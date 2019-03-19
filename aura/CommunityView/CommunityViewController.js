({
    doInit:function(component, event, helper){
        component.set("v.helperModules.utils", component.find("utils"));
        component.set("v.helperModules.soslComponentInstantTour", component.find("soslComponentInstantTour")); 
        component.set("v.helperModules.EnziValidate", component.find("EnziValidate"));
        component.set("v.helperModules.TourExternalAPI", component.find("TourExternalAPI"));
        component.set("v.expandSections.instantTourProfile", false);
        component.set("v.expandSections.instantTourInformation", false);
        if(component.get("v.urlData")){
            helper.setFilters(component, event, helper);
        }
        helper.setExpressionObj(component, event, helper);
        var buildindId;
        if(component.get("v.url_building")){
            buildindId = component.get("v.url_building");
            component.set("v.url_building",null);
        }else if(component.get("v.building")){
            buildindId = component.get("v.building");
        }
        if(buildindId == undefined || buildindId){
            component.find("utils").showProcessing();
            component.find("utils").execute("c.getOnLoadCommunityViewData",{"startDate":component.get("v.startDate"),"endDate":component.get("v.endDate"),"selectedStatus":component.get("v.selectedStatus"),"bookedBy":component.get("v.bookedBy"),"assignHost":component.get("v.assignHost"),"buildingId":buildindId ? buildindId.trim() : '',"companyName":component.get("v.companyName")},function(response){
                setTimeout(function(){component.find("utils").hideProcessing();},4000);
                if(response){
                    var response = JSON.parse(component.find("utils").removeSpecialCharacters(response));
                    if(response.BuildingInfo && response.BuildingInfo.length > 0){
                        component.set("v.isExpandedFilters",true);
                        component.set("v.isExpandedTourTable",true);
                        component.set("v.buildingInfo",response.BuildingInfo[0]);
                        component.set("v.building",response.BuildingInfo[0].Id);
                    }else{
                        component.find("utils").showWarning('Please select a building.');
                    }
                    if(response.CommunityViewAPISetting){
                        component.set("v.setting",JSON.parse(response.CommunityViewAPISetting.Data__c));
                        helper.setTourMetaFields(component,event,helper);
                    }else{
                        component.find("utils").showError('CommunityViewAPISetting sales console setting not loaded contact your System Administrator');
                    }
                    if(response.TodayTours && response.TodayTours.success && response.TodayTours.data){
                        component.set("v.records",[]);
                        component.set("v.records",JSON.parse(response.TodayTours.data));
                    }
                    if(response.AllWeWorkBuildings && response.AllWeWorkBuildings.length){
                        component.set("v.AllWeWorkBuildings", response.AllWeWorkBuildings);
                    }
                    if(response.ServerDates && response.ServerDates.TodaysDate){
                        if(!component.get("v.startDate")){
                            component.set("v.startDate",response.ServerDates.TodaysDate);
                            component.set("v.endDate",response.ServerDates.TodaysDate);
                        }
                    }
                    if(component.get("v.building") && response.ServerDates && response.ServerDates.BuildingTimeZoneDate){
                        response.ServerDates.BuildingTimeZoneDate = response.ServerDates.BuildingTimeZoneDate.split('T')[0];    
                    }else{
                        response.ServerDates.BuildingTimeZoneDate = response.ServerDates.TodaysDate;
                    }
                    component.set("v.serverDates",response.ServerDates);
                    if(response.loggedInUserInfo){
                        component.set("v.loggedInUserInfo",response.loggedInUserInfo);
                        helper.subscribeTourOutcomePushTopic(component,event,helper);
                    }
                }
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            },component);
        }else{
            component.set("v.isExpandedFilters",false);
            component.set("v.isExpandedTourTable",false);
            setTimeout(function(){  component.set("v.records",[]); }, 1000);
            component.find("utils").showWarning('Please select a building.');
        } 
    },
     getSelectedBuildingTourData:function(component, event, helper){
        if(component.get("v.building") != ""){
            component.find("utils").showProcessing();
            component.find("utils").execute("c.getSelectedBuildingTourRelatedDataAndUpdateUser",{"locationId":component.get("v.building")},function(response){
                component.find("utils").hideProcessing();
                var response = JSON.parse(response.replace(/\r?\n|\r/g,""));
                if(response.BuildingInfo && response.BuildingInfo.length > 0){
                    component.set("v.isExpandedFilters",true);
                    component.set("v.isExpandedTourTable",true);
                    component.set("v.buildingInfo",response.BuildingInfo[0]);
                    component.set("v.building",response.BuildingInfo[0].Id);
                }else{
                    component.find("utils").showWarning('Please select a building.');
                    component.find("utils").hideProcessing();
                }
                if(response.TodayTours && response.TodayTours.success && response.TodayTours.data){
                    component.set("v.records",[]);
                    component.set("v.records",JSON.parse(response.TodayTours.data));
                }
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            },component);
        }else{
            component.set("v.isExpandedFilters",false);
            component.set("v.isExpandedTourTable",false);
            setTimeout(function(){  component.set("v.records",[]); }, 1000);
            component.find("utils").showWarning('Please select a building.');
        }
    },
    openNewLeadModule:function(component, event, helper){
        component.set("v.leadFormData",{"Phone":component.get("v.phone"),"sobjectType":"Lead","LeadSource":"Walk In","Lead_Source_Detail__c":"Community Registration","Building_Interested_In__c":component.get("v.buildingInfo.Id")});
        component.find("NewLeadModal").showModal();
    },
    openScheduleTourModule:function(component, event, helper){
        document.getElementById("searchLeadorContact").value = "";
        component.set("v.instantTour.building", component.get("v.building"));
        component.set("v.showAccountSelector", false);
        component.find("InstantTourModal").showModal();
        component.find("utils").showWarning('Please select a Lead or Contact.');
        component.set("v.instantTour.tourDate", component.get("v.serverDates").BuildingTimeZoneDate);
        component.set("v.hideMsg", true);
        component.set("v.instantValid", false);
    },
    openNewLeadModuleForInstantTour:function(component, event, helper){
        document.getElementById("searchLeadorContact").value = "";
        component.set("v.selectedObject.type", "newlead");
        component.set("v.showFTE", true);
        component.set("v.hideMsg", false);
        let searchedString = component.get("v.helperModules.soslComponentInstantTour").get("v.keyword");
        let Email =null, Name=null;
        if(searchedString){
            if(!component.get("v.helperModules.EnziValidate").validateFromOtherComponent("email", searchedString)){
                Email = searchedString;
            }else{
                Name = searchedString;
            }
        }
        helper.setInstantTour(component, helper, {"contactId":null, "AccountId":null, "type":"newlead", "Name":Name, "Company":null, "Number_of_Full_Time_Employees__c":null, "Interested_in_Number_of_Desks__c":null, "Email":Email, "Phone":null});
        component.set("v.expandSections.instantTourProfile", true);
        component.set("v.expandSections.instantTourInformation", true);
        helper.loadtimeSlotsForTours(component, event, helper, function(timeSlotsOfToday){
            if(timeSlotsOfToday && timeSlotsOfToday.length){
                component.set("v.instantTour.startTime", timeSlotsOfToday[0].time); 
            }
        });
    },
    closeInstantTourModal:function(component, event, helper){
        component.get("v.helperModules.soslComponentInstantTour").set("v.keyword",'');
        helper.setInstantTour(component, helper, null);
        component.find("InstantTourModal").close();
    },
    createNewLead:function(component, event, helper){
        var lstRecords = [];
        var leadFormData = JSON.parse(JSON.stringify(component.get("v.leadFormData")));
        var query = "SELECT Id, Name FROM Building__c WHERE Id= '"+leadFormData.Building_Interested_In__c+"'";
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":query},function(resp){
            if(resp != undefined && resp.length){
                leadFormData.Lead_Assignment_Stage__c = "1000";
                leadFormData.Locations_Interested__c = resp[0].Name +';';
                lstRecords.push(leadFormData);
                component.find("utils").execute("c.saveRecords",{"records":lstRecords},function(response){
                    component.find("utils").showSuccess('Lead created successfully.');
                    component.find("NewLeadModal").close();
                    helper.clearLeadFields(component, event, helper);
                    component.find("utils").hideProcessing();
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                })
            }
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    showLeadModal:function(component, event, helper){
        component.set("v.tourData",JSON.parse(event.currentTarget.getAttribute('data-value')));
        component.set("v.leadFormData",{"Phone":component.get("v.phone"),"sobjectType":"Lead","LeadSource":"Walk In","Building_Interested_In__c":component.get("v.buildingInfo.Id")});
        component.find("NewLeadModal").showModal();
    },
    closeLeadModal:function(component, event, helper){
        helper.clearLeadFields(component, event, helper);
        component.find("NewLeadModal").close();
    },
    openManageTourModule:function(component, event, helper){
        let selectedRecord = component.get("v.selectedObject");
        let contactOrLead =  (selectedRecord.leadId != null) ? 'leadId' : 'contactId';
        let tourDate= component.get("v.instantTour.tourDate") ? component.get("v.instantTour.tourDate") : component.get("v.serverDates").BuildingTimeZoneDate;
        let objData = {"startDate": component.get("v.startDate"), "endDate":component.get("v.endDate"), "selectedStatus":component.get("v.selectedStatus"), "bookedBy":component.get("v.bookedBy"), "assignHost": component.get("v.assignHost"), "companyName":component.get("v.companyName"),"startTime":component.get("v.instantTour.startTime"),"tourDate": tourDate};
        let lead = JSON.parse(JSON.stringify(component.get("v.selectedObject")));
        let leadData = {"leadName":lead.Name,"Company":lead.Company,"Email":lead.Email,"Phone":lead.Phone,"NumberOfFTE":lead.Number_of_Full_Time_Employees__c,"InterestedInNoOfDesks":lead.Interested_in_Number_of_Desks__c};
        Object.assign(objData,leadData);
        let redirectUrl;
        let currentBuilding = component.get("v.instantTour.building") ? component.get("v.instantTour.building") :component.get("v.building");
        if(selectedRecord.leadId==null && selectedRecord.contactId==null){
           redirectUrl = '/apex/BookTours?productLine='+(component.get("v.productLine") ? component.get("v.productLine") : "WeWork")+'&buildingId='+currentBuilding+'&url_Data='+(encodeURI(JSON.stringify(objData)));
        }else{
           redirectUrl =  '/apex/BookTours?productLine='+(component.get("v.productLine") ? component.get("v.productLine") : "WeWork")+'&buildingId='+currentBuilding+'&url_Data='+(encodeURI(JSON.stringify(objData)))+'&'+contactOrLead+'='+selectedRecord[contactOrLead];
        }
        window.location = redirectUrl;
    },
    getTourData:function(component ,event, helper){
        component.find("utils").showProcessing();
        helper.getTourInfo(component,event,helper,function(tourRecords){ 
            setTimeout(function(){component.find("utils").hideProcessing();},4000);
            helper.resetTable(component);
            component.set("v.records",JSON.parse(tourRecords));
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    rescheduleTourSave : function(component , event , helper){
        helper.rescheduleTour(component, event, helper);
    },
    followupTourSave : function(component , event , helper){
        helper.followupTour(component, event, helper);
    },
    cancelTourSave:function(component,event,helper){
        var tour= JSON.parse(JSON.stringify(component.get("v.tourData")));
        var settings = JSON.parse(JSON.stringify(component.get("v.setting")));
        var url = settings.ReservableCancelAPI.url;
        url = url.split(":id").join(tour.uuid__c);
        var headers = {"Content-Type":"application/json","Authorization":settings.ReservableRescheduleAPI.Headers.Authorization};
        var cancelledTour = {
            Cancellation_Reason: component.get("v.cancellationReason")
        }
        component.find("utils").showProcessing();
        component.find("utils").execute("c.executeRest",{"method": "POST","endPointUrl": url,"headers": headers,"body": JSON.stringify(cancelledTour)},function(response){
            console.log('Cancel Response from SS ::: '+response);
            response = JSON.parse(response);
            if(response.hasOwnProperty("error")){                        
                component.find("utils").hideProcessing();
                component.find("tourCancelationModal").close();
                if((response.hasOwnProperty("error")) && (response.hasOwnProperty("message")))
                    component.find("utils").showError('Space Station Error : '+response.message);
                else
                    component.find("utils").showError('Space Station Error : '+response.error);
            }else{
                component.find("utils").execute("c.saveRecord",{"record":{"Id":component.get("v.tourData.Id"),"Cancellation_Reason__c":component.get("v.cancellationReason")}},function(response){                   
                    var result = JSON.parse(response);
                    if(result.success){
                        helper.getTourInfo(component,event,helper,function(tourRecords){                                             
                            var tours = JSON.parse(tourRecords);
                            component.find("utils").showSuccess('Tour cancelled successfully.');
                            component.set("v.records",tours);  
                            setTimeout(function(){
                                component.set("v.records",JSON.parse(tourRecords));
                            },1000);
                            component.find("utils").hideProcessing(); 
                            component.find("tourCancelationModal").close();
                        },function(error){
                            component.find("utils").hideProcessing();
                            component.find("utils").showError(error);
                        });
                    }    
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                })
                component.find("tourRescheduleModal").close();
            }
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },  
    closeModal:function(component , event , helper){
        component.set("v.cancellationReason",'');
        component.find("tourCancelationModal").close();
    },
    getTimeSlots : function(component,event,helper){
        var tour = JSON.parse(JSON.stringify(component.get("v.tourData")));
        if(component.get("v.tour.tourDate")){
            component.find("utils").showProcessing();
            helper.loadTimeSlots(component,tour,component.get("v.tour.tourDate"),function(){
                component.find("utils").hideProcessing();    
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            }); 
        }
    },
    getTimeSlotsInFollowup:function(component,event,helper){
        component.find("utils").showProcessing();
        component.set("v.followTour.startTime",'');
        component.set("v.followTour.endtTime",'');
        var buildingId = component.get("v.followTour.building");
        var followTour = JSON.parse(JSON.stringify(component.get("v.followTourData")));
        if(component.get("v.followTour.building") != component.get("v.followTourData").Location__c){
            var query = "Select Id , UUID__c from Building__c where Id = '"+component.get("v.followTour.building")+"'";
            component.find("utils").execute("c.getQueryData",{"query":query},function(response){
                if(response && response.length > 0){
                    if(response[0].UUID__c){
                        followTour.Location__r.UUID__c = response[0].UUID__c;
                        component.set("v.followTour.Location__r.UUID__c",response[0].UUID__c);
                        helper.loadTimeSlots(component,followTour,component.get("v.followTour.tourDate"),function(){
                            component.find("utils").hideProcessing();    
                        },function(error){
                            component.find("utils").hideProcessing();
                            component.find("utils").showError(error);
                        }); 
                    }else{
                        component.find("utils").hideProcessing();
                        component.set("v.followTour.tourDate",null);
                        component.set("v.followTour.startTime",'');
                        component.set("v.followTour.endtTime",'');
                        component.set("v.followTour.notes",'');
                        component.find("utils").showError("No UUID available for this building.");
                    }
                }
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            });
        }else{
            if(component.get("v.followTour.tourDate")){
                component.find("utils").showProcessing();
                component.set("v.followTour.Location__r.UUID__c",component.get("v.followTourData").Location__r.UUID__c);
                helper.loadTimeSlots(component,followTour,component.get("v.followTour.tourDate"),function(){
                    component.find("utils").hideProcessing();    
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                }); 
            } 
        }
    },
    setEndTime:function(component, event, helper){
        if(event.currentTarget.value){
            component.set("v.tour.endTime",helper.getEndTime(component,event.currentTarget.value));
        }else if(event.currentTarget.value == ""){
            component.set("v.tour.endTime",null);
        }
    },
    setEndTimeInFollowup:function(component, event, helper){
        if(event.currentTarget.value){
            component.set("v.followTour.endTime",helper.getEndTime(component,event.currentTarget.value));
        }else if(event.currentTarget.value == ""){
            component.set("v.followTour.endTime",null);
        }
    },
    clearDate:function(component, event, helper){
        component.set("v.followTour.tourDate",null);
        component.set("v.followTour.startTime",'');
        component.set("v.followTour.endTime",'');
    },
    closeRescheduleModal:function(component, event, helper){
        component.set("v.tour.tourDate",null);
        component.set("v.tour.startTime",null);
        component.set("v.tour.endTime",null);
        component.set("v.tour.notes",null);
        component.set("v.tour.booked_by_contact_id__c",null);
        component.find("tourRescheduleModal").close();
    },
    closeFollowUpTourModal : function(component , event , helper){
        component.set("v.followTour.tourDate",null);
        component.set("v.followTour.startTime",null);
        component.set("v.followTour.endTime",null);
        component.set("v.followTour.notes", null);
        component.find("followUpTourModal").close();
    },
    AssignNewContact : function(component , event , helper){
        component.find("utils").showProcessing();
        const host = component.get("v.selectedAssignHost");
        let action = component.get("c.updateSapiWithNewAssignedHost");
        action.setParams({ uuid : component.get("v.tourData.uuid__c"), contactSfId : host }); 
        action.setCallback(this, function(response) {
            const tourToUpdate = {Id: component.get("v.tourData.Id"), Assigned_Host__c: host};
            helper.assignHostProcessSapiResponse(component, helper, response, tourToUpdate, true);
        });
		$A.enqueueAction(action);
    }, 
    closeAssignModal : function(component , event , helper){
        component.set("v.selectedAssignHost",'');
        component.find("NewAssignModal").close();
    },
    fetchLinkData:function(component ,event, helper){
        if(component.get("v.building")){
            var enddate = component.get("v.serverDates").TomorrowDate;
            if(event.currentTarget.value == 'Yesterday'){
                component.set("v.startDate",component.get("v.serverDates").YesterdaysDate);
                component.set("v.endDate",component.get("v.serverDates").YesterdaysDate);
            }
            if(event.currentTarget.value == 'Today'){
                component.set("v.startDate",component.get("v.serverDates").TodaysDate);
                component.set("v.endDate",component.get("v.serverDates").TodaysDate);
            }
            if(event.currentTarget.value == 'Tomorrow'){
                component.set("v.startDate",enddate);
                component.set("v.endDate",enddate);
            }
            if(event.currentTarget.value == 'ThisWeek'){
                component.set("v.startDate",component.get("v.serverDates").ThisWeekStartDate);
                component.set("v.endDate",component.get("v.serverDates").ThisWeekEndDate);
            }
            component.find("utils").showProcessing();
            helper.getTourInfo(component,event,helper,function(tourRecords){ 
                setTimeout(function(){component.find("utils").hideProcessing();},4000);
                component.set("v.records",JSON.parse(tourRecords));
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            });
        }else{
            component.find("utils").showError('Please select a building.');
        }
    },
    clearLinkData:function(component, event, helper){
        component.set("v.startDate",null);
        component.set("v.endDate",null);
        component.set("v.selectedStatus",null);
        component.set("v.bookedBy",null);
        component.set("v.assignHost",null);
        component.set("v.companyName",null);
    },
    selectEntity : function(component, event, helper) {
        helper.clearEntity(component,event,helper);
        var selectEntityData = {};
        component.set("v.showSearchData", false);
        var buildingInfo = component.get("v.buildingInfo");
        var id = event.currentTarget.id;         
        var searchData = component.get("v.searchData");
        var index = searchData.findIndex(p => p.Id == id);
        if(index >= 0){
            if(searchData[index].Id==id){
                selectEntityData = Object.assign(selectEntityData,{"Id":searchData[index].Id,"Name":searchData[index].Name,"Email":searchData[index].Email});
                if(searchData[index].AccountId){
                    selectEntityData = Object.assign(selectEntityData,{"AccountId":searchData[index].AccountId,"AccountName":searchData[index].Account.Name,"Account_Type__c":searchData[index].Account.Account_Type__c,"PrimaryMember":searchData[index].Account.Primary_Member__c});
                    component.set("v.contactNames.isContact", true);
                    component.find("utils").showProcessing();
                    helper.getOpenOpportunities(component, selectEntityData.AccountId, function(openOpportunities){
                        component.find("utils").hideProcessing();
                        if(openOpportunities && openOpportunities.length){
                            selectEntityData.Interested_in_Number_of_Desks__c = openOpportunities[0].Account.Interested_in_Number_of_Desks__c != undefined ? parseInt(openOpportunities[0].Account.Interested_in_Number_of_Desks__c) : 1
                            for(var opportunity in openOpportunities){
                                selectEntityData = Object.assign(selectEntityData,{"opportunityName":openOpportunities[opportunity].Name,"opportunityBuildingId":openOpportunities[opportunity].Building__c,"opportunityId":openOpportunities[opportunity].id,"opportunityBuildingUUId":openOpportunities[opportunity].Building_uuid__c,"accountPrimaryMember":openOpportunities[opportunity].Account_Primary_Member__c,"accountPrimaryMemberEmail":openOpportunities[opportunity].Account.Primary_Member__r.Email});
                            }
                            component.set("v.relatedOpportunities",openOpportunities);
                        }else{
                            component.set("v.relatedOpportunities",[]);
                        }
                        if(selectEntityData.billingAccount != null)
                            component.set("v.sendPaperwork",true);
                        else
                            component.set("v.sendPaperwork",false); 
                        
                        component.set("v.contactNames", selectEntityData);
                        component.set("v.contactNames.isContact", true);
                        component.set("v.oppFound", true);
                        component.set("v.createOpportunityLink", true); 
                    })
                }else if(event.currentTarget.id.startsWith('00Q')){
                    helper.clearEntity(component,event,helper);
                    selectEntityData = Object.assign(selectEntityData,{"Id":searchData[index].Id,"LeadName":searchData[index].Name,"Email":searchData[index].Email,"LeadPhone":searchData[index].Phone,"LeadCompany":searchData[index].Company,"LeadBuildingInterested":searchData[index].Building_Interested_In__c,"LeadFullTimeEmployees":searchData[index].Number_of_Full_Time_Employees__c,"LeadInterestedinNumberofDesks":searchData[index].Interested_in_Number_of_Desks__c,"LeadSourceDetail":searchData[index].Lead_Source_Detail__c,"LeadSource":searchData[index].LeadSource,"LeadAccount":searchData[index].Account__c});
                    component.set("v.contactNames", selectEntityData);
                    component.set("v.sendPaperwork", true);
                    component.set("v.selectedRecord",'');
                    component.set("v.contactNames.isContact", false);
                }else if(searchData[index].AccountId == null){
                    helper.clearEntity(component,event,helper);
                    component.set("v.contactNames.isContact", true);
                    component.find("utils").showError('Related account for this contact does not exist');    
                }
            }
        }	
    },
    createNew:function(component,event,helper){
        component.find("sendPaperworkModal").close();
        component.set("v.showSearchData", false);
        helper.clearContactFields(component, event, helper);
        component.set("v.contactNames",{});
        component.set("v.relatedOpportunities",[]);
        component.find("createContactmodal").showModal();
        if(component.get("v.keyword"))
            component.set("v.contactNames.Email",component.get("v.keyword"));
    },
    search:function(component,event,helper){
        var emailOfContactOrLead = event.currentTarget.value;
        component.set("v.showSearchData", true);
        component.set("v.keyword", emailOfContactOrLead);
        if(emailOfContactOrLead == '' && emailOfContactOrLead.length == 0){
            component.set("v.contactNames.isContact",true);
            helper.clearEntity(component, event, helper);
            helper.clearContactFields(component, event, helper);
        }else if(emailOfContactOrLead && emailOfContactOrLead.length > 2){  
            component.find("utils").execute("c.getListQueryDataBySOSL",{"arrQuery":["FIND \'"+component.find("utils").addSlashes(emailOfContactOrLead)+"*\' IN ALL FIELDS RETURNING Contact(Id, Name, Email, Account.Name, Account.Id, Account.Primary_Member__c, Account.Account_Type__c ORDER BY CreatedDate) LIMIT 5","FIND  \'"+component.find("utils").addSlashes(emailOfContactOrLead)+"*\' IN ALL FIELDS RETURNING Lead( Id, Name, Email, Phone, Company, Building_Interested_In__c, Number_of_Full_Time_Employees__c, Interested_in_Number_of_Desks__c, Lead_Source_Detail__c, LeadSource,Account__c WHERE isConverted = false ORDER BY CreatedDate) LIMIT 5"]},function(response){      
                var data = [];
                var setContactEmail = new Set();
                var setLeadEmail = new Set();
                for(var row in response){
                    for(var column in response[row]){
                        if(row=="0"){
                            response[row][column]["type"] = "contact";
                            if(response[row][column]["Email"] != undefined){
                                setContactEmail.add(response[row][column]["Email"]);
                            }
                            data.push(response[row][column]);
                        }else{
                            if(!setContactEmail.has(response[row][column]["Email"])){
                                if(!setLeadEmail.has(response[row][column]["Email"])){
                                    setLeadEmail.add(response[row][column]["Email"]);
                                    response[row][column]["type"] = "lead";
                                    data.push(response[row][column]);      
                                }
                            }
                        }
                    }
                }                
                component.set("v.searchData", data);
                component.set("v.contactNames.isContact", true);
                var a=document.getElementById("listbox-unique-id");        
                $A.util.removeClass(a, "slds-hide");
            },function(error){
                component.find("utils").showError(error);
                component.find("utils").hideProcessing();
            })
        }
    },
    openSendPaperworkModule:function(component, event, helper){
        helper.clearContactFields(component, event, helper);
        component.find("sendPaperworkModal").showModal();
        component.set("v.contactNames.Email",'');
        component.set("v.createOpportunityLink", false);
    },
    closeSendPaperWorkModal:function(component,event,helper){
        if(component.get("v.contactNames")){
            helper.clearContactFields(component, event, helper);
            component.set("v.keyword",null);
            component.set("v.contactNames.isContact", true);
        }
        component.set("v.sendPPWKEmail",false);
        component.find("sendPaperworkModal").close();
    },
    createNewOpportunity : function(component){
        component.find("utils").showProcessing();
        component.find("selectOpenOppotutymodal").close();
        component.find("sendPaperworkModal").showModal();
        var contactNames = component.get("v.contactNames");
        var building_id = component.get("v.building");
        component.find("utils").execute("c.createOpportunityForCommunityView",{"contactId":contactNames.Id,"noOfDesks":contactNames.Interested_in_Number_of_Desks__c,"buildingID":building_id},function(response){
            var Opportunity;
            if(response){
              Opportunity  = JSON.parse(response); 
            }
            if(Opportunity && Opportunity.length){
                var relatedOpportunities = component.get("v.relatedOpportunities");
                relatedOpportunities.push({"Id":Opportunity[0]["Id"] ,"Name":Opportunity[0]["Name"]}); 
                component.set("v.relatedOpportunities",relatedOpportunities);
                component.set("v.contactNames.opportunityId",Opportunity[0].Id);
                component.set("v.contactNames.oppOwner",Opportunity[0].Owner.Name);
                component.set("v.contactNames.opportunityName",Opportunity[0].Name);
                component.set("v.contactNames.buildingName",Opportunity[0].Building__c ? Opportunity[0].Building__r.Name : '');
                component.set("v.contactNames.desks",Opportunity[0].Quantity__c);
                component.set("v.contactNames.CloseDate",Opportunity[0].CloseDate);
                component.set("v.contactNames.stage",Opportunity[0].StageName);
                component.set("v.contactNames.accountPrimaryMemberEmail",Opportunity[0].Account.Primary_Member__r.Email);
                component.set("v.contactNames.PrimaryMemberName",Opportunity[0].Account.Primary_Member__r.Name);
                component.set("v.createOpportunityLink",true);
                component.set("v.oppFound",true);
                if(Opportunity[0].Billing_Account__c){
                    component.set("v.sendPaperwork",true);
                }
                else{
                    component.set("v.sendPaperwork",false);
                }
                component.find("utils").hideProcessing();
                component.find("utils").showSuccess('New opportunity created successfully');
            }            	
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        },component);        
    },
    createNewContact:function(component,event,helper){
        component.find("utils").showProcessing();
        var contactDetails = component.get("v.contactNames");
        contactDetails['buildingId']=component.get("v.building");  
        component.find("utils").execute("c.createAccountOppContactCommunityView",{"recordsToCreate":contactDetails},function(response){
            component.find("utils").hideProcessing();
            if(response){
                var objResponse = JSON.parse(response);
                if(objResponse.contact && objResponse.account){
                    helper.clearContactFields(component, event, helper);
                    component.set("v.contactNames.Id",objResponse.contact.Id);
                    component.set("v.contactNames.Email",objResponse.contact.Email);
                    component.set("v.contactNames.Name",(objResponse.contact.FirstName !=null ? (objResponse.contact.FirstName +" " + objResponse.contact.LastName):objResponse.contact.LastName));
                    component.set("v.contactNames.AccountId",objResponse.account);
                    component.find("createContactmodal").close();
                    component.set("v.createOpportunityLink",true);
                    component.set("v.oppFound",true);
                    component.find("sendPaperworkModal").showModal();
                }
            } 
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        },component);
    },
    closeContactModal:function(component,event,helper){
        component.set("v.keyword",null);
        helper.clearContactFields(component, event, helper);
        component.set("v.createOpportunityLink",false);
        component.find("createContactmodal").close();
        component.find("sendPaperworkModal").showModal();
    },
    redirectTosendPaperworkUrl:function(component,event,helper){
        component.find("utils").showProcessing();
        component.set("v.sendPaperwork",true);
        component.find("sendPaperworkModal").close();
        component.set("v.sendPPWKEmail",false);
        var contactOrLead = component.get("v.contactNames.Id");
        if(contactOrLead && contactOrLead.startsWith('00Q')){
            component.set("v.LeadId", contactOrLead);
            if(!component.get("v.showAccountSelector")){
                component.set("v.showAccountSelector", true);
            } else {
                component.find("AccountSelector").showModal();
            }
            component.find("utils").hideProcessing();            
        }else{
            component.find("utils").hideProcessing();
            helper.redirectTosendPaperworkUrl(component,event,helper);
        }
    },
    continueAfterAccountSelector : function(component, event, helper){
        component.set("v.showAccountSelector", false);
        helper.continueAfterAccountSelector(component,helper,function(message){
            component.find("utils").showSuccess(message);
            helper.redirectTosendPaperworkUrl(component,event,helper);
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    selectAction:function(component,event,helper){
        var val = event.getParam("value");
        helper.actionHandler(component,event,helper,val);
    },
    selectedRecord:function(component,event,helper){
        var oppId;
        if(component.get("v.selectedRecord")){
            oppId = component.get("v.selectedRecord");
        }else{
            oppId = component.get("v.contactNames.opportunityId");
        }
        var query = "SELECT Id,Name,Building__c,Billing_Account__c,Building__r.Name,Owner.Name,Quantity__c,CreatedDate,StageName,CloseDate,Account_Primary_Member__c,Account.Primary_Member__r.Name,Account.Primary_Member__r.Email,Account.Account_Type__c,Billing_Account__r.Primary_Member__r.Email  From Opportunity Where Id ='"+oppId+"'";        
        component.find("utils").execute("c.getQueryData",{"query":query},function(response){
            if(response && response.length){ 
                component.set("v.contactNames.oppOwner",response[0].Owner.Name);
                component.set("v.contactNames.opportunityName",response[0].Name);
                component.set("v.contactNames.buildingName",response[0].Building__c ? response[0].Building__r.Name : '');
                component.set("v.contactNames.desks",response[0].Quantity__c);
                component.set("v.contactNames.CloseDate",response[0].CloseDate);
                component.set("v.contactNames.stage",response[0].StageName);
                component.set("v.contactNames.opportunityId",response[0].Id);
                component.set("v.contactNames.accountPrimaryMember",response[0].Account_Primary_Member__c);
                component.set("v.contactNames.accountPrimaryMemberEmail",response[0].Account.Primary_Member__r.Email);
                component.set("v.contactNames.sendPerwork",response[0].Billing_Account__c);
                if(response[0].Billing_Account__c && response[0].Billing_Account__r.Primary_Member__c){
                    component.set("v.contactNames.billingAccountPrimaryMemberEmail",(response[0].Billing_Account__c ? response[0].Billing_Account__r.Primary_Member__r.Email : ''));  
                }
                component.set("v.contactNames.PrimaryMemberName",response[0].Account.Primary_Member__r.Name);
                if(response[0].Billing_Account__c){
                    component.set("v.sendPaperwork",true);
                }else{
                    component.set("v.sendPaperwork",false); 
                }
            }
            component.find("sendPaperworkModal").showModal();
            component.find("selectOpenOppotutymodal").close();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    openOppertunityModal:function(component,event,helper){
        helper.resetOpportunityTable(component);
        component.set("v.selectedRecord",'');
        component.find("sendPaperworkModal").close();
        component.find("selectOpenOppotutymodal").showModal();
        var metaFields = [];
        metaFields.push({"name":"Id","label":"Action","type":"component","sort":"false","component":{"name":"c:EnziInputRadio","attributes":{"value":component.getReference("v.selectedRecord"),"text":"{{Id}}"}}});
        metaFields.push({"name":"Name","label":"Opportunity Name","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Name}}","value":"/{{Id}}","target":"_new"}}});
        metaFields.push({"name":"Account.Name","label":"Account Name"});
        metaFields.push({"name":"Billing_Account__r.Name","label":"Billing Account Name"});
        metaFields.push({"name":"Billing_Account__r.Primary_Member__r.Email","label":"Primary Member Email","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Billing_Account__r.Primary_Member__r.Email}}","value":"mailTo:{{Billing_Account__r.Primary_Member__r.Email}}","target":"_blank"}}});
        metaFields.push({"name":"Owner.Name","label":"Opportunity Owner"});
        metaFields.push({"name":"Building__r.Name","label":"Location"});
        component.set("v.opprtunityRelatedData",metaFields);
        component.find("utils").showProcessing();
        helper.getOpenOpportunities(component, component.get("v.contactNames").AccountId, function(openOpportunities){
            component.find("utils").hideProcessing();
            component.set("v.relatedOpportunities",openOpportunities);
        })
    },
    closeOpenOpportunityModal:function(component,event,helper){
        component.find("sendPaperworkModal").showModal();
        component.find("selectOpenOppotutymodal").close();
    },
    closeContactTourHistory:function(component,event,helper){
        component.find("viewContactTourHistory").close();
        component.set("v.tourHistoryData",{'contactInfo':undefined,'tours':[],'currentPage':1,'pageSize':10});
    },
    redirectToZendeskSupport:function(component,event,helper){
        var settings = JSON.parse(JSON.stringify(component.get("v.setting")));
        window.open(settings.ZendeskUrl.url);
    },
    processingCompleted:function(component,event,helper){
        if(component.get("v.contactNames.processingCompleted")){
            if(component.get("v.salesRecords").length > 0){
                component.find("utils").hideProcessing();
                component.set("v.contactNames.showAccountSelector", true);
            }else{
                component.find("utils").hideProcessing();
                if(component.get("v.OrgRecord.Id")){
                    helper.continueAfterAccountSelector(component,helper,function(message){
                        component.find("utils").hideProcessing();
                        component.find("utils").showSuccess(message);
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    });  
                }
            }
        }
    },
    actionSelected:function(component,event,helper){
        component.set("v.contactNames.showAccountSelector", false);
        if(component.get("v.contactNames.selectedAction") && (component.get("v.contactNames.selectedAction") != null)){
            component.find("utils").showProcessing();
            helper.continueAfterAccountSelector(component,helper,function(message){
                component.find("utils").hideProcessing();
                component.find("utils").showSuccess(message);
            },function(error){
                var  messege = error;
                component.find("utils").hideProcessing();
                component.find("utils").showError(messege.split(',')[1]);
            });   
        }
    },
    redirectToBuildingMapTool : function(component, event, helper){
        window.open(component.get("v.setting.BuildingMapToolUrl.url")+''+component.get("v.buildingInfo.UUID__c"));
    },
    searchDataUsingSOSLForInstanTour:function(component, event, helper){
        let sObject = component.get("v.helperModules.soslComponentInstantTour").selectRecordFromList(event.currentTarget.id);
        if(sObject){
            let a = document.getElementById("listbox-unique-id");        
            $A.util.addClass(a, "slds-hide");
            if(sObject.type == "contact" && sObject.AccountId){
                component.find("utils").showProcessing();
                component.find("utils").execute("c.getOnclickRelatedOpportunities",{"accountId":sObject.AccountId},function(response){
                    if(response && response.length > 0){
                        component.set("v.relatedOpportunitiesForInstantTour",response);
                        component.set("v.selectedObject.opportunityId",response[0].Id);
                        component.find("utils").hideProcessing();
                    }
                },function(error){
                    component.find("utils").showError(error);
                    component.find("utils").hideProcessing();
                },component);
            }else if(sObject.type == "contact" && !sObject.AccountId){
                sObject.OpportunityId = null;
                component.find("utils").showError('Account is missing on selected Contact, Please associate the Contact with an appropriate Account and try again.');
                
            }
            component.set("v.expandSections.instantTourProfile", true);
            component.set("v.expandSections.instantTourInformation", true);
            helper.loadtimeSlotsForTours(component, event, helper, function(timeSlotsOfToday){
                if(timeSlotsOfToday && timeSlotsOfToday.length){
                    component.set("v.instantTour.startTime", timeSlotsOfToday[0].time); 
                }
            });
            helper.setInstantTour(component, helper, sObject);
        }
    },
    hideMessageIndicator:function(component, event, helper){
        if(!component.get("v.hideMsg")){
            component.set("v.hideMsg", true);
            var element = document.getElementsByClassName("instantSection");
        }    
    },
    resetAndSearch:function(component, event, helper){
        component.set("v.hideMsg", true);
        if(event.currentTarget && event.currentTarget.value.length == 0){
             helper.setInstantTour(component, helper, null);
        }else if(event.currentTarget.value.length > 2){
            component.get("v.helperModules.soslComponentInstantTour").searchUsingSOSL(event.currentTarget.value);
        }
    },
    createInstantTour: function(component, event, helper){
        component.set("v.showAccountSelector", false);
        component.get("v.helperModules.utils").showProcessing();
        if(component.get("v.selectedObject.leadId")){
            var selectedObject = component.get("v.selectedObject");
            component.set("v.accountRec", {"sobjectType": "Account", "Name": null, "Website": "", "Number_of_Full_Time_Employees__c": selectedObject.Number_of_Full_Time_Employees__c, "Interested_in_Number_of_Desks__c": selectedObject.Interested_in_Number_of_Desks__c});
            component.set("v.LeadId", component.get("v.selectedObject.leadId"));
            helper.updateRelatedRecord(component,event,helper,function(){ 
                component.get("v.helperModules.utils").hideProcessing();
                component.set("v.showAccountSelector", true);  
                component.find("InstantTourModal").close();
            },function(error){
                component.get("v.helperModules.utils").hideProcessing();
                component.get("v.helperModules.utils").showError(error);
            });
        }else if(component.get("v.selectedObject.type") == "contact"){
            helper.updateRelatedRecord(component,event,helper,function(){ 
                var relatedOpenOpportunities;
                var buildingID = component.get("v.buildingInfo.Id");
                var mapRecordData = {"accountId":component.get("v.selectedObject.AccountId"), "contactId":component.get("v.selectedObject.contactId")};
                component.get("v.helperModules.utils").execute("c.getOpportunityRecord", {"mapRecordData": mapRecordData, "buildingID":buildingID}, function(response){
                    if(response){
                        helper.bookATour(component, helper, response["contact"][0], component.get("v.selectedObject.opportunityId"));
                    }
                    component.get("v.helperModules.utils").hideProcessing();
                }, function(error){
                    component.get("v.helperModules.utils").hideProcessing();
                    component.get("v.helperModules.utils").showError(error);
                }, component);
            },function(error){
                component.get("v.helperModules.utils").hideProcessing();
                component.get("v.helperModules.utils").showError(error);
            });
        }else{
            if(component.get("v.selectedObject.type")=="newlead"){
                var lead = JSON.parse(JSON.stringify(component.get("v.selectedObject")));
                var names = lead.Name.split(" ");
                if(names.length > 1){
                    var arrFirstName = names.slice(0, names.length-1);
                    lead.FirstName = arrFirstName.join(" ");
                    lead.LastName = names[names.length-1];
                    if(lead.LastName ==""){
                        lead.LastName = names[0];
                    }
                }else{
                    lead.LastName = names[0];
                }
                lead['sobjectType'] = "Lead";
                lead['Lead_Assignment_Stage__c'] = "1000";	             
                lead['Lead_Source_Detail__c'] = "Book Tour Page";	
                lead['Locations_Interested__c'] = component.get("v.building") ? component.get("v.building").Name : null;
                delete lead['Name'];
                delete lead['type'];
                component.get("v.helperModules.utils").execute("c.saveRecord", {"record": lead},function(response){
                    component.get("v.helperModules.utils").hideProcessing();
                    var leadId = JSON.parse(response).id;
                    var selectedObject = component.get("v.selectedObject");
                    component.set("v.selectedObject.Id", leadId);
                    component.set("v.selectedObject.type", "lead");
                    component.set("v.accountRec", {"sobjectType": "Account", "Name": null, "Website": "", "Number_of_Full_Time_Employees__c": selectedObject.Number_of_Full_Time_Employees__c, "Interested_in_Number_of_Desks__c": selectedObject.Interested_in_Number_of_Desks__c});
                    component.get("v.helperModules.utils").hideProcessing();
                    component.find("InstantTourModal").close();
                    component.set("v.LeadId" ,component.get("v.selectedObject.Id"));
                    component.set("v.showAccountSelector", true);
                },function(error){
                    component.get("v.helperModules.utils").hideProcessing();
                    component.get("v.helperModules.utils").showError(error);
                });
            }
        }
    },
    openPopup : function(component, event, helper) {
        component.set("v.showMe", !component.get("v.showMe"));
    },
    managePopupdata : function(component, event, helper){
        records.push(JSON.parse(event.currentTarget.getAttribute('data-value')))
        component.set("v.recordsData", records);
    },
    tourBuildingChange : function(component, event, helper){
        let newBuilding = component.get("v.instantTour.building");
        let allBuildings = component.get("v.AllWeWorkBuildings");
        if(newBuilding && allBuildings && allBuildings.length){
            let index = helper.getBuildingUUIDFromList(allBuildings, 'Id', newBuilding);
            if(index >= 0){
                helper.loadtimeSlotsForTours(component, event, helper, function(timeSlotsOfToday){
                    if(timeSlotsOfToday && timeSlotsOfToday.length){
                       component.set("v.instantTour.startTime", timeSlotsOfToday[0].time); 
                    }
                },allBuildings[index]);  
            }
        }else if(!newBuilding){
            component.set("v.instantTour.startTime", null);
            component.set("v.instantTour.tourDate", component.get("v.serverDates").BuildingTimeZoneDate);
            component.set("v.instantTour.available_tour_times", []); 
        }
    },
    setOpportunityForInstantTour : function(component, event, helper){
        component.set("v.selectedObject.opportunityId", component.find("opportunityInstantTour").get("v.value"));
    },
    createNewOpportunityForInstantTour : function(component, event, helper){
        component.find("utils").showProcessing();
        if(component.get("v.selectedObject.contactId")){
            component.find("utils").execute("c.createOpportunityForCommunityView",{"contactId":component.get("v.selectedObject.contactId"),"noOfDesks":component.get("v.selectedObject.Interested_in_Number_of_Desks__c"),"buildingID":component.get("v.instantTour.building") ? component.get("v.instantTour.building") : component.get("v.building")},function(response){
                component.find("utils").hideProcessing();
                if(response){
                    var opportunity = JSON.parse(response);
                    let relatedOpportunitiesForInstantTour = component.get("v.relatedOpportunitiesForInstantTour");
                    relatedOpportunitiesForInstantTour.push({"Name":opportunity[0].Name,"Id":opportunity[0].Id});
                    component.set("v.relatedOpportunitiesForInstantTour",relatedOpportunitiesForInstantTour);
                    component.set("v.selectedObject.opportunityId",opportunity[0].Id);
                }
            },function(error){
                component.get("v.helperModules.utils").hideProcessing();
                component.get("v.helperModules.utils").showError(error); 
            },component);
        }
    },
    setRecordsForInstantTour : function(component, event, helper){
        var data = [];
        var setContactEmail = new Set();
        var setLeadEmail = new Set();
        var records = component.get("v.helperModules.soslComponentInstantTour").get("v.searchData");
        for(var row in records){
            if(records[row]["type"] == "contact"){
                if(records[row]["Email"] != undefined){
                    setContactEmail.add(records[row]["Email"]);
                }
                data.push(records[row]);
            } else if(records[row]["type"] == "lead"){
                if(!setContactEmail.has(records[row]["Email"])){
                    if(!setLeadEmail.has(records[row]["Email"])){
                        setLeadEmail.add(records[row]["Email"]);
                        data.push(records[row]);      
                    }
                }
            }
        }    
        component.get("v.helperModules.soslComponentInstantTour").set("v.sortedDataForList",data);
    }
})