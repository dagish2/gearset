/************************************************************************************************************************************
  Author     	: Dipak Pawar
  Description 	: 
   
History:
----------------------------------------------------------------------------------------------------------------------------------
  VERSION      	DATE        		AUTHOR          	DETAIL              	ISSUE
	1			5th June 2018   	Dipak Pawar     	Initial Developement    ST-2488  	
**************************************************************************************************************************************/
public class TaskHelper {   
   
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method creates a Task record for Tour.
        Created Date  		:   05 June 2018  
		Issue No			:	ST-2489
    **************************************************************************************************************************************/
    public static Task createTaskForTour(Contact objContact, Tour_Outcome__c objTour){
        Task objTask = new Task();                   
        objTask.Subject = String.isBlank(objTour.Original_Tour__c) ? 'Book A Tour' : 'Reschedule Tour';
        objTask.Status = 'Not Started';
        objTask.Type = 'Website';
        objTask.ActivityDate = objTour.Tour_Date__c != null ? objTour.Tour_Date__c : System.today();                            
        objTask.WhoId = objContact.Id;
        objTask.WhatId = objTour.Id;
        objTask.OwnerId = objContact.OwnerId != null ? objContact.OwnerId : UserInfo.getUserId();        
        // Field mappings Contact to Activity
        objTask = (Task)FieldMappingsHelper.getMappings(objContact.Id, objTask, 'FieldMappings:ContactToActivity');       
        return objTask;
    }
}