@isTest
private class RESTOpportunityInsertTest {
     static{
         SalesConsoleSettings.createSettings();
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
			a.UUID__c = 'com001';
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
				uuid__c = 'bui001'
			);
			insert b;

			// fixed
			Reservable__c r1 = new Reservable__c(Name='r1',Building__c=b.Id, uuid__c='res001', Status__c = 'Available', Open_Date__c = date.today());
			insert r1;
        
        	// fixed
			Reservable__c r2 = new Reservable__c(Name='r2',Building__c=b.Id, uuid__c='res002', Status__c = 'Available', Open_Date__c = date.today());
			insert r2;
        
        	// fixed
			Reservable__c r3 = new Reservable__c(Name='r3',Building__c=b.Id, uuid__c='res003', Status__c = 'Available', Open_Date__c = date.today());
			insert r3;

		//test
		Test.startTest();
			Contact con = [ SELECT ID,Name,UUID__c from Contact Where ID =: paul.ID ];
			RestRequest req 	= new RestRequest(); 
	    	RestResponse res 	= new RestResponse();
      
      		// pass the req and resp objects to the method		 
      		req.requestURI = System.URL.getSalesforceBaseURL().getHost() + '/services/apexrest/OpportunityInsert';  
      		req.httpMethod = 'POST';

	 		//assign rest context
	 		RestContext.request 	= req;
	 		RestContext.response 	= res;
	 		
	 		//define container and set request Company and Reservable UUIDs
	 		WWTypes.OpportunityInsert oi = new WWTypes.OpportunityInsert();
        	oi.primary_member_email = 'paul@rambo.com';
        	oi.community_user = paul.Id;
	 		oi.company_uuid 					= a.UUID__c;
	 		oi.building_uuid 					= b.uuid__c;
	 		oi.opportunity_type 			= 'Office Space';
	 		oi.community_manager_uuid = 'xxx';
	 		oi.desk_number 						= 2;
	 		oi.actual_start_date 			= system.today();
			oi.reservable_uuids 			= new String[]{r1.uuid__c, r3.uuid__c};
            //oi.send_paperwork_by            = 'Agent Paper work';
			oi.send_paperwork_by			= con.UUID__c;
			WWTypes.Discount discount1 = new WWTypes.Discount();
			discount1.amount 				= 100;
			discount1.start_date 		= system.today();
			discount1.end_date 			= system.today();
			discount1.discount_type = 'Regular Discount';
			discount1.promotion_code = 'PROMO';
			discount1.promotion_override = true;

			WWTypes.Discount discount2 = new WWTypes.Discount();
			discount2.amount 				= 200;
			discount2.start_date 		= system.today();
			discount2.end_date 			= system.today();
			discount2.discount_type = 'Regular Discount';
			discount2.promotion_code = 'PROMO';
			discount2.promotion_override = false;
			
			//collect discounts
			oi.discounts.add(discount1);
			oi.discounts.add(discount2);
			Debug.log('Test : Before doPost oi ::: ' + oi);
			//submit post
			RESTOpportunityInsert.Response response = RESTOpportunityInsert.doPost(oi);
			//confirm response
			debug.log('response--'+response);
			system.assertEquals(true, response.success);
			
        	//confirm changes send_paperwork_by__c(string to lookup(Contact))
        	Opportunity opp = [ SELECT Id,Name,send_paperwork_by__c FROM Opportunity WHERE send_paperwork_by__c = : con.ID ];
        	system.assertEquals(opp.send_paperwork_by__c, paul.Id);
        	
			//check if a new opportunity was created
			Opportunity[] Os = [SELECT id, AccountID FROM Opportunity]; //, Send_Paperwork_By__c
        	Debug.log('Test : Os ::: ' + Os);
			system.assertEquals(
				1,
				Os.size(),
				'A new opportunity should be created'
			);

			//check if the opportunity is associated to the given account
			system.assertEquals(
				a.Id,
				Os[0].AccountID,
				'The new opportunity should be associated with the right Company(Account)'
			);
        	//System.assertEquals('Send PaperWork Agent', Os[0].Send_Paperwork_By__c);
			//check if the opportunity has the right opportunity-reservables records.
			Opportunity_Reservable__c[] ORs = [	SELECT Opportunity__c, Reservable__c 
																					FROM Opportunity_Reservable__c
																				];
			system.assertEquals(
				2,
				ORs.size(),
				'Given 2 reservables on an Opportunity should result in 2 Opportunity Reservable records'
			);

			system.assertEquals(
				Os[0].id,
				ORs[0].Opportunity__c,
				'The Opportunity Reservable must be associated to the right Opportunity'
			);

			system.assertEquals(
				Os[0].id,
				ORs[1].Opportunity__c,
				'The Opportunity Reservable must be associated to the right Opportunity'
			);

			system.assert(
				r1.Id == ORs[0].Reservable__c ||
				r1.Id == ORs[1].Reservable__c,
				'The Opportunity Reservable must be associated to the right Reservable'
			);

			system.assert(
				r3.Id == ORs[0].Reservable__c ||
				r3.Id == ORs[1].Reservable__c,
				'The Opportunity Reservable must be associated to the right Reservable'
			);
	
		Test.stopTest();
	}
	
	@isTest static void test_POST_failure() {
			Test.startTest();

			RestRequest req 	= new RestRequest(); 
	    	RestResponse res 	= new RestResponse();
	 		
			//submit post
			RESTOpportunityInsert.Response response = RESTOpportunityInsert.doPost(NULL);
	
			//confirm response
			system.assertEquals(false, response.success);
	
		Test.stopTest();
	}
}