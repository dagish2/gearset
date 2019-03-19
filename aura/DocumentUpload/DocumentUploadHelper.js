({
    getParentRecord : function(component, onSuccess){        
        var query = "SELECT Id, Name, Extensions_Allowed__c, Is_Finalized__c, Latest_Version__c, CreatedDate, CreatedBy.Name, CreatedById, Parent__c,Type__c,(Select Id, Name, Extensions_Allowed__c, Is_Finalized__c, Latest_Version__c, Parent__c, Type__c, CreatedDate, CreatedBy.Name, CreatedById From Documents__r)  FROM Document__c WHERE Id = '"+component.get("v.recordId")+"'";
        component.find("utils").execute("c.getQueryData",{"query":query},function(records){            
            onSuccess(records[0]);
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    getDocumentFiles : function(component, helper, onSuccess){  
        helper.getParentRecord(component, function(parentRecord){
            if(parentRecord.Type__c.toLowerCase()!="multiple versioned"){
                var query;
                /*var mapVersion= {};
                if(parentRecord.Document_Versions__r){
                    for(var v in parentRecord.Document_Versions__r){
                        mapVersion[parentRecord.Document_Versions__r[v].Id] = parentRecord.Document_Versions__r[v];
                    }
                }*/
                if(parentRecord.Type__c.toLowerCase()=='multiple files'){
                    query = "SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title, ContentDocument.FileType, ContentDocument.ContentSize, ContentDocument.CreatedDate, ContentDocument.CreatedBy.Name FROM ContentDocumentLink WHERE LinkedEntityId ='"+component.get("v.recordId")+"'";
                }else if(parentRecord.Type__c.toLowerCase()=='versioned' && component.get("v.contentDocumentId")){
                    query = "SELECT Id, ContentDocumentId, VersionNumber, Title, FileType, ContentSize, CreatedDate, CreatedBy.Name FROM ContentVersion WHERE ContentDocumentId='"+component.get("v.contentDocumentId")+"'";
                }
                if(query){
                    component.find("utils").execute("c.getQueryData",{"query":query},function(documentFiles){
                        documentFiles.forEach(function(file, index){
                            if(parentRecord.Type__c.toLowerCase()=='versioned'){
                                if(file["ContentSize"] != null )
                                {
                                    var fileSize = file["ContentSize"]/1024;
                                    fileSize = Number.parseFloat(fileSize).toFixed(2); 
                                    file["ContentSize"] = (fileSize).toString()+" KB";
                                }
                            }else{
                                if(file["ContentDocument"]["ContentSize"] != null )
                                {
                                    var fileSize = file["ContentDocument"]["ContentSize"]/1024;
                                    fileSize = Number.parseFloat(fileSize).toFixed(2); 
                                    file["size"] = (fileSize).toString()+" KB";
                                }
                            }
                           
                        });
                        component.set("v.documentFiles", documentFiles);
                        onSuccess();
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    });
                }else{
                    component.set("v.documentFiles", []);
                    component.find("utils").hideProcessing();
                }
            } else{
                if(parentRecord!=undefined){
                    if(parentRecord.Documents__r!=null && parentRecord.Documents__r!=undefined){
                        parentRecord.Documents__r.forEach(function(doc){
                            if(doc != undefined){
                                if(doc.Type__c.toLowerCase()!='versioned'){
                                    doc.Latest_Version__c = 'NA';
                                }  
                            }                           
                        })
                        component.set("v.documentFiles", parentRecord.Documents__r);
                    }
                }
            }
        });
    },
    closeModal : function(component){
        component.set("v.newDocument",{});
        component.find("NewDocumentModal").close();
    },
    createStandardDocuments:function(component,mapDocumentEntity,onsuccess,onerror){
        if(component.get("v.contentDocumentId")){
            onsuccess();
        }else{
            var documents = [];
            for(var d in mapDocumentEntity){
                documents.push({
                    "ContentDocumentId": d,
                    "LinkedEntityId": mapDocumentEntity[d],
                    "ShareType": "I",
                    "sobjectType": "ContentDocumentLink"
                });
            }
            component.find("utils").execute("c.saveRecords",{"records":documents},function(response){
                onsuccess();
            },function(error){
                onerror(error);
            })
        }
    }
})