({
	doInit : function(component, event, helper) {
        var start = component.get("v.start");
        var end = component.get("v.end");
        var diff;
        if(start<=end){
            component.set("v.order","asc");
            diff = end-start;
        }else{
            component.set("v.order","desc");
            diff = start-end;
        }
        component.set("v.counter",(100/diff));
		helper.setGradients(component);
	},
    valueChange : function(component, event, helper) {
		helper.setGradients(component);
	}
})