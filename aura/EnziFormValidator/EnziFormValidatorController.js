({
	doInit : function(component, event, helper) {
        component.set("v.errors",{"mapValidations":{},"mapComponents":{}});
        component.set("v.valid",true);
	},
    validate:function(component, event, helper){
        var errors = component.get("v.errors");
        //console.log(errors);
        if(errors){
            var valid = true;
            for (var field in errors.mapValidations) {
                if(errors.mapValidations[field]==false){
                    valid = false;
                }
            }
            component.set("v.valid",valid);
        }
    },
    validateByName:function(component, event, helper){
        var params = event.getParam('arguments');
        var cmp = component.get("v.errors").mapComponents[params.name];
        if(cmp)
        	cmp.validate();
    }
})