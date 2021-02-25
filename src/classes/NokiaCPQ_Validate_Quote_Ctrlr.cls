/****************************************
* Class Name : NokiaCPQ_Validate_Quote_Ctrlr
* Created Date: 8 December 2017
* Created By : Accenture
* Description : Approval Process for direct and Indirect Quotes
* Test Class: 
*****************************************/
public with sharing class NokiaCPQ_Validate_Quote_Ctrlr {
	
	public String currentquoteId {get;set;}
	public String currentOpportunityId  {get; set;}
	public Boolean validationException {get;set;}
	public Opportunity opportunity;
	public Apttus_Proposal__Proposal__c quote;
	public Boolean loaBypass{get;set;}
	public Boolean isBatchRunning {get;set;}
	public Boolean isBatchComplete {get;set;}
	public Boolean quoteApproved{get; set;}  
	public String currentUserId;
	public String apexMethod;
	public String apexClass; 
	public List<Apttus_Config2__ProductConfiguration__c> productConfigs;
	public Apttus_Config2__ProductConfiguration__c productConfig; 
	public List<Apttus_Proposal__Proposal_Line_Item__c > Lineitemlist1;
	public Id ConfigId=null;
	Apttus_Config2.ProductConfiguration cart; 
	public Integer flag;
	public Map<String,Decimal> marketAndDiscountMap = new  Map<String,Decimal>();
	//5261 chnages
	public ID finalizedProductConfigID = null;
	public boolean isCustomFlag = false;
	
	//For Direct
	public Boolean isContractedCLP = true;
	public Boolean manualDiscountGiven = false;
	List<Direct_Portfolio_General_Setting__mdt> generalSetting = new List<Direct_Portfolio_General_Setting__mdt>();
	public Double totalCNPinEURO= 0.0; 
	
	public List<Offer__c> offerList = new List<Offer__c>();
	
	//Constructor Class
	public NokiaCPQ_Validate_Quote_Ctrlr(){
		try{
			currentquoteId = ApexPages.currentPage().getParameters().get(GlobalConstants.QUOTEID);
			system.debug('Inside'+ currentquoteId);
	quote = [Select id,Apttus_Proposal__Opportunity__r.OwnerId,Apttus_Proposal__Opportunity__r.Account.OwnerId,Maintenance_Y1__c,Maintenance_Y2__c,SSP__c,SRS__c,NokiaCPQ_Environment_Access_Type__c,Apttus_Proposal__Approval_Stage__c,NokiaCPQ_Capture_Cancel_Recall_Action__c, NokiaCPQ_Pre_Approved_Discount_Range__c,Exchange_Rate__c, NokiaCPQ_Needs_Reprice__c ,NokiaCPQ_Total_Quote_Discount__c, NokiaCPQ_Approval_Required_Flag__c,Nokia_CPQ_SW_IRP_Discount__c,Nokia_CPQ_SEET_Margin__c,NokiaCPQ_Net_Amount_Quote__c,CurrencyIsoCode,
			NokiaCPQ_Total_CNP__c, Quote_Type__c,Apttus_Proposal__Account__r.L4Name__c,NokiaCPQ_Portfolio__c,Is_List_Price_Only__c,Offer__c,Apttus_Proposal__Opportunity__c, is_CustomProductQuote__c,NokiaCPQ_LEO_Discount__c,is_LEO_Criteria_Match__c,NokiaCPQ_CAD__c,NokiaCPQ_has_Partner_Certified__c,Indirect_Approval_Required__c from Apttus_Proposal__Proposal__c
			where id = :currentquoteId limit 1];
			
			
			currentOpportunityId = quote.Apttus_Proposal__Opportunity__c;
			
			opportunity = [Select id,StageName,Phase_Status__c,Authorized_for_Pricing_manager__c,
						   Pre_approved_Price_List_for_AM__c,No_Loa__c,LOA_Level__c,count_offer__c 
						   from Opportunity 
						   where id = :currentOpportunityId limit 1];
			
			
			quote.NokiaCPQ_Capture_Cancel_Recall_Action__c = GlobalConstants.NOTHING;
			
			productConfigs = [Select id,Apttus_Config2__Status__c from Apttus_Config2__ProductConfiguration__c
							  where Apttus_QPConfig__Proposald__c = :currentquoteId and Apttus_Config2__BusinessObjectType__c =: Nokia_CPQ_Constants.NOKIA_PROPOSAL
							  Order by CreatedDate DESC]; 
			
			//Retrieving meta data
			for(Account_L4_percentage__mdt objMetaData : [SELECT Account_L4__c,Percent_margin__c from Account_L4_percentage__mdt]){
				marketAndDiscountMap.put(objMetaData.Account_L4__c ,objMetaData.Percent_margin__c);
			}
			
			
					   Lineitemlist1= [Select id,LastModifiedDate,Is_Dummy_Bundle__c,Apttus_Proposal__Product__r.Last_Modified_Version__c, Apttus_QPConfig__LineType__c,Apttus_Proposal__Product__r.Apttus_Config2__ConfigurationType__c,Apttus_Proposal__Product__r.IsActive, NokiaCPQ_Product_Name__c, Apttus_QPConfig__OptionId__r.name, Apttus_QPConfig__OptionId__r.IsActive,Apttus_Proposal__Product__c, Apttus_QPConfig__OptionId__c, Apttus_QPConfig__Guidance__c,NokiaCPQ_Is_CLP__c, Apttus_QPConfig__NetAdjustmentPercent__c , is_Custom_Product__c,Apttus_QPConfig__ChargeType__c,NokiaCPQ_Light_Color__c
					   from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c =:currentquoteId];  
  
			
			for(Apttus_Proposal__Proposal_Line_Item__c lin : Lineitemlist1){
				if(quote.Quote_Type__c.equalsIgnoreCase(GlobalConstants.INDIRECT_QUOTE_TYPE )){
					if(lin.Apttus_Proposal__Product__r.IsActive == false  ){
						flag = 1;
						break;
					}
					else if (lin.Apttus_Proposal__Product__r.Last_Modified_Version__c > lin.LastModifiedDate){
						flag = 2;
						break;
					}
					
					if(lin.is_Custom_Product__c){
						isCustomFlag = true;
					}
				}
				else{
					if(String.isNotBlank(lin.Apttus_QPConfig__ChargeType__c) && lin.Apttus_QPConfig__ChargeType__c.equalsIgnoreCase(Nokia_CPQ_Constants.STANDARD_PRICE) && lin.Apttus_QPConfig__LineType__c != Nokia_CPQ_Constants.lin_Apttus_QPConfig && lin.NokiaCPQ_Is_CLP__c == false && !Nokia_CPQ_Constants.NOKIA_YES.equalsIgnoreCase(lin.Is_Dummy_Bundle__c)){

						isContractedCLP = false;
					}
					if(lin.Apttus_QPConfig__NetAdjustmentPercent__c != 0 && lin.Apttus_QPConfig__NetAdjustmentPercent__c != null){
						manualDiscountGiven = true;
					}
					/*if(lin.is_Custom_Product__c){
						isCustomFlag = true;
					}  */ 
				}
			}
			system.debug('isContractedCLP**' + isContractedCLP + '**manualDiscountGiven*'+ manualDiscountGiven);
			
			if(quote.Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_DIRECTCPQ)){
				generalSetting = [Select Id, Approval_Based_On_Traffic_Lights__c From Direct_Portfolio_General_Setting__mdt where Portfolio__c =: quote.NokiaCPQ_Portfolio__c LIMIT 1];
			}
			
			if(!productConfigs.isEmpty()){
				productConfig = productConfigs.get(0);
				system.debug('Status:'+ productConfig.Apttus_Config2__Status__c );
			}
		}catch(Exception e){
			ExceptionHandler.addException(e,NokiaCPQ_Validate_Quote_Ctrlr.class.getName(),GlobalConstants.ERRORVK);
		}
	}
	//PageReference
	public PageReference init() {
		
		
		PageReference approvalsPage = null;
		Boolean noFinalizedCart = false;
		try{
			if(productConfig != null)   
			{
				if(productConfig.Apttus_Config2__Status__c != GlobalConstants.FINALIZED)
				{
					validationException =True;
					isBatchRunning = false;
					isBatchComplete = true;
					loaBypass = false;
					noFinalizedCart = true;
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORHP));
				}  
			} 
			
			
			// noFinalizedCart = false;   
			system.debug('>>>>'+noFinalizedCart);
			if(!noFinalizedCart)   
			{ 
				System.debug('Inside 1 if cond>>>>');
				if(quote.Quote_Type__c.equalsIgnoreCase(GlobalConstants.INDIRECT_QUOTE_TYPE )){  
					 
					 System.debug('Inside Indirect QuoteType>>>>');
					if(opportunity.StageName.startsWith(GlobalConstants.WINCASE)  && opportunity.Phase_Status__c.startsWith(GlobalConstants.PENDINGWIN)  || (opportunity.StageName.equalsIgnoreCase(GlobalConstants.HANDOVER_OPPTY) || opportunity.StageName.equalsIgnoreCase(GlobalConstants.EXECUTE_OPPTY)))
					{	   
						String userProfileId = userinfo.getProfileId();
						Profile profile = [Select name from Profile where id = :userProfileId];
						String profileName = profile.Name;   
						loaBypass = false; 
						if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
						{	
							validationException = True;
							isBatchRunning = false;
							isBatchComplete = true;
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORJB));
						}
						else
						{
							validationException = True;  
							isBatchRunning = false;
							isBatchComplete = true;		 
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORRS)); 
						}
					}
					
					/*else if(quote.NokiaCPQ_Is_BOM_Generated__c == false){
						system.debug('Bom generated Checking');
						validationException =True;
						isBatchRunning = false;
						isBatchComplete = true;
						
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'please contact PSM to generate 1st BOM'));
					}
					
					else if(quote.NokiaCPQ_Is_BOM_Syned__c == false){
						system.debug('Bom generated Checking');
						validationException =True;
						isBatchRunning = false;
						isBatchComplete = true;
						
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please sync the cart before validtion of quote'));
					}*/
					
					//Added by RG for Quote Approval Start
					
			else if(quote.NokiaCPQ_LEO_Discount__c == true && quote.NokiaCPQ_has_Partner_Certified__c == false){
						system.debug('Leo Quote Partner Checking');
						validationException =True;
						isBatchRunning = false;
						isBatchComplete = true;
						
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPC));
					}
					
					
					//Added by RG for Quote Approval End
					
					else if(Lineitemlist1.size() > 0 && flag == 1)
					{		  
						
						for(Apttus_Proposal__Proposal_Line_Item__c lin:Lineitemlist1) {
							
							if (lin.Apttus_QPConfig__LineType__c == Nokia_CPQ_Constants.lin_Apttus_QPConfig) 
							{
								
								if (lin.Apttus_Proposal__Product__r.IsActive == false ) {
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORABD));
									
								}					   
							}else if(lin.Apttus_QPConfig__LineType__c== Nokia_CPQ_Constants.lin_Apttus_QPConfig_if_else){
								
								if (lin.Apttus_QPConfig__OptionId__r.IsActive == false ) {
									validationException = True;  
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORABD));
									
								}					   
							}
						}
					}
					else if(Lineitemlist1.size() > 0 && flag == 2 )
					{
						
						system.debug('debug1 Checking');
						
						for(Apttus_Proposal__Proposal_Line_Item__c lin:Lineitemlist1)
						{
							if(lin.Apttus_Proposal__Product__r.Last_Modified_Version__c > lin.LastModifiedDate)
							{
								validationException = True;  
								isBatchRunning = false;
								isBatchComplete = true;
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORBM));
							}
						}
					}												  
					else if(quote.NokiaCPQ_Needs_Reprice__c == true)
					{  
						system.debug('debug2 Checking');
						validationException =True;
						isBatchRunning = false;
						isBatchComplete = true;
						
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORMS)); 
						
					}	   
					
					
					else if((opportunity.StageName == GlobalConstants.CREATE_OFFER|| opportunity.StageName == GlobalConstants.WIN_THE_CASE_NEGOTIATE ) && opportunity.LOA_Level__c == null && opportunity.Authorized_for_Pricing_manager__c == 0 
							&& opportunity.Pre_approved_Price_List_for_AM__c == 0 && opportunity.No_Loa__c == false)
					{
						
						String userProfileId = userinfo.getProfileId();
						Profile profile = [Select name from Profile where id = :userProfileId];
						String profileName = profile.Name;   
						loaBypass = false; 
						if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
						{	
							validationException = True;
							isBatchRunning = false;
							isBatchComplete = true;
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORSS));
						}
						else
						{
							validationException = True; 
							isBatchRunning = false;
							isBatchComplete = true;		 
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORJA));   
						}	
					}   
					
					
					else if(quote.NokiaCPQ_Net_Amount_Quote__c == 0)
					{
						system.debug('debug4 Checking');
						validationException =True;
						isBatchRunning = false;
						isBatchComplete = true;
						loaBypass = false;
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORJR));
						
					}
					
					else if(opportunity.StageName != GlobalConstants.CREATE_OFFER && opportunity.StageName != GlobalConstants.WIN_THE_CASE_NEGOTIATE )
					{
						system.debug('debug5 Checking');
						
						validationException =True;
						isBatchRunning = false;
						isBatchComplete = true;
						loaBypass = false;
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORDW));
						
					}   
					
					else if(opportunity.Phase_Status__c == GlobalConstants.SUBMITTED_FOR_G4_APPROVAL)		 
						
					{
						system.debug('debug6 Checking');
						validationException =True;
						isBatchRunning = false;
						isBatchComplete = true;
						loaBypass = false;
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORKW));
						
					}
					
					else if(opportunity.StageName == GlobalConstants.WIN_THE_CASE_NEGOTIATE && (opportunity.LOA_Level__c == null || opportunity.LOA_Level__c == GlobalConstants.LOA_BYPASS_LEVEL)  && opportunity.Authorized_for_Pricing_manager__c == 0
							&& opportunity.Pre_approved_Price_List_for_AM__c == 0 && opportunity.No_Loa__c == true && quote.NokiaCPQ_Total_Quote_Discount__c == 0 && !isCustomFlag && (quote.Maintenance_Y1__c == null && quote.Maintenance_Y2__c == null && quote.SSP__c == null && quote.SRS__c == null && quote.NokiaCPQ_LEO_Discount__c == false))   
						
					{
						system.debug('debug7 Checking');
						if(FeatureManagement.checkPermission(GlobalConstants.CustomPermission_CPQPartnerUser) &&
							quote.Apttus_Proposal__Opportunity__r.OwnerId != quote.Apttus_Proposal__Opportunity__r.Account.OwnerId){
							System.debug('Inside Optyowner sharing');
							System.debug('Oppty  owner'+quote.Apttus_Proposal__Opportunity__r.OwnerId);
							System.debug('Account owner'+quote.Apttus_Proposal__Opportunity__r.Account.OwnerId);
							IndirectCPQ_UserSharing.optyOwnertoPartnerSharing(quote.Apttus_Proposal__Opportunity__r.OwnerId);
						   
						}
						quote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.APPROVED;
						update quote;
						validationException = True;
						isBatchRunning = false;
						isBatchComplete = true;
						loaBypass = false;
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.NokiaCPQ_ApprovedQuote));
						
					}
					
					else if(opportunity.StageName == GlobalConstants.WIN_THE_CASE_NEGOTIATE && (opportunity.LOA_Level__c == null || opportunity.LOA_Level__c == GlobalConstants.LOA_BYPASS_LEVEL) && opportunity.Authorized_for_Pricing_manager__c == 0
							&& opportunity.Pre_approved_Price_List_for_AM__c > 0 && opportunity.No_Loa__c == false && quote.NokiaCPQ_Pre_Approved_Discount_Range__c == true && !isCustomFlag && (quote.Maintenance_Y1__c == null && quote.Maintenance_Y2__c == null && quote.SSP__c == null && quote.SRS__c == null && quote.NokiaCPQ_LEO_Discount__c == false))	
						
					{
						 system.debug('debug8 Checking');
						 if(FeatureManagement.checkPermission(GlobalConstants.CustomPermission_CPQPartnerUser) &&
							quote.Apttus_Proposal__Opportunity__r.OwnerId != quote.Apttus_Proposal__Opportunity__r.Account.OwnerId){
							System.debug('Inside Optyowner sharing');
							System.debug('Oppty  owner'+quote.Apttus_Proposal__Opportunity__r.OwnerId);
							System.debug('Account owner'+quote.Apttus_Proposal__Opportunity__r.Account.OwnerId);
							IndirectCPQ_UserSharing.optyOwnertoPartnerSharing(quote.Apttus_Proposal__Opportunity__r.OwnerId);
						   
						}
						quote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.APPROVED;
						update quote;
						validationException = True;
						isBatchRunning = false;
						isBatchComplete = true;
						loaBypass = false;
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.NokiaCPQ_ApprovedQuote));
						
					}
					else if((opportunity.StageName == GlobalConstants.WIN_THE_CASE_NEGOTIATE || opportunity.StageName == GlobalConstants.CREATE_OFFER) && (opportunity.LOA_Level__c == null || opportunity.LOA_Level__c == GlobalConstants.LOA_BYPASS_LEVEL) && opportunity.Authorized_for_Pricing_manager__c == 0
							&& opportunity.Pre_approved_Price_List_for_AM__c == 0 && opportunity.No_Loa__c == true && (quote.NokiaCPQ_Total_Quote_Discount__c > 0 || (quote.Maintenance_Y1__c>0 || quote.Maintenance_Y2__c>0 || quote.SSP__c>0 || quote.SRS__c>0) || isCustomFlag || quote.NokiaCPQ_LEO_Discount__c))  
						
					{
						//RG: 13-08-2019 Added as a part of Req# 6430 Start
						quote.Indirect_Approval_Required__c = true;
						update quote;
						System.debug('quote.NokiaCPQ_LEO_Discount__c-->'+quote.NokiaCPQ_LEO_Discount__c);
						
						if((quote.Maintenance_Y1__c>0 || quote.Maintenance_Y2__c>0 || quote.SSP__c>0 || quote.SRS__c>0) && isCustomFlag && quote.NokiaCPQ_LEO_Discount__c && quote.NokiaCPQ_Total_Quote_Discount__c > 0){
							String userProfileId = userinfo.getProfileId();
							Profile profile = [Select name from Profile where id = :userProfileId];
							String profileName = profile.Name; 
							if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
							{	
								validationException = True;
								isBatchRunning = false;
								isBatchComplete = true;
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORAll));
							}
							else{
								validationException = True;
								isBatchRunning = false;
								isBatchComplete = true;
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMAll));
							}
						}
					   
						else if(quote.Maintenance_Y1__c>0 || quote.Maintenance_Y2__c>0 || quote.SSP__c>0 || quote.SRS__c>0)  {
							if(quote.NokiaCPQ_LEO_Discount__c){
								String userProfileId = userinfo.getProfileId();
								Profile profile = [Select name from Profile where id = :userProfileId];
								String profileName = profile.Name; 
								if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
								{	
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORMPO));
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORLP));
								}else{
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMMPO));
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMLP));
								}
							}
							else if(isCustomFlag==true){
								String userProfileId = userinfo.getProfileId();
								Profile profile = [Select name from Profile where id = :userProfileId];
								String profileName = profile.Name; 
								if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
								{	
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORMPO));
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORCP));
								}
								else{
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMMPO));
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMCP));
								}
							}
							else if(quote.NokiaCPQ_Total_Quote_Discount__c > 0){
								String userProfileId = userinfo.getProfileId();
								Profile profile = [Select name from Profile where id = :userProfileId];
								String profileName = profile.Name; 
								if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
								{	
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORMPO));
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORCAD));
								}
								else{
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMMPO));
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMCAD));
								}
							}
							else{
								String userProfileId = userinfo.getProfileId();
								Profile profile = [Select name from Profile where id = :userProfileId];
								String profileName = profile.Name; 
								if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
								{	
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORMPO));
								}
								else{   
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMMPO));
								}
							}
						}
						else if(isCustomFlag==true) {
							if(quote.NokiaCPQ_LEO_Discount__c){
								String userProfileId = userinfo.getProfileId();
								Profile profile = [Select name from Profile where id = :userProfileId];
								String profileName = profile.Name; 
								if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
								{	
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORCP));
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORLP));
								}
								else{
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMCP));
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMLP));
								}
							}
							else if(quote.NokiaCPQ_Total_Quote_Discount__c > 0){
								String userProfileId = userinfo.getProfileId();
								Profile profile = [Select name from Profile where id = :userProfileId];
								String profileName = profile.Name; 
								if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
								{	
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORCP));
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORCAD));
								}
								else{
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMCP));
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMCAD));
								}
							}
							else{
								String userProfileId = userinfo.getProfileId();
								Profile profile = [Select name from Profile where id = :userProfileId];
								String profileName = profile.Name; 
								if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
								{	
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORCP));
								}
								else{
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMCP));
								}
							}
						}
						 else if(quote.NokiaCPQ_LEO_Discount__c == true){
							 if(quote.NokiaCPQ_Total_Quote_Discount__c > 0){
								 String userProfileId = userinfo.getProfileId();
								Profile profile = [Select name from Profile where id = :userProfileId];
								String profileName = profile.Name; 
								 if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
								{	
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORLP));
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORCAD));
								}
								 else{
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMLP));
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMCAD));
								 }
							 }
							 else{
								String userProfileId = userinfo.getProfileId();
								Profile profile = [Select name from Profile where id = :userProfileId];
								String profileName = profile.Name; 
								if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
								{	
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORLP));
								}
								 else{
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMLP));
								 }
							 }
						}
						else if(quote.NokiaCPQ_Total_Quote_Discount__c > 0){
								String userProfileId = userinfo.getProfileId();
								Profile profile = [Select name from Profile where id = :userProfileId];
								String profileName = profile.Name; 
							 if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
								{	
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORCAD));
								}
							else{
								validationException = True;
								isBatchRunning = false;
								isBatchComplete = true;
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORPSMCAD));
							}
						}
						//RG: 13-08-2019 Added as a part of Req# 6430 End
						
						 else{
							String userProfileId = userinfo.getProfileId();
							Profile profile = [Select name from Profile where id = :userProfileId];
							String profileName = profile.Name;   
							loaBypass = false; 
							if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
							{	
								validationException = True;
								isBatchRunning = false;
								isBatchComplete = true;
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORSS));
							}
							else
							{
								validationException = True; 
								isBatchRunning = false;
								isBatchComplete = true;		 
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORJA));   
							}  
						}   
					}
					
					else if((opportunity.StageName == GlobalConstants.WIN_THE_CASE_NEGOTIATE || opportunity.StageName == GlobalConstants.CREATE_OFFER) && (opportunity.LOA_Level__c == null || opportunity.LOA_Level__c == GlobalConstants.LOA_BYPASS_LEVEL ) && opportunity.Authorized_for_Pricing_manager__c == 0
							 && opportunity.Pre_approved_Price_List_for_AM__c > 0 && opportunity.No_Loa__c == false && quote.NokiaCPQ_Pre_Approved_Discount_Range__c == false)  
						
					{
						String userProfileId = userinfo.getProfileId();
						Profile profile = [Select name from Profile where id = :userProfileId];
						String profileName = profile.Name;   
						loaBypass = false; 
						if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
						{	
							validationException = True;
							isBatchRunning = false;
							isBatchComplete = true;
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORSS));
						}
						else
						{
							validationException = True;  
							isBatchRunning = false;
							isBatchComplete = true;		 
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORJA));   
						}	
					}  
					else if(opportunity.StageName == GlobalConstants.WIN_THE_CASE_NEGOTIATE && ((opportunity.LOA_Level__c != null && opportunity.LOA_Level__c != GlobalConstants.LOA_BYPASS_LEVEL) || opportunity.Authorized_for_Pricing_manager__c > 0)
							&& opportunity.Pre_approved_Price_List_for_AM__c == 0 && opportunity.No_Loa__c == false)	 
					{ 
						validationException = True;
						isBatchRunning = false;
						isBatchComplete = true;
						loaBypass = false;
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORCG));   
					}
					else if(opportunity.StageName == GlobalConstants.CREATE_OFFER && (opportunity.LOA_Level__c == null || opportunity.LOA_Level__c == GlobalConstants.LOA_BYPASS_LEVEL) && opportunity.Authorized_for_Pricing_manager__c == 0
							&& opportunity.Pre_approved_Price_List_for_AM__c == 0 && opportunity.No_Loa__c == true && quote.NokiaCPQ_Total_Quote_Discount__c == 0)  
					{
						if(FeatureManagement.checkPermission(GlobalConstants.CustomPermission_CPQPartnerUser) &&
							quote.Apttus_Proposal__Opportunity__r.OwnerId != quote.Apttus_Proposal__Opportunity__r.Account.OwnerId){
							System.debug('Inside Optyowner sharing');
							System.debug('Oppty  owner'+quote.Apttus_Proposal__Opportunity__r.OwnerId);
							System.debug('Account owner'+quote.Apttus_Proposal__Opportunity__r.Account.OwnerId);
							IndirectCPQ_UserSharing.optyOwnertoPartnerSharing(quote.Apttus_Proposal__Opportunity__r.OwnerId);
						   
						}
						quote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.REVIEW;
						quote.NokiaCPQ_Approval_Required_Flag__c = true;
						update quote;
						system.debug('Inside Create Akrati-->'); 
						validationException = true;
						loaBypass = true;
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.NokiaCPQ_ApprovedQuote));
						submitforApproval(currentOpportunityId);
						isBatchRunning = true;
						isBatchComplete = false;
					} 
					else if(opportunity.StageName == GlobalConstants.CREATE_OFFER && (opportunity.LOA_Level__c == null || opportunity.LOA_Level__c == GlobalConstants.LOA_BYPASS_LEVEL) && opportunity.Authorized_for_Pricing_manager__c == 0
							&& opportunity.Pre_approved_Price_List_for_AM__c > 0 && opportunity.No_Loa__c == false && quote.NokiaCPQ_Pre_Approved_Discount_Range__c == true )  
					{
						System.debug('Insidde Indirectcondition>>>>>>>');
						if(FeatureManagement.checkPermission(GlobalConstants.CustomPermission_CPQPartnerUser) &&
							quote.Apttus_Proposal__Opportunity__r.OwnerId != quote.Apttus_Proposal__Opportunity__r.Account.OwnerId){
							System.debug('Inside Optyowner sharing');
							System.debug('Oppty  owner'+quote.Apttus_Proposal__Opportunity__r.OwnerId);
							System.debug('Account owner'+quote.Apttus_Proposal__Opportunity__r.Account.OwnerId);
							IndirectCPQ_UserSharing.optyOwnertoPartnerSharing(quote.Apttus_Proposal__Opportunity__r.OwnerId);
						   
						}
						quote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.REVIEW;
						quote.NokiaCPQ_Approval_Required_Flag__c = true;
						update quote;
						validationException = true;
						loaBypass = true;
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.NokiaCPQ_ApprovedQuote));
						submitforApproval(currentOpportunityId);
						isBatchRunning = true;
						isBatchComplete = false;						
					}
					else if(opportunity.StageName == GlobalConstants.CREATE_OFFER && ((opportunity.LOA_Level__c != null && opportunity.LOA_Level__c != GlobalConstants.LOA_BYPASS_LEVEL ) || opportunity.Authorized_for_Pricing_manager__c > 0)
							&& opportunity.Pre_approved_Price_List_for_AM__c == 0 && opportunity.No_Loa__c == false /* && (quote.Maintenance_Y1__c>0 || quote.Maintenance_Y2__c>0 || quote.SSP__c>0 || quote.SRS__c>0) */)
					{
						 System.debug('Insidde Indirectcondition22222>>>>>>>');
						String userProfileId = userinfo.getProfileId();
						Profile profile = [Select name from Profile where id = :userProfileId];
						String profileName = profile.Name;	
						loaBypass = false;
						//Added by RG for Approval check starts
						if(quote.NokiaCPQ_Total_Quote_Discount__c > 0 || (quote.Maintenance_Y1__c>0 || quote.Maintenance_Y2__c>0 || quote.SSP__c>0 || quote.SRS__c>0) || isCustomFlag || quote.NokiaCPQ_LEO_Discount__c){
							quote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.REVIEW;
							update quote;
				validationException = True;
							isBatchRunning = false;
							isBatchComplete = true;
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERROROCA));
						}
						//Added by RG for Approval check End
						else{ //added else check by RG
							if(profilename.contains(Nokia_CPQ_Constants.profilename_contains))
							{
								if(FeatureManagement.checkPermission(GlobalConstants.CustomPermission_CPQPartnerUser) &&
									quote.Apttus_Proposal__Opportunity__r.OwnerId != quote.Apttus_Proposal__Opportunity__r.Account.OwnerId){
									System.debug('Inside Optyowner sharing');
									System.debug('Oppty  owner'+quote.Apttus_Proposal__Opportunity__r.OwnerId);
									System.debug('Account owner'+quote.Apttus_Proposal__Opportunity__r.Account.OwnerId);
									IndirectCPQ_UserSharing.optyOwnertoPartnerSharing(quote.Apttus_Proposal__Opportunity__r.OwnerId);
								   
								}
								quote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.REVIEW;
								update quote;
								validationException = True;
								isBatchRunning = false;
								isBatchComplete = true;
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,GlobalConstants.ERRORBL));
							}						
							else
							{	
								if(FeatureManagement.checkPermission(GlobalConstants.CustomPermission_CPQPartnerUser) &&
									quote.Apttus_Proposal__Opportunity__r.OwnerId != quote.Apttus_Proposal__Opportunity__r.Account.OwnerId){
									System.debug('Inside Optyowner sharing');
									System.debug('Oppty  owner'+quote.Apttus_Proposal__Opportunity__r.OwnerId);
									System.debug('Account owner'+quote.Apttus_Proposal__Opportunity__r.Account.OwnerId);
									IndirectCPQ_UserSharing.optyOwnertoPartnerSharing(quote.Apttus_Proposal__Opportunity__r.OwnerId);
								   
								}
								quote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.REVIEW;
								update quote;
								validationException = True;
								isBatchRunning = false;
								isBatchComplete = true;
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,GlobalConstants.ERRORKS));
								
							}
						}
					}
					
				}
				// Req 4183 Starts:Approval Process for Direct Quotes
				
				else  
				{
					System.debug('Direct Quote starts here>>');
					//Changes in Sprint 0+ for requirement #5505
					//Condition 1: Quote needs reprice
					if(quote.NokiaCPQ_Needs_Reprice__c == true){  
						system.debug('Quote needs reprice>>');
						validationException =True;
						isBatchRunning = false;
						isBatchComplete = true;
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORMS));			 
					}// Condition 2: Opportunity stage shoud be Create Offer/Win the Case Negotiate
					else if(opportunity.StageName != GlobalConstants.CREATE_OFFER && opportunity.StageName != GlobalConstants.WIN_THE_CASE_NEGOTIATE){ 
						system.debug('Oppty stage=Create off/win the case negative'+opportunity.StageName);
						validationException =True;
						isBatchRunning = false;
						isBatchComplete = true;
						loaBypass = false;
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORBS));  
					} //Condition 3: Invalid Offer Condition	
					else if(((opportunity.StageName == GlobalConstants.CREATE_OFFER || opportunity.StageName == GlobalConstants.WIN_THE_CASE_NEGOTIATE) && opportunity.LOA_Level__c == null && opportunity.Authorized_for_Pricing_manager__c == 0 && opportunity.Pre_approved_Price_List_for_AM__c == 0 && opportunity.No_Loa__c == false)){
						system.debug('Invalid offer condition');
						loaBypass = false;
						validationException = True;
						isBatchRunning = false;
						isBatchComplete = true;
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORWA));
					} //Condition 4: Quote should be finalized
					//If 100% DISCOUNT GIVEN , CNP CAN BE ZERO(Req 6000)
					else if(quote.NokiaCPQ_Total_CNP__c == 0 && Lineitemlist1.size() == 0){
						system.debug('100% Discount give>>');
							validationException =True;
							isBatchRunning = false;
							isBatchComplete = true;
							loaBypass = false;
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORJR));
						
					} //Condition 5: Opportunity should not already be in approval
					else if(opportunity.Phase_Status__c == GlobalConstants.SUBMITTED_FOR_G4_APPROVAL && quote.NokiaCPQ_Portfolio__c <> 'QTC'){
						
						system.debug('debug6 Checking');
						validationException =True;
						isBatchRunning = false;
						isBatchComplete = true;
						loaBypass = false;
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORKW));	
					} //Condition 6: Quote cannot be validated when Oppty is already G4 approved
					else if(opportunity.StageName == GlobalConstants.WIN_THE_CASE_NEGOTIATE && (opportunity.Authorized_for_Pricing_manager__c > 0 || opportunity.Pre_approved_Price_List_for_AM__c > 0 || opportunity.No_Loa__c == true || (opportunity.LOA_Level__c != null && opportunity.LOA_Level__c != GlobalConstants.LOA_BYPASS_LEVEL)) && quote.NokiaCPQ_Portfolio__c <> 'QTC'){
						System.debug('Quote cannot be validated when oppty is already G4');
						validationException = True;
						isBatchRunning = false;
						isBatchComplete = true;
						loaBypass = false;
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GlobalConstants.ERRORCG));   
					} //Condition 7: For all remaining cases, Move quote to In-Review
					else if(opportunity.StageName == GlobalConstants.CREATE_OFFER && (opportunity.Authorized_for_Pricing_manager__c > 0 || opportunity.Pre_approved_Price_List_for_AM__c > 0 || opportunity.No_Loa__c == true || (opportunity.LOA_Level__c != null && opportunity.LOA_Level__c != GlobalConstants.LOA_BYPASS_LEVEL )) && quote.NokiaCPQ_Portfolio__c <> 'QTC'){
						system.debug('For all remaining quotes');
						if(String.isNotBlank(currentOpportunityId)){
							offerList = [Select Id,ActiveOffer__c, Name,Opportunity__c from Offer__c where ActiveOffer__c=true and Opportunity__c =:currentOpportunityId limit 1];
						}
						system.debug('offer'+offerList);
						if(!generalSetting.isempty() && generalSetting[0].Approval_Based_On_Traffic_Lights__c == false && quote.Is_List_Price_Only__c){  
							System.debug('ION Direct List Price Only quote>>');
							quote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.APPROVED;
							if(!offerList.isEmpty()){
								quote.Offer__c= offerList[0].Id;
							}
							quote.Quote_Status__c = 'Submit'; 
							update quote;
							
							
							validationException = True;
							isBatchRunning = false;
							isBatchComplete = true;
							loaBypass = false;
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.NokiaCPQ_ApprovedQuote));
						}
						else{
							//Converting currency into Euro by dividing it with Exchange rate
							if(quote.CurrencyIsoCode != 'EUR'){ 
								if(quote.Exchange_Rate__c != 0){
									totalCNPinEURO = (quote.NokiaCPQ_Total_CNP__c/quote.Exchange_Rate__c).setScale(2, RoundingMode.HALF_UP);
								}
							}
							else{
								totalCNPinEURO = quote.NokiaCPQ_Total_CNP__c;
							}
							
							// LOA Bypass: No Loa OR Preapproved for Account Manager
						if((opportunity.LOA_Level__c == null || opportunity.LOA_Level__c == GlobalConstants.LOA_BYPASS_LEVEL) && opportunity.Authorized_for_Pricing_manager__c == 0 && ((opportunity.Pre_approved_Price_List_for_AM__c == 0 && opportunity.No_Loa__c == true) || (opportunity.Pre_approved_Price_List_for_AM__c > 0 && opportunity.No_Loa__c == false))){
								
								// Quote set to In-Review + Auto Approval
								if(opportunity.No_Loa__c == true){
									System.debug('manualDiscountGiven -->>'+manualDiscountGiven);
									System.debug('isContractedCLP -->>'+isContractedCLP);
									System.debug('totalCNPinEURO -->>'+totalCNPinEURO);
									if(manualDiscountGiven == false && isContractedCLP == true && totalCNPinEURO < 5000000.00){
										quote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.REVIEW;
										quote.NokiaCPQ_Approval_Required_Flag__c = true;
										if(!offerList.isEmpty()){
											quote.Offer__c = offerList[0].Id;
										}
										update quote;
										
										system.debug('Inside LOA Bypass: No Loa OR Preapproved for Account Manager'); 
										
										validationException = true;
										loaBypass = true;
										ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.NokiaCPQ_ApprovedQuote));
										submitforApproval(currentOpportunityId);
										isBatchRunning = true;
										isBatchComplete = false;
									}
									else{
										validationException = True;
										isBatchRunning = false;
										isBatchComplete = true;
										loaBypass = false;
										ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Nokia_CPQ_Constants.ErrorNoLOA));   
									}
								}
								else if(opportunity.Pre_approved_Price_List_for_AM__c > 0){
									if(manualDiscountGiven == false && isContractedCLP == true && totalCNPinEURO < 5000000){
										quote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.REVIEW;
										quote.NokiaCPQ_Approval_Required_Flag__c = true;
										if(!offerList.isEmpty()){
											quote.Offer__c = offerList[0].Id;
										}
										update quote;
										
										system.debug('Inside LOA Bypass: No Loa OR Preapproved for Account Manager'); 
										
										validationException = true;
										loaBypass = true;
										ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.NokiaCPQ_ApprovedQuote));
										submitforApproval(currentOpportunityId);
										isBatchRunning = true;
										isBatchComplete = false;
									}
									else{
										validationException = True;
										isBatchRunning = false;
										isBatchComplete = true;
										loaBypass = false;
										ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Nokia_CPQ_Constants.ErrorPreApproved));   
									}
								}
							}// LOA Bypass: Authorized for Pricing Manager
							else if((opportunity.LOA_Level__c == null || opportunity.LOA_Level__c == GlobalConstants.LOA_BYPASS_LEVEL) && opportunity.Authorized_for_Pricing_manager__c > 0 && opportunity.Pre_approved_Price_List_for_AM__c == 0 && opportunity.No_Loa__c == false){
								
								Boolean isRedColor=false;
								for(Apttus_Proposal__Proposal_Line_Item__c lin:Lineitemlist1) {
									if(lin.NokiaCPQ_Light_Color__c == Nokia_CPQ_Constants.RED){
										isRedColor=true;
										break;
									}	  
								}
								
								//Quote set to In-Review, No Auto Approval
								if(!isRedColor && totalCNPinEURO < 5000000){
									system.debug('Inside LOA Bypass: Authorized for Pricing Manager'); 
									quote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.REVIEW;
									if(!offerList.isEmpty()){
										quote.Offer__c = offerList[0].Id;
									}
									update quote;
									
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									loaBypass = false;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.NokiaCPQ_InReview_DirectQuote));
								}
								else{
									validationException = True;
									isBatchRunning = false;
									isBatchComplete = true;
									loaBypass = false;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Nokia_CPQ_Constants.ErrorAuthorized));   
								}   
							}// No LOA Bypass
							else if(opportunity.LOA_Level__c != null && opportunity.LOA_Level__c != GlobalConstants.LOA_BYPASS_LEVEL){
								system.debug('Inside No LOA Bypass'); 
								// Quote set to In-Review, No Auto Approval
								quote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.REVIEW;
								if(!offerList.isEmpty()){
									quote.Offer__c = offerList[0].Id;
								}
								update quote;
						
								validationException = True;
								isBatchRunning = false;
								isBatchComplete = true;
								loaBypass = false;
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.NokiaCPQ_InReview_DirectQuote));
							}
						}
					}//Condition 8: For all QTC cases, move to Approved
					 else if((opportunity.StageName == GlobalConstants.CREATE_OFFER || opportunity.StageName == GlobalConstants.WIN_THE_CASE_NEGOTIATE) && quote.NokiaCPQ_Portfolio__c == 'QTC' ){  
							System.debug('ION Direct List Price Only quote>>');
							quote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.APPROVED;
							quote.Quote_Status__c = 'Submit'; 
							update quote;
							validationException = True;
							isBatchRunning = false;
							isBatchComplete = true;
							loaBypass = false;
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.NokiaCPQ_ApprovedQuote));
						}
				}
			}
			
			return approvalsPage;
			system.debug('approvalsPage>>'+approvalsPage);
		}catch(Exception e){
			ExceptionHandler.addException(e,NokiaCPQ_Validate_Quote_Ctrlr.class.getName(),GlobalConstants.ERRORAG);
		}
		return approvalsPage; 
	}
	
	// Req No. 4183 Ends 
	private PageReference constructRedirectionPage(PageReference approvalsPage){
		try{
			if(quote.NokiaCPQ_Environment_Access_Type__c == Nokia_CPQ_Constants.quote_Nokia_CPQ_EATC)
			{
				approvalsPage = Page.Apttus_Approval__ApprovalContextSubmit;
				approvalsPage.getParameters().put('sObjectType','Opportunity');
				approvalsPage.getParameters().put('sObjectId',currentOpportunityId);
				return approvalsPage;
				
			}
			else
			{
				approvalsPage = Page.NF_QuestionnairePreviewAndSubmit;
				approvalsPage.getParameters().put(GlobalConstants.OPPID,currentOpportunityId);
				return approvalsPage;
			}
			
		}catch(Exception e){
			ExceptionHandler.addException(e,NokiaCPQ_Validate_Quote_Ctrlr.class.getName(),GlobalConstants.ERRORMJ);
		}
		return approvalsPage;
	}
	
	//Status Class
	public void currentBatchStatus()
	{
		try{
			if(!loaBypass)
			{
				
				isBatchComplete = true;
				isBatchRunning = false;
				
			}  
			else
			{  
				
				currentUserId = UserInfo.getUserId();
				apexMethod = GlobalConstants.APPROVE; 
				apexClass = System.Label.NOKIA_CPQ_Validate_Quote_Ctrlr;
				
				List<AsyncApexJob> apexJobs = [Select Id,Status From AsyncApexJob Where ApexClassId = :apexClass AND JobType =: GlobalConstants.FUTURECASE AND MethodName = :apexMethod AND CreatedById = :currentUserId Order by CreatedDate DESC];
				AsyncApexJob job = apexJobs.get(0);
				if(job.Status == GlobalConstants.COMPLETED_OPPTY)
				{
					isBatchComplete = true;
					isBatchRunning = false;
					quoteApproved = true;	
				}
				else
				{
					isBatchComplete = false;
					isBatchRunning = true;
				}
			}
		}catch(Exception e){
			ExceptionHandler.addException(e,NokiaCPQ_Validate_Quote_Ctrlr.class.getName(),GlobalConstants.ERRORMH);
		}
	}  
	
	//PageReference if cancelled
	public PageReference cancel() {
		return new PageReference(Nokia_CPQ_Constants.SLASH+currentquoteId);
	}  
	
	@future //Class for Approval
	public static void submitforApproval(String oppId) {
		
		Apttus_Approval.ApprovalsWebService.submitForApprovals(GlobalConstants.OBJECT_OPPORTUNITY,oppId);  
		
	}
	
	
}