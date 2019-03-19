({
    uploadFiles : function(component, helper, inputFiles, onSuccess){
        var fileResults = [];
        var filesMap = {};
        var files = [];
        Array.from(inputFiles).forEach(function(inputFile){            
            files.push({
                "name": inputFile.name,
                "size": helper.bytesToSize(inputFile.size),
                "type": inputFile.type,
                "file": inputFile,
                "progress": 0,
                "status":"pending",
                "message":"waiting"
            });
        });
        component.set("v.files", files);
        component.set("v.isCancelAll", false);
        component.set("v.filesXHR", []);
        component.find("FileUploadProgress").showModal();
        component.get("v.files").forEach(function(inputFile){
            if(inputFile.status==="pending"){
                helper.uploadFile(component, helper, inputFile.file, function(resultFile){
                    fileResults.push(resultFile);
                    var result = [];
                    if(Array.from(inputFiles).length==fileResults.length){
                        component.set("v.isCancelAll", true);                        
                        onSuccess(fileResults);
                    }                    
                });
            }            
        });       
    },
    uploadFile : function(component, helper, inputFile, onSuccess) { 
        var filesXHR = component.get("v.filesXHR");
        component.find("FileUploadProgress").showModal();
        var objFormData = new FormData();
        objFormData.append("fileData", inputFile);
        objFormData.append("formData", "form-data; name='fileUpload', filename='"+ inputFile.name + "'");
        
        var timeInterval = 2000;
        var currentTime = new Date(); 
        
        var xhr = new XMLHttpRequest();
        filesXHR.push(xhr);
        component.set("v.filesXHR", filesXHR);
        xhr.withCredentials = true;
        
        xhr.addEventListener("progress", function(event) {
            if(currentTime.getTime()+timeInterval <= new Date().getTime()) { 
                var percent = 0;
                var position = event.loaded || event.position;
                var total = event.total;
                if (event.lengthComputable) {
                    percent = Math.ceil(position / total * 100);                
                    var files = component.get("v.files");
                    files.forEach(function(f, index){
                        if(f.name===inputFile.name){
                            files[index].progress = percent;
                        }
                    });
                    //console.log(new Date());
                    component.set("v.files", files);
                    currentTime = new Date();
                }
            }
        }, true);
        
        if ( xhr.upload ) {
            xhr.upload.onprogress = function(event) { 
                //console.log(event);
                if(currentTime.getTime()+timeInterval <= new Date().getTime()) { 
                    var percent = 0;
                    var position = event.loaded || event.position;
                    var total = event.total;
                    
                    if (event.lengthComputable) {
                        percent = Math.ceil(position / total * 100);
                        var files = component.get("v.files");
                        files.forEach(function(file, index){
                            if(file.name===inputFile.name){
                                files[index].progress = percent;
                            }
                        });
                        console.log(new Date());
                        component.set("v.files", files);
                        currentTime = new Date();
                    }
                }                
            };
        }
        xhr.onreadystatechange = function(e) {
            if ( 4 == this.readyState ) {
                if(this.responseText!="" && JSON.parse(this.responseText)["id"]){
                    //console.log(JSON.parse(this.responseText));                    
                    var files = component.get("v.files");
                    files.forEach(function(file, index){
                        if(file.name===inputFile.name){                            
                            files[index].progress = 100;
                            files[index].progressType = "slds-progress-bar__value_success";
                            files[index].status = "uploaded";
                            files[index].message = "Uploaded";                            
                        }
                    });
                    component.set("v.files", files);
                    onSuccess(JSON.parse(this.responseText));
                } else {
                    onSuccess();
                }
            }
        };
        if(component.get("v.contentDocumentId")){
            xhr.open("POST", component.get("v.endPointUrl")+"/services/data/v41.0/connect/files/"+component.get("v.contentDocumentId"), true);
        }else{
            xhr.open("POST", component.get("v.endPointUrl")+"/services/data/v41.0/connect/files/users/"+component.get("v.userId"), true);
        }
        xhr.setRequestHeader("Authorization", "Bearer "+component.get("v.apiSessionId"));
        xhr.setRequestHeader("cache-control", "no-cache");
        xhr.setRequestHeader("Access-Control-Allow-Credentials", "true");
        xhr.setRequestHeader("Content-Security-Policy", "default-src 'self';");
        xhr.setRequestHeader("connect-src", "self");
        xhr.send(objFormData);        
    },
    cancelAllFilesUpload : function(component, event, helper, onSuccess) {
        component.get("v.filesXHR").forEach(function(xhr, xhrIndex){
            xhr.abort();            
        });
        var files = component.get("v.files");
        files.forEach(function(file, fileIndex){
            files[fileIndex].progress = 0;
            files[fileIndex].status = "cancelled";
        });
        component.set("v.files", files);
        component.set("v.isCancelAll", true);
        onSuccess();
    },
    bytesToSize : function(bytes){
        var sizes = ['bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
        if (bytes == 0) return 'n/a';
        var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
        if (i == 0) { return (bytes / Math.pow(1024, i)) + ' ' + sizes[i]; }
        return (bytes / Math.pow(1024, i)).toFixed(1) + ' ' + sizes[i];       
    },
    checkFileTypes : function(component, files){
        var allow = true;
        var types = {};
        var result = {};
     if(component.get("v.allowedFileTypes")!=null && component.get("v.allowedFileTypes")!=undefined && component.get("v.allowedFileTypes")!="*" )
           {
        var allowedFileTypes = component.get("v.allowedFileTypes").split(",");
        files.forEach(function(inputFile){
            var fileExt = inputFile.name.replace(/^.*\./, "");
                if(allowedFileTypes.indexOf("."+fileExt.toLowerCase()) === -1){
                allow = false;
                types[fileExt] = fileExt;
            }
        });
        result["allow"] = allow;
        result["types"] = Object.keys(types);  
        }else {
        files.forEach(function(inputFile){
        var fileExt = inputFile.name.replace(/^.*\./, "");
        types[fileExt] = fileExt;    
            });
            result["allow"] = allow;
            result["types"] = Object.keys(types); 
		} 
        return result;
    },
    closeModal : function(component){
        window.setTimeout(
            $A.getCallback(function() {
                if (component.isValid()) {                                
                    component.find("FileUploadProgress").close();
                }
            }), 2000
        );
    }
})