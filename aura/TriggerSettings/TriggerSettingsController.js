({
    doInit : function(component, event, helper) {
        helper.populateTriggerData(component,function(){
            
        });
    },
    filter:function(component, event, helper){
        component.set("v.filterCriteria",event.currentTarget.value);
        helper.filterTriggers(component);
    },
    search:function(component, event, helper){
        component.set("v.searchKeyword",event.currentTarget.value);
        helper.filterTriggers(component);
    },
    openSettingModal:function(component, event, helper){
        component.set("v.trigger.name","");
        component.set("v.trigger.oldName","");
        component.set("v.trigger.status","");
        component.find("saveSettingModal").showModal();        
    },
    closeSettingModal:function(component, event, helper){
        component.set("v.trigger",{});
        component.find("saveSettingModal").close();        
    },
    editSetting:function(component, event, helper){
        var triggerName = event.currentTarget.id.split(":")[1];
        var trigger = {};
        var triggerData = JSON.parse(component.get("v.settingData"));
        trigger.name = triggerName;
        trigger.oldName = triggerName;
        trigger.status = triggerData[triggerName]?'Active':'Inactive';
        component.set("v.trigger",trigger);
        component.find("saveSettingModal").showModal();        
    },
    deleteSetting:function(component, event, helper){
        var triggerName = event.currentTarget.id.split(":")[1];
        component.find("utils").showConfirm("Are you sure you want to delete this trigger?",function(){
            component.find("utils").showProcessing();
            var triggerData = JSON.parse(component.get("v.settingData"));
            delete triggerData[triggerName];
            triggerData = helper.sortObject(triggerData);
            component.set("v.settingData",JSON.stringify(triggerData));
            helper.saveSetting(component,function(){
                helper.populateTriggerData(component,function(){
                    component.find("utils").hideProcessing();
                    component.find("utils").showSuccess("Trigger deleted successfully.");
                }); 
            },function(error){
                component.find("utils").showProcessing();
                component.find("utils").showError(error);
            })
        });
    },
    save:function(component, event, helper){
        var triggerData = JSON.parse(component.get("v.settingData"));
        var trigger = component.get("v.trigger");
        if(!trigger.oldName && triggerData.hasOwnProperty(trigger.name)){
            component.find("utils").showError('The trigger with given name already exists.');
        }else{
            component.find("saveSettingModal").close();         
            component.find("utils").showConfirm("Are you sure you want to save trigger?",function(){
                component.find("utils").showProcessing();
                if(trigger.name!=trigger.oldName){
                    delete triggerData[trigger.oldName];
                }
                triggerData[trigger.name] = (trigger.status=="Active");
                triggerData = helper.sortObject(triggerData);
                component.set("v.settingData",JSON.stringify(triggerData));
                helper.saveSetting(component,function(){
                    helper.populateTriggerData(component,function(){               
                        component.find("utils").hideProcessing();
                        component.find("utils").showSuccess("Trigger saved successfully.");
                    }); 
                },function(error){
                    component.find("utils").showProcessing();
                    component.find("utils").showError(error);
                })
                
            });   
        }        
    },
    saveAll:function(component, event, helper){
        component.find("utils").showConfirm("Are you sure you want to save triggers ?",function(){
            component.find("utils").showProcessing();
            var triggerData = JSON.parse(component.get("v.settingData"));
            var triggers = component.get("v.triggers");
            var mapTrigger = {};
            for(var t in triggers){
                mapTrigger[triggers[t].name] = triggers[t].status;
            }
            for(var t in triggerData){
                if(mapTrigger.hasOwnProperty(t)){
                    triggerData[t] = mapTrigger[t];
                }
            }
            triggerData = helper.sortObject(triggerData);
            component.set("v.settingData",JSON.stringify(triggerData));
            helper.saveSetting(component,function(){               
               helper.populateTriggerData(component,function(){                    
                    component.find("utils").hideProcessing();
                    component.find("utils").showSuccess("Triggers saved successfully."); 
                   
                });
            },function(error){
                component.find("utils").showProcessing();
                component.find("utils").showError(error);
            })
        })
        
    },
    cancel:function(component, event, helper){
        component.find("utils").showProcessing();
        helper.populateTriggerData(component,function(){
            component.find("utils").hideProcessing();
        });
    }
})