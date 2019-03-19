@isTest
private class RESTTourAdvancedTest {
	/*
	static {
         SalesConsoleSettings.createSettings();*/
       /* List<Setting__c> lstSettings = new List<Setting__c>();
        lstSettings.add(new Setting__c(Name = 'AccountCleansingSetting',Data__c = '{"starts_with":["The","An","A"],"ends_with":["pvt","ltd"],"specialCharacters":"@#^&*!():?/><"}'));
        insert lstSettings; 

        Setting__c testJourneyCreationSettings = new Setting__c();
        testJourneyCreationSettings.Name = 'JourneyCreationSettings';
        testJourneyCreationSettings.Data__c = '{"NextCallInDaysFromLeadCreation":0,"NoCompanyAccountId":"001F000001r0JbC","NextCallInDaysFromJourneyUpdation":0,"NewLeadActivityFields":{"Status":"Open","Subject":"Inbound Lead submission"},"NewJourneyFields":{"Stage__c":"Started"},"ExistingJourneyStage":"Started","ExistingJourneyCreatedDateDifference":2,"JourneyAssignmentCutOffDays":16,"CloseInDaysFromJourneyCreation":2,"ClosedJourneyStages":["Completed-Lost","Completed-Won"]}';
        insert testJourneyCreationSettings;*/
        /*
        Building__c b1 = new Building__c(Name = 'B1');
        insert b1;
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'testU', Email='testUser@example.com', 
            EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='testUserName1234@example.com',
                          CommunityNickname = TestingUtility.createUserCommunityName());
        insert u1;*/
      /*  
        Setting__c restartLocationSetting = new Setting__c();
        restartLocationSetting.Name = 'RestartLocation';
    	restartLocationSetting.Data__c = '[{"Buildings":["'+b1.Id+'"],"userId":"'+u1.Id+'"}]';
        TestingUtility.upsertWithAssert(restartLocationSetting);
        */
        /*Setting__c testCloseOpenActivities = new Setting__c();
        testCloseOpenActivities.Name = 'CloseOpenActivities';
        testCloseOpenActivities.Data__c = '{"subject":"Inbound Lead Submission,New InboundLead,Follow-Up,Follow up,Follow up two,Final Final up"}';
        insert testCloseOpenActivities;*/
        
        
		//create a building and open it
		/*Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'NYC-Penn Station',
            uuid__c = 'abc123'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
        	Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Maximum_Tour_Days__c = 1
        );
		insert tour_Schedule;

    //open hour
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

	//	* With account_uuid and contact_uuid
	//
	//		POST /services/apexrest/Tour/
	//		{
	//		  "first_name": "Sai",
	//		  "last_name": "Wong",
	//		  "email": "sai.wong@wework.com",
	//		  "phone": "15166063843",
	//		  "company_name": "WeWork",
	//		  "lead_source": "Walk-In Tour",
	//		  "tour_building_uuid": "ec573c00-59e4-0131-b9d5-3a00bb45c91f",
	//		  "tour_date": "2016-02-26",
	//		  "tour_time": "4:00PM",
	//		  "account_uuid": "40e88040-8251-0130-f786-123138068411",
	//		  "contact_uuid": "9bd6c830-145f-0133-167d-12614f2cca6d"
	//		}
	//
	@isTest static void test_with_account_uuid_and_contact_uuid_non_primary() {
		//pre-context

			//set internal clock
      Now.setGMT(2016, 2, 5, 8, 0, 0); //friday 2/5/16 8:00am 

			//account
	 		Account a = new Account(
	 			name = 'WeWork',
	 			uuid__c = '40e88040-8251-0130-f786-123138068411'
	 		);
	 		insert a;

	 		//create primary member
	 		Contact c_primary = new Contact(
	 			firstname = 'Paul',
	 			lastname = 'Boss',
	 			email = 'paul@boss.com',
	 			AccountId = a.id,
	 			uuid__c = 'xxx123'
	 		);
	 		insert c_primary;

	 		//make primary
	 		a.Primary_Member__c = c_primary.id;
	 		update a;

	 		//create regular member
	 		Contact c_regular = new Contact(
	 			firstname = 'John',
	 			lastname = 'Doe',
	 			email = 'john@doe.com',
	 			AccountId = a.id,
	 			uuid__c = 'yyy123'
	 		);
	 		insert c_regular;

	 		//opportunity
	 		/*Opportunity o = new Opportunity(
	 			name 							= 'test closed oppty',
	 			AccountId 				= a.id,
	 			Primary_Member__c = c_primary.id,
	 			stageName 				= 'Closed Lost',
	 			lost_reason__c 		= 'Not Interested',
	 			closeDate 				= System.today()
	 		);
	 		insert o;*/

	 		//contact to be used as target
			/*Contact target = c_regular;

			//payload
			WWTypes.InboundLead j = new WWTypes.InboundLead();
			j.first_name 					= target.firstname;
			j.last_name 					= target.lastname;
			j.email 							= 'target@example.com';
			j.phone 							= target.phone;
			j.company_name 				= a.name;
			j.lead_source 				= 'Walk-In Tour';
			j.tour_building_uuid 	= 'abc123';
			j.tour_date 					= Date.newInstance(2016, 2, 25);
			j.tour_time 					= '4:00PM';
			//j.account_uuid 				= a.uuid__c;
			j.contact_uuid 				= target.uuid__c;		
			

		//test
		Test.startTest();             

      RestRequest req 	= new RestRequest(); 
      RestResponse res 	= new RestResponse();
      
      // pass the req and resp objects to the method		 
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
      req.httpMethod = 'POST';
      
      //assign rest context
      RestContext.request 	= req;
      RestContext.response 	= res;
      
      //submit post
      RESTTour.Response response = RESTTour.doPost(j);
	  Test.stopTest();
        
      //confirm response
      system.assertEquals(true, response.success, 'Response msg: ' + response.message);

      //check tour outcome
      Tour_Outcome__c[] Ts = [SELECT id 
      												FROM Tour_Outcome__c
      											 ]; 

      system.assertEquals(
      	1,
      	Ts.size(),
      	'A tour record should be created'
      );

      //check opportunity
      /*Opportunity[] Os = [SELECT id 
      										FROM Opportunity
      									 ];

      system.assertEquals(
      	2,
      	Os.size(),
      	'There should be 2 opportunities (one closed and a brand new open)'
      );*/
	//}
	
	//	* Existing member with email and account_uuid
	//	POST /services/apexrest/Tour/
	//		{
	//		  "first_name": "Sai",
	//		  "last_name": "Wong",
	//		  "email": "sai.wong@wework.com",
	//		  "phone": "516-606-3843",
	//		  "company_name": "Friends of WeWork",
	//		  "lead_source": "Walk-In Tour",
	//		  "tour_building_uuid": "ec573c00-59e4-0131-b9d5-3a00bb45c91f",
	//		  "tour_date": "2016-02-26",
	//		  "tour_time": "4:00PM",
	//		  "account_uuid": "0b13cfad-1afd-4809-bb1d-83a1366b5325"
	//		}
	//
	/*@isTest static void test_existing_member_with_email_and_account_uuid() {
		//pre-context

			//set internal clock
      Now.setGMT(2016, 2, 5, 8, 0, 0); //friday 2/5/16 8:00am 

			//account*/
	 		/*Account a = new Account(
	 			name = 'WeWork',
	 			uuid__c = '40e88040-8251-0130-f786-123138068411'
	 		);
	 		insert a;*/

			/*Account a = new Account(
                name = 'WeWork'
            );
            insert a;

	 		//create primary member
	 		Contact c_primary = new Contact(
	 			firstname = 'Paul',
	 			lastname = 'Boss',
	 			email = 'paul@boss.com',
	 			AccountId = a.id,
	 			uuid__c = 'xxx123'
	 		);
	 		insert c_primary;

	 		//make primary
	 		a.Primary_Member__c = c_primary.id;
	 		update a;

	 		//create regular member
	 		Contact c_regular = new Contact(
	 			firstname = 'John',
	 			lastname = 'Doe',
	 			email = 'john@doe.com',
	 			AccountId = a.id,
	 			uuid__c = 'yyy123'
	 		);
	 		insert c_regular;

	 		//opportunity
	 		Opportunity o = new Opportunity(
	 			name 					= 'test closed oppty',
	 			AccountId 				= a.id,
	 			Primary_Member__c = c_primary.id,
	 			stageName 				= 'Closed Lost',
	 			lost_reason__c 		= 'Not Interested',
	 			closeDate 				= System.today()
	 		);
	 		insert o;

	 		//contact to be used as target
			Contact target = c_regular;

			//payload
			WWTypes.InboundLead j = new WWTypes.InboundLead();
			j.first_name 					= target.firstname;
			j.last_name 					= target.lastname;
			j.email 							= target.email;
			j.phone 							= target.phone;
			j.company_name 				= a.name;
			j.lead_source 				= 'Walk-In Tour';
			j.tour_building_uuid 	= 'abc123';
			j.tour_date 					= Date.newInstance(2016, 2, 25);
			j.tour_time 					= '4:00PM';
			j.account_uuid 				= a.uuid__c;
			j.contact_uuid              = 'yyy123';

		//test
		Test.startTest();             

      RestRequest req 	= new RestRequest(); 
      RestResponse res 	= new RestResponse();
      
      // pass the req and resp objects to the method		 
      req.requestURI = 'https://cs45.salesforce.com/services/apexrest/Tour';  
      req.httpMethod = 'POST';
      
      //assign rest context
      RestContext.request 	= req;
      RestContext.response 	= res;
      
      //submit post
      RESTTour.Response response = RESTTour.doPost(j);
        
      Test.stopTest();
      //confirm response
      system.assertEquals(true, response.success, 'Response msg: ' + response.message);

      //check tour outcome
      Tour_Outcome__c[] Ts = [SELECT id 
      												FROM Tour_Outcome__c
      											 ]; 

      system.assertEquals(
      	1,
      	Ts.size(),
      	'A tour record should be created'
      );

      //check opportunity
      /*Opportunity[] Os = [SELECT id 
      										FROM Opportunity
      									 ];

      system.assertEquals(
      	2,
      	Os.size(),
      	'There should be 2 opportunities (one closed and a brand new open)'
      );
	}*/

	// bug: too many soql queries
	//
	// POST /services/apexRest/Tour
	//
	//{
	//	"first_name": "Yale",
	//	"last_name": "Tester",
	//	"email": "yspector+tester1@wework.com",
	//	"phone": "12312312341",
	//	"company_name": "Yale Tester Co.",
	//	"tour_uuid": "732e8d2e-e0ad-11e5-86c0-22000b8909c6",
	//	"tour_building_uuid": "ec573c00-59e4-0131-b9d5-3a00bb45c91f",
	//	"tour_date": "2016-03-01",
	//	"tour_time": "12:00PM"
	//}
	/*@isTest static void test_bug_on_toomany_soql_1() {
		//pre-context
			//set internal clock
      Now.setGMT(2016, 2, 5, 8, 0, 0); //friday 2/5/16 8:00am        
      //payload
			WWTypes.InboundLead j = new WWTypes.InboundLead();
			j.first_name 					= 'Yale';
			j.last_name 					= 'Tester';
			j.email 						= 'yspector+tester1@wework.com';
			j.phone 						= '12312312341';
			j.company_name 					= 'Yale Tester Co.';
			j.tour_building_uuid 			= 'abc123';
			//j.tour_uuid 					= '732e8d2e-e0ad-11e5-86c0-22000b8909c6';
			j.tour_date 					= DateUtilities.getNextBusinessDay(System.today());
			j.tour_time 					= '12:00PM';
			j.locale                        = 'en-US';
			j.generate_journeys 			= true;
			j.account_uuid                  = 'account_uuid';
			j.contact_uuid                  = 'contact_uuid';

		//test
		Test.startTest();
	
	  RestRequest req 	= new RestRequest(); 
      RestResponse res 	= new RestResponse();
      
      // pass the req and resp objects to the method		 
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
      req.httpMethod = 'POST';
      
      //assign rest context
      RestContext.request 	= req;
      RestContext.response 	= res;
      
      //submit post
      RESTTour.Response response = RESTTour.doPost(j);
		Test.stopTest();
      //confirm response
      system.assertEquals(true, response.success, 'Response msg: ' + response.message);
	
      //check tour outcome
      Tour_Outcome__c[] Ts = [SELECT id 
      												FROM Tour_Outcome__c
      											 ]; 

      system.assertEquals(
      	1,
      	Ts.size(),
      	'A tour record should be created'
      );
	}*/
}