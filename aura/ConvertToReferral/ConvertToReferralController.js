({
	doInit : function(component, event, helper){
        component.set("v.utils", component.find("utils"));
        component.get("v.utils").setTitle("Convert To Referral");
        component.get("v.utils").showProcessing();
        if(!component.get("v.recordId")){
            component.get("v.utils").execute("c.initialize", {"opportunityId": null}, function(response){
                component.get("v.utils").hideProcessing();
                if(response){
                    var referralSetting = JSON.parse(response);
                    if(referralSetting && JSON.parse(referralSetting.isValid)){
                        var retroData = JSON.parse(referralSetting['Setting'].Data__c);
                        var restrictedStages = JSON.parse(JSON.stringify(retroData.RestrictOppStages).toLowerCase());
                        component.set("v.retrictedStages", restrictedStages);
                        component.set("v.theme", new Boolean(!window.location.href.includes('lightning')).valueOf('Boolean'));
                        $A.util.removeClass(document.getElementById("referralBody"), "slds-hide");
                    }else {
                        component.set("v.message", referralSetting.errorMessage ? referralSetting.errorMessage : "Something went wrong, Please contact System Administrator")
                        $A.util.removeClass(document.getElementById("errorMsg"), "slds-hide");
                    }
                }
            },function(error){
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError(error);
            },component);
        }else{
            component.get("v.utils").hideProcessing();
            setTimeout(function(){ $A.util.removeClass(document.getElementById("referralBody"), "slds-hide"); }, 100)
        }
    },
    useThisOpp : function(component, event, helper) {
        var utils = component.find("utils");
        if(component.get("v.record") && component.get("v.record.Id")){
            utils.showProcessing();
            utils.execute("c.initialize", {"opportunityId": component.get("v.record.Id")}, function(response){
                utils.hideProcessing();
                if(response){
                    var referralSetting = JSON.parse(response);
                    if(referralSetting && JSON.parse(referralSetting.isValid)){
                        var opp = JSON.parse(JSON.stringify(component.get("v.record")))
                        component.set("v.recordId", opp.Id);
                        component.set("v.isFromGlobalAction", true);
                    }else {
                        utils.showError(referralSetting.errorMessage ? referralSetting.errorMessage : "Something went wrong, Please contact System Administrator");
                        component.set("v.showConvertRefrrer", false);
                    }
                }
            },function(error){
                utils.hideProcessing();
                utils.showError(error);
            },component);
        }
    },
    backFromUpdateReferrer : function(component, event, helper){
        component.set("v.recordId", null);
        component.set("v.selectedRows", []);
        var lstOpp = component.get("v.opportunities");
        component.set("v.opportunities", []);
        component.set("v.oppRec", {});
        component.set("v.conRec", {});
        setTimeout(function(){
             component.set("v.opportunities", lstOpp);
        },100);
    },
    close : function(component, event, helper){
        component.get("v.utils").closeTab();
        component.get("v.utils").redirectToUrl('back');
    }
})