({
    doInit: function (component, event, helper) {
        component.find("utils").showProcessing();
        component.find("utils").setTitle("Send Paperwork");
        var metaFields = []; 
        component.find("utils").execute("c.getBillAccountsOfAccountHierarchy",{"accountId":component.get("v.parentId"),"opportunityId":component.get("v.recordId")},function(response) {
            component.find("utils").hideProcessing(); 
            if(response && response.accountInfo && response.accountInfo && response.accountInfo.Account_Type__c && response.accountInfo.Account_Type__c.toLowerCase() != 'bill') {
                metaFields.push({"name":"Id","label":"Action","type":"component","sort":"false","component":{"name":"c:EnziInputRadio","attributes":{"value":component.getReference("v.selectedRecord"),"text":"{{UUID__c}}"}}});
                metaFields.push({"name":"Name","label":"Billing Account Name","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Name}}","value":"/{{Id}}","target":"_blank"}}});
                metaFields.push({"name":"Id","label":"Primary Member Name","sort":"false","type":"component","component":{"name":"c:CreatePrimaryMember","attributes":{"primaryMember":"{{Primary_Member__c}}","click":component.getReference("c.createNewPrimaryMember"),"primaryMemberName":"{{Primary_Member__r.Name}}","selectedAccount":"{{Id}}"}}});
                metaFields.push({"name":"Id","label":"Primary Member Email","sort":"false","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Primary_Member__r.Email}}","value":"/{{Primary_Member__c}}"}}});
                metaFields.push({"name":"Parent.Name","label":"Parent Account","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Parent_Account__r.Name}}","value":"/{{Parent_Account__c}}","target":"_blank"}}});
                metaFields.push({"name":"Parent_Account__r.Account_Type__c","label":"Parent Account Type"});
                metaFields.push({"name":"ID_Status__c","label":"Billing Account Status"});
                component.set("v.metaFields",metaFields); 
                component.set("v.records",response.lstBillAccounts);
                component.set("v.ultimateParentOrg",response.ultimateParentOrg);
                component.set("v.ultimateParentOrgId",response.ultimateParentOrgId);
                component.set("v.ParentOrgData",response.accountInfo); 
            }else {
                component.set("v.ParentOrgData",response.accountInfo); 
               component.find("utils").showError('Parent Account cannot have bill or blank account type.'); 
            }
        },function(error) {
            helper.showError(component, error);
        } , component);
    },
    createNewAndSend: function (component, event, helper) {
        component.find("utils").showProcessing();
        var entity = component.get("v.newEntity");
        if(entity.Email != undefined || entity.Email == "") {
            var result =  helper.ValidateEmail(component, event, helper);
            if(result) {
                if(entity.Email) {
                    var createContact = false;
                    component.find("utils").execute("c.getQueryData",{"query":"SELECT Id, Name, UUID__c, Email, Billing_Account__c, Billing_Account__r.UUID__c, AccountId, Account.RecordTypeId FROM Contact WHERE Email='"+ component.find("utils").addSlashes(entity.Email) +"'"},function(objContact) {
                        if(objContact && objContact.length > 0 ) {
                            helper.checkPrimaryMember(component,objContact[0],function(result) {
                                if(result) {
                                    if(objContact && objContact.length > 0) {   
                                        helper.getBillingAccountUUID(component,objContact[0].UUID__c,true,function(response) {
                                            entity.accountUUID = response.account_uuid;
                                            entity.primaryMemberUUID = response.user_uuid;
                                            entity.contactId = objContact[0].Id;
                                            entity.parentId = component.get("v.parentId") ? component.get("v.parentId") : null;
                                            if(objContact[0].AccountId == undefined || objContact[0].AccountId == "") {
                                                entity.contactAccountId = component.get("v.parentId") ? component.get("v.parentId") : null;
                                            }
                                            entity.billingAccount = objContact[0].Billing_Account__c ? objContact[0].Billing_Account__c : null;
                                            component.find("utils").execute("c.insertNewAccountForSendPaperwork",{"mapNewObject":entity},function(response) {
                                                if(response) {
                                                    helper.updateParentAccountOnOpportunity(component,response.Id,function() {
                                                        component.find("utils").hideProcessing();
                                                        component.set("v.billingAccountUUID",response.UUID__c);
                                                    },function(error) {
                                                        helper.showError(component, error);
                                                    })
                                                }
                                            },function(error) {
                                                helper.showError(component, error);
                                            } , component);
                                        },function(error) {
                                            helper.showError(component, error);
                                        });
                                    }else {
                                        helper.updateParentAccountOnOpportunity(component,objContact[0].AccountId,function() {
                                            component.find("utils").hideProcessing();
                                            component.set("v.billingAccountUUID",objContact[0].Account.UUID__c);
                                        },function(error) {
                                            helper.showError(component, error);
                                        })
                                    }
                                }
                                
                            });
                        }else {
                            //email is not present in system.
                            helper.getBillingAccountUUID(component,null,false,function(response) {    
                                entity.accountUUID = response.account_uuid;
                                entity.primaryMemberUUID = response.user_uuid;
                                entity.contactId = null;
                                entity.parentId = component.get("v.parentId") ? component.get("v.parentId") : null;
                                component.find("utils").execute("c.insertNewAccountForSendPaperwork",{"mapNewObject":entity},function(response) {
                                    if(response) {
                                        helper.updateParentAccountOnOpportunity(component,response.Id,function() {
                                            component.find("utils").hideProcessing();
                                            component.set("v.billingAccountUUID",response.UUID__c);
                                        },function(error) {
                                            helper.showError(component, error);
                                        })
                                    }
                                },function(error) {
                                    helper.showError(component, error);
                                } , component); 
                            },function(error) {
                                helper.showError(component, error);
                            });
                        }
                    },function(error) {
                        helper.showError(component, error);
                    });
                }else {
                    component.find("utils").hideProcessing();
                    // component.find("utils").showError(error);
                }
            }else {
                helper.showError(component, 'Invalid Email.');
            }
        }else{
            helper.showError(component, 'Invalid Email.');
        }
    },
    changeName: function(component, event, helper) {
        var ultimateOrg = component.get("v.ultimateParentOrg");
        var Name = ultimateOrg.Name+" "+(ultimateOrg.hasOwnProperty('RecordType') && ultimateOrg.RecordType && ultimateOrg.RecordType.Name ? ultimateOrg.RecordType.Name : ''  )+" "+(ultimateOrg.hasOwnProperty('Number_of_Full_Time_Employees__c') && ultimateOrg.Number_of_Full_Time_Employees__c ?"Full Time Employee"+ ultimateOrg.Number_of_Full_Time_Employees__c:'')+" "+(ultimateOrg.hasOwnProperty('Opportunities__r') && ultimateOrg.Opportunities__r ?"Close Won Opportunities"+ ultimateOrg.Opportunities__r.length:'')
        component.set("v.billingAccountName",Name.trim())
    },
    sendSelected: function(component, event, helper) {
        component.find("utils").showProcessing();
        var records = component.get("v.records");
        if(records) {
            
        }
        for(var r in records) {
            if(records[r] && records[r].UUID__c && records[r].UUID__c==component.get("v.selectedRecord")) {
                if(records[r].Primary_Member__c && records[r].Primary_Member__c.Account == undefined) {
                    helper.updateAccountOnContact(component,records[r].Primary_Member__c,helper);
                } 
                helper.updateParentAccountOnOpportunity(component,records[r].Id,function() {
                    component.find("utils").hideProcessing();
                    component.set("v.billingAccountUUID",component.get("v.selectedRecord"));
                },function(error) {
                    helper.showError(component, error);
                })
            }
        }
    },
    openAddAccountModule: function(component, event, helper) {
        var entity = {};
        entity.recordId = component.get("v.recordId");
        entity.parentId = component.get("v.parentId");
        entity.AccountOwnerId = component.get("v.AccountOwnerId");
        component.set("v.newEntity",entity);
        component.set("v.showAddAccountModal","true");
    },
    showConfirm: function(component, event, helper) {
        component.set("v.newEntity.Email","");
        component.set("v.newEntity.ContactName","");
        component.set("v.newEntity.ParentAccountName","");
        component.set("v.newEntity.AccountName","");
        component.set("v.newEntity.Phone","");
        component.set("v.showAddAccountModal",false);
    },
    closeModal: function(component, event, helper) {
        component.find("utils").closeTab();
        //component.find("utils").redirectToUrl("/"+component.get("v.recordId"));
    },
    createNewPrimaryMember: function(component, event, helper) {   
        if(event && event.currentTarget && event.currentTarget.dataset && event.currentTarget.dataset.value) {
            var selectedAccount = JSON.parse(event.currentTarget.dataset.value);
            console.log('selectedAccount==>',selectedAccount); 
            component.set("v.selectedAccount",selectedAccount);
            component.set("v.showCreatePrimaryMemberModal",true);
        }                
    },
    checkPrimaryMember: function(component, event, helper, onSuccess) {
        component.find("utils").showProcessing();
        if(component.get('v.contactId')) {
            var query ="SELECT Id, Name, Email, AccountId FROM Contact WHERE Id = '"+component.get('v.contactId')+"'"; 
            component.find("utils").execute("c.getQueryData",{"query":query},function(response) {
                component.find("utils").hideProcessing();
                helper.checkPrimaryMember(component,response[0],function(result) {
                    if(result) {
                    	component.set("v.newPrimaryContact",{'sobjectType':'Contact','Name':null,'Email':null,'LeadSource':null});    
                    }else {
                        component.set("v.contactId","");
                    }
                    
                });
            }, function(error) {
                helper.showError(component, error);
            });
        }else {
            component.find("utils").hideProcessing();
        }
    },
    checkPrimaryMemberExist: function(component, event, helper) {
        var selectedAccount =  component.get("v.selectedAccount");
        if(!selectedAccount.hasOwnProperty('Primary_Member__c')) {
            component.find("utils").showError("Create Primary Member first.");
        }
    },
    createPrimaryContact: function(component, event, helper) {  
        var selectedAccount =  component.get("v.selectedAccount");
        var updateAccount = {"sobjectType":"Billing_Account__c","Id":selectedAccount.Id};
        var contactId = component.get("v.contactId");
        var newPrimaryMember = component.get("v.newPrimaryContact");
        if(contactId != undefined && contactId != "") {
            component.find("utils").showProcessing();
            var closePrimaryMemberModal = component.get('c.closePrimaryMemberModal');
            $A.enqueueAction(closePrimaryMemberModal);
            updateAccount["Primary_Member__c"] = contactId;
            component.find("utils").execute("c.saveRecord",{"record": updateAccount},function(response) {
                if(response && (JSON.parse(response).success)) {
                    var doInit = component.get('c.doInit');
                    $A.enqueueAction(doInit);
                }else {
                    component.find("utils").showError("Something went wrong, please contact your system administrator.");
                }
                component.find("utils").hideProcessing();
            },function(error) {
                helper.showError(component, error.search("EXCEPTION,") > 0 ? error.split("EXCEPTION,")[1] : error);
            });
        }else if(newPrimaryMember.Email != undefined && newPrimaryMember.LastName != undefined ) {
            if(component.get("v.parentId") != undefined && component.get("v.parentId") != "") {
                newPrimaryMember["AccountId"] = component.get("v.parentId");
            }
            if(selectedAccount != undefined && selectedAccount.hasOwnProperty('Id') && selectedAccount.Id != null) {
                newPrimaryMember["Billing_Account__c"] = selectedAccount.Id;
            }
            component.find("utils").execute("c.saveRecord",{"record": newPrimaryMember},function(response) {
                if(response && (JSON.parse(response).success)) {
                    component.find("utils").showSuccess("New Contact created successfully.");
                    var closePrimaryMemberModal = component.get('c.closePrimaryMemberModal');
                    $A.enqueueAction(closePrimaryMemberModal);
                    component.find("utils").showProcessing();
                    updateAccount["Primary_Member__c"] = JSON.parse(response).id;
                    component.find("utils").execute("c.saveRecord",{"record": updateAccount},function(response) {
                        if(response && (JSON.parse(response).success)) {
                            var doInit = component.get('c.doInit');
                            $A.enqueueAction(doInit);
                        }else {
                            component.find("utils").showError("Something went wrong, please contact your system administrator.");
                        }
                        component.find("utils").hideProcessing();
                    },function(error) {
                        helper.showError(component, error.search("EXCEPTION,") > 0 ? error.split("EXCEPTION,")[1] : error);
                    });
                }else {
                    component.find("utils").showError("Something went wrong, please contact your system administrator.");
                }
            },function(error) {
                helper.showError(component, error.search("EXCEPTION,") > 0 ? error.split("EXCEPTION,")[1] : error);
            });
        }
    },
    closePrimaryMemberModal: function(component, event, helper) {
        component.set("v.contactId","");
        component.set("v.newPrimaryContact.FirstName","");
        component.set("v.newPrimaryContact.LastName","");
        component.set("v.newPrimaryContact.Email","");
        component.set("v.newPrimaryContact.LeadSource","");
        component.set("v.showCreatePrimaryMemberModal",false);
    },
    fetchLinkData: function(component ,event, helper) {
        component.set("v.newEntity.Email","");
        component.set("v.newEntity.ContactName","");
        component.set("v.newEntity.ParentAccountName","");
        component.set("v.newEntity.AccountName","");
        component.set("v.newEntity.Phone","");
        component.find("utils").showProcessing();  
        if(component.get("v.recordId")) {
            if(event.currentTarget.value == 'OppMainContact') {
                var query ="SELECT Id, AccountId, Primary_Member_Email_New__c FROM Opportunity WHERE Id = '"+component.get('v.recordId')+"'"; 
                component.find("utils").execute("c.getQueryData",{"query":query},function(response) {
                    if(response && response.length > 0) {
                        if(response[0].Primary_Member_Email_New__c && response[0].Primary_Member_Email_New__c != null) {
                            var query ="SELECT Id, Email, Phone, Name, AccountId, Account.Parent_Org_Name__c, Billing_Account__c, Billing_Account__r.Name, Billing_Account__r.Primary_Member__c From Contact Where Email = '"+ component.find("utils").addSlashes(response[0].Primary_Member_Email_New__c) +"'";
                            component.find("utils").execute("c.getQueryData",{"query":query},function(response) {
                                component.find("utils").hideProcessing();
                                if(response && response.length > 0) {
                                    component.set("v.newEntity.Email",response[0].Email);
                                    component.set("v.newEntity.ContactName",response[0].Name);
                                    component.set("v.newEntity.ParentAccountName",(response[0].AccountId ? response[0].Account.Parent_Org_Name__c : null));
                                    if(response[0].Id== (response[0].Billing_Account__c ? response[0].Billing_Account__r.Primary_Member__c : null)) {
                                    component.set("v.newEntity.AccountName",(response[0].Billing_Account__c ? response[0].Billing_Account__r.Name : null));    
                                    }
                                    component.set("v.newEntity.Phone",response[0].Phone ? response[0].Phone : "");
                                    if(component.get("v.newEntity.ContactName")) {
                                        component.set("v.editData.ContactName",true);
                                    }
                                    if(component.get("v.newEntity.Phone")) {
                                        component.set("v.editData.Phone",true);
                                    }else {
                                        component.set("v.editData.Phone",false);
                                    }
                                }else {
                                    helper.showError(component, error);
                                }
                            },function(error) {
                                helper.showError(component, error);
                            }); 
                        }else {
                            helper.showError(component, "Opportunity missing the main contact. Please contact your support.");
                        }
                    }
                }, function(error) {
                    helper.showError(component, error);
                });
            }
        }else {
            helper.showError(component, error);
        }
    },
    selectEntity: function(component, event, helper) {
        var id = event.currentTarget.id;
        component.find("utils").showProcessing();
        var query ="SELECT Id, Email, Phone, Name, AccountId, Account.Parent_Org_Name__c, Billing_Account__c, Billing_Account__r.Name, Billing_Account__r.Primary_Member__c From Contact WHERE Id = '"+event.currentTarget.id+"'"; 
        component.find("utils").execute("c.getQueryData",{"query":query},function(response) {
            component.find("utils").hideProcessing();
            if(response && response.length > 0) {
                component.set("v.newEntity.Email",response[0].Email);
                component.set("v.newEntity.ContactName",response[0].Name);
                component.set("v.newEntity.ParentAccountName",(response[0].AccountId ? response[0].Account.Parent_Org_Name__c : null));
                if(response[0].Id== (response[0].Billing_Account__c ? response[0].Billing_Account__r.Primary_Member__c : null)) {
                component.set("v.newEntity.AccountName",(response[0].Billing_Account__c ? response[0].Billing_Account__r.Name : null));
                }
                component.set("v.newEntity.Phone",response[0].Phone);
                if(component.get("v.newEntity.ContactName")) {
                    component.set("v.editData.ContactName",true);
                }
                if(component.get("v.newEntity.Phone")) {
                    component.set("v.editData.Phone",true);
                }
            }else {
                helper.showError(component, error);
            }
        }, function(error) {
            helper.showError(component, error);
        });        
    },
    searchContacts: function(component, event, helper) {
        component.set("v.keyword",event.currentTarget.value);
        var keyword = event.currentTarget.value;
        component.set("v.newEntity.Email",keyword);
        if(keyword.length==0) {

            component.set("v.createOpportunityLink",false);
            component.set("v.newEntity.ContactName","");
            component.set("v.newEntity.ParentAccountName","");
            component.set("v.newEntity.AccountName","");
            component.set("v.newEntity.Phone","");
            component.set("v.editData",false);
        }
        else if(event.currentTarget.value && event.currentTarget.value.length>2) {
            component.find("utils").execute("c.getListQueryDataBySOSL",{"arrQuery":["FIND  '"+ component.find("utils").addSlashes(component.get("v.keyword")) + "*' IN ALL FIELDS RETURNING Contact(Id,Name,Email,Account.Name,Account.Id,Account.Primary_Member__c,Account.Parent_Org_Name__c,Billing_Account__c) LIMIT 10"]},function(response) {     
                var data = [];
                for(var o in response) {
                    for(var d in response[o]) {
                        response[o][d]["type"] = "contact";
                        data.push(response[o][d]);
                    }
                }                
                if(data && data.length) {
                    component.set("v.searchData",data);
                }else {
                    component.set("v.searchData",[]);
                    component.set("v.newEntity.ContactName","");
                    component.set("v.newEntity.ParentAccountName","");
                    component.set("v.newEntity.AccountName","");
                    component.set("v.newEntity.Phone","");
                    component.set("v.editData.ContactName",false);
                    component.set("v.editData.Phone",false);
                }
                var a=document.getElementById("listbox-unique-id");        
                $A.util.removeClass(a, "slds-hide");
            },function(error) {
                component.find("utils").showError(error);
            });
        }
    }
})