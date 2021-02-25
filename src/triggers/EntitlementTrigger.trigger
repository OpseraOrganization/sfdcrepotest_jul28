/****************************************
* Trigger Name : EntitlementTrigger 
* Created Date: 25 September 2018
* Created By : TCS
* Last Modified by: TCS
* Last Modified Date: 25 September 2018
* Description : All Entitlement Related Actions will be tracked here
*****************************************/
trigger EntitlementTrigger on Entitlement (before insert, before update, after insert, after update) {
	if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)) {
		if(Trigger.isBefore) {
			if(Trigger.isInsert) {
				CH_EntitlementTriggerHandler.beforeInsertOperation(Trigger.new);						 
			}
			if(Trigger.isUpdate) {
				CH_EntitlementTriggerHandler.beforeUpdateOperation(Trigger.oldMap, Trigger.new);						 
			}
		}
		if(Trigger.isAfter) {
			if(Trigger.isInsert) {
				CH_EntitlementTriggerHandler.afterInsertOperation(Trigger.new);						 
			}
			if(Trigger.isUpdate) {
				CH_EntitlementTriggerHandler.afterUpdateOperation(Trigger.oldMap, Trigger.new);						 
			}
		}
	}
}