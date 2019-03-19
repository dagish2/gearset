({
	doInit : function(component, event, helper) {
        var Name  = component.get("v.Name");
        console.log(Name);
        component.find("utils").showProcessing();
        component.find("utils").execute("c.validateLead",{"recordId":component.get("v.recordId")},function(result){
            if(result["message"] != ""){
                component.set("v.message","Referrer is blank. Add a referrer in the referrer lookup field.");
            }else{
                var urlMap = {};
                urlMap["ManageBookTourButton"] = '/apex/BookTours?leadId=';
                urlMap["SendToEnterprise"] = '/apex/CreateOpportunity?id=';
                
                component.find("utils").redirectToUrl(urlMap[component.get("v.Name")]+component.get("v.recordId"));
            } 
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    close:function(component,event,helper){
        history.go(-1); 
    }
})