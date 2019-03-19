/************************************************************************************************************************************
    Author      :   Jitesh Adwani 
    Description :   This trigger is a placeholder for different triggers on the campaign object. 

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           28 November 2018    Jitesh Adwani             Initial Developement
**************************************************************************************************************************************/
trigger CampaignTriggers on Campaign (before insert, before update) {
    TriggerProcessingManager.handle('Campaign');
}