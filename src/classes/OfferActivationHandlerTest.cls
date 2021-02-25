/****************************************
* Class Name : OfferActivationHandlerTest 
* Created Date: 21st October 2016
* Created By : Accenture
* Last Modified by: Accenture
* Last Modified Date: 28 Nov 2016
* Description : This is the test class to cover OfferActivationHandler
*****************************************/ 
@isTest(seealldata = false)
private class OfferActivationHandlerTest{
	/****************************************
* Method Name: validateOfferActivation
* Description : Test method to cover OfferActivationHandler
*****************************************/	
	static testMethod void validateOfferActivation(){
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		System.RunAs(userCreation){
			List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
			fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
			database.insert(fileSharingCustomSettingList);
			List<Account> accList = TestDataFactory.createAccount(2);
			accList[1].Name = 'Test Acc';
			database.insert(accList);
			Test.startTest();
			List<Opportunity> oppList = TestDataFactory.OpportunityCreation(2,accList[0]);
			database.insert(oppList);
			oppList[0].StageName = 'Win the Case (Negotiate)';
			oppList[0].Phase_Status__c = 'Offer Submitted to Customer (Manual)';
			oppList[0].Probability = 10;
			oppList[1].StageName = 'Win the Case (Negotiate)';
			oppList[1].Phase_Status__c = 'Offer Submitted to Customer (Manual)';
			oppList[1].Probability = 10;
			//database.update(oppList);
			Test.stopTest();
			/*Offer__c offerCreation = TestDataFactory.OfferCreation(1,oppList[0])[0];
offerCreation.ActiveOffer__c = true;
offerCreation.Expected_LoA_G4_Approval_Level__c = 'A';
insert offerCreation;*/
			List<Offer__c> offerList = TestDataFactory.OfferCreation(3,oppList[0]);
			offerList[0].Activeoffer__c = true;
			offerList[1].Activeoffer__c = false;
			offerList[2].Activeoffer__c = false;
			offerList[0].Expected_LoA_G4_Approval_Level__c = 'A';
			offerList[1].Expected_LoA_G4_Approval_Level__c = 'A';
			offerList[2].Expected_LoA_G4_Approval_Level__c = 'A';
			database.insert(offerList);  
			offerList[2].Activeoffer__c = true;			
			database.update(offerList);  
			//Exception
			OfferActivationHelper.onBeforeInsert(NULL);
			OfferActivationHelper.validate(NULL,NULL);
			
		}
	}
	
	/******************************
*Method Name: cloneTeamTest
*Description: Test Method to cover CloneOfferTeam class
********************************/
	static testMethod void cloneTeamTest(){
		List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		user userCreationRead = TestDataFactory.userCreation(1,'System Administrator')[0];
		database.insert(userCreation);
		system.runAs(userCreation){
			
			//fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
			//database.insert(fileSharingCustomSettingList);
			Account accountCreation = TestDataFactory.createAccount(1)[0];
			database.insert(accountCreation);
			Opportunity optyCreation = TestDataFactory.OpportunityCreation(1,accountCreation)[0];
			database.insert(optyCreation);
			optyCreation.StageName = 'Win the Case (Negotiate)';
			optyCreation.Phase_Status__c = 'Offer Submitted to Customer (Manual)';
			optyCreation.Probability = 10;		   
			OpportunityTeamMember optyTeamCreation = TestDataFactory.optyTeamMemberCreation(1,userCreation,optyCreation)[0];
			database.insert(optyTeamCreation);
			test.startTest();
			Offer__c offerCreation = TestDataFactory.OfferCreation(1,optyCreation)[0];
			offerCreation.ActiveOffer__c  = true;
			offerCreation.Expected_LoA_G4_Approval_Level__c = 'A';
			database.insert(offerCreation);
			List<Offer__c> offerList = new List<Offer__c>();
			offerList.add(offerCreation);

			test.stoptest();
		}
	}
	
	/****************************************
* Method Name: insertOffer
* Description : Test method to cover OfferActivationHandler
****************************************   
	static testMethod void insertOffer(){
		user userCreation = TestDataFactory.userCreation(1,'Global Process Admin Profile')[0];
		insert userCreation;
		System.RunAs(userCreation){
			List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
			fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
			database.insert(fileSharingCustomSettingList);
			Account acc = TestDataFactory.createAccount(1)[0];
			database.insert(acc);
			
			Test.startTest();
			List<Opportunity> opptyList = new List<Opportunity>();
			opptyList = TestDataFactory.OpportunityCreation(1,acc);
			opptyList[0].StageName = GlobalConstants.IDENTIFY_OPPORTUNITY;
			opptyList[0].Phase_Status__c = 'Planned';
			opptyList[0].Sales_Outcome__c = 'Obsolete';
			opptyList[0].Sales_Outcome_Reason__c = 'Commercial';
		   // opptyList.add(opp);
			/* opp.Second_Reason__c = '';
opp.Third_Reason__c = '';
			database.insert(opptyList);
			try{				
				Offer__c offerCreation = TestDataFactory.OfferCreation(1,opptyList[0])[0];
				offerCreation.ActiveOffer__c = true;
				offerCreation.Expected_LoA_G4_Approval_Level__c = 'A';
				insert offerCreation;
			}catch(Exception e){
				Boolean expectedExceptionThrown = e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false; 
				System.assertEquals(expectedExceptionThrown, true);
			}
		}
	}
	*/ 
	/****************************************
* Method Name: deleteOffer
* Description : Test method to cover OfferActivationHandler
*****************************************/	
	static testMethod void deleteOffer(){
		Offer__c offerCreation = new Offer__c();
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		database.insert(userCreation);
		user userCreationOtherProfile = TestDataFactory.userCreation(1,'Global Process Admin Profile')[0];
		database.insert(userCreationOtherProfile );
		
		System.runAs(userCreation){			
			Account acc = TestDataFactory.createAccount(1)[0];
			database.insert(acc);
			List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
			fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
			database.insert(fileSharingCustomSettingList);
			
			Opportunity opp = TestDataFactory.OpportunityCreation(1,acc)[0];
			opp.StageName = GlobalConstants.IDENTIFY_OPPORTUNITY;
			opp.Phase_Status__c = 'Planned';
			opp.Sales_Outcome__c = 'Obsolete';
			opp.Sales_Outcome_Reason__c = 'Commercial';
			database.insert(opp);
			
			offerCreation = TestDataFactory.OfferCreation(1,opp)[0];
			offerCreation.ActiveOffer__c = true;
			offerCreation.Expected_LoA_G4_Approval_Level__c = 'A';
			insert offerCreation;										  
		}
		
		Test.startTest();
		System.runAs(userCreationOtherProfile ){
			try{  
				List<Offer__c> offerListDelete = new List<Offer__c>();
				offerListDelete=[Select id from Offer__c where id =: offerCreation.Id ];
				system.debug('offerCreation>>>>'+offerCreation);			  
				delete offerListDelete;
			}catch(Exception e){
				Boolean expectedExceptionThrown = e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false; 
				System.assertEquals(expectedExceptionThrown, true);
			}
		}
		Test.stopTest();		
	}
		/****************************************
* Method Name: defaultValueForSSOSATOnUpdateToC_Test
* Description : Test method to cover OfferActivationHandler
*****************************************/	
	static testMethod void defaultValueForSSOSATOnUpdateToC_Test(){
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		System.RunAs(userCreation){
			Account acc = TestDataFactory.createAccount(1)[0];
			database.insert(acc);  
			
			Opportunity opp = TestDataFactory.OpportunityCreation(1,acc)[0];
			database.insert(opp); 
			
			Offer__c offerCreation = TestDataFactory.OfferCreation(1,opp)[0];
			offerCreation.ActiveOffer__c = true;
			offerCreation.Expected_LoA_G4_Approval_Level__c = 'A';
			insert offerCreation;
			
			Test.startTest();
			offerCreation.Expected_LoA_G4_Approval_Level__c = 'C';
			update offerCreation;
			OfferActivationHelper.defaultValueForSSOOnInsert(null);
			Test.stopTest();
		}
	}
	
	/****************************************
* Method Name: defaultValueForSSOSATOnUpdateToA_Test
* Description : Test method to cover OfferActivationHandler
*****************************************/	
	static testMethod void defaultValueForSSOSATOnUpdateToA_Test(){
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		System.RunAs(userCreation){
			Account acc = TestDataFactory.createAccount(1)[0];
			database.insert(acc);  
			
			Opportunity opp = TestDataFactory.OpportunityCreation(1,acc)[0];
			database.insert(opp); 
			
			Offer__c offerCreation = TestDataFactory.OfferCreation(1,opp)[0];
			offerCreation.ActiveOffer__c = true;
			offerCreation.Expected_LoA_G4_Approval_Level__c = 'C';
			insert offerCreation;
			
			Test.startTest();
			offerCreation.Expected_LoA_G4_Approval_Level__c = 'A';
			update offerCreation;
			OfferActivationHelper.defaultValueForSSOOnUpdate(null,null);
			Test.stopTest();
		}
	}
	
		/****************************************
* Method Name: restrictManualChangingSSOTOAttachedTest
* Description : Test method to cover OfferActivationHandler
*****************************************/	
	static testMethod void restrictManualChangingSSOTOAttachedTest(){
		user userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		insert userCreation;
		System.RunAs(userCreation){
			Account acc = TestDataFactory.createAccount(1)[0];
			database.insert(acc);  
			
			Opportunity opp = TestDataFactory.OpportunityCreation(1,acc)[0];
			database.insert(opp); 
			
			Offer__c offerCreation = TestDataFactory.OfferCreation(1,opp)[0];
			offerCreation.ActiveOffer__c = true;
			offerCreation.Expected_LoA_G4_Approval_Level__c = 'C';
			insert offerCreation;
			
			Test.startTest();
			try{
			offerCreation.Solution_Sign_Off_New__c = GlobalConstants.Required_Attached;
			update offerCreation;
			}catch(Exception ex){
			   String message = ex.getMessage();
				system.assert(message.contains('Please attach a Solution Sign-Off document'), 'message=' + message);  
			}
			OfferActivationHelper.restrictManualChangingSSOTOAttached(null,null);
			Test.stopTest();
		}
	}
}