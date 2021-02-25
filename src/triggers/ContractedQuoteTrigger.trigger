/****************************************
* Trigger Name : ContractedQuoteTrigger 
* Created Date: 24 May 2019
* Created By : Accenture
* Description : This trigger copies quote records updates from EAI and load it in to Contracted_Quote__c staging object
***************************************/
trigger ContractedQuoteTrigger on Contracted_Quote__c (after insert, after update ) {
	
	if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
		if(Trigger.isAfter){
			if(Trigger.isInsert){
				GlobalConstants.IS_INBOUND = True;
				ContractedQuoteTriggerHandler.checkSurroundCQ(Trigger.New,null);
			}
			if(Trigger.isUpdate){
				GlobalConstants.IS_INBOUND = True;
				ContractedQuoteTriggerHandler.checkSurroundCQ(Trigger.New,Trigger.OldMap);
			}
		}
	}
}