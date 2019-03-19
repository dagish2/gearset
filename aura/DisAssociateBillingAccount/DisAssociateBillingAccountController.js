({
    doInit : function(component, event, helper){
        component.find("utils").setTitle("Deassociate Billing Account");
        component.find("utils").showProcessing();
        var strQuery = "SELECT Id, StageName, Contract_Stage__c, Billing_Account__c, OwnerId FROM Opportunity WHERE Id= '"+component.get("v.recordId")+"'";
        component.find("utils").execute("c.getQueryData",{"query":strQuery}, function(response){
            component.set("v.opportunityRec", response[0]);
            helper.disassociate(component, helper, false);
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    disassociateBillAcc : function(component, event, helper){
        helper.disassociate(component, helper, true);
    },
    close : function(component, event, helper){
        component.find("utils").closeTab();
    }
})