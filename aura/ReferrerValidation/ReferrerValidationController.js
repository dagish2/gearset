({
    doInit : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.find("utils").execute("c.validateLead", {"recordId": component.get("v.recordId")}, function(result){
            var urlMap = {
                "ManageBookTourButton": "/apex/BookTours?leadId=",
                "SendToEnterprise": "/apex/CreateOpportunity?id=",
                "ManageBookTourJourney": "/apex/BookTours?journeyId="
            };            
            component.find("utils").closeTab();
            component.find("utils").redirectToUrl(urlMap[component.get("v.Name")] + component.get("v.recordId"));
            component.find("utils").hideProcessing();
        }, function(error){
            component.find("utils").hideProcessing();
            component.set("v.message", error);
        });
    },
    close:function(component, event, helper){
        history.go(-1); 
    }
})