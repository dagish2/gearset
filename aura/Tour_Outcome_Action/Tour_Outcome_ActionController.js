({
	doInit : function(component, event, helper) {
        $A.createComponent(
            "ui:message",{
                "title": "Please wait while we redirecting to your page",
                "severity": "warning"
            },
            function(components,status,statusMessagesList){
                if (status === "SUCCESS") {
                    var div1 = component.find("div1");
                    div1.set("v.body", components);
                }else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    helper.showMessage(component, event,'Success','No response from server or client is offline.');
                }else if (status === "ERROR") {
                    console.log("Error: " + statusMessagesList);
                }
            }
        );
        
        var action = component.get("c.isValidForTourOutcome");
        action.setParams({ "tourId" : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log(response.getReturnValue());
                if(response.getReturnValue().data.isValid){debugger
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": location.origin +"/apex/TourOutcomeForm?Id="+ component.get("v.recordId")
                    });
                    urlEvent.fire();
                    
                    if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                        $A.get("e.force:closeQuickAction").fire();
                    }   
                } else {
                    $A.createComponent(
                        "ui:message",{
                            "title": response.getReturnValue().data.errorMsg,
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
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);             
    }
})