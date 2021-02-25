({    
    doInit : function(component, event, helper) {        
        var qId = component.get("v.recordId");
        var action = component.get("c.getProposal");
        action.setParams({
            "proposalId": qId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.proposal", response.getReturnValue());
                console.log('Apoorv Jain'+component.get("v.proposal.NokiaCPQ_Environment_Access_Type__c"));
				  helper.ValidateCqorderButtonhelper(component, event, helper);
            }
        });
        $A.enqueueAction(action);
        
        var newAction = component.get("c.returnProfileName");        
        newAction.setCallback(this, function(response){            
            if(response.getState()==="SUCCESS"){
                component.set("v.profileName",response.getReturnValue());
            }
        });
        $A.enqueueAction(newAction);
        
        var newAction1 = component.get("c.returnAccessLoaFile");        
        newAction1.setCallback(this, function(response){            
            if(response.getState()==="SUCCESS"){
                component.set("v.loaAccess",response.getReturnValue());
            }
        });
        $A.enqueueAction(newAction1);
        
        var newAction2 = component.get("c.isPricingManager");
		newAction2.setCallback(this, function(response){            
            if(response.getState()==="SUCCESS"){
                component.set("v.isPricingManager",response.getReturnValue());
                console.log('isPricingManager>>>'+response.getReturnValue());        
            }
        });
        
        $A.enqueueAction(newAction2);        
    },
    makePrimary : function(component, event, helper) {        
        var action = component.get("c.makePrimaryMethod");        
        action.setParams({"recordIdVar":component.get("v.recordId")});        
        action.setCallback(this,function(response){            
            if(response.getState()=="SUCCESS"){
                var link = response.getReturnValue();
                window.open(link,"_self");
            }
            $A.get('e.force:refreshView').fire();
        });
        
        $A.enqueueAction(action);
    },    
    bomExport : function(component, event, helper) {        
        var action = component.get("c.bomExportMethod");        
        action.setParams({"recordIdVar" : component.get("v.recordId")});        
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS"){
                var link= response.getReturnValue();
                window.open(link,"_self");
            }            
        });
        
        $A.enqueueAction(action);
    },    
    quoteExport : function(component, event, helper) {        
        var action = component.get("c.quoteExportMethod");        
        action.setParams({"recordIdVar":component.get("v.recordId")});        
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                var link = response.getReturnValue();
                window.open(link,"_self");
            }            
        });
        
        $A.enqueueAction(action);
    },
    //RG Start:Renamed for Req-6611
	baiscquoteExport : function(component, event, helper) {        
        var action = component.get("c.basicquoteExportMethod");        
        action.setParams({"recordIdVar":component.get("v.recordId")});        
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                var link = response.getReturnValue();
                window.open(link,"_self");
            }            
        });
        
        $A.enqueueAction(action);
    }, 
 	//RG End:Renamed for Req-6611  
 	//RG start for Approval Process
 	submitforApproval : function(component, event, helper) {        
        var action = component.get("c.submitForApprovalMethod");        
        action.setParams({"recordIdVar":component.get("v.recordId")});        
        action.setCallback(this,function(response){
             if(response.getState()==="SUCCESS"){
                var link = response.getReturnValue();
                window.open(link,"_self");
            }
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    }, 
    recallforApproval : function(component, event, helper) { 
        var filePath;
        var recId = component.get("v.recordId");
        filePath = '/apex/Apttus_Approval__PreviewSubmitApprovals?id='+recId;
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('/', 14));        
        console.log('>>>'+baseURL+filePath);        
        var link=baseURL+filePath;
        window.open(link,"_self"); 
    },
 	//RG end for Approval Process 
    acceptProposal : function(component, event, helper) {        
        var action = component.get("c.acceptMethod");        
        action.setParams({"recordIdVar":component.get("v.recordId")});        
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                var link = response.getReturnValue();
                window.open(link,"_self");
            }
            $A.get('e.force:refreshView').fire();
        });
        
        $A.enqueueAction(action);
    },        
    configureProductsDirect : function(component, event, helper) {        
        var action = component.get("c.configureMethodDirect");        
        action.setParams({"recordIdVar":component.get("v.recordId")});        
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                var link = response.getReturnValue();
                window.open(link,"_self");
            }            
        });
        
        $A.enqueueAction(action);
    },    
    configureProductsMNDirect : function(component, event, helper) {        
        var filePath;
        var recId = component.get("v.recordId");
        var isPricingManager = component.get("v.isPricingManager");        
        if(isPricingManager === true){
        	filePath = '/apex/Apttus_QPConfig__ProposalConfiguration?id='+recId+'&flow=GridViewCartMNDirectPricing&cntrNbr_1='+component.get("v.proposal.Direct_Price_List_Number__c");    
        }else {
			filePath = '/apex/Apttus_QPConfig__ProposalConfiguration?id='+recId+'&flow=GridViewCartMNDirect&cntrNbr_1='+component.get("v.proposal.Direct_Price_List_Number__c");            
        }
        
        var url = location.href;  // entire url including querystring - also: window.location.href;
        var baseURL = url.substring(0, url.indexOf('/', 14));        
        console.log('>>>'+baseURL+filePath);        
        var link= baseURL+filePath;
        window.open(link,"_self"); 
    },    
    configureProducts : function(component, event, helper) {        
        var action = component.get("c.configureMethod");        
        action.setParams({"recordIdVar" : component.get("v.recordId")});        
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                var link = response.getReturnValue();                
                window.open(link,"_self");                
            }            
        });
        
        $A.enqueueAction(action);
    },    
    viewProducts : function(component, event, helper){        
        var action = component.get("c.viewProductsMethod");        
        action.setParams({"recordIdVar" : component.get("v.recordId")});        
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS"){
                var link= response.getReturnValue();
                window.open(link,"_self");
            }            
        });
        
        $A.enqueueAction(action);
    },    
    viewProductsDirect : function(component, event, helper){        
        var action = component.get("c.viewProductsDirectMethod");        
        action.setParams({"recordIdVar" : component.get("v.recordId")});        
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS"){
                var link= response.getReturnValue();
                window.open(link,"_self");
            }            
        });
        
        $A.enqueueAction(action);
    },    
    viewProductsMNDirect : function(component, event, helper){        
        var recId = component.get("v.recordId");
        var filePath = '/apex/Apttus_QPConfig__ProposalConfiguration?id='+recId+'&flow=GridViewCartMNDirect&cntrNbr_1='+component.get("v.proposal.Direct_Price_List_Number__c")+'&mode=readOnly';
        var url = location.href;  // entire url including querystring - also: window.location.href;
        var baseURL = url.substring(0, url.indexOf('/', 14));        
        console.log('>>>'+baseURL+filePath);        
        var link= baseURL+filePath;
        window.open(link,"_self");
    },
    
    collaboration : function(component, event, helper){        
        var action = component.get("c.configureCollaboration");        
        action.setParams({"recordIdVar" : component.get("v.recordId")});        
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS"){
                var link= response.getReturnValue();
                window.open(link,"_self");
            }            
        });
        
        $A.enqueueAction(action);
    },    
    boqExport : function(component, event, helper){
        var generateSiteIdAction = component.get("c.generateSiteId");
        generateSiteIdAction.setParams({
            "proposalId": component.get("v.recordId")
        });
        generateSiteIdAction.setCallback(this, function(response){            
            console.log('>>Output from apex class:::::'+response.getReturnValue());
            if(response.getState()==="SUCCESS"){
                var messageResult = response.getReturnValue();
                console.log('messageResult1'+messageResult);
                if(messageResult==='SUCCESS'){
                    var toastTitle = 'Success';
                    var toastType = 'Success';
                    var toastMessage = 'Line Item Updated successfully !';
                    var action = component.get("c.boqExportreturn");        
                    action.setParams({"recordIdVar" : component.get("v.recordId")});        
                    action.setCallback(this, function(response){
                        if(response.getState()==="SUCCESS"){
                            var link= response.getReturnValue();
                            window.open(link,"_self");
                        }            
                    });
                    $A.enqueueAction(action);
                }
                else {
                    // toast message
                    console.log('>>messageResult:::::'+messageResult);
                    var toastTitle = 'Error';
                    var toastType = 'Error';
                    helper.toastMessage(component, event, helper, toastTitle, messageResult, toastType);
                }
            }
        });
        $A.enqueueAction(generateSiteIdAction);
    },    
    boqClpExport : function(component, event, helper){
        var generateSiteIdAction = component.get("c.generateSiteId");
        generateSiteIdAction.setParams({
            "proposalId": component.get("v.recordId")
        });
        generateSiteIdAction.setCallback(this, function(response){            
            console.log('>>Output from apex class:::::'+response.getReturnValue());
            if(response.getState()==="SUCCESS"){
                var messageResult = response.getReturnValue();
                console.log('messageResult1'+messageResult);
                if(messageResult==='SUCCESS'){
                    var toastTitle = 'Success';
                    var toastType = 'Success';
                    var toastMessage = 'Line Item Updated successfully !';
                    var action = component.get("c.boqClpExportReturn");        
                    action.setParams({"recordIdVar" : component.get("v.recordId")});        
                    action.setCallback(this, function(response){
                        if(response.getState()==="SUCCESS"){
                            var link= response.getReturnValue();
                            window.open(link,"_self");
                        }            
                    });
                    
                    $A.enqueueAction(action);
                }
                else {
                    // toast message
                    console.log('>>messageResult:::::'+messageResult);
                    var toastTitle = 'Error';
                    var toastType = 'Error';
                    helper.toastMessage(component, event, helper, toastTitle, messageResult, toastType);
                }
            }
        });
        $A.enqueueAction(generateSiteIdAction);
    },    
    prmExport : function(component, event, helper){        
        var action = component.get("c.prmExportFunction");        
        action.setParams({"recordIdVar" : component.get("v.recordId")});        
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS"){
                var link= response.getReturnValue();
                window.open(link,"_self");
            }            
        });
        
        $A.enqueueAction(action);
    },    
    loaFileExport : function(component, event, helper){        
        var action = component.get("c.loaFileExportFunction");        
        action.setParams({"recordIdVar" : component.get("v.recordId")});        
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS"){
                var link= response.getReturnValue();
                window.open(link,"_self");
            }            
        });
        
        $A.enqueueAction(action);
    }, 
    // CSP Export     
    startOrderExportForCSP : function(component, event, helper) {
        var generateSiteIdAction = component.get("c.generateSiteId");
        generateSiteIdAction.setParams({
            "proposalId": component.get("v.recordId")
        });
        generateSiteIdAction.setCallback(this, function(response){            
            console.log('>>Output from apex class:::::'+response.getReturnValue());
            if(response.getState()==="SUCCESS"){
                var messageResult = response.getReturnValue();
                console.log('messageResult1'+messageResult);
                if(messageResult==='SUCCESS'){
                    var toastTitle = 'Success';
                    var toastType = 'Success';
                    var toastMessage = 'Line Item Updated successfully !';
                    helper.fireEventCPQ_Evt_ToCallStatusCheck(component, event, helper, 'CSP Export');
                }
                else {
                    // toast message
                    console.log('>>messageResult:::::'+messageResult);
                    var toastTitle = 'Error';
                    var toastType = 'Error';
                    helper.toastMessage(component, event, helper, toastTitle, messageResult, toastType);
                }
            }
        });
        $A.enqueueAction(generateSiteIdAction);
    },
    //Alliance Export
    startOrderExportForAlliance : function(component, event, helper) {
        var generateSiteIdAction = component.get("c.generateSiteId");
        generateSiteIdAction.setParams({
            "proposalId": component.get("v.recordId")
        });
        generateSiteIdAction.setCallback(this, function(response){            
            console.log('>>Output from apex class:::::'+response.getReturnValue());
            if(response.getState()==="SUCCESS"){
                var messageResult = response.getReturnValue();
                console.log('messageResult1'+messageResult);
                if(messageResult==='SUCCESS'){
                    var toastTitle = 'Success';
                    var toastType = 'Success';
                    var toastMessage = 'Line Item Updated successfully !';
                    helper.fireEventCPQ_Evt_ToCallStatusCheck(component, event, helper, 'Alliance Export');
                }
                else {
                    // toast message
                    console.log('>>messageResult:::::'+messageResult);
                    var toastTitle = 'Error';
                    var toastType = 'Error';
                    helper.toastMessage(component, event, helper, toastTitle, messageResult, toastType);
                }
            }
        });
        $A.enqueueAction(generateSiteIdAction);
    },    
    // QTC export
    startOrderExportForQTC : function(component, event, helper) {
        var generateSiteIdAction = component.get("c.generateSiteId");
        generateSiteIdAction.setParams({
            "proposalId": component.get("v.recordId")
        });
        generateSiteIdAction.setCallback(this, function(response){            
            console.log('>>Output from apex class:::::'+response.getReturnValue());
            if(response.getState()==="SUCCESS"){
                var messageResult = response.getReturnValue();
                console.log('messageResult1'+messageResult);
                if(messageResult==='SUCCESS'){
                    var toastTitle = 'Success';
                    var toastType = 'Success';
                    var toastMessage = 'Line Item Updated successfully !';
                    helper.fireEventCPQ_Evt_ToCallStatusCheck(component, event, helper, 'QTC SURROUND Export');
                }
                else {
                    // toast message
                    console.log('>>messageResult:::::'+messageResult);
                    var toastTitle = 'Error';
                    var toastType = 'Error';
                    helper.toastMessage(component, event, helper, toastTitle, messageResult, toastType);
                }
            }
        });
        $A.enqueueAction(generateSiteIdAction);
    },    
    // QTC SITE export
    startOrderExportForQTCSite : function(component, event, helper) { 
        var generateSiteIdAction = component.get("c.generateSiteId");
        generateSiteIdAction.setParams({
            "proposalId": component.get("v.recordId")
        });
        generateSiteIdAction.setCallback(this, function(response){            
            console.log('>>Output from apex class:::::'+response.getReturnValue());
            if(response.getState()==="SUCCESS"){
                var messageResult = response.getReturnValue();
                console.log('messageResult1'+messageResult);
                if(messageResult==='SUCCESS'){
                    var toastTitle = 'Success';
                    var toastType = 'Success';
                    var toastMessage = 'Line Item Updated successfully !';
                    helper.fireEventCPQ_Evt_ToCallStatusCheck(component, event, helper, 'QTC SITE Export');
                }
                else {
                    // toast message
                    console.log('>>messageResult:::::'+messageResult);
                    var toastTitle = 'Error';
                    var toastType = 'Error';
                    helper.toastMessage(component, event, helper, toastTitle, messageResult, toastType);
                }
            }
        });
        $A.enqueueAction(generateSiteIdAction);
    },
    // handle the product status check event and execute order export
    handleProductStatusCheckEvent: function(component, event, helper) {        
        var orderExportName = event.getParam("orderExportName");        
        console.log('orderExportName>>>'+orderExportName);
                
        var toastTitle = 'Information';
        var toastType = 'Information';
        var toastMessage = orderExportName + ' is in progress. Kindly wait for further instruction!';
        helper.toastMessage(component, event, helper, toastTitle, toastMessage, toastType);
                
        if(orderExportName === "Alliance Export"){
        	helper.executeAllianceExport(component, event, helper);
        }
        else if(orderExportName === "QTC SITE Export"){
            helper.executeQTCSiteExport(component, event, helper);
        }
        else if(orderExportName === "QTC SURROUND Export"){
            helper.executeQTCExport(component, event, helper);
        }
        else if(orderExportName === "CSP Export"){
            helper.cspExport(component, event, helper);
        }
        else if(orderExportName === "Reconciliation Export"){
            helper.generateReconciliationFile(component, event, helper);
            
        }
    },
	
	// Add Quote Message
    sendAddQuoteMessage : function(component, event, helper) {        
        helper.sendAddQuoteMessageToEAI(component, event, helper);
    },
	 
	 CQOrderDocExporthandler : function(component, event, helper) { 
        helper.CQOrderDocExporthelper(component, event, helper,"CQ Order Document");
    }, 
    CQOrderDocExportWithoutChildhandler : function(component, event, helper) { 
        helper.CQOrderDocExporthelper(component, event, helper,"CQ Order Doc-Without Child records");
    },
    startReconciliationExport : function(component, event, helper) { 
        var generateReconciliationExportAction = component.get("c.generateReconciliationExport");
        generateReconciliationExportAction.setParams({
            "proposalId": component.get("v.recordId")
        });
        generateReconciliationExportAction.setCallback(this, function(response){            
            console.log('>>Output from apex class:::::'+response.getReturnValue());
            if(response.getState()==="SUCCESS"){
                var messageResult = response.getReturnValue();
                console.log('messageResult1'+messageResult);
                if(messageResult==='SUCCESS'){
                   // helper.generateReconciliationFile(component, event, helper);
                    helper.fireEventCPQ_Evt_ToCallStatusCheck(component, event, helper, 'Reconciliation Export');
					var toastTitle = 'Success';
                    var toastType = 'Success';
                    var toastMessage = 'Line Item Updated successfully !';
                }
                else {
                    // toast message
                    console.log('>>messageResult:::::'+messageResult);
                    var toastTitle = 'Error';
                    var toastType = 'Error';
                    helper.toastMessage(component, event, helper, toastTitle, messageResult, toastType);
                }
            }
        });
        $A.enqueueAction(generateReconciliationExportAction);
    },
     
})