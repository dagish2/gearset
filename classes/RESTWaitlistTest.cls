@isTest
private class RESTWaitlistTest {
    static {
        SalesConsoleSettings.createSettings();
    }
	@isTest static void test_post_success_1_new_opportunity() {
		//pre-context
			Account a = new Account(
				name = 'Test Account'
			);
			insert a;

			Contact c = new Contact(
				lastname 	= 'TestContact',
				AccountId = a.Id,
				email 		= 'john@doe.com'
			);
			insert c;
			
			a.Primary_Member__c = c.Id;
			update a;

			Building__c b1 = new Building__c(
				name='b1',
				uuid__c = 'abc123'
			);
			insert b1;

			Building__c b2 = new Building__c(
				name='b2',
				uuid__c = 'def456'
			);
			insert b2;
						
			Opportunity o = new Opportunity(
				type__c 							= 'Network Membership',
				AccountID 						= a.Id,
				stagename 						= 'Qualifying',
				closeDate 						= system.today(),
				Building__c 					= b1.Id,
				actual_start_date__c 	= Date.today(),
				name 									= 'Test Opportunity',
				Primary_Member__c 		= c.id
			);
			insert o;

		//test
		Test.startTest();
		RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();
      
      // pass the req and resp objects to the method		 
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Waitlist';  
      req.httpMethod = 'POST';

	 		//assign rest context
	 		RestContext.request 	= req;
	 		RestContext.response 	= res;
	 		
	 		//define container and set request Company and Reservable UUIDs
	 		WWTypes.Waitlist j 						= new WWTypes.Waitlist();	 		
	 		j.actual_start_date 					= system.today().addDays(10);
	 		j.notes 								= 'Some notes';
	 		j.email 								= 'john@doe.com';
	 		j.buildings_interested_uuids 	= new String[]{'abc123', 'def456'};
			
			//submit post
			RESTWaitlist.Response response = RESTWaitlist.doPost(j);		

			system.assertEquals(
				true,
				response.success,
				'the response should be successfully processed'
			);

			Opportunity[] Os = [	SELECT id, stagename, Primary_Member__r.email, AccountId, locations_interested__c 
														FROM Opportunity 
														WHERE stagename = 'Negotiating'															
												 ];

       		Debug.log('Opportunity Os 81==>'+Os);
			system.assertEquals(
				1,
				Os.size(),
				'One opportunity in waitlist should exist'
			);								

			system.assertEquals(
				j.email,
				Os[0].Primary_Member__r.email,
				'The primary member should have the same email address as specified on waitlist'
			);

			system.assertEquals(
				a.id,
				Os[0].AccountId,
				'The same account of the primary member should be used for the opportunity'
			);

			system.assertNotEquals(
				null,
				Os[0].locations_interested__c,
				'locations should be set'
			);

			system.assertEquals(
				true,
				(Os[0].locations_interested__c.contains(b1.name)|| Os[0].locations_interested__c.contains('B1')),
				'locations should be set'
			);

			system.assertEquals(
				true,
				Os[0].locations_interested__c.contains(b2.name),
				'locations should be set'
			);

			system.assertEquals(
				true,
				Os[0].locations_interested__c.contains(';'),
				'locations separator should be set'
			);

		Test.stopTest();
	}
    
    
    
    

	@isTest static void test_post_success_1_update_opportunity() {
		//pre-context
			Account a = new Account(
				name = 'Test Account'
			);
			insert a;

			Contact c = new Contact(
				lastname 	= 'TestContact',
				AccountId = a.Id,
				email 		= 'john@doe.com'
			);
			insert c;
			
			a.Primary_Member__c = c.Id;
			update a;

			Building__c b1 = new Building__c(
				name='b1',
				uuid__c = 'abc123'
			);
			insert b1;

			Building__c b2 = new Building__c(
				name='b2',
				uuid__c = 'def456'
			);
			insert b2;
						
			Opportunity o = new Opportunity(
				type__c 							= 'Network Membership',
				AccountID 						= a.Id,
				stagename 						= 'Negotiating',
				closeDate 						= system.today(),
				Building__c 					= b1.Id,
				actual_start_date__c 	= Date.today(),
				name 									= 'Test Opportunity',
				Primary_Member__c 		= c.id,
				locations_interested__c = 'b1'
			);
			insert o;

		//test
		Test.startTest();
			RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();
      
      // pass the req and resp objects to the method		 
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Waitlist';  
      req.httpMethod = 'POST';

	 		//assign rest context
	 		RestContext.request 	= req;
	 		RestContext.response 	= res;
	 		
	 		//define container and set request Company and Reservable UUIDs
	 		WWTypes.Waitlist j 						= new WWTypes.Waitlist();	 		
	 		j.actual_start_date 					= system.today();
	 		j.notes 											= 'Some notes';
	 		j.email 											= 'john@doe.com';
	 		j.buildings_interested_uuids 	= new String[]{'abc123', 'def456'};
			
			//submit post
			RESTWaitlist.Response response = RESTWaitlist.doPost(j);		

			Opportunity[] Os = [	SELECT id, locations_interested__c 
														FROM Opportunity 
														WHERE stagename = 'Negotiating'															
												 ];
        	

			system.assertEquals(
				1,
				Os.size(),
				'One opportunity in waitlist should exist'
			);

        	debug.log('Os==>'+Os);
        system.assertEquals(
            true,
            (Os[0].locations_interested__c.contains(b1.name)|| Os[0].locations_interested__c.contains('B1')) &&
            Os[0].locations_interested__c.contains('b2') &&
            Os[0].locations_interested__c.contains(';'),
            'locations_interested__c should be merged'
        );		

		Test.stopTest();
	}

	@isTest static void test_post_success_2_update_opportunity() {
		//pre-context
			Account a = new Account(
				name = 'Test Account'
			);
			insert a;

			Contact c = new Contact(
				lastname 	= 'TestContact',
				AccountId = a.Id,
				email 		= 'john@doe.com'
			);
			insert c;
			
			a.Primary_Member__c = c.Id;
			update a;

			Building__c b1 = new Building__c(
				name='b1',
				uuid__c = 'abc123'
			);
			insert b1;

			Building__c b2 = new Building__c(
				name='b2',
				uuid__c = 'def456'
			);
			insert b2;
						
			Opportunity o = new Opportunity(
				type__c 							= 'Network Membership',
				AccountID 						= a.Id,
				stagename 						= 'Negotiating',
				closeDate 						= system.today(),
				Building__c 					= b1.Id,
				actual_start_date__c 	= Date.today(),
				name 									= 'Test Opportunity',
				Primary_Member__c 		= c.id,
				locations_interested__c = null
			);
			insert o;

		//test
		Test.startTest();
			RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();
      
      // pass the req and resp objects to the method		 
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Waitlist';  
      req.httpMethod = 'POST';

	 		//assign rest context
	 		RestContext.request 	= req;
	 		RestContext.response 	= res;
	 		
	 		//define container and set request Company and Reservable UUIDs
	 		WWTypes.Waitlist j 						= new WWTypes.Waitlist();	 		
	 		j.actual_start_date 					= system.today();
	 		j.notes 											= 'Some notes';
	 		j.email 											= 'john@doe.com';
	 		j.buildings_interested_uuids 	= new String[]{'abc123', 'def456'};
			
			//submit post
			RESTWaitlist.Response response = RESTWaitlist.doPost(j);		

			Opportunity[] Os = [	SELECT id, locations_interested__c 
														FROM Opportunity 
														WHERE stagename = 'Negotiating'															
												 ];

			system.assertEquals(
				1,
				Os.size(),
				'One opportunity in waitlist should exist'
			);

			system.assertEquals(
				true,
				(Os[0].locations_interested__c.contains(b1.name)|| Os[0].locations_interested__c.contains('B1')) &&
				Os[0].locations_interested__c.contains('b2') &&
				Os[0].locations_interested__c.contains(';'),
				'locations_interested__c should be merged'
			);		

		Test.stopTest();
	}

	@isTest static void test_post_success_3_update_opportunity() {
		//pre-context
			Account a = new Account(
				name = 'Test Account'
			);
			insert a;

			Contact c = new Contact(
				lastname 	= 'TestContact',
				AccountId = a.Id,
				email 		= 'john@doe.com'
			);
			insert c;
			
			a.Primary_Member__c = c.Id;
			update a;

			Building__c b1 = new Building__c(
				name='b1',
				uuid__c = 'abc123'
			);
			insert b1;

			Building__c b2 = new Building__c(
				name='b2',
				uuid__c = 'def456'
			);
			insert b2;
						
			Opportunity o = new Opportunity(
				type__c 							= 'Network Membership',
				AccountID 						= a.Id,
				stagename 						= 'Negotiating',
				closeDate 						= system.today(),
				Building__c 					= b1.Id,
				actual_start_date__c 	= Date.today(),
				name 									= 'Test Opportunity',
				Primary_Member__c 		= c.id,
				locations_interested__c = 'b1'
			);
			insert o;

		//test
		Test.startTest();
			RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();
      
      // pass the req and resp objects to the method		 
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Waitlist';  
      req.httpMethod = 'POST';

	 		//assign rest context
	 		RestContext.request 	= req;
	 		RestContext.response 	= res;
	 		
	 		//define container and set request Company and Reservable UUIDs
	 		WWTypes.Waitlist j 						= new WWTypes.Waitlist();	 		
	 		j.actual_start_date 					= system.today();
	 		j.notes 											= 'Some notes';
	 		j.email 											= 'john@doe.com';
	 		j.buildings_interested_uuids 	= null;
			
			//submit post
			RESTWaitlist.Response response = RESTWaitlist.doPost(j);		

			Opportunity[] Os = [	SELECT id, locations_interested__c 
														FROM Opportunity 
														WHERE stagename = 'Negotiating'															
												 ];

			system.assertEquals(
				1,
				Os.size(),
				'One opportunity in waitlist should exist'
			);

			system.assertEquals(
				true,
				(Os[0].locations_interested__c.contains(b1.name)|| Os[0].locations_interested__c.contains('B1')),
				'locations_interested__c should be merged'
			);		

		Test.stopTest();
	}

	@isTest static void test_post_success_4_update_opportunity() {
		//pre-context
			Account a = new Account(
				name = 'Test Account'
			);
			insert a;

			Contact c = new Contact(
				lastname 	= 'TestContact',
				AccountId = a.Id,
				email 		= 'john@doe.com'
			);
			insert c;
			
			a.Primary_Member__c = c.Id;
			update a;

			Building__c b1 = new Building__c(
				name='b1',
				uuid__c = 'abc123'
			);
			insert b1;

			Building__c b2 = new Building__c(
				name='b2',
				uuid__c = 'def456'
			);
			insert b2;
						
			Opportunity o = new Opportunity(
				type__c 							= 'Network Membership',
				AccountID 						= a.Id,
				stagename 						= 'Negotiating',
				closeDate 						= system.today(),
				Building__c 					= b1.Id,
				actual_start_date__c 	= Date.today(),
				name 									= 'Test Opportunity',
				Primary_Member__c 		= c.id,
				locations_interested__c = null
			);
			insert o;

		//test
		Test.startTest();
			RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();
      
      // pass the req and resp objects to the method		 
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Waitlist';  
      req.httpMethod = 'POST';

	 		//assign rest context
	 		RestContext.request 	= req;
	 		RestContext.response 	= res;
	 		
	 		//define container and set request Company and Reservable UUIDs
	 		WWTypes.Waitlist j 						= new WWTypes.Waitlist();	 		
	 		j.actual_start_date 					= system.today();
	 		j.notes 											= 'Some notes';
	 		j.email 											= 'john@doe.com';
	 		j.buildings_interested_uuids 	= null;
			
			//submit post
			RESTWaitlist.Response response = RESTWaitlist.doPost(j);		

			Opportunity[] Os = [	SELECT id, locations_interested__c 
														FROM Opportunity 
														WHERE stagename = 'Negotiating'															
												 ];

			system.assertEquals(
				1,
				Os.size(),
				'One opportunity in waitlist should exist'
			);

			system.assertEquals(
				null,
				Os[0].locations_interested__c ,
				'locations_interested__c should be empty'
			);		

		Test.stopTest();
	}

	@isTest static void test_post_failure_1_email_doesnt_exist() {
		//pre-context
			//...	

		//test
		Test.startTest();
			RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();
      
      // pass the req and resp objects to the method		 
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Waitlist';  
      req.httpMethod = 'POST';

	 		//assign rest context
	 		RestContext.request 	= req;
	 		RestContext.response 	= res;
	 		
	 		//define container and set request Company and Reservable UUIDs
	 		WWTypes.Waitlist j 						= new WWTypes.Waitlist();	 		
	 		j.actual_start_date 					= system.today();
	 		j.notes 											= 'Some notes';
	 		j.email 											= 'unexisting_email@doe.com';
	 		j.buildings_interested_uuids 	= new String[]{'abc123', 'def456'};
			
			//submit post
			RESTWaitlist.Response response = RESTWaitlist.doPost(j);		

			system.assertEquals(
				false,
				response.success,
				'an exception should be catched when the email is not found'
			);

		Test.stopTest();
	}
}