/************************************************************************************************************************************
    Author 		: ajaysinh chauhan
    Description : ---
    
    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION	DATE	     AUTHOR            DETAIL
    1	    6, Nov 2017	 ajaysinh chauhan  Initial Developement 
**************************************************************************************************************************************/
trigger OpportunityRoleTriggers on Opportunity_Role__c (before insert, before update,before delete,after insert, after update,after delete) {
     
      TriggerDispatcher.Run(new OpportunityRoleTriggerHandler());
}