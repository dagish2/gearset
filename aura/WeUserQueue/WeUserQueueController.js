({
	showPopover : function(component, event, helper) {
		component.set("v.showPopover", true);
	},
    closePopover : function(component, event, helper) {
		component.set("v.showPopover", false);
    },
    setObject : function(component, event, helper) {
        component.set("v.object", event.currentTarget.id);
        component.set("v.showPopover", false);
        component.set("v.value", "");
    },
    onBlur : function(component, event, helper) {
        setTimeout(function(){
            component.set("v.showPopover", false);
        },150);
    }
})