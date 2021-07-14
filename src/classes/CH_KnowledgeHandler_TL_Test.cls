@isTest 
private class CH_KnowledgeHandler_TL_Test {
	
	public static final string WORKGROUPNAME = 'TEST1';
	public static final string QUEUENAME = WORKGROUPNAME + '_AQ';
	
	@testSetup  
	static void setuptestdata()
	{  
		Group g1 = new Group(Name = QUEUENAME, type='Queue');
		insert g1;
		QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'KnowledgeArticleVersion');
		insert q1;
	}
	
	@isTest
	public static void CH_Knowledge2(){
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		String orgId = UserInfo.getOrganizationId();
		 Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		  String dateString = 
		String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
	 String uniqueName = orgId + dateString + randomInt;
		
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
						  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
						  LocaleSidKey='en_US', ProfileId = p.Id,
						  TimeZoneSidKey='America/Los_Angeles',  UserName= uniqueName + '@test' + orgId + '.org');
		insert u;
		
		// Query your permission set name from Organization that your want to test.
		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CH_Author'];
		PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'CH_Publisher'];
		
		// Assign the above inserted user for the above Permission Set.
		PermissionSetAssignment psa = new PermissionSetAssignment();
		psa.AssigneeId = u.Id;
		psa.PermissionSetId = ps.Id;
		insert psa;
		PermissionSetAssignment psa1 = new PermissionSetAssignment();
		psa1.AssigneeId = u.Id;
		psa1.PermissionSetId = ps1.Id;
		insert psa1;
		
		
		Knowledge__kav testArticle = new Knowledge__kav();
		// Run your code with inserted user.
		System.runAs(u)
		{
			Test.isRunningTest();
			Test.startTest();
			
			
			List<Group> oGrouplist =	[SELECT
										 Id,
										 Name,
										 DeveloperName
										 FROM
										 Group
										 WHERE
										 (DeveloperName like '%_AQ' OR DeveloperName like '%_PQ')
										 AND 
										 type = 'Queue'
										];
			
			System.assert(oGrouplist.size() >0);
			
			//Avoid Chain jobs in asynch Apex job
			CH_ManageCreateQueueAsynchQueue.doChainJob = false;
			
			//Create Workgroup
			List<CH_Workgroup__c> workGroups = new List<CH_Workgroup__c>();
			Id recordTypeId = Schema.SObjectType.CH_Workgroup__c.getRecordTypeInfosByDeveloperName().get('CH_KB_Workgroup').getRecordTypeId();
			String MemberRecTypeId = Schema.getGlobalDescribe().get('CH_Workgroup_Member__c').getDescribe().getRecordTypeInfosByName().get('CH_KB_WorkgroupMember').getRecordTypeId();
			CH_Workgroup__c workgroup = new CH_Workgroup__c(RecordTypeId = recordTypeId);
			workgroup.name = WORKGROUPNAME;
			workgroup.CH_End_of_Business_Hours_Threshold__c = 120;
			workgroup.CH_Start_of_Business_Hours_Threshold__c = 120;
			insert workgroup;
			
			CH_Workgroup_Member__c wgMember = new CH_Workgroup_Member__c();
			wgMember.CH_Workgroup__c = workgroup.id;
			wgMember.CH_User__c = UserInfo.getUserId();
			wgMember.CH_Role__c = 'Author';
			wgMember.RecordTypeId = MemberRecTypeId;
			insert wgMember;
			
			
			
			//Create Knowledge Article witch 'CH' Record Type
			String RecTypeId = Schema.getGlobalDescribe().get('Knowledge__kav').getDescribe().getRecordTypeInfosByName().get('How To').getRecordTypeId();
			//System.debug('RecTypeId'+RecTypeId);
			testArticle = new Knowledge__kav(Title = 'How To Test By Gizmo23131', 
											 urlName = 'HowToTestByGizmo1231231231',
											 RecordTypeId = RecTypeId,
											 ValidationStatus = 'Work in Progress', 
											 CH_PurposeRequired__c = 'd', 
											 CH_ProcedureRequired__c = 'Gizem is the best',
											 CH_Workgroup__c = workgroup.id,
											 CH_InApproval__c = false);
			insert testArticle; 
			List<Knowledge__kav> articleList = new List<Knowledge__kav>();
			articleList.add([Select id, Title, urlName, RecordTypeId, ValidationStatus,
							 CH_Workgroup__c, CH_WorkgroupName__c , CH_InApproval__c, PublishStatus, CreatedById from Knowledge__kav where id =: testArticle.id]);
			Group grp = new Group();
			grp.name = 'null_PQ';
			grp.DeveloperName = +'null_PQ';
			grp.Type = 'Queue'; 
			Insert grp; 
			
			//Create Group Member
			GroupMember grpMem1 = new GroupMember();
			grpMem1.UserOrGroupId = UserInfo.getUserId();
			grpMem1.GroupId = grp.Id;
			Insert grpMem1;
			
			Group grp2 = new Group();
			grp2.name = 'null_AQ';
			grp2.DeveloperName = 'null_AQ';
			grp2.Type = 'Queue'; 
			Insert grp2; 
			
			//Create Group Member
			GroupMember grpMem2 = new GroupMember();
			grpMem2.UserOrGroupId = UserInfo.getUserId();
			grpMem2.GroupId = grp2.Id;
			Insert grpMem2;
			testArticle.ValidationStatus = 'Internal Approved';
			testArticle.CH_InApproval__c = true;
			testArticle.CH_ComingFromApprovalProcess__c = true;
			testArticle.CH_Candidate_for_External__c = true;
			List<Knowledge__kav> articleListNew = new List<Knowledge__kav>();
			articleListNew.add(testArticle);
			// articleListNew.add([Select id, Title, urlName, RecordTypeId, ValidationStatus, CH_Workgroup__c, CH_InApproval__c, PublishStatus, CreatedById from Knowledge__kav where id =: testArticle.id]);
			
			try{
				CH_KnowledgeHandler_TL.assignOwnerIfInApprovalStatus(articleListNew,articleListNew);
			}
			catch(Exception ex){
			}
			try{
				CH_KnowledgeHandler_TL.validateIfUserCanEditArticle(articleList);
			}
			catch(Exception ex){
			}
			
			
			try{
				CH_KnowledgeHandler_TL.validateIfUserCanDeleteArticle(articleList);
			}
			catch(Exception ex){
				
				
			}
			try{
				CH_KnowledgeHandler_TH ch = new CH_KnowledgeHandler_TH();
				ch.beforeDelete();
			}
			catch(Exception ex){			   
				
			}
		}
		
	}
	@isTest
	public static void testSetDefaultDataCategories(){
		Test.isRunningTest();
		Test.startTest();
		
		//Avoid Chain jobs in asynch Apex job
		CH_ManageCreateQueueAsynchQueue.doChainJob = false;
		
		//Create Workgroup
		List<CH_Workgroup__c> workGroups = new List<CH_Workgroup__c>();
		Id recordTypeId = Schema.SObjectType.CH_Workgroup__c.getRecordTypeInfosByDeveloperName().get('CH_KB_Workgroup').getRecordTypeId();
		String MemberRecTypeId = Schema.getGlobalDescribe().get('CH_Workgroup_Member__c').getDescribe().getRecordTypeInfosByName().get('CH_KB_WorkgroupMember').getRecordTypeId();
		CH_Workgroup__c workgroup = new CH_Workgroup__c(RecordTypeId = recordTypeId);
		workgroup.name = WORKGROUPNAME;
		workgroup.CH_End_of_Business_Hours_Threshold__c = 120;
		workgroup.CH_Start_of_Business_Hours_Threshold__c = 120;
		insert workgroup;
		
		CH_Workgroup_Member__c wgMember = new CH_Workgroup_Member__c();
		wgMember.CH_Workgroup__c = workgroup.id;
		wgMember.CH_User__c = UserInfo.getUserId();
		wgMember.CH_Role__c = 'Author';
		wgMember.RecordTypeId = MemberRecTypeId;
		insert wgMember;
		
		//Create Knowledge Article witch 'CH' Record Type
		String RecTypeId = Schema.getGlobalDescribe().get('Knowledge__kav').getDescribe().getRecordTypeInfosByName().get('How To').getRecordTypeId();
		//System.debug('RecTypeId'+RecTypeId);
		Knowledge__kav testArticle = new Knowledge__kav(Title = 'How To Test By Gizmo23131', urlName = 'HowToTestByGizmo1231231231', RecordTypeId = RecTypeId, ValidationStatus = 'Work in Progress', CH_PurposeRequired__c = 'd', CH_ProcedureRequired__c = 'Gizem is the best',CH_Workgroup__c = workgroup.id, CH_InApproval__c = false);
		insert testArticle; 
		List<Knowledge__kav> articleList = new List<Knowledge__kav>();
		articleList.add([Select id, Title, urlName, RecordTypeId, ValidationStatus, CH_Workgroup__c, CH_InApproval__c, PublishStatus, CreatedById from Knowledge__kav where id =: testArticle.id]);
		
		try{
			CH_KnowledgeHandler_TL.assignOwnerIfInApprovalStatus(articleList, articleList);
		}
		catch(Exception ex){
		}
		try{
			CH_KnowledgeHandler_TL.validateIfUserCanEditArticle(articleList);
		}
		catch(Exception ex){
		}
		
		
		try{
			CH_KnowledgeHandler_TL.validateIfUserCanDeleteArticle(articleList);
		}
		catch(Exception ex){
			
			
		}
		
		
		try{
			testArticle.CH_InApproval__c = true;
			upsert testArticle;
		}
		catch(Exception ex){
			
			
		}
		try{
			testArticle.CH_Minor_changes__c = true;
			upsert testArticle;
		}
		catch(Exception ex){
		}
		try{
			testArticle.CH_Minor_changes__c = true;
			testArticle.CH_Candidate_for_External__c = true;
			upsert testArticle;
		}
		catch(Exception ex){
		}
		try{
			testArticle.CH_Minor_changes__c = false;
			testArticle.CH_Candidate_for_External__c = true;
			upsert testArticle; 
		}
		catch(Exception ex){ 
		}
		try{
			testArticle.ValidationStatus = 'Needs Publisher Review';
			testArticle.CH_InApproval__c = true ;
			upsert testArticle; 
		}catch(Exception ex){ 
		}
		Test.stopTest();
		
	}   
	
	@isTest
	public static void CH_Knowledge(){
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		String orgId = UserInfo.getOrganizationId();
		 Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		  String dateString = 
		String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
	 String uniqueName = orgId + dateString + randomInt;
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
						  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
						  LocaleSidKey='en_US', ProfileId = p.Id,
						  TimeZoneSidKey='America/Los_Angeles',  UserName= uniqueName + '@test' + orgId + '.org');
		insert u;
		
		// Query your permission set name from Organization that your want to test.
		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CH_Author'];
		
		// Assign the above inserted user for the above Permission Set.
		PermissionSetAssignment psa = new PermissionSetAssignment();
		psa.AssigneeId = u.Id;
		psa.PermissionSetId = ps.Id;
		insert psa;
		Knowledge__kav testArticle = new Knowledge__kav();
		// Run your code with inserted user.
		System.runAs(u)
		{
			Test.isRunningTest();
			Test.startTest();
			
			//Avoid Chain jobs in asynch Apex job
			CH_ManageCreateQueueAsynchQueue.doChainJob = false;
			
			//Create Workgroup
			List<CH_Workgroup__c> workGroups = new List<CH_Workgroup__c>();
			Id recordTypeId = Schema.SObjectType.CH_Workgroup__c.getRecordTypeInfosByDeveloperName().get('CH_KB_Workgroup').getRecordTypeId();
			String MemberRecTypeId = Schema.getGlobalDescribe().get('CH_Workgroup_Member__c').getDescribe().getRecordTypeInfosByName().get('CH_KB_WorkgroupMember').getRecordTypeId();
			CH_Workgroup__c workgroup = new CH_Workgroup__c(RecordTypeId = recordTypeId);
			workgroup.name = WORKGROUPNAME;
			workgroup.CH_End_of_Business_Hours_Threshold__c = 120;
			workgroup.CH_Start_of_Business_Hours_Threshold__c = 120;
			insert workgroup;
			
			CH_Workgroup_Member__c wgMember = new CH_Workgroup_Member__c();
			wgMember.CH_Workgroup__c = workgroup.id;
			wgMember.CH_User__c = UserInfo.getUserId();
			wgMember.CH_Role__c = 'Author';
			wgMember.RecordTypeId = MemberRecTypeId;
			insert wgMember;
			
			//Create Knowledge Article witch 'CH' Record Type
			String RecTypeId = Schema.getGlobalDescribe().get('Knowledge__kav').getDescribe().getRecordTypeInfosByName().get('How To').getRecordTypeId();
			//System.debug('RecTypeId'+RecTypeId);
			testArticle = new Knowledge__kav(Title = 'How To Test By Gizmo23131', urlName = 'HowToTestByGizmo1231231231', RecordTypeId = RecTypeId, ValidationStatus = 'Work in Progress', CH_PurposeRequired__c = 'd', CH_ProcedureRequired__c = 'Gizem is the best',CH_Workgroup__c = workgroup.id, CH_InApproval__c = false);
			insert testArticle; 
			List<Knowledge__kav> articleList = new List<Knowledge__kav>();
			articleList.add([Select id, Title, urlName, RecordTypeId, ValidationStatus, CH_Workgroup__c, CH_InApproval__c, PublishStatus, CreatedById from Knowledge__kav where id =: testArticle.id]);
			
			try{
				CH_KnowledgeHandler_TL.assignOwnerIfInApprovalStatus(articleList, articleList);
			}
			catch(Exception ex){
			}
			try{
				CH_KnowledgeHandler_TL.validateIfUserCanEditArticle(articleList);
			}
			catch(Exception ex){
			}
			
			
			try{
				CH_KnowledgeHandler_TL.validateIfUserCanDeleteArticle(articleList);
			}
			catch(Exception ex){
				
				
			}
			testArticle.CH_Minor_changes__c = true;
			testArticle.CH_ComingFromApprovalProcess__c = false;
			testArticle.CH_Candidate_for_External__c = false;
			upsert testArticle;
			articleList =   new List<Knowledge__kav>();
			articleList.add([Select id, Title, urlName, RecordTypeId, ValidationStatus, CH_Workgroup__c, CH_InApproval__c, PublishStatus, CreatedById from Knowledge__kav where id =: testArticle.id]);
			CH_KnowledgeHandler_TL.assignOwnerIfInApprovalStatus(articleList, articleList);
			try{
				
			}
			catch(Exception ex){
			}
			try{
				testArticle.CH_Minor_changes__c = true;
				testArticle.CH_ComingFromApprovalProcess__c = false;
				testArticle.CH_Candidate_for_External__c = true;
				upsert testArticle;
			}
			catch(Exception ex){
			}
			try{
				testArticle.CH_Minor_changes__c = false;
				testArticle.CH_ComingFromApprovalProcess__c = false;
				testArticle.CH_Candidate_for_External__c = true;
				upsert testArticle;
			}
			catch(Exception ex){
			}
			
			
			
			try{
				testArticle.ValidationStatus = 'Needs Publisher Review';
				testArticle.CH_InApproval__c = true ;
				upsert testArticle; 
			}catch(Exception ex){ 
			}
			Test.stopTest();
		}
		
		
		try{
			testArticle.CH_Workgroup__c = null;
			update testArticle;
			List<Knowledge__kav > articleList= new List<Knowledge__kav>();
			articleList =   new List<Knowledge__kav>();
			articleList.add([Select id, Title, urlName, RecordTypeId, ValidationStatus, CH_Workgroup__c, CH_InApproval__c, PublishStatus, CreatedById from Knowledge__kav where id =: testArticle.id]);
			
			CH_KnowledgeHandler_TL.validateIfUserCanDeleteArticle(articleList);
		}
		catch(Exception ex){
			
			
		}
		
	}
	@isTest
	public static void CH_KnowledgeDelete(){
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		String orgId = UserInfo.getOrganizationId();
		 Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		  String dateString = 
		String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
	 String uniqueName = orgId + dateString + randomInt;
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
						  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
						  LocaleSidKey='en_US', ProfileId = p.Id,
						  TimeZoneSidKey='America/Los_Angeles',  UserName= uniqueName + '@test' + orgId + '.org');
		insert u;
		
		// Query your permission set name from Organization that your want to test.
		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CH_Author'];
		
		// Assign the above inserted user for the above Permission Set.
		PermissionSetAssignment psa = new PermissionSetAssignment();
		psa.AssigneeId = u.Id;
		psa.PermissionSetId = ps.Id;
		insert psa;
		Knowledge__kav testArticle = new Knowledge__kav();
		// Run your code with inserted user.
		System.runAs(u)
		{
			Test.isRunningTest();
			Test.startTest();
			
			//Avoid Chain jobs in asynch Apex job
			CH_ManageCreateQueueAsynchQueue.doChainJob = false;
			
			//Create Workgroup
			List<CH_Workgroup__c> workGroups = new List<CH_Workgroup__c>();
			Id recordTypeId = Schema.SObjectType.CH_Workgroup__c.getRecordTypeInfosByDeveloperName().get('CH_KB_Workgroup').getRecordTypeId();
			String MemberRecTypeId = Schema.getGlobalDescribe().get('CH_Workgroup_Member__c').getDescribe().getRecordTypeInfosByName().get('CH_KB_WorkgroupMember').getRecordTypeId();
			CH_Workgroup__c workgroup = new CH_Workgroup__c(RecordTypeId = recordTypeId);
			workgroup.name = WORKGROUPNAME;
			workgroup.CH_End_of_Business_Hours_Threshold__c = 120;
			workgroup.CH_Start_of_Business_Hours_Threshold__c = 120;
			insert workgroup;
			
			CH_Workgroup_Member__c wgMember = new CH_Workgroup_Member__c();
			wgMember.CH_Workgroup__c = workgroup.id;
			wgMember.CH_User__c = UserInfo.getUserId();
			wgMember.CH_Role__c = 'Author';
			wgMember.RecordTypeId = MemberRecTypeId;
			insert wgMember;
			
			//Create Knowledge Article witch 'CH' Record Type
			String RecTypeId = Schema.getGlobalDescribe().get('Knowledge__kav').getDescribe().getRecordTypeInfosByName().get('How To').getRecordTypeId();
			//System.debug('RecTypeId'+RecTypeId);
			testArticle = new Knowledge__kav(Title = 'How To Test By Gizmo23131', urlName = 'HowToTestByGizmo1231231231', RecordTypeId = RecTypeId, ValidationStatus = 'Work in Progress',CH_Workgroup__c = workgroup.id, CH_PurposeRequired__c = 'd', CH_ProcedureRequired__c = 'Gizem is the best', CH_InApproval__c = false);
			insert testArticle; 
			List<Knowledge__kav> articleList = new List<Knowledge__kav>();
			articleList.add([Select id, Title, urlName, RecordTypeId, ValidationStatus, CH_Workgroup__c, CH_InApproval__c, PublishStatus, CreatedById from Knowledge__kav where id =: testArticle.id]);
			
			
			
			Test.stopTest();
		}
		
		
		try{
			
			List<Knowledge__kav > articleList= new List<Knowledge__kav>();
			
			articleList.add([Select id, Title, urlName, RecordTypeId, ValidationStatus, CH_Workgroup__c, CH_InApproval__c, PublishStatus, CreatedById from Knowledge__kav where id =: testArticle.id]);
			
			CH_KnowledgeHandler_TL.validateIfUserCanDeleteArticle(articleList);
		}
		catch(Exception ex){
			
			
		}
		// Assign the above inserted user for the above Permission Set.
		PermissionSetAssignment psa1 = new PermissionSetAssignment();
		psa1.AssigneeId = UserInfo.getUserId();
		psa1.PermissionSetId = ps.Id;
		insert psa1;
		try{
			
			List<Knowledge__kav > articleList= new List<Knowledge__kav>();
			
			articleList.add([Select id, Title, urlName, RecordTypeId, ValidationStatus, CH_Workgroup__c, CH_InApproval__c, PublishStatus, CreatedById from Knowledge__kav where id =: testArticle.id]);
			
			CH_KnowledgeHandler_TL.validateIfUserCanDeleteArticle(articleList);
		}
		catch(Exception ex){
			
			
		}
		
	}
	@isTest
	public static void CH_Knowledge1(){
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		String orgId = UserInfo.getOrganizationId();
		 Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		  String dateString = 
		String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
	 String uniqueName = orgId + dateString + randomInt;
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
						  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
						  LocaleSidKey='en_US', ProfileId = p.Id,
						  TimeZoneSidKey='America/Los_Angeles',  UserName= uniqueName + '@test' + orgId + '.org');
		insert u;
		
		// Query your permission set name from Organization that your want to test.
		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CH_Author'];
		
		// Assign the above inserted user for the above Permission Set.
		PermissionSetAssignment psa = new PermissionSetAssignment();
		psa.AssigneeId = u.Id;
		psa.PermissionSetId = ps.Id;
		insert psa;
		
		// Run your code with inserted user.
		System.runAs(u)
		{
			Test.isRunningTest();
			Test.startTest();
			
			//Avoid Chain jobs in asynch Apex job
			CH_ManageCreateQueueAsynchQueue.doChainJob = false;
			
			//Create Workgroup
			List<CH_Workgroup__c> workGroups = new List<CH_Workgroup__c>();
			Id recordTypeId = Schema.SObjectType.CH_Workgroup__c.getRecordTypeInfosByDeveloperName().get('CH_KB_Workgroup').getRecordTypeId();
			String MemberRecTypeId = Schema.getGlobalDescribe().get('CH_Workgroup_Member__c').getDescribe().getRecordTypeInfosByName().get('CH_KB_WorkgroupMember').getRecordTypeId();
			CH_Workgroup__c workgroup = new CH_Workgroup__c(RecordTypeId = recordTypeId);
			workgroup.name = WORKGROUPNAME;
			workgroup.CH_End_of_Business_Hours_Threshold__c = 120;
			workgroup.CH_Start_of_Business_Hours_Threshold__c = 120;
			insert workgroup;
			
			CH_Workgroup_Member__c wgMember = new CH_Workgroup_Member__c();
			wgMember.CH_Workgroup__c = workgroup.id;
			wgMember.CH_User__c = UserInfo.getUserId();
			wgMember.CH_Role__c = 'Author';
			wgMember.RecordTypeId = MemberRecTypeId;
			insert wgMember;
			
			//Create Knowledge Article witch 'CH' Record Type
			String RecTypeId = Schema.getGlobalDescribe().get('Knowledge__kav').getDescribe().getRecordTypeInfosByName().get('How To').getRecordTypeId();
			//System.debug('RecTypeId'+RecTypeId);
			Knowledge__kav testArticle = new Knowledge__kav(Title = 'How To Test By Gizmo23131', urlName = 'HowToTestByGizmo1231231231', RecordTypeId = RecTypeId, ValidationStatus = 'Work in Progress', CH_PurposeRequired__c = 'd', CH_ProcedureRequired__c = 'Gizem is the best',CH_Workgroup__c = workgroup.id, CH_InApproval__c = false);
			testArticle.CH_ComingFromApprovalProcess__c = false;
			testArticle.CH_Candidate_for_External__c = false;   
			insert testArticle; 
			testArticle.CH_Minor_changes__c = true;
			testArticle.CH_ComingFromApprovalProcess__c = false;
			testArticle.CH_Candidate_for_External__c = false;
			testArticle.CH_InApproval__c = true;
			List<Knowledge__kav> articleList = new List<Knowledge__kav>();
			try{
				update testArticle;
			}
			catch(Exception ex){
				
			}
			
			articleList.add([Select id, Title, urlName, RecordTypeId, ValidationStatus, CH_Workgroup__c, CH_InApproval__c, PublishStatus, CreatedById from Knowledge__kav where id =: testArticle.id]);
			
			try{
				CH_KnowledgeHandler_TL.assignOwnerIfInApprovalStatus(articleList, articleList);
			}
			catch(Exception ex){
			}
			try{
				CH_KnowledgeHandler_TL.validateIfUserCanEditArticle(articleList);
			}
			catch(Exception ex){
			}
			
			
			try{
				CH_KnowledgeHandler_TL.validateIfUserCanDeleteArticle(articleList);
			}
			catch(Exception ex){
				
				
			}
			delete workgroup;
			Test.stopTest();
		}
	}
}