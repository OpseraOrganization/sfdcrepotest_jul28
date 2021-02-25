/*******************************
Class Name:ProposalTriggerHelperTest
Created by: Accenture
Created Date: 06 April 2018
Last modified by: Accenture
Description: Test class for ProposalTriggerHelper
*******************************/
@istest
public class ProposalTriggerHelperTest {
	
	@testSetup 
	static void methodData() {
		list<user> userList = new list<user>();
	   /* User sysAdminUser = TestDataFactory.createSystemAdminUser();  
		usrList.add(sysAdminUser);
		User sysAdminUser2 = TestDataFactory.createSystemAdminUser(); 
		usrList.add(sysAdminUser2);*/
		userList = TestDataFactory.userCreation(2, 'System Administrator');
		//userList[0].NSA_Compliant__c = True;
		userList[0].Restriction_Level__c = 'Unrestricted';
		//userList[1].NSA_Compliant__c = True;
		userList[1].Restriction_Level__c = 'Unrestricted';
		insert userList; 
		/*File_Sharing_Custom_Setting__c fscs = new File_Sharing_Custom_Setting__c();
		fscs.name= 'Opportunity_SalesPhase_FinalStage';
		fscs.Value__c = 'Completed';
		insert fscs;
		
		
		//Create Account
		Account account = NF_TestDataFactory.createAccount('Test Account');
		account.L2Name__c = 'TestL2Name';
		List<Account> accounts=new List<Account>();
		accounts.add(account);
		insert accounts;
		QuoteWarningMessage.getQuoteId(accounts[0].Id);
		//Create Opportunity
		List<opportunity> opportunities = NF_TestDataFactory.getOpportunities(3,accounts);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunities[2].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunities[2].CurrencyIsoCode = 'USD';
		insert opportunities;
		
		Shipping_Location__c shipping_location = new Shipping_Location__c();
		shipping_location.Portfolio__c = 'IP Routing';
		shipping_location.Pricing_Cluster__c = 'Europe';
		insert shipping_location;*/
	}
	
	static testMethod void test_Proposaltrigger(){
		//List<Account> account_Obj  =  [SELECT Id,Name from Account];
		//List<Opportunity> opportunity_Obj  =  [SELECT Id from Opportunity];
		
		File_Sharing_Custom_Setting__c fscs = new File_Sharing_Custom_Setting__c();
		fscs.name= 'Opportunity_SalesPhase_FinalStage';
		fscs.Value__c = 'Completed';
		insert fscs;
		
		
		//Create Account
		Account account = NF_TestDataFactory.createAccount('Test Account');
		account.L2Name__c = 'TestL2Name';
		List<Account> account_Obj=new List<Account>();
		account_Obj.add(account);
		insert account_Obj;
		QuoteWarningMessage.getQuoteId(account_Obj[0].Id);
		//Create Opportunity
		List<opportunity> opportunity_Obj = NF_TestDataFactory.getOpportunities(3,account_Obj);
		opportunity_Obj[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunity_Obj[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].CurrencyIsoCode = 'USD';
		insert opportunity_Obj;
		
		/*List<Account> accounts1 = NOKIA_CPQ_TestDataFactory.getAccounts(1);
		accounts1[0].Acc_No__c = 'Testing1';
		accounts1[0].Partner_Program__c ='';
		accounts1[0].NokiaCPQ_Applicable_Price_Lists__c = 'Dummy Price List1';
		accounts1[0].Partner_Type__c = '';
		accounts1[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		insert accounts1;*/
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = account_Obj[0].Id;
		accreditations[1].partner__c = account_Obj[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		
		Apttus_Proposal__Proposal__c Quote_Obj = new Apttus_Proposal__Proposal__c(
			Apttus_Proposal__Proposal_Name__c = 'quote',Apttus_Proposal__Approval_Stage__c = 'Draft',
			Apttus_Proposal__Account__c = account_Obj[0].Id,
			Apttus_Proposal__Opportunity__c = opportunity_Obj[0].Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			//NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
			NokiaCPQ_SSP_Level__c = 'Unlimited',
			NokiaCPQ_SRS_Level__c = 'Unlimited',
			NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c = '1'
		);
		insert Quote_Obj;
		
		Apttus_Proposal__Proposal__c Quote_Obj1 = new Apttus_Proposal__Proposal__c(
			Apttus_Proposal__Proposal_Name__c = 'quote',Apttus_Proposal__Approval_Stage__c = 'Draft',
			Apttus_Proposal__Account__c = account_Obj[0].Id,
			Apttus_Proposal__Opportunity__c = opportunity_Obj[0].Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			//NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
			NokiaCPQ_SSP_Level__c = '',
			NokiaCPQ_SRS_Level__c = '',
			NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c = ''
		);
		insert Quote_Obj1;
		
		Shipping_Location__c shipping_location = new Shipping_Location__c();
		shipping_location.Portfolio__c = 'IP Routing';
		shipping_location.Pricing_Cluster__c = 'Europe';
		insert shipping_location;
		
		
		Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMapIndirect =new Map<Id, Apttus_Proposal__Proposal__c>();
		Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap=new Map<Id, Apttus_Proposal__Proposal__c>();
		Map<Id, Apttus_Proposal__Proposal__c> proposalOldTriggerMap=new Map<Id, Apttus_Proposal__Proposal__c>();
		proposalNewTriggerMap.put(Quote_Obj.Id,Quote_Obj);
		proposalOldTriggerMap.put(Quote_Obj.Id,Quote_Obj);
		proposalNewTriggerMapIndirect.put(Quote_Obj1.Id,Quote_Obj1);
		ProposalTriggerHelper.checkBlankFieldsValidation(proposalNewTriggerMap,proposalOldTriggerMap);
		ProposalTriggerHelper.updateDirectExchangeRate(NULL,NULL);
		ProposalTriggerHelper.sspsrsValueReturn('IP Routing','SSP');
		ProposalTriggerHelper.checkBlankFieldsValidation(proposalNewTriggerMapIndirect,proposalOldTriggerMap);
		
		ProposalTriggerHelper.customValidationOnDirectQickActions(proposalNewTriggerMap,proposalOldTriggerMap);
		List<Apttus_Proposal__Proposal__c> lt_quote=new List<Apttus_Proposal__Proposal__c>();
		lt_quote.add(Quote_Obj);
		ProposalTriggerHelper.updateExchangeRateFieldsOnBeforeInsert(lt_quote);
		ProposalTriggerHelper.updateExchangeRateFieldsOnBeforeInsert(null);
		test.stopTest();
	}
	
	
	static testMethod void test_insertServiceRecord(){
		//List<Account> account_Obj  =  [SELECT Id,Name, Acc_No__c from Account where Acc_No__c ='Test Account' Limit 1];
		//List<Opportunity> opportunity_Obj  =  [SELECT Id from Opportunity];
		
		File_Sharing_Custom_Setting__c fscs = new File_Sharing_Custom_Setting__c();
		fscs.name= 'Opportunity_SalesPhase_FinalStage';
		fscs.Value__c = 'Completed';
		insert fscs;
		
		
		//Create Account
		Account account = NF_TestDataFactory.createAccount('Test Account');
		account.L2Name__c = 'TestL2Name';
		List<Account> account_Obj=new List<Account>();
		account_Obj.add(account);
		insert account_Obj;
		QuoteWarningMessage.getQuoteId(account_Obj[0].Id);
		//Create Opportunity
		List<opportunity> opportunity_Obj = NF_TestDataFactory.getOpportunities(3,account_Obj);
		opportunity_Obj[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunity_Obj[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].CurrencyIsoCode = 'USD';
		insert opportunity_Obj;
		
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = account_Obj[0].Id;
		accreditations[1].partner__c = account_Obj[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//Create Proposal
		Apttus_Proposal__Proposal__c Quote_Obj = new Apttus_Proposal__Proposal__c(
			Apttus_Proposal__Proposal_Name__c = 'quote',
			Apttus_Proposal__Approval_Stage__c = 'Draft',
			Apttus_Proposal__Account__c = account_Obj[0].Id,
			Apttus_Proposal__Opportunity__c = opportunity_Obj[0].Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			//NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
			NokiaCPQ_SSP_Level__c = 'Unlimited',
			NokiaCPQ_SRS_Level__c = 'Unlimited',
			//NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing'
			//NokiaCPQ_No_of_Years__c = '1'
		);
		insert Quote_Obj;
		
		Quote_Obj.Apttus_Proposal__Proposal_Name__c= 'quote1';
		Quote_Obj.Apttus_Proposal__Approval_Stage__c = 'Approved';
		update Quote_Obj;
		test.stopTest();
	}
	static testMethod void test_Proposaltrigger1(){
		//List<Account> account_Obj  =  [SELECT Id,Name, Acc_No__c from Account where Acc_No__c ='Test Account' Limit 1];
		//List<Opportunity> opportunity_Obj  =  [SELECT Id from Opportunity];
		
		File_Sharing_Custom_Setting__c fscs = new File_Sharing_Custom_Setting__c();
		fscs.name= 'Opportunity_SalesPhase_FinalStage';
		fscs.Value__c = 'Completed';
		insert fscs;
		
		
		//Create Account
		Account account = NF_TestDataFactory.createAccount('Test Account');
		account.L2Name__c = 'TestL2Name';
		List<Account> account_Obj=new List<Account>();
		account_Obj.add(account);
		insert account_Obj;
		QuoteWarningMessage.getQuoteId(account_Obj[0].Id);
		//Create Opportunity
		List<opportunity> opportunity_Obj = NF_TestDataFactory.getOpportunities(3,account_Obj);
		opportunity_Obj[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunity_Obj[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].CurrencyIsoCode = 'USD';
		insert opportunity_Obj;
		
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = account_Obj[0].Id;
		accreditations[1].partner__c = account_Obj[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//Create Proposal
		Apttus_Proposal__Proposal__c Quote_Obj = new Apttus_Proposal__Proposal__c(
			Apttus_Proposal__Proposal_Name__c = 'quote',Apttus_Proposal__Approval_Stage__c = 'Approved',
			Apttus_Proposal__Account__c = account_Obj[0].Id,
			Apttus_Proposal__Opportunity__c = opportunity_Obj[0].Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			//NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			//NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			//NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
			NokiaCPQ_SSP_Level__c = 'Unlimited',
			NokiaCPQ_SRS_Level__c = 'Unlimited',
			NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c = '1',
			NokiaProductAccreditation__c = accreditations[0].Id
		);
		insert Quote_Obj;
		
		Shipping_Location__c shipping_location = new Shipping_Location__c();
		shipping_location.Portfolio__c = 'IP Routing';
		shipping_location.Pricing_Cluster__c = 'Europe';
		insert shipping_location;
		
		Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap=new Map<Id, Apttus_Proposal__Proposal__c>();
		Map<Id, Apttus_Proposal__Proposal__c> proposalOldTriggerMap=new Map<Id, Apttus_Proposal__Proposal__c>();
		proposalNewTriggerMap.put(Quote_Obj.Id,Quote_Obj);
		proposalOldTriggerMap.put(Quote_Obj.Id,Quote_Obj);
		ProposalTriggerHelper.checkBlankFieldsValidation(proposalNewTriggerMap,proposalOldTriggerMap);
		
		List<Apttus_Proposal__Proposal__c> lt_quote=new List<Apttus_Proposal__Proposal__c>();
		lt_quote.add(Quote_Obj);
		ProposalTriggerHelper.updateExchangeRateFieldsOnBeforeInsert(lt_quote);
		ProposalTriggerHelper.insertServiceRecord(NULL);
		ProposalTriggerHelper.InsertMaintenanceSSPandSRS(NULL);
		
		test.stopTest();
	}
	static testMethod void test_Proposaltrigger2(){
		//List<Account> account_Obj  =  [SELECT Id,Name, Acc_No__c from Account where Acc_No__c ='Test Account' Limit 1];
		//List<Opportunity> opportunity_Obj  =  [SELECT Id from Opportunity];
		
		File_Sharing_Custom_Setting__c fscs = new File_Sharing_Custom_Setting__c();
		fscs.name= 'Opportunity_SalesPhase_FinalStage';
		fscs.Value__c = 'Completed';
		insert fscs;
		
		
		//Create Account
		Account account = NF_TestDataFactory.createAccount('Test Account');
		account.L2Name__c = 'TestL2Name';
		List<Account> account_Obj=new List<Account>();
		account_Obj.add(account);
		insert account_Obj;
		QuoteWarningMessage.getQuoteId(account_Obj[0].Id);
		//Create Opportunity
		List<opportunity> opportunity_Obj = NF_TestDataFactory.getOpportunities(3,account_Obj);
		opportunity_Obj[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunity_Obj[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].CurrencyIsoCode = 'USD';
		insert opportunity_Obj;
		
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = account_Obj[0].Id;
		accreditations[1].partner__c = account_Obj[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//Create Proposal
		list<Apttus_Proposal__Proposal__c> QuoteList = new list<Apttus_Proposal__Proposal__c>();
		Apttus_Proposal__Proposal__c Quote_Obj = new Apttus_Proposal__Proposal__c(
			Apttus_Proposal__Proposal_Name__c = 'quote',Apttus_Proposal__Approval_Stage__c = 'Draft',
			Apttus_Proposal__Account__c = account_Obj[0].Id,
			Apttus_Proposal__Opportunity__c = opportunity_Obj[0].Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			//NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			//NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			//NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
			NokiaCPQ_SSP_Level__c = 'Unlimited',
			NokiaCPQ_SRS_Level__c = 'Unlimited',
			NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c = '1',
			NokiaProductAccreditation__c = accreditations[0].Id,
			NokiaCPQ_Is_Maintenance_Quote__c=false
		);
		QuoteList.add(Quote_Obj);
		Apttus_Proposal__Proposal__c Quote_Obj1 = new Apttus_Proposal__Proposal__c(
			Apttus_Proposal__Proposal_Name__c = 'quote',Apttus_Proposal__Approval_Stage__c = 'Draft',
			Apttus_Proposal__Account__c = account_Obj[0].Id,
			Apttus_Proposal__Opportunity__c = opportunity_Obj[0].Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			//NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			//NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			//NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
			NokiaCPQ_SSP_Level__c = 'Unlimited',
			NokiaCPQ_SRS_Level__c = 'Unlimited',
			//NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c = '1',
			NokiaProductAccreditation__c = accreditations[0].Id,
			NokiaCPQ_Is_Maintenance_Quote__c=false
		);
		QuoteList.add(Quote_Obj1);
		insert QuoteList;
		
		Shipping_Location__c shipping_location = new Shipping_Location__c();
		shipping_location.Portfolio__c = 'IP Routing';
		shipping_location.Pricing_Cluster__c = 'Europe';
		insert shipping_location;
		
		
		
		
		List<Product2 > prodList = NOKIA_CPQ_TestDataFactory.productCreationDirect(1);
		prodList[0].name = 'Comptel SRS';
		prodList[0].CurrencyIsoCode = 'USD';
		prodList[0].Business_Group__c='NSW';
		prodList[0].Family= 'A&A-CEM';
		prodList[0].Portfolio__c = 'IP Routing';
		prodList[0].ProductCode = 'COMP-1234';
		prodList[0].Apttus_Config2__ConfigurationType__c = 'Standalone';
		prodList[0].IsActive=True;
		prodList[0].RecordTypeId=Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Sales Product').getRecordTypeId();
		insert prodList;
		
		Apttus_Config2__PriceList__c pricelist=new Apttus_Config2__PriceList__c();
		
		// List<Apttus_Config2__PriceList__c> pricelist=[select Name,CurrencyIsoCode from Apttus_Config2__PriceList__c where Name='Global Price List (USD)' LIMIT 1];
		pricelist.Name='GPL';
		pricelist.Apttus_Config2__Active__c=true;
		pricelist.CurrencyIsoCode='USD';
		insert pricelist;
		//  pricelist.CurrencyIsoCode='EUR';
		//  update pricelist;
		
		Apttus_Config2__PriceListItem__c pli= new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c=pricelist.Id ,Apttus_Config2__ListPrice__c= 100.00, Apttus_Config2__ProductId__c=prodList[0].Id,Apttus_Config2__ChargeType__c='Product Price');
		insert pli;
		
		Optional_Services_Detail__c optionalservice = new Optional_Services_Detail__c(
			Accreditation_Level__c = 'Advanced',Portfolio__c = 'IP Routing',
			CurrencyIsoCode='USD',Product__c=prodList[0].Id);
		
		//  List<Optional_Services_Detail__c> osdetail =[SELECT Id,Product__r.Id,Product__r.ProductCode,Product__r.Description,Portfolio__c, NMS__c,Accreditation_Level__c from Optional_Services_Detail__c where Portfolio__c = 'IP Routing' LIMIT 1];
		
		
		insert optionalservice;
		
		
		Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap=new Map<Id, Apttus_Proposal__Proposal__c>();
		Map<Id, Apttus_Proposal__Proposal__c> proposalOldTriggerMap=new Map<Id, Apttus_Proposal__Proposal__c>();
		proposalNewTriggerMap.put(QuoteList[0].Id,QuoteList[0]);
		proposalOldTriggerMap.put(QuoteList[0].Id,QuoteList[0]);
		ProposalTriggerHelper.checkBlankFieldsValidation(proposalNewTriggerMap,proposalOldTriggerMap);
		ProposalTriggerHelper.updateRepriseOnMaintChange(proposalNewTriggerMap,proposalOldTriggerMap);
		List<Apttus_Proposal__Proposal__c> lt_quote=new List<Apttus_Proposal__Proposal__c>();
		lt_quote.add(QuoteList[0]);
		ProposalTriggerHelper.updateExchangeRateFieldsOnBeforeInsert(lt_quote);	 
		ProposalTriggerHelper.insertServiceRecord(lt_quote);
		/*
		Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap1=new Map<Id, Apttus_Proposal__Proposal__c>();
		Map<Id, Apttus_Proposal__Proposal__c> proposalOldTriggerMap1=new Map<Id, Apttus_Proposal__Proposal__c>();
		proposalNewTriggerMap.put(QuoteList[1].Id,QuoteList[1]);
		proposalOldTriggerMap.put(QuoteList[1].Id,QuoteList[1]);
		ProposalTriggerHelper.checkBlankFieldsValidation(proposalNewTriggerMap1,proposalOldTriggerMap1);
		ProposalTriggerHelper.updateRepriseOnMaintChange(proposalNewTriggerMap1,proposalOldTriggerMap1);
		List<Apttus_Proposal__Proposal__c> lt_quote1=new List<Apttus_Proposal__Proposal__c>();
		lt_quote.add(QuoteList[1]);
		ProposalTriggerHelper.updateExchangeRateFieldsOnBeforeInsert(lt_quote1);	 
		ProposalTriggerHelper.insertServiceRecord(lt_quote1);*/
		
		
		
		test.stopTest();
	}
	
	static testMethod void test_PriceList(){
		
		//List<Account> account_Obj  =  [SELECT Id,Name, Acc_No__c from Account where Acc_No__c ='Test Account' Limit 1];
		//List<Opportunity> opportunity_Obj  =  [SELECT Id from Opportunity];
		
		File_Sharing_Custom_Setting__c fscs = new File_Sharing_Custom_Setting__c();
		fscs.name= 'Opportunity_SalesPhase_FinalStage';
		fscs.Value__c = 'Completed';
		insert fscs;
		
		Shipping_Location__c shipping_location = new Shipping_Location__c();
		shipping_location.Portfolio__c = 'IP Routing';
		shipping_location.Pricing_Cluster__c = 'Europe';
		insert shipping_location;
		
		list<Apttus_Config2__PriceList__c> listPriceList = new list<Apttus_Config2__PriceList__c>();
		Apttus_Config2__PriceList__c pricelist=new Apttus_Config2__PriceList__c();
		pricelist.Name='GPL';
		pricelist.Apttus_Config2__Active__c=true;
		pricelist.PriceList_Type__c = 'CPQ';
		pricelist.Apttus_Config2__Active__c = TRUE;
		pricelist.CurrencyIsoCode='USD';
		//pricelist.Apttus_Config2__BasedOnPriceListId__c='a5t2100000099P2AAI';
		Apttus_Config2__PriceList__c pricelist1=new Apttus_Config2__PriceList__c();
		pricelist1.Name='Test1';
		pricelist1.Apttus_Config2__Active__c=true;
		pricelist1.PriceList_Type__c = 'Direct';
		pricelist1.Apttus_Config2__Active__c = TRUE;
		pricelist1.CurrencyIsoCode='USD';
		pricelist1.NokiaCPQ_Name__c = 'Dummy Price List2';
		listPriceList.add(pricelist1);   
		
		Apttus_Config2__PriceList__c pricelist2=new Apttus_Config2__PriceList__c();
		pricelist2.Name='Test2';
		pricelist2.Apttus_Config2__Active__c=true;
		pricelist2.PriceList_Type__c = 'Direct';
		pricelist2.Apttus_Config2__Active__c = TRUE;
		pricelist2.CurrencyIsoCode='USD';
		pricelist2.NokiaCPQ_Name__c = 'Smoke MN EUR Price List';
		listPriceList.add(pricelist2);  
		
		insert listPriceList;
		
		//Create Account
		Account account = NF_TestDataFactory.createAccount('Test Account');
		account.L2Name__c = 'TestL2Name';
		account.NokiaCPQ_Applicable_Price_Lists__c='Dummy Price List2, Smoke MN EUR Price List';
		List<Account> account_Obj=new List<Account>();
		account_Obj.add(account);
		insert account_Obj;
		QuoteWarningMessage.getQuoteId(account_Obj[0].Id);
		//Create Opportunity
		List<opportunity> opportunity_Obj = NF_TestDataFactory.getOpportunities(3,account_Obj);
		opportunity_Obj[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunity_Obj[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].CurrencyIsoCode = 'USD';
		insert opportunity_Obj;
		
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = account_Obj[0].Id;
		accreditations[1].partner__c = account_Obj[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		
		//Create Proposal
		list<Apttus_Proposal__Proposal__c> listProposal = new list<Apttus_Proposal__Proposal__c>();
		Apttus_Proposal__Proposal__c Quote_Obj = new Apttus_Proposal__Proposal__c(
			Apttus_Proposal__Proposal_Name__c = 'quote',Apttus_Proposal__Approval_Stage__c = 'Approved',
			Apttus_Proposal__Account__c = account_Obj[0].Id,
			Apttus_Proposal__Opportunity__c = opportunity_Obj[0].Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			//NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			//NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			//NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
			NokiaCPQ_SSP_Level__c = 'Unlimited',
			NokiaCPQ_SRS_Level__c = 'Unlimited',
			NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c = '1',
			CurrencyISOCode = 'USD',
			exchange_rate__c = 1.1147,
			NokiaProductAccreditation__c = accreditations[0].Id,
			NokiaCPQPricing_Cluster__c = 'Europe'
		);
		insert Quote_Obj;
		listProposal.add(Quote_Obj);
		
		//Create Proposal
		list<Apttus_Proposal__Proposal__c> listProposal1 = new list<Apttus_Proposal__Proposal__c>();
		Apttus_Proposal__Proposal__c Quote_Obj1 = new Apttus_Proposal__Proposal__c(
			Apttus_Proposal__Proposal_Name__c = 'quote',Apttus_Proposal__Approval_Stage__c = 'Draft',
			Apttus_Proposal__Account__c = account_Obj[0].Id,
			Apttus_Proposal__Opportunity__c = opportunity_Obj[0].Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today()+30,
			NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			//NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			//NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			//NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
			NokiaCPQ_SSP_Level__c = 'Unlimited',
			NokiaCPQ_SRS_Level__c = 'Unlimited',
			NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c = '2',
			CurrencyISOCode = 'USD',
			exchange_rate__c = 1.15327,
			NokiaProductAccreditation__c = accreditations[0].Id,
			NokiaCPQPricing_Cluster__c = 'Europe'
		);
		insert Quote_Obj1;
		listProposal1.add(Quote_Obj);
		
		//GlobalConstants.DIRECT_QUOTE_TYPE = 'Direct CPQ';
		
		
		List<CurrencyType> currencyObj = [select IsoCode, ConversionRate from CurrencyType];
		
		Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap2=new Map<Id, Apttus_Proposal__Proposal__c>();
		Map<Id, Apttus_Proposal__Proposal__c> proposaloldTriggerMap3=new Map<Id, Apttus_Proposal__Proposal__c>();
		proposalNewTriggerMap2.put(Quote_Obj1.id,Quote_Obj1);
		proposaloldTriggerMap3.put(Quote_Obj.id,Quote_Obj);
		ProposalTriggerHelper.updateDirectExchangeRate(proposalNewTriggerMap2,proposaloldTriggerMap3);
		ProposalTriggerHelper.associateDirectPriceList(listProposal);
		ProposalTriggerHelper.updateQuoteExpiryDate(listProposal);
		ProposalTriggerHelper.updateQuoteExpiryDate(NULL);
		ProposalTriggerHelper.updateQuoteRecordType(listProposal);
		ProposalTriggerHelper.updateContractNameOnQuote(listProposal);
		ProposalTriggerHelper.quoteStatusToValidate(listProposal);
		ProposalTriggerHelper.updateListPriceIONDirect(listProposal);
		ProposalTriggerHelper.updateIndirectOnOppChange(listProposal);
		//ProposalTriggerHelper.associateDirectPriceList(pricelist);
		test.stopTest();
	}
	
	static testMethod void testDirectQuote(){
		
		//List<Account> account_Obj  =  [SELECT Id,Name, Acc_No__c from Account where Acc_No__c ='Test Account' Limit 1];
		//List<Opportunity> opportunity_Obj  =  [SELECT Id from Opportunity];
		
		File_Sharing_Custom_Setting__c fscs = new File_Sharing_Custom_Setting__c();
		fscs.name= 'Opportunity_SalesPhase_FinalStage';
		fscs.Value__c = 'Completed';
		insert fscs;
		
		
		//Create Account
		Account account = NF_TestDataFactory.createAccount('Test Account');
		account.L2Name__c = 'TestL2Name';
		List<Account> account_Obj=new List<Account>();
		account_Obj.add(account);
		insert account_Obj;
		QuoteWarningMessage.getQuoteId(account_Obj[0].Id);
		//Create Opportunity
		List<opportunity> opportunity_Obj = NF_TestDataFactory.getOpportunities(3,account_Obj);
		opportunity_Obj[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunity_Obj[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].CurrencyIsoCode = 'USD';
		insert opportunity_Obj;
		
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = account_Obj[0].Id;
		accreditations[1].partner__c = account_Obj[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		
		//Create Proposal
		list<Apttus_Proposal__Proposal__c> listProposal = new list<Apttus_Proposal__Proposal__c>();
		Apttus_Proposal__Proposal__c Quote_Obj = new Apttus_Proposal__Proposal__c(
			RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),
			Apttus_Proposal__Proposal_Name__c = 'quote',Apttus_Proposal__Approval_Stage__c = 'Approved',
			Apttus_Proposal__Account__c = account_Obj[0].Id,
			Apttus_Proposal__Opportunity__c = opportunity_Obj[1].Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			//NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			//NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			//NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
			NokiaCPQ_SSP_Level__c = 'Unlimited',
			NokiaCPQ_SRS_Level__c = 'Unlimited',
			NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c = '1',
			CurrencyISOCode = 'USD',
			exchange_rate__c = 2,
			NokiaProductAccreditation__c = accreditations[0].Id
		);
		insert Quote_Obj;
		listProposal.add(Quote_Obj);
		
		//Create Proposal
		list<Apttus_Proposal__Proposal__c> listProposal1 = new list<Apttus_Proposal__Proposal__c>();
		Apttus_Proposal__Proposal__c Quote_Obj1 = new Apttus_Proposal__Proposal__c(
			RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote Read-Only').getRecordTypeId(),
			Apttus_Proposal__Proposal_Name__c = 'quote',Apttus_Proposal__Approval_Stage__c = 'Draft',
			Apttus_Proposal__Account__c = account_Obj[0].Id,
			Apttus_Proposal__Opportunity__c = opportunity_Obj[1].Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today()+30,
			NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			//NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			//NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			//NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
			NokiaCPQ_SSP_Level__c = 'Unlimited',
			NokiaCPQ_SRS_Level__c = 'Unlimited',
			NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c = '2',
			CurrencyISOCode = 'EUR',
			exchange_rate__c = 1.15327,
			NokiaProductAccreditation__c = accreditations[0].Id
		);
		insert Quote_Obj1;
		
		//GlobalConstants.DIRECT_QUOTE_TYPE = 'Direct CPQ';
		Apttus_Config2__PriceList__c pricelist=new Apttus_Config2__PriceList__c();
		pricelist.Name='GPL';
		pricelist.Apttus_Config2__Active__c=true;
		pricelist.PriceList_Type__c = 'CPQ';
		pricelist.Apttus_Config2__Active__c = TRUE;
		pricelist.CurrencyIsoCode='EUR';
		//pricelist.Apttus_Config2__BasedOnPriceListId__c='a5t2100000099P2AAI';
		insert pricelist;   
		
		List<CurrencyType> currencyObj = [select IsoCode, ConversionRate from CurrencyType];
		
		Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap2=new Map<Id, Apttus_Proposal__Proposal__c>();
		Map<Id, Apttus_Proposal__Proposal__c> proposaloldTriggerMap3=new Map<Id, Apttus_Proposal__Proposal__c>();
		proposalNewTriggerMap2.put(Quote_Obj1.id,Quote_Obj1);
		proposaloldTriggerMap3.put(Quote_Obj.id,Quote_Obj);
		ProposalTriggerHelper.updateDirectExchangeRate(proposalNewTriggerMap2,proposaloldTriggerMap3);
		ProposalTriggerHelper.associateDirectPriceList(listProposal);
		ProposalTriggerHelper.updateQuoteExpiryDate(listProposal);
		ProposalTriggerHelper.updateQuoteExpiryDate(NULL);
		ProposalTriggerHelper.updateQuoteRecordType(listProposal);
		ProposalTriggerHelper.updateContractNameOnQuote(listProposal);
		ProposalTriggerHelper.quoteStatusToValidate(listProposal);
		ProposalTriggerHelper.updateListPriceIONDirect(listProposal);
		ProposalTriggerHelper.updateIndirectOnOppChange(listProposal);
		test.stopTest();
	}
	
	static testMethod void testDirectQuote1(){
		
		//List<Account> account_Obj  =  [SELECT Id,Name, Acc_No__c from Account where Acc_No__c ='Test Account' Limit 1];
		//List<Opportunity> opportunity_Obj  =  [SELECT Id from Opportunity];
		
		File_Sharing_Custom_Setting__c fscs = new File_Sharing_Custom_Setting__c();
		fscs.name= 'Opportunity_SalesPhase_FinalStage';
		fscs.Value__c = 'Completed';
		insert fscs;
		
		
		//Create Account
		Account account = NF_TestDataFactory.createAccount('Test Account');
		account.L2Name__c = 'TestL2Name';
		List<Account> account_Obj=new List<Account>();
		account_Obj.add(account);
		insert account_Obj;
		QuoteWarningMessage.getQuoteId(account_Obj[0].Id);
		//Create Opportunity
		List<opportunity> opportunity_Obj = NF_TestDataFactory.getOpportunities(3,account_Obj);
		opportunity_Obj[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunity_Obj[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].CurrencyIsoCode = 'USD';
		insert opportunity_Obj;
		
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = account_Obj[0].Id;
		accreditations[1].partner__c = account_Obj[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		
		//Create Proposal
		list<Apttus_Proposal__Proposal__c> listProposal = new list<Apttus_Proposal__Proposal__c>();
		Apttus_Proposal__Proposal__c Quote_Obj = new Apttus_Proposal__Proposal__c(
			RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),
			Apttus_Proposal__Proposal_Name__c = 'quote',Apttus_Proposal__Approval_Stage__c = 'Approved',
			Apttus_Proposal__Account__c = account_Obj[0].Id,
			Apttus_Proposal__Opportunity__c = opportunity_Obj[2].Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			//NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			//NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			//NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
			NokiaCPQ_SSP_Level__c = 'Unlimited',
			NokiaCPQ_SRS_Level__c = 'Unlimited',
			NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c = '1',
			CurrencyISOCode = 'USD',
			exchange_rate__c = 1.1147,
			NokiaProductAccreditation__c = accreditations[0].Id
		);
		insert Quote_Obj;
		listProposal.add(Quote_Obj);
		
		//Create Proposal
		list<Apttus_Proposal__Proposal__c> listProposal1 = new list<Apttus_Proposal__Proposal__c>();
		Apttus_Proposal__Proposal__c Quote_Obj1 = new Apttus_Proposal__Proposal__c(
			RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote Read-Only').getRecordTypeId(),
			Apttus_Proposal__Proposal_Name__c = 'quote',Apttus_Proposal__Approval_Stage__c = 'Draft',
			Apttus_Proposal__Account__c = account_Obj[0].Id,
			Apttus_Proposal__Opportunity__c = opportunity_Obj[2].Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today()+30,
			NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			//NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			//NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			//NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
			NokiaCPQ_SSP_Level__c = 'Unlimited',
			NokiaCPQ_SRS_Level__c = 'Unlimited',
			NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c = '2',
			CurrencyISOCode = 'USD',
			exchange_rate__c = 1.15327,
			NokiaProductAccreditation__c = accreditations[0].Id
		);
		insert Quote_Obj1;
		
		//GlobalConstants.DIRECT_QUOTE_TYPE = 'Direct CPQ';
		Apttus_Config2__PriceList__c pricelist=new Apttus_Config2__PriceList__c();
		pricelist.Name='GPL';
		pricelist.Apttus_Config2__Active__c=true;
		pricelist.PriceList_Type__c = 'CPQ';
		pricelist.Apttus_Config2__Active__c = TRUE;
		pricelist.CurrencyIsoCode='USD';
		//pricelist.Apttus_Config2__BasedOnPriceListId__c='a5t2100000099P2AAI';
		insert pricelist;   
		
		List<CurrencyType> currencyObj = [select IsoCode, ConversionRate from CurrencyType];
		
		Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap2=new Map<Id, Apttus_Proposal__Proposal__c>();
		Map<Id, Apttus_Proposal__Proposal__c> proposaloldTriggerMap3=new Map<Id, Apttus_Proposal__Proposal__c>();
		proposalNewTriggerMap2.put(Quote_Obj1.id,Quote_Obj1);
		proposaloldTriggerMap3.put(Quote_Obj.id,Quote_Obj);
		ProposalTriggerHelper.updateDirectExchangeRate(proposalNewTriggerMap2,proposaloldTriggerMap3);
		ProposalTriggerHelper.associateDirectPriceList(listProposal);
		ProposalTriggerHelper.updateQuoteExpiryDate(listProposal);
		ProposalTriggerHelper.updateQuoteExpiryDate(NULL);
		ProposalTriggerHelper.updateQuoteRecordType(listProposal);
		ProposalTriggerHelper.updateContractNameOnQuote(listProposal);
		ProposalTriggerHelper.quoteStatusToValidate(listProposal);
		ProposalTriggerHelper.updateListPriceIONDirect(listProposal);
		ProposalTriggerHelper.updateIndirectOnOppChange(listProposal);
		test.stopTest();
	}
	
	
	
	 
	/*static testmethod void ProposalTriggerhelperTestNew(){
		List<Account> accounts1 = NOKIA_CPQ_TestDataFactory.getAccounts(1);
		accounts1[0].Acc_No__c = 'Testing New2';
		accounts1[0].Partner_Program__c ='';
		accounts1[0].NokiaCPQ_Applicable_Price_Lists__c = 'Dummy Price List1';
		accounts1[0].Partner_Type__c = '';
		accounts1[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		insert accounts1;
		 List<opportunity> opportunities = NF_TestDataFactory.getOpportunities(1,accounts1);
		 opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		 insert opportunities;
		list<Apttus_Proposal__Proposal__c> propList = new list<Apttus_Proposal__Proposal__c>();
		Apttus_Proposal__Proposal__c proposals = new Apttus_Proposal__Proposal__c(
		Apttus_Proposal__Account__c = accounts1[0].Id,
		Apttus_Proposal__Opportunity__c = opportunities[0].Id,
	   NokiaCPQ_Needs_Reprice__c = false,
		Reprice_In_Progress__c = false,
		NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
		 //NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
		//NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
		//NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
		 NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
		 NokiaCPQ_SSP_Level__c = 'Unlimited',
		NokiaCPQ_SRS_Level__c = 'Unlimited',
		 Apttus_Proposal__Approval_Stage__c = 'Approved',
		NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
		 NokiaCPQ_Portfolio__c = 'IP Routing',
		 NokiaCPQ_No_of_Years__c = '2'
			);
		insert proposals;
		propList.add(proposals);
		list<Apttus_Proposal__Proposal__c> propList1 = new list<Apttus_Proposal__Proposal__c>();
		Apttus_Proposal__Proposal__c proposals1 = new Apttus_Proposal__Proposal__c(
		Apttus_Proposal__Account__c = accounts1[0].Id,
		Apttus_Proposal__Opportunity__c = opportunities[0].Id,
	   NokiaCPQ_Needs_Reprice__c = false,
		Reprice_In_Progress__c = false,
		NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
		 //NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
		//NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
		//NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
		 NokiaCPQ_Capture_Cancel_Recall_Action__c='Test1',
		 NokiaCPQ_SSP_Level__c = 'Unlimited',
		NokiaCPQ_SRS_Level__c = 'Unlimited',
		 Apttus_Proposal__Approval_Stage__c = 'Draft',
		NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
		 NokiaCPQ_Portfolio__c = 'IP Routing',
		 NokiaCPQ_No_of_Years__c = '1'
			);
		insert proposals1;
		propList1.add(proposals1);
		Map<Id, Apttus_Proposal__Proposal__c> proposalTriggerMap = new Map<Id, Apttus_Proposal__Proposal__c>();
		proposalTriggerMap.put(propList[0].id,proposals);
		Map<Id, Apttus_Proposal__Proposal__c> proposalTriggerMap2 = new Map<Id, Apttus_Proposal__Proposal__c>();
		proposalTriggerMap2.put(propList1[0].id,proposals1);
		ProposalTriggerHelper.customValidationOnDirectQickActions(proposalTriggerMap,proposalTriggerMap2);
	}*/
	 static testMethod void test_Proposaltrigger10(){	   
		File_Sharing_Custom_Setting__c fscs = new File_Sharing_Custom_Setting__c();
		fscs.name= 'Opportunity_SalesPhase_FinalStage';
		fscs.Value__c = 'Completed';
		insert fscs;
		
		 List<User> userList = new List<User>();  
 Sales_Role__c sr = new Sales_Role__c();
  
 
 
		//Create Account
		Account account = NF_TestDataFactory.createAccount('Test Account');
		account.L2Name__c = 'Nokia Networks';
		List<Account> account_Obj=new List<Account>();
		account_Obj.add(account);
		insert account_Obj;
		QuoteWarningMessage.getQuoteId(account_Obj[0].Id);
		//Create Opportunity
		List<opportunity> opportunity_Obj = NF_TestDataFactory.getOpportunities(3,account_Obj);
		opportunity_Obj[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunity_Obj[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunity_Obj[2].CurrencyIsoCode = 'USD';
		 //opportunity_Obj[0].Org_L3__c = 'Nokia Networks';
		insert opportunity_Obj;
		
		
		userList = TestDataFactory.userCreation(1, 'System Administrator');
 userList[0].NSA_Compliant__c = True;
 userList[0].Restriction_Level__c = 'Unrestricted';
 Database.insert(userList);  
		System.runAs(userList[0]){
  sr.First_Name__c = 'Holger1';
  sr.Last_Name__c ='Streckert';
  sr.Organisation__c = 'Nokia Networks';
  sr.Role_Code__c ='NSND_PrMBG';
  sr.Role_Name__c	='5 - BG Pricing Manager';

  sr.BG__c = 'FN';
  sr.User__c = userList[0].Id;
  Database.insert(sr);   
		
		OpportunityTeamMember opt = new OpportunityTeamMember();
		opt.UserId = userList[0].Id;
		opt.OpportunityId = opportunity_Obj[0].Id;
		opt.TeamMemberRole = 'Pricing Manager';
		Database.insert(opt);  
		
		
		
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = account_Obj[0].Id;
		accreditations[1].partner__c = account_Obj[0].Id;
		//accreditations[0].Portfolio__c = 'Fixed Access - POL';
		//accreditations[1].Portfolio__c = 'Fixed Access - POL';
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//Create Proposal
		Apttus_Proposal__Proposal__c Quote_Obj = new Apttus_Proposal__Proposal__c(
			Apttus_Proposal__Proposal_Name__c = 'quote',Apttus_Proposal__Approval_Stage__c = 'Approved',
			Apttus_Proposal__Account__c = account_Obj[0].Id,
			Apttus_Proposal__Opportunity__c = opportunity_Obj[0].Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			//NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			//NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			//NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_Capture_Cancel_Recall_Action__c='Test',
			NokiaCPQ_SSP_Level__c = 'Unlimited',
			NokiaCPQ_SRS_Level__c = 'Unlimited',
			NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c = '1',
			NokiaCPQ_Is_Maintenance_Quote__c=true,
			Warranty_credit__c = 'No',
			NokiaCPQ_Contract_Start_Date__c = System.today(),
			NokiaProductAccreditation__c = accreditations[0].Id
		);
		insert Quote_Obj;
		
		Shipping_Location__c shipping_location = new Shipping_Location__c();
		shipping_location.Portfolio__c = 'IP Routing';
		shipping_location.Pricing_Cluster__c = 'Europe';
		insert shipping_location;
		
		Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap=new Map<Id, Apttus_Proposal__Proposal__c>();
		Map<Id, Apttus_Proposal__Proposal__c> proposalOldTriggerMap=new Map<Id, Apttus_Proposal__Proposal__c>();
		proposalNewTriggerMap.put(Quote_Obj.Id,Quote_Obj);
		proposalOldTriggerMap.put(Quote_Obj.Id,Quote_Obj);
		ProposalTriggerHelper.checkBlankFieldsValidation(proposalNewTriggerMap,proposalOldTriggerMap);
		
		List<Apttus_Proposal__Proposal__c> lt_quote=new List<Apttus_Proposal__Proposal__c>();
		lt_quote.add(Quote_Obj);
		ProposalTriggerHelper.updateExchangeRateFieldsOnBeforeInsert(lt_quote);
		ProposalTriggerHelper.insertServiceRecord(NULL);
		ProposalTriggerHelper.InsertMaintenanceSSPandSRS(NULL);
		
		test.stopTest();
	}
	
 }
}