/****************************************
 * Class Name : CheckAndChangeDefaultLegalEntity 
 * Created Date: 04 June 2019
 * Created By : Nokia
 * Last Modified by: 
 * Last Modified Date: 
 * Description : 1. Called because new Active legalEntity inserted
				 2. Since Default Legal Entity is inactive need to change the default legal entity				
 * Test Class: 
 *****************************************/
public class CheckChangeDefaultLegalEntity {
	private List<Account> newLegalEntityList = new List<Account>();
	private map<string,account> parentWithChildLE = new Map<string,account>();
	
	public void CheckAndChangeDefaultLegalEntity(List<Account> newLELiSt){
		  newLegalEntityList = [select Id,parentId,AccountNumber,active__c,default_legal_entity__c from account where Id IN: newLEList];
	 
	

		List<Account> updateLEList = new List<Account>();
		string defaultLEfromSetting ;
		
		for(Account LE : newLegalEntityList ){
			if(LE.active__c && !LE.default_legal_entity__c){
				parentWithChildLE.put(LE.parentId,LE); 
			}	
		}
		
		List<Account> InvalidDefaultLElist = [select Id,parentId,Parent_Account_Number__c,accountnumber from account where default_legal_entity__c= true and active__c=false and parentId IN : parentWithChildLE.keySet()];
		
		for(Account invalidDefault : InvalidDefaultLElist ){
			if(invalidDefault.Parent_Account_Number__c!=NULL && Default_Legal_Entity__c.getValues(invalidDefault.Parent_Account_Number__c)!=NULL){
				 defaultLEfromSetting = Default_Legal_Entity__c.getValues(invalidDefault.Parent_Account_Number__c).default__c;
			}
			System.debug('defaultLEfromSetting.....' + defaultLEfromSetting );
			if(defaultLEfromSetting == NULL || defaultLEfromSetting != invalidDefault.accountNumber){
				Account defaultLE = parentWithChildLE.get(invalidDefault.parentId); 
				defaultLE.default_legal_entity__c= true;
				updateLEList.add(defaultLE);
			}
		}
		if(updateLEList.size()>0){
			update updateLEList;
		}
	}
}