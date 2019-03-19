({
    doInit : function(component, event, helper) {
        component.find("utils").setTitle("Tour Close Hour");
        component.find("utils").showProcessing();
        component.set("v.record", {});                
        component.find("utils").execute("c.getPageData", {"strSettingName": "TourCloseHour", "tourScheduleId": component.get("v.tourSchedulesId"), "tourCloseHourId": component.get("v.recordId")}, function(pageData){
            if(pageData){
                component.set("v.objectPrefix", pageData.objectPrefix);
                component.set("v.instructions", pageData.instructions);                
                let userAccess = {
                    "hasReadAccess": pageData.userHasReadAccess,
                    "hasEditAccess": pageData.userHasEditAccess,
                    "hasDeleteAccess": pageData.userHasDeleteAccess
                };
                component.set("v.userAccess", userAccess); 
                helper.getTourStartTimeMeata(component, helper, function(){
                    let objTourSchedule = pageData.objTourSchedule;
                    if(objTourSchedule){
                        component.set("v.record.Tour_Schedule__c", objTourSchedule.Id);
                        component.set("v.record.Building__c", objTourSchedule.Building__c);
                    }
                    component.find("utils").hideProcessing();
                });                
            }
        },function(error){ 
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);             
        }, component);
        
        let headerActions = [{
            "label": "Edit",
            "name": "edit",
            "type": "neutral",
            "action": component.getReference("c.editTourCloseHour")
        },{
            "label": "Clone",
            "name": "Clone",
            "type": "neutral",
            "action": component.getReference("c.cloneTourCloseHour")
        },{
            "label": "Delete",
            "name": "delete",
            "type": "neutral",
            "action": component.getReference("c.deleteTourHour")
        }];
        component.set("v.headerActions", headerActions);
        
    },
    saveTourHour : function(component, event, helper) {
        if(helper.validateEndTime(component)){
            if(component.get("v.record.Weekday__c")){
                component.find("utils").showConfirm("You have selected to block off a DAY for every WEEK in the future, would you like to Save?", function(){
                    component.find("utils").showProcessing();
                    helper.saveTourCloseHour(component, function(){
                        component.set("v.mode", "VIEW");
                        component.find("utils").hideProcessing();
                    });
                });
            }else{
                component.find("utils").showProcessing();
                helper.saveTourCloseHour(component, function(){
                    component.set("v.mode", "VIEW");
                    component.find("utils").hideProcessing();
                });
            }
        }else{
            component.find("utils").showError("End time should be greater than start time.");
        }
    },
    editTourCloseHour : function(component, event, helper){
        component.find("utils").showProcessing();
        helper.editTourHour(component, event);        	
        component.find("utils").hideProcessing();
    },
    cloneTourCloseHour : function(component, event, helper){
        component.find("utils").showProcessing();
        component.set("v.isClone", true);
        helper.editTourHour(component, event);              	
        component.find("utils").hideProcessing();
    },
    saveAndNew : function(component, event, helper) {
        if(helper.validateEndTime(component)){
            component.find("utils").showProcessing();
            helper.saveTourCloseHour(component, function(){
                component.set("v.recordId", "");
                component.set("v.record", {Building__c: component.get("v.record.Building__c"),Tour_Schedule__c: component.get("v.record.Tour_Schedule__c")});
            }); 
        }else{
            component.find("utils").showError("End time should be greater than start time.");
        }
    },
    deleteTourHour : function(component, event, helper) {
        if(component.get("v.userAccess.hasDeleteAccess")){
            component.find("utils").showConfirm("Are you sure you want to delete?", function(){
                component.find("utils").showProcessing();
                component.find("utils").execute("c.deleteRecord", {"recordToDelete": component.get("v.recordId")}, function(response){
                    component.find("utils").hideProcessing();
                    component.find("utils").showSuccess("Record deleted successfully."); 
                    setTimeout(function(){
                        component.find("utils").redirectToUrl("/" + component.get("v.objectPrefix"));  
                    }, 1000);
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                });
            });
        } else {
         	component.set("v.isAllowed", false);
        }
    },
    cancel : function(component, event, helper) {
        component.find("utils").showConfirm("Are you sure you want to cancel?", function(){
            if(component.get("v.recordId") && component.get("v.isAllowed")){
                component.set("v.mode", "VIEW");
            }else{
                window.history.go(-1);
            }
        });
    },
    checkUserPermission : function(component, event, helper){
        helper.checkUserPermission(component, function(isAllowed){
            component.set("v.isAllowed", isAllowed);
            component.find("utils").hideProcessing();
        });
    }
})