({
    doInit : function(component, event, helper) {
        component.set("v.utils", component.find("utils"));
        var utils = component.get("v.utils");
       utils.showProcessing();
        if(component.get("v.opportunity_id")){
            utils.execute("c.getOpprtunityData", {"opportunityId": component.get("v.opportunity_id")},function(response){
                if(response){
                    var oppRec = response.opp;
                    var referral = response.referralRec;
                    var existingReferral = response.existingReferral;
                    var referralSetting = response && response.referralSetting && response.referralSetting.Data__c ? JSON.parse(response.referralSetting.Data__c) : null;
                    if(oppRec && referralSetting){
                        if(!oppRec.Referral_Status__c){
                            utils.hideProcessing();
                            utils.showWarning('Opportunity Referral Status is blank.');
                            helper.redirectToOpportunity(component, helper);
                        }else if(oppRec.Referral_Status__c != 'Pending'){
                            utils.hideProcessing();
                            utils.showWarning('Opportunity Referral Status already has been updated.');
                            helper.redirectToOpportunity(component, helper);
                        }else if(component.get("v.referral_status")){
                            if(component.get("v.referral_status").toLowerCase() == 'approved'){
                                helper.updateReferralSAPI(component, oppRec, referralSetting, existingReferral, function(response){
                                    if(!response.error){
                                        helper.upsertRecords(component, helper, oppRec, referral);
                                    }else if(response.error){
                                        utils.showError(response.error);
                                        utils.hideProcessing();
                                        helper.redirectToOpportunity(component, helper);
                                    }
                                })
                            }else if(component.get("v.referral_status").toLowerCase() == 'declined'){
                                helper.upsertRecords(component, helper, oppRec, null);
                            }
                        }else{
                            utils.showError('referral status not found.');
                            utils.hideProcessing();
                            helper.redirectToOpportunity(component, helper);
                        }
                    }
                }else{
                    utils.hideProcessing();
                    utils.showError(error);
                    helper.redirectToOpportunity(component, helper);
                }
            },function(error){
                utils.hideProcessing();
                utils.showError(error);
                helper.redirectToOpportunity(component, helper);
            }, component);   
        }
    }
})