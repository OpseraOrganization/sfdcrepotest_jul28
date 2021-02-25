/**
 * @name	NF_ApprovalRequestTest
 * @author   
 * @since   July 08, 2017
 * @desc	This class helps to code coverrage to the NF_ApprovalRequest Class
 * @history 
 */

@isTest
private class NF_ApprovalRequestTest{
	 
	Private static NCP_CustomerCommunitySetting__c cs = new NCP_CustomerCommunitySetting__c();
	
	private static User testUser = NF_TestDataFactory.createAdminUser('System Administrator');
	private static User testUser1 = NF_TestDataFactory.createAdminUser('System Administrator');
	private static User testUser2 = NF_TestDataFactory.createAdminUser('System Administrator');
	private static User testUser3 = NF_TestDataFactory.createAdminUser('System Administrator');
	private static User testUser4 = NF_TestDataFactory.createAdminUser('System Administrator');


	private static Account currentAccount;
	private static Opportunity currentOpportunity;
	private static Opportunity currentOpportunity1;
	private static Opportunity currentOpportunity2;
	private static Opportunity currentOpportunity3;
	private static Opportunity currentOpportunity4;
	private static Apttus_Approval__Approval_Request__c currentApprovalRequest;
	 private static Apttus_Approval__Approval_Request__c currentApprovalRequest1;
	 private static Apttus_Approval__Approval_Request__c currentApprovalRequest2;
	 private static Apttus_Approval__Approval_Request__c currentApprovalRequest3;
	 private static Apttus_Approval__Approval_Request__c currentApprovalRequest4;
	private static Sales_Role__c currentSalesOrg;
	private static Apttus_Approval__ApprovalRuleAssignee__c ruleAssignee;
	  private static Apttus_Approval__ApprovalRuleAssignee__c ruleAssignee1;
	private static Apttus_Approval__ApprovalRuleAssignee__c ruleAssignee2;
	private static Apttus_Approval__ApprovalRuleAssignee__c ruleAssignee3;
	private static Apttus_Approval__ApprovalRuleAssignee__c ruleAssignee4;
	Private Static List<Apttus_Approval__Approval_Request__c> CurrentRequest=new  List<Apttus_Approval__Approval_Request__c>();
	 
	public static void setup(){
		List<User> userList = new List<User>();
		 
		userList.add(testUser1);
		userList.add(testUser2);
		userList.add(testUser3);
		userList.add(testUser4);
		insert userList;
	
		
	
		
		
		
		currentAccount = NF_TestDataFactory.createAccount('132456783');
		currentAccount.L4Name__c = 'LAT CARSO CT CO';
		insert currentAccount;

		List<Opportunity> opportunityList = new List<Opportunity>();
		currentOpportunity = NF_TestDataFactory.createOpportunity(currentAccount.Id, 'Develop Opportunity', 'Opportunity in Progress', Date.today().addDays(10), 700);
		//currentOpportunity.Organisation_Level_4__c = 'LAT CARSO CT CO';
		currentOpportunity.lead_bg__c = 'NSW';
		opportunityList.add(currentOpportunity);
		
		
		 currentOpportunity1= NF_TestDataFactory.createOpportunity(currentAccount.Id, 'Develop Opportunity', 'Opportunity in Progress', Date.today().addDays(10), 700);
		//currentOpportunity1.Organisation_Level_4__c = 'LAT CARSO CT CO';
		currentOpportunity1.lead_bg__c = 'NSW';
		opportunityList.add(currentOpportunity1);
		
		
		
		currentOpportunity2 = NF_TestDataFactory.createOpportunity(currentAccount.Id, 'Develop Opportunity', 'Opportunity in Progress', Date.today().addDays(10), 700);
		//currentOpportunity2.Organisation_Level_4__c = 'LAT CARSO CT CO';
		currentOpportunity2.lead_bg__c = 'NSW';
		opportunityList.add(currentOpportunity2);
		
	//	currentOpportunity2.Phase_Status__c='Submitted for G3 Approval';
	  //  currentOpportunity2.StageName='Develop Opportunity';
		//opportunityList.add(currentOpportunity2);
	 //Update currentOpportunity2 ;
		
		currentOpportunity3 = NF_TestDataFactory.createOpportunity(currentAccount.Id, 'Develop Opportunity', 'Opportunity in Progress', Date.today().addDays(10), 700);
		//currentOpportunity2.Organisation_Level_4__c = 'LAT CARSO CT CO';
		currentOpportunity3.lead_bg__c = 'NSW';
		opportunityList.add(currentOpportunity3);
		
		currentOpportunity4 = NF_TestDataFactory.createOpportunity(currentAccount.Id, 'Develop Opportunity', 'Opportunity in Progress', Date.today().addDays(10), 700);
		opportunityList.add(currentOpportunity4);
		insert opportunityList;
		
		opportunityList[3].Phase_Status__c='Submitted for G3 Approval';
		opportunityList[3].StageName='Develop Opportunity';
	// Update currentOpportunity3 ;
		
		opportunityList[4].Country__c='Canada';
		opportunityList[4].Lead_BG__c='FN';
	// opportunityList[4].Lead_BU__c='ION IPR';
		//opportunityList[4].Supporting_BG_AA__c='NSW';
	// opportunityList[4].Supporting_BG_FN__c='FN';
	// opportunityList[4].Supporting_BG_ION__c='ION';
		//opportunityList[4].Supporting_BG_MN__c='MN';
	// opportunityList[4].Supporting_BG_GS__c='GS';
		//opportunityList[4].Supporting_BU_ION__c='ION Video';
	//  Update currentOpportunity4;
		Update opportunityList;
		
		Offer__c off = TestDataFactory.OfferCreation(1,currentOpportunity4)[0];
		//insert off;
		
		currentSalesOrg = NF_TestDataFactory.createSalesRole(testUser, 'NSNC_BM', 'LAT CARSO CT CO', '4 - RBC Presales Head AA G3 MU');
		insert currentSalesOrg;
		Apttus_Approval__ApprovalRule__c appRule = NF_TestDataFactory.createApprovalRule('rule class C1', true, 'Opportunity', 'Condition', 1);
		insert appRule;

		Apttus_Approval__ApprovalRuleEntry__c ruleEntry = NF_TestDataFactory.createRuleEntry(appRule.Id, 1);
		insert ruleEntry;
	 
		String assigneeValue2 = 'Sales_Role__c (Role_Code__c =\'NMS%D_BM \' AND O__c =\':Org_L4__c\' AND Active__c=true).User__c';

		String assigneeValue1 = 'Sales_Role__c (Role_Code__c =\'NSN%C_BM\' AND O__c =\':Org_L4__c\' AND Active__c=true).User__c';
		String assigneeValue ='Sales_Role__c(Role_Code__c=\'NSN%C_BM\' AND ( O__c =\':Org_L4__c\' OR __c =\':Org_L5__c\' OR O__c =\':Org_L6__c\' OR O__c =\':Org_L7__c\') AND Active__c=true).User__c';
		String assigneeValue3 ='Sales_Role__c(Role_Code__c=\'NSN%C_BM\' AND ( O__c =\':Org_L4__c\' OR __c =\':Org_L5__c\' OR O__c =\':Org_L6__c\' OR O__c =\':Org_L7__c\') AND Active__c=true and BG__c=\'NSW\').User__c';
		
		List<Apttus_Approval__ApprovalRuleAssignee__c> AssigneeList = new List<Apttus_Approval__ApprovalRuleAssignee__c>();
		ruleAssignee = NF_TestDataFactory.createArAssignee(ruleEntry.Id, 1, true, false, assigneeValue);
		ruleAssignee.Apttus_Approval__AssigneeDescription__c = 'NSNC_BM, Validator';
		AssigneeList.add(ruleAssignee);
		
		ruleAssignee1 = NF_TestDataFactory.createArAssignee(ruleEntry.Id, 1, true, false, assigneeValue1);
		ruleAssignee1.Apttus_Approval__AssigneeDescription__c = 'NSNC_BM, Validator';
		AssigneeList.add(ruleAssignee1);
		
		
		ruleAssignee2 = NF_TestDataFactory.createArAssignee(ruleEntry.Id, 1, true, false, assigneeValue2);
	ruleAssignee2.Apttus_Approval__AssigneeDescription__c = 'NMSD_BM, Validator';
		AssigneeList.add(ruleAssignee2);
		
		ruleAssignee3 = NF_TestDataFactory.createArAssignee(ruleEntry.Id, 1, true, false, assigneeValue2);
		ruleAssignee3.Apttus_Approval__AssigneeDescription__c = 'NMSE_BM, Approver';
		AssigneeList.add(ruleAssignee3);
		
		ruleAssignee4 = NF_TestDataFactory.createArAssignee(ruleEntry.Id, 1, true, false, assigneeValue3);
		ruleAssignee4.Apttus_Approval__AssigneeDescription__c = 'NMSG_BM, Validator';
		AssigneeList.add(ruleAssignee4);
		insert AssigneeList;
		
		ruleAssignee = [Select Id, Name, Apttus_Approval__AssigneeDescription__c from Apttus_Approval__ApprovalRuleAssignee__c where Id = :ruleAssignee.Id];
		
		ruleAssignee1 = [Select Id, Name, Apttus_Approval__AssigneeDescription__c from Apttus_Approval__ApprovalRuleAssignee__c where Id = :ruleAssignee1.Id];
	 
		ruleAssignee2 = [Select Id, Name, Apttus_Approval__AssigneeDescription__c from Apttus_Approval__ApprovalRuleAssignee__c where Id = :ruleAssignee2.Id];
		ruleAssignee3 = [Select Id, Name, Apttus_Approval__AssigneeDescription__c from Apttus_Approval__ApprovalRuleAssignee__c where Id = :ruleAssignee3.Id];
		ruleAssignee4 = [Select Id, Name, Apttus_Approval__AssigneeDescription__c from Apttus_Approval__ApprovalRuleAssignee__c where Id = :ruleAssignee4.Id];

		
		currentApprovalRequest = NF_TestDataFactory.createApprovalRequest('Notified', 'User', 'Opportunity', opportunityList[0].Id, true, false, testUser.FirstName+''+testUser.LastName, testUser.Id, AssigneeList[0].Name);
		currentApprovalRequest.Apttus_Approval__DelegateApproverIds__c=testUser.Id+','+testUser1.Id;
		currentApprovalRequest.NF_Assignee_Type__c='Validator';
		currentApprovalRequest.NF_Remaindercount__c=0;
		CurrentRequest.add(currentApprovalRequest);
		
		currentApprovalRequest1 = NF_TestDataFactory.createApprovalRequest('Notified', 'User', 'Opportunity', opportunityList[1].Id, true, false, testUser.FirstName+''+testUser.LastName, userList[0].Id, AssigneeList[1].Name);
		currentApprovalRequest1 .NF_Assignee_Type__c='Approver';
		currentApprovalRequest1 .Apttus_Approval__Approval_Status__c='Submitted';
		currentApprovalRequest1.Apttus_Approval__DelegateApproverIds__c=testUser.Id+','+userList[1].Id;
		CurrentRequest.add(currentApprovalRequest1);
	  
		 
		currentApprovalRequest2 = NF_TestDataFactory.createApprovalRequest('Assigned', 'User', 'Opportunity', opportunityList[2].Id, true, false, testUser.FirstName+''+testUser.LastName, userList[1].Id, AssigneeList[2].Name);
		currentApprovalRequest2.NF_Assignee_Type__c='Approver';
		currentApprovalRequest2.Apttus_Approval__Approval_Status__c='Submitted';
		currentApprovalRequest2.Apttus_Approval__DelegateApproverIds__c=testUser.Id+','+userList[2].Id;
		CurrentRequest.add(currentApprovalRequest2);
		
		currentApprovalRequest3 = NF_TestDataFactory.createApprovalRequest('Notified', 'User', 'Opportunity', opportunityList[3].Id, true, false, testUser.FirstName+''+testUser.LastName, userList[2].Id, AssigneeList[3].Name);
		currentApprovalRequest3.Apttus_Approval__DelegateApproverIds__c=testUser.Id+','+userList[0].Id;
		currentApprovalRequest3.NF_Assignee_Type__c='Validator';
		currentApprovalRequest3.Validator_Status__c='Validated';
		currentApprovalRequest3.NF_Remaindercount__c=0;
		CurrentRequest.add(currentApprovalRequest3);
		
		currentApprovalRequest4 = NF_TestDataFactory.createApprovalRequest('Assigned', 'User', 'Opportunity', opportunityList[4].Id, true, false, testUser.FirstName+''+testUser.LastName, userList[3].Id, AssigneeList[4].Name);
		currentApprovalRequest4.NF_Assignee_Type__c='Stakeholder for Information';
		currentApprovalRequest4.Apttus_Approval__Approval_Status__c='Notified';
		currentApprovalRequest4.Apttus_Approval__DelegateApproverIds__c=testUser.Id+','+userList[2].Id;
		CurrentRequest.add(currentApprovalRequest4);
	 
		Database.insert(CurrentRequest);
	 

	}
	
	  @isTest static void NF_ApprovlRequestHandlerTest() {
	 cs.Name = 'Default';
		cs.Customer_Account__c = 'Customer - test';
		cs.Customer_Account_Number__c = '12345';
		cs.Customer_User_Profile__c = 'Customers';
		insert cs;
		system.runAs(testUser){
		 
	
			setup();
	 Test.startTest();
	 
	NF_ApprovalRequest.getDelegateApprovers(CurrentRequest);
		 NF_ApprovalRequest.getAssignedId(null);
	 NF_ApprovalRequest.createOpportunityTeamMembers(CurrentRequest);
	 NF_ApprovalRequest.Opptysharing(CurrentRequest);
			NF_ApprovalRequest.getNotificationUsersList(CurrentRequest);
		//  NF_ApprovalRequest.getNotificationUsersList(currentApprovalRequest4);

			NF_ApprovalRequest.getApproverNotification(null);
	NF_ApprovalRequest.getApproverNotification(CurrentRequest);
	CurrentRequest.get(0).NF_Assignee_Type__c='Approver';
	CurrentRequest.get(0).Apttus_Approval__Approval_Status__c='Submitted';
	 CurrentRequest.get(1).NF_Assignee_Type__c='Approver';
	CurrentRequest.get(1).Apttus_Approval__Approval_Status__c='Reassigned';
	update CurrentRequest;
	 NF_ApprovalRequest.getApproverNotification(CurrentRequest);
	 
	
	 
			CurrentRequest.get(0).NF_Assignee_Type__c='Validator';
	CurrentRequest.get(0).Apttus_Approval__Approval_Status__c='Approved';
	 CurrentRequest.get(1).NF_Assignee_Type__c='Validator';
	CurrentRequest.get(1).Apttus_Approval__Approval_Status__c='Approved';
	CurrentRequest.get(2).NF_Assignee_Type__c='Approver';
	CurrentRequest.get(2).Apttus_Approval__Approval_Status__c='Submitted';
	CurrentRequest.get(3).NF_Assignee_Type__c='Approver';
	CurrentRequest.get(3).Apttus_Approval__Approval_Status__c='Submitted';
	
	update CurrentRequest;
	
	 NF_ApprovalRequest.TotalValidator=2;
	 NF_ApprovalRequest.ValidatorCompletion=2;
	 NF_ApprovalRequest.EmailTemplate=Label.NF_G3_Validation_Completion_Email;
	
	NF_ApprovalRequest.getNotificationUsersList(CurrentRequest);
	 
			Test.stopTest();
			}
			
	}  
	
	
	
	 @isTest static void NF_ApprovlRequestHandlerChatterpost() {
	cs.Name = 'Default';
		cs.Customer_Account__c = 'Customer - test';
		cs.Customer_Account_Number__c = '12345';
		cs.Customer_User_Profile__c = 'Customers';
		insert cs;
		system.runAs(testUser){
		 
		 Set<ID> Remid=new Set<ID>();
	
			setup();
	 Test.startTest();
	 for(Apttus_Approval__Approval_Request__c Appreq:CurrentRequest)	 {
	 Remid.add(Appreq.ID);
	 }
	 
	 NF_ApprovalRequest.Remindupdate(Remid);
	 
	 NF_ApprovalRequest.ChatterPostToG5StakeHolders(CurrentRequest);
	 //create offer
	NF_ApprovalRequest.Remindupdate(Null);
	 
	 NF_ApprovalRequest.ChatterPostToG5StakeHolders(Null);
	 Test.stopTest();
	 
	 }
		 }  
	
	
	
	
	
   }