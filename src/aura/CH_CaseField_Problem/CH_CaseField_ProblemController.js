({
	
    doInit: function(component,event,helper) {
      	
        helper.myAction(component,event,helper);
      	helper.doInit(component,event,helper);
      	  
    },
    
    createProblem : function (component,event,helper) {
    	
    	helper.createProblem(component,event,helper);
       
    },
    
    disassociateProblem : function (component,event,helper) {
    	
    	helper.disassociateProblem(component,event,helper);
        
    },
    
    postToProblem : function (component,event,helper) { 
    	
    	helper.postToProblem(component,event,helper);
    	
    },
    
    handleSaveSuccess : function(component, event, helper) {
        console.log('#handleSaveSuccess');
        component.set("v.toggleSpinner", false);
        helper.showToastMessage('Success', "The record has been updated successfully.");
        
        
    	
    	if(component.find('CH_Problem__c').get('v.value')){
    		component.set("v.incidentHasProblem", true);
    	}else{
    		component.set("v.incidentHasProblem", false);
    		component.set("v.theProblem.Subject", "");
    	}
    	component.set("v.toggleSpinner", false);
        
    },
    
    update : function(component,event,helper) {
    	console.log('#update');
    	component.set("v.toggleSpinner", true);
        component.find("recordEditForm").submit();
    },
    
    handleLoad: function(component,event,helper){
    	console.log('handleLoad');
    	component.set("v.toggleSpinner", false);
    	/*
    	console.log('#handleLoad>' + component.find('CH_Problem__c').get('v.value'));
    	
    	if(component.find('CH_Problem__c').get('v.value')){
    		component.set("v.incidentHasProblem", true);
    	}else{
    		component.set("v.incidentHasProblem", false);
    		component.set("v.theProblem.Subject", "");
    	}
    	component.set("v.toggleSpinner", false);
		*/
    	
    },
    
    handleSaveError: function(component,event,helper){
    	
    	console.log('An error ...');
    	component.set("v.toggleSpinner", false);    	
    
    },
    
    updateEntitlement : function (component, event, helper){
        var action = component.get('c.enableReEntitlement');
        action.setParams({ "caseRecordId" : component.get("v.recordId") });
        action.setCallback(this,function(response){
            if (response.getState() === "SUCCESS") {
                if (response.getReturnValue() == '') {
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:CH_ReEntitlement",
                        componentAttributes:{
                            caseId : component.get("v.recordId")
                        }            
                    });
                    evt.fire();
                } else {
                    helper.showToastMessage('Error',response.getReturnValue()); 
                }                              
            }
        });
        $A.enqueueAction(action);
    },
    
    openProductPulldown : function(component, event, helper) {
        var action = component.get('c.hasCaseEditAcess');
        action.setParams({ "caseRecordId" : component.get("v.recordId"), fields : [
            'ProductId', 'CH_Product_Release__c', 'CH_Product_Module__c', 'CH_ProductVariant__c', 
            'CH_Solution__c', 'CH_SW_Component__c', 'CH_SW_Release__c', 'CH_SW_Module__c',
            'CH_SW_Build__c', 'CH_HW_Component__c'
        ]});
        action.setCallback(this,function(response){
            if (response.getState() === "SUCCESS") {
                let result = response.getReturnValue();
                if(result === '' || result === 'Entitlement related details cannot be modified once Restore, Temporary Solution or Solution Provided events have been completed.') {
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:CH_ProductPulldown",
                        componentAttributes:{
                            id : component.get("v.recordId"),
                            object : 'Case',
                            type : 'CompleteMinimalLocked'
                        }            
                    });
                    evt.fire();
                }
                else {
                    helper.showToastMessage('Error',result); 
                }
            }
        });
        $A.enqueueAction(action);
	},
})