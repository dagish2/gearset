({
    //Generate Journey for Lead Source and Details Controller 
    initialiseComponent:function(component, event, helper){
        helper.setMetafields(component,event,helper);
        helper.initialiseComponent(component, event, helper);
    },
    addLeadSource : function(component, event, helper) {
        if(!event.$params$)
            helper.addLeadSource(component, event,helper);
    },
    removeLeadSource:function(component, event, helper){
        if(!event.$params$)
            helper.removeLeadSource(component, event, helper);
    },
    close:function(component,event,helper){
		helper.closeWindow(component,event,helper);
    },
    searchLeadSource:function(component, event, helper){
        component.set("v.currentPage",1);
        component.set("v.keywordLeadSource",(event.currentTarget.value).trim());
        if(window.timeOut == undefined)
            window.timeOut = 0;
        if(component.get("v.keywordLeadSource") != undefined && event.key != "Shift" && event.key != "Control" && event.key !="CapsLock" && event.key !="NumLock"){
            var timeOutS = 1000;
            if(window.timeOut){
                clearInterval(window.timeOut);
                window.timeOut = setTimeout(function(){
                    helper.searchLeadSourceData(component);
                }, timeOutS);
            }
            else
                window.timeOut = setTimeout(function(){
                    helper.searchLeadSourceData(component);
                }, timeOutS);
        }
        
    },
    searchLeadSourceDetails:function(component, event, helper){
         component.set("v.currentPage",1);
        component.set("v.keywordLeadSourceDetail",(event.currentTarget.value).trim());
        if(window.timeOut == undefined)
            window.timeOut = 0;
        if(component.get("v.keywordLeadSourceDetail") != undefined && event.key != "Shift" && event.key != "Control" && event.key !="CapsLock" && event.key !="NumLock"){
            var timeOutS = 1000;
            if(window.timeOut){
                clearInterval(window.timeOut);
                window.timeOut = setTimeout(function(){
                    helper.searchLeadSourceDetailsData(component);
                }, timeOutS);
            }
            else
                window.timeOut = setTimeout(function(){
                    helper.searchLeadSourceDetailsData(component);
                }, timeOutS);
        }
        
    },
    removeLeadSourceDetail:function(component, event, helper){
        if(!event.$params$){
            helper.removeLeadSourceSourceDetails(component, event, helper);
        }
    },
    addLeadSourceDetail:function(component, event, helper){
        if(!event.$params$){
            helper.addLeadSourceDetails(component,event,helper);
        }
    },
    save:function(component,event,helper){
        helper.save(component,event,helper);
    },
})