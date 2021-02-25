({
    // Load the schedules for the current workgroup
    doInit: function(component, event, helper) {
        component.set("v.Spinner", true);
        window.setTimeout(
            $A.getCallback(function() {
                const sharedjs = component.find("sharedJavaScript");
                sharedjs.apex(component,'getLocale',{})
                .then(function(result){
                    component.set('v.userLocale', result);
                    return sharedjs.apex(component,'getSchedules',{ workgroupId : component.get("v.workgroupId") });
                })
                .then(function(result){
                    helper.createTable(component, result);
                    component.set("v.Spinner", false);
                });
            }), 3000
        );
        
    },
    // Display a confirmation message before the delete
    confirmDelete: function(component, event, helper) {
        // Display confirmation message
        var tableId = helper.getTableId(component);  
        var selectedRows = $(tableId).DataTable().rows({ selected: true }).ids(false).toArray();
        var message = 'Do you want to delete ' + selectedRows.length + ' schedule' + (selectedRows.length > 1 ? 's?' : '?');
        var buttonClickedId = event.getSource().getLocalId();
        var messageBox = component.find('messageBox');        
        messageBox.displayModelMessage(buttonClickedId, true, false, true, message);        
    },
    // Handle events from the messagebox button clicks
    handleMessageboxEvent: function(component, event, helper){
        var popupButtonClicked = event.getParam("popupButtonClicked");

        // The delete button was clicked then delete the selected schedules
        if (popupButtonClicked == 'delete'){
            component.set("v.Spinner", true);
            
            var status;
            helper.deleteSchedules(component)
            .then(function(result){
                status = result;

            	// Get the latest schedules from the server
            	const sharedjs = component.find("sharedJavaScript");
            	return sharedjs.apex(component,'getSchedules',{ workgroupId : component.get("v.workgroupId") });
            })
            .then(function(result){
                // Refresh the table
                var tableId = helper.getTableId(component);
                $(tableId).DataTable().clear().rows.add(result).draw();
                component.set("v.Spinner", false);
                // Disable the delete button
            	var button = component.find('deleteScheduleButton');
                button.set('v.disabled',true);
                // Display the status of the save
                var messageBox = component.find('messageBox'); 
                messageBox.displayToastMessage(status);
            });
        }
    },
    // Validate the selected schedules
    validate: function(component, event, helper) {
        var validateSchedule = component.find('validateSchedule');
        var tableId = helper.getTableId(component); 
        var selectedRows = $(tableId).DataTable().rows({ selected: true }).ids(false).toArray();
        validateSchedule.validateSchedule(selectedRows);
    },
    // Event to fire when the new button or the schedule link is clicked
    navigationClicked : function(component, event) {
        var buttonClicked = event.getSource().getLocalId();
        var appEvent = $A.get("e.c:CH_CA_MS_Child_Event");
        appEvent.setParams({"action" : buttonClicked,
        					"scheduleId" : component.get("v.scheduleId")});
        appEvent.fire();
    }
})