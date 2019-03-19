({
    doInit : function(component, event, helper) {
        component.set("v.utils", component.find("utils"));
        component.get("v.utils").showProcessing();
         component.get("v.utils").execute("c.isValidForManageProductLightning",{"opportunityId":component.get("v.recordId")},function(response){
            var oppResponse = JSON.parse(response);
             if(oppResponse.Success){
                 component.get("v.utils").hideProcessing();
                 var workspaceAPI = component.find("workspace");
                 workspaceAPI.isConsoleNavigation().then(function(isConsole) {
                     if (isConsole) {
                         workspaceAPI.openTab({
                             url: window.location.href,
                             focus: true
                         }).then(function(response) {
                             workspaceAPI.openSubtab({
                                 parentTabId: response,
                                 url:"/apex/ManageProducts?id="+component.get("v.recordId")+"&isFromCreateOpp=false",
                                 focus: true
                             });
                         });
                     }else{
                         var urlEvent = $A.get("e.force:navigateToURL");
                         urlEvent.setParams({
                             "url": "/apex/ManageProducts?id="+component.get("v.recordId")+"&isFromCreateOpp=false"
                         });
                         urlEvent.fire();
                     };
                 })                                      
            }
             else{
                  component.set("v.message", oppResponse.Message);
                  component.get("v.utils").hideProcessing();
                }
        }, function(error){
             component.get("v.utils").hideProcessing();
             component.set("v.message", error);
        }, component);
    },
    close:function(component, event, helper){
        component.get("v.utils").closeTab(); 
    }
})