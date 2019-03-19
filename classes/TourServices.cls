/**
* Some logic around Tours that is used from different entry points.
*
* @author  - Antonio Grassi
* @date    - 02/11/2014
*/
public with sharing class TourServices {
	//Introduce new method for Product line
    public static Time[] getAvailableTimes(Date tourDate, Id tourBuildingId, String product_line) {
        return getAvailableTimes(tourDate, tourBuildingId, false, product_line);
    }
    
    public static Time[] getAvailableTimes(Date tourDate, Id tourBuildingId, Boolean showPastTimes, String product_line) {
        TourHandler h = new TourHandler(
            tourDate, 
            tourBuildingId,
            showPastTimes,
            product_line
        );
        
        return h.open_times;
    }
    
    public static Set<Time> getAvailableTimesAsSet(Date tourDate, Id tourBuildingId, String product_line) {
        return new Set<Time>(getAvailableTimes(tourDate, tourBuildingId, product_line));
    }
    
    public static Tour_Outcome__c scheduleTour(Id leadId, Id oppId, Id buildingId, Date tourDate, String startTime, String productLine) {
        Tour_Schedule__c tour_schedule = [select Tour_Spacing__c from Tour_Schedule__c where Building__c = :buildingId Limit 1];
        
        Time startTimeParsed = parsePicklistTime(startTime);
        
        return scheduleTour(leadId,
                            oppId,
                            buildingId,
                            tourDate,
                            startTime,
                            DateTime.newInstance(Date.today(), startTimeParsed.addMinutes(tour_schedule.Tour_Spacing__c == 'Half Hour' ? 30 : 60)).format('h:mma'),
                            productLine);
        
    }
    
    public static Tour_Outcome__c scheduleTour(Id leadId, Id oppId, Id buildingId, Date tourDate, String startTime, String endTime, String productLine) {    	
        try{
            Tour_Outcome__c t = new Tour_Outcome__c(
                Status__c = 'Scheduled',
                Lead__c = leadId,
                Opportunity__c = oppId,
                Tour_Date__c = tourDate,
                Location__c = buildingId,
                Start_Time__c = startTime,
                End_Time__c = endTime,
                Entry_Type__c = 'New Tour Wizard',
                Product_Line__c = productLine
            );
            
            if(oppId != null){
                Opportunity Opp = [SELECT Id, Primary_Member__c FROM Opportunity WHERE Id=:oppId];
                if(Opp.Primary_Member__c != null)
                    t.Primary_Member__c = Opp.Primary_Member__c;
            }
            
            insert t;
            return t;
        } catch(Exception ex) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('TourServices','scheduleTour', 'lead Id : '+leadId +', Opportunity Id : '+ oppId +', Building Id : '+ buildingId +', startTime : '+ startTime, ex)
            );
            throw new TourServicesException(ex.getMessage());
        }
    }
    
    public static Boolean eventsOverlap(Datetime aStartTime, Datetime aEndTime, Datetime bStartTime, Datetime bEndTime) {
        return (aStartTime < bEndTime && aEndTime >= bEndTime) ||
            (aStartTime <= bStartTime && aEndTime > bStartTime) ||
            (aStartTime >= bStartTime && aEndTime <= bEndTime) ||
            (aStartTime <= bStartTime && aEndTime >= bEndTime);
    }
    
    public static Time parsePicklistTime(String timeString) {
        String[] parts = timeString.split(':');
        return Time.newInstance(Integer.valueOf(parts[0]) + (parts[1].subString(2, 4).equalsIgnoreCase('pm') && parts[0] != '12' ? 12 : 0),
                                Integer.valueOf(parts[1].subString(0, 2)),
                                0,
                                0);
    }
    
    public static Datetime adjustToTimeZone(Date d, Time t, TimeZone tz) {
        return Datetime.newInstanceGMT(d, t).addSeconds(-(tz.getOffset(Datetime.newInstanceGMT(d, t)) / 1000));
    }
    
    public static String getDayOfWeek(Date d) {
        return Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0)).format('EEEE');
    }
    
    //executes under a trigger context
    public static void duplicate_event_to_buildings(Event pEvent) {
        try{
        //containers
        Event[] EEs = new Event[]{}; 
        //variables
        String BUILDING_PREFIX  = 'a00';
        String related_to       = pEvent.WhatId;
        
        //check if business logic applies to duplicate event
        if (pEvent.copy_to_buildings_in_same_country__c &&
            related_to != null &&
            related_to.startsWith(BUILDING_PREFIX)) {
                //get original building
                Building__c b_original = [SELECT country__c 
                                          FROM Building__c 
                                          WHERE id = :related_to 
                                          LIMIT 1
                                         ];
                debug.Log('b_original :: ' + b_original);
                //select buildings from same country
                Building__c[] BBs = [ SELECT id 
                                     FROM Building__c 
                                     WHERE country__c = :b_original.country__c AND 
                                     id <> :b_original.id
                                    ];
                debug.Log('BBs :: ' + BBs);
                //collect events
                for (Building__c b : BBs) {
                    Event e = pEvent.clone(false, false, false, false);
                    e.WhatId = b.id;
                    e.copy_to_buildings_in_same_country__c = false;
                    insert e;
                    //EEs.add(e);
                }            
                //insert EEs;             
            }
        } catch(Exception ex) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('TourServices','duplicate_event_to_buildings', JSON.serializePretty(pEvent), ex)
            );
            throw new TourServicesException(ex.getMessage());
        }
    }
    
    public static Settings.FieldMappings Contact2Tour() {
        Settings.FieldMappings contactToTourMappings = new Settings.FieldMappings();
        contactToTourMappings.version = 1;
        contactToTourMappings.mappings = new Map<String, Settings.MappedField>();
        contactToTourMappings.mappings.put('Primary_Member__c', new Settings.MappedField('Id'));
        contactToTourMappings.mappings.put('Locale__c', new Settings.MappedField('Locale__c'));
        contactToTourMappings.mappings.put('Country_Code__c', new Settings.MappedField('Country_Code__c'));
        contactToTourMappings.mappings.put('utm_campaign__c', new Settings.MappedField('utm_campaign__c'));
        contactToTourMappings.mappings.put('utm_campaign_id__c', new Settings.MappedField('utm_campaign_id__c'));
        contactToTourMappings.mappings.put('utm_content__c', new Settings.MappedField('utm_content__c'));
        contactToTourMappings.mappings.put('utm_medium__c', new Settings.MappedField('utm_medium__c'));
        contactToTourMappings.mappings.put('utm_source__c', new Settings.MappedField('utm_source__c'));
        contactToTourMappings.mappings.put('utm_term__c', new Settings.MappedField('utm_term__c'));
        return contactToTourMappings;
    }
    
    public static Tour_Outcome__c insert_tour_from_external_app(Account relatedAccount, Id pOpportunityId, WWTypes.InboundLead pInboundLead) {
        try{
            List<Contact> lstContact = new List<Contact>();
            List<Tour_Outcome__c> lstTour = new List<Tour_Outcome__c>();
            List<Journey__c> lstJourney = LeadHandler.lstJourney;
            List<User> tourOwner = new List<User>();
            //ST-626
            Settings.FieldMappings mapContactToTour;
            set<String> setContactFields = new set<String>();
            list<String> lstContactFields = new list<String>();
            mapContactToTour = Settings.getFieldMappings('ContactToTour');
            if(mapContactToTour == null)
                mapContactToTour = Contact2Tour();
            
            for(Settings.MappedField field : mapContactToTour.mappings.values()){
                setContactFields.add(field.fieldname.toLowerCase());
            }
            Setting__c tourBookingSettings = Settings.get('TourRservableSettings');
            debug.Log('tourBookingSettings' + tourBookingSettings);
            TourRservableSettings objTourBookingSettings;
            if(tourBookingSettings != null){
                objTourBookingSettings = (TourRservableSettings)JSON.deserialize(tourBookingSettings.Data__c, TourRservableSettings.class);            
            }
            if(pInboundLead.booked_by_contact_id != null){
                Contact[] con = [SELECT Id, Email FROM Contact WHERE Id=:pInboundLead.booked_by_contact_id];
                if(con.size() > 0){
                    //SOQL optimization
                    //tourOwner = [SELECT Id, profileId, Email FROM User WHERE Email =: con[0].Email AND IsActive = true Limit 1];
                    for(User currentUser : Settings.getAllUsers()){
                        if(currentUser.Email == con[0].Email)
                            tourOwner.add(currentUser);
                    }
                }
            }
            lstContactFields.addAll(setContactFields);
            string contactUUID = pInboundLead.contact_uuid;
            Debug.log('lstContactFields For Tour ::'+lstContactFields);
            Set<String> uuids = new Set<String>();
            Map<String, Contact> mapQureiedContact = new Map<String, Contact>();
            if(pInboundLead.contact_uuid != null)
                uuids.add(pInboundLead.contact_uuid);
            if(pInboundLead.tour_completed_by_uuid != null)
                uuids.add(pInboundLead.tour_completed_by_uuid);
            Debug.log('Test : uuids ::: ' + uuids);
            if(uuids.size() > 0)
                for(Contact con : Database.Query('Select UUID__c, ' + String.join(lstContactFields, ',') + ' From Contact Where UUID__c =: uuids')){
                    Debug.log('Test : tour completed by - con ::: ' + con);
                    mapQureiedContact.put(con.UUID__c, con);
                    if(con.UUID__c == pInboundLead.contact_uuid)
                        lstContact.add(con);
                }
            Setting__c objJSONEmailSettings = Settings.get('TourContactEmailSettings');
            if(pInboundLead.original_tour_uuid != null && pInboundLead.original_tour_uuid != '')
                lstTour = [Select Id,booked_by_contact_id__c,booked_by_contact_id__r.Email From Tour_Outcome__c Where uuid__c =: pInboundLead.original_tour_uuid];
            Debug.log('Test : lstTour ==>' + lstTour);
            set<string> setEmails = new set<string>();
            //ST-619:If booked_by_contact_id is blank/null then update this field value to using contact Id having loggedin users email
            //If contact not found using current user id then get email store from TourContactEmailSettings and find contact to update field value. 
            if(string.isBlank(pInboundLead.booked_by_contact_id))
            {
                list<contact> lstContactForId = [Select Id,Name from contact where Email=: UserInfo.getUserEmail() limit 1];
                if(lstContactForId != null && lstContactForId.size() > 0)                {	
                    pInboundLead.booked_by_contact_id = lstContactForId[0].Id;
                    User u = new User(Id=UserInfo.getUserId(), ProfileId=UserInfo.getProfileId(), Email=UserInfo.getUserEmail());
                    tourOwner.add(u);
                }
                else
                {
                    //list<string> lstEmails = new list<string>();
                    
                    //Setting__c objJSONEmailSettings = Settings.get('TourContactEmailSettings');
                    if(objJSONEmailSettings !=null)
                    {
                         setEmails = (set<string>)JSON.deserialize(objJSONEmailSettings.Data__c,  set<string>.class);
                        Boolean outerLoopFlag = false;
                        if(setEmails != null && setEmails.size() > 0)
                        {
                            lstContactForId = [select Id,Name,Email from Contact where Email IN :setEmails];
                            String bookedByContactEmail;
                            for(string currentEmail : setEmails)
                            {
                                if(outerLoopFlag)
                                    break;
                                
                                for(Contact currentContact:lstContactForId)
                                {
                                    //If first contact match found
                                    if(currentEmail == currentContact.Email)
                                    {
                                        bookedByContactEmail = currentEmail;
                                        pInboundLead.booked_by_contact_id = currentContact.Id;
                                        outerLoopFlag = true;
                                        break;
                                    }
                                }
                            }
                            Debug.log('Test : bookedByContactEmail ::: ' + bookedByContactEmail);
                            for(User currentUser : Settings.getAllUsers()){
                                if(currentUser.Email == bookedByContactEmail)
                                    tourOwner.add(currentUser);
                            }
                        }
                    }
                }
            }            
            if(!string.isBlank(pInboundLead.booked_by_contact_id) && !string.isBlank(pInboundLead.original_tour_uuid)){
                if(objJSONEmailSettings !=null){
                    setEmails = (set<string>)JSON.deserialize(objJSONEmailSettings.Data__c,  set<string>.class);
                }
                List<Contact> lstContacts = [Select Id,Name,Email From Contact WHERE Id=: pInboundLead.booked_by_contact_id];
                debug.log('lstContacts==>'+lstContacts);
                debug.log('lstTour==>'+lstTour);
                Debug.log('setEmails==>'+setEmails);
                if(lstContacts != null && !lstContacts.isEmpty() && setEmails.Contains(lstContacts[0].Email)){                   
                    if(lstTour != null && !lstTour.isEmpty() && !setEmails.Contains(lstTour[0].booked_by_contact_id__r.Email)){
                         Debug.log('IF IF==>');
                        pInboundLead.booked_by_contact_id = lstTour[0].booked_by_contact_id__c ;
                    }                    
                }else if(lstContacts != null && !lstContacts.isEmpty() && !setEmails.Contains(lstContacts[0].Email)){
                    if(!lstTour.isEmpty() && !setEmails.Contains(lstTour[0].booked_by_contact_id__r.Email)){
                        Debug.log('Else If==>');
                        pInboundLead.booked_by_contact_id = lstTour[0].booked_by_contact_id__c; 
                    }else{
                         Debug.log('Else Else==>');
                        pInboundLead.booked_by_contact_id = lstContacts[0].Id ;
                    }                   
                }
            } 
            Debug.log('pInboundLead==>'+pInboundLead);
            
            Tour_Outcome__c t = new Tour_Outcome__c(
                Status__c           = 'Scheduled',
                Opportunity__c      = pOpportunityId,
                Tour_Date__c        = pInboundLead.tour_date,
                Location__c         = BuildingHandler.getBuildingIdByUUID(pInboundLead.tour_building_uuid),
                Start_Time__c       = pInboundLead.tour_time,
                End_Time__c         = null, //it will be catched by TourEndTime trigger
                Entry_Type__c       = 'Website',
                New_Tour_Notes__c   = pInboundLead.tour_notes,
                uuid__c             = pInboundLead.tour_uuid,
                Tour_Participant__c = TourServices.get_tour_participant(pInboundLead.contact_uuid),
                Promo_Code__c       = pInboundLead.promo_code,
                Product_Line__c     = pInboundLead.product_line,
                account_uuid__c		= pInboundLead.account_uuid,
                contact_uuid__c		= pInboundLead.contact_uuid,
                Original_Tour__c	= (lstTour!=null && !lstTour.isEmpty()) ? lstTour[0].Id : null,
                Journey__c			= (lstJourney!=null && !lstJourney.isEmpty()) ? lstJourney[0].Id : null,
                sf_journey_uuid__c	= pInboundLead.sf_journey_uuid,
                booked_by_contact_id__c	= (pInboundLead.booked_by_contact_id!=null && pInboundLead.booked_by_contact_id !='') ? pInboundLead.booked_by_contact_id : null,
                Booked_By_Sales_Lead__c = pInboundLead.booked_by_sales_lead != null ? pInboundLead.booked_by_sales_lead : false,
                Assigned_Host__c = objTourBookingSettings != null && objTourBookingSettings.apiusercontactid != '' && objTourBookingSettings.apiusercontactid != null ? objTourBookingSettings.apiusercontactid : null,
                move_in_time_frame__c = pInboundLead.move_in_time_frame,
                Referral_Fail_Reason__c = pInboundLead.referral_fail_reason != null &&pInboundLead.referral_fail_reason!= '' ? pInboundLead.referral_fail_reason.length() > 255 ? pInboundLead.referral_fail_reason.substring(0, 255):pInboundLead.referral_fail_reason: null
            );
            // Changes made by : Anant
            // Date : 8/May/2017
            // If booked by sales lead check box is unchecked then the assigned host field will populated with API user's contact Id and 
            // Tour owner will be the API user.
            Debug.log('TourServices :: '+tourOwner);
            if(Schema.SObjectType.Account.getRecordTypeInfosById().get(relatedAccount.RecordTypeId).getName() != 'Mid Market'){
                if(tourOwner != null && tourOwner.size() > 0)
                    t.OwnerId = tourOwner[0].Id;
            }
            else if(t.Booked_By_Sales_Lead__c == true && Schema.SObjectType.Account.getRecordTypeInfosById().get(relatedAccount.RecordTypeId).getName() == 'Mid Market'){
                if(tourOwner != null && tourOwner.size() > 0)
                	t.OwnerId = tourOwner[0].Id;
                t.Assigned_Host__c = (pInboundLead.booked_by_contact_id!=null && pInboundLead.booked_by_contact_id !='') ? pInboundLead.booked_by_contact_id : null;
            }
            else if(t.Booked_By_Sales_Lead__c == false && Schema.SObjectType.Account.getRecordTypeInfosById().get(relatedAccount.RecordTypeId).getName() == 'Mid Market'){
                t.OwnerId = UserInfo.getUserId();
            }
            
            if(lstContact != null && lstContact.size()>0)
            {
                for(String field : mapContactToTour.mappings.keySet()){
                    Settings.MappedField mappedField = mapContactToTour.mappings.get(field);
                    if(mappedField.isvalue == true)
                        t.put(field, mappedField.value);
                    else
                        t.put(field, lstContact[0].get(mappedField.fieldname));
                    Debug.log('t :: '+t);
                    
                }
            } else {
                String pEmail = pInboundLead.email;
                for(Contact con : Database.Query('Select uuid__c, ' + String.join(lstContactFields, ',') + ' From Contact Where email =: pEmail')){
                    Debug.log('In else lstContact is null' + con);
                    lstContact.add(con);
                }
                if(lstContact != null && lstContact.size()>0){
                    for(String field : mapContactToTour.mappings.keySet()){
                        Debug.log('In else field :: '+ field);
                        Settings.MappedField mappedField = mapContactToTour.mappings.get(field);
                        Debug.log('In else mappedField :: '+mappedField);
                        if(mappedField.isvalue == true)
                            t.put(field, mappedField.value);
                        else
                            t.put(field, lstContact[0].get(mappedField.fieldname));
                        Debug.log('t :: '+t);
                    }
                }
            }
            //dml
            insert t;
            Debug.log('Test : t ::: ' + t);
            return t;
        } catch(Exception ex) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('TourServices','insert_tour_from_external_app','relatedAccount ==> '+ JSON.serializePretty(relatedAccount) +' , pOpportunityId ==> '+ pOpportunityId + ' ==>, '+ JSON.serializePretty(pInboundLead), ex)
            );
            throw new TourServicesException(ex.getMessage());
        }
    }
    
    private static Id get_tour_participant(String uuid) {
        Id result;      
        try {
            //sanity check
            if (uuid == null || uuid == '') throw new TourServicesException('No contact_uuid detected');
            
            Contact c = [SELECT id FROM Contact WHERE uuid__c = :uuid LIMIT 1];
            result = c.id;
        }
        catch(Exception pEx) {
            result = null; //default value
            /*new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('TourServices','get_tour_participant', uuid, pEx)
            );
            throw new TourServicesException(pEx.getMessage());*/
        }
        return result;
    }
    
    public static WWTypes.TourDetail get_tour_by_id(Id pTour_id) {
        try{
            Tour_Outcome__c t = [ SELECT  status__c, id, uuid__c,
                                 
                                 start_time__c, end_time__c, tour_date__c,
                                 tour_notes__c, tour_outcome_notes__c,product_line__c,
                                 referred_by_code__c, referral_code__c,
                                 
                                 Location__r.uuid__c, 
                                 
                                 Opportunity__c, Opportunity__r.Account.name, Opportunity__r.Account.uuid__c,
                                 Opportunity__r.Account.company_size__c, Opportunity__r.Account.industry,
                                 
                                 Opportunity__r.lead_source_detail__c,
                                 Opportunity__r.leadsource,
                                 
                                 Opportunity__r.Primary_Member__r.firstname, Opportunity__r.Primary_Member__r.lastname,
                                 Opportunity__r.Primary_Member__r.name, Opportunity__r.Primary_Member__r.uuid__c, 
                                 Opportunity__r.Primary_Member__r.email, Opportunity__r.Primary_Member__r.phone, 
                                 
                                 Tour_Participant__r.firstname, Tour_Participant__r.lastname, Tour_Participant__r.name,
                                 Tour_Participant__r.email, Tour_Participant__r.phone, Tour_Participant__r.uuid__c,
                                 Tour_Participant__c, 
                                 
                                 Lead__r.name, Lead__r.firstname, Lead__r.lastname, Lead__r.email, Lead__r.phone                                    
                                 
                                 FROM Tour_Outcome__c
                                 WHERE id = :pTour_id
                                 LIMIT 1
                                ];
            //container
            WWTypes.TourDetail result = new WWTypes.TourDetail();
            
            //contact is from Lead
            if (t.Lead__c != null) {
                result.last_name    = t.Lead__r.firstname; 
                result.first_name   = t.Lead__r.lastname;
                result.contact_name = t.Lead__r.name;
                result.contact_uuid = null;
                result.email        = t.Lead__r.email; 
                result.phone        = t.Lead__r.phone;
            }
            
            //contact is from Opportunity Primary
            if (t.Opportunity__c != null && t.Opportunity__r.Primary_Member__r != null) {
                result.last_name    = t.Opportunity__r.Primary_Member__r.firstname; 
                result.first_name   = t.Opportunity__r.Primary_Member__r.lastname;
                result.contact_name = t.Opportunity__r.Primary_Member__r.name;
                result.contact_uuid = t.Opportunity__r.Primary_Member__r.uuid__c;
                result.email        = t.Opportunity__r.Primary_Member__r.email; 
                result.phone        = t.Opportunity__r.Primary_Member__r.phone;
            }
            
            //contact is from Tour Participant
            if (t.Tour_Participant__c != null) {
                result.last_name    = t.Tour_Participant__r.firstname; 
                result.first_name   = t.Tour_Participant__r.lastname;
                result.contact_name = t.Tour_Participant__r.name;
                result.contact_uuid = t.Tour_Participant__r.uuid__c;
                result.email        = t.Tour_Participant__r.email; 
                result.phone        = t.Tour_Participant__r.phone;
            }
            
            //company
            if (t.Opportunity__c != null) {
                result.company_name     = t.Opportunity__r.Account.name;
                result.company_uuid     = t.Opportunity__r.Account.uuid__c;
                result.company_size     = t.Opportunity__r.Account.company_size__c;
                result.company_industry = t.Opportunity__r.Account.industry;
                //result.number_of_desks  = t.Opportunity__r.number_of_desks_2016__c != null ? String.valueOf(t.Opportunity__r.number_of_desks_2016__c) :'0';        
            }
            
            //lead source
            if (t.Opportunity__c != null) {
                result.lead_source        = t.Opportunity__r.leadsource;
                result.lead_source_detail = t.Opportunity__r.lead_source_detail__c;        
            }
            
            //tour details
            result.tour_status            = t.status__c;
            result.tour_date              = t.tour_date__c;      
            result.tour_time              = t.start_time__c;
            result.tour_building_uuid     = t.Location__r.uuid__c;
            result.tour_notes             = t.tour_notes__c;
            result.tour_outcome_notes     = t.tour_outcome_notes__c;
            result.tour_referred_by_code  = null;
            result.tour_referral_code     = null;
            result.tour_id                = t.id;
            result.tour_uuid              = t.uuid__c;
            result.product_line			= t.Product_Line__c;
            //associated oppty
            result.opportunity_id = t.Opportunity__c;
            
            return result;
        } catch(Exception ex) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('TourServices','get_tour_by_id', 'pTour_id =>> '+ pTour_id, ex)
            );
            throw new TourServicesException(ex.getMessage());
        }
    }
    
    public class TourRservableSettings{
        public List<TourReservableProfileSetting> salesleadprofiles{get;set;}
        public String bookedbysalesleadlabel{get;set;}
        public String apiuseremail{get;set;}
        public String apiuserid{get;set;}
        public String apiusercontactid{get;set;}
    }
    
    public class TourReservableProfileSetting{
        public String profilename {get;set;}
        public String profileid {get;set;}
    }
    
    public class TourServicesException extends Exception{}
}