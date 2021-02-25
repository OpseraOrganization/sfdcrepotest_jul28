/*
Class Name: CAPS_MultiFileUploadControllerTest
Date: 17 september 2018
Description: Test Class for CAPS multiple file Upload Attachment
Last Modified : Rajeshwari - 18th March 2020 - Fixed Test class coverage
*/
@isTest(seeallData= false)
public class CAPS_MultiFileUploadControllerTest{
	
   
	public testMethod static void CAPS_MultiFileUploadControllerGeneralMethod(){  
		List<Case> caseList = new List<Case>();
		caseList =  CAPS_TestDataUtil.createCaseRecord(1);
		caseList[0].CH_SolutionType__c = null;
		insert caseList;
		boolean iscomm =CAPS_MultiFileUploadController.isCommunity();  
		System.assertEquals(false,iscomm);   
		CAPS_MultiFileUploadController.getCaseTeamMembers(caseList[0].id);
		Case caseObj = new case();
		CAPS_MultiFileUploadController.getselectOptions(caseObj, 'Status');
		String classification;
		classification = CAPS_MultiFileUploadController.cAPSVclassification('Other Sensitive Information');
		System.assertEquals('3',classification);
		classification = CAPS_MultiFileUploadController.cAPSVclassification('Service Provider End User Information');
		System.assertEquals('1',classification);
		classification = CAPS_MultiFileUploadController.cAPSVclassification('Other Information');
		System.assertEquals('4',classification);
	}
	
	public testMethod static void CAPS_MultiFileinitiateUpload(){
		CH_Attachment__c chObj = new CH_Attachment__c();
		system.runAs(new User(Id = UserInfo.getUserId())){
			CAPS_TestDataUtil.createCustomSettingsData();
			List<Case> caseListQuery = new List<Case>();
			caseListQuery =  CAPS_TestDataUtil.createCaseRecord(1);
			Case caseList = caseListQuery[0];
			caseList.CH_SolutionType__c = null;
			caseList.Subject = 'Test';
			caseList.Type = 'Services_Project_Team';
			caseList.Status = 'New';
			caseList.Issue_Reported_By__c = UserInfo.getUserId();
			caseList.Category__c = 'General Issues';caseList.Description = 'test';
			insert caseList;
			
			Map<String,String> partNumVsEtagMap = new Map<String,String>();
			
			CAPS_UploadResponseWrapper wrapperFromJs = new CAPS_UploadResponseWrapper();
			wrapperFromJs.attachmentId = 'df330b2ea42b4e55b61f2647eb710f89';
			wrapperFromJs.s3keyname = 'df330b2ea42b4e55b61f2647eb710f89/test.txt';  
			wrapperFromJs.fileid = '411952';
			wrapperFromJs.signer = 'bdc7f90cef7345c984f9e34d25e0c192';
			wrapperFromJs.user = 'app_salesforce';
			wrapperFromJs.signtoken = '63823fceca9aeed2-842e632dcc8ae6348177520d00057bd975e949cccd4791fde62e28b494a5e386';
			wrapperFromJs.expiration = '1532757105';
			wrapperFromJs.permission = 'RW';
			wrapperFromJs.acl = 'private';
			wrapperFromJs.aws_url = 'https://s3.capsv.nokia.com/a848be61/us2';
			wrapperFromJs.bucket = 'capsvtest1';
			wrapperFromJs.aws_key = 'RZZVJKQRQUBLHMVWYTJ_';
			wrapperFromJs.uploadId = '2~ijxcVVOnMUT7dCtnf6WEvREyldaGng-';
			wrapperFromJs.partNumVsEtagMap = partNumVsEtagMap;
			String wrappertoSernd = JSON.serialize(wrapperFromJs);
			wrappertoSernd = wrappertoSernd.removestart('{');
			wrappertoSernd = '{"id":"Id",' +wrappertoSernd ;
			
			
			CAPS_MultiFileUploadWrapper wrapperFromJs1 = new CAPS_MultiFileUploadWrapper();
			wrapperFromJs1.attachmentId = 'df330b2ea42b4e55b61f2647eb710f89';
			wrapperFromJs1.s3keyname = 'df330b2ea42b4e55b61f2647eb710f89/test.txt';  
			wrapperFromJs1.fileid = '411952';
			wrapperFromJs1.signer = 'bdc7f90cef7345c984f9e34d25e0c192';
			wrapperFromJs1.user = 'app_salesforce';
			wrapperFromJs1.signtoken = '63823fceca9aeed2-842e632dcc8ae6348177520d00057bd975e949cccd4791fde62e28b494a5e386';
			wrapperFromJs1.expiration = '1532757105';
			wrapperFromJs1.permission = 'RW';
			wrapperFromJs1.acl = 'private';
			wrapperFromJs1.aws_url = 'https://s3.capsv.nokia.com/a848be61/us2';
			wrapperFromJs1.bucket = 'capsvtest1';
			wrapperFromJs1.aws_key = 'RZZVJKQRQUBLHMVWYTJ_';
			wrapperFromJs1.s3_region = 'us-east-1';
			wrapperFromJs1.aws_signature_version = '4';
			// wrapperFromJs1.uploadId = '2~ijxcVVOnMUT7dCtnf6WEvREyldaGng-';
			//wrapperFromJs1.partNumVsEtagMap = partNumVsEtagMap;
			String wrappertoSernd1 = JSON.serialize(wrapperFromJs1);
			wrappertoSernd1 = wrappertoSernd1.removestart('{');
			wrappertoSernd1 = '{"id":"Id",' +wrappertoSernd1 ;
			
			
			test.startTest();
			Test.setMock(HttpCalloutMock.class, new CAPS_UploadAttachMockHttpResponse());
			
			CAPS_MultiFileUploadWrapper wrap = CAPS_MultiFileUploadController.initiateUpload(caseList.Id,true,'test.txt','test','Other Information',5);
			System.assertEquals(CAPS_ConstantHandler.BASE_URL,wrap.baseURL );
			wrap = CAPS_MultiFileUploadController.parseAttachmentResponse(wrappertoSernd1 );
			System.assertEquals('app_salesforce',wrap.user );		 
			CAPS_MultiFileUploadController.getCaseInfo(caseList.Id);
			CAPS_MultiFileUploadController.uploadComplete('{"Name":[{"partNumber":1,"etag":"098f6bcd4621d373cade4e832627b4f6"}]}','2~ijxcVVOnMUT7dCtnf6WEvREyldaGng-',wrappertoSernd1,'test',5,caseList.id,false,'test desc','Other Information','71a7d5865d664c3694fffbe4919891b2%2Ftest.txt',false);
			test.stopTest();
		}
	}
	public testMethod static void CAPS_MultiFileuploadComplete(){
		CH_Attachment__c chObj = new CH_Attachment__c();
		system.runAs(new User(Id = UserInfo.getUserId())){
			
			CAPS_TestDataUtil.createCustomSettingsData();
			CAPS_TestDataUtil.createCustomSettingsData();
			List<Case> caseListQuery = new List<Case>();
			caseListQuery =  CAPS_TestDataUtil.createCaseRecord(1);
			Case caseList = caseListQuery[0];
			caseList.CH_SolutionType__c = null;
			caseList.Subject = 'Test';
			caseList.Type = 'Services_Project_Team';
			caseList.Status = 'New';
			caseList.Issue_Reported_By__c = UserInfo.getUserId();
			caseList.Category__c = 'General Issues';
			caseList.Description = 'test';
			insert caseList;
			
			Map<String,String> partNumVsEtagMap = new Map<String,String>();
			
			CAPS_UploadResponseWrapper wrapperFromJs = new CAPS_UploadResponseWrapper();
			wrapperFromJs.attachmentId = 'df330b2ea42b4e55b61f2647eb710f89';
			wrapperFromJs.s3keyname = 'df330b2ea42b4e55b61f2647eb710f89/test.txt';  
			wrapperFromJs.fileid = '411952';
			wrapperFromJs.signer = 'bdc7f90cef7345c984f9e34d25e0c192';
			wrapperFromJs.user = 'app_salesforce';
			wrapperFromJs.signtoken = '63823fceca9aeed2-842e632dcc8ae6348177520d00057bd975e949cccd4791fde62e28b494a5e386';
			wrapperFromJs.expiration = '1532757105';
			wrapperFromJs.permission = 'RW';
			wrapperFromJs.acl = 'private';
			wrapperFromJs.aws_url = 'https://s3.capsv.nokia.com/a848be61/us2';
			wrapperFromJs.bucket = 'capsvtest1';
			wrapperFromJs.aws_key = 'RZZVJKQRQUBLHMVWYTJ_';
			wrapperFromJs.uploadId = '2~ijxcVVOnMUT7dCtnf6WEvREyldaGng-';
			wrapperFromJs.partNumVsEtagMap = partNumVsEtagMap;
			String wrappertoSernd = JSON.serialize(wrapperFromJs);
			wrappertoSernd = wrappertoSernd.removestart('{');
			wrappertoSernd = '{"id":"Id",' +wrappertoSernd ;  
			
			CAPS_MultiFileUploadWrapper wrapperFromJs1 = new CAPS_MultiFileUploadWrapper();
			wrapperFromJs1.attachmentId = 'df330b2ea42b4e55b61f2647eb710f89';
			wrapperFromJs1.s3keyname = 'df330b2ea42b4e55b61f2647eb710f89/test.txt';  
			wrapperFromJs1.fileid = '411952';
			wrapperFromJs1.signer = 'bdc7f90cef7345c984f9e34d25e0c192';
			wrapperFromJs1.user = 'app_salesforce';
			wrapperFromJs1.signtoken = '63823fceca9aeed2-842e632dcc8ae6348177520d00057bd975e949cccd4791fde62e28b494a5e386';
			wrapperFromJs1.expiration = '1532757105';
			wrapperFromJs1.permission = 'RW';
			wrapperFromJs1.acl = 'private';
			wrapperFromJs1.aws_url = 'https://s3.capsv.nokia.com/a848be61/us2';
			wrapperFromJs1.bucket = 'capsvtest1';
			wrapperFromJs1.aws_key = 'RZZVJKQRQUBLHMVWYTJ_';
			wrapperFromJs1.s3_region = 'us-east-1';
			wrapperFromJs1.aws_signature_version = '4';
			// wrapperFromJs1.uploadId = '2~ijxcVVOnMUT7dCtnf6WEvREyldaGng-';
			//wrapperFromJs1.partNumVsEtagMap = partNumVsEtagMap;
			String wrappertoSernd1 = JSON.serialize(wrapperFromJs1);
			wrappertoSernd1 = wrappertoSernd1.removestart('{');
			wrappertoSernd1 = '{"id":"Id",' +wrappertoSernd1 ; 
			test.startTest();
			Test.setMock(HttpCalloutMock.class, new CAPS_UploadAttachMockHttpResponseV4());
			
			CAPS_MultiFileUploadWrapper wrap = CAPS_MultiFileUploadController.initiateUpload(caseList.Id,true,'test.txt','test','Other Information',5);
			System.assertEquals(CAPS_ConstantHandler.BASE_URL,wrap.baseURL );
			wrap = CAPS_MultiFileUploadController.parseAttachmentResponse(wrappertoSernd1);
			System.assertEquals('app_salesforce',wrap.user );		 
			CAPS_MultiFileUploadController.getCaseInfo(caseList.Id);
			CAPS_MultiFileUploadController.getCaseTeamMembers(caseList.Id);
			CAPS_MultiFileUploadController.uploadComplete('{"Name":[{"partNumber":1,"etag":"098f6bcd4621d373cade4e832627b4f6"}]}','2~ijxcVVOnMUT7dCtnf6WEvREyldaGng-',wrappertoSernd1,'test',5,caseList.id,false,'test desc','Other Information','71a7d5865d664c3694fffbe4919891b2%2Ftest.txt',false);
			test.stopTest();
		}
	} 

}