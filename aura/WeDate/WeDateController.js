({
	doInit : function(component, event, helper) {
        component.set("v.today",new Date());
        if(component.get("v.value")){
            if(component.get("v.type") == 'date')
                component.set("v.keyword",helper.getSystemFormatedDate(new Date(component.get("v.value"))));
            else
                component.set("v.keyword",component.get("v.value"));
        }
        var years = [];
        for(var i=1970;i<=2050;i++){
            years.push(i);
        }
        component.set("v.years",years);
	},
    focus : function(component, event, helper) {
		component.set("v.show",true);
        helper.getCalenderData(component);
	},
    setDate:function(component, event, helper){
        if(event.currentTarget.id){
            component.set("v.value",event.currentTarget.id);
            component.set("v.keyword",helper.getFormatedDate(new Date(event.currentTarget.id)));
        }
    },
    getNextMonth:function(component, event, helper){
        var currIndex = component.get("v.months").indexOf(component.get("v.currentMonth"));
        if(currIndex==11){
            component.set("v.currentMonth",component.get("v.months")[0]);
            component.set("v.currentYear",parseInt(component.get("v.currentYear"))+1);
        }else{
            component.set("v.currentMonth",component.get("v.months")[currIndex+1]);
        }
        helper.getCalenderData(component)
    },
    getPrevMonth:function(component, event, helper){
        var currIndex = component.get("v.months").indexOf(component.get("v.currentMonth"));
        if(currIndex==0){
            component.set("v.currentMonth",component.get("v.months")[11]);
            component.set("v.currentYear",parseInt(component.get("v.currentYear"))-1);
        }else{
            component.set("v.currentMonth",component.get("v.months")[currIndex-1]);
        }
        helper.getCalenderData(component);
    },
    valueChange:function(component, event, helper){
        if(component.get("v.value")){ 
            component.set("v.keyword",helper.getSystemFormatedDate(new Date(component.get("v.value"))));
        }
        if(component.get("v.validate") && component.find(component.get("v.auraId"))){
            var validity = component.find(component.get("v.auraId")).get('v.validity');
            if(validity){
                var errors = component.get("v.errors");
                errors[component.get("v.index")] = validity.valid;
                component.set("v.errors",errors);
            }
        }
    },
    yearChange:function(component, event, helper){
        component.set("v.currentYear",parseInt(event.target.value));
        helper.getCalenderData(component);
    },
    setToday:function(component,event,helper){        
        component.set("v.value",helper.getSystemFormatedDate(component.get("v.today")));
    	component.set("v.keyword",helper.getFormatedDate(component.get("v.today")));
        component.set("v.show",false);
    },
    clear:function(component,event,helper){
        component.set("v.value","");
    	component.set("v.keyword","");
    },
    close:function(component,event,helper){
        component.set("v.show",false);
    }
})