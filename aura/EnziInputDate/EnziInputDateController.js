({
    doInit:function(component, event, helper){ 
        component.find("utils").execute("c.getTodaysDate",{},function(today){
            component.set("v.todaysDate",helper.getDateObject(today));
            if(component.get("v.value") && component.get("v.value")!=""){
                component.set("v.currentDate",helper.getDateObject(component.get("v.value")));
                component.set("v.dateString",helper.getFormatedDate(helper.getDateObject(component.get("v.value"))));
            }else{
                component.set("v.currentDate",helper.getDateObject(today));
            }
            var years = [];
            for(var i=1900;i<=2050;i++){
                years.push(i);
            }
            component.set("v.years",years);
            var months = ["January","February","March","April","May","June","July","August","September","October","November","December"];
            component.set("v.months",months);
            var days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
            component.set("v.days",days);
            component.set("v.currentMonth",component.get("v.months")[component.get("v.currentDate").getMonth()]);
            component.set("v.currentYear",component.get("v.currentDate").getFullYear());
        },function(error){
            component.find("utils").showError(error);
        })
        
    },
    getPicker:function(component, event, helper){
        console.log(component.get("v.years"));
        console.log(component.get("v.days"));
        console.log(component.get("v.todaysDate"));
        console.log(component.get("v.currentDate"));
        console.log(component.get("v.months"));
        console.log(component.get("v.currentMonth"));
        console.log(component.get("v.currentYear"));
        
        console.log('in get picker');
        if(component.get("v.currentYear")!=undefined){
            var calData = helper.getCalenderData(component,helper);
            console.log(calData);
            component.set("v.calenderData",calData);
            console.log('after set data');
            component.set("v.show",true);
            console.log('after show data');
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
        var calData = helper.getCalenderData(component,helper);
        component.set("v.calenderData",calData);
        console.log(component.get("v.calenderData"));
    },
    getPrevMonth:function(component, event, helper){
        var currIndex = component.get("v.months").indexOf(component.get("v.currentMonth"));
        if(currIndex==0){
            component.set("v.currentMonth",component.get("v.months")[11]);
            component.set("v.currentYear",parseInt(component.get("v.currentYear"))-1);
        }else{
            component.set("v.currentMonth",component.get("v.months")[currIndex-1]);
        }
        var calData = helper.getCalenderData(component,helper);
        component.set("v.calenderData",calData);
        console.log(component.get("v.calenderData"));
    },
    yearChange:function(component, event, helper){
        component.set("v.currentYear",parseInt(event.target.value));
        var calData = helper.getCalenderData(component,helper);
        component.set("v.calenderData",calData);
        console.log(component.get("v.calenderData"));
    },
    setDate:function(component, event, helper){
        if(event.target.id!=''){
            component.set("v.value",event.target.id);
            component.set("v.dateString",helper.getFormatedDate(helper.getDateObject(event.target.id)));
            component.set("v.show",false);
            var ele = component.getElements()[3].querySelector("button");
            ele.click();
        }
    },
    setToday:function(component,event,helper){        
        component.set("v.value",helper.getSystemFormatedDate(component.get("v.todaysDate")));
    	component.set("v.dateString",helper.getFormatedDate(component.get("v.todaysDate")));
        component.set("v.show",false);
        var ele = component.getElements()[3].querySelector("button");
        ele.click();
    },
    clear:function(component,event,helper){
        component.set("v.value","");
    	component.set("v.dateString","");
        var ele = component.getElements()[3].querySelector("button");
        ele.click();
    },
    close:function(component,event,helper){
        component.set("v.show",false);
    },
    valueChange:function(component,event,helper){
        if(component.get("v.value") && typeof component.get("v.value")=="string"){
            component.set("v.dateString",helper.getFormatedDate(helper.getDateObject(component.get("v.value"))));
        }else if(component.get("v.value")==undefined){
             component.set("v.dateString","");
        }
    },
    boundsChanged:function(component,event,helper){
        var calData = helper.getCalenderData(component,helper);
        component.set("v.calenderData",calData);
    },
    defaultChange:function(component,event,helper){
        
    }
})