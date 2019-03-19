/************************************************************************************************************************************
    Author      :   Milanjeet Singh
    Description :   This class is the trigger for REST_API_Log__c object

    History :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                     DETAIL
    1           22 Oct 2018        Milanjeet Singh            Initial Developement
**************************************************************************************************************************************/
trigger RESTApiLogTrigger on REST_API_Log__c (before insert, before update, after update, after insert, before delete, after delete, after undelete) {
    TriggerDispatcher.Run(new RESTApiLogTriggerHandler());
}