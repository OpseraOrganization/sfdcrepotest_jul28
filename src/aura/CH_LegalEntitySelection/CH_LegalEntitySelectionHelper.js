({
    init : function(component, tableStructure, showOnlyAuthEntities, resetColumns) {
        let helper = this;
        helper.reset(component);
        if(resetColumns || (!resetColumns && !tableStructure || tableStructure.length == 0)) {
            tableStructure = [
                {label: 'Name', fieldName: 'AccountURL', sortable: 'true', searchable: 'true', type: 'url', typeAttributes: {
                    label: { fieldName: 'Name' }
                }},
                {label: 'Operational Customer Name', fieldName: 'OperationalCustomerName__c', sortable: 'true', type: 'text'},
                {label: 'Account Number', fieldName: 'AccountNumber', sortable: 'true', searchable: 'true', type: 'text'},
                {label: 'Parent Account', fieldName: 'CH_ParentAccountName__c', sortable: 'true', searchable: 'true', type: 'text'},
                {label: 'Account Name Alias', fieldName: 'CH_Account_Name_Alias__c', searchable: 'true', type: 'hidden'}
            ];
            if(!showOnlyAuthEntities) {
                tableStructure = [...tableStructure, {label: 'Care Contract', fieldName: 'CH_CareContract__c', sortable: 'true', type: 'boolean'}];
            }
        }
        component.set('v.tableColumns', tableStructure);
        //Get Legal Entities
        if(component.get("v.serviceType") === 'Customer Support') {
            if(!showOnlyAuthEntities) {
                component.set("v.legalEntities", []);
                helper.emit(component, 'noRecordFound');
            }
            else {
                helper.getLegalEntities(component, component.get("v.contact"));
                helper.emit(component, 'recordFound');
            }
        } else component.set("v.legalEntities", []);
    },
    getLegalEntities: function(component, contact) {
        let helper = this;
        if(!contact) return helper.reset(component);
        helper.incrementActionCounter(component);
        helper.action(component, "c.getContactAuthorizedLegalEntities",{
            withoutSharing: component.get("v.withoutSharing"), 
            contactId : contact.Id,
            swMaintenance : component.get("v.swMaintenance")
        }, function(legalEntitiesList, error){
            helper.decrementActionCounter(component);
            if(error || legalEntitiesList.length == 0) {
                component.set("v.legalEntities", []);
                if(error) console.log(error);
                else helper.emit(component, 'noRecordFound');
                return helper.reset(component);
            }
            var selected = false;
            for(var i = 0; i < legalEntitiesList.length; i++) {
                legalEntitiesList[i].AccountURL = helper.getLightningURL(legalEntitiesList[i].Id);
                if(legalEntitiesList[i].Id === component.get("v.selected")) {
                    selected = true;
                    component.find("legalEntityTable").setSelectedRows(new Array(legalEntitiesList[i].Id));
                    component.set('v.accountNameAlias', component.get('v.showAccountNameAlias') && legalEntitiesList[i].CH_Account_Name_Alias__c?object.CH_Account_Name_Alias__c:'');
                }
            }
            if(legalEntitiesList.length == 1 && !selected) helper.select(component, legalEntitiesList[0], component.get("v.autoNext"), true);
            component.set("v.legalEntities", legalEntitiesList);
        });
    },
    searchAllLegalEntities : function(component, text, serviceType) {
        let helper = this, contactId = component.get("v.contact.Id");
        if(!contactId) return helper.reset(component);
        helper.incrementActionCounter(component);
        helper.action(component, "c.searchLegalEntities",{
            searchString : text, 
            contactId : contactId,
            serviceType : serviceType
        }, function(legalEntitiesList, error){
            helper.decrementActionCounter(component);
            if(error || legalEntitiesList.length == 0) {
                component.set("v.legalEntities", []);
                if(error) console.log(error);
                else helper.emit(component, 'noRecordFound');
                return helper.reset(component);
            }
            var selected = false;
            for(var i = 0; i < legalEntitiesList.length; i++) {
                legalEntitiesList[i].AccountURL = helper.getLightningURL(legalEntitiesList[i].Id);
                if(legalEntitiesList[i].Id === component.get("v.selected")) {
                    selected = true;
                    component.find("legalEntityTable").setSelectedRows(new Array(legalEntitiesList[i].Id));
                    component.set('v.accountNameAlias', component.get('v.showAccountNameAlias') && legalEntitiesList[i].CH_Account_Name_Alias__c?object.CH_Account_Name_Alias__c:'');
                }
            }
            if(legalEntitiesList.length == 1 && !selected) helper.select(component, legalEntitiesList[0], component.get("v.autoNext"), true);
            component.set("v.legalEntities", legalEntitiesList);
        });
    },
    reset : function(component) {
        component.find("legalEntityTable").setSelectedRows(new Array());
        this.select(component, null);
    },
    select : function(component, object, nextOverride, selectInTable) {
        this.emit(component, nextOverride?'next':'select', object);
        component.set('v.selected', object ? object.Id : null);
        component.set('v.accountNameAlias', component.get('v.showAccountNameAlias') && object && object.CH_Account_Name_Alias__c?object.CH_Account_Name_Alias__c:'');
        if(selectInTable && object) component.find("legalEntityTable").setSelectedRows(new Array(object.Id));
    },
    // Generic Lightning URL Formation
    getLightningURL: function(recordId) {
        return '/one/one.app?#/sObject/' + recordId + '/view';
    },
    emit: function(component, event, args) {
        component.getEvent("onEvent").setParams({
            message	: event,
            target	: 'LegalEntity',
            object	: JSON.stringify(args)
        }).fire();
    },
    //
    action : function(component, method, args, callback) {
        let action = component.get(method);
        if(args) action.setParams(args);
        action.setCallback(this,function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                callback(response.getReturnValue(), null);
            } else if (state === "INCOMPLETE") {
                callback(null, 'Incomplete');
            } else if (state === "ERROR") {
                var errors = response.getError();
                callback(null, errors && errors[0] && errors[0].message?("Error message: " + errors[0].message):"Unknown error");
            }
        });
        $A.enqueueAction(action);
    },
    incrementActionCounter: function(component) {        
        component.getEvent("onEvent").setParams({
            message: 'incrementActionCounter'
        }).fire();
    },
    decrementActionCounter: function(component) {
        component.getEvent("onEvent").setParams({
            message: 'decrementActionCounter'
        }).fire();
    }
})