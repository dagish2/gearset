/************************************************************************************************************************************
  Author        : Dipak Pawar
  Description   : Some logic around Tours that is used from different entry points.
   
History:
----------------------------------------------------------------------------------------------------------------------------------
  VERSION       DATE                AUTHOR              DETAIL                  ISSUE
    1           5th June 2018       Dipak Pawar         Initial Developement    ST-2477     
**************************************************************************************************************************************/
public class TourHelper {    
    
    /***********************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method return the Tour record with the given sf_id
        Created Date        :   05 June 2018
        Issue No            :   ST-2482
    *************************************************************************************************************************************/
    public static Tour_Outcome__c createTour(RESTAPITourModelsV2.Input body, Contact objContact, Id opportunityId){        
        Debug.log('Tour Payload---'+body);
        Tour_Outcome__c objTour = new Tour_Outcome__c();
        List<Tour_Outcome__c> lstOriginalTour = new List<Tour_Outcome__c>();
        
        // Map Original_Tour on Tour if original_tour_uuid in payload
        if(String.isNotBlank(body.original_tour_uuid)){
            lstOriginalTour = new List<Tour_Outcome__c>([SELECT Id, booked_by_contact_id__c, booked_by_contact_id__r.Email FROM Tour_Outcome__c WHERE uuid__c =: body.original_tour_uuid]);
        }
        // Map Journey on Tour based on sf_journey_uuid or tour_building_uuid in payload
        RESTAPITourV2.objJourney = getTourRelatedJourney(body.sf_journey_uuid, objContact.Id, body.tour_building_uuid);        
        
        if(String.isNotBlank(body.desks_interested_min)){
            objTour.Interested_in_Number_of_Desks__c = Double.valueOf(body.desks_interested_min);    
        }
        objTour.Status__c = 'Scheduled';
        objTour.Opportunity__c = opportunityId;
        objTour.Tour_Date__c = body.tour_date;
        objTour.Location__c = Settings.mapBuildingByUUID.containsKey(body.tour_building_uuid) ? Settings.mapBuildingByUUID.get(body.tour_building_uuid).Id : null;
        objTour.Start_Time__c = body.tour_time;
        objTour.End_Time__c = null;
        objTour.Entry_Type__c = 'Website';
        objTour.New_Tour_Notes__c = body.tour_notes;
        objTour.uuid__c = body.tour_uuid;
        objTour.Primary_Member__c = objContact.Id;
        objTour.Tour_Participant__c = objContact.Id;
        objTour.Promo_Code__c = body.promo_code;
        objTour.Product_Line__c = body.product_line;        
        objTour.contact_uuid__c = body.contact_uuid;
        objTour.Original_Tour__c = lstOriginalTour.size() > 0 ? lstOriginalTour[0].Id : null;
        objTour.Journey__c = RESTAPITourV2.objJourney != null ? RESTAPITourV2.objJourney.Id : null;
        objTour.sf_journey_uuid__c = body.sf_journey_uuid;
        objTour.Booked_by_contact_id__c = String.isNotBlank(body.booked_by_contact_id) ? body.booked_by_contact_id : null;
        objTour.Booked_By_Sales_Lead__c = body.booked_by_sales_lead != null ? body.booked_by_sales_lead : false;        
        objTour.move_in_time_frame__c = body.move_in_time_frame;
        objTour.Referral_Fail_Reason__c = String.isNotBlank(body.referral_fail_reason) ? body.referral_fail_reason.length() > 255 ? body.referral_fail_reason.substring(0, 255) : body.referral_fail_reason : null;
        
        // ST-2483 : Tour Ownership 
        Setting__c tourBookingSettings = Settings.get('TourRservableSettings');
        TourRservableSettings objTourBookingSetting = new TourRservableSettings();        
        if(tourBookingSettings != null){
            objTourBookingSetting = (TourRservableSettings)JSON.deserialize(tourBookingSettings.Data__c, TourRservableSettings.class);            
        }
        List<Contact> lstBookedByContact;
        if(String.isNotBlank(body.booked_by_contact_id)){            
            Contact contactRec = RESTAPITourV2.getContactById(body.booked_by_contact_id);// query moved to RESTAPITourV2's getContactById method
            User tourBookedByUser = contactRec != NULL && String.isNotBlank(contactRec.Email) ? Settings.getUserByEmail(contactRec.Email) : NULL;
            if(contactRec != null && tourBookedByUser != null){
                objTour.booked_by_contact_id__c = contactRec.Id; 
                objTour.OwnerId = tourBookedByUser.Id;
                objTour.Assigned_Host__c = objTourBookingSetting.apiusercontactid;
            }else{
                String loggedUserEmail = UserInfo.getUserEmail();
                Map<Id, Contact> mapContacts = RESTAPITourV2.mapContacts;
                if(mapContacts != NULL || !mapContacts.isEmpty()){
                    for(Contact objContactRec : mapContacts.values()){
                        if(contactRec.Email.equalsIgnoreCase(loggedUserEmail)){
                            contactRec = objContactRec;
                        }
                    }
                }
                if(contactRec == NULL){
                    List<Contact> lstContacts = new List<Contact>([SELECT Id, Email FROM Contact WHERE Email =: UserInfo.getUserEmail()]);
                	contactRec = !lstContacts.isEmpty() ? lstContacts[0] : NULL;
                }
                if(contactRec != NULL){                    
                   //If Contact with logged in user does exist in SF. 
                    objTour.booked_by_contact_id__c = contactRec.Id;                    
                    objTour.OwnerId = UserInfo.getUserId();
                    objTour.Assigned_Host__c = objTourBookingSetting.apiusercontactid;
                }
            }
        }else{
            // API user
            objTour.booked_by_contact_id__c = objTourBookingSetting.apiusercontactid;
            objTour.OwnerId = objTourBookingSetting.apiuserid;
            objTour.Assigned_Host__c = objTourBookingSetting.apiusercontactid;            
        }
        
        if(objTour.Booked_By_Sales_Lead__c != null && Schema.SObjectType.Account.getRecordTypeInfosById().get(objContact.Account.RecordTypeId).getName() == 'Mid Market'){
            // If Primary contact's Account record type = 'Mid Market' by booked_by_sales_lead
            if(objTour.Booked_By_Sales_Lead__c){
                objTour.Assigned_Host__c = objTour.booked_by_contact_id__c;                
            }else if(objTour.Booked_By_Sales_Lead__c == false){
                objTour.Assigned_Host__c = objTourBookingSetting.apiusercontactid;
                objTour.OwnerId = objTourBookingSetting.apiuserid;
            }   
        }
      
        // Contact To Tour field mappings ST-2489
        objTour = (Tour_Outcome__c)FieldMappingsHelper.getMappings(objContact.Id, objTour, 'FieldMappings:ContactToTour');
        Debug.log('Limits.getQueries() TourHelper.createTour 02 end ::'+Limits.getQueries());
        Debug.Log('createTour objTour---'+objTour);        
        return objTour;
    }
    
     /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to update Interested No Of Desks on Account with given information in tour payload.
        Created Date        :   02 July 2018
        Issue No            :   ST-
    *************************************************************************************************************************************/
    public static void updateInterestedNoOfDesksonAccount(Contact tourContact,RESTAPITourModelsV2.Input objTourPayload){
        if(objTourPayload != null){
            Account objAccToUpdate;
            Boolean isupdateAccount = false;            
            if(tourContact != null && String.isNotBlank(tourContact.AccountId)){
                objAccToUpdate = new Account();                                              
                if(String.isNotBlank(objTourPayload.desks_interested_min) && Integer.valueOf(objTourPayload.desks_interested_min) != tourContact.Account.Interested_in_Number_of_Desks_Min__c){
                    objAccToUpdate.Interested_in_Number_of_Desks_Min__c = Integer.valueOf(objTourPayload.desks_interested_min);  
                    objAccToUpdate.Interested_in_Number_of_Desks__c = Integer.valueOf(objTourPayload.desks_interested_min);
                    isupdateAccount = true;
                }
                if(String.isNotBlank(objTourPayload.desks_interested_max) && Integer.valueOf(objTourPayload.desks_interested_max) != tourContact.Account.Interested_in_Number_of_Desks_Max__c){
                    objAccToUpdate.Interested_in_Number_of_Desks_Max__c = Integer.valueOf(objTourPayload.desks_interested_max);  
                    isupdateAccount = true;
                }
                if(String.isNotBlank(objTourPayload.desks_interested_range) && objTourPayload.desks_interested_range != tourContact.Account.Interested_in_Number_of_Desks_Range__c){
                    objAccToUpdate.Interested_in_Number_of_Desks_Range__c = objTourPayload.desks_interested_range;
                    isupdateAccount = true;
                }
                
                if(isupdateAccount){                   
                    objAccToUpdate.Id = tourContact.AccountId;                    
                    update objAccToUpdate;
                }                
            }  
        } 
    }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method will be return Tour related Journey by UUID provided in payload or Primary Contact's latest modified open Journey.
        Created Date        :   23 Nov 2018
        Modified By         :   Jitesh Adwani on 17 Jan 2019 for ST-3312
   **************************************************************************************************************************************/ 
    static Journey__c getTourRelatedJourney(String strJourneyUUID, Id primaryContactId, String tourBuildingUUID){
        Journey__c objTourJourney;
        if(String.isNotBlank(strJourneyUUID) && RESTAPITourV2.objJourney == null){
            List<Journey__c> lstJourney = new List<Journey__c>([SELECT Id, Count_of_Desk__c FROM Journey__c WHERE UUID__c =: strJourneyUUID]);
            objTourJourney = lstJourney.size() > 0 ? lstJourney[0] : null;
        } else {
            Set<String> setJourneyCloseStages = JourneyHelper.getJourneyCloseStages(); 
            Building__c objBuilding = Settings.getBuildingByUUID(tourBuildingUUID);
            Journey__c objLatestModifiedJourney = LeadTriggerHandler.objLatestModifiedJourney;
            List<Journey__c> lstJourneys = new List<Journey__c>([SELECT Id, Count_of_Desk__c, Building_Interested_In__c, Status__c FROM Journey__c WHERE Primary_Contact__c =: primaryContactId AND Status__c NOT IN :setJourneyCloseStages ORDER BY LastModifiedDate DESC]);
            if(objBuilding != null){
                for(Journey__c objJourney : lstJourneys){
                    if(objBuilding != null && objJourney.Building_Interested_In__c == objBuilding.Id){                       
                        if(objLatestModifiedJourney != null && objLatestModifiedJourney.Building_Interested_In__c == objBuilding.Id){
                            objTourJourney = objLatestModifiedJourney;    
                        } else {
                            objTourJourney = objJourney;   
                        }
                        break;
                    }                   
                }  
            }
            if(objTourJourney == null){
                objTourJourney = objLatestModifiedJourney != null ? objLatestModifiedJourney : (lstJourneys.size() > 0) ? lstJourneys[0] : null;
            }         
        }
        return objTourJourney;
    }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This wrapper class for Settings: TourRservableSettings.
        Created Date        :   05th June 2018
        Issue No            :   ST-2483
   **************************************************************************************************************************************/  
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
}