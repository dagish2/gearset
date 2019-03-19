({
	addComponent : function(element,attributes,component) {
        $A.createComponent(element,attributes,function(cmp, status, errorMessage){
            if(status === "SUCCESS") {
                component.set("v.body", cmp);
            }else if (status === "INCOMPLETE") {
                console.log("No response from server or client is offline.");
            }else if (status === "ERROR") {
                console.log("Error: " + errorMessage);
            }
        });
	},
    addComponents : function(elements,component,helper) {
        var components = [];
        for(var e in elements){
            var ele = [];
            ele.push(elements[e].name);
            ele.push(this.parseAttributes(component,elements[e].attributes,this));
            components.push(ele);
        }
        $A.createComponents(components,function(cmp, status, errorMessage){
            if (status === "SUCCESS") {
                component.set("v.body", cmp);
            }else if (status === "ERROR") {
                console.log("Error: " + errorMessage);
            }
        });     
	},
    parseAttributes:function(component,attr,helper){
        var parseObj = {};
        for(var key in attr){
            parseObj[key] = attr[key];
        }
        for(var key in parseObj){
            if(typeof(parseObj[key])=="string" && parseObj[key].startsWith("{!") && parseObj[key].endsWith("}")){
                var modal = parseObj[key].substr(2,parseObj[key].length-3);
                parseObj[key] = component.getReference("v.obj."+modal);
            }
            else if(typeof(parseObj[key])=="string"){
                var exp = this.getDynamicExpression(parseObj[key]);
                for(var e in exp){
                    if(component.get("v.obj."+exp[e])){
                        parseObj[key] = parseObj[key].replace("{{"+exp[e]+"}}",component.get("v.obj."+exp[e]));
                    }else{
                        parseObj[key] = parseObj[key].replace("{{"+exp[e]+"}}","");
                    }
                }
                if(parseObj[key].includes("==") || parseObj[key].includes("!=") || parseObj[key].includes("<") || parseObj[key].includes(">") || parseObj[key].includes("<=") || parseObj[key].includes(">=")){
                    try{
                        eval("parseObj[key]=("+(parseObj[key])+")");
                    }catch(error){
                        parseObj[key]=parseObj[key];
                    }
                }
            }else if(Array.isArray(parseObj[key])){
                var parsedArray = [];
                for(var obj in parseObj[key]){
                    parsedArray.push(helper.parseAttributes(component,parseObj[key][obj],helper));
                }
                parseObj[key] = parsedArray;
            }
        }
        return parseObj;
    },
    getDynamicExpression:function(exp){
        var re = new RegExp('[^{\}]+(?=})','g');
        var expressions = exp.match(re);
        return expressions;
    }
})