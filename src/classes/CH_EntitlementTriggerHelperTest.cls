/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* 
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/

@isTest
public class CH_EntitlementTriggerHelperTest {
	public static testMethod void test() {
		
		integer j = 5;
		CH_EntitlementTestData.createCustomSettingData();
		
		List <Account> AccountListNL = new List<Account>();
		AccountListNL = CH_EntitlementTestData.createAccountRecord(j, 'Prospect', null);
		insert AccountListNL;
		
		List <Account> AccountListLE = new List<Account>();
		AccountListLE = CH_EntitlementTestData.createAccountRecord(j, 'Legal_Entity', AccountListNL);
		insert AccountListLE;
		
		List <Contact> ConatctList = new List<Contact>();
		ConatctList = CH_EntitlementTestData.createContactRecord(j,AccountListNL);
		insert ConatctList;
		
		List<Product2> productlist =new List<Product2>();
		productlist = CH_EntitlementTestData.createProductRecord(j);
		insert productlist;
		
		List<PricebookEntry> pricebook =new List <PricebookEntry>();
		pricebook = CH_EntitlementTestData.createPricebookEntryRecord(j, productlist);
		insert pricebook;
		
		Pricebook2 customPB1 = new Pricebook2();
		customPB1.Id = CH_EntitlementTestData.CreateCustomPriceBook();
		
		List<PricebookEntry> Custompricebook =new List <PricebookEntry>();
		Custompricebook = CH_EntitlementTestData.createCustomPricebookEntryRecord(j, productlist, customPB1.id);
		insert Custompricebook;
		
		
		List<ServiceContract> ServiceContractlist =new List<ServiceContract>();
		ServiceContractlist = CH_EntitlementTestData.createServiceContractRecord(j, AccountListLE, null, customPB1.id );
		insert ServiceContractlist; 
		
		List<ContractLineItem> ContractLineItemList =new List<ContractLineItem>();
		ContractLineItemList = CH_EntitlementTestData.createContractLineItemRecord(j, Custompricebook,ServiceContractlist);
		insert ContractLineItemList;
		
		List<Entitlement> entitlementlist =new List<Entitlement>();
		entitlementlist = CH_EntitlementTestData.createEntitlementRecord(j, AccountListLE, ContractLineItemList, null,ServiceContractlist);
		insert entitlementlist;
		
		Map<ID,Entitlement> entMap = New Map<ID,Entitlement>([Select ID from Entitlement where AccountId =:AccountListLE AND ServiceContractId =: ServiceContractList AND id =:entitlementlist]);
		for(Entitlement entObjTest1: entMap.values()){		   
			entObjTest1.CH_ServiceMappingId__c = 'Legacy Customer Support Service - All Severity 24x7';
			entMap.put(entObjTest1.id,entObjTest1);
		}
		update entMap.values();		
	}
}