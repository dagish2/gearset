/************************************************************************************************************************************
	Author		: 	Nikhil Mehta
	Description	: 	This class handle Geography insertion using google api.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                     DETAIL
	1	    	7 December 2018		Nikhil Mehta            Initial Developement
**************************************************************************************************************************************/
@isTest
public class GeographyHandlerTest {
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        Account acc1 = new Account(Name='Master Account', Unomy_Company_ID__c = 123456, Lead_Source__c='Test',Account_Type__c='Org');
        TestingUtility.insertWithAssert(acc1, 'Account Not Inserted');
        Building__c objBuilding = new Building__c(City__c = 'Sangamner2456', Country__c = 'Indi2456politicala',Name = 'AMS-Metropool', CurrencyIsoCode = 'USD');
        TestingUtility.insertWithAssert(objBuilding);
        GeographyHandlerTest geographyHandlerTest = new GeographyHandlerTest();
        List<Geography__c> lstGeography = new  List<Geography__c>(); 
        Geography__c objGeography1 = new Geography__c(
            Name = 'Sangamner123, Maharashtra',
            City__c = 'Sangamner2456',
            Country__c = 'Indi2456politicala',
            District__c = 'Ahmednagar2456',
            Formatted_Address__c = 'Sangamner2456, Maharashtra 422605, India', 
            Geocode__Latitude__s = 85.5771387 ,
            Geocode__Longitude__s = 95.2079648,
            JSON__c = geographyHandlerTest.getJSONForGeography('Sangamner', 'Ahmednagar', 'Maharashtra', 'India'),
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy2456M--wjs2456_-5cSkaE', 
            State__c = 'Maharashtra2456',
            CurrencyIsoCode = 'USD',
            Nearest_Building__c = objBuilding.Id
        );
        upsert  objGeography1 Place_ID__c;
        System.assertNotEquals(null, objGeography1.Id);
        for(Geography__c geography : [SELECT Id, Name, City__c, Country__c, State__c, Place_ID__c, Nearest_Building__c FROM Geography__c WHERE Place_ID__c =: objGeography1.Place_ID__c]){
            System.assertEquals(objGeography1.Id, geography.Id);
            System.assertEquals(objGeography1.Nearest_Building__c, objBuilding.Id); 
        }
        
        Geography__c objGeography2 = new Geography__c(
            Name = 'Baner1,Maharashtra',
            City__c = 'Pune',
            Country__c = 'Indi2politicala',
            District__c='Pune',
            Formatted_Address__c = 'Baner, Pune, Maharashtra, India', 
            Geocode__Latitude__s = 18.5596581,
            Geocode__Longitude__s = 73.7799374,
            JSON__c = geographyHandlerTest.getJSONForGeography('Baner', 'Pune', 'Maharashtra', 'India'),
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy9Nd8M--wjsRfat_-5cSkaE', 
            State__c = 'Maharashtra' 
        ); 
        upsert  objGeography2 Place_ID__c;
        System.assertNotEquals(null, objGeography2.Id);
        
        Geography__c objGeography3 = new Geography__c(
            Name='Sangamner, Maharashtra',
            City__c = 'Sangamner',
            Country__c = 'Indi2politicala',
            District__c = 'Ahmednagar',
            Formatted_Address__c = 'Sangamner, Maharashtra 422605, India', 
            Geocode__Latitude__s = 19.5771387 ,
            Geocode__Longitude__s = 74.2079648,
            JSON__c = geographyHandlerTest.getJSONForGeography('Sangamner', 'Ahmednagar', 'Maharashtra', 'India'),
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy9Nd8M--wjsRfat_-5cSkaE', 
            State__c = 'Maharashtra',
            CurrencyIsoCode = 'USD'
        );
        upsert  objGeography3 Place_ID__c;
        System.assertNotEquals(null, objGeography3.Id);
        for(Geography__c objGeo : lstGeography){
            System.assertNotEquals(null, objGeo.Id);
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This test method used to verify hit google api and get related geography.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    @isTest
    public static void verifygetGeography(){ 
        Test.startTest();
        Map<String,String> mapAddress = new Map<String,String>();
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());
        mapAddress.put('address', '720 Olive Way, Suite 1700');
        mapAddress.put('city', 'Seattle');
        mapAddress.put('state', 'Washington');
        mapAddress.put('country', 'USA');
        mapAddress.put('zip', 'USA');
        GeographyHandler.getGoogleGeolocationApi(); 
        Geography__c objGeography1 = GeographyHandler.getGeography(mapAddress);
        Geography__c objGeography2 = GeographyHandler.getGeography(mapAddress);
        System.assert(objGeography1 != NULL, 'Geography Not Inserted');
        System.assert(objGeography2 != NULL, 'Geography Not Inserted');
        System.assertEquals(objGeography1.City__c, 'Frankfurt');
        System.assertEquals(objGeography2.City__c, 'Frankfurt');
        Test.stopTest();
    }
    
    public String getJSONForGeography(String address, String city, String state, String country){
        return '{"address_components":[{"long_name":"'+address+'","short_name":"'+getShortName(address)+'","types":["locality","political"]},{"long_name":"'+city+'","short_name":"'+getShortName(city)+'","types":["administrative_area_level_2","political"]},{"long_name":"'+state+'","short_name":"'+getShortName(state)+'","types":["administrative_area_level_1","political"]},{"long_name":"'+country+'","short_name":"'+getShortName(country)+'","types":["country","political"]},{"long_name":"422605","short_name":"422605","types":["postal_code"]}],"formatted_address":"Sangamner, Maharashtra 422605, India","geometry":{"bounds":{"northeast":{"lat":19.5954532,"lng":74.2273235},"southwest":{"lat":19.5567976,"lng":74.1888714}},"location":{"lat":19.5771387,"lng":74.2079648},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":19.5954532,"lng":74.2273235},"southwest":{"lat":19.5567976,"lng":74.1888714}}},"partial_match":true,"place_id":"ChIJeavrqdAB3TsRiL6oagFS3UY","types":["locality","political"]}';
    }
    public String getShortName(String name){
        return String.isNotBlank(name) ? name.contains(' ') ? name.toUpperCase().substring(0, 1) + name.toUpperCase().substring(1, 2) : name.toUpperCase().substring(0, 2) : '';
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This test method used to get account related geography.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    @isTest
    static void verifyUpdateNearestBuilding(){
        Test.startTest();
        Account acc =[SELECT Id FROM Account];
        List<Geography__c> lstObjGeography1 = [SELECT Id From Geography__c];
        Map<String,String> mapAddress = new Map<String,String>();
        Map<Id, Map<String, String>> mapNewGrographyData = new Map<Id, Map<String, String>>();
        mapNewGrographyData.put(acc.Id, mapAddress);
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());
        mapAddress.put('address', '720 Olive Way, Suite 1700');
        mapAddress.put('city', 'Seattle');
        mapAddress.put('state', 'Washington');
        mapAddress.put('country', 'USA');
        mapAddress.put('zip', 'USA');
        Map<Id, Id> mapGeoData = GeographyHandler.getGeogrphies(mapNewGrographyData);
        Debug.log('mapGeoData Data-->'+mapGeoData);
        System.assert(mapGeoData != NULL);
        System.assert(mapGeoData.get(acc.Id) != NULL , 'Geography not mapped to account');
        Test.stopTest();
    }
}