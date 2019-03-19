@isTest
private class RESTInboundLeadTest {
    static Boolean settingsInitialized = false;
    static LeadConvertor.JourneySettings settingJourney;
    static {
        SalesConsoleSettings.createSettings();
    }
    /*static void initFieldMappings() {
        //Debug.turnDebugOn();

        if( settingsInitialized )
            return;
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork Standard User'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 1');
        userRecordMap.put('Username','testweworkuser1@example.com');
        userRecordMap.put('Email','testweworkuser1@example.com');
        User testUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true); 
        
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'Lead:Lead and Lead Source Details';
        testSettings.Data__c = '{"LeadSource":[{"name":"Broker","OverrideLeadSoruce":true}], "LeadSourceDetails":["Broker1","Broker2" ]}]';
        TestingUtility.insertWithAssert(testSettings);
        
        testSettings = new Setting__c();
        testSettings.Name = 'User/Queue Journey Creation';
        testSettings.Data__c = '{"allowedUsers":[{"userName":"'+ testUser.Username +'","Id":"'+testUser.Id +'"}],"allowedQueues":[]}';
        TestingUtility.insertWithAssert(testSettings);
        
        
        Account account = new Account(Name = 'Dummy Lead Conversion Account');
        insert account;
        
        settingsInitialized = true;
    }
    @isTest static void test_post_success_1() {
        
        //pre-context
        initFieldMappings();
        Debug.turnDebugOn();
        
        //test
        Test.startTest();
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      Market__c market1 = new Market__c();
        market1.Name = 'Amsterdam';
        market1.Email__c = 'amsterdammarket1@example.com';
        market1.UUID__c = 'test-market-uuid1';
      TestingUtility.insertWithAssert(market1);
      
      Market__c market2 = new Market__c();
        market2.Name = 'Atlanta';
        market2.Email__c = 'atlantamarket2@example.com';
        market2.UUID__c = 'test-market-uuid2';
      TestingUtility.insertWithAssert(market2);
      // pass the req and resp objects to the method         
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/InboundLead';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            Campaign c = new Campaign(Name='Test Campaign');
            insert c;
            //define container and set request Company and Reservable UUIDs
            WWTypes.InboundLead j = new WWTypes.InboundLead();
            j.company_name = 'A company';
            j.last_name = 'Doe';
            j.first_name = 'John';
            j.email = 'exampleTest@test.com';
            j.campaign_sfid = c.Id;
            j.locale ='en-US';
            j.generate_journeys = false;
            j.phone = '0321456987';
            j.lead_source = 'test';
            j.lead_source_detail = 'test';
            j.lead_type = 'Office Space';
            j.Product_Interests = new List<String>{'Office Space','Residential Space'};
            j.market_uuids = new List<String>{market1.UUID__c, market2.UUID__c};
            j.company_size = '21-50';
            
            //submit post
            RESTInboundLead.Response response = RESTInboundLead.doPost(j);
        Debug.Log('response---'+response);
            //confirm response
            system.assertEquals(true, response.success);

            Lead[] Ks = [   SELECT id, Phone, Interested_in_Number_of_Desks__c
                                        FROM Lead 
                                        WHERE email = :j.email
                                        LIMIT 1
                                    ];
            system.assertEquals(
                1,
                Ks.size(),
                'A lead should be created'
            );
            
            System.assertEquals(21, Ks[0].Interested_in_Number_of_Desks__c);

            Task[] Ts = [ SELECT id
                                    FROM Task
                                    WHERE WhoId = :Ks[0].id
                                    LIMIT 1
                                ];

            system.assertEquals(
                1,
                Ts.size(),
                'A task associated to the lead should be created'
            ); 
        
            List<Lead> leads = [ SELECT Id FROM Lead WHERE Id IN (SELECT LeadId FROM CampaignMember WHERE CampaignId =: c.Id AND LeadId != null) ];
            system.assertEquals(
                1,
                leads.size(),
                'A Lead associated to the Campaign should be created'
            );
        Test.stopTest();
    }
       
    @isTest static void test_post_success_2() {
        //pre-context
        
        //test
        Test.startTest();
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/InboundLead';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            Campaign c = new Campaign(Name='Test Campaign');
            insert c;
            //define container and set request Company and Reservable UUIDs
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            
            //submit post
            RESTInboundLead.Response response = RESTInboundLead.doPost(j);

        Test.stopTest();
    }
    
    //Anant Kumar on 9th May 2016
    //UseCase : If lead is exists with given email id;
    @isTest static void test_post_success_3() {
        //pre-context

        //test
        Test.startTest();
            RestRequest req     = new RestRequest(); 
          RestResponse res    = new RestResponse();
      
          // pass the req and resp objects to the method         
          req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/InboundLead';  
          req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            Campaign c = new Campaign(Name='Test Campaign');
            insert c;
            Account accRec = TestingUtility.createAccount('strAccountName', true);
            Contact referrerContact = TestingUtility.createContact(accRec.Id, 'strLastName', false);
          referrerContact.Email = 'testreferrer@example.com';
          TestingUtility.insertWithAssert(referrerContact);

            Lead leadRec1 = new Lead();
            leadRec1.LastName = 'Test Lead';
            leadRec1.Company = 'test123';
            leadRec1.Status = 'Open';
            leadRec1.LeadSource = 'wework.com';
            leadRec1.Email = 'test.lead@test123.com';
            Database.SaveResult result = TestingUtility.insertWithAssert(leadRec1);
          
          Market__c market1 = new Market__c();
            market1.Name = 'Amsterdam';
            market1.Email__c = 'amsterdammarket1@example.com';
            market1.UUID__c = 'test-market-uuid1';
            TestingUtility.insertWithAssert(market1);
            
            Market__c market2 = new Market__c();
            market2.Name = 'Atlanta';
            market2.Email__c = 'atlantamarket2@example.com';
            market2.UUID__c = 'test-market-uuid2';
            TestingUtility.insertWithAssert(market2);
        
            CampaignMember cm = new CampaignMember(CampaignId=c.Id ,LeadId=result.Id, Status='Sent');
            insert cm;
            //define container and set request Company and Reservable UUIDs
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'test.lead@test123.com';
            j.locale                                    ='en-US';
            j.campaign_sfid                             = c.Id;
            j.referrer_sfid                                  = referrerContact.Id;  
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'}; 
            j.market_uuids = new List<String>{market1.UUID__c, market2.UUID__c};
            
            
            //submit post
            RESTInboundLead.Response response = RESTInboundLead.doPost(j);
    
            //confirm response
            //If a lead with given email id is exists.
            system.assertEquals(false, response.success);
    }
    
    @isTest static void test_post_success_5() {
        //pre-context

        //test
        Test.startTest();
            RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/InboundLead';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            Campaign c = new Campaign(Name='Test Campaign');
            insert c;
            Account accRec = TestingUtility.createAccount('strAccountName', true);
            Contact referrerContact = TestingUtility.createContact(accRec.Id, 'strLastName', false);
          referrerContact.Email = 'testreferrer@example.com';
          TestingUtility.insertWithAssert(referrerContact);

            Lead leadRec1 = new Lead();
            leadRec1.LastName = 'Test Lead';
            leadRec1.Company = 'test123';
            leadRec1.Status = 'Open';
            leadRec1.LeadSource = 'wework.com';
            leadRec1.Email = 'test.lead1@test123.com';
            Database.SaveResult result = TestingUtility.insertWithAssert(leadRec1);
        
            CampaignMember cm = new CampaignMember(CampaignId=c.Id ,LeadId=result.Id, Status='Sent');
            insert cm;
            //define container and set request Company and Reservable UUIDs
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'test.lead1@test123.com';
            j.locale                                    ='en-US';
            j.campaign_sfid                             = c.Id;
            j.referrer_sfid                                  = referrerContact.Id;  
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'};
            
            //submit post
            RESTInboundLead.Response response = RESTInboundLead.doPost(j);
    
            //confirm response
            //If a lead with given email id is exists.
            system.assertEquals(false, response.success);
            Test.stopTest();
    }
    
    //Anant Kumar on 9th May 2016
    //UseCase : If contact is exists with given email id;
    @isTest static void test_post_success_4() {
        //pre-context

        //test
        
            RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/InboundLead';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            Campaign c = new Campaign(Name='Test Campaign');
            insert c;
            Account accRec = TestingUtility.createAccount('strAccountName', true);
            Contact referrerContact = TestingUtility.createContact(accRec.Id, 'strLastName', false);
          referrerContact.Email = 'testreferrer@example.com';
          TestingUtility.insertWithAssert(referrerContact);
                
            Contact existingContact = TestingUtility.createContact(accRec.Id, 'existing Contact', false);
            existingContact.Email = 'test.lead@test123.com';
            TestingUtility.insertWithAssert(existingContact);
            
            Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
            oppRec1.Primary_Member__c = existingContact.Id;
            TestingUtility.insertWithAssert(oppRec1);
            
            Map<String,Object> tourDataMap = new Map<String,Object>();
            tourDataMap.put('Scheduled_By__c', existingContact.Id);
            tourDataMap.put('Status__c', 'Scheduled');
            tourDataMap.put('Tour_Date__c', system.today().addDays(-1));
            tourDataMap.put('Start_Time__c', '9:00AM');
            Tour_Outcome__c contactRecord = (Tour_Outcome__c)TestingUtility.createTestRecords(Tour_Outcome__c.SObjectType, tourDataMap, true);
            
            //define container and set request Company and Reservable UUIDs
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'test.lead@test123.com';
            j.locale                                    ='en-US';
            j.campaign_sfid                             = c.Id;
            j.referrer_sfid                             = referrerContact.Id;  
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'};
            j.company_size = '100+';
            Test.startTest();
            //submit post
            RESTInboundLead.Response response = RESTInboundLead.doPost(j);
        Test.stopTest();
            //confirm response
            //If a lead with given email id is exists.
            system.assertEquals(true, response.success,response+'');
            
            Lead[] Ks = [   SELECT id, Phone, Interested_in_Number_of_Desks__c
                                        FROM Lead 
                                        WHERE email = :j.email
                                        LIMIT 1
                                    ];
            system.assertEquals(
                1,
                Ks.size(),
                'A lead should be created'
            );
            
            System.assertEquals(100, Ks[0].Interested_in_Number_of_Desks__c);
            
            
    }
    
    //UseCase : Test Inbound Lead for referral app.
    @isTest static void test_post_success_6() {
        //pre-context

        //test
        Test.startTest();
            RestRequest req     = new RestRequest(); 
          RestResponse res    = new RestResponse();
        
          // pass the req and resp objects to the method         
          req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/InboundLead';  
          req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            Campaign c = new Campaign(Name='Test Campaign');
            insert c;
            Account accRec = TestingUtility.createAccount('strAccountName', false);
          accRec.Type = 'Prospect';
          TestingUtility.insertWithAssert(accRec);
        
            Contact referrerContact = TestingUtility.createContact(accRec.Id, 'strLastName', false);
          referrerContact.Email = 'testreferrer@example.com';
          TestingUtility.insertWithAssert(referrerContact);
          
            //define container and set request Company and Reservable UUIDs
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'test.lead@example.com';
            j.locale                                    ='en-US';
          j.referrer_sfid                                  = referrerContact.Id;  
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'}; 
            
            //submit post
            RESTInboundLead.Response response = RESTInboundLead.doPost(j);
    
            //confirm response
            //If a lead with given email id is exists.
            system.assertEquals(true, response.success);
          system.assertEquals(1, [SELECT Id, Expires_On__c, Referrer__c FROM Referral__c].size());
        Test.stopTest();
    }*/
}