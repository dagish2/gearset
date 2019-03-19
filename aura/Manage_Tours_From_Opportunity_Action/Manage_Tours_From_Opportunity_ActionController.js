({
    doInit : function(component, event, helper) {       
        component.find("utils").execute("c.isValidOpportunityForManageTourLightning",{"oppId":component.get("v.recordId")},function(result){
            var result = JSON.parse(result);
            if(!result.isValid){
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
                        "title": "Please wait while we redirect you to Manage Tours page",
                        "severity": "warning"
                    },
                    function(components,status,errorMessage){
                        switch(status){
                            case "SUCCESS":
			                    var div1 = component.find("div1");
                                div1.set("v.body", components); 
                                break;
                            case "INCOMPLETE":                                
                                helper.showMessage(component, event,'Success','No response from server or client is offline.');                                
                                break;
                            case "ERROR":  
                                helper.showMessage(component, event,'Success',errorMessage); 
                                break;
                        }
                    }
                );
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/apex/BookTours?opportunityId="+ component.get("v.recordId")
                });
                urlEvent.fire();
                
                if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                    $A.get("e.force:closeQuickAction").fire();
                }
                helper.refresh(component, event);
            } 
        },function(error){
            helper.showMessage(component, event,'Error',error);
        },component)               
    }
})