({
    doInit : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": location.origin +"/apex/ConvertToReferral"
        });
        urlEvent.fire();
        
        if($A.get("e.force:closeQuickAction").getSource().isValid()) {
            $A.get("e.force:closeQuickAction").fire();
        }
    },
})