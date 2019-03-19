({
    openPopup : function(component, event, helper) {
        component.set("v.icon",component.get("v.icon")=="utility:chevronright" ? "utility:chevrondown" : "utility:chevronright");
        if(!component.get("v.show")){
            component.set("v.show", !component.get("v.show"));
            if(!component.get("v.recordsData") && event.currentTarget.getAttribute('data-value')){
                component.set("v.recordsData", [JSON.parse(event.currentTarget.getAttribute('data-value'))]);
            }
        }else{
            component.set("v.show", !component.get("v.show"));
        }
        component.set("v.showData", component.get("v.show"));
    }
})