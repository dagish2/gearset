({
	change : function(component, event, helper) {
        component.set("v.dirty",true);
        component.set("v.value",event.target.value);
	}
})