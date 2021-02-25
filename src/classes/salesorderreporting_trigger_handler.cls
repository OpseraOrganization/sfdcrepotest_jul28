public class salesorderreporting_trigger_handler {

	public static void BeforeInsert(List<Sales_Order_Reporting__c> SOinslist){
		
		 if(!userinfo.getProfileId().equalsignorecase(system.label.Data_Loader_Profile_Id)){
			salesorderreporting_trigger_helper.Currencychange(SOinslist);
			salesorderreporting_trigger_helper.UpdateCQNumber(SOinslist);
			
		}
	}
	
	public static void BeforeUpdate(List<Sales_Order_Reporting__c> SOupdlist , Map<Id,Sales_Order_reporting__c> oldSOMap, Map<Id,Sales_Order_reporting__c> newSOMap){
		system.debug('entered before update in handler');
		 if(!userinfo.getProfileId().equalsignorecase(system.label.Data_Loader_Profile_Id)){
		salesorderreporting_trigger_helper.Updatecurrencychange(SOupdlist, oldSOMap);
		salesorderreporting_trigger_helper.CheckCQChange(oldSOMap,newSOMap);
		}
	}
	
	public static void AfterInsert(List<Sales_Order_Reporting__c> salesorderlist){
		 if(!userinfo.getProfileId().equalsignorecase(system.label.Data_Loader_Profile_Id)){
		salesorderreporting_trigger_helper.updatecqdata(salesorderlist);
			 salesorderreporting_trigger_helper.emailalert(salesorderlist);
		 }		
		}
	
	 public static void AfterUpdate(List<Sales_Order_Reporting__c> salesorderlist){
		if(!userinfo.getProfileId().equalsignorecase(system.label.Data_Loader_Profile_Id)){
		salesorderreporting_trigger_helper.updatecqdata(salesorderlist);
		}
		
		}
	
	public static void AfterDelete(List<Sales_Order_Reporting__c> salesorderlist){
		
		 if(!userinfo.getProfileId().equalsignorecase(system.label.Data_Loader_Profile_Id)){
		salesorderreporting_trigger_helper.updatecqdata(salesorderlist);
		 }		
		}
}