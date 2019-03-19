/************************************************************************************************************************************
	Author		: 	Mayuresh Ghodke
	Description	: 	AccountTriggers

	History	:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                     DETAIL
	1	    	05 July 2016		Mayuresh Ghodke            Initial Developement
**************************************************************************************************************************************/
trigger AccountTriggers on Account (before insert, before update, after update, after insert, before delete, after delete) {
    TriggerDispatcher.Run(new AccountTriggerHandler());
    TriggerProcessingManager.handle('Account');
}