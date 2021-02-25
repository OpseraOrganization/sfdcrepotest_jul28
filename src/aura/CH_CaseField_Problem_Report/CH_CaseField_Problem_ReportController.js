({
    doInit : function(component, event, helper) {
        //component.set("v.Spinner", false);
        var recordId = component.get("v.recordId");
        var action = component.get("c.accessCheck");
        action.setParams({ caseId : recordId });
        action.setCallback(this, function(response) {
            $A.util.toggleClass(component.find('spinner'),'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.edit",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        helper.createArticleButton(component);
        
        
    },
        handleOnLoad : function(component, event, helper) {        
               
        $A.get('e.force:refreshView').fire();
       
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
       /* $A.get('e.force:refreshView').fire();*/
    },
    launchOutageStatusUpdate : function (component,event,helper) {
        component.set("v.flowFinished",true);
        var flow = component.find("flowData");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        flow.startFlow("CH_Update_RCA_Provided",inputVariables);
        let button = component.find('disablebuttonid');
        button.set('v.disabled',true);
    },
    cancelProblem : function (component,event,helper) {
        
        component.set("v.createProblemFinished",true);
        component.set("v.closeProblem", false);
        var flow = component.find("createProblemFinished");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        flow.startFlow("CH_CancelProblemAndNotifyIncidents",inputVariables);
    },
    createKnownError : function (component,event,helper) {
		component.set("v.disableButtonCreateArt",true);
        component.set("v.createKnownErrorFinished",true);
        component.set("v.closeProblem", false);
        var flow = component.find("createKnownError");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        flow.startFlow("Create_Article_from_Case",inputVariables);
		$A.get('e.force:refreshView').fire();
    },
    handleCreateKnownErrorChange : function (component,event,helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.createKnownErrorFinished",false);
        }
    },        
    handleStatusChange : function (component,event,helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.flowFinished",false);
            let button = component.find('disablebuttonid');
            button.set('v.disabled',false);
			$A.get('e.force:refreshView').fire();
        }
    },
    handleCreateProblemFinished : function (component,event,helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.createProblemFinished",false);
        }
    },
    handleShowActiveSectionName: function (component, event, helper) {
        alert(component.find("accordion").get('v.activeSectionName'));
    },
    handleSetActiveSectionA: function (component) {
        if(component.find("accordion").get('v.activeSectionName') !='B'){
            component.find("accordion").set('v.activeSectionName', 'B');
        }else{
            component.find("accordion").set('v.activeSectionName', 'A');
        }
    },
    handleSetActiveSection: function (component) {
        alert(component.get('v.openSection') );
        if(component.get("v.openSection") =='A'){
            component.set("v.openSection","B");
            component.find("accordion").set('v.activeSectionName', 'B');
        }else{
            component.set("v.openSection","A");
            component.find("accordion").set('v.activeSectionName', 'A');
        }
        
    },
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');
    },
    closeProblem : function( cmp, event, helper ) {
        var actionAPI = cmp.find("quickActionAPI");
        alert(cmp.get("v.recordId"));
        var fields = {CH_Closure_Reason__c: {value:"Solution Provided" }
                     };
        var args = {actionName: "Case.CH_Close_Problem_COE"};
        actionAPI.selectAction(args).then(function(){
            alert("test");
            
            //    actionAPI.invokeAction(args);
        }).catch(function(e){
            alert("test"+e.errors);
            console.log('Er'+actionAPI.getAvailableActions());
            console.error(e.errors);
        });
    },
    resetProblem: function (component, event) {
        $A.get('e.force:refreshView').fire();
    },
    refreshPage: function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        
        
/*
 * https://jiradc2.int.net.nokia.com/browse/NOKIASC-24360
 As per this defect business doesn't want the page to be refreshed while editing any 
 record in detail page.  Hence, commenting the  location.reload();  
 */
    },
    
    refreshFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            alert(focusedTabId);
            workspaceAPI.refreshTab({
                tabId: focusedTabId,
                includeAllSubtabs: true
            });
        })
        .catch(function(error) {
            alert('error'+error);
            console.log(error);
        });
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
    },
    // When button clicked display the workgroup instructions
    handleWorkgroupInstructions : function(component,event,helper){
        component.set("v.Spinner", true); 
        var recordId = component.get("v.recordId");
        var assignFunction = component.get("c.displayWorkgroupInstructions");
        assignFunction.setParams({
            fieldId : recordId
        });
        assignFunction.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.Spinner", false);
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            }
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'An Error Occured',
                    message: errorMessage,
                    type : 'Error',
                    mode: 'sticky'
                });
                toastEvent.fire();                
            }
        });
        $A.enqueueAction(assignFunction);
    }
    
})