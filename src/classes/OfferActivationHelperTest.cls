/****************************************
 * Name : OfferActivationHelperTest
 * Author : Accenture
 * Description : Test class for OfferActivationHelper
 *****************************************/ 
@isTest
public class OfferActivationHelperTest {
	public static Offer__c offerObj;
	public static Offer__c offerObj1;
	public static Opportunity opportunityObj;
	public static Opportunity referenceOpportunityObj;
	public static Account accountObj;
	public static Offer__c updateOfferObj;
	private static Id oppDirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.CREATE_DIRECT_SALES_OPPORTUNITY).getRecordTypeId();
	  /****************************************
	*Method Name: createLoAByPassDetailsTest
	*Description: Method to cover createLoAByPassDetails
	*Parameters: none
	*****************************************/
	@isTest
	public static void createLoAByPassDetailsTest(){
		User sysAdminUser = TestDataFactory.userCreation(1,'System Administrator')[0];
		//insert sysAdminUser;
		System.runAs(sysAdminUser)
		{
		List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		database.insert(fileSharingCustomSettingList);
		accountObj = new Account();
		accountObj = TestDataFactory.createAccount(1)[0];
		accountObj.L4Name__c = 'Market India';
		database.insert(accountObj);
		Opportunity opptyList = TestDataFactory.OpportunityCreation(1, accountObj)[0];
		opptyList.RecordTypeId= oppDirectRecordTypeId;
		insert opptyList;
	   
		/*Opportunity opptyList1 = TestDataFactory.OpportunityCreation(1, accountObj)[0];
		opptyList1.RecordTypeId= oppDirectRecordTypeId;
		opptyList1.Reference_Opportunity__c = opptyList.id;	
		insert opptyList1;*/

		test.startTest();
		List<Offer__c> offerObjList = new List<Offer__c>();
		offerObjList = TestDataFactory.OfferCreation(2, opptyList);		
		database.insert(offerObjList);		

		Sales_Role__c SR = NF_TestDataFactory.createSalesRole(sysAdminUser,'NSNC_PrMBG','Market India','4 - BG Pricing Manager');
		insert SR;
		Offer_Team__c offerTeamObj = TestDataFactory.offerTeamCreation(1,offerObjList[0],sysAdminUser)[0];
		offerTeamObj.Team_Member_Role__c = 'Pricing Manager';
		insert offerTeamObj;
		
		offerObjList[0].LOA_Bypass__c = 'Authorized for Pricing Manager';
		offerObjList[0].LoA_Bypass_Sign_Off_BG_AA__c = 'Yes';
		offerObjList[0].LoA_Bypass_Sign_Off_BG_FN__c = 'Yes';
		offerObjList[0].LoA_Bypass_Sign_Off_BG_GS__c = 'Yes';
		offerObjList[0].LoA_Bypass_Sign_Off_BG_ION__c = 'Yes';
		offerObjList[0].LoA_Bypass_Sign_Off_BG_MN__c = 'Yes';
		offerObjList[0].LoA_Bypass_Sign_Off_BG_NEN__c = 'Yes';
		offerObjList[0].Product_Only_Offer__c = True;

		List<Offer__c> offerList = new List<Offer__c>();
		offerList.add( offerObjList[0]);	 
		
		OfferActivationHelper.createLoAByPassDetails(offerList);
		OfferActivationHelper.createLoAByPassDetails(null);
			
		Map<Id,Offer__c> offerOldMap = new Map<Id,Offer__c>();
		offerOldMap.put(offerObjList[0].Id,offerObjList[1]);
		OfferActivationHelper.updateLoAByPassDetails(offerList,offerOldMap);
		 
		List<Offer__c> offerList1 = new List<Offer__c>();
		offerList1.add( offerObjList[1]); 
		Map<Id,Offer__c> offerOldMap1 = new Map<Id,Offer__c>();
		offerOldMap1.put(offerObjList[1].Id,offerObjList[0]);
		
		OfferActivationHelper.updateLoAByPassDetails(offerList1,offerOldMap1);
		test.StopTest();
		}
	}
	@isTest
 public static void PopulateHigestOfferNumberOnOffer(){
		List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		database.insert(fileSharingCustomSettingList);
		accountObj = new Account();
		accountObj = TestDataFactory.createAccount(1)[0];
	  
		database.insert(accountObj);
		List<Opportunity> opptyList = TestDataFactory.OpportunityCreation(2, accountObj);
		opptyList[0].RecordTypeId= oppDirectRecordTypeId;
		opptyList[0].Reference_Opportunity__c = opptyList[1].id;		
		opptyList[0].HighestOfferNumber__c = 12;
		insert opptyList;
	   test.startTest();
		offerObj = new Offer__c();
		offerObj = TestDataFactory.OfferCreation(1, opptyList[0])[0]; 
		offerObj.Expected_LoA_G4_Approval_Level__c = 'A';
		database.insert(offerObj);
	 // Added By Shubham
		offerObj.Expected_LoA_G4_Approval_Level__c = 'A+';
		database.update(offerObj);
		offerObj.Expected_LoA_G4_Approval_Level__c = 'C';
		database.update(offerObj);
		test.stopTest();
}
	@isTest
	 public static void PopulateHigestOfferNumberOnOfferLow(){
		List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		database.insert(fileSharingCustomSettingList);
		accountObj = new Account();
		accountObj = TestDataFactory.createAccount(1)[0];
		test.startTest();
		database.insert(accountObj);
		List<Opportunity> opptyList = TestDataFactory.OpportunityCreation(2, accountObj);
		opptyList[0].RecordTypeId= oppDirectRecordTypeId;
		insert opptyList;
		
		opptyList[0].Reference_Opportunity__c = opptyList[1].id;		
		opptyList[0].HighestOfferNumber__c = 8;
		

		
		offerObj = new Offer__c();
		offerObj = TestDataFactory.OfferCreation(1, opptyList[0])[0];
		offerObj.Expected_LoA_G4_Approval_Level__c = 'A';
		database.insert(offerObj);
	   
}
	 @isTest
	 public static void PopulateHigestOfferNumberOnOfferNULL(){
		List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		database.insert(fileSharingCustomSettingList);
		accountObj = new Account();
		accountObj = TestDataFactory.createAccount(1)[0];
		test.startTest();
		database.insert(accountObj);
		List<Opportunity> opptyList = TestDataFactory.OpportunityCreation(2, accountObj);
		opptyList[0].RecordTypeId= oppDirectRecordTypeId;
		insert opptyList;
		
		opptyList[0].Reference_Opportunity__c = opptyList[1].id;		
		opptyList[0].HighestOfferNumber__c = null;
		

		
		offerObj = new Offer__c();
		offerObj = TestDataFactory.OfferCreation(1, opptyList[0])[0];
		offerObj.Expected_LoA_G4_Approval_Level__c = 'A';
		database.insert(offerObj);
	   
}
	@isTest
	 public static void PopulateHigestOfferNumberOnOfferNegative(){
		OfferActivationHelper.PopulateHigestOfferNumberOnOffer(NULL);
		OfferActivationHelper.UpdateHigestOfferNumberOnOppty(NULL);
		
		 
	 }
	@isTest
	 public static void onBeforeInsertTest(){
		accountObj = new Account();
		accountObj = TestDataFactory.createAccount(1)[0];
		test.startTest();
		database.insert(accountObj);
		List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		database.insert(fileSharingCustomSettingList);
		opportunityObj = new Opportunity();
		opportunityObj = TestDataFactory.OpportunityCreation(1, accountObj)[0];
		opportunityObj.RecordTypeId= oppDirectRecordTypeId;
		database.insert(opportunityObj);
		
		System.debug('opportunityObj'+opportunityObj);
		List<Offer__c> offerList = new List<Offer__c>();
		offerList = TestDataFactory.OfferCreation(2, opportunityObj);
		offerList[0].Expected_LoA_G4_Approval_Level__c = 'A';
		offerList[0].ActiveOffer__c=true;
		offerList[1].Expected_LoA_G4_Approval_Level__c = 'A';
		offerList[1].ActiveOffer__c=false;
		database.insert(offerList);
		offerList[0].ActiveOffer__c=false;
		offerList[1].Expected_LoA_G4_Approval_Level__c = 'A';
		offerList[1].ActiveOffer__c=true;
		database.update(offerList);
		OfferActivationHelper.onBeforeInsert(NULL);
	 }
	
	  @isTest
	 public static void marketValidationTest(){
				accountObj = new Account();
				accountObj.Market__c = 'Market Greater China';
				accountObj = TestDataFactory.createAccount(1)[0];
			  
				test.startTest();
				database.insert(accountObj);
				
				List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
				fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
				database.insert(fileSharingCustomSettingList);
				opportunityObj = new Opportunity();
				opportunityObj = TestDataFactory.OpportunityCreation(1, accountObj)[0];
				opportunityObj.RecordTypeId= oppDirectRecordTypeId;
				opportunityObj.Lead_BG__c = 'FN';
				database.insert(opportunityObj);
				
				System.debug('opportunityObj'+opportunityObj);
				
				try{
				offerObj = new Offer__c();
				offerObj = TestDataFactory.OfferCreation(1, opportunityObj)[0];
				offerObj.Expected_LoA_G4_Approval_Level__c = 'A';
				offerObj.ActiveOffer__c=true;
				offerObj.LOA_Bypass__c = 'Pre-approved Price List for Account Managers';
				database.insert(offerObj);
		   
				List<Account_Market__c> accMarketList = new List<Account_Market__c>();
				Account_Market__c accMarket = new Account_Market__c();
				accMarket.name ='Market Greater China';
				accMarketList.add(accMarket);
							  
					insert accMarketList;
					
					  System.debug('accMarketList'+accMarketList);
					  CustomException testingCatch = new CustomException('This is an error');
					  throw testingCatch; 
				}catch(Exception e){
				
						  Boolean expectedExceptionThrown =  e.getMessage().contains('Hi') ? true : false;
						 // System.assertEquals(expectedExceptionThrown, false);
				
				}			  
	 }
	
	/****************************************
	*Method Name: cloneTeamTest
	*Description: Method to cover cloneTeam
	*Parameters: none
	*****************************************/
	@isTest
	public static void cloneTeamTest(){
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		userCreation.Restriction_Level__c = 'Unrestricted';
		insert userCreation;
		List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		database.insert(fileSharingCustomSettingList);
		accountObj = new Account();
		accountObj = TestDataFactory.createAccount(1)[0];
		database.insert(accountObj);
		Opportunity oppty = TestDataFactory.OpportunityCreation(1, accountObj)[0];
		oppty.RecordTypeId= oppDirectRecordTypeId;
		insert oppty;
		test.startTest();
		OpportunityTeamMember opptyTeamMember = TestDataFactory.optyTeamMemberCreation(1, userCreation,oppty)[0];
		insert opptyTeamMember;
		Offer__c offer = TestDataFactory.OfferCreation(1, oppty)[0];
		insert offer;
		delete offer;
		Test.stopTest();
	}
	
	
	@isTest
	 public static void OfferLoACurrenyConversion(){
		  User sysAdminUser = TestDataFactory.userCreation(1,'System Administrator')[0];
		System.runAs(sysAdminUser){
		List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		database.insert(fileSharingCustomSettingList);
		accountObj = new Account();
		accountObj = TestDataFactory.createAccount(1)[0];
		accountObj.L4Name__c = 'Market India';
		database.insert(accountObj);
		Opportunity opptyList = TestDataFactory.OpportunityCreation(1, accountObj)[0];
		opptyList.RecordTypeId= oppDirectRecordTypeId;
		insert opptyList;
			
		List<Nokia_Financial_Calendar__c> oNokiaCalender = TestDataFactory.nokiaFinCalCreation(1);
		//oNokiaCalender[0].Current_Period__c = true;
		insert oNokiaCalender[0];
			
		List<Dated_Exchange_Rates__c> oDateExchangeRate = TestDataFactory.datedExchnageRateCreation(2);
			oDateExchangeRate[0].DER_Period__c=oNokiaCalender[0].id;
			oDateExchangeRate[1].CurrencyIsoCode='EUR';
			oDateExchangeRate[1].DER_Period__c=oNokiaCalender[0].id;
			insert oDateExchangeRate;
			
		   
	   
		/*Opportunity opptyList1 = TestDataFactory.OpportunityCreation(1, accountObj)[0];
		opptyList1.RecordTypeId= oppDirectRecordTypeId;
		opptyList1.Reference_Opportunity__c = opptyList.id;	
		insert opptyList1;*/

		test.startTest();
		List<Offer__c> offerObjList = new List<Offer__c>();
		offerObjList = TestDataFactory.OfferCreation(1, opptyList);		
		database.insert(offerObjList);		
		
		offerObjList[0].LoA_Currency__c = 'USD';
		offerObjList[0].Net_Sales_LoA_Base_Case__c = 12;
   update offerObjList;
			
			offerObjList[0].Net_Sales_LoA_Base_Case__c = 13;
			 offerObjList[0].LoA_Currency__c = 'EUR';
   update offerObjList;
		test.StopTest();
		}
	}
	
	
	@isTest
	public static void updateLoAByPassDetailsTest(){
		User testUser = NF_TestDataFactory.createAdminUser('System Administrator');
		testUser.Restriction_Level__c = 'Unrestricted';
		insert testUser;
	
		system.runAs(testUser){
		
		accountObj = new Account();
		accountObj = TestDataFactory.createAccount(1)[0];
		accountObj.L4Name__c = 'Market India';
		database.insert(accountObj);
		Opportunity oppty = TestDataFactory.OpportunityCreation(1, accountObj)[0];
		oppty.RecordTypeId= oppDirectRecordTypeId;
	   
 
		insert oppty;
			
		Sales_Role__c SR = NF_TestDataFactory.createSalesRole(testUser,'NSNC_PrMBG','Market India','4 - BG Pricing Manager');
		insert SR;
		 test.startTest();
		Offer__c offer = TestDataFactory.OfferCreation(1, oppty)[0];
		offer.LoA_Bypass_Sign_Off_BG_NEN__c= 'Yes';
		offer.LoA_Bypass_Sign_Off_BG_NEN__c= 'No';
		insert offer; 
		
		   
		Offer_Team__c offerTeamObj = TestDataFactory.offerTeamCreation(1,offer,testUser)[0];
		offerTeamObj.Team_Member_Role__c = 'Pricing Manager';
		insert offerTeamObj;
		
		Map<Id,Offer__c> offerOldMap = new Map<Id,Offer__c>();
		  offerOldMap.put(offer.Id,offer);  
		offer.LOA_Bypass__c = 'Authorized for Pricing Manager';
		offer.LoA_Bypass_Sign_Off_BG_NEN__c= 'Yes';
		offer.LoA_Bypass_Sign_Off_BG_NEN__c= 'No';
		//offer.Signed_Off_by_PricingManager_BG_NEN__c = UserInfo.getName();	
			 
			List<offer__c> offerList = new List<Offer__c>();
			offerList.add(offer);
			offeractivationhelper.updateLoAByPassDetails(offerList,offerOldMap);
				   //update offer;
	   test.stopTest();
		}
	}
}