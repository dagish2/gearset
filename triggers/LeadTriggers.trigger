/************************************************************************************************************************************
    Author 		: Amol Darekar 
    Description : ---
    History		: --

----------------------------------------------------------------------------------------------------------------------------------
	VERSION					DATE					AUTHOR							DETAIL
	1					    05,July 2016		    Amol Darekar	                Initial Developement
**************************************************************************************************************************************/

trigger LeadTriggers on Lead (before insert, after insert, before update, after update, before delete) {
    TriggerDispatcher.Run(new LeadTriggerHandler());
    TriggerProcessingManager.handle('Lead');
}