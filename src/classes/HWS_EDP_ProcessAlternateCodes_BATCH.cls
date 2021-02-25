global class HWS_EDP_ProcessAlternateCodes_BATCH implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
	/****************************************
* Name : AletnateCode records process
* Author : TCS
* Description : 
* User Stroy : 

/****************************************
* Name : execute
* Description : executes the batch class using schedulable instance
* Parameters: SchedulableContext
*****************************************/
	global void execute(SchedulableContext sc)	  
	{
		HWS_EDP_ProcessAlternateCodes_BATCH batch= new HWS_EDP_ProcessAlternateCodes_BATCH();
		Database.executebatch(batch,1);			
	} 
	
	/****************************************
* Name : start
* Description : Retrieves the data from ProductAlternateCode
* Parameters: Database.BatchableContext
* Returns : Database.QueryLocator
*****************************************/
	global Database.QueryLocator start(Database.BatchableContext bc)
	{
		
		String squery = 'select Name,HWS_VersionItem__c,HWS_PartType__c , HWS_IsProcessed__c ,HWS_NSNCode__c from HWS_AlternateProductCode__c where HWS_IsProcessed__c = false';
		return database.getQueryLocator(squery);
	}
	
	/****************************************
* Name : execute
* Description : Retrieves the data from product serviceable version item staging object
* Parameters: Database.BatchableContext, List of Product sales item
* Returns : 
*****************************************/	
	global void execute(Database.BatchableContext bc, List<HWS_AlternateProductCode__c> alternatecodes)
	{	 
		try 
		{ 
			List<HWS_AlternateProductCode__c> toUpdateprodSerAltCode = new List<HWS_AlternateProductCode__c>();
			Map<String,Id> nsnVerIdMap = new Map<String,Id>();
			Set<String> nsnCodesforVersion= new Set<String>();
			Map<String,String> nsncaresCodeMap = new Map<String,String>();
			Map<String,HWS_AlternateProductCode__c> alternatecodesmap = new Map<String,HWS_AlternateProductCode__c>();
			
			
			for(HWS_AlternateProductCode__c prodAltCode : alternatecodes){
				nsnCodesforVersion.add(prodAltCode.HWS_NSNCode__c);  
			}
			
			List<HWS_VersionItem__c> versionItemList = [Select id,HWS_NSNCode__c from HWS_VersionItem__c where HWS_NSNCode__c in: nsnCodesforVersion and HWS_Source__c='PUMA2'];		
			if(versionItemList.size()>0){
				for(HWS_VersionItem__c version : versionItemList){
					nsnVerIdMap.put(version.HWS_NSNCode__c,version.Id);
				}
			}
			
			
			for(HWS_AlternateProductCode__c prodAltCode : alternatecodes){
				if(prodAltCode.HWS_PartType__c =='PART'){
					nsnCodesforVersion.add(prodAltCode.HWS_NSNCode__c);
					nsncaresCodeMap.put(prodAltCode.HWS_NSNCode__c,prodAltCode.Name);
					alternatecodesmap.put(prodAltCode.HWS_NSNCode__c,prodAltCode);
				  }else{
					prodAltCode.HWS_VersionItem__c = nsnVerIdMap.get(prodAltCode.HWS_NSNCode__c);
					if(prodAltCode.HWS_VersionItem__c!=null){
						  prodAltCode.HWS_IsProcessed__c=true; 
					}
					toUpdateprodSerAltCode.add(prodAltCode);
					system.debug(nsnVerIdMap.get(prodAltCode.HWS_NSNCode__c));
					
				}
			}
			
			
			List<Product2> listProd = [Select id, ProductCode from Product2 where ProductCode in:nsnCodesforVersion and HWS_DoNotConsider__c=false ];
			List<Product2> listProdNew = new List<Product2>();
			system.debug('List Product Size: '+listProd.size());
			if(listProd.size()>0){
				for(Product2 prod : listProd){
					Product2 newProd = new Product2();
					newProd.Id = prod.Id;
					newProd.CARE_PartCode__c = nsncaresCodeMap.get(prod.ProductCode);
					if(newProd.CARE_PartCode__c !=null)
					{
						HWS_AlternateProductCode__c altcode= alternatecodesmap.get(prod.ProductCode);
						altcode.HWS_IsProcessed__c=true;
						toUpdateprodSerAltCode.add(altcode);
					}
					listProdNew.add(newProd);
				} 
			}
			
			
			List<Database.SaveResult> resultscares = Database.update(listProdNew,false);
			List<Database.SaveResult> resultsalternatecodes = Database.update(toUpdateprodSerAltCode,false);
			
			List<interface_log__c> ilogs = new List<interface_log__c>();
			for(Integer index = 0, size = resultscares.size(); index < size; index++) {
				if(!resultscares[index].isSuccess()) { 
					Interface_Log__c ilogpr = new Interface_Log__c();
					for (Database.Error err : resultscares[index].getErrors()){
						ilogpr.comment__c = 'Fields: '+err.getFields()+'Message: '+err.getMessage()+
							'Status Code: '+err.getStatusCode();
					}
					ilogpr.Interface_Type__c = 'HWS AletnateCode For Part';
					ilogpr.Message_Type__c = 'Inbound';
					ilogpr.Operation_Type__c = 'update';
					ilogpr.Status__c = 'Failure';
					ilogpr.Name = 'Product Serviceable Alternate Code Failure with NSNCode: '+ listProdNew[index].ProductCode;
					ilogs.add(ilogpr);
				} 
				
			}
			
			
			for(Integer index = 0, size = resultsalternatecodes.size(); index < size; index++) {
				if(!resultsalternatecodes[index].isSuccess()) { 
					Interface_Log__c ilogpr = new Interface_Log__c();
					for (Database.Error err : resultsalternatecodes[index].getErrors()){
						ilogpr.comment__c = 'Fields: '+err.getFields()+'Message: '+err.getMessage()+
							'Status Code: '+err.getStatusCode();
					}
					ilogpr.Interface_Type__c = 'HWS AletnateCode For Part Revison';
					ilogpr.Message_Type__c = 'Inbound';
					ilogpr.Operation_Type__c = 'update';
					ilogpr.Status__c = 'Failure';
					ilogpr.Name = 'Product Serviceable Alternate Code Failure with NSNCode: '+ toUpdateprodSerAltCode[index].HWS_NSNCode__c;
					ilogs.add(ilogpr);
					
				} 
				
			}
			
			
			Database.SaveResult[] results = Database.insert(ilogs,false);
			nsnVerIdMap.clear(); 
			nsnCodesforVersion.clear();
			nsnCodesforVersion.clear();
			nsncaresCodeMap.clear();
			resultscares.clear();
			ilogs.clear();
			alternatecodesmap.clear();
			
			
		}	  
		catch (DmlException e) { 
			System.debug('There was an error during the AletnateCode Insert'); 
		} 
		
		
	}
	
	/****************************************
* Name : finish
* Description : 
* Parameters: Database.BatchableContext
* Returns : 
*****************************************/ 
	global void finish(Database.BatchableContext bc)
	{
		HWS_EDP_BuildRelation_Product_Part batch = new HWS_EDP_BuildRelation_Product_Part();
		Database.executebatch(batch,2000);  
	}
	
	
}