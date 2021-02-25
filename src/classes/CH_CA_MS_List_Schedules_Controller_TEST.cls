@isTest
public class CH_CA_MS_List_Schedules_Controller_TEST {
		
	@testSetup	
	static void setuptestdata() {
		// Create workgroup with schedules
		CH_TestDataFactory.createProducts();
		CH_TestDataFactory.createNokiaUsers();
		CH_TestDataFactory.createAccounts();
		CH_TestDataFactory.createWorkgroups();
	}
	
	// Test that schedules can be retrieved
	@isTest
	static void TestGetSchedules() {
		CH_Workgroup__c workgroup = [SELECT Id FROM CH_Workgroup__c 
		WHERE Name = :CH_TestDataFactory.WORKGROUPNAME LIMIT 1];		
		List<CH_Workgroup_Schedule__c> schedules = CH_CA_MS_List_Schedules_Controller.getSchedules(workgroup.Id);
		System.assert(schedules.size() == 2, 'Expected 2 schedule. Actual ' + schedules.size());
	}
	
	// Test that the locale of the current user is retrieved correctly
	@isTest
	static void TestGetLocale() {
		User testUser = CH_TestDataFactory.createUser('CH_Agent','TEST');
		testUser.LocaleSidKey = 'fr_FR';
		System.runAs(testUser) {
			string locale = CH_CA_MS_List_Schedules_Controller.getLocale();
			System.assert(locale == 'fr-FR', 'Expected fr-FR. Actual ' + locale);
		}
		testUser = CH_TestDataFactory.createUser('CH_Agent','TEST2');
		testUser.LocaleSidKey = 'en_US';
		System.runAs(testUser) {
			string locale = CH_CA_MS_List_Schedules_Controller.getLocale();
			System.assert(locale == 'en-US', 'Expected en-US. Actual ' + locale);
		}
	}
	
	// Test that schedules can be deleted
	@isTest
	static void TestDeleteSelectedSchedules() {
		// Get all schedules for the workgroup
		CH_Workgroup__c workgroup = [SELECT Id FROM CH_Workgroup__c 
		WHERE Name = :CH_TestDataFactory.WORKGROUPNAME LIMIT 1];		
		List<CH_Workgroup_Schedule__c> schedules = CH_CA_MS_List_Schedules_Controller.getSchedules(workgroup.Id);
		System.assert(schedules.size() == 2, 'Expected 2 schedule. Actual ' + schedules.size());

		// Convert the found schedules in a list of IDs
		List<Id> scheduleIds = new List<Id>();
		for(CH_Workgroup_Schedule__c schedule : schedules){
			scheduleIds.add(schedule.id);
		}
		
		// Delete the schedules
		CH_CA_MS_List_Schedules_Controller.deleteSelectedSchedules(scheduleIds);
		schedules = CH_CA_MS_List_Schedules_Controller.getSchedules(workgroup.Id);
		System.assert(schedules.size() == 0, 'Expected 0 schedule. Actual ' + schedules.size());
	}
}