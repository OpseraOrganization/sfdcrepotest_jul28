/**
 * @name	NF_TL_UpdateRequestRCode 
 * @author  Jamal Rida 
 * @since   Dec 29, 2016
 * @desc	This class used to serve as Trigger Logic for implementing RoleName/Code/Organization in the ARRequests.
 * @history 
 */
public with sharing class NF_TL_UpdateRequestRCode {
	 @TestVisible  private Static  List<user> backup_Admin =new List<user>();
   
   @TestVisible  private Static  Map<ID,Apttus_Approval__ApprovalRuleEntry__c> RuleName= new Map<ID,Apttus_Approval__ApprovalRuleEntry__c>();

	@TestVisible  private Static Map<ID,Apttus_Approval__Approval_Request__c> parentinfo= new Map<ID,Apttus_Approval__Approval_Request__c>();

 @TestVisible  private Static Map<Id,Apttus_Approval__ApprovalRuleEntry__c> RuleEntrySet =new Map<Id,Apttus_Approval__ApprovalRuleEntry__c>();
 @TestVisible  private Static Map<ID,Sales_Role__c> FinalList = new Map<ID,Sales_Role__c>();
 @TestVisible  private Static  Integer count = 0;
  @TestVisible Private Static  Integer Total_count = 0;	
	@TestVisible Private Static  List<Apttus_Approval__Approval_Request__c> ParentReqUpdate = new list<Apttus_Approval__Approval_Request__c>();

	/**
	*   @desc   : Method used to update approvalRuleRequest Fields based on the appropriate AssigneeRule Table
	*   @param  : List<Apttus_Approval__Approval_Request__c>
	*/
	public static void updateRequestRcodeM(List<Apttus_Approval__Approval_Request__c> appRequests){			 

		List<Apttus_Approval__Approval_Request__c> tmpRequests = [
					SELECT
						Id,
						Apttus_Approval__SubstepName__c,
						Apttus_Approval__Assigned_To_Id__c,
						Apttus_Approval__Notify_Only__c,
						Apttus_Approval__Related_Opportunity__c,
						Apttus_Approval__Related_Opportunity__r.PSR_Lead_Business_Unit__c,
						Apttus_Approval__Related_Opportunity__r.PSR_Lead_Business_Group__c,												
						Apttus_Approval__Related_Opportunity__r.Lead_BG__c,
						Apttus_Approval__Related_Opportunity__r.Lead_BU__c,						
						Apttus_Approval__Related_Opportunity__r.OwnerID,
						Apttus_Approval__Related_Opportunity__r.Org_L2__c,
						Apttus_Approval__Related_Opportunity__r.Org_L3__c,
						Apttus_Approval__Related_Opportunity__r.Org_L4__c,
						Apttus_Approval__Related_Opportunity__r.Org_L5__c,
						Apttus_Approval__Related_Opportunity__r.Org_L6__c,
						Apttus_Approval__Related_Opportunity__r.Org_L7__c,
						NF_Assignee_Value__c,
						Related_Sales_Role__c,
						NF_BG_Attribute__c,
						Apttus_Approval__Send_Email__c,
						NF_Organization_Level__c,
						Apttus_Approval__Approval_Status__c,
						NF_Role_Code__c,
						NF_Role_Name__c,
						NF_Assignee_Type__c,
						Apttus_Approval__Assigned_To_Type__c
					FROM
						Apttus_Approval__Approval_Request__c
					WHERE
						Id in :appRequests
					];
		system.debug('tmpRequests:'+tmpRequests);
		set<String> assignedUsers = new set<String>();
		set<String> arulesSet = new set<String>();
		
		//Fetch  assignedTo Users + ApprovalRuleAssignees Name
		for(Apttus_Approval__Approval_Request__c request : appRequests){
			arulesSet.add(request.Apttus_Approval__SubstepName__c);
			assignedUsers.add(request.Apttus_Approval__Assigned_To_Id__c);
		}
		system.debug('arulesSet:'+arulesSet);
		set<String> orgsSet = new set<String>();
		set<String> BGSet = new set<String>();
		set<String> codesSet = new set<String>();
		Map<String, String> arAssigneeToOrgndCodeMap = new Map<String, String>();
		Map<String, String> arAssigneeToType = new Map<String, String>();
		Map<String, String> arAssigneeValue = new Map<String, String>();

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
			if(!arAssigneeValue.containsKey(arAssignee.Name) && String.isNotBlank(arAssignee.Apttus_Approval__AssigneeValue__c))
			arAssigneeValue.put(arAssignee.Name, arAssignee.Apttus_Approval__AssigneeValue__c);		 
			
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
			 for(Apttus_Approval__Approval_Request__c request : tmpRequests)
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
									AND
									User__c in :assignedUsers
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

		//Loop throught historyRequest list and update the relevant data.
		Savepoint sp = null;
		for(Apttus_Approval__Approval_Request__c request : tmpRequests){	
		String RoleBGVal = '';
		if(arAssigneeToOrgndCodeMap.get(request.Apttus_Approval__SubstepName__c) != null )
		RoleBGVal = (arAssigneeToOrgndCodeMap.get(request.Apttus_Approval__SubstepName__c).touppercase());
		  if((RoleBGVal.contains('ION') || RoleBGVal.contains('NEN'))&& rolendOrgToSalesRoleMap.get(RoleBGVal) == null)
		  {
		  List<String> keyset = RoleBGVal.split(' ');
		  RoleBGVal = keyset[0];
		  }
			if(arAssigneeToOrgndCodeMap.get(request.Apttus_Approval__SubstepName__c) != null 
				&& rolendOrgToSalesRoleMap.get(RoleBGVal) != null
			  ){
				Sales_Role__c sRole = new Sales_Role__c();
				sRole = rolendOrgToSalesRoleMap.get(RoleBGVal);
						
				if(sRole != null){
					request.NF_Organization_Level__c = sRole.Organisation__c;
					request.NF_Role_Code__c = sRole.Role_Code__c;
					request.NF_Role_Name__c = sRole.Role_Name__c;  
					request.Related_Sales_Role__c = sRole.ID; 
					system.debug('sRoleCode: '+ sRole.Role_Code__c);	
				}				
			}
			if(arAssigneeToType.get(request.Apttus_Approval__SubstepName__c) != null){
			System.debug('---->'+arAssigneeToType.get(request.Apttus_Approval__SubstepName__c));
			request.NF_Assignee_Type__c = arAssigneeToType.get(request.Apttus_Approval__SubstepName__c);
			   //if(arAssigneeToType.get(request.Apttus_Approval__SubstepName__c).contains('stakeholder'))
			   //request.Apttus_Approval__Approval_Status__c='';
			}
			if(arAssigneeValue.get(request.Apttus_Approval__SubstepName__c) != null){
			request.NF_Assignee_Value__c = arAssigneeValue.get(request.Apttus_Approval__SubstepName__c);
			}   
			if (request.Apttus_Approval__Assigned_To_Type__c<>Null && request.Apttus_Approval__Assigned_To_Type__c.equalsignorecase(GlobalConstants.QUEUE)) {
			  request.NF_Assignee_Type__c = GlobalConstants.STAKEHOLDER_INFORMATION;
			
			}
			if(request.Apttus_Approval__Assigned_To_Type__c<>Null && request.Apttus_Approval__Assigned_To_Id__c<>NUll && request.Apttus_Approval__Notify_Only__c<>True && request.Apttus_Approval__Send_Email__c<>True && request.Apttus_Approval__Assigned_To_Id__c.equalsignorecase(request.Apttus_Approval__Related_Opportunity__r.OwnerID))
			 request.NF_Assignee_Type__c = GlobalConstants.STAKEHOLDER_INFORMATION;
			
		}
		try{
			sp = Database.setSavepoint();
			Database.update(tmpRequests,false);
		}catch(DmlException e){
			if (sp != null) Database.rollback(sp);
			system.debug('###Exception from NF_TL_UpdateRequestRCode : '+e.getMessage() + 'Stack Trace : '+e.getStackTraceString());
			throw e;
		}
	}
	
	 /**
	*   @desc   : Method used to update  the Approval Date field
	*   @param  : List<Apttus_Approval__Approval_Request__c> Map<ID,Apttus_Approval__Approval_Request__c>
	*/
	
	public static void CopieApprovalStatus(List<Apttus_Approval__Approval_Request__c> appRequests, map<Id,Apttus_Approval__Approval_Request__c> MapOld){
		list<Apttus_Approval__Approval_Request__c> ApprovalToUpdate = new list<Apttus_Approval__Approval_Request__c>();
		set<Id> opportunityIds = new set<Id>();
		String ApprovalStatus;
		for(Apttus_Approval__Approval_Request__c app : appRequests){
			if( (app.Apttus_Approval__Approval_Status__c == 'Approved' || app.Apttus_Approval__Approval_Status__c =='Cancelled' || app.Apttus_Approval__Approval_Status__c =='Rejected')  && 
			   app.Apttus_Approval__Approval_Status__c != MapOld.get(app.id).Apttus_Approval__Approval_Status__c && 
			   app.Apttus_Approval__Assigned_To_Name__c == null){
				ApprovalStatus=app.Apttus_Approval__Approval_Status__c;
				if(app.Apttus_Approval__Related_Opportunity__c != null) opportunityIds.add(app.Apttus_Approval__Related_Opportunity__c);
			}
		}
		if(!opportunityIds.isEmpty()){
			for(Apttus_Approval__Approval_Request__c App : [select Id,Tech_Approval_Date__c,Tech_Status__c from Apttus_Approval__Approval_Request__c where Apttus_Approval__Related_Opportunity__c IN: OpportunityIds ]){
				App.Tech_Approval_Date__c = datetime.now();
				App.Tech_Status__c = ApprovalStatus;
				ApprovalToUpdate.add(App);
			}
		}
		Try{
			if(!ApprovalToUpdate.isEmpty())
			Database.update(ApprovalToUpdate,False);
		}catch(Exception e){
			 system.debug('###Exception from NF_TL_UpdateRequestRCode : '+e.getMessage() );
		}
	}
	
	
   
   
Public Static Void UpdateValidatorStatus(List<Apttus_Approval__Approval_Request__c> appRequests)
{   
   
	Savepoint sp = null;
	set<Id> ParentReqIds = new set<Id>();
	if(!GlobalConstants.UPDATE_VALIDATOR_REQUEST_STATUS){
	
	 for(Apttus_Approval__Approval_Request__c app : appRequests){
	 if(app.NF_Assignee_Type__c == 'Validator')
	 ParentReqIds.add(app.Apttus_Approval__ParentRequestId__c); 
		 system.debug('ParentReqIds : ' + ParentReqIds);
	}
	  if(!ParentReqIds.isEmpty()){
			for(Apttus_Approval__Approval_Request__c App_req : [select Id, Validator_Status__c,Validator_Request_Status__c from Apttus_Approval__Approval_Request__c where Apttus_Approval__ParentRequestId__c IN: ParentReqIds and NF_Assignee_Type__c = 'Validator']){				
					Total_Count = Total_count + 1;
					IF(App_req.Validator_Status__c != null)
					 count = count + 1;
					 system.debug('Count : ' + count);
					 system.debug('Total_Count : ' + Total_count);
				}
			for(Apttus_Approval__Approval_Request__c App : [select Id, Validator_Status__c,Validator_Request_Status__c  from Apttus_Approval__Approval_Request__c where Id IN: ParentReqIds]){
			if(count == Total_count && Total_count != null)
			{
				App.Validator_Request_Status__c = true;
				ParentReqUpdate.add(App);
			}
				else if(count != Total_count && App.Validator_Request_Status__c == true && Total_count != null)
				{
					App.Validator_Request_Status__c = false;
				ParentReqUpdate.add(App);					
				}
		}
		}
		Try{
			if(!ParentReqUpdate.isEmpty()){
			Database.update(ParentReqUpdate,False);
			
			}
			GlobalConstants.UPDATE_VALIDATOR_REQUEST_STATUS=true;
		}catch(Exception e){
			 system.debug('###Exception from NF_TL_UpdateRequestRCode : '+e.getMessage() );
		}
  }
}
	
	 /**
	*   @desc   : Method used to Update the non NSA users to NSA Backup user 
	*   @param  : List<Apttus_Approval__Approval_Request__c>  
	*/
	
 public static void updateAssignee_NSA(List<Apttus_Approval__Approval_Request__c> appRequests)
 {
	 try{
		   set<ID> assignedUsers = new set<ID>();
			set<ID> OpptySet= new set<ID>();
			 String Cust_compliance;
			
			List<Opportunity> Oppty= new List<Opportunity>();
				for(Apttus_Approval__Approval_Request__c request : appRequests)
			{
			  
				if(request.Apttus_Approval__Related_Opportunity__c != null)
				 Cust_compliance = Request.Oppty_Cust_compliance__c;
				System.debug('Oppty_Cust_compliance__c---->'+Request.Oppty_Cust_compliance__c);
				 
			}
		   
			
			If(Cust_compliance<>NUll && Cust_compliance == 'US_Govern' )
			{
			 
			
			
				if(backup_Admin.isEmpty())
				 backup_Admin = [ Select Id from User where Name =: Label.NF_NSA_BAckupAdmin ];
				
					for(Apttus_Approval__Approval_Request__c request : appRequests)
					{   
						if(request.Approver_User__c != null &&!request.Asigneed_User_NSA_Check__c && !backup_Admin.isEmpty() )
						{
							request.Apttus_Approval__Assigned_To_Id__c = backup_Admin[0].id;
							request.Apttus_Approval__Assigned_To_Name__c = Label.NF_NSA_BAckupAdmin;
							request.OwnerId = backup_Admin[0].id;
							
						}
					}
			}
			
		 }
		 catch(Exception Exp)
		 {
		   System.debug('updateAssignee_NSA Method Exception #####'+Exp.getMessage());
		 }
		  
	
 
	
 }


	 /**
	*   @desc   : Method used to Insert the stakeholders dynamically
	*   @param  : List<Apttus_Approval__Approval_Request__c>  
	*/
  
  
  Public Static Void InsertStakeholderRec(List<Apttus_Approval__Approval_Request__c> appRequests)
	  { 
   
	Set<String> EntryName = new set<String>();
	Set<String> SH_EntrySet = new set<String>();
	Map<String,String> RuleAssignee = new Map<String,String>();
	Map<String,String> RuleAssigneeName = new Map<String,String>();
	Set<ID> StakeHolderIds= new Set<ID>();
	Map<ID,String> Delegates =new Map<ID,String>();
	Map<String,String> AssigneedData= new Map<String,String>();
	List<ID> Stakeholderinfo1 =new List<ID>();
	Map<ID,ID> ValidatorID =new Map<ID,ID>();
	Map<Id,set<String>> map_uId_bgs =new Map<Id,set<String>>();//added by chen chen<chen.8.chen.ext@nokia.com> on 2018-06-22 to fliter Approval Request
	set<String> set_bgCodes = new set<String>();//added by chen chen<chen.8.chen.ext@nokia.com> on 2018-06-22 to save bgs of opp for fliter Approval Request
	map<String, Apttus_Approval__Approval_Request__c> map_arId_ar = new map<String, Apttus_Approval__Approval_Request__c>();//added by chen chen<chen.8.chen.ext@nokia.com> on 2018-06-22 to save assign type from Approval Request
		  
	 list<Apttus_Approval__Approval_Request__c> Stakeholderinfo =new  list<Apttus_Approval__Approval_Request__c>();
	List<Apttus_Approval__ApprovalRuleEntry__c> EntrySet = new List<Apttus_Approval__ApprovalRuleEntry__c>();
	Integer Count =0;
	string l2 ;
	string l3 ;
	string l4 ;
	string l5 ;
	string l6 ;
	string l7 ; 
	
   try{
	List<Opportunity> Oppty= new List<Opportunity>();
	String Lead_BG = '';
	String Lead_BU = '';
	String PSR_BG ='';
	String PSR_BU = '';
	   //commented by chen chen<chen.8.chen.ext@nokia.com> on 2018-06-22 to add fields for fliter Approval Request
	oppty = [Select Lead_BG__c, Lead_BU__c,PSR_Lead_Business_Group__c,PSR_Lead_Business_Unit__c from Opportunity where ID =: appRequests[0].Apttus_Approval__Related_Opportunity__c];		  
	   //added by chen chen<chen.8.chen.ext@nokia.com> on 2018-06-22 to add fields for fliter Approval Request
	   oppty = [Select Lead_BG__c, Supporting_BG_ION__c,Supporting_BG_NEN__c ,Supporting_BG_MN__c, Supporting_BG_AA__c, Supporting_BG_FN__c, Supporting_BG_GS__c, Lead_BU__c,PSR_Lead_Business_Group__c,PSR_Lead_Business_Unit__c from Opportunity where ID =: appRequests[0].Apttus_Approval__Related_Opportunity__c];
	   If(Oppty.size() > 0)
	   {
		Lead_BG = Oppty[0].Lead_BG__c;
		Lead_BU = Oppty[0].Lead_BU__c; 
		PSR_BG = oppty[0].PSR_Lead_Business_Group__c;		
		PSR_BU = Oppty[0].PSR_Lead_Business_Unit__c;
		   //added by chen chen<chen.8.chen.ext@nokia.com> on 2018-06-22 to get bg code for fliter Approval Request
		   if(String.isNotEmpty(Oppty[0].Lead_BG__c))
		   set_bgCodes.add(Oppty[0].Lead_BG__c);
		   if(String.isNotEmpty(Oppty[0].Supporting_BG_ION__c))
		   set_bgCodes.add(Oppty[0].Supporting_BG_ION__c);
		   if(String.isNotEmpty(Oppty[0].Supporting_BG_MN__c))
		   set_bgCodes.add(Oppty[0].Supporting_BG_MN__c);
		   if(String.isNotEmpty(Oppty[0].Supporting_BG_AA__c))
		   set_bgCodes.add(Oppty[0].Supporting_BG_AA__c);
		   if(String.isNotEmpty(Oppty[0].Supporting_BG_FN__c))
		   set_bgCodes.add(Oppty[0].Supporting_BG_FN__c);
		   if(String.isNotEmpty(Oppty[0].Supporting_BG_GS__c))
		   set_bgCodes.add(Oppty[0].Supporting_BG_GS__c);
		   if(String.isNotEmpty(Oppty[0].Supporting_BG_NEN__c))
			 set_bgCodes.add(Oppty[0].Supporting_BG_NEN__c);
		   //end added by chen chen<chen.8.chen.ext@nokia.com> on 2018-06-22 to get bg code for fliter Approval Request
		}
	System.debug('Calling--------------');

	   //added by chen chen<chen.8.chen.ext@nokia.com> on 2018-06-22 to get ASSIGNEE TYPE from Approval Request
	   set<String> set_arIds = new set<String>();
	   for(Apttus_Approval__Approval_Request__c Parentrec : appRequests) {
		   set_arIds.add(Parentrec.Id);
	   }
	   for(Apttus_Approval__Approval_Request__c ar : [select Id, NF_Assignee_Type__c, NF_BG_Attribute__c From Apttus_Approval__Approval_Request__c Where Id IN: set_arIds]) {
		   map_arId_ar.put(ar.Id, ar);
	   }
	   //end added by chen chen<chen.8.chen.ext@nokia.com> on 2018-06-22 to get ASSIGNEE TYPE from Approval Request
	   
	for(Apttus_Approval__Approval_Request__c Parentrec:appRequests)
	 {
	  
	 System.debug('Sub process name --->'+Parentrec);
	 if(Parentrec.Apttus_Approval__ParentRequestId__c<>null )
	  {
		  System.debug('Calling inside'+parentinfo);
		parentinfo.clear();
		 parentinfo.put(Parentrec.id,Parentrec); 
		  
		 if(Parentrec.Apttus_Approval__IsSubprocess__c == true )
			 {
			  EntryName.add(Parentrec.Apttus_Approval__SubprocessName__c);
			  }
	   
		}   
	   
		system.debug('Entry Name:'+EntryName);
		 //commented by chen chen<chen.8.chen.ext@nokia.com> on 2018-06-22 to fliter Approval Request
		 //ValidatorID.put(Parentrec.Apttus_Approval__Assigned_To_Id__c,Parentrec.Apttus_Approval__Assigned_To_Id__c);
		 //added by chen chen<chen.8.chen.ext@nokia.com> on 2018-06-22 to fliter Approval Request
		 if(map_arId_ar.get(Parentrec.Id).NF_Assignee_Type__c == GlobalConstants.APPROVER || map_arId_ar.get(Parentrec.Id).NF_Assignee_Type__c == GlobalConstants.VALIDATOR || set_bgCodes.size() <= 1) {
			 //these user will not show again
			 ValidatorID.put(Parentrec.Apttus_Approval__Assigned_To_Id__c,Parentrec.Apttus_Approval__Assigned_To_Id__c);
		 }else if(map_arId_ar.get(Parentrec.Id).NF_Assignee_Type__c == GlobalConstants.STAKEHOLDER_INFORMATION && set_bgCodes.size() > 1) {
			 //these user will check user is duplicate or not
			 if(!map_uId_bgs.containsKey(Parentrec.Apttus_Approval__Assigned_To_Id__c)) {
				 map_uId_bgs.put(Parentrec.Apttus_Approval__Assigned_To_Id__c, new set<String>());
			 }
			 map_uId_bgs.get(Parentrec.Apttus_Approval__Assigned_To_Id__c).add(map_arId_ar.get(Parentrec.Id).NF_BG_Attribute__c);
		 }
		 //end added by chen chen<chen.8.chen.ext@nokia.com> on 2018-06-22 to fliter Approval Request
	 }system.debug('map_uId_bgs@@' + map_uId_bgs);
	 
	 for(Apttus_Approval__Approval_Request__c Parentrec:parentinfo.values()){
	 
	 l2 = Parentrec.Org_l2__c;
	   l3 = Parentrec.Org_l3__c;
		l4 = Parentrec.org_L4__c;
		l5 = Parentrec.org_L5__c;
		l6 = Parentrec.org_L6__c;
		l7 = Parentrec.org_L7__c; 
		Count=String.ValueOf(Parentrec.Apttus_Approval__StepSequence__c).length();
	 }   
	 System.debug('--->'+l2);
	  System.debug('--->'+l3);
	   System.debug('--->'+l4);
		System.debug('--->'+l5);
		 System.debug('--->'+l6);
		  System.debug('--->'+l7);
	 
	 System.debug('Parent Record-->'+parentinfo.values());
	  System.debug('Parent Record-->'+EntryName);
	  
	  for(Apttus_Approval__ApprovalRuleEntry__c EuleEntry:[Select Id, Apttus_Approval__EntryLabel__c from Apttus_Approval__ApprovalRuleEntry__c where Name in :EntryName])
	  {
		  SH_EntrySet.add(EuleEntry.Apttus_Approval__EntryLabel__c+'-SH');
	   System.debug('EuleEntry'+EuleEntry);
	  }
	System.debug('EntrySet'+SH_EntrySet);
 
	for(Apttus_Approval__ApprovalRuleEntry__c RuleEntry:[Select ID,Apttus_Approval__EntryLabel__c,Apttus_Approval__ApprovalRuleId__r.name from Apttus_Approval__ApprovalRuleEntry__c where Apttus_Approval__EntryLabel__c in :SH_EntrySet])
	
	{
	System.debug('Stakeholder ruleid---->'+RuleEntry.ID);
	RuleEntrySet.put(RuleEntry.ID,RuleEntry);
	
	
	}
	
	
 
	 if(!RuleEntrySet.isEmpty()) {
	 List<Sales_Role__c> SRList = new List<Sales_Role__c>();
				 
	for(Apttus_Approval__ApprovalRuleAssignee__c AssigneeObj :[SELECT Id, Name, Apttus_Approval__RuleEntryId__c,Apttus_Approval__AssigneeType__c, Apttus_Approval__AssigneeDescription__c,Apttus_Approval__AssigneeValue__c
																  FROM Apttus_Approval__ApprovalRuleAssignee__c
																  WHERE Apttus_Approval__RuleEntryId__c in : RuleEntrySet.Keyset()])
	{
		System.debug('Rule entry'+AssigneeObj.Apttus_Approval__AssigneeValue__c+AssigneeObj.Apttus_Approval__AssigneeDescription__c);
	  if(AssigneeObj.Apttus_Approval__AssigneeValue__c != null && AssigneeObj.Apttus_Approval__AssigneeValue__c.contains('Sales_Role__c') && AssigneeObj.Apttus_Approval__AssigneeDescription__c.contains('Stakeholder for Information'))
	   {
				
				 
		
		String where_Clause = AssigneeObj.Apttus_Approval__AssigneeValue__c.subString(AssigneeObj.Apttus_Approval__AssigneeValue__c.IndexOf('('), AssigneeObj.Apttus_Approval__AssigneeValue__c.lastIndexof(')')+1);							
		 where_clause = where_clause.replaceAll('__c\'','__c').replaceAll('\':PSR_Lead_Business_Group__c',':PSR_BG').replaceAll('\':PSR_Lead_Business_Unit__c',':PSR_BU').replaceAll('\':Lead_BG__c',':Lead_BG').replaceAll('\':Lead_BU__c',':Lead_BU').replaceAll('\':Org_L2__c',':l2').replaceAll('\':Org_L3__c',':l3').replaceAll('\':Org_L4__c', ':l4').replaceAll('\':Org_L5__c', ':l5').replaceAll('\':Org_L6__c', ':l6').replaceAll('\':Org_L7__c', ':l7');
		system.debug(where_Clause);
		
		String Query = 'Select Id,BG__c,User__c,User__r.name, Role_Code__c, Role_Name__C, Organisation__c from Sales_Role__c where '+where_Clause+' Limit 1';
		SRList = database.query(query);
		System.debug('----------->'+SRList);
		System.debug(query);
		if(!SRList.isEmpty()){
		for(Sales_Role__c Salesroleinfo:SRList){
		Stakeholderinfo1.add(Salesroleinfo.ID);
		FinalList.put(Salesroleinfo.ID,Salesroleinfo);
		StakeHolderIds.add(Salesroleinfo.User__c);
		RuleAssignee.put(Salesroleinfo.Role_code__c+Salesroleinfo.BG__c,AssigneeObj.Apttus_Approval__AssigneeValue__c);
		RuleAssigneeName.put(Salesroleinfo.Role_code__c+Salesroleinfo.BG__c,AssigneeObj.Name);
		AssigneedData.put(Salesroleinfo.Role_code__c+Salesroleinfo.BG__c,AssigneeObj.Apttus_Approval__AssigneeType__c);
		 if(RuleEntrySet.get(AssigneeObj.Apttus_Approval__RuleEntryId__c)<>NUll)
		 RuleName.put(Salesroleinfo.User__c,RuleEntrySet.get(AssigneeObj.Apttus_Approval__RuleEntryId__c));
		 }
		} 
	  }  
	}
	
  System.debug('--->Final List'+FinalList);
   System.debug('--->Final List size'+FinalList.size());
   System.debug('--->Final List'+Stakeholderinfo1);
   System.debug('--->Final List size'+Stakeholderinfo1.size());
		
	
	 
	 for(Apttus_Approval__Approval_Request__c Parentchildinsert:parentinfo.values())
	 {
	   for(Sales_Role__c StakeholderRec:FinalList.Values()) {
		   //modified fliter of if to add approval request for user has different bg role
	   //if(StakeholderRec.User__c<>NUll && String.IsEmpty(ValidatorID.get(StakeholderRec.User__c))) {
	   system.debug('StakeholderRec@@' + StakeholderRec);
		   if(StakeholderRec.User__c<>NUll && (String.IsEmpty(ValidatorID.get(StakeholderRec.User__c)) 
			  && !(map_uId_bgs.containsKey(StakeholderRec.User__c) && map_uId_bgs.get(StakeholderRec.User__c).contains(StakeholderRec.BG__c)))) {
			   Apttus_Approval__Approval_Request__c Stakeholderdata =new Apttus_Approval__Approval_Request__c();
		 
		  if(RuleName.get(StakeholderRec.User__c).Apttus_Approval__ApprovalRuleId__r.name<>Null)
		  Stakeholderdata.Apttus_Approval__Step_Name__c=RuleName.get(StakeholderRec.User__c).Apttus_Approval__ApprovalRuleId__r.name;
		  Stakeholderdata.Apttus_Approval__Object_Type__c=Parentchildinsert.Apttus_Approval__Object_Type__c;
		  Stakeholderdata.Apttus_Approval__Object_Name__c=Parentchildinsert.Apttus_Approval__Object_Name__c;
		  Stakeholderdata.Apttus_Approval__ProcessInstanceId__c=Parentchildinsert.Apttus_Approval__ProcessInstanceId__c;
		   
		   if(RuleName.get(StakeholderRec.User__c).Apttus_Approval__EntryLabel__c<>Null)
		  Stakeholderdata.Apttus_Approval__StepLabel__c=RuleName.get(StakeholderRec.User__c).Apttus_Approval__EntryLabel__c;
		  
		  if(AssigneedData.get(StakeholderRec.Role_code__c+StakeholderRec.BG__c)<>Null && AssigneedData.get(StakeholderRec.Role_code__c+StakeholderRec.BG__c).contains(GlobalConstants.USER))
		 Stakeholderdata.Apttus_Approval__Assigned_To_Type__c=GlobalConstants.USER;
		  
		  Stakeholderdata.Apttus_Approval__Related_Opportunity__c=Parentchildinsert.Apttus_Approval__Object_Id__c;
		  Stakeholderdata.Apttus_Approval__Object_Id__c=Parentchildinsert.Apttus_Approval__Object_Id__c;
		  Stakeholderdata.Apttus_Approval__ParentRequestId__c=Parentchildinsert.Apttus_Approval__ParentRequestId__c;
		  Stakeholderdata.Apttus_Approval__ProcessInstanceId__c= Parentchildinsert.Apttus_Approval__ProcessInstanceId__c;
			Stakeholderdata.NF_Assignee_Type__c=GlobalConstants.STAKEHOLDER_INFORMATION; 
			count=count+1;
			 Stakeholderdata.Apttus_Approval__Sequence__c=String.ValueOf(count+1);
			Stakeholderdata.Apttus_Approval__Assigned_To_Id__c=StakeholderRec.User__c;
			Stakeholderdata.Apttus_Approval__Assigned_To_Name__c=StakeholderRec.User__r.name;
			Stakeholderdata.Apttus_Approval__Send_Email__c=false;
			Stakeholderdata.Apttus_Approval__Date__c=System.now();
			Stakeholderdata.Apttus_Approval__DateAssigned__c=System.now();
			
			 Stakeholderdata.NF_Organization_Level__c = StakeholderRec.Organisation__c;
			  Stakeholderdata.NF_Role_Code__c = StakeholderRec.Role_Code__c;
			  Stakeholderdata.NF_Role_Name__c = StakeholderRec.Role_Name__c;  
			   Stakeholderdata.Related_Sales_Role__c = StakeholderRec.ID;
			   
			   if(RuleAssignee.get(StakeholderRec.Role_code__c+StakeholderRec.BG__c)<>NUll)
			   Stakeholderdata.NF_Assignee_Value__c=RuleAssignee.get(StakeholderRec.Role_code__c+StakeholderRec.BG__c);
			   if(RuleAssigneeName.get(StakeholderRec.Role_code__c+StakeholderRec.BG__c)<>NUll)
			   Stakeholderdata.Apttus_Approval__SubstepName__c=RuleAssigneeName.get(StakeholderRec.Role_code__c+StakeholderRec.BG__c);
			   Stakeholderdata.Apttus_Approval__Initial_Submitter__c=Parentchildinsert.Apttus_Approval__Initial_Submitter__c;
			Stakeholderinfo.add(Stakeholderdata);
			System.debug('Stakeholder Info:'+Stakeholderinfo);
		 }  
	   }
	 
	} 
	 
		 if(!Stakeholderinfo.isEmpty())
		 {
		  System.debug('Record--------'+Stakeholderinfo);
		   GlobalConstants.STAKE_HOLDER_FLAG=true;
			Database.insert(Stakeholderinfo);
		 
		 }
	 
	   System.debug('Record insert--------'+Stakeholderinfo);
	 
	 }
   }
  catch (Exception ex) 
	  {  
	  System.debug('Stakeholder Records Exception'+ex.getMessage());
	  ExceptionHandler.addException(ex, GlobalConstants.NF_TL_UPDATE_REQUESTRCODE, GlobalConstants.INSERT_STAKEHOLDER_REC);
		
		 } 
 
 
  
  } 

  
	/*****************************
	*Method Name: updateValidatorAndStakeholderStatus
	*Description: this method work for update the validators status to "Cancelled" after approver rejected.
	*Support Ticket:11885
	*Parameters: Approval Request List
	*******************************/
	public static void updateValidatorAndStakeholderStatus(List<Apttus_Approval__Approval_Request__c> appRequests, map<Id,Apttus_Approval__Approval_Request__c> MapOld){
		try{
		Set<Id> approverReqOpptyIds = new Set<Id>();

		for(Apttus_Approval__Approval_Request__c app : appRequests){
			if(app.NF_Assignee_Type__c == 'Approver'&& app.Apttus_Approval__Approval_Status__c == GlobalConstants.REJECTED && MapOld.get(app.id).Apttus_Approval__Approval_Status__c != GlobalConstants.REJECTED){
				approverReqOpptyIds.add(app.Apttus_Approval__Object_Id__c); 
			}
		}
		if(!approverReqOpptyIds.isEmpty()){
			//Set <Id> appRequestsIdSet = new Set <Id>();

			List<Apttus_Approval__Approval_Request__c> appRequestsList = [SELECT Id,Apttus_Approval__Object_Id__c, NF_Assignee_Type__c, Apttus_Approval__Approval_Status__c FROM Apttus_Approval__Approval_Request__c WHERE Apttus_Approval__Object_Id__c in :approverReqOpptyIds and (NF_Assignee_Type__c = 'Validator' OR NF_Assignee_Type__c ='Stakeholder for Information')];
			system.debug('appRequestsList>>>>>>'+appRequestsList.size()+appRequestsList);
			
			for(Apttus_Approval__Approval_Request__c currentAppRequests:appRequestsList){
				currentAppRequests.Apttus_Approval__Approval_Status__c = GlobalConstants.CANCEL;
			}
			
			if(appRequestsList.size()>0){
				update appRequestsList;
			}
		}
		}
		 catch(Exception ex){
			System.debug('updateValidatorAndStakeholderStatus Method Exception #####'+ex.getMessage());
			ExceptionHandler.addException(ex, GlobalConstants.NF_TL_UPDATE_REQUESTRCODE, 'updateValidatorAndStakeholderStatus');
		}
	}
 /*****************************
	*Method Name: updateDateApporovedFieldOnValidator
	*Description: this method work for update the validators's DateApproved to null after submit for approval. And change it to Approval time after approved
	*Support Ticket:12596
	*Parameters: Approval Request List
	*******************************/
		// Update DateApproved Field to Null when approval request is not valiated by validators
	public static void updateDateApporovedFieldOnValidator(List<Apttus_Approval__Approval_Request__c> appRequests){
		for(Apttus_Approval__Approval_Request__c apr:appRequests){
			System.debug('====>Status:'+apr.Apttus_Approval__Approval_Status__c+' Assignee:'+apr.NF_Assignee_Type__c +' Validator Status:'+ apr.Validator_Status__c +' Tech Status:'+apr.Tech_Status__c==null);
			if('Notified'.equalsignorecase(apr.Apttus_Approval__Approval_Status__c) && 'Validator'.equalsignorecase(apr.NF_Assignee_Type__c) && apr.Validator_Status__c==null && apr.Tech_Status__c==null){
				apr.Apttus_Approval__DateApproved__c = null;
			}
			if('Notified'.equalsignorecase(apr.Apttus_Approval__Approval_Status__c) && 'Validator'.equalsignorecase(apr.NF_Assignee_Type__c) &&  'Approved'.equalsignorecase(apr.Tech_Status__c)){
				apr.Apttus_Approval__DateApproved__c = Datetime.now();
			}
		}
	}
	
}