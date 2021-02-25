({
	init : function(component, event, helper) {
        // Set legal account displayed fields
        component.set('v.legalEntityColumns', [
            {label: 'Name', fieldName: 'Name', sortable: 'true', searchable: 'true', type: 'text', typeAttributes: {
                label: { fieldName: 'Name' }
            }},
            {label: 'Parent Account', fieldName: 'CH_ParentAccountName__c', sortable: 'true', searchable: 'true', type: 'text'},
            {label: 'Account Name Alias', fieldName: 'CH_Account_Name_Alias__c', searchable: 'true', type: 'hidden'}
        ]);
        // Set Asset displayed fields
        component.set('v.assetColumns', [
            {label: 'Product', fieldName: 'ProductName', sortable: 'true', searchable: 'true', type: 'text', typeAttributes: {
                label: { fieldName: 'ProductName' }
            }},
            {label: 'Solution', fieldName: 'SolutionName', sortable: 'true', searchable: 'true', type: 'text', typeAttributes: {
                label: { fieldName: 'SolutionName' }
            }},
            {label: 'Product Variant', fieldName: 'VariantName', sortable: 'true', searchable: 'true', type: 'text', typeAttributes: {
                label: { fieldName: 'VariantName' }
            }},
            {label: 'Product Release', fieldName: 'ReleaseName', sortable: 'true', searchable: 'true', type: 'text', typeAttributes: {
                label: { fieldName: 'ReleaseName' }
            }},
            {label: 'Country', fieldName: 'CH_CountryISOName__c', sortable: 'true', searchable: 'true', type: 'text'},
            {label: 'Product Description', fieldName: 'ProductDescription', searchable: 'true', type: 'hidden'}  
        ]);
        // Set Entitlement displayed fields
        component.set('v.entitlementColumns', [
            {label: 'Entitlement Name', fieldName: 'Name', sortable: 'true', searchable: 'true', type: 'text', typeAttributes: {
                label: { fieldName: 'Name' }
            }},
            {label: 'Contract Name', fieldName: 'ContractName', sortable: 'true', searchable: 'true', type: 'text', typeAttributes: {
                label: { fieldName: 'ContractName' }
            }},
            {label: 'Project', fieldName: 'ProjectName', sortable: 'true', searchable: 'true', type: 'text'},  
            {label: 'NEA Count', fieldName: 'NEACount', sortable: 'true', searchable: 'true', type: 'number'}
        ]);
        // Set Network Element Assets displayed fields
        component.set('v.neaColumns', [
            {label: 'Network Element ID', fieldName: 'CH_NetworkElementID__c', sortable: 'true', searchable: 'true', type: 'text'},
            {label: 'Asset Name', fieldName: 'Name', sortable: 'true', searchable: 'true', type: 'text', typeAttributes: {
                label: { fieldName: 'Name' }
            }},
            {label: 'Product', fieldName: 'ProductName', sortable: 'true', searchable: 'true', type: 'text', typeAttributes: {
                label: { fieldName: 'ProductName' }
            }},
            {label: 'Solution', fieldName: 'SolutionName', sortable: 'true', searchable: 'true', type: 'text', typeAttributes: {
                label: { fieldName: 'SolutionName' }
            }},
            {label: 'Product Variant', fieldName: 'VariantName', sortable: 'true', searchable: 'true', type: 'text', typeAttributes: {
                label: { fieldName: 'VariantName' }
            }},
            {label: 'Product Release', fieldName: 'ReleaseName', sortable: 'true', searchable: 'true', type: 'text', typeAttributes: {
                label: { fieldName: 'ReleaseName' }
            }},
            {label: 'Address', fieldName: 'Address', sortable: 'true', searchable: 'true', type: 'text'},
            {label: 'Lab', fieldName: 'CH_LabEnvironment__c', sortable: 'true', type: 'boolean'},        
            {label: 'Country', fieldName: 'CH_CountryISOName__c', searchable: 'true', type: 'hidden'}
        ]);
        helper.setContactNameAndId(component, event);
        helper.setCaseRecordTypeId(component, event);
        helper.setCaseOwnerId(component, event);
        helper.getArticles(component, event);
	},
    eventHandler : function(component, event, helper) {
        var message = event.getParam("message"), stageNumber = component.get('v.stageNumber'), target = event.getParam("target");
        switch(message){
            case 'neaSelection':
                var stageNumber = parseInt(component.get('v.stageNumber'));
                component.set("v.neaStageNumber", stageNumber);
                component.set('v.stageNumber', 4);
                break;
            case 'clearNEA':
                component.set('v.selectedNEA', null);
                component.set('v.provisoryNEA', null);
                component.find('neaSelection').resetSelection();
                break;
            case 'incrementActionCounter':
                helper.incrementActionCounter(component);
                break;
            case 'decrementActionCounter':
                helper.decrementActionCounter(component); 
                break;
            case 'scriptVerification':
                component.set('v.entitlementScriptVerified', event.getParam("object"));
                break;
            case 'notListed':
                break;
            case 'noRecordFound':
                break;
            case 'recordFound':
                break;
            case 'notLinkedToCustomer':
                break;
            case 'scriptVerification':
                break;
            default:
                let object = JSON.parse((event.getParam("object")==null?null:event.getParam("object")));
                if(target === 'NEA') {
                   component.set('v.provisoryNEA', object);
                   if(parseInt(component.get("v.neaStageNumber")) == -1)
                       component.set('v.selected'+target.split(' ').join(''), object);
                }
                else component.set('v.selected'+target.split(' ').join(''), object);
                component.set('v.stageNumber', message==='next'?(stageNumber+1):stageNumber);
                helper.handleProgressBar(component);
                break;
        }        
    },
	startCaseCreation : function(component, event, helper) {
        var oCase = helper.recordEditFormsToObject(component, [
                {id: 'descriptionField', recordEditForm: false, required: true},
                {id: 'requiredFields', recordEditForm: true, required: true}
        	]), errorMessage = (oCase.error?oCase.error:(oCase.Severity__c==='Critical'?'*Severity cannot be set to Critical.':''));
        if(errorMessage === '') {
            component.set('v.stageNumber', 1);
            component.set('v.preSeverity', oCase.Severity__c);
            component.set('v.preDescription', oCase.Description);
        }
        component.set('v.save', errorMessage);
	},
    knowledgeSearch : function(component, event, helper) {
        if(event.keyCode == 13){
            helper.incrementActionCounter(component);
            let text = component.find("descriptionField").get("v.value"),
            	data = component.get("v.allArticles"), results = data, regex;
            try {
                regex = new RegExp(text, "i");
                results = data.filter(
                    row => regex.test(row.Title) || 
                    regex.test(row.CH_KB_Products__c) || 
                    regex.test(row.Description__c) || 
                    regex.test(row.CH_PurposeRequired__c) ||
                    regex.test(row.CH_InformationForInternalAudiences__c) ||
                    regex.test(row.CH_QuestionOrProductDescription__c) ||
                    regex.test(row.CH_AnswerOrResolution__c) ||
                    regex.test(row.CH_ProblemDescriptionRequired__c)
                );
            }
            catch(e) { results = data; }
            component.set("v.filteredArticles", results);
            component.set('v.articleSearchActive', true);
                helper.decrementActionCounter(component);
        }		
	},
    next : function(component, event, helper) {
        if(!event.getSource().get("v.disabled")) {
            var stageNumber = parseInt(component.get('v.stageNumber'));
            switch(stageNumber){
                case 3:
                    if(component.get('v.selectedEntitlement').NEACount != 0 && component.get('v.selectedNEA') == null) {
                    	component.set('v.stageNumber',  4);                        
                    }
                    else component.set('v.stageNumber', component.get("v.timeZoneMissing") ? 5 : 6);
                    break;
                case 4:
                    let neaStageNumber = parseInt(component.get("v.neaStageNumber"));
                    if(neaStageNumber != -1) {
                        component.set('v.selectedNEA', component.get('v.provisoryNEA'));
                        component.set('v.stageNumber', neaStageNumber);
                        component.set("v.neaStageNumber", -1);                   
                    }
                    else component.set('v.stageNumber', component.get("v.timeZoneMissing") ? 5 : 6);
                    break;
                default:
                    component.set('v.stageNumber', stageNumber+1);
                    break;
            }
            helper.handleProgressBar(component);
        }
	},
	previous : function(component, event, helper) {
        if(!event.getSource().get("v.disabled")) {
            var stageNumber = parseInt(component.get('v.stageNumber'));
            switch(stageNumber){
                case 6:
                    component.set('v.stageNumber', component.get('v.unhappyPath') ? 5 : (component.get('v.selectedNEA') != null ? 4 : 3));
                    break;
                case 5:
                    component.set('v.stageNumber', component.get('v.selectedNEA') != null ? 4 : 3);
                    break;
                case 4:
                    let neaStageNumber = parseInt(component.get("v.neaStageNumber"));
                    if(neaStageNumber != -1) {
                        component.find("neaSelection").resetSelection();
                        component.set("v.neaStageNumber", -1);
                        component.set('v.stageNumber', neaStageNumber);             
                    }
                    else component.set('v.stageNumber', 3);
                    break;
                default:
                    component.set('v.stageNumber', stageNumber-1);
                    break;
            }
            helper.handleProgressBar(component);
        }
    },
    saveCaseHandler : function(component, event, helper) {
        if(!component.get("v.showSpinner")){
            helper.incrementActionCounter(component); // Increment Action Counter
            var newCase = helper.recordEditFormsToObject(component, [
                    {id: 'preCaseDetailFields', recordEditForm: true, required: true},
                    {id: 'reqCaseDetailFields', recordEditForm: true, required: true},
                    {id: 'notReqCaseDetailFields', recordEditForm: true, required: false},
                    {id: 'emailCaseDetailFields', recordEditForm: true, required: false}
                ]),
                errorMessage = (newCase.error?newCase.error:(newCase.Severity__c==='Critical'?'*Severity cannot be set to Critical.':''));
            //Email Verification
            if(newCase.CH_AdditionalContacts__c && newCase.CH_AdditionalContacts__c.length > 0){
                newCase.CH_AdditionalContacts__c = newCase.CH_AdditionalContacts__c.replace(/\s+/g, '');
                newCase.CH_AdditionalContacts__c = newCase.CH_AdditionalContacts__c.replace(/\,/g, ';');
                newCase.CH_AdditionalContacts__c.split(';').forEach( (x) => {
                    if(!helper.validateEmail(x) && x.length != 0) {
                        errorMessage = x+" is not a valid email address.";
                        return false; 
                    }
                });
            }
            //
            if(errorMessage === '') {
                newCase.ContactId = component.get("v.selectedContact").Id;
                newCase.AccountId = component.get("v.selectedLegalEntity").Id;
                newCase.AssetId = component.get("v.selectedAsset").Id;
                newCase.CH_NetworkElementAsset__c = component.get("v.selectedNEA")?component.get("v.selectedNEA").Id:null;
                newCase.ProductId = component.get("v.selectedAsset").Product2Id;
                newCase.RecordTypeId = component.get("v.recordTypeId");
                newCase.OwnerId = component.get("v.portalOwnerId");
                newCase.Origin='Portal';
                newCase.CH_Outage__c = 'No';
                newCase.BusinessHoursId = component.get("v.selectedBusinessHours") ? component.get("v.selectedBusinessHours").Id : null;
                var entitlement = component.get("v.selectedEntitlement");
                newCase.EntitlementId = entitlement.Id;
                if(entitlement){
                    if((entitlement.ContractScript && entitlement.ContractScript.length != 0) || (entitlement.LineItemScript && entitlement.LineItemScript.length != 0)) {
                        newCase.CH_EntitlementException__c = 'Entitlement Script Verification Required';
                    } else {
                        newCase.CH_EntitlementException__c = 'No Exception';
                    }
                }
                helper.action(component, "c.doCase", {operationType: 'insert', oCase: newCase, withoutSharing: true}, function(result, error){
                    helper.decrementActionCounter(component);
                    if(error) return component.set("v.save", error);
                    if(!result) {
                        console.log("Unknown error");
                        return this.showToast('error', 'Error', "Something went wrong");
                    }
                    var href = window.location.href.split('/');
                    href.pop();
                    window.location.href= href.join('/')+'/case/'+result; 
                });	
            }
            else helper.decrementActionCounter(component);
            component.set("v.save", errorMessage);
        }
	},
    handleBHCalculation : function(component, event, helper) {
        let entitlement = component.get('v.selectedEntitlement');
        if(entitlement != null && entitlement != '') helper.setCaseBusinessHours(component, entitlement);
    },
    handleTimeZoneConfirmation : function(component, event, helper) {
        helper.calculateCaseBusinessHours(component, component.get('v.selectedEntitlement'), component.get("v.selectedTimeZone"));
    },
    cancel : function(component, event, helper) {
        if(confirm('All the entered details will be Discarded . Are you sure you want to cancel?')) {
            var href = window.location.href.split('/')
            href.pop();
            window.location.href= href.join('/');            
        }
        else return false;
    }
})