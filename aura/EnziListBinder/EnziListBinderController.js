({
    valueChange : function(component, event, helper) {
        var lst = component.get("v.list");
        if(lst[component.get("v.index")]){
            lst[component.get("v.index")][component.get("v.field")] = component.get("v.value");
            if(lst[component.get("v.index")][component.get("v.field")]!=component.get("v.value"))
                component.set("v.list",lst);
        }
    }
})