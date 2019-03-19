({
	getFormatedDate : function (date){
        var newDate = new Date(new Date(date).getTime()+(new Date().getTimezoneOffset()*60*1000))
        return ("0" + (newDate.getMonth() + 1)).slice(-2) + "/" + ("0" + newDate.getDate()).slice(-2) +"/"+newDate.getFullYear();
    },
    cancel : function(component, event, helper){
        parent.postMessage('close',location.origin); 
        self.close();
        location.refresh();
    }
})