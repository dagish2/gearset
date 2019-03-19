({
    doInit : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getTodaysDate",{},function(today){
            component.set("v.currentDate",today);
            component.find("utils").execute("c.getQueryData",{"query":"SELECT Id, Data__c FROM Setting__c WHERE Name ='FollowupOptions'"},function(result){
                var setting = JSON.parse(result[0].Data__c);
                var arrOptions = [];
                setting.options.split(",").forEach(function(result){
                    arrOptions.push({'label':result,'value':result}); 
                });
                component.set('v.options',arrOptions);
                
                if(typeof(component.get("v.journeyId")) == "string" ){
                    var strQuery = "SELECT Id, Name, Primary_Contact__r.Name, Primary_Lead__r.Name,CreatedDate FROM Journey__c WHERE Id ='"+component.get("v.journeyId")+"'";     
                    component.find("utils").execute("c.getQueryData",{"query":strQuery},function(result){
                        if(result.length==1){
                            if(result[0].Name!=undefined && result[0].Name!='')
                                component.set('v.journeyName',result[0].Name);
                        }
                    },function(error){
                        component.set('v.error',error);
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    })   
                }
                component.find("utils").hideProcessing();     
            },function(error){
                component.set('v.error',error);
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            })
        },function(error){
            component.set('v.error',error);
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
        
    },
    generateFollowupDate : function(component, event, helper){
        var daysToAdd;
        var interval = component.get("v.objFollowup.followUpAfter").trim().split(" ")[0];
        var span = component.get("v.objFollowup.followUpAfter").trim().split(" ")[1];
        if(span.toLowerCase()=='days' || span.toLowerCase()=='day'){
            daysToAdd = parseInt(interval);
        }else if(span.toLowerCase()=='weeks'){
            daysToAdd = parseInt(interval)*7;
        }else if(span.toLowerCase()=='months'){
            daysToAdd = parseInt(interval)*30;
        }
        var lstDates = component.get("v.currentDate").split("-");
        component.find("utils").execute("c.addBusinessDays",{"utcYear":lstDates[0],"utcMonth":lstDates[1],"utcDate":lstDates[2],"daysToAdd":daysToAdd},function(result){ 
            component.set("v.objFollowup.followupOn",result);
        },function(error){
            component.set('v.error',error);
            component.find("utils").showError(error);
        }) 
    },
    save : function(component, event, helper){
        component.find("utils").showProcessing();
        var paramObj = {"journeyIds":component.get("v.journeyId"),"nmdNextContactDate1":component.get("v.objFollowup.followupOn"), "description":component.get("v.objFollowup.comments") != undefined ? component.get("v.objFollowup.comments").substring(0,255) : component.get("v.objFollowup.comments")  };
        component.find("utils").execute("c.bulkJourneyUpdates",paramObj,function(result){
            if(result){
                component.find("utils").hideProcessing();
                component.find("utils").showSuccess('Journey Updated Successfully');//
                setTimeout(function () {
                    parent.postMessage('closeAndRefresh',location.origin);
                },2000);
                setTimeout(function () {
                    self.close();
                },2000);
                
            }else{
                component.find("utils").hideProcessing();
                component.find("utils").showError('Failed to Update Journeys');
            }
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },
    cancel : function(component, event, helper){
        helper.cancel(component, event, helper);    
    }
})