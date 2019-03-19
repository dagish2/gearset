/************************************************************************************************************************************
   	Author 		: Anant Kumar
   	Description : This is trigger for Tour, API name is Tour_Outcome__c.

   	History		: 
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR			DETAIL
	1			23 February 2016	Anant Kumar 	Initial Developement
**************************************************************************************************************************************/
trigger TourTriggers on Tour_Outcome__c (before insert, before update, after insert, after update) {
	TriggerDispatcher.Run(new TourTriggerHandler());
    TriggerProcessingManager.handle('Tour_Outcome__c');
}