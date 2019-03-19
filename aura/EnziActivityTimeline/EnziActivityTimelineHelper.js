({
    getMoreSteps : function(component, event) {
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":"SELECT ID, Name, (SELECT Subject,WhoId,WhatId,ActivityDate,ActivitySubtype,Description,IsTask,What.Name,Owner.Name,EndDateTime,StartDateTime,Status,CreatedDate,CallDisposition FROM OpenActivities ORDER BY ActivityDate desc NULLS last) FROM "+ component.get("v.sObjectName") +" Where Id='"+component.get("v.recordId")+"'"},function(response){
            console.log(response);	
            component.set("v.activityRecords.OpenActivities",response[0].OpenActivities);
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
        
    },
    getPastActivities : function(component, event) {
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":"SELECT ID, Name, (SELECT Subject,WhoId,WhatId,ActivityDate,ActivitySubtype,Description,IsTask,What.Name,Owner.Name,EndDateTime,StartDateTime,Status,CreatedDate,CallDisposition FROM ActivityHistories ORDER BY ActivityDate desc NULLS last) FROM "+ component.get("v.sObjectName") +" Where Id='"+component.get("v.recordId")+"'"},function(response){
            console.log(response);
            component.set("v.activityRecords.ActivityHistories",response[0].ActivityHistories);
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
    }
})