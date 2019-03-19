({
    doInit : function(component, event, helper) {      
        component.set("v.screenHeight",window.innerHeight);
        if(component.get("v.settingId")){
            helper.init(component, event, helper);
        }
    },
    saveInfo:function(component, event, helper){
        component.find("utils").showConfirm("Are you sure ?",function(){
            component.find("utils").showProcessing();
            var record = {};
            record['Id'] = component.get("v.currentSetting.Id");
            record['Name'] = component.get("v.currentSetting.Name");
            record['Description__c'] = component.get("v.currentSetting.Description__c");
            record['Type__c'] = component.get("v.currentSetting.Type__c");
            component.find("utils").execute("c.saveRecord",{"record":record},function(response){
                component.find("utils").hideProcessing();
                component.find("utils").showSuccess("Settings saved successfully.");
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);        
            })
        }); 
    },
    saveData:function(component, event, helper){
        component.find("utils").showConfirm("Are you sure ?",function(){
            component.find("utils").showProcessing();
            var record = {};
            record['Id'] = component.get("v.currentSetting.Id");
            record['Data__c'] = JSON.stringify(component.get("v.data"));
            component.find("utils").execute("c.saveRecord",{"record":record},function(response){
                component.set("v.oldData",JSON.parse(JSON.stringify(component.get("v.data"))));
                helper.getSettingHistories(component,function(){
                    component.find("utils").hideProcessing();
                    component.find("utils").showSuccess("Settings saved successfully.");
                });
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);        
            })
        });
    },
    revertData:function(component, event, helper){        
        component.set("v.data",JSON.parse(JSON.stringify(component.get("v.oldData"))));
    },
    syncData:function(component, event, helper){
        component.find("utils").showConfirm("This will override the setting from preprod. Are you sure you want to override setting from preprod ?",function(){
            component.find("utils").showProcessing();
            helper.getSettingData(component,helper,false,function(settingData){
                if(settingData && JSON.parse(settingData).records.length){
                    helper.getSettingObject(component,settingData,function(records){
                        helper.updateSettingData(component,records,function(response){
                            component.find("utils").hideProcessing(); 
                            component.find("utils").showSuccess("Settings saved successfully.");
                            helper.init(component, event, helper);
                        },function(error){
                            component.find("utils").hideProcessing();
                            component.find("utils").showError(error);   
                        })
                    });
                }
                else{
                    component.find("utils").hideProcessing();
                    component.find("utils").showError('"'+component.get("v.currentSetting.Name")+'" not found on preprod'); 
                }
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error); 
            });
        }); 
    },
    syncAllData:function(component, event, helper){
        component.find("utils").showConfirm("This will override all the setting from preprod. Are you sure you want to override all the settings from preprod to current instance ?",function(){
            component.find("utils").showProcessing();
            helper.getSettingData(component,helper,true,function(settingData){
                if(settingData && JSON.parse(settingData).records.length){
                    helper.getAllSettingData(component,helper,settingData,function(records){
                        helper.updateSettingData(component,records,function(records){
                            component.find("utils").hideProcessing(); 
                            component.find("utils").showSuccess("Settings saved successfully.");
                        },function(error){
                            component.find("utils").hideProcessing();
                            component.find("utils").showError(error);   
                        }) 
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error); 
                    })
                }
                else{
                    component.find("utils").hideProcessing();
                    component.find("utils").showError('"'+component.get("v.currentSetting.Name")+'" not found on preprod'); 
                }
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error); 
            });
        }); 
    },
    dataChanged:function(component, event, helper){
        console.log(component.get("v.data"));
    },
    cancel:function(component, event, helper){
        component.set("v.currentSetting",component.get("v.oldSetting"));
        helper.init(component, event, helper);
    },
    refreshActivities:function(component, event, helper){
        helper.getSettingHistories(component,function(){
            
        });
    },
    close:function(component, event, helper){       
        self.location="/"+component.get("v.settingId").substring(0,3);     
    },
})