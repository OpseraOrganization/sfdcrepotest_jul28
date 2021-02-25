/****************************************
 * Class Name : ContractHelper
 * Created Date: June 2018
 * Created By : Accenture
 * Last Modified by: Accenture
 * Last Modified Date: 
 * Description : Contract Helper
			  
 * Test Class: 
 *****************************************/
public without sharing class ContractHelper {

	/********************
	*Method Name: UpdatedAccountfforACcreditation level update
	*Parameter: 
	*Description: 
	*******************/
	public static void updateAccNAccreditation(list<Contract> newcontract){
		try{
			system.debug('newcontract  .....'+ newcontract);
			list<Account> accToUpdate = new list<Account>();
			list<string> accredContractType = new list<String>();
			map<id, String> accContract = new map<id, String>();
			map<id, list<String>> accActiveContract = new map<id, list<String>>();
			map<id, list<String>> accExpiredContract = new map<id, list<String>>();
			list<Accreditation__c> accredToUpdate = new list<Accreditation__c>();
			set<ID> accId = new set<ID>();
		   // set<ID> activeContract = new set<ID>();
		   // set<ID> ExpiredContract = new set<ID>();
			set<ID> activeContractAcc = new set<ID>();
			set<ID> expiredContractAcc = new set<ID>();
			
			for(Contract Contr : newcontract){
				system.debug('In contract loop : '+ Contr.name );
				accId.add(Contr.AccountID);
				accContract.put(Contr.AccountID, Contr.Contract_Type__c);
				if(Contr.Contract_Status__c == PRMGlobalConstants.EXPIRED){
				   
					list<String> expireCont = new list<String>();
					if(accExpiredContract.containsKey(Contr.AccountID)){
					expireCont = accExpiredContract.get(Contr.AccountID);
					}
					expireCont.add(Contr.Contract_Type__c);
					accExpiredContract.put(Contr.AccountID,expireCont);
					expiredContractAcc.add(Contr.accountid);
				}
				else if(Contr.Contract_Status__c == PRMGlobalConstants.ActiveSt){
				 
					list<String> activeCont = new list<String>();
					if(accActiveContract.containsKey(Contr.AccountID)){
					activeCont = accActiveContract.get(Contr.AccountID);
					}
					activeCont.add(Contr.Contract_Type__c);
					accActiveContract.put(Contr.AccountID,activeCont);
					activeContractAcc.add(Contr.accountid);
				}
				else{
					//
				}
				
			}
			
			system.debug('expiredContractAcc  .....'+ expiredContractAcc);
			system.debug('accExpiredContract  .....'+ accExpiredContract);
			
			for(Accreditation__c accred : [select id, name, Evaluated_Accreditation__c, Partner__c, Active_Contract_Types__c 
			from Accreditation__c where Partner__c in: accId Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
			   system.debug(' in loop accred  .....'+ accred.name);
			  
				 if(accActiveContract.containsKey(accred.Partner__c)){
					String strAccredContractType = String.valueof(accred.get(PRMGlobalConstants.ContractActive));
					if(strAccredContractType != Null){
					   accredContractType = strAccredContractType.split(PRMGlobalConstants.SemiColon);
					   
					   accredContractType.addall(accActiveContract.get(accred.Partner__c));
					   string newContactType = string.join(accredContractType,PRMGlobalConstants.SemiColon);
					   accred.Active_Contract_Types__c = newContactType;
						}
					else{
					   if(accActiveContract.get(accred.Partner__c).size() > 1){
						   string newContactType = string.join(accActiveContract.get(accred.Partner__c),PRMGlobalConstants.SemiColon);
						   accred.Active_Contract_Types__c = newContactType;
					   }
					   else{
					   accred.Active_Contract_Types__c = accContract.get(accred.Partner__c);
					   }
				   }
				 
			   }
			  
			   if(accExpiredContract.containsKey(accred.Partner__c)){
					   system.debug(' Active contract type  .....'+ String.valueof(accred.get(PRMGlobalConstants.ContractActive)));
					   String strAccredContractType = String.valueof(accred.get(PRMGlobalConstants.ContractActive));
					   if(strAccredContractType != null){
						   accredContractType = strAccredContractType.split(PRMGlobalConstants.SemiColon);
						   list<string> expContactType = accExpiredContract.get(accred.Partner__c); 
						   
							if(!accredContractType.isempty() && accredContractType.size()>1){
								for(string expConttype : expContactType){
									 integer i=0;
									for(String ContType : accredContractType){
										
										if(ContType == expConttype){
											break;
										}
										i=i++;
									}
								accredContractType.remove(i);
								}
						  
							system.debug('accredContractType  .....'+ accredContractType);
							string newContactType = string.join(accredContractType,PRMGlobalConstants.SemiColon);
							accred.Active_Contract_Types__c = newContactType;
							
								}
						
					   /*
						if(!accredContractType.isempty() && accredContractType.size()>1){
							for(String ContType : accredContractType){
								
								if(ContType == accContract.get(accred.Partner__c)){
									break;
								}
								i=i++;
							}
							accredContractType.remove(i);
							string newContactType = string.join(accredContractType,';');
							accred.Active_Contract_Types__c = newContactType;
						
						
						}  */
						
						
							else {
								accred.Active_Contract_Types__c = null;
							} 
					   }
					
					}
					system.debug('Active_Contract_Types__c ...... '+ accred.Active_Contract_Types__c);
					accred.Evaluated_Accreditation__c = true;
					accredToUpdate.add(accred);
			   }   
			system.debug('accredToUpdate ...... '+ accredToUpdate);
			Database.update(accredToUpdate, false);
			
		
		}catch(Exception e){
			ExceptionHandler.addException(e,PRMGlobalConstants.ContractHelper ,PRMGlobalConstants.ContractHelper);
		}
	}
}