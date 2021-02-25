/*******************************
Class Name: OpportunityTriggerHandler
Created By: Accenture
Last Modified By: Accenture
Last Modified Date: 23rd Dec 2016
Description: Handler Class for Opportunity Trigger
Change log : 1.0
1.1 Introduced SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES to stop recusion of opportinity trigger on insert/update of preSales opty
1.1 D-1645 Sprint 5 Hypercare Fixes(Sales Process)
*******************************/
public class OpportunityTriggerHandler
{
	public static Map<Id, Opportunity> preSaleOptyOldMap = new Map<Id, Opportunity>();
	public static List<Opportunity> preSaleOptyList =  new List<Opportunity>();
	public static List<Opportunity> preSalesOptyFilter = new List<Opportunity>();
	public static List<Opportunity> preSaleOptyListWithReadOnly  = new List<Opportunity>();
	public static Map<Id, Opportunity> saleOptyMap = new Map<Id, Opportunity>();
	public static boolean batchFlag = true;
	private static boolean flag = true;
  private static boolean oppflag = true;
  private static boolean opptyFlag = true;
  private static boolean chatterNotified = false;
  public static boolean flagForCompetitor = false;
  public static boolean flagForComp = false;
  public static boolean flagForChatter = false;
  public static boolean flagUpsellChange = true;
	public static boolean flagCommittedVal = true;
	public static boolean flagUpsellDeltaDiff = true;
  public static boolean flagForOwnerInsert = false;
	public static boolean flagForOwnerUpdate = false;
	public static boolean flagUpdateOffer = true;
	private static final Id PSR_ReadOnlyRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.PRESALESRISKOPPORTUNITY_READONLY).getRecordTypeId();
	private static final Id PSR_EditRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.PRESALESRISKOPPORTUNITY).getRecordTypeId();
  private static final Id directRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.DIRECT_OPPTY).getRecordTypeId();
	private static final Id inDirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.INDIRECT_OPPTY).getRecordTypeId();
	private static final Id readOnlyDirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.READONLYDIRECT).getRecordTypeId();
	private static final Id readOnlyIndirectRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.READONLYINDIRECT).getRecordTypeId();

	/*****************************
*Method Name: beforeUpdate
*Description: This is handler method for before update on opportunity
*Parameters: Opportunity List, Opportunity Map
*******************************/
	public static void beforeUpdate(List<Opportunity> optyList, Map<ID, Opportunity> optyOldMap)
	{
		// ignore trigger execution for Data Loader profile users....
		List<Opportunity> Decisionlist=new List<Opportunity>();
		List<Opportunity> psroOptyList = new List<Opportunity>();
		Set<String> stageNameSet = new Set<String>();
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id) && GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES == false ){
			//Req:5072 start
	 for(Opportunity op : optyList){
	  stageNameSet = new Set<String>(GlobalConstants.PSRO_STAGES.split(','));
	  if(stageNameSet.contains(op.stagename)){
		 psroOptyList.add(op);
	  }
	 }
	 if(!psroOptyList.isEmpty()){
	  OpportunityTriggerHelper_PreSales.updateProbabiltyOfPSROptysBeforeUpdateFeature(psroOptyList,optyOldMap); // PreSales Req:5072
	  OpportunityTriggerHelper_PreSales.psroUpdateThreshold(psroOptyList,optyOldMap); //PreSales Sprint 26
	 }
	  preSaleOptyList = OpportunityTriggerHelper_PreSales.getIsApplicableForPreSalesList(optyList);
			system.debug('preSaleOptyList >>>>'+preSaleOptyList);
			if(!preSaleOptyList.isEmpty()){
	preSaleOptyOldMap = OpportunityTriggerHelper_PreSales.getIsApplicableForPreSalesMap(preSaleOptyList,optyOldMap);
	system.debug('in before update preSaleOptyOldMap >> preSaleOptyList >>'+preSaleOptyList + '>>'+preSaleOptyOldMap );
	//OpportunityTriggerHelper_PreSales.updateProbabiltyOfPSROptysBeforeUpdateFeature(preSaleOptyList,preSaleOptyOldMap); // PreSales Req:5072
	OpportunityTriggerHelper_PreSales.costCalculationWhenEstimatedCostChecked(preSaleOptyList,preSaleOptyOldMap);//PreSales Req: 3097
	OpportunityTriggerHelper_PreSales.convertionUpdatePreSales(preSaleOptyList,preSaleOptyOldMap); //PreSales
	OpportunityTriggerHelper_PreSales.populateParentAccountOnPreSalesAndSetDefaultStage(preSaleOptyList,preSaleOptyOldMap); //PreSales:Sprint 6 and 7
	OpportunityTriggerHelper_PreSales.convertVRPSR_validationRule(preSaleOptyList,preSaleOptyOldMap); //PreSales:Sprint 8
	OpportunityTriggerHelper_PreSales.psrGateClassificationAllocation(preSaleOptyList,preSaleOptyOldMap); //PreSales Sprint 12
			}
		}
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id) &&  ITA_IFM_PAD.canRun('NF_ApprovalRequestTrigger') ){

			List<Opportunity> CurrencyList =new List<Opportunity>();
			List<Opportunity> OIFCurrencyList =new List<Opportunity>();
			if(!optyList.isEmpty()&& !CSWXGlobalConstant.oifCheckStatus){
	//OpportunityTriggerHelper.beforeUpdateG2DataFill(optyList);
	CSWXGlobalConstant.oifCheckStatus = true;
			}
			//D-1645 Sprint 5 Hypercare Fixes(Sales Process)
			//	  system.debug('populateEndCustomerAndEndCustomerLegalEntityForDirectRecordType>>before');
			OpportunityTriggerHelper.populateEndCustomerAndEndCustomerLegalEntityForDirectRecordType(optyList,optyOldMap);
			//	system.debug('populateEndCustomerAndEndCustomerLegalEntityForDirectRecordType>>after');
			if(!GlobalConstants.isSearchAndAddEndCustomer){
	OpportunityTriggerHelper.populateDefaultLE(optyList,optyOldMap);
	OpportunityTriggerHelper.populateEndCustomer(optyList,optyOldMap);
			}
			OpportunityTriggerHelper.checkLEIsEmpty(optyList,optyOldMap);
			//OpportunityTriggerHelper.offerPriceChange(optyList, optyOldMap);
			OpportunityTriggerHelper.setAluasTrue(optyList);
			// OpportunityTriggerHelper_preSales.populateParentCurrency(optyList, optyOldMap);
			//OpportunityTriggerHelper_PreSales.PopulateParentCurrency(optyList,optyOldMap);
			OpportunityTriggerHelper.UpdateUserinformation(optyList);
			//Sales Process: Requirement 3062
			//OpportunityTriggerHelper.populateG5ContractApprovalDate(optyList,optyOldMap);
			//Requirement 953
			//OpportunityTriggerHelper.compareUnweightedValueOnDeal(new Map<Id, Opportunity>(optyList));
			for(Opportunity Opptylist:optyList)
			{
	if(Opptylist.OIF_Lines__c<=0 && Opptylist.Amount<>0 && Opptylist.Amount<>Null )
		CurrencyList.add(Opptylist);
			}
			if(CurrencyList.size()>0)
			{
	OpportunityTriggerHelper.convertionrateupdate(CurrencyList);
	//	System.debug('Calling convertionrateupdate');
			}
			//Support Ticket:10920
			OpportunityTriggerHelper.removeLeadBGFreeze(optyList,optyOldMap);
			//Support Ticket:11982
			OpportunityTriggerHelper.removeG3Facilitator(optyList,optyOldMap);
			List<Order_Intake_Forecast__c> OIFList = new List<Order_Intake_Forecast__c>();
			for(Opportunity Opptylist:optyList)
			{
	if(Opptylist.OIF_Lines__c<>0 && Opptylist.Amount<>0 && Opptylist.Amount<>Null && Opptylist.CurrencyIsoCode<>optyOldMap.get(Opptylist.id).CurrencyIsoCode)
		OIFList = [select id, CurrencyIsoCode, OIF_Value_EUR__c, Opportunity__c, OIF_Value__c, POPlanReceipt__c from Order_Intake_Forecast__c where Opportunity__r.id =: Opptylist.id];
			}
			Map<Id,Opportunity> opportunityMap = new  Map<Id,Opportunity>();
			for(Opportunity Opptylist:optyList){
	opportunityMap.put(Opptylist.id,Opptylist);
			}
			/*for(Order_Intake_Forecast__c oif:OIFList){
	OrderIntakeHepler.ChangeCurrency(OIFList,opportunityMap);
			}*/
			
			//Commented above code snippet and added below line for sf ticket #00271170
			if(OIFList.size()>0) OrderIntakeHepler.ChangeCurrency(OIFList,opportunityMap);
		}
		//SF Ticket 1260: Need not to bypass for Dataloader Profile
		//if(!OpptyList.isEmpty())
		//if(optyList != NULL){

		//Sales Process: New Sales Path
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
			//Req 5783
			if(opptyFlag)
			{
	OpportunityTriggerHelper.validateWonShareAllocationSum(new map<Id,Opportunity>(optyList),optyOldMap);
	opptyFlag = false;
			}
			//Requirement 5151
			if(flag)
			{
	 OpportunityTriggerHelper.associateUpsellOpptyWithUpsellDeal(new map<Id,Opportunity>(optyList),optyOldMap);
	flag = false;
			}

	//Req  5073 Sales Process
			if(oppflag)
			{
	OpportunityTriggerHelper.updateWinningCompOnOppty(new map<Id,Opportunity>(optyList),optyOldMap);
	oppflag = false;
			}
			//Req 5150
			OpportunityTriggerHelper.restrictOpptyTypeChange(new map<Id,Opportunity>(optyList),optyOldMap);
			//
			OpportunityTriggerHelper.populateSalesOutcome(optyList, optyOldMap);
			// Requirement 3217
			OpportunityTriggerHelper.populateReasons(new map<Id,Opportunity>(optyList),optyOldMap);
			//Release8:Req#4999
			OpportunityTriggerHelper.committedUpsellOptyClosureValidation(optyList,optyOldMap);
			//Req 4879
			OpportunityTriggerHelper.g4PlannedDateMandatory(new map<Id,Opportunity>(optyList),optyOldMap);
			//Sales process R-8 req#5003
			OpportunityTriggerHelper.opportunityTypeChangeRestriction(optyList,optyOldMap);
			//G2 not 100% bypass
			OpportunityTriggerHelper.updateMultiBG(optyList);
			//Sales Process: 2381
			//OpportunityTriggerHelper.opptyPtaSignedOfferProductOnlyNotSame(new Map<Id, Opportunity>());
			// checking the old and new sales outcome values
			system.debug('OpptyList100'+optyList);
			for(Opportunity Oppupdate:optyList)
			{
	system.debug('inloop');
	system.debug('current value------>>>>'+Oppupdate.StageName);
	system.debug('oldMap value------>>>>'+optyOldMap.get(Oppupdate.ID).StageName);
	if((!Oppupdate.StageName.equalsignorecase(optyOldMap.get(Oppupdate.ID).StageName) && !Oppupdate.StageName.equalsignorecase(GlobalConstants.IN_EXECUTION) && !Oppupdate.StageName.equalsignorecase(GlobalConstants.COMPLETED_OPPTY) )){
		system.debug('Inif');
		Decisionlist.add(Oppupdate);
	}
			}

			//calll the decision period update methods

			if(Decisionlist.size()>0){
	system.debug('Decisionlist'+Decisionlist);
	OpportunityTriggerHelper.DecisonUpdate(Decisionlist);
			}

			//OpptyTriggerHelper.committedUnweightedValue(optyList, optyOldMap);
			//OpptyTriggerHelper.upsellDeltaDifference(optyList, optyOldMap);
			OpportunityTriggerHelper.validateSubstituteOptyWithSameUpsellDeal(optyList, optyOldMap);

			if(flagUpsellChange)
			{
	 OpportunityTriggerHelper.upsellChangeAccepted(optyList,optyOldMap);
	 flagUpsellChange = false;
			}

			if(flagCommittedVal)
			{
			OpportunityTriggerHelper.committedUnweightedValue(optyList, optyOldMap);
	 flagUpsellChange = false;
			}

			if(flagUpsellDeltaDiff)
			{
			OpportunityTriggerHelper.upsellDeltaDifference(optyList, optyOldMap);
	flagUpsellChange = false;
			}

			//if(flagUpdateOffer)
			{
	OpportunityTriggerHelper.UpdateOffer(optyList,optyOldMap);
	flagUpdateOffer = false;
			}
		}
		//   system.debug('after OpportunityTriggerHelper');
		ITA_IFM_PAD.deactivateTrigger('NF_ApprovalRequestTrigger');

	}
	/*****************************
*Method Name: beforeInsert
*Description: This is handler method for before insert on opportunity
*Parameters: Opportunity List
*******************************/
	public static void beforeInsert(List<Opportunity> optyList)
	{
		// ignore trigger execution for Data Loader profile users....
		Id profileId=userinfo.getProfileId();
		List<Opportunity> CurrencyList =new List<Opportunity>();
		flag = false;
		// testing purpose only : upsell oppty
		for(Opportunity  objOppty : optyList)
		{
			system.debug('Upsell Oppty Before Insert : objOppty.Name >>>>'+ objOppty.Name);
			system.debug('Upsell Oppty Before Insert  : objOppty.Phase_Status__c >>>>'+ objOppty.Phase_Status__c);
			system.debug('Upsell Oppty Before Insert  : objOppty.StageName >>>>'+ objOppty.StageName);
		}

		String profileName=[Select Id,Name from Profile where Id=:profileId LIMIT: Limits.getLimitQueryRows() - Limits.getQueryRows()].Name;
		//   system.debug('ProfileName'+profileName);
		ProfileNames__c pN = ProfileNames__c.getInstance(profileName);
		//   System.debug('pN<><><>'+pN);
		if(pN == Null){
			OpportunityTriggerHelper.restrictOpptyCreationByOTMFromDiffrentTerritory(optyList);
		}
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id) && GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES == false){
			//Sales Process : Spring 5: D-1512
			//OpportunityTriggerHelper.populateEndCustomerAndEndCustomerLegalEntityForDirectRecordType(optyList,new map<Id,Opportunity>());
			OpportunityTriggerHelper.setAluasTrue(optyList);
			OpportunityTriggerHelper_PreSales.updateRecordTypeWhenPreSaleTypeIsOtherThanRSRO(optyList,new map<Id,Opportunity>()); // Pre-Sales:Sprint 6: Req#2171
			OpportunityTriggerHelper_PreSales.updateProbabiltyOfPSROptysBeforeInsertFeature(optyList); //Release 8 :Sales Process : req :5072
			preSaleOptyList = OpportunityTriggerHelper_PreSales.getIsApplicableForPreSalesList(optyList);
			if(!preSaleOptyList.isEmpty()){
	//preSaleOptyOldMap = OpportunityTriggerHelper_PreSales.getIsApplicableForPreSalesMap(preSaleOptyList,optyOldMap);
	OpportunityTriggerHelper_PreSales.convertionUpdatePreSales(preSaleOptyList,null); //PreSales
	OpportunityTriggerHelper_PreSales.populateParentCurrencyOnPreSales(optyList,new map<Id,Opportunity>()); //PreSales
	OpportunityTriggerHelper_PreSales.populateParentAccountOnPreSalesAndSetDefaultStage(optyList,new map<Id,Opportunity>()); //PreSales:Sprint 6 and 7
			}
			OpportunityTriggerHelper.DecisonUpdate(optyList);
			if(!GlobalConstants.isSearchAndAddEndCustomer){
	OpportunityTriggerHelper.populateDefaultLE(optyList,new map<Id,Opportunity>());
	OpportunityTriggerHelper.populateEndCustomer(optyList,new map<Id,Opportunity>());
			}
			OpportunityTriggerHelper.UpdateUserinformation(optyList);

			for(Opportunity Opptylist:optyList)
			{
	if(Opptylist.OIF_Lines__c<=0 && Opptylist.Amount<>0 && Opptylist.Amount<>Null )
		CurrencyList.add(Opptylist);
			}
			if(CurrencyList.size()>0)
	OpportunityTriggerHelper.convertionrateupdate(CurrencyList);


		}
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
			OpportunityTriggerHelper.populatePhaseStatusOnInsert(optyList);
			//G2 not 100% bypass
			OpportunityTriggerHelper.updateMultiBG(optyList);
		}
		//No need to by pass for dataLoader
		//Digital Sales: 166
		//CSWX_OpportunityTriggerHelper.assigningG3Approver(optyList);
	}

	/*****************************
*Method Name: afterInsert
*Description: This is handler method for after insert on opportunity
*Parameters: Opportunity List
*******************************/
	public static void afterInsert(List<Opportunity> optyList)
	{
		//Opportunity follow(Req: 722)
		// ignore trigger execution for Data Loader profile users....
		for(Opportunity  objOppty : optyList)
		{
			system.debug('Upsell Oppty AfterInsert : objOppty.Name >>>>'+ objOppty.Name);
			system.debug('Upsell Oppty After Insert  : objOppty.Phase_Status__c >>>>'+ objOppty.Phase_Status__c);
			system.debug('Upsell Oppty After Insert  : objOppty.StageName >>>>'+ objOppty.StageName);
		}
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id) && GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES == false) { // to stop recursive trigger executionof opty
			preSaleOptyList = OpportunityTriggerHelper_PreSales.getIsApplicableForPreSalesList(optyList);
			if(!preSaleOptyList.isEmpty()){
	OpportunityTriggerHelper_PreSales.getNokiaPeriodName(preSaleOptyList,null);//PreSales
	OpportunityTriggerHelper_PreSales.populatePreSalesOpportunityNumber(preSaleOptyList); //preSales : Sprint 7
			}
			OpportunityTriggerHelper.FollowOpportunity(optyList);
			//Requirement 942. Sales Process
	 // OpportunityTriggerHelper.updateDealMasterOppty(optyList);
			//Requirement 953
			if(!CSWXGlobalConstant.oifCheckStatus){
	//OpportunityTriggerHelper.createOIFandOfferonDigiSalesOpportunity(optyList);
	CSWXGlobalConstant.oifCheckStatus = true;
			}
			//Digital Sales Requirement for Offer creation on SWX Oppty's
			if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
	  // OpportunityTriggerHelper.compareUnweightedValueOnDeal(new Map<Id, Opportunity>(optyList), NULL,true);
			}

		}
	Map<Id,Opportunity> opptymap = new Map<Id,Opportunity>();

	if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
			//Sales process Req:5468
			if(!flagForOwnerInsert)
			{
	OpportunityTriggerHelper.insertOwnerInOpptyTeam(optyList);
	flagForOwnerInsert = true;
			}
	  for(Opportunity opptycheck:optyList){
	opptymap.put(opptycheck.id,opptycheck);
			}
			if(opptymap.size() > 0){
	  // OpportunityTriggerHelper.updateCustomerOfferDueDate(opptymap);
			}
		}


		// CSWX_OpportunityTriggerHelper.createProposal(optyList);
		
		//   SF:0069801 > Prevent Oppty creation if user have wrong pricing manager and pricing manager lead in their default oppty team.
		//   Added by HCL Team
	 
			if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
	if(optyList.size() >0){
		
		List<OpportunityTeamMember> oppTeamlst = new List<OpportunityTeamMember>();
		oppTeamlst= [Select id,OpportunityId, user.name,UserId, TeamMemberRole,Additional_Team_Role__c from OpportunityTeamMember where OpportunityId in:optyList];
		if(oppTeamlst.size()>0) OpportunityTriggerHelper.oppTeamPrMValidation(oppTeamlst);
		
		/*for(Opportunity opp :[Select (Select id,OpportunityId, user.name, TeamMemberRole,Additional_Team_Role__c from OpportunityTeamMembers) from Opportunity Where Id IN :optyList]){
			if(opp.OpportunityTeamMembers.size()>0){
	OpportunityTriggerHelper.oppTeamPrMValidation(opp.OpportunityTeamMembers);
			}
		}*/
	}
			}
			
	}

	/*
* @desc	This is handler method for after update on opportunity
* @param   opportunitiesNewMap: the map of opportunities which are approved or rejected
* @param   opportunitiesoldMap: the map of opportunities which are approved or rejected
*/
	/*****************************
*Method Name: afterUpdate
*Description: This is handler method for after Update on opportunity
*Parameters: map<Id,Opportunity> opportunitiesNewMap,map<Id,Opportunity> opportunitiesoldMap
*******************************/
	public static void afterUpdate(map<Id,Opportunity> opportunitiesNewMap,map<Id,Opportunity> opportunitiesoldMap)
	{
		// system.debug('GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES >>>'+GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES );
		//  System.debug('PreSales Field>>>'+opportunitiesNewMap.values()[0].PSR_Total_Cost_in_Euro__c);
		//  System.debug('opportunitiesNewMap----->'+opportunitiesNewMap);
		//   System.debug('opportunitiesoldMap----->'+opportunitiesoldMap);

		Map<Id,Opportunity> OldMap=new  Map<Id,Opportunity>();
		Map<Id,Opportunity> NewMap=new  Map<Id,Opportunity>();
		Map<ID,Opportunity> TaskOfferInfo=new Map<ID,Opportunity>();


		List<opportunity> lstoldOpp= new List<opportunity>();
		Set<Id> ChatterOpptyinfo= new Set<Id>();
		Map<Id,Opportunity> RecallOpptyinfo= new Map<Id,Opportunity>();
		Set<id> Opptyid = new Set<id>();
		Set<id> Opptyallocationid = new Set<id>();
		Map<Id,Opportunity> StakeholderInfo= new Map<Id,Opportunity>();
		Map<ID,Opportunity> WindeclarationInfo =new Map<ID,Opportunity>();
		Map<ID,Opportunity> OfferControlInfo =new Map<ID,Opportunity>();
		List<opportunity> optyList= new List<opportunity>();
		OldMap=opportunitiesoldMap;
		NewMap=opportunitiesNewMap;
		//FT-1553: for April 2020 BP
		//OpportunityTriggerHelper.cloneContractRenewalOpportunity(opportunitiesoldMap,opportunitiesNewMap.values());

		If(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
	  //Req 5073
			if(flagForCompetitor == false){
			OpportunityTriggerHelper.createCompetitorWhenOpportunityClosedNegatively(opportunitiesNewMap.values(),opportunitiesoldMap);
			flagForCompetitor = true;
			}
	  //Req 5073 sales Process
	if(flagForComp == false){
	OpportunityTriggerHelper.createUnknownCompetitorRecord(opportunitiesNewMap.values(),opportunitiesoldMap);
	flagForComp = true;
			}
		//Sales Process Req:5468
			if(!flagForOwnerUpdate)
			{
	OpportunityTriggerHelper.updateOwnerInOpptyTeam(opportunitiesNewMap.values(), opportunitiesoldMap);
	OpportunityTriggerHelper.insertOwnerInTeamOnReopening(opportunitiesNewMap.values(), opportunitiesoldMap);
		flagForOwnerUpdate = true;
			}
			if(GlobalConstants.DeleteOpenTaskFlag!=True){

	OpportunityTriggerHelper.deleteOpenTasks(opportunitiesNewMap,opportunitiesoldMap);
	//system.debug('OPTYLIST'+optyList);
			}
	  // Req 4943
	  OpportunityTriggerHelper.updateUnweightedValueofOpptyGroup(opportunitiesNewMap,opportunitiesoldMap);
			OpportunityTriggerHelper.updateProbabilityOfPSROAsSalesOptyAfterUpdate(opportunitiesNewMap,opportunitiesoldMap); //Sales Process : October Release : Req:5072
	  //Req 4422
			OpportunityTriggerHelper.populate_G4ApprovalCycleTimeOnOffer(opportunitiesNewMap,opportunitiesoldMap);
		}
		lstoldOpp= opportunitiesoldMap.values();
		System.debug('Helpr after update' +GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES );

		//modified for Ticket 00012822 : PSRO cancellation notif email fired when Account LE updated in "Reference Sales Opportunity"
		//if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id) && GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES  == false)
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id) && (GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES  == false || GlobalConstants.notifyByChatter == false))
		{

			preSaleOptyList = OpportunityTriggerHelper_PreSales.getIsApplicableForPreSalesList(opportunitiesNewMap.values());

			if(!preSaleOptyList.isEmpty() && GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES  == false){


	OpportunityTriggerHelper_PreSales.getNokiaPeriodName(preSaleOptyList,null); //PreSales

			}
			preSaleOptyListWithReadOnly = OpportunityTriggerHelper_PreSales.getIsApplicableForPreSalesListWithReadOnly(opportunitiesNewMap.values());
			System.debug('Helpr after update' +preSaleOptyListWithReadOnly );
			if(!preSaleOptyListWithReadOnly.isEmpty()){
	//modified for Ticket 00012822 : PSRO cancellation notif email fired when Account LE updated in "Reference Sales Opportunity"
	  if((GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES  == false || GlobalConstants.notifyByChatter == false) && !chatterNotified) {
		OpportunityTriggerHelper_PreSales.notifyOTMsAndApprovalContributorsWhenClosed(preSaleOptyListWithReadOnly, opportunitiesoldMap, opportunitiesNewMap);
		GlobalConstants.notifyByChatter = true;
		chatterNotified = true;
	}
	if(GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES  == false) {
		//OpportunityTriggerHelper_PreSales.notifyOpportunityTeamMembers(preSaleOptyListWithReadOnly,opportunitiesoldMap); // preSales > Sprint 8 > Req: 2747
		OpportunityTriggerHelper_PreSales.notifyOTMsAndApprovalContributorsWhenReset(preSaleOptyListWithReadOnly, opportunitiesoldMap); // preSales > Sprint 10> Req: 3110
	}
	//end modified for Ticket 00012822
	//commented for Ticket 00012822 : PSRO cancellation notif email fired when Account LE updated in "Reference Sales Opportunity"
	//OpportunityTriggerHelper_PreSales.notifyOTMsAndApprovalContributorsWhenClosed(preSaleOptyListWithReadOnly);
	//OpportunityTriggerHelper_PreSales.notifyOpportunityTeamMembers(preSaleOptyListWithReadOnly,opportunitiesoldMap); // preSales > Sprint 8 > Req: 2747
	//OpportunityTriggerHelper_PreSales.notifyOTMsAndApprovalContributorsWhenReset(preSaleOptyListWithReadOnly, opportunitiesoldMap); // preSales > Sprint 10> Req: 3110
	//end commented for Ticket 00012822
			}
		}
		//This Method will execute only foe dataload profile
		If(UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
			OpportunityTriggerHelper.probabilityUpdateInline(opportunitiesNewMap,opportunitiesoldMap);
		}


		// ignore trigger execution for Data Loader profile users....
		//  System.debug('afteerUpdate'+opportunitiesoldMap);
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)  && ITA_IFM_PAD.canRun('afterUpdateOPP') && !Test.isRunningTest() ){
			//if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
			//SF Ticket 00003242: If 'LoA Bypass offer condition' is No LoA and Active Offer, Reference Opportunity cannot be changed or cannot be blank
			//OpportunityTriggerHelper.validateRefOpptyAndPTASigned(opportunitiesNewMap);
			//	 System.debug('afteerUpdateInside If');
			//OpportunityTriggerHelper.updateOfferswhenG4approvaldateIsUpdated(opportunitiesNewMap); // REQ942
			//	System.debug('Step1');
			//	system.debug('***********************In after update step 1*************');
			Set<ID> opportunitiesMap = new Set<ID>();
			Map<ID,Opportunity> opportunitiesMapforMember = new Map<ID,Opportunity>();
			System.debug('OpportunityRelatedUsers >>>>>'+OldMap);
			System.debug(' NotifyOpportunitymewRelatedUsers >>>>>'+NewMap);

			//Update the Probability
			OpportunityTriggerHelper.probabilityUpdateInline(opportunitiesNewMap,opportunitiesoldMap);

			for (Opportunity newopportunity:NewMap.values()){

	System.debug('Inside Loop NotifyOpportunitymewRelatedUsers '+newopportunity.Apttus_Approval__Approval_Status__c);
	Id prsoReadRecordTypeId=System.Label.PRSO_Read_RecordTypeId;
	Id prsoRecordTypeId=System.Label.PRSO_RecordTypeId;

	if(( OldMap.get(newopportunity.id).RecordTypeId == prsoReadRecordTypeId || OldMap.get(newopportunity.id).RecordTypeId == prsoRecordTypeId || (OldMap.get(newopportunity.ID).Phase_Status__c<>NUll && !OldMap.get(newopportunity.ID).Phase_Status__c.equalsignorecase(GlobalConstants.PENDING_WIN_LOSS_DECLARATION)) )
	   && newopportunity.Apttus_Approval__Approval_Status__c != null && newopportunity.Apttus_Approval__Approval_Status__c!=OldMap.get(newopportunity.id).Apttus_Approval__Approval_Status__c &&
	   (newopportunity.Apttus_Approval__Approval_Status__c.contains(GlobalConstants.APPROVED) || newopportunity.Apttus_Approval__Approval_Status__c.contains(GlobalConstants.REJECTED) ) && GlobalConstants.OPPORTUNITY_APPROVAL==false){
		System.debug('Inside Loop >>>');

		opportunitiesMap.add(newopportunity.Id);


	   }

	if (newopportunity.Apttus_Approval__Approval_Status__c != null && newopportunity.Phase_Status__c<>NUll && newopportunity.Phase_Status__c.equalsignorecase(GlobalConstants.PTA_HANDOVER) && newopportunity.Apttus_Approval__Approval_Status__c.contains(GlobalConstants.APPROVED)
		&& newopportunity.Phase_Status__c!= OldMap.get(newopportunity.Id).Phase_Status__c &&newopportunity.Apttus_Approval__Approval_Status__c != OldMap.get(newopportunity.Id).Apttus_Approval__Approval_Status__c ){

			System.debug('Inside Loop >>>');

			WindeclarationInfo.put(newopportunity.Id,newopportunity);
		}
			}
			if(opportunitiesMap.size()>0 && (!System.isBatch() && !System.isFuture()))
	NF_OpportunityTriggerHelper.NotifyOpportunityRelatedUsers(opportunitiesMap);

			if(!WindeclarationInfo.isEmpty())
	NF_OpportunityTriggerHelper.WindeclarationNotification(WindeclarationInfo);

			//Forecasting Requirement

			for (Opportunity newopportunity:NewMap.values())
			{
	if(newopportunity.Contract_Signing_Entity__c!=null && !newopportunity.Contract_Signing_Entity__c.equalsignorecase(OldMap.get(newopportunity.Id).Contract_Signing_Entity__c) && newopportunity.Contract_Signing_Entity__c.equalsignorecase(GlobalConstants.FALU))
		Opptyid.add(newopportunity.id);

	if(newopportunity.Contract_Signing_Entity__c!=null && !newopportunity.Contract_Signing_Entity__c.equalsignorecase(OldMap.get(newopportunity.Id).Contract_Signing_Entity__c) && newopportunity.Contract_Signing_Entity__c.equalsignorecase(GlobalConstants.FNOK))
		Opptyallocationid.add(newopportunity.id);

			}

			//Allocation line deletion
			if(!Opptyid.isEmpty())
	OpportunityTriggerHelper.DeleteAllocationLine(Opptyid);

			//auto creation of Allocation Lines
			if(!Opptyallocationid.isEmpty())
	OrderIntakeAllocationCreation.OIFAlloctionCreate(Opptyallocationid);

			//Requirement 942. Sales Process
			//OpportunityTriggerHelper.updateDealMasterOppty(opportunitiesNewMap.values());

			ITA_IFM_PAD.deactivateTrigger('afterUpdateOPP');

		}
		//   system.debug('GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES >>>'+GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES );
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id) &&!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Excel_Add_In_Profile_SF_Id) && GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES  == false)
		{
			//String opportunityFinalStage = File_Sharing_Custom_Setting__c.getInstance(GlobalConstants.OPPORTUNITY_DOC_FREEZE_STAGE).Value__c;
			String opportunityFinalStage = System.Label.Opportunity_SalesPhase_FinalStage;
			map<Id,Opportunity> filteredOpportunitiesNewMap = new map<Id,Opportunity>();
			map<Id,Opportunity> filteredOpportunitiesoldMap = new map<Id,Opportunity>();
	  map<Id,String> opptyIdToOfferLOAMap = new map<Id,String>();
			List<Offer__c> offerList = new  List<Offer__c>();
			Set<Id> parentOppIdSet = new Set<Id>();
			offerList  = [SELECT ActiveOffer__c,Id,LoA_Approval_Level__c, Opportunity__c FROM Offer__c WHERE ActiveOffer__c =: TRUE AND Opportunity__c IN: opportunitiesNewMap.keySet()];

			for(Offer__c offerInst : offerList){
	opptyIdToOfferLOAMap.put(offerInst.Opportunity__c, offerInst.LoA_Approval_Level__c);
			}
	  for(Opportunity oppRec : opportunitiesNewMap.values())
			{
	if(oppRec.Phase_Status__c!=null && oppRec.StageName != null){
		if(!(oppRec.Phase_Status__c.equals(opportunitiesoldMap.get(oppRec.Id).Phase_Status__c)) || (oppRec.StageName.equals(opportunityFinalStage) && !oppRec.StageName.equals(opportunitiesoldMap.get(oppRec.Id).StageName)))
		{
			//  System.debug('Freeze/Unfreeze/Upsell Creation Condition statisfied');
			filteredOpportunitiesNewMap.put(oppRec.id,opportunitiesNewMap.get(oppRec.Id));
			filteredOpportunitiesoldMap.put(oppRec.id,opportunitiesoldMap.get(oppRec.Id));

		}
		//	System.debug('Old Phase_Status__c::>'+opportunitiesoldMap.get(oppRec.Id).Phase_Status__c);
		//		System.debug('New Phase_Status__c::>'+oppRec.Phase_Status__c);
		//	System.debug('Old StageName::>'+opportunitiesoldMap.get(oppRec.Id).StageName);
		//	 System.debug('New StageName::>'+oppRec.StageName);
		if(opptyIdToOfferLOAMap.get(oppRec.Id) != 'E'){
			if(oppRec.Phase_Status__c.equals('Pending Win/Loss Declaration') && oppRec.StageName.equals('Win the Case (Negotiate)') && !oppRec.Phase_Status__c.equals(opportunitiesoldMap.get(oppRec.Id).Phase_Status__c))
			{
				//   System.debug('oppRec::>'+oppRec);
				parentOppIdSet.add(oppRec.Id);
			}
		}
	}
			}
			//	System.debug('filteredOpportunitiesNewMap::>'+filteredOpportunitiesNewMap);
			//	  System.debug('filteredOpportunitiesoldMap::>'+filteredOpportunitiesoldMap);

			if(!parentOppIdSet.isEmpty())
			{
	//		System.debug('upSellCreationList::>'+parentOppIdSet);
	if(UpsellOpportunityUtility.firstRun)
	{
		UpsellOpportunityUtility.toCreateUpsellOpportunity(parentOppIdSet);
		UpsellOpportunityUtility.firstRun = false;
	}

			}
		}
		//system.debug('GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES >>>'+GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES );
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id) && GlobalConstants.SKIP_TRIGGER_OPPORTUNITY_ON_PRESALES  == false)
		{
			//  system.debug('After Update G4');
			//Requirement 598: LoA- Snapshot on Active offer at the time of G4 approval.
			//OfferSnapshotCreationHelper.getopptyIds(opportunitiesNewMap,opportunitiesoldMap);

			// REQ#942& defect D-2793; Copy G4/G5 approval date from opportunity to Active Offer.
			if(!GlobalConstants.OPPORTUNITYTRIGGER_HELPER_UPDATE_G4_G5)
			{
	OpportunityTriggerHelper.updateOffersOnG4OrG5ApprovalDateIsUpdated(opportunitiesNewMap, opportunitiesOldMap);
			}

			//OpportunityTriggerHelper.notifyHSSERiskCountry(opportunitiesoldMap, opportunitiesNewMap);//Req 758
			//SF Ticket 00003242: If 'LoA Bypass offer condition' is No LoA and Active Offer, Reference Opportunity cannot be changed or cannot be blank
			// system.debug('After Update validateRefOpptyAndPTASigned');
			//OpportunityTriggerHelper.validateRefOpptyAndPTASigned(opportunitiesNewMap, opportunitiesoldMap);
			//Checking for direct and indirect opty

			saleOptyMap = OpportunityTriggerHelper.getIsApplicableForSalesNewMap(opportunitiesNewMap);

			if(!saleOptyMap.isEmpty()){
	//system.debug('in if loop>>>>');
	OpportunityTriggerHelper.validateRefOpptyAndPTASigned(saleOptyMap, opportunitiesoldMap); //sales process
	OpportunityTriggerHelper_preSales.populateParentCurrency(saleOptyMap.values(), opportunitiesoldMap);
	//OpportunityTriggerHelper_preSales.populateParentAccount(saleOptyMap.values(), opportunitiesoldMap); //Presales Req:2359 descoped
			}

			//system.debug('After Update validateRefOpptyAndPTASigned 1');
			//OpportunityTriggerHelper.changeMasterOpportunityOnDeal(opportunitiesNewMap,opportunitiesoldMap);
			if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
	//Sales Process Req 3158(Sprint 9)
	OpportunityTriggerHelper.chatterPostToAccountManager(opportunitiesNewMap,opportunitiesoldMap);
	//Sales process Req-5090 Release 8
	OpportunityTriggerHelper.updateSSOOnUnweightedValueChange(opportunitiesNewMap,opportunitiesoldMap);
	//Digital Sales: US 164
	// CSWX_OpportunityTriggerHelper.AccountTeamNotification(opportunitiesNewMap,opportunitiesoldMap);
			}
			opportunitytriggerhelper.offerPriceChange(opportunitiesNewMap.values(),opportunitiesoldMap);

			//   OpportunityTriggerHelper.checkLEIsEmpty(opportunitiesNewMap,opportunitiesoldMap);
			//Requirement 953
			if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
	//OpportunityTriggerHelper.compareUnweightedValueOnDeal(opportunitiesNewMap,opportunitiesoldMap,false);
			}
			// system.debug('opportunitiesNewMap.values()>>>>'+opportunitiesNewMap.values());
			for(Opportunity opty : opportunitiesNewMap.values()){
	preSalesOptyFilter.add(opty);
			}
			//  system.debug('preSalesOptyFilter>>>>'+preSalesOptyFilter);

			//Requirement #2558: Sales Process: Bypass only for data loader profile
			if(batchFlag == true){
	//  system.debug('Account change');
	//opportunitytriggerhelper.UpdateOrgLevelOnOpptyFromAcc(opportunitiesNewMap.values(),opportunitiesOldMap);
	batchFlag = false;
			}

	 // Opportunity Close Notification
			// Sales process Req-5077
			if(!GlobalConstants.OPPORTUNITY_CLOSE_CHECK && !flagForChatter) {
	OpportunityTriggerHelper.OpportunityClosure(NewMap,OldMap);
	//flagForChatter = true ;
			}

			// Opportunity Recall Notification
			for(Opportunity Opptydata:NewMap.values())
			{

	if(Opptydata.RecordTypeId!=PSR_EditRecordTypeID&&Opptydata.RecordTypeId!=PSR_ReadOnlyRecordTypeID && Opptydata.Apttus_Approval__Approval_Status__c<>Null && OldMap.get(Opptydata.id).Apttus_Approval__Approval_Status__c<>Null && Opptydata.Apttus_Approval__Approval_Status__c<>OldMap.get(Opptydata.id).Apttus_Approval__Approval_Status__c && Opptydata.Apttus_Approval__Approval_Status__c.equalsignorecase(GlobalConstants.CANCEL) )
		RecallOpptyinfo.put(Opptydata.ID,OldMap.get(Opptydata.ID));

	If(Opptydata.Apttus_Approval__Approval_Status__c<>Null && OldMap.get(Opptydata.id).Apttus_Approval__Approval_Status__c<>Null && Opptydata.Apttus_Approval__Approval_Status__c<>OldMap.get(Opptydata.id).Apttus_Approval__Approval_Status__c && Opptydata.Apttus_Approval__Approval_Status__c.equalsignorecase(GlobalConstants.PENDING_APPROVAL) && Opptydata.StageName<>Null && Opptydata.Phase_Status__c<>NUll && (  (Opptydata.LOA_Level__c<>NUll && Opptydata.Phase_Status__c.equalsignorecase(GlobalConstants.SUBMITTED_FOR_G5_APPROVAL) && Opptydata.LOA_Level__c.equalsignorecase(GlobalConstants.LOA_Level_A_Plus))  || !Opptydata.StageName.equalsignorecase(GlobalConstants.WIN_THE_CASE_NEGOTIATE)) )
		StakeholderInfo.put(Opptydata.ID,Opptydata);

	If(Opptydata.Apttus_Approval__Approval_Status__c<>Null && OldMap.get(Opptydata.id).Apttus_Approval__Approval_Status__c<>Null && Opptydata.Apttus_Approval__Approval_Status__c<>OldMap.get(Opptydata.id).Apttus_Approval__Approval_Status__c && Opptydata.Apttus_Approval__Approval_Status__c.equalsignorecase(GlobalConstants.PENDING_APPROVAL) && Opptydata.Phase_Status__c<>Null
	   && (Opptydata.Phase_Status__c.equalsignorecase(GlobalConstants.SUBMITTED_FOR_G4_APPROVAL) || Opptydata.Phase_Status__c.equalsignorecase(GlobalConstants.SUBMITTED_FOR_G5_APPROVAL) ) )
		OfferControlInfo.put(Opptydata.ID,Opptydata);

	IF( Opptydata.Apttus_Approval__Approval_Status__c<>Null && OldMap.get(Opptydata.id).Apttus_Approval__Approval_Status__c<>Null && Opptydata.Apttus_Approval__Approval_Status__c<>OldMap.get(Opptydata.id).Apttus_Approval__Approval_Status__c
	   && Opptydata.Apttus_Approval__Approval_Status__c.contains(GlobalConstants.APPROVED) && Opptydata.StageName<>Null && Opptydata.Phase_Status__c<>Null &&  (Opptydata.Phase_Status__c.equalsignorecase(GlobalConstants.OFFER_SUBMITTED_TO_CUSTOMER_MANUAL)
													&& Opptydata.StageName.equalsignorecase(GlobalConstants.WIN_THE_CASE_NEGOTIATE)) )
		TaskOfferInfo.put(Opptydata.ID,Opptydata);
			}

			if(!RecallOpptyinfo.isEmpty() && !GlobalConstants.OPPORTUNITY_RECALL_CHECK)
	NF_OpportunityTriggerHelper.RecallNotification(RecallOpptyinfo);
			IF(!StakeholderInfo.isEmpty() && !GlobalConstants.OPPORTUNITY_CHATTER_CHECK)
	NF_OpportunityTriggerHelper.ChatterPostToStakeHolders(StakeholderInfo,false);
			If(!OfferControlInfo.isEmpty() && !GlobalConstants.OFFER_BOOLEAN_CHECK)
	NF_OpportunityTriggerHelper.NotifyOfferController(OfferControlInfo);

			If(!TaskOfferInfo.isEmpty())
	NF_OpportunityTriggerHelper.CloseTheG4SubmissionTask(TaskOfferInfo);

			Set<ID> OpptyMap =new Set<ID>();
			//Massupdate on OIF lines
			for(Opportunity Opptydata:NewMap.values())
			{
	if(!system.isfuture() && Opptydata.Sales_Outcome__c<>NUll && (!Opptydata.Sales_Outcome__c.equalsignorecase('') &&!Opptydata.Sales_Outcome__c.equalsignorecase(GlobalConstants.WON) && !Opptydata.Sales_Outcome__c.equalsignorecase(GlobalConstants.WON_REQUESTED)))
		OpptyMap.add(Opptydata.ID);
			}

			IF(!OpptyMap.isEmpty() && !System.isFuture() && !System.isBatch())
	OpportunityTriggerHelper.MassupdateonOIFLines(OpptyMap);
		}

map<Id,Opportunity> maptoUpdate = new map<Id,Opportunity>();
	 if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id))
	{
	//common method for NF_opportunitytriggerhelper
	   NF_OpportunityTriggerHelper.Common_method_calls(NewMap,OldMap);
	//IWA_Req.5005_Upsell_Approver_Notification
		NF_UpsellNotificationHelper.notifyUpsellApprovers(opportunitiesNewMap,opportunitiesOldMap);

		for(Opportunity OpptyCheck:NewMap.values()){
	if(OpptyCheck.G4_Planned_Date__c != opportunitiesoldMap.get(OpptyCheck.id).G4_Planned_Date__c){

		maptoUpdate.put(OpptyCheck.id,OpptyCheck);

	}
			}
			if(maptoUpdate.size() > 0){
	OpportunityTriggerHelper.updateCustomerOfferDueDate(opportunitiesNewMap);
			}
			}
/* //IWA_Req.5005_Upsell_Approver_Notification
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id))
	{system.debug('After delta');
			NF_UpsellNotificationHelper.notifyUpsellApprovers(opportunitiesNewMap, opportunitiesOldMap);
		} */
		
		// SF:0069801 > Prevent to add wrong PRM/ PRM lead OTM on opportunity whenever owner gets changed
		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)){
	
			List<OpportunityTeamMember> oppTeamlst = new List<OpportunityTeamMember>();
			
			system.debug('new opp set:'+ opportunitiesNewMap.keySet());
			for(OpportunityTeamMember oppTm :[Select id,OpportunityId,user.name,UserId,TeamMemberRole,Additional_Team_Role__c from OpportunityTeamMember Where OpportunityId IN :opportunitiesNewMap.keySet()]){
	if(opportunitiesNewMap.get(oppTm.OpportunityId).ownerid != opportunitiesOldMap.get(oppTm.OpportunityId).ownerid){
	oppTeamlst.add(oppTm);
	}
			}
			
			if(oppTeamlst.size()>0) OpportunityTriggerHelper.oppTeamPrMValidation(oppTeamlst);
			
			/*for(Opportunity opp :[Select id,ownerId,(Select id,OpportunityId,user.name,TeamMemberRole,Additional_Team_Role__c from OpportunityTeamMembers) from Opportunity Where Id IN :opportunitiesNewMap.keySet()]){
	if(opportunitiesNewMap.get(opp.id).ownerid != opportunitiesOldMap.get(opp.id).ownerid){
		if(opp.OpportunityTeamMembers.size()>0){
	OpportunityTriggerHelper.oppTeamPrMValidation(opp.OpportunityTeamMembers);
		}
	}
			}*/
			
		} 
		
	}
	/*****************************
*Method Name: afterDelete
*Description: This is handler method for after Delete on opportunity
*Parameters: map<Id,Opportunity> opportunitiesNewMap
*******************************/
	public static void afterDelete(Map<Id, Opportunity> opptyoldMap){
		//Requirement 953
		//IWA Test Class are failing so adding this condition
/*		if(!UserInfo.getProfileId().equalsIgnoreCase(system.Label.Data_Loader_Profile_Id)&&!test.isrunningtest())
OpportunityTriggerHelper.compareUnweightedValueOnDeal(opptyoldMap,NUll,true); //SalesProcess : Sprint 8 : Req#3303*/
	}
}