({
    defaultChange:function(component, event, helper){
        
    },
    doInit:function(component, event, helper){
        var options = component.get("v.options");        
        if(component.get("v.value")){
            if(options.findIndex(x=>x.value==component.get("v.value")) == -1){	
			var obj={};
			obj['label']=component.get("v.value");
			obj['value']=component.get("v.value");
			options.push(obj);
            }   
        }
        var sortedOptions = [];
        if(component.get("v.sort")=="asc" || component.get("v.sort")=="desc"){
            sortedOptions = helper.sortRecords(options,"label",component.get("v.sort"));
        }else{
            sortedOptions = options;
        }
        if(component.get("v.isDependent")){
            component.set("v.filteredOptions",sortedOptions[component.get("v.controllingValue")]);
        }else{
            component.set("v.filteredOptions",sortedOptions);
        }
    },
    controllerChange:function(component, event, helper){
        component.set("v.filteredOptions",component.get("v.options")[component.get("v.controllingValue")]);
    },
    optionsChange:function(component, event, helper){
        var options = component.get("v.options");
      	if(component.get("v.value")){
            if(options.findIndex(x=>x.value==component.get("v.value")) == -1){	
            var obj={};
			obj['label']=component.get("v.value");
			obj['value']=component.get("v.value");
			options.push(obj);
            } 
        }
        var sortedOptions = [];
        if(component.get("v.sort")=="asc" || component.get("v.sort")=="desc"){
            sortedOptions = helper.sortRecords(options,"label",component.get("v.sort"));
        }else{
            sortedOptions = options;
        }
        if(component.get("v.isDependent")){
            component.set("v.filteredOptions",sortedOptions[component.get("v.controllingValue")]);
        }else{
            var index = sortedOptions.findIndex(function(option){
                return option.value==component.get("v.value");
            })
            if(index==-1 && component.get("v.value")){
                sortedOptions.push({"label":component.get("v.value"),"value":component.get("v.value")});
            }
            component.set("v.filteredOptions",sortedOptions);
        }
    },
    valueChange:function(component, event, helper){
        if(component.get("v.unrestricted")){
            console.log('component.get("v.value") valueChange==>'+component.get("v.value"));
            var options = component.get("v.options");         
        if(component.get("v.value")){
            if(options.findIndex(x=>x.value==component.get("v.value")) == -1){	
                var obj={};
                obj['label']=component.get("v.value");
                obj['value']=component.get("v.value");
                options.push(obj);            
            }   
        }
            var sortedOptions = [];
            if(component.get("v.sort")=="asc" || component.get("v.sort")=="desc"){
                sortedOptions = helper.sortRecords(options,"label",component.get("v.sort"));
            }else{
                sortedOptions = options;
            }
            if(component.get("v.isDependent")){
                component.set("v.filteredOptions",sortedOptions[component.get("v.controllingValue")]);
            }else{
                component.set("v.filteredOptions",sortedOptions);
            }  
        }        
    }
})