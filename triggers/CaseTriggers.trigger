/************************************************************************************************************************************
    Author      :   Dipak Pawar
    Description :   This trigger is used for all Case Triggers.
    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           23-Nov-2017         Dipak Pawar             Initial Development

    Code Reviewed By    :   Dipak Pawar
    Code Review Comments:   Reviewed the new trigger structure, comments. ST-2022.
    Code Review Date    :   07-Feb-2018
**************************************************************************************************************************************/
trigger CaseTriggers on Case (after insert, before insert, before update, after update) {
    Debug.log('In CaseTriggers Limits.getQueries() start :: '+Limits.getQueries());
    TriggerDispatcher.Run(new CaseTriggerHandler());
    TriggerProcessingManager.handle('Case');
    Debug.log('In CaseTriggers Limits.getQueries() end :: '+Limits.getQueries());
}