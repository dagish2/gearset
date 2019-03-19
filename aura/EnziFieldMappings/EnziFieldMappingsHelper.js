({
    initialiseComponent:function(component,event,helper){
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":"Select Id,Name,Data__c,Source_Object__c,Destination_Object__c From Setting__c Where Id='"+component.get("v.settingId")+"'"},function(response){
            var setting = response[0];
            if(setting.Source_Object__c !=undefined &&setting.Destination_Object__c !=undefined) {
                component.set("v.DestinationObjectName",setting.Destination_Object__c);
                component.set("v.sourcebjectName",setting.Source_Object__c);
                component.set("v.settingData",JSON.parse(setting.Data__c));
                component.find("utils").execute("c.getAllFields",{"sObjectName": setting.Source_Object__c},function(result){
                    var fields = JSON.parse(result).fields;
                    var sourceFields = [];
                    for(var f in fields){
                        sourceFields.push({"name":fields[f].name,"label":(fields[f].label+" ["+fields[f].type+"]")});
                    }
                    component.set("v.sourceFields",sourceFields);
                    component.find("utils").execute("c.getAllFields",{"sObjectName": setting.Destination_Object__c},function(result){
                        var fields = JSON.parse(result).fields;
                        var destinationFields = [];
                        for(var f in fields){
                            destinationFields.push({"name":fields[f].name,"label":(fields[f].label+" ["+fields[f].type+"]")});
                        }
                        component.set("v.destinationFields",destinationFields);
                        helper.generateDescribedFields(component);
                        helper.generateMappedData(component);
                        helper.generateUnmappedData(component);
                        component.find("utils").hideProcessing();
                    },function(error){
                        component.find("utils").showError(error);
                        component.find("utils").hideProcessing();
                    })
                },function(error){
                    component.find("utils").showError(error);
                    component.find("utils").hideProcessing();
                }) 
            }
            else {
                component.find("utils").hideProcessing();                
            }
            
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    } ,
    generateMappedData : function(component) {
        var mappedData = [];
        var settingData = component.get("v.settingData");
        for(var mapping in settingData.mappings){
            var data = settingData.mappings[mapping];
            data['field'] = mapping;
            mappedData.push(data);
        }
        component.set("v.mappedData",mappedData);
    },
    generateUnmappedData : function(component) {
        var unmappedData = [];
        var settingData = component.get("v.settingData");
        var destinationFields = component.get("v.destinationFields");
        for(var field in destinationFields){
            if(!settingData.mappings.hasOwnProperty(destinationFields[field].name)){
                var data = {"field":destinationFields[field].name};
            	unmappedData.push(data);
            }
        }
        component.set("v.unmappedData",unmappedData);
    },
    generateDescribedFields:function(component){
        var describedFields = [];
        describedFields.push({"name":"field","label":"Destination object ["+component.get("v.DestinationObjectName")+"]"});
        describedFields.push({"name":"isvalue","label":"Is Value","type":"component","component":{"name":"c:EnziField","attributes":{"name":"isValue","hideLabel":true,"type":"boolean","value":"{!isvalue}"}}});
        describedFields.push({"name":"fieldname","label":"source object ["+component.get("v.sourcebjectName")+"]","type":"component","component":{"name":"c:EnziField","attributes":{"name":"isValue","label":"Source Field","hideLabel":true,"type":"picklist","value":"{!fieldname}","options":component.get("v.sourceFields"),"labelField":"label","valueField":"name","value":"{!fieldname}"}}});
        describedFields.push({"name":"overwrite","label":"Overwrite","type":"component","component":{"name":"c:EnziField","attributes":{"name":"isValue","hideLabel":true,"type":"boolean","value":"{!overwrite}"}}});
        component.set("v.describedFields",describedFields);
    }
})