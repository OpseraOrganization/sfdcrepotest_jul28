/****************************************
 * Class Name : PSR_Approval_ApprovalNotificationTest
 * Created Date: 5th June 2017
 * Created By : Accenture
 * Last Modified by: Accenture
 * Last Modified Date: 
 * Description : Test class for PSR_Approval_ApprovalNotification_Comp Class
 *****************************************/

 @isTest
Private class PSR_Approval_ApprovalNotificationTest{
	 /******************************
	*Method Name:  Notification
	*Description: Test Method to cover Approval_ApprovalNotification_Comp
	
	********************************/
	
	
	 private static User testUser = NF_TestDataFactory.createAdminUser('System Administrator');
	private static User CurrentUser = NF_TestDataFactory.createAdminUser('System Administrator');
	Private static User sysAdminUser = NF_TestDataFactory.createAdminUser('System Administrator');
	Private Static List<User> Userlist =new List<User>();
	private static List<OpportunityTeamMember> opptyTeamMemberList = new List<OpportunityTeamMember>(); 
  
	private static Account currentAccount;
	private static Opportunity currentOpportunity;
	private static Id upsellDealId = Schema.SObjectType.Deal__c.getRecordTypeInfosByName().get('Upsell Deal').getRecordTypeId();
	private static Deal__c upsellDeal;
	private static Opportunity currentOpportunityC1;
	Private Static  List<Opportunity> Opplist=new List<Opportunity>();
	Private Static List<Apttus_Approval__Approval_Request__c> Approvalrequest;
	Private Static List<Offer__c> offerList = new List<Offer__c>();
	 Private Static List<Offer__c> offerListEmp = new List<Offer__c>();
	 Private Static  List<Opportunity> OpplistEmp=new List<Opportunity>();

	
	
	 static testMethod void Notification(){
		Userlist.add(testUser);
		 Userlist.add(sysAdminUser);
	 Database.insert(Userlist);	 
	 System.runAs(sysAdminUser){
	 NCP_CustomerCommunitySetting__c cs = new NCP_CustomerCommunitySetting__c();
		cs.Name = 'Default';
		cs.Customer_Account__c = 'Customer - test';
		cs.Customer_Account_Number__c = '12345';
		cs.Customer_User_Profile__c = 'Customers';
		insert cs;
	 
	 List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		database.insert(fileSharingCustomSettingList); 
	 DateTime dT = System.now();
   Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
	 
	 
	  currentAccount = NF_TestDataFactory.createAccount('132456783');
	currentAccount.BillingState='Ontario';
		 
		insert currentAccount;
		upsellDeal = TestDataFactory.createDeal(1)[0];
		upsellDeal.RecordTypeId = upsellDealId;
		insert upsellDeal;
		
		currentOpportunity = NF_TestDataFactory.createOpportunity(currentAccount.Id, 'Develop Opportunity', 'Opportunity in Progress', Date.today().addDays(10), 700);
			
		//currentOpportunity.Organisation_Level_5__c = 'LAT GCBT CARSO';
		//currentOpportunity.Organisation_Level_4__c = 'Market Latin America';
		currentOpportunity.NF_Facilitator_Notified__c=false;
	 currentOpportunity.Business_Type__c='Committed Upsell';
		currentOpportunity.Apttus_Approval__Approval_Status__c='Pending Approval'; 
		//currentOpportunity.Deal__c = upsellDeal.Id;
		//currentOpportunity.Phase_Status__c='Submitted for G3 Approval';   
		opplist.add(currentOpportunity);
		
		Insert  opplist;
		
		 opptyTeamMemberList = TestDataFactory.optyTeamMemberCreation(1,Userlist[0],opplist[0]);
			database.insert(opptyTeamMemberList);
		
		Approvalrequest=NF_TestDataFactory.getApprovalRequests(1,opplist,Userlist);
		Test.startTest();
		insert Approvalrequest;
			//Creating Offer
			Offer__c offerCreation = TestDataFactory.OfferCreation(1,currentOpportunity)[0];
			offerCreation.ActiveOffer__c = True;
			offerCreation.Expected_LoA_G4_Approval_Level__c='c';
			offerCreation.Customer_Offer_Due_Date__c =myDate ;					
			offerList.add(offerCreation);
			insert offerList;	 
		
	
		
		Approvalrequest=NF_TestDataFactory.getApprovalRequests(1,opplist,Userlist);
		
		database.insert(Approvalrequest);
		
		
		PSR_Approval_ApprovalNotification_Comp notification = new PSR_Approval_ApprovalNotification_Comp();
		
		notification.OppId=currentOpportunity.id;
		notification.Opp=currentOpportunity;
		notification.Off=offerCreation;
		notification.CTname='Test';
		notification.getOpp();
		 notification.getOff();
		 notification.getCTname();
		 Approvalrequest=notification.oppApprovalRequests;
		 
		 
		 //Empty Pass 
		 
	
		PSR_Approval_ApprovalNotification_Comp notification1 = new PSR_Approval_ApprovalNotification_Comp();
		
		notification1.OppId=Null;
		notification1.Opp=Null;
		notification1.Off=Null;
		notification1.CTname='Test';
		notification1.getOpp();
		 notification1.getOff();
		 notification1.getCTname();
		 notification1.oppApprovalRequests=Null;

		 Test.stopTest();
		 
	
		 
	
		 }
	
	
	
	}
	
 }