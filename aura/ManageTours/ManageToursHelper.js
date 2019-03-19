({
    formatDate: function (dt) {
        return dt.getFullYear()+"-"+((dt.getMonth()+1)<10?("0"+(dt.getMonth()+1)):dt.getMonth()+1)+"-"+(dt.getDate()<10?("0"+dt.getDate()):dt.getDate());
    },
    initTourData:function(component,onsuccess,onerror){
        var helper = this;
        var query;
        if(component.get("v.entity.entityType") == "lead"){
            query = "Select Id,Name,Company,Email,Account__c, Unomy_Company_Size__c, Phone,Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,Referrer_Name__c,Referrer_Email__c From Lead Where Id='"+component.get("v.entity.Id")+"'";
        }else if(component.get("v.entity.entityType") == "contact"){
            query = "Select Id,Name,Email,Phone,Account.Number_of_Full_Time_Employees__c,Account.Interested_in_Number_of_Desks__c,Interested_in_Number_of_Desks__c,Referrer_Name__c,Referrer_Email__c From Contact Where Id='"+component.get("v.entity.Id")+"'";
        }else if(component.get("v.entity.entityType") == "journey"){
            query = "Select Id,Name,Email__c,  Unomy_Company_Size__c, Primary_Contact__r.Account.Number_of_Full_Time_Employees__c,Primary_Contact__r.Account.Interested_in_Number_of_Desks__c,Primary_Lead__r.Number_of_Full_Time_Employees__c,Primary_Lead__r.Interested_in_Number_of_Desks__c,Primary_Lead__r.Referrer_Name__c,Primary_Lead__r.Referrer_Email__c,Primary_Contact__r.Referrer_Name__c,Primary_Contact__r.Referrer_Email__c From Journey__c Where Id='"+component.get("v.entity.Id")+"'";
        }else if(component.get("v.entity.entityType") == "opportunity"){
            query = "Select Id,Name,Primary_Member__c,Account.Number_of_Full_Time_Employees__c,Account.Interested_in_Number_of_Desks__c,Referrer_Name__c,Referrer_Email__c From Opportunity Where Id='"+component.get("v.entity.Id")+"'";
        }else if(component.get("v.entity.entityType") == "opportunityRole"){
            query = "Select Id,Name,Contact__c,Opportunity__c,Opportunity__r.Account.Number_of_Full_Time_Employees__c,Opportunity__r.Account.Interested_in_Number_of_Desks__c From Opportunity_Role__c Where Id='"+component.get("v.entity.Id")+"'";
        }else if(component.get("v.entity.entityType") == "account"){
            query = "Select Id,Name,Primary_Member__c,Parent_Org_Id__c,Account_Type__c,Number_of_Full_Time_Employees__c,Interested_in_Number_of_Desks__c,(Select Id,Name from Contacts ORDER BY LastModifiedDate DESC) From Account Where Id='"+component.get("v.entity.Id")+"'";
        }
        if(query){
            component.find("utils").execute("c.getQueryData",{"query":query},function(response){
                var entity = {"entityType":component.get("v.entity").entityType};
                var urlData ;
                if(component.get("v.urlData")){
                    urlData = JSON.parse(component.get("v.urlData"));
                }
                switch(entity.entityType){                      
                    case "lead":                    
                        entity.Id = response[0].Id;
                        entity.Name = response[0].Name;
                        entity.Company = response[0].Company;
                        entity.Email = response[0].Email;
                        entity.Phone =(urlData && urlData.Phone) ? urlData.Phone : response[0].Phone ? response[0].Phone :null;
                        if(response[0].Phone){
                            component.set("v.showPhone", true);
                        }else{
                            component.set("v.showPhone", false);
                        }
                        if(component.get("v.buildingId") && urlData && urlData.NumberOfFTE){
                            entity.Number_of_Full_Time_Employees__c = urlData.NumberOfFTE;
                        }else if(response[0].Unomy_Company_Size__c){
                            entity.Number_of_Full_Time_Employees__c =  helper.getUnomyCompanySize(response[0].Unomy_Company_Size__c);
                        }else if(response[0].Number_of_Full_Time_Employees__c){
                            entity.Number_of_Full_Time_Employees__c = response[0].Number_of_Full_Time_Employees__c;
                        }else{
                            entity.Number_of_Full_Time_Employees__c = null;
                            component.set("v.showFTE", true);
                        }
                        entity.Interested_in_Number_of_Desks__c = (urlData && urlData.InterestedInNoOfDesks) ? urlData.InterestedInNoOfDesks : response[0].Interested_in_Number_of_Desks__c ? response[0].Interested_in_Number_of_Desks__c :null;
                        entity.Account__c = response[0].Account__c;
                        entity.Referrer_Name__c = response[0].Referrer_Name__c ? response[0].Referrer_Name__c : null;
                        entity.Referrer_Email__c = response[0].Referrer_Email__c ? response[0].Referrer_Email__c : null;
                        break;
                    case "account":                    
                        entity.Id = response[0].Id;
                        if(response[0].Number_of_Full_Time_Employees__c){
                            component.set("v.showFTE",false);
                        }
                        entity.accountId = response[0].Id;
                        entity.paretOrgId = response[0].Parent_Org_Id__c;
                        entity.Name = response[0].Name;
                        entity.Interested_in_Number_of_Desks__c = response[0].Interested_in_Number_of_Desks__c;
                        entity.Number_of_Full_Time_Employees__c = response[0].Number_of_Full_Time_Employees__c;
                        entity.Primary_Member__c =  response[0].Primary_Member__c;
                        if(response[0].Contacts && response[0].Contacts.length > 0)
                            entity.contactId = response[0].Contacts[0].Id;                                
                        break;
                    case "contact":
                        if(response[0].Account){
                            if(response[0].Account.Number_of_Full_Time_Employees__c){
                                component.set("v.showFTE", false);
                                component.set("v.AccountFTE", true);//AccountNOD AccountFTE
                            }else{
                                component.set("v.showFTE", true);
                                component.set("v.AccountFTE", false);
                            }
                            var AccountFTE = response[0].Account.Interested_in_Number_of_Desks__c ? true : false;
                            component.set("v.AccountNOD", AccountFTE);
                            entity.Id = response[0].Id;
                            if(component.get("v.buildingId") && urlData && urlData.NumberOfFTE ){
                                entity.Number_of_Full_Time_Employees__c = (urlData && urlData.NumberOfFTE) ? urlData.NumberOfFTE : response[0].Account.Number_of_Full_Time_Employees__c ;
                            }else{
                                entity.Number_of_Full_Time_Employees__c = response[0].Account.Number_of_Full_Time_Employees__c ? response[0].Account.Number_of_Full_Time_Employees__c : null;
                            }
                            if(component.get("v.buildingId") && urlData && urlData.InterestedInNoOfDesks ){
                                entity.Interested_in_Number_of_Desks__c = (urlData && urlData.InterestedInNoOfDesks) ? urlData.InterestedInNoOfDesks : response[0].Account.Interested_in_Number_of_Desks__c ;
                            }else{
                                entity.Interested_in_Number_of_Desks__c = response[0].Account.Interested_in_Number_of_Desks__c ? response[0].Account.Interested_in_Number_of_Desks__c : (response[0].Interested_in_Number_of_Desks__c ? response[0].Interested_in_Number_of_Desks__c :null);
                            }
                            entity.Referrer_Name__c = response[0].Referrer_Name__c ? response[0].Referrer_Name__c : null;
                            entity.Referrer_Email__c = response[0].Referrer_Email__c ? response[0].Referrer_Email__c : null;
                            entity.Phone =(urlData && urlData.Phone) ? urlData.Phone : response[0].Phone ? response[0].Phone :null;
                            entity.accountId = response[0].Account.Id;
                        }
                        else{
                            component.find("utils").showError('Related account for this contact does not exists');
                        }
                        entity.contactId = response[0].Id;
                        break;
                    case "journey":
                        if(response[0].Primary_Lead__r){
                            entity.primaryLead = response[0].Primary_Lead__r.Id;
                            entity.Id = response[0].Id;
                            entity.Email = response[0].Email__c;
                            entity.Number_of_Full_Time_Employees__c = response[0].Unomy_Company_Size__c ? helper.getUnomyCompanySize(response[0].Unomy_Company_Size__c) : response[0].Primary_Lead__r.Number_of_Full_Time_Employees__c;
                            entity.Interested_in_Number_of_Desks__c = response[0].Primary_Lead__r.Interested_in_Number_of_Desks__c;
                            entity.Referrer_Name__c = response[0].Primary_Lead__r.Referrer_Name__c ? response[0].Primary_Lead__r.Referrer_Name__c : null;
                            entity.Referrer_Email__c = response[0].Primary_Lead__r.Referrer_Email__c ? response[0].Primary_Lead__r.Referrer_Email__c : null; 
                        }
                        if(response[0].Primary_Contact__r){
                            if(response[0].Primary_Contact__r.Account){
                                let objAccount = response[0].Primary_Contact__r.Account;
                                if(objAccount.Number_of_Full_Time_Employees__c){
                                    component.set("v.showFTE", false);
                                    entity.Number_of_Full_Time_Employees__c = objAccount.Number_of_Full_Time_Employees__c;
                                }
                                entity.Interested_in_Number_of_Desks__c = objAccount.Interested_in_Number_of_Desks__c ? objAccount.Interested_in_Number_of_Desks__c : null;
                            }
                            entity.primaryContact = response[0].Primary_Contact__r.Id;
                            entity.Id = response[0].Id;
                            entity.Email = response[0].Email__c;
                            entity.Referrer_Name__c = response[0].Primary_Contact__r.Referrer_Name__c ? response[0].Primary_Contact__r.Referrer_Name__c : null;
                            entity.Referrer_Email__c = response[0].Primary_Contact__r.Referrer_Email__c ? response[0].Primary_Contact__r.Referrer_Email__c : null;
                        }
                        break;
                    case "opportunity":
                        if(response[0].Account){
                            if(response[0].Account.Number_of_Full_Time_Employees__c){
                                component.set("v.showFTE", false);
                            }
                            entity.Id = response[0].Id;
                            entity.Number_of_Full_Time_Employees__c = response[0].Account.Number_of_Full_Time_Employees__c;
                            entity.Interested_in_Number_of_Desks__c = response[0].Account.Interested_in_Number_of_Desks__c;
                        }
                        entity.opportunityId = response[0].Id;
                        entity.contactId = response[0].Primary_Member__c;
                        entity.accountId = response[0].Account.Id;
                        entity.Referrer_Name__c = response[0].Referrer_Name__c ? response[0].Referrer_Name__c : null;
                        entity.Referrer_Email__c = response[0].Referrer_Email__c ? response[0].Referrer_Email__c : null;
                        break;
                    case "opportunityRole":
                        if(response[0].Opportunity__r){
                            if(response[0].Opportunity__r.Account.Number_of_Full_Time_Employees__c){
                                component.set("v.showFTE", false);
                            }
                            entity.Id = response[0].Id;
                            entity.Number_of_Full_Time_Employees__c = response[0].Opportunity__r.Account.Number_of_Full_Time_Employees__c;
                            entity.Interested_in_Number_of_Desks__c = response[0].Opportunity__r.Account.Interested_in_Number_of_Desks__c;
                        }
                        entity.contactId = response[0].Contact__c;
                        entity.opportunityId = response[0].Opportunity__c;
                        break;
                }
                component.set("v.entity", entity);
                
                if(component.get("v.entity.entityType") == 'opportunity' || component.get("v.entity.entityType") == 'opportunityRole')
                    component.set("v.disableOpportunity", true);
                if(!(component.get("v.entity.entityType") == "contact" && component.get("v.entity.accountId")) && !(component.get("v.entity.entityType") == 'account'))
                    component.set("v.disableOpportunity", true);
                if(component.get("v.entity.entityType") == 'account'){
                    component.set("v.disableOpportunity", false);
                }                                
                if(entity.entityType != "lead" && entity.entityType !=" newlead"){
                    component.find("utils").execute("c.getDataForManageTours",{"entityType":component.get("v.entity.entityType"),"accountId":(component.get("v.entity.accountId")?component.get("v.entity.accountId"):'')},function(response){
                        var data = JSON.parse(response);
                        if(component.get("v.entity.entityType") == "account"){                               
                            component.set("v.relatedOpportunities", data.relatedOpportunities);
                            component.set("v.relatedContacts", data.relatedContacts);
                            if(data.relatedOpportunities.length){
                                component.set("v.entity.opportunityId", data.relatedOpportunities[0].Id);
                                component.set("v.oldOpportunityId", data.relatedOpportunities[0].Id);  
                            }                         
                        }
                        if(component.get("v.entity.entityType") == "contact" && component.get("v.entity.accountId")){                               
                            component.set("v.relatedOpportunities", data.relatedOpportunities);
                            component.set("v.disableOpportunity",false);
                            if(data.relatedOpportunities.length){
                                component.set("v.entity.opportunityId", data.relatedOpportunities[0].Id);
                                component.set("v.oldOpportunityId", data.relatedOpportunities[0].Id);  
                            }
                        }else if(component.get("v.entity.entityType") == "opportunity"){
                            component.set("v.relatedContacts", data.relatedContacts);
                        }
                        helper.clearTours(component);
                        helper.updateTourInfo(component,function(){
                            onsuccess();
                        },function(error){
                            onerror(error);
                        });
                    },function(error){
                        onerror(error);
                    } ,component);
                }else{
                    helper.clearTours(component);
                    onsuccess();
                }
            },function(error){
                onerror(error);
            });
        }         
    },
    clearTours:function(component){
        component.set("v.tours",[{"id":this.generateTourId(),"productLine":(component.get("v.productLine") ? component.get("v.productLine"):"WeWork"),"bookedBySalesLead":(component.get("v.isVisibleForProfile")? true : false),"buildings":JSON.parse(JSON.stringify(component.get("v.weworkBuildings")))}]);
        if(component.get("v.buildingId") && component.get("v.buildingId") != ""){
            var lstTours = JSON.parse(JSON.stringify(component.get("v.tours")));
            lstTours[0]["building"] = component.get("v.buildingId");
            component.set("v.tours", lstTours);
        }
        component.set("v.globalNotes","");
    },
    loadTimeSlots:function(component,tour,index,isChange,onsuccess,onerror){ 
        if(tour && tour.tourDate){
            if(tour.productLine != undefined && tour.productLine != ""){
                if(component.get("v.mapBuildings")[tour.productLine][tour.building] != undefined){
                    if(component.get("v.mapBuildings")[tour.productLine][tour.building].UUID__c){
                        var endPointUrl = component.get("v.api.ReservableTourBuildingAvailabilitiesAPI.url")+('?show_past=true&date=' + tour.tourDate + '&building_id=' + component.get("v.mapBuildings")[tour.productLine][tour.building].UUID__c + '&product_line=' + tour.productLine);
                        if(tour.bookedBySalesLead && JSON.parse(tour.bookedBySalesLead)) {
                            endPointUrl += "&override=true"
                        }
                        component.find("utils").execute("c.executeRest",{"method":"GET","endPointUrl":endPointUrl,"headers":component.get("v.api.ReservableTourBuildingAvailabilitiesAPI.headers"),"body":''},function(response){
                            var times = JSON.parse(response).available_tour_times;
                            for(var t in times){
                                times[t].time = times[t].time.split(" ").join("");
                            }
                            if(times!=undefined){
                                if(times.length>0 && times!=undefined){
                                    if(index!=null && index!=undefined && index!=-1){
                                        component.set("v.tours["+index+"].available_tour_times", times);
                                    }else{
                                        var i = times.findIndex(function(t){
                                            return t.time==component.get("v.tour.startTime");
                                        })
                                        if(i<0){
                                            if(component.get("v.tour.startTime")){
                                                times.push({"time":component.get("v.tour.startTime")});
                                            }
                                        }
                                        component.set("v.tour.available_tour_times", times);
                                        if(isChange){
                                            component.set("v.tour.startTime", null);
                                            component.set("v.tour.endTime", null);
                                        }
                                    }
                                    onsuccess();
                                }else{
                                    onerror('No times slots available for the selected date');
                                }   
                            }else{
                                onerror(JSON.parse(response).message); 
                            }                    
                        },function(error){            
                            onerror(error);
                        })
                    }else{  
                        onerror('No UUID available for this building.');
                    }   
                }else{
                    onerror('No time slots available for this building.'); 
                }
            }else{
                onerror('Please select product line.');  
            }
        }else{
            component.set("v.tour.startTime", null);      
            component.set("v.tour.endTime", null);    
            onsuccess();
        }
    },
    getEndTime:function(component,index,id,startTime){
        var tour;
        if(id){
            var bookedTours = component.get("v.bookedTours");
            for(var b in bookedTours){
                if(id==bookedTours[b].Id){
                    tour = {"productLine":bookedTours[b].Product_Line__c,"building":bookedTours[b].Location__c};
                }
            }
        }else{
            tour = component.get("v.tours")[index];
        }
        var hr = startTime.split(":")[0];
        var min = startTime.split(":")[1].substr(0,2);
        var am = startTime.split(":")[1].substr(2,3);
        var tourSpacing;
        if(component.get("v.mapBuildings")[tour.productLine].hasOwnProperty(tour.building)){
            tourSpacing = component.get("v.mapBuildings")[tour.productLine][tour.building].Tour_Spacing__c;
        }
        if(tourSpacing=="Half Hour"){
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
    manageTour: function(component, helper, lead){ 
        component.find("utils").showProcessing();
        component.set("v.showAccountSelector", false);        
        helper.continueAfterAccountSelector(component, helper, function(message){
            if(component.get("v.isVisibleForProfile") && (component.get("v.entity.entityType") == "contact" || component.get("v.entity.entityType") == "account" || (component.get("v.entity.entityType") == "opportunity" || component.get("v.entity.entityType") == "opportunityRole")) && (component.get("v.entity.Referrer_Email__c") || component.get("v.entity.Referrer_Name__c"))){
                helper.saveReferralInfo(component);    
            }
            component.find("utils").showSuccess(message);
            component.find("utils").hideProcessing();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        });
    },
    createLead:function(component,onsuccess,onerror){ 
        var helper = this;
        var entity = component.get("v.entity");       
        if(entity.entityType == "newlead"){
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
            delete lead['Name'];
            delete lead['entityType'];
            component.find("utils").execute("c.saveRecord",{"record":lead},function(response){
                component.set("v.entity.Id", JSON.parse(response).id);
                component.set("v.entity.entityType", "lead");
                component.set("v.salesEntity.leadId", JSON.parse(response).id);
                onsuccess(true);
            },function(error){
                onerror(error);
            });
        }else if(entity.entityType == "lead" || (entity.entityType == "journey" && entity.hasOwnProperty('primaryLead'))){
            var lead = JSON.parse(JSON.stringify(component.get("v.entity")));
            if(entity.entityType == "lead"){
                var names = lead.Name.split(" ");
                if(names.length > 1){
                    var arrFirstName = names.slice(0,names.length-1)
                    lead.FirstName = arrFirstName.join(" ");
                    lead.LastName = names[names.length-1];
                }else{
                    lead.LastName = names[0];
                }
            }
            if(entity.entityType == "journey"){
                lead['Id'] = lead.primaryLead;
                delete lead['primaryLead'];
            }
            delete lead['Name'];
            delete lead['entityType'];
            component.find("utils").execute("c.saveRecord",{"record": lead},function(response){
                if(entity.entityType == "journey"){
                    component.set("v.salesEntity.journeyId", component.get("v.journeyId")); 
                }else{
                    component.set("v.salesEntity.leadId", JSON.parse(response).id); 
                }
                onsuccess(true);
            },function(error){
                onerror(error);
            })
        }else{
            onsuccess(false);
        }
    },
    continueAfterAccountSelector:function(component,helper,onsuccess,onerror){
        helper.convertLeadToExisting(component,function(){
            helper.getBookingInfo(component,function(){
                var tours = component.get("v.tours");
                var toursData = [];
                for(var t in tours){
                    if(!tours[t].removed){
                        toursData.push({
                            "date": tours[t].tourDate,
                            "time": tours[t].startTime,
                            "building_id": component.get("v.mapBuildings")[tours[t].productLine][tours[t].building].UUID__c,
                            "notes": tours[t].notes?tours[t].notes:component.get("v.globalNotes"),
                            "product_line": tours[t].productLine,
                            "contact_name": component.get("v.bookingData.contactData.Name"),
                            "email": component.get("v.bookingData.contactData.Email"),
                            "phone": component.get("v.bookingData.contactData.Phone")?component.get("v.bookingData.contactData.Phone"):null,
                            "company_name": component.get("v.bookingData.contactData.Account.Name"),
                            "contact_uuid": component.get("v.bookingData.contactData.UUID__c"),
                            "company_uuid": component.get("v.bookingData.contactData.Account.UUID__c"),
                            "sf_journey_uuid": component.get("v.journeyId")?component.get("v.journeyId"):null,
                            "primary_member": component.get("v.bookingData.contactData.Id"),
                            "booked_by_id": "",
                            "booked_by_contact_id": component.get("v.currentUserContact.Id"),
                            'opportunity_id': component.get("v.entity.opportunityId")?component.get("v.entity.opportunityId"):null,
                            "lead_source": component.get("v.bookingData.contactData.LeadSource"),
                            "lead_source_detail": "",
                            "addBookTourNo": "addBookingId"+t,
                            "booked_by_sales_lead": tours[t].bookedBySalesLead,
                            "assigned_host": component.get("v.currentUserContact.Id"),
                            "hosted_by": component.get("v.currentUserContact.Id")
                        })
                    }
                }
                helper.bookTours(component,toursData,0,function(errors){
                    onsuccess("Tour Booked Successfully and will be synced shortly.");
                },[])
            },function(error){
                onerror(error);
            })
        },function(error){
            onerror(error);
        })
    },
    convertLeadToExisting:function(component,onsuccess,onerror){
        var entity = component.get("v.entity");
        var tours = component.get("v.tours");
        var selectedRecord;
        if(component.get("v.salesEntity.selectedAction") == "Use Selected to Convert"){
            selectedRecord =  component.get("v.salesEntity.selectedRecord");
        }else{
            selectedRecord =  component.get("v.OrgRecord.Id");
        }
        if(entity.entityType == "lead" || (entity.entityType == "journey" && entity.hasOwnProperty("primaryLead"))){
            var leadId;
            if(entity.entityType == "lead"){
                leadId = component.get("v.entity.Id");
            }else{
                leadId = component.get("v.entity.primaryLead");
            }
            var lead = {};
            lead.Id = leadId;
            lead.Email = entity.Email;
            lead.Interested_in_Number_of_Desks__c = component.get("v.entity.Interested_in_Number_of_Desks__c");
            lead.Number_of_Full_Time_Employees__c = component.get("v.entity.Number_of_Full_Time_Employees__c");
            if(selectedRecord){
                lead.Account__c = selectedRecord;   
            }           
            component.find("utils").execute("c.convertLeadsToExisting",{"objLead":lead},function(response){
                if(response && response!="null"){
                    component.set("v.entity.contactId", JSON.parse(response).contactId);
                    onsuccess();
                }else{
                    onerror('Unexpected error occured, please contact your System administrator.');
                }
            },function(error){
                onerror(error);
            })
        }else{
            onsuccess();
        }
    },
    getBookingInfo:function(component,onsuccess,onerror){
        var entity = component.get("v.entity");
        var contactQuery,opportunityQuery;
        if(entity.entityType == "newlead" || entity.entityType == "lead" || (entity.entityType == "journey" &&  (entity.hasOwnProperty('primaryLead') || entity.hasOwnProperty('primaryContact')))){
            contactQuery = "Select Id,Name,Email,Phone,UUID__c,LeadSource,Account.Id,Account.Name,Account.UUID__c From Contact Where Id='"+(entity.hasOwnProperty('primaryContact')==false?component.get("v.entity.contactId"):entity.primaryContact)+"'";           	
        }else if(component.get("v.entity.contactId")){
            contactQuery = "Select Id,Name,Email,Phone,UUID__c,LeadSource,Account.Id,Account.Name,Account.UUID__c From Contact Where Id='"+component.get("v.entity.contactId")+"'";           
            if(component.get("v.entity.opportunityId")){
                opportunityQuery = "Select Id,Name From Opportunity Where Id='"+component.get("v.entity.opportunityId")+"'";
            }
        }
       var bookingData = {};
        if(contactQuery){
            component.find("utils").execute("c.getQueryData",{"query":contactQuery},function(contactData){
                bookingData['contactData'] = contactData[0];
                if(opportunityQuery){
                    component.find("utils").execute("c.getQueryData",{"query":opportunityQuery},function(opportunityData){
                        bookingData['opportunityData'] = opportunityData[0];
                        component.set("v.bookingData",bookingData);
                        onsuccess();
                    },function(error){
                        onerror(error);
                    })
                }else{
                    component.set("v.bookingData",bookingData);
                    onsuccess();
                }
            },function(error){
                onerror(error);
            })
        }else{
             onsuccess();
        }
    },
    bookTours:function(component,tours,index,onsuccess,errors){        
        var helper = this;
        component.find("utils").execute("c.executeRestQuery",{"setUrl":!component.get("v.api.ReservableCreateAPI.url").includes("https:"),"method":"POST","endPointUrl":component.get("v.api.ReservableCreateAPI.url"),"headers":component.get("v.api.ReservableCreateAPI.headers"),"body":JSON.stringify(tours[index])},function(response){
            var result = JSON.parse(response);
            if(result.hasOwnProperty('error')){
                component.find("utils").showError(result.message);
                component.find("utils").hideProcessing();
            }
            else 
                if(index < tours.length-1){
                    helper.bookTours(component,tours,(index+1),onsuccess,errors);
                }
                else{ 
                    onsuccess(errors);
                }
        },function(error){
            errors.push({index:error});
            if(index < tours.length-1){
                helper.bookTours(component,tours,(index+1),onsuccess,errors);
            }else{
                onsuccess(errors);
            }
        })
    },
    updateTourInfo:function(component,onsuccess,onerror){
        var entity = component.get("v.entity");
        var fetchTours = true;
        var tourQuery = "Select Id,Name,Tour_Date__c,Start_Time__c,Status__c,booked_by_contact_id__c,Product_Line__c,New_Tour_Notes__c,Location__c,Location__r.Name,UUID__c From Tour_Outcome__c ";
        if((entity.entityType == "newlead" || entity.entityType == "lead") && component.get("v.entity.contactId")){
            tourQuery += "Where Primary_Member__c='"+component.get("v.entity.contactId")+"'";
        }else if(entity.entityType == "contact" && component.get("v.entity.Id")){
            tourQuery += "Where Primary_Member__c='"+component.get("v.entity.Id")+"'";
        }else if(entity.entityType == "journey"){
            if(entity.hasOwnProperty('primaryLead')){
                if(component.get("v.entity.contactId") == undefined){
                    fetchTours=false;
                }else{
                    tourQuery += "Where Primary_Member__c='"+component.get("v.entity.contactId")+"'";
                }
            }else if(component.get("v.entity.primaryContact")){
                tourQuery += "Where Primary_Member__c='"+component.get("v.entity.primaryContact")+"'";   
            }
        }else if(entity.entityType == "opportunity"){
            tourQuery += "Where Opportunity__c='"+component.get("v.entity.opportunityId")+"'";
        }else if(entity.entityType == "account"){
            if(component.get("v.entity.opportunityId") && component.get("v.entity.contactId")){
                tourQuery += "Where Primary_Member__c='"+component.get("v.entity.contactId")+"' AND Opportunity__c='"+component.get("v.entity.opportunityId")+"'";  
            }else if(component.get("v.entity.contactId")){
                tourQuery += "Where Primary_Member__c='"+component.get("v.entity.contactId")+"'"; 
            }else if(component.get("v.entity.opportunityId")){
                tourQuery += "Where Opportunity__c='"+component.get("v.entity.opportunityId")+"'";  
            }            
        }else if(component.get("v.entity.contactId") && component.get("v.entity.opportunityId")){
            tourQuery += "Where Primary_Member__c='"+component.get("v.entity.contactId")+"' AND Opportunity__c='"+component.get("v.entity.opportunityId")+"'";
        }
        if(fetchTours && tourQuery.toLowerCase().includes('where')){
            component.find("utils").execute("c.getQueryData",{"query":tourQuery},function(tours){
                var mapTours = {};
                for(var t in tours){
                    mapTours[tours[t].Id] = tours[t];
                }
                component.set("v.bookedTours",tours);
                component.set("v.mapBookedTours",mapTours);
                if(onsuccess){
                    onsuccess();
                }
            },function(error){
                if(onsuccess){
                    onsuccess(error);
                }
            })
        }else{
            if(onsuccess){
                onsuccess();
            }
        }
    },
    syncTours:function(component){
        var helper = this;
        if(component.get("v.buildingId") && component.get("v.buildingId") != ""){
            component.find("utils").redirectToUrl("/apex/communityView?building_id="+component.get("v.buildingId")+((component.get("v.productLine") != null && component.get("v.productLine") != "")?"&product_line="+component.get("v.productLine"):"")+'&url_Data='+component.get("v.urlData"),'',false);
        }else if(component.get("v.contactId") && component.get("v.buildingId")){
            component.find("utils").redirectToUrl("/"+component.get("v.contactId"), "", false); 
        }else {
            if(component.get("v.entity.managed") || component.get("v.syncedToursCount") == component.get("v.tours").length-1){ 
                if(component.get("v.entity.entityType") == "lead" || component.get("v.entity.entityType") == "newlead"){
                    if(component.get("v.buildingId") && component.get("v.buildingId") != ""){
                        component.find("utils").redirectToUrl("/apex/BookTours?contactId="+component.get("v.entity.contactId")+"&buildingId="+component.get("v.buildingId")+((component.get("v.productLine") != null && component.get("v.productLine") != "")?"&productLine="+component.get("v.productLine"):""), "", false);
                    }else{
                        component.find("utils").redirectToUrl("/apex/BookTours?contactId="+component.get("v.entity.contactId"), "", false);
                        //component.find("utils").closeTab();
                    }
                }else{
                    location.reload();
                }
            }else{
                component.set("v.syncedToursCount", component.get("v.syncedToursCount")+1);
            }
        }        
    },
    subscribeToPushTopics:function(component){
        var helper = this;
        component.find("utils").execute("c.getSessionId",{},function(sessionId){
            $.cometd.init({
                url: '/cometd/38.0',
                requestHeaders: {"Authorization": "OAuth "+sessionId}
            });
            
            $.cometd.subscribe('/topic/ManageTours', function(message) {                
                var sobject = message.data.sobject
                if(component.get("v.entity.entityType") == "newlead" || component.get("v.entity.entityType") == "lead"){
                    if(sobject.Primary_Member__c.substring(0,15)==component.get("v.entity.contactId").substring(0,15)){
                        helper.syncTours(component);
                    }
                }else if(component.get("v.entity.entityType") == "contact" || component.get("v.entity.entityType") == "account"){
                    if(sobject.Primary_Member__c.substring(0,15) == component.get("v.entity.Id").substring(0,15) || (sobject.Primary_Member__c.substring(0,15) == component.get("v.entity.contactId").substring(0,15))){
                        helper.syncTours(component);
                    }
                }else if(component.get("v.entity.entityType") == "journey"){
                    if(component.get("v.entity").hasOwnProperty('primaryLead')){
                        if(sobject.Primary_Member__c.substring(0,15) == component.get("v.entity.contactId").substring(0,15)){
                            helper.syncTours(component);
                        }
                    }else{
                        if(sobject.Primary_Member__c.substring(0,15) == component.get("v.entity.primaryContact").substring(0,15)){
                            helper.syncTours(component);
                        }
                    }
                }else if(component.get("v.entity.entityType") == "opportunity"){
                    if(sobject.Opportunity__c.substring(0,15) == component.get("v.opportunityId").substring(0,15)){
                        helper.syncTours(component);
                    }
                }else if(component.get("v.entity.entityType") == "opportunityRole"){
                    if(sobject.Primary_Member__c.substring(0,15) == component.get("v.entity.contactId").substring(0,15) && sobject.Opportunity__c.substring(0,15) == component.get("v.entity.opportunityId").substring(0,15)){
                        helper.syncTours(component);
                    }
                }
            });
        });
    },
    validateTours:function(component,index){
        if(index != undefined && index != -1){
            var tours = component.get("v.tours");
            var exp = tours[index].building+'-'+tours[index].tourDate+'-'+tours[index].startTime;
            var mapTours = {};
            var valid = true;
            for(var tourIndex in tours){
                if(tours[tourIndex].building && tours[tourIndex].tourDate && tours[tourIndex].startTime){
                    var exp = tours[tourIndex].building+'-'+tours[tourIndex].tourDate+'-'+tours[tourIndex].startTime;
                    if(mapTours.hasOwnProperty(exp)){
                        component.set("v.tours["+mapTours[exp]+"].invalid", true);
                        component.set("v.tours["+tourIndex+"].invalid", true);
                        valid = false;
                    }else{
                        component.set("v.tours["+tourIndex+"].invalid", false);
                        mapTours[exp] = tourIndex;
                    }
                }else{
                    component.set("v.tours["+tourIndex+"].invalid", false);
                }
            }
            if(component.get("v.validTours") && !valid){
                component.find("utils").showError("Duplicate tours found, You can not book a tour with same building, tour date and tour time at once.");
            }
            component.set("v.validTours", valid);
        }else{
            var bookedTours = component.get("v.bookedTours");
            var isValid = true;
            for(var tour in bookedTours){
                if(bookedTours[tour].Status__c == 'Scheduled' && component.get("v.tour.building") == bookedTours[tour].Location__c && component.get("v.tour.tourDate") == bookedTours[tour].Tour_Date__c && component.get("v.tour.startTime") == bookedTours[tour].Start_Time__c){
                    isValid = false;
                    break;
                }
            }
            if(isValid){
                component.set("v.validReschedule", true);
            }else{
                component.find("utils").showError("You have already scheduled tour for the same building, on the same date and time.")
                component.set("v.validReschedule", false);
            }
        }
        
    },
    generateTourId:function(){
        return Math.floor((Math.random() * 99999) + 11111);
    },
    getTourIndex:function(component,id){
        var index = component.get("v.tours").findIndex(function(tour){
            return tour.id == parseInt(id.split(":")[1]);
        })
        return index;
    },
    getToursCount:function(component,tours){
        var count = 0;
        var validTourId;
        for(var tourIndex in tours){
            if(!tours[tourIndex].removed){
                validTourId = tours[tourIndex].id;
                tours[tourIndex].relatedIndex = count++;
            }
        }
        component.set("v.lastValidTour", validTourId);
        component.set("v.toursCount", count);
        component.set("v.tours", tours);
    },
    saveReferralInfo:function(component){
        var referrerName = component.get("v.entity.Referrer_Name__c"); 
        var referrerEmail = component.get("v.entity.Referrer_Email__c");
        component.find("utils").execute("c.saveRecords",{"records":[{"Id":component.get("v.entity.contactId"),"Referrer_Email__c": referrerEmail, "Referrer_Name__c":referrerName},{"Id":component.get("v.entity.opportunityId"),"Referrer_Email__c": referrerEmail,"Referrer_Name__c":referrerName}]},function(response){
        },function(error){
            component.find("utils").showError('Error in saving referral information');
        });
    },
    updateInterestedNoOfDesksOnOpp : function(component, event, helper){       
        var entity = component.get("v.entity");
        var oldopp = component.get("v.oldOpportunityId");         
        var query = "Select Id,Name,Interested_in_Number_of_Desks__c,Number_of_Full_Time_Employees__c,(Select Id,Name,Quantity From opportunityLineItems ORDER BY CreatedDate DESC LIMIT 1 ) From opportunity Where Id='"+entity.opportunityId+"'";
        
        if((entity.entityType == "contact" && entity.opportunityId) && (oldopp == undefined || oldopp.substring(0,15) != entity.opportunityId.substring(0,15))){
            component.find("utils").execute("c.getQueryData",{"query":query},function(response){                          	                           
                var result;
                if(response[0] && response[0].hasOwnProperty('OpportunityLineItems')){
                    result = response[0].OpportunityLineItems[0];
                }                          
                var OpportunityLineItemObject = {};
                var opportunityObject = {};
                var lstRecords = []; 
                if(result && result.Id){
                    OpportunityLineItemObject.Id = result.Id;
                    OpportunityLineItemObject.Quantity = entity.Interested_in_Number_of_Desks__c;                          
                    OpportunityLineItemObject.opportunityId = entity.OpportunityId;
                }
                opportunityObject.Id = entity.opportunityId;
                opportunityObject.Number_of_Full_Time_Employees__c = entity.Number_of_Full_Time_Employees__c;
                opportunityObject.Interested_in_Number_of_Desks__c = entity.Interested_in_Number_of_Desks__c;    
                
                lstRecords.push(opportunityObject);
                lstRecords.push(OpportunityLineItemObject);
                component.find("utils").execute("c.saveRecords",{"records":lstRecords},function(response){
                },function(errors){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(errors);
                }); 
            },function(errors){
                component.find("utils").hideProcessing();
                component.find("utils").showError(errors);  
            });                       
        }
    },
    addSlashes:function(str){
        str = str.split("'").join("\\'");        
        return str.trim();
    },
    setFilters : function(component, event, helper){
        var urlData = component.get("v.urlData");
        if(urlData != ""){
            urlData = JSON.parse(decodeURI(urlData)); 
            for(var key in urlData){
                if(urlData[key] != 'undefined' && urlData[key] != 'null'){
                    component.set("v."+key, urlData[key]);
                }
            }
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
    getOnLoadTimeSlotForInstantTour : function(component,event,helper){
        var urlData ;
        if(component.get("v.urlData")){
            urlData = JSON.parse(component.get("v.urlData"));
        }
        if(urlData){
            var tours = [];
            var index = 0;
            var tour = {"id":helper.generateTourId(),"building":component.get("v.buildingId"), "tourDate": urlData.tourDate, "productLine" : 'WeWork',"startTime":urlData.startTime,"endTime":urlData.startTime ? helper.getEndTime(component,0,"",urlData.startTime) : null};
            if(component.get("v.mapBuildings")[tour.productLine][tour.building] == undefined){ 
                tour.startTime = null; 
                tour.endTime = null;
            }
            component.set("v.tours",[tour])
            helper.loadTimeSlots(component,tour,0,true,function(){
                if(!index){     
                    helper.validateTours(component,index);
                }else{
                    component.set("v.tour.startTime", null);      
                    component.set("v.tour.endTime", null);          
                    component.set("v.tour.notes", null);          
                }  
                component.find("utils").hideProcessing();
            },function(error){
                component.find("utils").hideProcessing();  
                component.find("utils").showError(error);
                
            })
        }
        component.find("utils").hideProcessing();
    }
})