({
	action : function(component, action, params, callback) {
        this.incrementActionCounter(component);
        var action = component.get(action);
        action.setParams(params);
        action.setCallback(this, function(response) {
            var state = response.getState();
            this.decrementActionCounter(component);
            if (state === "SUCCESS"){
                callback(response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors && errors[0] && errors[0].message?("Error message: " + errors[0].message):"Unknown error");
                this.showToast('Error', 'Internal Error', errors && errors[0] && errors[0].message?errors[0].message:"Unknown error");
            }
        });
        $A.enqueueAction(action);
	},
    incrementActionCounter : function(component) {        
        var counter = component.get("v.actionCounter") + 1;
        if(counter === 1) {
            component.set("v.showSpinner", true);
        }
        component.set("v.actionCounter", counter);        
    },
    decrementActionCounter : function(component) {
        var counter = component.get("v.actionCounter") - 1;
        if(counter === 0) {
            component.set("v.showSpinner", false);
        }
        component.set("v.actionCounter", counter);    
    },
    showToast: function(sType, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": sType
        });
        toastEvent.fire();
    }
})