({
    holdOffReservableLightning: function(component, helper,onSuccess){
        helper.execute(component,
                       "c.holdOffReservableLightning", 
                       {
                           "holdId":component.get("v.recordId"), 
                           "sourcePage":component.get("v.sourcePage")
                       },
                       function(response){
                           var result = JSON.parse(JSON.parse(response));
                           onSuccess(result);
                       }, function(error){
                           component.find("utils").showError(error);
                       });
    },
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
    }
})