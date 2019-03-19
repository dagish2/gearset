({
	showSuccess : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var message = params.message;
            component.set("v.toasterType","success");
            component.set("v.message",message);
            helper.showToaster(component);
            helper.hideToaster(component,5000);
        }
	},
    showError : function(component, event, helper) {
        var params = event.getParams('params');
        if (params) {
            var message = params.arguments.message;
            component.set("v.toasterType","error");
            component.set("v.message",message);
            if(params.arguments.setTimeout == undefined){
                params.arguments["setTimeout"] = true;
                params.arguments["timeout"] = 5000;
            }
            helper.showToaster(component);
            if(params.arguments.setTimeout){
                helper.hideToaster(component,params.arguments.timeout);
            }
        }
	},
    showWarning : function(component, event, helper) {
        var params = event.getParams('params');
        if (params) {
            var message = params.arguments.message;
            component.set("v.toasterType","warning");
            component.set("v.message",message);
            if(params.arguments.setTimeout == undefined){
                params.arguments["setTimeout"] = true;
                params.arguments["timeout"] = 5000;
            }
            helper.showToaster(component);
            if(params.arguments.setTimeout){
                helper.hideToaster(component,params.arguments.timeout);
            }
            
        }
	},
    closeToaster:function(component,event,helper){
       helper.hideToaster(component,0);
    }
})