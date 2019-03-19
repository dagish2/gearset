/************************************************************************************************************************************
   	Author 		: Sunil Bhosale
   	Description : This is trigger for Region, API name is Region__c

   	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR				DETAIL
	1			10 November 17		Sunil Bhosale 		Initial Developement
**************************************************************************************************************************************/
trigger RegionTriggers on Region__c (before insert, before update, after insert, after update) {
    TriggerDispatcher.Run(new RegionTriggersHandler());
}