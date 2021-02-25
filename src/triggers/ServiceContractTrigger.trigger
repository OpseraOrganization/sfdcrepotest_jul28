/****************************************
* Trigger Name : ServiceContractTrigger 
* Created Date: 31 August 2018
* Created By : TCS
* Last Modified by: TCS
* Last Modified Date: 31 August 2018
* Description : All ServiceContract Related Actions will be tracked here
*****************************************/
trigger ServiceContractTrigger on ServiceContract (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)) {
		new ServiceContractTriggerHandler().run();
	if(Trigger.isBefore) {
			if(Trigger.isInsert) {
				CH_ServiceContractTriggerHandler.beforeInsertOperation(Trigger.new);						 
			}
			if(Trigger.isUpdate) {
				CH_ServiceContractTriggerHandler.beforeUpdateOperation(Trigger.oldMap, Trigger.new);						 
			}
		}
		
		if(Trigger.isAfter) {
			if(CH_AvoidRecursion.runOnce()) {
				if(Trigger.isInsert) {
					CH_ServiceContractTriggerHandler.afterInsertOperation(Trigger.new); 
											
				}
			  }
			if(Trigger.isInsert || Trigger.isUpdate ) {
				CH_ServiceContractTriggerHandler.SharingServiceContractsRecords(Trigger.oldMap, Trigger.newMap);
			}
			  
		}
	} 
}