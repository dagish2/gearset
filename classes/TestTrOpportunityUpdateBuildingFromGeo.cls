/**
* @author Gad Sharon
* @date 4/10/2018
* @description  Test class for TrOpportunityUpdateBuildingFromGeo.
**/

@isTest
public class TestTrOpportunityUpdateBuildingFromGeo {

	public static list <Geography__c> lstGeographies = new list <Geography__c>();

	/* 
        Scenario: Insert 3 opportunities, 
        			2 opportunities with 2 different geography and 1 opportunity without geography.
        
        Expected: The 2 opps with geography will get the building set within the geography.
        			The opp without geography will not have a building assigned to it.
    */

	static testMethod void testInsertBuildingFromGeography()
	{
		List<Opportunity> lstOppsToUpdate = new List<Opportunity>();
		list <Opportunity> lstOpps = createTestData(true, 1);
		integer building1 = 0, building2 = 0, noBuilding = 0;

		for(Opportunity opp : lstOpps)
		{
            if(opp.Geography__c == lstGeographies[0].Id)
            {
                System.assertEquals(lstGeographies[0].Nearest_Building__c, opp.Building__c);
                building1++;
            } 
            else if(opp.Geography__c == lstGeographies[1].Id)
            {
                System.assertEquals(lstGeographies[1].Nearest_Building__c, opp.Building__c);
                
                opp.Geography__c = lstGeographies[0].Id;
                opp.Building__c = null;
                lstOppsToUpdate.add(opp);
                building2++;
            } 
            else if(opp.Geography__c == null)
            {
                System.assertEquals(null, opp.Building__c);

                opp.Geography__c = lstGeographies[1].Id;
                lstOppsToUpdate.add(opp);
                noBuilding++;
            } 
        }

        //Making sure we have tested all 3 scenrios.
        system.assertEquals(building1, 1);
        system.assertEquals(building2, 1);
        system.assertEquals(noBuilding, 1);
	}

	/*
        Scenario: Update 3 opportunities, 
        			2 opportunities with 2 different geography than they had and 1 opportunity without geography.
        
        Expected: The 2 opps with geography will get the building set within the geography.
        			The opp without geography will not have a building assigned to it.
    */

	static testMethod void testUpdateBuildingFromGeography()
	{
		list <Opportunity> lstOpps = createTestData(false, 1);
		integer building1 = 0, building2 = 0, noBuilding = 0;

		for(Opportunity opp : lstOpps)
		{
            System.assertEquals(null, opp.Building__c);
        }

    	//Clean the map of processed records to allow update processing.
    	TriggerProcessingManager.mapNumOfIterationsByProcess.remove('TrOpportunityUpdateBuildingFromGeo');

        lstOpps[0].Geography__c = lstGeographies[0].Id;
        lstOpps[1].Geography__c = lstGeographies[1].Id;
        update lstOpps;

        lstOpps = getOpps(lstOpps);
        
        for(Opportunity opp : lstOpps)
		{
            if(opp.Geography__c == lstGeographies[0].Id)
            {
                System.assertEquals(lstGeographies[0].Nearest_Building__c, opp.Building__c);
                building1++;
            } 
            else if(opp.Geography__c == lstGeographies[1].Id)
            {
                System.assertEquals(lstGeographies[1].Nearest_Building__c, opp.Building__c);
                building2++;
            } 
            else if(opp.Geography__c == null)
            {
                System.assertEquals(null, opp.Building__c);
                noBuilding++;
            } 
        }

        //Making sure we have tested all 3 scenrios.
        system.assertEquals(building1, 1);
        system.assertEquals(building2, 1);
        system.assertEquals(noBuilding, 1);

	}

	/*
        Scenario: Bulk test, making sure we don't have issues with 150 records.
        
        Expected: Opps with geography gets the geo building.
    */

	static testMethod void testBulk()
	{
		list <Opportunity> lstOpps = createTestData(true, 20);
		integer amountOfOppsWithBuilding = 0;

		for(integer i = 0; i < 50; i++)
		{
			if(lstOpps[i].Geography__c != null)
			{
				system.assertNotEquals(lstOpps[i].Building__c, null);
				lstOpps[i].Geography__c = null;
				lstOpps[i].Building__c = null;
				amountOfOppsWithBuilding++;
			}
			else
			{
				lstOpps[i].Geography__c = lstGeographies[0].Id;
			}
		}
		system.assertEquals(amountOfOppsWithBuilding, 34);

		//Clean the map of processed records to allow update processing.
        TriggerProcessingManager.mapNumOfIterationsByProcess.remove('TrOpportunityUpdateBuildingFromGeo');
       
        Test.startTest();
        update lstOpps;
        Test.stopTest();
        
		lstOpps = getOpps(lstOpps);
		amountOfOppsWithBuilding = 0;
		for(Opportunity curOpp :lstOpps)
		{
			if(curOpp.Geography__c != null)
			{
				system.assertNotEquals(curOpp.Building__c, null);
				amountOfOppsWithBuilding++;
			}
		}
		system.assertEquals(amountOfOppsWithBuilding, 22);
	}



	public static list <Opportunity> createTestData(boolean withGeo, integer numOfRepetitions)
	{
		SalesConsoleSettings.createSettings();
		List<Building__c> lstBuildings = new List<Building__c>();
		List<Opportunity> lstOpportunities = new List<Opportunity>();
		Id geo1, geo2;

		User cmUser = UtilUser.createUser(UtilProfile.getSysAdminProfileId(), true);
		
		for(integer i = 0; i < numOfRepetitions; i++)
		{
			lstBuildings.add(UtilBuilding.createBuilding('AMS-Metropool', 'Amsterdam', 'Netherlands', null, 'Europe/Amsterdam', null, false));
			lstBuildings.add(UtilBuilding.createBuilding('BKN-Brooklyn Heights', 'Brooklyn', 'USA', 'TS', 'America/New_York', cmUser.Id, false));
		}
		insert lstBuildings;

		for(integer i = 0; i < numOfRepetitions; i++)
		{
			string json = '{"address_components":[{"long_name":"Baner","short_name":"Baner","types":["","sublocality","sublocality_level_1"]},{"long_name":"Pune","short_name":"Pune","types":["locality","political"]},{"long_name":"Pune","short_name":"Pune","types":["administrative_area_level_2","political"]},{"long_name":"Maharashtra","short_name":"MH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]}],"formatted_address":"Baner, Pune, Maharashtra, India","geometry":{"bounds":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}},"location":{"lat":18.5596581,"lng":73.7799374},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}}},"place_id":"ChIJy9Nd8M--wjsRfat_-5cSkaE","types":["political","sublocality","sublocality_level_1"]}';
			lstGeographies.add(UtilGeography.createGeography('Baner1,Maharashtra', 'Pune', 'Indi2politicala', 'Pune', 'Maharashtra', 'Baner, Pune, Maharashtra, India', json, 'ChIJy9Nd8M--wjsRfat_-5cSkaEvhj' + string.valueOf(i), lstBuildings[i].Id, 18.5596581, 73.7799374, false));
			json = '{"address_components":[{"long_name":"Sangamner","short_name":"Sangamner","types":["locality","political"]},{"long_name":"Ahmednagar","short_name":"Ahmednagar","types":["administrative_area_level_2","political"]},{"long_name":"Maharashtra","short_name":"MH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]},{"long_name":"422605","short_name":"422605","types":["postal_code"]}],"formatted_address":"Sangamner, Maharashtra 422605, India","geometry":{"bounds":{"northeast":{"lat":19.5954532,"lng":74.2273235},"southwest":{"lat":19.5567976,"lng":74.1888714}},"location":{"lat":19.5771387,"lng":74.2079648},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":19.5954532,"lng":74.2273235},"southwest":{"lat":19.5567976,"lng":74.1888714}}},"partial_match":true,"place_id":"ChIJeavrqdAB3TsRiL6oagFS3UY","types":["locality","political"]}';
			lstGeographies.add(UtilGeography.createGeography('Sangamner, Maharashtra', 'Sangamner', 'Indi2politicala', 'Ahmednagar', 'Maharashtra', 'Baner, Pune, Maharashtra, India', json, 'ChIJy9Nd8M--wjsRfat_-5cSkaEnjbhjg' + string.valueOf(i), lstBuildings[i+1].Id, 19.5771387, 74.2079648, false));
		}		
		insert lstGeographies;

		Account accRec = UtilAccount.GetNewAccounts(1, true)[0];
		Contact conRec = UtilContact.GetNewContacts(1, accRec, true)[0];

		if(withGeo)
		{
			geo1 = lstGeographies[0].Id;
			geo2 = lstGeographies[1].Id;
		}
		
		for(integer i = 0; i < numOfRepetitions; i++)
		{
			lstOpportunities.add(UtilOpportunity.createOppWithGeoAndContact(1, accRec, conRec.Id, geo1, false));
			lstOpportunities.add(UtilOpportunity.createOppWithGeoAndContact(1, accRec, conRec.Id, geo2, false));
			lstOpportunities.add(UtilOpportunity.createOppWithGeoAndContact(1, accRec, conRec.Id, null, false));
		}
		insert lstOpportunities;

		return getOpps(lstOpportunities);
	}


	public static list <Opportunity> getOpps(list <Opportunity> lstOpportunities)
	{
		return [Select Id, Building__c, Geography__c
				From Opportunity
				Where Id IN :lstOpportunities];
	}

}