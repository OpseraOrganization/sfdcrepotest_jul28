public class CH_CA_MS_List_Schedules_Controller {
	
	// Get the schedules for a workgroup
	@AuraEnabled
	public static List<CH_Workgroup_Schedule__c> getSchedules(Id workgroupId){
		List<CH_Workgroup_Schedule__c> workgroupSchedules;
		workgroupSchedules = [SELECT Id, CH_Active__c, Name, CH_Start_DateTime__c, CH_End_DateTime__c,
					 (SELECT CH_Region__c, CH_Country__c, CH_Outage__c, CH_Severity__c, CH_Workgroup_Type__c,CH_LevelOfSupport__c	
					   FROM CH_Workgroup_Filters__r)
					 FROM CH_Workgroup_Schedule__c 
							  WHERE CH_Workgroup__c =:workgroupId
							  ORDER BY CH_Start_DateTime__c, Name];

		return workgroupSchedules;
	}

	// Get the locale of the logged i user
	// getLocale() returns en_US this is converted to international standard of en-US
	@AuraEnabled
	public static string getLocale(){
		String userLocale = UserInfo.getLocale();
		return userLocale.replace('_','-');
	}
	
	// Delete the selected rows and return the status of the deletion
	@AuraEnabled
	public static string deleteSelectedSchedules(List<id> selectedScheduleIds){
		//Delete the schedules
		List<CH_Workgroup_Schedule__c> selectedSchedules;
		selectedSchedules = [SELECT Id FROM CH_Workgroup_Schedule__c WHERE Id in :selectedScheduleIds];
		
		return CH_CA_MS_Util.deleteSelectedObjects(selectedSchedules, 'schedule');
	}
}