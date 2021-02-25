@isTest(SeeAllData = true)
public class ProposalTriggerHandlerTest 
{
static testMethod void ProposalTriggerHandlerTestIndirect() {
		//create account
		List<Account> accounts = NOKIA_CPQ_TestDataFactory.getAccounts(1);
		insert accounts;
		List<Account> accounts1 = NOKIA_CPQ_TestDataFactory.getAccounts(1);
		accounts1[0].Acc_No__c = 'Testing1';
		accounts1[0].Partner_Program__c ='';
		accounts1[0].Partner_Type__c = '';
		accounts1[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		insert accounts1;

		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations; 
		
		//Create Opportunity
		List<opportunity> opportunities1 = NOKIA_CPQ_TestDataFactory.getOpportunities(1,accounts);
		opportunities1[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunities1[0].End_Customer_LE__c = accounts1[0].Id;
		insert opportunities1;
		
		//Create Product
		List<Product2> prods = new List<Product2>();
		Product2 prod1 = new product2(
			Name = 'Test1', 
			ProductCode = '123', 
			Business_Group__c = 'MN', 
			CurrencyIsoCode = 'USD',
			IsActive = false,
			NokiaCPQ_Item_Type__c='Software',
			Apttus_Config2__ConfigurationType__c='Bundle'
			
		); 
		prods.add(prod1);
		
	Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
			Name = 'Commercial Price List', 
			Apttus_Config2__Active__c = True
		);
		insert ApttusTestPriceList;
		
		//create price list items
		List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
		Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__ListPrice__c = 100, 
			Apttus_Config2__ProductId__c = prod1.Id, 
			Apttus_Config2__ChargeType__c = 'Standard Price'
		);
		//insert pLI1;
		plistItems.add(pLI1);
		 test.startTest();
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities1[0].Id;	  
		proposals[0].NokiaCPQ_Portfolio__c = 'IP Routing'; //MN airscale wifi portfolio
		proposals[0].Apttus_Proposal__Approval_Stage__c = 'Draft';
		//proposals[0].RecordTypeId =Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Indirect Quote').getRecordTypeId();
		 insert proposals;	  
	
	 List<Apttus_Proposal__Proposal__c > proposals1 = NOKIA_CPQ_TestDataFactory.createProposal(1);
	 
		proposals1[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals1[0].Apttus_Proposal__Opportunity__c = opportunities1[0].Id;	  
		proposals1[0].NokiaCPQ_Portfolio__c = 'IP Routing'; //MN airscale wifi portfolio
		proposals1[0].Apttus_Proposal__Approval_Stage__c = 'Approved';
		
		insert proposals1;		
	   
		//create product configuration
		Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c(
			Name = 'APTTUS Test Config', 
			Apttus_Config2__AccountId__c = accounts[0].Id, 
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
			Apttus_QPConfig__Proposald__c = proposals[0].Id, 
			Apttus_Config2__Status__c = 'New', 
			Apttus_Config2__VersionNumber__c = 1, 
			Apttus_Config2__EffectivePriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__BusinessObjectId__c = String.valueOf(proposals[0].Id),
			Apttus_Config2__BusinessObjectType__c = 'Proposal'
		);
		insert ProdConfig;
		
		//Create Line Items
		list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = prod1.Id,
			Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			is_Custom_Product__c=false,
			NokiaCPQ_Spare__c=true,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
		   
			
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		//insert LineItem2;
		allLineItems.add(LineItem1);
		Apttus_Config2__LineItem__c LineItem2 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = prod1.Id,
			Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 100.00,
			Apttus_Config2__ListPrice__c = 200,
			Apttus_Config2__Quantity__c = 1,
			NokiaCPQ_Spare__c=true,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
		   
			
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		//insert LineItem1;
		allLineItems.add(LineItem2);
		Apttus_Config2__LineItem__c LineItem3 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = prod1.Id,
			Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			NokiaCPQ_Spare__c=true,
			Apttus_Config2__ListPrice__c = 300,
			Apttus_Config2__Quantity__c = 1,
		   
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			
			
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		//insert LineItem1;
		allLineItems.add(LineItem3);
		
		Apttus_Config2__LineItem__c LineItem4 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Maintenance Y1', 
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = prod1.Id,
			Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			NokiaCPQ_Spare__c=true,
			Apttus_Config2__ListPrice__c = 120,
			Apttus_Config2__Quantity__c = 1,
		   
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			
			
			Apttus_Config2__AddedBy__c = 'added by code'	 
		);
		//insert LineItem1;
		allLineItems.add(LineItem4);
		  Apttus_Config2__LineItem__c LineItem5 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = prod1.Id,
			Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			NokiaCPQ_Spare__c=true,
			Apttus_Config2__ListPrice__c = 300,
			Apttus_Config2__Quantity__c = 1,
		   
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			
			
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		//insert LineItem1;
		allLineItems.add(LineItem5);
		Apttus_Config2__LineItem__c LineItem6 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			Apttus_Config2__LineType__c = 'Option',
			Apttus_Config2__ProductId__c = prod1.Id,
			Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 300,
			Apttus_Config2__Quantity__c = 1,
			
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			
			
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		//insert LineItem1;
		allLineItems.add(LineItem6);
		
list<Apttus_Config2__LineItem__c> testAllLineItems1 = new List<Apttus_Config2__LineItem__c>();
		Apttus_Config2__LineItem__c testLineItem11 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			Apttus_Config2__LineType__c = 'Option',
			Apttus_Config2__ProductId__c = prod1.Id,
			Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
		   
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			
			
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		
		testAllLineItems1.add(testLineItem11);
		insert testAllLineItems1;
		
		//Create summary Group
		//
		list<Apttus_Config2__SummaryGroup__c> allSummarygrps = new List<Apttus_Config2__SummaryGroup__c>();
		Apttus_Config2__SummaryGroup__c allSummarygrp1 =new Apttus_Config2__SummaryGroup__c(
			Name = 'Configurable Products',
			Apttus_Config2__LineNumber__c = 1,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__ConfigurationId__c = ProdConfig.Id ,
			Apttus_Config2__ExtendedPrice__c = 600,
			Apttus_Config2__Description__c = 'Total (One Time) (One Time)',
			Apttus_Config2__AdjustmentAmount__c = 100,
			Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__Frequency__c = 'One Time'
			
		);
		allSummarygrps.add(allSummarygrp1);
		Apttus_Config2__SummaryGroup__c allSummarygrp2 =new Apttus_Config2__SummaryGroup__c(
			Name = 'Configurable Products',
			Apttus_Config2__LineNumber__c = 2,
			Apttus_Config2__ItemSequence__c = 2,
			Apttus_Config2__ConfigurationId__c = ProdConfig.Id ,
			Apttus_Config2__ExtendedPrice__c = 120,
			Apttus_Config2__Description__c = 'Maintenance Y1 (One Time) (One Time)',
			Apttus_Config2__AdjustmentAmount__c = 80,
			Apttus_Config2__ChargeType__c = 'Maintenance Y1',
			Apttus_Config2__Frequency__c = 'One Time'
			
		);
		
		allSummarygrps.add(allSummarygrp2);
		 
		 Apttus_Config2__SummaryGroup__c allSummarygrp4 =new Apttus_Config2__SummaryGroup__c(
			Name = 'Subtotal - Standard Price (One Time)',
			Apttus_Config2__LineNumber__c = 1,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__ConfigurationId__c = ProdConfig.Id ,
			Apttus_Config2__ExtendedPrice__c = 600,
			Apttus_Config2__Description__c = 'Subtotal - Standard Price (One Time) - Standard Price (One Time)',
			Apttus_Config2__AdjustmentAmount__c = 100,
			Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__Frequency__c = 'One Time'
			
		);
		allSummarygrps.add(allSummarygrp4);
		insert allSummarygrps;
		  ProposalTriggerHandler pt=new ProposalTriggerHandler();
	test.stopTest();
	}
	
	 static testmethod void Direct1(){
	   
	  //create a Account
	   
		List<Account> accounts = NOKIA_CPQ_TestDataFactory.getAccounts(2);
		accounts[1].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		accounts[1].AccountNumber='';
		accounts[1].Partner_Type__c = '';
	accounts[1].Partner_Program__c = '';
		insert accounts;
		
		List<Account> acclist = new List<Account>();
		acclist.add(accounts[0]);
		
		//create opportunity
		GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES = true;
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunitieswithoutG6(1,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		insert opportunities;
		 
		opportunities[0].stageName = 'Win the Case (Negotiate)';
		opportunities[0].Phase_Status__c = 'Submitted for G5 Approval';
		opportunities[0].No_Loa__c = true;
		opportunities[0].LOA_Level__c = 'Loa';
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';  
		update opportunities; 
	  
		
	  
		// List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposalDirect(2);
	  //  proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
	   // proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
	   // proposals[0].NokiaCPQ_Needs_Reprice__c = false;
	  //  proposals[0].Reprice_In_Progress__c = false;
	  //  proposals[0].RecordTypeId = '01241000001coFv'; //direct quote
	   // proposals[0].Apttus_Proposal__Approval_Stage__c = 'In Review';
		//	insert proposals;			   
	   // proposals[0].Apttus_Proposal__Approval_Stage__c = Nokia_CPQ_Constants.QUOTEAPPROVED;	
	  
	   // update proposals;  
		Apttus_Proposal__Proposal__c proposals = new Apttus_Proposal__Proposal__c();
		proposals.Apttus_Proposal__Proposal_Name__c='test proposal';
		proposals.Apttus_Proposal__Account__c = accounts[0].Id;
		proposals.Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals.NokiaCPQ_Needs_Reprice__c = false;
		proposals.Reprice_In_Progress__c = false;
		proposals.RecordTypeId = '01241000001coFv'; //direct quote
		proposals.Apttus_Proposal__Approval_Stage__c = 'In Review';
		proposals.NokiaCPQ_Portfolio__c = 'Nokia Software';
		 //	 test.startTest();
		insert proposals; 
		  proposals.Apttus_Proposal__Approval_Stage__c = 'Approved';
		 update proposals;
		//get a Price List
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList.Name='Global Price List (EUR)';
		priceList.CurrencyIsoCode='GBP';
		priceList.Apttus_Config2__Active__c=true;
		priceList.PriceList_Type__c='CPQ';
		priceList.Apttus_Config2__Type__c='Standard';
		
		insert priceList;
		   
			  // create a product configuration
		List<Apttus_Config2__ProductConfiguration__c> prodConfigs = NOKIA_CPQ_TestDataFactory.createProdConfig(1);
		prodConfigs[0].Apttus_Config2__PriceListId__c = priceList.Id;
		prodConfigs[0].Apttus_Config2__EffectivePriceListId__c = priceList.Id;
		prodConfigs[0].Apttus_Config2__AccountId__c = accounts[0].Id;
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals.Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		prodConfigs[0].Apttus_Config2__BusinessObjectType__c = 'Proposal';
		insert prodConfigs;
		
		//get a IP Routing Product
   /*	  Product2 productInst = new Product2();
		productInst = [select Business_Group__c,Id,ProductCode from Product2 where name = 'Smart Plan Suite (SPS)' AND NokiaCPQ_State__c != null];
		
		 productInst.NokiaCPQ_Item_Type__c='Hardware';
		 productInst.NokiaCPQ_Classification2__c='Base';
		  productInst.Apttus_Config2__ConfigurationType__c='Bundle';
	  update productInst; */
	
	   List<Product2> prods1 = [select Business_Group__c,Id,ProductCode from Product2 where name = 'Smart Plan Suite (SPS)' ];
		// create a Line Item
		List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = prods1[0].Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		  test.startTest();
		insert lineItems;			

		
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = prods1[0].id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals.id;
		insert proposalLineItemList;
	   
	  
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals.id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
				
		test.stopTest();
		  
	   //  ProposalTriggerHandler pt=new ProposalTriggerHandler();
		
	 ProposalTriggerHandler.handleBeforeInsertTrigger(null);
	 ProposalTriggerHandler.createServiceRecord(null,null);
	 ProposalTriggerHandler.afterUpdateCPQTrigger(null,null);
	 ProposalTriggerHandler.afterInsertCPQTrigger(null);
	 }
	
   
	
}