/**********************************************************************************************************************************
    AUTHOR 		: RamseySolutions
    Discription :
    History 	: --
    
---------------------------------------------------------------------------------------------------------------------------------
	VERSION 	AUTHOR				DATE				DETAIL											
	1			RamseySolutions		18, Jan 2016		Test methods for different Task triggers
	2			Rupesh Patil		7 June 2018			Modifications,Optimization for Revamp
*****************************************************************************************************************************************/
@isTest
private class TaskTriggerHandlerTest {
     public static List<Lead> lstLeadsToInsert = new List<Lead>();
     public static List<Task> lstTasksToInsert = new List<Task>();
     public static List<Account> lstAccountsToInsert = new List<Account>();
     public static List<Contact> lstContactsToInsert = new List<Contact>();
     public static List<Journey__c> lstJourneysToInsert = new List<Journey__c>();
     public static List<Referral__c> lstReferencesToInsert = new List<Referral__c>();
    
    static Boolean settingsInitialized = false;    
   
    static{
        SalesConsoleSettings.createSettings();  
        
        lstLeadsToInsert.add(new Lead(FirstName = 'Test1', LastName = 'Test1', Company = 'Test',Phone = '1236547890',Email = 'samsung1@example.com',Generate_Journey__c = true ));
        lstLeadsToInsert.add(new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test',Phone = '9874563210',Email='honda@example.com',Status = 'Open',Locations_Interested__c = 'B1; B2;',
                                 Office_Type__c = 'Shared Desk; DailyDesk;'));
        insert lstLeadsToInsert;
        
        lstAccountsToInsert.add(new Account(Name='Test1 Account',Lead_Source__c = 'Id', UUID__c = 'account-uuid'));
        lstAccountsToInsert.add(new Account(Name='strAccountName'));
        insert lstAccountsToInsert;
        
        lstContactsToInsert.add(new Contact(AccountId = lstAccountsToInsert[0].Id,firstname='TestFirstName',lastname='TestLastName',Email='Test111@example.com',Status__c='active'));
       	lstContactsToInsert.add(new Contact(AccountId = lstAccountsToInsert[1].Id,firstname = 'TestFirstName1',lastname = 'TestLastName1',Email = 'Test120@example.com',Status__c='active'));
        insert lstContactsToInsert;
        
        lstJourneysToInsert.add(new Journey__c(Name='Test1 Journey',Status__c='Started',Primary_Contact__c=lstContactsToInsert[0].Id,NMD_Next_Contact_Date__c= Date.today(),Outreach_Stage__c = 'Call 1'));
        lstJourneysToInsert.add(new Journey__c(Name='Test Customer1',Status__c='Started',Primary_Contact__c=lstContactsToInsert[0].Id,NMD_Next_Contact_Date__c= Date.today().addDays(-2)));
        lstJourneysToInsert.add(new Journey__c(Name='Test2 Journey',Status__c='Started',Primary_Contact__c=lstContactsToInsert[0].Id,NMD_Next_Contact_Date__c= Date.today(),Outreach_Stage__c = 'Call 1'));
        lstJourneysToInsert.add(new Journey__c(Name='Test3 Journey',Status__c='Started',Primary_Contact__c=lstContactsToInsert[0].Id,NMD_Next_Contact_Date__c= Date.today(),Outreach_Stage__c = 'Call 5'));//verifyUpdateOutreachStageOnJourney    
        insert lstJourneysToInsert;
        
        lstTasksToInsert.add(new Task(WhoId = lstLeadsToInsert[0].Id, Subject = 'Engage Campaign:'));
        lstTasksToInsert.add(new Task(Status = 'Not Started',Priority = 'Normal',Subject = 'Call',whatId  = lstJourneysToInsert[0].Id));
        lstTasksToInsert.add(new Task(whoId = lstContactsToInsert[0].Id,Type = 'Call',Status = 'Completed',Priority = 'Normal',whatId =lstJourneysToInsert[0].Id,Subject = 'FastCall outbound call'));//verifyUpdateOutreachStageOnJourney
        insert lstTasksToInsert;
       
    }
    
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
        
        
        //create a building and open it
        Building__c testBuilding = new Building__c(
            City__c = 'Test',
            uuid__c = 'abc123',
            Name = 'Test Building'
            
        );
        insert testBuilding;
        settingsInitialized = true;
        
    }
    
/*************************************************************************************************
       Author 				: Anant Kumar
       Description 			: Test method for Update Lead Engagement Fields
       Created Date			: 19, May 2016 
	   Last Modified By 	: Rupesh Patil
	   Last Modified Date   : 08, June 2018
****************************************************************************************************/
    static testMethod void verifyUpdateLeadEngagementFields() {
        Lead objLead = [SELECT Engage_Emails_Sent__c, Last_Engage_Email_Sent__c FROM Lead WHERE Id = :lstLeadsToInsert[0].Id];
        Task objTask = [SELECT CreatedDate FROM Task WHERE Id = :lstTasksToInsert[0].Id];
        
        System.assertEquals(1, objLead.Engage_Emails_Sent__c);
        System.assertEquals(objTask.CreatedDate, objLead.Last_Engage_Email_Sent__c);
    }

/*************************************************************************************************
       Author 				: Samadhan Kadam
       Description 			: Test method for update stage field trigger
       Created Date			: 17, May 2016 
	   Last Modified By 	: Rupesh Patil
	   Last Modified Date   : 08 June 2018
****************************************************************************************************/
    static testMethod void verifyUpdateJourneyStageField() {
        
        lstTasksToInsert[1].CallDisposition = 'Do Not Call'; 
        update  lstTasksToInsert[1];
        
        journey__c journey = [SELECT Id, Status__c,Lost_Reason__c FROM Journey__c WHERE Id=:lstJourneysToInsert[0].Id];
        system.assertEquals('Unqualified',journey.Status__c);
        system.assertEquals('Not Interested',journey.Lost_Reason__c);
        
        //Test method for ST-508 : Auto tagging on task for referral app
        // Changes added by : Anant Kumar
        // Date : 02/Aug/2016
       	Referral__c reference1 = new Referral__c();
        reference1.Referral_Email__c = 'whoid1@example.com';
        reference1.IsActive__c = true;
        reference1.Referrer__c = lstContactsToInsert[0].Id;
        reference1.Expires_On__c = Date.today().addDays(10);
        TestingUtility.insertWithAssert(reference1);
        
        Contact conForWhoId1 = new Contact();
        conForWhoId1.AccountId = lstAccountsToInsert[0].Id;
        conForWhoId1.firstname = 'conForWhoId1';
        conForWhoId1.lastname = 'conForWhoId1LastName';
        conForWhoId1.Email = 'whoid1@example.com';
        conForWhoId1.Status__c = 'active';
        insert conForWhoId1;
       
        Task taskWithReferrer1 = new Task(Status = 'Not Started',Priority = 'Normal',Subject = 'Call',whoId  = conForWhoId1.Id);
        insert taskWithReferrer1;
        System.assertEquals(lstContactsToInsert[0].Id, [SELECT Id, Referrer__c FROM Task WHERE Id=:taskWithReferrer1.Id].Referrer__c);
        
    }

/*************************************************************************************************
       Author 				: Anant Kumar
       Description 			: Test method to update NMD Next Contact Date on task create , Written to cover senarios for ST:297 and ST:298
       Created Date			: 19, May 2016 
	   Last Modified By 	: Rupesh Patil
	   Last Modified Date   : 08 June,2018
****************************************************************************************************/
    static testMethod void verifyUpdateNextNMDContactDateOnJourney(){     
        set<Id> setJourneyWhatIds = new set<Id>(); 
        
        Task testTask = new Task(Type = 'Call',Subject = 'Follow-Up',TaskSubtype = 'Task',Status = 'In Progress',Priority = 'Normal',whatId = lstJourneysToInsert[0].Id,CallDisposition = 'Left VM');
       
        Date before_60_days = Date.Today().addDays(-14);
        testTask.ActivityDate = before_60_days;
        TestingUtility.insertWithAssert(testTask);
        testTask.Status = 'Not Started';
        TestingUtility.updateWithAssert(testTask);
        
        setJourneyWhatIds.add(testTask.whatId);
        Debug.log('SetofWhatIds*******************'+setJourneyWhatIds.size());
        
        Task testTask1 = new Task(Type = 'Call',TaskSubtype = 'Task',whatId = lstJourneysToInsert[0].Id,Priority = 'Normal',Subject = 'test Subject',CallDisposition = 'Left VM',Status = 'In Progress');
        
        TestingUtility.insertWithAssert(testTask1);
        testTask1.Status = 'In Progress';
        TestingUtility.updateWithAssert(testTask1);
        
        Task testTask3 = new Task(Type = 'Call',TaskSubtype = 'Task',whatId = lstJourneysToInsert[0].Id,Status = 'Deferred',Priority = 'Normal',Subject = 'Subject',CallDisposition = 'Busy / No answer', ActivityDate = Date.today()-1);
        TestingUtility.insertWithAssert(testTask3);
        testTask3.Status = 'In Progress';
        TestingUtility.updateWithAssert(testTask3);
      
        Task testTask4 = new Task(Type = 'Call',TaskSubtype = 'Task',whatId = lstJourneysToInsert[1].Id,Status = 'Completed',Priority = 'Normal',Subject = 'Subject',CallDisposition = 'Call in one week');
        TestingUtility.insertWithAssert(testTask4);
        testTask4.Status = 'In Progress';
        TestingUtility.updateWithAssert(testTask4);
        
        Task testTask5 = new Task(Type = 'Call',TaskSubtype = 'Task',whatId = lstJourneysToInsert[1].Id,Status = 'Not Started',Priority = 'Normal',Subject = 'Subject',CallDisposition = 'Left VM');
       
        TestingUtility.insertWithAssert(testTask5);
        List<Task> lstTaskToUpdate = new List<Task>();
        Set<Id> setTaskId = new Set<Id>();
        testTask5.Status = 'Completed'; 
        setTaskId.add(testTask5.Id);
        lstTaskToUpdate.add(testTask5);
        setTaskId.add(testTask3.Id);
        TestingUtility.updateListWithAssert(lstTaskToUpdate);
        Debug.log('testTask5---'+testTask5); 
        for(Task currentTask: [SELECT Type, Status, CallDisposition, whoId, whatId, ActivityDate FROM Task WHERE Id IN: setTaskId]){
            if(currentTask.Id == testTask5.Id){
                System.assertEquals(lstJourneysToInsert[1].Primary_Contact__c, currentTask.whoId);
            } else if(currentTask.Id == testTask3.Id){
                System.assertEquals('Completed', currentTask.Status);
            }
        }  
    }

/*************************************************************************************************
       Author 				: Anant Kumar
       Description 			: Test method for Change TaskOwner
       Created Date			: 13, Jun 2016 
	   Issue No 			: ST-421
	   Last Modified By 	: Rupesh Patil
	   Last Modified Date   : 14 June,2018
****************************************************************************************************/
    static testMethod void verifyTestChangeTaskOwner(){
        set<Id> setWhatIds = new set<Id>();
        System.runAs(new User(Id=UserInfo.getUserId())){
                       
            User testUser = TestUtility.createTestUser();
            Group group1 = new Group(Name='group name', type='Queue');
            insert group1;
            
            QueuesObject objQueue1 = new QueueSObject(QueueID = group1.id, SobjectType = 'Lead');
            insert objQueue1;
            
            QueuesObject objQueue2 = new QueueSObject(QueueID = group1.id, SobjectType = 'Journey__c');
            insert objQueue2;
            
            GroupMember member = new GroupMember();
            member.UserOrGroupId = testUser.Id;
            member.GroupId = group1.Id;
            insert member;
            
            System.runAs(testUser) {
                
                lstLeadsToInsert[1].OwnerId = objQueue1.QueueID;
                update lstLeadsToInsert[1];
                
                Test.startTest();
                Lead lead111 = [SELECT Id,OwnerId,LastName FROM Lead WHERE Id=:lstLeadsToInsert[1].Id];
                Debug.log('Lead ownerId and Id from Test Method '+lead111.OwnerId+' '+lead111.Id+'lstLeadsToInsert-->'+lstLeadsToInsert[1].Id);
                
                List<Journey__c> lstTestJourny = new list<Journey__c>();
                
                Journey__c objTestJourny1 = new Journey__c();
                objTestJourny1.Name = 'Test Customer1';
                objTestJourny1.Status__c = 'Completed';
                objTestJourny1.Primary_Lead__c = lead111.Id;
                objTestJourny1.NMD_Next_Contact_Date__c = Date.today();
                objTestJourny1.OwnerId = objQueue1.QueueID;
                TestingUtility.insertWithAssert(objTestJourny1);
                
                Journey__c objTestJourny2 = new Journey__c();
                objTestJourny2.Name = 'Test Customer1';
                objTestJourny2.Status__c = 'Completed';
                objTestJourny2.Primary_Contact__c = lstContactsToInsert[1].Id;
                objTestJourny2.NMD_Next_Contact_Date__c =Date.today();
                objTestJourny1.OwnerId = objQueue1.QueueID;
                TestingUtility.insertWithAssert(objTestJourny2);
                
                Task testTask = new Task();
                testTask.whoId = lstContactsToInsert[1].Id;
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
                testTask3.whoId = lstContactsToInsert[1].Id;
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
                
                List<Lead> updatedLead = new List<Lead>([SELECT Id,OwnerId FROM Lead WHERE Id =: lead111.Id]);
                System.assertEquals(updatedLead[0].OwnerId, testUser.Id);
                
                List<Journey__c> updatedJourney = new List<Journey__c>([SELECT Id,OwnerId FROM Journey__c WHERE Id =: objTestJourny1.Id]);
                System.assertEquals(updatedJourney[0].OwnerId, testUser.Id);
                Test.stopTest();
            }
        }
    }

/*************************************************************************************************
       Author 				: Dipak Pawar
       Description 			: Test method for Update OutreachStage On Journey
       Created Date			: 26, Aug 2016 
	   Issue No 			: ST-639
	   Last Modified By 	: Rupesh Patil
	   Last Modified Date   : 14 June,2018
****************************************************************************************************/
    static testMethod void verifyUpdateOutreachStageOnJourney() {
                
        Journey__c journey1 = [SELECT Id, Outreach_Stage__c FROM Journey__c WHERE Id =: lstJourneysToInsert[0].Id limit 1];
        Journey__c journey2 = [SELECT Id, Outreach_Stage__c FROM Journey__c WHERE Id =: lstJourneysToInsert[2].Id limit 1];
        Journey__c journey3 = [SELECT Id, Outreach_Stage__c FROM Journey__c WHERE Id =: lstJourneysToInsert[3].Id limit 1];
        System.assertEquals('Call 2', journey1.Outreach_Stage__c);
        System.assertEquals('Call 2', journey2.Outreach_Stage__c);
        System.assertEquals('Call 5', journey3.Outreach_Stage__c);
        
        Test.startTest();
        Journey__c testLeadJourney1 = new Journey__c();
        testLeadJourney1.Name = 'TestJourney1';
        testLeadJourney1.NMD_Next_Contact_Date__c = Date.today();
        testLeadJourney1.Primary_Lead__c = lstLeadsToInsert[1].Id;
        testLeadJourney1.Outreach_Stage__c = '';
        testLeadJourney1.Status__c = 'Started';
        insert testLeadJourney1;
        
        Journey__c testLeadJourney2 = new Journey__c();
        testLeadJourney2.Name = 'TestJourney2';
        testLeadJourney2.NMD_Next_Contact_Date__c = Date.today();
        testLeadJourney2.Primary_Lead__c = lstLeadsToInsert[1].Id;
        testLeadJourney2.Outreach_Stage__c = '';
        testLeadJourney2.Status__c = 'Started';
        insert testLeadJourney2;
        
        Journey__c testLeadJourney3 = new Journey__c();
        testLeadJourney3.Name = 'TestJourney3';
        testLeadJourney3.NMD_Next_Contact_Date__c = Date.today();
        testLeadJourney3.Primary_Lead__c = lstLeadsToInsert[1].Id;
        testLeadJourney3.Outreach_Stage__c = '';
        testLeadJourney3.Status__c = 'Started';
        insert testLeadJourney3;
        
        Journey__c testLeadJourney4 = new Journey__c();
        testLeadJourney4.Name = 'TestJourney4';
        testLeadJourney4.NMD_Next_Contact_Date__c = Date.today();
        testLeadJourney4.Primary_Lead__c = lstLeadsToInsert[1].Id;
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
        testLeadJourney5.Primary_Lead__c = lstLeadsToInsert[1].Id;
        testLeadJourney5.Status__c = 'Started';
        insert testLeadJourney5;
        
        Task testTask2 = new Task();
        testTask2.whoId = lstContactsToInsert[0].Id;
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
    

	/*************************************************************************************************
       Author 				: Dipak Pawar
       Description 			: Test method for update Contact on Task.
       Created Date			: 19, Dec 2016 
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
****************************************************************************************************/
    static testMethod void testUpdateContactOnTask() {
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact testContact1 = new Contact();
        testContact1.firstname = 'TestFirstName';
        testContact1.lastname = 'TestLastName';
        testContact1.Email = 'TestContact@example.com';
        testContact1.Status__c = 'active';  
        testContact1.AccountId = acc.Id;
        testContact1.UUID__c = 'con1UUID';
        insert testContact1;
        
        Contact testContact2 = new Contact();
        testContact2.firstname = 'TestFirstName';
        testContact2.lastname = 'TestLastName';
        testContact2.Email = 'TestContact2@example.com';
        testContact2.Status__c = 'active';  
        testContact2.AccountId = acc.Id;
        testContact2.UUID__c = 'con2UUID';
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
    }
}