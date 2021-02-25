/****************************************
 * Trigger Name : cloneOfferTeam 
 * Created Date: 7th November 2016
 * Created By : Accenture
 * Last Modified by: Accenture
 * Last Modified Date: 23rd November 2016
 * Description: All Opportunity events are handled here
 * @History add code to notify validators and contributors of an opportunity once approved or rejected by an approver
 *****************************************/
trigger OpportunityTrigger on Opportunity (before insert,after insert, before Update, after update, before Delete, after Delete) {
	if(!Nokia_CPQ_Constants.isCloneRun){
	// DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow('OpportunityTrigger', 'Opportunity');
		if(Trigger.isBefore){
			
			if(Trigger.isUpdate){
	OpportunityTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
	//3.1 Sprint 2 Requirement No#3519
	 OpportunityTriggerHandlerPRM.recordTypeUpdate(Trigger.oldMap,Trigger.newMap);
			}
			if(Trigger.isInsert){
	//calling setAluasTrue method from OpportunityTriggerHelper class
	IndirectCPQ_OpportunityTriggerHandler.beforeInsert(Trigger.new);
	OpportunityTriggerHandler.beforeInsert(Trigger.new);
	
			}
			if(Trigger.isDelete){
	//calling LockPreSalesOppty Method
	//OpportunityTriggerHandler.beforeDelete(Trigger.oldMap);
			}
	
		}
		if(Trigger.isAfter){
			if(Trigger.isInsert){
	//Opportunity follow(Req: 722)
	OpportunityTriggerHandler.afterInsert(trigger.new);
	//IR on Oppty (PRM sprint 2.1)   
	  OpportunityTriggerHandlerPRM.afterInsert(trigger.new);
	  
	   OpportunityTriggerHandlerPRM.ShareOpptyWithApprover(Trigger.newMap);//US-1220
	// For Req #5669
	
	// OpportunityTriggerHelper.updateCustomerOfferDueDate(Trigger.newMap,Trigger.oldMap);
	 IndirectCPQ_OpportunityTriggerHandler.afterInsert(Trigger.new);
	 //IndirectCPQ_OpportunityTriggerHandler.optyOwnertoPartnerSharing(Trigger.new,null);
			}
			if(Trigger.isDelete){
	OpportunityTriggerHandler.afterDelete(Trigger.oldMap);
	}
		}	
		
	  if(Trigger.isAfter &&  Trigger.isUpdate){
	System.debug('After Update Opp Trigger');
	OpportunityTriggerHandlerPRM.afterUpdate(Trigger.new[0],Trigger.Old[0]);
			//calling notify opportunity related users method from OpportunityTriggerHelper class
			OpportunityTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
			//IR on Oppty (PRM sprint 2.1)		  
	  OpportunityTriggerHandlerPRM.afterUpdateOppty(Trigger.oldMap,Trigger.newMap);		  
	//req 3053		 
	  OpportunityTriggerHandlerPRM.afterOTMDelete(Trigger.old[0],Trigger.new[0]);   
	  
	OpportunityTriggerHandlerPRM.ShareOpptyWithApprover(Trigger.newMap);//US-1220
	//IndirectCPQ_OpportunityTriggerHandler.optyOwnertoPartnerSharing(Trigger.new,Trigger.oldMap);
	// For Req #5669
	
	 //OpportunityTriggerHelper.updateCustomerOfferDueDate(Trigger.newMap,Trigger.oldMap);
		} 

		/*if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
			
			if(!System.Test.isRunningTest() && System.IsBatch() == false){
	NF_TL_SynchOppRestAPI.SynchCrossOrgOpps(Trigger.new);
			}
		}
		*/
	  //  if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
	  //DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus('OpportunityTrigger', 'Opportunity', DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow);
	  //}
	}
}