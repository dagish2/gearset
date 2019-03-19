/*****************************************************************************************************************************
  Yet to do
  1. Modularize the code into multiple method calls.
  2. Put comments for each method call to establish references.
  3. Get it reviewed from the peer team.
******************************************************************************************************************************
    Author      :  Krishana Tupe  
    Description :  This Utility class contains the utility methods related to Journey Helper
    History     :  --
    
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION                 DATE            ISSUE       AUTHOR                          DETAIL
    1                       28 Nov 2018      -     		Krishana Tupe                   Initial Developement    
******************************************************************************************************************************/
public class JourneyHelperUtility {
    
/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to create a journey for a Lead on Lead insertion
      	Created Date  		:   28 Nov 2018 
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static void createJourney(List<Map<String,sObject>> lstParents, List<Id> lstLeadsToBeDeleted){ 
        set<Id> setNewParentIds = new set<Id>();
        for(Map<String,sObject> mapParent : lstParents){           
            Lead objPrimaryParent = (Lead)(mapParent.containsKey('newlead')? mapParent.get('newlead') : mapParent.get('lead')); 
            setNewParentIds.add(objPrimaryParent.Id);
        }
        Map<Id,sObject> mapJourneys = FieldMappingsHelper.getMappings(setNewParentIds,'FieldMappings:LeadToJourney'); 
        Map<String, Map<String, Journey__c>> mapJourneyCriterias = checkJourneyCreationCriteria(lstParents, mapJourneys); 
        Debug.log('mapJourneyCriterias ==>'+mapJourneyCriterias);
        Map<Id,Map<String,sObject>> mapJourneysWithAssignment = new Map<Id,Map<String,sObject>>();
        Map<Id,Map<String,sObject>> mapJourneysToUpdate = new Map<Id,Map<String,sObject>>();
        for(Map<String,sObject> mapParent : lstParents){
            Lead objPrimaryParent = (Lead)(mapParent.containsKey('newlead')? mapParent.get('newlead') : mapParent.get('lead'));            
            if(objPrimaryParent.Generate_Journey__c){
                sObject objParent = mapParent.containsKey('contact') ? mapParent.get('contact') : mapParent.get('lead');                    
                Map<String, Journey__c> mapCriteriaResult = mapJourneyCriterias.get(objParent.Id);    
                Boolean isCreateNew = mapCriteriaResult.containsKey('createNew');              
                if(isCreateNew || (isCreateNew && objPrimaryParent.By_Pass_Journey_Creation_Criteria__c)){                  
                    mapJourneysWithAssignment.put(objPrimaryParent.Id, mapParent);
                }else if(!isCreateNew){
                    mapJourneysToUpdate.put(String.valueOf(objParent.get('Id')), mapParent);
                }
            }
        }
        Map<Id,Journey__c> mapJourneysToUpsert = new Map<Id,Journey__c>();
        Map<Id,Id> mapAssignments = new Map<Id,Id>();
        Debug.log('New journey will be create ==>'+mapJourneysWithAssignment.size());
        Debug.log('Existing journey will be update ==>'+mapJourneysToUpdate.size());
        
        //within 1 day reuse journey
        if(mapJourneysToUpdate.keySet().size() > 0){
            updateExistingJourneys(mapJourneysToUpdate, mapJourneysToUpsert, mapAssignments, mapJourneyCriterias);
        }
        
        //beyond 1 day create new journey
        if(mapJourneysWithAssignment.size() > 0){
            JourneyHelper.createJourneyWithAssignment(mapJourneysWithAssignment, mapJourneysToUpsert, mapAssignments, mapJourneys);            
        }
        Debug.log('JourneyUtltity lstJournysToUpsert ==>'+mapJourneysToUpsert.size());  
        if(mapJourneysToUpsert.size() > 0){
            upsert mapJourneysToUpsert.values();
            for(Id newLeadId : mapJourneysToUpsert.keySet()){                
                if(mapAssignments.containsKey(newLeadId) && mapAssignments.get(newLeadId) == null){
                    mapAssignments.put(newLeadId, mapJourneysToUpsert.get(newLeadId).Id);
                }
            }
        }
        if(LeadRoutingHelper.mapJourneysWithLeadOrContactIds.size() > 0){
            mapAssignments.putAll(LeadRoutingHelper.mapJourneysWithLeadOrContactIds);
        }
        Debug.log('JourneyUtltity mapAssignments ==>'+mapAssignments.size());
        Debug.log('JourneyUtltity lstLeadsToBeDeleted ==>'+(lstLeadsToBeDeleted != NULL ? lstLeadsToBeDeleted.size() : NULL));
        if(!System.isBatch() && mapAssignments.size() > 0){
            JourneyHelper.updateJourneyOwner(JSON.serialize(mapAssignments), JSON.serialize(lstLeadsToBeDeleted));
        }else if(!System.isBatch() && lstLeadsToBeDeleted.size() > 0){
            Database.delete(lstLeadsToBeDeleted, false);
        }
    }
    
/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to update the existing journey owner from Kickbox with Campaign according Lead Assignment Rule
      	Created Date  		:   29 Nov 2018 
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static void updateJourneyOwner(Set<Id> setLeadIds, List<Id> lstLeadIds){ 
        if(setLeadIds != null && !setLeadIds.isEmpty()){
            Map<String,String> mapAPIUserInfo = (Map<String,String>)JSON.deserialize(Settings.get('APIUserContactInfo').Data__c, Map<String,String>.class);
            Map<String,List<String>> mapUnassignedQueue = (Map<String,List<String>>)JSON.deserialize(Settings.get('Unassigned NMD US Queue').Data__c, Map<String,List<String>>.class);
            Id strHoldBackQueueId =  LeadConverterHelper.getHoldBackQueueId(); 
            List<Journey__c> lstJourneysToUpdate = new List<Journey__c>();
            Map<Id, Lead> mapLeads = new Map<Id, Lead>([SELECT Id, OwnerId FROM Lead WHERE Id IN : setLeadIds]);
            for(Journey__c objJourney : [SELECT Id, Lead_Id__c, OwnerId FROM Journey__c WHERE Lead_Id__c IN : setLeadIds AND CreatedDate= TODAY ]){
                Lead objPrimaryLead = mapLeads.containsKey(objJourney.Lead_Id__c) ? mapLeads.get(objJourney.Lead_Id__c) : NULL;
                Id apiUserId = (String.isNotBlank(mapAPIUserInfo.get('userId')) ? Id.valueOf(mapAPIUserInfo.get('userId')):  Id.valueOf('005F0000003Kmbw'));
                if(objPrimaryLead != NULL){
                    if((objPrimaryLead.OwnerId != apiUserId) && settings.getUserActive(objPrimaryLead.ownerId)){                       
                        objJourney.OwnerId = objPrimaryLead.OwnerId;     
                    }else if((objPrimaryLead.OwnerId == apiUserId) && !settings.getUserActive(objJourney.ownerId)){
                        objJourney.OwnerId = mapUnassignedQueue.get('UnassignedNMDUSQueue')[0];
                    }else if(objJourney.ownerId == strHoldBackQueueId || objJourney.ownerId == apiUserId){
                        objJourney.OwnerId = mapUnassignedQueue.get('UnassignedNMDUSQueue')[0]; 
                    } 
                    if(String.valueOf(objJourney.OwnerId).startsWith('005')){
                        objJourney.Status__c = 'Accepted';    
                    }
                    lstJourneysToUpdate.add(objJourney);
                }
            }
            Debug.log('lstJourneysToUpdate ==>'+lstJourneysToUpdate);
            if(!lstJourneysToUpdate.isEmpty()){
                Database.update(lstJourneysToUpdate, false);
            }
        } 
        if(lstLeadIds != null && !lstLeadIds.isEmpty()){
            Database.delete(lstLeadIds, false);   
        }
    }
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to update the existing journey (Within 1 day) 
      	Created Date  		:   29 Nov 2018 
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static void updateExistingJourneys(Map<Id,Map<String,sObject>> mapParents, Map<Id,Journey__c> mapJourneysToUpsert, Map<Id,Id> mapAssignments, Map<String, Map<String, Journey__c>> mapJourneyCriterias){       
        Map<String,String> mapAPIUserInfo = (Map<String,String>)JSON.deserialize(Settings.get('APIUserContactInfo').Data__c, Map<String,String>.class);
        Map<Id,Journey__c> mapJourneyWithLeadOrContact = new Map<Id,Journey__c>();
        Map<Id,Id> mapJourneyWithLeadOrContactIds = new Map<Id,Id>();
        for(Map<String,sObject> mapParent : mapParents.values()){
            sObject objParent = mapParent.containsKey('contact') ? mapParent.get('contact') : mapParent.containsKey('lead') ? mapParent.get('lead') : null;
            sObject objNewParent = mapParent.containsKey('newlead') ? mapParent.get('newlead') : mapParent.get('lead');
            Journey__c objJourney = mapJourneyCriterias.get(String.valueOf(objParent.get('Id'))).get('reUse');
            objJourney = JourneyHelper.getDefaultMappings(mapParent, objJourney);
            if(System.isBatch()){
                if(objJourney != null && objJourney.OwnerId != null && !Settings.getUserActive(objJourney.OwnerId) && !String.valueOf(objJourney.OwnerId).toLowerCase().startsWith('00g')){
                    if(objNewParent != null && objNewParent.get('OwnerId') != null && (Settings.getUserActive(Id.valueOf(String.valueOf(objNewParent.get('OwnerId')))) || String.valueOf(objNewParent.get('OwnerId')).toLowerCase().startsWith('00g'))){
                        objJourney.OwnerId = (Id)objNewParent.get('OwnerId');                        
                    }else{
                        objJourney.OwnerId = UserInfo.getUserId();
                    }
                }
            }
            mapJourneyWithLeadOrContact.put(Id.valueOf(String.valueOf(objNewParent.get('Id'))), objJourney);
            if(objJourney.get('OwnerId') != null && (objJourney.OwnerId == Id.valueOf(mapAPIUserInfo.get('UserId')) || (!Settings.getUserActive(objJourney.OwnerId) && !String.valueOf(objJourney.OwnerId).toLowerCase().startsWith('00g')))){
                mapJourneyWithLeadOrContactIds.put(Id.valueOf(String.valueOf(objNewParent.get('Id'))), objJourney.Id);
            }
            if(objParent != null && objParent.get('OwnerId') != null && (objParent.get('OwnerId') == Id.valueOf(mapAPIUserInfo.get('UserId')) || (!Settings.getUserActive(Id.valueOf(String.valueOf(objParent.get('OwnerId')))) && !String.valueOf(objParent.get('OwnerId')).toLowerCase().startsWith('00g')))){
                mapJourneyWithLeadOrContactIds.put(Id.valueOf(String.valueOf(objParent.get('Id'))), Id.valueOf(String.valueOf(objNewParent.get('Id'))));
            }            
        }
        Debug.Log('JourneyUtiltiy mapJourneyWithLeadOrContactIds == >'+mapJourneyWithLeadOrContactIds.size());
        if(mapJourneyWithLeadOrContact.size() > 0){
            mapJourneysToUpsert.putAll(mapJourneyWithLeadOrContact);
            mapAssignments.putAll(mapJourneyWithLeadOrContactIds);
        }
    }
    
/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to identify journey creation criteria: Create new journey or Reuse journey
      	Created Date  		:   29 Nov 2018 
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static Map<String, Map<String,Journey__c>> checkJourneyCreationCriteria(List<Map<String,sObject>> lstParents, Map<Id,sObject> mapJourneys){ 
        Map<String, Map<String,Journey__c>> mapJourneyCriterias = new Map<String, Map<String,Journey__c>>();      
        set<String> setJourneyMatchingFields = LeadRoutingHelper.getJourneyMatchingFields();
        for(Map<String, sObject> mapParent : lstParents){            
            sObject objParent = mapParent.containsKey('contact') ? mapParent.get('contact') : mapParent.get('lead');
            sObject objNewParent = mapParent.containsKey('newlead')? mapParent.get('newlead'):mapParent.get('lead');
            if(objParent.getSObjects('Journeys__r') != null && objParent.getSObjects('Journeys__r').size() > 0){                   
                Journey__c objNewJourney = (Journey__c)mapJourneys.get(String.valueOf(objNewParent.get('Id')));
                objNewJourney = JourneyHelper.getDefaultMappings(mapParent, objNewJourney);  
                Map<String, Journey__c> mapResult = checkIsUniqueJourney(objNewJourney,(List<Journey__c>)objParent.getSObjects('Journeys__r'), setJourneyMatchingFields);                        
                mapJourneyCriterias.put(String.valueOf(objParent.get('Id')), mapResult); 
            }else{
                mapJourneyCriterias.put(String.valueOf(objParent.get('Id')), new Map<String, Journey__c>{'createNew' => null});   
            }               
        } 
        return mapJourneyCriterias;        
    }
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to identify : Create new journey or Reuse journey
      	Created Date  		:   29 Nov 2018 
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static Map<String, Journey__c> checkIsUniqueJourney(Journey__c objNewJourney, List<Journey__c> lstJourneys, set<String> setJourneyMatchingFields){        
        if(!setJourneyMatchingFields.isEmpty()){
            for(Journey__c objJourney : lstJourneys){         
                Boolean isSameJourney = checkUniqueKey(setJourneyMatchingFields, objNewJourney, objJourney);
                if(isSameJourney){               
                    return new Map<String, Journey__c> {'reUse' => objJourney};
                        }
            }         
        }        
        return new Map<String, Journey__c> {'createNew' => null};
            }
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to identify the unique journeys using set of fields that are stored in metadata
      	Created Date  		:   29 Nov 2018 
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static Boolean checkUniqueKey(set<String> setJourneyMatchingFields, sObject objNewJourney, sObject objJourney){        
        for(String strField : setJourneyMatchingFields){             
            if(objNewJourney.get(strField) != objJourney.get(strField)){
                return false;
            }                  
        }
        return true; 
    }
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to get the Mode of Assignment for journey according to HOLD-BACK flow
      	Created Date  		:   29 Nov 2018 
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public static String getJourneyModeofAssignment(Lead objNewLead){       
        if(objNewLead.Campaign_Id__c != null){
            return 'Campaign Assignment'; 
        }else if(System.isBatch() && objNewLead.By_Pass_Journey_Creation_Criteria__c){
            return 'Kickbox Importer'; 
        }else if(RESTInboundLeadAPIHelper.isLeadFromWeb && objNewLead.Lead_Assignment_Stage__c == '11'){
            return 'Lead Assignment';   
        }else if((RESTInboundLeadAPIHelper.isLeadFromWeb && objNewLead.Lead_Assignment_Stage__c == '6') || (!System.isBatch() && objNewLead.Lead_Assignment_Stage__c == '1000')){
            return 'Manual Creation';   
        }
        return null;
    }    
}