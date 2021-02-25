/*****************************************
* Class Name : ProposalTriggerHelper
* Created Date: 8 December 2017
* Created By : Accenture
* Description : 1. Associate Accreditation and Shipping Location with proposal
* Test Class: 
*****************************************/
public with sharing class ProposalTriggerHelper{
	
  private static Boolean isSRS = false;
  public static map<String,Nokia_CPQ_SSP_SRS_Default_Values__mdt> newMapSRS_SSP = new map<String,Nokia_CPQ_SSP_SRS_Default_Values__mdt>();
	
  
	/*********************************
	* Param: Map<Id, Apttus_Proposal__Proposal__c>, Map<Id, Apttus_Proposal__Proposal__c>
	* Return: None  
	**********************************/
	public static void customValidationOnDirectQickActions(Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap, Map<Id, Apttus_Proposal__Proposal__c> proposalOldTriggerMap){
		try{
			for(id proposalObjRecId: proposalNewTriggerMap.keySet()){
				if(proposalNewTriggerMap.get(proposalObjRecId).Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_DIRECTCPQ)){									  
					
					if(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Capture_Cancel_Recall_Action__c != null && (!proposalOldTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(Nokia_CPQ_Constants.APPROVED_STRING) && !proposalOldTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(Nokia_CPQ_Constants.ACCEPTED_STRING) ) &&  proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Capture_Cancel_Recall_Action__c.equalsIgnoreCase(Nokia_CPQ_Constants.CANCEL_ACTION)  && proposalNewTriggerMap.get(proposalObjRecId).Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_DIRECTCPQ) && proposalNewTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c != proposalOldTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c){
						proposalNewTriggerMap.get(proposalObjRecId).addError(GlobalConstants.DISPLAY_ERROR_CANCEL_ACTION_ONDIRECTQUOTE);
						proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Capture_Cancel_Recall_Action__c = Nokia_CPQ_Constants.BLANK_STRING_WITHOUT_SPACE;
					}
				
					else if(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Capture_Cancel_Recall_Action__c != null && (!proposalOldTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTEINREVIEW)) && proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Capture_Cancel_Recall_Action__c.equalsIgnoreCase(Nokia_CPQ_Constants.RECALL_ACTION)  && proposalNewTriggerMap.get(proposalObjRecId).Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_DIRECTCPQ) && proposalNewTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c != proposalOldTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c){
						proposalNewTriggerMap.get(proposalObjRecId).addError(GlobalConstants.DISPLAY_ERROR_RECALL_ACTION_ONDIRECTQUOTE);
						proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Capture_Cancel_Recall_Action__c = Nokia_CPQ_Constants.BLANK_STRING_WITHOUT_SPACE;
					
					}
				}
			}
		}
		catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHelper.class.getName(),Nokia_CPQ_Constants.QUOTE_NOT_FOUND);
		} 
	}
	
	/*********************************
	* Param: Map<Id, Apttus_Proposal__Proposal__c>, Map<Id, Apttus_Proposal__Proposal__c>
	* Return: None  
	* This method is written in order to calculate correct SSP for SPS Direct product, we are setting USD based exchange rate to used in attribute expression
	**********************************/
	public static void updateDirectExchangeRate(Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap, Map<Id, Apttus_Proposal__Proposal__c> proposalOldTriggerMap){
		try{
						
			
			for(id proposalObjRecId: proposalNewTriggerMap.keySet()){
				if(proposalNewTriggerMap.get(proposalObjRecId).Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_DIRECTCPQ)){									  
					
					
					CurrencyType objCurrencyType = [select IsoCode, ConversionRate from CurrencyType where IsoCode =:proposalNewTriggerMap.get(proposalObjRecId).CurrencyISOCode LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())];
					Decimal price=objCurrencyType.ConversionRate;
					
					if(proposalNewTriggerMap.get(proposalObjRecId).exchange_rate__c != null && proposalOldTriggerMap.get(proposalObjRecId).exchange_rate__c != null && 
					   proposalOldTriggerMap.get(proposalObjRecId).exchange_rate__c!= proposalNewTriggerMap.get(proposalObjRecId).exchange_rate__c && proposalNewTriggerMap.get(proposalObjRecId).CurrencyISOCode!='USD'){
						proposalNewTriggerMap.get(proposalObjRecId).Exchange_Rate_for_Direct__c=proposalOldTriggerMap.get(proposalObjRecId).Exchange_Rate_for_Direct__c*proposalNewTriggerMap.get(proposalObjRecId).exchange_rate__c/price; 
					}
				}
			}
		}
		catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHelper.class.getName(),Nokia_CPQ_Constants.QUOTE_NOT_FOUND);
		} 
	}
	
	/*********************************
	* author: Accenture
	* Date: 29 MAR 2018
	* Param: List<Apttus_Proposal__Proposal__c> newQuote
	* Return: None
	* Description: method used to populate exchange rate depending on the currency
	* High Level Process :   
	**********************************/
	  public static void updateExchangeRateFieldsOnBeforeInsert( List<Apttus_Proposal__Proposal__c> newQuote){
 
		
		Set<Id> opptySet = new Set<Id>();
		Map<Id,OpportunityTeamMember>  opptyTeammemberMap = new Map<Id,OpportunityTeamMember>();
		try{
			
			for(Apttus_Proposal__Proposal__c objQuote: newQuote )
			{
				opptySet.add(objQuote.Apttus_Proposal__Opportunity__c);		 
			}
			
			// Collect Oppty rec 
			Map<Id, Opportunity> opptyRecMap = new Map<Id, Opportunity>([select id, CurrencyIsoCode from Opportunity where Id =:opptySet LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())]);
			
			Set<String> isoCodeSet = new Set<String>();
			
			// Create Set of ISO Code
			for(Opportunity objOppty : opptyRecMap.Values()){
				isoCodeSet.add(objOppty.CurrencyIsoCode);
			}
				
			Map<String, Decimal> conversionRateMap = new Map<String, Decimal>();
			CurrencyType objCurrencyTypeUSD = [select IsoCode, ConversionRate from CurrencyType where IsoCode ='USD' LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())];
				Decimal USDPrice=objCurrencyTypeUSD.ConversionRate;
			
			// Collect Conversion Rate from Currency Type object based on ISO code
			for(CurrencyType objCurrencyType : [select IsoCode, ConversionRate from CurrencyType where IsoCode =:isoCodeSet LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())])
			{
				conversionRateMap.put(objCurrencyType.IsoCode, objCurrencyType.ConversionRate);
			}
			
			// Assign value to Quote object rec.
			for(Apttus_Proposal__Proposal__c objQuoteRec : newQuote)
			{
			  
				
				if(opptyRecMap.get(objQuoteRec.Apttus_Proposal__Opportunity__c).CurrencyIsoCode.equalsIgnoreCase(GlobalConstants.EUR_CURRENCY_CODE)){
					objQuoteRec.exchange_rate__c = GlobalConstants.VALUE_ONE;
				}
				else{
					objQuoteRec.exchange_rate__c = conversionRateMap.get(opptyRecMap.get(objQuoteRec.Apttus_Proposal__Opportunity__c).CurrencyIsoCode);
				} 
				
				//Below conditions have been added for SPS product's SSP where USD should be base currency
				 if(opptyRecMap.get(objQuoteRec.Apttus_Proposal__Opportunity__c).CurrencyIsoCode.equalsIgnoreCase('USD')){
					objQuoteRec.Exchange_Rate_for_Direct__c=GlobalConstants.VALUE_ONE;
				}
				else{
					objQuoteRec.Exchange_Rate_for_Direct__c=conversionRateMap.get(opptyRecMap.get(objQuoteRec.Apttus_Proposal__Opportunity__c).CurrencyIsoCode)/USDPrice;					
				}				
			}					   
		}
		catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHelper.class.getName(),Nokia_CPQ_Constants.QUOTE_NOT_FOUND);
		}	 
	}
	
	/*********************************
	* Param: List<Apttus_Proposal__Proposal__c> newProposalList
	* Return: None
	* Description: method used to associate accreditation to proposal records  
	**********************************/
	public static void associateAccreditation(List<Apttus_Proposal__Proposal__c> newProposalList){
		
		Set<Id> oppIdSet = new Set<Id>();
		Set<Id> accIdSet = new Set<Id>();
		Set<String> portfolioSet = new Set<String>();
		List<Apttus_Proposal__Proposal__c> validPropList = new List<Apttus_Proposal__Proposal__c>();
		Map<Id,Id> oppAndAccIdMap = new Map<Id,Id>();
		Map<String, List<Accreditation__c>> accIdAndAccredMap = new Map<String, List<Accreditation__c>>();
		Map<String,String> shippingLocMap = new Map<String,String>();
		Map<Id,List<OpportunityTeamMember>>  opptyTeammemberMap = new Map<Id,List<OpportunityTeamMember>>();
		//By pass Associate Accreditation for Direct Quote Record type...
		for(Apttus_Proposal__Proposal__c newProp : newProposalList){
			// Check Direct Quote record type will not process furter
			if(newProp.Apttus_Proposal__Opportunity__c != null && String.isNotBlank(newProp.NokiaCPQ_Portfolio__c) && newProp.NokiaCPQ_Opportunity_Type__c <> Nokia_CPQ_Constants.DIRECT_REC_TYPE && newProp.Quote_Type__c.equalsignorecase(Nokia_CPQ_Constants.QUOTE_TYPE_INDIRECTCPQ)){
				oppIdSet.add(newProp.Apttus_Proposal__Opportunity__c);
				validPropList.add(newProp);
				portfolioSet.add(newProp.NokiaCPQ_Portfolio__c);
			}  
		}
		
		if(oppIdSet.size() >0 && validPropList.size()>0 &&  portfolioSet.size() >0){
			//Fetch AccountId from Opportunity
			for(Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id IN: oppIdSet AND AccountId != null LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())]){
				if(opp.AccountId != null){
					accIdSet.add(opp.AccountId);
					oppAndAccIdMap.put(opp.Id,opp.AccountId);
				}
			}
			
			//Fetch accreditation records related to Accounts
			for(Accreditation__c accred : [SELECT Id, Partner__c, Portfolio__c, Accreditation_Type__c, Pricing_Cluster__c FROM Accreditation__c WHERE Partner__c IN: accIdSet LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())]){
				if(accred.Partner__c != null){
					if(accIdAndAccredMap.containsKey(accred.Partner__c)){
						accIdAndAccredMap.get(accred.Partner__c).add(accred);
					}
					else{
						accIdAndAccredMap.put(accred.Partner__c, new List<Accreditation__c>{accred});
					}
				}
			}
			//ADDED BY RG FOR APPROVAL CHECK START 
			List<OpportunityTeamMember> opptyTeammember = [select TeamMemberRole,Id,OpportunityId,UserId from OpportunityTeamMember where OpportunityId=:oppIdSet and TeamMemberRole = 'Pricing Manager' LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())];
			List<id> pmUsers = new List<id>();
			List<id> PcngMngBGUser = New List<id>();
			
			for(OpportunityTeamMember optymem : opptyTeammember){
				if(opptyTeammemberMap.containsKey(optymem.OpportunityId)){
					opptyTeammemberMap.get(optymem.OpportunityId).add(optymem);
				}else{
					opptyTeammemberMap.put(optymem.OpportunityId, new List<OpportunityTeamMember>{optymem});
				}
				pmUsers.add(optymem.UserId);
				
			}
			
			for(Sales_Role__c otmBGpm : [Select User__c from Sales_Role__c where User__c IN :pmUsers and BG__c = 'FN' and Active__c = true LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())]){
				PcngMngBGUser.add(otmBGpm.User__c);
			}
			//ADDED BY RG FOR APPROVAL CHECK END 
			for(Shipping_Location__c loc : [SELECT Id, Portfolio__c, Pricing_Cluster__c, Shipping_Location__c FROM Shipping_Location__c WHERE Portfolio__c IN: portfolioSet AND Pricing_Cluster__c !=: Nokia_CPQ_Constants.BLANK_STRING_WITHOUT_SPACE LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())]){
				shippingLocMap.put(loc.Portfolio__c + loc.Pricing_Cluster__c, loc.Shipping_Location__c);
			}
			
			for(Apttus_Proposal__Proposal__c newProp : validPropList){
				Boolean noAccredFound = true;
				Boolean prodFound = false;
				Boolean maintFound = false;
				String accntId = oppAndAccIdMap.get(newProp.Apttus_Proposal__Opportunity__c);
				List<Accreditation__c> accredList = new List<Accreditation__c>();
				accredList = accIdAndAccredMap.get(accntId);
				//ADDED BY RG FOR APPROVAL CHECK START
				if(opptyTeammemberMap != null && (newProp.NokiaCPQ_Portfolio__c == 'Fixed Access - POL' || newProp.NokiaCPQ_Portfolio__c == 'Fixed Access - FBA')){
					for(id idValue : opptyTeammemberMap.keyset()){
						for(OpportunityTeamMember otm : opptyTeammemberMap.get(idValue)){
							if(PcngMngBGUser != null && PcngMngBGUser.Contains(otm.UserId)){
								newProp.PricingmanagerUser__c = otm.UserId;
							}
						}
					}
					//newProp.PricingmanagerUser__c = opptyTeammemberMap.get(newProp.Apttus_Proposal__Opportunity__c).UserId;
				}
				//ADDED BY RG FOR APPROVAL CHECK END 
				if(accredList != null && accredList.size()>0)
				{
					for(Accreditation__c accred2 : accredList)
					{
						if(String.isNotBlank(accred2.Portfolio__c) && accred2.Portfolio__c.equalsIgnoreCase(newProp.NokiaCPQ_Portfolio__c))
						{
							if(String.isNotBlank(accred2.Accreditation_Type__c) && accred2.Accreditation_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.NOKIA_ACCRED_TYPE_PRODUCT) && noAccredFound == true){
								//noAccredFound = false;
								prodFound = true;
								newProp.NokiaProductAccreditation__c = accred2.Id;
								if(String.isNotBlank(accred2.Pricing_Cluster__c))
								{
									newProp.NokiaCPQPricing_Cluster__c = accred2.Pricing_Cluster__c;
								}
							}
							
							if(String.isNotBlank(accred2.Accreditation_Type__c) && accred2.Accreditation_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.NOKIA_ACCRED_TYPE_MAINTENANCE))
							{
								maintFound = true;
								newProp.NokiaCPQ_Maintenance_Accreditation__c = accred2.Id;
							}
						}
						for(Shipping_Location__c loc : [SELECT Id, Portfolio__c, Pricing_Cluster__c, Shipping_Location__c FROM Shipping_Location__c WHERE Portfolio__c IN: portfolioSet AND Pricing_Cluster__c !=: Nokia_CPQ_Constants.BLANK_STRING_WITHOUT_SPACE LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())])
						{
							
							if(String.isNotBlank(loc.Portfolio__c) && loc.Portfolio__c.equalsIgnoreCase(newProp.NokiaCPQ_Portfolio__c) && String.isNotBlank(loc.Pricing_Cluster__c) && loc.Pricing_Cluster__c.equalsIgnoreCase(newProp.NokiaCPQPricing_Cluster__c))
							{								
								newProp.NokiaCPQ_ShippingLocation__c = loc.Id;
							}
						}
					}
					
					if(prodFound && maintFound){
						noAccredFound = false;
					}
				}
				
				if(noAccredFound)
				{   
					newProp.addError(Nokia_CPQ_Constants.ERROR_ONE+newProp.NokiaCPQ_Portfolio__c);   
				} 
				//Heema : req 6383 Start
				if(newProp.NokiaCPQ_Is_Maintenance_Quote__c==false && newProp.Warranty_credit__c!=null){
					  newProp.addError(Nokia_CPQ_Constants.WARRANTYCREDIT);
				}
				 
				if(newProp.NokiaCPQ_Is_Maintenance_Quote__c==false && newProp.NokiaCPQ_Contract_Start_Date__c!=null){
					  newProp.addError(Nokia_CPQ_Constants.CONTRACTSTARTDATE);
				}
				 if(newProp.NokiaCPQ_Is_Maintenance_Quote__c==false && newProp.NokiaCPQ_Contract_Start_Date__c!=null && newProp.Warranty_credit__c!=null){
					  newProp.addError(Nokia_CPQ_Constants.WARRANTYCONTRACTSTARTDATE);
				}
				//Heema : req 6383 End
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
	  public static void checkBlankFieldsValidation(Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap, Map<Id, Apttus_Proposal__Proposal__c> proposalOldTriggerMap){
		
		Map<String,Nokia_CPQ_SSP_SRS_Default_Values__mdt> portfolioMetaMap = new Map<String,Nokia_CPQ_SSP_SRS_Default_Values__mdt>();
		Boolean isSSP = false;
		Boolean isSRS = false;
		try{
			for(Nokia_CPQ_SSP_SRS_Default_Values__mdt val : [SELECT Portfolio__c, SRS_Visible__c, SSP_Visible__c FROM Nokia_CPQ_SSP_SRS_Default_Values__mdt Limit: (Limits.getLimitQueryRows() - Limits.getQueryRows())]){
				portfolioMetaMap.put(val.Portfolio__c,val);
			}
			
			for(id proposalObjRecId: proposalNewTriggerMap.keySet()){
				if(proposalNewTriggerMap.get(proposalObjRecId).Quote_Type__c.equalsIgnoreCase(GlobalConstants.INDIRECT_QUOTE_TYPE) && portfolioMetaMap.get(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Portfolio__c) != null){
					isSSP = portfolioMetaMap.get(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Portfolio__c).SSP_Visible__c;
					isSRS = portfolioMetaMap.get(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Portfolio__c).SRS_Visible__c;
					
					
					System.debug('Id value '+portfolioMetaMap.get(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Portfolio__c));
					System.debug('Field value '+portfolioMetaMap.get(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Portfolio__c).SSP_Visible__c);
					System.debug('Next field alue '+portfolioMetaMap.get(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Portfolio__c).SRS_Visible__c);
					
					if(String.isEmpty(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_No_of_Years__c) ||
						String.isEmpty(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Maintenance_Type__c) ||
						String.isEmpty(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Existing_IONMaint_Contract__c) || 
						(isSSP && String.isEmpty(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_SSP_Level__c)) || 
						(isSRS && String.isEmpty(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_SRS_Level__c))
					){
						proposalNewTriggerMap.get(proposalObjRecId).addError(Nokia_CPQ_Constants.ERROR_TWO);
					}
					//Heema: 6383 Req Start
					if(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Is_Maintenance_Quote__c==false && proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Contract_Start_Date__c!=null){
						proposalNewTriggerMap.get(proposalObjRecId).addError(Nokia_CPQ_Constants.CONTRACTSTARTDATE);
					}
					if(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Is_Maintenance_Quote__c==false && proposalNewTriggerMap.get(proposalObjRecId).Warranty_credit__c!=null){
						proposalNewTriggerMap.get(proposalObjRecId).addError(Nokia_CPQ_Constants.WARRANTYCREDIT);
						
					}
					if(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Is_Maintenance_Quote__c==false && proposalNewTriggerMap.get(proposalObjRecId).Warranty_credit__c!=null && proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Contract_Start_Date__c!=null){
						proposalNewTriggerMap.get(proposalObjRecId).addError(Nokia_CPQ_Constants.WARRANTYCONTRACTSTARTDATE);
						
					}
					//Heema: 6383 Req Start
				}
			}
		}
		
		catch(Exception e){
			  ExceptionHandler.addException(e,ProposalTriggerHelper.class.getName(),Nokia_CPQ_Constants.QUOTE_NOT_FOUND);
		}
}

	/*********************************
	* author: YAN SHA SDCTeam
	* Date: 18 Jul 2018
	* Param: List<Apttus_Proposal__Proposal__c> quoteproposalList
	* Return: None
	* Description: methods insert the values of Maintenance SSP and SRS section when create the new quote
	* High Level Process :   
	**********************************/
	public static void InsertMaintenanceSSPandSRS(List<Apttus_Proposal__Proposal__c> quoteproposalList){
		try{
			String successmsg = Nokia_CPQ_Constants.FAIL_STRING;
			//List<Apttus_Proposal__Proposal__c> newproposalList = new List<Apttus_Proposal__Proposal__c>();
			List<Nokia_CPQ_Maintenance_type__mdt> metadataList = new List<Nokia_CPQ_Maintenance_type__mdt>();
			metadataList = [SELECT NokiaCPQ_Portfolio__c, NokiaCPQ_Maintenance_Pricing_Levels__c, Default_Value__c, Maintenance_Type__c FROM Nokia_CPQ_Maintenance_type__mdt Limit: (Limits.getLimitQueryRows() - Limits.getQueryRows())];
	  
			for(Nokia_CPQ_SSP_SRS_Default_Values__mdt sspSrsMetadata : [SELECT Portfolio__c, SSP_Default_Value__c, SRS_Default_Value__c, SRS_Visible__c, SSP_Visible__c FROM Nokia_CPQ_SSP_SRS_Default_Values__mdt Limit: (Limits.getLimitQueryRows() - Limits.getQueryRows())]){
		
				newMapSRS_SSP.put(sspSrsMetadata.Portfolio__c, sspSrsMetadata);
			}
	  
			for(Apttus_Proposal__Proposal__c newProp : quoteproposalList){
		
				string recordIDvar=newProp.ID;
				string maintstring=newProp.NokiaCPQ_Maintenance_Type__c;
				string existcontract=newProp.NokiaCPQ_Existing_IONMaint_Contract__c;
				string numyears=newProp.NokiaCPQ_No_of_Years__c;
				string planLevel=newProp.NokiaCPQ_SSP_Level__c;
				string releaseLevel=newProp.NokiaCPQ_SRS_Level__c;
				List<String> pricingLevelList = new List<String>();
				
				if(String.isBlank(maintstring)){
					String maintPricinglevel = Nokia_CPQ_Constants.BLANK_STRING_WITHOUT_SPACE;
					String defaultValue = Nokia_CPQ_Constants.BLANK_STRING_WITHOUT_SPACE;
					String portfolioVal = newProp.NokiaCPQ_Portfolio__c;
					
					maintPricinglevel = newProp.NokiaCPQ_Maintenance_Accreditation__r.Pricing_Accreditation__c;
					//system.debug('Maintenance level **' + maintPricinglevel);
					
					//if maintenance Pricing level does not contains brand or AED then set it as All Others
					if(!String.isBlank(maintPricinglevel) && !maintPricinglevel.contains(Nokia_CPQ_Constants.BRAND_STRING) 
					   && !maintPricinglevel.equalsIgnoreCase(Nokia_CPQ_Constants.AED_STRING)){
						maintPricinglevel = Nokia_CPQ_Constants.PRICING_LEVEL_ALL_OTHERS;
					}
								
					//retriving data from custom metadata to get picklist values
					for(Nokia_CPQ_Maintenance_type__mdt metadataRec : metadataList){
			
						pricingLevelList = metadataRec.NokiaCPQ_Maintenance_Pricing_Levels__c.split(Nokia_CPQ_Constants.SEMICOLON_STRING);
						
							if(!String.isBlank(maintPricinglevel) && metadataRec.NokiaCPQ_Portfolio__c.equals(portfolioVal) && pricingLevelList.contains(maintPricinglevel)){
								defaultValue = metadataRec.Default_Value__c;
								break;
							}
							
						
					}
					maintstring = defaultValue;
				}
			   
				if(!String.isBlank(existcontract)){
					if(!existcontract.equalsIgnoreCase(newProp.NokiaCPQ_Existing_IONMaint_Contract__c)){
						if(existcontract.equalsIgnoreCase(Nokia_CPQ_Constants.NO_STRING)){
							numyears = Nokia_CPQ_Constants.ONE_YEAR_STRING;
						}
						else if(existcontract.equalsIgnoreCase(Nokia_CPQ_Constants.YES_STRING)){
							numyears = Nokia_CPQ_Constants.THREE_YEAR_STRING;
						}
					}
				}
			
				if(String.isBlank(numyears)){
					if(existcontract.equalsIgnoreCase(Nokia_CPQ_Constants.NO_STRING)){
						numyears = Nokia_CPQ_Constants.ONE_YEAR_STRING;
					} else{
						numyears=newProp.NokiaCPQ_No_of_Years__c;
						if(String.isBlank(numyears)){
							numyears = Nokia_CPQ_Constants.THREE_YEAR_STRING;
						}
					}
				}	  
			
				if(String.isBlank(planLevel)){
					/*if(newProp.NokiaCPQ_Portfolio__c.equals(Nokia_CPQ_Constants.IP_ROUTING_STRING)){
						planLevel = Nokia_CPQ_Constants.SSP_DEFAULT_VALUE;
					}*/
					planLevel = sspsrsValueReturn(newProp.NokiaCPQ_Portfolio__c, Nokia_CPQ_Constants.NOKIA_SSP);
				}else if(!String.isBlank(planLevel)){
					if(planLevel.equalsIgnoreCase(Nokia_CPQ_Constants.NONE_STRING)){
						planLevel=null;
					}
				}
				
				if(String.isBlank(releaseLevel)){
				   /* if(newProp.NokiaCPQ_Portfolio__c.equals(Nokia_CPQ_Constants.IP_ROUTING_STRING)){
						releaseLevel = Nokia_CPQ_Constants.SRS_DEFAULT_VALUE;
					}*/
					releaseLevel = sspsrsValueReturn(newProp.NokiaCPQ_Portfolio__c, Nokia_CPQ_Constants.NOKIA_SRS);
				}else if(!String.isBlank(releaseLevel)){
					if(releaseLevel.equalsIgnoreCase(Nokia_CPQ_Constants.NONE_STRING)){
						releaseLevel=null;
					}
				} 
				
				newProp.NokiaCPQ_Maintenance_Type__c = maintstring;
				newProp.NokiaCPQ_Existing_IONMaint_Contract__c = existcontract;
				newProp.NokiaCPQ_SSP_Level__c = planLevel;
				newProp.NokiaCPQ_SRS_Level__c = releaseLevel;
				newProp.NokiaCPQ_No_of_Years__c = numyears;
		//newproposalList.add(newProp);
				
			}
	  
	 // upsert newproposalList;
		}
		catch(Exception e){
			ExceptionHandler.addException(e,ProposalTriggerHelper.class.getName(),Nokia_CPQ_Constants.QUOTE_NOT_FOUND);
		}
	}
	
	/*********************************
	* author: Accenture
	* Date: 27 MAR 2018
	* Param: String, String
	* Return: String
	* Description: return default value for ssp and srs 
	**********************************/
	public static String sspsrsValueReturn(String portfolio, String field){	   
		String defaultValue = Nokia_CPQ_Constants.BLANK_STRING_WITHOUT_SPACE; 
		try{
	  if(newMapSRS_SSP != null && newMapSRS_SSP.get(portfolio) != null){
		Nokia_CPQ_SSP_SRS_Default_Values__mdt metadataRec = newMapSRS_SSP.get(portfolio);
			
		if(field.equals(Nokia_CPQ_Constants.NOKIA_SSP)){
		  if(metadataRec.SSP_Visible__c){
			defaultValue = metadataRec.SSP_Default_Value__c;
		  }
		  else{
			defaultValue= null;
		  }
		}  
		else{
		  if(metadataRec.SRS_Visible__c){
			defaultValue = metadataRec.SRS_Default_Value__c;
		  }
		  else{
			defaultValue= null;
		  }
		}
	  }  
	  
		}
		catch(Exception e){
			ExceptionHandler.addException(e,quote_Maintenance_Picklist_handler.class.getName(),Nokia_CPQ_Constants.ERROR_MSD);   
		}
		return defaultValue;
	}

  /*********************************
	* author: Accenture
	* Date: 27 MAR 2018
	* Param: List<Apttus_Proposal__Proposal__c> proposalTriggerList
	* Return: None
	* Description: methods create the professional service record for the related quote 
	**********************************/
	public static void insertServiceRecord(List<Apttus_Proposal__Proposal__c> proposalNewTriggerList){
			
		//List<Apttus_Proposal__Proposal__c> validPropList = new List<Apttus_Proposal__Proposal__c>();
		Map<string,List<Apttus_Proposal__Proposal__c>> propMap = new Map<string,List<Apttus_Proposal__Proposal__c>>();
		List<Optional_Professional_Service__c>  quoteProfService = new List<Optional_Professional_Service__c>();
		List<Optional_Professional_Service__c>  existsQuoteProfService = new List<Optional_Professional_Service__c>();
		List<Optional_Services_Detail__c> optionalServiceDetails =  new List<Optional_Services_Detail__c>();
		Map<string,double> prodListPriceMap = new Map<string,double>();
		set<Id> accreRecordID = new set<Id>();
		set<Id> productRecordID = new set<Id>();
		set<Id> proposalId = new set<Id>();
		Optional_Professional_Service__c opsDetail;
		List<String> portfolioList = new List<String>();
		List<String> accreLevel = new List<String>();
		Map<Id,Boolean> nmsPropId = new Map<Id,Boolean>();
		Map<Id,Accreditation__c> accreMap =  new Map<Id,Accreditation__c>();
		Map<Id,Optional_Services_Detail__c> OptionServiceMap = new Map<Id,Optional_Services_Detail__c>();
		
		try{
			for(Apttus_Proposal__Proposal__c prop1 : proposalNewTriggerList){
				isSRS = false;
				portfolioList.add(prop1.NokiaCPQ_Portfolio__c); 
				accreRecordID.add(prop1.NokiaProductAccreditation__c);
				if((!isSRS && prop1.Is_SRS__c>0)){
					isSRS =  true;
				}
				nmsPropId.put(prop1.Id,isSRS);
			}
		
			existsQuoteProfService = [SELECT Id from Optional_Professional_Service__c where Quote_Proposal__c in :nmsPropId.keySet() LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())];
			
			for(Accreditation__c acc : [SELECT Id,Pricing_Accreditation__c from Accreditation__c where Id in :accreRecordID LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())]){
				accreMap.put(acc.Id, acc);
				if(String.isNotBlank(acc.Pricing_Accreditation__c)){
					accreLevel.add(acc.Pricing_Accreditation__c);
				}
			}
			//Map<Id,Accreditation__c> accreMap =  new Map<Id,Accreditation__c>([SELECT Id,Pricing_Accreditation__c from Accreditation__c where Id in :accreRecordID LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())]);
			
			for(Apttus_Proposal__Proposal__c prop2 : proposalNewTriggerList){
				if(prop2.NokiaProductAccreditation__c!=null){
					if(propMap.containsKey(accreMap.get(prop2.NokiaProductAccreditation__c).Pricing_Accreditation__c+Nokia_CPQ_Constants.NOKIA_UNDERSCORE+prop2.NokiaCPQ_Portfolio__c)){
						propMap.get(accreMap.get(prop2.NokiaProductAccreditation__c).Pricing_Accreditation__c+Nokia_CPQ_Constants.NOKIA_UNDERSCORE+prop2.NokiaCPQ_Portfolio__c).add(prop2);
					}
					else{
						propMap.put(accreMap.get(prop2.NokiaProductAccreditation__c).Pricing_Accreditation__c+Nokia_CPQ_Constants.NOKIA_UNDERSCORE+prop2.NokiaCPQ_Portfolio__c,new List<Apttus_Proposal__Proposal__c>{prop2});
					}
				}
			}
			//system.debug('propMap'+propMap);
			/*for(Accreditation__c acc : accreMap.values()){
				if(!String.IsEmpty(acc.Pricing_Accreditation__c)){
				accreLevel.add(acc.Pricing_Accreditation__c);
				}
			}*/
			//system.debug('portfolio'+portfolio);
			
			for(Optional_Services_Detail__c osd : [SELECT Id,Product__r.Id,Product__r.ProductCode,Product__r.Description,Product__r.Name,Portfolio__c, NMS__c,Accreditation_Level__c from Optional_Services_Detail__c where (Portfolio__c IN : portfolioList and Accreditation_Level__c IN :accreLevel) LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())]){
				productRecordID.add(osd.Product__r.Id);
				OptionServiceMap.put(osd.Id, osd);
			}
			
			/*optionalServiceDetails = [SELECT Id,Product__r.Id,Product__r.ProductCode,Product__r.Description,Portfolio__c, NMS__c,Accreditation_Level__c from Optional_Services_Detail__c where (Portfolio__c IN : portfolioList and Accreditation_Level__c IN :accreLevel) LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())];*/
			//system.debug('Query executed');
			//system.debug('optionalServiceDetails'+optionalServiceDetails);
			/*for(Optional_Services_Detail__c osd : optionalServiceDetails){
				productRecordID.add(osd.Product__r.Id);
			}*/
			//system.debug('productRecordID'+productRecordID);
			
			for(Apttus_Config2__PriceListItem__c pli : [select Apttus_Config2__ProductId__c,Apttus_Config2__ListPrice__c,Apttus_Config2__PriceListId__c,Apttus_Config2__PriceListId__r.CurrencyIsoCode,Apttus_Config2__ProductId__r.ProductCode from Apttus_Config2__PriceListItem__c where Apttus_Config2__ProductId__c in : productRecordID LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())]){
				if(!(prodListPriceMap.containsKey(pli.Apttus_Config2__ProductId__r.ProductCode + Nokia_CPQ_Constants.NOKIA_UNDERSCORE + pli.Apttus_Config2__PriceListId__r.CurrencyIsoCode))){
					prodListPriceMap.put(pli.Apttus_Config2__ProductId__r.ProductCode + Nokia_CPQ_Constants.NOKIA_UNDERSCORE + pli.Apttus_Config2__PriceListId__r.CurrencyIsoCode,pli.Apttus_Config2__ListPrice__c);
				}
			}
		
		
			for(Optional_Services_Detail__c ps : OptionServiceMap.values()){
				for(Apttus_Proposal__Proposal__c finalPro : propMap.get(ps.Accreditation_Level__c + Nokia_CPQ_Constants.NOKIA_UNDERSCORE + ps.Portfolio__c)){
					//system.debug('srs optional'+ps.NMS__c+'SRS quote'+nmsPropId.get(finalPro.Id));
					if(finalPro!=null && !nmsPropId.get(finalPro.Id) && ps.NMS__c==true) continue;
					
					opsDetail= new Optional_Professional_Service__c(CurrencyIsoCode = finalPro.CurrencyIsoCode,Product_Code__c = ps.Product__r.ProductCode, Product_Description__c = ps.Product__r.Description, List_Price__c = prodListPriceMap.get(ps.Product__r.ProductCode + Nokia_CPQ_Constants.NOKIA_UNDERSCORE + finalPro.CurrencyIsoCode),Quote_Proposal__c = finalPro.Id,NokiaCPQ_Product_Name__c = ps.Product__r.Name); 
					quoteProfService.add(opsDetail);   
				}
			}
						
			if(!existsQuoteProfService.isEmpty()){
				Database.delete(existsQuoteProfService,false); 
			}
			
			if(!quoteProfService.isEmpty()){
			   Database.SaveResult[] saveResultList = Database.insert(quoteProfService,false);
			}
		
		}catch (Exception e) {
			ExceptionHandler.addException(e,ProposalTriggerHelper.class.getName(),Nokia_CPQ_Constants.QUOTE_NOT_FOUND);
		}
	}
	
	/*********************************
	* Param: List<Apttus_Proposal__Proposal__c>
	* Return: None  
	**********************************/
	public static void associateDirectPriceList(List<Apttus_Proposal__Proposal__c> directQuoteList){
		
		Set<Id> oppIdSet = new Set<Id>();
		Map<Id,List<String>> opptyPriceListMap = new Map<Id,List<String>>();
		Set<String> uniquePLNameSet = new Set<String>();
		Map<Id,String> oppAndCurrencyMap = new Map<Id,String>();
		Map<String,Apttus_Config2__PriceList__c> pLNameAndNumberMap = new Map<String,Apttus_Config2__PriceList__c>();
		Map<String,String> globalPLMap = new Map<String,String>();
		String directPriceListNumber = Nokia_CPQ_Constants.BLANK_STRING_WITHOUT_SPACE;
		String priceListName = Nokia_CPQ_Constants.BLANK_STRING_WITHOUT_SPACE;
		
		for(Apttus_Proposal__Proposal__c prop : directQuoteList){
			if(prop.NokiaCPQ_Portfolio__c<>null && prop.NokiaCPQ_Portfolio__c<>'QTC')
			oppIdSet.add(prop.Apttus_Proposal__Opportunity__c);
		}
		
		if(!oppIdSet.isEmpty()){
			
			for(Apttus_Config2__PriceList__c priceL: [Select Id, Name, CurrencyIsoCode,Apttus_Config2__BasedOnPriceListId__c From Apttus_Config2__PriceList__c where PriceList_Type__c =: Nokia_CPQ_Constants.PLTYPE_CPQ AND Apttus_Config2__Active__c = true]){
				if(priceL.CurrencyIsoCode.contains(Nokia_CPQ_Constants.EUR_CURR)){
					globalPLMap.put(priceL.CurrencyIsoCode, priceL.Name);
				}
				else if(priceL.Apttus_Config2__BasedOnPriceListId__c != null){
					globalPLMap.put(priceL.CurrencyIsoCode, priceL.Name);
				}
			}
		
			//Fetch Applicable Price List field from associated account on Opportunity
			for(Opportunity opp : [SELECT Id, AccountId, Account.NokiaCPQ_Applicable_Price_Lists__c , CurrencyIsoCode FROM Opportunity WHERE Id IN: oppIdSet AND AccountId != null LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())]){
				if(String.isNotBlank(opp.Account.NokiaCPQ_Applicable_Price_Lists__c)){
					List<String> priceListNamesList = new List<String>();
					
					for(String str : opp.Account.NokiaCPQ_Applicable_Price_Lists__c.split(',')){
						priceListNamesList.add(str.trim());  
					}
					opptyPriceListMap.put(opp.Id,priceListNamesList);
					uniquePLNameSet.addAll(priceListNamesList);
				}
				oppAndCurrencyMap.put(opp.Id,opp.CurrencyIsoCode);
			}
			//system.debug('opptyPriceListMap**' + opptyPriceListMap);
			//system.debug('uniquePLNameSet**' + uniquePLNameSet);
			
			//if(!uniquePLNameSet.isEmpty()){
				for(Apttus_Config2__PriceList__c plist : [Select Id,NokiaCPQ_Name__c,Project_Price_List_Number__c,CurrencyIsoCode From Apttus_Config2__PriceList__c Where Apttus_Config2__Active__c = true AND PriceList_Type__c =: Nokia_CPQ_Constants.PLTYPE_DIRECT AND NokiaCPQ_Name__c IN: uniquePLNameSet]){
					pLNameAndNumberMap.put(plist.NokiaCPQ_Name__c,plist);
				}
				
			   // system.debug('pLNameAndNumberMap**' + pLNameAndNumberMap);
				
				for(Apttus_Proposal__Proposal__c prop : directQuoteList){
					directPriceListNumber = Nokia_CPQ_Constants.BLANK_STRING_WITHOUT_SPACE;
					priceListName = Nokia_CPQ_Constants.BLANK_STRING_WITHOUT_SPACE;
					if(opptyPriceListMap != null && opptyPriceListMap.containsKey(prop.Apttus_Proposal__Opportunity__c)){
						for(String plName : opptyPriceListMap.get(prop.Apttus_Proposal__Opportunity__c)){
							if(String.isNotBlank(plName) && oppAndCurrencyMap != null && pLNameAndNumberMap != null && pLNameAndNumberMap.containsKey(plName) && pLNameAndNumberMap.get(plName).CurrencyIsoCode == oppAndCurrencyMap.get(prop.Apttus_Proposal__Opportunity__c)){
								directPriceListNumber = directPriceListNumber + pLNameAndNumberMap.get(plName).Project_Price_List_Number__c + Nokia_CPQ_Constants.NOKIA_COMMA;
								priceListName = priceListName + pLNameAndNumberMap.get(plName).NokiaCPQ_Name__c + Nokia_CPQ_Constants.NOKIA_COMMA;
							}
						}
						//system.debug('directPriceListNumber**' + directPriceListNumber);
						//system.debug('priceListName**' + priceListName);
						
						if(String.isNotBlank(directPriceListNumber) && String.isNotBlank(priceListName)){
							prop.Direct_Price_List_Number__c = directPriceListNumber.removeEnd(Nokia_CPQ_Constants.NOKIA_COMMA);
							prop.Price_List__c = priceListName.removeEnd(Nokia_CPQ_Constants.NOKIA_COMMA);
						}
						else{
							prop.Price_List__c = globalPLMap.get(oppAndCurrencyMap.get(prop.Apttus_Proposal__Opportunity__c));
						}
					}
					else{
						prop.Price_List__c = globalPLMap.get(oppAndCurrencyMap.get(prop.Apttus_Proposal__Opportunity__c));
					}
				}   
			//}
		}
	}
	/*********************************
* author: Accenture
* Date: 23 Aug 2019
* Param: List<Apttus_Proposal__Proposal__c> newQuote
* Return: None
* Description: Update Quote Expiry Date
* High Level Process :   
**********************************/
	public static void updateQuoteExpiryDate( List<Apttus_Proposal__Proposal__c> newQuote){
		try{
			
			for(Apttus_Proposal__Proposal__c quote : newQuote){
				if(quote.Quote_Type__c.equalsignorecase(Nokia_CPQ_Constants.QUOTE_TYPE_INDIRECTCPQ)){
					
					quote.Apttus_Proposal__Proposal_Expiration_Date__c = system.today()+30;
					quote.NokiaCPQQuote_Start_Date__c = system.today();
					
				}
				else if(quote.Quote_Type__c.equalsignorecase(Nokia_CPQ_Constants.QUOTE_TYPE_DIRECTCPQ))
				{
					quote.Apttus_Proposal__Proposal_Expiration_Date__c = system.today()+90;
					quote.NokiaCPQQuote_Start_Date__c = system.today();
				}
			}
		}
		catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHelper.class.getName(),'Line number '+ex.getLineNumber());
		}	 
	}
	/*********************************
* Param: List<Apttus_Proposal__Proposal__c>
* Return: None  
**********************************/
	public static void updateQuoteRecordTypeIndirect(List<Apttus_Proposal__Proposal__c> indirectQuotesList){
		
		Set<String> oppIdSet = new Set<String>();
		Map<String,String> oppIdAndStageMap = new Map<String,String>();
		
		String draftRecordTypeId = Label.NokiaCPQ_Indirect_Draft;
		String inReviewRecordTypeId = Label.NokiaCPQ_Indirect_InReview;
		String approvedRecordTypeId = Label.NokiaCPQ_Indirect_Approved;
		String expiredRecordTypeId = Label.NokiaCPQ_Indirect_Expired;
		String closedRecordTypeId = Label.NokiaCPQ_Indirect_Closed;
		String defaultRecordTypeId = Label.NokiaCPQ_Indirect_Draft_Default;
		
		system.debug('Indirect record type id ->' + draftRecordTypeId + ' In review-> ' + inReviewRecordTypeId);
		
		for(Apttus_Proposal__Proposal__c prop : indirectQuotesList){
			oppIdSet.add(prop.Apttus_Proposal__Opportunity__c);
		}
		
		for(Opportunity opp : [SELECT Id, StageName FROM Opportunity WHERE Id IN: oppIdSet]){
			oppIdAndStageMap.put(opp.Id,opp.StageName);
		}
		
		for(Apttus_Proposal__Proposal__c prop : indirectQuotesList){
			if(prop.Apttus_Proposal__Approval_Stage__c != null && (prop.Apttus_Proposal__Approval_Stage__c == 'Draft' || prop.Apttus_Proposal__Approval_Stage__c == 'Rejected' || prop.Apttus_Proposal__Approval_Stage__c == 'Approval Required') && prop.Apttus_Proposal__Opportunity__c != null && (oppIdAndStageMap.get(prop.Apttus_Proposal__Opportunity__c) == 'Create Offer (Bid)' || oppIdAndStageMap.get(prop.Apttus_Proposal__Opportunity__c) == 'Win the Case (Negotiate)') && prop.Reprice_In_Progress__c == false){
				prop.RecordTypeId =  draftRecordTypeId;
			}
			else if(prop.Apttus_Proposal__Approval_Stage__c != null && prop.Apttus_Proposal__Approval_Stage__c == 'In Review'  && prop.Reprice_In_Progress__c == false){
				prop.RecordTypeId =  inReviewRecordTypeId;
			}
			else if(prop.Apttus_Proposal__Approval_Stage__c != null && (prop.Apttus_Proposal__Approval_Stage__c == 'Approved' || prop.Apttus_Proposal__Approval_Stage__c == 'Generated' || prop.Apttus_Proposal__Approval_Stage__c == 'Accepted')){
				prop.RecordTypeId =  approvedRecordTypeId;
			}
			else if(prop.Apttus_Proposal__Approval_Stage__c != null && prop.Apttus_Proposal__Approval_Stage__c == 'Expired'){
				prop.RecordTypeId =  expiredRecordTypeId;
			}
			else if(prop.Apttus_Proposal__Approval_Stage__c != null && prop.Apttus_Proposal__Approval_Stage__c == 'Closed (Not Won)'){
				prop.RecordTypeId =  closedRecordTypeId;
			}
			else if(prop.Reprice_In_Progress__c == false ){
				prop.RecordTypeId =  defaultRecordTypeId;
			}
			
		}
	}
	/*********************************
* author: Accenture
* Date: 26 Aug 2019
* Param: List<Apttus_Proposal__Proposal__c> newQuote
* Return: None
* Description: updateListPriceIONDirect
* High Level Process :   
**********************************/
	public static void updateListPriceIONDirect( List<Apttus_Proposal__Proposal__c> newQuote){
		try{ 
			//priyanka: Move Process Builder (DS Update Quote Approval Stage + ION Direct Is List Price Only) only for direct CPQ logic
			 //Chetan: This code is written to update "Software Release Subscription Level" AND "Software Subscription Plan Level" to "Update" on Q/P for EP 
			for(Nokia_CPQ_SSP_SRS_Default_Values__mdt sspSrsMetadata : [SELECT Portfolio__c, SSP_Default_Value__c, SRS_Default_Value__c, SRS_Visible__c, SSP_Visible__c FROM Nokia_CPQ_SSP_SRS_Default_Values__mdt Limit: (Limits.getLimitQueryRows() - Limits.getQueryRows())]){
		
				newMapSRS_SSP.put(sspSrsMetadata.Portfolio__c, sspSrsMetadata);
			}
			List<Apttus_Proposal__Proposal__c> propListION = new List<Apttus_Proposal__Proposal__c>(); 
			Boolean hasCustomPermission = FeatureManagement.checkPermission(Nokia_CPQ_Constants.CPQ_GSS_User);
			system.debug('hasCustomPermission  '+hasCustomPermission);
			for(Apttus_Proposal__Proposal__c proposal : newQuote){
			//Chetan: added for EP requirement
					string ssplevel  = proposal.NokiaCPQ_SSP_Level__c;
					string srslevel  = proposal.NokiaCPQ_SRS_Level__c;
					if(String.isBlank(ssplevel)){
						/*if(newProp.NokiaCPQ_Portfolio__c.equals(Nokia_CPQ_Constants.IP_ROUTING_STRING)){
							planLevel = Nokia_CPQ_Constants.SSP_DEFAULT_VALUE;
						}*/
						ssplevel = sspsrsValueReturn(proposal.NokiaCPQ_Portfolio__c, Nokia_CPQ_Constants.SSP_DEFAULT_VALUE);
					}else if(!String.isBlank(ssplevel)){
						if(ssplevel.equalsIgnoreCase(Nokia_CPQ_Constants.NONE_STRING)){
							ssplevel=null;
						}
					}
				
					if(String.isBlank(srslevel)){
					   /* if(newProp.NokiaCPQ_Portfolio__c.equals(Nokia_CPQ_Constants.IP_ROUTING_STRING)){
							releaseLevel = Nokia_CPQ_Constants.SRS_DEFAULT_VALUE;
						}*/
						srslevel = sspsrsValueReturn(proposal.NokiaCPQ_Portfolio__c, Nokia_CPQ_Constants.SRS_DEFAULT_VALUE);
					}else if(!String.isBlank(srslevel)){
						if(srslevel.equalsIgnoreCase(Nokia_CPQ_Constants.NONE_STRING)){
							srslevel=null;
						}
					} 
				if(hasCustomPermission &&(proposal.NokiaCPQ_Portfolio__c == 'IP Routing'||proposal.NokiaCPQ_Portfolio__c == 'Optics'||
										  proposal.NokiaCPQ_Portfolio__c == 'Nuage'||proposal.NokiaCPQ_Portfolio__c == 'Optics - Wavelite')
				   &&(!proposal.Is_List_Price_Only__c)){
					   proposal.Is_List_Price_Only__c = true;
				   }
				   //Till here
				else if(proposal.NokiaCPQ_Portfolio__c == 'IP Routing' && (!proposal.Is_List_Price_Only__c) && proposal.Quote_Type__c =='Direct CPQ')
				{
					proposal.NokiaCPQ_SRS_Level__c = srslevel;
					system.debug('proposal.NokiaCPQ_SRS_Level__c-->> '+ssplevel);
					proposal.NokiaCPQ_SSP_Level__c = ssplevel;
					system.debug('proposal.NokiaCPQ_SSP_Level__c-->> '+ssplevel);
				}
			//Chetan: "END"
			}
			
		}
		catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHelper.class.getName(),'Line number '+ex.getLineNumber());
		}	 
		
	}	
	/*********************************
* Param: List<Apttus_Proposal__Proposal__c>
* Return: None  
**********************************/
	public static void updateQuoteRecordType(List<Apttus_Proposal__Proposal__c> directQuotesList){
		
		Set<String> oppIdSet = new Set<String>();
		Map<String,String> oppIdAndStageMap = new Map<String,String>();
		
		String draftRecordTypeId = Label.NokiaCPQ_DirectQuoteID;
		String readOnlyRecordTypeId = Label.NokiaCPQ_DirectReadOnlyQuoteID;
		
		system.debug('direct record type id' + draftRecordTypeId + ' read only-> ' + readOnlyRecordTypeId);
		
		for(Apttus_Proposal__Proposal__c prop : directQuotesList){
			oppIdSet.add(prop.Apttus_Proposal__Opportunity__c);
		}
		
		for(Opportunity opp : [SELECT Id, StageName FROM Opportunity WHERE Id IN: oppIdSet]){
			oppIdAndStageMap.put(opp.Id,opp.StageName);
		}
		
		for(Apttus_Proposal__Proposal__c prop : directQuotesList){
			if(prop.Apttus_Proposal__Approval_Stage__c != null && (prop.Apttus_Proposal__Approval_Stage__c == 'Draft' || prop.Apttus_Proposal__Approval_Stage__c == 'Rejected' || prop.Apttus_Proposal__Approval_Stage__c == 'Denied' || prop.Apttus_Proposal__Approval_Stage__c == 'Approval Required') && prop.Apttus_Proposal__Opportunity__c != null && (oppIdAndStageMap.get(prop.Apttus_Proposal__Opportunity__c) == 'Create Offer (Bid)' || oppIdAndStageMap.get(prop.Apttus_Proposal__Opportunity__c) == 'Win the Case (Negotiate)') && prop.RecordTypeId != draftRecordTypeId){
				prop.RecordTypeId =  draftRecordTypeId;
			}
			else if(prop.Apttus_Proposal__Approval_Stage__c != null && (prop.Apttus_Proposal__Approval_Stage__c == 'In Review' || prop.Apttus_Proposal__Approval_Stage__c == 'Approved' || prop.Apttus_Proposal__Approval_Stage__c == 'Accepted' || prop.Apttus_Proposal__Approval_Stage__c == 'Expired' || prop.Apttus_Proposal__Approval_Stage__c == 'Closed (Not Won)') && prop.RecordTypeId != readOnlyRecordTypeId){
				prop.RecordTypeId =  readOnlyRecordTypeId;
			}
		}
	}
	/*********************************
* author: Accenture
* Date: 28 Aug 2019
* Param: proposalNewTriggerMap, proposalOldTriggerMap)
* Return: None
* Description: quoteCancelIndirect
* High Level Process :   
* //Added by priyanka : Process builder Quote Updates When Opportunity is Changed
**********************************/   
	public static void quoteCancelIndirect(Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap, Map<Id, Apttus_Proposal__Proposal__c> proposalOldTriggerMap){
		try{
			for(id proposalObjRecId: proposalNewTriggerMap.keySet()){
				if(proposalNewTriggerMap.get(proposalObjRecId).Quote_Type__c.equalsIgnoreCase(GlobalConstants.INDIRECT_QUOTE_TYPE)){									  
					
					if((proposalOldTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c == 'Approved' || 
						proposalOldTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c == 'Accepted') && 
					   proposalNewTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c == 'Draft'){
						   
						   proposalNewTriggerMap.get(proposalObjRecId).Apttus_Proposal__Proposal_Expiration_Date__c = null;
						   proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQQuote_Start_Date__c = null;		  
					   }
				}else if(proposalNewTriggerMap.get(proposalObjRecId).Quote_Type__c.equalsIgnoreCase(GlobalConstants.DIRECT_QUOTE_TYPE))
				{
					if((proposalOldTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c == 'In Review' || 
						proposalOldTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c == 'Accepted' || proposalOldTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c == 'Approved' )&&  proposalNewTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c == 'Draft')
					  {
						  proposalNewTriggerMap.get(proposalObjRecId).Offer__c= null;
					  }
				
				}
				
			}
		}
		catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHelper.class.getName(),'Line number '+ex.getLineNumber());
			
		}
	}
	/*********************************
* author: Accenture
* Date: 28 Aug 2019
* Param: proposalNewTriggerMap, proposalOldTriggerMap)
* Return: None
* Description: quoteCancelIndirect
* High Level Process :   
* //Added by priyanka : Process builder Quote Updates When Opportunity is Changed
**********************************/   
public static void updateRepriseOnMaintChange(Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap, Map<Id, Apttus_Proposal__Proposal__c> proposalOldTriggerMap){
		try{
			for(id proposalObjRecId: proposalNewTriggerMap.keySet()){
				if(proposalNewTriggerMap.get(proposalObjRecId).Quote_Type__c.equalsIgnoreCase(GlobalConstants.INDIRECT_QUOTE_TYPE)){									  
					
					if((proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_Existing_IONMaint_Contract__c != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Existing_IONMaint_Contract__c || 
						proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_SSP_Level__c != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_SSP_Level__c  || 
						proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_SRS_Level__c != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_SRS_Level__c  ||
						proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_No_of_Years__c != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_No_of_Years__c  ||
						proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_Maintenance_Type__c != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Maintenance_Type__c  ||
						proposalOldTriggerMap.get(proposalObjRecId).Maintenance_Y1__c != proposalNewTriggerMap.get(proposalObjRecId).Maintenance_Y1__c  ||
						proposalOldTriggerMap.get(proposalObjRecId).Maintenance_Y2__c != proposalNewTriggerMap.get(proposalObjRecId).Maintenance_Y2__c  ||
						proposalOldTriggerMap.get(proposalObjRecId).SSP__c != proposalNewTriggerMap.get(proposalObjRecId).SSP__c  ||
						proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_LEO_Discount__c != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_LEO_Discount__c || 
						proposalOldTriggerMap.get(proposalObjRecId).Warranty_credit__c != proposalNewTriggerMap.get(proposalObjRecId).Warranty_credit__c ||
						proposalOldTriggerMap.get(proposalObjRecId).SRS__c != proposalNewTriggerMap.get(proposalObjRecId).SRS__c) &&
						proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Net_Amount_Quote__c > 0){
						   
						   //LEO QUOTE CHECK ADDED BY RG: FOR REPRICE NokiaCPQ_LEO_Discount__c
						   proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Needs_Reprice__c = True;
					   }
					   
						 //Defect 13865 heema
					   if(proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_LEO_Discount__c != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_LEO_Discount__c){
						   proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Prior_Leo_Value__c = proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_LEO_Discount__c;
					   }
					   //Defect 13889 heema
						 if(proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_No_of_Years__c != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_No_of_Years__c){
						   proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Prior_Number_of_years__c = proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_No_of_Years__c;
					   }
				}
				else if(proposalNewTriggerMap.get(proposalObjRecId).Quote_Type__c.equalsIgnoreCase(GlobalConstants.DIRECT_QUOTE_TYPE))
				{
					if( (proposalOldTriggerMap.get(proposalObjRecId).Exchange_Rate__c != proposalNewTriggerMap.get(proposalObjRecId).Exchange_Rate__c &&
						 proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Total_CNP__c > 0)  || 
					   ( proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Portfolio__c  == 'IP Routing' && !proposalNewTriggerMap.get(proposalObjRecId).Is_List_Price_Only__c &&
						(proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_SSP_Level__c != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_SSP_Level__c ||
						 proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_SRS_Level__c != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_SRS_Level__c ||
						 proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_No_of_Years__c != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_No_of_Years__c ||
						 proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_Maintenance_Type__c != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Maintenance_Type__c ||
						 proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_Existing_IONMaint_Contract__c != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Existing_IONMaint_Contract__c))
					  ){
							proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Needs_Reprice__c = True;
						   system.debug('reprice field --'+proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Needs_Reprice__c );
					   }
			   
			   // Priyanka :Moved workflow (Needs Reprice is True   )
				else if(proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Portfolio__c  == 'Airscale Wifi' &&
					   (proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_Maintenance_Type__c  != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Maintenance_Type__c   ||
						proposalOldTriggerMap.get(proposalObjRecId).NokiaCPQ_No_of_Years__c  != proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_No_of_Years__c  ))
				{
						proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Needs_Reprice__c = True;

				}
			}
			}
		}
		catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHelper.class.getName(),'Line number '+ex.getLineNumber());
		}
}
	/*********************************
* Param: Map<Id, Apttus_Proposal__Proposal__c>, Map<Id, Apttus_Proposal__Proposal__c>
* Return: None 
* Method Name: updateContractNameOnQuote 
**********************************/
	public static void updateContractNameOnQuote(List<Apttus_Proposal__Proposal__c> quoteList){
		try{
			
			Set<Id> accIds = new Set<Id>();
			String contractNames = '';
			List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
			List<Apttus_Proposal__Proposal__c> proposalListToUpdate = new List<Apttus_Proposal__Proposal__c>();
			Map<Id,List<Contract>> accIdToContractMap = new Map<Id,List<Contract>>();
			List<Contract> contractList = new List<Contract>();
			Map<Id,String> accountIdToPPAContractNameMap = new Map<Id,String>();
			Map<Id,String> accountIdToPMAContractNameMap = new Map<Id,String>();
			if(!quoteList.isEmpty())
			{
				for(Apttus_Proposal__Proposal__c proposal : quoteList)
				{
						   accIds.add(proposal.Apttus_Proposal__Account__c);
					   
				}
				system.debug('accIds==='+accIds);
				if(accIds.size() > 0)
				{
					for(Contract cont : [Select Id,AccountId,Name,NokiaCPQ_Is_Product_Agreement__c,
										 NokiaCPQ_Is_Maintenance_Agreement__c,NokiaCPQ_Sub_Contract_Type__c,
										 Status,StartDate,EndDate   
										 From Contract where AccountId in : accIds and NokiaCPQ_Sub_Contract_Type__c = 'Primary' and
										 Status = 'Activated'
										 LIMIT: Limits.getLimitQueryRows() - Limits.getQueryRows()])
					{
						if(accIdToContractMap.containsKey(cont.AccountId))
						{
							contractList = new List<Contract>();
							contractList = accIdToContractMap.get(cont.AccountId);
							contractList.add(cont);
							accIdToContractMap.put(cont.AccountId,contractList);
						}
						else{
							contractList = new List<Contract>();
							contractList.add(cont);
							accIdToContractMap.put(cont.AccountId,contractList);
						}
					}
					
				}
				 system.debug('accIdToContractMap==='+accIdToContractMap);
				for(Apttus_Proposal__Proposal__c proposal : quoteList)
				{
					String ppaContract = '';
					String pmaContract = '';
					if(accIdToContractMap.containsKey(proposal.Apttus_Proposal__Account__c)){
						for(Contract cont : accIdToContractMap.get(proposal.Apttus_Proposal__Account__c))
						{
							if(cont.StartDate <=proposal.NokiaCPQQuote_Start_Date__c &&
							   cont.EndDate >= proposal.NokiaCPQQuote_Start_Date__c && cont.NokiaCPQ_Is_Product_Agreement__c)
							{	 
								if(String.isBlank(ppaContract))
									ppaContract = cont.Name;
								else
									ppaContract = ppaContract + Nokia_CPQ_Constants.SEMICOLON_STRING + cont.Name;
							}
							if(cont.StartDate <=proposal.NokiaCPQQuote_Start_Date__c &&
							   cont.EndDate >= proposal.NokiaCPQQuote_Start_Date__c && cont.NokiaCPQ_Is_Maintenance_Agreement__c)
							{
								if(String.isBlank(pmaContract))
									pmaContract = cont.Name;
								else
									pmaContract = pmaContract + Nokia_CPQ_Constants.SEMICOLON_STRING + cont.Name;
							}
						}
					}
					//Apttus_Proposal__Proposal__c proposalRec = new Apttus_Proposal__Proposal__c(Id=proposal.Id);
					proposal.NokiaCPQ_PPA_Contract_Name__c = ppaContract;
					proposal.NokiaCPQ_PMA_Contract_Name__c = pmaContract;
							system.debug('ppaContract--'+ppaContract+'   '+'pmaContract--'+ pmaContract );
				}

			}
		   // if(!proposalListToUpdate.isEmpty())
			 //   database.update(proposalListToUpdate);
		}
		catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHelper.class.getName(),'Line number '+ex.getLineNumber());
		} 
	}
	/*********************************
* author: Accenture
* Date: 28 Aug 2019
* Param: proposalNewTriggerMap, proposalOldTriggerMap)
* Return: None
* Description: quoteCancelIndirect
* High Level Process :   
* //Added by priyanka : Process builder Quote Updates When Opportunity is Changed
**********************************/   
	public static void quoteStatusToValidate(List<Apttus_Proposal__Proposal__c> newquote){
		try{ 
			//priyanka: Move WorkFlow (Change Quote Status from 'Price' to 'Validate') only for direct CPQ logic
			List<Apttus_Proposal__Proposal__c> propList = new List<Apttus_Proposal__Proposal__c>();
			 system.debug('propList-- before update'+propList);
			for(Apttus_Proposal__Proposal__c proposal :[select id ,Roll_Up_Of_Proposal_Line_Item__c,Quote_Status__c from Apttus_Proposal__Proposal__c where id IN : newquote] ){
					   proposal.Quote_Status__c = 'Validate';
					   propList.add(proposal);
					system.debug('prop list--'+propList);
		}	
			database.update(propList);
	   
		}
		catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHelper.class.getName(),'Line number '+ex.getLineNumber());
		}   
	}   
	/*********************************
* author: Accenture
* Date: 26 Aug 2019
* Param: List<Apttus_Proposal__Proposal__c> newQuote
* Return: None
* Description: updateListPriceIONDirect
* High Level Process :   
**********************************/
	public static void updateIndirectOnOppChange( List<Apttus_Proposal__Proposal__c> newQuote){
		try{ 
			Set<Id> opptySet = new Set<Id>();
			List<Apttus_Proposal__Proposal__c> quotelist= new List<Apttus_Proposal__Proposal__c>();

			
			for(Apttus_Proposal__Proposal__c objQuote: newQuote )
			{
				opptySet.add(objQuote.Apttus_Proposal__Opportunity__c);		 
			}
			
			// Collect Oppty rec 
			Map<Id, Opportunity> opptyRecMap = new Map<Id, Opportunity>([select id, NokiaCPQ_Quote_Count__c,CurrencyIsoCode from Opportunity where Id =:opptySet LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows())]);
			
			for(Opportunity opp : opptyRecMap.values()){
				opp.NokiaCPQ_Quote_Count__c = opp.NokiaCPQ_Quote_Count__c+1;
				opptyRecMap.put(opp.id, opp);
			}
			database.update(opptyRecMap.values(),false);
			
			system.debug('values of opp'+ opptyRecMap.values()+ 'key' + opptyRecMap.values());
			
			List<Custom_Constant_Field__c> customConstantField = new List<Custom_Constant_Field__c>([select DOD__c,DPD__c from Custom_Constant_Field__c]);
			
			for(Apttus_Proposal__Proposal__c objQuote: [select id ,NokiaCPQ_Proposal_Id__c,Apttus_Proposal__Opportunity__r.Opportunity_ID__c,NokiaCPQ_DOD_Per__c, CurrencyIsoCode,
													   NokiaCPQ_DPD_Per__c ,Apttus_Proposal__Opportunity__r.CurrencyIsoCode,Apttus_Proposal__Opportunity__r.NokiaCPQ_Quote_Count__c
													   ,NokiaCPQ_Partner_Sales_Manager__c,Apttus_Proposal__Opportunity__r.End_Customer__c,Apttus_Proposal__Opportunity__r.Account.Partner_Type__c,
														Apttus_Proposal__Opportunity__r.PRMDeal_Origination_Discount_Status__c,
													   Apttus_Proposal__Opportunity__r.OwnerId from Apttus_Proposal__Proposal__c where id in : newQuote]){
														   
				objQuote.NokiaCPQ_Proposal_Id__c = objQuote.Apttus_Proposal__Opportunity__r.Opportunity_ID__c + ' ' + 'Q' +' '+ objQuote.Apttus_Proposal__Opportunity__r.NokiaCPQ_Quote_Count__c ; 
				system.debug('opportunity id -name '+objQuote.Apttus_Proposal__Opportunity__r.Opportunity_ID__c);
				system.debug('quote id **'+ objQuote.NokiaCPQ_Proposal_Id__c);
				objQuote.CurrencyIsoCode = objQuote.Apttus_Proposal__Opportunity__r.CurrencyIsoCode;
				if(objQuote.Apttus_Proposal__Opportunity__r.PRMDeal_Origination_Discount_Status__c == 'Approved with DOD'){
						objQuote.NokiaCPQ_DOD_Per__c = double.valueof(customConstantField[0].DOD__c);
				}
				else {
						objQuote.NokiaCPQ_DOD_Per__c = 0;
				}
				if(objQuote.Apttus_Proposal__Opportunity__r.PRMDeal_Origination_Discount_Status__c == 'Approved with DOD' && objQuote.Apttus_Proposal__Opportunity__r.Account.Partner_Type__c == 'Distributor'){
					  
					  objQuote.NokiaCPQ_DPD_Per__c = double.valueof(customConstantField[0].DPD__c);
				}
				else {
					objQuote.NokiaCPQ_DPD_Per__c = 0;
				}
				
				objQuote.NokiaCPQ_End_Customer__c = objQuote.Apttus_Proposal__Opportunity__r.End_Customer__c;
				objQuote.NokiaCPQ_Partner_Sales_Manager__c = objQuote.Apttus_Proposal__Opportunity__r.OwnerId; 
					quotelist.add(objQuote); 
			}
			database.update(quotelist,false);
			system.debug('values of quotelist'+ quotelist);
			
			List<Apttus_Proposal__Proposal_Line_Item__c> propLineItems = new List<Apttus_Proposal__Proposal_Line_Item__c>();
			for(Apttus_Proposal__Proposal_Line_Item__c pItem: [Select id  from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c IN : newQuote] )
			{
				pItem.NokiaCPQ_Opportunity_Site__c = null; 
				propLineItems.add(pItem);
			}
			if(!propLineItems.isEmpty()){
				database.update(propLineItems,false);
				
			}
			List<Apttus_Config2__ProductConfiguration__c> quoteConfig = new List<Apttus_Config2__ProductConfiguration__c>();
			for(Apttus_Config2__ProductConfiguration__c prodConfig: [Select id  from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c IN : newQuote] )
			{
				prodConfig.NokiaCPQ_Quote_Opportunity_Changed__c = True;  
				quoteConfig.add(prodConfig);
			}
			if(!quoteConfig.isEmpty()){
				database.update(quoteConfig,false);
				
			}
			system.debug('values of quoteConfig'+ quoteConfig);
			
			//database.update(newQuote,false);
			//system.debug('values of newQuote'+ newQuote);
			
		   
			
		}
		catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHelper.class.getName(),'Line number '+ex.getLineNumber());
		}	 
	}	
	 /*********************************
	* Param: Map<Id, Apttus_Proposal__Proposal__c>, Map<Id, Apttus_Proposal__Proposal__c>
	* Return: None  
	* This method is written in order to update the quote stage if any service override is there
	**********************************/
  public static void approvalRequiredChangeStatus(Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap, Map<Id, Apttus_Proposal__Proposal__c> proposalOldTriggerMap){
  List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItem = new List<Apttus_Proposal__Proposal_Line_Item__c>();
  proposalLineItem =  [Select id from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c in :proposalNewTriggerMap.keySet() and is_Custom_Product__c = true limit 1];
  try{
  
  for(id proposalObjRecId: proposalNewTriggerMap.keySet()){
	 if(proposalNewTriggerMap.get(proposalObjRecId).Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_INDIRECTCPQ)){ //&& proposalOldTriggerMap.get(proposalObjRecId).Apttus_QPConfig__ConfigurationFinalizedDate__c!=proposalNewTriggerMap.get(proposalObjRecId).Apttus_QPConfig__ConfigurationFinalizedDate__c
		if(proposalNewTriggerMap.get(proposalObjRecId).Apttus_QPConfig__ConfigurationFinalizedDate__c!=null && proposalNewTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c =='Draft'){
			if(proposalNewTriggerMap.get(proposalObjRecId).Maintenance_Y1__c > 0 || proposalNewTriggerMap.get(proposalObjRecId).Maintenance_Y2__c>0 || proposalNewTriggerMap.get(proposalObjRecId).SSP__c>0 || proposalNewTriggerMap.get(proposalObjRecId).SRS__c>0 || proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_LEO_Discount__c==true|| proposalNewTriggerMap.get(proposalObjRecId).NokiaCPQ_Quote_CAD__c>0 || proposalLineItem.Size()>0){
			proposalNewTriggerMap.get(proposalObjRecId).Apttus_Proposal__Approval_Stage__c = 'Approval Required';
			}
		
		}
	 }
  }
  }
 catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHelper.class.getName(),Nokia_CPQ_Constants.QUOTE_NOT_FOUND);
		} 
  } 
  
   /*********************************
	* Author : Rahul Garje COE
	* Param: List<Apttus_Proposal__Proposal__c> newQuote
	* Return: None  
	* This method is written in order to update the Indirect Quote Approval check field to false if non of the criteria for approval matches
	**********************************/
	 public static void updateIndirectApprovalCheck(Map<Id, Apttus_Proposal__Proposal__c> proposalNewTriggerMap){
	   List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItem = new List<Apttus_Proposal__Proposal_Line_Item__c>();
	   proposalLineItem =  [Select id from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c in :proposalNewTriggerMap.keySet() and is_Custom_Product__c = true limit 1];
		try{ 
			System.debug('proposalNewTriggerMap-->'+proposalNewTriggerMap);
			for(id proposalRecId: proposalNewTriggerMap.keySet()){
				if(proposalNewTriggerMap.get(proposalRecId).Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_INDIRECTCPQ)){
					if(proposalNewTriggerMap.get(proposalRecId).Apttus_QPConfig__ConfigurationFinalizedDate__c!=null){
						if(proposalNewTriggerMap.get(proposalRecId).Maintenance_Y1__c== null && proposalNewTriggerMap.get(proposalRecId).Maintenance_Y2__c== null && proposalNewTriggerMap.get(proposalRecId).SSP__c== null && proposalNewTriggerMap.get(proposalRecId).SRS__c== null && proposalNewTriggerMap.get(proposalRecId).NokiaCPQ_LEO_Discount__c == false && proposalNewTriggerMap.get(proposalRecId).NokiaCPQ_Total_Quote_Discount__c == 0.00 && (proposalNewTriggerMap.get(proposalRecId).Apttus_Proposal__Approval_Stage__c == 'Approval Required' || proposalNewTriggerMap.get(proposalRecId).Indirect_Approval_Required__c == true) && proposalLineItem.Size() == 0){
							proposalNewTriggerMap.get(proposalRecId).Apttus_Proposal__Approval_Stage__c = 'Draft';
							proposalNewTriggerMap.get(proposalRecId).Indirect_Approval_Required__c  = false;
						}
					} 
				}				   
			}   
		}
		 catch(Exception ex) {		   
			ExceptionHandler.addException(ex,ProposalTriggerHelper.class.getName(),'Line number '+ex.getLineNumber());
		}   
	}
}