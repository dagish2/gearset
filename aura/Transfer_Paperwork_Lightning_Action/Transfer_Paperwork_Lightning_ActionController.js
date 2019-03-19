({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
            $A.createComponent(
            "ui:message",{ 
                "title": "Please wait while we redirect you to spacestation",
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
        component.find("utils").execute("c.isValidOpportunityforTransferPaperwork",{"oppId":component.get("v.recordId")},function(result){
            console.log('Result::'+result);
            result = JSON.parse(result);
            if(result.isValid){
                component.set("v.result",result);
                helper.getBillingAccountSelector(component,event);
            }else {
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
            } 
        },function(error){
            helper.showMessage(component, event,'Error',error);
        } , component);
        
    },
    getBillingAccountUUID:function(component,event,helper){
        if(event.getParam('value')){
            component.set("v.result.objOpportunity.Billing_Account__r.UUID__c",event.getParam('value'));
            helper.redirectToSpacestation(component,event);
        }
    }
})