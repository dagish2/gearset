/************************************************************************************************************************************
	Author 		: Mayuresh Ghodke
	Description : This trigger is used for all contact triggers.

	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION			DATE				AUTHOR					DETAIL							ISSUE
	1				27 June 2016		Mayuresh Ghodke			Initial Developement			ST-420
**************************************************************************************************************************************/
trigger ContactTriggers on Contact (before insert,after insert,before update,after update, after delete) {
    
	/************************************************************************************************************************************
		Author 				: Sunil Bhosale. 
		Description 		: This method is used invoke contact triggers .
		Last Modified Date	: 13 January 2018
		Last Modified By	: Sunil Bhosale
	**************************************************************************************************************************************/    
  TriggerDispatcher.Run(new ContactTriggerHandler());
}