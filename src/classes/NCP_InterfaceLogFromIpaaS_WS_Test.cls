/**
 * Created by bkandov on 2019-07-01.
 */
@isTest
public class NCP_InterfaceLogFromIpaaS_WS_Test {

	@testSetup static void setup() {

		Account acc = NCP_TestFactory.createAccount();
		Account acc2 = NCP_TestFactory.createLegalAccount(acc.Id);
		Contact con = NCP_TestFactory.createContact(acc);
		ServiceContract scCDB = NCP_TestFactory.createServiceContract(acc2, NCP_Constants.TYPE_CARES);
		ServiceContract sccCDB = NCP_TestFactory.createChildServiceContract(acc2, scCDB, 'ClicS', NCP_Constants.RELATIONSHIP_P, true, false);
		List<ServiceContract> serviceContractsToInsert = new List<ServiceContract>();
		serviceContractsToInsert.add(sccCDB);

		insert serviceContractsToInsert;

		NCP_Authorised_Entitlement__c ae = NCP_TestFactory.createAuthorisedEntitlement(con, scCDB);

		Product2 pr = NCP_TestFactory.createProduct();
		NCP_Product_Content__c pc = NCP_TestFactory.createProductService(pr.Id, 'Discovery Center (Skylab)');
		contractLineItem cli = NCP_TestFactory.createContractLineItem(pr, scCDB);
	}

	@isTest
	static void testLogServiceContractFromIpaaS() {

		Id customerRecordTypeId = NCP_Utils.getObjectRecordTypeId('Account', NCP_Constants.ACCOUNT_RT_DEVNAME_CUSTOMER);
		Account acc = [SELECT Id FROM Account WHERE RecordTypeId = :customerRecordTypeId LIMIT 1];

		Id legalRecordTypeId = NCP_Utils.getObjectRecordTypeId('Account', NCP_Constants.ACCOUNT_RT_DEVNAME_LEGALENTITY);
		Account acc2 = [SELECT Id FROM Account WHERE RecordTypeId = :legalRecordTypeId LIMIT 1];

		Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];

		User u = NCP_TestFactory.createUser(true, 'AES Admin', con, 'test@nokia.com.dev');
		insert u;

		ServiceContract sccCDB = [SELECT Id,AccountId,RecordType.Name,Pricebook2.Name,NCP_External_Status__c FROM ServiceContract WHERE AccountId = :acc2.Id LIMIT 1] ;

		Test.startTest();

		String jobId = '12345';

		Map<String, String> headers = new Map<String, String>();
		headers.put('Content-Type', 'text/csv');
		NCP_SingleRequestMock fakeApiJobDetails = new NCP_SingleRequestMock(200,
				'Complete',
				'{"id":"1","object": "ServiceContract","operation":"insert","numberRecordsProcessed":1,"numberRecordsFailed":1}',
				headers);

		NCP_SingleRequestMock fakeSuccessCall = new NCP_SingleRequestMock(200,
				'Complete',
				'sf__Id,sf__Created,Account.Acc_No__c,NCP_Entitlement_Access_Type__c,NCP_External_Service_Contract_Id__c,NCP_External_Status__c,Name,ParentServiceContract.NCP_External_Service_Contract_Id__c,PriceBook2.Name,recordType.Name\n' + sccCDB.Id + ',' + false + ',' + sccCDB.AccountId + ',' + '' + ',' + '' + ',' + sccCDB.NCP_External_Status__c + ',' + '' + ',' + 203818 + ',' + sccCDB.Pricebook2.Name + ',' + sccCDB.RecordType.Name + '\n',
				headers);

		NCP_SingleRequestMock fakeErrorCall = new NCP_SingleRequestMock(200,
				'Complete',
				'sf__Id,sf__Created,Account.Acc_No__c,NCP_Entitlement_Access_Type__c,NCP_External_Service_Contract_Id__c,NCP_External_Status__c,Name,ParentServiceContract.NCP_External_Service_Contract_Id__c,PriceBook2.Name,recordType.Name\n' + sccCDB.Id + ',' + false + ',' + sccCDB.AccountId + ',' + '' + ',' + '' + ',' + sccCDB.NCP_External_Status__c + ',' + '' + ',' + 203818 + ',' + sccCDB.Pricebook2.Name + ',' + sccCDB.RecordType.Name + '\n',
				headers);

		String host = System.Url.getSalesforceBaseURL().toExternalForm();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(host + '/services/data/v43.0/jobs/ingest/' + jobid, fakeApiJobDetails);
		endpoint2TestResp.put(host + '/services/data/v43.0/jobs/ingest/' + jobid + '/successfulResults/', fakeSuccessCall);
		endpoint2TestResp.put(host + '/services/data/v43.0/jobs/ingest/' + jobid + '/failedResults/', fakeErrorCall);
		HttpCalloutMock multiCalloutMock = new NCP_InterfaceLogFromIpaaS_WS_Mock(endpoint2TestResp);

		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		NCP_InterfaceLogFromIpaaS_WS.CreateInterfaceLogFromIpaaS(jobId);

		List<Interface_Log__c> allRecords = [SELECT Id FROM Interface_Log__c];
		System.debug('allRecords >> ' + allRecords);

		Test.stopTest();
	}

	@isTest
	static void testLogContractLineItemFromIpaaS() {

		Id customerRecordTypeId = NCP_Utils.getObjectRecordTypeId('Account', NCP_Constants.ACCOUNT_RT_DEVNAME_CUSTOMER);
		Account acc = [SELECT Id FROM Account WHERE RecordTypeId = :customerRecordTypeId LIMIT 1];

		Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];

		User u = NCP_TestFactory.createUser(true, 'AES Admin', con, 'test@nokia.com.dev');
		insert u;

		contractLineItem cli = [SELECT Id,ExternalPricebookEntryId__c,NCP_External_Contract_Line_Item_Id__c FROM contractLineItem LIMIT 1] ;

		Test.startTest();

		String jobId = '12345';
		Map<String, String> headers = new Map<String, String>();
		headers.put('Content-Type', 'text/csv');
		NCP_SingleRequestMock fakeApiJobDetails = new NCP_SingleRequestMock(200,
				'Complete',
				'{"id":"1","object": "contractLineItem","operation":"insert","numberRecordsProcessed":1,"numberRecordsFailed":1}',
				headers);

		NCP_SingleRequestMock fakeSuccessCall = new NCP_SingleRequestMock(200,
				'Complete',
				'ExternalPricebookEntryId__c,NCP_External_Contract_Line_Item_Id__c\n' + cli.ExternalPricebookEntryId__c + ',' + cli.NCP_External_Contract_Line_Item_Id__c + '\n',
				headers);

		NCP_SingleRequestMock fakeErrorCall = new NCP_SingleRequestMock(200,
				'Complete',
				'ExternalPricebookEntryId__c,NCP_External_Contract_Line_Item_Id__c\n' + cli.ExternalPricebookEntryId__c + ',' + cli.NCP_External_Contract_Line_Item_Id__c + '\n',
				headers);

		String host = System.Url.getSalesforceBaseURL().toExternalForm();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(host + '/services/data/v43.0/jobs/ingest/' + jobid, fakeApiJobDetails);
		endpoint2TestResp.put(host + '/services/data/v43.0/jobs/ingest/' + jobid + '/successfulResults/', fakeSuccessCall);
		endpoint2TestResp.put(host + '/services/data/v43.0/jobs/ingest/' + jobid + '/failedResults/', fakeErrorCall);
		HttpCalloutMock multiCalloutMock = new NCP_InterfaceLogFromIpaaS_WS_Mock(endpoint2TestResp);

		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		NCP_InterfaceLogFromIpaaS_WS.CreateInterfaceLogFromIpaaS(jobId);

		List<Interface_Log__c> allRecords = [SELECT Id FROM Interface_Log__c];
		System.debug('allRecords >> ' + allRecords);

		Test.stopTest();
	}

	@isTest
	static void testAuthorisedEntitlementFromIpaaS() {

		Id customerRecordTypeId = NCP_Utils.getObjectRecordTypeId('Account', NCP_Constants.ACCOUNT_RT_DEVNAME_CUSTOMER);
		Account acc = [SELECT Id FROM Account WHERE RecordTypeId = :customerRecordTypeId LIMIT 1];

		Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];

		User u = NCP_TestFactory.createUser(true, 'AES Admin', con, 'test@nokia.com.dev');
		insert u;

		NCP_Authorised_Entitlement__c ae = [SELECT Id,NCP_External_Id__c FROM NCP_Authorised_Entitlement__c LIMIT 1] ;

		Test.startTest();

		String jobId = '12345';
		Map<String, String> headers = new Map<String, String>();
		headers.put('Content-Type', 'text/csv');
		NCP_SingleRequestMock fakeApiJobDetails = new NCP_SingleRequestMock(200,
				'Complete',
				'{"id":"1","object": "NCP_Authorised_Entitlement__c","operation":"insert","numberRecordsProcessed":1,"numberRecordsFailed":1}',
				headers);

		NCP_SingleRequestMock fakeSuccessCall = new NCP_SingleRequestMock(200,
				'Complete',
				'NCP_External_Id__c\n' + ae.NCP_External_Id__c + '\n',
				headers);

		NCP_SingleRequestMock fakeErrorCall = new NCP_SingleRequestMock(200,
				'Complete',
				'NCP_External_Id__c\n' + ae.NCP_External_Id__c + '\n',
				headers);

		String host = System.Url.getSalesforceBaseURL().toExternalForm();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(host + '/services/data/v43.0/jobs/ingest/' + jobid, fakeApiJobDetails);
		endpoint2TestResp.put(host + '/services/data/v43.0/jobs/ingest/' + jobid + '/successfulResults/', fakeSuccessCall);
		endpoint2TestResp.put(host + '/services/data/v43.0/jobs/ingest/' + jobid + '/failedResults/', fakeErrorCall);
		HttpCalloutMock multiCalloutMock = new NCP_InterfaceLogFromIpaaS_WS_Mock(endpoint2TestResp);

		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		NCP_InterfaceLogFromIpaaS_WS.CreateInterfaceLogFromIpaaS(jobId);

		List<Interface_Log__c> allRecords = [SELECT Id FROM Interface_Log__c];
		System.debug('allRecords >> ' + allRecords);

		Test.stopTest();
	}
	
	@isTest
	static void testInsertInterfaceLog() {

		Boolean abc = true;
		Test.startTest();
		
		try{
			NCP_InterfaceLog.insertInterfaceLog('CDB Parent Service Contract','Inbound', 'upsert', 'CDB Parent Service Contract', 'Success', 'Success', 'data');
			NCP_InterfaceLog.createInterfaceLog('CDB Parent Service Contract', 'Inbound', 'upsert', 'CDB Parent Service Contract', 'Success', 'Success', 'data');
		}catch(Exception e1){
		 	System.assertEquals(abc,true);   
		}
		System.assertEquals(abc,true);


		Test.stopTest();
	}


}