@isTest
private class RESTOpportunityVoidTest {
	static {
        SalesConsoleSettings.createSettings();
    }
    @isTest static void testPOSTSuccess() {
        
        Opportunity testOpportunity = RESTOpportunityVoidTest.createTestOpportunity();
        String id = testOpportunity.id;
        
        // Fetch again for encoded ID
        Opportunity opportunity = [select Encoded_ID__c from Opportunity where id=:id];
        String encodedId = opportunity.Encoded_ID__c;
        
        System.debug('-------- id:' + id);
        System.debug('-------- encoded id:' + encodedId);
        
        Test.startTest();
        
		RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();		 
      	req.requestURI = 'https://cs8.salesforce.com/services/apexrest/OpportunityVoid/' + encodedId;  
      	req.httpMethod = 'POST';
      	RestContext.request 	= req;
 		RestContext.response 	= res;
 		
 		RESTOpportunityVoid.Response response = RESTOpportunityVoid.doPost();
	 	
	 	System.debug(response.message);
	 	//confirm response
		system.assertEquals(true, response.success);
		
		//confirm contract stage is voided
		Opportunity o = [SELECT StageName FROM Opportunity WHERE id=:id];
		system.assertEquals('Closing', o.StageName);
      	
        Test.stopTest();
    }
    
    public static Opportunity createTestOpportunity() {
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
			Actual_Start_Date__c 	= system.today(),
			StageName 						= 'Qualifying',
			Name 							= 'test Opoortunity',
			Building__c						= b.Id,
            Primary_Member__c = john.Id
		);
		insert o;

		// to avoid validation error
		Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id,Status__c='Available',Open_Date__c=system.today().addDays(-1));
		insert r;
		Opportunity_Reservable__c opres = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id);
		insert opres;
			
		return o;
    }
    
    @isTest static void test_POST_failure() {
			Test.startTest();

			RestRequest req 	= new RestRequest(); 
	    	RestResponse res 	= new RestResponse();
	 		
			//submit post
			RESTOpportunityVoid.Response response = RESTOpportunityVoid.doPost();
	
			//confirm response
			system.assertEquals(false, response.success);
	
		Test.stopTest();
	}
}