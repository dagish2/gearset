/**********************************************************************************************************************************
    AUTHOR	: RamseySolutions
    History : --
---------------------------------------------------------------------------------------------------------------------------------
	VERSION 	AUTHOR				DATE			DETAIL											
	1			RamseySolutions		18/01/2016		Placeholder for different Task triggers
*****************************************************************************************************************************************/

trigger TaskTriggers on Task (before insert,after insert,before update,after update) 
{
    TriggerDispatcher.Run(new TaskTriggerHandler());
}