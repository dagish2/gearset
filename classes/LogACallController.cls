/************************************************************************************************************************************
    Author      :   Dipak Pawar    
    Description :   This class contain methods that are used in LogACallController
    
    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1          31-10-2018         	Dipak Pawar        		Initial Developement
**************************************************************************************************************************************/
global class LogACallController {
    public static Boolean isInvoker = false;
    public static Savepoint sp {get; set;}
    
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'LogACallController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    
    /****************************************************************************************************************************
        Author              : Dipak Pawar
        Description         : This Method returns the journeyData to Log A Call component for the provided journeyId
        Created Date        : 31-10-2018
       	Issue               : ST-2868
   *****************************************************************************************************************************/
	@AuraEnabled
    public static DatabaseResult getJourneyData(Id journeyId, String querylabel){
        try{
            Map<String, Object> objDatabaseResult = new Map<String, Object>();
            switch on querylabel{
                when 'getJourneyData' {
                    List<Journey__c> lstJourneys = new List<Journey__c>([SELECT Id, Name, Outreach_Stage__c, Primary_Lead__c, Primary_Contact__c, Status__c FROM Journey__c WHERE Id =: journeyId]);
                    objDatabaseResult.put('journeyRecord', lstJourneys[0]);
                }           	
            }
            return new DatabaseResult(objDatabaseResult);
        } catch(Exception pEx){
            ApexDebugLog.logException(pEx, journeyId + ' ' + querylabel, 'LogACallController', 'getJourneyData');            
            return (new DatabaseResult(pEx));
        }
    }
    
    /****************************************************************************************************************************
        Author              : Dipak Pawar
        Description         : This Method saves the call log for given journey.
        Created Date        : 31-10-2018
       	Issue               : ST-2868
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult saveCallLogs(Journey__c objJourney, Boolean leftAVoicemail, String callComments){
        try{            
            List<Task> lstTasksToCreate = new List<Task>();
            
            if(leftAVoicemail){
                objJourney.Outreach_Result__c = 'Left Voicemail';
            }
			
            Task objTask = new Task(
                Type = 'Call',
                TaskSubType = 'Call',
                Status = 'Completed',
                Subject = 'Log A Call : ' + objJourney.Outreach_Stage__c,
                CallDisposition = callComments,
                WhatId = objJourney.Id
            );
            lstTasksToCreate.add(objTask);
            
            update objJourney;
            if(lstTasksToCreate.size() > 0){
                insert lstTasksToCreate;
            }
            return new DatabaseResult(true);
        } catch(Exception pEx){
            ApexDebugLog.logException(pEx, JSON.serialize(objJourney) + ' ' + callComments, 'LogACallController', 'saveCallLogs');            
            return (new DatabaseResult(pEx));
        }
    }
    
    public class LogACallControllerException extends Exception{}
}