({
    addHideClass : function(id){
        $A.util.addClass(document.getElementById(id), "slds-hide");
    },
    removeHideClass : function(id){
        $A.util.removeClass(document.getElementById(id), "slds-hide");
    },
    showHidePageAndFooter : function(helper, page, footer, show){
        if(show){
            helper.removeHideClass(page);
            helper.removeHideClass(footer);
        }else{
            helper.addHideClass(page);
            helper.addHideClass(footer);
        }
    },
    retroReferrerSearch : function(helper, show){
        helper.showHidePageAndFooter(helper, "retroReferrer", "retroReferrerFooter", show);
    },
    retroCreateNewReferrer : function(helper, show){
        helper.showHidePageAndFooter(helper, "retroNewReferrer", "retroNewReferrerFooter", show);
    },
    retroCreateNewBillAcc : function(helper, show){
        helper.showHidePageAndFooter(helper, "retroNewBill", "retroNewBillFooter", show);
    },
    confidentionalReferrerSearch : function(helper, show){
        helper.showHidePageAndFooter(helper, "confindentionalReferrer", "confidentionalReferrerFooter", show);
    },
    confidentionalCreateNewBillAcc : function(helper, show){
        helper.showHidePageAndFooter(helper, "confidentionalNewBill", "confidentionalNewBillFooter", show);
    },
    confidentionalCreateNewReferrer : function(helper, show){
        helper.showHidePageAndFooter(helper, "confidentionalNewReferrer", "confidentionalNewReferrerFooter", show);
    },
    reset : function(reset, email){
        var obj;
        switch(reset) {
            case "contact":
                obj = {'sobjectType': 'Contact', 'FirstName': null, 'LastName': null, 'Email': email, 'Type__c': null, 'Company__c': null, 'Phone': null};
                break;
            case "contactDisabled":
                obj = {'FirstName': false, 'LastName': false, 'Phone': false, 'Type__c': false, 'Company__c': false};
                break;
            case "primaryContact":
                obj = {'sobjectType': 'Contact', 'FirstName': null, 'LastName': null, 'Email': email, 'Phone': null, 'BillAccName': null};
                break;
            case "primaryContactDisabled":
                obj = {'FirstName': false, 'LastName': false, 'Phone': false, 'BillAccName': false};
                break;
        }
        return obj;
    },
    resetRetroContact : function(component, helper, email){
        component.set("v.retroContact", helper.reset("contact", email));
        component.set("v.mapDisabledForContactInRetro", helper.reset("contactDisabled", null));
    },
    resetPrimaryRetroContact : function(component, helper, email){
        component.set("v.primaryRetroContact", helper.reset("primaryContact", email));
        component.set("v.mapDisabledForPrimaryRetroContact", helper.reset("primaryContactDisabled", null));
    },
    resetRetro : function(component, helper, email){
        helper.resetRetroContact(component, helper, email);
        helper.resetPrimaryRetroContact(component, helper, email);
    },
    gotoSearchReferrer : function(component, helper){
        helper.resetRetro(component, helper);
        component.set("v.existingRetroEmail", null);
        helper.retroReferrerSearch(helper, true);
        helper.retroCreateNewReferrer(helper, false);
        helper.retroCreateNewBillAcc(helper, false);
    },
    resetConfidentialContact : function(component, helper, email){
        component.set("v.contact", helper.reset("contact", email));
        component.set("v.mapDisabled", helper.reset("contactDisabled", null));
    },
    resetPrimaryContact : function(component, helper, email){
        component.set("v.primaryContact", helper.reset("primaryContact", email));
        component.set("v.mapDisabledForPrimaryContact", helper.reset("primaryContactDisabled", null));
    },
    resetConfidental : function(component, helper, email){
        helper.resetConfidentialContact(component, helper, email);
        helper.resetPrimaryContact(component, helper, email);
    },
    gotoConfidentionalReferrer : function(component, helper){
        helper.resetConfidental(component, helper, null);
        component.set("v.existingEmail", null);
        helper.confidentionalReferrerSearch(helper, true);
        helper.confidentionalCreateNewReferrer(helper, false);
        helper.confidentionalCreateNewBillAcc(helper, false);
    }
})