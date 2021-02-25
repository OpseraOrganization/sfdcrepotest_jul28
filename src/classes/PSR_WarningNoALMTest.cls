/**
 * @name	PSR_WarningNoALMTest
 * @author   
 * @since   Oct , 2017
 * @desc	This class helps create customized test data, used in test classes
 * @history 
 */
@isTest
private class PSR_WarningNoALMTest{
	private static List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
	static NCP_CustomerCommunitySetting__c cs = new NCP_CustomerCommunitySetting__c();

	static testMethod void opptyNoALMErrorMessageTestMethod() {
		
		cs.Name = 'Default';
		cs.Customer_Account__c = 'Customer - test';
		cs.Customer_Account_Number__c = '12345';
		cs.Customer_User_Profile__c = 'Customers';
		insert cs;

		test.startTest();
		//creating user
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		system.runAs(userCreation){
			fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
			database.insert(fileSharingCustomSettingList);
			
			//creating Account
			Account acc = TestDataFactory.createAccount(1)[0];
			//acc.AccountNumber = '1234';
			database.insert(acc);
			
			//insert opportunity
			Opportunity optyCreation = TestDataFactory.OpportunityCreation(1,acc)[0];			
			optyCreation.RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.CREATE_INDIRECT_SALES_OPPORTUNITY).getRecordTypeId();
			optyCreation.Country__c = 'India';
			optyCreation.G3_Approval_Date__c = system.now();
			optyCreation.StageName = GlobalConstants.DEVELOP_OPPORTUNITY;
			optyCreation.Phase_Status__c = 'Opportunity in Progress';
			database.insert(optyCreation);
			//changing oppty's stage Name and phase status
			optyCreation.Apttus_Approval__Approval_Status__c = 'Approved';
			optyCreation.StageName = GlobalConstants.DEVELOP_OPPORTUNITY;
			optyCreation.Phase_Status__c = 'Opportunity in Progress';
			database.update(optyCreation);
			system.debug('optyCreationoptyCreationoptyCreation>>>>>>>>>>>>>>>>>>>>>>>>>'+optyCreation);
			
			//Creating Presales Oppty
			List <Opportunity> preSalesTest = TestDataFactory.preSalesOpportunityCreation(1, acc, optyCreation);			
			preSalesTest[0].PSR_Pre_Sales_Risk_Opportunity_Type__c = 'Risk Order';
			preSalesTest[0].PSR_Pre_Sales_Risk_Opportunity_Sub_Type__c = 'Risk Order Only';
			preSalesTest[0].CurrencyIsoCode = 'USD';
			database.insert(preSalesTest);
			 
			//Updating Oppty with field required to chnage stage to 'Submitted for Approval'
			preSalesTest[0].PSR_Sales_Value_Business_Group_AA__c = 1000;
			preSalesTest[0].PSR_Sales_Value_Business_Group_FN__c = 10;
			preSalesTest[0].PSR_Sales_Value_Business_Group_GS__c = 10;
			preSalesTest[0].PSR_Sales_Value_Business_Group_MN__c = 10;
			preSalesTest[0].PSR_Cost_Business_Unit_ION_IPR__c = 10;
			preSalesTest[0].PSR_Cost_Business_Unit_ION_Optics__c = 11;
			preSalesTest[0].PSR_Cost_Business_Unit_ION_Video__c = 12;
			preSalesTest[0].PSR_Is_Cost_Reflected_In_Latest_Estimate__c = 'Yes';
			preSalesTest[0].PSR_Is_Rv_Reflected_In_Latest_Estimate__c = 'Yes';
			preSalesTest[0].PSR_Description_Justification__c = 'Test';

			presalesTest[0].NF_PRE_Tech_Field__c = 'Gate Submitted';
			database.update(preSalesTest);
			preSalesTest[0].StageName = 'Submitted For Approval';
			//Call method		   
			//PSR_WarningNoALM.opptyNoALMErrorMessage(preSalesTest[0].Id);			  
			
			PSR_WarningNoALM.opptyNoALMErrorMessage(acc.Id);
			PSR_WarningNoALM.opptyNoALMErrorMessage(preSalesTest[0].Id);
			PSR_WarningNoALM.opptyNoALMErrorMessage('123');
			
		test.stopTest();
		
	}
	}
}