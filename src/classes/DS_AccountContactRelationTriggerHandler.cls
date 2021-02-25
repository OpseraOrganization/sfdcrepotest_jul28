/*******************************
	Class name :DS_AccountContactRelationTriggerHandler	 
	Created by: Accenture
	Description: This handler is written for the Trigger on Account Contact Relationship object
	Team: Digital Sales
	*******************************/
public without sharing class DS_AccountContactRelationTriggerHandler {
/******************************************************************************************************
Name : checkRecordExist
Description : This method is used check if contact added for Logistics account(Tier 3) exists at Legal Account(Tier 2) or not.
Parameter : List of CurrentRecord ids, Map of newly inserted records
*********************************************************************************************************/	
   public static void checkRecordExist(List<AccountContactRelation> accountContactList,Map<Id,AccountContactRelation> accountContactRelationShipMap){
	   
	   try{
		
		Set<Id> accountIdSet  = new Set<Id>();
		for(AccountContactRelation obj : accountContactList) {
			accountIdSet.add(obj.AccountId);
		}
		System.debug('**********accountIdSet***************'+accountIdSet);
		Map<ID, Account> accMap  = new Map<ID, Account>([Select Id,RecordTypeId from Account where Id IN : accountIdSet and RecordType.Name =:CSWXGlobalConstant.recordTypeLogisticAccount LIMIT: (Limits.getLimitQueryRows() - Limits.getQueryRows())]);
		System.debug('*******accMap************'+accMap);
		LisT<AccountContactRelation> filterOnlyLogisitcAccountList = new List<AccountContactRelation>();
		System.debug('***************accountContactRelationShipMap*****************'+accountContactRelationShipMap.keySet());
		for(Id Key :  accountContactRelationShipMap.keySet()) {
			if(accMap.containsKey(accountContactRelationShipMap.get(Key).AccountId)) {
				filterOnlyLogisitcAccountList.add(accountContactRelationShipMap.get(Key));
			}
		}
		if(!filterOnlyLogisitcAccountList.isEmpty())
			DS_AccountContactRelationTriggerHelper.checkRecordExist(accountContactList);
		   
	   }catch(Exception ex){ExceptionHandler.addException(ex,CSWXGlobalConstant.DS_AccountContactRelationTriggerHandlerclass,CSWXGlobalConstant.checkRecordExistmethod);}
		
	}
}