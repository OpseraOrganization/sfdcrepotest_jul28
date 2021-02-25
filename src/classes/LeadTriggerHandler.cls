/****************************************
 * Class Name : LeadTriggerHandler
 * Created Date: 7 December 2016
 * Created By : Accenture
 * Last Modified by: Accenture
 * Last Modified Date: 7 December 2016
 * Description : Handle the sequence of the LeadTriggerHelper
 * Test Class: 
 *****************************************/
public without sharing class LeadTriggerHandler{
	/********************
	*Method Name: afterOperation
	*Parameter: Lead List
	*Description: Used to handle after update activities
	**************1. Validations for Lead Conversion
	**************2. Add default values in opportunity at the time of conversion
	*******************/
	public static void afterUpdateOperation(List<Lead> leadList){
		
		try{
		
		List<Lead> directSalesLeadList = new List<Lead>();
	   
		for(Lead ld : leadList){
			if(ld.recordtypeId == system.label.DirectLeadRecordType)
			   directSalesLeadList.add(ld); 
		} 
		   //Check Lead Conversion Validations
		if(!directSalesLeadList.isEmpty()){
			LeadTriggerHelper.leadConversionValidations(directSalesLeadList);
			LeadTriggerHelper.addOppDefaultValues(directSalesLeadList);
			LeadTriggerHelper.OverrideContactFields(directSalesLeadList);
		}
		}
		catch(System.Exception e){
			
		}
		
		
	   
   }//end of afterOperation  
   
   /*Method Name: beforeUpdateOperation
	*Parameter: Lead List
	*Description: Used to handle before update activities
	**************1. Vpoulate market and country code based on country value
   */
	public static void beforeOperation(List<Lead> leadList,Map<id, Lead> OldLeadMap){  
	//Check Lead Conversion Validations
		try{system.debug('leadList>>>>>>>>>>>'+leadList);
			system.debug('OldLeadMap>>>>>>>>>>>'+OldLeadMap);
			LeadTriggerHelper.leadCampaignAutoPopulation(leadList,OldLeadMap);
			
			 List<Lead> leadListoUpdate = new List<Lead> ();
			 List<Lead> leadListoUpdatelookup = new List<Lead> ();

			for(lead ld : leadList){
			
				system.debug('countrycode....'+ld.countrycode);
				system.debug('country....'+ld.country);
				system.debug('stateCode....'+ld.stateCode);
				
				if(ld.country != null || ld.countrycode!=NULL){
					
					if(ld.Market__c == null){
						ld.Market__c = ISO_Country_Codes__c.getvalues(ld.CountryCode).Market__c;
					}
					else if(ld.Market__c  != ISO_Country_Codes__c.getvalues(ld.CountryCode).Market__c){
						ld.addError(System.Label.Incorrect_Market_Value + ' ' +ISO_Country_Codes__c.getvalues(ld.CountryCode).Country_Name__c+ ' ' + System.Label.Is + ' ' + ISO_Country_Codes__c.getvalues(ld.CountryCode).Market__c);
					}
					ld.country__c= ISO_Country_Codes__c.getvalues(ld.countrycode).country_name__c;
					ld.Country_Code__c = ld.countrycode;
					ld.State__c = ld.State;
				}
			}
			
		   
			 
		}
		catch(Exception exc){
				 ExceptionHandler.addException(exc, GlobalConstants.LEAD_TRIGGER_HANDLER , GlobalConstants.LEAD_TRIGGER_HANDLER_BEFORE_OP );
		 }
	
	
	}//end of beforeUpdateOperation  
	
	/********************
	*Method Name: afterInsertOperation
	*Parameter: Lead List
	*Description: Used to handle after update activities
	**************1. 
	**************2. 
	*******************/
	public static void afterInsertOperation(List<Lead> leadList,Map<id, Lead> OldLeadMap){
		try{
		system.debug('new list......');
		system.debug('oldMap.....');
		system.debug('leadListoUpdatelookup .....'+LeadTriggerHelper.leadListoUpdatelookup );
		system.debug('campaignIdList.........'+LeadTriggerHelper.campaignIdList);
		if(LeadTriggerHelper.leadListoUpdatelookup.size()>0){
			LeadTriggerHelper.leadLookupCampaignAutoPopulation(LeadTriggerHelper.leadListoUpdatelookup,LeadTriggerHelper.campaignIdList);
		}
		}
		catch(System.Exception e){
			
		}
	}//end of afterInsertOperation
}//end of class LeadTriggerHandler