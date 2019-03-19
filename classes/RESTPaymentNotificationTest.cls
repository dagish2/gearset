@isTest
private class RESTPaymentNotificationTest {
    static {
        SalesConsoleSettings.createSettings();
    }
	@isTest static void test_success() {
		//pre-context
		
			Account a = new Account(
				name = 'Test Account',
				WW_Synced__c = true,
				WW_Sync_Request__c = false,
				ID_Creation_Status_Code__c = '200'
			);
			insert a;

			Contact c = new Contact(
				firstname = 'John',
				lastname = 'Rambo',
				email = 'john@rambo.com',
				accountID = a.Id,
				Status__c = 'active'
			);
			insert c;

			//hack to use the same uuid as on mock services
			c.UUID__c = '89d850f0-4bdd-0131-6a4b-10ddb1c23555';
			update c;

			//add contact as primary member
			a.Primary_Member__c = c.Id;
			update a;

			Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'abc123',
				email__c = 'b1@wework.com'
			);
			insert b;

			Opportunity o = new Opportunity(
				AccountID 						= a.Id,
				CloseDate 						= system.today(),
				Actual_Start_Date__c 	= system.today(),
				StageName 						= 'Qualifying',
				Name 									= 'test Opoortunity',
				Building__c						= b.Id,
                Primary_Member__c				= c.Id,
                Encoded_ID__c					= '10'
			);
			insert o;

			// to avoid validation error
			Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id);
			insert r;
			Opportunity_Reservable__c res = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id);
			insert res;

			//update stage
			o.StageName = 'Closing';
			update o;

		//test
		Test.startTest();

			//submit post
			RESTPaymentNotification.Response result = RESTPaymentNotification.doPost( String.valueOf(o.Id), 'http://google.com' );
	
			//confirm result
			system.assertEquals(true, result.success, 'Something went wrong: ' + result.message);

			//re-query
			o = [SELECT Signed_Contract_URL__c, StageName FROM Opportunity WHERE Id = :o.Id LIMIT 1];

			system.assertEquals(
				'http://google.com', 
				o.Signed_Contract_URL__c, 
				'After receiving a singned contract the associated opportunity have the URL link to see it'
			);

			system.assertEquals(
				'Closed Won', 
				o.StageName, 
				'After receiving a singned contract the associated opportunity stage should be Closed Won'
			);

		Test.stopTest();
	}

	@isTest static void test_failure() {
		//pre-context
	
		//test
		Test.startTest();

			//submit post
			RESTPaymentNotification.Response result = RESTPaymentNotification.doPost( 'Not a valid opportunity ID', null );
	
			//confirm result
			system.assertEquals(false, result.success);
		Test.stopTest();
	}
	
}