({
	doInit : function(component, event, helper) {
        if(!JSON.parse(component.get("v.isFromCreateOpportunity"))){
            component.find("utils").setTitle("Request New Organization");
        }
        helper.resetNewRquestForm(component, helper);
	},
    requestNewOrganization : function(component, event, helper) {
        component.find("utils").showProcessing();
        var strQuery ="SELECT Id, Name, RecordType.Name FROM Account WHERE Name = '" + component.find("utils").addSlashes(component.get("v.requestedOrg.Name")) + "' AND Account_Type__c = 'Org'"; 
        component.find("utils").execute("c.getQueryData", {"query": strQuery}, function(response){
            var  lstAccounts = JSON.parse(JSON.stringify(response));
            if(lstAccounts.length > 0){
                var existingAcc = lstAccounts[0];
                component.find("utils").hideProcessing();
                if(existingAcc.RecordType != undefined && existingAcc.RecordType['Name'] != undefined){
                    component.find("utils").showError("An Organization account with '" + component.get("v.requestedOrg.Name") + "' already exists with the '" + existingAcc.RecordType['Name'] + "' segment");
                } else {
                    component.find("utils").showError("An Organization account with " + component.get("v.requestedOrg.Name") + " already exists.");
                }
            } else {
                component.find("utils").execute("c.sendNewOrganizationRequest", {"objAccount": component.get("v.requestedOrg")}, function(response){                    
                    component.find("utils").hideProcessing();
                    if(response){                        
                        component.find("utils").showSuccess("New Organization request has been sent successfully.");
                        helper.resetNewRquestForm(component, helper);
                        if(component.get("v.requestNewOrgSuccess") != undefined){
                            component.set("v.requestNewOrgSuccess", true);
                        } else {
                            helper.close(component, helper, 2000);
                        }
                    } else {
                        component.find("utils").showError("Something went wrong, please contact your system administrator.");
                    }
                },function(error){
                    component.find("utils").hideProcessing();            
                    component.find("utils").showError(error);
                }, component); 
            }
        }, function(error){
            component.find("utils").showError(error);
        });
    },
    close : function(component, event, helper) {
        helper.close(component, helper, 0);
    }
})