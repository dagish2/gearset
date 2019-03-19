({
    csvValidator : function(component,file,helper){
        if(file != undefined){
            var extension = file.name;
            extension = extension.split('.')[1];
            if(extension != "csv"){     
                component.find("utils").showError(component.get("v.mapErrors").Errors['InvalidCSV']);       
            }else if(file.size > 26845634 ){
                component.find("utils").showError(component.get("v.mapErrors").Errors['FileSize']);
            }else{
                var reader = new FileReader();
                reader.onload = function(){
                    helper.proceedCSV(component,reader.result,helper);
                }
                reader.readAsText(file);
            }
        }  
    },
    proceedCSV : function(component,csv,helper){
        var helper = this;
        component.find("utils").showProcessing();
        var records = [];var campaignId =  component.get("v.campaignId");
        var rows = Papa.parse(csv.trim()).data;
        if(rows && rows.length >= 2 && rows[1].length != 0){
            if(true){
                var columns = JSON.parse(JSON.stringify(rows[0]).trim().toLowerCase());
                component.set("v.failColumns",columns);
                var generateJourney = component.get("v.generateJourney");
                var requiredFields = component.get("v.requiredFields");
                var mapErrors = {};
                if(helper.getRequiredFields(component,requiredFields,columns)){                        
                    var mapFieldsMetadata = {};
                    var invalidColumn = '';
                    mapFieldsMetadata = component.get("v.mapFieldsMetadata");
                    for(var i=1;i<rows.length;i++){
                        var data = rows[i]; 
                        if(columns && data && columns.length==data.length){         
                            var record = {};
                            for(var j=0;j<columns.length;j++){
                                if(mapFieldsMetadata.hasOwnProperty(columns[j])){
                                    switch(mapFieldsMetadata[columns[j]].name){
                                        case "Generate_Journey__c":
                                            if((generateJourney && generateJourney == true) || (data[j] && helper.getValue(data[j],mapFieldsMetadata[columns[j]].type))){
                                                record['Generate_Journey__c'] = true;
                                                record['By_Pass_Journey_Creation_Criteria__c'] = true;
                                            }else{
                                                record['Generate_Journey__c'] = false;
                                            }
                                            break;
                                        case "Campaign":
                                        case "Campaign_Id__c":
                                            if((campaignId && campaignId.startsWith("701") && (campaignId.length==15 || campaignId.length==18)) || (data[j] && data[j].startsWith("701") && (data[j].length==15 || data[j].length==18))){
                                                record['Campaign_Id__c'] = campaignId?campaignId:data[j];
                                            }
                                            break;
                                        default:
                                            var val = helper.getValue(data[j],mapFieldsMetadata[columns[j]].type);
                                            if(val){
                                                record[mapFieldsMetadata[columns[j]].name] = val;
                                            }else{
                                                if(requiredFields.includes(columns[j])){
                                                    var errRow = mapErrors['Required field missing '+columns[j]+' on row :'];
                                                    if(errRow==undefined){
                                                        errRow = [];
                                                    }
                                                    errRow.push(i);
                                                    mapErrors['Required field missing '+columns[j]+' on row :'] = errRow;
                                                }
                                            }
                                            break;
                                    }
                                }
                            }
                            record.sobjectType = "Lead";
                            record['Lead_Assignment_Stage__c'] = "1000";
                            if(generateJourney){
                                record['Generate_Journey__c'] = true;
                                record['By_Pass_Journey_Creation_Criteria__c'] = true;
                            }
                            if(campaignId){
                                record['Campaign_Id__c'] = campaignId;
                            }
                            if(record.hasOwnProperty('Generate_Journey__c') != true && generateJourney != true){
                                record['Generate_Journey__c'] = false;
                                record['By_Pass_Journey_Creation_Criteria__c'] = false;
                            }
                            records.push(record);
                        }else{
                            console.log(rows[i]);
                        }
                    }
                    console.log(records);
                    if(Object.keys(mapErrors).length>0){
                        var strErr = '';
                        for(var err in mapErrors){
                            strErr += (err + mapErrors[err].join(",")+"\n");
                        }
                        component.find("utils").showError(strErr);
                        component.find("utils").hideProcessing();
                    }else{
                        var obj = {};
                        obj.records = records;
                        obj.csv = csv;
                        obj.generateJourney = generateJourney;
                        obj.campaignId = campaignId;
                        obj.successColumns = component.get("v.successColumns");
                        obj.failColumns = component.get("v.failColumns");
                        obj.apiNamesOfCSVColumns =  component.get("v.apiNamesOfCSVColumns");
                        component.set("v.recordToSend",obj);
                        component.set("v.isInsertJourneys",true);
                    }
                }
            }else{
                component.find("utils").hideProcessing();
                component.find("utils").showError('Invalid CSV, CSV must be comma or tab seperated.');
            }
        }else{
            component.find("utils").showError(component.get("v.mapErrors").Errors['EmptyFile']);
            component.find("utils").hideProcessing();
        }
    },
    getRequiredFields:function(component,requiredFields,columns){
        var missingFields = [];
        for(var c in columns){
            columns[c] = columns[c].trim();
        }
        requiredFields.forEach(function(field){
            if(!columns.includes(field.trim())){
                missingFields.push(field);
            }
        })
        if(missingFields.length>0){
            component.find("utils").hideProcessing();
            component.find("utils").showError('Required Fields missing :'+missingFields.join());
            return false;
        }else{
            return true;
        }
    },
    getValue:function(val,type){
        val = val.trim();
        switch(type){
            case "date":
            case "datetime":
                var dt = new Date(val);
                return (dt.getFullYear()+'-'+(this.getDoubleValue(dt.getMonth()+1))+'-'+this.getDoubleValue(dt.getDate()));
                break;
            case "integer":
            case "number":
            case "decimal":
            case "double":
                return parseInt(val);
                break;
            case "boolean":
                val = val.trim();
                if(val=="TRUE" || val=="true" || val=="yes" || val=="1"){
                    return true;
                }else if(val=="FALSE" || val=="false" || val=="no" || val=="0"){
                    return false;
                }else{
                    return undefined;
                }
                break;
            default:
                return val;
        }
    },
    getDoubleValue:function(val){
        if(val<10){
            return "0"+val;
        }
        return val;
    }
})