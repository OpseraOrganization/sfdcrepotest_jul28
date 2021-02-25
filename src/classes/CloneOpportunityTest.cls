@istest
Private class CloneOpportunityTest 
{
	private static List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
	//private static List<CloneObject__c> CloneRecord = new List<CloneObject__c>();
	private static final Id directRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.DIRECT_OPPTY).getRecordTypeId();
	private static final Id inDirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.INDIRECT_OPPTY).getRecordTypeId();
	private static List<Opportunity> optyCreation = new list<Opportunity>();
	private static List<OpportunityTeamMember> optyTeamList= new List<OpportunityTeamMember>();
	
	static testMethod void cloneOptyForDirectTest()
	{
		//List<OpportunityTeamMember> optyTeamList= new List<OpportunityTeamMember>();
		List<user> userCreation = TestDataFactory.userCreation(2,'System Administrator');
		insert userCreation;
		System.runAs(userCreation[0])
		{			
			List<CloneObject__c> CloneRecord = new List<CloneObject__c>();
			CloneObject__c cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'CloseDate';
			cloneObj.Name = 'CloseDate';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Name';
			cloneObj.Name = 'Test1';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'G3_Planned_Date__c';
			cloneObj.Name = 'G3_Planned_Date__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'G4_Planned_Date__c';
			cloneObj.Name = 'G4_Planned_Date__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'G5_Planned_Date__c';
			cloneObj.Name = 'G5_Planned_Date__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'G6_Planned_Date__c';
			cloneObj.Name = 'G6_Planned_Date__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Amount';
			cloneObj.Name = 'Amount';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'AccountId';
			cloneObj.Name = 'AccountId';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Contract_Signing_Entity__c';
			cloneObj.Name = 'Contract_Signing_Entity__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Business_Type__c';
			cloneObj.Name = 'Business_Type__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'RecordTypeId';
			cloneObj.Name = 'RecordTypeId';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Lead_BG__c';
			cloneObj.Name = 'Lead_BG__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Lead_BU__c';
			cloneObj.Name = 'Lead_BU__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			database.insert(CloneRecord);
			Account accountCreation = TestDataFactory.createAccount(1)[0];
			insert accountCreation;
			optyCreation = TestDataFactory.OpportunityCreation(1,accountCreation);
			//optyCreation[0].Lead_BG__c=GlobalConstants.LEAD_BG_MN;
			optyCreation[0].recordTypeId = directRecordTypeId;
			insert optyCreation;
			
			optyTeamList = TestDataFactory.optyTeamMemberCreation(2,userCreation[1],optyCreation[0]);
			optyTeamList[0].UserId = userCreation[0].Id;
			//optyTeamList[0].Additional_Team_Role__c = GlobalConstants.TRICON_SCO_ROLE+GlobalConstants.Semicolon+'Business Development';
			optyTeamList[0].Additional_Team_Role__c = 'Account Manager (TRICORN Sales Case Owner (SCO))'+GlobalConstants.Semicolon+'Business Development';
			optyTeamList[0].TeamMemberRole = 'Bid Manager';
			insert(optyTeamList);
			Opportunity opp = TestDataFactory.OpportunityCreation(1,accountCreation)[0];
			database.insert(opp);
			test.startTest();
			CloneOpportunity.getCloneOpp(optyCreation[0].id);
			CloneOpportunity.cloneOpportunityTeam(opp.id,optyCreation[0].id);
			CloneOpportunity.cloneOpportunityTeam(null,optyCreation[0].id);  
			test.stopTest();
		}
		
	}
	static testMethod void cloneOptyForIndirectTest()
	{
		//List<OpportunityTeamMember> optyTeamList= new List<OpportunityTeamMember>();
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		System.runAs(userCreation)
		{			
			List<CloneObject__c> CloneRecord = new List<CloneObject__c>();
			CloneObject__c cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'CloseDate';
			cloneObj.Name = 'CloseDate';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Name';
			cloneObj.Name = 'Test1';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'G3_Planned_Date__c';
			cloneObj.Name = 'G3_Planned_Date__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'G4_Planned_Date__c';
			cloneObj.Name = 'G4_Planned_Date__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'G5_Planned_Date__c';
			cloneObj.Name = 'G5_Planned_Date__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'G6_Planned_Date__c';
			cloneObj.Name = 'G6_Planned_Date__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Amount';
			cloneObj.Name = 'Amount';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'AccountId';
			cloneObj.Name = 'AccountId';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Contract_Signing_Entity__c';
			cloneObj.Name = 'Contract_Signing_Entity__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Business_Type__c';
			cloneObj.Name = 'Business_Type__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'RecordTypeId';
			cloneObj.Name = 'RecordTypeId';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Lead_BG__c';
			cloneObj.Name = 'Lead_BG__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Lead_BU__c';
			cloneObj.Name = 'Lead_BU__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Account_Role__c';
			cloneObj.Name = 'Account_Role__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'End_Customer__c';
			cloneObj.Name = 'End_Customer__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Indirect';
			CloneRecord.add(cloneObj);
			database.insert(CloneRecord);
			Account accountCreation = TestDataFactory.createAccount(1)[0];
			insert accountCreation;
			optyCreation = TestDataFactory.OpportunityCreation(1,accountCreation);
			//optyCreation[0].Lead_BG__c=GlobalConstants.LEAD_BG_MN;
			optyCreation[0].recordTypeId = inDirectRecordTypeId;
			insert optyCreation;
			
			optyTeamList = TestDataFactory.optyTeamMemberCreation(1,userCreation,optyCreation[0]);			
			insert(optyTeamList);
			Opportunity opp = TestDataFactory.OpportunityCreation(1,accountCreation)[0];
			database.insert(opp);
			test.startTest();
			CloneOpportunity.getCloneOpp(optyCreation[0].id);
			CloneOpportunity.cloneOpportunityTeam(opp.id,optyCreation[0].id);	
			test.stopTest();
		}
		
	}
	
	
	static testMethod void cloneClosedOppty()
	{
		//List<OpportunityTeamMember> optyTeamList= new List<OpportunityTeamMember>();
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		System.runAs(userCreation)
		{			
			List<CloneObject__c> CloneRecord = new List<CloneObject__c>();
			CloneObject__c cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'CloseDate';
			cloneObj.Name = 'CloseDate';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Name';
			cloneObj.Name = 'Test1';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'G3_Planned_Date__c';
			cloneObj.Name = 'G3_Planned_Date__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'G4_Planned_Date__c';
			cloneObj.Name = 'G4_Planned_Date__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'G5_Planned_Date__c';
			cloneObj.Name = 'G5_Planned_Date__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'G6_Planned_Date__c';
			cloneObj.Name = 'G6_Planned_Date__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Amount';
			cloneObj.Name = 'Amount';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'AccountId';
			cloneObj.Name = 'AccountId';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Contract_Signing_Entity__c';
			cloneObj.Name = 'Contract_Signing_Entity__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Business_Type__c';
			cloneObj.Name = 'Business_Type__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'RecordTypeId';
			cloneObj.Name = 'RecordTypeId';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Lead_BG__c';
			cloneObj.Name = 'Lead_BG__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			cloneObj = new CloneObject__c();
			cloneObj.Field_API__c = 'Lead_BU__c';
			cloneObj.Name = 'Lead_BU__c';
			cloneObj.Object__c = 'Opportunity';
			cloneObj.Record_Type__c = 'Direct';
			CloneRecord.add(cloneObj);
			database.insert(CloneRecord);
			Account accountCreation = TestDataFactory.createAccount(1)[0];
			insert accountCreation;
			optyCreation = TestDataFactory.OpportunityCreation(1,accountCreation);
			optyCreation[0].recordTypeId = directRecordTypeId;
			optyCreation[0].Amount = 0;
			insert optyCreation;
			
			optyCreation[0].stageName = GlobalConstants.CANCELLED_BY_CUSTOMER;
			update optyCreation[0];
			
			test.startTest();
			CloneOpportunity.getCloneOpp(optyCreation[0].id);
			test.stopTest();
		}
		
	}
	
	
	static testMethod void cloneOptyTestNegative()
	{
		try
		{
			user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
			insert userCreation;
			system.runAs(userCreation)
			{  
	CloneOpportunity.getCloneOpp(null);
	CloneOpportunity.cloneOpportunityTeam(null,null);
			}
		}
		Catch(Exception ex){
			system.debug('Exception :: '  +  ex);
		}  
	}
	static testMethod void cloneOptyTestNonSalesProfile()
	{
		try
		{
			List<OpportunityTeamMember> optyTeamList= new List<OpportunityTeamMember>();
			user userCreation = TestDataFactory.userCreation(1,'Non-Sales User Profile')[0];
			insert userCreation;
			system.runAs(userCreation)
			{			
	Account accountCreation = TestDataFactory.createAccount(1)[0];
	insert accountCreation;
	list<Opportunity> optyCreation = TestDataFactory.OpportunityCreation(1,accountCreation);
	insert optyCreation;
	optyTeamList = TestDataFactory.optyTeamMemberCreation(1,userCreation,optyCreation[0]);
	insert(optyTeamList);
	//Updating oppty with PTA= True and stage to'Handover (Prepare for Delivery)'
	
	Opportunity opp = TestDataFactory.OpportunityCreation(1,accountCreation)[0];
	database.insert(opp);
	test.startTest();
	CloneOpportunity.getCloneOpp(optyCreation[0].id);
	CloneOpportunity.cloneOpportunityTeam(opp.id,optyCreation[0].id);	
	test.stopTest();
			}
			
		}   
		Catch(Exception ex)
		{
			system.debug('Exception :: '  +  ex); 
		}		
	}
}