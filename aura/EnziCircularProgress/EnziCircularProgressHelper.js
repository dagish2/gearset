({
	setGradients : function(component) {
        var val;
        if(component.get("v.order")=="desc"){
            val = (component.get("v.start")-component.get("v.value"))*component.get("v.counter");
        }else{
            val = component.get("v.value")*component.get("v.counter");
        }
        if(val<=50){
            component.set("v.under50",true);
            component.set("v.gradient1",90);
            component.set("v.gradient2",(90+(Math.floor(val*3.6))));
        }else{
            component.set("v.under50",false);
            component.set("v.gradient2",270);
            component.set("v.gradient1",(270+(Math.floor((val-50)*3.6))));
        }
	}
})