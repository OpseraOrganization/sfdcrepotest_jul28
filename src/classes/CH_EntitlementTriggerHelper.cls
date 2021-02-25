/****************************************
 * Class Name : CH_EntitlementTriggerHelper 
 * Created Date: 25 September 2018
 * Created By : TCS
 * Last Modified by: TCS
 * Last Modified Date: 25 September 2018
 * Description : Handle the sequence of the CH_EntitlementTriggerHelper
 * Test Class: CH_EntitlementTriggerHelperTest 
 ************/
public class CH_EntitlementTriggerHelper {
	/********************
	* Method Name: populateSLAProcessId
	* Parameter: List < Entitlement >
	* Description: Used to populate SLA Id based on Service Mapping Id
	* Reference: NOKIASC-13109
	*******************/
	public static void populateSLAProcessIds(List < Entitlement > newEntitlementList) {
		if(newEntitlementList != null && !newEntitlementList.isEmpty()) {
			Set < String > slaProcessNames = new Set < String > ();
			Set < String > contractLineItemExtIds = new Set < String > ();
			for(Entitlement entObj: newEntitlementList) {
				slaProcessNames.add(entObj.CH_ServiceMappingId__c);
				contractLineItemExtIds.add(entObj.CH_CDB_EntitlementId__c);
			}
			
			// Query to get relevant EntitlementProcess as per provided CH_ServiceMappingId__c
			Map < String, Id > slaProcessNameMap = new Map < String, Id > ();
			if(!slaProcessNames.isEmpty()) {
				List < SLAProcess > slaProcessList = [SELECT Id, Name FROM SLAProcess WHERE Name IN :slaProcessNames AND SobjectType = 'Case' AND IsVersionDefault = true AND IsActive = true];
				if(slaProcessList != null && !slaProcessList.isEmpty()) {
					for(SLAProcess slaObj: slaProcessList) {
						slaProcessNameMap.put(slaObj.Name, slaObj.Id);
					}
				}	
			}
			
			// Query to get relevant ContractLineItem records as per provided CH_CDB_EntitlementId__c
			Map < String, ContractLineItem > contractLineItemExtMap = new Map < String, ContractLineItem > ();
			if(!contractLineItemExtIds.isEmpty()) {
				List < ContractLineItem > cliList = [SELECT Id, CH_ServiceOffering__c, CH_CDB_EntitlementId__c FROM ContractLineItem WHERE CH_CDB_EntitlementId__c IN :contractLineItemExtIds];
				if(cliList != null && !cliList.isEmpty()) {
					for(ContractLineItem cliObj: cliList) {
						contractLineItemExtMap.put(cliObj.CH_CDB_EntitlementId__c, cliObj);
					}
				}
			}
			
			if(!slaProcessNameMap.isEmpty() || !contractLineItemExtMap.isEmpty()) {
				for(Entitlement entObj: newEntitlementList) {
					// Set EntitlementProcess 
					if(slaProcessNameMap.containsKey(entObj.CH_ServiceMappingId__c)) {
						entObj.SLAProcessId = slaProcessNameMap.get(entObj.CH_ServiceMappingId__c);
					}
					// Set CLI Reference and CH_ServiceOffering__c from ContractLineItem
					if(contractLineItemExtMap.containsKey(entObj.CH_CDB_EntitlementId__c)) {
						ContractLineItem tempObj = contractLineItemExtMap.get(entObj.CH_CDB_EntitlementId__c);
						entObj.ContractLineItemId = tempObj.Id;
						if(entObj.CH_EntitlementType__c == 'Entitled Asset' && String.isNotBlank(tempObj.CH_ServiceOffering__c)) {
							entObj.Name = tempObj.CH_ServiceOffering__c;
						}
					}
				}
			}
		}
	}
	
	
	/********************
	* Method Name: updateSLAProcessId
	* Parameter: Map < Id, Entitlement >, List < Entitlement >
	* Description: Used to populate SLA Id based on Service Mapping Id
	* Reference: NOKIASC-13109
	*******************/
	public static void updateSLAProcessIds(Map < Id, Entitlement > oldEntitlementMap, List < Entitlement > newEntitlementList) {
		if(newEntitlementList != null && !newEntitlementList.isEmpty()) {
			List < Entitlement > entList = new List < Entitlement > ();
			for(Entitlement entObj: newEntitlementList) {
				if(oldEntitlementMap.get(entObj.Id) != null) {
					Entitlement oldEntObj = oldEntitlementMap.get(entObj.Id);
					if(oldEntObj.CH_ServiceMappingId__c != entObj.CH_ServiceMappingId__c || 
						oldEntObj.CH_CDB_EntitlementId__c != entObj.CH_CDB_EntitlementId__c) {
						entList.add(entObj);
					}
				}
			}
			// Check if entList has any records or not to process
			if(!entList.isEmpty()) {
				populateSLAProcessIds(entList);
			}
		}	
	}
	
	/********************
	* Method Name: updateContractLineItemRecordsOnInsert
	* Parameter: List < Entitlement >
	* Description: Used to update contract line records with CH_Entitlement__c reference
	* Reference: NOKIASC-13231
	*******************/
	public static void updateContractLineItemRecordsOnInsert(List < Entitlement > newEntitlementList) {
		if(newEntitlementList != null && !newEntitlementList.isEmpty()) {
			Map < String, Id > entitlementExtMap = new Map < String, Id > ();
			for(Entitlement entObj: newEntitlementList) {
				if(String.isNotBlank(entObj.CH_CDB_EntitlementId__c)) {
					entitlementExtMap.put(entObj.CH_CDB_EntitlementId__c, entObj.Id);	
				}
			}
			
			if(!entitlementExtMap.isEmpty()) {
				List < ContractLineItem > cliList = [SELECT Id, CH_Entitlement__c, CH_CDB_EntitlementId__c FROM ContractLineItem WHERE CH_CDB_EntitlementId__c IN :entitlementExtMap.keySet()];
				if(cliList != null && !cliList.isEmpty()) {
					for(ContractLineItem cliObj: cliList) {
						if(entitlementExtMap.containsKey(cliObj.CH_CDB_EntitlementId__c)) {
							cliObj.CH_Entitlement__c = entitlementExtMap.get(cliObj.CH_CDB_EntitlementId__c);
						}
					}
					// Update ContractLineItem List
					try {
						update cliList;
					} catch(Exception ex) {
						System.debug('#### ' + ex.getMessage());
					}
				}
			}
		}
	}
	
	/********************
	* Method Name: updateContractLineItemRecordsOnUpdate
	* Parameter: Map < Id, Entitlement >, List < Entitlement >
	* Description: Used to update contract line records with CH_Entitlement__c reference
	* Reference: NOKIASC-13231
	*******************/
	public static void updateContractLineItemRecordsOnUpdate(Map < Id, Entitlement > oldEntitlementMap, List < Entitlement > newEntitlementList) {
		if(newEntitlementList != null && !newEntitlementList.isEmpty()) {
			List < Entitlement > entList = new List < Entitlement > ();
			for(Entitlement entObj: newEntitlementList) {
				if(oldEntitlementMap.get(entObj.Id) != null) {
					Entitlement oldEntObj = oldEntitlementMap.get(entObj.Id);
					if(oldEntObj.CH_CDB_EntitlementId__c != entObj.CH_CDB_EntitlementId__c) {
						entList.add(entObj);
					}
				}
			}
			// Check if entList has any records or not to process
			if(!entList.isEmpty()) {
				updateContractLineItemRecordsOnInsert(entList);
			}
		}	
	}
}