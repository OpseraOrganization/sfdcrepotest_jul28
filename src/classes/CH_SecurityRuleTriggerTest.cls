/** 
 * About 
 * ----- 
 * @Description	  : Case Handling SecurityRule Trigger Test Class.
 * @Project		  : Case Handling.
 * @Modification Log : 
 *  Created  : 2019 11 18 – tiago.almeida@nokia.com
 * ----- 
**/
@isTest
public class CH_SecurityRuleTriggerTest {
	private static ServiceContract oServiceContract;
	
	private static void setupData1() {
		//create user
		User adminUser = CH_TestDataFactory.createUser('System Administrator', 'CH_KnowledgeHandler_TL' + 1);
		insert adminUser;
		//Assign Permission set CH_KB_Workgroup_Admin to created user
		PermissionSet oPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CH_KB_Workgroup_Admin'];
		system.assert(oPermissionSet !=null);
		system.runAs(adminUser){
			Boolean hasEntitlementScript = true;
			Account oCustomerParentAccount = new Account();
			Id accountRecordType1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
			oCustomerParentAccount.Name = 'Customer Parent Account';
			oCustomerParentAccount.RecordTypeId = accountRecordType1;
			oCustomerParentAccount.Customer_Compliance__c = 'US_Company';
			insert oCustomerParentAccount; 
			
			// Creation of Account
			Account oAccount = new Account();
			Id accountCustomerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
			oAccount.Name = 'Parent Account';
			oAccount.RecordTypeId = accountCustomerRecordType;
			oAccount.ParentId = oCustomerParentAccount.id;
			oAccount.AccountNumber ='LE123';
			insert oAccount; 
			
			List<Product2> oProductList = CH_UTIL_TEST.createS2SProducts('testSolution', '12348', 'testProduct', '12350', 'testVariant', '12352');
			insert oProductList;
			
			PriceBookEntry oPriceBookEntry = new PriceBookEntry(
				Pricebook2Id = Test.getStandardPricebookId(),
				Product2Id = oProductList[0].id,
				UnitPrice = 0,
				CurrencyIsoCode = 'EUR',
				IsActive = true
			);
			insert oPriceBookEntry;
			
			// Create contract
			oServiceContract = new ServiceContract(
				AccountId = oAccount.Id, 
				Name = 'TestServiceContract',
				CH_CDB_ContractId__c = 'Test',
				CH_EntitlementScript__c = (hasEntitlementScript)?'Header Script':'',
				Pricebook2Id = Test.getStandardPricebookId(),
				NCP_External_Status__c = 'Active'
			);
			insert oServiceContract;
			System.debug('#####'+oServiceContract);
			
			// Create contract
			List<Group> oGroupList = new List<Group>{
				new Group(
					Name = 'SEC||TEST1||',
					DeveloperName = 'SEC_TEST1',
					Type  = 'Regular'
				),
				new Group(
					Name = 'SEC||TEST2||',
					DeveloperName = 'SEC_TEST2',
					Type  = 'Regular'
				)
			};
			insert oGroupList;
		}
	}
	
	public testMethod static void testMethod1() {
		setupData1() ;
		Test.StartTest();
		CH_SecurityRule__c oSecurityRule = new CH_SecurityRule__c(
			CH_OrderofExecution__c = 5000,
			CH_3rdPartySecurityGroup__c = 'SEC||TEST1||',
			CH_ContractNumber__c = [SELECT Id, ContractNumber FROM ServiceContract WHERE Id = :oServiceContract.Id LIMIT 1].ContractNumber,
			CH_Active__c = true
		);
		insert oSecurityRule;
		oSecurityRule.CH_3rdPartySecurityGroup__c = 'SEC||TEST2||';
		update oSecurityRule;
		delete oSecurityRule;
		Test.StopTest();		 
	}
}