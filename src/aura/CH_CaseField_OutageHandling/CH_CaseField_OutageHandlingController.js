({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.accessCheck");
        action.setParams({ caseId : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.edit",response.getReturnValue());
                var action = component.get("c.fetchODRrecords");
                action.setParams({ caseId : recordId });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.isODRexist",response.getReturnValue());
            }
        });
         $A.enqueueAction(action);
            }
        });
         $A.enqueueAction(action);
    },
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully.",
            "type": "success"
        });
        toastEvent.fire();
    },
    update : function(component,event,helper) {
        component.find("recordEditForm").submit();
        $A.get('e.force:refreshView').fire();
    },
    launchDeleteODR : function (component,event,helper) {
        component.set("v.deleteODR",true)
        var flow = component.find("ODRDeletion");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        flow.startFlow("CH_Delte_ODR",inputVariables);
    },
    launchCreateODR : function (component,event,helper) {
        component.set("v.createODR",true);
        var flow = component.find("ODRCreation");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        flow.startFlow("CH_Create_ODR",inputVariables);
    },
    launchCheckODR : function (component,event,helper) {
            component.set("v.checkODR",true);
        var flow = component.find("ODRCheck");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        flow.startFlow("CH_CheckODRCoverage",inputVariables);
    },
    handleCreateODR : function (component,event,helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.createODR",false);
              var recordId = component.get("v.recordId");
        var action = component.get("c.accessCheck");
        action.setParams({ caseId : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.edit",response.getReturnValue());
                var action = component.get("c.fetchODRrecords");
                action.setParams({ caseId : recordId });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.isODRexist",response.getReturnValue());
                        $A.get('e.force:refreshView').fire();
            }
        });
         $A.enqueueAction(action);
            }
        });
         $A.enqueueAction(action);
        }
    },
    
    handleDeleteODR : function (component,event,helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.deleteODR",false);
        }
    },
    
    sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');
    },
    handleCheckODR : function (component,event,helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.checkODR",false);
        }
    }
})