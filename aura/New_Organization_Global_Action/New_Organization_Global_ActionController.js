({
	doInit : function(component, event, helper) {
        $A.createComponent(
            "ui:message",{
                "title": "Please wait while we redirecting to your page",
                "severity": "warning"
            },
            function(components,status,statusMessagesList){
                if (status === "SUCCESS") {
                    var div1 = component.find("NewOrganization");
                    div1.set("v.body", components);
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": location.origin +"/apex/NewOrganization"
                    });
                    urlEvent.fire();
                    
                    if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    helper.showMessage(component, event,'Success','No response from server or client is offline.');
                }else if (status === "ERROR") {
                    console.log("Error: " + statusMessagesList);
                }
            }
        );
    },
})