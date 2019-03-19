/********************************************************************************************************************************
    Author 		: Milanjeet Singh
    Description : Add Opportunity Team Member on Opportunity Creation.
    History		: --
    
    Issue No. 	: ST-1599
----------------------------------------------------------------------------------------------------------------------------------
	VERSION					DATE						AUTHOR 							DETAIL
	1						--						    Milanjeet Singh 				Initial Developement
******************************************************************************************************************************************/

public with sharing class OpportunityTeamMemberTriggerHandler extends ITriggerHandler{
  
    static Map<Id, OpportunityRelatedTeamMember> mapRoleAndUserIds = new Map<Id, OpportunityRelatedTeamMember>();
    
    public OpportunityTeamMemberTriggerHandler(){
        super('OpportunityTeamMember__c');
    }
    
	/****************************************************************************************************************************
        Author 				: Amol Darekar
        Description 		: This method overrides before insert method from ITriggerHander which will control the execution flow.
        Created Date		: 05,July 2016
        Last Modified By 	: Prashant Mane
        Last Modified Date  : 02 Feb,2018
    *****************************************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){
        updateSplitPercentage((List<OpportunityTeamMember>)listNewItems,null);
    }
    
	/****************************************************************************************************************************
        Author 				: Amol Darekar
        Description 		: This method overrides before update method from ITriggerHander which will control the execution flow.
        Created Date		: 05,July 2016
        Last Modified By 	: Prashant Mane
        Last Modified Date  : 02 Feb,2018
    *****************************************************************************************************************************/
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        updateSplitPercentage((List<OpportunityTeamMember>)listNewItems,(map<Id,OpportunityTeamMember>)mapNewItems);
    }

    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){        
        if(TriggerSettings.mappedField.OpportunityTeamMember_ChangeOpenOppCasesOwner){
            changeOpenOppCasesOwner((List<OpportunityTeamMember>) listNewItems,(Map<Id,OpportunityTeamMember>) mapNewItems,null,null);
        }
    }
    
    public override void BeforeDelete(List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.OpportunityTeamMember_StoreOldOppTeamMemberUserIds){
            storeOldOppTeamMemberUserIds((List<OpportunityTeamMember>)listOldItems,(Map<Id,OpportunityTeamMember>)mapOldItems);
        }
    }
	/*************************************************************************************************
        Author 				: Milanjeet Singh
        Description 		: method to update split percentage
        Created Date		: --
        Last Modified By 	: Prashant Mane
        Last Modified Date  : 02 Feb,2018
    ****************************************************************************************************/
    
    public static void updateSplitPercentage(List<OpportunityTeamMember> listNewItems,Map<Id, OpportunityTeamMember> mapNewItems){
        WithoutSharingUtilityController.updateSplitPercentage(listNewItems,mapNewItems);  
    } 
    
     public static void changeOpenOppCasesOwner(List<OpportunityTeamMember> listNewItems, Map<Id, OpportunityTeamMember> mapNewItems, List<OpportunityTeamMember> listOldItems, Map<Id, OpportunityTeamMember> mapOldItems){
        if(listNewItems.size()>0 && mapRoleAndUserIds != null && mapRoleAndUserIds.size()>0 && mapOldItems == null){
                Debug.log('mapRoleAndUserIds--->'+mapRoleAndUserIds);
                Set<Id> setOldUsersIds = new Set<Id>();
                Set<Id> setOpportunityIds = new Set<Id>(); 
                Map<Id,Id> mapOldAndNewUsers = new Map<Id,Id>();
                for(OpportunityTeamMember objOpportunityTeamMember : listNewItems){
                    if(mapRoleAndUserIds.ContainsKey(objOpportunityTeamMember.OpportunityId) && mapRoleAndUserIds.get(objOpportunityTeamMember.OpportunityId).teamMemberRole == objOpportunityTeamMember.TeamMemberRole ){
                        setOpportunityIds.add(objOpportunityTeamMember.OpportunityId);
                        setOldUsersIds.add(mapRoleAndUserIds.get(objOpportunityTeamMember.OpportunityId).userId);
                        mapOldAndNewUsers.put(mapRoleAndUserIds.get(objOpportunityTeamMember.OpportunityId).userId,objOpportunityTeamMember.UserId);
                    }
                }
                List<Case> lstCases = new List<Case>();
                for(Case objCase : [SELECT Id,OwnerId FROM Case WHERE IsClosed = false AND OwnerId IN : setOldUsersIds AND  Opportunity__c IN : setOpportunityIds]) {
                    if( objCase.OwnerID != mapOldAndNewUsers.get(objCase.OwnerID) && mapOldAndNewUsers.containsKey(objCase.OwnerID)){
                        objCase.OwnerID = mapOldAndNewUsers.get(objCase.OwnerID);
                        lstCases.add(objCase);
                    }
                }
                if(lstCases.size() > 0){
                    update lstCases;
                }              
            }
        
    }
    public static void storeOldOppTeamMemberUserIds(List<OpportunityTeamMember> listOldItems, Map<Id,OpportunityTeamMember> mapOldItems){
        Debug.Log('storeOldOppTeamMemberUserIds---'+listOldItems);
        for(OpportunityTeamMember oppTeamMember : listOldItems){
            OpportunityRelatedTeamMember teamMember = new OpportunityRelatedTeamMember();
            teamMember.userId = oppTeamMember.UserId;
            teamMember.teamMemberRole = oppTeamMember.TeamMemberRole;
            mapRoleAndUserIds.put(oppTeamMember.OpportunityId, teamMember);
        }
    }
    
    public Class OpportunityRelatedTeamMember {        
        public Id userId {get;set;}
        public String teamMemberRole {get;set;}
    } 
    
    public class OpportunityTeamMemberHandlerException extends Exception{}
}