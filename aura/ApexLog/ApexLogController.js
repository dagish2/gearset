({
	doInit : function(component, event, helper) {
        var describedFields = [];
        describedFields.push({"name":"Id","label":"Log Id","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Id}}","value":"/p/setup/layout/ApexDebugLogDetailEdit/d?apex_log_id={{Id}}","target":"_blank"}}});
        describedFields.push({"name":"LogUser.Name","label":"Log User","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{LogUser.Name}}","value":"/{{LogUserId}}","target":"_blank"}}});
        //describedFields.push({"name":"Application","label":"Application"});
        //describedFields.push({"name":"LogLength","label":"LogLength"});
        describedFields.push({"name":"Operation","label":"Operation"});
        describedFields.push({"name":"StartTime","label":"StartTime","type":"datetime"});
        describedFields.push({"name":"Status","label":"Status"});
        component.set("v.describedFields",describedFields);
    },
    DeleteLogs:function(component, event, helper){
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":"SELECT Id FROM APEXLOG WHERE LogUserId = \'"+(component.get("v.objLog.logUser"))+"\' LIMIT 50000"},function(logs){
            helper.deleteLogs(component,logs,100);
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
    },
    DeleteAllLogs:function(component, event, helper){
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":"SELECT Id FROM APEXLOG LIMIT 50000"},function(logs){
            helper.deleteLogs(component,logs,100);
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
    },
    getLogs:function(component, event, helper){
        component.find("utils").showProcessing();
        component.set("v.recordsErrorMessage",'');
        var obj = component.get('v.objLog');
        var operations = [];
        if(obj.specificOperation){
            operations = obj.specificOperation.split(";");
        }
        if(obj.operations){
            operations = operations.push.apply(operations,obj.operations.split(";"));
        }
        var users = [];
        users.push(obj.logUser);
        component.find("utils").execute("c.getUserLogs",{"users":users,"startDate":obj.startDate,"endDate":obj.endDate,"size":obj.size !=undefined ? obj.size.toString():'',"searchTerm":obj.searchTerm,"operations":operations,"startTime":obj.startTime,"endTime":obj.endTime},function(logs){
            if(logs && logs.length > 0){
                component.set("v.logs",logs);
            }else{
                component.set("v.logs",[]);
                component.set("v.recordsErrorMessage","Records not found.Please try again");
            }
            component.find("utils").hideProcessing();

        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },
    doneRendering : function(component, event, helper) {
        var table = document.getElementById("dataTable");
        if(table){
            table.scrollIntoView({ block: 'start',  behavior: 'smooth' });
        }
    }
})