public class FlexibleGroupController {
   
	
	
	//================================================================================
	//
	//
	@AuraEnabled
	public static DataTableResponse getlineitems(Id configId,String bundlecode){
		
		DataTableResponse response = new DataTableResponse();
		try{
			Schema.FieldSet fieldSetObj = Schema.getGlobalDescribe().get('Apttus_Config2__LineItem__c').getDescribe().FieldSets.getMap().get('MarketModel_Listview');
			//To hold the table hearders 
			List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
			String Currencycode = [select CurrencyIsoCode from Apttus_Config2__ProductConfiguration__c where id = :configId].CurrencyIsoCode;
			//Field to be queried - fetched from fieldset
			List<String> lstFieldsToQuery = new List<String>();
			map<string, string> typeattributes = new map<string, string>();
			//The final wrapper response to return to component
			
			
			for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
				String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
				//This way we can set the type of a column
				//We do not get the exact type from schema object which matches to lightning:datatable component structure
				
				if(dataType == 'datetime'){
					dataType = 'date';
				}
				if(dataType == 'double'){
					dataType = 'number';
				}
				if(dataType == 'currency'){
					typeattributes.put('currencyCode',Currencycode);
				}
				//Create a wrapper instance and store label, fieldname and type.
				DataTableColumns datacolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
																	String.valueOf(eachFieldSetMember.getFieldPath()), 
																	dataType,
																   typeattributes);
				lstDataColumns.add(datacolumns);
				lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
			}
			
			//Form an SOQL to fetch the data - Set the wrapper instance and return as response
			if(! lstDataColumns.isEmpty()){			
				response.lstDataTableColumns = lstDataColumns;
				String query = '';
				if(bundlecode == null){
					query = 'SELECT Id, ' + String.join(lstFieldsToQuery, ',') + ' FROM Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c = \''+configId+'\' and Flexible_group_code__c = null';
				}else{
					query = 'SELECT Id, ' + String.join(lstFieldsToQuery, ',') + ' FROM Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c = \''+configId+'\' and Flexible_group_code__c =\''+bundlecode+'\'';
				}
				System.debug(query);
				response.lstDataTableData = Database.query(query);
			}
			
			
		}
		catch(exception ex){
			system.debug('exception'+ex.getMessage());
			ExceptionHandler.addException(ex,GlobalConstants.FlexibleGroupController, GlobalConstants.getlineitems);
		}
		return response;
	}
	
	
	//==========================================================================================
	//
	//
	@AuraEnabled
	public static bundlecreationwrapper updatemarketmodel (String modelname, Integer modelqty, List<Apttus_Config2__LineItem__c> LineitemIdList, Id configId, String GrpPicklist, Boolean QtyChanged){
		system.debug('entered updatemarketmodel');
		system.debug('modelname: '+modelname);
		system.debug('GrpPicklist: '+GrpPicklist);
		List<Apttus_Config2__LineItem__c> LIListupdate = new List<Apttus_Config2__LineItem__c>();
		bundlecreationwrapper BundleCreationData = new bundlecreationwrapper();
		map<Id, Apttus_Config2__LineItem__c> LineItemmap = new map<Id, Apttus_Config2__LineItem__c>() ;
		LineItemmap.putAll(LineitemIdList);
		system.debug('LineItemmap: '+LineItemmap);
		try{
			if(GrpPicklist == 'new'){
				Apttus_Config2__LineItem__c[] LIList = [Select Id, cpq_market_model__c,Flexible_group_code__c,Apttus_Config2__PricingStatus__c,Apttus_Config2__Quantity__c,Apttus_Config2__ConfigurationId__c from Apttus_Config2__LineItem__c where Id in :LineitemIdList and Apttus_Config2__ConfigurationId__c = :configId];
				
				Integer codeseq = getbundlecount(configId) + 1;
				IF(!LIList.isempty()){
					for(Apttus_Config2__LineItem__c LI :LIList){
						LI.cpq_market_model__c = modelname+' QTY('+modelQty+')';
						LI.Flexible_group_code__c = 'SOLUTION00' +codeseq;
						LI.Apttus_Config2__PricingStatus__c = 'Pending';
						LI.Apttus_Config2__Quantity__c = LI.Apttus_Config2__Quantity__c * modelqty;
						LIListupdate.add(LI);
					}
				}
			}else{
				Apttus_Config2__LineItem__c[] LIList = [Select Id, cpq_market_model__c,Flexible_group_code__c,
														Apttus_Config2__PricingStatus__c,Apttus_Config2__Quantity__c,
														Apttus_Config2__ConfigurationId__c 
														from Apttus_Config2__LineItem__c where (Id in :LineItemmap.keyset() or Flexible_group_code__c = :GrpPicklist) and Apttus_Config2__ConfigurationId__c = :configId];
				String FlexiGroupName = [Select cpq_market_model__c from Apttus_Config2__LineItem__c where Flexible_group_code__c = :GrpPicklist and Apttus_Config2__ConfigurationId__c = :configId limit 1].cpq_market_model__c;
	Integer Currentflexiqty = Integer.valueOf(FlexiGroupName.substringBetween('QTY(',')'));	
				system.debug('Currentflexiqty: '+Currentflexiqty);
				IF(!LIList.isempty()){
					for(Apttus_Config2__LineItem__c LI :LIList){
						system.debug('LIbefore modifying :'+LI);
						LI.cpq_market_model__c = modelname + ' QTY('+modelqty+')';
						LI.Flexible_group_code__c = GrpPicklist;
						LI.Apttus_Config2__PricingStatus__c = 'Pending';
					   if(LineItemmap.containskey( LI.Id)){
							LI.Apttus_Config2__Quantity__c = LI.Apttus_Config2__Quantity__c * modelqty;
							
						}else{
							
							   LI.Apttus_Config2__Quantity__c = (LI.Apttus_Config2__Quantity__c/ Currentflexiqty) * modelqty ; 
						 }
						LIListupdate.add(LI);
						system.debug('LI after modifying :'+LI);
					}
				}
			}
			system.debug('LIListupdate: '+LIListupdate);
			if(!LIListupdate.isempty()){
				database.update(LIListupdate);
				
				
				Apttus_CpqApi.CPQ.UpdatePriceRequestDO objUpdatePriceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
				objUpdatePriceRequestDO.CartId = LIListupdate[0].Apttus_Config2__ConfigurationId__c;
				Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(objUpdatePriceRequestDO);
				system.debug('result of reprice api**' + result);
				
				BundleCreationData.StandaloneList =  getlineitems(configId, null);
				BundleCreationData.BundlePickLists = getgrouplist(configId);
				BundleCreationData.BundleData = getbundledata(LIListupdate[0].Flexible_group_code__c,configId);
				BundleCreationData.NewBundleCode = LIListupdate[0].Flexible_group_code__c;
			}
			
		}
		catch(exception ex){
			system.debug('exception'+ex.getMessage());
			ExceptionHandler.addException(ex,GlobalConstants.FlexibleGroupController, GlobalConstants.updatemarketmodel);
		}
		return BundleCreationData;
	}
	
	//=================================================================================================
	
	@AuraEnabled
	public static map<String, String> getgrouplist (Id configId){
		system.debug('getgrouplist');
		map<String, String> grouplist = new map<String, String>();
		List<AggregateResult> aggreslist = [Select cpq_market_model__c,Flexible_group_code__c from Apttus_Config2__LineItem__c 
											where Apttus_Config2__ConfigurationId__c = :configId and 
											CPQ_Market_Model__c != null 
											group by cpq_market_model__c, Flexible_group_code__c];
		if(!aggreslist.isempty()){
			for(AggregateResult aggres: aggreslist){
				if(!grouplist.containsKey((string)aggres.get('Flexible_group_code__c'))){
					grouplist.put((string)aggres.get('Flexible_group_code__c'),(string)aggres.get('cpq_market_model__c'));
				}
			}
		}
		system.debug(grouplist);
		return grouplist;
	}
	
	
	//=================================================================================================
	
	@AuraEnabled
	public static bundledatawrapper getbundledata (string groupcode, Id configId ){
		system.debug('getgrouplist');
		Decimal TotalCLP = 0;
		Decimal TotalCNP = 0;
		String Currencycode;
		bundledatawrapper bundledata = new bundledatawrapper();
		List<String> grouplist = new List<String>();
		try{
		List<Apttus_Config2__LineItem__c> LIlist = [Select cpq_market_model__c,Flexible_group_code__c,NokiaCPQ_ExtendedPrice_CNP__c, NokiaCPQ_Partner_Price__c,currencyIsoCode from Apttus_Config2__LineItem__c 
													where Apttus_Config2__ConfigurationId__c = :configId and 
													Flexible_group_code__c = :groupcode ];
		
		bundledata.BundleList = getlineitems(configId, groupcode);
		If(!LIlist.isempty()){
			Currencycode = LIlist[0].currencyIsoCode;
			for(Apttus_Config2__LineItem__c LI: LIlist){
				
				TotalCNP += LI.NokiaCPQ_ExtendedPrice_CNP__c;
				
			}
			TotalCLP = TotalCNP / Integer.valueOf(LIlist[0].cpq_market_model__c.substringBetween('QTY(',')'));
			bundledata.rollupdata.put('GroupCode',LIlist[0].Flexible_group_code__c);
			bundledata.rollupdata.put('GroupName',LIlist[0].cpq_market_model__c);
			bundledata.rollupdata.put('Quantity',LIlist[0].cpq_market_model__c.substringBetween('QTY(',')'));
			bundledata.rollupdata.put('CLP',String.valueof(TotalCLP));
			bundledata.rollupdata.put('CNP',String.valueof(TotalCNP));
			bundledata.rollupdata.put('Currency',Currencycode);
		}
		}
		catch(exception ex){
			system.debug('exception'+ex.getMessage());
			ExceptionHandler.addException(ex,GlobalConstants.FlexibleGroupController, GlobalConstants.getbundledata);
		}
		return bundledata;
	}
	
	//=======================================================================
	//
	//
	@AuraEnabled
	public static bundlecreationwrapper RemoveLineItems (List<Apttus_Config2__LineItem__c> LineitemIdList, Id configId ){
		
		Apttus_Config2__LineItem__c[] LIList = [Select Id, cpq_market_model__c,Flexible_group_code__c,Apttus_Config2__PricingStatus__c,Apttus_Config2__Quantity__c,Apttus_Config2__ConfigurationId__c from Apttus_Config2__LineItem__c where Id in :LineitemIdList];
		List<Apttus_Config2__LineItem__c> LIListupdate = new List<Apttus_Config2__LineItem__c>();
		bundlecreationwrapper BundleCreationData = new bundlecreationwrapper();
		try{
		String Bundlecode = LIList[0].Flexible_group_code__c;
		
		for(Apttus_Config2__LineItem__c LI :LIList){
			
			LI.Flexible_group_code__c = null;
			LI.Apttus_Config2__PricingStatus__c = 'Pending';
			LI.Apttus_Config2__Quantity__c = LI.Apttus_Config2__Quantity__c / Integer.valueOf(LI.cpq_market_model__c.substringBetween('QTY(',')'));
			LI.cpq_market_model__c = null;
			LIListupdate.add(LI);
		}
		database.update(LIListupdate);
		
		// List<Apttus_Config2__LineItem__c> lineItemList = [Select Id, Apttus_Config2__ConfigurationId__c From Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c ='a6856000000Dy8l' and Apttus_Config2__PricingStatus__c = 'Pending']
		
		Apttus_CpqApi.CPQ.UpdatePriceRequestDO objUpdatePriceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
		objUpdatePriceRequestDO.CartId = LIListupdate[0].Apttus_Config2__ConfigurationId__c;
		Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(objUpdatePriceRequestDO);
		system.debug('result of reprice api**' + result);
	  
		 
		BundleCreationData.StandaloneList =  getlineitems(configId, null);
		BundleCreationData.BundlePickLists = getgrouplist(configId);
		BundleCreationData.BundleData = getbundledata(Bundlecode,configId);
		BundleCreationData.NewBundleCode = Bundlecode;
			}
		catch(exception ex){
			system.debug('exception'+ex.getMessage());
			ExceptionHandler.addException(ex,GlobalConstants.FlexibleGroupController, GlobalConstants.RemoveLineItems);
		}
		
		return BundleCreationData;
	}
	
	//=======================================================================
	//
	//
	public Static Integer getbundlecount(Id ConfigId){
		
		Integer bundleCount = 0;
		for(AggregateResult Aggres : [select Flexible_group_code__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c = :configId and 
									  Flexible_group_code__c != null group by Flexible_group_code__c]){
										  Integer Count = Integer.valueOf(((String)Aggres.get('Flexible_group_code__c')).right(3));
										  
										  bundleCount = bundleCount < Count ?Count : bundleCount;								
										  
									  }
		
		return bundleCount;
	}
	
 /*   @AuraEnabled
	public Static TreeDataResponse gethierarchydata(Id configId){
		
		system.debug('configId: '+configId);
		TreeDataResponse response = new TreeDataResponse();
		try{
			Schema.FieldSet fieldSetObj = Schema.getGlobalDescribe().get('Apttus_Config2__LineItem__c').getDescribe().FieldSets.getMap().get('MarketModel_Listview');
			String Currencycode = [select CurrencyIsoCode from Apttus_Config2__ProductConfiguration__c where id = :configId].CurrencyIsoCode;
			
			map<string, string> typeattributes = new map<string, string>();
			
			//To hold the table hearders 
			List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
			
			//Field to be queried - fetched from fieldset
			List<String> lstFieldsToQuery = new List<String>();
			
			//The final wrapper response to return to component
			
			
			for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
				String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
				//This way we can set the type of a column
				//We do not get the exact type from schema object which matches to lightning:datatable component structure
				
				if(dataType == 'datetime'){
					dataType = 'date';
				}
				if(dataType == 'double'){
					dataType = 'number';
				}
				if(dataType == 'currency'){
					typeattributes.put('currencyCode',Currencycode);
				}
				//Create a wrapper instance and store label, fieldname and type.
				DataTableColumns datacolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
																	String.valueOf(eachFieldSetMember.getFieldPath()), 
																	dataType,
																   typeattributes);
				lstDataColumns.add(datacolumns);
				lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
			}
			
			//Form an SOQL to fetch the data - Set the wrapper instance and return as response
			if(! lstDataColumns.isEmpty()){			
				response.lstDataTableColumns = lstDataColumns;
				
				map<String, List<Apttus_Config2__LineItem__c>> FlexiGrpwithrelatedLI = new map<String, List<Apttus_Config2__LineItem__c>>();
				map<String, Decimal> FlexiGrpwithrollupdata = new map<String, Decimal>();
				String query = '';
				String extra_fields =  ',Flexible_group_code__c,cpq_market_model__c';
				query = 'SELECT Id, ' + String.join(lstFieldsToQuery, ',') +extra_fields+ ' FROM Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c = \''+configId+'\'';
				System.debug(query);
				
				For(Apttus_Config2__LineItem__c LineItem_rec:  Database.query(query)){
					Apttus_Config2__LineItem__c Flexiblegrouprecord = new Apttus_Config2__LineItem__c();
					Parentwrapper ParentLeveldata = new Parentwrapper();
					if(LineItem_rec.cpq_market_model__c != null && LineItem_rec.cpq_market_model__c != ''){
						
						if(FlexiGrpwithrollupdata.containsKey(LineItem_rec.Flexible_group_code__c)){
							Decimal Total = LineItem_rec.NokiaCPQ_ExtendedPrice_CNP__c + FlexiGrpwithrollupdata.get(LineItem_rec.Flexible_group_code__c) ;
							FlexiGrpwithrollupdata.put(LineItem_rec.Flexible_group_code__c, Total) ;
						}else{
							FlexiGrpwithrollupdata.put(LineItem_rec.Flexible_group_code__c,LineItem_rec.NokiaCPQ_ExtendedPrice_CNP__c);
						}
						
						if(FlexiGrpwithrelatedLI.containsKey(LineItem_rec.Flexible_group_code__c)){
							FlexiGrpwithrelatedLI.get(LineItem_rec.Flexible_group_code__c).add(LineItem_rec);
						}else{
							FlexiGrpwithrelatedLI.put(LineItem_rec.Flexible_group_code__c, new List<Apttus_Config2__LineItem__c>{LineItem_rec});
						}
						
					}else{
						ParentLeveldata.parentobj = LineItem_rec;
						response.lstDataTableData.add(ParentLeveldata);
					}
					system.debug('ParentLeveldata: '+ParentLeveldata);
					
				}
				
				for(String GroupCode: FlexiGrpwithrelatedLI.keyset()){
					Parentwrapper Parentdata = new Parentwrapper();
					Apttus_Config2__LineItem__c Flexible_grp = new Apttus_Config2__LineItem__c();
					
					Parentdata.isflexiblegroup = true;
					Parentdata.RollupAmount = FlexiGrpwithrollupdata.get(GroupCode);
					parentdata.childdata.addall(FlexiGrpwithrelatedLI.get(GroupCode)) ;
					system.debug('Parentdata: '+Parentdata);
					response.lstDataTableData.add(Parentdata);
				}
			}
			
			system.debug('response: '+response);
		}
		catch(exception ex){
			system.debug('exception'+ex.getMessage());
			ExceptionHandler.addException(ex,GlobalConstants.FlexibleGroupController, GlobalConstants.getlineitems);
		}
		return response;
	}
	
	*/
	//=========================================================================
	
	@AuraEnabled
	public Static HierarchyDataResponse gethierarchydatafixedcol(Id configId){
		
		system.debug('configId: '+configId);
		HierarchyDataResponse response = new HierarchyDataResponse();
		try{
			Schema.FieldSet fieldSetObj = Schema.getGlobalDescribe().get('Apttus_Config2__LineItem__c').getDescribe().FieldSets.getMap().get('MarketModel_Listview');
			String Currencycode = [select CurrencyIsoCode from Apttus_Config2__ProductConfiguration__c where id = :configId].CurrencyIsoCode;
			
			map<string, string> typeattributes = new map<string, string>();
			
			//To hold the table hearders 
			List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
			
			//Field to be queried - fetched from fieldset
			List<String> lstFieldsToQuery = new List<String>();
			
			//The final wrapper response to return to component
			
			
			for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
				String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
				String fieldname = String.valueOf(eachFieldSetMember.getFieldPath());
				//This way we can set the type of a column
				//We do not get the exact type from schema object which matches to lightning:datatable component structure
				
				if(dataType == 'double'){
					dataType = 'number';
				}
				if(dataType == 'currency'){
					typeattributes.put('currencyCode',Currencycode);
				}
				//Create a wrapper instance and store label, fieldname and type.
				DataTableColumns datacolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
																	fieldname.removeEndIgnoreCase('__c'), 
																	dataType,
																   typeattributes);
				lstDataColumns.add(datacolumns);
				lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
			}
			
			//Form an SOQL to fetch the data - Set the wrapper instance and return as response
			if(! lstDataColumns.isEmpty()){			
				response.lstDataTableColumns = lstDataColumns;
				
				map<String, List<Lineitemchildwrapper>> FlexiGrpwithrelatedLI = new map<String, List<Lineitemchildwrapper>>();
				map<String, Decimal> FlexiGrpwithrollupdata = new map<String, Decimal>();
				map<String, String> FlexiGrpcodewithname = new map<String, String>();
				String query = '';
				String extra_fields =  ',Flexible_group_code__c,cpq_market_model__c';
				query = 'SELECT Id, ' + String.join(lstFieldsToQuery, ',') +extra_fields+ ' FROM Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c = \''+configId+'\'';
				System.debug(query);
				
				For(Apttus_Config2__LineItem__c LineItem_rec:  Database.query(query)){
					Lineitemparentwrapper ParentLeveldata = new Lineitemparentwrapper();
					
					
					if(LineItem_rec.cpq_market_model__c != null && LineItem_rec.cpq_market_model__c != ''){
						Lineitemchildwrapper childdata = new Lineitemchildwrapper();
						FlexiGrpcodewithname.put(LineItem_rec.Flexible_group_code__c,LineItem_rec.cpq_market_model__c);
						
						childdata.LineId = LineItem_rec.Id;
						childdata.NokiaCPQ_Part_Number = LineItem_rec.NokiaCPQ_Part_Number__c;
						childdata.NokiaCPQ_Product_Name = LineItem_rec.NokiaCPQ_Product_Name__c;
						childdata.Apttus_Config2_Quantity = LineItem_rec.Apttus_Config2__Quantity__c/ Integer.valueOf(LineItem_rec.cpq_market_model__c.substringBetween('QTY(',')'));
						childdata.NokiaCPQ_ExtendedPrice_CNP = (LineItem_rec.NokiaCPQ_ExtendedPrice_CNP__c/ Integer.valueOf(LineItem_rec.cpq_market_model__c.substringBetween('QTY(',')'))).setscale(2);
						
						if(FlexiGrpwithrollupdata.containsKey(LineItem_rec.Flexible_group_code__c)){
							Decimal Total = LineItem_rec.NokiaCPQ_ExtendedPrice_CNP__c + FlexiGrpwithrollupdata.get(LineItem_rec.Flexible_group_code__c) ;
							FlexiGrpwithrollupdata.put(LineItem_rec.Flexible_group_code__c, Total) ;
						}else{
							FlexiGrpwithrollupdata.put(LineItem_rec.Flexible_group_code__c,LineItem_rec.NokiaCPQ_ExtendedPrice_CNP__c);
						}
						
						if(FlexiGrpwithrelatedLI.containsKey(LineItem_rec.Flexible_group_code__c)){
							FlexiGrpwithrelatedLI.get(LineItem_rec.Flexible_group_code__c).add(childdata);
						}else{
							FlexiGrpwithrelatedLI.put(LineItem_rec.Flexible_group_code__c, new List<Lineitemchildwrapper>{childdata});
						}
						
					}else{
						ParentLeveldata.LineId = LineItem_rec.Id;
						ParentLeveldata.NokiaCPQ_Part_Number = LineItem_rec.NokiaCPQ_Part_Number__c;
						ParentLeveldata.NokiaCPQ_Product_Name = LineItem_rec.NokiaCPQ_Product_Name__c;
						ParentLeveldata.Apttus_Config2_Quantity = LineItem_rec.Apttus_Config2__Quantity__c;
						ParentLeveldata.NokiaCPQ_ExtendedPrice_CNP = LineItem_rec.NokiaCPQ_ExtendedPrice_CNP__c;
						response.lstDataTableData.add(ParentLeveldata);
					}
					system.debug('ParentLeveldata: '+ParentLeveldata);
					
				}
				system.debug('FlexiGrpwithrelatedLI: '+FlexiGrpwithrelatedLI);
				List<String> FlexiGroupcodeList = new List<String>();
				FlexiGroupcodeList.addall(FlexiGrpwithrelatedLI.keyset());
				FlexiGroupcodeList.sort();
				
				for(String GroupCode: FlexiGroupcodeList){
					Lineitemparentwrapper Parentdata = new Lineitemparentwrapper();
					parentdata.childrenwrapper = new List<Lineitemchildwrapper>();
					system.debug('FlexiGrpwithrelatedLI.get(GroupCode): '+FlexiGrpwithrelatedLI.get(GroupCode));		 
					Parentdata.LineId = getUUID();
					Parentdata.NokiaCPQ_ExtendedPrice_CNP = FlexiGrpwithrollupdata.get(GroupCode);
					Parentdata.NokiaCPQ_Part_Number = GroupCode;
					Parentdata.NokiaCPQ_Product_Name = FlexiGrpcodewithname.get(GroupCode);
					Parentdata.Apttus_Config2_Quantity = Decimal.valueOf(FlexiGrpcodewithname.get(GroupCode).substringBetween('QTY(',')')).setscale(0);
					parentdata.childrenwrapper.addall(FlexiGrpwithrelatedLI.get(GroupCode)) ;
					system.debug('Parentdata: '+Parentdata);
					response.lstDataTableData.add(Parentdata);
					response.expandedrowslist.add(Parentdata.LineId);
				}
			}
			
			system.debug('response: '+response);
		}
		catch(exception ex){
			system.debug('exception'+ex.getMessage());
			ExceptionHandler.addException(ex,GlobalConstants.FlexibleGroupController, GlobalConstants.getlineitems);
		}
		return response;
	}
	//======================
	
	public static String getUUID()
	{
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
		system.debug(guid);
		return guid;
	}
	//=======================================================================
	//
	//
	public class bundledatawrapper{
		
		@AuraEnabled
		public map<string,string> rollupdata {get;set;}
		@AuraEnabled
		public DataTableResponse BundleList {get;set;}
		
		public bundledatawrapper(){
			
			BundleList = new DataTableResponse();
			rollupdata = new map<string,string>();
		}
		
	}   
	
	//=======================================================================
	//
	//
	public class bundlecreationwrapper{
		
		@AuraEnabled
		public DataTableResponse StandaloneList {get;set;}
		@AuraEnabled
		public bundledatawrapper BundleData {get;set;}
		@AuraEnabled
		public map<String, String> BundlePicklists {get;set;}
		@AuraEnabled
		public String NewBundleCode {get;set;}
		
		public bundlecreationwrapper(){
			
			StandaloneList = new DataTableResponse();
			BundlePicklists = new map<string,string>();
			BundleData = new bundledatawrapper();
			NewBundleCode = '';
		}
		
	}	
	//Wrapper class to hold Columns with headers
	public class DataTableColumns {
		@AuraEnabled
		public String label {get;set;}
		@AuraEnabled	   
		public String fieldName {get;set;}
		@AuraEnabled
		public String type {get;set;}
		@AuraEnabled
		public map<string,string> typeAttributes {get;set;}
		
		//Create and set three variables label, fieldname and type as required by the lightning:datatable
		public DataTableColumns(String label, String fieldName, String type, map<string,string> typeAttributes){
			this.label = label;
			this.fieldName = fieldName;
			this.type = type;
			this.typeAttributes = typeAttributes;	   
		}
	}
	
	//Wrapper calss to hold response - This response is used in the lightning:datatable component
	public class DataTableResponse {
		@AuraEnabled
		public List<DataTableColumns> lstDataTableColumns {get;set;}
		@AuraEnabled
		public List<sObject> lstDataTableData {get;set;}
		
		
		public DataTableResponse(){
			lstDataTableColumns = new List<DataTableColumns>();
			lstDataTableData = new List<sObject>();
		}
	}
	
	public class TreeDataResponse {
		@AuraEnabled
		public List<DataTableColumns> lstDataTableColumns {get;set;}
		@AuraEnabled
		public List<Parentwrapper> lstDataTableData {get;set;}
		
		public TreeDataResponse(){
			lstDataTableColumns = new List<DataTableColumns>();
			lstDataTableData = new List<Parentwrapper>();
		}
	}
	
	public class Parentwrapper {
		@AuraEnabled
		public Apttus_Config2__LineItem__c parentobj {get;set;}
		@AuraEnabled
		public List<Apttus_Config2__LineItem__c> childdata {get;set;}
		@AuraEnabled
		public boolean isflexiblegroup {get;set;}
		@AuraEnabled
		public Decimal RollupAmount {get;set;}
		
		public Parentwrapper(){
			parentobj = new Apttus_Config2__LineItem__c() ;
			childdata = new List<Apttus_Config2__LineItem__c>();
			isflexiblegroup = false;
			RollupAmount =0;
			
		}
		
	}
	
	public Class Childwrapper{
		@AuraEnabled
		public sObject childobj {get;set;}
		@AuraEnabled
		public List<Childwrapper> childdata {get;set;}
	}
	
	public class HierarchyDataResponse {
		@AuraEnabled
		public List<DataTableColumns> lstDataTableColumns {get;set;}
		@AuraEnabled
		public List<Lineitemparentwrapper> lstDataTableData {get;set;}
		@AuraEnabled
		public List<String> expandedrowslist {get;set;}
		
		public HierarchyDataResponse(){
			lstDataTableColumns = new List<DataTableColumns>();
			lstDataTableData = new List<Lineitemparentwrapper>();
			expandedrowslist = new List<String>();
		}
	}
	
	public class Lineitemparentwrapper{
		@AuraEnabled
		public String LineId {get;set;}
		@AuraEnabled
		public String NokiaCPQ_Part_Number {get;set;}
		@AuraEnabled
		public String NokiaCPQ_Product_Name {get;set;}
		@AuraEnabled
		public Decimal Apttus_Config2_Quantity {get;set;}
		@AuraEnabled
		public Decimal NokiaCPQ_ExtendedPrice_CNP {get;set;}
		@AuraEnabled
		public List<Lineitemchildwrapper> childrenwrapper {get;set;}
		
		}
	
	public class Lineitemchildwrapper{
		@AuraEnabled
		public String LineId {get;set;}
		@AuraEnabled
		public String NokiaCPQ_Part_Number {get;set;}
		@AuraEnabled
		public String NokiaCPQ_Product_Name {get;set;}
		@AuraEnabled
		public Decimal Apttus_Config2_Quantity {get;set;}
		@AuraEnabled
		public Decimal NokiaCPQ_ExtendedPrice_CNP {get;set;}
	}
}