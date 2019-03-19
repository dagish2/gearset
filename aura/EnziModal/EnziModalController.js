({
    close : function(component, event, helper) {
		component.set("v.show",false);
	},
    showModal : function(component, event, helper) {
		component.set("v.show",true);
	},
    closeModal : function(component, event, helper) {
        component.set("v.show",false);
	}
})