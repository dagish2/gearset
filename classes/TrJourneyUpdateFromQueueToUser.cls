/************************************************************************************************************************************
    Author      :   Jitesh Adwani	
    Description :   This class will contain buisness logic of Journey trigger.
	Issue No    : 	ST-3040
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           14 November 2018    Jitesh             Initial Developement
**************************************************************************************************************************************/
public class TrJourneyUpdateFromQueueToUser implements IProcessHandler{
    
    public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap) {
        updateJourneyFromQueueToUser((List<Journey__c>)triggerNew, triggerOldMap);        
    }
    
/************************************************************************************************************************************
    Author         : Jitesh Adwani
    Description    : This method is used to Update Journey Status on Change of Journey Owner.
    Created Date   : 15 Nov 2018 
    Issue No       : ST-3040
**************************************************************************************************************************************/
    public void updateJourneyFromQueueToUser(List<Journey__c> triggerNew, Map<Id, sObject> triggerOldMap){
        Set<String> setJourneyCloseStages = new Set<String>();
        Setting__c objSetting = Settings.get('JourneyCloseStages');
        if(objSetting != null) {
            setJourneyCloseStages = (Set<String>)JSON.deserialize(objSetting.Data__c, Set<String>.class);
        }
        for(Journey__c objJourney : triggerNew){
            Journey__c oldJourney = (Journey__c)triggerOldMap.get(objJourney.Id);
            if(objJourney.OwnerId != oldJourney.OwnerId && String.valueOf(objJourney.OwnerId).startsWith('005') && String.valueOf(oldJourney.OwnerId).startsWith('00G') && !setJourneyCloseStages.contains(objJourney.Status__c)){
                objJourney.Status__c = 'Accepted'; 
            }
        }
    }
}