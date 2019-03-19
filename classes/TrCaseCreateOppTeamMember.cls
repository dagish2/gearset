/**
* @author Gad Sharon    
* @date 08/11/18
* @description If the case owner changes and is a user and not a queue we do the following:
				Check if the previous owner of the case was a user.
					If so, replace the opportunity team member record of the related opp from the previous owner to the new owner.
					If not, create a new opportunity team member record of the related opp
				Runs on after update.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* @author      - 
* @date        - 
* @description - 
* --------------------------------------------------------------------------------------
*/

public without sharing class TrCaseCreateOppTeamMember implements IProcessHandler {

	/**
    * @author Gad Sharon
    * @date 08/11/18
    * @description Main logic of the trigger.
    * @param list<sObject> - records from trigger.new list.
    		 map<Id, sObject> - Records from trigger.oldMap. 
    * @return None.
    */

	public void handle(list<sObject> triggerNew, map<Id, sObject> triggerOldMap)
	{
		map <Id, list <TrCaseCreateOppTeamMember.CaseOwners>> mapOppIdToCaseOwners = filter((list<Case>)triggerNew, triggerOldMap);
		//Check if we found relevant records in the trigger.
		if(!mapOppIdToCaseOwners.isEmpty())
		{
			//Get current opportunity team members.
			map <Id, map <Id, OpportunityTeamMember>> mapOppIdToMapTeamMembers = getOpportunityTeamMembers(mapOppIdToCaseOwners.keySet());
			//Create/delete opportunity team members.
			manageOppTeamMembers(mapOppIdToCaseOwners, mapOppIdToMapTeamMembers);
		}
	}

	/**
    * @author Gad Sharon
    * @date 08/11/18
    * @description Find relevant cases we need to run the logic on.
    * @param List<Case> - The cases this trigger is running on.
    		 Map<Id, sObject> - The old stage of the cases this trigger is running on.
    * @return map <Id, list <TrCaseCreateOppTeamMember.CaseOwners>> - Map of opportunity Id to it's related cases that we need to create for them team members. 
    */

	public map <Id, list <TrCaseCreateOppTeamMember.CaseOwners>> filter(list<Case> triggerNew, map<Id, sObject> triggerOldMap)
	{
        map <Id, list <TrCaseCreateOppTeamMember.CaseOwners>> mapOppIdToCaseOwners = new map <Id, list <TrCaseCreateOppTeamMember.CaseOwners>>();
        
        for(Case curCase : triggerNew)
        {
           
            if(caseToProcess(curCase, (Case)triggerOldMap.get(curCase.Id)))
            {                
                //If we don't already have this opp as a key in the map, add it to the map.
                if(!mapOppIdToCaseOwners.containsKey(curCase.Opportunity__c))
        		{
        			mapOppIdToCaseOwners.put(curCase.Opportunity__c, new list <TrCaseCreateOppTeamMember.CaseOwners>());
        		}

        		//Create a CaseOwners instance with the previous (if exists) and new (if exists) case owners. Add this instance to the map of opp id to case owners.
        		TrCaseCreateOppTeamMember.CaseOwners curOwners = new TrCaseCreateOppTeamMember.CaseOwners();
        		curOwners.newOwner = string.valueOf(curCase.OwnerId.getSobjectType()) == 'User' ? curCase.OwnerId : null;
        		curOwners.previousOwner = string.valueOf(((Id)triggerOldMap.get(curCase.Id).get('OwnerId')).getSobjectType()) == 'User' ? (Id)triggerOldMap.get(curCase.Id).get('OwnerId') : null;
        		mapOppIdToCaseOwners.get(curCase.Opportunity__c).add(curOwners);
        	}
        }      
        return mapOppIdToCaseOwners;
    }

	/**
    * @author Gad Sharon
    * @date 08/11/18
    * @description Get team members so we can delete them according to the new case owner.
    * @param set <Id> - Set of opp ids we need to get their related team members.
    * @return map <Id, map <Id, OpportunityTeamMember>> - Map of opp Id to map of user id to it's related team member record. 
    */

    public map <Id, map <Id, OpportunityTeamMember>> getOpportunityTeamMembers (set <Id> setOppIds)
    {
    	map <Id, map <Id, OpportunityTeamMember>> mapOppIdToMapTeamMembers = new map <Id, map <Id, OpportunityTeamMember>>();

    	//Get opportunity team members from the DB.
    	list <OpportunityTeamMember> lstOppTeamMembers = [Select Id, UserId, OpportunityId
    													  From OpportunityTeamMember 
    													  Where OpportunityId IN :setOppIds];
		//Go through team members from the DB and map them per opportunity and per user.
    	for(OpportunityTeamMember curTeamMember :lstOppTeamMembers)
    	{
    		if(!mapOppIdToMapTeamMembers.containsKey(curTeamMember.OpportunityId))
    		{
    			mapOppIdToMapTeamMembers.put(curTeamMember.OpportunityId, new map<Id, OpportunityTeamMember>());
    		}

    		mapOppIdToMapTeamMembers.get(curTeamMember.OpportunityId).put(curTeamMember.UserId, curTeamMember);
    	}

    	return mapOppIdToMapTeamMembers;
    }

    /**
    * @author Gad Sharon
    * @date 08/11/18
    * @description Create/delete opp team members according to the old and new case owners.
    * @param map <Id, list <TrCaseCreateOppTeamMember.CaseOwners>> - Map of opp id to it's list of new and old case owners related to that opp.
    * @param map <Id, map <Id, OpportunityTeamMember>> - Map of opp Id to map of user id to it's related team member record. 
    * @return None. 
    */

    public void manageOppTeamMembers (map <Id, list <TrCaseCreateOppTeamMember.CaseOwners>> mapOppIdToCaseOwners, map <Id, map <Id, OpportunityTeamMember>> mapOppIdToMapTeamMembers)
    {
        list <OpportunityTeamMember> lstTeamMembersToInsert = new list <OpportunityTeamMember>();
        list <OpportunityTeamMember> lstTeamMembersToDelete = new list <OpportunityTeamMember>();            
        //Go through the opps ids of the opps we need to create/delete their team members.
        for(Id curId :mapOppIdToCaseOwners.keySet())
        {
    		set <Id> setNewOwnerIds = new set <Id>();

    		//Go through the case owners related to this opportunity.
    		for(TrCaseCreateOppTeamMember.CaseOwners curOwners :mapOppIdToCaseOwners.get(curId))
    		{
                map <Id, OpportunityTeamMember> mapOppIdToTeamMember = mapOppIdToMapTeamMembers.get(curId);
    			//If we have owner we'll need to delete this team member record.
                if(mapOppIdToTeamMember != null && mapOppIdToTeamMember.containsKey(curOwners.previousOwner))
                {                   
                    lstTeamMembersToDelete.add(mapOppIdToTeamMember.get(curOwners.previousOwner));
                }

	    		//We have a new case owner we need to create team member record for.
	    		if(curOwners.newOwner != null &&
	    			(mapOppIdToTeamMember == null || !mapOppIdToTeamMember.containsKey(curOwners.newOwner)))
	    		{
	    			setNewOwnerIds.add(curOwners.newOwner);
	    		}
    		}

    		//Create new team members if we need to.
    		if(!setNewOwnerIds.isEmpty())
    		{
    			lstTeamMembersToInsert.addAll(createTeamMembers(setNewOwnerIds, curId));
    		}
    	}        
        delete lstTeamMembersToDelete;
        insert lstTeamMembersToInsert;
    }

    /**
    * @author Gad Sharon
    * @date 08/11/18
    * @description Create opp team members according to the new case owner.
    * @param set<Id> - The ids of the new owners of the cases we need to create team members for.
    * @param Id - The opp id this team member is related to.
    * @return list<OpportunityTeamMember> - The opp team members records we need to create. 
    */

    public list<OpportunityTeamMember> createTeamMembers (set <Id> setNewOwnerIds, Id oppId)
    {
    	list <OpportunityTeamMember> lstTeamMembers = new list <OpportunityTeamMember>();

    	for(Id newOwner :setNewOwnerIds)
    	{
	    	OpportunityTeamMember teamMember = new OpportunityTeamMember();

			teamMember.TeamMemberRole = 'Real Estate Advisory';
			teamMember.OpportunityId = oppId;
			teamMember.OpportunityAccessLevel = 'Read';
	    	teamMember.UserId = newOwner;

	    	lstTeamMembers.add(teamMember);
	    }
    	
    	return lstTeamMembers;
    }

    /**
    * @author Gad Sharon
    * @date 22/11/18
    * @description Check if we should process a case or not.
    * @param case - The current state of the case.
    * @param case - The previous state of the case.
    * @return boolean - True if we need to process the case, false otherwise. 
    */

    private boolean caseToProcess (Case newCaseState, Case oldCaseState)
    {
        boolean ownerChanged = newCaseState.OwnerId != oldCaseState.OwnerId;

        boolean ownerIsOrWasUser =  (string.valueOf(newCaseState.OwnerId.getSobjectType()) == 'User') || 
                                    (string.valueOf(oldCaseState.OwnerId.getSobjectType()) == 'User');

        boolean relevantRelatedOpp = newCaseState.Opportunity_RecordType_Developer_Name__c == 'Enterprise_Solutions';

        boolean allowedUserProfile = Label.AllowedProfilesToManageCases.toLowerCase().contains(';' + UtilProfile.getIdToNameMap().get(UserInfo.getProfileId()).toLowerCase() + ';');

        return ownerChanged && ownerIsOrWasUser && relevantRelatedOpp && allowedUserProfile;
    }


    /*
    Custom class to hold the previous and new owners of case.
    */

    public class CaseOwners
    {
    	Id previousOwner;
    	Id newOwner;
    }

}