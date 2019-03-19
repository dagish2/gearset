({
	toastMessage : function(component, message,severity) {
        $A.createComponent(
            "ui:message",{
                "title": message,
                "severity": severity
            },
            function(components,status,statusMessagesList){
                var errorMessage = component.find("component-body");
                errorMessage.set("v.body", components);
            }
        );
    }
})