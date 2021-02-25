({
    getTableId: function(component){
    	return '#schedules-' + component.get("v.workgroupId");          
    },
    // Intialize the datatables object
    createTable: function(component, schedules) {
        var thisHelper = this;
        var tableId = this.getTableId(component);
        $(tableId).DataTable({
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
                    width: '15em',
                    targets: 1,
                    title: 'Schedule Name'
                },{
                    mRender: function (data, type, full) {
                        return '<input type="Checkbox" ' + ((data)?' Checked ':'') + ' disabled="disabled" />' 
                    },
                    data: 'CH_Active__c',
                    width: '3em',
                    targets: 2,
                    orderDataType: 'dom-checkbox',
                    title: 'Active'
                },{
                    mRender: function (data, type, full) {
                        var date = new Date(data);
                        return '<input class="slds-input" type="datetime" readonly value="' + date.toLocaleString(component.get('v.userLocale')) + '" />';                        
                    },
                    data: 'CH_Start_DateTime__c', 
                    type: 'date',
                    width: '15em',
                    targets: 3,
                    title: 'Start Date'
                },{
                	mRender: function (data, type, full) {
                        var date = new Date(data);
                        return '<input class="slds-input" type="datetime" readonly value="' + date.toLocaleString(component.get('v.userLocale')) + '" />';                       
                    },
                    data: 'CH_End_DateTime__c', 
                    type: 'date',
                    width: '15em',
                    targets: 4,
                    title: 'End Date'
                },{
                    data: 'CH_Workgroup_Filters__r[0].CH_Region__c',
                    width: '10em',
                    targets: 5,
                    title: 'Region'
                },{
                    data: 'CH_Workgroup_Filters__r[0].CH_Country__c',
                    width: '10em',
                    targets: 6,
                    title: 'Country'
                },{
                    data: 'CH_Workgroup_Filters__r[0].CH_Outage__c',
                    width: '10em',
                    targets: 7,
                    title: 'Outage'
                },{
                    data: 'CH_Workgroup_Filters__r[0].CH_Severity__c',
                    width: '10em',
                    targets: 8,
                    title: 'Severity'
                },{
                    data: 'CH_Workgroup_Filters__r[0].CH_Workgroup_Type__c',
                    width: '10em',
                    targets: 9,
                    title: 'Workgroup Type'
                },{
                    data: 'CH_Workgroup_Filters__r[0].CH_LevelOfSupport__c',
                    width: '10em',
                    targets: 10,
                    title: 'Level Of Support'
                },{
                    data: 'Id',
                    targets: 11,
                    title: 'Schedule Id',
                    visible: false
                },{
                    mRender: function (data, type, full) {
                        return ((data)?'true':'false'); 
                    },
                    data: 'CH_Active__c',
                    targets: 12,
                    title: 'Active Hidden',
                    visible: false
                }        
            ],
            ordering: true,
            autoWidth: false,
            rowId: 'Id',
            pageLength: 5,
            lengthMenu: [ 5, 10, 25 ],
            data: schedules,
        });
        // Handle the (de)select of the checkbox
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
            var button = component.find('deleteScheduleButton');
            var validatebutton = component.find('validateButton');
            selectedRows = $(tableId).DataTable().rows({ selected: true }).ids(false).toArray();
            if (selectedRows.length > 0){
                button.set('v.disabled',false);
                validatebutton.set('v.disabled',false);
            }
            else {
                button.set('v.disabled',true);
                validatebutton.set('v.disabled',true);
            }
        });
        // When clicking on the schedule name goto the next screen with the id of the row
        $(tableId).on('click', 'a', function() {
            var tr = $(this).closest('tr');
            var rowId = $(tableId).DataTable().row(tr).id();
            component.set("v.scheduleId",rowId);
        });
        // Be able to sort on checkboxes
        $.fn.dataTable.ext.order['dom-checkbox'] = function  ( settings, col )
        {
            return this.api().column( col, {order:'index'} ).nodes().map( function ( td, i ) {
                return $('input', td).prop('checked') ? '1' : '0';
            } );
        };
    },
    // Delete the selected schedules
    deleteSchedules: function(component){
        var tableId = this.getTableId(component);
        var promise = new Promise( function( resolve , reject ) {
            var selectedRows = $(tableId).DataTable().rows({ selected: true }).ids(false).toArray();
        	const sharedjs = component.find("sharedJavaScript");
        	resolve(sharedjs.apex(component, 'deleteSelectedSchedules',{ selectedScheduleIds : selectedRows }));
        });           
        return promise; 
    },
})