/****************************************
 * Class Name : CH_EntitlementTriggerHandler 
 * Created Date: 25 September 2018
 * Created By : TCS
 * Last Modified by: TCS
 * Last Modified Date: 25 September 2018
 * Description : Handle the sequence of the CH_EntitlementTriggerHelper
 * Test Class: CH_EntitlementTriggerHelperTest 
 *****************************************/
public class CH_EntitlementTriggerHandler {
	/********************
	*Method Name: beforeInsertOperation
	*Parameter: New Entitlement List
	*Description: Used to handle before insert operation
	*******************/
	public static void beforeInsertOperation(List < Entitlement > newEntitlementList) {
		// Isolate CH_Entitlement Record Type
		newEntitlementList = isolateCaseHandlingRecordType(newEntitlementList);
		
		CH_EntitlementTriggerHelper.populateSLAProcessIds(newEntitlementList);
	}
	
	/********************
	*Method Name: beforeUpdateOperation
	*Parameter: Old Entitlement Map, New Entitlement List
	*Description: Used to handle before update operation
	*******************/
	public static void beforeUpdateOperation(Map < Id, Entitlement > oldEntitlementMap, List < Entitlement > newEntitlementList) {
		// Isolate CH_Entitlement Record Type
		newEntitlementList = isolateCaseHandlingRecordType(newEntitlementList);
		
		CH_EntitlementTriggerHelper.updateSLAProcessIds(oldEntitlementMap, newEntitlementList);
	}
	
	/********************
	*Method Name: afterInsertOperation
	*Parameter: New Entitlement List
	*Description: Used to handle before insert operation
	*******************/
	public static void afterInsertOperation(List < Entitlement > newEntitlementList) {
		// Isolate CH_Entitlement Record Type
		newEntitlementList = isolateCaseHandlingRecordType(newEntitlementList);
		
		CH_EntitlementTriggerHelper.updateContractLineItemRecordsOnInsert(newEntitlementList);
	}
	
	/********************
	*Method Name: afterUpdateOperation
	*Parameter: Old Entitlement Map, New Entitlement List
	*Description: Used to handle before update operation
	*******************/
	public static void afterUpdateOperation(Map < Id, Entitlement > oldEntitlementMap, List < Entitlement > newEntitlementList) {
		// Isolate CH_Entitlement Record Type
		newEntitlementList = isolateCaseHandlingRecordType(newEntitlementList);
		
		CH_EntitlementTriggerHelper.updateContractLineItemRecordsOnUpdate(oldEntitlementMap, newEntitlementList);
	}
	
	/********************
	*Method Name: isolateCaseHandlingRecordType
	*Parameter: New Entitlement List
	*Description: Used to filter Case Handling Record Type Records
	*******************/
	private static List < Entitlement > isolateCaseHandlingRecordType(List < Entitlement > newEntitlementList) {
		List < Entitlement > entList = new List < Entitlement > ();
		for (Entitlement entObj: newEntitlementList) {
			//Checks hidden field on Entitlement that is a formula field - boolean that returns true for the CH_Entitlement Record Types
			if (entObj.CH_RecordTypeCheck__c) {
				entList.add(entObj);
			}
		}
		return entList;
	}
}