@istest
public class HWS_EDP_SVItoVersionItem_BATCH_Test {
	@istest
	public static  void getTestMethods(){
		
		Test.startTest();	
		
		HWS_Product_Serviceable_Version_Item__c prdSerVitem = new HWS_Product_Serviceable_Version_Item__c();
		
		prdSerVitem.HWS_EDP_ActiveStatus__c = true ;
		prdSerVitem.HWS_EDP_DeletedAtSource__c = true ;
		// prdSerVitem.LastModifiedDate = System.TODAY();  HWS_NSNCode__c
		prdSerVitem.HWS_FITRate__c = 'test';
		prdSerVitem.HWS_MaterialType__c = 'test';
		prdSerVitem.HWS_PartRevision__c = 'test';
		prdSerVitem.HWS_NSNCode__c = 'HWS_NSNCode__c';
		
		List<HWS_Product_Serviceable_Version_Item__c> pslst = new List<HWS_Product_Serviceable_Version_Item__c>();
		pslst.add(prdSerVitem);
		insert pslst;
		System.assertEquals(pslst[0].HWS_FITRate__c, 'test');
		
		//Parmeters for pricelist mapping
		NokiaCPQ_PMDI_Parameter__c lp= new NokiaCPQ_PMDI_Parameter__c();
		lp.Name='Currency Update';
		lp.NokiaCPQ_ObjNameSrc__c='HWS_Product_Version_Item__c';
		lp.NokiaCPQ_ObjNameTrg__c='HWS_Product_Version_Item__c';
		lp.NokiaCPQ_ParaFrom__c='HWS_NSNCode__c';
		lp.NokiaCPQ_ParaTo__c='HWS_NSNCode__c';
		lp.NokiaCPQ_ParaType__c='MAPPING RULE';		
		lp.NokiaCPQ_ReqMap__c=  false;
		lp.NokiaCPQ_Active__c = true;
		
		NokiaCPQ_PMDI_Parameter__c lp1 = new NokiaCPQ_PMDI_Parameter__c();
		lp1.Name='Currency Update';
		lp1.NokiaCPQ_ObjNameSrc__c='HWS_Product_Serviceable_Version_Item__c';
		lp1.NokiaCPQ_ObjNameTrg__c='HWS_Product_Serviceable_Version_Item__c';
		lp1.NokiaCPQ_ParaFrom__c='HWS_NSNCode__c';
		lp1.NokiaCPQ_ParaTo__c='HWS_NSNCode__c';
		lp1.NokiaCPQ_ParaType__c='MAPPING RULE';	   
		lp1.NokiaCPQ_ReqMap__c=  false;
		lp1.NokiaCPQ_Active__c = true;
		
		
		List<NokiaCPQ_PMDI_Parameter__c> lparas = new List<NokiaCPQ_PMDI_Parameter__c>();
		lparas.add(lp);
		lparas.add(lp1);	   
		insert lparas; 
		
		HWS_Settings__c hwsSetSVI = new HWS_Settings__c();
		// hwsSetSVI.Name = 'SVI Batch Size';
		hwsSetSVI.Name = 'SSI_SVI Batch Size';
		hwsSetSVI.SettingValue__c = 2000;
		hwsSetSVI.Description__c = 'test';	  
		insert hwsSetSVI;
		
		HWS_Settings__c hwsSetPVI = new HWS_Settings__c();
		hwsSetPVI.Name = 'PVI Batch Size';
		hwsSetPVI.SettingValue__c = 2000;
		hwsSetPVI.Description__c = 'test';	  
		insert hwsSetPVI;
		
		
		Product2 prod = HWS_DataFactory_TEST.insertproduct2();		
		insert prod;
		
		HWS_VersionItem__c hwsv=HWS_DataFactory_TEST.createVerionsItems(prod.ID);   
		insert hwsv;
		
		List<HWS_VersionItem__c> vi = HWS_ProcessServiceableVersionItem_SVC.updateTarget(pslst, lparas);
		
		HWS_EDP_SVItoVersionItem_BATCH svibatch = new HWS_EDP_SVItoVersionItem_BATCH();
		Database.BatchableContext bc;
		SchedulableContext sc;
		List<HWS_VersionItem__c > hviLst = new List<HWS_VersionItem__c>();
		HWS_VersionItem__c hwsvi = new HWS_VersionItem__c(Id='aCS560000008PRx');
		hviLst.add(hwsvi);
		Database.Error[] errors;
		Database.SaveResult[] results = Database.insert(hviLst,false);
		for (Database.SaveResult sr : results) {			
			if (sr.isSuccess()) {		
			}
			else{
	errors = sr.getErrors();
			}
		}	  
		svibatch.execute(sc);
		svibatch.getFields();
		svibatch.start(bc);	   
		svibatch.execute(bc,pslst);
		if(errors.size()>0){
			svibatch.createErrorLog(errors, hwsvi, 'Update');
		}
		svibatch.finish(bc);
		Test.stopTest();
	}
}