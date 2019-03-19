/************************************************************************************************************************************
	Author 		: Amol Darekar
	Description : This trigger is used for all contact triggers.

	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION			DATE				AUTHOR					DETAIL							ISSUE
	1				-					Amol Darekar			Initial Developement			-
**************************************************************************************************************************************/
trigger ReferralTriggers on Referral__c (before insert) {    
    
        /************************************************************************************************************************************
            Author 				: -
            Description 		: This method is used invoke contact trigger .
            Last Modified Date	:	1 Februaru 2018
            Last Modified By	: Krishana Tupe
        **************************************************************************************************************************************/ 
        TriggerDispatcher.Run(new ReferralTriggerHandler());  
}