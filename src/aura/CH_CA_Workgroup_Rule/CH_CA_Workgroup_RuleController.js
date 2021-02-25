({
    // When a save is complete display a message
    saveCompleted: function(component,event,helper){
        helper.closeConsoleTAB(component);
        // Display the status of the save                        
        var messageBox = component.find('messageBox'); 
        messageBox.displayToastMessage('Workgroup Rule is saved');
    },
    // When cancel is pressed
    cancel: function(component,event,helper){
        helper.closeConsoleTAB(component);
    },
    
    // Change contract type with the  Service Type selected value
    serviceTypeChanged: function(component,event,helper){
        var selectedValue = component.find("serviceType").get("v.value");       
        if (selectedValue=="Internal Support"){           	
        	component.set("v.disabledContracType", false);  
        }
        else {        	
        	component.set("v.disabledContracType", true); 
        	component.set("v.selectedValue","");
        }
    },
    
    // Fix to load the contract type with the selected value
    typeChanged: function(component,event,helper){
        var selectedType = component.find("mySelect").get("v.value");
        component.set("v.selectedValue", selectedType);
    },
    // As the contract type is a seperate picklist, save the value on the object
    saveContractTypeField: function(component,event,helper){
        event.preventDefault();
        var fields = event.getParam("fields");
        fields["CH_Contract_Type__c"] = component.get("v.selectedValue");
		var byPassNoneValue=fields["CH_Contract_Type__c"];
        if(byPassNoneValue=='--None--'){
            fields["CH_Contract_Type__c"] = '';
        }
        component.find("workgroupRuleForm").submit(fields);
    },
    // When the rule is retrieved, get all contract types
    loadedRule : function(component, event, helper) {
        var action = component.get("c.getCdbRecords");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.options", response.getReturnValue());
                component.set("v.refresh", true);
                var setVal=component.find("contractType").get("v.value");
                component.set("v.selectedValue",setVal);                
                var serviceTypeChanged = component.get('c.serviceTypeChanged');
                $A.enqueueAction(serviceTypeChanged);
            }
        });
        $A.enqueueAction(action);
    },
})