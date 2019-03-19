({
	doInit : function(component, event, helper) {
        component.find("utils").execute("c.getRESTCalloutData",{},function(response){
            component.set("v.apiSessionId", JSON.parse(response).apiSessionId);
            component.set("v.userId", JSON.parse(response).userId);
            component.set("v.endPointUrl", JSON.parse(response).endPointUrl);            
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
         component.find("utils").hideProcessing();
    },
    onDragOver : function(component, event, helper) {
        event.preventDefault();
        var dropzone = component.find("dropzone");
        $A.util.addClass(dropzone, "slds-has-drag-over");
        
    },
    onDragLeave : function(component, event, helper) {
        event.preventDefault();
        var dropzone = component.find("dropzone");
        $A.util.removeClass(dropzone, "slds-has-drag-over");
    },
    onDrop : function(component, event, helper) {
        var dropzone = component.find("dropzone");
        $A.util.removeClass(dropzone, "slds-has-drag-over");
        event.stopPropagation();
        event.preventDefault();
		event.dataTransfer.dropEffect = "copy";
		var files = event.dataTransfer.files;
        var result = helper.checkFileTypes(component, Array.from(files));
        if(result["allow"]){
            var flag = true;
            if(!component.get("v.allowMultipleFiles") && Array.from(files).length > 1){
                component.find("enzi-file-input").getElement().value = "";
                component.find("utils").showError("Can't upload multiple files.");
                flag = false;
            }
            if(flag){
                helper.uploadFiles(component, helper, files, function(result){
                    //console.log(result);
                    component.set("v.resultFiles", result);
                    component.find("enzi-file-input").getElement().value = "";
                    component.find("utils").showSuccess("Files uploaded successfully.");
                    component.find("utils").hideProcessing();
                    helper.closeModal(component);
                });
            }            
        } else {
            component.find("utils").showError("File type not allowed : "+result["types"].join(", "));
        }        
    },
    upload : function(component, event, helper) {
        var files = event.target.files;
        var result = helper.checkFileTypes(component, Array.from(files));
        if(result["allow"]){
            var flag = true;
            if(!component.get("v.allowMultipleFiles") && Array.from(files).length > 1){
                component.find("enzi-file-input").getElement().value = "";
                component.find("utils").showError("Can't upload multiple files.");                
                flag = false;
            }
            if(flag){
                helper.uploadFiles(component, helper, files, function(result){
                    //console.log(result);
                    component.set("v.resultFiles", result);
                    component.find("enzi-file-input").getElement().value = "";
                    component.find("utils").showSuccess("Files uploaded successfully.");
                    component.find("utils").hideProcessing();
                    helper.closeModal(component);
                });
            } 
        } else {
            component.find("utils").showError(result["types"].join(", ")+" File type not allowed.");
              component.find("utils").hideProcessing();
        }
    },
    cancelFileUpload : function(component, event, helper) {
        var filesXHR = component.get("v.filesXHR");
        var index = parseInt(event.currentTarget.id.split(":")[1]);
        component.get("v.filesXHR").forEach(function(xhr, xhrIndex){
            if(xhrIndex===index){
                xhr.abort();
            }
        });
        var files = component.get("v.files");
        files.forEach(function(file, fileIndex){
            if(fileIndex===index){
                files[fileIndex].progress = 0;
                files[fileIndex].status = "cancelled";
            }
        });
        component.set("v.files", files);
        component.find("utils").showError("Upload cancelled successfully.");
        component.find("utils").hideProcessing();
    },
    cancelAllFilesUpload : function(component, event, helper) {
        helper.cancelAllFilesUpload(component, event, helper, function(){
            component.set("v.files", []);
            component.set("v.filesXHR", []);
        });
    },
    done : function(component, event, helper) {
        helper.cancelAllFilesUpload(component, event, helper, function(){
            component.set("v.files", []);
            component.set("v.filesXHR", []);
            component.find("utils").hideProcessing();
            helper.closeModal(component);
        });
    }
})