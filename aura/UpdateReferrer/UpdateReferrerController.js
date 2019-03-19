({
    doInit : function(component, event, helper) {
       helper.doInit(component, component.get("v.recordId"));
    },
    onRetroActive : function(component, event, helper) {
        component.get("v.referrerServices").onRetroActive(component, helper);
    },
    onConfidentionalActive : function(component, event, helper) {
        component.get("v.referrerServices").onConfidentionalActive(component, helper);
    },
    createRetroContact : function(component, event, helper){  
        component.get("v.referrerServices").createRetroContact();
    },
    searchContactRetro : function(component, event, helper) {
        component.get("v.retroactiveServices").searchReferrer(component.get("v.retroContact.Email"), component.get("v.existingRetroEmail"), "retroactive", false);
    },
    searchRetro : function(component, event, helper){
        component.get("v.referrerServices").gotoSearchReferrer();
    },
    useThisReferrarForRetro : function(component, event, helper){
        component.get("v.retroactiveServices").selectReferrer(component.get("v.retroContact.Id"), "retroactive");
    },
    saveRetroReferrer : function(component, event, helper){
        helper.saveRetroReferrer(component, helper);
    },
    createRetroNewBillAcc : function(component, event, helper){  
        component.get("v.referrerServices").createRetroBillAcc();
    },
    searchPrimaryRetroContact : function(component, event, helper) {
        component.get("v.retroactiveServices").searchReferrer(component.get("v.primaryRetroContact.Email"), component.get("v.existingRetroEmail"), "retroactive", true);
    },
    useRetroBillAcc : function(component, event, helper){
        component.get("v.retroactiveServices").selectBillAcc(component.get("v.primaryRetroContact.BillAccId"), "retroactive");
    },
    saveRetroBillAcc : function(component, event, helper){
        helper.saveRetroAcc(component, helper);
    },
    getAllReferralContacts : function(component, event, helper) {
        component.get("v.retroactiveServices").getReferrer("retroactive");
    },
    getRetroBillAccount : function(component, event, helper) {
        component.get("v.retroactiveServices").getBillAcc("retroactive");
    },
    getAccounts : function(component, event, helper) {
        component.get("v.retroactiveServices").getBillAcc("confidential");
    },
    getReferrals : function(component, event, helper) {
        component.get("v.retroactiveServices").getReferrer("confidential");
    },    
    referralSave : function(component, event, helper) {
        component.get("v.utils").showConfirm("Are you sure you want to Convert this opportunity to Retroactive Referral?",function(){
            helper.updateOpportunity(component, helper, component.get("v.referralObj"), component.get("v.accountRetroObj.Id"), null, "Retroactive Referral");
        });
    },
    referralClose : function(component, event, helper) {
        component.get("v.utils").showConfirm("Are you sure want to close ?",function(){
            helper.closeWindow(component, event, helper);
        });
    },
    confidentialSave : function(component, event, helper) {
        component.get("v.utils").showConfirm("Are you sure you want to Convert this opportunity to Confidential Referral?",function(){
            helper.updateOpportunity(component, helper, component.get("v.refObj"), component.get("v.accountObj.Id"), component.get("v.accountObj.Parent_Account__c"), "Confidential Referral");
        });
    },
    confidentialClose : function(component, event, helper) {
        component.get("v.utils").showConfirm("Are you sure want to close ?",function(){
            helper.closeWindow(component, event, helper);
        });
    },
    createContactReferral : function(component, event, helper){  
        component.get("v.referrerServices").createConfidentialContact();
    },
    createNewAccount : function(component, event, helper){
        component.get("v.referrerServices").createConfidentialBillAcc();
    },
    saveConfidentioanlReferrer : function(component, event, helper) {
       helper.saveConfiReferrer(component, helper);
    },
    saveAccount : function(component, event, helper) {
        helper.saveConfiAcc(component, helper);
    },
    closeNewContactConfidentional : function(component, event, helper){
        component.get("v.referrerServices").gotoConfidentionalReferrer();
    },
    closeNewAccountConfidentional : function(component, event, helper){
        component.get("v.referrerServices").gotoConfidentionalReferrer();
    },
    searchConfidentional : function(component, event, helper){
        component.get("v.referrerServices").gotoConfidentionalReferrer();
    },
    searchPrimaryContact : function(component, event, helper){
        component.get("v.retroactiveServices").searchReferrer(component.get("v.primaryContact.Email"), component.get("v.existingEmail"), "primarycontact", true);
    },
    searchContact : function(component, event, helper){
        component.get("v.retroactiveServices").searchReferrer(component.get("v.contact.Email"), component.get("v.existingEmail"), "confidential", false);
    },
    useBillAcc : function(component, event, helper){
        component.get("v.retroactiveServices").selectBillAcc(component.get("v.primaryContact.BillAccId"), "confidential");
    },
    useThisReferrar : function(component, event, helper){
        component.get("v.retroactiveServices").selectReferrer(component.get("v.contact.Id"), "confidential");
    },
    copyOppMainContactForRetro : function(component, event, helper){
        var oppData = JSON.parse(JSON.stringify(component.get("v.opportunityData")));
        if(oppData.Primary_Member__r.Email){
            component.set("v.primaryRetroContact.Email", oppData.Primary_Member__r.Email);
            component.get("v.retroactiveServices").searchReferrer(component.get("v.primaryRetroContact.Email"), component.get("v.existingRetroEmail"), "retroactive", true);
        }
    },
    changeInOrg : function(component, event, helper){
        component.set("v.confiBillCriteria", component.get("v.accountObj.Ultimate_Parent_Org__c") ? ("Ultimate_Parent_Org__c = '"+ JSON.parse(JSON.stringify(component.get("v.accountObj.Ultimate_Parent_Org__c"))) +"'") : '');
        if(component.get("v.orgId") != component.get("v.accountObj.Ultimate_Parent_Org__c")){
            component.get("v.accountObj.Ultimate_Parent_Org__c") ? component.set("v.accountObj", {"Id": null, "Primary_Member_Email__c": null, "Parent_Account__c": null, "ID_Status__c": null, "Ultimate_Parent_Org__c":component.get("v.accountObj.Ultimate_Parent_Org__c")}) : component.set("v.accountObj", {"Id": null, "Primary_Member_Email__c": null, "Parent_Account__c": null, "ID_Status__c": null, "Ultimate_Parent_Org__c":null});
        	component.set("v.orgId", component.get("v.accountObj.Ultimate_Parent_Org__c"));
        }
    }
})