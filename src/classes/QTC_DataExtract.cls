public without sharing class QTC_DataExtract {
	
	public static List<Product_Extension__c> getrelatedproductextensions (set<Id> Productset, String Currencycode){
		List<Product_Extension__c> Prodext_List = [select Id,Product__c,Market_Price__c,Floor_Price__c,Custom_Bid__c from Product_Extension__c where Product__c in :Productset and CurrencyIsoCode = :Currencycode];
		
		return Prodext_List;
	}
}