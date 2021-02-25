/**
 * @name	PSR_Approval_ApprovalNotification_Comp
 * @author   
 * @since   July 08, 2017
 * @desc	This class helps in Approval emails data
 * @history 
 */



public class PSR_Approval_ApprovalNotification_Comp{
	@TestVisible private Opportunity Opp {get; set;}
	@TestVisible private Offer__c Off {get; set;}
	@TestVisible private String CTname {get; set;}

	public String OppId {get; set;}

	public PSR_Approval_ApprovalNotification_Comp(){
	 
	}
	
	public Opportunity  getOpp() {
   
	   List<Opportunity> Opp_Lst;
		 Opp_Lst= new List<Opportunity>([Select Id,
																Name,
																Account.Name,
																L7_Name__c,
																Country__c,
																Opportunity_ID__c,
																PSR_Pre_Sales_Risk_Opportunity_Type__c,
																PSR_Pre_Sales_Risk_Opportunity_Sub_Type__c,
																PSR_Description_Justification__c,
																PSR_Reference_Opportunity__r.L7_Name__c,
																PSR_Reference_Opportunity__r.Country__c,
																PSR_Reference_Opportunity__r.Account.Name,
																PSR_Reference_Opportunity__r.StageName,
																PSR_Reference_Opportunity__r.Phase_Status__c,
																PSR_Reference_Opportunity__r.Amount,
																PSR_Reference_Opportunity__r.Contract_Signing_Entity__c,
																End_Customer__c,
																End_Customer__r.Name,
																PSR_Lead_Business_Group__c,
																PSR_Total_Cost_In_Euro__c,
																PSR_Total_Sales_Value_In_Euro__c,
																PSR_Total_Sales_Value_in_Local_Currency__c,
																PSR_Total_Cost_in_Local_Currency__c,
																PSR_Date_PO_Expected__c,
																PSR_Reference_Opportunity__c,
																PSR_Reference_Opportunity__r.Opportunity_ID__c,
																PSR_Reference_Opportunity__r.Name,
																PSR_Pre_C5_NPI__c,
																PSR_Is_Cost_Approved_In_Related_LOA_Opty__c,
																PSR_Is_Cost_Reflected_In_Latest_Estimate__c,
																Org_L7__c,
																CurrencyIsoCode
														 From Opportunity 
														 Where Id =: OppId ]);
														 
	   if( Opp_Lst != null && Opp_Lst.size() > 0){
		   return Opp_Lst[0] ;
	   }else{
		   return null;
	   }												  
	}
	
	 public Offer__c getOff() {
		List<File_Report__c> docs = new List<File_Report__c>();
		List<File_Report__c> G4LoAdocs = new List<File_Report__c>();
		List<Opportunity> oppList = [Select Id, PSR_Reference_Opportunity__c
														From Opportunity 
														 Where Id =: OppId];
		List<Offer__c > Off_Lst = new List<Offer__c >();
		set<ID> ActiveOfferIDSet = new set<ID>();
		if(oppList != null && oppList.size() > 0){
			Off_Lst = new List<Offer__c >([Select Id,
																Offer_ID__c,
																Offer_Number__c,
																Name,
																Offer_Description__c,
																Price__c,
																CurrencyIsoCode,
																LoA_Approval_Level__c,
																Approval_Recommendation__c,
																LoA_Level_Before_Trigger_Approval__c,
																Total_Price_At_Approval_Net_Sale__c,
																Net_Sales_LoA_Base_Case_BG_MN__c,
																Net_Sales_LoA_Base_Case_BG_ION__c,
																Net_Sales_LoA_Base_Case_BG_AA__c,
																Net_Sales_LoA_Base_Case_BG_FN__c,
																Net_Sales_LoA_Base_Case_BG_GS__c,
																LoA_Approval_Level_G4__c,
																Top_5_trigger_1_Name__c,
																Top_5_trigger_1_Level__c,
																Top_5_trigger_1_Category__c,
																Top_5_trigger_2_Category__c,
																Top_5_trigger_2_Level__c,
																Top_5_trigger_2_Name__c,
																Top_5_trigger_3_Category__c,
																Top_5_trigger_3_Level__c,
																Top_5_trigger_3_Name__c,
																Top_5_trigger_4_Category__c,
																Top_5_trigger_4_Level__c,
																	Top_5_trigger_4_Name__c,
																	Top_5_trigger_5_Category__c,
																	Top_5_trigger_5_Level__c,
																	Top_5_trigger_5_Name__c,																	
																	Approval_Scope__c,																	 
																	Risk_Assessment_Position_Statement__c,
																	Pricing_Strategy__c,
																	Customer_and_Competitive_Situation__c,
																	Expected_LoA_G4_Approval_Level__c,
																	Customer_Offer_Due_Date__c,
																	LoA_Currency__c,
																	Net_Sales_LoA_Base_Case__c														   
														 From Offer__c  
														 Where Opportunity__c =: oppList[0].PSR_Reference_Opportunity__c
														 And ActiveOffer__c = true ]);
			}

		for(Offer__c activeOffer:Off_Lst){
			ActiveOfferIDSet.add(activeOffer.Id);
		}
		docs = [select id,Document_Type__c from File_Report__c where Related_Offer__c in: ActiveOfferIDSet];
		for(File_Report__c doc:docs){
			System.debug('-------------------->doc.DocumentType__c'+doc.Document_Type__c);
			if(doc.Document_Type__c == 'LoA G4 Template'){
				G4LoAdocs.add(doc);
				break;
			}
		}
		System.debug('Loop-->Off'+ Off_Lst );   
	   if( Off_Lst != null && Off_Lst.size() > 0 && G4LoAdocs.size() > 0){
		   return Off_Lst[0] ;
	   }else{
		   return null;
	   } 
	}
	


	public String  getCTname() {
	System.debug('xxx OPPID >> '+ OppId );
	   List<OpportunityTeamMember> lstOTM = new List<OpportunityTeamMember>([SELECT Id, UserId, OpportunityId, User.Name ,Name 
																			 FROM OpportunityTeamMember
																			 WHERE OpportunityId= : oppId
																			 AND TeamMemberRole =:'CT Head']);

	   if( lstOTM != null && lstOTM.size() > 0){
		   return  lstOTM[0].name != null ? lstOTM[0].name : '' ; 
	   }else{
		   return null;
	   }												   
	}
	
	 //Construct List of approvalRequests to be shown in a table.
	public List<Apttus_Approval__Approval_Request__c> oppApprovalRequests {
		get{
			if(String.isNotBlank(oppId)){
			
				oppApprovalRequests =[
									SELECT
										Apttus_Approval__Step_Name__c,
										Apttus_Approval__Approval_Status__c,
										Validator_Status__c,
										Apttus_Approval__Date__c,
										Apttus_Approval__Assigned_To_Name__c,
										NF_Assignee_Type__c,
										Apttus_Approval__Actual_Approver__c,
										Apttus_Approval__Approver_Comments__c,
										NF_Role_Name__c,
										NF_Organization_Level__c,
										Apttus_Approval__ActualApproverName__c,
										Apttus_Approval__DelegateApprover__c,
										NF_BG_Attribute__c
									FROM
										Apttus_Approval__Approval_Request__c
									WHERE
										Apttus_Approval__Related_Opportunity__c = :oppId
										AND
										Apttus_Approval__Approval_Status__c != 'Not Submitted'
									];								 
			}
			return oppApprovalRequests;
		}
		set;
	}   

}