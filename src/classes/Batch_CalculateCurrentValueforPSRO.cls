/****************************************
 * Name : Batch_CalculateCurrentValueforPSRO
 * Author : Accenture
 * Description : calculate cost of BG in all RO/RS opportunities and update current value in Threshold object
 ****************************************/
global class Batch_CalculateCurrentValueforPSRO implements Database.Batchable<sObject>,Database.Stateful,Schedulable 
{ 
	public Map<Id, PSRO_Market_Threshold__c> Update_current_Value = new Map<Id, PSRO_Market_Threshold__c>();
	public List<PSRO_Market_Threshold__c> sendmail_List = new List<PSRO_Market_Threshold__C>();
	public Map<string, Decimal> cost_L4_BG = new Map<String, Decimal>();
	public static Decimal returnValueOfField(Decimal fieldValue){
	Return fieldValue == Null ? 0 : fieldValue;				   
	}
	/********************
	*Method Name:execute 
	*Parameter:SchedulableContext SC
	*Description:Execute the bacth 
	*******************/
  
	 global void execute(SchedulableContext SC)
	 
	 {
	   Batch_CalculateCurrentValueforPSRO  batch= new Batch_CalculateCurrentValueforPSRO();
	   Database.executebatch(batch,200);		   
	 
	 }
	/****************************************
	 * Name : start
	 * Author : Accenture
	 * Description : this method will contain the SOQL query for the batch 
	 *****************************************/
	global Database.QueryLocator start(Database.BatchableContext BC)
	{		   
	return Database.getQueryLocator([SELECT id, PSR_Cost_Business_Group_FN__c, PSR_Cost_Business_Group_GS__c, PSR_Cost_Business_Group_ION__c, PSR_Cost_Business_Group_MN__c, PSR_Cost_BG_NEN__c, PSR_Cost_Business_Group_AA__c,
									Org_L3__c,Org_L4__c,Org_L5__c,CurrencyIsoCode FROM Opportunity where PSR_Pre_Sales_Risk_Opportunity_Type__c = 'Risk Order' AND stagename = 'In Execution']);
	} 
	/****************************************
	 * Name : execute
	 * Author : Accenture
	 * Description : Execution of the batch
	 *****************************************/
	global void execute(Database.BatchableContext BC, List<Opportunity> opptyList)
	{			 
	try
	{		 
	List<PSRO_Market_Threshold__c> ThresholdList = [Select Id, Market__c, Threshold_Value__c, current_value__c,value_exceeded__c, Business_Group__c 
													from PSRO_Market_Threshold__c];
	List<Map_Enterprise_MUs_and_Market__c> mapL5_L4 = Map_Enterprise_MUs_and_Market__c.getAll().values();
	Set<String> Oppcurrency = new Set<String>();
	Map<String, Decimal> datedrate = new Map<String, Decimal>();
	Date todayDate = Date.Today();
	for (Opportunity newrec: opptyList) 
	{				
		Oppcurrency.add(newrec.CurrencyIsoCode);
	}
	if(!opptyList.isEmpty())
	{
		for (Dated_Exchange_Rates__c ratecollect:  [select Id, CurrencyIsoCode, Exchange_Rate__c, Start_Date__c
													from Dated_Exchange_Rates__c where CurrencyIsoCode =: Oppcurrency  
													AND Start_Date__c<=: todayDate
													Order By Start_Date__c ASC LIMIT: Limits.getLimitQueryRows()])
		{
		datedrate.put(ratecollect.CurrencyIsoCode, ratecollect.Exchange_Rate__c);
		}
	}
	
	for(Opportunity opportunity : opptyList)
	{
		string orgL4 = opportunity.org_l4__c;
		If(opportunity.Org_L3__c == GlobalConstants.Nokia_Enterprise)
		{
			for(Map_Enterprise_MUs_and_Market__c mapobj : mapL5_L4)
			{
			If(mapobj.Enterprise_MU__c == opportunity.org_l5__c)
			{ orgl4 = mapobj.Market__c; }	   
			}
		}
		for(PSRO_Market_Threshold__c BGVal : ThresholdList)
		{
			Decimal BG_cost = 0;
			If(BGVal.Market__c == orgL4)
			{
			If(BGVal.Business_Group__c ==  GlobalConstants.Lead_BG_NSW && opportunity.PSR_Cost_Business_Group_AA__c != null)
			{ 
			BG_cost = (returnValueOfField(opportunity.PSR_Cost_Business_Group_AA__c)).divide(datedrate.get(opportunity.CurrencyIsoCode),2,System.RoundingMode.HALF_UP);
			if(cost_L4_BG.containsKey(orgL4+BGVal.Business_Group__c))
			{
			BG_cost = cost_L4_BG.get(orgL4+BGVal.Business_Group__c) + BG_cost;
			cost_L4_BG.put(orgL4+BGVal.Business_Group__c,BG_cost);
			}
			else
			{
			cost_L4_BG.put(orgL4+BGVal.Business_Group__c,BG_cost);
			}
			BGVal.current_value__c = BG_cost;
			update_current_value.put(BGVal.Id,BGVal); 
			}
			If(BGVal.Business_Group__c ==  GlobalConstants.LEAD_BG_FN && opportunity.PSR_Cost_Business_Group_FN__c != null)
			{   
			BG_cost = (returnValueOfField(opportunity.PSR_Cost_Business_Group_FN__c)).divide(datedrate.get(opportunity.CurrencyIsoCode),2,System.RoundingMode.HALF_UP);
			if(cost_L4_BG.containsKey(orgL4+BGVal.Business_Group__c))
			{
			BG_cost = cost_L4_BG.get(orgL4+BGVal.Business_Group__c) + BG_cost;
			cost_L4_BG.put(orgL4+BGVal.Business_Group__c,BG_cost);
			}
			else
			{
			cost_L4_BG.put(orgL4+BGVal.Business_Group__c,BG_cost);
			}
			BGVal.current_value__c = BG_cost;
			update_current_value.put(BGVal.Id,BGVal); 
			}
			If(BGVal.Business_Group__c ==  GlobalConstants.LEAD_BG_ION && opportunity.PSR_Cost_Business_Group_ION__c != null)
			{   
			BG_cost = (returnValueOfField(opportunity.PSR_Cost_Business_Group_ION__c)).divide(datedrate.get(opportunity.CurrencyIsoCode),2,System.RoundingMode.HALF_UP);
			if(cost_L4_BG.containsKey(orgL4+BGVal.Business_Group__c))
			{
			BG_cost = cost_L4_BG.get(orgL4+BGVal.Business_Group__c) + BG_cost;
			cost_L4_BG.put(orgL4+BGVal.Business_Group__c,BG_cost);
			}
			else
			{
			cost_L4_BG.put(orgL4+BGVal.Business_Group__c,BG_cost);
			}
			BGVal.current_value__c = BG_cost;
			update_current_value.put(BGVal.Id,BGVal); 
			}
			
			If(BGVal.Business_Group__c ==  GlobalConstants.LEAD_BG_MN && opportunity.PSR_Cost_Business_Group_MN__c != null)
			{   
			BG_cost = (returnValueOfField(opportunity.PSR_Cost_Business_Group_MN__c)).divide(datedrate.get(opportunity.CurrencyIsoCode),2,System.RoundingMode.HALF_UP);
			if(cost_L4_BG.containsKey(orgL4+BGVal.Business_Group__c))
			{
			BG_cost = cost_L4_BG.get(orgL4+BGVal.Business_Group__c) + BG_cost;
			cost_L4_BG.put(orgL4+BGVal.Business_Group__c,BG_cost);
			}
			else
			{
			cost_L4_BG.put(orgL4+BGVal.Business_Group__c,BG_cost);
			update_current_value.put(BGVal.Id,BGVal); 
			}
			BGVal.current_value__c = BG_cost;
			update_current_value.put(BGVal.Id,BGVal); 
			}
			If(BGVal.Business_Group__c ==  GlobalConstants.LEAD_BG_GS && opportunity.PSR_Cost_Business_Group_GS__c != null)
			{   
			BG_cost = (returnValueOfField(opportunity.PSR_Cost_Business_Group_GS__c)).divide(datedrate.get(opportunity.CurrencyIsoCode),2,System.RoundingMode.HALF_UP);

			if(cost_L4_BG.containsKey(orgL4+BGVal.Business_Group__c))
			{
			BG_cost = cost_L4_BG.get(orgL4+BGVal.Business_Group__c) + BG_cost;
			cost_L4_BG.put(orgL4+BGVal.Business_Group__c,BG_cost);
			}
			else
			{
			cost_L4_BG.put(orgL4+BGVal.Business_Group__c,BG_cost);
			}
			BGVal.current_value__c = BG_cost;
			update_current_value.put(BGVal.Id,BGVal); 
			}
			If(BGVal.Business_Group__c == GlobalConstants.LEAD_BG_NEN && opportunity.PSR_Cost_BG_NEN__c != null)
			{   
			BG_cost = (returnValueOfField(opportunity.PSR_Cost_BG_NEN__c)).divide(datedrate.get(opportunity.CurrencyIsoCode),2,System.RoundingMode.HALF_UP);
			if(cost_L4_BG.containsKey(orgL4+BGVal.Business_Group__c))
			{
			BG_cost = cost_L4_BG.get(orgL4+BGVal.Business_Group__c) + BG_cost;
			cost_L4_BG.put(orgL4+BGVal.Business_Group__c,BG_cost);
			}
			else
			{
			cost_L4_BG.put(orgL4+BGVal.Business_Group__c,BG_cost);
			}
			BGVal.current_value__c = BG_cost;
			update_current_value.put(BGVal.Id,BGVal); 
			}					
		}
		}
	}
	}
	catch(Exception ex)
	{	
	   ExceptionHandler.addException(ex, GlobalConstants.Batch_CalculateCurrentValueforPSRO, GlobalConstants.Batch_CalculateCurrentValueforPSRO);
	}	
	}
	
	global void finish(Database.BatchableContext BC)
	{	
	try
	{
	List<PSRO_Market_Threshold__c> calcurrentvalue = [Select Id, Market__c, Threshold_Value__c, current_value__c,value_exceeded__c, Business_Group__c 
													from PSRO_Market_Threshold__c];
	List<PSRO_Market_Threshold__c> UpdateTHList = new List<PSRO_Market_Threshold__c>();
	if(!update_current_value.isEmpty())
	{
	 for(PSRO_Market_Threshold__c clearval: calcurrentvalue)
	 {
		 If(update_current_value.containskey(clearval.Id))
		 {
			 PSRO_Market_Threshold__c updateval = update_current_value.get(clearval.Id);
			 IF(updateval.current_value__c > updateval.Threshold_Value__c && updateval.value_exceeded__c == false)
	{				
	sendmail_list.add(updateval);
	updateval.value_exceeded__c = true;
	}
			else if(updateval.current_value__c < updateval.Threshold_Value__c && updateval.value_exceeded__c == true)	
			{
	updateval.value_exceeded__c = false;
			}	
			UpdateTHList.add(updateval);
			 
		 }
		 else
		 {
		  clearval.Current_value__c = 0;
		  clearval.value_exceeded__c = false;
		  UpdateTHList.add(clearval); 
		 }
	 } 
	database.update(UpdateTHList);
	}
	else
	{	
	   for(PSRO_Market_Threshold__c clearval: calcurrentvalue)
	   {
	   clearval.current_value__c = 0;
	   clearval.value_exceeded__c = false;
	   UpdateTHList.add(clearval);
	   }
	database.update(updatethlist);
	}
	if(!sendmail_List.isEmpty())
	{
	//PSRO_Calculate_BG_Cost triggermail = new PSRO_Calculate_BG_Cost();
	PSRO_Calculate_BG_Cost.psroThresholdMail(sendmail_List);
	}
	}
	catch(Exception ex)
	{	
	   ExceptionHandler.addException(ex, GlobalConstants.Batch_CalculateCurrentValueforPSRO, GlobalConstants.Batch_CalculateCurrentValueforPSRO);
	}
	}
}