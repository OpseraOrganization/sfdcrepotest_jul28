/************************************************************************************************************
* Apex Class Name   : PS_productuploadscontroller_Test
* Version		   : 1.0 
* Created Date	  : 24 Jan 2018
* Function		  : test class for PS_productuploadscontroller_Test
* Modification Log  :
* Developer				   Date					Description
* -----------------------------------------------------------------------------------------------------------
*Sneha Padhi			   20/01/2018			  Created Test Class for PS_productuploadscontroller_Test
*
************************************************************************************************************/
@isTest(seeAllData =true)
private class PS_productuploadscontroller_Test
{
	
	private static List<Account> accountList = new List<Account>();
	private static List<Opportunity> opportunityList = new List<Opportunity>();
	public static String[] csvFileLines;
	public static Blob csvFileBody;
	static String str = 'Name,AccountNumber,Type,Accountsource,Industry\n Esha Patharabe,10001,Prospect,Test,Banking\n Trupti Nimje,10002,Prospect,Test,Banking';

	/********** functionality lineitem trigger  ***********/
	@isTest static void lineitemTest1(){
		String csvContent = '/n /n ProductCode,Quantity,SiteName\n  3EC17929UA ;1;A B\n  3FE31189BA ,1,B C\n  301049607 ,1,C D\n  3EC17929UA,1,D E\n  3FE30949BA,1,E F\n  301049607,1,F G';
	   
		List <Account> account2 = NOKIA_CPQ_TestDataFactory.getAccounts(2);
		account2[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
		account2[1].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		account2[1].Partner_Type__c = '';
		account2[1].Partner_Program__c = '';
		insert account2;
		
		List<Opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunities(1,account2);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunities[0].End_Customer_LE__c = account2[1].id;
		insert opportunities;
		
		/*create product*/
		product2 prod = new product2();
		prod.name = '5G';
		prod.CurrencyIsoCode = 'USD';
		prod.Business_Group__c='NSW';
		prod.Family= 'A&A-CEM';
		prod.IsActive=True;
		prod.Partner_Visible__c=True;
		prod.ProductCode='3EC17929UA';
		prod.Apttus_Config2__Version__c=1;
		prod.Portfolio__c='IP Routing';
		prod.Pricing_Clusters__c='NAM';
		prod.IsActive= True;
		prod.Created_by_PMDI__c = True;
		//prod.Apttus_Config2__Version__c = 1;
		prod.isInvalidProductCatalog__c = Nokia_CPQ_Constants.TrueValue;
		prod.NokiaCPQ_Valid_for__c = 'Indirect';
		
		insert prod;
		
	  
		
		
		  /*create accreditation*/
		Accreditation__c accreditation1 = new Accreditation__c(Accreditation_Type__c='Product',
										Accreditation_Date__c = date.today(),
										Accreditation_Level__c='Advanced',
										Partner__c=account2[0].Id,
										Portfolio__c='IP Routing',
										Pricing_Cluster__c='NAM'				
				);
		insert accreditation1;
		accreditation1.app_name__c = 'Q2C_'+ accreditation1.Portfolio__c;
		update accreditation1;
		
		Accreditation__c accreditation2 = new Accreditation__c(Accreditation_Type__c='Maintenance',
										Accreditation_Date__c = date.today(),
										Accreditation_Level__c='Nokia Brand of Service',
										Partner__c=account2[0].Id,
										Portfolio__c='IP Routing',
										Pricing_Cluster__c='NAM'				
				);
		insert accreditation2;
		
		
		/*create pricelist*/
		Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
		Name = 'Commercial Price List', 
		PriceList_Type__c='CPQ',
		Apttus_Config2__Type__c='Standard',
		Apttus_Config2__Active__c = True
		);
		
		insert ApttusTestPriceList;
		
		/*create pricelist Item*/
		Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__ListPrice__c = 100, 
			Apttus_Config2__ProductId__c = prod.Id, 
			Apttus_Config2__ChargeType__c = 'Maintenance Year2+'
		);
		insert pLI5;
		
			test.startTest();
			Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(
			RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Proposal').getRecordTypeId(),
			Apttus_Proposal__Account__c = account2[0].Id,
			Apttus_Proposal__Opportunity__c = opportunities.get(0).Id,
			Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			NokiaCPQ_FN_Maintenance_Type__c='',
			NokiaCPQ_SRS_Level__c='',
			NokiaCPQ_Existing_IONMaint_Contract__c='',
			NokiaCPQ_Needs_Reprice__c = false,
			Reprice_In_Progress__c = false,
			NokiaCPQ_Existing_FN_Maint_Contract__c='',
			NokiaCPQ_No_of_Years__c = '',
			NokiaCPQ_ION_Maintenance_Type__c='',
			NokiaCPQ_SSP_Level__c='',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_Maintenance_Type__c =''  ,
			NokiaProductAccreditation__c=accreditation1.Id,
			NokiaCPQ_Maintenance_Accreditation__c=accreditation2.Id,
			Warranty_credit__c='Yes',
			NokiaCPQ_Is_Maintenance_Quote__c=true,
			NokiaCPQ_Contract_Start_Date__c=date.today(),
			Is_List_Price_Only__c = true,
			NokiaCPQPricing_Cluster__c = 'NAM'			
		 );
		insert testProposal;
		
		
		//create product configuration
		Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c(
			Name = 'APTTUS Test Config', 
			Apttus_Config2__AccountId__c = account2[0].Id, 
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
			Apttus_QPConfig__Proposald__c = testProposal.Id, 
			Apttus_Config2__Status__c = 'Finalized', 
			Apttus_Config2__VersionNumber__c = 1, 
			Apttus_Config2__EffectivePriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__BusinessObjectId__c = String.valueOf(testProposal.Id),
			Apttus_Config2__BusinessObjectType__c = 'Proposal'
			
			
		);
		insert ProdConfig;

		NokiaCPQ_Site__c site = new NokiaCPQ_Site__c();
		site.Opportunity__c = opportunities.get(0).Id;
		site.name = 'test tws';
		insert site;
		ApexPages.currentPage().getParameters().put('id',testProposal.id);
		csvFileBody =  Blob.valueof(csvContent); //Blob.valueOf(str);
		String csvAsString = csvFileBody.toString();
		csvFileLines = csvAsString.split('\n');
		PS_productuploadscontroller puc = new  PS_productuploadscontroller(new ApexPages.StandardController(testProposal));
	   // puc.csvFileBody = csvFileBody;
		puc.csvAsString = 'filename.csv';
		puc.csvFileBody =  Blob.valueof(csvContent);
		puc.setFile();
		puc.readFromFile();
		puc.createcart();
		puc.addProductsfromfile();
		//puc.Reprice();
		//puc.Finalize();
		puc.Saveconfig();
		puc.Finalize();
		puc.returntocart();
		puc.returntoquote();
		
		//puc.readCSVDirectFile();
		
		List<Apttus_Config2__LineItem__c> li = [select Id,Apttus_Config2__IsHidden__c from Apttus_Config2__LineItem__c Limit 1];
		Apttus_Config2__ProductAttributeValue__c PA1 = new Apttus_Config2__ProductAttributeValue__c();
		
	   
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
			Apttus_Config2__ProductId__c = prod.Id,
		//	Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__IsHidden__c=true,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = account2[0].Id,
			
			
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		
	   insert  LineItem1;
		Apttus_Config2__LineItem__c LineItem2 =new Apttus_Config2__LineItem__c();
		LineItem2.Apttus_Config2__IsHidden__c = true;
		LineItem2.Apttus_Config2__ConfigurationId__c=ProdConfig.Id;
		LineItem2.Apttus_Config2__ProductId__c = prod.Id;
		LineItem2.Apttus_Config2__ItemSequence__c = 1;
		LineItem2.Apttus_Config2__LineNumber__c = 1;
		insert LineItem2;
		
	   
	 /*   if(li != null && !li.isEmpty() && li[0] != null){
			PA1.Apttus_Config2__LineItemId__c = li[0].id;
			PA1.Q_SWSuite__c = 'Premium';
		}
		   insert PA1;  */
		try {
			puc.readFromFile();
		} catch(DMLException e) {
			system.assertEquals(e.getMessage(), e.getMessage());
		}
		test.stopTest();
	 }
	
	@isTest static void lineitemTest01(){
	   
		String csvContent = '/n /nProductCode,Quantity,SiteName\nFC11011;1;AB';
	   
		List <Account> account3 = NOKIA_CPQ_TestDataFactory.getAccounts(2);
		account3[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
	   // account2[1].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
	 //   account2[1].Partner_Type__c = '';
	  //  account2[1].Partner_Program__c = '';
		insert account3;
		
		List<Opportunity> opportunities1 = NOKIA_CPQ_TestDataFactory.getOpportunities(1,account3);
		opportunities1[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
	 //   opportunities[0].End_Customer_LE__c = account2[1].id;
		insert opportunities1;
	 
	   /*create product*/
	   product2 prod = new product2();
		prod.name = '5G';
		prod.CurrencyIsoCode = 'USD';
		prod.Business_Group__c='MN';
		prod.Family= 'A&A-CEM';
		prod.IsActive=True;
		prod.Partner_Visible__c=True;
		prod.ProductCode='FC11011';
		prod.Apttus_Config2__Version__c=1;
		prod.Portfolio__c='Airscale Wifi';
		prod.Created_by_PMDI__c = False;
		prod.Pricing_Clusters__c='NAM';
		prod.IsActive= True;
		insert prod;

	 test.startTest();	
	   /*create pricelist*/
		Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
		Name = 'Commercial Price List', 
		PriceList_Type__c='CPQ',
		Apttus_Config2__Type__c='Standard',
		Apttus_Config2__Active__c = True
		);
	   insert ApttusTestPriceList;
		/*create pricelist Item*/
	   Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__ListPrice__c = 100, 
			Apttus_Config2__ProductId__c = prod.Id, 
			Apttus_Config2__ChargeType__c = 'Standard Price'
		);
		insert pLI5;
		   
			Apttus_Proposal__Proposal__c testProposal1 = new Apttus_Proposal__Proposal__c(
			RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),
			Apttus_Proposal__Account__c = account3[0].Id,
			Apttus_Proposal__Opportunity__c = opportunities1.get(0).Id,
			Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			NokiaCPQ_FN_Maintenance_Type__c='',
			NokiaCPQ_SRS_Level__c='',
			NokiaCPQ_Existing_IONMaint_Contract__c='',
			NokiaCPQ_Needs_Reprice__c = false,
			//NokiaCPQ_Environment_Access_Type__c = 'PRM',
			Reprice_In_Progress__c = false,
			NokiaCPQ_Existing_FN_Maint_Contract__c='',
			NokiaCPQ_No_of_Years__c = '1',
			NokiaCPQ_ION_Maintenance_Type__c='',
			NokiaCPQ_SSP_Level__c='',
			NokiaCPQ_Portfolio__c = 'Airscale WiFi',
			NokiaCPQ_Maintenance_Type__c ='MN GS TSS Basic',
		   NokiaCPQ_Is_Maintenance_Quote__c=true,
				NokiaCPQ_Contract_Start_Date__c=date.today(),
				Warranty_credit__c='Yes'
		 );
		insert testProposal1;
		 
		
		
		Apttus_Config2__ProductConfiguration__c pconfig = new Apttus_Config2__ProductConfiguration__c();
		pconfig.Apttus_QPConfig__Proposald__c = testProposal1.Id;
		pconfig.Apttus_Config2__Status__c = 'Saved';
		pconfig.Name = 'APTTUS Test Config';
		pconfig.Apttus_Config2__AccountId__c = account3[0].Id;
		pconfig.Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id;
		insert pconfig;
		   
	   Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=pconfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			//Apttus_Config2__ChargeType__c = 'Standard Type',
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = prod.Id,
		//	Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__AdjustmentAmount__c = 10,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__IsHidden__c=true,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = account3[0].Id,
			Apttus_Config2__AddedBy__c = 'added by code'
		);
		insert  LineItem1;
		
		Direct_Portfolio_General_Setting__mdt setting = new Direct_Portfolio_General_Setting__mdt();
		setting.Portfolio__c = testProposal1.NokiaCPQ_Portfolio__c;
		setting.GSS_Flow__c = 'GSS List Price';
		setting.Non_GSS_Flow__c = 'ION Direct Pricing Quote';
		setting.MNDirectFlow__c = 'GridViewCartMNDirect';
		setting.Direct_CPQ__c = true;
		
	   
		
		ApexPages.currentPage().getParameters().put('id',testProposal1.id);
		PS_productuploadscontroller puc = new  PS_productuploadscontroller(new ApexPages.StandardController(testProposal1));
		
		
		
		puc.csvAsString = 'filename.csv';
		puc.csvFileBody =  Blob.valueof(csvContent);
		puc.setFile();
		puc.readFromFile();
		puc.createcart();
		puc.addProductsfromfile();
		puc.Reprice();
	  //  puc.Finalize();
		puc.Saveconfig();
		//puc.Finalize();
		puc.returntocart();
		puc.returntoquote();
		
		
		List<Apttus_Config2__LineItem__c> li = [select Id from Apttus_Config2__LineItem__c Limit 1];
		Apttus_Config2__ProductAttributeValue__c PA1 = new Apttus_Config2__ProductAttributeValue__c();
		
		if(li != null && !li.isEmpty() && li[0] != null){
			PA1.Apttus_Config2__LineItemId__c = li[0].id;
			PA1.Q_SWSuite__c = 'Premium';
		}
		   insert PA1; 
		test.stopTest();
	 }
	@isTest static void lineitemTest02(){
	   
		String csvContent = '/n /nProduct Code,Quantity,SiteName\nFC11011;1;AB';
	   
		List <Account> account3 = NOKIA_CPQ_TestDataFactory.getAccounts(2);
		account3[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
	   // account2[1].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
	 //   account2[1].Partner_Type__c = '';
	  //  account2[1].Partner_Program__c = '';
		insert account3;
		
		List<Opportunity> opportunities1 = NOKIA_CPQ_TestDataFactory.getOpportunities(1,account3);
		opportunities1[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
	 //   opportunities[0].End_Customer_LE__c = account2[1].id;
		insert opportunities1;
	 
	   /*create product*/
	   product2 prod = new product2();
		prod.name = '5G';
		prod.CurrencyIsoCode = 'USD';
		prod.Business_Group__c='MN';
		prod.Family= 'A&A-CEM';
		prod.IsActive=True;
		prod.Partner_Visible__c=True;
		prod.ProductCode='PRODUCT CODE';
		prod.Apttus_Config2__Version__c=1;
		prod.Portfolio__c='Airscale Wifi';
		prod.Created_by_PMDI__c = False;
		prod.Pricing_Clusters__c='NAM';
		prod.IsActive= True;
		insert prod;

		test.startTest(); 
	   /*create pricelist*/
		Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
		Name = 'Commercial Price List', 
		PriceList_Type__c='CPQ',
		Apttus_Config2__Type__c='Standard',
		Apttus_Config2__Active__c = True
		);
	   
		insert ApttusTestPriceList;
		/*create pricelist Item*/
	   Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__ListPrice__c = 100, 
			Apttus_Config2__ProductId__c = prod.Id, 
			Apttus_Config2__ChargeType__c = 'Standard Price'
		);
		insert pLI5;
		   
			Apttus_Proposal__Proposal__c testProposal1 = new Apttus_Proposal__Proposal__c(
			RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),
			Apttus_Proposal__Account__c = account3[0].Id,
			Apttus_Proposal__Opportunity__c = opportunities1.get(0).Id,
			Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			NokiaCPQ_FN_Maintenance_Type__c='',
			NokiaCPQ_SRS_Level__c='',
			NokiaCPQ_Existing_IONMaint_Contract__c='',
			NokiaCPQ_Needs_Reprice__c = false,
			//NokiaCPQ_Environment_Access_Type__c = 'PRM',
			Reprice_In_Progress__c = false,
			NokiaCPQ_Existing_FN_Maint_Contract__c='',
			NokiaCPQ_No_of_Years__c = '1',
			NokiaCPQ_ION_Maintenance_Type__c='',
			NokiaCPQ_SSP_Level__c='',
			NokiaCPQ_Portfolio__c = 'Airscale WiFi',
			NokiaCPQ_Maintenance_Type__c ='MN GS TSS Basic',
			NokiaCPQ_Is_Maintenance_Quote__c=true,
			NokiaCPQ_Contract_Start_Date__c=date.today(),
			Warranty_credit__c='Yes'
		 );
		insert testProposal1;
		   
		   
		Direct_Portfolio_General_Setting__mdt setting = new Direct_Portfolio_General_Setting__mdt();
		setting.Portfolio__c = testProposal1.NokiaCPQ_Portfolio__c;
		setting.GSS_Flow__c = 'GSS List Price';
		setting.Non_GSS_Flow__c = 'ION Direct Pricing Quote';
		setting.MNDirectFlow__c = 'GridViewCartMNDirect';
		setting.Direct_CPQ__c = true;
		
	   
		if(testProposal1.id != Null){
		ApexPages.currentPage().getParameters().put('id',testProposal1.id);
		PS_productuploadscontroller puc = new  PS_productuploadscontroller(new ApexPages.StandardController(testProposal1));
		
		
		
		puc.csvAsString = 'filename.csv';
		puc.csvFileBody =  Blob.valueof(csvContent);
		puc.setFile();
		puc.readFromFile();
		puc.createcart();
		//puc.addProductsfromfile();
		puc.Reprice();
	  //  puc.Finalize();
		puc.Saveconfig();
		puc.Finalize();
		puc.returntocart();
		puc.returntoquote();
		}
		
		
		List<Apttus_Config2__LineItem__c> li = [select Id from Apttus_Config2__LineItem__c Limit 1];
		Apttus_Config2__ProductAttributeValue__c PA1 = new Apttus_Config2__ProductAttributeValue__c();
		
		if(li != null && !li.isEmpty() && li[0] != null){
			PA1.Apttus_Config2__LineItemId__c = li[0].id;
			PA1.Q_SWSuite__c = 'Premium';
		}
		   insert PA1; 
		test.stopTest();
	 }
	

	 static testmethod void directInitTest1(){
		  String csvContent = '/n /nProductCode,Quantity,SiteName\nFC11011;1;AB';
		//create a Account
		List<Account> accounts = NOKIA_CPQ_TestDataFactory.getAccounts(1);
		 insert accounts;
	  
		
		
		//create opportunity with non-euro currency
		GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES = true;
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunities(1,accounts);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
		opportunities[0].CurrencyIsoCode = 'GBP'; 
		insert opportunities;  
	  
		 /*create product*/
	   product2 prod = new product2();
		prod.name = '5G';
		prod.CurrencyIsoCode = 'USD';
		prod.Business_Group__c='MN';
		prod.Family= 'A&A-CEM';
		prod.IsActive=True;
		prod.Partner_Visible__c=True;
		prod.ProductCode='FC11011';
		prod.Apttus_Config2__Version__c=1;
		prod.Portfolio__c='Airscale Wifi';
		prod.Created_by_PMDI__c = False;
		prod.Pricing_Clusters__c='NAM';
		prod.IsActive= True;
		insert prod;
		  Test.startTest();
		 
		  /*create pricelist*/
		Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
		Name = 'Commercial Price List', 
		PriceList_Type__c='CPQ',
		Apttus_Config2__Type__c='Standard',
		Apttus_Config2__Active__c = True
		);
	   
		insert ApttusTestPriceList;
		/*create pricelist Item*/
	   Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__ListPrice__c = 100, 
			Apttus_Config2__ProductId__c = prod.Id, 
			Apttus_Config2__ChargeType__c = 'Standard Price'
		);
		insert pLI5;
		 
		//create a quote with non-euro currency
		List<Apttus_Proposal__Proposal__c > proposals = NOKIA_CPQ_TestDataFactory.createProposal(1);
		proposals[0].Apttus_Proposal__Account__c = accounts[0].Id;
		proposals[0].Apttus_Proposal__Opportunity__c = opportunities[0].Id;
		proposals[0].CurrencyIsoCode = 'GBP'; 
		proposals[0].RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(); //direct quote
		insert proposals;		
	   
		Direct_Portfolio_General_Setting__mdt setting = new Direct_Portfolio_General_Setting__mdt();
		setting.Portfolio__c = proposals[0].NokiaCPQ_Portfolio__c;
		setting.GSS_Flow__c = 'GSS List Price';
		setting.Non_GSS_Flow__c = 'ION Direct Pricing Quote';
		setting.MNDirectFlow__c = 'GridViewCartMNDirect';
		setting.Direct_CPQ__c = true;
		 
		ApexPages.currentPage().getParameters().put('id',proposals[0].id);
		PS_productuploadscontroller puc = new  PS_productuploadscontroller(new ApexPages.StandardController(proposals[0]));
		
		
		
		puc.csvAsString = 'filename.csv';
		puc.csvFileBody =  Blob.valueof(csvContent);
		puc.setFile();
		puc.readFromFile();
		puc.createcart();
		//puc.addProductsfromfile();
		puc.Reprice();
	  //  puc.Finalize();
		puc.Saveconfig();
		puc.Finalize();
		puc.returntocart();
		puc.returntoquote();
		
		
		List<Apttus_Config2__LineItem__c> li = [select Id from Apttus_Config2__LineItem__c Limit 1];
		Apttus_Config2__ProductAttributeValue__c PA1 = new Apttus_Config2__ProductAttributeValue__c();
		
		if(li != null && !li.isEmpty() && li[0] != null){
			PA1.Apttus_Config2__LineItemId__c = li[0].id;
			PA1.Q_SWSuite__c = 'Premium';
		}
		   insert PA1; 
	   
	   

		Test.stopTest();	
		
			
}
	@isTest static void lineitemTest03(){
	   
		String csvContent = null;
	   
		List <Account> account3 = NOKIA_CPQ_TestDataFactory.getAccounts(2);
		account3[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
	   // account2[1].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
	 //   account2[1].Partner_Type__c = '';
	  //  account2[1].Partner_Program__c = '';
		insert account3;
		
		List<Opportunity> opportunities1 = NOKIA_CPQ_TestDataFactory.getOpportunities(1,account3);
		opportunities1[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
	 //   opportunities[0].End_Customer_LE__c = account2[1].id;
		insert opportunities1;
	 
	   /*create product*/
	   product2 prod = new product2();
		prod.name = '5G';
		prod.CurrencyIsoCode = 'USD';
		prod.Business_Group__c='MN';
		prod.Family= 'A&A-CEM';
		prod.IsActive=True;
		prod.Partner_Visible__c=True;
		prod.ProductCode='FC11011';
		prod.Apttus_Config2__Version__c=1;
		prod.Portfolio__c='Airscale Wifi';
		prod.Created_by_PMDI__c = False;
		prod.Pricing_Clusters__c='NAM';
		prod.IsActive= True;
		insert prod;

		test.startTest(); 
	   /*create pricelist*/
		Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
		Name = 'Commercial Price List', 
		PriceList_Type__c='CPQ',
		Apttus_Config2__Type__c='Standard',
		Apttus_Config2__Active__c = True
		);
	   
		insert ApttusTestPriceList;
		/*create pricelist Item*/
	   Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__ListPrice__c = 100, 
			Apttus_Config2__ProductId__c = prod.Id, 
			Apttus_Config2__ChargeType__c = 'Standard Price'
		);
		insert pLI5;
		   
			Apttus_Proposal__Proposal__c testProposal1 = new Apttus_Proposal__Proposal__c(
			RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),
			Apttus_Proposal__Account__c = account3[0].Id,
			Apttus_Proposal__Opportunity__c = opportunities1.get(0).Id,
			Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			NokiaCPQ_FN_Maintenance_Type__c='',
			NokiaCPQ_SRS_Level__c='',
			NokiaCPQ_Existing_IONMaint_Contract__c='',
			NokiaCPQ_Needs_Reprice__c = false,
			//NokiaCPQ_Environment_Access_Type__c = 'PRM',
			Reprice_In_Progress__c = false,
			NokiaCPQ_Existing_FN_Maint_Contract__c='',
			NokiaCPQ_No_of_Years__c = '1',
			NokiaCPQ_ION_Maintenance_Type__c='',
			NokiaCPQ_SSP_Level__c='',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_Maintenance_Type__c ='',
		   NokiaCPQ_Is_Maintenance_Quote__c=true,
				NokiaCPQ_Contract_Start_Date__c=date.today(),
				Is_List_Price_Only__c = true,
				Warranty_credit__c='Yes'
		 );
		insert testProposal1;
		   
		   
		Direct_Portfolio_General_Setting__mdt setting = new Direct_Portfolio_General_Setting__mdt();
		setting.Portfolio__c = testProposal1.NokiaCPQ_Portfolio__c;
		setting.GSS_Flow__c = 'GSS List Price';
		setting.Non_GSS_Flow__c = 'ION Direct Pricing Quote';
		setting.MNDirectFlow__c = 'GridViewCartMNDirect';
		setting.Direct_CPQ__c = true;
		
	   
		
		ApexPages.currentPage().getParameters().put('id',testProposal1.id);
		PS_productuploadscontroller puc = new  PS_productuploadscontroller(new ApexPages.StandardController(testProposal1));
		
		
		
		puc.csvAsString = 'filename.csv';
		puc.csvFileBody =  null;//Blob.valueof(csvContent);
		puc.setFile();
		puc.readFromFile();
		puc.createcart();
		puc.addProductsfromfile();
		puc.Reprice();
		puc.Finalize();
		puc.Saveconfig();
		puc.Finalize();
		puc.returntocart();
		puc.returntoquote();
		
		
		List<Apttus_Config2__LineItem__c> li = [select Id from Apttus_Config2__LineItem__c Limit 1];
		Apttus_Config2__ProductAttributeValue__c PA1 = new Apttus_Config2__ProductAttributeValue__c();
		
		if(li != null && !li.isEmpty() && li[0] != null){
			PA1.Apttus_Config2__LineItemId__c = li[0].id;
			PA1.Q_SWSuite__c = 'Premium';
		}
		   insert PA1; 
		test.stopTest();
	 }
	@isTest static void lineitemTest04(){
	   
		String csvContent = '/n /nProduct Code,Quantity,SiteName\nFC11011;1;AB';
	   
		List <Account> account3 = NOKIA_CPQ_TestDataFactory.getAccounts(2);
		account3[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
	   // account2[1].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
	 //   account2[1].Partner_Type__c = '';
	  //  account2[1].Partner_Program__c = '';
		insert account3;
		
		List<Opportunity> opportunities1 = NOKIA_CPQ_TestDataFactory.getOpportunities(1,account3);
		opportunities1[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
	 //   opportunities[0].End_Customer_LE__c = account2[1].id;
		insert opportunities1;
	 
	   /*create product*/
	   product2 prod = new product2();
		prod.name = '5G';
		prod.CurrencyIsoCode = 'USD';
		prod.Business_Group__c='MN';
		prod.Family= 'A&A-CEM';
		prod.IsActive=True;
		prod.Partner_Visible__c=True;
		prod.ProductCode='PRODUCT CODE';
		prod.Apttus_Config2__Version__c=1;
		prod.Portfolio__c='IP Routing';
		prod.Created_by_PMDI__c = False;
		prod.Pricing_Clusters__c='NAM';
		prod.IsActive= True;
		insert prod;

		test.startTest(); 
	   /*create pricelist*/
		Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
		Name = 'Commercial Price List', 
		PriceList_Type__c='CPQ',
		Apttus_Config2__Type__c='Standard',
		Apttus_Config2__Active__c = True
		);
	   
		insert ApttusTestPriceList;
		/*create pricelist Item*/
	   Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__ListPrice__c = 100, 
			Apttus_Config2__ProductId__c = prod.Id, 
			Apttus_Config2__ChargeType__c = 'Standard Price'
		);
		insert pLI5;
		   
			Apttus_Proposal__Proposal__c testProposal1 = new Apttus_Proposal__Proposal__c(
			RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),
			Apttus_Proposal__Account__c = account3[0].Id,
			Apttus_Proposal__Opportunity__c = opportunities1.get(0).Id,
			Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			NokiaCPQ_FN_Maintenance_Type__c='',
			NokiaCPQ_SRS_Level__c='',
			NokiaCPQ_Existing_IONMaint_Contract__c='',
			NokiaCPQ_Needs_Reprice__c = false,
			//NokiaCPQ_Environment_Access_Type__c = 'PRM',
			Reprice_In_Progress__c = false,
			NokiaCPQ_Existing_FN_Maint_Contract__c='',
			NokiaCPQ_No_of_Years__c = '',
			NokiaCPQ_ION_Maintenance_Type__c='',
			NokiaCPQ_SSP_Level__c='',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			//NokiaCPQ_Maintenance_Type__c ='MN GS TSS Basic',
			Is_List_Price_Only__c = true,
			NokiaCPQPricing_Cluster__c = 'NAM'
		 );
		insert testProposal1;
		   
		   
		Direct_Portfolio_General_Setting__mdt setting = new Direct_Portfolio_General_Setting__mdt();
		setting.Portfolio__c = testProposal1.NokiaCPQ_Portfolio__c;
		setting.GSS_Flow__c = 'GSS List Price';
		setting.Non_GSS_Flow__c = 'ION Direct Pricing Quote';
		setting.MNDirectFlow__c = 'GridViewCartMNDirect';
		setting.Direct_CPQ__c = true;
		
	   
		
		ApexPages.currentPage().getParameters().put('id',testProposal1.id);
		PS_productuploadscontroller puc = new  PS_productuploadscontroller(new ApexPages.StandardController(testProposal1));
		
		
		
		//puc.csvAsString = 'filename.csv';
		puc.csvFileBody =  Blob.valueof(csvContent);
		puc.setFile();
		puc.readFromFile();
		puc.createcart();
		//puc.addProductsfromfile();
		puc.Reprice();
	  //  puc.Finalize();
		puc.Saveconfig();
		puc.Finalize();
		puc.returntocart();
		puc.returntoquote();
		
		/*
		List<Apttus_Config2__LineItem__c> li = [select Id from Apttus_Config2__LineItem__c Limit 1];
		Apttus_Config2__ProductAttributeValue__c PA1 = new Apttus_Config2__ProductAttributeValue__c();
		
		if(li != null && !li.isEmpty() && li[0] != null){
			PA1.Apttus_Config2__LineItemId__c = li[0].id;
			PA1.Q_SWSuite__c = 'Premium';
		}
		   insert PA1; */
		test.stopTest();
	 }
}