trigger CollaborationGroupTrigger on CollaborationGroup (before insert, before update) {

	Try{
		String communityId=Network.getNetworkId();
		String PermissionSetName = 'DCP_Chatter_Permission'; 
		string loginUID = UserInfo.getUserId();	  
		User u = [select ID,profileID from User where ID=: loginUID];
		
		if(Test.isRunningTest()){
		
			communityId = [select ID,Name from Network where Name = 'Customers'].ID ;
		
		}	   

		if(communityID!=null){
			String CommunityName=ConnectApi.Communities.getCommunity(communityId).name;

			if(CommunityName=='Customers'){
				if(Trigger.isInsert){

				//  String communityID = ConnectApi.Communities.getCommunities();
							   
					System.debug('#####' + ConnectApi.Communities.getCommunities());			
				
					For(CollaborationGroup cGroup: Trigger.New){
						String cGroupOwnerID = cGroup.OwnerID;
						System.debug('##### cGroupOwnerID:' + cGroupOwnerID); 
						List<PermissionSetAssignment> psAssignment = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name =: PermissionSetName and AssigneeId =: cGroupOwnerID ];		  
						System.debug('##### psAssignment:' + psAssignment);		 
						if(psAssignment.size() != 1 ){
							cGroup.addError('You do not have sufficient privileges to create a group. <br> * If you are a CaPM, Please contact "collaboration.supportportal@nokia.com". * If you are not a CaPM, please contact CaPM of your customer. * If you were trying to create a group for DevOps or Enterprise customer, please contact “collaboration.supportportal@nokia.com"');		
							
						} 
						if(cGroup.CollaborationType == 'Public'){
							cGroup.addError('Creation of Public groups is not allowed on Support Portal. Please select an alternate “Access Type”');   
						}
					}	  
				}
				if(Trigger.isUpdate){
		
					For(CollaborationGroup cGroup: Trigger.New){
						String cGroupOwnerID = cGroup.OwnerID;
						User uValue = [select Id, Profile.Name from User where Id =: cGroupOwnerID];
						String profileName = uValue.Profile.Name;
						if(profileName == 'Customers' || profileName == 'Customers Login'){
							cGroup.addError('Group Ownership cannot be transferred to an external user in Support Portal');	   
						}
						if(cGroup.CollaborationType == 'Public'){
							cGroup.addError('Creation of Public groups is not allowed on Support Portal. Please select an alternate “Access Type”');   
						}					  
					}	  
				 }  
			}
		 }
	  
	}Catch(Exception E){}
	
}