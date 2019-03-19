({
    doInit: function(component, event, helper) {
        component.find("utils").setTitle("Assign To Account");
        var instructions = [];
        instructions.push("The name of the billing account should reflect the legal name of the company, as listed on their membership agreement.");
        instructions.push("The primary member on billing account should match the primary member on the membership agreement.");
        instructions.push("If a billing account cannot be found below that satisfies these conditions, select 'Add New'.");
        component.set("v.instructions", instructions);
        var metaFields = [];
        metaFields.push({"name":"Id","label":"Action","type":"component","sort":"false","component":{"name":"c:EnziInputRadio","attributes":{"value":component.getReference("v.selectedRecord"),"text":"{{UUID__c}}"}}});
        metaFields.push({"name":"Name","label":"Billing Account Name","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Name}}","value":"/{{Id}}","target":"_new"}}});
        metaFields.push({"name":"Id","label":"Primary Member Name","sort":"false","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Primary_Member__r.Name}}","value":"/{{Primary_Member__c}}","target":"_new"}}});
        metaFields.push({"name":"Id","label":"Primary Member Email","sort":"false","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Primary_Member__r.Email}}","value":"mailto:{{Primary_Member__r.Email}}","target":"_new"}}});
        metaFields.push({"name":"Parent.Name","label":"Parent Account","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Parent_Account__r.Name}}","value":"/{{Parent_Account__c}}","target":"_new"}}});
        metaFields.push({"name":"Parent_Account__r.Account_Type__c","label":"Parent Account Type"});
        metaFields.push({"name":"ID_Status__c","label":"Billing Account Status"});
        metaFields.push({"name":"UUID__c","label":"UUID"});
        component.set("v.metaFields", metaFields);
        helper.reset(component, false);
        if(!component.get("v.opportunityId")){
            component.find("utils").showError('No Opportunity Id found.');
        }else{
            component.find("utils").showProcessing();
            component.find("utils").execute("c.getOpportunityData",{"opportunityId": component.get("v.opportunityId")},function(response) {
                var result = JSON.parse(response);
                if(result.isValidForAssociation) {
                    component.set("v.opportunityRecord", result.opportunityRecord);
                    component.set("v.billingAccounts", result.billingAccounts);
                    component.set("v.ultimateParentOrgId", result.ultimateParentOrgId);
                    component.set("v.apiSetting", JSON.parse(result.apiSetting.Data__c)["CreateAccountAPI"]);
                    if(result.opportunityRecord.Billing_Account__r != null && result.opportunityRecord.Billing_Account__r != undefined && result.opportunityRecord.Billing_Account__r.UUID__c != null && result.opportunityRecord.Billing_Account__r.UUID__c != undefined) {
                        component.set("v.selectedRecord", result.opportunityRecord.Billing_Account__r.UUID__c);
                    }
                    if(result.isValidStage){
                        component.set("v.allowAssociation", true);
                    } else{
                        component.set("v.message","You can not perform this action for current Opportunity Stage or Contract Stage.")
                    }
                }else {
                    component.set("v.allowAssociation", result.isValidForAssociation);
                    component.set("v.message","To update the billing account please contact Growth Ops.")
                }
                component.find("utils").hideProcessing();
            },function(error) {
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            },component);
        }
    },
    showAddNewBillingAccountModal: function(component, event, helper) {
        component.set("v.allowEditBillingAccount.ParentAccountName",  false);
        component.set("v.newBillingAccount", {
            "sobjectType": "Billing_Account__c",
            "Parent_Account__c": component.get("v.opportunityRecord.AccountId")
        });
        component.set("v.showAddNewBillingAccountModal", true);
    },
    closeAddNewBillingAccountModal: function(component, event, helper) {
        helper.reset(component, false);
        component.set("v.showAddNewBillingAccountModal", false);
    },
    getOpportunityMainContact: function(component, event, helper) {
        component.find("utils").showProcessing();
        var query = "SELECT ID, Email, Phone, Name, AccountId, Account.Parent_Org_Name__c, Billing_Account__c, Billing_Account__r.Name From Contact WHERE Id = '"+component.get("v.opportunityRecord.Primary_Member__c")+"'";
        helper.getContact(component, query, component.get("v.opportunityRecord.Primary_Member__c"), function(objContact) {
            component.find("utils").hideProcessing();
        });
    },
    searchContacts: function(component, event, helper) {
        var keyword = event.currentTarget.value;
        if(keyword == '' || keyword.length == 0) {
            helper.reset(component, false);
        } else if(keyword.length > 2) {
            component.set("v.contact.Email", keyword);
            component.set("v.email", keyword);
            component.find("utils").execute("c.getListQueryDataBySOSL",{"arrQuery":["FIND  \'"+ component.find("utils").addSlashes(keyword) +"*\' IN ALL FIELDS RETURNING Contact(Id,Name,Email,Account.Name,Account.Id,Account.Primary_Member__c,Account.Parent_Org_Name__c,Billing_Account__c) LIMIT 10"]},function(response) {
                var contactRecords = [];
                for(var o in response) {
                    for(var d in response[o]) {
                        response[o][d]["type"] = "contact";
                        contactRecords.push(response[o][d]);
                    }
                }
                if(contactRecords.length == 0) {
                    helper.reset(component, true);
                }
                component.set("v.contactRecords", contactRecords);
                var a = document.getElementById("listbox-unique-id");
                $A.util.removeClass(a, "slds-hide");
            },function(error) {
                component.find("utils").showError(error);
            });
        }
    },
    selectContact: function(component, event, helper) {
        var contactId = event.currentTarget.id;
        component.find("utils").showProcessing();
        var query = "SELECT ID, Email, Phone, Name, AccountId, Account.Parent_Org_Name__c, Billing_Account__c, Billing_Account__r.Name From Contact WHERE Id = '"+contactId+"'";
        helper.getContact(component, query, contactId, function(objContact) {
            component.find("utils").hideProcessing();
        });
    },
    saveNewBillingAccount: function(component, event, helper) {
        component.find("utils").showProcessing();
        var contact = component.get("v.contact");
        if(contact != undefined && contact.Email != undefined && contact.Email.length > 0 && !component.find("enziValidate").validateFromOtherComponent("email", contact.Email)) {
            var query = "SELECT Id, Name, Primary_Member__c, Primary_Member__r.Name FROM Billing_Account__c WHERE Primary_Member__r.Email = '"+ component.find("utils").addSlashes(contact.Email) +"'";
            component.find("utils").execute("c.getQueryData",{"query": query},function(objBillingAccs){
                if(objBillingAccs != undefined && objBillingAccs.length > 0 && objBillingAccs[0].Primary_Member__r) {
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(contact.Name+" is already a primary member on "+objBillingAccs[0].Name+". Please select another contact or contact your support team.");
                } else if(contact != undefined && contact != null) {
                    if(contact.Id != undefined && contact.AccountId != undefined) {
                        component.find("utils").execute("c.getOrg", {"accountId": contact.AccountId},function(ultimateParentOrgId) {
                            if(ultimateParentOrgId != undefined && ultimateParentOrgId != component.get("v.ultimateParentOrgId")) {
                                component.find("utils").hideProcessing();
                                component.find("utils").showError(contact.Name+" is a member of a different Organization. You can only select a member of your Organization. Please contact your support team.");
                            } else {
                                helper.saveBillingAccount(component, helper,contact, function() {
                                    component.find("utils").hideProcessing();
                                    component.find("utils").showSuccess('Billing account created successfully.');
                                });
                            }
                        });
                    }else {
                        helper.saveBillingAccount(component, helper, contact, function() {
                            component.find("utils").hideProcessing();
                            component.find("utils").showSuccess('Billing account created successfully.');
                        });
                    }
                }
            },function(error) {
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            });
        } else {
            component.find("utils").hideProcessing();
            component.find("utils").showError("Incorrect Email");
        }
    },
    updateAccountOnOpportunity: function(component, event, helper) {
        component.find("utils").showProcessing();
        var billingAccount = component.get("v.billingAccounts")[component.get("v.billingAccounts").findIndex(x => x.UUID__c==component.get("v.selectedRecord"))];
        helper.updateAccountOnOpportunity(component, helper, billingAccount.Id, function() {
            component.find("utils").hideProcessing();
            component.find("utils").showSuccess('Opportunity updated successfully.');
            helper.openSFRecord(component, component.get("v.opportunityId"));
        },function(error) {
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    sendPaperwork: function(component, event, helper) {
        component.find("utils").showProcessing();
        helper.checkValidForSendPaperWork(component, helper, function(isValid) {
            var billingAccount = component.get("v.billingAccounts")[component.get("v.billingAccounts").findIndex(x => x.UUID__c==component.get("v.selectedRecord"))];
            helper.updateAccountOnOpportunity(component, helper, billingAccount.Id, function() {
                helper.spacestationRedirection(component, helper, event);
            },function(error) {
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            });
        });
    },
    close: function(component, event, helper) {
        helper.openSFRecord(component, component.get("v.opportunityId"));
    }
})