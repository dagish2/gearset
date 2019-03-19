({
	retroReferrerSearch : function(component, event, helper){
        helper.retroReferrerSearch(helper, event.getParam('arguments').show);
    },
    retroCreateNewReferrer : function(component, event, helper){
        helper.retroCreateNewReferrer(helper, event.getParam('arguments').show);
    },
    confidentionalReferrerSearch : function(component, event, helper){
        helper.confidentionalReferrerSearch(helper, event.getParam('arguments').show);
    },
    confidentionalCreateNewBillAcc : function(component, event, helper){
        helper.confidentionalCreateNewBillAcc(helper, event.getParam('arguments').show);
    },
    confidentionalCreateNewReferrer : function(component, event, helper){
        helper.confidentionalCreateNewReferrer(helper, event.getParam('arguments').show);
    },
    onRetroActive : function(component, event, helper){
        component.get("v.opportunityData.Referrer__r") ? component.set("v.referralObj", JSON.parse(JSON.stringify(component.get("v.opportunityData.Referrer__r"))))  : component.set("v.refObj", {"Id": null, "Email": null, "Phone": null, "Type__c": null});
        component.get("v.disabledBill") ? '' : component.get("v.opportunityData.Billing_Account__r")  ? component.set("v.accountRetroObj", JSON.parse(JSON.stringify(component.get("v.opportunityData.Billing_Account__r")))) : component.set("v.accountObj", {"Id": null, "Primary_Member_Email__c": null, "Parent_Account__c": null, "ID_Status__c": null});
        helper.gotoConfidentionalReferrer(component, helper);
        helper.retroReferrerSearch(helper, true);
        helper.retroCreateNewReferrer(helper, false);
        helper.confidentionalReferrerSearch(helper, false);
        helper.confidentionalCreateNewReferrer(helper, false);
        helper.confidentionalCreateNewBillAcc(helper, false);
    },
    onConfidentionalActive : function(component, event, helper){
        component.get("v.opportunityData.Referrer__r") ? component.set("v.refObj", JSON.parse(JSON.stringify(component.get("v.opportunityData.Referrer__r")))) : component.set("v.referralObj", {"Id": null, "Email": null, "Phone": null, "Type__c": null});
        component.get("v.disabledBill") ? '' : component.get("v.opportunityData.Billing_Account__r") ? component.set("v.accountObj", JSON.parse(JSON.stringify(component.get("v.opportunityData.Billing_Account__r")))) : component.set("v.accountRetroObj", {"Id": null, "Primary_Member_Email__c": null, "Parent_Account__c": null, "ID_Status__c": null});
        helper.gotoSearchReferrer(component, helper);
        helper.retroReferrerSearch(helper, false);
        helper.retroCreateNewReferrer(helper, false);
        helper.confidentionalReferrerSearch(helper, true);
        helper.confidentionalCreateNewReferrer(helper, false);
        helper.confidentionalCreateNewBillAcc(helper, false);
    },
    resetRetroContact : function(component, event, helper){
       var params = event.getParam('arguments');
        helper.resetRetroContact(component, helper, params.email ? params.email : null );
    },
    resetPrimaryRetroContact : function(component, event, helper){
       var params = event.getParam('arguments');
        helper.resetPrimaryRetroContact(component, helper, params.email ? params.email : null );
    },
    createRetroContact : function(component, event, helper){
        helper.resetRetro(component, helper, null);
        component.set("v.existingRetroEmail", null);
        helper.retroReferrerSearch(helper, false);
        helper.retroCreateNewReferrer(helper, true);
        helper.retroCreateNewBillAcc(helper, false);
    },
    createRetroBillAcc : function(component, event, helper){
        helper.resetRetro(component, helper, null);
        component.set("v.existingRetroEmail", null);
        helper.retroReferrerSearch(helper, false);
        helper.retroCreateNewReferrer(helper, false);
        helper.retroCreateNewBillAcc(helper, true);
    },
    gotoSearchReferrer : function(component, event, helper){
        helper.gotoSearchReferrer(component, helper);
    },
    gotoConfidentionalReferrer : function(component, event, helper){
        helper.gotoConfidentionalReferrer(component, helper);
    },
    reset : function(component, event, helper){
        var params = event.getParam('arguments');
        return helper.reset(params.reset, params.email);
    },
    resetConfidentialContact : function(component, event, helper){
       var params = event.getParam('arguments');
        helper.resetConfidentialContact(component, helper, params.email ? params.email : null );
    },
    resetPrimaryContact : function(component, event, helper){
       var params = event.getParam('arguments');
        helper.resetPrimaryContact(component, helper, params.email ? params.email : null );
    },
    createConfidentialContact : function(component, event, helper){
        helper.resetConfidental(component, helper, null);
        component.set("v.existingEmail", null);
        helper.confidentionalReferrerSearch(helper, false);
        helper.confidentionalCreateNewReferrer(helper, true);
        helper.confidentionalCreateNewBillAcc(helper, false);
    },
    createConfidentialBillAcc : function(component, event, helper){
        helper.resetConfidental(component, helper, null);
        component.set("v.existingEmail", null);
        helper.confidentionalReferrerSearch(helper, false);
        helper.confidentionalCreateNewReferrer(helper, false);
        helper.confidentionalCreateNewBillAcc(helper, true);
    }
})