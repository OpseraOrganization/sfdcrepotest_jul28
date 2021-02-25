/****************************************
 * Class Name : Batch_DupRCodeInSalesRoleTest
 * Created Date: 10 October 2017
 * Created By : Accenture
 * Last Modified by: 
 * Last Modified Date: 
 * Description : Test class for Duplcate Role codes in Sales Role at multple levels
*****************************************/
@isTest
Private class Batch_DupRCodeInSalesRoleTest{
/******************************
	*Method Name: Batchtest
	*Description: Test Method to cover Batch_DupRCodeInSalesRole class
********************************/

static testMethod void Batchtest(){
NCP_CustomerCommunitySetting__c cs = new NCP_CustomerCommunitySetting__c();
		cs.Name = 'Default';
		cs.Customer_Account__c = 'Customer - test';
		cs.Customer_Account_Number__c = '12345';
		cs.Customer_User_Profile__c = 'Customers';
		insert cs;
List<NF_Rolecode__c> RCList = new List<NF_Rolecode__c>();
NF_Rolecode__c currentRCode = new NF_Rolecode__c( Name = 'NSNE_PPS', NF_Multiple_level__c = true,A_S__c=true );
RCList.add(currentRCode);
NF_Rolecode__c currentRCode1 = new NF_Rolecode__c( Name = 'NSND_PPS', NF_Multiple_level__c = true ,A_S__c=true);
RCList.add(currentRCode1);
NF_Rolecode__c currentRCode2 = new NF_Rolecode__c( Name = 'NSNC_PPS',A_S__c=true );
RCList.add(currentRCode2);
insert RCList;

List<User> testUser = TestDataFactory.userCreation(3,'System Administrator');
insert testUSer;

Sales_Role__c currentSalesOrg;
Sales_Role__c currentSalesOrg1;
Sales_Role__c currentSalesOrg2;
Sales_Role__c currentSalesOrg3;
Sales_Role__c currentSalesOrg4;

List<Territory2Model> T2M = [SELECT Id,State FROM Territory2Model where State='Active' LIMIT 1] ;
List<Territory2Type> T2Type = [SELECT Id FROM Territory2Type LIMIT 1] ;



List<Territory2> Ter_All = [SELECT Id, Name, ParentTerritory2Id From Territory2 where Name = 'Customer Operations' OR Name = 'Market India' OR Name = 'INDIA GCBT Bharti'
						   OR Name = 'INDIA BH CBT Bharti' OR Name = 'INDIA BH CT Bharti'];
/*
Territory2 Ter_L7 = new Territory2();
Territory2 Ter_L6 = new Territory2();
Territory2 Ter_L5 = new Territory2();
Territory2 Ter_L4 = new Territory2();
Territory2 Ter_L3 = new Territory2();

Ter_L3 = NF_TestDataFactory.CreateTerritory2('Customer Operations','L3',T2M[0].Id, T2Type[0].Id );
Ter_All.add(Ter_L3);
Ter_L4 = NF_TestDataFactory.CreateTerritory2('Market India','L4',T2M[0].Id, T2Type[0].Id );
Ter_L4.ParentTerritory2Id = Ter_L3.Id;
Ter_All.add(Ter_L4);
Ter_L5 = NF_TestDataFactory.CreateTerritory2('INDIA GCBT Bharti','L5',T2M[0].Id, T2Type[0].Id );
Ter_L5.ParentTerritory2Id = Ter_L4.Id;
Ter_All.add(Ter_L5);
Ter_L6 = NF_TestDataFactory.CreateTerritory2('INDIA BH CBT Bharti','L6',T2M[0].Id, T2Type[0].Id );
Ter_L6.ParentTerritory2Id = Ter_L5.Id;
Ter_All.add(Ter_L6);
Ter_L7 = NF_TestDataFactory.CreateTerritory2('INDIA BH CT Bharti1','L7',T2M[0].Id, T2Type[0].Id );
Ter_L7.ParentTerritory2Id = Ter_L6.Id;
Ter_All.add(Ter_L7);
insert Ter_All;
*/
List<Sales_Role__c> SRList = new List<Sales_Role__c>();

CurrentSalesOrg = NF_TestDataFactory.createSalesRole(testUser[0], 'NSNC_PPS', 'Market India', 'MN Market Head of Product Portfolio Sales');
SRList.add(CurrentSalesOrg);
insert CurrentSalesOrg;
CurrentSalesOrg1 = NF_TestDataFactory.createSalesRole(testUser[1], 'NSNE_PPS', 'INDIA BH CBT Bharti', 'MN Market Head of Product Portfolio Sales CBT');
SRList.add(CurrentSalesOrg1);
insert CurrentSalesOrg1;
CurrentSalesOrg2 = NF_TestDataFactory.createSalesRole(testUser[0], 'NSND_PPS', 'INDIA GCBT Bharti', 'MN MU Head of Product Portfolio Sales');
SRList.add(CurrentSalesOrg2);
	insert CurrentSalesOrg2;
CurrentSalesOrg3 = NF_TestDataFactory.createSalesRole(testUser[1], 'NSNC_PPS', 'Market India', 'MN Market Head of Product Portfolio Sales');
SRList.add(CurrentSalesOrg3);
	insert CurrentSalesOrg3;
//CurrentSalesOrg4 = NF_TestDataFactory.createSalesRole(testUser[2], 'NSNC_BM', 'Market India', '4 - Bid Management Cluster Head');
//SRList.add(CurrentSalesOrg4);
//insert SRList;

Test.startTest();
Batch_DupRCodeInSalesRole batch= new Batch_DupRCodeInSalesRole();
Database.BatchableContext BC;
SchedulableContext SC;  
batch.execute(SC);
batch.start(BC);
batch.execute(BC,SRList);
batch.execute(BC,Null);
batch.finish(BC);
		
		
Test.StopTest();
}
}