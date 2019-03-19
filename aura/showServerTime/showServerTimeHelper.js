({
    showClock : function(component) {
        var helper = this;
        var today = new Date();
        var utc = today.getTime() + (today.getTimezoneOffset() * 60000);
        today = new Date(utc + (3600000*(component.get("v.offset"))));
        var hr = today.getHours();
        var min = today.getMinutes();
        var sec = today.getSeconds();
        var ap = (hr < 12) ? "AM" : "PM";
        hr = (hr == 0) ? 12 : hr;
        hr = (hr > 12) ? hr - 12 : hr;
        //Add a zero in front of numbers<10
        hr  = helper.checkTime(hr); 
        min = helper.checkTime(min);
        sec = helper.checkTime(sec);
        document.getElementById("clock").innerHTML = today.getDate() +"/"+(today.getMonth() + 1)+"/"+today.getFullYear()+" "+hr + " : " + min + " : " + sec + " " + ap;
        var time = setTimeout(function(){ helper.showClock(component) }, 500);
    },
    checkTime : function(i){
        if (i < 10) {
            i = "0" + i;
        }
        return i;
    },
    getUserTimeZoneOffset : function(component){
        component.find("utils").execute("c.getTimezoneOffset",{},function(offset){
            component.set("v.offset",parseFloat((offset/(1000*60*60))%24));
        },function(error){
            component.find("utils").showError(error);
        })
    }
})