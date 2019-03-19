/************************************************************************************************************************************
    Author 		: 	RamseySolutions	
    Description : 	Test class moved by DocusignStatusOpportunityWon trigger.

    History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			07 July 2016		Aanat Kumar				Initial Developement
**************************************************************************************************************************************/
trigger DocuSignStatusTriggers on dsfs__DocuSign_Status__c (after insert, after update) {
	TriggerDispatcher.Run(new DocuSignStatusTriggerHandler());
}