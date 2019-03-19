({
    doInit : function(component, event, helper) {        
        component.set("v.utility", component.find("utils"));
        component.get("v.utility").showProcessing();
        component.get("v.utility").execute("c.getJourneyData", {"journeyId": component.get("v.recordId"), "querylabel": "getJourneyData"}, function(journeyDataResult){
            if(journeyDataResult){
                let journeyRecord = journeyDataResult["journeyRecord"];
                component.set("v.relatedJourneys", journeyDataResult["relatedJourneys"]);
                let journeyOutreachStage = journeyRecord["Outreach_Stage__c"];
                if(journeyOutreachStage == undefined || journeyOutreachStage == ""){
                    journeyRecord["Outreach_Stage__c"] = "Call 1";
                    component.set("v.allowedLogACall", true);
                }else if(journeyOutreachStage && journeyOutreachStage == "Call 1"){                
                    journeyRecord["Outreach_Stage__c"] = "Call 2";
                    component.set("v.allowedLogACall", true);
                }else if(journeyOutreachStage && journeyOutreachStage != "Call 2" ){
                    journeyRecord["Outreach_Stage__c"] = "Call 1";
                    component.set("v.allowedLogACall", true);
                }else {
                    journeyRecord["Outreach_Stage__c"] = "Call 2";
                    component.set("v.allowedLogACall", false);
                }
                component.set("v.record", journeyRecord);
                component.get("v.utility").hideProcessing(); 
            }
        }, function(error){
            component.get("v.utility").hideProcessing();
            component.get("v.utility").showError(error);
        }, component);		
	},
    saveCallLog : function(component, event, helper) {
        component.get("v.utility").showProcessing();
        let objJourney = component.get("v.record");
        
        let leftAVoicemail = component.get("v.leftAVoicemail");        
        if(leftAVoicemail){
        	objJourney["Outreach_Result__c"] = "Left Voicemail";
        }
        
        let callComments = component.get("v.callComments");
        
        component.get("v.utility").execute("c.saveCallLogs", {"objJourney": objJourney, "leftAVoicemail": leftAVoicemail, "callComments": callComments}, function(saveCallLogResult){
            if(saveCallLogResult){
                component.get("v.utility").hideProcessing();
                component.get("v.utility").showSuccess("Journey updated successfully.");
                var logACall = component.get("v.logACall");
                if(logACall){                    
                    $A.enqueueAction(logACall);
                }
            } else {
                component.get("v.utility").hideProcessing();
                component.get("v.utility").showError("Something went wrong, please contact your system administrator");
            }
        }, function(error){
            component.get("v.utility").hideProcessing();
            component.get("v.utility").showError(error);
        }, component);
    },
    cancel : function(component, event, helper) {
        component.find("EnziLogACallModal").closeModal();
        component.get("v.utility").showConfirm("Are you sure you want to close the page?", function(){
            component.find("EnziLogACallModal").closeModal();
        }, function(){
            component.find("EnziLogACallModal").showModal();
        });
    }
})