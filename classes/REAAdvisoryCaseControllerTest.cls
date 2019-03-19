/************************************************************************************************************************************
Author		 	:	Rohit Nimase
Description 	:	This class verifies business logic for REAAdvisoryCase validations
---------------------------------------------------------------------------------------------------------------------------------------------
VERSION	  	DATE	          			AUTHOR                      DETAIL
1	     	21 November 2018			Rohit Nimase            	Initial Developement
**************************************************************************************************************************************/
@isTest
public class REAAdvisoryCaseControllerTest{
    /************************************************************************************************************************************
Author		 	:	Rohit Nimase
Description 	:	This Method creates test data
---------------------------------------------------------------------------------------------------------------------------------------------
VERSION	  	DATE	          			AUTHOR                      DETAIL
1	     	21 November 2018			Rohit Nimase            	Initial Developement
**************************************************************************************************************************************/
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        Test.startTest();
        List<Account> lstAccounts = TestingUtility.createAccounts(1,'strAccountName', true);
        Contact conRec = new Contact(
            firstname = 'John',
            lastname = 'Rambo',
            email = 'test@example.com',
            accountID = lstAccounts[0].Id,
            Status__c = 'active'
        );
        TestingUtility.insertWithAssert(conRec);
        
        lstAccounts[0].Primary_Member__c = conRec.Id;
        TestingUtility.updateWithAssert(lstAccounts[0]);
        
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Opportunity oppRec1 = TestingUtility.createOpportunity(lstAccounts[0].Id, false);
        oppRec1.Primary_Member__c = conRec.Id;
        oppRec1.StageName = 'Closed Won';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.Amount = 150;
        oppRec1.REA_Case_Status__c = '';
        oppRec1.RecordTypeId = oppRecordType.get('Consumer');
        lstOpportunity.add(oppRec1);
        
        Opportunity oppRec2 = TestingUtility.createOpportunity(lstAccounts[0].Id, false);
        oppRec2.Primary_Member__c = conRec.Id;
        oppRec2.StageName = 'Selling';
        oppRec2.CloseDate = system.today().addDays(5);
        oppRec2.REA_Case_Status__c = 'Open';
        oppRec2.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        lstOpportunity.add(oppRec2);
        
        Opportunity oppRec3 = TestingUtility.createOpportunity(lstAccounts[0].Id, false);
        oppRec3.Primary_Member__c = conRec.Id;
        oppRec3.StageName = 'Qualifying';
        oppRec3.CloseDate = system.today().addDays(5);
        oppRec3.REA_Case_Status__c = '';
        oppRec3.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        lstOpportunity.add(oppRec3);
        
        TestingUtility.insertListWithAssert(lstOpportunity);
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
Author		 	:	Rohit Nimase
Description 	:	This Method verifies checkValidOppForREAAdvisoryCase method
---------------------------------------------------------------------------------------------------------------------------------------------
VERSION	  	DATE	          			AUTHOR                      DETAIL
1	     	21 November 2018			Rohit Nimase            	Initial Developement
**************************************************************************************************************************************/
    static testMethod void testCheckValidOppForREAAdvisoryCase(){
        List<Opportunity> lstOpportunities = [SELECT Id, AccountId, OwnerId, Name, StageName, REA_Case_Status__c, RecordTypeId, RecordType.Name FROM Opportunity WHERE StageName = 'Closed Won' OR StageName = 'Selling' OR StageName = 'Qualifying'];
        DatabaseResult result1 = REAAdvisoryCaseController.checkValidOppForREAAdvisory(lstOpportunities[0].Id);
        DatabaseResult result2 = REAAdvisoryCaseController.checkValidOppForREAAdvisory(lstOpportunities[1].Id);
        DatabaseResult result3 = REAAdvisoryCaseController.checkValidOppForREAAdvisory(lstOpportunities[2].Id);
        
        Map<String, Object> res1 = (Map<String, Object>)result1.data;
        System.assertEquals(false, res1.get('isValid'));
        System.assertEquals('REA case cannot be opened on Closed Opportunity.', res1.get('message'));
        Map<String, Object> res2 = (Map<String, Object>)result2.data;
        System.assertEquals(false, res2.get('isValid'));
        System.assertEquals('Only one REA case can be opened per Opportunity.', res2.get('message'));
        Map<String, Object> res3 = (Map<String, Object>)result3.data;
        System.assertEquals(true, res3.get('isValid'));
        System.assertNotEquals(null, res3.get('opportunity'));
    }
}