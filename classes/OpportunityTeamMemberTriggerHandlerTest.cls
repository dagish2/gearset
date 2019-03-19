/********************************************************************************************************************************
	Author 		: Milanjeet Singh
	Description : Add Opportunity Team Member on Opportunity Creation.
	History		: --

	Issue No. 	: ST-1599
----------------------------------------------------------------------------------------------------------------------------------
	VERSION					DATE						AUTHOR 							DETAIL
	1						--						    Milanjeet Singh 			Initial Developement
******************************************************************************************************************************************/

@isTest
public class OpportunityTeamMemberTriggerHandlerTest {
    
    
/***********************************************************************************************************************************
	Author 				: Milanjeet Singh
	Description			: Mid Market SFDC Role ends with "Key Sales”.
	Enterprise ends with “Enterprise Solutions”.
	Sales Lead SFDC Role starts with "LEAD -“
	Created Date		:	--
	Issue No. 			: ST-1599
	Last Modified By 	: Prashant Mane
	Last Modified Date  : 02 Feb,2018
***********************************************************************************************************************************/ 
    @TestSetup
    Static void initData(){
        SalesConsoleSettings.createSettings();
        Test.startTest();
        setupData();
        Test.stopTest();
     
        List<User> lstUsers= [SELECT Id, Name, ProfileId, Profile.Name, UserRoleId, UserRole.Name FROM User WHERE Email = 'testUser_EnterprizeUser@example.com' OR Email = 'testUser_KeySalesUser@example.com' OR Email = 'testUser_LeadUser@example.com'
                              OR Email = 'testUser_StandardUser@example.com' OR Email = 'testUser_standarduser1@example.com' OR Email = 'testUser_standarduser2@example.com'];
        List<Account> lstAccount = new List<Account>();
        List<Contact> lstContact = new List<Contact>();
        
        System.runAs(lstUsers[1]){
        Account testAccount1 = TestingUtility.createAccount('WeWork1', true);
        Contact objContact1 = new contact(firstname ='Paul1', lastname = 'Boss1', email = 'paul1@example.com', AccountId = testAccount1.id, uuid__c = 'xxx123');
        TestingUtility.insertWithAssert(objContact1);
        Opportunity objOpportunity1 = new Opportunity(name = 'test oppty1', AccountId = testAccount1.id, Primary_Member__c = objContact1.id, stageName = 'Selling',closeDate = System.today() ); 
        TestingUtility.insertWithAssert(objOpportunity1);
        }
        
        System.runAs(lstUsers[0]){
        Account testAccount2 = TestingUtility.createAccount('WeWork2', false);
        testAccount2.Allow_Merge__c = false;
        testAccount2.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        TestingUtility.insertWithAssert(testAccount2);
        Contact objContact2 = new contact(firstname ='Paul2',lastname = 'Boss2', email = 'paul2@example.com', AccountId = testAccount2.id, uuid__c = 'xxx223');
        TestingUtility.insertWithAssert(objContact2);
        Opportunity objOpportunity2 = new Opportunity( name = 'test oppty2', AccountId = testAccount2.id, Primary_Member__c = objContact2.id, stageName = 'Selling',closeDate = System.today() );  
        TestingUtility.insertWithAssert(objOpportunity2);
        }
        
        System.runAs(lstUsers[2]){
        Account testAccount3 = TestingUtility.createAccount('WeWork3', false);
        testAccount3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        TestingUtility.insertWithAssert(testAccount3);
        Contact objContact3 = new contact(firstname = 'Paul3',lastname = 'Boss3', email = 'paul3@example.com', AccountId = testAccount3.id, uuid__c = 'xxx224');
        TestingUtility.insertWithAssert(objContact3);
		Opportunity objOpportunity3 = new Opportunity( name = 'test oppty3', AccountId = testAccount3.id, Primary_Member__c = objContact3.id, stageName = 'Selling',closeDate = System.today() ); 
        TestingUtility.insertWithAssert(objOpportunity3);
        } 
    }
    
/*************************************************************************************************
	Author 				: Milanjeet Singh
	Description 		: Test Method To Verify Update Split Percentage
	Created Date		:	--
	Issue No. 			: ST-1599
	Last Modified By 	: Prashant Mane
	Last Modified Date  : 02 Feb,2018
****************************************************************************************************/ 
    public static testmethod void verifyUpdate_Split_Percentage(){
        Set<Id> lstOppoId = new Set<Id>();
        List<UserRole> lstUserRoles=new List<UserRole>();
        
        Test.startTest();
        lstUserRoles=[SELECT Id, Name FROM UserRole WHERE Name = 'Enterprise Solutions' OR Name Like '%Key Sales%' OR Name Like '%LEAD -%' OR Name Like '%Admin%' ];    
        List<Opportunity> lstOpportunity = [SELECT Id, Name, Owner.LastName, Owner.UserRole.Name,(SELECT Id, User.UserRole.Name, Split_Rep_Percentage__c FROM OpportunityTeamMembers) FROM opportunity WHERE Account.Name='Wework1' OR Account.Name='Wework2' OR Account.Name='Wework3'];
        for(Opportunity objOpportunity : lstOpportunity){
            lstOppoId.add(objOpportunity.Id);
        }
        
        List<OpportunityTeamMember> lstOpptyTeamMember = [SELECT Id, User.UserRole.Name, Split_Rep_Percentage__c FROM OpportunityTeamMember WHERE OpportunityId IN :lstOppoId ]; 
        System.assertNotEquals(0, lstOpptyTeamMember.size());
        Test.stopTest();
        System.assertEquals(lstUserRoles[0].Name, lstOpptyTeamMember[1].User.UserRole.Name);
        System.assertEquals(0, lstOpptyTeamMember[1].Split_Rep_Percentage__c);

        System.assertEquals(lstUserRoles[1].Name, lstOpptyTeamMember[0].User.UserRole.Name);
        System.assertEquals(0, lstOpptyTeamMember[1].Split_Rep_Percentage__c);
        
        System.assertEquals(lstUserRoles[2].Name, lstOpptyTeamMember[2].User.UserRole.Name);
        System.assertEquals(100, lstOpptyTeamMember[2].Split_Rep_Percentage__c);        
       
    }
    
/*******************************************************************************************************************************/  
    public static testmethod void ChangeOpenOppCasesOwner(){
        
        Test.startTest();
        List<User> lstUsers= [SELECT Id, Name, ProfileId, Profile.Name, UserRoleId, UserRole.Name FROM User WHERE Email = 'testUser_standarduser1@example.com' OR Email = 'testUser_standarduser2@example.com'];
        
        List<Account> lstTestAccount=[SELECT Id, Name FROM Account WHERE Name = 'WeWork1' OR Name = 'WeWork2'];
        Contact objContact2=[SELECT Id, Name FROM Contact WHERE Email = 'paul2@example.com']; 
        
        Case_Template__c caseTemplateRec = new Case_Template__c(
            Name = 'Proposal',
            Default_Owner__c = 'Queue:testGroup', 
            Record_Type_Name__c = 'Legal Counsel ', 
            Opportunity_Stages__c = 'Selling;Negotiating;Closing',
            Owner_Role__c ='test',
            Triggering_Object__c = 'Opportunity'
        );  
        TestingUtility.insertWithAssert(caseTemplateRec);
       
        Map<String,Object> oppoValuesMap = new Map<String,Object>{ 'Name' =>'TestOppo1','Primary_Member__c' => objContact2.Id,'StageName' => 'Selling',
            'CurrencyIsoCode' => 'USD'  ,'CloseDate' => system.today().addDays(5),
            'RecordTypeId' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId(),
            'Membership_Agreement_Notes__c' => 'Opprtunity 2 Membership_Agreement_Notes__c','Description' => 'Opprtunity 2 Tour_Notes__c',
            'Locations_Interested__c' => 'Test1;Test2;','Amount' => 10 };
                Opportunity TestOppo1=TestingUtility.createOpportunity(oppoValuesMap, false);
        
        TestingUtility.insertWithAssert(TestOppo1); 
        
        List<Opportunity> lstOpportunity = [SELECT Id, Name, Description, Membership_Agreement_Notes__c FROM opportunity WHERE Amount = 10 LIMIT 1];
        
        Case objCase = new Case(Status='New Submission',
                                OwnerId = lstUsers[0].Id,
                                Opportunity__c = lstOpportunity[0].Id,
                                AccountId = lstTestAccount[1].Id,
                                RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Enterprise Finance & Strategy').getRecordTypeId(),
                                Requested_Type__c = caseTemplateRec.Name
                               );
        
        TestingUtility.insertWithAssert(objCase);
        System.assertNotEquals(null, objCase.Id);
        
        List<OpportunityTeamMember> lstOppTeams = new List<OpportunityTeamMember>();
       
        OpportunityTeamMember objOppTeam1 = new OpportunityTeamMember(
            OpportunityId   = lstOpportunity[0].Id,
            TeamMemberRole = 'Sales Rep',
            UserId = lstUsers[0].Id
        );
        lstOppTeams.add(objOppTeam1);
        
        OpportunityTeamMember objOppTeam2 = new OpportunityTeamMember(
            OpportunityId   = lstOpportunity[0].Id,
            TeamMemberRole = 'Legal Counsel',
            UserId = lstUsers[0].Id
        );
        lstOppTeams.add(objOppTeam2);
        TestingUtility.insertListWithAssert(lstOppTeams);
        
        for(OpportunityTeamMember objOppTeam : lstOppTeams)
            system.assertNotEquals(null, objOppTeam.Id);
        System.assertEquals(1, [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId=:lstOpportunity[0].Id].size());
        
        delete objOppTeam2;
        Test.stopTest();
        
        OpportunityTeamMember objOppTeam = new OpportunityTeamMember(
            OpportunityId   = lstOpportunity[0].Id,
            TeamMemberRole = 'Legal Counsel',
            UserId = lstUsers[1].Id
        );
        TestingUtility.insertWithAssert(objOppTeam);
        System.assertNotEquals(null, objOppTeam.Id);
        
        case caseRec = [SELECT Id,OwnerId FROM Case];
        System.assertEquals(caseRec.OwnerId,lstUsers[1].Id);
        
    }
    
    @future
    public static void setupData(){
            List<UserRole> lstUserRole=new List<UserRole>();
            List<User> lstUser = new List<User>();
            
            List<Profile> lstUserProfile = [SELECT Id, Name FROM Profile WHERE Name IN('WeWork NMD User','Standard User')];
            lstUserRole = [SELECT Id, Name FROM UserRole WHERE Name = 'Enterprise Solutions' OR Name Like '%Key Sales%' OR Name Like '%LEAD -%' OR Name Like '%Admin%' ];
            Map<String, Object> mapUserValues = TestingUtility.getUserMapValues('EnterprizeUser');
            mapUserValues.put('UserRoleId', lstUserRole[0].Id);
            lstUser.add((User)TestingUtility.insertUserWithAssert(lstUserProfile[1].Id, mapUserValues, false));
    
            mapUserValues=TestingUtility.getUserMapValues('KeySalesUser');
            mapUserValues.put('UserRoleId', lstUserRole[1].Id);
            lstUser.add((User)TestingUtility.insertUserWithAssert(lstUserProfile[1].Id, mapUserValues, false));
           
            mapUserValues=TestingUtility.getUserMapValues('LeadUser');
            mapUserValues.put('UserRoleId', lstUserRole[2].Id);
            lstUser.add((User)TestingUtility.insertUserWithAssert(lstUserProfile[1].Id, mapUserValues, false));
        
            mapUserValues=TestingUtility.getUserMapValues('StandardUser');
            mapUserValues.put('UserRoleId', lstUserRole[3].Id);
            lstUser.add((User)TestingUtility.insertUserWithAssert(lstUserProfile[1].Id, mapUserValues, false));
            
            mapUserValues=TestingUtility.getUserMapValues('standarduser1');
            lstUser.add((User)TestingUtility.insertUserWithAssert(lstUserProfile[0].Id, mapUserValues, false));
            
            mapUserValues=TestingUtility.getUserMapValues('standarduser2');
            lstUser.add((User)TestingUtility.insertUserWithAssert(lstUserProfile[0].Id, mapUserValues, false));
        
            TestingUtility.insertListWithAssert(lstUser); 
     }
}