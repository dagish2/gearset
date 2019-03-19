({
	validate : function(component,setMsg) {
        if(component.get("v.customValidate")){
            component.set("v.valid",false);
            component.set("v.errorMessage",component.get("v.message"));
            this.setError(component,false);
        }else if(component.get("v.required") && this.checkRequired(component)){
            component.set("v.valid",false);
            if(setMsg)
                component.set("v.errorMessage","Fields marked with * are mandatory fields.");
            this.setError(component,false);
        }else if(component.get("v.value")!=undefined && component.get("v.type")=="email" && this.checkEmail(component, null)){
            component.set("v.valid",false);
            if(setMsg)
                component.set("v.errorMessage","Please enter a valid email address.");
            this.setError(component,false);
        }
        else if(component.get("v.value")!=undefined && component.get("v.type")=="phone" && this.checkPhone(component)){
            component.set("v.valid",false);
            if(setMsg)
                component.set("v.errorMessage","Please enter a valid phone number.");
            this.setError(component,false);
        }else if(component.get("v.value")!=undefined && (component.get("v.type")=="currency" || component.get("v.type")=="percent" || component.get("v.type")=="double" || component.get("v.type")=="number") && this.checkMinimumNumber(component)){
            component.set("v.valid",false);
            if(setMsg && component.get("v.message")!=undefined){
                component.set("v.errorMessage",component.get("v.message"));
            } else if(setMsg){                
                component.set("v.errorMessage","Invalid value.");
            }  
            this.setError(component,false);
        }else if(component.get("v.value")!=undefined && (component.get("v.type")=="currency" || component.get("v.type")=="percent" || component.get("v.type")=="double" || component.get("v.type")=="number") && this.checkMaximumNumber(component)){
            component.set("v.valid",false);
            if(setMsg && component.get("v.message")!=undefined){
                component.set("v.errorMessage",component.get("v.message"));
            } else if(setMsg){                
                component.set("v.errorMessage","Invalid value.");
            }
            this.setError(component,false);
        }else if(component.get("v.value")!=undefined && component.get("v.type")=="url" && this.checkUrl(component)){
            component.set("v.valid",false);
            if(setMsg && component.get("v.message")!=undefined){
                component.set("v.errorMessage",component.get("v.message"));
            } else if(setMsg){                
                component.set("v.errorMessage","Invalid URL.");
            }
            this.setError(component,false);
        }else{
            var errFlag = true;
            for(v in component.get("v.validations")){
                if(component.get("v.validations")[v].for.indexOf(component.get("v.name"))!=-1 && !component.get("v.validations")[v].validator()){
                    errFlag = false
                    component.set("v.valid",false);
                    component.set("v.errorMessage",component.get("v.validations")[v].message);
                    this.setError(component,false);
                    break;
                }
            }
            if(errFlag){
                component.set("v.valid",true);
                component.set("v.errorMessage","");
                this.setError(component,true);
            }
        }
	},
    setError:function(component,flag){
        if(!component.get("v.errors")){
             component.set("v.errors",{"mapValidations":{},"mapComponents":{}});
        }
        var errors = component.get("v.errors");
        if(errors && component.get("v.name")){
            errors["mapValidations"][component.get("v.name")] = flag;
            errors["mapComponents"][component.get("v.name")] = component;
            component.set("v.errors",errors);
        }
    },
    checkRequired:function(component){
        if(component.get("v.value")===undefined || component.get("v.value")==='' || String(component.get("v.value")).trim() === '' || component.get("v.value")==null){
            return true;
        }else{
            return false;
        }
    },
    checkEmail:function(component, checkEmailFromotherComponents){
        if(checkEmailFromotherComponents == null){
            checkEmailFromotherComponents = component.get("v.value");
        }
        if(checkEmailFromotherComponents.match(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)){
            return false;
        }else{
            return true;
        }
    },
    checkPhone:function(component){
       return false; 
        /* //if(component.get("v.value").match(/^[+(]{0,1}[0-9]{3}[)\.\- ]{0,1}[0-9]{3}[\.\- ]{0,1}[0-9]{1,8}$/)){
         if(component.get("v.value").match(/^[+(]{0,1}[0-9]{3}[)\.\- ]{0,1}[0-9]{3}[\.\- ]{0,1}[0-9]{1,8}$/)){
            return false;
        }else{
            return true;
        }*/
    },
    checkMinimumNumber:function(component){
        if(!(component.get("v.value")==undefined || component.get("v.value")==="")){
            if(component.get("v.min")!=="" && component.get("v.value")<component.get("v.min")){
            	return true;
            }else{
                return false;
            }
        }else{
         	return false;   
        }
    },
    checkMaximumNumber:function(component){
        if(!(component.get("v.value")==undefined || component.get("v.value")==="")){
            if(component.get("v.max")!=undefined && component.get("v.max")!=="" && component.get("v.value")>component.get("v.max")){
                return true;
            }else{
                return false;
            }
        }else{
         	return false;   
        }
    },
    checkUrl:function(component){
        if(component.get("v.value").match(/^((https?|ftp|smtp):\/\/)?(www.)?[a-zA-z0-9]+(-{1,3}[a-zA-z0-9]{1,})*(\.[a-z]{2,}){1,3}(#?\/?[a-zA-Z0-9#]+)*\/?(\?[a-zA-Z0-9-_]+=[a-zA-Z0-9-%]+&?)?$/)){
            return false;
        }else{
            return true;
        }
    }
})