({
    doInit:function(component, event, helper){
        console.log(component.get("v.options"));
        component.set("v.filteredOptions",helper.getFilteredOptions(component,""));
        helper.initOptionsMap(component);
        helper.generatePills(component);
    },
    select:function(component, event, helper){
       component.set("v.value",(component.get("v.value")?(component.get("v.value")+";"):"")+component.get("v.filteredOptions")[parseInt(event.currentTarget.id.split(":")[1])].value);
    },
    remove:function(component, event, helper){ 
        var value = component.get("v.value");
        var arrValue = value.split(";");
        arrValue.splice(arrValue.indexOf(component.get("v.result")[parseInt(event.currentTarget.id.split(":")[1])].value),1);
        component.set("v.value",arrValue.join(";"));
    },
    showOptions:function(component, event, helper){
        component.set("v.showOptions", true);
    },
    searchOption:function(component, event, helper){
        component.set("v.filteredOptions",helper.getFilteredOptions(component,event.target.value));
    },
    valueChange:function(component,event,helper){
        helper.generatePills(component);
    },
    optionsChange:function(component,event,helper){
       	helper.initOptionsMap(component);
        component.set("v.filteredOptions",helper.getFilteredOptions(component,component.get("v.searchKeyword")));
        helper.generatePills(component);
    },
    showMoreLess:function(component,event,helper){
        component.set("v.showAll",!component.get("v.showAll"));
        component.set("v.filteredOptions",helper.getFilteredOptions(component,component.get("v.searchKeyword")));
    }
})