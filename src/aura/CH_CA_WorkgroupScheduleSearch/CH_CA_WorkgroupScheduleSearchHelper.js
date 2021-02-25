({
    fetchPickListVal: function(component, fieldName, elementId) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.find(elementId).set("v.options", opts);
            }
        });
        $A.enqueueAction(action);
    },
    getStartDate: function(component, event, helper) { 
        var action = component.get("c.getStartDate");
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var dateVal = response.getReturnValue();
                component.set('v.startDate',dateVal);
            }
        });
        $A.enqueueAction(action);
    },
    getEndDate: function(component, event, helper) { 
        var action = component.get("c.getEndDate");
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var dateVal = response.getReturnValue();
                component.set('v.endDate',dateVal);
            }
        });
        $A.enqueueAction(action);
    },
    Search: function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.searchSchedules");
        var startDate= component.find("startDate").get("v.value");
        var endDate= component.find("endDate").get("v.value");
        var active = component.find("activeBox").get("v.value");
        var workgroupType= component.find("wgTypeId").get("v.value");
        var customer = component.find("accLookup").get("v.value");
        var Region= component.find("regionId").get("v.value");
        var Country= component.find("countryId").get("v.value");
        var Severity= component.find("severity").get("v.value");
        var product = component.find("productLookup").get("v.value");
        var Outage = component.find("outageBox").get("v.value");
        var levelOfSupport = component.find("levelOfSupport").get("v.value");
        var workgroupId = component.get("v.recordId");
		var Solution = component.find("solutionLookup").get("v.value");
        var productModule = component.find("productmoduleLookup").get("v.value");
        var productVariant = component.find("productvariantLookup").get("v.value");
         
        action.setParams({startDate: startDate,
                          endDate: endDate,
                          Active : active,
                          WorkgroupType : workgroupType,
                          Customer : customer, 
                          Region : Region, 
                          Country : Country, 
                          Severity : Severity,
                          Product : product,  
                          Outage : Outage,
                          LevelOfSupport : levelOfSupport,
                          workgroupId : workgroupId,
						  Solution : Solution,
                          ProductModule : productModule,
                          ProductVariant : productVariant});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('in callback');
            var schedules = response.getReturnValue();
            if (state === "SUCCESS") {
                console.log(schedules);
                console.log('size of records' + schedules.length);
                // Sort the result by weight and 
                schedules.sort(function(a,b) {
                    return -1*(a.weight - b.weight) || ('' + a.wGSchedule.Name).localeCompare(b.wGSchedule.Name);
        		});               
                component.set('v.workGroupSchedules', schedules);
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },
    deleteRecord: function(component, event,helper){
        var rectarget = event.currentTarget;
        var idstr = event.target.getAttribute("data-recId");       
        var WorkgroupSchedule = component.get("v.workGroupSchedules");       
        var items = [];
        var i=0;
        for (i = 0; i < WorkgroupSchedule.length; i++) {
            if(WorkgroupSchedule[i].Id!==idstr) {
                items.push(WorkgroupSchedule[i]);  
            }
        }
        component.set("v.workGroupSchedules",items);
        var action = component.get("c.deleteSchedule");
        action.setParams({idstr : idstr,ListWGS : WorkgroupSchedule});
        action.setCallback(this, function(response) {
        });
        $A.enqueueAction(action);
        helper.showToastDelete(component,event,helper);
    },
    showToastDelete : function(component,event,helper){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: 'The record has been Deleted successfully',
            type : 'success'
        });
        toastEvent.fire();
    },
    editRecord: function(component,event,helper) {
        var rectarget = event.currentTarget;
        var idstr = event.target.getAttribute("data-recId"); 
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": idstr
        });
        editRecordEvent.fire();
    },
})