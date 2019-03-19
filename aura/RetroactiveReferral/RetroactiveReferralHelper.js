({
    getContactInfo : function(component, helper, onSuccess){
        if(component.get("v.referralObj.Id")){
            var query = "SELECT Id,Name,Email,Phone,Type__c FROM Contact WHERE Id = '"+component.get("v.referralObj.Id")+"'";
            component.find("utils").execute("c.getQueryData", {"query":query}, function(response){               
                if(response[0]){
                    component.set("v.referralObj",response[0]);
                     onSuccess();
                }  
            },function(error){              
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            });
        }       
    },
    getAccountsInfo : function(component, helper,  onSuccess){
        var query = "SELECT Id,Name,UUID__c,Primary_Member__c,Primary_Member__r.Email,ID_Status__c,Parent_Account__c,Parent_Account__r.Name FROM Billing_Account__c WHERE Id = '"+component.get("v.accountObj.Id")+"'";
        component.find("utils").execute("c.getQueryData", {"query":query}, function(response){
            if(response[0]){
                component.set("v.accountObj",{"Id":response[0].Id,"Name":response[0].Name,"UUID__c":response[0].UUID__c,"ID_Status__c":response[0].ID_Status__c,"Parent_Account_Name":(response[0].Parent_Account__c ? response[0].Parent_Account__r.Name : null),"Primary_Member_Email__c":(response[0].Primary_Member__c ? response[0].Primary_Member__r.Email : null),"Parent_Account__c":response[0].Parent_Account__c});
                onSuccess();
            }
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    getReferralsInfo : function(component, method, params, onSuccess, onError){
        var query = "SELECT Id,Name,Email,phone,Type__c FROM Contact WHERE Id = '"+component.get("v.refObj.Id")+"'";
        component.find("utils").execute("c.getQueryData", {"query":query}, function(response){
            if(response[0]){
                /*var refObj;
                refObj.Id = response[0].Id;
                refObj.Name = response[0].Name;
                refObj.Email = response[0].Email;
                refObj.phone = response[0].phone;
                refObj.Type__c = response[0].Type__c;*/
                component.set("v.refObj",response[0]);
            }
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    closeWindow:function(component,event,helper){
        var oppId= JSON.parse(JSON.stringify(component.get("v.recordId")));
        if (sforce.console.isInConsole()) {
            //Open a new primary tab with the URL page in it
            component.find("utils").hideProcessing();
            sforce.console.openPrimaryTab(null, '/' + oppId, false, 'Reservable Hold Form', openSuccess, 'Reservable Hold Form');
            var openSuccess = function openSuccess(result) {
                //Report whether opening the new tab was successful
                if (result.success == true) {
                    console.log('Primary tab successfully opened');
                } else {
                    console.log('Primary tab cannot be opened');
                }
            };
        }
        else if (sforce.one) {
            try {
                component.find("utils").hideProcessing();
                sforce.one.navigateToURL('/' + oppId);
            }
            catch (e) {
                component.find("utils").hideProcessing();
                window.location.href = '/' + oppId;
            }
        } else {
            component.find("utils").hideProcessing();
            window.location.href = '/' + oppId;   
        }
    },
    updateReferralSAPI : function (component,event,helper,referral,billingAccount,onSuccess){
        var updatedOpportunity = component.get("v.opportunityData");
        var objreferral = {};
        objreferral.referral = {};
        objreferral.referral.closed_won_date = (updatedOpportunity.Contract_Signed_On_Date__c !=null && updatedOpportunity.Contract_Signed_On_Date__c!='')?  updatedOpportunity.Contract_Signed_On_Date__c:'';
        objreferral.referral.deal_type = updatedOpportunity.RecordType.Name;
        objreferral.referral.company = {};
        if(billingAccount == null){
            objreferral.referral.company.uuid = updatedOpportunity.Billing_Account__r.UUID__c;
            objreferral.referral.company.name = updatedOpportunity.Billing_Account__r.Name; 
        }else{
            objreferral.referral.company.uuid = billingAccount.UUID__c;
            objreferral.referral.company.name = billingAccount.Name; 
        }
        
        objreferral.referral.location_uuid = (updatedOpportunity.Building__r != null && updatedOpportunity.Building__r.UUID__c != null)?updatedOpportunity.Building__r.UUID__c :'';
        objreferral.referral.primary_member = {};
        objreferral.referral.primary_member.email = (updatedOpportunity.Primary_Member__r != null && updatedOpportunity.Primary_Member__r.Email  != null)? updatedOpportunity.Primary_Member__r.Email:'';
        objreferral.referral.primary_member.name = (updatedOpportunity.Primary_Member__r != null && updatedOpportunity.Primary_Member__r.Name != null) ? updatedOpportunity.Primary_Member__r.Name :'';
        objreferral.user = {};
        objreferral.user.email = referral.Email;
        objreferral.user.name = referral.Name;
        objreferral.user.type = referral.Type__c;
        objreferral.user.phone = referral.Phone;
        console.log('objreferral ::     ' +JSON.stringify(objreferral));
        var settings = JSON.parse(JSON.stringify(component.get("v.settingData")));
        var url = settings.RetroactiveReferralApi.url;
        var headers = {"Content-Type":"application/json","Authorization":settings.RetroactiveReferralApi.Headers.Authorization};
        component.find("utils").execute("c.executeRest", {"method": "POST","endPointUrl": url,"headers": headers,"body": JSON.stringify(objreferral)}, function(response){
            if(response)
                onSuccess(true);
            onSuccess(true);
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    getContactInfoForconfidential: function(component, helper, onSuccess){
        if(component.get("v.refObj.Id")){
            var query = "SELECT Id,Name,Email,Phone,Type__c FROM Contact WHERE Id = '"+component.get("v.refObj.Id")+"'";
            component.find("utils").execute("c.getQueryData", {"query":query}, function(response){
                if(response[0]){
                    component.set("v.refObj",response[0]);
                     onSuccess();
                }  
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            });
        } 
    }
})