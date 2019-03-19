({
	change : function(component, event, helper) {
        component.set("v.value",event.target.value);
        if(component.get("v.change")){
            var change = component.get("v.change");
            $A.enqueueAction(change);
        }
	}
})