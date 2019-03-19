({
	getCalenderData:function(component) {
        var dtPointer;
        if(component.get("v.value")){
            dtPointer = new Date(new Date(component.get("v.value")).getFullYear()+'-'+(new Date(component.get("v.value")).getMonth()+1)+'-1');
        }else{
            dtPointer = new Date(new Date(component.get("v.today")).getFullYear()+'-'+(new Date(component.get("v.today")).getMonth()+1)+'-1');
        }
        component.set("v.currentMonth",component.get("v.months")[dtPointer.getMonth()])
        dtPointer.setDate(dtPointer.getDate()-dtPointer.getDay());
        var data = [];
        var week = [];
        while(dtPointer.getDate()!=1){
            var objDate = {"label":dtPointer.getDate(),"disabled":true,"value":this.getSystemFormatedDate(dtPointer),"today":this.getSystemFormatedDate(dtPointer)==this.getSystemFormatedDate(component.get("v.today"))};
			week.push(objDate);
            dtPointer.setDate(dtPointer.getDate()+1);
        }
        var currentMonth = dtPointer.getMonth();
        while(dtPointer.getMonth()==currentMonth){
            var objDate = {"label":dtPointer.getDate(),"disabled":false,"value":this.getSystemFormatedDate(dtPointer),"selected":(component.get("v.value")?(this.getSystemFormatedDate(dtPointer)==this.getSystemFormatedDate(new Date(component.get("v.value")))):false),"today":this.getSystemFormatedDate(dtPointer)==this.getSystemFormatedDate(component.get("v.today"))};
            week.push(objDate);
            dtPointer.setDate(dtPointer.getDate()+1)
            if(week.length==7){
                data.push(week);
                week=[];
            }
        }
        while(week.length<7){
            var objDate = {"label":dtPointer.getDate(),"disabled":true,"value":this.getSystemFormatedDate(dtPointer),"today":this.getSystemFormatedDate(dtPointer)==this.getSystemFormatedDate(component.get("v.today"))};
			week.push(objDate);
            dtPointer.setDate(dtPointer.getDate()+1)
            if(week.length==7){
                data.push(week);
            }
        }
        component.set("v.calenderData",data);
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
    }
})