({
    doInit : function(component, event, helper) {
        helper.holdOffReservableLightning(component,helper, function(result){                
            if(result.office_hold != undefined && !result.office_hold.active){
                component.find("utils").showSuccess("Hold Off Successfully");
                var timer = setTimeout(function(){
                    $A.get("e.force:closeQuickAction").fire();
                }, 1500);
            } else if(result.hasOwnProperty("error")){
                component.find("utils").showError(result.error);
                var timer = setTimeout(function(){
                    $A.get("e.force:closeQuickAction").fire();
                }, 1500);
            }
        });
    },
    closePopUp : function(component, event, helper) {$A.get("e.force:closeQuickAction").fire();}
})