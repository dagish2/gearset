({
    getBuildingData : function(component,event,helper) {
        component.find("utils").execute("c.getQueryData",{"query":"Select Id,Name from Building__c"},function(response){
            component.set("v.buildingData",response);
        },function(error){
            component.find("utils").showError(error);
        })   
    },  
    formatDate:function (dt) {
        return dt.getFullYear()+"-"+((dt.getMonth()+1)<10?("0"+(dt.getMonth()+1)):dt.getMonth()+1)+"-"+(dt.getDate()<10?("0"+dt.getDate()):dt.getDate());
    },
    getTourInfo:function(component,event,helper,onSuccess,onError) {
        var date1 = component.get("v.startDate");
        var edate = component.get("v.endDate");
        if(!component.get("v.assignHost")){
            component.set("v.assignHost",null);
        }
        if(!component.get("v.bookedBy")){
            component.set("v.bookedBy",null);
        }
        if(!component.get("v.companyName")){
            component.set("v.companyName",null);
        }
        component.find("utils").execute("c.getTourRelatedData",{"startDate":component.get("v.startDate"),"endDate":component.get("v.endDate"),"selectedStatus":component.get("v.selectedStatus"),"bookedBy":component.get("v.bookedBy"),"assignHost":component.get("v.assignHost"),"companyName":component.get("v.companyName"),"locationId":component.get("v.buildingInfo.Id")},function(response){
            if(response && response.length > 0){                
                response = JSON.parse(response.replace(/\r?\n|\r/g,""));
                if(response.length > 2000){
                    response.splice(-1,1);
                    component.find("utils").showWarning('Trying to fetch many records, please try to narrow down the serach by adding filters.If not, this may take a while to load the records');
                }
                onSuccess(JSON.stringify(response));
            }
        },function(error){
            onError(error);
        },component);
    },
    loadTimeSlots:function(component,tour,tourDate,onsuccess,onerror){ 
        if(tour && tour.Tour_Date__c){
            if(tour.Location__r.UUID__c){
                var settings = JSON.parse(JSON.stringify(component.get("v.setting")));
                var url = settings.ReservableTourBuildingAvailabilitiesAPI.url;
                url += '?date=' + tourDate + '&building_id=' + tour.Location__r.UUID__c + '&product_line=' + tour.Product_Line__c
                var headers = {"Content-Type":"application/json","Authorization":settings.ReservableTourBuildingAvailabilitiesAPI.Headers.Authorization};
                component.find("utils").execute("c.executeRest", {"method": "GET","endPointUrl": url,"headers": headers,"body": ""}, function(response){
                    if(response){
                        var times = JSON.parse(response).available_tour_times;
                        for(var t in times){
                            times[t].time = times[t].time.split(" ").join("");
                        }
                        if(component.get("v.tour")){
                            if(times && times.length > 0){
                                component.set("v.tour.available_tour_times",times);
                            }else{        
                                component.set("v.tour.startTime",null);
                                component.set("v.tour.endTime",null);
                                component.set("v.tour.available_tour_times",[]);                            
                                onerror('No times slots available for the selected date');
                            } 
                        }
                        if(component.get("v.followTour")){
                            if(times && times.length > 0){
                                component.set("v.followTour.available_tour_times",times);
                            }else{        
                                component.set("v.followTour.startTime",null);
                                component.set("v.followTour.endTime",null);
                                component.set("v.followTour.available_tour_times",[]);                            
                                onerror('No times slots available for the selected date');
                            }   
                        }
                        onsuccess();
                    }else{ 
                        onerror(JSON.parse(response).message); 
                    } 
                    
                },function(error){
                    onerror(error);
                });
            }else{
                onerror('No UUID available for this building.');
            }
        }else{
            onerror('Please select Tour date.');
        }
    },
    getEndTime : function(component,startTime){
        var hr = startTime.split(":")[0];
        var min = startTime.split(":")[1].substr(0,2);
        var am = startTime.split(":")[1].substr(2,3);
        if(component.get("v.tour"))
            var tour = JSON.parse(JSON.stringify(component.get("v.tour")));
        if(component.get("v.followTour"))
            var tour = JSON.parse(JSON.stringify(component.get("v.followTour")));
        if(tour.Location__r && tour.Location__r.Tour_Spacing__c=="Half Hour"){
            if(hr=="11" && min=="30"){
                return (parseInt(hr)+1)+":00"+(am=="AM"?"PM":"AM");
            }else{
                if(min=="00"){
                    return parseInt(hr)+":30"+am;
                }else{
                    if(hr!="12"){
                        return (parseInt(hr)+1)+":00"+am;
                    }else{
                        return "01"+":00"+am;
                    }
                }
            }
        }else{
            if(hr=="11" && min=="00"){
                return (parseInt(hr)+1)+":00"+(am=="AM"?"PM":"AM");
            }else{
                return (parseInt(hr)+1)+":00"+am;
            }
        }
    },
    rescheduleTour : function(component, event, helper){
        var loggedInUserInfo = component.get("v.loggedInUserInfo");
        if(loggedInUserInfo && loggedInUserInfo.Contact){
            var rescheduleTour = JSON.parse(JSON.stringify(component.get("v.tourData")));
            var settings = JSON.parse(JSON.stringify(component.get("v.setting")));
            var tour =  component.get("v.tour");
            var url = settings.ReservableRescheduleAPI.url;
            url = url.split(":id").join(rescheduleTour.uuid__c);
            var headers = {"Content-Type":"application/json","Authorization":settings.ReservableRescheduleAPI.Headers.Authorization};
           
            var newTour = {
                date: tour.tourDate,
                time: tour.startTime,
                notes: (tour.notes != null && tour.notes != "")?tour.notes:"",
                building_id: rescheduleTour.Location__r.UUID__c,
                booked_by_contact_id: tour.booked_by_contact_id__c
            }
            console.log("newTour"+newTour);
            component.find("utils").showProcessing();
            component.find("utils").execute("c.executeRest", {"method": "POST","endPointUrl": url,"headers": headers,"body": JSON.stringify(newTour)}, function(response){
                component.find("utils").hideProcessing();
                console.log('Reschedule Response from SS ::: '+response);
                var result = JSON.parse(response);
                console.log("result"+result.tourDate);
                if(result.hasOwnProperty("error")){                        
                    if((result.hasOwnProperty("error")) && (result.hasOwnProperty("message")))
                        component.find("utils").showError('Space Station Error : '+result.message);
                    else
                        component.find("utils").showError('Space Station Error : '+result.error);
                }else if(result.hasOwnProperty('tour')){
                    component.set("v.reshcheduledTour",result.tour);
                    component.find("utils").showSuccess('Tour rescheduled successfully and will be synced shortly.');
                    component.set("v.tour.tourDate",null);
                    component.set("v.tour.startTime",null);
                    component.set("v.tour.endTime",null);
                    component.set("v.tour.notes",null);
                    component.find("tourRescheduleModal").close();               
                }
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            }) 
        }else{
            component.find("utils").hideProcessing();
            component.find("utils").showError('Contact With Logged In User\'s Email Does not Exist.'); 
        }
    },
    followupTour : function(component,event,helper){
        var loggedInUserInfo = component.get("v.loggedInUserInfo");
        if(loggedInUserInfo && loggedInUserInfo.Contact){
            var followUpTour = JSON.parse(JSON.stringify(component.get("v.followTourData")));
            var settings = JSON.parse(JSON.stringify(component.get("v.setting")));
            var followTour =  component.get("v.followTour");
            if(followUpTour.Primary_Member__c){
                var url = settings.ReservableCreateAPI.url;
                var headers = {"Content-Type":"application/json","Authorization":settings.ReservableCreateAPI.headers.Authorization};
                var newTour = {
                    date: followTour.tourDate,
                    time: followTour.startTime,
                    building_id: followTour.Location__r.UUID__c,
                    notes: (followTour.notes != null && followTour.notes != "")?followTour.notes:"",
                    product_line : followUpTour.Product_Line__c,
                    contact_name : followUpTour.Primary_Member__r.Name,
                    contact_uuid : followUpTour.Primary_Member__r.UUID__c,
                    company_uuid : followUpTour.Primary_Member__r.Account.UUID__c,
                    sf_journey_uuid : null,
                    email : followUpTour.Primary_Member_Email__c,
                    phone : followUpTour.Primary_Member_Phone_Number__c,
                    company_name : followUpTour.Company_Name__c,
                    primary_member : followUpTour.Primary_Member__c,
                    booked_by_contact_id : loggedInUserInfo.Contact.Id,
                    Lead_Source__c : 'Walk In',
                    Lead_Source_Detail__c : 'Community Registration',
                    assigned_host : loggedInUserInfo.Contact.Id,
                    hosted_by : loggedInUserInfo.Contact.Id
                    
                }
                console.log("newTour"+newTour);
                component.find("utils").showProcessing();
                component.find("utils").execute("c.executeRest", {"method": "POST","endPointUrl": url,"headers": headers,"body": JSON.stringify(newTour)}, function(response){
                    component.find("utils").hideProcessing();
                    console.log('Follow up Response from SS ::: '+response);
                    var result = JSON.parse(response);
                    console.log("result"+result.tourDate);
                    if(result.hasOwnProperty("error")){                        
                        if((result.hasOwnProperty("error")) && (result.hasOwnProperty("message")))
                            component.find("utils").showError('Space Station Error : '+result.message);
                        else
                            component.find("utils").showError('Space Station Error : '+result.error);
                    }else if(result.hasOwnProperty('tour')){
                        component.set("v.createNewTour",result.tour);
                        component.find("utils").showSuccess('Tour created successfully and will be synced shortly.');
                        component.set("v.followTour.tourDate",null);
                        component.set("v.followTour.startTime",null);
                        component.set("v.followTour.endTime",null);
                        component.set("v.followTour.notes",null);
                        component.find("followUpTourModal").close();               
                    }
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                })
            }else{
                component.find("utils").hideProcessing();
                component.find("utils").showError('No primary Member present for this tour.');
            }
        }else{
            component.find("utils").hideProcessing();
            component.find("utils").showError('Contact With Logged In User\'s Email Does not Exist.'); 
        }
    },
    setTourMetaFields:function(component, event, helper){
        var setting  = component.get("v.setting");
        var metaFields = [];
        var menuItems = [];
        var lstAllMetaFields = component.get("v.setting").metaFields;
        var allMenuFields = component.get("v.setting").menuItems;
        if(($A.get("$Browser.formFactor") == 'PHONE') || ($A.get("$Browser.formFactor") == 'TABLET')){// For Phone or Tablet
            let lstTableSequenceForSmallScreen = ['Company_Name__c', 'Primary_Member_Email__c', 'Primary_Member_Phone_Number__c', 'Status__c', 'Tour_Date__c', 'Start_Time__c'];
            metaFields = helper.getSequence(lstTableSequenceForSmallScreen, lstAllMetaFields, 'name');
            
            let lstMenuSequenceForSmallScreen = ['Outcome', 'Reschedule', 'Cancel', 'Assign To Me', 'Follow Up Tour','No Show'];
            menuItems = helper.getSequence(lstMenuSequenceForSmallScreen, allMenuFields, 'label');
            metaFields.push({"name":"", "label":"Actions", 'sort':'false', "type":"component", "component":{"name":"c:WeMenuButton", "attributes":{"menuItems":menuItems ,"menuAlignment":"right", "variant":"bare-inverse", "name":"{{Id}}", "onSelect":component.getReference("c.selectAction")}}});
            
        }else{// For Desktop
            let lstTableSequenceForLargeScreen = ['Tour_Date__c', 'Start_Time__c', 'Primary_Member__r.Name', 'Primary_Member_Email__c','Company_Name__c', 'Opportunity__r.Interested_in_Number_of_Desks__c', 'Assigned_Host__r.Name' , 'Status__c', 'New_Tour_Notes__c'];
            let lstMenuSequenceForLargeScreen = ['Outcome', 'Reschedule', 'Cancel', 'Assign', 'Assign To Me', 'Follow Up Tour','View History','Related Tours','Send PaperWork','No Show'];
            
            menuItems = helper.getSequence(lstMenuSequenceForLargeScreen, allMenuFields, 'label');
                        
            metaFields = helper.getSequence(lstTableSequenceForLargeScreen, lstAllMetaFields, 'name');
            metaFields.splice(0,0,{"name":"", "label":"Actions", 'sort':'false', "type":"component", "component":{"name":"c:WeMenuButton", "attributes":{"menuItems":menuItems ,"menuAlignment":"right", "variant":"bare-inverse", "name":"{{Id}}", "onSelect":component.getReference("c.selectAction")}}});
            
        }
        var metaFieldsForPopover = metaFields;
        var dataForPopover = [{"header":"Tour","metadata":[{"name":"Name","label":"","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Name}}","value":"/{{Id}}","target":"_blank"}}},{"name":"booked_by_contact_id__r_Name","label":"Booked By"}]},{"header":"Primary Member","metadata":[{"name":"Primary_Member__r_Name","label":"","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Primary_Member__r_Name}}","value":"/{{Primary_Member__r_Id}}","target":"_blank"}}},{"name":"Primary_Member_Email__c","label":"","sort":"false","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Primary_Member_Email__c}}","title":"{{Primary_Member_Email__c}}","value":"mailto:{{Primary_Member_Email__c}}","target":"_blank"}}},{"name":"Primary_Member_Phone_Number__c","label":""}]},{"header":"Notes","metadata":[{"name":"New_Tour_Notes__c","label":"",}]},{"header":"Opportunity","metadata":[{"name":"Opportunity__r_Name","label":"","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Opportunity__r_Name}}","value":"/{{Opportunity__c}}","target":"_blank"}}},{"name":"Opportunity__r_Owner_Name","label":"Owner"}]},{"header":"Company","metadata":[{"name":"Company_Name__c","label":"","type":"component","component":{"name":"ui:outputUrl","attributes":{"label":"{{Company_Name__c}}","value":"/{{Opportunity__r_AccountId}}","target":"_blank"}}},{"name":"Opportunity__r_RecordType_Name","label":""}]},{"header":"","metadata":[{"name":"Tours_Visited__c","label":""}]}];
        var records = [{"Id":"{{Id}}","Name":"{{Name}}","booked_by_contact_id__r_Name":"{{booked_by_contact_id__r.Name}}, {{Booked_By_User_Role__c}}","Primary_Member__r_Id":"{{Primary_Member__r.Id}}","Primary_Member__r_Name":"{{Primary_Member__r.Name}}","Primary_Member_Email__c":"{{Primary_Member_Email__c}}","Primary_Member_Phone_Number__c":"{{Primary_Member_Phone_Number__c}}","New_Tour_Notes__c":"{{New_Tour_Notes__c}}","Opportunity__r_Name":"{{Opportunity__r.Name}}","Opportunity__r_AccountId":"{{Opportunity__r.AccountId}}","Opportunity__r_Owner_Name":"{{Opportunity__r.Owner.Name}}, {{Opportunity__r.Owner.UserRole.Name}}","Opportunity__r_RecordType_Name":"{{Opportunity__r.RecordType.Name}}","Opportunity__c":"{{Opportunity__c}}","Company_Name__c":"{{Company_Name__c}}","Tours_Visited__c":"{{Tours_Visited__c}}"}];
        metaFields.splice(0, 0, {"name":"Detailed Info", "label":"","value":"Demo Data", 'sort':'false', "type":"component", "component":{"name":"c:WePopover", "attributes":{"type":"brand","name":"{{Id}}","size":"large","headerText":"Tour Details", "onclose":component.getReference("c.openPopup"), "recordsData": records,"dataForPopover": dataForPopover, "init":component.getReference("c.managePopupdata")}}});
        component.set("v.metaFields", metaFields);
        let opportunityColumns = [{"fieldName": "Name", "sortable": true, "label" : "Name", type:"url",typeAttributes:{ label: { fieldName : 'Name'}}},
                                  {"fieldName": "Tour_Date__c", "label" : "Tour Date", "type" : "Date", "sortable": true}];
        component.set("v.opportunityMetaFields", opportunityColumns);
    },
    subscribeTourOutcomePushTopic : function (component, event, helper) {
        $.cometd.init({
            url: '/cometd/42.0',
            requestHeaders: {"Authorization": "OAuth "+component.get("v.loggedInUserInfo").sessionId},
            appendMessageTypeToURL: false
        });
        $.cometd.subscribe('/topic/TourOutcomeForm', function(message) {
            var sobject = message.data.sobject;
            var rescheduledTour = component.get("v.reshcheduledTour");
            var followupTour = component.get("v.createNewTour");
            let newtour = component.get("v.NewTour");
            let objData = {"startDate": component.get("v.startDate"), "endDate":component.get("v.endDate"), "selectedStatus":component.get("v.selectedStatus"), "bookedBy":component.get("v.bookedBy"), "assignHost": component.get("v.assignHost"), "companyName":component.get("v.companyName")};
            let redirectUrl = "/apex/communityView?building_id="+component.get("v.buildingInfo.Id")+((component.get("v.productLine") != null && component.get("v.productLine") != "")?"&product_line="+component.get("v.productLine"):"")+'&url_Data='+(encodeURI(JSON.stringify(objData)));
            if(newtour && sobject && newtour.id && sobject.uuid__c && newtour.id == sobject.uuid__c){
                component.find("utils").redirectToUrl(redirectUrl,'',false);
            } else if(rescheduledTour && sobject && rescheduledTour.id && sobject.uuid__c && rescheduledTour.id == sobject.uuid__c){
                component.find("utils").redirectToUrl(redirectUrl,'',false);
            } else if(followupTour && sobject && followupTour.id && sobject.uuid__c && followupTour.id == sobject.uuid__c){
                component.find("utils").redirectToUrl(redirectUrl,'',false);
            }   
        });
    },
    actionHandler:function(component,event,helper,selectedMenu){
        var selectedTour = component.get("v.records")[component.get("v.records").findIndex(x => x.Id==selectedMenu.split(":")[0])];
        var action = selectedMenu.split(":")[1].toLowerCase();
        switch(action){
            case "tour-details":
                helper.redirectToTourDetails(component,selectedTour);
                break;
            case "outcome-tour":
                helper.redirectToOutcome(component,selectedTour);
                break;
            case "reschedule-tour":
                helper.showRescheduleModal(component,selectedTour);
                break;
            case "cancel-tour":
                helper.cancleTourModal(component,selectedTour);
                break;
            case "assign-host":
                helper.assignHost(component,selectedTour);
                break;
            case "assign-to-me":
                helper.assignToSelf(component , event , helper,selectedTour);
                break;
            case "next-follow-up":
                helper.showFollowupTourModal(component,selectedTour);
                break;
            case "view-history":
                helper.viewTourHistory(component,helper,selectedTour);
                break;
            case "related-tours":
                helper.viewRelatedToursOfAccount(component,helper,selectedTour);
                break;
            case "send-paperwork":
                var tourData = selectedTour;
                helper.sendPWModal(component,helper,selectedTour);
                break;
            case "no-show":
                helper.saveNoShow(component,helper,selectedTour);
                break;
        }
    },
    redirectToTourDetails: function(component ,selectedTour){
        window.open('/'+selectedTour.Id);
    },
    redirectToOutcome : function(component ,selectedTour){
        var objData = {"startDate": component.get("v.startDate"), "endDate":component.get("v.endDate"), "selectedStatus":component.get("v.selectedStatus"), "bookedBy":component.get("v.bookedBy"), "assignHost": component.get("v.assignHost"), "companyName":component.get("v.companyName")};
        component.find("utils").redirectToUrl("/apex/TourOutcomeForm?Id="+selectedTour.Id+"&communityView=true&buildingId="+selectedTour.Location__c+"&url_Data="+(encodeURI(JSON.stringify(objData))),"",false);
    },
    showRescheduleModal : function(component,selectedTour){
        if(selectedTour){
            component.set("v.tourData",selectedTour);
            component.set("v.tour.building",component.get("v.buildingInfo.Id"));
            component.set("v.tour.tourDate",null);
            component.set("v.tour.notes",selectedTour.New_Tour_Notes__c);
            component.set("v.tour.booked_by_contact_id__c",selectedTour.booked_by_contact_id__c);
            component.find("tourRescheduleModal").showModal();
        }
    },
    showFollowupTourModal : function(component ,selectedTour){
        if(selectedTour){
            component.set("v.followTourData",selectedTour);
            component.set("v.followTour.building",component.get("v.buildingInfo.Id"));
            component.set("v.followTour.tourDate",null);
            component.set("v.followTour.notes", null);
            component.find("followUpTourModal").showModal();
        }
    },
    cancleTourModal : function(component , selectedTour){
        if(selectedTour){
            component.set("v.tourData",selectedTour);
            component.set("v.cancellationReason",null); 
            var searchId = document.getElementById('searchId');
            if(searchId)
                searchId.click();
            component.find("tourCancelationModal").showModal();
        }
    },
    assignHost : function(component,selectedTour){
        component.set("v.tourData",selectedTour);
        component.find("NewAssignModal").showModal();
    },
    assignToSelf : function(component , event , helper,selectedTour){
        component.set("v.tourData",selectedTour);
        const userInfo = $A.get("$SObjectType.CurrentUser.Email");
        const query = 'SELECT Id, Name FROM Contact where Email ='+"'"+ component.find("utils").addSlashes(userInfo) +"'";
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":query},function(response){
            helper.assignToSelfProcessQueryResult(component, helper, response)
        },function(error){
            helper.handleErrorResponse(component, error);
        });
    },
    assignToSelfProcessQueryResult : function (component, helper, response){
        if(response != undefined && response.length > 0){
            const assignedHostId = response[0].Id;
            const tourToUpdate = {Id: component.get("v.tourData.Id"), Assigned_Host__c: assignedHostId};
            let action = component.get("c.updateSapiWithNewAssignedHost");
            action.setParams({ uuid : component.get("v.tourData.uuid__c"), contactSfId : assignedHostId});
            action.setCallback(this, function(response) {
                helper.assignHostProcessSapiResponse(component, helper, response, tourToUpdate, false);
            });
            $A.enqueueAction(action);
        }
        else{
            helper.handleErrorResponse(component, "Contact With Logged In User\'s Email Does not Exist.");
        }
    },
    assignHostProcessSapiResponse : function(component, helper, response, tourToUpdate, withinModal){
        if(response.returnValue.success)
        {
            component.find("utils").execute("c.saveRecord",{"record":tourToUpdate},function(response){
                helper.getTourInfo(component,event,helper,function(tourRecords){
                    helper.displayToursOnSuccess(component, tourRecords);
                },function(error){
                    helper.handleErrorResponse(component, error);
                });
                if(withinModal)
                {
                    component.set("v.selectedAssignHost",'');
                    component.find("NewAssignModal").close();
                    component.find("utils").hideProcessing();
                }
            },function(error){
                helper.handleErrorResponse(component, error);
            });
        }
        else
        {
            helper.handleErrorResponse(component, response.returnValue.message);
        }
    },
    displayToursOnSuccess : function(component, tourRecords){
        component.find("utils").hideProcessing();
        component.find("utils").showSuccess('Records saved successfully.');
        component.set("v.records",JSON.parse(tourRecords));
    },
    handleErrorResponse : function (component, inResponse){
        component.find("utils").hideProcessing();
        component.find("utils").showError(inResponse);
    },
    viewTourHistory:function(component,helper,selectedTour){
        component.set("v.tourHistoryData.contactInfo",selectedTour.Primary_Member__r);
        helper.setTourHistoryMetaFieds(component);
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getQueryData",{"query":"Select Id,Email,Name,(Select Id,Name,Primary_Member_Email__c,Primary_Member_Phone_Number__c,Company_Name__c,Location__r.Name,Tour_Date__c from tours3__r) FROM Contact Where ID='"+selectedTour.Primary_Member__c+"'"},function(response){
            component.find("utils").hideProcessing();
            if(response && response.length){
                component.set("v.tourHistoryData.tours",response[0].Tours3__r);
                component.find("viewContactTourHistory").showModal();
            }
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },
    setTourHistoryMetaFieds:function(component){
        var lstMetaFields = [];
        lstMetaFields.push({"name": "Name", "label": "Name", "type":"component", "component":{"name": "ui:outputUrl", "attributes": {"label":"{{Name}}", "value":"/{{Id}}", "target":"_blank"}}});
        lstMetaFields.push({"name": "Tour_Date__c", "label": "Date", "type": "date"});
        lstMetaFields.push({"name": "Primary_Member_Email__c", "label": "Email",'sort': 'false',"type": "email","target": "_blank"});
        lstMetaFields.push({"name": "Primary_Member_Phone_Number__c", "label": "Phone", 'sort': 'false'});
        lstMetaFields.push({"name": "Company_Name__c", "label": "Company", "type":"String"});
        lstMetaFields.push({"name": "Location__r.Name", "label": "Building", "type":"string"});
        component.set("v.tourHistoryMetaFields",lstMetaFields);
    },
    viewRelatedToursOfAccount:function(component,helper,selectedTour){
        var settingData =  component.get("v.setting");    
        if(selectedTour && selectedTour.Primary_Member__r && selectedTour.Primary_Member__r.AccountId && settingData.ReportId != null){   
            var url = "/lightning/r/Report/"+settingData.ReportId+"/view?&fv0=";
            url += selectedTour.Primary_Member__r.AccountId.substring(0,15);
            window.open(url,"_blank");
        }else{
            component.find("utils").showError("Account not found on primary member of selected tour.");
        }    
    },
    redirectTosendPaperworkUrl:function(component,helper,selectedTour){
        var oppoId = component.get("v.contactNames.opportunityId");
        if(oppoId != null){
            var frameHeight = screen.height/2 - 700/2;
            var frameWidth = screen.width/2 - 450/2;
            window.open("/apex/sendPaperWork?Id="+oppoId,"SendPaperwork","height=500,width=1250,left=70,top=100,scrollbars=yes");
            component.set("v.OrgRecord",{});
            component.set("v.contactNames.Email",null);
            component.set("v.contactNames.AccountId",null);
            component.set("v.contactNames.PrimaryMember",null);
            component.set("v.contactNames.opportunityId",null);
            component.set("v.contactNames.Name",null);
            component.set("v.contactNames.oppOwner",null);
            component.set("v.contactNames.buildingName",null);
            component.set("v.contactNames.desks",null);
            component.set("v.contactNames.CloseDate",null);
            component.set("v.contactNames.stage",null);
            component.set("v.contactNames.isContact",true);
            component.set("v.contactNames.processingCompleted",false);
            component.set("v.contactNames.selectedAction",null);
            component.set("v.contactNames.LeadId",null);  
        }
    },
    sendPWModal:function(component,helper,selectedTour){
        component.set("v.keyword",null);
        component.set("v.createOpportunityLink",false);
        component.set("v.oppFound",true);
        if(selectedTour.Primary_Member__c){
            component.set("v.contactNames.Email",selectedTour.Primary_Member_Email__c);
            component.set("v.contactNames.Name",selectedTour.Primary_Member__r.Name);
            component.set("v.contactNames.AccountId",selectedTour.Primary_Member__r.AccountId);
            component.set("v.contactNames.PrimaryMember",selectedTour.Primary_Member__r.Account.Primary_Member__c);
            if(selectedTour.Opportunity__c){
                component.set("v.contactNames.opportunityId",selectedTour.Opportunity__c);
                component.set("v.contactNames.opportunityName",selectedTour.Opportunity__r.Name);
                component.set("v.contactNames.oppOwner",selectedTour.Opportunity__r.Owner.Name );
                component.set("v.contactNames.buildingName",selectedTour.Opportunity__r.Building__r.Name);
                component.set("v.contactNames.desks",selectedTour.Opportunity__r.Quantity__c);
                component.set("v.contactNames.CloseDate",selectedTour.Opportunity__r.CloseDate);
                component.set("v.contactNames.PrimaryMemberName",selectedTour.Opportunity__r.Account.Primary_Member__r.Name);
                component.set("v.contactNames.stage",selectedTour.Opportunity__r.StageName);
                component.set("v.contactNames.accountPrimaryMemberEmail",selectedTour.Opportunity__r.Account.Primary_Member__r.Email);
                component.set("v.sendPPWKEmail",true);
                component.find("sendPaperworkModal").showModal();
            }else{
                component.find("utils").hideProcessing();
                component.find("utils").showError("Related Opportunity not found for selected tour.");
            }  
        }else{
            component.find("utils").hideProcessing();
            component.find("utils").showError("Related Primary Member not found for selected tour.");
        }
    },
    clearFilters:function(component,event,helper){
        component.set("v.startDate","");
        component.set("v.endDate","");
        component.set("v.selectedStatus","");
        component.set("v.bookedBy","");
        component.set("v.assignHost","");
        component.set("v.companyName","");
        helper.resetTable(component);
    },
    saveNoShow : function(component,helper,selectedTour) {
        component.find("utils").showProcessing();
        var loggedInUser = component.get("v.loggedInUserInfo");
        if( selectedTour.uuid__c !=undefined && selectedTour.uuid__c !='' )
        {
            var settings = JSON.parse(JSON.stringify(component.get("v.setting")));
            var tourToNoShow = {
                "id": selectedTour.uuid__c
            };
            var url = settings.NoShowAPI.url;
            url = url.replace("tour_uuid", selectedTour.uuid__c);
            var headers = {"Content-Type":"application/json","Authorization":settings.NoShowAPI.Headers.Authorization,"CONTEXT_SALESFORCE_ID":loggedInUser.UserId};
            component.find("utils").execute("c.executeRest", {"method": "POST","endPointUrl": url,"headers": headers,"body": JSON.stringify(tourToNoShow)}, function(response){
                var response = JSON.parse(response);
                component.find("utils").hideProcessing();
                if(response.hasOwnProperty("error")){                        
                    component.find("utils").hideProcessing(); 
                    if((response.hasOwnProperty("error")) && (response.hasOwnProperty("message")))
                        component.find("utils").showError(response.message);
                    else
                        component.find("utils").showError(response.error);
                }else{
                    component.find("utils").showSuccess("Tour no show successfully saved.");
                }
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError("Not able to save the record successfully, Please try again or contact your administrator.");
            });  
        }else{            
            component.find("utils").hideProcessing();
            component.find("utils").showError("Not able to save the record successfully because Tour UUID should Not be blank, Please try again or contact your administrator.");
        }
    },
    resetTable:function(component){
        component.set("v.tourTableAttributes",{'currentPage':1,'pageSize':25,'keyword':''});
    },
    resetOpportunityTable:function(component){
        component.set("v.OpportunityTableAttributes",{'currentPage':1,'pageSize':10});
    },
    getOpenOpportunities : function(component,  accountId, onSuccess){
        var OppCloseStages = component.get("v.setting").OppCloseStages;
        var OppCloseContractStage = component.get("v.setting").OppCloseContractStage;
        var query = 'SELECT Id,Name,Building__c,Billing_Account__c,Billing_Account__r.Name,Account.Name,Building_uuid__c,Building__r.Name,Account.Account_Type__c,Account.Interested_in_Number_of_Desks__c,Owner.Name,Quantity__c,CreatedDate,StageName,CloseDate,Account.Primary_Member__r.Email,Account_Primary_Member__c,Billing_Account__r.Primary_Member__r.Email  From Opportunity Where AccountId = '+"'"+accountId+"'"+' AND StageName NOT IN ('+"'"+OppCloseStages.join("','")+"'"+')  AND Contract_Stage__c NOT IN ('+"'"+OppCloseContractStage.join("','")+"'"+') order by CreatedDate desc';
        component.find("utils").execute("c.getQueryData",{"query":query},function(response){
            onSuccess(response);
        },function(error){
            component.find("utils").showError(error);
            component.find("utils").hideProcessing();
        })     
    },
    clearContactFields:function(component,event,helper){
        component.set("v.contactNames.Email",null);
        component.set("v.contactNames.AccountId",null);
        component.set("v.contactNames.PrimaryMember",null);
        component.set("v.contactNames.opportunityId",null);
        component.set("v.contactNames.Name",null);
        component.set("v.contactNames.AccountName",null);
        component.set("v.contactNames.FirstName",null);
        component.set("v.contactNames.LastName",null);
        component.set("v.contactNames.Phone",null);
        component.set("v.contactNames.oppOwner",null);
        component.set("v.contactNames.buildingName",null);
        component.set("v.contactNames.desks",null);
        component.set("v.contactNames.CloseDate",null);
        component.set("v.contactNames.stage",null);
        component.set("v.createOpportunityLink",false);
        component.set("v.contactNames.isContact",true);
        component.set("v.contactNames.LeadCompany",null);
        component.set("v.contactNames.LeadName",null);
        component.set("v.contactNames.LeadPhone",null);
        component.set("v.contactNames.LeadInterestedinNumberofDesks",null);
        component.set("v.contactNames.LeadFullTimeEmployees",null);
        component.set("v.contactNames.LeadBuildingInterested",null);
        component.set("v.contactNames.LeadSourceDetail",null);
        component.set("v.contactNames.LeadSource",null);
    },
    clearLeadFields:function(component,event,helper){
        component.set("v.leadFormData.FirstName",'');
        component.set("v.leadFormData.LastName",'');
        component.set("v.leadFormData.Phone",'');
        component.set("v.leadFormData.Company",'');
        component.set("v.leadFormData.Email",'');
        component.set("v.leadFormData.Description",'');
        component.set("v.leadFormData.Number_of_Full_Time_Employees__c",'');
        component.set("v.leadFormData.Interested_in_Number_of_Desks__c",'');
    },
    clearEntity:function(component,event,helper){
        var objContact = {"Id":null,"Email":null,"createOpportunityLink":false,"AccountId":null,"opportunityId":null,"Name":null,"oppFound":false,"isContact":true,"oppOwner":null,"oppOwner":null,"buildingName":null,"desks":null,"CloseDate":null,"stage":null,"LeadPhone":null,"LeadCompany":null,"LeadBuildingInterested":null,"LeadFullTimeEmployees":null,"LeadInterestedinNumberofDesks":null,"LeadSourceDetail":null,"LeadSource":null,"LeadAccount":null,"selectedAction":null,"processingCompleted":false};
        var selectedContact = component.get("v.contactNames");
        component.set("v.relatedOpportunities",[]);
        component.set("v.contactNames",Object.assign(selectedContact,objContact));
    },
    continueAfterAccountSelector:function(component,helper,onsuccess,onerror){
        component.get("v.helperModules.utils").showProcessing();
        helper.convertLeadToExisting(component,helper,function(message){
            if(message){
                onsuccess(message);
                helper.redirectTosendPaperworkUrl(component,event,helper); 
                component.get("v.helperModules.utils").hideProcessing();
            }
        },function(error){
            onerror(error);
        });
    },
    convertLeadToExisting:function(component,helper,onsuccess,onerror){
        var selectedAction;
        var OrgRecord = component.get("v.OrgRecord");
        if(component.get("v.contactNames.selectedAction") == "Use Selected to Convert"){
            selectedAction =  component.get("v.contactNames.selectedRecord");
        }else{
            selectedAction =  OrgRecord.Id;
        }
        var leadtocreate = {};
        let lead = component.get("v.selectedObject");
        if(selectedAction){
            if(lead && lead.leadId ||(lead.Id && lead.Id.startsWith('00Q'))){
                leadtocreate.Id = lead.leadId ? lead.leadId : lead.Id;
                leadtocreate.Email = lead.Email;
                leadtocreate.Number_of_Full_Time_Employees__c = lead.Number_of_Full_Time_Employees__c;
            }else{
               leadtocreate.Id = component.get("v.contactNames.Id"); 
            }
            leadtocreate.Account__c = selectedAction;
            component.get("v.helperModules.utils").execute("c.convertLeadsToExistingAccountandOpportunity",{"objLead":leadtocreate,"buildingId":component.get("v.building")},function(response){
                component.get("v.helperModules.utils").hideProcessing();
                if(response){
                    if(lead.type == 'lead' && response["contact"] && response["opportunity"] && response["contact"].length){
                        helper.bookATour(component, helper, response["contact"][0], response["opportunity"]);
                    }else if(response["opportunity"]){
                        component.set("v.contactNames.opportunityId", response["opportunity"].Id);
                    }
                    onsuccess("Lead Converted successfully.");
                }else{
                    onerror("Opportunity not found.");
                }
            },function(error){
                onerror(error);
            }, component);
        } else {
            onsuccess(null);
        }   
    },
    getSequence : function(lstMenuSequence, metaFields, keyElement){
        var menuItems = [];
        lstMenuSequence.forEach(function(sequenceValue){
            var index = metaFields.findIndex(metaFields => metaFields[keyElement].toLowerCase() === sequenceValue.toLowerCase());
            if(index != -1){
                menuItems.push(metaFields[index]);  
            }
        }); 
        return menuItems
    },
    setFilters : function(component, event, helper){
        var urlData = component.get("v.urlData");
        urlData = JSON.parse(decodeURI(urlData)); 
        for(var key in urlData){
            if(urlData[key] != 'undefined' && urlData[key] != 'null'){
                component.set("v."+key, urlData[key]);
            }
        }
    },
    setInstantTour: function(component, helper, sObject){
        component.set("v.showAccountSelector", false);
        let selectedObject = {"contactId":"Id", "AccountId":"Account.Id", "type":"type", "Name":"Name", "Company":"Company", "Number_of_Full_Time_Employees__c":"Number_of_Full_Time_Employees__c", "Interested_in_Number_of_Desks__c":"Interested_in_Number_of_Desks__c", "Email":"Email", "Phone":"Phone", "Unomy_Company_Size__c":"Unomy_Company_Size__c"};
		component.set("v.AccountFTE", false);
        component.set("v.AccountNOD", false);
        Object.keys(selectedObject).forEach(function(key) {
            selectedObject[key] = sObject ? selectedObject[key].includes('.') ? helper.getDataFromRelatedRecordField(selectedObject[key], sObject): sObject[selectedObject[key]] ? sObject[selectedObject[key]] : null : null;
        });
         if(selectedObject["contactId"] && selectedObject["contactId"].startsWith('00Q')){
            selectedObject["leadId"] = selectedObject["contactId"];
            selectedObject["contactId"] = null;
            component.set("v.showFTE", true);
             if(sObject["Unomy_Company_Size__c"]){
                 selectedObject["Number_of_Full_Time_Employees__c"] = helper.getUnomyCompanySize(sObject["Unomy_Company_Size__c"]);  
             }else if(sObject["Number_of_Full_Time_Employees__c"]){
                  selectedObject["Number_of_Full_Time_Employees__c"]  = sObject["Number_of_Full_Time_Employees__c"];
             }
        }else{
            if(sObject){
                if(sObject["Full_Time_Employees__c"]){
                    selectedObject["Number_of_Full_Time_Employees__c"] = sObject["Full_Time_Employees__c"];
                    component.set("v.AccountFTE", true);
                }
                if(sObject["Account"] && sObject["Account"]["Interested_in_Number_of_Desks__c"]){
                    selectedObject["Interested_in_Number_of_Desks__c"] = sObject["Account"]["Interested_in_Number_of_Desks__c"];
                    component.set("v.AccountNOD", true);
                }
            }
            if(selectedObject["Number_of_Full_Time_Employees__c"]){
                component.set("v.showFTE", false);
            }else{
                component.set("v.showFTE", true);
            }  
        }
        if(selectedObject["Phone"]){
            component.set("v.showPhone", false);
        }else{
            component.set("v.showPhone", true);
        }
        component.set("v.selectedObject", selectedObject);
        if(sObject == null){
            component.set("v.expandSections.instantTourProfile", false);
            component.set("v.expandSections.instantTourInformation", false);
            var listdiv = document.getElementById("listbox-unique-id");        
            $A.util.addClass(listdiv, "slds-hide");
            component.set("v.instantTour.tourDate", null);
            component.set("v.instantTour.startTime", null);
            component.set("v.instantTour.building", null);
            component.set("v.instantValid", false);
        }else{
            component.set("v.expandSections.instantTourProfile", true);
            component.set("v.expandSections.instantTourInformation", true);
        } 
    },
    getUnomyCompanySize:function(companySize){
        if(companySize.includes(',')){
            companySize = companySize.replace(/,/g, "");
        }
        var isUpperRange = companySize.includes('-');
        var isLowerRange = companySize.includes('+');
        
        if(isUpperRange){
            var arr = companySize.split('-');
            if(arr.length > 1){
                arr =  arr[0].split(' ');
                if(arr[0] != '')
                    return arr[0];
                else
                    return arr[1];
            }else{
                return arr[0].substring(0,arr[0].length-1)
            }
        }else if(isLowerRange){
            if(companySize.slice(companySize.length-1,companySize.length) == '+')
                companySize = companySize.slice(0, -1);
            return companySize;
            
        }
        return companySize;
    },
    loadtimeSlotsForTours: function(component, event, helper,onSuccess, urlParameters){
        component.get("v.helperModules.utils").showProcessing();
        let buildingNotSelected = (component.get("v.instantTour.building") || (urlParameters && urlParameters.UUID__c));
        if(component.get("v.instantTour.tourDate") && buildingNotSelected){
            component.get("v.helperModules.TourExternalAPI").loadTimeSlots({"show_past":null, "product_line":"WeWork", "date":component.get("v.instantTour.tourDate"), "building_id":urlParameters ? urlParameters.UUID__c : component.get("v.buildingInfo").UUID__c, "building_Name": urlParameters ? urlParameters.Name : component.get("v.buildingInfo").Name}, function(response){
                component.get("v.helperModules.utils").hideProcessing();
                component.set("v.instantTour.available_tour_times", response);
                if(onSuccess){
                    onSuccess(response); 
                }
            },function(error){
                component.set("v.instantTour.startTime", null);
                component.set("v.instantTour.available_tour_times", []);
                component.get("v.helperModules.utils").hideProcessing();
                component.get("v.helperModules.utils").showError(error);
            })
        }else if(!(buildingNotSelected)){
            component.get("v.helperModules.utils").showError('Please select a building to load available time slots');
            component.get("v.helperModules.utils").hideProcessing();
        }else if(!(component.get("v.instantTour.tourDate"))){
            component.get("v.helperModules.utils").showError('Please select a tour date to load available time slots');
            component.get("v.helperModules.utils").hideProcessing();
        }
    },
    getDataFromRelatedRecordField:function(field, object){
        let objectFields = field.split('.');
        if(objectFields.length == 2 && object[objectFields[0]]){
            return object[objectFields[0]][objectFields[1]]; 
        }
    },
    bookATour: function(component, helper, contactInfo, Opportunity){
        let instantTour = component.get("v.instantTour");
        let index = helper.getBuildingUUIDFromList(component.get("v.AllWeWorkBuildings"), 'Id', instantTour.building);
        instantTour.building_id = (index && index > 0) ? component.get("v.AllWeWorkBuildings")[index].UUID__c : component.get("v.buildingInfo.UUID__c");
        instantTour.LeadSource = contactInfo.LeadSource ? contactInfo.LeadSource : "Walk In";
        instantTour.opportunityId = Opportunity;
        instantTour.LeadSourceDetail = contactInfo.Lead_Source_Detail__c ? contactInfo.Lead_Source_Detail__c : "Community Registration";
        let payload = component.get("v.helperModules.TourExternalAPI").createPayload({"formData":instantTour,"contact":contactInfo,"account":null,"loggedInUserContact":component.get("v.loggedInUserInfo")});
        component.get("v.helperModules.utils").showProcessing();
        component.get("v.helperModules.TourExternalAPI").bookATour(payload, function(response){
            component.get("v.helperModules.utils").hideProcessing();
            if(response.hasOwnProperty('error')){
                component.get("v.helperModules.utils").showError(response.message);
            }else if(response.hasOwnProperty('tour')){
                component.set("v.NewTour", response["tour"]);
                component.get("v.helperModules.utils").showSuccess("Tour Booked Successfully and will sync shortly")
            }
            component.find("InstantTourModal").close();
            helper.setInstantTour(component, helper, null);
        },function(error){
            component.get("v.helperModules.utils").hideProcessing();
            component.get("v.helperModules.utils").showError(error);
        })
    },
    updateRelatedRecord:function(component,event,helper,onSuccess,onError) {
        if(component.get("v.selectedObject.type") == "contact"){
            var conRecord = {"Id":component.get("v.selectedObject.contactId"), "Interested_in_Number_of_Desks__c":component.get("v.selectedObject.Interested_in_Number_of_Desks__c"), "Number_of_Full_Time_Employees__c":component.get("v.selectedObject.Number_of_Full_Time_Employees__c")};
            var accRecord;
            var listRecords = [conRecord];
            if(component.get("v.AccountNOD") == false && component.get("v.AccountFTE") == false ){
                accRecord = {"Id":component.get("v.selectedObject.AccountId"), "Interested_in_Number_of_Desks__c":component.get("v.selectedObject.Interested_in_Number_of_Desks__c"), "Number_of_Full_Time_Employees__c":component.get("v.selectedObject.Number_of_Full_Time_Employees__c")};
            }else if(component.get("v.AccountFTE") == false ){
                accRecord = {"Id":component.get("v.selectedObject.AccountId"), "Number_of_Full_Time_Employees__c":component.get("v.selectedObject.Number_of_Full_Time_Employees__c")}
            }else if(component.get("v.AccountNOD") == false){
                accRecord = {"Id":component.get("v.selectedObject.AccountId"), "Interested_in_Number_of_Desks__c":component.get("v.selectedObject.Interested_in_Number_of_Desks__c")}
            }
            if(accRecord != null){
                listRecords = [conRecord, accRecord];
            }
            component.find("utils").execute("c.saveRecords",{"records":listRecords}, function(response){
                onSuccess();
                component.get("v.helperModules.utils").hideProcessing();
            },function(error){
                component.get("v.helperModules.utils").hideProcessing();
                component.get("v.helperModules.utils").showError(error);
            }); 
            
        }else if(component.get("v.selectedObject.type") == "lead"){
            component.find("utils").execute("c.saveRecord",{"record":{"Id":component.get("v.selectedObject.leadId"), "Interested_in_Number_of_Desks__c":component.get("v.selectedObject.Interested_in_Number_of_Desks__c"), "Number_of_Full_Time_Employees__c":component.get("v.selectedObject.Number_of_Full_Time_Employees__c"), "Phone":component.get("v.selectedObject.Phone")}}, function(response){
                onSuccess();
                component.get("v.helperModules.utils").hideProcessing();
            },function(error){
                component.get("v.helperModules.utils").hideProcessing();
                component.get("v.helperModules.utils").showError(error);
            });
        }
    },
    setExpressionObj : function(component, event, helper){
        let objExp = {};
        objExp = {"{{Status__c}} == 'Cancelled' || {{Status__c}} == 'No Show' || {{Status__c}} == 'Rescheduled'" : "strike-through", "{{Status__c}} == 'Completed'" : "hightlight-row"};
        component.set("v.highlight", objExp);
    },
    getBuildingUUIDFromList: function(List, fieldTofind, valueTosearch){
        if(List && List.length){
          return List.findIndex(building => building[fieldTofind] == valueTosearch);  
        }
    }
})