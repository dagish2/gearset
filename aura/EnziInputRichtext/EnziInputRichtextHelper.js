({
	appliedStyle : function(component,helper) {
		var myMap = component.get("v.isApplied");
        for (var key in myMap){
            var state = document.queryCommandState(key);
        	component.set("v.isApplied."+key,state);
        }
	}
})