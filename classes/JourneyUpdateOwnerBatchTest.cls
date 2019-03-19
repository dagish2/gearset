/*
* Created By : Amol Darekar
* Date : 20/Dec/2016
*/
@isTest
public class JourneyUpdateOwnerBatchTest {
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
    }
    static void createUsers() 
    {
        /*List<Setting__c> lstSettings = new List<Setting__c>();
        lstSettings.add(new Setting__c(Name = 'AccountCleansingSetting',Data__c = '{"starts_with":["The","An","A"],"ends_with":["pvt","ltd"],"specialCharacters":"@#^&*!():?/><"}'));
        Insert lstSettings;*/
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 1');
        userRecordMap.put('Username','testweworkuser1@example.com');
        userRecordMap.put('Email','testweworkuser1@example.com');
        User testUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true); 
        
        userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 2');
        userRecordMap.put('Username','testweworkuser2@example.com');
        userRecordMap.put('Email','testweworkuser2@example.com');
        User testUser1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true);   
        
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'User/Queue Journey Creation';
        testSettings.Data__c = '{"allowedUsers":[{"userName":"'+ testUser.Username +'","Id":"'+testUser.Id +'"},{"userName":"'+ testUser1.Username +'","Id":"'+testUser1.Id +'"}],"allowedQueues":[]}';//{"Id":"'+ testGroup1.Id +'","queueName":"'+ testGroup1.Name +'"}
        TestingUtility.insertWithAssert(testSettings);
    }
    static testMethod void updateJourenyOwnerTest() {
        createUsers();
        Lead lead = new Lead();
        Lead lead1 = new Lead();
        Journey__c[] journeys;
        string leadId;
        Lead[] leads;
        Task[] tasks;
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, u);
        
        User u1 = [Select Id from user where username =:'testweworkuser2@example.com']; 
        system.assertNotEquals(null, u1); 
        
       // lead = LeadConvertorTest.prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);       
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker1123';
        lead.ownerId = u.Id;
        lead.Lead_Source_Detail__c = 'Broker1123';
        lead.Email = 'testLead1@example.com';
        lead.LastName = 'Smith';
        insert lead; 
        
        Journey__c testJourney1 = new Journey__c();
        testJourney1.Name = 'testJourney';
        testJourney1.NMD_Next_Contact_Date__c = Date.today();
        testJourney1.Primary_Lead__c = lead.Id;
        testJourney1.Status__c = 'Started';
        testJourney1.ownerId = u1.Id;  
        testJourney1.Lead_Source__c = 'Event';
        insert testJourney1;
        
       // lead = LeadConvertorTest.prepareLead('Smith', 'WeWork Test Company', 'testLead2@example.com', null);      
        lead1.Company = 'Test Company';
        lead1.Generate_Journey__c = true;
        lead1.LeadSource= 'Broker123';
        lead1.ownerId = u.Id;
        lead1.Lead_Source_Detail__c = 'Broker1123';
        lead1.Email = 'testLead2@example.com';
        lead1.LastName = 'Smith';
        insert lead1;
        
        Journey__c testJourney2 = new Journey__c();
        testJourney2.Name = 'testJourney';
        testJourney2.NMD_Next_Contact_Date__c = Date.today();
        testJourney2.Primary_Lead__c = lead1.Id;
        testJourney2.Status__c = 'Started';
        testJourney2.ownerId = u1.Id;  
        testJourney2.Lead_Source__c = 'Event';
        insert testJourney2;
        
        Test.setCreatedDate(lead1.Id,system.today().addDays(-2));  
        
        Test.startTest();
        JourneyUpdateOwnerBatch Jowner = new JourneyUpdateOwnerBatch();
        Database.executeBatch(Jowner,2); 
        Database.QueryLocator ql = Jowner.start(null);
        Jowner.execute(null);
        Jowner.Finish(null);
        Test.stopTest();
        
        //First Journey ownerID should get changed because it's lead is created within 1 hour
        //Second lead is created before 2 days even if journey is created within one hour it's owner Id do not update.
        list<Journey__c> testLstUpdatedJourneys = [SELECT Id, OwnerId, Primary_Lead__c,Primary_Contact__c FROM Journey__c order by CreatedDate asc];
        System.assertEquals(u.Id, testLstUpdatedJourneys[0].OwnerId); 
        System.assertEquals(u.Id, testLstUpdatedJourneys[1].OwnerId);  
        
    }
}