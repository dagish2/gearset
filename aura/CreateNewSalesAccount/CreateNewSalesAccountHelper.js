({
    createNewSalesAccount: function(component, event, helper) {
        component.find("utils").showProcessing();
        var salesAccount = Object.assign(component.get("v.mapParentAccount"), component.get("v.mapSalesAccount"));
        salesAccount.sobjectType = "Account";
        salesAccount.Org_Identification_Status__c = "Processed";
        salesAccount.Name = component.get("v.mapParentAccount.Name") + component.get("v.mapSalesAccount.Nickname__c");
        salesAccount.ParentId = component.get("v.recordId");
        salesAccount.Website = component.get("v.mapSalesAccount.Website");
        delete salesAccount.Id;
        if(!salesAccount.OwnerId){
            component.find("utils").showError("Please Select User");
            component.find("utils").hideProcessing();
            return;
        }
        component.find("utils").execute("c.saveRecord", {"record" : salesAccount}, function(response){
            if(response && response.length){
                component.find("utils").showSuccess("Sales Account Created successfully");
                component.find("utils").hideProcessing();
                component.find("confirmation").closeModal();
            }
            try{
                setTimeout(function () {
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    var salesAccountId = JSON.parse(response).id;
                    if(dismissActionPanel) {
                        component.find("utils").closeTab();
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/" + salesAccountId
                        });
                        urlEvent.fire();
                    } else{
                        if(opener != null && opener != undefined){
                            window.close();
                            parent.postMessage("close", opener.location.href = "/" + salesAccountId); 
                        }else{
                            component.find("utils").closeTab();
                            component.find("utils").redirectToUrl("/"+salesAccountId);
                        }
                    }
                }, 1000);
            }catch(err){
                component.find("utils").showError(err);
            }
        },function(error){
            if(Array.isArray(error) && error.length){
                error = error[0];
            }
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
    },
    setHeadermeta:function(component){
        var lstMetaFields = [];
        lstMetaFields.push({"label":"Account Owner", "apiName":"Owner.Name", "isNameField":true});//type is phone to get same css as phone field
        lstMetaFields.push({"label":"Record Type", "apiName":"RecordType.Name", "type":"string"});
        lstMetaFields.push({"label":"Account Type", "apiName":"Account_Type__c", "type":"string"});//type is phone to get same css as phone field
        lstMetaFields.push({"label":"Main Contact", "apiName":"Primary_Member__r.Name", "isNameField":true});//type is phone to get same css as phone field
        component.set("v.headerMeta", lstMetaFields);
    }
})