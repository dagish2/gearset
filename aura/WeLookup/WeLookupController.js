({
	doInit : function(component, event, helper) {
        if(component.get("v.value")){
            helper.getName(component);
        }
	},
    valueChange:function(component, event, helper){
        if(event.getParam("value")!=component.get("v.value") && component.get("v.value")){
            helper.getName(component);
        }else if(event.getParam("value")!=undefined && component.get("v.keyword")==undefined  && component.get("v.value")){
            helper.getName(component);
        }
        helper.validate(component)
    },
    focus:function(component, event, helper){
        component.set("v.show",true);
    },
    blur:function(component, event, helper){
        setTimeout(function(){
            component.set("v.show",false);
        },200);
    },
    search:function(component, event, helper){
        component.set("v.isSearching",true); 
        helper.getResults(component, helper); 
    },
    select:function(component, event, helper){
        component.set("v.value",event.currentTarget.id.split(':')[0]);
        component.set("v.keyword",event.currentTarget.id.split(':')[1]);
        component.set("v.isSearching",false); 
    }
})