/************************************************************************************************************************************
    Author 		: 	RamseySolutions	
    Description : 	This trigger is a placeholder for different triggers on the CampaignMember object.

    History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			22 January 2016		RamseySolutions			Initial Developement
	2			05 July 2016		Pranay Jadhav			New Trigger CampaignMemberTriggers
**************************************************************************************************************************************/
trigger CampaignMemberTriggers on CampaignMember (before insert, after insert, after update) {
     TriggerDispatcher.Run(new CampaignMemberTriggerHandler());
}