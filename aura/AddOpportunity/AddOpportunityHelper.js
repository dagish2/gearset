({
    getJourneyData: function (component, event, helper, onsuccess, onerror) {        
        component.find("utils").execute("c.getAddOpportunityData", {"journeyId": component.get("v.journeyId")}, function(response){
            var addOpportunityData = JSON.parse(response);
            component.set("v.todayDate", addOpportunityData.systemDate);
            component.set("v.journey", addOpportunityData.journeyRecord);
            if(addOpportunityData.journeyRecord.hasOwnProperty("Primary_Lead__c") == false)
                component.set("v.isContact", true);
            else
                component.set("v.isContact", false);
            component.set("v.addOpportunityData", JSON.parse(addOpportunityData.settingData));
            
            var profiles = JSON.parse(addOpportunityData.excludedProfiles).Profiles; 
            var excludedProfiles = [];
            for(var index = 0; index < profiles.length; ++index){
                excludedProfiles.push(profiles[index].toLowerCase());
            }
            component.set("v.excludedProfiles", excludedProfiles);
            component.set("v.currentUsersProfile", (addOpportunityData.currentUserProfile).toLowerCase());
            onsuccess();
        },function(error){
            onsuccess(error);
        }, component);
    },
    showOpportunities : function (component, event, helper, onsuccess, onerror) {
        var opportunityColumns = [  { label: "Action", type : "button", typeAttributes: { variant:"base", name:"SendPaperwork", label: "Send Paperwork" }},
                                  {"label" : "Name", fieldName: "Id", type: "url", typeAttributes:{ label: { fieldName : "Name"}} },
                                  {"fieldName":"Quantity__c", "label":"No. Of Desk(s)", "type":"phone", "cellAttributes": { "alignment": "center" }}, 
                                  {"fieldName":"Deal_Type__c", "label":"Deal Type", "type":"text"},
                                  {"fieldName":"Building__r.Name", "label":"Building/Nearest Building", "type":"component","component":{"name":"c:EnziOutputUrl","attributes":{"value":"{{Building__c}}","label":"{{Building__r.Name}}","click": component.getReference("c.redirectToUrl")}}},
                                  {"fieldName":"StageName", "label":"Stage", "type":"text"},
                                  {"fieldName":"CloseDate", "label":"Close Date", "type":"date"}                                 	
                                 ];
        component.set("v.opportunityColumns", opportunityColumns);
        if(component.get("v.journey").hasOwnProperty("Primary_Contact__c")){
            component.find("utils").execute("c.getQueryData", {"queryLable": "getJourneyRelatedOpportunities", "journeyId" : component.get("v.journeyId"), "contactId" : component.get("v.journey").Primary_Contact__c, "accountId" : null}, function(relatedOpportunitiesResponse){                   
                component.set("v.opportunities", relatedOpportunitiesResponse);
                onsuccess();
            },function(error){
                onerror(error);
            }, component);
        }else{
            onsuccess();
        }
    },
    showNewOpportunityModal: function (component, event, helper, onsuccess, onerror) {
        component.set("v.showNewOppModal", true);
        var journey = component.get("v.journey");        
        helper.getOpportunityData(component, event, helper, onsuccess, onerror);
        component.find("NewOpportunityModal").showModal();
    },
    closeNewOpportunityModal: function (component, helper) {
        var obj = {
            "Number_of_Full_Time_Employees__c": null,
            "Interested_in_Number_of_Desks__c": null,
            "Building__c": null,
            "Owner_Auto_Assign__c": true
        };
        component.set("v.opportunity", obj);        
        component.find("NewOpportunityModal").close();
    },
    getOpportunityData: function (component, event, helper, onsuccess, onerror) {        
        var journey = component.get("v.journey");
        var opportunityData = {};
        opportunityData["journeyId"] = journey.Id;
        if(component.get("v.accountId")){
            opportunityData["accountId"] = component.get("v.accountId");
            if(journey.hasOwnProperty("Primary_Contact__r")){
                opportunityData["contactId"] = journey.Primary_Contact__r.Id;
            }else{
                opportunityData["leadId"] = journey.Primary_Lead__c;
            }
        }else{
            if(journey.hasOwnProperty("Primary_Contact__r")){
                opportunityData["accountId"] = journey.Primary_Contact__r.Account.Id;
                opportunityData["contactId"] = journey.Primary_Contact__r.Id;
            }else{
                opportunityData["leadId"] = journey.Primary_Lead__c;
            }
        }
        component.find("utils").execute("c.getJourneyOpportunityData", {"mapOpportunityData":opportunityData}, function(response){
            component.set("v.journeyOpportunityData", JSON.parse(response));
            helper.initOpportunity(component, event, helper);
            onsuccess()            
        },function(error){
            onerror(error);
        }, component);
    },
    save: function (component, event, helper, contactId, onsuccess, onerror) {
        var opportunity = component.get("v.opportunity");
        var opportunityForm = component.get("v.opportunityForm");
        var accRec = component.get("v.accountRec");
        opportunity.Number_of_Full_Time_Employees__c = accRec ? accRec.Number_of_Full_Time_Employees__c : opportunityForm.Number_of_Full_Time_Employees__c;
        opportunity.Interested_in_Number_of_Desks__c = accRec ? accRec.Interested_in_Number_of_Desks__c : opportunityForm.Interested_in_Number_of_Desks__c;
        opportunity.Building__c = opportunityForm.Building__c;
        opportunity.CloseDate = opportunityForm.CloseDate;
        var opportunityData = component.get("v.journeyOpportunityData");
        var addOpportunityData = component.get("v.addOpportunityData");
        var recordsToSave = [];
        var objJourney = {};
        var flag = false;
        opportunity.Name="New Opportunity";
        opportunity.Journey__c = opportunityData.journey.Id;
        if(contactId != "" && contactId != null){
            opportunity.Primary_Member__c = contactId;
        }else{
            opportunity.Primary_Member__c = opportunityData.journey.Primary_Contact__c;
        }
        opportunity.AccountId = opportunityData.journey.Primary_Contact__r.AccountId;
        opportunity.StageName = "Qualifying";
        
        var locationInterested = {};
        var lstbuildings = [];
        if (opportunityData.contact.Location_Interested__c != null) {
            lstbuildings = opportunityData.contact.Location_Interested__c.split(";")
            lstbuildings.forEach(function(building){
                if (locationInterested[building.toLowerCase()] == undefined)
                    locationInterested[building.toLowerCase()] = building;
            })
        }
        if(opportunity.Building__c && opportunityData.mapBuildings.hasOwnProperty(opportunity.Building__c) && opportunityData.mapBuildings[opportunity.Building__c].Name && !locationInterested.hasOwnProperty(opportunityData.mapBuildings[opportunity.Building__c].Name.toLowerCase())){
            locationInterested[opportunityData.mapBuildings[opportunity.Building__c].Name.toLowerCase()] = opportunityData.mapBuildings[opportunity.Building__c].Name;
        }
        opportunity.Locations_Interested__c = Object.values(locationInterested).join(";");
        opportunity.Journey__c = component.get("v.journeyId"); 
        objJourney.UserType__c = (opportunity.RecordTypeId == opportunityData.opportunityRecordTypes["Enterprise Solutions"].recordTypeId) ? "Enterprise Solutions" : "Default";
        objJourney.Id = opportunityData.journey.Id;
        objJourney.Status__c = "Completed";
        objJourney.Building_Interested_In__c = opportunity.Building__c;
        if(Object.values(locationInterested).length > 0)
            objJourney.Locations_Interested__c = Object.values(locationInterested).join(";");
        
        var objAccount = {};
        var contactToUpdate = {};
        var lstRecordsToUpdate =[];
        
        objAccount.Id = opportunityData.journey.Primary_Contact__r.AccountId;
        objAccount.Number_of_Full_Time_Employees__c = accRec ? accRec.Number_of_Full_Time_Employees__c : opportunityForm.Number_of_Full_Time_Employees__c;
        objAccount.Interested_in_Number_of_Desks__c = accRec ? accRec.Interested_in_Number_of_Desks__c : opportunityForm.Interested_in_Number_of_Desks__c;
        
        contactToUpdate.Id = opportunityData.journey.Primary_Contact__c;
        contactToUpdate.Number_of_Full_Time_Employees__c = accRec ? accRec.Number_of_Full_Time_Employees__c : opportunityForm.Number_of_Full_Time_Employees__c;
        contactToUpdate.Interested_in_Number_of_Desks__c = accRec ? accRec.Interested_in_Number_of_Desks__c : opportunityForm.Interested_in_Number_of_Desks__c;
        contactToUpdate.Location__c = opportunityForm.Building__c;
        contactToUpdate.Location_Interested__c = Object.values(locationInterested).join(";");
        
        lstRecordsToUpdate.push(objAccount);
        lstRecordsToUpdate.push(contactToUpdate);
        lstRecordsToUpdate.push(objJourney);
        
        component.find("utils").execute("c.saveRecords",{"records": lstRecordsToUpdate}, function(response){
            component.find("utils").execute("c.insertAddOpportunity", {"mapOpportunityData": opportunity}, function(result){
                component.set("v.opportunityId", JSON.parse(result).id);
                component.set("v.todayDate",JSON.parse(response).SystemToday);
                helper.showOpportunities(component, event, helper,function(){
                    component.find("NewOpportunityModal").close();
                    onsuccess();
                },function(error){
                    onerror(error);
                });
            },function(error){
                onerror(error);
            }, component);
        },function(error){
            onerror(error);
        });
    },
    close: function (component, event, helper){
        component.find("utils").showConfirm("Are you sure you want to close this page ?",function(){
            component.find("utils").closeTab();
        });
    },
    initOpportunity: function(component, event, helper){ //Method to initialize new Opportunity object with prepopulated values.		
        var journeyOpportunityData = component.get("v.journeyOpportunityData");
        var opportunity = {"Owner_Auto_Assign__c": false};
        if(journeyOpportunityData.account && journeyOpportunityData.account.Number_of_Full_Time_Employees__c != undefined){
            opportunity["Number_of_Full_Time_Employees__c"] = parseInt(journeyOpportunityData.account.Number_of_Full_Time_Employees__c);
        }else if(journeyOpportunityData.account && journeyOpportunityData.account.Company_Size__c != undefined){
            if(journeyOpportunityData.account.Company_Size__c.includes("-")){
                opportunity["Number_of_Full_Time_Employees__c"] = parseInt(journeyOpportunityData.account.Company_Size__c.split("-")[0]);
            } else if(journeyOpportunityData.account.Company_Size__c.includes("+")){
                opportunity["Number_of_Full_Time_Employees__c"] = parseInt(journeyOpportunityData.account.Company_Size__c.split("+")[0]);
            }
        } else if (journeyOpportunityData.account && journeyOpportunityData.account.Unomy_Company_Size__c != undefined) {
            if (journeyOpportunityData.account.Unomy_Company_Size__c.includes("-")) {
                opportunity["Number_of_Full_Time_Employees__c"] = parseInt(journeyOpportunityData.account.Unomy_Company_Size__c.split("-")[0]);
            } else if(journeyOpportunityData.account.Unomy_Company_Size__c.includes("+")){
                opportunity["Number_of_Full_Time_Employees__c"] = parseInt(journeyOpportunityData.account.Unomy_Company_Size__c.split("+")[0]);
            }
        } else if(journeyOpportunityData.contact && journeyOpportunityData.contact.Number_of_Full_Time_Employees__c != undefined){
            opportunity["Number_of_Full_Time_Employees__c"] = parseInt(journeyOpportunityData.contact.Number_of_Full_Time_Employees__c);
        } else if(journeyOpportunityData.contact && journeyOpportunityData.contact.Company_Size__c != undefined){
            if(journeyOpportunityData.contact.Company_Size__c.includes("-")){
                opportunity["Number_of_Full_Time_Employees__c"] = parseInt(journeyOpportunityData.contact.Company_Size__c.split("-")[0]);
            } else if(journeyOpportunityData.account.Company_Size__c.includes("+")){
                opportunity["Number_of_Full_Time_Employees__c"] = parseInt(journeyOpportunityData.contact.Company_Size__c.split("+")[0]);
            }
        } else if (journeyOpportunityData.contact && journeyOpportunityData.contact.Unomy_Company_Size__c != undefined) {
            if (journeyOpportunityData.contact.Unomy_Company_Size__c.includes("-")) {
                opportunity["Number_of_Full_Time_Employees__c"] = parseInt(journeyOpportunityData.contact.Unomy_Company_Size__c.split("-")[0]);
            } else if(journeyOpportunityData.contact.Unomy_Company_Size__c.includes("+")){
                opportunity["Number_of_Full_Time_Employees__c"] = parseInt(journeyOpportunityData.contact.Unomy_Company_Size__c.split("+")[0]);
            }
        } else if(journeyOpportunityData.lead && (journeyOpportunityData.lead.Number_of_Full_Time_Employees__c != undefined || journeyOpportunityData.lead.Unomy_Company_Size__c != undefined)){
            //opportunity["Number_of_Full_Time_Employees__c"] = parseInt(journeyOpportunityData.lead.Number_of_Full_Time_Employees__c);
            if(journeyOpportunityData.lead.Unomy_Company_Size__c != undefined){                
                opportunity["Number_of_Full_Time_Employees__c"] = parseInt(helper.getUnomyCompanySize(journeyOpportunityData.lead.Unomy_Company_Size__c));                
            } else if(journeyOpportunityData.lead.Number_of_Full_Time_Employees__c != undefined){
                opportunity["Number_of_Full_Time_Employees__c"] = parseInt(journeyOpportunityData.lead.Number_of_Full_Time_Employees__c);
            }            
        }
        if(opportunity["Number_of_Full_Time_Employees__c"] && opportunity["Number_of_Full_Time_Employees__c"] != ""){
            component.set("v.isFTEDisabled", (journeyOpportunityData.lead==undefined || journeyOpportunityData.lead == null));
        }
        
        // Interested number of desks
        if(journeyOpportunityData.account && journeyOpportunityData.account.Interested_in_Number_of_Desks__c != undefined){
            opportunity["Interested_in_Number_of_Desks__c"] = parseInt(journeyOpportunityData.account.Interested_in_Number_of_Desks__c);
        } else if(journeyOpportunityData.contact && journeyOpportunityData.contact.Interested_in_Number_of_Desks__c != undefined){
            opportunity["Interested_in_Number_of_Desks__c"] = parseInt(journeyOpportunityData.contact.Interested_in_Number_of_Desks__c);
        } else if(journeyOpportunityData.lead && journeyOpportunityData.lead.Interested_in_Number_of_Desks__c != undefined) {
            opportunity["Interested_in_Number_of_Desks__c"] = parseInt(journeyOpportunityData.lead.Interested_in_Number_of_Desks__c);
        }
        
        // Building
        if (journeyOpportunityData.journey && journeyOpportunityData.journey.Building_Interested_In__c != undefined) {
            opportunity["Building__c"] = journeyOpportunityData.journey.Building_Interested_In__c;            
        } else if (journeyOpportunityData.contact && journeyOpportunityData.contact.Location__c != null) {
            opportunity["Building__c"] = journeyOpportunityData.contact.Location__c;            
        } else if (journeyOpportunityData.journey && journeyOpportunityData.journey.Location_Interested__c != null) {
            var buildingInterestedIn = journeyOpportunityData.journey.Location_Interested__c.split(";")[0];
            opportunity["Building__c"] = journeyOpportunityData.mapBuildings[buildingInterestedIn].Id;            
        } else if (journeyOpportunityData.contact && journeyOpportunityData.contact.Location_Interested__c != null) {
            var buildingInterestedIn = journeyOpportunityData.contact.Location_Interested__c.split(";")[0];			
            if(journeyOpportunityData.mapBuildings && journeyOpportunityData.mapBuildings[buildingInterestedIn] != undefined){
                opportunity["Building__c"] = journeyOpportunityData.mapBuildings[buildingInterestedIn].Id;
            }else {
                var tempBuildingMap = [];
                var building = journeyOpportunityData.mapBuildings;
                for(var d in building){
                    var b =  building[d].Name;
                    tempBuildingMap[b] = building[d];
                    tempBuildingMap.push(tempBuildingMap[b]);
                }
                if(tempBuildingMap && tempBuildingMap[buildingInterestedIn] != undefined){
                    opportunity["Building__c"] = tempBuildingMap[buildingInterestedIn].Id;
                }	
            }            
        }
        component.set("v.opportunity", opportunity);
    },
    sendPaperwork:function(component, event, helper){      
        var opportunity = JSON.parse(JSON.stringify(event.getParam('record')));
        if(opportunity){
            var settings = component.get("v.addOpportunityData");
            console.log(settings);
            component.find("utils").execute("c.isValidOppforSendPaperwork", {"oppId": opportunity.Id}, function(result){
                var result = JSON.parse(result);
                if(result.isValid){
                    window.open("/apex/sendPaperWork?Id=" + opportunity.Id, "SendPaperwork", "height=500,width=1250, left=70, top=100, scrollbars=yes","_blank");
                }else if(!result.isValidOwner){
                    component.find("utils").showError(result.errorMsg);
                } else if(result.isValidOwner && !result.isValid){
                    component.find("utils").showError(result.errorMsg);
                }
            },function(error){
                component.find("utils").showError(error);
            },component);
        }
    },
    saveController:function(component,event,helper){
        component.set("v.opportunityForm", JSON.parse(JSON.stringify(component.get("v.opportunity"))));
        component.find("utils").showProcessing();
        if(component.get("v.isContact")){
            helper.save(component, event, helper, null, function(){
                component.find("utils").hideProcessing();                
                component.find("utils").showSuccess("Opportunity created successfully");
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            });
        }else{
            component.find("utils").showProcessing();
            component.find("utils").execute("c.saveRecord", {"record": {"Id": component.get("v.journey").Primary_Lead__c, "Account__c": component.get("v.OrgRecord.Id"), "Number_of_Full_Time_Employees__c": component.get("v.accountRec.Number_of_Full_Time_Employees__c"), "Interested_in_Number_of_Desks__c": component.get("v.accountRec.Interested_in_Number_of_Desks__c")}}, function(response){
                component.find("utils").execute("c.convertLeadsToExisting", {"objLead":{"Id": component.get("v.journey").Primary_Lead__c, "Email": component.get("v.journey").Primary_Lead__r.Email}}, function(response){
                    if(response && response != "null"){
                        var convertedResult = {};
                        convertedResult = JSON.parse(response);
                        var opportunityData = {};
                        opportunityData["accountId"] = convertedResult.accountId;
                        opportunityData["contactId"] = convertedResult.contactId;
                        opportunityData["journeyId"] = component.get("v.journey.Id");
                        component.find("utils").execute("c.getJourneyOpportunityData", {"mapOpportunityData": opportunityData}, function(response){
                            component.set("v.journeyOpportunityData", JSON.parse(response));
                            helper.closeNewOpportunityModal(component, helper);
                            helper.getJourneyData(component, event, helper, function(){
                                helper.showOpportunities(component, event, helper,function(){
                                    helper.save(component, event, helper, convertedResult.ContactId, function(){
                                        helper.updateOpportunityWithOrgId(component);
                                        component.find("utils").hideProcessing();
                                    },function(error){ 
                                        component.find("utils").hideProcessing();
                                        component.find("utils").showError(error);
                                    });
                                },function(error){
                                    component.find("utils").hideProcessing();
                                    component.find("utils").showError(error);
                                });
                            },function(error){
                                component.find("utils").hideProcessing();
                                component.find("utils").showError(error);
                            });
                        },function(error){
                            component.find("utils").hideProcessing();
                            component.find("utils").showError(error);
                        }, component);
                    }
                },function(error){
                    var  message = error;
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(message.split(",")[1]);
                })
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            })
        }
    },
    findOrg:function(component,accountId,onsucess,onerror){
        component.find("utils").execute("c.getOrg", {"accountId": accountId}, function(response){
            if(response){
                component.set("v.orgAccountId", response);
                onsucess(response);
            }
        },function(error){
            onerror(error);
        });
    },
    updateOpportunityWithOrgId:function(component){
        if(component.get("v.parentAccountIdToPopulate")){
            var recordToUpdate = {};
            recordToUpdate.Id =  component.get("v.opportunityId");
            recordToUpdate.AccountId = component.get("v.parentAccountIdToPopulate");
            component.find("utils").execute("c.saveRecord", {"record":recordToUpdate},function(response){
                component.set("v.showOrgAccountModal",false);
                component.find("utils").hideProcessing();
                component.find("utils").execute("c.getQueryData", {"queryLable": "getJourneyRelatedOpportunities", "journeyId" : component.get("v.journeyId"), "contactId" : component.get("v.journey").Primary_Contact__c, "accountId" : null}, function(relatedOpportunitiesResponse){                   
                    component.set("v.opportunities", response);
                },function(error){
                    onerror(error);
                },component);
                component.find("utils").showSuccess("Opportunity created successfully");
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            });
        }
    },
    getReleatedOrgOfLead:function(component,onsuccess,onerror){
        component.find("utils").showProcessing();
        component.find("utils").execute("c.getReleatedOrg", {"leadId": component.get("v.journey").Primary_Lead__c}, function(response){
            onsuccess(response);
        },function(error){
            onerror(error);
        });
    },
    checkAndFindUltimateOrg:function(component,accountId,onsuccess,onerror){
        component.find("utils").execute("c.getQueryData", {"queryLable": "getAccountRecord", "journeyId" : null, "contactId" : null, "accountId" : accountId}, function(relatedOpportunitiesResponse){                   
            if(response){
                var entity = component.get("v.entity");
                if(response[0].Account_Type__c == "Sales"){
                    entity.orgRecordId = response[0].Parent_Org_Id__c;
                    component.set("v.entity", entity);
                    onsuccess(response[0].Parent_Org_Id__c);
                }else{
                    entity.orgRecordId = response[0].Id;
                    entity.orgRecordName = response[0].Name;
                    component.set("v.entity", entity);
                    onsuccess(response[0].Id);
                }
            }
        }, function(error){
            onerror(error);
        }, component);
    },
    getUnomyCompanySize:function(companySize){
        if(companySize.includes(",")){
            companySize = companySize.replace(/,/g, "");
        }
        var isUpperRange = companySize.includes("-");
        var isLowerRange = companySize.includes("+");
        
        if(isUpperRange){
            var arr = companySize.split("-");
            if(arr.length > 1){
                arr =  arr[0].split(" ");
                if(arr[0] != "")
                    return arr[0];
                else
                    return arr[1];
            }else{
                return arr[0].substring(0, arr[0].length - 1)
            }
        }else if(isLowerRange){
            if(companySize.slice(companySize.length-1,companySize.length) == "+")
                companySize = companySize.slice(0, -1);
            return companySize;            
        }
        return companySize;
    },
    getFullTimeEmployees : function(companySize){
        if(companySize.includes("-")){
            return companySize.split("-")[0];
        } else if(companySize.includes("+")){
            return companySize.split("+")[0];
        }
    }
    
})