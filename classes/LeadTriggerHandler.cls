/*****************************************************************************************************************************
    Author      :  Amol Darekar  
    Description :  ---
    History     :  --
    
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION                 DATE                    AUTHOR                          DETAIL
    1                   05,July 2016            Amol Darekar                    Initial Developement
    2.0                 06 June 2018            Sunil Bhosale                   Code revamp.
******************************************************************************************************************************/
public class LeadTriggerHandler extends ITriggerHandler {
   	
    //Added By Jitesh Adwani for ST-3312
    public static Journey__c objLatestModifiedJourney;
    
    public LeadTriggerHandler(){
        super('Lead');
    } 
    
 /****************************************************************************************************************************
    Author              : Amol Darekar
    Description         : This method overrides before insert method from ITriggerHander which will control the execution flow.
    Created Date        : 05,July 2016
    Last Modified By    : Prashant Mane
    Last Modified Date  : 02 Feb,2018
*****************************************************************************************************************************/    
    public override void BeforeInsert(List<SObject> listNewItems){
        Debug.log('In Before handler BeforeInsert==>'+listNewItems);        
        if(TriggerSettings.mappedField.Lead_UpdateActiveReferrerOnLead){
            updateActiveReferrerOnLead((List<Lead>)listNewItems,null,null,null);   
        }  
        
        if(TriggerSettings.mappedField.Lead_UpdateBuildingInterestOnLead){
            updateBuildingInterestOnLead((List<Lead>)listNewItems,null,null,null); 
        } 
        
        if(TriggerSettings.mappedField.Lead_BlankEmailOrPhoneOnLead){
            blankEmailOrPhoneOnLead((List<Lead>)listNewItems,null,null,null);
        }
        
        if(TriggerSettings.mappedField.Lead_UpdateRecordType){
            updateRecordType((List<Lead>)listNewItems,null,null,null);
        }
        
        if(TriggerSettings.mappedField.Lead_UpdateLeadSourceAndLeadSourceDetail){
            updateLeadSourceAndLeadSourceDetail((List<Lead>)listNewItems,null,null,null);
        }
        
        if(TriggerSettings.mappedField.Lead_UpdateCleansedName){
            updateCleansedName((List<Lead>)listNewItems);
        }
         
    }
    
/*************************************************************************************************************************
    Author              : Amol Darekar
    Description             : This method overrides before update method from ITriggerHander which will control the execution flow.
    Created Date            : 05,July 2016
    Last Modified By    : Prashant Mane
    Last Modified Date   : 02 Feb,2018
******************************************************************************************************************************/
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){       
        Debug.log('In Before handler BeforeUpdate==>'+listNewItems);
        if(TriggerSettings.mappedField.Lead_UpdateBuildingInterestOnLead){
            updateBuildingInterestOnLead((List<Lead>)listNewItems,(map<Id,Lead>)mapNewItems,(List<Lead>)listOldItems,(map<Id,Lead>)mapOldItems);
        }
        
        if(TriggerSettings.mappedField.Lead_BlankEmailOrPhoneOnLead){
            blankEmailOrPhoneOnLead((List<Lead>)listNewItems,(map<Id,Lead>)mapNewItems,(List<Lead>)listOldItems,(map<Id,Lead>)mapOldItems);
        }
        
        if(TriggerSettings.mappedField.Lead_UpdateRecordType){
            updateRecordType((List<Lead>)listNewItems,(map<Id,Lead>)mapNewItems,(List<Lead>)listOldItems,(map<Id,Lead>)mapOldItems);
        }
        
        if(TriggerSettings.mappedField.Lead_UpdateLeadOwner && !System.isFuture() && !System.isBatch()){
            updateLeadOwner((List<Lead>)listNewItems,(map<Id,Lead>)mapNewItems,(List<Lead>)listOldItems,(map<Id,Lead>)mapOldItems);                
        }
        
        if(TriggerSettings.mappedField.Lead_UpdateCleansedName){
            updateCleansedName((List<Lead>)listNewItems);
        }
        
        if(TriggerSettings.mappedField.Lead_PopulateOrganization){
            populateOrganization((List<Lead>)listNewItems,(map<Id,Lead>)mapNewItems,(List<Lead>)listOldItems,(map<Id,Lead>)mapOldItems);
        }   
        
        if(TriggerSettings.mappedField.Lead_UpdateLeadScore){
            updateLeadScore((List<Lead>)listNewItems,(map<Id,Lead>)mapNewItems,(List<Lead>)listOldItems,(map<Id,Lead>)mapOldItems);
        }  
    }
    
/*******************************************************************************************************************************
    Author              : Amol Darekar
    Description             : This method overrides after insert method from ITriggerHander which will control the execution flow.
    Created Date            : 05,July 2016
    Last Modified By    : Prashant Mane
    Last Modified Date   : 02 Feb,2018
********************************************************************************************************************************/    
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){ 
        if(TriggerSettings.mappedField.Lead_CreateDeleteBuildingInterest){
            createUpdateDeleteBuildingInterest((List<Lead>)listNewItems,(map<Id,Lead>)mapNewItems,null,null);
        }
        
        if(TriggerSettings.mappedField.Lead_ConvertLeadsToJourneys){
            convertLeadsToJourneys((List<Lead>)listNewItems,(map<Id,Lead>)mapNewItems,null,null);
        }            
    }
    
/*******************************************************************************************************************************
    Author              : Amol Darekar
    Description             : This method overrides after update method from ITriggerHander which will control the execution flow.
    Created Date            : 05,July 2016
    Last Modified By    : Prashant Mane
    Last Modified Date   : 02 Feb,2018
********************************************************************************************************************************/    
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){         
        
        if(TriggerSettings.mappedField.Lead_UpdateJourneyPrimaryContact){
            updateJourneyPrimaryContact((List<Lead>)listNewItems,(map<Id,Lead>)mapNewItems,(List<Lead>)listOldItems,(map<Id,Lead>)mapOldItems);  
        }  
        
        if(TriggerSettings.mappedField.Lead_RestartJourney){
            restartJourney((List<Lead>)listNewItems,null,null,null);
        }
        
        if(TriggerSettings.mappedField.Lead_CreateDeleteBuildingInterest){
            createUpdateDeleteBuildingInterest((List<Lead>)listNewItems,(map<Id,Lead>)mapNewItems,(List<Lead>)listOldItems,(map<Id,Lead>)mapOldItems);
        }
        
        if(TriggerSettings.mappedField.Lead_ConvertLeadsToJourneys){
            convertLeadsToJourneys((List<Lead>)listNewItems,(map<Id,Lead>)mapNewItems,(List<Lead>)listOldItems,(map<Id,Lead>)mapOldItems);  
        }
    }
    
/*******************************************************************************************************************************
    Author              : Amol Darekar
    Description         : This method overrides before delete method from ITriggerHander which will control the execution flow.
    Created Date        : 05,July 2016
    Last Modified By    : Prashant Mane
    Last Modified Date  : 02 Feb,2018
********************************************************************************************************************************/   
    public override void BeforeDelete(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){        
        if(TriggerSettings.mappedField.Lead_DeleteBuildingInterestOnLeadDelete){
            createUpdateDeleteBuildingInterest(null,null,(List<Lead>)listOldItems,(map<Id,Lead>)mapOldItems); 
        }        
        
        if(TriggerSettings.mappedField.Lead_CheckForRelatedJourney){
            CheckForRelatedJoureny(null,null,(List<Lead>)listOldItems,(map<Id,Lead>)mapOldItems);
        }
    }
    
    
  /************************************************************************************************************************************
    Author              : Amol Darekar
    Description         : Update The Building Interest On Lead.
    Created Date        : 05 july, 2016
    Last Modified By    : Sunil Bhosale
    Last Modified Date  : 06 June 2018
    Issue No            : ST-2493
    Description         : code optimisation and naming conventions
**************************************************************************************************************************************/
    public static void updateBuildingInterestOnLead(List<Lead> listNewItems,Map<Id, Lead> mapNewItems,List<Lead> listOldItems,Map<Id, Lead> mapOldItems){       
        Set<String> allBuildings = new Set<String>();
        List<Building__c> buildingsList = new List<Building__c>();
        Map<String, Id> allBuildingsMap = new Map<String, Id>();
        for(Lead leadRec : listNewItems){
            if(leadRec.Locations_Interested__c != null)
                allBuildings.add(leadRec.Locations_Interested__c.split(';')[0]);
        }
        if(allBuildings != null && allBuildings.size() > 0){
            for(Building__c building : BuildingHandler.getSpecificBuildings(allBuildings)){
                allBuildingsMap.put(building.Name,building.Id);
            }
            if(allBuildingsMap.size() > 0){
                for(Lead leadRec : listNewItems){
                    if(leadRec.Locations_Interested__c != null){
                        if(leadRec.Building_Interested_In__c == null && allBuildingsMap.containsKey(leadRec.Locations_Interested__c.split(';')[0]))
                            leadRec.Building_Interested_In__c = allBuildingsMap.get(leadRec.Locations_Interested__c.split(';')[0]);
                    }
                }
            }
        }
    }    
    
 /************************************************************************************************************************************
    Author              : Mayuresh Ghodke
    Description         : When Lead gets converted, we need to set the Contact person on the Journey as a "Primary Contact".
    Created Date        : 28 july, 2016
    Last Modified By    : Mayuresh Ghodke
**************************************************************************************************************************************/
    public static void updateJourneyPrimaryContact(List<Lead> listNewItems,Map<Id, Lead> mapNewItems,List<Lead> listOldItems,Map<Id, Lead> mapOldItems){       
        Set<Id> setConvertedLeadIds = new Set<Id>();
        for(Lead objLead : listNewItems){
            if(objLead.IsConverted && !(mapOldItems.get(objLead.Id).IsConverted)){
                setConvertedLeadIds.add(objLead.Id);
            }
        }
        if(!setConvertedLeadIds.isEmpty()){
            List<sObject> lstRecordsToUpdate = new List<sObject>();
            List<Lead> lstJourneyRelatedLeads = new List<Lead>([SELECT Id, ConvertedContactId, (SELECT Id, Primary_contact__c, Primary_Lead__c, Status__c, Building_Interested_In__c FROM Journeys__r ORDER BY LastModifiedDate DESC), (SELECT Id, Status, WhatId FROM Tasks WHERE Status <> 'Completed') FROM Lead WHERE Id IN : setConvertedLeadIds]);
            
            //Added By Jitesh Adwani for ST-3312
            objLatestModifiedJourney = lstJourneyRelatedLeads[0].Journeys__r.size() > 0 ? lstJourneyRelatedLeads[0].Journeys__r[0] : null;
            
            for(Lead objLeadRec : lstJourneyRelatedLeads){
                Journey__c objJourney = objLeadRec.Journeys__r.size() > 0 ? objLeadRec.Journeys__r[0] : null;              
                for(Journey__c objJourneyRec : objLeadRec.Journeys__r){                    
                    objJourneyRec.Primary_contact__c = objLeadRec.ConvertedContactId;
                    objJourneyRec.Primary_Lead__c = null;
                    lstRecordsToUpdate.add(objJourneyRec);
                }
                for(Task objTaskRec : objLeadRec.Tasks){
                    if(objJourney != null){
                        objTaskRec.Status = 'Completed';
                        objTaskRec.WhatId = objJourney.Id;
                        lstRecordsToUpdate.add(objTaskRec);
                    }
                }
            }
            if(!lstRecordsToUpdate.isEmpty()){
                update lstRecordsToUpdate;
            }
        }
    }     
    
 
  /************************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : Create, Update, Delete Building Interest on lead.
        Created Date        : 24 September
  **************************************************************************************************************************************/ 
    public static void createUpdateDeleteBuildingInterest(List<Lead> listNewItems,Map<Id, Lead> mapNewItems,List<Lead> listOldItems,Map<Id, Lead> mapOldItems){
        Set<Id> setLeadIds = new Set<Id>();
        for(Lead leadRec : listNewItems != null ? listNewItems : listOldItems){
            if((mapOldItems == null && leadRec.Locations_Interested__c != null) || (mapOldItems != null && listNewItems == null && leadRec.Locations_Interested__c != null) || (mapOldItems != null && (leadRec.Locations_Interested__c != mapOldItems.get(leadRec.Id).Locations_Interested__c || leadRec.Office_Type__c != mapOldItems.get(leadRec.Id).Office_Type__c))){
                setLeadIds.add(leadRec.Id);
            }
        }
        if(setLeadIds.size() > 0){
            Map<String, Building__c> mapBuildingWithName = new Map<String, Building__c>();
            for(Building__c buildingRec : Settings.getAllBuildings()){
                mapBuildingWithName.put(buildingRec.Name.toLowerCase(), buildingRec);
            }
            Map<Id,Building__c> mapBuildings = Settings.mapBuildingById;
            Debug.Log('Map---'+mapBuildingWithName);
            if(mapBuildings != null && mapBuildings.size() > 0){
                List<Lead> lstLeads = new List<Lead>();
                List<Building_Interest__c> lstBuildingInterestedToUpsert = new List<Building_Interest__c>();
                List<Building_Interest__c> lstBuildingInterestedToDelete = new List<Building_Interest__c>();
                if(mapOldItems != null){
                    lstLeads.addAll([SELECT Id, Locations_Interested__c, Office_Type__c, (SELECT Id, Name, Building__c, Office_Type__c FROM Building_Interest__r) FROM Lead WHERE IsConverted = false AND Id IN : setLeadIds]);
                }else{
                    lstLeads.addAll(listNewItems);
                }
                for(Lead leadRec : lstLeads){
                    if(listNewItems != null && String.isNotBlank(leadRec.Locations_Interested__c)){
                        Set<String> setLocations = new Set<String>();
                        setLocations.addAll(leadRec.Locations_Interested__c.toLowerCase().split(';'));
                        Debug.log('setLocations-->'+setLocations);
                        if(mapOldItems != null && leadRec.Building_Interest__r.size() > 0){
                            for(Building_Interest__c buildingInterested : leadRec.Building_Interest__r){
                                if(mapBuildings.get(buildingInterested.Building__c) != null && setLocations.contains(mapBuildings.get(buildingInterested.Building__c).Name.toLowerCase())){
                                    if(buildingInterested.Office_Type__c != leadRec.Office_Type__c){
                                        lstBuildingInterestedToUpsert.add(new Building_Interest__c(Id=buildingInterested.Id, Office_Type__c=leadRec.Office_Type__c));
                                    }
                                    setLocations.remove(mapBuildings.get(buildingInterested.Building__c).Name.toLowerCase());
                                }else{
                                    lstBuildingInterestedToDelete.add(buildingInterested);
                                }
                            }
                            if(setLocations.size() > 0){
                                for(String location : setLocations){
                                    if(mapBuildingWithName.get(location) != null){
                                        lstBuildingInterestedToUpsert.add(new Building_Interest__c(Lead__c = leadRec.Id, Building__c=mapBuildingWithName.get(location).Id, Office_Type__c=leadRec.Office_Type__c));
                                    }
                                }
                            }
                        }else if(setLocations.size() > 0){
                            for(String location : setLocations){
                                if(mapBuildingWithName.get(location) != null){
                                    lstBuildingInterestedToUpsert.add(new Building_Interest__c(Lead__c = leadRec.Id, Building__c=mapBuildingWithName.get(location).Id, Office_Type__c=leadRec.Office_Type__c));
                                }
                            }
                        }
                    }else if(mapOldItems != null && leadRec.Building_Interest__r.size() > 0){
                        lstBuildingInterestedToDelete.addAll(leadRec.Building_Interest__r);
                    }
                }
                if(lstBuildingInterestedToUpsert.size() > 0){
                    upsert lstBuildingInterestedToUpsert;
                }
                if(lstBuildingInterestedToDelete.size() > 0){ 
                    delete lstBuildingInterestedToDelete;
                } 
            }
            
        }
    }
   
 /************************************************************************************************************************************
    Author              : Dipak Pawar
    Description             : Delete Lead if Email or Phone is blank.
    Created Date            : 14,July 2016
    Last Modified By    : Prashant Mane
    Last Modified Date   : 02 Feb,2018
**************************************************************************************************************************************/ 
    public static void blankEmailOrPhoneOnLead(List<Lead> listNewItems,Map<Id, Lead> mapNewItems,List<Lead> listOldItems,Map<Id, Lead> mapOldItems) {       
        for(Lead currentLead : listNewItems){
            if((currentLead.Email == null || currentLead.Email == '') && (currentLead.Phone == null || currentLead.Phone == '')){
                currentLead.addError('Email and Phone cannot be blank on Lead.');
            }
        }  
    }
    
/************************************************************************************************************************************
    Author              : Amol Darekar.
    Description         : This method get active Referrence record and set Referrer__c field value of lead based on lead email Id.
    Created Date        : 19,July 2016.
    Issue No.           : ST-352
    Last Modified By    : Sunil Bhosale
    Last Modified Date  : 06 June 2018
    Issue No.           : ST-2493   
    Comment             : code otimisation                        
**************************************************************************************************************************************/ 
    public static void updateActiveReferrerOnLead(List<Lead> listNewItems,Map<Id, Lead> mapNewItems,List<Lead> listOldItems,Map<Id, Lead> mapOldItems){
        set<string> setLeadEmails = new set<string>();
        map<string,Id> mapActiveReference = new map<String,Id>();
        for(Lead currentLead : listNewItems){
            if(!string.isBlank(currentLead.Email))
                setLeadEmails.add(currentLead.Email);
        } 
        if(!setLeadEmails.isEmpty())
            mapActiveReference = ReferenceHandler.getActiveReference(setLeadEmails);
        if(mapActiveReference != null && mapActiveReference.size() > 0){
            for(Lead currentLead : listNewItems){
                if(!string.isBlank(currentLead.Email) && mapActiveReference.containsKey(currentLead.Email.toLowerCase()))
                    currentLead.Referrer__c = mapActiveReference.get(currentLead.Email.toLowerCase());
            }   
        }  
    }    
    
/************************************************************************************************************************************
    Author              : Anant Kumar
    Description             : Method For Restrart Journey.
    Created Date            : 24,Aug 2016.
    Issue No.           : ST-622
    Last Modified By    : Sunil Bhosale
    Last Modified Date   : 03 June,2018
**************************************************************************************************************************************/ 
    public static void restartJourney(List<Lead> listNewItems,Map<Id, Lead> mapNewItems,List<Lead> listOldItems,Map<Id, Lead> mapOldItems){
        set<Id> setLeadIds = new set <Id>();
        List<Sobject> lstObjectsToUpdate = new List<Sobject>();
        List<Sobject> lstjourneyToInsert = new List<Sobject>();
        String strQuery;
        for(Lead lead : listNewItems){
            if(lead.Restart_Journey__c != null && lead.Restart_Journey__c == true)
                setLeadIds.add(lead.Id);
        }
        if(setLeadIds != null && !setLeadIds.isEmpty()){
            Settings.FieldMappings mapLeadToJourney = Settings.getFieldMappings('LeadToJourney');
            if(mapLeadToJourney != null){
                strQuery = 'SELECT Name, LeadSource,OwnerId,';
                for(Settings.MappedField field : mapLeadToJourney.mappings.values()){
                    if(!strQuery.contains(field.fieldname))
                        strQuery += field.fieldname + ',';
                }
                strQuery = strQuery.removeEnd(',');
                strQuery += ' , Building_Interested_In__r.City__c, (SELECT Status__c, LastModifiedDate, NMD_Next_Contact_Date__c, Building_Interested_In__c FROM Journeys__r where Status__c = \'Started\' Order By LastModifiedDate DESC) FROM Lead WHERE Id IN :setLeadIds';
                Debug.Log('strQuery'+strQuery);
            }
            if(strQuery != null && strQuery != ''){
                for(Lead lead : Database.Query(strQuery)){
                    if(lead.Journeys__r == null || lead.Journeys__r.size() == 0){// No Started Journey is present on Lead 
                        Journey__c journey = new Journey__c();
                        journey.NMD_Next_Contact_Date__c = Date.today();
                        journey.Primary_Lead__c = lead.Id;
                        journey.OwnerId = lead.OwnerId;
                        journey.Status__c = 'Started';
                        for(String strKey : mapLeadToJourney.mappings.keySet()){
                            journey.put(strKey, lead.get(mapLeadToJourney.mappings.get(strKey).fieldname));
                        }
                        if(lead.Building_Interested_In__c != null && String.isNotBlank(lead.Building_Interested_In__r.city__c) ){
                            journey.Name = journey.Name +'-'+lead.Building_Interested_In__r.city__c ;
                        }
                        if(String.isNotBlank(lead.LeadSource))
                            journey.Name = journey.Name +'-'+lead.LeadSource;
                        
                        lstjourneyToInsert.add(journey);                       
                    }else{                       
                        for(Journey__c journeyRec : lead.Journeys__r){                            
                            journeyRec.NMD_Next_Contact_Date__c = Date.today();
                            lstObjectsToUpdate.add(journeyRec);
                        }
                    }
                    lead.Restart_Journey__c = false;
                    lstObjectsToUpdate.add(lead);
                }
            }
            Debug.Log('lstObjectsToUpdate =>'+lstObjectsToUpdate);
            Debug.Log('lstjourneyToInsert =>'+lstjourneyToInsert);
            if(lstObjectsToUpdate.size () > 0){
                update  lstObjectsToUpdate;
            }
            if(lstjourneyToInsert.size () > 0){
                insert lstjourneyToInsert;
            } 
        }
    }
    
 /************************************************************************************************************************************
    Author              : Mayuresh Ghodke
    Description         : Before delete check that Lead having any Joureny or not. If that lead contains joureny then give error.
    Created Date        : 11 Nov, 2016.
    Issue No.           : ST-736
    Last Modified By    : Prashant Mane
    Last Modified Date  : 02 Feb,2018
**************************************************************************************************************************************/ 
    public static void CheckForRelatedJoureny(List<Lead> listNewItems,Map<Id, Lead> mapNewItems,List<Lead> listOldItems,Map<Id, Lead> mapOldItems){
        List<Journey__c> lstJourney = [Select Id, Name, Primary_Lead__c From Journey__c Where Primary_Lead__c IN : listOldItems];
        Map<Id,Journey__c> mapJourney = new Map<Id,Journey__c>();
        for(Journey__c objJourney : lstJourney)
            mapJourney.put(objJourney.Primary_Lead__c,objJourney);
        for(Lead objLead : listOldItems)
            if(mapJourney.containsKey(objLead.Id))
            objLead.Email.addError('You cannot delete the Lead associated with one or more Journeys.'); 
    }
    
/************************************************************************************************************************************
    Author              : Mayuresh Ghodke
    Description         : This method is used to update the record type of lead based on Number_of_Full_Time_Employees__c and UnomyCompanySize.
    Trigger             : Before insert/ After Insert
    Created Date        : 05 April, 2016.
    Last Modified By    : Sunil Bhosale
    Last Modified Date  : 05 June ,2018
    Description         : code optimisation and naming  conventions
**************************************************************************************************************************************/ 
    public static void updateRecordType(List<Lead> listNewItems,Map<Id, Lead> mapNewItems,List<Lead> listOldItems,Map<Id, Lead> mapOldItems){        
        Map<String,Schema.RecordTypeInfo> mapLeadRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByName();
        Setting__c accountRecordTypeSettings = Settings.get('AccountRecordTypeSettings');
        List<RecordTypeSize> recordTypeSettings =  new List<RecordTypeSize>();
        if(accountRecordTypeSettings != null){
            recordTypeSettings = (List<RecordTypeSize>)JSON.deserialize(accountRecordTypeSettings.Data__c ,List<RecordTypeSize>.class);                 
        }
        if(recordTypeSettings!=null){ 
            for(Lead objLead :listNewItems){
                Integer UnomyCompanySize = null;
                if(objLead.Unomy_Company_Size__c != null)
                    UnomyCompanySize = LeadTriggerHandler.getUnomyCompanySize(objLead.Unomy_Company_Size__c);
                sObject oldVal;
                if(Trigger.isUpdate)
                    oldVal = mapOldItems.get(objLead.Id);
                if(Trigger.isInsert || (Trigger.isUpdate && oldVal.get('RecordTypeId') == mapLeadRecordType.get('Consumer').getRecordTypeId())){
                    for(RecordTypeSize currentRecordType : recordTypeSettings){
                        if(currentRecordType.RecordType != 'Consumer'){
                            if(UnomyCompanySize != null){
                                If(currentRecordType.Size.contains('-') && UnomyCompanySize <= Integer.valueOf(currentRecordType.Size.split('-')[1]) && UnomyCompanySize >= Integer.valueOf(currentRecordType.Size.split('-')[0]))
                                    objLead.RecordTypeId = mapLeadRecordType.get(currentRecordType.RecordType).getRecordTypeId();
                                else If(currentRecordType.Size.contains('+') && UnomyCompanySize >= Integer.valueOf(currentRecordType.Size.removeEnd('+')))
                                    objLead.RecordTypeId = mapLeadRecordType.get(currentRecordType.RecordType).getRecordTypeId();
                            }
                            else if(objLead.Number_of_Full_Time_Employees__c != null){             
                                If(currentRecordType.Size.contains('-') && objLead.Number_of_Full_Time_Employees__c <= Integer.valueOf(currentRecordType.Size.split('-')[1]) && objLead.Number_of_Full_Time_Employees__c >= Integer.valueOf(currentRecordType.Size.split('-')[0]))
                                    objLead.RecordTypeId = mapLeadRecordType.get(currentRecordType.RecordType).getRecordTypeId();
                                else If(currentRecordType.Size.contains('+') && objLead.Number_of_Full_Time_Employees__c >= Integer.valueOf(currentRecordType.Size.removeEnd('+')))
                                    objLead.RecordTypeId = mapLeadRecordType.get(currentRecordType.RecordType).getRecordTypeId();
                                
                            }
                        }
                    }
                }                
            }
        }
    }
    
    public class RecordTypeSize {
        public String Size {get;set;}
        public String RecordType {get;set;}
    }
    
 /************************************************************************************************************************************
    Author              : Mayuresh Ghodke
    Description             : This Method Used To get UnomyCompanySize
    Created Date            : 05,July 2016.
    Last Modified By    : Prashant Mane
    Last Modified Date   : 02 Feb,2018
**************************************************************************************************************************************/ 
    public static Integer getUnomyCompanySize(String UnomyCompanySize){        
        if(UnomyCompanySize.contains(','))
            UnomyCompanySize = UnomyCompanySize.replace(',','');
        Integer strtRangeVal = null;
        Boolean containsUpperRange = UnomyCompanySize.contains('-');
        Boolean containsLowerRange = UnomyCompanySize.contains('+');
        if(containsUpperRange){
            String[] range = UnomyCompanySize.split('-');                    
            if(range.Size() > 1){
                String[] strtRange = range[0].split(' ');
                if(strtRange[0] != '')
                    strtRangeVal = Integer.valueof(strtRange[0]);
                else
                    strtRangeVal = Integer.valueof(strtRange[1]);
            }
            else{
                String lastRange = range[0].substring(0,range[0].length()-1);
                strtRangeVal = Integer.valueof(lastRange);  
            }
        }
        else if(containsLowerRange) {
            String range = UnomyCompanySize; 
            range = range.removeEnd('+');
            strtRangeVal = Integer.valueof(range);
        }
        else
            strtRangeVal = Integer.valueof(UnomyCompanySize);
        return strtRangeVal;  
    }
    
    public class EnterpriseSettingsRecord {
        public List<EnterpriseLandingSettings> EnterpriseLandingSettings;
        public EnterpriseLeadSettings EnterpriseLeadSettings;
    }
    
 /************************************************************************************************************************************
    Author              : Mayuresh Ghodke
    Description         : This method is used to update Cleansed Company Name and Cleansed Unomy Company Name 
    Created Date        : 05,July 2016.
    Last Modified By    : Prashant Mane
    Last Modified Date  : 02 Feb,2018
**************************************************************************************************************************************/ 
    public static void updateCleansedName(List<Lead> listNewItems){
        for(Lead lead:listNewItems){
            if(String.isNotBlank(lead.Company)){
                lead.Cleansed_Company_Name__c = OrganizationHelper.getCleansedName(lead.Company);
            }else if(String.isNotBlank(lead.Name)){
                lead.Cleansed_Company_Name__c = OrganizationHelper.getCleansedName(lead.Name);
            }else{
                lead.Cleansed_Company_Name__c = OrganizationHelper.getCleansedName(lead.LastName);
            }
            if(String.isNotBlank(lead.Unomy_Company_Name__c)){
                lead.Cleansed_Unomy_Company_Name__c = OrganizationHelper.getCleansedName(lead.Unomy_Company_Name__c);
            }    
        }  
    }
    
 /************************************************************************************************************************************
    Author              : Krishna Tupe
    Description         : Update lead owner to Building => Cluster => Sales Lead When lead is assigned to specific Queue.
    Created Date        : 10,Nov 2017
    Last Modified By    : Sunil Bhosale
    Last Modified Date  : 11 June ,2018
    Description         : code optimisation , Removed future metod.
    Issue No.           : ST-2493
   **************************************************************************************************************************************/    
    static Map<Id, Lead> mapLeadWithJourney = new Map<Id, Lead>();
    public static void updateLeadOwner(List<Lead> listNewItems,Map<Id, Lead> mapNewItems,List<Lead> listOldItems,Map<Id, Lead> mapOldItems){ 
        Set<Id> setLeadIdsForOwnerChange = new Set<Id>();
        Set<String> setQueueIds = new Set<String>();
        Setting__c referralQueueSetting = Settings.get('Referral Queue');
        if(referralQueueSetting != null){
            setQueueIds = (Set<String>)(JSON.deserialize(referralQueueSetting.Data__c.toLowerCase(), Set<String>.class));
        }       
        for(Lead leadRec : listNewItems){
            if(setQueueIds.contains(String.valueOf(leadRec.OwnerId).toLowerCase().substring(0,15))){
                setLeadIdsForOwnerChange.add(leadRec.Id);
            }
        }
        map<Id,Sobject> mapSobjectToUpdate = new map<Id,Sobject>();
        Setting__c APIUserContactInfo = new Setting__c();
        APIUserContactInfo = Settings.get('APIUserContactInfo');
        LeadTriggerHandler.APIUserContactInfoSetting settingData = new LeadTriggerHandler.APIUserContactInfoSetting();
        if(APIUserContactInfo != null){
            settingData = (APIUserContactInfoSetting)JSON.deserialize(APIUserContactInfo.Data__c, APIUserContactInfoSetting.class);
        }       
        LeadTriggerHandler.UnassignedNMDUSQueue objUnassignedNMDUSQueueData = new LeadTriggerHandler.UnassignedNMDUSQueue();
        Setting__c objUnassignedNMDUSQueue = new Setting__c();
        objUnassignedNMDUSQueue = Settings.get('Unassigned NMD US Queue');
        if(objUnassignedNMDUSQueue != null ){
            objUnassignedNMDUSQueueData = (UnassignedNMDUSQueue)JSON.deserialize(objUnassignedNMDUSQueue.Data__c, UnassignedNMDUSQueue.class); 
        } 
        if(!setLeadIdsForOwnerChange.isEmpty() && !setQueueIds.isEmpty()){           
            if(!mapLeadWithJourney.keySet().containsAll(mapNewItems.keySet())){
                mapLeadWithJourney.clear();
                mapLeadWithJourney.putAll(new Map<Id, Lead>([SELECT Id,Building_Interested_In__r.Cluster__r.Sales_Lead__c,OwnerId,(select id,OwnerId,status__c from Journeys__r where status__c != 'Completed') From Lead WHERE Id IN : mapNewItems.keySet()]));
            }          
            Lead objLead;
            Lead lead;
            for(Id leadId : setLeadIdsForOwnerChange){
                objLead = mapNewItems.get(leadId);
                lead = mapLeadWithJourney.get(objLead.Id);
                if(lead != null && objLead != null && setQueueIds.contains(String.valueOf(objLead.OwnerId).toLowerCase().substring(0,15))){
                    List<Journey__c> lstJourneies = lead.journeys__r;
                    for(Journey__c journey : lstJourneies){
                        if(lead.Building_Interested_In__c !=null && lead.Building_Interested_In__r.Cluster__c !=null && lead.Building_Interested_In__r.Cluster__r.Sales_Lead__c !=null && Settings.getUserActive(lead.Building_Interested_In__r.Cluster__r.Sales_Lead__c) && journey.OwnerId == mapOldItems.get(lead.Id).OwnerId){
                            journey.OwnerId = lead.Building_Interested_In__r.Cluster__r.Sales_Lead__c; 
                            objLead.OwnerId = lead.Building_Interested_In__r.Cluster__r.Sales_Lead__c; 
                        }else if(journey.OwnerId == mapOldItems.get(lead.Id).OwnerId){
                            if(settingData != null)
                                objLead.OwnerId = settingData.UserId; 
                            if(objUnassignedNMDUSQueueData != null)
                                journey.OwnerId = Id.valueof(objUnassignedNMDUSQueueData.UnassignedNMDUSQueue[0])  ; 
                        }
                        mapSobjectToUpdate.put(journey.Id, journey);
                    }
                }
            }
            Debug.Log('mapSobjectToUpdate'+mapSobjectToUpdate);
            if(mapSobjectToUpdate.size() > 0 ){
                update mapSobjectToUpdate.values();    
            }
        }
    }
    
    public static Map<Id,Lead> mapLeadsEmailChanged = new Map<Id,Lead>(); 
    public static void convertLeadsToJourneys(List<Lead> listNewItems,Map<Id, Lead> mapNewItems,List<Lead> listOldItems,Map<Id, Lead> mapOldItems){
        List<Lead> lstLeads = new List<Lead>();
        for(Lead objLead : listNewItems){
            if(Trigger.isInsert || (Trigger.isUpdate && !objLead.isConverted && objLead.Email!=mapOldItems.get(objLead.Id).Email)){
                lstLeads.add(new Lead(Id = objLead.Id, Email = objLead.Email, Campaign_Id__c = objLead.Campaign_Id__c ));
                if(Trigger.isUpdate){
                    LeadConverterHelper.isInsert = false;
                    LeadConverterHelper.isCreateActivity = false;
                    mapLeadsEmailChanged.put(objLead.Id,objLead);
                }                
            }
        }        
        if(lstLeads.size() > 0){
            LeadConverterHelper.manageLead(lstLeads);
        }
    }
    
    public static void populateOrganization(List<Lead> listNewItems,Map<Id, Lead> mapNewItems,List<Lead> listOldItems,Map<Id, Lead> mapOldItems){
        List<Lead> lstLeadsToFindOrg = new List<Lead>();
        for(Lead objLead:listNewItems){
            if(String.isBlank(objLead.Account__c) && objLead.Unomy_Updated_DateTime__c!=null && objLead.Unomy_Updated_DateTime__c!=mapOldItems.get(objLead.Id).Unomy_Updated_DateTime__c){
                lstLeadsToFindOrg.add(objLead);
            }
        }       
        if(lstLeadsToFindOrg.size()>0){
            Map<Id,Id> mapOrgs = OrganizationHelper.findRelatedOrg(lstLeadsToFindOrg);
            for(Lead objLead:listNewItems){
                if(mapOrgs.containsKey(objLead.Id) && mapOrgs.get(objLead.Id)!=null){
                    objLead.Account__c = mapOrgs.get(objLead.Id);
                }
            }
        }
    }
    
 /************************************************************************************************************************************
        Author              :   Shivprasad Patil
        Description         :   This method update Lead Source and Lead Source detail according to unomy data.
        Created Date        :   17 July 2018
        Issue No            :   ST-2659
    **************************************************************************************************************************************/  
    public static void updateLeadSourceAndLeadSourceDetail(List<Lead> lstNewLeads,Map<Id,Lead> mapNewLeads,List<Lead> lstOldLeads,Map<Id,Lead> mapOldLeads){
        for(Lead objLead : lstNewLeads){
            if(checkChangeInFieldValue('utm_source__c',objLead,mapOldLeads) && objLead.utm_source__c.toLowerCase() == 'partner'){
                objLead.LeadSource = 'Partner Referral';
                objLead.Lead_Source_Detail__c = objLead.utm_medium__c;
            }
        }
    }
    
  /************************************************************************************************************************************
        Author              :   Shivprasad Patil
        Description         :   This method checks if specific field is changed in trigger context.
        Created Date        :   25 July 2018
        Issue No            :   -
  **************************************************************************************************************************************/  
    public static boolean checkChangeInFieldValue(String fieldName, Lead objNewLead, Map<Id,Lead> mapOldLeads){
        //for Insert context
        if(mapOldLeads == null || mapOldLeads.size() == 0){
            if(String.isNotBlank((String)objNewLead.get(fieldName))){
                return true;
            }else{
                return false; 
            } 
        }
        //for Update context
        if(String.valueOf(objNewLead.get(fieldName)) != String.valueOf(mapOldLeads.get(objNewLead.Id).get(fieldName))){
            return true;
        }
        return false;
    }
    
  /************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This method is used to update lead score on lead after unomy enrichment
        Created Date        :   14 Aug 2018
        Issue No            :   CSI-1150,CSI-1288
        Modified Date       :   04 Oct 2018
        Modified By         :   Samadhan Kadam
 **************************************************************************************************************************************/  
    public static void updateLeadScore(List<Lead> listNewItems,Map<Id, Lead> mapNewItems,List<Lead> listOldItems,Map<Id, Lead> mapOldItems){
        Set<string> setOfLeadsource = new Set<string>();
        Set<string> setOfLeadsourceDetail = new Set<string>();
        List<Lead> lstUnomyUpdatedLeads = new List<Lead>();
        Map<String, Map<String,set<String>>> mapOfLeadScoreSetting = new Map<String, Map<String,set<String>>>();
        List<Map<String,Set<String>>> lstRules;
        Setting__c objSettings = Settings.get('LeadScoreMechanismSetting');
        if(objSettings == null){
            return;   
        } 
        Setting__c leadSourceDetailSetting = Settings.get('LeadScoreMechanismForLeadSourceDetail');
        if(leadSourceDetailSetting != null){
            lstRules = (List<Map<String,Set<String>>>)JSON.deserialize(leadSourceDetailSetting.Data__c.toLowerCase(), List<Map<String,Set<String>>>.class);        
        }        
        mapOfLeadScoreSetting = (Map<String, Map<String,set<String>>>) JSON.deserialize(objSettings.Data__c, Map<String, Map<String,set<String>>>.class);
        Map<String, Set<String>> mapOfLeadSource = mapOfLeadScoreSetting.get('LeadSource');       
        Set<String> setLocationInterestedInLead = new Set<String>();
        Set<String> setProcessingStages = new Set<String>{'created', 'market identified', 'assignment complete', 'behavioural scored'};
        for(Lead leadRec : listNewItems){  
            if((mapOldItems.get(leadRec.Id).Unomy_Updated_DateTime__c != leadRec.Unomy_Updated_DateTime__c) && (String.isBlank(leadRec.Processing_Stage__c) || leadRec.Processing_Stage__c.equalsIgnoreCase('Created'))){
                leadRec.Processing_Stage__c = 'Enriched'; 
            } 
            if((mapOldItems.get(leadRec.Id).Unomy_Updated_DateTime__c != leadRec.Unomy_Updated_DateTime__c) || (leadRec.Lead_Demographic_Score_Re_calculate__c &&  mapOldItems.get(leadRec.Id).Lead_Demographic_Score_Re_calculate__c != leadRec.Lead_Demographic_Score_Re_calculate__c)){            
                leadRec.Lead_Demographic_Score_DateTime__c = System.now();
                leadRec.Lead_Demographic_Score_Re_calculate__c = false; 
                if((String.isBlank(leadRec.Processing_Stage__c) || (!setProcessingStages.contains(leadRec.Processing_Stage__c.toLowerCase())))){
                    leadRec.Processing_Stage__c = 'Demographic Scored';  
                }
                lstUnomyUpdatedLeads.add(leadRec);
                setOfLeadsource.add(getAggregateLeadSource(leadRec, mapOfLeadSource));
                if(lstRules != null){
                    setOfLeadsourceDetail.add(getAggregateLeadSourceDetail(leadRec,lstRules));
                }
                if(String.isNotBlank(leadRec.Building_Interested_Name__c)){
                    setLocationInterestedInLead.add(leadRec.Building_Interested_Name__c.split('-')[0].toLowerCase());
                }
            } 
        }       
        Set<String> setAggregatedLocationsFromLeadScoreTable = new Set<String>();
        Map<string,Lead_Score_Table__c> mapOfLeadScore;
        if(setOfLeadsource.size() > 0 && setOfLeadsourceDetail.size() > 0){
            mapOfLeadScore = createMapOfLeadScore(setOfLeadsource, setOfLeadsourceDetail, setLocationInterestedInLead,setAggregatedLocationsFromLeadScoreTable);             
        }        
        if(mapOfLeadScore != null){
            mapLeadScoreToLead(lstUnomyUpdatedLeads, mapOfLeadSource, mapOfLeadScore, lstRules,setAggregatedLocationsFromLeadScoreTable, mapOfLeadScoreSetting);  
        }  
    }
    
/****************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This method is used to get all aggregate and assign lead demographic score with matching records
        Created Date        :   08 Oct 2018
        Issue No            :   CSI-1150,CSI-1288
*****************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************/
    public static void mapLeadScoreToLead(List<Lead> lstUnomyUpdatedLeads, Map<String, Set<String>> mapOfLeadSource, Map<string,Lead_Score_Table__c> mapOfLeadScore, List<Map<String,Set<String>>> lstRules,set<String> setAggregatedLocationsFromLeadScoreTable, Map<String, Map<String,set<String>>> mapOfLeadScoreSetting){
        if(mapOfLeadScore != null && !mapOfLeadScore.isEmpty()){
            Lead_Score_Table__c leadScoreValue;
            Map<String,Object> mapAggregatedFieldValues;
            String leadScoreAttributes;
            Set<String> setLocationInterestedInLead = new Set<String>();
            Map<String, Set<String>> mapOfInterestedNumberOfDesks = (Map<String, Set<String>>) mapOfLeadScoreSetting.get('InterestedNumberOfDesks');
            Map<String, Set<String>> mapOfUnomycompanySize = (Map<String, Set<String>>) mapOfLeadScoreSetting.get('UnomyCompanySize');
            Map<String, Set<String>> mapOfLocationInterested = (Map<String, Set<String>>) mapOfLeadScoreSetting.get('LocationInterested');
            Set<String> setLeadFieldValues = new Set<String>{'LeadSource','Lead_Source_Detail__c','Unomy_Company_Size__c','Building_Interested_Name__c','Range_For_Interested_Number_Of_Desk__c'};
                for(Lead leadRec : lstUnomyUpdatedLeads){
                    mapAggregatedFieldValues = new Map<String,Object>();                    
                    mapAggregatedFieldValues.put('LeadSource',getAggregateLeadSource(leadRec, mapOfLeadSource));  
                    mapAggregatedFieldValues.put('Lead_Source_Detail__c',getAggregateLeadSourceDetail(leadRec, lstRules));
                    if(String.isNotBlank(leadRec.Building_Interested_Name__c)){
                        mapAggregatedFieldValues.put('Building_Interested_Name__c',getAggregateLocation(leadRec, setAggregatedLocationsFromLeadScoreTable));
                    }
                    if(String.isNotBlank(leadRec.Range_For_Interested_Number_Of_Desk__c)){
                        mapAggregatedFieldValues.put('Range_For_Interested_Number_Of_Desk__c',getAggregateInterestedNumofDesk(leadRec, mapOfInterestedNumberOfDesks));
                    }
                    if(String.isNotBlank(leadRec.Unomy_Company_Size__c)){
                        mapAggregatedFieldValues.put('Unomy_Company_Size__c',getAggregateUnomySize(leadRec, mapOfUnomycompanySize));
                    }                    
                    leadScoreAttributes = createAttribute(leadRec,setLeadFieldValues,mapAggregatedFieldValues,setAggregatedLocationsFromLeadScoreTable);
                    leadRec.Lead_Demographic_Score_DateTime__c = system.now();
                    if(mapOfLeadScore.containsKey(leadScoreAttributes)){
                        leadScoreValue = mapOfLeadScore.get(leadScoreAttributes);
                        checkNullAndMapLeadScore(leadScoreValue, leadRec);
                    }                    
                }
        }
    }   
    
/************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This method is used to create attribute and used for create map of lead score
        Created Date        :   09 Oct 2018
        Issue No            :   CSI-1150,CSI-1288
**************************************************************************************************************************************/  
    public static string createAttribute(sObject objRec, set<String> setFields, Map<String,Object> mapAggregatedFieldValues,set<string> setAggregatedLocationsFromLeadScoreTable){
        String attribute;
        Set<String> setLocationInterestedInLead = new set<string>(); 
        List<String> lstAttributes = new List<String>();
        for(String fieldName: setFields){
            if(String.isBlank(String.valueOf(objRec.get(fieldName))) && !fieldName.equalsIgnoreCase('LeadSource') && !fieldName.equalsIgnoreCase('Lead_Source_Detail__c')){
                lstAttributes.add('null'); 
            }else{
                if(mapAggregatedFieldValues != null && mapAggregatedFieldValues.get(fieldName) != null){
                    lstAttributes.add(String.valueOf(mapAggregatedFieldValues.get(fieldName)));  
                }else if(mapAggregatedFieldValues == null && String.isNotBlank(String.valueOf(objRec.get(fieldName)))){
                    lstAttributes.add(String.valueOf(objRec.get(fieldName)).toLowerCase());
                }  
            }
        }
        attribute = String.join(lstAttributes, ';' );
        return attribute;
    }
        
  /************************************************************************************************************************************
    Author             :   Samadhan Kadam
    Description        :   This method is used to check null value and then map lead demographic score and 
                                Lead Demoghraphic Score DateTime (Related to Lead Score Mechanism) 
    Created Date       :   04 Oct 2018
    Issue No           :   CSI-1150,CSI-1288    
  **************************************************************************************************************************************/     
    public static void checkNullAndMapLeadScore(Lead_Score_Table__c leadScoreValue, Lead leadRec){
        if(leadScoreValue != null){
            leadRec.Lead_Demographic_Score__c = leadScoreValue.Lead_Score__c;
        }
    }
    
  /************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This method is used to get aggregate LeadSource(Related to Lead Score Mechanism) 
        Created Date        :   27 Sept 2018
        Issue No            :   CSI-1150,CSI-1288
  **************************************************************************************************************************************/  
    public static string getAggregateLeadSource(Lead leadRec, Map<String, Set<String>> mapOfLeadSource){
        if(String.isNotBlank(leadRec.LeadSource)){
            for(string key : mapOfLeadSource.keySet()){
                if(mapOfLeadSource.get(key).contains(leadRec.LeadSource)){
                    return key.toLowerCase();
                }
            }   
        }       
        return 'other';
    }
    
  /************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This method is used to get aggregate LeadSource Detail(Related to Lead Score Mechanism)
        Created Date        :   27 Sept 2018
        Issue No            :   CSI-1150,CSI-1288
  **************************************************************************************************************************************/  
    public static String getAggregateLeadSourceDetail(Lead objLead, List<Map<String,Set<String>>> lstRules){
        if(String.isNotBlank(objLead.Lead_Source_Detail__c)){
            String strLeadSource = String.isNotBlank(objLead.LeadSource) ? objLead.LeadSource.toLowerCase() : NULL;
            String strLeadSourceDetail = objLead.Lead_Source_Detail__c.toLowerCase();
            for(Map<String,Set<String>> objlstRule : lstRules){
                if((String.isBlank(strLeadSource) || objlstRule.get('leadsources').contains(strLeadSource) || objlstRule.get('leadsources').size() == 0) && objlstRule.get('leadsourcedetails').contains(strLeadSourceDetail) && !objlstRule.get('leadsourceexclude').contains(strLeadSource)) {
                    return strLeadSourceDetail;
                }else if((String.isBlank(strLeadSource) || !(strLeadSource.equalsIgnoreCase('Programmatic') || strLeadSource.equalsIgnoreCase('Google'))) && strLeadSourceDetail.equalsIgnoreCase('NA')){
                    return strLeadSourceDetail;
                }
            }
        }
        return 'other';
    }
    
 /************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This method is used to get aggregate Interested Number Of Desks(Related to Lead Score Mechanism)
        Created Date        :   03 Oct 2018
        Issue No            :   CSI-1150,CSI-1288
  **************************************************************************************************************************************/  
    public static string getAggregateInterestedNumofDesk(Lead leadRec, Map<String, Set<String>> mapOfInterestedNumberOfDesks){
        for(string key : mapOfInterestedNumberOfDesks.keySet()){
            if(mapOfInterestedNumberOfDesks.get(key).contains(leadRec.Range_For_Interested_Number_Of_Desk__c)){
                return key.toLowerCase();
            }
        }
        return 'other';
    }
    
  /************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This method is used to get aggregate Location Interested(Related to Lead Score Mechanism)
        Created Date        :   04 Oct 2018
        Issue No            :   CSI-1150,CSI-1288
  **************************************************************************************************************************************/  
    public static string getAggregateLocation(Lead leadRec,set<string> setAggregatedLocationsFromLeadScoreTable){
        string aggregatedLocation = leadRec.Building_Interested_Name__c.split('-')[0].toLowerCase();
        if(setAggregatedLocationsFromLeadScoreTable.contains(aggregatedLocation) && (aggregatedLocation.split('-')[0].length() == 2 || aggregatedLocation.split('-')[0].length() == 3)){
            return aggregatedLocation;
        }else{
            return 'other';
        }
    }
    
  /************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This method is used to get aggregate Unomy Company Size(Related to Lead Score Mechanism)
        Created Date        :   04 Oct 2018
        Issue No            :   CSI-1150,CSI-1288
  **************************************************************************************************************************************/  
    public static string getAggregateUnomySize(Lead leadRec, Map<String, Set<String>> mapOfUnomycompanySize){
        for(string key : mapOfUnomycompanySize.keySet()){
            if(mapOfUnomycompanySize.get(key).contains(leadRec.Unomy_Company_Size__c)){
                return key.toLowerCase();
            }
        }
        return leadRec.Unomy_Company_Size__c.toLowerCase();
    }
    
  /************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This method is used to create map of Lead score Table(Related to Lead Score Mechanism)
        Created Date        :   13 Aug 2018
        Issue No            :   CSI-1150,CSI-1288
  **************************************************************************************************************************************/  
    public static Map<string,Lead_Score_Table__c> createMapOfLeadScore(Set<string> setOfLeadsource,Set<string> setOfLeadsourceDetail, Set<string> setLocationInterestedInLead,Set<String> setAggregatedLocationsFromLeadScoreTable){
        Map<string,Lead_Score_Table__c> mapOfLeadScore = new Map<string,Lead_Score_Table__c>();
        string aggregatedKey;
        Set<String> setLeadFieldValues = new Set<String>{'Lead_Source_Aggregate__c','Lead_Source_Detail_Aggregate__c','Number_Of_Full_Time_Employees__c','Location_Interested__c','Interested_In_Number_of_Desks__c'};
            for(Lead_Score_Table__c scoreRec : [SELECT Id,Name,Lead_Source_Aggregate__c,Lead_Source_Detail_Aggregate__c,Location_Interested__c,Number_Of_Full_Time_Employees__c,Interested_In_Number_of_Desks__c,Lead_Score__c FROM Lead_Score_Table__c WHERE (Lead_Source_Aggregate__c IN : setOfLeadsource AND Lead_Source_Detail_Aggregate__c IN : setOfLeadsourceDetail) Or Location_Interested__c IN: setLocationInterestedInLead]){
                if(string.isNotBlank(scoreRec.Lead_Source_Aggregate__c) && string.isNotBlank(scoreRec.Lead_Source_Detail_Aggregate__c)){
                    aggregatedKey = createAttribute(scoreRec, setLeadFieldValues, null,null);
                    mapOfLeadScore.put(aggregatedKey,scoreRec);
                }
                if(string.isNotBlank(scoreRec.Location_Interested__c) && setLocationInterestedInLead.contains(scoreRec.Location_Interested__c.toLowerCase())){
                    setAggregatedLocationsFromLeadScoreTable.add(scoreRec.Location_Interested__c.toLowerCase());
                }
            }
        return mapOfLeadScore;
    }       
    
    public class EnterpriseLandingSettings{
        public String LeadSource{get;set;}
        public String LeadSourceDetail{get;set;}        
    }
    
    public class EnterpriseLeadSettings {
        public String ActivitySubject;
        public Integer CompanySize;
    }
    public class LeadJourneyStatusController {
        public string LeadStatus{get;set;}
        public string JourneyStage{get;set;}
    }
    public class APIUserContactInfoSetting{
        public String Name;
        public String UserId;
        public String Email;
        public String ContactId;
        public String ContactUUID;
        
    }
    public class UnassignedNMDUSQueue{
        List<String> UnassignedNMDUSQueue{get;set;}             
    }
    
    public class LeadTriggerHandlerException extends Exception{}
    
}