({
    doInit : function(component, event, helper) {
        component.find("utils").showProcessing();
        component.find("utils").execute("c.initialize",{"opportunityId":component.get("v.recordId")}, function(response){
            component.find("utils").hideProcessing();
            if(response){
                var reservableSetting = response;
                if(reservableSetting && reservableSetting['Setting'].hasOwnProperty('Data__c')){
                    component.set("v.settingData", JSON.parse(reservableSetting['Setting'].Data__c));
                }
                if(reservableSetting && reservableSetting.LoggedInUser){
                    component.set("v.LoggedInUser",reservableSetting.LoggedInUser);
                }
                if(response.currentDate){
                    component.set("v.objHoldReservable",{"startsDate":response.currentDate});
                    component.set("v.currentDate",response.currentDate);
                }
                if(reservableSetting && reservableSetting.hasOwnProperty('OpportunityData') && reservableSetting.OpportunityData){                            
                    component.set("v.entity",reservableSetting.OpportunityData);
                    helper.setHeadermeta(component);
                    if(reservableSetting.OpportunityData.Primary_Member__r)
                        component.set("v.mainContactInfo",reservableSetting.OpportunityData.Primary_Member__r);
                    if(reservableSetting.OpportunityData.Billing_Account__c){
                        if(reservableSetting.OpportunityData.Billing_Account__r.UUID__c){
                            component.set("v.mainContactInfo.company_uuid",reservableSetting.OpportunityData.Billing_Account__r.UUID__c);
                            component.set("v.mainContactInfo.company_name",reservableSetting.OpportunityData.Billing_Account__r.Name);
                        }
                    }
                    if(reservableSetting.OpportunityData.Building__c){
                        component.set("v.objHoldReservable.building",reservableSetting.OpportunityData.Building__c);
                        if(reservableSetting.OpportunityData && reservableSetting.OpportunityData.Building__r && reservableSetting.OpportunityData.Building__r.UUID__c){
                            var lstLocationUUIDS = [];
                            lstLocationUUIDS.push(reservableSetting.OpportunityData.Building__r.UUID__c);
                            component.set("v.selectedBuilding",reservableSetting.OpportunityData.Building__r);
                            helper.searchReservables(component, event, helper, component.get("v.currentDate"), lstLocationUUIDS, 1, 999, function(lstReservables){
                                component.set("v.buildingsReservables",lstReservables);
                                component.find("utils").hideProcessing();
                            });
                        }else{
                            component.find("utils").showError('UUID for the Selected Building Not Present In The System.');
                        }	  
                    }else{
                        component.find("utils").showWarning('Please select a building.');
                        component.find("utils").hideProcessing();
                    }
                }
            }
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        },component);
    },
    save:function(component, event, helper) {
        component.find("utils").showProcessing();
        var objHoldReservable = {};
        objHoldReservable.building_id = component.get("v.selectedBuilding").UUID__c;
        objHoldReservable.reservable_uuid = component.get("v.objHoldReservable.reservable");
        objHoldReservable.expires_at = component.get("v.objHoldReservable.tillDate");
        objHoldReservable.starts_at = component.get("v.objHoldReservable.startsDate");
        objHoldReservable.note = component.get("v.objHoldReservable.Notes");
		objHoldReservable.opportunity_id = component.get("v.recordId");
        var mainContactInfo = component.get("v.mainContactInfo");
        var buildingsReservables = JSON.parse(JSON.stringify(component.get("v.buildingsReservables")));
        objHoldReservable.contact_info = {};
        var index = buildingsReservables.findIndex(item => item.uuid==objHoldReservable.reservable_uuid);
        objHoldReservable.reservable_name = (buildingsReservables[index].location_name != null && buildingsReservables[index].location_name != '' && buildingsReservables[index].location_name != undefined) ? buildingsReservables[index].location_name : "";
		objHoldReservable.reservable_type = (buildingsReservables[index].type != null && buildingsReservables[index].type != '' && buildingsReservables[index].type != undefined) ? buildingsReservables[index].type : "";       
        if(mainContactInfo){
            objHoldReservable.contact_info.email = mainContactInfo.Email ? mainContactInfo.Email : "";
            objHoldReservable.contact_info.phone = mainContactInfo.Phone ? mainContactInfo.Phone : "";
            objHoldReservable.contact_info.contact_name = mainContactInfo.Name ? mainContactInfo.Name : "";
            objHoldReservable.contact_info.contact_uuid = mainContactInfo.UUID__c ? mainContactInfo.UUID__c : ""; 
            objHoldReservable.contact_info.company_uuid = mainContactInfo.company_uuid ? mainContactInfo.company_uuid : "";
            objHoldReservable.contact_info.company_name = mainContactInfo.company_name ? mainContactInfo.company_name : "";
        }
        console.log('objHoldReservable ::' +JSON.stringify(objHoldReservable));
        var settings = JSON.parse(JSON.stringify(component.get("v.settingData")));
        var url = settings.HoldReservableApi.url;
        var headers = {"Content-Type":"application/json","Authorization":settings.HoldReservableApi.Headers.Authorization,"CONTEXT_SALESFORCE_ID":component.get("v.LoggedInUser")};
        component.find("utils").execute("c.executeRest", {"method": "POST","endPointUrl": url,"headers": headers,"body": JSON.stringify(objHoldReservable)}, function(response){
            component.find("utils").hideProcessing();
            response = JSON.parse(response);
            if(response && response.office_hold){
                if(response.office_hold.active){
                    component.find("utils").showSuccess('Office Hold Record Successfully Created');
                    console.log('Office Status =>'+JSON.stringify(response.office_hold));
                }else{
                    component.find("utils").showSuccess('Office Hold Record Successfully Created With Inactive Status');
                } 
                setTimeout(function(){
                    helper.closeWindow(component,event,helper);
                }, 1500);
            }else if((response.hasOwnProperty("error")) && (response.hasOwnProperty("message"))){
                component.find("utils").showError(response.message);                           
            }else if(response.hasOwnProperty("error")){
                component.find("utils").showError(response.error);      
            } 
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        }); 
    },
    getReservablesOnStartDateChange: function(component, event, helper){
        helper.validationForHoldReservable(component,function(holdDurationStatus){
            if(!holdDurationStatus){
                helper.resetHoldForm(component);
                helper.getReservables(component, event, helper);
            }else{
                component.set("v.objHoldReservable.reservable",null);
                if(component.get("v.selectedBuilding") != null && component.get("v.selectedBuilding.UUID__c")){
                    helper.getReservables(component, event, helper);
                }else{
                    component.find("utils").showWarning('Please select a building.');
                }
            }
        });
    },
     close:function(component,event,helper){
		helper.closeWindow(component,event,helper);
    },
    getBuildingData:function(component,event,helper){
        component.set("v.objHoldReservable.reservable",null);
        if(component.get("v.objHoldReservable.building")){
            helper.setHeadermeta(component);
            if(component.get("v.objHoldReservable") && component.get("v.objHoldReservable.building")){
                var query = "SELECT Id, Name, UUID__c FROM Building__c WHERE Id ='"+component.get("v.objHoldReservable.building")+"'";
                component.find("utils").showProcessing();
                component.find("utils").execute("c.getQueryData", {"query":query}, function(response){
                    component.find("utils").hideProcessing();
                    if(response && response.length > 0){
                        if(response[0].UUID__c){
                            component.set("v.objHoldReservable.building",response[0].Id);
                            component.set("v.selectedBuilding",response[0]);
                            helper.resetHoldForm(component);
                            helper.getReservables(component, event, helper);
                        }else{
                            component.set("v.selectedBuilding",{});
                            component.set("v.objHoldReservable.building",null);
                            component.find("utils").showError('Selected Building '+response[0].Name+' does not have UUID.'); 
                        }
                    }
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                })
            }else{
                component.set("v.selectedBuilding",{});
                helper.resetHoldForm(component);
            }  
        }else{
            helper.resetHoldForm(component);
            component.find("utils").hideProcessing();
            component.find("utils").showWarning('Please select a building.');
        }
    },
    validateHoldDuration:function(component,event,helper){
        helper.validationForHoldReservable(component,function(holdDurationStatus){
            if(!holdDurationStatus){
                helper.resetHoldForm(component);
                helper.getReservables(component, event, helper);
            }else if(holdDurationStatus){
                if(component.get("v.objHoldReservable.tillDate") == null){
                    component.set("v.objHoldReservable.reservable",null);
                }
                if(component.get("v.selectedBuilding") != null && component.get("v.selectedBuilding.UUID__c")){
                    helper.getReservables(component, event, helper);
                }else{
                    component.find("utils").showWarning('Please select a building.');
                }
            }
        });
    }
})