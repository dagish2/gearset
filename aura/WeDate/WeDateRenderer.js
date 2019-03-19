({
	afterRender: function (component, helper) {
        this.superAfterRender();
        console.log('In After render date::'+(component.get("v.name")));
        if(component.get("v.validate") && component.find(component.get("v.auraId"))){
            var valid = component.find(component.get("v.auraId")).get('v.validity').valid;
            var errors = component.get("v.errors");
            errors[component.get("v.index")] = valid;
            component.set("v.errors",errors);
        }
    }
})