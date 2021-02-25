/*******************************
Class Name: ProductTriggerHandler
Created By: Accenture - October 2019
Last Modified By: Accenture
Last Modified Date: 10-10-2019
Description: Handler Class for Product Trigger 
*******************************/

public class ProductTriggerHandler {
	
	/*****************************
*Method Name: updateproductdata
*Description: This method is used to update product fields when product hierarchy is changed
*Parameters: Product List,Old Product Map,New Product Map  
*Created By: Accenture - October 2019
*Last Modified By: Accenture
*Last Modified Date: 10-10-2019
*******************************/
	
	public static void updateproductdata(map<Id,Product2> oldprodmap, map<Id,Product2> newprodmap){
		List<Product2> ProductList = new List<Product2>();
		Map<Id,Product_Hierarchy__c> hiermap = new Map<Id,Product_Hierarchy__c>();
		
		Set<Id> Producthierset=new Set<Id>();
		try{
			
			for(Product2 prod:newprodmap.values())
			{
				if(newprodmap.get(prod.Id).Product_Hierarchy__c <> oldprodmap.get(prod.Id).Product_Hierarchy__c)
				{
					Producthierset.add(prod.Product_Hierarchy__c);
					
				}
			}
			
			if(!Producthierset.isempty()){
				for(Product_Hierarchy__c Prodhierrec: [select Id, Business_Group_Code__c, Business_Unit_Code__c,Portfolio_Package_Code__c,Business_Line_Code__c from Product_Hierarchy__c where Id in :(Producthierset)])
				{
					hiermap.put(Prodhierrec.Id,Prodhierrec);
				}
			}
			
			for(Product2 pro:newprodmap.values())
			{
				if(hiermap.containskey(pro.Product_Hierarchy__c))
				{
					pro.Business_Group__c=hiermap.get(pro.Product_Hierarchy__c).Business_Group_Code__c;
					pro.Family=hiermap.get(pro.Product_Hierarchy__c).Business_Unit_Code__c;
					pro.NokiaCPQ_Portfolio_Package_Code__c=hiermap.get(pro.Product_Hierarchy__c).Portfolio_Package_Code__c;
					pro.Business_Line_Code__c=hiermap.get(pro.Product_Hierarchy__c).Business_Line_Code__c;
				}
			}
			
			/*if(!ProductList.isEmpty())
{
List<database.SaveResult> Updateresult = database.update(ProductList,false);
system.debug('Updateresult: '+Updateresult); 
}*/
			
		}
		
		catch(exception ex)
		{
			system.debug('exception'+ex.getMessage());
			ExceptionHandler.addException(ex,GlobalConstants.ProductTriggerHandler, GlobalConstants.PTH_updateproductdata);
		}   
	}
}