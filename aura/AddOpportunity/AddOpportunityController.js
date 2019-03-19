({
    doInit: function (component, event, helper) {        
        component.find("utils").setTitle("Add Opportunity");
        component.find("utils").showProcessing();
        helper.getJourneyData(component, event, helper, function(){
            helper.showOpportunities(component, event, helper, function(){
                var lstOpportunities =  component.get("v.opportunities");
                if(lstOpportunities && lstOpportunities.length == 0){
                    helper.showNewOpportunityModal(component, event, helper, function(){
                        component.find("utils").hideProcessing();
                    }, function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    });
                }
                if(component.get("v.accountId") != ""){
                    helper.showNewOpportunityModal(component, event, helper, function(){
                        component.find("utils").hideProcessing();
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    });
                }
                component.find("utils").hideProcessing();
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            });
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    showNewOpportunityModal: function (component, event, helper) {
        component.set("v.showOrgAccountModal", false);
        component.find("utils").showProcessing();
        helper.showNewOpportunityModal(component, event, helper, function(){
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    closeNewOpportunityModal: function (component, event, helper) {
        component.set("v.showNewOppModal", false);
        component.find("utils").showConfirm("Are you sure you want to close this page ?",function(){
            helper.closeNewOpportunityModal(component, helper);
        }, function(){
            component.set("v.showNewOppModal", true);
        });
    },
    save: function (component, event, helper) {
        if(!component.get("v.isContact")){
            var leadId = component.get("v.journey.Primary_Lead__c");
            var opportunity = component.get("v.opportunity");
            component.set("v.accountRec", {"sobjectType": "Account", "Name": null, "Website": "", "Interested_in_Number_of_Desks__c": opportunity.Interested_in_Number_of_Desks__c});
            component.find("NewOpportunityModal").close();
            component.set("v.showAccountSelector", true);
        } else {
            helper.saveController(component, event, helper);
        }
    },
    addOpportunity: function(component, event, helper){
        component.set("v.showAccountSelector", false);
        helper.saveController(component, event, helper);        
    },
    close: function (component, event, helper) {
        component.find("utils").showConfirm("Are you sure you want to close this page?",function(){
            component.find("utils").closeTab();
            component.find("utils").redirectToUrl("/" + component.get("v.journeyId"),'',false);
        });
    },
    back: function (component, event, helper) {
        history.back();
    },  
    handleRowAction:function(component, event, helper){
        var record = event.getParam("record");
        var actionName = event.getParam("action").name;
        switch(actionName) {
            case "SendPaperwork":
                helper.sendPaperwork(component, event, helper);
                break;
        }
    }
})