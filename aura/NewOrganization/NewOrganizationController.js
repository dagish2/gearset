({
	doInit : function(component, event, helper){
        component.set("v.previous", {
            "label": "Previous",
            "click": component.getReference("c.previous")
        });
        var instructions = [];
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getNewOrganizationData", { } ,function(response){                    
            if(response.instructions){                        
                component.set("v.mapInstructions", response.instructions);
            }
            component.set("v.canCreateOrg", response.isUserCreateOrg);
            component.set("v.canCreateEnterpriseOrg", response.isUserCreateEnterpriseOrg);
            helper.changeHeaderAndInstructions(component, "Search Organization");
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").hideProcessing();            
            component.find("utils").showError(error);
        }, component);
        
	},
    next : function(component,event,helper){
        if(component.get("v.canCreateOrg")){
            helper.addHideClass( component, "searchOrganization");
            helper.removeHideClass( component, "createNewOrganization");
            helper.changeHeaderAndInstructions(component, "Create New Organization");
        }else{
            helper.addHideClass( component, "searchOrganization");
            helper.removeHideClass( component, "requestNewOrganization");
            helper.changeHeaderAndInstructions(component, "Request New Organization");
        }
        component.set("v.previous", {
            "label": "Previous",
            "click": component.getReference("c.previous")
        });
    },
    previous : function(component,event,helper){
        helper.removeHideClass( component, "searchOrganization");
        if(component.get("v.canCreateOrg")){
            helper.addHideClass( component, "createNewOrganization");
        }else{
            helper.addHideClass( component, "requestNewOrganization");
        }
        helper.changeHeaderAndInstructions( component, "Search Organization");
    },
    close : function(component,event,helper){
        component.find("utils").showConfirm("Are you sure you want close this page ?",function(){
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
            }
        });
        
        
    },
    useExistingOrg: function(component, event, helper){
        if(JSON.parse(component.get("v.isInLightningConsole"))){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.isConsoleNavigation().then(function(response) {
                console.log(response);
                if(response){
                    workspaceAPI.openTab({
                        recordId: component.get("v.selectedOrgId"),
                        focus: true
                    }).then(function(response) {
                        workspaceAPI.getEnclosingTabId().then(function(tabId) {
                            workspaceAPI.closeTab({tabId: tabId});
                        })
                        component.find("utils").closeTab();                	
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                } else {
                    //component.find("utils").closeTab();
                    component.find("utils").redirectToUrl("/"+component.get("v.selectedOrgId"), '', false);
                }
            })
            .catch(function(error) {
                console.log(error);
            });
        }else{
            //component.find("utils").closeTab();
            component.find("utils").redirectToUrl("/"+component.get("v.selectedOrgId"), '', false);
        }
    }
})