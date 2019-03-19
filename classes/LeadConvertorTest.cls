/*********************************************************************************************
Name   : LeadConvertor
Purpose: Cover the test senarios for lead convertor class.
History:
         VERSION      DATE      	AUTHOR                 DETAIL
          1.0      24 Apr 2016   Hemanshu Shah  	 Initial Developement.
		  2.0      1  May 2016	 Amol Darekar	 	 Initial Developement and Improvements.

*********************************************************************************************/ 
@isTest
public class LeadConvertorTest {
    @TestSetup
    static void initData(){          
        SalesConsoleSettings.createSettings();
    }
    static Boolean settingsInitialized = false;
    static LeadConvertor.JourneySettings settingJourney;
    
    /*public static void initFieldMappings() {
        if( settingsInitialized )
            return;

        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'Lead:Lead and Lead Source Details';
        testSettings.Data__c = '{"LeadSource":[{"name":"Broker","OverrideLeadSoruce":false},{"name":"Test Broker","OverrideLeadSoruce":true}], "LeadSourceDetails":["Broker1","Broker2" ]}';
        TestingUtility.insertWithAssert(testSettings);
        
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
        
        //Create a queue
        Group testGroup = new Group ();
        testGroup.Name = 'Test Lead Queue';
        testGroup.Type = 'Queue';
        insert testGroup;
        
        Group testGroup1 = new Group ();
        testGroup1.Name = 'Test Lead Queue1';
        testGroup1.Type = 'Queue';
        insert testGroup1;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueueSObject testQueue = new QueueSObject();
            testQueue.QueueId = testGroup.Id;
            testQueue.SObjectType = 'Lead';
            insert testQueue;
            
            testQueue = new QueueSObject();
            testQueue.QueueId = testGroup.Id;
            testQueue.SObjectType = 'Journey__c';
            insert testQueue;
            
            testQueue = new QueueSObject();
            testQueue.QueueId = testGroup1.Id;
            testQueue.SObjectType = 'Lead';
            insert testQueue;
            
            testQueue = new QueueSObject();
            testQueue.QueueId = testGroup1.Id;
            testQueue.SObjectType = 'Journey__c';
            insert testQueue;
            
            GroupMember member = new GroupMember();
            member.UserOrGroupId = testUser.Id;//UserInfo.getUserId();
            member.GroupId = testGroup.Id; 
            insert member;
            
            member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = testGroup.Id; 
            insert member;
        }
        
        User apiUser = [SELECT Id,Username FROM User WHERE Username  =:'testapiuser89833@example.com'];
        User susieRomero = [SELECT Id,Username FROM User WHERE Name='Susie Romero'];
        
        testSettings = new Setting__c();
        testSettings.Name = 'User/Queue Journey Creation';
        testSettings.Data__c = '{"allowedUsers":[{"userName":"'+ testUser.Username +'","Id":"'+testUser.Id +'"},{"userName":"'+ testUser1.Username +'","Id":"'+testUser1.Id +'"},{"userName":"'+ apiUser.Username +'","Id":"'+apiUser.Id +'"},{"userName":"'+susieRomero.Username +'","Id":"'+susieRomero.Id +'"}],"allowedQueues":[{"Id":"'+ testGroup.Id +'","queueName":"'+ testGroup.Name +'"}]}';//{"Id":"'+ testGroup1.Id +'","queueName":"'+ testGroup1.Name +'"}
        TestingUtility.insertWithAssert(testSettings);
        
        /*testSettings = new Setting__c();
        testSettings.Name = 'UpdateJourneysOwner';
        testSettings.Data__c = '{ "ownerId":"'+testUser.Id +'" }';
        TestingUtility.insertWithAssert(testSettings);
        
        Account testAccount = new Account(Name ='Test Global Acoount');
        insert testAccount;
        
        //samadhan
        /*Setting__c JourneyCreationSettings = new Setting__c();
        JourneyCreationSettings.Name = 'JourneyCreationSettings';
        JourneyCreationSettings.Data__c = '{"NextCallInDaysFromLeadCreation":0,"NoCompanyAccountId":"'+ testAccount.Id +'","NextCallInDaysFromJourneyUpdation":0,"NewLeadActivityFields":{"Status":"Open","Subject":"Inbound Lead submission"},"NewJourneyFields":{"Status__c":"Started"},"ExistingJourneyStage":"Started","ExistingJourneyCreatedDateDifference":4,"JourneyAssignmentCutOffDays":30,"CloseInDaysFromJourneyCreation":2,"ClosedJourneyStages":["Completed-Lost","Completed-Won"]}';
        TestingUtility.insertWithAssert(JourneyCreationSettings);
        
        settingsInitialized = true;
    }
    
    public static Lead prepareLead(String lastName, String company, String email, String phone) {
        return prepareLeads(lastName, company, email, phone, 1)[0];
    }
    
    public static List<Lead> prepareLeads(String lastName, String company, String email, String phone, integer count){
        
        List<Lead> listLeads = new List<Lead>();
        if( count == 1 ){
            Lead leadNew = new Lead(LastName = lastName, Company = company, Email = email, Phone = phone, Generate_Journey__c = false);
            listLeads.add(leadNew);
        }
        else if( count > 1 ) {
            String emailName = null, emailDomain = null;
            if( !String.IsBlank(email) ){
                integer iFound = email.indexOf('@');
                if( iFound >= 0 ){
                    emailName = email.left(iFound);
                    emailDomain = email.Mid(iFound, email.length());
                }
            }
            
            for(integer iIndex = 0; iIndex < count; ++iIndex) {
                Lead leadNew = new Lead(LastName = lastName + '-' + iIndex, Company = company, Generate_Journey__c = false);
                leadNew.Email = (emailName == null) ? null : emailName + '-' + iIndex + emailDomain;
                leadNew.Phone = (String.IsBlank(phone)) ? null : phone + iIndex;
                listLeads.add(leadNew);
            }
        }
        
        return listLeads;
    }
    
    @testSetup static void testContactCreation() {
        //Check if contact exist and use the same contact and convert the lead get created with same email id and create journey and assign it to primary contact
        //samadhan
        /* List<Setting__c> lstSettings = new List<Setting__c>();
        lstSettings.add(new Setting__c(Name = 'AccountCleansingSetting',Data__c = '{"starts_with":["The","An","A"],"ends_with":["pvt","ltd"],"specialCharacters":"@#^&*!():?/><"}'));
        insert lstSettings;
        
        Contact contact = new Contact(LastName = 'test', Email = 'test@example.com');
        insert contact;
        System.assert(contact.Id != null);
        
        contact = new Contact(LastName = 'test', Email = 'test1@example.com');
        insert contact;
        System.assert(contact.Id != null);
    }
    
    
    //Test Journey creation for single lead  
    static testMethod void testJourneyCreationForLeadAssinedToUser()
    {
        
        initFieldMappings();
        Lead lead;
        Journey__c[] journeys;
        string leadId;
        Lead[] leads;
        Task[] tasks;
        //Product_interested__c[] lstTestProductInt;
        User u = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, u);
        
        //If Journey is owned by the user given in settings also match the lead source and lead source details create new journey and activity
        system.runAs(u)
        {   
            lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Lead_Source_Detail__c = 'Broker1';
            //lead.Number_of_Desks__c = '1';
            insert lead;
            
            lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Lead_Source_Detail__c = 'Broker1';
            //lead.Number_of_Desks__c = '1';
            insert lead;
            
            journeys = [Select Id,Name from Journey__c];
            system.assertEquals(1, journeys.size());
            Test.setCreatedDate(journeys[0].Id,system.today().addDays(-5));
            
            Test.startTest();
            lead = prepareLead('S', 'WeWork Test Company', 'testLead1@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Lead_Source_Detail__c = 'Broker1';
            insert lead;
            
            journeys = [Select Id,Name from Journey__c];
            system.assertEquals(2, journeys.size());
            
            leads = [select Id,Name from Lead];
            system.assertEquals(1, leads.size());
            
            tasks = [select Id from task];
            system.assertEquals(3, tasks.size());
           
            Test.stopTest();
        }
        
    }
    
    //Test Journey creation if contact exist
    static testMethod void testJourneyCreationForLeadWithExistingContact1()
    {
        initFieldMappings();
        Lead lead;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        User u = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, u);
        
        //If Journey is owned by the user given in settings also match the lead source and lead source details create new journey and activity
        //contact exit then convert the lead
        system.runAs(u)
        {
            
            lead = prepareLead('Smith', 'WeWork Test Company', 'test@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Lead_Source_Detail__c = 'Broker1';
            insert lead;
            
            leads = [select Id,Name from Lead where IsConverted = true];
            system.assertEquals(1, leads.size());
            
            tasks = [select Id from task];
            system.assertEquals(1, tasks.size());
            
            journeys = [Select Id,Name from Journey__c];
            system.assertEquals(1, journeys.size());
            
            Debug.log('Test : SOQL Limit 1 ::: ' + Limits.getQueries());
            Test.setCreatedDate(journeys[0].Id,system.today().addDays(-3));
            
            Test.startTest();          
            //Convert the lead but do not create new journey because journey alredy exist
            //and created date is greater than date given in JSON
            lead = prepareLead('Smith', 'WeWork Test Company', 'test@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Lead_Source_Detail__c = 'Broker1';
            insert lead;
            Test.stopTest();
            
            leads = [select Id,Name from Lead where IsConverted = true];
            system.assertEquals(2, leads.size());
            Debug.log('Test : SOQL Limit 2::: ' + Limits.getQueries());
            journeys = [Select Id,Name from Journey__c];
            system.assertEquals(1, journeys.size());
        } 
    }
    
    //Test Journey creation if contact exist
    static testMethod void testJourneyCreationForLeadWithExistingContact2()
    {  
        initFieldMappings();
        Lead lead;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        User u = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, u);
        
        //If Journey is owned by the user given in settings also match the lead source and lead source details create new journey and activity
        //contact exit then convert the lead
        system.runAs(u)
        {
            
            lead = prepareLead('Smith', 'WeWork Test Company', 'test@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Lead_Source_Detail__c = 'Broker1';
            insert lead;
            
            leads = [select Id,Name from Lead where IsConverted = true];
            system.assertEquals(1, leads.size());
            
            tasks = [select Id from task];
            system.assertEquals(1, tasks.size());
            
            journeys = [Select Id,Name from Journey__c];
            system.assertEquals(1, journeys.size());
            
            Test.setCreatedDate(journeys[0].Id,system.today().addDays(-5));            
			Test.startTest();            
            
            //Journey already exist on contact but created date is less than the date we have provided in JSON
            //So it will create new lead and convert the current lead and create journey
            lead = prepareLead('Smith', 'WeWork Test Company', 'test@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Lead_Source_Detail__c = 'Broker1';
            insert lead;
            
            Debug.log('Test : SOQL Limit 3 ::: ' + Limits.getQueries());
            journeys = [Select Id,Name from Journey__c];
            system.assertEquals(2, journeys.size());
            leads = [select Id,Name from Lead where IsConverted = true];
            system.assertEquals(2, leads.size());
            Debug.log('Test : SOQL Limit 4 ::: ' + Limits.getQueries());
            Test.stopTest();
        } 
    }
    
    
    //Test Joureny creation assined to Queue
    //ST-653 : New Jouney should not be created if exsisting journey is create within Y date(as per setting data). But activity should be created.
    static testMethod void testJourneyCreationForLeadAssignedToQueue()
    {
        initFieldMappings();
        Lead lead;
        Contact contact;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        //Check if lead owner is queue if yes and Lead source and lead source details condition satisfy create journey and activity.
        Group testGroup = [Select Id,Name from Group where Name = 'Test Lead Queue' and Type = 'Queue'];
        Debug.log('testGroup:'+testGroup.Id);
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        lead.OwnerId = testGroup.Id;
        insert lead;
        journeys = [Select Id, Primary_Contact__c From Journey__c];
        System.assertEquals(1,journeys.size());
        tasks = [Select Id from Task];
        System.assertEquals(1,tasks.size()); 
        Test.setCreatedDate(journeys[0].Id,system.today().addDays(-2));
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, u);
        
        //Lead owner is user and existing lead owner is a queue then system will not create a new journey
        //Because journey is already exist and it's created date is greater than date mentioned in JSON
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        lead.ownerId = u.Id;
        insert lead;
        
        journeys = [Select Id, Primary_Contact__c From Journey__c];
        System.assertEquals(1,journeys.size());
        tasks = [Select Id from Task];
        System.assertEquals(2,tasks.size());
        
        Test.setCreatedDate(journeys[0].Id,system.today().addDays(-5));
        
        Test.startTest();
        //Lead owner is user and existing lead owner is a queue then system will  create a new journey
        //Because journey is already exist but it's created date is less than date mentioned in JSON
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        lead.ownerId = u.Id;
        insert lead;
        
        //Two journey is created with same ownerId
        journeys = [Select Id, Primary_Contact__c , createdDate From Journey__c where ownerId =:testGroup.Id];
        System.assertEquals(2,journeys.size());
        tasks = [Select Id from Task];
        System.assertEquals(3,tasks.size());
        system.debug(logginglevel.ERROR,'Joureny Queue::'+journeys);
        system.debug(logginglevel.ERROR,' system.today()::'+ system.today());
        //Lead owner is user and existing lead owner is a queue then system will  not create a new journey
        //Because journey is already exist and it's createdDate date is greater than date mentioned in JSON
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        lead.ownerId = u.Id;
        insert lead;
        journeys = [Select Id, Primary_Contact__c From Journey__c where ownerId =:testGroup.Id];
        System.assertEquals(2,journeys.size());
        tasks = [Select Id from Task];
        System.assertEquals(4,tasks.size());
        journeys = [Select Id, Primary_Contact__c From Journey__c where createdDate >=: Date.today()];
        System.assertEquals(1,journeys.size());
        Test.stopTest();
    }
    
    //Test Joureny creation assined to owner not in JSON
    static testMethod void testJourneyCreationForLeadOwnerNotInJSON()
    {
        initFieldMappings();
        Lead lead;
        Contact contact;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, u);
        
        //Lead source and Lead source details conditions match but owner is not from json
        //Create activity but do not create journey
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        insert lead;
        
        leads = [Select Id, OwnerId from lead];
        System.assertEquals(1,leads.size());
        
        journeys = [Select Id, Primary_Contact__c From Journey__c];
        System.assertEquals(0,journeys.size());
        
        tasks = [Select Id from Task];
        System.assertEquals(1,tasks.size());
        
        //Lead source and Lead source details conditions match and owner is  from json
        //Existing leads ownerId is not from JSON then it create Joureny with existing lead owner id
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        lead.OwnerId = u.Id;
        insert lead;
        
        leads = [Select Id, OwnerId from lead];
        Debug.log('Test : leads ::: ' + leads);
        System.assertEquals(1,leads.size());
        
        journeys = [Select Id, Primary_Contact__c From Journey__c];
        System.assertEquals(1,journeys.size());
        
    }
    
    
    static testMethod void testLeadForEnterPriseSolution(){
        initFieldMappings();
        Lead lead;
        Contact contact;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        User u = [Select Id from user where username =:'testweworkuser1@example.com'];
        //Lead is created for EnterPrise Solution recordtype and journey creation condition match
        //but it will create joureny because recordtype is enterprise solution
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith1234@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        insert lead;
        Test.startTest();
        journeys = [select Id from Journey__c];
        system.assertEquals(1,journeys.size());
        tasks = [select Id from task];  
        system.assertEquals(1,tasks.size());
        
        //Lead is created for default recordtype and lead creation condition match but lead with email alredy exist
        //then it will not create journey because this lead create only activity becasue existing lead is of enterprise solution.
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith1234@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        insert lead;
        
        journeys = [select Id from Journey__c];
        system.assertEquals(1,journeys.size());
        tasks = [select Id from task];  
        system.assertEquals(2,tasks.size());
        
        //Lead is not of type enterprise solution the it will create journey and activity
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith123@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        insert lead;
        journeys = [select Id from Journey__c];
        system.assertEquals(2,journeys.size());
        tasks = [select Id from task];  
        system.assertEquals(3,tasks.size());
        
        //Lead is created for Enterprise Solution recordtype and lead creation condition match but lead with email alredy exist
        //then it will not create journey because this lead create only activity becasue new lead is of Enterprise solution recordtype.
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith123@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        lead.OwnerId = u.Id;
        insert lead;
        journeys = [select Id from Journey__c];
        system.assertEquals(2,journeys.size());
        tasks = [select Id from task];  
        system.assertEquals(4,tasks.size());
        leads = [Select Id from Lead];
        system.assertEquals(2,leads.size());
        Test.stopTest();
    }
    
    
    static testMethod void testLeadMassUpload_1(){
        
        initFieldMappings();
        Lead lead;
        Contact[] contacts;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com'];
        
        User u1 = [Select Id from user where username =:'testweworkuser2@example.com'];
        
        //Create Activity and Journey on lead
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        insert lead;
        
        //Create Activity and but do not create journey becasue lead owner condition does not satisfy
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        insert lead;
        
        Test.startTest();
        //Create Activity and Journey and convert the lead becasue contact with given email alredy exist
        lead = prepareLead('Smith', 'WeWork Test Company', 'test1@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.ownerId = u1.Id;
        insert lead;
        
        journeys = [select Id from Journey__c];
        system.assertEquals(2,journeys.size());
        
        //Inserting leads in bulk
        //Create four leads with same email then only one get created and rest get deleted and create fore activity and one journey.
        leads = prepareLeads('Smith', 'WeWork Test Company', 'john.smith@example.com', '+13698564125',4);
        
        for(Lead currentLead : leads)
        {
            currentLead.LeadSource= 'Broker';
            currentLead.Lead_Source_Detail__c = 'Broker1';
            currentLead.Generate_Journey__c = true;
            currentLead.Email = 'testduplead@example.com';
            currentLead.OwnerId = u.Id;
        }
        
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith1234@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        leads.add(lead);
        
        //Contact exist then it will convert this lead.
        lead = prepareLead('Smith', 'WeWork Test Company', 'test1@example.com', null);
        lead.Generate_Journey__c = true;
        leads.add(lead);
        
        //Contact exist with journey then it will create journey and not activity
        lead = prepareLead('Smith', 'WeWork Test Company', 'test1@example.com', null);
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        leads.add(lead);
        
        //Contact exist and journey on contact alredy exist then it will update journey on contact and convert then lead
        lead = prepareLead('Smith', 'WeWork Test Company', 'test1@example.com', null);
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        leads.add(lead);
        
        //Lead already exist create activity & update existing journey and deletes the lead
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        leads.add(lead);
        //Lead already exist create activity & update existing journey and deletes the lead
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        leads.add(lead);
        
        //Lead exist but journey do not exist creates lead and journey and delete the lead
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        leads.add(lead);
        
        //Lead already exist but journey creation condition do not meet so creates activity and delete the lead.
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        leads.add(lead);
        Debug.log('Test : All Leads ::: ' + leads);
        insert leads;
        
        contacts = [select Id from contact where email =: 'test1@example.com']; 
        system.assertNotEquals(null,contacts);
        leads = [select Id,Email,IsConverted from lead where IsConverted = false];
        Debug.log('Test : All Leads after insert ::: ' + leads);
        system.assertEquals(4,leads.size());
        leads = [select Id from lead where IsConverted = true];
        system.assertEquals(4,leads.size());
        tasks = [select Id from task];  
        system.assertEquals(15,tasks.size());
        journeys = [select Id from Journey__c];
        system.assertEquals(4,journeys.size());
        Test.stopTest();
    }
    
    static testMethod void testLeadMassUpload_2(){
        
        initFieldMappings();
        Lead lead;
        Contact[] contacts;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com'];
        
        User u1 = [Select Id from user where username =:'testweworkuser2@example.com'];
        
        //Create Activity and Journey on lead
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        insert lead;
        
        journeys = [select Id from Journey__c];
        system.assertEquals(1,journeys.size());
        Test.setCreatedDate(journeys[0].Id,system.today().addDays(-5));
        
        //Create Activity and but do not create journey becasue lead owner condition does not satisfy
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        insert lead;
        
        Test.startTest();
        //Create Activity and Journey and convert the lead becasue contact with given email alredy exist
        lead = prepareLead('Smith', 'WeWork Test Company', 'test1@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.ownerId = u1.Id;
        insert lead;
        
        journeys = [select Id from Journey__c];
        system.assertEquals(2,journeys.size());
        
        //Inserting leads in bulk
        //Create four leads with same email then only one get created and rest get deleted and do not create journey because it is of Enterprise Type Lead.
        leads = prepareLeads('Smith', 'WeWork Test Company', 'john.smith@example.com', '+13698564125',4);
        
        for(Lead currentLead : leads)
        {
            currentLead.LeadSource= 'Broker';
            currentLead.Lead_Source_Detail__c = 'Broker1';
            currentLead.Generate_Journey__c = true;
            currentLead.Email = 'testduplead@example.com';
            currentLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
            currentLead.OwnerId = u.Id;
        }
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith1234@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        leads.add(lead);
        
        //Contact exist then it will convert this lead.
        lead = prepareLead('Smith', 'WeWork Test Company', 'test1@example.com', null);
        lead.Generate_Journey__c = true;
        leads.add(lead);
        
        //Contact exist with journey then it will create journey and not activity
        lead = prepareLead('Smith', 'WeWork Test Company', 'test1@example.com', null);
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        leads.add(lead);
        
        //Contact exist and journey on contact alredy exist then it will update journey on contact and convert then lead
        lead = prepareLead('Smith', 'WeWork Test Company', 'test1@example.com', null);
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        leads.add(lead);
        
        //Lead already exist create activity & and creates the new journey because it's journey creation date is less than date mentioned in JSON
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        leads.add(lead);
        //Lead already exist create activity & update existing journey and deletes the lead
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        leads.add(lead);
        
        //Lead exist but journey do not exist creates lead and journey and delete the lead
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        leads.add(lead);
        
        //Lead already exist but journey creation condition do not meet so creates activity and delete the lead.
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        leads.add(lead);
        insert leads;
        
        contacts = [select Id from contact where email =: 'test1@example.com']; 
        system.assertNotEquals(null,contacts);
        leads = [select Id,Email,IsConverted from lead where IsConverted = false];
        system.debug(logginglevel.ERROR,'Test leads:'+leads);
        system.assertEquals(4,leads.size());
        leads = [select Id from lead where IsConverted = true];
        system.assertEquals(4,leads.size());
        tasks = [select Id from task];  
        system.assertEquals(15,tasks.size());
        journeys = [select Id from Journey__c];
        system.assertEquals(3,journeys.size());
        Test.stopTest();
    }
    
    static testMethod void testLeadMassUpload_3(){
        
        initFieldMappings();
        Lead lead;
        Contact contact;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com'];
        
        User u1 = [Select Id from user where username =:'testweworkuser2@example.com'];
        
        //Create Activity and Journey on lead
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        insert lead;
        //Create Activity and but do not create journey becasue lead owner condition does not satisfy
        lead = prepareLead('Smith', 'WeWork Test Company', 'testduplead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        insert lead;
        
        journeys = [select Id from Journey__c];
        system.assertEquals(1,journeys.size()); 
        
        Test.startTest();
        //Inserting leads in bulk
        //Create four leads with same email then only one get created and rest get deleted and do not create journey because it is of Enterprise Type Lead.
        leads = prepareLeads('Smith', 'WeWork Test Company', 'testduplead@example.com', '+13698564125',4);
        
        for(Lead currentLead : leads)
        {
            currentLead.LeadSource= 'Broker';
            currentLead.Lead_Source_Detail__c = 'Broker1';
            currentLead.Generate_Journey__c = true;
            currentLead.Email = 'testduplead@example.com';
            currentLead.OwnerId = u.Id;
        }
        
        insert leads;
        
        leads = [select Id,Email,IsConverted from lead where IsConverted = false];
        system.debug(logginglevel.ERROR,'Test leads:'+leads);
        system.assertEquals(2,leads.size());
        tasks = [select Id from task];  
        system.assertEquals(6,tasks.size());
        journeys = [select Id from Journey__c];
        system.assertEquals(2,journeys.size());
        Test.stopTest();
    }        
    
    //Lead is for enterprise solution and lead with duplicate email is for default 
    //delete all duplicate lead and create journey because existing lead is of type Enterprise solution
    static testMethod void testLeadMassUpload_4(){
        
        initFieldMappings();
        Lead lead;
        Contact contact;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com'];
        //Create Activity but do not create journey because lead is of type enterprise solution
        lead = prepareLead('Smith', 'WeWork Test Company', 'testduplead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.ownerId = u.Id;
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        insert lead;
        Test.startTest();
        //Inserting leads in bulk
        //Create four leads with same email then only one get created and rest get deleted and do not create journey because it is of Enterprise Type Lead.
        leads = prepareLeads('Smith', 'WeWork Test Company', 'testduplead@example.com', '+13698564125',4);
        
        for(Lead currentLead : leads)
        {
            currentLead.LeadSource= 'Broker';
            currentLead.Lead_Source_Detail__c = 'Broker1';
            currentLead.Generate_Journey__c = true;
            currentLead.Email = 'testduplead@example.com';
            currentLead.OwnerId = u.Id;
        }
        
        insert leads;
        
        leads = [select Id,Email,IsConverted from lead where IsConverted = false];
        system.debug(logginglevel.ERROR,'Test leads:'+leads);
        system.assertEquals(1,leads.size());
        tasks = [select Id from task];  
        system.assertEquals(5,tasks.size());
        journeys = [select Id from Journey__c];
        system.assertEquals(1,journeys.size());
        Test.stopTest();
    } 
    
    static testMethod void testActivityForExistingLead(){
        
        initFieldMappings();
        Lead lead;
        Id existingLeadId;
        Task[] tasks;
        Test.startTest();
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        //lead.ownerId = testGroup.Id;
        insert lead;
        existingLeadId = lead.Id;
        tasks = [select Id from task];
        system.assertEquals(1, tasks.size());
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        //lead.ownerId = testGroup.Id;
        insert lead;
        Test.stopTest();
        tasks = [Select Id from Task where whoId =: existingLeadId];
        system.assertEquals(2,tasks.size());
    }
    
    static testMethod void testUpdateExistingJoureny(){
        
        initFieldMappings();
        Lead lead;
        Contact contact;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, u);
        Group testGroup = [Select Id,Name from Group where Name = 'Test Lead Queue' and Type = 'Queue'];
        system.assertNotEquals(null, testGroup.Id);  
        Debug.log('User Id::'+u.Id);
        system.runAs(u){
            lead = prepareLead('Smith', 'WeWork Test Company', 'testnew_lead124@example.com', null);
            lead.Company = 'Test Company';
            lead.LeadSource = 'Broker';
            lead.Lead_Source_Detail__c = 'Broker1';
            lead.Generate_Journey__c = true;
            lead.OwnerId = testGroup.Id;
            insert lead;
            System.debug(LoggingLevel.ERROR,'Journey ==>>'+[select Id,Name,ownerId,NMD_Next_Contact_Date__c from Journey__c]);
            System.debug(LoggingLevel.ERROR,'today ==>>'+System.today());
            //journeys = [select Id,Name,ownerId,NMD_Next_Contact_Date__c from Journey__c where NMD_Next_Contact_Date__c >=:DateUtilities.addBusinessDays(Date.today(), 1)];
            journeys = [select Id,Name,ownerId,NMD_Next_Contact_Date__c from Journey__c where NMD_Next_Contact_Date__c >=:System.today()];
            system.assertEquals(1,journeys.size());
            //Change Journey NMD_Next_Contact_Date set it to Previous date
            journeys[0].NMD_Next_Contact_Date__c = DateUtilities.addBusinessDays(Date.today().addDays(-4), 0);
            update journeys;
            
            //This will update existing journey to todays date
            lead = prepareLead('Smith', 'WeWork Test Company', 'testnew_lead124@example.com', null);
            lead.Company = 'Test Company';
            lead.LeadSource = 'Broker';
            lead.Lead_Source_Detail__c = 'Broker1';
            lead.Generate_Journey__c = true;
            lead.OwnerId = testGroup.Id;
            insert lead;
            
            journeys = [select Id,Name,NMD_Next_Contact_Date__c,ownerId from Journey__c];
            system.assertEquals(1,journeys.size());
            
            journeys = [select Id,Name,NMD_Next_Contact_Date__c,ownerId from Journey__c where NMD_Next_Contact_Date__c =:DateUtilities.addBusinessDays(Date.today(), 0)];
            system.assertEquals(1,journeys.size());
        }
    }
    
    //Check if OverrideLeadSoruce is true then create journey even if lead source details do not match.
    static testMethod void testOverrideLeadSourceDetails(){
        
        initFieldMappings();
        Lead lead;
        Contact contact;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        User u = [Select Id from user where username =:'testweworkuser1@example.com'];
        //Lead Source details not match so it will not create journey only create activity
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith1234@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker123';
        lead.OwnerId = u.Id;
        insert lead;
        
        journeys = [select Id from Journey__c];
        system.assertEquals(0,journeys.size());
        tasks = [select Id from task];  
        system.assertEquals(1,tasks.size());
        
        //Lead Source details not match but OverrideLeadSoruce propety in json is true so it will create journey and activity
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith1234@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Test Broker';
        lead.Lead_Source_Detail__c = 'Broker123';
        lead.OwnerId = u.Id;
        insert lead;
        journeys = [select Id from Journey__c];
        system.assertEquals(1,journeys.size());
        tasks = [select Id from task];  
        system.assertEquals(2,tasks.size());
        
    }
    
    //This test method is use test email is sent or not if exception occured
    static testMethod void testEmailSendOnException()
    {
        set<string> setEmails = new set<string>();
        setEmails.add('testLeadEmail.example.com');
        setEmails.add('testLeadEmail.example.com');
        Lead lead;
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith1234@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Email ='';
        lead.Lead_Source_Detail__c = 'Broker123';
        insert lead;        
        LeadConvertor.sendMailOnException(setEmails,null);
        System.assert(Limits.getEmailInvocations()==1);
        //System.assert(Limits.getEmailInvocations()==2);
    }
    
    //Check journey creation depends on 'ExistingJourneyCreatedDateDifference' and 'JourneyAssignmentCutOffDays' settings
    static testMethod void tionDependsOnSettingsForLead_1()
    {
        initFieldMappings();
        Lead lead;
        Contact contact;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com'];
        User u1 = [Select Id from user where username =:'testweworkuser2@example.com'];
        
        //Create Activity and Journey on lead
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        insert lead;
        
        journeys = [select Id from Journey__c];
        system.assertEquals(1,journeys.size());
        Test.setCreatedDate(journeys[0].Id,system.today().addDays(-4));
        Test.setCreatedDate(lead.Id,system.today().addDays(-40));
        Test.startTest();
        journeys = [select Id from Journey__c];
        system.assertEquals(1,journeys.size());
        //Journey creation date is equals to 'ExistingJourneyCreatedDateDifference' new journey is not get created
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u.Id;
        insert lead;
        
        journeys = [select Id from Journey__c];
        system.assertEquals(1,journeys.size());
        Test.stopTest();
        Test.setCreatedDate(journeys[0].Id,system.today().addDays(-5));
        //lead is created before 'JourneyAssignmentCutOffDays' and jounrey is created before 'ExistingJourneyCreatedDateDifference'
        //It will create new journey
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = u1.Id;
        insert lead;
        journeys = [select Id,ownerId from Journey__c order by createdDate desc];
        system.assertEquals(2,journeys.size());
        system.assertEquals(u.Id,journeys[0].OwnerId);
       
    }
    
    //Check journey creation depends on 'ExistingJourneyCreatedDateDifference' and 'JourneyAssignmentCutOffDays' settings
    static testMethod void testJourneyCreationDependsOnSettingsForLead_2()
    {
        
        initFieldMappings();
        Lead lead;
        Contact contact;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com'];
        
        User u1 = [Select Id from user where username =:'testweworkuser2@example.com'];
        
        //Create Activity but do not create journey because owner do not have permission
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        insert lead;
        
        journeys = [select Id from Journey__c];
        system.assertEquals(0,journeys.size());
        
        tasks =[Select Id from Task];
        system.assertEquals(1,tasks.size());
        
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.ownerId = u.Id;
        insert lead;
        
        leads = [select Id from lead];
        system.assertEquals(1,leads.size());
        journeys = [select Id,ownerId from Journey__c];
        system.assertEquals(1,journeys.size());
        system.assertEquals(u.Id,journeys[0].ownerId);
        tasks =[Select Id from Task];
        system.assertEquals(2,tasks.size());
    }
    
    
    //Check journey creation depends on 'ExistingJourneyCreatedDateDifference' and 'JourneyAssignmentCutOffDays' settings
    static testMethod void testJourneyCreationDependsOnSettingsForContact_1()
    {
        
        Test.startTest();
        initFieldMappings();
        Lead lead;
        Contact contact;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com'];
        
        User u1 = [Select Id from user where username =:'testweworkuser2@example.com'];
        
        //Check if contact exist and use the same contact and convert the lead get created with same email id and create journey and assign it to primary contact
        contact = new Contact(LastName = 'test', Email = 'testLeadSettings@example.com', LeadSource = 'test broker',Lead_Source_Detail__c = 'broker1', OwnerId = u.id , Convert_Lead__c = true);
        insert contact;
        System.assert(contact.Id != null);
        
        //Create Activity and Journey on Contact with contact ownerId because contact created date is greater than 'JourneyAssignmentCutOffDays'
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLeadSettings@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.ownerId = u1.Id;
        insert lead;
        Lead l = [Select Id,Name,OwnerId,isConverted From Lead Where Id=:lead.Id];
        debug.log('l==>'+l);
        system.assertEquals(l.ownerId,u1.Id);
        journeys = [select Id,ownerId from Journey__c];
        system.assertEquals(1,journeys.size());
        
        leads = [select Id,ownerId from Lead where isConverted = false];
        system.assertEquals(0,leads.size());
        system.assertEquals(contact.ownerId,journeys[0].ownerId);
        Test.stopTest();
        Test.setCreatedDate(contact.Id,system.today().addDays(-40));
        Test.setCreatedDate(journeys[0].Id,system.today().addDays(-5));
        
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLeadSettings@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.ownerId = u1.Id;
        insert lead;
        journeys = [select Id,ownerId from Journey__c];
        system.assertEquals(2,journeys.size());
        
        contact = new Contact(LastName = 'test', Email = 'testLeadSettings1@example.com', LeadSource = 'broker',Lead_Source_Detail__c = 'broker1', Convert_Lead__c = true);
        insert contact;
        System.assert(contact.Id != null);
        Test.setCreatedDate(contact.Id,system.today().addDays(-40));
        
        //contact is created before 'JourneyAssignmentCutOffDays' and jounrey not present so it will create lead with lead owner Id
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLeadSettings1@example.com', '+13698564125');
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.ownerId = u1.Id;
        insert lead;
        journeys = [select Id,ownerId from Journey__c];
        system.assertEquals(3,journeys.size());
        journeys = [select Id,ownerId from Journey__c where Primary_Contact__c =:contact.Id];
        system.assertEquals(1,journeys.size());
        //Journey OwnerId should be same as newly submited lead owner Id
        system.assertEquals(u1.Id,journeys[0].ownerId);
        system.assertEquals(3, [SELECT Id FROM Task].size());
        
    }
    
    //This method is used to test create Journey for lead and contact for email to lead journey creation
    static testMethod void testEmailToLeadJourneyCreation()
    {
        
        initFieldMappings();
        Lead lead;
        Contact contact;
        Journey__c[] journeys;
        list<lead> leads = new list<lead>();
        list<contact> contacts = new list<contact>();
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com'];
        //Create Activity and Journey on Contact with contact ownerId because contact created date is greater than 'JourneyAssignmentCutOffDays'
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLeadSettings@example.com', '+13698564125');
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.ownerId = u.Id;
        lead.Generate_Journey__c = false;
        insert lead;
        leads.add(lead);
        
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLeadSettings_1@example.com', '+13698564125');
        lead.LeadSource= 'Broker123';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.ownerId = u.Id;
        lead.Generate_Journey__c = false;
        insert lead;
        leads.add(lead);
        /*LeadConvertor.emailToLeadJourneyCreation(leads,contacts);

journeys = [select Id,ownerId from Journey__c];
system.assertEquals(1,journeys.size());

//Check if contact exist and use the same contact and convert the lead get created with same email id and create journey and assign it to primary contact
contact = new Contact(LastName = 'test', Email = 'testLeadSettings@example.com', LeadSource = 'test broker',Lead_Source_Detail__c = 'broker1', OwnerId = u.id , Convert_Lead__c = true);
insert contact;
contacts.add(contact);
System.assert(contact.Id != null);
leads.clear();
LeadConvertor.emailToLeadJourneyCreation(leads,contacts);
journeys = [select Id,ownerId from Journey__c];
system.assertEquals(2,journeys.size());
    }
    
    //Test Journey creation for single lead  
    static testMethod void testCreationOfProductInterested()
    {
        
        initFieldMappings();
        Lead lead;
        Journey__c[] journeys;
        string leadId;
        Lead[] leads;
        Contact[] contacts;
        Task[] tasks;
        Product_interested__c[] lstTestProductInt;
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, u);
        
        //If Journey is owned by the user given in settings also match the lead source and lead source details create new journey and activity
        system.runAs(u)
        {
            //Create Lead , Journey and Product Interested record
            lead = prepareLead('Smith', 'WeWork Test Company', 'testLeadProductInterest@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Lead_Source_Detail__c = 'Broker1';
            lead.Number_of_Desks_2016__c = '21-30';
            insert lead;
            
            lstTestProductInt = [select Id, Journey__c, Status__c from Product_interested__c where Lead__c =: lead.Id];
            system.assertEquals(1, lstTestProductInt.size());
            system.assertEquals('Started', lstTestProductInt[0].Status__c);
            Test.setCreatedDate(lstTestProductInt[0].Id,system.today().addDays(-5));
            
            //Delete duplicate lead and update journey and create new product intertested record because created date is less than x days
            lead = prepareLead('Smith', 'WeWork Test Company', 'testLeadProductInterest@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Lead_Source_Detail__c = 'Broker1';
            lead.Number_of_Desks_2016__c = '21-30';
            insert lead;
            Test.startTest();
            lstTestProductInt = [select Id, Journey__c, Status__c from Product_interested__c];
            system.assertEquals(2, lstTestProductInt.size());
            
            //Delete duplicate lead and update journey and do not product intertested record because created date is greater than x days
            lead = prepareLead('Smith', 'WeWork Test Company', 'testLeadProductInterest@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Lead_Source_Detail__c = 'Broker1';
            lead.Number_of_Desks_2016__c = '21-30';
            insert lead;
            
            lstTestProductInt = [select Id, Journey__c, Status__c from Product_interested__c];
            system.assertEquals(2, lstTestProductInt.size());
            
            /*Contact contact = new Contact(LastName = 'test', Email = 'testLeadProductInterest@example.com');
insert contact;
System.assert(contact.Id != null);


contacts = [Select Id,Name,Convert_Lead__c,Email from contact where Id =: contact.Id];
system.debug(logginglevel.Error,'contacts[0]::'+contacts);
system.assertEquals(true, contacts[0].Convert_Lead__c);

lstTestProductInt = [select Id, Lead__c, Contact__c, Journey__c, Status__c, Unique_Key__c from Product_interested__c];
system.debug(logginglevel.Error,'lstTestProductInt::'+lstTestProductInt);
system.assertNotEquals(lstTestProductInt[0].Contact__c, null);
system.assertNotEquals(lstTestProductInt[1].Contact__c, null);
            Test.stopTest();	
        }
    }
    
    //Created By: Amol Darekar.
    //Purpose: Give direct call to ConvertLeadToJourney If lead is inserted using
    //Jounrey import wizard for kickbox verification.
    static testMethod void testJourneyCreationForKickbox(){
        initFieldMappings();
        
        Lead lead;
        Journey__c[] journeys;
        string leadId;
        Lead[] leads;
        Task[] tasks;
        //Fetch user record to run code in users context
        User u = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, u);
        
        //If Journey is owned by the user given in settings also match the lead source and lead source details create new journey and activity
        system.runAs(u)
        {
            //Make Check_Duplicates__c checkbox true to indicate that journey is created using journey
            //import wizard.
            
            lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Lead_Source_Detail__c = 'Broker1';
            lead.Check_Duplicates__c = true;
            //lead.Number_of_Desks__c = '1';
            insert lead;
            
            lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Check_Duplicates__c = true;
            lead.Lead_Source_Detail__c = 'Broker1';
            insert lead;
            
            journeys = [Select Id,Name from Journey__c];
            system.assertEquals(1, journeys.size());
            
            //Set Journey createed date to previous date than metion in Journey JSON settings so that new journey 
            //will create for the existing lead.
            Test.setCreatedDate(journeys[0].Id,system.today().addDays(-5));
            
            Test.startTest();
            lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Check_Duplicates__c = true;
            lead.Lead_Source_Detail__c = 'Broker1';
            insert lead;
            
            //New journey and task will create for this lead.
            lead = prepareLead('Smith', 'WeWork Test Company', 'testLead2@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            lead.Check_Duplicates__c = true;
            lead.Lead_Source_Detail__c = 'Broker1';
            insert lead;
            
            journeys = [Select Id,Name from Journey__c];
            system.assertEquals(3, journeys.size());
            
            leads = [select Id,Name from Lead];
            system.assertEquals(2, leads.size());
            
            tasks = [select Id from task];
            system.assertEquals(4, tasks.size());
            
            //lstTestProductInt = [select Id, Journey__c, Journey_Status__c from Product_interested__c];
            //system.assertEquals(2, lstTestProductInt.size());
            
            Test.stopTest();
        }
    }    
    //Created By: Mayuresh Ghodke.
    //Issue No. : ST-1350 //For Contact Inactive allow create Journey creation criteria
    static testMethod void testJourneyCreationSkipForKickbox1(){
        initFieldMappings();
        
        Lead lead;
        Journey__c[] journeys;
        string leadId;
        Lead[] leads;
        Task[] tasks;
        
        //Make Check_Duplicates__c checkbox true to indicate that journey is created using journey
        //import wizard.
        lead = prepareLead('Smith', 'WeWork Test Company', 'testkickboxLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Check_Duplicates__c = true;
        lead.By_Pass_Journey_Creation_Criteria__c = true;
        //lead.Number_of_Desks__c = '1';
        insert lead;            
        
        leads = [Select Id,Name from Lead];
        system.assertEquals(1, leads.size());
        
        journeys = [Select Id,Name from Journey__c];
        system.assertEquals(1, journeys.size());
        
        tasks = [select Id from task];
        system.assertEquals(1, tasks.size());
        
        Contact contact1 = new Contact(LastName = 'test', Email = 'testKickbox1@example.com', Status__c = 'Active');
        insert contact1;
        System.assert(contact1.Id != null);
        
        lead = prepareLead('Smith', 'WeWork Test Company', 'testKickbox1@example.com', null);
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Check_Duplicates__c = true;
        lead.By_Pass_Journey_Creation_Criteria__c = true;
        insert lead;  
        
        leads = [Select Id,Name from Lead Where isConverted = false];
        system.assertEquals(1, leads.size());
        
        journeys = [Select Id,Name from Journey__c];
        system.assertEquals(1, journeys.size());
    }
    
    //Created By: Mayuresh Ghodke.
    //Issue No. : ST-1350 //For Last activity on the lead/contact is 90 days or older
    static testMethod void testJourneyCreationSkipForKickbox2(){
        initFieldMappings();
        
        Lead lead;
        Journey__c[] journeys;
        string leadId;
        Lead[] leads;
        Task[] tasks;
        
        //Make Check_Duplicates__c checkbox true to indicate that journey is created using journey
        //import wizard.
        lead = prepareLead('Smith', 'WeWork Test Company', 'testkickboxLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Check_Duplicates__c = true;
        lead.By_Pass_Journey_Creation_Criteria__c = true;
        //lead.Number_of_Desks__c = '1';
        insert lead;            
        
        leads = [Select Id,Name from Lead];
        system.assertEquals(1, leads.size());
        
        journeys = [Select Id,Name,Status__c from Journey__c];
        system.assertEquals(1, journeys.size());
        
        journeys[0].Status__c = 'Completed';
        update journeys;
        
        tasks = [select Id from task];
        system.assertEquals(1, tasks.size());
        
        lead = prepareLead('Smith', 'WeWork Test Company', 'testkickboxLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Check_Duplicates__c = true;
        lead.By_Pass_Journey_Creation_Criteria__c = true;
        //lead.Number_of_Desks__c = '1';
        insert lead;    
        
        leads = [Select Id,Name from Lead];
        system.assertEquals(1, leads.size());
        
        journeys = [Select Id,Name from Journey__c];
        system.assertEquals(1, journeys.size());  
    }
    
    static testMethod void testJourneyFieldUpdateForOwnerChange(){
        initFieldMappings();
        
        Lead lead;
        Journey__c[] journeys;
        string leadId;
        Lead[] leads;
        Task[] tasks;
        User apiUser = [Select Id from user where username =:'testapiuser89833@example.com']; 
        system.assertNotEquals(null, apiUser);
        User u1 = [Select Id from user where username =:'testweworkuser2@example.com']; 
        system.assertNotEquals(null, u1);
        
        
        lead = prepareLead('John Smiths', 'WeWork Test Company', 'testLead1@example.com', null);
        lead.Company = 'Test Company Old';
        lead.Generate_Journey__c = true;
        lead.ownerId = apiUser.Id;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Check_Duplicates__c = false;
        //lead.Number_of_Desks__c = '1';
        insert lead;
        leads = [Select Id,Name,ownerId from Lead Where isConverted = false AND Id=:lead.Id];
        system.assertEquals(1, leads.size());
        system.assertEquals(apiUser.Id, leads[0].ownerId,'Lead Owner is not same');
        
        journeys = [Select Id,Name,Owner_SFID__c,OwnerId from Journey__c where Primary_Lead__c =: leads[0].Id];
        system.assertEquals(1, journeys.size());
        system.assertEquals(apiUser.Id, journeys[0].OwnerId);
        system.assertEquals(journeys[0].Owner_SFID__c, null);
        Test.startTest();
        // Test.setCreatedDate(journeys[0].Id,system.today().addDays(-4));
        System.runAs(u1){
            lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
            lead.Company = 'Test Company';
            lead.Generate_Journey__c = true;
            lead.LeadSource= 'Broker';
            //lead.OwnerId = u1.Id;
            lead.Lead_Source_Detail__c = 'Broker1';
            lead.Check_Duplicates__c = false;
            insert lead;
            //lead = [Select Id,Name,OwnerId from Lead where Id=:lead.Id];
            //system.assertEquals(lead.OwnerId, u1.Id);
        }
        debug.Log('Converted Leads ------'+[Select Id,Name,OwnerId from Lead where isConverted = true]);
        journeys = [Select Id,Name,Owner_SFID__c,OwnerId from Journey__c where Primary_Lead__c =: leads[0].Id];
        debug.Log('journeys---'+journeys);
        system.assertEquals(1, journeys.size());
        system.assertEquals(journeys[0].Owner_SFID__c, u1.Id);
        
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead2@example.com', null);
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.OwnerId = apiUser.Id;
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Check_Duplicates__c = false;
        insert lead;
        leads = [Select Id,Name,ownerId from Lead Where isConverted =: false];
        journeys = [Select Id,Name,Owner_SFID__c from Journey__c where Primary_Lead__c =: lead.Id];
        system.assertEquals(1, journeys.size());
        system.assertEquals(journeys[0].Owner_SFID__c, null);
        
        Test.stopTest();
    }
    
    static testMethod void testJourneyFieldUpdateForOwnerChangeContact(){
        initFieldMappings();      
        Lead lead;
        Journey__c[] journeys;
        string leadId;
        Lead[] leads;
        Task[] tasks;
        User apiUser = [Select Id from user where username =:'testapiuser89833@example.com']; 
        system.assertNotEquals(null, apiUser);
        User u1 = [Select Id from user where username =:'testweworkuser2@example.com']; 
        system.assertNotEquals(null, u1);
        
        Contact contact = new Contact(LastName = 'test', Email = 'testContactChange@example.com', Status__c = 'Active', OwnerId = apiUser.id );
        insert contact;
        
        contact testObjContact = [SELECT Id,OwnerId from Contact WHERE Email =: 'testContactChange@example.com' limit 1];
        system.assertEquals(apiUser.Id, testObjContact.OwnerId);
        
        lead = prepareLead('Smith', 'WeWork Test Company', 'testContactChange@example.com', null);
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = true;
        lead.ownerId = u1.Id;
        lead.LeadSource= 'Broker';
        lead.Check_Duplicates__c = true;
        lead.Lead_Source_Detail__c = 'Broker1'; 
        insert lead;
        
        journeys = [Select Id,Name from Journey__c];
        system.assertEquals(1, journeys.size());
        
        //Set Journey createed date to previous date than metion in Journey JSON settings so that new journey 
        //will create for the existing lead.
        Test.setCreatedDate(journeys[0].Id,system.today().addDays(-5));
        Test.startTest();
        lead = prepareLead('Smith', 'WeWork Test Company', 'testContactChange@example.com', null);
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = true;
        lead.ownerId = u1.Id;
        lead.LeadSource= 'Broker';
        lead.Check_Duplicates__c = true;
        lead.Lead_Source_Detail__c = 'Broker1'; 
        insert lead;
        
        journeys = [Select Id,Name from Journey__c];
        system.assertEquals(2, journeys.size());
        
        //Check owner of contact after new lead created with non-api user and converted then it will update joureny Owner_SFID and 
        //change contact Owner to newly created lead owner.
        testObjContact = [SELECT Id,OwnerId from Contact WHERE Email =: 'testContactChange@example.com' limit 1];
        system.assertEquals(u1.Id, testObjContact.OwnerId);
        Test.stopTest();
        
    }
   /* //Added by krishana
    static testMethod void testJourneyCreationForLeadWithExistingContactWithApiuser(){  
        initFieldMappings();
        Lead lead;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        User u = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, u);
        User settingUser=[Select Id,Name From User Where userName='testapiuser89833@example.com'];       
        Debug.log('apiUser===>'+settingUser);
        System.runAs(settingUser){
            Lead objLead = new Lead();
            objLead.lastname='Smith';
            objLead.email='test4564156@examplesusie.com';
            objLead.Company = 'WeWork Test Company';
            objLead.phone = '1456466546546';
            objLead.Generate_Journey__c = true;
            objLead.LeadSource= 'Broker';
            objLead.Lead_Source_Detail__c = 'Broker1';            
            /*Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true; 
            objLead.setOptions(dmo);*/
            /*insert objLead;
            
            debug.log('Lead Id==>'+objLead.Id);            
            leads = [select Id,Name,ownerId,Email from Lead where IsConverted = false And Email='test4564156@examplesusie.com'];
            Debug.log('leads==>'+leads);
            system.assertEquals(1, leads.size());
            
            tasks = [select Id from task];
            system.assertEquals(1, tasks.size());
            
            journeys = [Select Id,Name,Email__c,Primary_Lead__c,Primary_Contact__c from Journey__c Where Email__c='test4564156@examplesusie.com'];
            Debug.log('journeys==>'+journeys);
            system.assertEquals(1, journeys.size());            
            Test.setCreatedDate(journeys[0].Id,system.today().addDays(-5));
            
            Test.startTest();
            
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leads[0].id);            
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
            
            Contact con=[Select Id,Name,ownerId From Contact Where Email='test4564156@examplesusie.com' Limit 1];
            Debug.log('Con==>'+con);
            System.assertEquals(settingUser.Id,con.ownerId);
            //Journey already exist on contact but created date is less than the date we have provided in JSON
            //So it will create new lead and convert the current lead and create journey
            Lead objLead1 = new Lead();
            objLead1.lastname='Smith123';
            objLead1.email='test4564156@examplesusie.com';
            objLead1.Company = 'WeWork Test Company';
            objLead1.phone = '1456466546546';
            objLead1.Generate_Journey__c = true;
            objLead1.LeadSource= 'Broker';
            objLead1.Lead_Source_Detail__c = 'Broker1';            
           /* Database.DMLOptions dmo1 = new Database.DMLOptions();
            dmo1.assignmentRuleHeader.useDefaultRule= true; 
            objLead1.setOptions(dmo1);*/
            /*insert objLead1;
            leads = [select Id,Name,ownerId,Email from Lead where IsConverted = true AND Email='test4564156@examplesusie.com'];
            Debug.log('leads==>'+leads);
            system.assertEquals(2, leads.size());
            
            journeys = [Select Id,Name,Email__c,Primary_Lead__c,Primary_Contact__c,isContactLeadOwnerIsAPIUser__c from Journey__c Where Email__c='test4564156@examplesusie.com'];
            Debug.log('journeys after==>'+journeys);
            Debug.log('journeys 1 ==>'+journeys[0].isContactLeadOwnerIsAPIUser__c);
            Debug.log('journeys 2 ==>'+journeys[0].isContactLeadOwnerIsAPIUser__c);
          
            system.assertEquals(2, journeys.size());
            system.assertEquals(journeys[0].isContactLeadOwnerIsAPIUser__c, false);
            system.assertEquals(journeys[1].isContactLeadOwnerIsAPIUser__c, true);
            
            Test.stopTest();
        } 
    }
    
   static testMethod void testFieldMapping(){
        LeadConvertor.Lead2Contact();
        LeadConvertor.Lead2Journey();
        LeadConvertor.Lead2Activity();
        LeadConvertor.Lead2Account();
        LeadConvertor.DefaultJourneySettings();
    }
   /*  static testMethod void testLeadContactOwner(){
        WeWorkValidatorHelper.createTerritoryStructure();
        Map<String,Object> mapData = new Map<String,Object>();
        Map<String,Object> mapData1 = new Map<String,Object>();
      
        
        User  u = [select id from User where id =: '005F0000003KmbwIAC'];
        debug.log('user :: =>>>>'+u);
        mapData.put('first_name','John');
        mapData.put('last_name','Smith');
        mapData.put('email','john.smith@xyz.com');//lead shode be assign to queue
        mapData.put('phone','9168200192');
        mapData.put('company_name','Test Company');
        mapData.put('company_size','5-10 desks');
        mapData.put('lead_source','WeWork.com');
        mapData.put('lead_source_detail','Book a Tour Form');
        Building__c objBuilding = [Select Id,Community_Lead__c,Cluster__r.Sales_Lead__c,UUID__c,Community_Sales_Lead__c From Building__c Where Name='Test Building Tour'][0];
        mapData.put('tour_building_uuid',objBuilding.UUID__c);
        mapData.put('buildings_interested_uuids',new List<Object>{objBuilding.UUID__c});
         Test.startTest();
        //RESTInboundLead.Response leadResponse = WeWorkValidatorHelper.insertInboundLead(mapData);
        //System.assertEquals(true,leadResponse.success,'Failed to create inbound lead, Error: '+leadResponse.message);
        //RESTTour.Response tourResponse = WeWorkValidatorHelper.bookTour(mapData);
  		//debug.log('tourResponse'+tourResponse);
        System.runAs(u){
        mapData1.put('first_name','John');
        mapData1.put('last_name','Smith');
        mapData1.put('email','john.smith@xyz.com');//lead shode be assign to queue
        mapData1.put('phone','9168200192');
        mapData1.put('company_name','Test Company');
        mapData1.put('company_size','5-10 desks');
        mapData1.put('lead_source','WeWork.com');
        mapData1.put('lead_source_detail','Book a Tour Form');
        mapData1.put('tour_building_uuid',objBuilding.UUID__c);
        mapData1.put('buildings_interested_uuids',new List<Object>{objBuilding.UUID__c});
            Test.stopTest();
        //RESTInboundLead.Response leadResponse1 = WeWorkValidatorHelper.insertInboundLead(mapData1);
        //debug.log('leadResponse1 : '+leadResponse1);
        //Journey__c[] lstJorney = [select id,status__c from Journey__c where status__c = 'Started'];
        //Debug.log('objJorney:: '+lstJorney);
        //System.assertEquals(1, lstJorney.size());
             
        }    
        
    }*/
}