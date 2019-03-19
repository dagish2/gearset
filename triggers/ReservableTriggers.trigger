/************************************************************************************************************************************
    Author 		:
    Description : ---
    History		:
----------------------------------------------------------------------------------------------------------------------------------
	VERSION	  	DATE	        	AUTHOR           	DETAIL
	1	     	01, Mar 2016		Anant Kumar      	Initial Developement
**************************************************************************************************************************************/

trigger ReservableTriggers on Reservable__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {    
    //Triggers__c triggerSettings = Triggers__c.getInstance();
    TriggerDispatcher.Run(new ReservableTriggerHandler());
}