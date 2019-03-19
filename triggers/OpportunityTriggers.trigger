/************************************************************************************************************************************
    Author      :   Anant Kumar 
    Description :   This trigger is a placeholder for different triggers on the opportunity object. 

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           23 February 2016    Anant Kumar             Initial Developement
**************************************************************************************************************************************/
trigger OpportunityTriggers on Opportunity(before insert, before update, after insert, after update, before delete){   
    TriggerDispatcher.Run(new OpportunityTriggerHandler());
    TriggerProcessingManager.handle('Opportunity');
}