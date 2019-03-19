({
	change : function(component, event, helper) {
        if(event.target.value==undefined || event.target.value==""){
            component.set("v.value","");
        }else{
            component.set("v.value",parseInt(event.target.value));
        }
	}
})