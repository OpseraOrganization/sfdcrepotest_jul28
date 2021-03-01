/*************************************************************
@Name: APTSCU_PreviewApprovalsController
@Author:  Jigar Naik
@CreateDate: 21 Feb 2016
@Description: Controller class for custom approvals pages.
******************************************************************/
public class APTSCU_PreviewApprovalsController{

	public String sObjectType {get; set;}
	public ID sObjectId {get; set;}
	public String sObjectFieldSetJSON {get; set;}
	public String sObjectDataJSON {get; set;}
	public String previewApprovalsJSON{get;set;}
	public String approvalHeaderInformation{get;set;}
	public String approvalColumnsFieldSetJSON {get; set;}
	public String approvalReqWrapperListJSON {get;set;}
	public String submittionComments {get;set;}
	public Boolean onlyPreview {get;set;}
	public Boolean isCancelled {get;set;}
	private Set<String> approvalFieldSet = null;
	public String reasonsRequired{get;set;}
	@TestVisible private String currentApprovalStatus = null;
	Public static Map<String,Apttus_Approval__Approval_Process__c> ApprovalsStepMap = new Map<String,Apttus_Approval__Approval_Process__c>();
	Public static Map<String,List<Apttus_Approval__Approval_Process__c>> ApprovalsEntryMap = new Map<String,List<Apttus_Approval__Approval_Process__c>>();
	
	public string PSRLoAlevel ;
	public boolean isDisplay; 
	public boolean isAmountGreater;
	public String firstReason{get;set;}
	public String secondReason{get;set;}
	public boolean isDisplayProbability; 
	public Integer probabilityPercentage{get;set;}
	
	public Opportunity optyObj{get;set;}
	public Opportunity optyObjRecord{get;set;}
	
	public String Previewmessage{get;set;}
	 public Boolean ispreviewmessage {get;set;}
	public Boolean loaupdated {get;set;}
	public static boolean flagForUpsellOppty = true;
	 
	public APTSCU_PreviewApprovalsController() {
	   
		sObjectId = ApexPages.currentPage().getParameters().get('sObjectId');
		
		// Code added By Mehul Parmar - Start
		sObjectType st=sObjectId.getSObjectType();  
		sObjectType=String.valueOf(st);
		PSRLoAlevel =	ApexPages.currentPage().getParameters().get('PSRLoAlevel');
		
		currentApprovalStatus = '';
		approvalFieldSet = new Set<String>();
		onlyPreview = false;
		isCancelled = false;
		ispreviewmessage=false;
		loAupdated = false;
		// Code added By Mehul Parmar - End
		 
	}
	
	public void previewApprovals(){
		queryApprovalHeaderInformation();
		queryApprovalColumnsFieldSet();
		try{ 

			if(currentApprovalStatus == 'Approval Required' || currentApprovalStatus == 'Not Submitted'){
				Apttus_Approval.ApprovalsWebService.previewApprovals(sObjectType,sObjectId);
			}else if(currentApprovalStatus == 'Pending Approval'){
				onlyPreview = true;
			}else if(currentApprovalStatus == 'Cancelled'){
				onlyPreview = true;
				isCancelled = true;
			}else{
				previewApprovalsJSON = JSON.serialize('No approval Records available');
				approvalReqWrapperListJSON = JSON.serialize('No approval Records available');
				return;
			}
			List<approvalRequestWrapperClass> approvalReqWrapperList = new List<approvalRequestWrapperClass>();
			
			String soqlQuery = getAllFieldsSOQL('Apttus_Approval__Approval_Request__c','Apttus_Approval__Object_Id__c = :sObjectId And Apttus_Approval__Object_Type__c = :sObjectType AND Apttus_Approval__Assigned_To_Id__c!= null order by Name');
			System.debug('soqlQuery :'+soqlQuery);
			List<Apttus_Approval__Approval_Request__c> approvalRequestList = (List<Apttus_Approval__Approval_Request__c>)Database.query(soqlQuery);
			System.debug('approvalRequestList'+approvalRequestList);
			approvalRequestWrapperClass  approvalReqWrapper;
			List<string> approvalReqData;
			
			System.debug('#### approvalRequestList Size'+approvalRequestList.size() );
			
			for(Apttus_Approval__Approval_Request__c approveReq :approvalRequestList ) {
				submittionComments = approveReq.Apttus_Approval__SubmissionComment1__c;
				approvalReqData = new List<string>();
				IF(approveReq.Apttus_Approval__Approval_Process__c<>null && approveReq.Apttus_Approval__Step_Name__c<>NUll )
				approvalReqData = saveApprovalDisplayInformation(approveReq.Apttus_Approval__Approval_Process__c, approveReq.Apttus_Approval__Step_Name__c);
			   System.debug('Approval Submittion Data ======>'+approvalReqData);
				if(approvalReqData.size()>0 ) {
					approvalReqWrapper = new approvalRequestWrapperClass (approveReq,approvalReqData[0],approvalReqData[1]);
				} else {
					approvalReqWrapper = new approvalRequestWrapperClass (approveReq,null,null);
				}
				
				approvalReqWrapperList.add(approvalReqWrapper);
			}	
			
			System.debug('-->approvalReqWrapperList'+approvalReqWrapperList.get(0));
			previewApprovalsJSON=JSON.serialize(approvalRequestList);
			
			 approvalReqWrapperListJSON = JSON.serialize(SortRecords(approvalReqWrapperList));
		   
		}catch(Exception exp){
		system.debug('############# Message' + exp.getMessage());
			previewApprovalsJSON=  JSON.serialize(exp.getMessage());
			approvalReqWrapperListJSON = JSON.serialize('No approval Records available');
		}
	}
	
	 
   
	@RemoteAction
	 public static String submitForApprovals(String sObjectType,String sObjectId,String comments){
	   System.debug('Commnets ---->'+comments);
		Opportunity opptyinfo;
		 Savepoint sp = null;
		try{
		   sp = Database.setSavepoint();
			Id directRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.DIRECT_OPPTY).getRecordTypeId();
			Id inDirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.INDIRECT_OPPTY).getRecordTypeId();
		   // Updating the Submission Comments and used in G2 Completion Template
			 for(Opportunity Oppty:[Select Id,RecordTypeId,Name,No_Offer_Support__c,NF_Facilitator_Notified__c,ApprovalStatusTechField__c,Submission_Comments__c,Phase_Status__c,Sales_Outcome__c,Apttus_Approval__Approval_Status__c,StageName from Opportunity where id=:sObjectId])
			  {
			  opptyinfo=Oppty;
					
			  }  
			 
			 // SDC modification and added the bypass condition 

			system.debug('presales submit debug'+sObjectType);
			system.debug('presales submit debug'+sObjectId);
			if(opptyinfo<>NUll && opptyinfo.RecordTypeId<>Null && opptyinfo.No_Offer_Support__c<>Null &&(opptyinfo.No_Offer_Support__c<>1 && opptyinfo.No_Offer_Support__c<>3) && (opptyinfo.RecordTypeId.equals(directRecordTypeId) || opptyinfo.RecordTypeId.equals(inDirectRecordTypeId)) && opptyinfo.NF_Facilitator_Notified__c == FALSE && (opptyinfo.Phase_Status__c.equalsignorecase(GlobalConstants.OPPORTUNITY_IN_PROGRESS)||opptyinfo.Phase_Status__c.equalsignorecase(GlobalConstants.SUBMITTED_FOR_G2_APPROVAL)) ){
				System.debug('====> enter bypass');
				return Label.NF_OnlyFacilitatorCanSubmit;
			}else{ 
				Apttus_Approval.ApprovalsWebService.submitForApprovals(sObjectType, sObjectId);
				 updatePhaseStatus(sObjectId,comments);
				return 'Success';
			}
			 
			 
			 
		}catch(Exception exp){
		
		
		  if(sp != null) Database.rollback(sp);
		  
 
		 String error='Test'+exp.getLineNumber()+exp.getMessage()+exp.getstackTraceString()+exp.getTypeName();

		Return error;
			
		 
			 
			   
		}
	}
	
	@RemoteAction
	public static String addComments(String sObjectType,String sObjectId,String comments){
		try{
			String soqlQuery = 'Select id,Name,Apttus_Approval__SubmissionComment1__c from Apttus_Approval__Approval_Request__c where Apttus_Approval__Object_Id__c = :sObjectId And Apttus_Approval__Object_Type__c = :sObjectType AND Apttus_Approval__Assigned_To_Id__c!= null order by Name';
			
			List<Apttus_Approval__Approval_Request__c> approvalRequestList = (List<Apttus_Approval__Approval_Request__c>)Database.query(soqlQuery);
			System.debug('approvalRequestList'+approvalRequestList);
			for(Apttus_Approval__Approval_Request__c apprvalReq : approvalRequestList ) {
				apprvalReq.Apttus_Approval__SubmissionComment1__c = comments;
			}
			update approvalRequestList;
			return 'success'; 
		}catch(Exception exp){
			return exp.getMessage();
		}
	}
   
	@RemoteAction
	public static String cancelApprovals(String sObjectType,String sObjectId, String Comments){
		Savepoint sp = null;
		try{
			List<Apttus_Approval__Approval_Request__c> Remupdate= new  List<Apttus_Approval__Approval_Request__c>();

			  
			  List<Opportunity> OpptyUpdate=new List<Opportunity>();
			   sp = Database.setSavepoint();
			  for(Opportunity Oppty:[Select id,name,Approval_Cancel_Info__c,Is_Automated__c from Opportunity Where id=:sObjectId Limit 1])
			  {
				 Oppty.Approval_Cancel_Info__c =Comments;
				 Oppty.Is_Automated__c=True;
				 update Oppty;
				
			  }
		 //update the Stakeholders Status	 
	  for(Apttus_Approval__Approval_Request__c Appupdate:[Select id,Apttus_Approval__Notify_Only__c,Apttus_Approval__Object_Id__c,Apttus_Approval__DelegateApproverIds__c,Apttus_Approval__Assigned_To_Id__c,NF_Assignee_Type__c,Apttus_Approval__Approval_Status__c  from Apttus_Approval__Approval_Request__c where Apttus_Approval__Object_Id__c=:sObjectId and NF_Assignee_Type__c<>Null  ])
	   {
	   
		 
	   // Collecting the StakeHodler Records and updating the stakeholder status.
		if(Appupdate.NF_Assignee_Type__c<>Null&&(Appupdate.NF_Assignee_Type__c.Contains(GlobalConstants.VALIDATOR)||Appupdate.NF_Assignee_Type__c.Contains(GlobalConstants.STAKEHOLDER_INFORMATION)))
		{
			System.debug('### Inside Loop Assignee type'+Appupdate.NF_Assignee_Type__c);
			Appupdate.Apttus_Approval__Approval_Status__c =GlobalConstants.CANCEL;
			  Remupdate.add(Appupdate);
			 
		 }
		 
		 }
		 
		 
		 if(!Remupdate.isEmpty())
		 List<Database.saveResult> srs= Database.update(Remupdate,False); 
			
			Apttus_Approval.ApprovalsWebService.cancelApprovals(sObjectType, sObjectId);

			return 'success'; 
		}catch(Exception exp){
		System.debug('Calcel exp'+exp);
		  if(sp != null) Database.rollback(sp);
			return exp.getMessage();
			
		}
	}
	
	public void queryApprovalHeaderInformation(){
		List<Schema.FieldSetMember> fields = Schema.getGlobalDescribe().get(sObjectType).getDescribe().fieldSets.getMap().get('APTSCU_Approval_Header_Fields').getFields(); 
		
		Map<String,String> fldVsLabelMap = new Map<String,String>();
		for(Schema.FieldSetMember fld : fields){
			fldVsLabelMap.put(fld.getFieldPath(),fld.getLabel());
		}
		
		String soqlQuery = getAllFieldsSOQL(sObjectType,'Id = :sObjectId');
		SObject sObjectData = Database.query(soqlQuery);
		
		for(String approvalField : approvalFieldSet){
			if(sObjectData.get(approvalField) != null && sObjectData.get(approvalField) != ''){
				currentApprovalStatus = (String)sObjectData.get(approvalField);
			}
		}
		
		sObjectFieldSetJSON = JSON.serialize(fldVsLabelMap);
		sObjectDataJSON = JSON.serialize(sObjectData);
	}
	
	public void queryApprovalColumnsFieldSet(){
		List<Schema.FieldSetMember> fields = Schema.getGlobalDescribe().get('Apttus_Approval__Approval_Request__c').getDescribe().fieldSets.getMap().get('APTSCU_Preview_Approval_Columns').getFields(); 
		
		Map<String,String> fldVsLabelMap = new Map<String,String>();
		for(Schema.FieldSetMember fld : fields){
		System.debug('--->fld.getLabel()'+fld.getFieldPath()+fld.getLabel());
			fldVsLabelMap.put(fld.getFieldPath(),fld.getLabel());
		}
		
		approvalColumnsFieldSetJSON = JSON.serialize(fldVsLabelMap);
	}

	private String getAllFieldsSOQL(String objectName, String whereClause){
		 
		String selects = '';
		 
		if (whereClause == null || whereClause == ''){ return null; }
		 
		// Get a map of field name and field token
		Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
		list<string> selectFields = new list<string>();
		 
		if (fMap != null){
			for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
				Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
				selectFields.add(fd.getName());
				
				if(fd.getName().containsIgnoreCase('Approval_Status__c')){
					approvalFieldSet.add(fd.getName());
				}
			}
		}
		 
		if (!selectFields.isEmpty()){
			for (string s:selectFields){
				selects += s + ',';
			}
			if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
			 
		}
		 
		return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
		 
	}


	public List<string> saveApprovalDisplayInformation(Id processId,string currentStepName){
	
	System.debug('processId currentStepName'+currentStepName+processId);
	Apttus_Approval__Approval_Process__c approvalStep;
	 List<Apttus_Approval__Approval_Process__c> entryCriteriaList = new List<Apttus_Approval__Approval_Process__c>();
	 
	 // compare the data to approvalStep Map stop the SOQL execution into next time
		if(ApprovalsStepMap.get(currentStepName)<>Null)
		  approvalStep=ApprovalsStepMap.get(currentStepName);
			else
		   approvalStep = [Select Id, Apttus_Approval__StepDisplayFieldNameHeader__c, Apttus_Approval__StepDisplayFieldNames__c From Apttus_Approval__Approval_Process__c Where Apttus_Approval__Step__r.Apttus_Approval__Step_Group__c = :processId And Apttus_Approval__Step_Name__c = :currentStepName];
		
		// storing the data into map to reduce the SOQL execution
		if(approvalStep<>NUll)
		ApprovalsStepMap.put(currentStepName,approvalStep);
		
		 
		 
		 
		 // compare the data to ApprovalsEntryMap stop the SOQL execution into next time
		   if(ApprovalsEntryMap.get(currentStepName)<>NUll)
			  entryCriteriaList=ApprovalsEntryMap.get(currentStepName);
				else
			   entryCriteriaList = [Select Id, Apttus_Approval__Step_Filter_Field__c, Apttus_Approval__Step_Filter_Comparison_Type__c, Apttus_Approval__Step_Filter_Field_Value__c, Apttus_Approval__Step_Filter_BoolOper__c From Apttus_Approval__Approval_Process__c Where Apttus_Approval__Step_Filter__r.Apttus_Approval__Step__r.Apttus_Approval__Step_Group__c = :processId And Apttus_Approval__Step_Filter__r.Apttus_Approval__Step_Name__c = :currentStepName];
	   
	   
	  // storing the data into map to reduce the SOQL execution 
	   if(entryCriteriaList<>NUll)
	   ApprovalsEntryMap.put(currentStepName,entryCriteriaList);
		
		Set<String> displayFields = new Set<String>();
		if(approvalStep.Apttus_Approval__StepDisplayFieldNameHeader__c != '' && approvalStep.Apttus_Approval__StepDisplayFieldNameHeader__c != null){
			displayFields.add(approvalStep.Apttus_Approval__StepDisplayFieldNameHeader__c.toLowerCase());
		}
		
		if(approvalStep.Apttus_Approval__StepDisplayFieldNames__c != '' && approvalStep.Apttus_Approval__StepDisplayFieldNames__c != null){
			String[] displayFieldsArray = approvalStep.Apttus_Approval__StepDisplayFieldNames__c.split(',');
			
			for(String displayField : displayFieldsArray){
				displayFields.add(displayField.toLowerCase());
			}
		}
		
		if(displayFields.isEmpty()){
			displayFields.add('name');
		}
		
		Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(sObjectType).getDescribe().fields.getMap(); 
		
		Map<String,String> fldVsLabelMap = new Map<String,String>();
		Map<String,String> fldVsLabelMapAll = new Map<String,String>();
		for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
			Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
			if(displayFields.contains(fd.getName().toLowerCase())){
				fldVsLabelMap.put(fd.getName(), fd.getLabel());
			}
			fldVsLabelMapAll.put(fd.getName(), fd.getLabel());
		}
		String stepEntryCriteria;
		for(Integer index = 0; index < entryCriteriaList.size(); index++){
			Apttus_Approval__Approval_Process__c entryCriteria = entryCriteriaList[index];
			stepEntryCriteria = '(' + fldVsLabelMapAll.get(entryCriteria.Apttus_Approval__Step_Filter_Field__c) + getOperator(entryCriteria.Apttus_Approval__Step_Filter_Comparison_Type__c) + entryCriteria.Apttus_Approval__Step_Filter_Field_Value__c + ')';
			if(index < entryCriteriaList.size() - 1){
				stepEntryCriteria += ' ' + entryCriteria.Apttus_Approval__Step_Filter_BoolOper__c + ' ';
			}
		}
		
		List<string> approvalStepData = new List<string>();
		approvalStepData.add(stepEntryCriteria);
		approvalStepData.add(JSON.serialize(fldVsLabelMap));
		return approvalStepData;
	}
	
	 
	@TestVisible
	private String getOperator(String compareOperator){
		if (compareOperator == 'equal to') {
			return ' = ';
		} else if (compareOperator == 'not equal to') {
			return ' != ';
		} else if (compareOperator == 'less than') {
			return ' < ';
		} else if (compareOperator == 'greater than') {
			return ' > ';
		} else if (compareOperator == 'less than or equal to') {
			return ' <= ';
		} else if (compareOperator == 'greater than or equal to') {
			return ' >= ';
		} else if(compareOperator =='starts with' || compareOperator =='contains' ) {   
			return ' LIKE ';	
		} else if(compareOperator =='in') {
			return ' IN ';	 
		} else if(compareOperator =='not in') {		
			return ' NOT IN ';	 
		}
		
		return '';
	}
   public class approvalRequestWrapperClass {
		public Apttus_Approval__Approval_Request__c approvalReq{get; set;}
		public String stepEntryCriteria{get; set;}		
		public String sObjectDisplayFieldsJSON {get; set;}
		public boolean showHeaderInfo;
		public approvalRequestWrapperClass (Apttus_Approval__Approval_Request__c appreq, string stepCriteria, string fieldjson){
		  approvalReq = appreq;

		  stepEntryCriteria = stepCriteria;
		  sObjectDisplayFieldsJSON = fieldjson;
		  showHeaderInfo = false;
		}
	} 
  /****************************************
	*Method Name: getDisplaySalesoutcomReason()
	*Description:  These method used for rerendering of page
	*Parameters:
	*Req No:2382
	*****************************************/	   
	  public boolean getDisplaySalesoutcomReason(){
		   Id opptyDirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.DIRECT_OPPTY).getRecordTypeId();
		   Id opptyIndirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.INDIRECT_OPPTY).getRecordTypeId();
		   isDisplay=false;
		   String label_Amount = System.Label.Unweighted_Amount_For_Sales_Outcome; 
		   List<String> loaBypassList=System.label.LoA_Bypass_Offer_Condition.Split(GlobalConstants.COMMA);
		   set<String> loaBypassSet = new set<String>();
		   loaBypassSet.addAll(loaBypassList);
		   loaBypassSet.remove(GlobalConstants.BLANK_VALUE);
		  system.debug('loaBypassSet'+loaBypassSet);
		  
	   try{
			Opportunity oppty = [Select id,Name,Description,Phase_Status__c,Third_Reason__c,
								 Sales_Outcome_Reason__c,Second_Reason__c,LOA_Level__c,StageName,RecordTypeId,
								 Amount,count_offer__c,NF_LoA_Bypass__c,No_Offer_Support__c,Apttus_Approval__Approval_Status__c
								 from Opportunity where id = :sObjectId];			
			
		  
		   Showwarningmessage(oppty);
		   
		   System.debug('*****oppty*****'+oppty);
			if((oppty.Phase_Status__c == GlobalConstants.PENDING_WIN_LOSS_DECLARATION ||oppty.LOA_Level__c=='E' ||(oppty.NF_LoA_Bypass__c>0 && oppty.No_Offer_Support__c<2) ) && 
			   oppty.StageName==GlobalConstants.WIN_THE_CASE_OPPORTUNITY_STAGE &&
			   (oppty.RecordTypeId==opptyDirectRecordTypeId || oppty.RecordTypeId==opptyIndirectRecordTypeId) &&
			   oppty.Amount >= Decimal.valueOf(label_Amount)){  
				   
				   Offer__c offerRec = [Select id, ActiveOffer__c, Opportunity__c, LOA_Bypass__c from Offer__c 
								 where Opportunity__c =:sObjectId  AND ActiveOffer__c = True LIMIT: 1];
				   
					if(oppty.count_offer__c > 0 && offerRec!= Null && (!loaBypassSet.contains(offerRec.LOA_Bypass__c))){
						isDisplay=true;
						optyObjRecord=oppty;
					}else if(oppty.count_offer__c == 0)
					{
						isDisplay=true;
						optyObjRecord=oppty;
					}
			   }
			 return isDisplay;
			
		}catch(Exception ex){
			ExceptionHandler.addException(ex,GlobalConstants.PRVIEW_APPROVAL_CONTROLLER,GlobalConstants.DISPLAY_SALES_OUTCOMEREASON);
			return false;
		}
	}
	

	@RemoteAction   
  /****************************************
	*Method Name: updateOpportunityReasons
	*Description: Update the sales outcome reason
	*Parameters: String sObjectType,String sObjectId,String firstReason ,String secondReason,String thirdReason
	*Req No:2382
	*****************************************/		
	public static String updateOpportunityReasons(String sObjectType,String sObjectId,String firstReason ,String secondReason,String thirdReason){
				
				System.debug('-------->firstReason '+firstReason );
				System.debug('-------->secondReason'+secondReason);
				System.debug('-------->thirdReason'+thirdReason);
		try{
		
			String soqlQuery = 'Select id,Name,Description from Opportunity where id = :sObjectId';
			
			List<Opportunity> oppList = (List<Opportunity>)Database.query(soqlQuery);
			System.debug('oppList'+oppList);
			
			if(oppList!=null){
					for(Opportunity oppObj : oppList ) {
						
						
						   if(firstReason != GlobalConstants.NONE && String.isNotBlank(firstReason) && !firstReason.contains(GlobalConstants.Remove_Unwanted_Value)){
							   oppObj.Sales_Outcome_Reason__c =firstReason;
						   }
						   
						   if(secondReason != GlobalConstants.NONE && String.isNotBlank(secondReason) && !secondReason.contains(GlobalConstants.Remove_Unwanted_Value)){
							   oppObj.Second_Reason__c=secondReason;
						   }
						   
						   if(thirdReason != GlobalConstants.NONE && String.isNotBlank(thirdReason) && !thirdReason.contains(GlobalConstants.Remove_Unwanted_Value)){
							   oppObj.Third_Reason__c=thirdReason;
						   }
						oppObj.Sales_Outcome__c = GlobalConstants.WON_REQUESTED;
			
					}
						update oppList;
					
		  }  
			
		  
		   return GlobalConstants.RETURN_SUCCESS; 
		  
		}catch(Exception exp){
			 
			 ExceptionHandler.addException(exp,GlobalConstants.PRVIEW_APPROVAL_CONTROLLER,GlobalConstants.UPDATE_SALES_OUTCOME_REASON);
			 return exp.getMessage();
		}
	}		  
	
	
   /****************************************
	*Method Name: getDisplayProbability
	*Description:These method used for rerendering of page for displaying probability for G2 and G3
	*Parameters:2382
	*****************************************/	  
	  public boolean getDisplayProbability(){
	
		   Id opptyDirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.DIRECT_OPPTY).getRecordTypeId();
		   Id opptyIndirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.INDIRECT_OPPTY).getRecordTypeId();
		   isDisplayProbability=false; 
		  
	   try{
			Opportunity oppty = [Select id,Name,Description,No_Offer_Support__c,Probability,Unweighted_Amount_EUR__c,Phase_Status__c,StageName,RecordTypeId from Opportunity where id = :sObjectId];
			System.debug('*****oppty*****'+oppty);
			
			optyObj = oppty;
		
			
			if(((oppty.StageName==GlobalConstants.IDENTIFY_OPPORTUNITY && oppty.Phase_Status__c==GlobalConstants.PLANNED) || (oppty.StageName==GlobalConstants.DEVELOP_OPPORTUNITY  && oppty.Phase_Status__c==GlobalConstants.OPPORTUNITY_IN_PROGRESS &&(oppty.No_Offer_Support__c==1 || oppty.No_Offer_Support__c==3) ))&&(oppty.RecordTypeId==opptyDirectRecordTypeId || oppty.RecordTypeId==opptyIndirectRecordTypeId)){
				isDisplayProbability=true;
			}
			
			 
			 return isDisplayProbability;
			
		}catch(Exception ex){
			
			ExceptionHandler.addException(ex,GlobalConstants.PRVIEW_APPROVAL_CONTROLLER,GlobalConstants.GET_DISPLAY_PROBABILITY);
			return false;
		}
	}
	/****************************************
	*Method Name: getProbability
	*Description: These method used displaying probability percentage for G2 and G3
	*Parameters:
	*Req No:
	*****************************************/   
   
	  public Double getProbability(){
		 try{
			Opportunity oppty = [Select id,Name,Description,Probability,Phase_Status__c,StageName,RecordTypeId from Opportunity where id = :sObjectId];   
		   
			 
			 System.debug('oppty ---->'+oppty);
			 return oppty.Probability;
									 

			
		}catch(Exception ex){
			ExceptionHandler.addException(ex,GlobalConstants.PRVIEW_APPROVAL_CONTROLLER,GlobalConstants.GET_PROBABILITY);
			return 0.0;
		}
	}
	
	
	  @RemoteAction
   /****************************************
	*Method Name: updateProbabilityPercentage
	*Description: update probability percentage
	*Parameters: String sObjectType,String sObjectId,String probabilityPer
	*Req No:2382
	*****************************************/	
  public static String updateProbabilityPercentage(String sObjectType,String sObjectId,String probabilityPer){
	   
	   try{
		
			String soqlQuery = 'Select id,Name,Description,Probability,Calculating_Probability__c from Opportunity where id = :sObjectId';
			
			List<Opportunity> oppList = (List<Opportunity>)Database.query(soqlQuery);
			System.debug('oppList'+oppList);
			
			if(oppList!=null){
					for(Opportunity oppObj : oppList ) {
					
						System.debug('probabilityPer--->'+probabilityPer);
						oppObj.Calculating_Probability__c= integer.valueof(probabilityPer);
						oppObj.Probability = integer.valueof(probabilityPer);
						 System.debug('oppObj.Probability--->'+oppObj.Probability);
					}
						update oppList;
						
						System.debug('oppList--->'+oppList);
		  }  
	   
			return GlobalConstants.RETURN_SUCCESS;  
		  
		}catch(Exception exp){
			
			ExceptionHandler.addException(exp,GlobalConstants.PRVIEW_APPROVAL_CONTROLLER,GlobalConstants.UPDATE_PROBABILITY_PER);
			return exp.getMessage();
		}
	}
	
	
	
	
	
	
	  @RemoteAction
   /****************************************
	*Method Name: SubmissionCommentsUpdate
	*Description: update probability percentage
	*Parameters: String sObjectType,String sObjectId,String probabilityPer
	*Req No:2382
	*****************************************/	
  public static String SubmissionCommentsUpdate(String sObjectId,String Comments){
	   
	   
		
	   Savepoint sp = null;
		   try{
		   sp = Database.setSavepoint();
		   List<Opportunity> OpptyUpdate =new List<Opportunity>();
			
			  for(Opportunity Oppty:[Select Id,Is_Automated__c,ApprovalStatusTechField__c,Submission_Comments__c,Phase_Status__c,Sales_Outcome__c,Apttus_Approval__Approval_Status__c,StageName from Opportunity where id=:sObjectId])
			  {
				   if(Comments<>NUll)
				   Oppty.Submission_Comments__c=Comments;
				   else
				   Oppty.Submission_Comments__c='';
				   Oppty.Is_Automated__c=True;
				   Database.update(Oppty,false); 
				   
					
				 
				  
			  }
			  return 'success';
		   }   
		  catch(Exception e)
		  {
			 if(sp != null) Database.rollback(sp);
			 system.debug('Exception On updatePhaseStatus>>>>'+e.getMessage());
			 
			 return e.getMessage();
		  }
			 
	  }
 
   
	
	
	
	 @Future
		 public Static Void updatePhaseStatus(String sObjectId,String Comments){
		  Savepoint sp = null;
		   Try{
		  set<id> parentOppIdSet = new set<id>();
			   parentOppIdSet.add(sObjectId);
		   List<Opportunity> OpptyUpdate =new List<Opportunity>();
			  // string strOfferLevel = [select id,LoA_Approval_Level__c,ActiveOffer__c FROM Offer__c WHERE ActiveOffer__c =: TRUE AND Opportunity__c =:sObjectId LIMIT 1].LoA_Approval_Level__c;
			  List<Offer__c> relOffer = [select id,LoA_Approval_Level__c,ActiveOffer__c FROM Offer__c WHERE ActiveOffer__c =: TRUE AND Opportunity__c =:sObjectId LIMIT 1];
			   for(Opportunity Oppty:[Select Id,ApprovalStatusTechField__c,Submission_Comments__c,LOA_Level__c,Phase_Status__c,NF_LoA_Bypass__c,No_Offer_Support__c,Sales_Outcome__c,Apttus_Approval__Approval_Status__c,StageName from Opportunity where id=:sObjectId])
			  {
				  /*system.debug('Oppty.StageName-->'+Oppty.StageName);
				   system.debug('Oppty.Phase_Status__c-->'+Oppty.Phase_Status__c);
				   system.debug('Oppty.LOA_Level__c-->'+Oppty.LOA_Level__c);
				   system.debug('Oppty.Apttus_Approval__Approval_Status__c-->'+Oppty.Apttus_Approval__Approval_Status__c);
				  system.debug('Oppty.NF_LoA_Bypass__c-->'+Oppty.NF_LoA_Bypass__c);
				  system.debug('Oppty.No_Offer_Support__c-->'+Oppty.No_Offer_Support__c);
				  */
				 if(Oppty<>Null && Oppty.Phase_Status__c<>NUll && Oppty.StageName <>NUll  && Oppty.StageName.equalsignorecase(GlobalConstants.WIN_THE_CASE_NEGOTIATE) && ((Oppty.Phase_Status__c.equalsignorecase(GlobalConstants.PENDING_WIN_LOSS_DECLARATION) && Oppty.Apttus_Approval__Approval_Status__c<>NUll&& Oppty.Apttus_Approval__Approval_Status__c.equalsignorecase(GlobalConstants.PENDING_APPROVAL))|| (Oppty.LOA_Level__c<>Null&&Oppty.LOA_Level__c=='E') ||(Oppty.Apttus_Approval__Approval_Status__c<>NUll&& !Oppty.Phase_Status__c.equalsignorecase(GlobalConstants.PENDING_WIN_LOSS_DECLARATION  ) && Oppty.Apttus_Approval__Approval_Status__c.equalsignorecase(GlobalConstants.PENDING_APPROVAL) && Oppty.NF_LoA_Bypass__c>0 && Oppty.No_Offer_Support__c<2 ))   )
				 {
				   Oppty.Phase_Status__c=GlobalConstants.PTA_HANDOVER;
				   Oppty.StageName=GlobalConstants.HANDOVER_OPPTY;
				   Oppty.Apttus_Approval__Approval_Status__c=GlobalConstants.APPROVED;
				   Oppty.ApprovalStatusTechField__c=GlobalConstants.G5_APPROVAL_TECH;
				   Oppty.Sales_Outcome__c=GlobalConstants.WON;
				   if(Comments<>Null)
				   Oppty.Submission_Comments__c=Comments;
				   OpptyUpdate.add(Oppty);
				 
				 }
				 
				 
			  }
			  sp = Database.setSavepoint();
			  // this is only for G5 Pending Winloss Update to Next phase
			 if(!OpptyUpdate.isEmpty())
			 Database.update(OpptyUpdate,false);  
			  
			  // CreateUpsellOppty updateJob = new CreateUpsellOppty(parentOppIdSet);if(flagForUpsellOppty)
			   if(flagForUpsellOppty)
				{
			 /* 
			  * Commented for 00197712 
			  if(strOfferLevel != '' && strOfferLevel =='E')
			  {
				UpsellOppUtility.toCreateUpsellOpportunity(parentOppIdSet);  
			  }*/
					
					system.debug('Logs1:  LOA LEVEL'+ relOffer[0].LoA_Approval_Level__c + ' Stage Name: '+ OpptyUpdate[0].StageName );
			  if(relOffer<>Null &&  relOffer.size()>0 && OpptyUpdate<>Null && relOffer[0].LoA_Approval_Level__c != '' && relOffer[0].LoA_Approval_Level__c =='E' && OpptyUpdate[0].StageName.equalsignorecase(GlobalConstants.HANDOVER_OPPTY))
			  { system.debug('Logs2:  LOA LEVEL'+ relOffer[0].LoA_Approval_Level__c + ' Stage Name: '+ OpptyUpdate[0].StageName );
				UpsellOppUtility.toCreateUpsellOpportunity(parentOppIdSet);  
			  }	 
					flagForUpsellOppty = false;   
				}
			 
			 
			 
			 
			 List<Apttus_Approval__Approval_Request__c> Approval_SH= new List<Apttus_Approval__Approval_Request__c>();
			  
	  //update the Stakeholders Status to notify
	  for(Apttus_Approval__Approval_Request__c Appupdate:[Select id,Apttus_Approval__Related_Opportunity__r.Phase_Status__c,Apttus_Approval__Notify_Only__c,Apttus_Approval__Object_Id__c,Apttus_Approval__DelegateApproverIds__c,Apttus_Approval__Assigned_To_Id__c,NF_Assignee_Type__c,Apttus_Approval__Approval_Status__c  from Apttus_Approval__Approval_Request__c where Apttus_Approval__Object_Id__c=:sObjectId and NF_Assignee_Type__c<>Null  ])
	   {
	   
		 
	   // Collecting the StakeHodler Records and updating the stakeholder status.
		if(Appupdate.NF_Assignee_Type__c<>Null&& Appupdate.Apttus_Approval__Related_Opportunity__r.Phase_Status__c<>NUll && (Appupdate.Apttus_Approval__Related_Opportunity__r.Phase_Status__c.equalsignorecase(GlobalConstants.SUBMITTED_FOR_G3_APPROVAL) || Appupdate.Apttus_Approval__Related_Opportunity__r.Phase_Status__c.equalsignorecase(GlobalConstants.SUBMITTED_FOR_G4_APPROVAL) )&& Appupdate.Apttus_Approval__Approval_Status__c.equalsignorecase(GlobalConstants.STATUS_NOT_SUBMITTED) && Appupdate.NF_Assignee_Type__c.Contains(GlobalConstants.STAKEHOLDER_INFORMATION))
		{
			System.debug('### Inside SH Recorde'+Appupdate.NF_Assignee_Type__c);
			Appupdate.Apttus_Approval__Approval_Status__c =GlobalConstants.NOTIFIED;
			  Approval_SH.add(Appupdate);
			 
		 }
		 
		 }

		  if(Approval_SH.size()>0)
		  Database.update(Approval_SH,false);
		  
			 
		  }   
		  catch(Exception e)
		  {
			 if(sp != null) Database.rollback(sp);
			 system.debug('Exception On updatePhaseStatus>>>>'+e.getMessage());
		  }			 
   }
   
	/****************************************
*Method Name: getUnweightedAmount()
*Description:  These method used for getting Unweighted Amount
*Parameters:
*Req No: SF00007566
*****************************************/	   
	public boolean getUnweightedAmount(){
		Id opptyDirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.DIRECT_OPPTY).getRecordTypeId();
		Id opptyIndirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.INDIRECT_OPPTY).getRecordTypeId();
		String label_Amount = System.Label.Unweighted_Amount_For_Sales_Outcome;		
		isAmountGreater=false; 
		reasonsRequired = System.Label.Three_Reasons_Required;		
		
		try{
			Opportunity oppty = [Select 
								 id,RecordTypeId,
								 Amount  
								 from Opportunity 
								 where id = :sObjectId   
								 LIMIT 1 ];
			
			System.debug('*****oppty*****'+oppty);
			System.debug('label_Amount'+label_Amount);
			if(oppty.Amount >= Decimal.valueOf(label_Amount) && 
			   (oppty.RecordTypeId == opptyDirectRecordTypeId || oppty.RecordTypeId == opptyIndirectRecordTypeId)){
				isAmountGreater=true;
			}
			system.debug('isAmountGreater'+isAmountGreater);
			return isAmountGreater;
			
		}catch(Exception ex){
			ExceptionHandler.addException(ex,GlobalConstants.PRVIEW_APPROVAL_CONTROLLER,GlobalConstants.Get_Unweighted_Amount);
			return false;
		}
	}	  
 
 
 public void Showwarningmessage(Opportunity opp){
	  try{
		   Previewmessage=JSON.serialize('Please wait until your request is completely processed. Do not close the page or interrupt the approval submission.');
		   ispreviewmessage=false;
		  if(opp.StageName.equalsignorecase(GlobalConstants.WIN_THE_CASE_NEGOTIATE )&&opp.LOA_Level__c=='E') ispreviewmessage=true;
		  // Previewmessage=JSON.serialize('G5 (LOA) Level E approval: Please be informed that proceeding with the opportunity submission will trigger BOTH the contract signature approval, as well as the win declaration.');
		  if(opp.StageName.equalsignorecase(GlobalConstants.WIN_THE_CASE_NEGOTIATE ) && !opp.Phase_Status__c.equalsignorecase(GlobalConstants.PENDING_WIN_LOSS_DECLARATION  ) && opp.NF_LoA_Bypass__c>0 && opp.No_Offer_Support__c<2 )ispreviewmessage=true;
			  // Previewmessage=JSON.serialize('G5 (LoA) Bypass: Please be informed that proceeding with the opportunity submission will trigger the win declaration.');
		  if(opp.StageName.equalsignorecase(GlobalConstants.WIN_THE_CASE_NEGOTIATE ) && opp.Phase_Status__c.equalsignorecase(GlobalConstants.PENDING_WIN_LOSS_DECLARATION  )  )ispreviewmessage=true;
						
			if(PSRLoAlevel != null && PSRLoAlevel != '')
			{
			loaupdated = true;
			Previewmessage=JSON.serialize('LoA level is set to - '+PSRLoAlevel+ '. Please review the gate participants before submitting for approval');
			} 
		  
	  }catch(Exception ex){
			ExceptionHandler.addException(ex,GlobalConstants.PRVIEW_APPROVAL_CONTROLLER,GlobalConstants.Get_Unweighted_Amount);
		}
}
 
 
 
 
 /****************************************
*Method Name: SortRecords
*Description:  Sort the records with the sequence i.e Approver,Validator and Stakeholder
*Parameters: List of approvalRequestWrapperClass and return the sort order
 
*****************************************/   
Public  List<approvalRequestWrapperClass> SortRecords(  List<approvalRequestWrapperClass> Records)

  {

		List<approvalRequestWrapperClass> AfterSort =new List<approvalRequestWrapperClass>();
		 List<string> approvalReqData;
		 List<Apttus_Approval__Approval_Request__c> BeforeSort= new List<Apttus_Approval__Approval_Request__c>();
		  approvalRequestWrapperClass  approvalReqWrapper;
		  
		 for(approvalRequestWrapperClass Data:Records)
		 BeforeSort.add(Data.approvalReq);
		 
		 
		 for(approvalRequestWrapperClass  Rec:Records)
		{
		  if(Rec.approvalReq.NF_Assignee_Type__c<>Null && Rec.approvalReq.NF_Assignee_Type__c.equalsignorecase(GlobalConstants.APPROVER) )
			{
				  
				 
				AfterSort.add(Rec);
			}
		 
		}

		for(approvalRequestWrapperClass  RecValidator:Records)
		{
		  if(RecValidator.approvalReq.NF_Assignee_Type__c<>Null && RecValidator.approvalReq.NF_Assignee_Type__c.equalsignorecase(GlobalConstants.VALIDATOR ) )
			{ 
				  AfterSort.add(RecValidator);
			
			}
		 
		}


		for(approvalRequestWrapperClass  RecStakeHolder: Records)
		{
		  if(RecStakeHolder.approvalReq.NF_Assignee_Type__c<>Null && RecStakeHolder.approvalReq.NF_Assignee_Type__c.equalsignorecase(GlobalConstants.STAKEHOLDER_INFORMATION) )
			{ 
				   AfterSort.add(RecStakeHolder);
				 
			
			}
			else
			{
			 if(RecStakeHolder.approvalReq.NF_Assignee_Type__c==NUll){
			  
				  
				   AfterSort.add(RecStakeHolder);
				 
			 }
			}
		 
		}

		 


return AfterSort ;

}



 
 }