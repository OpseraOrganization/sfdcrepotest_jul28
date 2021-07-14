/*******************************
	Created by: Accenture
	Description: This Handler is written for the Trigger of CPO Object
	*******************************/
public  without sharing class CPOTriggerHandler {
	
	/******************************************************************************************************
Name : checkMandatoryFields
Description : This method is used to validate if all the mandatory fields on CPO are filled or not
Parameter : List of CurrentRecord ids
*********************************************************************************************************/
	public static void checkMandatoryFields(List<Apttus_Config2__CustomerPurchaseOrder__c > cpoNewList, Map<Id, Apttus_Config2__CustomerPurchaseOrder__c > cpoOldMap){
		for(Apttus_Config2__CustomerPurchaseOrder__c cpo: cpoNewList){
			if(cpo.Apttus_Config2__Status__c!= (cpoOldMap.get(cpo.id)).Apttus_Config2__Status__c){
				CPOTriggerHelper.checkMandatoryFields(cpoNewList);	
			}	   
		}   
		
	}
  
	
	/******************************************************************************************************
Name : updateCPOOwner
Description : This method is used to update Owner on Legacy CPO
Parameter : List of CurrentRecord ids
*********************************************************************************************************/
	public static void shareCSMandCDMwithCustomer(List<Apttus_Config2__CustomerPurchaseOrder__c > cpoList){
	  CPOTriggerHelper.shareCSMandCDMwithCustomer(cpoList);
	}
	
   /******************************************************************************************************
Name : createEntitlement
Description : This method is used to Create Commercial Entitlement Records. 
*********************************************************************************************************/	
	public static void createEntitlement(List<Apttus_Config2__CustomerPurchaseOrder__c> cpoList_new,Map<Id, Apttus_Config2__CustomerPurchaseOrder__c> cpoList_oldMap ){
	  try{ 
		List<Apttus_Config2__CustomerPurchaseOrder__c> CPORecList = new List<Apttus_Config2__CustomerPurchaseOrder__c>();
			for(Apttus_Config2__CustomerPurchaseOrder__c cpo: cpoList_new){
			
				if((cpo.Apttus_Config2__Status__c!= cpoList_oldMap.get(cpo.Id).Apttus_Config2__Status__c && cpo.Apttus_Config2__Status__c == CSWXGlobalConstant.ReadyforExecution ) || (cpo.Apttus_Config2__Status__c!= cpoList_oldMap.get(cpo.Id).Apttus_Config2__Status__c && cpo.Apttus_Config2__Status__c == CSWXGlobalConstant.ReadyforDelivery  && cpo.Legacy_CPO__c ==true )){
				
				  CPORecList.add(cpo);
			   }
				if(!CPORecList.isEmpty()){
				 CPOTriggerHelper.createEntitlement(CPORecList);   
				}
				   
		   
			}
		}catch(Exception ex) {ExceptionHandler.addException(ex,CSWXGlobalConstant.CPOTriggerHandler ,CSWXGlobalConstant.createEntitlement );}   
	}  
	
}