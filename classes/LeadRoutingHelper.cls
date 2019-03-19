/*****************************************************************************************************************************
  Yet to do
  1. Modularize the code into multiple method calls.
  2. Put comments for each method call to establish references.
  3. Get it reviewed from the peer team.
******************************************************************************************************************************
    Author      :  Krishana Tupe
    Description :  This helper class it contains the business logic related to Lead Routing and Conversion
    History     :  --

    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION                 DATE            ISSUE       AUTHOR                          DETAIL
    1                       23 Nov 2018      -     		Krishana Tupe                   Initial Developement
******************************************************************************************************************************/
public without sharing class LeadRoutingHelper {

/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used get first created lead from the List of leads
      	Created Date  		:   27 Nov 2018
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static  DateTime objLeadCreatedDate;
    public static Lead sortLeadByCreatedDate(List<Lead> lstLeadsToSort){
        if(lstLeadsToSort != null && lstLeadsToSort.size() > 0){
            Lead objFirstLeadCreated = lstLeadsToSort[0];
            if(lstLeadsToSort.size() > 1){
                LeadRoutingHelper.objLeadCreatedDate = lstLeadsToSort[0].createdDate;
                for(Lead objLead : lstLeadsToSort){
                    Integer iCompareValue = LeadRoutingHelper.compareTo(objLead);
                    if(iCompareValue == 1){
                        objFirstLeadCreated = objLead;
                    }
                }
            }
            return objFirstLeadCreated;
        }
        return null;
    }

    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used get compare the lead using CreatedDate
      	Created Date  		:   27 Nov 2018
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static Integer compareTo(Lead objLead){
        if(objLead.CreatedDate < LeadRoutingHelper.objLeadCreatedDate){
            LeadRoutingHelper.objLeadCreatedDate = objLead.CreatedDate;
            return 1;
        }else if(objLead.CreatedDate >= LeadRoutingHelper.objLeadCreatedDate){
            return 0;
        }
        return -1;
    }

  /************************************************************************************************************************************
       Author              :   Krishana Tupe
       Description         :   This method is used to insert,Update and Delete Lead related records also change owner of Journeys according to HOLD-BACK flow
       Created Date  		:   04 Dec 2018
 *************************************************************************************************************************************/
    public static Map<Id,Id> mapJourneysWithLeadOrContactIds = new Map<Id,Id>();
    public static void manageLeadRelatedRecords(Boolean isInsert, List<Map<String, sObject>> lstJourneyParents, List<Id> lstLeadsToDelete, List<CampaignMember> lstCampaignMembers, Map<Id,Id> mapJourneyWithLeadOrContactIds){
        if(isInsert){
            if(lstCampaignMembers.size() > 0){
                Database.insert(lstCampaignMembers,false);
            }
            Debug.log('lstJourneyParents ==>'+lstJourneyParents.size());
            if(lstJourneyParents.size() > 0){
                mapJourneysWithLeadOrContactIds = mapJourneyWithLeadOrContactIds;
                JourneyHelper.createJourney(lstJourneyParents, (System.isBatch() ? lstLeadsToDelete : LeadConverterHelper.manageDuplicateLeads(lstLeadsToDelete)));
            }else if(!System.isBatch() && lstLeadsToDelete != null && lstLeadsToDelete.size() > 0){
                LeadConverterHelper.deleteLeads((System.isBatch() ? lstLeadsToDelete : LeadConverterHelper.manageDuplicateLeads(lstLeadsToDelete)));
            }
        }else if(!mapJourneyWithLeadOrContactIds.isEmpty()){
            if(!System.isBatch() && mapJourneyWithLeadOrContactIds.size() > 0){
                JourneyHelper.updateJourneyOwner(JSON.serialize(mapJourneyWithLeadOrContactIds), JSON.serialize(lstLeadsToDelete));
            }else if(lstLeadsToDelete.size() > 0){
                Database.delete(lstLeadsToDelete);
            }
        }
    }

    public static void updateBypassProcessingStage(Lead objLead){
        if(String.isBlank(objLead.Update_HQ_Market_Status__c) || objLead.Update_HQ_Market_Status__c.equalsIgnoreCase('Pending')){
            objLead.Bypass_Processing_Stage__c = 'Market Identified';
        }
        if(String.isNotBlank(objLead.processing_stage__c) && objLead.processing_stage__c.equalsIgnoreCase('Created')){
            objLead.Bypass_Processing_Stage__c = 'Enriched;Demographic Scored;Market Identified';
        }
    }

 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to update the Lead Assignment stage according to HOLD-BACK flow if exiting contact exist.
      	Created Date  		:   28 Nov 2018
 *************************************************************************************************************************************/
    public static Boolean updateLeadAssignmentStageForContact(Lead objNewLead, Boolean isAllowConvert,  Boolean isInsert, RESTAPITourModelsV2.Input objTourPayload, Database.DMLOptions dmo, String strHoldBackQueueId){
        if(isInsert && objNewLead.Lead_Assignment_Stage__c == '1000'){
            isAllowConvert = true; //handled for manual creation
            objNewLead.Processing_Stage__c = 'Assignment Complete';
        }else if(!System.isBatch() && isInsert && String.isBlank(objNewLead.Campaign_Id__c) && RESTInboundLeadAPIHelper.isLeadFromWeb && objNewLead.Lead_Assignment_Stage__c == '1'){
            objNewLead.ownerId = strHoldBackQueueId;
            objNewLead.Lead_Assignment_Stage__c = '6';
            isAllowConvert = false;
        }else if(!isInsert && objNewLead.Lead_Assignment_Stage__c == '6' && objNewLead.OwnerId == Id.valueOf(strHoldBackQueueId) && (objTourPayload == null || (objTourPayload != null && String.isNotBlank(objTourPayload.email)))){
            if(!objNewLead.Send_For_Forcefully_Lead_Assignments__c && objNewLead.Unomy_Updated_DateTime__c == null){
                objNewLead.Send_For_Forcefully_Lead_Assignments__c = true;
                objNewLead.Forcefully_Assigned_On__c = System.now();
            }
            objNewLead.Lead_Assignment_Stage__c = 'Lead Converted';
            objNewLead.setOptions(dmo);
            updateBypassProcessingStage(objNewLead);
            objNewLead.Processing_Stage__c = 'Assignment Complete';
            isAllowConvert = true;
        }else if(objNewLead.Lead_Assignment_Stage__c == '1' && String.isBlank(objNewLead.Campaign_Id__c) && objNewLead.ownerId == Id.valueOf(strHoldBackQueueId)){
            updateBypassProcessingStage(objNewLead);
            objNewLead.Processing_Stage__c = 'Assignment Complete';
            objNewLead.setOptions(dmo);
            isAllowConvert = true;
        }
        return isAllowConvert;
    }

 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used update the Lead Assignment stage according to HOLD-BACK flow
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static void updateLeadAssignmentStage(Lead objNewLead, Map<Id, Lead> mapLeadsToDeDup, Boolean isInsert, String strHoldBackQueueId, Database.DMLOptions dmo){
        if(isInsert && objNewLead.Lead_Assignment_Stage__c == '1000'){
            objNewLead.Processing_Stage__c = 'Assignment Complete';
            mapLeadsToDeDup.put(objNewLead.Id, objNewLead);   //handled for manual creation
        }else if(!System.isBatch() && isInsert && String.isBlank(objNewLead.Campaign_Id__c) && objNewLead.Lead_Assignment_Stage__c == '1' && RESTInboundLeadAPIHelper.isLeadFromWeb){
            objNewLead.ownerId = strHoldBackQueueId;
            objNewLead.Lead_Assignment_Stage__c = '6';
        }else if(!isInsert && objNewLead.Lead_Assignment_Stage__c == '6' && objNewLead.OwnerId == Id.valueOf(strHoldBackQueueId)){
            objNewLead.Lead_Assignment_Stage__c = '11';
            if(!objNewLead.Send_For_Forcefully_Lead_Assignments__c && objNewLead.Unomy_Updated_DateTime__c == null){
                objNewLead.Send_For_Forcefully_Lead_Assignments__c = true;
                objNewLead.Forcefully_Assigned_On__c = System.now();
            }
            objNewLead.setOptions(dmo);
            updateBypassProcessingStage(objNewLead);
            objNewLead.Processing_Stage__c = 'Assignment Complete';
        }else if(objNewLead.Lead_Assignment_Stage__c == '1'){
            objNewLead.Processing_Stage__c = 'Assignment Complete';
            mapLeadsToDeDup.put(objNewLead.Id, objNewLead);
        }
    }

  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used set the Campaign owner to a Lead according to Campaign Assignment flow
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static void setCampaignAssignment(Lead objNewLead, String leadOwnerId, String strHoldBackQueueId, Map<Id,Lead> mapLeadsToDeDup, Database.DMLOptions dmo, Id apiUserId){
        if(leadOwnerId != apiUserId && Id.valueOf(leadOwnerId) != Id.valueOf(strHoldBackQueueId)){
            objNewLead.OwnerId = leadOwnerId;
        }
        if(Id.valueOf(leadOwnerId) == Id.valueOf(strHoldBackQueueId)){
            objNewLead.setOptions(dmo);
            LeadConverterHelper.setLeadIds.add(objNewLead.Id);
        }
        mapLeadsToDeDup.put(objNewLead.Id, objNewLead);
    }


  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used identify the Campaign Assignment owner if not found it will return HOLD-BACK Queue Id
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static String getLeadOwnerForCampaign(Map<Id, Campaign> mapCampaigns, String campaignId, String strHoldBackQueueId){
        Id campaignLeadOwner = (mapCampaigns != null && mapCampaigns.containsKey(campaignId)) ? mapCampaigns.get(campaignId).Lead_Owner__c : null;
        if(String.isNotBlank(campaignLeadOwner) && Settings.getUserActive(campaignLeadOwner)){
            return campaignLeadOwner;
        }else if(String.isNotBlank(strHoldBackQueueId)){
            return strHoldBackQueueId;
        }
        return null;
    }

 	/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used find the org for Lead and Contact for LeadConverterHelper class
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 	*************************************************************************************************************************************/
    public static Map<Id,Id> getMapLeadContactOrgIds(Set<String> setEmails, Map<String,List<Lead>> mapLeadByEmail, Map<String, List<Contact>> mapContactByEmail, RESTAPITourModelsV2.Input objTourPayload){
        List<Lead> lstLeadRecords = new List<Lead>();
        List<Contact> lstContactRecords = new List<Contact>();
        for(String strEmail : setEmails){
            if(mapContactByEmail.containsKey(strEmail)){
                if(objTourPayload != null){
                    Contact objContact = LeadConverterHelper.getContactByUUID(mapContactByEmail.get(strEmail),objTourPayload.contact_uuid);
                    if(objContact != null){
                        lstContactRecords.add(objContact);
                    }else{
                        lstContactRecords.add(mapContactByEmail.get(strEmail)[0]);
                    }
                }else{
                    lstContactRecords.add(mapContactByEmail.get(strEmail)[0]);
                }
            }else if(mapLeadByEmail.containsKey(strEmail)){
                for(Lead objLead : mapLeadByEmail.get(strEmail)){
                    lstLeadRecords.add(objLead);
                }
            }
        }
        List<sObject> lstRecordsToFindOrg = new List<sObject>();
        if(lstLeadRecords.size() > 0){
            lstRecordsToFindOrg.addAll(lstLeadRecords);
        }
        if(lstContactRecords.size() > 0){
            lstRecordsToFindOrg.addAll(lstContactRecords);
        }
        Map<Id,Id> mapOrgIds;
        if(lstRecordsToFindOrg.size() > 0){
            mapOrgIds = OrganizationHelper.findOrCreateRelatedOrg(lstRecordsToFindOrg);
        }
        return mapOrgIds;
    }


 	/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to set the Account-Contact Structure for Lead Conversion on Tour Booking
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 	*************************************************************************************************************************************/
    public static Contact setExitingAccountStructureForTour(String strEmail, Contact objContact, Map<Id,Id> mapOrgIds, Map<String, List<Contact>> mapContactByEmail, Map<Id,sObject> mapRecordsToUpdate, RESTAPITourModelsV2.Input objTourPayload){
        if(objContact == null && mapContactByEmail.containsKey(strEmail) && mapContactByEmail.get(strEmail).size() > 0){
            objContact = mapContactByEmail.get(strEmail)[0];
            Contact objContactToUpdate = new Contact(Id = objContact.Id);
            objContactToUpdate.UUID__C = objTourPayload.contact_uuid;
            if(String.isNotBlank(objTourPayload.promo_code)){
                objContactToUpdate.Promo_Code__c = objTourPayload.promo_code;
            }
            if(objContact.AccountId == null){
                objContactToUpdate.AccountId = mapOrgIds.containsKey(objContact.Id) ? mapOrgIds.get(objContact.Id) : null;
                objContact.AccountId = objContactToUpdate.AccountId;
            }
            if(String.isBlank(objContact.Company__c)){
                objContactToUpdate.Company__c = objTourPayload.company_name;
            }
            mapRecordsToUpdate.put(objContact.Id, objContactToUpdate);
        }else if(objContact != null && objContact.AccountId == null && mapOrgIds.containsKey(objContact.Id) && String.isNotBlank(mapOrgIds.get(objContact.Id))){
            objContact.AccountId = mapOrgIds.get(objContact.Id);
            mapRecordsToUpdate.put(objContact.Id, new Contact(Id = objContact.Id, AccountId = objContact.AccountId));
        }else if(objContact != null && objContact.AccountId != null && String.isNotBlank(objTourPayload.promo_code)){
            Contact objContactToUpdatePromo = new Contact(Id = objContact.Id);
            objContactToUpdatePromo.Promo_Code__c = objTourPayload.promo_code;
            mapRecordsToUpdate.put(objContactToUpdatePromo.Id, objContactToUpdatePromo);
        }
        return objContact;
    }

    public static Set<String> setFields;
    public static Set<String> getListofLeadFields(){
        if(setFields == null){
            setFields = new Set<String>();
            Schema.DescribeSObjectResult sObjResult = Schema.getGlobalDescribe().get('Lead').getDescribe();
            for(String fieldName:sObjResult.fields.getMap().keyset()){
                Schema.DescribeFieldResult fieldResult = sObjResult.fields.getMap().get(fieldName).getDescribe();
                if(fieldResult.isCreateable() && !fieldResult.isAutoNumber() && !fieldResult.isCalculated()){
                    setFields.add(fieldResult.getName());
                }
            }
        }
        return setFields;
    }

 	/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to map new Lead values to old Lead. here only old lead blank values will be Changed.
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 	*************************************************************************************************************************************/
    public static void mapNewLeadFieldsToOldLead(Map<Id,Lead> mapLeadsToMap, Map<Id, sObject> mapRecordsToUpdate,   Map<Id,Lead> mapDestinationLeads){
        Set<String> setFields = getListofLeadFields();
        List<Lead> lstMappedLeads = LeadConverterHelper.getDefaultLeadMappings(mapLeadsToMap);
        for(Lead objLead : lstMappedLeads){
            Lead objDestinationLead = mapDestinationLeads.get(objLead.Id);
            Map<String, Object> mapDestination = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(objDestinationLead));
            for(String fieldName : mapDestination.keySet()){
                if(setFields.contains(fieldName)){
                    objLead.put(fieldName,objDestinationLead.get(fieldName));
                }
            }
            mapRecordsToUpdate.put(objLead.Id,objLead);
        }
    }

    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to get journey closed stages.
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 	*************************************************************************************************************************************/
    public static set<String> getJourneyClosedStages(){
        MetadataSetting__mdt objMetadataSetting = Settings.getMetadataSettingByDevName('ClosedJourneyStages');
        return (Set<String>)JSON.deserialize(objMetadataSetting.Data__c, Set<String>.class);
    }

    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to get Existing Leads and Journeys By Email
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 	*************************************************************************************************************************************/
    public static Map<String,List<Lead>> getLeadsByEmail(Set<String> setEmails){
        Map<String,List<Lead>> mapLeadByEmail = new Map<String,List<Lead>>();
        Set<String> setJourneyClosedStages  = getJourneyClosedStages();
        List<String> lstLeadFields = new List<String>(getLeadFields());
        List<String> lstJourneyFields = new List<String>(getJourneyFields());
        String strQuery = 'SELECT ' + String.join(lstLeadFields, ',') + ', (SELECT '+ String.join(lstJourneyFields, ',') +' FROM Journeys__r WHERE Status__c NOT IN : setJourneyClosedStages AND CreatedDate = TODAY ORDER BY LastModifiedDate DESC),(SELECT Id, Status, WhoId, WhatId FROM Tasks WHERE Status <> \'Completed\') From Lead WHERE IsConverted = false AND Email IN : setEmails ORDER BY CreatedDate';
        List<Lead> lstLeads = (List<Lead>)Database.query(strQuery);
        for(Lead objLead : lstLeads){
            if(!mapLeadByEmail.containsKey(objLead.Email.toLowerCase())){
                mapLeadByEmail.put(objLead.Email.toLowerCase(),new List<Lead>());
            }
            mapLeadByEmail.get(objLead.Email.toLowerCase()).add(objLead);
        }
        return mapLeadByEmail;
    }

 	/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to get Existing Contact and Journeys By Email
      	Created Date  		:   28 Nov 2018
        Last Modified By    :   Krishana Tupe
 	*************************************************************************************************************************************/
    public static Map<String,List<Contact>> getExistingContactsByEmail(Set<String> setEmails){
        return getExistingContactsByEmail(setEmails, null);
    }

    public static Map<String,List<Contact>> getExistingContactsByEmail(Set<String> setEmails, Map<Id, Id> mapcampaignSettings){
        Map<String,List<Contact>> mapContactByEmail = new Map<String,List<Contact>>();
        Set<String> setJourneyClosedStages  = getJourneyClosedStages();
        List<String> lstContactFields = new List<String>(getContactFields());
        List<String> lstJourneyFields = new List<String>(getJourneyFields());
        set<Id> setCampaignIds = mapcampaignSettings != null ? mapcampaignSettings.keySet() : NULL;
        String strQuery = 'SELECT ' + String.join(lstContactFields, ',') + ', (SELECT '+ String.join(lstJourneyFields, ',') +' FROM Journeys__r WHERE Status__c NOT IN : setJourneyClosedStages AND CreatedDate = TODAY ORDER BY LastModifiedDate DESC)';
        if(mapcampaignSettings != null && !mapcampaignSettings.keySet().isEmpty()){
            strQuery += ' ,(SELECT Id, CampaignId, Campaign.Lead_Owner__c, Campaign.EndDate, ContactId, LeadId, Email FROM CampaignMembers WHERE CampaignId IN : setCampaignIds ORDER BY LastModifiedDate DESC) ';
        }
        strQuery += ' FROM Contact WHERE Email IN : setEmails ORDER BY LastModifiedDate DESC';
        List<Contact> lstContacts = (List<Contact>)Database.query(strQuery);
        for(Contact objContact : lstContacts){
            if(!mapContactByEmail.containsKey(objContact.Email.toLowerCase())){
                mapContactByEmail.put(objContact.Email.toLowerCase(),new List<Contact>());
            }
            mapContactByEmail.get(objContact.Email.toLowerCase()).add(objContact);
        }
        return mapContactByEmail;
    }

 	/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to get Contact fields that are used for LeadConverterHelper
      	Created Date  		:   24 Nov 2018
        Last Modified By    :   Krishana Tupe
 	*************************************************************************************************************************************/
    public static set<String> getContactFields(){
        Set<String> setContactFields = new Set<String>();
        setContactFields.add('id');
        setContactFields.add('number_of_desks_2016__c');
        setContactFields.add('company_size__c');
        setContactFields.add('ownerId');
        setContactFields.add('status__c');
        setContactFields.add('account_name__c');
        setContactFields.add('accountid');
        setContactFields.add('account.account_type__c');
        setContactFields.add('createddate');
        setContactFields.add('lastmodifieddate');
        setContactFields.add('firstname');
        setContactFields.add('lastname');
        setContactFields.add('name');
        setContactFields.add('promo_code__c');
        setContactFields.add('interested_in_number_of_desks__c');
        setContactFields.add('product_line__c');
        setContactFields.add('company__c ');
        setContactFields.add('email_domain__c');
        setContactFields.add('email');
        setContactFields.add('unomy_company_id__c');
        setContactFields.add('uuid__c');
        setContactFields.add('unomy_company_name__c');
        setContactFields.add('location__r.city__c');
        setContactFields.add('cleansed_unomy_company_name__c');
        setContactFields.add('leadsource ');
        setContactFields.add('location_interested__c');
        setContactFields.add('cleansed_company_name__c');
        return setContactFields;
    }

 	/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :  	This method is used to get Journey fields that are used for LeadConverterHelper
      	Created Date  		:   27 Nov 2018
        Last Modified By    :   Krishana Tupe
 	*************************************************************************************************************************************/
    public static Set<String> getJourneyFields(){
        Set<String> setJourneyFields = new Set<String>();
        setJourneyFields.add('id');
        setJourneyFields.add('mode_of_assignment__c');
        setJourneyFields.add('lead_id__c');
        setJourneyFields.add('ownerId');
        setJourneyFields.add('status__c');
        setJourneyFields.add('building_interested_in__c');
        setJourneyFields.add('building_interested_in__r.city__c');
        setJourneyFields.add('locations_interested__c');
        setJourneyFields.add('createddate');
        setJourneyFields.add('lastmodifieddate');
        MetadataSetting__mdt objJourneyCreationMDT = Settings.getMetadataSettingByDevName('UniqueJourneyCriteria');
        if(String.isNotBlank(objJourneyCreationMDT.Data__c)){
            if(String.isNotBlank(objJourneyCreationMDT.Data__c)){
                Map<String, Set<String>> mapJourneyMatchingData = (Map<String, Set<String>>)JSON.deserialize(objJourneyCreationMDT.Data__c.toLowerCase(), Map<String, Set<String>>.class);
                if(mapJourneyMatchingData != null && mapJourneyMatchingData.get('uniquejourneycriteria') != null){
                    setJourneyFields.addAll(mapJourneyMatchingData.get('uniquejourneycriteria'));
                }
            }
        }
        return setJourneyFields;
    }

  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to get the Jounry Creation Criteria metadata
      	Created Date  		:   14 Feb 2019
        Last Modified By    :   Krishana Tupe
  *************************************************************************************************************************************/
    public static Set<String> getJourneyMatchingFields(){
        Set<String> setJourneyFields = new Set<String>();
        MetadataSetting__mdt objJourneyCreationMDT = Settings.getMetadataSettingByDevName('UniqueJourneyCriteria');
        if(String.isNotBlank(objJourneyCreationMDT.Data__c)){
            Map<String, Set<String>> mapJourneyMatchingData = (Map<String, Set<String>>)JSON.deserialize(objJourneyCreationMDT.Data__c.toLowerCase(), Map<String, Set<String>>.class);
            if(mapJourneyMatchingData != null && mapJourneyMatchingData.get('uniquejourneycriteria') != null){
                setJourneyFields.addAll(mapJourneyMatchingData.get('uniquejourneycriteria'));
            }
        }
        return setJourneyFields;
    }

 	/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to get Lead fields that are used for LeadConverterHelper
      	Created Date  		:   24 Nov 2018
        Last Modified By    :   Krishana Tupe
 	*************************************************************************************************************************************/
    public static Set<String> getLeadFields(){
        List<String> lstLeadFields = new List<String>();
        Set<String>  setLeadFields = new Set<String>();
        setLeadFields.add('id');
        setLeadFields.add('send_for_forcefully_lead_assignments__c');
        setLeadFields.add('lead_assignment_stage__c');
        setLeadFields.add('email');
        setLeadFields.add('firstname');
        setLeadFields.add('createddate');
        setLeadFields.add('bypass_lead_assignment_rules__c');
        setLeadFields.add('interested_in_number_of_desks_min__c');
        setLeadFields.add('interested_in_number_of_desks__c');
        setLeadFields.add('lastname');
        setLeadFields.add('name');
        setLeadFields.add('email_domain__c');
        setLeadFields.add('ownerid');
        setLeadFields.add('product_line__c');
        setLeadFields.add('company');
        setLeadFields.add('account__c');
        setLeadFields.add('account__r.account_type__c');
        setLeadFields.add('referrer__c');
        setLeadFields.add('cleansed_unomy_company_name__c');
        setLeadFields.add('cleansed_company_name__c');
        setLeadFields.add('unomy_company_id__c');
        setLeadFields.add('unomy_company_name__c');
        setLeadFields.add('leadsource');
        setLeadFields.add('lead_source_detail__c');
        setLeadFields.add('generate_journey__c');
        setLeadFields.add('by_pass_journey_creation_criteria__c');
        setLeadFields.add('campaign_id__c');
        setLeadFields.add('building_interested_in__c');
        setLeadFields.add('building_interested_in__r.city__c');
        setLeadFields.add('locations_interested__c');
        setLeadFields.add('number_of_full_time_employees__c');
        setLeadFields.add('company_size__c');
        setLeadFields.add('number_of_desks_2016__c');
        setLeadFields.add('markets_interested__c');
        setLeadFields.add('lead_demographic_score_adj__c');
        setLeadFields.add('lead_demographic_score__c');
        setLeadFields.add('behavioral_lead_score__c');
        setLeadFields.add('lead_demographic_score_total__c');
        setLeadFields.add('lead_demographic_score_re_calculate__c');
        setLeadFields.add('unomy_updated_datetime__c');
        setLeadFields.add('lead_demographic_score_datetime__c');
        setLeadFields.add('leadsource_sub_type__c');//ST-3222
        // Modified By Jitesh Adwani for ST-3409 on 18 February 2019
        setLeadFields.add('personal_mailing_street__c');
        setLeadFields.add('personal_mailing_city__c');
        setLeadFields.add('personal_mailing_state__c');
        setLeadFields.add('personal_mailing_country__c');
        setLeadFields.add('personal_mailing_postalcode__c');
        setLeadFields.add('bypass_processing_stage__c');
        setLeadFields.add('processing_stage__c');
        setLeadFields.add('update_hq_market_status__c');
        Settings.FieldMappings mapLeadToJourney=  Settings.getFieldMappings('LeadToJourney');
        for(Settings.MappedField field : mapLeadToJourney.mappings.values()){
            setLeadFields.add(field.fieldname.toLowerCase());
        }
        return setLeadFields;
    }

  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to find the Campaign owner according to Project Campaign Celebation functionality
      	Created Date  		:   14 Feb 2019
        Last Modified By    :   Krishana Tupe
  *************************************************************************************************************************************/
   public static Id getValidCampaignOwnerORCampaignId(Contact objContact, List<CampaignMember> lstCampaignMembers,  Map<Id, Id> mapCampaignSettings){
       Id ownerORCampaignId;
        Map<String,String> mapAPIUserInfo = (Map<String,String>)JSON.deserialize(Settings.get('APIUserContactInfo').Data__c, Map<String,String>.class);
        for(CampaignMember objCampaignMember : lstCampaignMembers){
            if(mapCampaignSettings != NULL && mapCampaignSettings.keySet().contains(objCampaignMember.CampaignId)){
                if(objCampaignMember.Campaign.EndDate == NULL || objCampaignMember.Campaign.EndDate > Date.today()){
                    ownerORCampaignId = mapCampaignSettings.get(objCampaignMember.CampaignId);
                    if(String.isBlank(ownerORCampaignId) && String.isNotBlank(objCampaignMember.CampaignId) && String.isNotBlank(objCampaignMember.Campaign.Lead_Owner__c) &&
                       (objCampaignMember.Campaign.Lead_Owner__c.startsWith('00G') || (settings.getUserActive(objCampaignMember.Campaign.Lead_Owner__c) && objCampaignMember.Campaign.Lead_Owner__c != (String.isNotBlank(mapAPIUserInfo.get('userId')) ? Id.valueOf(mapAPIUserInfo.get('userId')):  Id.valueOf('005F0000003Kmbw'))))){
                           ownerORCampaignId = objCampaignMember.Campaign.Lead_Owner__c;
                       }else if(String.isBlank(ownerORCampaignId) && settings.getUserActive(objContact.ownerId) && objContact.ownerId != (String.isNotBlank(mapAPIUserInfo.get('userId')) ? Id.valueOf(mapAPIUserInfo.get('userId')):  Id.valueOf('005F0000003Kmbw'))){
                           ownerORCampaignId = objContact.ownerId;
                       }else if(String.isBlank(ownerORCampaignId) && String.isNotBlank(objCampaignMember.CampaignId)){
                           ownerORCampaignId = objCampaignMember.CampaignId;
                       }
                }
            }
            if(String.isNotBlank(ownerORCampaignId)){
                return ownerORCampaignId;
            }
        }
        return NULL;
    }

}