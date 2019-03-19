({
    click : function(component, event, helper) {
        if(event.button < 2){
            if(component.get("v.isWebsite")){
                var website = component.get("v.value");
                if(!website.includes("http")){
                    website = "http://" + component.get("v.value");
                }
                window.open(website,"_blank");
            }else{
                if(sforce && sforce.console && sforce.console.isInConsole()){
                    sforce.console.openPrimaryTab(null,"/"+component.get("v.value"),true,null);
                }else{
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.isConsoleNavigation().then(function(response) {
                        if(response){
                            workspaceAPI.openTab({
                                recordId: component.get("v.value"),
                                focus: true
                            }).then(function(response) {
                                workspaceAPI.getTabInfo({
                                    tabId: response
                                }).then(function(tabInfo) {
                                    console.log("The url for this tab is: " + tabInfo.url);
                                });
                            })
                        }else if(sforce && sforce.console && sforce.console.isInConsole()){
                            sforce.console.openPrimaryTab(null,"/"+component.get("v.value"),true,null);
                        }else {
                            window.open("/"+component.get("v.value"),"_blank");
                        }
                    }) 
                    .catch(function(error) {
                        console.log(error);
                    });
                }
            }
        } 
    }
})