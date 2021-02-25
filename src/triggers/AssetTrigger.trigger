/****************************************
* Trigger Name : AssetTrigger 
* Created Date: 25 September 2018
* Created By : TCS
* Last Modified by: TCS
* Last Modified Date: 11 November 2019
* Description : All Asset Related Actions will be tracked here
	 : Added functionality to create Covered NEA record automatically upon creation of NEA from CLI record page. 
*****************************************/
trigger AssetTrigger on Asset (before insert, before update, after insert) {
	if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)) {
		if(Trigger.isBefore) {
			if(Trigger.isInsert) {
				CH_AssetTriggerHandler.beforeInsertOperation(Trigger.new);						 
			}
			if(Trigger.isUpdate) {
				CH_AssetTriggerHandler.beforeUpdateOperation(Trigger.oldMap, Trigger.new);						 
			}
		}
		if(Trigger.isAfter){
			if(Trigger.isInsert){
			   CH_AssetTriggerHandler.afterInsertOperation(Trigger.new);
			}
		}
	}
}