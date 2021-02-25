@isTest
public with sharing class OpportunityWarningsCompController_Test {

	public static Id swxRecordTypeId = Schema.SObjectType.SWx_Upsell_Proposal__c.getRecordTypeInfosByName().get('SWx Upsell Proposal').getRecordTypeId();
	public static Id swxQuoteRecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('SWx/CCRE Proposal').getRecordTypeId();
	public static Id indirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.INDIRECT_OPPTY).getRecordTypeId();

	public static Id upsellOpptyId ;
	public static Id opptyId ;
	public static Id accountId ;
	public static Id priceListId ;
	public static Id upsellProposalId ;
	public static Id userID;

	@isTest
	static void checkOpportunityStageParameters() {
		User sysAdminUser = TestDataFactory.createSystemAdminUser();

		System.runAs(sysAdminUser){

			Account accountCreationDP = TestDataFactory.createAccount(1)[0];
			database.insert(accountCreationDP);
			accountId = accountCreationDP.Id;

			Account acc = new Account();
			acc.Name='Legal Entity Account For Test';
			acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
			acc.ParentId = accountCreationDP.Id;
			acc.AccountNumber = '100006843';
			database.insert(acc);

			//Create Digital Proposal
			SWx_Upsell_Proposal__c upsellProposal_SWX=TestDataFactory.upsellList(1,accountCreationDP)[0];
			upsellProposal_SWX.Analytics_File_Refer_ID__c='GBR-61940-82356';
			upsellProposal_SWX.Analytics_Source__c='CXM';
			upsellProposal_SWX.Proposal_Recommendation_Type__c='renewal';
			upsellProposal_SWX.P20_Id__c=215616;
			upsellProposal_SWX.CurrencyIsoCode='EUR';
			upsellProposal_SWX.Unweighted_Value__c=429052.07;
			upsellProposal_SWX.Account_ID__c=accountCreationDP.Id;
			upsellProposal_SWX.Sold_To_Party__c = accountCreationDP.Id;
			upsellProposal_SWX.RecordTypeID=swxRecordTypeId;
			database.insert(upsellProposal_SWX);
			upsellProposalId = upsellProposal_SWX.Id;

			//Create Opportunity
			List<Opportunity> oppties = TestDataFactory.OpportunityCreation(2,accountCreationDP);
			oppties.get(0).SWx_Upsell_Proposal__c=upsellProposal_SWX.id;
			database.insert(oppties);
			upsellOpptyId = oppties.get(0).Id;
			opptyId = oppties.get(1).Id;

			oppties.get(0).StageName = 'Execute (Start Delivery)';
			oppties.get(0).Phase_Status__c = 'In Execution';
			oppties.get(0).Lead_BG__c ='MN';
			oppties.get(0).DS_Reasons_Populated__c = true;

			oppties.get(1).Lead_BG__c ='MN';
			database.update(oppties);

			Apttus_Config2__PriceList__c priceList= TestdataFactory.priceList(1)[0];
			database.insert(priceList);
			priceListId = priceList.Id;

			product2 prod = TestDataFactory.productCreation(1)[0];
			prod.Business_Group__c='FN';
			prod.Family= 'FNCABLE';
			database.insert (prod);

			Nokia_Financial_Calendar__c nokiaFinCal = TestDataFactory.nokiaFinCalCreation(1)[0];
			database.insert(nokiaFinCal);

			Order_Intake_Forecast__c orderIntake = new Order_Intake_Forecast__c();
			orderIntake.BusinessLine__c = prod.id;
			orderIntake.Opportunity__c = oppties.get(0).id;
			orderIntake.OIF_Value__c = 12000;
			orderIntake.OIF_Value_EUR__c = 12000;
			orderIntake.Forecast_Category__c = 'Upside';
			orderIntake.POPlanReceipt__c = nokiaFinCal.id;
			database.insert(orderIntake);

			Apttus_Approval__Approval_Request__c appreq = new Apttus_Approval__Approval_Request__c();
			appreq.Apttus_Approval__Step_Name__c = 'G4 Process Test';
			appreq.Apttus_Approval__Assigned_To_Type__c = 'User';
			appreq.Apttus_Approval__Related_Opportunity__c = oppties.get(0).id;
			insert appreq;

			Apttus_Approval__Approval_Process__c appProcess = new Apttus_Approval__Approval_Process__c();
			appProcess.Apttus_Approval__Process_Name__c = 'G5 Contract Approvals (Bypass)';
			appProcess.Apttus_Approval__Object_Type__c = 'Opportunity';
			insert appProcess;

			Apttus_Approval__Approval_Process__c appProcess1 = new Apttus_Approval__Approval_Process__c();
			appProcess1.Apttus_Approval__Process_Name__c = 'G6 Approvals (Bypass)';
			appProcess1.Apttus_Approval__Object_Type__c = 'Opportunity';
			insert appProcess1;

			Apttus_Approval__Approval_Process__c appProcess2 = new Apttus_Approval__Approval_Process__c();
			appProcess2.Apttus_Approval__Process_Name__c = 'G5 Approvals Bypass';
			appProcess2.Apttus_Approval__Object_Type__c = 'Opportunity';
			insert appProcess2;

			Test.startTest();

			Apttus_Proposal__Proposal__c quoteProposal = NOKIA_CPQ_TestDataFactory.createProposal(1)[0];
			quoteProposal.Apttus_Proposal__Opportunity__c = opptyId;
			quoteProposal.Apttus_QPConfig__PriceListId__c = priceListId;
			quoteProposal.NokiaCPQ_Portfolio__c = 'IP Routing';
			quoteProposal.NokiaCPQ_SSP_Level__c = 'Unlimited';
			quoteProposal.SWx_Upsell_Proposal__c=upsellProposalId;
			quoteProposal.Analytics_Source__c  = CSWXGlobalConstant.AnalyticsSource_CCRE;
			quoteProposal.Apttus_Proposal__Account__c=accountId;
			quoteProposal.Prices_Aligned__c=true;
			quoteProposal.RecordTypeId = swxQuoteRecordTypeId;
			insert quoteProposal;
			checkRecursive.run=true;

			quoteProposal.Apttus_Proposal__Approval_Stage__c='Accepted';
			update quoteProposal;
			Integer i = OpportunityWarningsCompController.checkOpttyStageParams(opptyId);

			Test.stopTest();
		}

	}

	@isTest
	static void OfferWarningMessageTest(){
		User userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];

		System.runAs(userCreation){
			Account accountCreation = TestDataFactory.createAccount(1)[0];
			database.insert(accountCreation);

			Opportunity optyCreation = TestDataFactory.OpportunityCreation(1,accountCreation)[0];
			optyCreation.stageName = GlobalConstants.WIN_THE_CASE_NEGOTIATE;
			optyCreation.Phase_Status__c= GlobalConstants.OFFERSUBMITTEDTOCUSTOMER;
			database.insert(optyCreation);
			
			Offer__c offerCreation =  TestDataFactory.OfferCreation(1,optyCreation)[0];
			offerCreation.Expected_LoA_G4_Approval_Level__c = 'C';
			offerCreation.ActiveOffer__c = true;
			
			Test.startTest();
			System.assertEquals(OpportunityWarningsCompController.findOffer(optyCreation.Id, optyCreation.Id), GlobalConstants.BLANK_VALUE) ;
			database.insert(offerCreation);
			System.assertNotEquals(OpportunityWarningsCompController.findOffer(optyCreation.Id, optyCreation.Id), GlobalConstants.BLANK_VALUE) ;
			Test.stopTest();
		}
	}

	@isTest
	static void checkMinPlanDateOIFTest(){

		User userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];

		system.runAs(userCreation){

			Account accountCreation = TestDataFactory.createAccount(1)[0];
			database.insert(accountCreation);

			Opportunity optyCreation = TestDataFactory.OpportunityCreation(1,accountCreation)[0];
			optyCreation.G5_Planned_Date__c = System.today() + 90;
			database.insert(optyCreation);

			Product2 prod = TestDataFactory.productCreation(1)[0];
			prod.Business_Group__c='FN';
			prod.Family= 'FNCABLE';
			database.insert (prod);

			List<Nokia_Financial_Calendar__c> nokiaFinCals = TestDataFactory.nokiaFinCalCreation(2);
			Date first = System.today() + 30;
			Date second = System.today() + 120;
			nokiaFinCals[0].Start_Date__c = first;
			nokiaFinCals[0].End_Date__c = first + 30;
			nokiaFinCals[1].Start_Date__c = second;
			nokiaFinCals[1].End_Date__c = second + 30;
			database.insert(nokiaFinCals);

			List<Order_Intake_Forecast__c> orderIntakes = new List<Order_Intake_Forecast__c>();
			for(integer i = 0; i < 2 ; i++){
				Order_Intake_Forecast__c orderIntake = new Order_Intake_Forecast__c();
				orderIntake.BusinessLine__c = prod.id;
				orderIntake.Opportunity__c = optyCreation.id;
				orderIntake.OIF_Value__c = 1;
				orderIntake.OIF_Value_EUR__c = 1;
				orderIntake.Forecast_Category__c = 'Upside';
				orderIntakes.add(orderIntake);
			}

			orderIntakes.get(0).POPlanReceipt__c = nokiaFinCals[0].Id;
			database.insert(orderIntakes.get(0));

			Test.startTest();
			Date newDate = OpportunityWarningsCompController.checkMinPlanDateOIF(optyCreation.Id);
			Date lastDayFirst = ((first.addMonths(1)).toStartOfMonth()).addDays(-1); 
			System.assertEquals(newDate, lastDayFirst);
			orderIntakes.get(1).POPlanReceipt__c = nokiaFinCals[1].Id;
			database.insert(orderIntakes.get(1));
			newDate = OpportunityWarningsCompController.checkMinPlanDateOIF(optyCreation.Id);
			System.assertEquals(newDate, lastDayFirst);
			OpportunityWarningsCompController.overrideDecisionPlanDate(optyCreation.Id,newDate);
			System.assertEquals([Select G5_Planned_Date__c From Opportunity Where Id = :optyCreation.Id].G5_Planned_Date__c, lastDayFirst);
			Test.stopTest();
		}
	}

	@isTest
	static void checkOpptyInfoTest(){

		User userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];

		system.runAs(userCreation){

			Account accountCreation = TestDataFactory.createAccount(1)[0];
			database.insert(accountCreation);

			Test.startTest();
			List<Opportunity> opportunities = TestDataFactory.OpportunityCreation(2,accountCreation);
			opportunities.get(0).recordTypeId = indirectRecordTypeId;
			database.insert(opportunities);
			
			System.assert(OpportunityWarningsCompController.getOpptyInfo(opportunities.get(0).Id));
			System.assertEquals(OpportunityWarningsCompController.getOpptyInfo(opportunities.get(1).Id), false);
			Test.stopTest();
		
		}
	}
	
	@isTest
	static void checkOpptyFields(){
		User userCreation = TestDataFactory.userCreation(1,'System Administrator')[0];
		system.runAs(userCreation){
			Test.startTest();
			String[] fields = OpportunityWarningsCompController.validateFieldsAccessibility();
			System.assert(fields.size() > 0);
			Test.stopTest();
		}
	}
	
}