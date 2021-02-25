@isTest
private class ContractedQuoteTriggerHandlerTest {
	Private static final Id Contracted_Quote_RecId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(Label.CQ_RecordTypeId).getRecordTypeId();
	Private static final Id CQ_Read_Only_RecId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get('CQ_Read_Only').getRecordTypeId();
	private static Id oppDirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.CREATE_DIRECT_SALES_OPPORTUNITY).getRecordTypeId();
	private static  Id LERecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
	private static  Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(); 
	
	public Static List<Apttus_Proposal__Proposal__c> Quotes=new List<Apttus_Proposal__Proposal__c>();
   /*
	@testSetUp
	static void testData() 
	{
		//create QP records
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		PermissionSet permission1 = [SELECT Name, Id, Description, Type 
									 FROM PermissionSet 
									 where name = 'Surround_CQ_Reporting_Data_Access'];
		insert new PermissionSetAssignment(AssigneeId = userCreation.id, PermissionSetId = permission1.Id);
		PermissionSet permission2 =[Select Name, Id, Description, Type 
									FROM PermissionSet 
									where name = 'CQ_Business_admin'];
		insert new PermissionSetAssignment(AssigneeId = userCreation.id, PermissionSetId = permission2.Id);
		System.RunAs(userCreation){
			
			Account[] acc = TestDataFactory.createAccount(1);
			database.insert(acc);
			
			Opportunity opp1 = TestDataFactory.OpportunityCreation(1,acc[0])[0];
			opp1.StageName='Create Offer (Bid)';
			opp1.Phase_Status__c = 'Offer in Progress';
			//opp1.Opportunity_ID__c= '19.857057'; 
			database.insert(opp1);
			
			
			
			Contracted_Quote__c cq1 = new Contracted_Quote__c();
			//cq1.CQ_Number__c = '19.857057.A81';
			database.insert(cq1);
			system.debug('cq1-->'+cq1.Id);
		}
	}
	*/
   /* static testmethod void updateQuotePricing() 
	{
		Test.startTest();
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		
		//PermissionSetAssignment psa = new PermissionSetAssignment();
		//psa.AssigneeId = userCreation.Id;
		//psa.PermissionSetId = 
		//insert psa;
		PermissionSet permission1 = [SELECT Name, Id, Description, Type 
									 FROM PermissionSet 
									 where name = 'Surround_CQ_Reporting_Data_Access'];
		insert new PermissionSetAssignment(AssigneeId = userCreation.id, PermissionSetId = permission1.Id);
		PermissionSet permission2 =[Select Name, Id, Description, Type 
									FROM PermissionSet 
									where name = 'CQ_Business_admin'];
		insert new PermissionSetAssignment(AssigneeId = userCreation.id, PermissionSetId = permission2.Id);
		System.RunAs(userCreation){
			Account acc=[select id from Account limit 1];
			Opportunity opp=[select id,Opportunity_ID__c,Opportunity_Number_Unformatted__c from Opportunity limit 1];
			Apttus_Proposal__Proposal__c cq2 = TestDataFactory.createCQ(1,acc,opp)[0];
			//cq2.NokiaCPQ_Proposal_Id__c= '19.857057.A81';
			database.insert(cq2);
			system.debug('cq2-->'+cq2.Id + ' '+cq2.NokiaCPQ_Proposal_Id__c);
			
			List<Contracted_Quote__c> cqList = new List<Contracted_Quote__c>();
			
			
			//Create a record in Contracted Quote for which CQ does not exists in sCPQ
			Contracted_Quote__c cq = new Contracted_Quote__c();
			//cq.CQ_Number__c ='19.857057.A89';
			cq.CQ_Value__c = 123.00;
			cq.CurrencyIsoCode = 'USD';
			cq.Initial_Pricing_Date__c = system.today();
			cq.Ready_for_Submission__c = system.today() + 1;
			cq.Expiration_Date__c = system.today() + 2;
			cq.Surround_Master_Quote__c = true;
			cq.Surround_QTC_Code__c = '7000987'; 
			cqList.add(cq);
			
			//update a record for which CQ exists in SCPQ
			Contracted_Quote__c cq1 = [Select Id, cq_Number__c from Contracted_Quote__c where cq_Number__c = '19.857057.A81'];
			//cq1.cq_Number__c = '19.857057.A81';
			cq1.cq_Value__c = 123.00;
			cq1.CurrencyIsoCode = 'USD';
			cq1.Initial_Pricing_Date__c = system.today();
			cq1.Ready_for_Submission__c = system.today() + 1;
			cq1.Expiration_Date__c = system.today() + 2;
			cq1.Surround_Master_Quote__c = true;
			cq1.Surround_QTC_Code__c = '8000405';
			cqList.add(cq1);
			
			
			Database.UpsertResult[] dt=Database.upsert(cqList);
			system.debug('saveresult-->'+dt);
			system.debug('Contracted Quote Insert:'+[Select Id,NokiaCPQ_Proposal_Id__c from Apttus_Proposal__Proposal__c] );
			system.debug('Contracted Quote Update:'+[Select Id,cq_Number__c from Contracted_Quote__c] );
			system.debug('cq1-->'+cq1);
			system.debug('cqlist-->'+cqlist[0]+''+cqlist[1]);
			
			
			/*Check in CQ reporting whether the first created record exists
Surround_CQ_Reporting__c cqReporting = [Select Id, CQ_Number__c 
From Surround_CQ_Reporting__c 
where CQ_Number__c = :cq.CQ_Number__c
limit 1];
system.debug('cqrep-->'+cqReporting.Id);
//system.assert(cqReporting!=null);

//Check whether the status of the second CQ changed to approved and pricing updates are available
Apttus_Proposal__Proposal__c scq = [select id, NokiaCPQ_Proposal_Id__c,Apttus_Proposal__Approval_Stage__c 
From Apttus_Proposal__Proposal__c
where NokiaCPQ_Proposal_Id__c = :cq1.CQ_Number__c];
system.debug('scq-->'+scq);
// system.assertEquals(GlobalConstants.CQ_STATUS_APPROVED, scq.Apttus_Proposal__Approval_Stage__c,'Approval stage is not changed');
//system.assertEquals(cq1.cq_Value__c, scq.CQ_Value__c, 'Pricing update not done');
			Test.stopTest();
		}
		
		
	}
	
  
	 static testmethod void updateQuoteStatusSuccess() 
	{
		
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		PermissionSet permission1 = [SELECT Name, Id, Description, Type 
									 FROM PermissionSet 
									 where name = 'Surround_CQ_Reporting_Data_Access'];
		insert new PermissionSetAssignment(AssigneeId = userCreation.id, PermissionSetId = permission1.Id);
		PermissionSet permission2 =[Select Name, Id, Description, Type 
									FROM PermissionSet 
									where name = 'CQ_Business_admin'];
		insert new PermissionSetAssignment(AssigneeId = userCreation.id, PermissionSetId = permission2.Id);
		System.RunAs(userCreation){
			Test.startTest();
			Account acc=[select id from Account limit 1];
			Opportunity opp=[select id,Opportunity_ID__c,Opportunity_Number_Unformatted__c from Opportunity limit 1];
			Apttus_Proposal__Proposal__c scq = TestDataFactory.createCQ(1,acc,opp)[0];
			//scq.NokiaCPQ_Proposal_Id__c= '19.857057.A81A1';
			scq.Apttus_Proposal__Approval_Stage__c ='Approved';  
			scq.CQ_eQuote__c = true;
			scq.CQ_eQuote_Status__c = GlobalConstants.IN_PROGRESS;
			scq.CQ_Customer_Organization_Segment__c = 'Verizon';
			Database.insert(scq);
			
			Contracted_Quote__c cq1 = [Select Id, cq_Number__c from Contracted_Quote__c where cq_Number__c = '19.857057.A81'];
			cq1.eQuote_Error__c = 'Accepted the quote';
			database.update(cq1);
			
			//system.assertEquals(GlobalConstants.SUCCESS,scq.CQ_eQuote_Status__c,'Equote message is not updated');
			Test.stopTest();  
		}
		
	}
	
	static testmethod void updateQuoteStatusFailure() 
	{
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		PermissionSet permission1 = [SELECT Name, Id, Description, Type 
									 FROM PermissionSet 
									 where name = 'Surround_CQ_Reporting_Data_Access'];
		insert new PermissionSetAssignment(AssigneeId = userCreation.id, PermissionSetId = permission1.Id);
		PermissionSet permission2 =[Select Name, Id, Description, Type 
									FROM PermissionSet 
									where name = 'CQ_Business_admin'];
		insert new PermissionSetAssignment(AssigneeId = userCreation.id, PermissionSetId = permission2.Id);
		System.RunAs(userCreation){
			Test.startTest();
			Account acc=[select id from Account limit 1];
			Opportunity opp=[select id,Opportunity_ID__c,Opportunity_Number_Unformatted__c from Opportunity limit 1];
			Apttus_Proposal__Proposal__c scq = TestDataFactory.createCQ(1,acc,opp)[0];
			//scq.NokiaCPQ_Proposal_Id__c= '19.857057.A81';
			scq.Apttus_Proposal__Approval_Stage__c ='Approved';  
			scq.CQ_eQuote__c = true;
			scq.CQ_Customer_Organization_Segment__c = 'Verizon';
			scq.CQ_eQuote_Status__c = GlobalConstants.IN_PROGRESS;
			Database.insert(scq);
			
			Contracted_Quote__c cq1 = [Select Id, cq_Number__c from Contracted_Quote__c where cq_Number__c = '19.857057.A81'];
			cq1.eQuote_Error__c = 'Failed';
			database.update(cq1);
			
			//system.assertEquals(GlobalConstants.FAILURE,scq.CQ_eQuote_Status__c,'Equote message is not updated');
			Test.stopTest();}
	}
	*/
	
	/* static testmethod void TestData2()
{
user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
insert userCreation;
System.RunAs(userCreation){

Account accountNoNvzw = NF_TestDataFactory.createAccount('1TestNONVZW0000');
accountNoNvzw.RecordTypeId=custRecordTypeId;
Account accountNoNvzw_LegalEnt = NF_TestDataFactory.createAccount('10308719999AISIS');
List<Account> accounts=new List<Account>();
accounts.add(accountNoNvzw);
Database.insert(accounts);

accountNoNvzw_LegalEnt.Accountnumber='1323242223i';
accountNoNvzw_LegalEnt.Recordtypeid=LERecordTypeId;
accountNoNvzw_LegalEnt.ParentId=accounts[0].Id;
accountNoNvzw_LegalEnt.Default_Legal_Entity__c = true;
accountNoNvzw_LegalEnt.Partner_Program__c=null;

accounts.add(accountNoNvzw_LegalEnt);
Database.upsert(accounts);

Opportunity OpportunityNonVZW = NF_TestDataFactory.createOpportunity(accounts[0].Id, 'Create offer (bid)', 'Offer in Progress', Date.today().addDays(10), 7000000);
OpportunityNonVZW.Lead_BG__c='NSW';
OpportunityNonVZW.RecordTypeId = oppDirectRecordTypeId;
OpportunityNonVZW.Business_Type__c = 'Standard Opportunity';

List<opportunity> opportunities=new List<opportunity>();
opportunities.add(OpportunityNonVZW);
Database.insert(opportunities);




Apttus_Proposal__Proposal__c Quote_ObjNoNVZW = new Apttus_Proposal__Proposal__c(
RecordtypeId=Contracted_Quote_RecId,NokiaCPQ_Proposal_Id__c= '19.857057.A81',
CQ_Value__c=100,
Apttus_Proposal__Proposal_Expiration_Date__c=system.today(),
CQ_eQuote_Status__c='failure',
Apttus_Proposal__Proposal_Name__c = 'quote',Apttus_Proposal__Approval_Stage__c = 'Approved',
Apttus_Proposal__Account__c = accounts[0].Id,
Account_Legal_Entity__c=accounts[2].Id,
Apttus_Proposal__Opportunity__c = opportunities[0].Id,
Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
isCQ__C=true,
CQ_Documents_Attached__c=true,
CQ_Due_Date__c  =system.Today()+30		 
);

Quotes.add(Quote_ObjNoNVZW);
Database.insert(Quotes);

Test.startTest();
Apttus_Proposal__Proposal__c NonvZWQuote=[Select Id ,NokiaCPQ_Proposal_Id__c,Apttus_Proposal__Account__c,Account_Legal_Entity__r.Qtc_sold_to__c from Apttus_Proposal__Proposal__c Where Account_Legal_Entity__r.Qtc_sold_to__c!=:system.Label.VzW_Number Limit 1];
List<Contracted_Quote__c> cqList = new List<Contracted_Quote__c>();


//Create a record in Contracted Quote for which CQ does not exists in sCPQ
Contracted_Quote__c cq = new Contracted_Quote__c();
cq.CQ_Number__c = NonvZWQuote.NokiaCPQ_Proposal_Id__c;
cq.CQ_Value__c = 123.00;
cq.CurrencyIsoCode = 'USD';
cq.Initial_Pricing_Date__c = system.today();
cq.Ready_for_Submission__c = system.today() + 1;
cq.Expiration_Date__c = system.today() + 2;
cq.Surround_Master_Quote__c = true;
cq.Surround_QTC_Code__c = '700987'; 
cqList.add(cq);
Database.insert(cqList); 

Test.stopTest();
}
}*/
	 static testmethod void uInt() 
	{
		
		test.startTest();
		ContractedQuoteTriggerHandler.createErrorInterfaceLogs('Surround Files','Testclass','Testclass','Testclass');
		ContractedQuoteTriggerHandler.createErrorInterfaceLogs(null,'Testclass','Testclass','Testclass');
		ContractedQuoteTriggerHandler.createSuccessInterfaceLogs('Surround Files','Testclass','Testclass');
		ContractedQuoteTriggerHandler.createSuccessInterfaceLogs(null,'Testclass','Testclass');
		test.stopTest();
	}
	static testmethod void insertCQ(){
		Map<String,Apttus_Proposal__Proposal__c> quoteMap=new Map<String,Apttus_Proposal__Proposal__c>();
		List<Apttus_Proposal__Proposal__c> li=new List<Apttus_Proposal__Proposal__c>();
		test.startTest();
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		PermissionSet permission1 = [SELECT Name, Id, Description, Type 
									 FROM PermissionSet 
									 where name = 'Surround_CQ_Reporting_Data_Access'];
		insert new PermissionSetAssignment(AssigneeId = userCreation.id, PermissionSetId = permission1.Id);
		PermissionSet permission2 =[Select Name, Id, Description, Type 
									FROM PermissionSet 
									where name = 'CQ_Business_admin'];
		insert new PermissionSetAssignment(AssigneeId = userCreation.id, PermissionSetId = permission2.Id);
		 System.RunAs(userCreation){
			Account[] acc = TestDataFactory.createAccount(1);
			database.insert(acc);
			
			Opportunity opp1 = TestDataFactory.OpportunityCreation(1,acc[0])[0];
			opp1.StageName='Create Offer (Bid)';
			opp1.Phase_Status__c = 'Offer in Progress';
			opp1.Opportunity_ID__c= '19..857057'; 
			database.insert(opp1);
			 
			 Apttus_Proposal__Proposal__c cq2 = TestDataFactory.createCQ(1,acc[0],opp1)[0];
			 cq2.NokiaCPQ_Proposal_Id__c = '19..857057.A00A';
			 li.add(cq2);
			 insert cq2;
			 SYstem.debug('cq2::> '+cq2);
			 List<Contracted_Quote__c> cqList = new List<Contracted_Quote__c>();
			List<Contracted_Quote__c> cqList2 = new List<Contracted_Quote__c>();
			
			//Create a record in Contracted Quote for which CQ does not exists in sCPQ
			Contracted_Quote__c cq = new Contracted_Quote__c();
			cq.CQ_Number__c ='19..857057.A00A';
			cq.CQ_Value__c = 123.00;
			cq.CurrencyIsoCode = 'USD';
			cq.Initial_Pricing_Date__c = system.today();
			cq.Ready_for_Submission__c = system.today() + 1;
			cq.Expiration_Date__c = system.today() + 2;
			cq.Surround_Master_Quote__c = true;
			cq.Surround_QTC_Code__c = '7000987'; 
			cqList.add(cq);
			insert cqList;
			 cq.CQ_Value__c=125.00;
			 cqList2.add(cq);
			 update cqList2;
			 quotemap.put(cq2.NokiaCPQ_Proposal_Id__c,cq2);
			 ContractedQuoteTriggerHandler.updateQuoteStatus(cq,quotemap);
			 ContractedQuoteTriggerHandler.updateQuoteStatus(null,null);
			 ContractedQuoteTriggerHandler.updateQuoteinQP(li,'CQ UpdateQuote/Status');
			 ContractedQuoteTriggerHandler.updateQuoteinQP(li,'CQ UpdateQuote/Pricing');
			 ContractedQuoteTriggerHandler.updateQuoteinQP(null,'CQ UpdateQuote/Pricing');
			 ContractedQuoteTriggerHandler.updateQuotePricing(cq,quotemap);
			  ContractedQuoteTriggerHandler.checkSurroundCQ(null,null);
			 test.stopTest();
			 
		 }
		
	}
}