/*************************************************************
@Name: ProductConfigTriggerHandler
@Author: Accenture
@Description: This class contains Logic for Product Configuration Triggers 
******************************************************************/ 
public with sharing class ProductConfigTriggerHandler {
	/************************
@MethodName: afterUpdate
*************************/ 
	public static void afterUpdate(List<Apttus_Config2__ProductConfiguration__c> newConfigList, List<Apttus_Config2__ProductConfiguration__c> oldConfigList){
		try{
			Set<String> associatedQuoteSet = new Set<String>();
			Set<Id> configIdSet = new Set<Id>();
			Integer i=0;
			List<Apttus_Proposal__Proposal__c> quotesToBeUpdatedList = new List<Apttus_Proposal__Proposal__c>();
			//system.debug('new config**' + newConfigList[i].Apttus_Config2__BusinessObjectType__c + oldConfigList[i].Apttus_Config2__Status__c + newConfigList[i].Apttus_Config2__Status__c);
			for(i=0; i< newConfigList.size(); i++){
				if(newConfigList[i].Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_DIRECTCPQ) && newConfigList[i].Apttus_Config2__BusinessObjectType__c.equalsIgnoreCase(Nokia_CPQ_Constants.NOKIA_PROPOSAL) && (newConfigList[i].Apttus_Config2__Status__c.equalsIgnoreCase(Nokia_CPQ_Constants.Saved) || newConfigList[i].Apttus_Config2__Status__c.equalsIgnoreCase(Nokia_CPQ_Constants.ApprovalRequired) || newConfigList[i].Apttus_Config2__Status__c.equalsIgnoreCase(Nokia_CPQ_Constants.PendingApproval))){
					associatedQuoteSet.add(newConfigList[i].Apttus_QPConfig__Proposald__c);
				}
				if(newConfigList[i].NokiaCPQ_Quote_Opportunity_Changed__c && newConfigList[i].Quote_Type__c.contains('CPQ'))
				{
					configIdSet.add(newConfigList[i].Id);
				}
			}
			
			if(!associatedQuoteSet.isEmpty()){
				for(Apttus_Proposal__Proposal__c quote : [Select id, Quote_Status__c from Apttus_Proposal__Proposal__c where Id IN:associatedQuoteSet]){
					//system.debug('quote.Quote_Status__c** '+quote.Quote_Status__c+'cloned???'+quote.isClone());
					if(String.isNotBlank(quote.Quote_Status__c) && quote.Quote_Status__c.equalsIgnoreCase(Nokia_CPQ_Constants.Configure)){
						quote.Quote_Status__c = Nokia_CPQ_Constants.NokiaCPQ_PRICE;
						quotesToBeUpdatedList.add(quote);
					}
				}
				if(!quotesToBeUpdatedList.isEmpty()){
					Database.update(quotesToBeUpdatedList,false);
				}
			}
			if(!configIdSet.isEmpty())
			{
				ProductConfigTriggerHelper.clearSiteOnConfiguration(configIdSet);
			}
		}
		
		Catch(Exception e){
			ExceptionHandler.addException(e,ProductConfigTriggerHandler.class.getName(),Nokia_CPQ_Constants.ERROR_MSD);
		}   
	}
/************************************
 * Method :  afterUpdate_QTC
 * Paramater: newList,oldList
 * Comments: Used to Update Approval status of Quote to Draft after Cart is Approved
 * Created By: UKS 09-09-2019   
 * ************************************/
  public static void afterUpdate_QTC(List<Apttus_Config2__ProductConfiguration__c> newConfigList, List<Apttus_Config2__ProductConfiguration__c> oldConfigList){
	List<Apttus_Proposal__Proposal__c> quotesUpdateList = new List<Apttus_Proposal__Proposal__c>();
	Set<String> QuoteIdSet = new Set<String>();
	try{System.debug('Inside afterUpdate_QTC>>>>>>>>>>>>>>>>');
	  for(Apttus_Config2__ProductConfiguration__c config : newConfigList){
		if(config.Quote_Type__c=='Direct CPQ'&&config.NokiaCPQ_Portfolio_From_Quote__c=='QTC'&&config.Apttus_CQApprov__Approval_Status__c=='Approved')
		  QuoteIdSet.add(config.Apttus_QPConfig__Proposald__c);
	  }
	  if(!QuoteIdSet.isEmpty())
		for(Apttus_Proposal__Proposal__c quote : [Select id, Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where Id IN:QuoteIdSet]){
		  quote.Apttus_Proposal__Approval_Stage__c='Draft';
		  quotesUpdateList.add(quote);
		}
	  if(!quotesUpdateList.IsEmpty())
		Database.update(quotesUpdateList, false);
	}
	catch(Exception ex){
	  System.debug('afterUpdate_QTC Exception::> '+ex.getCause()+ex.getMessage());
	}
  }
  
	/************************************
* Method :  BeforeInsert
* Paramater: List<Apttus_Config2__ProductConfiguration__c>
* Comments: Used for before creation of Product Configuration
* Created By: Piyush Tawari 26-09-2019  
* Nokia CPQ REQ:6624  
* ************************************/
	public static void beforeInsert(List<Apttus_Config2__ProductConfiguration__c> prodConfigList)
	{
		try{
			ProductConfigTriggerHelper.updateFieldsOnProdConfig(prodConfigList);
		} 
		catch(Exception ex){
			ExceptionHandler.addException(ex,ProductConfigTriggerHandler.class.getName(),Nokia_CPQ_Constants.ERROR_MSD);
		}
	}
	
	
}