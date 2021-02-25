/****************************************
* Name : AgreementTriggerHelperTest
* Author : Accenture

*****************************************/
@isTest
public class AgreementTriggerHelperTest {
	public static testmethod void checkMandatoryFieldsTest(){
		
		Set<Id> accId = new Set<Id>();
		List<Account> accountCreation = TestDataFactory.createAccount(2);
		accountCreation[0].AccountNumber = '3011234';
		accountCreation[1].AccountNumber = '3011235';
		database.insert(accountCreation);
		accId.add(accountCreation[0].Id);
		accId.add(accountCreation[1].Id);
		Account acc = new Account();
		acc.Name='Legal Entinty Account For Test';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		acc.ParentId = accountCreation[0].Id;
		acc.AccountNumber = '100006843';
		database.insert(acc);
		   
		Account soldtopartyAcc =  TestDataFactory.createAccount(1)[0];
		//soldtopartyAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		database.insert(soldtopartyAcc);
		
		Id RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(CSWXGlobalConstant.directOppty).getRecordTypeId();
		//creating user
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		Opportunity oppty;
		insert userCreation;
		system.runAs(userCreation){
		oppty = TestDataFactory.OpportunityCreation(1,soldtopartyAcc)[0];
		oppty.StageName = CSWXGlobalConstant.DEVELOP_OPPTY;
		oppty.RecordTypeId=RecordTypeId;
		oppty.Lead_BG__c ='MN';
		oppty.Phase_Status__c = CSWXGlobalConstant.Opty_phase_Status;
		//insert new File_Sharing_Custom_Setting__c(Name = GlobalConstants.OPPORTUNITY_DOC_FREEZE_STAGE,Value__c='7');
		database.insert(oppty);
		}
		DS_Agreement_Validation__c aggobj = new DS_Agreement_Validation__c();
		aggobj.Name = 'ERP is P20';
		aggobj.ERP__c = 'P20';
		aggobj.Agreement_MandatoryFields__c = 'ERP__c,Apttus_CMConfig__PaymentTermId__c,Inco_Term_Description__c,Sold_to_party_number__c,Payer__c,Delivery_System__c,Sales_Org_Number__c,Sales_Office_Number__c,Sales_Group_Number__c,Dist_Channel__c';
		aggobj.Agreement_MandatoryFields2__c = 'Division__c,WBS_Number__c,Sales_Mode__c,Nokia_Legal_Entity__c,Apttus_CMConfig__PayoutFrequency__c,Apttus_CMConfig__BillToAccountId__c';
		aggobj.Agreement_MandatoryFields3__c = null;
		database.insert(aggobj);
		
		 DS_Agreement_Validation__c aggobj2 = new DS_Agreement_Validation__c();
		aggobj2.Name = 'ERP is P20';
		aggobj2.ERP__c = 'P20';
		aggobj2.Agreement_MandatoryFields__c = 'Apttus_CMConfig__PaymentTermId__c,Inco_Term_Description__c,Sold_to_party_number__c,Payer__c,Delivery_System__c,Sales_Org_Number__c,Sales_Office_Number__c,Sales_Group_Number__c,Dist_Channel__c';
		aggobj2.Agreement_MandatoryFields2__c = 'Division__c,WBS_Number__c,Sales_Mode__c,Nokia_Legal_Entity__c,Apttus_CMConfig__PayoutFrequency__c,Apttus_CMConfig__BillToAccountId__c';
		aggobj2.Agreement_MandatoryFields3__c = 'ERP__c';		
		database.insert(aggobj2);
		
		DS_Agreement_Validation__c aggobj1 = new DS_Agreement_Validation__c();
		aggobj1.Name = 'ERP is Blue Planet';
		aggobj1.ERP__c = 'Blue Planet';
		aggobj1.Agreement_MandatoryFields__c = 'ERP__c,Apttus_CMConfig__PaymentTermId__c,Inco_Term_Description__c,Sold_to_party_number__c,Payer__c,Delivery_System__c,WBS_Number__c,Sales_Mode__c,Nokia_Legal_Entity__c';
		aggobj1.Agreement_MandatoryFields2__c = 'Apttus_CMConfig__PayoutFrequency__c,Apttus_CMConfig__BillToAccountId__c';
		aggobj1.Agreement_MandatoryFields3__c = null;
		database.insert(aggobj1);
		
		/*DS_Agreement_Validation__c aggobj3 = new DS_Agreement_Validation__c();
		aggobj3.Name = 'ERP is Blue Planet';
		aggobj3.ERP__c = 'Blue Planet';
		aggobj3.Agreement_MandatoryFields__c = 'Apttus_CMConfig__PaymentTermId__c,Inco_Term_Description__c,Sold_to_party_number__c,Payer__c,Delivery_System__c,WBS_Number__c,Sales_Mode__c,Nokia_Legal_Entity__c';
		aggobj3.Agreement_MandatoryFields2__c = 'Apttus_CMConfig__PayoutFrequency__c,Apttus_CMConfig__BillToAccountId__c';
		aggobj3.Agreement_MandatoryFields3__c = 'ERP__c';
		database.insert(aggobj3); */
	  
		list<Apttus__APTS_Agreement__c> agreement= new list<Apttus__APTS_Agreement__c>();
		Apttus__APTS_Agreement__c agreementobj= new Apttus__APTS_Agreement__c();
		agreementobj.Name= 'New demo';
		agreementobj.Apttus__Account__c = soldtopartyAcc.id;
		agreementobj.CurrencyIsoCode = 'EUR';
		agreementobj.Delivery_System__c = 'Scratch Order via P20';
		agreementobj.ERP__c = 'P20';
		agreementobj.Sales_Mode__c = 'Corporate Sales Mode';
		agreementobj.Confidence_Level__c = 'Low Level';
		agreement.add(agreementobj);
		database.insert(agreement);
		
		list<Apttus__APTS_Agreement__c> agreement1 = new list<Apttus__APTS_Agreement__c>();
		Apttus__APTS_Agreement__c agreement1obj = new Apttus__APTS_Agreement__c();
		agreement1obj.Name= 'Final DEMO';
		agreement1obj.Apttus__Account__c = soldtopartyAcc.id;
		agreement1obj.CurrencyIsoCode = 'EUR';
		agreement1obj.Delivery_System__c = 'Scratch Order via P20';
		agreement1obj.ERP__c = 'Blue Planet';
		agreement1obj.Sales_Mode__c = 'Corporate Sales Mode';
		agreement1obj.Confidence_Level__c = 'High Level';
		agreement1.add(agreement1obj);
		//agreement.add(agreement1obj);
		database.insert(agreement1);
				
		Map<Id,Apttus__APTS_Agreement__c> oldrecords = new Map<Id,Apttus__APTS_Agreement__c>();
		oldrecords.put(agreement[0].id, agreement[0]);
		Map<Id,Apttus__APTS_Agreement__c> oldrecords1 = new Map<Id,Apttus__APTS_Agreement__c>();
		oldrecords1.put(agreement1[0].id, agreement1[0]);
	   
		Test.startTest();
		AgreementTriggerHelper.checkMandatoryFields(agreement);
		AgreementTriggerHelper.checkMandatoryFields(agreement1);
		AgreementTriggerHandler.checkMandatoryFields(agreement, oldrecords1);
		AgreementTriggerHandler.checkMandatoryFields(agreement1, oldrecords);
	 	AgreementTriggerHelper.checkMandatoryFields(null);
		AgreementTriggerHandler.checkMandatoryFields(null,null);
		AgreementTriggerHelper.getAgreementFieldsOnStatus();
		test.stopTest();
	} 
}