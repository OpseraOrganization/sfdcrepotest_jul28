/*******************************
	Created by: Accenture
	Description: This helper is written for the Trigger of Agreement Object
	Team: Digital Sales
	*******************************/
public  without sharing Class AgreementTriggerHelper {
	private static integer limitRows=Limits.getLimitQueryRows()- Limits.getQueryRows();	
	/******************************************************************************************************
Name : checkMandatoryFields
Description : This method is used to validate if all the mandatory fields on agreement are filled or not
Parameter : List of CurrentRecord ids
*********************************************************************************************************/
	public static void checkMandatoryFields(List<Apttus__APTS_Agreement__c > aggNewList){
		try{
			
			Map<String,String> agreementFieldsOnStatus = new Map<String,String>();
		 
			agreementFieldsOnStatus = getAgreementFieldsOnStatus();
			
		   
			
			//method call to get list of mandatory fields from Custom setting
		   // String aggFields = getAgreementFields(aggStatusRecord);
			
			if(!aggNewList.isEmpty()){
	//Below for loop iterate through the CPO result and checks for the empty values for the Required fields. 
	for (Apttus__APTS_Agreement__c agg: aggNewList) {
		if(!String.isEmpty(agg.ERP__c)) {
			List<String> fieldlist = agreementFieldsOnStatus.get(agg.ERP__c).split(CSWXGlobalConstant.comma);
			String missingFieldsLabels = CSWXGlobalConstant.EMPTY_STRING;
			for(String item : fieldlist) {
			
			
				system.debug('item>>>>>'+item);
				if(agg.get(item)==null){
		missingFieldsLabels = missingFieldsLabels + Schema.getGlobalDescribe().get(CSWXGlobalConstant.OBJECT_Agreement).getDescribe().fields.getMap().get(item).getDescribe().getLabel() + CSWXGlobalConstant.comma;
		
				}
				if(agg.get(item)==false){
		missingFieldsLabels = missingFieldsLabels + Schema.getGlobalDescribe().get(CSWXGlobalConstant.OBJECT_Agreement).getDescribe().fields.getMap().get(item).getDescribe().getLabel() + CSWXGlobalConstant.comma;
				}
			}
		
			system.debug('missingFieldsLabels>>>>'+missingFieldsLabels);
			missingFieldsLabels= missingFieldsLabels.removeEnd(CSWXGlobalConstant.comma);
			if(missingFieldsLabels!=CSWXGlobalConstant.EMPTY_STRING){
				agg.addError(CSWXGlobalConstant.MandatoryFieldsagreement +missingFieldsLabels);
			}
		}
		
	}
	
			}
			//}
			
		}catch (Exception ex) {ExceptionHandler.addException(ex,CSWXGlobalConstant.AgreementTriggerHelper,CSWXGlobalConstant.checkMandatoryFields);} 
		
	}
	
	/* Method to get Agreement fields */
	public static Map<String,String> getAgreementFieldsOnStatus(){
		try{
			
		   
		  
			Map<String,String> agreementFieldsMapOnStatus = new Map<String,String>();
			for(DS_Agreement_Validation__c aggObj : [Select Name, ERP__c, Agreement_MandatoryFields__c, Agreement_MandatoryFields2__c, Agreement_MandatoryFields3__c from DS_Agreement_Validation__c where Name!=Null  LIMIT: (Limits.getLimitQueryRows() - Limits.getQueryRows())] ){
				
				String agg_mandfields=CSWXGlobalConstant.EMPTY_STRING;
	if(aggObj.Agreement_MandatoryFields3__c!=null){
					agg_mandfields =  aggObj.Agreement_MandatoryFields__c + CSWXGlobalConstant.comma + aggObj.Agreement_MandatoryFields2__c + CSWXGlobalConstant.comma + aggObj.Agreement_MandatoryFields3__c;
				}else{
					agg_mandfields =  aggObj.Agreement_MandatoryFields__c + CSWXGlobalConstant.comma + aggObj.Agreement_MandatoryFields2__c;
				}
	
	agreementFieldsMapOnStatus.put(aggObj.ERP__c,agg_mandfields);
				
			}
			system.debug('agreementFieldsMapOnStatus>>>>>>>>>'+agreementFieldsMapOnStatus);
			
			return agreementFieldsMapOnStatus;
		}catch (Exception ex) {ExceptionHandler.addException(ex,CSWXGlobalConstant.AgreementTriggerHelper,CSWXGlobalConstant.getAgreementFields);} 
		return null;
	}
}