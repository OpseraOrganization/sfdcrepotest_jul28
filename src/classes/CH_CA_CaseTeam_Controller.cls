// There is a lightning component that displays the caseteam members.
// This is instead of the OOTB caseteam. Nokia has specific security requirements
// that cannot be implemented with the OOTB caseteam.
public with sharing class CH_CA_CaseTeam_Controller {	

	// Get the CaseTeamMembers for the case id to display in the UI
	@AuraEnabled
	public static List<CaseTeamMember> getCaseTeamMembers(String caseId){
		return [SELECT Id, Member.Name, TeamRole.Name, CreatedDate 
				FROM CaseTeamMember 
				WHERE ParentId =: caseId];
	}
	
	// Delete a member from the caseteam
	@AuraEnabled
	public static void deleteCaseTeamMember(CaseTeamMember caseMember){
		try {
			CaseTeamMember caseMemberQuery = [SELECT id , MemberId, ParentId, TeamRole.Name,TeamRoleId
											  FROM CaseTeamMember  
											  WHERE id = :caseMember.Id];			
			delete caseMember;

			//Added by Rajeshwari (NOkia) as part of US NOKIASC-17221
			CH_CaseTriggerUtilityHelper.updateExitTimeCaseHistory(caseMemberQuery);
		} catch (Exception e) {
			system.debug('CH_CA: ' + e.getMessage());
			throw new AuraHandledException('Cannot delete caseteam member. '+ e.getMessage());
		}
	}
}