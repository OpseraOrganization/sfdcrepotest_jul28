/****************************************
* Trigger Name : CustomerDocumentTrigger 
* Created Date: 09 July 2019
* Created By : Accenture
* Description : This trigger is for customer document object
***************************************/
trigger CustomerDocumentTrigger on Customer_Document__c (After update, After insert) {
	if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
		if(Trigger.isAfter){
			if(Trigger.isInsert){
				CustomerDocumentTriggerHandler.checkValidationOnCreate(Trigger.New);
			}

			if(Trigger.isUpdate){
				CustomerDocumentTriggerHandler.checkValidationOnUpdate(Trigger.New, Trigger.oldMap);
			}
		}
	}
}