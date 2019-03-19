({
	doInit : function(component, event, helper) {
		window.addEventListener("message", function(event) {
            switch(event.data){
                case "close":
                    console.log("close");
                    component.destroy();
                    break;
                case "closeAndRefresh":
                    console.log("closeAndRefresh");
					component.destroy();
                    window.location.reload();
                    break;
            }
        }, false);
	},
    close : function(component, event, helper) {
		component.destroy();
	},
    setHeight:function(component, event, helper){
        event.currentTarget.style.height = (window.innerHeight - 174) + "px"
    }
})