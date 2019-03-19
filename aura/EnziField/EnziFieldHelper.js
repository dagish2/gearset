({
    addElement:function(component,metadata){
        var attributes = [];
        attributes.push({"name":"name","value":component.get("v.name")?component.get("v.name"):metadata.name});
        attributes.push({"name":"label","value":component.get("v.label")?component.get("v.label"):metadata.label});
        if(component.get("v.dynamicBinding")){
            component.set("v.value",component.get("v.record."+(component.get("v.fieldName"))));
        }
        attributes.push({"name":"value","value":component.getReference("v.value")});
        attributes.push({"name":"required","value":(!metadata.nillable)?true:component.get("v.required")});
        attributes.push({"name":"disabled","value":component.getReference("v.disabled")});
        switch(metadata.type){
            case "string":
                attributes.push({"name":"onInput","value":component.getReference("v.onInput")});
                attributes.push({"name":"length","value":metadata.length});
                this.addComponent(component,"c:EnziInputText",attributes);
                break;
            case "email":
                attributes.push({"name":"change","value":component.getReference("v.change")});
                attributes.push({"name":"onInput","value":component.getReference("v.onInput")});
                this.addComponent(component,"c:EnziInputEmail",attributes);
                break;
            case "url":
                this.addComponent(component,"c:EnziInputUrl",attributes);
                break;
            case "address":
            case "textarea":
                attributes.push({"name":"length","value":metadata.length});
                this.addComponent(component,"c:EnziInputTextarea",attributes);
                break;
            case "richtextarea":
                attributes.push({"name":"sObjectName","value":component.getReference("v.sObjectName")});
                this.addComponent(component,"c:EnziInputRichtext",attributes);
                break;
            case "date":
            case "datetime":
                attributes.push({"name":"upperBound","value":component.getReference("v.upperBound")});
                attributes.push({"name":"lowerBound","value":component.getReference("v.lowerBound")});
                attributes.push({"name":"change","value":component.getReference("v.change")});
                this.addComponent(component,"c:EnziInputDate",attributes);
                break;
            case "reference":
                if(metadata.referenceTo)
                	attributes.push({"name":"reference","value":metadata.referenceTo});
                attributes.push({"name":"searchFields","value":component.getReference("v.searchFields")});
                attributes.push({"name":"recordId","value":component.getReference("v.fastCallRecordId")});
                attributes.push({"name":"sObjectName","value":component.getReference("v.sObjectName")});
                if(component.get("v.filteredOptions"))
                	attributes.push({"name":"options","value":component.getReference("v.filteredOptions")});
               	attributes.push({"name":"criteria","value":component.getReference("v.criteria")});
                attributes.push({"name":"addNew","value":component.getReference("v.addNew")});
                attributes.push({"name":"icon","value":component.getReference("v.icon")});
                attributes.push({"name":"change","value":component.getReference("v.change")});
                attributes.push({"name":"onInput","value":component.getReference("v.onInput")});
                attributes.push({"name":"fields","value":component.get("v.getFields")});
                attributes.push({"name":"placeholder","value":component.get("v.placeholder")});
                attributes.push({"name":"createNew","value":component.get("v.createNew")});
                attributes.push({"name":"keyword","value":component.getReference("v.keyword")});
                this.addComponent(component,"c:EnziInputReference",attributes);
                break;
            case "picklist":
            case "combobox":
                attributes.push({"name":"options","value":component.getReference("v.filteredOptions")});
                attributes.push({"name":"change","value":component.getReference("v.change")});
                attributes.push({"name":"controllingValue","value":component.getReference("v.controllingValue")});
                attributes.push({"name":"isDependent","value":component.get("v.isDependent")});
                attributes.push({"name":"sort","value":component.get("v.sort")});
                attributes.push({"name":"unrestricted","value":component.get("v.unrestricted")});                
                this.addComponent(component,"c:EnziInputSelect",attributes);
                break;
            case "boolean":
                attributes.push({"name":"change","value":component.getReference("v.change")});
                attributes.push({"name":"varient","value":component.getReference("v.varient")});
                this.addComponent(component,"c:EnziInputCheckbox",attributes);
                break;
            case "phone":
                attributes.push({"name":"onInput","value":component.getReference("v.onInput")});
                attributes.push({"name":"fastCallObjectName","value":component.getReference("v.fastCallObjectName")});
                attributes.push({"name":"fastCallRecordName","value":component.getReference("v.fastCallRecordName")});
                attributes.push({"name":"fastCallRecordId","value":component.getReference("v.fastCallRecordId")});
                attributes.push({"name":"allowFastCall","value":component.getReference("v.allowFastCall")});
                attributes.push({"name":"maxPhoneLength","value":component.getReference("v.maxPhoneLength")});
                this.addComponent(component,"c:EnziInputPhone",attributes);
                break;
            case "multipicklist":
                attributes.push({"name":"options","value":component.getReference("v.filteredOptions")});
                attributes.push({"name":"showLabel","value":true});                
                this.addComponent(component,"c:EnziInputMultiSelect",attributes);
                break;
            case "currency":
            case "percent":
            case "double":
            case "number":
            case "integer":
                attributes.push({"name":"onInput","value":component.getReference("v.onInput")});
                attributes.push({"name":"min","value":component.getReference("v.min")});
                attributes.push({"name":"max","value":component.getReference("v.max")});
                attributes.push({"name":"allowDecimal","value":component.getReference("v.allowDecimal")});
                this.addComponent(component,"c:EnziInputNumber",attributes);
                break;
            case "googleLocation":
                if(metadata.referenceTo)
                	attributes.push({"name":"reference","value":metadata.referenceTo});
                attributes.push({"name":"sObjectName","value":component.getReference("v.sObjectName")});
                attributes.push({"name":"icon","value":component.getReference("v.icon")});
                this.addComponent(component,"c:EnziInputGeolocation",attributes);
                break;
            case "radio":
                attributes.push({"name":"change","value":component.getReference("v.change")});
                attributes.push({"name":"options","value":component.getReference("v.options")});
                attributes.push({"name":"label","value":component.getReference("v.label")});
                attributes.push({"name":"value","value":component.getReference("v.value")});
                this.addComponent(component,"c:EnziInputRadio",attributes);
                break;
        }
    },
    addComponent:function(component,inputComponent,attributes){
        var objAttributes = {};
        for(var a in attributes){
            objAttributes[attributes[a].name] = attributes[a].value;
        }
        if(inputComponent!="c:EnziInputReference"){
            $A.createComponent(
                inputComponent,
                objAttributes,
                function(cmp, status, errorMessage){
                    if (status === "SUCCESS") {
                        component.set("v.body", cmp);
                        component.set("v.isLoaded",true);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.");
                    }
                        else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                        }
                }
            );
        }else{
            if(component.get("v.icons")){
                var mapIcon = component.get("v.icons");
                var icon;
                if(mapIcon.hasOwnProperty(objAttributes["reference"][objAttributes["reference"].length-1])){
                    objAttributes["icon"] = mapIcon[objAttributes["reference"][objAttributes["reference"].length-1]];
                }else if(component.get("v.icon")){
                    objAttributes["icon"] = component.get("v.icon");
                }
                else {
                    objAttributes["icon"] = "utility:salesforce1";
                }
                $A.createComponent(
                        inputComponent,
                        objAttributes,
                        function(cmp, status, errorMessage){
                            if (status === "SUCCESS") {
                                component.set("v.body", cmp);
                                component.set("v.isLoaded",true);
                            }
                            else if (status === "INCOMPLETE") {
                                console.log("No response from server or client is offline.")
                            }
                                else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                }
                        }
                    );
            }else{
                component.find("utils").execute("c.getQueryData",{"query":"Select Data__c from Setting__c where Name='IconSettings'"},function(response){
                    var mapIcon = JSON.parse(response[0].Data__c);
                    if(objAttributes["reference"] && mapIcon.hasOwnProperty(objAttributes["reference"][objAttributes["reference"].length-1])){
                        objAttributes["icon"] = mapIcon[objAttributes["reference"][objAttributes["reference"].length-1]];
                    }else if(component.get("v.icon")){
                        objAttributes["icon"] = component.get("v.icon");
                    }else{
                        objAttributes["icon"] = "utility:salesforce1";
                    }
                    $A.createComponent(
                        inputComponent,
                        objAttributes,
                        function(cmp, status, errorMessage){
                            if (status === "SUCCESS") {
                                component.set("v.body", cmp);
                                component.set("v.isLoaded",true);
                            }
                            else if (status === "INCOMPLETE") {
                                console.log("No response from server or client is offline.")
                            }
                                else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                }
                        }
                    );
                },function(error){
                    component.find("utils").showError(error);
                })
            }
        }
    },
    getFilteredOptions:function(picklistValues,component){
        var options = [];
        for(var option in picklistValues){
            var opt = {};
            if(typeof picklistValues[option]=="object"){
                if(component.get("v.labelField")){
                    opt.label = picklistValues[option][component.get("v.labelField")];
                }else{
                    opt.label = picklistValues[option];
                } 
                
                if(component.get("v.valueField")){
                    opt.value = picklistValues[option][component.get("v.valueField")];
                }else{
                    opt.value = picklistValues[option];
                }
            }else{
                opt.label = picklistValues[option];
                opt.value = picklistValues[option];
            }
            options.push(opt);
        }
        return options;
    },
    getDependentPicklistValues : function(component,metadata,onsuccess,onerror) {
        var helper = this;
        component.find("utils").execute("c.getFieldMetadata",{"sObjectName":component.get("v.sObjectName"),"fieldName":metadata.controllerName},function(response){
            var cmetadata = JSON.parse(response);
            var picklistValues = {};
            for(var i=0;i<cmetadata.picklistValues.length;i++){
                picklistValues[cmetadata.picklistValues[i].value] = [];
                for(var j=0;j<metadata.picklistValues.length;j++){
                    var encode = atob(metadata.picklistValues[j].validFor);
                    if(helper.testBit(encode,i)){
                        picklistValues[cmetadata.picklistValues[i].value].push({"label":metadata.picklistValues[j].label,"value":metadata.picklistValues[j].value});
                    }
                }
            }
            onsuccess(picklistValues);
        },function(error){
            onerror(error);
        })
    },
    testBit : function(validFor, pos) {
        var byteToCheck = Math.floor(pos / 8);
        var bit = 7 - (pos % 8);
        return ((Math.pow(2, bit) & validFor.charCodeAt(byteToCheck)) >> bit) == 1;
    },
    initField:function(component,helper){
        var metadata = component.get("v.metadata");
        if(component.get("v.helpText")==undefined && metadata.inlineHelpText){
            component.set("v.helpText",metadata.inlineHelpText);
        }
        if(!metadata.createable)
            component.set('v.editable',false);
        ////////////////////////////////// Patch for Journey Details///////////////////////////////////////
        if(component.get("v.sObjectName")=="Journey__c" && component.get("v.fieldName")=="Phone__c")
            metadata.type = "phone";
        if(component.get("v.sObjectName")=="Journey__c" && component.get("v.fieldName")=="Email__c")
            metadata.type = "email";
        ////////////////////////////////// Patch for Journey Details///////////////////////////////////////
        //-----------Patch for Task Subject-----------------------------------//
        // Commented By Milanjeet
        // if(component.get("v.sObjectName")=="Task" && component.get("v.fieldName")=="Subject"){
        //    metadata.type="string";
        // }
        //-----------Patch for Task Subject-----------------------------------//
        if(component.get("v.label")==undefined)
            component.set("v.label",metadata.label);
        else
            metadata.label = component.get("v.label");
        if(component.get("v.required")==undefined)
            component.set("v.required",!metadata.nillable);
        if(component.get("v.name")==undefined)
            component.set("v.name",metadata.name);
        component.set("v.type",metadata.type);
        component.set("v.length",metadata.length);
        if(metadata.type=="reference" && metadata.referenceTo=="Geography__c"){
            metadata.type="googleLocation";
        }
        if(metadata.type=="picklist" || metadata.type=="combobox" || metadata.type=="multipicklist"){
            component.set("v.labelField","label");
            component.set("v.valueField","value");
            if(component.get("v.isDependent")){
                helper.getDependentPicklistValues(component,metadata,function(picklistValues){
                    metadata.picklistValues = picklistValues;
                    component.set("v.filteredOptions",picklistValues);
                    helper.addElement(component,metadata);
                },function(error){
                    component.find("utils").showError(error);
                });
            }else{
                if(component.get("v.options") != undefined){
                    component.set("v.filteredOptions",component.get("v.options"))
                }else{
                component.set("v.filteredOptions",helper.getFilteredOptions(metadata.picklistValues,component));
                }
                helper.addElement(component,metadata);
            }
            
        }        
        else
            helper.addElement(component,metadata);
    }
})