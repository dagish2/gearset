({
    getRecordDetails: function(component, helper, recordId, onSuccess, onError){
        component.find("utils").execute("c.getCreateOpportunityData", {"recordId":recordId}, function(response){            
            var result = JSON.parse(response)
            component.set("v.record", result);
            onSuccess(result);
        },function(error){
            onError(error);
        }, component);  
    },
    setDataFields : function(component, helper, record){        
        var dataFields = [];
        if(record.relatedObjectName){
            switch(record.relatedObjectName.toLowerCase()){
                case "account":
                    if(record.relatedRecord){
                        var account = record.relatedRecord;
                        dataFields.push({"label": "Account Name", "value": account.Name, "url": account.Id});
                        dataFields.push({"label": "Main Contact", "value": account.Primary_Member__r ? account.Primary_Member__r.Name : "", "url": account.Primary_Member__c});
                        dataFields.push({"label": "Main Contact Email", "value": account.Primary_Member__r ? account.Primary_Member__r.Email : ""});
                        dataFields.push({"label": "Number of Full Time Employees", "value": account.Number_of_Full_Time_Employees__c});
                        dataFields.push({"label": "Account Owner", "value": account.Owner.Name, "url": account.OwnerId});
                        break;
                    }
                case "contact":
                    if(record.relatedRecord){
                        var contact = record.relatedRecord;
                        dataFields.push({"label": "Contact Name", "value": contact.Name, "url": contact.Id});
                        dataFields.push({"label": "Email", "value": contact.Email});
                        dataFields.push({"label": "Phone", "value": contact.Phone});
                        dataFields.push({"label": "Account", "value": contact.Account ? contact.Account.Name : "", "url": contact.AccountId});
                        dataFields.push({"label": "Owner", "value": contact.Owner.Name, "url": contact.OwnerId});
                        break;
                    }    
                case "lead":
                    if(record.relatedRecord){
                        var lead = record.relatedRecord;
                        dataFields.push({"label": "Lead Name", "value": lead.Name, "url": lead.Id});
                        dataFields.push({"label": "Email", "value": lead.Email });
                        dataFields.push({"label": "Phone", "value": lead.Phone});
                        dataFields.push({"label": "Company", "value": lead.Company});
                        dataFields.push({"label": "Owner", "value": lead.Owner.Name, "url": lead.OwnerId});
                        break;
                    }
                case "journey":
                    if(record.relatedRecord){
                        var journey = record.relatedRecord.Primary_Contact__r != null ? record.relatedRecord.Primary_Contact__r : record.relatedRecord.Primary_Lead__r;
                        dataFields.push({"label": "Journey Name", "value": record.relatedRecord.Name, "url": record.relatedRecord.Id});
                        dataFields.push({"label": "Email", "value": journey.Email});
                        dataFields.push({"label": "Phone", "value": journey.Phone});
                        dataFields.push({"label": record.relatedRecord.Primary_Contact__r != null ? "Account" : "Company", "value": record.relatedRecord.Primary_Contact__r != null ? journey.Account ? journey.Account.Name : "" : journey.Company , "url": record.relatedRecord.Primary_Contact__r != null ? journey.AccountId : ""});
                        dataFields.push({"label": "Owner", "value": record.relatedRecord.Owner.Name, "url": record.relatedRecord.OwnerId});
                        break;
                    }
            }
        }
        component.set("v.dataFields", dataFields);
        
    },
    setRecordData: function(component, helper, record, onSuccess, onError) {
        if(record){
            switch(record.relatedObjectName.toLowerCase()){
                case "lead": 
                    if(record.relatedRecord){
                        var mapDisables = component.get("v.disabledOnLoad");
                        if(helper.checkNullUndefineOrBlank(record.ultimateParentAccountRecord)){
                            component.set("v.orgAccountId", record.ultimateParentAccountRecord.Id);
                        }
                        if(record.relatedRecord.Account__r && record.relatedRecord.Account__r.Account_Type__c == 'Sales'){
                            component.set("v.salesAccountId", record.relatedRecord.Account__c);
                            component.set("v.disabledOnLoad.salesAccountId", true);
                            component.set("v.disabledOnLoad.orgAccountId", true);
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Email))
                            component.set("v.leadPrimaryMember", record.relatedRecord.Email);
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.LeadSource)){
                            component.set("v.opportunityRecord.LeadSource", record.relatedRecord.LeadSource);
                            mapDisables['LeadSource'] = true;                            
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Building_Interested_In__c))
                            component.set("v.opportunityRecord.Building__c", record.relatedRecord.Building_Interested_In__c);
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Lead_Source_Detail__c)){
                            component.set("v.opportunityRecord.Lead_Source_Detail__c", record.relatedRecord.Lead_Source_Detail__c);
                            mapDisables['Lead_Source_Detail__c'] = true;
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Description)){
                            component.set("v.opportunityRecord.Description", record.relatedRecord.Description);
                        } 
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Interested_in_Number_of_Desks__c)){
                            component.set("v.opportunityRecord.Interested_in_Number_of_Desks__c", record.relatedRecord.Interested_in_Number_of_Desks__c);
                        }  
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Markets_Interested__c)){
                            component.set("v.opportunityRecord.Markets_Interested__c",record.relatedRecord.Markets_Interested__c);
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Locations_Interested__c)){
                            component.set("v.opportunityRecord.Locations_Interested__c",record.relatedRecord.Locations_Interested__c);
                        }
                        component.set("v.disabledOnLoad", mapDisables);
                        onSuccess(record);
                        component.find("utils").hideProcessing();
                    }
                    break;
                case "journey": 
                    if(record.relatedRecord){									
                        var mapDisables = component.get("v.disabledOnLoad");
                        component.set("v.opportunityRecord.Journey__c", component.get("v.recordId"));
                        if(helper.checkNullUndefineOrBlank(record.ultimateParentAccountRecord)){
                            component.set("v.orgAccountId", record.ultimateParentAccountRecord.Id);
                        } 
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Interested_in_Number_of_Desks__c)){
                            component.set("v.opportunityRecord.Interested_in_Number_of_Desks__c", record.relatedRecord.Interested_in_Number_of_Desks__c);
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Description__c)){
                            component.set("v.opportunityRecord.Description", record.relatedRecord.Description__c);
                        } 
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Building_Interested_In__c)){
                            component.set("v.opportunityRecord.Building__c", record.relatedRecord.Building_Interested_In__c);
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Lead_Source__c)){
                            component.set("v.opportunityRecord.LeadSource", record.relatedRecord.Lead_Source__c);
                            mapDisables['LeadSource'] = true;
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Lead_Source_Detail__c)){
                            component.set("v.opportunityRecord.Lead_Source_Detail__c", record.relatedRecord.Lead_Source_Detail__c);
                            mapDisables['Lead_Source_Detail__c'] = true;
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Markets_Interested__c)){
                            component.set("v.opportunityRecord.Markets_Interested__c", record.relatedRecord.Markets_Interested__c);
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Locations_Interested__c)){
                            component.set("v.opportunityRecord.Locations_Interested__c", record.relatedRecord.Locations_Interested__c);
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Lead__c) && helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Lead__r)){
                            if(helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Lead__r.Email)){
                                component.set("v.leadPrimaryMember", record.relatedRecord.Primary_Lead__r.Email);
                            }
                            if(mapDisables['LeadSource']!=true && helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Lead__r.LeadSource)){
                                component.set("v.opportunityRecord.LeadSource", record.relatedRecord.Primary_Lead__r.LeadSource);
                                mapDisables['LeadSource'] = true;
                            } 
                            if(mapDisables['Lead_Source_Detail__c'] != true && helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Lead__r.Lead_Source_Detail__c)){
                                component.set("v.opportunityRecord.Lead_Source_Detail__c", record.relatedRecord.Primary_Lead__r.Lead_Source_Detail__c); 
                                mapDisables['Lead_Source_Detail__c'] = true;
                            }
                            if(record.relatedRecord.Primary_Lead__r.Account__r && record.relatedRecord.Primary_Lead__r.Account__r.Account_Type__c == 'Sales'){
                                component.set("v.salesAccountId", record.relatedRecord.Primary_Lead__r.Account__c);
                                component.set("v.disabledOnLoad.salesAccountId", true);
                                component.set("v.disabledOnLoad.orgAccountId", true);
                            }
                        } else if(helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Contact__c) && helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Contact__r)){
                            console.log(record.relatedRecord.Primary_Contact__r);
                            var mapDisables = component.get("v.disabledOnLoad");
                            component.set("v.opportunityRoleRecord.Contact__c", record.relatedRecord.Primary_Contact__c);
                            if(helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Contact__r.LeadSource) ){
                                component.set("v.opportunityRecord.LeadSource", record.relatedRecord.Primary_Contact__r.LeadSource); 
                                mapDisables['LeadSource'] = true;  
                            }     
                            if(record.relatedRecord.Primary_Contact__r.Account.Account_Type__c == 'Sales'){
                                component.set("v.salesAccountId", record.relatedRecord.Primary_Contact__r.AccountId);
                                mapDisables.salesAccountId = true;
                                mapDisables.orgAccountId = true;
                            }
                            if(helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Contact__r.Lead_Source_Detail__c)){
                                component.set("v.opportunityRecord.Lead_Source_Detail__c", record.relatedRecord.Primary_Contact__r.Lead_Source_Detail__c); 
                                mapDisables['Lead_Source_Detail__c'] = true;
                            }  
                        } 
                        component.set("v.disabledOnLoad",mapDisables);
                        onSuccess(record);
                        component.find("utils").hideProcessing();
                    }
                    break; 
                case "contact": 
                    if(record.relatedRecord){
                        var mapDisables = component.get("v.disabledOnLoad");
                        if(helper.checkNullUndefineOrBlank(record.ultimateParentAccountRecord)){
                            component.set("v.orgAccountId",record.ultimateParentAccountRecord.Id);
                        }
                        if(record.relatedRecord.Account && record.relatedRecord.Account.Account_Type__c == 'Sales'){
                            component.set("v.salesAccountId", record.relatedRecord.AccountId);
                            component.set("v.disabledOnLoad.salesAccountId", true);
                            component.set("v.disabledOnLoad.orgAccountId", true);
                        }
                        
                        if(helper.checkNullUndefineOrBlank(component.get("v.recordId")))
                            component.set("v.opportunityRecord.Primary_Member__c", component.get("v.recordId"));      
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Id)){
                            component.set("v.opportunityRoleRecord.Contact__c", record.relatedRecord.Id);                      
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.LeadSource)){
                            component.set("v.opportunityRecord.LeadSource", record.relatedRecord.LeadSource);
                            mapDisables['LeadSource'] = true;                            
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Lead_Source_Detail__c)){
                            component.set("v.opportunityRecord.Lead_Source_Detail__c", record.relatedRecord.Lead_Source_Detail__c);
                            mapDisables['Lead_Source_Detail__c'] = true;
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Description)){
                            component.set("v.opportunityRecord.Description", record.relatedRecord.Description);
                        } 
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Interested_in_Number_of_Desks__c)){
                            component.set("v.opportunityRecord.Interested_in_Number_of_Desks__c", record.relatedRecord.Interested_in_Number_of_Desks__c);
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Location__c))
                            component.set("v.opportunityRecord.Building__c", record.relatedRecord.Location__c);
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Markets_Interested__c)){
                            component.set("v.opportunityRecord.Markets_Interested__c", record.relatedRecord.Markets_Interested__c);
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Location_Interested__c)){
                            component.set("v.opportunityRecord.Locations_Interested__c", record.relatedRecord.Location_Interested__c);
                        }
                        component.set("v.disabledOnLoad", mapDisables); 
                        onSuccess(record);
                    }
                    break;
                case "account": 
                    if(record.relatedRecord){
                        var mapDisables = component.get("v.disabledOnLoad");
                        if(helper.checkNullUndefineOrBlank(record.ultimateParentAccountRecord)){
                            component.set("v.orgAccountId", record.ultimateParentAccountRecord.Id);
                        } 
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Member__c)){
                            component.set("v.opportunityRoleRecord.Contact__c", record.relatedRecord.Primary_Member__c);
                        } else if(helper.checkNullUndefineOrBlank(record.ultimateParentAccountRecord.Primary_Member__c)){
                            component.set("v.opportunityRoleRecord.Contact__c", record.ultimateParentAccountRecord.Primary_Member__c);
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Account_Type__c == 'Sales')){
                            component.set("v.salesAccountId", record.relatedRecord.Id);
                            component.set("v.disabledOnLoad.salesAccountId", true);
                            component.set("v.disabledOnLoad.orgAccountId", true);
                        }
                        
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Lead_Source__c)){
                            component.set("v.opportunityRecord.LeadSource", record.relatedRecord.Lead_Source__c);
                            mapDisables['LeadSource'] = true;
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Description)){
                            component.set("v.opportunityRecord.Description", record.relatedRecord.Description);
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Interested_in_Number_of_Desks__c)){
                            component.set("v.opportunityRecord.Interested_in_Number_of_Desks__c", record.relatedRecord.Interested_in_Number_of_Desks__c);
                        }
                        component.set("v.disabledOnLoad", mapDisables); 
                        onSuccess(record);
                    }
                    break;
                default: 
                    component.find("utils").showError('Create Opportunity not allowed from '+ record.relatedObjectName.toLowerCase());
            }
            if(!component.get("v.isProfileAllowed")){
                component.set("v.opportunityRecord.Interested_in_Number_of_Desks__c", 0);
            }
            if(component.get("v.orgAccountId")){
                component.set("v.saleAccCriteria", "Parent_Org__c = '" + component.get("v.orgAccountId").substr(0, 15) + "' AND Account_Type__c = 'Sales'");
            }
        }
    },
    checkNullUndefineOrBlank: function(entity) {
        if(entity){
            if(entity != undefined && entity != null && entity != '')
                return true;
            else
                return false;
        }else
            return false;
    },
    callConvertLeadToContactFromLead: function(component, helper, mapEntities, onSuccess, onError){
        var record = component.get('v.record');
        mapEntities["orgAccountId"] = (helper.checkNullUndefineOrBlank(component.get('v.salesAccountId')) ? component.get('v.salesAccountId') : component.get('v.orgAccountId'));
        component.find("utils").execute("c.convertEnterpriseLead",{"mapEntity": mapEntities}, function(response){
            helper.convertLeadToContact(component, helper, JSON.parse(response), function(response, oppRecResponse){
                component.set("v.opportunityRoleRecord.Contact__c",response.contactId);
                oppRecResponse["Primary_Member__c"] = response.contactId;
                helper.createOpportunity(component, helper, oppRecResponse, true, function(oppResponse){
                    if(helper.checkNullUndefineOrBlank(oppResponse)){
                        var oppRoleRec = component.get("v.opportunityRoleRecord");
                        oppRoleRec["Opportunity__c"] = oppResponse.Id;
                        oppRoleRec["Is_Primary_Member__c"] = (oppResponse.Primary_Member__c == component.get("v.opportunityRoleRecord.Contact__c"));
                        helper.createOpportunityContactRole(component, helper, oppRoleRec, function(oppRoleResponse){
                            onSuccess(oppResponse);
                        },function(error){
                            onError(error);
                        })
                    }
                },function(error){
                    component.find("utils").hideProcessing();
                    component.find("utils").showError(error);
                })
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            })
        },function(error){
            onError(error);               
        }, component);
    },
    convertLeadToContact: function(component, helper, mapEntity, onSuccess, onError){
        var oppRec = component.get("v.opportunityRecord");
        mapEntity['conRecType'] = component.get('v.orgRecordTypeName');
        mapEntity["accountId"] = (helper.checkNullUndefineOrBlank(component.get('v.salesAccountId')) ? component.get('v.salesAccountId') : component.get('v.orgAccountId'));
        var record = component.get('v.record');
        if(mapEntity.hasOwnProperty('accountId') && mapEntity.hasOwnProperty('contactId')){
            if(helper.checkNullUndefineOrBlank(mapEntity.accountId)){
                oppRec["AccountId"] = mapEntity.accountId;
            }
            oppRec["Decision_Maker__c"] = null;
            if(helper.checkNullUndefineOrBlank(component.get("v.opportunityRoleRecord.Contact__c"))){
                oppRec["Primary_Member__c"] = component.get("v.opportunityRoleRecord.Contact__c");
            } else if(record.relatedObjectName.toLowerCase() != 'contact')
                oppRec["Primary_Member__c"] = mapEntity.contactId;
            oppRec["Do_Not_Create_Opportunity_Role__c"] = true;
            oppRec["Owner_Auto_Assign__c"] = true;
            onSuccess(mapEntity,oppRec); 
        }
    },
    createOpportunity: function(component, helper, opportunityRecord, isLead, onSuccess, onError){
        var oppQualifyingSetting = component.get("v.OpportunityQualifySetting");
        if(helper.checkNullUndefineOrBlank(oppQualifyingSetting)){
            var isOppQualified = true;
            oppQualifyingSetting["Fields"].forEach(function(field){
                if(opportunityRecord[field] == null || opportunityRecord[field] == ""){
                    isOppQualified = false;
                }                
            });
            if(isOppQualified){
                opportunityRecord["StageName"] = oppQualifyingSetting["StageName"];
            }else {
                opportunityRecord["StageName"] = "Qualifying";                
            } 
        }else
            opportunityRecord["StageName"] = "Qualifying";
        for(field in opportunityRecord){
            field != "Type__c" || field != "Broker_Involved__c" ? component.set("v.opportunityRecord"+field, opportunityRecord[field]) : '' ;
        }
        component.find("utils").execute("c.createEnterpriseOpportunity", {"oppRec": opportunityRecord}, function(response){ 
            if(helper.checkNullUndefineOrBlank(response))
                onSuccess(response); 
            else
                onError("Something went wrong, please contact your system administrator.");
        },function(error){
            onError(error);               
        }, component);
        
    },
    createOpportunityContactRole: function(component, helper, opportunityContRole, onSuccess, onError){        
        component.set("v.opportunityRoleRecord", opportunityContRole);
        component.find("utils").execute("c.saveRecord", {"record": opportunityContRole}, function(response){
            console.log(response);
            if(helper.checkNullUndefineOrBlank(response))
                onSuccess(response); 
            else
                onError("Something went wrong, please contact your system administrator.");
        },function(error){
            component.find("utils").hideProcessing();            
            component.find("utils").showError(error);
        });
    },
    save: function(component, addProducts){
        component.find("utils").showProcessing();
        var helper = this;
        var mapEntities = {};
        var record = component.get('v.record');
        var oppRec = component.get("v.opportunityRecord");
        switch(record.relatedObjectName.toLowerCase()){
            case "lead": 
                if(record.relatedRecord){
                    if(helper.checkNullUndefineOrBlank(record.relatedRecord.Id)){
                        mapEntities["leadId"] = record.relatedRecord.Id; 
                        if(helper.checkNullUndefineOrBlank(component.get('v.orgAccountId'))){
                            mapEntities["orgAccountId"] = component.get('v.orgAccountId'); 
                        }
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Email)){
                            mapEntities["Email"] = record.relatedRecord.Email; 
                        }
                        helper.callConvertLeadToContactFromLead(component, helper, mapEntities, function(oppResponse){
                            component.find("utils").hideProcessing();
                            component.find("utils").showSuccess('Opportunity created successfully.');
                            helper.openSFRecord(component, helper, oppResponse.Id, addProducts);
                        },function(error){
                            component.find("utils").hideProcessing();
                            component.find("utils").showError("Something went wrong, please contact your system administrator.");
                        });
                    }
                }
                break;
            case "journey": 
                if(record.relatedObjectName == 'journey'){
                    if(record.relatedRecord.Primary_Contact__c && helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Contact__c)){
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Contact__c)){
                            mapEntities["contactId"] = record.relatedRecord.Primary_Contact__c; 
                        }
                        helper.convertLeadToContact(component, helper, mapEntities, function(response, oppRecResponse){                            
                            helper.createOpportunity(component, helper, oppRecResponse, true, function(oppResponse){
                                if(helper.checkNullUndefineOrBlank(oppResponse)){
                                    var oppRoleRec = component.get("v.opportunityRoleRecord");
                                    oppRoleRec["Opportunity__c"] = oppResponse.Id;
                                    oppRoleRec["Is_Primary_Member__c"] = (oppResponse.Primary_Member__c == component.get("v.opportunityRoleRecord.Contact__c"));
                                    helper.createOpportunityContactRole(component, helper, oppRoleRec, function(oppRoleResponse){
                                        component.find("utils").hideProcessing();
                                        component.find("utils").showSuccess('Opportunity created successfully.');
                                        helper.openSFRecord(component, helper, oppResponse.Id, addProducts);
                                    }, function(error){
                                        component.find("utils").hideProcessing();
                                        component.find("utils").showError(error);
                                    })
                                } else {
                                    component.find("utils").hideProcessing();
                                    onError("Something went wrong, please contact your system administrator.");
                                }
                            },function(error){
                                component.find("utils").hideProcessing();
                                component.find("utils").showError(error);
                            })
                        },function(error){
                            component.find("utils").hideProcessing();
                            component.find("utils").showError(error);
                        })
                    } else if(record.relatedRecord.Primary_Lead__c && helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Lead__c)){
                        if(helper.checkNullUndefineOrBlank(record.relatedRecord.Id)){
                            mapEntities["leadId"] = record.relatedRecord.Primary_Lead__c; 
                            
                            if(helper.checkNullUndefineOrBlank(component.get('v.orgAccountId'))){
                                mapEntities["orgAccountId"] = component.get('v.orgAccountId'); 
                            }
                            if(record.relatedRecord.Primary_Lead__r.hasOwnProperty('Email') && helper.checkNullUndefineOrBlank(record.relatedRecord.Primary_Lead__r.Email)){
                                mapEntities["Email"] = record.relatedRecord.Primary_Lead__r.Email; 
                            }
                            helper.callConvertLeadToContactFromLead(component, helper, mapEntities, function(oppResponse){                                
                                component.find("utils").hideProcessing();
                                component.find("utils").showSuccess('Opportunity created successfully.');
                                helper.openSFRecord(component, helper, oppResponse.Id, addProducts);
                            },function(error){
                                component.find("utils").hideProcessing();
                                component.find("utils").showError("Something went wrong, please contact your system administrator.");
                            });
                        }
                    }
                }
                break; 
            case "contact": 
                if(record.relatedRecord){
                    if(helper.checkNullUndefineOrBlank(record.relatedRecord.Id)){
                        mapEntities["contactId"] = record.relatedRecord.Id; 
                    }
                    helper.convertLeadToContact(component, helper, mapEntities, function(response, oppRecResponse){
                        if(response && helper.checkNullUndefineOrBlank(response)){
                            helper.createOpportunity(component, helper, oppRecResponse, true, function(oppResponse){
                                if(helper.checkNullUndefineOrBlank(oppResponse)){
                                    var oppRoleRec = component.get("v.opportunityRoleRecord");
                                    oppRoleRec["Opportunity__c"] = oppResponse.Id;
                                    oppRoleRec["Is_Primary_Member__c"] = (oppResponse.Primary_Member__c == component.get("v.opportunityRoleRecord.Contact__c"));
                                    helper.createOpportunityContactRole(component, helper, oppRoleRec, function(oppRoleResponse){
                                        component.find("utils").hideProcessing();
                                        component.find("utils").showSuccess('Opportunity created successfully.');
                                        helper.openSFRecord(component, helper, oppResponse.Id, addProducts);
                                    },function(error){
                                        component.find("utils").hideProcessing();
                                        component.find("utils").showError(error);
                                    })
                                } else {
                                    component.find("utils").hideProcessing();
                                    onError("Something went wrong, please contact your system administrator.");
                                }
                            },function(error){
                                component.find("utils").showError(error);
                            }) 
                        }
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    })
                }
                break;
            case "account": 
                if(record.relatedRecord){
                    if(helper.checkNullUndefineOrBlank(component.get('v.opportunityRoleRecord.Contact__c'))){
                        mapEntities["contactId"] = component.get('v.opportunityRoleRecord.Contact__c'); 
                    }                    
                    helper.convertLeadToContact(component, helper, mapEntities, function(response, oppRecResponse){
                        if(response && helper.checkNullUndefineOrBlank(response)){
                            helper.createOpportunity(component, helper, oppRecResponse, true, function(oppResponse){
                                if(helper.checkNullUndefineOrBlank(oppResponse)){
                                    var oppRoleRec = component.get("v.opportunityRoleRecord");
                                    oppRoleRec["Opportunity__c"] = oppResponse.Id;
                                    oppRoleRec["Is_Primary_Member__c"] = (oppResponse.Primary_Member__c == component.get("v.opportunityRoleRecord.Contact__c"));
                                    helper.createOpportunityContactRole(component, helper, oppRoleRec, function(oppRoleResponse){
                                        component.find("utils").hideProcessing();
                                        component.find("utils").showSuccess('Opportunity created successfully.');
                                        helper.openSFRecord(component, helper, oppResponse.Id, addProducts);
                                    },function(error){
                                        component.find("utils").hideProcessing();
                                        component.find("utils").showError(error);
                                    })
                                } else {
                                    component.find("utils").hideProcessing();
                                    onError("Something went wrong, please contact your system administrator.");
                                }
                            },function(error){
                                component.find("utils").showError(error);
                            }) 
                        }
                    },function(error){
                        component.find("utils").hideProcessing();
                        component.find("utils").showError(error);
                    })
                }
                break;
        }
    },
    openSFRecord: function(component, helper, recordId, addProducts){
        if(addProducts){
            component.find("utils").closeTab();
            component.find("utils").redirectToUrl("/apex/ManageProducts?id=" + recordId + "&isFromCreateOpp=true");
        } else{
            component.find("utils").redirectToUrl("/"+recordId, "", false);
        }
    },
    resetDefaultRecord: function(component, helper, onSuccess, onError){
        var objOpportunity_Role = {'sobjectType':'Opportunity_Role__c', 'Opportunity__c':null, 'Role__c':'Primary Member', 'Is_Primary_Member__c':null, 'Contact__c':null};
        var objOpportunity = {'sobjectType': 'Opportunity', ' CloseDate': null, 'LeadSource': null, 'Lead_Source_Detail__c': null, 'Description': null, 'Building__c': null, 'Primary_Member__c': null, 'Geography__c': null, 'Referrer__c': null, 'Type__c': null, 'Requirement_Quantity__c': null, 'Desired_Budget__c': null, 'Actual_Start_Date__c': null, 'Commitment_Term_in_months__c': null};
        component.set('v.opportunityRoleRecord', objOpportunity_Role);
        component.set('v.opportunityRecord', objOpportunity);
        onSuccess();
    },
    resetPrimaryContact : function(component){
        component.set("v.newPrimaryContact", {'sobjectType': 'Contact', 'Name': null, 'Email': null, 'FirstName': null, 'LastName': null});
    },
    closeCreateNewOrganization: function(component,close) { 
        if(close){
            component.find("CreateNewOrganization").closeModal();
            component.find("utils").showConfirm("Are you sure you want close this page ?",function(){
                component.set("v.selectedOrgId", null);
                component.set("v.requestedOrg", {"Name":null,"Number_of_Full_Time_Employees__c":null,"Website":null,"Description":null});
                component.set("v.requestNewOrgSuccess", false); 
                component.set("v.hasSearched", false);
                component.set("v.defaultOrgRecords", []);
            }, function(){
                component.find("CreateNewOrganization").showModal();
            }, null, "close-confirm");   
        }else{
            component.set("v.selectedOrgId", null);
         	component.set("v.requestedOrg", {"Number_of_Full_Time_Employees__c" : null, "Website" : null, "Description" : null});
            component.set("v.requestNewOrgSuccess", false);
            component.set("v.defaultOrgRecords", []);
            component.find("CreateNewOrganization").closeModal();
            if(component.get("v.recordId")){
                helper.openSFRecord(component, helper, component.get("v.recordId"), false);
            }
        }  
    }, 
    updateMainContact: function(component, helper, salesAccountId, onSuccess, onError) {        
        var orgRelatedSalesAccounts = component.get("v.orgRelatedSalesAccounts");
        var salesAccount = orgRelatedSalesAccounts[orgRelatedSalesAccounts.findIndex(x => x.Id==salesAccountId)];
        if(salesAccount.hasOwnProperty("Primary_Member__c") && salesAccount.Primary_Member__c != undefined && salesAccount.Primary_Member__c != null){
            component.set("v.opportunityRoleRecord.Contact__c", salesAccount.Primary_Member__c);
        } 
        onSuccess();
    },
    removeHideClass : function(component, componentName){
        var remove = document.getElementById(componentName);        
        $A.util.removeClass(remove, "slds-hide");
    },
    addHideClass : function(component, componentName){
        var add = document.getElementById(componentName);        
        $A.util.addClass(add, "slds-hide");
    },
    previous : function(component, helper){
         component.set("v.requestedOrg", {"Number_of_Full_Time_Employees__c" : null, "Website" : null, "Description" : null});
         helper.removeHideClass(component, "searchOrganization");
         helper.addHideClass(component, "requestNewOrganization");
    },
     changeHeaderAndInstructions : function( component, header){
        var mapInstructions = component.get("v.mapInstructions");
        component.set("v.header", header);
        if(mapInstructions.get(header.charAt(0).toLowerCase() + header.trim().replace(/ /g,"").substring(1)) != undefined && mapInstructions.get(header.charAt(0).toLowerCase() + header.trim().replace(/ /g,"").substring(1)).length > 0){
            component.set("v.instructions", mapInstructions.get(header.charAt(0).toLowerCase() + header.trim().replace(/ /g,"").substring(1)));
            this.removeHideClass(component, "accountinstructions");
        }else{
            this.addHideClass(component, "accountinstructions");
        }
    },
    setrequestNewOrg : function(component, helper) {
        component.set("v.requestedOrg", new Map());
        component.set("v.requestNewOrgSuccess", false);
        component.set("v.requestedOrg.Name", component.get("v.accountName"));
    }
})