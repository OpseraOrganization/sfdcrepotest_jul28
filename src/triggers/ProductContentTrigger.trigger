trigger ProductContentTrigger on NCP_Product_Content__c (after insert,after update, after delete) {

	Set<Id> ids = new Set<Id>();
	System.Debug('#### trigger.old '+trigger.old);
	List<Product2> prToUpdate = new List<Product2>();
	Map<Id,List<Id>> mapPC = new Map<Id,List<Id>>();
		
	if(Trigger.isDelete){		
		for(NCP_Product_Content__c p:Trigger.old){
			 ids.add(p.NCP_Product__c);
		 }
	}else if(Trigger.isUpdate){
		for(NCP_Product_Content__c  pc:trigger.new){
			ids.add(pc.NCP_Product__c);
		}   
		for(NCP_Product_Content__c  pc:trigger.old){
			ids.add(pc.NCP_Product__c);
		}
   }else if(Trigger.isInsert){
		 for(NCP_Product_Content__c  pc:trigger.new){
			ids.add(pc.NCP_Product__c);
		}  
	}  
	for(NCP_Product_Content__c p:[select Id,NCP_Product__c from NCP_Product_Content__c where NCP_Product__c IN:ids]){
		 if(!mapPC.containsKey(p.NCP_Product__c)){
			mapPC.put(p.NCP_Product__c,new List<Id>());
			mapPC.get(p.NCP_Product__c).add(p.Id);			
		}else{
			mapPC.get(p.NCP_Product__c).add(p.Id); 
		}
	}
	system.Debug('#### mapPC '+mapPC);
	system.Debug('#### Product2 '+[select Id,NCP_Product_Content_Count__c from Product2 where id IN:ids]);
	for(Product2 p:[select Id,NCP_Product_Content_Count__c from Product2 where id IN:ids]){
		if( mapPC.get(p.Id) == null){
			p.NCP_Product_Content_Count__c = 0;
		}else{
			p.NCP_Product_Content_Count__c  = mapPC.get(p.Id).size();
		}
		prToUpdate.add(p);
	}	 
	
	update prToUpdate;

}