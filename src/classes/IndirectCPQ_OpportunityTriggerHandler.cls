/******************************************************************************************************
Name : IndirectCPQ_OpportunityTriggerHandler
Created by: Accenture
Description : Handler class for Indirect CPQ to handle Opportunity Trigger process.		
*********************************************************************************************************/
public class IndirectCPQ_OpportunityTriggerHandler {
/******************************
*Method Name: beforeInsert
*Description: This Method is used to handle before insert logic for Opportunity trigger.
 ********************************/   
  public static void beforeInsert(List<Opportunity> optyList){
		List <Opportunity> optyToUpdate = new List<Opportunity>();
		Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
		System.debug('RecordtypeMAp>>'+rtMap);
		for(Opportunity optyRecord  : optyList){
			if(rtMap.get(optyRecord.RecordTypeId).getName().equals(GlobalConstants.IndirectOpportunityPartner) ){
			   optyToUpdate.add(optyRecord); 
			}
		} 
		if((FeatureManagement.checkPermission(GlobalConstants.CustomPermission_CPQPartnerUser) || 
		   FeatureManagement.checkPermission(GlobalConstants.custompermission_PartnerSalesManager)) && !optyToUpdate.isEmpty()
		  ){
			IndirectCPQ_OpportunityTriggerHelper.completeOpptyInfo(optyToUpdate);
		}
		
	}
/******************************
*Method Name: afterInsert
*Description: This Method is used to handle after insert logic for Opportunity trigger.
 ********************************/ 
	public static void afterInsert(List<Opportunity> optyList){
		List <Opportunity> optyToUpdate = new List<Opportunity>();
		Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
		System.debug('RecordtypeMAp>>'+rtMap);
		for(Opportunity optyRecord  : optyList){
			if(rtMap.get(optyRecord.RecordTypeId).getName().equals(GlobalConstants.INDIRECT_OPPTY)  && optyRecord.isPartnerOpportunity__c){
			   optyToUpdate.add(optyRecord); 
			}
		} 
		 if((FeatureManagement.checkPermission(GlobalConstants.CustomPermission_CPQPartnerUser) ||
			FeatureManagement.checkPermission(GlobalConstants.custompermission_PartnerSalesManager)) && !optyToUpdate.isEmpty()
		   ){
		 IndirectCPQ_OpportunityTriggerHelper.updateOpty_afterinsert(optyToUpdate);
		 }
   
	}
	
/******************************
*Method Name: optyOwnertoPartnerSharing
*Description: This Method is used to share Opportunity Owner record with Partner users when Account owner is different from Opportunity owner.
 ********************************/	 
	/*public static void optyOwnertoPartnerSharing(List<Opportunity> opptyList,Map<Id,Opportunity>oldmap){
		List <Opportunity> optyToUpdate = new List<Opportunity>();
		Map<ID, Schema.RecordTypeInfo> recordtypeMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById(); 
		Set<Id> opptyIdSet = new Set<Id>();
		
		for(opportunity oppty : opptyList){
			opptyIdSet.add(oppty.Id);
		}
		
		for(opportunity oppty : [Select ID,RecordTypeId, OwnerId, Account.OwnerID from opportunity where ID IN: opptyIdSet]){
			
			if(Oldmap!=null && !oldmap.isEmpty()&& oldmap.containsKey(oppty.Id)){
				
				if( !oppty.OwnerID.equals(oldmap.get(oppty.Id).OwnerID) &&
				   recordtypeMap.get(oppty.RecordTypeId).getName().equals(GlobalConstants.INDIRECT_OPPTY)  && 
				   !oppty.Account.OwnerID.equals(oppty.OwnerID) ){
					   optyToUpdate.add(oppty); 
				   } 
			}
			else{
				
				if(recordtypeMap.get(oppty.RecordTypeId).getName().equals(GlobalConstants.INDIRECT_OPPTY)  && 
				   !oppty.Account.OwnerID.equals(oppty.OwnerID) ){
					   optyToUpdate.add(oppty);  
				   }
				
			}
			
		}
		System.debug('optyToUpdate>>>>'+optyToUpdate);
		if(!optyToUpdate.isEmpty() && optyToUpdate!= Null){
			IndirectCPQ_OpportunityTriggerHelper.optyOwnertoPartnerSharing_Helper(optyToUpdate);			  
		}
		
	} */ 
	
}