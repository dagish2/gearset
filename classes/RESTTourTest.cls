@isTest
private class RESTTourTest {
	/*static {
        SalesConsoleSettings.createSettings();
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Map<String,Object> userRecordMap3 = new Map<String,Object>();
        userRecordMap3.put('LastName','API User');
        userRecordMap3.put('Username','testapiuser123456@example.com');
        userRecordMap3.put('Email','testapiuser@example.com');
        User apiUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap3, true);        
                
        insert new Building__c[]{
            new Building__c(
                Name = 'b1',
                UUID__c = 'b1',
                City__c = 'city1'
            ),
            new Building__c(
                Name = 'b2',
                UUID__c = 'b2',
                City__c = 'city2'
            ),
            new Building__c(
                Name = 'b3',
                UUID__c = 'b3',
                City__c = 'city1'
            ),
            new Building__c(
                Name = 'b4',
                UUID__c = 'b4',
                City__c = 'city4'
            ),
            new Building__c(
                Name = 'b5',
                UUID__c = 'b5',
                City__c = 'city5'
            ),
            new Building__c(
                Name = 'b6',
                UUID__c = 'b6',
                City__c = 'city6'
            )            
        };
        
        Building__c b1 = new Building__c(Name = 'old B1');
        insert b1;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'testU', Email='testUser-123@example.com', 
            EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='testUserName123@example.com',CommunityNickname = TestingUtility.createUserCommunityName());
        insert u1;
        
        User u2 = new User(Alias = 'testN', Email='test@example.com', 
            EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='testnewuser@example.com',CommunityNickname = TestingUtility.createUserCommunityName());
        insert u2;
        
        User u3 = new User(Alias = 'testN', Email='joinus@example.com', 
            EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='joinus@example.com',CommunityNickname = TestingUtility.createUserCommunityName());
        insert u3;
        
        User inactiveUser = new User(Alias = 'inact', Email='inactiveu@example.com', 
            EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = false,
            TimeZoneSidKey='America/Los_Angeles', UserName='inactiveu@example.com',CommunityNickname = TestingUtility.createUserCommunityName());
        insert inactiveUser;
        
        Setting__c testTourRservableSettings = new Setting__c();
        testTourRservableSettings.Name = 'TourRservableSettings';
        testTourRservableSettings.Data__c = '{"salesleadprofiles": [{"profilename":"System Administrator", "profileid":"00eF0000000Rfpc"}], "bookedbysalesleadlabel":"Booked By Sales Lead", "apiuseremail":"joinus@wework.com", "apiuserid":"' + u3.Id + '", "apiusercontactid":""}';
        insert testTourRservableSettings;
       
        Building__c b = new Building__c(
            City__c = 'Test',
            uuid__c = 'abc123',
            Name = 'Test Building'

        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
       
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Tuesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Wednesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Thursday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Friday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Saturday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Sunday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            )
        };
    }
    
    static testMethod void test_business_case_1() {
        
        	User user1 = [SELECT Id FROM User WHERE UserName = 'testnewuser@example.com'];
        	Account acc = new Account();
        System.runAs(user1){
            acc = new Account();
            acc.Name = 'A Company';
            acc.UUID__c = 'account-uuid';
            acc.OwnerId = user1.Id;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
            insert acc;
        }
        	Contact con = TestingUtility.createContact(acc.Id, 'strLastName', false);
        	con.UUID__c = UUIDHandler.generateVersion4();
        	con.Email = 'testtourcompletedbycontact@example.com';
        	TestingUtility.insertWithAssert(con);	
        
        	Contact con2 = TestingUtility.createContact(acc.Id, 'strLastName 2', false);
        	con2.UUID__c = UUIDHandler.generateVersion4();
        	con2.Email = 'test@example.com';
        	TestingUtility.insertWithAssert(con2);
        
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'john@doe.com';
            j.tour_building_uuid            =   'abc123';
            j.tour_date                             = system.today().addDays(1);
            j.tour_time                             = '9:00AM';
            j.locale                                = 'en-US';
            j.generate_journeys                     = false;
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'};
            j.account_uuid = 'account-uuid';
            j.contact_uuid = 'contact-uuid';
            j.lead_source = 'Test Method';   
        	j.tour_completed_by_uuid = con.UUID__c;
        	j.tour_completed_by_name = 'strLastName';
        	j.booked_by_sales_lead = true;

        
        Test.startTest();
            RestRequest req     = new RestRequest(); 
            RestResponse res    = new RestResponse();
          
                      
              req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour';  
              req.httpMethod = 'POST';
    
                
                RestContext.request     = req;
                RestContext.response    = res;
    
                
                RESTTour.Response response = RESTTour.doPost(j);
        		System.Debug('Response From REST API :::'+response);
        		Debug.log('Response From REST API :::'+response.result);
        
                
                system.assertEquals(true, response.success, 'Response msg: ' + response.message);
    
                
                Opportunity[] Os = [SELECT id, OwnerId , RecordType.Name
                                                        FROM Opportunity 
                                                        WHERE Primary_Member__r.email = :con.email
                                                     ];
    			debug.log('Os==>'+Os);
        
                system.assert(
                    Os.size() > 0,
                    'An opportunity should be created'
                );
        		
        		Account[] arrAccount = [ SELECT Id,OwnerId, RecordType.Name FROM Account WHERE Id = :acc.Id ];
        		system.assertEquals(Os[0].RecordType.Name, arrAccount[0].RecordType.Name,'Opportunity Record Type should be same as Account Record Type.');
        		
        		system.assertEquals(
                   
                    user1.Id,
                    Os[0].OwnerId,
                    'Opportunity owner should be same as Account owner as Account of Opportunity is mid market.'
                );
                
                
    
                Tour_Outcome__c[] Ts = [SELECT id, Opportunity__c, tour_completed_by__c, tour_completed_by_UUID__c, tour_completed_by_Name__c, tour_completed_by_SFID__c,
                                                                Booked_By_Sales_Lead__c, Hosted_By__c, Assigned_Host__c, OwnerId, booked_by_contact_id__c
                                        						FROM Tour_Outcome__c
                                                                WHERE tour_date__c = :j.tour_date
                                                                ];
                
                system.assert(
                    Ts.size() > 0,
                    'A tour for the specified date should be created:' + j.tour_date
                );
        		Debug.log('Test : Ts ::: ' + Ts[0]);
        		System.assertEquals([SELECT Id FROM User WHERE Email = 'test@example.com'].Id, Ts[0].OwnerId);
				System.assertEquals(true, Ts[0].Booked_By_Sales_Lead__c);
                System.assertEquals(Ts[0].booked_by_contact_id__c, Ts[0].Assigned_Host__c);
        		
                
                system.assert(
                    response.result != null &&
                    response.result.contains(Ts[0].id),
                    'The opportunity id should be provided as response; ' + Ts[0].id
                );                                      
    		Test.stopTest();
                Task[] Ks = [   SELECT id, subject
                                            FROM Task
                                        ];
                
                system.assert(
                    Ks.size() == 1,
                    'A task should be created:' + Ks.size()
                );
    
                system.assertEquals(
                    'Book a Tour',
                    Ks[0].subject,
                    'The created task should have the right subject'
                );
    }

    
    static testMethod void test_business_case_2() {
        
        	Account acc = TestingUtility.createAccount('strAccountName', false);
        	acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        	TestingUtility.insertWithAssert(acc);	
        
        	Contact con = TestingUtility.createContact(acc.Id, 'strLastName', false);
        	con.UUID__c = UUIDHandler.generateVersion4();
        	con.Email = 'test@example.com';
        	TestingUtility.insertWithAssert(con);	
        
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                         = 'Doe';
            j.first_name                        = 'John';
            j.email                             = 'john@doe.com';
            j.tour_building_uuid                =  'abc123';
            j.tour_date                         = system.today().addDays(1);
            j.tour_time                         = '9:00AM';
            j.locale                            = 'en-US';
            j.generate_journeys                 = false;
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'};
            j.account_uuid = 'account-uuid';
            j.contact_uuid = 'contact-uuid';
            j.lead_source = 'Test Method Payload';
        	j.booked_by_sales_lead = true;
            
        	
            Lead k = new Lead(
                company                                 = j.company_name,
                firstname                           = j.first_name,
                lastname                                = j.last_name,
                email                                   = j.email,
                locale__c                               ='en-US',
                locations_interested__c = 'NYC-Penn Station',
                leadsource = 'Test Method Existing Lead'
            );
            insert k;

        
        Test.startTest();
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
              
      req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour';   
      req.httpMethod = 'POST';

            
            RestContext.request     = req;
            RestContext.response    = res;
            
            
            RESTTour.Response response = RESTTour.doPost(j);
    		Test.stopTest();
            
            system.assertEquals(true, response.success, 'Response msg: ' + response.message);
        
            system.assertEquals(
                true,
                [   SELECT isConverted 
                    FROM Lead 
                    WHERE id = :k.id
                ].isConverted,
                'The lead was not converted'
            );
            
            
            
            Opportunity[] Os = [SELECT id, OwnerId  FROM Opportunity  WHERE Primary_Member__r.email = :j.Email ];
                                                   
                                                   
                                                 
			debug.Log('Os *** : ' + Os );
            system.assert(
                Os.size() > 0,
                'An opportunity should be created'
            );
			
            

            Tour_Outcome__c[] Ts = [SELECT id, Opportunity__c, Booked_By_Sales_Lead__c, Hosted_By__c, Assigned_Host__c, OwnerId
                                                            FROM Tour_Outcome__c
                                                            WHERE tour_date__c = :j.tour_date
                                                            ];
        	debug.Log('Ts*****' + Ts);
            
            system.assert(
                Ts.size() > 0,
                'A tour for the specified date should be created:' + j.tour_date
            );
        	
        	System.assertEquals(true, Ts[0].Booked_By_Sales_Lead__c);
        	
        	
        	User userNew = [SELECT Id FROM User WHERE UserName='testnewuser@example.com'];
            
            System.assertEquals(userNew.Id, Ts[0].OwnerId);
        	
        	
            system.assert(
                response.result != null &&
                response.result.contains(Ts[0].id),
                'The opportunity id should be provided as response; ' + Ts[0].id
            );  

            Task[] Ks = [SELECT id, subject FROM Task Order By CreatedDate];
        	debug.log('Ks ==>'+Ks );
        	System.assertEquals(2,Ks.size(),'Two activities should be created');
            system.assertEquals(
                'Inbound Lead submission',
                Ks[0].subject,
                'The first created task should have the right subject'
            );
            system.assertEquals(
                'Book a Tour',
                Ks[1].subject,
                'The second created task should have the right subject'
            );
       
    }

    
    static testMethod void test_business_case_3_1() {
        Account acc = new Account();
        acc.Name = 'A Company';
        acc.UUID__c = 'account-uuid';
        insert acc;
        
        Contact con = new Contact(
                firstname = 'Paul',
                lastname = 'Boss',
                email = 'john@doe.com',
                AccountId = acc.id,
                UUID__c = 'contact-uuid'
            );
        insert con;
        
        Contact con2 = TestingUtility.createContact(acc.Id, 'strLastName', false);
        con2.UUID__c = UUIDHandler.generateVersion4();
        con2.Email = 'inactiveu@example.com';
        TestingUtility.insertWithAssert(con2);
        
        
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'john@doe.com';
            j.tour_building_uuid            =   'abc123';
            j.tour_date                             = system.today().addDays(1);
            j.tour_time                             = '9:00AM';
            j.account_uuid = 'account-uuid';
            j.contact_uuid = 'contact-uuid';
            j.lead_source = 'Test Method Payload';
            
            Lead k = new Lead(
                company                                 = j.company_name,
                firstname                           = j.first_name,
                lastname                                = j.last_name,
                email                                   = j.email,
                locations_interested__c = 'NYC-Penn Station'
            );
            insert k;

            
            k = [   SELECT id, convertedContactId, convertedAccountId, convertedOpportunityId
                        FROM Lead 
                        WHERE id = :k.id
                    ];
            System.debug(logginglevel.ERROR, 'Test : Converted Lead ::: ' + k);
        
        Test.startTest();
            RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
             
      req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour';  
      req.httpMethod = 'POST';

            
            RestContext.request     = req;
            RestContext.response    = res;
            
            
            RESTTour.Response response = RESTTour.doPost(j);
    		
        	Test.stopTest();
            
            system.assertEquals(true, response.success, 'Response msg: ' + response.message);
            
            
            Contact contactRec = [SELECT Id, LeadSource FROM Contact WHERE Email =: j.email];
            
            Opportunity[] Os = [SELECT id  FROM Opportunity ];

            system.assert(
                Os.size() > 0,
                'An opportunity should be created'
            );

            

            Tour_Outcome__c[] Ts = [SELECT id, Opportunity__c, OwnerId
                                                            FROM Tour_Outcome__c
                                                            WHERE tour_date__c = :j.tour_date
                                                            ];
            system.assert(
                Ts.size() > 0,
                'A tour for the specified date should be created:' + j.tour_date
            );
        
        	System.assertEquals(UserInfo.getUserId(), Ts[0].OwnerId, 'Tour owner should be loggedin user if user with email of Booked_By_Contact\'s is inactive');

                                                                        

            system.assert(
                response.result != null &&
                response.result.contains(Ts[0].id),
                'The opportunity id should be provided as response; ' + Ts[0].id
            );  

            Task[] Ks = [   SELECT id, subject
                                        FROM Task
                                    ];
            
            system.assertEquals(2, Ks.size(), '2 tasks should be created:' + Ks.size());
                

            system.assertEquals(
                'Inbound Lead submission',
                Ks[0].subject,
                'The created task should have the right subject'
            );
        	system.assertEquals(
                'Book a Tour',
                Ks[1].subject,
                'The created task should have the right subject'
            );

    }

    
    static testMethod void test_business_case_3_2() {
        Account acc = new Account();
        acc.Name = 'A Company';
        acc.UUID__c = 'account-uuid';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        insert acc;
        
        Contact con = new Contact(
                firstname = 'Paul',
                lastname = 'Boss',
                email = 'con1@example.com',
                AccountId = acc.id,
                UUID__c = 'contact-uuid'
            );
        insert con;
        
        Contact con2 = new Contact(
                firstname = 'Paul',
                lastname = 'Boss',
                email = 'test@example.com',
                AccountId = acc.id,
                UUID__c = UUIDHandler.generateVersion4()
            );
        insert con2;
        
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'john@doe.com';
            j.tour_building_uuid            =   'abc123';
            j.tour_date                             = system.today().addDays(1);
            j.tour_time                             = '9:00AM';
            j.account_uuid = 'account-uuid';
            j.contact_uuid = 'contact-uuid';
        	j.tour_completed_by_uuid = UUIDHandler.generateVersion4();
        	j.booked_by_contact_id = con2.Id;
        	j.booked_by_sales_lead = true;
            
            Lead k = new Lead(
                company                                 = j.company_name,
                firstname                           = j.first_name,
                lastname                                = j.last_name,
                email                                   = j.email,
                locations_interested__c = 'Test'
            );
            insert k;

            
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(k.id);

            LeadStatus convertStatus = [SELECT Id, MasterLabel 
                                                                    FROM LeadStatus 
                                                                    WHERE IsConverted=true 
                                                                    LIMIT 1
                                                                 ];
            lc.setAccountId(acc.Id);
            lc.setContactId(con.Id);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);

            
            k = [   SELECT id, convertedContactId, convertedAccountId, convertedOpportunityId
                        FROM Lead 
                        WHERE id = :k.id
                    ];

            Opportunity o = new Opportunity(
                id                          = k.convertedOpportunityId,
                stageName           = 'Closed Lost',
                lost_reason__c  = 'Not Interested'
            );
            update o;

        
        Test.startTest();
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      
      req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour';  
      req.httpMethod = 'POST';

            
            RestContext.request     = req;
            RestContext.response    = res;
            
            
            RESTTour.Response response = RESTTour.doPost(j);
    		Test.stopTest();
            
            system.assertEquals(true, response.success, 'Response msg: ' + response.message);

            
            Opportunity[] Os = [SELECT id 
                                                    FROM Opportunity 
                                                    WHERE isClosed = false
                                                 ];
            
            Tour_Outcome__c[] Ts = [SELECT id, Opportunity__c, booked_by_contact_id__c, OwnerId, Owner.Email
                                                            FROM Tour_Outcome__c
                                                            WHERE tour_date__c = :j.tour_date
                                                            ];
            
            system.assert(
                Ts.size() > 0,
                'A tour for the specified date should be created:' + j.tour_date
            );
            
            System.assertEquals([SELECT Id FROM User WHERE Email='test@example.com'].Id, Ts[0].OwnerId);
        	
            system.assert(
                response.result != null &&
                response.result.contains(Ts[0].id),
                'The opportunity id should be provided as response; ' + Ts[0].id
            );  

            Task[] Ks = [   SELECT id, subject
                                        FROM Task
                                    ];
            
            system.assert(
                Ks.size() == 2,
                '2 tasks should be created:' + Ks.size()
            );

           
    }

   
    static testMethod void test_business_case_4_1() {
        
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'john@doe.com';
            j.tour_building_uuid            =   'abc123';
            j.tour_date                             = system.today().addDays(1);
            j.tour_time                             = '9:00AM';
            j.account_uuid = 'account-uuid';
            j.contact_uuid = 'contact-uuid';
            
            Account a = new Account(
                name = 'Acme',
                UUID__c = 'account-uuid'
            );
            insert a;

            
            Contact c_primary = new Contact(
                firstname = 'Paul',
                lastname = 'Boss',
                email = 'paul@boss.com',
                AccountId = a.id
            );
            insert c_primary;

            
            a.Primary_Member__c = c_primary.id;
            update a;

            
            Contact c_regular = new Contact(
                firstname = 'John',
                lastname = 'Doe',
                email = 'john@doe.com',
                AccountId = a.id,
                UUID__c = 'contact-uuid'
            );
            insert c_regular;

            Opportunity o = new Opportunity(
                name                            = 'test closed oppty',
                AccountId               = a.id,
                Primary_Member__c = c_primary.id,
                stageName               = 'Closed Lost',
                lost_reason__c      = 'Not Interested',
                closeDate               = System.today()
            );
            insert o;

        
        Test.startTest();

        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
     
      req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour';
      req.httpMethod = 'POST';

            
            RestContext.request     = req;
            RestContext.response    = res;
            
            
            RESTTour.Response response = RESTTour.doPost(j);
    		Test.stopTest();
            
            system.assertEquals(true, response.success, 'Response msg: ' + response.message);

           
            Opportunity[] Os = [SELECT id 
                                                    FROM Opportunity 
                                                    WHERE isClosed = false
                                                 ];
            

            Tour_Outcome__c[] Ts = [SELECT id, Opportunity__c
                                                            FROM Tour_Outcome__c
                                                            WHERE tour_date__c = :j.tour_date
                                                            ];
            
            system.assert(
                Ts.size() > 0,
                'A tour for the specified date should be created:' + j.tour_date
            );
            
            system.assert(
                response.result != null &&
                response.result.contains(Ts[0].id),
                'The opportunity id should be provided as response; ' + Ts[0].id
            );  

            Task[] Ks = [   SELECT id, subject
                                        FROM Task
                                    ];
            
            system.assert(
                Ks.size() == 1,
                'A task should be created:' + Ks.size()
            );

            system.assertEquals(
                'Book a Tour',
                Ks[0].subject,
                'The created task should have the right subject'
            );

    }

    
    static testMethod void test_business_case_4_2() {
       
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'john@doe.com';
            j.tour_building_uuid            =   'abc123';
            j.tour_date                             = system.today().addDays(1);
            j.tour_time                             = '9:00AM';
            j.locale                                = 'en-US';
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'};
            j.account_uuid = 'account-uuid';
            j.contact_uuid = 'contact-uuid';
            
            Account a = new Account(
                name = 'Acme',
                UUID__c = 'account-uuid'
            );
            insert a;

            
            Contact c_primary = new Contact(
                firstname = 'Paul',
                lastname = 'Boss',
                email = 'paul@boss.com',
                AccountId = a.id
            );
            insert c_primary;

            
            a.Primary_Member__c = c_primary.id;
            update a;

            
            Contact c_regular = new Contact(
                firstname = 'John',
                lastname = 'Doe',
                email = 'john@doe.com',
                AccountId = a.id,
                UUID__c = 'contact-uuid'
            );
            insert c_regular;

            Opportunity o = new Opportunity(
                name                                        = 'test closed oppty',
                AccountId                           = a.id,
                Primary_Member__c           = c_primary.id,
                stageName                           = 'Closed Lost',
                closeDate                           = System.today(),
                locations_interested__c = 'NYC-Penn Station',
                Lost_Reason__c      ='test'
            );
            insert o;

            
            Test.startTest();

            RestRequest req     = new RestRequest(); 
            RestResponse res    = new RestResponse();
      
             
            req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour';
            req.httpMethod = 'POST';

            
            RestContext.request     = req;
            RestContext.response    = res;
            
            
            RESTTour.Response response = RESTTour.doPost(j);
        	Test.stopTest();
            
            system.assertEquals(true, response.success, 'Response msg: ' + response.message);

                    
            Opportunity[] Os = [SELECT id 
                                                    FROM Opportunity 
                                                 ];

            Tour_Outcome__c[] Ts = [SELECT id, Opportunity__c
                                                            FROM Tour_Outcome__c
                                                            WHERE tour_date__c = :j.tour_date
                                                            ];
            
            system.assert(
                Ts.size() > 0,
                'A tour for the specified date should be created:' + j.tour_date
            );

            system.assert(
                response.result != null &&
                response.result.contains(Ts[0].id),
                'The opportunity id should be provided as response; ' + Ts[0].id
            );  

            Task[] Ks = [   SELECT id, subject
                                        FROM Task
                                    ];
            
            system.assert(
                Ks.size() == 1,
                'A task should be created:' + Ks.size()
            );

            system.assertEquals(
                'Book a Tour',
                Ks[0].subject,
                'The created task should have the right subject'
            );
    }

    
    static testMethod void test_business_case_5_1() {
       
        Account a = new Account(
            Name = 'Acme',
            UUID__c = 'account-uuid',
            Lead_Source__c = 'Id'
        );
        insert a;
        
        

        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.company_name                      = 'A company';
        j.last_name                             = 'Doe';
        j.first_name                            = 'John';
        j.email                                     = 'john@doe.com';
        j.tour_building_uuid            =   'abc123';
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'contact-uuid';

        
        Test.startTest();
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        
        req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour';
        req.httpMethod = 'POST';
        
        
        RestContext.request     = req;
        RestContext.response    = res;
        
        RESTTour.Response response = RESTTour.doPost(j);
		Debug.log('response==>'+ response);
        Test.stopTest();

        
        if(response != null){
            system.assertEquals(true, response.success, 'Response msg: ' + response.message);  
        }
        

        Debug.Log('Tour # of Queries 3: ' + Limits.getQueries());
        
        Contact[] Cs = [select AccountId, Is_Primary_Member__c from Contact where AccountId = :a.Id and UUID__c = 'contact-uuid'];

        System.assert(Cs.size() == 1, 'A Contact should be created');        

        a = [select Id, Primary_Member__c from Account where Id = :a.Id];

        System.assert(a.Primary_Member__c == Cs[0].Id, 'Contact should be set as Primary Member');
        
        
        Opportunity[] Os = [SELECT Id FROM Opportunity where AccountId = :a.Id];
        
        system.assert(
            Os.size() == 1,
            'An opportunity should be created'
        );
        
        system.assert(
            response.result != null &&
            response.result.contains([SELECT id FROM Tour_Outcome__c LIMIT 1].id),
            'The tour id should be provided as response; ' + Os[0].id
        );
        
        Task[] Ks = [SELECT id, subject FROM Task];
        
        system.assert(
            Ks.size() == 1,
            'A task should be created:' + Ks.size()
        );
        
        system.assertEquals(
            'Book a Tour',
            Ks[0].subject,
            'The created task should have the right subject'
        );
    }

    
    
    static testMethod void test_business_case_5_2() {

        Account a = new Account(Name = 'Acme');
        insert a;

        Contact c = new Contact(
            AccountId = a.Id,
            LeadSource = 'Id',
            UUID__c = 'contact-uuid',
            FirstName = 'Test',
            LastName = 'Test'
        );
        
        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'contact-uuid';

        
        Test.startTest();
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        
        req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour';
        req.httpMethod = 'POST';
        
        
        RestContext.request     = req;
        RestContext.response    = res;
        
        
        RESTTour.Response response = RESTTour.doPost(j);
        Test.stopTest();
        
        system.assertEquals(false, response.success, 'Response msg: ' + response.message);
    }

    
    static testMethod void test_business_case_5_3() {
        
        Account a = new Account(Name = 'Acme');
        insert a;

        Contact primaryContact = new Contact(
            AccountId = a.Id,
            FirstName = 'Test',
            LastName = 'Test',
            LeadSource = 'Id',
            UUID__c = 'pm-contact-uuid',
            Email = 'test@example.com');

        insert primaryContact;

        Contact regularContact = new Contact(
            AccountId = a.Id,
            FirstName = 'Test',
            LastName = 'Test',
            LeadSource = 'Id',
            UUID__c = 'regular-contact-uuid',
            Email = 'test1@example.com');

        insert regularContact;
        
        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.company_name                      = 'A company';
        j.last_name                 = 'doe';
        j.tour_building_uuid            =   'abc123';
        j.email                         = 'john@doe.com';
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'regular-contact-uuid';

        Test.startTest();
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        
        req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour';
        req.httpMethod = 'POST';
        
        
        RestContext.request     = req;
        RestContext.response    = res;
        
        RESTTour.Response response = RESTTour.doPost(j);
        Test.stopTest();
        
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);
        
        
        Account[] accounts = [select Id, Primary_Member__c,Phone from Account where UUID__c = 'account-uuid'];
        System.assert(accounts.size() == 1, 'Account should have been created');
        accounts[0].Phone = '8956321889';
        update accounts;
        
        
        Contact[] Cs = [select AccountId, Is_Primary_Member__c from Contact where AccountId = :accounts[0].Id and UUID__c = 'regular-contact-uuid'];
        Account[] updatedAccount = [select Id, Primary_Member__c from Account where UUID__c = 'account-uuid'];
        System.assert(Cs.size() == 1, 'Regular Contact should have been transferred to new Account');      
        System.assert(updatedAccount[0].Primary_Member__c == Cs[0].Id, 'Contact should be set as Primary Member');
        
        
        
        Task[] Ks = [SELECT id, subject FROM Task];
        system.assert(
            Ks.size() == 1,
            'A task should be created:' + Ks.size()
        );
        
        system.assertEquals(
            'Book a Tour',
            Ks[0].subject,
            'The created task should have the right subject'
        );
    }

    
    static testMethod void test_business_case_5_4() {
        
        Account a = new Account(Name = 'Acme', Lead_Source__c = 'Id', UUID__c = 'account-uuid');
        insert a;

        Contact c = new Contact(
            AccountId = a.Id,
            FirstName = 'Test',
            LastName = 'Test',
            LeadSource = 'Id',
            UUID__c = 'contact-uuid',
            Email = 'test@example.com');

        insert c;

        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.company_name                      = 'A company';
        j.last_name                 = 'doe';
        j.tour_building_uuid            =   'abc123';
        j.email                         = 'john@doe.com';
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'contact-uuid';

        
        Test.startTest();
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        
        req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour';
        req.httpMethod = 'POST';
        
        
        RestContext.request     = req;
        RestContext.response    = res;
        
        
        RESTTour.Response response = RESTTour.doPost(j);
        
        Test.stopTest();
        
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);

        
        Opportunity[] Os = [SELECT id FROM Opportunity where AccountId = :a.Id];

        
        Task[] Ks = [SELECT id, subject FROM Task];
        
        system.assert(
            Ks.size() == 1,
            'A task should be created:' + Ks.size()
        );
        
        system.assertEquals(
            'Book a Tour',
            Ks[0].subject,
            'The created task should have the right subject'
        );
    }

    
    static testMethod void test_business_case_5_5() {
        
        Account a = new Account(Name = 'Acme', Lead_Source__c = 'Id', UUID__c = 'account-uuid');
        insert a;

        Account another = new Account(Name = 'Acme2');
        insert another;
        
        Contact c = new Contact(
            AccountId = another.Id,
            FirstName = 'Test',
            LastName = 'Test',
            LeadSource = 'Id',
            UUID__c = 'contact-uuid',
            Email = 'test@example.com');

        insert c;

        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.company_name                      = 'A company';
        j.tour_building_uuid            =   'abc123';
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'contact-uuid';

        
        Test.startTest();
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
       
        req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Tour';     
         
        req.httpMethod = 'POST';
        
        
        RestContext.request     = req;
        RestContext.response    = res;
        
        
        RESTTour.Response response = RESTTour.doPost(j);
        
        
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);
    }

    
    static testMethod void test_business_case_5_6() {

        
        Account a = new Account(Name = 'Acme', Lead_Source__c = 'Id', UUID__c = 'account-uuid');
        insert a;

        Account another = new Account(Name = 'Acme2');
        insert another;
        
        Contact primaryContact = new Contact(
            AccountId = another.Id,
            FirstName = 'Test2',
            LastName = 'Test2',
            Email = 'test@example.com');
        insert primaryContact;
        
        Contact regularContact = new Contact(
            AccountId = another.Id,
            FirstName = 'Test',
            LastName = 'Test',
            LeadSource = 'Id',
            UUID__c = 'contact-uuid',
            Email = 'test1@example.com');

        insert regularContact;

        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.company_name              = 'A company';
        j.last_name                 = 'doe';
        j.tour_building_uuid        = 'abc123';
        j.email                     = 'test1@example.com';
        j.account_uuid              = 'account-uuid';
        j.contact_uuid              = 'contact-uuid';

        
        Test.startTest();
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        
        req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour';
        req.httpMethod = 'POST';
        
        
        RestContext.request     = req;
        RestContext.response    = res;
        
        
        RESTTour.Response response = RESTTour.doPost(j);
        
        
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);

        Test.stopTest();
    }

    
    static testMethod void test_business_case_5_7() {
        
        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.company_name                      = 'A company';
        j.first_name                            = 'Test';
        j.last_name                             = 'Test';
        j.tour_building_uuid            =   'abc123';
        J.Email = 'testREST@example.com';
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'contact-uuid';

        
        Test.startTest();
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        
        req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour';
        req.httpMethod = 'POST';
        
        
        RestContext.request     = req;
        RestContext.response    = res;
        
        
        RESTTour.Response response = RESTTour.doPost(j);
        Test.stopTest();
        
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);

        
        Account[] accounts = [select Id, Primary_Member__c from Account where UUID__c = 'account-uuid'];
        System.assert(accounts.size() == 1, 'Account should have been created');
            
        
        Contact[] Cs = [select AccountId, Is_Primary_Member__c from Contact where AccountId = :accounts[0].Id and UUID__c = 'contact-uuid'];
        
        System.assert(Cs.size() == 1, 'Regular Contact should have been transferred to new Account');        

        System.assert(accounts[0].Primary_Member__c == Cs[0].Id, 'Contact should be set as Primary Member');
        

        
        Opportunity[] Os = [SELECT id FROM Opportunity where AccountId = :accounts[0].Id];
        
        Task[] Ks = [SELECT id, subject FROM Task];
        
        system.assert(
            Ks.size() == 1,
            'A task should be created:' + Ks.size()
        );
       
        system.assertEquals(
            'Book a Tour',
            Ks[0].subject,
            'The created task should have the right subject'
        );
    }

    static testMethod void test_get_tour_success_1() {
        
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'john@doe.com';
            j.tour_building_uuid            =   'abc123';
            j.tour_date                             = system.today().addDays(1);
            j.tour_time                             = '9:00AM';
            j.generate_journeys                     = false;
            j.account_uuid = 'account-uuid';
            j.contact_uuid = 'contact-uuid';
        RESTTour.Response context_response = RESTTour.doPost(j);
        Debug.log('context_response SUCCESS::'+context_response.success);        
            system.assertEquals(
                true,
                context_response.success,
                'Valid Context should created: tour based on business case 1'
            );

            Tour_Outcome__c[] Ts = [SELECT id FROM Tour_Outcome__c];
            system.assertEquals(
                1,
                Ts.size(),
                'A tour should be created'
            );

        
        Test.startTest();

        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
            String tour_id = Ts[0].id;
            
            Debug.log('Tour ID===>'+tour_id);

        
        req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour/'+tour_id;
        
        req.httpMethod = 'GET';
     
            
            RestContext.request     =   req;
            RestContext.response    =   res;
            
            
            RESTTour.Response response = RESTTour.doGet();
            Debug.log('Test : response ::: ' + response);
            
            system.assertEquals(true, response.success);
    
        Test.stopTest();
    }

    static testMethod void test_get_tour_failure_1() {
        
            
        
        Test.startTest();

        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        String tour_id = 'unexisting_salesforce_tour_id';

        
        req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour/'+ tour_id;
        req.httpMethod = 'GET';
     
            
            RestContext.request     =   req;
            RestContext.response    = res;
            
            
            RESTTour.Response response = RESTTour.doGet();
    
            
            system.assertEquals(false, response.success);
    
        Test.stopTest();
    }*/
}