/******************************************************************************************************
Name : IndirectCPQ_ProposalTriggerHandler
Created by: Accenture
Description : Handler class for Indirect CPQ to handle quote process.		
*********************************************************************************************************/
public class IndirectCPQ_ProposalTriggerHandler {
/******************************
*Method Name: afterUpdateMethod
*Description: This Method is used to handle after update logic of Proposal Trigger for Indirect
 ********************************/
	public static void afterUpdateMethod(List<Apttus_Proposal__Proposal__c> updatedQuoteList,Map<Id, Apttus_Proposal__Proposal__c> oldQuoteMap ){
		try{
			Set<Id> quoteIDSet = new Set<Id>();
			 for(Apttus_Proposal__Proposal__c quoteRecord : updatedQuoteList ){
				if( quoteRecord.Quote_Type__c.equalsIgnoreCase(Nokia_CPQ_Constants.QUOTE_TYPE_INDIRECTCPQ) && 
				  ( quoteRecord.Maintenance_Y1__c != oldQuoteMap.get(quoteRecord.Id).Maintenance_Y1__c ||
					quoteRecord.Maintenance_Y2__c != oldQuoteMap.get(quoteRecord.Id).Maintenance_Y2__c ||
					quoteRecord.SSP__c != oldQuoteMap.get(quoteRecord.Id).SSP__c ||
					quoteRecord.SRS__c != oldQuoteMap.get(quoteRecord.Id).SRS__c) )
				  {
				   
					quoteIDSet.add(quoteRecord.Id);
				  }
			}
		   if( quoteIDSet.size() > 0){
			 IndirectCPQ_ProposalTriggerHelper.UpdateStatusOnLI(quoteIDSet);
		   }
		  }catch(Exception ex){
			ExceptionHandler.addException(ex, IndirectCPQ_ProposalTriggerHandler.class.getName(), Nokia_CPQ_Constants.ERROR_MSD);
		}
	}
}