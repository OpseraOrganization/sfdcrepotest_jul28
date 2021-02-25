@istest
private class Batch_CalculateCurrentValueforPSROTest {
private static List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
 private static Id oppIndirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.CREATE_INDIRECT_SALES_OPPORTUNITY).getRecordTypeId();
 private static List<Opportunity> preSalesOpportunity = new List<Opportunity>();
 private static final Id PSR_ReadOnlyRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.PRESALESRISKOPPORTUNITY_READONLY).getRecordTypeId();	
 private static final Id PSR_EditRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.PRESALESRISKOPPORTUNITY).getRecordTypeId();
 static NCP_CustomerCommunitySetting__c cs = new NCP_CustomerCommunitySetting__c();
 static testmethod void Batch_CalculateTest() {
			 
		 
		Id recordType1,recordType2 ;
		
		List<PSRO_Market_Threshold__c> THList = new List<PSRO_Market_Threshold__c>();
		PSRO_Market_Threshold__c OpenVal = new PSRO_Market_Threshold__c();
		OpenVal.Market__c = 'Market India';
		OpenVal.Business_group__c = 'NSW';
		OpenVal.Threshold_Value__c = 20000.00;
		OpenVal.Current_value__c = 10000.00;
		OpenVal.value_exceeded__c = false;
		THList.add(OpenVal);
		PSRO_Market_Threshold__c OpenVal1 = new PSRO_Market_Threshold__c();
		OpenVal1.Market__c = 'Market India';
		OpenVal1.Business_group__c = 'MN';
		OpenVal1.Threshold_Value__c = 2000.00;
		OpenVal1.Current_value__c = 10000.00;
		OpenVal1.value_exceeded__c = true;
		THList.add(OpenVal1);
		PSRO_Market_Threshold__c OpenVal2 = new PSRO_Market_Threshold__c();
		OpenVal2.Market__c = 'Market India';
		OpenVal2.Business_group__c = 'GS';
		OpenVal2.Threshold_Value__c = 200000.00;
		OpenVal2.Current_value__c = 10000.00;
		OpenVal2.value_exceeded__c = false;
		THList.add(OpenVal2);
		PSRO_Market_Threshold__c OpenVal3 = new PSRO_Market_Threshold__c();
		OpenVal3.Market__c = 'Market India';
		OpenVal3.Business_group__c = 'ION';
		OpenVal3.Threshold_Value__c = 200000.00;
		OpenVal3.Current_value__c = 10000.00;
		OpenVal3.value_exceeded__c = false;
		THList.add(OpenVal3);
		PSRO_Market_Threshold__c OpenVal4 = new PSRO_Market_Threshold__c();
		OpenVal4.Market__c = 'Market India';
		OpenVal4.Business_group__c = 'FN';
		OpenVal4.Threshold_Value__c = 200000.00;
		OpenVal4.Current_value__c = 10000.00;
		OpenVal4.value_exceeded__c = false;
		THList.add(OpenVal4);
		PSRO_Market_Threshold__c OpenVal5 = new PSRO_Market_Threshold__c();
		OpenVal5.Market__c = 'Market India';
		OpenVal5.Business_group__c = 'NEN';
		OpenVal5.Threshold_Value__c = 200000.00;
		OpenVal5.Current_value__c = 10000.00;
		OpenVal5.value_exceeded__c = false;
		THList.add(OpenVal5);
		insert THList;

		Map_Enterprise_MUs_and_Market__c MU = new Map_Enterprise_MUs_and_Market__c();
		MU.Enterprise_MU__c = 'BWTX Market Unit INDIA';
		MU.MArket__C = 'Market India';
		MU.NAme = 'Test';
		insert MU;
		//Creating User
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		system.runAs(userCreation){

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
			OptyCreation.End_Customer_LE__c = sonAccount.Id;
			optyCreation.G2_Planned_Date__c = Date.today();
			optyCreation.G3_Planned_Date__c = Date.today();
			optyCreation.G4_Planned_Date__c = Date.today();
			optyCreation.G5_Planned_Date__c = Date.today();
			optyCreation.G4_Approval_Date__c = system.today();
		   // optyCreation.G6_Planned_Date__c = Date.today();
			database.insert(optyCreation);
			//Creating Presales Oppty
			Opportunity preSalesTest = TestDataFactory.preSalesOpportunityCreation(2, accountCreation, optyCreation)[0];
			preSalesTest.PSR_Pre_Sales_Risk_Opportunity_Type__c = 'Risk Order';
			preSalesTest.PSR_Pre_Sales_Risk_Opportunity_Sub_Type__c = 'Risk Order Only';
			preSalesTest.CurrencyIsoCode = 'USD';
			preSalesTest.RecordTypeId= PSR_EditRecordTypeID ;
			preSalesTest.PSR_Cost_Business_Group_AA__c = 40000;
			preSalesTest.PSR_Cost_Business_Group_FN__c = 2000;
			preSalesTest.PSR_Cost_Business_unit_ION_IPR__c = 300;
			preSalesTest.PSR_Cost_Business_Group_MN__c = 200;
			preSalesTest.PSR_Cost_BU_NE_DAaaS__c = 2300;
			preSalesTest.PSR_Sales_Value_Business_Group_AA__c = 1000;
			preSalesTest.PSR_Sales_Value_Business_Group_FN__c = 10;
			preSalesTest.PSR_Sales_Value_Business_Group_GS__c = 10;
			preSalesTest.PSR_Sales_Value_Business_Group_MN__c = 10;
			preSalesTest.PSR_Is_Cost_Reflected_In_Latest_Estimate__c = 'Yes';
			preSalesTest.PSR_Is_Rv_Reflected_In_Latest_Estimate__c = 'Yes';
			preSalesTest.PSR_Description_Justification__c = 'Test';
			presalesTest.NF_PRE_Tech_Field__c = 'Gate Submitted';
			//database.insert(preSalesTest);
			preSalesTest.StageName = 'Submitted For Approval';
			preSalesTest.RecordTypeId = PSR_ReadOnlyRecordTypeID;
			//Updating Presales Oppty
			//database.update(preSalesTest);
			system.debug('preSalesTest>>>>>>>>>>>>'+preSalesTest);
			preSalesTest.Apttus_Approval__Approval_Status__c = 'Approved';
			system.debug('preSalesTest>>>>>>>>>>'+preSalesTest);
			database.insert(preSalesTest);
			test.startTest();
			List<Opportunity> psro = [Select Id,PSR_Pre_Sales_Risk_Opportunity_Type__c,CurrencyIsoCode,PSR_Cost_Business_Group_AA__c,
							  PSR_Cost_Business_Group_FN__c,stagename,PSR_Pre_Sales_Risk_Opportunity_Sub_Type__c,G4_Approval_Date__c,Org_L4__c, Org_L3__c, Org_L5__c,PSR_Cost_Business_Group_ION__c,
							   PSR_Cost_Business_Group_MN__c,PSR_LoA_Level__c,PSR_Cost_BG_NEN__c,PSR_Reference_Opportunity__c,recordTypeId,PSR_Cost_Business_Group_GS__c,PSR_Lead_Business_Group__c,PSR_Total_Cost_In_Euro__c
							   from opportunity where ID =:presalesTest.Id limit 1 ];


			Nokia_Financial_Calendar__c nokiaCalender = TestDataFactory.nokiaFinCalCreation(1)[0];
			nokiaCalender.Start_Date__c = System.today();
			nokiaCalender.End_Date__c = System.today();
			database.insert(nokiaCalender);
			Dated_Exchange_Rates__c exchangeRate = TestDataFactory.datedExchnageRateCreation(1)[0];
			database.insert(exchangeRate);
			
		   
Batch_CalculateCurrentValueforPSRO batch= new Batch_CalculateCurrentValueforPSRO();
Database.BatchableContext BC;
SchedulableContext SC;  
batch.execute(sc);
batch.start(BC);
batch.execute(BC,psro);
 batch.finish(BC);
	 test.stopTest();	   
}
}
}