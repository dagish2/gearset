({
    doInit : function(component, event, helper) {
        component.set("v.utils", component.find("utils"));
        component.get("v.utils").showProcessing();
        component.get("v.utils").execute("c.getOpportunityData",{"opportunityId":component.get("v.recordId")},function(response){
            var messageReturned = JSON.parse(response);
            var redirectURL = window.location.href.includes('?')?window.location.href.split('?')[0]:window.location.href;
            if(messageReturned.Success == true){ 
                if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                    $A.get("e.force:closeQuickAction").fire();
                    window.open(messageReturned.Message+redirectURL, "_blank");
                }
            }else{
                component.get("v.utils").hideProcessing();
                component.set("v.message", messageReturned.Message);                  
            }
        },function(error){
            component.get("v.utils").hideProcessing();
            component.set("v.message", error);
        }, component);
    },
    close:function(component, event, helper){
        component.get("v.utils").closeTab(); 
    }
})