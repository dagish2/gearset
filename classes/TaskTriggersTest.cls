@isTest
private class TaskTriggersTest {
    /*static{
        SalesConsoleSettings.createSettings();  
    }
    static Boolean settingsInitialized = false;
   
    
    static void initFieldMappings() {
        Debug.turnDebugOn();
        
        if( settingsInitialized )
            return;
        
        Settings.FieldMappings leadToContactMappings = new Settings.FieldMappings();
        leadToContactMappings.version = 1;
        leadToContactMappings.mappings = new Map<String, Settings.MappedField>();
        leadToContactMappings.mappings.put('Name', new Settings.MappedField('Name'));
        leadToContactMappings.mappings.put('Email', new Settings.MappedField('Email'));
        Settings.saveFieldMappings( 'LeadToContact', leadToContactMappings);
        
        Settings.FieldMappings leadToJourneyMappings = new Settings.FieldMappings();
        leadToJourneyMappings.version = 1;
        leadToJourneyMappings.mappings = new Map<String, Settings.MappedField>();
        leadToJourneyMappings.mappings.put('Name', new Settings.MappedField('Name'));
        leadToJourneyMappings.mappings.put('Lead_Source__c', new Settings.MappedField('LeadSource'));
        Settings.saveFieldMappings( 'LeadToJourney', leadToJourneyMappings);
        Debug.log('leadToJourneyMappings:'+leadToJourneyMappings); 
        
        Settings.FieldMappings leadToActivityMappings = new Settings.FieldMappings();
        leadToActivityMappings.version = 1;
        leadToActivityMappings.mappings = new Map<String, Settings.MappedField>();
        leadToJourneyMappings.mappings.put('Lead_Source__c', new Settings.MappedField('LeadSource'));
        Settings.saveFieldMappings( 'LeadToActivity', leadToActivityMappings);
        
        Account account = new Account(Name = 'Dummy Lead Conversion Account');
        insert account;

        Setting__c[] settingsToInsert = new List<Setting__c>();
        
        
       
        Building__c testBuilding = new Building__c(
            City__c = 'Test',
            uuid__c = 'abc123',
            Name = 'Test Building'
            
        );
        insert testBuilding;
        settingsInitialized = true;
        
    }
    
	
    static testMethod void testUpdateLeadEngagementFields() {
        
        Lead l = new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test',Phone = '1236547890',Email = 'samsung@example.com' );
        insert l;
        
        Task t = new Task(WhoId = l.Id, Subject = 'Engage Campaign:');
        insert t;
        
        l = [select Engage_Emails_Sent__c, Last_Engage_Email_Sent__c from Lead where Id = :l.Id];
        t = [select CreatedDate from Task where Id = :t.Id];
        
        System.assertEquals(1, l.Engage_Emails_Sent__c);
        System.assertEquals(t.CreatedDate, l.Last_Engage_Email_Sent__c);
    }


    static testMethod void testupdateJourneyStageField() {
        
        
        Account accRec = new Account();
        accRec.Name='Test Account' ;
        insert accRec;
        
        Contact conRec1 = new Contact();
        conRec1.AccountId = accRec.Id;
        conRec1.firstname = 'TestFirstName';
        conRec1.lastname = 'TestLastName';
        conRec1.Email = 'Test111@example.com';
        conRec1.Status__c = 'active';
        
        insert conRec1;
        
        Lead l = new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test',Phone ='7894562359',Email='herohonda@example.com');
        insert l;
        
        Journey__c newTestJourney = new Journey__c();
        newTestJourney.Name = 'Test Samadhan';
        newTestJourney.Status__c = 'Started';
        newTestJourney.Primary_Contact__c = conRec1.Id;
        newTestJourney.NMD_Next_Contact_Date__c = Date.today();
        insert newTestJourney;
        
        
        Task testTask = new Task(Status = 'Not Started',Priority = 'Normal',Subject = 'Call',whatId  = newTestJourney.Id);
        insert testTask;
        
        testTask.CallDisposition = 'Do Not Call'; 
        update testTask;
        
        journey__c journey = [SELECT Id, Status__c FROM Journey__c WHERE Id=:newTestJourney.Id];
        system.assertEquals('Unqualified',journey.Status__c);
        
       
        Referral__c reference1 = new Referral__c();
        reference1.Referral_Email__c = 'whoid1@example.com';
        reference1.IsActive__c = true;
        reference1.Referrer__c = conRec1.Id;
        reference1.Expires_On__c = Date.today().addDays(10);
        TestingUtility.insertWithAssert(reference1);
        
        Contact conForWhoId1 = new Contact();
        conForWhoId1.AccountId = accRec.Id;
        conForWhoId1.firstname = 'conForWhoId1';
        conForWhoId1.lastname = 'conForWhoId1LastName';
        conForWhoId1.Email = 'whoid1@example.com';
        conForWhoId1.Status__c = 'active';
        insert conForWhoId1;
        
        Task taskWithReferrer1 = new Task(Status = 'Not Started',Priority = 'Normal',Subject = 'Call',whoId  = conForWhoId1.Id);
        insert taskWithReferrer1;
        
        System.assertEquals(conRec1.Id, [SELECT Id, Referrer__c FROM Task WHERE Id=:taskWithReferrer1.Id].Referrer__c);
        
    }

	
    static testMethod void testUpdateNextNMDContactDateOnJourney() 
    {
        
        Account accRec = new Account();
        accRec.Name='Test Account' ;
        insert accRec;
        
        Contact conRec1 = new Contact();
        conRec1.AccountId = accRec.Id;
        conRec1.firstname = 'TestFirstName';
        conRec1.lastname = 'TestLastName';
        conRec1.Email = 'Test111@example.com';
        conRec1.Status__c = 'active';
        
        insert conRec1;
      
            
        list<Journey__c> lstTestJourny = new list<Journey__c>();
        set<Id> setJourneyWhatIds = new set<Id>(); 
        
        Journey__c objTestJourny1 = new Journey__c();
        objTestJourny1.Name = 'Test Customer1';
        objTestJourny1.Status__c = 'Started';
        objTestJourny1.Primary_Contact__c = conRec1.Id;
        objTestJourny1.NMD_Next_Contact_Date__c =Date.today();
        TestingUtility.insertWithAssert(objTestJourny1);
        
        Task testTask = new Task();
        testTask.Type = 'Call';
        testTask.Subject = 'Follow-Up';
        testTask.TaskSubtype = 'Task';
        testTask.Status = 'In Progress';
        testTask.Priority = 'Normal';
        testTask.whatId = objTestJourny1.Id;
        testTask.CallDisposition = 'Left VM';
        Date before_60_days = Date.Today().addDays(-14);
        testTask.ActivityDate = before_60_days;
        TestingUtility.insertWithAssert(testTask);
        testTask.Status = 'Not Started';
        TestingUtility.updateWithAssert(testTask);
        
        setJourneyWhatIds.add(testTask.whatId);
        Debug.log('SetofWhatIds*******************'+setJourneyWhatIds.size());
        
        Task testTask1 = new Task();
        testTask1.Type = 'Call';
        testTask1.TaskSubtype = 'Task';
        testTask1.whatId = objTestJourny1.Id;
        testTask1.Priority = 'Normal';
        testTask1.Subject = 'test Subject';
        testTask1.CallDisposition = 'Call in one week';
        testTask1.Status = 'In Progress';
        TestingUtility.insertWithAssert(testTask1);
        testTask1.Status = 'In Progress';
        TestingUtility.updateWithAssert(testTask1);
        
        Task testTask3 = new Task();
      
        testTask3.TaskSubtype = 'Task';
        testTask3.whatId = objTestJourny1.Id;
        testTask3.Status = 'Deferred';
        testTask3.Priority = 'Normal';
        testTask3.Subject = 'Subject';
        testTask3.CallDisposition = 'Call in one week';
        testTask3.Status = 'In Progress';
        TestingUtility.insertWithAssert(testTask3);
        TestingUtility.updateWithAssert(testTask3);
        
        Journey__c objTestJourny2 = new Journey__c();
        objTestJourny2.Name = 'Test Customer1';
        objTestJourny2.Status__c = 'Started';
        objTestJourny2.Primary_Contact__c = conRec1.Id;
        objTestJourny2.NMD_Next_Contact_Date__c = Date.today().addDays(-2);
        TestingUtility.insertWithAssert(objTestJourny2);
      
        Task testTask4 = new Task();
        testTask4.Type = 'Call';
        testTask4.TaskSubtype = 'Task';
        testTask4.whatId = objTestJourny2.Id;
        testTask4.Status = 'Completed';
        testTask4.Priority = 'Normal';
        testTask4.Subject = 'Subject';
        testTask4.CallDisposition = 'Call in one week';
        TestingUtility.insertWithAssert(testTask4);
        testTask4.Status = 'In Progress';
        TestingUtility.updateWithAssert(testTask4);
        
        Task testTask5 = new Task();
        testTask5.Type = 'Call';
        testTask5.TaskSubtype = 'Task';
        testTask5.whatId = objTestJourny2.Id;
        testTask5.Status = 'Not Started';
        testTask5.Priority = 'Normal';
        testTask5.Subject = 'Subject';
        testTask5.CallDisposition = 'No Answer/Busy';
        TestingUtility.insertWithAssert(testTask5);
        testTask5.Status = 'Completed';
        TestingUtility.updateWithAssert(testTask5);
    }

	
    static testMethod void testChangeTaskOwner(){
        set<Id> setWhatIds = new set<Id>();
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u2 = new User(Alias = 'newUser1', Email='newuser123@testorg.com', 
                               EmailEncodingKey='UTF-8', LastName='Testing123', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = p.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='newuser123@testorg.com',
                               CommunityNickname = 'TEst67'+TestingUtility.createUserCommunityName());
            
            User testUser = TestUtility.createTestUser();
            Group group1 = new Group(Name='group name', type='Queue');
            insert group1;
            
            QueuesObject q1 = new QueueSObject(QueueID = group1.id, SobjectType = 'Lead');
            insert q1;
            
            QueuesObject q2 = new QueueSObject(QueueID = group1.id, SobjectType = 'Journey__c');
            insert q2;
            
            GroupMember member = new GroupMember();
            member.UserOrGroupId = testUser.Id;
            member.GroupId = group1.Id;
            insert member;
            
            System.runAs(testUser) {
                
                Lead lead1 = new Lead(OwnerId=q1.QueueID,FirstName = 'Test', LastName = 'Test', Company = 'Test',Phone = '9874563210',Email='honda@example.com');
                insert lead1;
                
                Account accRec = TestingUtility.createAccount('strAccountName', true);
                
               
                
                Contact conRec1 = new Contact();
                conRec1.AccountId = accRec.Id;
                conRec1.firstname = 'TestFirstName';
                conRec1.lastname = 'TestLastName';
                conRec1.Email = 'Test120@example.com';
                conRec1.Status__c = 'active';
                
                insert conRec1; 
                
                Journey__c journey = new Journey__c();
                journey.Name = 'TestJourney';
                journey.NMD_Next_Contact_Date__c = Date.today();
                journey.Primary_Lead__c = lead1.Id;
                
                insert journey;
                
                Contact con =[select Id from Contact where Id=:conRec1.Id];
                debug.log('Contact Id ::'+con.Id);
               
                
                Test.startTest();
                Lead lead111 = [select Id,OwnerId,LastName from Lead where Id=:lead1.Id];
                debug.log('Lead ownerId and Id from Test Method '+lead111.OwnerId+' '+lead111.Id);
                
                list<Journey__c> lstTestJourny = new list<Journey__c>();
                set<Id> setWhoId = new Set<Id>();
                
                Journey__c objTestJourny1 = new Journey__c();
                objTestJourny1.Name = 'Test Customer1';
                objTestJourny1.Status__c = 'Completed';
                objTestJourny1.Primary_Lead__c = lead111.Id;
                objTestJourny1.NMD_Next_Contact_Date__c = Date.today();
                objTestJourny1.OwnerId = q1.QueueID;
                TestingUtility.insertWithAssert(objTestJourny1);
                
                Journey__c objTestJourny2 = new Journey__c();
                objTestJourny2.Name = 'Test Customer1';
                objTestJourny2.Status__c = 'Completed';
                objTestJourny2.Primary_Contact__c = conRec1.Id;
                objTestJourny2.NMD_Next_Contact_Date__c =Date.today();
                objTestJourny1.OwnerId = q1.QueueID;
                TestingUtility.insertWithAssert(objTestJourny2);
                
                Task testTask = new Task();
                testTask.whoId = conRec1.Id;
                testTask.Type = 'Call';
                testTask.Status = 'Started';
                testTask.Priority = 'Normal';
                testTask.whatId = objTestJourny1.Id;
                testTask.CallDisposition = 'Left VM';
                testTask.Subject = 'other';
               
                insert testTask;
                
                testTask.Status = 'Call';
                testTask.Subject = 'other';
                
                update testTask;
                
                Task testTask2 = new Task();
                testTask2.whoId = lead111.Id;
                testTask2.Type = 'Call';
                testTask2.TaskSubtype = 'Call';
                testTask2.Status = 'Started';
                testTask2.Priority = 'Normal';
                testTask2.CallDisposition = 'Left VM';
                testTask2.Subject = 'other';
                insert testTask2;
                
                testTask2.Status = 'Completed';
                testTask2.Subject = 'Call';
                update testTask2;
                
                Task testTask3 = new Task();
                testTask3.whoId = conRec1.Id;
                testTask3.Type = 'Call';
                testTask3.Status = 'Started';
                testTask3.Priority = 'Normal';
                testTask3.whatId = objTestJourny2.Id;
                testTask3.CallDisposition = 'Left VM';
                testTask3.Subject = 'other';
                insert testTask3;
                
                testTask3.Status = 'Call';
                testTask3.Subject = 'other';
                
                update testTask3;
                
                Id currentUserId = testUser.Id;
                
                List<Lead> updatedLead = new List<Lead>([Select Id,OwnerId From Lead Where Id =: lead111.Id]);
                System.assertEquals(updatedLead[0].OwnerId, testUser.Id);
                
                List<Journey__c> updatedJourney = new List<Journey__c>([Select Id,OwnerId From Journey__c Where Id =: objTestJourny1.Id]);
                System.assertEquals(updatedJourney[0].OwnerId, testUser.Id);
                Test.stopTest();
            }
        }
    }

	
    static testMethod void testUpdateOutreachStageOnJourney() {
        Account testAccount = TestingUtility.createAccount('TestAccountName', true);
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.firstname = 'TestFirstName';
        testContact.lastname = 'TestLastName';
        testContact.Email = 'TestContact@example.com';
        testContact.Status__c = 'active';            
        insert testContact; 
        
        Journey__c testJourney1 = new Journey__c();
        testJourney1.Name = 'TestJourney1';
        testJourney1.NMD_Next_Contact_Date__c = Date.today();
        testJourney1.Primary_Contact__c = testContact.Id;
        testJourney1.Outreach_Stage__c = 'Call 1';
        testJourney1.Status__c = 'Started';
        insert testJourney1;
        
        Journey__c testJourney2 = new Journey__c();
        testJourney2.Name = 'TestJourney2';
        testJourney2.NMD_Next_Contact_Date__c = Date.today();
        testJourney2.Primary_Contact__c = testContact.Id;
        testJourney2.Outreach_Stage__c = 'Call 1';
        testJourney2.Status__c = 'Started';
        insert testJourney2;
        
        Journey__c testJourney3 = new Journey__c();
        testJourney3.Name = 'TestJourney3';
        testJourney3.NMD_Next_Contact_Date__c = Date.today();
        testJourney3.Primary_Contact__c = testContact.Id;
        testJourney3.Outreach_Stage__c = 'Call 1';
        testJourney3.Status__c = 'Started';
        insert testJourney3;
        
        Journey__c testJourney4 = new Journey__c();
        testJourney4.Name = 'TestJourney4';
        testJourney4.NMD_Next_Contact_Date__c = Date.today();
        testJourney4.Primary_Contact__c = testContact.Id;
        testJourney4.Outreach_Stage__c = 'Call 5';
        testJourney4.Status__c = 'Started';
        insert testJourney4;
        
        Task testTask = new Task();
        testTask.whoId = testContact.Id;
        testTask.Type = 'Call';
        testTask.Status = 'Completed';
        testTask.Priority = 'Normal';
        testTask.whatId = testJourney1.Id;
        testTask.Subject = 'FastCall outbound call';
        insert testTask;
        
        Journey__c journey1 = [SELECT Id, Outreach_Stage__c FROM Journey__c WHERE Id =: testJourney2.Id limit 1];
        Journey__c journey2 = [SELECT Id, Outreach_Stage__c FROM Journey__c WHERE Id =: testJourney3.Id limit 1];
        Journey__c journey3 = [SELECT Id, Outreach_Stage__c FROM Journey__c WHERE Id =: testJourney4.Id limit 1];
        System.assertEquals('Call 2', journey1.Outreach_Stage__c);
        System.assertEquals('Call 2', journey2.Outreach_Stage__c);
        System.assertEquals('Call 5', journey3.Outreach_Stage__c);
        
        Test.startTest();
        Lead testLead = new Lead(FirstName = 'Test',
                                 LastName = 'Lead',
                                 Company = 'TestCompany',
                                 Status = 'Open',
                                 Locations_Interested__c = 'B1; B2;',
                                 Office_Type__c = 'Shared Desk; DailyDesk;',
                                 Email = 'TestLead@example.com');
        insert testLead;
        
        Journey__c testLeadJourney1 = new Journey__c();
        testLeadJourney1.Name = 'TestJourney1';
        testLeadJourney1.NMD_Next_Contact_Date__c = Date.today();
        testLeadJourney1.Primary_Lead__c = testLead.Id;
        testLeadJourney1.Outreach_Stage__c = '';
        testLeadJourney1.Status__c = 'Started';
        insert testLeadJourney1;
        
        Journey__c testLeadJourney2 = new Journey__c();
        testLeadJourney2.Name = 'TestJourney2';
        testLeadJourney2.NMD_Next_Contact_Date__c = Date.today();
        testLeadJourney2.Primary_Lead__c = testLead.Id;
        testLeadJourney2.Outreach_Stage__c = '';
        testLeadJourney2.Status__c = 'Started';
        insert testLeadJourney2;
        
        Journey__c testLeadJourney3 = new Journey__c();
        testLeadJourney3.Name = 'TestJourney3';
        testLeadJourney3.NMD_Next_Contact_Date__c = Date.today();
        testLeadJourney3.Primary_Lead__c = testLead.Id;
        testLeadJourney3.Outreach_Stage__c = '';
        testLeadJourney3.Status__c = 'Started';
        insert testLeadJourney3;
        
        Journey__c testLeadJourney4 = new Journey__c();
        testLeadJourney4.Name = 'TestJourney4';
        testLeadJourney4.NMD_Next_Contact_Date__c = Date.today();
        testLeadJourney4.Primary_Lead__c = testLead.Id;
        testLeadJourney4.Outreach_Stage__c = 'Call 5';
        testLeadJourney4.Status__c = 'Started';
        insert testLeadJourney4;
        
        Task testLeadTask = new Task();
        testLeadTask.Type = 'Call';
        testLeadTask.Status = 'Completed';
        testLeadTask.Priority = 'Normal';
        testLeadTask.whatId = testLeadJourney1.Id;
        testLeadTask.Subject = 'FastCall outbound call';
        insert testLeadTask;
        
        Journey__c leadJourney1 = [SELECT Id, Outreach_Stage__c FROM Journey__c WHERE Id =: testLeadJourney2.Id limit 1];
        Journey__c leadJourney2 = [SELECT Id, Outreach_Stage__c FROM Journey__c WHERE Id =: testLeadJourney3.Id limit 1];
        Journey__c leadJourney3 = [SELECT Id, Outreach_Stage__c FROM Journey__c WHERE Id =: testLeadJourney4.Id limit 1];
        System.assertEquals('Call 1', leadJourney1.Outreach_Stage__c);
        System.assertEquals('Call 1', leadJourney2.Outreach_Stage__c);
        System.assertEquals('Call 5', leadJourney3.Outreach_Stage__c);
        
        Journey__c testLeadJourney5 = new Journey__c();
        testLeadJourney5.Name = 'TestJourney4';
        testLeadJourney5.NMD_Next_Contact_Date__c = Date.today();
        testLeadJourney5.Primary_Lead__c = testLead.Id;
        testLeadJourney5.Status__c = 'Started';
        insert testLeadJourney5;
        
        Task testTask2 = new Task();
        testTask2.whoId = testContact.Id;
        testTask2.Type = 'Call';
        testTask2.Status = 'Completed';
        testTask2.Priority = 'Normal';
        testTask2.whatId = testLeadJourney5.Id;
        testTask2.Subject = '';
        insert testTask2;
        
        Journey__c leadJourney_BlankSubject = [SELECT Id, Outreach_Stage__c FROM Journey__c WHERE Id =: testLeadJourney5.Id];
        System.assertEquals('Call 1', leadJourney_BlankSubject.Outreach_Stage__c);
        
        Test.stopTest();
    }
    

	
    static testMethod void testUpdateJourneyOnTour() {
        initFieldMappings();
        Account a = new Account(Name = 'Acme', Lead_Source__c = 'Id', UUID__c = 'account-uuid');
        insert a;
        
        Contact testContact = new Contact();
        testContact.firstname = 'TestFirstName';
        testContact.lastname = 'TestLastName';
        testContact.Email = 'TestContact@example.com';
        testContact.Status__c = 'active';  
        testContact.AccountId = a.Id;       
        insert testContact; 
        

        Journey__c testJourney1 = new Journey__c();
        testJourney1.Name = 'TestJourney1';
        testJourney1.NMD_Next_Contact_Date__c = Date.today();
        testJourney1.Primary_Contact__c = testContact.Id;
        testJourney1.Outreach_Stage__c = 'Call 1';
        testJourney1.Status__c = 'Started';
        insert testJourney1;
        
        Tour_Outcome__c tour = new Tour_Outcome__c();
        tour.Scheduled_By__c = testContact.Id;
        tour.Primary_Member__c = testContact.Id;
        tour.Status__c = 'Scheduled';
        tour.Tour_Date__c = system.today().addDays(1);
        tour.Referrer__c = null;
        tour.CurrencyIsoCode = 'MXN';
        insert tour;
        
        testJourney1.Status__c = 'Started';
        update testJourney1;
        Task testTask = new Task();
        testTask.whoId = testContact.Id;
        testTask.Type = 'Call';
        testTask.Status = 'Started';
        testTask.Priority = 'Normal';
        testTask.whatId = tour.Id;
        testTask.CallDisposition = 'Left VM';
        testTask.Subject = 'Book a Tour';
     
        insert testTask;
        
        List<Tour_OutCome__c> lstTourOutCome = [Select Journey__c from Tour_OutCome__c where Id =:tour.Id];
        
        system.assertNotEquals(null,lstTourOutCome[0].Journey__c);
        system.assertEquals(testJourney1.Id,lstTourOutCome[0].Journey__c);
        list<Building__c> testLstBuilding = [Select Id from Building__c where uuid__c =: 'abc123'];
        Tour_Outcome__c tour1 = new Tour_Outcome__c();
        tour1.Scheduled_By__c = testContact.Id;
        tour1.Primary_Member__c = testContact.Id;
        tour1.Status__c = 'Scheduled';
        tour1.Tour_Date__c = system.today().addDays(1);
        tour1.Referrer__c = null;
        tour1.Location__c = testLstBuilding[0].Id;
        tour1.CurrencyIsoCode = 'MXN';

        insert tour1;
        
       
        
        Journey__c testJourney2 = new Journey__c();
        testJourney2.Name = 'TestJourney1';
        testJourney2.NMD_Next_Contact_Date__c = Date.today();
        testJourney2.Primary_Contact__c = testContact.Id;
        testJourney2.Outreach_Stage__c = 'Call 1';
        testJourney2.Status__c = 'Started';
        insert testJourney2;
        
        Journey__c testJourney3 = new Journey__c();
        testJourney3.Name = 'TestJourney1';
        testJourney3.NMD_Next_Contact_Date__c = Date.today();
        testJourney3.Primary_Contact__c = testContact.Id;
        testJourney3.Outreach_Stage__c = 'Call 1';
        testJourney3.Status__c = 'Started';
        testJourney3.Building_Interested_In__c = testLstBuilding[0].Id;
        insert testJourney3;
        
        Test.startTest();
        Task testTask1 = new Task();
        testTask1.whoId = testContact.Id;
        testTask1.Type = 'Call';
        testTask1.Status = 'Started';
        testTask1.Priority = 'Normal';
        testTask1.whatId = tour1.Id;
        testTask1.CallDisposition = 'Left VM';
        testTask1.Subject = 'Book a Tour';
      
        insert testTask1;
        
        lstTourOutCome = [Select Journey__c from Tour_OutCome__c where Id =:tour1.Id];
        system.assertEquals(testJourney3.Id,lstTourOutCome[0].Journey__c);
       
        Journey__c testJourney4 = new Journey__c();
        testJourney4.Name = 'TestJourney1';
        testJourney4.NMD_Next_Contact_Date__c = Date.today();
        testJourney4.Primary_Contact__c = testContact.Id;
        testJourney4.Outreach_Stage__c = 'Call 1';
        testJourney4.Status__c = 'Started';
        testJourney4.Quick_Quote_Location__c = 'abc';
        insert testJourney4;
        
        Tour_Outcome__c tour2 = new Tour_Outcome__c();
        tour2.Scheduled_By__c = testContact.Id;
        tour2.Primary_Member__c = testContact.Id;
        tour2.Status__c = 'Scheduled';
        tour2.Tour_Date__c = system.today().addDays(1);
        tour2.Referrer__c = null;
        tour2.CurrencyIsoCode = 'MXN';
        
        insert tour2;
        
        Task testTask2 = new Task();
        testTask2.whoId = testContact.Id;
        testTask2.Type = 'Call';
        testTask2.Status = 'Started';
        testTask2.Priority = 'Normal';
        testTask2.whatId = tour2.Id;
        testTask2.CallDisposition = 'Left VM';
        testTask2.Subject = 'Book a Tour';
        testTask2.Quick_Quote_Location__c = 'abc';
       
        insert testTask2;
        lstTourOutCome = [Select Journey__c from Tour_OutCome__c where Id =:tour2.Id];
        system.assertEquals(testJourney4.Id,lstTourOutCome[0].Journey__c);
        Test.stopTest();
        
        
    }

	
    static testMethod void testUpdateContactOnTask() {
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact testContact1 = new Contact();
        testContact1.firstname = 'TestFirstName';
        testContact1.lastname = 'TestLastName';
        testContact1.Email = 'TestContact@example.com';
        testContact1.Status__c = 'active';  
        testContact1.AccountId = acc.Id;       
        insert testContact1;
        
        Contact testContact2 = new Contact();
        testContact2.firstname = 'TestFirstName';
        testContact2.lastname = 'TestLastName';
        testContact2.Email = 'TestContact2@example.com';
        testContact2.Status__c = 'active';  
        testContact2.AccountId = acc.Id;       
        insert testContact2;
        
        Test.startTest();
        Contact conRec1 = [SELECT Id, Name, Email, UUID__C FROM Contact WHERE Id =: testContact1.Id];
        Contact conRec2 = [SELECT Id, Name, Email, UUID__C FROM Contact WHERE Id =: testContact2.Id];
        
        Task testTask1 = new Task();
        testTask1.whoId = testContact1.Id;
        testTask1.Type = 'Task';
        testTask1.TaskSubtype = 'Task';
        testTask1.Status = 'Started';
        testTask1.Priority = 'Normal';
        testTask1.Subject = 'Test Activity';
        testTask1.Saleslady_Contact_UUID__c = conRec1.UUID__c;            
        insert testTask1;
        
        Task taskRec1 = [SELECT Id, Saleslady_Contact_UUID__c, Salesforce_Contact__c FROM Task WHERE Id =: testTask1.Id];
        System.assertEquals(conRec1.UUID__c, taskRec1.Saleslady_Contact_UUID__c);
        System.assertEquals(conRec1.Id+' '+conRec1.Name, taskRec1.Salesforce_Contact__c);
        
        testTask1.Subject = 'Test Activity 2';
        testTask1.Saleslady_Contact_UUID__c = conRec1.UUID__c;            
        update testTask1;  
        
        Task testTask2 = new Task();
        testTask2.whoId = conRec2.Id;
        testTask2.Type = 'Task';
        testTask2.TaskSubtype = 'Task';
        testTask2.Status = 'Started';
        testTask2.Priority = 'Normal';
        testTask2.Subject = 'Test Activity';
        insert testTask2;
        
        Task taskRec2 = [SELECT Id, Saleslady_Contact_UUID__c, Salesforce_Contact__c FROM TAsk WHERE Id =: testTask2.Id];
        System.assertEquals(null, taskRec2.Saleslady_Contact_UUID__c);
        System.assertEquals(null, taskRec2.Salesforce_Contact__c);
        
        testTask2.Saleslady_Contact_UUID__c = conRec2.UUID__c;
        update testTask2;
        
        taskRec2 = [SELECT Id, Saleslady_Contact_UUID__c, Salesforce_Contact__c FROM TAsk WHERE Id =: testTask2.Id];
        System.assertEquals(conRec2.UUID__c, taskRec2.Saleslady_Contact_UUID__c);
        System.assertEquals(conRec2.Id+' '+conRec2.Name, taskRec2.Salesforce_Contact__c);
        Test.stopTest();
    }*/
}