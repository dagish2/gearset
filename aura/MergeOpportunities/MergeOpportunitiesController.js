({
    doInit : function(component, event, helper) {
        component.set("v.utils", component.find("utils"));
        component.get("v.utils").showProcessing();
        helper.getMergeOpportunityData(component,function(userInfo){
            if(userInfo){
                helper.isOwnershipProfile(component, function(isOwnershipProfile){
                    component.set("v.isOwnershipProfile", isOwnershipProfile);
                    helper.setDisplayFields(component, helper);
                    helper.setView(component,helper, function(message){
                        component.find("instructionModel").showModal();
                        component.get("v.utils").hideProcessing();
                    },function(error){
                        component.get("v.utils").hideProcessing();
                        component.get("v.utils").showError(error);
                    });
                });
            }
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        })
    },
    closeInstructionModel:function(component, event, helper){
        component.find("instructionModel").closeModal();
    },
    handleRowAction:function(component, event, helper){
        var record = event.getParam('record');
    },
    next:function(component, event, helper){
        if(component.get("v.selectedOpportunities").length >= 2){
          component.set("v.stage", 1);
          component.set("v.btnLabel", "Merge");
            helper.setView(component, helper, function(message){
                component.get("v.utils").hideProcessing();
            },function(error){
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError(error);
            });
        }else{
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError('Please select at least two opportunities to merge');
        }
    },
    prev:function(component, event, helper){
        component.get("v.utils").showProcessing();
        component.set("v.stage", 0);
        component.set("v.btnLabel", "Next");
        component.set("v.btnIcon", "utility:forward");
        component.set("v.selectedOpportunities", []);
        component.set("v.selectedOpportunitiesToMerge", []);
        helper.setDisplayFields(component, helper);
        helper.setView(component, helper, function(message){
            component.get("v.utils").hideProcessing();
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        });
    },
    close:function(component, event, helper){
        component.get("v.utils").showConfirm("Are you sure you want to close the page?",function(){
            if(sforce && sforce.console && sforce.console.isInConsole())
                component.get("v.utils").closeTab();
            history.go(-1);
        });
    },
    MergeOpprtunity:function(component, event, helper){
        if(component.get("v.selectedOpportunitiesToMerge")  && component.get("v.selectedOpportunitiesToMerge").length){
            helper.validateOpportunities(component, event, helper);
        }else{
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError('Please select a Primary opportunity');
        }
    }
})