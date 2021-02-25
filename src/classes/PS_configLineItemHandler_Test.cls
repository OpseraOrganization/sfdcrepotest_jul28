/************************************************************************************************************
* Apex Class Name   : PS_configLineItemHandler_Test.cls
* Version		   : 1.0 
* Created Date	  : 20 Jul 2017
* Function		  : test class for PS_configLineItemHandler_Test
* Modification Log  :
* Developer				   Date					Description
* -----------------------------------------------------------------------------------------------------------
* Akshay Thorat			   20/07/2017			  Created Test Class for PS_configLineItemHandler_Test
*
************************************************************************************************************/
@isTest(seeAllData =true)
private class PS_configLineItemHandler_Test
{
	private static List<Account> accountList = new List<Account>();
	private static List<Opportunity> opportunityList = new List<Opportunity>();
	
	
	/*Create Dummy Price list*/
	public static Apttus_Config2__PriceList__c createpricelist(string priceListName) {
		Apttus_Config2__PriceList__c pl = new Apttus_Config2__PriceList__c();
		pl.Name=priceListName; 
		return pl;
	}
	
	
	/********** functionality lineitem trigger  ***********/
	@isTest static void lineitemTest(){
		/* String csvContent = 'ProductCode,QTY,\n3HE11467AA,2,\n3HE10218AA,5';
		Apttus_Proposal__Proposal__c proposal = [select ID, Apttus_QPConfig__PriceListId__c from Apttus_Proposal__Proposal__c limit 1];
		ApexPages.currentPage().getParameters().put('id',proposal.id);
		PS_productuploadscontroller puc = new  PS_productuploadscontroller(new ApexPages.StandardController(proposal));
		puc.csvAsString = 'filename.csv';
		puc.csvFileBody =  Blob.valueof(csvContent);
		puc.setFile();
		puc.readFromFile();
		// puc.createcart();
		puc.addProductsfromfile();
		//puc.Reprice();
		puc.Finalize();
		puc.Saveconfig();
		puc.Finalize();
		puc.returntoquote();
		puc.returntocart();
		
		test.startTest();
		List<Apttus_Config2__LineItem__c> li = [select Id from Apttus_Config2__LineItem__c Limit 1];
		Apttus_Config2__ProductAttributeValue__c PA1 = new Apttus_Config2__ProductAttributeValue__c();
		
		if(li != null && !li.isEmpty() && li[0] != null){
			//PA1.Product_Offering__c = 'eBook Only';
			//PA1.CurrencyIsoCode = 'GBP';
			PA1.Apttus_Config2__LineItemId__c = li[0].id;
			PA1.Q_SWSuite__c = 'Premium';
		}
		   insert PA1; 
		   
		test.stopTest(); */
		 
	}
	
	/********** functionality lineitem trigger  ***********/
	@isTest static void lineitemTest1(){
		List<User> sysAdminUser = NOKIA_CPQ_TestDataFactory.userCreation(1,'System Administrator');
		System.runAs(sysAdminUser[0]){
		String csvContent = 'ProductCode,QTY,\n3HE11467AA,2,\n3HE10218AA,5';
		Account account;
		
		account = NF_TestDataFactory.createAccount('30112345');
		List<Account> accounts=new List<Account>();
		accounts.add(account);
		insert accounts; 
		List<opportunity> opportunities = NOKIA_CPQ_TestDataFactory.getOpportunities(1,accounts);
		opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		insert opportunities;
		Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
																							Name = 'Commercial Price List', 
																							Apttus_Config2__Active__c = True
																							);
		insert ApttusTestPriceList;
		//Accrediation creation
	   /*Accreditation__c accred = new Accreditation__c(
			partner__c = account.Id,
			Accreditation_Type__c = 'Product',
			Portfolio__c = 'IP Routing',
			Pricing_Cluster__c = 'NAM',
			Accreditation_Level__c = 'Advanced', 
			Pricing_Level_Override__c = 'Advanced',  
			Accreditation_Date__c = date.today() + 9, 
			Pricing_Override_Expiration__c = date.today() + 9, 
			Actual_pricing_level__c = 'Advanced'
		); 
		insert accred;*/
		
		//create Accreditation
		List<Accreditation__c > accreditations = NOKIA_CPQ_TestDataFactory.createAccreditation(2);
		accreditations[0].partner__c = account.Id;
		accreditations[1].partner__c = account.Id;
		accreditations[1].Accreditation_Type__c = 'Maintenance';
		accreditations[1].Accreditation_Level__c = 'Premium';
		accreditations[1].Pricing_Level_Override__c = 'Premium';   
		insert accreditations;
		
		 Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(
																					 Apttus_Proposal__Account__c = account.Id,
																					 Apttus_Proposal__Opportunity__c = opportunities.get(0).Id,
																					 Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
																					 Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
																					 NokiaCPQ_FN_Maintenance_Type__c='Gold',
			NokiaCPQ_SRS_Level__c='Unlimited',
			NokiaCPQ_Existing_IONMaint_Contract__c='No',
			NokiaCPQ_Existing_FN_Maint_Contract__c='No',
			NokiaCPQ_ION_Maintenance_Type__c='Gold',
			NokiaCPQ_SSP_Level__c='Unlimited',
			RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Proposal').getRecordTypeId(),
			NokiaCPQ_Maintenance_Type__c = '',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c  = '1'
																					);
		insert testProposal;
				if(testProposal.id != Null){

		ApexPages.currentPage().getParameters().put('id',testProposal.id);
		PS_productuploadscontroller puc = new  PS_productuploadscontroller(new ApexPages.StandardController(testProposal));
		puc.csvAsString = 'filename.csv';
		puc.csvFileBody =  Blob.valueof(csvContent);
		puc.setFile();
		puc.readFromFile();
		puc.createcart();
		puc.addProductsfromfile();
		//puc.Reprice();
		puc.Finalize();
		puc.Saveconfig();
		puc.Finalize();
		puc.returntoquote();
		puc.returntocart();
				}
		test.startTest();
		List<Apttus_Config2__LineItem__c> li = [select Id from Apttus_Config2__LineItem__c Limit 1];
		Apttus_Config2__ProductAttributeValue__c PA1 = new Apttus_Config2__ProductAttributeValue__c();
		
		if(li != null && !li.isEmpty() && li[0] != null){
			//PA1.Product_Offering__c = 'eBook Only';
			//PA1.CurrencyIsoCode = 'GBP';
			PA1.Apttus_Config2__LineItemId__c = li[0].id;
			PA1.Q_SWSuite__c = 'Premium';
		}
		   insert PA1; 
		   
		test.stopTest();
		 }
	}
	 @isTest static void setup()
	{
		test.startTest();
		PageReference pageRef = Page.Apttus_QPConfig__ProposalConfiguration; // Add your VF page Name here
		
		Apttus_Proposal__Proposal__c proposal = [select ID, Apttus_QPConfig__PriceListId__c from Apttus_Proposal__Proposal__c limit 1];
		 List<Apttus_Config2__LineItem__c> li = [select Id from Apttus_Config2__LineItem__c Limit 1];
		Apttus_Config2__ProductAttributeValue__c PA1 = new Apttus_Config2__ProductAttributeValue__c();
		
		if(li != null && !li.isEmpty() && li[0] != null){
			//PA1.Product_Offering__c = 'eBook Only';
			//PA1.CurrencyIsoCode = 'GBP';
			PA1.Apttus_Config2__LineItemId__c = li[0].id;
			PA1.Q_SWSuite__c = 'Premium';
		}
		
		
		   insert PA1; 
		/* Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController(proposal);
		PS_productuploadscontroller  puc = new  PS_productuploadscontroller(sc);
		pageRef.getParameters().put('id', String.valueOf(proposal.Id));
		pageRef.getParameters().put('flow','NewUIPartner');
		puc.returntocart(); */
		test.stopTest();
		
	}

}