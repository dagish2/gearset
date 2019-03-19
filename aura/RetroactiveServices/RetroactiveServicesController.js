({
    doInit : function(component, event, helper){
        component.set("v.utils", component.find("utils"));
        component.set("v.referrerServices", component.find("referrerServices"));
    },
    checkContactEmail : function(component, event, helper){
		var params = event.getParam('arguments');
        helper.checkContactEmail(params.email, params.existingEmail, params.onsuccess);
	},
    searchContact : function(component, event, helper){
        var params = event.getParam('arguments');
        helper.searchRecord(component, params.id, params.email, params.isReferrer, params.onsuccess);
    },
    checkContact : function(component, event, helper){
        var params = event.getParam('arguments');
        helper.checkContact(component, helper, params.contactRec, params.onsuccess);
    },
    resetContact : function(component, event, helper){
        var params = event.getParam('arguments');
        return component.get("v.referrerServices").reset("contact", null);
    },
    resetDisabled : function(component, event, helper){
         var params = event.getParam('arguments');
        return component.get("v.referrerServices").reset("contactDisabled", null);
    },
    selectReferrer : function(component, event, helper){
        var params = event.getParam('arguments');
        helper.searchRecord(component, params.recordId, null, true, function(referrer){
            if(params.type.toLowerCase() == "retroactive"){
                component.set("v.referralObj", referrer);
                component.get("v.referrerServices").gotoSearchReferrer(component, helper);
            }else if(params.type.toLowerCase() == "confidential"){
                component.set("v.refObj", referrer);
                component.get("v.referrerServices").gotoConfidentionalReferrer(component, helper);
            }
        });
    },
    selectBillAcc : function(component, event, helper){
        var params = event.getParam('arguments');
        helper.searchRecord(component, params.recordId, null, true, function(billAcc){
            if(params.type.toLowerCase() == "retroactive"){
                component.set("v.accountRetroObj", billAcc);
                component.get("v.referrerServices").gotoSearchReferrer(component, helper);
            }else if(params.type.toLowerCase() == "confidential"){
                component.set("v.accountObj", billAcc);
                component.get("v.referrerServices").gotoConfidentionalReferrer(component, helper);
            }
        });
    },
    searchReferrer : function(component, event, helper) {
        var params = event.getParam('arguments');
        helper.searchReferrer(component, helper, params.email, params.existingEmail, params.type.toLowerCase(), params.isPrimaryContact);
    },
    getBillAcc : function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params.type.toLowerCase() == "retroactive"){
            component.get("v.accountRetroObj.Id") ? helper.searchRecord(component, component.get("v.accountRetroObj.Id"), null, true, function(billAcc){ component.set("v.accountRetroObj", billAcc) }) : component.set("v.accountRetroObj", {"Id": null, "Primary_Member_Email__c": null, "Parent_Account__c": null, "ID_Status__c": null});
        }else if(params.type.toLowerCase() == "confidential"){
            component.get("v.accountObj.Id") ? helper.searchRecord(component, component.get("v.accountObj.Id"), null, true, function(billAcc){ component.set("v.accountObj", billAcc) }) : component.set("v.accountObj", {"Id": null, "Ultimate_Parent_Org__c": (component.get("v.accountObj.Ultimate_Parent_Org__c")? component.get("v.accountObj.Ultimate_Parent_Org__c") : null ),  "Primary_Member_Email__c": null, "Parent_Account__c": null, "ID_Status__c": null});
        }
    },
    getReferrer : function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params.type.toLowerCase() == "retroactive"){
            component.get("v.referralObj.Id") ? helper.searchRecord(component, component.get("v.referralObj.Id"), null, true, function(referrer){ component.set("v.referralObj", referrer) }) : component.set("v.referralObj", {"Id": null, "Email": null, "Phone": null, "Type__c": null});
        }else if(params.type.toLowerCase() == "confidential"){
            component.get("v.refObj.Id") ? helper.searchRecord(component, component.get("v.refObj.Id"), null, true, function(referrer){ component.set("v.refObj", referrer) }) : component.set("v.refObj", {"Id": null, "Email": null, "Phone": null, "Type__c": null});
        }
    }
})