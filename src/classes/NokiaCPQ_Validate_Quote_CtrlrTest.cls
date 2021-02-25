@isTest(SeeAllData=true)
public class NokiaCPQ_Validate_Quote_CtrlrTest{
	/***********************
	* Method Name: validateQuoteController_InitTest1
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTest1(){
		List<User> PartnerUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'Non-Sales User Profile');
		insert PartnerUser;
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
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunities(1,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		opportunities[0].StageName='Create Offer (Bid)';
		opportunities[0].Phase_Status__c='Submitted for G4 Approval';
		opportunities[0].LOA_Level__c = '';
		opportunities[0].No_Loa__c = false;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		insert opportunities;
		 List<OpportunityTeamMember> opportunityTeamMemberList = new List<OpportunityTeamMember>();
		opportunityTeamMemberList = TestDataFactory.optyTeamMemberCreation(2, PartnerUser[0],opportunities[0]);
		insert opportunityTeamMemberList;
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		 system.runAs(PartnerUser[0]){
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = true;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		//get a Price List
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList.Name='Global Price List (EUR)';
		priceList.CurrencyIsoCode='GBP';
		priceList.Apttus_Config2__Active__c=false;
		priceList.PriceList_Type__c='CPQ';
		priceList.Apttus_Config2__Type__c='Standard';
		
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
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
			 
		   list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest(); 
		 }
	}
	
	 
	
	
	/***********************
	* Method Name: validateQuoteController_InitTest3
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTest2(){
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
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunities(1,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		insert opportunities;  
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		//get a Price List
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList.Name='Global Price List (EUR)';
		priceList.CurrencyIsoCode='GBP';
		priceList.Apttus_Config2__Active__c=false;
		priceList.PriceList_Type__c='CPQ';
		priceList.Apttus_Config2__Type__c='Standard';
		
		insert priceList;
		
		// create a product configuration
		List<Apttus_Config2__ProductConfiguration__c> prodConfigs = NOKIA_CPQ_TestDataFactory.createProdConfig(1);
		prodConfigs[0].Apttus_Config2__PriceListId__c = priceList.Id;
		prodConfigs[0].Apttus_Config2__EffectivePriceListId__c = priceList.Id;
		prodConfigs[0].Apttus_Config2__AccountId__c = accounts[0].Id;
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		insert prodConfigs;
		 prodConfigs[0].Apttus_Config2__Status__c ='New';
		update prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
	  /*  List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest(); 
		
	}
	  /***********************
	* Method Name: validateQuoteController_InitTest1
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr ; proposals[0].NokiaCPQ_Needs_Reprice__c = true;
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTest20(){
		  List<User> PartnerUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'Non-Sales User Profile');
		insert PartnerUser;
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
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunities(1,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		 
		opportunities[0].stageName = GlobalConstants.IDENTIFY_OPPORTUNITY;
		opportunities[0].Phase_Status__c = GlobalConstants.SUBMITTED_FOR_G2_APPROVAL;
		opportunities[0].No_Loa__c = false;
		opportunities[0].LOA_Level__c = '';
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		insert opportunities; 
		 List<OpportunityTeamMember> opportunityTeamMemberList = new List<OpportunityTeamMember>();
		opportunityTeamMemberList = TestDataFactory.optyTeamMemberCreation(3, PartnerUser[0],opportunities[0]);
		insert opportunityTeamMemberList;
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		 system.runAs(PartnerUser[0])
		 {
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, IsActive, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
		
		productInst.IsActive = false;
		productInst.Apttus_Config2__ConfigurationType__c = 'option';
		update productInst;
		
		
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		
		insert lineItems;*/
			 
			  list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		proposalLineItemList[0].Apttus_QPConfig__LineType__c = 'option';
		insert proposalLineItemList;
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].Id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest();  
		 }		  
		
	}
	 static testmethod void validateQuoteController_InitTest19(){
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
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunities(1,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		insert opportunities;  
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id,Apttus_Config2__Version__c, NAME, IsActive, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
		productInst.Apttus_Config2__Version__c = 2;
		 update productInst;
		
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		 
		  list<Apttus_Config2__LineItem__c> LineItemList1 = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem2 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList1.add(LineItem2);
		
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		insert proposalLineItemList;
		productInst.Apttus_Config2__Version__c = 3;
		update productInst;
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].Id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest();  
				
		
	}

	  /***********************
	* Method Name: validateQuoteController_InitTest5
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr ;else if(Lineitemlist1.size() > 0 && flag == 1)
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTest7(){
		User sysAdminUser = TestDataFactory.createSystemAdminUser();   
	// System.runAs(sysAdminUser){
		//create Account
		List<Account>accounts=NOKIA_CPQ_TestDataFactory.getAccounts(2);
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
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		insert opportunities; 

		opportunities[0].stageName = 'Create Offer (bid)';
		opportunities[0].Phase_Status__c = 'Submitted for G4 Approval';
		opportunities[0].LOA_Level__c = 'A';
		opportunities[0].No_Loa__c = true;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		update opportunities; 
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, IsActive, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c,NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
		
		productInst.IsActive = true;
		update productInst;
		
		
		// create a Line Item
	  /*  List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		insert proposalLineItemList;
	   
	  
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].Id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest();	  
		
	 }
	 
	 /***********************
	* Method Name: validateQuoteController_InitTest5
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr ;else if(Lineitemlist1.size() > 0 && flag == 1)
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTest8(){
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
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		insert opportunities; 
		opportunities[0].stageName = GlobalConstants.WIN_THE_CASE_NEGOTIATE;
		opportunities[0].Phase_Status__c = GlobalConstants.PENDING_WIN_LOSS_DECLARATION;
		opportunities[0].LOA_Level__c = '';
		opportunities[0].No_Loa__c = true;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		update opportunities; 
		
		
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, IsActive, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
		
		productInst.IsActive = true;
		update productInst;
		
		
		// create a Line Item
		/*List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		insert proposalLineItemList;
		 proposalLineItemList[0].Apttus_QPConfig__LineType__c=Nokia_CPQ_Constants.lin_Apttus_QPConfig_if_else;
		update proposalLineItemList;
	   
	  
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].Id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest();	  
		 
	}
  
		/***********************
	* Method Name: validateQuoteController_InitTest1
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr ;If condition for productConfig.Apttus_Config2__Status__c != 'Finalized'
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTest3(){
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
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		 opportunities[0].stageName = 'Win the Case (Negotiate)';
		opportunities[0].Phase_Status__c = 'Pending Win/Loss Declaration';
		insert opportunities;  
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c =  opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c,NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId', opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest(); 
		
	}
	 /***********************
	* Method Name: validateQuoteController_InitTest1
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr ;If condition for productConfig.Apttus_Config2__Status__c != 'Finalized'
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTest31Indirect(){
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
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		 opportunities[0].StageName = GlobalConstants.WIN_THE_CASE_NEGOTIATE;
		opportunities[0].Phase_Status__c =GlobalConstants.SUBMITTED_FOR_G5_APPROVAL ;
		 opportunities[0].LOA_Level__c='';
		opportunities[0].No_Loa__c = true;
		insert opportunities;  
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c =  opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c,NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId', opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest(); 
		
	}
		 /***********************
	* Method Name: validateQuoteController_InitTest1
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr ;If condition for productConfig.Apttus_Config2__Status__c != 'Finalized'
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTest30Indirect(){
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
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		 opportunities[0].stageName = GlobalConstants.IDENTIFY_OPPORTUNITY;
		opportunities[0].Phase_Status__c =GlobalConstants.SUBMITTED_FOR_G2_APPROVAL ;
		insert opportunities;  
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c =  opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c,NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId', opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest(); 
		
	}
	   
	  
	  //************************************************ For Direct
   static testmethod void validateQuoteController_InitTest21Direct(){
	   /* List<User> PartnerUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'Partner Profile');
		insert PartnerUser;*/
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
		opportunities[0].stageName = 'Create Offer (Bid)';
		opportunities[0].Phase_Status__c = 'Submitted for G4 Approval';
	   // opportunities[0].LOA_Level__c = 'A';
		opportunities[0].No_Loa__c = false;
		opportunities[0].LOA_Level__c = '';
	   // opportunities[0].No_Loa__c = false;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
	  
		update opportunities; 
	   /* List<OpportunityTeamMember> opportunityTeamMemberList = new List<OpportunityTeamMember>();
		opportunityTeamMemberList = TestDataFactory.optyTeamMemberCreation(2, PartnerUser[0],opportunities[0]);
		insert opportunityTeamMemberList;*/
		// List<OpportunityTeamMember> optyTeamList= new List<OpportunityTeamMember>();
	  /*  for (integer i = 0; i < size; i++){
			OpportunityTeamMember optyTeamMember = new OpportunityTeamMember();
			optyTeamMember.TeamMemberRole = 'Bid Manager';
			optyTeamMember.UserId = PartnerUser[0].id;
			optyTeamMember.OpportunityId = opportunities[0].id;
			optyTeamMember.OpportunityAccessLevel = 'Edit';
			optyTeamList.add(optyTeamMember);
		}*/
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		  List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposalDirect(1);
	   proposals[0].RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId();  
	   // system.runAs(PartnerUser[0])
		{
		//create a quote
			system.debug('Accnt' + accounts[0].Id + opportunities[0].Id);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = true;
		proposals[0].Reprice_In_Progress__c = false;
		proposals[0].NokiaCPQ_Portfolio__c = 'Airscale Wifi';
		proposals[0].NokiaCPQ_Maintenance_Type__c = 'MN GS TSS Enhanced';
		insert proposals;		
			system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, IsActive, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
		
		//productInst.IsActive = true;
	//  update productInst;
		
		
		// create a Line Item
	  /*  List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
			
		list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		insert proposalLineItemList;
	   
	  
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].Id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest();
		
		}
		
   } 
   
	 //************************************************ For Direct
   static testmethod void validateQuoteController_InitTest22Direct(){
	   /* List<User> PartnerUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'Partner Profile');
		insert PartnerUser;*/
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
		opportunities[0].stageName = 'Identify Opportunity';
		opportunities[0].Phase_Status__c = 'Submitted for G2 Approval';
	   // opportunities[0].LOA_Level__c = 'A';
		opportunities[0].No_Loa__c = false;
		opportunities[0].LOA_Level__c = '';
	   // opportunities[0].No_Loa__c = false;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
	  
		update opportunities; 
	  
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		  List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposalDirect(1);
	   // system.runAs(PartnerUser[0])
		{
		//create a quote
			system.debug('Accnt' + accounts[0].Id + opportunities[0].Id);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		proposals[0].RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(); 
		proposals[0].NokiaCPQ_Portfolio__c = 'Airscale Wifi';
		proposals[0].NokiaCPQ_Maintenance_Type__c = 'MN GS TSS Enhanced';
		insert proposals;		
			system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, IsActive, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
		
		//productInst.IsActive = true;
	//  update productInst;
		
		
	/*	// create a Line Item
		List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		insert proposalLineItemList;
	   
	  
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].Id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest();
		
		}  
   }
	 //************************************************ For Direct
   static testmethod void validateQuoteController_InitTest23Direct(){
	   /* List<User> PartnerUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'Partner Profile');
		insert PartnerUser;*/
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
		opportunities[0].stageName = 'Create Offer (Bid)';
		opportunities[0].Phase_Status__c = 'Submitted for G4 Approval';
	   // opportunities[0].LOA_Level__c = 'A';
		opportunities[0].No_Loa__c = false;
		opportunities[0].LOA_Level__c = '';
	   // opportunities[0].No_Loa__c = false;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
	  
		update opportunities; 
	  
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		  List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposalDirect(1);
	   // system.runAs(PartnerUser[0])
		{
		//create a quote
			system.debug('Accnt' + accounts[0].Id + opportunities[0].Id);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		proposals[0].RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(); 
		proposals[0].NokiaCPQ_Portfolio__c = 'Airscale Wifi';
		proposals[0].NokiaCPQ_Maintenance_Type__c = 'MN GS TSS Enhanced';
		insert proposals;		
			system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, IsActive, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
		
		//productInst.IsActive = true;
	//  update productInst;
		
		
	/*	// create a Line Item
		List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		insert proposalLineItemList;
	   
	  
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].Id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest();
		
		}  
   }
	 //************************************************ For Direct
   static testmethod void validateQuoteController_InitTest24Direct(){
	   /* List<User> PartnerUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'Partner Profile');
		insert PartnerUser;*/
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
	   // opportunities[0].LOA_Level__c = 'A';
		opportunities[0].No_Loa__c = true;
		opportunities[0].LOA_Level__c = 'Loa';
	   // opportunities[0].No_Loa__c = false;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
	  
		update opportunities; 
	  
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		  List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposalDirect(1);
	   // system.runAs(PartnerUser[0])
		{
		//create a quote
			system.debug('Accnt' + accounts[0].Id + opportunities[0].Id);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		proposals[0].RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId();
		proposals[0].NokiaCPQ_Portfolio__c = 'Airscale Wifi';
		proposals[0].NokiaCPQ_Maintenance_Type__c = 'MN GS TSS Enhanced';
		insert proposals;		
			system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, IsActive, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
		
		//productInst.IsActive = true;
	//  update productInst;
		
		
	/*	// create a Line Item
		List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
			list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		insert proposalLineItemList;
	   
	  
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].Id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest();
		
		}  
   }
	//************************************************ For Direct
   static testmethod void validateQuoteController_InitTest25Direct(){
	   /* List<User> PartnerUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'Partner Profile');
		insert PartnerUser;*/
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
		opportunities[0].stageName = 'Identify Opportunity';
		opportunities[0].Phase_Status__c = 'Submitted for G2 Approval';
	   // opportunities[0].LOA_Level__c = 'A';
		opportunities[0].No_Loa__c = false;
		opportunities[0].LOA_Level__c = '';
	   // opportunities[0].No_Loa__c = false;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Draft';
	  
		update opportunities; 
	  
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		  List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposalDirect(1);
	   // system.runAs(PartnerUser[0])
		{
		//create a quote
			system.debug('Accnt' + accounts[0].Id + opportunities[0].Id);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		proposals[0].RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId();
		proposals[0].NokiaCPQ_Portfolio__c = 'Airscale Wifi';
		proposals[0].NokiaCPQ_Maintenance_Type__c = 'MN GS TSS Enhanced';
		insert proposals;		
			system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, IsActive, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
		
		//productInst.IsActive = true;
	//  update productInst;
		
		
	/*	// create a Line Item
		List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
			
			list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		insert proposalLineItemList;
	   
	  
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].Id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest();
		
		}  
   }
	//************************************************ For Direct
   static testmethod void validateQuoteController_InitTest26Direct(){
	   /* List<User> PartnerUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'Partner Profile');
		insert PartnerUser;*/
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
		opportunities[0].stageName =GlobalConstants.CREATE_OFFER;
		opportunities[0].Phase_Status__c = GlobalConstants.SUBMITTED_FOR_G4_APPROVAL;
	   // opportunities[0].LOA_Level__c = 'A';
		opportunities[0].No_Loa__c = true;
	  //  opportunities[0].LOA_Level__c = '';
	   // opportunities[0].No_Loa__c = false;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		
		update opportunities; 
	  
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		  List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposalDirect(1);
	   // system.runAs(PartnerUser[0])
		{
		//create a quote
			system.debug('Accnt' + accounts[0].Id + opportunities[0].Id);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		proposals[0].RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId();
		proposals[0].NokiaCPQ_Portfolio__c = 'Airscale Wifi';
		proposals[0].NokiaCPQ_Maintenance_Type__c = 'MN GS TSS Enhanced';
		insert proposals;
			  proposals[0].Apttus_Proposal__Approval_Stage__c='In Review';
			update proposals;
			system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, IsActive, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
		
		//productInst.IsActive = true;
	//  update productInst;
		
		
	/*	// create a Line Item
		List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		
			list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		insert proposalLineItemList;
	   
	  
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].Id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		   
			objControllerClass.currentBatchStatus();
		 objControllerClass.cancel();   
		test.stopTest();
	
		}  
   }
	//************************************************ For Direct
   static testmethod void validateQuoteController_InitTest27Direct(){
	   /* List<User> PartnerUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'Partner Profile');
		insert PartnerUser;*/
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
		opportunities[0].stageName =GlobalConstants.CREATE_OFFER;
		opportunities[0].Phase_Status__c = GlobalConstants.SUBMITTED_FOR_G4_APPROVAL;
		opportunities[0].LOA_Level__c = 'C';
		opportunities[0].No_Loa__c = true;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		
		update opportunities; 
	   
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposalDirect(1);
	   // system.runAs(PartnerUser[0])
		{
		//create a quote
			system.debug('Accnt' + accounts[0].Id + opportunities[0].Id);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		proposals[0].RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId();
		proposals[0].NokiaCPQ_Portfolio__c = 'Airscale Wifi';
		proposals[0].NokiaCPQ_Maintenance_Type__c = 'MN GS TSS Enhanced';
		 insert proposals;
			
		  
			  proposals[0].Apttus_Proposal__Approval_Stage__c='In Review';
			update proposals;
			system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, IsActive, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
		
		//productInst.IsActive = true;
	//  update productInst;
		
		
	/*	// create a Line Item
		List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
			list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		insert proposalLineItemList;
	   
	  
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Grand Total'
		);
		insert propSummaryGrp1;
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].Id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		objControllerClass.currentBatchStatus();
			objControllerClass.cancel();
		test.stopTest();
	
		}  
   }
	
	 //************************************************ For Direct
   static testmethod void validateQuoteController_InitTest280Direct(){
	   /* List<User> PartnerUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'Partner Profile');
		insert PartnerUser;*/
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
		opportunities[0].stageName =GlobalConstants.WIN_THE_CASE_NEGOTIATE;
		opportunities[0].Phase_Status__c = GlobalConstants.OFFER_SUBMITTED_TO_CUSTOMER_MANUAL;
	 //   opportunities[0].LOA_Level__c = 'C';
		opportunities[0].No_Loa__c = true;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		
		update opportunities; 
	   
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		//List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposalDirect(1);
	   // system.runAs(PartnerUser[0])
		{
		//create a quote
			system.debug('Accnt' + accounts[0].Id + opportunities[0].Id);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		proposals[0].RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId();
		proposals[0].NokiaCPQ_Portfolio__c = 'Airscale Wifi';
		proposals[0].NokiaCPQ_Maintenance_Type__c = 'MN GS TSS Enhanced';
		 insert proposals;
			
		  
			 /* proposals[0].Apttus_Proposal__Approval_Stage__c='In Review';
			update proposals;*/
			system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, IsActive, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
		
		//productInst.IsActive = true;
	//  update productInst;
		
		
	/*	// create a Line Item
		List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
			list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		insert proposalLineItemList;
	   
	  
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Grand Total'
		);
		insert propSummaryGrp1;
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].Id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		objControllerClass.currentBatchStatus();
			objControllerClass.cancel();
		test.stopTest();
	
		}  
   }
  //************************************************ For Direct
  // static testmethod void validateQuoteController_InitTest2800Direct(){
	   /* List<User> PartnerUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'Partner Profile');
		insert PartnerUser;*/
		//create a Account
	   
	   /* List<Account> accounts = NOKIA_CPQ_TestDataFactory.getAccounts(2);
		accounts[1].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		accounts[1].AccountNumber='';
		accounts[1].Partner_Type__c = '';
		accounts[1].Partner_Program__c = '';
		insert accounts;
		
		List<Account> acclist = new List<Account>();
		acclist.add(accounts[0]);*/
		
		//create opportunity
	  /*  GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES = true;
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunitieswithoutG6(1,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();		
	  opportunities[0].End_Customer_LE__c = accounts[1].id;
		insert opportunities; 
		opportunities[0].stageName =GlobalConstants.CREATE_OFFER;
		opportunities[0].Phase_Status__c = GlobalConstants.OFFER_IN_PROGRESS;
	 //   opportunities[0].LOA_Level__c = 'C';
		opportunities[0].No_Loa__c = true;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		
		update opportunities; */
	   
		//create Accreditation
	 /*   List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[0].Accreditation_Type__c = 'Maintenance';
		accreditations[0].Accreditation_Level__c = 'Premium';
		accreditations[0].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest();
		 List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
	   // system.runAs(PartnerUser[0])
		{
		//create a quote
			system.debug('Accnt' + accounts[0].Id + opportunities[0].Id);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		Proposals[0].NokiaCPQ_Maintenance_Type__c='';
		proposals[0].RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId();		
 
		 insert proposals;
			
		  
			  proposals[0].Apttus_Proposal__Approval_Stage__c='In Review';
			update proposals;
			system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		
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
		prodConfigs[0].Apttus_QPConfig__Proposald__c = proposals[0].Id;
		prodConfigs[0].Apttus_Config2__Status__c = 'Finalized';
		insert prodConfigs;
		
		//get a IP Routing Product
		Product2 productInst = new Product2();
		productInst = [SELECT Id, NAME, IsActive, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
		*/
		//productInst.IsActive = true;
	//  update productInst;
		
		
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		   
		 /*list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		//create proposal line items
		List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		insert proposalLineItemList;
	   
	  
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Grand Total'
		);
		insert propSummaryGrp1;
		
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].Id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		objControllerClass.currentBatchStatus();
			objControllerClass.cancel();
		test.stopTest();
	
		}  
   }*/
	
	//******************************************************************************************************************
	/***********************
	* Method Name: validateQuoteController_InitTest1
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTestIndirect1000000(){
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
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunitieswithoutG6(2,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();	 
		opportunities[1].End_Customer_LE__c = accounts[1].id;
		insert opportunities; 
		opportunities[0].stageName = 'Win the Case (Negotiate)';
		opportunities[0].Phase_Status__c = 'Offer Submitted to Customer (Manual)';
		opportunities[0].LOA_Level__c = '';
		opportunities[0].No_Loa__c = false ;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		
		opportunities[1].stageName = 'Create Offer (bid)';
		opportunities[1].Phase_Status__c = 'Offer in Progress';
		opportunities[1].LOA_Level__c = 'A';
		opportunities[1].No_Loa__c = false;
		opportunities[1].Apttus_Approval__Approval_Status__c = 'Approved';
		update opportunities; 
				
		Offer__c offer = new Offer__c(
		No_LoA__c = false,
		ActiveOffer__c =true,
		Authorized_for_Pricing_Manager__c = true,
		Pre_approved_Price_List_for_Acc_Managers__c = false,
		Expected_LoA_G4_Approval_Level__c = 'LoA Bypass',
		LOA_Bypass__c = 'Pre-approved Price List for Account Managers',
		Opportunity__c = opportunities[1].Id
		); 
		insert offer;
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
	 //   proposals[0].NokiaCPQ_Total_Quote_Discount__c=0;
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		//get a Price List
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList.Name='Global Price List (EUR)';
		priceList.CurrencyIsoCode='GBP';
		priceList.Apttus_Config2__Active__c=false;
		priceList.PriceList_Type__c='CPQ';
		priceList.Apttus_Config2__Type__c='Standard';
		
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
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest(); 
		
	}
	  //******************************************************************************************************************
	/***********************
	* Method Name: validateQuoteController_InitTest1
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTestIndirect1000000IN(){
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
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunitieswithoutG6(2,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();	 
		opportunities[1].End_Customer_LE__c = accounts[1].id;
		insert opportunities; 
		opportunities[0].stageName = 'Win the Case (Negotiate)';
		opportunities[0].Phase_Status__c = 'Offer Submitted to Customer (Manual)';
		opportunities[0].LOA_Level__c = '';
		opportunities[0].No_Loa__c = true ;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		
		opportunities[1].stageName = 'Create Offer (bid)';
		opportunities[1].Phase_Status__c = 'Offer in Progress';
		opportunities[1].LOA_Level__c = 'A';
		opportunities[1].No_Loa__c = true;
		opportunities[1].Apttus_Approval__Approval_Status__c = 'Approved';
		update opportunities; 
				
		Offer__c offer = new Offer__c(
		No_LoA__c = false,
		ActiveOffer__c =true,
		Authorized_for_Pricing_Manager__c = true,
		Pre_approved_Price_List_for_Acc_Managers__c = false,
		Expected_LoA_G4_Approval_Level__c = 'LoA Bypass',
		LOA_Bypass__c = 'Pre-approved Price List for Account Managers',
		Opportunity__c = opportunities[1].Id
		); 
		insert offer;
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
	 //   proposals[0].NokiaCPQ_Total_Quote_Discount__c=0;
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		//get a Price List
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList.Name='Global Price List (EUR)';
		priceList.CurrencyIsoCode='GBP';
		priceList.Apttus_Config2__Active__c=false;
		priceList.PriceList_Type__c='CPQ';
		priceList.Apttus_Config2__Type__c='Standard';
		
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
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
		/*List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest(); 
		
	}

	//******************************************************************************************************************
	/***********************
	* Method Name: validateQuoteController_InitTest1
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTestIndirect10IN(){
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
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunitieswithoutG6(2,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();	 
		opportunities[1].End_Customer_LE__c = accounts[1].id;
		insert opportunities; 
		opportunities[0].stageName = 'Win the Case (Negotiate)';
		opportunities[0].Phase_Status__c = 'Offer Submitted to Customer (Manual)';
		opportunities[0].LOA_Level__c = 'C';
		opportunities[0].No_Loa__c = false ;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		
		opportunities[1].stageName = 'Create Offer (bid)';
		opportunities[1].Phase_Status__c = 'Offer in Progress';
		opportunities[1].LOA_Level__c = 'A';
		opportunities[1].No_Loa__c = false;
		opportunities[1].Apttus_Approval__Approval_Status__c = 'Approved';
		update opportunities; 
				
		Offer__c offer = new Offer__c(
		No_LoA__c = false,
		ActiveOffer__c =true,
		Authorized_for_Pricing_Manager__c = true,
		Pre_approved_Price_List_for_Acc_Managers__c = false,
		Expected_LoA_G4_Approval_Level__c = 'LoA Bypass',
		LOA_Bypass__c = 'Pre-approved Price List for Account Managers',
		Opportunity__c = opportunities[1].Id
		); 
		insert offer;
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
	 //   proposals[0].NokiaCPQ_Total_Quote_Discount__c=0;
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		//get a Price List
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList.Name='Global Price List (EUR)';
		priceList.CurrencyIsoCode='GBP';
		priceList.Apttus_Config2__Active__c=false;
		priceList.PriceList_Type__c='CPQ';
		priceList.Apttus_Config2__Type__c='Standard';
		
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
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest(); 
		
	}
	//******************************************************************************************************************
	/***********************
	* Method Name: validateQuoteController_InitTest1
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTestIndirect011IN(){
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
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunitieswithoutG6(2,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();	 
		opportunities[1].End_Customer_LE__c = accounts[1].id;
		insert opportunities; 
		opportunities[0].stageName = 'Win the Case (Negotiate)';
		opportunities[0].Phase_Status__c = 'Offer Submitted to Customer (Manual)';
		opportunities[0].LOA_Level__c = '';
		opportunities[0].No_Loa__c = true ;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		
		opportunities[1].stageName = 'Create Offer (bid)';
		opportunities[1].Phase_Status__c = 'Offer in Progress';
		opportunities[1].LOA_Level__c = '';
		opportunities[1].No_Loa__c = true;
		opportunities[1].Apttus_Approval__Approval_Status__c = 'Approved';
		update opportunities; 
				
		Offer__c offer = new Offer__c(
		No_LoA__c = false,
		ActiveOffer__c =true,
		Authorized_for_Pricing_Manager__c = true,
		Pre_approved_Price_List_for_Acc_Managers__c = false,
		Expected_LoA_G4_Approval_Level__c = 'LoA Bypass',
		LOA_Bypass__c = 'Pre-approved Price List for Account Managers',
		Opportunity__c = opportunities[1].Id
		); 
		insert offer;
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
	 //   proposals[0].NokiaCPQ_Total_Quote_Discount__c=0;
			 proposals[0].Maintenance_Y2__c=1;
			 proposals[0].NokiaCPQ_LEO_Discount__c = true;
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		//get a Price List
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList.Name='Global Price List (EUR)';
		priceList.CurrencyIsoCode='GBP';
		priceList.Apttus_Config2__Active__c=false;
		priceList.PriceList_Type__c='CPQ';
		priceList.Apttus_Config2__Type__c='Standard';
		
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
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 1,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest(); 
		
	}
 
	//******************************************************************************************************************
	/***********************
	* Method Name: validateQuoteController_InitTest1
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTestIndirect00000011IN(){
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
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunitieswithoutG6(2,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();	 
		opportunities[1].End_Customer_LE__c = accounts[1].id;
		insert opportunities; 
		opportunities[1].stageName = 'Create Offer (bid)';
		opportunities[1].Phase_Status__c = 'Offer in Progress';
		opportunities[1].LOA_Level__c = '';
		opportunities[1].No_Loa__c = true;
		opportunities[1].Apttus_Approval__Approval_Status__c = 'Approved';
		
		opportunities[0].stageName = 'Win the Case (Negotiate)';
		opportunities[0].Phase_Status__c = 'Offer Submitted to Customer (Manual)';
		opportunities[0].LOA_Level__c = '';
		opportunities[0].No_Loa__c = true ;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		update opportunities; 
				
		Offer__c offer = new Offer__c(
		No_LoA__c = false,
		ActiveOffer__c =true,
		Authorized_for_Pricing_Manager__c = true,
		Pre_approved_Price_List_for_Acc_Managers__c = false,
		Expected_LoA_G4_Approval_Level__c = 'LoA Bypass',
		LOA_Bypass__c = 'Pre-approved Price List for Account Managers',
		Opportunity__c = opportunities[1].Id
		); 
		insert offer;
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
	 //   proposals[0].NokiaCPQ_Total_Quote_Discount__c=0;
	 proposals[0].NokiaCPQ_LEO_Discount__c = true;
				  proposals[0].Maintenance_Y2__c=1;
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		//get a Price List
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList.Name='Global Price List (EUR)';
		priceList.CurrencyIsoCode='GBP';
		priceList.Apttus_Config2__Active__c=false;
		priceList.PriceList_Type__c='CPQ';
		priceList.Apttus_Config2__Type__c='Standard';
		
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
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 1,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest(); 
		
	}
	
	//******************************************************************************************************************
	/***********************
	* Method Name: validateQuoteController_InitTest1
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTestIndirectINDIRECT(){
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
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunitieswithoutG6(2,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();	 
		opportunities[1].End_Customer_LE__c = accounts[1].id;
		insert opportunities; 
		opportunities[0].stageName = 'Win the Case (Negotiate)';
		opportunities[0].Phase_Status__c = 'Offer Submitted to Customer (Manual)';
		opportunities[0].LOA_Level__c ='A';
		opportunities[0].No_Loa__c = false ;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		
		opportunities[1].stageName = 'Create Offer (bid)';
		opportunities[1].Phase_Status__c = 'Offer in Progress';
		opportunities[1].LOA_Level__c = GlobalConstants.LOA_BYPASS_LEVEL;
		opportunities[1].No_Loa__c = true;
		opportunities[1].Apttus_Approval__Approval_Status__c = 'Approved';
		update opportunities; 
				
		Offer__c offer = new Offer__c(
		No_LoA__c = false,
		ActiveOffer__c =true,
		Authorized_for_Pricing_Manager__c = true,
		Pre_approved_Price_List_for_Acc_Managers__c = false,
		Expected_LoA_G4_Approval_Level__c = 'LoA Bypass',
		LOA_Bypass__c = 'Pre-approved Price List for Account Managers',
		Opportunity__c = opportunities[1].Id
		); 
		insert offer;
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
	 //   proposals[0].NokiaCPQ_Total_Quote_Discount__c=0;
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		//get a Price List
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList.Name='Global Price List (EUR)';
		priceList.CurrencyIsoCode='GBP';
		priceList.Apttus_Config2__Active__c=false;
		priceList.PriceList_Type__c='CPQ';
		priceList.Apttus_Config2__Type__c='Standard';
		
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
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest(); 
		
	}
	
	 //******************************************************************************************************************
	/***********************
	* Method Name: validateQuoteController_InitTest1
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTestIndirectINDIRECTttt(){
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
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunitieswithoutG6(2,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[1].End_Customer_LE__c = accounts[1].id;
	 /*   opportunities[2].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[2].End_Customer_LE__c = accounts[1].id;*/
		opportunities[0].stageName = 'Win the Case (Negotiate)';
		opportunities[0].Phase_Status__c = 'Offer Submitted to Customer (Manual)';
		opportunities[0].LOA_Level__c ='A';
		opportunities[0].No_Loa__c = false ;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		insert opportunities;
	   
		 opportunities[1].stageName = GlobalConstants.IDENTIFY_OPPORTUNITY ;
		opportunities[1].Phase_Status__c ='Submitted for G2 Approval';
		opportunities[1].LOA_Level__c ='A';
		opportunities[1].No_Loa__c = false ;
		opportunities[1].Apttus_Approval__Approval_Status__c = 'Approved';
		/*opportunities[2].stageName ='Create Offer (bid)';
		opportunities[2].Phase_Status__c = 'Offer in Progress';
		opportunities[2].LOA_Level__c ='A';
		opportunities[2].No_Loa__c = false ;
		opportunities[2].Apttus_Approval__Approval_Status__c = 'Approved';	 */   
		update opportunities;
	   

		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		//get a Price List
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList.Name='Global Price List (EUR)';
		priceList.CurrencyIsoCode='GBP';
		priceList.Apttus_Config2__Active__c=false;
		priceList.PriceList_Type__c='CPQ';
		priceList.Apttus_Config2__Type__c='Standard';
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
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest(); 
		
	}
	   /* Method Name: validateQuoteController_InitTest1
	* Description: To cover the method inti method of vf page controller class: NokiaCPQ_Validate_Quote_Ctrlr
	* Parameters: NA
	************************/
	static testmethod void validateQuoteController_InitTestIndirectINDIRECTTest9(){
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
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunitieswithoutG6(2,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[1].End_Customer_LE__c = accounts[1].id;
	 /*   opportunities[2].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[2].End_Customer_LE__c = accounts[1].id;*/
		opportunities[0].stageName = 'Win the Case (Negotiate)';
		opportunities[0].Phase_Status__c = 'Pending Win/Loss Declaration';
		opportunities[0].LOA_Level__c ='A';
		opportunities[0].No_Loa__c = false ;
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		insert opportunities;
	   
		 opportunities[1].stageName = GlobalConstants.IDENTIFY_OPPORTUNITY ;
		opportunities[1].Phase_Status__c ='Submitted for G2 Approval';
		opportunities[1].LOA_Level__c ='A';
		opportunities[1].No_Loa__c = false ;
		opportunities[1].Apttus_Approval__Approval_Status__c = 'Approved';
		/*opportunities[2].stageName ='Create Offer (bid)';
		opportunities[2].Phase_Status__c = 'Offer in Progress';
		opportunities[2].LOA_Level__c ='A';
		opportunities[2].No_Loa__c = false ;
		opportunities[2].Apttus_Approval__Approval_Status__c = 'Approved';	 */   
		update opportunities;
	   

		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
		proposals[0].NokiaCPQ_LEO_Discount__c =  true;
		proposals[0].NokiaCPQ_has_Partner_Certified__c =  false;
		proposals[0].Maintenance_Y1__c =10;
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		//get a Price List
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList.Name='Global Price List (EUR)';
		priceList.CurrencyIsoCode='GBP';
		priceList.Apttus_Config2__Active__c=false;
		priceList.PriceList_Type__c='CPQ';
		priceList.Apttus_Config2__Type__c='Standard';
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
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
	   /* List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		insert lineItems;*/
		 list<Apttus_Config2__LineItem__c> LineItemList = new List<Apttus_Config2__LineItem__c>();

		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=prodConfigs[0].Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = priceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			//Portfolio_from_Quote_Line_Item__c = 'Nokia Software',
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = productInst.Id,
		   // Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			Apttus_Config2__PricingStatus__c = 'Pending',		   
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		 

		//insert LineItem2;
		LineItemList.add(LineItem1);
		
		//insert proposal line item
		 List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList= NOKIA_CPQ_TestDataFactory.createProposalLineItem(1);
		proposalLineItemList[0].Apttus_Proposal__Product__c = productInst.id;
		proposalLineItemList[0].Apttus_Proposal__Proposal__c =proposals[0].id;
		proposalLineItemList[0].Apttus_QPConfig__LineType__c = Nokia_CPQ_Constants.lin_Apttus_QPConfig;
				proposalLineItemList[0].is_Custom_Product__c=true;
		insert proposalLineItemList;
		
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		
		ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest(); 
		
	}
	
	static testmethod void validateQuoteController_optyOwnerShareTest(){
	  
		List<user>userList = new List<User>();
		List<Account> accounts = new list<Account>();
		List<Account> acclist = new list<Account>();
		userList = TestDataFactory.userCreation(2,'System Administrator');
		database.insert(userList);
		 
		PermissionSet ps = [Select id from PermissionSet Where name = 'Nokia_CPQ_Partner_User' Limit 1];
		System.debug('psid>>'+ps.Id);
		PermissionSetAssignment  psAssgnment = new PermissionSetAssignment();
		psAssgnment.AssigneeId = userList[0].Id;
		psAssgnment.PermissionSetId = ps.id;
		Database.insert(psAssgnment);
		 
		 System.runAs(userList[1]){
	
	 //create a Account
		accounts = NOKIA_CPQ_TestDataFactory.getAccounts(2);
		accounts[1].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		accounts[1].AccountNumber='';
		accounts[1].Partner_Type__c = '';
	 accounts[1].Partner_Program__c = '';
		insert accounts;
		
		 acclist = new List<Account>();
		acclist.add(accounts[0]);
		 
		 }
		 
		 System.runAs(userList[0]){
		//create opportunity
		GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES = true;
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunitieswithoutG6(2,acclist);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();		
		opportunities[0].End_Customer_LE__c = accounts[1].id;
		opportunities[1].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();	 
		opportunities[1].End_Customer_LE__c = accounts[1].id;
		insert opportunities; 
		opportunities[0].stageName = 'Win the Case (Negotiate)';
		opportunities[0].Phase_Status__c = 'Offer Submitted to Customer (Manual)';
		opportunities[0].LOA_Level__c = '';
		
		opportunities[0].Apttus_Approval__Approval_Status__c = 'Approved';
		opportunities[0].No_Loa__c = true;
		opportunities[1].stageName = GlobalConstants.CREATE_OFFER;
		opportunities[1].Phase_Status__c = 'Offer in Progress';
		opportunities[1].LOA_Level__c = '';
		opportunities[1].No_Loa__c = false;
		opportunities[1].Apttus_Approval__Approval_Status__c = 'Approved';
		update opportunities; 
	
		Offer__c offer = new Offer__c(
		No_LoA__c = false,
		ActiveOffer__c =false,
		Authorized_for_Pricing_Manager__c = false,
		Pre_approved_Price_List_for_Acc_Managers__c = false,
		Expected_LoA_G4_Approval_Level__c = 'LoA Bypass',
		LOA_Bypass__c = 'Pre-approved Price List for Account Managers',
		Opportunity__c = opportunities[0].Id
		); 
		insert offer;
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = accounts[0].Id;
		accreditations[1].partner__c = accounts[0].Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		test.startTest(); 
		//create a quote
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].NokiaCPQ_Needs_Reprice__c = false;
		proposals[0].Reprice_In_Progress__c = false;
	// proposals[0].NokiaCPQ_Pre_Approved_Discount_Range__c = false;
		proposals[0].RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Draft Quote').getRecordTypeId();
		//proposals[0].RecordTypeId ='012290000008kdZAAQ'; //direct quote
		//proposals[0].RecordTypeId ='01241000001EPXcAAO'; //indirect draft quote
	 //   proposals[0].NokiaCPQ_Total_Quote_Discount__c=0;
		insert proposals;		
		system.debug('>>>Quote Record Type::>>'+proposals[0].recordtypeID);
		
		//get a Price List
		Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
		priceList.Name='Global Price List (EUR)';
		priceList.CurrencyIsoCode='GBP';
		priceList.Apttus_Config2__Active__c=false;
		priceList.PriceList_Type__c='CPQ';
		priceList.Apttus_Config2__Type__c='Standard';
		
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
		productInst = [SELECT Id, NAME, Portfolio__c, ProductCode, Apttus_Config2__ConfigurationType__c, NokiaCPQ_Category__c, NokiaCPQ_Product_Discount_Category__c, Pricing_Clusters_Search_Filter__c, Pricing_Clusters__c, NokiaCPQ_State__c FROM Product2 WHERE Portfolio__c =: proposals[0].NokiaCPQ_Portfolio__c AND NokiaCPQ_State__c != null Limit 1];
			
		// create a Line Item
		List<Apttus_Config2__LineItem__c> lineItems = NOKIA_CPQ_TestDataFactory.createLineItem(1);
		lineItems[0].Apttus_Config2__ConfigurationId__c = prodConfigs[0].id;
		lineItems[0].Apttus_Config2__ProductId__c = productInst.Id;
		lineItems[0].Apttus_Config2__PriceListId__c = priceList.Id;
		lineItems[0].Apttus_Config2__ItemSequence__c = 1;
		lineItems[0].Apttus_Config2__LineNumber__c = 1;
		lineItems[0].Apttus_Config2__LineStatus__c='New';
		lineItems[0].Apttus_Config2__ChargeType__c = 'Standard Price';
		lineItems[0].Apttus_Config2__LineType__c = 'Product/Service';
		lineItems[0].Apttus_Config2__PriceMethod__c = 'Per Unit';
		lineItems[0].Apttus_Config2__Frequency__c = 'One Time';
		lineItems[0].Apttus_Config2__AdjustmentAmount__c = 10;
		lineItems[0].Apttus_Config2__ListPrice__c = 100;
		lineItems[0].Apttus_Config2__Quantity__c = 1;
		lineItems[0].Apttus_Config2__PrimaryLineNumber__c = 1;
		lineItems[0].Apttus_Config2__ShipToAccountId__c = accounts[0].Id;
		lineItems[0].Apttus_Config2__AddedBy__c = 'added by code';
		insert lineItems;
		
		// Proposal Summary Group
		Apttus_QPConfig__ProposalSummaryGroup__c propSummaryGrp1 = new Apttus_QPConfig__ProposalSummaryGroup__c(
		Apttus_QPConfig__ProposalId__c = proposals[0].id,
		Apttus_QPConfig__AdjustmentAmount__c = 0,
		CurrencyIsoCode = 'USD',
		Apttus_QPConfig__NetPrice__c = 100.00,
		Apttus_QPConfig__ItemSequence__c = 1,
		Apttus_QPConfig__LineNumber__c = 1,
		Apttus_QPConfig__ExtendedPrice__c = 100,
		name = 'Total (One Time)'
		);
		insert propSummaryGrp1;
		 
	
			ApexPages.currentPage().getParameters().put('quoteId',proposals[0].id);
		ApexPages.currentPage().getParameters().put('oppId',opportunities[0].id);
		NokiaCPQ_Validate_Quote_Ctrlr objControllerClass = new NokiaCPQ_Validate_Quote_Ctrlr();
		objControllerClass.init();
		test.stopTest();   
	
	
		 }
		 
	  }
}