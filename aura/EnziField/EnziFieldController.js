({
    doInit : function(component, event, helper) {
        if(component.get("v.metadata")){
            helper.initField(component,helper);
        }else if(component.get("v.sObjectName") && component.get("v.fieldName")){
            component.find("utils").execute("c.getFieldMetadata",{"sObjectName":component.get("v.sObjectName"),"fieldName":component.get("v.fieldName")},function(response){
                component.set("v.metadata",JSON.parse(response));
                helper.initField(component,helper);
            },function(error){
                component.find("utils").showError(error);
            })
        }else if(component.get("v.type")){
            var metadata = {};
            metadata.name = component.get("v.name");
            metadata.label = component.getReference("v.label");
            metadata.length = component.get("v.length");
            metadata.type = component.get("v.type");
           
            if(component.get("v.type")=="picklist" || component.get("v.type")=="multipicklist" || component.get("v.type")=="reference"){
                if(component.get("v.isDependent"))
                    component.set("v.filteredOptions",component.get("v.options"));
                else
                    component.set("v.filteredOptions",helper.getFilteredOptions(component.get("v.options"),component));
            }
            if(component.get("v.reference") && component.get("v.type")=="reference"){
                metadata.referenceTo = [component.get("v.reference")];
            }
            helper.addElement(component,metadata);
        }
    },
    valueChange:function(component, event, helper){
        if(component.get("v.dynamicBinding")){
            var record = component.get("v.record");
            record[component.get("v.fieldName")] = component.get("v.value");
            component.set("v.record",record);
        }
        ////////////////////////////////// Patch for Journey Details///////////////////////////////////////
        if(component.get("v.sObjectName")=="Journey__c" && component.get("v.fieldName")=="Phone__c") {
            if(component.get("v.value")!=undefined && component.get("v.value").includes('_blank">')){
                var url = component.get("v.value").split("?")[1];
                var params = {};
                for(var i=0;i<url.split("&amp;").length;i++){
                    params[url.split("&amp;")[i].split("=")[0]] = url.split("&amp;")[i].split("=")[1];
                }
                params["DISPLAY_NAME"] = params["DISPLAY_NAME"].split("&#39;")[2];
                params["DN"] = params["DN"].split("&#39;")[2];
                params["OBJECT_NAME"] = params["OBJECT_NAME"].split("&#39;")[2];
                component.set("v.fastCallRecordId",params['ID']);
                component.set("v.fastCallRecordName",params['OBJECT_NAME']);
                component.set("v.fastCallObjectName",params['DISPLAY_NAME']);
                component.set("v.allowFastCall",true);
                component.set("v.value",params['DN']);
            }else{
                component.set("v.allowFastCall",false);
            }
        }
        ////////////////////////////////// Patch for Journey Details///////////////////////////////////////
        if(component.get("v.value") && component.get("v.value")!=undefined){
            component.set("v.dirty",true);
            if(component.get("v.type")=="phone"){
                if(!component.get("v.fastCallRecordId")){
                    var evt = $A.get("e.c:EnziFieldInlineSaveEvent");
                    evt.setParams({"sObjectName":component.get('v.sObjectName'),"onSuccess":function(recordId){
                        if(recordId){
                            component.set("v.fastCallRecordId",recordId);
                            component.find("utils").execute("c.getQueryData",{"query":"Select Id,Name from "+component.get("v.sObjectName")+" Where Id='"+recordId+"'"},function(response){
                                component.set("v.fastCallRecordName",response[0].Name);
                                component.set("v.allowFastCall",true);
                                component.set("v.fastCallObjectName",component.get("v.sObjectName"));
                            },function(error){
                                console.log(error);
                            })
                        }else{
                            component.set("v.allowFastCall",false);
                        }
                    }});
                    evt.fire();
                }
            }
            if(component.get("v.type")=="reference"){
                if(component.get("v.fieldName")=="CreatedById" || component.get("v.fieldName")=="LastModifiedById"){
                    if(!component.get("v.fastCallRecordId")){
                        var evt = $A.get("e.c:EnziFieldInlineSaveEvent");
                        evt.setParams({"sObjectName":component.get('v.sObjectName'),"onSuccess":function(recordId){
                            component.set("v.fastCallRecordId",recordId);
                        }});
                        evt.fire();
                    }
                }
                
            }
        }
        ////////////////////////////////// Patch for email field///////////////////////////////////////
        if((component.get("v.type")=="email" || component.get("v.type")=="url") && (component.get("v.value")==null || component.get("v.value")=='') ){
            component.set("v.dirty",false);
            component.set("v.value", null);
        }
        if(component.get("v.value")==null){
            component.set("v.dirty",false);
        }
    },
    optionsChange:function(component, event, helper){
        component.set("v.filteredOptions",helper.getFilteredOptions(component.get("v.options"),component));
    },
    makeEditable:function(component, event, helper){
        component.set("v.disabled",false);
    },
    save:function(component, event, helper){
        component.set("v.saving",true);
        var evt = $A.get("e.c:EnziFieldInlineSaveEvent");
        evt.setParams({"sObjectName":component.get('v.sObjectName'),"onSuccess":function(recordId){
            var record = {};
            record['Id'] = recordId;
            record[component.get("v.name")] = component.get("v.value");
            component.find("utils").execute("c.saveRecord",{"record":record},function(response){
                component.set("v.saving",false);
                component.set("v.disabled",true);
            },function(error){
                component.set("v.saving",false);
                component.find("utils").showError(error);
            })
        }});
        evt.fire();
    },
    cancel:function(component, event, helper){
        component.set("v.saving",true);
        var evt = $A.get("e.c:EnziFieldInlineSaveEvent");
        evt.setParams({"sObjectName":component.get('v.sObjectName'),"onSuccess":function(recordId){
            component.find("utils").execute("c.getQueryData",{"query":"SELECT "+component.get("v.name")+" FROM "+component.get("v.sObjectName")+" WHERE Id='"+recordId+"'"},function(response){
                component.set("v.value",response[0][component.get("v.name")]);
                component.set("v.saving",false);
                component.set("v.disabled",true);
            },function(error){
            	component.set("v.saving",false);
                component.find("utils").showError(error);
            })
        }});
        evt.fire();
    },
    handleDestroy:function(component, event, helper){
        var errors = component.get("v.errors");
        var name;
        if(event.getParam("value")['$valueProviders$']){
            name = event.getParam("value")['$valueProviders$']['v']["$values$"]["name"];
        }else if(event.getParam("value") && event.getParam("value")["t"] && event.getParam("value")["t"]["A"] && event.getParam("value")["t"]["A"]["name"]){
            name = event.getParam("value")["t"]["A"]["name"];
        }else if(event.getParam("value") && event.getParam("value")["Z"] && event.getParam("value")["Z"]["v"] && event.getParam("value")["Z"]["v"]["w"] && event.getParam("value")["Z"]["v"]["w"]["name"]){
            name = event.getParam("value")["Z"]["v"]["w"]["name"]
        }
        if(name){
            if(typeof(name)=="object"){
                name = name["result"];
            }
            if(errors && name && errors.hasOwnProperty("mapValidations") && errors.hasOwnProperty("mapComponents") && errors["mapValidations"].hasOwnProperty(name) && errors["mapComponents"].hasOwnProperty(name)){
                delete errors["mapValidations"][name];
                delete errors["mapComponents"][name];
                component.set("v.errors",errors);
            }
        }        
    },
    defaultChange:function(){
    }
})