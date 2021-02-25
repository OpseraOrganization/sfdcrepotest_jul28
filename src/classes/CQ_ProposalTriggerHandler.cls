/*Description: Handler Class for Quote/Proposal Trigger for Contracted Quote Record Type
*******************************/
public class CQ_ProposalTriggerHandler {
	Public static final Id Contracted_Quote_RecId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(Label.CQ_RecordTypeId).getRecordTypeId();
	Public static final Id CQ_Read_Only_RecId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get('CQ_Read_Only').getRecordTypeId();
	
	/*****************************
/*Method Name: BeforeInsert
*Description: This method is used to create quote team on CQ quote creation
*Parameters:  Quote/Proposal List
*Created By: Accenture - April 2019
*Last Modified By: Accenture
*Last Modified Date: 19-04-2019
*******************************/
	public static void BeforeInsert(list<Apttus_Proposal__Proposal__c> CQ_newList){ 
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id))
		{
			//Record type check		
			list<Apttus_Proposal__Proposal__c> CQ_newList_WithRecord=new list<Apttus_Proposal__Proposal__c>();			
			for(Apttus_Proposal__Proposal__c Quote:CQ_newList)
				if(QUote.RecordtypeId<>null&&(QUote.RecordtypeId==Contracted_Quote_RecId ||QUote.RecordtypeId==CQ_Read_Only_RecId ))
				CQ_newList_WithRecord.add(Quote);
			
			//IF CQ Records There Available
			if(!CQ_newList_WithRecord.isempty()){
				CQ_ProposalTriggerHelper.CQ_eQuoteCheck(CQ_newList_WithRecord);
				CQ_ProposalTriggerHelper.createQuoteNumber(CQ_newList_WithRecord);
			}
		}
	}
	/*Method Name: AfterInsert
*Description: This method is used to create quote team on CQ quote creation
*Parameters:  Quote/Proposal Map
*Created By: Accenture - April 2019
*Last Modified By: Accenture
*Last Modified Date: 19-04-2019
*******************************/
	public static void AfterInsert(Map<Id,Apttus_Proposal__Proposal__c> CQ_newMap){
		try{
			if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id))
			{
				//Record type check
				Map<Id,Apttus_Proposal__Proposal__c> CQ_newMap_WithRecord=new  Map<Id,Apttus_Proposal__Proposal__c>();
				Map<Id,Id> CQ_Acct_map = new Map<Id,Id>();
	
				for(Apttus_Proposal__Proposal__c Quote:CQ_newMap.values())
				{
					if(QUote.RecordtypeId<>null&&(QUote.RecordtypeId==Contracted_Quote_RecId ||QUote.RecordtypeId==CQ_Read_Only_RecId ))
					{
						CQ_newMap_WithRecord.put(Quote.Id, Quote);
			CQ_Acct_map.put(Quote.Id, Quote.Apttus_Proposal__Account__c);
					}
				}
				//IF CQ Records There Available
				if(!CQ_newMap_WithRecord.isEmpty()){
					
					CQ_QuotetoReporting.CQ_Report_Insert(CQ_newMap_WithRecord);
					CQ_ProposalTriggerHelper.Sync_QuotestoEAI(CQ_newMap_WithRecord,null);
		CQ_ProposalTriggerHelper.createQuoteTeamoncqcreation(CQ_newMap_WithRecord.values());
		CQ_ProposalTriggerHelper.CQTerritorysharing(CQ_newMap_WithRecord, CQ_Acct_map);
				}
			}
		}
		catch(exception ex){
			ExceptionHandler.addException(ex, GlobalConstants.CQ_ProposalTriggerHandler, GlobalConstants.CQ_ProposalTriggerHandler_AfterInsert);  
		}
	}
	/*Method Name: BeforeUpdate
*Description: This method is used to create quote team on CQ quote creation
*Parameters:  Quote/Proposal Map
*Created By: Accenture - April 2019
*Last Modified By: Accenture
*Last Modified Date: 19-04-2019
*******************************/ 
	public static void BeforeUpdate(Map<Id,Apttus_Proposal__Proposal__c> newMap, Map<Id,Apttus_Proposal__Proposal__c> oldMap){
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id))
		{
			//Record type check
			Map<Id,Apttus_Proposal__Proposal__c> CQ_newMap_WithRecord=new  Map<Id,Apttus_Proposal__Proposal__c>();
			for(Apttus_Proposal__Proposal__c Quote:newMap.values())
				if(QUote.RecordtypeId<>null&&(QUote.RecordtypeId==Contracted_Quote_RecId ||QUote.RecordtypeId==CQ_Read_Only_RecId ))
				CQ_newMap_WithRecord.put(Quote.Id, Quote);
			
			if(!CQ_newMap_WithRecord.isempty()){
				if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)
				   && GlobalConstants.IS_CQHANDLERUPDATEFIRSTRUN){
					   GlobalConstants.IS_CQHANDLERUPDATEFIRSTRUN = False;
					   //If this is an inbound update message from EAI, then call these methods
					   if(GlobalConstants.IS_INBOUND){
						   CQ_ProposalTriggerHelper.updateSurroundPricedAccount(CQ_newMap_WithRecord.values(),oldMap);
						   CQ_ProposalTriggerHelper.updateeQuoteStatus(oldMap.values(),CQ_newMap_WithRecord);
					   }
				   }
			}
		}
	}
	/*Method Name: AfterUpdate
*Description: This method is used to create quote team on CQ quote creation
*Parameters:  Quote/Proposal Map
*Created By: Accenture - April 2019
*Last Modified By: Accenture
*Last Modified Date: 19-04-2019
*******************************/
	public static  void AfterUpdate(Map<Id,Apttus_Proposal__Proposal__c> newMap, Map<Id,Apttus_Proposal__Proposal__c> oldMap){
		try{
			if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id))
			{   
				//Record type check
				Map<Id,Apttus_Proposal__Proposal__c> CQ_newMap_WithRecord=new  Map<Id,Apttus_Proposal__Proposal__c>();
	Map<Id,Apttus_Proposal__Proposal__c> CQ_newMap_QTchanges=new  Map<Id,Apttus_Proposal__Proposal__c>();
	Map<Id,Apttus_Proposal__Proposal__c> CQ_sharingchagnes=new  Map<Id,Apttus_Proposal__Proposal__c>();
				Map<Id,Id> CQ_Acct_map = new Map<Id,Id>();
	
				for(Apttus_Proposal__Proposal__c Quote:newMap.values()){
					if(QUote.RecordtypeId<>null&&(QUote.RecordtypeId==Contracted_Quote_RecId ||QUote.RecordtypeId==CQ_Read_Only_RecId ))
					{
						CQ_newMap_WithRecord.put(Quote.Id, Quote);
						if(Quote.OwnerId <> oldMap.get(Quote.Id).ownerId || quote.Apttus_Proposal__Account__c <> oldMap.get(Quote.Id).Apttus_Proposal__Account__c){
							system.debug(' entered CQ_sharingchagnes');
							CQ_Acct_map.put(Quote.Id, Quote.Apttus_Proposal__Account__c);
							CQ_sharingchagnes.put(Quote.Id, Quote);
						}
			if((Quote.CQ_Lead__c <> oldMap.get(Quote.Id).CQ_Lead__c && Quote.CQ_Lead__c <> null) || (Quote.CQ_Sales_Lead__c <> oldMap.get(Quote.Id).CQ_Sales_Lead__c && Quote.CQ_Sales_Lead__c <> null)){
							CQ_newMap_QTchanges.put(Quote.Id,Quote);
						}
						
					}
					system.debug('  c.getQuickActionName()--> '+Quote.getQuickActionName());
				}
				//IF CQ Records There Available
				if(!CQ_newMap_WithRecord.isempty()){
					if( GlobalConstants.CQ_AFTERUPDATEHANDLERFIRSTRUN){
						GlobalConstants.CQ_AFTERUPDATEHANDLERFIRSTRUN = false;
						CQ_ProposalTriggerHelper.CQ_QuoteVersion_Active(CQ_newMap_WithRecord,oldMap);
						
						CQ_ProposalTriggerHelper.CQ_StatusChange_NotificationEmail(newMap,oldMap);
			
			if(!CQ_sharingchagnes.isempty()){
							CQ_ProposalTriggerHelper.CQTerritorysharingupdate(CQ_sharingchagnes,CQ_Acct_map);
						}
			if(!CQ_newMap_QTchanges.isempty()){
							CQ_ProposalTriggerHelper.CQ_QuoteTeammemberUpdate(CQ_newMap_WithRecord,oldMap);
						}
			
					}
					
					
					Globalconstants.REC_Count=Globalconstants.REC_Count+1;
					CQ_QuotetoReporting.CQ_Report_Update(CQ_newMap_WithRecord.values());
					
					if(!GlobalConstants.IS_CQUPDATEPRICINGMSG && !GlobalConstants.IS_PROCESS_QUOTE_SYNC ){
					   CQ_ProposalTriggerHelper.Sync_QuotestoEAI(CQ_newMap_WithRecord,oldMap);
		}
					
				}
				
			}  
		}catch(exception ex){
			ExceptionHandler.addException(ex, GlobalConstants.CQ_ProposalTriggerHandler, GlobalConstants.CQ_ProposalTriggerHandler_AfterUpdate);			
		}
	}
	/*Method Name: BeforeDelete
*Description: This method is used to create quote team on CQ quote creation
*Parameters:  Quote/Proposal list
*Created By: Accenture - April 2019
*Last Modified By: Accenture
*Last Modified Date: 19-04-2019
*******************************/
	 public static void BeforeDelete(list<Apttus_Proposal__Proposal__c> newList){
		try{
			if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id))
			{
				//Record type check
				Map<Id,Apttus_Proposal__Proposal__c> CQ_newMap_WithRecord=new  Map<Id,Apttus_Proposal__Proposal__c>();
				for(Apttus_Proposal__Proposal__c Quote:newList)
					if(QUote.RecordtypeId<>null&&(QUote.RecordtypeId==Contracted_Quote_RecId ||QUote.RecordtypeId==CQ_Read_Only_RecId ))
					CQ_newMap_WithRecord.put(Quote.Id, Quote);
				
				//IF CQ Records There Available
				if(!CQ_newMap_WithRecord.isempty()){
					CQ_QuotetoReporting.CQ_Report_Delete(CQ_newMap_WithRecord.values());
				}
			}
		}catch(exception ex){
			ExceptionHandler.addException(ex, GlobalConstants.CQ_ProposalTriggerHandler, GlobalConstants.CQ_ProposalTriggerHandler_BeforeDelete);			
		}
	}
	
	
}