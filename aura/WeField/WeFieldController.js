({
	doInit : function(component, event, helper) {
        if(component.get("v.metadata")){
            helper.initField(component);
        }else if(component.get("v.sObjectName") && component.get("v.fieldName")){
            component.find("utils").execute("c.getFieldMetadata", {"sObjectName": component.get("v.sObjectName"),"fieldName": component.get("v.fieldName")}, function(response){
                component.set("v.metadata", JSON.parse(response));
                component.set("v.fireInitField", true);
                //helper.initField(component);
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            })
        }else{
            helper.createComponent(component);
        }
        
        if(component.get("v.type") == "multipicklist" || component.get("v.type") == "reference"){
            component.set("v.filteredOptions", helper.getFilteredOptions(component.get("v.options"), component));
        }
        if(component.get("v.validate") && component.get("v.errors")){  
            var errors = component.get("v.errors");
            component.set("v.index", errors.length);
            errors[errors.length] = undefined;
            component.set("v.errors", errors);
        }
    },
    optionsChange:function(component, event, helper){
        if(component.get("v.type") == "multipicklist" || component.get("v.type") == "reference"){
            component.set("v.filteredOptions", helper.getFilteredOptions(component.get("v.options"), component));
        }
    },
    fireInitField:function(component, event, helper){
        helper.initField(component);
    },
    valueChange:function(component, event, helper){
        var fName = component.get("v.fieldName");
        if(component.get("v.type") == "number" && component.get("v.value") && typeof(component.get("v.value")) == "string"){
            component.set("v.value", Number(component.get("v.value")));
        }else{
            var record = component.get("v.record");
            if(component.get("v.dynamicBinding") && component.get("v.value") != record[component.get("v.fieldName")]){
                record[component.get("v.fieldName")] = component.get("v.value");
                component.set("v.record", record);
            }
            setTimeout(function(){
                helper.validate(component)
            }, 1);            
        }
    },
    bindValue:function(component, event, helper){
        var record = component.get("v.record");
        if(component.get("v.dynamicBinding") && component.get("v.value") != record[component.get("v.fieldName")]){
            component.set("v.value", record[component.get("v.fieldName")]);
        }
    },
    handleDestroy:function(component, event, helper){
        var errors = component.get("v.errors");
        if(errors){
            errors[component.get("v.index")] = undefined;
            component.set("v.errors", errors);
        }
    }
})