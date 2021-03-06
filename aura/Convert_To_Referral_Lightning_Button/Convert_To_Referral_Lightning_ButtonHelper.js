({
    execute: function(component, method, params, onSuccess, onError){
      
        var action = component.get(method);
        action.setParams(params);
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                onSuccess(response.getReturnValue());
            }else if(response.getState()=="ERROR"){
                var errors = response.getError();
                onError(errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
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