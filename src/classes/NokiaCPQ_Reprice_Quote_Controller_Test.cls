/****************************************
 * Name : NokiaCPQ_Reprice_Quote_Controller_Test
 * Author : Accenture
 * Description : Test class for NokiaCPQ_Reprice_Quote_controller, ProcessLineItemBatch, RepriceAllQuotesBatch & lightning component.
 *****************************************/

@istest(SeeAllData=true)
public class NokiaCPQ_Reprice_Quote_Controller_Test {

	/***********************
	* Method Name: submitForRepriceTest
	* Description: To cover the method submitForReprice from class NokiaCPQ_Reprice_Quote_controller.
	* Parameters: NA
	************************/
	static testmethod void submitForRepriceTest(){
		test.startTest();
		//create a Account
		List<Account> accounts = NOKIA_CPQ_TestDataFactory.getAccounts(1);
		accounts[0].Acc_No__c = 'Test10';
		insert accounts;
		
		//create opportunity
		GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES = true;
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunities(1,accounts);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		insert opportunities;  
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = true;
		proposals[0].Reprice_In_Progress__c = false;
		insert proposals;
		
		system.debug('proposals[0].Id;--->'+proposals[0].Id);
		
		//get a Price List
		/*Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList = [SELECT ID, Name, PriceList_Type__c, Apttus_Config2__Active__c FROM Apttus_Config2__PriceList__c WHERE Name='Global Price List (EUR)' Limit 1];
		*/
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c(
			Name = 'Global Price List (EUR)', 
			Apttus_Config2__Active__c = True
		);
		insert priceList;
		
		// create a product configuration
		List<Apttus_Config2__ProductConfiguration__c> prodConfigs = NOKIA_CPQ_TestDataFactory.createProdConfig(1);
		prodConfigs[0].Apttus_Config2__PriceListId__c = priceList.Id;
		prodConfigs[0].Apttus_Config2__EffectivePriceListId__c = priceList.Id;
		prodConfigs[0].Apttus_Config2__AccountId__c = accounts[0].Id;
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c Limit 1];
			
		// create a Line Item
		List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;
		
		
		NokiaCPQ_Reprice_Quote_controller.submitForReprice(proposals[0].Apttus_Proposal__Opportunity__c);
		test.stopTest(); 
		
	}
	
	/***********************
	* Method Name: submitForRepriceTest2
	* Description: To cover the method submitForReprice from class NokiaCPQ_Reprice_Quote_controller such that validquoteList is empty.
	* Parameters: NA
	************************/
	static testmethod void submitForRepriceTest2(){
		test.startTest();
		//create a Account
		List<Account> accounts = NOKIA_CPQ_TestDataFactory.getAccounts(1);
		accounts[0].Acc_No__c = 'Test11';
		insert accounts;
		
		//create opportunity
		GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES = true;
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunities(1,accounts);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		insert opportunities;  
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		insert proposals;
		
		system.debug('proposals[0].Id;--->'+proposals[0].Id);
		
		//get a Price List
		/*Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList = [SELECT ID, Name, PriceList_Type__c, Apttus_Config2__Active__c FROM Apttus_Config2__PriceList__c WHERE Name='Global Price List (EUR)' Limit 1];
		*/
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c(
			Name = 'Global Price List (EUR)', 
			Apttus_Config2__Active__c = True
		);
		insert priceList;
		
		// create a product configuration
		List<Apttus_Config2__ProductConfiguration__c> prodConfigs = NOKIA_CPQ_TestDataFactory.createProdConfig(1);
		prodConfigs[0].Apttus_Config2__PriceListId__c = priceList.Id;
		prodConfigs[0].Apttus_Config2__EffectivePriceListId__c = priceList.Id;
		prodConfigs[0].Apttus_Config2__AccountId__c = accounts[0].Id;
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c Limit 1];
			
		// create a Line Item
		List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;
		
		NokiaCPQ_Reprice_Quote_controller newVar = new NokiaCPQ_Reprice_Quote_controller();
		NokiaCPQ_Reprice_Quote_controller.submitForReprice(proposals[0].Apttus_Proposal__Opportunity__c);
		test.stopTest(); 
		
	}
	
}