({
    doInit : function(component, event, helper) {
        var action = component.get("c.validUser");
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
		action.setCallback(this, function(result) {
            console.log('-----------------');
            console.log('AO: '+(result.getReturnValue()?true:false));
            console.log('-----------------');
            component.set('v.validUser', result.getReturnValue()?true:false);
        });
        $A.enqueueAction(action);        
    },
	acceptOwnership : function(component, event, helper) {
        var action = component.get("c.assignSelfOwnership");
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
		action.setCallback(this, function(result) {
            if(result.getState() !== 'ERROR') location.reload();
        });
        $A.enqueueAction(action);
	}
})