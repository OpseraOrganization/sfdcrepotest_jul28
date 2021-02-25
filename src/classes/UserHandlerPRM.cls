/**
* @description: A handler class for User Trigger.
* @author:	Accenture IDC.
*
* ============================================================================
* History:
* -------
* 
* VERSION AUTHOR		  DATE		DETAIL										  FEATURES/CSR/TTP
* 1.0				   26/12/2016   Sprint 3 Doc Stretegy & LoA requirements.
* ============================================================================ 
*/
public with sharing class UserHandlerPRM {
	
	/**********************************************************************************************************************
* author: Accenture
* Date: March-2016
* Param: List<User> userListNew
* Return: void
* Description: Handler method for before Insert operation.
* High Level Process : 
**********************************************************************************************************************/	 
	public static void onBeforeInsert(List<User> newUserList)
	{
		try{
			if(!GlobalConstants.STOP_TRIGGER_USER_ON_BEFOREINSERT){
				UserHelperPRM.updateShowEmailToExternalUsers(newUserList); 
			}
		}catch(System.Exception e){ExceptionHandler.addException(e,PRMGlobalConstants.UserHandler,PRMGlobalConstants.afterInsertOperation);}
		
	}
	/**********************************************************************************************************************
* author: Accenture
* Date: Dec-2016
* Param: Map<Id, User> newUserMap, Map<Id, User> oldUserMap
* Return: void
* Description: Handler method for after update operation.
* High Level Process : 
**********************************************************************************************************************/	 
	public static void onAfterUpdate(Map<Id, User> newUserMap, Map<Id, User> oldUserMap)
	{
		try{
			/*if(!GlobalConstants.STOP_TRIGGER_USER_ON_AFTERUPDATE){
GlobalConstants.STOP_TRIGGER_USER_ON_AFTERUPDATE = true;
// To delete share fund with inserted users
Set<id> userIdset = new Set<id>(); 
for(User userinstance : newUserMap.values() ){
if(oldUserMap.get(userinstance.Id).IsPortalEnabled != newUserMap.get(userinstance.Id).IsPortalEnabled && newUserMap.get(userinstance.Id).IsPortalEnabled == FALSE ){
userIdset.add(userinstance.id);
}
}
UserHelperPRM.unshareFundOnUserDeactivation(userIdset);


}*/
			Set<Id> contactIds = new Set<Id>();
			for (User u : newUserMap.values())
			{System.debug('profile'+u.ProfileId);
			 System.debug('user status'+u.NCP_Approval_Status__c);
			 System.debug('user status'+oldUserMap.get(u.id).NCP_Approval_Status__c);
				if (u.ContactId != null && (u.ProfileId == system.Label.PRM_Partner_Profile_Id || 
											u.ProfileId == system.Label.PRM_Partner_Relationship_Manager_Login_ID ||
											u.ProfileId == System.Label.PRM_Unauthorized_Partner_Profile)){
												if(u.NCP_Approval_Status__c==PRMGlobalConstants.Approved 
												   && oldUserMap.get(u.id).NCP_Approval_Status__c == PRMGlobalConstants.Pending){
													contactIds.add(u.ContactId);
														System.debug('inside for loop'+ contactIds);
												}
											}
			}
			if(contactIds.size() > 0){
				System.debug('inside for loop'+ contactIds);
				ContactUpdateWithNewTool.updateContacts(contactIds);
			}
					   
		}catch(System.Exception e){ExceptionHandler.addException(e,PRMGlobalConstants.UserHandler,PRMGlobalConstants.afterInsertOperation);}
		
	}
	/**********************************************************************************************************************
* author: Accenture
* Date: April-2018
* Param: List<User> userListNew
* Return: void
* Description: Handler method for after Insert operation.code bloack for contact field update when partner user created 
* High Level Process : 
**********************************************************************************************************************/ 
	public static void onAfterInsert(List<User> newUserList){
		try{
			List<User> userListCoop = new List<User>();
			for(User us : newUserList){
				if ((us.ProfileId == system.Label.PRM_Partner_Profile_Id || 
					 us.ProfileId == system.Label.PRM_Partner_Relationship_Manager_Login_ID  || 
us.ProfileId == System.Label.Customers_Login_Profile_ID|| 
us.ProfileId == System.Label.Customers_Profile_ID )){
	userListCoop.add(us);
}
			}
			if(!userListCoop.IsEmpty() ) {
				Database.executeBatch(new CoOpFundBatch(userListCoop));
			}
			Set<Id> contactIds = new Set<Id>();
			Set<Id> contactPRMIds = new Set<Id>();
			
			for (User u : newUserList)
			{
				if (u.ContactId != null && (u.ProfileId == system.Label.PRM_Partner_Profile_Id || 
											u.ProfileId == system.Label.PRM_Partner_Relationship_Manager_Login_ID)){
												contactIds.add(u.ContactId);
											}
				
				System.debug('user-->'+u);
				System.debug('contactIds-->'+contactIds);
			}		
			if (contactIds.size() > 0) {
				ContactUpdateWithNewTool.updateContacts(contactIds);
			}
			
		}
		
		catch(System.Exception e){ExceptionHandler.addException(e,PRMGlobalConstants.UserHandler,PRMGlobalConstants.afterInsertOperation);}
	}
}