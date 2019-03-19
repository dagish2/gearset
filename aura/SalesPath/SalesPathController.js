({
    doInit : function(component, event, helper) {
        helper.getOpportunityDetails(component);
        component.find("utils").execute("c.getQueryData", {"query": "Select Lost_Reason__c, Help_Text__c FROM Opportunity_Sales_Path_Help_Text__mdt"}, function(metadataRecords){
            var helptextData = new Map();
            metadataRecords.forEach(function(record){
                helptextData[record["Lost_Reason__c"]] = record["Help_Text__c"];
            });            
            component.set("v.helptextData", helptextData);
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);   
        });       
    },
    handleSelect : function(component, event, helper) {
        var stageName = event.getParam("detail").value;
        component.set("v.hideUpdateButton", (stageName == "Closing" && component.get("v.opportunityStage") == stageName));
        if(stageName.includes("Closed")){
            component.set("v.hideUpdateButton", true);
            component.find("ChangeOpportunityStageModal").showModal();
        }
    },
    cancel : function(component, event, helper) {        
        component.find("ChangeOpportunityStageModal").closeModal();
        helper.getOpportunityDetails(component);
        helper.refresh();
    },
    changeLostReason : function(component, event, helper) {        
        var lostReasons = ["Timing", "No response", "Other WeWork Solution", "Duplicate Opportunity", "Unqualified"];
        component.set("v.helpText", component.get("v.helptextData")[component.get("v.opportunityRec.Lost_Reason__c")]);
        if(component.get("v.opportunityRec.Lost_Reason__c") && !lostReasons.includes(component.get("v.opportunityRec.Lost_Reason__c"))){
            component.set("v.competitorSolution", true);
        } else {
            component.set("v.competitorSolution", false);
            component.set("v.opportunityRec.Competitor_Solution__c", null);
            component.set("v.opportunityRec.Competitor_Solution_Detail__c", null);
        }
    },
    save : function(component, event, helper) {
        component.find("utils").showProcessing();
        var opportunityRec = JSON.parse(JSON.stringify(component.get("v.opportunityRec")));
        opportunityRec["Id"] = component.get("v.recordId");
        if(opportunityRec.StageName != "Closed Lost"){
            opportunityRec["Lost_Reason__c"] = null;
            opportunityRec["Competitor_Solution__c"] = null;
            opportunityRec["Competitor_Solution_Detail__c"] = null
        }
        component.find("utils").execute("c.saveRecord", {"record": opportunityRec}, function(result){
            if(result && JSON.parse(result).success){
                component.find("utils").hideProcessing();
                component.find("ChangeOpportunityStageModal").closeModal();
                component.find("utils").showSuccess("Stage changed successfully");
                helper.getOpportunityDetails(component);
                setTimeout(function(){
                    helper.refresh();
                }, 1000);
            }
        },function(error){
            component.find("utils").hideProcessing();            
            component.find("utils").showError(error);
        });
    }
})