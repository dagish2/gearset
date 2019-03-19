({
    doInit : function(component, event, helper){
        component.set("v.utils", component.find("utils"));
    },
	saveBillAcc : function(component, event, helper) {
        var params = event.getParam('arguments');
        var contact = params.contact;
        var billingAccount = params.billingAccount;
        var onsuccess = params.onsuccess;
        if(contact && billingAccount){
            component.get("v.utils").showProcessing();
            contact["Name"] = ((contact["FirstName"] != undefined && contact["FirstName"] != "") ? contact["FirstName"] + " " : "") + contact["LastName"];
            if(!contact.Id){
                contact["LeadSource"] = "Referral";
                contact["Lead_Source_Detail__c"] = "Retroactive Referral Form";
                contact["OwnerId"] = component.get("v.APIUser");
                contact["RecordTypeId"] = component.get("v.ContactRecordType");
            }
            contact["sobjectType"] = "Contact";
            billingAccount["Name"] = billingAccount["BillAccName"];
            billingAccount["sobjectType"] = "Billing_Account__c";
            billingAccount["OwnerId"] = component.get("v.APIUser");
            billingAccount["Lead_Source__c"] = "Referral";
            delete billingAccount["Id"];
            var records = [];
            records.push(contact);
            records.push(billingAccount);
            var apiSetting = component.get("v.apiSetting");
            if(apiSetting){
                var payload = {
                    "account_name": billingAccount.BillAccName,
                    "primary_member": {
                        "name": contact.Name,
                        "email": contact.Email,
                        "phone": contact.Phone
                    }
                };
                if(contact.UUID__c != undefined) {
                    payload["primary_member"]["uuid"] = contact.UUID__c; 
                }        
                component.get("v.utils").execute("c.executeRestQuery",{"setUrl": !(apiSetting.url.includes("https:") || apiSetting.url.includes("http:")), "method": "POST", "endPointUrl": apiSetting.url, "headers": apiSetting.headers, "body": JSON.stringify(payload)},function(billingAccResponse) {
                    if(billingAccResponse != undefined ) {
			billingAccResponse = JSON.parse(billingAccResponse);
                        records.forEach(function(record){
                            if(record["sobjectType"] && record["sobjectType"] == "Billing_Account__c"){
                                record["UUID__c"] = billingAccResponse["account_uuid"];
                            }else if(record["sobjectType"] && record["sobjectType"] == "Contact"){
                                (record["UUID__c"] != billingAccResponse["user_uuid"]) ? record["UUID__c"] = billingAccResponse["user_uuid"]: delete record["UUID__c"];
                            }  
                        });
                        component.get("v.utils").execute("c.saveConAccRecords", {"lstRecords": records}, function(response){
                            if(response && response.billAcc){
                                onsuccess(response.billAcc);
                            }
                            component.get("v.utils").hideProcessing();
                        },function(error){
                            component.get("v.utils").hideProcessing();
                            component.get("v.utils").showError(error);
                        },component);
                    }else{
                        component.get("v.utils").hideProcessing();
                        component.get("v.utils").showError("Unable to connect spacestation");
                    } 
                },function(error) {
                    component.get("v.utils").hideProcessing();
                    component.get("v.utils").showError(error); 
                });
            }else{
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError("Unable to Api Setting");
            }  
        }
    },
    saveReferrer : function(component, event, helper){
        var params = event.getParam('arguments');
        var contact = params.contact;
        var onsuccess = params.onsuccess;
        if(contact){
            component.get("v.utils").showProcessing();
            var records = [];
            contact["Name"] = ((contact["FirstName"] != undefined && contact["FirstName"] != "") ? contact["FirstName"] + " " : "") + contact["LastName"];
            contact["sobjectType"] = "Contact";
            contact["LeadSource"] = "Referral";
            contact["Lead_Source_Detail__c"] = "Retroactive Referral Form";
            contact["OwnerId"] = component.get("v.APIUser");
            records.push(contact);
            component.find("utils").execute("c.saveConAccRecords", {"lstRecords": records}, function(response){
                component.get("v.utils").hideProcessing();
                if(response && response.contact){
                    onsuccess(response.contact)
                }
            },function(error){
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError(error);
            },component);
        }
    },
    saveOpportunity : function(component, event, helpercomponent, helper, referrer, billAccId, parentAccId, oppReferralType){
        component.get("v.utils").showProcessing();
        var params = event.getParam('arguments');
        var recordId = params.recordId;
        var referrer = params.referrer;
        var billAccId = params.billAccId;
        var parentAccId = params.parentAccId;
        var oppReferralType = params.oppReferralType;
        var onsuccess = params.onsuccess;
        referrer["sobjectType"] = "Contact";
        delete referrer["attributes"];
        component.get("v.utils").execute("c.updateReferrerOnOpportunity", {"opportunityId": recordId, "referrer": referrer, "billAccId": billAccId, "parentAccId": parentAccId, "oppReferralType" : oppReferralType}, function(response){
            if(response){
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showSuccess('Referrer updated on opportunity Successfully');
                setTimeout(function(){
                    onsuccess(response);
                }, 1500);
            }else if(response && !response.success){
                component.get("v.utils").showError(result.message ? result.message : 'Referrer not updated on opportunity');
            }
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        },component);
    }
})