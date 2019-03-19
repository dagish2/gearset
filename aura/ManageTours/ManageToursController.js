({
    doInit: function (component, event, helper){
        component.find("utils").setTitle("Manage Tours");
        helper.subscribeToPushTopics(component);
        helper.setFilters(component, event, helper);
        component.find("utils").showProcessing();        
        component.find("utils").execute("c.getUserAndBuildingForManageTours",{"buildingId":component.get("v.buildingId") ? component.get("v.buildingId") :''},function(response){
            var info = JSON.parse(response);
            var currentUserDetail;
            var buildingID;
            if(info.userInfo){
                currentUserDetail = JSON.parse(info.userInfo.data)[0];
                component.set("v.currentUserDetail",currentUserDetail);
            }
            if(component.get("v.buildingId")){
                if(info.building != null || info.building != undefined){
                    buildingID = info.building.Id;
                    component.set("v.buildingId", buildingID);
                }else{
                    component.find("utils").showError("Building not available");
                }
            }
            var bookedTourFields=[{'name':'','label':'Action','sort':'false','type':'component','component':[{'name':'c:EnziButton','attributes':{'label':'Reschedule','type':'brand','id':'{{Id}}','click':component.getReference("c.rescheduleTour"),"disabled":"'{{Status__c}}'!='Scheduled'"}},{'name':'c:EnziButton','attributes':{'label':'Cancel','type':'neutral','id':'{{Id}}','click':component.getReference("c.cancelTour"),"disabled":"'{{Status__c}}'!='Scheduled'"}}]}];
            bookedTourFields.push({"name":"Name","label":"Name","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Name}}","value":"/{{Id}}","target":"_blank"}}},{"name":"Location__r.Name","label":"Building Name","type":"component","component":{"name":"ui:outputURL","attributes":{"label":"{{Location__r.Name}}","value":"/{{Location__c}}","target":"_blank"}}},{'name':'Tour_Date__c','label':'Tour Date','type':'date'},{'name':'Start_Time__c','label':'Tour Time'},{'name':'Status__c','label':'Status'},{'name':'Product_Line__c','label':'Product Line'},{'name':'New_Tour_Notes__c','label':'Notes'});
            component.set("v.bookedTourFields", bookedTourFields);
            component.find("utils").execute("c.getDataForManageTours",{"entityType":component.get("v.entity.entityType"),"accountId":(component.get("v.entity.accountId")?component.get("v.entity.accountId"):'')},function(response){
                var data = JSON.parse(response);
                component.set("v.currentUserContact", data.currentUser);
                var mapBuildings = {"WeWork":{},"WeLive":{}};
                var lstWeWorkBuildings = [];
                for(var b in data.mapBuildings.WeWork){
                    lstWeWorkBuildings.push({"label":data.mapBuildings.WeWork[b].Building__r.Name,"value":data.mapBuildings.WeWork[b].Building__c});
                    mapBuildings.WeWork[data.mapBuildings.WeWork[b].Building__c] = {"Id":data.mapBuildings.WeWork[b].Building__c,"Name":data.mapBuildings.WeWork[b].Building__r.Name,"UUID__c":data.mapBuildings.WeWork[b].Building__r.UUID__c,"Tour_Spacing__c":data.mapBuildings.WeWork[b].Tour_Spacing__c};
                }
                var lstWeLiveBuildings = [];
                for(var b in data.mapBuildings.WeLive){
                    lstWeLiveBuildings.push({"label":data.mapBuildings.WeLive[b].Building__r.Name,"value":data.mapBuildings.WeLive[b].Building__c});
                    mapBuildings.WeLive[data.mapBuildings.WeLive[b].Building__c] = {"Id":data.mapBuildings.WeLive[b].Building__c,"Name":data.mapBuildings.WeLive[b].Building__r.Name,"UUID__c":data.mapBuildings.WeLive[b].Building__r.UUID__c,"Tour_Spacing__c":data.mapBuildings.WeLive[b].Tour_Spacing__c};
                }
                component.set("v.weworkBuildings", lstWeWorkBuildings);
                component.set("v.weliveBuildings", lstWeLiveBuildings);
                component.set("v.mapBuildings", mapBuildings);
                component.set("v.api", JSON.parse(data.tourSetting.Data__c));
                var settingQuery='SELECT Id, Name, Data__c FROM Setting__c WHERE Name=\'TourRservableSettings\'';
                component.find("utils").execute("c.getQueryData",{"query":settingQuery},function(response){            
                    var TourRservableSettings=JSON.parse(response[0].Data__c);
                    var bookedbySalesLeadLabel=TourRservableSettings.bookedbysalesleadlabel;
                    component.set("v.TourRservableSettings", TourRservableSettings);
                    component.set("v.bookedbySalesLeadLabel", bookedbySalesLeadLabel); 
                    
                    var settingProfiles = TourRservableSettings.salesleadprofiles;
                    component.set("v.isVisibleForProfile", false);
                    for(var index = 0; index < settingProfiles.length; index++){
                        if(settingProfiles[index].profilename == component.get("v.currentUserDetail").Profile.Name){                           
                            component.set("v.isVisibleForProfile", true);
                            break;
                        }
                    }
                    var entity = {};
                    if(component.get("v.leadId")){
                        entity.entityType = "lead";
                        entity.Id = component.get("v.leadId");
                    }else if(component.get("v.contactId")){
                        entity.entityType = "contact";
                        entity.Id = component.get("v.contactId");
                    }else if(component.get("v.journeyId")){
                        entity.entityType = "journey";
                        entity.Id = component.get("v.journeyId");
                    }else if(component.get("v.opportunityId")){
                        entity.entityType = "opportunity";
                        entity.Id = component.get("v.opportunityId");
                    }else if(component.get("v.opportunityRoleId")){
                        entity.entityType = "opportunityRole";
                        entity.Id = component.get("v.opportunityRoleId");
                    }else if(component.get("v.accountId")){
                        entity.entityType = "account";
                        entity.Id = component.get("v.accountId");  
                        entity.accountId = component.get("v.accountId");
                    }else{
                        entity.entityType = "newlead";
                    }
                    component.set("v.entity", entity);
                    if(entity.entityType != "newlead"){
                        helper.initTourData(component,function(){
                            helper.getOnLoadTimeSlotForInstantTour(component,event,helper); 
                            component.find("utils").hideProcessing();
                        },function(error){
                            component.find("utils").hideProcessing();
                            component.find("utils").showError(error);
                        })
                    }else{
                     if(component.get("v.urlData")){  
                        let urldata=JSON.parse(component.get("v.urlData"));
                            entity.Name = urldata.leadName ?urldata.leadName  :null;
                            entity.Company = urldata.Company ?urldata.Company:null;
                            entity.Email = urldata.Email ?urldata.Email:null;
                            entity.Phone = urldata.Phone?urldata.Phone:null;
                            entity.Number_of_Full_Time_Employees__c = urldata.NumberOfFTE ?urldata.NumberOfFTE :"";
                            entity.Interested_in_Number_of_Desks__c =urldata.InterestedInNoOfDesks ?urldata.InterestedInNoOfDesks:"";
                            entity.entityType = "updatedlead";
                        }
                        component.set("v.entity", entity);
                        var tours = component.get("v.tours");
                        helper.clearTours(component);
                        var tour = {};
                        tours.push({"id":helper.generateTourId(),"productLine":"WeWork","bookedBySalesLead":(component.get("v.isVisibleForProfile")? true : false),"buildings":JSON.parse(JSON.stringify(component.get("v.weworkBuildings")))});
                        tour.id = helper.generateTourId();
                        if(component.get("v.productLine") || component.get("v.buildingId")){
                            if(component.get("v.buildingId")){
                                tour.building = buildingID;
                            }
                            if(component.get("v.productLine").toLowerCase() == 'welive'){
                                tour.productLine = "WeLive";
                            }
                            else if(component.get("v.productLine").toLowerCase() == 'wework'){
                                tour.productLine = "WeWork";
                            }
                                else{
                                    tour.productLine = (component.get("v.productLine") ? component.get("v.productLine") : "WeWork");
                                }
                        }
                        else{
                            tour.productLine = "WeWork";
                        }
                        var urlData ;
                        if(component.get("v.urlData")){
                            urlData = JSON.parse(component.get("v.urlData"));
                            tour = {"id":tour.id ? tour.id : helper.generateTourId(),"building":component.get("v.buildingId"), "tourDate": urlData.tourDate, "productLine" : 'WeWork',"startTime":urlData.startTime,"endTime":urlData.startTime ? helper.getEndTime(component,0,"",urlData.startTime) : null};
                            helper.loadTimeSlots(component,tour,0,true,function(){
                                component.set("v.entity", entity);
                                if(!index){     
                                    helper.validateTours(component,index);
                                    component.set("v.valid", false);
                                }else{
                                    component.set("v.tour.startTime", null);      
                                    component.set("v.tour.endTime", null);          
                                    component.set("v.tour.notes", null);          
                                }  
                                component.find("utils").hideProcessing();
                            },function(error){
                                helper.validateTours(component,0);
                                component.set("v.entity", entity);
                                component.find("utils").hideProcessing();  
                                component.find("utils").showError(error);
                                
                            })
                        }
                        tour.bookedBySalesLead = component.get("v.isVisibleForProfile")? true : false;
                        tours[0] = tour;
                        component.set("v.tours", tours);
                        component.find("utils").hideProcessing();
                        if(entity.entityType == 'newlead'){
                            component.find("utils").showWarning('Please select a Lead or Contact.');
                            document.getElementById("searchLeadorContact").focus();
                        }else{
                            document.getElementById("searchLeadorContact").value = "";
                            component.set("v.showProfileInfo", true); 
                            component.set("v.showSection", true);
                        }                    }
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                });
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            } , component);   
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        } , component);   
    },
    createNew:function(component, event, helper){
        document.getElementById("searchLeadorContact").value = "";
        component.set("v.entity", {"Name":null,"Company":null,"Email":null,"Phone":null,"Number_of_Full_Time_Employees__c":null,"Interested_in_Number_of_Desks__c":null,"contactId":null,"opportunityId":null});
        component.set("v.entity", {"entityType":"newlead"});
        component.set("v.showFTE", true);
        component.set("v.bookedTours", []);
        component.set("v.keyword", "");
        component.set("v.hideMsg", false);
        component.set("v.showProfileInfo", true); 
        component.set("v.showSection", true); 
        setTimeout(function(){ 
            var element = document.getElementsByClassName("slds-section");
            element[0].classList.add("shake-div");
        }, 500);    
    },
    addNewTour:function(component, event, helper){
        var tours = component.get("v.tours");
        tours.push({"id":helper.generateTourId(),"productLine":"WeWork","bookedBySalesLead":(component.get("v.isVisibleForProfile")? true : false),"buildings":JSON.parse(JSON.stringify(component.get("v.weworkBuildings")))});
        helper.getToursCount(component,tours);
    },
    removeTour:function(component,event,helper){       
        var tours = component.get("v.tours");
        var index = helper.getTourIndex(component,event.currentTarget.id);
        if(index >= 0){
            tours[index].removed = true;
        }
        helper.getToursCount(component,tours);
    },
    loadTimeSlots:function(component, event, helper){
        var index = helper.getTourIndex(component,event.target.id);
        component.set("v.tours["+index+"].startTime", null);         
        component.set("v.tours["+index+"].endTime", null);  
        component.set("v.tours["+index+"].notes", null);
        var tour;
        if(index != -1 && index<component.get("v.tours").length){
            tour = component.get("v.tours["+index+"]");
        }else{
            tour = component.get("v.tour");
        }
        if(tour){
            component.find("utils").showProcessing();
            helper.loadTimeSlots(component,tour,index,true,function(){
                if(index){                   
                    component.set("v.tours["+index+"].startTime", null);         
                    component.set("v.tours["+index+"].endTime", null);  
                    component.set("v.tours["+index+"].notes", null);
                    helper.validateTours(component,index);
                }else{
                    component.set("v.tour.startTime", null);      
                    component.set("v.tour.endTime", null);          
                    component.set("v.tour.notes", null);          
                }  
                component.find("utils").hideProcessing();
            },function(error){
                if(index != -1){                    
                    component.set("v.tours["+index+"].startTime", null);         
                    component.set("v.tours["+index+"].endTime", null);  
                    component.set("v.tours["+index+"].notes", null);
                    component.set("v.tours["+index+"].available_tour_times", []);
                    helper.validateTours(component,index);
                }else{
                    if(index == -1){
                        component.set("v.tour.startTime", null);      
                        component.set("v.tour.endTime", null);          
                        component.set("v.tour.notes", null); 
                        component.set("v.tour.available_tour_times", []);
                    }else{
                        component.set("v.tours["+index+"].startTime", null);         
                        component.set("v.tours["+index+"].endTime", null);  
                        component.set("v.tours["+index+"].notes", null);
                        component.set("v.tours["+index+"].available_tour_times", []);
                        helper.validateTours(component,index);
                    }        
                } 
                component.find("utils").hideProcessing();  
                component.find("utils").showError(error);
                
            })
        }
    },
    setEndTime:function(component, event, helper){
        var index = helper.getTourIndex(component,event.currentTarget.id);
        if(event.currentTarget.value){
            var endTime;
            if(index >= 0){
                endTime = helper.getEndTime(component,index,"",event.currentTarget.value);
            }else{
                endTime = helper.getEndTime(component,"",component.get("v.tour.id"),event.currentTarget.value);
            }
            if(index >= 0 && index < component.get("v.tours").length){
                component.set("v.tours["+index+"].startTime", event.currentTarget.value);
                component.set("v.tours["+index+"].endTime", endTime);
                helper.validateTours(component,index);
            }else{
                component.set("v.tour.startTime", event.currentTarget.value);
                component.set("v.tour.endTime", endTime);
            }
        }else{
            if(index && index<component.get("v.tours").length){
                component.set("v.tours["+index+"].startTime", event.currentTarget.value);
                component.set("v.tours["+index+"].endTime", event.currentTarget.value);
                helper.validateTours(component,index);
            }else{
                component.set("v.tour.startTime", event.currentTarget.value);
                component.set("v.tour.endTime", event.currentTarget.value);
            }
        }
    },
    bookTours : function(component, event, helper){
        component.find("utils").showProcessing();        
        var entity = component.get("v.entity");       
        if(entity.entityType == "newlead"  || entity.entityType == "updatedlead"){
            var lead = JSON.parse(JSON.stringify(component.get("v.entity")));            
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
            var locationsInterested = '';	
            var bookTourData = component.get("v.tours"); 	
            var buildingData = component.get("v.mapBuildings").WeWork;	
            var buildingDataWeLive = component.get("v.mapBuildings").WeLive;	
            buildingData = Object.assign(buildingData , buildingDataWeLive);	
            for(var buiildingIndex in buildingData){	
                for(var tourData in bookTourData){	
                    if(buiildingIndex == bookTourData[tourData].building){	
                        locationsInterested = locationsInterested + buildingData[buiildingIndex].Name + ';';	
                    }	
                }	
            }	
            lead['Lead_Assignment_Stage__c'] = "1000";	             
            lead['Lead_Source_Detail__c'] = "Book Tour Page";	
            lead['Locations_Interested__c'] = locationsInterested ? locationsInterested : null;
            delete lead['Name'];
            delete lead['entityType'];
            component.find("utils").execute("c.saveRecord", {"record": lead},function(response){
                var leadId = JSON.parse(response).id;
                component.set("v.entity.Id", leadId);
                component.set("v.entity.entityType", "lead");
                component.set("v.salesEntity.leadId", leadId);
                component.set("v.accountRec", {"sobjectType": "Account", "Name": null, "Website": "", "Number_of_Full_Time_Employees__c": entity.Number_of_Full_Time_Employees__c, "Interested_in_Number_of_Desks__c": entity.Interested_in_Number_of_Desks__c});
                component.find("utils").hideProcessing();
                component.set("v.showAccountSelector", true);
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            });
        }else if(entity.entityType == "lead" || (entity.entityType == "journey" && entity.hasOwnProperty('primaryLead'))){
            component.set("v.salesEntity.leadId", entity.entityType == "lead" ? component.get("v.entity.Id") : component.get("v.entity.primaryLead"));
            component.set("v.accountRec", {"sobjectType": "Account", "Name": null, "Website": "", "Number_of_Full_Time_Employees__c": entity.Number_of_Full_Time_Employees__c, "Interested_in_Number_of_Desks__c": entity.Interested_in_Number_of_Desks__c});
            component.find("utils").hideProcessing();
            component.set("v.showAccountSelector", true);
        } else if(component.get("v.entity") && component.get("v.entity.contactId")){  
            var conRecord = {"Id":component.get("v.entity.contactId"), "Interested_in_Number_of_Desks__c":component.get("v.entity.Interested_in_Number_of_Desks__c"), "Number_of_Full_Time_Employees__c":component.get("v.entity.Number_of_Full_Time_Employees__c")};
            var accRecord;
            var listRecords = [conRecord];
            if(component.get("v.AccountNOD") == false && component.get("v.AccountFTE") == false ){
                accRecord = {"Id":component.get("v.entity.accountId"), "Interested_in_Number_of_Desks__c":component.get("v.entity.Interested_in_Number_of_Desks__c"), "Number_of_Full_Time_Employees__c":component.get("v.entity.Number_of_Full_Time_Employees__c")};
            }else if(component.get("v.AccountFTE") == false ){
                accRecord = {"Id":component.get("v.entity.accountId"), "Number_of_Full_Time_Employees__c":component.get("v.entity.Number_of_Full_Time_Employees__c")}
            }else if(component.get("v.AccountNOD") == false){
                accRecord = {"Id":component.get("v.entity.accountId"), "Interested_in_Number_of_Desks__c":component.get("v.entity.Interested_in_Number_of_Desks__c")}
            }
            if(accRecord != null){
                listRecords = [conRecord, accRecord];
            }
            component.find("utils").execute("c.saveRecords",{"records":listRecords}, function(response){
                helper.manageTour(component, helper);
                component.find("utils").hideProcessing();
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            });
        }else{
            helper.manageTour(component, helper);
        }
    },
    manageTour : function(component, event, helper){ 
        var orgRecord = component.get("v.OrgRecord");
        if(orgRecord && orgRecord.Id != undefined){
            component.find("utils").execute("c.saveRecord", {"record": {"Id": component.get("v.entity.Id"), "Account__c": orgRecord.Id, "Interested_in_Number_of_Desks__c":component.get("v.entity.Interested_in_Number_of_Desks__c"), "Number_of_Full_Time_Employees__c":component.get("v.entity.Number_of_Full_Time_Employees__c"), "Phone":component.get("v.entity.Phone")}}, function(response){
            helper.manageTour(component, helper);
            }, function(error){
                component.find("utils").showError(error);
                component.find("utils").hideProcessing();
            });
        } else {
            helper.manageTour(component, helper);
        }                                        
    },
    search:function(component, event, helper){ 
        var targetValue = event.currentTarget.value;
        component.set("v.keyword", targetValue);
        if(component.get("v.keyword") && component.get("v.keyword") == "" ){
            component.set("v.entity.Referrer_Name__c", null);
            component.set("v.entity.Referrer_Email__c", null);
        }      
        if(targetValue && targetValue.length > 2){                  
            component.find("utils").execute("c.getListQueryDataBySOSL",{"arrQuery":["FIND '"+ component.find("utils").addSlashes(targetValue) +"*' IN ALL FIELDS RETURNING Contact( Id,Name,Email,Phone,Account.Number_of_Full_Time_Employees__c,Account.Interested_in_Number_of_Desks__c ORDER BY CreatedDate) LIMIT 5","FIND '"+ component.find("utils").addSlashes(targetValue) +"*' IN ALL FIELDS RETURNING Lead(Id,Name,Company,Email,Phone,Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c WHERE IsConverted=false ORDER BY CreatedDate) LIMIT 5"]},function(response){     
                var data = [];
                var setContactEmail = new Set();
                var setLeadEmail = new Set();
                for(var row in response){
                    for(var column in response[row]){				
                        if(row == "0"){
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
                var classId = document.getElementById("listbox-unique-id");        
                $A.util.removeClass(classId, "slds-hide");
            },function(error){
                component.find("utils").showError(error);
            })
        }else if(targetValue == ""){           
            component.set("v.entity", {"Name":null,"Company":null,"Email":null,"Phone":null,"Number_of_Full_Time_Employees__c":null,"Interested_in_Number_of_Desks__c":null,"contactId":null,"opportunityId":null,"Referrer_Name__c":"","Referrer_Email__c":""});
            component.set("v.entity", {"entityType":"newlead"});
            component.set("v.showFTE", true);
            component.set("v.bookedTours", []);
            component.set("v.valid", false);
            component.set("v.validTours", false);
        }
    },
    selectEntity:function(component, event, helper){
        var id = event.currentTarget.id;
        var searchData = component.get("v.searchData"); 
        if(searchData != null){
            component.set('v.showProfileInfo', true);
            component.set('v.showSection', false);
        }
        for(var row in searchData){
            if(searchData[row].Id == id){
                component.find("utils").showProcessing();
                document.getElementById("searchLeadorContact").value = searchData[row].Name;
                var entity = {"entityType":searchData[row].type,"Id":event.currentTarget.id};
                component.set("v.entity", entity);
                if(searchData[row].Id.indexOf("3") == 2 && searchData[row].AccountId == null){
                    component.find("utils").showError('Related account for this contact does not exists');
                    component.set("v.disableOpportunity", true);
                    component.find("utils").hideProcessing();
                }else{
                    helper.initTourData(component,function(){
                        component.find("utils").hideProcessing();
                    },function(error){
                        component.find("utils").showError(error);
                        component.find("utils").hideProcessing();
                    })
                }
            }
        }
        if(!component.get("v.hideMsg")){
            component.set("v.hideMsg", true);
            var element = document.getElementsByClassName("slds-section");
            element[0].classList.remove("shake-div")
        }
        var classId = document.getElementById("listbox-unique-id");        
        $A.util.addClass(classId, "slds-hide");
    },
    processingCompleted:function(component,event,helper){
        if(component.get("v.salesEntity.processingCompleted")){
            if(component.get("v.salesRecords").length > 0){
                component.find("utils").hideProcessing();
                component.set("v.salesEntity.showAccountSelector", true);
            }else{
                helper.continueAfterAccountSelector(component,helper,function(message){
                    component.find("utils").hideProcessing();
                    component.find("utils").showSuccess(message);
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                });
            }
        }
    },
    actionSelected:function(component,event,helper){
        component.set("v.salesEntity.showAccountSelector", false);
        if(component.get("v.salesEntity.selectedAction") && (component.get("v.salesEntity.selectedAction") != null)){
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
    close:function(component,event,helper){
        if(component.get("v.buildingId") && component.get("v.buildingId") != ""){
            component.find("utils").redirectToUrl("/apex/communityView?building_id="+component.get("v.buildingId")+((component.get("v.productLine") != null && component.get("v.productLine") != "")?"&product_line="+component.get("v.productLine"):"")+'&url_Data='+component.get("v.urlData"),'',false); 
        }else if(component.get("v.leadId")){
            component.find("utils").redirectToUrl("/"+component.get("v.leadId"),'',false);
        }else if(component.get("v.contactId")){
            component.find("utils").redirectToUrl("/"+component.get("v.contactId"),'',false);
        }else if(component.get("v.journeyId")){
            if(component.get("v.isFromInboundCallPage")){
                if(sforce.one){
                    component.find("utils").redirectToUrl('back');
                }else{
                    component.find("utils").closeTab();
                }
            }else{
                component.find("utils").redirectToUrl( "/"+component.get("v.journeyId"),'',false);    
            }
        }else if(component.get("v.opportunityId")){
            component.find("utils").redirectToUrl("/"+component.get("v.opportunityId"),'',false);
        }else if(component.get("v.opportunityRoleId")){
            component.find("utils").redirectToUrl("/"+component.get("v.opportunityRoleId"),'',false);
        }else if(component.get("v.buildingId") && !component.get("v.contactId")){
            component.find("utils").redirectToUrl('/apex/communityview?building_id='+component.get("v.buildingId"),'',false);
        }else if(component.get("v.accountId")){
            component.find("utils").redirectToUrl("/"+component.get("v.accountId"),'',false);
        }else{
            component.find("utils").redirectToUrl('back');
        }
    },
    rescheduleTour:function(component,event,helper){      
        component.find("utils").showProcessing();
        var tour = component.get("v.mapBookedTours."+event.currentTarget.id);
        component.set("v.tour", {"bookedByContactId":tour.booked_by_contact_id__c, "id":event.currentTarget.id,"productLine":tour.Product_Line__c,"building":tour.Location__c,"tourDate":tour.Tour_Date__c,"startTime":tour.Start_Time__c,"endTime":helper.getEndTime(component,"",event.currentTarget.id,tour.Start_Time__c),"notes":tour.New_Tour_Notes__c,"uuid":tour.uuid__c});
        var t = component.get("v.tour");
        if(t.productLine == 'WeLive'){
            component.set("v.buildings", JSON.parse(JSON.stringify(component.get("v.weliveBuildings"))));  
        }else if(t.productLine == 'WeWork'){
            component.set("v.buildings", JSON.parse(JSON.stringify(component.get("v.weworkBuildings"))));  
        }else{
            component.set("v.buildings", []);  
        }
        helper.loadTimeSlots(component,t,null,false,function(){
            component.find("utils").hideProcessing();
            component.set("v.originalTour", JSON.parse(JSON.stringify(t)));
            component.set("v.validReschedule", true);
            component.find("tourRescheduleModal").showModal();
        },function(error){
            component.find("utils").hideProcessing();
            component.set("v.originalTour", JSON.parse(JSON.stringify(t)));
            component.set("v.validReschedule", true);
            component.find("tourRescheduleModal").showModal();
        })
    },
    cancelTour:function(component,event,helper){
        var tour = component.get("v.mapBookedTours."+event.currentTarget.id);
        component.set("v.tour", {"id":tour.Id,"uuid":tour.uuid__c});
        component.find("tourCancelationModal").showModal();
    },
    closeModal:function(component,event,helper){
        component.find(event.currentTarget.id).close();
    },
    rescheduleTourSave:function(component,event,helper){
        helper.validateTours(component);
        if(component.get("v.validReschedule")){
            component.find('tourRescheduleModal').close();
            component.find("utils").showProcessing();
            var url = component.get("v.api.ReservableRescheduleAPI.url").split(":id").join(component.get("v.tour.uuid"));
            var tour = {
                date: component.get("v.tour.tourDate"),
                time: component.get("v.tour.startTime"),
                notes: component.get("v.tour.notes"),
                building_id: component.get("v.mapBuildings")[component.get("v.tour.productLine")][component.get("v.tour.building")].UUID__c,
                booked_by_contact_id: ((component.get("v.tour.bookedByContactId") != undefined && component.get("v.tour.bookedByContactId").substring(0,15) != component.get("v.TourRservableSettings").apiusercontactid.substring(0,15)) ? component.get("v.tour.bookedByContactId") : component.get("v.currentUserContact.Id"))
            }
            component.set("v.entity.managed", true);
            component.find("utils").execute("c.executeRestQuery",{"setUrl":!component.get("v.api.ReservableCreateAPI.url").includes("https:"),"method":"POST","endPointUrl":url,"headers":component.get("v.api.ReservableRescheduleAPI.headers"),"body":JSON.stringify(tour)},function(response){
                component.find("utils").hideProcessing();
                component.get("v.tour",{});
                component.find("utils").showSuccess('Tour rescheduled successfully and will be synced shortly.');                
                component.find("utils").hideProcessing();
            },function(error){
                component.find("utils").showProcessing();
                component.find("utils").showError(error);
            })
        }
    },
    canceTourSave:function(component,event,helper){
        component.find('tourCancelationModal').close();
        component.find("utils").showProcessing();
        var url = component.get("v.api.ReservableCancelAPI.url").split(":id").join(component.get("v.tour.uuid"));
        var tour = {
            Cancellation_Reason: component.get("v.tour.cancellationReason")
        }
        component.set("v.entity.managed",true);
        component.find("utils").execute("c.executeRestQuery",{"setUrl":!component.get("v.api.ReservableCreateAPI.url").includes("https:"),"method":"POST","endPointUrl":url,"headers":component.get("v.api.ReservableCancelAPI.headers"),"body":JSON.stringify(tour)},function(response){
            component.find("utils").hideProcessing();
            component.find("utils").showSuccess('Tour cancelled successfully and will be synced shortly.'); 
            component.find("utils").execute("c.saveRecord",{"record":{"Id":component.get("v.tour.id"),"Cancellation_Reason__c":component.get("v.tour.cancellationReason")}},function(response){ 
                component.set("v.tour", {});
            },function(error){
                component.find("utils").showProcessing();
                component.find("utils").showError(error);
            });
        },function(error){
            component.find("utils").showProcessing();
            component.find("utils").showError(error);
        })
    } ,   
    createNewOpportunity : function(component){
        if(component.get("v.entity.contactId") == null || component.get("v.entity.contactId") == undefined || component.get("v.entity.contactId") == ''){
            component.find("utils").showError('Please select contact to create new Opportunity');
        }else{
            component.find("utils").showProcessing();
            component.find("utils").execute("c.createOpportunityForManageTours",{"contactId":component.get("v.entity.contactId"),"noOfDesks":component.get("v.entity.Interested_in_Number_of_Desks__c")},function(response){
                var Opportunity = JSON.parse(response); 
                if( Opportunity != undefined || Opportunity[0] != undefined ){                                
                    var relatedOpportunities = component.get("v.relatedOpportunities");                
                    relatedOpportunities.push({"Id":Opportunity[0]["Id"] ,"Name":Opportunity[0]["Name"]});                
                    component.set("v.relatedOpportunities", relatedOpportunities);
                    component.set("v.entity.opportunityId", Opportunity[0]["Id"]);  
                    component.find("utils").hideProcessing();
                }            	
            },function(error){             
                component.find("utils").showProcessing();
                component.find("utils").showError(error);
            } , component);     
        }           
    },
    refreshDate : function(component,event,helper){
        var index = helper.getTourIndex(component,event.target.id);
        if(index>=0){
            if(index<component.get("v.tours").length){
                component.set("v.tours["+index+"].tourDate", null);
                component.set("v.tours["+index+"].startTime", null);
                component.set("v.tours["+index+"].endTime", null);
                component.set("v.tours["+index+"].notes", null);
                helper.validateTours(component,index);
            }
        }else{
            component.set("v.tour.tourDate", null);
            component.set("v.tour.startTime", null);
            component.set("v.tour.endTime", null);
            component.set("v.tour.notes", null);
        }
    },
    refreshRow:function(component,event,helper){
        setTimeout(function(){
            var index = helper.getTourIndex(component,event.target.id);
            if(index >= 0 && index < component.get("v.tours").length){
                var productLine= component.get("v.tours["+index+"].productLine");
                if(productLine == 'WeLive'){
                    component.set("v.tours["+index+"].buildings", JSON.parse(JSON.stringify(component.get("v.weliveBuildings"))));
                }else if(productLine == 'WeWork'){
                    component.set("v.tours["+index+"].buildings", JSON.parse(JSON.stringify(component.get("v.weworkBuildings"))));
                }else{
                    component.set("v.tours["+index+"].buildings", []);
                }
                component.set("v.tours["+index+"].building", null);
                component.set("v.tours["+index+"].tourDate", null);
                component.set("v.tours["+index+"].startTime", null);
                component.set("v.tours["+index+"].endTime", null);
                component.set("v.tours["+index+"].notes", null);
                helper.validateTours(component,index);
            }
        },500)
    },
    globalNotesChanged:function(component,event,helper){
        for(var tourIndex in component.get("v.tours")){
            if(!component.get("v.tours["+tourIndex+"].notes") || component.get("v.tours["+tourIndex+"].notes") == event.getParam('oldValue') ||component.get("v.tours["+tourIndex+"].notes") == undefined){
                component.set("v.tours["+tourIndex+"].notes", event.getParam("value"));
            }
        }
    },
    refreshTours:function(component,event,helper){
        helper.initTourData(component,function(){          
            component.find("utils").showSuccess("Tours synced successfully.");
        },function(error){
            component.find("utils").showError(error);
        });
    },
    showReferralSection:function(component,event,helper){
        component.set("v.hideReferralPane", !component.get("v.hideReferralPane"));
    },
    hideMessageIndicator:function(component,event,helper){
        if(!component.get("v.hideMsg")){
            component.set("v.hideMsg", true);
            var element = document.getElementsByClassName("slds-section");
            element[0].classList.remove("shake-div")
        }      
    },
    updateTourInfo : function(component,event,helper){
        helper.updateTourInfo(component,function(success){            
        },function(error){   
            component.find("utils").showError(error);
        });  
    }
})