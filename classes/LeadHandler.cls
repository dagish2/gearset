public with sharing class LeadHandler {
    public static List<Journey__c> lstJourney = new List<Journey__c>();
    //used by Inbound Lead API
    public static void upsert_inbound_lead(WWTypes.InboundLead pInboundLead) {
        try{
            LeadServices ls = new LeadServices(pInboundLead);
            
            TaskServices ts = new TaskServices(ls);

            
            //create task
            Task t = ts.create_task_from_web(pInboundLead);
            
            //insert task
            insert t;
        }catch(Exception ex){
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadHandler','upsert_inbound_lead',JSON.serializePretty(pInboundLead), ex)
            );
            throw new applicationException(ex.getMessage());
        }
    }

    //used by Tour API
    public static Id book_a_tour(WWTypes.InboundLead pInboundLead) {
        Id result = null;
        try{
            //business scenario 5: pre-existing account or contact
            if (pInboundLead.account_uuid != null || pInboundLead.contact_uuid != null) {
                //set account services
                AccountServices aServices = new AccountServices(pInboundLead);
                Debug.Log('Tour # of Queries 1.0 : ' + Limits.getQueries());
                //locate the latest open opportunity id
                //Id latest_open_opportunity_id = null;
                
                if(pInboundLead.sf_journey_uuid != null && pInboundLead.sf_journey_uuid != '')
                    lstJourney = [Select Id, Count_of_Desk__c From Journey__c Where UUID__c =: pInboundLead.sf_journey_uuid];
                
                Debug.log('Create Opportunity');
                Id latest_open_opportunity_id = LeadHandler.get_or_create_opportunity_new(aServices.a.Id, aServices.c.Id, 'Selling', pInboundLead);
                Debug.Log('Tour # of Queries 1.1 : ' + Limits.getQueries());
                Account acc = [SELECT Primary_member__c, RecordTypeId, OwnerId FROM Account WHERE id = :aServices.a.Id LIMIT 1];
                //create tour (primaryMember.id, pInboundLead)
               Tour_Outcome__c tourInfo = TourServices.insert_tour_from_external_app(acc, latest_open_opportunity_id, pInboundLead);
                //Id tour_id = TourServices.insert_tour_from_external_app(acc, latest_open_opportunity_id, pInboundLead).id;
                Debug.log('tourInfo==>'+tourInfo);
                Id tour_id =  tourInfo.Id;                
                Debug.log('latest_open_opportunity_id==>'+latest_open_opportunity_id);
                Debug.Log('Tour # of Queries==> ' + Limits.getQueries());
                if(latest_open_opportunity_id != null){
                    Opportunity opp = [Select Id,Name,Tour_Booked_By__c,(Select Id,Name From Tour_Outcome__r order by CreatedDate DESC LIMIT 10) From Opportunity Where Id =:latest_open_opportunity_id];                  
                    Debug.log('opp==>'+opp);
                    if(String.isBlank(opp.Tour_Booked_By__c) && opp.Tour_Outcome__r != null && opp.Tour_Outcome__r.size()==1){
                        Debug.log('opp111==>'+opp);
                        opp.Tour_Booked_By__c = tourInfo.booked_by_contact_id__c;                       
                        Database.update(opp);
                    }   
                }  
                Debug.Log('Tour # of Queries 1.2 : ' + Limits.getQueries());
                //create task services
                TaskServices ts = new TaskServices(null, aServices.c, false);
                
                //create task and assign to regular member
                //LeadHandler.insert_task(ts, pInboundLead, 'Book a Tour', UserInfo.getUserId(), tour_id);
                TaskServiceQueueable tsQueueable = new TaskServiceQueueable(ts, pInboundLead, 'Book a Tour', UserInfo.getUserId(), tour_id);
                ID jobID = System.enqueueJob(tsQueueable);
                Debug.Log('Queueable jobID : ' + jobID);
                Debug.Log('Tour # of Queries 1.3 : ' + Limits.getQueries());
                result = tour_id;
            }
        }catch(Exception ex){
            Debug.log('Exception==>'+ex);
             Debug.log('getStackTraceString==>'+ex.getStackTraceString());
            Debug.log('getStackTraceString==>'+ex.getLineNumber());
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadHandler','book_a_tour', JSON.serializePretty(pInboundLead), ex)
            );
            throw new applicationException(ex.getMessage());
        }
        return result;
    }

    public static Settings.FieldMappings Contact2Activity() {
        Settings.FieldMappings contactToActivityMappings = new Settings.FieldMappings();
        contactToActivityMappings.version = 1;
        contactToActivityMappings.mappings = new Map<String, Settings.MappedField>();
        contactToActivityMappings.mappings.put('Phone__c', new Settings.MappedField('Phone'));
        contactToActivityMappings.mappings.put('Locale__c', new Settings.MappedField('Locale__c'));
        contactToActivityMappings.mappings.put('Email__c', new Settings.MappedField('Email'));
        contactToActivityMappings.mappings.put('Market__c', new Settings.MappedField('Market__c'));
        contactToActivityMappings.mappings.put('Product_Interests__c', new Settings.MappedField('Product_Interests__c'));
        contactToActivityMappings.mappings.put('Country_Code__c', new Settings.MappedField('Country_Code__c'));
        contactToActivityMappings.mappings.put('Quick_Quote_Location__c', new Settings.MappedField('Quick_Quote_Location__c'));
        contactToActivityMappings.mappings.put('Lead_Source__c', new Settings.MappedField('LeadSource'));
        contactToActivityMappings.mappings.put('Lead_Source_Detail__c', new Settings.MappedField('Lead_Source_Detail__c'));
        contactToActivityMappings.mappings.put('utm_campaign__c', new Settings.MappedField('utm_campaign__c'));
        contactToActivityMappings.mappings.put('utm_campaign_id__c', new Settings.MappedField('utm_campaign_id__c'));
        contactToActivityMappings.mappings.put('utm_content__c', new Settings.MappedField('utm_content__c'));
        contactToActivityMappings.mappings.put('utm_medium__c', new Settings.MappedField('utm_medium__c'));
        contactToActivityMappings.mappings.put('utm_source__c', new Settings.MappedField('utm_source__c'));
        contactToActivityMappings.mappings.put('utm_term__c', new Settings.MappedField('utm_term__c'));
        return contactToActivityMappings;
    }

    private static void insert_task(TaskServices ts, WWTypes.InboundLead pInboundLead, String subject, Id ownerId, Id tourId) {
        //create generic task
        try{
            Task t = ts.create_task_from_web(pInboundLead);
            
            List<Contact> lstContcat = new List<Contact>();
            
            Settings.FieldMappings mapContactToActivity;
            set<String> setContactFields = new set<String>();
            list<String> lstContactFields = new list<String>();
            mapContactToActivity = Settings.getFieldMappings('ContactToActivity');
            if(mapContactToActivity == null)
                mapContactToActivity = Contact2Activity();
            for(Settings.MappedField field : mapContactToActivity.mappings.values()){
                setContactFields.add(field.fieldname.toLowerCase());
            }
            lstContactFields.addAll(setContactFields);
            String str_contact_uuid = pInboundLead.contact_uuid;
            if(pInboundLead.contact_uuid != '' && pInboundLead.contact_uuid != null)
                lstContcat = Database.Query('Select ' + String.join(lstContactFields, ',') + ' From Contact Where UUID__c =: str_contact_uuid');
            Debug.log('Test : lstContcat ::: ' + lstContcat);
            //custom bindings
            t.Notes__c           = 'Created by Tour API';    
            t.Subject            = subject;
            t.Description        = pInboundLead.tour_notes;        
            t.WhatId             = tourId;
            
            if(lstContcat != null && lstContcat.size()>0){ 
                for(String field : mapContactToActivity.mappings.keySet()){
                    Settings.MappedField mappedField = mapContactToActivity.mappings.get(field);
                    if(mappedField.isvalue == true)
                        t.put(field, mappedField.value);
                    else
                        t.put(field, lstContcat[0].get(mappedField.fieldname));
                }
            }
            
            //set task owner                               
            if (ownerId != null) t.OwnerId = UserInfo.getUserId(); // Review this    
            
            //dml
            insert t;
        }catch(Exception ex){
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadHandler','insert_task',JSON.serializePretty(pInboundLead), ex)
            );
            throw new applicationException(ex.getMessage());
        }
    }

    private static Id get_or_create_opportunity_new(Id pAccountId, Id pContactId, String pStageName, WWTypes.InboundLead pInboundLead) {
        try{
            Id buildingInterestedId;
            String buildingName = BuildingHandler.getMultipicklistValuesFromUUID(
                new String[] {
                    pInboundLead.tour_building_uuid
                        }
            );
            Opportunity o;
            if(pInboundLead.opportunity_id == null || pInboundLead.opportunity_id.length() == 0){
                o = OpportunityServices.get_latest_open_opportunity_by_primary_member(pAccountId, pContactId, buildingName);
                Debug.log('get_latest_open_opportunity_by_primary_member ==>> '+ o);
            }
            else {
                o = OpportunityServices.getOpportunitybySFId(pInboundLead.opportunity_id);
                Debug.log('getOpportunitybySFId ==>> '+ o);
            }
            if(pInboundLead.tour_building_uuid != null)
                buildingInterestedId = BuildingHandler.getBuildingIdByUUID(pInboundLead.tour_building_uuid);
            Debug.log('Opportunity buildingInterestedId ==>> '+ buildingInterestedId);
            if (o == null) {
                o = OpportunityServices.create_opportunity(pAccountId, buildingName, pStageName);
                List<Contact> lstContcat = new List<Contact>();
                lstContcat = [Select Id,LeadSource,Lead_Source_Detail__c,utm_campaign__c,utm_campaign_id__c,utm_content__c,utm_medium__c,utm_source__c,utm_term__c,Locale__c,Country_Code__c,Location_Interested__c From Contact Where Id =: o.Primary_Member__c];
                o.LeadSource              = (lstContcat!=null && !lstContcat.isEmpty()) ? lstContcat[0].LeadSource : null; 
                o.Lead_Source_Detail__c   = (lstContcat!=null && !lstContcat.isEmpty()) ? lstContcat[0].Lead_Source_Detail__c : null; 
                o.utm_campaign__c         = (lstContcat!=null && !lstContcat.isEmpty()) ? lstContcat[0].utm_campaign__c : null;
                o.utm_campaign_id__c      = (lstContcat!=null && !lstContcat.isEmpty()) ? lstContcat[0].utm_campaign_id__c : null;
                o.utm_content__c          = (lstContcat!=null && !lstContcat.isEmpty()) ? lstContcat[0].utm_content__c : null;
                o.utm_medium__c           = (lstContcat!=null && !lstContcat.isEmpty()) ? lstContcat[0].utm_medium__c : null;
                o.utm_source__c           = (lstContcat!=null && !lstContcat.isEmpty()) ? lstContcat[0].utm_source__c : null;
                o.utm_term__c             = (lstContcat!=null && !lstContcat.isEmpty()) ? lstContcat[0].utm_term__c : null;
                o.Locations_Interested__c = (lstContcat!=null && !lstContcat.isEmpty()) ? lstContcat[0].Location_Interested__c : null;
                o.Tour_Notes__c           = pInboundLead.tour_notes;
                if(buildingInterestedId != null){
                    o.Building__c = buildingInterestedId;
                }
                if(o.locations_interested__c != null){ 
                    Set<String> location_Interested = new Set<String>(o.locations_interested__c.split(';'));
                    location_Interested.add(buildingName);
                    o.locations_interested__c = String.join(new List<String>(location_Interested),';');
                    debug.log('updated locations_interested__c ::'+ o.locations_interested__c);
                }
                o.Referral_Fail_Reason__c = pInboundLead.referral_fail_reason != null &&pInboundLead.referral_fail_reason!= '' ? pInboundLead.referral_fail_reason.length() > 255 ? pInboundLead.referral_fail_reason.substring(0, 255):pInboundLead.referral_fail_reason: null ;
                o.Count_of_Desk__c = (lstJourney!=null && !lstJourney.isEmpty()) ? lstJourney[0].Count_of_Desk__c : null;
                o.Owner_Auto_Assign__c = true;                
                insert o;
                Debug.log('Will Insert opportunity ::'+o);
            }
            else{
                Debug.log('In else Will update opportunity ::'+ o);
                if(o.Count_of_Desk__c == null)
                    o.Count_of_Desk__c = (lstJourney!=null && !lstJourney.isEmpty()) ? lstJourney[0].Count_of_Desk__c : null;
                o.Tour_Notes__c = pInboundLead.tour_notes;
                if(buildingInterestedId != null && o.Building__c == null){
                    o.Building__c = buildingInterestedId;
                }
                if(o.locations_interested__c != null){ 
                    debug.log('locations_interested__c of Opportunity ::'+ o.locations_interested__c);
                    Set<String> location_Interested = new Set<String>(o.locations_interested__c.split(';'));
                    location_Interested.add(buildingName);
                    o.locations_interested__c = String.join(new List<String>(location_Interested),';');
                    debug.log('updated locations_interested__c of Opportunity ::'+ o.locations_interested__c);
                }
                else{
                    debug.log('locations_interested__c ==null ::'+ buildingName);
                    o.locations_interested__c = buildingName;
                }
                
                update o;
                UpdateLocationInterestedOnOppQueueable oppLocationInterestedQueueable = new UpdateLocationInterestedOnOppQueueable(pAccountId, pContactId, pInboundLead);
                ID jobID = System.enqueueJob(oppLocationInterestedQueueable);
                Debug.Log('UpdateLocationInterestedOn OppQueueable jobID : ' + jobID);
                if(pContactId != null && pInboundLead.opportunity_id != null && pInboundLead.opportunity_id.length()> 0){
                    List<Opportunity_Role__c> lstOppRole = [Select Id From Opportunity_Role__c Where Contact__c =: pContactId and Opportunity__c =: pInboundLead.opportunity_id];
                    if(lstOppRole.size() == 0){
                        Opportunity_Role__c newOppRole = new Opportunity_Role__c();
                        newOppRole.Contact__c = pContactId;
                        newOppRole.Opportunity__c = pInboundLead.opportunity_id;
                        insert newOppRole;
                        Debug.log('newOppRole ==> '+ newOppRole);
                    }
                }
            }
            Debug.log('Opportunity updated  ==> '+ o);
            return o.Id;
        }catch(Exception ex){
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadHandler','get_or_create_opportunity_new', 'pAccountId : '+ pAccountId +' Payload : '+JSON.serializePretty(pInboundLead), ex)
            );
            throw new applicationException(ex.getMessage());
        }
    }
    public class applicationException extends Exception {}
}