Trigger Contacttrigger on Contact (after Insert,after Update, before update, before Insert) {
   if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id))
   {
	if(Trigger.isAfter){
		if(Trigger.isInsert){
			ContactTriggerHandler.afterInsertOperation(Trigger.New);
			ContactTriggerHandler.afterInsertOperation(Trigger.New,trigger.oldMap);
		}else if(Trigger.isUpdate)
			ContactTriggerHandler.afterUpdateOperation(Trigger.new,Trigger.oldMap);
	}
	
	if(Trigger.isBefore){ 
		ContactTriggerHandler.beforeOperation(Trigger.new, Trigger.oldMap);
			if(Trigger.isInsert)
				ContactTriggerHandler.beforeInsertOperation(Trigger.New);
			if(Trigger.isUpdate){
				ContactTriggerHandler.beforeUpdateOperation(Trigger.new);				
			}
		}
	}
}