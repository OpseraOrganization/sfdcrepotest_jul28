@isTest
private class ApprovalCentreControllerTest {
	Private static List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList;
	static testMethod void basicApprovalDetails(){
		List<user> userList = new List<User>();
		List<Account> accountList = new List<Account>();
		List<Opportunity> opportunityList = new List<Opportunity>();
		List<Opportunity> opportunityList1 = new List<Opportunity>();
		List<Offer__c> offerList = new List<Offer__c>();
		List<Offer__c> offerList1 = new List<Offer__c>();
		userList = TestDataFactory.userCreation(2, 'Data Loader Profile');
		database.insert(userList);
		fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		Database.insert(fileSharingCustomSettingList);
		system.runAs(userList[0])
		{
			//Create an account
			accountList = TestDataFactory.createAccount(1);
			accountList[0].Market__c = null;
			accountList[0].Country__c = null;
			database.insert(accountList);
			id accountId  = accountList[0].id;
			system.assert(accountId!=null);
			Id territoryId;
			territoryId = TestDataFactory.getL7TerritoryId();
			System.debug('L7 Territory:::>'+territoryId);
			TestDataFactory.assigningAccountToTerritory(1, accountList[0], territoryId);
			// create an opportunity

			opportunityList = TestDataFactory.OpportunityCreation(1, accountList[0]);
			Test.startTest();
			opportunityList[0].Lead_BU__c  = 'ION IPR';
			opportunityList[0].Lead_BG__c  = 'ION';
			opportunityList[0].Supporting_BG_ION__c = 'ION';
			opportunityList[0].Supporting_BU_ION__c = 'ION Optics';
			//opportunityList[0].Supporting_BUs_NEN__c  = 'NE IoT';
			opportunityList[0].Supporting_BG_MN__c = 'MN';
			opportunityList[0].Supporting_BG_AA__c = 'NSW';
			opportunityList[0].Supporting_BG_FN__c = 'FN';
			opportunityList[0].Supporting_BG_GS__c = 'GS';
			//opportunityList[0].Supporting_BG__c  = 'ION';
			//opportunityList[0].Supporting_BU_ION__c  = 'ION Video';
			database.insert(opportunityList);
			id opportunityId = opportunityList[0].id;
			//ApprovalCentreController.basicApprovalDetails(opportunityId);
			accountList[0].Market__c = 'Market Greater China';
			accountList[0].Country__c = null;
			database.update(accountList);
			//ApprovalCentreController.basicApprovalDetails(opportunityId);
	accountList[0].Market__c = 'Market Greater China';
			accountList[0].Country__c = 'China';
			//database.update(accountList);
			system.assert(opportunityId!=null);
			opportunityList[0].StageName = 'Identify Opportunity';
			opportunityList[0].Phase_Status__c = 'Submitted for G2 Approval';
			opportunityList[0].Probability = 10;
			//database.update(opportunityList);

			// Create an offer
			offerList = TestDataFactory.OfferCreation(1,opportunityList[0]);
			offerList[0].Approval_Recommendation__c = 'Approval will get Approve Button Enabled if they having any pending approval request on Opportunity.';
			offerList[0].Approval_Scope__c = 'Scope to test approval center';
			offerList[0].LoA_Approval_Level__c = 'A';
			offerList[0].LoA_Level_Before_Trigger_Approval__c = 'A' ;
			offerList[0].Net_Sales_LoA_Base_Case_BG_AA__c = 25252.0 ;
			offerList[0].Net_Sales_LoA_Base_Case_BG_NEN__c = 25251.0 ;
			offerList[0].Net_Sales_LoA_Base_Case_BG_FN__c = 78888.0 ;
			offerList[0].Net_Sales_LoA_Base_Case_BG_GS__c = 67434.0 ;
			offerList[0].Net_Sales_LoA_Base_Case_BG_ION__c = 15245.0 ;
			offerList[0].Net_Sales_LoA_Base_Case_BG_MN__c = 13255.0 ;
			offerList[0].LoA_Customer_Net_Price_MN__c = 1;
			offerList[0].LoA_Customer_Net_Price_GS__c= 1;
			offerList[0].LoA_Customer_Net_Price_FN__c = 1;
			offerList[0].LoA_Customer_Net_Price_ION__c= 1;
			offerList[0].LoA_Customer_Net_Price_AA__c= 1;
			offerList[0].LoA_Customer_Net_Price_NEN__c = 1;
			offerList[0].Total_LoA_Customer_Net_Price_CNP__c = 1;
			offerList[0].LoA_Currency__c = '100';
			offerList[0].Net_Sales_LoA_Base_Case__c = 1370300.0 ;
			offerList[0].Offer_Description__c = 'Test Offer for Approval Center...' ;
			database.insert(offerList);
			id offerId = offerList[0].id;
			system.assert(offerId!=null);
			//ApprovalCentreWrapper approvalCentreWrapper = new ApprovalCentreWrapper();
			List<Apttus_Approval__Approval_Request__c> approvalReqList = new List<Apttus_Approval__Approval_Request__c>();
			Apttus_Approval__Approval_Request__c approvalRec = new Apttus_Approval__Approval_Request__c();
			approvalRec.Apttus_Approval__Step_Name__c = 'XYZ';
			approvalRec.Apttus_Approval__Approval_Status__c = 'Assigned';
			approvalRec.Apttus_Approval__Assigned_To_Name__c = 'Test User';
			approvalRec.Apttus_Approval__Approver_Comments__c = 'User comments---- Test Comments 2017-10-11 00:12 User comments---- Test Comments 2017-10-11 00:12';
			approvalRec.Apttus_Approval__Object_Id__c = opportunityId;
			approvalRec.Apttus_Approval__Assigned_To_Id__c = userList[0].Id;
			approvalRec.Apttus_Approval__DelegateApproverIds__c = userList[0].Id;
			approvalRec.NF_Assignee_Type__c = 'Approver';
			approvalRec.Apttus_Approval__Date__c = Date.today();
			//approvalReqList.add(approvalRec);

			database.insert(approvalRec);
			ApprovalCentreController.basicApprovalDetails(opportunityId);

			approvalRec = new Apttus_Approval__Approval_Request__c();
			approvalRec.Apttus_Approval__Step_Name__c = 'XYZ';
			approvalRec.Apttus_Approval__Approval_Status__c = GlobalConstants.STATUS_NOTIFIED;
			approvalRec.Apttus_Approval__Assigned_To_Name__c = 'Test User';
			approvalRec.Apttus_Approval__Approver_Comments__c = 'Notified';
			approvalRec.Apttus_Approval__Object_Id__c = opportunityId;
			approvalRec.Apttus_Approval__Assigned_To_Id__c = userList[0].Id;
			approvalRec.Apttus_Approval__DelegateApproverIds__c = userList[0].Id;
			approvalRec.NF_Assignee_Type__c = 'Validator';
			approvalRec.Apttus_Approval__Date__c = Date.today();
			approvalReqList.add(approvalRec);
			database.insert(approvalReqList);
			ApprovalCentreController.returnApprovalStatusInfo(approvalReqList,new ApprovalCentreWrapper());

			approvalRec = new Apttus_Approval__Approval_Request__c();
			approvalRec.Apttus_Approval__Step_Name__c = 'XYZ';
			approvalRec.Apttus_Approval__Approval_Status__c = GlobalConstants.STATUS_NOTIFIED;
			approvalRec.Apttus_Approval__Assigned_To_Name__c = 'Test User';
			approvalRec.Apttus_Approval__Approver_Comments__c = 'Notified';
			approvalRec.Apttus_Approval__Object_Id__c = opportunityId;
			approvalRec.Apttus_Approval__Assigned_To_Id__c = userList[0].Id;
			approvalRec.Apttus_Approval__DelegateApproverIds__c = userList[0].Id;
			approvalRec.NF_Assignee_Type__c = 'Validator';
			approvalRec.Validator_Status__c = 'Validated';
			approvalRec.Apttus_Approval__Date__c = Date.today();
			approvalReqList = new List<Apttus_Approval__Approval_Request__c>();
			approvalReqList.add(approvalRec);
			database.insert(approvalReqList);
			ApprovalCentreController.returnApprovalStatusInfo(approvalReqList,new ApprovalCentreWrapper());

			approvalRec = new Apttus_Approval__Approval_Request__c();
			approvalRec.Apttus_Approval__Step_Name__c = 'XYZ';
			approvalRec.Apttus_Approval__Approval_Status__c = 'Not Submitted';
			approvalRec.Apttus_Approval__Assigned_To_Name__c = 'Test User';
			approvalRec.Apttus_Approval__Approver_Comments__c = 'Notified';
			approvalRec.Apttus_Approval__Object_Id__c = opportunityId;
			approvalRec.Apttus_Approval__Assigned_To_Id__c = userList[0].Id;
			approvalRec.Apttus_Approval__DelegateApproverIds__c = userList[0].Id;
			approvalRec.NF_Assignee_Type__c = 'Validator';
			approvalRec.Validator_Status__c = 'Validated';
			approvalRec.Apttus_Approval__Date__c = Date.today();
			approvalReqList = new List<Apttus_Approval__Approval_Request__c>();
			approvalReqList.add(approvalRec);
			database.insert(approvalReqList);
			ApprovalCentreController.returnApprovalStatusInfo(approvalReqList,new ApprovalCentreWrapper());


			/*Apttus_Approval__Approval_Request__c approvalRec1 = new Apttus_Approval__Approval_Request__c();
			approvalRec1.Apttus_Approval__Step_Name__c = 'XYZ';
			approvalRec1.Apttus_Approval__Assigned_To_Name__c = 'Test User';
			approvalRec1.Apttus_Approval__Request_Comments__c = 'Test Comments';
			approvalRec1.Apttus_Approval__Object_Id__c = opportunityId;
			approvalRec1.Apttus_Approval__Date__c = Date.today();
			database.insert(approvalRec1);*/
			//ApprovalCentreController.basicApprovalDetails(opportunityId);
			offerList[0].LoA_Currency__c = null;
			//Database.update(offerList);
			/*approvalRec.NF_Assignee_Type__c = 'Validator';
			approvalRec.Apttus_Approval__DelegateApproverIds__c = userList[0].id;
			approvalRec.Apttus_Approval__Approval_Status__c = null;
			Database.update(approvalRec);*/
			//ApprovalCentreController.basicApprovalDetails(opportunityId);
			//ApprovalCentreController.basicApprovalDetails(null);
			test.stopTest();
		}

	}
	static testMethod void basicApprovalDetails1(){
		Test.startTest();
		List<user> userList = new List<User>();
		List<Account> accountList = new List<Account>();
		List<Opportunity> opportunityList = new List<Opportunity>();
		List<Opportunity> opportunityList1 = new List<Opportunity>();
		List<Offer__c> offerList = new List<Offer__c>();
		List<Offer__c> offerList1 = new List<Offer__c>();
		userList = TestDataFactory.userCreation(2, 'Data Loader Profile');
		database.insert(userList);
		fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		Database.insert(fileSharingCustomSettingList);
		system.runAs(userList[0])
		{
			//Create an account
			accountList = TestDataFactory.createAccount(1);
			accountList[0].Market__c = null;
			accountList[0].Country__c = null;
			database.insert(accountList);
			id accountId  = accountList[0].id;
			system.assert(accountId!=null);
			Id territoryId;
			territoryId = TestDataFactory.getL7TerritoryId();
			System.debug('L7 Territory:::>'+territoryId);
			TestDataFactory.assigningAccountToTerritory(1, accountList[0], territoryId);
			// create an opportunity
			opportunityList = TestDataFactory.OpportunityCreation(1, accountList[0]);
			opportunityList[0].StageName = 'Win the Case (Negotiate)';
			opportunityList[0].Phase_Status__c = 'Submitted for G5 Approval';
			opportunityList[0].Lead_BU__c  = 'ION IPR';
			opportunityList[0].Lead_BG__c  = 'ION';
			opportunityList[0].Supporting_BG_ION__c = null;
			//opportunityList[0].Supporting_BG__c  = 'ION';
			//opportunityList[0].Supporting_BU_ION__c  = 'ION Video';
			database.insert(opportunityList);
			id opportunityId = opportunityList[0].id;
			ApprovalCentreController.basicApprovalDetails(opportunityId);
			ApprovalCentreController.basicApprovalDetails(null);
	test.stopTest();
		}
	}
	static testMethod void validatorMethodCoverage()
	{
		test.startTest();
		List<user> userList = new List<User>();
		List<Account> accountList = new List<Account>();
		List<Opportunity> opportunityList = new List<Opportunity>();
		List<Opportunity> opportunityList1 = new List<Opportunity>();
		List<Offer__c> offerList = new List<Offer__c>();
		List<Offer__c> offerList1 = new List<Offer__c>();
		userList = TestDataFactory.userCreation(2, 'Data Loader Profile');
		database.insert(userList);
		fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		Database.insert(fileSharingCustomSettingList);
		system.runAs(userList[1])
		{
			accountList = TestDataFactory.createAccount(1);
			accountList[0].Market__c = null;
			accountList[0].Country__c = null;
			database.insert(accountList);
			id accountId  = accountList[0].id;
			system.assert(accountId!=null);
			Id territoryId;
			territoryId = TestDataFactory.getL7TerritoryId();
			System.debug('L7 Territory:::>'+territoryId);
			TestDataFactory.assigningAccountToTerritory(1, accountList[0], territoryId);
			// create an opportunity
			opportunityList = TestDataFactory.OpportunityCreation(1, accountList[0]);
			opportunityList[0].Lead_BU__c  = 'ION IPR';
			opportunityList[0].Lead_BG__c  = 'ION';
			opportunityList[0].Supporting_BG_ION__c = 'ION';
			opportunityList[0].Supporting_BU_ION__c = '  ION Optics';
			opportunityList[0].Supporting_BG_MN__c = 'MN';
			opportunityList[0].Supporting_BG_AA__c = 'NSW';
			opportunityList[0].Supporting_BG_FN__c = 'FN';
			opportunityList[0].Supporting_BG_GS__c = 'GS';
			database.insert(opportunityList);

			// Create an offer
			offerList = TestDataFactory.OfferCreation(1,opportunityList[0]);
			offerList[0].Approval_Recommendation__c = 'Approval will get Approve Button Enabled if they having any pending approval request on Opportunity.';
			offerList[0].Approval_Scope__c = 'Scope to test approval center';
			offerList[0].LoA_Approval_Level__c = 'A';
			offerList[0].LoA_Level_Before_Trigger_Approval__c = 'A' ;
			offerList[0].Net_Sales_LoA_Base_Case_BG_AA__c = 25252.0 ;
			offerList[0].Net_Sales_LoA_Base_Case_BG_FN__c = 78888.0 ;
			offerList[0].Net_Sales_LoA_Base_Case_BG_GS__c = 67434.0 ;
			offerList[0].Net_Sales_LoA_Base_Case_BG_ION__c = 15245.0 ;
			offerList[0].Net_Sales_LoA_Base_Case_BG_MN__c = 13255.0 ;
			offerList[0].LoA_Currency__c = '100';
			offerList[0].Net_Sales_LoA_Base_Case__c = 1370300.0 ;
			/*offerList[0].Offer_Description__c = '<p>Test Offer for Approval Center...</p>' ;  */
			database.insert(offerList);

			//Approval request creation
			Apttus_Approval__Approval_Request__c approvalRec1 = new Apttus_Approval__Approval_Request__c();
			approvalRec1.Apttus_Approval__Step_Name__c = 'XYZ';
			approvalRec1.Apttus_Approval__Assigned_To_Name__c = 'Test User';
			approvalRec1.Apttus_Approval__Approver_Comments__c = 'Test Comments';
			approvalRec1.Apttus_Approval__Object_Id__c = opportunityList[0].id;
			approvalRec1.Apttus_Approval__Date__c = Date.today();
			approvalRec1.NF_Assignee_Type__c = 'Validator';
			approvalRec1.Apttus_Approval__Approval_Status__c = null;
			database.insert(approvalRec1);
			//ApprovalCentreController.basicApprovalDetails(approvalRec1.Apttus_Approval__Object_Id__c);
			ApprovalCentreController.validateOrReject(approvalRec1.Id, approvalRec1.Apttus_Approval__Approver_Comments__c, GlobalConstants.VALIDATE);
			ApprovalCentreController.validateOrReject(null, null, null);
			ApprovalCentreController.removeCommentsSystemInfo(null);
		}
		test.stopTest();

	}
	static testMethod void getGatesAndConfidentialDocs()
	{

		List<Account> accountList = new List<Account>();
		List<Opportunity> opportunityList = new List<Opportunity>();
		List<Offer__c> offerList = new List<Offer__c>();
		fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		Database.insert(fileSharingCustomSettingList);
		List<user> userList = new List<User>();
		userList = TestDataFactory.userCreation(1, 'Data Loader Profile');
		database.insert(userList);
		system.runAs(userList[0])
		{
			//Create an account
			accountList = TestDataFactory.createAccount(1);
			database.insert(accountList);
			id accountId  = accountList[0].id;
			system.assert(accountId!=null);

			// create an opportunity
			Test.startTest();
			opportunityList = TestDataFactory.OpportunityCreation(1, accountList[0]);
			database.insert(opportunityList);
			id opportunityId = opportunityList[0].id;
			system.assert(opportunityId!=null);
			opportunityList[0].Probability = 10;
			database.update(opportunityList);
			ApprovalCentreController.getTaskDetails(opportunityList[0].Id);

			// Create an offer
			offerList = TestDataFactory.OfferCreation(1,opportunityList[0]);
			offerList[0].ActiveOffer__c = true;
			database.insert(offerList);
			id offerId = offerList[0].id;
			system.assert(offerId!=null);

	ContentVersion  oVersion= TestDataFactory.createContentVersion_New(1,'LoA G4 Template')[0];
			database.insert(oVersion);

			ContentVersion conVersion = [SELECT ContentDocumentId,Document_Type_POC__c FROM ContentVersion where ID =: oVersion.Id LIMIT 1];

			ContentDocumentLink oDocumentLink = TestDataFactory.createContentDocumentLink_New(1,offerId,conVersion.ContentDocumentId)[0];
			database.insert(oDocumentLink);

			Confidential_File__c oConfiFile = TestDataFactory.createConfidentialFile(conVersion.ContentDocumentId,offerId,accountId);
			database.insert(oConfiFile);
			ApprovalCentreController.getConfidentialDocs(opportunityId);
			Test.stoptest();
		}
	}

	static testMethod void getG4_G5_Docs()
	{

		List<Account> accountList = new List<Account>();
		List<Opportunity> opportunityList = new List<Opportunity>();
		List<Offer__c> offerList = new List<Offer__c>();
		fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		Database.insert(fileSharingCustomSettingList);
		List<user> userList = new List<User>();
		userList = TestDataFactory.userCreation(1, 'Data Loader Profile');
		database.insert(userList);
		system.runAs(userList[0])
		{
			//Create an account
			accountList = TestDataFactory.createAccount(1);
			database.insert(accountList);
			id accountId  = accountList[0].id;
			system.assert(accountId!=null);

			// create an opportunity
			Test.startTest();
			opportunityList = TestDataFactory.OpportunityCreation(1, accountList[0]);
			database.insert(opportunityList);
			id opportunityId = opportunityList[0].id;
			system.assert(opportunityId!=null);
			opportunityList[0].Probability = 10;
			database.update(opportunityList);
			ApprovalCentreController.getTaskDetails(opportunityList[0].Id);

			// Create an offer
			offerList = TestDataFactory.OfferCreation(1,opportunityList[0]);
			offerList[0].ActiveOffer__c = true;
			offerList[0].Offer_DSO__c = 99;
			offerList[0].Offer_IRD__c = 101;
			database.insert(offerList);
			id offerId = offerList[0].id;
			system.assert(offerId!=null);

			ContentVersion  oVersion= TestDataFactory.createContentVersion_New(1,'LoA G4 Template (without financials)')[0];
			database.insert(oVersion);

			ContentVersion conVersion = [SELECT ContentDocumentId,Document_Type_POC__c FROM ContentVersion where ID =: oVersion.Id LIMIT 1];

			ContentDocumentLink oDocumentLink = TestDataFactory.createContentDocumentLink_New(1,offerId,conVersion.ContentDocumentId)[0];
			database.insert(oDocumentLink);

			Confidential_File__c oConfiFile = TestDataFactory.createConfidentialFile(conVersion.ContentDocumentId,offerId,accountId);
			database.insert(oConfiFile);

			File_Report__c  fileReport = new File_Report__c(ContentDocumentId__c = conVersion.ContentDocumentId,Parent_Account__c =accountId,File_Version__c='1');
			database.insert(fileReport);

			ApprovalCentreController.getG4_G5_Docs(opportunityId);
			ApprovalCentreController.getUserRestriction();
			Test.stoptest();
		}
	}

	static testMethod void getexceptions()
	{
		ApprovalCentreController.getConfidentialDocs(null);
		ApprovalCentreController.getG4_G5_Docs(null);
		ApprovalCentreController.rejectionRequest(null,null);
		//ApprovalCentreController.allowedToOpenDocument(null);
		ApprovalCentreController.getApprovalsDetailsRec(null);
		 ApprovalCentreController.getUserRestriction();
		ApprovalCentreController.getRequestorComment(null);
		ApprovalCentreController.getTaskDetails(null);
	// ApprovalCentreController.allowedToOpenDocument(null);
		ApprovalCentreController.rejectionRequest(null,null);
		ApprovalCentreController.approvalRequest(null,null);


	}

	static testMethod void getApprovalsDetailsRec()
	{
		Test.startTest();
		List<user> userList = new List<User>();
		List<Account> accountList = new List<Account>();
		List<Opportunity> opportunityList = new List<Opportunity>();
		fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		Database.insert(fileSharingCustomSettingList);

		userList = TestDataFactory.userCreation(1, 'Data Loader Profile');
		database.insert(userList);
		system.runAs(userList[0])
		{
			//Create an account
			accountList = TestDataFactory.createAccount(1);
			database.insert(accountList);
			id accountId  = accountList[0].id;
			system.assert(accountId!=null);

			// create an opportunity
			opportunityList = TestDataFactory.OpportunityCreation(1, accountList[0]);
			database.insert(opportunityList);
			id opportunityId = opportunityList[0].id;
			system.assert(opportunityId!=null);
			opportunityList[0].StageName = 'Win the Case (Negotiate)';
			opportunityList[0].Phase_Status__c = 'Submitted for G5 Approval';
			opportunityList[0].Probability = 10;
			database.update(opportunityList);

			// creating Approval Request Record
			Apttus_Approval__Approval_Request__c approvalRec = new Apttus_Approval__Approval_Request__c();
			approvalRec.Apttus_Approval__Approver_Comments__c = 'Test Comments';
			approvalRec.Apttus_Approval__Assigned_To_Name__c = 'Test User';
			approvalRec.Apttus_Approval__Request_Comments__c = 'Test Test Comments';
			approvalRec.NF_Assignee_Type__c = 'Test Assignee Type';

			ApprovalCentreController.getApprovalsDetailsRec(opportunityId);
			ApprovalCentreController.getApprovalsDetailsRec(null);
			list < ContentVersion > conVersionList = TestDataFactory.createContentVersion(1);
			Database.insert(conVersionList);
			Id contentDocId = conVersionList[0].ContentDocumentId;
	 // ApprovalCentreController.allowedToOpenDocument(contentDocId);
			//ApprovalCentreController.allowedToOpenDocument(null);
			Test.stoptest();
		}
	}

	static testMethod void approvalRequest()
	{
		Test.startTest();
		List<user> userList = new List<User>();
		List<Account> accountList = new List<Account>();
		List<Opportunity> opportunityList = new List<Opportunity>();
		fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		Database.insert(fileSharingCustomSettingList);
		userList = TestDataFactory.userCreation(1, 'Data Loader Profile');
		database.insert(userList);
		system.runAs(userList[0])
		{
			//Create an account
			accountList = TestDataFactory.createAccount(1);
			database.insert(accountList);
			id accountId  = accountList[0].id;
			system.assert(accountId!=null);

			// create an opportunity
			opportunityList = TestDataFactory.OpportunityCreation(1, accountList[0]);
			database.insert(opportunityList);
			id opportunityId = opportunityList[0].id;
			system.assert(opportunityId!=null);
			opportunityList[0].StageName = 'Win the Case (Negotiate)';
			opportunityList[0].Phase_Status__c = 'Submitted for G5 Approval';
			opportunityList[0].Probability = 10;
			database.update(opportunityList);
			ApprovalCentreController.getRequestorComment(opportunityList[0].id);


			Apttus_Approval__Approval_Request__c approvalRequest=new Apttus_Approval__Approval_Request__c();
			approvalRequest.Apttus_Approval__Object_Id__c = opportunityId;
			approvalRequest.Apttus_Approval__Object_Type__c='Opportunity';
			//Apttus_Approval__Approval_Process__c=mainProcess.id,
			approvalRequest.Apttus_Approval__Step_Name__c='First Step';
			//Apttus_Approval__Initial_Submitter__c=appr.Id,
			//Apttus_Approval__Assigned_To_Id__c=appr.Id);
			database.insert(approvalRequest);
			ApexPages.currentPage().getParameters().put('approvalRequestId', approvalRequest.id);
			ApprovalCentreController.approvalRequest(String.valueof(approvalRequest.id),'Hi this is comment');
			ApprovalCentreController.rejectionRequest(String.valueof(approvalRequest.id),'Hi this is comment');
			ApprovalCentreController.approvalRequest(null,null);
			ApprovalCentreController.rejectionRequest(null,null);
			Test.stoptest();
		}
	}
	static testMethod void approvalRequest1()
	{
		Test.startTest();
		List<user> userList = new List<User>();
		List<Account> accountList = new List<Account>();
		List<Opportunity> opportunityList = new List<Opportunity>();
		fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		Database.insert(fileSharingCustomSettingList);
		userList = TestDataFactory.userCreation(1, 'Data Loader Profile');
		database.insert(userList);
		system.runAs(userList[0])
		{
			ApprovalCentreController.returnApprovalStatusInfo(null,null);
			ApprovalCentreController.getTaskDetails(null);
		}
		Test.stopTest();
	}
}