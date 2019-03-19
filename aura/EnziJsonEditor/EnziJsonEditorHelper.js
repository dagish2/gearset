({
	getElementBySelector : function(component,selector) {
        for(var i in component.getElements()){
            if(component.getElements()[i].nodeName!="#text" && component.getElements()[i].querySelector(selector)!=null){
                return component.getElements()[i].querySelector(selector);
                break;
            }
        }
	},
    getNewNameVersion:function(key,obj){
        var newKey = key;
        while(obj.hasOwnProperty(newKey)){
            newKey += '-copy';
        }
        return newKey;
    }
})