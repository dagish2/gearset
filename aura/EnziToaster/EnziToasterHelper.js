({
	hideToaster : function(component,time) {
        setTimeout(function(){
            component.set("v.show",false);
        },time);
	},
    showToaster : function(component) {
		component.set("v.show",true);
	}
})