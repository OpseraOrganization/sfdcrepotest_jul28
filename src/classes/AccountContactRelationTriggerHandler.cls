/**
About
-----
Description: This Class is used as handler for AccountContactRelationTrigger Trigger .

Created for: Nokia Customer Portal
Created: 04 16 2018

Update History
--------------
Created: 04 16 2018 – aboukrim@salesforce.com
-------------
**/
public class AccountContactRelationTriggerHandler {

	/*
	* @description	  Check NCP_Entitlement_Relationship__c field update on AccountContactRelation.
	* @param			Act new Act updated data
	* @return		 
	*/

	public static void AccountContactRelationAfterOperation(Map<Id, AccountContactRelation> Act) {
		AccountContactRelationTriggerHelper.companyNameAfterUpadte(Act);
	}

	public static void AccountContactRelationBeforeInsertOperation(List<AccountContactRelation> actList) {
		AccountContactRelationTriggerHelper.companyNameBeforeInsert(actList);
	}

	public static void AccountContactRelationBeforeUpdateOperation(Map<Id, AccountContactRelation> newMap, List<AccountContactRelation> oldList) {
		//AccountContactRelationBeforeUpdateOperation(newMap, oldList);
		AccountContactRelationTriggerHelper.companyNameBeforeUpdate(newMap, oldList);
	}

	public static void createAccountContactShare(Map<Id, AccountContactRelation> newMap) {
		AccountContactRelationTriggerHelper.createAccountContactRelationShare(newMap);
	}

	public static void updateAccountContactShare(Map<Id, AccountContactRelation> newMap, Map<Id, AccountContactRelation> oldMap) {
		AccountContactRelationTriggerHelper.updateAccountContactRelationShare(newMap, oldMap);
	}

	public static void deleteAccountContactShare(List<AccountContactRelation> oldList) {
		AccountContactRelationTriggerHelper.deleteAccountContactRelationShare(oldList);
	}

}