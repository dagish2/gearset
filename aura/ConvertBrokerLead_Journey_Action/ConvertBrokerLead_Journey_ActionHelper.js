({
    showMessage : function(component, message, type) {
        $A.createComponent(
            "ui:message",{
                "title": message,
                "severity": type
            },
            function(components, status, statusMessagesList){
                var convertBrokerLeadJourneyAction = component.find("ConvertBrokerLeadJourneyAction");
                convertBrokerLeadJourneyAction.set("v.body", components);
            }
        );
    },
    getClosedStages: function (component, helper, onsuccess){
        component.get("v.utils").execute("c.getJourneyClosedStages",{}, function(response){
            var closedStages = JSON.parse(response.toLowerCase());
            component.set("v.closedJourneyStages", closedStages);
            onsuccess();
         },function(error){
            component.get("v.utils").showError(error);
            component.get("v.utils").hideProcessing();
        },component);
    }
})