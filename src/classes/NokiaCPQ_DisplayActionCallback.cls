global with sharing class NokiaCPQ_DisplayActionCallback implements Apttus_Config2.CustomClass.IDisplayActionCallback{

	global static void start(Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2.DisplayActionInfo> disActionInfoList){		 

		//system.debug('***DisplayActionCallback > start() > DisActList: '+disActionInfoList + ' <> cart:' + cart);
		
		Apttus_Config2__ProductConfiguration__c standardConfig = cart.getConfigSO();
		
		Apttus_Proposal__Proposal__c maintenanceQuote = [Select id,NokiaCPQ_Is_Maintenance_Quote__c,NokiaCPQ_Portfolio__c from Apttus_Proposal__Proposal__c where id =:standardConfig.Apttus_QPConfig__Proposald__c];
		//system.debug('maintenanceQuote -->'+maintenanceQuote);
		if(maintenanceQuote.NokiaCPQ_Is_Maintenance_Quote__c == True) {
		
			for(Apttus_Config2.DisplayActionInfo actionInfoInst : disActionInfoList){
			   
				Apttus_Config2__ConfigCustomDisplayActions__c ActionSOInst = actionInfoInst.ActionSO;
				
				String actionName = ActionSOInst.Apttus_Config2__ActionLabelName__c;
				//system.debug('***DisplayActionCallback > Action Name: ' + actionName);
	
				//system.debug('***DisplayActionCallback > Before: ' + ActionSOInst.Apttus_Config2__ActionLabelName__c + ' <> ' + actionInfoInst.IsEnabled + ' <> ' +  actionInfoInst.ActionSO.Apttus_Config2__IsEnabled__c);
	

				if(actionName.equals('AddMoreProducts')) {
					// MAKE ACTION INVISIBLE!!!
					actionInfoInst.IsEnabled = false;
					actionInfoInst.ActionSO.Apttus_Config2__IsEnabled__c= false;
				}
			   
				//system.debug('***DisplayActionCallback > After: ' + ActionSOInst.Apttus_Config2__ActionLabelName__c + ' <> ' + actionInfoInst.IsEnabled + ' <> ' +  actionInfoInst.ActionSO.Apttus_Config2__IsEnabled__c);
	
			 }
		 }
		 
		 if(maintenanceQuote.NokiaCPQ_Portfolio__c != Nokia_CPQ_Constants.IP_ROUTING_STRING) {
		
			for(Apttus_Config2.DisplayActionInfo actionInfoInst : disActionInfoList){
			   
				Apttus_Config2__ConfigCustomDisplayActions__c ActionSOInst = actionInfoInst.ActionSO;
				String gppActionName = ActionSOInst.Apttus_Config2__ActionLabelName__c;
				if(gppActionName.equals('GPPPricing')) {
					// MAKE ACTION INVISIBLE!!!
					actionInfoInst.IsEnabled = false;
					actionInfoInst.ActionSO.Apttus_Config2__IsEnabled__c= false;
				}
			 }
		 }
	}
	
	
	global static void setActionProperties(Apttus_Config2.CustomClass.ActionParams actionParam){
		//System.debug('***DisplayActionCallback > setActionProperties() > actionParam: '+actionParam);
		  
	}
}