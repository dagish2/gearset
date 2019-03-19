({
    doInit : function(component, event, helper){
        if(component.get("v.accountRec")){
            component.set("v.accountRec", component.get("v.accountRec"));
            component.set("v.accountRec.Name", component.get("v.contactRec.Company"));
        }else{
            component.set("v.accountRec", {"sobjectType": "Account", "Name": null, "Website": null, "Number_of_Full_Time_Employees__c": null, "Interested_in_Number_of_Desks__c": null});
        }
        component.get("v.contactRec") ?  component.get("v.contactRec.Company") ? component.set("v.accountRec.Name", component.get("v.contactRec.Company")) : "" : component.set("v.contactRec", {"sobjectType": "Contact", "FirstName": null, "LastName": null, "Email": null, "Phone": null});
    },
    checkNumberOfFullTimeEmployee : function(component, event, helper){
        if(component.get("v.accountRec.Number_of_Full_Time_Employees__c") >= 1000 && !component.get("v.canCreateEnterpriseOrg")){
            component.find("utils").showWarning("In order to create an Enterprise Organization, you have to submit a request by clicking on Request New Organization button.", false);
        }        
    },
    close : function(component, event, helper){
        helper.close(component);
    },
    createNewOrg :function(component, event, helper){
        if(!component.get("v.accountRec.Website") && !JSON.parse(component.get("v.isFromConfirmationModal"))){
            component.find("confirmation").showModal();
            component.set("v.isFromConfirmationModal", true);
        }else{
            helper.createNewOrganization(component, helper);
        }
    },
    requestNewOrg : function(component, event, helper){
        if(!component.get("v.accountRec.Website") && !JSON.parse(component.get("v.isFromConfirmationModal"))){
            component.find("confirmation").showModal();
            component.set("v.isFromConfirmationModal", true);
        }else{
            helper.requestNewOrganization(component, helper);
        }
    },
    searchContact : function(component, event, helper){
        var email = component.get("v.contactRec.Email");
        var existingEmail = component.get("v.existingContact.Email");
        if((existingEmail == undefined || (email && existingEmail && existingEmail.toLocaleLowerCase() != email.toLocaleLowerCase())) && existingEmail == undefined  && email != undefined && email.lastIndexOf("@") < email.lastIndexOf(".") && (email.lastIndexOf(".") - email.lastIndexOf("@")) > 1 && (email.length - email.lastIndexOf(".")) > 1){
            var strQuery = "SELECT Id, FirstName, LastName, Phone, Email, AccountId, Account.Name, Billing_Account__c, Billing_Account__r.Parent_Account__c, Billing_Account__r.Name, (SELECT Id, Name, Parent_Account__c FROM Billing_Accounts__r) FROM Contact WHERE Email = '" + component.find("utils").addSlashes(email) + "'";
            component.find("utils").execute("c.getQueryData", {"query": strQuery}, function(response){
                if(response.length > 0){
                    var contactRec = response[0];
                    if(email.toLocaleLowerCase() == contactRec.Email.toLocaleLowerCase()){
                        helper.checkBillingAccount(component, helper, contactRec);
                    }
                }else{
                    component.set("v.canCreateOrg", true);
                }
            },function(error){
                component.find("utils").hideProcessing();            
                component.find("utils").showError(error);
            }); 
        }else if(existingEmail != undefined && email != existingEmail){
            helper.resetContact(component, email);
            component.set("v.existingContact",null);
            component.set("v.canCreateOrg", true);
        }
    },
    closeModal : function(component, event, helper){
        component.find("confirmation").closeModal();
        component.set("v.isFromConfirmationModal", false);        
    }
})