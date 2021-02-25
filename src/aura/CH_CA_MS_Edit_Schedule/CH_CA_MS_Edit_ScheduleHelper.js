({
    getTableId: function(component){
    	return '#timeslots-' + component.get("v.scheduleId");         
    },
    // Intialize the datatables object
    createTable: function(component, timeslots) {
        // Don't re-initialize the table when it already exists
        if ($.fn.DataTable.isDataTable(this.getTableId(component))) {
  			return;
		}
        
        var tableId = this.getTableId(component);
        var thisHelper = this;
        $(tableId).on( 'error.dt', function ( e, settings, techNote, message ) {
            console.log( 'error occurred in dataTables_' +tableId +' : ', message );
        }).DataTable({
            columnDefs: [{
                	orderable: false,
                    mRender: function (data, type, full) {
                        return '<input class="button" type="Checkbox" />' 
                    },
                    data: null,
                    defaultContent: '',
                	width: '3em',
                	targets: 0,
                    title: 'Select'
            	},{
                    mRender: function (data, type, full) {
                        // javascript:; makes sure that when you click on the link you don't go anywhere
                        return '<a href="javascript:;">' + data + '</a>' 
                    },
                    data: 'Name',
                    width: '5em',
                    targets: 1,
                    title: 'Timeslot Name'
                },{
                    data: 'CH_Day__c', 
                    width: '10em',
                    targets: 2,
                    title: 'Day'
                },{
                	mRender: function (data, type, full) {
                        var date = new Date(data);
                        return '<input class="slds-input" type="text" readonly value="' + date.toLocaleTimeString(component.get('v.userLocale'),{ timeZone: 'UTC'}) + '" />';                       
                    },
                    data: 'CH_Start_Time__c',
                    width: '10em',
                    targets: 3,
                    title: 'Start Time'
                },{
                	mRender: function (data, type, full) {
                        var date = new Date(data);
                        return '<input class="slds-input" type="text" readonly value="' + date.toLocaleTimeString(component.get('v.userLocale'),{ timeZone: 'UTC'}) + '" />';                       
                    },
                    data: 'CH_End_Time__c', 
                    width: '10em',
                    targets: 4,
                    title: 'End Time'
                }        
            ],
            ordering: true,
            autoWidth: false,
            rowId: 'Id',
            pageLength: 5,
            lengthMenu: [ 5, 10, 25 ],
            data: timeslots,
	    destroy:true
        });
        $(tableId).on('click', 'input[type="Checkbox"]', function() {
            var selectedRows = $(tableId).DataTable().rows({ selected: true }).ids(false).toArray();
            var row = $(tableId).DataTable().row($(this).closest('tr'));
            var rowId = row.data().Id;
            // Check if the rowId of the current row is a slected row already
            if ($.inArray(rowId, selectedRows) === -1){
                // If not selected
            	row.select();        
            }
            else {
                // If selected
                row.deselect();
            }
            
            // Enable Disable the delete button
            var button = component.find('deleteTimeslotButton');
            selectedRows = $(tableId).DataTable().rows({ selected: true }).ids(false).toArray();
            if (selectedRows.length > 0){
                button.set('v.disabled',false);
            }
            else {
                button.set('v.disabled',true);
            }
        });
        // When clicking on the timeslot name goto the next screen with the id of the row
        $(tableId).on('click', 'a', function() {
            var tr = $(this).closest('tr');
            var rowId = $(tableId).DataTable().row(tr).id();            
            component.set("v.timeslotId", rowId);
        });        
    },
    // Delete the schedules
    deleteSchedule: function(component){
        var promise = new Promise( function( resolve , reject ) {
        	const sharedjs = component.find("sharedJavaScript");
        	resolve(sharedjs.apex(component, 'deleteSchedule',{ scheduleId : component.get("v.schedule.Id")}));
        });           
        return promise; 
    },
    // Delete the filter
    deleteFilter: function(component){
        var promise = new Promise( function( resolve , reject ) {
        	const sharedjs = component.find("sharedJavaScript");
        	resolve(sharedjs.apex(component, 'deleteFilter',{ filterId : component.get("v.schedule").CH_Workgroup_Filters__r[0].Id}));
        });           
        return promise; 
    },
    // Delete the selected timeslots
    deleteTimeSlots: function(component){
        var tableId = this.getTableId(component);
        var promise = new Promise( function( resolve , reject ) {
            var selectedRows = $(tableId).DataTable().rows({ selected: true }).ids(false).toArray();
        	const sharedjs = component.find("sharedJavaScript");
        	resolve(sharedjs.apex(component, 'deleteSelectedTimeSlots',{ selectedTimeSlotIds : selectedRows }));
        });           
        return promise; 
    },    
    // Get the schedule based on the attribute v.schedule.Id
    refreshSchedule: function(component) {
        var helperModule = this;
        var schedule;
        var promise = new Promise( function( resolve , reject ) {
        	const sharedjs = component.find("sharedJavaScript");
        	sharedjs.apex(component, 'getSchedule',{ scheduleId : component.get("v.scheduleId")})
            .then(function(result){
                schedule = result;
                component.set('v.schedule', schedule);
                component.set('v.scheduleId', schedule.Id);
                return sharedjs.apex(component, 'getFilter',{ scheduleId : component.get("v.scheduleId")})
            })
            .then(function(result){
                // Apex returns a map
                var map = result;
                Object.keys(map).forEach(function(key) {
                    if (key == 'filter'){
                        var filters = map[key];
                        var filter = (filters.length > 0) ? filters[0] : null;
                        component.set('v.filter', filter);
                		// Fix for picklist with --None-- value
                        component.set("v.oldOutageValue", (filter == null) ? '' : filter.CH_Outage__c);
						//Added for prod issue 28410
                        component.set("v.oldLevelOfSupportValue", (filter == null) ? '' : filter.CH_LevelOfSupport__c);
                    }
                    if (key == 'filterProducts'){
                        var filterProducts = map[key];
                        component.set('v.filterProducts', filterProducts);
                        var visible = (filterProducts.length == 0)? true : false;
                        component.set('v.noFilterProducts', visible);
                    }
                    if (key == 'filterCustomers'){
                        var filterCustomers = map[key];
                        component.set('v.filterCustomers', filterCustomers);
                        var visible = (filterCustomers.length == 0)? true : false;
                        component.set('v.nofilterCustomers', visible);
                    }
                });

                // Reload the recordedit form to make sure the latest data is visible
                component.set('v.refreshUI', false);
                component.set('v.refreshUI', true);                
                component.set('v.dataChanged', false);

                resolve(schedule);
            });
        });           
        return promise;         
    },
    // Save the filter customers
    saveFilterRelatedLists: function(component){
        // Update the filter related lists on the server
        var promise = new Promise( function( resolve , reject ) {
        	const sharedjs = component.find("sharedJavaScript");
        	resolve(sharedjs.apex(component, 'saveFilterRelatedLists',{ productsToSave : component.get('v.filterProducts'), customersToSave : component.get('v.filterCustomers')}));
        });           
        return promise; 
    },
    // Save the schedule
    saveSchedule: function(component, scheduleFields){
        // Update the filter related lists on the server
        var promise = new Promise( function( resolve , reject ) {
        	const sharedjs = component.find("sharedJavaScript");
        	resolve(sharedjs.apex(component, 'saveSchedule',{ scheduleFields : scheduleFields }));
        });           
        return promise; 
    },
})