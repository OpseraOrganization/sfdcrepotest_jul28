/*************************************************************
@Name: NokiaCPQ_Reprice_Quote_Ctrlr
@Author: Accenture
@Description: This class contains Logic for quote level reprice
******************************************************************/ 

public with sharing class NokiaCPQ_Reprice_Quote_Ctrlr 
{
	public Apttus_Proposal__Proposal__c quote;
	public String currentquoteId {get;set;}
	public List<Apttus_Config2__ProductConfiguration__c> productConfigs = new List<Apttus_Config2__ProductConfiguration__c>();
	public List<Apttus_Config2__LineItem__c> configLineItems = new List<Apttus_Config2__LineItem__c>();
	public List<Apttus_Config2__LineItem__c> configLineItemsUpdate = new List<Apttus_Config2__LineItem__c>();
	public List<Apttus_Config2__LineItem__c> configLineItemsOptions = new List<Apttus_Config2__LineItem__c>();
	public List<Apttus_Config2__LineItem__c> configLineItemsBundles = new List<Apttus_Config2__LineItem__c>();
	public List<Apttus_Config2__LineItem__c> configLineItemsArcadiaBundles = new List<Apttus_Config2__LineItem__c>();
	public List<Apttus_Config2__LineItem__c> configLineItemsBundleAndSRSMaint = new List<Apttus_Config2__LineItem__c>();
	public List<Apttus_Config2__LineItem__c> configLineItemsBundlesAgain = new List<Apttus_Config2__LineItem__c>();
	public List<Apttus_Config2__LineItem__c> productPriceconfigLineItems = new List<Apttus_Config2__LineItem__c>();
	public List<Apttus_Config2__LineItem__c> productPriceconfigLineItemFinal = new List<Apttus_Config2__LineItem__c>();
	public Apttus_Config2__ProductConfiguration__c productConfig; 
	public Id configId;
	public Boolean actionPollerActive{get; set;}
	public Boolean hasPendingItems{get; set;} 
	public Boolean flagUpdatePrice; 
	public Apttus_CpqApi.CPQ.UpdatePriceRequestDO objUpdatePriceRequestDO ;
	public Boolean pricingNotRequired;
	public Boolean isError{get; set;}
	public Boolean isChangedLEO{get; set;}
	public Integer totalLineItems {get; set;}
	public transient Integer completedLineItems {get; set;} 
	public Boolean isFinalized {get; set;}
	public Boolean isDirect {get; set;}
	public Integer countOptions {get; set;}
	public Integer countBundles {get; set;}
	public Integer countSRSMaintenance {get; set;}
	public Integer countArcadiaItems {get; set;}
	public Integer countFlag {get; set;}
	public List<Apttus_Config2__LineItem__c> configLineItemsSRSMaintenance = new List<Apttus_Config2__LineItem__c>();
	Set<String> srsMaintenanceSet = new Set<String>{Nokia_CPQ_Constants.NOKIA_PRODUCT_NAME_SRS,Nokia_CPQ_Constants.NOKIA_YEAR2_BEYOND,Nokia_CPQ_Constants.NOKIA_YEAR1_MAINTENANCE,Nokia_CPQ_Constants.NOKIA_PRODUCT_NAME_SSP};
	
	//constructor defined

	public NokiaCPQ_Reprice_Quote_Ctrlr(){
	isChangedLEO=false;
		currentquoteId = ApexPages.currentPage().getParameters().get(Nokia_CPQ_Constants.QUOTEIDPARAMETER);
		quote = [Select id,NokiaCPQ_Last_Reprice__c,NokiaCPQ_Needs_Reprice__c, Reprice_In_Progress__c, IsCollaborationProgress__c,Quote_Type__c,Direct_Price_List_Number__c,NokiaCPQ_Is_Maintenance_Quote__c,NokiaCPQ_Portfolio__c,NokiaCPQ_Prior_Leo_Value__c,NokiaCPQ_LEO_Discount__c,NokiaCPQ_No_of_Years__c,NokiaCPQ_Existing_IONMaint_Contract__c,NokiaCPQ_Prior_Number_of_years__c from Apttus_Proposal__Proposal__c where id = :currentquoteId]; 
		
		//Heema: Req 6383
		if(quote.NokiaCPQ_Is_Maintenance_Quote__c){
		productConfigs = [Select id,Apttus_Config2__Status__c,Apttus_Config2__ContractNumbers__c,NokiaCPQ_IsMainSSPAdded__c from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c = :currentquoteId AND Apttus_Config2__BusinessObjectType__c =: Nokia_CPQ_Constants.NOKIA_PROPOSAL AND ((Apttus_Config2__Status__c = 'Saved' OR Apttus_Config2__Status__c='Finalized')) Order by CreatedDate DESC];
		}
		else{
		productConfigs = [Select id,Apttus_Config2__Status__c,Apttus_Config2__ContractNumbers__c,NokiaCPQ_IsMainSSPAdded__c from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c = :currentquoteId AND Apttus_Config2__BusinessObjectType__c =: Nokia_CPQ_Constants.NOKIA_PROPOSAL Order by CreatedDate DESC]; 
		}
		
		if(quote.Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_DIRECTCPQ)){
			isDirect = true;
		}
		else if(quote.Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_INDIRECTCPQ)){
			isDirect = false;
		}
		//heema D-13889
		if(quote.NokiaCPQ_No_of_Years__c!=quote.NokiaCPQ_Prior_Number_of_years__c){
		
		isChangedLEO = true;
		}

		//Varsha: Fixed for Defect D-7623
		if(!productConfigs.isEmpty()){
			configId = productConfigs.get(0).Id;
		}   
	}
	
	public void callConstraintRule(){
		if(isChangedLEO){
				List<Integer> primaryLines = new List<Integer>();
				Apttus_CPQApi.CPQWebService.associateConstraintRules(configId,primaryLines);
				Apttus_CPQApi.CPQWebService.applyConstraintRules(configId, false);
		}
	}
	//This method uses logic for reprice
	public PageReference init(){
		try{
			if(quote.NokiaCPQ_Needs_Reprice__c == false){
				pricingNotRequired = true;
				hasPendingItems = false;
				actionPollerActive = false;
				isError = true;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,Nokia_CPQ_Constants.SINGLEREPRICENOTREQ));
			}
			else if(quote.NokiaCPQ_Needs_Reprice__c == true && quote.IsCollaborationProgress__c == true){
				pricingNotRequired = true;
				hasPendingItems = false;
				actionPollerActive = false;
				isError = true;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,Nokia_CPQ_Constants.SINGLEREPRICEINCOLLAB));
			}
			else if(configId == null){
				quote.NokiaCPQ_Needs_Reprice__c = false;
				Database.update(quote, false);
				pricingNotRequired = true;
				hasPendingItems = false;
				actionPollerActive = false;
				isError = true;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,Nokia_CPQ_Constants.CONFIGUREFIRST));
			}
			else{
				//update Product Config with Contract Number for Direct
				if(isDirect && quote.Direct_Price_List_Number__c != productConfigs.get(0).Apttus_Config2__ContractNumbers__c){
					productConfigs.get(0).Apttus_Config2__ContractNumbers__c = quote.Direct_Price_List_Number__c;
					Database.update(productConfigs.get(0), false);
				}
				If(isChangedLEO){
					if(quote.NokiaCPQ_No_of_Years__c.equalsIgnoreCase(Nokia_CPQ_Constants.NOKIA_1YEAR)){
						productConfigs.get(0).NokiaCPQ_IsMainSSPAdded__c = true;
					}
					else{
						productConfigs.get(0).NokiaCPQ_IsMainSSPAdded__c = false;
					}
					Database.update(productConfigs.get(0), false);
				}
				configLineItems = [Select Id,Apttus_Config2__PricingStatus__c, NokiaCPQ_Configuration_Type__c,Apttus_Config2__IsPrimaryLine__c, Apttus_Config2__ChargeType__c,Apttus_Config2__LineType__c,Apttus_Config2__IsHidden__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c = :configId];
				//Heema : 6383 Req Start
				if(quote.NokiaCPQ_Is_Maintenance_Quote__c){
					For(Apttus_Config2__LineItem__c productPriceconfigLineItem : configLineItems){
						if(productPriceconfigLineItem.Apttus_Config2__ChargeType__c.equalsIgnoreCase('Standard Price')){
						productPriceconfigLineItem.Apttus_Config2__IsHidden__c = false;
						productPriceconfigLineItems.add(productPriceconfigLineItem);
						}
					}
				
					if(!productPriceconfigLineItems.isEmpty()){
						Database.update(productPriceconfigLineItems, false);
					}
				}
				//Heema : 6383 Req End
				if(!configLineItems.isEmpty()){ 
					quote.Reprice_In_Progress__c = true;				  
					Database.update(quote, false);
					totalLineItems  = configLineItems.size();
					system.debug('configLineItems before status update>>'+configLineItems);

					for(Apttus_Config2__LineItem__c configLineItem : configLineItems){
						if(isDirect == true){
							//top level bundles
							if(configLineItem.Apttus_Config2__LineType__c.equalsIgnoreCase(Nokia_CPQ_Constants.NOKIA_PRODUCT_SERVICES) && configLineItem.NokiaCPQ_Configuration_Type__c != null && configLineItem.NokiaCPQ_Configuration_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.BUNDLE) && configLineItem.Apttus_Config2__ChargeType__c.equalsIgnoreCase(Nokia_CPQ_Constants.STANDARD_PRICE)){
								configLineItem.Apttus_Config2__PricingStatus__c = Nokia_CPQ_Constants.PENDING_STRING;
								configLineItemsBundles.add(configLineItem);
							}
							//Arcadia items
							else if(configLineItem.Apttus_Config2__LineType__c.equalsIgnoreCase(Nokia_CPQ_Constants.NOKIA_OPTION) && configLineItem.NokiaCPQ_Configuration_Type__c != null && configLineItem.NokiaCPQ_Configuration_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.BUNDLE)){
								configLineItem.Apttus_Config2__PricingStatus__c= Nokia_CPQ_Constants.PENDING_STRING;
								configLineItemsArcadiaBundles.add(configLineItem);
							}
							//options with standard price charge type
							else if(configLineItem.NokiaCPQ_Configuration_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.NOKIA_STANDALONE) && configLineItem.Apttus_Config2__ChargeType__c.equalsIgnoreCase(Nokia_CPQ_Constants.STANDARD_PRICE)){
								configLineItem.Apttus_Config2__PricingStatus__c= Nokia_CPQ_Constants.PENDING_STRING;
								configLineItemsOptions.add(configLineItem);
							}
							//options with charge type other than standard price
							else if(srsMaintenanceSet.contains(configLineItem.Apttus_Config2__ChargeType__c)){
								configLineItem.Apttus_Config2__PricingStatus__c= Nokia_CPQ_Constants.PENDING_STRING;
								configLineItemsSRSMaintenance.add(configLineItem);
							}
							if(quote.NokiaCPQ_Portfolio__c == 'Nokia Software'){
								if(configLineItem.Apttus_Config2__LineType__c.equalsIgnoreCase(Nokia_CPQ_Constants.NOKIA_PRODUCT_SERVICES)){
									configLineItem.Apttus_Config2__PricingStatus__c= Nokia_CPQ_Constants.PENDING_STRING;
									configLineItemsBundlesAgain.add(configLineItem);
								}
							}
						}
						else if(isDirect == false){
							// For Indirect, both Bundles and Options are processed together
							configLineItem.Apttus_Config2__PricingStatus__c= 'Pending';
							configLineItemsOptions.add(configLineItem);							 
						}  
					}
					system.debug('configLineItemsBundles-->'+configLineItemsBundles);
					system.debug('configLineItemsArcadiaBundles-->'+configLineItemsArcadiaBundles);
					system.debug('configLineItemsOptions-->'+configLineItemsOptions);
					system.debug('configLineItemsSRSMaintenance-->'+configLineItemsSRSMaintenance);
					
					Database.update(configLineItemsOptions,false); 
					countOptions = configLineItemsOptions.size();
					if(isDirect == true){
						countBundles = configLineItemsBundles.size();
						countSRSMaintenance = configLineItemsSRSMaintenance.size();
						countArcadiaItems = configLineItemsArcadiaBundles.size();
					}
				}
				
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,Nokia_CPQ_Constants.REPRICING_WAIT_MSG));
				pricingNotRequired  = false;
				hasPendingItems = false; 
				actionPollerActive = true;
				objUpdatePriceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
				objUpdatePriceRequestDO.CartId = configId;
				isError = false;
				
				if(!Test.isRunningTest()){
				Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(objUpdatePriceRequestDO);
					hasPendingItems = result.IsPricePending;
					system.debug('hasPendingItems in runningtest--> '+hasPendingItems);
				}
				else{
				   hasPendingItems = true; 
				}
				
				if(hasPendingItems){
					actionPollerActive = true;
					flagUpdatePrice = true;
					system.debug('flagUpdatePrice-->'+flagUpdatePrice);
				}
			  
				if(isDirect == true){
					completedLineItems = countOptions;
					countFlag=1;
				}
				else if(isDirect == false){
					completedLineItems = [Select Count() from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c = :configId AND Apttus_Config2__PricingStatus__c =: Nokia_CPQ_Constants.COMPLETE_MSG]; 
				}
			}
		}
		catch(Exception e){
			System.debug('Excpetion'+e);
			ExceptionHandler.addException(e,NokiaCPQ_Reprice_Quote_Ctrlr.class.getName(),Nokia_CPQ_Constants.ERROR_MSD);
		}

		return null;
	}

	//This method contains logic to update the price
	public void doUpdatePrice(){
		try{
			if(flagUpdatePrice == true){  
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,Nokia_CPQ_Constants.REPRICING_WAIT_MSG));	  
				objUpdatePriceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
				objUpdatePriceRequestDO.CartId = configId;
				if(!Test.isRunningTest()){
					Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart (objUpdatePriceRequestDO);
					hasPendingItems = result.IsPricePending; 
				
					system.debug('doUpdatePrice hasPendingItems-->'+hasPendingItems);
					List<Integer> pendingLineNumbers = result.PendingLineNumbers;  
					List<Integer> completedLineNumbers = result.CompletedLineNumbers;
				}
				else{
				   hasPendingItems = false; 
				}
				//Update arcadia items in 2nd call
				if(configLineItemsArcadiaBundles.size() > 0 && hasPendingItems == False && isDirect == true){   
					Database.update(configLineItemsArcadiaBundles,false);
					hasPendingItems = true; 
					completedLineItems = countOptions+countArcadiaItems;
					countFlag = 2;
					configLineItemsArcadiaBundles.clear();
					system.debug('in 2nd call configLineItemsArcadiaBundles' + completedLineItems);
				}
				
				//Update Main Bundle in 3rd call
				if(configLineItemsArcadiaBundles.size()==0 && configLineItemsBundles.size() > 0 && isDirect == true && hasPendingItems == False){   
					Database.update(configLineItemsBundles,false);
					hasPendingItems = true; 
					completedLineItems = countOptions+countArcadiaItems+countBundles;
					countFlag = 3;
					configLineItemsBundles.clear();
					system.debug('in 3rd call configLineItemsBundles' + completedLineItems);
				}
				
				//Update Maintenance Lines in 4th call
				if(configLineItemsArcadiaBundles.size()==0 && configLineItemsBundles.size()==0 && configLineItemsSRSMaintenance.size()>0 && isDirect == true && hasPendingItems == False){	   
					Database.update(configLineItemsSRSMaintenance,false);
					hasPendingItems = true;
					completedLineItems = countOptions+countBundles+countArcadiaItems+countSRSMaintenance;
					countFlag=4;
					configLineItemsSRSMaintenance.clear();
					system.debug('in 4th call configLineItemsSRSMaintenance' + completedLineItems);
					  
				}
				
				//Update Main Bundle again in 5th call
				if(configLineItemsSRSMaintenance.size()==0 && countFlag == 4 && isDirect == true && hasPendingItems == False){
					
					countFlag=5;
					completedLineItems = countOptions+countBundles+countArcadiaItems+countSRSMaintenance;
					system.debug('in 5th call configLineItemsBundlesAgain' + completedLineItems);  
					 if(!configLineItemsBundlesAgain.isEmpty()){
						Database.update(configLineItemsBundlesAgain,false);
						hasPendingItems = true; 
						configLineItemsBundlesAgain.clear();
					}
				}

				//Set completedlineItems for Direct
				if(isDirect && countFlag == 1){
					completedLineItems = countOptions;
				}
				else if(isDirect && countFlag == 2){
					completedLineItems = countOptions+countArcadiaItems;
				}
				else if(isDirect && countFlag == 3){
					completedLineItems = countOptions+countArcadiaItems+countBundles;
				}
				else if(isDirect){
					completedLineItems = countOptions+countBundles+countArcadiaItems+countSRSMaintenance;
				}

				if(hasPendingItems == false){	
					
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,Nokia_CPQ_Constants.REPRICING_COMPLETE_MSG));				  
					Apttus_CpqApi.CPQ.FinalizeCartRequestDO requestFinalizeCart = new Apttus_CpqApi.CPQ.FinalizeCartRequestDO(); 
					requestFinalizeCart.CartId = configId; 
					if(!Test.isRunningTest()){				   
						Apttus_CpqApi.CPQ.FinalizeCartResponseDO responseFinalizeCart = Apttus_CpqApi.CPQWebService.finalizeCart(requestFinalizeCart);
				
						if(responseFinalizeCart.IsSuccess){
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,Nokia_CPQ_Constants.FINALIZE_MSG));
							isFinalized = true;
							actionPollerActive = false; 
							quote.NokiaCPQ_Last_Reprice__c = System.Now();
							quote.NokiaCPQ_Needs_Reprice__c = false;
							quote.Reprice_In_Progress__c = false;
						
							update quote;
						}
					}
				}
				else if(hasPendingItems == true ){ 
					actionPollerActive = true;  
				}

				if(countFlag == 5 && isDirect == true){
					completedLineItems = countOptions+countBundles+countSRSMaintenance+countArcadiaItems;
				}
				else if(isDirect == false){
					if(quote.NokiaCPQ_Is_Maintenance_Quote__c){
						For(Apttus_Config2__LineItem__c productPriceconfigLineItem : productPriceconfigLineItems){
						productPriceconfigLineItem.Apttus_Config2__IsHidden__c = true;
						productPriceconfigLineItemFinal.add(productPriceconfigLineItem);
					}
				
					if(!productPriceconfigLineItemFinal.isEmpty()){
						Database.update(productPriceconfigLineItemFinal, false);
					}
					}
					else{
					completedLineItems = [Select Count() from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c = :configId AND Apttus_Config2__PricingStatus__c =: Nokia_CPQ_Constants.COMPLETE_MSG]; 
					}
				}
			}
		}
		catch(Exception e){
			ExceptionHandler.addException(e,NokiaCPQ_Reprice_Quote_Ctrlr.class.getName(),Nokia_CPQ_Constants.ERROR_MSD);
		}
	}

	//This method contains the logic to cancel button action.
	public PageReference cancel(){
		return new PageReference(Nokia_CPQ_Constants.SLASH+currentquoteId);
	}
}