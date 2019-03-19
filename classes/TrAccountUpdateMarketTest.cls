/************************************************************************************************************************************
	Author		: 	Nikhil Mehta
	Description	: 	This test method is used to test update market on account trigger.
					Runs on after insert and after update.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                     	DETAIL
	1	    	6 December 2018		Nikhil Mehta            	Initial Developement
**************************************************************************************************************************************/
@isTest
public class TrAccountUpdateMarketTest {
    
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        SalesConsoleSettings.createSettings();
        Region__c objRegion = new Region__c(Name = 'Test Region', Region__c = 'Test Region');
        TestingUtility.insertWithAssert(objRegion, 'Region inserted');
        Territory__c objTerritory = new Territory__c(Name = 'Test Territory', Territory__c =' Test Territory', RegionID__c = objRegion.Id);
        TestingUtility.insertWithAssert(objTerritory, 'Territory inserted');
        Market__c objMarket = new Market__c(Name = 'Test Portfolio', Portfolio__c = 'Test Portfolio', TerritoryId__c = objTerritory.Id);
        TestingUtility.insertWithAssert(objMarket, 'Portfolio inserted');
        Account acc1 = new Account(Name='Master Account1', Unomy_Company_ID__c = 123456, Unomy_Updated_DateTime__c = Date.today(), Lead_Source__c = 'Test', Account_Type__c = 'Org', Unomy_Location_Address__c = 'USA', Unomy_Location_City__c = 'Seattle', Unomy_Location_State__c = 'Washington', Unomy_Location_Country__c = 'USA', BillingStreet = 'Washington', BillingCity = 'Seattle', BillingState = 'Washington', BillingCountry = 'USA'); 
        TestingUtility.insertWithAssert(acc1, 'Account Not Inserted');
        acc1 = new Account(Name='Master Account2', Unomy_Company_ID__c = 789456, Unomy_Updated_DateTime__c = Date.today(), Lead_Source__c = 'Test', Account_Type__c = 'Org', BillingStreet = 'Washington', BillingCity = 'Seattle', BillingState = 'Washington', BillingCountry = 'USA'); 
        TestingUtility.insertWithAssert(acc1, 'Account Not Inserted');
        Cluster__c objCluster = new Cluster__c(Name = 'Test Cluster');
        TestingUtility.insertWithAssert(objCluster,'Cluster not inserted');
        Building__c objBuilding1 = new Building__c(Name='Test1',UUID__c='12544114441111',Market__c=objMarket.Id);
        TestingUtility.insertWithAssert(objBuilding1);
        Building__c objBuilding = new Building__c(City__c = 'Sangamner2456', Country__c = 'Germany',Name = 'AMS-Metropool', CurrencyIsoCode = 'USD',Market__c=objMarket.Id);
        TestingUtility.insertWithAssert(objBuilding);
        List<Geography__c> lstGeography = new  List<Geography__c>(); 
        Geography__c objGeography1 = new Geography__c(
            Name = 'Sangamner123, Maharashtra',
            City__c = 'Sangamner2456',
            Country__c = 'Indi2456politicala',
            District__c = 'Ahmednagar2456',
            Formatted_Address__c = 'Sangamner2456, Maharashtra 422605, India', 
            Geocode__Latitude__s = 85.5771387 ,
            Geocode__Longitude__s = 95.2079648,
            JSON__c = '{"address_components":[{"long_name":"Sangamner","short_name":"Sangamner","types":["locality","political"]},{"long_name":"Ahmednagar","short_name":"Ahmednagar","types":["administrative_area_level_2","political"]},{"long_name":"Maharashtra","short_name":"MH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]},{"long_name":"422605","short_name":"422605","types":["postal_code"]}],"formatted_address":"Sangamner, Maharashtra 422605, India","geometry":{"bounds":{"northeast":{"lat":19.5954532,"lng":74.2273235},"southwest":{"lat":19.5567976,"lng":74.1888714}},"location":{"lat":19.5771387,"lng":74.2079648},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":19.5954532,"lng":74.2273235},"southwest":{"lat":19.5567976,"lng":74.1888714}}},"partial_match":true,"place_id":"ChIJeavrqdAB3TsRiL6oagFS3UY","types":["locality","political"]}',
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy2456M--wjs2456_-5cSkaE', 
            State__c = 'Maharashtra2456',
            CurrencyIsoCode = 'USD'
        );
        insert objGeography1;
    }
	
	/************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This test method for update the market based on max limit.
        Created Date  		:   06 December 2018
		Issue No.			:	ST-3198
    **************************************************************************************************************************************/    
    @isTest
    static void verifyUpdateMarketAccounts(){       
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());
        Account objAcc = [SELECT Id, Account_Market__c, Unomy_Company_ID__c From Account WHERE Unomy_Company_ID__c = 123456];
        System.assertEquals(null, objAcc.Account_Market__c);
        List<Account> lstAccountInserted = [SELECT Id, Processing_Stage__c, Account_Market__c, Unomy_Company_ID__c, Geography__c, Market_Identified_On__c, Update_HQ_Market_Status__c FROM Account WHERE Id =:objAcc.Id];
        Test.startTest();
        Database.executeBatch(new BatchToUpdateMarket('Account'));
        Test.stopTest();
        lstAccountInserted = [SELECT Id, Processing_Stage__c, Account_Market__c, Unomy_Company_ID__c, Geography__c, Market_Identified_On__c, Update_HQ_Market_Status__c FROM Account WHERE Id IN : lstAccountInserted];
        Market__c objMarket = [SELECT Id FROM Market__c WHERE Name = 'Test Portfolio'];    
        for(Account objAccount : lstAccountInserted){
            System.assertEquals(objMarket.Id, objAccount.Account_Market__c);
            System.assertNotEquals(NULL, objAccount.Geography__c);
            System.assertEquals('Completed', objAccount.Update_HQ_Market_Status__c);
        } 
    }
    
    @isTest
    static void verifyTrAccountUpdateMarket(){       
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());      
        List<Account> lstAccountInserted = [SELECT Id, BillingCountry, BillingCity, Processing_Stage__c, Account_Market__c, Unomy_Company_ID__c, Geography__c, Market_Identified_On__c, Update_HQ_Market_Status__c FROM Account WHERE Unomy_Company_ID__c = 123456];
        for(Account objAccount : lstAccountInserted){   
            objAccount.BillingCity = 'Test City';
            objAccount.BillingCountry = 'Test Country';
            objAccount.Update_HQ_Market_Status__c = 'Completed';
        }
        Database.update(lstAccountInserted, false);
        lstAccountInserted = [SELECT Id, Processing_Stage__c, Account_Market__c, Unomy_Company_ID__c, Geography__c, Market_Identified_On__c, Update_HQ_Market_Status__c FROM Account WHERE Id IN : lstAccountInserted];
        for(Account objAccount : lstAccountInserted){
            System.assertEquals('Pending', objAccount.Update_HQ_Market_Status__c);
            System.assertEquals(NULL, objAccount.Account_Market__c);            
        } 
    }
}