({
	doInit : function(component, event, helper) {       
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":"Select ContentDocumentId From ContentDocumentLink Where LinkedEntityId='"+component.get("v.recordId")+"'"},function(response){
            if(response && response.length>0){
                component.set("v.contentDocumentId",response[0].ContentDocumentId);
            }
            helper.getParentRecord(component, function(parentRecord){
                if(parentRecord!=undefined){
                    component.set("v.parentRecord", parentRecord);
                    component.set("v.allowUpload", (parentRecord.Type__c!=undefined && parentRecord.Type__c!="" && parentRecord.Type__c.toLowerCase()!="multiple versioned" && !parentRecord.Is_Finalized__c));
                    component.set("v.allowNewDocument", (parentRecord.Type__c!=undefined && parentRecord.Type__c!="" && parentRecord.Type__c.toLowerCase()=="multiple versioned" && !parentRecord.Is_Finalized__c));
                    if(parentRecord.Type__c!=undefined && parentRecord.Type__c!="" && parentRecord.Type__c.toLowerCase()=="versioned"){
                        component.set("v.allowMultipleFiles", false);
                        if(parentRecord.Extensions_Allowed__c!=undefined && parentRecord.Extensions_Allowed__c!=""){
                            var types = [];
                            parentRecord.Extensions_Allowed__c.split(",").forEach(function(type){
                                types.push(type.trim().toLowerCase());  
                            });
                            component.set("v.allowedFileTypes", "."+types.join(",."));                        
                        }                    
                    } else {
                        component.set("v.allowMultipleFiles", (parentRecord.Type__c!=undefined && parentRecord.Type__c!="" && parentRecord.Type__c.toLowerCase()=="multiple files"));                    
                        if(parentRecord.Extensions_Allowed__c!=undefined && parentRecord.Extensions_Allowed__c!=""){
                            var types = [];
                            parentRecord.Extensions_Allowed__c.split(",").forEach(function(type){
                                types.push(type.trim().toLowerCase());  
                            });
                            component.set("v.allowedFileTypes", "."+types.join(",."));                        
                        }
                    }
                    component.set("v.label", parentRecord.Name+(component.get("v.allowMultipleFiles")?"(s)":""));
                }
                if(parentRecord.Type__c.toLowerCase()=="multiple versioned"){
                    var documentFilesColumns = [
                        {"name":"Name","label":"Document","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Name}}","value":"/{{Id}}"}}},
                        {"name":"Type__c","label":"Type","type":"string"},                
                        {"name":"Latest_Version__c","label":"Latest Version","type":"number"},
                        {"name":"CreatedDate","label":"Created On","type":"date"}, 
                        {"name":"CreatedBy.Name","label":"Created By","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{CreatedBy.Name}}","value":"/{{CreatedById}}"}}}
                    ];
                    component.set("v.documentFilesColumns", documentFilesColumns);
                    if(parentRecord.Documents__r!=null && parentRecord.Documents__r!=undefined){
                        component.set("v.documentFiles", parentRecord.Documents__r);
                    }
                }else if(parentRecord.Type__c.toLowerCase()=="multiple files"){ 
                    var documentFilesColumns = [
                        {"name":"ContentDocument.Title","label":"Title","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{ContentDocument.Title}}","value":"/{{ContentDocumentId}}"}}},
                        {"name":"ContentDocument.FileType","label":"File Type","type":"string"},
                        {"name":"size","label":"Size","type":"string"},
                        {"name":"ContentDocument.CreatedBy.Name","label":"Created By","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{ContentDocument.CreatedBy.Name}}","value":"/{{ContentDocument.CreatedById}}"}}},
                        {"name":"ContentDocument.CreatedDate","label":"Created On","type":"date"},                        
                        {"name":"action","label":"Action","type":"component","component":[{"name":"lightning:buttonIcon", "attributes":{"iconName":"utility:download","alternativeText":"Download", "onclick": component.getReference("c.downloadDoc")}}]}
                    ];
                    component.set("v.documentFilesColumns", documentFilesColumns); 
                }else if(parentRecord.Type__c.toLowerCase()=="versioned"){
                    var documentFilesColumns = [
                        {"name":"Title","label":"Title","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Title}}","value":"/{{ContentDocumentId}}"}}},
                        {"name":"VersionNumber","label":"Version","type":"number"},                
                        {"name":"FileType","label":"File Type","type":"string"},
                        {"name":"ContentSize","label":"Size","type":"string"},
                        {"name":"CreatedBy.Name","label":"Created By","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{CreatedBy.Name}}","value":"/{{CreatedById}}"}}},
                        {"name":"CreatedDate","label":"Created On","type":"date"},                        
                        {"name":"action","label":"Action","type":"component","component":[{"name":"lightning:buttonIcon", "attributes":{"iconName":"utility:download","alternativeText":"Download", "onclick": component.getReference("c.downloadDoc")}}]}
                    ];
                    component.set("v.documentFilesColumns", documentFilesColumns); 
                } 
                helper.getDocumentFiles(component, helper, function(){
                    component.find("utils").hideProcessing();
                });
                component.find("utils").hideProcessing();
            });
        },function(error){
             component.find("utils").hideProcessing();
             component.find("utils").showError(error);
        })
        component.find("utils").hideProcessing();
	},
    onDragOver : function(component, event, helper) {
        event.preventDefault();
        component.find("FileUpload").onDragOver(component, event, helper);
    },
    onDragLeave : function(component, event, helper) {
        event.preventDefault();
        component.find("FileUpload").onDragLeave(component, event, helper);
    },
    onDrop : function(component, event, helper) {
        event.preventDefault();
        component.find("FileUpload").onDragLeave(component, event, helper);
    },
    createDontentDocumentLinks : function(component, event, helper) {
        component.find("utils").showProcessing();
        if(component.get("v.result")!=undefined && component.get("v.result").length > 0){
            var records = [];
            var parentRecord = component.get("v.parentRecord");
            helper.getParentRecord(component, function(parentRecord){
                var mapDocumentEntity = {};
                var latestVersion = (parentRecord.Latest_Version__c!=undefined)?(parentRecord.Latest_Version__c+1):1;
                if(parentRecord.Type__c.toLowerCase()=='multiple files'){
                    component.get("v.result").forEach(function(doc){                         
                        if(doc != undefined && doc.id != undefined){                           
                            mapDocumentEntity[doc.id] = component.get("v.recordId");   
                        }                        
                    })
                    helper.createStandardDocuments(component,mapDocumentEntity,function(){
                        helper.getDocumentFiles(component, helper, function(){
                            component.find("utils").hideProcessing();
                        });
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    })
                }else if(parentRecord.Type__c.toLowerCase()=='versioned'){
                    mapDocumentEntity[component.get("v.result")[0]["id"]] = component.get("v.recordId");
                    helper.createStandardDocuments(component,mapDocumentEntity,function(){
                        component.find("utils").execute("c.saveRecord",{"record":{"Id": component.get("v.recordId"),"Latest_Version__c": latestVersion}},function(result){
                            component.set("v.contentDocumentId",component.get("v.result")[0]["id"]);
                            helper.getDocumentFiles(component, helper, function(){
                                component.find("utils").hideProcessing();
                            });
                        },function(error){
                            component.find("utils").hideProcessing();
                            component.find("utils").showError(error);
                        });
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    })
                }
            });            
        }
        component.find("utils").hideProcessing();
    },
    finalizeDocument : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.find("utils").execute("c.saveRecord",{"record": {"Id":component.get("v.recordId"),"Is_Finalized__c":true}}, function(response){
            if(JSON.parse(response).success){
                component.set("v.allowUpload", false);
                helper.getParentRecord(component, function(parentRecord){
                    if(parentRecord!=undefined){
                        component.set("v.parentRecord", parentRecord);
                        component.find("utils").hideProcessing();
                    }
                }, function(error){
                    console.log(error);
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                });
                helper.getDocumentFiles(component, helper, function(){
                    component.find("utils").showSuccess("Document Finalized");
                });
            }                       
        }, function(error){
            console.log(error);
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    newDocument : function(component, event, helper) {
        component.set("v.newDocument",{});
        component.find("NewDocumentModal").showModal();
    },
    saveNewDocument : function(component, event, helper) {
        component.find("utils").showProcessing();
        var newDocument = component.get("v.newDocument");
        newDocument["sobjectType"] = "Document__c";
        newDocument["Parent__c"] = component.get("v.recordId");
        component.find("utils").execute("c.saveRecord",{"record": newDocument}, function(response){
            component.find("utils").showSuccess("Document Created");
            helper.getDocumentFiles(component, helper, function(){ 
            });
            component.find("utils").hideProcessing();
            helper.closeModal(component);
        }, function(error){
            console.log(error);
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },
    downloadDoc : function(component, event, helper) {
        var recordToDownload = JSON.parse(event.currentTarget.getAttribute('data-value'));
        if(recordToDownload!=undefined){
            if(component.get("v.parentRecord.Type__c").toLowerCase()=='versioned'){
                window.open("/sfc/servlet.shepherd/version/download/" + recordToDownload.Id);   
            }else{
                var query = "SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = '"+recordToDownload.ContentDocumentId+"'";
                component.find("utils").execute("c.getQueryData",{"query": query}, function(contentVersions){
                    if(contentVersions.length > 0 && contentVersions[0].Id){
                        window.open("/sfc/servlet.shepherd/version/download/" + contentVersions[0].Id);   
                    }            
                }, function(error){
                    
                });
            } 
        }
    },
    deleteDoc : function(component, event, helper) {
        var recordToDelete = JSON.parse(event.currentTarget.getAttribute('data-value'));
        component.find("utils").execute("c.deleteRecord",{"recordToDelete": recordToDelete.ContentDocumentId}, function(response){
            helper.getDocumentFiles(component, helper, function(){
                component.find("utils").showSuccess("Deleted");
            });            
        }, function(error){
            console.log(error);
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    }
})