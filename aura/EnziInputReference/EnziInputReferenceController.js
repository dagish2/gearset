({
    doInit:function(component, event, helper){        
        if(component.get("v.value") && component.get("v.value")!=""){
            if(component.get("v.options") && component.get("v.options").length>0){
                var data = [];
                var options = component.get("v.options");
                for(var o in options){
                    if(options[o].value==component.get("v.value")){
                        component.set("v.keyword",options[o].label);
                        break;
                    }
                }
            }else{
                var arrQuery = [];
                for(var q in component.get("v.reference")){
                    if(component.get("v.fields")!=undefined && component.get("v.fields")!=""){
                        arrQuery.push("Select Id,Name,"+Object.keys(JSON.parse(component.get("v.fields"))).join(',')+" from "+component.get("v.reference")[q]+" where Id='"+component.get("v.value")+"'")
                    }else{
                        arrQuery.push("Select Id,Name from "+component.get("v.reference")[q]+" where Id='"+component.get("v.value")+"'")
                    }
                }
                component.find("utils").execute("c.getListQueryData",{"arrQuery":arrQuery},function(response){
                    var data = [];
                    for(var r in response){
                        data = data.concat(response[r]);
                    }
                    if(data.length>0){
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
                                        var temp = data[d][templst[0]];
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
                                        if(fieldNames[key]!="Id"&&fieldNames[key]!="Name"&&fieldNames[key]!="Email"&&fieldNames[key]!="Phone" && data[d][fieldNames[key]]){
                                            lst.push({name: searchFields[fieldNames[key]], value: data[d][fieldNames[key]]});
                                        }
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
                        component.set("v.keyword",data[0].Name);
                        if(component.get("v.name")=="CreatedById" || component.get("v.name")=="LastModifiedById"){
                            component.find("utils").execute("c.getTimezoneOffset",{},function(response){
                                component.set("v.timezoneOffset",parseInt(response));
                                component.find("utils").execute("c.getQueryData",{"query":"Select CreatedDate,LastModifiedDate from "+component.get("v.sObjectName")+" where id='"+component.get("v.recordId")+"'"},function(response){
                                    var dt;
                                    if(component.get("v.name")=="CreatedById"){
                                        dt = helper.decodeTimezoneValue(new Date(response[0].CreatedDate).getTime(),component);
                                    }
                                    if(component.get("v.name")=="LastModifiedById"){
                                        dt = helper.decodeTimezoneValue(new Date(response[0].LastModifiedDate).getTime(),component);
                                    }
                                    component.set("v.dateAffected",(helper.getDoubles(dt.getMonth()+1)+"/"+helper.getDoubles(dt.getDate())+"/"+dt.getFullYear()+" "+helper.getDoubles((dt.getHours()<12?(dt.getHours()==0?12:dt.getHours()):dt.getHours()-12))+":"+helper.getDoubles(dt.getMinutes())+" "+(dt.getHours()<12?"am":"pm")));
                                },function(error){
                                    component.find("utils").showError(error);
                                })
                            },function(error){
                                component.find("utils").showError(error);
                            })
                        }
                    }
                },function(error){
                    component.find("utils").showError(error);
                })
            }
            
        }else if(component.get("v.keyword")!=""){
            component.set("v.keyword","");
        }
    },
    selectOption: function(component, event, helper){	
        component.set("v.selectedIndex",event.currentTarget.getAttribute('data-index'));
        helper.select(component);
    },
    optionsChange:function(component, event, helper){
        var data = [];
        var options = component.get("v.options");
        var keyword = component.get("v.keyword");
        if(keyword){
            data = options.filter(function(option){
                if(option.label && option.label.toLowerCase().includes(keyword.toLowerCase())){
                    return true;
                }
            });
        }
        component.set("v.searchResult",data);
    },
    valueClear:function(component, event, helper){
        if(component.get("v.keyword")==undefined || component.get("v.keyword")==""){
            if(component.get("v.value")){
                component.set("v.value","");
            }
            if(component.getElements()[3]){
                var ele = component.getElements()[3].querySelector("button");
                ele.click();
            }
        }
    },
    blurReference:function(component, event, helper){
        setTimeout(function(){
            component.set("v.search", false);
        },500)
    },
    focusReference:function(component, event, helper){
        component.set("v.search", true);
    },
    keyupReference:function(component, event, helper){
        switch(event.keyCode){
            case 38:
                helper.selectUp(component);
                break;
            case 40:
                helper.selectDown(component);
                break;
            case 13:
                helper.select(component);
                break;
            default:
                component.set("v.keyword",event.target.value);
                if(event.target.value && event.target.value!="" && event.target.value.length>2){
                    helper.search(component,event.target.value);                        
                }
                break;
        }
    },
    defaultChange:function(component, event, helper){
        console.log('default change');
    }
})