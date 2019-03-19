({
    getLogs:function(component){
        var helper = this;
        component.find("utils").execute("c.getQueryData",{"query":"SELECT Id FROM APEXLOG LIMIT 50000"},function(logs){
            helper.deleteLogs(component,logs,100);
        },function(error){
            component.find("utils").showError(error);
        })
    },
    deleteLogs:function(component,logs,size){
        var helper = this;
        var logsToDelete = logs.slice(0,size);
        var logIds = [];
        logsToDelete.forEach(function(log){
            logIds.push(log.Id);
        })
        component.find("utils").execute("c.deleteLogs",{"lstLogIds":logIds},function(response){
            if(logs.length>logsToDelete.length){
                logs = logs.slice(size,logs.length);
                helper.deleteLogs(component,logs,size);
            }else{
                component.find("utils").showSuccess("Logs deleted successfully.");
            }
        },function(error){
           component.find("utils").showError(error);
        })
    }
})