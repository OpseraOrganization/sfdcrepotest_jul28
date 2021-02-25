/*************************************************************
@Name: Nokia_CPQ_Constants
@Author: Rupesh Sharma
@CreateDate: 22 Aug 2017.
@Description: This class contains constants used in apex code
@UsedBy: Many Classes and Triggers
******************************************************************/
public class Nokia_CPQ_Constants {
	
	public static final String NOKIA_PRODUCT_NAME_SSP = 'SSP';
	public static final string NOKIA_PARTNER_PROFILE_NAME='PRM Partner Community User Login';
	public static final string NOKIA_EMPTY = '';
	public static final string NOKIA_PARTNER_RELATIONSHIP_MANAGER='PRM Partner Relationship Manager Login';
	public static final String NOKIA_PRODUCT_NAME_SRS = 'SRS';
	public static final String NOKIA_ACCRED_TYPE_PRODUCT = 'Product';
	public static final String NOKIA_ACCRED_TYPE_MAINTENANCE = 'Maintenance';
	public static final String NOKIA_IP_ROUTING = 'IP Routing';
	public static final String NOKIA_FIXED_ACCESS_POL = 'Fixed Access - POL';
	public static final String NOKIA_FIXED_ACCESS_FBA = 'Fixed Access - FBA';
	public static final String NOKIA_NUAGE = 'Nuage';
	public static final String NOKIA_NFM_P = 'NFM-P';
	public static final String NOKIA_MAINT_Y1 = 'Maintenance Year1';
	public static final String NOKIA_MAINT_Y2 = 'Maintenance Year2+';
	public static final String NOKIA_UNLIMITED = 'Unlimited';
	public static final String NOKIA_BIENNIAL = 'Biennial';
	public static final String NOKIA_GOLD = 'Gold';
	public static final String NOKIA_BRONZE = 'Bronze';
	public static final String NOKIA_NO = 'No';
	public static final String NOKIA_YES = 'Yes';
	public static final String NOKIA_BOM = 'BOM';
	public static final String NOKIA_BOM_APP = 'BOM_';
	public static final String NOKIA_Q2C = 'PPA';
	public static final String NOKIA_ORDERGENERATION = 'Order Generation';
	public static final String NOKIA_PRICECATALOGEXPORT = 'PriceCatalogExport';
	public static final String NOKIA_QUOTESUMMARY = 'Quote Summary';
	public static final String NOKIA_EXPORTQUOTE  = 'Export Quote';
	public static final String NOKIA_BASICEXPORTQUOTE = 'Basic Quote-Indirect'; //Added by RG for Req 6611
	public static final String NOKIA_DIRECTEXPORTQUOTE  = 'Direct Export Quote';
	public static final String NOKIA_CSPEXPORT  = 'CSP Export';
	public static final String NOKIA_PROPOSAL  = 'Proposal';
	public static final String NOKIA_CHARGE_TYPE_ERROR_MSG  = 'Competitive Additional Discount can only be entered at Total (One Time) level. Please remove CAD Amount from other Sub Totals and click Reprice.';
	public static final String NOKIA_CAD_ERROR_MSG  = 'Competitive Additional Discount can not be entered more than Total (One Time) SubTotal. Please correct CAD Amount and click Reprice.';
	public static final String NOKIA_STRING_APPENDER  = '~~';
	public static final String NOKIA_MAINTENANCE_STRING_APPENDER  = 'Maintenance~~';
	public static final String NOKIA_PRODUCT_STRING_APPENDER  ='Product~~';
	public static final String NOKIA_OPTION  ='Option';
	public static final String ERRORMSG2 ='The Quote cannot be finalized as it contains products that do not belong to the portfolio you selected on the quote. Please remove the following items:';
	public static final String ERRORMSG1 ='The Quote cannot be validated as it contains products that are no longer available for purchase. Please remove the following items:';
	public static final String NOKIA_PRODUCT_SERVICES ='Product/Service';
	public static final String NOKIA_UNDERSCORE = '_'; 
	public static final String NOKIA_MAINTENANCE_CATALOGUE='Maintenance Catalogue_';
	public static final String NOKIA_PPA='PPA-';
	public static final String NOKIA_URL_PART1='/apex/Apttus_XApps__EditInExcelLaunch?selectedRecordId=';
	public static final String NOKIA_URL_PART2='&appName=';
	public static final String NOKIA_URL_PART3='&mode=touchless&outputType=EXCEL';
	public static final String NOKIA_URL_PART4='&mode=touchless&outputType=None';
	public static final String NOKIA_APPNAME='appName';
	public static final String NOKIA_SELECTED_RECORD_ID='selectedRecordId';
	
	public static final String NOKIA_PRM='PRM';
	public static final String NOKIA_PRODUCTID_SITE_APPENDER = '--';
	public static final String NOKIA_PRODUCTCODE_ERROR_MSG = 'Either the Product is inactive or does not exist.';
	public static final String NOKIA_NULL = 'null';
	public static final String NOKIA_PRODUCT_LOADED_MSG = 'Products loaded successfully..';
	public static final String NOKIA_STRING_ID = 'id';
	public static final String NOKIA_COMMA = ',';
	public static final String NOKIA_NEW_LINE = '\n';
	public static final String NOKIA_NULL_APPENDER = '--null';
	public static final String NOKIA_PRODUCT_NOTEXIST_MSG = 'Product codes do not exist';
	public static final String NOIKA_FILE_NOTSELECT_MSG = 'No File Selected';
	public static final String NOKIA_CSVFILE_ERROR_MSG = 'CSV File Error';
	public static final String NOKIA_PRODUCT_UPLOADERROR_MSG = 'Products Upload Error';
	public static final String NOKIA_PRODUCT_LOADED_MSG2 = 'Product loaded....';
	public static final String NOKIA_RETURN_TOCORT_URL1 = '/apex/Apttus_QPConfig__ProposalConfiguration?id=';
	public static final String NOKIA_RETURN_TOCORT_URL2 = '&flow=NewUIPartner';
	public static final String NOKIA_PRODUCT_VERSION = 'Apttus_Config2__ProductVersion__c';
	public static final String SOURCE = 'Source__c';
	public static final String CSV = 'CSV';
	public static final String  NOKIA_YEAR1_MAINTENANCE='Year 1 Maintenance';
	public static final String NOKIA_YEAR2_BEYOND='Maintenance for Y2 and Beyond';
	public static final String NOKIA_YEAR2_BEYOND2='Maintenance for Y2 & Beyond';
	public static final String NOKIA_SSP='SSP';
	public static final String NOKIA_SRS='SRS';
	public static final String DEPLOY_SERVICES='Deploy Services';
	
	
	
	//O2Q Constants Start
	public static final String FINALIZED = 'Finalized';
	public static final String FINALIZEDERRORMESSAGE = 'Please finalize the cart';
	public static final String CREATEOFFERSTAGE = 'Create offer (bid)';
	public static final String WINTHECASESTAGE = 'Win the Case (Negotiate)';
	public static final String PLEASECREATEOFFER = 'Please create an offer with LoA Level to proceed';
	public static final String PLEASECONFIGUREPRODUCTS = 'Please configure products in the quote to proceed';
	public static final String LOABYPASS = 'LoA Bypass';
	public static final String QUOTECANNOTBEVALIDATED = 'Quote cannot be validated at the cuurent opportunity stage';
	public static final String SUBMITTEDG4APPROVAL = 'Submitted for G4 Approval';
	public static final String OPPORTUNITYUNDERAPPROVAL = 'Opportunity is already pending approval';
	public static final String QUOTEDRAFT = 'Draft';
	public static final String QUOTEINREVIEW = 'In Review';
	public static final String QUOTEAPPROVED = 'Approved';
	public static final String QUOTEEXPIRED = 'Expired';
	public static final String QUOTEREJECTED = 'Rejected';
	public static final String QUOTECLOSED = 'Closed(not won)';
	public static final String OPTION = 'Option';
	public static final String QUOTEAPPROVEDSTATUS = 'Quote Approved';
	public static final String INREVIEWMESSAGEPARTNER = 'Quote is In Review. You will be notified when the Quote is approved.';
	public static final String INREVIEWMESSAGEPSM = 'Quote is In Review, please submit the opportunity for G4 approval to complete the quote approval.';
	public static final String INVALIDOFFERPARTNER = 'Quote cannot be validated. Please contact your Partner Sales Manager (Invalid Offer condition).';
	public static final String INVALIDOFFERPSM = 'Quote cannot be validated against the Active Offer. Please create a new Active Offer with the required conditions.';
	public static final String SLASH = '/';
	public static final String OPPORTUNITY = 'Opportunity';
	public static final String OPPORTUNITYCANNOTBEVALIDATED = 'Quote cannot be validated.Opportunity should be in Create offer(bid) stage.';
	public static final String VALIDATECLASS = 'NokiaCPQ_Validate_Quote_Ctrlr';
	public static final String FUTURE = 'Future';
	public static final String APPROVALMETHODNAME = 'submitforApproval';
	public static final String QUOTEIDPARAMETER = 'quoteId';
	public static final String OPPIDPARAMETER = 'oppId';
	public static final String USDCURRENCY = 'USD';
	public static final String OPPORTUNITYSIDE = 'NokiaCPQ_Opportunity_Site__c';
	public static final string PRODUCTCATALOG = 'Product Catalogue';
	
	public static final string MAINTY1CODE = 'MT001';
	public static final string MAINTY2CODE = 'MT002';
	public static final string SSPCODE = 'SSP002';
	public static final string SRS = 'SRS001';
	public static final string INCENTIVES_STRING_APPENDER = 'Incentives~~';
	public static final string RENEWAL_STRING_APPENDER = 'Renewal~~';
	public static final string ATTACHMENT_STRING_APPENDER = 'Attachment~~';
	public static final string MULTIYR_STRING_APPENDER = 'Multi-Year~~';
	public static final string PERFORMANCE_STRING_APPENDER = 'Performance~~';
	public static final string OPTICS = 'Optics';
	
	// O2Q Constant END
	//static variable to handle recursion
	public static String ProductAfterTriggerExecute = 'False';
	public static String ProposalBeforeUpdateTriggerExecute = 'False';
	public static String ProposalAfterUpdateTriggerExecute = 'False';
	public static String PCBBEFOREPRICINGINADJ = 'False';
	public static String ProposalAfterUpdate = 'True';
	public static String ProposalBeforeUpdate = 'True';
	public static String ProductConfigAfterUpdate = 'True';
	

	public static final string QUOTE_TYPE_INDIRECTCPQ = 'Indirect CPQ';
	public static final string QUOTE_TYPE_DIRECTCPQ = 'Direct CPQ'; 
	public static final string EUR_CURR = 'EUR';
	public static final string PLTYPE_DIRECT = 'Direct';
	public static final string PLTYPE_CPQ = 'CPQ';
	public static final string OBJECT_ACCOUNT = 'Account';
	public static final string QUOTE_TYPE_DS = 'DS';
	
	
	//Maintenance Type Lightnimg component constants
	public static final string Maintenance_Type_List_Values = 'Bronze (Return for Exchange);Gold (Return for Exchange);Gold (Return for Repair);Gold & Advanced Exchange Next Business Day';
	public static final string PROPOSAL_OBJECT = 'Apttus_Proposal__Proposal__c';
	public static final string FAIL_STRING = 'FAIL';
	public static final string SUCCESS_STRING = 'SUCCESS';
	public static final string IP_ROUTING_STRING = 'IP Routing';
	public static final string AIRSCALE_WIFI_STRING = 'Airscale Wifi';
	public static final string SSP_DEFAULT_VALUE = 'Unlimited';
	public static final string SRS_DEFAULT_VALUE = 'Unlimited';
	public static final string NO_STRING = 'No';
	public static final string YES_STRING = 'Yes';
	public static final string ONE_YEAR_STRING = '1';
	public static final string TWO_YEAR_STRING = '2';
	public static final string THREE_YEAR_STRING = '3';
	public static final string FIVE_YEAR_STRING = '5';
	public static final string MAINT_TYPE_DEFAULT_VALUE = 'Gold (Return for Exchange)';
	public static final string PRICING_LEVEL_ALL_OTHERS = 'All Others';
	public static final string BRAND_STRING = 'Brand';
	public static final string AED_STRING = 'AED';
	public static final string STRING_EXISTING_MAINT_CNT = 'NokiaCPQ_Existing_IONMaint_Contract__c';
	public static final string STRING_SSP_API_NAME = 'NokiaCPQ_SSP_Level__c';
	public static final string STRING_SRS_API_NAME = 'NokiaCPQ_SRS_Level__c';
	public static final string STRING_NO_OF_YEARS = 'NokiaCPQ_No_of_Years__c';
	public static final string NONE_STRING = '--None--';
	public static final string IN_REVIEW_STRING = 'In Review';
	public static final string APPROVED_STRING = 'Approved';
	public static final string EXPIRED_STRING = 'Expired';
	public static final string CLOSED_NOT_WON_STRING = 'Closed(not won)';
	public static final string ACCEPTED_STRING = 'Accepted';
	public static final string BLANK_STRING = ' ';
	public static final string BLANK_STRING_WITHOUT_SPACE = '';
	public static final string SEMICOLON_STRING = ';'; 
	public static final string UPDATE_MAINTENANCE_TYPE_VALUE = 'updateMaintenanceTypeValue()';
	public static final string ERROR_MSD = 'Error occurred';
	public static final string AirScaleWiFi = 'AirScaleWiFi';
	
	//NokiaCPQquoteActionsController
	public static final string PRM_QUOTE_BUTTON = 'Internal_Detailed_Quote_Export_for_PrM__c';
	public static final string LOA_QUOTE_BUTTON = 'LOA_Export__c';
	//proposal trigger
	public static final string TRUE_STRING = 'True';
	public static final string QUOTE_NOT_FOUND = 'Quote Not found';
	
	//reprice functionality
	public static final string BATCHAPEX_STRING = 'BatchApex';
	public static final string PROCCESSING_STRING = 'Processing';
	public static final string PREPARING_STRING = 'Preparing';
	public static final string HOLDING_STRING = 'Holding';
	public static final string QUEUED_STRING = 'Queued';
	public static final string QUOTEID_STRING = 'quoteId';
	public static final string PENDING_STRING = 'Pending';
	public static final string REPRICING_WAIT_MSG = 'Repricing.... Please Wait';
	public static final string REPRICING_COMPLETE_MSG = 'Reprice Complete.Finalizing the cart......Please Wait';
	public static final string FINALIZE_MSG = 'Finalize Complete';
	public static final string COMPLETE_MSG = 'Complete';
	
	//collaboration functionality
	public static final string COLLABORATION_REQUEST = 'Collaboration Request';
	public static final string ACCEPTED = 'Accepted';
	
	//toast messages
	public static final string REPRICENOTREQ = 'Reprice is not required at the moment. Please note that quotes with collaboration in progress can only be repriced after completion of collaboration.';
	public static final string REPRICEBATCHSUBMITTED = 'Request to reprice quotes was submitted successfully. You will be notified via e-mail & chatter once the quote reprice is completed. Please note that quotes with collaboration in progress will not be repriced.';
	public static final string REPRICEBATCHOVERLOAD = 'Request to reprice cannot be submitted at this time due to system overload.Please try again after some time';
	public static final string SINGLEREPRICENOTREQ = 'Reprice not required at the moment';
	public static final string SINGLEREPRICEINCOLLAB = 'Repricing cannot be initiated until quote collaboration is completed.';
	public static final string CONFIGUREFIRST = 'Please configure the products in the quote before repricing';
	
	//DirectToastMessage Cons.
	public static final string CLASS_NAME_STRING = 'Class Name : ';
	public static final string FUNCTION_NAME_STRING = 'Function Name : ';
	public static final string FUNCTION_CHECK_CONFIG_LINE_ITEMS = 'checkExistingConfigurationLineItems()';
	
	//NokiaCPQ_Validate_Quote_Ctrlr
	public static final string  JobType = 'Future';
	public static final string productConfig = 'Finalized';
	public static final string profilename_contains='Partner';
	public static final string lin_Apttus_QPConfig='Product/Service';
	public static final string lin_Apttus_QPConfig_if_else='option';
	public static final string opportunity_sname ='Create offer bid';
	public static final string quote_Nokia_CPQ_EATC='PRM';
	public static final string  Job_Status ='Completed';
	public static final string ExceptionHandle='Product Configuration Not present';
	public static final string addmessage='Please finalize the cart';
	public static final string ErrorNoLOA = 'The offer condition of the related opportunity is set to LoA bypass: No LoA. For successful quote validation this condition requires:<br/>1. No manual discounts<br/>2. All CNP based on contracted CLP<br/>3. Quote total below 5 million Euro<br/>Please make sure to fulfill the above criteria or update the offer condition.';
	public static final string ErrorPreApproved = 'The offer condition of the related opportunity is set to LoA bypass: Pre-approved for Account Manager. For successful quote validation this condition requires:<br/>1. No manual discounts<br/>2. All CNP based on contracted CLP<br/>3. Quote total below 5 million<br/>Please make sure to fulfill the above criteria or update the offer condition.';
	public static final string ErrorAuthorized = 'The offer condition of the related opportunity is set to LoA bypass: Authorized for Pricing Manager. For successful quote validation this condition requires:<br/>1. All discounts within the green area<br/>2. Quote total below 5 million<br/>Please make sure to fulfill the above criteria or update the offer condition.';
	
	
	public static final string DOWNLOAD_OFFER = 'Download Offer';
	
	//proposalTriggerHelper
	public static final string CANCEL_ACTION = 'Cancel Action'; 
	public static final string DIRECT_REC_TYPE = 'Direct_Record_Type';
	public static final string RECALL_ACTION = 'Recall Action';
	public static final string ERROR_ONE = 'Please select a valid portfolio value, you are not authorized for ';
	public static final string ERROR_TWO = 'The quotation cannot be saved. Please select values for all required fields.';
	public static final string INSIDE_QUOTE = 'Inside quote';
	
	//ProcessLineItemBatch
	public static final string  Finish='Finished Reprice';
	public static final string  Repricing='The quote repricing request for Opportunity \'';
	public static final string  Nokia_Partner='Nokia Partner Portal';
	public static final string  Refer='\' is complete. Please refer below link for more details- \n\n';
	public static final string  Query='Select Id, Apttus_Config2__ConfigurationId__c From Apttus_Config2__LineItem__c where Id IN: lineItemIdList';
	
	//Nokia_PricingCallBack
	public static final string STANDARD='Standard price';
	public static final string AFTERPRICING = 'afterPricing';
	public static final string DEFAULTPENDING='Default Pending';
	public static final string NOKIA_EPT='EPT';
	public static final string CALCULATE_QUANTITY ='calculateTotalQuantityForSRSDataRef';
	public static final string AGREEMENT = 'Agreement';
	
	//NokiaCPQ_AttachmentHandler
	public static final string Edit='Edit';
	public static final string xlsm='.xlsm';
	public static final string text_csv='text/csv';
	public static final string None='None';
	public static final string PRMEXPORT='Internal Detailed Quote Export for PrM';
	public static final string LOAEXPORT='LOA_file_';
	public static final string CSPEXPORT='P20 (CSP) Export_';
	
	public static final string  STANDARD_PRICE='Standard Price';		
	public static final string  BUNDLE='Bundle';		 
	public static final string  FALSE_CONSTANT='False';		
	public static final string  TRUE_CONSTANT='true';	   
	
	// Added by Hardik Shah
	// for Support Ticket : 12088
	public static final string DATA_REFINERY='Data Refinery';
	public static final string FASTER_MIND='Fastermind';
	public static final string DATA_REFINERY_SRS='Data Refinery TL SRS';
	public static final string FASTER_MIND_SRS= 'Fastermind TL SRS';
	
	//APTS_CustomActionCallback
	public static final string Errormessage3 ='Copy is not allowed on EPT Products: ';
	
	//NeedsRepriceQuoteRepricePriceList
	public static final string QUERY1 = '\',\'';
	public static final string QUERY2 = '\')';
	public static final string NOKIA_SOFTWARE = 'Nokia Software';
	public static final string BASIC85 = 'Basic (8x5)';
	public static final string SUBSCR = 'Subscription';
	public static final string GOLD247 = 'Gold (24x7)';
	public static final string PLAT_SLA = 'Platinum (higher SLA)';
	
	//AccreditationHandler
	public static final string ACCRD_HANDLER = 'AccreditationHandler';
	
	//AccreditationTrigger
	public static string AccredAfterTriggerExecute = 'False';
	
	//AccreditationTriggerHelper
	public static final string PRICING_TEAM = 'Pricing Team';
	public static final string CHATTER1 = '\n A new Accreditation record has been added or the Current Pricing Level has been changed. Please see the information below. \n \n Partner Name:';
	public static final string CHATTER2 = '\n Accreditation Type : ';
	public static final string CHATTER3 = '\n Portfolio : ';
	public static final string CHATTER4 = '\n Accreditation Level : ';
	public static final string CHATTER5 = '\n Reason for Status Change : ';
	public static final string CHATTER6 = '\n Pricing Level Override  : ';
	public static final string CHATTER7 = '\n Pricing Override Expiration : ';
	public static final string CHATTER8 = '\n Current Pricing Level : ';
	public static final string ACCR_TRIGGER_NAME = 'AccreditationTrigger';
	
	//Values From PCB
	public static final string PRODUCTITEMTYPESOFTWARE = 'Software';
	
	//Quote Actions
	public static final string SCRM = 'sCRM';
	
	//NokiaCPQ_CSP_Export_Generator
	public static final string SOFTWARE_STRING = 'Software';
	public static final string HARDWARE_STRING = 'Hardware';
	public static final string SERVICE_STRING = 'Service';
	public static final string SERVICES_STRING = 'Services';
	public static final string GS_Deploy_STRING = 'GS Deploy Services Items';
	public static final string Deploy_Services_STRING = 'Deploy Services';
	public static final string Attribute_STRING = 'ATTRIBUTE';
	public static final double double_zero = 0.0;
	// req. 5676
	public static boolean RUN_AFTER_UPDATE_QUOTE_TRIGGER = true;
	public static string QUOTE_EXTERNAL_TARGET_SYSTEM_ALLIANCE = 'Alliance';
	public static string SLI_PREFIX_FOR_ALLIANCE_EXPORT = 'NOK:';
	public static string ALLIANCE_EXPORT_PRODUCT_TYPE_SLI = 'SLI';
	public static string ALLIANCE_EXPORT_PRODUCT_TYPE_CO = 'CO';
	public static string ALLIANCE_EXPORT_PRODUCT_LEVEL_TWO = '2';
	public static string ALLIANCE_EXPORT_PRODUCT_LEVEL_ONE = '1';
	public static string ALLIANCE_EXPORT_PRODUCT_CATEGORY_CDE = 'CDE';
	public static string ALLIANCE_EXPORT_PRODUCT_CATEGORY_SSP_SRS = 'SSP/SRS';
	public static string ALLIANCE_EXPORT_PRODUCT_CATEGORY_CARES = 'CAREs';
	public static string ALLIANCE_EXPORT_PRODUCT_CATEGORY_HW = 'HW';
	public static string ALLIANCE_EXPORT_PRODUCT_CATEGORY_SW = 'SW';
	public static string ALLIANCE_EXPORT_PRODUCT_CATEGORY_CS = 'CS';
	public static string ALLIANCE_EXPORT_ITEM_CODE_FOR_HW = 'FP_MF02_MAT_EXTER';
	public static string ALLIANCE_EXPORT_ITEM_CODE_FOR_SW = 'FP_AF08_SW_LICENCE';
	public static string ALLIANCE_EXPORT_ITEM_CODE_FOR_OHER_SERVICES = 'FP_SF03_NE_S_INTEG';
	public static string ALLIANCE_EXPORT_SUCCESS_STRING = 'SUCCESS';
	public static string ALLIANCE_EXPORT_ERROR_STRING = 'ERROR: ';
	public static string ALLIANCE_EXPORT_ERROR_MESSAGE_STRING ='ERROR: There is no Proposal Line Items associated with current Quote!';
	public static string QTC_FILE_NAME_PREFIX = 'QTC (Surround) Export_<';
	public static string LESS_THAN_SYMBOL = '>';
	public static string ENGLISH_ALPHABET_S = 'S';
	public static string ENGLISH_ALPHABET_V = 'V';
	public static string TXT_FILE_EXTENSION = '.txt';
	public static string QTC_FILE_COLUMN_HEADER ='#Services|item_code|quantity|price_class|description|adjust_amt';
	public static string QTC_FILE_NEW_LINE = '\r\n';
	public static string QTC_FILE_LINE_1 = 'Tool|Version||||';
	public static string QTC_FILE_LINE_2 = 'VIPRE|smartCPQ||||';
	public static string QTC_FILE_COLUMN_SEPERATOR = '|';
	public static string QTC_FILE_WORD_SERVICE = '#Services';
	public static string NOKIA_STANDALONE = 'Standalone';
	public static string NOKIA_SCPQ = 'sCPQ';
	public static string  SUMMARY_LINE='Standard Price (One Time)';
	
	//req. 4623
	public static boolean TrueValue = True;
	
	//Req 6000
	public static String ZERO = '0';
	public static String NEGATIVE_DISCOUNT = '-100';
	
	//Req 5258
	public static String Saved = 'Saved';
	
	//Req 6238 
	public static String Split= 'Split';
	public static String SplitLevelOne= '1'; 
	public static String Main = 'Main'; 
	public static String Table = 'Table'; 
	
	//Req 6225
	public static String DISCOUNT_PERCENT= '% Discount';
	public static String DISCOUNT_AMOUNT= 'Discount Amount';
	public static String PRICE_OVEERIDE= 'Price Override';
	//Req 6337
	public static String AdvacncePricing_error='Please relaunch the Advanced Pricing app to update the Net Price correctly and click on Reprice in the cart afterwards.';
	
	// req. 6316	
	public static String QTC_SITE_FILE_NAME_PREFIX = 'QTC (SITE) Export_<';
	public static String ITEM_TYPE_OFFER = 'Offer';
	public static String VALID = 'VALID';
	public static String INDIA_V_SELECT = 'IndivSelect';
	public static String SALES_ORDER_NUMBER = '12345678';
	public static String SUBORDER_NUMBER = '123';
	public static string ENGLISH_ALPHABET_X = 'X';
	public static string ENGLISH_ALPHABET_R = 'R';
	public static string ENGLISH_ALPHABET_E = 'E';
	public static string CONFIGURATOR_OUTPUT = 'CONFIGURATOR OUTPUT';
	public static string ERROR_EXPORT_FILE_CREATION = 'An Error occurred during \'Export File\' creation. Kindly contact your system administrator!' ;
	public static string NO_SALES_ITEM_FOR_QTC_SITE_EXPORT = 'No Sales Item found for QTC (SITE) Export.';
	public static string QTC_SIT_EXPORT_TOP_LEVEL_XML_TAGS = 'TITLE:ORDER_DATA:CONFIG_TOOL:ORDERABLE_ITEM';
	public static string QTC_SIT_EXPORT_ORDER_DATA_XML_TAGS = 'SALES_ORDER:SUBORDER:SEGMENT:VERSION:OPERATION:OMS:LOGIN_ID';
	public static string QTC_SIT_EXPORT_CONFIG_TOOL_XML_TAGS = 'TOOL_NAME:TOOL_STATUS:CONFIG_ID:VINTAGE';
	public static string QTC_SIT_EXPORT_ORDERABLE_ITEMS_XML_TAGS = 'OI_ID:OI_TITLE:OI_QTY:CONFIG_DESC';
	public static string QTC_SIT_EXPORT_ROOT_XML_TAG = 'CONFIG_DATA';
	public static string QTC_SIT_EXPORT_IST = 'IST';
	public static final String DOT = '.';
	// Req. 5934
	public static string EXTERNAL = 'External';
	public static string SERVICE_PCI = 'Service PCI';
	public static string EQUIPMENT_PCI = 'Equipment PCI';
	public static string HYPHEN = '-';
	public static string DUMMY = 'Dummy';
	public static string ENGLISH_ALPHABET_Y = 'Y';
	public static string ENGLISH_ALPHABET_N = 'N';
	public static string ALL = 'ALL';
	public static string PCI_SEMICOLON = 'PCI;';
	public static boolean isCloneRun = false;
	
	Public static String GS_DEPLOY = 'GS Deploy Service Product';
	
	//Req 6383
	
	public static String WARRANTYCREDIT = 'Warranty Credit Applicable For Maintenance Only Quote';
	public static String CONTRACTSTARTDATE = 'Contract Start Date Applicable For Maintenance Only Quote';
	public static String WARRANTYCONTRACTSTARTDATE = 'Warranty Credit & Contract Start Date Applicable For Maintenance Only Quote';
	
	//QTC Constants
	
	Public static String FlexibleGroupController = 'FlexibleGroupController';
	Public static String getlineitems = 'getlineitems' ;
	Public static String updatemarketmodel = 'updatemarketmodel';
	Public static String RemoveLineItems = 'RemoveLineItems';
	Public static String getbundledata = 'getbundledata';
	Public static String QTC_PORTFOLIO = 'QTC';
	public static final string SITE_STRING = 'Site';
	//DS Update Quote Approval Stage + ION Direct Is List Price Only
	Public static String CPQ_GSS_User = 'CPQ_GSS_User';
	
	//CPQ Req 6624
	Public static String RED = 'RED';
	Public static String GREEN = 'GREEN';
	Public static String CPQ_SALES_USER = 'CPQ_Sales_User';
	Public static String PRICING_MANAGER = 'PricingManager';
	Public static String YELLOW = 'YELLOW';
	
	//CPQ indirect 
	public static String NOKIA_LEO_WARNING_MSG = 'Leo Quote amount is less than EUR 500. Please verify';
	
	//Performance Improvement
	public static String SUBTOTAL_ONE_TIME ='Subtotal - Standard Price (One Time)';
	public static String TOTAL_ONE_TIME = 'Total (One Time)';
	public static boolean flagOnSummary = true;
	public static boolean isCloneLineItem = false;
	
	//CartService Nova 
	Public static String NokiaOrder = 'Order';
	Public static String Nokia_CART_Interface = 'CART Interface';
	Public static String Nokia_Upsert = 'Upsert';
	Public static String Nokia_Cart_service_Interface  = 'CART Service Interface - CartId: ';
	Public static String Nokia_ConfigId  = ' ConfigId: ';
	Public static String NokiaCPQ_Unitary_Cost  = 'NokiaCPQ_Unitary_Cost__c';
	Public static String Nokia_Item_Type_From_CAT  = 'Item_Type_From_CAT__c';
	Public static String Nokia_PCI_Code  = 'PCI_Code__c';
	Public static String NokiaCPQ_IsArcadiaBundle  = 'NokiaCPQ_IsArcadiaBundle__c';
	Public static String NokiaCPQ_Unitary_Cost_Initial  = 'NokiaCPQ_Unitary_Cost_Initial__c';
	Public static String Nokia_Insert_Delivery_Sales_Items  = 'Insert Delivery Sales Items';
	Public static String Nokia_CARTService  = 'CARTService';
	Public static String Nokia_createInterfaceLog  = 'createInterfaceLog';
	Public static String Nokia_Required_Data_Missing  = 'Required Data Missing';
	Public static String Nokia_Missing_configuration_data  = 'Missing configuration data';
	Public static String Nokia_Missing_BOM_Data  = 'Missing BOM Data';
	Public static String Nokia_Missing_Main_Bundle_Line_Item_Id  = 'Missing Main Bundle Line Item Id';
	Public static String Nokia_Missing_Cart_Id  = 'Missing Cart Id';
	Public static String NokiaCPQ_ZID  = '-ZID';
	Public static String NokiaCPQ_ZID1  = 'ZID';
	Public static String NokiaCPQ_ZNAME  = '-ZNAME';
	Public static String NokiaCPQ_ZNAME1  = 'ZNAME';
	Public static String NokiaCPQ_CHARC  = '-CHARC';
	Public static String NokiaCPQ_CHARC1  = 'CHARC';
	Public static String NokiaCPQ_CHARC_TXT  = '-CHARC_TXT';
	Public static String NokiaCPQ_CHARC_TXT1  = 'CHARC_TXT';
	Public static String NokiaCPQ_VALUE  = '-VALUE';
	Public static String NokiaCPQ_VALUE1  = 'VALUE';
	Public static String NokiaCPQ_VALUE_TXT  = '-VALUE_TXT';
	Public static String NokiaCPQ_VALUE_TXT1  = 'VALUE_TXT';
	Public static String NokiaCPQ_digits  = '&#124;';
	Public static String NokiaCPQ_Hyphen  = '-';
	Public static String NokiaCPQ_Colon  = ':';
	Public static String NokiaCPQ_errorMessage = 'These Products are selected in CAT but not available in Apttus CPQ- ';
	Public static String NokiaCPQ_txt  = 'text/plain';
	Public static String NokiaCPQ_cfgdata  = 'cfg_data.txt';
	Public static String NokiaCPQ_Success   = 'Success';
	Public static String NokiaCPQ_spaceComma = ' ; ';
	public static String NokiaCPQ_CartService = 'CartService';
	public static String NokiaCPQ_insertAttachment = 'insertAttachment';
	public static String NokiaCPQ_checkArcadiaItems = 'checkArcadiaItems';
	public static String NokiaCPQ_addSelectedOptions  = 'addSelectedOptions'; 
	public static String NokiaCPQ_addArcadiaItems = 'addArcadiaItems';	
	public static String NokiaCPQ_parseConfigString ='parseConfigString';
	// ProductConfigTriggerHelper- NovaSuite
	public static Integer Two =2;
	Public static String directDS='Direct DS';
	public static Integer minusOne =-1;
	public static Integer Three =3;
	Public Static String dotZero='.00';
	Public static String updateFieldsOnProdConfig ='updateFieldsOnProdConfig';
	Public static String ProductConfigTriggerHelper='ProductConfigTriggerHelper';
   
	//NovaSuiteFixes
	Public static String pricingManagerPS = 'Nokia_CPQ_Pricing_Manager';
	Public static String adminPS = 'CPQ_Admin';
	Public static String sendAddQuoteMessageToEAImethod = 'sendAddQuoteMessageToEAI';
	Public static String Error_String = 'Error';
	Public static String Closed_String = 'Closed';
	Public static String Fail = 'Fail';
	Public static String getQuoteDeliverySalesItemsForArcadiamethod = 'getQuoteDeliverySalesItemsForArcadia';
	Public static String generateParentToChildOptionsHierarchymethod = 'generateParentToChildOptionsHierarchy';
	Public static String FN= 'FN';
	Public static String Primary= 'Primary';
	Public static String Activated= 'Activated';
	Public static String ApprovalRequired= 'Approval Required';
	Public static String Generated= 'Generated';
	Public static String Denied= 'Denied';
	Public static String Closed_Not_Won ='Closed (Not Won)';
	Public static String Validate = 'Validate';
	Public static String Submit= 'Submit';
	Public static String Optics_Wavelite = 'Optics - Wavelite';
	Public static String Error= 'Please contact your PSM to check your Partner Certification';
	Public static String sObjectType= 'sObjectType';
	Public static String sObjectId= 'sObjectId';
	Public static String Pricing_Manager1 = 'Pricing Manager';
	Public static String Approved_with_DOD= 'Approved with DOD';
	Public static String Line_number= 'Line number ';
	public static String Qword='Q';
	public static String Distributor='Distributor';
	public static String PRODSTATUS = 'CPQ_ProductStatusCheckController';
	public static String GETPRODSTATUS = 'getProductStatusResult';
	public static String PRODNAME = '{ProdName}';
	public static String PRODCODE = '{ProdCode}';
	public static String NokiaCPQ_PRICE = 'Price';
	public static String PendingApproval = 'Pending Approval';
	public static String QTC = 'QTC';
	public static String Nokia_New = 'New';
	public static String Nokia_Brand ='Nokia Brand of Service';
	public static String Nokia_Maintenance_level_api='NokiaCPQ_Maintenance_Level__c';
	public static String Working='working';
	
	public static String Nokia_FASTMILE = 'FastMile';
	public static String NOKIA_1YEAR ='1';
	public static String NOKIA_LEO ='LEO';
	public static String NOKIA_NAMCLUSTER ='NAM';
	public static String NOKIA_ONT ='ONT';
	public static String NOKIA_PTP ='PTP';
	public static String Configure ='Configure';
	public static String Manual ='Manual';
	public static String NokiaCPQShareProposalsWithOTM ='NokiaCPQShareProposalsWithOTM';
	public static String unshareProposalRecordAfterOTMTriggerDelete ='unshareProposalRecordAfterOTMTriggerDelete';
	public static String CUSTPROD001 = 'CUSTPROD001';

}