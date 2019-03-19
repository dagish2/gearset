({
    doInit : function(component, event, helper) {
        //component.find("utils").showProcessing();
        switch(component.get("v.mode")){
            case "new":
                component.set("v.header","New Record");
                break;
            case "edit":
                component.set("v.header","Edit Record");
                break;
            case "view":
                component.set("v.header","View Record");
                break;
            case "clone":
                component.set("v.header","Clone Record");
                break;
        }
        if(component.get("v.mode")=="new")
            component.set("v.record",{});
        var arrFields = [];
        if(component.get("v.useLayout")){
            if(component.get("v.mode")=="new"){
                component.find("utils").execute("c.getLayoutWithMapping",{"sObjectName":component.get("v.sObjectName")},function(response){
                    if(response.recordTypes.length>0){
                        component.set("v.setRecordType",true);
                        component.set("v.recordTypes",response.recordTypes);
                        component.set("v.rawLayout",response);
                        component.set("v.header","Select Record Type");
                    }else{
                        var layout = JSON.parse(response.default.layout).layouts[0];
                        helper.setLayout(component,layout,function(newLayout){
                            component.set("v.layout",newLayout);
                            component.set("v.setRecordType",false);
                        })
                        for(var key in component.get("v.defaultValues")){
                            component.set("v.record."+key,component.get("v.defaultValues")[key]);
                        }
                    }
                    //component.find("utils").hideProcessing();
                },function(error){
                    //component.find("utils").showError(error);                                                          
                })
            }else{
                component.find("utils").execute("c.getLayout",{"recordId":component.get("v.recordId")},function(response){
                    var data = JSON.parse(response);
                    var layout;
                    if(data.lstRecordTypes.length>0)
                        layout = JSON.parse(data.layout);
                    else
                        layout = JSON.parse(data.layout).layouts[0];
                    component.set("v.sObjectName",data.sObjectName);
                    helper.setLayout(component,layout,function(newLayout){
                        component.set("v.layout",layout);
                        var query = helper.getLayoutQuery(component,newLayout);
                        component.find("utils").execute("c.getQueryData",{"query":query},function(records){
                            var layoutSections = (component.get("v.mode")=="view"?layout.detailLayoutSections:layout.editLayoutSections);
                            for(var section in layoutSections){
                                for(var row in layoutSections[section].layoutRows){
                                    for(var cmp in layoutSections[section].layoutRows[row].layoutItems){
                                        if(layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents.length>0 && layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].type=="Field"){
                                            if(layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].components){
                                                records[0][layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].value] = "";
                                                for(var c in layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].components){
                                                    if(records[0][layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].components[c].value]!=undefined)
                                                        records[0][layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].value] += (records[0][layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].components[c].value]+" ");
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            for(var key in component.get("v.defaultValues")){
                                component.set("v.record."+key,component.get("v.defaultValues")[key]);
                            }
                            console.log(records[0]);
                            component.set("v.record",JSON.parse(JSON.stringify(records[0])));
                            //component.find("utils").hideProcessing();
                        },function(error){
                            component.find("utils").showError(error);
                            //component.find("utils").hideProcessing();
                        })
                        
                    })
                },function(error){
                    component.find("utils").showError(error);
                    //component.find("utils").hideProcessing();
                })
                
            }
        }else{
            for(var field in component.get("v.fields")){
                var arrField = [];
                arrField.push("c:EnziField");
                arrField.push({"sObjectName":component.get("v.sObjectName"),"fieldName":component.get("v.fields")[field],"value":component.getReference("v.record."+component.get("v.fields")[field]),"errors":component.getReference("v.errors"),"disabled":component.get("v.mode")=="view"});
                arrFields.push(arrField);
            }
            helper.createComponents(component,arrFields,function(components){
                component.set("v.body",components);
                if(component.get("v.mode")!="new"){
                    var query = 'Select Id,'+component.get("v.fields").join(",")+" FROM "+component.get("v.sObjectName")+" WHERE Id='"+component.get("v.recordId")+"'";
                    component.find("utils").execute("c.getQueryData",{"query":query},function(records){
                        component.set("v.record",records[0]);
                        component.find("utils").hideProcessing();
                    },function(error){
                        component.find("utils").showError(error);
                        //component.find("utils").hideProcessing();
                    })
                }else{
                    //component.find("utils").hideProcessing();
                }
            });
        }
    },
    cancel:function(component, event, helper){
        component.find("enziFormModal").close();
    },
    saveNext:function(component, event, helper){
        var arrFields = [];
        component.set("v.setRecordType",false);
        var layout = JSON.parse(component.get("v.rawLayout")[component.get("v.record.RecordTypeId")].layout);
        helper.setLayout(component,layout,function(newLayout){
            component.set("v.layout",newLayout);
            console.log(layout);
            component.set("v.header","New Record");
            for(var key in component.get("v.defaultValues")){
                component.set("v.record."+key,component.get("v.defaultValues")[key]);
            }
        })
    },
    save:function(component, event, helper){
        component.find("utils").showProcessing();
        var record = {};
        if(component.get("v.mode")!="clone"){
            for(var f in component.get("v.record")){
                if(f!="Id"){
                    record[f] = component.get("v.record."+f);
                }
            }
        }else{
            record = component.get("v.record");
        }
        
        //Change made by amol
        if(component.get("v.mode") == "edit")
            record["Id"] = component.get("v.record").Id;
        
        if(!record.hasOwnProperty('Id')){
            record['sobjectType'] = component.get("v.sObjectName");
        }
        component.find("utils").execute("c.saveRecord",{"record":JSON.parse(JSON.stringify(record))},function(response){
            record.Id = JSON.parse(response).id;
            component.find("utils").showSuccess("Record saved successfully!");
            helper.notifySave(component,record);
            component.find("enziFormModal").close();
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
    },
    saveNew:function(component, event, helper){
        component.find("utils").showProcessing();
        var record = component.get("v.record");
        if(component.get("v.mode")=="clone"){
            delete record['Id'];
        }
        if(!record.hasOwnProperty('Id')){
            record['sobjectType'] = component.get("v.sObjectName");
        }
        component.find("utils").execute("c.saveRecord",{"record":record},function(response){
            record.Id = JSON.parse(response).id;
            component.find("utils").showSuccess("Record saved successfully!");
            helper.notifySave(component,record);
            helper.resetForm(component);
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
    },
    saveInline:function(component,event,helper){
        if(component.get("v.sObjectName")==event.getParam('sObjectName')){
            var onSuccess =  event.getParam('onSuccess')(component.get("v.record.Id"));
        }        
    }
})