/************************************************************************************************************************************
    Author      :   Dipak Pawar
    Description :   

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           16 Nov 2018    Dipak Pawar            	Initial Developement
**************************************************************************************************************************************/
public class TrLeadChangeRelatedJourneyStatus implements IProcessHandler{ 
    
    public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap) {        
        if(!TrJourneyChangeRelatedLeadStatus.isJourneyUpdated){
        	changeLeadRelatedJourneyStatus(triggerNew, triggerOldMap);    
        }        
    }
    
    public static void changeLeadRelatedJourneyStatus(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap){        
        Set<Id> setLeadIds = new Set<Id>();       
        Map<String, String> mapStatusMapping = getStatusMappingsByObject();
        for(Lead objLead : (List<Lead>)triggerNew){
            Lead objOldLead = (Lead)triggerOldMap.get(objLead.Id);
            if(String.isNotBlank(objLead.Status) && String.isNotBlank(objOldLead.Status) && objLead.Status != objOldLead.Status && mapStatusMapping.keySet().contains(objLead.Status)){
                setLeadIds.add(objLead.Id);
            }
        }       
        
        if(!setLeadIds.isEmpty()){
            Set<String> setJourneyCloseStages = new Set<String>();
            List<Journey__c> lstJourneysToUpdate = new List<Journey__c>();
            Setting__c objSetting = Settings.get('JourneyCloseStages');
            if(objSetting != null) {
                setJourneyCloseStages = (Set<String>)JSON.deserialize(objSetting.Data__c, Set<String>.class);
            }
            for(Lead objLead : [SELECT Id, Status, Unqualified_Reason__c, (SELECT Id, Status__c, Lost_Reason__c FROM Journeys__r WHERE Status__c NOT IN :setJourneyCloseStages ORDER BY LastModifiedDate DESC LIMIT 1) FROM Lead Where Id IN : setLeadIds AND isConverted = false]){
                if(objLead.Journeys__r.size() > 0){
                    Journey__c  objJourney = objLead.Journeys__r[0];
                    if(objJourney.Status__c != mapStatusMapping.get(objLead.Status)){
                        objJourney.Status__c = mapStatusMapping.get(objLead.Status);
                        if(objLead.Status == 'Unqualified'){
                            objJourney.Lost_Reason__c = objLead.Unqualified_Reason__c;
                        }
                        lstJourneysToUpdate.add(objJourney);  
                    }
                }
            }
            
            Debug.log('lstJourneysToUpdate ==>'+lstJourneysToUpdate);
            if(!lstJourneysToUpdate.isEmpty()){
                update lstJourneysToUpdate;
            }
        }
    }
    
    static Map<String, String> getStatusMappingsByObject(){
        Map<String, String> mapStatusMapping = new Map<String, String>();
        for(LeadJourneyTrigger__mdt objStatusMapping : [SELECT Journey_Status__c, Lead_Status__c, Source_Object__c, Destination_Object__c FROM LeadJourneyTrigger__mdt WHERE Source_Object__c = 'Lead' AND Destination_Object__c = 'Journey__c']){
            mapStatusMapping.put(objStatusMapping.Lead_Status__c, objStatusMapping.Journey_Status__c);
        }
        return mapStatusMapping;
    }
}