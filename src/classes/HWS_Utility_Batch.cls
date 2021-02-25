/****************************************
* Name : HWS_Utility_Batch
* Author : TCS
* Description : This class is for utility batch
* ReqNo : 
****************************************/
public without sharing class HWS_Utility_Batch {
	/****************************************
		 * Name : getToken
		 * Description : Retreives token from EDP by making a callout
		 * Parameters: 
		 * Returns : HttpResponse which contains token
	 *****************************************/
	public String getToken(){
		HWS_TokenGenerate tokenGenerate = new HWS_TokenGenerate();
		return tokenGenerate.getToken();
	}
	/****************************************
		 * Name : getCountofRecords
		 * Description : gets the count of records retrieved for each callout to an external object
		 * Parameters: URL string
		 * Returns : Count Integer
	 *****************************************/
	public Integer getCountofRecords(String query, String token){
		HWS_CountOfRecords countRecords = new HWS_CountOfRecords();
		return countRecords.getCountofRecords(query, token);
	}
	/****************************************
		 * Name : 
		 * Description : load data to Product Serviceble Version Items
		 * Parameters: HttResponse, URL
		 * Returns: List of Product Serviceble Version Items
	 *****************************************/
	public static List<HWS_Product_Serviceable_Version_Item__c> jsonToServiceableVersionItemStagingTable(HttpResponse response1, String path){
		return HWS_UploadToServicebleVersionItems.jsonToServiceableVersionItemStagingTable(response1, path);
	}
	/****************************************
		 * Name : createInterfaceLogsToServiceableVersionItem
		 * Description : create interface logs for  Product Serviceble Version Items load
		 * Parameters: Response, List of  Product Serviceble Version Items, url
		 * Returns: 
	 *****************************************/
	public static void createInterfaceLogsAndServiceableVersionItem(HttpResponse response1, List<HWS_Product_Serviceable_Version_Item__c> prodSerVersionItmList, String path){
	   HWS_UploadToServicebleVersionItems.createInterfaceLogsAndServiceableVersionItem(response1, prodSerVersionItmList, path);
	}
	/****************************************
		 * Name : uploadToProductServiceableSalesItemStagingTable
		 * Description : load data to Product Serviceble Version Items
		 * Parameters: HttResponse, URL
		 * Returns: List of Product Serviceble Version Items
	 *****************************************/
	public static List<HWS_Product_Serviceable_Sales_Item__c> jsonToProductServiceableSalesItemStagingTable(HttpResponse response1, String path){
		return HWS_UploadToServicebleSalesItems.jsonToProductServiceableSalesItemStagingTable(response1, path);
	}
	/****************************************
		 * Name : createInterfaceLogsToServiceableSalesItem
		 * Description : create interface logs for  Product Serviceble Version Items load
		 * Parameters: Response, List of  Product Serviceble Version Items, url
		 * Returns: 
	 *****************************************/
	public static void createInterfaceLogsAndServiceableSalesItem(HttpResponse response1, List<HWS_Product_Serviceable_Sales_Item__c> prodSerVersionItmList, String path){
		HWS_UploadToServicebleSalesItems.createInterfaceLogsAndServiceableSalesItem(response1, prodSerVersionItmList, path);
	}
	/****************************************
		 * Name : uploadToProductRelationshipTable
		 * Description : load data to Product Relationship records
		 * Parameters: HttResponse, URL
		 * Returns: List of Product Relationship records
	 *****************************************/
	public static List<HWS_Product_Serviceable_Relations__c> jsonToProductRelationshipTable(HttpResponse response1, String path){
		return HWS_UploadToProductRelation.jsonToProductRelationshipTable(response1, path);
	}
	/****************************************
		 * Name : createInterfaceLogsToProductRelationship
		 * Description : create interface logs for  Relationship records load
		 * Parameters: Response, List of  Product Relationship records, url
		 * Returns: 
	 *****************************************/
	public static void createInterfaceLogsAndProductRelationship(HttpResponse response1, List<HWS_Product_Serviceable_Relations__c> prodRelationshipList, String path){
		HWS_UploadToProductRelation.createInterfaceLogsAndProductRelationship(response1, prodRelationshipList, path);
	}
	/****************************************
		 * Name : uploadToProductVersionItemStagingTable
		 * Description : load data to Product Relationship records
		 * Parameters: HttResponse, URL
		 * Returns: List of Product Relationship records
	 *****************************************/
	public static List<HWS_Product_Version_Item__c> jsonToProductVersionItemStagingTable(HttpResponse response1, String path){
		return HWS_UploadToProductVersionItems.jsonToProductVersionItemStagingTable(response1, path);
	}
	/****************************************
		 * Name : createInterfaceLogsToProductVersionItem
		 * Description : create interface logs for  Relationship records load
		 * Parameters: Response, List of  Product Relationship records, url
		 * Returns: 
	 *****************************************/
	public static void createInterfaceLogsAndProductVersionItem(HttpResponse response1, List<HWS_Product_Version_Item__c> prodRelationshipList, String path){
		HWS_UploadToProductVersionItems.createInterfaceLogsAndProductVersionItem(response1, prodRelationshipList, path);
	}
	/****************************************
		 * Name : uploadToProductServicableAltCodesTable
		 * Description : load data to Product Serviceble Version Items
		 * Parameters: HttResponse, URL
		 * Returns: List of Product Serviceble Version Items
	 *****************************************/
	public static List<HWS_AlternateProductCode__c> jsonToProductServicableAltCodesTable(HttpResponse response1, String path){
		return HWS_UploadToProductServicableAltCodes.jsonToProductServicableAltCodesTable(response1, path);
	}
	/****************************************
		 * Name : createInterfaceLogsToProductServiceableAltCode
		 * Description : create interface logs for  Product Serviceble Version Items load
		 * Parameters: Response, List of  Product Serviceble Version Items, url
		 * Returns: 
	 *****************************************/
	public static void createInterfaceLogsAndProductServiceableAltCode(HttpResponse response1, List<HWS_AlternateProductCode__c> prodSerAltCodeList, String path){
		HWS_UploadToProductServicableAltCodes.createInterfaceLogsAndProductServiceableAltCode(response1, prodSerAltCodeList, path);
	}
	/****************************************
		 * Name : unschedule
		 * Description : Unschedule the Schedulable job based on job name
		 * Parameters: jobName
		 * Returns: 
	 *****************************************/
	public void unschedule(string jobName)
	{
		try
		{
			CronTrigger[] cronTrigger = [SELECT Id 
										 FROM CronTrigger 
										 where CronJobDetail.Name = :jobName];
			if(cronTrigger != null && !cronTrigger.isEmpty()){
			   System.abortJob(cronTrigger[0].Id); 
			}
		}catch(Exception e)
		{
			System.debug('Error while aborting job :'+jobName+'Exception: '+e);
		}
	}
	/****************************************
		 * Name : rescheduleMethod
		 * Description : reschedule the Schedulable job based on job name
		 * Parameters: jobName
		 * Returns: 
	 *****************************************/
	public void rescheduleMethod(string jobName, String batchName){
		if(batchName == 'ProductVersionItemBatch'){
			HWS_ProductVersionItem_Batch pvib = new HWS_ProductVersionItem_Batch();
			Datetime dt = Datetime.now().addMinutes(60);  // i.e. 60 mins
			String timeForScheduler = dt.format('s m H * * \'?\' *');
			system.schedule(jobName,timeForScheduler, pvib);
		}
		if(batchName == 'ProductServiceableVersionItemBatch'){
			HWS_ProductServiceableVersionItem_Batch psvib = new HWS_ProductServiceableVersionItem_Batch();
			Datetime dt = Datetime.now().addMinutes(60);  // i.e. 60 mins
			String timeForScheduler = dt.format('s m H * * \'?\' *');
			system.schedule(jobName,timeForScheduler, psvib);
		}
		if(batchName == 'ProductServiceableSalesItemBatch'){
			HWS_ProductServiceableSalesItem_Batch pssib = new HWS_ProductServiceableSalesItem_Batch();
			Datetime dt = Datetime.now().addMinutes(60);  // i.e. 60 mins
			String timeForScheduler = dt.format('s m H * * \'?\' *');
			system.schedule(jobName,timeForScheduler, pssib);
		}
		if(batchName == 'ProductRelationBatch'){
			HWS_Product_Relationship_Batch prb = new HWS_Product_Relationship_Batch();
			Datetime dt = Datetime.now().addMinutes(60);  // i.e. 60 mins
			String timeForScheduler = dt.format('s m H * * \'?\' *');
			system.schedule(jobName,timeForScheduler, prb);
		}
		if(batchName == 'ProductServiceableAltCodeBatch'){
			HWS_ProductServiceableAltCode_Batch psacb = new HWS_ProductServiceableAltCode_Batch();
			Datetime dt = Datetime.now().addMinutes(60);  // i.e. 60 mins
			String timeForScheduler = dt.format('s m H * * \'?\' *');
			system.schedule(jobName,timeForScheduler, psacb);
		}
		//Add 25 hrs to custom setting modified date time			
		List<EDP_HWS_Settings__c> edpEntryList = [Select Id,Name,ModifiedDate__c from EDP_HWS_Settings__c];
		system.debug('It is: '+edpEntryList);
		if(edpEntryList != null)
		{
			for(EDP_HWS_Settings__c edpEntry : edpEntryList)
			{
				edpEntry.ModifiedDate__c = Datetime.now().addHours(-25);
			}
		}
		Database.update(edpEntryList,false);
	}
	 public void clearcustomsetting(String instanceName)
	{
		EDP_HWS_Settings__c  pcEntry = EDP_HWS_Settings__c.getInstance(instanceName); 
		pcEntry.ModifiedDate__c = null;
		pcEntry.Full_Load_Filter__c= '';  
		pcEntry.Full_Load__c = false;
		update pcEntry;
		if(instanceName=='ProductServiceableAltCode')
			 setDoNotConsiderFlag();
	}
	
	//This is to set the duplicate product codes 
	public void setDoNotConsiderFlag()
	{
	   Set<String> prodSet = new Set<String>();
	   List<AggregateResult> repcols =   [ SELECT productcode FROM Product2 where  HWS_DoNotConsider__c=false group by productcode having count(id)>1 and productcode!=null ];
		System.debug('testtt:'+repcols);
	   for (AggregateResult ar : repcols ) {
			prodSet.add((String)ar.get('productcode'));
		} 
		
	  if(prodSet.size() > 0){
		 List<Product2> duplicatecodeList = new List<Product2>();
		 Map<String ,String> productMap = new Map<String,String>();
		 List<Product2>  listprod = [SELECT NokiaCPQ_Item_Type__c,productcode ,HWS_DoNotConsider__c FROM Product2 where productcode in :prodSet];
		 for(Product2 product : listprod){
			if(product.NokiaCPQ_Item_Type__c !='Hardware'  || productMap.containsKey(product.productcode.toUpperCase())){  
						 product.HWS_DoNotConsider__c=true;
						 duplicatecodeList.add(product);
			}
			else
			   productMap.put(product.ProductCode.toUpperCase() ,product.Id);
			}
			if(duplicatecodeList.size() > 0){
			  update duplicatecodeList;
		   }
		}
	}
}