/******************************************************************************************************
Name : IndirectCPQ_ProposalTriggerHelper
Created by: Accenture
Description : Helper class for Indirect CPQ to handle quote process.		
*********************************************************************************************************/
public class IndirectCPQ_ProposalTriggerHelper {
/******************************
*Method Name: updateStatusonLI
*Description: This Method is used to update Pricing Status On Config LI once Prices are overridden at Quote Level.
 ********************************/
	public static void updateStatusonLI(Set<ID> quoteIDSet){
		try{
			Set<Id>productConfigIDSet = new Set<Id>();
			List <Apttus_Config2__LineItem__c> configLIList = new List<Apttus_Config2__LineItem__c>();
			  for(Apttus_Config2__ProductConfiguration__c config : [Select ID,Name from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c IN : quoteIDSet and Apttus_Config2__Status__c = : Nokia_CPQ_Constants.Saved ]){
				   productConfigIDSet.add(config.Id);
				 }
		
			  for(Apttus_Config2__LineItem__c configLI : [Select ID, Name, Apttus_Config2__ChargeType__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c IN : productConfigIDSet]){
				if(configLI.Apttus_Config2__ChargeType__c.equalsIgnoreCase(Nokia_CPQ_Constants.STANDARD)){
				configLI.Apttus_Config2__PricingStatus__c = Nokia_CPQ_Constants.PENDING_STRING;
				configLIList.add(configLI);
			}
		}
		database.update(configLIList); 
	   }
		Catch(Exception ex){
			ExceptionHandler.addException(ex, IndirectCPQ_ProposalTriggerHelper.class.getName(), Nokia_CPQ_Constants.ERROR_MSD);
		}
		
	}
}