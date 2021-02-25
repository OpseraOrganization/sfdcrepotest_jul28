trigger salesorderreporting_trigger on Sales_Order_Reporting__c (Before insert, before update, after insert, after update, before delete, after delete) {

	if(Trigger.isafter){
		
		if(Trigger.isinsert){
			
			salesorderreporting_trigger_handler.AfterInsert(Trigger.New);
		}
		
		if(Trigger.isupdate){
			
			salesorderreporting_trigger_handler.AfterUpdate(Trigger.New);
		}
		
	   if(Trigger.isdelete){
			system.debug('Entered After delete in SO');
			salesorderreporting_trigger_handler.AfterDelete(Trigger.Old);
		}
	}
	
	if(Trigger.Isbefore){
		
		if(Trigger.Isinsert){
			salesorderreporting_trigger_handler.BeforeInsert(Trigger.New);
		}
		
		if(Trigger.Isupdate){
			system.debug('entered before update in trigger');
			salesorderreporting_trigger_handler.BeforeUpdate(Trigger.New,Trigger.oldmap,Trigger.newmap);
		}
		 
	}
	
}