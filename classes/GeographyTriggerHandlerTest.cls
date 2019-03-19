/************************************************************************************************************************************
    Author 		: 	Priyanka Ambre
    Description : 	This class should contain all test methods related to GeographyTriggerHandler class.
    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL
    1	     	07, Mar 2017		Priyanka Ambre      	Initial Developement
**************************************************************************************************************************************/
@isTest
public class GeographyTriggerHandlerTest {
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        List<Building__c> lstBuilding = new List<Building__c>();
        lstBuilding.add(new Building__c(City__c = 'Sangamner2476', State__c = 'Maharashtra2456', Country__c = 'Indi2456politicala', Name = 'AMS-Sangamner2476', CurrencyIsoCode = 'USD'));
        lstBuilding.add(new Building__c(City__c = 'Sangamner2456', Country__c = 'Indi2456politicala', Name = 'AMS-Sangamner2456', CurrencyIsoCode = 'USD'));
        TestingUtility.insertListWithAssert(lstBuilding);
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
            Nearest_Building__c = lstBuilding[1].Id
        );
        lstGeography.add(objGeography1);
        TestingUtility.upsertListWithAssert(lstGeography);
        for(Geography__c geographyRec : [SELECT Id, City__c, Nearest_Building__c FROM Geography__c WHERE Id =: objGeography1.Id]){
            if(geographyRec.City__c.equals('Sangamner2456')){
                System.assertEquals(lstBuilding[0].Id, geographyRec.Nearest_Building__c);
            }
        }
        lstGeography.clear();
        Geography__c objGeography2 = new Geography__c(
            Name = 'Baner ,Maharashtra',
            City__c = 'Pune',
            Country__c = 'India',
            District__c='Pune',
            Formatted_Address__c = 'Baner, Pune, Maharashtra, India', 
            Geocode__Latitude__s = 18.5596581,
            Geocode__Longitude__s = 73.7799374,
            JSON__c = geographyHandlerTest.getJSONForGeography('Baner', 'Pune', 'Maharashtra', 'India'),
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy9Nd8M--wjsRfat_-5cSkaF', 
            State__c = 'Maharashtra' 
        ); 
        lstGeography.add(objGeography2);
        Geography__c objGeography3 = new Geography__c(
            Name='1460 Broadway, WeWork',
            City__c = 'New York',
            Country__c = 'United States',
            District__c = 'New York',
            Formatted_Address__c = '1460 Broadway, New York, United States', 
            Geocode__Latitude__s = 45.5771387 ,
            Geocode__Longitude__s = 55.2079648,
            JSON__c = geographyHandlerTest.getJSONForGeography('New York', 'New York', 'New York', 'United States'),
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy9Nd8M--wjsRfat_-5cSkaG', 
            State__c = 'New York',
            CurrencyIsoCode = 'USD'
        );
        lstGeography.add(objGeography3);
        Geography__c objGeography4 = new Geography__c(
            Name='2 Sheraton St Medius House, WeWork',
            City__c = 'London',
            Country__c = 'United Kingdom',
            District__c = 'London',
            Formatted_Address__c = '2 Sheraton St Medius House, London, United Kingdom', 
            Geocode__Latitude__s = 75.5771387 ,
            Geocode__Longitude__s = 85.2079648,
            JSON__c = geographyHandlerTest.getJSONForGeography('London', 'London', 'Maharashtra', 'United Kingdom'),
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy9Nd8M--wjsRfat_-5cSkaH', 
            State__c = 'Maharashtra',
            CurrencyIsoCode = 'USD'
        );
        lstGeography.add(objGeography4);
        Geography__c objGeography5 = new Geography__c(
            Name='33 Rue la Fayette, WeWork',
            City__c = 'Paris',
            Country__c = 'France',
            District__c = 'Paris',
            Formatted_Address__c = '33 Rue la Fayette, Paris, France', 
            Geocode__Latitude__s = 80.5771387 ,
            Geocode__Longitude__s = 85.2079648,
            JSON__c = geographyHandlerTest.getJSONForGeography('Paris', 'Paris', 'Paris', 'France'),
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy9Nd8M--wjsRfat_-5cSkaM', 
            State__c = 'Paris',
            CurrencyIsoCode = 'USD'
        );
        lstGeography.add(objGeography5);
        Geography__c objGeography6 = new Geography__c(
            Name='10F, Mass Mutual Tower, 33 Lockhart Rd, WeWork',
            City__c = 'Wan Chai',
            Country__c = 'Chaina',
            District__c = 'Wan Chai',
            Formatted_Address__c = '10F, Mass Mutual Tower, 33 Lockhart Rd, Paris, France', 
            Geocode__Latitude__s = 88.5771387 ,
            Geocode__Longitude__s = 85.2079648,
            JSON__c = geographyHandlerTest.getJSONForGeography('Wan Chai', 'Wan Chai', 'Hong Kong', 'Chaina'),
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy9Nd8M--wjsRfat_-5cSkaN', 
            State__c = 'Hong Kong',
            CurrencyIsoCode = 'USD'
        );
        lstGeography.add(objGeography6);
        TestingUtility.upsertListWithAssert(lstGeography);
        lstBuilding.clear();
        lstBuilding.add(new Building__c(City__c = 'Sangamner2456', State__c = 'Maharashtra2456', Country__c = 'Indi2456politicala',Name = 'AMS-India', CurrencyIsoCode = 'USD', Geography__c = objGeography1.Id));
        lstBuilding.add(new Building__c(City__c = 'Pune', State__c = 'Maharashtra', Country__c = 'India', Name = 'BKN-Brooklyn Heights', CurrencyIsoCode = 'USD', Geography__c = objGeography2.Id));
        lstBuilding.add(new Building__c(City__c = 'New York', State__c = 'New York', Country__c = 'United States', Name = 'BL-Sony Center', CurrencyIsoCode = 'USD', Geography__c = objGeography3.Id));
        lstBuilding.add(new Building__c(City__c = 'London', State__c = 'London', Country__c = 'United Kingdom', Name = 'AMS-UK', CurrencyIsoCode = 'USD', Geography__c = objGeography4.Id));
        lstBuilding.add(new Building__c(City__c = 'Paris', State__c = 'Paris', Country__c = 'France', Name = 'AMS-France', CurrencyIsoCode = 'USD', Geography__c = objGeography5.Id));
        lstBuilding.add(new Building__c(City__c = 'Wan Chai', State__c = 'Hong Kong', Country__c = 'Chaina', Name = 'AMS-Chaina', CurrencyIsoCode = 'USD', Geography__c = objGeography6.Id));
        TestingUtility.insertListWithAssert(lstBuilding);
    }    
    
    /************************************************************************************************************************************
        Author 				: 	Priyanka Ambre
        Description 		: 	This method is used to test updateNearestBuilding. 
        Created Date		:	07, Mar 2017	
        Issue No			:	ST-2097
        Last Modified By	: 	Nikhil Mehta
        Last Modified Date	: 	04 December 2018
        Issue No.			: 	ST-3200
    **************************************************************************************************************************************/
    public static testmethod void updateNearestBuildingTest(){ 
        Building__c buildingRec1;
        Building__c buildingRec2;
        Building__c buildingRec3;
        Building__c buildingRec4;
        Building__c buildingRec5;
        Building__c buildingRec6;
        
        for(Building__c buildingRec : [SELECT Id, Name, Geography__c, City__c, Geography__r.Name FROM Building__C WHERE Geography__c != NULL AND City__c != NULL]){
            Debug.Log('buildingRec---'+buildingRec);
            Debug.Log('buildingRec GeoName---'+buildingRec.Geography__r.Name);
            switch on buildingRec.City__c {
                when 'Sangamner2456' {
                    buildingRec1 = buildingRec;
                }
                when 'Pune' {
                    buildingRec2 = buildingRec;
                }
                when 'New York' {
                    buildingRec3 = buildingRec;
                }
                when 'London' {
                    buildingRec4 = buildingRec;
                }
                when 'Paris' {
                    buildingRec5 = buildingRec;
                }
                when 'Wan Chai' {
                    buildingRec6 = buildingRec;
                }
            }
        }
        GeographyHandlerTest geographyHandlerTest = new GeographyHandlerTest();
        List<Geography__c> lstGeography = new  List<Geography__c>(); 
        Geography__c objGeography1 = new Geography__c(
            Name = 'Sangamner123, Maharashtra',
            City__c = 'Sangamner2456',
            Country__c = 'Indi2456politicala',
            District__c = 'Ahmednagar2456',
            Formatted_Address__c = 'Sangamner2476, Maharashtra 422605, India', 
            Geocode__Latitude__s = 85.5771397 ,
            Geocode__Longitude__s = 95.2079648,
            JSON__c = geographyHandlerTest.getJSONForGeography('Sangamner2456', 'Sangamner2456', 'Maharashtra2456', 'Indi2456politicala'),
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy2456M--wjs2456_-5cSkaI', 
            State__c = 'Maharashtra2456',
            CurrencyIsoCode = 'USD'
        );
        lstGeography.add(objGeography1);
        Geography__c objGeography2 = new Geography__c(
            Name = 'Baner ,Maharashtra',
            City__c = 'Pune',
            Country__c = 'India',
            District__c='Pune',
            Formatted_Address__c = 'Baner, Pune, Maharashtra, India', 
            Geocode__Latitude__s = 18.5596591,
            Geocode__Longitude__s = 73.7799374,
            JSON__c = geographyHandlerTest.getJSONForGeography('Baner', 'Pune', 'Maharashtra', 'India'),
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy9Nd8M--wjsRfat_-5cSkaJ', 
            State__c = 'Maharashtra' 
        ); 
        lstGeography.add(objGeography2);
        Geography__c objGeography3 = new Geography__c(
            Name='1460 Broadway, WeWork',
            City__c = 'New York',
            Country__c = 'United States',
            District__c = 'New York',
            Formatted_Address__c = '1460 Broadway, New York, United States', 
            Geocode__Latitude__s = 45.5771397 ,
            Geocode__Longitude__s = 55.2079648,
            JSON__c = geographyHandlerTest.getJSONForGeography('New York', 'New York', 'New York', 'United States'),
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy9Nd8M--wjsRfat_-5cSkaK', 
            State__c = 'New York',
            CurrencyIsoCode = 'USD'
        );
        lstGeography.add(objGeography3);
        Geography__c objGeography4 = new Geography__c(
            Name='2 Sheraton St Medius House, WeWork',
            City__c = 'London',
            Country__c = 'United Kingdom',
            District__c = 'London',
            Formatted_Address__c = '2 Sheraton St Medius House, London, United Kingdom', 
            Geocode__Latitude__s = 75.5771397 ,
            Geocode__Longitude__s = 85.2079648,
            JSON__c = geographyHandlerTest.getJSONForGeography('London', 'London', 'Maharashtra', 'United Kingdom'),
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy9Nd8M--wjsRfat_-5cSkaL', 
            State__c = 'Maharashtra',
            CurrencyIsoCode = 'USD'
        );
        lstGeography.add(objGeography4);
        objGeography4 = new Geography__c(
            Name='2 Sheraton St Medius House, WeWork',
            City__c = 'London12',
            Country__c = 'United Kingdom',
            District__c = 'London',
            Formatted_Address__c = '2 Sheraton St Medius House, London, United Kingdom', 
            Geocode__Latitude__s = 75.5771397 ,
            Geocode__Longitude__s = 85.2079648,
            JSON__c = geographyHandlerTest.getJSONForGeography('London', 'London12', 'Maharashtra', 'United Kingdom'),
            Location_Type__c = 'APPROXIMATE', 
            Place_ID__c = 'ChIJy9Nd8M--wjsRfat_-5cSkaL1', 
            State__c = 'Maharashtra',
            CurrencyIsoCode = 'USD'
        );
        lstGeography.add(objGeography4);
        upsert lstGeography Place_ID__c;
        
        for(Geography__c geographyRec : [SELECT Id, City__c, Nearest_Building__c, Nearest_Building__r.Name FROM Geography__c WHERE Id IN : new Set<Id>{objGeography1.Id, objGeography2.Id, objGeography3.Id, objGeography1.Id}]){
            switch on geographyRec.City__c {
                when 'Sangamner2456' {
                    System.assertEquals(buildingRec1.Id, geographyRec.Nearest_Building__c);
                }
                when 'Pune' {
                    System.assertEquals(buildingRec2.Id, geographyRec.Nearest_Building__c);
                }
                when 'New York' {
                    System.assertEquals(buildingRec3.Id, geographyRec.Nearest_Building__c);
                }
                when 'London' {
                    System.assertEquals(buildingRec4.Id, geographyRec.Nearest_Building__c);
                }
                when 'London12' {
                    System.assertEquals(buildingRec4.Id, geographyRec.Nearest_Building__c);
                }
            }
        }
        List<Geography__c> lstGeographyToUpdate = new List<Geography__c>();
        Geography__c objGeography5 = new Geography__c(
            Id = objGeography3.Id,
            Name='33 Rue la Fayette, WeWork',
            City__c = 'Paris12',
            Country__c = 'France',
            District__c = 'Paris',
            State__c = 'Paris',
            Formatted_Address__c = '33 Rue la Fayette, Paris, France', 
            Geocode__Latitude__s = 80.5771397 ,
            Geocode__Longitude__s = 85.2079648,
            Nearest_Building__c = NULL
        );
        lstGeographyToUpdate.add(objGeography5);
        Geography__c objGeography6 = new Geography__c(
            Id = objGeography4.Id,
            Name='10F, Mass Mutual Tower, 33 Lockhart Rd, WeWork',
            City__c = 'Wan Chai12',
            Country__c = 'Chaina',
            District__c = 'Wan Chai',
            State__c = 'Hong Kong12',
            Formatted_Address__c = '10F, Mass Mutual Tower, 33 Lockhart Rd, Paris, France', 
            Geocode__Latitude__s = 88.5771397 ,
            Geocode__Longitude__s = 85.2079648,
            Nearest_Building__c = NULL
        );
        lstGeographyToUpdate.add(objGeography6);
        update lstGeographyToUpdate;
        
        for(Geography__c geographyRec : [SELECT Id, City__c, Nearest_Building__c FROM Geography__c WHERE Id IN : new Set<Id>{objGeography1.Id, objGeography2.Id, objGeography3.Id, objGeography1.Id}]){
            switch on geographyRec.City__c {
                when 'Paris12' {
                    System.assertEquals(buildingRec5.Id, geographyRec.Nearest_Building__c);
                }
                when 'Wan Chai12' {
                    System.assertEquals(buildingRec6.Id, geographyRec.Nearest_Building__c);
                }
            }
        }
        
    } 
     /************************************************************************************************************************************
        Author 				: 	Nikhil Mehta
        Description 		: 	This method is used to test null in getDistance method. 
        Created Date		:	04 December 2018
        Issue No			:	ST-3200
    **************************************************************************************************************************************/
    public static testmethod void checkNullAtGetDistace(){ 
        Geography__c geographyRec = new Geography__c(Name = 'Parel, Mumbai');
        System.assertEquals(null, GeographyTriggerHandler.getDistance(geographyRec, null));
    }
}