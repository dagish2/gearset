({	/*created By : Shobhit Gahlot
    * Issue No : ST-1316 - improvement and conversion on page in angular to lightning
	*/
    doInit : function(component, event, helper) {
        var settingId = component.get("v.settingId");
        helper.setMetaDataFields(component, event, helper);
        helper.init(component, event, helper, settingId);
    },
    saveJSON : function(component, event, helper){
        helper.generateSettingJSON(component,event,helper);
        component.find("utils").showConfirm("Are you sure ?",function(){
            var setting = {};
            setting.Id = component.get("v.settingId");
            setting.Data__c = JSON.stringify(helper.generateSettingJSON(component,event,helper));
            //var settingData = this.generateSettingJSON(component,event,helper);
            if(setting){
                component.find("utils").showProcessing();
                component.find("utils").execute("c.saveRecord",{"record":setting},function(response){
                    component.set("v.settingRecord",setting);
                    component.find("utils").hideProcessing();
                    component.find("utils").showSuccess('Saved successfully.');                 
                },function(error){
                    component.find("utils").showError(error); 
                });
            }
        });
    },
    search : function(component, event, helper){
        component.find("utils").showProcessing();
        component.set("v.currentPage",1);
        component.set("v.keyword",(event.target.value).trim());
        helper.search(component, event, helper,function(){
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        });
        /*if(window.timeOut == undefined)
            window.timeOut=0;
        if(component.get("v.keyword") != '' && event.key != "Shift" && event.key != "Control" && event.key !="CapsLock" && event.key !="NumLock"){
            var timeOutS = 1000;
            if(window.timeOut){
                clearInterval(window.timeOut);
                window.timeOut = setTimeout(function(){ helper.search(component, event, helper);}, timeOutS);
            }
            else
                window.timeOut = setTimeout(function(){ helper.search(component, event, helper);}, timeOutS);
       }
	   if(component.get("v.keyword") == '')
           helper.search(component, event, helper);   */     
    },
    cancel : function(component, event, helper){
        component.find("utils").showConfirm("Are you sure?",function(){
            helper.close(component, helper);
        });
    },
    addUser: function(component, event, helper){
    	if(!event.$params$){
            helper.addUser(component, event, helper);
        }
	},
 	removeUser: function(component, event, helper){
    	if(!event.$params$){
            helper.removeUser(component, event, helper);
        }
	},
    removeQueue: function(component, event, helper){
    	if(!event.$params$){
            helper.removeQueue(component, event, helper);
        }
	},
    addQueue: function(component, event, helper){
    	if(!event.$params$){
            helper.addQueue(component, event, helper);
        }
	}
})