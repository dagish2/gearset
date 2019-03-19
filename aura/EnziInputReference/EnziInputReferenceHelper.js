({
    selectUp : function(component) {
        var index = component.get("v.selectedIndex")==0?0:(component.get("v.selectedIndex")-1);
        component.set("v.selectedIndex",index);
    },
    selectDown : function(component) {
        var index = component.get("v.selectedIndex")==(component.get("v.searchResult").length-1)?(component.get("v.searchResult").length-1):(component.get("v.selectedIndex")+1);
        component.set("v.selectedIndex",index);
    },
    select : function(component){
        var mapResult = component.get("v.searchResultMap");
        var lst = component.get("v.searchResult");
        var index = component.get("v.selectedIndex");
        (index != undefined) ? component.set("v.keyword",lst[index].label) : '';
        (index != undefined) ? component.set("v.value",lst[index].value) : '';  
        component.set("v.search",false);
        component.set("v.selectedIndex",0);
        var ele = component.getElements()[3].querySelector("button");
        ele.click();
    },
    search:function(component,keyword){
        var helper = this;
        if(component.get("v.options") && component.get("v.options").length>0){
            component.set("v.selectedIndex",0);
            component.set("v.dirty",true);
            component.set("v.search",true);
            var data = [];
            var options = component.get("v.options");
            data = options.filter(function(option){
                if(option.label && option.label.toLowerCase().includes(keyword.toLowerCase())){
                    return true;
                }
            });
            component.set("v.searchResult",data);
            component.find("referenceSpinner").hideProcessing();
        }else{
            component.set("v.selectedIndex",0);
            component.set("v.dirty",true);
            component.set("v.search",true);
            var referenceObject = component.get("v.reference");
            var name = component.get("v.name");
            component.set("v.keyword",keyword);
            var arrQuery = [];
            for(var q in component.get("v.reference")){
                if(component.get("v.searchFields") && component.get("v.searchFields").length && component.get("v.fields")!=undefined && component.get("v.fields")!=""){
                    arrQuery.push("Select Id,Name,"+Object.keys(JSON.parse(component.get("v.fields"))).join(',')+" from "+component.get("v.reference")[q]+" where "+(component.get("v.criteria")?(component.get("v.criteria")+' AND '):'')+"("+component.get("v.searchFields").join(" like '%"+component.find("utils").addSlashes(keyword)+"%' OR ")+" like '%"+component.find("utils").addSlashes(keyword)+"%') LIMIT 10");
                }else if(component.get("v.fields")!=undefined && component.get("v.fields")!=""){
                    arrQuery.push("Select Id,Name,"+Object.keys(JSON.parse(component.get("v.fields"))).join(',')+" from "+component.get("v.reference")[q]+" where "+(component.get("v.criteria")?(component.get("v.criteria")+' AND '):'')+" Name like '%"+component.find("utils").addSlashes(keyword)+"%' LIMIT 10");
                }else if(component.get("v.searchFields") && component.get("v.searchFields").length){
                    arrQuery.push("Select Id,Name from "+component.get("v.reference")[q]+" where "+(component.get("v.criteria")?(component.get("v.criteria")+' AND '):'')+"("+component.get("v.searchFields").join(" like '%"+component.find("utils").addSlashes(keyword)+"%' OR ")+" like '%"+component.find("utils").addSlashes(keyword)+"%') LIMIT 10");
                }else{
                    arrQuery.push("Select Id,Name from "+component.get("v.reference")[q]+" where "+(component.get("v.criteria")?(component.get("v.criteria")+' AND '):'')+" Name like '%"+component.find("utils").addSlashes(keyword)+"%' LIMIT 10");
                }
            }
            if(keyword && keyword.length>=2){
                component.find("referenceSpinner").showProcessing();
                component.find("utils").execute("c.getListQueryData",{"arrQuery":arrQuery},function(response){
                    var data = [];
                    for(var r in response){
                        data = data.concat(response[r]);
                    }
                    var result;
                    var fields;
                    var searchResult = [];
                    if(component.get("v.fields")!=undefined && component.get("v.fields")!=""){
                        for(var d in data){
                            result={};
                            result["value"]=data[d]["Id"];
                            data[d]["Name"]!=undefined?result["label"]=data[d]["Name"]:'';
                            var lst=[];
                            var searchFields = JSON.parse(component.get("v.fields"));
                            var fieldNames = Object.keys(searchFields);
                            for(var key in fieldNames){
                                if(fieldNames[key].includes('.')){
                                    var templst = fieldNames[key].split('.');
                                    var temp = data[d][templst[0]] ;
                                    if(temp != undefined && temp != "" && templst != undefined && templst != ""){
                                        for(var iIndex=1 ; iIndex < templst.length;iIndex++){
                                            if(temp != undefined && temp[templst[iIndex]] != undefined && temp != "" && temp[templst[iIndex]] != ""){
                                                if(typeof(temp[templst[iIndex]])=="Object"){
                                                    temp = temp[templst[iIndex]];
                                                }else{
                                                    temp = temp[templst[iIndex]];
                                                    lst.push({name: searchFields[fieldNames[key]], value: temp});
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }else{
                                    lst.push({name: searchFields[fieldNames[key]], value: data[d][fieldNames[key]]});
                                }
                                
                            }
                            result["fields"] =lst.length>0 ? lst : undefined ;
                            searchResult.push(result);
                        }
                    }else{
                        for(var d in data){
                            searchResult.push({'label':data[d].Name,'value':data[d].Id});
                        }
                    }
                    component.set("v.searchResult",searchResult);
                    component.find("referenceSpinner").hideProcessing();
                },function(error){
                    component.find("utils").showError(error);
                })
            }
            else{
                component.set("v.search",false);
                component.set("v.value","");
            }
        }
    },
    decodeTimezoneValue:function(value,component){
        value += (new Date().getTimezoneOffset()*60*1000);
        value += component.get("v.timezoneOffset");
        return new Date(value);
    },
    getDoubles:function(no){
        if(no<10){
            return "0"+no;
        }else{
            return no;
        }
    }
})