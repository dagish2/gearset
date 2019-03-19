@isTest
public class QueueInsertGeographyForBuildingTest {
    public static List<Geography__c> lstGeographies = new  List<Geography__c>();
    static{
         SalesConsoleSettings.createSettings();
        Geography__c objGeography1 = new Geography__c(
            Name='Baner1,Maharashtra',
            City__c='Pune',
            Country__c='Netherlands', District__c='Pune',
            Formatted_Address__c='Baner, Pune, Maharashtra, India', 
            Geocode__Latitude__s=18.5596581,
            Geocode__Longitude__s=73.7799374,
            JSON__c='{"address_components":[{"long_name":"Baner","short_name":"Baner","types":["","sublocality","sublocality_level_1"]},{"long_name":"Pune","short_name":"Pune","types":["locality","political"]},{"long_name":"Pune","short_name":"Pune","types":["administrative_area_level_2","political"]},{"long_name":"Maharashtra","short_name":"MH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]}],"formatted_address":"Baner, Pune, Maharashtra, India","geometry":{"bounds":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}},"location":{"lat":18.5596581,"lng":73.7799374},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}}},"place_id":"ChIJy9Nd8M--wjsRfat_-5cSkaE","types":["political","sublocality","sublocality_level_1"]}',
            Location_Type__c='APPROXIMATE', 
            Place_ID__c='ChIJy9Nd8M--wjsRfat_-5cSkaEvhj', 
            State__c='Maharashtra' 
        );  
        lstGeographies.add(objGeography1);
        Debug.log('objGeography1---'+objGeography1); 
        Geography__c objGeography2 = new Geography__c(
            Name='Sangamner, Maharashtra', City__c='Sangamner',
            Country__c='Indi2politicala', District__c='Ahmednagar',
            Formatted_Address__c='Sangamner, Maharashtra 422605, India', 
            Geocode__Latitude__s=19.5771387 ,
            Geocode__Longitude__s=74.2079648,
            JSON__c='{"address_components":[{"long_name":"Sangamner","short_name":"Sangamner","types":["locality","political"]},{"long_name":"Ahmednagar","short_name":"Ahmednagar","types":["administrative_area_level_2","political"]},{"long_name":"Maharashtra","short_name":"MH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]},{"long_name":"422605","short_name":"422605","types":["postal_code"]}],"formatted_address":"Sangamner, Maharashtra 422605, India","geometry":{"bounds":{"northeast":{"lat":19.5954532,"lng":74.2273235},"southwest":{"lat":19.5567976,"lng":74.1888714}},"location":{"lat":19.5771387,"lng":74.2079648},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":19.5954532,"lng":74.2273235},"southwest":{"lat":19.5567976,"lng":74.1888714}}},"partial_match":true,"place_id":"ChIJeavrqdAB3TsRiL6oagFS3UY","types":["locality","political"]}',
            Location_Type__c='APPROXIMATE', 
            Place_ID__c='ChIJy9Nd8M--wjsRfat_-5cSkaEnjbhjg', 
            State__c='Maharashtra',
            CurrencyIsoCode='USD' 
        );  
        lstGeographies.add(objGeography2);
         Geography__c objGeography3 = new Geography__c(
            Name='Melbourne VIC, Victoria', City__c='Victoria',
            Country__c='Australia',
            Formatted_Address__c='Melbourne VIC, Australia', 
            Geocode__Latitude__s=-37.8136276,
            Geocode__Longitude__s=144.9630576,
            JSON__c='{"address_components":[{"long_name":"Melbourne","short_name":"Melbourne","types":["colloquial_area","locality","political"]},{"long_name":"Victoria","short_name":"VIC","types":["administrative_area_level_1","political"]},{"long_name":"Australia","short_name":"AU","types":["country","political"]}],"formatted_address":"Melbourne VIC, Australia","geometry":{"bounds":{"northeast":{"lat":-37.5112737,"lng":145.5125288},"southwest":{"lat":-38.4338593,"lng":144.5937418}},"location":{"lat":-37.8136276,"lng":144.9630576},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":-37.5112737,"lng":145.5125288},"southwest":{"lat":-38.4338593,"lng":144.5937418}}},"place_id":"ChIJ90260rVG1moRkM2MIXVWBAQ","types":["colloquial_area","locality","political"]}',
            Location_Type__c='APPROXIMATE', 
            Place_ID__c='ChIJ90260rVG1moRkM2MIXVWBAQ', 
            State__c='Victoria',
            CurrencyIsoCode='USD' 
        );
        lstGeographies.add(objGeography3);
        TestingUtility.insertListWithAssert(lstGeographies);
     }
    public static testMethod void testQueueInsertGeographyForBuilding(){
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());  
        Building__c building1 = new Building__c(City__c = 'Frankfurt', Country__c = 'Germany',Name = 'HE-Goetheplatz', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam', Geography__c = lstGeographies[0].Id, UUID__c='11111');
        Building__c building2 = new Building__c(City__c = 'Brooklyn', Country__c = 'USA',Name = 'BKN-Williamsburg', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam', Geography__c = lstGeographies[1].Id, UUID__c='22222');
        Building__c building3 = new Building__c(City__c = 'London', Country__c = 'UK',Name = 'LON-Kings Place', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam', Geography__c = lstGeographies[2].Id, UUID__c='33333');
        Building__c building4 = new Building__c(City__c = 'Pune', Country__c = 'India',Name = 'Test', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam', Geography__c = lstGeographies[2].Id);
		List<Building__c> lstBuildings = new List<Building__c>();
        lstBuildings.add(building1); 
        lstBuildings.add(building2);
        lstBuildings.add(building3);
        lstBuildings.add(building4);
        TestingUtility.insertListWithAssert(lstBuildings);
        
        List<Geography__c> lstGeographyUpdate = new List<Geography__c>(); 
        lstGeographies[0].Nearest_Building__c = lstBuildings[0].Id;
        lstGeographyUpdate.add(lstGeographies[0]);
        lstGeographies[1].Nearest_Building__c = lstBuildings[1].Id;
        lstGeographyUpdate.add(lstGeographies[1]);
        lstGeographies[2].Nearest_Building__c = lstBuildings[2].Id;
        lstGeographyUpdate.add(lstGeographies[2]);
        update lstGeographyUpdate;
        
        List<Geography__c> lstNewGeographys = new List<Geography__c>();
        Decimal latitude = 19.5771387 ;
        Decimal logitude = 74.2079648 ; 
        for(Integer index=1; index<10 ; index++){
            lstNewGeographys.add(new Geography__c(
                Name='Melbourne VIC, Victoria'+(index), City__c='Victoria'+(index),
                Country__c='Australia',
                Formatted_Address__c='Melbourne VIC, Australia', 
                Geocode__Latitude__s=(latitude+index),
                Geocode__Longitude__s=(logitude+index),
                JSON__c='{"address_components":[{"long_name":"Melbourne","short_name":"Melbourne","types":["colloquial_area","locality","political"]},{"long_name":"Victoria","short_name":"VIC","types":["administrative_area_level_1","political"]},{"long_name":"Australia","short_name":"AU","types":["country","political"]}],"formatted_address":"Melbourne VIC, Australia","geometry":{"bounds":{"northeast":{"lat":-37.5112737,"lng":145.5125288},"southwest":{"lat":-38.4338593,"lng":144.5937418}},"location":{"lat":-37.8136276,"lng":144.9630576},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":-37.5112737,"lng":145.5125288},"southwest":{"lat":-38.4338593,"lng":144.5937418}}},"place_id":"ChIJ90260rVG1moRkM2MIXVWBAQ","types":["colloquial_area","locality","political"]}',
                Location_Type__c='APPROXIMATE', 
                Place_ID__c= QueueInsertGeographyForBuildingTest.generateRandomString(30), 
                State__c='Victoria',
                CurrencyIsoCode='USD',
				Nearest_Building__c = lstBuildings[2].Id
            ));
            
        }
		TestingUtility.insertListWithAssert(lstNewGeographys);
        
        try{
            Test.startTest();
            Debug.log('In manageBuildingRelatedGeographies---'); 
            Setting__c googleGeolocationAPISetting = Settings.get('Google Geolocation API');
            if(googleGeolocationAPISetting != null){
                String googleGeolocationAPISettingData = googleGeolocationAPISetting.Data__c.replace('accept-encoding','acceptEncoding');
                Debug.log('googleGeolocationAPISettingData---'+googleGeolocationAPISettingData);
                GeographyHandler.GoogleGeolocationAPI googleGeolocationAPIRec = (GeographyHandler.GoogleGeolocationAPI)System.JSON.deserialize(googleGeolocationAPISettingData, GeographyHandler.GoogleGeolocationAPI.class);
                Debug.log('googleGeolocationAPIRec---'+googleGeolocationAPIRec);
                Debug.log('googleGeolocationAPIRec.geolocationAPI.url---'+googleGeolocationAPIRec.geolocationAPI.url);
                QueueInsertGeographyForBuilding jobQueueInsertGeographyForBuilding = new QueueInsertGeographyForBuilding(lstBuildings, googleGeolocationAPIRec);
                ID jobID = System.enqueueJob(jobQueueInsertGeographyForBuilding);
                Debug.Log('jobID---'+jobID);
             }
            Test.stopTest();
            for(Building__c buildingRec : [SELECT Name, Geography__c, Geography__r.Name, Geography__r.Nearest_Building__c FROM Building__c]){
                Debug.Log('buildingRec---'+buildingRec);
                System.assertNotEquals(null, buildingRec.Id);                
                if(buildingRec.Id == building1.Id){                    
                    System.assertNotEquals(null, building1.Geography__c);
                 }else if(buildingRec.Id == building2.Id){
                     System.assertNotEquals(null, building1.Geography__c);
                 }else if(buildingRec.Id == building3.Id){
                     System.assertNotEquals(null, building1.Geography__c);
                 }
             }
            
        }catch(Exception exc){
            Debug.log('exc :: '+exc);
        }
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}