({
	getNetworkElementAssets : function(component, accountId, cliId) {
		component.set("v.IsSpinner", true);
        var assets = component.get("v.allAssets");    
        var searchCrit = component.get("v.searchCriteria");
        var CLIIDS = [];
        if(assets != null && searchCrit == 'Part Code'){
            for(var i=0;i<assets.length;i++){
                CLIIDS.push(assets[i].HWS_ContractLineItem__c);
            }
        }
        var clitems = component.get("v.allCLIS");	
        if(clitems != null && searchCrit == 'Contract Number'){	
            for(var i=0;i<clitems.length;i++){	
                CLIIDS.push(clitems[i].Id);	
            }	
        }
        var action =component.get("c.getNEA");  
        action.setParams({
            accId : accountId,
            cliId : cliId,
            cliIdList : CLIIDS
        });
        action.setCallback(this, function(response){
            var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.IsSpinner", false);
				var neaList = response.getReturnValue();   
				console.log('response NEA##'+neaList);
				for(var i = 0; i < neaList.length; i++) {
					neaList[i].AssetName = neaList[i].Name;
					neaList[i].Address = neaList[i].Address__r?neaList[i].Address__r.CH_AddressDetails__c :'N/A';
					neaList[i].ProductName = neaList[i].Product2?neaList[i].Product2.Name :'';
					neaList[i].SolutionName = neaList[i].CH_Solution__r?neaList[i].CH_Solution__r.Name :'';
					neaList[i].ProductVariant = neaList[i].CH_ProductVariant__r?neaList[i].CH_ProductVariant__r.Name :'';
					neaList[i].ProductRelease = neaList[i].CH_ProductRelease__r?neaList[i].CH_ProductRelease__r.Name :'';
					if(neaList[i].Id === component.get("v.selected")) {
						selected = true;
						component.find("neaTable").setSelectedRows(new Array(neaList[i].Id));
					}
					if(component.get('v.clearNEACheck')){
						console.log('NEA CLEAERES');
						component.set('v.netElemAssets',null);
						component.set("v.selectedNEA",null);
					}
					component.set('v.clearNEACheck',false);
					component.set('v.netElemAssets',neaList);
					component.set('v.showAllNEA',neaList);
				}
			}            
        });
        $A.enqueueAction(action);                
    }
})