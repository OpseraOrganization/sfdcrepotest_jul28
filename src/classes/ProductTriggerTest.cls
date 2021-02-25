/****************************************
 * Name : ProductTriggerTest
 * Author : Accenture
 * Description : Test class for ProductTrigger and ProductTriggerHelper
 * Fixed by Salesforce Aug 15,2018
 *****************************************/
@isTest
private class ProductTriggerTest {

	@testSetup static void setup() {
		Product2 pr = NCP_TestFactory.createProduct();
		Account acc = NCP_TestFactory.createAccount();
		Account acc2 = NCP_TestFactory.createLegalAccount(acc.id);
		Contact cont = NCP_TestFactory.createContact(acc);
		AccountContactRelation acr = NCP_TestFactory.createAccountContactRelation(cont.Id, acc2.Id, true);
		ServiceContract scCDB = NCP_TestFactory.createServiceContract(acc2, 'CDB');
		//NCP_Product_Content__c pc = NCP_TestFactory.createProductService(pr.Id,'PIC');
		//contractLineItem cli = NCP_TestFactory.createContractLineItem(pr,scCDB);
	}

	/***********************
	* Method Name: productUpdateTest
	* Description: To create Product and update it
	* Parameters: NA
	************************/
	@isTest
	static void productUpdateTest() {

		User admin = CustomLeadConversionTest.createSystemAdminUser();
		System.runAs(admin) {
			List<Product2> prodList = new List<Product2>();

			//Creating a Product prod1
			Product2 prod1 = NCP_TestFactory.createProduct('Test1', '1231', 'NSW', 'USD', 'IP Routing', 'Release', 1.00, true);
			//Creating a product prod2
			Product2 prod2 = NCP_TestFactory.createProduct('Test2', '1232', 'NSW', 'USD', 'IP Routing', 'Maintain', 2.00, true);
			//Creating a product prod3
			Product2 prod3 = NCP_TestFactory.createProduct('Test3', '1233', 'NSW', 'USD', 'IP Routing', '', 3.00, true);
			//Creating a product prod4
			Product2 prod4 = NCP_TestFactory.createProduct('Test4', '1234', 'NSW', 'USD', 'Fixed Access - FBA', '', 4.00, true);

			prodList.add(prod1);
			prodList.add(prod2);
			prodList.add(prod3);
			prodList.add(prod4);

			//inserting the products created above
			insert prodList;
			Test.startTest();
			Product2 productTest2 = new Product2();
			productTest2 = [select Id, Apttus_Config2__Version__c from Product2 where Id = :prod1.Id];

			productTest2.Apttus_Config2__Version__c = 11.10;
			update productTest2;

			CollaborationGroup CollaborationGroupObject = new CollaborationGroup();
			CollaborationGroupObject = TestDataFactory.createCollaborationGroup('Unlisted', 'Partner Users Group');
			database.insert(CollaborationGroupObject);

			TestDataFactory.createCollaborationGroupMember(CollaborationGroupObject.Id, admin.Id);

			//updating the List inserted above

			ProductTriggerHelper.sendChatter(prodList);
			Test.stopTest();
		}
	}

	@isTest
	static void TestDeleteProduct2() {
		User admin = NCP_TestFactory.createUser(true, 'AES Admin', null, 'test@nokia.com.dev');
		System.runAs(admin) {

			Product2 simplePr = [SELECT Id FROM Product2 LIMIT 1];
			NCP_Favorite_Product__c favoritePr = NCP_TestFactory.createFavoriteProduct(simplePr, admin);

			// Perform test
			Test.startTest();
			Database.DeleteResult result = Database.delete(simplePr, false);
			List<Product2> checkIfExistList = [SELECT Id FROM Product2 WHERE Id = :simplePr.Id];

			System.assertEquals(checkIfExistList.size(), 0);
			Test.stopTest();
		}
	}

}