@isTest
public class CH_EmailAttachmentHandler_Test {
	
	@testSetup static void setup(){ 
		
		/*
		CH_CaseTriggerHelper.debuggingLimits('TEST SETUP BEFORE');
		//CH_UTIL_TEST.setupCase(false); 
		
		//User portalAccountOwner;
		Product2 tempProduct;
		PriceBookEntry tempPriceBookEntry;
		//CH_UTIL_TEST.setupCase(false); 
		
		//CH_UTIL_TEST.createCustomSettings(); 
		CH_AccountName__c  setting = new CH_AccountName__c  ();
		setting.CH_InvalidName__c = 'Nokia';
		setting.CH_ValidName__c = 'test';
		insert setting;
		
		//CH_UTIL_TEST.createNokiaUsers(); 
		User runAsUser = new User(Id = UserInfo.getUserId());
		integer NokiaId = 100;
		
		//CH_UTIL_TEST.createAccounts();
		Account tempParentAccount;
		Account tempLegalAccount;
		
		List<Account> newAccounts = new List<Account>();
			
		// Create parent account
		Id accountCustomerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
		tempParentAccount = new Account(
			Name = 'PARENT-ACOOUNT',
			//OwnerId = portalAccountOwner.Id,
			RecordTypeId = accountCustomerRecordType
		);
		newAccounts.add(tempParentAccount);		
		
		// Create legal entity
		Id accountLegalEntityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		tempLegalAccount = new Account(
			Name = 'LEGAL-ACCOUNT',
			//OwnerId = portalAccountOwner.Id,
			RecordTypeId = accountLegalEntityRecordType
		);
		newAccounts.add(tempLegalAccount);	  
		
		System.runAs(runAsUser) {			
			Insert newAccounts;
			
			if (newAccounts[1].Name == 'LEGAL-ACCOUNT'){
				newAccounts[1].ParentId = newAccounts[0].id;
				Update newAccounts[1];		
			}
			
			// Add a account team member
			AccountTeamMember member = new AccountTeamMember();
			member.AccountId  = tempLegalAccount.Id;
			member.UserId  = runAsUser.Id;
			member.TeamMemberRole  = 'Customer Care Manager';
			insert member;
		}		

		
		//CH_UTIL_TEST.createContacts();
		List<Contact> newContacts = new List<Contact>();
		string email = System.now().millisecond() + 'test@test.com';
		
		// Create the contact that is needed for portal users
		Contact normalContact = new Contact(
			FirstName = 'McTesty',
			Lastname = String.valueOf(System.now().millisecond()),
			Email = email,
			AssistantName = 'Normal Contact',
			AccountId = tempParentAccount.Id
		);
		newContacts.add(normalContact);
		
		// Create the contact that is needed for portal users
		Contact portalContact = new Contact(
			FirstName = 'Portal Contact',
			Lastname = String.valueOf(System.now().millisecond()),
			Email = System.now().millisecond() + 'test2@test.com',
			AssistantName = 'Portal Contact',
			AccountId = tempParentAccount.Id
		);
		newContacts.add(portalContact);
		
		System.runAs(runAsUser) {			
			Insert newContacts;
		}
		
		//CH_UTIL_TEST.CreatePortalUsers();		 
		
		//CH_UTIL_TEST.createProducts();
		CH_Import_UTIL_TEST.CreateCustomPriceBook();
		
		tempProduct = new Product2(
			Name = 'TestProduct',
			NokiaCPQ_State__c = 'Implement',
			NCP_CAREACTIVATE__c = 'test',
			PMD_Portfolio_Classification__c = 'Product'
		);
		
		System.runAs(runAsUser) {			
			Insert tempProduct;
			
			tempPriceBookEntry = new PriceBookEntry(
				Pricebook2Id = Test.getStandardPricebookId(),
				Product2Id = tempProduct.id,
				UnitPrice = 0,
				CurrencyIsoCode = 'EUR',
				IsActive = true
			);
			Insert tempPriceBookEntry;
		}
		
		
		//CH_UTIL_TEST.createContracts(false);
		// Create the assset
		Asset asset = createAssets(tempLegalAccount, tempProduct);
			   
		// Create contract
		ServiceContract serviceContract = new ServiceContract(
			AccountId = tempLegalAccount.Id, 
			Name = 'TestServiceContract',
			CH_CDB_ContractId__c = 'Test',
			//OwnerId = [SELECT Id FROM User WHERE Alias = 'NP1' LIMIT 1].Id,
			CH_EntitlementScript__c = '',
			Pricebook2Id = Test.getStandardPricebookId()
		);
		Insert serviceContract;

		// Create Contract Line Item 
		ContractLineItem contractLineItem = new ContractLineItem(
			ServiceContractId = serviceContract.Id,
			AssetId = asset.Id,
			UnitPrice = 0,
			Quantity = 1,
			PricebookEntryId = tempPriceBookEntry.Id, 
			CH_LineItemEntitlementScript__c = '',
			CH_CDB_EntitlementId__c = 'TEST', 
			CH_ServiceMappingId__c = 'Legacy Customer Support Service - Critical Major Minor 24x7'
		);
		Insert contractLineItem;
		
		// Create entitlement
		Entitlement entitlement = new Entitlement(
			AccountId = tempLegalAccount.Id,
			AssetId = asset.Id,
			Startdate = Date.Today().addDays(-1), // To get an Active entitlement
			CH_CDB_EntitlementId__c = '12345',
			ContractLineItemId = contractLineItem.Id,
			ServiceContractId = serviceContract.Id,
			CH_EntitlementType__c = 'Entitled Asset',
			Name = 'TestEntitlement',
			CH_ServiceMappingId__c = 'Legacy Customer Support Service - Critical Major Minor 24x7'
		);
		Insert entitlement;
		
		// authorized entitlement
		Entitlement authorizedEntitlement = new Entitlement(
			AccountId = tempLegalAccount.Id,
			AssetId = asset.Id,
			Startdate = Date.Today().addDays(-1), // To get an Active entitlement
			CH_CDB_EntitlementId__c = '12345',
			ContractLineItemId = contractLineItem.Id,
			ServiceContractId = serviceContract.Id,
			CH_EntitlementType__c = 'Authorized Contact',
			Name = 'Authorized Contact Entitlement',
			CH_ServiceMappingId__c = 'Legacy Customer Support Service - Critical Major Minor 24x7'
		);
		Insert authorizedEntitlement;
		
		serviceContract.CH_Entitlement__c = authorizedEntitlement.Id;
		update serviceContract; 
		
		contractLineItem.CH_Entitlement__c = entitlement.Id;
		update contractLineItem; 
		
		List<Contact> contacts = [SELECT Id FROM Contact 
								  WHERE AssistantName = 'Normal Contact' OR AssistantName = 'Portal Contact'];		
		
		list<EntitlementContact> entitlementContactlist = new list<EntitlementContact>();
		list<AccountContactRelation> accountContactRelationList = new list<AccountContactRelation>();
		
		// Creat an authorized contact
		for (Contact contact : contacts){
			EntitlementContact entitlementContact = new EntitlementContact();
			entitlementContact.ContactId = contact.Id;
			entitlementContact.EntitlementId = entitlement.id;
			entitlementContactlist.add(entitlementContact);
			//insert entitlementContact; 
			
			System.runAs(runAsUser) {	 
				AccountContactRelation accountContactRelation = new AccountContactRelation();
				accountContactRelation.AccountId = tempLegalAccount.Id;
				accountContactRelation.ContactId = contact.id;
				accountContactRelation.NCP_Entitlement_Relationship__c = true;
				accountContactRelationList.add(accountContactRelation);
				//insert accountContactRelation;
			}
		}
		System.runAs(runAsUser){
			if(!entitlementContactlist.isEmpty()) insert entitlementContactlist;
			if(!accountContactRelationList.isEmpty()) insert accountContactRelationList;	
		}
		
		// Create the authroized account
		CH_AuthorizedAccount__c authorizedAccount = new CH_AuthorizedAccount__c();
		authorizedAccount.CH_Account__c = tempLegalAccount.id;
		authorizedAccount.CH_ServiceContract__c = serviceContract.Id;
		insert authorizedAccount;
		
		//CH_UTIL_TEST.createWorkgroups();
		
		CH_CaseTriggerHelper.debuggingLimits('TEST SETUP END');
		CH_Settings__c cstObj = new CH_Settings__c();
		cstObj.Description__c = 'CAPSSecret';
		cstObj.SettingValue__c = 'MzExMjgwNzk0NGI0NGRiMTk3YjE3ZWQwN2I0MzMxODc=';
		cstObj.Name = 'CAPSSecret'; 
		insert cstObj;
		
		CH_Settings__c cstObj2 = new CH_Settings__c();
		cstObj2.Description__c = 'if the attachment status is not ready with in specific time we are making the status as on hold';
		cstObj2.SettingValue__c = '3';
		cstObj2.Name = 'SpecificTimeForOnhold'; 
		insert cstObj2; 
		
		CH_AvoidRecursion.beforeInsert = false;
		CH_AvoidRecursion.beforeUpdate = false;
		CH_AvoidRecursion.afterInsert = false;
		CH_AvoidRecursion.afterUpdate = false;
		
		CH_CaseTriggerHelper.debuggingLimits('BEFORE CASE CREATION');
		// Create a case
		Case newCase = new Case(CH_InternalCase__c = true, AccountId = tempLegalAccount.Id, AssetId = asset.Id, CH_ReportedDate__c = DateTime.Now(),
			Mobile_Phone__c = '123-456789', Country__c = 'Sweden', reason = 'New problem', ContactId = normalContact.Id, Subject = 'test 111',
			CH_Summary__c = 'test 111', Type = 'Incident', Description = 'TEST', Severity__c = 'Minor',
			CH_Outage__c = 'No',  Status = 'Created', CH_IssueOccurenceDate__c = system.today(),
			ProductId = tempProduct.id, EntitlementId = entitlement.Id,			
			recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Nokia Standard Case').getRecordTypeId());		
		 insert newCase;
		CH_CaseTriggerHelper.debuggingLimits('AFTER CASE CREATION');
		*/
		
		CH_AvoidRecursion.beforeInsert = false;
		CH_AvoidRecursion.beforeUpdate = false;
		CH_AvoidRecursion.afterInsert = false;
		CH_AvoidRecursion.afterUpdate = false;
		CH_AvoidRecursion.doNtExcuteCseTrggr4NotfcationBtch = false;
		CH_UTIL_TEST.setupCase(false);
		
		
		//CH_UTIL_TEST.setupCase(false);

	}
	
	static Case createNewCHcase(){
		
		// Create a new CH case
		CH_AvoidRecursion.beforeInsert = false;
		CH_AvoidRecursion.beforeUpdate = false;
		CH_AvoidRecursion.afterInsert = false;
		CH_AvoidRecursion.afterUpdate = false;
		CH_AvoidRecursion.doNtExcuteCseTrggr4NotfcationBtch = false;
		Case newCase = CH_UTIL_TEST.createCaseNotSaved('Test1', 'Minor', 'No', 'Nokia Standard Case', true); 
		newCase.CH_ServiceType__c = 'Customer Support';
		newCase.CH_OutageEndDate__c = datetime.now().addDays(5);
		newCase.CH_OutageStartDate__c = datetime.now();		 
		newCase.ownerId = Userinfo.getUserId();
		insert newCase;
		return newCase;
		
	}
	
	@isTest static void sendNewEmailWithNoRelatedCase(){
		
		Test.startTest(); 
		
		Case newCase = createNewCHcase(); 
		
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		
		// setup the data for the email
		email.subject = 'Test theadId [ ref:_00D1FDGvi._5001F1zZnV:ref ]';
		email.fromAddress = 'Test932047120919781@nokia.com';
		email.plainTextBody = 'email body content';
		email.HtmlBody = 'email body content';
		email.toAddresses = new list<string>{'alphaUser@test.com'}; 
		
		Test.setMock(HttpCalloutMock.class, new MockHttpCAPSresponse());
		// call the email service class  
		CH_EmailAttachmentHandler inbound = new CH_EmailAttachmentHandler();
		inbound.caseId = null;
		inbound.handleInboundEmail(email, env);
		Test.stopTest();	
		
		list<EmailMessage> message = new list<EmailMessage>([SELECT Id FROM EmailMessage WHERE Subject = 'Test theadId [ ref:_00D1FDGvi._5001F1zZnV:ref ]']);
		system.assert(message.isEmpty(), 'No message should be found');
		
	}
	// Test that an email without an email chain gets discarded
	@isTest static void sendNewEmail(){
		Test.startTest();
		//Case newCase = CH_UTIL_TEST.createCaseNotSaved('Test1', 'Minor', 'No', 'Nokia Standard Case', false); 
		//insert newCase;
		Case newCase = createNewCHcase(); 
		
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		
		// setup the data for the email
		email.subject = 'Test theadId [ ref:_00D1FDGvi._5001F1zZnV:ref ]';
		email.fromAddress = 'Test932047120919781@nokia.com';
		email.plainTextBody = 'email body content';
		email.HtmlBody = 'email body content';
		email.toAddresses = new list<string>{'alphaUser@test.com'}; 
		
		Test.setMock(HttpCalloutMock.class, new MockHttpCAPSresponse());
		// call the email service class  
		CH_EmailAttachmentHandler inbound = new CH_EmailAttachmentHandler();
		inbound.caseId = newCase.Id;
		inbound.handleInboundEmail(email, env);
		Test.stopTest();	
		
		list<EmailMessage> message = new list<EmailMessage>([SELECT Id FROM EmailMessage WHERE Subject = 'Test theadId [ ref:_00D1FDGvi._5001F1zZnV:ref ]']);
		system.assert(message.isEmpty(), 'No message should be found');
	}
	
	
	// Test that an email can be linked to an existing email chain on a case
	@isTest static void replyToCaseEmail(){
		Test.startTest();
		//Case newCase = CH_UTIL_TEST.createCaseNotSaved('Test1', 'Minor', 'No', 'Nokia Standard Case', false); 
		Case newCase = createNewCHcase();
		newCase.Status = 'Assigned';
		newCase.CH_AssignedDate__c = DateTime.Now();
		update newCase;

		EmailMessage existingEmailMessage = new EmailMessage();
		existingEmailMessage.parentid = newCase.Id;
		existingEmailMessage.Subject = 'Test theadId [ ref:_00D1FDGvi._5001F1zZnV:ref ]';
		existingEmailMessage.CH_Email_Type__c = 'Update';
		insert existingEmailMessage;
			
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		
		// setup the data for the email
		email.subject = 'Test theadId [ ref:_00D1FDGvi._5001F1zZnV:ref ]';
		email.fromAddress = 'Test932047120919781@nokia.com';
		email.plainTextBody = 'email body content';
		email.HtmlBody = 'email body content';
		email.toAddresses = new list<string>{'alphaUser@test.com'}; 
		
		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment attachment2 = new Messaging.InboundEmail.BinaryAttachment();
		attachment2.body = blob.valueOf('png body');
		attachment2.fileName = 'exemple.png';
		attachment2.mimeTypeSubType = 'image/png';
		
		Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		attachment.body = blob.valueOf('png body');
		attachment.fileName = 'exemple.png';
		attachment.mimeTypeSubType = 'image/png';
		list<Messaging.InboundEmail.Header> headers = new list<Messaging.InboundEmail.Header>();
		Messaging.InboundEmail.Header header1 = new Messaging.InboundEmail.Header();
		header1.name = 'X-Attachment-Id';
		header1.value = 'cid:AttachmentID2342';
		headers.add(header1);
		Messaging.InboundEmail.Header header2 = new Messaging.InboundEmail.Header();
		header2.name = 'Content-Disposition';
		header2.value =  'inline; filename="image.png"';
		headers.add(header2);
		attachment.headers = headers;
		
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment, attachment2 };
			
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
		attachmenttext.body = 'text body';
		attachmenttext.fileName = 'example2.txt';
		attachment.mimeTypeSubType = 'text/plain';
		email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
			
		Test.setMock(HttpCalloutMock.class, new MockHttpCAPSresponse());
		// call the email service class  
		CH_EmailAttachmentHandler inbound = new CH_EmailAttachmentHandler();
		inbound.caseId = newCase.Id;
		inbound.handleInboundEmail(email, env);
		list<EmailMessage> message2 = new list<EmailMessage>([SELECT Id FROM EmailMessage]); // WHERE Subject = 'Nokia Support - Unable to Process Email']);
		list<EmailMessage> message = new list<EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId = :newCase.Id]);
		Test.stopTest();	

		System.debug('xxx ' + message2.size());		
		system.assert(message.size()==2, 'There must be 2 emails. Orginal and Reply');
		
	}
	
	@isTest static void replyToCaseEmail2(){
		Test.startTest();
		Case newCase = createNewCHcase();
		newCase.Status = 'Assigned';
		newCase.CH_AssignedDate__c = DateTime.Now();
		update newCase;

		EmailMessage existingEmailMessage = new EmailMessage();
		existingEmailMessage.parentid = newCase.Id;
		existingEmailMessage.Subject = 'Test theadId [ ref:_00D1FDGvi._5001F1zZnV:ref ]';
		existingEmailMessage.CH_Email_Type__c = 'Update';
		insert existingEmailMessage;
			
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		
		// setup the data for the email
		email.subject = 'Test theadId [ ref:_00D1FDGvi._5001F1zZnV:ref ]';
		email.fromAddress = 'Test932047120919781@nokia.com';
		email.plainTextBody = 'email body content';
		email.HtmlBody = 'email body content';
		email.toAddresses = new list<string>{'alphaUser@test.com'}; 
		
		// add an Binary attachment
		Messaging.InboundEmail.BinaryAttachment attachment2 = new Messaging.InboundEmail.BinaryAttachment();
		attachment2.body = blob.valueOf('png body');
		attachment2.fileName = 'exemple.png';
		attachment2.mimeTypeSubType = 'image/png';
		
		Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		attachment.body = blob.valueOf('png body');
		attachment.fileName = 'exemple.png';
		attachment.mimeTypeSubType = 'image/png';
		list<Messaging.InboundEmail.Header> headers = new list<Messaging.InboundEmail.Header>();
		Messaging.InboundEmail.Header header1 = new Messaging.InboundEmail.Header();
		header1.name = 'X-Attachment-Id';
		header1.value = 'cid:AttachmentID2342';
		headers.add(header1);
		Messaging.InboundEmail.Header header2 = new Messaging.InboundEmail.Header();
		header2.name = 'Content-Disposition';
		header2.value =  'inline; filename="image.png"';
		headers.add(header2);
		attachment.headers = headers;
		
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment, attachment2 };
			
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
		attachmenttext.body = 'text body';
		attachmenttext.fileName = 'example2.txt';
		attachment.mimeTypeSubType = 'text/plain';
		email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
			
		Test.setMock(HttpCalloutMock.class, new MockHttpCAPSresponse());
		// call the email service class  
		CH_EmailAttachmentHandler inbound = new CH_EmailAttachmentHandler();
		inbound.fileMaxSizeBytes = 1; 
		inbound.caseId = newCase.Id;
		inbound.handleInboundEmail(email, env);
		list<EmailMessage> message2 = new list<EmailMessage>([SELECT Id FROM EmailMessage]); // WHERE Subject = 'Nokia Support - Unable to Process Email']);
		list<EmailMessage> message = new list<EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId = :newCase.Id]);
		Test.stopTest();	

		System.debug('xxx ' + message2.size());		
		system.assert(message.size()==2, 'There must be 2 emails. Orginal and Reply');
		
	}
	/*
	@isTest static void testCAPSBinaryAttachmentCallout(){
		//Test.startTest();
		//CH_CaseTriggerHelper.debuggingLimits('FUNCTION 1');
		
		//CH_CaseTriggerHelper.debuggingLimits('BEFORE CASE CREATION');
		//Case newCase = CH_UTIL_TEST.createCaseNotSaved('Test1', 'Minor', 'No', 'Nokia Standard Case', false); 
		Case newCase = createNewCHcase();
		//Case newCase = CH_UTIL_TEST.createCaseNotSaved('Test1', 'Minor', 'No', 'Problem', false); 
		//insert newCase;
		//CH_CaseTriggerHelper.debuggingLimits('FUNCTION 3');
		
		Messaging.InboundEmail.BinaryAttachment attachment2 = new Messaging.InboundEmail.BinaryAttachment();
		attachment2.body = blob.valueOf('png body');
		attachment2.fileName = 'exemple.png';
		attachment2.mimeTypeSubType = 'image/png';
		CH_EmailAttachmentHelper attHelper = new CH_EmailAttachmentHelper(newCase.Id, 'Email Subject', attachment2); 
		//CH_CaseTriggerHelper.debuggingLimits('FUNCTION 4');   
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CH_EmailAttachmentHandler_Test.MockHttpCAPSresponse1());
		attHelper.execute(null);
		
		Test.stopTest();
	}
	*/
	
	/*
	@isTest static void testCAPSTextattachmentCallout(){
		
		Case newCase = createNewCHcase(); 
		//Case newCase = CH_UTIL_TEST.createCaseNotSaved('Test1', 'Minor', 'No', 'Nokia Standard Case', false); 
		//insert newCase;
		
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
		attachmenttext.body = 'text body';
		attachmenttext.fileName = 'example2.txt';
		attachmenttext.mimeTypeSubType = 'text/plain';
		CH_EmailAttachmentHelper attHelper2 = new CH_EmailAttachmentHelper(newCase.Id, 'Email Subject', attachmenttext);
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CH_EmailAttachmentHandler_Test.MockHttpCAPSresponse1());
		attHelper2.execute(null);
		Test.stopTest();	
	}
	*/
	
	public class MockHttpCAPSresponse1 implements HttpCalloutMock{
		public HTTPResponse respond(HTTPRequest req){
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"id":"c9c54141228044a98070638deba4e344","owner":"app_salesforce","owner_name":" ","owner_email":"ignore@nokia.com","app":"Salesforce CRM","classification":{"id":14,"name":"Non-Sensitive Data"},"classifications":[{"id":14,"name":"Non-Sensitive Data"}],"nctclassification":4,"customer":{"id":31502,"id_cdb":"76521","name":"Verizon Wireless, US","country_code":"US"},"product":null,"productversion":null,"ticket":{"id":15692,"app_name":"Salesforce CRM","ticket_id":"00013477"},"description":"file Desc","purpose":"Case Handling","files":[{"id":532282,"name":"TestFile20.txt","size":2416,"type":"original","status":"uploading","s3keyname":"c9c54141228044a98070638deba4e344/TestFile20.txt","processing_time":null,"s3_time":null,"dpc_id":"DPI_10269508821387T2","virus_scan_status":0}],"creation_time":"2018-10-26T07:07:08.715752-05:00","deletion_time":null,"retention_days":null,"status":null,"encryption_key":null,"evaporate":{"sign_params":{"permission":"RW","user":"app_salesforce","expiration":1540627629,"signer":"bdc7f90cef7345c984f9e34d25e0c192","signtoken":"4223fd6cca2de6b0-a245c85a8e7d5336a2e911ad190209cd7a9b526207b3e95e234da5f6ada0175f"},"aws_signature_version":"4","s3_region":"us-east-1","max_concurrent_parts":2,"acl":"private","part_size":33554432,"aws_key":"RZZVJKQRQUBLHMVWYTJ_","signer_url":"https://capsv.nokia.com/93f6cc8e/api/s3sign","aws_url":"https://s3.capsv.nokia.com/a848be61/us2","bucket":"capsvtest1"},"download_url":"https://capsv.nokia.com/93f6cc8e/downloadattachment?id=c9c54141228044a98070638deba4e344","download_url_external":"https://capsv.nokia.com/93f6cc8e/external/downloadattachment?id=c9c54141228044a98070638deba4e344","skip_scrambling":false,"service_class":"CARE","nct_lawful_intercept":null,"nct_case_status":null,"customer_visible":true,"retentiondaysleft":"N/A","capsrt_issue":null,"country_code":null,"SFsecuritygroup":"SEC_Default"}');
			res.setStatusCode(200);
			return res;
		}
	}
	
	public class MockHttpCAPSresponse2 implements HttpCalloutMock{
		public HTTPResponse respond(HTTPRequest req){
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('ypmfiJ/kRY1V5N3rf8sozn5rqIU=');
			res.setStatusCode(200);
			return res;
		}
	}
	
	public class MockHttpCAPSresponse3 implements HttpCalloutMock{
		public HTTPResponse respond(HTTPRequest req){
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/xml');
			res.setBody('<?xml version="1.0" encoding="UTF-8"?><InitiateMultipartUploadResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Bucket>capsvtest1</Bucket><Key>c9c54141228044a98070638deba4e344/TestFile20.txt</Key><UploadId>2~ZOTUTDzWqctucNysuAjXfyvi8YoUzO4</UploadId></InitiateMultipartUploadResult>');
			res.setStatusCode(200);
			return res;
		}
	}
	
	public class MockHttpCAPSresponse4 implements HttpCalloutMock{
		public HTTPResponse respond(HTTPRequest req){
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('m7fQ2Jej9bNzIg4vr8NYL1abdcg=');
			res.setStatusCode(200);
			return res;
		}
	}
	
	public class MockHttpCAPSresponse implements HttpCalloutMock{
		
		public HTTPResponse respond(HTTPRequest req){
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('');
			res.setStatusCode(200);
			return res;
		}   
	}
	
	
	static private Asset createAssets(Account portalAccount, Product2 product){
		// Create asset
		Asset asset = new Asset(
			AccountId = portalAccount.Id,
			Name = 'TestAsset',
			Product2Id = product.Id
		);
		
		System.runAs(new user(Id = UserInfo.getUserId())) {			
			Insert asset;
		}
		
		return asset;
	}
	
}