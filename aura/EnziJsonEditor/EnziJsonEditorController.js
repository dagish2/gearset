({
	doInit : function(component, event, helper) {
        var data = component.get("v.data");
        var childs = [];
        for(var key in data){
            childs.push({"key":key,"value":data[key],"type":(typeof data[key])});
        }
        component.set("v.childs",childs);
        component.set("v.parentDelimeter",typeof data=="object"?(Array.isArray(data)?'['+childs.length+']':'{'+childs.length+'}'):(typeof data=="array"?'['+childs.length+']':''));
	},
    manageChild:function(component, event, helper){
        var id = event.currentTarget.id;
        if(id.split(":")[0]=="parent"){
            
        }else{
            var span = helper.getElementBySelector(component,"#childspan"+id.split(":")[0]);
            var input = helper.getElementBySelector(component,"#childinput"+id.split(":")[0]);
            switch(id.split(":")[1]){
                case "edit":
                   	$A.util.addClass(span,'slds-hide');
                    $A.util.removeClass(input,'slds-hide');
                    break;
                case "clone":
                    var index = parseInt(id.split(":")[0]);
                    var data = component.get("v.data");
                    var childs = component.get("v.childs");
                    if(component.get("v.parentDelimeter").includes("{")){
                        data[helper.getNewNameVersion(childs[index].key,data)] = childs[index].value
                    }else{
                        data.push(childs[index].value);
                    }
                    component.set("v.data",data);
                    break;
                case "remove":
                    var index = parseInt(id.split(":")[0]);
                    var data = component.get("v.data");
                    var childs = component.get("v.childs");
                    if(component.get("v.parentDelimeter").includes("{")){
                        delete data[childs[index].key];
                    }else{
                        data.splice(index,1);
                    }
                    component.set("v.data",data);
                    break;
            }
        }
    },
    editChild:function(component, event, helper){
        var id = event.currentTarget.id;
        var index = parseInt(id.split("-")[1]);
        if(id.split("-")[0]=="childkey"){
            if(component.get("v.parentDelimeter").includes("{")){
                var key = helper.getElementBySelector(component,"#childkey-"+index);
                var val = helper.getElementBySelector(component,"#childinputkey-"+index);
                $A.util.addClass(key,'slds-hide');
                $A.util.removeClass(val,'slds-hide');
                val.focus();
            }
        }else{
            var key = helper.getElementBySelector(component,"#childvalue-"+index);
            var val = helper.getElementBySelector(component,"#childinputvalue-"+index);
            $A.util.addClass(key,'slds-hide');
            $A.util.removeClass(val,'slds-hide');
            val.focus();
        }
    },
    saveData:function(component, event, helper){
        var id = event.currentTarget.id;
        var index = parseInt(id.split("-")[1]);
        var data = component.get("v.data");
        var originalData = component.get("v.originalData");
        var childs = component.get("v.childs");
        if(id.split("-")[0]=="childinputkey"){
            if(component.get("v.parentDelimeter").includes("{")){
                var key = helper.getElementBySelector(component,"#childkey-"+index);
                var val = helper.getElementBySelector(component,"#childinputkey-"+index);
                $A.util.removeClass(key,'slds-hide');
                $A.util.addClass(val,'slds-hide');
                var newData = {};
                var keyVal;
                if(event.currentTarget.value){
                    keyVal = event.currentTarget.value;
                }else{
                    keyVal = "new key";
                }
                for(var k in data){
                    if(k==childs[index].key){
                        newData[keyVal] = childs[index].value;
                    }else{
                        newData[k] = data[k];
                    }
                }
                data = newData;
            }
        }else{
            var key = helper.getElementBySelector(component,"#childvalue-"+index);
            var val = helper.getElementBySelector(component,"#childinputvalue-"+index);
            $A.util.removeClass(key,'slds-hide');
            $A.util.addClass(val,'slds-hide');
            var val;
            if(isNaN(event.currentTarget.value)){
                if(event.currentTarget.value=="true"){
                    val = true;
                }else if(event.currentTarget.value=="false"){
                    val = false;
                }else{
                    val = event.currentTarget.value;
                }
            }else{
                val = typeof(event.currentTarget.value)=="number"?parseInt(event.currentTarget.value):(event.currentTarget.value)==''?'new value':event.currentTarget.value;
            }
            data[childs[index].key] = val;
        }

       	component.set("v.data",data);
    },
    editParent:function(component, event, helper){
        var parentData = component.get("v.parentData");
        if(parentData && !Array.isArray(parentData)){
            var key = helper.getElementBySelector(component,"#parentKey");
            var val = helper.getElementBySelector(component,"#parentValue");
            $A.util.addClass(key,'slds-hide');
            $A.util.removeClass(val,'slds-hide');
            val.focus();
        }
    },
    saveParent:function(component, event, helper){
        var key = helper.getElementBySelector(component,"#parentKey");
        var val = helper.getElementBySelector(component,"#parentValue");
        $A.util.removeClass(key,'slds-hide');
        $A.util.addClass(val,'slds-hide');
        var parentData = component.get("v.parentData");
        var newData = {};
        var keyVal;
        if(event.currentTarget.value){
            keyVal = event.currentTarget.value;
        }else{
            keyVal = "new key";
        }
        for(var k in parentData){
            if(k==component.get("v.key")){
                newData[keyVal] = component.get("v.data");
            }else{
                newData[k] = parentData[k];
            }
        }
        parentData = newData;
        component.set("v.parentData",parentData);
    },
    manageParent:function(component, event, helper){
        var id = event.currentTarget.id;
        var data = component.get("v.data");
        var childs = component.get("v.childs");
        switch(id.split(':')[2]){
            case "add":
                switch(id.split(":")[1]){
                    case "string":
                        if(component.get("v.parentDelimeter").includes("{"))
                        	data[helper.getNewNameVersion('new string',data)] = "new string";
                        else
                            data.push("new string");
                        break;
                    case "number":
                        if(component.get("v.parentDelimeter").includes("{"))
                            data[helper.getNewNameVersion('new number',data)] = 0;
                        else
                            data.push(0);
                        break;
                    case "boolean":
                        if(component.get("v.parentDelimeter").includes("{"))
                            data[helper.getNewNameVersion('new boolean',data)] = false;
                        else
                            data.push(false);
                        break;
                    case "object":
                        if(component.get("v.parentDelimeter").includes("{"))
                            data[helper.getNewNameVersion('new object',data)] = {};
                        else
                            data.push({});
                        break;
                    case "array":
                        if(component.get("v.parentDelimeter").includes("{"))
                            data[helper.getNewNameVersion('new array',data)] = [];
                        else
                            data.push([]);
                        break;
                }
                component.set("v.data",data);
                break;
            case "clone":
                var parentData = component.get("v.parentData");
                if(Array.isArray(parentData)){
                    parentData.push(data);
                }else{
                    parentData[helper.getNewNameVersion(component.get("v.key"),parentData)] = data;
                }
                component.set("v.parentData",parentData);
                break;
            case "remove":
                var parentData = component.get("v.parentData");
                if(Array.isArray(parentData)){
                    parentData.splice(component.get("v.parentIndex"),1);
                }else{
                    delete parentData[component.get("v.key")];
                }
                component.set("v.parentData",parentData);
                break;
        }
    }
})