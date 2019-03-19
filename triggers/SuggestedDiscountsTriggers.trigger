/************************************************************************************************************************************
   Author 	   : Shobhit Gahlot
   Description : This will contain all triggers on SuggestedDiscounts Object test  

   History:
----------------------------------------------------------------------------------------------------------------------------------
VERSION	 DATE	        AUTHOR          DETAIL
1	     05, Oct 2017   Shobhit Gahlot  Initial Developement
**************************************************************************************************************************************/

trigger SuggestedDiscountsTriggers on Suggested_Discounts__c (before insert,before update) {
    TriggerDispatcher.Run(new SuggestedDiscountsTriggerHandler());
}