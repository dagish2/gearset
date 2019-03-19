({
    checkDuplicateOrganization : function(component, helper, useCreatedAccount, onSuccess) {
        var accRec = component.get("v.accountRec");
        component.find("utils").showProcessing();
        var strQuery ="SELECT Id, Name, RecordType.Name FROM Account WHERE Name = '" + component.find("utils").addSlashes(accRec.Name) + "' AND Account_Type__c = 'Org'";
        component.find("utils").execute("c.getQueryData", {"query": strQuery}, function(response){
            var  lstAccounts = JSON.parse(JSON.stringify(response));
            if(lstAccounts.length > 0){
                var existingAcc = lstAccounts[0];
                component.find("utils").hideProcessing();
                component.find("utils").showError("An Organization account with " + component.get("v.accountRec.Name") + " already exist.");
                onSuccess(false);
            }else{
                var conRec = JSON.parse(JSON.stringify(component.get("v.contactRec")));
                var billAccRec = component.get("v.billingAccountRec");
                if(conRec.hasOwnProperty('Id') && conRec.Email != undefined){
                    delete conRec.Email;
                }
                var lstSObjects = [];
                lstSObjects.push(accRec);
                if(!component.get("v.canCreateEnterpriseOrg")){
                    accRec.Number_of_Full_Time_Employees__c != undefined ? conRec["Number_of_Full_Time_Employees__c"] = accRec.Number_of_Full_Time_Employees__c : '';
                    accRec.Interested_in_Number_of_Desks__c != undefined ? conRec["Interested_in_Number_of_Desks__c"] = accRec.Interested_in_Number_of_Desks__c : '';
                    accRec.Description != undefined ? conRec["Description"] = accRec.Description : '';
                    conRec.sobjectType = "Contact";
                    if(useCreatedAccount){
                        conRec.Convert_Lead__c = false;
                    }
                    lstSObjects.push(conRec);
                    if(billAccRec != undefined){
                        billAccRec.sobjectType = "Billing_Account__c";
                        lstSObjects.push(billAccRec);
                    }
                }                
                onSuccess(lstSObjects);
            }
        }, function(error){
            component.find("utils").showError(error);
        });
    },
    createNewOrganization : function(component, helper) {
        var useCreatedAccount = component.get("v.useCreatedAccount");
        helper.checkDuplicateOrganization(component, helper, useCreatedAccount, function(result){
            if(result && typeof(result) !== "boolean"){
                let leadRec = component.get("v.leadRec");
                if(leadRec){
                    leadRec["sobjectType"] = "Lead";
                    result.push(leadRec);
                }
                component.find("utils").execute("c.createNewOrganization", {"lstRecords": result} ,function(response){                    
                    component.find("utils").hideProcessing();
                    if(response){                         
                        component.find("utils").showSuccess("New Account has been created successfully.");
                        var objAccount = {};
                        objAccount.Id = response;
                        objAccount.sobjectType = "Account";
                        component.set("v.isNewAccountCreated", true);
                        component.set("v.selectedOrg", objAccount);
                        if(component.get("v.previous.label") == undefined){
                            window.setTimeout(
                                $A.getCallback(function() {
                                    helper.openSfRecord(component, response);
                                }),
                                1500);    
                        }  else if(useCreatedAccount){
                            $A.enqueueAction(useCreatedAccount);                            
                        }
                    }else{
                        component.find("utils").showError("Something went wrong, please contact your system administrator.");
                    }
                },function(error){
                    component.find("utils").hideProcessing();            
                    component.find("utils").showError(error);
                }, component);
            }
        });
    },
    requestNewOrganization : function(component, helper) {
        var useCreatedAccount = component.get("v.useCreatedAccount");
        var recordId = component.get("v.recordId");
        helper.checkDuplicateOrganization(component, helper, useCreatedAccount, function(result){
            if(result && typeof(result) !== "boolean"){
                for(var iIndex in result){
                    if(component.get("v.contactRec.Email") && result[iIndex].hasOwnProperty("sobjectType") && result[iIndex]["sobjectType"].toLowerCase() == "contact" && ((result[iIndex].hasOwnProperty("Email") && !result[iIndex]["Email"]) || !result[iIndex].hasOwnProperty("Email"))){
                        result[iIndex]["Email"] = component.get("v.contactRec.Email");
                    }
                }
                component.find("utils").execute("c.sendNewOrganizationRequest", {"lstRecords": result} ,function(response){                    
                    component.find("utils").hideProcessing();
                    if(response){                        
                        component.find("utils").showSuccess("New Organization request has been sent successfully.");
                        if(component.get("v.previous.label") == undefined){
                            window.setTimeout(
                                $A.getCallback(function() {
                                    helper.close(component);
                                }),
                                1500);
                        } else if(useCreatedAccount){
                            helper.openSfRecord(component, recordId);
                        }
                    }else{
                        component.find("utils").showError("Something went wrong, please contact your system administrator.");
                    }
                },function(error){
                    component.find("utils").hideProcessing();            
                    component.find("utils").showError(error);
                }, component);
            }
        });
    },
    checkBillingAccount : function( component, helper, contactRec){
        var mapDisabled = {};
        var billAcc;
        var isPrimaryMember = false;
        var canCreateOrg = false;
        var billingAcc = null;
        var errorMsg = null;
        var warningMsg = null;
        component.set("v.existingContact",contactRec);
        contactRec.FirstName != undefined ? (component.set("v.contactRec.FirstName", contactRec.FirstName), mapDisabled["FirstName"] = true) : '';
        contactRec.LastName != undefined ? (component.set("v.contactRec.LastName", contactRec.LastName), mapDisabled["LastName"] = true): '';
        contactRec.Phone != undefined ? (component.set("v.contactRec.Phone", contactRec.Phone), mapDisabled["Phone"]  = true): '';
        contactRec.AccountId != undefined ? component.set("v.contactRec.AccountId",contactRec.AccountId): '';
        contactRec.Id != undefined ? component.set("v.contactRec.Id",contactRec.Id): '';
        component.set("v.contactRec.sobjectType","Contact");
        component.set("v.mapDisabled",mapDisabled);
        if(contactRec.Billing_Accounts__r && contactRec.Billing_Accounts__r.length>0){
            billAcc = contactRec.Billing_Accounts__r[0];
            isPrimaryMember = !(contactRec.AccountId == undefined && billAcc.Parent_Account__c == undefined);
        }else if(contactRec.Billing_Account__r){
            billAcc = contactRec.Billing_Account__r;
        }else{
            warningMsg = 'Contact already present with same Email Address.';
        }
        if(isPrimaryMember && billAcc && contactRec && ((contactRec.AccountId && billAcc.Parent_Account__c) || (!contactRec.AccountId && billAcc.Parent_Account__c) || (contactRec.AccountId && !billAcc.Parent_Account__c))){
            errorMsg = 'Contact is Primary Member on "'+billAcc.Name+'" Billing Account. You can not create or submit a request for account.';
        }else if(!isPrimaryMember && billAcc && contactRec){
            canCreateOrg = true;
            if(contactRec.AccountId && billAcc.Parent_Account__c){
                warningMsg = 'Contact is Member on "'+billAcc.Name+'" Billing Account.';
            }else if(contactRec.AccountId && !billAcc.Parent_Account__c){
                billingAcc = billAcc;
                billingAcc.Parent_Account__c = contactRec.AccountId;
            }else if(!contactRec.AccountId && billAcc.Parent_Account__c){
                component.set("v.contactRec.AccountId",billAcc.Parent_Account__c)
            }else if(!contactRec.AccountId && !billAcc.Parent_Account__c){
                billingAcc = billAcc;
            }
        }else{
            canCreateOrg = true;
        }
        component.set("v.canCreateOrg",canCreateOrg);
        if(billingAcc != undefined){
            billingAcc["sobjectType"] = "Billing_Account__c";
        }
        if(errorMsg){
            component.find("utils").showError(errorMsg);
        }else if(warningMsg){
            component.find("utils").showWarning( warningMsg, false);
        }
        component.set("v.billingAccountRec",billingAcc);
    },
    openSfRecord: function(component, recordId) {
        if(JSON.parse(component.get("v.isInLightningConsole"))){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.isConsoleNavigation().then(function(response) {
                if(response){
                    workspaceAPI.openTab({
                        recordId: recordId,
                        focus: true
                    }).then(function(response) {
                        workspaceAPI.getEnclosingTabId().then(function(tabId) {
                            workspaceAPI.closeTab({tabId: tabId});
                        })
                        component.find("utils").closeTab();                	
                    })
                    .catch(function(error) {
                        console.log(error);
                    }); 
                    
                }else{
                    //component.find("utils").closeTab();
                    component.find("utils").redirectToUrl('/'+recordId, '', false);
                }
            })
            .catch(function(error) {
                console.log(error);
            });
        }else if(component.get("v.isFromConverBrokerFunctionality")){
            component.find("utils").redirectToUrl('/'+ (component.get("v.redirectIdAfterRequestNewOrg") ? component.get("v.redirectIdAfterRequestNewOrg") : recordId), '', false);
        }else{
            //component.find("utils").closeTab();
            component.find("utils").redirectToUrl('/'+recordId, '', false);
        }        
    },
    close :function(component) {
        if(JSON.parse(component.get("v.isInLightningConsole"))){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.isConsoleNavigation().then(function(response) {
                if(response){
                    workspaceAPI.getEnclosingTabId().then(function(tabId) {
                        workspaceAPI.closeTab({tabId: tabId});
                        component.find("utils").closeTab();
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                } else {
                    component.find("utils").closeTab();
                    component.find("utils").redirectToUrl('back');
                }
            })
            .catch(function(error) {
                console.log(error);
            });
        }else{
            component.find("utils").closeTab();
            component.find("utils").redirectToUrl('back');
        }
    },
    resetDisabled : function(component){
        component.set("v.mapDisabled", {'FirstName':false, 'LastName':false, 'Phone':false});
    },
    resetContact : function(component, email){
        component.set("v.contactRec", {'sobjectType':'Contact', 'FirstName':null, 'LastName':null, 'Email':email, 'Phone':null});
        component.set("v.mapDisabled", {'FirstName':false, 'LastName':false, 'Phone':false});
    }
})