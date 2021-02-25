/**
* @Name	NF_ApprovalRequestHandler
* @Author  Najlae KHARBOUCH 
* @Since   Jan 30, 2017
* @Desc	This class  handles all trigger events on the Apttus_Approval__Approval_Request__c object.
* @History 
*/
 
public with sharing class NF_ApprovalRequestHandler extends NF_TriggerHandler {
	// Maps and list initialized from the Trigger context
	private Map<Id, Apttus_Approval__Approval_Request__c> oldMap;
	private List<Apttus_Approval__Approval_Request__c> oldList;
	private List<Apttus_Approval__Approval_Request__c> newList;
	
	/*
	* @desc	Constructor
	*/
	public NF_ApprovalRequestHandler() {
		this.oldMap = (Map<Id, Apttus_Approval__Approval_Request__c>) Trigger.oldMap;
		this.oldList = (List<Apttus_Approval__Approval_Request__c>) Trigger.old;
		this.newList = (List<Apttus_Approval__Approval_Request__c>) Trigger.new;	
	} 
	
	/*
	* @desc beforeUpdate handle the Value before update event
	*/
	public override void beforeUpdate(){
		List<Apttus_Approval__Approval_Request__c> lstApprovalRequest = new List<Apttus_Approval__Approval_Request__c>();
		List<Apttus_Approval__Approval_Request__c> lstAppReq = new List<Apttus_Approval__Approval_Request__c>(); 
		
		for(Integer i=0; i< newList.size() ; i++){
			if(newList[i].Apttus_Approval__DelegateApproverIds__c != null  && oldList[i].Apttus_Approval__DelegateApproverIds__c != newList[i].Apttus_Approval__DelegateApproverIds__c)
				lstApprovalRequest.add(newList[i]);
			 
			 
			if(newList[i].Apttus_Approval__Assigned_To_Id__c!= null   && newList[i].Approver_User__c <>newList[i].Apttus_Approval__Assigned_To_Id__c )
				lstAppReq.add(newList[i]);  
				
				
				
				
		}
		
		if(!lstApprovalRequest.isEmpty()){
			NF_ApprovalRequest.getDelegateApprovers(lstApprovalRequest);  
		}
		
		if(!lstAppReq.isEmpty()){
				NF_ApprovalRequest.getAssignedId(lstAppReq);  
			}
		 
		
	}
	
	
	
	 public override void afterInsert(){
	 List<Apttus_Approval__Approval_Request__c> Stakeholderinfo =new List<Apttus_Approval__Approval_Request__c>();
	 
	 for(Integer i=0; i< newList.size() ; i++){
	 if(newList[i].Apttus_Approval__Assigned_To_Name__c<>NUll)
		 {
			
			Stakeholderinfo.add(newList[i]);
		  }   
		}
	 
	 if(!GlobalConstants.STAKE_HOLDER_FLAG && !Stakeholderinfo.isEmpty())
	  {
	   NF_TL_UpdateRequestRCode.InsertStakeholderRec(Stakeholderinfo);
	   system.debug('---->'+newList);
	   }
	 
	 }
	
	 /*
	* @desc beforeInsert handle the Value before insert event
	*/
	public override void beforeInsert(){
		List<Apttus_Approval__Approval_Request__c> lstApprovalRequest = new List<Apttus_Approval__Approval_Request__c>();
		
		for(Integer i=0; i< newList.size() ; i++){
			if(newList[i].Apttus_Approval__DelegateApproverIds__c != null )
				lstApprovalRequest.add(newList[i]);
		}
		
		if(!lstApprovalRequest.isEmpty()){
			NF_ApprovalRequest.getDelegateApprovers(lstApprovalRequest);  
		}
	}
	
		 /*
	* @desc afterInsert handle the Value after update event
	*/
	public override void afterUpdate(){
			 system.debug('INSIDE AFTER UPDATE'); 
	
			 List<Apttus_Approval__Approval_Request__c> lstValidatorRequest = new List<Apttus_Approval__Approval_Request__c>();
			 List<Apttus_Approval__Approval_Request__c> lstApprovalRequest = new List<Apttus_Approval__Approval_Request__c>();
			 List<Apttus_Approval__Approval_Request__c> Delegatesharing= new List<Apttus_Approval__Approval_Request__c>();
			  List<Apttus_Approval__Approval_Request__c> Stakeholder= new List<Apttus_Approval__Approval_Request__c>();

			 Set<ID> Reminderid= new Set<ID>();
			 Set<ID> StakeholderID= new Set<ID>();
	 
	  
		for(Integer i=0; i< newList.size() ; i++){
			if(newList[i].Apttus_Approval__Approval_Status__c!=oldList[i].Apttus_Approval__Approval_Status__c && newList[i].Apttus_Approval__Approval_Status__c<>NULL   && ( newList[i].Apttus_Approval__Approval_Status__c.equals('Approved')))
				lstApprovalRequest.add(newList[i]);
			
			
			  if(!GlobalConstants.OPPORTUNITY_CHATTER_CHECK &&newList[i].Apttus_Approval__Step_Name__c<>Null &&newList[i].Apttus_Approval__Approval_Status__c!=oldList[i].Apttus_Approval__Approval_Status__c && newList[i].Apttus_Approval__Approval_Status__c<>NULL   && ( newList[i].Apttus_Approval__Approval_Status__c.equals('Approved')) &&  newList[i].Apttus_Approval__Step_Name__c.equalsignorecase(Label.G5_CT_Head_Check) && (newList[i].Oppty_LOA_Level__c<>Null && newList[i].Oppty_LOA_Level__c<>GlobalConstants.LOA_Level_A_Plus))
	 
			  Stakeholder.add(newList[i]);  
			
		 }
		 system.debug('List  lstApprovalRequest:' +lstApprovalRequest);
		
		
		for(Integer i=0; i< newList.size() ; i++){
			if(newList[i].Validator_Status__c!= oldList[i].Validator_Status__c &&newList[i].Validator_Status__c<>NULL   && ( newList[i].Validator_Status__c.equals('Validated') || newList[i].Validator_Status__c.equals('Rejected')))
				lstValidatorRequest.add(newList[i]);
		}
		system.debug('List lstValidatorRequest is:' +lstValidatorRequest);
		 
		 
			for(Integer i=0; i< newList.size() ; i++){
			if(newList[i].Apttus_Approval__DelegateApproverIds__c != null  && oldList[i].Apttus_Approval__DelegateApproverIds__c != newList[i].Apttus_Approval__DelegateApproverIds__c)
				Delegatesharing.add(newList[i]);
		}
		
		 for(Integer i=0; i< newList.size() ; i++){
		 StakeholderID.add(newList[i].id);
			if(newList[i].NF_Remaindercount__c!= null  && oldList[i].NF_Remaindercount__c!= newList[i].NF_Remaindercount__c && newList[i].NF_Remaindercount__c==0)
				Reminderid.add(newList[i].id);
		}
		 
		 
		 
			if(!Reminderid.isEmpty())
		   NF_ApprovalRequest.Remindupdate(Reminderid);
		 
		 //if(!StakeholderID.isEmpty())
		 //NF_ApprovalRequest.StakeHolderupdate(StakeholderID);
		
		if(!lstValidatorRequest.isEmpty()&&!GlobalConstants.Recursive_APPREq_CHECK){
			  system.debug('INSIDE VALIDATOR REQ' );
			  NF_ApprovalRequest.getNotificationUsersList(lstValidatorRequest);
			  SYSTEM.DEBUG('VALUE : '+lstValidatorRequest);
 
				//ITA_IFM_PAD.deactivateTrigger('NF_ApprovalRequestTrigger');
			
			 }
			 
			 if(!lstApprovalRequest.isEmpty())
			 NF_ApprovalRequest.getApproverNotification(lstApprovalRequest);
			 
			 
			 If(!Stakeholder.isEmpty())
			 NF_ApprovalRequest.ChatterPostToG5StakeHolders(Stakeholder);
				 
			 if(!Delegatesharing.isEmpty()){
			 NF_ApprovalRequest.Opptysharing(Delegatesharing);
			  ITA_IFM_PAD.deactivateTrigger('NF_ApprovalRequestTrigger');
			 }
	
	
			
   }
   
   
}