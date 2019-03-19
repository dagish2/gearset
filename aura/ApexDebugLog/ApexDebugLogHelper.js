({
    clearLogFields:function(component,event,helper){
        component.set("v.objupdate.estimatedfix",'');
        component.set("v.objupdate.findingsandobservations",'');
        component.set("v.objupdate.exceptioncategory",'');
        component.set("v.objupdate.status",'');
        component.set("v.objupdate.resolutionstepsanddetails",'');
    },
    getLogData : function(component, obj, startDate, endDate, startTime, endTime, event, helper) {
        var action = component.get("c.getDebugLog");
        action.setParams({"startDate":startDate,"endDate":endDate,"startTime":startTime,"endTime":endTime,"message":obj.message,"status":obj.status,"method":obj.method,"stackTrace":obj.stackTrace,"estimatedfix":obj.estimatedfix,"exceptioncategory":obj.exceptioncategory});
        action.setCallback(this,$A.getCallback(function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var logs =  response.getReturnValue().data;
                if(logs && logs.length > 0){
                    component.set("v.logs",logs);
                }else{
                    component.set("v.logs",[]);
                    component.set("v.recordsErrorMessage","Records not found.Please try again");
                }
                component.find("utils").hideProcessing();
            } else if (state == "ERROR") {
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            }
        }));
        $A.enqueueAction(action);
    },
    updateNewRecord : function(component, objupdate, lstOfSelectedRecord, event, helper) {
        var action = component.get("c.setFeildOfDebugLog");
        action.setParams({"estimatedfix":objupdate.estimatedfix,"findingsandobservations":objupdate.findingsandobservations,"exceptioncategory":objupdate.exceptioncategory,"status":objupdate.status,"resolutionstepsanddetails":objupdate.resolutionstepsanddetails,"lstOfSelectedRecord":lstOfSelectedRecord});
        action.setCallback(this,$A.getCallback(function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                component.find("utils").hideProcessing();
                helper.clearLogFields(component, event, helper);   
                component.find("utils").showSuccess('Record(s) updated successfully');
            } else if (state == "ERROR") {
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            }
        }));
        $A.enqueueAction(action);
    },
    advancesSearchFeilds:function(component,event,helper){
        component.set("v.objLog.estimatedfix",'');
        component.set("v.objLog.exceptioncategory",'');
        component.set("v.objLog.status",'');
        component.set("v.objLog.method",''); 
        component.set("v.objLog.message",'');
        component.set("v.objLog.stackTrace",'');
        component.set("v.logs",null);
        component.set("v.selectedRecord",null);
    },
})