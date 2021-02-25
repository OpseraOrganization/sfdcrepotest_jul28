/****************************************
* Name : PSRO_Calculate_BG_CostTest 
* Author : Accenture
* Description : Test class for PSRO_Calculate_BG_Cost
*****************************************/
@istest
private class PSRO_Calculate_BG_CostTest
{
 private static List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
 private static Id oppIndirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.CREATE_INDIRECT_SALES_OPPORTUNITY).getRecordTypeId();
 private static List<Opportunity> preSalesOpportunity = new List<Opportunity>();
 private static final Id PSR_ReadOnlyRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.PRESALESRISKOPPORTUNITY_READONLY).getRecordTypeId();	
 private static final Id PSR_EditRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.PRESALESRISKOPPORTUNITY).getRecordTypeId();
 static NCP_CustomerCommunitySetting__c cs = new NCP_CustomerCommunitySetting__c();
	static testmethod void PSRO_Calculate_BG_CostTest() {
		 cs.Name = 'Default';
		cs.Customer_Account__c = 'Customer - test';
		cs.Customer_Account_Number__c = '12345';
		cs.Customer_User_Profile__c = 'Customers';
		insert cs;
		
		 test.startTest();
		Id recordType1,recordType2 ;
		
		List<PSRO_Market_Threshold__c> THList = new List<PSRO_Market_Threshold__c>();
		PSRO_Market_Threshold__c OpenVal = new PSRO_Market_Threshold__c();
		OpenVal.Market__c = 'Market India';
		OpenVal.Business_group__c = 'NSW';
		OpenVal.Threshold_Value__c = 2000000.00;
		OpenVal.Current_value__c = 10000.00;
		THList.add(OpenVal);
		PSRO_Market_Threshold__c OpenVal1 = new PSRO_Market_Threshold__c();
		OpenVal1.Market__c = 'Market India';
		OpenVal1.Business_group__c = 'MN';
		OpenVal1.Threshold_Value__c = 2000000.00;
		OpenVal1.Current_value__c = 10000.00;
		THList.add(OpenVal1);
		PSRO_Market_Threshold__c OpenVal2 = new PSRO_Market_Threshold__c();
		OpenVal2.Market__c = 'Market India';
		OpenVal2.Business_group__c = 'GS';
		OpenVal2.Threshold_Value__c = 200000.00;
		OpenVal2.Current_value__c = 10000.00;
		THList.add(OpenVal2);
		PSRO_Market_Threshold__c OpenVal3 = new PSRO_Market_Threshold__c();
		OpenVal3.Market__c = 'Market India';
		OpenVal3.Business_group__c = 'ION';
		OpenVal3.Threshold_Value__c = 200000.00;
		OpenVal3.Current_value__c = 10000.00;
		THList.add(OpenVal3);
		PSRO_Market_Threshold__c OpenVal4 = new PSRO_Market_Threshold__c();
		OpenVal4.Market__c = 'Market India';
		OpenVal4.Business_group__c = 'FN';
		OpenVal4.Threshold_Value__c = 200000.00;
		OpenVal4.Current_value__c = 10000.00;
		THList.add(OpenVal4);

		insert THList;
		 PSR_Gate_Classification_Logic__c psr1 = new PSR_Gate_Classification_Logic__c();
		psr1.name= '1';
		psr1.BG_Value__c= 'NSW';
		psr1.Gate_Classification__c= 'R1';
		psr1.Max_Value__c= 0;
		psr1.Min_Value__c= 200000;
		psr1.Opportunity_Sub_Type__c= 'Risk Order Only';
		psr1.Opportunity_Type__c= 'Risk Order';
		
		insert psr1;
		Map_Enterprise_MUs_and_Market__c MU = new Map_Enterprise_MUs_and_Market__c();
		MU.Enterprise_MU__c = 'BWTX Market Unit INDIA';
		MU.MArket__C = 'Market India';
		MU.NAme = 'Test';
		insert MU;
		//Creating User
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		system.runAs(userCreation){
			fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
			database.insert(fileSharingCustomSettingList);
			Sales_Role__c SR = NF_TestDataFactory.createSalesRole(usercreation,'NSNA_BGFPA','Market India','BG Finance PSRO Validator');
			SR.BG__c = 'NSW';
			insert SR;
			Account accountCreation = TestDataFactory.createAccount(1)[0];
			accountCreation.AccountNumber = '1234'; 
			accountcreation.L3Name__c = 'Nokia Enterprise';
			accountcreation.L4Name__c = 'Market India';
			accountcreation.L5Name__c = 'BWTX Market Unit INDIA';
			database.insert(accountCreation);
			Account sonAccount = TestDataFactory.createAccount(1)[0];
			sonAccount.AccountNumber = '1234';
			sonAccount.L4Name__c = 'Market India';
			sonAccount.ParentId = accountCreation.Id;
			sonAccount.Active__c = true;
			sonAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
			database.insert(sonAccount);
			//Creating Indirect-Oppty
			Opportunity optyCreation = TestDataFactory.OpportunityCreation(1,accountCreation)[0];			
			optyCreation.RecordTypeId= oppIndirectRecordTypeId ;
			optyCreation.Country__c = 'India';
			optyCreation.G3_Approval_Date__c = system.now();
			optyCreation.CurrencyIsoCode = 'USD';
			optyCreation.StageName = GlobalConstants.DEVELOP_OPPORTUNITY;
			optyCreation.Phase_Status__c = 'Opportunity in Progress';
			optyCreation.Legal_Entity__c = sonAccount.Id;
		 //   optyCreation.PSR_Lead_Business_Group__c ='NSW';
			OptyCreation.End_Customer_LE__c = sonAccount.Id;
			optyCreation.G2_Planned_Date__c = Date.today();
			optyCreation.G3_Planned_Date__c = Date.today();
			optyCreation.G4_Planned_Date__c = Date.today();
			optyCreation.G5_Planned_Date__c = Date.today();
			optyCreation.G4_Approval_Date__c = system.today();
		   // optyCreation.G6_Planned_Date__c = Date.today();
			database.insert(optyCreation);
			String oppId = optyCreation.Id;
			optyCreation = [select Id From Opportunity Where Id =: oppId limit 1];

			system.debug('optyCreationoptyCreationoptyCreation>>>>>>>>>>>>>>>>>>>>>>>>>'+optyCreation);
			//Creating Presales Oppty
			Opportunity preSalesTest = TestDataFactory.preSalesOpportunityCreation(2, accountCreation, optyCreation)[0];
			preSalesTest.PSR_Pre_Sales_Risk_Opportunity_Type__c = 'Risk Order';
			preSalesTest.PSR_Pre_Sales_Risk_Opportunity_Sub_Type__c = 'Risk Order Only';
			preSalesTest.CurrencyIsoCode = 'USD';
			preSalesTest.RecordTypeId= PSR_EditRecordTypeID ;
			preSalesTest.PSR_Cost_Business_Group_AA__c = 200;
			preSalesTest.PSR_Cost_Business_Group_FN__c = 2000;
			preSalesTest.PSR_Cost_Business_unit_ION_IPR__c = 300;
			preSalesTest.PSR_Cost_Business_Group_MN__c = 4000;
			preSalesTest.PSR_Cost_Business_Group_GS__c = 5000;
			database.insert(preSalesTest);
			Opportunity psro = [Select Id,PSR_Pre_Sales_Risk_Opportunity_Type__c,CurrencyIsoCode,PSR_Cost_Business_Group_AA__c,
							  PSR_Cost_Business_Group_FN__c,PSR_Pre_Sales_Risk_Opportunity_Sub_Type__c,G4_Approval_Date__c,Org_L4__c, Org_L3__c, Org_L5__c,PSR_Cost_Business_Group_ION__c,
							   PSR_Cost_Business_Group_MN__c,PSR_LoA_Level__c,PSR_Reference_Opportunity__c,recordTypeId,PSR_Cost_Business_Group_GS__c,PSR_Lead_Business_Group__c,PSR_Total_Cost_In_Euro__c
							   from opportunity where ID =:presalesTest.Id limit 1 ];
			List<PSR_Gate_Classification_Logic__c> objList = PSR_Gate_Classification_Logic__c.getall().values();
			//preSalesTest.RecordTypeId= PSR_ReadOnlyRecordTypeID ;
			system.debug('PSRO:>>>>'+psro);
			 preSalesTest.PSR_GateClass__c = psr1.Gate_Classification__c;

			Map<String,decimal> drate = new MAp<String, decimal>();
			drate.put('EUR', 1);
			drate.put('USD', 1.38);
			drate.put('INR', 5.38);
			Nokia_Financial_Calendar__c nokiaCalender = TestDataFactory.nokiaFinCalCreation(1)[0];
			nokiaCalender.Start_Date__c = System.today();
			nokiaCalender.End_Date__c = System.today();
			database.insert(nokiaCalender);
			Dated_Exchange_Rates__c exchangeRate = TestDataFactory.datedExchnageRateCreation(1)[0];
			database.insert(exchangeRate);
		 /*   Boolean Exceed = PSRO_Calculate_BG_Cost.returnexceed(psro,drate,OpenVal);
			Boolean Exceed1 = PSRO_Calculate_BG_Cost.returnexceed(psro,drate,OpenVal1);
			Boolean Exceed2 = PSRO_Calculate_BG_Cost.returnexceed(psro,drate,OpenVal2);
			Boolean Exceed3 = PSRO_Calculate_BG_Cost.returnexceed(psro,drate,OpenVal3);
			Boolean Exceed4 = PSRO_Calculate_BG_Cost.returnexceed(psro,drate,OpenVal4);*/
			PSRO_Calculate_BG_Cost.calculateLoAlevel(psro);
			PSRO_Calculate_BG_Cost.psroThresholdMail(THList);
			test.stopTest();

		}
	}
}