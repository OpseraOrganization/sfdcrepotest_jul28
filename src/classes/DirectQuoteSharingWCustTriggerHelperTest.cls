@IsTest(SeeAllData=true) 
public class DirectQuoteSharingWCustTriggerHelperTest {
 private static  Id LERecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
	private static  Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(); 
	private static Id oppDirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.CREATE_DIRECT_SALES_OPPORTUNITY).getRecordTypeId();
	 private static  Id QuoteRecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get(CSWXGlobalConstant.QuoteRecordType).getRecordTypeId();
/*
	 static testMethod void QuoteSharing(){
		  Test.startTest();
		List<Account> accounts=new List<Account>();
		Account Customeraccount = NF_TestDataFactory.createAccount('1TestNONV0000');
		Customeraccount.RecordTypeId=custRecordTypeId;
		 Customeraccount.DMP_Account__c=true;
		accounts.add(Customeraccount);
		Database.insert(accounts);
		
		Account LegalEntityaccount = NF_TestDataFactory.createAccount('10308719999AIA');
		LegalEntityaccount.Accountnumber='1323242223i';
		LegalEntityaccount.Recordtypeid=LERecordTypeId;
		LegalEntityaccount.ParentId=accounts[0].Id;
		LegalEntityaccount.Default_Legal_Entity__c = true;
		LegalEntityaccount.Partner_Program__c=null;
		accounts.add(LegalEntityaccount);
		Database.upsert(accounts); 
		
		Opportunity Opportunity_v1= NF_TestDataFactory.createOpportunity(accounts[0].Id, 'Execute (Start Delivery)', 'In Execution', Date.today().addDays(10), 7000000);
		Opportunity_v1.Lead_BG__c='NSW';
		Opportunity_v1.Opportunity_ID__c='19.IN.856951';
		Opportunity_v1.RecordTypeId = oppDirectRecordTypeId;
		Opportunity_v1.Business_Type__c = 'Standard Opportunity';
		
		Database.insert(Opportunity_v1);
		   
		List<Apttus_Config2__PriceList__c> priceListObj = TestDataFactory.priceList(1);
		priceListObj[0].Apttus_Config2__AccountId__c = LegalEntityaccount.id;
		priceListObj[0].Type__c  = 'CXM';
		database.insert(priceListObj[0]);
		
			   Apttus__APTS_Agreement__c agreementobj= new Apttus__APTS_Agreement__c();
		agreementobj.Apttus__Agreement_Number__c='00000024';
		agreementobj.Name= 'New demo';
		agreementobj.Apttus__Account__c = accounts[1].id;
		agreementobj.CurrencyIsoCode = 'EUR';
		agreementobj.Delivery_System__c = 'Scratch Order via P20';
		agreementobj.ERP__c = 'P20';
		agreementobj.Sales_Mode__c = 'Corporate Sales Mode';
		agreementobj.Confidence_Level__c = 'Low Level';
		agreementobj.Apttus__Contract_Start_Date__c=System.today();
		agreementobj.Apttus__Contract_End_Date__c=System.today()+30;
		agreementobj.Apttus_CMConfig__PriceListId__c = priceListObj[0].id;
		database.insert(agreementobj);
		 Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};

		 Contact ContactDS = new Contact(lastName=CSWXGlobalConstant.ContactNameDS,AccountId=accounts[0].id,Email=CSWXGlobalConstant.EmailContactNameDS );
		 database.insert(ContactDS);
				  User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
User newUser;
		 System.runAs ( thisUser ) {
UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType =:'CustomerPortal' limit 1];
Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
 
newUser = new User(
UserRoleId = ur.Id,
profileId = p.id,
username = 'newUser@yahoo.com',
email = 'pb@ff.com',
emailencodingkey = 'UTF-8',
localesidkey = 'en_US',
languagelocalekey = 'en_US',
timezonesidkey = 'America/Los_Angeles',
alias='nuser',
lastname='lastname',
contactId = ContactDS.id
);
database.insert(newUser,false);  
}
					
	   List <Apttus_Proposal__Proposal__c> QPList = new List<Apttus_Proposal__Proposal__c>();
		 Apttus_Proposal__Proposal__c Quote=new Apttus_Proposal__Proposal__c();
				  Quote.RecordTypeId=QuoteRecordTypeId;
				  Quote.Sold_To_Party__c=accounts[1].id;
		  Quote.Apttus_Proposal__Account__c =accounts[0].id;
				  Quote.Agreement_Lookup__c=agreementobj.id;
				  Quote.Apttus_Proposal__Opportunity__c=Opportunity_v1.id;
				  Quote.Analytics_Source__c='CXM';
				  Quote.Analytics_File_Refer_ID__c= 'LTE AIR Interface AR';
				  Quote.Apttus_Proposal__Approval_Stage__c='Approved';
				  Quote.Creation_Date__c=System.today();
				  Quote.Proposal_Recommendation_Type__c='SW Recommendation';
				  Quote.Contract_Start_Date__c=System.today();
				  Quote.Contract_End_Date__c=System.today()+30;
				  Quote.LOA_Status__c='Approved';
						   QPList.add(Quote);
		 Database.insert(QPList);
			 QPList[0].Revision_Status__c='Revision';
	  DirectQuoteSharingWCustTriggerHelper.shareDirectQuoteWithCustomer(QPList);
		Test.stopTest(); 

	 }
	*/
	static testMethod void QuoteSharing1(){
		Test.startTest();
		USer user1 = [Select Id,Profile.Name,Name,ContactID,AccountId from User where  isPortalEnabled = True and isActive = True and AccountId!=null and ContactID!=null  and contact.Account.DMP_Account__c =True and contact.Account.Active__c=true and (UserType = 'PowerCustomerSuccess' or UserType ='CustomerSuccess')   limit 1];
		 Account LegalEntityaccount = [Select id From Account Where RecordtypeId=:LERecordTypeId  AND Parentid=:user1.AccountId AND Active__c = true  limit 1 ];
			
		
		/* Account LegalEntityaccount = NF_TestDataFactory.createAccount('10308719999AIA');
		LegalEntityaccount.Accountnumber='1323242223i';
		LegalEntityaccount.Recordtypeid=LERecordTypeId;
		LegalEntityaccount.ParentId=user1.AccountId;
		LegalEntityaccount.Default_Legal_Entity__c = true;
		LegalEntityaccount.Partner_Program__c=null;
		LegalEntityaccount.Active__c = true;
		Database.insert(LegalEntityaccount); */
		
		
		  Opportunity Opportunity_v1= NF_TestDataFactory.createOpportunity(user1.AccountId, 'Execute (Start Delivery)', 'In Execution', Date.today().addDays(10), 7000000);
		Opportunity_v1.Lead_BG__c='NSW';
		Opportunity_v1.Opportunity_ID__c='19.IN.856951';
		Opportunity_v1.RecordTypeId = oppDirectRecordTypeId;
		Opportunity_v1.Business_Type__c = 'Standard Opportunity';
		Opportunity_v1.Legal_Entity__c=LegalEntityaccount.id;
		Opportunity_v1.End_Customer_LE__c=LegalEntityaccount.id;
		Database.insert(Opportunity_v1);
		
		 List <Apttus_Proposal__Proposal__c> QPList = new List<Apttus_Proposal__Proposal__c>();
		 Apttus_Proposal__Proposal__c Quote=new Apttus_Proposal__Proposal__c();
				  Quote.RecordTypeId=QuoteRecordTypeId;
				  Quote.Sold_To_Party__c=LegalEntityaccount.id;
		  Quote.Apttus_Proposal__Account__c =user1.AccountId;
				 // Quote.Agreement_Lookup__c=agreementobj.id;
				  Quote.Apttus_Proposal__Opportunity__c=Opportunity_v1.id;
				  Quote.Analytics_Source__c='CXM';
				  Quote.Analytics_File_Refer_ID__c= 'LTE AIR Interface AR';
				  Quote.Apttus_Proposal__Approval_Stage__c='Approved';
				  Quote.Creation_Date__c=System.today();
				  Quote.Proposal_Recommendation_Type__c='SW Recommendation';
				  Quote.Contract_Start_Date__c=System.today();
				  Quote.Contract_End_Date__c=System.today()+30;
				  Quote.LOA_Status__c='Approved';
						   QPList.add(Quote);
		 Database.insert(QPList);
			 QPList[0].Revision_Status__c='Revision';
	  DirectQuoteSharingWCustTriggerHelper.shareDirectQuoteWithCustomer(QPList);
		Test.stopTest();
	}
}