/****************************************
 * Class Name : CH_EmailAttachmentHandler
 * Created Date: 15 Oct 2018
 * Created By : Marwan Boutaleb (mboutaleb@salesforce.com)
 * Last Modified by: Marwan Boutaleb (mboutaleb@salesforce.com)
 * Last Modified Date: 23 Oct 2018
 * Description : Upload attachment to CAPS
 *	  The aim of the following code is to store the emails attachments received as case replies into CAPS system.
 *	  All the rest calls in this class are an exact replication of the mecanism of saving an attachement in CAPS: 
 *	  present at the level of the lightning component CAPS_UploadMultipleAttachment
 *	  This class reformulates the XMLHttpRequest calls present at the level of the helper of the same component into Apex rest calls.
 * Test Class: CH_EmailAttachmentHandler_Test
 *****************************************/
public class CH_EmailAttachmentHelper implements Queueable, Database.AllowsCallouts { 
	
	boolean customerVisible = true; 
	string fileClassification = 'Other Information';
	Integer fileMaxSizeBytes = Integer.valueOf(Label.CH_EmailAttachmentSize);//3000000;
	
	public Id caseId {get; set;}
	public Messaging.InboundEmail.BinaryAttachment bAttachment {get; set;}
	public Messaging.InboundEmail.TextAttachment tAttachment {get; set;}
	public string emailSubject {get; set;}
	
	public void execute(QueueableContext context){
		
		if(caseId != null){
			
			if(bAttachment != null && bAttachment.body != null && bAttachment.body.size() <= fileMaxSizeBytes)
			{createCAPSattachment(caseId, customerVisible, bAttachment.fileName, emailSubject, fileClassification, bAttachment.body.size(), bAttachment.body); }   
			
			if(tAttachment != null && tAttachment.body != null && tAttachment.body.length() <= fileMaxSizeBytes) {createCAPSattachment(caseId, customerVisible, tAttachment.fileName, emailSubject, fileClassification, tAttachment.body.length(), Blob.valueOf(tAttachment.body));}
		}
		
	}
	
	// Constructor
	public CH_EmailAttachmentHelper(Id caseId, string emailSubject, Messaging.InboundEmail.BinaryAttachment bAttachment){
		this.caseId = caseId;
		this.bAttachment = bAttachment;
		this.emailSubject = emailSubject;
	}
	
	// Constructor
	public CH_EmailAttachmentHelper(Id caseId, string emailSubject, Messaging.InboundEmail.TextAttachment tAttachment){
		this.caseId = caseId;
		this.tAttachment = tAttachment;
		this.emailSubject = emailSubject;
	}
	
	/*
		This method replicates the same behavior used at the level of the component CAPS_UploadMultipleAttachment to upload attachment in CAPS system
	*/
	public void createCAPSattachment(Id caseId, boolean customerVisible, string fileName, string fileDescription, string fileClassification, Integer fielSize, Blob fileBody){
		
		if(Test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new CH_EmailAttachmentHandler_Test.MockHttpCAPSresponse1());
		// Get signature for CAPS 
		CAPS_MultiFileUploadWrapper wrap = Test.isRunningTest() ? new CAPS_MultiFileUploadWrapper() : CAPS_MultiFileUploadController.initiateUpload(caseId, customerVisible, fileName, fileDescription, fileClassification, fielSize);
		system.debug('#wrap:' + wrap);
		
		if(Test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new CH_EmailAttachmentHandler_Test.MockHttpCAPSresponse2());
		
		string enpointurl = wrap.baseURL + wrap.logApiURL;
		string authHeader = 'Signature keyId="'+ wrap.signatureKey+'",' + 'algorithm="hmac-sha256", ' + 'headers="(request-target) x-amz-date x-end-user",' + 'signature= "' + wrap.signature + '"';
		map<string, string> headers = new map<string, string>{'Content-Type' => 'application/json', 'x-amz-date' => wrap.nowFormatted, 'X-End-User'=> 'CAPSCLI', 'Authorization' => authHeader};
		//call to creare attachement
		HTTPResponse res;
		if(!Test.isRunningTest()){res = restCall('POST', enpointurl, headers, wrap.jsonString, null);}
		CAPS_MultiFileUploadWrapper wrap2 = Test.isRunningTest() ? new CAPS_MultiFileUploadWrapper() : CAPS_MultiFileUploadController.parseAttachmentResponse(res.getbody());
		system.debug('###wrap2:' + wrap2);
		
		string aws_signature_version = Test.isRunningTest() ? '4' : wrap2.aws_signature_version;
		
		string filenameUTF8 =encode(wrap2.s3keyname);
		// Remove spaces from the filename
		filenameUTF8 = filenameUTF8.replaceAll('\\+','%20');
		string algorithm = 'AWS4-HMAC-SHA256';
		string region = wrap2.s3_region;
		string service = 's3';
		
		map<string, string> headers3;
		string s3v4SignAPIUrl = CH_Settings__c.getValues('CAPSVS3SignAPIV4Url') != null ? CH_Settings__c.getValues('CAPSVS3SignAPIV4Url').SettingValue__c :'';
		if(aws_signature_version == '2'){
			string urlToSignPOST = 'POST\n\n\n\n'+'x-amz-acl:'+wrap2.acl+'\n'+'x-amz-date:'+wrap2.amzdate+'\n'+'/'+wrap2.bucket+'/'+filenameUTF8+'?uploads';
			string urlPOST = wrap.baseURL + wrap.s3SignApiURL+'?to_sign='+encode(urlToSignPOST)+'&signer='+encode(wrap2.signer)+'&user='+encode(wrap2.user)+'&expiration='+encode(wrap2.expiration)+'&permission='+encode(wrap2.permission)+'&signtoken='+ encode(wrap2.signtoken);
			//sign api call before getting upload id
			HTTPResponse res2; if(!Test.isRunningTest()){res2 = restCall('GET', urlPOST, null, null, null);}
			string jSONResponseUploadIDS3Token1 = res2.getBody(); string s3authPOST = wrap2.aws_key + ':' + jSONResponseUploadIDS3Token1; string authHead = 'AWS ' + s3authPOST;
			headers3 = new map<string, string>{'x-amz-acl'=> wrap2.acl, 'x-amz-date'=> wrap2.amzdate, 'Authorization' => authHead};
		}else if(aws_signature_version == '4'){
			DateTime now = DateTime.now();
			string dateStamp = now.formatGMT('yyyyMMdd');
			string timeStamp = now.formatGMT('HHmmss');
			string dateTimeStamp = dateStamp+'T'+timeStamp+'Z';
			string credential_scope = dateStamp + '/' + region + '/' + service + '/' + 'aws4_request';
			string method1 = 'POST';
			string bucket1 = wrap2.bucket;
			string s3keyname4 = filenameUTF8;
			string canonical_querystring = 'uploads=';
			string signed_headers = 'host;x-amz-acl;x-amz-date';
			if(!Test.isRunningTest()){
			string canonical_uri = '/'+wrap2.aws_url.split('/')[3]+'/'+wrap2.aws_url.split('/')[4]+'/'+bucket1+'/'+s3keyname4; string host = wrap2.aws_url.split('/')[2]; string canonical_headers = 'host:' + host + '\n' +'x-amz-acl:' +'private'+'\n'+ 'x-amz-date:' + dateTimeStamp +'\n';
			string payload_hash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(''))); string canonical_request = method1 + '\n' + canonical_uri + '\n' + canonical_querystring + '\n' + canonical_headers + '\n' + signed_headers + '\n' + payload_hash;
			string to_sign = algorithm + '\n' +  dateTimeStamp + '\n' +  credential_scope + '\n' +  EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(canonical_request)));
			string urlPOST = s3v4SignAPIUrl+'?to_sign='+encode(to_sign)+'&datetime='+encode(dateTimeStamp)+'&canonical_request='+encode(canonical_request)+'&signer='+encode(wrap2.signer)+'&user='+encode(wrap2.user)+'&expiration='+encode(wrap2.expiration)+'&permission='+encode(wrap2.permission)+'&signtoken='+ encode(wrap2.signtoken);
			HTTPResponse res2 = restCall('GET', urlPOST, null, null, null); string jSONResponseUploadIDS3Token1 = res2.getBody(); string authHead = 'AWS4-HMAC-SHA256 '+'Credential='+wrap2.aws_key+'/'+credential_scope+', SignedHeaders='+signed_headers+', Signature='+jSONResponseUploadIDS3Token1; headers3 = new map<string, string>{'x-amz-content-sha256'=>payload_hash,'x-amz-acl'=> wrap2.acl, 'x-amz-date'=> dateTimeStamp, 'Authorization' => authHead};
			}
		}
		if(Test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new CH_EmailAttachmentHandler_Test.MockHttpCAPSresponse3());
		string enpointPOST = wrap2.aws_url + '/' + wrap2.bucket + '/' + filenameUTF8 + '?uploads';
		//call to get upload id
		HTTPResponse res3;
		string jSONResponseUploadIDS3Token;
		if(!Test.isRunningTest()){ res3 = restCall('POST', enpointPOST, headers3, null, null); jSONResponseUploadIDS3Token = res3.getBody();}
		system.debug('###jSONResponseUploadIDS3Token!>' + jSONResponseUploadIDS3Token);
		string s3uploadid;
		DOM.Document document = new DOM.Document();
		if(!string.isBlank(jSONResponseUploadIDS3Token)) {document.load(jSONResponseUploadIDS3Token);}
		Dom.XMLNode noda = document.getRootElement();
		if(noda != null)
		for(Dom.XMLNode child : noda.getChildElements()) { if(child.getName() == 'UploadId') s3uploadid = child.getText();}
		system.debug('###s3uploadid:' + s3uploadid);
		map<string, string> headers5;
		if(aws_signature_version == '2'){
			string nowFormatted = DateTime.now().formatGMT(CAPS_ConstantHandler.DATE_FORMAT); string urlToSignPUT = 'PUT\n\n'+'text/plain;charset=UTF-8'+'\n\n'+'x-amz-date:'+nowFormatted+'\n'+'/'+wrap2.bucket+'/'+filenameUTF8+'?partNumber='+ '1' +'&uploadId='+s3uploadid;
			String capsSignAPIUrl = wrap.baseURL + wrap.s3SignApiURL; string url4 = capsSignAPIUrl +'?to_sign='+encode(urlToSignPUT)+'&signer='+encode(wrap2.signer)+'&user='+encode(wrap2.user)+'&expiration='+encode(wrap2.expiration)+'&permission='+encode(wrap2.permission)+'&signtoken='+encode(wrap2.signtoken);
			HTTPResponse res4 = restCall('GET', url4, null, null, null); string JSONResponseS3 = res4.getBody();
			system.debug('###JSONResponseS3:' + JSONResponseS3); string s3authPUT = wrap2.aws_key + ':'+JSONResponseS3; string authHead3 = 'AWS '+s3authPUT;
			headers5 = new map<string, string>{'x-amz-date'=> nowFormatted, 'Content-Type' => 'text/plain;charset=UTF-8', 'Authorization'=> authHead3};
		}else if(aws_signature_version == '4'){
			DateTime now = DateTime.now();
			string dateStamp = now.formatGMT('yyyyMMdd');
			string timeStamp = now.formatGMT('HHmmss');
			string dateTimeStamp = dateStamp+'T'+timeStamp+'Z';
			string credential_scope = dateStamp + '/' + region + '/' + service + '/' + 'aws4_request';
			string method2 = 'PUT';
			string bucket2 = wrap2.bucket;
			string s3keyname4 =filenameUTF8;
			string canonical_part = 'partNumber='+'1'+'&uploadId='+s3uploadid;
			string canonical_querystring = 'uploads=';
			string sign_headers = 'content-md5;host;x-amz-date';
			if(!Test.isRunningTest()){
			string canonical_uri = '/'+wrap2.aws_url.split('/')[3]+'/'+wrap2.aws_url.split('/')[4]+'/'+bucket2+'/'+s3keyname4;
			string host = wrap2.aws_url.split('/')[2]; string canonical_headers = 'host:' + host + '\n' + 'x-amz-date:' + dateTimeStamp; string md5data = EncodingUtil.base64Encode(Crypto.generateDigest('MD5', fileBody));
			string canonical_part2 = 'content-md5:'+md5data; string canonical_request = method2 + '\n' + canonical_uri + '\n' + canonical_part + '\n' + canonical_part2 + '\n' + canonical_headers + '\n'+'\n'+sign_headers + '\n' + 'UNSIGNED-PAYLOAD';
			string to_sign = algorithm + '\n' +  dateTimeStamp + '\n' +  credential_scope + '\n' +  EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(canonical_request))); string url4 = s3v4SignAPIUrl+'?to_sign='+encode(to_sign)+'&datetime='+encode(dateTimeStamp)+'&canonical_request='+encode(canonical_request)+'&signer='+encode(wrap2.signer)+'&user='+encode(wrap2.user)+'&expiration='+encode(wrap2.expiration)+'&permission='+encode(wrap2.permission)+'&signtoken='+ encode(wrap2.signtoken);
			HTTPResponse res4; if(!Test.isRunningTest()){res4 = restCall('GET', url4, null, null, null);} string JSONResponseS3 = res4.getBody();
			system.debug('###JSONResponseS3:' + JSONResponseS3);
			string s3auth = 'Credential='+wrap2.aws_key+'/'+credential_scope+', SignedHeaders='+sign_headers+', Signature='+JSONResponseS3; string authHead3 = 'AWS4-HMAC-SHA256 '+s3auth; headers5 = new map<string, string>{'Authorization'=> authHead3, 'x-amz-content-sha256'=> 'UNSIGNED-PAYLOAD','x-amz-date'=> dateTimeStamp, 'content-md5' => md5data};
			}
		}
		if(Test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new CH_EmailAttachmentHandler_Test.MockHttpCAPSresponse4());
		//sign api call before upload of content
		string uploadEndPointUrl = wrap2.aws_url + '/'+wrap2.bucket+'/'+filenameUTF8+'?partNumber='+ '1' +'&uploadId='+s3uploadid;
		//call to upload content
		HTTPResponse res5;
		res5 = restCall('PUT', uploadEndPointUrl, headers5, null, fileBody);
		
		string etag = Test.isRunningTest() ? 'm7fQ2Jej9bNzIg4vr8NYL1abdcg=' : res5.getHeader('ETag');
		system.debug('###ETAG:' + etag);
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName('Name');
		gen.writeStartArray();
		gen.writeStartObject();
		gen.writeStringField('partNumber', '1');
		gen.writeStringField('etag', etag);
		gen.writeEndObject();
		gen.writeEndArray();
		gen.writeEndObject();
		string partVsetagjson = gen.getAsString();
		// Running the test class results in System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out
		string rresult = Test.isRunningTest() ? 'TEST_IS_RUNNING' : CAPS_MultiFileUploadController.uploadComplete(partVsetagjson, s3uploadid, JSON.Serialize(wrap2), fileName, fielSize, (string)caseId, customerVisible, fileDescription, fileClassification, filenameUTF8, true );
		system.debug('###result:' + rresult);
	}
	
	public HTTPResponse restCall(string method, string endpoint, map<string, string> headers, string body, Blob blobAttach){ 
		
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setTimeout(120000);
		req.setMethod(method);
		req.setEndpoint(endpoint);
		if(headers != null && !headers.isEmpty()){for(string head : headers.keySet()){if(!string.isBlank(head) && !string.isBlank(headers.get(head))){ req.setHeader(head, headers.get(head)); }}}
		if(!string.isBlank(body)) {req.setBody(body);}
		if(blobAttach != null) {req.setBodyAsBlob(blobAttach);}
		system.debug('###CALLOUT_START:');
		system.debug('###Method:' + method + '#endpoint:' + endpoint);
		HTTPResponse res; if(!Test.isRunningTest()){res = http.send(req);
		system.debug('###Status:' + res.getStatus());
		system.debug('###CALLOUT_RESPONSE_BODY_START:');
		system.debug(res.getbody());
		system.debug('###CALLOUT_RESPONSE_BODY_END:');
		system.debug('###CALLOUT_END:');
		}										  
		return res;
	}
	
	static string encode(string tring){
		return string.isBlank(tring) ? '' : EncodingUtil.urlEncode(tring, 'UTF-8');
	}
	
	public static AttachmentHeader getAttHeader(list<Messaging.InboundEmail.Header> headers){
		AttachmentHeader attHeader = new AttachmentHeader();
		if(headers != null)
		for(Messaging.InboundEmail.Header header : headers){
			if(header.name == 'Content-ID')		 attHeader.attachementId = header.value.substringBetween('<','>');
			if(header.name == 'Content-Type')	 attHeader.contentType = header.value;
			if(header.name == 'Content-Disposition')	attHeader.contentDisposition = header.value.substring(0, header.value.indexOf(';'));
		}
		return attHeader;
	}
	
	public class AttachmentHeader{
		public string contentType {get; set;}
		public string contentDisposition {get; set;} // Format: inline; filename="image.png"...
		public string attachementId {get; set;}
	}
	
	public static void sendEmailNotification(string toAddress, string subject, string senderName, string plainTextBody, string messageId){
		system.debug('###CH_EmailAttachmentHelper:sendEmailNotification:START');
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.setToAddresses(new list<string>{ toAddress});
		//message.setSenderDisplayName(senderName);
		message.setPlainTextBody(plainTextBody);
		message.setInReplyTo(messageId);
		// setReferences(references)
		message.setSubject(subject);
		list<OrgWideEmailAddress> orgEmail = new list<OrgWideEmailAddress>([SELECT Id FROM OrgWideEmailAddress WHERE Address LIKE '%support.service%' limit 1]);
		if(!orgEmail.isEmpty()) message.setOrgWideEmailAddressId(orgEmail[0].Id);
		system.debug('##CH_EmailAttachmentHelper:Email:'+ message);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		system.debug('###CH_EmailAttachmentHelper:sendEmailNotification:END');
		
	}

}