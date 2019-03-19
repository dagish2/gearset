({
    redirectToOpportunity : function(component, helper) {
        window.setTimeout(function(){
            if(component.get("v.opportunity_id")){
                component.get("v.utils").closeTab();
                component.get("v.utils").redirectToUrl('/'+component.get("v.opportunity_id"))
            }else{
                component.get("v.utils").closeTab();
            }
        },2000);
    },
    updateReferralSAPI : function(component, oppRec, referralSetting, existingReferral, onSuccess){
        var utils = component.get("v.utils");
        if(oppRec && referralSetting){
            var objreferral = {};
            objreferral.referral = {};
            objreferral.referral.closed_won_date = (oppRec.Contract_Signed_On_Date__c) ? oppRec.Contract_Signed_On_Date__c : '';
            objreferral.referral.deal_type = (oppRec.RecordType && oppRec.RecordType.Name) ? oppRec.RecordType.Name : '' ;
            objreferral.referral.location_uuid = (oppRec.Building__r && oppRec.Building__r.UUID__c) ? oppRec.Building__r.UUID__c : '';
            objreferral.referral.market_uuid = (oppRec.Building__r && oppRec.Building__r.Market__r && oppRec.Building__r.Market__r.UUID__c) ? oppRec.Building__r.Market__r.UUID__c : '';
            objreferral.referral.opportunity_sf_id = oppRec.Id;
            objreferral.referral.referred_at = existingReferral ? existingReferral.CreatedDate: oppRec.CreatedDate;
            objreferral.referral.contact_referrer_only = (oppRec.Contact_Broker__c) ? oppRec.Contact_Broker__c : false;
            objreferral.referral.company = {};
            objreferral.referral.company.uuid = (oppRec.Billing_Account__r && oppRec.Billing_Account__r.UUID__c) ? oppRec.Billing_Account__r.UUID__c : '';
            objreferral.referral.company.name = (oppRec.Billing_Account__r && oppRec.Billing_Account__r.Name) ? oppRec.Billing_Account__r.Name : '';
            objreferral.referral.primary_member = {};
            objreferral.referral.primary_member.email = (oppRec.Primary_Member__r && oppRec.Primary_Member__r.Email) ? oppRec.Primary_Member__r.Email : '';
            objreferral.referral.primary_member.name = (oppRec.Primary_Member__r && oppRec.Primary_Member__r.Name) ? oppRec.Primary_Member__r.Name : '';
            objreferral.user = {};
            objreferral.user.email = (oppRec.Referrer__r && oppRec.Referrer__r.Email) ? oppRec.Referrer__r.Email : '';
            objreferral.user.name = (oppRec.Referrer__r && oppRec.Referrer__r.Name) ? oppRec.Referrer__r.Name : '';
            objreferral.user.type = (oppRec.Referrer__r && oppRec.Referrer__r.Type__c) ? oppRec.Referrer__r.Type__c : '';
            objreferral.user.phone = (oppRec.Referrer__r && oppRec.Referrer__r.Phone) ? oppRec.Referrer__r.Phone : '';
            objreferral.user.contact_sf_id = (oppRec.Referrer__r && oppRec.Referrer__r.Id) ? oppRec.Referrer__r.Id : '';
            var url = referralSetting.RetroactiveReferralApi.url;
            var headers = {"Content-Type":"application/json","Authorization":referralSetting.RetroactiveReferralApi.Headers.Authorization};
            utils.execute("c.executeRest", {"method": "POST","endPointUrl": url,"headers": headers,"body": JSON.stringify(objreferral)}, function(response){
                if(response)
                    onSuccess(JSON.parse(response));      
            },function(error){
                utils.hideProcessing();
                utils.showError(error);
            });
        }
    },
    upsertRecords : function(component, helper, oppRec, referral){
        var utils = component.get("v.utils");
        utils.execute("c.getUserInfo",{},function(userRec){
            if(userRec && JSON.parse(userRec).length){
                var records = [];
                records.push({"Id":component.get("v.opportunity_id"),"Referral_Status__c":component.get("v.referral_status"),"Referral_Approved_By__c":JSON.parse(userRec)[0].Id})
                referral ? records.push({"sobjectType":"Referral__c", "Referral_Email__c": oppRec.Primary_Member__r.Email, "Expires_On__c": referral.Expires_On__c, "Referral_Source__c": "Retroactive Referral", "Referrer_Type__c": oppRec.Referrer__r.Type__c, "Referrer__c": oppRec.Referrer__r.Id, "Start_Date__c": referral.Start_Date__c}) : '' ;
                utils.execute("c.saveRecords", {"records": records},function(response){
                    utils.showSuccess('Opportunity updated successfully.');
                    utils.hideProcessing();
                    helper.redirectToOpportunity(component, helper);
                },function(error){
                    utils.hideProcessing();
                    utils.showError(error);
                    helper.redirectToOpportunity(component, helper);
                });
            }else{
                utils.hideProcessing();
                utils.showError('User not found.');
                helper.redirectToOpportunity(component, helper);
            }
        },function(error){
            utils.hideProcessing();
            utils.showError(error);
            helper.redirectToOpportunity(component, helper);
        })
    }
})