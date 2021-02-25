/*********************************
	* Class: ProposalTriggerHandler
	* Description: Handler class for Proposal object
	* Heema			 28/8/2018		   Changes in Release 5 for req 4777	
	**********************************/
public with sharing class ProposalTriggerHandler{
	
	/*********************************
	* author: Accenture
	* Date: 20 MAR 2018
	* Param: List<Apttus_Proposal__Proposal__c> proposalTriggerList
	* Return: None
	* Description: methods collect Proposal Trigger List on before insert and pass to ProposalTriggerHelper.	
	**********************************/
	public static void handleBeforeInsertTrigger(List<Apttus_Proposal__Proposal__c> newProposalList)
	{  
		try{
			//change the value of static variable
			Nokia_CPQ_Constants.ProposalBeforeUpdateTriggerExecute = Nokia_CPQ_Constants.TRUE_STRING;  
			List<Apttus_Proposal__Proposal__c> indirectQuotesList = new List<Apttus_Proposal__Proposal__c>();
			List<Apttus_Proposal__Proposal__c> directQuotesList = new List<Apttus_Proposal__Proposal__c>();
			
			//Segregating Direct and Indirect Quotes
			for(Apttus_Proposal__Proposal__c objNewQuoteRec : newProposalList)
			{
				if(objNewQuoteRec.Quote_Type__c.equalsIgnoreCase(GlobalConstants.DIRECT_QUOTE_TYPE)){
					directQuotesList.add(objNewQuoteRec);
				}
				else if(objNewQuoteRec.Quote_Type__c.equalsIgnoreCase(GlobalConstants.INDIRECT_QUOTE_TYPE)){
					indirectQuotesList.add(objNewQuoteRec);
				}
			}
			
			if(directQuotesList.size() > 0){
				ProposalTriggerHelper.updateExchangeRateFieldsOnBeforeInsert(directQuotesList);
				//Changes in Sprint 0+ for requirement #5495
				ProposalTriggerHelper.associateDirectPriceList(directQuotesList);
				//priyanka: Move Process Builder (Update Quote Record Type Based on Status) logic to Trigger
				ProposalTriggerHelper.updateQuoteRecordType(directQuotesList);
				//priyanka: Move Process Builder (DS Update Quote Approval Stage + ION Direct Is List Price Only) only for direct CPQ logic
				ProposalTriggerHelper.updateListPriceIONDirect(directQuotesList);
			}

			if(indirectQuotesList.size() > 0){  
				ProposalTriggerHelper.associateAccreditation(indirectQuotesList);
				 //Varsha: Move Process Builder (Update Quote Record Type Based on Status) logic to Trigger
				ProposalTriggerHelper.updateQuoteRecordTypeIndirect(indirectQuotesList);
			}
		   
			/**
			* Date: 18 Jul 2018
			* Insert Maintenance SSP and SRS value when create quote
			**/
			if(indirectQuotesList.size() > 0){			   
			   ProposalTriggerHelper.InsertMaintenanceSSPandSRS(indirectQuotesList);
			}
			
		}
		catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHelper.class.getName(),Nokia_CPQ_Constants.QUOTE_NOT_FOUND);
		}  
	}
	
	
	/*********************************
* author: Accenture
* Date: 20 MAR 2018
* Param: List<Apttus_Proposal__Proposal__c> proposalTriggerList
* Return: None
* Description: methods collect Proposal Trigger List on before insert and pass to ProposalTriggerHelper.
* High Level Process :	 
**********************************/
	public static void beforeUpdateTrigger(Map<Id, Apttus_Proposal__Proposal__c> proposalNewTrigger, Map<Id, Apttus_Proposal__Proposal__c> proposalOldTrigger){
		List<Apttus_Proposal__Proposal__c> directQuotesList = new List<Apttus_Proposal__Proposal__c>();
		List<Apttus_Proposal__Proposal__c> indirectQuotesList = new List<Apttus_Proposal__Proposal__c>();
		List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
		if(GlobalConstants.ALLOW_BEFOREUPDATE_QUOTE_PROPOSAL_TRIGGER == true)
		{
			GlobalConstants.ALLOW_BEFOREUPDATE_QUOTE_PROPOSAL_TRIGGER = false;
			System.debug('************Inside ProposalTriggerHelper***********************');
			ProposalTriggerHelper.updateDirectExchangeRate(proposalNewTrigger,proposalOldTrigger);	 
			ProposalTriggerHelper.customValidationOnDirectQickActions(proposalNewTrigger,proposalOldTrigger);
			//heema : status changed while submission for approval
			ProposalTriggerHelper.approvalRequiredChangeStatus(proposalNewTrigger,proposalOldTrigger);
			//Added by RG for Indirect Quote Approval check condition
			ProposalTriggerHelper.updateIndirectApprovalCheck(proposalNewTrigger);
			//priyanka : Move Process Builder ( Quote Updates When Opportunity is Changed) for cancel quote 
			ProposalTriggerHelper.quoteCancelIndirect(proposalNewTrigger,proposalOldTrigger);
			//priyanka : Move Workflow(Update Needs Reprice When Maintenance Changed	)
			ProposalTriggerHelper.updateRepriseOnMaintChange(proposalNewTrigger,proposalOldTrigger);
			//Piyush: Move Process Builder(Quote Updates When Opportunity is Changed) flow(ContractNameUpdateAtQuote)
			 for(id proposal : proposalNewTrigger.keySet()){
				if((proposalNewTrigger.get(proposal).Apttus_Proposal__Approval_Stage__c != proposalOldTrigger.get(proposal).Apttus_Proposal__Approval_Stage__c)
					&& proposalNewTrigger.get(proposal).Apttus_Proposal__Approval_Stage__c == 'Approved'){
					   quoteList.add(proposalNewTrigger.get(proposal));
				   }
			}
			
			if(!quoteList.isEmpty()){
				system.debug('inside updateIndirectOnOppChange');
			  ProposalTriggerHelper.updateContractNameOnQuote(quoteList);
			}
		   // ProposalTriggerHelper.updateContractNameOnQuote(proposalNewTrigger,proposalOldTrigger);
			//Varsha: Move Process Builder (Update Quote Record Type Based on Status) logic to Trigger
			for(Id proposalObjRecId: proposalNewTrigger.keySet()){
				if(proposalNewTrigger.get(proposalObjRecId).Quote_Type__c.equalsIgnoreCase(GlobalConstants.DIRECT_QUOTE_TYPE)){
					directQuotesList.add(proposalNewTrigger.get(proposalObjRecId));
				}
				else if(proposalNewTrigger.get(proposalObjRecId).Quote_Type__c.equalsIgnoreCase(GlobalConstants.INDIRECT_QUOTE_TYPE)){
					indirectQuotesList.add(proposalNewTrigger.get(proposalObjRecId));
				}
			}
			
			if(!directQuotesList.isEmpty()){
				ProposalTriggerHelper.updateQuoteRecordType(directQuotesList);
				//priyanka: Move Process Builder (DS Update Quote Approval Stage + ION Direct Is List Price Only) only for direct CPQ logic
				ProposalTriggerHelper.updateListPriceIONDirect(directQuotesList);
			  
				
			}
			if(!indirectQuotesList.isEmpty()){
			   //priyanka: Move Process Builder (Update Quote Record Type Based on Status) logic to Trigger
				ProposalTriggerHelper.updateQuoteRecordTypeIndirect(indirectQuotesList);
			}
			

			
			//Priyanka: Move Process Builder (Update Quote Expiry Date) logic to Trigger
			List<Apttus_Proposal__Proposal__c> propList = new List<Apttus_Proposal__Proposal__c>();
			
			for(id proposal : proposalNewTrigger.keySet()){
				if(proposalOldTrigger.get(proposal)!=null && String.isNotBlank(proposalOldTrigger.get(proposal).Apttus_Proposal__Approval_Stage__c) && 
				   (proposalOldTrigger.get(proposal).Apttus_Proposal__Approval_Stage__c == 'In Review' ||
					proposalOldTrigger.get(proposal).Apttus_Proposal__Approval_Stage__c == 'Draft' )&& 
				   proposalNewTrigger.get(proposal).Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTEAPPROVED) && 
				   String.isNotBlank(proposalNewTrigger.get(proposal).NokiaCPQ_Portfolio__c) && String.isNotBlank(proposalNewTrigger.get(proposal).Quote_Type__c) ){
					   propList.add(proposalNewTrigger.get(proposal));
				   }
			}
			
			if(!propList.isEmpty()){
				ProposalTriggerHelper.updateQuoteExpiryDate(propList);
			}
		}
		
		
	}
	
		
	/*********************************
	* author: Accenture
	* Date: 27 MAR 2018
	* Param: List<Apttus_Proposal__Proposal__c> proposalTriggerList
	* Return: None
	* Description: methods checks the values of Maintenance and SSP section should not be blank at the time of update.	
	**********************************/
	public static void beforeUpdateCheckBlankFields(Map<Id, Apttus_Proposal__Proposal__c> proposalNewTrigger, Map<Id, Apttus_Proposal__Proposal__c> proposalOldTrigger){

		if(Nokia_CPQ_Constants.ProposalBeforeUpdateTriggerExecute != Nokia_CPQ_Constants.TRUE_STRING){
				   ProposalTriggerHelper.checkBlankFieldsValidation(proposalNewTrigger,proposalOldTrigger);
		}
	
	}
	/*********************
	*
	 * Param: Map<Id,Apttus_Proposal__Proposal__c> proposalNewTrigger>,Map<Id,Apttus_Proposal__Proposal__c> proposalOldTrigger>
	* Return: None
	* Description: methods insert the professional services product for a quote based on portfolio and accreditation level
	* High Level Process :  
	**Requirement ID 4777   
	**********************************/
	public static void createServiceRecord(Map<Id, Apttus_Proposal__Proposal__c> proposalNewTrigger, Map<Id, Apttus_Proposal__Proposal__c> proposalOldTrigger){
		List<Apttus_Proposal__Proposal__c> propList = new List<Apttus_Proposal__Proposal__c>();
		List<String> validMarketList = new List<String>();
		validMarketList = Label.MarketForProfessionalServices.split(';');
		try{
			for(id proposal : proposalNewTrigger.keySet()){
				if(proposalOldTrigger.get(proposal)!=null && String.isNotBlank(proposalOldTrigger.get(proposal).Apttus_Proposal__Approval_Stage__c) && 
				!proposalOldTrigger.get(proposal).Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTEAPPROVED) && 
				proposalNewTrigger.get(proposal).Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTEAPPROVED) && 
				String.isNotBlank(proposalNewTrigger.get(proposal).NokiaCPQ_Portfolio__c) && String.isNotBlank(proposalNewTrigger.get(proposal).Quote_Type__c) && 
				proposalNewTrigger.get(proposal).Quote_Type__c.equalsignorecase(Nokia_CPQ_Constants.QUOTE_TYPE_INDIRECTCPQ)){
					if(String.isNotBlank(proposalNewTrigger.get(proposal).Account_Market__c) && !validMarketList.isEmpty() && validMarketList.contains(proposalNewTrigger.get(proposal).Account_Market__c)){
						propList.add(proposalNewTrigger.get(proposal));
					}
				}
			}
			
			if(!propList.isEmpty()){
				ProposalTriggerHelper.insertServiceRecord(propList);  
			}

		}
		catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHandler.class.getName(),Nokia_CPQ_Constants.QUOTE_NOT_FOUND);
		} 
	}
	
	
	/*********************************
* author: Accenture
* Date: 23 AUG 2019
* Param: Map<Id, Apttus_Proposal__Proposal__c> proposalNewTrigger, Map<Id, Apttus_Proposal__Proposal__c> proposalOldTrigger
* Return: None
* Description: methods collect Old and New Proposal Trigger Map on after update and pass to CQ_ProposalTriggerHelper.
* High Level Process :	 
*****************/
	public static void afterUpdateCPQTrigger(Map<Id, Apttus_Proposal__Proposal__c> proposalNewTrigger, Map<Id, Apttus_Proposal__Proposal__c> proposalOldTrigger){
		try{
			if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id))
			{
				Map<String,String> taskValuesMap = new Map<String,String>();
				Set<Id> qtcProposalMap=new  Set<ID>();
				//Map<Id,Apttus_Proposal__Proposal__c> DQ_sharingchanges=new  Map<Id,Apttus_Proposal__Proposal__c>();
				//Map<Id,Id> DQ_Acct_map = new Map<Id,Id>();  
				for(Apttus_Proposal__Proposal__c Quote:proposalNewTrigger.values()){
				   // if(Quote.Quote_Type__c.equalsIgnoreCase(GlobalConstants.DIRECT_QUOTE_TYPE))
					//{
					  //  if(Quote.OwnerId <> proposalOldTrigger.get(Quote.Id).ownerId || quote.Apttus_Proposal__Account__c <> proposalOldTrigger.get(Quote.Id).Apttus_Proposal__Account__c){
						//	system.debug(' entered CQ_sharingchanges');
						  //  DQ_Acct_map.put(Quote.Id, Quote.Apttus_Proposal__Account__c);
						   // DQ_sharingchanges.put(Quote.Id, Quote);
						//}  
				   // }
					
					//QTC_QuoteProposalTOStaging NovRelease 2019 
					//Added by Naveen to pass data to QTC integration								   
					if((proposalNewTrigger.get(Quote.Id).Roll_Up_Of_Proposal_Line_Item__c != proposalOldTrigger.get(Quote.Id).Roll_Up_Of_Proposal_Line_Item__c)
					//&& proposalNewTrigger.get(Quote.Id).Quote_Type__c.equalsIgnoreCase(GlobalConstants.DIRECT_QUOTE_TYPE)
					&& proposalNewTrigger.get(Quote.Id).Roll_Up_Of_Proposal_Line_Item__c> 0){		  
						//Add the values to task map, to identify if its a Add or Final AddQuoteMessage
						taskValuesMap.put(Quote.NokiaCPQ_Proposal_Id__c,GlobalConstants.TASK_VALUE_UPD);
						qtcProposalMap.add(Quote.Id);
					}
					if(proposalOldTrigger.get(Quote.Id).Apttus_Proposal__Approval_Stage__c !=Quote.Apttus_Proposal__Approval_Stage__c && Quote.Apttus_Proposal__Approval_Stage__c <> null &&
					   Quote.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(GlobalConstants.ACCEPTED)){
						   taskValuesMap.put(Quote.NokiaCPQ_Proposal_Id__c,GlobalConstants.TASK_VALUE_Final);
						   qtcProposalMap.add(Quote.Id);
					   }
				}
				if(!qtcProposalMap.isEmpty() && !GlobalConstants.QTC_BATCHEXECUTED){
					system.debug('Running batch job for status change');		 
					GlobalConstants.QTC_BATCHEXECUTED = true;
					QTC_QuoteProposalToStaging qtc = new QTC_QuoteProposalToStaging(qtcProposalMap,taskValuesMap);	
					Database.executebatch(qtc,Integer.valueOf(Label.QTC_ADDQuoteBatchSize));
				}
				
				//if(!DQ_sharingchanges.isempty()){
			   //	 CQ_ProposalTriggerHelper.CQTerritorysharingupdate(DQ_sharingchanges,DQ_Acct_map);
//				}
				 //priyanka : Move Workflow (Change Quote Status from 'Price' to 'Validate')
			List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
			  for(id proposal : proposalNewTrigger.keySet()){
				if((proposalNewTrigger.get(proposal).Roll_Up_Of_Proposal_Line_Item__c != proposalOldTrigger.get(proposal).Roll_Up_Of_Proposal_Line_Item__c)
					&& proposalNewTrigger.get(proposal).Quote_Type__c.equalsIgnoreCase(GlobalConstants.DIRECT_QUOTE_TYPE)
					&& proposalNewTrigger.get(proposal).Roll_Up_Of_Proposal_Line_Item__c> 0){
					   quoteList.add(proposalNewTrigger.get(proposal));
				   }
			}
			
			if(!quoteList.isEmpty()){
				ProposalTriggerHelper.quoteStatusToValidate(quoteList);
			}
			 //priyanka : Move Process Builder ( Quote Updates When Opportunity is Changed) for cancel quote 
			List<Apttus_Proposal__Proposal__c> quoteListindirect = new List<Apttus_Proposal__Proposal__c>();
			for(id proposal : proposalNewTrigger.keySet()){
				if((proposalNewTrigger.get(proposal).Apttus_Proposal__Opportunity__c != proposalOldTrigger.get(proposal).Apttus_Proposal__Opportunity__c)
					&& proposalNewTrigger.get(proposal).Quote_Type__c.equalsIgnoreCase(GlobalConstants.INDIRECT_QUOTE_TYPE)){
					   quoteListindirect.add(proposalNewTrigger.get(proposal));
				   }
			}
			
			if(!quoteListindirect.isEmpty()){
				system.debug('inside updateIndirectOnOppChange');
				ProposalTriggerHelper.updateIndirectOnOppChange(quoteListindirect);
			}
		  

			}   
		}
		catch(exception ex){
			ExceptionHandler.addException(ex, GlobalConstants.ProposalTriggerHandler, GlobalConstants.ProposalTriggerHandler_afterUpdateCPQTrigger);			
		}
	}
	
	
	/*********************************
* author: Accenture
* Date: 23 AUG 2019
* Param: Map<Id, Apttus_Proposal__Proposal__c> proposalNewTrigger
* Return: None
* Description: methods collect Old and New Proposal Trigger Map on after insert and pass to CQ_ProposalTriggerHelper.
* High Level Process :	 
**********************************/
	
	public static void afterInsertCPQTrigger(Map<Id, Apttus_Proposal__Proposal__c> proposalNewTrigger){
		try{
			if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id))
			{
			  /*  Map<Id,Apttus_Proposal__Proposal__c> DQ_newMap_WithRecord=new  Map<Id,Apttus_Proposal__Proposal__c>();
				Map<Id,Id> DQ_Acct_map = new Map<Id,Id>();
				
				for(Apttus_Proposal__Proposal__c Quote:proposalNewTrigger.values())
				{
					if(Quote.Quote_Type__c.equalsIgnoreCase(GlobalConstants.DIRECT_QUOTE_TYPE))
					{
						DQ_newMap_WithRecord.put(Quote.Id, Quote);
						DQ_Acct_map.put(Quote.Id, Quote.Apttus_Proposal__Account__c);
						system.debug('Inside after CPQ Trigger-Selva');
						system.debug('Quote.NokiaCPQ_End_Customer__c'+Quote.Apttus_Proposal__Account__c);
					}  
					
				}  
				
				system.debug('DQ_Acct_map'+DQ_Acct_map);
				if(!DQ_newMap_WithRecord.isEmpty())
				{
					System.debug('Inside after CPQ Trigger-Selva2');
					CQ_ProposalTriggerHelper.CQTerritorysharing(DQ_newMap_WithRecord, DQ_Acct_map);
					System.debug('Inside after CPQ Trigger-Selva3');
				}*/
			}
		}
		
		catch(exception ex){
			ExceptionHandler.addException(ex, GlobalConstants.ProposalTriggerHandler, GlobalConstants.ProposalTriggerHandler_afterInsertCPQTrigger);			
		}
	}
	
/*********************************
* author: RG: COE
* Date: 27 NOV 2019
* Param: Map<Id, Apttus_Proposal__Proposal__c> proposalNewTrigger
* Return: None
* Description: methods collect Old and New Proposal Trigger Map on after insert and pass to CQ_ProposalTriggerHelper.
* High Level Process :	 
**********************************/
  public static void opptyApprovalforIndirectQuote(Map<Id, Apttus_Proposal__Proposal__c> proposalNewTrigger){
		try{
			Id opptyid;
			if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id))
			{
				for(id proposalRecId: proposalNewTrigger.keySet()){
					opptyid = proposalNewTrigger.get(proposalRecId).Apttus_Proposal__Opportunity__c;
				}
				Opportunity checkOpptyStage = [Select id,StageName,Phase_Status__c,LOA_Level__c,No_Loa__c,Authorized_for_Pricing_manager__c,Pre_approved_Price_List_for_AM__c from Opportunity where id =:opptyid]; 
				System.debug('checkOpptyStage -->'+checkOpptyStage);
				System.debug('proposalNewTrigger-->'+proposalNewTrigger);
				for(id proposalRecId: proposalNewTrigger.keySet()){
					if(proposalNewTrigger.get(proposalRecId).Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_INDIRECTCPQ)){
					   if(checkOpptyStage.StageName == GlobalConstants.CREATE_OFFER && checkOpptyStage.Phase_Status__c == GlobalConstants.OFFER_IN_PROGRESS && (checkOpptyStage.LOA_Level__c == null || checkOpptyStage.LOA_Level__c == GlobalConstants.LOA_BYPASS_LEVEL) && (checkOpptyStage.Pre_approved_Price_List_for_AM__c > 0 || checkOpptyStage.No_Loa__c == true) && proposalNewTrigger.get(proposalRecId).Apttus_Proposal__Approval_Stage__c == GlobalConstants.APPROVED && proposalNewTrigger.get(proposalRecId).Indirect_Approval_Required__c == true){
							System.debug('Inside Submit for approval Auto');
							NokiaCPQ_Validate_Quote_Ctrlr.submitforApproval(opptyid);
					   }
					}
				}
			}
		}
		catch(exception ex){
			ExceptionHandler.addException(ex, GlobalConstants.ProposalTriggerHandler, GlobalConstants.ProposalTriggerHandler_afterInsertCPQTrigger);			
		}
  }	 
}