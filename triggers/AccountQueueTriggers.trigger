/************************************************************************************************************************************
	Author 		: Dipak Pawar
   	Description : This is trigger for AccountQueue, API name is Account_Queue__c

   	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR				DETAIL
	1			26 April 2017		Dipak Pawar 		Initial Developement
**************************************************************************************************************************************/

trigger AccountQueueTriggers on Account_Queue__c (before insert, before update) {
    TriggerDispatcher.Run(new AccountQueueTriggerHandler());  
}