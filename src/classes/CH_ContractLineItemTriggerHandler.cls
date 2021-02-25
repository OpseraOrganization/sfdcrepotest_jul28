/****************************************
 * Class Name : CH_ContractLineItemTriggerHandler
 * Created Date: 02 September 2018
 * Created By : TCS
 * Last Modified by: Sónia Reis
 * Last Modified Date: 09 October 2019
 * Description : Handle the sequence of the ContractLineItemTriggerHelper
 * Test Class: CH_ContractLineItemTriggerHelperTest
 *****************************************/
public class CH_ContractLineItemTriggerHandler {
	/********************
	*Method Name: beforeInsertOperation
	*Parameter: New ContractLineItem List
	*Description: Used to handle before insert operation
	*******************/
	public static void beforeInsertOperation(List < ContractLineItem > newLineItemList) {
		CH_ContractLineItemTriggerHelper.populateLookupIds(newLineItemList);
		CH_ContractLineItemTriggerHelper.populateCountryName(newLineItemList);
	}
	
	/********************
	*Method Name: beforeInsertOperation
	*Parameter: Old ContractLineItem Map, New ContractLineItem List
	*Description: Used to handle before update operation
	*******************/
	public static void beforeUpdateOperation(Map < Id, ContractLineItem > oldLineItemMap, List < ContractLineItem > newLineItemList) {
		CH_ContractLineItemTriggerHelper.updateLookupIds(oldLineItemMap, newLineItemList);
		CH_ContractLineItemTriggerHelper.populateCountryName(newLineItemList);
	}
	
	
	
	/*public static void afterUpdateOperation(Map < Id, ContractLineItem > oldLineItemMap, Map <Id, ContractLineItem> newLineItemList) {
		CH_ContractLineItemTriggerHelper.updateEntitlementIds(oldLineItemMap, newLineItemList);
	}*/
}