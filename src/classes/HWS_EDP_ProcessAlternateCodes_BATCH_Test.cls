@isTest 

public class HWS_EDP_ProcessAlternateCodes_BATCH_Test {
	
	@isTest 
	static void testproductServicableAltcode5001() 
	{   
		list<hws_versionitem__c> HWVList =new  list<hws_versionitem__c>();
		hws_versionitem__c hwvitem =new  hws_versionitem__c();
		hwvitem.Name='test';
		hwvitem.HWS_Serial_Number_Traceable__c='Yes';
		hwvitem.HWS_Material_Type__c ='123';
		hwvitem.Material_Code__c= '1234';
		hwvitem.HWS_Version_Code__c='test';
		HWVList.add(hwvitem);
		insert HWVList;
		
		list<HWS_AlternateProductCode__c> altcodelist = new list<HWS_AlternateProductCode__c>();
		HWS_AlternateProductCode__c alt = new HWS_AlternateProductCode__c();
		alt.HWS_VersionItem__c=HWVList[0].id;
		alt.HWS_PartType__c='PART';
		alt.Name='test';
		alt.HWS_IsProcessed__c=true;
		alt.HWS_NSNCode__c='NSN123';
		altcodelist.add(alt);
		//insert altcodelist;  
		
		hws_versionitem__c hwvitem1 =new  hws_versionitem__c();
		hwvitem1.Name='test';
		hwvitem1.HWS_Serial_Number_Traceable__c='Yes';
		hwvitem1.HWS_Material_Type__c ='123';
		hwvitem1.Material_Code__c= '1234';
		hwvitem1.HWS_Version_Code__c='test';
		hwvitem1.HWS_NSNCode__c='NSN123';
		hwvitem1.HWS_Source__c='PUMA2';
		insert hwvitem1;
		
		List<product2> prodlist =new List<product2>();
		product2 pr2 = new product2();
		Id rtId = Schema.SObjectType.product2.getRecordTypeInfosByDeveloperName().get('NokiaCPQ_Sales_Product').getRecordTypeId();
		pr2.RecordTypeId =rtId;
		pr2.Name ='ProductCode';
		pr2.IsActive = true;
		pr2.Description='ProductCode';
		pr2.ProductCode = 'NSN123';
		pr2.HWS_DoNotConsider__c=false;
		pr2.CARE_PartCode__c='test';
 		prodlist.add(pr2);
		insert prodlist;
		 
		Test.startTest();
		
		
		HWS_EDP_ProcessAlternateCodes_BATCH batch = new HWS_EDP_ProcessAlternateCodes_BATCH();
		Database.BatchableContext BC;
		SchedulableContext SC;
		batch.start(BC);
		batch.execute(SC);
		batch.execute(BC,altcodelist);		 
		 batch.finish(BC);
		Test.StopTest();
	
		
	}
	
	@isTest 
	static void testproductServicableAltcode5002() 
	{   
		hws_versionitem__c hwvitem =new  hws_versionitem__c();
		hwvitem.Name='test';
		hwvitem.HWS_Serial_Number_Traceable__c='Yes';
		hwvitem.HWS_Material_Type__c ='123';
		hwvitem.Material_Code__c= '1234';
		hwvitem.HWS_Version_Code__c='test';
		 insert hwvitem;
		
		list<HWS_AlternateProductCode__c> altcodelist = new list<HWS_AlternateProductCode__c>();
		HWS_AlternateProductCode__c alt = new HWS_AlternateProductCode__c();
		alt.Name='test';
		alt.HWS_VersionItem__c=hwvitem.id;
		alt.HWS_PartType__c='Material';
		alt.HWS_IsProcessed__c=true;
		alt.HWS_NSNCode__c='NSN123';
		altcodelist.add(alt);
		//insert altcodelist; 

		List<product2> prodlist =new List<product2>();
		product2 pr2 = new product2();
		Id rtId = Schema.SObjectType.product2.getRecordTypeInfosByDeveloperName().get('NokiaCPQ_Sales_Product').getRecordTypeId();
		pr2.RecordTypeId =rtId;
		pr2.Name ='ProductCode';
		pr2.IsActive = true;
		pr2.Description='ProductCode';
		pr2.ProductCode = 'NSN123';
		pr2.HWS_DoNotConsider__c=false;
		pr2.CARE_PartCode__c='test';
 		prodlist.add(pr2);
		insert prodlist;
		
		Test.startTest();
		
		
		HWS_EDP_ProcessAlternateCodes_BATCH batch = new HWS_EDP_ProcessAlternateCodes_BATCH();
		Database.BatchableContext BC;
		SchedulableContext SC;
		batch.start(BC);
		batch.execute(SC);
		batch.execute(BC,altcodelist);		 
		 batch.finish(BC);
		Test.StopTest();
	
		
	}
}