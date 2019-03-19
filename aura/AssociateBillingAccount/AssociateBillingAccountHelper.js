({
    reset: function(component, preserveEmail) {
        component.set("v.contact", new Map());
        component.set("v.billingAccount", new Map());        
        if(preserveEmail) {
            component.set("v.contact.Email", component.get("v.email"));
        } else {
            component.set("v.contact.Email", null);
            component.set("v.email", null);
        }      
        component.set("v.contact.Name", null);
        component.set("v.billingAccount.Name", null);
        component.set("v.billingAccount.ParentAccountName", null);        
        component.set("v.allowEditContact", {
            "Name": true,
            "Phone": true
        });
        component.set("v.allowEditBillingAccount", {
            "ParentAccountName": false,
            "Name": true
        });
        component.set("v.contactRecords", []);
    },
    getContact: function(component, contactQuery, contactId, onSuccess) {
        var billAccQuery = "SELECT Id, Name, Primary_Member__c, Primary_Member__r.Name FROM Billing_Account__c WHERE Primary_Member__c = '"+contactId+"'";
        component.find("utils").execute("c.getListQueryData", {"arrQuery": [contactQuery, billAccQuery]}, function(response) {
            var objContact;
            if(response != null && response != undefined && response.length > 1) {
                var  objContact = response[0][0];
              	var billingAccounts = response[1];  
                if(billingAccounts.length > 0) {
                    component.find("utils").showError(objContact.Name + " is already a primary member on "+billingAccounts[0].Name + ". Please select another contact or contact your support team.");
                    component.set("v.allowEditContact", {
                        "Name": false,
                        "Phone": false
                    });
                    component.set("v.allowEditBillingAccount", {
                        "ParentAccountName": false,
                        "Name": false
                    });
                } 
                component.find("utils").hideProcessing();
            }
            component.set("v.email",objContact.Email);
            component.set("v.contact", objContact);
            component.set("v.allowEditContact.Phone", (objContact.Phone == undefined || objContact.Phone == null || objContact.Phone == '') ? true : false);
            component.set("v.allowEditContact.Name", objContact.Name == '' ? true : false);            
            component.set("v.billingAccount.ParentAccountName", objContact.AccountId ? objContact.Account.Parent_Org_Name__c : null);
         	onSuccess(objContact);  
        }, function(error) {  
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);            
        });   
    },
    getBillingAccounts: function(component) {
        var billAccQuery = "SELECT Id, OwnerId, ID_Status__c, Owner.Name, Parent_Account__r.Name, Parent_Account__r.Account_Type__c, Parent_Account__c, Name, Primary_Member__c, Primary_Member__r.Name, Primary_Member__r.Email, Primary_Member__r.Id, UUID__c FROM Billing_Account__c WHERE Ultimate_Parent_Org__c ='" + component.get("v.ultimateParentOrgId") + "'";
        component.find("utils").execute("c.getQueryData", {"query": billAccQuery}, function(billingAccounts){
            component.set("v.billingAccounts", billingAccounts);
            component.set("v.showAddNewBillingAccountModal", false);            
        }, function(error) {
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);            
        });
    }, 
    createBillingAccount: function(component, helper, contact, onsuccess) {
        var apiSetting = component.get("v.apiSetting");
        var billingAccount = component.get("v.billingAccount"); 
        var payload = {
            "account_name": billingAccount.Name,
            "primary_member": {
                "name": contact.Name,
                "email": contact.Email,
                "phone": contact.Phone
            }
        };
        if(contact.UUID__c != undefined) {
            payload["primary_member"]["uuid"] = contact.UUID__c; 
        }        
        component.find("utils").execute("c.executeRestQuery",{"setUrl": !(apiSetting.url.includes("https:") || apiSetting.url.includes("http:")), "method": "POST", "endPointUrl": apiSetting.url, "headers": apiSetting.headers, "body": JSON.stringify(payload)},function(billingAccResponse) {
            if(billingAccResponse != undefined ) {  
                var billingAccResponse = JSON.parse(billingAccResponse);
                if(!billingAccResponse.hasOwnProperty("error")) {
                     onsuccess(billingAccResponse);
                }else {
                    component.find("utils").hideProcessing();
                    component.find("utils").showError("Something went wrong, please contact your system administrator.");
                }
               
            } else {
                component.find("utils").hideProcessing();
                component.find("utils").showError("Unable to connect spacestation");
            } 
        },function(error) {
            component.find("utils").hideProcessing();
            component.find("utils").showError(error); 
        });        
    },
    updateAccountOnOpportunity: function(component, helper, billingAccountId, onsuccess) {
        component.find("utils").execute("c.saveRecord",{"record": {"Id": component.get("v.opportunityId"), "Billing_Account__c": billingAccountId}},function(response) {
            onsuccess(); 
        }, function(error) {
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);    
        });
    },
    checkValidForSendPaperWork: function(component, helper, onsuccess) {
        component.find("utils").execute("c.isValidOppforSendPaperwork",{"oppId": component.get("v.opportunityId")},function(isValidResponse) {
            isValidResponse = JSON.parse(isValidResponse);
            if(isValidResponse.isValid) {
                onsuccess(isValidResponse.isValid);
            }else {
                component.find("utils").hideProcessing();
                component.find("utils").showError(isValidResponse.errorMsg); 
            }
        },function(error) {
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        }, component);
    },
    spacestationRedirection: function(component, helper, billingAccUUID) { 
        var opportunityRecord = component.get("v.opportunityRecord");
        var query = "Select Data__c From Setting__c Where Name='SendPaperworkSetting'";
        component.find("utils").execute("c.getQueryData",{"query": query},function(settingResponse) {
            var sendPaperWorkSetting = JSON.parse(settingResponse[0].Data__c);
            var url =  sendPaperWorkSetting.URL;
            url= url.replace('Opportunity.Billing_Account__r.UUID__c', billingAccUUID);
            url= url.replace('Opportunity.Encoded_ID__c', opportunityRecord.Encoded_ID__c);
            url= url.replace('Opportunity.Building_uuid__c', opportunityRecord.Building_uuid__c);
            url= url.replace('Opportunity.Actual_Start_Date__c', ((opportunityRecord.Actual_Start_Date__c != undefined) ? opportunityRecord.Actual_Start_Date__c : ""));                    
            helper.redirectToSS(component, url);
            window.setTimeout(
                $A.getCallback(function() {
                    if (component.isValid()) {
                        helper.openSFRecord(component, component.get("v.opportunityId"));
                    }}),
                6000);
        },function(error) {
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    saveBillingAccount: function(component, helper, contact, onsuccess) {
        query = "SELECT ID, Email, Phone, Name, AccountId, Account.Parent_Org_Name__c, Billing_Account__c, Billing_Account__r.Name From Contact WHERE Email = '"+ component.find("utils").addSlashes(contact.Email) +"'";
        component.find("utils").execute("c.getQueryData",{"query": query},function(objContacts) {
            var objContact = (objContacts != undefined && objContacts.length > 0) ? objContacts[0] : contact;
            helper.createBillingAccount(component, helper, objContact, function(billingAccount) {
                console.log(billingAccount);
                var objBillingAccount = component.get("v.billingAccount");
                var mapBillAccParams = {
                    "contactName": objContact.Name,
                    "phone": objContact.Phone,
                    "oppId": component.get("v.opportunityId"),
                    "Email": objContact.Email,
                    "billingAccountName": objBillingAccount.Name,
                    "primaryMemberUUID": billingAccount.user_uuid,
                    "parentId": component.get("v.opportunityRecord.AccountId"),
                    "billingAccountUUID": billingAccount.account_uuid
                };
                if(objContact.Id != undefined) {
                    mapBillAccParams["contactId"] = objContact.Id;
                }
                component.find("utils").execute("c.createNewBillingAccount",{"mapNewObject": mapBillAccParams},function(billingAccResponse) {
                    if(billingAccResponse != undefined) {
                        var objBillingAccount = billingAccResponse;
                        component.set("v.selectedRecord", objBillingAccount.UUID__c);
                        helper.getBillingAccounts(component);
                        onsuccess();
                    } else {
                        component.find("utils").hideProcessing();
                        component.find("utils").showError("Something went wrong, please contact your system administrator.");
                    }
                },function(error) {
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                },component);
            });
        }, function(error) {
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    openSFRecord: function(component, recordId) {
        component.find("utils").closeTab();       
        component.find("utils").redirectToUrl("/"+recordId, '', true, false);                  
    },
    redirectToSS: function(component, url) {
        window.open(url);
    },
    addSlashes: function(str){
        str = str.split("\\").join("");
        str = str.split("'").join("\\'"); 
        return str.trim();
    }
})