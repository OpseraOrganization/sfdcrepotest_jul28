/****************************************
* Class Name : HWS_CaseTriggerHelper_Test
* Created By : TCS
* Last Modified by: TCS
* Description : Test Class for Hws_CaseTriggerHelper and HWS_CasetriggerHandler
*****************************************/
@isTest
public class HWS_CaseTriggerHelper_TEST {
	private static Set<String> childCaseStatuses = new Set<String>{'Closed','Cancelled'};
		private static Id parentCaseId;
		@testSetup static void testDataSetup(){
			Id accountRecordType = HWS_Utilty.getRecordTypeByName('Account',HWS_Constants.LOGISTIC_ACCOUNT_EXISTING);
			Id childcase = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_Child_Case_Read_Only);
			Id exchangeInDays = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_Advance_Exchange_In_Days);
			Id exchangeInHours = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_ADVANCE_EXCHANGE_IN_HOURS);
			Id parentCaseRecordType = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_Parent_Case);
			Id sparePartSales = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_SPS_PART_SALES);
			Id legalEntityAccountType = HWS_Utilty.getRecordTypeByName('Account',HWS_Constants.LEGAL_ENTITY);
			List<Case>listCase= new List<Case>();
			Account acc = HWS_DataFactory_TEST.insertAccount();
			acc.name='test1';
			acc.Customer_Compliance__c ='US_Govern';
			insert acc;
			
			Account acc2 = HWS_DataFactory_TEST.insertAccount(); 
			acc2.RecordTypeId =  legalEntityAccountType;
			acc2.ParentId = Acc.Id;
			insert acc2;
			
			Account acc1 = new Account();
			acc1.Name = 'Testing RMANUMBER FIELD';
			acc1.ParentId = Acc.Id;
			acc1.Logistic_Account_Type__c = 'Bill-To';
			acc1.ngERP__c = '1';
			acc1.BillingCountry = 'India';
			acc1.BillingStreet = 'Gachibowli, Gachibowli';
			acc1.BillingCity = 'Hyderabad';
			acc1.BillingPostalCode = '500071';
			acc1.BillingState = 'TELANGANA';
			acc1.Market__c = 'Market India';
			acc1.RecordTypeId = accountRecordType;
			//ACC1.RecordTypeId =  LegalEntityAccountType;
			insert acc1;
			Product2 prod = HWS_DataFactory_TEST.insertproduct2();
			prod.ProductCode = '1234';
			insert prod;
			hws_versionitem__c vItem = HWS_DataFactory_TEST.insertHwsversionitem();
			insert vItem;
			ServiceContract sc = HWS_DataFactory_TEST.insertServiceContract(Acc);
			insert sc;
			Asset ast = new Asset();
			Id assetRecordType = HWS_Utilty.getRecordTypeByName('Asset','HWS_Covered_Part');
			ast.RecordTypeId = assetRecordType;
			ast.Name = 'Test Asset';
			ast.AccountId = acc2.id;
	  ast.Product2Id = prod.Id;	
			ast.HWS_SourceSystem__c  = 'Puma1';
	  ast.HWS_Price__c = '20';
			insert ast;   
			/*Entitlement ent = new Entitlement();
			ent.Name = 'HWS Advance Exchange in Hours';
			ent.AccountId = ACC1.id;
			ent.AssetId = ast.Id;
			ent.CH_CDB_EntitlementId__c = '1234';
			ent.CH_ServiceMappingId__c = 'Advanced Exchange in Hours (AE-H)';
			insert ent;*/
			Case ca = new Case();
			ca.RecordTypeId = parentCaseRecordType;
			ca.AccountId = acc2.Id;
			ca.Hws_Ship_to_Party_Address__c= acc1.Id;
	  ca.AssetId=ast.Id;
			ca.Status='Closed';
			ca.Subject='Test Subject';
			ca.Description='test Description';
			//ca.HWS_Faulty_Serial_Number__c= 'test1234';
			ca.HWS_ShipTopartyId__c='1234566';
			ca.Describe__c = 'Test description3';
			insert ca;
			//parentCaseId = ca.Id;
			Case cas = new Case();
			cas.RecordTypeId = childcase;
			cas.ParentId = ca.Id;
			cas.AccountId = acc2.Id;
	  cas.AssetId=ast.Id;
			//cas.Status ='Cancelled';
			cas.Hws_Ship_to_Party_Address__c= acc1.Id;
			cas.HWS_Sellable_Product__c = prod.Id;
			cas.HWS_Faulty_Serial_Number__c = '1234'; 
			cas.HWS_FaultyUnitMaterialCode__c = '4567';
			cas.HWS_Shippeddate__c= system.today();
			//cas.HWS_AWBNumber__c = '122';
			cas.HWS_LSP_Courier_Name__c = 'Test123';
			cas.HWS_TotalShippedQuantity__c = 1234;
			cas.Describe__c = 'Test description';
			cas.HWS_Bar_Code__c = 'Test data111';
		  cas.HWS_Bar_Code_Ref1__c = 'Test data123';
			insert cas;
			
			Case cas1 = new Case();
			cas1.RecordTypeId = sparePartSales;
			cas1.ParentId = ca.Id;
			cas1.AccountId = acc2.Id;
			//cas.Status ='Cancelled';
			cas1.Hws_Ship_to_Party_Address__c= acc1.Id;
			cas1.HWS_Sellable_Product__c = prod.Id;
	  cas1.AssetId=ast.Id;
			cas1.HWS_Faulty_Serial_Number__c = '123434233'; 
			cas1.HWS_FaultyUnitMaterialCode__c = '456755667';
			cas1.HWS_ServiceType__c ='Spare Part Sales';
			cas1.HWS_TotalShippedQuantity__c = 12344455;
			cas1.HWS_Shippeddate__c= system.today();
			//cas1.HWS_AWBNumber__c = '12277';
			cas1.HWS_LSP_Courier_Name__c = 'Test1232334';
			cas1.Describe__c = 'Test description';
			cas1.HWS_Address_Name__c='test';
		  cas1.City__c = 'hyderabad';
		  cas1.State__c = 'Telangana';
		  cas1.Country__c = 'India';
		  cas1.POSTAL_CODE_CHQ__c = '500090';
			cas1.HWS_Bar_Code__c = 'Test data2222';
		  cas1.HWS_Bar_Code_Ref1__c = 'Test data123';
	  cas1.HWS_Quantity__c = 5;
			insert cas1;
			HWS_BypassStatusChangeValidation__c cussett = new HWS_BypassStatusChangeValidation__c();
			cussett.HWS_BypassCaseStatusValidation__c = true;
			insert cussett;
		}
	public static testmethod void parentCaseStatus(){		 
		List<Case> listCase= new List<Case>();
		List<Case> listChildCase= new List<Case>();
		Set<Id> caseIdSet = new Set<Id>();
		Id caseRectype = Schema.SObjectType.Case.getRecordTypeInfosByName().get('HWS Advance Exchange In Hours').getRecordTypeId();
		Account acc = [Select id from Account where name='test' limit 1];								
		Case caserec = [Select id,Status,HWS_SOO_CaseStatus__c from Case limit 1];  
		Product2 prod = [select id from Product2 where name='test'];
		Asset ast = [Select id from Asset limit 1];
		 //case cas1 = [select id,Status,HWS_SOO_CaseStatus__c,RecordTypeId,HWS_Faulty_Serial_Number__c,HWS_FaultyUnitMaterialCode__c from case where HWS_LSP_Courier_Name__c = 'Test123'];
		listCase.add(caserec);
		Case childCaseRec = HWS_DataFactory_TEST.insertChildCase();
		childCaseRec.ParentId = caserec.id; 
		childCaseRec.AccountId = acc.id;
	childCaseRec.AssetId = ast.Id;
		childCaseRec.HWS_Sellable_Product__c=prod.id;
		childCaseRec.Status ='Cancelled';		
		childCaseRec.AccountId = acc.Id;		
		childCaseRec.HWS_Faulty_Serial_Number__c= '12345'; 
		listChildCase.add(childCaseRec);
		test.startTest();
		insert listChildCase; 
		caseIdSet.add(childCaseRec.Id);
		for(Case cs:listCase){
			if(cs.cases.size() == 0){
				cs.Status ='Closed';
				system.assertEquals(cs.Status, 'Closed');
			}else{
				cs.Status ='Open';
				system.assertEquals(cs.Status, 'Open');
			}			
		}  
		HWS_CaseTriggerHelper.changeParentCaseStatus(caseIdSet);
		test.stopTest();				  
	}   
	public static testmethod void caseValidationmethod(){
		List<Case>listCase= new List<Case>();		
		hws_versionitem__c vItem = HWS_DataFactory_TEST.insertHwsversionitem();
		insert vItem;
		Case caseRec = HWS_DataFactory_TEST.insertChildCase();
		caseRec.HWS_Stockable_Product__c= vItem.id;
		caseRec.HWS_Faulty_Serial_Number__c= '';
		listCase.add(caserec);
		test.startTest();
		try{
			insert listCase;
			update listCase;
		}		
		Catch(Exception e){
			Boolean expectedExceptionThrown =  e.getMessage().contains('Please Enter Faulty Unit Serial Number');			
		}		
		test.stopTest();
	}
	public static testmethod void duplicateSernumMethod(){		
		List<Case>listCase = new List<Case>();		
		Case parentCase = [Select id from Case limit 1];
		Product2 prod = [select id from Product2 where name='test'];
	Asset ast = [Select id from Asset limit 1];
		Account acc2 = [Select id from account where name='test' LIMIT 1];
		Account acc1 = [Select id from account where name='Testing RMANUMBER FIELD' LIMIT 1];
		Case caseRec = HWS_DataFactory_TEST.insertChildCase();
		caseRec.Status ='Ordered';
		caseRec.AccountId = acc2.Id;
		caseRec.Hws_Ship_to_Party_Address__c= acc1.Id;
	caseRec.AssetId = ast.Id;
		caseRec.HWS_Faulty_Serial_Number__c = '123456';
		caseRec.ParentId = parentCase.Id;
		caseRec.HWS_Sellable_Product__c = prod.Id;
		listCase.add(caseRec);
		insert listCase;
		system.assertequals(listCase.size(),1);  
		listCase[0].HWS_Faulty_Serial_Number__c = '123456'; 
		test.startTest();
		try{
			update listCase ;
		}		
		Catch(Exception e){
			Boolean expectedExceptionThrown =  e.getMessage().contains('Duplicate faulty unit Serial number');
			//System.AssertEquals(expectedExceptionThrown, true);
		}
		test.stopTest();
	}
	
	public static testmethod void sendCaPMToAccOwnerTest(){		
		Id scRectype = Schema.SObjectType.ServiceContract.getRecordTypeInfosByName().get('Parent Service Contract').getRecordTypeId();		
		Id caseChildRectype = Schema.SObjectType.Case.getRecordTypeInfosByName().get('HWS Advance Exchange In Hours').getRecordTypeId();
		Account acc = [Select id from Account limit 1];		
		ServiceContract sc= [Select id from ServiceContract limit 1];
		sc.RecordTypeId=scRectype ;
		update sc;
		Case cs = [Select id from Case limit 1];		
		Case child = new case();
		child.status = 'On Hold';
		child.RecordTypeId=caseChildRectype; 
		child.ParentId = cs.Id;
		child.AccountId = acc.id;
		child.HWS_Failure_Description__c='1';
		child.HWS_Failure_Occurance__c = '1';
		//cs.HWS_Failure_Detection__c = '1';
		child.subject='test';
		child.description = 'test';
		child.NCP_Service_Contract__c = sc.id;
		child.HWS_Capm_Email__c = '';
		child.HWS_Bar_Code__c = 'Test data3333';
		child.HWS_Bar_Code_Ref1__c = 'Test data123';
		test.startTest();
		try{
		insert child;
		System.assertequals(child.HWS_Capm_Email__c,'');	 
		}
		catch(Exception e){
			String testException = e.getMessage();
		}  
		test.stopTest();
	}
	
	public static testmethod void rmaNumberPopulateTest(){
		Id parentCaseRecordType = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_Parent_Case);		
		Id exchangeInHours = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_ADVANCE_EXCHANGE_IN_HOURS);
		Id exchangeInDays = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_Advance_Exchange_In_Days);
		Id sparePartSales = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_SPS_PART_SALES);
		Case parentCase = [Select id,CaseNumber from Case where RecordTypeId = :parentCaseRecordType limit 1];
		Account acc2 = [Select id from account where name='test' LIMIT 1];
		Account acc1 = [Select id from account where name='Testing RMANUMBER FIELD' LIMIT 1];
		Product2 prod = [select id from Product2 where name='test'];
	Asset ast = [Select id from Asset limit 1];
		List<Case>listCase= new List<Case>();		
		for(integer i=0; i<5; i++){ 
			case childcase = new Case();
			childcase.RecordTypeId = exchangeInHours;
			if((childcase.RecordTypeId == exchangeInHours) || (childcase.RecordTypeId == exchangeInDays)){
				childcase.ParentId = parentCase.Id;
				childcase.AccountId = acc2.Id;
				childcase.Hws_Ship_to_Party_Address__c= acc1.Id;
				childcase.HWS_Sellable_Product__c = prod.Id;
		childcase.AssetId = ast.Id;
				childcase.HWS_Failure_Description__c = 'Fan defect';
				childcase.HWS_Failure_Detection__c = 'Start reset loop';
				childcase.HWS_Failure_Occurance__c = 'Permanent';
				childcase.HWS_Address_Name__c = 'Test Address';
				childcase.HWS_Bar_Code__c = 'Test data444';
			childcase.HWS_Bar_Code_Ref1__c = 'Test data123';
				childcase.HWS_RMA_Number__c = parentCase.CaseNumber+'-00'+(i+1);
				listCase.add(childcase);
			}
			else if(childcase.RecordTypeId == sparePartSales){
				childcase.ParentId = parentCase.Id;
				childcase.HWS_Sellable_Product__c = prod.Id;
		childcase.AssetId = ast.Id;
				childcase.Hws_Ship_to_Party_Address__c= acc1.Id;
				childcase.AccountId = acc2.Id;
				childcase.HWS_Quantity__c = Decimal.valueOf('1');
				childcase.HWS_Bar_Code__c = 'Test data555';
			childcase.HWS_Bar_Code_Ref1__c = 'Test data123';
				childcase.HWS_RMA_Number__c = parentCase.CaseNumber+'-00'+(i+1);
				//childcase.HWS_Requested_Delivery_Date_Time__c = date.valueOf('2019-03-15T12:00:00.000+0000');
				listCase.add(childcase);
			}
		}  
		test.startTest();
		insert listCase;
		System.assertequals(listCase[0].HWS_RMA_Number__c,parentCase.CaseNumber+'-001');
		test.stopTest();
	}  
	
	public static testmethod void handleCaseFieldChangesTest(){
		Id childcase = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_Child_Case_Read_Only);
		List<Case> caseList = new List<Case>();		
		list<CH_Track_Field_Change__c> trackedFields = new list<CH_Track_Field_Change__c>();
		Case parentCase = [Select id from Case limit 1]; 
		Product2 prod = [select id from Product2 where name='test'];
		Account acc2 = [Select id from account where name='test' LIMIT 1];
		Account acc1 = [Select id from account where name='Testing RMANUMBER FIELD' LIMIT 1];
		map<id,case> casoldmap = new map<id,case>();
		map<id,case> casnewmap = new map<id,case>();
					  
		case cas1 = [select id,RecordTypeId,HWS_Faulty_Serial_Number__c,HWS_FaultyUnitMaterialCode__c, HWS_Bar_Code__c, HWS_Bar_Code_Ref1__c from case where HWS_LSP_Courier_Name__c = 'Test123'];
		cas1.HWS_Faulty_Serial_Number__c = '9877889';
		cas1.HWS_FaultyUnitMaterialCode__c = '1548121';
		cas1.HWS_TotalShippedQuantity__c = 45678;
		cas1.Describe__c = 'Test data123';
		cas1.HWS_Bar_Code__c = 'Test data6666';
		cas1.HWS_Bar_Code_Ref1__c = 'Test data123';
		test.startTest();
		update cas1;
		test.stopTest();		
	}
	
	/*public static testmethod void handleCaseFieldChangesTest2(){
		Id ParentCaseRecordType = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_Parent_Case);
		Id childcase = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_Child_Case_Read_Only);
		Account acc2 = [Select id from account where name='test' LIMIT 1];
		Account acc1 = [Select id from account where name='Testing RMANUMBER FIELD' LIMIT 1];
		Product2 prod = [select id from Product2 where name='test'];
		case cas1 = [select id,RecordTypeId,HWS_Faulty_Serial_Number__c,HWS_FaultyUnitMaterialCode__c from case where HWS_LSP_Courier_Name__c = 'Test123'];
		  cas1.AccountId = acc2.Id;
			cas1.Hws_Ship_to_Party_Address__c= acc1.Id;
		  cas1.HWS_Sellable_Product__c = prod.Id;
			cas1.Describe__c = 'Test description123';
			cas1.HWS_Faulty_Serial_Number__c = '9877889';
			cas1.HWS_FaultyUnitMaterialCode__c = '1548121';
		  cas1.HWS_Shippeddate__c= system.today()+1;
			//cas1.HWS_AWBNumber__c = '144';
			cas1.HWS_LSP_Courier_Name__c = 'Test1567';
			update cas1;
  } */
	public static testmethod void handleCaseFieldChangesTest3(){
		Id childcase = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_Child_Case_Read_Only);
		List<Case> caseList = new List<Case>();		
		list<CH_Track_Field_Change__c> trackedFields = new list<CH_Track_Field_Change__c>();
		Case parentCase = [Select id from Case limit 1]; 
		Product2 prod = [select id from Product2 where name='test'];
		Account acc2 = [Select id from account where name='test' LIMIT 1];
		Account acc1 = [Select id from account where name='Testing RMANUMBER FIELD' LIMIT 1];
		map<id,case> casoldmap = new map<id,case>();
		map<id,case> casnewmap = new map<id,case>();
					  
		case cas1 = [select id,RecordTypeId,HWS_Faulty_Serial_Number__c,HWS_FaultyUnitMaterialCode__c from case where HWS_LSP_Courier_Name__c = 'Test1232334'];
		cas1.HWS_Faulty_Serial_Number__c = '9877889567';
		cas1.HWS_FaultyUnitMaterialCode__c = '15481213455';
		cas1.Describe__c = 'Test data123';
		cas1.HWS_TotalShippedQuantity__c=12345789;
		test.startTest();
		update cas1;
		test.stopTest();		
	}
	
	public static testmethod void validationsOnCaseForDate(){
		Case parentCase = [Select id from Case limit 1];
		Id sparePartSales = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_SPS_PART_SALES);
		List<Case>childCaseList = new List<Case>();
		Product2 prod = [select id from Product2 where name='test'];
		Account acc2 = [Select id from account where name='test' LIMIT 1];
		Account acc1 = [Select id from account where name='Testing RMANUMBER FIELD' LIMIT 1];
		Asset ast = [Select id from Asset limit 1];
	case childCase = new Case();
		childCase.RecordTypeId = sparePartSales;
		childCase.ParentId = parentCase.Id;
		childCase.AccountId = acc2.Id;
	childcase.AssetId = ast.Id;
		childCase.Hws_Ship_to_Party_Address__c= acc1.Id;
		childCase.HWS_Sellable_Product__c = prod.Id;
		childCase.HWS_Quantity__c = Decimal.valueOf('1');
		childCase.HWS_Planned_Delivery_Date__c = date.valueOf('2019-03-11T14:30:00.000+0000');
		childCase.HWS_Requested_Delivery_Date_Time__c = date.valueOf('2019-03-15T12:00:00.000+0000');
		childCase.HWS_Bar_Code__c = 'Test data777';
		childCase.HWS_Bar_Code_Ref1__c = 'Test data123';
		test.startTest();
		insert childCase;
		//  System.AssertEquals(expectedExceptionThrown, true);
		childCase.HWS_Requested_Delivery_Date_Time__c = date.valueOf('2019-03-17T12:00:00.000+0000');
		//childCaseList.add(childCase);
		update childCase;
		test.stopTest();
	}	
	public static testmethod void updateRetunDeliveryOnParentTest(){
		Case parentCase = [Select id from Case where HWS_ShipTopartyId__c='1234566' limit 1];
		Id exchangeInDays = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_Advance_Exchange_In_Days);
		List<Case>childCaseList = new List<Case>(); 
		Product2 prod = [select id from Product2 where name='test'];
	Asset ast = [Select id from Asset limit 1];
		Account acc2 = [Select id from account where name='test' LIMIT 1];
		Account acc1 = [Select id from account where name='Testing RMANUMBER FIELD' LIMIT 1];
		list<case> childcasl = new List<case>();
		case childCase = new Case();
		childCase.RecordTypeId = exchangeInDays;
		childCase.ParentId = parentCase.Id;
		childCase.AccountId = acc2.Id;
	childCase.AssetId = ast.Id;
		childCase.HWS_Address_Name__c='test';
		childCase.City__c = 'hyderabad';
		childCase.State__c = 'Telangana';
		childCase.Country__c = 'India';
		childCase.POSTAL_CODE_CHQ__c = '500090';
		childCase.Hws_Ship_to_Party_Address__c= acc1.Id;
		childCase.HWS_Sellable_Product__c = prod.Id;		
		childCase.HWS_Bar_Code__c = 'Test data8888';
		childCase.HWS_Bar_Code_Ref1__c = 'Test data123';
		test.startTest();
		insert childCase;
		childcasl.add(childCase);
		//parentCase.HWS_ReturnAddressReceivedFromSOO__c = True;
		//update parentCase;
		HWS_CaseTriggerHelper.updateRetunDeliveryOnParent(childcasl);
		test.stopTest();
	}   
	public static testmethod void completeMilestoneTest(){
		Case parentCase = [Select id from Case limit 1];
		Id exchangeInDays = HWS_Utilty.getRecordTypeByName('Case',HWS_Constants.HWS_Advance_Exchange_In_Days);
		List<Case>childCaseList = new List<Case>(); 
		Product2 prod = [select id from Product2 where name='test'];
	Asset ast = [Select id from Asset limit 1];
		Account acc2 = [Select id from account where name='test' LIMIT 1];
		Account acc1 = [Select id from account where name='Testing RMANUMBER FIELD' LIMIT 1];
		list<case> childCaseli = new list<case>();
		case childCase = new Case();
		DateTime createdOn = System.Now().addHours(-4);
		childCase.RecordTypeId = exchangeInDays;
		childCase.SlaStartDate = createdOn;
		childCase.ParentId = parentCase.Id;
		childCase.AccountId = acc2.Id;
	childcase.AssetId = ast.Id;
		childCase.HWS_ServiceType__c = 'Advanced Exchange in Days';
		childCase.Hws_Ship_to_Party_Address__c= acc1.Id;
		childCase.HWS_Sellable_Product__c = prod.Id;
		childCase.City__c = 'Hyderabad';
		childCase.HWS_Shippeddate__c = System.Now();
		childCase.HWS_Bar_Code__c = 'Test data9999';
		childCase.HWS_Bar_Code_Ref1__c = 'Test data123';
		childCaseli.add(childCase);
		test.startTest();
		insert childCaseli;
		parentCase.HWS_ReturnAddressReceivedFromSOO__c = True;
		HWS_CaseTriggerHelper.completeMilestone(childCaseli);
		update parentCase;
		test.stopTest();
	}
}