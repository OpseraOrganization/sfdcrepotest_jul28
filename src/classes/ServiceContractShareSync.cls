/**
* Created by bkandov on 06/06/2018.
*/

public with sharing class ServiceContractShareSync {

	private static final String RAW_CAUSE_OWNER = 'Owner';
	private static final String RAW_CAUSE_MANUAL = 'Manual';
	private static final String ACCESS_LEVEL_READ = 'Read';

	public static ServiceContractShare createNewInstance(Id recordId, Id userOrGroupId, String accessLevel) {
		// Create new sharing object for the custom object Service Contract.
		ServiceContractShare serviceContractShare = new ServiceContractShare();

		// Set the ID of record being shared.
		serviceContractShare.ParentId = recordId;

		// Set the ID of user or group being granted access.
		serviceContractShare.UserOrGroupId = userOrGroupId;

		// Set the access level.
		serviceContractShare.AccessLevel = accessLevel;

		return serviceContractShare;
	}

	public static void createServiceContractShares(Map<Id, Set<Id>> userIdsBySCIds) {

		System.debug('inside createServiceContractShares :: ' + userIdsBySCIds);

		List<ServiceContractShare> serviceContractShares = new List<ServiceContractShare>();
		for (Id SCId : userIdsBySCIds.keySet()) {
			for (Id userId : userIdsBySCIds.get(SCId)) {
				ServiceContractShare scShare = ServiceContractShareSync.createNewInstance(SCId, userId, ACCESS_LEVEL_READ);
				serviceContractShares.add(scShare);
			}
		}

		if (serviceContractShares.size() > 0) {
			List<ServiceContractShare> scSharesToInsert = new List<ServiceContractShare>();
			Integer count = 0;
			for (ServiceContractShare scShare : serviceContractShares) {
				scSharesToInsert.add(scShare);
				count ++;

				if (count == 1000) {
					count = 0;
					// create batch
					System.debug('batch run NCP_ServiceContractShareCreate_Batch :: ' + scSharesToInsert);
					Database.executeBatch(new NCP_ServiceContractShareCreate_Batch(scSharesToInsert));
					scSharesToInsert = new List<ServiceContractShare>();
				}
			}

			if (count > 0) {
				//create batch
				System.debug('batch run NCP_ServiceContractShareCreate_Batch :: ' + scSharesToInsert);
				Database.executeBatch(new NCP_ServiceContractShareCreate_Batch(scSharesToInsert));
			}
		}
	}

	public static void deleteServiceContractShares(Set<Id> scIdsToDelete) {

		List<ServiceContractShare> scSharesToDelete = [
				SELECT Id,ParentId,UserOrGroupId,AccessLevel,RowCause
				FROM ServiceContractShare
				WHERE ParentId IN:scIdsToDelete AND RowCause = :RAW_CAUSE_MANUAL
		];

		if (scSharesToDelete.size() > 0) {
			delete scSharesToDelete;
		}
	}

	public static void deleteSCSharesByUsers(Map<Id, Set<Id>> userIdsBySCIds) {

		List<ServiceContractShare> scShares = [
				SELECT Id,ParentId,UserOrGroupId,AccessLevel,RowCause
				FROM ServiceContractShare
				WHERE ParentId IN:userIdsBySCIds.keySet() AND RowCause = :RAW_CAUSE_MANUAL
		];

		List<ServiceContractShare> scSharesToDelete = new List<ServiceContractShare>();
		for (ServiceContractShare scShare : scShares) {

			String scId = scShare.ParentId;
			String userId = scShare.UserOrGroupId;
			if (userIdsBySCIds.get(scId).contains(userId)) {
				scSharesToDelete.add(scShare);
			}
		}

		if (scSharesToDelete.size() > 0) {
			delete scSharesToDelete;
		}
	}
}