@isTest(SeeAllData = true)
private class Nokia_PricingCallBack_Test {

static testMethod void directNSW() {
Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
custSetting.Apttus_Config2__PricingCallbackClass__c = 'Nokia_PricingCallBack';
custSetting.Name = 'Nokia_CallBack1';
insert custSetting;

Nokia_PricingCallBack npc = new Nokia_PricingCallBack();

List<Opportunity> opportunities;

List<User> users = NF_TestDataFactory.getUsers(1,'System Administrator');
users[0].Nokia_ID__c = '234597';
insert users;

System.runAs(users[0]) {   

List<Account> accountsNew = new List<Account>();
Account accLegalEntity = TestDataFactory.createAccount(1)[0];
accLegalEntity.AccountNumber='101234567';
accLegalEntity.Acc_No__c = '101234567';
accLegalEntity.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
accountsNew.add(accLegalEntity);

Account account = TestDataFactory.createAccount(1)[0];
account.AccountNumber='3011234567';
account.Acc_No__c = '3011234567';
account.CountryCode__c='IN';
accountsNew.add(account);

insert accountsNew;

List<Account> accounts=new List<Account>();
accounts.add(account);

//Create Opportunity
opportunities = NF_TestDataFactory.getOpportunities(1,accounts);
opportunities.get(0).Lead_BG__c = 'NSW';
opportunities.get(0).RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();

insert opportunities.get(0);


//Create Product
List<Product2> prods = new List<Product2>();
Product2 prod1 = new product2(
Name = 'Test1', 
ProductCode = '123', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'Nokia Software',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Bundle',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Standard SW (STD)',
NokiaCPQ_License_Usage__c='Commercial Term License',
NokiaCPQ_Product_Discount_Category__c = 'XYZ'
); 
prods.add(prod1);

Product2 prod2 = new product2(
Name = 'Option1Care', 
ProductCode = '784800098209', 
Business_Group__c = 'NSW', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'Nokia Software',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Standard SW (STD)',
NokiaCPQ_License_Usage__c='Commercial Licence'); 
prods.add(prod2);

Product2 prod3 = new product2(
Name = 'Option2SRS', 
ProductCode = 'SRS', 
Business_Group__c = 'NSW', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'Nokia Software',
IsActive = true,
NokiaCPQ_Product_Discount_Category__c = 'NFM-P',
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Standard SW (STD)',
NokiaCPQ_License_Usage__c='Commercial Licence'
); 
prods.add(prod3);

Product2 prod4 = new product2(
Name = 'Option3', 
ProductCode = '12345', 
Business_Group__c = 'NSW', 
CurrencyIsoCode = 'USD',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Standard SW (STD)',
NokiaCPQ_License_Usage__c='Commercial Licence'
);  
prods.add(prod4);

Product2 prod5 = new product2(
Name = 'Test1', 
ProductCode = '12356', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'Nokia Software',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Bundle',
NokiaCPQ_Item_Type__c='Hardware',
NokiaCPQ_Classification2__c='Base',
NokiaCPQ_License_Usage__c='Commercial Licence',
NokiaCPQ_Product_Discount_Category__c = 'NSW'
); 
prods.add(prod5);

Product2 prod6 = new product2(
Name = 'Option2Care', 
ProductCode = '784800098210', 
Business_Group__c = 'NSW', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'Nokia Software',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Standard SW (STD)',
NokiaCPQ_License_Usage__c='Commercial Licence'); 
prods.add(prod6);

insert prods;

//Create PriceList

Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
Name = 'Commercial Price List', 
Apttus_Config2__Active__c = True
);
insert ApttusTestPriceList;

//create price list items
List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod1.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price'
);
//insert pLI1;
plistItems.add(pLI1);

Apttus_Config2__PriceListItem__c pLI2 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
Apttus_Config2__ListPrice__c = 200, 
Apttus_Config2__ProductId__c = prod2.Id, 
Apttus_Config2__PriceIncludedInBundle__c = true,
Apttus_Config2__ChargeType__c = 'Year 1 Maintenance'
);
//insert pLI2;
plistItems.add(pLI2);

Apttus_Config2__PriceListItem__c pLI3 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod3.Id, 
Apttus_Config2__ChargeType__c = 'SRS',
Apttus_Config2__PriceIncludedInBundle__c = true,
Apttus_Config2__ContractPrice__c = 100
);
//insert pLI1;
plistItems.add(pLI3);

Apttus_Config2__PriceListItem__c pLI4 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod4.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price'
);
//insert pLI1;
plistItems.add(pLI4);

Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod5.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price'
);
//insert pLI1;
plistItems.add(pLI5);

Apttus_Config2__PriceListItem__c pLI6 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
Apttus_Config2__ListPrice__c = 200, 
Apttus_Config2__ProductId__c = prod6.Id, 
Apttus_Config2__PriceIncludedInBundle__c = true,
Apttus_Config2__ChargeType__c = 'Year 1 Maintenance'
);
//insert pLI2;
plistItems.add(pLI6);

insert plistItems;

Product_Discount__c disc = new Product_Discount__c ();
disc.Discount__c = 8.00;
disc.Market__c = account.Market__c;
disc.Product_Discount_Category__c = 'NFM-P';
insert disc;

//create proposal
Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(
Apttus_Proposal__Opportunity__c = opportunities.get(0).Id,
Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
NokiaCPQ_Portfolio__c = 'Nokia Software',
Apttus_Proposal__Approval_Stage__c = 'Draft',
NokiaCPQ_No_of_Years__c = '1',
RecordTypeId =Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),//direct	Prices_Aligned__c=true,
Apttus_Proposal__Account__c=accounts[0].id,
Sold_To_Party__c = accLegalEntity.id,
Is_List_Price_Only__c =false
);
insert testProposal;

system.debug('testProposal:'+testProposal);

//create product configuration
Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c(
Name = 'APTTUS Test Config', 
Apttus_Config2__AccountId__c = account.Id, 
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
Apttus_QPConfig__Proposald__c = testProposal.Id, 
Apttus_Config2__Status__c = 'New', 
Apttus_Config2__VersionNumber__c = 1, 
Apttus_Config2__EffectivePriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__BusinessObjectId__c = String.valueOf(testProposal.Id),
Apttus_Config2__BusinessObjectType__c = 'Proposal'
);
insert ProdConfig;

//Create Line Items
list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__PriceListItemId__c = pLI1.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePrice__c=120,
Apttus_Config2__ListPrice__c = 100,
Apttus_Config2__Quantity__c = 1,
Source__c='',
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
is_Custom_Product__c=false,
Apttus_Config2__BasePriceOverride__c=1180.52,
Apttus_Config2__AddedBy__c = 'added by code',
NokiaCPQ_Is_Direct_Option__c=true,
Apttus_Config2__NetAdjustmentPercent__c=0,
Item_Type_From_CAT__c='PS',
NokiaCPQ_Account_Region__c='RG_NAM'


);
allLineItems.add(LineItem1);

Apttus_Config2__LineItem__c LineItem2 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 2,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Year 1 Maintenance', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__OptionId__c = prod2.Id,
Apttus_Config2__ParentBundleNumber__c = 1,
Apttus_Config2__PriceListItemId__c = pLI2.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
is_Custom_Product__c=false,
Apttus_Config2__ListPrice__c = 200,
Apttus_Config2__BasePrice__c=200,
Apttus_Config2__Quantity__c = 1,
Apttus_Config2__BasePriceOverride__c=1185.02,
Apttus_Config2__PrimaryLineNumber__c = 2,
Apttus_Config2__ShipToAccountId__c = account.Id,

NokiaCPQ_Account_Region__c='RG_LAM',
Apttus_Config2__AddedBy__c = 'added by code'
);
//insert LineItem1;
allLineItems.add(LineItem2);

Apttus_Config2__LineItem__c LineItem3 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 3,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'SRS', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__OptionId__c = prod3.Id,
Apttus_Config2__ParentBundleNumber__c = 1,
Apttus_Config2__PriceListItemId__c = pLI3.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePrice__c=300,
Apttus_Config2__ListPrice__c = 300,
Apttus_Config2__Quantity__c = 1,
is_Custom_Product__c=false,
Apttus_Config2__PrimaryLineNumber__c = 2,
Apttus_Config2__ShipToAccountId__c = account.Id,

NokiaCPQ_Account_Region__c='RG_MEA',
Apttus_Config2__AddedBy__c = 'added by code'
);

allLineItems.add(LineItem3);

Apttus_Config2__LineItem__c LineItem4 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 4,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__OptionId__c = prod4.Id,
Apttus_Config2__ParentBundleNumber__c = 1,
Apttus_Config2__PriceListItemId__c = pLI4.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
NokiaCPQ_Maint_Yr1_Extended_Price__c =  100,
Apttus_Config2__ListPrice__c = 120,
Apttus_Config2__BasePrice__c=120,
Apttus_Config2__Quantity__c = 1,
Apttus_Config2__PriceIncludedInBundle__c = true,
Apttus_Config2__PrimaryLineNumber__c = 2,
Apttus_Config2__ShipToAccountId__c = account.Id,
is_Custom_Product__c=false,
NokiaCPQ_Account_Region__c= 'RG_ASIA',
Apttus_Config2__AddedBy__c = 'added by code'	 
);
allLineItems.add(LineItem4);

Apttus_Config2__LineItem__c LineItem5 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 5,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__OptionId__c = prod5.Id,
Apttus_Config2__ParentBundleNumber__c = 1,
Apttus_Config2__PriceListItemId__c = pLI5.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
NokiaCPQ_Maint_Yr1_Extended_Price__c =  100,
Apttus_Config2__ListPrice__c = 120,
Apttus_Config2__BasePrice__c=120,
Apttus_Config2__Quantity__c = 1,
Apttus_Config2__PriceIncludedInBundle__c = false,
Apttus_Config2__PrimaryLineNumber__c = 2,
Apttus_Config2__ShipToAccountId__c = account.Id,
is_Custom_Product__c=false,
NokiaCPQ_Account_Region__c= 'RG_CHINA',
Apttus_Config2__AddedBy__c = 'added by code'	 
);
//insert LineItem1;
allLineItems.add(LineItem5);

Apttus_Config2__LineItem__c LineItem6 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 6,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Year 1 Maintenance', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__OptionId__c = prod6.Id,
Apttus_Config2__ParentBundleNumber__c = 1,
Apttus_Config2__PriceListItemId__c = pLI6.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
is_Custom_Product__c=false,
Apttus_Config2__ListPrice__c = 200,
Apttus_Config2__BasePrice__c=200,
Apttus_Config2__Quantity__c = 1,
Apttus_Config2__BasePriceOverride__c=1185.02,
Apttus_Config2__PrimaryLineNumber__c = 2,
Apttus_Config2__ShipToAccountId__c = account.Id,
NokiaCPQ_Account_Region__c  = 'RG_EUROPE',
Apttus_Config2__AddedBy__c = 'added by code'
);

allLineItems.add(LineItem6);

insert allLineItems;

Test.startTest(); 

Nokia_PricingCallBack obj = new Nokia_PricingCallBack();

obj.setMode(Apttus_Config2.CustomClass.PricingMode.BASEPRICE);
Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);

obj.setMode(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT);

Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);
obj.finish();

obj.getPortfolio(LineItem5);
Nokia_PricingCallBack.getProductDiscountCategory(LineItem5);
Nokia_PricingCallBack.getProductDiscountCategory(LineItem1);
obj.getMinimumSalesMargin(LineItem1); 
obj.getMinimumSalesMargin(LineItem2); 
obj.getMinimumSalesMargin(LineItem3); 
obj.getMinimumSalesMargin(LineItem4); 
obj.getMinimumSalesMargin(LineItem5); 
obj.getMinimumSalesMargin(LineItem6); 



}
Test.stopTest();
}

//method for testDS_Equivalentprice
static testMethod void Airscalewifisoftware() {
Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
custSetting.Apttus_Config2__PricingCallbackClass__c = 'Nokia_PricingCallBack';
custSetting.Name = 'Nokia_CallBack1';
insert custSetting;

Nokia_PricingCallBack npc = new Nokia_PricingCallBack();

List<Opportunity> opportunities;
List<Accreditation__c> accreditations = new List<Accreditation__c>();
List<User> users = NF_TestDataFactory.getUsers(1,'System Administrator');
users[0].Nokia_ID__c = '234597';
insert users;


System.runAs(users[0]) {

List<Account> accountsNew = new List<Account>();
Account accLegalEntity = TestDataFactory.createAccount(1)[0];
accLegalEntity.AccountNumber='101234567';
accLegalEntity.Acc_No__c = '101234567';
accLegalEntity.GeoLevel1Id__c = 'RG_NAM';
accLegalEntity.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
accountsNew.add(accLegalEntity);

Account account = TestDataFactory.createAccount(1)[0];
account.AccountNumber='3011234567';
account.Acc_No__c = '3011234567';
account.GeoLevel1Id__c = 'RG_NAM';
accountsNew.add(account);

insert accountsNew;


List<Account> accounts=new List<Account>();
accounts.add(account);

//Create Opportunity
opportunities = NF_TestDataFactory.getOpportunities(1,accounts);
opportunities.get(0).Lead_BG__c = 'NSW';
opportunities.get(0).RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();

insert opportunities.get(0);


//Create Product
List<Product2> prods = new List<Product2>();

Product2 prod1 = new product2(
Name = 'Test1', 
ProductCode = '123',
CurrencyIsoCode = 'USD',
Portfolio__c = 'Airscale Wifi',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Bundle',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Base'	   
); 
prods.add(prod1);

Product2 prod2 = new product2(
Name = 'Maintenance Year1', 
ProductCode = 'MT001', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'IP Routing',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Base'); 
prods.add(prod2);

Product2 prod3 = new product2(
Name = 'Test2', 
ProductCode = '1234',  
CurrencyIsoCode = 'USD',
Portfolio__c = 'Airscale Wifi',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Base'
); 
prods.add(prod3);

Product2 prod5 = new product2(
Name = 'Maintenance Year2+', 
ProductCode = 'MT002', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'IP Routing',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone'
); 
prods.add(prod5); 

Product2 prod6 = new product2(
Name = 'Test1Arcadia', 
ProductCode = '123Arcadia',
CurrencyIsoCode = 'USD',
Portfolio__c = 'Airscale Wifi',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Bundle',
NokiaCPQ_Item_Type__c='Hardware',
NokiaCPQ_Classification2__c='Base'	   
); 
prods.add(prod6);   

Product2 prod7 = new product2(
Name = 'Test2Arcadia', 
ProductCode = 'Arcadia2',
CurrencyIsoCode = 'USD',
Portfolio__c = 'Airscale Wifi',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Bundle',
NokiaCPQ_Item_Type__c='Hardware',
NokiaCPQ_Classification2__c='Base'	   
); 
prods.add(prod7); 


Product2 prod8 = new product2(
Name = '12678', 
ProductCode = '12678',
CurrencyIsoCode = 'USD',
Portfolio__c = 'Airscale Wifi',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Hardware',
NokiaCPQ_Classification2__c='Base'	   
); 
prods.add(prod8); 

insert prods;

//Create PriceList

Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
Name = 'Commercial Price List', 
Apttus_Config2__Active__c = True, PriceList_Type__c = 'CPQ'
);
insert ApttusTestPriceList;

//create price list items
List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod1.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price'
);
//insert pLI1;
plistItems.add(pLI1);

Apttus_Config2__PriceListItem__c pLI2 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
Apttus_Config2__ListPrice__c = 200, 
Apttus_Config2__ProductId__c = prod2.Id, 
Apttus_Config2__PriceIncludedInBundle__c = false,
Apttus_Config2__ChargeType__c = 'Year 1 Maintenance'
);
//insert pLI2;
plistItems.add(pLI2);

Apttus_Config2__PriceListItem__c pLI3 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod3.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price',
Apttus_Config2__PriceIncludedInBundle__c = false,
Apttus_Config2__ContractPrice__c = 100
);
//insert pLI1;
plistItems.add(pLI3);


Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod5.Id, 
Apttus_Config2__ChargeType__c = 'Maintenance for Y2 & Beyond'
);
//insert pLI1;
plistItems.add(pLI5);

Apttus_Config2__PriceListItem__c pLI6 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod6.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price',
Apttus_Config2__PriceIncludedInBundle__c = false,
Apttus_Config2__ContractPrice__c = 100
);
//insert pLI1;
plistItems.add(pLI6);

Apttus_Config2__PriceListItem__c pLI7 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod7.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price',
Apttus_Config2__PriceIncludedInBundle__c = false,
Apttus_Config2__ContractPrice__c = 100
);
//insert pLI1;
plistItems.add(pLI7);

Apttus_Config2__PriceListItem__c pLI8 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod8.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price',
Apttus_Config2__PriceIncludedInBundle__c = false,
Apttus_Config2__ContractPrice__c = 100
);
//insert pLI1;
plistItems.add(pLI8);

insert plistItems;

Product_Discount__c disc = new Product_Discount__c ();
disc.Discount__c = 8.00;
disc.Market__c = account.Market__c;
disc.Product_Discount_Category__c = 'NFM-P';
insert disc;

//create proposal
Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(
Apttus_Proposal__Opportunity__c = opportunities.get(0).Id,
Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
NokiaCPQ_Portfolio__c = 'Airscale Wifi',
NokiaCPQ_No_of_Years__c = '3',
NokiaCPQ_Maintenance_Type__c='MN GS TSS Enhanced',
RecordTypeId =Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),//direct	Prices_Aligned__c=true,
Apttus_Proposal__Account__c=accLegalEntity.id,
Sold_To_Party__c = accLegalEntity.id,
Is_List_Price_Only__c =false
);
insert testProposal;


system.debug('testProposal:'+testProposal);

//create product configuration
Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c(
Name = 'APTTUS Test Config', 
Apttus_Config2__AccountId__c = account.Id, 
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
Apttus_QPConfig__Proposald__c = testProposal.Id, 
Apttus_Config2__Status__c = 'New', 
Apttus_Config2__VersionNumber__c = 1, 
Apttus_Config2__EffectivePriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__BusinessObjectId__c = String.valueOf(testProposal.Id),
Apttus_Config2__BusinessObjectType__c = 'Proposal'
);
insert ProdConfig;

//Create Line Items
list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__PriceListItemId__c = pLI1.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePrice__c=100,
Apttus_Config2__ListPrice__c = 100,
Apttus_Config2__Quantity__c = 1,
Source__c='',
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
is_Custom_Product__c=false,
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__AddedBy__c = 'added by code',
NokiaCPQ_Product_Type__c='Controller'

);
//insert LineItem2;
allLineItems.add(LineItem1);

Apttus_Config2__LineItem__c LineItem3 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 2,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__OptionId__c = prod6.Id,
Apttus_Config2__ParentBundleNumber__c = 1,
Apttus_Config2__PriceListItemId__c = pLI6.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__ListPrice__c = 300,
Apttus_Config2__BasePrice__c=300,
Apttus_Config2__Quantity__c = 1,
is_Custom_Product__c=false,
Apttus_Config2__PrimaryLineNumber__c = 2,
Apttus_Config2__ShipToAccountId__c = account.Id,
NokiaCPQ_Product_Type__c = 'Access Point',			
Apttus_Config2__AddedBy__c = 'added by code',
Apttus_Config2__AdjustmentType__c = '% Discount',
Apttus_Config2__AdjustmentAmount__c = 10
);
//insert LineItem1;
allLineItems.add(LineItem3);

Apttus_Config2__LineItem__c LineItem4 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 3,
Apttus_Config2__LineNumber__c = 2,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Year 1 Maintenance', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod2.Id,
Apttus_Config2__PriceListItemId__c = pLI2.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
NokiaCPQ_Maint_Yr1_Extended_Price__c =  100,
Apttus_Config2__ListPrice__c = 120,
Apttus_Config2__BasePrice__c=120,
Apttus_Config2__Quantity__c = 1,
Apttus_Config2__PriceIncludedInBundle__c = true,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
is_Custom_Product__c=false,
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__AddedBy__c = 'added by code'	 
);
//insert LineItem1;
allLineItems.add(LineItem4);

Apttus_Config2__LineItem__c LineItem5 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 4,
Apttus_Config2__LineNumber__c = 3,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Maintenance for Y2 & Beyond', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod5.Id,
Apttus_Config2__PriceListItemId__c = pLI5.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
NokiaCPQ_Maint_Yr1_Extended_Price__c =  100,
Apttus_Config2__ListPrice__c = 120,
Apttus_Config2__BasePrice__c=120,
Apttus_Config2__Quantity__c = 1,
Apttus_Config2__PriceIncludedInBundle__c = true,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
is_Custom_Product__c=false,
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__AddedBy__c = 'added by code'	 
);
//insert LineItem1;
allLineItems.add(LineItem5);

Apttus_Config2__LineItem__c LineItem6 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 2,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod6.Id,
Apttus_Config2__OptionId__c = prod3.Id,
Apttus_Config2__ParentBundleNumber__c = 2,
Apttus_Config2__PriceListItemId__c = pLI3.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__ListPrice__c = 300,
Apttus_Config2__BasePrice__c=300,
Apttus_Config2__Quantity__c = 1,
is_Custom_Product__c=false,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,


Apttus_Config2__AddedBy__c = 'added by code'
);
//insert LineItem1;
allLineItems.add(LineItem6);

Apttus_Config2__LineItem__c LineItem7 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 2,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__OptionId__c = prod7.Id,
Apttus_Config2__ParentBundleNumber__c = 1,
Apttus_Config2__PriceListItemId__c = pLI7.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__ListPrice__c = 300,
Apttus_Config2__BasePrice__c=300,
Apttus_Config2__Quantity__c = 1,
is_Custom_Product__c=false,
Apttus_Config2__PrimaryLineNumber__c = 3,
Apttus_Config2__ShipToAccountId__c = account.Id,
NokiaCPQ_Product_Type__c = 'Controller',			
Apttus_Config2__AddedBy__c = 'added by code',
Apttus_Config2__AdjustmentType__c = 'Discount Amount',
Apttus_Config2__AdjustmentAmount__c = 100
);
//insert LineItem1;
allLineItems.add(LineItem7);

Apttus_Config2__LineItem__c LineItem8 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 2,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod7.Id,
Apttus_Config2__OptionId__c = prod8.Id,
Apttus_Config2__ParentBundleNumber__c = 3,
Apttus_Config2__PriceListItemId__c = pLI8.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__ListPrice__c = 300,
Apttus_Config2__BasePrice__c=300,
Apttus_Config2__Quantity__c = 1,
is_Custom_Product__c=false,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
NokiaCPQ_Product_Type__c = 'Third Party Wavespot',  

Apttus_Config2__AddedBy__c = 'added by code'
);
allLineItems.add(LineItem8);

insert allLineItems;

Test.startTest(); 

Nokia_PricingCallBack obj = new Nokia_PricingCallBack();

obj.setMode(Apttus_Config2.CustomClass.PricingMode.BASEPRICE);
Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);

obj.setMode(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT);

obj.finish();
//obj.onPriceItemSet(pLI8,null);
Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);


Nokia_PricingCallBack.calculateEquivalentPrice(allLineItems, 'Market India');

testProposal.NokiaCPQ_No_of_Years__c = '1';
testProposal.NokiaCPQ_Maintenance_Type__c='MN GS TSS Enhanced';
update testProposal;

Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);

}
Test.stopTest();
}

static testMethod void QTCmethod() {


List <Account> account3 = NOKIA_CPQ_TestDataFactory.getAccounts(2);
account3[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();

insert account3;

List<Opportunity> opportunities1 = NOKIA_CPQ_TestDataFactory.getOpportunities(1,account3);
opportunities1[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();

insert opportunities1;

/*create product*/
product2 prod = new product2();
prod.name = '5G';
prod.CurrencyIsoCode = 'USD';
prod.Business_Group__c='MN';
prod.Family= 'A&A-CEM';
prod.IsActive=True;
prod.Partner_Visible__c=True;
prod.ProductCode='FC11011';
prod.Apttus_Config2__Version__c=1;
prod.Portfolio__c='Airscale Wifi';
prod.Created_by_PMDI__c = False;
prod.Pricing_Clusters__c='NAM';
prod.IsActive= True;
insert prod;

test.startTest(); 
/*create pricelist*/
Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
Name = 'Commercial Price List', 
PriceList_Type__c='CPQ',
Apttus_Config2__Type__c='Standard',
Apttus_Config2__Active__c = True
);

insert ApttusTestPriceList;
/*create pricelist Item*/
Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price'
);
insert pLI5;

Apttus_Proposal__Proposal__c testProposal1 = new Apttus_Proposal__Proposal__c(
RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),
Apttus_Proposal__Account__c = account3[0].Id,
Apttus_Proposal__Opportunity__c = opportunities1.get(0).Id,
Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
NokiaCPQ_FN_Maintenance_Type__c='',
NokiaCPQ_SRS_Level__c='',
NokiaCPQ_Existing_IONMaint_Contract__c='',
NokiaCPQ_Needs_Reprice__c = false,
//NokiaCPQ_Environment_Access_Type__c = 'PRM',
Reprice_In_Progress__c = false,
NokiaCPQ_Existing_FN_Maint_Contract__c='',
NokiaCPQ_No_of_Years__c = '',
NokiaCPQ_ION_Maintenance_Type__c='',
NokiaCPQ_SSP_Level__c='',
NokiaCPQ_Portfolio__c = 'QTC',
//NokiaCPQ_Maintenance_Type__c ='MN GS TSS Basic',
Is_List_Price_Only__c = true 
);
insert testProposal1;

//create product configuration
Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c(
Name = 'APTTUS Test Config', 
Apttus_Config2__AccountId__c = account3[0].Id, 
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
Apttus_QPConfig__Proposald__c = testProposal1.Id, 
Apttus_Config2__Status__c = 'New', 
Apttus_Config2__VersionNumber__c = 1, 
Apttus_Config2__EffectivePriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__BusinessObjectId__c = String.valueOf(testProposal1.Id),
Apttus_Config2__BusinessObjectType__c = 'Proposal'
);
insert ProdConfig;


//Create Line Items
list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();

Apttus_Config2__LineItem__c LineItem3 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 1,
//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod.Id,
CPQ_Market_Model__c=null,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
is_Custom_Product__c=false,
Apttus_Config2__ListPrice__c = 300,


Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__Quantity__c = 10,
Apttus_Config2__NetPrice__c=100,


Apttus_Config2__AddedBy__c = 'added by code'
);
//insert LineItem1;
allLineItems.add(LineItem3);

insert allLineItems;

Nokia_PricingCallBack obj = new Nokia_PricingCallBack();

obj.setMode(Apttus_Config2.CustomClass.PricingMode.BASEPRICE);
Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);
Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);

obj.setMode(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT);

Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);
test.stopTest(); 
}

//method for Indirect Quotes

 /*static testMethod void Indirect1111() {
	Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
	custSetting.Apttus_Config2__PricingCallbackClass__c = 'Nokia_PricingCallBack';
	custSetting.Name = 'Nokia_CallBack1';
	insert custSetting;
	
	Map < String, List < String >> maintenanceAccredMap = new Map < String, List < String >> (); 
	Map < String, List < String >> productAccredMap = new Map < String, List < String >> ();
	Nokia_PricingCallBack npc = new Nokia_PricingCallBack();

	List<Opportunity> opportunities;
	List<Accreditation__c> accreditations = new List<Accreditation__c>();
	List<User> users = NF_TestDataFactory.getUsers(1,'System Administrator');
	users[0].Nokia_ID__c = '234597';
	insert users;
	
	System.runAs(users[0]) {   
	 
	//Create Account
	List<Account> accounts = NOKIA_CPQ_TestDataFactory.getAccounts(1);
		insert accounts;
		List<Account> accounts1 = NOKIA_CPQ_TestDataFactory.getAccounts(1);
		accounts1[0].Acc_No__c = 'Testing1';
		accounts1[0].Partner_Program__c ='';
		accounts1[0].Partner_Type__c = '';
		accounts1[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		accounts1[0].Active__c = true;
		accounts1[0].ParentId = accounts[0].Id;
		insert accounts1;
		
		//Create Opportunity
		opportunities = NF_TestDataFactory.getOpportunities(1,accounts);
		opportunities.get(0).Lead_BG__c = 'NSW';
		opportunities.get(0).RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Indirect Sales Opportunity').getRecordTypeId();
		opportunities.get(0).End_Customer_LE__c = accounts1[0].Id;
		opportunities.get(0).CurrencyIsoCode = Nokia_CPQ_Constants.USDCURRENCY;
		insert opportunities.get(0);
		
	//create Accreditation
	 
	Accreditation__c accreditation2 = new Accreditation__c(Accreditation_Type__c='Maintenance',
										Accreditation_Date__c = date.today(),
										Accreditation_Level__c='Nokia Brand of Service',
										Partner__c=accounts[0].Id,
										Portfolio__c='IP Routing',
										Pricing_Cluster__c='NAM'
																				);
	 accreditations.add(accreditation2);
		
	 Accreditation__c accreditation3 = new Accreditation__c(Accreditation_Type__c='Product',
										Accreditation_Date__c = date.today(),
										Accreditation_Level__c='Advanced',
										Partner__c=accounts[0].Id,
										Portfolio__c='IP Routing',
										Pricing_Cluster__c='NAM'
																				);
	 accreditations.add(accreditation3);
		
	 insert accreditations;
		 
	 //Create Product
	 List<Product2> prods = new List<Product2>();
	 Product2 prod1 = new product2(
			Name = 'Test1', 
			ProductCode = '123', 
			CurrencyIsoCode = 'USD',
			Portfolio__c = 'IP Routing',
			IsActive = true,
			Apttus_Config2__ConfigurationType__c = 'Standalone'
	 ); 
	 prods.add(prod1);
		
	 Product2 prod2 = new product2(
			Name = 'Maintenance Year1', 
			ProductCode = 'MT001', 
			Business_Group__c = 'NSW', 
			CurrencyIsoCode = 'USD',
			Portfolio__c = 'IP Routing',
			IsActive = true,
			Apttus_Config2__ConfigurationType__c = 'Standalone'
						
	 ); 
	 prods.add(prod2);
	 
	 Product2 prod3 = new product2(
			Name = 'SRS', 
			ProductCode = 'SRS001', 
			CurrencyIsoCode = 'USD',
			Portfolio__c = 'IP Routing',
			IsActive = true,
			Apttus_Config2__ConfigurationType__c = 'Standalone'		 
	 ); 
	 prods.add(prod3);
	 
	 Product2 prod4 = new product2(
			Name = 'SSP', 
			ProductCode = 'SSP002', 
			CurrencyIsoCode = 'USD',
			IsActive = true,
			NokiaCPQ_Product_Discount_Category__c = '7210 SAS-D ION',
			Apttus_Config2__ConfigurationType__c = 'Standalone'
	 ); 
	 prods.add(prod4);
	 
	 Product2 prod5 = new product2(
			Name = 'Maintenance Year2+', 
			ProductCode = 'MT002',  
			CurrencyIsoCode = 'USD',
			Portfolio__c = 'IP Routing',
			IsActive = true,
			NokiaCPQ_Product_Discount_Category__c ='NFM-P IPR',
			Apttus_Config2__ConfigurationType__c = 'Standalone' 
	 ); 
	 prods.add(prod5);
	   
	 Product2 prod6 = new product2(
			Name = 'prod6', 
			ProductCode = 'P6', 
			CurrencyIsoCode = 'USD',
			 Portfolio__c = 'IP Routing',
			IsActive = true,
			NokiaCPQ_Product_Discount_Category__c = '7210 SAS-D ION',
			Apttus_Config2__ConfigurationType__c = 'Standalone' 
	 ); 
	 prods.add(prod6);
	 insert prods;
		
	 //Create PriceList
		
	 Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
			Name = 'Commercial Price List', 
			Apttus_Config2__Active__c = True
	 );
	 insert ApttusTestPriceList;
		
	 //create price list items
	 List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
	 Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__ListPrice__c = 100, 
			Apttus_Config2__ProductId__c = prod1.Id, 
			Apttus_Config2__ChargeType__c = 'Standard Price'
	 );
	 //insert pLI1;
	 plistItems.add(pLI1);
		
		Apttus_Config2__PriceListItem__c pLI2 = new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
			Apttus_Config2__ListPrice__c = 200, 
			Apttus_Config2__ProductId__c = prod2.Id, 
			Apttus_Config2__ChargeType__c = 'Year 1 Maintenance'
		);
		//insert pLI2;
		plistItems.add(pLI2);
		
		Apttus_Config2__PriceListItem__c pLI3 = new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__ListPrice__c = 100, 
			Apttus_Config2__ProductId__c = prod3.Id, 
			Apttus_Config2__ChargeType__c = 'SRS'
		);
		//insert pLI1;
		plistItems.add(pLI3);
		
		Apttus_Config2__PriceListItem__c pLI4 = new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__ListPrice__c = 100, 
			Apttus_Config2__ProductId__c = prod4.Id, 
			Apttus_Config2__ChargeType__c = 'SSP'
		);
		//insert pLI1;
		plistItems.add(pLI4);
		
		 Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__ListPrice__c = 100, 
			Apttus_Config2__ProductId__c = prod5.Id, 
			Apttus_Config2__ChargeType__c = 'Maintenance for Y2 and Beyond'
		);
		//insert pLI1;
		plistItems.add(pLI5);
	   
	   
		 Apttus_Config2__PriceListItem__c pLI6 = new Apttus_Config2__PriceListItem__c(
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__ListPrice__c = 800, 
			Apttus_Config2__ProductId__c = prod6.Id, 
			Apttus_Config2__ChargeType__c = 'Standard Price'
		);
		//insert pLI1;
		plistItems.add(pLI6);
		insert plistItems;

		//create proposal
		Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(
			Apttus_Proposal__Account__c = accounts[0].Id,
			Apttus_Proposal__Opportunity__c = opportunities.get(0).Id,
			Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
			Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
			NokiaCPQ_Existing_IONMaint_Contract__c = 'No',
			NokiaCPQ_Existing_FN_Maint_Contract__c = 'No',
			NokiaCPQ_ION_Maintenance_Type__c = 'Gold',
			NokiaCPQ_FN_Maintenance_Type__c = 'Gold',
			NokiaCPQ_SSP_Level__c = 'Unlimited',
			NokiaCPQ_SRS_Level__c = 'Unlimited',
			NokiaCPQ_Maintenance_Type__c = 'Gold (Return for Exchange)',
			NokiaCPQ_Portfolio__c = 'IP Routing',
			NokiaCPQ_No_of_Years__c = '1',
			CurrencyIsoCode = Nokia_CPQ_Constants.USDCURRENCY,
			NokiaCPQ_LEO_Discount__c=false,
			Is_List_Price_Only__c =false,
			NokiaCPQ_Is_cloned__c = false,
			RecordTypeId =Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Draft Quote').getRecordTypeId(),
			isCQ__c = false
		   
		);
		insert testProposal;

		//create product configuration
		Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c(
			Name = 'APTTUS Test Config', 
			Apttus_Config2__AccountId__c = accounts[0].Id, 
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
			Apttus_QPConfig__Proposald__c = testProposal.Id, 
			Apttus_Config2__Status__c = 'New', 
			Apttus_Config2__VersionNumber__c = 1, 
			Apttus_Config2__EffectivePriceListId__c = ApttusTestPriceList.Id,
			Apttus_Config2__BusinessObjectId__c = String.valueOf(testProposal.Id),
			Apttus_Config2__BusinessObjectType__c = 'Proposal'
		);
		insert ProdConfig;
		
		 
		
		//Create Line Items
		list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
		Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 1,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = prod1.Id,
			Apttus_Config2__PriceListItemId__c = pLI1.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__BasePrice__c=4427,
			Apttus_Config2__ListPrice__c = 100,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PriceIncludedInBundle__c=false,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			is_Custom_Product__c =true,
			Custom_Product_Code__c='123',
			Apttus_Config2__AddedBy__c = 'added by code',
			Apttus_Config2__NetPrice__c=120,
			NokiaCPQ_SSP_Rate__c=120
		);
		//insert LineItem2;
		allLineItems.add(LineItem1);
		Apttus_Config2__LineItem__c LineItem2 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 2,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = prod6.Id,
			Apttus_Config2__PriceListItemId__c = pLI6.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__BasePrice__c=4427,
			Apttus_Config2__ListPrice__c = 200,
			Apttus_Config2__Quantity__c = 1,
			Apttus_Config2__PriceIncludedInBundle__c=false,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			is_Custom_Product__c =false,
			Apttus_Config2__AddedBy__c = 'added by code',
			Apttus_Config2__NetPrice__c=120,
			NokiaCPQ_SSP_Rate__c=120
		);
		//insert LineItem1;
		allLineItems.add(LineItem2);
		
		 Apttus_Config2__LineItem__c LineItem3 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 6,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			Apttus_Config2__ChargeType__c = 'SRS', 
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = prod3.Id,
			Apttus_Config2__PriceListItemId__c = pLI3.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			is_Custom_Product__c =false,										  
			Apttus_Config2__ListPrice__c = 120,
			Apttus_Config2__BasePrice__c=120,
			Apttus_Config2__Quantity__c = 1,
			Nokia_SRS_Base_Extended_Price__c = 80,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			
			
			Apttus_Config2__AddedBy__c = 'added by code'	 
		);
		//insert LineItem1;
		allLineItems.add(LineItem3);
		
		Apttus_Config2__LineItem__c LineItem4 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 3,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			Apttus_Config2__ChargeType__c = 'Year 1 Maintenance', 
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = prod2.Id,
			Apttus_Config2__PriceListItemId__c = pLI2.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			NokiaCPQ_Maint_Yr1_Extended_Price__c =  100,
			Apttus_Config2__ListPrice__c = 120,
			Apttus_Config2__BasePrice__c=120,
			Apttus_Config2__Quantity__c = 1,
			Custom_Product_Code__c=Nokia_CPQ_Constants.SRS,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			  is_Custom_Product__c =false,
			
			Apttus_Config2__AddedBy__c = 'added by code'	 
		);
		//insert LineItem1;
		allLineItems.add(LineItem4);
		
		Apttus_Config2__LineItem__c LineItem5 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 4,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			Apttus_Config2__ChargeType__c = 'SSP', 
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = prod4.Id,
			Apttus_Config2__PriceListItemId__c = pLI4.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
				is_Custom_Product__c =false,										  
			Apttus_Config2__ListPrice__c = 120,
			Apttus_Config2__BasePrice__c=120,
			Apttus_Config2__Quantity__c = 1,
			Nokia_SRS_Base_Extended_Price__c = 80,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			
			
			Apttus_Config2__AddedBy__c = 'added by code'	 
		);
		//insert LineItem1;
		allLineItems.add(LineItem5);
		
		Apttus_Config2__LineItem__c LineItem7 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 1,
			Apttus_Config2__LineNumber__c = 5,
			//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			Apttus_Config2__ChargeType__c = 'Maintenance for Y2 and Beyond', 
			Apttus_Config2__LineType__c = 'Product/Service',
			Apttus_Config2__ProductId__c = prod5.Id,
			Apttus_Config2__PriceListItemId__c = pLI5.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'Yearly',
			NokiaCPQ_Maint_Yr2_Extended_Price__c = 100,
			Apttus_Config2__ListPrice__c = 120,
			Apttus_Config2__BasePrice__c=120,
			Apttus_Config2__Quantity__c = 1,
			Nokia_SSP_Base_Extended_Price__c = 200,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = accounts[0].Id,
			  is_Custom_Product__c =false,
			
			Apttus_Config2__AddedBy__c = 'added by code'	 
		);
		//insert LineItem1;
		allLineItems.add(LineItem7);
		
		insert allLineItems;
		
		Test.startTest(); 
		
		Shipping_Location__c ship= new Shipping_Location__c();
		ship.Portfolio__c='Fixed Access - FBA';
		ship.Pricing_Cluster__c='NAM Canada';
		ship.Shipping_Location__c='Lewisville, Texas';
		insert ship; 
		
		Nokia_CPQ_Constants.PCBBEFOREPRICINGINADJ = 'False';
		Nokia_PricingCallBack obj = new Nokia_PricingCallBack();
		
		obj.setMode(Apttus_Config2.CustomClass.PricingMode.BASEPRICE);
		//Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
		Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);
		
		obj.setMode(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT);

		 Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);
	   }
		 Test.stopTest();
	} */ 
	
//FOr Direct Enterprise
static testMethod void directEnterprise() {
Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
custSetting.Apttus_Config2__PricingCallbackClass__c = 'Nokia_PricingCallBack';
custSetting.Name = 'Nokia_CallBack1';
insert custSetting;

Map < String, List < String >> maintenanceAccredMap = new Map < String, List < String >> (); 
Map < String, List < String >> productAccredMap = new Map < String, List < String >> ();
Nokia_PricingCallBack npc = new Nokia_PricingCallBack();

Custom_Constant_Field__c ccf = new Custom_Constant_Field__c();
ccf.Name = 'Custom Constant Field';

List<Opportunity> opportunities;
List<User> users = NF_TestDataFactory.getUsers(1,'System Administrator');
users[0].Nokia_ID__c = '234597';
insert users;


System.runAs(users[0]) {   

/************ Account Insertion  ***************/

List<Account> accountsNew = new List<Account>();
Account accLegalEntity = TestDataFactory.createAccount(1)[0];
accLegalEntity.AccountNumber='101234567';
accLegalEntity.Acc_No__c = '101234567';
accLegalEntity.GEOLevel1ID__c ='RG_NAM';
accLegalEntity.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
accountsNew.add(accLegalEntity);
//database.insert(accLegalEntity);

Account account = TestDataFactory.createAccount(1)[0];
account.AccountNumber='3011234567';
account.Acc_No__c = '3011234567';
account.GEOLevel1ID__c ='RG_NAM';
accountsNew.add(account);
//database.insert(account);

insert accountsNew;

List<Account> accounts=new List<Account>();
accounts.add(account);

//Create Opportunity
opportunities = NF_TestDataFactory.getOpportunities(1,accounts);
opportunities.get(0).Lead_BG__c = 'NSW';
opportunities.get(0).RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();

insert opportunities.get(0);


//Create Product
List<Product2> prods = new List<Product2>();
Product2 prod1 = new product2(
Name = 'Test1', 
ProductCode = '123', 
//Business_Group__c = 'ION', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'IP Routing',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Bundle',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Base',
NokiaCPQ_Product_Discount_Category__c = 'NSD-NRC IPR'
); 
prods.add(prod1);

Product2 prod2 = new product2(
Name = 'Maintenance Year1', 
ProductCode = 'MT001', 
//Business_Group__c = 'NSW', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'IP Routing',
IsActive = true,
NokiaCPQ_Product_Discount_Category__c = 'NSD-NRC IPR',
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Base'); 
prods.add(prod2);

Product2 prod4 = new product2(
Name = 'SSP', 
ProductCode = 'SSP002', 
Business_Group__c = 'NSW', 
CurrencyIsoCode = 'USD',
IsActive = true,
NokiaCPQ_Product_Discount_Category__c = 'NSD-NRC IPR',
Apttus_Config2__ConfigurationType__c = 'Standalone'
); 
prods.add(prod4);   
Product2 prod5 = new product2(
Name = 'Maintenance Year2+', 
ProductCode = 'MT002', 
Business_Group__c = 'NSW', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'IP Routing',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Product_Discount_Category__c = 'NSD-NRC IPR'
); 
prods.add(prod5);

Product2 prod6 = new product2(
Name = 'Bundle', 
ProductCode = '123', 
//Business_Group__c = 'ION', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'IP Routing',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Base',
NokiaCPQ_Product_Discount_Category__c = 'NSD-NRC IPR'
); 
prods.add(prod6);

insert prods;

//Create PriceList
List<Apttus_Config2__PriceList__c> priceLists = new List<Apttus_Config2__PriceList__c>();
Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
Name = 'Commercial Price List', 
Apttus_Config2__Active__c = True, PriceList_Type__c = 'CPQ'
);
priceLists.add(ApttusTestPriceList);
Apttus_Config2__PriceList__c ApttusTestPriceList2 = new Apttus_Config2__PriceList__c(
Name = 'CLP', 
Apttus_Config2__Active__c = True, PriceList_Type__c = 'Direct'
);
priceLists.add(ApttusTestPriceList2);
insert priceLists;

//create price list items
List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod1.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price',
Apttus_Config2__Cost__c = 10
);
plistItems.add(pLI1);

Apttus_Config2__PriceListItem__c pLI2 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
Apttus_Config2__ListPrice__c = 200, 
Apttus_Config2__ProductId__c = prod2.Id, 
Apttus_Config2__PriceIncludedInBundle__c = true,
Apttus_Config2__ChargeType__c = 'Maintenance Year1',
Apttus_Config2__Cost__c = 10
);
//insert pLI2;
plistItems.add(pLI2);

Apttus_Config2__PriceListItem__c pLI4 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod4.Id, 
Apttus_Config2__ChargeType__c = 'SSP',
Apttus_Config2__Cost__c = 10
);
//insert pLI1;
plistItems.add(pLI4);

Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod5.Id, 
Apttus_Config2__ChargeType__c = 'Maintenance Year2+',
Apttus_Config2__Cost__c = 10
);
plistItems.add(pLI5);

Apttus_Config2__PriceListItem__c pLI6 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod6.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price',
Apttus_Config2__Cost__c = 10
);
plistItems.add(pLI6);

Apttus_Config2__PriceListItem__c pLI7 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList2.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod6.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price',
Apttus_Config2__Cost__c = 10
);
plistItems.add(pLI7);

insert plistItems;

Product_Discount__c disc = new Product_Discount__c ();
disc.Discount__c = 8.00;
disc.Market__c = account.Market__c;
disc.Product_Discount_Category__c = 'NFM-P';
insert disc;

//create proposal
Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(
Apttus_Proposal__Opportunity__c = opportunities.get(0).Id,
Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
NokiaCPQ_Portfolio__c = 'IP Routing',
NokiaCPQ_No_of_Years__c = '3',
NokiaCPQ_Maintenance_Type__c='Gold (Return for Exchange)',
RecordTypeId =Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),//direct	Prices_Aligned__c=true,
Apttus_Proposal__Account__c=accLegalEntity.id,
Sold_To_Party__c = accLegalEntity.id,
Is_List_Price_Only__c =false,
NokiaCPQ_Existing_IONMaint_Contract__c = 'No'
);
insert testProposal;


system.debug('testProposal:'+testProposal);

//create product configuration
Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c(
Name = 'APTTUS Test Config', 
Apttus_Config2__AccountId__c = account.Id, 
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
Apttus_QPConfig__Proposald__c = testProposal.Id, 
Apttus_Config2__Status__c = 'New', 
Apttus_Config2__VersionNumber__c = 1, 
Apttus_Config2__EffectivePriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__BusinessObjectId__c = String.valueOf(testProposal.Id),
Apttus_Config2__BusinessObjectType__c = 'Proposal'
);
insert ProdConfig;

//Create Line Items
list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();

Apttus_Config2__LineItem__c LineItem3 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 1,
//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__PriceListItemId__c = pLI1.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__ListPrice__c = 300,
Apttus_Config2__BasePrice__c = 300,
Apttus_Config2__Quantity__c = 1,
is_Custom_Product__c=false,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
Advanced_pricing_done__c = false,

Apttus_Config2__AddedBy__c = 'added by code'
);
//insert LineItem1;
allLineItems.add(LineItem3);

Apttus_Config2__LineItem__c LineItem4 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 2,
//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Maintenance Year1', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod2.Id,
Apttus_Config2__PriceListItemId__c = pLI2.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
NokiaCPQ_Maint_Yr1_Extended_Price__c =  100,
Apttus_Config2__ListPrice__c = 120,
Apttus_Config2__BasePrice__c = 120,
Apttus_Config2__Quantity__c = 1,
Apttus_Config2__PriceIncludedInBundle__c = true,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
is_Custom_Product__c=false,
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__AddedBy__c = 'added by code',
Advanced_pricing_done__c = false			
);
//insert LineItem1;
allLineItems.add(LineItem4);


Apttus_Config2__LineItem__c LineItem6 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 3,
//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'SSP', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod4.Id,
Apttus_Config2__PriceListItemId__c = pLI4.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePrice__c = 120,
Apttus_Config2__ListPrice__c = 120,
Apttus_Config2__Quantity__c = 1,
Nokia_SSP_Base_Extended_Price__c = 90,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
Advanced_pricing_done__c = false,

Apttus_Config2__AddedBy__c = 'added by code'	 
);
//insert LineItem1;
allLineItems.add(LineItem6);

Apttus_Config2__LineItem__c LineItem7 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 4,
//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Maintenance Year2+', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod5.Id,
Apttus_Config2__PriceListItemId__c = pLI5.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'Yearly',
NokiaCPQ_Maint_Yr2_Extended_Price__c = 100,
Apttus_Config2__ListPrice__c = 120,
Apttus_Config2__BasePrice__c = 120,
Apttus_Config2__Quantity__c = 1,
Nokia_SSP_Base_Extended_Price__c = 200,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
Advanced_pricing_done__c = false,

Apttus_Config2__AddedBy__c = 'added by code'	 
);
//insert LineItem1;
allLineItems.add(LineItem7);

Apttus_Config2__LineItem__c LineItem8 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__OptionId__c = prod6.Id,
Apttus_Config2__ParentBundleNumber__c = 1,
Apttus_Config2__PriceListItemId__c = pLI7.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__ListPrice__c = 300,
Apttus_Config2__BasePrice__c = 300,
Apttus_Config2__Quantity__c = 1,
is_Custom_Product__c=false,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
Advanced_pricing_done__c = false,

Apttus_Config2__AddedBy__c = 'added by code'
);
//insert LineItem1;
allLineItems.add(LineItem8);

insert allLineItems;

Test.startTest(); 

CPQ_Maintenance_and_SSP_Rule__c rec1 = new CPQ_Maintenance_and_SSP_Rule__c();
rec1.Maintenance_Level__c = 'Nokia Brand of Service';
rec1.Maintenance_Type__c = 'Gold (Return for Exchange)';
rec1.Region__c = 'RG_NAM';
rec1.Service_Rate_Y1__c = 0.05;
rec1.Service_Rate_Y2__c = 0.05;
rec1.Unlimited_SSP_Discount__c = 0.03; 
rec1.Maintenance_Category__c = 'NSD-NRC IPR';
insert rec1;
list<NokiaCPQ_Maintenance_and_SSP_Rules__c> listMaintSSPRule =  [SELECT NokiaCPQ_withPMA__c, NokiaCPQ_Pricing_Cluster__c, NokiaCPQ_Product_Discount_Category__c, NokiaCPQ_Product_Discount_Category_per__c, NokiaCPQ_Unlimited_SSP_Discount__c, NokiaCPQ_Biennial_SSP_Discount__c, NokiaCPQ_Maintenance_Level__c, NokiaCPQ_Maintenance_Type__c, NokiaCPQ_Service_Rate_Y1__c, NokiaCPQ_Service_Rate_Y2__c FROM NokiaCPQ_Maintenance_and_SSP_Rules__c ]; 
Nokia_PricingCallBack obj = new Nokia_PricingCallBack();

obj.setMode(Apttus_Config2.CustomClass.PricingMode.BASEPRICE);
Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);

obj.setMode(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT);
//obj.finish();

Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);

//Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
}
Test.stopTest();
}
//method for Indirect Quotes

static testMethod void DirectMethod1() {
	Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
custSetting.Apttus_Config2__PricingCallbackClass__c = 'Nokia_PricingCallBack';
custSetting.Name = 'Nokia_CallBack1';
insert custSetting;

Nokia_PricingCallBack npc = new Nokia_PricingCallBack();

List<Opportunity> opportunities;
List<Accreditation__c> accreditations = new List<Accreditation__c>();
List<User> users = NF_TestDataFactory.getUsers(1,'System Administrator');
users[0].Nokia_ID__c = '234597';
insert users;


System.runAs(users[0]) {

List<Account> accountsNew = new List<Account>();
Account accLegalEntity = TestDataFactory.createAccount(1)[0];
accLegalEntity.AccountNumber='101234567';
accLegalEntity.Acc_No__c = '101234567';
accLegalEntity.GeoLevel1Id__c = 'RG_NAM';
accLegalEntity.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
accountsNew.add(accLegalEntity);

Account account = TestDataFactory.createAccount(1)[0];
account.AccountNumber='3011234567';
account.Acc_No__c = '3011234567';
account.GeoLevel1Id__c = 'RG_NAM';
accountsNew.add(account);

insert accountsNew;


List<Account> accounts=new List<Account>();
accounts.add(account);

//Create Opportunity
opportunities = NF_TestDataFactory.getOpportunities(1,accounts);
opportunities.get(0).Lead_BG__c = 'NSW';
opportunities.get(0).RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();

insert opportunities.get(0);


//Create Product
List<Product2> prods = new List<Product2>();

Product2 prod1 = new product2(
Name = 'Test1', 
ProductCode = '123',
CurrencyIsoCode = 'USD',
Portfolio__c = 'Airscale Wifi',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Bundle',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Base'	   
); 
prods.add(prod1);

Product2 prod2 = new product2(
Name = 'Maintenance Year1', 
ProductCode = 'MT001', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'IP Routing',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Base'); 
prods.add(prod2);

Product2 prod3 = new product2(
Name = 'Test2', 
ProductCode = '1234',  
CurrencyIsoCode = 'USD',
Portfolio__c = 'Airscale Wifi',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Base'
); 
prods.add(prod3);

Product2 prod5 = new product2(
Name = 'Maintenance Year2+', 
ProductCode = 'MT002', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'IP Routing',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone'
); 
prods.add(prod5); 

Product2 prod6 = new product2(
Name = 'Test1Arcadia', 
ProductCode = '123Arcadia',
CurrencyIsoCode = 'USD',
Portfolio__c = 'Airscale Wifi',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Bundle',
NokiaCPQ_Item_Type__c='Hardware',
NokiaCPQ_Classification2__c='Base'	   
); 
prods.add(prod6);   

Product2 prod7 = new product2(
Name = 'Test2Arcadia', 
ProductCode = 'Arcadia2',
CurrencyIsoCode = 'USD',
Portfolio__c = 'Airscale Wifi',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Hardware',
NokiaCPQ_Classification2__c='Base'	   
); 
prods.add(prod7); 


Product2 prod8 = new product2(
Name = '12678', 
ProductCode = '12678',
CurrencyIsoCode = 'USD',
Portfolio__c = 'Airscale Wifi',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Hardware',
NokiaCPQ_Classification2__c='Base'	   
); 
prods.add(prod8); 

insert prods;

//Create PriceList

Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
Name = 'Commercial Price List', 
Apttus_Config2__Active__c = True, PriceList_Type__c = 'CPQ'
);
insert ApttusTestPriceList;

//create price list items
List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod1.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price'
);
//insert pLI1;
plistItems.add(pLI1);

Apttus_Config2__PriceListItem__c pLI2 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
Apttus_Config2__ListPrice__c = 200, 
Apttus_Config2__ProductId__c = prod2.Id, 
Apttus_Config2__PriceIncludedInBundle__c = false,
Apttus_Config2__ChargeType__c = 'Year 1 Maintenance'
);
//insert pLI2;
plistItems.add(pLI2);

Apttus_Config2__PriceListItem__c pLI3 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod3.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price',
Apttus_Config2__PriceIncludedInBundle__c = false,
Apttus_Config2__ContractPrice__c = 100
);
//insert pLI1;
plistItems.add(pLI3);


Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod5.Id, 
Apttus_Config2__ChargeType__c = 'Maintenance for Y2 & Beyond'
);
//insert pLI1;
plistItems.add(pLI5);

Apttus_Config2__PriceListItem__c pLI6 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod6.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price',
Apttus_Config2__PriceIncludedInBundle__c = false,
Apttus_Config2__ContractPrice__c = 100
);
//insert pLI1;
plistItems.add(pLI6);

Apttus_Config2__PriceListItem__c pLI7 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod7.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price',
Apttus_Config2__PriceIncludedInBundle__c = false,
Apttus_Config2__ContractPrice__c = 100
);
//insert pLI1;
plistItems.add(pLI7);

Apttus_Config2__PriceListItem__c pLI8 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod8.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price',
Apttus_Config2__PriceIncludedInBundle__c = false,
Apttus_Config2__ContractPrice__c = 100
);
//insert pLI1;
plistItems.add(pLI8);

insert plistItems;


//create proposal
Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(
Apttus_Proposal__Opportunity__c = opportunities.get(0).Id,
Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
NokiaCPQ_Portfolio__c = 'Airscale Wifi',
NokiaCPQ_No_of_Years__c = '4',
NokiaCPQ_Maintenance_Type__c='MN GS TSS Enhanced Emergency',
RecordTypeId =Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),//direct	Prices_Aligned__c=true,
Apttus_Proposal__Account__c=accLegalEntity.id,
Sold_To_Party__c = accLegalEntity.id,
Is_List_Price_Only__c =false
);
insert testProposal;


system.debug('testProposal:'+testProposal);

//create product configuration
Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c(
Name = 'APTTUS Test Config', 
Apttus_Config2__AccountId__c = account.Id, 
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
Apttus_QPConfig__Proposald__c = testProposal.Id, 
Apttus_Config2__Status__c = 'New', 
Apttus_Config2__VersionNumber__c = 1, 
Apttus_Config2__EffectivePriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__BusinessObjectId__c = String.valueOf(testProposal.Id),
Apttus_Config2__BusinessObjectType__c = 'Proposal'
);
insert ProdConfig;

//Create Line Items
list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__PriceListItemId__c = pLI1.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePrice__c=100,
Apttus_Config2__ListPrice__c = 100,
Apttus_Config2__Quantity__c = 1,
Source__c='',
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
is_Custom_Product__c=false,
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__AddedBy__c = 'added by code',
NokiaCPQ_Unitary_IRP__c = 300,
NokiaCPQ_Product_Type__c='Controller'

);
//insert LineItem2;
allLineItems.add(LineItem1);

Apttus_Config2__LineItem__c LineItem3 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 2,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__OptionId__c = prod6.Id,
Apttus_Config2__ParentBundleNumber__c = 1,
Apttus_Config2__PriceListItemId__c = pLI6.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__ListPrice__c = 300,
Apttus_Config2__BasePrice__c=300,
Apttus_Config2__Quantity__c = 1,
is_Custom_Product__c=false,
Apttus_Config2__PrimaryLineNumber__c = 2,
Apttus_Config2__ShipToAccountId__c = account.Id,
NokiaCPQ_Product_Type__c = 'Access Point',			
Apttus_Config2__AddedBy__c = 'added by code',
Apttus_Config2__AdjustmentType__c = '% Discount',
NokiaCPQ_Unitary_IRP__c = 1300,
Apttus_Config2__AdjustmentAmount__c = 10
);
//insert LineItem1;
allLineItems.add(LineItem3);

Apttus_Config2__LineItem__c LineItem4 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 3,
Apttus_Config2__LineNumber__c = 2,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Year 1 Maintenance', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod2.Id,
Apttus_Config2__PriceListItemId__c = pLI2.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
NokiaCPQ_Maint_Yr1_Extended_Price__c =  100,
Apttus_Config2__ListPrice__c = 120,
Apttus_Config2__BasePrice__c=120,
Apttus_Config2__Quantity__c = 1,
Apttus_Config2__PriceIncludedInBundle__c = true,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
is_Custom_Product__c=false,
Apttus_Config2__BasePriceOverride__c=120,
NokiaCPQ_Unitary_IRP__c = 400,
Apttus_Config2__AddedBy__c = 'added by code'	 
);
//insert LineItem1;
allLineItems.add(LineItem4);

Apttus_Config2__LineItem__c LineItem5 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 4,
Apttus_Config2__LineNumber__c = 3,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Maintenance for Y2 & Beyond', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod5.Id,
Apttus_Config2__PriceListItemId__c = pLI5.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
NokiaCPQ_Maint_Yr1_Extended_Price__c =  100,
Apttus_Config2__ListPrice__c = 120,
Apttus_Config2__BasePrice__c=120,
Apttus_Config2__Quantity__c = 1,
Apttus_Config2__PriceIncludedInBundle__c = true,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
is_Custom_Product__c=false,
Apttus_Config2__BasePriceOverride__c=120,
NokiaCPQ_Unitary_IRP__c = 300,
Apttus_Config2__AddedBy__c = 'added by code'	 
);
//insert LineItem1;
allLineItems.add(LineItem5);

Apttus_Config2__LineItem__c LineItem6 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 5,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod6.Id,
Apttus_Config2__OptionId__c = prod3.Id,
Apttus_Config2__ParentBundleNumber__c = 2,
Apttus_Config2__PriceListItemId__c = pLI3.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__ListPrice__c = 300,
Apttus_Config2__BasePrice__c=300,
Apttus_Config2__Quantity__c = 1,
is_Custom_Product__c=false,
Apttus_Config2__PrimaryLineNumber__c = 3,
NokiaCPQ_Unitary_IRP__c = 300,
Apttus_Config2__ShipToAccountId__c = account.Id,


Apttus_Config2__AddedBy__c = 'added by code'
);
//insert LineItem1;
allLineItems.add(LineItem6);

Apttus_Config2__LineItem__c LineItem7 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 6,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__OptionId__c = prod7.Id,
Apttus_Config2__ParentBundleNumber__c = 1,
Apttus_Config2__PriceListItemId__c = pLI7.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__ListPrice__c = 300,
Apttus_Config2__BasePrice__c=300,
Apttus_Config2__Quantity__c = 1,
is_Custom_Product__c=false,
Apttus_Config2__PrimaryLineNumber__c = 2,
Apttus_Config2__ShipToAccountId__c = account.Id,
NokiaCPQ_Product_Type__c = 'Controller',			
Apttus_Config2__AddedBy__c = 'added by code',
NokiaCPQ_Unitary_IRP__c = 100,
Apttus_Config2__AdjustmentType__c = 'Discount Amount',
Apttus_Config2__AdjustmentAmount__c = 100
);
//insert LineItem1;
allLineItems.add(LineItem7);

Apttus_Config2__LineItem__c LineItem8 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 2,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod6.Id,
Apttus_Config2__OptionId__c = prod8.Id,
Apttus_Config2__ParentBundleNumber__c = 2,
Apttus_Config2__PriceListItemId__c = pLI8.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__ListPrice__c = 300,
Apttus_Config2__BasePrice__c=300,
Apttus_Config2__Quantity__c = 1,
is_Custom_Product__c=false,
Apttus_Config2__PrimaryLineNumber__c = 3,
Apttus_Config2__ShipToAccountId__c = account.Id,
NokiaCPQ_Unitary_IRP__c = 600,
NokiaCPQ_Product_Type__c = 'Third Party Wavespot',  

Apttus_Config2__AddedBy__c = 'added by code'
);
allLineItems.add(LineItem8);

insert allLineItems;


Test.startTest(); 

Nokia_PricingCallBack obj = new Nokia_PricingCallBack();

obj.setMode(Apttus_Config2.CustomClass.PricingMode.BASEPRICE);
Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);

obj.setMode(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT);

Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);

obj.finish();
Nokia_PricingCallBack.calculateEquivalentPrice(allLineItems, 'Market India');

testProposal.NokiaCPQ_No_of_Years__c = '1';
testProposal.NokiaCPQ_Maintenance_Type__c='MN GS TSS Enhanced';
update testProposal;

Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);

}
Test.stopTest();
}

static testMethod void AirscalewifisoftwareMethod() {
Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
custSetting.Apttus_Config2__PricingCallbackClass__c = 'Nokia_PricingCallBack';
custSetting.Name = 'Nokia_CallBack1';
insert custSetting;

Nokia_PricingCallBack npc = new Nokia_PricingCallBack();

List<Opportunity> opportunities;
List<Accreditation__c> accreditations = new List<Accreditation__c>();
List<User> users = NF_TestDataFactory.getUsers(1,'System Administrator');
users[0].Nokia_ID__c = '234597';
insert users;


System.runAs(users[0]) {
		
List<Account> accountsNew = new List<Account>();
Account accLegalEntity = TestDataFactory.createAccount(1)[0];
accLegalEntity.AccountNumber='101234567';
accLegalEntity.Acc_No__c = '101234567';
accLegalEntity.GeoLevel1Id__c = 'RG_NAM';
accLegalEntity.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
accountsNew.add(accLegalEntity);

Account account = TestDataFactory.createAccount(1)[0];
account.AccountNumber='3011234567';
account.Acc_No__c = '3011234567';
account.GeoLevel1Id__c = 'RG_NAM';
accountsNew.add(account);

insert accountsNew;


List<Account> accounts=new List<Account>();
accounts.add(account);

//Create Opportunity
opportunities = NF_TestDataFactory.getOpportunities(1,accounts);
opportunities.get(0).Lead_BG__c = 'NSW';
opportunities.get(0).RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();

insert opportunities.get(0);


//Create Product
List<Product2> prods = new List<Product2>();

Product2 prod1 = new product2(
Name = 'Test1', 
ProductCode = '123',
CurrencyIsoCode = 'USD',
Portfolio__c = 'Airscale Wifi',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Bundle',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Base'	   
); 
prods.add(prod1);


Product2 prod7 = new product2(
Name = 'Test2Arcadia', 
ProductCode = 'Arcadia2',
CurrencyIsoCode = 'USD',
Portfolio__c = 'Airscale Wifi',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Hardware',
NokiaCPQ_Classification2__c='Base'	   
); 
prods.add(prod7); 

insert prods;

//Create PriceList

Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
Name = 'Commercial Price List', 
Apttus_Config2__Active__c = True, PriceList_Type__c = 'CPQ'
);
insert ApttusTestPriceList;

//create price list items
List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod1.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price'
);
plistItems.add(pLI1);

Apttus_Config2__PriceListItem__c pLI7 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod7.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price',
Apttus_Config2__PriceIncludedInBundle__c = false,
Apttus_Config2__ContractPrice__c = 100
);
plistItems.add(pLI7);

insert plistItems;

Product_Discount__c disc = new Product_Discount__c ();
disc.Discount__c = 8.00;
disc.Market__c = account.Market__c;
disc.Product_Discount_Category__c = 'NFM-P';
insert disc;

//create proposal
Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(
Apttus_Proposal__Opportunity__c = opportunities.get(0).Id,
Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
NokiaCPQ_Portfolio__c = Nokia_CPQ_Constants.AIRSCALE_WIFI_STRING,
NokiaCPQ_Maintenance_Type__c = 'MN GS TSS Enhanced Emergency',
NokiaCPQ_No_of_Years__c = '1',
RecordTypeId =Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),//direct	Prices_Aligned__c=true,
Apttus_Proposal__Account__c=accLegalEntity.id,
Sold_To_Party__c = accLegalEntity.id,
Is_List_Price_Only__c =false
);
insert testProposal;


system.debug('testProposal:'+testProposal);

//create product configuration
Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c(
Name = 'APTTUS Test Config', 
Apttus_Config2__AccountId__c = account.Id, 
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
Apttus_QPConfig__Proposald__c = testProposal.Id, 
Apttus_Config2__Status__c = 'New', 
Apttus_Config2__VersionNumber__c = 1, 
Apttus_Config2__EffectivePriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__BusinessObjectId__c = String.valueOf(testProposal.Id),
Apttus_Config2__BusinessObjectType__c = 'Proposal'
);
insert ProdConfig;

//Create Line Items
list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__PriceListItemId__c = pLI1.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePrice__c=100,
Apttus_Config2__ListPrice__c = 100,
Apttus_Config2__Quantity__c = 1,
Source__c='',
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
is_Custom_Product__c=false,
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__AddedBy__c = 'added by code',
NokiaCPQ_Product_Type__c='Controller'

);
//insert LineItem2;
allLineItems.add(LineItem1);

Apttus_Config2__LineItem__c LineItem3 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
Apttus_Config2__ItemSequence__c = 2,
Apttus_Config2__LineNumber__c = 1,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Option',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__OptionId__c = prod7.Id,
Apttus_Config2__ParentBundleNumber__c = 1,
Apttus_Config2__PriceListItemId__c = pLI7.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__ListPrice__c = 300,
Apttus_Config2__BasePrice__c=300,
Apttus_Config2__Quantity__c = 1,
is_Custom_Product__c=false,
Apttus_Config2__PrimaryLineNumber__c = 2,
Apttus_Config2__ShipToAccountId__c = account.Id,
NokiaCPQ_Product_Type__c = 'Access Point',			
Apttus_Config2__AddedBy__c = 'added by code',
Apttus_Config2__AdjustmentType__c = '% Discount',
Apttus_Config2__AdjustmentAmount__c = 10
);
allLineItems.add(LineItem3);

insert allLineItems;

Test.startTest(); 

Nokia_PricingCallBack obj = new Nokia_PricingCallBack();

obj.setMode(Apttus_Config2.CustomClass.PricingMode.BASEPRICE);
Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);

obj.setMode(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT);



Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);
obj.finish();

Nokia_PricingCallBack.calculateEquivalentPrice(allLineItems, 'Market India');


//Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
//Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);

}
Test.stopTest();
}

static testMethod void directEnterpriseMethod() {
Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
custSetting.Apttus_Config2__PricingCallbackClass__c = 'Nokia_PricingCallBack';
custSetting.Name = 'Nokia_CallBack1';
insert custSetting;

Map < String, List < String >> maintenanceAccredMap = new Map < String, List < String >> (); 
Map < String, List < String >> productAccredMap = new Map < String, List < String >> ();
Nokia_PricingCallBack npc = new Nokia_PricingCallBack();

Custom_Constant_Field__c ccf = new Custom_Constant_Field__c();
ccf.Name = 'Custom Constant Field';

List<Opportunity> opportunities;
List<User> users = NF_TestDataFactory.getUsers(1,'System Administrator');
users[0].Nokia_ID__c = '234597';
insert users;


System.runAs(users[0]) {   

/************ Account Insertion  ***************/

List<Account> accountsNew = new List<Account>();
Account accLegalEntity = TestDataFactory.createAccount(1)[0];
accLegalEntity.AccountNumber='101234567';
accLegalEntity.Acc_No__c = '101234567';
accLegalEntity.GEOLevel1ID__c ='RG_NAM';
accLegalEntity.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
accountsNew.add(accLegalEntity);
//database.insert(accLegalEntity);

Account account = TestDataFactory.createAccount(1)[0];
account.AccountNumber='3011234567';
account.Acc_No__c = '3011234567';
account.GEOLevel1ID__c ='RG_NAM';
accountsNew.add(account);
//database.insert(account);

insert accountsNew;

List<Account> accounts=new List<Account>();
accounts.add(account);

//Create Opportunity
opportunities = NF_TestDataFactory.getOpportunities(1,accounts);
opportunities.get(0).Lead_BG__c = 'NSW';
opportunities.get(0).RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();

insert opportunities.get(0);


//Create Product
List<Product2> prods = new List<Product2>();
Product2 prod1 = new product2(
Name = 'Test1', 
ProductCode = '123', 
//Business_Group__c = 'ION', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'IP Routing',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Bundle',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Base',
NokiaCPQ_Product_Discount_Category__c = 'NSD-NRC IPR'
); 
prods.add(prod1);

Product2 prod2 = new product2(
Name = 'Maintenance Year1', 
ProductCode = 'MT001', 
//Business_Group__c = 'NSW', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'IP Routing',
IsActive = true,
NokiaCPQ_Product_Discount_Category__c = 'NSD-NRC IPR',
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Base'); 
prods.add(prod2);

Product2 prod3 = new product2(
Name = 'SSP', 
ProductCode = 'SSP002', 
Business_Group__c = 'NSW', 
CurrencyIsoCode = 'USD',
IsActive = true,
NokiaCPQ_Product_Discount_Category__c = 'NSD-NRC IPR',
Apttus_Config2__ConfigurationType__c = 'Standalone'
); 
prods.add(prod3);   
Product2 prod4 = new product2(
Name = 'Maintenance Year2+', 
ProductCode = 'MT002', 
Business_Group__c = 'NSW', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'IP Routing',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Product_Discount_Category__c = 'NSD-NRC IPR'
); 
prods.add(prod4);

Product2 prod5 = new product2(
Name = 'SRS', 
ProductCode = 'SRS002', 
//Business_Group__c = 'ION', 
CurrencyIsoCode = 'USD',
Portfolio__c = 'IP Routing',
IsActive = true,
Apttus_Config2__ConfigurationType__c = 'Standalone',
NokiaCPQ_Item_Type__c='Software',
NokiaCPQ_Classification2__c='Base',
NokiaCPQ_Product_Discount_Category__c = 'NSD-NRC IPR'
); 
prods.add(prod5);

insert prods;

//Create PriceList
List<Apttus_Config2__PriceList__c> priceLists = new List<Apttus_Config2__PriceList__c>();
Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
Name = 'Commercial Price List', 
Apttus_Config2__Active__c = True, PriceList_Type__c = 'CPQ'
);
priceLists.add(ApttusTestPriceList);
Apttus_Config2__PriceList__c ApttusTestPriceList2 = new Apttus_Config2__PriceList__c(
Name = 'CLP', 
Apttus_Config2__Active__c = True, PriceList_Type__c = 'Direct'
);
priceLists.add(ApttusTestPriceList2);
insert priceLists;

//create price list items
List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod1.Id, 
Apttus_Config2__ChargeType__c = 'Standard Price',
Apttus_Config2__Cost__c = 10
);
plistItems.add(pLI1);

Apttus_Config2__PriceListItem__c pLI2 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
Apttus_Config2__ListPrice__c = 200, 
Apttus_Config2__ProductId__c = prod2.Id, 
Apttus_Config2__PriceIncludedInBundle__c = true,
Apttus_Config2__ChargeType__c = 'Maintenance Year1',
Apttus_Config2__Cost__c = 10
);
//insert pLI2;
plistItems.add(pLI2);

Apttus_Config2__PriceListItem__c pLI3 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod3.Id, 
Apttus_Config2__ChargeType__c = 'SSP',
Apttus_Config2__Cost__c = 10
);
//insert pLI1;
plistItems.add(pLI3);

Apttus_Config2__PriceListItem__c pLI4 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod4.Id, 
Apttus_Config2__ChargeType__c = 'Maintenance Year2+',
Apttus_Config2__Cost__c = 10
);
plistItems.add(pLI4);

Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__ListPrice__c = 100, 
Apttus_Config2__ProductId__c = prod5.Id, 
Apttus_Config2__ChargeType__c = 'SRS',
Apttus_Config2__Cost__c = 10
);
plistItems.add(pLI5);

insert plistItems;

Product_Discount__c disc = new Product_Discount__c ();
disc.Discount__c = 8.00;
disc.Market__c = account.Market__c;
disc.Product_Discount_Category__c = 'NFM-P';
insert disc;

//create proposal
Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(
Apttus_Proposal__Opportunity__c = opportunities.get(0).Id,
Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
NokiaCPQ_Portfolio__c = 'IP Routing',
NokiaCPQ_No_of_Years__c = '3',
NokiaCPQ_Maintenance_Type__c='Gold (Return for Exchange)',
RecordTypeId =Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),//direct	Prices_Aligned__c=true,
Apttus_Proposal__Account__c=accLegalEntity.id,
Sold_To_Party__c = accLegalEntity.id,
Is_List_Price_Only__c =false,

NokiaCPQ_Existing_IONMaint_Contract__c = 'No'
);
insert testProposal;


system.debug('testProposal:'+testProposal);

//create product configuration
list<Apttus_Config2__ProductConfiguration__c> ProdConfigList = new list<Apttus_Config2__ProductConfiguration__c>();
Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c(
Name = 'APTTUS Test Config', 
Apttus_Config2__AccountId__c = account.Id, 
Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
Apttus_QPConfig__Proposald__c = testProposal.Id, 
Apttus_Config2__Status__c = 'New', 
Apttus_Config2__VersionNumber__c = 1, 
Apttus_Config2__EffectivePriceListId__c = ApttusTestPriceList.Id,
Apttus_Config2__BusinessObjectId__c = String.valueOf(testProposal.Id),
Apttus_Config2__BusinessObjectType__c = 'Proposal'
);
insert ProdConfig;
ProdConfigList.add(ProdConfig);
//Create Line Items
list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();

Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfigList[0].Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 1,
//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Standard Price', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod1.Id,
Apttus_Config2__PriceListItemId__c = pLI1.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__ListPrice__c = 300,
Apttus_Config2__BasePrice__c = 300,
Apttus_Config2__Quantity__c = 1,
is_Custom_Product__c=false,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
Advanced_pricing_done__c = false,

Apttus_Config2__AddedBy__c = 'added by code'
);

allLineItems.add(LineItem1);

Apttus_Config2__LineItem__c LineItem2 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfigList[0].Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 2,
//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Maintenance Year1', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod2.Id,
Apttus_Config2__PriceListItemId__c = pLI2.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
NokiaCPQ_Maint_Yr1_Extended_Price__c =  100,
Apttus_Config2__ListPrice__c = 120,
Apttus_Config2__BasePrice__c = 120,
Apttus_Config2__Quantity__c = 1,
Apttus_Config2__PriceIncludedInBundle__c = true,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
is_Custom_Product__c=false,
Apttus_Config2__BasePriceOverride__c=120,
Apttus_Config2__AddedBy__c = 'added by code',
Advanced_pricing_done__c = false			
);

allLineItems.add(LineItem2);


Apttus_Config2__LineItem__c LineItem3 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfigList[0].Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 3,
//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'SSP', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod3.Id,
Apttus_Config2__PriceListItemId__c = pLI3.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'One Time',
Apttus_Config2__BasePrice__c = 120,
Apttus_Config2__ListPrice__c = 120,
Apttus_Config2__Quantity__c = 1,
Nokia_SSP_Base_Extended_Price__c = 90,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
Advanced_pricing_done__c = false,
is_Custom_Product__c=false,
Apttus_Config2__AddedBy__c = 'added by code'	 
);

allLineItems.add(LineItem3);

Apttus_Config2__LineItem__c LineItem4 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfigList[0].Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 4,
//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'Maintenance Y2+', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod4.Id,
Apttus_Config2__PriceListItemId__c = pLI4.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'Yearly',
NokiaCPQ_Maint_Yr2_Extended_Price__c = 100,
Apttus_Config2__ListPrice__c = 120,
Apttus_Config2__BasePrice__c = 120,
Apttus_Config2__Quantity__c = 1,
Nokia_SSP_Base_Extended_Price__c = 200,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
Advanced_pricing_done__c = false,
is_Custom_Product__c=false,
Apttus_Config2__AddedBy__c = 'added by code'	 
);
allLineItems.add(LineItem4);

Apttus_Config2__LineItem__c LineItem5 =new Apttus_Config2__LineItem__c(
Apttus_Config2__ConfigurationId__c=ProdConfigList[0].Id,
Apttus_Config2__ItemSequence__c = 1,
Apttus_Config2__LineNumber__c = 4,
//Apttus_Config2__IsPrimaryLine__c = opportunities.get(0).IdTrue,
Apttus_Config2__LineStatus__c='New',
Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
//Apttus_Config2__ChargeType__c = 'Standard Type',
Apttus_Config2__ChargeType__c = 'SRS', 
Apttus_Config2__LineType__c = 'Product/Service',
Apttus_Config2__ProductId__c = prod5.Id,
Apttus_Config2__PriceListItemId__c = pLI5.id,
Apttus_Config2__PriceMethod__c = 'Per Unit',
Apttus_Config2__Frequency__c = 'Yearly',
NokiaCPQ_Maint_Yr2_Extended_Price__c = 100,
Apttus_Config2__ListPrice__c = 120,
Apttus_Config2__BasePrice__c = 120,
Apttus_Config2__Quantity__c = 1,
Nokia_SSP_Base_Extended_Price__c = 200,
Apttus_Config2__PrimaryLineNumber__c = 1,
Apttus_Config2__ShipToAccountId__c = account.Id,
Advanced_pricing_done__c = false,
is_Custom_Product__c=false,
Apttus_Config2__AddedBy__c = 'added by code'	 
);
allLineItems.add(LineItem5);

insert allLineItems;

Test.startTest(); 

CPQ_Maintenance_and_SSP_Rule__c rec1 = new CPQ_Maintenance_and_SSP_Rule__c();
rec1.Maintenance_Level__c = 'Nokia Brand of Service';
rec1.Maintenance_Type__c = 'Gold (Return for Exchange)';
rec1.Region__c = 'RG_NAM';
rec1.Service_Rate_Y1__c = 0.05;
rec1.Service_Rate_Y2__c = 0.05;
rec1.Unlimited_SSP_Discount__c = 0.03; 
rec1.Maintenance_Category__c = 'NSD-NRC IPR';
insert rec1;

Nokia_PricingCallBack obj = new Nokia_PricingCallBack();

obj.setMode(Apttus_Config2.CustomClass.PricingMode.BASEPRICE);
Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfigList[0].Id);

obj.setMode(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT);
obj.finish();

//Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfigList[0].Id);

//Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
}
Test.stopTest();
}

static testMethod void DirectMethod11() {
		Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
		custSetting.Apttus_Config2__PricingCallbackClass__c = 'Nokia_PricingCallBack';
		custSetting.Name = 'Nokia_CallBack1';
		insert custSetting;
		
		Nokia_PricingCallBack npc = new Nokia_PricingCallBack();
		
		List<Opportunity> opportunities;
		List<Accreditation__c> accreditations = new List<Accreditation__c>();
		List<User> users = NF_TestDataFactory.getUsers(1,'System Administrator');
		users[0].Nokia_ID__c = '234597';
		insert users;
		
		
		System.runAs(users[0]) {
			
			List<Account> accountsNew = new List<Account>();
			Account accLegalEntity = TestDataFactory.createAccount(1)[0];
			accLegalEntity.AccountNumber='101234567';
			accLegalEntity.Acc_No__c = '101234567';
			accLegalEntity.GeoLevel1Id__c = 'RG_NAM';
			accLegalEntity.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
			accountsNew.add(accLegalEntity);
			
			Account account = TestDataFactory.createAccount(1)[0];
			account.AccountNumber='3011234567';
			account.Acc_No__c = '3011234567';
			account.GeoLevel1Id__c = 'RG_NAM';
			accountsNew.add(account);
			
			insert accountsNew;
			
			
			List<Account> accounts=new List<Account>();
			accounts.add(account);
			
			//Create Opportunity
			opportunities = NF_TestDataFactory.getOpportunities(1,accounts);
			opportunities.get(0).Lead_BG__c = 'NSW';
			opportunities.get(0).RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Create Direct Sales Opportunity').getRecordTypeId();
			
			insert opportunities.get(0);
			
			
			//Create Product
			List<Product2> prods = new List<Product2>();
			
			Product2 prod1 = new product2(
				Name = 'Test1', 
				ProductCode = '123',
				CurrencyIsoCode = 'USD',
				Portfolio__c = 'Airscale Wifi',
				IsActive = true,
				Apttus_Config2__ConfigurationType__c = 'Bundle',
				NokiaCPQ_Item_Type__c='Software',
				NokiaCPQ_Classification2__c='Base'	   
			); 
			prods.add(prod1); 
		   
		   Product2 prod2 = new product2(
			Name = 'Test1Arcadia', 
			ProductCode = '123Arcadia',
			CurrencyIsoCode = 'USD',
			Portfolio__c = 'Airscale Wifi',
			IsActive = true,
			Apttus_Config2__ConfigurationType__c = 'Standalone',
			NokiaCPQ_Item_Type__c='Hardware',
			NokiaCPQ_Classification2__c='Base'	   
			); 
		prods.add(prod2);  
		insert prods;
			
			//Create PriceList
			
			Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
				Name = 'Commercial Price List', 
				Apttus_Config2__Active__c = True, PriceList_Type__c = 'CPQ'
			);
			insert ApttusTestPriceList;
			
			//create price list items
			List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
			Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
				Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
				Apttus_Config2__ListPrice__c = 100, 
				Apttus_Config2__ProductId__c = prod1.Id, 
				Apttus_Config2__ChargeType__c = 'Standard Price'
			);
			
			plistItems.add(pLI1);   
			
			Apttus_Config2__PriceListItem__c pLI2 = new Apttus_Config2__PriceListItem__c(
				Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
				Apttus_Config2__ListPrice__c = 100, 
				Apttus_Config2__ProductId__c = prod2.Id, 
				Apttus_Config2__ChargeType__c = 'Standard Price'
			);
			plistItems.add(pLI2); 
			insert plistItems;
			
			//create proposal
			Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(
				Apttus_Proposal__Opportunity__c = opportunities.get(0).Id,
				Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.Id,
				Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
				NokiaCPQ_Portfolio__c = 'Airscale Wifi',
				NokiaCPQ_No_of_Years__c = '4',
				NokiaCPQ_Maintenance_Type__c='MN GS TSS Basic',
				RecordTypeId =Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Direct Quote').getRecordTypeId(),//direct	Prices_Aligned__c=true,
				Apttus_Proposal__Account__c=accLegalEntity.id,
				Sold_To_Party__c = accLegalEntity.id,
				Is_List_Price_Only__c =false
			);
			insert testProposal;
			
			
			system.debug('testProposal:'+testProposal);
			
			//create product configuration
			Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c(
				Name = 'APTTUS Test Config', 
				Apttus_Config2__AccountId__c = account.Id, 
				Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
				Apttus_QPConfig__Proposald__c = testProposal.Id, 
				Apttus_Config2__Status__c = 'New', 
				Apttus_Config2__VersionNumber__c = 1, 
				Apttus_Config2__EffectivePriceListId__c = ApttusTestPriceList.Id,
				Apttus_Config2__BusinessObjectId__c = String.valueOf(testProposal.Id),
				Apttus_Config2__BusinessObjectType__c = 'Proposal'
			);
			insert ProdConfig;
			
			//Create Line Items
			list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
			Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
				Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
				Apttus_Config2__ItemSequence__c = 1,
				Apttus_Config2__LineNumber__c = 1,
				Apttus_Config2__LineStatus__c='New',
				Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
				Apttus_Config2__ChargeType__c = 'Standard Price', 
				Apttus_Config2__LineType__c = 'Product/Service',
				Apttus_Config2__ProductId__c = prod1.Id,
				Apttus_Config2__PriceListItemId__c = pLI1.id,
				Apttus_Config2__PriceMethod__c = 'Per Unit',
				Apttus_Config2__Frequency__c = 'One Time',
				Apttus_Config2__BasePrice__c=100,
				Apttus_Config2__ListPrice__c = 100,
				Apttus_Config2__Quantity__c = 1,
				Source__c='',
				Apttus_Config2__PrimaryLineNumber__c = 1,
				Apttus_Config2__ShipToAccountId__c = account.Id,
				is_Custom_Product__c=false,
				Apttus_Config2__BasePriceOverride__c=120,
				Apttus_Config2__AddedBy__c = 'added by code',
				NokiaCPQ_Unitary_IRP__c = 300,
				NokiaCPQ_Product_Type__c='Controller'
				
			);
			
			allLineItems.add(LineItem1);
			
			Apttus_Config2__LineItem__c LineItem2 =new Apttus_Config2__LineItem__c(
			Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
			Apttus_Config2__ItemSequence__c = 2,
			Apttus_Config2__LineNumber__c = 1,
			Apttus_Config2__LineStatus__c='New',
			Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
			Apttus_Config2__ChargeType__c = 'Standard Price', 
			Apttus_Config2__LineType__c = 'Option',
			Apttus_Config2__ProductId__c = prod1.Id,
			Apttus_Config2__OptionId__c = prod2.Id,
			Apttus_Config2__ParentBundleNumber__c = 1,
			Apttus_Config2__PriceListItemId__c = pLI2.id,
			Apttus_Config2__PriceMethod__c = 'Per Unit',
			Apttus_Config2__Frequency__c = 'One Time',
			Apttus_Config2__BasePriceOverride__c=120,
			Apttus_Config2__ListPrice__c = 300,
			Apttus_Config2__BasePrice__c=300,
			Apttus_Config2__Quantity__c = 1,
			is_Custom_Product__c=false,
			Apttus_Config2__PrimaryLineNumber__c = 1,
			Apttus_Config2__ShipToAccountId__c = account.Id,
			Apttus_Config2__AddedBy__c = 'added by code'
			);
			allLineItems.add(LineItem2);
			insert allLineItems;
			
			Test.startTest(); 
			
			Nokia_PricingCallBack obj = new Nokia_PricingCallBack();
			
			obj.setMode(Apttus_Config2.CustomClass.PricingMode.BASEPRICE);
			Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);
			
			obj.setMode(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT);
			
			Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
			Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);
			
			obj.finish();
			Nokia_PricingCallBack.calculateEquivalentPrice(allLineItems, 'Market India');
			
			//Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
			//Apttus_Config2.PricingWebService.updatePriceForCart(ProdConfig.Id);
			
		}
		Test.stopTest();
	}
	
}