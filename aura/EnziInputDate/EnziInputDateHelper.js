({
	getCalenderData : function(component,helper) {
        console.log('init get calender');
        var dt = new Date(component.get("v.currentYear"),component.get("v.months").indexOf(component.get("v.currentMonth")),01);
        var day = dt.getDay();
        var data = [];
        var week = [];
        console.log('above upper');
        var upper,lower;
        if(component.get("v.upperBound"))
        	upper = (typeof component.get("v.upperBound")=="object"?component.get("v.upperBound"):new Date(this.getDateObject(component.get("v.upperBound"))));
        if(component.get("v.lowerBound"))
        	lower = (typeof component.get("v.lowerBound")=="object"?component.get("v.lowerBound"):new Date(this.getDateObject(component.get("v.lowerBound"))));
        var dtPointer = dt;
        dtPointer.setDate(dtPointer.getDate()-day);
        console.log('after date pointer');
        for(var i=0;i<day;i++){
            var objDate = {"label":dtPointer.getDate(),"disabled":true,"value":this.getSystemFormatedDate(dtPointer),"today":this.getSystemFormatedDate(dtPointer)==this.getSystemFormatedDate(component.get("v.todaysDate"))};
			week.push(objDate);
            dtPointer.setDate(dtPointer.getDate()+1);
        }
        console.log('after disabled1');
        while(dtPointer.getMonth()==component.get("v.months").indexOf(component.get("v.currentMonth"))){
            var objDate = {"label":dtPointer.getDate(),"disabled":false,"value":this.getSystemFormatedDate(dtPointer),"selected":this.getSystemFormatedDate(dtPointer)==this.getSystemFormatedDate(component.get("v.currentDate")),"today":this.getSystemFormatedDate(dtPointer)==this.getSystemFormatedDate(component.get("v.todaysDate"))};
			if(upper)
                objDate.disabled = dtPointer.getTime()<upper.getTime();
            if(lower)
                objDate.disabled = dtPointer.getTime()>lower.getTime();
            week.push(objDate);
            dtPointer.setDate(dtPointer.getDate()+1)
            if(week.length==7){
                data.push(week);
                week=[];
            }
        }
        console.log('after real data');
        while(week.length<7){
            var objDate = {"label":dtPointer.getDate(),"disabled":true,"value":this.getSystemFormatedDate(dtPointer),"today":this.getSystemFormatedDate(dtPointer)==this.getSystemFormatedDate(component.get("v.todaysDate"))};
			week.push(objDate);
            dtPointer.setDate(dtPointer.getDate()+1)
            if(week.length==7){
                data.push(week);
            }
        }
        console.log('after disabled2');
        console.log(data);
        return data;
	},
    getSystemFormatedDate:function(dt){
        return dt.getFullYear()+'-'+this.getDoubles(dt.getMonth()+1)+'-'+this.getDoubles(dt.getDate());
    },
    getFormatedDate:function(ticks){
        var dt = new Date(ticks);
        return (this.getDoubles(dt.getMonth()+1))+"/"+this.getDoubles(dt.getDate())+"/"+dt.getFullYear();
    },
    getDoubles:function(no){
        if(no<10){
            return "0"+no;
        }else{
            return no;
        }
    },
    encodeTimezoneValue:function(value,component){
        if((new Date().getTimezoneOffset()*60*1000)>0){
            value += (new Date().getTimezoneOffset()*60*1000);
        }else{
            value -= (new Date().getTimezoneOffset()*60*1000);
        }
        return new Date(value);
    },
    decodeTimezoneValue:function(value,component){
        if(component.get("v.timezoneOffset")>0){
            value += component.get("v.timezoneOffset");
        }else{
            value -= component.get("v.timezoneOffset");
        }
        if((new Date().getTimezoneOffset()*60*1000)>0){
            value -= (new Date().getTimezoneOffset()*60*1000);
        }else{
            value += (new Date().getTimezoneOffset()*60*1000);
        }
        return new Date(value);
    },
    getDateObject:function(dt){
        return new Date(parseInt(dt.split('-')[0]),parseInt(dt.split('-')[1])-1,parseInt(dt.split('-')[2]));
    }
})