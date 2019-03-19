({
    createComponent : function(component) {
        var attributes = {};
        attributes["name"] = component.getReference("v.name");
        attributes["label"] = component.getReference("v.label");
        attributes["required"] = component.get("v.required");
        attributes["disabled"] = component.getReference("v.disabled");
        attributes["readonly"] = component.getReference("v.readonly");
        attributes["variant"] = component.get("v.variant");
        attributes["placeholder"] = component.get("v.placeholder") ? component.getReference("v.placeholder") : "Enter "+component.get("v.label");
        attributes["pattern"] = component.get("v.pattern");
        attributes["messageWhenRangeUnderflow"] = component.get("v.messageWhenRangeUnderflow");
        attributes["messageWhenPatternMismatch"] = component.get("v.messageWhenPatternMismatch");
        if(component.get("v.onblur")!=undefined){
            attributes["onblur"] = component.getReference("v.onblur");
        }
        if(component.get("v.onchange")!=undefined){
            attributes["onchange"] = component.getReference("v.onchange");
        }
        if(component.get("v.onfocus")!=undefined){
            attributes["onfocus"] = component.getReference("v.onfocus");
        }
        if(component.get("v.dynamicBinding")){
            component.set("v.value",component.get("v.record."+component.get("v.fieldName")));
        }
        attributes["value"] = component.getReference("v.value");
        attributes["aura:id"] = component.get("v.auraId");
        switch(component.get("v.type")){
            case "checkbox":
                attributes["checked"] = component.getReference("v.value");
                attributes["type"] = "checkbox";
                component.set("v.needToValidate",false);
                component.set("v.componentName","lightning:input");
                break;
            case "email":
                attributes["type"] = "email";
                component.set("v.componentName","lightning:input");
                break;
            case "tel":
                attributes["type"] = "tel";
                component.set("v.componentName","lightning:input");
                break;
            case "url":
                attributes["type"] = "url";
                component.set("v.componentName","lightning:input");
                break;
            case "date":
                attributes["max"] = component.getReference("v.max");
                attributes["min"] = component.getReference("v.min");
                attributes["type"] = "date";
                component.set("v.componentName","lightning:input");
                break;
            case "datetime":
                attributes["max"] = component.getReference("v.max");
                attributes["min"] = component.getReference("v.min");
                attributes["type"] = "datetime";
                component.set("v.componentName","lightning:input");
                break;
            case "time":
                attributes["type"] = "time";
                component.set("v.componentName","lightning:input");
                break;
            case "text":
                attributes["maxlength"] = component.get("v.maxlength");
                attributes["minlength"] = component.get("v.minlength");
                attributes["pattern"] = component.get("v.pattern");
                attributes["type"] = "text";
                component.set("v.componentName","lightning:input");
                break;
            case "textarea":
                attributes["maxlength"] = component.get("v.maxlength");
                attributes["minlength"] = component.get("v.minlength");
                component.set("v.componentName","lightning:textarea");
                break;
            case "integer":
            case "decimal":
            case "double":
            case "long":
            case "number":
                if(!component.get("v.type"))
                    component.set("v.type","number");
                attributes["max"] = component.getReference("v.max");
                attributes["min"] = component.getReference("v.min");
                attributes["type"] = "number";
                component.set("v.componentName","lightning:input");
                break;
            case "percent":
                attributes["formatter"] = "percent";
                attributes["type"] = "number";
                component.set("v.componentName","lightning:input");
                break;
            case "currency":
                attributes["formatter"] = "currency";
                attributes["type"] = "number";
                component.set("v.componentName","lightning:input");
                break;
            case "select":
                component.set("v.componentName","lightning:combobox");
                attributes["options"] = component.getReference("v.options");
                break;
            case "multipicklist":
                component.set("v.componentName","c:EnziInputMultiSelect");
                attributes["index"] = component.getReference("v.index");
                attributes["errors"] = component.getReference("v.errors");
                attributes["validate"] = component.getReference("v.validate");

                attributes["options"] = component.getReference("v.options");
                attributes["isDisabled"] = component.getReference("v.disabled");
                attributes["showLabel"] = true;
                attributes["isForWeField"] = true;
                component.set("v.needToValidate",false);
                break;
            case "reference":
                component.set("v.componentName","c:WeLookup");
                attributes["showOnlyActiveUsers"] = component.getReference("v.showOnlyActiveUsers");
                attributes["keyword"] = component.getReference("v.keyword");
                attributes["index"] = component.getReference("v.index");
                attributes["errors"] = component.getReference("v.errors");
                attributes["validate"] = component.getReference("v.validate");
                attributes["reference"] = component.getReference("v.reference");
                attributes["options"] = component.getReference("v.filteredOptions");
                component.set("v.needToValidate",false);
                break;
        }
        $A.createComponent(
            component.get("v.componentName"),
            attributes,
            function(cmp, status, errorMessage){
                if (status === "SUCCESS") {
                    component.set("v.cmp", cmp);
                }
            }
        );
    },
    initField:function(component){
        var metadata = component.get("v.metadata");
        component.set("v.name",(component.get("v.name")?component.get("v.name"):metadata.name));
        if(!component.get("v.label"))
            component.set("v.label",metadata.label);
        component.set("v.required", (component.get("v.required") || (metadata.length > 0 && !metadata.nillable)) );

        if(!component.get("v.helpText") && metadata.inlineHelpText){
            component.set("v.helpText",metadata.inlineHelpText);
        }
        switch(metadata.type){
            case "boolean":
                component.set("v.type","checkbox");
                break;
            case "date":
                component.set("v.type","date");
                break;
            case "datetime":
                component.set("v.type","datetime");
                break;
            case "email":
                component.set("v.type","email");
                break;
            case "integer":
            case "decimal":
            case "double":
            case "long":
            case "currency":
            case "percent":
            case "number":
                component.set("v.type","number");
                break;
            case "phone":
                component.set("v.type","tel");
                break;
            case "time":
                component.set("v.type","time");
                break;
            case "url":
                component.set("v.type","url");
                break;
            case "string":
                component.set("v.type","text");
                break;
            case "picklist":
                setTimeout(function(){
                    if(!component.get("v.value")){
                        if(metadata.defaultValue){
                            component.set("v.value",metadata.defaultValue);
                        }else if(!metadata.isCustomNoneSet){
                            component.set("v.value","");
                            metadata.isCustomNoneSet = true;
                            metadata.picklistValues.unshift({active: true, defaultValue: true, label: "--None--", value: ""});
                        }
                    }
                },500);
                component.set("v.type", "select");
                component.set("v.options", metadata.picklistValues);
                break;
            case "multipicklist":
                component.set("v.type","multipicklist");
                component.set("v.options",metadata.picklistValues);
                break;
            case "reference":
                component.set("v.type","reference");
                component.set("v.reference",metadata.referenceTo[0]=="Group"?"Group":metadata.referenceTo[0]);
                break;
        }
        this.createComponent(component);
    },
    validate:function(component,isFromDoneRendering){
        if(component.get("v.validate") && component.get("v.needToValidate") && component.find(component.get("v.auraId"))){
            var validity = component.find(component.get("v.auraId")).get('v.validity');
            if(validity && component.get("v.errors")){
                var errors = component.get("v.errors");
                errors[component.get("v.index")] = validity.valid;
                component.set("v.errors",errors);
                if(isFromDoneRendering)
                    component.set("v.retryValidate",false);
            }
        }
    },
     getFilteredOptions:function(picklistValues,component){
        var options = [];
        for(var option in picklistValues){
            var opt = {};
            if(typeof picklistValues[option]=="object"){
                if(component.get("v.labelField")){
                    opt.label = picklistValues[option][component.get("v.labelField")];
                }else{
                    opt.label = picklistValues[option];
                }

                if(component.get("v.valueField")){
                    opt.value = picklistValues[option][component.get("v.valueField")];
                }else{
                    opt.value = picklistValues[option];
                }
            }else{
                opt.label = picklistValues[option];
                opt.value = picklistValues[option];
            }
            options.push(opt);
        }
        return options;
    }
})