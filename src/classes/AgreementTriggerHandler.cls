/*******************************
	Created by: Accenture
	Description: This Handler is written for the Trigger of Agreement Object
	*******************************/
public without sharing  class AgreementTriggerHandler {
	
	/******************************************************************************************************
Name : checkMandatoryFields
Description : This method is used to validate if all the mandatory fields on Agreement are filled or not
Parameter : List of CurrentRecord ids
*********************************************************************************************************/
 public static void checkMandatoryFields(List<Apttus__APTS_Agreement__c> aggNewList, Map<Id, Apttus__APTS_Agreement__c > aggOldMap){
	 try{
			for(Apttus__APTS_Agreement__c agg: aggNewList){
				if((agg.Confidence_Level__c!= (aggOldMap.get(agg.id)).Confidence_Level__c) && (agg.Confidence_Level__c.equals('High Level') && (aggOldMap.get(agg.id)).Confidence_Level__c.equals('Low Level'))){
					AgreementTriggerHelper.checkMandatoryFields(aggNewList);	
				}	   
			}
		} catch(Exception ex) {
			ExceptionHandler.addException(ex,CSWXGlobalConstant.AgreementTriggerHandler ,CSWXGlobalConstant.checkMandatoryFields);
		   } 
		 
	} 
}