/****************************************
* Trigger Name : ContractedQuoteTrigger 
* Created Date: 24 April 2019
* Created By : Accenture
* Description : This trigger copies quote records updates from EAI and load it in to Contracted_Quote__c staging object
*********************/
public with sharing class ContractedQuoteTriggerHandler {
	
	
	private static String UPDATESTATUS_INTERFACETYPE = 'CQ UpdateQuote/Status';
	private static String UPDATEPRICING_INTERFACETYPE = 'CQ UpdateQuote/Pricing';
	Public static integer limitRows = Limits.getLimitQueryRows()- Limits.getQueryRows();
	List<Interface_log__c> ilogsList = new List<Interface_log__c>();
	
	/*****************************
*Method Name: checkSurroundCQ
*Description: This method is used to check whether it the quotes existing in CQ or not
*Parameters:  Quote/Proposal List
**********************/
	public static void checkSurroundCQ(List<Contracted_Quote__c> cqList, Map<Id,Contracted_Quote__c> cqOldMap)
	{
		Map<String,Apttus_Proposal__Proposal__c> quoteMap = new Map<String,Apttus_Proposal__Proposal__c>();
		Set<String> quoteNumberSet = new Set<String>();
		Set<String> Sdlfalsequoteset=new Set<String>();
		Set<String> surrDocQuotes = new Set<String>();
		Map<String,String> oppNumbers = new Map<String,String>();
		List<Apttus_Proposal__Proposal__c> cqUpdateStatusList = new List<Apttus_Proposal__Proposal__c>();
		List<Apttus_Proposal__Proposal__c> cqUpdatePricingList = new List<Apttus_Proposal__Proposal__c>();
		List<Contracted_Quote__c> cqinsertList = new List<Contracted_Quote__c>();
		List<Surround_Document_Links__c> surrDocLinks = new List<Surround_Document_Links__c>();
		try{
			for(Contracted_Quote__c cq : cqList)
			{
				quoteNumberSet.add(cq.CQ_Number__c);
				system.debug(quoteNumberSet);
				String oppNo = cq.CQ_Number__c;
				system.debug('Oppno-->'+oppNo);
				oppNo = oppNo.substring(0, oppNo.lastIndexOf('.')).replace('.','');
				oppNumbers.put(cq.CQ_Number__c,oppNo);
			}
			for(Apttus_Proposal__Proposal__c scq : [Select Id,NokiaCPQ_Proposal_Id__c,eQuote_Error__c,
													Apttus_Proposal__Approval_Stage__c,
													CQ_Submitted_to_Customer_Date__c,
													CQ_eQuote_Status__c,CQ_eQuote__c
													from Apttus_Proposal__Proposal__c
													where NokiaCPQ_Proposal_Id__c = :quoteNumberSet
												   ])
			{
				quoteMap.put(scq.NokiaCPQ_Proposal_Id__c,scq);
			}
			for(Contracted_Quote__c quote : cqList)
			{
				if(quoteMap.containsKey(quote.CQ_Number__c)){
					System.debug('quote++++++++++'+quote+'error++++'+quote.eQuote_Error__c);
					if(quote.eQuote_Error__c <> null && quote.eQuote_Error__c <> 'null' && !String.isBlank(quote.eQuote_Error__c)){
						if(cqOldMap == null || (cqOldMap <> null && quoteMap.get(quote.CQ_Number__c).eQuote_Error__c <> quote.eQuote_Error__c)){
							GlobalConstants.IS_CQUPDATESTATUSMSG = true;
							Apttus_Proposal__Proposal__c cqupdatestatus = updateQuoteStatus(quote,quoteMap);
							cqUpdateStatusList.add(cqupdatestatus); 
						}
					}
					//else{
						if(quote.Surround_QTC_Code__c <> null && quote.Surround_QTC_Code__c <> 'null' && !String.isBlank(quote.Surround_QTC_Code__c)
						  ){
							  if(quoteMap.get(quote.CQ_Number__c).CQ_eQuote__c <> true || !(quoteMap.get(quote.CQ_Number__c).CQ_eQuote__c == true &&
									(quoteMap.get(quote.CQ_Number__c).CQ_eQuote_Status__c != null &&
								   quoteMap.get(quote.CQ_Number__c).CQ_eQuote_Status__c.equalsIgnoreCase(GlobalConstants.EQUOTE_STATUS_INPROGRESS))))
							  {
								  system.debug('Inside prcicng'); 
								  GlobalConstants.IS_CQUPDATEPRICINGMSG = true;
									   Apttus_Proposal__Proposal__c cqupdatepricing = updateQuotePricing(quote,quoteMap);
									cqUpdatePricingList.add(cqupdatepricing);
									sdlfalsequoteset.add(cqupdatepricing.Id);
							  }
						}
					//}
					
				}
				// Removed CQ reporting record creation as per defect D-12354
			  /*  else{
					cqinsertList.add(quote);
				}*/
			}
			for(Surround_Document_Links__c sdocLink : [SELECT Id, Is_Latest__c 
													   FROM Surround_Document_Links__c
													   where(CQ_Name__c in :sdlfalsequoteset)
													   AND Is_Latest__c = true])
			{
				sdocLink.Is_Latest__c = false;
				surrDocLinks.add(sdocLink);
			}
			system.debug('StatusList:'+cqUpdateStatusList);
			 system.debug('cqUpdatePricingList:'+cqUpdatePricingList);
			if(!cqUpdateStatusList.isEmpty())
				updateQuoteinQP(cqUpdateStatusList,UPDATESTATUS_INTERFACETYPE);
			if(!cqUpdatePricingList.isEmpty())
			{
				updateQuoteinQP(cqUpdatePricingList,UPDATEPRICING_INTERFACETYPE);
			}
			// CQ reporting record creation commented defect D-12354
		   // if(!cqinsertList.isEmpty())
		   //	 createCQReportings(cqinsertList,oppNumbers);
			 if(!surrDocLinks.isEmpty()){
				Database.update(surrDocLinks,false);
			}
		}catch(Exception ex)
		{
			ExceptionHandler.addException(ex,GlobalConstants.CQ_CONTRACTED_QUOTE_TRIGGER_HANDLER, GlobalConstants.CQ_CHECKSURROUNDCQ);
		}
	}
	
	/*****************************
*Method Name: updateQuote
*Description: This method checks whether it is update quote status or update quote pricing
*Parameters:  Quote/Proposal List
**********************/ 
	public static Apttus_Proposal__Proposal__c updateQuoteStatus(Contracted_Quote__c cq, Map<String,Apttus_Proposal__Proposal__c> quoteMap){
		Apttus_Proposal__Proposal__c CQquote = new Apttus_Proposal__Proposal__c();
		try{
			CQquote.Id = quoteMap.get(cq.CQ_Number__c).Id;
			CQquote.eQuote_Error__c = cq.eQuote_Error__c;
			CQquote.NokiaCPQ_Proposal_Id__c = cq.CQ_Number__c;
		}catch(Exception ex)
		{
			ExceptionHandler.addException(ex,GlobalConstants.CQ_CONTRACTED_QUOTE_TRIGGER_HANDLER , GlobalConstants.CQ_UPDATE_QUOTE_STATUS);
		}
		return CQquote;
	}
	
	/*****************************
*Method Name: updateQuote
*Description: This method checks whether it is update quote status or update quote pricing
*Parameters:  Quote/Proposal List
**********************/ 
	public static void updateQuoteinQP(List<Apttus_Proposal__Proposal__c> CQList,String messageType){
		String ilogName = '';
		String interfaceReqSent = '';
		String comment = '';
		List<Interface_log__c> ilogsList = new List<Interface_log__c>();
		
		try{
			if(!CQList.isEmpty())
			{
				//update CQList;
				List<Database.SaveResult> cqResults = Database.update(CQList,false);
				for(Integer index=0, size = CQList.size(); index < size;index++ )
				{
					if(messageType.equals(UPDATESTATUS_INTERFACETYPE)){
						ilogName = 'CQ update status success for '+ CQList[index].NokiaCPQ_Proposal_Id__c;
						interfaceReqSent = ' Quote Id: '+ CQList[index].Id +' eQuote error :'+ CQList[index].eQuote_Error__c ;
					}
					else{
						ilogName = 'CQ update pricing success for '+ CQList[index].NokiaCPQ_Proposal_Id__c;
						interfaceReqSent = ' Quote Id: '+ CQList[index].Id +'\nCQ value :'+ CQList[index].CQ_Value__c +
							'\nReady for Submission: '+CQList[index].CQ_Ready_for_Submission__c + '\nInitial Pricing Date: '+CQList[index].CQ_Initial_Pricing_Date__c
							+ '\nExpiration Date: '+CQList[index].Apttus_Proposal__Proposal_Expiration_Date__c+
							'\nCurrency Code: '+CQList[index].CurrencyIsoCode;
					}
					if(cqResults[index].isSuccess()){
						ilogsList.add(createSuccessInterfaceLogs(messageType,ilogName,interfaceReqSent));
					}
					else{
						for (Database.Error err : cqResults[index].getErrors()){
							comment = ' Fields: '+err.getFields()+' Message: '+err.getMessage()+
											'Status Code: '+err.getStatusCode();
						}
						ilogsList.add(createErrorInterfaceLogs(messageType,ilogName,interfaceReqSent,comment));
					}
				}
				Database.insert(ilogsList,false);
			}
			//Send email logic to be added
		}catch(Exception ex)
		{
			ExceptionHandler.addException(ex,GlobalConstants.CQ_CONTRACTED_QUOTE_TRIGGER_HANDLER,GlobalConstants.CQ_UPDATEQUOTEINQP);
		}
	}
	
	
	
	/*****************************
*Method Name: updateQuoteProposal
*Description: This method updates record in quote/proposal based on data from EAI
*Parameters:  Quote/Proposal List
**********************/
	@testVisible
	private static Apttus_Proposal__Proposal__c updateQuotePricing(Contracted_Quote__c cq, Map<String,Apttus_Proposal__Proposal__c> quoteMap){
		System.debug('Pricing*********');
		Apttus_Proposal__Proposal__c CQquote = new Apttus_Proposal__Proposal__c();
		
		try{
			CQquote.Id = quoteMap.get(cq.CQ_Number__c).Id;
			CQquote.CQ_Value__c = cq.CQ_Value__c;
			CQquote.CurrencyIsoCode = cq.CurrencyIsoCode;
			CQquote.CQ_Initial_Pricing_Date__c = cq.Initial_Pricing_Date__c;
			CQquote.CQ_Ready_for_Submission__c = cq.Ready_for_Submission__c;
			CQquote.NokiaCPQ_Proposal_Id__c = cq.CQ_Number__c;
			CQquote.Apttus_Proposal__Proposal_Expiration_Date__c = cq.Expiration_Date__c;
			//CQquote.CQ_Master_Quote__c = cq.Surround_Master_Quote__c;
			CQquote.CQ_Surround_Master_Quote__c = cq.Surround_Master_Quote__c;
			CQquote.Surround_QTC_Code__c = cq.Surround_QTC_Code__c; 
			if(quoteMap.get(cq.CQ_Number__c).Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(GlobalConstants.CQ_STATUS_DRAFT))
				CQquote.Apttus_Proposal__Approval_Stage__c = GlobalConstants.CQ_STATUS_APPROVED;
		   
		}catch(Exception ex)
		{
			ExceptionHandler.addException(ex,GlobalConstants.CQ_CONTRACTED_QUOTE_TRIGGER_HANDLER,GlobalConstants.CQ_UPDATE_QUOTE_PRICING);
		}
		return CQquote;
	}	// QuoteMapping() method ends here
	

	/*****************************
*Method Name: createCQReportings
*Description: This method creates record in CQ reportings based on data from EAI
*Parameters:  Quote/Proposal List
**********************/
   /* private static void createCQReportings(List<Contracted_Quote__c> CQWrap,Map<String,String> oppNumbers)
	{
		List<Surround_CQ_Reporting__c> cqReportingList = new List<Surround_CQ_Reporting__c>();
		Map<String,Opportunity> oppMap = new Map<String,Opportunity>();
		try{
			for(Opportunity opp : [Select Id,Opportunity_ID__c,Opportunity_Number_Unformatted__c,AccountId
								 From Opportunity
								  Where Opportunity_Number_Unformatted__c in :oppNumbers.values()
								 ])
			{
				oppMap.put(opp.Opportunity_Number_Unformatted__c,opp);
			}

		
			
			
			for(Contracted_Quote__c cq : CQWrap)
			{
				Surround_CQ_Reporting__c cqReporting = new Surround_CQ_Reporting__c();
				cqReporting.CQ_Status__c = GlobalConstants.CQ_STATUS_APPROVED;
				cqReporting.CQ_Value__c = CQ.CQ_Value__c;
				cqReporting.CurrencyIsoCode = CQ.CurrencyIsoCode;
				cqReporting.Initial_Pricing_Date__c = CQ.Initial_Pricing_Date__c;
				cqReporting.Ready_for_Submission__c = CQ.Ready_for_Submission__c;
				cqReporting.CQ_Number__c = CQ.CQ_Number__c;
				cqReporting.Expiration_Date__c = CQ.Expiration_Date__c;
				cqReporting.Master_CQ__c = CQ.Surround_Master_Quote__c;
				cqReporting.Opportunity__c = oppMap.get(oppNumbers.get(CQ.CQ_Number__c)).Id;
				cqReporting.Surround_Priced_Account__c = CQ.Surround_Priced_Account__c;
				cqReporting.CQ_Quote_Path_Status__c = Globalconstants.CQ_STATUS_SUBMIT;
				cqReporting.Account_Name__c = oppMap.get(oppNumbers.get(CQ.CQ_Number__c)).AccountId;
				cqReportingList.add(cqReporting);
			}
			if( !cqReportingList.isEmpty())
			{
				//insert cqReportingList;
				Database.insert(cqReportingList,false);
			}
		}catch(Exception ex)
		{
			ExceptionHandler.addException(ex,GlobalConstants.CQ_CONTRACTED_QUOTE_TRIGGER_HANDLER,GlobalConstants.CQ_CREATECQREPORTINGS);
		}
	}  */  
	
	/*****************************
*Method Name: createInterfaceLogs
*Description: This method creates record in interface logs for all the error record updates from EAI
*Parameters:  Quote/Proposal List
**********************/	
	public static Interface_log__c createErrorInterfaceLogs(String interfaceType, String logName, String interfaceReqSent, String comment)
	{
		Interface_log__c ilog_callout = new Interface_log__c();
		try{
			ilog_callout.Interface_Type__c = interfaceType ;
			ilog_callout.Message_Type__c = GlobalConstants.INBOUND;
			ilog_callout.Operation_Type__c = GlobalConstants.UPDATE_VALUE;
			ilog_callout.Interface_Request_Sent__c = interfaceReqSent;
			ilog_callout.Status__c = GlobalConstants.FAILURE;
			ilog_callout.Name = logName;   
			ilog_callout.comment__c = comment;
		}catch(Exception ex)
		{
			ExceptionHandler.addException(ex,GlobalConstants.CQ_CONTRACTED_QUOTE_TRIGGER_HANDLER , GlobalConstants.CQ_CREATERRORINTERFACELOGS);
		}
		return ilog_callout;
	}
	/*****************************
*Method Name: createSuccessInterfaceLogs
*Description: This method creates record in interface logs for all the success record updates from EAI
*Parameters:  Quote/Proposal List
**********************/	
	public static Interface_log__c createSuccessInterfaceLogs(String interfaceType, String logName, String interfaceReqSent)
	{
		Interface_log__c ilog_callout = new Interface_log__c();
		try{
			ilog_callout.Interface_Type__c = interfaceType ;
			ilog_callout.Message_Type__c = GlobalConstants.INBOUND;
			ilog_callout.Operation_Type__c = GlobalConstants.UPDATE_VALUE;
			ilog_callout.Interface_Request_Sent__c = interfaceReqSent;
			ilog_callout.Status__c = GlobalConstants.SUCCESS;
			ilog_callout.Name = logName;   
			ilog_callout.comment__c = GlobalConstants.SUCCESS;
		}catch(Exception ex)
		{
			ExceptionHandler.addException(ex,GlobalConstants.CQ_CONTRACTED_QUOTE_TRIGGER_HANDLER , GlobalConstants.CQ_CREATESUCCESSINTERFACELOGS);
		}
		return ilog_callout;
	}
   
}