@isTest
public class IndirectCPQ_ProposalTriggerHelperTest {
	
	public static testmethod void updateStatusonLITest(){
		Id RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.INDIRECT_OPPTY).getRecordTypeId(); 
		
		Account accCustomer = TestDataFactory.createAccount(1)[0];
		accCustomer.AccountNumber='100006843';
		accCustomer.BusinessPartnerRole__c= GlobalConstants.Alliance;
		accCustomer.Market__c = 'Market India';
		accCustomer.L7Name__c = 'APJ ANO CT Ooredoo Myanmar';
		accCustomer.Partner_Program__c ='GPP 3.0';
		accCustomer.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
		database.insert(accCustomer);
		
		Account accLegalEntity = TestDataFactory.createAccount(1)[0];
		accLegalEntity.AccountNumber='1000068431';
		accLegalEntity.ParentId=accCustomer.ID;
		accLegalEntity.Default_Legal_Entity__c = True ;
		accLegalEntity.Active__c = true;
		accLegalEntity.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		database.insert(accLegalEntity);
		
		Accreditation__c accreditations = NOKIA_CPQ_TestDataFactory.createAccreditationforProd(1)[0];
		accreditations.partner__c = accCustomer.Id;
		accreditations.Accreditation_Type__c = 'Product';
		accreditations.Accreditation_Level__c = 'Authorized';
		accreditations.Pricing_Level_Override__c ='Authorized';
		accreditations.Portfolio__c='IP Routing' ; 
		accreditations.RecordTypeId = Schema.SObjectType.Accreditation__c.getRecordTypeInfosByName().get('Reseller GPP 3.0').getRecordTypeId();
		insert accreditations;
		 
		Accreditation__c accreditation_main = NOKIA_CPQ_TestDataFactory.createAccreditationforProd(1)[0];
		accreditation_main.partner__c = accCustomer.Id;
		accreditation_main.Accreditation_Type__c = 'Maintenance';
		accreditation_main.Accreditation_Level__c = 'Authorized';
		accreditation_main.Pricing_Level_Override__c ='Authorized - Accreditation In Progress';
		accreditation_main.Portfolio__c='IP Routing' ; 
		accreditation_main.RecordTypeId = Schema.SObjectType.Accreditation__c.getRecordTypeInfosByName().get('Reseller GPP 3.0').getRecordTypeId();
		insert accreditation_main;
		
		test.startTest();
		opportunity opty = new Opportunity();
		opty.Name = 'test';
		opty.Lead_BG__c = 'ION';
		opty.Lead_BU__c = 'ION IPR';
		opty.AccountId = accCustomer.Id;
		opty.Business_Type__c = GlobalConstants.STANDARDOPPORTUNITY;
		opty.Unweighted_Amount_EUR__c =0;
		opty.Contract_Signing_Entity__c = 'fALU';
		opty.G3_Planned_Date__c = System.today();
		opty.G4_Planned_Date__c = System.today();
		opty.G5_Planned_Date__c = System.today().addMonths(3);
		opty.G6_Planned_Date__c = System.today().addMonths(4);
		opty.CloseDate = System.today().addMonths(3);
		opty.StageName = GlobalConstants.IDENTIFY_OPPORTUNITY;
		opty.Phase_Status__c = GlobalConstants.PLANNED;
		opty.RecordTypeId = RecordTypeId;
		opty.End_Customer_LE__c =accLegalEntity.Id;
		
		database.insert(opty);
		
		Apttus_Proposal__Proposal__c quote = TestDataFactory.createProposal(1)[0];
		quote.Apttus_Proposal__Opportunity__c = opty.Id;
		quote.Apttus_Proposal__Account__c = accCustomer.ID;
		quote.NokiaCPQ_Portfolio__c= 'IP Routing';
		quote.NokiaProductAccreditation__c=accreditations.Id;
		quote.NokiaCPQ_Maintenance_Accreditation__c=accreditation_main.Id;
		database.insert(quote);
		
		 Apttus_Config2__ProductConfiguration__c prodconfig = TestDataFactory.createProductConfiguration(quote);
		prodconfig.Apttus_Config2__Status__c = Nokia_CPQ_Constants.Saved ;
		database.insert(prodconfig);
		
		 Apttus_Config2__LineItem__c lineItem = new Apttus_Config2__LineItem__c();
	   // lineItem.Apttus_Config2__ClassificationHierarchy__c = 'SWX Product Catalogue | Radio | LTE';
		lineItem.Apttus_Config2__ItemSequence__c = 1;
		lineItem.Apttus_Config2__LineNumber__c = 1;
		lineItem.Apttus_Config2__ConfigurationId__c=prodconfig.id;
		lineItem.Apttus_Config2__ChargeType__c=Nokia_CPQ_Constants.STANDARD;
		database.insert(lineItem);
		
		quote.Maintenance_Y1__c = 100;
		update quote;
Set<Id>quoteidSet = new Set<Id>();
quoteidSet.add(quote.Id);
		
	   IndirectCPQ_ProposalTriggerHandler.afterUpdateMethod(null,null);
	 IndirectCPQ_ProposalTriggerHelper.updateStatusonLI(quoteidSet);
		test.stopTest();
		
	}
	
}