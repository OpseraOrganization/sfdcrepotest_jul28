/**
 * Created by tweinberger on 06/09/2018.
 */

trigger ContractLineItemTrigger on ContractLineItem (before insert, before update, after insert, after update) {
	if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)) {
		new ContractLineItemTriggerHandler().run();
	
		if(Trigger.isBefore) {
			if(Trigger.isInsert) {
				CH_ContractLineItemTriggerHandler.beforeInsertOperation(Trigger.new);						 
			}
			if(Trigger.isUpdate) {
				CH_ContractLineItemTriggerHandler.beforeUpdateOperation(Trigger.oldMap, Trigger.new);						 
			}
		}
	} 
}