trigger Agreement_Trigger on Apttus__APTS_Agreement__c (Before update) {
	if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
		if(Trigger.isBefore){
			
			
			if(Trigger.isUpdate){
				AgreementTriggerHandler.checkMandatoryFields(Trigger.new, Trigger.oldMap);
				
			}
			
			
		}
		
		
	}
}