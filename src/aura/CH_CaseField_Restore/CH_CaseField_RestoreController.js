({
    doInit : function(component, event, helper) {
        helper.distributecomment(component, event, helper);
        var recordId = component.get("v.recordId");
        var action = component.get("c.accessCheck");
        action.setParams({ caseId : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.edit",response.getReturnValue());
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
        if(component.get("v.runflow")){        
            
        component.set("v.outageStatusFinished",false);
        }
    },
    update : function(component,event,helper) {
        
        component.find("recordEditForm").submit();
        $A.get('e.force:refreshView').fire();
    },
    launchOutageStatusUpdate : function (component,event,helper) {
        
        component.set("v.outageStatusFinished",true);
        var flow = component.find("outageStatus");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
           
        ];
        flow.startFlow("CH_Status_Update_of_Critical_Service_Disruption_Not_Restored",inputVariables);
  		component.set("v.isButtonActive",true);
        component.set("v.runflow", true);
        
    },
    activeButton : function(component,event,helper){
        
        var inputText = component.find("incomment").get("v.value");
        if(inputText != null ){
            component.set("v.isButtonActive",false);
        } 
         if(inputText == null || inputText == '' || inputText == undefined  ){
            component.set("v.isButtonActive",true);
         }
    },
    handleOutageStatusChange : function (component,event,helper) {
        
        if(event.getParam("status") === "FINISHED") {
            component.set("v.outageStatusFinished",false);
            
        }
    }
})