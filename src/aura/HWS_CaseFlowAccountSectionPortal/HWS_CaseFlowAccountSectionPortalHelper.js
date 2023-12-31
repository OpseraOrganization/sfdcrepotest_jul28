({
	getContactType : function(component, event, helper) {        
        var id = component.get("v.recordId");
        var action =component.get("c.getContactType");
        action.setParams({
            contactid: id
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(response.getReturnValue()=='Communication Contact'){
                component.set("v.isCommunicationContact","true");
                component.set("v.communicationContactMessage",'Contact is a Communication Contact and Support Tickets cannot be initiated.')
            }
            else{
                component.set("v.isCommunicationContact","false");
            }
        });
        $A.enqueueAction(action);
    },
    
    // Set Tab Icon and Label - added for the US-3196, 3198 - start
    setTabIcon : function(component) {
        //Js Controller
        var workspaceAPI = component.find("CreateCaseWorkspace");        
        workspaceAPI.getEnclosingTabId().then(function(response) {
            workspaceAPI.setTabLabel({
                tabId: response,
                label: "Create Case", //set label you want to set
                title: "Create Case"
            });
            workspaceAPI.setTabIcon({
                tabId: response,
                icon: "action:new_case", //set icon you want to set
                iconAlt: "Create Case" //set label tooltip you want to set
            });
            workspaceAPI.focusTab({
                tabId : response
            }); 
        })
    },
    
    //added for US-3205 to get Contact Name
    getContactName : function(component, event, helper) {        
        var id = component.get("v.recordId");                
        var action =component.get("c.getContactName");
        action.setParams({
            contactid: id
        });                
        action.setCallback(this, function(response) {                       
                var contactName = response.getReturnValue();
                component.set("v.contactName",contactName);            
        });
        $A.enqueueAction(action);
    },
    
    getRelatedAccounts : function(component, event, helper) {
        component.set('v.AccountColumns', [
            //US-3199 code added Legal Account hyper link
        	//{label: 'Name', fieldName: 'linkName', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Name', fieldName: 'Name', type: 'text'},//,sortable:true
			{label: 'Operational Customer Name', fieldName: 'OperationalCustomerName__c', type: 'text'},	
            {label: 'Account Number', fieldName: 'AccountNumber', type: 'text'},   //,sortable:true 
			{label: 'Parent Account', fieldName: 'CH_ParentAccountName__c', type: 'text'}
            
        ]);
		var id = component.get("v.recordId");            
		var action =component.get("c.getAllAccounts");
		action.setParams({
			contactid: id
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(response.getReturnValue()==null){
				component.set("v.isActive","false");
				component.set("v.cntInactiveMessage",'Contact is inactive and Support Tickets cannot be initiated.')
			}
			else{
				component.set("v.isActive","true");
				component.set("v.conAccounts", response.getReturnValue());
                component.set("v.AllAccounts", response.getReturnValue()); 
                var parentAccountId = component.get("v.conAccounts");
                console.log('parent account id '+parentAccountId[0].AccountId);
			}
		});
		$A.enqueueAction(action);
	},
    
    getParentAccount : function(component, event){
        var action = component.get("c.getParentAccountId");
        action.setParams({ contactId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var stringItems = response.getReturnValue();                
                component.set("v.defaultAccount", stringItems);                
            }
        });
        $A.enqueueAction(action);
    },
    
    getFailureOccurrencePickListValues : function(component, event) {
        var action = component.get("c.getPickListValues1");
        action.setParams({ obj:"Case",str:"HWS_Failure_Occurance__c"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var stringItems = response.getReturnValue();
                
                component.set("v.FailureOccurance", stringItems); 
            }
        });
        $A.enqueueAction(action);
    },
    
    getFailureDetectionPickListValues : function(component, event) {
        
        var action = component.get("c.getPickListValues1");
        action.setParams({ obj:"Case",str:"HWS_Failure_Detection__c"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var stringItems = response.getReturnValue();                
                component.set("v.FailureDetection", stringItems); 
            }
        });
        $A.enqueueAction(action);
    },
    
    getFailureDescriptionPickListValues : function(component, event) {        
        var action = component.get("c.getPickListValues1");
        action.setParams({ obj:"Case",str:"HWS_Failure_Description__c"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var stringItems = response.getReturnValue();                
                component.set("v.FailureDescription", stringItems); 
            }
        });
        $A.enqueueAction(action);
    },
    
    gotoSearchScreen: function(component, event, helper) {        
        var rows = component.get("v.selectedAccount");        
        if(rows!=null && rows!='' && rows!=undefined){
            component.set("v.Stage1", "slds-path__item slds-is-complete");
            component.set("v.Stage2", "slds-path__item slds-is-current slds-is-active");
            component.set("v.StageNumber", 2);
            var Cli=component.get("v.selectedclis");
            var Asset=component.get("v.selectedAssets");
            var Acc=component.get("v.selectedAccount");
            var selAcc=JSON.parse(JSON.stringify(Acc[0]));
            var oldAcc = component.get("v.oldSelectedAccount");
            var showAssets = component.get("v.showAssets");
            var showCli = component.get("v.showClis");
            if(selAcc.Id==oldAcc){
                var searchCriteria =component.get("v.searchCriteria");
                var searchType=component.find("InputSelectSingle");
                searchType.set("v.value",searchCriteria);
                if(Asset!=null && Asset!='' && Asset!=undefined && showAssets=='true'){
                    
                    var dTable = component.find("cliTable");
                    var selectedAcc = dTable.getSelectedRows();
                    var selectedAcc = component.get("v.selectedAssets");
                    if (typeof selectedAcc != 'undefined' && selectedAcc) {
                        var selectedRowsIds = [];
                        for(var i=0;i<selectedAcc.length;i++){
                            selectedRowsIds.push(selectedAcc[i].Id);  
                        }         
                        var dTable = component.find("cliTable");
                        dTable.set("v.selectedRows", selectedRowsIds);
                    }
                    
                }
                if((Cli!=null && Cli!='' && Cli!=undefined) && showCli=='true'){
                    
                    var dTable = component.find("conTable");
                    var selectedAcc = dTable.getSelectedRows();
                    var selectedAcc = component.get("v.selectedclis");
                    if (typeof selectedAcc != 'undefined' && selectedAcc) {
                        var selectedRowsIds = [];
                        for(var i=0;i<selectedAcc.length;i++){
                            selectedRowsIds.push(selectedAcc[i].Id);  
                        }         
                        var dTable = component.find("conTable");
                        dTable.set("v.selectedRows", selectedRowsIds);
                    }
                    
                }
            }else{
                component.set("v.showParentEntS",false);//HIDE ENTITLEMENT IF ACC IS CHANGED
                component.set("v.showLineEntS",false);//HIDE ENTITLEMENT IF ACC IS CHANGED
                component.set("v.Assets", null);
                component.set("v.selectedAssets", null);
                component.set("v.clis", null);
                component.set("v.selectedclis", null);
                component.set("v.selectedVersions", null);
                component.set("v.versionItems", null);
                component.set("v.searchKeyword",'');
                component.set("v.contractNumber",'');
                component.set("v.serviceType",'');
                component.set("v.showStep6",false);
                component.set("v.showAssets",false);
                component.set("v.showClis",false);
                component.set("v.searchCriteria",'Part Code');
                if(oldAcc!=null && oldAcc!='' && oldAcc!=undefined){
                    this.clearChild(component,event);
                    this.clearParent(component,event);
                }
            }
            
        }else{
            this.showToast('error','Error Message','Please select Account before proceeding');
        }
        var today = new Date();
        component.set('v.newChildCase.HWS_Planned_Delivery_Date__c', today);
    },
})