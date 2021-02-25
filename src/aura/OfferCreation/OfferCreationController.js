({
    doInit : function(component, event, helper) {
        // Prepare the action to load Opportunity record
        var action = component.get("c.getOppty");
        action.setParams({"opptyId": component.get("v.opptyId")});
        var G4PlannedDate,G3PlannedDate,G5PlannedDate; 
       
        var expextedLoALevel = component.get("c.getAllExpectedLoALevel");
        //console.log('Checking Expected Loa levels......');  
        expextedLoALevel.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var loaLevels = [];
                var expextedLoALevels = [];
                loaLevels = response.getReturnValue();
                
                expextedLoALevels.push({value:'--None--', key:'--None--'});
                for (var key in loaLevels ) {
                    expextedLoALevels.push({value:loaLevels[key], key:key});
                }
                component.set("v.loaLevels", expextedLoALevels);
                      
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(expextedLoALevel); 
        
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var oppty = response.getReturnValue();
                console.log('Oppty data: ' + JSON.stringify(response.getReturnValue()));
                component.set("v.currentOppty", response.getReturnValue());
                component.set("v.G4PlannedDate",oppty.G4_Planned_Date__c);
                component.set("v.G3PlannedDate",oppty.G3_Planned_Date__c);
                component.set("v.G5PlannedDate",oppty.G5_Planned_Date__c);
                component.set("v.G4PlannedDateOLD",oppty.G4_Planned_Date__c);
                var expectedLoALevel = oppty.Expected_LoA_Approval_Level__c;
                component.find("Expected_loA_Level").set("v.value", expectedLoALevel);
                var loaLevels = component.get("v.loaLevels");
                var loaLevelsSelected = [];  
                Object.keys(loaLevels).forEach(key => {
                    if(loaLevels[key]["key"] === expectedLoALevel){
                        var values = loaLevels[key];
                        values.selected = true;
                        loaLevelsSelected.push(values);
                    } else {
                    	loaLevelsSelected.push(loaLevels[key]);
                    }
            	});
            	component.set("v.loaLevels", loaLevelsSelected);
                if(oppty.Account.Customer_Compliance__c == 'US_Govern')
                {
                    component.set("v.NSACompliance",true);
                }
                
            } else {
                console.log('Problem getting oppty data ' + state);
            }
        });
        $A.enqueueAction(action);        
        
                
    },
    
    handleNext: function(component, event, helper) {
        
        var btn = event.getSource();
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        
        if (dd < 10) {
            dd = '0' + dd;
        }
        
        if (mm < 10) {
            mm = '0' + mm;
        }
        
        today = yyyy + '-' + mm + '-' + dd;
        helper.validateRequiredFields( component );
        
        
        console.log(component.get("v.has_error"));
        if(component.get("v.has_error") == true ){
            document.getElementById('scrollable_div').scrollTop = 0;
            return;
        }
        
        if((component.get("v.G4PlannedDate") < component.get("v.G3PlannedDate")) || (component.get("v.G4PlannedDate") > component.get("v.G5PlannedDate")) || component.get("v.G4PlannedDate") < today)
        {
            component.set("v.has_error", true);
            component.set("v.errors", 'Error : The Gate Planned Date entered is either blank, in the past, precedes the date entered for the previous gate or exceeds the date entered for the following gate');
            return;
        }else
            component.set("v.has_error", false);
        
        component.set("v.newOffer.Opportunity__c",component.get("v.currentOppty.Id"));
        component.set("v.newOffer.Expected_LoA_G4_Approval_Level__c", component.find("Expected_loA_Level").get("v.value"));
        var actionOpptyTeam = component.get("c.getOpptyTeam");
        actionOpptyTeam.setParams({"opptyId": component.get("v.opptyId")});            
        // Configure response handler
        actionOpptyTeam.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log('Oppty Team Data: ' + JSON.stringify(response.getReturnValue()));
                component.set("v.wrapper",response.getReturnValue());
                component.set("v.offerCreationFlag", false);
                component.set("v.offerTeamCreationFlag", true);
                console.log('length'+response.getReturnValue().length);
                var oppTeam = component.get("v.wrapper");
                if(oppTeam != undefined && oppTeam != null && oppTeam != ''){
                    var lengthOfTeam = component.get("v.wrapper").length;
                    console.log('lengthOfTeam'+lengthOfTeam);
                    if(lengthOfTeam < 8)
                    {
                        for(var i = 0 ; i< (8-lengthOfTeam) ; i++){
                            helper.createObjectData(component, event);
                        }
                    }
                }else
                {
                    for(var i = 0 ; i< 8 ; i++){
                        helper.createObjectData(component, event);
                    }
                }  
                
                var MSG = $A.get("$Label.c.Offer_Team_creation_warning_message");
                component.set("v.mylabel", MSG);
                var resultsToastWarning = $A.get("e.force:showToast");
                resultsToastWarning.setParams({
                    'message': MSG,
                    'type' : 'warning',
                    'duration' : 10000                     
                });
                //$A.get("e.force:closeQuickAction").fire();
                resultsToastWarning.fire();
            } else {
                console.log('Problem getting oppty Team ' + state);
            }
        });
        $A.enqueueAction(actionOpptyTeam);
    },
    
    
    handleCancel: function(component, event, helper) {
        component.set("v.offerCreationFlag", false);
        component.set("v.newOffer",{'sobjectType':'Offer__c',
                                    'Name':'',
                                    'Customer_Offer_Due_Date__c':'',
                                    'Opportunity':'',
                                    'Expected_loA_Level':''
                                   });
        component.set("v.wrapper", null );
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/' + component.get("v.opptyId")
        });
        urlEvent.fire();
        component.destroy();
    },
    
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.offerCreationFlag", true);
    },
    
    closeOfferCreation: function(component, event, helper) {
        component.set("v.offerCreationFlag", false);
        component.set("v.newOffer",{'sobjectType':'Offer__c',
                                    'Name':'',
                                    'Customer_Offer_Due_Date__c':'',
                                    'Opportunity':'',
                                    'Expected_loA_Level':''
                                   });
        component.set("v.wrapper", null );
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/' + component.get("v.opptyId")
        });
        urlEvent.fire();
        component.destroy();
        //$A.get('e.force:refreshView').fire();
    },
    closeOfferTeamCreation: function(component, event, helper) {
        component.set("v.offerCreationFlag", false);
        component.set("v.offerTeamCreationFlag", false);
        component.set("v.newOffer",{'sobjectType':'Offer__c',
                                    'Name':'',
                                    'Customer_Offer_Due_Date__c':'',
                                    'Opportunity':'',
                                    'Expected_loA_Level':''
                                   }); 
        component.set("v.wrapper", null );
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/' + component.get("v.opptyId")
        });
        urlEvent.fire();
        component.destroy();
    },
    
    handleSave: function(component, event, helper) {
        component.set("v.saveClicked",true);
        var teamValidated = helper.validateTeam(component);
        if(teamValidated)
            helper.saveOffer(component);
    },
    
    // function for create new object Row in Contact List 
    addNewRow: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List  
        helper.createObjectData(component, event);
    },
    
    // function for delete the row 
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");
        // get the all List (contactList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.wrapper");
        AllRowsList.splice(index, 1);
        // set the contactList after remove selected row element  
        component.set("v.wrapper", AllRowsList);
    },
    
})