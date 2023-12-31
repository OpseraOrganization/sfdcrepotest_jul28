/****************************************
 * Trigger Name : ContractTrigger 
 * Created Date: July 2018
 * Created By : Accenture
 * Last Modified by: Accenture
 * Last Modified Date: 
 * Description : All ContractTrigger Related Actions will be tracked here
 *****************************************/
trigger ContractTrigger on Contract (after update, after insert) {
	 if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)) {
		if(Trigger.isAfter){
			if(Trigger.isUpdate){
			System.debug(':::::Trigger.new::::::: ' +Trigger.new);
				ContractHandler.afterUpdateOperation(Trigger.new, Trigger.oldMap);
				
			}
			 if(Trigger.isInsert){
			System.debug(':::::Trigger.new::::::: ' +Trigger.new);
				ContractHandler.afterinsertOperation(Trigger.new);
				
			}
		}
   }
	   
}