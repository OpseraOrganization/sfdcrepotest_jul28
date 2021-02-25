({
   doInit: function(component, event, helper) {
       helper.myAction1(component);
       helper.myAction2(component);
       helper.myAction3(component);
       //helper.statusval(component);
       helper.generatesdrval(component);
       var recordId = component.get("v.recordId");
   },
   handleSuccess : function(component, event, helper) {
       try{
           var toastEvent = $A.get("e.force:showToast");
           toastEvent.setParams({
               "title": "Success!",
               "message": "The record has been updated successfully.",
               "type": "success"
           });
           toastEvent.fire();
            helper.myAction3(component);
       }catch(e){
           console.log('Error Occured------------------->'+e.getMessage());
       }
       var test = component.find('TCA').get("v.value");
       if(test==true)
       {
           let button = component.find('disablebuttonidwrite');
           button.set('v.disabled',false);
       }
       else
       {
           let button = component.find('disablebuttonidwrite');
           button.set('v.disabled',true);
       }
   },
    handleError : function(component, event, helper) {
       try{
           var toastEvent = $A.get("e.force:showToast");
           toastEvent.setParams({
               "title": "Error!",
               "message": "Please enter the Required Fields!:Issue Description/Technical Analysis/Case Cause",
               "type": "error"
           });
           toastEvent.fire();
       }catch(e){
           console.log('Error Occured------------------->'+e.getMessage());
       }
       
       
   },
    
   update : function(component,event,helper) {
       
        var errorFlag = false;
        component.set('v.showSpinner', true);
        if(component.find('CH_IssueDescription__c').get("v.value") ==null || component.find('CH_IssueDescription__c').get("v.value") ==''
          || component.find('CH_TechnicalAnalysis__c').get("v.value") ==null|| component.find('CH_TechnicalAnalysis__c').get("v.value") ==''
          || component.find('CH_CaseCause__c').get("v.value") =='--None--'|| component.find('CH_CaseCause__c').get("v.value") ==''
          )
        {
            $A.util.addClass(component.find('CH_IssueDescription__c'),'slds-has-error');
            errorFlag = true;
        }else{
            $A.util.removeClass(component.find('CH_IssueDescription__c'), 'slds-has-error');
        }
       
        if(!errorFlag){
            component.find("recordEditForm").submit();
            
           $A.get('e.force:refreshView').fire();
            
   
        }else{
             var errmsg = component.get('c.handleError');
            $A.enqueueAction(errmsg);
             component.set('v.showSpinner', false);
             //v.Spinner
             
        }
      /* try{
           component.find("recordEditForm").submit();
           $A.get('e.force:refreshView').fire();
       }catch(e){
           console.log('Error Occured------------------->'+e.getMessage());
       }*/
   },
   generateCar: function (component, event, helper) {
       var recordId = component.get("v.recordId");
       var url = '/apex/CH_GenerateCAR?id=' + recordId;
       var urlEvent = $A.get("e.force:navigateToURL");
       urlEvent.setParams({
           "url": url
       });
       urlEvent.fire();
   },
   associateUsages: function (component, event, helper) {
       var recordId = component.get("v.recordId");
       var url = '/apex/CH_GeneratePdf?id=' + recordId;
       var urlEvent = $A.get("e.force:navigateToURL");
       urlEvent.setParams({
           "url": url
       });
       urlEvent.fire();
   },
   finalSolution : function (component,event,helper) {
       //Change for NOKIASC-17514-Start
        /*component.set("v.issueResolvedFinished",true);
        var flow = component.find("issueResolved");
        var inputVariables = [
            { name : "recordId", type : "String", value: component.get("v.recordId") }
        ];
        flow.startFlow("CH_ResolveCase",inputVariables);*/
    var recordId = component.get("v.recordId");
    var action = component.get("c.checkODRValidationQuery");
    action.setParams({ caseId: recordId });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        if (storeResponse) {
          try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Failure!",
              message: "You cannot close this support ticket with outage reported or assessed if following no all End dates in the Outage Duration Records (ODR) are populated.",
              type: "error"
            });
            toastEvent.fire();
          } catch (e) {
            console.log("Error Occured------------------->" + e.getMessage());
          }
        } else {
          component.set("v.issueResolvedFinished", true);
          var flow = component.find("issueResolved");
          var inputVariables = [
            {
              name: "recordId",
              type: "String",
              value: component.get("v.recordId")
            }
          ];
          flow.startFlow("CH_ResolveCase", inputVariables);
        }
        //Change for NOKIASC-17514-End
      }
    });
    $A.enqueueAction(action);
   },
   handleIssueResolvedFinishedChange : function (component,event,helper) {
       if(event.getParam("status") === "FINISHED") {
           component.set("v.Spinner", true);
           component.set("v.issueResolvedFinished",false);
           $A.get('e.force:refreshView').fire();
           window.setTimeout(function(){component.set("v.Spinner", false)}, 4000);
       }
   }
})