/************************************************************************************************************************************
    Author 		: 	Pragalbha Mahajan
    Description : 	This trigger is used for OpportunityLineItem Triggers.
    History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			08 March 2018		Pragalbha Mahajan		Initial Development
*************************************************************************************************************************************/
trigger OpportunityLineItemTriggers on OpportunityLineItem (before insert,before update,after insert, after update, after delete) {
     Debug.log('In OpportunityLineItemTriggers Limits.getQueries() start :: '+Limits.getQueries());
    TriggerDispatcher.Run(new OpportunityLineItemTriggerHandler());
     Debug.log('In OpportunityLineItemTriggers Limits.getQueries() end :: '+Limits.getQueries());
}