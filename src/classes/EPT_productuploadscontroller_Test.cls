@isTest(seeAllData =true)
private class EPT_productuploadscontroller_Test
{
	
	private static List<Account> accountList = new List<Account>();
	private static List<Opportunity> opportunityList = new List<Opportunity>();
	public static String[] csvFileLines;
	public static Blob csvFileBody;
	
	@isTest static void lineitemTest1(){
		//String csvContent = 'ProductCode,Quantity,SiteName\n 3HE10479AA,1,A\n 3HE05936CG,1,B\n 3HE05936CF,1,C D';
	   List<User> sysAdminUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'System Administrator');
	   System.runAs(sysAdminUser[0]){
	   String csvContent = 'Acronym,Orderable Item,APN,Price,TOTALS,Pune,Mumbai,Delhi\nCOSKIT,"Main Shelf Kit (incl. COSHF, USRPNL, FAN, TIBNKx2)",3HE10869BA,(-),10,1,1,1\n COEKIT,"Extension Shelf Kit (incl COSHF, UPBNK, FAN, TIBNKx2)",3HE10477AA,(-),18,3,1,1\n  COEKIT2,"Extension Shelf Kit2 (incl COSHF2, UPBNK2, FAN2, TIBNKx22)",3HE10869AAAA,(-),18,3,1,1\n COEKIT3,"Extension Shelf Kit2 (incl COSHF3, UPBNK3, FAN3, TIBNKx33)",3HE10869XX,(-),18,3,1,1';
	   
		List<Opportunity> opportunities;
		
		List <Account> account2 = NOKIA_CPQ_TestDataFactory.getAccounts(2);
		account2[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
		account2[1].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		account2[1].Partner_Type__c = '';
		account2[1].Partner_Program__c = '';
		insert account2;
		
		product2 prod = new product2();
		prod.name = 'A';
		prod.CurrencyIsoCode = 'USD';
		prod.Business_Group__c='NSW';
		prod.Family= 'A&A-CEM';
		prod.IsActive=True;
		prod.Partner_Visible__c=True;
		prod.ProductCode='3HE10869BA';
		prod.Apttus_Config2__Version__c= 1;
		prod.Portfolio__c= 'Optics';
		prod.Pricing_Clusters__c='NAM';
		prod.IsActive= True;
		insert prod;
		
		product2 prod1 = new product2();
		prod1.name = 'A2';
		prod1.CurrencyIsoCode = 'USD';
		prod1.Business_Group__c='NSW';
		prod1.Family= 'A&A-CEM';
		prod1.IsActive=True;
		prod1.Partner_Visible__c=True;
		prod1.ProductCode='3HE10869AAAA';
		prod1.Apttus_Config2__Version__c= 1;
		prod1.Portfolio__c= 'Optics';
		prod1.Pricing_Clusters__c='NAM';
		prod1.IsActive= True;
		insert prod1;
		
		product2 prod3 = new product2();
		prod3.name = 'A3';
		prod3.CurrencyIsoCode = 'USD';
		prod3.Business_Group__c='NSW';
		prod3.Family= 'A&A-CEM';
		prod3.IsActive=True;
		prod3.Partner_Visible__c=True;
		prod3.ProductCode='3HE10869XX';
		prod3.Apttus_Config2__Version__c= 1;
		prod3.Portfolio__c= 'Optics';
		prod3.Pricing_Clusters__c='NAM';
		prod3.IsActive= True;
		insert prod3;
		
		Accreditation__c accreditation1 = new Accreditation__c(Accreditation_Type__c='Product',
										Accreditation_Date__c = date.today(),
										Accreditation_Level__c='Advanced',
										Partner__c=account2[0].Id,
										Portfolio__c='Optics',
										Pricing_Cluster__c='NAM'				
				);
				
		insert accreditation1;
		
		/*Accreditation__c accreditation2 = new Accreditation__c(Accreditation_Type__c='Maintenance',
										Accreditation_Date__c = date.today(),
										Accreditation_Level__c='Authorized',
										Partner__c=account2[0].Id,
										Portfolio__c='Optics - Wavelite',
										Pricing_Cluster__c='NAM'				
				);
				
		insert accreditation2; */
		
		accreditation1.app_name__c = 'Q2C_'+ accreditation1.Portfolio__c;
		update accreditation1;
		
		opportunities = NOKIA_CPQ_TestDataFactory.getOpportunities(1,account2);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunities[0].End_Customer_LE__c = account2[1].id;
		insert opportunities;
		
		Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(Name ='Commercial Price List', Apttus_Config2__Active__c = True);
		insert ApttusTestPriceList;
		
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
			//NokiaCPQ.Opportunity_Type__c = 'Dummy Opportunity',
			NokiaCPQ_SSP_Level__c='',
			//NokiaCPQ_Portfolio__c = 'Optics - Wavelite',
			NokiaCPQ_Maintenance_Type__c =''
		 
		 );
		insert testProposal;
		
		Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c();
			ProdConfig.Name = 'APTTUS Test Config'; 
			//ProdConfig.Apttus_Config2__AccountId__c = account.Id
			ProdConfig.Apttus_QPConfig__Proposald__c = testProposal.id;
			ProdConfig.Apttus_Config2__Status__c = 'Finalized';
			ProdConfig.Apttus_Config2__VersionNumber__c = 1;
			ProdConfig.Apttus_Config2__BusinessObjectType__c = 'Proposal';
		
		insert ProdConfig;  
		
		NokiaCPQ_Site__c site = new NokiaCPQ_Site__c();
		site.Opportunity__c = opportunities.get(0).Id;
		site.name = 'test  test';
		insert site;
		
		Test.StartTest();
		ApexPages.currentPage().getParameters().put('id',testProposal.id);
		EPT_productuploadscontroller puc = new  EPT_productuploadscontroller(new ApexPages.StandardController(testProposal));
		puc.selectedSource = 'Wavelite';
		puc.csvAsString = 'filename.csv';
		puc.csvFileBody =  Blob.valueof(csvContent);
		puc.getsourceType();
	   // puc.setFile();
	   
		puc.readFromFile();
		puc.createcart();
		puc.addProductsfromfile();
		
		puc.Reprice();
		puc.getisCSV();
		puc.Finalize();
		puc.Saveconfig();
		puc.setCSVFile();
		Test.StopTest();
		puc.returntoquote();
		puc.returntocart();
		
	  }
	}
	
   @isTest static void lineitemTest2(){
	   List<User> sysAdminUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'System Administrator');
	   System.runAs(sysAdminUser[0]){
	   String csvContent = 'Acronym;Orderable Item;APN,Price,TOTALS,Pune,Mumbai,Delhi\n ,"Main Shelf Kit (incl. COSHF, USRPNL, FAN, TIBNKx2)",3HE10869BA,(-),10,1,1,1\n "Extension Shelf Kit (incl COSHF, UPBNK, FAN, TIBNKx2)",3HE10477AA,(-),18,3,1,1\n,"Extension Shelf Kit2 (incl COSHF2, UPBNK2, FAN2, TIBNKx22)",3HE10869AAAA,(-),18,3,1,1\n,"Extension Shelf Kit2 (incl COSHF3, UPBNK3, FAN3, TIBNKx33)",3HE10869XX,(-);18;3;1;1';
	   
		List<Opportunity> opportunities;
		
		List <Account> account2 = NOKIA_CPQ_TestDataFactory.getAccounts(2);
		account2[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
		account2[1].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		account2[1].Partner_Type__c = '';
		account2[1].Partner_Program__c = '';
		insert account2;
		
		product2 prod = new product2();
		prod.name = 'A';
		prod.CurrencyIsoCode = 'USD';
		prod.Business_Group__c='NSW';
		prod.Family= 'A&A-CEM';
		prod.IsActive=True;
		prod.Partner_Visible__c=True;
		prod.ProductCode='3HE10869BA';
		prod.Apttus_Config2__Version__c= 1;
		prod.Portfolio__c= 'Optics';
		prod.Pricing_Clusters__c='NAM';
		prod.IsActive= True;
		insert prod;
		
		product2 prod1 = new product2();
		prod1.name = 'A2';
		prod1.CurrencyIsoCode = 'USD';
		prod1.Business_Group__c='NSW';
		prod1.Family= 'A&A-CEM';
		prod1.IsActive=True;
		prod1.Partner_Visible__c=True;
		prod1.ProductCode='3HE10869AAAA';
		prod1.Apttus_Config2__Version__c= 1;
		prod1.Portfolio__c= 'Optics';
		prod1.Pricing_Clusters__c='NAM';
		prod1.IsActive= True;
		insert prod1;
		
		product2 prod3 = new product2();
		prod3.name = 'A3';
		prod3.CurrencyIsoCode = 'USD';
		prod3.Business_Group__c='NSW';
		prod3.Family= 'A&A-CEM';
		prod3.IsActive=True;
		prod3.Partner_Visible__c=True;
		prod3.ProductCode='3HE10869XX';
		prod3.Apttus_Config2__Version__c= 1;
		prod3.Portfolio__c= 'Optics';
		prod3.Pricing_Clusters__c='NAM';
		prod3.IsActive= True;
		insert prod3;
		
		Accreditation__c accreditation1 = new Accreditation__c(Accreditation_Type__c='Product',
										Accreditation_Date__c = date.today(),
										Accreditation_Level__c='Advanced',
										Partner__c=account2[0].Id,
										Portfolio__c='Optics',
										Pricing_Cluster__c='NAM'				
				);
				
		insert accreditation1;
		
		/*Accreditation__c accreditation2 = new Accreditation__c(Accreditation_Type__c='Maintenance',
										Accreditation_Date__c = date.today(),
										Accreditation_Level__c='Authorized',
										Partner__c=account2[0].Id,
										Portfolio__c='Optics - Wavelite',
										Pricing_Cluster__c='NAM'				
				);
				
		insert accreditation2; */
		
		accreditation1.app_name__c = 'Q2C_'+ accreditation1.Portfolio__c;
		update accreditation1;
		
		opportunities = NOKIA_CPQ_TestDataFactory.getOpportunities(1,account2);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunities[0].End_Customer_LE__c = account2[1].id;
		insert opportunities;
		
		Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(Name ='Commercial Price List', Apttus_Config2__Active__c = True);
		insert ApttusTestPriceList;
		
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
			//NokiaCPQ.Opportunity_Type__c = 'Dummy Opportunity',
			NokiaCPQ_SSP_Level__c='',
			//NokiaCPQ_Portfolio__c = 'Optics - Wavelite',
			NokiaCPQ_Maintenance_Type__c =''
		 
		 );
		insert testProposal;
		
		Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c();
			ProdConfig.Name = 'APTTUS Test Config'; 
			//ProdConfig.Apttus_Config2__AccountId__c = account.Id
			ProdConfig.Apttus_QPConfig__Proposald__c = testProposal.id;
			ProdConfig.Apttus_Config2__Status__c = 'Finalized';
			ProdConfig.Apttus_Config2__VersionNumber__c = 1;
			ProdConfig.Apttus_Config2__BusinessObjectType__c = 'Proposal';
		
		insert ProdConfig;  
		
		NokiaCPQ_Site__c site = new NokiaCPQ_Site__c();
		site.Opportunity__c = opportunities.get(0).Id;
		site.name = 'test  test';
		insert site;
		
		Test.StartTest();
		ApexPages.currentPage().getParameters().put('id',testProposal.id);
		EPT_productuploadscontroller puc = new  EPT_productuploadscontroller(new ApexPages.StandardController(testProposal));
		puc.selectedSource = 'Wavelite';
		puc.csvAsString = 'filename.csv';
		puc.csvFileBody =  Blob.valueof(csvContent);
		puc.getsourceType();
	   // puc.setFile();
		
		puc.readFromFile();
		puc.createcart();
		puc.addProductsfromfile();
		
		puc.Reprice();
		puc.getisCSV();
		puc.Finalize();
		puc.Saveconfig();
		puc.setCSVFile();
		Test.StopTest();
		puc.returntoquote();
		puc.returntocart();
		
	  }
	}  
	
	 @isTest static void lineitemTest3(){
	   List<User> sysAdminUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'System Administrator');
	   System.runAs(sysAdminUser[0]){
	   String csvContent = '"Acronym","Orderable Item","APN","Price","TOTALS","Pune","Mumbai","Delhi"\n ,"Main Shelf Kit (incl. COSHF, USRPNL, FAN, TIBNKx2)","3HE10869BA","(-)","10","1","1","1"\n "Extension Shelf Kit (incl COSHF, UPBNK, FAN, TIBNKx2)","3HE10477AA","(-)","18","3","1","1"\n,"Extension Shelf Kit2 (incl COSHF2, UPBNK2, FAN2, TIBNKx22)","3HE10869AAAA","(-)","18","3","1","1"\n,"Extension Shelf Kit2 (incl COSHF3, UPBNK3, FAN3, TIBNKx33)","3HE10869XX","(-)","18","3","1","1"';
	   
		List<Opportunity> opportunities;
		
		List <Account> account2 = NOKIA_CPQ_TestDataFactory.getAccounts(2);
		account2[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
		account2[1].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		account2[1].Partner_Type__c = '';
		account2[1].Partner_Program__c = '';
		insert account2;
		
		product2 prod = new product2();
		prod.name = 'A';
		prod.CurrencyIsoCode = 'USD';
		prod.Business_Group__c='NSW';
		prod.Family= 'A&A-CEM';
		prod.IsActive=True;
		prod.Partner_Visible__c=True;
		prod.ProductCode='3HE10869BA';
		prod.Apttus_Config2__Version__c= 1;
		prod.Portfolio__c= 'Optics';
		prod.Pricing_Clusters__c='NAM';
		prod.IsActive= True;
		insert prod;
		
		product2 prod1 = new product2();
		prod1.name = 'A2';
		prod1.CurrencyIsoCode = 'USD';
		prod1.Business_Group__c='NSW';
		prod1.Family= 'A&A-CEM';
		prod1.IsActive=True;
		prod1.Partner_Visible__c=True;
		prod1.ProductCode='3HE10869AAAA';
		prod1.Apttus_Config2__Version__c= 1;
		prod1.Portfolio__c= 'Optics';
		prod1.Pricing_Clusters__c='NAM';
		prod1.IsActive= True;
		insert prod1;
		
		product2 prod3 = new product2();
		prod3.name = 'A3';
		prod3.CurrencyIsoCode = 'USD';
		prod3.Business_Group__c='NSW';
		prod3.Family= 'A&A-CEM';
		prod3.IsActive=True;
		prod3.Partner_Visible__c=True;
		prod3.ProductCode='3HE10869XX';
		prod3.Apttus_Config2__Version__c= 1;
		prod3.Portfolio__c= 'Optics';
		prod3.Pricing_Clusters__c='NAM';
		prod3.IsActive= True;
		insert prod3;
		
		Accreditation__c accreditation1 = new Accreditation__c(Accreditation_Type__c='Product',
										Accreditation_Date__c = date.today(),
										Accreditation_Level__c='Advanced',
										Partner__c=account2[0].Id,
										Portfolio__c='Optics',
										Pricing_Cluster__c='NAM'				
				);
				
		insert accreditation1;
		
		/*Accreditation__c accreditation2 = new Accreditation__c(Accreditation_Type__c='Maintenance',
										Accreditation_Date__c = date.today(),
										Accreditation_Level__c='Authorized',
										Partner__c=account2[0].Id,
										Portfolio__c='Optics - Wavelite',
										Pricing_Cluster__c='NAM'				
				);
				
		insert accreditation2; */
		
		accreditation1.app_name__c = 'Q2C_'+ accreditation1.Portfolio__c;
		update accreditation1;
		
		opportunities = NOKIA_CPQ_TestDataFactory.getOpportunities(1,account2);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunities[0].End_Customer_LE__c = account2[1].id;
		insert opportunities;
		
		Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(Name ='Commercial Price List', Apttus_Config2__Active__c = True);
		insert ApttusTestPriceList;
		
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
			//NokiaCPQ.Opportunity_Type__c = 'Dummy Opportunity',
			NokiaCPQ_SSP_Level__c='',
			//NokiaCPQ_Portfolio__c = 'Optics - Wavelite',
			NokiaCPQ_Maintenance_Type__c =''
		 
		 );
		insert testProposal;
		
		Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c();
			ProdConfig.Name = 'APTTUS Test Config'; 
			//ProdConfig.Apttus_Config2__AccountId__c = account.Id
			ProdConfig.Apttus_QPConfig__Proposald__c = testProposal.id;
			ProdConfig.Apttus_Config2__Status__c = 'Finalized';
			ProdConfig.Apttus_Config2__VersionNumber__c = 1;
			ProdConfig.Apttus_Config2__BusinessObjectType__c = 'Proposal';
		
		insert ProdConfig;  
		
		NokiaCPQ_Site__c site = new NokiaCPQ_Site__c();
		site.Opportunity__c = opportunities.get(0).Id;
		site.name = 'test  test';
		insert site;
		
		Test.StartTest();   
		ApexPages.currentPage().getParameters().put('id',testProposal.id);
		EPT_productuploadscontroller puc = new  EPT_productuploadscontroller(new ApexPages.StandardController(testProposal));
		puc.selectedSource = 'Wavelite';
		puc.csvAsString = 'filename.csv';
		puc.csvFileBody =  Blob.valueof(csvContent);
		puc.getsourceType();
	   // puc.setFile();
		
		puc.readFromFile();
		puc.createcart();
		puc.addProductsfromfile();
		
		puc.Reprice();
		puc.getisCSV();
		puc.Finalize();
		puc.Saveconfig();
		puc.setCSVFile();
		Test.StopTest();
		puc.returntoquote();
		puc.returntocart();
		
	  }
	}

@isTest static void lineitemTest4(){
	   List<User> sysAdminUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'System Administrator');
	   System.runAs(sysAdminUser[0]){
	   String csvContent = 'Acronym,Orderable Item,APN,Price,TOTALS,Pune,Mumbai,Delhi\n,Main Shelf Kit (incl. COSHF, USRPNL, FAN, TIBNKx2),3HE10869BA,(-),10,1,1,1\n Extension Shelf Kit (incl COSHF, UPBNK, FAN, TIBNKx2),3HE10477AA,(-),18,3,1,1\n,Extension Shelf Kit2 (incl COSHF2, UPBNK2, FAN2, TIBNKx22),3HE10869AAAA,(-),18,3,1,1\n,Extension Shelf Kit2 (incl COSHF3, UPBNK3, FAN3, TIBNKx33),3HE10869XX,(-),18,3,1,1';
	   
		List<Opportunity> opportunities;
		
		List <Account> account2 = NOKIA_CPQ_TestDataFactory.getAccounts(2);
		account2[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
		account2[1].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		account2[1].Partner_Type__c = '';
		account2[1].Partner_Program__c = '';
		insert account2;
		
		product2 prod = new product2();
		prod.name = 'A';
		prod.CurrencyIsoCode = 'USD';
		prod.Business_Group__c='NSW';
		prod.Family= 'A&A-CEM';
		prod.IsActive=True;
		prod.Partner_Visible__c=True;
		prod.ProductCode='3HE10869BA';
		prod.Apttus_Config2__Version__c= 1;
		prod.Portfolio__c= 'Optics';
		prod.Pricing_Clusters__c='NAM';
		prod.IsActive= True;
		insert prod;
		
		product2 prod1 = new product2();
		prod1.name = 'A2';
		prod1.CurrencyIsoCode = 'USD';
		prod1.Business_Group__c='NSW';
		prod1.Family= 'A&A-CEM';
		prod1.IsActive=True;
		prod1.Partner_Visible__c=True;
		prod1.ProductCode='3HE10869AAAA';
		prod1.Apttus_Config2__Version__c= 1;
		prod1.Portfolio__c= 'Optics';
		prod1.Pricing_Clusters__c='NAM';
		prod1.IsActive= True;
		insert prod1;
		
		product2 prod3 = new product2();
		prod3.name = 'A3';
		prod3.CurrencyIsoCode = 'USD';
		prod3.Business_Group__c='NSW';
		prod3.Family= 'A&A-CEM';
		prod3.IsActive=True;
		prod3.Partner_Visible__c=True;
		prod3.ProductCode='3HE10869XX';
		prod3.Apttus_Config2__Version__c= 1;
		prod3.Portfolio__c= 'Optics';
		prod3.Pricing_Clusters__c='NAM';
		prod3.IsActive= True;
		insert prod3;
		
		Accreditation__c accreditation1 = new Accreditation__c(Accreditation_Type__c='Product',
										Accreditation_Date__c = date.today(),
										Accreditation_Level__c='Advanced',
										Partner__c=account2[0].Id,
										Portfolio__c='Optics',
										Pricing_Cluster__c='NAM'				
				);
				
		insert accreditation1;
		
		/*Accreditation__c accreditation2 = new Accreditation__c(Accreditation_Type__c='Maintenance',
										Accreditation_Date__c = date.today(),
										Accreditation_Level__c='Authorized',
										Partner__c=account2[0].Id,
										Portfolio__c='Optics - Wavelite',
										Pricing_Cluster__c='NAM'				
				);
				
		insert accreditation2; */
		
		accreditation1.app_name__c = 'Q2C_'+ accreditation1.Portfolio__c;
		update accreditation1;
		
		opportunities = NOKIA_CPQ_TestDataFactory.getOpportunities(1,account2);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunities[0].End_Customer_LE__c = account2[1].id;
		insert opportunities;
		
		Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(Name ='Commercial Price List', Apttus_Config2__Active__c = True);
		insert ApttusTestPriceList;
		
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
			//NokiaCPQ.Opportunity_Type__c = 'Dummy Opportunity',
			NokiaCPQ_SSP_Level__c='',
			//NokiaCPQ_Portfolio__c = 'Optics - Wavelite',
			NokiaCPQ_Maintenance_Type__c =''
		 
		 );
		insert testProposal;
		
		Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c();
			ProdConfig.Name = 'APTTUS Test Config'; 
			//ProdConfig.Apttus_Config2__AccountId__c = account.Id
			ProdConfig.Apttus_QPConfig__Proposald__c = testProposal.id;
			ProdConfig.Apttus_Config2__Status__c = 'Finalized';
			ProdConfig.Apttus_Config2__VersionNumber__c = 1;
			ProdConfig.Apttus_Config2__BusinessObjectType__c = 'Proposal';
		
		insert ProdConfig;  
		
		NokiaCPQ_Site__c site = new NokiaCPQ_Site__c();
		site.Opportunity__c = opportunities.get(0).Id;
		site.name = 'test  test';
		insert site;
		
		Test.StartTest();
		ApexPages.currentPage().getParameters().put('id',testProposal.id);
		EPT_productuploadscontroller puc = new  EPT_productuploadscontroller(new ApexPages.StandardController(testProposal));
		puc.selectedSource = 'Wavelite';
		puc.csvAsString = 'filename.csv';
		puc.csvFileBody =  Blob.valueof(csvContent);
		puc.getsourceType();
	   // puc.setFile();
		
		puc.readFromFile();
		puc.createcart();
		puc.addProductsfromfile();
		
		puc.Reprice();
		puc.getisCSV();
		puc.Finalize();
		puc.Saveconfig();
		puc.setCSVFile();
		Test.StopTest();
		puc.returntoquote();
		puc.returntocart();
		
	  }
	}   
}