public class CH_CA_WorkGroup_Rule_Controller {
	// This method is used to get the Picklist records from the CDBServiceContractType.
	@AuraEnabled
	public static List<String> getCdbRecords() {  
		List<String> pickListValues= new List<String>();
		pickListValues.add('--None--');
		Schema.DescribeFieldResult fieldResult = CH_CDB_ServiceContractType__c.CH_CDB_ContractType__c.getDescribe();
		List<Schema.PicklistEntry> listOfValues = fieldResult.getPicklistValues();
		if(listOfValues.size()>0){
			for( Schema.PicklistEntry pickListVal : listOfValues){
				pickListValues.add(pickListVal.getLabel());
			} 
		}
		pickListValues.sort();
		return pickListValues;
	}
	
}