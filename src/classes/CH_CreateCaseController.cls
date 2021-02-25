/****************************************
* Class Name : CH_CreateCaseController
* Created Date: 19 Feb 2019
* Created By : Mahati Krishna (mahatikrishna.chitta@tcs.com)
* Last Modified by: Mahati Krishna
* Last Modified Date: 20 Feb 2019
* Description : Case creation button action and visibility 
* Test Class: CH_CreateCaseControllerTest
*****************************************/
public with sharing class CH_CreateCaseController {
	/********************
	* Method Name: checkCreateCaseButtonVisibility
	* Parameter: Id contactId
	* Description: Used to Checks object level access of case and contact status 'Active' for button visibility
	* Reference: NOKIASC-15495
	*******************/
	@AuraEnabled
	public static String checkCreateCaseButtonVisibility(Id contactId) {
		String message = checkObjectAccess('Case', new String[] {'Create'});
		// Return blank if message is null as well
		if(String.isBlank(message)) {
			message = '';
		}
		return message;
	}
	
	/********************
	* Method Name: redirectToCreateCaseFlow
	* Parameter: Id contactId
	* Description: Used to Checks condition for case creation
	* Reference: NOKIASC-15083
	*******************/
	@AuraEnabled
	public static String redirectToCreateCaseFlow(Id contactId, String serviceType ) {
		String message = '';  
		
		Contact contactObj = [SELECT Id, Contact_Status__c, MobilePhone,CH_Legal_Entity_Name__c, Phone FROM Contact WHERE Id=: contactId];
		
		if(contactObj != null) {
			if ((contactObj.MobilePhone != null || contactObj.Phone != null) && contactObj.CH_Legal_Entity_Name__c != null && contactObj.Contact_Status__c == 'Active') {
				message = redirectBasedOnServiceType(serviceType, contactId) ;
			} else {
				String ObjectAccess = checkObjectAccess('Contact', new String[] {'Edit'});
				String RecordAccess = checkRecordLevelAccess(contactId);
				
				Map < String, String > fieldLevelAccessMap =  checkFieldAccess('Contact', new Map < String, String > {'Contact_Status__c' => 'Edit' ,'CH_Legal_Entity_Name__c' => 'Edit', 'MobilePhone' => 'Edit', 'Phone' => 'Edit' });		   
				
				if (contactObj.Contact_Status__c != 'Active') {
					if(String.isBlank(ObjectAccess) && String.isBlank(fieldLevelAccessMap.get('Contact_Status__c')) && String.isBlank(RecordAccess)) {
						message = System.label.CH_NewCaseButton_ContactNotActive +'\n'; 
					} else {
						message = 'Kindly Contact system administrator to ' + System.label.CH_NewCaseButton_ContactNotActive +'\n';
					}			  
				}
				// If legal entity is blank through a message
				if (contactObj.CH_Legal_Entity_Name__c == null) {				
					if(String.isBlank(ObjectAccess) && String.isBlank(fieldLevelAccessMap.get('CH_Legal_Entity_Name__c')) && String.isBlank(RecordAccess)) {
						message += System.label.CH_NewCaseButton_LegalEntityMissing +'\n'; 
					} else {
						message += 'Kindly Contact system administrator to ' + System.label.CH_NewCaseButton_LegalEntityMissing +'\n';
					}
				}
				// If mobile or phone is blank through a message
				if (contactObj.MobilePhone == null && contactObj.Phone == null) {
					if(String.isBlank(ObjectAccess) && String.isBlank(fieldLevelAccessMap.get('MobilePhone')) && String.isBlank(fieldLevelAccessMap.get('Phone')) && String.isBlank(RecordAccess)) {
						message += System.label.CH_NewCaseButton_Missingphone;
					} else {
						if (String.isBlank(message)) {
							message = 'contactDetails';
						} else {
							message += '';
						}						
					}
				}
			} 
		} else{
			message = 'This message does not make sense. No Contact Record found'; 
		}
		return message;
	}
	
	/********************
	* Method Name: checkContactStatus
	* Parameter: Id contactId
	* Description: Used to Checks contact status
	* Reference: NOKIASC-15495/15083
	*******************/	
	/*public static String checkContactStatus(Id contactId) {
		if(String.isNotBlank(contactId)) {
			Contact contactObj = [SELECT Id, Contact_Status__c, MobilePhone, Phone FROM Contact WHERE Id=: contactId];
			if(contactObj != null && contactObj.Contact_Status__c == 'Active') {
				return '';
			} else {
				return 'Error Message';
			}	   
		} 
		return 'Invalid Contact Id';
	}*/
	
	/********************
	* Method Name: checkObjectAccess
	* Parameter: String sObjectName, String[] accessLevel
	* Description: Used to check access of given object with provided access level
	* Reference: NOKIASC-15495/15083
	*******************/
	public static string checkObjectAccess(String sObjectName, String[] accessLevel) {
		SObjectType sObjectTypeName = Schema.getGlobalDescribe().get(sObjectName);
		for(String access: accessLevel) {
			if(access == 'Read' && !sObjectTypeName.getDescribe().isAccessible()) {
				return 'No Read Access';
			} else if(access == 'Create' && !sObjectTypeName.getDescribe().isCreateable()) {
				return 'No Create Access';
			} else if(access == 'Edit' && !sObjectTypeName.getDescribe().isUpdateable()) {
				return 'No Edit Access';
			} else if(access == 'Delete' && !sObjectTypeName.getDescribe().isDeletable()) {
				return 'No Delete Access';
			} else {
				return '';
			}
		}
		return 'Invalid object access level';	
	}
	
	/********************
	* Method Name: checkFieldAccess
	* Parameter: String sObjectName, Map < String, String > fieldMap
	* Description: Used to check access of fields with provided access level
	* Reference: NOKIASC-15495/15083
	*******************/
	public static Map < String, String > checkFieldAccess(String sObjectName, Map < String, String > fieldMap) {
		Map < String, String > fieldAccessmap = new Map < String, String > ();
		SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
		Map < String, Schema.SObjectField > schemaFieldMap = sObjectType.getDescribe().fields.getMap();
		for (String fieldApiName : fieldMap.keySet()) {
			if(schemaFieldMap.get(fieldApiName) != null) {
				if(fieldMap.get(fieldApiName) == 'Read' && !schemaFieldMap.get(fieldApiName).getDescribe().isAccessible()) {
					 //fieldAccessmap.put('No Read Access for field' , fieldApiName);
					 fieldAccessmap.put(fieldApiName, 'No Read Access for field');
				} else if(fieldMap.get(fieldApiName) == 'Edit' && !schemaFieldMap.get(fieldApiName).getDescribe().isUpdateable()) {
					 //fieldAccessmap.put('No Edit Access for field' , fieldApiName);
					fieldAccessmap.put(fieldApiName, 'No Edit Access for field');
				} else {
					//fieldAccessmap.put( '', fieldApiName);
					fieldAccessmap.put(fieldApiName, '');
				}
			}		  
		}	  
		return fieldAccessmap;
	}

	
	/********************
	* Method Name: getPickListValuesBasedOnContactType
	* Parameter: string ObjectName, string fieldName
	* Description: Used to get the picklist values based on input paramters
	* Reference: NOKIASC-15458
	*******************/
	@AuraEnabled
	public static List < String > getPickListValuesBasedOnContactType(Id contactId) {   
		Set < String > picklistValues = new Set < String > ();
		if(String.isNotBlank(contactId)) {
			Contact contactObj = [SELECT Id, Contact_Status__c, CH_ContactType__c FROM Contact WHERE Id=: contactId];
			/*if(contactObj.CH_ContactType__c == 'Customer') { 
				picklistValues = getCustomSettingData('Customer');
			} else if (contactObj.CH_ContactType__c == 'Nokia Employee') {			
				picklistValues = getCustomSettingData('Nokia Employee');
			} else if (contactObj.CH_ContactType__c == 'Partner' ) {
				picklistValues = getCustomSettingData('Partner');
			} else if (contactObj.CH_ContactType__c == 'Supplier') {
				picklistValues = getCustomSettingData('Supplier');
			} else if (contactObj.CH_ContactType__c == 'Sub-Contractor') {
				picklistValues = getCustomSettingData('Sub-Contractor');
			} else if (contactObj.CH_ContactType__c == 'No Relationship') {
				picklistValues = getCustomSettingData('No Relationship');
			} else if (contactObj.CH_ContactType__c == 'Secondary Account') {			
				picklistValues = getCustomSettingData('Secondary Account');
			}*/
			if(contactObj.CH_ContactType__c != 'None') {
				String contactType = contactObj.CH_ContactType__c;
				picklistValues = getCustomSettingData(contactType);
			}
		}
		return (new List < String > (picklistValues));
	}
	
	/********************
	* Method Name: getCustomSettingData
	* Parameter: string ContactType
	* Description: Used to get custom data values
	* Reference: NOKIASC-15458
	*******************/	
	public static Set < String > getCustomSettingData(String ContactType) { 
		Set < String > picklistValues = new Set < String > ();
		if(String.isNotEmpty(ContactType)) {			
			for(CH_ServiceTypeData__c ServiceTypeData : [SELECT CH_ServiceType__c FROM CH_ServiceTypeData__c WHERE CH_ContactType__c = :ContactType]) {
				picklistValues.add(ServiceTypeData.CH_ServiceType__c);
			}
		}
		return picklistValues;		
	}
	
	public static final String LEGAL_ENTITY_REC_TYPE = 'Legal_Entity';
	
	/********************
	* Method Name: updateContactDetails
	* Parameter: Integer mobile, Integer phone, string contactId
	* Description: Used to send email for updating contact details
	* Reference: NOKIASC- 16337
	*******************/ 
	@AuraEnabled
	public static String updateContactDetails(Integer mobile, Integer phone, string contactId){   
		String message = '';
		if ( mobile != null || phone != null ) {
			if ( contactId != null ) {
				
				Contact contactObj = [SELECT Id,Name, AccountId, Account.Name, Account.Country__c FROM Contact WHERE Id =: contactId];  
			   
				string [] toAdd=new string [] {System.label.CH_ContactMissingEmail};
				String addressEmail = System.label.CH_FromAddressForGWCMail;
				OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: addressEmail LIMIT 1];
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				if ( owea.size() > 0 ) {
					email.setOrgWideEmailAddressId(owea.get(0).Id);
				}
				
				email.setToAddresses(toAdd);
				email.setSubject('Update contact details');
				String body = '<p>Dear GWC Agent</p>'+'<p>The contact details for the below contact has to be updated for the case creation. Contact details as following:</p>'+'<p>Contact Name: '+contactObj.Name+'</p>';
				if(contactObj.Account.Name != null) {
					body += '<p>Contact Account: '+contactObj.Account.Name+' </p>';
				} else {
					body += '<p>Contact Account:  </p>';
				}
				body += '<p>The below details have to be updated in contact</p>';
				if(contactObj.Account.Country__c != null) {
					body += '<p>Country: '+contactObj.Account.Country__c+' </p>';
				} else {
					body += '<p>Country:  </p>';
				}
				if(mobile != null) {
					body += '<p>Mobile :'+mobile+'</p>';
				}
				if(phone != null) {
					body += '<p>Phone : '+phone+'</p>';
				}
				body += '<p>The contact link : <a href="' +URL.getSalesforceBaseUrl().toExternalForm() +'/' + contactObj.Id+'">Contact</a> </p>';
				body += '<p>Thanks & Regards</p>';				
				email.setHtmlBody(body);
				
				messaging.Email[] emails = new messaging.Email[]{email};
					messaging.sendEmail(emails);
				message = 'sendMail';
			}else{
				message = 'Invalid Contact Id';
			}   
			
		} else {
			message = 'Invalid Phone/Mobile No';
		}		
		return message;
	}
	
	/********************
	* Method Name: redirectBasedOnServiceType
	* Parameter: String serviceType, Id contactId
	* Description: Used to separate the case creation based on service type
	* Reference: NOKIASC-16406
	*******************/ 
	
	public static String redirectBasedOnServiceType(String serviceType, Id contactId){ 
		system.debug('Service Type' + serviceType );
		String message = '';
		if (contactId != null){
			Contact contactObj = [SELECT CH_ContactType__c FROM Contact WHERE Id =: contactId];
			if (serviceType != null && contactObj != null ) {
				if ( serviceType == 'Customer Support' || serviceType == 'Internal Support' ) {
					system.debug('Service Type' + serviceType );
					message = '';
					return message;
				// HWS - Start	
				// Modified as partof HWS HWST-3196 & 3198 user stories Sprint 1917	
	} else if ( serviceType == 'Hardware Services' ) {	
					message = '';	
	// HWS - End
				} else {
					message = 'Case cannot be created for this service type';
				}
			} else{
				message = 'Not valid service type';
			} 
		}		
		return message;
	}
	
	/********************
	* Method Name: checkRecordLevelAccess
	* Parameter: Id objectID
	* Description: TO check the record level access
	* Reference: NOKIASC-16337
	*******************/ 
	
	public static String checkRecordLevelAccess(Id objectID){ 
		String message = '';
		if (objectID != null){
		UserRecordAccess recordAccess =  [SELECT RecordId  ,HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId =: objectID Limit 1];
			if(recordAccess != null && recordAccess.HasEditAccess){
			   message = ''; 
			} else {
				message = 'Does not have edit access over record for this user';
			}	 
		}  
		return message;
	}	
}