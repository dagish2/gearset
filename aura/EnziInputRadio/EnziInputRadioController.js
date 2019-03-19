({
	doInit : function(component, event, helper) {
        if(!component.get("v.name"))
            component.set("v.name", helper.getRandomId());
	},
    change : function(component, event, helper) {
        component.set("v.value", event.target.value);
	},
    defaultChange:function(component, event, helper){
        
    }
})