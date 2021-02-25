({
	navigateToComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:CH_CreateNEA",
            componentAttributes: {
                recordId : component.get("v.recordId"),
                tabMode : true
            }
        });
        evt.fire();
    }
})