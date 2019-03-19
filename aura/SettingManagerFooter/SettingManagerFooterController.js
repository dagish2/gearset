({
	close : function(component, event, helper) {
		self.location = "/"+component.get("v.settingId").substring(0,3);
	}
})