@isTest
public class OfferSnapshotCreationHelperTest
{
	private static final Id OpptyDirect = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.PRESALESRISKOPPORTUNITY_READONLY).getRecordTypeId();

	private static User user = new User();
	private static Opportunity oppty = new Opportunity();
	private static List<Offer__c> offers = new List<Offer__c>();
	private static final String market = GlobalConstants.Const_Market + ' ' + GlobalConstants.Const_Ind;


	private static void setup(String userProfile) {
		user = TestDataFactory.userCreation(1,userProfile)[0];
		database.insert(user);
		Account account = new Account();
		account = TestDataFactory.createAccount(1)[0];
		account.L4name__c = market;
		database.insert(account);
		oppty = TestDataFactory.OpportunityCreation(1,account)[0];
		database.insert(oppty);
		offers = TestDataFactory.OfferCreation(2,oppty);
	}


	static testMethod void excelAddInUpdate() {
		setup('Excel Add-In Profile');
		offers[0].Lead_BG__c = 'NSW';
		offers[0].Supporting_BG_MN__c = 'MN';
		offers[0].Supporting_BG_ION__c = 'ION';
		offers[0].Supporting_BU_ION_Optics__c = 'ION Optics';
		offers[0].Supporting_BU_ION_IPR__c = 'ION IPR';
		offers[0].Supporting_BG_GS__c = 'GS';
		offers[0].Supporting_BG_FN__c = 'FN';
		offers[0].Supporting_BG_NEN__c = 'NEN';
		offers[0].Supporting_BU_NE_DAaaS__c = 'NE DAaaS';
		offers[0].Supporting_BU_NE_EOP__c = 'NE EOP';
		offers[0].Supporting_BU_NE_IoT__c = 'NE IoT';
		database.insert(offers);
		Map<Id,Offer__c> offersMap = new Map<Id,Offer__c>(offers);

		System.runAs(user) {
			Test.startTest();
			OfferSnapshotCreationHelper.excelAddInUpdate(offersMap,offersMap);
			OfferSnapshotCreationHelper.excelAddInUpdate(null,null);
			Test.stopTest();
		}
	}

	static testMethod void validateOfferFieldEditForPricingManager() {
		setup('System Administrator');
		Offer__c offer = offers[0];
		offer.Approval_Scope__c = 'Pending';
		database.insert(offer);
		List<Offer_Team__c> offerTeamMemberList = TestDataFactory.offerTeamCreation(1, offer,user);
		Map<Id, Offer__c> filteredOfferMap = new Map<Id, Offer__c>{offer.Id => offer};
		Map<Id, Id> offerIdOpptyIdMap = new Map<Id, Id>{offer.Id => oppty.Id};

		System.runAs(user) {
			Test.startTest();
			database.insert(offerTeamMemberList);
			OfferSnapshotCreationHelper.validateOfferFieldEditForPricingManager(filteredOfferMap,offerIdOpptyIdMap);
			OfferSnapshotCreationHelper.validateOfferFieldEditForPricingManager(null,null);
			Test.stopTest();
		}
	}

	static testMethod void validateApprovalScopeTest() {
		setup('Excel Add-In Profile');
		Map<ID,Offer__c> offerMap = new map<Id,Offer__c>();
		Offer__c offer = offers[0];
		offer.Approval_Scope__c = 'Pending';
		offer.Customer_and_Competitive_Situation__c = 'Pending';
		system.runAs(user){
			insert offer;
			offerMap.put(offer.id,offer);
			OfferSnapshotCreationHelper.validateOfferFieldsLoA(offerMap,offerMap);
		}
	}

	static testMethod void validateLoABypassOfferConditionFieldValueTest(){

		Map<Id, Offer__c> newMap = new Map<Id, Offer__c>();
		Map<Id, Offer__c> oldMap = new Map<Id, Offer__c>();
		setup('System Administrator');
		Offer__c offer = offers[0];
		database.insert(offer);
		oldMap.put(offer.Id, offer);

		Sales_Role__c salesRoleRec = NF_TestDataFactory.createSalesRole(user,'NSNC_PrMBG',market,'4 - BG Pricing Manager');
		insert salesRoleRec;

		Offer_Team__c offerTeamObj = TestDataFactory.offerTeamCreation(1,offer,user)[0];
		offerTeamObj.Team_Member_Role__c = GlobalConstants.OFFER_OPPTY_TEAM_ROLE_PRICING_MANAGER;

		Offer__c offerToUpdate = offer.clone(true,true,true,true);
		offerToUpdate.LOA_Bypass__c=GlobalConstants.PICKLIST_VALUE_AUTHORIZED_FOR_PRICING_MANAGER;

		System.runAs(user)
		{
			Test.startTest();
			insert offerTeamObj;
			database.update(offerToUpdate);
			newMap.put(offerToUpdate.Id, offerToUpdate);
			OfferSnapshotCreationHelper.validateLoABypassOfferConditionFieldValue(oldMap,newMap);
			Test.stopTest();
		}
	}


	static testMethod void CatchException_Test()
	{
		user userCreation = TestDataFactory.userCreation(1,'Global Process Admin Profile')[0];
		database.insert(userCreation);
		system.runAs(userCreation){
			test.starttest();
			OfferSnapshotCreationHelper.validateLoABypassOfferConditionFieldValue(null,null);
			test.stopTest();
		}
	}

	static testMethod void updateOpportunity_ExceptionTest()
	{
		List<Opportunity> opptiesToUpdate = new List<Opportunity>();
		opptiesToUpdate.add(new Opportunity(Id=null));
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		database.insert(userCreation);

		system.runAs(userCreation){
			test.starttest();
			OfferSnapshotCreationHelper.updateOpportunity(opptiesToUpdate);
			test.stopTest();
		}
	}
}