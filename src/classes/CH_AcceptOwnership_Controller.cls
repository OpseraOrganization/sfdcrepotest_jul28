public without sharing class CH_AcceptOwnership_Controller {
	
	@AuraEnabled
	public static boolean validUser(Id caseId){
		Boolean result = false;
		Case curCase = [SELECT Id, CH_Workgroup__c, OwnerId FROM Case WHERE Id =: caseId LIMIT 1];
		Id userId = UserInfo.getUserId();
		String sType = ''+curCase.OwnerId.getsobjecttype();
		if(curCase.CH_Workgroup__c != null && sType.equals('Group')) {
			List<CaseTeamMember> oCaseTeamMember = [SELECT Id, ParentId, MemberId, TeamRoleId FROM CaseTeamMember WHERE ParentId =: caseId AND MemberId =: userId LIMIT 1];
			List<GroupMember> oGroupMember = [SELECT GroupId, UserOrGroupId, Id FROM GroupMember WHERE GroupId =: curCase.OwnerId AND UserOrGroupId =: userId LIMIT 1];
			if(!oCaseTeamMember.isEmpty() || !oGroupMember.isEmpty()) result = true;
		}
		return result;
	}
	
	@AuraEnabled
	public static void assignSelfOwnership(Id caseId){
		Case curCase = [SELECT Id, CH_Workgroup__c, OwnerId FROM Case WHERE Id =: caseId LIMIT 1];
		Id userId = UserInfo.getUserId();
		String sType = ''+curCase.OwnerId.getsobjecttype();
		if(curCase.CH_Workgroup__c != null && sType.equals('Group')) {
			List<CaseTeamMember> oCaseTeamMember = [SELECT Id, ParentId, MemberId, TeamRoleId FROM CaseTeamMember WHERE ParentId =: caseId AND MemberId =: userId LIMIT 1];
			List<GroupMember> oGroupMember = [SELECT GroupId, UserOrGroupId, Id FROM GroupMember WHERE GroupId =: curCase.OwnerId AND UserOrGroupId =: userId LIMIT 1];
			if(!oCaseTeamMember.isEmpty() || !oGroupMember.isEmpty()){
				curCase.OwnerId = userId;
				update curCase;				
			}
		}
	}
}