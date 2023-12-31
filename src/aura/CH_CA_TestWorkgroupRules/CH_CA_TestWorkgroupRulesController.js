({
    doInit : function(component, event, helper) { 
        // get the fields API name and pass it to helper function  
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var objDetails = component.get("v.objDetail");
        // call the helper function
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);
		helper.loadOptions(component,helper);
    },
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        if (controllerValueKey != '--None--') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--None--']);
            }  
        } else {
            component.set("v.listDependingValues", ['--None--']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
    Search : function(component,event) {
        component.set("v.Spinner", true);
		var selectedType = component.find("mySelect").get("v.value");
        if(selectedType==''){
            component.set("v.selectedValue","--None--");
        }
        var contractType=component.get("v.selectedValue");
        var action = component.get("c.fetchFilterValues");
        var Contract = component.find("contractId").get("v.value");
        var Severity= component.find("severity").get("v.value");
        var Region= component.find("region").get("v.value");
        var Country= component.find("country").get("v.value");
        var levelOfSupportval= component.find("LevelOfSupport").get("v.value");
        var customer = component.find("accLookup").get("v.value");
        var custoGroup = component.find("custoGroupLookup").get("v.value");
        var product = component.find("productLookup").get("v.value");
        var productGroup = component.find("productGroupLookup").get("v.value");
        var Outage = component.find("outageBox").get("v.value");
        /* Chnages w.r.t 17116 starts */
        var active = component.find("activeBox").get("v.value");
        var workgroupType= component.find("WorkgroupType").get("v.value");
        var serviceType= component.find("ServiceType").get("v.value");
        var productModule = component.find("productmoduleLookup").get("v.value");
        var productVariant = component.find("productvariantLookup").get("v.value");
        var solution = component.find("solutionLookup").get("v.value");
        action.setParams({Contract : Contract, Severity : Severity, Region : Region, Country : Country, levelOfSupport : levelOfSupportval, 
                          Customer : customer, CustomerGroup : custoGroup, Product : product, ProductGroup : productGroup, Outage : Outage , 
                          Active : active, WorkgroupType : workgroupType, ServiceType : serviceType,
                          productModule: productModule,productVariant:productVariant,solution:solution,contractType:contractType});
        /* Chnages w.r.t 17116 ends */
        action.setCallback(this, function(response) {
            var state = response.getState();
            var rules = response.getReturnValue();
            if (state === "SUCCESS") {
                console.log(rules);
                
                console.log('size of records' + rules.length);
                component.set('v.workGroupRules', response.getReturnValue());
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },
    refresh : function(component,event) {
        $A.get('e.force:refreshView').fire();
    },
    newRecord: function(component, event) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            'entityApiName' : 'CH_Workgroup_Rule__c'
        });
        createRecordEvent.fire();
    },
	typeChanged: function(component,event,helper){
        var selectedType = component.find("mySelect").get("v.value");
        component.set("v.selectedValue", selectedType);
    },
})