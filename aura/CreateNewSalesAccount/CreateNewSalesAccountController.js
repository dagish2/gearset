({
    doInit: function(component, event, helper) {
        component.find("utils").setTitle("New Sales Account");   
        component.find("utils").showProcessing();
        component.find("utils").execute("c.isValidForSalesAccount", {"recordId" : component.get("v.recordId")}, function(response){
            var result = JSON.parse(response);
            if(result.isValid){
                component.set("v.isValidUser", result.isValid);                
                component.find("utils").execute("c.getQueryData", {"query":"SELECT Data__c FROM Setting__c WHERE Name = 'SalesAccountSetting'"}, function(response){
                    if(response && response.length){
                        var settingData = JSON.parse(response[0].Data__c);
                        var accountFields = settingData["AccountFields"];
                        var instructions = settingData["Instructions"];
                        component.set("v.mapInstructions", instructions);
                        var strOrgAccountQuery = "SELECT " + accountFields;
                        strOrgAccountQuery += " FROM Account WHERE Id = '" + component.get("v.recordId") + "'";
                        component.find("utils").execute("c.getQueryData", {"query" : strOrgAccountQuery}, function(response){
                            if(response && response.length) {
                                component.set("v.mapParentAccount", response[0]);
                                helper.setHeadermeta(component);
                                component.find("utils").hideProcessing();
                            }
                        },function(error){
                            component.find("utils").hideProcessing();
                            component.find("utils").showError(error);
                        });
                    } else {
                        component.find("utils").hideProcessing();
                        component.find("utils").showError("No Records Under Sales Console Setting");
                    }
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                })
            }else{
                $A.createComponent(
                    "ui:message",{ 
                        "title" : result.errorMessage,
                        "severity" : "warning"
                    },
                    function(components,status,statusMessagesList){
                        if (status === "SUCCESS") {
                            var errorMessage = component.find("errorMessage");
                            errorMessage.set("v.body", components);
                        }else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.");
                            helper.showMessage(component, event, "Success", "No response from server or client is offline.");
                        }else if (status === "ERROR") {
                            console.log("Error: " + statusMessagesList);
                        }
                    }
                );
                component.find("utils").hideProcessing();
            }
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        } , component);
    },
    cancelSalesAccount : function(component, event, helper) {
        component.find("utils").showConfirm("Are you sure, you want to leave the page?", function(){ 
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            if(dismissActionPanel){
                dismissActionPanel.fire();    
            }else{
                component.find("utils").closeTab(); 
            }
        });
    },
    showModal : function(component, event, helper){
        var mapInstructions = component.get("v.mapInstructions");
        var instructions = [];
        if(!component.get("v.mapSalesAccount.Website") ){
            component.set("v.confirmationForSave", false);
            instructions = mapInstructions["WithoutWebsite"];
        }else{
            component.set("v.confirmationForSave", true);
            instructions = mapInstructions["WithWebsite"];          	
        }
        component.set("v.instructions", instructions);
        component.find("confirmation").showModal();                                                   
    },
    closeModal : function(component, event, helper){
        component.find("confirmation").closeModal();
    },
    createNewSalesAccount : function(component, event, helper){
        helper.createNewSalesAccount(component, event, helper);
    }
})