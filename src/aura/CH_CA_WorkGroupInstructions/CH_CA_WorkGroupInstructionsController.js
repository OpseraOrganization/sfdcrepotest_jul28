({
    
    onInit : function(component,event,helper){
        var recordId = component.get("v.recordId");        
        var action = component.get("c.accessCheckWGInstructions");
        action.setParams({ accessCheck : recordId });
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.booleanEdit",response.getReturnValue());
            }
            else {
                var errors = response.getError();   
                var messageBox = component.find('messageBox'); 
                messageBox.displayToastMessage('error', errors && errors[0] && errors[0].message?errors[0].message:"Something went wrong",'Error');
            }
        });
        $A.enqueueAction(action);               
    },
    
    // Change severityType with the assignmentType selected value
    assignmentTypeChanged: function(component,event,helper){
        var selectedValue = component.find("assignmentType").get("v.value");  
        if (selectedValue == "Active"){    
            component.set("v.disabledSeverityType", true);  
        }
        else {   
            component.set("v.disabledSeverityType", false); 
        }
    },
    // When a save is complete display a message
    saveCompleted: function(component,event,helper){
        
        helper.closeConsoleTAB(component);
        // Display the status of the save                        
        var messageBox = component.find('messageBox'); 
        messageBox.displayToastMessage('Workgroup Instruction is saved');
    },
    // When cancel is pressed
    cancel: function(component,event,helper){
        helper.closeConsoleTAB(component);
    },
    // When the values are retrieved, get all assignmentType
    loadedInstructions : function(component, event, helper) {
        // Set the AssignmentType fields
        var recUi = event.getParam("recordUi");
        var selectedValue = recUi.record.fields["CH_AssignmentType__c"].value;
        if (selectedValue == "Active"){    
            component.set("v.disabledSeverityType", true);  
        }
    },
    
    saveFields: function(component,event,helper){
        event.preventDefault();
        var fields = event.getParam("fields");
        var byPassNoneValue=fields["CH_AssignmentType__c"];
        if(byPassNoneValue=='Passive'||byPassNoneValue==='Case Team'){
            fields["CH_Severity__c"] = '';
        }
        component.find("workgroupInstructionForm").submit(fields);
    },
    
})