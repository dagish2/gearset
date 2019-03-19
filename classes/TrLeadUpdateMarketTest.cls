/************************************************************************************************************************************
	Author		: 	Nikhil Mehta
	Description	: 	This test class is used to test update market on Lead.
					Runs on after insert and after update.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                     	DETAIL
	1	    	17 December 2018	Krishana Tupe       	Initial Developement
**************************************************************************************************************************************/
@isTest
public class TrLeadUpdateMarketTest {
@TestSetup
    public static void initData(){
        SalesConsoleSettings.createSettings();
        Region__c objRegion = new Region__c(Name = 'Test Region', Region__c = 'Test Region');
        TestingUtility.insertWithAssert(objRegion, 'Region inserted');
        Territory__c objTerritory = new Territory__c(Name = 'Test Territory', Territory__c =' Test Territory', RegionID__c = objRegion.Id);
        TestingUtility.insertWithAssert(objTerritory, 'Territory inserted');
        Market__c objMarket = new Market__c(Name = 'Test Portfolio', Portfolio__c = 'Test Portfolio', TerritoryId__c = objTerritory.Id);
        TestingUtility.insertWithAssert(objMarket, 'Portfolio inserted');        
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
        Description         :   This test method for update market on Lead.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3255
    **************************************************************************************************************************************/    
    @isTest
    public static void verifyUpdateMarketForLead(){      
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());
        Market__c objMarket = [SELECT Id FROM Market__c WHERE Name = 'Test Portfolio']; 
        RESTInboundLeadAPIHelper.isLeadFromWeb  = true;
        List<Lead> lstLeads = new List<Lead>();
        BatchToUpdateMarketTest.getLeads(lstLeads,5);       
        Database.insert(lstLeads, false);
        List<Lead> lstLeadsResult = [SELECT Id, Name, Email, Update_HQ_Market_Status__c, Lead_Demographic_Score_Re_calculate__c, Lead_Demographic_Score__c, Lead_Processing_Stage__c, Processing_Stage__c, Lead_Market__c FROM Lead WHERE Id IN : lstLeads AND isConverted = FALSE];
        BatchToUpdateMarketTest.verifyAssertions(lstLeadsResult, 'Pending', 'Created', '1');       
        for(Lead objLead : lstLeadsResult){
            objLead.Unomy_Location_Address__c = 'USA';
            objLead.Unomy_Location_City__c = 'Seattle';
            objLead.Unomy_Location_State__c = 'Greenland';
            objLead.Unomy_Location_Country__c = 'USA';
            objLead.Unomy_Updated_DateTime__c = System.today();
        }
        Database.update(lstLeadsResult, false);
        Test.startTest();
        Database.executeBatch(new BatchToUpdateMarket('Lead'));
        Test.stopTest();
        lstLeadsResult = [SELECT Id, Name, Email, Update_HQ_Market_Status__c, Lead_Demographic_Score_Re_calculate__c, Lead_Demographic_Score__c, Lead_Processing_Stage__c, Processing_Stage__c, Lead_Market__c FROM Lead WHERE Id IN : lstLeads AND isConverted = FALSE];
        BatchToUpdateMarketTest.verifyAssertions(lstLeadsResult, 'Completed', 'Market Identified', '5');
        for(Lead objLead : lstLeadsResult){
            System.assertEquals(objMarket.Id, objLead.Lead_Market__c);
        }
    }
    
}