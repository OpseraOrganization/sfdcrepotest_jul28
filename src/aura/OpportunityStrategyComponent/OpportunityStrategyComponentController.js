({
    /*init : function(component, event, helper){
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS' && result != null)
            {
               let fields =["Customer_Request__c","Expected_Contract_T_and_Cs__c","Selection_Criteria_Ability_to_influence__c",
                            "High_level_Solution_Installed_base__c","StrategicContextCompetitiveSituation__c","Solution_fit_to_requirements__c"];
                            
                for(let i = 0; i < fields.length; i++)
                {
                    result[fields[i]] == null?'':result[fields[i]];
                    console.log("result for: "+result[fields[i]]);
                }

                component.set("v.opp",result);
                console.log("v.opp --> "+ JSON.stringify(component.get("v.opp")));
            }
    */

    init : function(component, event, helper){
        
        console.log("v.viewMode -- "+component.get("v.viewMode"));
        console.log("v.userAllowed -- "+component.get("v.userAllowed"));

        var action = component.get("c.allowedUserToEdit");
        
        action.setParams({
            recordId : component.get("v.recordId")
        });        
        

        action.setCallback(this, function(response){
            var result = response.getReturnValue();            
            if(response.getState()==='SUCCESS' && result != null)
            {
                component.set("v.userAllowed",result);
                console.log('v.userAllowedINIT --> '+result);
            }
        })
        $A.enqueueAction(action);
    },
    edit: function(component, event){
        component.set("v.viewMode",false);
    },
    cancel: function(component, event, helper){
        component.set("v.viewMode",true);	
    },
    handleSave : function(component, event, helper) {
        component.find("form1").submit();
        component.find("form2").submit();
        component.find("form3").submit();
        component.set("v.viewMode",true);
        $A.get('e.force:refreshView').fire(); 
    },
    toggleSection1: function(component, event) {        
        var section1 = component.find('section1');
        if(component.get("v.viewMode")==true)
            $A.util.toggleClass(section1, 'slds-is-open');
        else        
            $A.util.addClass(section1, 'slds-is-open');
    },
    toggleSection2: function(component, event) {
        var section2 = component.find('section2');
        if(component.get("v.viewMode")==true)
        {        
            $A.util.toggleClass(section2, 'slds-is-open');
        }
        else        
            $A.util.addClass(section2, 'slds-is-open');
    },
    toggleSection3: function(component, event) {
        var section3 = component.find('section3');
        if(component.get("v.viewMode")==true)
        {            
            $A.util.toggleClass(section3,'slds-is-open');
        }
        else
            $A.util.addClass(section3,'slds-is-open');
    },
    toggleSection4: function(component, event) {
        var section4 = component.find('section4');
        $A.util.toggleClass(section4, 'slds-is-open');
    }
});