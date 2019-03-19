({
    getMergeOpportunityData: function(component, onsuccess, onerror) {
        component.get("v.utils").execute("c.getMergeOpportunitySettings",{}, function(response){
 			var response = JSON.parse(response);
            component.set("v.mapUserInfo",response.lstUser[0]); 
            component.set("v.settingData",JSON.parse(response.getMergeOpportunitySetting.Data__c));
            onsuccess(response.lstUser);
        },function(error){
            onerror(error);
        },component);
    },
    getOpportunities:function(component, query, onsuccess, onerror){
        component.get("v.utils").execute("c.getQueryData",{"query":query}, function(response){
            var opportunities = JSON.parse(response[0]);
            onsuccess(opportunities);
        },function(error){
            onerror(error);
        })
    },
    setDisplayFields:function(component, helper){
        var opportunityColumns = [];
        opportunityColumns.push({"fieldName": "OwnerId","sortable": true, "label" : "Opportunity Owner", type:"url",typeAttributes:{ label: { fieldName : 'Owner.Name'}}});
        opportunityColumns.push({"fieldName": "Segment__c", "label" : "Segment", "type" : "String","sortable": true});
        opportunityColumns.push({"fieldName": "Id", "label" : "Opportunity Id", "type" : "String","sortable": true});
        opportunityColumns.push({"fieldName": "Id","label" : "Name","sortable": true, type : "url",typeAttributes:{ label: { fieldName : 'Name'}} });
        opportunityColumns.push({"fieldName": "StageName", "label" : "Stage", "type" : "text","sortable": true});
        opportunityColumns.push({"fieldName": "Primary_Member__c","sortable": true, "label" : "Main Contact", type : "url",typeAttributes:{ label: { fieldName : 'Primary_Member__r.Name'}}});
        opportunityColumns.push({"fieldName": "Billing_Account__c","sortable": true, "label" : "Billing Account", type : "url",typeAttributes:{ label: { fieldName : 'Billing_Account__r.Name'}}});
        opportunityColumns.push({"fieldName": "CloseDate", "label" : "Close Date", "type" : "date","sortable": true});
        opportunityColumns.push({"fieldName": "CurrencyIsoCode", "label" : "Opportunity Currency", "type" : "string","sortable": true});
        component.set("v.opportunityMetaFields", opportunityColumns);
    },
    isOwnershipProfile:function(component, onSuccess){
        var currentUserProfile = component.get("v.mapUserInfo.Profile").Name.toLowerCase();
        var lstOwnershipProfile=component.get("v.settingData.OwnershipProfiles").map(r => r.toLowerCase());
        onSuccess(lstOwnershipProfile.indexOf(currentUserProfile)>-1?true:false);
    },
    setView:function(component, helper, onSuccess){
        if(component.get("v.stage") == 0){
            var query="SELECT Id, Name, Account.Name, AccountId, StageName,CurrencyIsoCode, Account.OwnerId, CloseDate, Segment__c, Billing_Account__c, Billing_Account__r.Name, Primary_Member__c, Primary_Member__r.Name, Owner.Name FROM Opportunity ";
            if(!component.get("v.isOwnershipProfile")){
                query +="WHERE Stagename IN "+helper.getOppStages(component, helper)+" AND OwnerId ='"+component.get("v.mapUserInfo.Id")+"'";
                query += " AND StageName !='Merged'";
            }else{
                query += " WHERE StageName !='Merged'"; 
            }
            component.set("v.query", query);
            component.set("v.NotMergedOpportunity" , 2);
            component.set("v.stage", 1);
            onSuccess('true');
        } else if(component.get("v.stage") == 1){
            if(component.get("v.selectedOpportunities").length){
                component.set("v.NotMergedOpportunity", 3);
                component.set("v.btnIcon", "utility:merge");
                component.set("v.SelectedMergedOpportunityData", component.get("v.selectedOpportunities"));
            }
        }
    },
    getOppStages:function(component, helper){
        var OppStages = component.get("v.settingData.OppStages");
        var strOppStages = "(";
        strOppStages += OppStages.length ? ( "'" + OppStages.join("', '") + "'" ) : '';
        strOppStages += ")";
        return strOppStages;
    },
    validateOpportunities:function(component, event, helper){
        var lstSelectedOpp = component.get("v.SelectedMergedOpportunityData");
        var objPrimaryOpp = lstSelectedOpp[lstSelectedOpp.findIndex(r => r.Id==component.get("v.selectedOpportunitiesToMerge")[0].Id)];
        if(!component.get("v.isOwnershipProfile")){
            var isSameAccount = true;
            for(var selectedOpp in lstSelectedOpp){
                if(lstSelectedOpp[selectedOpp].AccountId !=objPrimaryOpp.AccountId){
                    if(lstSelectedOpp[selectedOpp].Account.OwnerId != component.get("v.mapUserInfo.Id")){
                        isSameAccount = false;
                        break;
                    }
                }
            }
            for(var selectedOpp in lstSelectedOpp){
                var subLstSelected = lstSelectedOpp.slice(lstSelectedOpp.findIndex(r => r.Id == lstSelectedOpp[selectedOpp].Id));
                for(var subListedOpp in subLstSelected){
                    if(lstSelectedOpp[selectedOpp].AccountId!=subLstSelected[subListedOpp].AccountId && lstSelectedOpp[selectedOpp].Billing_Account__c != subLstSelected[subListedOpp].Billing_Account__c){
                        isSameAccount = false;
                        break;
                    }
                }
                if(!isSameAccount){
                    break;
                }                    
            }
            if(!isSameAccount){
                for(var selectedOpp in lstSelectedOpp){
                    var subLstSelected = lstSelectedOpp.slice(lstSelectedOpp.findIndex(r => r.Id == lstSelectedOpp[selectedOpp].Id));
                    for(var r in subLstSelected){
                        if(lstSelectedOpp[selectedOpp].Account.OwnerId==subLstSelected[r].Account.OwnerId && subLstSelected[r].Account.OwnerId==component.get("v.mapUserInfo.Id")){
                            isSameAccount = true;
                        }else{
                            isSameAccount = false;
                            break;
                        }
                    }
                    if(!isSameAccount){
                        break;
                    }
                }
            }
            if(!isSameAccount){
                component.get("v.utils").showError("You can't merge the opportunities having different account")
            }else{
                helper.mergeOpportunities(component, event, helper);
            }
        }else{
            helper.mergeOpportunities(component, event, helper);
        }
    },
    mergeOpportunities:function(component, event, helper){
        var selectedOppIds=[];
        var idPrimaryOppty = component.get("v.selectedOpportunitiesToMerge")[0].Id;
        var lstSelectedOppty = component.get("v.SelectedMergedOpportunityData");
        var lstSelectedOppIds = [];
        for(var o in lstSelectedOppty){
            lstSelectedOppIds.push(lstSelectedOppty[o].Id);
        }
        component.get("v.utils").showConfirm("You are about to merge all the Secondary Opportunity(s) into Primary Opportunity, these changes can not be undone. Are you sure to continue?",function(){
            component.get("v.utils").showProcessing();
            component.get("v.utils").execute("c.mergeOpportunities",{"mergeOppIds":JSON.stringify(lstSelectedOppIds),"primaryOpprtunity":idPrimaryOppty},function(response){
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showSuccess("Opportunity Merged Successfully. Redirecting you to the Primary Opportunity.");
                helper.redirect(component,event,helper);
            },function(error){
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError(error);
            } , component);
        });
    },
    redirect:function(component, event, helper){
        setTimeout(function(){
            if(sforce && sforce.console && sforce.console.isInConsole()){
                component.get("v.utils").closeTab();
                sforce.console.openPrimaryTab(null, "/"+component.get("v.selectedOpportunitiesToMerge")[0].Id, true, "");
                history.go(-1);
            }else{
                component.get("v.utils").redirectToUrl("/"+component.get("v.selectedOpportunitiesToMerge")[0].Id,'',false);
            }
            
        },1000)
    }
})