({
    push : function(record,component) {
        if(component.get("v.mode")=="edit"){
            this.replace(record,component);
        }else{
            var data = component.get("v.tableData");
            data.unshift(record);
            component.set("v.tableData",data);
        }
    },
    replace:function(record,component){
        var data = component.get("v.tableData");
        var index;
        for(var i in data){
            if(data[i].Id==record.Id){
                index = i;
            }
        }
        data[index] = record;
        component.set("v.tableData",data);
    },
    resetForm:function(component){
        component.set("v.header","New Record");
        component.set("v.mode","new");
        component.set("v.record",{});
        var arrFields = [];
        for(var field in component.get("v.fields")){
            var arrField = [];
            arrField.push("c:EnziField");
            arrField.push({"sObjectName":component.get("v.sObjectName"),"fieldName":component.get("v.fields")[field],"value":component.getReference("v.record."+component.get("v.fields")[field]),"errors":component.getReference("v.errors"),"disabled":component.get("v.mode")=="view"});
            arrFields.push(arrField);
        }
        $A.createComponents(
            arrFields,
            function(components,status,statusMessagesList){
                component.set("v.body",components);
                component.find("utils").hideProcessing();
            }
        );
    },
    createComponents:function(component,fields,onsuccess){
        $A.createComponents(
            fields,
            function(components,status,statusMessagesList){
                onsuccess(components);
            }
        );
    },
    setLayout:function(component,layout,onsuccess){
        var layoutSections = (component.get("v.mode")=="view"?layout.detailLayoutSections:layout.editLayoutSections);
        var lstFields = [];
        for(var section in layoutSections){
            for(var row in layoutSections[section].layoutRows){
                for(var cmp in layoutSections[section].layoutRows[row].layoutItems){
                    if(layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents.length>0 && layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].type=="Field"){
                        lstFields.push(layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].value);
                    }
                }
            }
        }
        var helper = this;
        component.find("utils").getIcons(function(icons){
            var mapIcon = icons;
            component.find("utils").execute("c.getFieldsMetadata",{"sObjectName":component.get("v.sObjectName"),"fields":lstFields},function(response){
                var metadata = JSON.parse(response);
                for(var section in layoutSections){
                    for(var row in layoutSections[section].layoutRows){
                        for(var cmp in layoutSections[section].layoutRows[row].layoutItems){
                            if(layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents.length>0 && layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].type=="Field"){
                                var arrField = []
                                arrField.push("c:EnziField");
                                arrField.push({"metadata":metadata[layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].value],"sObjectName":component.get("v.sObjectName"),"fieldName":layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].value,"value":component.getReference("v.record."+layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].value),"errors":component.getReference("v.errors"),"disabled":(component.get("v.mode")=="view" || (component.get("v.mode")=="new" && layoutSections[section].layoutRows[row].layoutItems[cmp].editableForNew==false) || (component.get("v.mode")=="edit" && layoutSections[section].layoutRows[row].layoutItems[cmp].editableForUpdate==false)),"editable":(component.get("v.mode")=="view" && layoutSections[section].layoutRows[row].layoutItems[cmp].editableForUpdate),"save":component.getReference("c.saveInline"),"icons":mapIcon,"required":layoutSections[section].layoutRows[row].layoutItems[cmp].required,"label":layoutSections[section].layoutRows[row].layoutItems[cmp].label});
                                helper.createComponents(component,[arrField],function(components){
                                    layoutSections[section].layoutRows[row].layoutItems[cmp].enziComponent = components[0];
                                })
                            }
                        }
                    }
                }
                if(component.get("v.mode")=="view")
                    layout.detailLayoutSections = layoutSections;
                else
                    layout.editLayoutSections = layoutSections;
                onsuccess(layout);
            },function(error){
                component.find("utils").showError(error);
            })
        },function(error){
            component.find("utils").showError(error);
        })
        
    },
    getLayoutQuery:function(component,layout){
        var query = "Select Id,";
        var fields = [];
        var layoutSections = (component.get("v.mode")=="view"?layout.detailLayoutSections:layout.editLayoutSections);
        for(var section in layoutSections){
            for(var row in layoutSections[section].layoutRows){
                for(var cmp in layoutSections[section].layoutRows[row].layoutItems){
                    if(layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents.length>0 && layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].type=="Field"){
                        if(layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].components){
                            for(var c in layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].components){
                                fields.push(layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].components[c].value);
                            }
                        }
                        else
                            fields.push(layoutSections[section].layoutRows[row].layoutItems[cmp].layoutComponents[0].value);
                    }
                }
            }
        }
        query += fields.join(",");
        query += " FROM "+component.get("v.sObjectName");
        query += " WHERE Id='"+component.get("v.recordId")+"'";
        return query;
    },
    notifySave:function(component,record){
        var evt = $A.get("e.c:EnziFormSaveEvent");
        evt.setParams({"sObjectName":component.get("v.sObjectName"),"record":record,"mode":component.get("v.mode")});
        evt.fire();
    }
})