/************************************************************************************************************************************
	Author			:	Ajaysinh Chauhan
	Description 	:	This trigger handles the all operations after upating Territory object

	History :
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        		 AUTHOR                     DETAIL
	1	    	04 December 2017	 	 Ajaysinh Chauhan           Initial Developement
**************************************************************************************************************************************/
trigger TerritoryTriggers on Territory__c (after update) {
   TriggerDispatcher.Run(new TerritoryTriggersHandler()); 
}