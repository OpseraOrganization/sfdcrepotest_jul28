/**
*   This class is used as a helper to Update ApprovalRequest History 
*   "Role NAme", "Organization" and "AssigneeType" from the Rule Assignee Table
*/
public with sharing class NF_TL_UpdateHistoryRequestRCode {
	
	/**
	*   @desc   : Method used to update approvalRuleHistory Fields based on the appropriate AssigneeRule Table
	*   @param  : List<Apttus_Approval__Approval_Request_History__c>
	*/
	public static void updateHistoryRequestRcodeM(List<Apttus_Approval__Approval_Request_History__c> historyRequests){
		List<Apttus_Approval__Approval_Request_History__c> tmpRequests =[
					SELECT
						Id,
						Apttus_Approval__SubstepName__c,
						Apttus_Approval__Assigned_To_Id__c,
						Apttus_Approval__Related_Opportunity__c,
						Apttus_Approval__Related_Opportunity__r.PSR_Lead_Business_Unit__c,
						Apttus_Approval__Related_Opportunity__r.PSR_Lead_Business_Group__c,						
						Apttus_Approval__Related_Opportunity__r.Lead_BG__c,
						Apttus_Approval__Related_Opportunity__r.Lead_BU__c,
						Apttus_Approval__Related_Opportunity__r.Org_L2__c,
						Apttus_Approval__Related_Opportunity__r.Org_L3__c,
						Apttus_Approval__Related_Opportunity__r.Org_L4__c,
						Apttus_Approval__Related_Opportunity__r.Org_L5__c,
						Apttus_Approval__Related_Opportunity__r.Org_L6__c,
						Apttus_Approval__Related_Opportunity__r.Org_L7__c,
						BG_Attribute__c,
						NF_Organization_Level__c,
						NF_Role_Code__c,
						NF_Role_Name__c,
						NF_Assignee_Type__c
					FROM
						Apttus_Approval__Approval_Request_History__c
					WHERE
						Id in :historyRequests
					];

		set<String> assignedUsers = new set<String>();
		set<String> arulesSet = new set<String>();

		//Fetch  assignedTo Users + ApprovalRuleAssignees Name
		for(Apttus_Approval__Approval_Request_History__c request : historyRequests){
			arulesSet.add(request.Apttus_Approval__SubstepName__c);
			assignedUsers.add(request.Apttus_Approval__Assigned_To_Id__c);
			System.debug('-->User'+assignedUsers+arulesSet);
		}
		
		System.debug('historyRequests-->'+historyRequests);

		set<String> orgsSet = new set<String>();
		set<String> codesSet = new set<String>();
		set<String> BGSet = new set<String>();
		Map<String, String> arAssigneeToOrgndCodeMap = new Map<String, String>();
		Map<String, String> arAssigneeToType = new Map<String, String>();

		//Loop Through assignees and construct : Org, roles, Map for each assigneeName relatedOrg+Code
		for(Apttus_Approval__ApprovalRuleAssignee__c arAssignee :[SELECT Id,Apttus_Approval__AssigneeValue__c,
																	Apttus_Approval__AssigneeDescription__c,Name
																  FROM Apttus_Approval__ApprovalRuleAssignee__c
																  WHERE Name in :arulesSet
																]){
			String org='';
			String org1='';
			String code='';
			string lead_bg = '';
			string lead_bu = '';
			
			List<String> codList = new List<String>();
			List<String> org_codList = new List<String>();
			List<String> BG_List = new List<String>();
			
			String BG_Val = '';
			String BU_Val = '';
			 System.debug('Asignee Rule ID --->'+arAssignee.Id);
			
			//Map for unique AssigneeNAme to Description which can be : Approver, Validator, Stackholder to be used for ValidatorComments.
			if(!arAssigneeToType.containsKey(arAssignee.Name) && String.isNotBlank(arAssignee.Apttus_Approval__AssigneeDescription__c))
			arAssigneeToType.put(arAssignee.Name, arAssignee.Apttus_Approval__AssigneeDescription__c.subString(arAssignee.Apttus_Approval__AssigneeDescription__c.lastIndexOf(',')+1, arAssignee.Apttus_Approval__AssigneeDescription__c.length()));				   
	   
			
			//Check wether the Record has a valid value in  the field assigneeValue, if yes then split.
			if(arAssignee.Apttus_Approval__AssigneeValue__c != null && arAssignee.Apttus_Approval__AssigneeValue__c.contains('AND'))
			{
				codList = arAssignee.Apttus_Approval__AssigneeValue__c.split('AND');
				if(codList[1].contains('OR'))
				org_codList = codList[1].split('OR');
				If(codlist.size()== 4)
				{
				if(codList[3].contains('OR'))
				BG_List = codList[3].split('OR');						
				}
			}
			system.debug('org_codList:'+org_codList);
			system.debug('codList:'+codList);
			//Get the Organization Level from SalesRole, then get the value from the opportunity by Dynamic Apex.  
			 for(Apttus_Approval__Approval_Request_History__c request : tmpRequests)
			{
				 if(arAssignee.Name.equalsIgnoreCase(request.Apttus_Approval__SubstepName__c) && request.Apttus_Approval__Related_Opportunity__r != null && !codList.isEmpty())
				 {
													   
								 
					 if(!BG_List.isEmpty())
					 {		   
						Lead_bg = BG_List[0].subString(BG_List[0].lastIndexOf(':')+1,BG_List[0].length()-2).remove(' ');
						BG_Val = String.valueOf(request.Apttus_Approval__Related_Opportunity__r.get(Lead_bg));

						if(BG_Val == 'ION' || BG_Val == 'NEN')
						{
						BGSet.add(BG_Val);						
						Lead_bu = BG_List[1].subString(BG_List[1].lastIndexOf(':')+1,BG_List[1].IndexOf(')')-1).remove(' ');
						BG_Val = String.valueOf(request.Apttus_Approval__Related_Opportunity__r.get(Lead_bu));
						}
					 }
					 else if(codList.size() == 4)
					 {
					 BG_Val = codList[3].subString(codList[3].lastIndexOf('=')+2,codList[3].IndexOf(')')-1);
					 }
					 if(string.isNotBlank(BG_Val))
					 BGSet.add(BG_Val);
				
				if(!org_codList.isEmpty())
				{			 
					for(String org_all : Org_codList)
					{
						org_all.replace('(','').trim();													   
						If(org_all.contains(')'))
						org1 = org_all.subString(org_all.lastIndexOf(':')+1, org_all.IndexOf(')')-1).remove(' ');   
						else
						org1 = org_all.subString(org_all.lastIndexOf(':')+1, org_all.length()-2).remove(' ');	   
						org = String.valueOf(request.Apttus_Approval__Related_Opportunity__r.get(org1));														  
						code = codList[0].subString(codList[0].lastIndexOf('%')+2, codList[0].length()-2).remove(' '); 
					 //Map for Unique Assignee name to Code
					if(!arAssigneeToOrgndCodeMap.containsKey(arAssignee.Name) && String.isNotBlank(code) && String.isNotBlank(org))
					arAssigneeToOrgndCodeMap.put(arAssignee.Name,code+BG_Val);	 
					system.debug('arAssigneeToOrgndCodeMAp:'+arAssigneeToOrgndCodeMap);						
						if(org1.contains('2'))
						code = 'NSNA'+code;
						else if(org1.contains('3'))
						code = 'NSNB'+code;
						else if(org1.contains('4'))
						code = 'NSNC'+code;
						else if(org1.contains('5'))
						code = 'NSND'+code;
						else if(org1.contains('6'))
						code = 'NSNE'+code;
						else if(org1.contains('7'))
						code = 'NSNG'+code;		  
					//Sets used to get Sales Role records					   
					if(String.isNotBlank(code))
					codesSet.add(code);		 
						//Sets used to get Sales Role records.
						if(String.isNotBlank(org))
						orgsSet.add(org); 
									   
					}
				}		 
				else
				{
					org1 = codList[1].subString(codList[1].lastIndexOf(':')+1, codList[1].length()-2).remove(' ');
					  org = String.valueOf(request.Apttus_Approval__Related_Opportunity__r.get(org1));	
					code = codList[0].subString(codList[0].lastIndexOf('%')+2, codList[0].length()-2).remove(' ');
					//Map for Unique Assignee name to Code
					if(!arAssigneeToOrgndCodeMap.containsKey(arAssignee.Name) && String.isNotBlank(code) && String.isNotBlank(org))
					arAssigneeToOrgndCodeMap.put(arAssignee.Name,code+BG_Val);	 
					system.debug('arAssigneeToOrgndCodeMAp:'+arAssigneeToOrgndCodeMap); 
					if(org1.contains('2'))
						code = 'NSNA'+code;
						else if(org1.contains('3'))
						code = 'NSNB'+code;
						else if(org1.contains('4'))
						code = 'NSNC'+code;
						else if(org1.contains('5'))
						code = 'NSND'+code;
						else if(org1.contains('6'))
						code = 'NSNE'+code;
						else if(org1.contains('7'))
						code = 'NSNG'+code;		  
					//Sets used to get Sales Role records					   
					if(String.isNotBlank(code))
					codesSet.add(code);		 
					if(String.isNotBlank(org))			   
					orgsSet.add(org); 
																							 
				}									
			}											
		}
		}
		system.debug('code:'+codesSet);
		system.debug('OrsSet:'+orgsSet);
		system.debug('BGSet:'+BGSet);
		Map<String, Sales_Role__c> rolendOrgToSalesRoleMap = new Map<String, Sales_Role__c>();
		for(Sales_Role__c sRole :[
								SELECT
									Id,
									User__c,
									BG__c,
									Role_Name__c,
									Organisation__c,
									Role_Code__c
								FROM
									Sales_Role__c
								WHERE
									(BG__c = :BGSet or BG__c = '')
									AND
									Role_Code__c in :codesSet
									AND
									Organisation__c in :orgsSet
								 //   AND
								 //   User__c in :assignedUsers
								]
		){
			
			//Map for unique Code+Organization to the relevant record sRole.
			//String Role_Map_Key = sRole.Role_Code__c+''+sRole.Organisation__c;
			string Role = sRole.Role_Code__c;
			String Role_Map_Key ='';
			IF(sRole.BG__c!=null)
			Role_Map_Key = Role.subString(Role.lastIndexOf('_'))+sRole.BG__c;
			else
			Role_Map_Key = Role.subString(Role.lastIndexOf('_'));			
			if(!rolendOrgToSalesRoleMap.containsKey(Role_Map_Key.touppercase())){
				rolendOrgToSalesRoleMap.put(Role_Map_Key.touppercase(), sRole);
				system.debug('sRole:'+sRole);
			}
		}
		system.debug('########## rolendOrgToSalesRoleMap ' + rolendOrgToSalesRoleMap );
		//Loop throught historyRequest list and update the relevant data.
		Savepoint sp = null;
		for(Apttus_Approval__Approval_Request_History__c request : tmpRequests){
			 String RoleBGVal = '';
		if(arAssigneeToOrgndCodeMap.get(request.Apttus_Approval__SubstepName__c) != null )
		RoleBGVal = (arAssigneeToOrgndCodeMap.get(request.Apttus_Approval__SubstepName__c).touppercase());
		system.debug('RoleBGVal:'+RoleBGVal);
		  if((RoleBGVal.contains('ION')||RoleBGVal.contains('NEN')) && rolendOrgToSalesRoleMap.get(RoleBGVal) == null)
		  {
		  List<String> keyset = RoleBGVal.split(' ');
		  RoleBGVal = keyset[0];
		  system.debug('RoleBGVal:'+RoleBGVal);
		  }
			if(arAssigneeToOrgndCodeMap.get(request.Apttus_Approval__SubstepName__c) != null 
				&& rolendOrgToSalesRoleMap.get(RoleBGVal) != null
			  ){
				Sales_Role__c sRole = new Sales_Role__c();
				sRole = rolendOrgToSalesRoleMap.get(RoleBGVal);
				if(sRole != null){
					request.NF_Organization_Level__c = sRole.Organisation__c;
					system.debug('########## Role Code ' + sRole.Role_Code__c );
					system.debug('########## sRole.Role_Name__c ' + sRole.Role_Name__c );
					System.debug('########## sRole.BG__c'+sRole.BG__c);
					request.NF_Role_Code__c = sRole.Role_Code__c;
					request.NF_Role_Name__c = sRole.Role_Name__c; 
					if(sRole.BG__c<>NUll)  
					
					request.BG_Attribute__c=sRole.BG__c;
					
					
				}
			}
				if(arAssigneeToType.get(request.Apttus_Approval__SubstepName__c) != null){
				request.NF_Assignee_Type__c = arAssigneeToType.get(request.Apttus_Approval__SubstepName__c);
				}
		}
		try{
			sp = Database.setSavepoint();
			Database.update(tmpRequests,false);
		}catch(DmlException e){
			if (sp != null) Database.rollback(sp);
			system.debug('###Exception from NF_TL_UpdateHistoryRequestRCode : '+e.getMessage() + 'Stack Trace : '+e.getStackTraceString());
			throw e;
		}
		
	}
}