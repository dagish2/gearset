({
    doInit : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.find("utils").setTitle("REA Advisory Case");
        var response1;
        component.find("utils").execute("c.checkValidOppForREAAdvisory", {"opportunityId":component.get("v.recordId")}, function(response){
            if(response && response["isValid"] != null && response["isValid"] == false){
                component.set("v.valid", false);
                component.set("v.message", response["message"]);
                component.find("utils").hideProcessing();
            }else if(response && response["opportunity"] && response["isValid"] != null && response["isValid"] == true){
                response1 = response;
                component.set("v.valid", true);
                component.find("utils").hideProcessing();
            }else{
                component.find("utils").hideProcessing();
                component.find("utils").showError("Opportunity not found.");
            }
            if( response1 != null && response1["opportunity"] && component.get("v.valid") != null && response["isValid"] == true){
                component.find("utils").showProcessing();
                component.find("utils").closeTab();
                //var url = "/apex/disco__NewFormWizard?templateID=a3g0S0000009d2X&sfdc.override=1&passthroughreturl="+response1["opportunity"].Id+"&disco__Form_Account__c="+response1["opportunity"].AccountId+"&disco__Form_Opportunity__c="+response1["opportunity"].Id+"&User__c="+response1["opportunity"].OwnerId+"&disco__Form_Case__c=New"; 
                var url = "/apex/disco__NewFormWizard?templateID=a3g2I0000019Q63QAE&sfdc.override=1&passthroughreturl="+response1["opportunity"].Id+"&disco__Form_Account__c="+response1["opportunity"].AccountId+"&disco__Form_Opportunity__c="+response1["opportunity"].Id+"&User__c="+response1["opportunity"].OwnerId+"&disco__Form_Case__c=New"; 
                component.find("utils").redirectToUrl(url);
            }
        }, function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        }, component);
    }, 
    
    cancel : function(component, event, helper){
        component.find("utils").closeTab();
    }
    
})