public class PSRO_Calculate_BG_Cost {

public static Decimal returnValueOfField(Decimal fieldValue){
  Return fieldValue == Null ? 0 : fieldValue;				   
}
public static Boolean returnexceed(Opportunity NewOppty,Map<String, Decimal> Datedrate, PSRO_Market_Threshold__c BGVal)
{
Boolean exceed;
Decimal BG_Cost = 0;
If(BGVal.Business_Group__c ==  GlobalConstants.Lead_BG_NSW  && returnValueOfField(NewOppty.PSR_Cost_Business_Group_AA__c) != 0)
{   
 BG_Cost = (returnValueOfField(NewOppty.PSR_Cost_Business_Group_AA__c)).divide(datedrate.get(NewOppty.CurrencyIsoCode),2,System.RoundingMode.HALF_UP);
}
If(BGVal.Business_Group__c == GlobalConstants.Lead_BG_FN && returnValueOfField(NewOppty.PSR_Cost_Business_Group_FN__c) != 0)
{
  BG_Cost = (returnValueOfField(NewOppty.PSR_Cost_Business_Group_FN__c)).divide(datedrate.get(NewOppty.CurrencyIsoCode),2,System.RoundingMode.HALF_UP);

}
If(BGVal.Business_Group__c == GlobalConstants.Lead_BG_ION && returnValueOfField(NewOppty.PSR_Cost_Business_Group_ION__c) != 0)
{
BG_Cost = (returnValueOfField(NewOppty.PSR_Cost_Business_Group_ION__c)).divide(datedrate.get(NewOppty.CurrencyIsoCode),2,System.RoundingMode.HALF_UP);

}
If(BGVal.Business_Group__c == GlobalConstants.Lead_BG_MN && returnValueOfField(NewOppty.PSR_Cost_Business_Group_MN__c) != 0)
{
 BG_cost = (returnValueOfField(NewOppty.PSR_Cost_Business_Group_MN__c)).divide(datedrate.get(NewOppty.CurrencyIsoCode),2,System.RoundingMode.HALF_UP);
}
If(BGVal.Business_Group__c == GlobalConstants.Lead_BG_GS && returnValueOfField(NewOppty.PSR_Cost_Business_Group_GS__c) != 0)
{
BG_cost = (returnValueOfField(NewOppty.PSR_Cost_Business_Group_GS__c)).divide(datedrate.get(NewOppty.CurrencyIsoCode),2,System.RoundingMode.HALF_UP);
}
If(BGVal.Business_Group__c == GlobalConstants.Lead_BG_NEN && returnValueOfField(NewOppty.PSR_Cost_BG_NEN__c) != 0)
{
 BG_cost = (returnValueOfField(NewOppty.PSR_Cost_BG_NEN__c)).divide(datedrate.get(NewOppty.CurrencyIsoCode),2,System.RoundingMode.HALF_UP);								  
}
if(BG_cost != 0 && BG_Cost != null && ((returnValueOfField(BGVal.current_value__c) + returnValueOfField(BG_Cost)) > BGVal.Threshold_Value__c))
{ 
exceed = true; 
}
return exceed;
}
public static Opportunity calculateLoAlevel(Opportunity opportunity)
{
		Map<Id, Opportunity> preSalesOptyMapForLoAlevel = new Map<Id, Opportunity>();
		Map <Id, Opportunity> salesOptyWithApprovalDateMap = new Map <Id, Opportunity>();
		 Id PSR_EditRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.PRESALESRISKOPPORTUNITY).getRecordTypeId();	
		try{
			List<Map_Enterprise_MUs_and_Market__c> mapL5_L4 = Map_Enterprise_MUs_and_Market__c.getAll().values();
			string orgL4 = opportunity.Org_L4__c;
			If(opportunity.PSR_Pre_Sales_Risk_Opportunity_Type__c.equalsIgnoreCase(GlobalConstants.RISK_ORDER))
			{
			If(opportunity.Org_L3__c == GlobalConstants.Nokia_Enterprise)
			{
				for(Map_Enterprise_MUs_and_Market__c mapobj : mapL5_L4)
				{
				If(mapobj.Enterprise_MU__c == opportunity.org_l5__c)
				{ orgl4 = mapobj.Market__c; }	   
				}
			}
			List<PSRO_Market_Threshold__c> ThresholdList = [Select Id, Market__c, Threshold_Value__c, current_value__c, Business_Group__c 
											  from PSRO_Market_Threshold__c where Market__c = :orgL4];
			
			List<PSRO_Market_Threshold__c>  UpdateList = new List<PSRO_Market_Threshold__c> ();
			List<PSRO_Market_Threshold__c>  sendmail_List = new List<PSRO_Market_Threshold__c> ();
			 Map<String, Decimal> datedrate = new Map<String, Decimal>();
			Boolean exceed;
			Date todayDate = Date.Today();			  
		   
			   for (Dated_Exchange_Rates__c ratecollect:  [select Id, CurrencyIsoCode, Exchange_Rate__c, Start_Date__c
															from Dated_Exchange_Rates__c where CurrencyIsoCode =: opportunity.CurrencyIsoCode  
															AND Start_Date__c<=: todayDate
															Order By Start_Date__c ASC LIMIT: Limits.getLimitQueryRows()]){
																datedrate.put(ratecollect.CurrencyIsoCode, ratecollect.Exchange_Rate__c);
															}
			

					for(PSRO_Market_Threshold__c BGVal : ThresholdList)
					{   
						Decimal BG_cost = 0;
						Decimal current_value = 0;  

							Boolean checkVal = returnexceed(Opportunity,datedrate,BGVal);
							If(checkVal == true)
								exceed = true;						 
					}
					
				   
					If(exceed == true && opportunity.recordTypeId == PSR_EditRecordTypeID)
					{
					opportunity.PSR_LoA_Level__c = GlobalConstants.LOA_Level; //A
					opportunity.PSR_GateClass__c = GlobalConstants.Gate_R4;
					}
					else if(opportunity.recordTypeId == PSR_EditRecordTypeID)
					{ 
						Opportunity ParentOppty = [select id, G4_Approval_Date__c from Opportunity where id = :opportunity.PSR_Reference_Opportunity__c ]; 
							If(parentOppty.G4_Approval_Date__c == null)
							{
							   opportunity.PSR_LoA_Level__c = GlobalConstants.LOA_Level; //A
							   opportunity.PSR_GateClass__c = GlobalConstants.Gate_R4;
						   }
						else
						{
							
							List<PSR_Gate_Classification_Logic__c> objList;
							objList = PSR_Gate_Classification_Logic__c.getall().values();
							objList.sort();
							for(integer i = 0; i< objList.size(); i++){
								system.debug('Cost Value:'+opportunity.PSR_Total_Cost_In_Euro__c+'...'+objList[i].BG_Value__c+'...'+objList[i].LOA_Level__c);
								if(opportunity.PSR_Pre_Sales_Risk_Opportunity_Type__c == objList[i].Opportunity_Type__c && 
								   opportunity.PSR_Pre_Sales_Risk_Opportunity_Sub_Type__c == objList[i].Opportunity_Sub_Type__c &&
								   opportunity.PSR_Lead_Business_Group__c == objList[i].BG_Value__c && ((opportunity.PSR_Total_Cost_In_Euro__c >= objList[i].Min_Value__c && opportunity.PSR_Total_Cost_In_Euro__c <= objList[i].Max_Value__c)  || (opportunity.PSR_Total_Cost_In_Euro__c >= objList[i].Max_Value__c && objList[i].Min_Value__c == Null))){
									   system.debug('Check Logic:');
									   opportunity.PSR_GateClass__c = objList[i].Gate_Classification__c;
									   opportunity.PSR_LoA_Level__c = objList[i].LOA_Level__c;
									   System.debug('PSR_Total_Cost_In_Euro__c>>>>>>>>>' + opportunity.PSR_Total_Cost_In_Euro__c);
									   System.debug('PSR_Total_Cost_In_Euro__c>>>>>>>>>' + opportunity.PSR_GateClass__c);
									   System.debug('objList[i].LOA_Level__c>>>>>>>>>opportunity.PSR_LoA_Level__c' + objList[i].LOA_Level__c+'>>>'+opportunity.PSR_LoA_Level__c);
									   
								   }
							}
						}
					}
				update Opportunity;
				}
			} 
		
		catch(Exception ex) {
			ExceptionHandler.addException(ex, GlobalConstants.CALCULATELOALEVEL, GlobalConstants.CALCULATELOALEVEL);
		}
	   return opportunity; 
	} 
Public static void psroThresholdMail(List<PSRO_Market_Threshold__c> sendmail_List)
{
try
{
EmailTemplate et=[SELECT Id FROM EmailTemplate WHERE developerName =:Label.NF_ThresholdExceededNotification LIMIT 1];		   
List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
String roles = Label.PSRO_Threshold_send_Mail;
List<String> Rolelist = roles.split(';');
set<String> RoleSet = new set<string>();
 RoleSet.addAll(Rolelist);
List<Sales_Role__c> SRList = [Select Id, BG__c, O__c, User__C from Sales_Role__c where Role_Code__c in :RoleSet];
	system.debug('SRList:'+SRList);
for(PSRO_Market_Threshold__c ThRec : sendmail_List)
{
for(Sales_Role__c SRrec : SRList)
{
If(SRrec.Bg__C == ThRec.Business_group__c)
{
Messaging.SingleEmailMessage Participants = new Messaging.SingleEmailMessage();
Participants.setWhatId(ThRec.Id);
participants.setTargetObjectId(SRrec.user__c);
participants.setTemplateId(et.Id);
participants.setSaveAsActivity(false);
system.debug('participants'+participants);
mailList.add(participants);
}
}

}
	
if(!mailList.isEmpty()){
system.debug('Send mail:'+mailList);
		Messaging.SendEmailResult[] results=Messaging.sendEmail(mailList);   
	}
}
catch(Exception ex) {
ExceptionHandler.addException(ex, GlobalConstants.PSROThresholdMail, GlobalConstants.PSROThresholdMail);
}
}
}