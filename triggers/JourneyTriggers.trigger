/************************************************************************************************************************************
    Author 		: Amol Darekar
    Description : ---

    History		:
----------------------------------------------------------------------------------------------------------------------------------
    VERSION	  DATE	         AUTHOR        DETAIL
    1	      17,May 2016	 Amol Darekar  Initial Developement
**************************************************************************************************************************************/

trigger JourneyTriggers on Journey__c (before insert,before update,after insert,after update) {    
    TriggerDispatcher.Run(new JourneyTriggerHandler());        
    TriggerProcessingManager.handle('Journey__c');
}