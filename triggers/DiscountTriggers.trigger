/************************************************************************************************************************************
	Author 		: Anant Kumar
	Description : This trigger is used for all Discount__c triggers.

	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION			DATE				AUTHOR					DETAIL							ISSUE
	1				-					Anant Kumar				Initial Developement			-
**************************************************************************************************************************************/
trigger DiscountTriggers on Discount__c (before insert) {	
/************************************************************************************************************************************
	Author 				: Anant Kumar
	Description 		: This method is used invoke Discount__c triggers .
	Last Modified Date	: -
	Last Modified By	: Krishana Tupe(added Comment)
**************************************************************************************************************************************/    
        TriggerDispatcher.Run(new DiscountTriggerHandler());
}