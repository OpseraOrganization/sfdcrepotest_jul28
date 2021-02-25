/****************************************
* Name : DS_TabRenderingTest
* Author : Accenture

*****************************************/
@isTest
Private class DS_TabRenderingTest{
	
	
	public testmethod static void createTestDP(){
		 
	   // try{
			
			

			User sysAdminUser = TestDataFactory.createSystemAdminUser();
			System.runAs(sysAdminUser){
				
				Account accountCreationDP = TestDataFactory.createAccount(1)[0];
				database.insert(accountCreationDP);
				Test.startTest();
				String orgId = UserInfo.getOrganizationId();
				String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
				Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
				String uniqueName =   dateString + randomInt;
				
			   
				User user1 = new User(alias = 'abc', email = uniqueName + '@nokia.com' , emailencodingkey = 'UTF-8', firstName = 'test', lastname = 'Testing',
									  languagelocalekey = 'en_US', localesidkey = 'en_US',  profileid = UserInfo.getProfileId(),  Country__c= 'Canada',Market__c='MARKET NORTH AMERICA',
									  timezonesidkey = 'America/Los_Angeles', Username = uniqueName+'a' + '@nokia.com' + orgId + '.org',Restriction_Level__c = 'Confidential',Nokia_ID__c = randomInt + '0');
				database.insert(user1); 
				
				//Creating Custom Setting Data
				CH_AccountName__c accauth = new CH_AccountName__c();
				accauth.CH_InvalidName__c = 'Nokia';
				accauth.CH_ValidName__c = 'Nokia-OYJ';
				insert accauth;
				
				List<Contact> ContactList = new List<Contact>();
				Contact conDS = new Contact(lastName=CSWXGlobalConstant.ContactNameDS,AccountId=accountCreationDP.id,Email=CSWXGlobalConstant.EmailContactNameDS );
				Contact conDS2 = new Contact(lastName=CSWXGlobalConstant.ContactNameDS,AccountId=accountCreationDP.id,Email=CSWXGlobalConstant.EmailContactNameDS );
				ContactList.add(conDS);
				ContactList.add(conDS2);
				database.insert(ContactList); 
			   
				User userDS = new User(alias = 'abc', email = uniqueName + '@nokia.com' /*+ orgId '.org' */, emailencodingkey = 'UTF-8', firstName = 'test',lastname = 'Testing',
									   languagelocalekey = 'en_US', localesidkey = 'en_US',  profileid = '00e410000022ds8'/*system.Label.PRM_Partner_Relationship_Manager_Login_ID*/,  Country__c= 'Canada',Market__c='MARKET NORTH AMERICA',
									   timezonesidkey = 'America/Los_Angeles', Username = uniqueName + '@nokia.com' + orgId + '.org',Restriction_Level__c = 'Confidential',Nokia_ID__c = randomInt + '00',ContactId  = conDS.Id );
				
				
			   system.runAs(user1){						
					database.insert(userDS); 
					
					userDS.IsPortalEnabled =  True;
					
					database.update(userDS);
			   }
				Test.stopTest();
				
				File_Upload__c fu = new File_Upload__c();
				fu.Technology__c=CSWXGlobalConstant.Technology ;
				fu.Use_Case__c =CSWXGlobalConstant.Usecase  ;  
				fu.Account__c = accountCreationDP.id;
				insert fu;
				
				ContentVersion contentVersion = new ContentVersion();
				ContentDocumentLink contentlink = new ContentDocumentLink();
				contentVersion = TestDataFactory.createContentVersion(1)[0];  
				
				contentVersion.title = CSWXGlobalConstant.benchmarking;
				database.insert(contentVersion) ;					 
				
				Id theContentDocumentId = [select ContentDocumentId from ContentVersion where Id =: contentVersion.Id limit 1].ContentDocumentId;		
				contentlink = TestDataFactory.createContentDocumentLink(1,accountCreationDP.id, theContentDocumentId)[0];
				contentlink.LinkedEntityId=fu.id;
				database.insert(contentlink) ; 
									
			  
				DP_PortalFilter__c cs1 = new DP_PortalFilter__c();
				cs1.Name = CSWXGlobalConstant.csAllProposal;
				cs1.ProposalStage__c = CSWXGlobalConstant.ACTIVE; 
				cs1.Upsell_Stage__c = CSWXGlobalConstant.readyForReview;
				insert cs1;
				
				
				DP_PortalFilter__c cs2= new DP_PortalFilter__c();
				cs2.Name = CSWXGlobalConstant.csClosedProposal;
				cs2.ProposalStage__c = CSWXGlobalConstant.Approval_stage_Cancel;
				cs2.Upsell_Stage__c = CSWXGlobalConstant.Approval_stage_Cancel;
				insert cs2;
				
				DP_PortalFilter__c cs3= new DP_PortalFilter__c();
				cs3.Name = CSWXGlobalConstant.csForYourReview;
				cs3.ProposalStage__c = CSWXGlobalConstant.ACTIVE; 
				cs3.Upsell_Stage__c = CSWXGlobalConstant.readyForReview;
				insert cs3;
				
				DP_PortalFilter__c cs4= new DP_PortalFilter__c();
				cs4.Name = CSWXGlobalConstant.csValidatedProposal;
				cs4.ProposalStage__c = CSWXGlobalConstant.VALIDATED ;
				cs4.Upsell_Stage__c = CSWXGlobalConstant.convert; 
				insert cs4;
				 
				SWx_Upsell_Proposal__c UpsellProposal=TestDataFactory.upsellList(1,accountCreationDP)[0];
				upsellProposal.Analytics_File_Refer_ID__c='GBR-61940-82356';
				upsellProposal.Analytics_Source__c=CSWXGlobalConstant.AnalyticsSource_CCRE ;
				upsellProposal.Proposal_Status__c=CSWXGlobalConstant.ACTIVE; 
				upsellProposal.Upsell_Status__c=CSWXGlobalConstant.readyForReview ;
				
				upsellProposal.Proposal_Recommendation_Type__c='renewal';
				upsellProposal.P20_Id__c=215616;
				upsellProposal.CurrencyIsoCode='EUR';
				upsellProposal.Unweighted_Value__c=429052.07;
				upsellProposal.Account_ID__c=accountCreationDP.id;
				upsellProposal.Technology__c=CSWXGlobalConstant.Technology ;
				upsellProposal.Use_Case__c=CSWXGlobalConstant.Usecase ;
				upsellProposal.DS_Show_In_Portal__c=true;
				upsellProposal.Sold_To_Party__c = accountCreationDP.id;
				database.insert(UpsellProposal);
				
			   DS_Recommendation_Type__c recomemndationtype = new DS_Recommendation_Type__c(name='CXM');
			   database.insert(recomemndationtype);
				
				System.runAs(userDS) {
					
				   List<String>  recommendationType = DS_TabRendering.Get_typepicklist();
				   List<String>  technologyList = DS_TabRendering.getTechnologies();
				   List<String>  UsecaseList = DS_TabRendering.getUseCaseOnTechnology('TDD LTE');
				  
				   List<String> techList = new List<String>();
				   techList.add('TDD LTE');
				   techList.add('FDD LTE');
				   
				   List<String> ucaseList = new List<String>();
				   ucaseList.add('Energy Efficiency');
				   ucaseList.add('eNB User Capacity');
				   ucaseList.add('Load Balancing');
				
				   
				   List<SWx_Upsell_Proposal__c> filterDP = DS_TabRendering.filterDPRecord(techList[0] ,ucaseList[0] ,CSWXGlobalConstant.allProposal,CSWXGlobalConstant.NONE, recomemndationtype.name );
				   List<SWx_Upsell_Proposal__c> filterDP2 = DS_TabRendering.filterDPRecord(techList[0] ,ucaseList[0] ,CSWXGlobalConstant.csClosedProposal,CSWXGlobalConstant.NONE, recomemndationtype.name);
				   List<SWx_Upsell_Proposal__c> filterDP4 = DS_TabRendering.filterDPRecord(techList[0] ,ucaseList[0] ,CSWXGlobalConstant.csForYourReview,CSWXGlobalConstant.NONE, recomemndationtype.name );
				   List<SWx_Upsell_Proposal__c> filterDP3 = DS_TabRendering.filterDPRecord(techList[0] ,ucaseList[0] ,CSWXGlobalConstant.csValidatedProposal,CSWXGlobalConstant.NONE, recomemndationtype.name);
				   List<SWx_Upsell_Proposal__c> filterDP5 = DS_TabRendering.filterDPRecord(CSWXGlobalConstant.NONE ,CSWXGlobalConstant.NONE,CSWXGlobalConstant.NONE,CSWXGlobalConstant.NONE, recomemndationtype.name);
				   List<SWx_Upsell_Proposal__c> filterDP6 = DS_TabRendering.filterDPRecord('234' ,'123' ,CSWXGlobalConstant.NONE,CSWXGlobalConstant.NONE, recomemndationtype.name);
				
				   List<SWx_Upsell_Proposal__c> filterDP7 = DS_TabRendering.filterDPRecord(techList[0], CSWXGlobalConstant.NONE_OPTION_VALUE, CSWXGlobalConstant.allProposal,CSWXGlobalConstant.QuoteNeeded, recomemndationtype.name);
				   List<SWx_Upsell_Proposal__c> filterDP8 = DS_TabRendering.filterDPRecord(techList[0], CSWXGlobalConstant.NONE_OPTION_VALUE, CSWXGlobalConstant.csClosedProposal,CSWXGlobalConstant.CanNotEntitled, recomemndationtype.name);
				   List<SWx_Upsell_Proposal__c> filterDP9 = DS_TabRendering.filterDPRecord(techList[0], CSWXGlobalConstant.NONE_OPTION_VALUE, CSWXGlobalConstant.csForYourReview,CSWXGlobalConstant.CanBeEntitled, recomemndationtype.name);
				   List<SWx_Upsell_Proposal__c> filterDP10 = DS_TabRendering.filterDPRecord(techList[0], CSWXGlobalConstant.NONE_OPTION_VALUE, CSWXGlobalConstant.csValidatedProposal,CSWXGlobalConstant.Entitled, recomemndationtype.name);
					
				   List<SWx_Upsell_Proposal__c> filterDP11 = DS_TabRendering.filterDPRecord(CSWXGlobalConstant.NONE_OPTION_VALUE, CSWXGlobalConstant.NONE_OPTION_VALUE, CSWXGlobalConstant.allProposal,CSWXGlobalConstant.NONE, recomemndationtype.name);
				   List<SWx_Upsell_Proposal__c> filterDP12 = DS_TabRendering.filterDPRecord(CSWXGlobalConstant.NONE_OPTION_VALUE, CSWXGlobalConstant.NONE_OPTION_VALUE, CSWXGlobalConstant.csClosedProposal,CSWXGlobalConstant.NONE, recomemndationtype.name);
				   List<SWx_Upsell_Proposal__c> filterDP13 = DS_TabRendering.filterDPRecord(CSWXGlobalConstant.NONE_OPTION_VALUE, CSWXGlobalConstant.NONE_OPTION_VALUE, CSWXGlobalConstant.csForYourReview,CSWXGlobalConstant.NONE, recomemndationtype.name);
				   List<SWx_Upsell_Proposal__c> filterDP14 = DS_TabRendering.filterDPRecord(CSWXGlobalConstant.NONE_OPTION_VALUE, CSWXGlobalConstant.NONE_OPTION_VALUE, CSWXGlobalConstant.csValidatedProposal,CSWXGlobalConstant.NONE, recomemndationtype.name);
					
				   List <SWx_Upsell_Proposal__c> sorttest = DS_TabRendering.sortDPRec('Entitlement_Info__c',true,techList[0] ,ucaseList[0] ,CSWXGlobalConstant.csAllProposal,CSWXGlobalConstant.NONE, recomemndationtype.name);
				   List <SWx_Upsell_Proposal__c> sorttest2 = DS_TabRendering.sortDPRec('Identified_Cells__c',true,techList[0] ,ucaseList[0] ,CSWXGlobalConstant.csAllProposal,CSWXGlobalConstant.NONE, recomemndationtype.name);
				   List <SWx_Upsell_Proposal__c> sorttest3 = DS_TabRendering.sortDPRec('Name',false,techList[0] ,ucaseList[0] ,CSWXGlobalConstant.csAllProposal,CSWXGlobalConstant.Entitled, recomemndationtype.name);
				   List <SWx_Upsell_Proposal__c> sorttest4 = DS_TabRendering.sortDPRec('Recommendation_Type__c',false,techList[0] ,ucaseList[0] ,CSWXGlobalConstant.csAllProposal,CSWXGlobalConstant.Entitled, recomemndationtype.name);
				
					DS_TabRendering.Get_entitlepicklist();
				}
				
			}
			
			
	  /*  }catch (Exception ex) {
		   

			ExceptionHandler.addException(ex,CSWXGlobalConstant.DS_TabRenderingTest,CSWXGlobalConstant.createTestDP);
							   
		}	*/
	 
	}
	 
	public testmethod static void getTech_UsecaseTest(){
		 test.startTest();
		 
		DS_Technology_Usecase_Combination__c techCS = new DS_Technology_Usecase_Combination__c();
		techCS.DS_Technology__c='TDD LTE';
		techCS.DS_Usecase__c='Energy Efficiency';
		techCS.Name= 'Tech_usecase';
		insert techCS ;
		
		DS_Util.getTechnologies();
		DS_Util.getUseCaseOnTechnology(techCS.DS_Technology__c);
		DS_TabRendering.getTechnologies();
		DS_TabRendering.getUseCaseOnTechnology(techCS.DS_Technology__c);
	  
		test.stopTest();
		
	}
	
}