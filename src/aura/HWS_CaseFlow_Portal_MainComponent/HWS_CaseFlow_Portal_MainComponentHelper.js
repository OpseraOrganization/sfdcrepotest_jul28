({
    getRecordTypeId : function(component, event, helper) {
        var serviceType = component.get('v.serviceType');
        console.log('service type ###'+serviceType);
        var action = component.get("c.getRecordType");
        action.setParams({
            serviceType : serviceType,
        });
        action.setCallback(this, function(response) {   
            var state = response.getState();
            console.log('Response State##### '+state);
            if (state === "SUCCESS") {                                
                component.set("v.recordTypeId",response.getReturnValue());
            }                
        }); 
        console.log('recordTypeId ',component.get("v.recordTypeId"));
        $A.enqueueAction(action);
    },
    getParentRecordTypeId : function(component, event, helper) {		
        var action = component.get("c.getRecordType");
        action.setParams({
            serviceType : 'HWS_Parent_Case',
        });
        action.setCallback(this, function(response) {   
            var state = response.getState();
            console.log('Response State##### '+state);
            if (state === "SUCCESS") {                                
                component.set("v.parentRecordTypeId",response.getReturnValue());
            }                
        }); 
        console.log('recordTypeId ',component.get("v.parentRecordTypeId"));
        $A.enqueueAction(action);
    },
    requestDateChangeValidate : function(component, event){
        var reqVal = false;
        var planedDate = component.get('v.newChildCase.HWS_Planned_Delivery_Date__c');
        var requestedDate = component.get('v.newChildCase.HWS_Requested_Delivery_Date_Time__c');
        if(new Date(planedDate) > new Date(requestedDate) && requestedDate != null){
            component.set("v.dateValidationError" , true);
            reqVal = false; 
        }else{
            component.set("v.dateValidationError" , false);
            reqVal = true; 
        }
        return reqVal;
    },
    saveCaseFlow : function(component, event) {
        console.log('In Save');
        component.set("v.spinner",true);
        var buttonName = event.getSource().getLocalId();
        //var buttonName = component.get("v.buttonName");  
        var submitToSOO = (buttonName =='saveAsDraft') ? false :true; 
        var contactid = component.get("v.contactId");
        var accountList = component.get("v.accountId");
        var contractLines = component.get("v.assetRec");
        var versionItems = component.get("v.versionRec");
        var childCase = component.get("v.listChildCase");
        //var childCaseList = component.get("v.childCases");        
        var parentCase = component.get("v.parentCase");
        var communicationContact = component.get('v.communicationContact');
        var ShiptopartyAddress = component.get('v.ShiptopartyAddress');
        component.set("v.saveDisable",true);
        component.set("v.saveSubmitDisable",true);
        parentCase.HWS_Communication_Contact__c = communicationContact;
        parentCase.Hws_Ship_to_Party_Address__c = ShiptopartyAddress;
		var deliveryTimeZone = component.get("v.deliveryTimeZone");
		parentCase.HWS_Delivery_TimeZone__c  = deliveryTimeZone;
        parentCase.Origin='Web';
        console.log('button name '+buttonName+' submitToSOO '
                    +submitToSOO+' contactid '+contactid+' accountList '+accountList
                    +' contractLines '+JSON.stringify(contractLines) +' versionItems '+
                    JSON.stringify(versionItems)
                    +' childCase '+JSON.stringify(childCase)
                    +' parentCase '+JSON.stringify(parentCase));
        //Code Changes for 26952
        var newAssetList = component.get('v.getAllAssets');
        console.log('##FinalnewAssetLis##'+JSON.stringify(newAssetList));
        if(newAssetList != null){
            for(var i=0;i<newAssetList.length;i++){
                var getPayPerUse=newAssetList[i].HWS_ServiceOffering__c;
               if( getPayPerUse != undefined && (getPayPerUse.includes('RES RFR PU') || getPayPerUse.includes('RES AED PU'))){
                    component.set("v.getPayPerUse", true);
                }
            }
        }
        var getPO=parentCase.HWS_Customer_PO__c;
        if(component.get("v.getPayPerUse") === true && (getPO==null || getPO=='' || getPO==undefined ||getPO=='undefined') && submitToSOO){
            component.set("v.saveCase", false);   
            this.showToast('error','Error Message','Please Fill Customer Purchase Order Number');
            component.set("v.spinner",false);
            component.set("v.stageNumber", 5);
            component.set("v.saveDisable",false);
            component.set("v.saveSubmitDisable",false);
        }
        else{
            component.set("v.saveCase", true);  
        }
        if(!submitToSOO){
            component.set("v.saveCase", true); 
        }
        if(component.get("v.saveCase")===true){
            var action = component.get('c.createHWSCasePortal');
            console.log('after calling controller');
            action.setParams({
                accountId : accountList,
                shipAccId : ShiptopartyAddress,
                contractLines : contractLines,
                versionItems : versionItems,
                childCaseList : childCase,
                parentCase : parentCase,
                contactid : contactid,
                submitToSOO:submitToSOO,
                contactTimeZone:component.get("v.contactTimeZone")
            });
            console.log('after sending parameters');
            action.setCallback(this, $A.getCallback(function (response) {
                var state = response.getState();
                console.log('Response State '+response.getReturnValue());
                if (state === "SUCCESS") {
                    var recordid = response.getReturnValue();
                    component.set("v.caseNumber", response.getReturnValue());
                    if (submitToSOO) {
                        var actionCallout=component.get('c.makeSOOCallout');
                        actionCallout.setParams({
                            parentCaseId : recordid});
                        actionCallout.setCallback(this, $A.getCallback(function (response) {
                            var state = response.getState();
                            component.set("v.ProcessResponse", response.getReturnValue());
                            var processResponse=component.get("v.ProcessResponse");
                            if (state === "SUCCESS") {
                                if(processResponse!=null){
                                    var statuscode=processResponse.statusCode;
                                    console.log('status code '+statuscode);
                                    if(statuscode==200){
                                        this.showToast('success','Success Message','Your request is Successfully submitted');
                                    }
                                    else{
                                        this.showToast('error','Error Message','Your request is Created but not submitted');
                                    }
                                    //this.openCaseTab(component, this.getLightningURL(recordid));
                                    //this.closeTab(component);
                                    this.openCaseTab(component, recordid);
                                }
                            }
                            else{
                                this.showToast('error','Success Message','Your request is Created but not submitted');
                                //this.openCaseTab(component, this.getLightningURL(recordid));
                                //this.closeTab(component);
                                this.openCaseTab(component, recordid);
                            }
                        }));
                        $A.enqueueAction(actionCallout);
                        
                    }
                    else{
                        this.showToast('success','Success Message','Case was created Successfully');
                        //this.openCaseTab(component, this.getLightningURL(recordid));
                        //this.closeTab(component);
                        this.openCaseTab(component, recordid);
                    }                
                } else {
                    component.set("v.saveDisable",false);
                    component.set("v.saveSubmitDisable",false);
                    component.set("v.spinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    var message = '';
                    if (state === "INCOMPLETE") {
                        message = 'Server could not be reached. Check your internet connection.';
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            for(var i=0; i < errors.length; i++) {
                                for(var j=0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                                    message += (message.length > 0 ? '\n' : '') + errors[i].pageErrors[j].message;
                                }
                                if(errors[i].fieldErrors) {
                                    for(var fieldError in errors[i].fieldErrors) {
                                        var thisFieldError = errors[i].fieldErrors[fieldError];
                                        for(var j=0; j < thisFieldError.length; j++) {
                                            message += (message.length > 0 ? '\n' : '') + thisFieldError[j].message;
                                        }
                                    }
                                }
                                if(errors[i].message) {
                                    message += (message.length > 0 ? '\n' : '') + errors[i].message;
                                }
                            }
                        } else {
                            message += (message.length > 0 ? '\n' : '') + 'Unknown error';
                        }
                    }
                    toastEvent.setParams({
                        title: 'Error',
                        type: 'error',
                        message: message
                    });
                    toastEvent.fire();
                } 
            }));
            $A.enqueueAction(action);
        }
    },
    createChildCase : function(component, event) {  
        //Start Changes for 26952
        var listToADDValues = []; 
        var newAssetListValues = component.get('v.getAllAssets');
        var assetListValues = component.get("v.assetRec");
        for(var i in newAssetListValues){
            var oldRecipentValues = newAssetListValues[i];
            if(oldRecipentValues!=[]){
                listToADDValues.push(oldRecipentValues);
            }
        }
        for(var i in assetListValues){
            var oldRecipentValues = assetListValues[i];
            if(oldRecipentValues!=[]){
                listToADDValues.push(oldRecipentValues);
            }
        }
        //listToADD1.push( JSON.parse(JSON.stringify(assetList1)));
        component.set('v.getAllAssets',listToADDValues);
        console.log('##Final'+JSON.stringify(component.get('v.getAllAssets')));
        //End Changes for 26952
        console.log('createChildCase');
        var assetList = component.get("v.assetRec");
        var contractNumber = assetList[0].HWS_Service_Contract_Number__c;
        var serviceType = assetList[0].HWS_Service_Type__c;        	
        var cliId = assetList[0].HWS_ContractLineItem__r.Id;
        var prod2Id = assetList[0].Product2Id;
        var prodName = assetList[0].Product2.Name;
        var assetId = assetList[0].Id;
        var stockableProd = component.get("v.versionRec");
        var stockableProdId = stockableProd[0].Id;
        var parentContractId = assetList[0].HWS_ContractLineItem__r.ServiceContractId;
		//26091
        var selNEA = component.get("v.neaRec");            
        if(selNEA != null && selNEA != '' && selNEA != undefined){
            var neaId = selNEA[0].Id;
        } 
        component.set("v.newChildCase.HWS_Contract_Line_Item__c",cliId);
        //26101
        component.set("v.newChildCase.Street_Address_2__c",assetList[0].HWS_ContractLineItem__r.CH_BusinessHour__c);
        //Assigning ContractLine Item value by using subject, as portal user doesnot have access for Contract line items. Subject field will be populated with RMA number again while inserting.
        component.set("v.newChildCase.Subject",cliId);
        component.set("v.newChildCase.HWS_Customer_Part_Revision__c",component.get("v.customerPartRev"));
        component.set("v.newChildCase.HWS_Sellable_Product__c",prod2Id);
        component.set("v.newChildCase.NCP_Product_Name__c",prodName);
        component.set("v.newChildCase.HWS_ServiceType__c",serviceType);
        component.set("v.newChildCase.NCP_Service_Contract__c",parentContractId);        
        component.set("v.newChildCase.HWS_Stockable_Product__c", stockableProdId);
        //26101
        component.set("v.newChildCase.Street_Address_1__c", stockableProd[0].HWS_Version_Code__c); 
        component.set("v.newChildCase.AssetId",assetId);
        var childCase = component.get("v.newChildCase");
        component.set("v.newChildCase.HWS_Part_Code__c",assetList[0].HWS_Part_Code__c);
		component.set("v.newChildCase.CH_NetworkElementAsset__c",neaId);
        /* console.log('assetList '+assetList+' contractNumber '+contractNumber+
                    ' serviceType '+serviceType+' cliId '+cliId+
                    ' prod2Id '+prod2Id+' assetId '+assetId+' parentContractId '+parentContractId+
                    ' childCase '+JSON.stringify(childCase));*/
        var listToADD = [];  
        var newChildCasesList = component.get('v.listChildCase');    
        for(var i in newChildCasesList){            
            var oldRecipent = newChildCasesList[i];
            if(oldRecipent!=[])
                listToADD.push(oldRecipent);
        }
        listToADD.push( JSON.parse(JSON.stringify(childCase)));
        console.log('listToADD '+listToADD);
        component.set('v.listChildCase',listToADD);        
        /* var listChildCase = component.get('v.listChildCase');
            console.log('create child case');
            console.log('child case details '+JSON.stringify(listChildCase)); */
        
        
    },
    parentCaseValidation : function(component,event){
        console.log('recordTypeId ',component.get("v.recordTypeId"));
        console.log('parentRecordTypeId ',component.get("v.parentRecordTypeId"));
        var validation = false;
        var requiredFieldsValidation = false;
        var phoneValidation = false;
        var emailValidation = false;
        var shippedPartyValidation = false;
        var emailId = component.get('v.parentCase.HWS_ShipmentRecipientEmailId__c');
        var phoneNumber = component.get('v.parentCase.HWS_Shipment_Recipient_Phone__c');
        var ShiptopartyAddress = component.get('v.ShiptopartyAddress');
        if(ShiptopartyAddress == null || ShiptopartyAddress == undefined || ShiptopartyAddress == '')
        {
            component.find("recordValue3").set("v.errors", [{message:"Please Enter Ship to party Address before Proceeding"}]);
            shippedPartyValidation = true;
        } 
        else {   
            component.find("recordValue3").set("v.errors", [{message: null}]);
            $A.util.removeClass(component.find("recordValue3"), 'slds-has-error');
            shippedPartyValidation = false;
        }
        if(phoneNumber!= ''){
            if(phoneNumber!= undefined){
                console.log('phone number inside if '+phoneNumber);
                var phoneValidateCheck = this.phoneValidation(phoneNumber);
                console.log('phoneValidateCheck '+phoneValidateCheck);
                if(phoneValidateCheck){
                    document.getElementById("validateParentPhone").innerHTML = 'Please enter valid Phone number. Phone number should only contain digits(ex: +XXX XX XXXX, XXXXXXXXXX)';
                    phoneValidation = true;
                }else{
                    document.getElementById("validateParentPhone").innerHTML = '';
                    phoneValidation = false;
                }
            }
        }
        if(emailId!= ''){
            if(emailId!= undefined){
                var emailValidateCheck = this.emailValidation(emailId);
                console.log('emailValidateCheck '+emailValidateCheck);
                if(emailValidateCheck){
                    document.getElementById("validateParentEmailId").innerHTML = 'You have entered an invalid format.';
                    emailValidation = true;
                }else{
                    document.getElementById("validateParentEmailId").innerHTML = '';
                    emailValidation = false;
                }
            }
        }
        if( shippedPartyValidation || phoneValidation || emailValidation){
            component.set('v.stageNumber', 5);
            validation = true;
        }
        else{
            //component.set('v.stageNumber', parseInt(component.get('v.stageNumber'))+1);
            validation = false;
        }
		if(!validation){
            component.set('v.parentcaseStep5',true);
            component.set('v.ProgressBarCounter', 5);
            component.set("v.ProgressBarNEACounter",6);
            component.set("v.ContNumProgressBarCounter",6);
            component.set("v.ContNEAProgressBarCounter",7);
        }
        return validation;
    },
    childCaseValidation : function (component,parentCheck){        
        var validation = false;
        var requiredFieldsValidation = false;
        var phoneValidation = false;
        var emailValidation = false;
        var dateChangeValidate = false;
        var versionItems = component.get("v.versionRec");
        var faultySerialCheck;
        var isTraceble = versionItems[0].HWS_Serial_Number_Traceable__c;
        //var faultySerialNumber = component.find("faultySerial").get("v.value");
        //console.log('is traceable '+isTraceble+ ' faultySerialNumber '+faultySerialNumber);
        console.log('Faulty value check in childCaseValidation '+faultySerialCheck);
        //console.log('is faulty serial number value'+faultySerialNumber);
        var serviceType = component.get('v.serviceType'); 
        console.log('service type'+serviceType);
        dateChangeValidate = this.requestDateChangeValidate(component, event);
        if(serviceType != 'Spare Part Sales'){ 
            if(serviceType =='Identical Repair' || serviceType == 'Return for Repair or Replacement'){
                var faultySerialNumber = component.find("faultySerial1").get("v.value");
            }
            if(serviceType =='Advanced Exchange in Days' || serviceType == 'Advanced Exchange in Hours'){
                var faultySerialNumber = component.find("faultySerial").get("v.value");
            }
            console.log('Faulty serial number'+faultySerialNumber);
            if(isTraceble == undefined || isTraceble.toUpperCase() == 'NO' || ((isTraceble.toUpperCase() == 'YES' || isTraceble.toUpperCase() == 'Y') && (faultySerialNumber != undefined && faultySerialNumber !='' && faultySerialNumber !=null))){    
                faultySerialCheck = false;
                console.log('Faulty Serial Check validation in if '+faultySerialCheck);		
            }
            else if(serviceType != 'Advanced Exchange in Hours' && ((isTraceble.toUpperCase() == 'YES' || isTraceble.toUpperCase() == 'Y') && (faultySerialNumber == undefined || faultySerialNumber =='' || faultySerialNumber ==null))){
                faultySerialCheck = true;              
                console.log('Faulty Serial Check validation in else '+faultySerialCheck);		
            }
            if(faultySerialCheck){
                document.getElementById("faultySerialNumber").innerHTML = 'Please Enter Faulty Unit Serial Number';
				
            }
            else{
                document.getElementById("faultySerialNumber").innerHTML = '';
                //phoneValidation = false;
            }
        }
        if(serviceType =='Advanced Exchange in Days'){            
            var oCase = this.requiredFieldValidations(component, [                
                {id: 'failureOccurance', recordEditForm: true, required: true},
                {id: 'failureDetection', recordEditForm: true, required: true},
                {id: 'failureDetectionDate', recordEditForm: true, required: true},
                {id: 'failureDescription', recordEditForm: true, required: true}            
            ]),
                errorMessage = (oCase.error?oCase.error:''); 
            console.log('error message '+errorMessage);
        }  
        if(serviceType =='Identical Repair' || serviceType == 'Return for Repair or Replacement'){            
            var oCase = this.requiredFieldValidations(component, [                
                {id: 'failureOccurance1', recordEditForm: true, required: true},
                {id: 'failureDetection1', recordEditForm: true, required: true},
                {id: 'failureDetectionDate1', recordEditForm: true, required: true},
                {id: 'failureDescription1', recordEditForm: true, required: true}            
            ]),
                errorMessage = (oCase.error?oCase.error:''); 
            console.log('error message '+errorMessage);
        }
        if(serviceType =='Spare Part Sales'){            
            var oCase = this.requiredFieldValidations(component, [                
                {id: 'quantity', recordEditForm: true, required: true}                      
            ]),          
                errorMessage = (oCase.error?oCase.error:''); 
            console.log('error message inside spare part sales '+errorMessage);
        }
        if(errorMessage){
            document.getElementById("errorOnCreate").innerHTML = errorMessage;
            requiredFieldsValidation = true;
			
        }else{
            document.getElementById("errorOnCreate").innerHTML = '';
            requiredFieldsValidation = false;
        }               
        var phoneNumber = component.get('v.newChildCase.HWS_Fault_Reported_By_Phone__c');
        console.log('phoneNumber '+phoneNumber);
        if(phoneNumber!= ''){
            if(phoneNumber!= undefined && serviceType != 'Spare Part Sales'){
                console.log('phone number inside if '+phoneNumber);
                var phoneValidateCheck = this.phoneValidation(phoneNumber);
                console.log('phoneValidateCheck '+phoneValidateCheck);
                if(phoneValidateCheck){
                    document.getElementById("validatePhone").innerHTML = 'Please enter valid Phone number. Phone number should only contain digits(ex: +XXX XX XXXX, XXXXXXXXXX)';
                    phoneValidation = true;
                }else{
                    document.getElementById("validatePhone").innerHTML = '';
                    phoneValidation = false;
                }
            }
        }
        var emailId = component.get('v.newChildCase.HWS_Fault_Reported_By_Email__c');
        //var EmailValidate = component.find("validateEmail").get("v.value");
        console.log('emailId '+emailId);
        if(emailId!= ''){
            if(emailId!= undefined){
                var emailValidateCheck = this.emailValidation(emailId);
                console.log('emailValidateCheck '+emailValidateCheck);
                if(emailValidateCheck){
                    //document.getElementById("validateEmailId").innerHTML = 'Please Enter Valid Email Id';
                    emailValidation = true;
                }else{
                    emailValidation = false;
                }
            }
        } 
        //var dupSerialCheck = this.duplicateSerialnumCheck(component);
        console.log('validation:'+validation);                
        console.log('requiredFieldsValidation outside if '+requiredFieldsValidation+' phoneValidation '+phoneValidation
                    +' faultySerialCheck '+faultySerialCheck );
        if(requiredFieldsValidation || phoneValidation || emailValidation || faultySerialCheck || !dateChangeValidate){
            console.log('requiredFieldsValidation '+requiredFieldsValidation+' phoneValidation '+phoneValidation+' Email validation '+emailValidation);
            component.set('v.stageNumber', 4);
            validation = true;
            component.set('v.oneclick','');
            //return validation;
        }
        else{
            //component.set('v.stageNumber', parseInt(component.get('v.stageNumber'))+1);
            component.set('v.oneclick',undefined);
            validation = false;
        }  
		if(parentCheck == 'addPart' && !validation){
            component.set("v.selectedAssetstep2",false);
            component.set("v.SelectNEA",false);
            component.set("v.SelectConNum",false);
            component.set("v.selectedVersionstep3",false);
            component.set('v.childcasestep4',false);
            component.set("v.ProgressBarCounter",1);
            component.set("v.ProgressBarNEACounter",1);
            component.set("v.ContNumProgressBarCounter",1);
            component.set("v.ContNEAProgressBarCounter",1);
        }
        if(parentCheck == 'parentCheck' && !validation){
            component.set('v.childcasestep4',true);
            component.set('v.ProgressBarCounter', 4);
            component.set("v.ProgressBarNEACounter",5);
            component.set("v.ContNumProgressBarCounter",5);
            component.set("v.ContNEAProgressBarCounter",6);
        }
        return validation;       
    },
    bulkParentCaseValidation : function(component, event){
        var validation = false;
        var phoneValidation = false;
        var emailValidation = false;
        var emailId = component.get('v.parentBulkUploadCase.HWS_ShipmentRecipientEmailId__c');
        var phoneNumber = component.get('v.parentBulkUploadCase.HWS_Shipment_Recipient_Phone__c');
        if(phoneNumber!= ''){
            if(phoneNumber!= undefined){
                console.log('phone number inside if '+phoneNumber);
                var phoneValidateCheck = this.phoneValidation(phoneNumber);
                console.log('phoneValidateCheck '+phoneValidateCheck);
                if(phoneValidateCheck){
                    document.getElementById("validateBulkParentPhone").innerHTML = 'Please enter valid Phone number. Phone number should only contain digits(ex: +XXX XX XXXX, XXXXXXXXXX)';
                    phoneValidation = true;
                }else{
                    document.getElementById("validateBulkParentPhone").innerHTML = '';
                    phoneValidation = false;
                }
            }
        }
        if(emailId!= ''){
            if(emailId!= undefined){
                var emailValidateCheck = this.emailValidation(emailId);
                if(emailValidateCheck){
                    document.getElementById("validateBulkParentEmail").innerHTML = 'You have entered an invalid format.';
                    emailValidation = true;
                }else{
                    document.getElementById("validateBulkParentEmail").innerHTML = '';
                    emailValidation = false;
                }
            }
        }
        if( phoneValidation || emailValidation){
            
            validation = true;
        }
        else{
            //component.set('v.stageNumber', parseInt(component.get('v.stageNumber'))+1);
            validation = false;
        }
        return validation;
    },
    duplicateSerialnumCheck: function(component,parentCheck){
        var validation = false;
        var serialNumber;
        var serviceType = component.get('v.serviceType');
        if(serviceType == 'Advanced Exchange in Days' || serviceType == 'Advanced Exchange in Hours' ){
            serialNumber = component.find("faultySerial").get("v.value");
        }
        if(serviceType == 'Identical Repair' || serviceType == 'Return for Repair or Replacement' ){
            serialNumber = component.find("faultySerial1").get("v.value");
        }
        var contractLines = component.get("v.assetRec");
        var duplicateSerialnumCheck = false;
        var newChildCasesList = component.get('v.listChildCase');
        var action = component.get("c.duplicateSerialNumberInfo");
        action.setParams({
            "serialNumber" : serialNumber,
            materialCode  : contractLines[0].HWS_Part_Code__c
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var dupSerfromApex = response.getReturnValue();
                console.log('dupSerfromApex ' +dupSerfromApex);
                if(!$A.util.isEmpty(dupSerfromApex) &&  dupSerfromApex != '' &&  dupSerfromApex != null){
                    console.log('DuplicateSNum '+dupSerfromApex);
                    duplicateSerialnumCheck = true;
                    this.childCaseValidation(component,parentCheck);
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        title : 'Error Message',
                        mode: 'sticky',
                        type: 'error',
                        key: 'info_alt',
                        message: 'message',
                        messageTemplate: 'Sorry, Cannot proceed with case creation as entered serial number and {0} pending for closure! {1}',
                        messageTemplateData: ['material code is part of an existing case', {
                            url: $A.get("$Label.c.Duplicate_SerialNumber")+dupSerfromApex[0].Id,
                            label: 'Case Number: '+dupSerfromApex[0].CaseNumber,
                        }]   
                    });
                    validation = true;
                    component.set('v.oneclick','');
                    resultsToast.fire();
                }else if(newChildCasesList.length!=0){
                    var faultCodeList =[];
                    for(var i in newChildCasesList){
                        var faultCode = newChildCasesList[i].HWS_Faulty_Serial_Number__c;
                        if(faultCode !='' && faultCode != null && faultCode != undefined)
                            faultCodeList.push(faultCode.toUpperCase());
                    }
                    if(faultCodeList != null && faultCodeList != '' && faultCodeList.includes(serialNumber.toUpperCase())){
                        this.showToast('error','Error Message','Entered faulty serial number is Part of previously added part');
                        validation = true;
                        component.set("v.duplicateSerialnumCheck",true); 
                        component.set('v.oneclick','');
                    }
                    else{
                        validation = this.childCaseValidation(component,parentCheck);
                        if(parentCheck == 'parentCheck'){
                            if(!validation){
                                this.createChildCase(component, event);
								//Code Changes for 29132
                                component.set("v.getPPU",false);
                                var newAssetList = component.get('v.getAllAssets');
                                if(newAssetList != null){
                                    for(var i=0;i<newAssetList.length;i++){
                                        var getPayPerUse=newAssetList[i].HWS_ServiceOffering__c;
                                        if( getPayPerUse != undefined && (getPayPerUse.includes('RES RFR PU') || getPayPerUse.includes('RES AED PU'))){
                                            component.set("v.getPPU", true);
                                            break;
                                        }
                                    }
                                }
                                component.set('v.stageNumber', parseInt(component.get('v.stageNumber'))+1);
                                var contactLookup = component.find("contactAuraId");
                                contactLookup.doInitFromPortal();
                                var accountLookup = component.find("recordValue2");
                                accountLookup.doInitFromPortal();
                            }
                        }
                        //3876 -- added validation condition
                        else if(parentCheck == 'addPart' && !validation){
                            this.addPartHelper(component,event);
                        }
                    }                     
                }else{
                    validation = this.childCaseValidation(component,parentCheck);
                    if(parentCheck == 'parentCheck'){
                        if(!validation){
                            this.createChildCase(component, event);
							//Code Changes for 29132
                                component.set("v.getPPU",false);
                                var newAssetList = component.get('v.getAllAssets');
                                if(newAssetList != null){
                                    for(var i=0;i<newAssetList.length;i++){
                                        var getPayPerUse=newAssetList[i].HWS_ServiceOffering__c;
                                        if( getPayPerUse != undefined && (getPayPerUse.includes('RES RFR PU') || getPayPerUse.includes('RES AED PU'))){
                                            component.set("v.getPPU", true);
                                            break;
                                        }
                                    }
                                }
                            component.set('v.stageNumber', parseInt(component.get('v.stageNumber'))+1);
                            var contactLookup = component.find("contactAuraId");
                            contactLookup.doInitFromPortal();
                            var accountLookup = component.find("recordValue2");
                            accountLookup.doInitFromPortal();
                        }
                    }
                    //3876 -- added validation condition
                    else if(parentCheck == 'addPart' && !validation){
                        this.addPartHelper(component,event);
                    }
                } 
                //validation = this.childCaseValidation(component); // this function is called after success of duplicate num check
                return validation;
            }
            
        });
        $A.enqueueAction(action);
    },
    addPartHelper : function(component,event){
        this.createChildCase(component, event);
        this.clearChild(component, event);
        var serviceType = component.get("v.serviceType");
        var contractNumber = component.get("v.contractNumber");
		var country = component.get("v.country");
        component.set('v.stageNumber', 2);
        component.set("v.addPartCheck",true);
        component.set('v.assetRec',null);
        component.set('v.clis',null);
        component.set("v.versionRec", null); 
        component.set("v.addPartServiceType",serviceType);
        component.set("v.addPartcontractNumber",contractNumber);
		component.set("v.addPartCountry", country);
        var childCmp = component.find("assetSecId");
        childCmp.componentRefresh();
        var childCmp1 = component.find("versionSecId");
        childCmp1.componentRefresh();
	    var childCmp2 = component.find("contractNumberSecId");
        childCmp2.componentRefresh();
        var childCmp3 = component.find("neaSecId");
        childCmp3.componentRefresh();
        var childCmp4 = component.find("contractAssetSecId");
        childCmp4.componentRefresh();
        var contactLookup = component.find("contactAuraId");
        contactLookup.doInitFromPortal();
        var accountLookup = component.find("recordValue2");
        accountLookup.doInitFromPortal();
        component.set('v.oneclick','');
        
    },
    getplannedDeliveryDateTime : function(component, event){
        /*var selectedAsset = component.get("v.assetRec");
        var businesshours = selectedAsset[0].HWS_ContractLineItem__r.CH_BusinessHour__c;
        var leadTimeUnit = selectedAsset[0].HWS_ContractLeadTimeUnit__c;
        var leadTimeDuration = selectedAsset[0].HWS_ContractLeadTimeDuration__c;
        var specifiedTime = selectedAsset[0].HWS_SpecifiedDeliveryTargetTime__c;
        var byPassPlannedDate = component.get("v.byPassDate");
        var action = component.get("c.plannedDeliveryDateTime");
        console.log('businesshours' +businesshours+ '    leadTimeUnit'+leadTimeUnit+'    leadTimeDuration'+leadTimeDuration);
        console.log('byPassPlannedDate' +byPassPlannedDate);
        action.setParams({ businessHrsId : businesshours,
                          leadTimeUnit : leadTimeUnit,
                          leadTimeDuration : leadTimeDuration,
                          byPassPlannedDate: byPassPlannedDate,
                          specifiedTime : specifiedTime
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state of response ' +state);
            if (state === "SUCCESS") {
                var stringItems = response.getReturnValue();
                console.log('Planned date stringItems' +stringItems);
                var date = new Date(stringItems);
                component.set("v.newChildCase.HWS_Planned_Delivery_Date__c", date);
                //alert(component.get("v.newChildCase.HWS_Planned_Delivery_Date__c"));
            }
        });
        $A.enqueueAction(action);*/
        var listChildCases = component.get("v.listChildCase");
        var selectedAccount = component.get('v.ShiptopartyAddress');
        //alert('listChildCases**'+listChildCases);
        //alert('selectedAccount**'+selectedAccount);
        var action = component.get("c.accountTimeZoneplannedDeliveryDateTime");
        action.setParams({ listChildCases : listChildCases,
                          selectedAccount : selectedAccount
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var stringItems = response.getReturnValue();                
                var st = [];
                st.push(stringItems.newTimeZoneCaseList);
                var listChildCasetimeZone = st[0];
                var st1 = [];
                st1.push(stringItems.bhTimeZone);
                console.log('SSSSTT:'+st1[0]);
                component.set("v.deliveryTimeZone",st1[0]); 
				for(var i=0; i<listChildCasetimeZone.length; i++){
                    var countryTime = listChildCasetimeZone[i].HWS_PlannedDeliveryDateShipment__c; 
					countryTime = new Date(countryTime);
                    var counteryDateOnly = $A.localizationService.formatDate(countryTime);                       
                	counteryDateOnly = counteryDateOnly.replace(/[\/\\.-]/g, ' ');
                	var counteryTimeOnly = $A.localizationService.formatTime(countryTime);
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
                	listChildCasetimeZone[i].HWS_PlannedDeliveryDateShipment__c = counteryDateOnly +', ' + strTime+' ('+listChildCasetimeZone[i].HWS_Delivery_TimeZone__c+')';
                }
                component.set("v.listChildCase",listChildCasetimeZone);
                console.log('listChildCasetimeZone:'+JSON.stringify(listChildCasetimeZone));
                
            }
        });
        $A.enqueueAction(action);
    }, 
    getBulkServiceTypes : function(component, event){   
        var accountId = component.get('v.accountId');   
        var action = component.get('c.bulkUploadServiceTypes');
        action.setParams({ 
            accountId : accountId 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state of response ' +state);
            if (state === "SUCCESS") {
                var serviceTypes = response.getReturnValue();
                component.set("v.serviceTypes", serviceTypes);
            }
        });
        $A.enqueueAction(action);
    },
    requiredFieldValidations : function(component, values) {
        console.log('values in validationsOnChildCase '+JSON.stringify(values)+values.length);
        let result = {}, fieldsNotFilled= [];  
        for(let i = 0; i < values.length; i++){
            if(values[i].recordEditForm){
                console.log('inside if '+component.find(values[i].id));
                let fields = component.find(values[i].id).get("v.body");                
                console.log('fields '+JSON.stringify(fields) +'-Length:'+fields.length);
                for(let n = 1; n < fields.length; n++){
                    console.log('values[i] '+fields[n].get('v.value'));
                    if(values[i].required && !fields[n].get('v.value')
                       || values[i].required && fields[n].get('v.value') === undefined || values[i].required && fields[n].get('v.value') === ''){
                        fieldsNotFilled = [...fieldsNotFilled, fields[n].get('v.fieldName')];
                        var redoutlineremover = component.get('v.redoutlineremover');
                        if(redoutlineremover){
                            $A.util.addClass(fields[n], 'redOutLine');
                        }
                        else {
                            $A.util.removeClass(fields[n], 'redOutLine');
                        }
                    }
                    else {
                        $A.util.removeClass(fields[n], 'redOutLine');
                    }
                    result[fields[n].get('v.fieldName')]= fields[n].get('v.value');
                }  
            }
            else {
                let field = component.find(values[i].id);
                if(values[i].required && !field.get('v.value')
                   || values[i].required && field.get('v.value') === '') {
                    fieldsNotFilled = [...fieldsNotFilled, field.get('v.name')];
                    var redoutlineremover = component.get('v.redoutlineremover');
                    if(redoutlineremover){
                        console.log('when click on previous button');
                        $A.util.addClass(field, 'redOutLine');
                    }
                } 
                else {
                    $A.util.removeClass(field, 'redOutLine');
                }
                result[field.get('v.name')]= field.get('v.value');
            }            
        }
        //alert('fieldLength outside for loop'+fieldsNotFilled.length);
        if(fieldsNotFilled.length > 0){
            result= { error : "*All required fields must be completed.", fields: fieldsNotFilled.join(', ') };
        }
        console.log('result '+JSON.stringify(result));
        return result;
    },
    phoneValidation : function(phoneNumber){
        console.log('phone: '+phoneNumber);
        var regExpEmailformat = /^[+]*[\s0-9]*$/;
        var validation = false;
        if(!regExpEmailformat.test(phoneNumber) || phoneNumber == undefined || phoneNumber ==''){
            validation = true; 
        }else{
            validation = false;
        }
        return validation;
    },
    emailValidation : function(emailValue) {
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;          
        var validation = false;
        if(!regExpEmailformat.test(emailValue) || emailValue == undefined || emailValue == '' ){
            validation = true; 
        }else{
            validation = false;
        }
        return validation;
    },
    showToast : function(type,title,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:'10000',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire(); 
    },
    openCaseTab : function(component, recordid) {
        var navService  = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'Case',
                recordId : recordid // change record id. 
            }
        };
        component.set("v.pageReference", pageReference);
        var pageReference1 = component.get("v.pageReference");
        navService.navigate(pageReference1);
    },
    clearChild : function(component, event){
        component.set("v.newChildCase",{'sobjectType':'Case',
                                        'HWS_Site_ID__c':'',
                                        'HWS_Replacement_Unit_Serial_Number__c':'',
                                        'HWS_Fault_Reported_By_Name__c':'',
                                        'HWS_Faulty_Serial_Number__c':'',
                                        'HWS_Failure_Occurance__c':'',
                                        'HWS_Failure_Detection__c':'',
                                        'HWS_Site_Information__c':'',
                                        'HWS_Fault_Reported_By_Phone__c':undefined,
                                        'HWS_Fault_Reported_By_Email__c':'',
                                        'HWS_Customer_Reference_Number__c':'',
                                        'HWS_Failure_Description__c':'',
                                        'HWS_Quantity__c':'',
                                        'HWS_Failure_Detection_Date__c':'',
                                        'HWS_Requested_Delivery_Date_Time__c':null,
                                        'HWS_Planned_Delivery_Date__c':null,
                                        'HWS_Failure_Description_Server_ID__c':'',
                                        'HWS_Fault_Reported_By_Phone__c':''});
        component.set("v.customerPartRev",'');
    },  
    clearParent : function(component, event){
        component.set("v.parentCase",{'sobjectType':'Case',
                                      'HWS_Shipment_Recipient_Name__c':'',
                                      'HWS_Delivery_Additional_Information__c':'',
                                      'HWS_Shipment_Recipient_Phone__c':'',
                                      'HWS_ShipmentRecipientEmailId__c':'',
                                      'HWS_Customer_PO__c':''});                                        
        component.set('v.ShiptopartyAddress','');
        component.set('v.communicationContact','');
        
    },
     //26101
    deliveryInfo: function(component, event, helper) {               
        var userTimeZone = component.get("v.currentUserTimeZone");
        var selectedServiceType = component.get("v.serviceType");
        if(selectedServiceType == 'Advanced Exchange in Hours'){
            component.set('v.childCaseColumns', [
                {label: 'Part Code', fieldName: 'HWS_Part_Code__c', type: 'text', "initialWidth": 150},
                {label: 'Part Revision', fieldName: 'Street_Address_1__c', type: 'text', "initialWidth": 150},
                {label: 'Planned Delivery Date (User TZ)', fieldName: 'HWS_Planned_Delivery_Date__c', type: 'date', "initialWidth": 250,
                     typeAttributes:{
                         day: '2-digit',
                         year: "numeric",
                         month: "short",
                         day: "2-digit",
                         hour: "2-digit",
                         minute: "2-digit",
                         hour12: true,
                         timeZone: userTimeZone
                     }
                },
                {label: 'Planned Delivery Date (Ship to TZ)', fieldName: 'HWS_PlannedDeliveryDateShipment__c', type: 'text', "initialWidth": 260 
                },  
                {label: 'Cust Req Delivery Date (User TZ)', fieldName: 'HWS_Requested_Delivery_Date_Time__c', editable:true, type: 'date', "initialWidth": 260,
                     typeAttributes: {
                         day: '2-digit',
                         month: 'short',
                         year: 'numeric',
                         hour: '2-digit',
                         minute: '2-digit',                                     
                         hour12: true,
                         timeZone: userTimeZone
                     },
                     cellAttributes:{  
                         class:{  
                             fieldName:"Street_Address_3__c"
                         }
                     }
                },
                {label: 'Cust Req Delivery Date (Ship to TZ)', fieldName: 'HWS_RequestedDateShipment__c', type: 'text', "initialWidth": 260},      
            	]);
			}
        	else{
                component.set('v.childCaseColumns', [
                {label: 'Part Code', fieldName: 'HWS_Part_Code__c', type: 'text'},
                {label: 'Part Revision', fieldName: 'Street_Address_1__c', type: 'text'},
                {label: 'Planned Delivery Date (User TZ)', fieldName: 'HWS_Planned_Delivery_Date__c', type: 'date',
                typeAttributes:{
                day: '2-digit',
                year: "numeric",
                month: "short",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit",
                hour12: true
                }
                },
                {label: 'Planned Delivery Date (Ship to TZ)', fieldName: 'HWS_PlannedDeliveryDateShipment__c', type: 'text',"initialWidth": 260 }					   
            ]);
        }        
        this.getShipToTimeZone(component, event, helper);               
	},
    //26101
    getShipToTimeZone : function(component, event, helper) {
        var childCasesList = component.get("v.listChildCase");
        var bhIdList = [];
        for(var i=0;i<childCasesList.length;i++){            
            bhIdList.push(childCasesList[i].Street_Address_2__c);
        }
        console.log('Business Id::: '+bhIdList);
        var action =component.get("c.getShipToTimeZone");
        action.setParams({
            selectedAccount: component.get('v.ShiptopartyAddress'),
            businessHourIdList : bhIdList,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var stringTimeZoneMap = response.getReturnValue();                
                if(Object.keys(stringTimeZoneMap).includes("Account")){
                    component.set("v.shipToTimeZone", "Account");
                    component.set("v.shipToTimeZoneMap",stringTimeZoneMap["Account"]);                    
                }
                else if(Object.keys(stringTimeZoneMap).includes("BusinessHour")){
                   component.set("v.shipToTimeZone", "BusinessHour");
                   component.set("v.shipToTimeZoneMap",stringTimeZoneMap["BusinessHour"]);                   
                }                
            }           
             this.handleCustReqShipmentDate(component,event,helper);
        });
        $A.enqueueAction(action);
    }, 
    
    //26101 To handle the Requested Date Shipment function from Dlivery Info screen in line Edit
    handleCustReqShipmentDate: function(component,event,helper) {
       	var childCasesList = component.get("v.listChildCase");        
       	var reqVal = true;
        var countryTimezone = 'GMT';
        var shipToTimeZone = component.get("v.shipToTimeZone");        
        var shipToTimeZoneMap = component.get("v.shipToTimeZoneMap");
        if(childCasesList){
            for(var i=0;i<childCasesList.length;i++){
                var requestedDate = childCasesList[i].HWS_Requested_Delivery_Date_Time__c; 
                if(childCasesList[i].HWS_Requested_Delivery_Date_Time__c != null && childCasesList[i].HWS_Requested_Delivery_Date_Time__c != undefined){
					childCasesList[i].Street_Address_3__c =  null;                                           
                        
                    if(shipToTimeZone == 'Account'){
                        countryTimezone = shipToTimeZoneMap[component.get('v.ShiptopartyAddress')];
                    }
                    if (shipToTimeZone == 'BusinessHour'){
                        var bhId = childCasesList[i].Street_Address_2__c;
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
                    childCasesList[i].HWS_RequestedDateShipment__c = counteryDateOnly +', ' + strTime +' ('+countryTimezone+')';
                    
                }                    
                else{
                    childCasesList[i].HWS_Requested_Delivery_Date_Time__c = null;
                    childCasesList[i].HWS_RequestedDateShipment__c = null;
                    childCasesList[i].Street_Address_3__c =  "delInfoBGCol"; 
                }
            } 
			document.getElementById("validateRequiredFields").innerHTML = '';
            component.set("v.listChildCase",childCasesList);            	
            this.getplannedDeliveryDateTime(component, event,helper);
            component.set("v.stageNumber",13);
		}
    },
})