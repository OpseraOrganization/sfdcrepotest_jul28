({
    //Spinner Code Start
    showWaiting:function(cmp){
        cmp.set("v.IsSpinner",true);
    },
    hideWaiting:function(cmp){
        cmp.set("v.IsSpinner",false);  
    },
    //Spinner Code Ends
	doInit: function(component, event, helper) {  
        component.set('v.neaColumns', [
            {label: 'Network Element ID', fieldName: 'CH_NetworkElementID__c', sortable: 'true', searchable: 'true', type: 'text'},
            {label: 'Asset Name', fieldName: 'AssetName', sortable: 'true', searchable: 'true', type: 'text'},
            {label: 'Product', fieldName: 'ProductName', sortable: 'true', searchable: 'true', type: 'text'},
            {label: 'Solution', fieldName: 'SolutionName', sortable: 'true', searchable: 'true', type: 'text'},
            {label: 'Product Variant', fieldName: 'ProductVariant', sortable: 'true', searchable: 'true', type: 'text'},
            {label: 'Product Release', fieldName: 'ProductRelease', sortable: 'true', searchable: 'true', type: 'text'},
            {label: 'Address', fieldName: 'Address', sortable: 'true', searchable: 'true', type: 'text'},
            {label: 'Lab', fieldName: 'CH_LabEnvironment__c', sortable: 'true',searchable: 'true', type: 'boolean'},        
            {label: 'Country', fieldName: 'CH_CountryISOName__c', searchable: 'true', type: 'hidden'}
        ]);
        var selAccount = component.get('v.selectedAccount');
        var selectedAsset = component.get("v.assetRec");
        var selectedCLI = component.get("v.selectedContractLineItem");
        var cliId = null;
        if(selectedAsset != undefined && selectedAsset != '' && selectedAsset != null){
            cliId = selectedAsset[0].HWS_ContractLineItem__c;
        }  
        if(selectedCLI != undefined && selectedCLI != '' && selectedCLI != null){
            cliId = selectedCLI[0].Id;
        }
        helper.getNetworkElementAssets(component,selAccount,cliId);
    },
    
    processSelectedNEA : function(component, event, helper) {
        var selectedNEA = event.getParam('selectedRows');
		component.set('v.selectedNEA',selectedNEA);
        var cmpEvent = component.getEvent("HWS_CaseFlowEventPortal");
        var selAsset = component.get("v.assetRec");
        var assets = component.get("v.allAssets");	
        var selCLI = component.get("v.selectedContractLineItem");	
        var clis = component.get("v.allCLIS");	
        var selAssetCheck = false;	
        var selContractCheck = false;	
        var searchCrit = component.get("v.searchCriteria");	
        var CLIID = [];	
        CLIID.push(selectedNEA[0].Network_Element_Assets__r[0].CH_ContractLineItem__c);	
        if(searchCrit == 'Part Code' && (selAsset == '' || selAsset == null || selAsset == undefined)){	
            selAssetCheck = true;	
            var assetRelatedCLIIDs = [];	
            var assetMap = new Map();	
            var assets1 = [];	
            if(assets != null){	
                for(var i=0;i<assets.length;i++){	
                    assetRelatedCLIIDs.push(assets[i].HWS_ContractLineItem__c);	
                    if(assets[i].CoveredNetworkElementCount == '0'){	
                        CLIID.push(assets[i].HWS_ContractLineItem__c);	
                    }	
                    assetMap[assets[i].HWS_ContractLineItem__c] = assets[i];	
                }	
            }	
            for(var i=0;i<CLIID.length;i++){	
                if(assetRelatedCLIIDs.includes(CLIID[i])){	
                    assets1.push(assetMap[CLIID[i]]);	
                }	
            }	
            component.set("v.Assets",assets1);	
        }	
        if(searchCrit == 'Contract Number' && (selCLI == '' || selCLI == null || selCLI == undefined)){	
            selContractCheck = true;	
            var cliIdList = [];	
            var cliMap = new Map();	
            var clis1 = [];	
            if(clis != null){	
                for(var i=0;i<clis.length;i++){	
                    cliIdList.push(clis[i].Id);	
                    if(clis[i].CoveredNetworkElementCount == '0'){	
                        CLIID.push(clis[i].Id);	
                    }	
                    cliMap[clis[i].Id] = clis[i];	
                }	
            }	
            for(var i=0;i<CLIID.length;i++){	
                if(cliIdList.includes(CLIID[i])){	
                    clis1.push(cliMap[CLIID[i]]);	
                }	
            }	
            component.set("v.clis",clis1);	
        }             
        cmpEvent.setParams({            
            "showSection" : 8,
            "selectedNEA" : selectedNEA[0],   
            "selectedAssetCheck" : selAssetCheck,	
            "showassets" : assets1,	
            "selectedCLICheck" : selContractCheck,	
            "allCLIS" : clis1
        });
        cmpEvent.fire(); 
    },
    clearSelection : function (component, event, helper) {
        component.find("neaTable").set("v.selectedRows", new Array()); 
        var cmpEvent = component.getEvent("HWS_CaseFlowEventPortal");            
        cmpEvent.setParams({                       
            "showSection" : 50,
            "selectedNEA" : undefined,
			"enableButton" : 4,
        });
        cmpEvent.fire();
        component.getEvent("onrowselection").setParams({
            selectedRows: new Array()
        }).fire();
        
    },
    filterNEA: function(component, event, helper) {
        var action = component.get("v.showAllNEA"),
            NEAFilter = component.get("v.NEAFilterText"),
            results = action, regex;
        try {
            regex = new RegExp(NEAFilter, "i");
            // filter checks each row, constructs new array where function returns true
            results = action.filter(
                row => regex.test(row.Name) ||
                regex.test(row.CH_NetworkElementID__c) ||
                regex.test(row.Product2.Name) ||
                regex.test(row.SolutionName) ||
                regex.test(row.ProductVariant) ||
                regex.test(row.ProductRelease) ||
                regex.test(row.CH_LabEnvironment__c) ||
                regex.test(row.CH_CountryISOName__c) ||
                regex.test(row.Address)
                
            );
        } catch(e) {
            // invalid regex, use full list
        }
        component.set("v.netElemAssets", results);
    },
	componentRefresh : function(component, event, helper) {          
        component.set("v.netElemAssets", null);
        component.set("v.NEAFilterText", null);  
		component.set('v.selectedNEA', null);		
    }
    
})