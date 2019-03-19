({
    doInit: function(component, event, helper) {
        component.find("utils").setTitle("Create Opportunity");       
        var instructions = [];
        instructions.push("To create a new Organization Account, please ensure that an existing Organization Account is not currently present in the system. You can check for this using the search function.");
        instructions.push("If the desired Organization Account does not exist, click on 'Next' it will redirect you to 'Create New Organization' page and input the required fields, indicated by a red star.");
        
        var mapInstructions = new Map([["searchOrganization", instructions]]);
        component.set("v.instructions", mapInstructions.get("searchOrganization"));
        component.set("v.header", "Search Organization");
        
        instructions = [];
        instructions.push("To create a new Organization Account, please ensure that an existing Organization Account is not currently present in the system. You can check for this using the search function.");
        instructions.push("If the desired Organization Account does not exist, click on 'Next' it will redirect you to 'Request New Organization' page and input the required fields, indicated by a red star.");
        
        mapInstructions.set("requestNewOrganization", instructions);
        component.set("v.mapInstructions", mapInstructions);
        component.set("v.requestedOrg", new Map());
        component.find("utils").showProcessing();
        var recordId = component.get("v.recordId");
        component.set("v.fromGlobalAction", (recordId == undefined || recordId == ""));
        if(recordId == undefined || recordId == ""){
            component.set("v.allowCreateOpp", (recordId == undefined || recordId == ""));
        }
        component.set("v.currentDate", new Date());        
        helper.getRecordDetails(component, helper, recordId, function(response){
            var result = response;
            helper.setDataFields(component, helper, result);
            component.set("v.record", result);
            component.set("v.allowCreateOpp", result.isValidForCreateOpp);
            var data = JSON.parse(result.opportunityQualifySetting.Data__c)
            component.set("v.OpportunityQualifySetting", Object.assign({}, data));          
            var family = Object.assign({}, data)["family"]
            component.set("v.quantityinunits", family);
            var options = [];
            for(key in family){
                options.push({"label": key, "value": key});
            }
            component.set("v.familyoptions", options);
            
            var brokerOptions = [{"label": "Yes", "value": "Yes"}, {"label": "No", "value": "No"}];
            component.set("v.isBrokerOptions", brokerOptions);
            
            component.set("v.isProfileAllowed", false);
            Array.from(component.get("v.OpportunityQualifySetting")["profiles"]).forEach(function(profileName){
                if(profileName.toLowerCase() == result.userInfo.Profile.Name.toLowerCase()){
                    component.set("v.isProfileAllowed", true);
                }                    
            });            
            component.set("v.mapRecordTypeInfo", result.recordTypeInfo);
            var mapRecordTypes = {};
            Object.keys(result.recordTypeInfo).forEach(function(objectName){
                mapRecordTypes[objectName] = result.recordTypeInfo[objectName]["Enterprise Solutions"];
            });            
            component.set("v.mapRecordTypes", mapRecordTypes);
            component.set("v.hasNoRecordId", component.get("v.fromGlobalAction") ? true : false);
            if(!component.get("v.fromGlobalAction")){                
                helper.setRecordData(component, helper, result, function(setRecordDataResponse){
                    component.set("v.disabledOnLoad.orgAccountId", helper.checkNullUndefineOrBlank(component.get("v.orgAccountId")));
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                }); 
            }
            component.find("utils").hideProcessing();
        }, function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },   
    changeBuildingOption: function(component, event, helper) { 
        var opportunityRecord = component.get("v.opportunityRecord");
        if(helper.checkNullUndefineOrBlank(opportunityRecord)){  
            if(component.get("v.selectedBuildingOption") == "Primary Building"){
                component.set("v.opportunityRecord.Geography__c", null); 
            } else{
                component.set("v.opportunityRecord.Building__c", null); 
            }
        }
    },
    changeSearchOrg: function(component, event, helper) {
        if(helper.checkNullUndefineOrBlank(component.get("v.orgAccountId")) && component.get("v.hasNoRecordId")){
            component.set("v.salesAccountId", null);
            component.set("v.saleAccCriteria", "Parent_Org__c = '" + component.get("v.orgAccountId").substr(0, 15) + "' AND Account_Type__c = 'Sales'");            
            component.find("utils").showProcessing();            
            component.set("v.opportunityRoleRecord.Primary_Member__c", null);
            helper.resetDefaultRecord(component, helper, function(){
                var strQuery = "SELECT Id, Name, Primary_Member__c, RecordType.Name, (SELECT Id, Name, Account_Type__c From ChildAccounts Where Account_Type__c = 'Sales') FROM Account WHERE Id= '"+component.get("v.orgAccountId")+"'";
                if(strQuery && helper.checkNullUndefineOrBlank(strQuery)){
                    component.find("utils").execute("c.getQueryData", {"query":strQuery}, function(response){
                        if(response.success != false){      
                            if(response && response.length > 0 && (response[0].ChildAccounts == undefined || response[0].ChildAccounts == null)){
                                component.set("v.salesAccountSearch", false);
                            }else{
                                component.set("v.salesAccountSearch", true);
                            }
                            if(response && response.length > 0 && response[0]['RecordType'] && response[0]['RecordType']['Name']){
                                component.set('v.orgRecordTypeName', response[0]['RecordType']['Name']);
                            }
                            helper.getRecordDetails(component, helper, component.get("v.orgAccountId"), function(result){
                                component.set("v.record", result);
                                helper.setDataFields(component, helper, result);
                                component.find("utils").hideProcessing();
                                helper.setRecordData(component, helper, component.get("v.record"), function(setRecordResponse){
                                    component.find("utils").hideProcessing();
                                    component.find("CreateNewOrganization").closeModal();
                                },function(error){
                                    component.find("utils").hideProcessing(); 
                                })
                            }, function(error){
                                component.find("utils").hideProcessing();
                                component.find("utils").showError(error);
                            })
                        } else {
                            component.find("utils").hideProcessing();
                            onError(response.message);
                        }
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    });  
                }
            }, function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            });
        } else if(helper.checkNullUndefineOrBlank(component.get("v.orgAccountId"))){
            if(component.get("v.saleAccCriteria") == undefined){
                component.set("v.saleAccCriteria", "Parent_Org__c = '" + component.get("v.orgAccountId").substr(0, 15) + "'");
            }
            var strQuery = "SELECT Id, Name, Primary_Member__c, RecordType.Name, (SELECT Id, Name, Account_Type__c From ChildAccounts Where Account_Type__c = 'Sales') FROM Account WHERE Id= '"+component.get("v.orgAccountId")+"'";
            if(strQuery && helper.checkNullUndefineOrBlank(strQuery)){
                component.find("utils").execute("c.getQueryData",{"query":strQuery}, function(response){
                    if(response.success != false){ 
                        if(response && response.length > 0 && (response[0].ChildAccounts == undefined || response[0].ChildAccounts == null)){
                            component.set("v.salesAccountSearch", false);
                        } else{
                            component.set("v.salesAccountSearch", true);
                        }
                        if(response && response.length > 0 && response[0]['RecordType'] && response[0]['RecordType']['Name']){
                            component.set('v.orgRecordTypeName', response[0]['RecordType']['Name']);
                        }
                    } else {
                        component.find("utils").hideProcessing();
                        onError(response.message);
                    }
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                });
            }
        } else {
            component.set("v.saleAccCriteria", null);
            component.set("v.salesAccountId", null);
            component.set("v.opportunityRoleRecord.Contact__c", null);
        }
    },
    showCreateOrgPopup: function(component, event, helper){
        var searchOrg = {"searchOrgName":"", "enableSearchOrg":false, "enableDataTableSection":false, "enableRequestSection":false, "enableExistingOrg":true, "enableNewRequest":false, "searchOrgTab":true, "requestOrgTab":false};
        component.set("v.searchOrg", searchOrg);
        component.find("createNewOrganization").showModal();
    },
    showCreateContactPopup: function(component, event, helper){
        component.find("createNewContact").showModal();
    },
    closeCreateContactPopup: function(component, event, helper){
        component.find("createNewContact").closeModal();
        helper.resetPrimaryContact(component);
    },
    createPrimaryContact: function(component, event, helper){
        if(helper.checkNullUndefineOrBlank(component.get('v.orgAccountId'))){
            var contact = component.get("v.newPrimaryContact");
            contact["AccountId"] = helper.checkNullUndefineOrBlank(component.get("v.salesAccountId")) ? component.get("v.salesAccountId") : component.get('v.orgAccountId');
            var mapRecordTypeInfo = component.get('v.mapRecordTypeInfo');
            contact["RecordTypeId"] = mapRecordTypeInfo['Contact'][component.get('v.orgRecordTypeName')];
            component.find("utils").execute("c.saveRecord",{"record":contact}, function(response){
                if(response && (JSON.parse(response).success)){
                    component.set("v.opportunityRoleRecord.Contact__c",JSON.parse(response).id);
                    component.find("utils").showSuccess("New " + (helper.checkNullUndefineOrBlank(component.get("v.opportunityRoleRecord.Role__c"))?((component.get("v.opportunityRoleRecord.Role__c")=='Primary Member')?"Main Contact":component.get("v.opportunityRoleRecord.Role__c")):"Contact")+" created successfully.");
                    contact["FirstName"] = null;
                    contact["LastName"] = null;
                    contact["Email"] = null;
                    component.set("v.newPrimaryContact", contact);
                    component.find("createNewContact").closeModal();
                }else{
                    component.find("utils").showError("Something went wrong, please contact your system administrator.");
                }
            },function(error){
                component.find("utils").hideProcessing();            
                component.find("utils").showError(error.search("EXCEPTION,") > 0 ? error.split("EXCEPTION,")[1] : error);
            });
        } else {
            component.find("createNewContact").closeModal();
            component.find("utils").showError('Please select organization first.');
        }
    },
    save: function(component, event, helper){
        let buttons = {'confirm':{'leftIcon':'utility:like','rightIcon':'','label':'Confirm'},'decline':{'leftIcon':'utility:undo','rightIcon':'','label':'Go Back'}};
        component.find("utils").showConfirm("Upon confirming, you will be navigated to the new Opportunity.",function(){
            helper.save(component, false);
        }, null, buttons, "confirmModal");
    },
    addProducts: function(component, event, helper){
        helper.save(component, true);
    },
    cancel: function(component, event, helper){
        let buttons = {'confirm':{'leftIcon':'utility:like','rightIcon':'','label':'Confirm'},'decline':{'leftIcon':'utility:undo','rightIcon':'','label':'Go Back'}};
        component.find("utils").showConfirm("The Opportunity will not be created and your progress will not be saved. Are you sure you want to close?",function(){
        if(component.get("v.recordId")){
            helper.openSFRecord(component, helper, component.get("v.recordId"), false);
        }else{
            component.find("utils").closeTab();
            component.find("utils").redirectToUrl('back');
        }
        }, null, buttons, "confirmModal");
    },
    closeFocusedTab: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            alert("Focused Tab::" + focusedTabId);
        }).catch(function(error) {
            console.log(error);
        });
    },
    changefamily : function(component, event, helper) {
        var units = component.get("v.quantityinunits");
        var type = component.get("v.opportunityRecord.Type__c");
        units.hasOwnProperty(type) ? component.set("v.units", units[type]) : component.set("v.units", "") ;
        component.set("v.opportunityRecord.Requirement_Quantity__c", null);
        component.set("v.opportunityRecord.Desired_Budget__c", null);
    },
    requestNewOrgModal : function(component, event, helper) {
        component.set("v.accountName", component.get("v.orgName"));
        helper.setrequestNewOrg(component, helper);
        component.find("CreateNewOrganization").showModal();
    },
    closeCreateNewOrganization : function(component, event, helper) {
        helper.previous(component, helper);
        helper.closeCreateNewOrganization(component, true);
    },
    closeCreateNewOrganizationFromRequest : function(component, event, helper) {
        helper.previous(component, helper);
        helper.closeCreateNewOrganization(component, false);
        component.find("utils").closeTab();
        component.find("utils").redirectToUrl('back');
    },
    requestNewOrgSuccess : function(component, event, helper) {
        if(component.get("v.requestNewOrgSuccess")){
            component.find("utils").showSuccess("New Organization request has been successfully sent.");
            helper.closeCreateNewOrganization(component, false);
        } else {
            component.find("utils").showError("Something went wrong, please contact your system administrator.");
        }
    },
    useExistingOrg: function(component, event, helper) {
       if(component.get("v.selectedOrgId") != component.get("v.orgAccountId")){
            component.set("v.orgAccountId", component.get("v.selectedOrgId"));
        }else{
            component.set("v.orgAccountId", null);
            component.set("v.orgAccountId", component.get("v.selectedOrgId"));
        }
        helper.closeCreateNewOrganization(component, false);
    },
    showOrgRelatedSalesAccounts: function(component, event, helper) {
        component.set("v.selectedSalesAccountId", null);
        component.find("ShowOrgRelatedSalesAccounts").showModal();
    },
    closeOrgRelatedSalesAccounts: function(component, event, helper) {
        component.find("ShowOrgRelatedSalesAccounts").closeModal();
    },
    selectSalesAccount: function(component, event, helper) {
        component.find("utils").showProcessing(); 
        component.set("v.salesAccountId", component.get("v.selectedSalesAccountId"));
        helper.updateMainContact(component, helper, component.get("v.selectedSalesAccountId"), function(){
            component.find("ShowOrgRelatedSalesAccounts").closeModal();
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        }); 
    },
    next : function(component,event,helper){
        helper.addHideClass(component, "searchOrganization");
        helper.removeHideClass(component, "requestNewOrganization");
        helper.setrequestNewOrg(component, helper);
        helper.changeHeaderAndInstructions(component, "Request New Organization");
    },
    previous : function(component, event, helper){
        helper.previous(component, helper);
        helper.removeHideClass(component, "accountinstructions");
        helper.changeHeaderAndInstructions(component, "Search Organization");
    },
    changeBrokerInvolvement : function(component, event, helper){
        component.set("v.opportunityRecord.Referrer__c", "");
    }
})