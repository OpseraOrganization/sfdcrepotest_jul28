({
	//Spinner Code Start
    showWaiting:function(cmp){
       cmp.set("v.IsSpinner",true);
    },
    hideWaiting:function(cmp){
        cmp.set("v.IsSpinner",false);  
    },
    //Spinner Code Ends
    cancelHwsCase : function(component, event, helper) {
		helper.cancelHwsCaseHelper(component,event);
	}
})