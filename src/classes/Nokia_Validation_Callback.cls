/************************************************************************************************************
	* Apex Class Name   : Nokia_Validation_Callback.cls
	* Version		   : 1.0
	* Created Date	  : 28 Aug 2017
	* Function		  : validation call back on Cart
	* Modification Log  :
	* Developer				   Date					Description
	* -----------------------------------------------------------------------------------------------------------
	* Rupesh Sharma			   08/28/2017			  validation call back on Cart
	*
	************************************************************************************************************/
	global with sharing class Nokia_Validation_Callback implements Apttus_Config2.CustomClass.IValidationCallback2{
	 public Id ConfigId=null;
		Id Recordtype=null;
	 public Id proposalId;
	 private Apttus_Config2__ProductConfiguration__c configSO;  
	
 
	private Apttus_Config2__ProductConfiguration__c prdConfig;
	/* Method Name   : validateCart
	* Developer	  : Rupesh Sharma
	* Description	: validation messages on cart */
		global Apttus_Config2.CustomClass.ValidationResult validateCart(Apttus_Config2.ProductConfiguration cart) {
			Apttus_Config2.CustomClass.ValidationResult result= new Apttus_Config2.CustomClass.ValidationResult(true);
			Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c();
			Apttus_Config2__ProductConfiguration__c Prodid = new Apttus_Config2__ProductConfiguration__c();
			try{					
				ConfigId = cart.getConfigSO().Id;
				 
				configSO = cart.getConfigSO();			 
				Prodid=[select id,Quote_Type__c,NokiaCPQ_Portfolio_From_Quote__c from Apttus_Config2__ProductConfiguration__c  where id=:ConfigId];
				if(!String.isblank(Prodid.Quote_Type__c) && Prodid.Quote_Type__c.contains('CPQ')) {
				List<Apttus_Config2__LineItem__c> Lineitemlist1=[select id,Apttus_Config2__LineType__c,
																 Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c,
																 Apttus_Config2__ProductId__r.IsActive,
																 Apttus_Config2__ProductId__r.name,
								 Apttus_Config2__ProductId__r.ProductCode,
																 Apttus_Config2__ProductId__r.Portfolio__c,
																 Apttus_Config2__OptionId__r.name,Apttus_Config2__OptionId__r.IsActive,
																 Apttus_Config2__ProductId__c,Apttus_Config2__OptionId__c,
																 NokiaCPQ_Rationale_Of_Adjustment__c,Apttus_Config2__AdjustmentAmount__c,NokiaCPQ_Configuration_Type__c,NokiaCPQ_Spare__c,Item_Type__c,NokiaCPQ_Light_Color__c,
																 CPQ_Market_Model__c,Apttus_Config2__ExtendedQuantity__c,Apttus_Config2__Quantity__c
																 from Apttus_Config2__LineItem__c
																 where Apttus_Config2__ConfigurationId__c =:ConfigId];
				//Recordtype=Prodid.Apttus_QPConfig__Proposald__r.RecordTypeid;
				//currentquoteId = ApexPages.currentPage().getParameters().get('id');
			   
				
				quote =  [Select id,NokiaCPQ_Environment_Access_Type__c,Quote_Type__c,NokiaCPQ_LEO_Discount__c,NokiaCPQ_Is_Maintenance_Quote__c,NokiaCPQ_Portfolio__c from Apttus_Proposal__Proposal__c where id = :configSO.Apttus_QPConfig__Proposald__c];
				set<Id> Pricelistid= new set<Id>();
				Map<ID,Boolean> ProductMap= new Map<ID,Boolean>();
				Boolean isOnlyMaintenance=true;
	   
				//if(quote.Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_INDIRECTCPQ))
				//{	  
					If(Lineitemlist1.size() > 0)
					{				
						
						for(Apttus_Config2__LineItem__c lin:Lineitemlist1) {	

							if(!Prodid.NokiaCPQ_Portfolio_From_Quote__c.equalsignorecase('QTC'))
						{
							
							if (lin.Apttus_Config2__LineType__c== 'Product/Service')
							{
			 
				if(lin.Apttus_Config2__ProductId__r.ProductCode!='MT001' &&	
				  lin.Apttus_Config2__ProductId__r.ProductCode!='MT002'
								   && lin.Apttus_Config2__ProductId__r.ProductCode!='SSP002' && lin.Apttus_Config2__ProductId__r.ProductCode!='SRS')
				   {
									   isOnlyMaintenance=false;
								   }
							  
								if (lin.Apttus_Config2__ProductId__r.IsActive == false ) {
									result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,'The Quote cannot be validated as it contains products that are no longer available for purchase. Please remove the following items:' + lin.Apttus_Config2__ProductId__r.name));   
									result.isSuccess = false;
								}					  
							}
			  if (lin.NokiaCPQ_Spare__c==True && ((Nokia_CPQ_Constants.lin_Apttus_QPConfig.equals(lin.Apttus_Config2__LineType__c) && Nokia_CPQ_Constants.BUNDLE.equals(lin.NokiaCPQ_Configuration_Type__c)) ||
															   Nokia_CPQ_Constants.NOKIA_OPTION.equals(lin.Apttus_Config2__LineType__c) || !Nokia_CPQ_Constants.HARDWARE_STRING.equals(lin.Item_Type__c))) {
									result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.RestrictSpare));   
									result.isSuccess = false;
								}
							else if(lin.Apttus_Config2__LineType__c == 'Option'){
								if (lin.Apttus_Config2__OptionId__r.IsActive == false ) {
									result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,'The Quote cannot be validated as it contains products that are no longer available for purchase. Please remove the following items:' + lin.Apttus_Config2__OptionId__r.name ));   
									result.isSuccess = false;
								}					  
							}
							system.debug('quote.NokiaCPQ_Portfolio__c'+quote.NokiaCPQ_Portfolio__c);
							system.debug('lin.Apttus_Config2__ProductId__r.Portfolio__c'+lin.Apttus_Config2__ProductId__r.Portfolio__c);
							if(!quote.NokiaCPQ_Portfolio__c.equalsignorecase(lin.Apttus_Config2__ProductId__r.Portfolio__c) && !String.isEmpty(lin.Apttus_Config2__ProductId__r.Portfolio__c ) && !String.isBlank(lin.Apttus_Config2__ProductId__r.Portfolio__c) ){
					  
					   
									result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,'The Quote cannot be finalized as it contains products that do not belong to the portfolio you selected on the quote. Please remove the following items:' +lin.Apttus_Config2__ProductId__r.name  ));   
									result.isSuccess = false;
								 
				   
							}
						}
						if(Prodid.NokiaCPQ_Portfolio_From_Quote__c.equalsignorecase('QTC')){
							if(lin.CPQ_Market_Model__c<>NULL){
								System.debug('FG::> '+lin.CPQ_Market_Model__c);
								String modelname = lin.CPQ_Market_Model__c;
								String [] modelArray = modelname.split('\\s');			  
								String qty = modelArray[modelArray.size()-1];
								string Quantity = qty.substringBetween('(',')');
								Integer FGqty = Integer.valueOf(Quantity);
								Integer Extqty = Integer.valueOf(lin.Apttus_Config2__Quantity__c);
								System.debug('FGqty::> '+FGqty +' '+ 'Extqty::> '+Extqty);
								if(Math.mod(Extqty, FGqty)<>0){
									result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,'Item ' +lin.Apttus_Config2__ProductId__r.name +' is part of a Flexible Group. The quantity you entered is invalid. The quantity entered must be a multiple of the Flexible Group Quantity.'  ));
									result.isSuccess = false;
								}
							}
						}
					}   
//Heema :Req 6383
			 if(isOnlyMaintenance==true && quote.NokiaCPQ_Is_Maintenance_Quote__c==false && !quote.NokiaCPQ_Portfolio__c.equalsIgnoreCase('QTC')){
						result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,'You must select at least one catalog or custom product in the cart before you can finalize.'));   
									result.isSuccess = false;	
						}
					}
					
				
				//}
		/* Requirement   : Req:6001
				* Developer	  : Piyush Tawari 
				* Description	: warning messages on cart for product
				1.if adjustment given but rationale not provided*/
				if(quote.Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_DIRECTCPQ) && !quote.NokiaCPQ_Portfolio__c.equalsIgnoreCase('QTC') ){	  
					system.debug('In directquote code');
					if(Lineitemlist1.size() > 0){										 
						for(Apttus_Config2__LineItem__c lin:Lineitemlist1) {
							if(quote.NokiaCPQ_Portfolio__c == Nokia_CPQ_Constants.AIRSCALE_WIFI_STRING){
								system.debug('In Product/Service and options');
								system.debug('LineItemInDirect'+lin);
								if (lin.Apttus_Config2__AdjustmentAmount__c != null && 
									lin.Apttus_Config2__AdjustmentAmount__c != 0.00 && 
									String.isBlank(lin.NokiaCPQ_Rationale_Of_Adjustment__c )) {
										if(lin.Apttus_Config2__LineType__c== Nokia_CPQ_Constants.lin_Apttus_QPConfig){
											system.debug('In Product/Service error');
											result.Messages.add(new ApexPages.Message(ApexPages.Severity.WARNING,System.label.Rationale_Needed_Product + lin.Apttus_Config2__ProductId__r.name));	
											result.isSuccess = true;
										}else if(lin.Apttus_Config2__LineType__c == Nokia_CPQ_Constants.NOKIA_OPTION &&
												 Nokia_CPQ_Constants.BUNDLE.equals(lin.NokiaCPQ_Configuration_Type__c)){
													 system.debug('In options error');
													 result.Messages.add(new ApexPages.Message(ApexPages.Severity.WARNING,System.label.Rationale_Needed_Product + lin.Apttus_Config2__OptionId__r.name));	
													 result.isSuccess = true;													
												 }
									}
							}
							/* Requirement   : Req:6671,6670,6500
							* Developer	  : Piyush Tawari, Kamlesh Jandu 
							* Description	: Error message on cart if Guidance is RED */
							String DealGuidancePortfolios = System.label.Deal_Guidance_Applicable_Portfolios;
							if(DealGuidancePortfolios.contains(quote.NokiaCPQ_Portfolio__c)){
								   Boolean isPricingManager = FeatureManagement.checkPermission(Nokia_CPQ_Constants.PRICING_MANAGER);
									//system.debug(isPricingManager );
								   Boolean isSalesUser = FeatureManagement.checkPermission(Nokia_CPQ_Constants.CPQ_SALES_USER);
									//system.debug(isSalesUser );
								   Map<String, String> mapValues = Apttus_Config2.RuntimeContext.getParameters();
								   String PageAction = mapValues.get('pageAction');
								   //system.debug('PageAction'+PageAction);
								   if(PageAction == 'Finalize'){
									   if(isSalesUser && !isPricingManager &&
										  !Nokia_CPQ_Constants.BUNDLE.equals(lin.NokiaCPQ_Configuration_Type__c) && 
										  lin.NokiaCPQ_Light_Color__c == Nokia_CPQ_Constants.RED ){
											  result.isSuccess = false;
											  result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.Deal_Guidance_Error));													
											  return result;
										  }
								   }	 
							   }
						}
					}					
				}
			 }
		   
			
			}
			catch(exception ex){
				System.debug('EXception --- ' +ex);
			}
		   
			result.isSuccess = true;
			 if(!String.isblank(Prodid.Quote_Type__c) && Prodid.Quote_Type__c.contains('CPQ') && !Prodid.NokiaCPQ_Portfolio_From_Quote__c.equalsignorecase('QTC')) {
				if(quote.Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_INDIRECTCPQ)){
				prdConfig =  cart.getConfigSO();
				
				List<Apttus_Config2__SummaryGroup__c> summaryLines = [Select Id,NokiaCPQ_Net_Price__c,Apttus_Config2__Description__c,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__AdjustmentAmount__c from Apttus_Config2__SummaryGroup__c Where  Apttus_Config2__ConfigurationId__c = :prdConfig.Id];
				
				if(Nokia_CPQ_Constants.NOKIA_PROPOSAL.equalsIgnoreCase(prdConfig.Apttus_Config2__BusinessObjectType__c)){
												  
					if(isChargeTypeMaintenance(summaryLines)) {
					   
						result.isSuccess = false;
						result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, Nokia_CPQ_Constants.NOKIA_CHARGE_TYPE_ERROR_MSG));					
						
						return result;
					}  
					
					if(isCADCorrect(summaryLines)) {
					   
						result.isSuccess = false;
						result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, Nokia_CPQ_Constants.NOKIA_CAD_ERROR_MSG));				   
						
						return result;
					} 
					if(quote.NokiaCPQ_LEO_Discount__c== true && isValidLEOAmount(summaryLines)){
					system.debug('i am LEO');
					 result.isSuccess = false;
						result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, Nokia_CPQ_Constants.NOKIA_LEO_WARNING_MSG));					
						system.debug('result'+result);
						return result;
					}
				}
			}
		   
		  }
	   /* Requirement   : Req:6337
				* Developer	  : Priyanka Agrawal
				* Description	: warning messages on cart for NP
				1.if NP not equal to CNP - Reserves*/
			if(!String.isblank(Prodid.Quote_Type__c) && Prodid.Quote_Type__c.contains('CPQ') && !Prodid.NokiaCPQ_Portfolio_From_Quote__c.equalsignorecase('QTC')) {
				if(quote.Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_DIRECTCPQ) && quote.NokiaCPQ_Portfolio__c != 'QTC' ){
					List<CPQ_Advance_Pricing__mdt> tempData = new List<CPQ_Advance_Pricing__mdt>();
					tempData = [Select MasterLabel,Action_Name__c from CPQ_Advance_Pricing__mdt where MasterLabel = :quote.NokiaCPQ_Portfolio__c];
					if(!tempData.isEmpty()){
						Map<String, String> mapValues = Apttus_Config2.RuntimeContext.getParameters();
						String PageAction = mapValues.get('pageAction');
						List<Apttus_Config2__SummaryGroup__c> summaryLines = [Select Id,Nokia_CPQ_Reserves__c,NokiaCPQ_Extended_CNP_2__c,NokiaCPQ_Extended_NP__c from Apttus_Config2__SummaryGroup__c Where  Name = 'Total (One Time)' AND Apttus_Config2__ConfigurationId__c = :ConfigId LIMIT 1];
 
						 if(PageAction == tempData[0].Action_Name__c){
							Decimal differnceCNP = (summaryLines[0].NokiaCPQ_Extended_CNP_2__c - (summaryLines[0].Nokia_CPQ_Reserves__c*summaryLines[0].NokiaCPQ_Extended_CNP_2__c)/100).setScale(2, RoundingMode.HALF_UP);
							 system.debug('differnceCNP---in loop'+differnceCNP + ' NP**' + summaryLines[0].NokiaCPQ_Extended_NP__c);
							if(differnceCNP != summaryLines[0].NokiaCPQ_Extended_NP__c ){	   
								system.debug('PageAction'+PageAction);
								result.isSuccess = false;
								result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, Nokia_CPQ_Constants.AdvacncePricing_error));				   
								
								return result;
							}
						}
					}
				}
			}
 
			return result;
		}
	   
		
 
	/* Method Name   : validateCart
	* Developer	  : Rupesh Sharma
	* Description	: This method returns true when the CAD is applied on any Sub Total Lines */	   
		@TestVisible private Boolean isChargeTypeMaintenance(List<Apttus_Config2__SummaryGroup__c> summaryLines) {
			/*maintenance Fee Flag*/
			@TestVisible Boolean isMaintenanceFee = FALSE;
	
			for(Apttus_Config2__SummaryGroup__c osl:summaryLines)
			{
				if(osl.Apttus_Config2__Description__c!=null && osl.Apttus_Config2__AdjustmentAmount__c!=null&&!osl.Apttus_Config2__Description__c.equalsIgnoreCase('Total (One Time) (One Time)')&&Double.valueOf(osl.Apttus_Config2__AdjustmentAmount__c)>0.00)
				{
					isMaintenanceFee = TRUE;
				}
			}
			return isMaintenanceFee;
		}
 
	/* Method Name   : validateCart
	* Developer	  : Rupesh Sharma
	* Description	: This method returns true when the CAD is applied wrong */	   
		@TestVisible private Boolean isCADCorrect(List<Apttus_Config2__SummaryGroup__c> summaryLines) {
		   /*CAD discount Flag*/
			@TestVisible Boolean isCADcorrect = FALSE;
			for(Apttus_Config2__SummaryGroup__c osl:summaryLines)
			{
				if(osl.Apttus_Config2__Description__c!=null && osl.Apttus_Config2__AdjustmentAmount__c!=null&&osl.Apttus_Config2__Description__c.equalsIgnoreCase('Total (One Time) (One Time)')&& osl.Apttus_Config2__AdjustmentAmount__c>osl.Apttus_Config2__ExtendedPrice__c)
				{
					isCADcorrect = TRUE;
				}
			}
			return isCADcorrect;
		}
   /*Method name validate cart
	*developer : heema solanki
	*Description : this method will return true if quote amunt is less than 500 for LEO */
	  @TestVisible private Boolean isValidLEOAmount(List<Apttus_Config2__SummaryGroup__c> summaryLines) { 
		/*valid LEO amount check*/
		@TestVisible Boolean isValidLEOAmount = FALSE;
		for(Apttus_Config2__SummaryGroup__c osl:summaryLines)
		{
			if(osl.Apttus_Config2__Description__c!=null && osl.Apttus_Config2__Description__c.equalsIgnoreCase('Total (One Time) (One Time)') && osl.NokiaCPQ_Net_Price__c < 500)
			{
				isValidLEOAmount = TRUE;
			}
		}
	  
		return isValidLEOAmount;
	}
	   
	/* Method Name   : validateCart
	* Developer	  : Apttus
	* Description	: OOTB */		   
		global Apttus_Config2.CustomClass.ValidationResult validateRampLineItems(Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2.LineItem> rampLineItems) {
			Apttus_Config2.CustomClass.ValidationResult result= new Apttus_Config2.CustomClass.ValidationResult(true);
			return result;
		}
 
	/* Method Name   : validateCart
	* Developer	  : Apttus
	* Description	: OOTB */		   
		global Apttus_Config2.CustomClass.ValidationResult validateAssetItems(Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2__TempRenew__c> assetItems) {
		   
			Apttus_Config2.CustomClass.ValidationResult result= new Apttus_Config2.CustomClass.ValidationResult(true);
			return result;
		}
 
	   
	}