({
    checkContactEmail : function(email, existingEmail, onsuccess) {
        if((existingEmail == undefined || (email && existingEmail && existingEmail.toLocaleLowerCase() != email.toLocaleLowerCase())) && email != undefined && email.lastIndexOf("@") < email.lastIndexOf(".") && (email.lastIndexOf(".") - email.lastIndexOf("@")) > 1 && (email.length - email.lastIndexOf(".")) > 1){
            onsuccess(true);
        }else if(existingEmail != undefined && email != existingEmail){
            onsuccess(false);
        }
    },
    searchRecord : function(component, id, email, isReferrer, onsuccess, returnResponse) {
        component.get("v.utils").execute("c.searchRecord", {"recordId": id, "email": email, "isReferrer": isReferrer}, function(response){
            component.get("v.utils").hideProcessing();
            if(returnResponse){
                onsuccess(response && response.length ? response[0] : null);                
            }else if(response && response.length){
                onsuccess(response[0]);
            }
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        }, component);
    },
    checkContact : function(component, helper, contactRec, onsuccess) {
        var contact = component.get("v.referrerServices").reset("contact", null);
        var mapDisabled = component.get("v.referrerServices").reset("contactDisabled", null);
        contactRec.FirstName != undefined ? (contact.FirstName = contactRec.FirstName, mapDisabled.FirstName = true) : '';
        contactRec.LastName != undefined ? (contact.LastName = contactRec.LastName, mapDisabled.LastName = true) : '';
        contactRec.Phone != undefined ? (contact.Phone = contactRec.Phone, mapDisabled.Phone = true) : '';
        contactRec.Type__c != undefined ? (contact.Type__c = contactRec.Type__c, mapDisabled.Type__c = true) : '';
        contactRec.Company__c != undefined ? (contact.Company__c = contactRec.Company__c, mapDisabled.Company__c = true) : '';
        contactRec.Email != undefined ?  contact.Email = contactRec.Email : '';
        contactRec.Billing_Account__c != undefined ?  contact["Billing_Account__c"] = contactRec.Billing_Account__c : '';
        contactRec.Id != undefined ? contact["Id"] = contactRec.Id : '';
        if(contactRec.Billing_Accounts__r && contactRec.Billing_Accounts__r.length){
            contactRec.Billing_Accounts__r != undefined ? (contact["BillAccId"] = contactRec.Billing_Accounts__r[0].Id, contact["BillAccName"] = contactRec.Billing_Accounts__r[0].Name, contact["Ultimate_Parent_Org__c"] = contactRec.Billing_Accounts__r[0].Ultimate_Parent_Org__c, mapDisabled["BillAccName"] = true) : '';
            component.get("v.utils").showWarning( "Contact with this email already primary member on " + contactRec.Billing_Accounts__r[0].Name + " Billing Account", false);
            mapDisabled["useBillAcc"] = true;
        }
        onsuccess(contact, mapDisabled);
    },
    searchReferrer : function(component, helper, email, existingEmail, type, isPrimaryContact) {
        helper.checkContactEmail(email, existingEmail, function(result){
            if(result){
                helper.searchRecord(component, null, email, !isPrimaryContact, function(contact){
                    if(contact){
                        helper.checkContact(component, helper, contact, function(conRec, mapDisabled){
                            if(type.toLowerCase() == "retroactive"){
                                component.set("v.existingRetroEmail", conRec.Email)
                                if(isPrimaryContact){
                                    component.set("v.primaryRetroContact", conRec);
                                    component.set("v.mapDisabledForPrimaryRetroContact", mapDisabled);
                                }else{
                                    component.set("v.retroContact", conRec);
                                    component.set("v.mapDisabledForContactInRetro", mapDisabled);
                                    component.get("v.utils").showWarning("You can not create new contact, You can use this as Referrer", false);
                                }
                            }else{
                                component.set("v.existingEmail", conRec.Email)
                                if(isPrimaryContact){
                                    component.set("v.primaryContact", conRec);
                                    component.set("v.mapDisabledForPrimaryContact", mapDisabled);
                                }else{
                                    component.set("v.contact", conRec);
                                    component.set("v.mapDisabled", mapDisabled);
                                    component.get("v.utils").showWarning("You can not create new contact, You can use this as Referrer", false);
                                }
                            }
                        });
                    }else if(existingEmail){
                        if(type.toLowerCase() == "retroactive"){
                            component.set("v.existingRetroEmail", null);
                            isPrimaryContact ? component.get("v.referrerServices").resetPrimaryRetroContact(email) : component.get("v.referrerServices").resetRetroContact(email);
                        }else{
                            component.set("v.existingEmail", null);
                            isPrimaryContact ? component.get("v.referrerServices").resetPrimaryContact(email) : component.get("v.referrerServices").resetConfidentialContact(email);
                        }
                        
                    }
                }, true);
            }else{
                if(type.toLowerCase() == "retroactive"){
                    component.set("v.existingRetroEmail", null);
                    isPrimaryContact ? component.get("v.referrerServices").resetPrimaryRetroContact(email) : component.get("v.referrerServices").resetRetroContact(email);
                }else{
                    component.set("v.existingEmail", null);
                    isPrimaryContact ? component.get("v.referrerServices").resetPrimaryContact(email) : component.get("v.referrerServices").resetConfidentialContact(email);
                }
            }
        });        
    }
})