/****************************************
 * Class Name : CH_EmailAttachmentHandler
 * Created Date: 18 Sept 2018
 * Created By : Marwan Boutaleb (mboutaleb@salesforce.com)
 * Last Modified by: Marwan Boutaleb (mboutaleb@salesforce.com)
 * Last Modified Date: 23 Oct2018
 * Description : Upload attachment to CAPS
 *			   The aim of the following code is to store the emails attachments received as case replies into CAPS system.
 *			   All the rest calls in this class are an exact replication of the mecanism of saving an attachement in CAPS: 
 *			   present at the level of the lightning component CAPS_UploadMultipleAttachment
 *			   This class reformulates the XMLHttpRequest calls present at the level of the helper of the same component into Apex rest calls.
 *			   
 *			   This method fires a Queueable call for each non inline binary/text attachment received with email: this is due to the re-use of the method CAPS_MultiFileUploadController.uploadComplete that makes a callout and a DML operation
 *			   Adding an additional DML and a Callout in the same transaction will result in the famous exception: 'You have uncommitted work pending. Please commit or rollback before calling out'
 *			   The limit is 50 Queueable call per transaction = Max of 50 attachements in the email
 * Test Class: CH_EmailAttachmentHandler_Test
 *****************************************/
 
global class CH_EmailAttachmentHandler implements Messaging.InboundEmailHandler {
	
	@TestVisible Id caseId {get; set;} 
	string emailType = 'Update'; 
	string feedbody = 'An attachment from email reply was not stored in CAPS because its size is over 11MB ';
	string NotifBody = 'Sorry your attachment(s) was rejected because the limit size of 11MB has been exceeded ';
	@TestVisible Integer fileMaxSizeBytes = Integer.valueOf(Label.CH_EmailAttachmentSize);//3000000;
	
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
		Set<String> caseStatusSet = new Set<String>{'Completed','Closed','Cancelled'};
		Boolean isClosedOrCancelled = false;
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult(); 
		
		try{
			system.debug('###handleInboundEmail:subject:' + email.subject); 
			if(!string.isBlank(email.subject)){
				
				// Get the email reference present at the level of the email subject
				string threadId = email.subject.substringBetween('ref:',':ref');
				system.debug('###handleInboundEmail:threadId:' + threadId);
				
				if(!string.isBlank(threadId)){
					
					// Identify the related case, based on the previousely retrieved reference, from the email message records
					threadId = '%' + threadId + '%';
					list<EmailMessage> emails = new list<EmailMessage>([SELECT ParentId FROM EmailMessage WHERE Subject like :threadId limit 1]); // use MessageDate to imporve the query?
					if(!emails.isEmpty() && emails[0].ParentId != null) caseId = emails[0].ParentId;
					
					if(caseId != null){
						List<Case> caseList = new List<Case>([SELECT Id, 
															CaseNumber, Status, contact.Email
															FROM Case 
															WHERE Id = :caseId 
															LIMIT 1]);
						if(!caseList.isEmpty() && caseStatusSet.contains(caseList[0].Status)){
							if(email.textAttachments != null || email.binaryAttachments != null)
							{
								isClosedOrCancelled = true;
								CH_EmailAttachmentHelper.sendEmailNotification(email.fromAddress, 
																		   'Undeliverable: [ ref:' + threadId + ':ref ]', 
																		   System.Label.CH_SenderDisplayName,
																			'Dear Sender,'+'\n\nAn attachment from email reply was not processed as Support Case '+caseList[0].CaseNumber+ ' has been '+caseList[0].Status+'.'+'\n\nRegards,\n\nNokia Support',  
																		   email.messageId);
							}
						}
						string fileNamesOver3mb = '';
						system.debug('###handleInboundEmail:CaseId:' + caseId);
						list<FeedItem> feedItems = new list<FeedItem>();
						// Check if text attachment need to be uploaded to CAPS
						if(email.textAttachments != null)
							for(Messaging.InboundEmail.TextAttachment att : email.textAttachments){
								if(att.body.length() <= fileMaxSizeBytes){
									if(att.body != null && !Test.isRunningTest()){
										
										CH_EmailAttachmentHelper help = new CH_EmailAttachmentHelper(caseId, email.Subject, att);
										if(!isClosedOrCancelled){
											ID jobId = System.enqueueJob(help);
											system.debug('###CH_EmailAttachmentHandler:JobId:' + jobId);
										}   
									} 
								}else{
									feedItems.add(new FeedItem(ParentId = caseId, Body = feedbody + '(' + att.fileName + ')', Type = 'TextPost'));
									fileNamesOver3mb += string.isBlank(fileNamesOver3mb) ? att.fileName : ', ' + att.fileName;
								}
								 
							} 
						
						map<string, Attachment> contentIdAttachment = new map<string, Attachment>();
						// Save email inline content as Salesforce attachments and replace the header attachment id with the attachment url in the email html body
						// And send non inline attachment to CAPS 
						if(email.binaryAttachments != null){
							for(Messaging.InboundEmail.BinaryAttachment att : email.binaryAttachments){
								system.debug('#HEADERS:' + att.headers);
								CH_EmailAttachmentHelper.AttachmentHeader attHeader = CH_EmailAttachmentHelper.getAttHeader(att.headers);
								system.debug('#attHeader:' + attHeader);
								if(attHeader.contentDisposition == 'inline'){
									contentIdAttachment.put(attHeader.attachementId, new Attachment(parentId = caseId, Body = att.body, ContentType = attHeader.contentType, Name = att.fileName, Description = 'Inline attachment from email reply'));
								}else{
									if(att.body.size() <= fileMaxSizeBytes){
										if(!Test.isRunningTest()){
											CH_EmailAttachmentHelper help = new CH_EmailAttachmentHelper(caseId, email.Subject, att);
											if(!isClosedOrCancelled){
												ID jobId = System.enqueueJob(help);
												system.debug('###CH_EmailAttachmentHandler:JobId:' + jobId); 
											}										   
										}   
									}else{
										feedItems.add(new FeedItem(ParentId = caseId, Body = feedbody + '(' + att.fileName + ')', Type = 'TextPost'));
										fileNamesOver3mb += string.isBlank(fileNamesOver3mb) ? att.fileName : ', ' + att.fileName;
									}
									
								}
							} 
							
							system.debug('#feedItems:' + feedItems.size());
							if(!feedItems.isEmpty() && !isClosedOrCancelled) insert feedItems;
							
							system.debug('#contentIdAttachment:' + contentIdAttachment.size());
							system.debug('#contentIdAttachment:' + contentIdAttachment);
							if(!contentIdAttachment.isEmpty()) insert contentIdAttachment.values();
							
						} 
						
						// Attach the new email reply to the case
						string toAddresses = '';
						if(email.toAddresses != null && !email.toAddresses.isEmpty())
							for(string toAdd : email.toAddresses) toAddresses += toAdd + ', ';
							toAddresses = toAddresses.substringBeforeLast(', ');
						
						string htBody = email.htmlBody;
						if(!string.isBlank(htBody) && contentIdAttachment != null)
							for(string attId : contentIdAttachment.KeySet())
								htBody = htBody.replace('cid:' + attId, '/servlet/servlet.FileDownload?file=' + contentIdAttachment.get(attId).Id);
							
						EmailMessage newEmail = new EmailMessage(   ParentId = caseId, 
																	Subject = email.subject, 
																	FromAddress = email.FromAddress, 
																	FromName = email.FromName, 
																	TextBody = email.plainTextBody,
																	HtmlBody = htBody, 
																	toAddress = (string.isEmpty(caseList[0].contact.Email) ? toAddresses : caseList[0].contact.Email), 
																	CH_Email_Type__c = emailType);
						
						
						
						insert newEmail;
						
						system.debug('#fileNamesOver3mb:' + fileNamesOver3mb);
						if(!string.isBlank(fileNamesOver3mb) && !isClosedOrCancelled){
							CH_EmailAttachmentHelper.sendEmailNotification(email.fromAddress, 
																		   'Undeliverable: [ ref:' + threadId + ':ref ]', 
																		   System.Label.CH_SenderDisplayName, 
																		   System.Label.CH_AttachmentSizeRejectionBody + '\n\n File Name: ' + fileNamesOver3mb ,  
																		   email.messageId);
						}									 
					} 
				}
			}
			
			// Notify sender when no case is retreived
			if(caseId == null) 
				CH_EmailAttachmentHelper.sendEmailNotification(email.fromAddress, 
															   'Nokia Support - Unable to Process Email', 
															   System.Label.CH_SenderDisplayName, 
															   System.Label.CH_NoThreadIdentified,  
															   null);
			
			result.success = true;
		
		}catch (Exception e) {
			result.success = false;
			result.message = 'An error has occurred: '+ e.getMessage();
			system.debug('###Exception:Message>' + e.getMessage() + ':LineNumber>' + e.getLineNumber() + ':Cause>'+ e.getCause() + ':Type>'+ e.getTypeName() + ':Trace>'+ e.getStackTraceString());
		} 
		
		return result;
	}
	
}