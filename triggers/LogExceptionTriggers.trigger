/************************************************************************************************************************************
    Author 		: 	Krishana Tupe	
    Description : 	This trigger is used to insert apex debug log.
    
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL
    1			02 May 2018 		Krishana Tupe			Changes for exception logging.
**************************************************************************************************************************************/
trigger LogExceptionTriggers on LogException__e (after insert) {
    Debug.log('In Log_Exception__e==>'+Trigger.new);
    TriggerDispatcher.Run(new LogExceptionTriggerHandler());
}