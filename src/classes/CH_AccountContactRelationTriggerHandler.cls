/****************************************
 * Class Name : CH_AccountContactRelationTriggerHandler 
 * Created Date: 14 September 2018
 * Created By : TCS
 * Last Modified by: TCS
 * Last Modified Date: 14 September 2018
 * Description : Contains common business logic
 * Test Class: CH_AccountContactRelationTriggerTest
 *****************************************/
public class CH_AccountContactRelationTriggerHandler {
	/********************
	*Method Name: afterInsertOperation
	*Parameter: New AccountContactRelation List
	*Description: Used to handle after insert operation
	*******************/
	public static void afterInsertOperation(List < AccountContactRelation > newAccountContactList) {
		CH_AccountContactRelationTriggerHelper.createEntitlementContact(newAccountContactList);
	}
	
	/********************
	*Method Name: afterInsertOperation
	*Parameter: Old AccountContactRelation Map, New AccountContactRelation List
	*Description: Used to handle after update operation
	*******************/
	public static void afterUpdateOperation(Map < Id, AccountContactRelation > oldAccountContactMap, Map < Id, AccountContactRelation > newAccountContactMap) {
		CH_AccountContactRelationTriggerHelper.updateEntitlementContact(oldAccountContactMap, newAccountContactMap);
	}
	
	/********************
	*Method Name: afterDeleteOperation
	*Parameter: New AccountContactRelation List
	*Description: Used to handle before delete operation
	*******************/
	public static void afterDeleteOperation(List < AccountContactRelation > oldAccountContactList) {
		CH_AccountContactRelationTriggerHelper.deleteEntitlementContact(oldAccountContactList);
	}
}