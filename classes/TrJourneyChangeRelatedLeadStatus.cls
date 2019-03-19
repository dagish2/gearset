/************************************************************************************************************************************
    Author      :   Dipak Pawar
    Description :   

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           16 Nov 2018    		Dipak Pawar            	Initial Developement
**************************************************************************************************************************************/
public class TrJourneyChangeRelatedLeadStatus implements IProcessHandler{ 
    public static Boolean isJourneyUpdated = false;    
    public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap) {
        changeJourneyRelatedLeadStatus(triggerNew, triggerOldMap);
    }
    
    public static void changeJourneyRelatedLeadStatus(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap){        
        Map<Id, Lead> mapLeadsToUpdate = new Map<Id, Lead>();
        Map<Id, Id> mapJourneyLeadIds = new Map<Id, Id>();
        Map<String, String> mapStatusMapping = getStatusMappingsByObject();
        
        for(Journey__c objJourney : (List<Journey__c>)triggerNew){
            Boolean isLeadToUpdate = false;            
            
            if(objJourney.Primary_Lead__c != null && String.isNotBlank(objJourney.Status__c)){
                if(Trigger.isInsert){
                    Set<String> setJourneyStages = new Set<String>{'Started', 'Accepted'};
                    isLeadToUpdate = setJourneyStages.contains(objJourney.Status__c) && objJourney.Is_Lead_Completed__c;                    
                } else {
                    Journey__c objOldJourney = (Journey__c)triggerOldMap.get(objJourney.Id);            
                    if(String.isNotBlank(objOldJourney.Status__c) && objJourney.Status__c != objOldJourney.Status__c){
                        isLeadToUpdate = true;
                    }
                }
                
                if(isLeadToUpdate){
                    Lead objLead = new Lead(
                        Id = objJourney.Primary_Lead__c,
                        Status = mapStatusMapping.get(objJourney.Status__c)
                    );                    
                    switch on objJourney.Status__c {
                        when 'Unqualified' {
                            objLead.Unqualified_Reason__c = objJourney.Lost_Reason__c;
                        }
                        when 'Nurture' {
                            objLead.Nurture_Reason__c = objJourney.Nurture_Reason__c;
                        }
                        when else {
                            objLead.Unqualified_Reason__c = '';
                            objLead.Nurture_Reason__c = '';
                        }
                    }
                    
                    if(isLeadToUpdate){
                        mapLeadsToUpdate.put(objLead.Id, objLead);
                        mapJourneyLeadIds.put(objJourney.Id, objLead.Id);
                    }
                }
            }            
        }
        if(!mapLeadsToUpdate.isEmpty()){
            List<Lead> lstLeadsToUpdate = new List<Lead>();
            Setting__c objSetting = Settings.get('JourneyCloseStages');
            Set<String> setJourneyCloseStages = new Set<String>();
            if(objSetting != null){
                setJourneyCloseStages = (Set<String>)JSON.deserialize(objSetting.Data__c, Set<String>.class);
            }
            for(Lead objLead : [SELECT Id, (SELECT Id FROM Journeys__r WHERE Id NOT IN :mapJourneyLeadIds.keySet() AND Status__c NOT IN :setJourneyCloseStages) FROM Lead WHERE Id IN :mapJourneyLeadIds.values()]){
                Integer countOpenJourneys = objLead.Journeys__r.size();                
                if(countOpenJourneys < 1){
                    lstLeadsToUpdate.add(mapLeadsToUpdate.get(objLead.Id));
                }
            }
            
            if(!lstLeadsToUpdate.isEmpty()){
                isJourneyUpdated = true;
                update lstLeadsToUpdate;
            }            
        }
    }
    
    static Map<String, String> getStatusMappingsByObject(){
        Map<String, String> mapStatusMapping = new Map<String, String>();
        for(LeadJourneyTrigger__mdt objStatusMapping : [SELECT Journey_Status__c, Lead_Status__c FROM LeadJourneyTrigger__mdt WHERE Source_Object__c = 'Journey__c' AND Destination_Object__c = 'Lead']){
            mapStatusMapping.put(objStatusMapping.Journey_Status__c, objStatusMapping.Lead_Status__c);
        }
        return mapStatusMapping;
    }
}