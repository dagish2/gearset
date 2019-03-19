/********************************************************************************************************************************
	Author 		: Hemanshu Shah
	Description : This class is used to keep track record of Sales Console setting for modification of any settings via UI or Apex Code.
	
	History:
	-----------------------------------------------------------------------------------------------------------------------------------
	VERSION							DATE						AUTHOR 							DETAIL
	1							    24 April 2016				Hemanshu Shah 			        Initial Developement
***********************************************************************************************************************************/

trigger SettingsTriggers on Setting__c (before insert, before update) {
    /************************************************************************************************************************************
		Author 				: Prashant Mane 
		Description 		: This method is used to invoke Setting__c triggers .
		Last Modified Date	: 05 February 2018
		Last Modified By	: Prashant Mane
	**************************************************************************************************************************************/ 
    TriggerDispatcher.Run(new SettingTriggerHandler()); 
}