({
    submitHWSCase : function(component,event,helper) {
        var actionCallout = component.get("c.makeSOOCallout");
        var caseId=component.get("v.recordId");   
        var actionCallout=component.get('c.makeSOOCallout');
        actionCallout.setParams({
            parentCaseId : caseId});
        actionCallout.setCallback(this, $A.getCallback(function (response) {
          var state = response.getState();
          component.set("v.ProcessResponse", response.getReturnValue());
          var processResponse=component.get("v.ProcessResponse");
            if (state === "SUCCESS") {
                if(processResponse!=null){
                    var statuscode=processResponse.statusCode;
                    var Status=processResponse.Status;
                    if(statuscode==200 && Status!='Fail'){
                        this.showToast('success','Success Message','Your request is successfully submitted');
                    }
                    else
                    {
                        if(statuscode==200 && Status=='Fail'){
                        	this.showToast('error','Error Message','Cancelled Cases connot be submitted');    
                        }else{
                        	this.showToast('error','Error Message','Your request is Created but not submitted');    
                        }
                        
                    }
                }
                else{
                    this.showToast('error','Error Message','Your request is Created but not submitted');
                }
                $A.get('e.force:refreshView').fire();
                
                
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        }));
        $A.enqueueAction(actionCallout);
        
    },
    getCaseStatus : function(component, event, helper) {        
        var id = component.get("v.recordId");                
        var action =component.get("c.getCasStatus");
        action.setParams({
            caseid: id
        });                
        action.setCallback(this, function(response) {                       
            var caseCaStatus = response.getReturnValue();
            component.set("v.CasStatus",caseCaStatus);            
        });
        $A.enqueueAction(action);
    },
    
    
    //Helper method to display the error toast message
    showToast : function(type,title,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:'5000',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
        
    },
	
	//This is used for checking Customer Purchaser Order Number 
	 checkPayPerUse : function(component,event,helper) {
        var getCaseId=component.get("v.recordId"); 
        var action=component.get('c.getPayPerUse');
        action.setParams({
            parentCaseId : getCaseId});
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()===true){
                    this.showToast('error','Error Message','Please Fill Customer Purchase Order Number');
                }
                else{
                    this.submitHWSCase(component,event,helper);
                }
            }
        }));
        $A.enqueueAction(action);     
    }
	
    
})