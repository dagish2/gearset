/************************************************************************************************************************************
   	Author 		: Dipak Pawar
   	Description : This class Contains Unit Tests of AccountQueueTriggerHandler.

   	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR				DETAIL
	1			26 April 2017		Dipak Pawar 		Initial Developement
**************************************************************************************************************************************/

@isTest
public with sharing class AccountQueueTriggerHandlerTest {
    @TestSetup
    static void ininData(){
        SalesConsoleSettings.createSettings();
    }
    /************************************************************************************************************************************
        Author 				: Dipak Pawar
        Description 		: Test method for Restrict Duplicate Records for Account Assignment
        Last Modified Date	: 26 April 2017
        Last Modified By	: Dipak Pawar
	**************************************************************************************************************************************/	
    static testMethod void testRestrictDuplicateRecordsForAccountAssignment() {
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Debug.log('testProfile :: '+testProfile);
        System.assertNotEquals(null, testProfile);
        
        User testUser = new User(Alias = 'testU', Email='testWeworkUser@example.com', 
                                 EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = testProfile.Id, IsActive = true,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testWeworkUser@example.com', CommunityNickname = TestingUtility.createUserCommunityName());
        
        
        insert testUser;
        Debug.log('testUser :: '+testUser);
        System.assertNotEquals(null, testUser.ID);
        
        Map<String, Id> accountRecordType = TestingUtility.getRecordTypeMapByName(Account.sObjectType);
        Debug.log('accountRecordType :: '+accountRecordType);
        
        Account testAccount = new Account(Name = 'TestCompany', RecordTypeId = accountRecordType.get('Mid Market'));
        insert testAccount;
        Debug.log('testAccount : '+testAccount);
        System.assertNotEquals(null, testAccount.Id);
        
        Building__c testMarket = new Building__c(
            Name='Test Market',
            uuid__c = 'testUUID'
        );
        insert testMarket;
        Debug.log('testMarket :: '+testMarket);
        System.assertNotEquals(null, testMarket.Id);
        
        List<Market__c> lstMarkets = new List<Market__c>(); 
        lstMarkets.add(new Market__c(Name='Sydney',CurrencyIsoCode='USD'));
        lstMarkets.add(new Market__c(Name='London',CurrencyIsoCode='USD'));
        insert lstMarkets;
        
        Account_Queue__c accountQueueRec = new Account_Queue__c(
            Account_Record_Type__c = 'Consumer',
            Is_Queue_Active__c = true,
            Market__c = testMarket.Name,
            Portfolio__c = lstMarkets[0].Id,
            Member__c = testUser.Id,
            Last_Account_Assigned__c = System.now()
        );
        insert accountQueueRec;
        Debug.log('accountQueueRec :: '+accountQueueRec);
        System.assertNotEquals(null, accountQueueRec.Id);
        
        accountQueueRec = new Account_Queue__c(
            Account_Record_Type__c = 'Enterprise Solutions',
            Is_Queue_Active__c = true,
            Market__c = testMarket.Name,
            Portfolio__c = lstMarkets[0].Id,
            Member__c = testUser.Id,
            Last_Account_Assigned__c = System.now()
        );
        insert accountQueueRec;
        
        accountQueueRec.Account_Record_Type__c = 'Mid Market';
        accountQueueRec.Market__c = 'Test Market';
        accountQueueRec.Member__c = testUser.Id+'';
        accountQueueRec.Last_Account_Assigned__c = system.today().addDays(1);
        update accountQueueRec;
        
        LIst<Account_Queue__c> accQueueRec = [SELECT Id, Account_Record_Type__c, Is_Member_Active__c, Is_Queue_Active__c, Market__c, Member__c FROM Account_Queue__c WHERE Id =:accountQueueRec.Id ];
        Debug.log('accQueueRec :: '+accQueueRec);
        System.assertNotEquals(0, accQueueRec.size());
        
        List<Account_Queue__c> lstToInsert = new List<Account_Queue__c>();
        
        accountQueueRec = new Account_Queue__c(
            Account_Record_Type__c = 'Mid Market',
            Is_Queue_Active__c = true,
            Market__c = testMarket.Name,
            Portfolio__c = lstMarkets[0].Id,
            Member__c = testUser.Id,
            Last_Account_Assigned__c = System.now()
        );
        lstToInsert.add(accountQueueRec);
        
        accountQueueRec = new Account_Queue__c(
            Account_Record_Type__c = 'Enterprise Solutions',
            Is_Queue_Active__c = true,
            Market__c = testMarket.Name,
            Portfolio__c = lstMarkets[0].Id,
            Member__c = testUser.Id,
            Last_Account_Assigned__c = System.now()
        );
        lstToInsert.add(accountQueueRec); 
        
        accountQueueRec = new Account_Queue__c(
            Account_Record_Type__c = 'Enterprise Solutions',
            Is_Queue_Active__c = true,
            Market__c = testMarket.Name,
            Portfolio__c = lstMarkets[0].Id,
            Member__c = testUser.Id,
            Last_Account_Assigned__c = System.now()
        );
        lstToInsert.add(accountQueueRec); 
        Debug.log('lstToInsert :: '+lstToInsert);
        
        try {
            insert lstToInsert;
            Debug.log('lstToInsert :: '+lstToInsert);
        } catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Duplicate Record found') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
}