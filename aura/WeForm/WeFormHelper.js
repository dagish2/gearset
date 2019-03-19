({
    saveRecord : function(component,onSuccess,onError) {
        if(component.get('v.mode') == 'EDIT'){
            component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    onSuccess("Record Saved Successfully.");
                } else if (saveResult.state === "INCOMPLETE") {
                    onError("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    onError('Problem saving record.\n error: '+(saveResult.error[0] ? saveResult.error[0].message : JSON.stringify(saveResult.error)));
                } else {
                    onError('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            }));
        }
    },
    deleteRecord: function(component, event, helper) {
        var auraId = (component.get("v.mode")=='EDIT') ? "recordEditor" : "recordViewer";
        component.find(auraId).deleteRecord($A.getCallback(function(deleteResult) {
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                // record is deleted
                onSuccess("Record is deleted.");
            } else if (saveResult.state === "INCOMPLETE") {
                onError("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                onError('Problem saving record, error: '+JSON.stringify(saveResult.error));
            } else {
                onError('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
    },
    setLayout: function(component, event, helper) {
        var data = {};
        if(!component.get("v.layout")){
            if(component.get("v.recordId")){
                component.find("utils").execute("c.getLayout",{"recordId":component.get("v.recordId")},function(response){
                    data = JSON.parse(response);
                    if(data.lstRecordTypes.length>0)
                        data = JSON.parse(data.layout);
                    else
                        data = JSON.parse(data.layout).layouts[0];
                    component.set("v.layout",data);
                },function(error){
                    component.find("utils").showError(error);
                });
            }else{
                component.find("utils").execute("c.getLayoutForNewRecord",{"sObjectName":component.get("v.sObjectName")},function(response){
                    component.set("v.layout",JSON.parse(JSON.parse(response).layout));
                },function(error){
                    component.find("utils").showError(error);
                });
            }
        }else if(typeof(component.get("v.layout"))=="string"){
            data = JSON.parse(component.get("v.layout"));
            if(data.layouts){
                component.set("v.layout",data.layouts[0]);
            }
            else{
                component.set("v.layout",data);
            }
        }
    },
    getPhoneHref: function(value,id,objectName,recordName) {
        return encodeURI("javascript:sendCTIMessage('/CLICK_TO_DIAL?DN='+encodeURIComponent('"+value+"')+'&ID="+id+"&ENTITY_NAME="+objectName+"&OBJECT_NAME='+encodeURIComponent('"+recordName+"')+'&DISPLAY_NAME='+encodeURIComponent('"+objectName+"'))");
    }
})