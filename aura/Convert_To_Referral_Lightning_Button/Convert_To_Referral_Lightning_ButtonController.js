({
    doInit : function(component, event, helper) {
        

        helper.execute(component, "c.isValidConversionLightning",{"oppId":component.get("v.recordId")},function(result){            
            var result = JSON.parse(result.data);
            if(!result.isValidConversion){
                $A.createComponent(
                    "ui:message",{
                        "title": result.errorMsg,
                        "severity": "warning"
                    },
                    function(components,status,statusMessagesList){
                        var div1 = component.find("div1");
                        div1.set("v.body", components);
                    }
                );
                   
            }else{
               
                $A.createComponent(   
                    "ui:message",{
                        "title": "Please wait while we are redirecting to Convert To Referral",
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
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/apex/RetroActiveReferral?id="+ component.get("v.recordId")
                });
                urlEvent.fire();
                
                if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                    $A.get("e.force:closeQuickAction").fire();
                }
                helper.refresh(component, event);
            } 
        },function(error){
            helper.showMessage(component, event,'Error',error);
        })               
    }
})