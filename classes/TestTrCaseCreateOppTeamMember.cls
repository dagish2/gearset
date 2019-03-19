/**
* @author Gad Sharon
* @date 18/10/2018
* @description  Test class for TrCaseCreateOppTeamMember.
**/

@isTest
public class TestTrCaseCreateOppTeamMember {

	public static Trigger_Configuration__mdt config = [Select Active__c, Record_Types_API_Names__c From Trigger_Configuration__mdt Where DeveloperName = 'Case_T1' limit 1];
	public static string recordType = string.isBlank(config.Record_Types_API_Names__c)? null : config.Record_Types_API_Names__c.split(';')[0].ToLowerCase();
	public static boolean isTriggerActive = config.Active__c;
	public static Id queueId = [Select Id From Group Where DeveloperName = 'RealEstateAdvisoryQueue'].Id;
	public static list <User> lstTestUsers = new list <User>();
	public static list <Opportunity> lstOpps = new list<Opportunity>();

	/*
        Scenario: 1. Update case owner from queue to user using an allowed user.
        			The case is related to opportunity that doesn't have the new case owner as opp team member.
        			2. Update from the user in section 1 to another user using an allowed user.
        			3. Update from the user in section 2 to queue.

        
        Expected: 1. A new opportunity team member with the new case owner will be created.
        			2. The team member record for the 1st user will get deleted and a new team
        			member record for the 2nd user will get created.
        			3. The team member record for the 2nds user will get deleted and we will not
        			create a team member record for the queue.

    */

	static testMethod void testUpdateOwenersWithAllowedProfile()
	{
		//Run the test only if the trigger is set as active.
		if(!isTriggerActive)
			return;

		Case testCase = createTestData(1, true, 2)[0];
		set<Id> setIds = new set<Id>{lstTestUsers[0].Id, lstTestUsers[1].Id, queueId};

		//Make sure the test user doesn't have a team member record.
		list <OpportunityTeamMember> lstTeamMembers = getOpportunityTeamMembers(setIds);
		system.assertEquals(lstTeamMembers.size(), 0);

		system.runAs(lstTestUsers[0])
		{
			//Update the 1st test user to be the case owner.
			testCase.OwnerId = lstTestUsers[0].Id;
			update testCase;
		}
		
		//Make sure the test user has a team member record and it's related to the case owner (1st test user).
		lstTeamMembers = getOpportunityTeamMembers(setIds);
		system.assertEquals(lstTeamMembers.size(), 1);
		system.assertEquals(lstTeamMembers[0].UserId, lstTestUsers[0].Id);
		
        //In order to allow the trigger to run once again, clear it from looping mechanism.
		TriggerProcessingManager.mapNumOfIterationsByProcess.remove('TrCaseCreateOppTeamMember');
        //debug.log('lstUsers 0 Query: '+[SELECT Name, Id, Email, Username, Profile.Name, Profile.Id  FROM User WHERE Id =: lstTestUsers[0].Id]);
        //debug.log('testCase before 2nd test user: '+[SELECT Id, Status, OwnerId FROM Case WHERE id =: testCase.Id]);
		system.runAs(lstTestUsers[0])
		{
			//Update the 2nd test user to be the case owner.
			testCase.OwnerId = lstTestUsers[1].Id;
			update testCase;
		}
		//debug.log('testCase after 2nd test user: '+[SELECT Id, Status, OwnerId FROM Case WHERE id =: testCase.Id]);
		//Make sure we still have only one team member and it's related to the case owner (2nd test user).
		lstTeamMembers = getOpportunityTeamMembers(setIds);
		system.assertEquals(lstTeamMembers.size(), 1);
		system.assertEquals(lstTeamMembers[0].UserId, lstTestUsers[1].Id); //New
		
		//In order to allow the trigger to run once again, clear it from looping mechanism.
		TriggerProcessingManager.mapNumOfIterationsByProcess.remove('TrCaseCreateOppTeamMember');
		//debug.log('Queue Query: '+[Select Id, Type, Name, (SELECT Id, UserOrGroupId FROM GroupMembers) From Group Where Id =: queueId]);
		system.runAs(lstTestUsers[0])
		{
			//Update the case owner to be the queue.
			testCase.OwnerId = queueId;
			update testCase;
		}

		//Make sure we don't have any team members.
		lstTeamMembers = getOpportunityTeamMembers(setIds);
		system.assertEquals(lstTeamMembers.size(), 0); //New
	}

	/*
        Scenario: Update case owner from queue to user using a user that doesn't have allowed profile.
        			The case is related to opportunity that doesn't have the new case owner as opp team member.
        
        Expected: We will not create a team member record to the user.
    */

	static testMethod void testUpdateFromQueueToUserNotAllowedProfile()
	{
		//Run the test only if the trigger is set as active.
		if(!isTriggerActive)
			return;

		Case testCase = createTestData(1, false, 1)[0];
		set<Id> setIds = new set<Id>{lstTestUsers[0].Id};

		//Make sure the test user doesn't have a team member record.
		list <OpportunityTeamMember> lstTeamMembers = getOpportunityTeamMembers(setIds);
		system.assertEquals(lstTeamMembers.size(), 0);

		system.runAs(lstTestUsers[0])
		{
			//Update the test user to be the case owner.
			testCase.OwnerId = lstTestUsers[0].Id;
			update testCase;
		}

		//Make sure the test user still doesn't have a team member record.
		lstTeamMembers = getOpportunityTeamMembers(setIds);
		system.assertEquals(lstTeamMembers.size(), 0);
	}

	/*
        Scenario: 1. Update case owners of 25 cases from queue to user using an allowed user.
        			The cases are related to opportunities that don't have the new case owners as opp team member.
        			2. Update all case owners to be the queue.

        Expected: 1. A new opportunity team member with the new case owner will be created to all opps.
        			2. The team members will get deleted and we won't create new ones.
    */

	static testMethod void testUpdateBulkOfCasesFromQueueToUserWithAllowedProfile()
	{
		//Run the test only if the trigger is set as active.
		if(!isTriggerActive)
			return;

        test.startTest();
		list <Case> lstTestCases = createTestData(25, true, 1);
        Debug.Log('lstTestCases--'+lstTestCases);
        Debug.Log('lstTestCases--'+lstTestCases.size());
      
		set<Id> setIds = new set<Id>{lstTestUsers[0].Id};

		//Make sure the test user doesn't have a team member record.
		list <OpportunityTeamMember> lstTeamMembers = getOpportunityTeamMembers(setIds);
		system.assertEquals(lstTeamMembers.size(), 0);

		system.runAs(lstTestUsers[0])
		{
			//Update the test user to be the case owner for all cases.
			for(Case testCase :lstTestCases)
			{
				testCase.OwnerId = lstTestUsers[0].Id;
			}
            update lstTestCases;
        }
        
        TriggerProcessingManager.mapNumOfIterationsByProcess.remove('TrCaseCreateOppTeamMember');
		//Make sure we now have 25 team members, one per each opportunity.
		set <Id> setOppIds = new set <Id>();
		lstTeamMembers = getOpportunityTeamMembers(setIds);
		for(OpportunityTeamMember curMember :lstTeamMembers)
		{
			setOppIds.add(curMember.OpportunityId);
		}
		system.assertEquals(setOppIds.size(), 25);
        test.stopTest();

		system.runAs(lstTestUsers[0])
		{
			//Update the case owner to be the queue for all cases.
			for(Case testCase :lstTestCases)
			{
				testCase.OwnerId = queueId;
			}
			update lstTestCases;
		}

		//Make sure we don't have any team members.
		lstTeamMembers = getOpportunityTeamMembers(setIds);
		system.assertEquals(lstTeamMembers.size(), 0);
	}	
    
    public static list <Case> createTestData(integer numOfCases, boolean allowedUser, integer amountOfUsers)
	{
		SalesConsoleSettings.createSettings();
		list <Case> lstCases = new list <Case>();
		Id profileId;

		if(allowedUser)
		{
			for(string curProfile :Label.AllowedProfilesToManageCases.split(';'))
			{
				//Making sure we're not using the wework system admin profile.
				if(!string.isBlank(curProfile) && !curProfile.containsIgnoreCase('admin'))
				{
					profileId = UtilProfile.getNameToIdMap().get(curProfile);
					break;
				}
			}
		}
		else
		{
			//System admin profile is not in the allowed profiles list to create team members so we're using this profile.
			profileId = UtilProfile.getNameToIdMap().get('System Administrator');
		}
		lstTestUsers.addAll(UtilUser.createUsers(amountOfUsers, profileId, false));
		insert lstTestUsers;

		Account accRec = UtilAccount.GetNewAccountsByRecordType(1, 'Enterprise_Solutions', new Map<String,Object>(), true)[0];
		Contact conRec = UtilContact.GetNewContacts(1, accRec, true)[0];

		for(integer i = 0; i < numOfCases; i++)
		{
			lstOpps.add(UtilOpportunity.GetOppByRecordType(1, 'Enterprise_Solutions', accRec, false)[0]);
		}
		insert lstOpps;

		for(integer i = 0; i < numOfCases; i++)
		{
			lstCases.add(UtilCase.createCaseRelatedToOpp(lstOpps[i].Id, queueId, UtilRecordType.GetSobjectActiveRecordTypes('Case').get(recordType), false));
		}
		insert lstCases;
		return lstCases;
	}

    public static list <OpportunityTeamMember> getOpportunityTeamMembers(set <Id> setIds){       
        return [Select Id, OpportunityId, UserId
                From OpportunityTeamMember
                Where UserId IN :setIds];
    }
}