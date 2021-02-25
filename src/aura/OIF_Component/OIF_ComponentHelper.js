({
	 GridLock: function(component, event) {
   
         
        var action = component.get("c.getPositionRecords");
        
        var pageid=component.get("v.recordId");
        action.setParams({
            oppid:pageid 
        });
         
          
        //Setting the Callback
            action.setCallback(this,function(a){
                //get the response state
                var state = a.getState();
                
                //check if result is successfull
                if(state == "SUCCESS"){
                    var result = a.getReturnValue();
                   
                    component.set("v.LockRec",result.Grid_Buddy_Closed__c);
                      
                    

                    }  
                 else if(state == "ERROR"){
                    alert('Please refresh the Browser');
                }
            });
            
            //adds the server-side action to the queue        
            $A.enqueueAction(action);
     }
    
   
     
})