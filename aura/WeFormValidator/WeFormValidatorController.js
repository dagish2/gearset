({
	validate : function(component, event, helper) {
        component.set("v.valid",!component.get("v.errors").includes(false));
	}
})