/************************************************************************************************************************************
    Author      :   Anant Kumar
    Description :   This class will contain test methods of opportunity trigger.

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           23 February 2016    Anant Kumar             Initial Developement
    2           13 June 2016        Amol Darekar            
**************************************************************************************************************************************/
@isTest
private class OpportunityTriggerHandlerTest {
    
    @testSetup 
    static void setup() {
        SalesConsoleSettings.createSettings();
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Map<String, Object> userRecordMap1 = new Map<String, Object>();
        userRecordMap1.put('LastName', 'Last Name 1');
        userRecordMap1.put('Username', 'testweworkuser1@example.com');
        userRecordMap1.put('Email', 'testweworkuser1@example.com');
        userRecordMap1.put('CommunitynickName', 'test111'+system.now());
        TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap1, true);
        
        Map<String,Object> userRecordMap2 = new Map<String,Object>();
        userRecordMap2.put('LastName', 'CmUser');
        userRecordMap2.put('Username', 'responsibleCmUserXXXXX@example.com');
        userRecordMap2.put('Email', 'responsibleCmUserXXXXX@example.com');
        userRecordMap2.put('CommunitynickName', 'test274' + System.now());
        User responsibleCMUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap2, true);
        
        Map<String,Object> userRecordMap3 = new Map<String,Object>();
        userRecordMap3.put('LastName', 'API User');
        userRecordMap3.put('Username', 'testapiuser-1XXX@example.com');
        userRecordMap3.put('Email', 'testapiuser-1XXX@example.com');
        userRecordMap3.put('CommunitynickName', 'test333' + System.now());
        TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap3, true);
        
        Map<String,Object> userRecordMap5 = new Map<String,Object>();
        userRecordMap5.put('LastName', 'Test User 5');
        userRecordMap5.put('Username', 'testweworkuser5@example.com');
        userRecordMap5.put('Email', 'testweworkuser5@example.com');
        userRecordMap5.put('CommunitynickName', 'test569' + System.now());
        User testUser5 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap5, true);
        
        Map<String,Object> userRecordMap6 = new Map<String,Object>();
        userRecordMap6.put('LastName', 'Test User 6');
        userRecordMap6.put('Username', 'testweworkuser6@example.com');
        userRecordMap6.put('Email', 'testweworkuser6@example.com');
        userRecordMap6.put('CommunitynickName', 'testxxxxxxxx'+system.now());
        User testUser6 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap6, true);
        
        Map<String,Object> userRecordMap7 = new Map<String,Object>();
        userRecordMap7.put('LastName', 'Test User 7');
        userRecordMap7.put('Username', 'testweworkuser7@example.com');
        userRecordMap7.put('Email', 'testweworkuser7@example.com');
        userRecordMap7.put('CommunitynickName', 'test705'+system.now());
        User testUser7 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap7, true); 
        
        Map<String, Object> userRecordMap8 = new Map<String, Object>();
        userRecordMap8.put('LastName', 'Test User 8');
        userRecordMap8.put('Username', 'testweworkuser8@example.com');
        userRecordMap8.put('Email', 'testweworkuser8@example.com');
        userRecordMap8.put('CommunitynickName', 'test805'+system.now());
        userRecordMap8.put('Sales_Role__c', 'Director of sales');
        userRecordMap8.put('Sales_Pod__c', 'USA_003');
        User testUser8 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap8, true); 
        
        List<user> lstUser = new List<User>();
        User testUser1 = new User(Alias = 'testU1', Email = 'testUser1@example.com', 
                      EmailEncodingKey = 'UTF-8', LastName = 'User1', LanguageLocaleKey = 'en_US', 
                      LocaleSidKey = 'en_US', ProfileId = weworkSystemAdmin.Id, IsActive = true,
                      TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testUserName13@example.com', CommunityNickName = 'Test1' + System.now());
        lstUser.add(testUser1);
        User testUser2 = new User(Alias = 'testU2', Email = 'testUser2@example.com', 
                      EmailEncodingKey = 'UTF-8', LastName='User2', LanguageLocaleKey = 'en_US', 
                      LocaleSidKey = 'en_US', ProfileId = weworkSystemAdmin.Id, IsActive = true,
                      TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testUserName23@example.com', CommunityNickName = 'Test2' + System.now());
        lstUser.add(testUser2);
        User testUser3 = new User(Alias = 'testU3', Email = 'testUser43@example.com', 
                      EmailEncodingKey = 'UTF-8', LastName = 'User3', LanguageLocaleKey = 'en_US', 
                      LocaleSidKey = 'en_US', ProfileId = weworkSystemAdmin.Id, IsActive = true,
                      TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testUserName43@example.com', CommunityNickName = 'Test3' + System.now());
        lstUser.add(testUser3);
        TestingUtility.insertListWithAssert(lstUser);
        
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'TaskRayProject';
        testSettings.Data__c = '{"OpportunityTeamMemberSet":[{"setUserId":["' + testUser1.Id + '","' + testUser3.Id + '"],"AssignedTo":"' + testUser2.Id + '"}]}';
        TestingUtility.insertWithAssert(testSettings);
        
        List<Market__c> lstMarkets = new List<Market__c>(); 
        lstMarkets.add(new Market__c(Name='Austin',CurrencyIsoCode='USD'));
        lstMarkets.add(new Market__c(Name='London',CurrencyIsoCode='USD'));
        insert lstMarkets;
        //Account Queues
        List<Account_Queue__c> lstAccountQueues = new List<Account_Queue__c>();
        Account_Queue__c testAccountQueue1 = new Account_Queue__c();
        testAccountQueue1.Member__c = testUser5.Id;
        testAccountQueue1.Account_Record_Type__c = 'Mid Market';
        testAccountQueue1.Last_Account_Assigned__c = Date.today();
        testAccountQueue1.Market__c = 'Austin';
        testAccountQueue1.Portfolio__c = lstMarkets[0].Id;        
        testAccountQueue1.Is_Queue_Active__c = true;
        lstAccountQueues.add(testAccountQueue1);
        
        Account_Queue__c testAccountQueue2 = new Account_Queue__c();
        testAccountQueue2.Member__c = testUser6.Id;
        testAccountQueue2.Account_Record_Type__c = 'Consumer';
        testAccountQueue2.Last_Account_Assigned__c = Date.today()-1;
        testAccountQueue2.Market__c = 'London';
        testAccountQueue2.Portfolio__c = lstMarkets[1].Id;       
        testAccountQueue2.Is_Queue_Active__c = true;
        lstAccountQueues.add(testAccountQueue2);        
        
        Account_Queue__c testAccountQueue3 = new Account_Queue__c();
        testAccountQueue3.Member__c = testUser7.Id;
        testAccountQueue3.Account_Record_Type__c = 'Consumer';
        testAccountQueue3.Last_Account_Assigned__c = Date.today()+1;
        testAccountQueue3.Market__c = 'London';       
        testAccountQueue3.Portfolio__c = lstMarkets[1].Id; 
        testAccountQueue3.Is_Queue_Active__c = true;
        lstAccountQueues.add(testAccountQueue3);
        
        insert lstAccountQueues;
        
        //Refrence fields - RecordTypeId,Market__c,Primary_Member__c
        String recTypeComsumerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        String recTypeMidMarketId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        String recTypeEnterpriseId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        
        Account testAccount1 = TestingUtility.createAccount('Test-Account1', false);
        testAccount1.RecordTypeId = recTypeComsumerId ;
        testAccount1.Unomy_Location_Country__c = 'Australia';
        
        Account testAccount2 = TestingUtility.createAccount('Test-Account2', false);
        testAccount2.RecordTypeId = recTypeMidMarketId ;
        
        Account testAccount3 = TestingUtility.createAccount('Test-Account3', false);
        testAccount3.RecordTypeId = recTypeEnterpriseId ;
        
        Account testAccount4 = TestingUtility.createAccount('Test-Account4', false);
        testAccount4.RecordTypeId = recTypeComsumerId ;
        
        Account testAccount5 = TestingUtility.createAccount('Test-Account5', false);
        testAccount5.RecordTypeId = recTypeComsumerId ;
        testAccount5.Unomy_Location_Country__c = 'Australia';
        
        Account testAccount6 = TestingUtility.createAccount('Test-Account6', false);
        testAccount6.RecordTypeId = recTypeComsumerId ;
        
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(testAccount1);
        lstAccount.add(testAccount2);
        lstAccount.add(testAccount3);
        lstAccount.add(testAccount4);
        lstAccount.add(testAccount5);
        lstAccount.add(testAccount6); 
        
        TestingUtility.insertListWithAssert(lstAccount);
    } 
    
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This method contain unit test for general opportunity creation scenarios.
        Created Date        :   23 February 2016
        Last Modified Date  :   13 June 2016
        Last Modified By    :   Amol Darekar
    **************************************************************************************************************************************/
    static testMethod void testOpportunityCommonCreationScenarios(){
        Test.startTest();
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        
        Contact conRec = new Contact(
            firstname = 'John',
            lastname = 'Rambo',
            email = 'test@example.com',
            accountID = accRec.Id,
            Status__c = 'active'
        );
        insert conRec;
        
        accRec.Primary_Member__c = conRec.Id;
        update accRec;
        
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        
        Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec.Primary_Member__c = conRec.Id;
        oppRec.StageName = 'Selling';
        oppRec.CloseDate = system.today().addDays(5);
        oppRec.Amount = 150;
        oppRec.RecordTypeId = oppRecordType.get('Consumer');
        TestingUtility.insertWithAssert(oppRec);
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec1.Primary_Member__c = conRec.Id;
        oppRec1.StageName = 'Closing';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        TestingUtility.insertWithAssert(oppRec1);
        Test.stopTest();
        
        Building__c building1 = new Building__c(Name='building1', uuid__c = 'abc123');
        TestingUtility.insertWithAssert(building1);
        Reservable__c reservable = new Reservable__c(Name='reservable', Building__c=building1.Id);
        TestingUtility.insertWithAssert(reservable);
        Opportunity_Reservable__c oppReservable = new Opportunity_Reservable__c(Reservable__c = reservable.Id, Opportunity__c = oppRec1.Id);
        TestingUtility.insertWithAssert(oppReservable);
        
        oppRec1.Opportunity_Reservable__c = oppReservable.Id ;
        oppRec1.Building__c = building1.Id;
        oppRec1.Primary_Member__c = conRec.Id;
        oppRec1.Encoded_ID__c = '123';
        oppRec1.Actual_Start_Date__c = system.today().addDays(5);
        oppRec1.StageName = 'Closed Won';
        oppRec1.Amount = 10;
        TestingUtility.updateWithAssert(oppRec1);
        
        Opportunity oppRec3 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec3.Primary_Member__c = conRec.Id;
        oppRec3.StageName = 'Selling';
        oppRec3.LeadSource = 'WeLive.com';
        oppRec3.CloseDate = system.today().addDays(5);
        oppRec3.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        TestingUtility.insertWithAssert(oppRec3);
        
        oppRec3 = [SELECT Id, Encoded_Id__c FROM Opportunity WHERE Id =: oppRec3.Id];
        system.assertEquals(EncodingHandler.encode(oppRec3.Id), oppRec3.Encoded_Id__c, 'The Opportunity was not correctly encoded.');
    }
    
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This method contain unit test for update opportunity name.
        Created Date        :   23 February 2016
        Last Modified Date  :   13 June 2016
        Last Modified By    :   Amol Darekar 
        Modified By         :   Priyanka Ambre on 25-April-2018 for ST-2290
    **************************************************************************************************************************************/
    testmethod static void testUpdateOppName(){ 
        Map<Integer, String> monthinMMMMap = new Map<Integer, String>{1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun', 7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'};
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        //Contact conRec = TestingUtility.createContact(accRec.Id, 'strLastName', true);        
        Contact referrer1 = new Contact(
            firstname = 'John',
            lastname = 'Rambo',
            email = 'referrer1@example.com',
            accountID = accRec.Id,
            Status__c = 'active'
        );
        insert referrer1;        
        Referral__c referral1 = new Referral__c();
        referral1.Referral_Email__c = 'primarycontact@example.com';
        referral1.IsActive__c = true;
        referral1.Referrer__c = referrer1.Id;
        referral1.Expires_On__c = Date.today().addDays(10);
        TestingUtility.insertWithAssert(referral1);        
        Contact conRec = new Contact(
            firstname = 'John',
            lastname = 'Rambo',
            email = 'primarycontact@example.com',
            accountID = accRec.Id,
            Status__c = 'active'
        );
        insert conRec;        
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        
        Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec.Primary_Member__c = conRec.Id;
        oppRec.AccountId = accRec.Id;
        oppRec.Actual_Start_Date__c = system.today();
        oppRec.StageName = 'Selling';
        oppRec.CloseDate = system.today().addDays(5);
        oppRec.RecordTypeId = oppRecordType.get('Consumer');
        oppRec.Type__c = 'Office Space';
        oppRec.Encoded_ID__c = '123';
        TestingUtility.insertWithAssert(oppRec);
        
        oppRec = [SELECT Name, Type__c, No_of_Desks_unweighted__c, CloseDate, Referrer__c FROM Opportunity WHERE Id =: oppRec.Id];
        debug.log('oppRec.Name: '+oppRec.Name);
        System.assertEquals(referrer1.Id, oppRec.Referrer__c);
        
        DateTime todayDT;
        String dateStr = null;        
        if(oppRec.CloseDate == null){
            todayDT = System.now();
            dateStr = todayDT.format('MMM dd, yyyy');
        }else{
            todayDT = DateTime.newInstance(oppRec.CloseDate.year(), oppRec.CloseDate.month(), oppRec.CloseDate.day());
            dateStr = todayDT.format('MMM dd, yyyy');
        }
        //AccName-MMM dd, yyyy-Quantity MMM dd, yyyy = closing date or today
        String name = accRec.Name+'-'+dateStr+''+((oppRec.No_of_Desks_unweighted__c != 0 && oppRec.No_of_Desks_unweighted__c != null) ? +'-'+oppRec.No_of_Desks_unweighted__c: '');
        //String name =  accRec.Name + ' - ' + oppRec.Type__c + ' - ' + monthinMMMMap.get(system.today().month()) + ' ' + oppRec.CloseDate.year();
        System.assertEquals(name, oppRec.Name);
        
        Account accRecc = TestingUtility.createAccount('strAccountNamestrAccountNamestrAccountNamestrAccountNamestrAccountName:::', true);        
        Contact conRecc = new Contact(
            firstname = 'John',
            lastname = 'Rambo',
            email = 'primarycontact1325@example.com',
            accountID = accRecc.Id,
            Status__c = 'active'
        );
        insert conRecc;
        
        Opportunity oppRecc = TestingUtility.createOpportunity(accRecc.Id, false);
        oppRecc.Primary_Member__c = conRec.Id;
        oppRecc.AccountId = accRecc.Id;
        oppRecc.Actual_Start_Date__c = system.today();
        oppRecc.StageName = 'Selling';
        oppRecc.CloseDate = system.today().addDays(5);
        oppRecc.RecordTypeId = oppRecordType.get('Consumer');
        oppRecc.Type__c = 'Office Space';
        oppRecc.Encoded_ID__c = '123';
        TestingUtility.insertWithAssert(oppRecc);
        
        Test.startTest();
        oppRecc = [SELECT Name, Type__c, No_of_Desks_unweighted__c, CloseDate, Referrer__c FROM Opportunity WHERE Id =: oppRecc.Id];
        System.assertEquals(referrer1.Id, oppRecc.Referrer__c);
        DateTime todayDTT;
        String dateStrr = null;
        if(oppRecc.CloseDate == null){
            todayDTT = System.now();
            dateStrr = todayDTT.format('MMM dd, yyyy');
        }
        else{
            todayDTT = DateTime.newInstance(oppRec.CloseDate.year(), oppRec.CloseDate.month(), oppRec.CloseDate.day());
            dateStrr = todayDTT.format('MMM dd, yyyy');
        }
        String accName =((String)(accRecc.Name)).substring(0, 30);
        //AccName-MMM dd, yyyy-Quantity MMM dd, yyyy = closing date or today
        String oppname = accName + '-' + dateStrr + ''+((oppRec.No_of_Desks_unweighted__c != null && oppRec.No_of_Desks_unweighted__c != 0) ? + '-' + oppRec.No_of_Desks_unweighted__c : '');
        Debug.Log('oppname---'+oppname);
        Debug.Log('oppRecc.Name---'+oppRecc.Name);
        System.assertEquals(oppname, oppRecc.Name); 
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Priyanka Ambre
        Description         :   This method will update Enterprise Opportunity's Name according to product family .
        Created Date        :   25 April 2018 
        Issue No            :   ST-2290
    **************************************************************************************************************************************/
    testmethod static void testUpdateOppNameEnt(){  
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType); 
        List<Product2> lstProductsToInsert = new List<Product2>();
        List<PricebookEntry> lstPricebookEntryToInsert = new List<PricebookEntry>();
        List<Opportunity> lstOpportunitiesToInsert = new List<Opportunity>();
        List<Geography__c> lstGeographies = new List<Geography__c>();
        List<OpportunityLineItem> lstOpportunityLineItemToInsert = new List<OpportunityLineItem>();
        List<Building__c> lstBuilding = new List<Building__c>();
        lstBuilding.add(new Building__c(City__c = 'Amsterdam', Country__c = 'Netherlands', Name = 'AMS-Metropool', CurrencyIsoCode = 'USD', Time_Zone__c = 'Europe/Amsterdam'));
        lstBuilding.add(new Building__c(City__c = 'Berlin Mitte',Country__c = 'Germany', Name = 'BL-Sony Center',CurrencyIsoCode = 'USD', Time_Zone__c = 'America/New_York'));
        insert lstBuilding;
         
        List<Market__c> lstMarkets = new List<Market__c>(); 
        lstMarkets.add(new Market__c(Name='Sydney',CurrencyIsoCode='USD'));
        lstMarkets.add(new Market__c(Name='London',CurrencyIsoCode='USD'));
        insert lstMarkets;
        
        insert new Building_Market__c(Building__c=lstBuilding[1].Id,Market__c=lstMarkets[0].Id);
        
        Map<Integer, String> monthinMMMMap = new Map<Integer, String>{1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun', 7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'};
            Geography__c objGeography1 = new Geography__c(
                Name='Baner1,Maharashtra',
                City__c='Pune',
                Country__c='Indi2politicala', District__c='Pune',
                Formatted_Address__c='Baner, Pune, Maharashtra, India', 
                Geocode__Latitude__s=18.5596581,
                Geocode__Longitude__s=73.7799374,
                JSON__c='{"address_components":[{"long_name":"Baner","short_name":"Baner","types":["","sublocality","sublocality_level_1"]},{"long_name":"Pune","short_name":"Pune","types":["locality","political"]},{"long_name":"Pune","short_name":"Pune","types":["administrative_area_level_2","political"]},{"long_name":"Maharashtra","short_name":"MH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]}],"formatted_address":"Baner, Pune, Maharashtra, India","geometry":{"bounds":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}},"location":{"lat":18.5596581,"lng":73.7799374},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}}},"place_id":"ChIJy9Nd8M--wjsRfat_-5cSkaE","types":["political","sublocality","sublocality_level_1"]}',
                Location_Type__c='APPROXIMATE', 
                Place_ID__c='ChIJy9Nd8M--wjsRfat_-pqr5cSkaEvhj', 
                State__c='Maharashtra',
                Nearest_Building__c = lstBuilding[0].Id
            );  
        lstGeographies.add(objGeography1); 
        Test.startTest();
        TestingUtility.insertListWithAssert(lstGeographies);
        Account accRec = new Account(Name = 'strAccountName1', Number_of_Full_Time_Employees__c = 1000 );
        insert accRec;
        System.assertNotEquals(null, accRec.Id);
        
        Contact contactRec = new Contact(FirstName = 'John', LastName = 'Smith', Email = 'testContact1@example.com', AccountID = accRec.Id, Status__c = 'active');
        insert contactRec;
        System.assertNotEquals(null,contactRec.Id); 
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);//for WeWork with building on opportunity
        oppRec1.Primary_Member__c = contactRec.Id;
        oppRec1.StageName = 'Closing';
        oppRec1.CurrencyIsoCode = 'USD';
        oppRec1.CloseDate = system.today().addDays(5); 
        oppRec1.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        oppRec1.Geography__c = lstGeographies[0].Id;
        oppRec1.Building__c= lstBuilding[0].Id;
        lstOpportunitiesToInsert.add(oppRec1);
        
        Opportunity oppRec2 = TestingUtility.createOpportunity(accRec.Id, false);//for PxWe
        oppRec2.Primary_Member__c = contactRec.Id;
        oppRec2.StageName = 'Closing';
        oppRec2.CurrencyIsoCode = 'USD';
        oppRec2.Requirement_Quantity__c = 10;
        oppRec2.CloseDate = system.today().addDays(5); 
        oppRec2.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        oppRec2.Geography__c = lstGeographies[0].Id;
        oppRec2.Building__c= lstBuilding[0].Id;
        lstOpportunitiesToInsert.add(oppRec2);
        
        System.debug('1.Number of Queries used in this apex code so far at Start: ' + Limits.getQueries());
        
        Opportunity oppRec3 = TestingUtility.createOpportunity(accRec.Id, false);//for Global Access
        oppRec3.Primary_Member__c = contactRec.Id;
        oppRec3.StageName = 'Closing';
        oppRec3.CurrencyIsoCode = 'USD';
        oppRec3.CloseDate = system.today().addDays(5); 
        oppRec3.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        oppRec3.Geography__c = lstGeographies[0].Id;
        oppRec3.Building__c = lstBuilding[0].Id;
        lstOpportunitiesToInsert.add(oppRec3);
        
        Opportunity oppRec4 = TestingUtility.createOpportunity(accRec.Id, false);//for Mixed
        oppRec4.Primary_Member__c = contactRec.Id;
        oppRec4.StageName = 'Closing';
        oppRec4.CurrencyIsoCode = 'USD';
        oppRec4.Requirement_Quantity__c = 5;
        oppRec4.CloseDate = system.today().addDays(5); 
        oppRec4.Geography__c = lstGeographies[0].Id;
        oppRec4.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        oppRec4.Building__c= lstBuilding[0].Id;
        lstOpportunitiesToInsert.add(oppRec4);
        
        Opportunity oppRec5 = TestingUtility.createOpportunity(accRec.Id, false);//other than specified families. "Envision"
        oppRec5.Primary_Member__c = contactRec.Id;
        oppRec5.StageName = 'Closing';
        oppRec5.CurrencyIsoCode = 'USD';
        oppRec5.CloseDate = system.today().addDays(5); 
        oppRec5.Geography__c = lstGeographies[0].Id;
        oppRec5.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        oppRec5.Building__c= lstBuilding[0].Id;
        lstOpportunitiesToInsert.add(oppRec5);
        
        Opportunity oppRec6 = TestingUtility.createOpportunity(accRec.Id, false);//for WeWork with Building on oppLineItem 
        oppRec6.Primary_Member__c = contactRec.Id;
        oppRec6.StageName = 'Closing';
        oppRec6.CurrencyIsoCode = 'USD';
        oppRec6.CloseDate = system.today().addDays(5); 
        oppRec6.Geography__c = lstGeographies[0].Id;
        oppRec6.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        lstOpportunitiesToInsert.add(oppRec6);
        
        Opportunity oppRec7 = TestingUtility.createOpportunity(accRec.Id, false);//for WeWork with no oppLineItem 
        oppRec7.Primary_Member__c = contactRec.Id;
        oppRec7.StageName = 'Closing';
        oppRec7.CurrencyIsoCode = 'USD';
        oppRec7.CloseDate = system.today().addDays(5); 
        oppRec7.Geography__c = lstGeographies[0].Id;
        oppRec7.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        oppRec7.Building__c = lstBuilding[0].Id;
        lstOpportunitiesToInsert.add(oppRec7);
        
        Opportunity oppRec8 = TestingUtility.createOpportunity(accRec.Id, false);//for PxWe with geography on opportunityLineItem
        oppRec8.Primary_Member__c = contactRec.Id;
        oppRec8.StageName = 'Closing';
        oppRec8.CurrencyIsoCode = 'USD';
        oppRec8.CloseDate = system.today().addDays(5); 
        oppRec8.RecordTypeId = oppRecordType.get('Enterprise Solutions'); 
        oppRec8.Building__c= lstBuilding[0].Id;
        lstOpportunitiesToInsert.add(oppRec8);
        
        Opportunity oppRec9 = new Opportunity(Name = 'Test',
                                              Primary_Member__c = contactRec.Id,
                                              StageName = 'Closing', 
                                              CloseDate = system.today().addDays(5));//for PxWe with geography on opportunityLineItem
        DateTime todayDT;
        String dateStr = null;
        if(oppRec1.CloseDate == null){
            todayDT = System.now();
            dateStr = todayDT.format('MMM dd, yyyy');
        } else{
            todayDT = DateTime.newInstance(oppRec1.CloseDate.year(), oppRec1.CloseDate.month(), oppRec1.CloseDate.day());
            dateStr = todayDT.format('MMM dd, yyyy');
        }
        
        TestingUtility.insertListWithAssert(lstOpportunitiesToInsert);        
        for(Opportunity opp : [SELECT Id, Name, No_of_Desks_unweighted__c, Type__c FROM Opportunity]){ 
            debug.log('opp: '+opp);
            if(opp.Type__c != null ){
                System.assertEquals(accRec.Name + '-' + opp.Type__c + '-' + dateStr, opp.Name);
            }else{
                System.assertEquals(accRec.Name + '-' + dateStr, opp.Name);
            }
        } 
        
        Product2 prod1 = new Product2(
            Name = 'Hot Desk',
            Product_Category__c = 'Hot Desk',
            Default_Product_Category__c = 'Hot Desk',
            ProductCode = 'PRHD-000400',
            Family = 'WeWork',
            IsActive = true);
        lstProductsToInsert.add(prod1);
        
        Product2 prod2 = new Product2(
            Name = 'Hospitality',
            Product_Category__c = 'PxWe',
            Default_Product_Category__c = 'PxWe',
            Family = 'PxWe',
            ProductCode = 'PxWe-Ho',
            IsActive = true);
        lstProductsToInsert.add(prod2);
        
        Product2 prod3 = new Product2(
            Name = 'Deal',
            Product_Category__c = 'Standard Office',
            Default_Product_Category__c = 'Standard Office',
            ProductCode = 'PRDL-000001',
            Family = 'Global Access',
            IsActive = true);
        lstProductsToInsert.add(prod3);
        
        Product2 prod4 = new Product2(
            Name = 'DedicatedDesk',
            Product_Category__c = 'Global Access',
            Default_Product_Category__c = 'Standard Office', 
            ProductCode = 'PRDE-000500',
            Family = 'Envision',
            IsActive = true);
        lstProductsToInsert.add(prod4);
        TestingUtility.insertListWithAssert(lstProductsToInsert);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice1 = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod1.Id,
            UnitPrice = 10000, 
            IsActive = true,
            CurrencyIsoCode = 'USD' );
        lstPricebookEntryToInsert.add(standardPrice1);
        
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod2.Id,
            UnitPrice = 10000, 
            IsActive = true,
            CurrencyIsoCode = 'USD' );
        lstPricebookEntryToInsert.add(standardPrice2);
        
        PricebookEntry standardPrice3 = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod3.Id,
            UnitPrice = 10000, 
            IsActive = true,
            CurrencyIsoCode = 'USD'
        );
        lstPricebookEntryToInsert.add(standardPrice3);
        
        PricebookEntry standardPrice4 = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod4.Id,
            UnitPrice = 10000, 
            IsActive = true,
            CurrencyIsoCode = 'USD'
        );
        lstPricebookEntryToInsert.add(standardPrice4);
        
        TestingUtility.insertListWithAssert(lstPricebookEntryToInsert);
        
        OpportunityLineItem objOpportunityLineItem1 = new OpportunityLineItem();
        objOpportunityLineItem1.Is_Primary_Product__c = true;
        objOpportunityLineItem1.PricebookEntryId = standardPrice1.Id;
        objOpportunityLineItem1.Geography__c = lstGeographies[0].Id;    
        objOpportunityLineItem1.OpportunityId = oppRec1.Id;
        objOpportunityLineItem1.UnitPrice = 10;
        objOpportunityLineItem1.Quantity = 20; 
        objOpportunityLineItem1.Family__c = 'WeWork';
        lstOpportunityLineItemToInsert.add(objOpportunityLineItem1);
        
        OpportunityLineItem objOpportunityLineItem2 = new OpportunityLineItem();
        objOpportunityLineItem2.PricebookEntryId = standardPrice2.Id;
        objOpportunityLineItem2.OpportunityId = oppRec2.Id;
        objOpportunityLineItem2.UnitPrice = 10;
        objOpportunityLineItem2.Quantity = 20;  
        objOpportunityLineItem2.Family__c = 'PxWe';
        lstOpportunityLineItemToInsert.add(objOpportunityLineItem2);
        
        OpportunityLineItem objOpportunityLineItem3 = new OpportunityLineItem();
        objOpportunityLineItem3.PricebookEntryId = standardPrice3.Id;
        objOpportunityLineItem3.OpportunityId = oppRec3.Id;
        objOpportunityLineItem3.UnitPrice = 10;
        objOpportunityLineItem3.Quantity = 20;  
        objOpportunityLineItem3.Family__c = 'Global Access';
        lstOpportunityLineItemToInsert.add(objOpportunityLineItem3);
        
        OpportunityLineItem objOpportunityLineItem4 = new OpportunityLineItem();
        objOpportunityLineItem4.PricebookEntryId = standardPrice3.Id;
        objOpportunityLineItem4.OpportunityId = oppRec3.Id;
        objOpportunityLineItem4.UnitPrice = 10;
        objOpportunityLineItem4.Quantity = 40;  
        objOpportunityLineItem4.Family__c = 'Global Access';
        lstOpportunityLineItemToInsert.add(objOpportunityLineItem4);
        
        OpportunityLineItem objOpportunityLineItem5 = new OpportunityLineItem();//oppRec4
        objOpportunityLineItem5.PricebookEntryId = standardPrice1.Id;
        objOpportunityLineItem5.OpportunityId = oppRec4.Id;
        objOpportunityLineItem5.UnitPrice = 10;
        objOpportunityLineItem5.Quantity = 20; 
        objOpportunityLineItem5.Family__c = 'WeWork';
        lstOpportunityLineItemToInsert.add(objOpportunityLineItem5);
        
        OpportunityLineItem objOpportunityLineItem6 = new OpportunityLineItem();//oppRec4
        objOpportunityLineItem6.PricebookEntryId = standardPrice4.Id;
        objOpportunityLineItem6.OpportunityId = oppRec4.Id;
        objOpportunityLineItem6.UnitPrice = 10;
        objOpportunityLineItem6.Quantity = 40;  
        objOpportunityLineItem6.Family__c = 'Global Access';
        lstOpportunityLineItemToInsert.add(objOpportunityLineItem6);
        
        OpportunityLineItem objOpportunityLineItem7 = new OpportunityLineItem();// oppRec5 other than specified families.
        objOpportunityLineItem7.PricebookEntryId = standardPrice4.Id;
        objOpportunityLineItem7.OpportunityId = oppRec5.Id;
        objOpportunityLineItem7.UnitPrice = 10;
        objOpportunityLineItem7.Quantity = 40;  
        objOpportunityLineItem7.Family__c = 'Envision';
        lstOpportunityLineItemToInsert.add(objOpportunityLineItem7);
        
        OpportunityLineItem objOpportunityLineItem8 = new OpportunityLineItem();// oppRec6 
        objOpportunityLineItem8.PricebookEntryId = standardPrice1.Id;
        objOpportunityLineItem8.OpportunityId = oppRec6.Id;
        objOpportunityLineItem8.Building__c = lstBuilding[0].Id; 
        objOpportunityLineItem8.UnitPrice = 10;
        objOpportunityLineItem8.Quantity = 40;  
        objOpportunityLineItem8.Family__c = 'WeWork'; 
        lstOpportunityLineItemToInsert.add(objOpportunityLineItem8); 
        
        OpportunityLineItem objOpportunityLineItem9 = new OpportunityLineItem();// oppRec8 for PxWe with geography on opportunityLineItem
        objOpportunityLineItem9.PricebookEntryId = standardPrice2.Id;
        objOpportunityLineItem9.OpportunityId = oppRec8.Id;
        objOpportunityLineItem9.Geography__c = lstGeographies[0].Id;
        objOpportunityLineItem9.UnitPrice = 10;
        objOpportunityLineItem9.Quantity = 40;  
        objOpportunityLineItem9.Family__c = 'PxWe'; 
        lstOpportunityLineItemToInsert.add(objOpportunityLineItem9); 
        TestingUtility.insertListWithAssert(lstOpportunityLineItemToInsert);
        
        insert oppRec9;
        System.assertNotEquals(null, oppRec9.Id);
        System.assertEquals('Test', oppRec9.Name);
       
        for(Opportunity opp : [SELECT Id, Name, No_of_Desks_unweighted__c, Building__r.Name, Type__c, Requirement_Quantity__c FROM Opportunity] ){ 
            debug.log('opp: '+opp);
            if(opp.Id == oppRec1.Id ){
                System.assertEquals(accRec.Name + '-' + lstGeographies[0].City__c + '-WW-' + opp.No_of_Desks_unweighted__c + '-'+dateStr, opp.Name);     
            } else if(opp.Id == oppRec2.Id ){
                 System.assertEquals(accRec.Name + '-' + lstGeographies[0].City__c + '-PxWe-' + dateStr, opp.Name);
            } else if(opp.Id == oppRec3.Id ){
                 System.assertEquals(accRec.Name + '-' + lstGeographies[0].City__c + '-GA-' + '60' + '-' + dateStr, opp.Name);
            } else if(opp.Id == oppRec4.Id ){
                 System.assertEquals(accRec.Name + '-Mixed-' + dateStr, opp.Name); 
            } else if(opp.Id == oppRec5.Id ){
                 System.assertEquals(accRec.Name + '-' + 'Envision' + '-' + dateStr, opp.Name);
            } else if(opp.Id == oppRec6.Id ){
                 System.assertEquals(accRec.Name+'-' + lstGeographies[0].City__c + '-WW-' + opp.No_of_Desks_unweighted__c + '-' + dateStr, opp.Name);
            } else if(opp.Id == oppRec7.Id ){
                System.assertEquals(accRec.Name + '-' + dateStr, opp.Name);
            } else if(opp.Id == oppRec8.Id ){
                System.assertEquals(accRec.Name + '-PxWe-' + dateStr, opp.Name);
            }
        }
        objGeography1.City__c=null;
        update lstGeographies;
        for(Geography__c geo : [SELECT Id, Name, City__c, State__c, Country__c FROM Geography__c] ){
            if(geo.Id == objGeography1.Id ){
                System.assertEquals(null, geo.City__c);
            }
        }
        oppRec1.Name = 'abc';
        oppRec8.Name = 'abc';
        oppRec2.Name = 'abc';
        
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        lstOppToUpdate.add(oppRec2);
        lstOppToUpdate.add(oppRec8);
        lstOppToUpdate.add(oppRec1);
        update lstOppToUpdate;
        
        for(Opportunity opp : [SELECT Id, Name, No_of_Desks_unweighted__c, Type__c, Requirement_Quantity__c FROM Opportunity] ){
            if(opp.Id == oppRec1.Id ){
                System.assertEquals(accRec.Name + '-' + lstGeographies[0].State__c + '-WW-' + opp.No_of_Desks_unweighted__c + '-' + dateStr, opp.Name);
            }else if(opp.Id ==oppRec2.Id ){
                System.assertEquals(accRec.Name + '-'+lstGeographies[0].State__c + '-PxWe-' + dateStr, opp.Name);
            }else if(opp.Id == oppRec8.Id ){
                System.assertEquals(accRec.Name + '-PxWe-' + dateStr, opp.Name);
            }
        } 
        objGeography1.State__c = null;
        update lstGeographies;
        for(Geography__c geo : [SELECT Id, Name, City__c, State__c, Country__c FROM Geography__c] ){
            if(geo.Id == objGeography1.Id ){
                System.assertEquals(null, geo.State__c);
            }
        } 
        oppRec8.Name = 'abc';
        oppRec2.Name = 'abc'; 
        oppRec1.Name = 'abc';
        update lstOppToUpdate;
        
        for(Opportunity opp : [SELECT Id, Name, No_of_Desks_unweighted__c, Type__c, Requirement_Quantity__c FROM Opportunity] ){
            if(opp.Id == oppRec1.Id ){
                System.assertEquals(accRec.Name+'-'+lstGeographies[0].Country__c + '-WW-' + opp.No_of_Desks_unweighted__c + '-'+dateStr, opp.Name);
            }else if(opp.Id == oppRec2.Id ){
                System.assertEquals(accRec.Name + '-' + lstGeographies[0].Country__c + '-PxWe-' + dateStr, opp.Name);
            }else if(opp.Id == oppRec8.Id ){
                System.assertEquals(accRec.Name + '-PxWe-' + dateStr, opp.Name);
            }
        }
        
        accRec.Name = 'strAccountName1_strAccountName2_strAccountName3_strAccountName4_strAccountName5_strAccountName6';
        update accRec;
        for(Account account : [SELECT Id, Name FROM Account WHERE Id =: accRec.Id] ){
            if(account.Id == accRec.Id ){
                System.assertEquals(accRec.Name, 'strAccountName1_strAccountName2_strAccountName3_strAccountName4_strAccountName5_strAccountName6');
            }
        }
        oppRec2.Name = 'abc'; 
        update lstOppToUpdate;
        for(Opportunity opp : [SELECT Id, Name, No_of_Desks_unweighted__c, Type__c, Requirement_Quantity__c FROM Opportunity WHERE Id =: oppRec2.Id] ){
            if(opp.Id == oppRec2.Id ){
                System.assertEquals('strAccountName1_strAccountName2_strAccountName3_strAccountName4_strAccountName5_strAcc' + '-' + lstGeographies[0].Country__c + '-PxWe-' + dateStr, opp.Name);              
            }
        }
        Test.stopTest();
    }

    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This method contain unit test for copying field from last opportunity.
        Created Date        :   23 February 2016
        Last Modified Date  :   13 June 2016
        Last Modified By    :   Amol Darekar
    **************************************************************************************************************************************/
    static testMethod void testcopyFieldFromLastOpportunity(){
        test.startTest();
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        Contact conRec = new Contact(
            firstname = 'John',
            lastname = 'Rambo',
            email = 'test@example.com',
            accountID = accRec.Id,
            Status__c = 'active'
        );
        insert conRec;
        
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        
        Opportunity oppRec = new Opportunity();
        oppRec.AccountId = accRec.Id;
        oppRec.Primary_Member__c = conRec.Id;
        oppRec.StageName = 'Inquiry';
        oppRec.CloseDate = system.today();
        oppRec.RecordTypeId = oppRecordType.get('Consumer');
        oppRec.Lead_Source_Detail__c = 'Test Lead Details'; 
        oppRec.LeadSource = '42 Floors';
        oppRec.utm_campaign__c = 'Test Campaign';
        oppRec.utm_campaign_id__c = '123';
        oppRec.utm_content__c = 'Test Content';
        oppRec.utm_medium__c = 'Test Medium';
        oppRec.utm_source__c = 'Test Source';
        oppRec.utm_term__c = 'Test Term';
        oppRec.Use_Case__c = 'Swing Space';
        insert oppRec;
        
        Opportunity oppnew = [select CreatedDate,LeadSource,Lead_Source_Detail__c,utm_campaign__c,utm_campaign_id__c,utm_content__c,utm_medium__c,utm_source__c,utm_term__c,Contract_Email__c from Opportunity where Id =: oppRec.Id];
        
        Opportunity opportunity2 = new Opportunity();
        Opportunity2.Name='Test';
        opportunity2.AccountId = accRec.Id;
        opportunity2.Primary_Member__c = conRec.Id;
        opportunity2.StageName = 'Selling';
        opportunity2.CloseDate = system.today().addDays(5);
        opportunity2.RecordTypeId = oppRecordType.get('Consumer');
        opportunity2.Use_Case__c = 'Swing Space';
        /*Modified by- Milanjeet - Added LeadSource*/
        opportunity2.LeadSource = '42 Floors';
        insert opportunity2;
        
        Opportunity newOpp = [SELECT CreatedDate, LeadSource, Lead_Source_Detail__c, utm_campaign__c, utm_campaign_id__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c, Contract_Email__c FROM Opportunity WHERE Id =: opportunity2.Id];
        system.assertEquals('42 Floors',newOpp.LeadSource);
        system.assertEquals('Test Lead Details',newOpp.Lead_Source_Detail__c);
        test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This method contain unit test for update primary memeber on opportunity.
        Created Date        :   23 February 2016
        Last Modified Date  :   13 June 2016
        Last Modified By    :   Amol Darekar
    **************************************************************************************************************************************/
    static testMethod void testUpdatePrimaryMemberOnOpportunity(){
        //Test : ST-508 : Map opportunity with latest booked tour on its primary member with same location interested
        Account accountRec = TestingUtility.createAccount('strAccountName', true);
        Contact primaryMember1 = TestingUtility.createContact(accountRec.Id, 'strLastName', false);
        primaryMember1.Email = 'primarymember1@example.com';
        TestingUtility.insertWithAssert(primaryMember1);
        
        List<Tour_Outcome__c> lstTours = new List<Tour_Outcome__c>();
        List<Building__c> lstBuildings = new List<Building__c>();
        Building__c building1 = new Building__c(
            Name='NYC-Penn Station',
            uuid__c = 'abc123'
        );
        lstBuildings.add(building1);
        
        Building__c building2 = new Building__c(
            Name='building2',
            uuid__c = 'abc1232'
        );
        lstBuildings.add(building2);
        
        TestingUtility.insertListWithAssert(lstBuildings);
        
        Tour_Outcome__c tour1 = new Tour_Outcome__c();
        tour1.Primary_Member__c = primaryMember1.Id;
        tour1.Status__c = 'Scheduled';
        tour1.Tour_Date__c = system.today().addDays(3);
        tour1.Location__c = building1.Id;
        lstTours.add(tour1);        
        
        Tour_Outcome__c tour2 = new Tour_Outcome__c();
        tour2.Primary_Member__c = primaryMember1.Id;
        tour2.Status__c = 'Scheduled';
        tour2.Tour_Date__c = system.today().addDays(3);
        tour2.Location__c = building1.Id;
        lstTours.add(tour2);
        TestingUtility.insertListWithAssert(lstTours);
        
        Debug.log('Limits queries==>'+Limits.getQueries());
        Test.setCreatedDate(tour1.Id, Datetime.now().addDays(-1));
        Test.setCreatedDate(tour2.Id, Datetime.now());
        
        Test.startTest();
        Opportunity opportunity1 = new Opportunity(
            AccountID                       = accountRec.Id,
            CloseDate                       = system.today(),
            Actual_Start_Date__c            = system.today(),
            StageName                       = 'Qualifying',
            Name                            = 'test Opoortunity',
            Building__c                     = building1.Id,
            Primary_Member__c               = primaryMember1.Id,
            Use_Case__c                     = 'Swing Space'
        );
        insert opportunity1;
        Test.stopTest();
        System.assertEquals(tour2.Id, [SELECT Id, Name, Tour_Outcome__c FROM Opportunity WHERE Id=:opportunity1.Id].Tour_Outcome__c);
    }
    
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This method contain unit test for delete building interest.
        Created Date        :   23 February 2016
        Last Modified Date  :   13 June 2016
        Last Modified By    :   Amol Darekar
    **************************************************************************************************************************************/
    static testMethod void testDeleteBuildingInterests(){  
        test.startTest();
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        Account accRec     = TestingUtility.createAccount('strAccountName', true);
        Contact conRec = new Contact(
            firstname      = 'John',
            lastname       = 'Rambo',
            email          = 'test@example.com',
            accountID       = accRec.Id,
            Status__c      = 'active'
        );
        insert conRec;
        
        Opportunity oppRec = new Opportunity();
        oppRec.AccountId = accRec.Id;
        oppRec.StageName = 'Selling';
        oppRec.CloseDate = system.today().addDays(5);
        // oppRec.RecordTypeId = oppRecordType.get('Consumer');
        oppRec.Use_Case__c = 'Swing Space';
        // oppRec.Primary_Member__c = conRec.Id;
        insert oppRec;
        
        Building__c b = new Building__c(
            Name='b1',
            uuid__c = 'abc123'
        );
        insert b;
        
        Building_Interest__c b1 = new Building_Interest__c(
            Building__c = b.Id,
            //CurrencyIsoCode ='GBP-British Pound',
            Opportunity__c = oppRec.Id
        );
        
        insert b1;
        delete oppRec;
        
        List<Building_Interest__c> bi = [SELECT Id FROM Building_Interest__c];
        System.assertEquals(bi.size(), 0);
        Debug.log('Size of Building Interest ::'+bi);
        test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This method contain unit test for on send paperwork change opportunity owner.
        Created Date        :   23 February 2016
        Last Modified Date  :   13 June 2016
        Last Modified By    :   Amol Darekar
    **************************************************************************************************************************************/
    static testMethod void updateOpporunityOwnerOnSendPaperworkTest(){
        Test.startTest();
        Profile systemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];        
        Map<String,Object> userRecordMap1 = new Map<String,Object>();
        userRecordMap1.put('LastName','Last Name');
        userRecordMap1.put('Username','testweworkuserforSendPaperwork@example.com');
        userRecordMap1.put('Email','testweworkuserforSendPaperwork@example.com');
        userRecordMap1.put('IsActive',true);
        User testUser1 = TestingUtility.insertUserWithAssert(systemAdmin.Id, userRecordMap1, true);
        
        Map<String,Object> userRecordMap2 = new Map<String,Object>();
        userRecordMap2.put('LastName','Last Name1');
        userRecordMap2.put('Username','testweworkuserforSendPaperwork3@example.com');
        userRecordMap2.put('Email','testweworkuserforSendPaperwork3@example.com');
        userRecordMap2.put('IsActive',true);
        User testUser2 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap2, true);
        
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        System.assertNotEquals(null, accRec.Id);
        
        Contact conRec = new Contact(
            firstname = 'Test',
            lastname = 'User',
            email = 'testweworkuserforSendPaperwork@example.com',
            AccountId = accRec.Id
        );
        TestingUtility.insertWithAssert(conRec);
        System.assertNotEquals(null, conRec.Id);
        
        Contact conRec2 = new Contact(
            firstname = 'Test',
            lastname = 'User',
            email = 'testweworkuserforSendPaperwork2@example.com',
            AccountId = accRec.Id
        );
        TestingUtility.insertWithAssert(conRec2);
        System.assertNotEquals(null, conRec2.Id);
        
        Contact conRec3 = new Contact(
            firstname = 'Test1',
            lastname = 'User',
            email = 'testweworkuserforSendPaperwork3@example.com',
            AccountId = accRec.Id
        );
        TestingUtility.insertWithAssert(conRec3);
        System.assertNotEquals(null, conRec3.Id);
        
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        System.assertNotEquals(null, oppRecordType);
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec1.Primary_Member__c = conRec.Id;
        oppRec1.AccountId = accRec.Id;
        oppRec1.StageName = 'Selling';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.RecordTypeId = oppRecordType.get('Consumer');   
        oppRec1.Owner_Auto_Assign__c = true;
        TestingUtility.insertWithAssert(oppRec1);
        
        System.assertNotEquals(null, oppRec1.Id);
        
        Opportunity opp = [SELECT Id, OwnerId, Send_Paperwork_By__c FROM Opportunity WHERE Id =: oppRec1.Id];
        
        System.assertNotEquals(null, opp);
        System.assertEquals(null, opp.Send_Paperwork_By__c);
        System.assertNotEquals(testUser1.Id, opp.OwnerId);      
        
        opp.Send_Paperwork_By__c = conRec.Id;
        update opp;
        
        opp = [SELECT Id, RecordType.Name, OwnerId FROM Opportunity WHERE Id =: oppRec1.Id];
        
        System.assertEquals('Consumer', opp.RecordType.Name);
        System.assertEquals(testUser1.Id, opp.OwnerId);     
        Test.stopTest();
        
        Opportunity oppRec2 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec2.Primary_Member__c = conRec.Id;
        oppRec2.AccountId = accRec.Id;
        oppRec2.StageName = 'Selling';
        oppRec2.CloseDate = system.today().addDays(5);
        oppRec2.RecordTypeId = oppRecordType.get('Mid Market');
        oppRec2.Send_Paperwork_By__c = conRec2.Id;
        oppRec2.Owner_Auto_Assign__c = true;
        TestingUtility.insertWithAssert(oppRec2);
        
        opp = [SELECT Id, OwnerId, Send_Paperwork_By__c FROM Opportunity WHERE Id =: oppRec2.Id];
        System.assertEquals(conRec2.Id, opp.Send_Paperwork_By__c);
        
        oppRec2.Send_Paperwork_By__c = conRec.Id;
        update oppRec2;
        
        opp = [SELECT Id, RecordType.Name,Send_Paperwork_By__c, OwnerId FROM Opportunity WHERE Id =: oppRec2.Id];
        
        System.assertEquals('Consumer', opp.RecordType.Name); 
        System.assertEquals(testUser1.Id, opp.OwnerId); 
            
        Opportunity oppRec3 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec3.Primary_Member__c = conRec.Id;
        oppRec3.AccountId = [SELECT Id FROM Account WHERE Name ='Test-Account3'].Id;
        oppRec3.StageName = 'Selling';
        oppRec3.CloseDate = system.today().addDays(5);
        oppRec3.RecordTypeId = oppRecordType.get('Enterprise Solutions'); 
        oppRec3.Owner_Auto_Assign__c = true;
        TestingUtility.insertWithAssert(oppRec3);
        
        opp = [SELECT Id, RecordType.Name,Send_Paperwork_By__c, OwnerId FROM Opportunity WHERE Id =: oppRec3.Id];
        System.assertNotEquals(opp.OwnerId, testUser2.Id);
        oppRec3.Send_Paperwork_By__c = conRec3.Id;
        update oppRec3;
        
        opp = [SELECT Id, RecordType.Name,Send_Paperwork_By__c, OwnerId FROM Opportunity WHERE Id =: oppRec3.Id];
        System.assertNotEquals(opp.OwnerId, testUser2.Id);
        
        oppRec3.Send_Paperwork_By__c = conRec.Id;
        update oppRec3;
        opp = [SELECT Id, RecordType.Name,Send_Paperwork_By__c, OwnerId FROM Opportunity WHERE Id =: oppRec3.Id];
        System.assertEquals(testUser1.Id, opp.OwnerId); 
    }
   
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method contain unit test for update primary memeber on opportunity.
        Created Date        :   10 May 2017
        Issue No            :   ST-1091
    **************************************************************************************************************************************/
    public static testMethod void verifyMapOpportunityContactRole(){        
        Account accRec = new Account(
            Name = 'Test Account'      
        );
        insert accRec;
        System.assert(String.isNotBlank(accRec.Id));
        
        Contact conRec1 = new Contact(
            FirstName = 'Test',
            LastName = 'Member',
            Email = 'testContact1@example.com',
            AccountId = accRec.Id
        );
        insert conRec1;
        System.assert(String.isNotBlank(conRec1.Id));
        debug.log('conRec1  ::'+conRec1);
        
        Opportunity oppRec = new Opportunity(
            Name = 'Test Opportunity',
            Primary_Member__c = conRec1.Id,
            AccountId = accRec.Id,
            StageName = 'Qualifying',
            CloseDate = Date.today().addDays(30),
            Use_Case__c = 'Swing Space',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId(),
            Owner_Auto_Assign__c = true
        );
        insert oppRec;
        Test.startTest();
        System.assert(String.isNotBlank(oppRec.Id));
        
        List<Opportunity_Role__c> opportunityRole = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE Opportunity__c =: oppRec.Id];
        Debug.log('opportunityRole 1 :: '+opportunityRole);
        //for singale opportunity one opportunityRole is created
        System.assertEquals(1, opportunityRole.size());
        //here opportunityRole becomes Primary Member
        System.assertNotEquals(null, opportunityRole[0].Id);
        //opportunity Id and  opportunityRole[0].Opportunity__c shode be same
        System.assertEquals(oppRec.Id, opportunityRole[0].Opportunity__c);
        //contact Id and the contact on  opportunityRole shode be same
        System.assertEquals(conRec1.Id, opportunityRole[0].Contact__c);
        //the primary member on opportunityRole is created when opportunityRole record is  created 
        System.assertEquals(true, opportunityRole[0].Is_Primary_Member__c);
        //for firest contact on opportunity the Role is 'Primary Member' on opportunityRole(that is Role field on opportunityRole is updated with 'Primary Member').
        //  when cotact on opportunity is updated the previous contact become Influencer and new contact becomes primary member.
        
        System.assertEquals('Primary Member', opportunityRole[0].Role__c);
        //seccond contact is created
        Contact conRec2 = new Contact(
            FirstName = 'Test',
            LastName = 'Member',
            Email = 'testContact2@example.com',
            AccountId = accRec.Id
        );
        insert conRec2;
        System.assert(String.isNotBlank(conRec2.Id));//second contact is inserted successfuly
        //second Opportunity created
        Opportunity oppRec2 = new Opportunity(
            Name = 'Test Opportunity',
            Primary_Member__c = conRec2.Id,
            AccountId = accRec.Id,
            StageName = 'Qualifying',
            CloseDate = Date.today().addDays(30),
            Use_Case__c = 'Swing Space',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId(),
            Owner_Auto_Assign__c = true
        );
        insert oppRec2;        
        System.assert(String.isNotBlank(oppRec2.Id));//second opportunity insereted succesfully
        
        opportunityRole = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE Opportunity__c =: oppRec2.Id];
        //Here 2 Opportunity roles gets created because we assign contact as primary member of opportunity which is not primary member of account
        //So we have process builder name 'Opportunity fields mapping' which update opportunity primary member field  to accounts primary member
        //Here opportunity primary member get changed so 2 opportunity roles get created first on create and second on update from trigger.
        //for oppRec2 a singale opportunityRole is created
        System.assertEquals(1, opportunityRole.size());
        //here opportunityRole is 'Primary Member'
        System.assertNotEquals(null, opportunityRole[0].Id);
        //opportunity Id is same as opportunityRole.Opportunity__c
        System.assertEquals(oppRec2.Id, opportunityRole[0].Opportunity__c);
        //conRec2.Id is same as opportunityRole.Contact__c
        System.assertEquals(conRec2.Id, opportunityRole[0].Contact__c);
        System.assertEquals(true, opportunityRole[0].Is_Primary_Member__c);
        /*
            * Edited By : sunil bhosale  
            *below two asserts are comented because they are out of scenarios   
        */
        
        System.assertEquals('Primary Member', opportunityRole[0].Role__c);
        //for oppRec contact is updated due to this secod contact becomes Primary member and firest ontact on oppRec becomes infulancer.
        oppRec.Primary_Member__c = conRec2.Id;
        update oppRec;
        Opportunity opp = [SELECT Id, Primary_Member__c FROM Opportunity WHERE Id =: oppRec.Id];        
        //primary member on opp.(oppRec) becomes conRec2 (i.e. updated contact)
        System.assertEquals(conRec2.Id, opp.Primary_Member__c);
        
        opportunityRole = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE Opportunity__c =:oppRec.Id];
        //due to update of contact on oppRec two opportunityRole are created
        System.assertEquals(2, opportunityRole.size());
        for(Opportunity_Role__c oppRole : opportunityRole){
            if(oppRole.Contact__c == conRec2.Id){
                System.assertEquals(true, oppRole.Is_Primary_Member__c);
                System.assertEquals('Primary Member', oppRole.Role__c);
            } else {
                System.assertEquals(false, oppRole.Is_Primary_Member__c);
                System.assertEquals('Influencer', oppRole.Role__c);
            }
        }
        
        oppRec2.Primary_Member__c = conRec1.Id;
        update oppRec2;
        
        opportunityRole = [SELECT Id, Opportunity__c, Contact__c, Is_Primary_Member__c, Role__c FROM Opportunity_Role__c WHERE Opportunity__c =: oppRec2.Id];        
        System.assertEquals(2, opportunityRole.size());
        for(Opportunity_Role__c oppRole : opportunityRole){
            if(oppRole.Contact__c == conRec1.Id){
                System.assertEquals(true, oppRole.Is_Primary_Member__c);
                System.assertEquals('Primary Member', oppRole.Role__c);
            }else {             
                System.assertEquals(false, oppRole.Is_Primary_Member__c);
                System.assertEquals('Influencer', oppRole.Role__c);
            }
        }        
        
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Anant Kumar
        Description         :   This method contain unit test for restrict user to change lead source.
        Created Date        :   23 February 2016
        Last Modified Date  :   13 June 2016
        Last Modified By    :   Amol Darekar
    **************************************************************************************************************************************/
    static testMethod void testRestrictUserToChangeLeadSource(){
        try{            
            System.runAs(new User(Id=UserInfo.getUserId())) {
                Account accRec = TestingUtility.createAccount('strAccountName', true);         
                Contact referrer1 = new Contact(
                    firstname = 'John',
                    lastname = 'Rambo',
                    email = 'referrer1@example.com',
                    accountID = accRec.Id,
                    Status__c = 'active'
                );
                insert referrer1;
                            
                Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);                
                Opportunity oppRec = new Opportunity();
                oppRec.Primary_Member__c = referrer1.Id;                
                oppRec.AccountId = accRec.Id;
                oppRec.StageName = 'selling';
                oppRec.CloseDate = system.today().addDays(5);
                oppRec.LeadSource = 'WeWork.com';
                oppRec.RecordTypeId = oppRecordType.get('Consumer');
                insert oppRec;               
                
                Tour_Outcome__c tour1 = new Tour_Outcome__c();
                tour1.Scheduled_By__c = referrer1.Id;
                tour1.Opportunity__c = oppRec.Id;       
                tour1.Status__c = 'Scheduled';       
                tour1.Primary_Member__c = referrer1.Id;
                tour1.Tour_Date__c = system.today().addDays(3);
                insert tour1;
                
                //Test.setCreatedDate(tour1.Id, DateTime.newInstance(2017,08,24)); 
                Tour_Outcome__c tourRecord = [SELECT Id, Name, Primary_Member__c, CreatedDate FROM Tour_Outcome__c];                
                Opportunity opp=[SELECT id,Name,LeadSource,StageName from Opportunity WHERE Id =: oppRec.Id];                
                opp.LeadSource='Outbound Email/Cold Call';
                update opp;                
                Opportunity oppRecord=[SELECT id,Name,LeadSource,StageName from Opportunity WHERE Id =: opp.Id];                
            } 
        } catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot change the lead source to outbound because the main contact was given a tour within the last 60 days');
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This Method is used to verify reparenting of opportunity on different org.
        Created Date        :   07 July 2018       
    **************************************************************************************************************************************/    
    public static testmethod void verifyReparentOpportunity(){        
        List<Account> lstOrgAccToInsert = new List<Account>();
        List<Account> lstAccToInsert = new List<Account>();
        Map<String, Object> mapAccountToInsert = new Map<String, Object>{'Name'=>'Org Account'};
            
            lstOrgAccToInsert.addAll(TestingUtility.getAccountsByType(mapAccountToInsert, 'Org', 2));
        TestingUtility.insertListWithAssert(lstOrgAccToInsert);//acc1 and acc2 are top level org Accounts.
        
        mapAccountToInsert.put('Name', 'Account ');
        mapAccountToInsert.put('ParentId', lstOrgAccToInsert[0].Id);
        mapAccountToInsert.put('UUID__c', 'account-uuid2');
        lstAccToInsert.addAll(TestingUtility.getAccountsByType(mapAccountToInsert, 'Org', 1));
        
        mapAccountToInsert.put('UUID__c', 'account-uuid0');
        mapAccountToInsert.put('ParentId', lstOrgAccToInsert[1].Id);
        lstAccToInsert.addAll(TestingUtility.getAccountsByType(mapAccountToInsert, 'Org', 1));
        
        mapAccountToInsert.put('UUID__c', 'account-uuid1');
        mapAccountToInsert.put('NickName__c', 'Acount 2 NickName');
        mapAccountToInsert.put('ParentId', lstOrgAccToInsert[0].Id);
        lstAccToInsert.addAll(TestingUtility.getAccountsByType(mapAccountToInsert, 'Sales', 1));
        
        TestingUtility.insertListWithAssert(lstAccToInsert);       
        
        List<Contact> lstContToInsertforPrimaryMember = new List<Contact>();
        Contact conObjectBill1 = new Contact();     // has billing Account  
        conObjectBill1.FirstName = 'Bill1';
        conObjectBill1.LastName  = 'PrmaryMember';
        conObjectBill1.Email = 'testContactBill129062018K1@example.com'; 
        conObjectBill1.AccountId = lstAccToInsert[0].Id;//acc3
        lstContToInsertforPrimaryMember.add(conObjectBill1);
        
        Contact conObjectBill2 = new Contact();     // has billing Account  
        conObjectBill2.FirstName = 'Bill2';
        conObjectBill2.LastName  = 'PrmaryMember';
        conObjectBill2.Email = 'testContactBill229062018K2@example.com'; 
        conObjectBill2.AccountId = lstAccToInsert[1].Id;//acc3
        lstContToInsertforPrimaryMember.add(conObjectBill2);
        TestingUtility.insertListWithAssert(lstContToInsertforPrimaryMember);
        
        Billing_Account__c billAcc1 = new Billing_Account__c(
            name = 'Test Billing Account 1',
            Parent_Account__c = lstAccToInsert[0].Id,//acc3
            Primary_Member__c = conObjectBill1.Id
        );
        Billing_Account__c billAcc2 = new Billing_Account__c(
            name = 'Test Billing Account 2',
            Parent_Account__c = lstAccToInsert[1].Id, //acc4
            Primary_Member__c = conObjectBill2.Id
        );
        List<Billing_Account__c> lstBillAcc=new List<Billing_Account__c>();
        lstBillAcc.add(billAcc1);
        lstBillAcc.add(billAcc2);
        TestingUtility.insertListWithAssert(lstBillAcc);   
        
        List<Contact> lstContToInsert = new List<Contact>();
        Contact conObject = new Contact();     //has Bill1 billing Account  
        conObject.FirstName = 'Bill1';
        conObject.LastName  = 'Member';
        conObject.Email = 'testContact29062018K1@example.com'; 
        conObject.AccountId = lstAccToInsert[0].Id;//acc3
        conObject.Billing_Account__c = billAcc1.Id;  
        lstContToInsert.add(conObject);
        
        Contact conObject2 = new Contact(); 
        conObject2.FirstName = 'Bill2';
        conObject2.LastName  = 'Member';
        conObject2.Email = 'testContactBill129062018K10@example.com'; 
        conObject2.AccountId = lstAccToInsert[0].Id;//acc3
        conObject2.Billing_Account__c = billAcc2.Id;  
        lstContToInsert.add(conObject2);
        TestingUtility.insertListWithAssert(lstContToInsert); 
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Opportunity oppRec1 = new Opportunity();//bill1 Opportunity having acc3 org and Top Level acc1.
        oppRec1.Name = 'Bill 1 Opportunity';
        oppRec1.Primary_Member__c = conObjectBill1.Id;                
        oppRec1.AccountId = lstAccToInsert[0].Id;
        oppRec1.StageName = 'selling';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.LeadSource = 'WeWork.com';
        oppRec1.Billing_Account__c = billAcc1.Id;
        lstOpportunity.add(oppRec1);   
        
        Opportunity oppRec2 = new Opportunity();//bill2 Opportunity having acc4 org and Top Level acc2.
        oppRec2.Name = 'Bill 2 Opportunity';
        oppRec2.Primary_Member__c = conObjectBill2.Id;                
        oppRec2.AccountId = lstAccToInsert[1].Id;
        oppRec2.StageName = 'selling';
        oppRec2.CloseDate = system.today().addDays(5);
        oppRec2.LeadSource = 'WeWork.com';
        oppRec2.Billing_Account__c = billAcc2.Id;
        lstOpportunity.add(oppRec2);
        TestingUtility.insertListWithAssert(lstOpportunity); 
        
        List<Account> lstAccount = [Select Id,Name,Parent_Org_Id__c From Account Where Id IN : lstAccToInsert];
        List<Opportunity> lstOpportunityInserted = [Select Id,AccountId,Primary_Member__c,Account.Parent_Org_Id__c,Billing_Account__c From Opportunity Where Id IN : lstOpportunity];
        System.assertEquals(2,lstOpportunityInserted.size());
        System.assertEquals(3,lstAccount.size());
        System.assertEquals(lstAccount[0].Id,lstOpportunityInserted[0].AccountId);
        System.assertEquals(lstAccount[0].Parent_Org_Id__c,lstOpportunityInserted[0].Account.Parent_Org_Id__c);
        System.assertEquals(lstAccount[1].Id,lstOpportunityInserted[1].AccountId);
        System.assertEquals(lstAccount[1].Parent_Org_Id__c,lstOpportunityInserted[1].Account.Parent_Org_Id__c);
        
        lstOpportunityInserted[0].AccountId = lstAccToInsert[2].Id;  //same hierarchy with billing account 
        lstOpportunityInserted[1].AccountId = lstAccToInsert[0].Id;  //No change becuase acc4 is outside of org.
        
        try{
            Test.startTest();
            Database.update(lstOpportunityInserted,false);
            Test.stopTest();
        }catch(Exception pEx){
            Debug.log('pEx==>'+pEx);
            System.assert(pEx.getMessage().contains('Reparenting is allowed only within the same org hierarchy.'));             
        }
        
        List<Opportunity> lstOpportunityUpdated2 = [Select Id,AccountId,Primary_Member__c,Account.Parent_Org_Id__c,Billing_Account__c From Opportunity Where Id IN : lstOpportunityInserted];
        System.assertEquals(lstAccToInsert[2].Id,lstOpportunityUpdated2[0].AccountId);
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This Method is used to verify reparenting of opportunity on different org.
        Created Date        :   18 July 2018       
    **************************************************************************************************************************************/    
    public static testmethod void verifyReparentOpportunityWithPrimaryMember(){        
        List<Account> lstOrgAccToInsert = new List<Account>();
        List<Account> lstAccToInsert = new List<Account>();
        
        lstOrgAccToInsert.add(new Account(Name = 'Org Account1', UUID__c = 'account-uuid-Org', Account_Type__c = 'Org'));
        lstOrgAccToInsert.add(new Account(Name = 'Org Account2', UUID__c = 'account-uuid-Org2', Account_Type__c = 'Org'));
        TestingUtility.insertListWithAssert(lstOrgAccToInsert);//acc1 and acc2 are top level org Accounts.
        
        lstAccToInsert.add(new Account(Name = 'Account 2', UUID__c = 'account-uuid1', ParentId = lstOrgAccToInsert[0].Id, Account_Type__c = 'Sales', NickName__c = 'Acount 2 NickName'));
        lstAccToInsert.add(new Account(Name = 'Account 1', UUID__c = 'account-uuid0', ParentId = lstOrgAccToInsert[1].Id, Account_Type__c = 'Org'));  
        lstAccToInsert.add(new Account(Name = 'Account 3', UUID__c = 'account-uuid2', ParentId = lstOrgAccToInsert[0].Id, Account_Type__c = 'Org')); 
        TestingUtility.insertListWithAssert(lstAccToInsert);
        
        List<Contact> lstContToInsertforPrimaryMember = new List<Contact>();
        Contact conObjectBill1 = new Contact();     // has billing Account  
        conObjectBill1.FirstName = 'Bill1';
        conObjectBill1.LastName  = 'Primary Member';
        conObjectBill1.Email = 'testContactBill129062018K1@example.com'; 
        conObjectBill1.AccountId = lstAccToInsert[0].Id;//acc3
        lstContToInsertforPrimaryMember.add(conObjectBill1);
        
        TestingUtility.insertListWithAssert(lstContToInsertforPrimaryMember);
        
        List<Billing_Account__c> lstBillAcc=new List<Billing_Account__c>();
        lstBillAcc.add(new Billing_Account__c(name = 'Test Billing Account 1', Parent_Account__c = lstAccToInsert[0].Id, Primary_Member__c = conObjectBill1.Id));
        lstBillAcc.add(new Billing_Account__c(name = 'Test Billing Account 2', Parent_Account__c = lstAccToInsert[1].Id, Primary_Member__c = conObjectBill1.Id));
        TestingUtility.insertListWithAssert(lstBillAcc);   
        
        conObjectBill1.Billing_Account__c = lstBillAcc[1].Id;
        TestingUtility.updateWithAssert(conObjectBill1);
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Opportunity oppRec1 = new Opportunity();//bill1 Opportunity having acc3 org and Top Level acc1.
        oppRec1.Name = 'Bill 1 Opportunity';
        oppRec1.Primary_Member__c = conObjectBill1.Id;                
        oppRec1.AccountId = lstAccToInsert[0].Id;
        oppRec1.StageName = 'selling';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.LeadSource = 'WeWork.com';
        oppRec1.Billing_Account__c = lstBillAcc[0].Id;
        lstOpportunity.add(oppRec1);   
        TestingUtility.insertListWithAssert(lstOpportunity); 
        
        List<Account> lstAccount = [Select Id,Name,Parent_Org_Id__c From Account Where Id IN : lstAccToInsert];
        List<Opportunity> lstOpportunityInserted = [Select Id,AccountId,Primary_Member__c,Account.Parent_Org_Id__c,Billing_Account__c From Opportunity Where Id IN : lstOpportunity];
        
        System.assertEquals(1,lstOpportunityInserted.size());
        System.assertEquals(3,lstAccount.size());
        System.assertEquals(lstAccount[0].Id,lstOpportunityInserted[0].AccountId);
        System.assertEquals(lstAccount[0].Parent_Org_Id__c,lstOpportunityInserted[0].Account.Parent_Org_Id__c);
        
        lstOpportunityInserted[0].AccountId = lstAccToInsert[2].Id;  //same hierarchy with billing account but multiple primary member 
        
        try{
            Test.startTest();
            Database.update(lstOpportunityInserted,false);
            Test.stopTest();
        }catch(Exception pEx){
            Debug.log('pEx==>'+pEx);
            System.assert(pEx.getMessage().contains('Main contact of this Opportunity is a primary member or Member'));             
        }        
        List<Opportunity> lstOpportunityUpdated2 = [Select Id,AccountId,Primary_Member__c,Account.Parent_Org_Id__c,Billing_Account__c From Opportunity Where Id IN : lstOpportunityInserted];
        System.assertEquals(lstAccToInsert[2].Id,lstOpportunityUpdated2[0].AccountId); 
        System.assertNotEquals(lstAccToInsert[0].Id,lstOpportunityUpdated2[0].AccountId);
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This Method is used to verify reparenting of opportunity on different org.
        Created Date        :   19 July 2018       
    **************************************************************************************************************************************/    
    public static testmethod void verifyReparentOpportunityOutSideOrg(){         
        List<Account> lstOrgAccToInsert = new List<Account>();
        List<Account> lstAccToInsert = new List<Account>();
                                  
        lstOrgAccToInsert.add(new Account(Name = 'Org Account1', UUID__c = 'account-uuid-Org', Account_Type__c = 'Org'));
        lstOrgAccToInsert.add(new Account(Name = 'Org Account2', UUID__c = 'account-uuid-Org2', Account_Type__c = 'Org'));
        TestingUtility.insertListWithAssert(lstOrgAccToInsert);
        
        lstAccToInsert.add(new Account(Name = 'Account 2', UUID__c = 'account-uuid1', ParentId = lstOrgAccToInsert[0].Id, Account_Type__c = 'Sales', NickName__c = 'Acount 2 NickName'));
        lstAccToInsert.add(new Account(Name = 'Account 1', UUID__c = 'account-uuid0', ParentId = lstOrgAccToInsert[1].Id, Account_Type__c = 'Org'));  
        lstAccToInsert.add(new Account(Name = 'Account 3', UUID__c = 'account-uuid2', ParentId = lstOrgAccToInsert[1].Id, Account_Type__c = 'Org')); 
        TestingUtility.insertListWithAssert(lstAccToInsert);
        
        Contact conObjectBill1 = new Contact();     // has billing Account  
        conObjectBill1.FirstName = 'Bill1';
        conObjectBill1.LastName  = 'Primary Member';
        conObjectBill1.Email = 'testContactBill129062018K1@example.com'; 
        conObjectBill1.AccountId = lstAccToInsert[0].Id;
        TestingUtility.insertWithAssert(conObjectBill1);
        
        Billing_Account__c billAcc1 = new Billing_Account__c(
            name = 'Test Billing Account 1',
            Parent_Account__c = lstAccToInsert[0].Id,
            Primary_Member__c = conObjectBill1.Id
        );
        Billing_Account__c billAcc2 = new Billing_Account__c(
            name = 'Test Billing Account 2',
            Parent_Account__c = lstAccToInsert[1].Id         
        );
        List<Billing_Account__c> lstBillAcc=new List<Billing_Account__c>();
        lstBillAcc.add(billAcc1);
        lstBillAcc.add(billAcc2);
        TestingUtility.insertListWithAssert(lstBillAcc); 
        
       
        Opportunity oppRec1 = new Opportunity();//bill1 Opportunity having acc3 org and Top Level acc1.
        oppRec1.Name = 'Bill 1 Opportunity';
        oppRec1.Primary_Member__c = conObjectBill1.Id;                
        oppRec1.AccountId = lstAccToInsert[0].Id;
        oppRec1.StageName = 'selling';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.LeadSource = 'WeWork.com';
        oppRec1.Billing_Account__c = billAcc1.Id;        
        TestingUtility.insertWithAssert(oppRec1);   
        
        List<Account> lstAccount = [Select Id, Name, Parent_Org_Id__c From Account Where Id IN : lstAccToInsert];
        List<Opportunity> lstOpportunityInserted = [Select Id, AccountId, Primary_Member__c, Account.Parent_Org_Id__c, Billing_Account__c From Opportunity Where Id =: oppRec1.Id];
        System.assertEquals(1,lstOpportunityInserted.size());
        System.assertEquals(3,lstAccount.size());
        System.assertEquals(lstAccount[0].Id,lstOpportunityInserted[0].AccountId);
        System.assertEquals(lstAccount[0].Parent_Org_Id__c,lstOpportunityInserted[0].Account.Parent_Org_Id__c);
        
        lstOpportunityInserted[0].AccountId = lstAccToInsert[1].Id;  //same hierarchy with billing account but multiple primary member 
       
        try{
            Test.startTest();
            Database.update(lstOpportunityInserted[0],false);
            Test.stopTest();
        }catch(Exception pEx){            
            System.assert(pEx.getMessage().contains('Reparenting is allowed only within the same org hierarchy.'));             
        }        
        List<Opportunity> lstOpportunityUpdated2 = [Select Id, AccountId, Primary_Member__c,Account.Parent_Org_Id__c,Billing_Account__c From Opportunity Where Id =: lstOpportunityInserted[0].Id];
        System.assertNotEquals(lstAccToInsert[1].Id, lstOpportunityUpdated2[0].AccountId); 
     }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This Method is used to verify reparenting of opportunity on different org.
        Created Date        :   19 July 2018       
    **************************************************************************************************************************************/    
    public static testmethod void verifyReparentOpportunityOutSideOrgWithPrimaryMember(){          
        List<Account> lstOrgAccToInsert = new List<Account>();
        List<Account> lstAccToInsert = new List<Account>();
        Account acc1 = new Account(       
            Name = 'Org Account1',
            UUID__c = 'account-uuid-Org',            
            Account_Type__c = 'Org'
        );
        Account acc2 = new Account(       
            Name = 'Org Account2',
            UUID__c = 'account-uuid-Org2',            
            Account_Type__c = 'Org'
        );                                
        lstOrgAccToInsert.add(acc1);
        lstOrgAccToInsert.add(acc2);
        TestingUtility.insertListWithAssert(lstOrgAccToInsert);//acc1 and acc2 are top level org Accounts.
        
        Account acc3 = new Account(       
            Name = 'Account 2',
            UUID__c = 'account-uuid1',
            ParentId = lstOrgAccToInsert[0].Id,        
            Account_Type__c = 'Sales',
            NickName__c = 'Acount 2 NickName'
        );
        
        Account acc4 = new Account(       
            Name = 'Account 1',
            UUID__c = 'account-uuid0',            
            ParentId = lstOrgAccToInsert[1].Id,
            Account_Type__c = 'Org'
            
        );
        
        Account acc5 = new Account(       
            Name = 'Account 3',
            UUID__c = 'account-uuid2',
            ParentId = lstOrgAccToInsert[1].Id,        
            Account_Type__c = 'Org'
        );     
        //acc3 and acc5 are belongs to acc1 org.
        //acc4 is belongs to acc2 org.             
        
        lstAccToInsert.add(acc3);
        lstAccToInsert.add(acc4);  
        lstAccToInsert.add(acc5); 
        TestingUtility.insertListWithAssert(lstAccToInsert);
        
        Contact conObjectBill1 = new Contact();     // has billing Account  
        conObjectBill1.FirstName = 'Bill1';
        conObjectBill1.LastName  = 'Primary Member';
        conObjectBill1.Email = 'testContactBill129062018K1@example.com'; 
        conObjectBill1.AccountId = lstAccToInsert[0].Id;//acc3
        TestingUtility.insertWithAssert(conObjectBill1);
        
        Billing_Account__c billAcc1 = new Billing_Account__c(
            name = 'Test Billing Account 1',
            Parent_Account__c = lstAccToInsert[0].Id,//acc3
            Primary_Member__c = conObjectBill1.Id
        );
        Billing_Account__c billAcc2 = new Billing_Account__c(
            name = 'Test Billing Account 2',
            Parent_Account__c = lstAccToInsert[1].Id, //acc4
            Primary_Member__c = conObjectBill1.Id
        );
        List<Billing_Account__c> lstBillAcc=new List<Billing_Account__c>();
        lstBillAcc.add(billAcc1);
        lstBillAcc.add(billAcc2);
        TestingUtility.insertListWithAssert(lstBillAcc); 
        
        Opportunity oppRec1 = new Opportunity();//bill1 Opportunity having acc3 org and Top Level acc1.
        oppRec1.Name = 'Bill 1 Opportunity';
        oppRec1.Primary_Member__c = conObjectBill1.Id;                
        oppRec1.AccountId = acc3.Id;
        oppRec1.StageName = 'selling';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.LeadSource = 'WeWork.com';        
        TestingUtility.insertWithAssert(oppRec1);   
        
        List<Account> lstAccount = [Select Id, Name, Parent_Org_Id__c From Account Where Id IN : lstAccToInsert];
        List<Opportunity> lstOpportunityInserted = [Select Id, AccountId,Primary_Member__c, Account.Parent_Org_Id__c, Billing_Account__c From Opportunity Where Id =: oppRec1.Id];
        System.assertEquals(1,lstOpportunityInserted.size());
        System.assertEquals(3,lstAccount.size());
        System.assertEquals(lstAccount[0].Id, lstOpportunityInserted[0].AccountId);
        System.assertEquals(lstAccount[0].Parent_Org_Id__c, lstOpportunityInserted[0].Account.Parent_Org_Id__c);
        
        lstOpportunityInserted[0].AccountId = acc4.Id;  //same hierarchy without billing account but multiple primary member 
       
        try{
            Test.startTest();
            Database.update(lstOpportunityInserted[0], false);
            Test.stopTest();
        }catch(Exception pEx){            
            System.assert(pEx.getMessage().contains('Main contact of this Opportunity is'));             
        }        
        List<Opportunity> lstOpportunityUpdated2 = [Select Id, AccountId,Primary_Member__c, Account.Parent_Org_Id__c, Billing_Account__c From Opportunity Where Id =: lstOpportunityInserted[0].Id];
        System.assertNotEquals(acc4.Id,lstOpportunityUpdated2[0].AccountId); 
        System.assertEquals(acc3.Id,lstOpportunityUpdated2[0].AccountId);
    }
    
    /************************************************************************************************************************************
        Author              :  Shivprasad Patil
        Description         :  This method will update broker account on opportunity if referrer contact is populated.
        Created Date        :  19 July 2018
    **************************************************************************************************************************************/
    static testMethod void testUpdateBrokerAccount(){ 
        Map<String,Object> mapAccountFieldValues = new Map<String,Object>();
        List<Account> lstAccounts = new List<Account>();
        mapAccountFieldValues.put('Name', 'Test Org 1');
        mapAccountFieldValues.put('Account_Type__c', 'Org');
        lstAccounts.add(TestingUtility.createAccount(mapAccountFieldValues,false));
        TestingUtility.insertListWithAssert(lstAccounts);
        
        mapAccountFieldValues.clear();
        mapAccountFieldValues.put('AccountId', lstAccounts[0].Id);
        Contact conRec = TestingUtility.createContact(mapAccountFieldValues,true); 
        
        mapAccountFieldValues.clear();
        mapAccountFieldValues.put('Primary_Member__c', conRec.Id);
        mapAccountFieldValues.put('Amount', 150);
        Opportunity oppRec = TestingUtility.createOpportunity(mapAccountFieldValues, true);
        
        oppRec = [SELECT Id,Referrer_Account__c FROM Opportunity WHERE Id = :oppRec.Id];
        system.assertEquals(null, oppRec.Referrer_Account__c);
        
        opprec.Referrer__c = conRec.Id;
        update opprec;
        
        oppRec = [SELECT Id,Referrer_Account__c FROM Opportunity WHERE Id = :oppRec.Id];
        system.assertEquals(lstAccounts[0].id, oppRec.Referrer_Account__c);
    }
    /************************************************************************************************************************************
        Author              :   Ashish Mishra
        Description         :   This Test method used to verify the 'set Broker Involved to true' functionality
        Created Date        :   30 Aug 2018    
        Issue No            :   ST-2740 
    **************************************************************************************************************************************/    
    static testMethod void testSetBrokerInvolved(){
        //Positive Senario 
        Map<String,Object> mapAccountFieldValues = new Map<String,Object>();
        List<Account> lstAccounts = new List<Account>();
        mapAccountFieldValues.put('Name', 'Test Org 1');
        mapAccountFieldValues.put('Account_Type__c', 'Org');
        lstAccounts.add(TestingUtility.createAccount(mapAccountFieldValues, false));
        TestingUtility.insertListWithAssert(lstAccounts);
        
        mapAccountFieldValues.clear();
        mapAccountFieldValues.put('AccountId', lstAccounts[0].Id);
        //Contact
        Contact conRec = TestingUtility.createContact(mapAccountFieldValues, true); 
        //Opportunity
        List<Opportunity> lstOpp = new List<Opportunity>();
        mapAccountFieldValues.clear();
        mapAccountFieldValues.put('AccountId',lstAccounts[0].Id);
        mapAccountFieldValues.put('Primary_Member__c',conRec.Id);
        mapAccountFieldValues.put('Amount',150);
        mapAccountFieldValues.put('LeadSource','Broker Referral');
        mapAccountFieldValues.put('Referrer__c',conRec.Id);
        mapAccountFieldValues.put('Broker_Involved__c',false);
        lstOpp.add(TestingUtility.createOpportunity(mapAccountFieldValues, false));            
        mapAccountFieldValues.clear();
        mapAccountFieldValues.put('AccountId',lstAccounts[0].Id);
        mapAccountFieldValues.put('Primary_Member__c',conRec.Id);
        mapAccountFieldValues.put('Amount',250);
        mapAccountFieldValues.put('LeadSource','Broker Referral');
        mapAccountFieldValues.put('Referrer__c',conRec.Id);
        mapAccountFieldValues.put('Broker_Involved__c',false);        
        lstOpp.add(TestingUtility.createOpportunity(mapAccountFieldValues, false));            
        mapAccountFieldValues.clear();
        mapAccountFieldValues.put('AccountId',lstAccounts[0].Id);
        mapAccountFieldValues.put('Primary_Member__c',conRec.Id);
        mapAccountFieldValues.put('Amount',270);
        mapAccountFieldValues.put('LeadSource','Broker Referral');
        mapAccountFieldValues.put('Referrer__c',conRec.Id);
        mapAccountFieldValues.put('Broker_Involved__c',false);        
        lstOpp.add(TestingUtility.createOpportunity(mapAccountFieldValues, false));            
        TestingUtility.insertListWithAssert(lstOpp);
        System.debug('List of Opportunity ==>'+lstOpp);
        
        for(Opportunity objOpportunity : [SELECT Id,Name,Broker_Involved__c,Broker_Involvement_Indicated__c From Opportunity Where AccountId=:lstAccounts[0].Id]){
            System.assert(objOpportunity.Broker_Involvement_Indicated__c == 'Yes', 'Broker_Involvement_Indicated__c is not Yes') ;
        }       
    }
    
    /************************************************************************************************************************************
        Author              :   Ashish Mishra
        Description         :   This Test method used to verify the 'set Broker Involved to true' functionality
        Created Date        :   30 Aug 2018    
        Issue No            :   ST-2740
    **************************************************************************************************************************************/    
    static testMethod void testSetBrokerInvolved2(){
        //Negative Senario : When Lead source is not match as Member Referral
        Map<String,Object> mapAccountFieldValues = new Map<String,Object>();
        List<Account> lstAccounts = new List<Account>();
        mapAccountFieldValues.put('Name', 'Test Org 1');
        mapAccountFieldValues.put('Account_Type__c', 'Org');
        lstAccounts.add(TestingUtility.createAccount(mapAccountFieldValues, false));
        TestingUtility.insertListWithAssert(lstAccounts);        
        System.debug('lstAccounts ==>'+lstAccounts);
        
        mapAccountFieldValues.clear();
        mapAccountFieldValues.put('AccountId', lstAccounts[0].Id);
        //Contact
        Contact conRec = TestingUtility.createContact(mapAccountFieldValues, true);
        System.debug('conRec Inserted ==>'+conRec);
        
        //Opportunity
        List<Opportunity> lstOpp = new List<Opportunity>();
        mapAccountFieldValues.clear();
        mapAccountFieldValues.put('AccountId',lstAccounts[0].Id);
        mapAccountFieldValues.put('Primary_Member__c',conRec.Id);
        mapAccountFieldValues.put('Amount',150);
        mapAccountFieldValues.put('LeadSource','Member Referral');
        mapAccountFieldValues.put('Broker_Involved__c',false);
        mapAccountFieldValues.put('Broker_Involvement_Indicated__c','No');    
        lstOpp.add(TestingUtility.createOpportunity(mapAccountFieldValues, false));            
        mapAccountFieldValues.clear();
        
        mapAccountFieldValues.put('AccountId',lstAccounts[0].Id);
        mapAccountFieldValues.put('Primary_Member__c',conRec.Id);
        mapAccountFieldValues.put('Amount',250);
        mapAccountFieldValues.put('LeadSource','Member Referral');
        mapAccountFieldValues.put('Referrer__c',conRec.Id);
        mapAccountFieldValues.put('Broker_Involved__c',false);     
        mapAccountFieldValues.put('Broker_Involvement_Indicated__c','No');    
        lstOpp.add(TestingUtility.createOpportunity(mapAccountFieldValues, false));
        
        mapAccountFieldValues.clear();
        mapAccountFieldValues.put('AccountId',lstAccounts[0].Id);
        mapAccountFieldValues.put('Primary_Member__c',conRec.Id);
        mapAccountFieldValues.put('Amount',270);
        mapAccountFieldValues.put('LeadSource','Member Referral');
        mapAccountFieldValues.put('Referrer__c',conRec.Id);
        mapAccountFieldValues.put('Broker_Involved__c',false);    
        mapAccountFieldValues.put('Broker_Involvement_Indicated__c','No');    
        lstOpp.add(TestingUtility.createOpportunity(mapAccountFieldValues, false));            
        TestingUtility.insertListWithAssert(lstOpp);
        
        System.debug('List of Opportunity ==>'+lstOpp);
        System.debug('List of Opportunity.Broker_Involved__c ==>'+lstOpp[0].Broker_Involved__c);        
        
        for(Opportunity objOpportunity : [SELECT Id,Name,Broker_Involved__c,Broker_Involvement_Indicated__c From Opportunity Where AccountId=:lstAccounts[0].Id]){
            System.assert(objOpportunity.Broker_Involvement_Indicated__c == 'No', 'Broker_Involvement_Indicated__c is Yes') ;
        }
        
        //Negative Senario test : In time of Update Opportunity ,We have to change Referrer__c field as per Lead Source.
        mapAccountFieldValues.clear();        
        List<Account> lstAccountList2 = new List<Account>();
        mapAccountFieldValues.put('Name', 'Test Org 2');
        mapAccountFieldValues.put('Account_Type__c', 'Org');
        lstAccountList2.add(TestingUtility.createAccount(mapAccountFieldValues, false));
        TestingUtility.insertListWithAssert(lstAccountList2);        
        System.debug('lstAccountList2 ==>'+lstAccountList2);
        
        mapAccountFieldValues.clear();
        mapAccountFieldValues.put('AccountId', lstAccountList2[0].Id);
        //Contact
        Contact contactRecord = TestingUtility.createContact(mapAccountFieldValues, true);
        System.debug('contactRecord Inserted ==>'+contactRecord);        
        
        List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
        for(Opportunity objOpportunity : [SELECT Id,Name,LeadSource,Broker_Involved__c,Referrer__c From Opportunity Where Referrer__c= null]){
            objOpportunity.LeadSource = 'Broker Referral';
            objOpportunity.Referrer__c = contactRecord.id;
            lstOpportunityToUpdate.add(objOpportunity);            
        }
        TestingUtility.updateListWithAssert(lstOpportunityToUpdate);
        
        for(Opportunity lstOpportunity : [SELECT Id,Name,Broker_Involved__c,Broker_Involvement_Indicated__c From Opportunity Where Id IN: lstOpportunityToUpdate]){
            System.assert(lstOpportunity.Broker_Involvement_Indicated__c == 'Yes', 'Broker_Involvement_Indicated__c is not yes') ;
        }
    }
    /************************************************************************************************************************************
        Author              :   Jitesh Adwani.
        Description         :   This method is used to test notifyTeamMemberWhenOppGetsCwOrCl function.
        Created Date        :   04 Sept 2018.
        Issue No.           :   ST-2741
    **************************************************************************************************************************************/
    @isTest
    public static void verifyNotifyTeamMemberWhenOppGetsCwOrCl(){
        List<Opportunity> lstOpportunity = [SELECT Id, Name, StageName FROM Opportunity LIMIT 2];
        List<User> userDetails = [SELECT Id, UserRole.Name FROM User LIMIT 2];      
        List<OpportunityTeamMember> lstOppTeamMember = new List<OpportunityTeamMember>();
        for(Opportunity objOpportunity : lstOpportunity){
            OpportunityTeamMember objOppTeamMember = new OpportunityTeamMember();
            objOppTeamMember.OpportunityId = objOpportunity.Id;
            objOppTeamMember.UserId = userDetails[0].Id;
            objOppTeamMember.TeamMemberRole = 'Business Development';
            lstOppTeamMember.add(objOppTeamMember);
        }
        insert lstOppTeamMember;        
        for(Opportunity objOpp : lstOpportunity){
            objOpp.StageName = 'Closed Won';
        }
        update lstOpportunity;        
        for(Opportunity objOpp : [SELECT Id, Name, StageName FROM Opportunity WHERE Id IN :lstOpportunity]){
            System.assertEquals('Closed Won', objOpp.StageName);
        }
    }
    
    /*****************************************************************************************************************************************
        Author              :   Milanjeet Singh
        Description         :   This method is used to return opportunity map values.
        Created Date        :   01 October 2018
        Issue No            :   ST-2439
    ******************************************************************************************************************************************/
     public static Map<String, Object> getOpportunityMapValues(Map<String, Object> mapOppValues, Id recordTypeId, Id contactId, Id accountId, Id userId){
        mapOppValues.put('Primary_Member__c', contactId);
        mapOppValues.put('OwnerId', userId);
        mapOppValues.put('RecordTypeId', recordTypeId);
        mapOppValues.put('AccountId', accountId);
        return mapOppValues;
    }
    
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to test SendEmailOnOwnerChange method
        Created Date        :   01 October 2018
        Issue No            :   ST-2795
    ******************************************************************************************************************************************/
    static testMethod void verifySendEmailOnOwnerChange(){
        List<User> lstUsers = new List<User>();
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        List<Profile> lstTestProfiles = [SELECT Id FROM Profile WHERE Name IN ('WeWork Regional Sales Lead - Beta','System Administrator')];
        
        lstUsers.add((User)TestingUtility.insertUserWithAssert(lstTestProfiles[0].Id, TestingUtility.getUserMapValues('testUser_001'), false));
        lstUsers.add((User)TestingUtility.insertUserWithAssert(lstTestProfiles[1].Id, TestingUtility.getUserMapValues('testUser_002'), false));
        lstUsers.add((User)TestingUtility.insertUserWithAssert(lstTestProfiles[1].Id, TestingUtility.getUserMapValues('testUser_003'), false));
        
        TestingUtility.insertListWithAssert(lstUsers);
        
        List<Account> lstAccounts = new List<Account>();
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        Map<String, Object> accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName1',
            'Account_Type__c' => 'Org',
            'RecordTypeId' =>  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId()};
        lstAccounts.addAll(TestingUtility.getAccountsByType(accountValuesMap, 'Org', 1));        
        accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName2',
            'Account_Type__c' => 'Org',
            'RecordTypeId' =>  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId()};        
        lstAccounts.addAll(TestingUtility.getAccountsByType(accountValuesMap, 'Org', 1));    
        TestingUtility.insertListWithAssert(lstAccounts);
        
        Map<String, Object> opportunityValuesMap = new Map<String, Object>{'Name' => 'John1', 'StageName' => 'Selling', 'Amount' => 150 };
            
        OpportunityValuesMap = getOpportunityMapValues(opportunityValuesMap, oppRecordType.get('Consumer'), Null, lstAccounts[1].Id, lstUsers[0].Id);
        Opportunity opp1 = (Opportunity)TestingUtility.createTestRecords(Opportunity.sObjectType, opportunityValuesMap, false);
        lstOpportunities.add(opp1);
        OpportunityValuesMap = getOpportunityMapValues(opportunityValuesMap, oppRecordType.get('Enterprise Solutions'), Null, lstAccounts[0].Id, lstUsers[0].Id);
        Opportunity opp2 = (Opportunity)TestingUtility.createTestRecords(Opportunity.sObjectType, opportunityValuesMap, false);
        lstOpportunities.add(opp2);
        opportunityValuesMap = getOpportunityMapValues(opportunityValuesMap, oppRecordType.get('Enterprise Solutions'), Null, lstAccounts[0].Id, lstUsers[1].Id);
        Opportunity opp3 = (Opportunity)TestingUtility.createTestRecords(Opportunity.sObjectType, opportunityValuesMap, false);
        lstOpportunities.add(opp3);
        TestingUtility.insertListWithAssert(lstOpportunities);
        Integer beforeInvocations = Limits.getEmailInvocations();
        system.assertEquals(0, beforeInvocations);
        
        lstOpportunities[0].OwnerId = lstUsers[1].Id;
        TestingUtility.updateWithAssert(lstOpportunities[0], 'Opportunity Not Updated');
        
        Integer afterInvocations = Limits.getEmailInvocations();
        system.assertEquals(1, afterInvocations);
        Test.startTest();
        System.runAs(lstUsers[2]){
            Integer beforeBulkInvocations = Limits.getEmailInvocations();
            system.assertEquals(0, beforeBulkInvocations);
            lstOpportunities[1].OwnerId = lstUsers[1].Id;
            lstOpportunities[2].OwnerId = lstUsers[0].Id;
            TestingUtility.updateListWithAssert(lstOpportunities);
            Integer afterBulkInvocations = Limits.getEmailInvocations();
            system.assertEquals(1, afterBulkInvocations);
        }        
        Test.stopTest();
    }
    
/************************************************************************************************************************************
  	Author              : Rohit Nimase
    Description         : This method is used to test updateOppForecastCategory method.
    Created Date        : 15 Oct 2018
	Issue No.           : ST-2750
**************************************************************************************************************************************/    
    @isTest
    public static void verifyUpdateOppForecastCategory(){
        
        List<User> lstUsers = [SELECT Id, Name, ProfileId, Sales_Role__c, Sales_Pod__c, UserRoleId  FROM User WHERE LastName = 'Last Name 1' OR LastName = 'Test User 7' OR LastName = 'Test User 8'];
        Map<String, Id> accRecordType = TestingUtility.getRecordTypeMapByName(Account.sObjectType);
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        
        Building__c objBuilding = new Building__c(City__c = 'Frankfurt', Country__c = 'Germany',Name = 'HE-Goetheplatz', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam');
        TestingUtility.insertWithAssert(objBuilding);
        
        Test.startTest();
        //For Owner
        System.runAs(lstUsers[0]){
            List<Account> lstAcc = new List<Account>();
            List<Contact> lstContacts = new List<Contact>();
            List<Opportunity> lstOpps = new List<Opportunity>();
            
            Account testAccount1 = TestingUtility.createAccount('WeWork1', false);
            testAccount1.RecordTypeId = accRecordType.get('Enterprise Solutions'); 
            lstAcc.add(testAccount1);
            Account testAccount2 = TestingUtility.createAccount('WeWork2', false);
            testAccount2.RecordTypeId = accRecordType.get('Enterprise Solutions'); 
            lstAcc.add(testAccount2);
            Account testAccount3 = TestingUtility.createAccount('WeWork3', false);
            testAccount3.RecordTypeId = accRecordType.get('Consumer');
            lstAcc.add(testAccount3);
            TestingUtility.insertListWithAssert(lstAcc);
            
            Map<String, Object> contactValuesMap = new Map<String, Object>{'FirstName' => 'John',
                'LastName' => 'Smith1',
                'Email' => 'john.smith1@example.com',
                'AccountId' => testAccount1.id };
            lstContacts.add((Contact)TestingUtility.createTestRecords(Contact.sObjectType, contactValuesMap, false));
            
            contactValuesMap.put('LastName', 'Smith2');
            contactValuesMap.put('Email', 'john.smith2@example.com');
            contactValuesMap.put('AccountId', testAccount2.id);
            lstContacts.add((Contact)TestingUtility.createTestRecords(Contact.sObjectType, contactValuesMap, false));
            
            contactValuesMap.put('LastName', 'Smith3');
            contactValuesMap.put('Email', 'john.smith3@example.com');
            contactValuesMap.put('AccountId', testAccount3.Id);
            lstContacts.add((Contact)TestingUtility.createTestRecords(Contact.sObjectType, contactValuesMap, false));
            TestingUtility.insertListWithAssert(lstContacts);
            
            Map<String, Object> opportunityValuesMap = new Map<String, Object>{'Name' => 'test oppty1', 'StageName' => 'Selling', 'Amount' => 150 };
            opportunityValuesMap = getOpportunityMapValues(opportunityValuesMap, oppRecordType.get('Enterprise Solutions'), lstContacts[0].Id, lstAcc[0].Id, lstUsers[0].Id);
            Opportunity oppRec1 = (Opportunity)TestingUtility.createTestRecords(Opportunity.sObjectType, opportunityValuesMap, false);
            lstOpps.add(oppRec1);
            
            opportunityValuesMap.put('Name', 'test oppty1');
            opportunityValuesMap.put('StageName', 'Selling');
            opportunityValuesMap.put('Amount', 250);
            opportunityValuesMap = getOpportunityMapValues(opportunityValuesMap, oppRecordType.get('Enterprise Solutions'), lstContacts[1].Id, lstAcc[1].Id, lstUsers[0].Id);
            Opportunity oppRec2 = (Opportunity)TestingUtility.createTestRecords(Opportunity.sObjectType, opportunityValuesMap, false);
            lstOpps.add(oppRec2);
            opportunityValuesMap.put('Name', 'test oppty2');
            opportunityValuesMap.put('StageName', 'Selling');
            opportunityValuesMap.put('Amount', 350);
            opportunityValuesMap = getOpportunityMapValues(opportunityValuesMap, oppRecordType.get('Consumer'), lstContacts[2].Id, lstAcc[2].Id, lstUsers[0].Id);
            Opportunity oppRec3 = (Opportunity)TestingUtility.createTestRecords(Opportunity.sObjectType, opportunityValuesMap, false);
            lstOpps.add(oppRec3);
            TestingUtility.insertListWithAssert(lstOpps);
            
            lstOpps[0].StageName = 'Negotiating';
            lstOpps[1].StageName = 'Negotiating';
            lstOpps[1].ForecastCategoryName = 'Omitted';
            lstOpps[2].Forecast_Category__c = 'Upside';
            checkAssertsForecast(Database.update(lstOpps, false)); 
            
            List<Opportunity> lstUpdatedOpportunity = [SELECT Id, Name, OwnerId, Owner.LastName, stageName, ForecastCategoryName, Forecast_Category__c FROM opportunity WHERE Account.Name = 'Wework1' OR Account.Name = 'Wework2' OR Account.Name = 'Wework3'];
            system.assertEquals('Probable', lstUpdatedOpportunity[0].Forecast_Category__c);
            system.assertEquals('Omitted', lstUpdatedOpportunity[1].Forecast_Category__c);
            system.assertEquals('Upside', lstUpdatedOpportunity[2].ForecastCategoryName);
        }
        // Not valid User
        System.runAs(lstUsers[1]){
            List<Opportunity> lstOpportunity = [SELECT Id, Name, OwnerId, Owner.LastName, stageName, ForecastCategoryName, Forecast_Category__c FROM opportunity WHERE Account.Name = 'Wework1' OR Account.Name = 'Wework2' OR Account.Name = 'Wework3'];
            Contact objContact = [SELECT Id, Name FROM Contact WHERE Email = 'john.smith3@example.com'];
            lstOpportunity[0].StageName = 'Selling';
            lstOpportunity[0].ForecastCategoryName = 'Upside';
            lstOpportunity[0].Actual_Start_Date__c = System.today().addDays(-1);
            lstOpportunity[0].Description = 'To change stage to selling' ;
            lstOpportunity[0].Requirement_Quantity__c = 100;
            lstOpportunity[0].Desired_Budget__c = 20200;
            lstOpportunity[0].Commitment_Term_in_months__c = 5;
            lstOpportunity[0].Building__c = objBuilding.Id;
            lstOpportunity[0].Decision_Maker__c = objContact.Id;
            lstOpportunity[0].CloseDate = System.today().addDays(5);
            lstOpportunity[1].Forecast_Category__c = 'Commit';
            lstOpportunity[2].Forecast_Category__c = 'Commit';
            checkAssertsForecast(Database.update(lstOpportunity, false));
            
            List<Opportunity> lstUpdatedOpportunity = [SELECT Id, Name, OwnerId, Owner.LastName, stageName, ForecastCategoryName, Forecast_Category__c FROM opportunity WHERE Account.Name = 'Wework1' OR Account.Name = 'Wework2' OR Account.Name = 'Wework3'];
            system.assertEquals('Upside', lstUpdatedOpportunity[0].Forecast_Category__c);
            system.assertEquals('Omitted', lstUpdatedOpportunity[1].Forecast_Category__c);
            system.assertEquals('Upside', lstUpdatedOpportunity[2].ForecastCategoryName);
        } 
        //Valid User Director of Sales
        System.runAs(lstUsers[2]){
            List<Opportunity> lstOpportunity = [SELECT Id, Name, OwnerId, Owner.LastName, stageName, ForecastCategoryName, Forecast_Category__c FROM opportunity WHERE Account.Name = 'Wework1' OR Account.Name = 'Wework2' OR Account.Name = 'Wework3']; 
            
            lstOpportunity[0].StageName = 'Qualifying';
            lstOpportunity[1].StageName = 'Qualifying';
            lstOpportunity[1].Forecast_Category__c = 'Closed';  
            lstOpportunity[2].Forecast_Category__c = 'Closed';
            checkAssertsForecast(Database.update(lstOpportunity, false));
            
            List<Opportunity> lstUpdatedOpportunity = [SELECT Id, Name, OwnerId, Owner.LastName, stageName, ForecastCategoryName, Forecast_Category__c FROM opportunity WHERE Account.Name = 'Wework1' OR Account.Name = 'Wework2' OR Account.Name = 'Wework3'];
            system.assertEquals('Upside', lstUpdatedOpportunity[0].Forecast_Category__c);
            system.assertEquals('Closed', lstUpdatedOpportunity[1].Forecast_Category__c);
            system.assertEquals('Upside', lstUpdatedOpportunity[2].ForecastCategoryName);
        } 
        Test.stopTest();
    }

/************************************************************************************************************************************
  	Author              : Rohit Nimase
    Description         : This method is used to check asserts for verifyUpdateOppForecastCategory method.
    Created Date        : 15 Oct 2018
	Issue No.           : ST-2750
**************************************************************************************************************************************/    
    public static void checkAssertsForecast(List<Database.SaveResult> lstResult){
        String errorMessage = 'Opportunity Owner can modify custom Forecast Category field for any record type and Director of Sales can modify this field for Enterprise Solutions Opportunity.';
        for(Database.SaveResult result : lstResult){
            if(result.isSuccess()){
                System.assert(result.isSuccess());
            }else{
                for(Database.Error error : result.getErrors()) {
                    System.assertEquals(true, errorMessage.equalsIgnoreCase(error.getMessage()), 'checking valid User'); 
                }
            }
        }
    }
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to test notifyEmailAlertToReferralTeam method
        Created Date        :   31 October 2018
        Issue No            :   ST-2824
    ******************************************************************************************************************************************/
    static testMethod void testNotifyEmailAlertToReferralTeam(){
        List<User> lstUsers = new List<User>();
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        List<Profile> lstTestProfiles = [SELECT Id FROM Profile WHERE Name IN ('WeWork Regional Sales Lead - Beta','System Administrator')];
        lstUsers.add((User)TestingUtility.insertUserWithAssert(lstTestProfiles[0].Id, TestingUtility.getUserMapValues('testUser_001'), false));
        TestingUtility.insertListWithAssert(lstUsers);
        
        List<Account> lstAccounts = new List<Account>();
        List<Contact> lstContacts = new List<Contact>();
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        Map<String, Object> accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName1',
            'Account_Type__c' => 'Org',
            'RecordTypeId' =>  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId()};
        lstAccounts.addAll(TestingUtility.getAccountsByType(accountValuesMap, 'Org', 1));        
        accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName2',
            'Account_Type__c' => 'Org',
            'RecordTypeId' =>  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId()};        
        lstAccounts.addAll(TestingUtility.getAccountsByType(accountValuesMap, 'Org', 1));    
        TestingUtility.insertListWithAssert(lstAccounts);
        
        Map<String, Object> contactValuesMap = new Map<String, Object>{'LastName' => 'strContactName1', 'AccountId' => lstAccounts[1].Id};
        lstContacts.add(TestingUtility.createContact(contactValuesMap, false));
        contactValuesMap = new Map<String, Object>{'LastName' => 'strContactName2', 'AccountId' => lstAccounts[1].Id};
        lstContacts.add(TestingUtility.createContact(contactValuesMap, false));
        TestingUtility.insertListWithAssert(lstContacts);
        
        Map<String, Object> opportunityValuesMap = new Map<String, Object>{'Name' => 'John1', 'StageName' => 'Selling', 'Amount' => 150, 'Opportunity_Referral_Type__c' => 'Retroactive Referral', 'Referral_Status__c' => 'Pending'};
        OpportunityValuesMap = getOpportunityMapValues(opportunityValuesMap, oppRecordType.get('Consumer'), Null, lstAccounts[1].Id, lstUsers[0].Id);
        Opportunity opp1 = (Opportunity)TestingUtility.createTestRecords(Opportunity.sObjectType, opportunityValuesMap, false);
        lstOpportunities.add(opp1);
        OpportunityValuesMap = getOpportunityMapValues(opportunityValuesMap, oppRecordType.get('Enterprise Solutions'), Null, lstAccounts[0].Id, lstUsers[0].Id);
        Opportunity opp2 = (Opportunity)TestingUtility.createTestRecords(Opportunity.sObjectType, opportunityValuesMap, false);
        lstOpportunities.add(opp2);
        TestingUtility.insertListWithAssert(lstOpportunities);
        Integer beforeInvocations = Limits.getEmailInvocations();
        system.assertEquals(0, beforeInvocations);
        lstOpportunities[0].Referrer__c = lstContacts[1].Id;
        lstOpportunities[0].Referral_Status__c = 'Pending';
        Update lstOpportunities[0];
        Integer afterInvocations = Limits.getEmailInvocations();
      
    }
}