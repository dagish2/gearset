/*****************************************************************************************************************************
  Yet to do
  1. Modularize the code into multiple method calls.
  2. Put comments for each method call to establish references.
  3. Get it reviewed from the peer team.
******************************************************************************************************************************
    Author      :  Krishana Tupe
    Description :  This class contains the business logic of Journey, Campaign and Lead conversion.

    History     :  --

    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION                 DATE            ISSUE       AUTHOR                          DETAIL
    1                       26 Nov 2018      -     		Krishana Tupe                   Initial Developement
******************************************************************************************************************************/
public without sharing class LeadConverterHelper {
    public static Boolean generateJourney;
    public static Boolean isCreateActivity = true;

    public static Map<String,Id> manageLead(Lead objLead){
        LeadConverterHelper.generateJourney = true;
        if(objLead!=null && String.isNotBlank(objLead.Email)){
            Map<String,Map<String,Id>> mapConvertData = manageLead(new List<Lead>{objLead},null);
            return mapConvertData.get(objLead.Email);
        }
        return null;
    }

    public static Map<String,Id> manageLead(RESTAPITourModelsV2.Input objTourPayload){
        LeadConverterHelper.generateJourney = true;
        if(objTourPayload!=null && String.isNotBlank(objTourPayload.email)){
            objTourPayload.email = objTourPayload.email.toLowerCase();
            LeadConverterHelper.isInsert = false;
            Map<String,Map<String,Id>> mapConvertData = manageLead(new List<Lead>{new Lead(Email=objTourPayload.email)},objTourPayload);
            return (mapConvertData != null && mapConvertData.containsKey(objTourPayload.email) ? mapConvertData.get(objTourPayload.email) : null);
        }
        return null;
    }

    public static Map<String,Map<String,Id>> manageLead(List<Lead> lstLeads){
        LeadConverterHelper.generateJourney = true;
        if(lstLeads!=null && lstLeads.size()>0){
            return manageLead(lstLeads,null);
        }
        return null;
    }

    public static Map<String,Map<String,Id>> manageJourneyForLead(List<Lead> lstLeads,Boolean generateJourney){
        LeadConverterHelper.generateJourney = true;
        if(lstLeads!=null && lstLeads.size()>0){
            LeadConverterHelper.generateJourney = generateJourney != null ? generateJourney : true;
            return manageLead(lstLeads,null);
        }
        return null;
    }

    public static void markLeasTasksCompletedOnLeadConversion(List<Lead> lstLeads){
        if(lstLeads != null && lstLeads[0].Tasks != null && lstLeads[0].Tasks.size() > 0){
            List<Task> lstTaskToBeCompleted = new List<Task>();
            for(Task objTask : lstLeads[0].Tasks){
                lstTaskToBeCompleted.add(new Task(Id = objTask.Id, Status = 'Completed'));
            }
            if(lstTaskToBeCompleted != null && lstTaskToBeCompleted.size() > 0){
                Database.update(lstTaskToBeCompleted, false);
            }
        }
    }

    public static void setLeadGenerateJourney(Lead objLead){
        if(objLead != null && String.isNotBlank(objLead.Email)){
            List<Contact> lstContact = [SELECT Id From Contact Where Email =: objLead.Email];
            if(lstContact != null && lstContact.size() > 0){
                LeadConverterHelper.generateJourney = false;
                LeadConverterHelper.isCreateActivity = false;
            }else{
                LeadConverterHelper.generateJourney = true;
                LeadConverterHelper.isCreateActivity = true;
            }
        }
    }

/************************************************************************************************************************************
    Author         : Prashant Mane.
    Description    : This method used to accept Lead Object to get the TourPayLoad and convert Lead.
    Issue No       : CSI-1105
    Created Date   : 10 Aug 2018
**************************************************************************************************************************************/
    public static Map<String,Map<String,Id>> convertLeadWithTour(Lead objLead){
        if(objLead != null && String.isNotBlank(objLead.Email)){
            List<Lead> lstLeads = [SELECT Id,(SELECT Id, Status, WhoId, WhatId FROM Tasks WHERE Status <> 'Completed') From Lead WHERE Id =: objLead.Id];
            RESTAPITourModelsV2.Input objTourPayload = new RESTAPITourModelsV2.Input();
            objTourPayload.email = objLead.Email.toLowerCase();
            LeadConverterHelper.isCreateActivity = false;
            LeadConverterHelper.isInsert = false;
            Map<String,Map<String,Id>> mapConvertedLead  =  LeadConverterHelper.manageLead(new List<Lead>{objLead},objTourPayload);
            LeadConverterHelper.markLeasTasksCompletedOnLeadConversion(lstLeads);
            return mapConvertedLead;
        }
        return null;
    }

 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to get the new Lead map by email and Campaign
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static void getNewLeadsData(List<Lead> lstLeads, Map<String,List<Lead>> mapNewLeadByEmail, Map<Id,Map<Id,Lead>> mapCampaignWithLead){
        for(Lead objLead : lstLeads){
            if(mapNewLeadByEmail != null && String.isNotBlank(objLead.Email)){
                if(!mapNewLeadByEmail.containskey(objLead.Email.toLowerCase())){
                    mapNewLeadByEmail.put(objLead.Email.toLowerCase(), new List<Lead>());
                }
                mapNewLeadByEmail.get(objLead.Email.toLowerCase()).add(objLead);
            }
            if(mapCampaignWithLead != null && String.isNotBlank(objLead.Campaign_Id__c)){
                if(!mapCampaignWithLead.containsKey(objLead.Campaign_Id__c)){
                    mapCampaignWithLead.put(objLead.Campaign_Id__c, new Map<Id,Lead>());
                }
                mapCampaignWithLead.get(objLead.Campaign_Id__c).put(objLead.Id, objLead);
            }
        }
    }

 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to set the exiting contact owner when contact owner is inactive
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static void setContactOwner(Contact objContact, Lead objNewLead, Map<String, String> mapAPIUserInfo){
        if(objContact.OwnerId != null && (!Settings.getUserActive(objContact.OwnerId) || objContact.OwnerId == Id.valueOf(mapAPIUserInfo.get('UserId')))){
            if(objNewLead != null && objNewLead.OwnerId != null && objNewLead.Campaign_Id__c == null && (Settings.getUserActive(objNewLead.OwnerId) && !String.valueOf(objNewLead.OwnerId).toLowerCase().startsWith('00g'))){
                objContact.OwnerId = objNewLead.OwnerId;
            }else if( objNewLead == null || (objNewLead != null && objNewLead.Campaign_Id__c == null)){
                objContact.OwnerId = UserInfo.getUserId();
            }
        }
    }

 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to map the new Lead field onto Exiting Lead
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static void mapNewLeadToLead(Lead objNewLead, Lead objLead){
        if(objNewLead.Locations_Interested__c != null){
            Set<String> setLocationIntrested =  new Set<String>();
            if(objLead.Locations_Interested__c != null){ // objLead:-> existing lead
                setLocationIntrested.addAll(objLead.Locations_Interested__c.split(';'));
            }
            setLocationIntrested.addAll(objNewLead.Locations_Interested__c.split(';'));
            objLead.Locations_Interested__c = String.join(new List<String>(setLocationIntrested),';');
        }
        //Added by Pragalbha for ST-2909
        if(objNewLead.Promo_Code__c != null){
            objLead.Promo_Code__c = objNewLead.Promo_Code__c;
        }
        // Modified By Jitesh Adwani for ST-3409 on 18 February 2019
        if(updateNewAddressValues(objNewLead)){
            objLead.Personal_Mailing_Street__c = getFieldValue(objNewLead.Personal_Mailing_Street__c);
            objLead.Personal_Mailing_City__c = getFieldValue(objNewLead.Personal_Mailing_City__c);
            objLead.Personal_Mailing_Country__c = getFieldValue(objNewLead.Personal_Mailing_Country__c);
            objLead.Personal_Mailing_State__c = getFieldValue(objNewLead.Personal_Mailing_State__c);
            objLead.Personal_Mailing_PostalCode__c = getFieldValue(objNewLead.Personal_Mailing_PostalCode__c);
        }
    }

 /************************************************************************************************************************************
        Author              :   Jitesh Adwani
        Description         :   This method check whether Null value.
      	Created Date  		:   18 Feb 2019
		Issue Number		:	ST-3409
 *************************************************************************************************************************************/
    public static String getFieldValue(String fieldValue){
        return String.isNotBlank(fieldValue) ? fieldValue : '';
    }

  /************************************************************************************************************************************
        Author              :   Jitesh Adwani
        Description         :   This method check whether to map Address fileds.
      	Created Date  		:   18 Feb 2019
		Issue Number		:	ST-3409
 *************************************************************************************************************************************/
    public static Boolean updateNewAddressValues(Lead objNewLead){
        if(String.isNotBlank(objNewLead.Personal_Mailing_Street__c) || String.isNotBlank(objNewLead.Personal_Mailing_City__c) ||
           String.isNotBlank(objNewLead.Personal_Mailing_Country__c) || String.isNotBlank(objNewLead.Personal_Mailing_State__c) ||
           String.isNotBlank(objNewLead.Personal_Mailing_PostalCode__c)){
               return true;
           }
        return false;
    }

/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to map the new Lead data to Contact on Lead Conversion
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static void mapNewLeadToContact(Lead objNewLead, Contact objContact){
        if(objNewLead != null && objNewLead.Promo_Code__c != null){
            objContact.Promo_Code__c = objNewLead.Promo_Code__c;
        }
        if(objNewLead != null && objNewLead.Locations_Interested__c != null){
            Set<String> setLocationIntrested =  new Set<String>();
            if(objContact.Location_Interested__c != null){
                setLocationIntrested.addAll(objContact.Location_Interested__c.split(';'));
            }
            setLocationIntrested.addAll(objNewLead.Locations_Interested__c.split(';'));
            objContact.Location_Interested__c = String.join(new List<String>(setLocationIntrested),';');

        }
        if(String.isBlank(objContact.Company__c)){
            objContact.Company__c = objNewLead.Company;
        }

        // Modified By Jitesh Adwani for ST-3409 on 18 February 2019
        if(updateNewAddressValues(objNewLead)){
            objContact.Personal_Mailing_Street__c = getFieldValue(objNewLead.Personal_Mailing_Street__c);
            objContact.Personal_Mailing_City__c = getFieldValue(objNewLead.Personal_Mailing_City__c);
            objContact.Personal_Mailing_Country__c = getFieldValue(objNewLead.Personal_Mailing_Country__c);
            objContact.Personal_Mailing_State__c = getFieldValue(objNewLead.Personal_Mailing_State__c);
            objContact.Personal_Mailing_PostalCode__c = getFieldValue(objNewLead.Personal_Mailing_PostalCode__c);
        }
    }

 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to get the journey created for a lead
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static Id getJourneyByLeadId(Id leadId, List<Journey__c> lstJourneys){
        if(String.isBlank(leadId)){
            return null;
        }
        for(Journey__c objJourney : lstJourneys){
            if(objJourney.Lead_Id__c == leadId){
                return  objJourney.Id;
            }
        }
        return null;
    }

    public static void updateLeadAssignmentStageOnConversion(Lead objOldLead){
        if(objOldLead.Unomy_Updated_DateTime__c == null || objOldLead.Lead_Demographic_Score_DateTime__c == null){
            objOldLead.Lead_Assignment_Stage__c = 'Lead Converted';
        }
    }

    public static String getHoldBackQueueId(){
        MetadataSetting__mdt objJourneyCreationMDT = Settings.getMetadataSettingByDevName('Hold_Back_Queue');
        return (String.isNotBlank(objJourneyCreationMDT.Data__c) ? objJourneyCreationMDT.Data__c : null);
    }

 /************************************************************************************************************************************
    Author         		: Ajaysinh Chauhan
    Description    		: This method contains the business logic of Lead/Journey insertion and assignment with Dedup/Conversion
    Issue No       		: -
    LastModfied By   	: Krishana Tupe
 **************************************************************************************************************************************/
    public static Boolean isInsert = true;
    public static Map<Id,Lead> mapLeadsToDeDup;
    public static List<Id> lstLeadsToDelete;
    public static set<Id> setLeadIds;
    public static Map<String,Map<String,Id>> manageLead(List<Lead> lstLeads, RESTAPITourModelsV2.Input objTourPayload){
        Map<String,String> mapAPIUserInfo = (Map<String,String>)JSON.deserialize(Settings.get('APIUserContactInfo').Data__c, Map<String,String>.class);
        String strHoldBackQueueId =  LeadConverterHelper.getHoldBackQueueId();
        Map<String,List<Lead>> mapNewLeadByEmail = new Map<String,List<Lead>>();
        mapLeadsToDeDup = new Map<Id,Lead>();
        Map<Id, Lead> mapOldLeadToFireAss = new Map<Id, Lead>();
        Map<Id,Map<Id,Lead>> mapCampaignWithLead = new Map<Id,Map<Id,Lead>>();
        LeadConverterHelper.getNewLeadsData(lstLeads, mapNewLeadByEmail, mapCampaignWithLead);
        String strMDTSettingData = (String)Settings.getMetadataSettingByDevName('CampaignOwnerSetting').Data__c;
        CampaignAssignmentSetting objCampaignAssignmentSetting;
        if(String.isNotBlank(strMDTSettingData)){
            objCampaignAssignmentSetting = (CampaignAssignmentSetting)JSON.deserialize(strMDTSettingData, CampaignAssignmentSetting.class);
        }
        Map<Id, Id> mapCampaignSettings = objCampaignAssignmentSetting.campaigns;
        Map<Id, Campaign> mapCampaigns;
        set<Id> setCampaignIds = new set<Id>();
        if(mapCampaignWithLead != null && mapCampaignWithLead.size() > 0) {
            setCampaignIds.addAll(mapCampaignWithLead.keySet());
        }
        if(mapCampaignSettings != null && mapCampaignSettings.size() > 0){
            setCampaignIds.addAll(mapCampaignSettings.keySet());
        }
        if(setCampaignIds != NUll && !setCampaignIds.isEmpty()){
            mapCampaigns = new Map<Id, Campaign>([SELECT Id, Name, Lead_Owner__c, By_Pass_Campaign_Assignment__c FROM Campaign WHERE Id IN : setCampaignIds]);
        }
        Set<String> setEmails = mapNewLeadByEmail.keySet();
        Map<Id,Lead> mapLeadsEmailChanged = LeadTriggerHandler.mapLeadsEmailChanged;
        if(setEmails != null && setEmails.size() > 0){
            //SOQL on Lead and Contact for get existing Lead and Contact info
            Map<String,List<Contact>> mapContactByEmail = LeadRoutingHelper.getExistingContactsByEmail(setEmails, mapCampaignSettings);
            Map<String,List<Lead>> mapLeadByEmail = LeadRoutingHelper.getLeadsByEmail(setEmails);
            //get or create Org for Lead and Contact
            Map<Id,Id> mapOrgIds = LeadRoutingHelper.getMapLeadContactOrgIds(setEmails, mapLeadByEmail, mapContactByEmail, objTourPayload);
            Debug.log('mapOrgIds ==>'+mapOrgIds);
            Map<String,Map<String,Id>> mapAfterConversionData = new Map<String,Map<String,Id>>();
            Map<String,Map<String,Object>> mapConvertData = new Map<String,Map<String,Object>>();
            lstLeadsToDelete = new List<Id>();
            List<Map<String,sObject>> lstJourneyParents = new List<Map<String,sObject>>();
            List<CampaignMember> lstCampaignMembers = new List<CampaignMember>();
            Map<Id,sObject> mapRecordsToUpdate = new Map<Id,sObject>();
            Map<Id,Lead> mapLeadsToMap = new Map<Id,Lead>();
            Map<Id,Contact> mapContactsToMap = new Map<Id,Contact>();
            Map<Id,Lead> mapDestinationLeads = new Map<Id,Lead>();
            Map<Id,Id> mapJourneyWithLeadOrContactIds = new Map<Id,Id>();
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            setLeadIds = new Set<Id>();

            for(String strEmail : setEmails){
                for(Lead objectNewLead : mapNewLeadByEmail.get(strEmail)){
                    if(objTourPayload != null && String.isNotBlank(objTourPayload.email)){
                        isInsert = false;
                    }
                    if(mapContactByEmail.containsKey(strEmail)){
                        Boolean isAllowConvert = true;
                        Contact objContact;
                        Lead objNewLead;
                        //for Tour payload
                        if(objTourPayload != null && String.isNotBlank(objTourPayload.contact_uuid)){
                            isInsert = false;
                            objContact = getContactByUUID(mapContactByEmail.get(strEmail), objTourPayload.contact_uuid);
                            objContact = LeadRoutingHelper.setExitingAccountStructureForTour(strEmail, objContact, mapOrgIds, mapContactByEmail, mapRecordsToUpdate, objTourPayload);
                        }else{
                            objContact = mapContactByEmail.get(strEmail)[0];
                            Debug.log('In Existing Contact ==>'+((objContact != NULL && String.isNotBlank(objContact.Id)) ? objContact.Id : NULL));
                            objNewLead = getLeadById(mapLeadByEmail.get(strEmail), objectNewLead.Id);
                            if(objNewLead != null && String.isNotBlank(objNewLead.Id)){
                                isAllowConvert = LeadRoutingHelper.updateLeadAssignmentStageForContact(objNewLead, isAllowConvert, isInsert, objTourPayload, dmo, strHoldBackQueueId);
                                objContact.AccountId = mapOrgIds.containsKey(objContact.Id) ? mapOrgIds.get(objContact.Id) : null;
                                Boolean isCheckCampiagnAssignment = true;
                                String campaignOROwnerId = LeadRoutingHelper.getValidCampaignOwnerORCampaignId(objContact, objContact.CampaignMembers, mapCampaignSettings);
                                if(String.isNotBlank(campaignOROwnerId)){
                                    if(campaignOROwnerId.startsWith('005') || campaignOROwnerId.startsWith('00G')){
                                        objNewlead.ownerId = campaignOROwnerId;
                                        isAllowConvert = true;
                                        if(String.isNotBlank(objNewLead.Campaign_Id__c)){
                                            lstCampaignMembers.add(new CampaignMember(ContactId = objContact.Id, CampaignId = objNewLead.Campaign_Id__c));
                                        }
                                        if(campaignOROwnerId.startsWith('005')){
                                            if(objContact.OwnerId != null && (!Settings.getUserActive(objContact.OwnerId) || objContact.OwnerId == mapAPIUserInfo.get('UserId')) && (Settings.getUserActive(campaignOROwnerId) && Id.valueOf(campaignOROwnerId) != Id.valueOf(mapAPIUserInfo.get('UserId')))){
                                                objContact.OwnerId = campaignOROwnerId;
                                            }
                                        }
                                        isCheckCampiagnAssignment = false;
                                        mapRecordsToUpdate.put(objNewlead.Id, objNewlead);
                                    }else if(campaignOROwnerId.startsWith('701')){
                                        mapRecordsToUpdate.put(objNewlead.Id, objNewlead);
                                    }
                                }
                                if(System.isBatch() && objNewLead.By_Pass_Journey_Creation_Criteria__c && isInsert){
                                    setContactOwner(objContact, objNewLead, mapAPIUserInfo);
                                }
                                Id existingCampaignId = (String.isNotBlank(campaignOROwnerId) && campaignOROwnerId.startsWith('701')) ? campaignOROwnerId : NULL;
                                if((objNewLead.Campaign_Id__c != null || String.isNotBlank(existingCampaignId)) && isInsert && isCheckCampiagnAssignment){
                                    String leadOwnerId = LeadRoutingHelper.getLeadOwnerForCampaign(mapCampaigns, (String.isNotBlank(existingCampaignId) ? existingCampaignId : objNewLead.Campaign_Id__c), strHoldBackQueueId);
                                    if(String.isNotBlank(leadOwnerId)){
                                        if(leadOwnerId.startsWith('005')){
                                            if(objContact.OwnerId != null && (!Settings.getUserActive(objContact.OwnerId) || objContact.OwnerId == mapAPIUserInfo.get('UserId'))){
                                                objContact.OwnerId = leadOwnerId;
                                            }
                                        }
                                        //By_Pass_Journey_Creation_Criteria__c == Lead from Journey Importer
                                        if(System.isBatch() && objNewLead.By_Pass_Journey_Creation_Criteria__c){
                                            objNewLead.OwnerId = (Id.valueOf(leadOwnerId) == Id.valueOf(strHoldBackQueueId)) ? UserInfo.getUserId() : leadOwnerId;
                                            if(Id.valueOf(leadOwnerId) == Id.valueOf(strHoldBackQueueId)){
                                                objNewLead.setOptions(dmo);
                                            }
                                            setLeadIds.add(objNewLead.Id);
                                        }else if(Id.valueOf(leadOwnerId) == Id.valueOf(strHoldBackQueueId)){//If Campaign owner is Inactive or Null then we will fire LAR
                                            objNewLead.setOptions(dmo);
                                        }else if(Id.valueOf(leadOwnerId) != Id.valueOf(strHoldBackQueueId)){//Lead owner according to Campaign Assignment
                                            objNewLead.OwnerId = leadOwnerId;
                                            isAllowConvert = true;
                                        }
                                    }
                                    if(String.isNotBlank(objNewLead.Campaign_Id__c)){
                                        lstCampaignMembers.add(new CampaignMember(ContactId = objContact.Id, CampaignId = objNewLead.Campaign_Id__c));
                                    }
                                }
                                if(isInsert && (mapLeadsEmailChanged == null || (mapLeadsEmailChanged != null && !mapLeadsEmailChanged.containsKey(objNewLead.Id)))){
                                    if(LeadConverterHelper.generateJourney != null && LeadConverterHelper.generateJourney){
                                        lstJourneyParents.add(new Map<String,sObject>{'contact'=> objContact,'newlead'=> objNewLead});
                                    }
                                }else if(!isInsert && (objNewLead.Lead_Assignment_Stage__c != '1' && objNewLead.Lead_Assignment_Stage__c != '1000')){
                                    if(mapLeadByEmail != null && mapLeadByEmail.containsKey(strEmail) && mapLeadByEmail.get(strEmail).size() > 0){
                                        for(Lead objOldLead : mapLeadByEmail.get(strEmail)){
                                            if(objOldLead.OwnerId == Id.valueOf(strHoldBackQueueId) && !mapOldLeadToFireAss.containsKey(objOldLead.Id)){
                                                objOldLead.setOptions(dmo);
                                                if((objTourPayload != null && String.isNotBlank(objTourPayload.email)) && (objOldLead.Unomy_Updated_DateTime__c == null || objOldLead.Lead_Demographic_Score_DateTime__c == null)){
                                                    objOldLead.Lead_Assignment_Stage__c = 'Lead Converted';
                                                }
                                                mapOldLeadToFireAss.put(objOldLead.Id, objOldLead);
                                            }
                                            if(!mapJourneyWithLeadOrContactIds.containsKey(objOldLead.Id)){
                                                mapJourneyWithLeadOrContactIds.put(objOldLead.Id, LeadConverterHelper.getJourneyByLeadId(objOldLead.Id, objContact.Journeys__r));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if(isInsert && objNewLead != null){
                            LeadConverterHelper.mapNewLeadToContact(objNewLead, objContact);
                            mapContactsToMap.put(objNewLead.Id, objContact);
                            if(objNewLead != null && objNewLead.OwnerId != null && !Settings.getUserActive(objNewLead.OwnerId) && !String.valueOf(objNewLead.OwnerId).toLowerCase().startsWith('00g')){
                                objNewLead.OwnerId = (System.isBatch()) ? UserInfo.getUserId() : Id.valueOf(mapAPIUserInfo.get('UserId'));
                                mapLeadsToMap.put(objNewLead.Id,objNewLead);
                                mapDestinationLeads.put(objNewLead.Id,objNewLead);
                            }
                        }
                        if(mapLeadByEmail != null && mapLeadByEmail.containsKey(strEmail) && mapLeadByEmail.get(strEmail).size() > 0){
                            if(isInsert){
                                for(Lead objectLead : mapLeadByEmail.get(strEmail)){
                                    if(objectLead != null && objectLead.OwnerId != null && !Settings.getUserActive(objectLead.OwnerId) && !String.valueOf(objectLead.OwnerId).toLowerCase().startsWith('00g') && !mapOldLeadToFireAss.containsKey(objectLead.Id)){
                                        objectLead.OwnerId = Id.valueOf(mapAPIUserInfo.get('UserId'));
                                        mapLeadsToMap.put(objectLead.Id,objectLead);
                                        mapDestinationLeads.put(objectLead.Id,objectLead);
                                    }
                                }
                            }
                            if(isAllowConvert && !mapConvertData.containsKey(strEmail)){
                                mapConvertData.put(strEmail,new Map<String,Object>{'accountId' => mapOrgIds.get(objContact.Id), 'contactId' => objContact.Id, 'leads' => mapLeadByEmail.get(strEmail)});
                            }
                        }
                        if(isAllowConvert && !mapAfterConversionData.containsKey(strEmail)){
                            mapAfterConversionData.put(strEmail,new Map<String,Id>{'accountId' => (objContact != null && objContact.AccountId != null) ? objContact.AccountId : null, 'contactId' => (objContact != null && objContact.Id != null) ? objContact.Id : null});
                        }
                        Boolean isLeadToConvert = (isAllowConvert || (objTourPayload != null && String.isNotBlank(objTourPayload.contact_uuid)));
                        if(isLeadToConvert && !mapLeadByEmail.isEmpty()){
                            for(Lead objOldLead : mapLeadByEmail.get(strEmail)){
                                Boolean isFireAss = (!mapOldLeadToFireAss.containsKey(objOldLead.Id));
                                LeadConverterHelper.updateLeadAssignmentStageOnConversion(objOldLead);
                                if(isLeadToConvert && objOldLead.Lead_Assignment_Stage__c == '6'){
                                    objOldLead.Lead_Assignment_Stage__c = '11';
                                }
                                if(objOldLead.OwnerId == Id.valueOf(strHoldBackQueueId) && (objNewLead == null || (objNewLead != null && !mapLeadsToMap.containskey(objNewLead.Id))) && isFireAss){
                                    objOldLead.setOptions(dmo);
                                    mapRecordsToUpdate.put(objOldLead.Id, objOldLead);
                                    mapJourneyWithLeadOrContactIds.put(objOldLead.Id, LeadConverterHelper.getJourneyByLeadId(objOldLead.Id, objContact.Journeys__r));
                                }else if((objNewLead == null || (objNewLead != null && !mapLeadsToMap.containskey(objNewLead.Id))) && isFireAss){
                                    mapRecordsToUpdate.put(objOldLead.Id,objOldLead);
                                }
                            }
                        }
                        else if(objNewLead != null && String.isNotBlank(objNewLead.Id) && !mapLeadsToMap.containskey(objNewLead.Id) && (!mapOldLeadToFireAss.containsKey(objNewLead.Id))){
                            mapRecordsToUpdate.put(objNewLead.Id,objNewLead);
                        }
                    }
                    else if(mapLeadByEmail != null && mapLeadByEmail.containsKey(strEmail)){
                        Lead objLead = LeadRoutingHelper.sortLeadByCreatedDate(mapLeadByEmail.get(strEmail));
                        Debug.log('objLead Existing Lead ==>'+((objLead != NULL && String.isNotBlank(objLead.Id)) ? objLead.Id : NULL));
                        if(objTourPayload != null){
                            isInsert = false;
                            Map<String,Id> mapAccountStructure = createAccountStructure(objTourPayload, objLead.Id, mapOrgIds.get(objLead.Id));
                            if(objLead !=null && objLead.OwnerId != null && !Settings.getUserActive(objLead.OwnerId) && !String.valueOf(objLead.OwnerId).toLowerCase().startsWith('00g')){
                                objLead.OwnerId = Id.valueOf(mapAPIUserInfo.get('UserId'));
                                mapLeadsToMap.put(objLead.Id, objLead);
                                mapDestinationLeads.put(objLead.Id, objLead);
                            }
                            for(Lead objOldLead : mapLeadByEmail.get(strEmail)){
                                if(objOldLead.OwnerId == Id.valueOf(strHoldBackQueueId) && !mapLeadsToMap.containsKey(objLead.Id)){
                                    objOldLead.setOptions(dmo);
                                    LeadConverterHelper.updateLeadAssignmentStageOnConversion(objOldLead);
                                    mapRecordsToUpdate.put(objOldLead.Id,objOldLead);
                                    mapJourneyWithLeadOrContactIds.put(objOldLead.Id, LeadConverterHelper.getJourneyByLeadId(objOldLead.Id, objLead.Journeys__r));
                                }else if(!mapLeadsToMap.containsKey(objLead.Id)){
                                    LeadConverterHelper.updateLeadAssignmentStageOnConversion(objOldLead);
                                    mapRecordsToUpdate.put(objOldLead.Id,objOldLead);
                                }
                            }
                            mapConvertData.put(strEmail,new Map<String,Object>{'accountId' => mapAccountStructure.get('accountId'),'contactId' => mapAccountStructure.get('contactId'),'leads' => mapLeadByEmail.get(strEmail)});
                        }else{
                            if(mapLeadByEmail.get(strEmail).size() > 1){
                                Lead objNewLead = getLeadById(mapLeadByEmail.get(strEmail), objectNewLead.Id);
                                Debug.log('Duplicate Lead objNewLead==>'+((objNewLead != NULL && String.isNotBlank(objNewLead.Id)) ? objNewLead.Id : NULL));
                                if(objNewLead != null){
                                    LeadRoutingHelper.updateLeadAssignmentStage(objNewLead, mapLeadsToDeDup, isInsert, strHoldBackQueueId, dmo);
                                    LeadConverterHelper.mapNewLeadToLead(objNewLead, objLead);
                                    if(objNewLead.Campaign_Id__c != null && isInsert){
                                        String leadOwnerId = LeadRoutingHelper.getLeadOwnerForCampaign(mapCampaigns, objNewLead.Campaign_Id__c, strHoldBackQueueId);
                                        LeadRoutingHelper.setCampaignAssignment(objNewLead, leadOwnerId, strHoldBackQueueId, mapLeadsToDeDup, dmo, mapAPIUserInfo.get('UserId'));
                                        lstCampaignMembers.add(new CampaignMember(LeadId = objLead.Id, CampaignId = objNewLead.Campaign_Id__c));
                                    }
                                    if(isInsert && (mapLeadsEmailChanged == null || (mapLeadsEmailChanged != null && !mapLeadsEmailChanged.containsKey(objNewLead.Id)))){
                                        lstJourneyParents.add(new Map<String,sObject>{'lead' => objLead, 'newlead' => objNewLead});
                                    }else if(!isInsert && (objNewLead.Lead_Assignment_Stage__c != '1' && objNewLead.Lead_Assignment_Stage__c != '1000')){
                                        if(!mapJourneyWithLeadOrContactIds.containsKey(objLead.Id)){
                                            mapJourneyWithLeadOrContactIds.put(objLead.Id, objNewLead.Id);
                                        }
                                        mapJourneyWithLeadOrContactIds.put(objNewLead.Id, LeadConverterHelper.getJourneyByLeadId(objNewLead.Id, objLead.Journeys__r));
                                    }
                                    if(objLead.Id != objNewLead.Id){
                                        lstLeadsToDelete.add(objNewLead.Id);
                                    }
                                    if(System.isBatch() && isInsert){
                                        if(objLead != null && objLead.OwnerId != null && ((!Settings.getUserActive(objLead.OwnerId) && !String.valueOf(objLead.OwnerId).toLowerCase().startsWith('00g')) || objLead.OwnerId == Id.valueOf(mapAPIUserInfo.get('UserId')))){
                                            if(objNewLead != null && objNewLead.OwnerId != null && objNewLead.Campaign_Id__c == null && (Settings.getUserActive(objNewLead.OwnerId) || String.valueOf(objNewLead.OwnerId).toLowerCase().startsWith('00g'))){
                                                objLead.OwnerId = objNewLead.OwnerId;
                                            }else if(objNewLead == null || (objNewLead != null && objNewLead.Campaign_Id__c == null)){
                                                objLead.OwnerId = UserInfo.getUserId();
                                            }
                                        }
                                        mapLeadsToDeDup.put(objNewLead.Id, objNewLead);
                                    }
                                    if(isInsert){
                                        if(!mapLeadsToMap.containsKey(objLead.Id)){
                                            mapLeadsToMap.put(objLead.Id,objNewLead);
                                        }
                                        if(!mapDestinationLeads.containsKey(objLead.Id)){
                                            mapDestinationLeads.put(objLead.Id,objLead);
                                        }
                                    }
                                    if(mapRecordsToUpdate != null && !mapRecordsToUpdate.containsKey(objNewLead.Id)){
                                        if(!mapLeadsToMap.isEmpty() && mapLeadsToMap.containsKey(objLead.Id) ){
                                            if(objLead.Id != objNewLead.Id){
                                                mapRecordsToUpdate.put(objNewLead.Id,objNewLead);
                                            }
                                        }else if(mapLeadsToMap.isEmpty()){
                                            mapRecordsToUpdate.put(objNewLead.Id,objNewLead);
                                        }
                                    }
                                }
                            }
                            else{
                                Lead objNewLead = getLeadById(mapLeadByEmail.get(strEmail), objectNewLead.Id);
                                if(objNewLead != null){
                                    if(objNewLead.Campaign_Id__c != null && isInsert){
                                        String leadOwnerId = LeadRoutingHelper.getLeadOwnerForCampaign(mapCampaigns, objNewLead.Campaign_Id__c, strHoldBackQueueId);
                                        LeadRoutingHelper.setCampaignAssignment(objNewLead, leadOwnerId, strHoldBackQueueId, mapLeadsToDeDup, dmo, mapAPIUserInfo.get('UserId'));
                                        lstCampaignMembers.add(new CampaignMember(LeadId = objNewLead.Id, CampaignId = objNewLead.Campaign_Id__c));
                                    }
                                    LeadRoutingHelper.updateLeadAssignmentStage(objNewLead, mapLeadsToDeDup, isInsert, strHoldBackQueueId, dmo);
                                    if(System.isBatch() && String.valueOf(objNewLead.ownerId).startsWith('005') && !setLeadIds.contains(objNewLead.Id)){
                                        objNewLead.Status = 'In Process';
                                    }
                                    mapRecordsToUpdate.put(objNewLead.Id, objNewLead);
                                    if(isInsert && (mapLeadsEmailChanged == null || (mapLeadsEmailChanged != null && !mapLeadsEmailChanged.containsKey(objNewLead.Id)))){
                                        lstJourneyParents.add(new Map<String,sObject>{'lead' => objNewLead});
                                    }else if(!isInsert && (objNewLead.Lead_Assignment_Stage__c != '1' && objNewLead.Lead_Assignment_Stage__c != '1000')){
                                        mapJourneyWithLeadOrContactIds.put(objNewLead.Id, LeadConverterHelper.getJourneyByLeadId(objNewLead.Id, objNewLead.Journeys__r));
                                    }
                                }
                            }
                        }
                    }
                    else if(objTourPayload != null){
                        mapAfterConversionData.put(strEmail,createAccountStructure(objTourPayload,null,null));
                    }
                }
            }
            if(mapContactsToMap.size() > 0){
                mapRecordsToUpdate.putAll(FieldmappingsHelper.getMappings(mapContactsToMap,'FieldMappings:LeadToContact').values());
            }
            Debug.log('mapOldLeadToFireAss ==>'+mapOldLeadToFireAss.size());
            if(!mapOldLeadToFireAss.isEmpty()){
                mapRecordsToUpdate.putAll(mapOldLeadToFireAss.values());
            }
            //Map new lead information on Old lead that are blank on old lead
            Debug.log('mapLeadsToMap==>'+mapLeadsToMap.size());
            if(mapLeadsToMap.size() > 0){
                LeadRoutingHelper.mapNewLeadFieldsToOldLead(mapLeadsToMap, mapRecordsToUpdate, mapDestinationLeads);
            }
            Debug.log('mapRecordsToUpdate==> '+mapRecordsToUpdate);
            Debug.log('mapLeadsToDeDup==> '+mapLeadsToDeDup.size());
            Debug.log('lstLeadsToDelete==> '+lstLeadsToDelete.size());
            if(!mapRecordsToUpdate.isEmpty() && mapRecordsToUpdate.size() > 0){
                mapRecordsToUpdate.remove(null);
                Database.update(mapRecordsToUpdate.values());
            }
            LeadRoutingHelper.manageLeadRelatedRecords(isInsert, lstJourneyParents, lstLeadsToDelete, lstCampaignMembers, mapJourneyWithLeadOrContactIds);
            if(mapConvertData.size() > 0){
                Map<String,Map<String,Id>> mapConvertResultData = convertLead(mapConvertData);
                for(String strEmail : mapConvertResultData.keySet()){
                    if(!mapAfterConversionData.containsKey(strEmail)){
                        mapAfterConversionData.put(strEmail, mapConvertResultData.get(strEmail));
                    }
                }
            }
            Debug.log('mapAfterConversionData ==> '+mapAfterConversionData.size());
            return mapAfterConversionData;
        }
        return null;
    }

    public static List<Id> manageDuplicateLeads(List<Id> lstLeadsToDelete){
        List<Id> lstLeadToDeletes = new List<Id>();
        if(isInsert && lstLeadsToDelete != null && lstLeadsToDelete.size() > 0){
            for(Id deleteLeadId : lstLeadsToDelete){
                if(mapLeadsToDeDup.containsKey(deleteLeadId)){
                    lstLeadToDeletes.add(deleteLeadId);
                }
            }
            return lstLeadToDeletes;
        }else{
            return lstLeadsToDelete;
        }
    }

    public static void deleteLeads(List<Id> lstLeadsToDelete){
        if(lstLeadsToDelete != null && lstLeadsToDelete.size() > 0){
            if(!(System.isBatch() || System.isFuture())){
                deleteDuplicateLeads(JSON.serialize(lstLeadsToDelete));
            }else{
                Database.delete(lstLeadsToDelete);
            }
        }
    }

    @future
    public static void deleteDuplicateLeads(String strLstDuplicateLeads){
        if(strLstDuplicateLeads != null && String.isNotBlank(strLstDuplicateLeads) && strLstDuplicateLeads != 'null'){
            List<Id> lstLeadsToDelete = (List<Id>)JSON.deserialize(strLstDuplicateLeads, List<Id>.class);
            Database.delete(lstLeadsToDelete);
        }
    }

    public static Lead getLeadById(List<Lead> lstLeads, String strID){
        if(lstLeads != null && String.isNotBlank(strID)){
            for(Lead objLead : lstLeads){
                if(objLead.Id == strID){
                    return objLead;
                }
            }
        }
        return null;
    }

    public static Contact getContactByUUID(List<Contact> lstContacts, String strUUID){
        if(String.isNotBlank(strUUID)){
            for(Contact objContact : lstContacts){
                if(objContact.UUID__c == strUUID){
                    return objContact;
                }
            }
        }
        return null;
    }

    public static Map<String,Id> createAccountStructure(RESTAPITourModelsV2.Input objTourPayload,Id leadId,Id accountId){
        if(String.isNotBlank(objTourPayload.email)){
            Map<String,Id> mapAccountStructure = new Map<String,Id>();
            Contact objContact = getContactByWeb(objTourPayload);
            if(leadId != null){
                objContact = (Contact)FieldMappingsHelper.getMappings(leadId,objContact,'FieldMappings:LeadToContact');
            }
            if(accountId != null){
                objContact.AccountId = accountId;
            }
            objContact.Convert_Lead__c = false;
            if(String.isNotBlank(objTourPayload.Promo_Code)){
                objContact.Promo_Code__c = objTourPayload.Promo_Code;
            }
            insert objContact;
            if(accountId == null){
                objContact = [Select Id,FirstName,LastName,Name,Company__c,OwnerId,Email_Domain__c,Account_Name__c,AccountId,Account.Account_Type__c,Email,Unomy_Company_ID__c,Unomy_Company_Name__c,UUID__c,Location__c,Location__r.City__c,LeadSource,Cleansed_Unomy_Company_Name__c,Location_Interested__c,Cleansed_Company_Name__c From Contact Where Id=:objContact.Id];
                objContact.AccountId = OrganizationHelper.findOrCreateRelatedOrg(objContact);
                update objContact;
            }
            mapAccountStructure.put('contactId',objContact.Id);
            mapAccountStructure.put('accountId',objContact.AccountId);
            return mapAccountStructure;
        }
        return null;
    }

    public static Contact getContactByWeb(RESTAPITourModelsV2.Input objTourPayload){
        return new Contact(
            FirstName = objTourPayload.first_name,
            LastName = objTourPayload.last_name,
            Company__c = objTourPayload.company_name,
            Convert_Lead__c = false,
            Phone = objTourPayload.phone,
            Email = objTourPayload.email,
            Locale__c = objTourPayload.locale,
            Product_Interests__c = objTourPayload.product_interests != null ? String.join(objTourPayload.product_interests, ';') : null,
            Country_Code__c = objTourPayload.country_code,
            Product_Line__c = objTourPayload.product_line,
            UUID__c = objTourPayload.contact_uuid,
            Marketing_Consent__c = ((objTourPayload.marketing_consent != null && objTourPayload.marketing_consent == 'true') ? true :false),
            Affiliate_Consent__c = ((objTourPayload.affiliates_consent != null && objTourPayload.affiliates_consent == 'true') ? true : false),
            Ts_and_Cs_Consent__c = ((objTourPayload.t_and_cs_consent != null && objTourPayload.t_and_cs_consent == 'true') ? true : false),
            Referral_Fail_Reason__c = String.isNotBlank(objTourPayload.referral_fail_reason) ? (objTourPayload.referral_fail_reason.length() > 255 ? objTourPayload.referral_fail_reason.substring(0, 255):objTourPayload.referral_fail_reason) : null
        );
    }

    public static List<Lead> getDefaultLeadMappings(Map<Id,Lead> mapLeads){
        Set<String> setFields =  LeadRoutingHelper.getListofLeadFields();
        Set<Id> setLeadIds = mapLeads.keySet();
        String query = 'Select Id,'+String.join(new List<String>(setFields),',')+' From Lead Where Id IN:setLeadIds';
        List<Lead> lstDestinations = Database.query(query);
        for(Lead objDestination : lstDestinations){
            if(objDestination.Id != mapLeads.get(objDestination.Id).Id){
                Map<String,Object> mapDestination = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(objDestination));
                Map<String,Object> mapSource = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(mapLeads.get(objDestination.Id)));
                for(String strField:mapSource.keySet()){
                    if(setFields.contains(strField) && mapDestination.get(strField)==null && mapSource.get(strField)!=null){
                        objDestination.put(strField,mapSource.get(strField));
                    }
                }
            }
        }
        return lstDestinations;
    }

    public static Map<String,Map<String,Id>> convertLead(Map<String, Map<String,Object>> mapConvertData){
        Map<String,String> mapAPIUserInfo = (Map<String,String>)JSON.deserialize(Settings.get('APIUserContactInfo').Data__c, Map<String,String>.class);
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        for(Map<String,Object> convertData:mapConvertData.values()){
            for(Lead objLead : (List<Lead>)convertData.get('leads')){
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(objLead.Id);
                lc.setAccountId(String.valueOf(convertData.get('accountId')));
                lc.setContactId(String.valueOf(convertData.get('contactId')));
                lc.setConvertedStatus('Qualified');
                lc.doNotCreateOpportunity = true;
                lc.overwriteLeadSource  = false;
                lc.setOwnerId((String.valueOf(objLead.OwnerId).toLowerCase().startsWith('00g') || !Settings.getUserActive(objLead.OwnerId)) ? mapAPIUserInfo.get('UserId') : objLead.OwnerId);
                leadConverts.add(lc);
            }
        }
        List<Database.LeadConvertResult> lstConvertResults = Database.convertLead(leadConverts);
        Map<Id,Database.LeadConvertResult> mapConvertResult = new Map<Id,Database.LeadConvertResult>();
        for(Database.LeadConvertResult objConvertResult:lstConvertResults){
            mapConvertResult.put(objConvertResult.getLeadId(),objConvertResult);
        }
        List<Lead> lstLeads = [Select Id,Email From Lead Where Id IN:mapConvertResult.keySet()];
        Map<String,Map<String,Id>> mapConvertResultData = new Map<String,Map<String,Id>>();
        for(Lead objLead:lstLeads){
            Database.LeadConvertResult result = mapConvertResult.get(objLead.Id);
            if(result.isSuccess()){
                mapConvertResultData.put(objLead.Email.toLowerCase(),new Map<String,Id>{'accountId'=>result.getAccountId(),'contactId'=>result.getContactId(),'leadId'=>result.getLeadId()});
            }
        }
        return mapConvertResultData;
    }

    public class CampaignAssignmentSetting{
        Map<Id, Id> campaigns ;
    }

}