/******************************************************************************************************
Name : CustomerDocumentTriggerHandler
Created Date: 7 July 2019
Created by: Accenture
Description : This class is a handler class for customerDocumentTrigger
*********************************************************************************************************/
public class CustomerDocumentTriggerHandler {
	
	/***********************************************
	Name : checkValidationOnCreate
	Descritpion: This method is used to get Mandatory fields on customer document
	based on Status from Custom Setting 'Customer_Document'. 
	Parameter : List<Customer_Document__c> Customer_Document_Vaidation__c
	*************************************************/
	public static void checkValidationOnCreate(List<Customer_Document__c> custDocList){
		  CustomerDocumentTriggerHelper.checkValidation(custDocList,null);	  
	}
	
		/***********************************************
	Name : checkValidationOnCreate
	Descritpion: This method is used to get Mandatory fields on customer document
	based on Status from Custom Setting 'Customer_Document'. 
	Parameter : List<Customer_Document__c> Customer_Document_Vaidation__c
	*************************************************/
	public static void checkValidationOnUpdate(List<Customer_Document__c> custDocList,Map<Id,Customer_Document__c> custDocListOldMap){
		try{
			if(!custDocList.isEmpty()){
				CustomerDocumentTriggerHelper.checkValidation(custDocList,custDocListOldMap.keyset());
			}
		}catch(Exception ex){
			ExceptionHandler.addException(ex,CSWXGlobalConstant.CustomerDocumentTriggerHelper ,CSWXGlobalConstant.CheckValidation);
		}
	}
}