({
    doInit : function(component, event, helper) {
        if(component.get("v.isFromConvertLeadPage")){
            helper.verifyAndShowAccountSelector(component, event, helper);
        }
    },
    verifyAndShowAccountSelector : function(component, event, helper) {
        helper.verifyAndShowAccountSelector(component, event, helper);
    },
    convertBrokerLead : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.set("v.spinnerWithoutContainer",true);
        component.set("v.showAccountSelector",false);
        helper.showMessage(component, "Lead Conversion is in process. Please Wait.", "warning"); 
        component.get("v.record")["Account__c"] = component.get("v.selectedAccount")["Id"];
        component.find("utils").execute("c.verifyBrokerLead", {"leadId": component.get("v.recordId"), "convertLead": true, "objlead": component.get("v.record"), "journeyId": component.get("v.updateJourneyStatusId"), "isNewAccountCreated": component.get("v.isNewAccountCreated") ? component.get("v.isNewAccountCreated") : false}, function(result){
            var contactId;
            if(result)
                contactId = JSON.parse(result).contactId;
            helper.showMessage(component, "Lead Converted Successfully.", "confirm");
            if(component.get("v.isFromConvertLeadPage")){
                component.find("utils").hideProcessing();
            }else{
                setTimeout(function(){
                    if(contactId){
                        component.find("utils").redirectToUrl("/" + contactId);
                    }
                    component.find("utils").hideProcessing();
                },1000);
            } 
        },function(error){
            helper.showMessage(component, error, "error");
        },component);
    },
    closeAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})