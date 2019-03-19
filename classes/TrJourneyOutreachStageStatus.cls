/************************************************************************************************************************************
    Author      :   Jitesh Adwani	
    Description :   This class will contain buisness logic of Journey trigger.
	Issue No    : 	ST-3039
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           12 November 2018    Jitesh             Initial Developement
**************************************************************************************************************************************/
public class TrJourneyOutreachStageStatus implements IProcessHandler{
    
	public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap) {
        updateJourneyStatusOnOutreachStage((List<Journey__c>)triggerNew, triggerOldMap);        
    }
    
/************************************************************************************************************************************
    Author         : Jitesh Adwani
    Description    : This method is used to Update Journey Status on Outreach Stage Updates.
    Created Date   : 15 Nov 2018 
    Issue No       : ST-3039
**************************************************************************************************************************************/
    public void updateJourneyStatusOnOutreachStage(List<Journey__c> triggerNew, Map<Id, sObject> triggerOldMap){
        Setting__c UpdateJourneyOutreachStage = Settings.get('UpdateJourneyOutreachStage');
        if(UpdateJourneyOutreachStage != null){
            Set<String> setStages = (Set<String>)JSON.deserialize(UpdateJourneyOutreachStage.Data__c.toLowerCase(), Set<String>.class);
            for(Journey__c objJourney : triggerNew){
                Journey__c oldJourney = (Journey__c)triggerOldMap.get(objJourney.Id);
                if(String.isNotBlank(objJourney.Outreach_Stage__c) && objJourney.Outreach_Stage__c != oldJourney.Outreach_Stage__c && setStages != null && setStages.contains(objJourney.Outreach_Stage__c.toLowerCase())){
                    objJourney.Status__c = 'Trying to Reach';
                }
            } 
        }
    }
}