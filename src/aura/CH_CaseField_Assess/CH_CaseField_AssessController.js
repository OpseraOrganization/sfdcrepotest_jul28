({
    doInit : function(component, event, helper) {
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
        component.set("v.reloadForm", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully.",
            "type": "success"
        });
        toastEvent.fire();
        
        component.set("v.reloadForm", true);
    },
    update : function(component,event,helper) {
        /*** Modified below code NOKIASC-18141  Added Check condition before Submit*/
         var outageValue = component.find("oType").get("v.value");
        var outageType = component.find("oValue").get("v.value");
        var initalDiag = component.find("initialdiagnosis").get("v.value");
        if((outageValue == "Yes" && outageType =='') || (initalDiag == null || initalDiag =='')){
            if(outageValue == "Yes" && outageType ==''){
            	$A.util.addClass(component.find('oValue'),'slds-has-error');
                document.getElementById("validaterequiredfields").innerHTML = '*All required fields must be completed.';
            }
            if(initalDiag == null || initalDiag ==''){
            	$A.util.addClass(component.find('initialdiagnosis'),'redOutLine');
                document.getElementById("validaterequiredfields").innerHTML = '*All required fields must be completed.';
            }
        }else{
            document.getElementById("validaterequiredfields").innerHTML = '';
            $A.util.removeClass(component.find('oValue'),'slds-has-error');
            $A.util.removeClass(component.find('initialdiagnosis'),'redOutLine');
            component.find("recordEditForm").submit();
		
        }
  
    },
    
    /***  NOKIASC-18141 */
    onchangeOutage : function(component,event,helper) {
       var outageValue = component.find("oType").get("v.value");
        if(outageValue == "Yes"){
            component.set("v.outageflag",false);
        }else{
            component.set("v.outageflag",true);    
        }
    },
     /***  NOKIASC-18141 */
    onEditLoad : function(component,event,helper) {
       var outageValue = component.get("v.currentCaseRecord.CH_Outage__c");
        if(outageValue == "Yes"){
            component.set("v.outageflag",false);
        }else{
            component.set("v.outageflag",true);    
        }
    },
   
})