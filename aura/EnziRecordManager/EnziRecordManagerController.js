({
    doInit : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.find("utils").getIcons(function(response){
            component.set("v.icons",response);
            component.find("utils").execute("c.getLayout",{"recordId":component.get("v.recordId")},function(response){
                var data = JSON.parse(response);
                var layout;
                if(data.lstRecordTypes.length>0)
                    layout = JSON.parse(data.layout);
                else
                    layout = JSON.parse(data.layout).layouts[0];
                component.set("v.sObjectName",data.sObjectName);
                component.set("v.icon",component.get("v.icons")[data.sObjectName]);
                component.set("v.label",data.label);
                component.set("v.recordTypeId",data.recordTypeId);
                component.set("v.recordTypeName",data.recordTypeName?data.recordTypeName:'Default');
                component.set("v.recordName",data.recordName);
                component.set("v.record",{});
                var standardActions = [];
                var customActions = [];
                var topActions = [];
                var predefinedStandardActions = ["Edit","Delete","Clone","ChangeOwnerOne","ChangeRecordType"];
                for(var sa in layout.buttonLayoutSection.detailButtons){
                    if(layout.buttonLayoutSection.detailButtons[sa].custom){
                        if(component.get("v.topActions").indexOf(layout.buttonLayoutSection.detailButtons[sa].name)==-1){
                            customActions.push(layout.buttonLayoutSection.detailButtons[sa]);
                        }else{
                            topActions.push(layout.buttonLayoutSection.detailButtons[sa]);
                        }
                    }else{
                        if(predefinedStandardActions.indexOf(layout.buttonLayoutSection.detailButtons[sa].name)==-1 || (layout.buttonLayoutSection.detailButtons[sa].name=="ChangeRecordType" && data.lstRecordTypes.length==0)){
                            continue;
                        }
                        standardActions.push(layout.buttonLayoutSection.detailButtons[sa]);
                    }
                }
                component.set("v.standardActions",standardActions);
                component.set("v.customActions",customActions);
                component.set("v.topActionsObj",topActions);
                component.set("v.layout",layout);
                component.find("utils").hideProcessing();
                if(component.get("v.relatedDetails").length>0){
                    var query = "Select Id,"+component.get("v.relatedDetails").join(",")+" FROM "+component.get("v.sObjectName")+" WHERE Id='"+component.get("v.recordId")+"'";
                    component.find("utils").execute("c.getQueryData",{"query":query},function(response){
                        var relatedRecords = [];
                        for(var rel in component.get("v.relatedDetails")){
                            if(response[0][component.get("v.relatedDetails")[rel]]){
                                relatedRecords.push(response[0][component.get("v.relatedDetails")[rel]]);
                            }
                        }
                        component.find("utils").execute("c.describeById",{"lstIds":relatedRecords},function(response){
                            var relatedComponents = [];
                            for(var relcmp in response){
                                var cmp = {};
                                cmp.label = response[relcmp];
                                cmp.id = relcmp;
                                relatedComponents.push(cmp);
                            }
                            component.set("v.relatedDetailsComponent",relatedComponents);
                            component.find("utils").hideProcessing();
                        },function(error){
                            component.find("utils").showError(error)
                            component.find("utils").hideProcessing();
                        })
                        component.find("utils").hideProcessing();
                    })
                }
                
            },function(error){
                component.find("utils").showError(error);
                component.find("utils").hideProcessing();
            })
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })
        
        
    },
    newRecord:function(component, event, helper){
        var defaultValues = {};
        component.find("utils").addComponent("c:EnziForm",{"sObjectName":event.currentTarget.getAttribute("data-sobject"),"mode":"new","useLayout":true,"showModal":true,"defaultValues":defaultValues});
    },
    addRelation:function(component, event, helper){
        var defaultValues = {};
        defaultValues[event.currentTarget.getAttribute('data-parentfield')] = component.get("v.recordId");
        component.find("utils").addComponent("c:EnziForm",{"sObjectName":"AccountContactRelation","mode":"new","useLayout":true,"showModal":true,"defaultValues":defaultValues});
    },
    newTask:function(component, event, helper){
        var defaultValues = {};
        defaultValues[event.currentTarget.getAttribute('data-parentfield')] = component.get("v.recordId");
        component.find("utils").addComponent("c:EnziForm",{"sObjectName":"Task","mode":"new","useLayout":true,"showModal":true,"defaultValues":defaultValues});
    },
    newEvent:function(component, event, helper){
        var defaultValues = {};
        defaultValues[event.currentTarget.getAttribute('data-parentfield')] = component.get("v.recordId");
        component.find("utils").addComponent("c:EnziForm",{"sObjectName":"Event","mode":"new","useLayout":true,"showModal":true,"defaultValues":defaultValues});
    },
    newMeeting:function(component, event, helper){
        component.find("utils").showAlert("This event is not supported by Enzi Record Manager.");
    },
    logCall:function(component, event, helper){
        var defaultValues = {};
        defaultValues[event.currentTarget.getAttribute('data-parentfield')] = component.get("v.recordId");
        component.find("utils").addComponent("c:EnziForm",{"sObjectName":"Task","mode":"new","useLayout":true,"showModal":true,"defaultValues":defaultValues});
    },
    mailMerge:function(component, event, helper){
        component.find("utils").showAlert("This event is not supported by Enzi Record Manager.");
    },
    sendEmail:function(component, event, helper){
        component.find("utils").showAlert("This event is not supported by Enzi Record Manager.");
    },
    requestUpdate:function(component, event, helper){
        component.find("utils").showAlert("This event is not supported by Enzi Record Manager.");
    },
    viewAll:function(component, event, helper){
        component.find("utils").showAlert("This event is not supported by Enzi Record Manager.");
    },
    attach:function(component, event, helper){
        component.find("utils").showAlert("This event is not supported by Enzi Record Manager.");
    },
    addToCampaign:function(component, event, helper){
        var defaultValues = {};
        defaultValues[event.currentTarget.getAttribute('data-parentfield')] = component.get("v.recordId");
        component.find("utils").addComponent("c:EnziForm",{"sObjectName":"CampaignMember","mode":"new","useLayout":true,"showModal":true,"defaultValues":defaultValues});
    },
    defaultAction:function(component, event, helper){
        component.find("utils").showAlert("This event is not supported by Enzi Record Manager.");
    },
    toggleAction:function(component, event, helper){
        $A.util.toggleClass(document.getElementById('actionDropdown'),'slds-is-open');
    },
    manageCustomAction:function(component, event, helper){
        $A.util.toggleClass(document.getElementById('actionDropdown'),'slds-is-open');
        var id = parseInt(event.currentTarget.id.split(":")[1]);
        switch(component.get("v.customActions")[id].name){
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
            case "Lightning_Add_Opportunity":
                component.find("customActions").addOpportunity();
                break;
            case "Create_Opportunity":
                component.find("customActions").sendToEnterprise();
                break;
            default:
                component.find("utils").showAlert("Unsupported action.");
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
                component.find("utils").showAlert("Unsupported action.");
                break;
        }
        
    },
    manageStandardActions:function(component, event, helper){
        var id = parseInt(event.currentTarget.id.split(":")[1]);
        switch(component.get("v.standardActions")[id].name){
            case "Edit":
                component.find("utils").addComponent("c:EnziForm",{"sObjectName":component.get("v.sObjectName"),"mode":"edit","useLayout":true,"showModal":true,"recordId":component.get("v.recordId")});
                break;
            case "Clone":
                component.find("utils").addComponent("c:EnziForm",{"sObjectName":component.get("v.sObjectName"),"mode":"clone","useLayout":true,"showModal":true,"recordId":component.get("v.recordId")});
                break;
            case "Delete":
                component.find("utils").showConfirm("Are you sure you want to delete?",function(){
                    component.find("utils").showProcessing();
                    component.find("utils").execute("c.deleteRecord",{"recordToDelete":component.get("v.recordId")},function(response){
                        console.log('response===>'+response);
                        component.find("utils").hideProcessing();
                        component.find("utils").showSuccess('Record deleted successfully.');
                    },function(error){
                        console.log('In Error===>'+error);
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    })
                })
                break;
            case "ChangeOwnerOne":
                component.find("utils").addComponent("c:EnziChangeOwner",{"recordId":component.get("v.recordId"),"ownerId":component.get("v.record.OwnerId")});
                break;
            case "ChangeRecordType":
                component.find("utils").addComponent("c:EnziChangeRecordType",{"recordId":component.get("v.recordId"),"recordTypeId":component.get("v.record.RecordTypeId")});
                break;
        }
    },
    formSaved:function(component, event, helper){
        if(component.get('v.sObjectName') == event.getParam('sObjectName')){
            var record = JSON.parse(JSON.stringify(component.get("v.record")));
            for(var f in event.getParam('record')){
                record[f] = event.getParam('record')[f];
            }
            component.set("v.record",record);
        }
    }
})