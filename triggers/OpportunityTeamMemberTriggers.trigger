/********************************************************************************************************************************
    Author 		: Milanjeet Singh
    Description : Add Opportunity Team Member on Opportunity Creation.
    History		: --
    
    Issue No. 	: ST-1599
----------------------------------------------------------------------------------------------------------------------------------
	VERSION					DATE						AUTHOR 							DETAIL
  	1						--						    Milanjeet Singh 			    Initial Developement
***************************************************************************************************************************************************/
trigger OpportunityTeamMemberTriggers on OpportunityTeamMember (before insert, before update,after insert, after update,before delete) {
     Debug.log('In OpportunityTeamMemberTriggers Limits.getQueries() start :: '+Limits.getQueries());
    TriggerDispatcher.Run(new OpportunityTeamMemberTriggerHandler());
      Debug.log('In OpportunityTeamMemberTriggers Limits.getQueries() end :: '+Limits.getQueries());
}