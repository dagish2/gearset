({
    doInit : function(component, event, helper) {
        component.set("v.utils", component.find("utils"));
        component.set("v.journeyId", component.get("v.recordId"));
        helper.getClosedStages(component, helper, function(){
            component.get("v.utils").execute("c.getQueryResultForLabel",{"label":'journeyDetails', "filters": {"journeyId": component.get("v.recordId")}}, function(journeyRecords){
                if(journeyRecords){
                    var journeyRecord = JSON.parse(JSON.stringify(journeyRecords)).data[0];
                    if(journeyRecord.Status__c == "Unqualified"){
                        helper.showMessage(component, "No further actions possible as the Journey is unqualified.", "error");
                    }else if(journeyRecord.Primary_Contact__c){
                        if(!component.get("v.closedJourneyStages").includes(journeyRecord.Status__c.toLowerCase())){
                            journeyRecord.Status__c = "Completed";
                            component.get("v.utils").showProcessing();
                            component.get("v.utils").execute("c.saveJourney", {"record": journeyRecord}, function(result){
                                if(result){
                                    helper.showMessage(component, "Successfully updated the Journey status to Completed.", "confirm");
                                    $A.get('e.force:refreshView').fire();
                                    setTimeout(function(){
                                        $A.get("e.force:closeQuickAction").fire();
                                    },2000);
                                }
                                component.get("v.utils").hideProcessing();
                            },function(error){
                                component.get("v.utils").hideProcessing();
                                helper.showMessage(component, error, "error");
                            },component);
                        }else{
                            helper.showMessage(component, "You can not hand off Journeys that have been closed or completed.", "error");
                        }
                    }else{
                        component.set("v.recordId", journeyRecord.Primary_Lead__c);
                        component.set("v.showConfirmation", true);
                    }
                }
            }, function(error){
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError(error);
            },component);    
        });        
    },
    verifyAndConvert : function(component, event, helper) {
        component.set("v.showConfirmation", false);
        helper.showMessage(component, "Lead is verifying, Please Wait.", "warning");
        var lead = new sforce.SObject("Lead");
           
        component.get("v.utils").execute("c.verifyBrokerLead", {"leadId": component.get("v.recordId"), "convertLead": false, "objlead": lead, "journeyId": "", "isNewAccountCreated": false}, function(result){
            component.set("v.record", result);
            component.get("v.utils").execute("c.getJourneyToUpdate", {"leadId": component.get("v.recordId")}, function(response){
                if(response && response[0] && response[0].Id){
                    component.set("v.updateJourneyStatusId", response[0].Id);
                }
                component.set("v.showAccountSelector", true); 
            },function(error){
                helper.showMessage(component, error, "error");  
            }, component); 
        }, function(error){
            helper.showMessage(component, error, "error");  
        }, component);
    },
    convertBrokerLead : function(component, event, helper) {
        component.get("v.utils").showProcessing();
        component.set("v.spinnerWithoutContainer", true);
        component.set("v.showAccountSelector", false);
        helper.showMessage(component, "Lead Conversion is in process. Please Wait.", "warning");
        component.get("v.record")["Account__c"] = component.get("v.selectedAccount")["Id"];
        component.get("v.utils").execute("c.verifyBrokerLead", {"leadId": component.get("v.recordId"), "convertLead": true, "objlead": component.get("v.record"), "journeyId": component.get("v.updateJourneyStatusId"), "isNewAccountCreated": component.get("v.isNewAccountCreated") ? component.get("v.isNewAccountCreated") : false }, function(result){
            var contactId = JSON.parse(result).contactId;
            if(result && contactId){
                component.get("v.utils").closeTab();       
                component.get("v.utils").redirectToUrl("/" + contactId);
            }else{
                helper.showMessage(component, "Lead converted successfully.", "confirm");
            }
            component.get("v.utils").hideProcessing();
        },function(error){
            helper.showMessage(component, error, "error");
        },component);
    },
    closeAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})