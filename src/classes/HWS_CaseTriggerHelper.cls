/****************************************
* Class Name : Hws_CaseTriggerHelper
* Created Date: 22 Nov 2018
* Created By : TCS
* Last Modified by: TCS
* Last Modified Date: 
* Description : Contains common business logic
* Test Class: CH_CaseTriggerHelperTest
*****************************************/
public without sharing class HWS_CaseTriggerHelper {
	public static Set<String> childCaseStatuses = new Set<String>{'Closed','Cancelled'};
	public static Set<String> childCaseSOOStatuses = new Set<String>{'Open-ReceivedAndDelivered','Resolved-Cancelled'};
	public static Set<String> childCaseStatusesforDuplicte = new Set<String>{'Closed','Cancelled','Delivered'};
	public static Id exchangeInDays {
		get {
			if(exchangeInDays == null){
				exchangeInDays = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_Advance_Exchange_In_Days);
			}
			return exchangeInDays;
		}
		set;
	}
	public static Id exchangeInHours {
		get {
			if(exchangeInHours == null){
				exchangeInHours = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_ADVANCE_EXCHANGE_IN_HOURS);
			}
			return exchangeInHours;
		}
		set;
	}
	public static Id childCaseReadOnly {
		get {
			if(childCaseReadOnly == null){
				childCaseReadOnly = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_CHILD_CASE_READ_ONLY);
			}
			return childCaseReadOnly;
		}
		set;
	}
	public static Id sPSCaseRType {
		get {
			if(sPSCaseRType == null){
				sPSCaseRType = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_SPS_PART_SALES);
			}
			return sPSCaseRType;
		}
		set;
	}
	public static Id spsReadOnly {
		get {
			if(spsReadOnly == null){
				spsReadOnly = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_SPS_PART_SALES_READ_ONLY);
			}
			return spsReadOnly;
		}
		set;
	}
	public static Id returnForRepairCaseRType {
		get {
			if(returnForRepairCaseRType == null){
				returnForRepairCaseRType = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_RETURN_FOR_REPAIR);
			}
			return returnForRepairCaseRType;
		}
		set;
	}
	
	public static Set<ID> recordTypeIds = new Set<ID> {exchangeInDays,exchangeInHours};	
	// To ensure field tracking is performed only once per transaction
	public static boolean fieldTrackingChecked = false;	
	public static boolean fieldChecked = false;
	public static boolean updateCheck = true;	
	public static boolean updateStatCheck = true; 
	static final list<string> CASEFIELDS = new list<string>{'HWS_FaultyUnitMaterialCode__c','HWS_Faulty_Serial_Number__c','HWS_Shippeddate__c','HWS_AWBNumber__c','HWS_LSP_Courier_Name__c' };  
	//Please add all child record types whenever new child case record type is created
	public static Set<ID> hwsRecordTypeIds = new Set<ID> {exchangeInDays,exchangeInHours,childCaseReadOnly,sPSCaseRType,returnForRepairCaseRType,spsReadOnly};
	
	/********************
	*Method Name: changeParentCaseStatus
	*Parameter: oldmap and new list of cases
	*Description:to update the parent case status to closed when all child cases are closed or cancelled.
	*******************/  
	public static void changeParentCaseStatus(Set<Id> newCaseIds){	  
			List<Case> parentCasesToUpdate = new List<Case>();
			set<Id> parentCaseIds = new set<Id>(); 
			List<Case> newCaseList = [SELECT id,RecordTypeId,Status,ParentId from Case where id IN:newCaseIds];
			for(Case caseRec : newCaseList){
				System.debug('Record type:'+caseRec.RecordTypeId+'Status of child case '+caseRec.Status);
				if(hwsRecordTypeIds.contains(caseRec.RecordTypeId) && (caseRec.Status=='Closed' || caseRec.Status=='Cancelled')){					  
					  parentCaseIds.add(caseRec.ParentId);					  
				  }
			}		   
			if(parentCaseIds.size() > 0){
				List<Case> toIdentifycasesToClose =[SELECT id ,status,HWS_CancelConfirm__c,
													(SELECT id,status FROM Cases WHERE status Not in:childCaseStatuses) 
													FROM case WHERE id in :parentCaseIds];				
				if(toIdentifycasesToClose.size() > 0)
				{
					for(case caserec : toIdentifycasesToClose){
						String parentStatus = 'Open';
						if(caserec.cases.size() == 0){
							parentStatus = 'Closed';
							
						}
						//Update Parent cases if changes exists
						if(caserec.status != parentStatus){
							caserec.status = parentStatus;
			  caserec.HWS_CancelConfirm__c = 'AllowCancellation';
							parentCasesToUpdate.add(caserec);
						}
					}
				}
			}		   
			if(parentCasesToUpdate.size() > 0 ){
				update parentCasesToUpdate ;
			}	  
		}
	
	/********************
  *Method Name: validationsOnCase
  *Parameter: New Case List (Only HWS Handling child Record Type Records)
  *Last updated by: TCS
  *Description: Method to validate HWS Faulty Serial Number field. If the case product related version item "Serial number traced field" is checked
  then we need to make "HWS Faulty Serial Number field" as Required, if its blank it should display error.
  *			   
  *******************/
  public static void validationsOnCase(List < Case > caseList) {
	Set<Id> caseVerItmIdSet = new Set<Id>();
	for(case caseRec: caseList) {
	   if((caseRec.RecordTypeId == exchangeInDays || caseRec.RecordTypeId == exchangeInHours || caseRec.RecordTypeId == returnForRepairCaseRType || caseRec.RecordTypeId == childCaseReadOnly) && caseRec.HWS_Stockable_Product__c <> null && caseRec.HWS_ServiceType__c!='Advanced Exchange in Hours'){
		caseVerItmIdSet.add(caseRec.HWS_Stockable_Product__c);
	  }
	}
	if(caseVerItmIdSet.size()>0){
	  Map<Id, Hws_Versionitem__C> verItmMap = new Map<Id, Hws_Versionitem__C>([SELECT HWS_Serial_Number_Traceable__c FROM Hws_Versionitem__c WHERE Id in : caseVerItmIdSet]);

	  for(case caseRec: caseList)  {
		if(caseRec.HWS_Stockable_Product__c != null && verItmMap.containskey(caseRec.HWS_Stockable_Product__c)){
		  Hws_Versionitem__C versionItem = verItmMap.get(caseRec.HWS_Stockable_Product__c);
		  if(versionItem.HWS_Serial_Number_Traceable__c != null && (versionItem.HWS_Serial_Number_Traceable__c.equalsIgnoreCase('YES') || versionItem.HWS_Serial_Number_Traceable__c.equalsIgnoreCase('Y')) && (caseRec.HWS_Faulty_Serial_Number__c == ''  || caseRec.HWS_Faulty_Serial_Number__c == null)){
			caseRec.HWS_Faulty_Serial_Number__c.addError('Please Enter Faulty Unit Serial Number ');
		  }					
		}
	  }
	} 
  }
	
	/********************
  *Method Name: duplicateSerialNumberCheck
  *Parameter: New Case List (Only HWS Handling child Record Type Records)
  *Last updated by: TCS
  *Description: Method to validate HWS Faulty Serial Number field and product Material code. If the Faulty Unity serial number and material code is part of an existing case pending for closure
  (Status not equals to Closed, cancelled,Delivered) then it should display error.
  *			   
  *******************/	
	public static void duplicateSerialNumberCheck(Map<Id,Case> oldCaseMap, List < Case > caseList) {	
	system.debug('duplicateSerialNumberCheck');
		Set<Id> caseProductId = new Set<Id>();
		String caseFaultyUSnum ;
		String errorMessage = System.Label.HWS_Duplicate_SNumber_ErrorMsg;
		set<String> prcodeset = new set<String>();
		if(caseList.size()> 0){
			for(case caseRec: caseList)  {
				if((caseRec.RecordTypeId== exchangeInDays || caseRec.RecordTypeId == exchangeInHours || caseRec.RecordTypeId == childCaseReadOnly
					|| caseRec.RecordTypeId == returnForRepairCaseRType) 
				   && (caseRec.Status !='Closed' || caseRec.Status !='Cancelled' || caseRec.Status !='Delivered') &&
				   (oldCaseMap == null ||  caseRec.HWS_Faulty_Serial_Number__c != oldCaseMap.get(caseRec.Id).HWS_Faulty_Serial_Number__c)  )
				{
					caseProductId.add(caseRec.HWS_Sellable_Product__c);
					caseFaultyUSnum =  caseRec.HWS_Faulty_Serial_Number__c ;
				}
			}
		}
		
		if(caseProductId <> null){
			list<product2> productsList = [select id,name, Productcode from product2 where ID IN :caseProductId AND HWS_DoNotConsider__c = false];
			if(productsList.size() > 0){
				for(Product2 prod:productsList){
					prcodeset.add(prod.ProductCode) ;
				}
				List<Case> cRecdup =[Select id,HWS_Faulty_Serial_Number__c,CaseNumber,Status From Case
									 where (status Not in:childCaseStatusesforDuplicte ) AND HWS_Sellable_Product__r.ProductCode In : prcodeset 
									 AND HWS_Faulty_Serial_Number__c =: caseFaultyUSnum AND HWS_Faulty_Serial_Number__c !=null];
				system.debug('cRecdup'+cRecdup);
				if(cRecdup.size() > 0){
					for(case caseRec: caseList)  {
						caseRec.HWS_Faulty_Serial_Number__c.addError(errorMessage +' :Case Number is '+cRecdup[0].CaseNumber);
					}
				}
			}
		}
	}
	
	/*********
  *Method Name: sendCaPMEmailAccOwner
  *Parameter: Old Case Map, New Case List
  *Events: BeforeUpdate,BeforeInsert
  *Description: Used to send an Email to Account owner if CaPM email is missing on service contract
  **********/
	public static void sendCaPMEmailAccOwner(Map<Id,Case> oldCaseMap,List<Case> newCaseList) {
	Set<Id> servContIdSet= new Set<Id>();
		Map<Id,ServiceContract> servContMap= new Map<Id,ServiceContract>();
		
		for(Case ce : newCaseList){servContIdSet.add(ce.NCP_Service_Contract__c);}
		
		for(ServiceContract sc: [select id,name,CH_CAPM_EmailAddress__c from ServiceContract where Id IN : servContIdSet]){servContMap.put(sc.Id,sc);}
		try{  
			for(Case cs : newCaseList){
				if(trigger.isUpdate){ 
					if(cs.Parentid <> null && (oldCaseMap.get(cs.Id).Status <> cs.Status && cs.Status == 'On Hold') && !servContMap.isEmpty()){
						cs.HWS_Capm_Email__c = servContMap.get(cs.NCP_Service_Contract__c).CH_CAPM_EmailAddress__c;
					}
				}
				if(trigger.isInsert){ 
					if(cs.Parentid <> null && cs.Status == 'On Hold' && !servContMap.isEmpty()){
						cs.HWS_Capm_Email__c = servContMap.get(cs.NCP_Service_Contract__c).CH_CAPM_EmailAddress__c;
					}
				}
			}
		}catch(Exception e){}	
	}
  
	/*********
  *Method Name: RMANumberPopulate
  *Last updated by: TCS
  *Parameter: New Case List
  *Events: BeforeInsert
  *Description: Used to populate the Parent Case number in RMA Number and Subject fields of related Child cases.
  RMA Number Format: <Parent CaseNumber-001>
  Subject Format: <RMA : Parent CaseNumber-001> 
  **********/   
	public static void RMANumberPopulate(Map<Id,Case> oldCaseMap, List<Case> newCaseList){		
		Map<String,List<Case>> mapChildCase = new Map<String,List<Case>>();
		Map<Id,String> caseMapNumber = new Map<Id,String>();
		Map<Id,Integer> childSize = new Map<Id, Integer>();
		Integer childCount = 1;
		if(newCaseList != null){
			Set<Id> parentIds = new Set<Id>();
			for(Case caserec : newCaseList) {
				parentIds.add(caserec.ParentId);
		List<Case> caseList = mapChildCase.get(caserec.ParentId);
				if(caseList == null){
					caseList = new List<Case>();
		}
				caseList.add(caserec);
				mapChildCase.put(caserec.ParentId,caseList);
			}
			List<Case> parentCase1=[Select id,CaseNumber,HWS_RMA_Number__c,Subject,(Select Id from Cases) from Case where id In: parentIds];
			
			if(parentcase1.size() > 0) {
				for(Case ce : parentCase1){
					caseMapNumber.put(ce.Id,ce.CaseNumber);
					childSize.put(ce.Id, ce.Cases.Size());
				}
			}
			for(Id parentid : parentIds){
				childCount = 1;
				for(Case ce : mapChildCase.get(parentid)){
					if((ce.ParentId) != null){
						if(ce.RecordTypeId==exchangeInHours || ce.RecordTypeId==exchangeInDays || ce.RecordTypeId == returnForRepairCaseRType){
							if(((childCount+(childSize.get(ce.ParentId)))<10)){
								ce.HWS_RMA_Number__c=caseMapNumber.get(ce.ParentId)+'-00'+(childCount+(childSize.get(ce.ParentId)));
							}
							else if(((childCount+(childSize.get(ce.ParentId)))>=10)&&((childCount+(childSize.get(ce.ParentId)))<100)){
								ce.HWS_RMA_Number__c=caseMapNumber.get(ce.ParentId)+'-0'+childCount;
							}
							else if((childCount+(childSize.get(ce.ParentId)))>=100){
								ce.HWS_RMA_Number__c=caseMapNumber.get(ce.ParentId)+'-'+childCount;
							}
							ce.Subject=('RMA'+' : '+ce.HWS_RMA_Number__c);
							
						}
						
						//Adding below Logic For SPS cases
						if((ce.RecordTypeId== sPSCaseRType)){
							
							if(((childCount+(childSize.get(ce.ParentId)))<10)){
								ce.HWS_SPS_Order_No__c =caseMapNumber.get(ce.ParentId)+'-00'+(childCount+(childSize.get(ce.ParentId)));
							}
							else if(((childCount+(childSize.get(ce.ParentId)))>=10)&&((childCount+(childSize.get(ce.ParentId)))<100)){
								ce.HWS_SPS_Order_No__c=caseMapNumber.get(ce.ParentId)+'-0'+childCount;
							}
							else if((childCount+(childSize.get(ce.ParentId)))>=100){
								ce.HWS_SPS_Order_No__c=caseMapNumber.get(ce.ParentId)+'-'+childCount;
							}
							if(ce.HWS_SPS_Order_No__c != null){
								ce.Subject=('SPS'+' : '+ce.HWS_SPS_Order_No__c);
							} 
						}
						childCount++;
					}
				}
			}
		}
	}
  
	/*********
  *Method Name: calculatingTotalShippedQuantity
  *Last updated by: TCS
  *Parameter: old Case Map, New Case Map
  *Events: Beforeupdate
  *Description: Used to Calculate Total Shipped Quantity.
  **********/	
	public static void calculatingTotalShippedQuantity(map<id, Case> oldCases, List <Case> newCaseList){		
	for(Case caseRec: newCaseList){
	  Case oldCaseRec = oldCases.get(caseRec.Id); 
	  if(caseRec.HWS_TotalShippedQuantity__c == null){
		caseRec.HWS_TotalShippedQuantity__c = 0;
		}
	  System.debug('Before calculatingTotalShippedQuantity:'+caseRec.HWS_TotalShippedQuantity__c);
	  if(caseRec.HWS_TotalShippedQuantity__c < caseRec.HWS_Quantity__c && caseRec.HWS_ShippedQuantity__c < caseRec.HWS_Quantity__c ){
		caseRec.HWS_TotalShippedQuantity__c = caseRec.HWS_TotalShippedQuantity__c + caseRec.HWS_ShippedQuantity__c;
		System.debug('After calculatingTotalShippedQuantity:'+caseRec.HWS_TotalShippedQuantity__c);
	  }
	}
  }
  
	/*********
  *Method Name: handleCaseFieldChanges
  *Last updated by: TCS
  *Parameter: old Case Map, New Case Map
  *Events: Beforeupdate
  *Description: Used to Track changes on HWS Case record Type Fields
  **********/   
	public static void handleCaseFieldChanges(map<id, Case> oldCases, List<Case> newCaseList ){	   
		if(!fieldTrackingChecked){ 
			list<CH_Track_Field_Change__c> trackedFields = new list<CH_Track_Field_Change__c>();
			Map<String,Schema.SObjectField> cfields = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
			
			for(Case aCase : newCaseList){
				for(string fieldName : CASEFIELDS){
					if(aCase.get(fieldName) != oldCases.get(aCase.Id).get(fieldName) && hwsRecordTypeIds.contains(aCase.RecordTypeId)){
						if(cfields.containsKey(fieldName)){
							Schema.DescribeFieldResult dfr = cfields.get(fieldName).getDescribe();
							System.debug('dfr:'+dfr);
							object newVal = aCase.get(fieldName);
							object oldVal = oldCases.get(aCase.Id).get(fieldName);
							if(aCase.HWS_ServiceType__c != 'Spare Part Sales'){
								if(dfr.getSOAPType() == Schema.SOAPType.STRING || dfr.getSOAPType() == Schema.SOAPType.ID || dfr.getSOAPType() == Schema.SOAPType.Boolean){
									if(dfr.getType() == Schema.DisplayType.TextArea){
										trackedFields.add(new CH_Track_Field_Change__c( name = dfr.getLabel(),
																					   Support_Ticket__c = aCase.Id,  
																					   CH_API_name_Field__c = fieldName,
																					   field_name__c = dfr.getLabel(),
																					   CH_New_value__c = (string)newVal,
																					   CH_Old_value__c = (string)oldVal)); 
									}else{
										trackedFields.add(new CH_Track_Field_Change__c( name = dfr.getLabel(),
																					   Support_Ticket__c = aCase.Id,  
																					   CH_API_name_Field__c = fieldName,
																					   field_name__c = dfr.getLabel(),
																					   Text_new__c = String.valueOf(newVal),
																					   text_old__c = String.valueOf(oldVal)));
									}
									
								}
							}
							else{
								if(dfr.getSOAPType() == Schema.SOAPType.STRING || dfr.getSOAPType() == Schema.SOAPType.ID || dfr.getSOAPType() == Schema.SOAPType.Boolean || dfr.getSOAPType() == Schema.SOAPType.Double || dfr.getSOAPType() == Schema.SOAPType.Long){
									if(dfr.getType() == Schema.DisplayType.TextArea){
										trackedFields.add(new CH_Track_Field_Change__c( name = dfr.getLabel(),
																					   Support_Ticket__c = aCase.Id,  
																					   CH_API_name_Field__c = fieldName,
																					   field_name__c = dfr.getLabel(),
																					   CH_New_value__c = (string)newVal,
																					   CH_Old_value__c = (string)oldVal)); 
									}else{
										trackedFields.add(new CH_Track_Field_Change__c( name = dfr.getLabel(),
																					   Support_Ticket__c = aCase.Id,  
																					   CH_API_name_Field__c = fieldName,
																					   field_name__c = dfr.getLabel(),
																					   Text_new__c = String.valueOf(newVal),
																					   text_old__c = String.valueOf(oldVal)));
									}
								}
								else if(dfr.getSOAPType() == Schema.SOAPType.DATETIME || dfr.getSOAPType() == Schema.SOAPType.DATE){ 
									trackedFields.add(new CH_Track_Field_Change__c( name = dfr.getLabel(),
																				   Support_Ticket__c = aCase.Id, 
																				   CH_API_name_Field__c = fieldName, 
																				   field_name__c = dfr.getLabel(),
																				   //CH_New_value__c = String.valueOf(newVal),
																				   //CH_Old_value__c = string.valueOf(oldVal), 
																				   Date_new__c = (Datetime)newVal,
																				   Date_old__c = (Datetime)oldVal)); 
								}
							}
						}
					}
				}
				object newTotalShippedQty = aCase.get('HWS_TotalShippedQuantity__c');
				object oldTotalShippedQty = oldCases.get(aCase.Id).get('HWS_TotalShippedQuantity__c');
				if(aCase.HWS_ServiceType__c == 'Spare Part Sales' && cfields.containsKey('HWS_ShippedQuantity__c') && oldTotalShippedQty!=newTotalShippedQty && newTotalShippedQty!=0 && newTotalShippedQty!=null){					
						Schema.DescribeFieldResult dfr = cfields.get('HWS_ShippedQuantity__c').getDescribe();
						System.debug('dfr:'+dfr); 
					  object newShippedQty = aCase.get('HWS_ShippedQuantity__c');
						object oldShippedQty = oldCases.get(aCase.Id).get('HWS_ShippedQuantity__c');
						if(dfr.getSOAPType() == Schema.SOAPType.Double || dfr.getSOAPType() == Schema.SOAPType.Long){
							trackedFields.add(new CH_Track_Field_Change__c( name = dfr.getLabel(),
																		   Support_Ticket__c = aCase.Id,  
																		   CH_API_name_Field__c = 'HWS_ShippedQuantity__c',
																		   field_name__c = dfr.getLabel(),
																		   Text_new__c = String.valueOf(newShippedQty),
																		   text_old__c = String.valueOf(oldShippedQty)));
						}
						
					}					 
			}
			system.debug('###CH_CustomFieldTracking:trackedFields:' + trackedFields);
			if(!trackedFields.isEmpty()) {
			 insert trackedFields;
			  }
			fieldTrackingChecked = true;
		}
	}
	
	/*********
  *Method Name: RecordTypeChange
  *Parameter: New Case List
  *Events: BeforeUpdate,BeforeInsert
  *Description: used to change child/parent case record types once child case status is ordered.
  **********/  
	/*
  public static void RecordTypeChange(List<Case> newCaseList){


  Id childsCaseReadOnlyRType = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_CHILD_CASE_READ_ONLY);
  Id parentCaseReadOnlyRType = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_PARENT_CASE_READ_ONLY);
  Id ParentCaseRecordType = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_Parent_Case);
  Map<ID, RecordType> recordTypeMap = New Map<ID, RecordType>([Select ID, Name From RecordType Where sObjectType = 'Case']);
  Integer isChanged=0;
  List<Case> parentCaseRecordTypeToUpdate = new List<Case>();
  set<Id> parentCaseIds = new set<Id>();

  for(Case caseRec : newCaseList){

  if((caseRec.RecordTypeId== exchangeInDays || caseRec.RecordTypeId == exchangeInHours || caseRec.RecordTypeId == childsCaseReadOnlyRType)
  && (caseRec.Status=='Ordered' )){
  parentCaseIds.add(caseRec.ParentId);
  caseRec.RecordTypeId = childsCaseReadOnlyRType;
  }
  }	  
  if(parentCaseIds <> null){
  List<Case> parentCasewithChilds =[SELECT id ,status,RecordTypeId,
  (SELECT id,status FROM Cases) 
  FROM case WHERE id in :parentCaseIds];

  system.debug('parentCasewithChilds::'+parentCasewithChilds);

  for(case caserec : parentCasewithChilds){
  // Case old = Trigger.oldMap.get(caserec.id);
  system.debug('parentCaseReadOnlyRType::'+parentCaseReadOnlyRType);
  if(parentCaseReadOnlyRType != null)
  //   if(recordTypeMap.get(leadNewRec.recordTypeID).name.containsIgnoreCase('TestLeadRecordType')){
  // RecordType  rec =  recordTypeMap.Name.containsIgnoreCase('HWS_Parent Case Not Editable Fields');
  if(trigger.oldmap.get(caseRec.RecordTypeId)!= trigger.newMap.get(caserec.RecordTypeId)){
  if(caserec.cases.size() > 0){
  caserec.RecordTypeId = parentCaseReadOnlyRType;

  }else{
  caserec.RecordTypeId = ParentCaseRecordType;
  }

  parentCaseRecordTypeToUpdate.add(caserec);
  }
  }
  }
  if(parentCaseRecordTypeToUpdate.size() > 0 ){
  update parentCaseRecordTypeToUpdate ;

  } 
  }*/
  
	/*********
  *Method Name: updateRetunDeliveryOnParent
  *Parameter: Case List
  *Events: AfterUpdate
  *Description: updates the retundelivery received flag on parent after receiving return delivery address for all the child cases.
  **********/
	public Static void updateRetunDeliveryOnParent(List<Case> caseList){	  
	Set<ID> parentIds = new Set<Id>();
		List<Case> parentCases = new List<Case>();
		Set<Case> parentsToBeUpdated = new Set<Case>();
		List<Case> updateParents = new List<Case>();
		for(Case cs: caseList){
			if(cs.RecordTypeId==exchangeInHours || cs.RecordTypeId==exchangeInDays || cs.RecordTypeId==childCaseReadOnly ){
				parentIds.add(cs.ParentId);
			}
		}
		parentCases=[SELECT Id,HWS_ReturnAddressReceivedFromSOO__c,
					 (SELECT Id,Status,HWS_Address_Name__c,City__c,State__c,Country__c,POSTAL_CODE_CHQ__c,HWS_Bar_Code__c,HWS_Bar_Code_Ref1__c
					  FROM Cases WHERE Status = 'Ordered')
					 FROM Case
					 WHERE Id IN: parentIds];
		if(parentCases.Size()>0){
			for(Case parent:parentCases){
				Boolean deliveryAddrSent=true;
				if(parent.Cases.Size()>0){
					for(Case child:parent.Cases){						
						if(child.HWS_Address_Name__c == null && child.City__c == null && child.State__c == null && child.Country__c == null && child.POSTAL_CODE_CHQ__c == null){
							deliveryAddrSent=false;
						}
			
			String parentBarcode = child.HWS_Bar_Code__c;
			String rmaBarcode = child.HWS_Bar_Code_Ref1__c;
			if(parentBarcode == null || rmaBarcode == null){
			  deliveryAddrSent=false;
			}
					}
					if(deliveryAddrSent){
						if(!parent.HWS_ReturnAddressReceivedFromSOO__c){
							parent.HWS_ReturnAddressReceivedFromSOO__c=True;
							parentsToBeUpdated.add(parent);
						}					   
					}
				}
				
			}
			if(parentsToBeUpdated.Size()>0){
				updateParents.addAll(parentsToBeUpdated);
				update updateParents;
			}
		}   
	}
	/*****************************************************************************************
  * Name : validationsOnCaseForDate
  * Description : Validation rule for the requested and planned delivery dates on case
  * Parameters: CaseList
  * Returns: Void
  *****************************************************************************************/
	public static void validationsOnCaseForDate(List<Case> caseList) {	   
	if(caseList.Size()>0){
			for(Case cas : caseList){
				if(cas.RecordTypeId== exchangeInDays || cas.RecordTypeId == exchangeInHours || cas.RecordTypeId == childCaseReadOnly
				   || cas.RecordTypeId ==sPSCaseRType || cas.RecordTypeId == returnForRepairCaseRType || cas.RecordTypeId == spsReadOnly){
					   if((cas.HWS_Planned_Delivery_Date__c != null) && (cas.HWS_Requested_Delivery_Date_Time__c != null)){
						   if(cas.HWS_Requested_Delivery_Date_Time__c < cas.HWS_Planned_Delivery_Date__c && (cas.HWS_ServiceType__c!='Identical Repair' && cas.HWS_ServiceType__c != 'Return for Repair or Replacement')){
							   system.debug('case record type is :'+cas.RecordTypeId +' and case service type is :'+ cas.HWS_ServiceType__c);
							   cas.HWS_Requested_Delivery_Date_Time__c.addError('Requested Delivery date should be greater than Planned Delivery date');
						   }
					   }	
				   }
			}
		}   
	}
  
	/********************
  *Method Name: Recalculating Planned delivery date
  *Parameter: New Case List , Old case map
  *Last updated by: TCS
  *Description: Method to validate HWS service type field . If the service type field is "Identical Repair" and Hws faulty unit receive date is changed 
  then  SLA needs to recalculate for the Identical repair Service type.
  *			   
  *******************/	
  public static void reCalculatePlannedDeliveryDate(Map <Id,Case> oldCaseMap,List<Case> caseList){	   
	Set<Id> countId=new Set<Id>();
		if(caseList.Size()>0){
			for(Case casCalculate: caseList){
				system.debug('Service Type value is :'+casCalculate.HWS_ServiceType__c);
				If((casCalculate.HWS_ServiceType__c=='Identical Repair' || casCalculate.HWS_ServiceType__c == 'Return for Repair or Replacement') && casCalculate.HWS_FaultyUnitReceivedDate__c!=oldCaseMap.get(casCalculate.Id).HWS_FaultyUnitReceivedDate__c)
				{
					countId.add(casCalculate.ID);
					
				}
			}
		}
		system.debug('Value of the count for planned delivery date:'+countId.size());
		if(countId.Size()>0 ){
			Map<ID,Case> caseLvale=new Map<ID,Case>([Select Id,HWS_Planned_Delivery_Date__c,HWS_FaultyUnitReceivedDate__c,Asset.HWS_ContractLineItem__r.CH_BusinessHour__c,Asset.HWS_ContractLeadTimeUnit__c,Asset.HWS_ContractLeadTimeDuration__c,Asset.HWS_SpecifiedDeliveryTargetTime__c from case where Id in :countId ]);
			for(Case casCalculate: caseList){ 
				system.debug('Case ID value is : '+casCalculate.id);
				if(caseLvale.get(casCalculate.id).Id == casCalculate.id && caseLvale.get(casCalculate.id).Asset.HWS_ContractLineItem__r.CH_BusinessHour__c != null ){
					system.debug('Business hour id : '+caseLvale.get(casCalculate.id).Asset.HWS_ContractLineItem__r.CH_BusinessHour__c);
					DateTime  dateUpdat=HWS_Utilty.plannedDeliveryDateTime(caseLvale.get(casCalculate.id).Asset.HWS_ContractLineItem__r.CH_BusinessHour__c,caseLvale.get(casCalculate.id).Asset.HWS_ContractLeadTimeUnit__c,caseLvale.get(casCalculate.id).Asset.HWS_ContractLeadTimeDuration__c,casCalculate.HWS_FaultyUnitReceivedDate__c,caseLvale.get(casCalculate.id).Asset.HWS_SpecifiedDeliveryTargetTime__c);
					system.debug('Date value in planned delivery date:'+dateUpdat);
					casCalculate.HWS_Planned_Delivery_Date__c=dateUpdat;
					
				}
			}
		}  
	}	
	
	/*****************************************************************************************
  * Name : entitlementNamePopulate
  * Description : enable milestone tracker on Child Case for RFR
  * Parameters: CaseList
  * Returns: Void
  *****************************************************************************************/
	public static void entitlementNamePopulate(List<Case> caseList) {	   
		List<Id> childCaseIdLst = new List<Id>();
		Set<Id> cliIdSet = new Set<Id>();
		Map<Id, Id> cliIdEntilmentIdMap = new Map<Id, Id>();
		List<Entitlement> entitlementLst;
		
		if(!caseList.isEmpty()){
			for(Case childCase : caseList){
				cliIdSet.add(childCase.HWS_Contract_Line_Item__c);
			}
		}
		system.debug('cliIdSet'+cliIdSet);
		if(!cliIdSet.isEmpty()){
			entitlementLst = [SELECT Id, Name, AssetId, ContractLineItemId 
							  FROM Entitlement 
							  WHERE ContractLineItemId IN :cliIdSet
							  AND ContractLineItem.NCP_External_Status__c = 'Active'];
		}
		system.debug('entitlementLst'+entitlementLst);
		if(!entitlementLst.isEmpty()){
			for(Entitlement ent : entitlementLst){
				cliIdEntilmentIdMap.put(ent.ContractLineItemId, ent.Id);
			}
		}
		for(Case cas : caseList){
			System.debug('childCases field Values: ' +cas.HWS_ServiceType__c +cas.HWS_FaultyUnitReceivedDate__c +cas.Status);
			if(((cas.HWS_ServiceType__c == 'Return for Repair or Replacement') || (cas.HWS_ServiceType__c == 'Identical Repair')) && (cas.HWS_FaultyUnitReceivedDate__c != null) && cas.Status == 'Ordered'){
				// system.debug('boss is back'+cliIdEntilmentIdMap.get(cas.HWS_Contract_Line_Item__c));
				cas.EntitlementId = cliIdEntilmentIdMap.get(cas.HWS_Contract_Line_Item__c);
			}
		}  
	}  
	/*****************************************************************************************
  * Name : completeMilestone
  * Description : Complete Milestone when case is closed
  * Parameters: CaseList
  * Returns: Void
  *****************************************************************************************/
	public static void completeMilestone(List<Case> caseList) {
		DateTime complDate = System.now(); 
		List<Id> caseIdLst = new List<Id>();
		if(caseList.Size()>0){
	  for(Case c : caseList){
		if ((c.SlaExitDate == null) && (c.SlaStartDate <= complDate)){
		  if((c.HWS_ServiceType__c == 'Advanced Exchange in Days' 
			|| c.HWS_ServiceType__c == 'Return for Repair or Replacement' 
			|| c.HWS_ServiceType__c == 'Identical Repair' 
			|| c.HWS_ServiceType__c == 'Spare Part Sales') && (c.HWS_Shippeddate__c != null)){
			  caseIdLst.add(c.Id);
		  } 
		  else if ((c.HWS_ServiceType__c == 'Advanced Exchange in Hours') && (c.HWS_ProofDeliveryDate__c != null)){
			caseIdLst.add(c.Id);
		  }
		}
	  }
	}
		if(!caseIdLst.isEmpty()){
			List<CaseMilestone> cmsToUpdate = [SELECT Id, CompletionDate FROM CaseMilestone WHERE caseId in :caseIdLst AND MilestoneType.Name = 'HWS Milestone Tracker' AND completionDate = null limit 1];
			if (!cmsToUpdate.isEmpty()){
				for (CaseMilestone cm : cmsToUpdate){
					cm.completionDate = complDate;
				}
				try{
					update cmsToUpdate;
				}catch(System.DmlException de){
					System.debug('Cannot Update Case ' +de.getMessage() +de.getStackTraceString());
				}
			}
		}	
	}
  /*****************************************************************************************
	* Name : updateMilestoneChecbox
	* Description : Update HWS_StartMilestone__c to true from batch class for RFR & IR records when we received HWS_FaultyUnitReceivedDate__c 
	* Parameters: CaseList
	* Returns: Satya
	* Milestone CPU Time Limit Fix
	*****************************************************************************************/
	public static void updateMilestoneChecbox(List<Case> caseList) {
		
		List<Id> parentCaseIdSet = new List<Id>();
		List<Id> parentCaseIdLst = new List<Id>();
		for(Case c :caseList){
			if(c.ParentId != null && c.HWS_FaultyUnitReceivedDate__c != null && c.HWS_StartMilestone__c != true && (c.HWS_ServiceType__c =='Return for Repair or Replacement' || c.HWS_ServiceType__c =='Identical Repair')){
				parentCaseIdSet.add(c.ParentId);
			}
			 if(c.ParentId != null && c.Status == 'Ordered' && c.HWS_StartMilestone__c != true && (c.HWS_ServiceType__c == 'Advanced Exchange in Days'|| c.HWS_ServiceType__c =='Advanced Exchange in Hours' || c.HWS_ServiceType__c =='Spare Part Sales')){
				parentCaseIdSet.add(c.ParentId);
			 }
		}
		if(parentCaseIdSet.size()>0){
			parentCaseIdLst.addAll(parentCaseIdSet);
			Id batchJobId = Database.executeBatch(new HWS_StartMilestoneCalculationBatch (parentCaseIdLst), 50);
		}
	}
  /*****************************************************************************************
	* Name : totalNetValueCalculateOnChild
	* Description : Calculate Total Net Value for SPS Child Cases
	* Parameters: CaseList
	* Returns: Bharathi N	
	*****************************************************************************************/
  public static void totalNetValueCalculateOnChild(List<Case> newCaseList){ 
		Set<Id> assetIdSet = new Set<Id>();
		Integer childCount = 1;		
		Decimal i = 0;
		if(newCaseList != null){
			for(Case caserec : newCaseList) {
				if(caserec.RecordTypeId == sPSCaseRType || caserec.RecordTypeId == spsReadOnly){
					if(caserec.AssetId != null){
						assetIdSet.add(caserec.AssetId);					
					}	 
				}
			}  
			if(!assetIdSet.isEmpty()){
				//Map<Id,String> assetIdPriceMap = new Map<Id,String>();
				Map<Id,Asset> assetIdPriceMap = new Map<Id,Asset>([Select Id,HWS_Price__c from Asset where Id IN:assetIdSet]);
				for(Case cas : newCaseList){
					if(assetIdPriceMap.containsKey(cas.AssetId)){
					   String price;
			if(assetIdPriceMap.get(cas.AssetId).HWS_Price__c != null && assetIdPriceMap.get(cas.AssetId).HWS_Price__c != ''){
			  price = assetIdPriceMap.get(cas.AssetId).HWS_Price__c;
			  
			  i = Decimal.valueof(price) * cas.HWS_Quantity__c; // Modified the logic to accept Decimal values for defect# 4342
			  cas.HWS_Net_Quantity__c = String.valueOf(i);
			}
					}
				}
			}
			
		}
	}
  /*****************************************************************************************
	* Name : totalNetValueCalculateOnParent
	* Description : Calculate Total Net Value for SPS Parent Case
	* Parameters: CaseList
	* Returns: Bharathi N	
	*****************************************************************************************/
	public static void totalNetValueCalculateOnParent(List<Case> caseList){ 
		Set<Id> parentCaseIdSet = new Set<Id>();
		List<Case> caseListToUpdate = new List<Case>();
		for(Case c : caseList){
			if(c.RecordTypeId == sPSCaseRType || c.RecordTypeId == spsReadOnly){
				if(c.ParentId != null){
					parentCaseIdSet.add(c.ParentId);
				}
			}
		}
		if(!parentCaseIdSet.isEmpty()){
			List<Case> parentCaseList =[Select Id,HWS_Net_Quantity__c,(Select Id,HWS_Net_Quantity__c from Cases) from Case where Id IN:parentCaseIdSet];			
			for(Case cas : parentCaseList){
				Decimal s = 0;// Modified the logic to accept Decimal values for defect# 4342
				System.debug('Child Net Value:'+cas.HWS_Net_Quantity__c);			   
		if(cas.Cases.size() > 0){
		  for(Case c:cas.Cases){
			if(c.HWS_Net_Quantity__c != null){
			  s = s+Decimal.valueOf(c.HWS_Net_Quantity__c);// Modified the logic to accept Decimal values for defect# 4342
			}
		  }		  
		}
				cas.HWS_Net_Quantity__c = String.valueOf(s);
				caseListToUpdate.add(cas);
			}
		}
		update caseListToUpdate;
	}
}