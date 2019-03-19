({
    confirm : function(component, event, helper) {
        component.find("confirmModal").close();
        if(component.get("v.confirm"))
            component.get("v.confirm")();
    },
    decline:function(component, event, helper){
        component.find("confirmModal").close();
        if(component.get("v.decline"))
            component.get("v.decline")();
    }
})