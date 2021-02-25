/**
* @name	NF_ApprovalRequest
* @author  Najlae Kharbouch
* @since   Jan 30, 2017
* @desc	This class is called by ApprovalRequestTrigger to 
* @history 
*/
public without sharing class NF_ApprovalRequest  {
   
 @TestVisible  Private Static  Integer TotalValidator;
  @TestVisible  Private Static  Integer ValidatorCompletion;
	@TestVisible  Private Static  String EmailTemplate;
	/*
* @desc get the Delegate Approvers Names based on Ids
* @param lstApprovalRequest: the Approval Request List
*/	
	public static void getDelegateApprovers (List<Apttus_Approval__Approval_Request__c> lstApprovalRequest){
		//get the Delegate Approvers Ids		
		Set<Id> delegateApproversIds = new Set<Id>();
		Integer Count=1;
		Map<Integer,ID> Delegatesinfo =new Map<Integer,ID>();
		for(Apttus_Approval__Approval_Request__c approvalRequest : lstApprovalRequest){
			approvalRequest.Delegate_Approvers__c ='';
			for(String delegateApproverId : approvalRequest.Apttus_Approval__DelegateApproverIds__c.split(','))
			{
	delegateApproversIds.add(delegateApproverId);
	Delegatesinfo.put(count+1,delegateApproverId);
	count++;
	
			}
		}
		System.debug('Delegate Info----'+Delegatesinfo);
		//get the Name of the Delegate Approvers
		Map<Id,User> mapDelegateIdNames = new Map<Id,User>([SELECT Id,Name 
						FROM User 
						WHERE Id 
						IN: delegateApproversIds
				 ]);
		
		//update the Delegate Approvers Names fields
		for(Apttus_Approval__Approval_Request__c approvalRequest : lstApprovalRequest){
			List<ID> list_Id = new List<ID>();
			for(String delegateApproverId : approvalRequest.Apttus_Approval__DelegateApproverIds__c.split(','))
			{
			//Req 2940
			if(approvalRequest.Delegate_Approvers__c =='' ){ 
			approvalRequest.Delegate_Approvers__c = String.ValueOf(mapDelegateIdNames.get(delegateApproverId).Name); }
			else{
			approvalRequest.Delegate_Approvers__c += ', '+String.ValueOf(mapDelegateIdNames.get(delegateApproverId).Name); }
	//approvalRequest.Delegate_Approvers__c += String.ValueOf(mapDelegateIdNames.get(delegateApproverId).Name)+', ';
			list_Id.add(delegateApproverId);
			}
			
			
			if (list_Id.size()>0 ) {
	 approvalRequest.Delegate_User1__c = list_Id.get(0);
			}
			if (list_Id.size()>1) {
	 approvalRequest.Delegate_User2__c = list_Id.get(1); 
			}
			if (list_Id.size()>2) {
	 approvalRequest.Delegate_User3__c = list_Id.get(2);
	 
			}
			
			
		}
	}
	
	
	
	
	 /*
	* @desc to collect Approval Assigned_To_Id 
	* @param lstAppReq: the Approval Request List
	*/ 
	public static void getAssignedId(List<Apttus_Approval__Approval_Request__c> lstAppReq)
	{
	  try
	  {		
		for(Apttus_Approval__Approval_Request__c approvalRequest : lstAppReq){
			if(String.isNotBlank(approvalRequest.Apttus_Approval__Assigned_To_Id__c) && approvalRequest.Apttus_Approval__Assigned_To_Type__c <>NUll && approvalRequest.Apttus_Approval__Assigned_To_Type__c.equalsignorecase('User')){
	approvalRequest.Approver_User__c = approvalRequest.Apttus_Approval__Assigned_To_Id__c;
			}
		}
	  }
	  catch(Exception E){
		 System.debug(' Approver User Update --->'+E.getMessage());	 
	  } 
	}   
	
	
	
   /*
* @desc to create opportunity team members for delegates approvers
* @param lstApprovalRequest: the Approval Request List
*/	
	public static void createOpportunityTeamMembers (List<Apttus_Approval__Approval_Request__c> lstApprovalRequest){
		 
		// Commneting the code because there is no concept of Opportunity team adding 
		/*
		
	 map<ID,Set<Id>>  mapOppIdMemberIds = new map<ID,Set<Id>>();
	 map<ID,Set<Id>>  mapOppIddelegateApproversIds = new map<ID,Set<Id>>();
	 map<ID,Set<ID>>  mapOppIdQueueIds = new map<ID,Set<Id>>();
	 set<ID> queueIds = new Set<ID>();
	 List<OpportunityTeamMember> opportunitiesTeamMembersToCreate = new List<OpportunityTeamMember>();
	
		//get the Delegate Approvers and approvers and stackholders for information and validation Ids map	 
	for(Apttus_Approval__Approval_Request__c approvalRequest : lstApprovalRequest){
			
			if (!mapOppIddelegateApproversIds.containsKey(approvalrequest.Apttus_Approval__Object_Id__c)){
	mapOppIddelegateApproversIds.put(approvalrequest.Apttus_Approval__Object_Id__c,new Set<ID>());
			}
			
	if (String.isNotBlank(approvalRequest.Apttus_Approval__Assigned_To_Id__c) && String.valueOf(approvalRequest.Apttus_Approval__Assigned_To_Id__c).startsWithIgnoreCase('00G')){
				if (!mapOppIdQueueIds.containsKey(approvalrequest.Apttus_Approval__Object_Id__c)){
		mapOppIdQueueIds.put(approvalrequest.Apttus_Approval__Object_Id__c,new Set<ID>());
		}
				mapOppIdQueueIds.get(approvalrequest.Apttus_Approval__Object_Id__c).add(approvalRequest.Apttus_Approval__Assigned_To_Id__c);
				queueIds.add(approvalRequest.Apttus_Approval__Assigned_To_Id__c);
				
			}
		 
				if(String.isNotBlank(approvalRequest.Apttus_Approval__Assigned_To_Id__c) && String.valueOf(approvalRequest.Apttus_Approval__Assigned_To_Id__c).startsWithIgnoreCase('005')){
		 mapOppIddelegateApproversIds.get(approvalrequest.Apttus_Approval__Object_Id__c).add(approvalRequest.Apttus_Approval__Assigned_To_Id__c);
				}
	 

	 
	 if(approvalRequest.Apttus_Approval__DelegateApproverIds__c != null){
	for(String delegateApproverId : approvalRequest.Apttus_Approval__DelegateApproverIds__c.split(','))
	{

		if(delegateApproverId != null && String.isNotBlank(delegateApproverId)){
		// trait the case where the approver delegate is a queue
			if (delegateApproverId.startsWithIgnoreCase('00g')){
				if (!mapOppIdQueueIds.containsKey(approvalrequest.Apttus_Approval__Object_Id__c)){
		mapOppIdQueueIds.put(approvalrequest.Apttus_Approval__Object_Id__c,new Set<ID>());
		}
				mapOppIdQueueIds.get(approvalrequest.Apttus_Approval__Object_Id__c).add(delegateApproverId);
				queueIds.add(delegateApproverId);
				
			}
		 
				if(delegateApproverId.startsWithIgnoreCase('005')){
		 mapOppIddelegateApproversIds.get(approvalrequest.Apttus_Approval__Object_Id__c).add(delegateApproverId);
				}
		}
	}

			} 
		}
		// Add delegate approvers that added as queue
		if (mapOppIdQueueIds != null && mapOppIdQueueIds.values().size()>0 ){
			map<ID,set<ID>> queueIdUserIds = new map<ID,set<ID>>();

			queueIdUserIds = getQueueMembersByQueue(queueIds) ;
	 for (ID oppId : mapOppIdQueueIds.keySet()){
	  for (ID queueId : mapOppIdQueueIds.get(oppId)){
	  
	   for (ID userId : queueIdUserIds.get(queueId)){
		
		  if (!mapOppIddelegateApproversIds.containsKey(oppId)){
		 mapOppIddelegateApproversIds.put(oppId,new Set<ID>());
		  }
		  mapOppIddelegateApproversIds.get(oppId).add(userId);
	 
	   }
	  }
	  
			
	 }
		}
		
		// Fill the map of opportunity and related users in opportunity team members
		 List<OpportunityTeamMember> opportunitiesTeamMembers = [SELECT UserId, OpportunityId, User.isActive
				 FROM OpportunityTeamMember
				 WHERE OpportunityId IN:mapOppIddelegateApproversIds.keySet()
				  ];
		for (OpportunityTeamMember oppTeamMember : opportunitiesTeamMembers){
			if(!mapOppIdMemberIds.containsKey(oppTeamMember.OpportunityId)){
	mapOppIdMemberIds.put(oppTeamMember.OpportunityId,new Set<ID>());
			}
			if(oppTeamMember.UserId != null && oppTeamMember.User.isActive){

	mapOppIdMemberIds.get(oppTeamMember.OpportunityId).add(oppTeamMember.UserId);
			}
		}

		for (Id oppId : mapOppIddelegateApproversIds.keySet()){

			set<ID> existingMemberIds = new set<ID>();
			existingMemberIds = mapOppIdMemberIds.get(oppId);

			for (Id delegateApproverId : mapOppIddelegateApproversIds.get(oppId) ){
	if (  delegateApproverId !=null && ((existingMemberIds != null && !existingMemberIds.contains(delegateApproverId))||existingMemberIds == null)){

		opportunitiesTeamMembersToCreate.add(new OpportunityTeamMember(
				UserId=delegateApproverId,OpportunityId=oppId,OpportunityAccessLevel='Read'));
	}
			}
		}
		if(!opportunitiesTeamMembersToCreate.isEmpty()){

			insert opportunitiesTeamMembersToCreate;
		}
		
		*/
	}
	
	 /*
	 * @desc this method return a map of queues and its related users
	 * param set of queue Ids
	 * return map of queue and its related users
	*/
	/*
	  //we have used the backend functionlity 
	public static map<ID,set<Id>> getQueueMembersByQueue(set<ID> queueIds){
		map<ID,set<Id>> queuememebersIds = new  map<ID,set<Id>>();
		
		for(GroupMember member : [Select GroupId,UserOrGroupId From GroupMember where GroupId in :queueIds]){
			if (String.valueOf(member.UserOrGroupId).startsWithIgnoreCase('005')) {
	if (!queuememebersIds.containsKey(member.GroupId)){
			queuememebersIds.put(member.GroupId,new Set<ID>());
	  }
	  queuememebersIds.get(member.GroupId).add(member.UserOrGroupId);
			}
		}
		return queuememebersIds;
	}
	
  */  
	
	/*
	 * @desc this method used to Sent validation request to all approvers and delegates
	 * param set of NotificationIds
	 *  Sent email
	 
	*/ 
	
	
	public static void getNotificationUsersList(List<Apttus_Approval__Approval_Request__c> lstNotificationRequest){
	
   Set<ID> Opptyid = New Set<ID>();
   map<ID,ID> Approvaldata =new map<ID,ID>();
	Map<ID,ID> ApprovalRecord =new Map<ID,ID>();
		GlobalConstants.Recursive_APPREq_CHECK=true; 
	  List<Messaging.SingleEmailMessage> ApproverMailSent = new List<Messaging.SingleEmailMessage>();


   
 
  
   
   for(Apttus_Approval__Approval_Request__c validatorinfo:lstNotificationRequest){
	Opptyid.add(validatorinfo.Apttus_Approval__Object_Id__c);
	}
	if(!test.isRunningTest())
	TotalValidator=[Select count() from Apttus_Approval__Approval_Request__c where  NF_Assignee_Type__c LIKE '%Validator%'  AND Apttus_Approval__Object_Id__c=:Opptyid Limit:Limits.getLimitQueryRows()];
	if(!test.isRunningTest())
	ValidatorCompletion=[Select count() from Apttus_Approval__Approval_Request__c where (Validator_Status__c='Validated' or Validator_Status__c='Rejected') AND NF_Assignee_Type__c LIKE '%Validator%' AND Apttus_Approval__Object_Id__c=:Opptyid Limit:Limits.getLimitQueryRows()] ;
	 System.debug('Loop TotalValidator'+TotalValidator);
	 System.debug('Loop ValidatorCompletion'+ValidatorCompletion);
	  
	if(TotalValidator==ValidatorCompletion)
	{
		 for(Opportunity OpportunityInfo:[select id,name,Phase_Status__c,PSR_Pre_Sales_Risk_Opportunity_Type__c,RecordType.id from Opportunity where id=:Opptyid LIMIT 1]){
		 
		 if(OpportunityInfo.Phase_Status__c<>NULL && OpportunityInfo.Phase_Status__c.equalsignorecase('Submitted for G3 Approval') )
	 EmailTemplate=Label.NF_G3_Validation_Completion_Email;
	 
	 else if( OpportunityInfo.Phase_Status__c<>NULL && (OpportunityInfo.Phase_Status__c.equalsignorecase('Submitted for G4 Approval')|| OpportunityInfo.Phase_Status__c.equalsignorecase('Submitted for G5 Approval')))
			EmailTemplate=Label.NF_ValidationCompleteEmail;

	/* else if(OpportunityInfo.PSR_Pre_Sales_Risk_Opportunity_Type__c<>NULL &&(OpportunityInfo.PSR_Pre_Sales_Risk_Opportunity_Type__c.equalsignorecase(System.Label.NF_Create_FOC_Trail_Record_Type)))
	 EmailTemplate=Label.NF_PSR_Validation_Completion_FoC;
	 else if(OpportunityInfo.PSR_Pre_Sales_Risk_Opportunity_Type__c<>NULL&&((OpportunityInfo.PSR_Pre_Sales_Risk_Opportunity_Type__c.equalsignorecase(System.Label.NF_Create_Trial_Record_Type)) || (OpportunityInfo.PSR_Pre_Sales_Risk_Opportunity_Type__c.equalsignorecase(System.Label.NF_Create_Demo_Record_Type)) ))
	 EmailTemplate=Label.NF_PSR_Validation_CompletionTrialDemo;
	else if(OpportunityInfo.PSR_Pre_Sales_Risk_Opportunity_Type__c<>NULL&&(OpportunityInfo.PSR_Pre_Sales_Risk_Opportunity_Type__c.equalsignorecase(System.Label.NF_Pre_Sales_Risk_Opportunity_Record_Type)))
	 EmailTemplate=Label.NF_PSR_Validation_Completion_RO; */
	
	
	 else if(OpportunityInfo.PSR_Pre_Sales_Risk_Opportunity_Type__c<>NULL &&((OpportunityInfo.PSR_Pre_Sales_Risk_Opportunity_Type__c.equalsignorecase(System.Label.NF_Create_FOC_Trail_Record_Type)) 
					   || ((OpportunityInfo.PSR_Pre_Sales_Risk_Opportunity_Type__c.equalsignorecase(System.Label.NF_Create_Trial_Record_Type)) || (OpportunityInfo.PSR_Pre_Sales_Risk_Opportunity_Type__c.equalsignorecase(System.Label.NF_Create_Demo_Record_Type))) 
					   || (OpportunityInfo.PSR_Pre_Sales_Risk_Opportunity_Type__c.equalsignorecase(System.Label.NF_Pre_Sales_Risk_Opportunity_Record_Type))))
	 {
	 EmailTemplate=Label.NF_PSR_Validation_Completion;
	  
	  System.debug('Loop EmailTemplate'+EmailTemplate);
	 
	 } 
		 }
		 } 
	  
	  try{	
	
	  if(EmailTemplate<>NULL){
		 for(Apttus_Approval__Approval_Request__c Appinfo:[Select id,Apttus_Approval__Assigned_To_Id__c,Apttus_Approval__DelegateApproverIds__c from Apttus_Approval__Approval_Request__c where Apttus_Approval__Object_Id__c=:Opptyid AND NF_Assignee_Type__c LIKE '%Approver%' AND (Apttus_Approval__Approval_Status__c LIKE '%Assigned%' OR  Apttus_Approval__Approval_Status__c LIKE '%Reassigned%' OR Apttus_Approval__Approval_Status__c LIKE '%Submitted%')])
	 {
	  Approvaldata.put(Appinfo.Apttus_Approval__Assigned_To_Id__c,Appinfo.id);
	
	 if (Appinfo.Apttus_Approval__DelegateApproverIds__c != null) {
			String[] delegateApproverIds = Appinfo.Apttus_Approval__DelegateApproverIds__c.split(',');
			for (string delegateapproverId: delegateApproverIds) {
	Approvaldata.put(delegateapproverId,Appinfo.ID);
			}
			
			}
			
		 }  
		 
		 System.debug('All Approver data ====+'+Approvaldata); 
	  
	for( EmailTemplate et:[SELECT id FROM EmailTemplate WHERE developerName =:EmailTemplate LIMIT 1]){
		 System.debug('Email All Approval Template====='+et);
			System.debug('All Approval record map id =========='+Approvaldata.Keyset());
		 for(ID ApproverInfo:Approvaldata.Keyset())
		{
	System.debug('Loop All Approval ID'+ApproverInfo);
	   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();


			mail.setWhatId(Approvaldata.get(ApproverInfo));
			System.debug('==========='+Approvaldata.get(ApproverInfo)+'====>'+ApproverInfo);
	mail.setTargetObjectId(ApproverInfo); // Specify who the email should be sent to.
			mail.setTemplateId(et.id);
			mail.setSaveAsActivity(false);
			ApproverMailSent.add(mail);
			
		 }
	  
	 
		 }
	 
	 
	}
	
		if(ApproverMailSent.size()>0){
	Messaging.SendEmailResult[] results=Messaging.sendEmail(ApproverMailSent);
	System.debug('Email Result'+results);
	}
	 
	 }
		
		
   catch(Exception E)
	 {
		 System.debug('Approval Notification completion'+E.getmessage());
	  }
 } 
	
	  
	  
	  
	  
	/*
	 * @desc this method sent the next approvers to remind the notification
	 * param set of NotificationIds
	 * Sent emails
	 
	*/ 
	
	
	public static void getApproverNotification(List<Apttus_Approval__Approval_Request__c> lstNotificationRequest){
	 
	  Set<ID> Opptyid = New Set<ID>();
   map<ID,ID> ApprovalRecord =new map<ID,ID>();
   List<Opportunity> OpportunityInfo=new  List<Opportunity>();
	Integer RemApprover;
	List<Messaging.SingleEmailMessage> MailSent = new List<Messaging.SingleEmailMessage>();

   
	 try{
   for(Apttus_Approval__Approval_Request__c validatorinfo:lstNotificationRequest){
	Opptyid.add(validatorinfo.Apttus_Approval__Object_Id__c);
	}
	
   
	  OpportunityInfo=[select id,name,RecordType.id from Opportunity where id=:Opptyid LIMIT 1];
	  
	if(!OpportunityInfo.IsEmpty() &&(OpportunityInfo.get(0).RecordType.id.equals(System.Label.NF_OpptyDirect) || OpportunityInfo.get(0).RecordType.id.equals(System.Label.NF_OpptyIndirect) ))
	
	RemApprover=[Select count()  from Apttus_Approval__Approval_Request__c where  NF_Assignee_Type__c LIKE '%Approver%' AND (Apttus_Approval__Approval_Status__c='Submitted' OR Apttus_Approval__Approval_Status__c='Assigned' OR Apttus_Approval__Approval_Status__c='Reassigned')AND Apttus_Approval__Object_Id__c=:Opptyid Limit:Limits.getLimitQueryRows()];
   
   System.debug('Loop RemApprover'+RemApprover);
	 if(RemApprover>0)
	 {
		 for(Apttus_Approval__Approval_Request__c Approvalrequestinfo :[Select id,Apttus_Approval__DelegateApproverIds__c,Apttus_Approval__Assigned_To_Id__c from Apttus_Approval__Approval_Request__c where NF_Assignee_Type__c LIKE '%Approver%' AND (Apttus_Approval__Approval_Status__c='Submitted' OR Apttus_Approval__Approval_Status__c='Assigned' OR Apttus_Approval__Approval_Status__c='Reassigned')AND Apttus_Approval__Object_Id__c=:Opptyid Limit:Limits.getLimitQueryRows()])
		 {
	ApprovalRecord.put(Approvalrequestinfo.Apttus_Approval__Assigned_To_Id__c,Approvalrequestinfo.id);
	
	if (Approvalrequestinfo.Apttus_Approval__DelegateApproverIds__c != null) {
			String[] delegateApproverIds = Approvalrequestinfo.Apttus_Approval__DelegateApproverIds__c.split(',');
			for (string delegateapproverId: delegateApproverIds) {
	ApprovalRecord.put(delegateapproverId,Approvalrequestinfo.ID);
			}
			
			}
	
	 } 
	 }
	 
	 System.debug('Next Approver data ====+'+ApprovalRecord); 

	 
	 if(ApprovalRecord.size()>0)
	 {
	 
	 
	 
	 for( EmailTemplate et:[SELECT id FROM EmailTemplate WHERE developerName =:Label.NF_ApprovalEmailTemplate LIMIT 1]){
			System.debug('Email Approval Template====='+et);
			System.debug('Approval record map id =========='+ApprovalRecord.Keyset());
		 for(ID ApproverInfo:ApprovalRecord.Keyset())
		{
	System.debug('Loop Approval ID'+ApproverInfo+'====>'+ApprovalRecord.get(ApproverInfo));
	   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();


			mail.setWhatId(ApprovalRecord.get(ApproverInfo));
	mail.setTargetObjectId(ApproverInfo); // Specify who the email should be sent to.
			mail.setTemplateId(et.id);
			mail.setSaveAsActivity(false);
			MailSent.add(mail);
			
		}
	 
	 
	 
	 
	 }
	 
	 }
	 
		if(MailSent.size()>0){
	Messaging.SendEmailResult[] results=Messaging.sendEmail(MailSent);
	System.debug('Email Result'+results);
	}
	 
	 
	 
	 
	 
	 
	 }
	 
 
  catch(Exception E)
	 {
	  System.debug('One Approval Completion'+E.getmessage());
	 }
	
	}
   
   
   
		
	/*
	 * @desc this method used to backend sharing of Oppty to delegates
	 * param Appoval request
	 * Opportunity Sharing to Delegates
	 
	*/  
	
	
	 public static void Opptysharing(List<Apttus_Approval__Approval_Request__c> appRequests){

	List<OpportunityShare> OpptyShares = new List<OpportunityShare>();
	Map<ID,ID> Delegateinfo=new Map<ID,ID>(); 

	try{
	for(Apttus_Approval__Approval_Request__c Approvalrequestinfo :appRequests)
	{
	
	  if (Approvalrequestinfo .Apttus_Approval__DelegateApproverIds__c != null) {
			String[] delegateApproverIds = Approvalrequestinfo.Apttus_Approval__DelegateApproverIds__c.split(',');
			for (string delegateapproverId: delegateApproverIds) {
	Delegateinfo.put(delegateapproverId,Approvalrequestinfo.Apttus_Approval__Object_Id__c);
			}
			
	}
	
	 } 
	 System.debug('Loop Delegate sharing User ===>'+Delegateinfo);
	 
	 
	 
	 for(ID Delegateid:Delegateinfo.keyset()){
	  OpportunityShare   oppshare = new OpportunityShare();
	  oppshare.OpportunityId=Delegateinfo.get(Delegateid); 
	  
	oppshare.UserOrGroupId =Delegateid;
	oppshare.OpportunityAccessLevel= 'edit';

	oppshare.RowCause=Schema.OpportunityShare.RowCause.Manual;
	
	
	OpptyShares.add(oppshare);
	
	
	}
	
   
	
	  if(!OpptyShares.isEmpty())
	  Database.insert(OpptyShares,false);
	  System.debug('Delegate Backend Sharing ====>'+OpptyShares);
	}
	catch(Exception e){
	system.debug('###Exception from NF_TL_UpdateRequestRCode : '+e.getMessage());
	
 
   }
   
   }
   
   
	 
	/*
	 * @desc this method Update the Remindercount to call recursive remainder emails
	 * param Appoval request
	 * Recursive reminder emails to delegates and approvers
	 
	*/  
	
 
   @Future
	public static void Remindupdate(Set<ID> appRequests){
	List<Apttus_Approval__Approval_Request__c> Remupdate= new  List<Apttus_Approval__Approval_Request__c>();
	try{
	
   
	for(Apttus_Approval__Approval_Request__c Appupdate:[Select id,NF_Recursive_Reminder__c,NF_Remaindercount__c,ApprovalDateTechField__c from Apttus_Approval__Approval_Request__c where id=:appRequests LIMIT:appRequests.size()  ]){
	if(Appupdate.NF_Remaindercount__c==0)
	{
	  Appupdate.NF_Remaindercount__c=1;
	  Appupdate.ApprovalDateTechField__c=Appupdate.NF_Recursive_Reminder__c;
	  Remupdate.add(Appupdate);
	}
	
	
	}
	
	if(Remupdate.size()>0)
	Database.Update(Remupdate,false);
	}
	Catch(Exception E)
	{
	  System.debug('Reminder Update Exception'+E.getMessage());
	}
	
	}
	
	
	
	
	/*****************************
*Method Name: ChatterPostToG5StakeHolders
*Description:  Chatter Post to All Stakeholders to Inform about the gate submissions
*Parameters: ApproverInfo
 
*******************************/
   
	
	public static void ChatterPostToG5StakeHolders(List<Apttus_Approval__Approval_Request__c > Approverinfo){
	 Map<ID,Set<ID>> mapStakeHolderId= new Map<ID,Set<ID>>();
	 Set<ID> StakeholderID =new Set<ID>();
	try{
	
	 //system.debug('@@@cHA');
	 Map<Id,Offer__c> Offerinfo = new Map<Id,Offer__c>();
	 Map<ID,Opportunity> Oppty=new Map<ID,Opportunity>();
	  List<Apttus_Approval__Approval_Request__c > Remupdate =new List<Apttus_Approval__Approval_Request__c>();
	 Set<ID> OpptyID =new Set<ID>();
	 String LOALevel;
	 String LoALevelbeforeSTA='';
	 String LeadBG='';
	 String LeadBU='';
	 String SupportingBG='';
	 String SupportingBUs='';
	 String OferDescription='';
	 String ApprovalScope='';
	 String Account='';
	 String Country='';
	 String wtd_Class='';
	  
	  for(Apttus_Approval__Approval_Request__c Rec:Approverinfo)
	  {
	if(Rec.Apttus_Approval__Object_Id__c<>Null)
		OpptyID.add(Rec.Apttus_Approval__Object_Id__c);
	  
	  }
	  
	  
	if(!OpptyID.isEmpty()) 
   {	
	 GlobalConstants.OPPORTUNITY_CHATTER_CHECK=True;
	 for(Offer__c Offerinf:[select id,name,Opportunity__c,Offer_Description__c,LoA_Level_Before_Trigger_Approval__c,Approval_Scope__c, WTD_Case__c from Offer__c where ActiveOffer__c=true and Opportunity__c=:OpptyID LIMIT: Limits.getLimitQueryRows() ])
	  {	  
	system.debug('NF_ApprovalRequest Avn:'+Offerinf.Approval_Scope__c);
	  if(Offerinf.Offer_Description__c<>Null)
	OferDescription=Offerinf.Offer_Description__c;
	  
	  if(Offerinf.Approval_Scope__c<>Null)
	  ApprovalScope=Offerinf.Approval_Scope__c;
	  
	  if(Offerinf.LoA_Level_Before_Trigger_Approval__c<>Null)
		LoALevelbeforeSTA=Offerinf.LoA_Level_Before_Trigger_Approval__c;

	  if(Offerinf.WTD_Case__c<>Null)
		wtd_Class=Offerinf.WTD_Case__c;
	  
	  }
	  
	  for(Opportunity opptyInfo:[Select id,name,Country__c,Account_Name__c,CurrencyIsoCode,Lead_BG__c,Lead_BU__c,
			 Supporting_BG_AA__c,Supporting_BG_FN__c,Supporting_BG_ION__c,Supporting_BG_MN__c,Supporting_BG_GS__c,
				 Supporting_BG_NEN__c,Supporting_BU_ION__c,Supporting_BUs_NEN__c,
				 LOA_Level__c,Amount,Opportunity_ID__c,Phase_Status__c,OwnerId
			 from Opportunity where id=:OpptyID])
		{
			Oppty.put(opptyInfo.id,opptyInfo);

	
		if(opptyInfo.Country__c<>Null)
		Country=opptyInfo.Country__c;
		
		if(opptyInfo.Account_Name__c<>Null)
		Account=opptyInfo.Account_Name__c;
		
	if(opptyInfo.Lead_BG__c<>Null)
	LeadBG=opptyInfo.Lead_BG__c;
	
	  if(opptyInfo.Lead_BU__c<>Null)
	  LeadBU=opptyInfo.Lead_BU__c;
	 
	 if(opptyInfo.Supporting_BG_AA__c<>Null)
	 SupportingBG=opptyInfo.Supporting_BG_AA__c;
	 
	 if(opptyInfo.Supporting_BG_AA__c<>Null&&opptyInfo.Supporting_BG_FN__c<>Null)
	 SupportingBG=SupportingBG+',';
	
	 if(opptyInfo.Supporting_BG_FN__c<>Null)
	  SupportingBG=SupportingBG+opptyInfo.Supporting_BG_FN__c;
	 
	 if(opptyInfo.Supporting_BG_ION__c<>Null&&(opptyInfo.Supporting_BG_AA__c<>Null || opptyInfo.Supporting_BG_FN__c<>Null))
	 SupportingBG= SupportingBG+',';
	 
	  if(opptyInfo.Supporting_BG_ION__c<>Null)
	  SupportingBG=SupportingBG+opptyInfo.Supporting_BG_ION__c;
	 
	 if(opptyInfo.Supporting_BG_MN__c<>Null &&(opptyInfo.Supporting_BG_AA__c<>Null || opptyInfo.Supporting_BG_FN__c<>Null || opptyInfo.Supporting_BG_ION__c<>Null ))
	  SupportingBG= SupportingBG+',';
	  
	if(opptyInfo.Supporting_BG_MN__c<>Null)
	SupportingBG=SupportingBG+opptyInfo.Supporting_BG_MN__c;
	  
	  
	  if(opptyInfo.Supporting_BG_GS__c<>Null && (opptyInfo.Supporting_BG_AA__c<>Null || opptyInfo.Supporting_BG_FN__c<>Null || opptyInfo.Supporting_BG_ION__c<>Null || opptyInfo.Supporting_BG_MN__c<>Null ))
	 SupportingBG= SupportingBG+',';
	 
		if(opptyInfo.Supporting_BG_GS__c<>Null)
	SupportingBG=SupportingBG+opptyInfo.Supporting_BG_GS__c;
	
	if(opptyInfo.Supporting_BG_NEN__c<>Null && (opptyInfo.Supporting_BG_AA__c<>Null || opptyInfo.Supporting_BG_FN__c<>Null || opptyInfo.Supporting_BG_ION__c<>Null || opptyInfo.Supporting_BG_MN__c<>Null ||opptyInfo.Supporting_BG_GS__c<>Null ))
	 SupportingBG= SupportingBG+',';
	
	if(opptyInfo.Supporting_BG_NEN__c<>Null)
	SupportingBG=SupportingBG+opptyInfo.Supporting_BG_NEN__c;
	
 if(opptyInfo.Supporting_BU_ION__c<>Null)
	SupportingBUs=opptyInfo.Supporting_BU_ION__c;
	
   
	  if(opptyInfo.Supporting_BU_ION__c<>Null&&opptyInfo.Supporting_BUs_NEN__c<>Null)
		SupportingBUs= SupportingBUs+',';
	
		 if(opptyInfo.Supporting_BUs_NEN__c<>Null)
	SupportingBUs=SupportingBUs+opptyInfo.Supporting_BUs_NEN__c;
		 
		 
	  if(SupportingBUs<>NUll && SupportingBUs.contains(';'))
	SupportingBUs=SupportingBUs.replaceAll(';',',');
	 
	 if(opptyInfo.LOA_Level__c<>Null)
	 LOALevel=opptyInfo.LOA_Level__c;
	  
	if (!mapStakeHolderId.containsKey(opptyInfo.ID)) {
	mapStakeHolderId.put(opptyInfo.ID, new Set<ID>());
	  }
	mapStakeHolderId.get(opptyInfo.ID).add(opptyInfo.OwnerID);
	  }
	 
	 System.debug('---> Oppty info'+Oppty);
	for(Apttus_Approval__Approval_Request__c Appupdate:[Select id,Apttus_Approval__Assigned_To_Type__c,Apttus_Approval__Notify_Only__c,Apttus_Approval__Object_Id__c,Apttus_Approval__DelegateApproverIds__c,Apttus_Approval__Assigned_To_Id__c,NF_Assignee_Type__c,Apttus_Approval__Approval_Status__c  from Apttus_Approval__Approval_Request__c where Apttus_Approval__Object_Id__c=:Oppty.KeySet() and NF_Assignee_Type__c<>Null  ])
	{
	System.debug('------Assignee type'+Appupdate.NF_Assignee_Type__c);
		 
	// Collecting the StakeHodler Records and updating the stakeholder status.
		if(Appupdate.NF_Assignee_Type__c.Contains(GlobalConstants.STAKEHOLDER_INFORMATION))
		{
		System.debug('------ Inside Loop Assignee type'+Appupdate.NF_Assignee_Type__c);
		 StakeholderID.add(Appupdate.id);
		 Remupdate.add(Appupdate);
		 
			if (!mapStakeHolderId.containsKey(Appupdate.Apttus_Approval__Object_Id__c)) {
	mapStakeHolderId.put(Appupdate.Apttus_Approval__Object_Id__c, new Set<ID>());
			}
			
			if(mapStakeHolderId.containsKey(Appupdate.Apttus_Approval__Object_Id__c))
			{
	if(Appupdate.Apttus_Approval__Assigned_To_Type__c<>Null && Appupdate.Apttus_Approval__Assigned_To_Type__c.contains(GlobalConstants.USER))
			mapStakeHolderId.get(Appupdate.Apttus_Approval__Object_Id__c).add(Appupdate.Apttus_Approval__Assigned_To_Id__c);

	if(Appupdate.Apttus_Approval__Assigned_To_Type__c<>Null && Appupdate.Apttus_Approval__Assigned_To_Type__c.contains(GlobalConstants.QUEUE))
	   {
		  for(ID QueueID:NF_OpportunityTriggerHelper.getQueueMembers(Appupdate.Apttus_Approval__Assigned_To_Id__c))
		  {
		if(QueueID<>NUll)
			mapStakeHolderId.get(Appupdate.Apttus_Approval__Object_Id__c).add(QueueID);

		  }

		}
			}
	
	 if (Appupdate.Apttus_Approval__DelegateApproverIds__c != null) {
	String[] delegateApproverIds = Appupdate.Apttus_Approval__DelegateApproverIds__c.split(',');
	for (string delegateapproverId: delegateApproverIds) {
	  if (!mapStakeHolderId.containsKey(Appupdate.Apttus_Approval__Object_Id__c)) {
	mapStakeHolderId.put(Appupdate.Apttus_Approval__Object_Id__c, new Set<ID>());
	  }
	if(mapStakeHolderId.containsKey(Appupdate.Apttus_Approval__Object_Id__c))
	  mapStakeHolderId.get(Appupdate.Apttus_Approval__Object_Id__c).add(delegateapproverId);
			}
	}
		} 
	  }
	
	System.debug('StakeHolder Update-->'+Remupdate);
	for (ID oppId: mapStakeHolderId.keySet()) {
			if (mapStakeHolderId.get(OppId) != null && !Oppty.isEmpty()) {
	integer NumberOfPost = (integer)((decimal) mapStakeHolderId.get(OppId).size() / 24).round(System.RoundingMode.UP);
	integer StartLoop = 0;
	for (integer i = 0; i<NumberOfPost; i++) {
		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
		
		ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
		ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
		
		messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
		list<Id>lstIds = new list<Id>(mapStakeHolderId.get(oppId));
		
		for (integer j = StartLoop; j<StartLoop + 24; j++) {
			if (lstIds.size()>j) {
				ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
				mentionSegmentInput.id = lstIds[j];
				messageBodyInput.messageSegments.add(mentionSegmentInput);
			}
		}
		StartLoop += 24;
			 String Gateinfo=''; 
			 String OfferData='';
		StartLoop += 24;
		 ConnectApi.MarkupBeginSegmentInput markupBeginSegmentBold;
		ConnectApi.MarkupEndSegmentInput markupEndSegmentBold;
		ConnectApi.MarkupBeginSegmentInput markupBeginSegmentSpace;
		ConnectApi.MarkupEndSegmentInput markupEndSegmentSpace;
		ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph;
		ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph;
 
	//Tag for Bold  
	 markupBeginSegmentBold = new ConnectApi.MarkupBeginSegmentInput();
	markupBeginSegmentBold.markupType = ConnectApi.MarkupType.Bold;
	 markupEndSegmentBold = new ConnectApi.MarkupEndSegmentInput();
	  markupEndSegmentBold.markupType = ConnectApi.MarkupType.Bold;
	 
		 //Tag for Next Line
		 markupBeginSegmentSpace = new ConnectApi.MarkupBeginSegmentInput();
				markupBeginSegmentSpace.markupType = ConnectApi.MarkupType.Paragraph;
				textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = '&nbsp;';
				markupEndSegmentSpace = new ConnectApi.MarkupEndSegmentInput();
				markupEndSegmentSpace.markupType = ConnectApi.MarkupType.Paragraph;
				
		
			 
			if(Oppty.get(oppId).Phase_Status__c<>Null && Oppty.get(oppId).Phase_Status__c.contains('G2') )
		Gateinfo='Gate 2 has been launched for approval.';
		 if(Oppty.get(oppId).Phase_Status__c<>Null && Oppty.get(oppId).Phase_Status__c.contains('G3') )
		Gateinfo='Gate 3 has been launched for approval.';
 
		if(Oppty.get(oppId).Phase_Status__c<>Null && Oppty.get(oppId).Phase_Status__c.contains('G4') )
		Gateinfo='Gate 4 has been launched for approval.';
		
			 //system.debug('@@@cha++>'+Oppty.get(oppId).Phase_Status__c);
		
		 if(Oppty.get(oppId).Phase_Status__c<>Null &&Oppty.get(oppId).Phase_Status__c.contains('G5'))
		Gateinfo='Gate 5 has been launched for approval.';
 
		if(Oppty.get(oppId).Phase_Status__c<>Null && Oppty.get(oppId).Phase_Status__c.contains('G6') )
		Gateinfo='Gate 6 has been launched for approval.';
 
		 
		 //first line of chatter info
		
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
			messageBodyInput.messageSegments.add(markupBeginSegmentBold);
			 textSegmentInput = new ConnectApi.TextSegmentInput();
			 textSegmentInput.text =Gateinfo;
				messageBodyInput.messageSegments.add(textSegmentInput);
				messageBodyInput.messageSegments.add(markupEndSegmentBold); 
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace);
		
		//new Paragraph
		 
				markupBeginSegmentParagraph = new ConnectApi.MarkupBeginSegmentInput();
				markupBeginSegmentParagraph.markupType = ConnectApi.MarkupType.Paragraph;
				messageBodyInput.messageSegments.add(markupBeginSegmentParagraph);
				textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = '&nbsp;';
				messageBodyInput.messageSegments.add(textSegmentInput);	
				markupEndSegmentParagraph = new ConnectApi.MarkupEndSegmentInput();
				markupEndSegmentParagraph.markupType = ConnectApi.MarkupType.Paragraph;
				messageBodyInput.messageSegments.add(markupEndSegmentParagraph);
	   
		
		
			// opportunity name
		
			 messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace);
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
			messageBodyInput.messageSegments.add(markupBeginSegmentBold);
			textSegmentInput = new ConnectApi.TextSegmentInput();

			 textSegmentInput.text ='Opportunity Name:'+GlobalConstants.SPACE;
				messageBodyInput.messageSegments.add(textSegmentInput);
				messageBodyInput.messageSegments.add(markupEndSegmentBold);
		 textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = GlobalConstants.SPACE+Oppty.get(oppId).Name;
				messageBodyInput.messageSegments.add(textSegmentInput);
				
				// Customer name
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
			messageBodyInput.messageSegments.add(markupBeginSegmentBold);
			textSegmentInput = new ConnectApi.TextSegmentInput();
			 textSegmentInput.text ='Customer:'+GlobalConstants.SPACE;
				messageBodyInput.messageSegments.add(textSegmentInput);
				messageBodyInput.messageSegments.add(markupEndSegmentBold);
		 textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text =GlobalConstants.SPACE+Account;
				messageBodyInput.messageSegments.add(textSegmentInput);
				
				// Country name
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
			messageBodyInput.messageSegments.add(markupBeginSegmentBold);
			textSegmentInput = new ConnectApi.TextSegmentInput();
			 textSegmentInput.text ='Country:'+GlobalConstants.SPACE;
				messageBodyInput.messageSegments.add(textSegmentInput);
				messageBodyInput.messageSegments.add(markupEndSegmentBold);
		 textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text =GlobalConstants.SPACE+Country;
				messageBodyInput.messageSegments.add(textSegmentInput);
				
				// Unweighted Amount
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
			messageBodyInput.messageSegments.add(markupBeginSegmentBold);
			textSegmentInput = new ConnectApi.TextSegmentInput();
			 textSegmentInput.text ='Unweighted amount:'+GlobalConstants.SPACE;
				messageBodyInput.messageSegments.add(textSegmentInput);
				messageBodyInput.messageSegments.add(markupEndSegmentBold);
		 textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = GlobalConstants.SPACE+Oppty.get(oppId).CurrencyIsoCode+''+Oppty.get(oppId).Amount;
				messageBodyInput.messageSegments.add(textSegmentInput);
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace);
		 messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace);
		 
		 
		 // New Paragraph
		 
			   
				markupBeginSegmentParagraph = new ConnectApi.MarkupBeginSegmentInput();
				markupBeginSegmentParagraph.markupType = ConnectApi.MarkupType.Paragraph;
				messageBodyInput.messageSegments.add(markupBeginSegmentParagraph);
				textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = '&nbsp;';
				messageBodyInput.messageSegments.add(textSegmentInput);	
				markupEndSegmentParagraph = new ConnectApi.MarkupEndSegmentInput();
				markupEndSegmentParagraph.markupType = ConnectApi.MarkupType.Paragraph;
				messageBodyInput.messageSegments.add(markupEndSegmentParagraph);
	   
				
				// Oppty ID
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
			messageBodyInput.messageSegments.add(markupBeginSegmentBold);
			textSegmentInput = new ConnectApi.TextSegmentInput();
			 textSegmentInput.text ='Opportunity Number:'+GlobalConstants.SPACE;
				messageBodyInput.messageSegments.add(textSegmentInput);
				messageBodyInput.messageSegments.add(markupEndSegmentBold);
		 textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = GlobalConstants.SPACE+Oppty.get(oppId).Opportunity_ID__c;
				messageBodyInput.messageSegments.add(textSegmentInput);
				
				
				// LOA Level
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
			messageBodyInput.messageSegments.add(markupBeginSegmentBold);
			textSegmentInput = new ConnectApi.TextSegmentInput();
			 textSegmentInput.text ='LoA Level:'+GlobalConstants.SPACE;
				messageBodyInput.messageSegments.add(textSegmentInput);
				messageBodyInput.messageSegments.add(markupEndSegmentBold);
		 textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = GlobalConstants.SPACE+LOALevel;
				messageBodyInput.messageSegments.add(textSegmentInput);
				
				// LoA Level before STA
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
			messageBodyInput.messageSegments.add(markupBeginSegmentBold);
			textSegmentInput = new ConnectApi.TextSegmentInput();
			 textSegmentInput.text ='LoA Level before STA:'+GlobalConstants.SPACE;
				messageBodyInput.messageSegments.add(textSegmentInput);
				messageBodyInput.messageSegments.add(markupEndSegmentBold);
		 textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = GlobalConstants.SPACE+LoALevelbeforeSTA;
				messageBodyInput.messageSegments.add(textSegmentInput);
				
				//Lead BG
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
			messageBodyInput.messageSegments.add(markupBeginSegmentBold);
			textSegmentInput = new ConnectApi.TextSegmentInput();
			 textSegmentInput.text ='Lead BG:'+GlobalConstants.SPACE;
				messageBodyInput.messageSegments.add(textSegmentInput);
				messageBodyInput.messageSegments.add(markupEndSegmentBold);
		 textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text =GlobalConstants.SPACE+ LeadBG;
				messageBodyInput.messageSegments.add(textSegmentInput);
				
				//Lead BU
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
			messageBodyInput.messageSegments.add(markupBeginSegmentBold);
			textSegmentInput = new ConnectApi.TextSegmentInput();
			 textSegmentInput.text ='Lead BU:'+GlobalConstants.SPACE;
				messageBodyInput.messageSegments.add(textSegmentInput);
				messageBodyInput.messageSegments.add(markupEndSegmentBold);
		 textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = GlobalConstants.SPACE+LeadBU;
				messageBodyInput.messageSegments.add(textSegmentInput);
				
				//Supporting BGs
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
			messageBodyInput.messageSegments.add(markupBeginSegmentBold);
			textSegmentInput = new ConnectApi.TextSegmentInput();
			 textSegmentInput.text ='Supporting BGs:'+GlobalConstants.SPACE;
				messageBodyInput.messageSegments.add(textSegmentInput);
				messageBodyInput.messageSegments.add(markupEndSegmentBold);
		 textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = GlobalConstants.SPACE+SupportingBG;
				messageBodyInput.messageSegments.add(textSegmentInput);
				
				
				//Supporting BUs
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
	messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
	 messageBodyInput.messageSegments.add(markupBeginSegmentBold);
	 textSegmentInput = new ConnectApi.TextSegmentInput();
			textSegmentInput.text ='Supporting BUs:'+GlobalConstants.SPACE;
	messageBodyInput.messageSegments.add(textSegmentInput);
	messageBodyInput.messageSegments.add(markupEndSegmentBold);
	 textSegmentInput = new ConnectApi.TextSegmentInput();
	textSegmentInput.text = GlobalConstants.SPACE+SupportingBUs;
	messageBodyInput.messageSegments.add(textSegmentInput);

	 //WTD Case
	 messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
	 messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
	 messageBodyInput.messageSegments.add(markupBeginSegmentBold);
	 textSegmentInput = new ConnectApi.TextSegmentInput();
	 textSegmentInput.text ='WTD Case:'+GlobalConstants.SPACE;
	 messageBodyInput.messageSegments.add(textSegmentInput);
	 messageBodyInput.messageSegments.add(markupEndSegmentBold);
	 textSegmentInput = new ConnectApi.TextSegmentInput();
	 textSegmentInput.text = GlobalConstants.SPACE;
	 messageBodyInput.messageSegments.add(textSegmentInput);
	 ConnectApi.LinkSegmentinput linksegment = new ConnectApi.LinkSegmentinput();
	 if(wtd_Class != ''){
	linksegment.url = wtd_Class;
	messageBodyInput.messageSegments.add(linksegment);
	 }
	 
	 messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
	 messageBodyInput.messageSegments.add(markupEndSegmentSpace);
	 messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
	 messageBodyInput.messageSegments.add(markupEndSegmentSpace);
		
		//New Paragraph
			   
				markupBeginSegmentParagraph = new ConnectApi.MarkupBeginSegmentInput();
				markupBeginSegmentParagraph.markupType = ConnectApi.MarkupType.Paragraph;
				messageBodyInput.messageSegments.add(markupBeginSegmentParagraph);
				textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = '&nbsp;';
				messageBodyInput.messageSegments.add(textSegmentInput);	
				markupEndSegmentParagraph = new ConnectApi.MarkupEndSegmentInput();
				markupEndSegmentParagraph.markupType = ConnectApi.MarkupType.Paragraph;
				messageBodyInput.messageSegments.add(markupEndSegmentParagraph);
	   
				
		 //Offer Description
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
			messageBodyInput.messageSegments.add(markupBeginSegmentBold);
			textSegmentInput = new ConnectApi.TextSegmentInput();
			 textSegmentInput.text ='Offer Description:'+GlobalConstants.SPACE;
				messageBodyInput.messageSegments.add(textSegmentInput);
				messageBodyInput.messageSegments.add(markupEndSegmentBold);
		 textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = GlobalConstants.SPACE+OferDescription;
				messageBodyInput.messageSegments.add(textSegmentInput);
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace);
		 
		 
		 
		 //New Paragraph
			   
				markupBeginSegmentParagraph = new ConnectApi.MarkupBeginSegmentInput();
				markupBeginSegmentParagraph.markupType = ConnectApi.MarkupType.Paragraph;
				messageBodyInput.messageSegments.add(markupBeginSegmentParagraph);
				textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = '&nbsp;';
				messageBodyInput.messageSegments.add(textSegmentInput);	
				markupEndSegmentParagraph = new ConnectApi.MarkupEndSegmentInput();
				markupEndSegmentParagraph.markupType = ConnectApi.MarkupType.Paragraph;
				messageBodyInput.messageSegments.add(markupEndSegmentParagraph);
	   
	   
	   // Approval Scope
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace); 
			messageBodyInput.messageSegments.add(markupBeginSegmentBold);
			textSegmentInput = new ConnectApi.TextSegmentInput();
			 textSegmentInput.text ='Approval Scope:'+GlobalConstants.SPACE;
				messageBodyInput.messageSegments.add(textSegmentInput);
				messageBodyInput.messageSegments.add(markupEndSegmentBold);
		 textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = GlobalConstants.SPACE+ApprovalScope;
				messageBodyInput.messageSegments.add(textSegmentInput);
		messageBodyInput.messageSegments.add(markupBeginSegmentSpace);
		messageBodyInput.messageSegments.add(markupEndSegmentSpace);
		 
	   
	   
		 
		 /*
		String Messageinfo;
 
		
			 Messageinfo = '\n\n'+Gateinfo+'\n\n'+'Opportunity Name:'+Oppty.get(oppId).Name+'\n'+'Customer:'+Account+'\n'+'Country:'+Country+'\n'+'Unweighted amount:'+Oppty.get(oppId).CurrencyIsoCode+''+Oppty.get(oppId).Amount+'\n'+'Opportunity Number:'+Oppty.get(oppId).Opportunity_ID__c+'\n';
		OfferData= '\n'+'LoA Level:'+LOALevel+'\n'+'LoA Level before STA:'+LoALevelbeforeSTA+'\n'+'Lead BG:'+LeadBG +'\n'+'Lead BU:'+LeadBU+'\n'+'Supporting BGs:'+ SupportingBG+'\n'+'Supporting BUs:'+SupportingBUs+'\n\n'+'Offer Description:'+'\n'+OferDescription+'\n'+'Approval Scope:'+ ApprovalScope;		 
		textSegmentInput.text=Messageinfo+OfferData;
			  
		messageBodyInput.messageSegments.add(textSegmentInput);
	 */ 
		
		feedItemInput.body = messageBodyInput;
		feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
		feedItemInput.subjectId = oppId;
		if (!test.isRunningTest()) {
		  ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
		}
		
		
	}
			}
		}
	
	
	}
	//method to update the stakeholder notification information
	 StakeHolderupdate(StakeholderID);
   
	 }
	 
	
	
	Catch(Exception ex)
	{
	 ExceptionHandler.addException(ex, GlobalConstants.NF_APPROVALREQUEST, GlobalConstants.CHATTER_POST_TO_STAKEHOLDER);
	System.debug('$$$$$$$$$$'+ex.getMessage());
	}
	
}
	
	
	
	
	  /*
* @desc Update the Stakehodler Status after G5 Step1 Approve
* @param  ID  Stakeholderid's
*/  
	
   
   @Future
	public static void StakeHolderupdate(Set<ID> appRequests){
	List<Apttus_Approval__Approval_Request__c> Remupdate= new  List<Apttus_Approval__Approval_Request__c>();
	try{
	System.debug('IDs--->'+appRequests);
	
	for(Apttus_Approval__Approval_Request__c Appupdate:[Select id,NF_Assignee_Type__c,Apttus_Approval__Approval_Status__c  from Apttus_Approval__Approval_Request__c where ID=:appRequests and NF_Assignee_Type__c<>Null   LIMIT:appRequests.size()  ])
	{
	
	
		if(Appupdate.NF_Assignee_Type__c.equalsignorecase(GlobalConstants.STAKEHOLDER_INFORMATION))
		{
		Appupdate.Apttus_Approval__Approval_Status__c =GlobalConstants.NOTIFIED;
		Appupdate.Apttus_Approval__Notify_Only__c=True;
		 Remupdate.add(Appupdate);
		} 
	}
		
	
	if(!Remupdate.isEmpty())
	Database.Update(Remupdate,false);
	
	}
	Catch(Exception E)
	{
	System.debug(' Stakeholder Update Eception--->'+E.getMessage());
	}
	 
	
 }
 
 
 }