({
    doInit : function(component, event, helper){
        component.set("v.utility", component.find("utils"));
        component.get("v.utility").showProcessing(); 
        component.get("v.utility").execute("c.getOnLoadAssignCaseToUserData", {"recordId":component.get("v.recordId")}, function(formData){
            component.set("v.sObjectRecord", formData["caseRecords"]);
            let settingReaponse  = JSON.parse(formData["settings"]);
            var user = JSON.parse(formData["userData"]);                
            component.set("v.loggedInUser", user[0]); 
            if(settingReaponse.profiles != null && settingReaponse.profiles != undefined) {
                var profiles = settingReaponse.profiles;
                if(profiles != null) {
                    profiles.forEach(function(profileName) {
                        if( profileName.toLowerCase() == user[0].Profile.Name.toLowerCase()) {
                            component.set("v.isProfileAllowed", true);
                        }
                    });
                }
                component.get("v.utility").hideProcessing();
            }
        }, function(error){
            helper.showMessage(component, 'error', error);
        }, component); 
    },
    showSelectUserModal : function (component, event, helper) {
        helper.showSelectUserModal(component, event, helper);
    },
    closeSelectUserModal : function (component, event, helper) {        
        helper.closeSelectUserModal(component, event, helper);
    },
    assignToMe : function (component, event, helper) {        
        var caseRec = component.get("v.sObjectRecord");
        var userRec = component.get("v.loggedInUser");
        var isProfileAllowed = component.get("v.isProfileAllowed");
        component.get("v.utility").showProcessing();
        if((caseRec.Status != "Closed") && (caseRec.OwnerId != userRec.Id) && (isProfileAllowed || caseRec.User_Profile__c.toLowerCase() == userRec.Profile.Name.toLowerCase())){
            component.get("v.utility").execute("c.UpdateCaseToUser",{"caseId": component.get("v.recordId"), "userId": userRec["Id"], "isProfileAllowed":isProfileAllowed},function(response){
                component.get("v.utility").hideProcessing();
                if(response){
                    var message;
                    if(caseRec.Opportunity__c != undefined){
                        message = "Congratulations, you are added as a team member on the opportunity. This case is assigned to you."; 
                    }else {
                        message = "This case is assigned to you.";
                    }
                    helper.showMessage(component, 'success', message); 
                    component.set('v.sObjectRecord.OwnerId',userRec["Id"]);
                } else {
                    component.get("v.utility").showError("This case is not assigned to you.");
                }
                helper.refresh(component, event, helper);
            }, function(error){
                helper.showMessage(component, 'error', error);
            }, component);
        }else{
            var errMessage;
            component.get("v.utility").hideProcessing();
            if(!(isProfileAllowed || caseRec.User_Profile__c == userRec.Profile.Name)){
                errMessage = "Sorry, your profile does not have permission to take this action.";
            }else if(caseRec.Status == 'Closed'){
                errMessage = "This case is closed and can not be re-assigned.";
            }else{
                errMessage = "This case is already assigned to you.";
            }
            component.get("v.utility").showError(errMessage);
        }  
    },
    getRelatedUsers : function (component, event, helper) {
        component.get("v.utility").showProcessing();
        component.set("v.selectedUserId", null);
        var caseRec = component.get("v.sObjectRecord");
        var userRec = component.get("v.loggedInUser");
        if((caseRec.Status != "Closed") && (component.get("v.isProfileAllowed") || (caseRec.User_Profile__c == userRec.Profile.Name))){
            var query = "SELECT Id, Name, Profile.Name, Username FROM User WHERE Profile.Name = '"+ component.get("v.utility").addSlashes(caseRec["User_Profile__c"]) +"' AND IsActive = true";
            component.get("v.utility").execute("c.getQueryData", {"query":query}, function(response){
                component.get("v.utility").hideProcessing();
                if(response.length > 1){
                    helper.showSelectUserModal(component, event, helper);
                    var indexToRemove;
                    for(var iIndex=0; iIndex < response.length; iIndex++ ){
                        if(response[iIndex]["Id"] == caseRec["OwnerId"]){
                            indexToRemove = parseInt(iIndex);
                            break;
                        }
                    }
                    if(indexToRemove != undefined){
                        response.splice(parseInt(indexToRemove), 1);
                    }
                    component.set("v.relatedUsers", response);
                } else if(response.length > 0){ 
                    if(response[0]["Id"] == caseRec["OwnerId"]){
                        component.get("v.utility").showError("There is no other suitable user for the profile.");
                    } else{
                        helper.showSelectUserModal(component, event, helper);
                        component.set("v.relatedUsers", response);
                    }
                } else{
                    component.get("v.utility").showError("There is no suitable user for the profile.");
                }
            }, function(error){
                helper.showMessage(component, 'error', error);
            });
        } else {
            helper.showMessage(component, 'error', !(component.get("v.isProfileAllowed") || (caseRec.User_Profile__c == userRec.Profile.Name)) ? "Sorry, your profile does not have permission to take this action." : "This case is closed and can not be re-assigned.");
        } 
    },
    assignCaseToUser : function (component, event, helper) {
        var userRec = component.get("v.loggedInUser");
        var caseRec = component.get("v.sObjectRecord");
        component.get("v.utility").showProcessing(); 
        component.get("v.utility").execute("c.UpdateCaseToUser",{"caseId":component.get("v.recordId"), "userId": component.get("v.selectedUserId"), "isProfileAllowed":component.get("v.isProfileAllowed")}, function(response){
            component.get("v.utility").hideProcessing();
            helper.closeSelectUserModal(component, event, helper);
            if(response){
                var message;
                if(caseRec.Opportunity__c != undefined){
                    message = "Congratulations, selected user is added as a team member on the Opportunity. This case has been assigned to the selected user successfully.";
                }else{
                    message = "This case is assigned to the selected user.";
                }
                helper.showMessage(component, 'success', message);
                component.set("v.sObjectRecord.OwnerId", component.get("v.selectedUserId"));
            }else
                component.get("v.utility").showError("This case is not assigned to the selected user.");
                helper.refresh(component, event, helper); 
        }, function(error){
            helper.showError(component, 'error', error);
        }, component);
    }
})