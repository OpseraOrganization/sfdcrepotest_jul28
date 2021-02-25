/**
*   Class used to check the 14 conditions on Pre Sales Opportunity
*/
public with sharing class NF_PRE_ErrorNotificationCtrl{
	Public static integer limitRows=Limits.getLimitQueryRows()- Limits.getQueryRows();
	public Opportunity currentOpp {get;set;}
	public boolean isQueueAssigned {get;set;}
	public Boolean isAlreadyNotified {get;set;}
	public Boolean hasPermissionToredirect {get;set;}
	public Boolean hasNoSubmitForApproval {get;set;}
	public String currentOppId {get;set;}
	public boolean SalesRole {get;set;}
 
	private static String redirectionChoice{get;set;}

	public enum ApprovalsRedirection { APPROVALCONTEXTSUBMIT, MYAPPROVALS , PREVIEWSUBMITAPPROVALS }

   
	 /* @desc	the method used to initiate the VF NF_FacilitatorNotification 
	 * @return   PageReference: 
	 */
	public PageReference init(){
		//Following line used to check wheter the call is from Preview My approvals or Submit&Preview Approvals or Submit from relatedList
		//Modifying exsisting logic as a part of LoA Req 2356 of Sprint 7.
		SalesRole = false;
		PageReference errorMessage; 
		 
		currentOppId = ApexPages.currentPage().getParameters().get('oppId');
				 system.debug('CurrentOppId:'+CurrentOppID);
	  currentOpp=[select id,name,
					PSR_LoA_Level__c,
					PSR_Description_Justification__c,
					PSR_Date_PO_Expected__c,
					PSR_Total_Cost_in_Local_Currency__c,
					PSR_Lead_Business_Group__c,
					org_l4__c, Org_L3__c,Org_L5__c,
					recordTypeId,PSR_GateClass__c,PSR_Reference_Opportunity__c,
					PSR_Total_Sales_Value_in_Local_Currency__c,
					PSR_Trial_Start_Date__c,
					CurrencyIsoCode,
					PSR_Cost_Business_Group_AA__c,
					PSR_Cost_Business_Group_FN__c,
					PSR_Cost_Business_Group_ION__c,
					PSR_Cost_Business_Group_MN__c,		 
					PSR_Cost_Business_Group_GS__c,
					PSR_Cost_BG_NEN__c,
					PSR_Trial_Duration__c,
					PSR_Total_Cost_In_Euro__c,
					PSR_SW_R_D_Justification_Explanation__c,
					PSR_Trial_Agreement_Status__c,
					PSR_Pre_Sales_Risk_Opportunity_Type__c,
					PSR_Is_Cost_Approved_In_Related_LOA_Opty__c, 
					PSR_Is_Cost_Reflected_In_Latest_Estimate__c,
					PSR_Is_Rv_Reflected_In_Latest_Estimate__c,
					PSR_Pre_Sales_Risk_Opportunity_Sub_Type__c,
					PSR_is_BOM_BOQ_document_attached__c 
				from Opportunity Where id=:currentOppId];
	   
		Return ErrorMessage(currentOpp);
	  
		}
		
		
		
		public PageReference ErrorMessage(Opportunity currentOpp ) {
		
		 String Errorinfo=Label.NF_PRE_Required_Filed_Mandatory;
		 Integer Messagecount=0;
			system.debug('CurrentOpp:'+currentOpp);
		 /*Checking Required fields Start*/
		  if(String.IsEmpty(currentOpp.PSR_Description_Justification__c)){
		  Messagecount=Messagecount+1;
		   Errorinfo=Errorinfo+'Description/Justification, ';
		   Errorinfo+=' \r\n';
		   }
		   
		  if(String.IsEmpty(currentOpp.PSR_Lead_Business_Group__c)){
		  Messagecount=Messagecount+1;
		   Errorinfo=Errorinfo+'Cost for any BG/BU, ';
		   Errorinfo+=' \r\n';
		   }
		   //Risk order
		   if(currentOpp.PSR_Pre_Sales_Risk_Opportunity_Type__c<>NULL && currentOpp.PSR_Pre_Sales_Risk_Opportunity_Type__c.equals('Risk Order')) {			  
		   if(currentOpp.PSR_Total_Sales_Value_in_Local_Currency__c<=0 ){			  
		   Messagecount=Messagecount+1;
		   //Errorinfo=Errorinfo+'Total Sales Value of Opportunity in local currency, ';
		   Errorinfo=Errorinfo+'Sales Value for any BG/BU, '; // PreSales > Sprint 10 > UAT > D-3952
		   Errorinfo+=' \r\n';
		   }
		   IF(currentOpp.PSR_Date_PO_Expected__c==NULL){
		   Errorinfo=Errorinfo+'Date PO Expected / Contract Signed, ' +'\r\n';
			Messagecount=Messagecount+1;
		   }
		   
		   }
		   
		   //Trial
		   if(currentOpp.PSR_Pre_Sales_Risk_Opportunity_Type__c<>NULL && currentOpp.PSR_Pre_Sales_Risk_Opportunity_Type__c.equals('Trial')) {			  
		   
		   if(currentOpp.PSR_Trial_Start_Date__c==NULL){
		  Messagecount=Messagecount+1;
		   Errorinfo=Errorinfo+'Trial/Demo Start Date, ';
		   Errorinfo+=' \r\n';
		   }
			if(currentOpp.PSR_Trial_Duration__c==NULL){
		  Messagecount=Messagecount+1;
		   Errorinfo=Errorinfo+'Trial/Demo Duration, ';
		   Errorinfo+=' \r\n';
		   }
		   IF(currentOpp.PSR_Date_PO_Expected__c==NULL){
		   Errorinfo=Errorinfo+'Date PO Expected / Contract Signed, ' +'\r\n';
			Messagecount=Messagecount+1;
		   }
		   if(String.IsEmpty(currentOpp.PSR_Trial_Agreement_Status__c)){
		  Messagecount=Messagecount+1;
		   Errorinfo=Errorinfo+'Trial Agreement Status, ';
		   Errorinfo+=' \r\n';
		   }
		   if(String.IsEmpty(currentOpp.PSR_Is_Cost_Approved_In_Related_LOA_Opty__c)){
		  Messagecount=Messagecount+1;
		   Errorinfo=Errorinfo+'Is Cost Approved in Related LOA Opportunity, ';
		   Errorinfo+=' \r\n';
		   }
		   }
		   
		   //Demo
			if(currentOpp.PSR_Pre_Sales_Risk_Opportunity_Type__c<>NULL && currentOpp.PSR_Pre_Sales_Risk_Opportunity_Type__c.equals('Demo')) {			  
			if(currentOpp.PSR_Trial_Start_Date__c==NULL){
		  Messagecount=Messagecount+1;
		   Errorinfo=Errorinfo+'Trial/Demo Start Date, ';
		   Errorinfo+=' \r\n';
		   }
			if(currentOpp.PSR_Trial_Duration__c==NULL){
		  Messagecount=Messagecount+1;
		   Errorinfo=Errorinfo+'Trial/Demo Duration, ';
		   Errorinfo+=' \r\n';
		   }
		   }
		   
		   
		   //FOC
		   if(currentOpp.PSR_Pre_Sales_Risk_Opportunity_Type__c<>NULL && currentOpp.PSR_Pre_Sales_Risk_Opportunity_Type__c.equals('Free of Charge')) {			  
		   if(String.IsEmpty(currentOpp.PSR_Is_Cost_Approved_In_Related_LOA_Opty__c)){
		  Messagecount=Messagecount+1;
		   Errorinfo=Errorinfo+'Is Cost Approved in Related LOA Opportunity, ';
		   Errorinfo+=' \r\n';
		   }
		   }
			
			if(currentOpp.PSR_is_BOM_BOQ_document_attached__c == false){
			   Messagecount=Messagecount+1;
			   Errorinfo=Errorinfo+ GlobalConstants.PRESALES_UPLOAD_FILE_ERROR;
			   Errorinfo+=' \r\n';
		   }	
		  /*Checking Required fields End*/  
			
		 String New_Loa_level;
		 String existing_LoA = currentopp.PSR_LoA_Level__c;
		 //PSRO_Calculate_BG_Cost calculateLoA = new PSRO_Calculate_BG_Cost();
		 currentOpp = PSRO_Calculate_BG_Cost.calculateLoAlevel(currentopp);

		   /*Other Validations start*/		  
			if(Messagecount==0)
		   {	 
			   //Req.5782 - Approval submission for level A PSRO limited by user role(offer controller)
			   if(GlobalConstants.LOA_Level.equalsIgnoreCase(currentOpp.PSR_LoA_Level__c)&& !UserInfo.getProfileId().equalsIgnoreCase(Label.System_Admin_Profile_ID) && !UserInfo.getProfileId().equalsIgnoreCase(Label.Nokia_Admin_Profile_Id) && !UserInfo.getProfileId().equalsIgnoreCase(Label.Global_Process_Admin_Profile_Id)){
				  Integer optyTeamMembercount = [SELECT count() FROM OpportunityTeamMember WHERE TeamMemberRole=:GlobalConstants.OFFER_CONTROL AND OpportunityId=:currentOpp.Id AND UserId=:Userinfo.getUserId() Limit : limitRows]; 
				if(optyTeamMembercount==0){
					Messagecount=Messagecount+1;
					if(currentOpp.PSR_Pre_Sales_Risk_Opportunity_Type__c<>NULL && currentOpp.PSR_Pre_Sales_Risk_Opportunity_Type__c.equals('Risk Order'))
						Errorinfo= Label.NF_PSRO_OC_RO;
					if(currentOpp.PSR_Pre_Sales_Risk_Opportunity_Type__c<>NULL && (currentOpp.PSR_Pre_Sales_Risk_Opportunity_Type__c.equals('Trial') || currentOpp.PSR_Pre_Sales_Risk_Opportunity_Type__c.equals('Demo')))
						Errorinfo= Label.NF_PSRO_OC_TD;
				}
			   }				  
			}
			/*Other Validations End */
			
			
				if(Messagecount>0){
				isAlreadyNotified = true;
			   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Errorinfo));
					   System.debug('Loop---'+Errorinfo);
					   return null;
				   }  
				   else 
				   {
					 PageReference myPAge;
					 if(existing_LoA != currentopp.PSR_LoA_Level__c)
					   {
						new_loa_level = currentopp.PSR_LoA_Level__c;
					   }
					 myPAge= Page.APTSCU_PreviewApproval;
					 myPAge.getParameters().put('sObjectId', currentOpp.Id);
					 mypage.getparameters().put('PSRLoAlevel',new_loa_level); 
					  
				   System.debug('NF_PRE_Error'+currentOpp.Id); 
				   return myPAge;				
				   }  
					   
		}   
					
					
					 
   
		
		
		
		 public PageReference cancel() {
		return new PageReference('/'+currentOppId);
		  }
	
	
	
	
	}