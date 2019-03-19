/************************************************************************************************************************************
	Author		:	Pragalbha Mahajan
	Description :	To Create multiple Test Records for AccountQueueServices.

	History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                       DETAIL
	1	    	1 Feb 2017	  		Pragalbha Mahajan          	 Initial Developement
**************************************************************************************************************************************/
    @isTest
    public with sharing class AccountQueueServicesTest {
        static Id accRecordtypeMidMarket;
        static Id accRecordtypeConsumer;
        
        /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to setup test data.
    Issue No.			:	ST-3391
	Created Date		:	06 Feb 2019
    **************************************************************************************************************************************/ 
        @testSetup
        static void setup(){
            SalesConsoleSettings.createSettings();
            Region__c objRegion = new Region__c(Name = 'Test Region', Region__c = 'Test Region');
            TestingUtility.insertWithAssert(objRegion, 'Region inserted');
            Territory__c objTerritory = new Territory__c(Name = 'Test Territory', Territory__c =' Test Territory', RegionID__c = objRegion.Id);
            TestingUtility.insertWithAssert(objTerritory, 'Territory inserted');
            
            List<Market__c> lstMarket = new List<Market__c>();
            Market__c objMarket = new Market__c(Name = 'Test Portfolio', Portfolio__c = 'Test Portfolio', TerritoryId__c = objTerritory.Id);
            lstMarket.add(objMarket);
            Market__c objMarket1 = new Market__c(Portfolio__c = 'Pune', Name = 'Pune', Enterprise_Assignment_Override__c = 'Region', TerritoryId__c = objTerritory.Id);
            lstMarket.add(objMarket1);
            Market__c objMarket2 = new Market__c(Portfolio__c = 'Bombay', Name = 'Bombay', Enterprise_Assignment_Override__c = 'Territory', TerritoryId__c = objTerritory.Id);
            lstMarket.add(objMarket2);
            Market__c objMarket3 = new Market__c(Portfolio__c = 'Aurangabad', Name = 'Aurangabad');
            lstMarket.add(objMarket3);
            TestingUtility.insertListWithAssert(lstMarket);
            
            Account acc1 = new Account(Name='Master Account1', Unomy_Company_ID__c = 123456, Unomy_Updated_DateTime__c = Date.today(), Lead_Source__c = 'Test', Account_Type__c = 'Org', Unomy_Location_Address__c = 'USA', Unomy_Location_City__c = 'Seattle', Unomy_Location_State__c = 'Washington', Unomy_Location_Country__c = 'USA', BillingStreet = 'Washington', BillingCity = 'Seattle', BillingState = 'Washington', BillingCountry = 'USA'); 
            TestingUtility.insertWithAssert(acc1, 'Account Not Inserted');
            acc1 = new Account(Name='Master Account2', Unomy_Company_ID__c = 789456, Unomy_Updated_DateTime__c = Date.today(), Lead_Source__c = 'Test', Account_Type__c = 'Org', BillingStreet = 'Washington', BillingCity = 'Seattle', BillingState = 'Washington', BillingCountry = 'USA'); 
            TestingUtility.insertWithAssert(acc1, 'Account Not Inserted');
            
            Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            
            List<User> lstUsers = new List<User>();
            Map<String,Object> userRecordMap = new Map<String,Object>{'LastName' => 'Last Name 1',
               'Username' =>  'testweworkuser1@example.com',
                'Email' => 'testweworkuser1@example.com'};
            lstUsers.add(TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, false));
            
            userRecordMap = new Map<String,Object>{'LastName' => 'Last Name 2',
               'Username' =>  'testweworkuser2@example.com',
                'Email' => 'testweworkuser2@example.com'};
            lstUsers.add(TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, false));
            
            userRecordMap = new Map<String,Object>{'LastName' => 'Last Name 3',
               'Username' =>  'testweworkuser3@example.com',
                'Email' => 'testweworkuser3@example.com'};
            lstUsers.add(TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, false));
            
            TestingUtility.insertListWithAssert(lstUsers);
            
            accRecordtypeMidMarket = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
            accRecordtypeConsumer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
            
            List<Account_Queue__c> lstAccountQueues = new List<Account_Queue__c>();
            
            Map<String, Object> mapAccountQueues = new Map<String, Object>{'Member__c' => lstUsers[1].Id,
                'Account_Record_Type__c' => 'Mid Market',
                'Last_Account_Assigned__c' => Date.today(),
                'Market__c' => lstMarket[0].Name,
                'Portfolio__c' => lstMarket[0].Id,
                'Is_Queue_Active__c' => true};
            lstAccountQueues.add((Account_Queue__c)TestingUtility.createTestRecords(Account_Queue__c.sObjectType, mapAccountQueues, false));
            
            mapAccountQueues = new Map<String, Object>{'Member__c' => lstUsers[0].Id,
                'Account_Record_Type__c' => 'Consumer',
                'Last_Account_Assigned__c' => Date.today(),
                'Market__c' => lstMarket[1].Name,
                'Portfolio__c' => lstMarket[1].Id,
                'Is_Queue_Active__c' => true};
            lstAccountQueues.add((Account_Queue__c)TestingUtility.createTestRecords(Account_Queue__c.sObjectType, mapAccountQueues, false));
            
            mapAccountQueues = new Map<String, Object>{'Member__c' => lstUsers[2].Id,
                'Account_Record_Type__c' => 'Enterprise Solutions',
                'Last_Account_Assigned__c' => Date.today(),
                'Market__c' => lstMarket[2].Name,
                'Portfolio__c' => lstMarket[2].Id,
                'Is_Queue_Active__c' => true};
            lstAccountQueues.add((Account_Queue__c)TestingUtility.createTestRecords(Account_Queue__c.sObjectType, mapAccountQueues, false));
            
            TestingUtility.insertListWithAssert(lstAccountQueues);
            debug.log('lstAccountQueues query: '+[SELECT Id, Name, Market__c, Last_Account_Assigned__c, Account_Record_Type__c, Portfolio__c FROM  Account_Queue__c WHERE Id IN: lstAccountQueues]);
            
        }

        /************************************************************************************************************************************
            Author				: 	Pragalbha Mahajan
            Description 		: 	This method is used to verify Queue Owner By Market For Enterprise Solutions
            Last Modified Date  : 	02 Feb 2017
        **************************************************************************************************************************************/               
        static testMethod void testQueueOwnerByMarketForEnterpriseSolutions(){            
            User testuser03 = [Select Id,Name From User Where Username='testweworkuser3@example.com'];
            List<Market__c> lstMarkets = [SELECT Id, Name, Portfolio__c, TerritoryID__c, TerritoryID__r.RegionID__c, Mid_Market_Assignment_Override__c, Enterprise_Assignment_Override__c FROM Market__c]; 
            List<Account_Queue__c> lstAccountQueues = [SELECT Id, Name, Account_Record_Type__c, Last_Account_Assigned__c, Market__c, Portfolio__c, Is_Queue_Active__c FROM Account_Queue__c];
            Id returnUserId = AccountQueueServices.getQueueOwnerByMarketTerritoryOrRegion(new List<String>{'Enterprise Solutions'},String.valueOf(lstMarkets[2].Id), 'Enterprise Solutions');
            System.assertEquals( testuser03.Id, returnUserId);             
        }
        /************************************************************************************************************************************
            Author				:	Pragalbha Mahajan
            Description 		:	This method is used to verify Queue Owner By Market For Consumer
            Last Modified Date  :	02 Feb 2017
        **************************************************************************************************************************************/        
        static testMethod void testQueueOwnerByMarketForConsumer(){
            User testuser01=[Select Id,Name From User Where Username='testweworkuser1@example.com'];
            List<Market__c> lstMarkets = [SELECT Id, Name, Portfolio__c, TerritoryID__c, TerritoryID__r.RegionID__c, Mid_Market_Assignment_Override__c, Enterprise_Assignment_Override__c FROM Market__c];
            List<Account_Queue__c> lstAccountQueues = [SELECT Id, Name, Account_Record_Type__c, Last_Account_Assigned__c, Market__c, Portfolio__c, Is_Queue_Active__c FROM Account_Queue__c];
            Id returnUserId = AccountQueueServices.getQueueOwnerByMarketTerritoryOrRegion(new List<String>{'Consumer'}, String.valueOf(lstMarkets[1].Id), 'Consumer');
            System.assertEquals( testuser01.Id, returnUserId);             
        }
        /************************************************************************************************************************************
        	Author				:	Pragalbha Mahajan
            Description 		:	This method is used to Queue Owner By Market For Mid Market
            Last Modified Date  :	02 Feb 2017
        **************************************************************************************************************************************/        
        static testMethod void testQueueOwnerByMarketForMidMarket(){
            User testuser02=[Select Id,Name From User Where Username='testweworkuser2@example.com'];
            List<Market__c> lstMarkets = [SELECT Id, Name, Portfolio__c, TerritoryID__c, TerritoryID__r.RegionID__c, Mid_Market_Assignment_Override__c, Enterprise_Assignment_Override__c FROM Market__c]; 
            Id returnUserId = AccountQueueServices.getQueueOwnerByMarket(new List<String>{'Mid Market'},String.valueOf(lstMarkets[0].Id));
            System.assertEquals( testuser02.Id, returnUserId);    
            AccountQueueServices.updateAccountQueues();//This is added to increase coverage
        }
    }