({
	doInit : function(component, event, helper) {
        if(component.get("v.recordId")){
            //component.find("utils").showProcessing();
            component.find("utils").execute("c.getSobjectNameById",{"recordId":component.get("v.recordId")},function(sObjectName){
                component.set("v.sObjectName",sObjectName);
                component.find("utils").execute("c.getQueryData",{"query":"SELECT ID, Name, (SELECT Subject,WhoId,WhatId,ActivityDate,ActivitySubtype,Description,IsTask,What.Name,Owner.Name,EndDateTime,StartDateTime,Status,CreatedDate,Notes__c,CallDisposition,Description__c FROM OpenActivities ORDER BY ActivityDate desc NULLS last LIMIT 5),(SELECT Subject,WhoId,WhatId,ActivityDate,ActivitySubtype,Description,IsTask,What.Name,Owner.Name,EndDateTime,StartDateTime,Status,CreatedDate,Notes__c,CallDisposition,Description__c FROM ActivityHistories ORDER BY ActivityDate desc NULLS last LIMIT 5) FROM "+ sObjectName +" Where Id='"+component.get("v.recordId")+"'"},function(response){
                    console.log(response);	
                    component.set("v.activityRecords",response[0]);
                },function(error){
                    component.find("utils").showError(error);
                    component.find("utils").hideProcessing();
                })
                
             if(component.get("v.sObjectName") == 'Journey__c'){
                component.find("utils").execute("c.getUserInfo",{},function(response){
                    var user = JSON.parse(response)[0];
                    component.set("v.userInfo",user);	
                },function(error){
                    component.find("utils").showError(error);
                    component.find("utils").hideProcessing();
              })
             }  
                //component.find("utils").hideProcessing();
            },function(error){
                component.find("utils").showError(error);
                //component.find("utils").hideProcessing();
            })
        }
	},
    toogleAction:function(component, event, helper){
        var id = event.currentTarget.id.split(":")[1]; 
        $A.util.toggleClass(document.getElementById(component.get("v.sObjectName") +'toggle:'+id),'slds-is-open');
    },
    view:function(component, event, helper){
        var id = event.currentTarget.id.split(":")[1];
        $A.util.toggleClass(document.getElementById(component.get("v.sObjectName") +'toggle:'+id),'slds-is-open');
        //component.find("utils").addComponent("c:EnziForm",{"recordId":id, "useLayout":true, "mode":"view", "showModal":true});
    },
	edit:function(component, event, helper){
        var id = event.currentTarget.id.split(":")[1];
        $A.util.toggleClass(document.getElementById(component.get("v.sObjectName") +'toggle:'+id),'slds-is-open');
        //component.find("utils").addComponent("c:EnziForm",{"recordId":id, "useLayout":true, "mode":"edit", "showModal":true});
    },
	delete:function(component, event, helper){
        var id = event.currentTarget.id.split(":")[1];
        $A.util.toggleClass(document.getElementById(component.get("v.sObjectName") +'toggle:'+id),'slds-is-open');
        //component.find("utils").addComponent("c:",{"recordId":"00T8A0000043J9cUAE","type":"FULL"});
    },
    makeComplete: function(component, event, helper){
        $A.util.toggleClass(event.currentTarget.parentElement.parentElement.nextElementSibling.firstElementChild, "strikethrough");
    	component.find("utils").showProcessing();
        component.find("utils").execute("c.saveRecord",{"record":{"Id":event.currentTarget.getAttribute("data-recordid"),"Status":"Completed"}},function(response){
            if(JSON.parse(response).success){
                component.find("utils").showSuccess('Task completed successfully');
                component.find("utils").hideProcessing();
            }  
            },function(error){
                component.find("utils").showError(error);
                component.find("utils").hideProcessing();
            })
    },
    getMoreSteps: function(component, event, helper){
        helper.getMoreSteps(component, event);
    },
    getPastActivities: function(component, event, helper){
        helper.getPastActivities(component, event);
    }
})