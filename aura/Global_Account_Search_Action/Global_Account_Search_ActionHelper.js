({
	showMessage : function(component, event, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message
        });
        toastEvent.fire();
	},
    refresh : function(component, event) {
        if($A.get("e.force:refreshView").getSource().isValid()) {
       		$A.get('e.force:refreshView').fire();
        }
    }
})