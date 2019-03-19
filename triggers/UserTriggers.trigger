/************************************************************************************************************************************
    Author 		: ajaysinh chauhan
    Description : ---
    History		: -- 

----------------------------------------------------------------------------------------------------------------------------------
	VERSION	 	DATE	        	AUTHOR            	DETAIL
	1	     	17, Sep 2016		ajaysinh chauhan  	Initial Developement
**************************************************************************************************************************************/

trigger UserTriggers on User (before insert,before update, after update,after insert) {
    TriggerDispatcher.Run(new UserTriggerHandler()); 
    TriggerProcessingManager.handle('User');
}