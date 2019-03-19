({
    doInit : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.set("v.referralObj",{});
        component.set("v.refObj",{}); 
        component.set("v.accountObj",{});
        component.set("v.opportunityData",{});
        
        component.find("utils").execute("c.initialize",{"opportunityId":component.get("v.recordId")}, function(response){
            component.find("utils").hideProcessing();
            if(response){
                var referralSetting = JSON.parse(response);
                if(referralSetting && referralSetting.Setting){
                    component.set("v.referralType",JSON.parse(referralSetting['Setting'].Data__c).RetroactiveReferralType);
                    component.set("v.referrType",JSON.parse(referralSetting['Setting'].Data__c).RetroactiveReferrType);
                    component.set("v.ContactRecordType",JSON.parse(referralSetting['Setting'].Data__c).ContactRecordType);
                    component.set("v.AccountRecordType",JSON.parse(referralSetting['Setting'].Data__c).AccountRecordType);
                    component.set("v.APIUser",JSON.parse(referralSetting['Setting'].Data__c).APIUser);
                    component.set("v.settingData",JSON.parse(referralSetting['Setting'].Data__c));
                    if(referralSetting.OpportunityData ){
                        component.set("v.opportunityData",JSON.parse(JSON.stringify(referralSetting.OpportunityData)));
                        if(referralSetting.OpportunityData.Referrer__r){
                            component.set("v.referralObj",referralSetting.OpportunityData.Referrer__r);
                            component.set("v.refObj",referralSetting.OpportunityData.Referrer__r);
                        }
                    }
                }
            }
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        },component);
    },
    changeForm : function(component, event, helper) {
        if(component.get("v.referralTypeVal") == 'Retroactive Referral'){
            component.set("v.hide",false);
            component.set("v.referral",true);
            component.set("v.confidential",false);
        }
        else if(component.get("v.referralTypeVal") == 'Confidential Referral'){
            component.set("v.hide",false);
            component.set("v.referral",false);
            component.set("v.confidential",true);
        }
            else{
                component.set("v.hide",true);
                component.set("v.referral",false);
                component.set("v.confidential",false);        
            }
    },
    getAllReferralContacts : function(component, event, helper) {
        if(component.get("v.referralObj.Id") !='' && component.get("v.referralObj.Id")){
            helper.getContactInfo(component, helper, function(){
                component.find("utils").hideProcessing();
            });
        }else{
            component.set("v.referralObj",{"Id":null,"Email":null,"Phone":null,"Type__c":null});
        }
    },
    getAccounts : function(component, event, helper) {
        if(component.get("v.accountObj.Id") !='' && component.get("v.accountObj.Id")){
            helper.getAccountsInfo(component, helper, function(){   
                component.find("utils").hideProcessing();
            });
        }else{
            component.set("v.accountObj",{"Id":null});
        }
    },
    getReferrals : function(component, event, helper) {
        if(component.get("v.refObj.Id") !='' && component.get("v.refObj.Id")){
            helper.getReferralsInfo(component, helper, function(){
                component.find("utils").hideProcessing();
            });
        }else{
            component.set("v.refObj",{"Id":null});
        }
    },
    referralSave : function(component, event, helper) {
        component.find("utils").showProcessing();
        var referral = component.get("v.referralObj");
        console.log('referral::'+referral);
        helper.updateReferralSAPI(component, event, helper,referral,null,function(response){
            component.find("utils").hideProcessing();
            response = JSON.parse(response);
            if(response){
                if(response.hasOwnProperty('error')){
                    if(response.hasOwnProperty('error') && response.hasOwnProperty('message'))
                      component.find("utils").showError(response.message);
                    else
                       component.find("utils").showError(response.error);
                }else{
                    component.find("utils").execute("c.updateOpp",{"opportunityId":component.get("v.recordId"),"referrerId":component.get("v.referralObj.Id"),"accId":null,"referrerType":referral.Type__c,"ParentAccount":component.get("v.accountObj.Parent_Account__c")}, function(response){
                        var result = JSON.parse(response);
                        if(result && result.Referrer__c){
                            component.find("utils").showSuccess('Retroactive Referral Created Successfully');
                            setTimeout(function(){
                                helper.closeWindow(component,event,helper);
                            }, 1500);
                        }
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    },component);
                }
            }
        })
    },
 	referralClose : function(component, event, helper) {
    	helper.closeWindow(component,event,helper);
    },
    confidentialSave : function(component, event, helper) {
        component.find("utils").showProcessing();
        var referral = component.get("v.refObj");
        var account = component.get("v.accountObj");
        helper.updateReferralSAPI(component, event, helper,referral, account,function(response){
            component.find("utils").hideProcessing();
            response = JSON.parse(response);
            if(response){
                if(response.hasOwnProperty('error')){
                    if(response.hasOwnProperty('error') && response.hasOwnProperty('message'))
                      component.find("utils").showError(response.message);
                    else
                       component.find("utils").showError(response.error);
                }else{
                    component.find("utils").execute("c.updateOpp",{"opportunityId":component.get("v.recordId"),"referrerId":component.get("v.refObj.Id"),"accId":component.get("v.accountObj.Id"),"referrerType":referral.Type__c,"ParentAccount":component.get("v.accountObj.Parent_Account__c")}, function(response){           
                        var result = JSON.parse(response);
                        if(result){
                            component.find("utils").showSuccess('Confidential Referral Created Successfully');
                            setTimeout(function(){
                                helper.closeWindow(component,event,helper);
                            }, 1500);
                        }
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    },component);
                }
            }
        })
    },
    confidentialClose : function(component, event, helper) {
        helper.closeWindow(component,event,helper);
    },
    createContactReferral : function(component){  
        component.set("v.contact", {});
        component.find("NewContactModal").showModal();
    },
    createNewAccount : function(component){
        component.set("v.primaryContact", {});
        component.find("NewAccountModal").showModal();
    },
    saveContact : function(component, event, helper) {
        component.find("utils").showProcessing();
        var contact = JSON.parse(JSON.stringify(component.get("v.contact")));
        var billingAccount = JSON.parse(JSON.stringify(component.get("v.contact")));
        contact["Name"] = ((contact["FirstName"]!=undefined && contact["FirstName"]!="")? contact["FirstName"]+" " : "")+contact["LastName"];
        contact["sobjectType"] = "Contact";
        contact["Type__c"] = component.get("v.contact.referrType");
        contact["LeadSource"] = "Referral";
        contact["Lead_Source_Detail__c"] = "Retroactive Referral Form";
        contact["Company__c"]=component.get("v.contact.CompanyName");
        contact["Phone"]=component.get("v.contact.Phone");
        //contact["RecordTypeId"] = component.get("v.ContactRecordType");
        contact["OwnerId"] = component.get("v.APIUser");
        billingAccount["Name"] = ((billingAccount["FirstName"]!=undefined && billingAccount["FirstName"]!="")? billingAccount["FirstName"]+" " : "")+billingAccount["LastName"];
        billingAccount["OwnerId"] = component.get("v.APIUser");
        billingAccount["sobjectType"] ="Billing_Account__c";
        billingAccount["Lead_Source__c"] = "Referral";
        //account["RecordTypeId"] = component.get("v.AccountRecordType");
        console.log(contact);
        var records = [];
        console.log(billingAccount);
        var accountRecords = [];
        records.push(contact);
        records.push(billingAccount);
        component.find("utils").execute("c.saveConAccRecords", {"records": records,"createReferral":false}, function(response){
            response = JSON.parse(response);
            if(response.insrtedRecords[0].success){
                if(component.get("v.referral")){
                    component.set("v.referralObj.Id",response.insrtedRecords[0].id);
                    helper.getContactInfo(component, helper,function(){
                        component.set("v.contact", {"FirstName":null,"LastName":null,"Email":null,"referrType":null,"Phone":null,"CompanyName":null});
                        component.find("utils").showSuccess('Referrer succesfully created!!');
                    });
                }else if(component.get("v.confidential")){
                    component.set("v.refObj.Id",response.insrtedRecords[0].id);
                    helper.getContactInfoForconfidential(component, helper,function(){
                        component.set("v.contact", {"FirstName":null,"LastName":null,"Email":null,"referrType":null,"Phone":null,"CompanyName":null});
                        component.find("utils").showSuccess('Referrer succesfully created!!');
                    });
                }      
            }
            component.find("NewContactModal").close();
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        },component);
    },
    saveAccount : function(component, event, helper) {
        component.find("utils").showProcessing();
        var contact = JSON.parse(JSON.stringify(component.get("v.primaryContact")));
        var billingAccount = JSON.parse(JSON.stringify(component.get("v.primaryContact")));
        contact["Name"] = ((contact["FirstName"]!=undefined && contact["FirstName"]!="")? contact["FirstName"]+" " : "")+contact["LastName"];
        contact["sobjectType"] = "Contact";
        contact["LeadSource"] = "Referral";
        contact["Lead_Source_Detail__c"] = "Retroactive Referral Form";
        contact["OwnerId"] = component.get("v.APIUser");
        contact["RecordTypeId"] = component.get("v.ContactRecordType");
        contact["Company__c"]=component.get("v.primaryContact.Name");
        contact["Phone"]=component.get("v.primaryContact.Phone");
        billingAccount["Name"] = billingAccount["Name"];
        billingAccount["sobjectType"] ="Billing_Account__c";
        billingAccount["OwnerId"] = component.get("v.APIUser");
        billingAccount["Lead_Source__c"] = "Referral";
        console.log(contact);
        var records = [];
        console.log(billingAccount);
        var accountRecords = [];
        records.push(contact);
        records.push(billingAccount);
        component.find("utils").execute("c.saveConAccRecords", {"records": records,"createReferral":false}, function(response){
           response = JSON.parse(response);
            if(response.insrtedRecords[0].success){  
                //component.set("v.refObj.Id",response.insrtedRecords[0].id);
                if(response.insrtedRecords[1].success){
                    component.set("v.accountObj.Id",response.insrtedRecords[1].id);
                    helper.getAccountsInfo(component, helper, function(){ 
                        component.find("utils").showSuccess('Account succesfully created!!');
                        component.set("v.primaryContact", {
                            "Name": null,
                            "FirstName": null,
                            "LastName" : null,
                            "Email" : null,
                            "Phone" : null
                        });
                    });
                }
            }
            component.find("NewAccountModal").close();
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        },component);          
    },
    closeNewContactModal : function(component,event,helper){
        component.set("v.contact", {"FirstName":null,"LastName":null,"Email":null,"referrType":null,"Phone":null,"CompanyName":null});
        component.find("NewContactModal").close();
    },
    closeNewAccountModal : function(component,event,helper){
        component.set("v.primaryContact", {"Name": null,"FirstName": null,"LastName" : null,"Email" : null, "Phone" : null });
        component.find("NewAccountModal").close();
    }
})