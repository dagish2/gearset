({
    doInit : function(component, event, helper) {   
        if($A.get("e.force:closeQuickAction").getSource().isValid()) {
            $A.get("e.force:closeQuickAction").fire();
        }
        helper.getData(component, helper);
    }
})