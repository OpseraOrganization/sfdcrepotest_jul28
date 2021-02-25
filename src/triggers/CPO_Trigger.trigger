trigger CPO_Trigger on Apttus_Config2__CustomerPurchaseOrder__c (Before insert, Before update,After update, After insert) {
 if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
		if(Trigger.isBefore){

			
			if(Trigger.isUpdate){
				CPOTriggerHandler.checkMandatoryFields(Trigger.new, Trigger.oldMap);
					
			}
			
		  
		}
		
		if(Trigger.isAfter) {
			if(Trigger.isUpdate){
			 
				CPOTriggerHandler.createEntitlement(Trigger.new, Trigger.oldMap);
					
			}
		 
			if(Trigger.isInsert){
				CPOTriggerHandler.shareCSMandCDMwithCustomer(Trigger.new);
			}
			  
		}
}
}