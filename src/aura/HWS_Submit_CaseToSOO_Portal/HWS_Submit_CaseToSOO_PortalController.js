({
  
    submitHWSCase : function(component, event, helper) {
       // helper.submitHWSCase(component,event,helper); 
	   helper.checkPayPerUse(component,event,helper);
       
    },
     myAction: function(component, event, helper) {
         // helper.getFailureDescriptionPickListValues(component, event);
        
         helper.getCaseStatus(component, event);
         helper.getInternalStatus(component, event, helper);
		   helper.getWorkgroup(component, event, helper);
    },
   
})