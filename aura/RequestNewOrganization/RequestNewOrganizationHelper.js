({
    resetNewRquestForm: function(component, helper) {
        component.set("v.requestedOrg", {"Name":null,"Number_of_Full_Time_Employees__c":null,"Website":null,"Description":null});
    },
    close: function(component, helper, timeOut) {        
        window.setTimeout(
            $A.getCallback(function() { 
                if(component.get("v.isFromCreateOpportunity")){
                    var parentCmpMethod = component.get("v.method");
                    //fire event from child and capture in parent                
                    $A.enqueueAction(parentCmpMethod);
                }else{
                    if(JSON.parse(component.get("v.isInLightningConsole"))){
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.isConsoleNavigation().then(function(response) {
                            if(response){
                                workspaceAPI.getEnclosingTabId().then(function(tabId) {
                                    workspaceAPI.closeTab({tabId: tabId});
                                    component.find("utils").closeTab();
                                })
                                .catch(function(error) {
                                    console.log(error);
                                });
                            } else {
                                component.find("utils").closeTab();
                                component.find("utils").redirectToUrl('back');
                            }
                        })
                        .catch(function(error) {
                            console.log(error);
                        });
                    }else{
                        component.find("utils").closeTab();
                        component.find("utils").redirectToUrl('back');
                    }}}),
            timeOut);        
    }
})