@isTest
private class BuildingHandlerTest {

    static{
        SalesConsoleSettings.createSettings();
    }
    
	/*
	*	Single Account, with opportunity closed won on insert
	*/
	@isTest static void test_get_building_uuid_1() {
		//pre-context
			Account t = new Account(
				name = 'Test Account'
			);

			//dml
			insert t;

			Contact c = new Contact();
			c.LastName = 'TestContact';
        	c.Email = 'testcontact@example.com';
			c.AccountId = t.Id;
			insert c;
			
			t.Primary_Member__c = c.Id;
			update t;

			Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'abc123'
			);
			insert b;
						
			Opportunity o = new Opportunity(
				Type__c = 'Network Membership',
				AccountID = t.Id,
                Primary_Member__c = c.Id,
				StageName = 'Qualifying',
				CloseDate = system.today(),
				Building__c = b.Id,
				Actual_Start_Date__c = Date.today(),
				name 			= 'Test Opportunity',
                Network_Monthly_Conference_Room_Credits__c = 1,
                Network_Monthly_Membership_Fee__c = 100,
                Network_Set_Up_Fee__c = 100,
                Primary_Member_Email__c = 'testcontact@example.com',
                Encoded_ID__c = '10'
			);

			//dml
			insert o;

			//update to closed won
			o.StageName = 'Closed Won';
			update o;
			
		//test
		Test.startTest();
			
			String actual = BuildingHandler.getBuildingUUIDByAccount(t.Id);
			system.assertEquals(b.UUID__c, actual);

		Test.stopTest();
	}

	/*
	*	Single Account, no opportunity 
	*/
	@isTest static void test_get_building_uuid_2() {
		//pre-context
			Account t = new Account(
				name = 'Test Account'
			);

			//dml
			insert t;
						
		//test
		Test.startTest();
			
			String actual = BuildingHandler.getBuildingUUIDByAccount(t.Id);
			system.assertEquals(null, actual);

		Test.stopTest();
	}

	/*
	*	Single Account, with 2 opportunities closed won on insert
	*/
	@isTest static void test_get_building_uuid_3() {
		//pre-context
			Account t = new Account(
				name = 'Test Account'
			);

			//dml
			insert t;

			Contact c = new Contact();
			c.LastName = 'TestContact';
        	c.Email = 'testcontact@example.com';
			c.AccountId = t.Id;
			insert c;
			
			t.Primary_Member__c = c.Id;
			update t;

			Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'abc123'
			);
			insert b;
					
			Opportunity o = new Opportunity(
				Type__c = 'Network Membership',
				AccountID = t.Id,
                Primary_Member__c = c.Id,
				StageName = 'Qualifying',
				CloseDate = system.today(),
				Building__c = b.Id,
				Actual_Start_Date__c = Date.today(),
				name 			= 'Test Opportunity',
                Network_Monthly_Conference_Room_Credits__c = 1,
                Network_Monthly_Membership_Fee__c = 100,
                Network_Set_Up_Fee__c = 100,
                Primary_Member_Email__c = 'testcontact@example.com',
                Encoded_ID__c = '10'
			);

			//dml
			insert o;

			//update to closed won
			o.StageName = 'Closed Won';
			update o;

			Building__c b2 = new Building__c(
				Name='b2',
				uuid__c = 'zyx789'
			);
			insert b2;
        
        	Test.startTest();

			Opportunity o2 = new Opportunity(
				Type__c = 'Network Membership',
				AccountID = t.Id,
                Primary_Member__c = c.Id,
				StageName = 'Qualifying',
				CloseDate = system.today(),
				Building__c = b2.Id,
				Actual_Start_Date__c = Date.today(),
				name 			= 'Test Opportunity',
                Network_Monthly_Conference_Room_Credits__c = 1,
                Network_Monthly_Membership_Fee__c = 100,
                Network_Set_Up_Fee__c = 100,
                Primary_Member_Email__c = 'testcontact@example.com',
                Encoded_ID__c = '10'
			);

			//dml
			insert o2;

			//update to closed won
			o2.StageName = 'Closed Won';
			update o2;
			
			String actual = BuildingHandler.getBuildingUUIDByAccount(t.Id);
			system.assertEquals(b.UUID__c, actual);

		Test.stopTest();
	}

	@isTest static void test_get_building_id_by_uuid_1() {
		//pre-context
			Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'abc123'
			);
			insert b;

		//test
		Test.startTest();
			
			system.assertEquals(
				b.id,
				BuildingHandler.getBuildingIdByUUID('abc123'),
				'The building should be selected with the provided uuid'
			);

		Test.stopTest();
	}

	@isTest static void test_get_building_id_by_uuid_2() {
		//pre-context
			Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'abc123'
			);
			insert b;

		//test
		Test.startTest();
			
			system.assertEquals(
				null,
				BuildingHandler.getBuildingIdByUUID('not-uuid-123'),
				'No building with the provided uuid'
			);
			
		Test.stopTest();
	}

	@isTest static void test_get_building_id_by_uuid_3() {
		//pre-context
			Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'abc123'
			);
			insert b;

		//test
		Test.startTest();
			
			system.assertEquals(
				null,
				BuildingHandler.getBuildingIdByUUID(null),
				'No building with the provided uuid'
			);
			
		Test.stopTest();
	}

	@isTest static void test_get_buildings_by_uuid_0() {
		//pre-context			
			insert new Building__c[]{
				new Building__c(
					name = 'b1',
					uuid__c = 'abc123'
				),
				new Building__c(
					name = 'b2',
					uuid__c = 'mnp123'
				),
				new Building__c(
					name = 'b3',
					uuid__c = 'xyz123'
				)
			};

			String[] uuids = new String[]{};
			
		//test
		Test.startTest();
	
			String result = BuildingHandler.getMultipicklistValuesFromUUID(uuids);

			system.assertEquals(
				null,
				result,
				'empty uuids should return null'
			);
			
		Test.stopTest();
	}

	@isTest static void test_get_buildings_by_uuid_00() {
		//pre-context			
			insert new Building__c[]{
				new Building__c(
					name = 'b1',
					uuid__c = 'abc123'
				),
				new Building__c(
					name = 'b2',
					uuid__c = 'mnp123'
				),
				new Building__c(
					name = 'b3',
					uuid__c = 'xyz123'
				)
			};

			String[] uuids = null;
			
		//test
		Test.startTest();
	
			String result = BuildingHandler.getMultipicklistValuesFromUUID(uuids);

			system.assertEquals(
				null,
				result,
				'empty uuids should return null'
			);
			
		Test.stopTest();
	}

	@isTest static void test_get_buildings_by_uuid_1() {
		//pre-context			
			insert new Building__c[]{
				new Building__c(
					name = 'b1',
					uuid__c = 'abc123'
				),
				new Building__c(
					name = 'b2',
					uuid__c = 'mnp123'
				),
				new Building__c(
					name = 'b3',
					uuid__c = 'xyz123'
				)
			};

			String[] uuids = new String[]{
				'abc123',
				'xyz123'
			};

		//test
		Test.startTest();
	
			String result = BuildingHandler.getMultipicklistValuesFromUUID(uuids);

			system.assertNotEquals(
				null,
				result,
				'existing uuids must return a value'
			);

			system.assert(
				result.contains('b1') &&
				result.contains('b3') &&
				result.contains(';'),
				'result should contain buildings names separated by semi-colon'
			);

		Test.stopTest();
	}

	@isTest static void test_get_buildings_by_uuid_2() {
		//pre-context			
			insert new Building__c[]{
				new Building__c(
					name = 'b1',
					uuid__c = 'abc123'
				),
				new Building__c(
					name = 'b2',
					uuid__c = 'mnp123'
				),
				new Building__c(
					name = 'b3',
					uuid__c = 'xyz123'
				)
			};

			String[] uuids = new String[]{
				'xyz123'
			};

		//test
		Test.startTest();
	
			String result = BuildingHandler.getMultipicklistValuesFromUUID(uuids);

			system.assertNotEquals(
				null,
				result,
				'existing uuids must return a value'
			);

			system.assert(				
				result.contains('b3') &&
				!result.contains(';'),
				'result should contain building name without semi-colon'
			);

		Test.stopTest();
	}

	@isTest static void test_get_buildings_uuids_by_multipicklist_0() {
		//pre-context
			insert new Building__c[]{
				new Building__c(
					name = 'b1',
					uuid__c = 'abc123'
				),
				new Building__c(
					name = 'b2',
					uuid__c = 'mnp123'
				),
				new Building__c(
					name = 'b3',
					uuid__c = 'xyz123'
				)
			};

			String multipicklist = '';

		//test
		Test.startTest();

			String[] result = BuildingHandler.getUUIDsFromMultipicklistValues(multipicklist);
	
			system.assertNotEquals(
				null,
				result,
				'existing buidlings must return a value'
			);

			system.assertEquals(
				0,
				result.size(),
				'elements in response are incorrect'
			);

		Test.stopTest();
	}

	@isTest static void test_get_buildings_uuids_by_multipicklist_00() {
		//pre-context
			insert new Building__c[]{
				new Building__c(
					name = 'b1',
					uuid__c = 'abc123'
				),
				new Building__c(
					name = 'b2',
					uuid__c = 'mnp123'
				),
				new Building__c(
					name = 'b3',
					uuid__c = 'xyz123'
				)
			};

			String multipicklist = null;

		//test
		Test.startTest();

			String[] result = BuildingHandler.getUUIDsFromMultipicklistValues(multipicklist);
	
			system.assertNotEquals(
				null,
				result,
				'existing buidlings must return a value'
			);

			system.assertEquals(
				0,
				result.size(),
				'elements in response are incorrect'
			);

		Test.stopTest();
	}

	@isTest static void test_get_buildings_uuids_by_multipicklist_1() {
		//pre-context
			insert new Building__c[]{
				new Building__c(
					name = 'b1',
					uuid__c = 'abc123'
				),
				new Building__c(
					name = 'b2',
					uuid__c = 'mnp123'
				),
				new Building__c(
					name = 'b3',
					uuid__c = 'xyz123'
				)
			};

			String multipicklist = 'b3;b1';

		//test
		Test.startTest();

			String[] result = BuildingHandler.getUUIDsFromMultipicklistValues(multipicklist);
			debug.log('result:'+result);
			system.assertNotEquals(
				null,
				result,
				'existing buidlings must return a value'
			);

			system.assertEquals(
				2,
				result.size(),
				'elements in response are incorrect'
			);

			system.assert(
				(result[0] == 'abc123' &&
				result[1] == 'xyz123') ||
				(result[1] == 'abc123' &&
				result[0] == 'xyz123'),
				'wrong uuids calculated'
			);

		Test.stopTest();
	}

	@isTest static void test_get_buildings_uuids_by_multipicklist_2() {
		//pre-context
			insert new Building__c[]{
				new Building__c(
					name = 'b1',
					uuid__c = 'abc123'
				),
				new Building__c(
					name = 'b2',
					uuid__c = 'mnp123'
				),
				new Building__c(
					name = 'b3',
					uuid__c = 'xyz123'
				)
			};

			String multipicklist = 'b3';

		//test
		Test.startTest();

			String[] result = BuildingHandler.getUUIDsFromMultipicklistValues(multipicklist);
	
			system.assertNotEquals(
				null,
				result,
				'existing buidlings must return a value'
			);

			system.assertEquals(
				1,
				result.size(),
				'elements in response are incorrect'
			);

			system.assert(
				result[0] == 'xyz123',
				'wrong uuids calculated'
			);

		Test.stopTest();
	}
    @isTest static void test_getSpecificBuildings() {
        List<Building__c> lstBuildings = new List<Building__c> ();
        lstBuildings.add(new Building__c(name = 'build-1',uuid__c = 'building-1'));
        lstBuildings.add(new Building__c(name = 'build-2',uuid__c = 'building-2'));
        lstBuildings.add(new Building__c(name = 'build-3',uuid__c = 'building-3'));
        TestingUtility.insertListWithAssert(lstBuildings);
        
        List<Building__c> fetchedBulidings = BuildingHandler.getSpecificBuildings(new Set<String>{lstBuildings[0].name,lstBuildings[1].name,lstBuildings[2].name,lstBuildings[2].name});
        
        System.assertEquals(lstBuildings[0].name, fetchedBulidings[0].name, 'Building Not found with this name');
        System.assertEquals(lstBuildings[1].name, fetchedBulidings[1].name, 'Building Not found with this name');
        System.assertEquals(lstBuildings[2].name, fetchedBulidings[2].name, 'Building Not found with this name');
    }
	
}