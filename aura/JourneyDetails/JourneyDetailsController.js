({
    doInit : function(component, event, helper) {
        component.set("v.utils", component.find("utils"));
        component.get("v.utils").setTitle("Journey Details");
        component.get("v.utils").showProcessing();
        helper.getClosedStages(component, helper, event);
        helper.getLayout(component,component.get("v.recordId"),function(result){
            var data = result[0];
            var layout = result[1];
            component.set("v.journeyLayoutDetails",data);
            component.set("v.sObjectName",data.sObjectName);
            component.set("v.label",data.label);
            component.set("v.recordTypeId",data.recordTypeId);
            component.set("v.recordTypeName",data.recordTypeName?data.recordTypeName:'Default');
            component.set("v.recordName",data.recordName);
            component.set("v.record",{});
            
            helper.setActions(component,layout.buttonLayoutSection.detailButtons,component.get("v.predefinedStandardActions"),component.get("v.topActions"),data);
            component.set("v.journeyLayout",layout);
            component.get("v.utils").hideProcessing();        
        });
            
    },
    handleActive:function(component, event, helper){
        helper.lazyLoadTabs(component,helper,event);
    },
    manageStandardActions:function(component, event, helper){
        component.get("v.utils").showProcessing();
        var id = parseInt(event.currentTarget.id.split(":")[1]);
        switch(component.get("v.standardActions")[id].name){
            case "Edit":
                if(component.get("v.phase") == "phase1")
                    component.set("v.mode","EDIT");
                else
                    component.set("v.relatedMode","EDIT");
                break;
            case "Clone":
                component.get("v.utils").addComponent("c:EnziForm",{"sObjectName":component.get("v.sObjectName"),"mode":"clone","useLayout":true,"showModal":true,"recordId":component.get("v.recordId")});
                break;
            case "Delete":
                component.get("v.utils").showConfirm("Are you sure you want to delete?",function(){
                    component.get("v.utils").showProcessing();
                    component.get("v.utils").execute("c.deleteRecord",{"recordToDelete": (component.get("v.phase") == "phase1") ? component.get("v.recordId") : component.get("v.releatedRecordId")},function(response){
                        console.log('response===>'+response);
                        component.get("v.utils").hideProcessing();
                        component.get("v.utils").showSuccess('Record deleted successfully.');
                        if(typeof(sforce) != "undefined" && sforce && sforce.console && sforce.console.isInConsole())
                            component.get("v.utils").closeTab();
                        else
                            component.get("v.utils").redirectToUrl(window.location.href.split('.com')[0]+'.com/a0j/o');
                    },function(error){
                        console.log('In Error===>'+error);
                        component.get("v.utils").hideProcessing();
                        component.get("v.utils").showError(error);
                    })
                })
                break;
            case "ChangeOwnerOne":
                var lstRecord =  (component.get("v.phase") == "phase1") ? [component.get("v.recordId"),component.get("v.record.OwnerId")] : [component.get("v.releatedRecordId"),component.get("v.relatedRecord.OwnerId")];
                component.get("v.utils").addComponent("c:EnziChangeOwner",{"recordId":lstRecord[0],"ownerId":lstRecord[1],"redirectToUrl": "/apex/RecordManager?id="+component.get("v.recordId")});
                break;
            case "ChangeRecordType":
                component.get("v.utils").addComponent("c:EnziChangeRecordType",{"recordId":component.get("v.recordId"),"recordTypeId":component.get("v.record.RecordTypeId")});
                break;
        }
        component.find('utils').hideProcessing();
    },
    manageCustomAction:function(component, event, helper){
        $A.util.toggleClass(document.getElementById('actionDropdown'),'slds-is-open');
        var id = parseInt(event.currentTarget.id.split(":")[1]);
        var name = component.get("v.customActions")[id].name;
        if(name == "Availability" && component.get("v.phase") == 'phase2')
            name = "relatedAvailability";
        switch(name){
            case "Follow_Up":
                component.find("customActions").followUpCall();
                break;
            case "Log_A_Call":
                component.find("customActions").logCall();
                break;
            case "Marketing_Drip":
                component.find("customActions").addToCampaign();
                break;
            case "Send_To_Enterprise":
                component.find("customActions").sendToEnterprize();
                break;
            case "Unqualify":
                component.find("customActions").unqualify();
                break;
            case "Lightning_Manage_Book_a_Tour":
                component.find("customActions").manageTours('/apex/BookTours?journeyId='+component.get("v.recordId"));
                break;
            case "Manage_Book_a_Tour_Referrer":
                component.find("customActions").manageToursFromLead(component.get("v.releatedRecordId"),'/apex/BookTours?leadId='+component.get("v.releatedRecordId"));
                break;
            case "Refresh":
                component.find("customActions").refresh();
                break;
            case "Restart_Journey":
                component.find("customActions").restartJourney();
                break;
            case "Availability": 
                component.find("customActions").availiblity();
                break;
            case "Add_Opportunity":
                component.find("customActions").addOpportunity();
                break;
            case "Lightning_Add_Opportunity":
                component.find("customActions").addOpportunity();
                break;
            case "Create_Opportunity":
                component.find("customActions").sendToEnterprise();
                break;
            case "Send_to_Enterprise":
                component.find("customActions").sendToEnterpriseFromLead(component.get("v.releatedRecordId"),'/apex/CreateOpportunity?id='+component.get("v.releatedRecordId"));
                break;
            case "Convert_Broker_Lead": 
                if(component.get('v.record.Status__c')=='Unqualified'){
                    component.get("v.utils").showError('No further actions possible as the Journey is unqualified.');
                }else{
                    component.set("v.warningMessage","");
                    component.set("v.showConvertBrokerModal",true);
                }
                break;    
            case "Convert_Broker_Lead_javascript":
                if(component.get("v.record.Status__c")=="Unqualified"){
                    component.get("v.utils").showError("No further actions possible as the Journey is unqualified.");
                }else if(component.get("v.record.Primary_Contact__c")){
                    if(!component.get("v.closedJourneyStages").includes(component.get("v.record.Status__c").toLowerCase())){
                        component.set("v.record.Status__c", "Completed");
                        component.get("v.utils").showProcessing();
                        component.get("v.utils").execute("c.saveJourney", {"record": component.get("v.record")}, function(result){
                            if(result){
                                component.get("v.utils").showSuccess("Successfully updated the Journey status to Completed.");
                                setTimeout(function(){
                                    component.find("weform").reloadRecord();
                                },2000);
                            }
                            component.get("v.utils").hideProcessing();
                        },function(error){
                            component.get("v.utils").hideProcessing();
                            component.get("v.utils").showError(error);
                        },component);
                    }else{
                        component.get("v.utils").showError("You can not hand off Journeys that have been closed or completed.");
                    }
                }else{
                    component.set("v.warningMessage","");
                    component.set("v.showConvertBrokerModal",true);
                }
                break;  
            case "Create_Opportunity":
                component.get("v.utils").redirectToUrl('/apex/CreateOpportunity?id='+component.get("v.releatedRecordId"));
                break;
            case "Lightning_Manage_Tours":
                component.get("v.utils").redirectToUrl('/apex/BookTours?contactId='+component.get("v.releatedRecordId"));
                break;
            case "relatedAvailability":
                component.get("v.utils").redirectToUrl('/apex/availability?sfdc.tabName=01rF00000015D05&contactid='+component.get("v.releatedRecordId"));
                break;
            default:
                component.get("v.utils").showAlert("Unsupported action.");
                break;
        }
    },
    manageTopAction:function(component, event, helper){
        $A.util.toggleClass(document.getElementById('actionDropdown'),'slds-is-open');
        var id = parseInt(event.currentTarget.id.split(":")[1]);
        switch(component.get("v.topActionsObj")[id].name){
            case "Follow_Up":
                component.find("customActions").followUpCall();
                break;
            case "Log_A_Call":
                component.find("customActions").logCall();
                break;
            case "Marketing_Drip":
                component.find("customActions").addToCampaign();
                break;
            case "Send_To_Enterprise":
                component.find("customActions").sendToEnterprize();
                break;
            case "Unqualify":
                component.find("customActions").unqualify();
                break;
            case "Manage_Tours":
                component.find("customActions").manageTours();
                break;
            case "Refresh":
                component.find("customActions").refresh();
                break;
            case "Restart_Journey":
                component.find("customActions").restartJourney();
                break;
            case "Availability":
                component.find("customActions").availiblity();
                break;
            case "Add_Opportunity":
                component.find("customActions").addOpportunity();
                break;
            default:
                component.get("v.utils").showAlert("Unsupported action.");
                break;
        }
        
    },
    toggleAction:function(component, event, helper){
        $A.util.toggleClass(document.getElementById('actionDropdown'),'slds-is-open');
    },
    saveRecord:function(component, event, helper){
        component.find('utils').showProcessing();
        component.find((component.get("v.phase") == "phase1") ? 'weform':'weform1').saveRecord(function(response){
            component.find('utils').showSuccess(response);
            helper.switchToViewMode(component);
            component.find('utils').hideProcessing();
        },function(error){
            component.find('utils').showError(error);
            component.find('utils').hideProcessing();
        });
    },
    close:function(component, event, helper){
        component.find('utils').showProcessing();
        helper.switchToViewMode(component);
        component.find('utils').hideProcessing();
    },
    changePhase:function(component, event, helper){
        helper.changePhase(component,helper,event);
    },
    closeAction:function(component, event, helper){
        component.set("v.showConvertBrokerModal",false);
    },
    verifyAndShowAccountSelector:function(component, event, helper){
        component.get("v.utils").showProcessing();
        component.find("customActions").verifyBrokerLead(component.get("v.record.Primary_Lead__c"), component, function(response){
            component.get("v.utils").hideProcessing();
            component.set("v.relatedLeadRecord",response);
            component.get("v.utils").execute("c.getJourneyToUpdate", {"leadId": component.get("v.record.Primary_Lead__c")}, function(response){
                if(response && response[0] && response[0].Id){
                    component.set("v.updateJourneyStatusId", response[0].Id);
                }
                component.set("v.showConvertBrokerModal",false);
                component.set("v.showAccountSelector",true);
            },function(error){
                component.get("v.utils").hideProcessing();
                component.set("v.warningMessage",error);
            }, component);
        },function(error){
            component.get("v.utils").hideProcessing();
            component.set("v.warningMessage",error);
        });
    },
    convertBrokerLead:function(component, event, helper){
        component.get("v.utils").showProcessing();
        component.set("v.spinnerWithoutContainer",true);
        component.set("v.showAccountSelector",false);
        component.set("v.showConvertBrokerModal",true);
        component.set("v.warningMessage", "Lead Conversion is in process. Please Wait.");
        component.get("v.relatedLeadRecord")["Account__c"] = component.get("v.selectedAccount")["Id"];
        component.find("customActions").convertBrokerLead(component.get("v.relatedLeadRecord"), component.get("v.updateJourneyStatusId"), component.get("v.isNewAccountCreated"), component, function(response){
            component.set("v.spinnerWithoutContainer",false);
            component.get("v.utils").hideProcessing();
            component.set("v.warningMessage","Lead Converted successfully.");
            if(sforce && sforce.one){
                sforce.one.navigateToURL("/"+response,true);
            }else{
                component.get("v.utils").redirectToUrl("/"+response);    
            }
        },function(error){
            component.get("v.utils").hideProcessing();
            component.set("v.spinnerWithoutContainer",false);
            component.set("v.showConvertBrokerModal",false);
            component.find('utils').showError(error);
        });
    }  
})