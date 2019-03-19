/************************************************************************************************************************************
	Author		: 	Samadhan Kadam
	Description : 	This trigger handles the all operations on Reservable Hold object

	History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                       DETAIL
	1	    	1 December 2017	  	Samadhan Kadam            	 Initial Developement
**************************************************************************************************************************************/
trigger ReservableHoldTriggers on Reservable_Hold__c (before insert,after insert,after update,before update) {
	TriggerDispatcher.Run(new ReservableHoldTriggerHandler());    
}