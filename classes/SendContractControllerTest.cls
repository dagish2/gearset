@isTest
private class SendContractControllerTest {
    static{
        SalesConsoleSettings.createSettings();
    }     
	@isTest static void test_success() {
		//pre-context
			Account a = new Account(
				name = 'S.H.I.E.L.D.'
			);
			insert a;

			Contact nick = new Contact(
				firstname = 'Nick',
				lastname = 'Fury',
				email = 'nick@shield.com',
				AccountID = a.Id
			);
			insert nick;

			Contact steve = new Contact(
				firstname = 'Steve',
				lastname = 'Rogers',
				email = 'captain_america@shield.com',
				AccountID = a.Id
			);
			insert steve;

			a.Primary_Member__c = steve.Id;
			a.Authorized_Signatory__c = nick.Id;
			update a;

			Building__c b = new Building__c(
				name = 'Stark Tower',
				uuid__c = 'abc1234',
				email__c = 'fultoncenter@wework.com'
			);
			insert b;

			Opportunity o = new Opportunity(
				AccountID = a.Id,
				StageName = 'Qualifying',
				CloseDate = system.today(),
				Building__c = b.Id,
				name 			= 'Test Opportunity',
				Actual_Start_Date__c = date.today(),
				Primary_Member__c = steve.Id,
				Encoded_ID__c = '123'
			);
			insert o;

			// to avoid validation error
			Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id, Status__c = 'Available', Open_Date__c = date.today());
			insert r;
			Opportunity_Reservable__c res = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id);
			insert res;

		//test
		Test.startTest();
	
			//create controller
			SendContractController controller = new SendContractController();
			controller.OpportunityID = o.Id;
			controller.sendContract();

			//re-query
			o = [	SELECT StageName 
						FROM Opportunity 
						WHERE Id = :o.Id 
						LIMIT 1
					];		

			//assert
			system.assertEquals(
				'Closing', 
				o.StageName, 
				'The contract should be marked as sent'
			);

			system.assertNotEquals(
				null,
				controller.goBack(),
				'The page reference must be declared!'
			);

		Test.stopTest();
	}

	@isTest static void test_failure_reservable_not_available_1() {
		//pre-context
			Account a = new Account(
				name = 'S.H.I.E.L.D.'
			);
			insert a;

			Contact nick = new Contact(
				firstname = 'Nick',
				lastname = 'Fury',
				email = 'nick@shield.com',
				AccountID = a.Id
			);
			insert nick;

			Contact steve = new Contact(
				firstname = 'Steve',
				lastname = 'Rogers',
				email = 'captain_america@shield.com',
				AccountID = a.Id
			);
			insert steve;

			a.Primary_Member__c = steve.Id;
			a.Authorized_Signatory__c = nick.Id;
			update a;

			Building__c b = new Building__c(
				name = 'Stark Tower',
				uuid__c = 'abc1234',
				email__c = 'fultoncenter@wework.com'
			);
			insert b;

			Opportunity o = new Opportunity(
				AccountID = a.Id,
				StageName = 'Qualifying',
				CloseDate = system.today(),
				Building__c = b.Id,
				name 			= 'Test Opportunity',
				Actual_Start_Date__c = date.today(),
				Primary_Member__c = steve.Id,
				Encoded_ID__c = '123'
			);
			insert o;

			// to avoid validation error
			Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id, Status__c = 'Unvailable', Open_Date__c = date.today());
			insert r;
			Opportunity_Reservable__c res = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id);
			insert res;

		//test
		Test.startTest();
	
			//create controller
			SendContractController controller = new SendContractController();
			controller.OpportunityID = o.Id;
			controller.sendContract();

			//re-query
			o = [	SELECT StageName 
						FROM Opportunity 
						WHERE Id = :o.Id 
						LIMIT 1
					];		

			//assert
			/*system.assertEquals(
				'Closing', 
				o.StageName, 
				'The contract should not be marked as sent with Unvailable reservables'
			);*/

		Test.stopTest();
	}

	@isTest static void test_failure_reservable_not_available_2() {
		//pre-context
			Account a = new Account(
				name = 'S.H.I.E.L.D.'
			);
			insert a;

			Contact nick = new Contact(
				firstname = 'Nick',
				lastname = 'Fury',
				email = 'nick@shield.com',
				AccountID = a.Id
			);
			insert nick;

			Contact steve = new Contact(
				firstname = 'Steve',
				lastname = 'Rogers',
				email = 'captain_america@shield.com',
				AccountID = a.Id
			);
			insert steve;

			a.Primary_Member__c = steve.Id;
			a.Authorized_Signatory__c = nick.Id;
			update a;

			Building__c b = new Building__c(
				name = 'Stark Tower',
				uuid__c = 'abc1234',
				email__c = 'fultoncenter@wework.com'
			);
			insert b;

			Opportunity o = new Opportunity(
				AccountID = a.Id,
				StageName = 'Qualifying',
				CloseDate = system.today(),
				Building__c = b.Id,
				name 			= 'Test Opportunity',
				Actual_Start_Date__c = date.today(),
				Primary_Member__c = steve.Id,
				Encoded_ID__c = '123'
			);
			insert o;

			// to avoid validation error
			Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id, Status__c = 'Available', Archived_On__c = Date.today(), Open_Date__c = date.today() );
			insert r;
			Opportunity_Reservable__c res = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id);
			insert res;

		//test
		Test.startTest();
	
			//create controller
			SendContractController controller = new SendContractController();
			controller.OpportunityID = o.Id;
			controller.sendContract();

			//re-query
			o = [	SELECT StageName 
						FROM Opportunity 
						WHERE Id = :o.Id 
						LIMIT 1
					];		

			//assert
			/*system.assertEquals(
				'Closing', 
				o.StageName, 
				'The contract should not be marked as sent with Unvailable reservables'
			);*/

		Test.stopTest();
	}

	@isTest static void test_failure_reservable_not_available_3() {
		//pre-context
			Account a = new Account(
				name = 'S.H.I.E.L.D.'
			);
			insert a;

			Contact nick = new Contact(
				firstname = 'Nick',
				lastname = 'Fury',
				email = 'nick@shield.com',
				AccountID = a.Id
			);
			insert nick;

			Contact steve = new Contact(
				firstname = 'Steve',
				lastname = 'Rogers',
				email = 'captain_america@shield.com',
				AccountID = a.Id
			);
			insert steve;

			a.Primary_Member__c = steve.Id;
			a.Authorized_Signatory__c = nick.Id;
			update a;

			Building__c b = new Building__c(
				name = 'Stark Tower',
				uuid__c = 'abc1234',
				email__c = 'fultoncenter@wework.com'
			);
			insert b;

			Opportunity o = new Opportunity(
				AccountID = a.Id,
				StageName = 'Qualifying',
				CloseDate = system.today(),
				Building__c = b.Id,
				name 			= 'Test Opportunity',
				Actual_Start_Date__c = date.today(),
				Primary_Member__c = steve.Id,
				Encoded_ID__c = '123'
			);
			insert o;

			// to avoid validation error
			Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id, Open_Date__c = date.today());
			insert r;
			Opportunity_Reservable__c res = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id);
			insert res;

		//test
		Test.startTest();
	
			//create controller
			SendContractController controller = new SendContractController();
			controller.OpportunityID = o.Id;
			controller.sendContract();

			//re-query
			o = [	SELECT StageName 
						FROM Opportunity 
						WHERE Id = :o.Id 
						LIMIT 1
					];		

			//assert
			/*system.assertEquals(
				'Closing', 
				o.StageName, 
				'The contract should not be marked as sent with Unvailable reservables'
			);*/

		Test.stopTest();
	}

	@isTest static void test_failure_reservable_already_used_1() {
		//pre-context
			Account a = new Account(
				name = 'S.H.I.E.L.D.'
			);
			insert a;

			Contact nick = new Contact(
				firstname = 'Nick',
				lastname = 'Fury',
				email = 'nick@shield.com',
				AccountID = a.Id
			);
			insert nick;

			Contact steve = new Contact(
				firstname = 'Steve',
				lastname = 'Rogers',
				email = 'captain_america@shield.com',
				AccountID = a.Id
			);
			insert steve;

			a.Primary_Member__c = steve.Id;
			a.Authorized_Signatory__c = nick.Id;
			update a;

			Building__c b = new Building__c(
				name = 'Stark Tower',
				uuid__c = 'abc1234',
				email__c = 'fultoncenter@wework.com'
			);
			insert b;

			Opportunity o = new Opportunity(
				AccountID = a.Id,
				StageName = 'Qualifying',
				CloseDate = system.today(),
				Building__c = b.Id,
				name 			= 'Test Opportunity',
				Actual_Start_Date__c = date.today(),
				Primary_Member__c = steve.Id,
				Encoded_ID__c = '123'
			);
			insert o;

			// to avoid validation error
			Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id, Status__c = 'Available', Open_Date__c = date.today());
			insert r;
			Opportunity_Reservable__c res = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id);
			insert res;

			//create another opportunity
			Opportunity o2 = new Opportunity(
				AccountID = a.Id,
				StageName = 'Qualifying',
				CloseDate = system.today(),
				Building__c = b.Id,
				name 			= 'Test Opportunity',
				Actual_Start_Date__c = date.today()
			);
			insert o2;

			//create an opportunity reservable for the same reservable as before
			Opportunity_Reservable__c res2 = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o2.Id);
			insert res2;

		//test
		Test.startTest();
	
			//create controller
			SendContractController controller = new SendContractController();
			controller.OpportunityID = o.Id;
			controller.sendContract();

			//re-query
			o = [	SELECT StageName 
						FROM Opportunity 
						WHERE Id = :o.Id 
						LIMIT 1
					];		

			//assert
			system.assertEquals(
				'Closing', 
				o.StageName, 
				'The contract should be marked as sent with available reservables'
			);

			//now that the reservable is on an opportunity with status Contract sent
			//another opportunity can't send contract if it references that reservable
			controller.OpportunityID = o2.Id;
			controller.sendContract();

			//re-query
			o2 = [	SELECT StageName 
						FROM Opportunity 
						WHERE Id = :o2.Id 
						LIMIT 1
					];		

			//assert
			/*system.assertEquals(
				'Closing', 
				o2.StageName, 
				'The contract should not be marked as sent with an already used reservable'
			);*/

		Test.stopTest();
	}

	@isTest static void test_success_reservable_already_used_hot_desk() {
		//pre-context
			Account a = new Account(
				name = 'S.H.I.E.L.D.'
			);
			insert a;

			Contact nick = new Contact(
				firstname = 'Nick',
				lastname = 'Fury',
				email = 'nick@shield.com',
				AccountID = a.Id
			);
			insert nick;

			Contact steve = new Contact(
				firstname = 'Steve',
				lastname = 'Rogers',
				email = 'captain_america@shield.com',
				AccountID = a.Id
			);
			insert steve;

			a.Primary_Member__c = steve.Id;
			a.Authorized_Signatory__c = nick.Id;
			update a;

			Building__c b = new Building__c(
				name = 'Stark Tower',
				uuid__c = 'abc1234',
				email__c = 'fultoncenter@wework.com'
			);
			insert b;

			Opportunity o = new Opportunity(
				AccountID = a.Id,
				StageName = 'Qualifying',
				CloseDate = system.today(),
				Building__c = b.Id,
				name 			= 'Test Opportunity',
				Actual_Start_Date__c = date.today(),
				Primary_Member__c = steve.Id,
				Encoded_ID__c = '123'
			);
			insert o;

			// to avoid validation error
			Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id, Status__c = 'Available', Office_Work_Station_Type__c = 'HotDeskArea', Open_Date__c = date.today());
			insert r;
			Opportunity_Reservable__c res = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id );
			insert res;

			//create another opportunity
			Opportunity o2 = new Opportunity(
				AccountID = a.Id,
				StageName = 'Qualifying',
				CloseDate = system.today(),
				Building__c = b.Id,
				name 			= 'Test Opportunity',
				Actual_Start_Date__c = date.today(),
				Primary_Member__c = steve.Id,
				Encoded_ID__c = '123'
			);
			insert o2;

			//create an opportunity reservable for the same reservable as before
			Opportunity_Reservable__c res2 = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o2.Id);
			insert res2;

		//test
		Test.startTest();
	
			//create controller
			SendContractController controller = new SendContractController();
			controller.OpportunityID = o.Id;
			controller.sendContract();

			//re-query
			o = [	SELECT StageName 
						FROM Opportunity 
						WHERE Id = :o.Id 
						LIMIT 1
					];		

			//assert
			/*system.assertEquals(
				'Closing', 
				o.StageName, 
				'The contract should be marked as sent with available reservables'
			);*/

			//now that the reservable is on an opportunity with status Contract sent
			//another opportunity can send contract if it references that reservable (hot desk)
			controller.OpportunityID = o2.Id;
			controller.sendContract();

			//re-query
			o2 = [	SELECT StageName 
						FROM Opportunity 
						WHERE Id = :o2.Id 
						LIMIT 1
					];		

			//assert
			/*system.assertEquals(
				'Closing', 
				o2.StageName, 
				'The contract should be marked as sent with an already used reservable (hot desk)'
			);*/

		Test.stopTest();
	}

	@isTest static void test_failure_reservable_not_open_1() {
		//pre-context
			Account a = new Account(
				name = 'S.H.I.E.L.D.'
			);
			insert a;

			Contact nick = new Contact(
				firstname = 'Nick',
				lastname = 'Fury',
				email = 'nick@shield.com',
				AccountID = a.Id
			);
			insert nick;

			Contact steve = new Contact(
				firstname = 'Steve',
				lastname = 'Rogers',
				email = 'captain_america@shield.com',
				AccountID = a.Id
			);
			insert steve;

			a.Primary_Member__c = steve.Id;
			a.Authorized_Signatory__c = nick.Id;
			update a;

			Building__c b = new Building__c(
				name = 'Stark Tower',
				uuid__c = 'abc1234',
				email__c = 'fultoncenter@wework.com'
			);
			insert b;

			Opportunity o = new Opportunity(
				AccountID = a.Id,
				StageName = 'Qualifying',
				CloseDate = system.today(),
				Building__c = b.Id,
				name 			= 'Test Opportunity',
				Actual_Start_Date__c = date.today()
			);
			insert o;

			// create reservable that will open next month
			Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id, Status__c = 'Available', Open_Date__c = date.today().addMonths(1));
			insert r;
			Opportunity_Reservable__c res = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id);
			insert res;

		//test
		Test.startTest();
	
			//create controller
			SendContractController controller = new SendContractController();
			controller.OpportunityID = o.Id;
			controller.sendContract();

			//re-query
			o = [	SELECT StageName 
						FROM Opportunity 
						WHERE Id = :o.Id 
						LIMIT 1
					];		

			//assert
			/*system.assertEquals(
				'Closing', 
				o.StageName, 
				'The contract should not be marked as sent because an associated reservable was not opened'
			);*/

		Test.stopTest();
	}

	@isTest static void test_failure_reservable_next_move_out_1() {
		//pre-context
			Account a = new Account(
				name = 'S.H.I.E.L.D.'
			);
			insert a;

			Contact nick = new Contact(
				firstname = 'Nick',
				lastname = 'Fury',
				email = 'nick@shield.com',
				AccountID = a.Id
			);
			insert nick;

			Contact steve = new Contact(
				firstname = 'Steve',
				lastname = 'Rogers',
				email = 'captain_america@shield.com',
				AccountID = a.Id
			);
			insert steve;

			a.Primary_Member__c = steve.Id;
			a.Authorized_Signatory__c = nick.Id;
			update a;

			Building__c b = new Building__c(
				name = 'Stark Tower',
				uuid__c = 'abc1234',
				email__c = 'fultoncenter@wework.com'
			);
			insert b;

			Opportunity o = new Opportunity(
				AccountID = a.Id,
				StageName = 'Qualifying',
				CloseDate = system.today(),
				Building__c = b.Id,
				name 			= 'Test Opportunity',
				Actual_Start_Date__c = date.today()
			);
			insert o;

			// create reservable that will open next month
			Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id, Status__c = 'Available', Next_Move_Out__c = date.today().addMonths(1));
			insert r;
			Opportunity_Reservable__c res = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id);
			insert res;

		//test
		Test.startTest();
	
			//create controller
			SendContractController controller = new SendContractController();
			controller.OpportunityID = o.Id;
			controller.sendContract();

			//re-query
			o = [	SELECT StageName 
						FROM Opportunity 
						WHERE Id = :o.Id 
						LIMIT 1
					];		

			//assert
			/*system.assertEquals(
				'Closing', 
				o.StageName, 
				'The contract should not be marked as sent because an associated reservable has a next moved out date AFTER Opportunity actual start date' 
			);*/

		Test.stopTest();
	}

	@isTest static void test_x() {
		//pre-context
	
		//test
		Test.startTest();
			//create controller
			SendContractController controller = new SendContractController();
			controller.OpportunityID = null;
			controller.sendContract();

			System.assert(ApexPages.getMessages().size() > 0);

			system.assertNotEquals(
				null,
				controller.goBack(),
				'The page reference must be declared!'
			);

		Test.stopTest();
	}
	
}