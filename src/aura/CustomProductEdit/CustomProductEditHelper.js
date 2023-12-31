({
    callDoInt : function(component, event, helper) {
        var action = component.get("c.getLineItemValue");
        action.setParams({
            'strProductId': component.get("v.strProductID"),
            'strConfigId': component.get("v.strConfigId")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var  storeResponse = response.getReturnValue();
                component.set("v.wrapper",storeResponse);
                component.set("v.productcode", storeResponse.strProductCode);
                //  alert(storeResponse.strPortfolio);
                
                if(storeResponse.strPortfolio != "IP Routing")
                {
                    component.find("NFM").set("v.class" , 'slds-hide');
                    component.find("idSSP").set("v.class" , 'slds-hide');
                    component.set("v.isSSP",false);
                }

            }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        
    },
	
	getQuoteType : function(component, event, helper){
        
       var action = component.get("c.getProductConfig");
       action.setParams({
            'strConfigId': component.get("v.strConfigId")
           });
        
         action.setCallback(this, function(response) {
             
            var state = response.getState();
            if (state === "SUCCESS") {
                 
                var  storeResponse = response.getReturnValue(); 
                 component.set("v.quoteType",storeResponse.Quote_Type__c);
                 
             }
             
         });
        $A.enqueueAction(action);
      
    },
    
    Validation : function(component, event, helper) {
        if(isNaN(component.find("idQuantity").get("v.value")) || component.find("idQuantity").get("v.value") < 0 )
        {
            component.set("v.has_error", true);
            component.set("v.errors", 'Error : Please enter Numberic value in '+component.find("idQuantity").get("v.label"));
            component.set("v.showSpinner", false);
            return false;
        }
        if(isNaN(component.find("idMantY1").get("v.value")) || component.find("idMantY1").get("v.value") < 0 )
        {
            component.set("v.has_error", true);
            component.set("v.errors", 'Error : Please enter Numberic value in '+component.find("idMantY1").get("v.label"));
            component.set("v.showSpinner", false);
            return false;
        }
        if(isNaN(component.find("idMantY2").get("v.value")) || component.find("idMantY2").get("v.value") < 0)
        {
            component.set("v.has_error", true);
            component.set("v.errors", 'Error : Please enter Numberic value in '+component.find("idMantY2").get("v.label"));
            component.set("v.showSpinner", false);
            return false;
        }
        if(isNaN(component.find("idListPrice").get("v.value")) || component.find("idListPrice").get("v.value") < 0)
        {
            component.set("v.has_error", true);
            component.set("v.errors", 'Error : Please enter Numberic value in '+component.find("idListPrice").get("v.label"));
            component.set("v.showSpinner", false);
            return false;
        }
        if(isNaN(component.find("idSSP").get("v.value")) || component.find("idSSP").get("v.value") < 0 )
        {
            component.set("v.has_error", true);
            component.set("v.errors", 'Error : Please enter Numberic value in '+component.find("idSSP").get("v.label"));
            component.set("v.showSpinner", false);
            return false;
        }
        if(isNaN(component.find("idPDC").get("v.value")) || component.find("idPDC").get("v.value") < 0)
        {
            component.set("v.has_error", true);
            component.set("v.errors", 'Error : Please enter Numberic value in '+component.find("idSSP").get("v.label"));
            component.set("v.showSpinner", false);
            return false;
        }
        return true;
    },
    
    setLIValues : function(component, event, helper) {
        console.log("inhlerp statr");
        var  vWrapper =   component.get("v.wrapper"); 
        
        component.set("v.showSpinner", true);
        var fields = event.getParam('fields');
        event.preventDefault();
        fields.Apttus_Config2__Quantity__c =component.find("idQuantity").get("v.value");
        if(! $A.util.isEmpty(component.get("v.strProductID")))
        {   
            fields.Apttus_Config2__ProductId__c = vWrapper.strProductID;
            fields.Custom_Product_Name__c = vWrapper.strProductName;
            fields.Custom_Product_Code__c = vWrapper.strProductCode;
            fields.Apttus_Config2__Description__c =  vWrapper.strProductName;
			fields.NokiaCPQ_CustomProductPDC__c =  vWrapper.strPdc;
            
        }else
        {
            fields.Apttus_Config2__ProductId__c =  vWrapper.strProductID;
            fields.Custom_Product_Name__c = component.find("prodname").get("v.value");
            fields.Custom_Product_Code__c =  component.find("prodCode").get("v.value");
            fields.Apttus_Config2__Description__c =  component.find("prodname").get("v.value");
        }
        
        fields.Apttus_Config2__LineNumber__c = vWrapper.iLineNumber + 1;
        fields.Apttus_Config2__PrimaryLineNumber__c = vWrapper.iPrimaryLineNumber +1  ;
        fields.Apttus_Config2__ItemSequence__c = vWrapper.iItemSequence + 1;
        fields.NokiaCPQAccreditationType__c = vWrapper.strPricingAccred;
        fields.Apttus_Config2__ConfigurationId__c = component.get("v.strConfigId");
        fields.Apttus_Config2__LineType__c = 'Product/Service';
        fields.Apttus_Config2__ListPrice__c =  component.find("idListPrice").get("v.value") ;
		
		 if(component.get("v.quoteType") != 'Direct CPQ'){
             fields.Nokia_CPQ_Maint_Prod_Cat_Disc__c = component.find("idPDC").get("v.value");
            
        }
        if(component.get("v.quoteType") == 'Direct CPQ'){
             fields.NokiaCPQ_Unitary_IRP__c =  fields.Apttus_Config2__ListPrice__c;
			 fields.NokiaCPQ_Alias__c = fields.Custom_Product_Name__c;
           if(! component.get("v.isNetwork")){
            fields.NokiaCPQ_SSP_Rate__c = component.find("idSSP").get("v.value");
           }else{
            fields.NokiaCPQ_SRS_Rate__c = vWrapper.dSRSPercentage;
           }
        }
		
        
        fields.Nokia_Maint_Y1_Per__c = component.find("idMantY1").get("v.value");
        fields.NokiaCPQ_Maint_Y1_List_Price__c = (fields.Apttus_Config2__ListPrice__c * fields.Nokia_Maint_Y1_Per__c) /100 ;
        fields.NokiaCPQ_Maint_Yr1_Base_Price__c = fields.NokiaCPQ_Maint_Y1_List_Price__c ;
        fields.NokiaCPQ_Maint_Yr1_Extended_Price__c = ( (fields.Apttus_Config2__ListPrice__c * fields.Apttus_Config2__Quantity__c)* fields.Nokia_Maint_Y1_Per__c) /100  ;
        fields.Nokia_Maint_Y1_Extended_List_Price__c = fields.NokiaCPQ_Maint_Yr1_Extended_Price__c;
        fields.Apttus_Config2__BasePriceMethod__c = 'Per Unit';
        //defect 13944,14075
        if(vWrapper.str1Year== '1' && (component.get("v.quoteType") == 'Indirect CPQ')){
            fields.Nokia_Maint_Y2_Per__c = 0.0;
        }
        else{
        fields.Nokia_Maint_Y2_Per__c = component.find("idMantY2").get("v.value");
        }
        fields.NokiaCPQ_Maint_Yr2_List_Price__c = (fields.Apttus_Config2__ListPrice__c * fields.Nokia_Maint_Y2_Per__c)/100
        fields.NokiaCPQ_Maint_Yr2_Extended_Price__c = ((fields.Apttus_Config2__ListPrice__c * fields.Apttus_Config2__Quantity__c) * fields.Nokia_Maint_Y2_Per__c)/100 ;
        fields.NokiaCPQ_Maint_Yr2_Extended_List_Price__c = fields.NokiaCPQ_Maint_Yr2_Extended_Price__c
        fields.NokiaCPQ_Maint_Yr2_Base_Price__c = fields.NokiaCPQ_Maint_Yr2_List_Price__c;
        
        if($A.util.isEmpty(fields.Nokia_CPQ_Maint_Prod_Cat_Disc__c) && $A.util.isEmpty(vWrapper.strAccredDiscount))
            fields.Apttus_Config2__BasePrice__c = fields.Apttus_Config2__ListPrice__c ;
        
        else if(! $A.util.isEmpty(fields.Nokia_CPQ_Maint_Prod_Cat_Disc__c) && $A.util.isEmpty(vWrapper.strAccredDiscount))
            fields.Apttus_Config2__BasePrice__c = fields.Apttus_Config2__ListPrice__c- (fields.Apttus_Config2__ListPrice__c * fields.Nokia_CPQ_Maint_Prod_Cat_Disc__c)/100;
        
            else if($A.util.isEmpty(fields.Nokia_CPQ_Maint_Prod_Cat_Disc__c) && ! $A.util.isEmpty(vWrapper.strAccredDiscount))
                fields.Apttus_Config2__BasePrice__c = fields.Apttus_Config2__ListPrice__c - (fields.Apttus_Config2__ListPrice__c * vWrapper.strAccredDiscount)/100;
        
                else if(! $A.util.isEmpty(fields.Nokia_CPQ_Maint_Prod_Cat_Disc__c) &&  ! $A.util.isEmpty(vWrapper.strAccredDiscount))
                {
                    fields.Apttus_Config2__BasePrice__c = fields.Apttus_Config2__ListPrice__c - (fields.Apttus_Config2__ListPrice__c * vWrapper.strAccredDiscount)/100;
                    fields.Apttus_Config2__BasePrice__c = fields.Apttus_Config2__BasePrice__c - (fields.Apttus_Config2__BasePrice__c * fields.Nokia_CPQ_Maint_Prod_Cat_Disc__c)/100;
                }
        
		if(! $A.util.isEmpty(vWrapper.iIncotermPercentage))
        {
            fields.Apttus_Config2__BasePrice__c = fields.Apttus_Config2__BasePrice__c + (fields.Apttus_Config2__BasePrice__c * vWrapper.iIncotermPercentage)/100;
        }
		
        fields.Apttus_Config2__BasePriceOverride__c = fields.Apttus_Config2__BasePrice__c ;
		fields.NokiaCPQ_IncotermNew__c = vWrapper.iIncotermPercentage;
        fields.Apttus_Config2__PriceListId__c = vWrapper.strGlobalPriceListID
        fields.Apttus_Config2__PriceListItemId__c = vWrapper.strGlobalPriceListItemID
        fields.Apttus_Config2__BaseExtendedPrice__c = fields.Apttus_Config2__BasePrice__c * fields.Apttus_Config2__Quantity__c;
        fields.Apttus_Config2__ExtendedPrice__c = fields.Apttus_Config2__BasePrice__c * fields.Apttus_Config2__Quantity__c; 
        fields.Apttus_Config2__NetPrice__c = fields.Apttus_Config2__BasePrice__c * fields.Apttus_Config2__Quantity__c;
        fields.Apttus_Config2__NetUnitPrice__c = fields.Apttus_Config2__BasePrice__c ;
        fields.Apttus_Config2__PriceUom__c ='Each';
        fields.Apttus_Config2__Frequency__c = 'One Time';	
        fields.Apttus_Config2__Frequency__c = 'One Time';	
        
        fields.Apttus_Config2__PricingStatus__c = 'Pending';
        fields.is_Custom_Product__c = true;
        fields.Apttus_Config2__ConfigStatus__c = 'NA';
        fields.Apttus_Config2__IsPrimaryLine__c = true;
        fields.Apttus_Config2__ChargeType__c = 'Standard Price';
        
        if(! component.get("v.isNetwork"))
        {        //SSP fields population
            //alert('Inside SSP');
			if(vWrapper.isLEO== true){
				fields.Nokia_SSP_List_Price__c = 0.0;
			}
			else{
            fields.Nokia_SSP_List_Price__c =  (fields.Apttus_Config2__ListPrice__c * component.find("idSSP").get("v.value"))/100; 
			}
            if(! $A.util.isEmpty(fields.Nokia_CPQ_Maint_Prod_Cat_Disc__c))
                fields.Nokia_SSP_Base_Price__c =  fields.Nokia_SSP_List_Price__c  - (fields.Nokia_SSP_List_Price__c * fields.Nokia_CPQ_Maint_Prod_Cat_Disc__c) /100;
            else
                fields.Nokia_SSP_Base_Price__c = fields.Nokia_SSP_List_Price__c;
            fields.Nokia_SSP_Base_Extended_Price__c = fields.Nokia_SSP_Base_Price__c * fields.Apttus_Config2__Quantity__c;
        }else
        {
            fields.Nokia_SRS_List_Price__c = (fields.Apttus_Config2__ListPrice__c * vWrapper.dSRSPercentage);
			fields.IsNFMP_Custom_Product__c = true;
            console.log('fields.Nokia_SRS_List_Price__c'+fields.Nokia_SRS_List_Price__c);
            if(! $A.util.isEmpty(fields.Nokia_CPQ_Maint_Prod_Cat_Disc__c))
                fields.Nokia_SRS_Base_Price__c = fields.Nokia_SRS_List_Price__c - (fields.Nokia_SRS_List_Price__c * fields.Nokia_CPQ_Maint_Prod_Cat_Disc__c)/100;
            else 
                fields.Nokia_SRS_Base_Price__c = fields.Nokia_SRS_List_Price__c;
            console.log('fields.Nokia_SRS_Base_Price__c'+fields.Nokia_SRS_Base_Price__c);
            fields.Nokia_SRS_Base_Extended_Price__c = fields.Nokia_SRS_Base_Price__c * fields.Apttus_Config2__Quantity__c;
        }
        fields.Apttus_Config2__NetUnitPrice__c = fields.Apttus_Config2__BasePrice__c ;
        fields.Apttus_Config2__ProductVersion__c = 1.0;
        fields.Source__c ='Custom Product';
        fields.CustomProductValue__c = fields.Apttus_Config2__ListPrice__c +';'+fields.Apttus_Config2__BasePrice__c +';'+ fields.Apttus_Config2__BasePriceOverride__c;
        console.log("inhlerp end");
        component.find('myRecordForm').submit(fields);
    },
    
    /*createMaint : function(component, event, helper) {
         
        var action = component.get("c.createMaint");
        
        action.setParams({
            'ProductConfigId': component.get("v.strConfigId"),
            'blIsNetwork' : component.get("{!v.isNetwork}")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
           //  alert('state'+state);
            if (state === "SUCCESS") {
                
                var cmpEvent = component.getEvent("ShowModalevt"); 
                
                component.set("v.showSpinner", false);
                component.set("v.showModal", false);
                //console.log(event.getparams());
                var cmpEvent = component.getEvent("ShowModalevt"); 
                cmpEvent.setParams({ "ShowMessage" : true,"ShowParentModal" : true}); 
                cmpEvent.fire(); 
                
            }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        
    },*/
    
})