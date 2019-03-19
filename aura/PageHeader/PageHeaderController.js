({
	isInLightning : function(component, event, helper) {
		let shouldSetTheme = window.location.href.includes("lightning");
        component.set("v.isInLightning", shouldSetTheme);
	}
})