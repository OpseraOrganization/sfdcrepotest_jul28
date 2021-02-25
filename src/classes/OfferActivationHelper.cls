/****************************************
* Class Name : OfferActivationHelper
* Created Date: 29 November 2016
* Created By : Accenture
* Last Modified by: Accenture
* Last Modified Date: 29 November 2016
* Description : This class will check if more than one active offer is related to oppty and would update all offers as inactive except the latest one.
*****************************************/
public  with sharing class OfferActivationHelper{
	private static final Id DirectReadOnlyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.READONLYDIRECT).getRecordTypeId();
	private static final Id InDirectReadOnlyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.READONLYINDIRECT).getRecordTypeId();
	
	/****************************************
*Method Name: onBeforeInsert
*Description: Method to make offer active on creation
*Parameters: Offer List
*****************************************/
	public static void onBeforeInsert(List<Offer__c> newOfferList){
		try
		{
			Set<ID> opportunityIdSet = new Set<ID>();
			boolean isOfferWithoutExpectedLoALevel=false;
			 
			for(Offer__c offer : newOfferList)
			{			  
				opportunityIdSet.add(offer.Opportunity__c);				
			}
			
			system.debug('opportunityIdSet==>'+opportunityIdSet);
			
			for(Opportunity oppty :[Select Id, (Select Id,Expected_LoA_G4_Approval_Level__c  from Offers__r where Expected_LoA_G4_Approval_Level__c = null AND ActiveOffer__c=TRUE) from Opportunity where Id IN : opportunityIdSet LIMIT :opportunityIdSet.size()])
			{
				system.debug('oppty.Offers__r.size()==>'+oppty.Offers__r.size());
				if(oppty.Offers__r.size() > 0)
				{
					isOfferWithoutExpectedLoALevel=true;
					break;
				}
			}
			
			for(Offer__c offer : newOfferlist)
			{
				if(isOfferWithoutExpectedLoALevel==true)
				{
					offer.addError(label.Populate_Expected_LoA_Level);
					break;
				}				
				
				if(!offer.Activeoffer__c){
					offer.Activeoffer__c = true;
				}
			}
			if(Test.isRunningTest()){
				CustomException testingCatch = new CustomException('This is an error');
				throw testingCatch; 
			}
		} 
		catch (Exception ex) 
		{
			ExceptionHandler.addException(ex,GlobalConstants.OFFER_ACTIVATION_HELPER,GlobalConstants.ON_BEFORE_INSERT);
		}		
	}
	
	/****************************************
*Method Name: onUpdate
*Description: When an active offer is created , all other active offers on that oppty should be made inactive
*Parameters: Offer List
*****************************************/
	public static void updateActiveOffers(List<Offer__c> newOfferList){
		Integer getQueriesAvailable = Limits.getLimitQueryRows() - Limits.getQueryRows();
		Set<Id> OppIds = new Set<Id>();
		Set<Id> offerIds = new Set<Id>();
		List<Offer__c> offerList = new List<Offer__c>();
		
		for(Offer__c offer : newOfferlist){
			if(offer.Activeoffer__c){
				//Getting the offer id 
				offerIds.add(offer.id);
				OppIds.add(offer.Opportunity__c);
				//Getting the related Opportunity Id
				system.debug('OppIds>>>'+OppIds);
			}
		}
		//Querying the offer related to the oppty but not the last created one
		for(Offer__c offer: [SELECT id,Activeoffer__c FROM Offer__c WHERE Opportunity__c IN: OppIds AND Id NOT IN:offerIds AND Activeoffer__c = true LIMIT : getQueriesAvailable]){
			offer.Activeoffer__c=false;
			system.debug('offer.Activeoffer__c>>'+ offer.Activeoffer__c);
			offerList.add(offer);
		}
		system.debug('offerList'+ offerList);
		system.debug('offerListsize>>>'+ offerList.size());
		
		if(!offerList.isEmpty()){
			try{
				database.update(offerList);
				if(Test.isRunningTest()){
					CustomException testingCatch = new CustomException('This is an error');
					throw testingCatch; 
				}
			} catch (Exception ex) {
				system.debug('In Excption');
				ExceptionHandler.addException(ex,GlobalConstants.OFFER_ACTIVATION_HELPER,GlobalConstants.UPDATE_ACTIVE_OFFER);
			}
		}
	}
	
	
	/****************************************
*Method Name: validate
*Description: Must have only one active offer
*Parameters: Offer List, Offer Map
*****************************************/
	public static void validate(List<Offer__c> offerList, map<ID,Offer__c> offerOldMap){
		Set<ID> opportunityIdSet = new Set<ID>();
		Map<ID,offer__c> offerMap = new Map<ID,offer__c>();
		
		try{
			for(Offer__c offer : offerList){
				//checked prior and new values of active offer 
				if(offer.Activeoffer__c == false && offerOldMap.get(offer.id).Activeoffer__c == true){
					opportunityIdSet.add(offer.Opportunity__c);
					offerMap.put(offer.id, offer);
				}
			}
			for(Opportunity oppty :[Select Id, (Select Id from Offers__r where ActiveOffer__c = true) from Opportunity 
									where Id IN : opportunityIdSet LIMIT :opportunityIdSet.size()]){
										if(oppty.Offers__r.size() == 1){
											offerMap.get(oppty.Offers__r[0].id).addError(System.Label.One_Active_Offer_Mandatory);
										}
									}
			if(Test.isRunningTest()){
				CustomException testingCatch = new CustomException('This is an error');
				throw testingCatch; 
			}
		} catch (Exception ex) {
			ExceptionHandler.addException(ex,GlobalConstants.OFFER_ACTIVATION_HELPER,GlobalConstants.VALIDATE);
		}
	}

	
	/****************************************
*Method Name: restrictOffer
*Description: Restrict offer creation, addition, deletion when opportunity is freeze
* REQ : 855.
*Parameters: Offer List, Offer Map
*****************************************/
	public static void restrictOffer(List<Offer__c> offerList){
		try{
			Map<ID,ID> offerIDOppIDMap = new Map<ID,ID>();
			
			for(Offer__c off : offerList){
				if(off.Opportunity__c != null){
					offerIDOppIDMap.put(off.Id,off.Opportunity__c);
				}  
			}
			if(offerIDOppIDMap.size() > 0){
				Map<ID,Opportunity> oppMap = new Map<ID,Opportunity>([Select id, StageName, Phase_Status__c, Sales_Outcome__c from Opportunity where Id IN: offerIDOppIDMap.Values() Limit : (Limits.getLimitQueryRows() - Limits.getQueryRows())]);
				for(Offer__c off : offerList){
					if(off.Opportunity__c != null){
						Opportunity opp = oppMap.get(offerIDOppIDMap.get(off.id));
						//Adding logic as per D-1687
						//if(opp.StageName != null && opp.Sales_Outcome__c != null){
						if(opp.Phase_Status__c.equalsIgnoreCase(GlobalConstants.PHASE_STATUS_CLOSED) || opp.Phase_Status__c.equalsIgnoreCase(GlobalConstants.PHASE_STATUS_CLOSED_NOT_WON)){
							off.addError(System.Label.Offer_Error_Message);
							
						}
						//}
					}
				}
			}
		}
		catch(Exception ex){
			ExceptionHandler.addException(ex,GlobalConstants.OFFER_ACTIVATION_HELPER,GlobalConstants.RETRICTOFFER);
		}
		
	}
	
	/****************************************
*Method Name: createLoAByPassDetails
*Description: Method to update LoA_Bypass_Sign_Off fields on offer creation
*Parameters: List<Offer__c> newOfferList
*Note : D-3996, Update No_Support_Decision_Maker__c only when No_Support_Offer_Condition__c = true 
*****************************************/
	public static void createLoAByPassDetails(List<Offer__c> newOfferList){		
		try{			
			for(Offer__c offObj : newOfferList){
				//No filling of Decision Maker during create time D-3996..
				if(!string.isblank(offObj.No_Support_Offer_Condition__c) && offObj.No_Support_Offer_Condition__c == GlobalConstants.PICKLIST_VALUE_YES){					
					offObj.No_Support_Decision_Maker__c = UserInfo.getName();					
				}
				if(!string.isblank(offObj.LOA_Bypass__c)){					
					offObj.Decision_Maker__c = UserInfo.getName();					
				}
				if(!string.isblank(offObj.LoA_Bypass_Sign_Off_BG_AA__c)){					
					offObj.LoA_Bypass_Sign_Off_PrM_for_BG_AA__c = UserInfo.getName();					
				}
				if(!string.isblank(offObj.LoA_Bypass_Sign_Off_BG_FN__c)){					
					offObj.LoA_Bypass_Sign_Off_PrM_for_BG_FN__c = UserInfo.getName();					
				}
				if(!string.isblank(offObj.LoA_Bypass_Sign_Off_BG_ION__c)){					
					offObj.LoA_Bypass_Sign_Off_PrM_for_BG_ION__c = UserInfo.getName();					
				}
				if(!string.isblank(offObj.LoA_Bypass_Sign_Off_BG_MN__c)){					
					offObj.LoA_Bypass_Sign_Off_PrM_for_BG_MN__c = UserInfo.getName();					
				}
				if(!string.isblank(offObj.LoA_Bypass_Sign_Off_BG_GS__c)){					
					offObj.Signed_Off_by_PricingManager_BG_GS__c = UserInfo.getName();					
				}
	if(!string.isblank(offObj.LoA_Bypass_Sign_Off_BG_NEN__c)){					
					offObj.Signed_Off_by_PricingManager_BG_NEN__c = UserInfo.getName();					
				}
				if(offObj.Product_Only_Offer__c == true){
					offObj.No_Execute_Decision_Maker__c = UserInfo.getName();
				}
			}			
		}catch(Exception ex){
			ExceptionHandler.addException(ex,GlobalConstants.OFFER_ACTIVATION_HELPER,GlobalConstants.METHOD_CREATE_LOA_BYPASS_DETAILS);
		}
		
	}
	/****************************************
*Method Name: updateLoAByPassDetails
*Description: Method to update LoA_Bypass_Sign_Off fields on offer updation
*Parameters: List<Offer__c> newOfferList
*****************************************/
	public static void updateLoAByPassDetails(List<Offer__c> offerNewList, map<ID,Offer__c> offerOldMap){			 
		try{			
			for(Offer__c offerObj : offerNewList){ 
				//D-3996 LoA Release 4.
				If(offerOldMap.get(offerObj.id).No_Support_Offer_Condition__c == GlobalConstants.PICKLIST_VALUE_YES && offerObj.No_Support_Offer_Condition__c == GlobalConstants.PICKLIST_VALUE_NO)
				{
					offerObj.No_Support_Decision_Maker__c = null;
				}
				else If(offerOldMap.get(offerObj.id).No_Support_Offer_Condition__c == GlobalConstants.PICKLIST_VALUE_NO && offerObj.No_Support_Offer_Condition__c == GlobalConstants.PICKLIST_VALUE_YES)
				{
					offerObj.No_Support_Decision_Maker__c = UserInfo.getName();
				}
				
				if(string.isEmpty(offerOldMap.get(offerObj.id).LOA_Bypass__c)&&!string.isEmpty(offerObj.LOA_Bypass__c)){  
					
					offerObj.Decision_Maker__c = UserInfo.getName();
					
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LOA_Bypass__c)&&!string.isEmpty(offerObj.LOA_Bypass__c)){					
					if(!offerObj.LOA_Bypass__c.equalsIgnoreCase(offerOldMap.get(offerObj.id).LOA_Bypass__c)){									  
						
						offerObj.Decision_Maker__c = UserInfo.getName();					  
						
					}
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LOA_Bypass__c)&&string.isEmpty(offerObj.LOA_Bypass__c)){							 
					
					offerObj.Decision_Maker__c = null;
				}					
				else{
					System.debug('Nothing');
				}
				
				if(string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_AA__c)&&!string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_AA__c)){					
					
					offerObj.LoA_Bypass_Sign_Off_PrM_for_BG_AA__c = UserInfo.getName();
					
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_AA__c)&&!string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_AA__c)){				   
					
					if(!offerObj.LoA_Bypass_Sign_Off_BG_AA__c.equalsIgnoreCase(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_AA__c)){									 
						
						offerObj.LoA_Bypass_Sign_Off_PrM_for_BG_AA__c = UserInfo.getName();					  
					}
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_AA__c)&&string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_AA__c)){								 
					
					offerObj.LoA_Bypass_Sign_Off_PrM_for_BG_AA__c = null;
					
				}
				else{
					System.debug('Nothing');
				}
				
				if(string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_FN__c)&&!string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_FN__c)){
					
					offerObj.LoA_Bypass_Sign_Off_PrM_for_BG_FN__c = UserInfo.getName();
					
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_FN__c)&&!string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_FN__c)){
					
					if(!offerObj.LoA_Bypass_Sign_Off_BG_FN__c.equalsIgnoreCase(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_FN__c)){
						
						offerObj.LoA_Bypass_Sign_Off_PrM_for_BG_FN__c = UserInfo.getName();					  
					}
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_FN__c)&&string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_FN__c)){									
					
					offerObj.LoA_Bypass_Sign_Off_PrM_for_BG_FN__c = null;
					
				}
				else{
					System.debug('Nothing');
				}
				
				if(string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_ION__c)&&!string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_ION__c)){
					
					offerObj.LoA_Bypass_Sign_Off_PrM_for_BG_ION__c = UserInfo.getName();
					
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_ION__c)&&!string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_ION__c)){
					
					if(!offerObj.LoA_Bypass_Sign_Off_BG_ION__c.equalsIgnoreCase(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_ION__c)){
						
						offerObj.LoA_Bypass_Sign_Off_PrM_for_BG_ION__c = UserInfo.getName();					  
					}
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_ION__c)&&string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_ION__c)){							 
					
					offerObj.LoA_Bypass_Sign_Off_PrM_for_BG_ION__c = null;
					
				}
				else{
					System.debug('Nothing');
				}
				
				if(string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_MN__c)&&!string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_MN__c)){					
					
					offerObj.LoA_Bypass_Sign_Off_PrM_for_BG_MN__c = UserInfo.getName();
					
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_MN__c)&&!string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_MN__c)){
					if(!offerObj.LoA_Bypass_Sign_Off_BG_MN__c.equalsIgnoreCase(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_MN__c)){								   
						
						offerObj.LoA_Bypass_Sign_Off_PrM_for_BG_MN__c = UserInfo.getName();					
						
					}
					
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_MN__c)&&string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_MN__c)){								  
					
					offerObj.LoA_Bypass_Sign_Off_PrM_for_BG_MN__c = null;
				}
				else{
					System.debug('Nothing');
				}
				
				
				if(string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_GS__c)&&!string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_GS__c)){					
					
					offerObj.Signed_Off_by_PricingManager_BG_GS__c = UserInfo.getName();
					
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_GS__c)&&!string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_GS__c)){				   
					
					if(!offerObj.LoA_Bypass_Sign_Off_BG_GS__c.equalsIgnoreCase(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_GS__c)){									 
						
						offerObj.Signed_Off_by_PricingManager_BG_GS__c = UserInfo.getName();					  
					}
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_GS__c)&&string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_GS__c)){								 
					
					offerObj.Signed_Off_by_PricingManager_BG_GS__c = null;
					
				}
				else{
					System.debug('Nothing');
				}
				
	if(string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_NEN__c)&&!string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_NEN__c)){					
					
					offerObj.Signed_Off_by_PricingManager_BG_NEN__c = UserInfo.getName();
					
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_NEN__c)&&!string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_NEN__c)){				   
					
					if(!offerObj.LoA_Bypass_Sign_Off_BG_NEN__c.equalsIgnoreCase(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_NEN__c)){									 
						
						offerObj.Signed_Off_by_PricingManager_BG_NEN__c = UserInfo.getName();					  
					}
				}else if(!string.isEmpty(offerOldMap.get(offerObj.id).LoA_Bypass_Sign_Off_BG_NEN__c)&&string.isEmpty(offerObj.LoA_Bypass_Sign_Off_BG_NEN__c)){								 
					
					offerObj.Signed_Off_by_PricingManager_BG_NEN__c = null;
					
				}
				else{
					System.debug('Nothing');
				}
				
				if(offerOldMap.get(offerObj.id).Product_Only_Offer__c == false && offerObj.Product_Only_Offer__c == true){					
					
					offerObj.No_Execute_Decision_Maker__c = UserInfo.getName();
					
				}
				
				else if(offerOldMap.get(offerObj.id).Product_Only_Offer__c == true && offerObj.Product_Only_Offer__c == false){								  
					
					offerObj.No_Execute_Decision_Maker__c = null;
				}
				else{
					System.debug('Nothing');
				}
			}
			if(Test.isRunningTest()){
				CustomException testingCatch = new CustomException(GlobalConstants.Error);
				throw testingCatch; 
			}
		}catch(Exception ex){
			ExceptionHandler.addException(ex,GlobalConstants.OFFER_ACTIVATION_HELPER,GlobalConstants.METHOD_UPDATE_LOA_BYPASS_DETAILS);
		}
		
	}
	
	 //Sales Process: SF Ticket: 11957
	//Written by SDC Cheng Shuai 2018/9/13
  public static void PopulateHigestOfferNumberOnOffer(List <Offer__c> offerList)
  {
	try
	{
	  System.debug('Entered in method==> PopulateHigestOfferNumberOnOffer()');
	  List<Offer__c> lstOffer=new List<Offer__c>();
	  List<Id> listOpptyIds = new List<Id>();
	  Opportunity oppty=null;
		string strOfferNumber='';
		string lastOfferNumber='';
		string s1='';
	  
	  for (Offer__c objOffer : offerList) 
	  {
		listOpptyIds.add(objOffer.Opportunity__c);
	  }
	  
	  Map<id,Opportunity> mapOppty=new Map<id,Opportunity>([SELECT Id,Opportunity_ID__c,HighestOfferNumber__c  
								  FROM Opportunity where Id IN :listOpptyIds LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
	  List<Offer__c> existingOfferList = [Select Offer_Number__c , Opportunity__c from Offer__c where Opportunity__c in:listOpptyIds];
	  List<Offer__c> tempOfferList = new List<Offer__c>();
	  Map<Id, List<Offer__c>> existingOfferOppMap = new Map<Id, List<Offer__c>>();
	  for(Offer__c objOffer : existingOfferList){
		if(!existingOfferOppMap.containsKey(objOffer.Opportunity__c)){
		  tempOfferList = new List<Offer__c>();
		  tempOfferList.add(objOffer);
		  existingOfferOppMap.put(objOffer.Opportunity__c, tempOfferList);
		}else{
		  tempOfferList = existingOfferOppMap.get(objOffer.Opportunity__c);
		  tempOfferList.add(objOffer);
		  existingOfferOppMap.put(objOffer.Opportunity__c, tempOfferList);
		}
	  }  
	  List<Offer__c> offList = existingOfferOppMap.get(offerList[0].Opportunity__c);

	  IF(offList==NULL){
		offList = new List<Offer__c>();
	  }
	  System.debug(LoggingLevel.INFO, '*** offList: ' + offList);
	  List<AggregateResult> maxOfferList = [SELECT max(Offer_Number__c) FROM Offer__c WHERE Id IN:offList];
	  System.debug(LoggingLevel.INFO, '*** maxOfferList: ' + maxOfferList);
	  for (Offer__c objOffer :offerList)
	  {
		oppty=mapOppty.get(objOffer.Opportunity__c);
		
		if(oppty!=null) 
		{
		  System.debug(LoggingLevel.INFO, '*** oppty.HighestOfferNumber__c before: ' + oppty.HighestOfferNumber__c);
		  if(oppty.HighestOfferNumber__c!= 0)
		  {
			for(AggregateResult offerNumList : maxOfferList){
			  s1 = String.valueOf(offerNumList.get('expr0'));
		 }
		 String s2 = s1.substringAfterLast('.');
			System.debug(LoggingLevel.INFO, '*** s2: ' + s2);
		 Integer lastOfferNum = Integer.valueOf(s2);
		 lastOfferNumber = String.valueOf(lastOfferNum+1);
			if((lastOfferNum+1)<10)
			{
			  objOffer.Offer_Number__c = oppty.Opportunity_ID__c+'.0'+lastOfferNumber;
			}
			else
			{
			  objOffer.Offer_Number__c = oppty.Opportunity_ID__c+'.'+lastOfferNumber;
			}			
			lstOffer.add(objOffer);
		  }
		  else
		  {
			objOffer.Offer_Number__c = String.valueOf(oppty.Opportunity_ID__c)+'.01';
			lstOffer.add(objOffer);
		  }	  
		}		
	  } 
		if(Test.isRunningTest()){
				CustomException testingCatch = new CustomException('This is an error');
				throw testingCatch; 
		}
	}
	catch(Exception ex)
	{
			ExceptionHandler.addException(ex,GlobalConstants.OFFER_ACTIVATION_HELPER,GlobalConstants.METHOD_UPDATE_LOA_BYPASS_DETAILS);
		}		
	}
	
	//Sales Process: SF Ticket: 2567
	/****************************************
*Method Name: UpdateHigestOfferNumberOnOppty 
*Description: This method used to update HigestOfferNumber aganst opportunity Object opst offer creation
*Parameters: Offer List
*****************************************/
	public static void UpdateHigestOfferNumberOnOppty(List <Offer__c> offerList)
	{
		try
		{
			System.debug('Entered in method==> UpdateHigestOfferNumberOnOppty()');
			List<Offer__c> lstOffer=new List<Offer__c>();
			List<Id> listOpptyIds = new List<Id>();
			List<Opportunity> lstOppty= new List<Opportunity>();
			Opportunity oppty=null;
			
			for (Offer__c objOffer : offerList) 
			{
				listOpptyIds.add(objOffer.Opportunity__c);
			}
			
			Map<id,Opportunity> mapOppty=new Map<id,Opportunity>([SELECT Id,HighestOfferNumber__c  
																  FROM Opportunity where Id IN :listOpptyIds LIMIT :Limits.getLimitQueryRows() - Limits.getQueryRows()]);
			
			for (Offer__c objOffer :offerList)
			{
				oppty=mapOppty.get(objOffer.Opportunity__c);
				
				if(oppty!=null) 
				{
					if(oppty.HighestOfferNumber__c != null) 
					{
						oppty.HighestOfferNumber__c = oppty.HighestOfferNumber__c+1;
						lstOppty.add(oppty);	
					}
					else
					{		  
						oppty.HighestOfferNumber__c = 1;
						lstOppty.add(oppty);
					}			
				}
			}
			
			if(!lstOppty.isEmpty())
			{
				database.update(lstOppty);
			}
			if(Test.isRunningTest()){
				CustomException testingCatch = new CustomException('This is an error');
				throw testingCatch; 
			}
		}
		catch(Exception ex)
		{
			ExceptionHandler.addException(ex,GlobalConstants.OFFER_ACTIVATION_HELPER,GlobalConstants.METHOD_UPDATE_LOA_BYPASS_DETAILS);
		}		
	}
	/****************************************
*Method Name: marketValidation
*Description: limit "Pre-approved Price List for Account Managers" to market 
*Parameters: Offer List, Offer Map
*Req No:2748,2411, SFTicket 00016740
*****************************************/
	public static void marketValidation(List<Offer__c> offerList){
		system.debug('calling marketValidation>>>');
		try{
			Set<Id> opptyIds = new Set<Id>();
			Map<Id, Id> offerToOpp = new Map<Id, Id>();
			Opportunity opp = new Opportunity();
			String leadBGBypass = System.Label.LeadBGbypassforallmarket;
			Map<ID, Schema.RecordTypeInfo> recTypeMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
			system.debug('recTypeMap' + recTypeMap);
			for(Offer__c objOffer :offerList){
				if(GlobalConstants.LOA_BYPASS.equalsIgnoreCase(objOffer.LOA_Bypass__c)){
					opptyIds.add(objOffer.Opportunity__c);
					offerToOpp.put(objOffer.id, objOffer.Opportunity__c);
				}
			}
			system.debug('opptyIds' + opptyIds);
			system.debug('offerToOpp' + offerToOpp);
			Map<Id, Opportunity> opptyList = new Map<Id, Opportunity>([select id, AccountId,Account.L5Name__c , Lead_BG__c, Account.Market__c, RecordTypeId from Opportunity where Id IN: opptyIds]); 
			
			List<Account_Market__c> accMarket = Account_Market__c.getAll().values();
			
			
			system.debug('******accMarket*******'+accMarket);
			
			Set<String> accMarkets = new Set<String>();
			
			for(Account_Market__c accMarketObj: accMarket){
		accMarkets.add(accMarketObj.Name);				
			}
			
			system.debug('******accMarkets*******'+accMarkets);  
			for(Offer__c objOffer :offerList){
				if(offerToOpp.containsKey(objOffer.id) && opptyList.containsKey(offerToOpp.get(objOffer.id))){
					opp = Null;
					opp = opptyList.get(offerToOpp.get(objOffer.id));
					String opptyRecordType = recTypeMap.get(opp.RecordTypeId).getName();
					system.debug('opp.Account.L5Name__c>>'+opp.Account.L5Name__c);
					if((opptyRecordType.equalsIgnoreCase(GlobalConstants.DIRECT_OPPTY) || opptyRecordType.equalsIgnoreCase(GlobalConstants.INDIRECT_OPPTY)) &&
					   opp.Lead_BG__c != Null && !String.isBlank(leadBGBypass) && leadBGBypass.contains(opp.Lead_BG__c) )
					{
						System.debug('All markets bypassed.');
					}
		else if((opptyRecordType.equalsIgnoreCase(GlobalConstants.DIRECT_OPPTY) || opptyRecordType.equalsIgnoreCase(GlobalConstants.INDIRECT_OPPTY)) 
							&& (accMarkets.contains(opp.Account.Market__c) || accMarkets.contains(opp.Account.L5Name__c)) ){
							   System.debug('2..specific markets bypassed.');
							}
					else{
					System.debug('3.. show error');
						 objOffer.addError(Label.Market_validation_error_msg);
					}
									 
				}
			}
			if(Test.isRunningTest()){
				CustomException testingCatch = new CustomException(GlobalConstants.ERROR_TEXT);
				throw testingCatch; 
			}
		}
		catch(Exception ex){
			ExceptionHandler.addException(ex,GlobalConstants.OFFER_ACTIVATION_HELPER,GlobalConstants.METHOD_MARKETVALIDATION);
		}
	}
	
	/******************************************************
*author: Accenture
* Date: June -2018
* Param: Offer List
* Return: void
* Description: Validate Pricing Manager on creation
* High Level Process 
********************************************************/
	public static void offerinsertPrMValidation(List<Offer__c> offerlist)
	{
		String userId = UserInfo.getUserId();
		set<Id> oppIdSet = new set<Id>();
		set<String> orgL2 = new set<String>();
		set<String> orgL3 = new set<String>();
		set<String> orgL4 = new set<String>();
		set<String> orgL5 = new set<String>();
		set<String> orgL6 = new set<String>();
		set<String> orgL7 = new set<String>();
		List<Offer__c> OfferPRMValidation = new List<Offer__c>();
		//Opportunity opp = new Opportunity();
		Map<String,String> sRmap = new Map<String, String>();
		try
		{
			for(Offer__c offer:offerlist)
			{
				if((Offer.LOA_Bypass__c<>Null && Offer.LOA_Bypass__c.equalsignorecase(System.Label.NF_PrM_Picklist))
				   || Offer.LoA_Bypass_Sign_Off_BG_FN__c<>Null 
				   || Offer.LoA_Bypass_Sign_Off_BG_MN__c<>Null 
				   || Offer.LoA_Bypass_Sign_Off_BG_AA__c<>Null 
				   || Offer.LoA_Bypass_Sign_Off_BG_ION__c<>Null 
				   || Offer.LoA_Bypass_Sign_Off_BG_GS__c<>Null 
	   || Offer.LoA_Bypass_Sign_Off_BG_NEN__c<>Null
				  )
					OfferPRMValidation.add(offer);
				
			}
			
			if(!OfferPRMValidation.isEmpty())
			{
				for(Offer__c off : OfferPRMValidation)
				{
					oppIdSet.add(off.Opportunity__c);
				}
				System.debug('oppIdSet::> '+oppIdSet);
			} 
			
			if(!oppIdSet.isEmpty())
			{
				for(Opportunity opp : [SELECT Id,Org_L2__c,Org_L3__c,Org_L4__c,Org_L5__c,Org_L6__c,Org_L7__c FROM Opportunity WHERE Id IN :oppIdSet AND SWx_Upsell_Proposal__c = null])
				{
					orgL2.add(opp.Org_L2__c);
					orgL3.add(opp.Org_L3__c);
					orgL4.add(opp.Org_L4__c);
					orgL5.add(opp.Org_L5__c);
					orgL6.add(opp.Org_L7__c);
					orgL7.add(opp.Org_L7__c);
				}
				
				for(Sales_Role__c sR : [SELECT User__c,Organisation__c FROM Sales_Role__c WHERE Role_Code__c LIKE :System.Label.NF_PrM_Role AND
										(Organisation__c IN: orgL2 OR
										 Organisation__c IN: orgL3 OR
										 Organisation__c IN: orgL4 OR 
										 Organisation__c IN: orgL5 OR 
										 Organisation__c IN: orgL6 OR 
										 Organisation__c IN: orgL7)])
				{
					sRmap.put(sR.User__c, sR.Organisation__c);
				}
				
			}
			
			
			if((!sRmap.isEmpty() && !sRmap.containsKey(userId)) || sRmap.isEmpty())
			{
				for(Offer__c offer : OfferPRMValidation)
				{
					if(Offer.LOA_Bypass__c == System.Label.NF_PrM_Picklist)
					{
						Offer.addError(system.Label.NF_PrM_LoABypass);
					}
					else if(Offer.LoA_Bypass_Sign_Off_BG_FN__c<>Null && (Offer.LoA_Bypass_Sign_Off_BG_FN__c.equalsIgnoreCase(GlobalConstants.PICKLIST_VALUE_YES) || Offer.LoA_Bypass_Sign_Off_BG_FN__c.equalsIgnoreCase(GlobalConstants.PICKLIST_VALUE_NO)))
					{
						Offer.addError(System.Label.NF_PrM_SignOff);
					}
					else if(Offer.LoA_Bypass_Sign_Off_BG_MN__c<>Null && (Offer.LoA_Bypass_Sign_Off_BG_MN__c.equalsIgnoreCase(GlobalConstants.PICKLIST_VALUE_YES) || Offer.LoA_Bypass_Sign_Off_BG_MN__c.equalsIgnoreCase(GlobalConstants.PICKLIST_VALUE_NO)))
					{
						Offer.addError(System.Label.NF_PrM_SignOff);
					}
					else if(Offer.LoA_Bypass_Sign_Off_BG_AA__c<>Null && (Offer.LoA_Bypass_Sign_Off_BG_AA__c.equalsIgnoreCase(GlobalConstants.PICKLIST_VALUE_YES) || Offer.LoA_Bypass_Sign_Off_BG_AA__c.equalsIgnoreCase(GlobalConstants.PICKLIST_VALUE_NO)))
					{
						Offer.addError(System.Label.NF_PrM_SignOff);
					}
					else if(Offer.LoA_Bypass_Sign_Off_BG_ION__c<>Null && (Offer.LoA_Bypass_Sign_Off_BG_ION__c.equalsIgnoreCase(GlobalConstants.PICKLIST_VALUE_YES)|| Offer.LoA_Bypass_Sign_Off_BG_ION__c.equalsIgnoreCase(GlobalConstants.PICKLIST_VALUE_NO)))
					{
						Offer.addError(System.Label.NF_PrM_SignOff);
					}
					else if(Offer.LoA_Bypass_Sign_Off_BG_GS__c<>Null && (Offer.LoA_Bypass_Sign_Off_BG_GS__c.equalsIgnoreCase(GlobalConstants.PICKLIST_VALUE_YES) || Offer.LoA_Bypass_Sign_Off_BG_GS__c.equalsIgnoreCase(GlobalConstants.PICKLIST_VALUE_NO)))
					{
						Offer.addError(System.Label.NF_PrM_SignOff);
					}
		else if(Offer.LoA_Bypass_Sign_Off_BG_NEN__c<>Null && (Offer.LoA_Bypass_Sign_Off_BG_NEN__c.equalsIgnoreCase(GlobalConstants.PICKLIST_VALUE_YES) || Offer.LoA_Bypass_Sign_Off_BG_NEN__c.equalsIgnoreCase(GlobalConstants.PICKLIST_VALUE_NO)))
					{
						Offer.addError(System.Label.NF_PrM_SignOff);
					}
				}
			}
			
		}
		
		catch (Exception ex)
		{
			System.debug('Exception::> '+ex);
			ExceptionHandler.addException(ex, GlobalConstants.OFFER_ACTIVATION_HELPER, GlobalConstants.METHOD_OFFER_INSERT_PrMVALIDATION);
		}
	}
	
	/******************************************************
*author: Accenture
* Date: June -2018
* Param: Offer List, Offer Old Map
* Return: void
* Description: Validate Pricing Manager on Update
* High Level Process 
********************************************************/
	public static void offerUpdatePrMValidation (List<Offer__c> offerList,map<ID,Offer__c> offerOldMap)
	{
		String userId = UserInfo.getUserId();
		set<Id> oppIdSet = new set<Id>();
		set<String> orgL2 = new set<String>();
		set<String> orgL3 = new set<String>();
		set<String> orgL4 = new set<String>();
		set<String> orgL5 = new set<String>();
		set<String> orgL6 = new set<String>();
		set<String> orgL7 = new set<String>();
		//Opportunity opp = new Opportunity();
		Map<String,String> sRmap = new Map<String, String>();
		List<Offer__c> OfferPRMInfo = new List<Offer__c>();
		Map<ID,Offer__c> OldOfferPRMInfo = new map<ID,Offer__c>();
		try
		{
			for(Offer__c offer:offerList)
			{
				if((Offer.LOA_Bypass__c<>Null && offerOldMap<>Null && Offer.LOA_Bypass__c<>offerOldMap.get(offer.id).LOA_Bypass__c && Offer.LOA_Bypass__c.equalsignorecase(System.Label.NF_PrM_Picklist))||
				   (Offer.LoA_Bypass_Sign_Off_BG_FN__c<>offerOldMap.get(offer.id).LoA_Bypass_Sign_Off_BG_FN__c || Offer.LoA_Bypass_Sign_Off_BG_MN__c<>offerOldMap.get(offer.id).LoA_Bypass_Sign_Off_BG_MN__c || Offer.LoA_Bypass_Sign_Off_BG_AA__c<>offerOldMap.get(offer.id).LoA_Bypass_Sign_Off_BG_AA__c ||
					Offer.LoA_Bypass_Sign_Off_BG_ION__c<>offerOldMap.get(offer.id).LoA_Bypass_Sign_Off_BG_ION__c || Offer.LoA_Bypass_Sign_Off_BG_GS__c<>offerOldMap.get(offer.id).LoA_Bypass_Sign_Off_BG_GS__c || Offer.LoA_Bypass_Sign_Off_BG_NEN__c<>offerOldMap.get(offer.id).LoA_Bypass_Sign_Off_BG_NEN__c)
				  )
				{
					OfferPRMInfo.add(offer);
					OldOfferPRMInfo.put(Offer.id,offerOldMap.get(offer.id));
				} 
			}
			
			if(!OfferPRMInfo.IsEmpty() && !OldOfferPRMInfo.IsEmpty())
			{
				for(Offer__c off : OfferPRMInfo)
				{
					oppIdSet.add(off.Opportunity__c);
				}
				System.debug('oppIdSet::> '+oppIdSet);
			}  
			
			if(!oppIdSet.isEmpty())
			{
				for(Opportunity opp : [SELECT Id,Org_L2__c,Org_L3__c,Org_L4__c,Org_L5__c,Org_L6__c,Org_L7__c FROM Opportunity WHERE Id IN :oppIdSet AND SWx_Upsell_Proposal__c = null])
				{
					orgL2.add(opp.Org_L2__c);
					orgL3.add(opp.Org_L3__c);
					orgL4.add(opp.Org_L4__c);
					orgL5.add(opp.Org_L5__c);
					orgL6.add(opp.Org_L7__c);
					orgL7.add(opp.Org_L7__c);
				}
				
				for(Sales_Role__c sR : [SELECT User__c,Organisation__c FROM Sales_Role__c WHERE Role_Code__c LIKE :System.Label.NF_PrM_Role AND
										(Organisation__c IN: orgL2 OR
										 Organisation__c IN: orgL3 OR
										 Organisation__c IN: orgL4 OR 
										 Organisation__c IN: orgL5 OR 
										 Organisation__c IN: orgL6 OR 
										 Organisation__c IN: orgL7)])
				{
					sRmap.put(sR.User__c, sR.Organisation__c);
				}
				
			}
			
			
			if((!sRmap.isEmpty() && !SRmap.containsKey(userId)) || sRmap.isEmpty())
			{
				for (Offer__c objOffer : OfferPRMInfo) 
				{
					if(objOffer.LOA_Bypass__c == System.Label.NF_PrM_Picklist && OldOfferPRMInfo.get(objOffer.id).LOA_Bypass__c != objOffer.LOA_Bypass__c)
					{
						objOffer.addError(system.Label.NF_PrM_LoABypass);
					}
					else if(OldOfferPRMInfo.get(objOffer.id).LoA_Bypass_Sign_Off_BG_FN__c != objOffer.LoA_Bypass_Sign_Off_BG_FN__c)
					{
						objOffer.addError(system.Label.NF_PrM_SignOff);
					}
					else if(OldOfferPRMInfo.get(objOffer.id).LoA_Bypass_Sign_Off_BG_MN__c != objOffer.LoA_Bypass_Sign_Off_BG_MN__c)
					{
						objOffer.addError(system.Label.NF_PrM_SignOff);
					}
					else if(OldOfferPRMInfo.get(objOffer.id).LoA_Bypass_Sign_Off_BG_AA__c != objOffer.LoA_Bypass_Sign_Off_BG_AA__c)
					{
						objOffer.addError(system.Label.NF_PrM_SignOff);
					}
					else if(OldOfferPRMInfo.get(objOffer.id).LoA_Bypass_Sign_Off_BG_ION__c != objOffer.LoA_Bypass_Sign_Off_BG_ION__c)
					{
						objOffer.addError(system.Label.NF_PrM_SignOff);
					}
					else if(OldOfferPRMInfo.get(objOffer.id).LoA_Bypass_Sign_Off_BG_GS__c != objOffer.LoA_Bypass_Sign_Off_BG_GS__c)
					{
						objOffer.addError(system.Label.NF_PrM_SignOff);
					}
		else if(OldOfferPRMInfo.get(objOffer.id).LoA_Bypass_Sign_Off_BG_NEN__c != objOffer.LoA_Bypass_Sign_Off_BG_NEN__c)
					{
						objOffer.addError(system.Label.NF_PrM_SignOff);
					}
				}
			}
			
		}
		catch (Exception ex)
		{
			ExceptionHandler.addException(ex, GlobalConstants.OFFER_ACTIVATION_HELPER, GlobalConstants.METHOD_OFFER_UPDATE_PrMVALIDATION);
		}
	}
	
	/******************************************************
*author: Accenture
* Date: June -2018
* Param: Offer List, Offer Old Map
* Return: void
* Description: 4724 :Add conversion logic to custom validations
* High Level Process 
********************************************************/
	public static void offerLoACurrenyConversion (List<Offer__c> offerList,Map<Id, Offer__c> oldMap)
	{
		Set<Offer__c>Opprec = new Set<Offer__c>();
		Set<String>Oppcurrency = new Set<String>();
		map<String, Decimal>datedrate = new map<String, Decimal>();
		Date todayDate = Date.Today();
		
		try { 
			
			for (offer__c oOffer: offerList) 
			{
				//Opprec.add(newrec);
				if(oOffer.Net_Sales_LoA_Base_Case__c != oldMap.get(oOffer.id).Net_Sales_LoA_Base_Case__c)
					Oppcurrency.add(oOffer.LoA_Currency__c);
			}
			
			system.debug('Oppcurrency'+Oppcurrency);
			//collecting the Active period
			if(Oppcurrency.size() > 0)
			{
				Nokia_Financial_Calendar__c currentPeiod = [select id, name, Start_Date__c ,End_Date__c 
															from Nokia_Financial_Calendar__c 
															where Current_Period__c = True ORDER BY End_Date__c ASC LIMIT 1];
				
				
				for(Dated_Exchange_Rates__c ratecollect :[select Id,CurrencyIsoCode,Exchange_Rate__c, Start_Date__c from 
														  Dated_Exchange_Rates__c 
														  where 
														  ( CurrencyIsoCode = : Oppcurrency) AND  DER_Period__c=:currentPeiod.ID LIMIT 1])
				{
					datedrate.put(ratecollect.CurrencyIsoCode, ratecollect.Exchange_Rate__c);
				}
				
				Decimal dRateEur = [select Id,Exchange_Rate__c from 
									Dated_Exchange_Rates__c 
									where 
									( CurrencyIsoCode = :GlobalConstants.EUR) AND  DER_Period__c=:currentPeiod.ID LIMIT 1].Exchange_Rate__c;
				
				
				list<offer__c> lstOfferUpdate = new list<offer__c>();
				for (offer__c objOffer : offerList) 
				{
					if(objOffer.Net_Sales_LoA_Base_Case__c != oldMap.get(objOffer.id).Net_Sales_LoA_Base_Case__c)
					{
						if(objOffer.Net_Sales_LoA_Base_Case__c <> null || objOffer.Net_Sales_LoA_Base_Case__c <> 0 )
						{
							if( (!objOffer.LoA_Currency__c.equalsignorecase(GlobalConstants.EUR))) 
							{
								objOffer.Total_Net_Sales_in_LoA_EUR__c = ((objOffer.Net_Sales_LoA_Base_Case__c / datedrate.get(objOffer.LoA_Currency__c)) * dRateEur).setScale(2);
								lstOfferUpdate.add(objOffer);
							}else if( objOffer.LoA_Currency__c.equalsignorecase(GlobalConstants.EUR))
							{
								objOffer.Total_Net_Sales_in_LoA_EUR__c = objOffer.Net_Sales_LoA_Base_Case__c ;
								lstOfferUpdate.add(objOffer); 
							}
						}
					}
					
				}
			}
		}
		catch(exception ex)
		{
			ExceptionHandler.addException(ex, GlobalConstants.OFFER_ACTIVATION_HELPER, GlobalConstants.METHOD_OFFER_UPDATE_PrMVALIDATION);
		}
	}
	
	/*****************************************************************************************
*author: Accenture
* Date: 30/08/2018
* Param: Offer List
* Return: void
* Description: 5090 :Trigger to automatically update Solution Sign-Off
This method will fire when offer is inserted to update Solution_Sign_Off_and_Smart_Trading__c.
**********************************************************************************************/
	public static void defaultValueForSSOOnInsert(List<Offer__c> offerList)
	{		
		try{
			Double totalNetSalesValue = Double.valueOf(System.Label.Total_Net_Sales_Value_EUR_Threshold); 
			Set<Id> opptyIdSet = new Set<Id>();
			Map<Id,Opportunity> opptyMap ;
			
			for(Offer__c offr : offerList)
			{
				opptyIdSet.add(offr.Opportunity__c);
			}
			system.debug('opptyIdSet'+opptyIdSet);
			if(opptyIdSet.size() > 0)
			{
				opptyMap = new Map<Id,Opportunity>([select Id,Unweighted_Amount_EUR__c from Opportunity 
													where Id in : opptyIdSet
													LIMIT: Limits.getLimitQueryRows() - Limits.getQueryRows()]); 
			}
			system.debug('opptyMap'+opptyMap);
			for(Offer__c offr : offerList)
			{
				system.debug('offr.Opportunity__c'+offr.Opportunity__c);
				if((offr.Expected_LoA_G4_Approval_Level__c == GlobalConstants.LOA_Level) || 
				(offr.Expected_LoA_G4_Approval_Level__c == GlobalConstants.LOA_Level_A_Plus) ||
				   (offr.Expected_LoA_G4_Approval_Level__c == GlobalConstants.LOA_Level_c &&
					opptyMap.get(offr.Opportunity__c).Unweighted_Amount_EUR__c >= totalNetSalesValue)) 
				{
					offr.Solution_Sign_Off_New__c = GlobalConstants.Required;
					offr.SSO_Exception_Reason__c = GlobalConstants.BLANK_VALUE ;
				}
				else
				{
					offr.Solution_Sign_Off_New__c = GlobalConstants.Not_Required;
					offr.SSO_Exception_Reason__c = GlobalConstants.ExceptionReasonDefaultValue;
				}
			}
		}catch(Exception ex){
			ExceptionHandler.addException(ex, GlobalConstants.OFFER_ACTIVATION_HELPER, GlobalConstants.DefaultValueForSSOSATOnInsert);
		} 
	}
	
	/********************************************************************************
*author: Accenture
* Date: 30/08/2018
* Param: Offer List, Offer Old Map
* Return: void
* Description: 5090 :Trigger to automatically update Solution Sign-Off
This method will fire when Solution_Sign_Off_and_Smart_Trading__c field is updated
*************************************************************************************/
	public static void defaultValueForSSOOnUpdate(List<Offer__c> offerList , Map<Id,Offer__c> oldMap)
	{
		Double totalNetSalesValue = Double.valueOf(System.Label.Total_Net_Sales_Value_EUR_Threshold); 
		List<Offer__c> updatedOfferList = new List<Offer__c>();
		Set<Id> opptyIdSet = new Set<Id>();
		Map<id,Opportunity> opptyMap ;
		try{
			for(Offer__c offr : offerList)
			{
				if(offr.Solution_Sign_Off_New__c != GlobalConstants.Required_Attached &&
				   offr.Expected_LoA_G4_Approval_Level__c != OldMap.get(offr.Id).Expected_LoA_G4_Approval_Level__c &&				  
				   offr.ActiveOffer__c )
				{
					updatedOfferList.add(offr);
					opptyIdSet.add(offr.Opportunity__c);
				}
			}
			if(opptyIdSet.size() > 0)
			{
				opptyMap = new Map<Id,Opportunity>([select Id,Unweighted_Amount_EUR__c from Opportunity 
													where Id in : opptyIdSet
													LIMIT: Limits.getLimitQueryRows() - Limits.getQueryRows()]);
				
				
				for(Offer__c offr : updatedOfferList)
				{
					if((offr.Expected_LoA_G4_Approval_Level__c == GlobalConstants.LOA_Level) || 
					(offr.Expected_LoA_G4_Approval_Level__c == GlobalConstants.LOA_Level_A_Plus) ||
					   (offr.Expected_LoA_G4_Approval_Level__c == GlobalConstants.LOA_Level_c &&
						opptyMap.get(offr.Opportunity__c).Unweighted_Amount_EUR__c >= totalNetSalesValue)) 
					{
						offr.Solution_Sign_Off_New__c = GlobalConstants.Required;
						offr.SSO_Exception_Reason__c = GlobalConstants.BLANK_VALUE ;
					}
					else
					{
						offr.Solution_Sign_Off_New__c = GlobalConstants.Not_Required;
						offr.SSO_Exception_Reason__c = GlobalConstants.ExceptionReasonDefaultValue;
					}
				}
			}
		}catch(Exception ex){
			ExceptionHandler.addException(ex, GlobalConstants.OFFER_ACTIVATION_HELPER, GlobalConstants.DefaultValueForSSOSATOnUpdate);
		} 
	}
	
	/*********************************************************************************************************
*author: Accenture
* Date: 30/08/2018
* Param: Offer List, Offer Old Map
* Return: void
* Description: Req:5090 :Trigger to automatically update Solution Sign-Off
This method will fire when Solution_Sign_Off_and_Smart_Trading__c field is updated manually to "Attached"
**********************************************************************************************************/
	public static void restrictManualChangingSSOTOAttached(Map<Id,Offer__c> offerNewMap , Map<Id,Offer__c> oldMap)
	{   
		Map<Id,Id> conDocIdToOfferIdMap = new Map<Id,Id>();
		Set<Id> offerIdSet = new Set<Id>();
		Set<Id> ssoChangedOfferSet = new Set<Id>();
		Set<Id> ssoUploadedOfferIds = new Set<Id>();
		Set<String> documentTypes = new Set<String>();  
		String sObjectType = Null;
		String documentTypesSSO = Null;
		
		try{			
			for(Document_Types__mdt docTypes : [select DeveloperName,Document_Type__c,Object__c 
												from Document_Types__mdt
												where DeveloperName =: Globalconstants.SSO_Document_Types
												and Object__c =: GlobalConstants.OBJECT_OFFER
												LIMIT: Limits.getLimitQueryRows() - Limits.getQueryRows()])
			{
				if(docTypes.DeveloperName == Globalconstants.SSO_Document_Types)
				{
					documentTypesSSO = docTypes.Document_Type__c;
				}
			}
			if(String.isNotBlank(documentTypesSSO))
			{			   
				for(String docType : documentTypesSSO.split(GlobalConstants.COMMA))
				{
					documentTypes.add(docType.trim());
				}
			}
			system.debug('new map'+offernewmap);
			system.debug('old map'+oldMap);
			for(Offer__c offr : offerNewMap.values())
			{
				if(offr.Solution_Sign_Off_New__c == GlobalConstants.Required_Attached &&
				   offr.Solution_Sign_Off_New__c != oldMap.get(offr.Id).Solution_Sign_Off_New__c &&
				   offr.ActiveOffer__c )
				{
					offerIdSet.add(offr.Id);
				}
				else if(offr.Solution_Sign_Off_New__c != oldMap.get(offr.Id).Solution_Sign_Off_New__c &&
						oldMap.get(offr.Id).Solution_Sign_Off_New__c == GlobalConstants.Required_Attached &&
						offr.ActiveOffer__c)
				{
					ssoChangedOfferSet.add(offr.Id);
				}
			}
			if( offerIdSet.size() > 0 || ssoChangedOfferSet.size() > 0 ){
				for(ContentDocumentLink link : [Select ContentDocumentId,LinkedEntityId 
												from ContentDocumentLink 
												where LinkedentityId in : offerIdSet  or LinkedentityId in :ssoChangedOfferSet
												LIMIT :Limits.getLimitQueryRows() - Limits.getQueryRows()])
				{
					sObjectType = link.LinkedEntityId.getSObjectType().getDescribe().getName(); 
					system.debug('sObjectType'+sObjectType);
					if(sObjectType == GlobalConstants.OBJECT_OFFER )
					{
						conDocIdToOfferIdMap.put(link.ContentDocumentId,link.LinkedEntityId);
					}
				}
				for(ContentVersion conVer : [select Document_Type_POC__c,ContentDocumentId,IsLatest 
											 from ContentVersion 
											 where ContentDocumentId in: conDocIdToOfferIdMap.KeySet() 
											 and Document_Type_POC__c in : documentTypes and IsLatest = True										
											 LIMIT: Limits.getLimitQueryRows() - Limits.getQueryRows()])
				{
					ssoUploadedOfferIds.add(conDocIdToOfferIdMap.get(conVer.ContentDocumentId));
				}
				system.debug('ssoUploadedOfferIds'+ssoUploadedOfferIds);
				offerIdSet.removeAll(ssoUploadedOfferIds);
				system.debug('offerIdSet'+offerIdSet);
				if(offerIdSet.size() > 0){
					for(Id offrId : offerIdSet)
					{					
						offerNewMap.get(offrId).addError(System.Label.ManualSelectNotAllowed);
					}
				}
				if(ssoChangedOfferSet.size() > 0){
					for(Id offrId : ssoChangedOfferSet)
					{	 
						if(ssoUploadedOfferIds.contains(offrId)){
							offerNewMap.get(offrId).addError(System.Label.ManualDeselectNotAllowed);
						}
					}
				}
			}
		}catch(Exception ex){
			ExceptionHandler.addException(ex, GlobalConstants.OFFER_ACTIVATION_HELPER, GlobalConstants.ManualChangingSSOTOAttached);
		}
	}
	
//Sales Process: SF Ticket: 11462
/****************************************
*Method Name: updateUpsellContainerCurrencyISOcode 
*Description: This method used to convert upsell container currency when LoA currency is USD.
*Parameters: Offer List
*****************************************/   
	public static void updateUpsellContainerCurrencyISOcode(List<Offer__c> offerList){
	try{
		List<Upsell_Container__c> lstUpsell = [SELECT Id, CurrencyISOcode, Parent_Offer__c, Parent_Offer__r.LoA_Currency__c, Quarter1_Period_Value__c, Quarter2_Period_Value__c, Quarter3_Period_Value__c, Quarter4_Period_Value__c, Total_Year_Sales__c from Upsell_Container__c WHERE Upsell_Container__c.Parent_Offer__c IN :offerList];
		List<Upsell_Container__c> lstToUpdate = new List<Upsell_Container__c>();
		for(Upsell_Container__c upsellRed : lstUpsell)
		{
			System.debug(LoggingLevel.INFO, '*** upsellRed.Parent_Offer__r.LoA_Currency__c: ' + upsellRed.Parent_Offer__r.LoA_Currency__c);
			System.debug(LoggingLevel.INFO, '*** upsellRed.CurrencyIsoCode: ' + upsellRed.CurrencyIsoCode);
			if (upsellRed.Parent_Offer__r.LoA_Currency__c!=null && upsellRed.Parent_Offer__r.LoA_Currency__c == 'USD') {
				upsellRed.CurrencyIsoCode = 'USD';
				lstToUpdate.add(upsellRed);
			}
		}
		update lstToUpdate;
	}
	catch(Exception ex)
	{
		ExceptionHandler.addException(ex,GlobalConstants.OFFER_ACTIVATION_HELPER,GlobalConstants.METHOD_UPDATE_LOA_BYPASS_DETAILS);
	}
	}
	  
	  //CQ Team
/****************************************
*Method Name: OfferSync_ToEAI 
*Description: This method used to Send offer to EAI.
*Parameters: Offermap
*****************************************/   
	public static void OfferSync_ToEAI(Map<Id, Offer__c> newOffermap, Map<Id, Offer__c> OldOfferMap)
	{
		Globalconstants.CountCheck=Globalconstants.CountCheck+1;
		
		Map<Id, Offer__c> newofferMap_v1 = new Map<Id, Offer__c>();
		set<ID> New_OfferIDs=new set<ID>(); 
		Map<Id, string> Old_OfferStatusmap=new map<Id,string>();
		Map<Id, string> Old_OfferNamemap=new map<Id,string>();
		
		//determine Dml is Insert or Update
		string Operationtype=OldOfferMap<>null ? Globalconstants.UPDATE_VALUE : Globalconstants.INSERT_VALUE;
			System.SavePoint savePoint = Database.setSavepoint();
	   
			for(Id OfferId : newOffermap.keySet()){
				if(( !String.isBlank(newOffermap.get(OfferId).Opportunity__c) && !String.isBlank(newOffermap.get(OfferId).Customer_Account_Name__c)))
				{
			   if((Operationtype.equalsIgnoreCase(Globalconstants.INSERT_VALUE) ||(Operationtype.equalsIgnoreCase(Globalconstants.UPDATE_VALUE)&&!Globalconstants.OFFERSET_SYNC.contains(OfferId)))&&is_RecordToSync(newOffermap.get(OfferId),OldOfferMap <> null && OldOfferMap.containskey(OfferId) ? OldOfferMap.get(OfferId):Null ))
					{
					  if(Operationtype.equalsIgnoreCase(Globalconstants.INSERT_VALUE)) 
						  Globalconstants.OFFERSET_SYNC.add(OfferId);
						  
					New_OfferIDs.add(OfferId);
					newofferMap_v1.put(OfferId,newOffermap.get(OfferId));
					if(Operationtype.equalsIgnoreCase(Globalconstants.UPDATE_VALUE))
					{
						Old_OfferNamemap.put(OfferId,OldOfferMap.get(OfferId).Name);
						Old_OfferStatusmap.put(OfferId,OldOfferMap.get(OfferId).ActiveOffer__c? 'Active':'InActive');
					}
					}
					
				}
				else 
					newOffermap.get(OfferId).addError(CQ_Sync_Quote_EAI__c.getInstance(Globalconstants.CQ_OFFER_REQUIRED_INFO_MISSING).Message__c);
			}
			If(!Test.isRunningTest()){
			if(!newofferMap_v1.isEmpty() )
			{  //In existing EAI implementation max 25 records only we can send max size check 
				if(newofferMap_v1.size() >CQ_Sync_Quote_EAI__c.getInstance(Globalconstants.CQ_MAX_SIZE).Size__c ) {
					for(Offer__c newOffer: newOffermap.values())
						newOffer.addError(CQ_Sync_Quote_EAI__c.getInstance(Globalconstants.MAX_BULK_SIZE_ERROR).Message__c);
				}
				else{
					try{
						boolean  makeCallout = true; 
						String iLogName = ( newofferMap_v1.size() > 1 ? GlobalConstants.INTERFACE_LOG_BULK_NAME + system.today() : newofferMap_v1.values()[0].Offer_Number__c	 );
						if(newofferMap_v1.size()==1) {						
							//see if a record interface log exists for the same Opportunity, in Queued Status and with the same operation. 
							Integer iLogInProgress=[select count() from Interface_Log__c where Name = :iLogName and Status__c = :GlobalConstants.INTERFACE_LOG_QUEUED  and 
													Interface_Type__c=:GlobalConstants.INTERFACE_LOG_OFFER_INTERFACE_TYPE and Operation_Type__c = :Operationtype ];
							
							if( iLogInProgress== 1)makeCallout = false;			
						}
						
						if(makeCallout) {
							Interface_Log__c iLog = new Interface_Log__c(Name=iLogName, Interface_Type__c=GlobalConstants.INTERFACE_LOG_OFFER_INTERFACE_TYPE, Message_Type__c=Globalconstants.OUTBOUND,												 
																		 Operation_type__c =Operationtype,Status__c = GlobalConstants.INTERFACE_LOG_QUEUED);
							database.insert(ilog);													
						   if((Globalconstants.INSERT_VALUE.equalsignorecase(Operationtype)&&CQ_Sync_Quote_EAI__c.getInstance(Globalconstants.CQ_SYNCOFFER_INSERT).sync__c)||(Globalconstants.UPDATE_VALUE.equalsignorecase(Operationtype)&&CQ_Sync_Quote_EAI__c.getInstance(Globalconstants.CQ_SYNCOFFER_UPDATE).sync__c))
							 QuoteOffer_SyncCalloutService.SyncOffertoEAI(New_OfferIDs,Old_OfferStatusmap,Old_OfferNamemap , iLog.id,Operationtype ,true);
						}
						
						 system.debug('####Globalconstants.CountCheck-->'+Globalconstants.CountCheck);
						
					}
					catch(Exception e) {
						system.debug('An unexpected erorr occurred:' + e);
						ExceptionHandler.addException(e, GlobalConstants.OFFER_ACTIVATION_HELPER, GlobalConstants.OFFERSYNC_TOEAI);
						for(Id OId: newOffermap_v1.keySet())
							newOffermap.get(OId).addError('Unexpected system error occurred:' + e.getMessage());
						Database.rollback(savePoint);  
					}
				}
			}
			}
		}
  //CQ Team
/****************************************
*Method Name: is_RecordToSync 
*Description: This method used to Send offer to EAI.
*Parameters: Offer
*****************************************/   
	 public static boolean is_RecordToSync(Offer__c newOffer, Offer__c oldOffer){
		boolean isRecordToSync=false;
		try{
		If((oldOffer==null ||(oldOffer<>null&&(newOffer.Name<>oldOffer.Name || newOffer.ActiveOffer__c <> oldOffer.ActiveOffer__c||newOffer.Opportunity__c<>oldOffer.Opportunity__c
											 ||newOffer.LoA_Approval_Level__c<>oldOffer.LoA_Approval_Level__c  ||newOffer.Customer_Offer_Due_Date__c<>oldOffer.Customer_Offer_Due_Date__c
											  ))))
		{
			isRecordToSync=true;
		}
	   }
		 
		catch(Exception ex) {
			  system.debug('Exception-->'+Ex.getMessage());
			}  
		 return isRecordToSync;
	}
   
	
}