/************************************************************************************************************************************
   	Author 		: Milanjeet
   	Description : This is trigger for Market, API name is Market__c

   	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE			AUTHOR				DETAIL
	1			9 Nov 2017		Milanjeet 			Initial Developement
**************************************************************************************************************************************/

trigger PortfolioTriggers on Market__c (before insert, before update, after insert, after update) {
    TriggerDispatcher.Run(new PortfolioTriggersHandler());  
}