({
    afterRender:function(component, helper){
        var ele = component.find("select").getElements()[0];
        ele.addEventListener("change",function(evt){
            component.set("v.value",evt.target.value);
        })
    }
})