@isTest(seeAlldata=true)
/** 
 *  Author : Accenture 
 *  Description : Test Class for Controller class for SaaSUtility
 *  Created Date : 05\06\2015
 * 
 *  Version History :
 *  Date			  Changes 
 *  09\06\2015		created 
 *
 */
public class SaaSUtilityTest
{
	 static testMethod void validateSaaSUtility() 
	 {
		List<Question_Log__c> Quest = new List<Question_Log__c>();
		SaaSUtility ctrlObj = new SaaSUtility();
		SaaSUtility.getCreatableFieldsSOQL('', '');
		SaaSUtility.getRecordTypeID('Question_Log__c','SaaS_Delivery_Question_Log');
		SaaSUtility.displayErrMsg('Error');
		SaaSUtility.displaySuccessMsg('Success');
		SaaSUtility.isAccentureRepresentative();
		SaaSUtility.getURLParameter('key');
		SaaSUtility.deleteSobject(Quest);
		SaaSUtility.insertSobject(Quest);
	}	
	
	static testMethod void validateSaaSPageTemplateCtrl()
	{
		 SaaSPageTemplateCtrl  ctrlObj = new SaaSPageTemplateCtrl();
		 ctrlObj.getUserPhotoUrl();
		 ctrlObj.getDesginSessionOutcomes();
		 ctrlObj.getBuildSessionOutcomes();
		 ctrlObj.getInitiateSessionOutcomes();
	}
	
	
	static testMethod void validateSaaSPageMessage()
	{
		SaaSPageMessages.getMessages();
		SasSCustomPageMessages customMsg = new SasSCustomPageMessages();
		customMsg.getPageMessages();
		String s = customMsg.CustomPageMessages_ClosableErrorsRenderPlaceHolder;
	}
	static testMethod void validateDocumentDownload()
	{
		List<User> userList = new List<User>();
		userList = TestDataFactory.userCreation(1, 'System Administrator');
		database.insert(userList);
		System.runAs(userList[0]){			
			SaaSDocumentDownload ctrlObj = new SaaSDocumentDownload();
			List<Schema.Document> docObj = [SELECT DeveloperName FROM Document WHERE IsDeleted = false LIMIT 1];			
			String docID = docObj[0].DeveloperName;
			ctrlObj.docDeveloperName = docID;
			ctrlObj.getDocumentID();
			
			SaaSDocumentDownload ctrlObj2 = new SaaSDocumentDownload();
			ctrlObj2.docDeveloperName = Null;
			ctrlObj2.getDocumentID();			
		}
		
	}
	
}