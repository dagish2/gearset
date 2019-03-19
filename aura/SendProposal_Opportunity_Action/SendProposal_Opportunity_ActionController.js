({
	doInit : function(component, event, helper) {
        $A.createComponent(
            "ui:message",{
                "title": "Please wait while we redirecting to your page.",
                "severity": "warning"
            },
            function(components,status,statusMessagesList){
                if (status === "SUCCESS") {
                    var div1 = component.find("div1");
                    div1.set("v.body", components);
                }else if (status === "INCOMPLETE") {
                    helper.showMessage(component, event,'Success','No response from server or client is offline.');
                }else if (status === "ERROR") {
                    console.log("Error: " + statusMessagesList);
                }
            }
        );
        
        component.find("utils").execute("c.isValidOppforSendProposal",{"oppId":component.get("v.recordId")},function(result){
            if(result.isValid){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": location.origin +"/apex/Availability"
                });
                urlEvent.fire();
                
                if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                    $A.get("e.force:closeQuickAction").fire();
                }   
            }else{
                $A.createComponent(
                    "ui:message",{
                        "title": "Error while update opportunity for send proposal.",
                        "severity": "warning"
                    },
                    function(components,status,statusMessagesList){
                        if (status === "SUCCESS") {
                            var div1 = component.find("div1");
                            div1.set("v.body", components);
                        }else if (status === "INCOMPLETE") {
                            helper.showMessage(component, event,'Success','No response from server or client is offline.');
                        }else if (status === "ERROR") {
                            console.log("Error: " + statusMessagesList);
                        }
                    }
                );
            }
        },function(error){
            helper.showMessage(component, event,'Error',error);
        })               
    },
})