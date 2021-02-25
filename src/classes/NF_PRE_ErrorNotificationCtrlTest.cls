/**
 * @name	NF_PRE_ErrorNotificationCtrlTest
 * @author   
 * @since   July 08, 2017
 * @desc	This class helps create customized test data, used in test classes
 * @history 
 */


@isTest
private class NF_PRE_ErrorNotificationCtrlTest{
	 
	
   private static User testUser = NF_TestDataFactory.createAdminUser('System Administrator');
	private static User CurrentUser = NF_TestDataFactory.createAdminUser('System Administrator');
	private static User delegate1User = NF_TestDataFactory.createAdminUser('System Administrator');
	private static User delegate2User = NF_TestDataFactory.createAdminUser('System Administrator');
	private static User delegate3User = NF_TestDataFactory.createAdminUser('System Administrator');
	 private static User Dataloaduser= NF_TestDataFactory.createAdminUser(Label.Data_Loader_Profile_Name);
	private static Account currentAccount;
	 private static Id upsellDealId = Schema.SObjectType.Deal__c.getRecordTypeInfosByName().get('Upsell Deal').getRecordTypeId();
	private static Deal__c upsellDeal;
	private static Opportunity currentOpportunity;
	private static Opportunity currentOpportunityC1;
	private static Opportunity currentOpportunityC2;
	private static Opportunity currentOpportunityC3;
	private static Opportunity currentOpportunityC4;
	private static Opportunity optyCreation1 ;
	
	private static Apttus_Approval__Approval_Request__c currentApprovalRequest;
	
	private static Apttus_Approval__Backup_Approver__c BackupApprover;
	private static Sales_Role__c currentSalesOrg;
	 Private Static List<GroupMember> lstGrpM = new List<GroupMember>();
	 Private Static List<Group> lstGrp = new List<Group>();
		   private static Id oppIndirectRecordTypeId;

	
	public static void setup(){ 
	/*List<File_Sharing_Custom_Setting__c> fileSharingCustomSettingList = new List<File_Sharing_Custom_Setting__c>();
		fileSharingCustomSettingList = TestDataFactory.create_File_Sharing_Custom_Setting();
		database.insert(fileSharingCustomSettingList); 
		
		FileSharingCS=NF_TestDataFactory.createFileSharingCustomSetting('SchedulerOpptyTeamFileShareBatch',
																		'SchedulerOpptyTeamFileShareBatch', 
																		'SchedulerOpptyTeam File Share Batch');
		insert FileSharingCS;
		
		FileSharingCS2=NF_TestDataFactory.createFileSharingCustomSetting('SchedulingTime','2','This is used for scheduling the batch');
		insert FileSharingCS2;
		
		FileSharingCS3=NF_TestDataFactory.createFileSharingCustomSetting('OpportunityTeamBatchSize','10','Opportunity Team Batch Size');
		insert FileSharingCS3;*/
		
		currentAccount = NF_TestDataFactory.createAccount('132456783');
		currentAccount.L5Name__c = 'LAT GCBT CARSO';
		currentAccount.L4Name__c = 'Market Latin America';
		insert currentAccount;
			Account sonAccount = TestDataFactory.createAccount(1)[0];
			sonAccount.AccountNumber = '1234';
			sonAccount.L4Name__c = 'Market India';
			sonAccount.ParentId = currentAccount.Id;
			sonAccount.Active__c = true;
			sonAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
			database.insert(sonAccount);
		upsellDeal = TestDataFactory.createDeal(1)[0];
		 upsellDeal.RecordTypeId = upsellDealId;
		insert upsellDeal;
		oppIndirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.CREATE_INDIRECT_SALES_OPPORTUNITY).getRecordTypeId();
		
		
		currentOpportunity = NF_TestDataFactory.createOpportunity(currentAccount.Id, 'Develop Opportunity', 'Opportunity in Progress', Date.today().addDays(10), 700);
						
		//currentOpportunity.Organisation_Level_5__c = 'LAT GCBT CARSO';
		  currentOpportunity.PSR_Sales_Value_Business_Group_AA__c=1000;
			 currentOpportunity.Contract_Signing_Entity__c='fALU';
		//currentOpportunity.Organisation_Level_4__c = 'Market Latin America';
		currentOpportunity.NF_Facilitator_Notified__c=false;	  
		currentOpportunity.Business_Type__c='Committed Upsell';
		//currentOpportunity.Deal__c = upsellDeal.Id;
		currentOpportunity.Legal_Entity__c = sonAccount.Id;
			currentOpportunity.End_Customer_LE__c = sonAccount.Id;
		insert currentOpportunity ;
		
		
		  optyCreation1 = TestDataFactory.OpportunityCreation(1,currentAccount)[0];					  
			system.debug('optyCreation1>>>'+optyCreation1);
			optyCreation1.RecordTypeId = oppIndirectRecordTypeId;
			optyCreation1.Lead_BG__c = 'NSW';
			optyCreation1.StageName = 'Develop Opportunity';
			optyCreation1.Phase_Status__c = 'Opportunity in Progress';
			optyCreation1.Legal_Entity__c = sonAccount.Id;
			OptyCreation1.End_Customer_LE__c = sonAccount.Id;
			database.insert(optyCreation1);
		}
		
		
		
		 @isTest static void test_init_Notifier() {
		 NCP_CustomerCommunitySetting__c cs = new NCP_CustomerCommunitySetting__c();
		cs.Name = 'Default';
		cs.Customer_Account__c = 'Customer - test';
		cs.Customer_Account_Number__c = '12345';
		cs.Customer_User_Profile__c = 'Customers';
		insert cs;
		system.runAs(testUser){
			setup();
		
		   ApexPages.currentPage().getParameters().put('oppId', currentOpportunity.Id);
			 NF_PRE_ErrorNotificationCtrl ErrorNotifCntrl = new NF_PRE_ErrorNotificationCtrl();
			 ErrorNotifCntrl.init();
			 ErrorNotifCntrl.cancel();
			 
				Test.StartTest();
			optyCreation1.StageName = 'Develop Opportunity';
			optyCreation1.Phase_Status__c = 'Opportunity in Progress';
			database.update(optyCreation1);

			
			
			//Changes
			List<Opportunity> updateRecordType  = TestDataFactory.preSalesOpportunityCreation(4, currentAccount, optyCreation1);
			updateRecordType[0].PSR_Pre_Sales_Risk_Opportunity_Type__c = 'Risk Order';
			updateRecordType[0].PSR_Pre_Sales_Risk_Opportunity_Sub_Type__c='Risk Order Only';
			updateRecordType[0].CurrencyIsoCode = 'USD';
			//updateRecordType[0].PSR_Sales_Value_Business_Group_AA__c=1000;
			updateRecordType[0].PSR_Date_PO_Expected__c=null;
			updateRecordType[0].PSR_SW_R_D_Justification_Explanation__c='';
			updateRecordType[0].CloseDate = System.Today();
			updateRecordType[0].PSR_Description_Justification__c='';
			updateRecordType[1].PSR_Pre_Sales_Risk_Opportunity_Type__c = 'Trial';
			updateRecordType[1].PSR_Pre_Sales_Risk_Opportunity_Sub_Type__c = 'R&D Trial';
			updateRecordType[1].PSR_SW_R_D_Justification_Explanation__c='';
			updateRecordType[1].PSR_Trial_Start_Date__c=null;
			updateRecordType[1].PSR_Trial_Duration__c=NULL;
			updateRecordType[1].PSR_Date_PO_Expected__c=NULL;
			updateRecordType[1].PSR_Trial_Agreement_Status__c='';
			updateRecordType[1].PSR_Is_Cost_Approved_In_Related_LOA_Opty__c='';
			updateRecordType[1].CloseDate = System.Today();
			updateRecordType[2].PSR_Pre_Sales_Risk_Opportunity_Type__c = 'Demo';
			updateRecordType[2].PSR_SW_R_D_Justification_Explanation__c='';
			updateRecordType[2].PSR_Trial_Start_Date__c=null;
			updateRecordType[2].PSR_Trial_Duration__c=NULL;
			updateRecordType[2].CloseDate = System.Today();
			updateRecordType[3].PSR_Pre_Sales_Risk_Opportunity_Type__c = 'Risk Order';
			updateRecordType[3].PSR_Pre_Sales_Risk_Opportunity_Sub_Type__c='Risk Order Only';
			updateRecordType[3].CurrencyIsoCode = 'USD';
			updateRecordType[3].PSR_Cost_Business_Group_MN__c = 10000;
			updateRecordType[3].PSR_Sales_Value_Business_Group_AA__c=1000;
			updateRecordType[3].PSR_Date_PO_Expected__c=System.today();
			updateRecordType[3].PSR_SW_R_D_Justification_Explanation__c='';
			updateRecordType[3].CloseDate = System.Today();
			updateRecordType[3].PSR_Description_Justification__c='Test';
			updateRecordType[3].PSR_is_BOM_BOQ_document_attached__c = true;
			
			insert updateRecordType;
			
			Opportunity updateRecordType1 =  [select id,name,
					PSR_LoA_Level__c,
					PSR_Description_Justification__c,
					PSR_Date_PO_Expected__c,
					PSR_Total_Cost_in_Local_Currency__c,
				   PSR_Lead_Business_Group__c,
					recordTypeId,
					PSR_Total_Sales_Value_in_Local_Currency__c,
					CurrencyIsoCode,
					PSR_Cost_Business_Group_AA__c,
					PSR_Cost_Business_Group_FN__c,
					PSR_Cost_Business_Group_ION__c,
					PSR_Cost_Business_Group_MN__c,		 
					PSR_Cost_Business_Group_GS__c,
					PSR_Cost_BG_NEN__c,
					PSR_Total_Cost_In_Euro__c,
					PSR_SW_R_D_Justification_Explanation__c,
					PSR_Pre_Sales_Risk_Opportunity_Type__c,
					PSR_Pre_Sales_Risk_Opportunity_Sub_Type__c,
					PSR_is_BOM_BOQ_document_attached__c 
				from Opportunity Where id=:updateRecordType[3].id];
			//Change ends
		 system.debug('Oppty.Lead:'+updateRecordType1.PSR_Lead_Business_Group__c);
		   NF_PRE_ErrorNotificationCtrl[] ErrorNotifCntrl1 = new NF_PRE_ErrorNotificationCtrl[4];
			for(integer i=0;i<4;i++)
			{
			ApexPages.currentPage().getParameters().put('oppId', updateRecordType[i].Id);
			ErrorNotifCntrl1[i]=new NF_PRE_ErrorNotificationCtrl();
			ErrorNotifCntrl1[i].init();
			ErrorNotifCntrl1[i].cancel();
			}
			
			Test.StopTest();
		}
		}
		
	 }