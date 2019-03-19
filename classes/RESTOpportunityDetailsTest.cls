@isTest
private class RESTOpportunityDetailsTest {
	 static {
         SalesConsoleSettings.createSettings();
    }
	@isTest static void test_GET_failure() {
		//pre-context
	
		//test
		Test.startTest();
  	    
    	RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();
	 		String encoded_id = 'this is not a valid encoded ID';

	    // pass the req and resp objects to the method		 
	    req.requestURI = 'https://cs9.salesforce.com/services/apexrest/OpportunityDetails/' + encoded_id;  
	    req.httpMethod = 'GET';
	 
	 		//assign rest context
	 		RestContext.request 	=	req;
	 		RestContext.response 	= res;

			//submit get
			RESTOpportunityDetails.Response response = RESTOpportunityDetails.doGet();
	
			//confirm response
			system.assertEquals(false, response.success);

		Test.stopTest();
	}

	@isTest static void test_GET_success() {
		//pre-context
			Account a = new Account(
				name = 'Test Account',
				WW_Synced__c = true,
				WW_Sync_Request__c = false,
				ID_Creation_Status_Code__c = '200'
			);
			insert a;

			Contact john = new Contact(
				firstname = 'John',
				lastname = 'Rambo',
				email = 'john@rambo.com',
				accountID = a.Id,
				Status__c = 'active'
			);
			insert john;

			//add contact as primary member
			a.Primary_Member__c = john.Id;
			update a;

			Contact paul = new Contact(
				firstname = 'Paul',
				lastname = 'Rambo',
				email = 'paul@rambo.com',
				accountID = a.Id,
				Status__c = 'active'
			);
			insert paul;

			Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'abc123'
			);
			insert b;

			Opportunity o = new Opportunity(
				AccountID 						= a.Id,
				CloseDate 						= system.today(),
				Actual_Start_Date__c 			= system.today(),
				StageName 						= 'Qualifying',
				Name 							= 'test Opoortunity',
				Building__c						= b.Id,
                Primary_Member__c				= paul.Id,
                Encoded_ID__c					= '10'
			);
			insert o;

			// to avoid validation error
			Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id);
			insert r;
			Opportunity_Reservable__c opres = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id);
			insert opres;

			//update stage
			o.StageName = 'Closing';
			update o;
		//test
		Test.startTest();

			RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();
	 		String encoded_id = EncodingHandler.encode(o.Id);

	    // pass the req and resp objects to the method		 
	    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/OpportunityDetails/' + encoded_id;  
	    req.httpMethod = 'GET';
	 
	 		//assign rest context
	 		RestContext.request 	=	req;
	 		RestContext.response 	= res;
	 		
			//submit get
			RESTOpportunityDetails.Response response = RESTOpportunityDetails.doGet();
	
			//confirm response
			system.assertEquals(true, response.success);
	
		Test.stopTest();
	}

	@isTest static void test_POST_failure() {
		//pre-context
	
		//test
		Test.startTest();

			RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();
	 		WWTypes.OpportunityDetails od = new WWTypes.OpportunityDetails();
	 		od.salesforce_id = 'not a valid Id';

	    // pass the req and resp objects to the method		 
	    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/OpportunityDetails';  
	    req.httpMethod = 'POST';
	 
	 		//assign rest context
	 		RestContext.request 	=	req;
	 		RestContext.response 	= res;
	 		
			//submit post
			RESTOpportunityDetails.Response response = RESTOpportunityDetails.doPost(od);
	
			//confirm response
			system.assertEquals(false, response.success);
	
		Test.stopTest();
	}

	@isTest static void test_POST_success() {
		//pre-context
			Account a = new Account(
				name = 'Test Account',
				WW_Synced__c = true,
				WW_Sync_Request__c = false,
				ID_Creation_Status_Code__c = '200'
			);
			insert a;

			Contact john = new Contact(
				firstname = 'John',
				lastname = 'Rambo',
				email = 'john@rambo.com',
				accountID = a.Id,
				Status__c = 'active'
			);
			insert john;

			//add contact as primary member
			a.Primary_Member__c = john.Id;
			update a;

			Contact paul = new Contact(
				firstname = 'Paul',
				lastname = 'Rambo',
				email = 'paul@rambo.com',
				accountID = a.Id,
				Status__c = 'active'
			);
			insert paul;

			Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'abc123'
			);
			insert b;

			Opportunity o = new Opportunity(
				AccountID 						= a.Id,
				CloseDate 						= system.today(),
				Actual_Start_Date__c 			= system.today(),
				StageName 						= 'Qualifying',
				Name 							= 'test Opoortunity',
				Building__c						= b.Id,
                Primary_Member__c				= paul.Id,
                Encoded_ID__c					= '10'
			);
			insert o;

			// to avoid validation error
			Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id);
			insert r;
			Opportunity_Reservable__c opres = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id);
			insert opres;

			//update stage
			o.StageName = 'Closing';
			update o;

		//test
		Test.startTest();

			RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();
	 		WWTypes.OpportunityDetails od = OpportunityServices.getOpportunityDetails(o.Id);

	    // pass the req and resp objects to the method		 
	    req.requestURI = 'https://cs8.salesforce.com/services/apexrest/OpportunityDetails';  
	    req.httpMethod = 'POST';
	 
	 		//assign rest context
	 		RestContext.request 	=	req;
	 		RestContext.response 	= res;
	 		
	 		//update the company name
	 		od.company.name = 'Nakatomi';

			//submit post
			RESTOpportunityDetails.Response response = RESTOpportunityDetails.doPost(od);
	
			//confirm response
			system.assertEquals(true, response.success);

			//check if the account name was updated
			a = [SELECT name FROM Account WHERE id = :a.Id LIMIT 1];
			system.assertEquals(
				'Nakatomi', 
				a.name, 
				'The company name was not renamed.'
			);
	
		Test.stopTest();
	}
	
}