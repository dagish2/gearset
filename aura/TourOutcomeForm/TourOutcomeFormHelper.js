({  
    execute: function(component, method, params, onSuccess, onError){
        var action = component.get(method);
        action.setParams(params);
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                onSuccess(response.getReturnValue());
            }else if(response.getState()=="ERROR"){
                var errors = response.getError();
                onError(errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    getFormData : function(component, event, helper) {
        component.get("v.utils").showProcessing();
        var id = component.get("v.recordId");
        var uuid = component.get("v.recordUUID");
        var shouldSetTheme = new Boolean(!window.location.href.includes('lightning')).valueOf('Boolean');
        component.set("v.theme", shouldSetTheme);
        let filterForTourIdentification = (id != null && id != '') ? component.get("v.recordId") : (uuid != null && uuid != '') ? component.get("v.recordUUID") : null;
        if(filterForTourIdentification){
            var rescheduledTourFields = [{"name": "Name", "label": "Name", "type": "component", "component": {"name": "ui:outputURL", "attributes": {"label": "{{Name}}", "value":"/{{Id}}", "target": "_blank"}}}, {"name": "Location__r.Name", "label": "Building Name", "type": "component", "component": {"name": "ui:outputURL", "attributes": {"label": "{{Location__r.Name}}", "value": "/{{Location__c}}", "target": "_blank"}}}, {'name': 'Tour_Date__c', 'label': 'Tour Date', 'type': 'date'}, {'name': 'Start_Time__c', 'label': 'Tour Time'}, {'name': 'Status__c','label': 'Status'}, {'name': 'Product_Line__c', 'label': 'Product Line'}, {'name': 'New_Tour_Notes__c', 'label': 'Notes'}];
            component.set("v.rescheduledTourFields", rescheduledTourFields);       
            component.set("v.rescheduleTour",{});
            helper.execute(component, "c.getFormData", {"parameters": {"label":"TourDetails","IdOrUUID":filterForTourIdentification}}, function(response){
                var arrBuildingsUuid = [];            
                response = JSON.parse(component.get("v.utils").removeSpecialCharacters(response.data));  
                helper.getOldTourdata(component, response);
                component.set("v.LoggedInUser", response.loggedInUser);  
                let tourRecord = response.tourRecord[0];
                if(tourRecord){
                component.set("v.tour", tourRecord);
                if(tourRecord.Primary_Member__r.Account.Unomy_Location_Country__c || tourRecord.Primary_Member__r.Account.Unomy_Location_State__c || tourRecord.Primary_Member__r.Account.Unomy_Location_City__c || tourRecord.Primary_Member__r.Account.Unomy_Location_Address__c){
                    component.set("v.showUnomyFields", true);
                }
                if(tourRecord.Primary_Member__r && tourRecord.Primary_Member__r.Account){
                    component.set("v.tourAccount", tourRecord);
                }
                response.tourRecord = response.tourRecord[0];
                component.set("v.buildingsList", response.buildings);
                if(response.tourRecord.Opportunity__c != null && response.tourRecord.Opportunity__c != 'undefined'){
                    component.set("v.referrer_Name", response.tourRecord.Opportunity__r.Referrer_Name__c);
                    component.set("v.referrer_Email", response.tourRecord.Opportunity__r.Referrer_Email__c);
                    component.set("v.opportunityId", response.tourRecord.Opportunity__c);
                }
                var buildingMap = {};
                response.buildings.forEach(function(building){
                    buildingMap[building.Name] = building;
                });            
                component.set("v.buildingMap", buildingMap);
                component.set("v.settings", response.setting);
                component.set("v.tourCompletedBy", response.tourCompletedBy);
                component.set("v.currentDate", response.currentDate);
                component.set("v.tourInterest", response.tourRecord.Tour_Outcome__c);
                component.set("v.tourOutcomeUUID", response.tourRecord.Tour_Outcome_UUID__c);
                component.set("v.sessionId", response.sessionId);
                component.set("v.rescheduleTour.building", response.tourRecord.Location__r.Id);
                component.set("v.rescheduleTour.notes", response.tourRecord.New_Tour_Notes__c);
                
                helper.getAPICallout(component, event, helper);
                
                if(response.tourRecord.Tour_Outcome_UUID__c!=undefined){
                    helper.getDecisionMakers(component, event, helper, function(){
                        helper.setObjections(component, event, helper, function(){
                            helper.setHowDidHearOptions(component, event, helper, function(){
                                helper.setUrgencies(component, event, helper, function(){
                                    component.set("v.tourOutcome",{
                                        "Unit_Type__c": response.tourRecord.Unit_Type__c,
                                        "Interested_Buildings__c": (JSON.parse(JSON.stringify(component.get("v.buildingMap")))[response.tourRecord.Interested_Buildings__c]!=undefined)?JSON.parse(JSON.stringify(component.get("v.buildingMap")))[response.tourRecord.Interested_Buildings__c].UUID__c:"",
                                        "Interested_in_Number_of_Desks__c": response.tourRecord.Interested_in_Number_of_Desks__c,
                                        "Outcome_Reservables__c": response.tourRecord.Outcome_Reservables__c,
                                        "Move_In_Date__c": response.tourRecord.Move_In_Date__c,
                                        "Urgency__c": component.get("v.mapUrgenciesOptions")[response.tourRecord.Urgency__c],
                                        "How_Did_You_Hear_About_Us__c": component.get("v.mapHowDidHearOptions")[response.tourRecord.How_Did_You_Hear_About_Us__c],
                                        "Objections__c": (response.tourRecord.Objections__c!=undefined)?component.get("v.mapObjections")[response.tourRecord.Objections__c.toLowerCase()]:"",
                                        "Current_Budget__c":response.tourRecord.Current_Budget__c,
                                        "Desired_Budget__c":response.tourRecord.Desired_Budget__c,
                                        "Is_Decision_Maker__c":response.tourRecord.Is_Decision_Maker__c,
                                        "Tour_Outcome_Notes__c":response.tourRecord.Tour_Outcome_Notes__c,
                                        "Decision_Maker__c" : response.tourRecord.Name_of_Decision_Maker__c,
                                        "No_Follow_Up__c": response.tourRecord.No_Follow_Up__c,
                                        "Lease_Expiration__c":response.tourRecord.Lease_Expiration__c
                                    });
                                    
                                    
                                    // (response.tourRecord.Lease_Expiration__c != undefined)? response.tourRecord.Lease_Expiration__c:undefined
                                    var isDecisionMaker = component.get("v.tourOutcome.Is_Decision_Maker__c");
                                    var tourOutcome = JSON.parse(JSON.stringify(component.get("v.tourOutcome")));
                                    var tourInterest = component.get("v.tourInterest");
                                    console.log("tourOutcome========>>>>>>"+tourOutcome);
                                    if(response.tourRecord.Status__c!=undefined && response.tourRecord.Status__c.toLowerCase()=='scheduled'){
                                        tourOutcome["Interested_Buildings__c"] = response.tourRecord.Location__r.UUID__c;
                                    } else if(response.tourRecord.Interested_Buildings__c!=undefined&&response.tourRecord.Interested_Buildings__c!=''){
                                        response.buildings.forEach(function(building){
                                            if(response.tourRecord.Interested_Buildings__c.toLowerCase()==building.Name.toLowerCase()){
                                                tourOutcome["Interested_Buildings__c"] = building.UUID__c;
                                            }
                                        });
                                    }
                                    if(response.tourRecord.Status__c.toLowerCase()=='no show'){
                                        component.get("v.utils").hideProcessing();
                                    }
                                    var arrReservableNames =[];
                                    if(response.tourRecord.Outcome_Reservables__c != undefined && response.tourRecord.Outcome_Reservables__c != ''){
                                        response.tourRecord.Outcome_Reservables__c.split(";").forEach(function(reservable){
                                            arrReservableNames.push(reservable);
                                        }); 
                                        var options = component.get("v.officesToShowOptions");
                                        if(options == undefined)
                                            options = [];
                                        var officesMap = {};
                                        var officesShown = {};
                                        var existngOfficesResult = {};
                                        var query = "SELECT Id, Name, Floor__c, UUID__c, Monthly_Price__c FROM Reservable__c WHERE Name IN ('"+ component.get("v.utils").addSlashes(arrReservableNames.join("','")) +"')";
                                        component.get("v.utils").execute("c.getQueryData",{"query":query},function(response){
                                            response.forEach(function(res){
                                                officesMap = JSON.parse(JSON.stringify(component.get("v.officesResult")));                                            
                                                options = component.get("v.officesToShowOptions")
                                                if(!officesMap.hasOwnProperty(res.UUID__c)){
                                                    options.push({"name": res.Name +':'+ res.Monthly_Price__c,
                                                                  "price": res.Monthly_Price__c,
                                                                  "floor": res.Floor__c,
                                                                  "uuid": res.UUID__c
                                                                 });
                                                    officesMap[res.UUID__c] = {
                                                        "name": res.Name +':'+ res.Monthly_Price__c,
                                                        "price": res.Monthly_Price__c,
                                                        "floor": res.Floor__c,
                                                        "uuid": res.UUID__c
                                                    };
                                                    existngOfficesResult[res.UUID__c] = {
                                                        "name": res.Name +':'+ res.Monthly_Price__c,
                                                        "price": res.Monthly_Price__c,
                                                        "floor": res.Floor__c,
                                                        "uuid": res.UUID__c
                                                    };
                                                }
                                                officesShown[res.UUID__c] = res;
                                            });
                                            var officesResult = JSON.parse(JSON.stringify(component.get("v.officesResult")));
                                            for (var key in officesMap) {
                                                if (!officesResult.hasOwnProperty(key)) {
                                                    officesResult[key] = officesMap[key];
                                                }
                                            }
                                            component.set("v.officesToShowOptions", options);
                                            component.set("v.officesResult", officesResult);
                                            component.set("v.existngOfficesResult", existngOfficesResult);                                        
                                            component.set("v.officesShown", Object.keys(officesShown).join(';'));
                                            helper.changeIsDecisionMaker(component, event, helper);
                                            component.get("v.utils").hideProcessing();
                                        },function(error){
                                            component.get("v.utils").hideProcessing();
                                            component.get("v.utils").showError(error);
                                        });
                                    } else {
                                        component.get("v.utils").hideProcessing();
                                    }
                                });
                            });
                        });
                    });                
                } else {
                    component.set("v.tourOutcome", {
                        "Interested_Buildings__c": response.tourRecord.Location__r.UUID__c,
                        "Is_Decision_Maker__c": true,
                        "Interested_in_Number_of_Desks__c": response.tourRecord.Interested_in_Number_of_Desks__c,
                        "Lease_Expiration__c": (response.tourRecord.Lease_Expiration__c != undefined)? response.tourRecord.Lease_Expiration__c:undefined
                    });
                    component.get("v.utils").hideProcessing();
                }
                var oldTour = {};
                if(component.get("v.officesShown"))
                    oldTour.oldOfficesShown =  component.get("v.officesShown");
                if(component.get("v.referrer_Name"))
                    oldTour.referrer_Name = component.get("v.referrer_Name");
                if(component.get("v.referrer_Email"))
                    oldTour.referrer_Email = component.get("v.referrer_Email");
                    component.set("v.oldTourData",oldTour);
                }else{
                    component.get("v.utils").hideProcessing();
                    component.get("v.utils").showWarning('The tour with provided Id is not present in salesforce. Please wait, we are redirecting you to community view page');
                    window.setTimeout(function(){
                        component.find("utils").redirectToUrl('/one/one.app#/alohaRedirect/apex/vfPageName/apex/CommunityView','',false);
                    }, 6000);
                }
            },function(error){
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError(error);
            }); 
        }else{
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError('Please provide either a Tour Id or a Tour UUID.');
        }
    },
    getOldTourdata : function(component,response){
        console.log(response);
        component.set("v.oldTourRecord",response.tourRecord);
    },
    changeOutcome : function(component, event, helper) { 
        helper.getDecisionMakers(component, event, helper, function(){
            var tour = JSON.parse(JSON.stringify(component.get("v.tour")));
            var tourOutcome = JSON.parse(JSON.stringify(component.get("v.tourOutcome")));
            console.log("tourOutcome"+tourOutcome);
            if(tourOutcome!=undefined){
                tourOutcome["Decision_Maker__c"] = (tour!=undefined&&tour.Primary_Member__r != undefined) ? tour.Primary_Member__r.Email : undefined;              
                if(tour.Lease_Expiration__c){
                    var d = new Date(tour.Lease_Expiration__c);
                    var n = d.toUTCString();
                    tourOutcome["Lease_Expiration__c"] = n;
                }
                delete tourOutcome.Objections__c;
                component.set("v.tourOutcome", tourOutcome);
            }       
            console.log("statusOfTour:"+tour.Status__c);
            component.set("v.tourStatus",tour.Status__c);
            component.get("v.utils").hideProcessing();
        }); 
        
        helper.setObjections(component, event, helper);
        helper.setHowDidHearOptions(component, event, helper);
        helper.setUrgencies(component, event, helper);
        
    },
    changeIsDecisionMaker: function(component, event, helper) {
        var isDecisionMaker = component.get("v.tourOutcome.Is_Decision_Maker__c");
        var tourOutcome = JSON.parse(JSON.stringify(component.get("v.tourOutcome")));
        var tourInterest = component.get("v.tourInterest");
        if(tourInterest!=undefined&&isDecisionMaker!=undefined&&isDecisionMaker==true&&tourOutcome.hasOwnProperty('Decision_Maker__c')){
            delete tourOutcome["Decision_Maker__c"];       
            component.set("v.tourOutcome", tourOutcome);
        }
        //component.set("v.tourOutcome", tourOutcome);
    },
    getDecisionMakers: function(component, event, helper, onsuccess){
        if(JSON.parse(JSON.stringify(component.get("v.tour"))).Primary_Member__r != undefined){
            if(JSON.parse(JSON.stringify(component.get("v.tour"))).Primary_Member__r.AccountId){
                var query = "SELECT Id, Name, Email FROM Contact WHERE AccountId ='"+JSON.parse(JSON.stringify(component.get("v.tour"))).Primary_Member__r.AccountId+"'";
                component.get("v.utils").execute("c.getQueryData",{"query":query},function(response){
                    var contactList = response;
                    //contactList = contactList.concat(response);
                    component.set("v.contactList", contactList);
                    if(onsuccess)
                        onsuccess();
                },function(error){
                    component.get("v.utils").hideProcessing();
                    component.get("v.utils").showError(error);
                });   
            }else{
                component.get("v.utils").showError("Tour's Primary Member Doesn't Have an Account");
            }
        }else{
            component.get("v.utils").showError("Tour Doesn't Have Primary Member");
        }
    },
    setObjections: function(component, event, helper, onsuccess){
        var settings = JSON.parse(JSON.stringify(component.get("v.settings")));
        var tourInterest = component.get("v.tourInterest");
        var url = settings.reasons.url;
        var headers = {"Content-Type":"application/json","Authorization":settings.reasons.headers.Authorization};
        component.get("v.utils").execute("c.executeRest", {"method": "GET","endPointUrl": url,"headers": headers,"body": ""}, function(response){
            response = JSON.parse(response);
            var objections = [];
            response.reasons.forEach(function(reason){
                if(tourInterest != undefined){
                    if(tourInterest.toLowerCase()=='interested' && reason.scope == 'interested'){
                        objections.push({
                            "reason": reason.text,
                            "id": reason.id
                        });
                    } else if((tourInterest.toLowerCase()=='not interested' || tourInterest.toLowerCase()=='did not show up') && reason.scope == 'uninterested'){
                        objections.push({
                            "reason": reason.text,
                            "id": reason.id
                        });                    
                    }
                }                       
            });
            component.set("v.objections", objections);
            var obj = []; 
            response.reasons.forEach(function(item){
                obj[item.text.toLowerCase()] = item.id;
            })
            component.set("v.mapObjections", obj);
            if(onsuccess)
                onsuccess();
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        });
    },
    setHowDidHearOptions: function(component, event, helper, onsuccess){
        var settings = JSON.parse(JSON.stringify(component.get("v.settings")));
        var url = settings.howHeards.url;
        var headers = {"Content-Type":"application/json","Authorization":settings.howHeards.headers.Authorization};
        component.get("v.utils").execute("c.executeRest", {"method": "GET","endPointUrl": url,"headers": headers,"body": ""}, function(response){
            response = JSON.parse(response);
            component.set("v.howDidHearOptions", response.how_heards);
            var obj = []; 
            response.how_heards.forEach(function(item){
                obj[item.text] = item.id;    
            })
            component.set("v.mapHowDidHearOptions", obj);
            if(onsuccess)
                onsuccess();
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        });
    },
    setUrgencies: function(component, event, helper, onsuccess){
        var settings = JSON.parse(JSON.stringify(component.get("v.settings")));
        var url = settings.urgencies.url;
        var headers = {"Content-Type":"application/json","Authorization":settings.urgencies.headers.Authorization};
        component.get("v.utils").execute("c.executeRest", {"method": "GET","endPointUrl": url,"headers": headers,"body": ""}, function(response){
            response = JSON.parse(response);
            component.set("v.urgenciesOptions", response.urgencies);
            var obj = []; 
            response.urgencies.forEach(function(item){
                obj[item.text] = item.id;    
            })
            component.set("v.mapUrgenciesOptions", obj);
            if(onsuccess)
                onsuccess();
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        });
    },
    getOfficeDetails : function(component, event, helper) {
        component.get("v.utils").showProcessing();
        var tourOutcome = JSON.parse(JSON.stringify(component.get("v.tourOutcome")));
        if(tourOutcome.Interested_Buildings__c != undefined && tourOutcome.Interested_Buildings__c!=""){
            //component.find("utils").showProcessing();
            var settings = JSON.parse(JSON.stringify(component.get("v.settings")));
            var location_uuids = [];
            var types = [];
            var moveInDate = "";
            var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
            if(tourOutcome.Move_In_Date__c!=undefined && tourOutcome.Move_In_Date__c!="") {
                tourOutcome.Move_In_Date__c = new Date(tourOutcome.Move_In_Date__c);
                moveInDate = tourOutcome.Move_In_Date__c.getFullYear() + "-" + months[tourOutcome.Move_In_Date__c.getMonth()]+ "-" + tourOutcome.Move_In_Date__c.getDate();                
            } else {
                moveInDate = this.firstOfNextMonth();
            }
            if(tourOutcome.Interested_Buildings__c != undefined && tourOutcome.Interested_Buildings__c!=""){
                var interestedBuilding = tourOutcome.Interested_Buildings__c;
                location_uuids.push(tourOutcome.Interested_Buildings__c);                
            }
            var requestPayload = {
                "available_date": moveInDate,
                "location_uuids": location_uuids,
                "include_pending_contracts": "No",
                "show_unavailable": false,
                "min_capacity": 1,
                "max_capacity": 999,
                "show_pending_contracts": false,
                "types": [],
                "per_page": 1000,
                "summary": false
            };
            console.log(requestPayload);            
            var url = settings.reservableAvailabilityAPI.url;
            var headers = {"Content-Type":"application/json","Authorization":settings.reservableAvailabilityAPI.headers.Authorization};
            component.get("v.utils").execute("c.executeRest", {"method": "POST","endPointUrl": url,"headers": headers,"body": JSON.stringify(requestPayload)}, function(response){
                var res = JSON.parse(response);
                if(res.result != undefined){
                    var reservables = [];//component.get("v.officesToShowOptions");
                    var officesResult = {};
                    if(component.get("v.existngOfficesResult")!=undefined && Object.keys(component.get("v.existngOfficesResult")).length>0){
                        /*JSON.parse(JSON.stringify(component.get("v.existngOfficesResult"))).forEach(function(officeOption){
                            reservables.push(officeOption);
                            officesResult[officeOption.uuid] = officeOption;
                        });*/
                        for (var officeOption in component.get("v.existngOfficesResult")) {
                            officesResult[officeOption] = component.get("v.existngOfficesResult")[officeOption];
                            reservables.push(component.get("v.existngOfficesResult")[officeOption]);
                        }
                    }
                    res.result.data.forEach(function(reservable){
                        if(!officesResult.hasOwnProperty(reservable.uuid)){                            
                            reservable['name'] = reservable.location_name+' - '+reservable.office_num+' ('+reservable.capacity+'):'+reservable.price;
                            reservables.push(reservable);
                            officesResult[reservable.uuid] = reservable;
                        }                                                
                    });
                    component.set("v.officesResult", officesResult);
                    component.set("v.officesToShowOptions", reservables);
                    component.get("v.utils").hideProcessing();
                } else {
                    component.get("v.utils").hideProcessing();
                    component.get("v.utils").showError(res.error);
                }
                component.get("v.utils").hideProcessing();
            },function(error){
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError(error);
            });
        }
    },
    save : function(component, event, helper) {
        component.get("v.utils").showProcessing();
        var tourInterest = "";
        var outcome = {};
        var places = [];
        var options = [];
        var unitTypes = {};
        var reasonIds = [];
        var officesResult = JSON.parse(JSON.stringify(component.get("v.officesResult")));
        var moveInDate = new Date(component.get("v.tourOutcome.Move_In_Date__c"));
        var tourOutcome = JSON.parse(JSON.stringify(component.get("v.tourOutcome")));
        var settings = JSON.parse(JSON.stringify(component.get("v.settings")));
        var interest = component.get("v.tourInterest");
        if(interest.toLowerCase()=="interested"){
            tourInterest = "interested";
        } else if(interest.toLowerCase()=="not interested"){
            tourInterest = "uninterested";
        } else if(interest.toLowerCase()=="ready to sign now"){
            tourInterest = "ready";
        }
        if (component.get("v.tourOutcome.Unit_Type__c") != undefined && component.get("v.tourOutcome.Unit_Type__c") != "") {
            component.get("v.tourOutcome.Unit_Type__c").split(";").forEach(function(type){
                unitTypes[type.replace(/\s/g, '')] = type;            
                if(type == "Office"){
                    options.push({
                        "capacity": tourOutcome.Interested_in_Number_of_Desks__c,
                        "line": "WeWork",
                        "product_type": type
                    });
                } else{
                    options.push({
                        "capacity": 1,
                        "line": "WeWork",
                        "product_type": type
                    });
                }            
            });  
        } 
        if(component.get("v.tourOutcome.Objections__c")!=undefined && component.get("v.tourOutcome.Objections__c")!=""){
            reasonIds.push(component.get("v.tourOutcome.Objections__c"));            
        }
        if(moveInDate!=undefined && moveInDate!=""){
            moveInDate = new Date(moveInDate);
        }else{
            moveInDate = "";
        }  
        
        if(component.get("v.tourOutcome.Interested_Buildings__c")!=undefined && component.get("v.tourOutcome.Interested_Buildings__c")!=""){
            places.push({
                "place_type": "Building",
                "place_id": component.get("v.tourOutcome.Interested_Buildings__c")
            });
        }
        if(component.get("v.officesShown")!=undefined && component.get("v.officesShown")!=""){                       
            component.get("v.officesShown").split(";").forEach(function(office){
                if(officesResult[office]!=undefined){
                    options.push({"reservable_uuid": officesResult[office].uuid,
                                  "reservable_name": (officesResult[office].name).split(":")[0],
                                  "reservable_floor": officesResult[office].floor,
                                  "reservable_price": officesResult[office].price
                                 });
                }
            });    
        }     
        outcome = {
            tour_id: JSON.parse(JSON.stringify(component.get("v.tour"))).uuid__c,
            status: tourInterest,
            status_text: "",
            expected_start_date: moveInDate,
            outcome_notes: component.get("v.tourOutcome.Tour_Outcome_Notes__c")                                
        };
        if(component.get("v.tourOutcomeUUID") != undefined) {
            outcome["id"] = component.get("v.tourOutcomeUUID");
        }
        if(tourInterest=="interested" || tourInterest=="ready") {
            outcome["interests_attributes"] = [{"places_attributes": places,"products_attributes": [{"options_attributes": options}]}];    
        }
        if(tourInterest=="interested" || tourInterest=="uninterested"){                                
            outcome["reason_ids"] = reasonIds;
            outcome["reason_notes"] = "";
        }
        if(component.get("v.tourCompletedBy") != undefined && JSON.parse(JSON.stringify(component.get("v.tourCompletedBy"))).UUID__c != undefined)
            outcome["tour_completed_by_uuid"] = JSON.parse(JSON.stringify(component.get("v.tourCompletedBy"))).UUID__c;
        else
            outcome["tour_completed_by_uuid"] = '';
        outcome["number_of_desks"] = component.get("v.tourOutcome.Interested_in_Number_of_Desks__c");
        outcome["current_paying"] = (component.get("v.tourOutcome.Current_Budget__c")!=undefined)?component.get("v.tourOutcome.Current_Budget__c"):"";
        outcome["desired_budget"] = (component.get("v.tourOutcome.Desired_Budget__c")!=undefined)?component.get("v.tourOutcome.Desired_Budget__c"):"";
        outcome["how_heard_id"] = (component.get("v.tourOutcome.How_Did_You_Hear_About_Us__c")!=undefined)?component.get("v.tourOutcome.How_Did_You_Hear_About_Us__c"):"";
        outcome["urgency_id"] = component.get("v.tourOutcome.Urgency__c");
        outcome["no_follow_up"] = (component.get("v.tourOutcome.No_Follow_Up__c")!=undefined)?component.get("v.tourOutcome.No_Follow_Up__c"):false;
        outcome["is_decision_maker"] = component.get("v.tourOutcome.Is_Decision_Maker__c");
        outcome["decision_maker_email"] = (component.get("v.tourOutcome.Is_Decision_Maker__c")!=undefined&&component.get("v.tourOutcome.Is_Decision_Maker__c"))?JSON.parse(JSON.stringify(component.get("v.tour"))).Primary_Member__r.Email:component.get("v.tourOutcome.Decision_Maker__c");
        console.log('outcome before callout ::'+JSON.stringify(outcome));
        
        var url = settings.createTourOutcomes.url;
        var headers = {"Content-Type":"application/json","Authorization":settings.createTourOutcomes.headers.Authorization,"CONTEXT_SALESFORCE_ID":component.get("v.LoggedInUser")};
        component.get("v.utils").execute("c.executeRest", {"method": "POST","endPointUrl": url,"headers": headers,"body": JSON.stringify(outcome)}, function(response){
            response = JSON.parse(response);
            if(response.hasOwnProperty("error")){                        
                component.get("v.utils").hideProcessing(); 
                if((response.hasOwnProperty("error")) && (response.hasOwnProperty("message")))
                    component.get("v.utils").showError(response.message);
                else
                    component.get("v.utils").showError(response.error);
            }else{
                helper.updateTour(component, event, helper, response.tour_outcome);
            }
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        });
    },
    updateTour : function(component, event, helper, tourOutcome) {
        component.get("v.utils").showProcessing();
        var objectsToUpdate = [];
        var AccountToUpdate = [];
        var tour = JSON.parse(JSON.stringify(component.get("v.tour")));
        var tourCompletedBy = JSON.parse(JSON.stringify(component.get("v.tourCompletedBy")));
        var tourToUpdate = {
            Id: tour.Id,
            Tour_Completed_By_Contact_UUID__c: tourCompletedBy.UUID__c
        };
        objectsToUpdate.push(tourToUpdate);
        
        let updatedAccount = tour.Primary_Member__r.Account;
        let oldAccount = component.get("v.tourAccount");
        let isAccountUpdated = false;
        
        for (var key in updatedAccount) {
            if(updatedAccount[key] != oldAccount[key]){
                isAccountUpdated = true;
                break;
            }
        }
        component.get("v.utils").execute("c.saveRecords",{"records": objectsToUpdate},function(response){
            if(response){
                if(isAccountUpdated){
                    let objAccUpdate = { 
                        Id: updatedAccount.Id,
                        Name: updatedAccount.Name, 
                        Number_of_Full_Time_Employees__c: updatedAccount.Number_of_Full_Time_Employees__c,
                    };
                    let isUnomyData = false;
                    if(updatedAccount.hasOwnProperty('Unomy_Location_Country__c') || updatedAccount.hasOwnProperty('Unomy_Location_City__c') || updatedAccount.hasOwnProperty('Unomy_Location_State__c') || updatedAccount.hasOwnProperty('Unomy_Location_Address__c')){
                        isUnomyData = true;
                    }
                    objAccUpdate["BillingCountry"] = isUnomyData ? updatedAccount.Unomy_Location_Country__c : updatedAccount.BillingCountry;
                    objAccUpdate["BillingState"] = isUnomyData ? updatedAccount.Unomy_Location_State__c : updatedAccount.BillingState;
                    objAccUpdate["BillingCity"] = isUnomyData ? updatedAccount.Unomy_Location_City__c : updatedAccount.BillingCity;
                    objAccUpdate["BillingStreet"] = isUnomyData ? updatedAccount.Unomy_Location_Address__c : updatedAccount.BillingStreet;
                    AccountToUpdate.push(objAccUpdate);
                }
                component.get("v.utils").execute("c.saveRecords",{"records": AccountToUpdate},function(response){
                    console.log('Saved in SF==>'+JSON.stringify(response));
                    if (component.isValid()) {
                        window.setTimeout(
                            $A.getCallback(function() {
                                if (component.isValid()) {                            
                                    helper.close(component, event, helper);
                                }
                            }), 4000
                        );
                        if(component.get("v.opportunityId"))
                            helper.updateOpportunityReferral(component);
                        component.get("v.utils").showSuccess("Tour outcome successfully saved."); 
                    }else if(response.getState()=="ERROR"){
                        var errors = response.getError();
                        component.get("v.utils").hideProcessing();
                        component.get("v.utils").showError("Not able to save the record successfully, Please try again or contact your administrator.");
                    }
                },function(error){
                    component.get("v.utils").hideProcessing();
                    component.get("v.utils").showError(error);
                });
            }
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        }); 
    },
    updateOpportunityReferral : function(component){
        var referrerName = component.get("v.referrer_Name");
        var referrerEmail = component.get("v.referrer_Email");
        console.log('Oppo id::'+component.get("v.opportunityId"));
        component.get("v.utils").execute("c.saveRecords",{"records":[{"Id":component.get("v.opportunityId"),"Referrer_Email__c": referrerEmail, "Referrer_Name__c":referrerName}]},function(response){
            console.log('response of saveRecords:'+response);
        },function(error){
            console.log('Error in saving referral information');
            onsuccess(error);
        });   
    },
    saveNoShow : function(component, event, helper, bookTours) {
        component.get("v.utils").showProcessing();
        
        var tour = JSON.parse(JSON.stringify(component.get("v.tour")));
        //Modified By : Krishana Tupe When UUID__c ==NULL then we cannot hit the No_show Api.
        if( tour.uuid__c !=undefined && tour.uuid__c !='' )
        {
            var tourOutcome = JSON.parse(JSON.stringify(component.get("v.tourOutcome")));
            var settings = JSON.parse(JSON.stringify(component.get("v.settings")));
            var tourToNoShow = {
                "id": tour.uuid__c,
                "no_follow_up": (tourOutcome.No_Follow_Up__c!=undefined)?tourOutcome.No_Follow_Up__c:false
                //,"reason_ids": [tourOutcome.Objections__c]
                
            };
            var url = settings.noShow.url;
            url = url.replace("tour_uuid", tour.uuid__c);
            var headers = {"Content-Type":"application/json","Authorization":settings.noShow.headers.Authorization,"CONTEXT_SALESFORCE_ID":component.get("v.LoggedInUser")};
            component.get("v.utils").execute("c.executeRest", {"method": "POST","endPointUrl": url,"headers": headers,"body": JSON.stringify(tourToNoShow)}, function(response){
                var response = JSON.parse(response);
                console.log(response);
                if(response.hasOwnProperty("tour")){
                    if(bookTours){
                        component.get("v.utils").showSuccess("Tour no show successfully saved.");
                        window.setTimeout(
                            $A.getCallback(function() { 
                                component.get("v.utils").redirectToUrl("/apex/BookTours?contactId="+tour.Primary_Member__c+'&buildingId='+tour.Location__c);
                            }), 1000
                        );                    
                    } else if (component.isValid()) {
                        window.setTimeout(
                            $A.getCallback(function() {
                                if (component.isValid()) {                                
                                    helper.close(component, event, helper);
                                }
                            }), 8000
                        );
                        component.get("v.utils").showSuccess("Tour no show successfully saved.");                    
                    }
                } else {
                    var errors = response.error;
                    component.get("v.utils").hideProcessing();
                    component.get("v.utils").showError("Not able to save the record successfully, Please try again or contact your administrator.");
                }            
            },function(error){
                console.log(error);
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError("Not able to save the record successfully, Please try again or contact your administrator.");
            });  
        }else{            
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError("Not able to save the record successfully because Tour UUID should Not be blank, Please try again or contact your administrator.");
        }
        
    },    
    firstOfNextMonth : function(){        
        var d = new Date();
        d.setMonth(d.getMonth() + 1, 1);
        return [d.getFullYear(), this.pad(d.getMonth() + 1), this.pad(d.getDate())].join('-');
    },
    pad : function(param){ 
        return (param < 10) ? '0' + param : param; 
    }, 
    cancel : function(component, event, helper){ 
        helper.close(component, helper);
    },
    close : function(component, event, helper){ 
        var tour = JSON.parse(JSON.stringify(component.get("v.tour")));
        if (sforce.console.isInConsole()) {
            //Open a new primary tab with the URL page in it
            component.get("v.utils").hideProcessing();
            component.get("v.utils").redirectToUrl('/' + tour.Id, 'Tour Outcome Form', false);
        }
        else if (sforce.one) {
            try {
                if(component.get("v.buildingId")){
                    setTimeout(function(){
                        component.get("v.utils").hideProcessing();
                        sforce.one.navigateToURL("/apex/communityview?building_id="+component.get("v.buildingId")+"&url_Data="+component.get("v.urlData"));
                    }, 3000);
                }else{
                    setTimeout(function(){
                        component.get("v.utils").hideProcessing();
                        sforce.one.navigateToURL('/' + tour.Id);
                    }, 50); 
                }
            }
            catch (e) {
                setTimeout(function(){
                    component.get("v.utils").hideProcessing();
                    window.location.href = '/' + tour.Id;
                }, 5000);
                
            }
        } else {
            if(component.get("v.communityView")){
                component.get("v.utils").redirectToUrl("CommunityView?building_id="+component.get("v.buildingId")+"&url_Data="+component.get("v.urlData"),"",false,false,false);
            }
            else{
                setTimeout(function(){
                    component.get("v.utils").hideProcessing();
                    window.location.href = '/' + tour.Id;
                }, 50);
            }
        }
    },
    increamentTicks:function(component, helper, ticks){
        component.set("v.counter",component.get("v.counter")-1);
        if(component.get("v.counter")==0){
            clearInterval(ticks);
            helper.close(component, helper);
        }
    },
    refreshView : function(component, event, helper){
        if($A.get("e.force:refreshView").getSource().isValid()) {
            $A.get('e.force:refreshView').fire();
        } 
    },
    showNewContactModal: function (component, event, helper){
        var tour = JSON.parse(JSON.stringify(component.get("v.tour")));
        component.set("v.contact", {
            "sobjectType": "Contact",
            "Company__c": (tour.Primary_Member__r.Account!=undefined && tour.Primary_Member__r.Account.Name!=undefined && tour.Primary_Member__r.Account.Name!="")?tour.Primary_Member__r.Account.Name:"",
            "AccountId": JSON.parse(JSON.stringify(component.get("v.tour"))).Primary_Member__r.AccountId
        });
        component.find("NewContactModal").showModal();
    },
    closeNewContactModal: function (component, event, helper){
        component.find("NewContactModal").close();
    },
    saveContact : function(component, event, helper) {
        component.get("v.utils").showProcessing();
        var tour = JSON.parse(JSON.stringify(component.get("v.tour")));
        var contact = JSON.parse(JSON.stringify(component.get("v.contact")));
        var tourOutcome = JSON.parse(JSON.stringify(component.get("v.tourOutcome")));
        contact["Name"] = ((contact["FirstName"]!=undefined && contact["FirstName"]!="")? contact["FirstName"]+" " : "")+contact["LastName"];
        console.log(contact);
        var records = [];
        records.push(contact);
        component.get("v.utils").execute("c.saveRecords",{"records": records},function(response){
            let result = JSON.parse(response);
            if(result && result["insertedRecords"] && result["insertedRecords"].length && result["insertedRecords"][0]["success"]){
                helper.getDecisionMakers(component, event, helper, function(){
                    tourOutcome["Decision_Maker__c"] = contact["Email"];
                    component.set("v.tourOutcome", tourOutcome);
                    component.set("v.contact", {});
                    helper.closeNewContactModal(component, event, helper);
                    component.get("v.utils").hideProcessing();
                });					
            }else{
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError(result["insertedRecords"][0]["errors"]);
            }
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        });        
    },
    getAPICallout : function (component, event, helper) {
        
        var sessionId = component.get("v.sessionId");
        var oldTourOutcomeUUID = component.get("v.oldTourOutcomeUUID");
        $.cometd.init({
            url: '/cometd/38.0',
            requestHeaders: {"Authorization": "OAuth "+sessionId}
        });
        $.cometd.subscribe('/topic/TourOutcomeForm', function(message) {
            
            var sobject = message.data.sobject;            
            var tour = JSON.parse(JSON.stringify(component.get("v.tour")));
            var rescheduledTour = component.get("v.rescheduledTour");
            if(rescheduledTour.tour.id == sobject.uuid__c)
                helper.getSyncedTours(component, event, helper);
        });
    },
    rescheduleTour : function(component, event, helper){
        component.get("v.utils").showProcessing();
        var statusOfTour = component.get("v.tourStatus");
        console.log("statusOfTour:"+statusOfTour);
        if(statusOfTour !== 'Rescheduled')
        {
            helper.execute(component,"c.getUserContactInfo",{},function(response){
                var callBackResponse = JSON.parse(response);
                if(callBackResponse && callBackResponse.length > 0){
                    var currentUserId = JSON.parse(response)[0].Id;
                    var rescheduleTour = JSON.parse(JSON.stringify(component.get("v.rescheduleTour")));
                    var tour = JSON.parse(JSON.stringify(component.get("v.tour")));
                    var settings = JSON.parse(JSON.stringify(component.get("v.settings")));
                    var url = settings.reservableRescheduleAPI.url;
                    url = url.split(":id").join(tour.uuid__c);
                    var headers = {"Content-Type":"application/json","Authorization":settings.reservableRescheduleAPI.headers.Authorization};
                    var newTour = {
                        date: component.get("v.rescheduleTour.tourDate"),
                        time: rescheduleTour.startTime,
                        notes: (rescheduleTour.notes != null && rescheduleTour.notes != "")?rescheduleTour.notes:"",
                        building_id: tour.Location__r.UUID__c,
                        booked_by_contact_id: tour.booked_by_contact_id__c
                    }
                    component.get("v.utils").execute("c.executeRest", {"method": "POST","endPointUrl": url,"headers": headers,"body": JSON.stringify(newTour)}, function(response){
                        
                        component.get("v.utils").hideProcessing();
                        var result = JSON.parse(response);
                        component.set("v.rescheduledTour",result);
                        console.log("result"+result.tourDate);
                        if(result.hasOwnProperty("error")){                        
                            component.get("v.utils").hideProcessing(); 
                            if((result.hasOwnProperty("error")) && (result.hasOwnProperty("message")))
                                component.get("v.utils").showError('Space Station Error : '+result.message);
                            else
                                component.get("v.utils").showError('Space Station Error : '+result.error);
                        }else if(result.hasOwnProperty('tour'))
                        {
                            component.get("v.utils").showSuccess('Tour Rescheduled Sucessfully and Will be Synced Shortly');
                            component.set("v.valid5",false);
                            $("#reschedule_Id").hide();
                            $("#closeButton").show();
                        }
                    },function(error){
                        component.get("v.utils").hideProcessing();
                        component.get("v.utils").showError(error);
                    }) 
                }else{
                    component.get("v.utils").hideProcessing();
                    component.get("v.utils").showError('Contact With Logged In User\'s Email Does not Exist.'); 
                }
                
            },function(error){
                component.get("v.utils").hideProcessing();
                component.get("v.utils").showError(error);
            }) 
        }
        else
        {
            component.get("v.utils").showError('Tour is already rescheduled');
            component.get("v.utils").hideProcessing();
            $("#reschedule_Id").hide();
            $("#closeButton").show();
        }
    },
    loadTimeSlots:function(component,tour,tourDate,onsuccess,onerror){ 
        
        if(tour && tour.Tour_Date__c){
            if(tour.Location__r.UUID__c){
                var settings = JSON.parse(JSON.stringify(component.get("v.settings")));
                var url = settings.reservableTourBuildingAvailabilitiesAPI.url;
                url += '?date=' + tourDate + '&building_id=' + tour.Location__r.UUID__c + '&product_line=' + tour.Product_Line__c
                var headers = {"Content-Type":"application/json","Authorization":settings.reservableTourBuildingAvailabilitiesAPI.headers.Authorization};
                component.get("v.utils").execute("c.executeRest", {"method": "GET","endPointUrl": url,"headers": headers,"body": ""}, function(response){ 
                    if(response){
                        var times = JSON.parse(response).available_tour_times;
                        for(var t in times){
                            times[t].time = times[t].time.split(" ").join("");
                        }
                        if(times && times.length > 0){
                            component.set("v.available_tour_times",times);
                        }else{        
                            component.set("v.rescheduleTour.startTime",null);
                            component.set("v.rescheduleTour.endTime",null);
                            component.set("v.available_tour_times",[]);                            
                            onerror('No times slots available for the selected date');
                        } 
                        onsuccess();
                    }else{ 
                        onerror(JSON.parse(response).message); 
                    } 
                    
                },function(error){
                    onerror(error);
                });
            }
        }else{
            onerror('No UUID available for this building.');
        }
    },
    getEndTime : function(component,startTime){
        var hr = startTime.split(":")[0];
        var min = startTime.split(":")[1].substr(0,2);
        var am = startTime.split(":")[1].substr(2,3);
        var tour = JSON.parse(JSON.stringify(component.get("v.tour")));
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
    formatDate: function (dt) {
        return dt.getFullYear()+"-"+((dt.getMonth()+1)<10?("0"+(dt.getMonth()+1)):dt.getMonth()+1)+"-"+(dt.getDate()<10?("0"+dt.getDate()):dt.getDate());
    },
    getSyncedTours : function(component, event, helper){
        setTimeout(function(){
            component.get("v.utils").showSuccess('Tour Synced Successfully.');
            var rescheduledTour = component.get("v.rescheduledTour");
            var tour = JSON.parse(JSON.stringify(component.get("v.tour"))); 
            if(rescheduledTour && tour){
                var query = 'SELECT Id, Name, Status__c, Start_Time__c, End_Time__c, Tour_Date__c, Location__r.Name,Product_Line__c,New_Tour_Notes__c FROM Tour_Outcome__c WHERE uuid__c IN  (\''+rescheduledTour.tour.id+'\',\''+tour.uuid__c+'\')';
                component.get("v.utils").showProcessing();
                component.get("v.utils").execute("c.getQueryData",{"query":query},function(response){
                    component.get("v.utils").hideProcessing();
                    if(response && response.length > 0)
                    {
                        component.set("v.tourTable",response);
                    }
                },function(error){
                    component.get("v.utils").hideProcessing();
                    component.get("v.utils").showError(error);
                })
            }
        }, 2000);
    }    
})