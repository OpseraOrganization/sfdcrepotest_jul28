@isTest
private class NF_TL_UpdateHistoryRequestRCodeTest {
	
	private static User testUser = NF_TestDataFactory.createAdminUser('System Administrator');
	private static User testUser2 = NF_TestDataFactory.createAdminUser('System Administrator');
	private static Account currentAccount;
	private static Opportunity currentOpportunity;
	private static Opportunity currentOpportunity1;
	private static Opportunity currentOpportunity2;
	private static Opportunity currentOpportunity3;
	private static Sales_Role__c currentSalesOrg;
	private static Sales_Role__c currentSalesOrg1;
	private static Sales_Role__c currentSalesOrg2;
	private static Apttus_Approval__ApprovalRuleAssignee__c ruleAssignee;
	private static Apttus_Approval__ApprovalRuleAssignee__c ruleAssignee1;
	private static Apttus_Approval__ApprovalRuleAssignee__c ruleAssignee2;
	private static Apttus_Approval__ApprovalRuleAssignee__c ruleAssignee3;
	 
	Private Static List<Apttus_Approval__Approval_Request_History__c > CurrentRequest=new  List<Apttus_Approval__Approval_Request_History__c >();
	
	private static Apttus_Approval__Approval_Request_History__c currentApprovalRequest;
	private static Apttus_Approval__Approval_Request_History__c currentApprovalRequest1;
	private static Apttus_Approval__Approval_Request_History__c currentApprovalRequest2;
	private static Apttus_Approval__Approval_Request_History__c currentApprovalRequest3;
	 
	 

	public static void setup(){
	
	insert testUser2;
	
		 
		
		currentAccount = NF_TestDataFactory.createAccount('132456783');
		currentAccount.L4Name__c = 'LAT CARSO CT CO';
		insert currentAccount;

		List<Opportunity> oppList = new List<Opportunity>();
		currentOpportunity = NF_TestDataFactory.createOpportunity(currentAccount.Id, 'Develop Opportunity', 'Opportunity in Progress', Date.today().addDays(10), 700);
		//currentOpportunity.Organisation_Level_4__c = 'LAT CARSO CT CO';
		currentOpportunity.lead_bg__c = 'NSW';
		oppList.add(currentOpportunity);
		
		currentOpportunity1= NF_TestDataFactory.createOpportunity(currentAccount.Id, 'Develop Opportunity', 'Opportunity in Progress', Date.today().addDays(10), 700);
		//currentOpportunity1.Organisation_Level_4__c = 'LAT CARSO CT CO';
		currentOpportunity1.lead_bg__c = 'NSW';
		oppList.add(currentOpportunity1);
		
		currentOpportunity2 = NF_TestDataFactory.createOpportunity(currentAccount.Id, 'Develop Opportunity', 'Opportunity in Progress', Date.today().addDays(10), 700);
		//currentOpportunity2.Organisation_Level_4__c = 'LAT CARSO CT CO';
		currentOpportunity2.lead_bg__c = 'ION';
		currentOpportunity2.lead_bu__c = 'ION IPR';
		oppList.add(currentOpportunity2);
		
		currentOpportunity2.Phase_Status__c='Submitted for G3 Approval';
		currentOpportunity2.StageName='Develop Opportunity';
	 //Update currentOpportunity2 ;
		insert oppList;
		
		//List<Sales_Role__c> salesRoleList = new List<Sales_Role__c>();
		currentSalesOrg = NF_TestDataFactory.createSalesRole(testUser, 'NSNC_BM', 'LAT CARSO CT CO', '4 - RBC Presales Head AA G3 MU');
		insert currentSalesOrg;
		currentSalesOrg1 = NF_TestDataFactory.createSalesRole(testUser, 'NSNC_BM', 'LAT CARSO CT CO', '4 - RBC Presales Head AA G3 MU');
		CurrentSalesOrg1.BG__c='NSW';
		insert currentSalesOrg1;
		currentSalesOrg2 = NF_TestDataFactory.createSalesRole(testUser2, 'NSNC_BM', 'LAT CARSO CT CO', '4 - RBC Presales Head AA G3 MU');
		CurrentSalesOrg2.BG__c='ION';
		insert currentSalesOrg2;
		//salesRoleList.add(currentSalesOrg);
		//salesRoleList.add(currentSalesOrg1);
		//salesRoleList.add(currentSalesOrg2);
		//insert salesRoleList; 
		
		Apttus_Approval__ApprovalRule__c appRule = NF_TestDataFactory.createApprovalRule('rule class C1', true, 'Opportunity', 'Condition', 1);
		insert appRule;

		List<Apttus_Approval__ApprovalRuleEntry__c> ruleEntryList = new List<Apttus_Approval__ApprovalRuleEntry__c>();
		Apttus_Approval__ApprovalRuleEntry__c ruleEntry = NF_TestDataFactory.createRuleEntry(appRule.Id, 1);
		ruleEntry.Apttus_Approval__EntryLabel__c = 'Rule1';
		Apttus_Approval__ApprovalRuleEntry__c ruleEntry1 = NF_TestDataFactory.createRuleEntry(appRule.Id, 2);
		ruleEntry1.Apttus_Approval__EntryLabel__c = 'Rule2';
		Apttus_Approval__ApprovalRuleEntry__c ruleEntry2 = NF_TestDataFactory.createRuleEntry(appRule.Id, 3);
		ruleEntry2.Apttus_Approval__EntryLabel__c = 'Rule3';
		ruleEntryList.add(ruleEntry);
		ruleEntryList.add(ruleEntry1);
		ruleEntryList.add(ruleEntry2);
		insert ruleEntryList;
	 
		String assigneeValue2 = 'Sales_Role__c (Role_Code__c =\'%\\_BM\' AND Organisation__c =\':Org_L4__c\' AND Active=true AND (BG__c=\':Lead_BG__c\' OR BG__c=\':Lead_BU__c\'))).User__c';
		String assigneeValue1 = 'Sales_Role__c (Role_Code__c =\'%\\_BM\' AND Organisation__c =\':Org_L4__c\' AND Active=true).User__c';
		String assigneeValue ='Sales_Role__c(( Role_Code__c=\'%\\_BM\' AND ( Organisation__c =\':Org_L4__c\' OR Organisation__c =\':Org_L5__c\' OR Organisation__c =\':Org_L6__c\' OR Organisation__c =\':Org_L7__c\') AND Active=true AND BG__c=\'NSW\')).User__c';
		String assigneeValue3 = 'Sales_Role__c (Role_Code__c =\'%\\_BM\' AND (Organisation__c =\':Org_L2__c\' OR Organisation__c =\':Org_L3__c\') AND Active=true).User__c';
		
		List<Apttus_Approval__ApprovalRuleAssignee__c> ruleAssigneeList = new List<Apttus_Approval__ApprovalRuleAssignee__c>();
		ruleAssignee = NF_TestDataFactory.createArAssignee(ruleEntry.Id, 1, true, false, assigneeValue);
		ruleAssignee.Apttus_Approval__AssigneeDescription__c = 'NSNC_BM, Validator';
		ruleAssigneeList.add(ruleAssignee);
		
		
		ruleAssignee1 = NF_TestDataFactory.createArAssignee(ruleEntry.Id, 1, true, false, assigneeValue1);
		ruleAssignee1.Apttus_Approval__AssigneeDescription__c = 'NSNC_BM, Validator';
		ruleAssigneeList.add(ruleAssignee1);
		
		ruleAssignee2 = NF_TestDataFactory.createArAssignee(ruleEntry.Id, 1, true, false, assigneeValue2);
		ruleAssignee2.Apttus_Approval__AssigneeDescription__c = 'NMSD_BM, Validator';
		ruleAssigneeList.add(ruleAssignee2);
		
		ruleAssignee3 = NF_TestDataFactory.createArAssignee(ruleEntry1.Id, 1, true, false, assigneeValue3);
		ruleAssignee3.Apttus_Approval__AssigneeDescription__c = 'NSNG_BM, Validator';
		ruleAssigneeList.add(ruleAssignee3);
		insert ruleAssigneeList;
	
		ruleAssignee = [Select Id, Name, Apttus_Approval__AssigneeDescription__c from Apttus_Approval__ApprovalRuleAssignee__c where Id = :ruleAssignee.Id];
		ruleAssignee1 = [Select Id, Name, Apttus_Approval__AssigneeDescription__c from Apttus_Approval__ApprovalRuleAssignee__c where Id = :ruleAssignee1.Id];
		ruleAssignee2 = [Select Id, Name, Apttus_Approval__AssigneeDescription__c from Apttus_Approval__ApprovalRuleAssignee__c where Id = :ruleAssignee2.Id];
		ruleAssignee3 = [Select Id, Name, Apttus_Approval__AssigneeDescription__c from Apttus_Approval__ApprovalRuleAssignee__c where Id = :ruleAssignee3.Id];
		
		currentApprovalRequest = NF_TestDataFactory.createApprovalHistoryRequest('Notified', 'User', 'Opportunity', currentOpportunity.Id, true, false, testUser.FirstName+''+testUser.LastName, testUser.Id, ruleAssignee.Name);
		currentApprovalRequest.Apttus_Approval__DelegateApproverIds__c=testUser.Id+','+testUser.Id;
		currentApprovalRequest.NF_Assignee_Type__c='Validator';
		CurrentRequest.add(currentApprovalRequest);
		
		currentApprovalRequest1 = NF_TestDataFactory.createApprovalHistoryRequest('Notified', 'User', 'Opportunity', currentOpportunity.Id, true, false, testUser.FirstName+''+testUser.LastName, testUser.Id, ruleAssignee1.Name);
		currentApprovalRequest1.NF_Assignee_Type__c='Approver';
		currentApprovalRequest1.Apttus_Approval__Approval_Status__c='Submitted';
		currentApprovalRequest1.Apttus_Approval__DelegateApproverIds__c=testUser.Id+','+testUser.Id;
		CurrentRequest.add(currentApprovalRequest1);
	  
		currentApprovalRequest2 = NF_TestDataFactory.createApprovalHistoryRequest('Assigned', 'User', 'Opportunity', currentOpportunity2.Id, true, false, testUser.FirstName+''+testUser.LastName, testUser.Id, ruleAssignee2.Name);
		currentApprovalRequest2.NF_Assignee_Type__c='Approver';
		currentApprovalRequest2.Apttus_Approval__Approval_Status__c='Submitted';
		currentApprovalRequest2.Apttus_Approval__DelegateApproverIds__c=testUser.Id+','+testUser.Id;
		CurrentRequest.add(currentApprovalRequest2);
		
		currentApprovalRequest3 = NF_TestDataFactory.createApprovalHistoryRequest('Assigned', 'User', 'Opportunity', currentOpportunity2.Id, true, false, testUser.FirstName+''+testUser.LastName, testUser2.Id, ruleAssignee2.Name);
		currentApprovalRequest3.NF_Assignee_Type__c='Approver';
		currentApprovalRequest3.Apttus_Approval__Approval_Status__c='Submitted';
		currentApprovalRequest3.Apttus_Approval__DelegateApproverIds__c=testUser2.Id+','+testUser2.Id;
		CurrentRequest.add(currentApprovalRequest3);
	 
	 Database.insert(CurrentRequest);
	}
	
	@isTest static void test_updateRequestRcodeM() {
	NCP_CustomerCommunitySetting__c cs = new NCP_CustomerCommunitySetting__c();
		cs.Name = 'Default';
		cs.Customer_Account__c = 'Customer - test';
		cs.Customer_Account_Number__c = '12345';
		cs.Customer_User_Profile__c = 'Customers';
		insert cs;
		system.runAs(testUser){
		 Test.startTest();
			setup();
	 
			List<Apttus_Approval__Approval_Request_History__c> appRequests = new List<Apttus_Approval__Approval_Request_History__c>{currentApprovalRequest};
			NF_TL_UpdateHistoryRequestRCode.updateHistoryRequestRcodeM(CurrentRequest);
			Test.stopTest();

			Apttus_Approval__Approval_Request_History__c appRequestFetched = [Select NF_Organization_Level__c,NF_Role_Code__c,
				NF_Role_Name__c,NF_Assignee_Type__c from Apttus_Approval__Approval_Request_History__c where Id =:currentApprovalRequest.Id];
	
		}
	}
	
}