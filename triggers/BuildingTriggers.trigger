/*******************************************************************************************************************************
    Author 		: Ajaysinh Chauhan
    Description : ---
    History		: --

----------------------------------------------------------------------------------------------------------------------------------
	VERSION					DATE					AUTHOR							DETAIL
	1						--		                Ajaysinh Chauhan	            Initial Developement
********************************************************************************************************************************/

trigger BuildingTriggers on Building__c (before insert,before update, after insert, after update) {
    TriggerDispatcher.Run(new BuildingTriggerHandler()); 
}