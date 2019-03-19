/************************************************************************************************************************************
    Author 		: Dipak Pawar
    Description : This class will contain the Test Methods of UserTrigger.
	Issue No.	: ST-542,  ST-682 
    History		: --

----------------------------------------------------------------------------------------------------------------------------------
	VERSION					DATE					AUTHOR							DETAIL
	1					    09,Sept 2016		    Dipak Pawar	                	Initial Developement
	2						26,Sept 2016			Dipak Pawar						--
**************************************************************************************************************************************/
@isTest
public class UserTriggerHandlerTest {    
    @testSetup 
    public static void setup() {
        SalesConsoleSettings.createSettings();  
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];		
        User testUser1 = new User(Alias = 'testU', Email='testUser09092016_1@example.com', 
                                  EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = testProfile.Id, IsActive = true,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='testUserName09092016_1@example.com',
                                  CommunityNickname ='Test1'+System.now());
        insert testUser1;
        User testUser2 = new User(Alias = 'testU', Email='testUser09092016_2@example.com', 
                                  EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = testProfile.Id, IsActive = true,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='testUserName09092016_2@example.com',
                                  CommunityNickname ='Test2'+System.now());
        insert testUser2;
        Lead testLead = new Lead(FirstName = 'Test',
                                 LastName = 'Lead',
                                 Company = 'TestCompany',
                                 Status = 'Open',
                                 Locations_Interested__c = 'B1; B2;',
                                 Office_Type__c = 'Shared Desk; DailyDesk;',
                                 Email = 'test@example.com',
                                 OwnerId = testUser1.Id);
        insert testLead;
    }
    
    public static testMethod void testQueryGenerator() { 
        String query = UserTriggerHandler.queryGenerator('Account',new List<String>{'Id','Name'},'123456789',false,Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap());
        String expected = 'SELECT Id,Name FROM Account WHERE Id = \'123456789\' OR Name LIKE \'%123456789%\'';
        System.assertEquals(expected, query);
        query = UserTriggerHandler.queryGenerator('Account',new List<String>{'Name'},'123456789',true,Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap());
        expected = 'SELECT Id,Name,Name FROM Account';
        System.assertEquals(expected, query);
    }
}