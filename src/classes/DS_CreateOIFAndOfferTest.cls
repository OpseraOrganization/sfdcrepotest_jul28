@isTest(seeAllData=true) 
public class DS_CreateOIFAndOfferTest {
	  
	private static Id oppDirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.CREATE_DIRECT_SALES_OPPORTUNITY).getRecordTypeId();
	
	 /******************************
	*Method Name: createOIFandOfferTest
	*Description: Test Method to cover OpportunityTriggerHelper class
	********************************/
	public testmethod static void createOIFandOfferTest(){
		Set<Id> accId = new Set<Id>();
			Map<Id,Opportunity> upsellProposalToOppty = new Map<Id,Opportunity>();
			user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
			insert userCreation;
		   
			system.runAs(userCreation){
			Test.startTest();
			
			List<Account> accountCreation = TestDataFactory.createAccount(2);
			accountCreation[0].AccountNumber = '3011234';
			accountCreation[1].AccountNumber = '3011235';
			database.insert(accountCreation);
			accId.add(accountCreation[0].Id);
			accId.add(accountCreation[1].Id);
			
			Id swxRecordTypeId = Schema.SObjectType.SWx_Upsell_Proposal__c.getRecordTypeInfosByName().get('SWx Upsell Proposal').getRecordTypeId();
			Id ccreRecordTypeId = Schema.SObjectType.SWx_Upsell_Proposal__c.getRecordTypeInfosByName().get('CCRE Upsell Proposal').getRecordTypeId();
		   
			List <SWx_Upsell_Proposal__c> upsellProposalList = TestDataFactory.upsellList(3,accountCreation[0]);
			upsellProposalList[0].Analytics_Source__c = CSWXGlobalConstant.AnalyticsSource;
			upsellProposalList[0].RecordTypeId= swxRecordTypeId;
			upsellProposalList[0].Proposal_Recommendation_Type__c = CSWXGlobalConstant.SW_Recommendation;
			upsellProposalList[0].Account_ID__c = accountCreation[0].id;
			upsellProposalList[0].Sold_To_Party__c = accountCreation[0].id;
			upsellProposalList[1].Analytics_Source__c = CSWXGlobalConstant.AnalyticsSource;
			upsellProposalList[1].RecordTypeId= swxRecordTypeId;
			upsellProposalList[1].Proposal_Recommendation_Type__c = CSWXGlobalConstant.HW_Recommendation;
			upsellProposalList[1].Account_ID__c = accountCreation[1].id;
			upsellProposalList[1].Sold_To_Party__c =accountCreation[1].id;
			upsellProposalList[2].Analytics_Source__c = 'CXM';//CSWXGlobalConstant.AnalyticsSource_CCRE;
			upsellProposalList[2].RecordTypeId= swxRecordTypeId; //ccreRecordTypeId;
			upsellProposalList[2].Account_ID__c = accountCreation[1].id;
			upsellProposalList[2].Proposal_Recommendation_Type__c = CSWXGlobalConstant.HW_Recommendation;
			upsellProposalList[2].Sold_To_Party__c =accountCreation[1].id;
				
			database.insert(upsellProposalList);
			System.assertEquals(accountCreation[0].id, upsellProposalList[0].Account_ID__c);
			System.assertEquals(accountCreation[1].id, upsellProposalList[1].Account_ID__c);
			System.assertEquals(accountCreation[1].id, upsellProposalList[2].Account_ID__c);	
			System.assertEquals( upsellProposalList[0].Analytics_Source__c, CSWXGlobalConstant.AnalyticsSource);
			System.assertEquals( upsellProposalList[1].Analytics_Source__c, CSWXGlobalConstant.AnalyticsSource);
		  //  System.assertEquals( upsellProposalList[2].Analytics_Source__c, CSWXGlobalConstant.AnalyticsSource_CCRE);
			
			Opportunity oppty ;
			oppty = TestDataFactory.OpportunityCreation(1,accountCreation[0])[0];
			oppty.StageName = CSWXGlobalConstant.DEVELOP_OPPTY;
			oppty.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.CREATE_DIRECT_SALES_OPPORTUNITY).getRecordTypeId();
			oppty.SWx_Upsell_Proposal__c =upsellProposalList[0].Id;
			oppty.Lead_BG__c ='MN';
			oppty.Phase_Status__c = CSWXGlobalConstant.Opty_phase_Status;
			
			

			database.insert(oppty);
		 
			List<Opportunity> optyCreation = TestDataFactory.OpportunityCreation(2,accountCreation[0]);
			optyCreation[0].SWx_Upsell_Proposal__c = upsellProposalList[0].Id;
			//optyCreation[0].SWx_Upsell_Proposal__c = null;
			optyCreation[0].Apttus_Approval__Approval_Status__c = CSWXGlobalConstant.Approval_stage_approved;
			optyCreation[0].ApprovalStatusTechField__c = CSWXGlobalConstant.Approved_G2;
			optyCreation[0].Approvals_Current_Status__c = CSWXGlobalConstant.Approved_G2;
			optyCreation[0].G2_Approval_Date__c = System.now();
			optyCreation[0].G3_Approval_Date__c = System.now();
			optyCreation[0].RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.CREATE_DIRECT_SALES_OPPORTUNITY).getRecordTypeId();
			optyCreation[0].StageName = GlobalConstants.DEVELOP_OPPORTUNITY;
		   // optyCreation[0].Phase_Status__c ='Submitted for G3 Approval';
			  optyCreation[0].Phase_Status__c = CSWXGlobalConstant.Opty_phase_Status;
			  optyCreation[0].Reference_Opportunity__c= oppty.id;
			
			
			
			/*optyCreation[1].SWx_Upsell_Proposal__c = upsellProposalList[2].Id;
			optyCreation[1].Apttus_Approval__Approval_Status__c = CSWXGlobalConstant.Approval_stage_approved;
			optyCreation[1].ApprovalStatusTechField__c = CSWXGlobalConstant.Approved_G2;
			optyCreation[1].Approvals_Current_Status__c = CSWXGlobalConstant.Approved_G2;
			optyCreation[1].G2_Approval_Date__c = System.now();
			optyCreation[1].G3_Approval_Date__c = System.now();
			optyCreation[1].RecordTypeId=oppDirectRecordTypeId;
			optyCreation[1].StageName = GlobalConstants.DEVELOP_OPPORTUNITY;
			optyCreation[1].Phase_Status__c ='Submitted for G3 Approval';
			*/
			
			database.insert(optyCreation);
			Apttus_Approval__Approval_Request__c approvalData = new Apttus_Approval__Approval_Request__c();
			approvalData.Apttus_Approval__Related_Opportunity__c = optyCreation[0].id;   
			database.insert(approvalData);	
			
			system.debug('optyCreation[0]--->'+optyCreation[0]);
			system.debug('optyCreation[0].SWx_Upsell_Proposal__c]--->'+optyCreation[0].SWx_Upsell_Proposal__c);
			system.debug('optyCreation[0].RecordType.DeveloperName--->'+optyCreation[0].RecordType.DeveloperName);
			system.debug('optyCreation[0].StageName--->'+optyCreation[0].StageName);
			
			//DS_CreateOIFAndOffer.createOIFandOfferonDigiSalesOpportunity(optyCreation);
				
			optyCreation[0].SWx_Upsell_Proposal__c = upsellProposalList[2].Id;
			database.update(optyCreation);
			 System.enqueueJob( new DS_CreateOIFAndOffer(optyCreation) );
			//DS_CreateOIFAndOffer.createOIFandOfferonDigiSalesOpportunity(optyCreation);	
		   // DS_CreateOIFAndOffer.createOIFandOfferonDigiSalesOpportunity(NULL);
		   // DS_CreateOIFAndOffer.UpdateApprovalHistoryData(optyCreation[0].Id);  
			Test.stopTest();
			} 
	}  

}