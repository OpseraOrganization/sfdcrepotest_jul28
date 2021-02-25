({
    validateProfile : function(component,helper){
        var action = component.get("c.validateFieldsAccessibility");
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var fields = response.getReturnValue();
				if(fields !== null && fields !== ''){
					component.set("v.fields", fields);
				}
			}
		});
		$A.enqueueAction(action);
    },    
    
	//F1784 - method to reload repeatly the record and if there is a change in the OIF
	reloadingRecord : function(component, helper){
        
        var isClosed = component.get("v.simpleRecord.IsClosed");
        if(!isClosed){
            //set to reload the record every x seconds
            setInterval(
                $A.getCallback(function() {
                    var loader = component.find("recordLoader");
                    if(loader !== undefined){
                        loader.reloadRecord(true, $A.getCallback(function() {
                            var newLastRefresh = component.get("v.simpleRecord.Last_Refresh_OIF__c");
                            var oldLastRefresh = component.get("v.lastRefreshOIFs");
                            var newOIFLines = component.get("v.simpleRecord.OIF_Lines__c");
                            var oldOIFLines = component.get("v.oifLines");
                            if(newLastRefresh !== oldLastRefresh || newOIFLines != oldOIFLines){
                                component.set("v.lastRefreshOIFs", component.get("v.simpleRecord.Last_Refresh_OIF__c"));
                                component.set("v.oifLines", component.get("v.simpleRecord.OIF_Lines__c"));
                                helper.checkOIFChanges(component);
                            }
                        }))
                    }}), 6000
            );
        }
	},
    
	//F1784 - check if there are any date changes and if there is a proposed new G5 Plan Date
	checkOIFChanges : function(component) {

		var action = component.get("c.checkMinPlanDateOIF");

		action.setParams({
			recordId: component.get("v.recordId")
		});

		action.setCallback(this, function(response) {

			var state = response.getState();

			if (state === "SUCCESS") {
				var newWDPlanDate = response.getReturnValue();
				if(newWDPlanDate != null){
					component.set("v.newWDPlanDate", newWDPlanDate);
					component.set("v.modal_WDDate", true);
				}
			}
		});
		$A.enqueueAction(action);
	},

	//F1784 - Save the new Win Declaration plan date on the opportunity
	submitNewDecisionPlanDate : function(component){

		var action = component.get("c.overrideDecisionPlanDate");

		action.setParams({
			recordId: component.get("v.recordId"),
			newWDPlanDate: component.get("v.newWDPlanDate")
		});

		action.setCallback(this, function(response) {

			var state = response.getState();

			if (state === "SUCCESS") {

				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "Win Declaration Plan Date",
					"message": "The Win Declaration Plan Date was successfully updated.",
					"type": "info",
					"mode":"pester",
					"duration":10000
				});
				resultsToast.fire();
				$A.get('e.force:refreshView').fire();

			} else if(state === "ERROR") {
				var errors = response.getError();
				var message = "There was a problem and it was not possible to update the Win Declaration Plan Date. Go to Opportunity Detail page to confirm planning.";
				if(errors.length  > 0 && errors[0].pageErrors){
					for(var i = 0; i < errors[0].pageErrors.length ; i++){
						if(errors[0].pageErrors[i].statusCode == "FIELD_CUSTOM_VALIDATION_EXCEPTION" && errors[0].pageErrors[i].message.includes("The Gate Planned Date entered is either blank")){
							message = "The update of the Win Declaration Planned Date was not possible due to inconsistency with dates of preceding gates. Please go to Detail tab and thoroughly rework the opportunity planned dates.";
							break;
						}
					}
				}

				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "Win Declaration Plan Date",
					"message": message,
					"type": "error",
					"mode":"pester",
					"duration":10000
				});
				resultsToast.fire();
			}
		});
		$A.enqueueAction(action);
	},

	checkOpttyStageParams : function(component) {

		var action = component.get("c.checkOpttyStageParams");

		action.setParams({ recordId: component.get("v.recordId")});
		action.setCallback(this, function(response){
			if(response.getReturnValue() ===1)
			{
				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "Please Note",
					"message": "Main Reason 1 : \"Value is pre-populated to Sales and Customer Engagement\"\n Main Reason 2 : \"Value is pre-populated to Commercial\"\n Main Reason 3 : \"Value is pre-populated to Mistake/Redundant/Merged\" ",
					"type": "info",
					"mode":"sticky"
				});
				resultsToast.fire();
			 }

		});
		$A.enqueueAction(action);
	},

	displayWarningMessage: function(component) {

		var currentUrl = window.location.href; // Get current url

		var action = component.get("c.findOffer");

		action.setParams({
			recordId: component.get("v.recordId"),
			url: currentUrl
		});

		action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {

				var showToast = $A.get('e.force:showToast');
				showToast.setParams({
					'message': response.getReturnValue(),
					'type': 'warning',
					'duration': 10000
				});

				//fire the event
				showToast.fire();
			} else {
				console.info('No warning message to display');
			}
		});
		$A.enqueueAction(action);

	},
    
    showWarningIndirect : function(component, event, helper) {
        var action=component.get("c.getOpptyInfo");
        
        action.setParams({
            currentRecordId : component.get("v.recordId"),
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS" && result ) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: 'This is Warning Toast...!!!',
                    messageTemplate: 'Indirect opportunities require ACAF questionnaires to be in line with the {0}. Please verify that a valid Company Profile Questionnaire (CPQ) and ACAF are in place for the related third party and opportunity and if not, please initiate these questionnaires now in the {1} in order avoid delays in the process. Any questions, you can reach out to your Ethics & Compliance leaders {2}.',
                    messageTemplateData: [                        
                        { url: 'https://nokia.sharepoint.com/Ethics_Compliance/Pages/Third-Party.aspx',
                         label: 'SOP on Third Parties'
                        },
                        {url: 'https://nokia.compliancedesktop.com/login',
                         label: 'Compliance Desktop Tool',},
                        {url: 'https://nokia.sharepoint.com/Ethics_Compliance/Documents/Compliance%20Leaders%20list.pdf',
                         label: 'here',}
                    ],
                    duration:' 60000',
                    type: 'warning'
                });
                toastEvent.fire();
           }
        });
        $A.enqueueAction(action);
    }
})