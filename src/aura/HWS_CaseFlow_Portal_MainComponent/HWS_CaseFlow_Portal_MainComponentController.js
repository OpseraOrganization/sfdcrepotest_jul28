({
    //Spinner Code Start
    showWaiting: function(cmp) {
        cmp.set("v.IsSpinner", true);
    },
    hideWaiting: function(cmp) {
        cmp.set("v.IsSpinner", false);
    },
    setCaseOring: function(component, event) {
        var selectCmp = component.find("caseOrigin");
        component.set("v.caseOrigin", selectCmp.get("v.value")); 
    },
    serviceTypeCall : function(component, event, helper){
        helper.getBulkServiceTypes(component, event);
        component.set("v.stageNumber", 8);
        component.set("v.serviceType", '');
		component.set('v.hideProgressBar',false);
    },
    serviceTypeBulkUploadCall : function(component, event, helper){
        var serviceType = component.get("v.serviceType");
        component.set("v.serviceType", serviceType);
        if(serviceType == 'Advanced Exchange in Days' || serviceType == 'Identical Repair' || serviceType == 'Return for Repair or Replacement'){    
            component.set("v.stageNumber", 9);
        } else{
            helper.showToast('error','Error Message','Please select servicetype before proceeding next');
        }
    },
    parentCaseBulkUploadCall : function(component, event,helper){
        var validation = helper.bulkParentCaseValidation(component, event);
        if(!validation){
            component.set("v.stageNumber", 10);
        }
    },
    bulkuploadCall : function(component, event){
        component.set("v.stageNumber", 11);
        var bulkRMACmp = component.find("bulkRMAId");		
        bulkRMACmp.init();
    },
    portalProcess : function(component, event){
        component.set("v.stageNumber", 2);
		component.set('v.hideProgressBar',true);
        var oldSelectedAcc = component.get("v.accountId");
        var newSelectedAccount = component.get("v.oldSelectedAccount");
        var childCmp = component.find("assetSecId");
        childCmp.init();          
        var versionItemCmp = component.find("versionSecId");
        component.set("v.oldSelectedAccount",oldSelectedAcc); 
        if(oldSelectedAcc !=newSelectedAccount && oldSelectedAcc!= undefined && newSelectedAccount!=undefined){                
            childCmp.componentRefreshFromMainComponent();
            versionItemCmp.componentRefreshVersionItem();
            helper.clearChild(component, event, helper);
            helper.clearParent(component, event, helper);
        }
        var childCmp = component.find("assetSecId");
        childCmp.init();
    },
    requestDateChange: function(component, event, helper) {
        var validation = helper.requestDateChangeValidate(component, event);
    },
    checkLength : function(component, event) {
        var auraIdFromCmp = event.getSource().getLocalId();
        //alert('auraIdFromCmp'+auraIdFromCmp);
        if(auraIdFromCmp == 'siteAuraId'){
            var siteId = component.find('siteAuraId').get('v.value');
            if(siteId.length > 36){
                var substr = siteId.substring(0, 36);
                component.find('siteAuraId').set('v.value',substr);            
            }
        }
        else if(auraIdFromCmp == 'replacementAuraId'){
            var replaceAuraId = component.find('replacementAuraId').get('v.value');
            
            if(replaceAuraId.length > 30){
                var substr = replaceAuraId.substring(0, 30);
                component.find('replacementAuraId').set('v.value',substr);            
            }
        }
            else if(auraIdFromCmp == 'FRNAuraId'){
                var FRNId = component.find('FRNAuraId').get('v.value');
                if(FRNId.length > 50){
                    var substr = FRNId.substring(0, 50);
                    component.find('FRNAuraId').set('v.value',substr);            
                }
            }
                else if(auraIdFromCmp == 'FRNAuraId1'){
                    var FRNId1 = component.find('FRNAuraId1').get('v.value'); 
                    if(FRNId1.length > 50){
                        var substr = FRNId1.substring(0, 50);
                        component.find('FRNAuraId1').set('v.value',substr);            
                    }
                }
                    else if(auraIdFromCmp == 'faultySerial'){            
                        var FSNId = component.find('faultySerial').get('v.value');
                        if(FSNId.length > 30){
                            var substr = FSNId.substring(0, 30);
                            component.find('faultySerial').set('v.value',substr);            
                        }
                    }
                        else if(auraIdFromCmp == 'faultySerial1'){
                            var FSNId1 = component.find('faultySerial1').get('v.value');
                            if(FSNId1.length > 30){
                                var substr = FSNId1.substring(0, 30);
                                component.find('faultySerial1').set('v.value',substr);            
                            }
                        }
                            else if(auraIdFromCmp == 'FDSAuraId'){ 
                                var FDNId1 = component.find('FDSAuraId').get('v.value');
                                if(FDNId1.length > 255){
                                    var substr = FDNId1.substring(0, 255);
                                    component.find('FDSAuraId').set('v.value',substr);            
                                }
                            }
                                else if(auraIdFromCmp == 'FDS1AuraId'){
                                    var FDSId1 = component.find('FDS1AuraId').get('v.value');
                                    if(FDSId1.length > 255){
                                        var substr = FDSId1.substring(0, 255);
                                        component.find('FDS1AuraId').set('v.value',substr);            
                                    }
                                }
                                    else if(auraIdFromCmp == 'CustRefAuraId'){
                                        var CRN = component.find('CustRefAuraId').get('v.value');
                                        if(CRN.length > 30){
                                            var substr = CRN.substring(0, 30);
                                            component.find('CustRefAuraId').set('v.value',substr);            
                                        }
                                    }
                                        else if(auraIdFromCmp == 'CustRefAuraId1'){
                                            var CRN1 = component.find('CustRefAuraId1').get('v.value');
                                            if(CRN1.length > 30){
                                                var substr = CRN1.substring(0, 30);
                                                component.find('CustRefAuraId1').set('v.value',substr);            
                                            }
                                        }
                                            else if(auraIdFromCmp == 'shipmentRecNameAuraId'){
                                                var shipRecName = component.find('shipmentRecNameAuraId').get('v.value');
                                                if(shipRecName.length > 36){
                                                    var substr = shipRecName.substring(0, 36);
                                                    component.find('shipmentRecNameAuraId').set('v.value',substr);            
                                                }
                                            }
                                                else if(auraIdFromCmp == 'custOrderPOAuraId'){
                                                    var custOrderPO = component.find('custOrderPOAuraId').get('v.value');
                                                    if(custOrderPO.length > 20){
                                                        var substr = custOrderPO.substring(0, 20);
                                                        component.find('custOrderPOAuraId').set('v.value',substr);            
                                                    }
                                                }
                                                    else if(auraIdFromCmp == 'siteAuraId1'){
                                                        var custOrderPO1 = component.find('siteAuraId1').get('v.value');
                                                        if(custOrderPO1.length > 60){
                                                            var substr = custOrderPO1.substring(0, 60);
                                                            component.find('siteAuraId1').set('v.value',substr);            
                                                        }
                                                    }
                                                        else if(auraIdFromCmp == 'shipmentBulkRecNameAuraId'){
                                                            var shipmentBulkRecName = component.find('shipmentBulkRecNameAuraId').get('v.value');
                                                            if(shipmentBulkRecName.length > 36){
                                                                var substr = shipmentBulkRecName.substring(0, 36);
                                                                component.find('shipmentBulkRecNameAuraId').set('v.value',substr);            
                                                            }
                                                        }
                                                            else if(auraIdFromCmp == 'shipmentBulkRecPhoneAuraId'){
                                                                var shipmentBulkRecPhone = component.find('shipmentBulkRecPhoneAuraId').get('v.value');
                                                                if(shipmentBulkRecPhone.length > 60){
                                                                    var substr = shipmentBulkRecPhone.substring(0, 60);
                                                                    component.find('shipmentBulkRecPhoneAuraId').set('v.value',substr);            
                                                                }
                                                            }
                                                                else if(auraIdFromCmp == 'shipmentRecPhoneAuraId'){
                                                                    var shipmentRecPhone = component.find('shipmentRecPhoneAuraId').get('v.value');
                                                                    if(shipmentRecPhone.length > 60){
                                                                        var substr = shipmentRecPhone.substring(0, 60);
                                                                        component.find('shipmentRecPhoneAuraId').set('v.value',substr);            
                                                                    }
                                                                }
    },
    //Spinner Code Ends
    passContactId : function(component, event, helper) {
        // jQuery("[id$=siteIdclass]").setAttribute('maxlength', '60');
        //component.find('siteIdclass').set('v.maxlength',30);
        component.set('v.SelectProgressBar',true);        
        if(component.get("v.getContact") !== false){
            var searchCriteria = event.getParam("searchCriteria");
            component.set('v.assetRec',undefined);//to disable next button on Asset Section
            component.set('v.versionRec',undefined);//to disable next button on VersionItem Section  
            component.set('v.selectedContractLineItem',undefined);//to disable next button on VersionItem Section  
            component.set('v.neaRec',undefined);//to disable next button on NEA Section 
            var action = component.get("c.getContactDetails");            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var conId = response.getReturnValue();            
                    component.set("v.contactId",conId[0].ContactId);
                    component.set("v.contactName",conId[0].Contact.Name); 
                    component.set("v.defaultAccount",conId[0].Contact.AccountId);  
                    component.set("v.contactTimeZone",conId[0].Contact.CH_ContactTimeZone__c);
                    component.set("v.getContact",false); 
					component.set("v.parentCase.CH_Email2__c",conId[0].Contact.Email1__c);//Nokiasc-27247
                	component.set("v.parentCase.CH_Email3__c",conId[0].Contact.CH_Email3__c);//Nokiasc-27247
                    //helper.getRecordTypeId(component, event);
                }
                component.set('v.stageNumber', parseInt(component.get('v.stageNumber'))+1);
            });
            $A.enqueueAction(action);
        }   
        var action = component.get("c.getResourceURL"); //getting attachment from apex
        action.setParams({
            resourceName : 'BulkRMATemplate'
        })
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log('response value#####'+response.getReturnValue());
            console.log('state'+state);
            if (state === "SUCCESS") {
                component.set("v.downloadURL", response.getReturnValue());
                var urldownload = component.get('v.downloadURL');
            } 
            else {
                console.log("Failed with state: " + state);
            }
        })                           
        $A.enqueueAction(action);
    },
    handleLookupEvent: function(component, event, helper) {
        var objectId = event.getParam("ParentRecordId");
        var ObjectnameId = event.getParam("objectNameId");
        if (ObjectnameId == "Account") {
            component.set("v.ShiptopartyAddress", objectId);
        } else if (ObjectnameId == "Contact") {
            component.set("v.communicationContact", objectId);
        }
    },
     handleComponentEvent : function(component, event, helper){       
        var showSection = event.getParam("showSection"); 
        var searchCriteria = event.getParam("searchCriteria");
        console.log('showSection '+showSection);
		if(showSection === 0)
        {            
            component.set("v.stageNumber", 1);
        }
        var backtoasset = event.getParam("backtoasset");
		if(showSection === 1){
            var objectId = event.getParam("selectedRecId");            
            var accountName = event.getParam("accountName");
            var selectedAccount = event.getParam("legalListAccount");
            component.set("v.accountId", objectId);
            component.set("v.accountName", accountName);
            component.set("v.showRelatedSection", showSection);  
            component.set("v.selectedAccount", selectedAccount);
            component.set("v.legalEntityNotFound",true);
			if(selectedAccount == null || selectedAccount == '' || selectedAccount == undefined){
                component.set("v.legalEntityNotFound",false);
            }
        }
        if(showSection === 2){   
            var assetRec = event.getParam("selectedAsset");
            var showassets = event.getParam("showassets"); 
            var searchCriteria = event.getParam("searchCriteria"); 
            var searchKeyword = event.getParam("searchKeyword"); 
            component.set("v.searchCriteria",searchCriteria); 
            component.set("v.searchKeyword",searchKeyword); 
            component.set("v.showassets",showassets);
            component.set("v.assetRec", assetRec);
            component.set("v.serviceType", assetRec.HWS_Service_Type__c);
            helper.getRecordTypeId(component, event);
            helper.getParentRecordTypeId(component, event);
            component.set("v.contractNumber", assetRec.HWS_Service_Contract_Number__c);
			component.set("v.country", assetRec.HWS_ContractLineItem__r.CH_CountryISOName__c);
            component.set("v.productCode", assetRec.HWS_Part_Code__c);
            component.set("v.showRelatedSection", showSection);
            //27280 --> Passing contractLineItem's country            
            if(assetRec.HWS_ContractLineItem__r.CH_CountryISOName__c !=null){
                component.set("v.serviceContractCountry", assetRec.HWS_ContractLineItem__r.CH_CountryISOName__c);
            }
            console.log('asset records '+searchCriteria);            
            //Start Changes for US-26951
            var getPayPerUse=assetRec.HWS_ServiceOffering__c;
            var getPrice=assetRec.HWS_Price__c;
            if(
                ( getPayPerUse != undefined && (getPayPerUse.includes('RES RFR PU') || getPayPerUse.includes('RES AED PU'))) &&
                (getPrice == '' || getPrice == null || getPrice == undefined)
            )
            {
                component.set("v.getPayPerPrice", true);
            }
            else{
                component.set("v.getPayPerPrice", false);
            }
            //End Changes for US-26951
            component.set("v.selectedAssetstep2",true);	
            if(assetRec.CoveredNetworkElementCount > 0){	
                component.set('v.showNEAStage',12);	
                if(searchCriteria == 'Part Code'){	
                    component.set("v.SelectNEAProgress",true);	
                    component.set("v.SelectNEAProgressBar",true);	
                    component.set("v.ProgressBarNEACounter" ,1);	
                    component.set("v.SelectProgressBar",false);	
                    component.set("v.ContractNumProgress",false);	
                    component.set("v.ContractNumNEAProgress",false);	
                }	
            }	
            else {	
                component.set('v.showNEAStage',0);	
                if(searchCriteria == 'Part Code'){	
                    component.set("v.SelectNEAProgress",false);	
                    component.set("v.SelectProgressBar",true);	
                    component.set("v.ProgressBarCounter" ,1);	
                    component.set("v.SelectNEAProgressBar",false);	
                    component.set("v.ContractNumProgress",false);	
                    component.set("v.ContractNumNEAProgress",false);
					component.set("v.neaRec",undefined);	
					component.set("v.selectedAssetCheckUpfrontNEA",false);					
                }	
            }
            if(searchCriteria == 'Contract Number'){                
                //Start Changes-26951
                if(component.get("v.getPayPerPrice")){
                    helper.showToast("error","Error Message","The service requires quotation, please escalate"); 
                }
                else{
                    console.log('search criteria '+searchCriteria);
                    component.set("v.stageNumber", 3);
                    var childCmp = component.find("versionSecId");
                    childCmp.init();
                    helper.getplannedDeliveryDateTime(component, event);
                }
                //End Changes-26951                
            }              
        }
		if(showSection === 3){
            var versionRec = event.getParam("selectedVersion");
            component.set("v.showRelatedSection", showSection);
            component.set("v.versionRec", versionRec);
            component.set("v.customerPartRev", event.getParam("customerPartRev"));
            component.set("v.partRevision", versionRec.HWS_Version_Code__c);
            helper.getplannedDeliveryDateTime(component, event);
            component.set("v.selectedVersionstep3",true);
        }
        if(showSection === 4){
            var listChildCase = event.getParam("listChildCase");
            component.set("v.showRelatedSection", showSection);
            component.set("v.listChildCase", listChildCase);
            console.log('Child Case in Main Portal '+listChildCase);
        }
        if(showSection === 5){
            var parentCase = event.getParam("parentCase");
            console.log('Parent Case details in Main portal '+JSON.stringify(parentCase));
            var buttonName = event.getParam("buttonName");
            component.set("v.showRelatedSection", showSection);
            component.set("v.buttonName", buttonName);
            component.set("v.parentCase", parentCase);
            helper.saveCaseFlow(component, event, helper);
        }
		if(showSection === 6){
            var selectedContractLineItem = event.getParam("selectedContractLineItem");            
            component.set("v.selectedContractLineItem", selectedContractLineItem);
            component.set("v.showRelatedSection", showSection);
            component.set("v.selectedAssetstep2",true);	
            component.set("v.contractNumber",selectedContractLineItem.HWS_ServiceContractNumber__c);
            if(selectedContractLineItem.CoveredNetworkElementCount > 0){	
                component.set('v.showNEAStage',12);	
                if(searchCriteria == 'Contract Number'){	
                    component.set("v.SelectNEAProgress",true);	
                    component.set("v.ContractNumNEAProgress",true);	
                    component.set("v.ContNEAProgressBarCounter" ,1);	
                    component.set("v.SelectProgressBar",false);	
                    component.set("v.SelectNEAProgressBar",false);	
                    component.set("v.ContractNumProgress",false);	
                }	
            }	
            else {	
                component.set('v.showNEAStage',0);	
                component.set("v.SelectNEAProgress",false);	
                if(searchCriteria == 'Contract Number'){	
                    component.set("v.ContractNumProgress",true);	
                    component.set("v.ContProgressBarCounter" ,1);	
                    component.set("v.SelectProgressBar",false);	
                    component.set("v.SelectNEAProgressBar",false);	
                    component.set("v.ContractNumNEAProgress",false);	
					component.set("v.neaRec",undefined);	
					component.set("v.selectedAssetCheckUpfrontNEA",false);
                }	
            }
        }
        if(showSection === 7){	
            var selCLI = event.getParam("selectedCLI");	
            component.set('v.selectedCLI',selCLI);	
        }
		if(showSection === 8){	
            var selNEA = event.getParam("selectedNEA");
            var selAssetCheck = event.getParam("selectedAssetCheck");	
            var showassets = event.getParam("showassets");	
            var selectedCLICheck = event.getParam("selectedCLICheck");	
            var allCLIS = event.getParam("allCLIS");
            component.set('v.neaRec',selNEA);	
			component.set('v.NEAID',selNEA.CH_NetworkElementID__c);
            component.set('v.Address',selNEA.Address);
            component.set("v.SelectNEA",true);	                        
            if(selAssetCheck){	
                component.set("v.selectedAssetCheckUpfrontNEA",selAssetCheck);	
                component.set("v.assetsUpfrontNEASelection",showassets);	               
            }	
            if(selectedCLICheck) {	
                component.set("v.selectedContractCheckUpfrontNEA",selectedCLICheck);
                component.set("v.contractsUpfrontNEASelection",allCLIS);	
            }
        }
        
		if(showSection === 10){
            var allCLIS = event.getParam("allCLIS");
            component.set("v.allCLIS",allCLIS);
        }
		if(showSection === 11 && backtoasset)
        {
            var accId =component.get('v.accountId');
            component.set("v.accountId", accId);
            component.set("v.showRelatedSection", showSection);
        }
        if(showSection === 13)
        {            
            var searchCriteria = event.getParam("searchCriteria");
            console.log('searchcriteria '+searchCriteria);
            component.set("v.searchCriteria",searchCriteria);
            component.set("v.assetRec",undefined);
            if(searchCriteria == 'Contract Number'){	
                var childCmp = component.find("contractNumberSecId");	
                childCmp.init();	
            }
        }              
        if(showSection == 20){	
            component.set('v.stageNumber', 12);	
            var childCmp = component.find("neaSecId");	
            childCmp.init();
            component.set("v.SelectNEAProgress" , true);
            if(component.get("v.searchCriteria") === 'Part Code'){
                component.set("v.SelectNEAProgressBar" , true); 
                component.set("v.ProgressBarNEACounter" , 2); 
                component.set("v.SelectProgressBar" , false); 
                component.set("v.ContractNumProgress" , false); 
                component.set("v.ContractNumNEAProgress" , false); 
            }
            if(component.get("v.searchCriteria") === 'Contract Number'){
                component.set("v.ContractNumNEAProgress" , true); 
                component.set("v.ContNEAProgressBarCounter" , 2); 
                component.set("v.SelectProgressBar" , false); 
                component.set("v.SelectNEAProgressBar" , false); 
                component.set("v.ContractNumProgress" , false); 
            }
        }	
        if(showSection === 21){ 
            var ser = event.getParam("selectedServiceType");
            var conN = event.getParam("selectedContractNumber"); 
            component.set('v.contractNumber', conN);
            component.set('v.serviceType', ser);
            component.set('v.stageNumber', 21); 
        }
        if(showSection === 22){            
            component.set('v.stageNumber', 2);            
        }
		if(showSection == 23){	
            var showassets = event.getParam("showassets");	
            component.set("v.showassets",showassets);	
        }
        if(showSection === 24){	
            component.set('v.stageNumber', 2);	
        }	
        if(showSection === 25){	
            var selAstContrNum = event.getParam("selectedAssetForContractNumber");	
            console.log('selAstContrNum ###'+JSON.stringify(selAstContrNum));	
            component.set('v.assetRec',null);	
            component.set('v.assetRec',selAstContrNum);	
            component.set('v.serviceType',selAstContrNum.HWS_Service_Type__c);
            component.set("v.productCode", selAstContrNum.HWS_Part_Code__c);
            component.set('v.SelectConNum' , true);
        }	
        if(showSection === 26){	
            var selAstContrNum = event.getParam("selectedAssetForContractNumber");	
            component.set('v.neaRec',undefined);
            component.set("v.selectedAssetCheckUpfrontNEA",false);
            component.set("v.selectedContractCheckUpfrontNEA",false);
			component.set("v.clearNEACheck",true);
			var childCmp = component.find("neaSecId");
             childCmp.componentRefresh();
        }
        if(showSection === 50){ 
            if (event.getParam("enableButton") == 1){
            var assetRec = event.getParam("selectedAsset");
            component.set("v.assetRec", assetRec);
			component.set('v.selectedAssetstep2',false);
            }
            else if (event.getParam("enableButton") == 2){
            var assetRec1 = event.getParam("selectedContractLineItem");
            component.set("v.selectedContractLineItem", assetRec1);
			component.set('v.selectedAssetstep2',false);
            }
            else if (event.getParam("enableButton") == 3){
            var assetRec2 = event.getParam("selectedVersion");
            component.set("v.versionRec", assetRec2); 
			component.set('v.selectedVersionstep3',false);
            }
            else if (event.getParam("enableButton") == 4){
            var assetRec3 = event.getParam("selectedNEA");
            component.set("v.neaRec", assetRec3);
			component.set('v.SelectNEA',false);
            }
            else if (event.getParam("enableButton") == 5){
            var assetRec4 = event.getParam("selectedAssetForContractNumber");
            var abc = component.set("v.assetRec", assetRec4);
			component.set('v.SelectConNum',false);
            }
        }
        var showSection = event.getParam("NextButtonValidation");
        component.set("v.NextButtonVal", NextButtonValidation);        
    },
    nextHandler : function(component, event, helper) {
        var searchCrit = component.get("v.searchCriteria");
        if(component.get('v.stageNumber') === 1){
            component.set("v.bulkUpload", true);
            component.set('v.stageNumber', 7);
            component.set('v.ProgressBarCounter', 1);   
            component.set("v.ProgressBarNEACounter",1);   
            component.set("v.ContNumProgressBarCounter",1);   
            component.set("v.ContNEAProgressBarCounter",1);
			component.set('v.hideProgressBar',false);
        }else{
            //component.set('v.stageNumber', parseInt(component.get('v.stageNumber'))+1);
            component.set('v.redoutlineremover',true);
            if(component.get('v.stageNumber') === 2){
                //Progress Bar Starts   
                component.set("v.ProgressBarCounter",2);   
                component.set("v.ProgressBarNEACounter",2);   
                component.set("v.ContNumProgressBarCounter",2);   
                component.set("v.ContNEAProgressBarCounter",2);   
                //Progress Bar Ends
                var selAsset = component.get("v.assetRec");   
                if(searchCrit== "Part Code"){
                    component.set("v.toProceedSPSLOD", false);
                    var serviceType = component.get("v.assetRec[0].HWS_Service_Type__c");
                    console.log('serviceType'+serviceType+'Search Criteria:'+(searchCrit));
                    var SRMLOD = component.get("v.assetRec[0].HWS_Product_SPSLOD__c");
                    console.log('SRMLOD'+SRMLOD);
                    var SPSLOD = new Date();
                    SPSLOD = component.get("v.assetRec[0].HWS_Product_SPSLOD__c");
                    console.log('SPSLOD1'+SPSLOD);
                    if (
                        (component.get("v.assetRec[0].HWS_Product_SPSLOD__c") != undefined ||
                         component.get("v.assetRec[0].HWS_Product_SPSLOD__c") != null) &&
                        serviceType == "Spare Part Sales"
                    ) {
                        console.log('milliseconds'+new Date().getTime());
                        var milliseconds = new Date().getTime() - Date.parse(SRMLOD);
                        console.log('milliseconds'+milliseconds);
                    }
                    if (milliseconds > 0 && serviceType == "Spare Part Sales") {
                        component.set("v.toProceedSPSLOD", true);
                    }
                    console.log('toProceedSPSLOD'+component.get("v.toProceedSPSLOD"));
                    
                }
                
                // Start Changes for US-26951
                if (component.get("v.toProceedSPSLOD") || component.get("v.getPayPerPrice")) {
                    component.set('v.stageNumber', 2);
                    if(component.get("v.toProceedSPSLOD")){
                        helper.showToast(
                            "error",
                            "Error Message",
                            "Cannot add this part as last order date for the part has already passed, Please contact HWS Customer Delivery Manager"
                        );
                    }
                    if(component.get("v.getPayPerPrice")){
                        helper.showToast("error","Error Message","The service requires quotation, please escalate");
                        //Progress Bar Starts   
                        component.set("v.ProgressBarCounter",1);   
                        component.set("v.ProgressBarNEACounter",1);   
                        component.set("v.ContNumProgressBarCounter",1);   
                        component.set("v.ContNEAProgressBarCounter",1);   
                        //Progress Bar Ends
                    }
                }
                // End Changes for US-26951
                /*else{
                    component.set("v.newChildCase.HWS_Planned_Delivery_Date__c", '');
                    helper.getplannedDeliveryDateTime(component, event);  
                    //component.set('v.stageNumber', parseInt(component.get('v.stageNumber'))+1);
                    console.log('stage number'+component.get('v.stageNumber'));
                   
                }*/
            }
            else if(component.get('v.stageNumber') === 3){
                component.set('v.stageNumber', 4);
                component.set('v.ProgressBarCounter', 3);
                component.set("v.ProgressBarNEACounter",4);
                component.set("v.ContNumProgressBarCounter",4);
                component.set("v.ContNEAProgressBarCounter",5);
            }
                else if(component.get('v.stageNumber') === 4){
                    component.set('v.oneclick',undefined);
                    var faultyValidation = helper.duplicateSerialnumCheck(component,'parentCheck');
                }
        }
     
     if(searchCrit == 'Part Code' && component.get('v.stageNumber') === 2 && component.get('v.showNEAStage') === 0 && !component.get("v.getPayPerPrice")){
         component.set('v.stageNumber', 3);
         component.set('v.ProgressBarCounter', 2);
         component.set("v.ProgressBarNEACounter",3);
         component.set("v.ContNumProgressBarCounter",3);
         component.set("v.ContNEAProgressBarCounter",4);
         var childCmp = component.find("versionSecId");
         childCmp.init();
     }
     if(component.get("v.selectedAssetCheckUpfrontNEA") && component.get('v.stageNumber') === 2 && searchCrit == 'Part Code'){  
         component.set('v.stageNumber', 3);
         component.set("v.ProgressBarCounter",2);  
         component.set("v.ProgressBarNEACounter",3);  
         component.set("v.ContNumProgressBarCounter",3);  
         component.set("v.ContNEAProgressBarCounter",4);
         var childCmp = component.find("versionSecId");  
         childCmp.init();  
     }
     if(searchCrit == 'Part Code' && component.get('v.stageNumber') === 12 && component.get('v.neaRec') != undefined && component.get('v.neaRec') != null && component.get('v.neaRec') != '' && component.get("v.selectedAssetCheckUpfrontNEA")){
         component.set('v.stageNumber', 2);
         component.set("v.ProgressBarCounter",1);  
         component.set("v.ProgressBarNEACounter",1);  
         component.set("v.ContNumProgressBarCounter",1);  
         component.set("v.ContNEAProgressBarCounter",1);
         var childCmp = component.find("assetSecId");  
         childCmp.init();              
     }
     if(searchCrit == 'Part Code' && component.get('v.stageNumber') === 12 && component.get('v.neaRec') != undefined && component.get('v.neaRec') != null && component.get('v.neaRec') != ''){
         component.set('v.stageNumber', 3);
         component.set("v.ProgressBarCounter",2);  
         component.set("v.ProgressBarNEACounter",3);  
         component.set("v.ContNumProgressBarCounter",3);  
         component.set("v.ContNEAProgressBarCounter",4);  
         var childCmp = component.find("versionSecId");
         childCmp.init();          
     }
     if(!component.get("v.selectedAssetCheckUpfrontNEA") && component.get('v.stageNumber') === 2 && searchCrit == 'Part Code' && component.get('v.showNEAStage') == 12){
         component.set('v.stageNumber', 12);
         var childCmp = component.find("neaSecId");
         childCmp.init();
     }
     if(searchCrit == 'Contract Number' && component.get('v.stageNumber') === 12 && component.get('v.neaRec') != undefined && component.get('v.neaRec') != null && component.get('v.neaRec') != '' && component.get("v.selectedContractCheckUpfrontNEA")){
         component.set('v.stageNumber', 2);
         component.set("v.ProgressBarCounter",1);  
         component.set("v.ProgressBarNEACounter",1);  
         component.set("v.ContNumProgressBarCounter",1);  
         component.set("v.ContNEAProgressBarCounter",1);
         var childCmp = component.find("contractNumberSecId");  
         childCmp.init();
     }      
     if(searchCrit == 'Contract Number' && component.get('v.stageNumber') === 12 && component.get('v.neaRec') != undefined && component.get('v.neaRec') != null && component.get('v.neaRec') != ''){         
         component.set('v.stageNumber', 14); 
         component.set("v.ContNEAProgressBarCounter",3);
         var childCmp = component.find("contractAssetSecId"); 
         childCmp.searchAssetsForContractNumber(); 
     }
     var selectedContractLineItem = component.get("v.selectedContractLineItem");
     if(component.get('v.stageNumber') === 2 && searchCrit == "Contract Number" && (component.get("v.selectedContractCheckUpfrontNEA") || component.get('v.showNEAStage') == 0 )&& selectedContractLineItem!= undefined && selectedContractLineItem != null && selectedContractLineItem != ''){
         component.set("v.stageNumber",14);
         if(component.get('v.showNEAStage') > 0){
             component.set("v.ProgressBarCounter",3); 
             component.set("v.ProgressBarNEACounter",3); 
             component.set("v.ContNumProgressBarCounter",3); 
             component.set("v.ContNEAProgressBarCounter",3);
         }
         var childCmp = component.find("contractAssetSecId");
         childCmp.searchAssetsForContractNumber();
     }
     if(component.get('v.stageNumber') === 2 && searchCrit == "Contract Number" && component.get('v.showNEAStage') == 12 && !component.get("v.selectedContractCheckUpfrontNEA")){                   
         component.set('v.stageNumber', 12);
         var childCmp = component.find("neaSecId");
         childCmp.init();         
     }
     if(searchCrit == 'Contract Number' && component.get('v.stageNumber') === 14 && component.get('v.assetRec') != undefined && component.get('v.assetRec') != null && component.get('v.assetRec') != ''){
         component.set('v.stageNumber', 3);
         component.set("v.ContNumProgressBarCounter",3);
         component.set("v.ContNEAProgressBarCounter",4);
         var childCmp = component.find("versionSecId");
         childCmp.init();
     }
	 if(component.get('v.stageNumber') === 12 || component.get('v.stageNumber') === 3 || component.get('v.stageNumber') === 14){
            var oldAst = component.get("v.oldAssetRec");
            var newAst = component.get("v.assetRec");
            component.set("v.oldAssetRec",component.get('v.assetRec'));  
            if(oldAst != '' && oldAst != null && oldAst != undefined &&
               newAst != '' && newAst != null && newAst != undefined){
                var oldAsset=JSON.parse(JSON.stringify(oldAst[0]));	
                var newAsset=JSON.parse(JSON.stringify(newAst[0]));	
                if(oldAsset.Id != newAsset.Id){
                    component.set('v.neaRec',undefined);
                    helper.clearChild(component, event, helper);
            		helper.clearParent(component, event, helper);
                    var childCmp = component.find("neaSecId");
                    childCmp.componentRefresh();
                }
            }
			var oldCLI = component.get("v.oldContractNumberRec");
            var newCLI = component.get("v.selectedContractLineItem");
            component.set("v.oldContractNumberRec",component.get('v.selectedContractLineItem'));
            if(oldCLI != '' && oldCLI != null && oldCLI != undefined &&
               newCLI != '' && newCLI != null && newCLI != undefined){
                var oldCLIRec=JSON.parse(JSON.stringify(oldCLI[0]));	
                var newCLIRec=JSON.parse(JSON.stringify(newCLI[0]));	
                if(oldCLIRec.Id != newCLIRec.Id){
                    component.set('v.neaRec',undefined);
                    helper.clearChild(component, event, helper);
            		helper.clearParent(component, event, helper);
                    var childCmp = component.find("neaSecId");
                    childCmp.componentRefresh();
                }
            }
     }
     
 },
    
    previousHandler : function(component, event, helper) {
       
        if(!component.get("v.selectedAssetCheckUpfrontNEA") && component.get("v.searchCriteria")== "Part Code" && component.get('v.showNEAStage') == 12 && component.get('v.stageNumber') == 3){
            component.set('v.stageNumber', 12);   
        }
        else if(component.get("v.selectedAssetCheckUpfrontNEA") && component.get("v.searchCriteria")== "Part Code" && component.get('v.showNEAStage') == 12 && component.get('v.stageNumber') == 3){	
            component.set('v.stageNumber', 2);	
        }
            else if(component.get('v.stageNumber') == 12){
                component.set('v.stageNumber', 2);
                if(component.get("v.searchCriteria")== "Part Code" && (component.get('v.neaRec') == undefined || component.get('v.neaRec') == null || component.get('v.neaRec') == '')){
                    component.set("v.SelectNEAProgress" , false);
                    component.set("v.SelectProgressBar" , true);
                    component.set("v.ProgressBarCounter" , 1); 
                    component.set("v.SelectNEAProgressBar" , false);
                    component.set("v.ContractNumProgress" , false); 
                    component.set("v.ContractNumNEAProgress" , false); 
                    
                }
                if(component.get("v.searchCriteria")== "Contract Number" && (component.get('v.neaRec') == undefined || component.get('v.neaRec') == null || component.get('v.neaRec') == '')){
                    component.set("v.SelectNEAProgress" , false);
                    component.set("v.ContractNumProgress" , true);
                    component.set("v.ProgressBarCounter" , 1);
                    component.set("v.SelectProgressBar" , false);
                    component.set("v.SelectNEAProgressBar" , false);
                    component.set("v.ContractNumNEAProgress" , false); 
                }
                
            }
                else if(component.get('v.stageNumber') == 14){
                    if(component.get('v.showNEAStage') == 12 && !component.get("v.selectedContractCheckUpfrontNEA")){
                        component.set('v.stageNumber', 12);
                        component.set("v.ContNEAProgressBarCounter",2);
                    } else{
                        component.set('v.stageNumber', 2);
                        component.set("v.ProgressBarCounter",1);	
                        component.set("v.ProgressBarNEACounter",1);	
                        component.set("v.ContNumProgressBarCounter",1);	
                        component.set("v.ContNEAProgressBarCounter",1);
                    }
                }
                    else if(component.get("v.searchCriteria")== "Contract Number" && component.get('v.stageNumber') == 3){
                        component.set('v.stageNumber', 14);
                        component.set("v.ProgressBarCounter",3);	
                        component.set("v.ProgressBarNEACounter",3);	
                        component.set("v.ContNumProgressBarCounter",3);	
                        component.set("v.ContNEAProgressBarCounter",3);
                    }
                        else{
                            component.set('v.stageNumber', parseInt(component.get('v.stageNumber'))-1);
                        }
        console.log('enterind sps previous');
        console.log('##Stage Number in Previous Handler'+component.get('v.stageNumber'));
        var stageNumber = component.get('v.stageNumber');
        var serviceType = component.get('v.serviceType');
        console.log('previous service type'+serviceType);
        if(serviceType == 'Advanced Exchange in Days'){
            component.set('v.redoutlineremover',false);
            
            console.log('remove red outline'+component.get('v.redoutlineremover'));
            var oCase = helper.requiredFieldValidations(component, [                
                {id: 'failureOccurance', recordEditForm: true, required: true},
                {id: 'failureDetection', recordEditForm: true, required: true},
                {id: 'failureDetectionDate', recordEditForm: true, required: true},
                {id: 'failureDescription', recordEditForm: true, required: true}            
            ]),
                errorMessage = (oCase.error?oCase.error:''); 
            document.getElementById("errorOnCreate").innerHTML = '';
            document.getElementById("validatePhone").innerHTML = '';
            document.getElementById("faultySerialNumber").innerHTML = '';
            console.log('##Stage Number in Previous Handler'+component.get('v.stageNumber'));
        }
        if(serviceType == 'Identical Repair' || serviceType == 'Return for Repair or Replacement'){
            component.set('v.redoutlineremover',false);
            
            console.log('remove red outline'+component.get('v.redoutlineremover'));
            var oCase = helper.requiredFieldValidations(component, [                
                {id: 'failureOccurance1', recordEditForm: true, required: true},
                {id: 'failureDetection1', recordEditForm: true, required: true},
                {id: 'failureDetectionDate1', recordEditForm: true, required: true},
                {id: 'failureDescription1', recordEditForm: true, required: true}            
            ]),
                errorMessage = (oCase.error?oCase.error:''); 
            document.getElementById("errorOnCreate").innerHTML = '';
            document.getElementById("validatePhone").innerHTML = '';
            document.getElementById("faultySerialNumber").innerHTML = '';
            console.log('##Stage Number in Previous Handler'+component.get('v.stageNumber'));
        }
        if(serviceType == 'Spare Part Sales'){
            component.set('v.redoutlineremover',false);
            console.log('remove red SPS'+component.get('v.redoutlineremover'));
            var oCase = helper.requiredFieldValidations(component, [                
                {id: 'quantity', recordEditForm: true, required: true}                      
            ]); 
            document.getElementById("errorOnCreate").innerHTML = '';
        }
        document.getElementById("validateParentPhone").innerHTML = '';
        if(stageNumber === 4){
            var newChildCasesList = component.get("v.listChildCase");
            var removeLast = newChildCasesList.pop(newChildCasesList.length);
            var listToADD = [];
            for (var i in newChildCasesList) {
                var oldRecipent = newChildCasesList[i];
                if (oldRecipent != []){
                    listToADD.push(oldRecipent);
                }
            }
            component.set("v.childCases", listToADD);
            //component.set("v.ShiptopartyAddress", "");
            //component.set("v.communicationContact", "");
			component.set("v.ProgressBarCounter",3);
            component.set("v.ProgressBarNEACounter",4);
            component.set("v.ContNumProgressBarCounter",4);
            component.set("v.ContNEAProgressBarCounter",5);
        }
        if(serviceType == 'Spare Part Sales' && stageNumber === 2){
            var childCmp1 = component.find("versionSecId");
            childCmp1.componentRefreshVersionItem();
        }
        if(component.get('v.stageNumber') === 1){
            var clearFiltersCriteria = component.find("assetSecId");
            clearFiltersCriteria.clearFiltersSTage2();
            component.set("v.ProgressBarCounter",0);
            component.set("v.ProgressBarNEACounter",0);
            component.set("v.ContNumProgressBarCounter",0);
            component.set("v.ContNEAProgressBarCounter",0);
        }
        if(component.get('v.stageNumber') === 2){
            var clearFiltersCriteriaVersions3to2 = component.find("versionSecId");
            clearFiltersCriteriaVersions3to2.clearFiltersSTage3();
            component.set("v.ProgressBarCounter",1);
            component.set("v.ProgressBarNEACounter",1);
            component.set("v.ContNumProgressBarCounter",1);
            component.set("v.ContNEAProgressBarCounter",1);
        }
        if(component.get("v.searchCriteria")== "Part Code" && component.get('v.stageNumber') == 12){
            component.set("v.ProgressBarCounter",2);
            component.set("v.ProgressBarNEACounter",2);
            component.set("v.ContNumProgressBarCounter",2);
            component.set("v.ContNEAProgressBarCounter",2);
        }    
        if(component.get('v.stageNumber') === 3){
            component.set("v.ProgressBarCounter",2);
            component.set("v.ProgressBarNEACounter",3);
            component.set("v.ContNumProgressBarCounter",3);
            component.set("v.ContNEAProgressBarCounter",4);  
        }
        if(component.get('v.stageNumber') === 6){
            var clearFiltersCriteriaVersions = component.find("versionSecId");
            clearFiltersCriteriaVersions.clearFiltersSTage3();
        }
        
        if(component.get('v.stageNumber') === 14 && component.get('v.showNEAStage') === 0 ){
            component.set("v.ContNumProgressBarCounter",2);
        }
        component.set('v.oneclick','');
    },
    
    addPart : function(component, event, helper) {  
        if(component.get('v.stageNumber') === 4){
            var validation = helper.duplicateSerialnumCheck(component,'addPart');
            
        }
    },
    
    //26101
    saveCase: function(component, event, helper){
        var childCasesList = component.get("v.listChildCase");   
       	var reqVal = true;        
        for(var i=0;i<childCasesList.length;i++){           
            var planedDate =  childCasesList[i].HWS_Planned_Delivery_Date__c;
            var requestedDate = childCasesList[i].HWS_Requested_Delivery_Date_Time__c;               
            console.log('Planned date: subbbb'+planedDate+' Req Date: subbbbb'+requestedDate);
            if(planedDate != null && new Date(planedDate) > new Date(requestedDate) && requestedDate != null){                    
                reqVal = false;
                childCasesList[i].Street_Address_3__c =  "delInfoBorderCol";
            }
        }
        component.set("v.listChildCase",childCasesList);
        if(reqVal){
            document.getElementById("validateRequiredFields").innerHTML = '';       		
            helper.saveCaseFlow(component, event);
			component.set('v.onSubmitprogress',true);
        }
        else{
            document.getElementById("validateRequiredFields").innerHTML = 'Date and time cannot be less than Planned Delivery date';
        }
    },
    
    //26101
    validateParentCase: function(component, event, helper){
        var validation = helper.parentCaseValidation(component,event);
        var phoneNumber = component.get('v.parentCase.HWS_Shipment_Recipient_Phone__c');
        if(phoneNumber == ''){
            document.getElementById("validateParentPhone").innerHTML = '';
        }
        console.log('validation in next handler '+validation);
        if(!validation){
            helper.deliveryInfo(component, event, helper);            
        }
    },
    
    bulkEmailValidation : function(component, event, helper){
        helper.bulkParentCaseValidation(component, event);
        
    },
    //added for bug  HWST-3544:
    shipTopartyEmptyOnPickSelection : function(component, event, helper){
        
        var childComp = component.find('recordValue2');        
        childComp.removeShiptoParty();
    },
    //26101
    backToParentDetailPage : function(component, event, helper){
			component.set("v.stageNumber", 5);
			component.set('v.ProgressBarCounter', 4);
			component.set("v.ProgressBarNEACounter",5);
			component.set("v.ContNumProgressBarCounter",5);
			component.set("v.ContNEAProgressBarCounter",6);
    },
    //26101 To handle the save function from Dlivery Info screen in line Edit
    handleSave: function(component,event,helper) {
        var editedRecords =  event.getParam('draftValues');
        var childCasesList = component.get("v.listChildCase");        
        var reqVal = true;
        var countryTimezone = 'GMT';
        var shipToTimeZone = component.get("v.shipToTimeZone");
        console.log('shipToTimeZoneeeeee'+shipToTimeZone);
        var shipToTimeZoneMap = component.get("v.shipToTimeZoneMap");
        if(editedRecords){            
            for(var i=0;i<editedRecords.length;i++){
                var rowNumber = editedRecords[i].Id;
                rowNumber = rowNumber.substring(4,rowNumber.length);
                var planedDate =  childCasesList[rowNumber].HWS_Planned_Delivery_Date__c;
                var requestedDate = editedRecords[i].HWS_Requested_Delivery_Date_Time__c;               
                console.log('Planned date: '+planedDate+' Req Date: '+requestedDate);
                if(new Date(planedDate) > new Date(requestedDate) && requestedDate != null){                    
                    reqVal = false;
                    childCasesList[rowNumber].Street_Address_3__c =  "delInfoBorderCol";
                }else{
                    if(editedRecords[i].HWS_Requested_Delivery_Date_Time__c != null && editedRecords[i].HWS_Requested_Delivery_Date_Time__c != undefined){
                        childCasesList[rowNumber].Street_Address_3__c =  null;                                           
                        childCasesList[rowNumber].HWS_Requested_Delivery_Date_Time__c = editedRecords[i].HWS_Requested_Delivery_Date_Time__c;
                        
                        if(shipToTimeZone == 'Account'){
                            countryTimezone = shipToTimeZoneMap[component.get('v.ShiptopartyAddress')];
                        }
                        if (shipToTimeZone == 'BusinessHour'){
                            var bhId = childCasesList[rowNumber].Street_Address_2__c;
                            countryTimezone = shipToTimeZoneMap[bhId];
                            console.log('bhIdddd'+bhId+'  countryTimezoneeee'+countryTimezone);
                        }
                        var countryTime = new Date(requestedDate).toLocaleString("en-US", {timeZone: countryTimezone});                    
                        countryTime = new Date(countryTime);
                        var counteryDateOnly = $A.localizationService.formatDate(countryTime);                       
                        counteryDateOnly = counteryDateOnly.replace(/[\/\\.-]/g, ' ');                        
                        var counteryTimeOnly = $A.localizationService.formatTime(countryTime);                        
                        /*  var monthNames = [
                            "Jan", "Feb", "Mar",
                            "Apr", "May", "Jun", "Jul",
                            "Aug", "Sep", "Oct",
                            "Nov", "Dec"
                          ];*/
                        var hours = countryTime.getHours();
                        var minutes = countryTime.getMinutes();
                        var ampm = hours >= 12 ? 'pm' : 'am';
                        if(counteryTimeOnly.includes("AM") || counteryTimeOnly.includes("PM")){
                            ampm = hours >= 12 ? 'PM' : 'AM';
                        }
                        hours = hours % 12;
                        hours = hours ? hours : 12; // the hour '0' should be '12'
                        minutes = minutes < 10 ? '0'+minutes : minutes;
                        var strTime = hours + ':' + minutes + ' ' + ampm;                        
                        childCasesList[rowNumber].HWS_RequestedDateShipment__c = counteryDateOnly +', ' + strTime +' ('+countryTimezone+')';
                    }                    
                    else{
                        childCasesList[rowNumber].HWS_Requested_Delivery_Date_Time__c = null;
                        childCasesList[rowNumber].HWS_RequestedDateShipment__c = null;
                        childCasesList[rowNumber].Street_Address_3__c =  "delInfoBGCol"; 
                    }
                }                
            }
        }      
        component.set("v.listChildCase",childCasesList);
        console.log('Final List'+JSON.stringify(component.get("v.listChildCase")));
        if(reqVal){
            document.getElementById("validateRequiredFields").innerHTML = '';
            component.find("childTable").set("v.draftValues", null);
        }
        else{
            document.getElementById("validateRequiredFields").innerHTML = 'Date and time cannot be less than Planned Delivery date';
        }
    },
    
    //26101 To handle the Cancel function from Dlivery Info screen in line Edit     
    handleCancel: function(component,event,helper) {
        var childCasesList = component.get("v.listChildCase");       
        if(childCasesList){            
            for(var i=0;i<childCasesList.length;i++){                    
                if(childCasesList[i].HWS_Requested_Delivery_Date_Time__c != null && childCasesList[i].HWS_Requested_Delivery_Date_Time__c != undefined){
                    childCasesList[i].Street_Address_3__c = null;
                }
                else{
                    childCasesList[i].Street_Address_3__c =  "delInfoBGCol";
                }
            }
        }
        document.getElementById("validateRequiredFields").innerHTML = '';
        component.set("v.listChildCase",childCasesList);        
    },
    //Added for search using part code
    onSingleSelectChange: function(component) {
        var selectCmp = component.find("InputSelectSingle");
        component.set("v.searchCriteria",selectCmp.get("v.value"));
        var searchCrit = component.get('v.searchCriteria');
        console.log('search criteria on change ###'+searchCrit);
        component.set('v.assetRec',null);
        component.set('v.selectedAssetstep2',false);
        component.set('v.SelectNEA',false);
        component.set('v.selectedVersionstep3',false);
        component.set('v.childcasestep4',false);
        component.set('v.parentcaseStep5',false);
        component.set('v.SelectConNum',false);
        component.set('v.neaRec',null);
        component.set('v.selectedContractLineItem',null);
        if(searchCrit == 'Part Code'){
            component.set("v.SelectProgressBar",true);
            component.set("v.ProgressBarCounter",1);
            component.set('v.SelectNEAProgress',false);
            component.set("v.ContractNum",false);
            component.set("v.ContractNumProgress",false); 
            component.set("v.SelectNEAProgressBar",false); 
            component.set("v.ContractNumNEAProgress",false);    
        }
        if(searchCrit == 'Contract Number'){
            component.set("v.ContractNumProgress",true);
            component.set("v.ContProgressBarCounter",1);
            component.set('v.SelectNEAProgress',false);
            component.set("v.ContractNum",true);
            component.set("v.SelectProgressBar",false); 
            component.set("v.SelectNEAProgressBar",false); 
            component.set("v.ContractNumNEAProgress",false); 
        }                
    },
    search: function(component, event, helper){
        var searchCrit = component.get('v.searchCriteria');
        console.log('search criteria ###'+searchCrit);
        if(searchCrit == 'Part Code'){
            var childCmp = component.find("assetSecId");
            childCmp.searchAsset();
        }
        if(searchCrit == 'Contract Number'){
            var childCmp = component.find("contractNumberSecId");
            childCmp.searchContractNumber();
        }
    },
    searchPartorContract: function(component, event, helper) {        
        var searchCrit = component.get('v.searchCriteria');
        if (event.keyCode === 13) {
            if(searchCrit == 'Part Code'){
                var childCmp = component.find("assetSecId");
                childCmp.searchAsset();
            }
            if(searchCrit == 'Contract Number'){
                var childCmp = component.find("contractNumberSecId");
                childCmp.searchContractNumber();
            }
        }        
    },
})