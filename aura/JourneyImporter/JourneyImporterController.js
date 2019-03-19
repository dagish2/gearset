({
    doInit : function(component, event, helper){ 
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":"Select Name,Data__c From Setting__c Where Name='KickboxLeadImporterUtility' OR Name='FieldMappings:KickboxCSVToLead'"},function(response){
            if(response){    
                response.forEach(function(setting){
                    if(setting.Name=="KickboxLeadImporterUtility"){
                        var mapErrors = JSON.parse(setting.Data__c);
                        component.set("v.mapErrors",mapErrors);
                        component.set("v.instructions",mapErrors.Instructions);
                        component.set("v.successColumns",mapErrors.CsvAPINames);
                    }else if(setting.Name=="FieldMappings:KickboxCSVToLead"){
                        var mapping = JSON.parse(setting.Data__c.toLowerCase());
                        component.set("v.requiredFields",Object.keys(mapping.mappings));
                    }
                })
                component.find("utils").hideProcessing();
                component.find("instructionModel").showModal();
            }
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
        
        var fieldsMetadata = {};
        component.find("utils").execute("c.getAllFields",{"sObjectName":"Lead"},function(response){
            var response = JSON.parse(response);
            response.fields.forEach(function(field){
                fieldsMetadata[field.label.toLowerCase()] = field;
            })
            component.set("v.mapFieldsMetadata",fieldsMetadata);
        },function(error){
            component.find("utils").showError(error);
        })
    },
    setCampaignName : function(component, event, helper){
        var campaignId = component.get("v.campaignId");
        if(campaignId && campaignId!=""){
            component.find("utils").execute("c.getQueryData",{"query":"Select Id,Name From Campaign Where ID='"+campaignId+"'"},function(response){
                if(response && response.length==1){
                    var campaignName1 = response[0].Name;
                    component.set("v.campaignName",campaignName1);  
                }          
            },function(error){
                component.find("utils").showError(error);
            })
        }
    },    
    handleFilesChange : function(component, event, helper){
        var file = document.getElementById('file-upload-input-01').files[0];
        if(file != undefined){
            var fileName = file.name;
            component.set("v.fileName",fileName);
            //document.getElementById("name").innerHTML =  component.get("v.fileName");
        }
    },
    downloadTemplate : function(component, event, helper){
        component.find("utils").execute("c.getQueryData",{"query":"Select Id From Document Where Name='Lead Importer CSV Template'"},function(response){
            if(response && response.length==1){
                window.open("/servlet/servlet.FileDownload?file="+response[0].Id);
            }else{
                component.find("utils").showError('No template found in the document with the Name "Lead Importer CSV Template"');
            }
            
        },function(error){
            component.find("utils").showError(error);
        })
    },
    validateCSV : function(component, event, helper) {           
        component.find("utils").showConfirm("You are trying to upload the list of leads"+ (component.get("v.selectCampaign") ? " with the Campaign \""+component.get("v.campaignName")+"\"": " without any of the Campaign") +". Are you sure to upload a file?",function(){
            var file = document.getElementById('file-upload-input-01').files[0];
            if (file) {
                helper.csvValidator(component,file,helper);
            }else if(component.get("v.mapErrors")){
                component.find("utils").showError(component.get("v.mapErrors").Errors['InvalidCSV']);
            }
        },function(){            
        });
    },
    close:function(component,event,helper){
        component.find("utils").closeTab();
        component.find("utils").redirectToUrl('back');
    },
    
    insertJourneysForKickbox : function(component, event,helper){
        if( component.get("v.isInsertJourneys") ){
            var obj = component.get("v.recordToSend");
            component.find("utils").execute("c.insertJourneysForKickBoxImporter",{"lstLeads":obj.records,"strCSV":obj.csv,"generateJourney":obj.generateJourney,"campaignId":obj.campaignId,"successColumns":obj.successColumns,"failColumns":obj.failColumns,"apiNamesOfCSVColumns":obj.apiNamesOfCSVColumns},function(response){          
                if(response){
                    component.find("utils").showSuccess('Import process is going to take some time, you will be notified via email once the process is complete.');
                    component.set("v.fileName","Upload CSV file for Lead/Journey import");
                    document.getElementById('file-upload-input-01').value =  "";
                    component.set("v.campaignId","");
                    component.set("v.selectCampaign",false);
                    component.set("v.generateJourney",false);
                } 
                component.find("utils").hideProcessing();
            },function(error){
                component.find("utils").showError(error);
                component.find("utils").hideProcessing();
            },component);
            component.set("v.isInsertJourneys",false);
        }
    },
})