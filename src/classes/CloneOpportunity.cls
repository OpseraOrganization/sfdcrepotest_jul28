/*******************************
Class Name: CloneOpportunity
Created by: Accenture
Created Date: 20th June 2017
Last modified by: Accenture
Last modified date:  
Description: Requirement 1507: Sales Process: Opportunity Cloning 
*******************************/
public with sharing class CloneOpportunity {
	private static final Id directRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.DIRECT_OPPTY).getRecordTypeId();
	private static final Id inDirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.INDIRECT_OPPTY).getRecordTypeId();
	private static final Id directReadOnlyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.READONLYDIRECT).getRecordTypeId();
	private static final Id inDirectReadOnlyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.READONLYINDIRECT).getRecordTypeId();
	
	@AuraEnabled
	/*******************************
Method Name: getCloneOpp
Description: Requirement 1507: Sales Process: Opportunity Cloning 
Parameters: Opportunity record id
*******************************/
	public static String getCloneOpp(String recordId) {
		system.debug('recordId>>>>>>>>> ' + recordId);
		// Initialize setup variables
		String returnMessage;
		Schema.DescribeSObjectResult sc = Opportunity.sObjectType.getDescribe();
		Boolean isCreateable = sc.isCreateable();
		opportunity opty = new Opportunity();	 
		system.debug('isCreateable' + isCreateable);
		Id profileId = UserInfo.getProfileId();
		Set<Id> profileIdSet = new Set<Id>();
		String objectName = GlobalConstants.OBJECT_OPPORTUNITY;
		String query = GlobalConstants.SELECT_QUERY;
		
		try {
			List<Id> profiles = System.Label.Clone_Restricted_Profiles.Split(GlobalConstants.COMMA);			
			profileIdSet.addAll(profiles);
			
			if (isCreateable && (!profileIdSet.contains(profileId))) {
				
				opty = [select RecordTypeId from opportunity where id=:recordId Limit 1];
				if(opty.RecordTypeId.equals(directRecordTypeId) || opty.RecordTypeId.equals(directReadOnlyRecordTypeId)) {
					for(cloneObject__c opptyField : [SELECT Field_API__c 
													 FROM cloneObject__c 
													 where Object__c =: GlobalConstants.OBJECT_OPPORTUNITY and Record_Type__c =: GlobalConstants.Direct
													 LIMIT: (Limits.getLimitQueryRows() - Limits.getQueryRows())])
					{
						query += GlobalConstants.SPACE + opptyField.Field_API__c + GlobalConstants.COMMA;
					}
				}else if(opty.RecordTypeId.equals(inDirectRecordTypeId) || opty.RecordTypeId.equals(inDirectReadOnlyRecordTypeId)){
						for(cloneObject__c opptyField : [SELECT Field_API__c 
														 FROM cloneObject__c 
														 where Object__c =: GlobalConstants.OBJECT_OPPORTUNITY and Record_Type__c =: GlobalConstants.Indirect
														 LIMIT: (Limits.getLimitQueryRows() - Limits.getQueryRows())])
						{
							query += GlobalConstants.SPACE + opptyField.Field_API__c + GlobalConstants.COMMA;
						}
					}
				
				system.debug('query.subString(query.Length())?>>>>' + query.Length());				
				system.debug('query.subString(query.Length()-1,query.Length())?>>>>' + query.subString(query.Length() - 1, query.Length()));
				
				// Strip off the last comma if it exists.[from last query statement]
				if (query.subString(query.Length() - 1, query.Length()) == GlobalConstants.COMMA) {
					system.debug('in if... query?>>>>' + query);
					query = query.subString(0, query.Length() - 1);
					system.debug('in if after substring... query?>>>>' + query);
				}
				// Add complete query
				query += GlobalConstants.SOQLFROM + objectName;
				query += GlobalConstants.SOQLWHERE + recordId + GlobalConstants.SOQLLIMIT;
				system.debug(query);
				
				Opportunity opp = database.query(query);
				
				// 2017-12-04 Added By Jingwei for SF Support Ticket '00008286'***start***
				List<RecordType> List_RecordType_Id = [SELECT ID, NAME FROM RecordType WHERE ID=:opp.recordtypeid LIMIT 1];
				String Record_Name;
				if (List_RecordType_Id.size() > 0) {
					Record_Name = List_RecordType_Id.get(0).Name;
				} else {
					returnMessage = system.label.ReadOnlyCloneDenied;
				}
				system.debug('===Record Type Name is' + Record_Name);
				if (!Record_Name.contains(GlobalConstants.Check_Read_Only)) {
					// 2017-12-04 Added By Jingwei for SF Support Ticket '00008286'***end***
					
					system.debug(opp);
					Opportunity newOpp = opp.clone(false, true, false, false);
					newOpp.Name = opp.Name + GlobalConstants.CLONEOPTYNAME;
					newOpp.Amount = 0;
					newOpp.G3_Planned_Date__c = system.today();
					newOpp.G4_Planned_Date__c = system.today();
					newOpp.G5_Planned_Date__c = system.today();
					newOpp.G6_Planned_Date__c = system.today();
					if (opp.Lead_BG__c == GlobalConstants.LEAD_BG_MN && opp.Lead_BU__c != NULL) {
						newOpp.Lead_BU__c = NULL;
						newOpp.IfOpportunityIsCloned__c = True;
					}					
					//database.insert(newOpp,false);
					
						Database.SaveResult savedResults = Database.insert(newOpp, false);
						Boolean someFailure = false;
							if (!savedResults.isSuccess()) {
								someFailure = true;
								for (Database.Error err: savedResults.getErrors()) {
									System.debug('Error occured : ' + err.getStatusCode() + ' : ' + err.getMessage());
									System.debug('Fields that affected this error : ' + err.getFields());
			returnMessage = err.getMessage();
								}
							}
						if (!someFailure) {
							System.debug('newopp Opportunity inserted added successfully');
				returnMessage = newOpp.id;
				cloneOpportunityTeam(newOpp.id, recordId);
						}				  
					
					// 2017-12-04 Added By Jingwei for SF Support Ticket '00008286'***start***
					
				} else { 
					system.debug('===You cannot clone the read only opportunity');
					returnMessage = system.label.ReadOnlyCloneDenied;
				} 
				// 2017-12-04 Added By Jingwei for SF Support Ticket '00008286'***end***
			} else {
				returnMessage = system.label.AccessDenied;
			}
			system.debug('returnMessage' + returnMessage);
			return returnMessage;
		} catch(Exception ex) {
			system.debug('Print Exception' + ex);
			returnMessage = ex.getDmlMessage(0);
			ExceptionHandler.addException(ex, GlobalConstants.CLONE_OPPORTUNITY, GlobalConstants.GET_CLONE_OPPTY);
			return returnMessage;
		}		
	}
	/*******************************
Method Name: cloneOpportunityTeam
Description: Requirement 1507: Sales Process: Opportunity Cloning 
Parameters: old Opportunity id , new Opportunity id
*******************************/
	public static void cloneOpportunityTeam(ID newOpptyId, string oldOpptyID) {
		List < OpportunityTeamMember > opportunityTeamMemberList = new List < OpportunityTeamMember > ();
		List < OpportunityTeamMember > newOpportunityTeamMemberList = null;
		OpportunityTeamMember opportunityTeamMemberObj = new OpportunityTeamMember();
		Id currentUserId = UserInfo.getUserId() ;
		String accManager = System.Label.ACC_MANAGER_TRICON_SCO ;
		Set<String> additionalRole = new Set<String>();
		String roles;
		try {
			opportunityTeamMemberList = [SELECT UserId, User.IsActive, Additional_Team_Role__c, 
										 Name, OpportunityAccessLevel, OpportunityId, TeamMemberRole, Opportunity.OwnerId
										 FROM OpportunityTeamMember where OpportunityId = :oldOpptyID
										 and TeamMemberRole != NULL and User.IsActive = True
										 LIMIT: Limits.getLimitQueryRows() - Limits.getQueryRows()];
			if (!opportunityTeamMemberList.isEmpty()) {
				system.debug('Inside if offerteamlist');
				newOpportunityTeamMemberList = new List < OpportunityTeamMember > ();
				
				for (OpportunityTeamMember obj: opportunityTeamMemberList) {
					system.debug('obj' + obj);
					if(currentUserId != obj.UserId && obj.TeamMemberRole != accManager){
						opportunityTeamMemberObj = new OpportunityTeamMember();
						opportunityTeamMemberObj.Additional_Team_Role__c = obj.Additional_Team_Role__c;
						opportunityTeamMemberObj.UserId = obj.UserId;
						opportunityTeamMemberObj.OpportunityId = newOpptyId;
						opportunityTeamMemberObj.OpportunityAccessLevel = obj.OpportunityAccessLevel;
						opportunityTeamMemberObj.TeamMemberRole = obj.TeamMemberRole;
						newOpportunityTeamMemberList.add(opportunityTeamMemberObj);
					}else if(currentUserId == obj.UserId && obj.Additional_Team_Role__c != Null){
						opportunityTeamMemberObj = new OpportunityTeamMember();
						roles = obj.Additional_Team_Role__c;
						if(roles.contains(accManager)){
							for(String roleVal : roles.split(';'))
							{
								additionalRole.add(roleVal);
							}
							additionalRole.remove(accManager);
							if(additionalRole.size() > 0)
							{
								for(String str : additionalRole)
								{
									if(opportunityTeamMemberObj.Additional_Team_Role__c == null)
									{
										opportunityTeamMemberObj.Additional_Team_Role__c = str;
									}else{
										opportunityTeamMemberObj.Additional_Team_Role__c = opportunityTeamMemberObj.Additional_Team_Role__c+GlobalConstants.SEMICOLON+ str ;  
									}									
								}
							}
							system.debug('opportunityTeamMemberObj.Additional_Team_Role__c'+opportunityTeamMemberObj.Additional_Team_Role__c);
						}else
							opportunityTeamMemberObj.Additional_Team_Role__c = obj.Additional_Team_Role__c;
						opportunityTeamMemberObj.UserId = obj.UserId;
						opportunityTeamMemberObj.OpportunityId = newOpptyId;
						opportunityTeamMemberObj.TeamMemberRole = accManager;
						opportunityTeamMemberObj.OpportunityAccessLevel = GlobalConstants.ALL_ACCESS;
						newOpportunityTeamMemberList.add(opportunityTeamMemberObj);
					}
				}
				
				system.debug('Final newOpportunityTeamMemberList' + newOpportunityTeamMemberList);
				if (!newOpportunityTeamMemberList.isEmpty()) {
					Database.SaveResult[] savedResults = Database.insert(newOpportunityTeamMemberList, false);
					Boolean someFailure = false;
					for (Database.SaveResult sr: savedResults) {
						if (!sr.isSuccess()) {
							someFailure = true;
							for (Database.Error err: sr.getErrors()) {
								System.debug('Error occured : ' + err.getStatusCode() + ' : ' + err.getMessage());
								System.debug('Fields that affected this error : ' + err.getFields());
							}
						}
					}
					if (!someFailure) {
						System.debug('Opty Team added successfully');
					}
				}
				system.debug('OptyTeam Insert successful');
			}
		}
		catch(Exception ex) {
			ExceptionHandler.addException(ex, GlobalConstants.CLONE_OPPORTUNITY, GlobalConstants.GET_CLONE_OPPTY);
		}
	}
}