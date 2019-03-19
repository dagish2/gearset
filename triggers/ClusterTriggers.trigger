/************************************************************************************************************************************
    Author 		: 	Milanjeet	
    Description : 	This trigger is a placeholder for different triggers on the cluster object.

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			09 November 2017	Milanjeet				Initial Developement
**************************************************************************************************************************************/
trigger ClusterTriggers on Cluster__c (before insert, before update, after insert, after update) {
    TriggerDispatcher.Run(new ClusterTriggersHandler());  
}