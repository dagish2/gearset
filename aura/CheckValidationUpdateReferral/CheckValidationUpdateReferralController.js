({
    doInit : function(component, event, helper){
        component.set("v.utils", component.find("utils"));
        component.get("v.utils").setTitle("Update Referrer");
        component.get("v.utils").showProcessing();
        component.get("v.utils").execute("c.initialize", {"opportunityId": component.get("v.recordId") ? component.get("v.recordId") : null }, function(response){
            component.get("v.utils").hideProcessing();
            if(response){
                var referralSetting = JSON.parse(response);
                if(referralSetting && JSON.parse(referralSetting.isValid)){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": location.origin +"/apex/ConvertToReferral?id=" + (component.get("v.recordId") ? component.get("v.recordId") : null )
                    });
                    urlEvent.fire();
                    if($A.get("e.force:closeQuickAction").getSource().isValid()) {
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }else {
                    component.set("v.message", referralSetting.errorMessage ? referralSetting.errorMessage : "Something went wrong, Please contact System Administrator")
                    component.set("v.showConvertRefrrer", false);
                }
            }
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        },component);
    },
    close : function(component, event, helper){
        component.find("utils").closeTab();
    }
})