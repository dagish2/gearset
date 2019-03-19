/************************************************************************************************************************************
	Author		: 	Prashant Mane
	Description	: 	BillingAccountTriggers.

	History	:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                     DETAIL
	1	    	05 June 2018		Prashant Mane              Initial Developement
**************************************************************************************************************************************/
trigger BillingAccountTriggers on Billing_Account__c (before insert, before update, after insert, after update) {
    TriggerDispatcher.Run(new BillingAccountTriggerHandler());
}