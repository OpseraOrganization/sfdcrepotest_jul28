/*
    Last Modified By : Rajeshwari Aug 13 2019 - NOKIASC-18141
    Last Modified By : Rajeshwari Sept 6  2019 - NOKIASC-23087
    */
({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.accessCheck");
        action.setParams({ caseId : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.edit",response.getReturnValue());
                if(response.getReturnValue()){
                    component.set("v.transferRndShowButton",false); 
                }else{
                    component.set("v.transferRndShowButton",true); 
                }
            }
        });
        $A.enqueueAction(action);
        
        var actionTransferRndShowButton = component.get("c.transferRndAccessCheck");
        actionTransferRndShowButton.setParams({ caseId : recordId });
        actionTransferRndShowButton.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()!=null && (response.getReturnValue() == 'JIRA' || response.getReturnValue() =='PRONTO') ){
                    component.set("v.transferRndShowButton", false);
                }else{
                   component.set("v.transferRndShowButton", true);
                }
               component.set("v.interfaceType",response.getReturnValue());
            }
        });
        $A.enqueueAction(actionTransferRndShowButton);
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
        //$A.get('e.force:refreshView').fire();
    },
    shareTemporarySolution : function (component,event,helper) {
        component.set("v.shareTemporarySolutionFinished",true);
        var flow = component.find("shareTemporarySolution");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        flow.startFlow("CH_ProvideTemporarySolution",inputVariables);
    },
    shareSolution : function (component,event,helper) {
        component.set("v.shareSolutionFinished",true);
        var flow = component.find("shareSolution");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        flow.startFlow("CH_PopulateSolutionFromProblem",inputVariables);
    },
    withdrawTemporarySolution : function (component,event,helper) {
        component.set("v.withdrawTemporarySolutionFinished",true);
        var flow = component.find("withdrawTemporarySolution");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        flow.startFlow("CH_WithdrawTemporarySolution",inputVariables);
    },
    /*transferToRnd : function (component,event,helper) {
        var recordId = component.get("v.recordId");
        $A.createComponent(
            "c:CH_TransferRndFlow",
            {
                
                "problemId": component.get("v.recordId"),
                "headerMessage": "Transfer to R&D",
                "caseRecord": component.get("v.caseRecord")
            },
            function(msgBox){                
                if (component.isValid()) {
                    var cmp = component.find('transferRndModal');
                    var body = cmp.get("v.body");
                    body.push(msgBox);
                    cmp.set("v.body", body); 
                }
            }
        );
        
    },*/
    transferToRnd : function (component,event,helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.transferRndRequiredFieldsCheck");
        action.setParams({ caseId : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()) {
                    $A.createComponent(
                        "c:CH_TransferRndFlow",
                        {
                            
                            "problemId": component.get("v.recordId"),
                            "headerMessage": "Transfer to R&D",
                            "caseRecord": component.get("v.caseRecord")
                        },
                        function(msgBox){                
                            if (component.isValid()) {
                                var cmp = component.find('transferRndModal');
                                var body = cmp.get("v.body");
                                body.push(msgBox);
                                cmp.set("v.body", body); 
                            }
                        }
                    );
                } else {
                    $A.createComponent(
                        "c:CH_TransferRndInteraction",
                        {
                            "showValidationError": "true",
                            "headerMessage": "Transfer to R&D"
                        },
                        function(msgBox){     
                            if (component.isValid()) {
                                var cmp = component.find('transferRndModal');
                                var body = cmp.get("v.body");
                                body.push(msgBox);
                                cmp.set("v.body", body); 
                            }
                        }
                    );
                }
            }
        });
        $A.enqueueAction(action);
    },
    closeTransferToRnd : function (component,event,helper) {
        $A.util.removeClass(component.find("transferRndModal"), "slds-fade-in-open");
        $A.util.removeClass(component.find("transferRndModalBack"), "slds-fade-in-open");
    },
    createKnownError : function (component,event,helper) {
        component.set("v.createKnownErrorFinished",true);
        var flow = component.find("createKnownError");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        flow.startFlow("Create_Article_from_Case",inputVariables);
    },
    cancelProblem : function (component,event,helper) {
        component.set("v.createProblemFinished",true);
        var flow = component.find("createProblemFinished");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        flow.startFlow("CH_CancelProblemAndNotifyIncidents",inputVariables);
    },
    handleShareTemporarySolutionChange : function (component,event,helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.shareTemporarySolutionFinished",false);
        }
    },
    handleShareSolutionChange : function (component,event,helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.shareSolutionFinished",false);
        }
    },
    handleWithdrawTemporarySolutionChange : function (component,event,helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.withdrawTemporarySolutionFinished",false);
        }
    },
    handleCreateProblemFinished : function (component,event,helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.createProblemFinished",false);
        }
    },
    handleCreateKnownErrorChange : function (component,event,helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.createKnownErrorFinished",false);
        }
    },
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');
    },
    openTab: function(component, event, helper) {
        component.set("v.closeProblem", true);
    },
    saveCloseProblem: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var cReason = component.find("cReason").get("v.value");
        if(cReason !=null && cReason !=''){
            $A.util.removeClass(component.find('cReason'),'slds-has-error');
            var action = component.get("c.closeProblemRecord");
            action.setParams({ recordId : recordId,
                              closureReason:cReason  });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.closeProblem",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been closed successfully.",
                        "type": "success"
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    
                }
            });
            $A.enqueueAction(action);
        }
        else{
            $A.util.addClass(component.find('cReason'),'slds-has-error');
        }
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }
})