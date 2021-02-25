/****************************************
 * Class Name : HWS_ProductServiceableAltCode_Batch_Test
 * Created Date: 15th mar 2019
 * Created By : TCS
 * Last Modified by: 
 * Last Modified Date: 
 * Description : Test class for loading product Servicable code master data from edp to salesforce 
*****************************************/
@isTest
public class HWS_ProductServiceableAltCode_Batch_Test {
	@testSetup
	public static void createTestData()
	{
		List<EDP_HWS_Settings__c> edpEntryList = new List<EDP_HWS_Settings__c>();
		 
		 //Create custom settings entries for test data
		 EDP_HWS_Settings__c edpEntry = new EDP_HWS_Settings__c();
		 edpEntry.Name = 'ProductServiceableAltCode';
		 edpEntry.Full_Load_Filter__c ='Yes';
		 edpEntry.Full_Load__c = true;
		 edpEntry.ModifiedDate__c = Date.today();
		 edpEntryList.add(edpEntry);	
		 insert edpEntryList;
				  
		 List<EDP_URLs__c> edpURLList = new List<EDP_URLs__c>();
		 EDP_URLs__c edpURL1 = new EDP_URLs__c();
		 edpURL1.name = 'PSAC';
		 edpURL1.URL__c = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode';
		 edpURLList.add(edpURL1);
		
		// inserting resource data required to generate the Token
		EDP_URLs__c edpURL2 = new EDP_URLs__c();
		edpURL2.name = 'resource';
		edpURL2.URL__c = 'https://edpqaapi.azurewebsites.net';
		edpURLList.add(edpURL2);
		
		 insert edpURLList;
		
		//creating data for Skip Count
		List<HWS_Skipcount__c> skipEntryList = new List<HWS_Skipcount__c>();
		HWS_Skipcount__c skipEntry1 = new HWS_Skipcount__c();
		skipEntry1.name = 'PSAC';
		skipEntry1.Skip_Count__c = null;
		skipEntryList.add(skipEntry1);
		insert skipEntryList;
	} 
  
	@isTest 
	static void testproductServicableAltcode() 
	{
		//Setting callout mock for loading data from static resource		
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String ciPath = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode';
		String tokenPath = 'https://login.microsoftonline.com/5d471751-9675-428d-917b-70f44f9630b0/oauth2/token';
		String calloutPath = 'callout:EDP_Login';
		
		multimock.setStaticResource(ciPath, 'ProductServiceableAltCode');
		multimock.setStaticResource(tokenPath,'ProductToken');
		multimock.setStaticResource(calloutPath,'ProductToken');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$count=true&$top=1','ProductServiceableAltCodeCount');
		//multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=3000&$top=3000','ProductServiceableAltCodeCount');
		//multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=6000&$top=3000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=1000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=2000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=3000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=4000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=5000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=6000&$top=1000','ProductServiceableAltCodeCount');
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
		//batch.execute(SC);
		batch.execute(bc,queryList);		 
		batch.finish(bc);
		Test.StopTest();
		
	}   
	
	 @isTest 
	static void testproductServicableAltcode1() 
	{
		
		//Setting callout mock for loading data from static resource		
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String ciPath = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode';
		String tokenPath = 'https://login.microsoftonline.com/5d471751-9675-428d-917b-70f44f9630b0/oauth2/token';
		String calloutPath = 'callout:EDP_Login';
		
		multimock.setStaticResource(ciPath, 'ProductServiceableAltCode');
		multimock.setStaticResource(tokenPath,'ProductToken');
		multimock.setStaticResource(calloutPath,'ProductToken');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$count=true&$top=1','ProductServiceableAltCodeCount');
		//multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=3000&$top=3000','ProductServiceableAltCodeCount');
	   // multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=6000&$top=3000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=1000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=2000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=3000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=4000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=5000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?&$skip=6000&$top=1000','ProductServiceableAltCodeCount');
		 String url1 = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode';
		
		multimock.setStaticResource(url1,'ProductServiceableAltCode'); 
		
		multimock.setStatusCode(201);
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
		batch.execute(bc,queryList);		 
		 batch.finish(bc);
		 batch.execute(sc);
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
		 multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$count=true&$top=1','ProductServiceableAltCodeCount');
		 
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
		// batch.execute(SC);
		 batch.execute(bc,queryList);		 
		 batch.finish(bc);	  
		 Test.StopTest();
		
	}   
	
	
	@isTest 
	static void testproductServicableAltcode5001() 
	{
		EDP_HWS_Settings__c edpEntry = EDP_HWS_Settings__c.getInstance('ProductServiceableAltCode');
		edpEntry.Full_Load_Filter__c ='Yes';
		edpEntry.Full_Load__c = false;
		edpEntry.ModifiedDate__c = Date.newInstance(2019,03,26);
		update edpEntry;
		
		//Setting callout mock for loading data from static resource		
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		String ciPath = 'https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode';
		String tokenPath = 'https://login.microsoftonline.com/5d471751-9675-428d-917b-70f44f9630b0/oauth2/token';
		String calloutPath = 'callout:EDP_Login';
		
		multimock.setStaticResource(ciPath, 'ProductServiceableAltCode');
		multimock.setStaticResource(tokenPath,'ProductToken');
		multimock.setStaticResource(calloutPath,'ProductToken');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$count=true&$top=1','ProductServiceableAltCodeCount');
		//multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=3000&$top=3000','ProductServiceableAltCodeCount');
	   // multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=6000&$top=3000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=1000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=2000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=3000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=4000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=5000&$top=1000','ProductServiceableAltCodeCount');
		multimock.setStaticResource('https://edpqaapi.azurewebsites.net/api/ProductServiceableAlternateCode?$filter=EDP_LastModifiedDate%20gt%202019-03-26T05:30:00Z&$skip=6000&$top=1000','ProductServiceableAltCodeCount');
												
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
		batch.execute(bc,queryList);		 
		 batch.finish(bc);
		//batch.execute(SC);
		Test.StopTest();
	
		
	}
	
   
	@isTest 
	 static void testproductServicableVersionWrapper() 
	 {
		 HWS_UploadToProductServicableAltCodes.ProdAltCodeWrapper wrap = new HWS_UploadToProductServicableAltCodes.ProdAltCodeWrapper();
		 wrap.EDP_ActiveStatus = true;
		 wrap.EDP_DeletedAtSource = true;
		 wrap.EDP_LastModifiedDate = date.today();
		 wrap.NSNCode='2';
		 wrap.AlternateCodeValue = 'none';
		 //wrap.NSNCode = '90983747576';
		 wrap.AlternateCodeType='223';
		 wrap.PartType = 'test';
		 //wrap.PartRevisionFormat='test';
		 wrap.SourceSystem='test';
		// wrap.SerialNumberFormat='test';
		// wrap.SerialNumberTraceable='test';
		// wrap.Source='test';
	 }
}