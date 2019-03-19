({
	doInit : function(component, event, helper) {
        var obj = component.get("v.obj");
        var nameObj;
        if(component.get("v.col").search("toLabel")!=-1){
            var col = component.get("v.col");
            component.set("v.col",(col.substring(8,col.length-1)));
        }
        for(var field in component.get("v.col").split(".")){
            if(obj && component.get("v.isNameField") && parseInt(field)==component.get("v.col").split(".").length-1){
                nameObj = JSON.parse(JSON.stringify(obj));
            }
            if(obj && obj.hasOwnProperty(component.get("v.col").split(".")[field]))
            	obj = obj[component.get("v.col").split(".")[field]];
            else
                obj = "";
        }
        if(obj==undefined){
            obj = "";
        }
        if(component.get("v.type")=='component'){
            if(Array.isArray(component.get("v.field.component"))){
                helper.addComponents(component.get("v.field.component"),component);
            }else{
                helper.addComponent(component.get("v.field.component.name"),helper.parseAttributes(component,component.get("v.field.component.attributes"),helper),component);
            }
        }else{
            component.set("v.objVal",nameObj);
            component.set("v.val",obj);
        }
	},
    setDataAttributes:function(component, event, helper){
        setTimeout(function(){
            if(component.get("v.type")=="component"){
                var elements = component.getElements();
                for(var ele in elements){
                    if(elements[ele] && ['INPUT', 'TEXTAREA', 'SELECT', 'BUTTON','A'].includes(elements[ele].nodeName)){
                        elements[ele].setAttribute('data-value',JSON.stringify(component.get("v.obj")));
                    }
                    if(elements[ele].nodeName!='#text'){
                        var queryElements = elements[ele].querySelectorAll('input, textarea, select, button','a');
                        if(queryElements.length>0){
                            for(var e=0;e<queryElements.length;e++){
                                queryElements[e].setAttribute('data-value',JSON.stringify(component.get("v.obj")));
                            }
                        }
                    }
                }
            }
        },3000)
    },
    recordChanged:function(component, event, helper){
        if(event.getParam('oldValue') != event.getParam('value')){
            var lst = component.get("v.list");
            if(lst && lst != undefined){
                component.set("v.list["+component.get("v.index")+"]",component.get("v.obj"));   
            }            
        }
    }
})