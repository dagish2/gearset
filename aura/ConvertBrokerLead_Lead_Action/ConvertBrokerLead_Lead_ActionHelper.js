({
	showMessage : function(component, message, type) {
        $A.createComponent(
            "ui:message",{
                "title": message,
                "severity": type
            },
            function(components,status,statusMessagesList){
                var convertBrokerLead = component.find("ConvertBrokerLead");
                convertBrokerLead.set("v.body", components);
            }
        );
    },
    verifyAndShowAccountSelector : function(component, event, helper) {
        component.set("v.showConfirmation", false);
        var lead = new sforce.SObject("Lead"); 
        component.find("utils").execute("c.verifyBrokerLead", {"leadId": component.get("v.recordId"), "convertLead": false, "objlead": lead, "journeyId": "", "isNewAccountCreated": false},function(result){
            component.set("v.record",result);
            component.find("utils").execute("c.getJourneyToUpdate", {"leadId": component.get("v.recordId")}, function(response){
                if(response && response[0] && response[0].Id){
                    component.set("v.updateJourneyStatusId", response[0].Id);
                }
                component.set("v.showAccountSelector",true);
            }, function(error){
                component.set("v.showAccountSelector",false);
                helper.showMessage(component, error, "error");
            }, component);
        },function(error){
            component.set("v.showAccountSelector",false);
            helper.showMessage(component, error, "error");  
        }, component);
    }
})