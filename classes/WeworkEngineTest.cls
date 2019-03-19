//comment for cherrypic
/*
* @ Created By : Anant Kumar
* @ Created Date : 15 Mar 2016
*/
@isTest
private class WeworkEngineTest { 
    
    @TestSetup
    static void initData() {
        SalesConsoleSettings.createSettings();
        Building__c b1 = new Building__c(Name = 'B1');
        insert b1;
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'testU', Email='testUser@example.com', 
                           EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = true,
                           TimeZoneSidKey='America/Los_Angeles', UserName='testUserName1@example.com');
        insert u1; 
    }
    
    static void testWeworkEngine(){
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        String strQuery = 'SELECT Id FROM Account WhERE Id= \'' + accRec.Id + '\'';
        WeworkEngine engineObj = new WeworkEngine();
        System.assertEquals(accRec.Id, WeWorkEngine.Query(strQuery)[0].Id);
        System.assertEquals(UserInfo.getUserId(), WeWorkEngine.GetLoggedInUserInfo().Id);
        System.assertEquals(true, WeWorkEngine.fetchObjectFields('Account', 'AccountSource').size() > 0);
        String strSearchQuery = 'FIND \'*Account*\' IN Name FIELDS RETURNING Account( Id, Name )';
        WeWorkEngine.searchQuery(strSearchQuery); 
    }
    static void verifySaveRecords(){
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(new Account(Name = 'Test'));
        List<SaveResult> saveResult = WeworkEngine.SaveRecords(lstAccount);
        System.assert(saveResult[0].IsSuccess); 
        
        List<SObject> lstSObject = new List<SObject>();
        lstSObject.add(new Account());
        List<SaveResult> nullSaveResult = WeworkEngine.SaveRecords(lstSObject);
        System.assertEquals(true,saveResult[0].IsSuccess);
    }
    static void verifyDeleteRecords(){
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(new Account(Name = 'TestJohnSmith'));
        List<SaveResult> saveResult = WeworkEngine.SaveRecords(lstAccount);
        System.assert(saveResult[0].IsSuccess);
        saveResult = WeworkEngine.SaveRecords(lstAccount);
        System.assert(saveResult[0].IsSuccess);
        List<Database.DeleteResult>  deleteResult = WeworkEngine.DeleteRecords(new List<Id>{saveResult[0].Id});
        System.assert(deleteResult[0].isSuccess());
        List<Database.DeleteResult>  deleteResultNull = WeworkEngine.DeleteRecords(new List<Id>());
    }
	@isTest
    static void verifyGetAllFields(){
        WeworkEngine.GetAllFields('Lead');        
    }
    
    @isTest
    static void verifyGetUserName(){
        String strUserName = WeworkEngine.getUserName();
        System.assertEquals(strUserName, UserInfo.getName());
    }
    
    static void verifyGetSettings(){
        Setting__c settings = new Setting__c(Name = 'Test Settings');
        insert Settings;
        Setting__c objSettings = WeworkEngine.getSettings(Settings.Id);
    }
    
    static void verifyLoadAvailableTimes(){
        Building__c b = new Building__c(
            City__c = 'Test City',
            Name = 'Test Building',
            CurrencyIsoCode = 'USD',
            Time_Zone__c = 'America/New_York'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Product_Line__c = 'WeWork',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Building__c = b.Id,
                Tour_Schedule__c = tour_Schedule.id
            ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Tuesday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Wednesday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Thursday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Friday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Saturday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Sunday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                )      
                };
                    WeworkEngine.loadAvailableTimes(Date.today().addDays(1),b.Id,'WeWork','America/New_York');              
    }
    
    static void verifyGetBuildingList(){
        List<Building__c> lstBuilding = new List<Building__c>();
        lstBuilding.add(new Building__c(City__c = 'Amsterdam', Country__c = 'Netherlands',Name = 'AMS-Metropool', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam'));
        lstBuilding.add(new Building__c(City__c = 'Brooklyn',Country__c = 'USA',State__c='CA',Name = 'BKN-Brooklyn Heights',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/New_York'));
        lstBuilding.add(new Building__c(City__c = 'Berlin Mitte',Country__c = 'Germany',Name = 'BL-Sony Center',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/New_York'));
        lstBuilding.add(new Building__c(City__c = 'Amsterdam',Country__c = 'USA',State__c='CA',Name = 'AMS-Labs',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/New_York'));
        lstBuilding.add(new Building__c(City__c = 'Chicago',Country__c = 'USA',State__c='CA',Name = 'CHI-River North',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/Chicago'));
        List<SaveResult> saveResult = WeworkEngine.SaveRecords(lstBuilding);
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = saveResult[0].Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Product_Line__c = 'WeWork',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        WeworkEngine.getBuildingList('WeWork');              
    }
    
    static void verifyReScheduleTours(){
        Date thisDate = Date.today();
        Building__c b = new Building__c(City__c = 'Amsterdam', Country__c = 'Netherlands',Name = 'AMS-Metropool', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam');
        insert b;
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Product_Line__c = 'WeWork',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Building__c = b.Id,
                Tour_Schedule__c = tour_Schedule.id
            ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Tuesday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Wednesday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Thursday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Friday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Saturday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Sunday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                )      
                };
                    
        list<Tour_Outcome__c> listTourOutcome1 = new list<Tour_Outcome__c>();
        listTourOutcome1.add(new Tour_Outcome__c(Tour_Date__c = thisDate,Location__c = b.Id,Start_Time__c = '4:00PM',End_Time__c = '7:00PM'));
        list<Tour_Outcome__c> listTourOutcome2 = new list<Tour_Outcome__c>();
        listTourOutcome2.add(new Tour_Outcome__c(Tour_Date__c = thisDate,Location__c = b.Id,Start_Time__c = '18:30PM',End_Time__c = '7:30PM'));  
        list<Tour_Outcome__c> listTourOutcome3 = new list<Tour_Outcome__c>();
        listTourOutcome3.add(new Tour_Outcome__c(Start_Time__c = '18:30PM',End_Time__c = '7:30PM'));    
        WeworkEngine.reScheduleTours(listTourOutcome1,listTourOutcome2);  
        WeworkEngine.reScheduleTours(listTourOutcome3,listTourOutcome3);
        /*Added By Milanjeet Singh*/
       	list<Tour_Outcome__c> listTourOutcome4 = new list<Tour_Outcome__c>();
        listTourOutcome4.add(new Tour_Outcome__c(Tour_Date__c = thisDate,Location__c = b.Id,Start_Time__c = '19:30PM',End_Time__c = '8:30PM'));
       	WeworkEngine.reScheduleTours(listTourOutcome4,null);        
    }
    
    static void verifyCreateJourneryAndJourneyContact_1(){
        //Insert Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        //Insert two contacts
        Contact c1 = new Contact(FirstName = 'Test',
                                 LastName = 'Contact1',
                                 Email = 'testContact1@example.com',
                                 AccountId = acc.Id,
                                 Phone = '3256987425');
        insert c1;
        Contact c2 = new Contact(FirstName = 'Test',
                                 LastName = 'Contact2',
                                 AccountId = acc.Id,
                                 Email = 'testContact2@example.com',
                                 Phone = '3256987455',
                                 LeadSource = 'Inbound Call');
        insert c2;
        
        Building__c tesBuilding = new Building__c(Name = 'LON-Paddington',
                                                  City__c = 'London',
                                                  CurrencyIsoCode = 'USD');
        insert tesBuilding;
        
        
        WeworkEngine.createJourneryAndJourneyContact(c2.Id, c2.LeadSource, tesBuilding.Id, tesBuilding.City__c, false);
    } 
    
    static void verifyCreateJourneryAndJourneyContact_2(){
        //Insert Account
        Account acc = new Account(Name = 'Test Account1');
        insert acc;
        
        //Insert two contacts
        Contact c1 = new Contact(FirstName = 'Test',
                                 LastName = 'Contact1',
                                 AccountId = acc.Id,
                                 Email = 'testContact3@example.com',
                                 Phone = '3256987425');
        insert c1;
        Contact c2 = new Contact(FirstName = 'Test',
                                 LastName = 'Contact2',
                                 AccountId = acc.Id,
                                 Email = 'testContact4@example.com',
                                 Phone = '3256987455',
                                 LeadSource = 'Inbound Call');
        insert c2;
        
        Building__c tesBuilding = new Building__c(Name = 'LON-Paddington',
                                                  City__c = 'London',
                                                  CurrencyIsoCode = 'USD');
        insert tesBuilding;
        
        WeworkEngine.createJourneryAndJourneyContact(c2.Id, c2.LeadSource, tesBuilding.Id, tesBuilding.City__c, true);
    } 
    
    static void verifyAddBusinessDays(){
        Date resultDate = WeworkEngine.addBusinessDays(2016, 02, 25, 3);
    }
      
    static void verifyFetchObjectFields(){
        Account accRec = TestingUtility.createAccount('strAccountName1', true);
        accRec.Name = 'Test1';
        update accRec;
        
        Contact newContact1 = new Contact();
        newContact1.AccountId = accRec.Id;
        newContact1.firstname = 'TestFirstName';
        newContact1.lastname = 'TestLastName';
        newContact1.Email = 'Test11@example.com';
        newContact1.Status__c = 'active';
        newContact1.Convert_Lead__c = true;
        insert newContact1;
        
        Contact newContact2 = new Contact();
        newContact2.AccountId = accRec.Id;
        newContact2.firstname = 'TestFirstName';
        newContact2.lastname = 'TestLastName';
        newContact2.Email = 'Test12@example.com';
        newContact2.Status__c = 'active';
        newContact2.Convert_Lead__c = true;
        insert newContact2;
        
        WeworkEngine.fetchObjectFields('Contact','Email');
    }
    
    static void verifyConstructSobject(){
        
        String jsonStr = '{"LastName":"Doe", "End_Date__c" :"'+ System.today() +'", "ID_Last_Sync__c":"'+ System.now() +'", "Interested_in_Number_of_Desks__c":"'+ 2 +'"}';
        //String jsonstring = Json.serialize(jsonStr); 
        WeworkEngine.ConstructSobject('Contact',jsonStr);
        /*Added By Milanjeet*/
        String jsonStr2 = '{"Name":"TestOpportunity","Negotiated_Price__c":"'+100.25+'","Probability":"'+10+'","Monthly_Phone_Fee__c":"'+52+'","Count_of_Desk__c":"'+5+'"}';
        WeworkEngine.ConstructSobject('Opportunity',jsonStr2);
    } 
    
    static void testDeleteRecord(){        
        String jsonStr = '{"LastName":"Doe","End_Date__c" :"'+ System.today() +'", "ID_Last_Sync__c":"'+ System.now() +'", "Interested_in_Number_of_Desks__c":"'+ 2 +'"}';
        WeworkEngine.DeleteRecord('Name',jsonStr);
    }
    
    static testMethod void testGetTypedSetings(){
        MySettings settingsMy = new MySettings();
        settingsMy.count = 10;
        settingsMy.timestamp = Date.today();
        settingsMy.name = 'Test';
        
        Setting__c setting = new Setting__c( Name = 'Test', Data__c = JSON.serialize(settingsMy));
        insert setting;
        
        Setting__c settingsNew = WeworkEngine.getSettingsRecord('Test');       
    }
    
    public class MySettings {
        Integer count;
        Date timestamp;
        String name;
    }
    
    static testMethod void testExtendReference(){
        Test.startTest();
        Account accRec = TestingUtility.createAccount('strAccountName2', true);
        Contact referrer1 = new Contact();
        referrer1.LastName = 'referrer1';
        referrer1.Email = 'referrer1@example.com';
        TestingUtility.insertWithAssert(referrer1);
        
        Contact referrer2 = new Contact();
        referrer2.LastName = 'referrer1';
        referrer2.Email = 'referrer2@example.com';
        TestingUtility.insertWithAssert(referrer2);
        
        Referral__c referral1 = new Referral__c();
        referral1.Referral_Email__c = 'referral1@example.com';
        referral1.IsActive__c = true;
        referral1.Referrer__c = referrer1.Id;
        referral1.Expires_On__c = Date.today().addDays(10);
        TestingUtility.insertWithAssert(referral1);
        
        Referral__c referral2 = new Referral__c();
        referral2.Referral_Email__c = 'referral2@example.com';
        referral2.IsActive__c = false;
        referral2.Referrer__c = referrer1.Id;
        referral2.Expires_On__c = Date.today().addDays(10);
        TestingUtility.insertWithAssert(referral2);
        
        WeworkEngine.extendReference(referral1.Id,Date.today(), Date.today());
        Referral__c assertReferral = [Select Id,Name,Referral_Email__c,Expires_On__c,Referrer__r.Name,Referrer_Email__c,Referred_Date__c From Referral__c where Id =:referral1.Id ];
        
        System.assertEquals(assertReferral.Expires_On__c , Date.today().addDays(60));
        System.assertEquals(assertReferral.Referred_Date__c , Date.today());
        Test.stopTest();
    }
    
    
    //For method createActivityForTour 
    static void verifyCreateActivityForTour(){
        Account accRec = TestingUtility.createAccount('strAccountName3', true);
        accRec.Name = 'TestAccount';
        update accRec;
        
        Contact newContact2 = new Contact();
        newContact2.AccountId = accRec.Id;
        newContact2.firstname = 'TestFirstName';
        newContact2.lastname = 'TestLastName';
        newContact2.Email = 'Test111@example.com';
        newContact2.Phone = '9874563210';
        newContact2.Status__c = 'active';
        newContact2.Convert_Lead__c = true;
        insert newContact2;
        
        Task newTask = new Task();
        Date activityDate = Date.newInstance(2016, 10, 13);
        newTask.ActivityDate = activityDate;
        newTask.Product_Line__c = 'WeWork';
        
        List<Task> lstTask = new List<Task>();
        lstTask.add(newTask);
        String Id = newContact2.Id;
        WeworkEngine.createActivityForTour(Id,'2016-08-08','');
        
    }
    
    /*
    * @ Created By : 	Mayuresh Ghodke
    * @ Created Date : 	27-07-2016
    */
    testMethod static void verifyChangeLeadRecordType(){  
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForLightning());
        Lead lead1 = new Lead(
            FirstName = 'Test', 
            LastName = 'Test',
            Company = 'Test',
            Email = 'Test1@example.com',
            LeadSource = 'other',
            Status = 'TestStatus',
            CurrencyIsoCode = 'USD'
        );
        insert lead1;       
        String resultNeg1 = WeworkEngine.changeLeadRecordType(lead1.Id);        
        System.assertEquals(resultNeg1, 'Please update Company Size to submit to Enterprise Solution Team');
        
        Lead lead2 = new Lead(
            FirstName = 'WeworkEngineTestTest', 
            LastName = 'Test',
            Company = 'Test',
            Email = 'Test2@example.com',
            LeadSource = 'other',
            Status = 'TestStatus',
            CurrencyIsoCode = 'USD',
            Company_Size__c = '5-10'
            
        );
        insert lead2;
        
        String resultNeg2 = WeworkEngine.changeLeadRecordType(lead2.Id);
        System.assertEquals(resultNeg2, 'Company Size is less than 15 desk. Unable to submit to Enterprise Solution Team');
        Test.startTest();
        List<Group> lstOwnerInfo = new List<Group>();
        lstOwnerInfo = [select Id From Group where Name = 'Enterprise Queue'];
        
        Lead lead4 = new Lead(
            FirstName = 'Test', 
            LastName = 'Test',
            Company = 'Test',
            Email = 'Test4@example.com',
            LeadSource = 'other',
            Status = 'TestStatus',
            CurrencyIsoCode = 'USD',
            Company_Size__c = '6-20',
            OwnerId = lstOwnerInfo[0].Id
        );
        insert lead4;
        
        String result4 = WeworkEngine.changeLeadRecordType(lead4.Id);
        System.assertEquals(result4, 'Lead is submitted to Enterprise Solution Team successfully');       
        Lead lead5 = new Lead(
            FirstName = 'Test', 
            LastName = 'Test',
            Company = 'Test',
            Email = 'Test5@example.com',
            LeadSource = 'other',
            Status = 'TestStatus',
            CurrencyIsoCode = 'USD',
            Company_Size__c = '6-20',
            RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Consumer').getRecordTypeId()          
        );
        insert lead5;
         
        String result5 = WeworkEngine.changeLeadRecordType(lead5.Id);
        System.assertEquals(result5, 'Lead is submitted to Enterprise Solution Team successfully');        
        String resultNeg5 = WeworkEngine.changeLeadRecordType(lead5.Id);
        System.assertEquals(resultNeg5, 'Lead is already submitted to Enterprise Solution Team');              
        Test.stopTest();
    }    
    
    static testMethod void verifyChangeLeadRecordTypeForLarge(){        
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForLightning());
        Lead lead1 = new Lead(
            FirstName = 'Test', 
            LastName = 'Test',
            Company = 'Test',
            Email = 'Test1@example.com',
            LeadSource = 'other',
            Status = 'TestStatus',
            CurrencyIsoCode = 'USD',
            Company_Size__c = '100+'
        );
        insert lead1;
        
        String resultNeg1 = WeworkEngine.changeLeadRecordType(lead1.Id);
        System.assertEquals(resultNeg1, 'Lead is submitted to Enterprise Solution Team successfully');  
        
        Lead lead2 = new Lead(
            FirstName = 'Test', 
            LastName = 'Test',
            Company = 'Test',
            Email = 'Test2@example.com',
            LeadSource = 'other',
            Status = 'TestStatus',
            CurrencyIsoCode = 'USD',
            Company_Size__c = '+201'
        );
        insert lead2;
        System.debug('lead2 Id::'+lead2.Id);
        String resultNeg2 = WeworkEngine.changeLeadRecordType(lead2.Id);
        System.assertEquals(resultNeg2, 'Lead is submitted to Enterprise Solution Team successfully');  
        Test.stopTest();
    }
    
    static testMethod void verifyChangeStageRelatedLeadOrContactOnJourney(){
        Test.startTest();
        WeworkEngine.JourneyStageUpdateResult resultContact = new WeworkEngine.JourneyStageUpdateResult();
        WeworkEngine.JourneyStageUpdateResult resultLead = new WeworkEngine.JourneyStageUpdateResult();
        //Test Account created for testContact.
        Account testAccount = new Account();
        testAccount.Name = 'Test Account2';
        
        insert testAccount;
        //Test Contact created for testJourney.
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.firstname = 'TestFirstName';
        testContact.lastname = 'TestLastName';
        testContact.Email = 'Test111@example.com';
        testContact.Status__c = 'active';
        insert testContact;
        System.assertNotEquals(testContact.Id, null);
        
        //Test Journey for JourneyDetailController.        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'testJourneyName';
        testJourney.CurrencyIsoCode = 'USD';
        testJourney.Primary_Contact__c = testContact.Id;
        testJourney.Status__c ='Started';
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        TestingUtility.insertWithAssert(testJourney);
        
        resultContact = WeworkEngine.changeStageRelatedLeadOrContactOnJourney(testJourney.Id);
        
        System.assertEquals(resultContact.errorType ,'success');
        
        //Test Account created for testContact.
        Lead leadNew = new Lead(LastName = 'Test Lead Last Name', Company = 'Test Company', Email = 'test@example.com', Phone = '1212121125', Generate_Journey__c = false);
        insert leadNew;
        //Test Journey for JourneyDetailController.        
        Journey__c testJourneyLead = new Journey__c();
        testJourneyLead.Name = 'testJourneyLead';
        testJourneyLead.CurrencyIsoCode = 'USD';
        testJourneyLead.Primary_Lead__c = leadNew.Id;
        testJourneyLead.Status__c ='Started';
        testJourneyLead.NMD_Next_Contact_Date__c = Date.today();
        testJourneyLead.Outreach_Stage__c = 'Call 1';
        TestingUtility.insertWithAssert(testJourneyLead);
        
        resultLead = WeworkEngine.changeStageRelatedLeadOrContactOnJourney(testJourneyLead.Id);
        System.assertEquals(resultLead.errorType ,'success');
        Test.stopTest();
    }
    
    static testMethod void testSetOutreachStage(){
        Test.startTest();
        //Test Account created for testContact.
        Account testAccount = new Account();
        testAccount.Name = 'Test Account3';
        insert testAccount;
        //Test Contact created for testJourney.
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.firstname = 'TestFirstName';
        testContact.lastname = 'TestLastName';
        testContact.Email = 'Test111@example.com';
        testContact.Status__c = 'active';
        insert testContact;
        System.assertNotEquals(testContact.Id, null);
        
        //Test Journey for JourneyDetailController.        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'testJourneyName';
        testJourney.CurrencyIsoCode = 'USD';
        testJourney.Primary_Contact__c = testContact.Id;
        testJourney.Status__c ='Started';
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        TestingUtility.insertWithAssert(testJourney);
        
        WeworkEngine.setOutreachStage(testJourney.Id);
        
        
        //Test Account created for testContact.
        Lead leadNew = new Lead(LastName = 'Test Lead Last Name', Company = 'Test Company', Email = 'test@example.com', Phone = '1212121125', Generate_Journey__c = false);
        insert leadNew;
        //Test Journey for JourneyDetailController.        
        Journey__c testJourneyLead = new Journey__c();
        testJourneyLead.Name = 'testJourneyLead';
        testJourneyLead.CurrencyIsoCode = 'USD';
        testJourneyLead.Primary_Lead__c = leadNew.Id;
        testJourneyLead.Status__c ='Started';
        testJourneyLead.NMD_Next_Contact_Date__c = Date.today();
        testJourneyLead.Outreach_Stage__c = 'Call 1';
        TestingUtility.insertWithAssert(testJourneyLead);
        
        WeworkEngine.setOutreachStage(testJourneyLead.Id);
        
        Test.stopTest();
    } 
    
    static testMethod void testCreateActivityForFollowUp(){
        Test.startTest();
        //Test Account created for testContact.
        Account testAccount = new Account();
        testAccount.Name = 'Test Account4';
        insert testAccount;
        //Test Contact created for testJourney.
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.firstname = 'TestFirstName';
        testContact.lastname = 'TestLastName';
        testContact.Email = 'Test111@example.com';
        testContact.Status__c = 'active';
        insert testContact;
        System.assertNotEquals(testContact.Id, null);
        
        //Test Journey for JourneyDetailController.        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'testJourneyName';
        testJourney.CurrencyIsoCode = 'USD';
        testJourney.Primary_Contact__c = testContact.Id;
        testJourney.Status__c ='Started';
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        TestingUtility.insertWithAssert(testJourney);
        
        Database.SaveResult[] resultContact = WeworkEngine.createActivityForFollowUp(testJourney.Id,'2016-10-10','Description');
        
        
        //Test Account created for testContact.
        Lead leadNew = new Lead(LastName = 'Test Lead Last Name', Company = 'Test Company', Email = 'test@example.com', Phone = '1212121125', Generate_Journey__c = false);
        insert leadNew;
        //Test Journey for JourneyDetailController.        
        Journey__c testJourneyLead = new Journey__c();
        testJourneyLead.Name = 'testJourneyLead';
        testJourneyLead.CurrencyIsoCode = 'USD';
        testJourneyLead.Primary_Lead__c = leadNew.Id;
        testJourneyLead.Status__c ='Started';
        testJourneyLead.NMD_Next_Contact_Date__c = Date.today();
        testJourneyLead.Outreach_Stage__c = 'Call 1';
        testJourneyLead.NMD_Next_Contact_Date__c = Date.today();
        TestingUtility.insertWithAssert(testJourneyLead);
        
        
        Database.SaveResult[] resultLead = WeworkEngine.createActivityForFollowUp(testJourneyLead.Id, '2016-10-10','Description');
        
        Test.stopTest();
    }
    
    static testMethod void testSetJourneyStageToManualOutreach(){
        Test.startTest();
        //Test Account created for testContact.
        Account testAccount = new Account();
        testAccount.Name = 'Test Account5';
        insert testAccount;
        //Test Contact created for testJourney.
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.firstname = 'TestFirstName';
        testContact.lastname = 'TestLastName';
        testContact.Email = 'Test111@example.com';
        testContact.Status__c = 'active';
        insert testContact;
        System.assertNotEquals(testContact.Id, null);
        
        //Test Journey for JourneyDetailController.        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'testJourneyName';
        testJourney.CurrencyIsoCode = 'USD';
        testJourney.Primary_Contact__c = testContact.Id;
        testJourney.Status__c ='Started';
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        TestingUtility.insertWithAssert(testJourney);
        
        WeworkEngine.setJourneyStageToManualOutreach(testJourney.Id);
        
        //Test Account created for testContact.
        Lead leadNew = new Lead(LastName = 'Test Lead Last Name', Company = 'Test Company', Email = 'test@example.com', Phone = '1212121125', Generate_Journey__c = false);
        insert leadNew;
        //Test Journey for JourneyDetailController.        
        Journey__c testJourneyLead = new Journey__c();
        testJourneyLead.Name = 'testJourneyLead';
        testJourneyLead.CurrencyIsoCode = 'USD';
        testJourneyLead.Primary_Lead__c = leadNew.Id;
        testJourneyLead.Status__c ='Started';
        testJourneyLead.NMD_Next_Contact_Date__c = Date.today();
        testJourneyLead.Outreach_Stage__c = 'Call 1';
        TestingUtility.insertWithAssert(testJourneyLead);
        
        WeworkEngine.setJourneyStageToManualOutreach(testJourneyLead.Id);
        
        //Test Account created for testContact.
        Lead leadNew1 = new Lead(LastName = 'Test Lead Last Name', Company = 'Test Company', Email = 'test1@example.com', Phone = '1212121125', Generate_Journey__c = false);
        insert leadNew1;
        //Test Journey for JourneyDetailController.        
        Journey__c testJourneyLead1 = new Journey__c();
        testJourneyLead1.Name = 'testJourneyLead';
        testJourneyLead1.CurrencyIsoCode = 'USD';
        testJourneyLead1.Primary_Lead__c = leadNew1.Id;
        testJourneyLead1.Status__c ='Manual Outreach';
        testJourneyLead1.NMD_Next_Contact_Date__c = Date.today();
        testJourneyLead1.Outreach_Stage__c = 'Call 1';
        TestingUtility.insertWithAssert(testJourneyLead1);
        
        WeworkEngine.setJourneyStageToManualOutreach(testJourneyLead1.Id);
        Test.stopTest();
    } 
    
 
    static testMethod void testSendToEnterpriseJourney(){
        //Test Account created for testContact.
        Account testAccount = new Account();
        testAccount.Name = 'Test Account6';
        Test.startTest();
        insert testAccount;
        //Test Contact created for testJourney.
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.firstname = 'TestFirstName';
        testContact.lastname = 'TestLastName';
        testContact.Email = 'Test111@example.com';
        testContact.Status__c = 'active';
        insert testContact;
        System.assertNotEquals(testContact.Id, null);
        
        //Test Journey for JourneyDetailController.        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'testJourneyName';
        testJourney.CurrencyIsoCode = 'USD';
        testJourney.Primary_Contact__c = testContact.Id;
        testJourney.Status__c ='Started';
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        TestingUtility.insertWithAssert(testJourney);
        WeworkEngine.sendToEnterpriseJourney(testJourney.Id);
        
        //Test Account created for testContact.
        Lead leadNew = new Lead(LastName = 'Test Lead Last Name', Company = 'Test Company', Email = 'test@example.com', Phone = '1212121125', Generate_Journey__c = false);
        insert leadNew;
        //Test Journey for JourneyDetailController.        
        Journey__c testJourneyLead = new Journey__c();
        testJourneyLead.Name = 'testJourneyLead';
        testJourneyLead.CurrencyIsoCode = 'USD';
        testJourneyLead.Primary_Lead__c = leadNew.Id;
        testJourneyLead.Status__c ='Started';
        testJourneyLead.NMD_Next_Contact_Date__c = Date.today();
        testJourneyLead.Outreach_Stage__c = 'Call 1';
        TestingUtility.insertWithAssert(testJourneyLead);
        WeworkEngine.sendToEnterpriseJourney(testJourneyLead.Id);
        
        //Test Account created for testContact.
        Lead leadNew1 = new Lead(LastName = 'Test Lead Last Name', Company = 'Test Company', Email = 'test1@example.com', Phone = '1212121125', Generate_Journey__c = false);
        insert leadNew1;
        Test.stopTest();
        //Test Journey for JourneyDetailController.        
        Journey__c testJourneyLead1 = new Journey__c();
        testJourneyLead1.Name = 'testJourneyLead';
        testJourneyLead1.CurrencyIsoCode = 'USD';
        testJourneyLead1.Primary_Lead__c = leadNew1.Id;
        testJourneyLead1.Status__c ='Manual Outreach';
        testJourneyLead1.NMD_Next_Contact_Date__c = Date.today();
        testJourneyLead1.Outreach_Stage__c = 'Call 1';
        TestingUtility.insertWithAssert(testJourneyLead1);
        
        WeworkEngine.sendToEnterpriseJourney(testJourneyLead1.Id);
        system.assertNotEquals(null,WeworkEngine.getObjectRecordTypeId('Lead','Partnership'));
        
        try{
            WeworkEngine.sendToEnterpriseJourney(null);
        } catch(Exception exc){}
        
    } 
    
    static testMethod void combineSmallTests(){
        //verifyGetAllFields();
        verifyGetUserName();
        verifyGetSettings();
        verifyAddBusinessDays();       
        verifyConstructSobject();
        testDeleteRecord();
        verifyCreateActivityForTour();
        testWeworkEngine();        
        verifySaveRecords();
        verifyDeleteRecords();
        verifyGetBuildingList();       
        Test.startTest();
        verifyCreateJourneryAndJourneyContact_1();
        verifyCreateJourneryAndJourneyContact_2();
        verifyFetchObjectFields();
        verifyLoadAvailableTimes();
        verifyReScheduleTours();       
        Test.stopTest();
    }
    
    /*
    *	Created By   	: Dipak Pawar
    *	Created Date 	: 23-09-2016
    * 	Issue No.		: ST-701
    */
    static testMethod void verifyExceptionFormatter(){
        try {
            insert new Lead();            
        }catch(Exception ex) {
            Debug.log('Exception :: '+WeworkEngine.exceptionFormatter(ex));
        }   
    }
    
    /*
    *	Created By   	: Dipak Pawar
    *	Created Date 	: 23-09-2016
    * 	Issue No.		: ST-719
    */
    static testMethod void verifyAddOpportunity() {         
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);        
        Map<String, Id> accRecordType = TestingUtility.getRecordTypeMapByName(Account.sObjectType);       
       	Map<String, Id> conRecordType = TestingUtility.getRecordTypeMapByName(Contact.sObjectType);
        Map<String, sObject> objectsToSave = new Map<String, sObject>();
        
        Building__c building1 = new Building__c(Name='test building 1', uuid__c = 'abc123');
        insert building1;
        System.assertNotEquals(null, building1.Id);
        
        Building__c building2 = new Building__c(Name='test building 2', uuid__c = 'abc1234');
        insert building2;
        
        System.assertNotEquals(null, building2.Id);

        Account accRec = new Account();
        accRec.RecordTypeId = accRecordType.get('Consumer');
        accRec.Name='Test Account7';
        accRec.Number_of_Full_Time_Employees__c = 1;
        insert accRec;        
        System.assertNotEquals(null, accRec.Id);
        
        Contact testContact = new Contact(
            AccountId =  accRec.Id,	
            firstname = 'TestFirstName',
            lastname = 'TestLastName',
            email = 'testContact@example.com',
            RecordTypeId = conRecordType.get('Consumer'),
            Status__c = 'active',
            Interested_in_Number_of_Desks__c = 2,
            Number_of_Full_Time_Employees__c = 1,
            Location_Interested__c = building1.Name,
            Referrer__c  = null	          
        ); 
        insert testContact;
        
        System.assertNotEquals(null, testContact.Id);
        
        Journey__c testJourney = new Journey__c();
	    testJourney.Name = 'testJourney';
	    testJourney.CurrencyIsoCode = 'USD';
	    testJourney.Primary_Contact__c = testContact.Id;
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        testJourney.Locations_Interested__c = building1.Name;
	    TestingUtility.insertWithAssert(testJourney);
	    System.assertNotEquals(null, testJourney.Id);
      
        Map<String,List<Object>> opportunityData = WeworkEngine.getJourneyOpportunityData(String.valueOf(accRec.Id), String.valueOf(testContact.Id), String.valueOf(testJourney.Id));
        System.assertEquals(5, opportunityData.size());
	    
	    testJourney.Building_Interested_In__c = building1.Id;
	    
        Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec.Primary_Member__c = testContact.Id;
        oppRec.StageName = 'Qualifying';
        oppRec.CurrencyIsoCode = 'USD';
        oppRec.Journey__c = testJourney.Id;
        oppRec.CloseDate = system.today().addDays(5);
        oppRec.RecordTypeId = oppRecordType.get('Consumer');
        oppRec.Locations_Interested__c = building1.Name;
        oppRec.Number_of_Full_Time_Employees__c = 1;
        oppRec.CurrencyIsoCode = 'USD';
		oppRec.Owner_Auto_Assign__c = true;
        
        objectsToSave.put('Account', accRec);
        objectsToSave.put('Contact', testContact);
        objectsToSave.put('Opportunity', oppRec);
        objectsToSave.put('Journey', testJourney);
        List<SaveResult> result = WeworkEngine.addOpportunity(objectsToSave.values(), testContact.Id);
        System.assertEquals(4, result.size());
        for(SaveResult res : result){
        	System.assertEquals(true, res.IsSuccess);
        }
		
		Account acc = [SELECT Id, RecordTypeId, Number_of_Full_Time_Employees__c FROM Account WHERE Id =:accRec.Id];
		System.assertNotEquals(null, acc.Id);
		System.assertEquals(1, acc.Number_of_Full_Time_Employees__c);
		System.assertEquals(accRecordType.get('Consumer'), acc.RecordTypeId);
		Contact con = [SELECT Id, RecordTypeId, Number_of_Full_Time_Employees__c FROM Contact WHERE Id =:testContact.Id];
		System.assertNotEquals(null, con.Id);
		System.assertEquals(1, con.Number_of_Full_Time_Employees__c);
		System.assertEquals(conRecordType.get('Consumer'), con.RecordTypeId);		
		Opportunity opp = [SELECT Id, RecordTypeId, Number_of_Full_Time_Employees__c, StageName, Locations_Interested__c, Owner_Auto_Assign__c FROM Opportunity LIMIT 1];
		System.assertNotEquals(null, opp.Id);
		System.assertEquals('Qualifying', opp.StageName);
		System.assertEquals(1, opp.Number_of_Full_Time_Employees__c);
		System.assertEquals(testContact.Location_Interested__c, opp.Locations_Interested__c);
		System.assertEquals(oppRecordType.get('Consumer'), opp.RecordTypeId);
		System.assertEquals(true, opp.Owner_Auto_Assign__c);    
        
        accRec.Number_of_Full_Time_Employees__c = 101;
        accRec.RecordTypeId = accRecordType.get('Mid Market');
        objectsToSave.put('Account', accRec);
        
        testContact.Number_of_Full_Time_Employees__c = 101;
        testContact.RecordTypeId = conRecordType.get('Mid Market');
        testContact.Location_Interested__c = building1.Name+';'+building2.Name;
        objectsToSave.put('Contact', testContact);        
        Opportunity oppRec2 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec2.Primary_Member__c = testContact.Id;
        oppRec2.StageName = 'Qualifying';
        oppRec2.CurrencyIsoCode = 'USD';
        oppRec2.Journey__c = testJourney.Id;
        oppRec2.CloseDate = system.today().addDays(5);
        oppRec2.Number_of_Full_Time_Employees__c = 101;
        oppRec2.Locations_Interested__c = building1.Name+';'+building2.Name;
        oppRec2.RecordTypeId = oppRecordType.get('Mid Market');
        oppRec2.CurrencyIsoCode = 'USD';
		oppRec2.Owner_Auto_Assign__c = true;
        
        objectsToSave.put('Opportunity', oppRec2);
        Test.startTest();  
        result = WeworkEngine.addOpportunity(objectsToSave.values(), testContact.Id);
        for(SaveResult res : result){
        	System.assertEquals(true, res.IsSuccess);
        }         
        acc = [SELECT Id, RecordTypeId, Number_of_Full_Time_Employees__c FROM Account WHERE Id =:accRec.Id];
		System.assertNotEquals(null, acc.Id);
		System.assertEquals(accRec.Number_of_Full_Time_Employees__c, acc.Number_of_Full_Time_Employees__c);
		System.assertEquals(accRecordType.get('Mid Market'), acc.RecordTypeId);
		
		con = [SELECT Id, RecordTypeId, Number_of_Full_Time_Employees__c, Location_Interested__c FROM Contact WHERE Id =:testContact.Id];
		System.assertNotEquals(null, con.Id);
		System.assertEquals(testContact.Number_of_Full_Time_Employees__c, con.Number_of_Full_Time_Employees__c);		
		System.assertEquals(conRecordType.get('Mid Market'), con.RecordTypeId);
        
        opp = [SELECT Id, RecordTypeId, Number_of_Full_Time_Employees__c, StageName, Locations_Interested__c, Owner_Auto_Assign__c FROM Opportunity WHERE Id !=:opp.Id LIMIT 1];
		System.assertNotEquals(null, opp.Id);
		System.assertEquals('Qualifying', opp.StageName);
		System.assertEquals(oppRec2.Number_of_Full_Time_Employees__c, opp.Number_of_Full_Time_Employees__c);		
		System.assertEquals(oppRecordType.get('Mid Market'), opp.RecordTypeId);
		System.assertEquals(true, opp.Owner_Auto_Assign__c);         
       	Test.stopTest();        
    }
    
    
    /*
    *	Created By   	: Amol Darekar
    *	Created Date 	: 30 Nov 2016
    * 	Issue No.		: ST-749
    */
    static testMethod void testBulkJourneyUpdates() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForLightning());
        String strJourneyIds='';
        Lead l = new Lead(FirstName = 'Test',
                          LastName = 'Lead',
                          Company = 'TestCompany',
                          Status = 'Open',
                          Locations_Interested__c = 'B1; B2;',
                          Office_Type__c = 'Shared Desk; DailyDesk;',
                          Email = 'test@example.com');
        insert l;
        
        Journey__c testLeadJourney = new Journey__c();
        testLeadJourney.Name = 'testJourney 1';
        testLeadJourney.CurrencyIsoCode = 'USD';
        testLeadJourney.Primary_Lead__c = l.Id;
        testLeadJourney.Status__c ='Started';
        testLeadJourney.NMD_Next_Contact_Date__c = Date.today();
        TestingUtility.insertWithAssert(testLeadJourney);
        
        strJourneyIds = testLeadJourney.Id;
        
        //Test Account created for testContact.
        Account testAccount = new Account();
        testAccount.Name = 'Test Account8';
        insert testAccount;
        
        //Test Contact created for testJourney.
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.firstname = 'TestFirstName';
        testContact.lastname = 'TestLastName';
        testContact.Email = 'Test111@example.com';
        testContact.Status__c = 'active';
        insert testContact;
        System.assertNotEquals(testContact.Id, null);
       
        //Test Journey for JourneyDetailController.        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'testJourney 1';
        testJourney.CurrencyIsoCode = 'USD';
        testJourney.Primary_Contact__c = testContact.Id;
        testJourney.Status__c ='Started';
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        TestingUtility.insertWithAssert(testJourney);
        
        strJourneyIds +=','+testJourney.Id;
        
        testJourney = new Journey__c();
        testJourney.Name = 'testJourney 2';
        testJourney.CurrencyIsoCode = 'USD';
        testJourney.Primary_Contact__c = testContact.Id;
        testJourney.Status__c ='Started';
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        TestingUtility.insertWithAssert(testJourney);
        Debug.Log('testBulkJourneyUpdates # of Queries 1.2 : ' + Limits.getQueries());
        strJourneyIds +=','+testJourney.Id; 
        
        Datetime d = DateTime.now();
        Datetime dt = DateUtilities.addBusinessDays(d.date(),10);
        Test.startTest();
         WeworkEngine.bulkJourneyUpdates(strJourneyIds,dt,'Test Comment', d.second(), d.minute(), d.hour());
        Test.stopTest();        
     }
    
    static testMethod void testCallDateDiff() {
        DateTime dt1 = DateTime.newInstance(2016, 12, 13, 0, 0, 0);
        DateTime dt2 = DateTime.newInstance(2016, 12, 14, 0, 0, 0);
        Long diff = WeworkEngine.callDateDiff(dt1, dt2, 0, 0, 0);
        //System.assertEquals(24,diff);
    }
    
    static void testGetContactInfo() {
        Account testAccount = new Account();
        testAccount.Name = 'Test Account9';
        insert testAccount;
        //Test Contact created for testJourney.
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.firstname = 'TestFirstName';
        testContact.lastname = 'TestLastName';
        testContact.Email = 'Test111@example.com';
        testContact.Status__c = 'active';
        insert testContact;
        System.assertNotEquals(testContact.Id, null);
        
        List<Contact> lstContacts = WeworkEngine.GetContactInfo(testContact.Email);
        System.assertNotEquals(lstContacts, null);
        System.assertEquals(1, lstContacts.size());
        System.assertEquals(testContact.Email.toLowerCase(), lstContacts[0].Email.toLowerCase());
    }	
    
    static void testFetchReportId() {	    	
        String result;
        try{
            result = WeworkEngine.FetchReportId();
        } catch(Exception exc){}
        
        System.assertEquals('No Report Found', result);
    }
    
    static void testJourney2Journey(){
        Settings.FieldMappings mapping = WeworkEngine.Journey2Journey();
        System.assertNotEquals(null, mapping);
    }
    
    static testMethod void testSaveWebsiteLead(){
        Lead l = new Lead(FirstName = 'Test Setup',
                          LastName = 'Lead',
                          Company = 'TestCompany',
                          Status = 'Open',
                          Office_Type__c = 'Shared Desk; DailyDesk;',
                          Email = 'testsetup@example.com');
        insert l;
        test.startTest();
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'testSetupJourney';
        testJourney.CurrencyIsoCode = 'USD';
        testJourney.Primary_Lead__c = l.Id;
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        testJourney.Lost_Reason__c = 'Not Interested';
        TestingUtility.insertWithAssert(testJourney);       
        WeWorkEngine.SaveWebsiteLead(new List<Lead>{l});
        WeWorkEngine.reassignGuestUser(new List<Lead>{l});
        WeWorkEngine.reassignGuestUserLead(new List<Lead>{l});
        WeWorkEngine.CallConvertLeadToJourneys(l.Id);
        test.stopTest();
        list<WeWorkEngine.SObjectFieldDescription> leadObjFields = WeWorkEngine.getObjectFields('Lead');
        List<String> picklistValues = WeWorkEngine.getPicklistValues('Lead', 'Status');
        //Journey__c journey = WeWorkEngine.getDefaultJourneyRecord(); 
    }
    
    static testMethod void testGetDefaultJourneyRecord(){
        Lead l = new Lead(FirstName = 'Test Setup',
                          LastName = 'Lead',
                          Company = 'TestCompany',
                          Status = 'Open',
                          Office_Type__c = 'Shared Desk; DailyDesk;',
                          Email = 'testsetup@example.com');
        insert l;
        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'testSetupJourney';
        testJourney.CurrencyIsoCode = 'USD';
        testJourney.Primary_Lead__c = l.Id;
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        testJourney.Lost_Reason__c = 'Not Interested';
        TestingUtility.insertWithAssert(testJourney);
       
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'Campaign Wizard Settings';
        //{ "successmessage": { "message": "Process is going to take some time, you will be notified via email once the process is complete.", "timeout": 10 }, "journeydefaultid": { "fieldAPIs": [ { "fieldLabel": "Building Name", "fieldApiName": "building_interested_in__r.name" }, { "fieldLabel": "Building City", "fieldApiName": "building_interested_in__r.city__c" }, { "fieldLabel": "Country", "fieldApiName": "building_interested_in__r.country__c" }, { "fieldLabel": "Community Manager", "fieldApiName": "building_interested_in__r.community_manager__r.name" } ], "types": [ "Advertisement", "Email", "Multitouch Outbound Campaign", "Newsletter" ] } }
        
        testSettings.Data__c = '{ "successmessage": { "message": "Process is going to take some time, you will be notified via email once the process is complete.", "timeout": 10 }, "journeydefaultid": { "Id": "'+((testJourney.Id != null) ? testJourney.Id : null) +'", "fieldAPIs": [ { "fieldLabel": "Building Name", "fieldApiName": "building_interested_in__r.name" }, { "fieldLabel": "Building City", "fieldApiName": "building_interested_in__r.city__c" }, { "fieldLabel": "Country", "fieldApiName": "building_interested_in__r.country__c" }, { "fieldLabel": "Community Manager", "fieldApiName": "building_interested_in__r.community_manager__r.name" } ], "types": ["Advertisement", "Email", "Multitouch Outbound Campaign" ] } }';
        debug.log('testSetting_Query:'+testSettings.Data__c);
        insert testSettings;
      
        Debug.Log('testSettings :: '+testSettings);
        System.assertNotEquals(null, testSettings.Id);
        
        Journey__c journey = WeworkEngine.getDefaultJourneyRecord();        
    }
    
    static testMethod void combineSmallTests2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForLightning());
        testCallDateDiff();
        testGetContactInfo();
        testFetchReportId();
        testJourney2Journey();
        WeWorkEngine.getAllUpdatableSobjectField('Journey__c');
        WeWorkEngine.getResourceURL('vendor_css');
        WeWorkEngine.getObjectFields('Journey__c');
        WeWorkEngine.getPicklistValues('Lead','LeadSource');
        
    }



    static testMethod void verifyCreateOpportunityForManageTour(){
    	Account acc = new Account(Name='Test Account10');
    	insert acc;
    	System.assert(acc.Id!=null);
    	Contact con = new Contact(FirstName='Test',LastName='Contact',AccountId=acc.Id,Email='test@example.com');
        insert con;
    	System.assert(con.Id!=null);
    	Opportunity opp = WeworkEngine.createOpportunityForManageTours(con.Id);
    	System.assert(opp.Id!=null);
    }
    
    /*
	* Created By   	: Amol Darekar
	* Created Date 	: 06-06-2017
	* Comment		: This method is use to create opportunity when tour is booked from 
	*                 manage tour page,insted of crating opportunity at responce in tour end point]
	*				  we are creating opportunity on lead conversion after contact creation to avoid 
	*				  multiple opportunity creation on tour book.
	* Issue No.		: 
	*/ 
   static testMethod void OppportunityCreationFromManageToursTest(){
    	/*Lead l = new Lead(FirstName = 'Test',
			  LastName = 'Lead',
			  Company = 'TestCompany',
			  Status = 'Open',
			  Locations_Interested__c = 'B1; B2;',
			  Office_Type__c = 'Shared Desk; DailyDesk;',
			  Email = 'testNewLead@example.com');
		insert l;
		system.assertNotEquals(null,l.Id);
		
		Building__c building = new Building__c();
		building.Name = 'building 1'; 
       	insert building;
       	system.assertNotEquals(null, building.Id);
       	
       	//Call method getLeadsToJourneys which convert lead and call opportunity creation
       	//function.
		list<Id> lstTestLeadIds = new list<Id>();
		lstTestLeadIds.add(l.Id);
		WeworkEngine.getLeadsToJourneys(lstTestLeadIds,building.Id);
		list<Opportunity> lstTestOpp = [SELECT Id FROM Opportunity];
		system.assertEquals(1,lstTestOpp.size());*/
		
   }
   
    /*
	* Created By   	: Amol Darekar
	* Created Date 	: 06-06-2017
	* Comment		: This test method is use to test the getMasterAccountUUID() function.
	* Issue No.		: ST-1156
	*/
   static testMethod void getMasterAccountUUIDTest(){
   	  //Insert Account record for testing 
   	  list<Account> lstTestAccounts = new list<Account>();
   	  Account accRec = TestingUtility.createAccount('strAccountName4', false);
	  accRec.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
	  lstTestAccounts.add(accRec);       
	    
	  Account accRec2 = new Account();
	  accRec2.Name = 'strAccountName5';
	  accRec2.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
	  lstTestAccounts.add(accRec2);
	    
	  Account accRec3 = new Account();
	  accRec3.Name = 'strAccountName6';
	  lstTestAccounts.add(accRec3);
	  insert lstTestAccounts;
	  
	  lstTestAccounts = [SELECT Id, UUID__c FROM Account];
	  
	  //Call to database merge function.
	  Database.merge(lstTestAccounts[0],(String)lstTestAccounts[1].Id);
	  
	  //Call to getMasterAccountUUID() methodto get master account UUID
	  String masterAccountUUID = WeworkEngine.getMasterAccountUUID(lstTestAccounts[1].UUID__c);
	  
	  //Check whether function retun the Master account UUID or not
	  system.assertEquals(lstTestAccounts[0].UUID__c,masterAccountUUID);
       debug.log('lstTestAccounts[0].UUID__c:::'+lstTestAccounts[0].UUID__c);
       debug.log('masterAccountUUID:::'+masterAccountUUID);
   }
    static testMethod void verifyConvertLeadsToNew(){
        Building__c building = new Building__c(City__c = 'Amsterdam', Country__c = 'Netherlands',Name = 'AMS-Metropool', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam');
        insert building;
        
        Lead l1 = new Lead(FirstName = 'Test',
                          LastName = 'Lead',
                          Company = 'TestCompany',
                          LeadSource = 'WeWork.com',
                          Status = 'Open',
                          Locations_Interested__c = 'B1; B2;',
                          Office_Type__c = 'Shared Desk; DailyDesk;',
                          Email = 'testNewLead1@example.com');
        insert l1;
        Test.startTest();
         WeworkEngine.convertLeadsToExisting(new Map<String,Object>{'leadId'=>l1.Id,'buildingId'=>building.Id,'bookedBySalesLead'=>true});
        Test.stopTest();
        Contact con = [Select Id,Email,AccountId From Contact Where Email = 'testNewLead1@example.com'];
        List<Opportunity> lstOpportunities = [Select Id From Opportunity Where Primary_Member__c=:con.Id];
        System.assert(con!=null);
        System.assert(con.AccountId!=null);
        System.assertEquals(1,lstOpportunities.size());
        List<Opportunity_Role__c> lstOpportunityRoles = [Select Id, Contact__c, Opportunity__c, Role__c From Opportunity_Role__c];
        System.assertEquals(1, lstOpportunityRoles.size());
    }
    static testMethod void verifyConvertLeadsToExisting(){
        Building__c building = new Building__c(City__c = 'Amsterdam', Country__c = 'Netherlands',Name = 'AMS-Metropool', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam');
        insert building;
        Account a1 = new Account(Name='Test Account1');
        insert a1;
        System.assert(a1.Id!=null);
        Lead l2 = new Lead(FirstName = 'Test',
                          LastName = 'Lead',
                          Company = 'TestCompany',
                          Status = 'Open',
                          Locations_Interested__c = 'B1; B2;',
                          Office_Type__c = 'Shared Desk; DailyDesk;',
                          Email = 'testNewLead2@example.com');
        insert l2;
        System.assert(l2.Id!=null);
        Test.startTest();
        WeworkEngine.convertLeadsToExisting(new Map<String,Object>{'leadId'=>l2.Id,'accountId'=>a1.Id,'buildingId'=>building.Id,'bookedBySalesLead'=>true});
        Test.stopTest();
        Lead lead = [Select Id,Name,IsConverted,ConvertedAccountId From Lead Where Id=:l2.Id];
        System.assert(lead.IsConverted);
        System.assert(lead.ConvertedAccountId==a1.Id);
    }
    /************************************************************************************************************************************
    Author 				: Jitesh Adwani
    Description 		: This method tests isValidOppforTransferPaperwork.
    Created Date		: 07 June 2018 
	-------------------------------------------------------------------------------------------------------------------------------------
	Last Modified By	: Milanjeet Singh
	Description`		: test scenarios according to the changes done in wework engine
	Issue No.			: ST-2547
    **************************************************************************************************************************************/
    static testMethod void verifyIsValidOppforTransferPaperwork(){
        Account accRec1 = TestingUtility.createAccount('Tranfer PW 1', false);
        accRec1.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        accRec1.Account_Type__c = 'Org';
        
        Account accRec2 = TestingUtility.createAccount('Tranfer PW 2', false);
        accRec2.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        accRec2.Account_Type__c = 'Org';
        
        List<Account> lstOrgAccount = new List<Account>();
        lstOrgAccount.add(accRec1);
        lstOrgAccount.add(accRec2);
        
        TestingUtility.insertListWithAssert(lstOrgAccount);
        
        Contact conRec = new Contact(firstname = 'John',lastname = 'Rambo',email = 'test_0007_01@example.com', accountID = accRec1.Id, Status__c = 'active');
        TestingUtility.insertWithAssert(conRec);
        
        List<Billing_Account__c> lstBillingAccount = new List<Billing_Account__c>();
        lstBillingAccount.add(new Billing_Account__c(Name='Transfer PW B1',Parent_Account__c=lstOrgAccount[0].Id));
        lstBillingAccount.add(new Billing_Account__c(Name='Transfer PW B2',Parent_Account__c=lstOrgAccount[1].Id));
        
        TestingUtility.insertListWithAssert(lstBillingAccount);
        
        //Updating billing account uuid as blank for uuid error on Transfer PW
        Update new Billing_Account__c(Id=lstBillingAccount[0].Id,UUID__c='');
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        //Creating Opportunity with Stage other than TransferPaperwork Setting
        Opportunity oppRec1 = TestingUtility.createOpportunity(lstOrgAccount[0].Id, false);
        oppRec1.Primary_Member__c = conRec.Id;
        oppRec1.StageName = 'Close Lost';
        oppRec1.Lost_Reason__c = 'Not Interested';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.Membership_Agreement_Notes__c = 'Opprtunity 1 Membership_Agreement_Notes__c';
        oppRec1.Tour_Notes__c = 'Opprtunity 1 Tour_Notes__c';
        oppRec1.Tour_Outcome_Notes__c = 'Opprtunity 1 Tour_Notes__c';
        oppRec1.Description = 'Opprtunity 1 Tour_Notes__c'; 
        oppRec1.Contract_Stage__c = 'Contract Sent';
        oppRec1.Owner_Auto_Assign__c = true; 
        lstOpportunity.add(oppRec1);

        Account accRec3 = new Account();
        accRec3.Name = 'StrAccountName';
        accRec3.Account_Type__c = 'Bill';
        insert accRec3;
        
        //Creating Opportunity with Stage from TransferPaperwork and Contract Stage is not from Setting
        Opportunity oppRec2 = TestingUtility.createOpportunity(lstOrgAccount[0].Id, false);
        oppRec2.Primary_Member__c = conRec.Id;
        oppRec2.StageName = 'Selling';
        oppRec2.CloseDate = system.today().addDays(5);
        oppRec2.Membership_Agreement_Notes__c = 'Opprtunity 2 Membership_Agreement_Notes__c';
        oppRec2.Tour_Notes__c = 'Opprtunity 2 Tour_Notes__c';
        oppRec2.Tour_Outcome_Notes__c = 'Opprtunity 2 Tour_Notes__c';
        oppRec2.Description = 'Opprtunity 2 Tour_Notes__c'; 
        oppRec2.Owner_Auto_Assign__c = true; 
        oppRec2.Contract_Stage__c = 'Contract Signed';
        lstOpportunity.add(oppRec2);
      
        Account accRec4 = new Account();
        accRec4.Name = 'StrAccountName';
        accRec4.Account_Type__c = 'Bill';
        insert accRec4;
        
        //Creating Opportunity Stage and Contract Stage from Setting having billing account with No UUID
        Opportunity oppRec3 = TestingUtility.createOpportunity(lstOrgAccount[1].Id, false);
        oppRec3.Primary_Member__c = conRec.Id;
        oppRec3.StageName = 'Selling';
        oppRec3.CloseDate = system.today().addDays(5);
        oppRec3.Membership_Agreement_Notes__c = 'Opprtunity 3 Membership_Agreement_Notes__c';
        oppRec3.Tour_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRec3.Tour_Outcome_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRec3.Description = 'Opprtunity 3 Tour_Notes__c'; 
        oppRec3.Owner_Auto_Assign__c = true; 
        oppRec3.Contract_Stage__c = 'Contract Sent';
        oppRec3.Billing_Account__c = lstBillingAccount[0].Id;
        lstOpportunity.add(oppRec3);
        
        //Creating Opportunity Stage and Contract Stage from Setting having billing account having UUID
        Opportunity oppRec4 = TestingUtility.createOpportunity(lstOrgAccount[1].Id, false);
        oppRec4.Primary_Member__c = conRec.Id;
        oppRec4.StageName = 'Selling';
        oppRec4.CloseDate = system.today().addDays(5);
        oppRec4.Membership_Agreement_Notes__c = 'Opprtunity 4 Membership_Agreement_Notes__c';
        oppRec4.Tour_Notes__c = 'Opprtunity 4 Tour_Notes__c';
        oppRec4.Tour_Outcome_Notes__c = 'Opprtunity 4 Tour_Notes__c';
        oppRec4.Description = 'Opprtunity 4 Tour_Notes__c'; 
        oppRec4.Owner_Auto_Assign__c = true; 
        oppRec4.Billing_Account__c = lstBillingAccount[1].Id;
        oppRec4.Contract_Stage__c = 'Contract Sent';
        lstOpportunity.add(oppRec4);
        
        //Creating Opportunity Stage and Contract Stage from Setting having no billing account
        Opportunity oppRec5 = TestingUtility.createOpportunity(lstOrgAccount[1].Id, false);
        oppRec5.Primary_Member__c = conRec.Id;
        oppRec5.StageName = 'Selling';
        oppRec5.CloseDate = system.today().addDays(5);
        oppRec5.Membership_Agreement_Notes__c = 'Opprtunity 4 Membership_Agreement_Notes__c';
        oppRec5.Tour_Notes__c = 'Opprtunity 4 Tour_Notes__c';
        oppRec5.Tour_Outcome_Notes__c = 'Opprtunity 4 Tour_Notes__c';
        oppRec5.Description = 'Opprtunity 4 Tour_Notes__c'; 
        oppRec5.Owner_Auto_Assign__c = true; 
        oppRec5.Billing_Account__c = lstBillingAccount[1].Id;
        oppRec5.Contract_Stage__c = 'Contract Sent';
        lstOpportunity.add(oppRec5);
     	
        TestingUtility.insertListWithAssert(lstOpportunity);
        
        //Defining the error for asserts
        String oppStageError = 'You are not allowed to transfer this paperwork. Please check the Opportunity Stage.';
        String oppContractStageError = 'You are not allowed to transfer this paperwork. Please check the Contract Stage.';
        String oppBillingAccountUUIDError = 'You are not allowed to transfer this paperwork as uuid is not present on Opportunity\'s Billing Account.';
        WeworkEngine.ValidResultWithOpp result;
        String strResult;
        
        //Assertions for Opportunity whose Stage is not from the Setting
       	strResult = WeworkEngine.isValidOppforTransferPaperwork(lstOpportunity[0].Id);
        result = (WeworkEngine.ValidResultWithOpp)JSON.deserialize(strResult,WeworkEngine.ValidResultWithOpp.class);
        System.assertEquals(result.isValid, false, 'Opportunity should not be valid');
        System.assertEquals(result.errorMsg ,oppStageError ,'errorMsg for Opportunity Stage is not matched');
        
        //Assertions for Opportunity whose Contact Stage is not from the Setting
        strResult = WeworkEngine.isValidOppforTransferPaperwork(lstOpportunity[1].Id);
        result = (WeworkEngine.ValidResultWithOpp)JSON.deserialize(strResult,WeworkEngine.ValidResultWithOpp.class);
        System.assertEquals(result.isValid, false, 'Opportunity should not be valid');
        System.assertEquals(result.errorMsg ,oppContractStageError ,'errorMsg for Contract Stage is not matched');
        
        //Assertions for Opportunity having billing account with no uuid
        strResult = WeworkEngine.isValidOppforTransferPaperwork(lstOpportunity[2].Id);
        result = (WeworkEngine.ValidResultWithOpp)JSON.deserialize(strResult,WeworkEngine.ValidResultWithOpp.class);
        System.assertEquals(result.isValid, false, 'Opportunity should not be valid');
        System.assertEquals(result.errorMsg ,oppBillingAccountUUIDError ,'errorMsg for UUID Stage is not matched');
        
        //Assertions for Opportunity having billing account with uuid
        strResult = WeworkEngine.isValidOppforTransferPaperwork(lstOpportunity[3].Id);
        result = (WeworkEngine.ValidResultWithOpp)JSON.deserialize(strResult,WeworkEngine.ValidResultWithOpp.class);
        System.assertEquals(result.isValid, true, 'Opportunity should valid');
        
        //Assertions for Opportunity not having billing account
        strResult = WeworkEngine.isValidOppforTransferPaperwork(lstOpportunity[4].Id);
        result = (WeworkEngine.ValidResultWithOpp)JSON.deserialize(strResult,WeworkEngine.ValidResultWithOpp.class);
        System.assertEquals(result.isValid, true, 'Opportunity should be valid');
        
    }
    
     /************************************************************************************************************************************
    Author 				: Priyanka Ambre
    Description 		: This method tests isValidOppforTransferPaperwork.
    Created Date		: 07 June 2018 
 	Issue No.			: ST-2327
    **************************************************************************************************************************************/
    
    static testMethod void verifyIsValidOppforSendPaperwork(){ 
        Profile systemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];
        Debug.log('weworkSystemAdmin ::'+weworkSystemAdmin);
        Map<String,Object> userRecordMap1 = new Map<String,Object>();
        userRecordMap1.put('LastName','Last Name');
        userRecordMap1.put('Username','testweworkuserforSendPaperwork@example.com');
        userRecordMap1.put('Email','testweworkuserforSendPaperwork@example.com');
        userRecordMap1.put('IsActive',true);
        User testUser1 = TestingUtility.insertUserWithAssert(systemAdmin.Id, userRecordMap1, true);
        Debug.log('testUser ::'+testUser1);  
        
        Map<String,Object> userRecordMap2 = new Map<String,Object>();
        userRecordMap2.put('LastName','Last Name1');
        userRecordMap2.put('Username','testweworkuserforSendPaperwork3@example.com');
        userRecordMap2.put('Email','testweworkuserforSendPaperwork3@example.com');
        userRecordMap2.put('IsActive',true);
        User testUser2 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap2, true);
        Debug.log('testUser2 ::'+testUser2);  
        
        Account testAccount1 = TestingUtility.createAccount('Test-Account1',false);
        testAccount1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId(); 
        testAccount1.Unomy_Location_Country__c = 'Australia';
        
        Account testAccount2 = TestingUtility.createAccount('Test-Account2',false);
        testAccount2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId(); 
            
        Account testAccount3 = TestingUtility.createAccount('Test-Account3',false);
        testAccount3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId(); 
            
		    List<Account> lstAccount = new List<Account>();
        lstAccount.add(testAccount1);
        lstAccount.add(testAccount2);
        lstAccount.add(testAccount3);
        insert lstAccount;
        Account accRec = TestingUtility.createAccount('strAccountName7', false);
        accRec.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        TestingUtility.insertWithAssert(accRec);
        
        Contact conRec = new Contact(firstname = 'John',lastname = 'Rambo',email = 'test_0007_01@example.com', accountID = accRec.Id, Status__c = 'active');
        TestingUtility.insertWithAssert(conRec);
        
        List<Building__c> lstBuilding = new List<Building__c>();
        lstBuilding.add(new Building__c(City__c = 'Amsterdam', Country__c = 'Netherlands',Name = 'AMS-Metropool', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam', uuid__c = 'abc123'));
        lstBuilding.add(new Building__c(City__c = 'Brooklyn',Country__c = 'USA',State__c='TS', Name = 'BKN-Brooklyn Heights',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/New_York',uuid__c = 'abc1234'));
        TestingUtility.insertListWithAssert(lstBuilding);
        
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        Debug.log('oppRecordType :: '+oppRecordType);
        
		    List<Opportunity> lstOpportunities = new List<Opportunity>();
        Opportunity oppRecCons = TestingUtility.createOpportunity(lstAccount[0].Id, false);
        oppRecCons.Primary_Member__c = conRec.Id;
        oppRecCons.StageName = 'Selling';
        oppRecCons.CloseDate = system.today().addDays(5);
        oppRecCons.Membership_Agreement_Notes__c = 'Opprtunity 3 Membership_Agreement_Notes__c';
        oppRecCons.Tour_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecCons.Tour_Outcome_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecCons.Description = 'Opprtunity 3 Tour_Notes__c'; 
        oppRecCons.Owner_Auto_Assign__c = true;  
        
        Opportunity oppRecMM = TestingUtility.createOpportunity(lstAccount[1].Id, false);
        oppRecMM.Primary_Member__c = conRec.Id;
        oppRecMM.StageName = 'Selling';
        oppRecMM.CloseDate = system.today().addDays(5);
        oppRecMM.Membership_Agreement_Notes__c = 'Opprtunity 3 Membership_Agreement_Notes__c';
        oppRecMM.Tour_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecMM.Tour_Outcome_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecMM.Description = 'Opprtunity 3 Tour_Notes__c'; 
        oppRecMM.Owner_Auto_Assign__c = true;  
        
        Opportunity oppRecEnt = TestingUtility.createOpportunity(lstAccount[2].Id, false);
        oppRecEnt.Primary_Member__c = conRec.Id;
        oppRecEnt.StageName = 'Selling';
        oppRecEnt.CloseDate = system.today().addDays(5);
        oppRecEnt.Membership_Agreement_Notes__c = 'Opprtunity 3 Membership_Agreement_Notes__c';
        oppRecEnt.Tour_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecEnt.Tour_Outcome_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecEnt.Description = 'Opprtunity 3 Tour_Notes__c'; 
        oppRecEnt.Owner_Auto_Assign__c = true;  
        
        lstOpportunities.add(oppRecCons);
        lstOpportunities.add(oppRecMM);
        lstOpportunities.add(oppRecEnt);
        
       TestingUtility.insertListWithAssert(lstOpportunities);
        
        Test.startTest();
        //Enterprise Solutions Opportunity oppRec.Type__c = 'Mixed'
        oppRecEnt.Type__c = 'Mixed';
        update oppRecEnt;
        String resultForProduct = WeworkEngine.isValidOppforSendPaperwork(oppRecEnt.id);
        Map<String, Object> mapResultForProduct = (Map<String, Object>)JSON.deserializeUntyped(resultForProduct);  
        Debug.log('mapResultForProduct---'+mapResultForProduct);
        System.assertEquals(null, mapResultForProduct.get('opportunityBuildings'));
        System.assertEquals(false, mapResultForProduct.get('isValid'));
        System.assertEquals(false, mapResultForProduct.get('isValidOwner'));
        
        oppRecEnt.Type__c = 'Global Access';
        oppRecEnt.StageName = 'Closing';
        oppRecEnt.Contract_Stage__c = 'Contract Sent';
        update oppRecEnt;
        //Enterprise Solutions Opportunity oppRec.StageName = 'Closing' and oppRec.StageName = 'Closing'
        String resultForContractSent = WeworkEngine.isValidOppforSendPaperwork(oppRecEnt.id);
        Map<String, Object> mapResultForContractSent = (Map<String, Object>)JSON.deserializeUntyped(resultForContractSent);  
        Debug.log('mapResultForContractSent---'+mapResultForContractSent);
        System.assertEquals(null, mapResultForContractSent.get('opportunityBuildings'));
        System.assertEquals(false, mapResultForContractSent.get('isValid'));
        System.assertEquals(false, mapResultForContractSent.get('isValidOwner')); 
        
        //MidMarket Opportunity  for closing 
        oppRecMM.Contract_Stage__c = 'Contract Discarded';
        oppRecMM.StageName = 'Selling';
        update oppRecMM;
        System.runAs(testUser1) {
            String resultMMForClosing = WeworkEngine.isValidOppforSendPaperwork(oppRecMM.id);
            Map<String, Object> mapResultMMForClosing = (Map<String, Object>)JSON.deserializeUntyped(resultMMForClosing);  
            Debug.log('mapResultMMForClosing---'+mapResultMMForClosing);
            System.assertEquals(null, mapResultMMForClosing.get('opportunityBuildings'));
            System.assertEquals(false, mapResultMMForClosing.get('isValid'));
            System.assertEquals(false, mapResultMMForClosing.get('isValidOwner')); 
        } 
        
         //MidMarket Opportunity for closing and bypass Profiles
        System.runAs(testUser2) {
            String resultMMForOwner = WeworkEngine.isValidOppforSendPaperwork(oppRecMM.id);
            Map<String, Object> mapResultMMForOwner = (Map<String, Object>)JSON.deserializeUntyped(resultMMForOwner);  
            Debug.log('mapResultMMForOwner---'+mapResultMMForOwner);
            System.assertEquals(null, mapResultMMForOwner.get('opportunityBuildings'));
            System.assertEquals(true, mapResultMMForOwner.get('isValid'));
            System.assertEquals(true, mapResultMMForOwner.get('isValidOwner')); 
        }
        
        //Enterprise Solutions Opportunity  for closing  
        oppRecEnt.StageName = 'Closing';
        oppRecEnt.Contract_Stage__c = 'Contract Discarded';
        update oppRecEnt;
        System.runAs(testUser1) {
            String resultEntForClosing = WeworkEngine.isValidOppforSendPaperwork(oppRecEnt.id);
            Map<String, Object> mapResultEntForClosing = (Map<String, Object>)JSON.deserializeUntyped(resultEntForClosing);  
            Debug.log('mapResultEntForClosing---'+mapResultEntForClosing);
            System.assertEquals(null, mapResultEntForClosing.get('opportunityBuildings'));
            System.assertEquals(false, mapResultEntForClosing.get('isValid'));
            System.assertEquals(false, mapResultEntForClosing.get('isValidOwner')); 
        }
        oppRecEnt.StageName = 'Closing';
        oppRecEnt.Locations_Interested__c = lstBuilding[0].Name;
        oppRecEnt.Building__c = lstBuilding[1].Id;
        oppRecEnt.OwnerId = testUser1.Id;
        update oppRecEnt;
        //Enterprise Solutions Opportunity   with same owner as  logged in User
        System.runAs(testUser1) {
            String resultEntForOwnerSame = WeworkEngine.isValidOppforSendPaperwork(oppRecEnt.id);
            Map<String, Object> mapResultEntForOwnerSame = (Map<String, Object>)JSON.deserializeUntyped(resultEntForOwnerSame);  
            Debug.log('mapResultEntForOwnerSame---'+mapResultEntForOwnerSame);
            System.assertNotEquals(null, mapResultEntForOwnerSame.get('opportunityBuildings'));
            System.assertEquals(true, mapResultEntForOwnerSame.get('isValid'));
            System.assertEquals(true, mapResultEntForOwnerSame.get('isValidOwner')); 
        }
        
        //Enterprise Solutions Opportunity   Bypass profile
        System.runAs(testUser2) {
            String resultEntForAllowedOwner = WeworkEngine.isValidOppforSendPaperwork(oppRecEnt.id);
            Map<String, Object> mapResultEntForAllowedOwner = (Map<String, Object>)JSON.deserializeUntyped(resultEntForAllowedOwner);  
            Debug.log('mapResultEntForAllowedOwner---'+mapResultEntForAllowedOwner);
            System.assertNotEquals(null, mapResultEntForAllowedOwner.get('opportunityBuildings'));
            System.assertEquals(true, mapResultEntForAllowedOwner.get('isValid'));
            System.assertEquals(true, mapResultEntForAllowedOwner.get('isValidOwner')); 
        }
        
        //Consumer Opportunity for Building__c 
        oppRecCons.Building__c = null;
        update oppRecCons;
        System.runAs(testUser1) {
            String resultConsumerForBuilding = WeworkEngine.isValidOppforSendPaperwork(oppRecCons.id);
            Map<String, Object> mapResultConsumerForBuilding = (Map<String, Object>)JSON.deserializeUntyped(resultConsumerForBuilding);  
            Debug.log('mapResultConsumerForBuilding---'+mapResultConsumerForBuilding);
            System.assertEquals(null, mapResultConsumerForBuilding.get('opportunityBuildings'));
            System.assertEquals(false, mapResultConsumerForBuilding.get('isValid'));
            System.assertEquals(false, mapResultConsumerForBuilding.get('isValidOwner')); 
        }
        
        //Consumer everything is good.
        oppRecCons.Building__c = lstBuilding[1].Id;
        update oppRecCons;
        System.runAs(testUser1) {
            String result = WeworkEngine.isValidOppforSendPaperwork(oppRecCons.id);
            Map<String, Object> mapResult  = (Map<String, Object>)JSON.deserializeUntyped(result);  
            Debug.log('mapResult---'+mapResult);
            System.assertEquals(null, mapResult.get('opportunityBuildings'));
            System.assertEquals(true, mapResult.get('isValid'));
            System.assertEquals(true, mapResult.get('isValidOwner'));
        }
        Test.stopTest();
    }
}