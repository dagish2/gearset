({
    doInit : function(component, recordId){
        ["v.updateReferrerHelper", "v.referrerServices", "v.retroactiveServices", "v.utils", "v.referralObj", "v.refObj", "v.accountObj", "v.accountRetroObj", "v.opportunityData"].forEach((element) => {
            element == "v.utils" ? component.set(element, component.find("utils")) : element == "v.retroactiveServices" ? component.set(element, component.find("retroactiveServices")) : element == "v.referrerServices" ? component.set(element, component.find("referrerServices")) : element == "v.updateReferrerHelper" ? component.set(element, component.find("updateReferrerHelper")) : component.set(element, {});
        });
        if(recordId && (!component.get("v.opportunityData") || (component.get("v.opportunityData") && recordId != component.get("v.opportunityData.Id")))){
            component.get("v.utils").execute("c.initialize", {"opportunityId": recordId}, function(response){
                component.get("v.utils").hideProcessing();
                if(response){
                    var referralSetting = JSON.parse(response);
                    if(referralSetting && referralSetting.Setting){
                        var retroData = JSON.parse(referralSetting['Setting'].Data__c);
                        component.set("v.referralType", retroData.RetroactiveReferralType);
                        component.set("v.referrType", retroData.RetroactiveReferrType);
                        component.set("v.ContactRecordType", retroData.ContactRecordType);
                        component.set("v.AccountRecordType", retroData.AccountRecordType);
                        component.set("v.APIUser", retroData.APIUser);
                        component.set("v.settingData", retroData);
                        component.set("v.apiSetting", JSON.parse(referralSetting['apiSetting'].Data__c)["CreateAccountAPI"])
                        var oppData = JSON.parse(JSON.stringify(referralSetting.OpportunityData));
                        if(oppData){
                            component.set("v.opportunityData", oppData);
                            if(oppData.Referrer__r){
                                var referrer = JSON.parse(JSON.stringify(oppData.Referrer__r))
                                component.set("v.referralObj", referrer);
                                component.set("v.refObj", referrer);
                            }
                            if(oppData.Billing_Account__r){
                                var billingAcc = JSON.parse(JSON.stringify(oppData.Billing_Account__r));
                                component.set("v.accountRetroObj", billingAcc);
                                component.set("v.accountObj", billingAcc);
                                component.set("v.orgId", billingAcc.Ultimate_Parent_Org__c);
                                component.set("v.confiBillCriteria", billingAcc.Ultimate_Parent_Org__c ? ("Ultimate_Parent_Org__c = '"+ billingAcc.Ultimate_Parent_Org__c +"'") : '');
                                var allowOppstages = new Set(JSON.parse(JSON.stringify(retroData.RestrictCriteria.allowedOppStages).toLowerCase()));
                                var excludeContractStages = new Set(JSON.parse(JSON.stringify(retroData.RestrictCriteria.excludedContractStages).toLowerCase())); 
                                if(allowOppstages && excludeContractStages && oppData.StageName && oppData.Contract_Stage__c && allowOppstages.has(oppData.StageName.toLowerCase()) && excludeContractStages.has(oppData.Contract_Stage__c.toLowerCase())){
                                    component.set("v.disabledBill", true);
                                }
                            }
                            if(oppData.AccountId, oppData.Account.Parent_Org__c){
                                component.set("v.retroCriteria", "Ultimate_Parent_Org__c = '"+ oppData.Account.Parent_Org__c +"'");
                                
                            }
                        }
                        component.set("v.marginFooter",document.getElementById("updateReferrerFooter").getBoundingClientRect().height +"px");
                    }
                }
            },function(error){
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError(error);
            },component);
        }
    },
    closeWindow : function(component, event, helper){
        component.get("v.utils").closeTab();
        component.get("v.utils").redirectToUrl('back');
    },
    OpenSFRecord : function(component){
        if(component.get("v.opportunityData")){
            component.get("v.utils").closeTab();
            component.get("v.utils").redirectToUrl("/" + component.get("v.opportunityData.Id"), "", true, false, false);
        }else{
            component.get("v.utils").closeTab();
            component.get("v.utils").redirectToUrl('back');
        }
    },
    saveRetroReferrer : function(component, helper) {
        component.get("v.updateReferrerHelper").saveReferrer(JSON.parse(JSON.stringify(component.get("v.retroContact"))), function(conReferrer){
            component.get("v.utils").showSuccess('Referrer created succesfully!!');
            component.get("v.retroactiveServices").selectReferrer(conReferrer.Id, "retroactive");
        });
    },
    saveConfiReferrer : function(component, helper) {
        component.get("v.updateReferrerHelper").saveReferrer(JSON.parse(JSON.stringify(component.get("v.contact"))), function(conReferrer){
            component.get("v.utils").showSuccess('Referrer created succesfully!!');
            component.get("v.retroactiveServices").selectReferrer(conReferrer.Id, "confidential");
        });
    },
    saveRetroAcc : function(component, helper) {
        var contact = JSON.parse(JSON.stringify(component.get("v.primaryRetroContact")));
        var billingAccount = JSON.parse(JSON.stringify(component.get("v.primaryRetroContact")));
        if(!contact.Id){
            contact["Company__c"] = billingAccount.BillAccName;
            contact["AccountId"] = component.get("v.opportunityData.AccountId");
        }
        billingAccount["Parent_Account__c"] = component.get("v.opportunityData.AccountId");
        component.get("v.updateReferrerHelper").saveBillAcc(contact, billingAccount, function(billAcc){
            component.get("v.utils").showSuccess('Account created succesfully.');
            component.get("v.retroactiveServices").selectBillAcc(billAcc.Id, "retroactive");
        });
    },
    saveConfiAcc : function(component, helper) {
        var contact = JSON.parse(JSON.stringify(component.get("v.primaryContact")));
        var billingAccount = JSON.parse(JSON.stringify(component.get("v.primaryContact")));
        var confiAcc = JSON.parse(JSON.stringify(component.get("v.accountObj.Ultimate_Parent_Org__c")));
        confiAcc ? billingAccount["Parent_Account__c"] = confiAcc : '' ;
        if(!contact.Id){
            contact["Company__c"] = billingAccount.BillAccName;
        }
        component.get("v.updateReferrerHelper").saveBillAcc(contact, billingAccount, function(billAcc){
            component.get("v.utils").showSuccess('Account created succesfully.');
            component.get("v.retroactiveServices").selectBillAcc(billAcc.Id, "confidential");
        });
    },
    updateOpportunity : function(component, helper, referrer, billAccId, parentAccId, oppReferralType){
        component.get("v.updateReferrerHelper").saveOpportunity(component.get("v.recordId"), referrer, billAccId, parentAccId, oppReferralType, function(oppRec){
            helper.OpenSFRecord(component);
        });   
    }
})