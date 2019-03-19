({
    doInit:function(component, event, helper){
        helper.validate(component,false);
    },
    valueChange : function(component, event, helper) {
        helper.validate(component,true);
	},
    validateByName:function(component, event, helper){
        helper.validate(component,true);
    },
    validateFromOtherComponent:function(component, event, helper){
        let params = event.getParam('arguments');
        if(params){
            let typetoCheck = params.typetoCheck;
            if(typetoCheck && typetoCheck.toLowerCase() == 'email'){
                return helper.checkEmail(component, params.stringtoCheck);
            }
        }
    }
})