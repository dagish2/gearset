({
    doInit : function(component, event, helper) {
        $A.createComponent(
            "ui:message",{
                "title": "Please wait while we redirect to your page",
                "severity": "warning"
            },
            function(components,status,statusMessagesList){
                switch(status){
                    case "SUCCESS":
                        var requestNewOrganization = component.find("RequestNewOrganization");
                        requestNewOrganization.set("v.body", components);
                        
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": location.origin +"/apex/RequestNewOrganization"
                        });
                        urlEvent.fire();
                        
                        if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                            $A.get("e.force:closeQuickAction").fire();
                        }
                        break;
                    case "INCOMPLETE":
                        console.log("No response from server or client is offline.");
                        helper.showMessage(component, event, 'Success','No response from server or client is offline.');
                        break;
                    case "ERROR":
                        console.log("Error---", statusMessagesList);
                        break;
                    default: 
                        console.log("Error---", statusMessagesList);
                }
            }
        );
    }
})