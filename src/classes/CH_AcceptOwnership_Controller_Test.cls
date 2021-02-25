@isTest
public class CH_AcceptOwnership_Controller_Test {

	@testSetup	
	static void setuptestdata()
	{  
		CH_TestDataFactory.setupCase(false);
	}
	
	/*
	@isTest
	public static void test() {
		test.starttest();
		Case newCase = CH_TestDataFactory.createCaseNotSaved('Test Case', 'Minor', 'No', 'Nokia Standard Case', false);
		newCase.CH_Workgroup__c = [SELECT Id FROM CH_Workgroup__c LIMIT 1].Id;
		newCase.OwnerId = UserInfo.getUserId();
		insert newCase;
		System.assertNotEquals(newCase.Id, null);
		CH_AcceptOwnership_Controller.validUser(newCase.Id);
		CH_AcceptOwnership_Controller.assignSelfOwnership(newCase.Id);
		test.stoptest();
	}*/
}