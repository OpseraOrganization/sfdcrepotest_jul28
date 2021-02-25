/****************************************
 * Class Name : CH_ContractLineItemTriggerHelper 
 * Created Date: 02 September 2018
 * Created By : TCS
 * Last Modified by: Sónia Reis
 * Last Modified Date: 09 October 2019
 * Description : Contains common business logic
 * Test Class: CH_ContractLineItemTriggerTest
 *****************************************/
public class CH_ContractLineItemTriggerHelper {
	/********************
	* Method Name: updateLookupIds
	* Parameter: ContractLineItem
	* Description: Used to update lookup fields Id coming from Interface/CDB/CARES
	* Reference: NOKIASC-10907
	*******************/
	public static void updateLookupIds(Map < Id, ContractLineItem > oldLineItemMap, List < ContractLineItem > newLineItemList) {
		if(newLineItemList != null && !newLineItemList.isEmpty()) {
			List < ContractLineItem > lineItemList = new List < ContractLineItem > ();
			for(ContractLineItem lineItemObj: newLineItemList) {
				if(oldLineItemMap.get(lineItemObj.Id) != null) {
					ContractLineItem oldLineItemObj = oldLineItemMap.get(lineItemObj.Id);
					if(oldLineItemObj.CH_BusinessHourName__c != lineItemObj.CH_BusinessHourName__c || 
						oldLineItemObj.CH_CDB_EntitlementId__c != lineItemObj.CH_CDB_EntitlementId__c) {
							lineItemList.add(lineItemObj);
					}
				}
			}
			// Check if lineItemList has any records or not to process
			if(!lineItemList.isEmpty()) {
				populateLookupIds(lineItemList);
			}
		}
	}
	
	/********************
	* Method Name: populateLookupIds
	* Parameter: ContractLineItem
	* Description: Used to set lookup fields Id coming from Interface/CDB/CARES
	* Reference: NOKIASC-10907
	*******************/
	public static void populateLookupIds(List < ContractLineItem > newLineItemList) {
		if(newLineItemList != null && !newLineItemList.isEmpty()) {
			Set < String > businessHourNames = new Set < String > ();
			Set < String > pricebookEntryNames = new Set < String > ();
			Set < String > entitlementNames = new Set < String > ();
			for(ContractLineItem lineItemObj: newLineItemList) {
				businessHourNames.add(lineItemObj.CH_BusinessHourName__c);
				pricebookEntryNames.add(lineItemObj.CH_PriceBookEntry__c);
				entitlementNames.add(lineItemObj.CH_CDB_EntitlementId__c);
			}
			// Get all BusinessHours by its Name
			Map < String, Id > businessHourMap = new Map < String, Id > (); 
			if(!businessHourNames.isEmpty()) {
				for(BusinessHours businessHourObj: [SELECT Id, Name FROM BusinessHours WHERE Name IN :businessHourNames]) {
					businessHourMap.put(businessHourObj.Name, businessHourObj.Id);
				}	
			}
			// Get all PricebookEntry by its Name
			Map < String, Id > pricebookEntryMap = new Map < String, Id > (); 
			if(!pricebookEntryNames.isEmpty()) {
				for(PricebookEntry pricebookEntryObj: [SELECT Id, NCP_External_ID__c FROM PricebookEntry WHERE Name IN :pricebookEntryNames]) {
					pricebookEntryMap.put(pricebookEntryObj.NCP_External_ID__c, pricebookEntryObj.Id);
				}	
			}
			// Get all Entitlement by its External Id
			Map < String, Id > entitlementMap = new Map < String, Id > (); 
			if(!entitlementNames.isEmpty()) {
				for(Entitlement entObj: [SELECT Id, CH_CDB_EntitlementId__c FROM Entitlement WHERE CH_CDB_EntitlementId__c IN :entitlementNames]) {
					entitlementMap.put(entObj.CH_CDB_EntitlementId__c, entObj.Id);
				}	
			}
			// Iterate newLineItemList againt to set lookup fields Id
			for(ContractLineItem lineItemObj: newLineItemList) {
				if(businessHourMap.containsKey(lineItemObj.CH_BusinessHourName__c)) {
					lineItemObj.CH_BusinessHour__c = businessHourMap.get(lineItemObj.CH_BusinessHourName__c);
				} 
				if(pricebookEntryMap.containsKey(lineItemObj.CH_PriceBookEntry__c)) {
					lineItemObj.PricebookEntryId = pricebookEntryMap.get(lineItemObj.CH_PriceBookEntry__c);
				}
				if(entitlementMap.containsKey(lineItemObj.CH_CDB_EntitlementId__c)) {
					lineItemObj.CH_Entitlement__c = entitlementMap.get(lineItemObj.CH_CDB_EntitlementId__c);
				} 
			}
		}
	}
	
	/********************
	* Method Name: matchCountryName
	* Parameter: ContractLineItem
	* Description: Used to to populate Country Name by Country Code
	* Reference: NOKIASC-23472
	*******************/
	public static void populateCountryName(List <ContractLineItem> newLineItemList){
		List<ISO_Country_Codes__c> isoCodes =  [select id, name, country_name__c from ISO_Country_Codes__c]; 
		Map<String, String> codeToNameMap = new Map<String, String>();
		for(ISO_Country_Codes__c code :isoCodes){
			codeToNameMap.put(code.name, code.country_name__c);
		}
		for(ContractLineItem cli : newLineItemList){
			String countryCode = cli.CH_CountryISO2__c;
			if(!String.isBlank(countryCode)){
				String countryCodeUpperCase = countryCode.toUpperCase();
				if(codeToNameMap.containsKey(countryCodeUpperCase)){
					cli.CH_CountryISOName__c=codeToNameMap.get(countryCodeUpperCase);
					cli.CH_CountryISO2__c=countryCodeUpperCase;	//to pass all the codes to uppercase
				}
			}
		}
	}
	
   /* public static void updateEntitlementIds(Map < Id, ContractLineItem > oldLineItemMap, Map <Id, ContractLineItem> newLineItemList) {
		Map <Id,String> previousEntId = new Map<Id,String>();
		Map <Id,String> latestEntId = new Map<Id,String>();
		for(ContractLineItem lineItemId:oldLineItemMap.values())
		{
			If(lineItemId.CH_PreviousCDBEntitlementId__c!= NULL && newLineItemList.get(lineItemId.Id).get('CH_PreviousCDBEntitlementId__c') == NULL ){
				previousEntId.put(lineItemId.Id,lineItemId.CH_PreviousCDBEntitlementId__c);
				latestEntId.put(lineItemId.Id,lineItemId.CH_LatestCDBEntitlementId__c);
			}
		}
		system.debug('Prrev line item'+previousEntId+'Latest Line item'+latestEntId);
		List<ContractLineItem> cliList = [SELECT Id,CH_PreviousCDBEntitlementId__c,CH_LatestCDBEntitlementId__c,CreatedDate from ContractLineItem 
										  WHERE CH_CDB_EntitlementId__c =:previousEntId.values()];
		if(cliList.size()>0)
		{
			for(ContractLineItem cliToUpdate:cliList)
			{
				system.debug('CLI to update'+cliToUpdate);
			}
		}
		
	}*/
}