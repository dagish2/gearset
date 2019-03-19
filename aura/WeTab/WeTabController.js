({
	doInit : function(component, event, helper) {        
        $A.createComponent(
            component.get("v.component.name"),
            component.get("v.component.attributes"),
            function(cmp, status, errorMessage){
                if (status === "SUCCESS") {
                    component.set("v.body", cmp);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
	}
})