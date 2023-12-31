({
    getlineitemlist : function(component, event, helper) {
        this.showSpinner(component);
        var lineaction1 = component.get("c.getlineitems");
        console.log('entered function getlineitemlist1');
        return new Promise(function (resolve, reject) {
            lineaction1.setParams({
                configId : component.get("v.configId")
            });
            
            lineaction1.setCallback(this, function(response){
                var state = response.getState();
                console.log('response getlineitemlist: '+state);
                if (state === "SUCCESS" ) {
                    var resultData = response.getReturnValue();
                    console.log('json: '+JSON.stringify(response.getReturnValue().lstDataTableColumns));
                    console.log('data: '+JSON.stringify(response.getReturnValue().lstDataTableData));
                    component.set("v.lineitemcolumns", response.getReturnValue().lstDataTableColumns);
                    component.set("v.lineitemdata", response.getReturnValue().lstDataTableData);
                    component.set("v.unassignedrows",response.getReturnValue().lstDataTableData.length);
                    resolve(response.getReturnValue());
                }
                else if (component.isValid() && state === "ERROR") {
                    var errors = response.getError();
                    reject(response.getError()[0]);
                }
            });
            $A.enqueueAction(lineaction1);
        });
    },
    
    getgroups :function(component, event, helper) {
        
        var action = component.get("c.getgrouplist");
        var grpoptions = [{'label': 'choose one', 'value': 'choose'},{'label': '--- Create New ---', 'value': 'new'}];
        console.log('entered function getgroups');
        return new Promise(function (resolve, reject) {
        action.setParams({
            configId : component.get("v.configId")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response getgroups: '+state);
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                console.log('key: '+JSON.stringify(resultData));
                for(var i=0; i<Object.keys(resultData).length; i++){
                    var option ={};
                    
                    option['label']=resultData[Object.keys(resultData)[i]];
                    option['value']=Object.keys(resultData)[i];
                    
                    grpoptions.push(option);
                }
                console.log("grpoptions:"+JSON.stringify(grpoptions));
                component.set('v.groupoptions',grpoptions);
                resolve(response.getReturnValue());
            }else if (component.isValid() && state === "ERROR") {
                    var errors = response.getError();
                    reject(response.getError()[0]);
                }
        });
        $A.enqueueAction(action);
         });
        },
    
    getbundledetails : function (component, event, helper, bundlecode){
        this.showSpinner(component);
        var action = component.get("c.getbundledata");
        var grpoptions = [{'label': '--- Create New ---', 'value': 'new'}];
        console.log('entered function getbundledetails');
        console.log('bundlecode: '+bundlecode);
        
        action.setParams({
            groupcode : bundlecode,
            configId : component.get("v.configId")
            
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response getbundledetails: '+state);
            console.log('response getbundledetails: '+JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                
                component.set('v.RollupData', resultData.rollupdata);
                component.set('v.bundlecolumns',resultData.BundleList.lstDataTableColumns);
                component.set('v.bundledata',resultData.BundleList.lstDataTableData);
                component.set('v.quantity', resultData.rollupdata.Quantity);
                component.set('v.newgroupname',resultData.rollupdata.GroupName.substring(0,(resultData.rollupdata.GroupName.lastIndexOf("QTY("))-1));
                this.hideSpinner(component);
            }else if (component.isValid() && state === "ERROR") {
                    component.set('v.ErrorMsg','Error Occured While Deleting Rows');
                    component.set('v.iserror','true');
                     this.hideSpinner(component);
                }
        });
            $A.enqueueAction(action);
        
    },
    
    RedirectTocart: function(component, event, helper) {
        
        var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
            vars[key] = value;
            console.log('working'+m);
            console.log('working1'+key);
        });
        
        var vURL = "https://"+$A.get("$Label.c.CartURL")+"/apex/Cart?configRequestId="+ vars["configRequestId"]+"&cartStatus=New&id="+vars["id"]+"&flow=";
        window.location = vURL;
    },
    
    DeleteLineItems: function (component, event, helper) {
        
        this.showSpinner(component);
        component.set('v.iserror','false');
        try{
            var grpoptions = [{'label': 'choose one', 'value': 'choose'},{'label': '--- Create New ---', 'value': 'new'}];
            var selrows = component.get('v.bundlerowCnt');
            console.log('selrows: '+selrows);
            var bundlename = component.get('v.bundleoptionselected');
            console.log('bundlename: '+bundlename);
            if(selrows == '0' || typeof selrows == 'undefined' ){
                component.set('v.ErrorMsg','Please select at least one Line Item');
                component.set('v.iserror','true');
                this.hideSpinner(component);
            }else{
                var rows = component.get("v.BundleRows");
                console.log('BundleRows:  '+JSON.stringify(rows));
                var action = component.get('c.RemoveLineItems');
                action.setParams({
                    
                    LineitemIdList : rows,
                    configId : component.get("v.configId")
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    console.log('state+: '+state);
                    if (state === "SUCCESS" ) {
                        
                        var resultData = response.getReturnValue();
                    //console.log('resultData: '+ JSON.stringify(response.getReturnValue()));
                    //Set Table whose Line Items are not assigned to Groups
                    component.set("v.lineitemcolumns", resultData.StandaloneList.lstDataTableColumns);
                    component.set("v.lineitemdata", resultData.StandaloneList.lstDataTableData); 
                    component.set("v.unassignedrows",resultData.StandaloneList.lstDataTableData.length);
                    console.log('Set Bundle component data ');
                    //Set Bundle component data
                    component.set('v.RollupData', resultData.BundleData.rollupdata);
                    component.set('v.bundlecolumns',resultData.BundleData.BundleList.lstDataTableColumns);
                    component.set('v.bundledata',resultData.BundleData.BundleList.lstDataTableData);
                    console.log('Set New Bundle Picklists BundlePickLists ');
                    console.log('BundlePickLists length: '+resultData.BundlePicklists);
                    //Set New Bundle Picklists BundlePickLists
                    for(var i=0; i<Object.keys(resultData.BundlePicklists).length; i++){
                        var option ={};
                        var picklist = resultData.BundlePicklists;
                        console.log('picklist:'+picklist);
                        option['label']=picklist[Object.keys(picklist)[i]];
                        option['value']=Object.keys(picklist)[i];
                        console.log('picklist:'+Object.keys(picklist));
                        grpoptions.push(option);
                    }
                    //console.log("grpoptions:"+JSON.stringify(grpoptions));
                    component.set('v.groupoptions',grpoptions);
                    console.log('//Set newly created Group visible in picklist');
                    //Set newly created Group visible in picklist
                    component.set('v.bundleoptionselected',resultData.NewBundleCode);
                    component.set('v.iserror', 'false');
                    this.hideSpinner(component);
                                             
                    }else{
                        component.set('v.ErrorMsg','Error Occured While Deleting Rows');
                        component.set('v.iserror','true');
                        this.hideSpinner(component);
                    }
                });
                $A.enqueueAction(action);
                
            }
        } catch(ex){
            console.log('ex: '+ex);
            component.set('v.ErrorMsg','Error Occured While Deleting Rows');
            component.set('v.iserror','true');
            this.hideSpinner(component);
        }
    },
    
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        console.log('entered show spinner');
       // $A.util.removeClass(spinner, "slds-hide");
        component.set("v.Spinner", true); 
    },
    
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        console.log('entered hide spinner');
        //$A.util.addClass(spinner, "slds-hide");
        component.set("v.Spinner", false);
    },
    
    Updatebundle : function(component, event, helper){
        component.set('v.iserror','false');
        this.showSpinner(component);
        try{
        var selrows = component.get('v.selectedRowsCount');
            var mmname = component.get('v.newgroupname');
            var name;
            if(component.get('v.newgroupname')){
               name = component.get('v.newgroupname').trim();
            }else{
                name = component.get('v.newgroupname');
            }
        var qty = component.get('v.quantity');
        var grpoptions = [{'label': 'choose one', 'value': 'choose','selected':'false'},{'label': '--- Create New ---', 'value': 'new','selected':'false'}];
        var groupselected = component.get('v.bundleoptionselected');
        var qtychanged = component.get('v.qtychanged');
        var namechanged = component.get('v.namechanged');
        var unassignedrowscount = component.get('v.unassignedrows');
                
        console.log('entered Addbundle');
        console.log('selrows: '+selrows);
        console.log('marketmodelname: '+name);
        console.log('groupselected: '+groupselected);
        console.log('unassignedrowscount: '+unassignedrowscount);
        
         if(groupselected == 'new' && unassignedrowscount == 0){
            component.set('v.ErrorMsg','All the Line Items are assigned to Market Models');
            component.set('v.iserror','true');
            this.hideSpinner(component);
        }
        else if(groupselected == 'new' && (typeof name === 'undefined' || name =='' || name ==' ' || name == null)) {
                
            component.set('v.ErrorMsg','Please give a name for Flexible Group');
            component.set('v.iserror','true');
            this.hideSpinner(component);
        } else if( groupselected == 'new' && selrows == 0){
            component.set('v.ErrorMsg','Please select at least one Line Item to create Flexible Group');
            component.set('v.iserror','true');
            this.hideSpinner(component);
        } else if(groupselected == 'choose' || groupselected == ''){
            component.set('v.ErrorMsg','Please select Create New option to create groups or select existing groups to update');
            component.set('v.iserror','true');
            this.hideSpinner(component);
        }else if(selrows == 0 && !qtychanged && !namechanged){
            component.set('v.ErrorMsg','Please Select at least one Line Item or change Quantity');
            component.set('v.iserror','true');
            this.hideSpinner(component);
        }else if(qtychanged &&( qty<1||qty>10000)){
            component.set('v.ErrorMsg','Please enter a valid Quantity');
            component.set('v.iserror','true');
            this.hideSpinner(component);
        }else 
        {
            var rows = component.get("v.selectedRows");
            console.log('rows:  '+JSON.stringify(rows));
            var action = component.get('c.updatemarketmodel');
            action.setParams({
                modelname : name,
                modelqty : qty,
                LineitemIdList : rows,
                configId : component.get("v.configId"),
                GrpPicklist : groupselected,
                QtyChanged : qtychanged
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                
                if (state === "SUCCESS" ) {
                    var resultData = response.getReturnValue();
                    console.log('resultData: '+ JSON.stringify(response.getReturnValue()));
                    //Set Table whose Line Items are not assigned to Groups
                    component.set("v.lineitemcolumns", resultData.StandaloneList.lstDataTableColumns);
                    component.set("v.lineitemdata", resultData.StandaloneList.lstDataTableData); 
                    component.set("v.unassignedrows",resultData.StandaloneList.lstDataTableData.length);
                    console.log('Set Bundle component data ');
                    //Set Bundle component data
                    component.set('v.RollupData', resultData.BundleData.rollupdata);
                    component.set('v.bundlecolumns',resultData.BundleData.BundleList.lstDataTableColumns);
                    component.set('v.bundledata',resultData.BundleData.BundleList.lstDataTableData);
                    console.log('Set New Bundle Picklists BundlePickLists ');
                    console.log('BundlePickLists length: '+resultData.BundlePicklists);
                    //Set New Bundle Picklists BundlePickLists
                    for(var i=0; i<Object.keys(resultData.BundlePicklists).length; i++){
                        var option ={};
                        var picklist = resultData.BundlePicklists;
                        console.log('picklist:'+picklist);
                        option['label']=picklist[Object.keys(picklist)[i]];
                        option['value']=Object.keys(picklist)[i];
                        if(Object.keys(picklist)[i] == resultData.BundleData.rollupdata.GroupCode){
                        	option['selected']='true';
                        }else{
                            option['selected']='false';
                        }
                        console.log('picklist:'+Object.keys(picklist));
                        grpoptions.push(option);
                    }
                    console.log("grpoptions:"+JSON.stringify(grpoptions));
                    component.set('v.groupoptions',grpoptions);
                    console.log('//Set newly created Group visible in picklist');
                    //Set newly created Group visible in picklist
                    component.set('v.bundleoptionselected',resultData.NewBundleCode);
                    component.set('v.iserror', 'false');
                    component.set('v.qtychanged','false');
                    this.hideSpinner(component);
                    
                }else{
                        component.set('v.ErrorMsg','Error Occured While Updating Bundle');
                        component.set('v.iserror','true');
                        this.hideSpinner(component);
                    }
            });
            $A.enqueueAction(action);
        }
        }catch(ex){
            console.log('ex: '+ex);
            component.set('v.ErrorMsg','Error Occured While creating bundle :'+ex);
            component.set('v.iserror','true');
            this.hideSpinner(component);
        }
        
    },
    
/*    fetchbundletreedata : function(component, event, helper){
        this.showSpinner(component);
        var action = component.get("c.gethierarchydata");
        console.log('configid: '+component.get("v.configId"));
        action.setParams({
                    configId : component.get("v.configId")
                });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                var treedata = [];
                console.log('resultDatatest: '+JSON.stringify(resultData));
                component.set('v.treecolumns', resultData.lstDataTableColumns);
                for(var i=0; i< resultData.lstDataTableData.length; i++){
                    var wrapperdata = resultData.lstDataTableData[i];
                    if(wrapperdata.isflexiblegroup){
                        var groupname = wrapperdata.childdata[0].CPQ_Market_Model__c;
                        wrapperdata.parentobj['NokiaCPQ_ExtendedPrice_CNP__c'] =  wrapperdata.RollupAmount;
                        wrapperdata.parentobj['NokiaCPQ_Part_Number__c'] = wrapperdata.childdata[0].Flexible_group_code__c;
                        wrapperdata.parentobj['NokiaCPQ_Product_Name__c'] = groupname;
                        wrapperdata.parentobj['_children'] = wrapperdata.childdata;
                        wrapperdata.parentobj['Id']= 'a'+Math.floor(Math.random() * 1000000000);
                        wrapperdata.parentobj['Apttus_Config2__Quantity__c'] = groupname.substring(groupname.lastIndexOf("QTY(") + 4, groupname.lastIndexOf(")"));
                        treedata.push(wrapperdata.parentobj);
                    }else{
                        treedata.push(wrapperdata.parentobj);
                    }
                }
                console.log('treedata: '+JSON.stringify(treedata));
                component.set('v.treedata',treedata);
                }else if (component.isValid() && state === "ERROR") {
                    component.set('v.ErrorMsg','Error Occured While Updating Bundle');
                    component.set('v.iserror','true');
                    this.hideSpinner(component);
                    console.log('resultDatatest is error: ');
                    
                }
        });
        $A.enqueueAction(action);
    },*/
    
    fetchhierarchydata : function(component, event, helper){
        
        var action = component.get("c.gethierarchydatafixedcol");
        console.log('configid: '+component.get("v.configId"));
        action.setParams({
                    configId : component.get("v.configId")
                });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                console.log('resultDatatest: '+JSON.stringify(resultData));
                component.set('v.treecolumns', resultData.lstDataTableColumns);
                var stringdata1 = JSON.stringify(resultData.lstDataTableData).replace(/childrenwrapper/g, '_children');
                var stringdata2 = stringdata1.replace(/Apttus_Config2_Quantity/g, 'Apttus_Config2__Quantity');
                console.log('stringdata2'+stringdata2);
                component.set('v.treedata',JSON.parse(stringdata2));
                component.set('v.gridExpandedRows',resultData.expandedrowslist);
                component.set("v.Spinner2", false); 
            }else{
                component.set('v.ErrorMsg','Error Occured While Updating Bundle');
                    component.set('v.iserror','true');
                    component.set("v.Spinner2", false); 
                    console.log('resultDatatest is error: ');
            }
        });
	$A.enqueueAction(action);
    }
})