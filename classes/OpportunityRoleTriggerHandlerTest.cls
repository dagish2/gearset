/************************************************************************************************************************************
    Author 		: Dipak Pawar
    Description : Tets class for OpportunityRoleTriggersHandler class
    
    History		:
----------------------------------------------------------------------------------------------------------------------------------
    VERSION	  DATE	         AUTHOR        DETAIL
    1	      12,May 2017	 Dipak Pawar   Initial Developement
**************************************************************************************************************************************/

@isTest
global class OpportunityRoleTriggerHandlerTest {    
    static{
        SalesConsoleSettings.createSettings();      
    }
    
    
        /************************************************************************************************************************************
    Author 				:
    Issue No 			:
    Description 		: This Method for update Opportunity Role.
    Created Date 		:
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/

    @isTest
    public static void testUpdateOpportunityRole(){
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
         
        Account accRec = TestingUtility.createAccount('strAccountName', true);
       
        Debug.log('accRec :: '+accRec);
        System.assertNotEquals(null, accRec.Id);
        
        Contact conRec1 = new Contact(
            FirstName  = 'John',
            LastName   = 'Rambo',
            Email     = 'testContact1@example.com',
            AccountId  = accRec.Id
        );
        insert conRec1;
        Debug.log('conRec1 :: '+conRec1);
        System.assertNotEquals(null, conRec1.Id);
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec1.Primary_Member__c = conRec1.Id;
        oppRec1.StageName = 'Qualifying';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.Amount = 150;
        oppRec1.RecordTypeId = oppRecordType.get('Consumer');
        TestingUtility.insertWithAssert(oppRec1);
        Debug.log('oppRec1 :: '+oppRec1);
        System.assertNotEquals(null, oppRec1.Id);
        
        
        List<Opportunity_Role__c> lstOpportunityRoles = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE Opportunity__c =:oppRec1.Id ];
        Debug.log('lstOpportunityRoles 1 :: '+lstOpportunityRoles);
        System.assertEquals(1, lstOpportunityRoles.size());
        System.assertEquals(oppRec1.Id, lstOpportunityRoles[0].Opportunity__c);
        System.assertEquals(conRec1.Id, lstOpportunityRoles[0].Contact__c);
        System.assertEquals(true, lstOpportunityRoles[0].Is_Primary_Member__c);
        System.assertEquals('Primary Member', lstOpportunityRoles[0].Role__c);
        
        Opportunity_Role__c oppRoleRec1 = new Opportunity_Role__c(
            Opportunity__c = lstOpportunityRoles[0].Opportunity__c,
            Contact__c = lstOpportunityRoles[0].Contact__c,
            Is_Primary_Member__c = true,
            Role__c = 'Primary Role'
        );
        
        try {
            insert oppRoleRec1;
            Debug.log('oppRoleRec1 :: '+oppRoleRec1);
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Opportunity role with same opportunity and contact is already present') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }	    
        
        lstOpportunityRoles = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE Opportunity__c =:oppRec1.Id ];
        Debug.log('lstOpportunityRoles 2 :: '+lstOpportunityRoles);
        System.assertEquals(1, lstOpportunityRoles.size());
        System.assertEquals(oppRec1.Id, lstOpportunityRoles[0].Opportunity__c);
        System.assertEquals(conRec1.Id, lstOpportunityRoles[0].Contact__c);
        System.assertEquals(true, lstOpportunityRoles[0].Is_Primary_Member__c);
        oppRoleRec1 = lstOpportunityRoles[0];
        
        Contact conRec2 = new Contact(
            FirstName  = 'John',
            LastName   = 'Rambo',
            Email     = 'testContact2@example.com',
            AccountId  = accRec.Id
        );
        insert conRec2;
        Debug.log('conRec2 :: '+conRec2);
        System.assertNotEquals(null, conRec2.Id);
        
        Opportunity_Role__c oppRoleRec2 = new Opportunity_Role__c(
            Opportunity__c = oppRec1.Id,
            Contact__c = conRec2.Id,
            Is_Primary_Member__c = true,
            Role__c = 'Primary Role'
        );
        insert oppRoleRec2;
        Debug.log('oppRoleRec2 :: '+oppRoleRec2);
        System.assertNotEquals(null, oppRoleRec2.Id);
        
        lstOpportunityRoles = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE Opportunity__c =:oppRec1.Id ];
        Debug.log('lstOpportunityRoles 3 :: '+lstOpportunityRoles);
        System.assertEquals(2, lstOpportunityRoles.size());
        for(Opportunity_Role__c oppRole : lstOpportunityRoles) {
            if(conRec1.Id == oppRole.Contact__c){
                System.assertEquals(false, oppRole.Is_Primary_Member__c);
            } else if(conRec2.Id == oppRole.Contact__c){
                System.assertEquals(true, oppRole.Is_Primary_Member__c);
            }
        }
        
        oppRoleRec1.Is_Primary_Member__c = true;
        update oppRoleRec1;
        
        lstOpportunityRoles = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE  Opportunity__c =:oppRec1.Id ];
        Debug.log('lstOpportunityRoles 4 :: '+lstOpportunityRoles);
        System.assertEquals(2, lstOpportunityRoles.size());
        for(Opportunity_Role__c oppRole : lstOpportunityRoles) {
            if(conRec1.Id == oppRole.Contact__c){
                System.assertEquals(true, oppRole.Is_Primary_Member__c);
            } else if(conRec2.Id == oppRole.Contact__c){
                System.assertEquals(false, oppRole.Is_Primary_Member__c);
            }
        }
        
        oppRoleRec1.Contact__c = conRec2.Id;
        oppRoleRec1.Is_Primary_Member__c = true;
        try {
            update oppRoleRec1;
            Debug.log('oppRoleRec1 :: '+oppRoleRec1);
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Opportunity role with same opportunity and contact is already present') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }	
    }
    
        /************************************************************************************************************************************
    Author 				: Krishana Tupe
    Issue No 			: ST-1340
    Description 		: Test method checks the Opportunity Roles and Contatc Role of Opportunity should be sync.
    Created Date 		: 11 Nov, 2017
    Last Modified Date	: 02 Feb, 2018
    Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/

    @isTest
    public static void testInsertOrUpdateOpportunityContactRole(){
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);        
        List<Account> lstAccountsTestInsertUpdate=new List<Account>();
        Account accRec = TestingUtility.createAccount('strAccountName1', true);
        Account accRec1 = TestingUtility.createAccount('strAccountName2', true);
        Account accRec2 = TestingUtility.createAccount('strAccountName3', true);
        Debug.log('accRec :: '+accRec);
        System.assertNotEquals(null, accRec.Id);
        
        Contact conRec1 = new Contact(
            FirstName  = 'Test',
            LastName   = 'Contact',
            Email     = 'testContact1@example.com',
            AccountId  = accRec.Id
        );        
        insert conRec1;
        System.assertNotEquals(null, conRec1.Id);
        Contact conRec2 = new Contact(
            FirstName  = 'Test',
            LastName   = 'Contact1',
            Email     = 'testContact2@example.com',
            AccountId  = accRec1.Id
        );        
        insert conRec2;
        System.assertNotEquals(null, conRec2.Id);
        Contact conRec3 = new Contact(
            FirstName  = 'Test',
            LastName   = 'Contact2',
            Email     = 'testContact3@example.com',
            AccountId  = accRec2.Id
        );        
        insert conRec3;
        Debug.log('conRec3 :: '+conRec3.Id);
        System.assertNotEquals(null, conRec3.Id);
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec1.Primary_Member__c = conRec1.Id;
        oppRec1.StageName = 'Qualifying';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.Amount = 150;
        oppRec1.RecordTypeId = oppRecordType.get('Consumer');
        TestingUtility.insertWithAssert(oppRec1);
        Debug.log('oppRec1 :: '+oppRec1);
        System.assertNotEquals(null, oppRec1.Id);
    
        List<Opportunity_Role__c> lstOpportunityRoleForContactRole = new  List<Opportunity_Role__c>();
        lstOpportunityRoleForContactRole.add(new Opportunity_Role__c(Contact__c=conRec2.Id,Opportunity__c=oppRec1.Id,Role__c='Influencer',Is_Primary_Member__c=false));
        lstOpportunityRoleForContactRole.add(new Opportunity_Role__c(Contact__c=conRec3.Id,Opportunity__c=oppRec1.Id,Role__c='Broker',Is_Primary_Member__c=false));
        
        insert lstOpportunityRoleForContactRole;
        
        List<Opportunity_Role__c> lstOpportunityRoles = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE Opportunity__c =:oppRec1.Id ];
        List<OpportunityContactRole> lstOpportunityContactRoles=[SELECT Id,ContactId,OpportunityId,Role,IsPrimary From OpportunityContactRole WHERE OpportunityId=:oppRec1.Id];
        Debug.log('lstOpportunityRoles ==> '+lstOpportunityRoles);
      //lstOpportunityContactRoles = lstOpportunityContactRoles.sort();
        Debug.log('lstOpportunityContactRoles ==> '+lstOpportunityContactRoles);
        Debug.log('lstOpportunityContactRoles Size ==> '+lstOpportunityContactRoles.size());
        System.assertEquals(3, lstOpportunityContactRoles.size());
        System.assertEquals(3, lstOpportunityRoles.size());
        System.assertEquals(oppRec1.Id, lstOpportunityRoles[0].Opportunity__c);
        System.assertEquals(conRec1.Id, lstOpportunityRoles[0].Contact__c);
        System.assertEquals(true, lstOpportunityRoles[0].Is_Primary_Member__c);
        System.assertEquals('Primary Member', lstOpportunityRoles[0].Role__c);
        
        System.assertEquals(oppRec1.Id, lstOpportunityRoles[1].Opportunity__c);
        System.assertEquals(conRec2.Id, lstOpportunityRoles[1].Contact__c);
        System.assertEquals(false, lstOpportunityRoles[1].Is_Primary_Member__c);
        System.assertEquals('Influencer', lstOpportunityRoles[1].Role__c);
        
        System.assertEquals(oppRec1.Id, lstOpportunityRoles[2].Opportunity__c);
        System.assertEquals(conRec3.Id, lstOpportunityRoles[2].Contact__c);
        System.assertEquals(false, lstOpportunityRoles[2].Is_Primary_Member__c);
        System.assertEquals('Broker', lstOpportunityRoles[2].Role__c);
        
        System.assertEquals(oppRec1.Id, lstOpportunityContactRoles[0].OpportunityId);
        System.assertEquals(conRec1.Id, lstOpportunityContactRoles[0].ContactId);
        System.assertEquals(true, lstOpportunityContactRoles[0].IsPrimary);
        System.assertEquals('Primary Member', lstOpportunityContactRoles[0].Role);
        
        System.assertEquals(oppRec1.Id, lstOpportunityContactRoles[1].OpportunityId);
        System.assertEquals(conRec2.Id, lstOpportunityContactRoles[1].ContactId);
        System.assertEquals(false, lstOpportunityContactRoles[1].IsPrimary);
        System.assertEquals('Influencer', lstOpportunityContactRoles[1].Role);
        
        System.assertEquals(oppRec1.Id, lstOpportunityContactRoles[2].OpportunityId);
        System.assertEquals(conRec3.Id, lstOpportunityContactRoles[2].ContactId);
        System.assertEquals(false, lstOpportunityContactRoles[2].IsPrimary);
        System.assertEquals('Broker', lstOpportunityContactRoles[2].Role);
        
        delete lstOpportunityRoles[0];
        
        List<Opportunity_Role__c> lstNotDeletedOpportunityRoles = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE Opportunity__c =:oppRec1.Id ];
        List<OpportunityContactRole>lstNotDeletedOpportunityContactRoles=[SELECT Id,ContactId,OpportunityId,Role,IsPrimary From OpportunityContactRole WHERE OpportunityId=:oppRec1.Id];
        System.assertEquals(2, lstNotDeletedOpportunityRoles.size());
        System.assertEquals(2, lstNotDeletedOpportunityContactRoles.size());
        debug.log('lstNotDeletedOpportunityRoles==>'+lstNotDeletedOpportunityRoles);
        debug.log('lstNotDeletedOpportunityContactRoles==>'+lstNotDeletedOpportunityContactRoles);
        
        lstNotDeletedOpportunityRoles[0].Is_Primary_Member__c=false;
        lstNotDeletedOpportunityRoles[0].Contact__c=conRec1.Id;
        lstNotDeletedOpportunityRoles[0].Role__c='Decision Maker';
        
        update lstNotDeletedOpportunityRoles;
        List<Opportunity_Role__c> lstUpdatedOpportunityRoles = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE Opportunity__c =:oppRec1.Id ];
        List<OpportunityContactRole>lstUpdatedOpportunityContactRoles=[SELECT Id,ContactId,OpportunityId,Role,IsPrimary From OpportunityContactRole WHERE OpportunityId=:oppRec1.Id];
        System.assertEquals(2, lstUpdatedOpportunityRoles.size());
        System.assertEquals(2, lstUpdatedOpportunityContactRoles.size()); 
        debug.log('lstUpdatedOpportunityRoles==>'+lstUpdatedOpportunityRoles);
        debug.log('lstUpdatedOpportunityContactRoles==>'+lstUpdatedOpportunityContactRoles);
        
        System.assertEquals(oppRec1.Id, lstUpdatedOpportunityContactRoles[0].OpportunityId);
        System.assertEquals(conRec1.Id, lstUpdatedOpportunityContactRoles[0].ContactId);
        System.assertEquals(false, lstUpdatedOpportunityContactRoles[0].IsPrimary);
        System.assertEquals('Decision Maker', lstUpdatedOpportunityContactRoles[0].Role);
        
        System.assertEquals(oppRec1.Id, lstUpdatedOpportunityContactRoles[1].OpportunityId);
        System.assertEquals(conRec3.Id, lstUpdatedOpportunityContactRoles[1].ContactId);
        System.assertEquals(false, lstUpdatedOpportunityContactRoles[1].IsPrimary);
        System.assertEquals('Broker', lstUpdatedOpportunityContactRoles[1].Role);
        
       
        
        System.assertEquals(oppRec1.Id, lstUpdatedOpportunityRoles[0].Opportunity__c);
        System.assertEquals(conRec1.Id, lstUpdatedOpportunityRoles[0].Contact__c);
        System.assertEquals(false, lstUpdatedOpportunityRoles[0].Is_Primary_Member__c);
        System.assertEquals('Decision Maker', lstUpdatedOpportunityRoles[0].Role__c);
        
        System.assertEquals(oppRec1.Id, lstUpdatedOpportunityRoles[1].Opportunity__c);
        System.assertEquals(conRec3.Id, lstUpdatedOpportunityRoles[1].Contact__c);
        System.assertEquals(false, lstUpdatedOpportunityRoles[1].Is_Primary_Member__c);
        System.assertEquals('Broker', lstUpdatedOpportunityRoles[1].Role__c);
        
        Test.startTest();
        Opportunity oppRec2 = TestingUtility.createOpportunity(accRec.Id, false);        
        oppRec2.Primary_Member__c = conRec1.Id;
        oppRec2.StageName = 'Qualifying';
        oppRec2.CloseDate = system.today().addDays(5);
        oppRec2.Amount = 150;
        oppRec2.RecordTypeId = oppRecordType.get('Consumer');
        TestingUtility.insertWithAssert(oppRec2);
        Debug.log('oppRec1 :: '+oppRec1);
        System.assertNotEquals(null, oppRec2.Id);
        
        lstUpdatedOpportunityRoles[0].Opportunity__c=oppRec2.Id;
        lstUpdatedOpportunityRoles[0].Contact__c=conRec3.Id;
        lstUpdatedOpportunityRoles[0].Is_Primary_Member__c=false;
        lstUpdatedOpportunityRoles[0].Role__c='Influencer';
        update lstUpdatedOpportunityRoles;        
        Test.stopTest();
        
        List<Opportunity_Role__c> lstUpdatedOpportunityRoles1 = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE Opportunity__c =:oppRec1.Id ];
        List<OpportunityContactRole>lstUpdatedOpportunityContactRoles1=[SELECT Id,ContactId,OpportunityId,Role,IsPrimary From OpportunityContactRole WHERE OpportunityId=:oppRec1.Id];
        System.assertEquals(1, lstUpdatedOpportunityRoles1.size());
        System.assertEquals(1, lstUpdatedOpportunityContactRoles1.size());
        
        List<Opportunity_Role__c> lstUpdatedOpportunityRoles2 = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE Opportunity__c =:oppRec2.Id ORDER BY Role__C DESC];
        List<OpportunityContactRole>lstUpdatedOpportunityContactRoles2=[SELECT Id,ContactId,OpportunityId,Role,IsPrimary From OpportunityContactRole WHERE OpportunityId=:oppRec2.Id];
        System.assertEquals(2, lstUpdatedOpportunityRoles2.size());
        System.assertEquals(2, lstUpdatedOpportunityContactRoles2.size());
        debug.log('lstUpdatedOpportunityRoles2==>'+lstUpdatedOpportunityRoles2);
        debug.log('lstUpdatedOpportunityContactRoles2==>'+lstUpdatedOpportunityContactRoles2);
        debug.log('conRec1.Id==>'+conRec1.Id);
        debug.log('conRec3.Id==>'+conRec3.Id);
        
        System.assertEquals(oppRec2.Id, lstUpdatedOpportunityContactRoles2[0].OpportunityId);
        System.assertEquals(conRec1.Id, lstUpdatedOpportunityContactRoles2[0].ContactId);
        System.assertEquals(true, lstUpdatedOpportunityContactRoles2[0].IsPrimary);
        System.assertEquals('Primary Member', lstUpdatedOpportunityContactRoles2[0].Role);
        
        System.assertEquals(oppRec2.Id, lstUpdatedOpportunityContactRoles2[1].OpportunityId);
        System.assertEquals(conRec3.Id, lstUpdatedOpportunityContactRoles2[1].ContactId);
        System.assertEquals(false, lstUpdatedOpportunityContactRoles2[1].IsPrimary);
        System.assertEquals('Influencer', lstUpdatedOpportunityContactRoles2[1].Role);
        
        System.assertEquals(oppRec2.Id, lstUpdatedOpportunityRoles2[0].Opportunity__c);
        System.assertEquals(conRec1.Id, lstUpdatedOpportunityRoles2[0].Contact__c);
        System.assertEquals(true, lstUpdatedOpportunityRoles2[0].Is_Primary_Member__c);
        System.assertEquals('Primary Member', lstUpdatedOpportunityRoles2[0].Role__c);
        
        System.assertEquals(oppRec2.Id, lstUpdatedOpportunityRoles2[1].Opportunity__c);
        System.assertEquals(conRec3.Id, lstUpdatedOpportunityRoles2[1].Contact__c);
        System.assertEquals(false, lstUpdatedOpportunityRoles2[1].Is_Primary_Member__c);
        System.assertEquals('Influencer', lstUpdatedOpportunityRoles2[1].Role__c);
    }  
}