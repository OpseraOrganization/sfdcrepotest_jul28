/**
About
-----
Description: This Class is used as Helper for AccountContactRelationTrigger .

Created for: Nokia Customer Portal
Created: 04 16 2018

Update History
--------------
Created: 04 16 2018 – aboukrim@salesforce.com
-------------
**/
public with sharing class AccountContactRelationTriggerHelper {
	/*
* @description	  Check NCP_Entitlement_Relationship__c field update on AccountContactRelation.
* @param			Act new Act updated data
* @return		 
*/
	//private class AppException extends Exception {
	//}

	public static void companyNameAfterUpadte(Map<Id, AccountContactRelation> Act) {
		Set<Id> contactIdSet = new Set<Id>();
		Set<Id> AccountIdSet = new Set<Id>();
		Map<Id, String> acrIdSet = new Map<Id, String>();
		Map<Id, String> AccountNameIdSet = new Map<Id, String>();
		list<User> users = new list<User>();


		for (Id acrId : Act.keySet()) {
			if (Act.get(acrId).NCP_Entitlement_Relationship__c == True) {
				acrIdSet.put(Act.get(acrId).AccountId, Act.get(acrId).ContactId);
				AccountIdSet.add(Act.get(acrId).AccountId);
				contactIdSet.add(Act.get(acrId).ContactId);
			}
		}

		for (Account ac : [Select Name From Account Where Id in:AccountIdSet]) {
			AccountNameIdSet.put(acrIdSet.get(ac.Id), ac.Name);
		}

		for (User au : [Select id, ContactId, companyName From User Where contactId in:contactIdSet and isActive = true]) {

			String companyAccountName = AccountNameIdSet.get(au.ContactId);
			if (companyAccountName.length() > 80) {
				au.companyName = companyAccountName.substring(0, 80);
			} else {
				au.CompanyName = companyAccountName;
			}

			//au.companyName = AccountNameIdSet.get(au.ContactId);
			//au.companyName = AccountNameIdSet.get(au.ContactId).abbreviate(80);
			users.add(au);
		}
		update users;
	}

	public static void companyNameBeforeInsert(List<AccountContactRelation> actList) {

		Set<Id> contactIdSet = new Set<Id>();
		Map<Id, AccountContactRelation> acrIdSet = new Map<Id, AccountContactRelation>();

		for (AccountContactRelation acr : actList) {
			if (acr.NCP_Entitlement_Relationship__c == true) {
				acrIdSet.put(acr.contactId, acr);
				contactIdSet.add(acr.contactId);
			}
		}

		for (AccountContactRelation record : [SELECT contactId FROM AccountContactRelation WHERE NCP_Entitlement_Relationship__c = true And contactId in:contactIdSet]) {
			if (record.contactId != null) {
				acrIdSet.get(record.contactId).NCP_Entitlement_Relationship__c.addError(system.label.NCP_Account_Contact_Relationship_Error);
			}
		}
	}

	public static void companyNameBeforeUpdate(Map<Id, AccountContactRelation> newACRMap, List<AccountContactRelation> oldACR) {

		Set<Id> contactIdSet = new Set<Id>();
		Map<Id, AccountContactRelation> acrIdSet = new Map<Id, AccountContactRelation>();

		//for (AccountContactRelation acr : oldACR) {
		//	if (acr.NCP_Entitlement_Relationship__c == false &&
		//			newACRMap.get(acr.Id).NCP_Entitlement_Relationship__c == true) {
		//		acrIdSet.put(acr.contactId, acr);
		//		contactIdSet.add(acr.contactId);
		//	}
		//}
		for (AccountContactRelation acr : newACRMap.values()) {
			if (acr.NCP_Entitlement_Relationship__c == true) {
				for (AccountContactRelation oldAcrRec : oldACR) {
					if (oldAcrRec.id == acr.id && oldAcrRec.NCP_Entitlement_Relationship__c != true) {
						acrIdSet.put(acr.contactId, acr);
						contactIdSet.add(acr.contactId);
					}
				}
			}
		}

		for (AccountContactRelation record : [SELECT contactId FROM AccountContactRelation WHERE NCP_Entitlement_Relationship__c = true And contactId in:contactIdSet]) {
			if (record.contactId != null) {
				system.debug('acrIdSet : ' + acrIdSet);
				system.debug('ACR record in error: ' + acrIdSet.get(record.contactId));
				acrIdSet.get(record.contactId).NCP_Entitlement_Relationship__c.addError(system.label.NCP_Account_Contact_Relationship_Error);
				//throw new AppException(system.label.NCP_Account_Contact_Relationship_Error);
			}
		}

	}


	public static void createAccountContactRelationShare(Map<Id, AccountContactRelation> newACRMap) {

		Map<Id, Id> contactAccountRelation = new Map<Id, Id>();
		for (AccountContactRelation currentACR : newACRMap.values()) {
			if (currentACR.NCP_Entitlement_Relationship__c == true) {
				contactAccountRelation.put(currentACR.ContactId, currentACR.AccountId);
			}
		}

		Map<Id, Set<Id>> aCRUsers = new Map<Id, Set<Id>>();
		Map<Id, Set<Id>> scUsers = new Map<Id, Set<Id>>();
		Map<Id, Set<Id>> aeUsers = new Map<Id, Set<Id>>();
		system.debug('### AES contactAccountRelation ' + contactAccountRelation);
		getAccountSharing(contactAccountRelation, aCRUsers, scUsers, aeUsers);

		if (aCRUsers.size() > 0) {
			AccountShareSync.createAccountShares(aCRUsers);
		}

		if (scUsers.size() > 0) {
			ServiceContractShareSync.createServiceContractShares(scUsers);
		}

		if (aeUsers.size() > 0) {
			AuthorisedEntitlementShareSync.createAuthorisedEntitlementShares(aeUsers);
		}
	}

	private static void getAccountSharing(Map<Id, Id> contactAccountRelation,
			Map<Id, Set<Id>> aCRUsers, Map<Id, Set<Id>> scUsers, Map<Id, Set<Id>> aeUsers) {

		List<ServiceContract> serviceContracts = [
				SELECT Id,AccountId
				FROM ServiceContract
				WHERE NCP_External_Status__c = :NCP_Constants.STATUS_ACTIVE
				AND AccountId IN:contactAccountRelation.values()
		];

		Map<Id, Set<Id>> scByAccountIds = new Map<Id, Set<Id>>();
		for (ServiceContract currentSC : serviceContracts) {
			if (scByAccountIds.containsKey(currentSC.AccountId) == false) {
				scByAccountIds.put(currentSC.AccountId, new Set<Id>());
			}
			scByAccountIds.get(currentSC.AccountId).add(currentSC.Id);
		}
		system.debug('### AES scByAccountIds ' + scByAccountIds);
		List<NCP_Authorised_Entitlement__c> authorisedEntitlements = [
				SELECT Id,NCP_Account__c
				FROM NCP_Authorised_Entitlement__c
				WHERE NCP_External_Status__c = :NCP_Constants.STATUS_ACTIVE
				AND NCP_Account__c IN:contactAccountRelation.values()
		];

		Map<Id, Set<Id>> aeByAccountIds = new Map<Id, Set<Id>>();
		for (NCP_Authorised_Entitlement__c currentAE : authorisedEntitlements) {

			if (aeByAccountIds.containsKey(currentAE.NCP_Account__c) == false) {
				aeByAccountIds.put(currentAE.NCP_Account__c, new Set<Id>());
			}
			aeByAccountIds.get(currentAE.NCP_Account__c).add(currentAE.Id);
		}

		List<User> users = [SELECT Id, ContactId FROM User WHERE ContactId IN:contactAccountRelation.keySet() and isActive = true];

		for (User user : users) {
			String accountId = contactAccountRelation.get(user.ContactId);

			if (!aCRUsers.containsKey(accountId)) {
				aCRUsers.put(accountId, new Set<Id>());
			}
			aCRUsers.get(accountId).add(user.Id);

			if (scByAccountIds.containsKey(accountId)) {
				for (Id scId : scByAccountIds.get(accountId)) {
					if (scUsers.containsKey(scId) == false) {
						scUsers.put(scId, new Set<Id>());
					}
					scUsers.get(scId).add(user.Id);
				}
			}

			if (aeByAccountIds.containsKey(accountId)) {
				for (Id aeId : aeByAccountIds.get(accountId)) {
					if (aeUsers.containsKey(aeId) == false) {
						aeUsers.put(aeId, new Set<Id>());
					}
					aeUsers.get(aeId).add(user.Id);
				}
			}
		}
	}

	public static void updateAccountContactRelationShare(Map<Id, AccountContactRelation> newACRMap, Map<Id, AccountContactRelation> oldACRMap) {

		List<AccountContactRelation> deleteACCShares = new List<AccountContactRelation>();
		Map<Id, AccountContactRelation> addACCShares = new Map<Id, AccountContactRelation>();

		for (AccountContactRelation currentACR : newACRMap.values()) {

			AccountContactRelation oldACR = oldACRMap.get(currentACR.Id);

			// the Entitlement Relation stay true and the account/contact changed
			if (currentACR.NCP_Entitlement_Relationship__c == true
					&& oldACRMap.get(currentACR.Id).NCP_Entitlement_Relationship__c == true) {

				if ((oldACR.ContactId != currentACR.ContactId)
						|| (oldACR.AccountId != currentACR.AccountId)) {

					deleteACCShares.add(oldACR);
					addACCShares.put(currentACR.Id, currentACR);
				}
			}// Entitlement Relation changed to true
			else if (currentACR.NCP_Entitlement_Relationship__c == true
					&& oldACRMap.get(currentACR.Id).NCP_Entitlement_Relationship__c == false) {
				addACCShares.put(currentACR.Id, currentACR);
			} // Entitlement Relation changed to false
			else if (currentACR.NCP_Entitlement_Relationship__c == false
					&& oldACRMap.get(currentACR.Id).NCP_Entitlement_Relationship__c == true) {
				deleteACCShares.add(oldACR);
			}
		}

		if (addACCShares.size() > 0) {
			createAccountContactRelationShare(addACCShares);
		}

		if (deleteACCShares.size() > 0) {
			deleteAccountContactRelationShare(deleteACCShares);
		}
	}

	public static void deleteAccountContactRelationShare(List<AccountContactRelation> oldACRList) {

		Map<Id, Id> contactAccountRelation = new Map<Id, Id>();
		for (AccountContactRelation currentACR : oldACRList) {
			contactAccountRelation.put(currentACR.ContactId, currentACR.AccountId);
		}

		Map<Id, Set<Id>> aCRUsers = new Map<Id, Set<Id>>();
		Map<Id, Set<Id>> scUsers = new Map<Id, Set<Id>>();
		Map<Id, Set<Id>> aeUsers = new Map<Id, Set<Id>>();

		getAccountSharing(contactAccountRelation, aCRUsers, scUsers, aeUsers);

		if (aCRUsers.size() > 0) {
			AccountShareSync.deleteAccountShares(aCRUsers);
		}

		if (scUsers.size() > 0) {
//			ServiceContractShareSync.deleteSCSharesByUsers(scUsers);
			Database.executeBatch(new NCP_ServiceContractShare_Batch(scUsers, NCP_ServiceContractShare_Batch.SharingOperation.SHARING_DELETE), 1000);
		}

		if (aeUsers.size() > 0) {
			Database.executeBatch(new NCP_AuthEntitlementShareDelete_BATCH(aeUsers, NCP_AuthEntitlementShareDelete_BATCH.SharingOperation.SHARING_DELETE), 1000);
//			AuthorisedEntitlementShareSync.deleteAESharesByUsers(aeUsers);
		}
	}
}