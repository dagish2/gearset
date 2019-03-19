({
	doInit : function(component, event, helper) {        
        component.find("utils").execute("c.getQueryData", {"query": "SELECT Id, Name, Lost_Reason__c, Other_Reason__c, Status__c FROM Journey__c WHERE Id = '" + component.get("v.recordId") + "'"}, function(response){
            component.set("v.journey", response[0]);
            component.find("utils").hideProcessing();
        }, function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
	},
    unqualify : function(component, event, helper) {
        component.find("utils").showProcessing();
        var journey = component.get("v.journey");
        journey["Status__c"] = "Unqualified";
        component.find("utils").execute("c.saveRecord",{"record": journey}, function(response){
            component.find("utils").hideProcessing();
            var result = JSON.parse(response);
            if(result && result.success){
                component.find("utils").showSuccess('Journey unqualified successfully.');
                helper.close(component);
            }else{
                component.find("utils").showError(result.errors[0]);
            }
        }, function(error){            
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
	},
    close : function(component, event, helper) {
        helper.close(component);
    }
})