({
    rerender : function(component, helper){
        this.superRerender();
        var fName = component.get("v.fieldName");
        if(component.get("v.retryValidate") && component.get("v.needToValidate")){
            helper.validate(component,true);
        }
    }
})