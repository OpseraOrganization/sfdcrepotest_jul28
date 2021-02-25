/****************************************
* Name : HWS_Utility_Batch_Test
* Author : TCS
* Description : This class is for util batch for HWS
* ReqNo : 
****************************************/
@isTest
public class HWS_Utility_Batch_Test {
	@testSetup
	static void createTestData()
	{
		List<EDP_HWS_Settings__c> edpEntryList = new List<EDP_HWS_Settings__c>();
		
		//Create custom settings entries for test data
		EDP_HWS_Settings__c edpEntry = new EDP_HWS_Settings__c();
		edpEntry.Name = 'ProductRelation';
		edpEntry.Full_Load__c = true;
		edpEntry.Full_Load_Filter__c ='Yes';
		edpEntry.ModifiedDate__c = Date.today();
		edpEntryList.add(edpEntry);
		
		EDP_HWS_Settings__c edpEntry1 = new EDP_HWS_Settings__c();
		edpEntry1.Name = 'ProductServiceableSalesItem';
		edpEntry1.Full_Load_Filter__c ='Yes';
		edpEntry1.Full_Load__c = true;
		edpEntry1.ModifiedDate__c = Date.today();
		edpEntryList.add(edpEntry1);
		
		EDP_HWS_Settings__c edpEntry2 = new EDP_HWS_Settings__c();
		edpEntry2.Name = 'ProductServiceableVersionItem';
		edpEntry2.Full_Load_Filter__c ='Yes';
		edpEntry2.Full_Load__c = true;
		edpEntry2.ModifiedDate__c = Date.today();
		edpEntryList.add(edpEntry2);
		
		//start changes
		EDP_HWS_Settings__c edpEntry3 = new EDP_HWS_Settings__c();
		edpEntry3.Name = 'ProductServiceableAltCode';
		edpEntry3.Full_Load_Filter__c ='Yes';
		edpEntry3.ModifiedDate__c = Date.today();
		edpEntryList.add(edpEntry3);
		
		EDP_HWS_Settings__c edpEntry4 = new EDP_HWS_Settings__c();
		edpEntry4.Name = 'ProductVersionItem';
		edpEntry4.Full_Load_Filter__c ='Yes';
		edpEntry4.ModifiedDate__c = Date.today();
		edpEntryList.add(edpEntry4);
		
		
		// end changes
		insert edpEntryList;
		
		List<EDP_URLs__c> edpURLList = new List<EDP_URLs__c>();
		EDP_URLs__c edpURL1 = new EDP_URLs__c();
		edpURL1.name = 'Product_Relation';
		edpURL1.URL__c = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations';
		edpURLList.add(edpURL1);
		
		EDP_URLs__c edpURL2 = new EDP_URLs__c();
		edpURL2.name = 'PSSI';
		edpURL2.URL__c = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems';
		edpURLList.add(edpURL2);
		
		EDP_URLs__c edpURL3 = new EDP_URLs__c();
		edpURL3.name = 'PSVI';
		edpURL3.URL__c = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems';
		edpURLList.add(edpURL3);
		
		EDP_URLs__c edpURL4 = new EDP_URLs__c();
		edpURL4.name = 'resource';
		edpURL4.URL__c = 'https://edpqaapi.azurewebsites.net';
		edpURLList.add(edpURL4);
		// start changes
		EDP_URLs__c edpURL5 = new EDP_URLs__c();
		edpURL5.name = 'PSAC';
		edpURL5.URL__c = 'https://edpqaapi.azurewebsites.net/api/Productserviceablealernatecodes';
		edpURLList.add(edpURL5);
		
		EDP_URLs__c edpURL6 = new EDP_URLs__c();
		edpURL6.name = 'PVI';
		edpURL6.URL__c = 'https://edpqaapi.azurewebsites.net/api/ProductVersionItems';
		edpURLList.add(edpURL6);
		//End Changes		
		insert edpURLList;
		
		Product_Relation__c productRel = new Product_Relation__c();
		productRel.Child_ID__c			  = '00000001';
		productRel.Child_Name__c			= '00000001';
		productRel.Parent_ID__c			 = '133-060762_00';
		productRel.EDPActiveStatus__c	   = true;
		productRel.RelationType__c			  ='test';
		productRel.Combined_key__c		  = '00000001_133-060762_00';
		insert productRel;
		
		//start changes
		//creating data for Skip Count
		List<HWS_Skipcount__c> skipEntryList = new List<HWS_Skipcount__c>();
		HWS_Skipcount__c skipEntry1 = new HWS_Skipcount__c();
		skipEntry1.name = 'PSAC';
		skipEntry1.Skip_Count__c = null;
		skipEntryList.add(skipEntry1);
		
		HWS_Skipcount__c skipEntry2 = new HWS_Skipcount__c();
		skipEntry2.name = 'PVI';
		skipEntry2.Skip_Count__c = null;
		skipEntryList.add(skipEntry2);
		
		HWS_Skipcount__c skipEntry3 = new HWS_Skipcount__c();
		skipEntry3.name = 'PSR';
		skipEntry3.Skip_Count__c = null;
		skipEntryList.add(skipEntry3);
		
		HWS_Skipcount__c skipEntry4 = new HWS_Skipcount__c();
		skipEntry4.name = 'PSVI';
		skipEntry4.Skip_Count__c = null;
		skipEntryList.add(skipEntry4);
		
		HWS_Skipcount__c skipEntry5 = new HWS_Skipcount__c();
		skipEntry5.name = 'PSSI';
		skipEntry5.Skip_Count__c = null;
		skipEntryList.add(skipEntry5); 
		
		
		insert skipEntryList;
		//end changes
		
		List<HWS_Product_Serviceable_Relations__c> prodServiceRelationList = new List<HWS_Product_Serviceable_Relations__c>();
		HWS_Product_Serviceable_Relations__c prodServiceRelation = new HWS_Product_Serviceable_Relations__c();
		prodServiceRelation.HWS_HWSSIPartNumber__c = '833-049122_00';
		prodServiceRelation.HWS_Product_Code__c = '833-049122_00';
		prodServiceRelation.HWS_Is_Processed__c = false;
		prodServiceRelationList.add(prodServiceRelation);
		insert prodServiceRelationList;
		
		Product2 prod = new Product2();
		prod.Name ='Test Product 1';
		prod.ProductCode = '833-049122_00';
		prod.NokiaCPQ_Item_Type__c = 'Hardware';
		insert prod;
		System.assertNotEquals(prod.Name, null);
		
		Product2 prod1 = new Product2();
		prod1.Name ='Test Product 2';
		prod1.ProductCode = '833-049122_00';
		prod1.NokiaCPQ_Item_Type__c = 'OTHER';
		insert prod1;
		
		CH_ProductRelation__c chProdRelation = new CH_ProductRelation__c();
		chProdRelation.CH_Child_Product__c = prod.Id;
		chProdRelation.CH_Parent_Product__c = prod1.Id;
		chProdRelation.CH_ExternalId__c = '085849A833-049122_00';
		insert chProdRelation;

	}
	
	
	@isTest 
	static void testproductServicableVersion() 
	{
		//Setting callout mock for loading data from static resource		
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String ciPath = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems';
		String tokenPath = 'https://login.microsoftonline.com/5d471751-9675-428d-917b-70f44f9630b0/oauth2/token';
		String calloutPath = 'callout:EDP_Login';
		
		multimock.setStaticResource(ciPath, 'ProductServiceableVersionItems');
		multimock.setStaticResource(tokenPath,'ProductToken');
		multimock.setStaticResource(calloutPath,'ProductToken');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems?&$count=true&$top=1','ProductServiceableVersionItemsCount');
		//multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems?&$skip=2000&$top=2000','ProductServiceableVersionItemsCount');
		//multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems?&$skip=4000&$top=2000','ProductServiceableVersionItemsCount');
		//multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems?&$skip=6000&$top=2000','ProductServiceableVersionItemsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems?&$skip=1000&$top=1000','ProductServiceableVersionItemsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems?&$skip=2000&$top=1000','ProductServiceableVersionItemsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems?&$skip=3000&$top=1000','ProductServiceableVersionItemsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems?&$skip=4000&$top=1000','ProductServiceableVersionItemsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems?&$skip=5000&$top=1000','ProductServiceableVersionItemsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems?&$skip=6000&$top=1000','ProductServiceableVersionItemsCount');
		
		String url1 = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems';
		
		multimock.setStaticResource(url1,'ProductServiceableVersionItems'); 
		
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/json');
		
		Test.startTest();
		
		//Prepare url list for the start method
		List<String> queryList = new List<String>();
		queryList.add('https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems'); 
		
		//set mock callout mode
		Test.setMock(HttpCalloutMock.class, multimock);
		
		HWS_ProductServiceableVersionItem_Batch batch = new HWS_ProductServiceableVersionItem_Batch();
		Database.BatchableContext bc;
		SchedulableContext sc;
		batch.start(bc);
		batch.execute(sc);
		batch.execute(bc,queryList);		 
		batch.finish(bc);			
		Test.StopTest();
		
	}
	@isTest 
	static void testproductServicableVersion5000() 
	{
		List<EDP_HWS_Settings__c> edpEntryList = new List<EDP_HWS_Settings__c>();
		//Create custom settings entries for test data
		EDP_HWS_Settings__c edpEntry = new EDP_HWS_Settings__c();
		edpEntry.Name = 'ProductServiceableVersionItem';
		//edpEntry.Full_Load__c = true;
		edpEntry.Full_Load_Filter__c ='Yes';
		edpEntry.ModifiedDate__c = Date.newInstance(2019,03,26);
		edpEntryList.add(edpEntry);
		insert edpEntryList;
		HWS_Skipcount__c skipCountValue = HWS_Skipcount__c.getInstance('PSVI');
		skipCountValue.Skip_Count__c = 5100;
		update skipCountValue;
		//Setting callout mock for loading data from static resource		
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String ciPath = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems';
		String tokenPath = 'https://login.microsoftonline.com/5d471751-9675-428d-917b-70f44f9630b0/oauth2/token';
		String calloutPath = 'callout:EDP_Login';
		
		multimock.setStaticResource(ciPath, 'ProductServiceableVersionItems');
		multimock.setStaticResource(tokenPath,'ProductToken');
		multimock.setStaticResource(calloutPath,'ProductToken');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$count=true&$top=1','ProductServiceableVersionItemsCount');
		
		String url1 = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems';
		
		multimock.setStaticResource(url1,'ProductServiceableVersionItems'); 
		
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/json');
		
		Test.startTest();
		
		//Prepare url list for the start method
		List<String> queryList = new List<String>();
		queryList.add('https://edpqaapi.azurewebsites.net/api/ProductServiceableVersionItems'); 
		
		//set mock callout mode
		Test.setMock(HttpCalloutMock.class, multimock);
		
		HWS_ProductServiceableVersionItem_Batch batch = new HWS_ProductServiceableVersionItem_Batch();
		Database.BatchableContext bc;
		SchedulableContext sc;
		batch.start(bc);
		batch.execute(sc);
		batch.execute(bc,queryList);		 
		batch.finish(bc);	  
		Test.StopTest();
	}
	
	@isTest 
	static void testproductServicableSales() 
	{
		//Setting callout mock for loading data from static resource		
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String ciPath = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems';
		String tokenPath = 'https://login.microsoftonline.com/5d471751-9675-428d-917b-70f44f9630b0/oauth2/token';
		String calloutPath = 'callout:EDP_Login';
		String url1 = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems';
		multimock.setStaticResource(ciPath, 'ProductServiceableSalesItems');
		multimock.setStaticResource(tokenPath,'ProductToken');
		multimock.setStaticResource(calloutPath,'ProductToken');
		//multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems?$filter=EDP_LastModifiedDate%20gt%202019-03-19T05:30:00Z&$count=true&$top=1','ProductServiceableSalesItemsCount');
		//multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems?&$count=true&$top=1','ProductServiceableSalesItemsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems?&$count=true&$top=1', 'ProductServiceableSalesItemsCount');
		// multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems?&$skip=3000&$top=3000', 'ProductServiceableSalesItemsCount');
		//  multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems?&$skip=6000&$top=3000', 'ProductServiceableSalesItemsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems?&$skip=1000&$top=1000', 'ProductServiceableSalesItemsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems?&$skip=2000&$top=1000', 'ProductServiceableSalesItemsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems?&$skip=3000&$top=1000', 'ProductServiceableSalesItemsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems?&$skip=4000&$top=1000', 'ProductServiceableSalesItemsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems?&$skip=5000&$top=1000', 'ProductServiceableSalesItemsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems?&$skip=6000&$top=1000', 'ProductServiceableSalesItemsCount');
		multimock.setStaticResource(url1,'ProductServiceableSalesItems'); 
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/json');
		Test.startTest();
		//Prepare url list for the start method
		List<String> queryList = new List<String>();
		queryList.add('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems'); 
		//set mock callout mode
		Test.setMock(HttpCalloutMock.class, multimock);
		//HWS_ProductServiceableSalesItem_bat_Pav batch = new HWS_ProductServiceableSalesItem_bat_Pav();
		HWS_ProductServiceableSalesItem_Batch batch=new HWS_ProductServiceableSalesItem_Batch();
		
		Database.BatchableContext bc;
		SchedulableContext sc;
		
		batch.start(bc);
		batch.execute(bc,queryList);  
		batch.finish(bc);
		// batch.execute(sc);
		Test.StopTest();
		
	}   
	@isTest 
	static void testproductServicableSales5001() 
	{
		List<EDP_HWS_Settings__c> edpEntryList = new List<EDP_HWS_Settings__c>();
		//Create custom settings entries for test data
		EDP_HWS_Settings__c edpEntry = new EDP_HWS_Settings__c();
		edpEntry.Name = 'ProductServiceableSalesItem';
		edpEntry.Full_Load_Filter__c ='Yes';
		edpEntry.ModifiedDate__c = Date.newInstance(2019,03,26);
		edpEntryList.add(edpEntry);
		insert edpEntryList;
		//EDP_HWS_Settings__c edpEntry =EDP_HWS_Settings__c.getInstance('ProductServiceableSalesItem');
		// edpEntry.Full_Load_Filter__c ='Yes';
		// edpEntry.ModifiedDate__c = Date.newInstance(2019,03,26);
		//edpEntryList.add(edpEntry);
		// update edpEntry;
		HWS_Skipcount__c skipCountValue = HWS_Skipcount__c.getInstance('PSSI');
		skipCountValue.Skip_Count__c = 5100;
		update skipCountValue;
		//Setting callout mock for loading data from static resource		
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String ciPath = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems';
		String tokenPath = 'https://login.microsoftonline.com/5d471751-9675-428d-917b-70f44f9630b0/oauth2/token';
		String calloutPath = 'callout:EDP_Login';
		multimock.setStaticResource(ciPath, 'ProductServiceableSalesItems');
		multimock.setStaticResource(tokenPath,'ProductToken');
		multimock.setStaticResource(calloutPath,'ProductToken');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$count=true&$top=1','ProductServiceableSalesItemsCount');
		String url1 = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems';
		multimock.setStaticResource(url1,'ProductServiceableSalesItems'); 
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/json');
		Test.startTest();
		//Prepare url list for the start method
		List<String> queryList = new List<String>();
		queryList.add('https://edpqaapi.azurewebsites.net/api/ProductServiceableSalesItems'); 
		//set mock callout mode
		Test.setMock(HttpCalloutMock.class, multimock);
		HWS_ProductServiceableSalesItem_Batch batch = new HWS_ProductServiceableSalesItem_Batch();
		//HWS_ProductServiceableSalesItem_bat_Pav batch = new HWS_ProductServiceableSalesItem_bat_Pav();
		Database.BatchableContext bc;
		SchedulableContext sc;
		batch.start(bc);
		//  batch.execute(sc);
		batch.execute(bc,queryList);		 
		Test.StopTest();
		
	}   
	
	@isTest 
	static void testproductServicableAlternateVersion() 
	{
		List<EDP_HWS_Settings__c> edpEntryList1 = new List<EDP_HWS_Settings__c>();
		EDP_HWS_Settings__c edpEntry = new EDP_HWS_Settings__c();
		edpEntry.Name = 'ProductServiceableAltCode';
		edpEntry.Full_Load_Filter__c ='Yes';
		edpEntry.ModifiedDate__c = Date.newInstance(2019,03,26);
		edpEntryList1.add(edpEntry);
		insert edpEntryList1;
		
		//Setting callout mock for loading data from static resource		
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String ciPath = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode';
		String tokenPath = 'https://login.microsoftonline.com/5d471751-9675-428d-917b-70f44f9630b0/oauth2/token';
		String calloutPath = 'callout:EDP_Login';
		
		multimock.setStaticResource(ciPath, 'ProductServiceableAltCode');
		multimock.setStaticResource(tokenPath,'ProductToken');
		multimock.setStaticResource(calloutPath,'ProductToken');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/Productserviceablealernatecodes?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$count=true&$top=1','ProductServiceableAltCodeCount');
		//multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/Productserviceablealernatecodes?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=3000&$top=3000','ProductServiceableAltCodeCount');
		//multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/Productserviceablealernatecodes?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=6000&$top=3000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$count=true&$top=1','ProductServiceableAltCodeCount');
		// multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=3000&$top=3000','ProductServiceableAltCodeCount');
		// multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=6000&$top=3000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/Productserviceablealernatecodes?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=1000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/Productserviceablealernatecodes?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=2000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/Productserviceablealernatecodes?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=3000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/Productserviceablealernatecodes?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=4000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/Productserviceablealernatecodes?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=5000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/Productserviceablealernatecodes?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=6000&$top=1000','ProductServiceableAltCodeCount');
		
		
		String url1 = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode';
		
		multimock.setStaticResource(url1,'ProductServiceableAltCode'); 
		
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/json');
		
		Test.startTest();
		
		//Prepare url list for the start method
		List<String> queryList = new List<String>();
		queryList.add('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode'); 
		
		//set mock callout mode
		Test.setMock(HttpCalloutMock.class, multimock);
		
		HWS_ProductServiceableAltCode_Batch batch = new HWS_ProductServiceableAltCode_Batch();
		Database.BatchableContext bc;
		SchedulableContext sc;
		batch.start(bc);
		//batch.execute(sc);
		batch.execute(bc,queryList);		 
		batch.finish(bc);
		Test.StopTest();
		
		
	}
	
	@isTest 
	static void testproductServicableAltcode5000() 
	{
		
		List<EDP_HWS_Settings__c> edpEntryList1 = new List<EDP_HWS_Settings__c>();
		//Create custom settings entries for test data
		EDP_HWS_Settings__c edpEntry = new EDP_HWS_Settings__c();
		edpEntry.Name = 'ProductServiceableAltCode';
		edpEntry.Full_Load_Filter__c ='Yes';
		edpEntry.ModifiedDate__c = Date.newInstance(2019,03,26);
		edpEntryList1.add(edpEntry);
		insert edpEntryList1;
		
		HWS_Skipcount__c skipCountValue = HWS_Skipcount__c.getInstance('PSAC');
		skipCountValue.Skip_Count__c = 5100;
		update skipCountValue;
		//Setting callout mock for loading data from static resource		
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String ciPath = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode';
		String tokenPath = 'https://login.microsoftonline.com/5d471751-9675-428d-917b-70f44f9630b0/oauth2/token';
		String calloutPath = 'callout:EDP_Login';
		
		multimock.setStaticResource(ciPath, 'ProductServiceableAltCode');
		multimock.setStaticResource(tokenPath,'ProductToken');
		multimock.setStaticResource(calloutPath,'ProductToken');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/Productserviceablealernatecodes?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$count=true&$top=1','ProductServiceableAltCodeCount');
		
		String url1 = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode';
		
		multimock.setStaticResource(url1,'ProductServiceableAltCode'); 
		
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/json');
		
		Test.startTest();
		
		//Prepare url list for the start method
		List<String> queryList = new List<String>();
		queryList.add('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode'); 
		
		//set mock callout mode
		Test.setMock(HttpCalloutMock.class, multimock);
		
		HWS_ProductServiceableAltCode_Batch batch = new HWS_ProductServiceableAltCode_Batch();
		Database.BatchableContext bc;
		SchedulableContext sc;
		batch.start(bc);
		// batch.execute(sc);
		batch.execute(bc,queryList);		 
		batch.finish(bc);	  
		Test.StopTest();
		
	}   
	
	
	@isTest
	static void testrescheduleMethod(){
		HWS_Utility_Batch hwsbatch=new HWS_Utility_Batch();
		hwsbatch.rescheduleMethod('test','ProductVersionItemBatch');
		HWS_Utility_Batch hwsbatch1=new HWS_Utility_Batch();
		hwsbatch1.rescheduleMethod('test1','ProductServiceableVersionItemBatch');
		HWS_Utility_Batch hwsbatch2=new HWS_Utility_Batch();
		hwsbatch2.rescheduleMethod('test2','ProductServiceableSalesItemBatch');
		HWS_Utility_Batch hwsbatch3=new HWS_Utility_Batch();
		hwsbatch3.rescheduleMethod('test3','ProductRelationBatch');
		HWS_Utility_Batch hwsbatch4=new HWS_Utility_Batch();
		hwsbatch4.rescheduleMethod('test4','ProductServiceableAltCodeBatch');
	}
	
	@isTest 
	static void testcustsetting(){
		//List<EDP_HWS_Settings__c> edpEntryList = [Select Id,Name,ModifiedDate__c from EDP_HWS_Settings__c];
		// system.assertEquals(edpEntryList.Name, 'ProductRelation');
		HWS_Utility_Batch bat=new HWS_Utility_Batch();
		bat.clearcustomsetting('ProductRelation');
		
	}
	
	
	
	@isTest 
	static void testproductServicableRelation() 
	{
		//Setting callout mock for loading data from static resource		
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String ciPath = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations';
		String tokenPath = 'https://login.microsoftonline.com/5d471751-9675-428d-917b-70f44f9630b0/oauth2/token';
		String calloutPath = 'callout:EDP_Login';
		
		multimock.setStaticResource(ciPath, 'ProductServiceableRelations');
		multimock.setStaticResource(tokenPath,'ProductToken');
		multimock.setStaticResource(calloutPath,'ProductToken');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations?&$count=true&$top=1','ProductServiceableRelationsCount');
		// multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations?&$skip=3000&$top=3000','ProductServiceableRelationsCount');
		//  multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations?&$skip=6000&$top=3000','ProductServiceableRelationsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations?&$skip=1000&$top=1000','ProductServiceableRelationsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations?&$skip=2000&$top=1000','ProductServiceableRelationsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations?&$skip=3000&$top=1000','ProductServiceableRelationsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations?&$skip=4000&$top=1000','ProductServiceableRelationsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations?&$skip=5000&$top=1000','ProductServiceableRelationsCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations?&$skip=6000&$top=1000','ProductServiceableRelationsCount');
		
		String url1 = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations';
		
		multimock.setStaticResource(url1,'ProductServiceableRelations'); 
		
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/json');
		
		Test.startTest();
		
		//Prepare url list for the start method
		List<String> queryList = new List<String>();
		queryList.add('https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations'); 
		
		//set mock callout mode
		Test.setMock(HttpCalloutMock.class, multimock);
		
		HWS_Product_Relationship_Batch batch = new HWS_Product_Relationship_Batch();
		Database.BatchableContext bc;
		SchedulableContext sc;
		batch.start(bc);
		batch.execute(sc);
		batch.execute(bc,queryList);		 
		batch.finish(bc);
		Test.StopTest();
		
		
	}   
	
	
	
	@isTest 
	static void testproductServicableRelationship5000() 
	{
		List<EDP_HWS_Settings__c> edpEntryList = new List<EDP_HWS_Settings__c>();
		//Create custom settings entries for test data
		EDP_HWS_Settings__c edpEntry = new EDP_HWS_Settings__c();
		edpEntry.Name = 'ProductRelation';
		//edpEntry.Full_Load__c = true;
		edpEntry.Full_Load_Filter__c ='Yes';
		edpEntry.ModifiedDate__c = Date.newInstance(2019,03,26);
		edpEntryList.add(edpEntry);
		insert edpEntryList;
		HWS_Skipcount__c skipCountValue = HWS_Skipcount__c.getInstance('PSR');
		skipCountValue.Skip_Count__c = 5100;
		update skipCountValue;
		//Setting callout mock for loading data from static resource		
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String ciPath = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations';
		String tokenPath = 'https://login.microsoftonline.com/5d471751-9675-428d-917b-70f44f9630b0/oauth2/token';
		String calloutPath = 'callout:EDP_Login';
		
		multimock.setStaticResource(ciPath, 'ProductServiceableRelations');
		multimock.setStaticResource(tokenPath,'ProductToken');
		multimock.setStaticResource(calloutPath,'ProductToken');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$count=true&$top=1','ProductServiceableRelationsCount');
		
		String url1 = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations';
		
		multimock.setStaticResource(url1,'ProductServiceableRelations'); 
		
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/json');
		
		Test.startTest();
		
		//Prepare url list for the start method
		List<String> queryList = new List<String>();
		queryList.add('https://edpqaapi.azurewebsites.net/api/ProductServiceableRelations'); 
		
		//set mock callout mode
		Test.setMock(HttpCalloutMock.class, multimock);
		
		HWS_Product_Relationship_Batch batch = new HWS_Product_Relationship_Batch();
		Database.BatchableContext bc;
		SchedulableContext sc;
		batch.start(bc);
		batch.execute(sc);
		batch.execute(bc,queryList);		 
		batch.finish(bc);	  
		Test.StopTest();
		
	}
	
	
	@isTest 
	static void testproductVersionItem() 
	{
		List<EDP_HWS_Settings__c> edpEntryList = new List<EDP_HWS_Settings__c>();
		//Create custom settings entries for test data
		EDP_HWS_Settings__c edpEntry = new EDP_HWS_Settings__c();
		edpEntry.Name = 'ProductVersionItem';
		//edpEntry.Full_Load__c = true;
		edpEntry.Full_Load_Filter__c ='Yes';
		edpEntry.ModifiedDate__c = Date.newInstance(2019,03,26);
		edpEntryList.add(edpEntry);
		insert edpEntryList;
		//Setting callout mock for loading data from static resource		
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String ciPath = 'https://edpqaapi.azurewebsites.net/api/ProductVersionItems';
		String tokenPath = 'https://login.microsoftonline.com/5d471751-9675-428d-917b-70f44f9630b0/oauth2/token';
		String calloutPath = 'callout:EDP_Login';
		
		multimock.setStaticResource(ciPath, 'ProductVersionItem');
		multimock.setStaticResource(tokenPath,'ProductToken');
		multimock.setStaticResource(calloutPath,'ProductToken');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$count=true&$top=1','ProductVersionItemCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=1000&$top=1000','ProductVersionItemCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=2000&$top=1000','ProductVersionItemCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=3000&$top=1000','ProductVersionItemCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=4000&$top=1000','ProductVersionItemCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=5000&$top=1000','ProductVersionItemCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=6000&$top=1000','ProductVersionItemCount');
		//  multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?&$count=true&$top=1','ProductVersionItemCount');
		// multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?&$skip=1000&$top=1000','ProductVersionItemCount');
		//  multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?&$skip=2000&$top=1000','ProductVersionItemCount');
		//  multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?&$skip=3000&$top=1000','ProductVersionItemCount');
		//  multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?&$skip=4000&$top=1000','ProductVersionItemCount');
		//  multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?&$skip=5000&$top=1000','ProductVersionItemCount');
		//  multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?&$skip=6000&$top=1000','ProductVersionItemCount');
		String url1 = 'https://edpqaapi.azurewebsites.net/api/ProductVersionItems';
		
		multimock.setStaticResource(url1,'ProductVersionItem'); 
		
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/json');
		
		Test.startTest();
		
		//Prepare url list for the start method
		List<String> queryList = new List<String>();
		queryList.add('https://edpqaapi.azurewebsites.net/api/ProductVersionItems'); 
		
		//set mock callout mode
		Test.setMock(HttpCalloutMock.class, multimock);
		
		HWS_ProductVersionItem_Batch batch = new HWS_ProductVersionItem_Batch();
		Database.BatchableContext bc;
		SchedulableContext sc;
		batch.start(bc);
		batch.execute(sc);
		batch.execute(bc,queryList);		 
		batch.finish(bc);
		Test.StopTest();
		
	}
	
	@isTest 
	static void testproductVersionItemstatus() 
	{
		List<EDP_HWS_Settings__c> edpEntryList = new List<EDP_HWS_Settings__c>();
		//Create custom settings entries for test data
		EDP_HWS_Settings__c edpEntry = new EDP_HWS_Settings__c();
		edpEntry.Name = 'ProductVersionItem';
		//edpEntry.Full_Load__c = true;
		edpEntry.Full_Load_Filter__c ='Yes';
		edpEntry.ModifiedDate__c = Date.newInstance(2019,03,26);
		edpEntryList.add(edpEntry);
		insert edpEntryList;
		HWS_Skipcount__c skipCountValue = HWS_Skipcount__c.getInstance('PVI');
		skipCountValue.Skip_Count__c = 5100;
		update skipCountValue;
		//Setting callout mock for loading data from static resource		
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String ciPath = 'https://edpqaapi.azurewebsites.net/api/ProductVersionItems';
		String tokenPath = 'https://login.microsoftonline.com/5d471751-9675-428d-917b-70f44f9630b0/oauth2/token';
		String calloutPath = 'callout:EDP_Login';
		
		multimock.setStaticResource(ciPath, 'ProductVersionItem');
		multimock.setStaticResource(tokenPath,'ProductToken');
		multimock.setStaticResource(calloutPath,'ProductToken');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductVersionItems?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$count=true&$top=1','ProductVersionItemCount');
		
		String url1 = 'https://edpqaapi.azurewebsites.net/api/ProductVersionItems';
		
		multimock.setStaticResource(url1,'ProductVersionItem'); 
		
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/json');
		
		Test.startTest();
		
		//Prepare url list for the start method
		List<String> queryList = new List<String>();
		queryList.add('https://edpqaapi.azurewebsites.net/api/ProductVersionItems'); 
		
		//set mock callout mode
		Test.setMock(HttpCalloutMock.class, multimock);
		
		HWS_ProductVersionItem_Batch batch = new HWS_ProductVersionItem_Batch();
		Database.BatchableContext bc;
		SchedulableContext sc;
		batch.start(bc);
		batch.execute(sc);
		batch.execute(bc,queryList);		 
		batch.finish(bc);	  
		Test.StopTest();
		
	}
}