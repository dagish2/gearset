/************************************************************************************************************************************
	Author		: 	Nikhil Mehta
	Description	: 	This is Test class for MarketAssignmentController.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        	AUTHOR                     DETAIL
	1	    	4 December 2018		Nikhil Mehta            Initial Developement
**************************************************************************************************************************************/
@isTest
public class MarketAssignmentControllerTest {
    
    @TestSetup
    public static void initData(){
        SalesConsoleSettings.createSettings();
        Region__c objRegion = new Region__c(Name = 'Test Region', Region__c = 'Test Region');
        TestingUtility.insertWithAssert(objRegion, 'Region not inserted');
        Territory__c objTerritory = new Territory__c(Name = 'Test Territory', Territory__c =' Test Territory', RegionID__c = objRegion.Id);
        TestingUtility.insertWithAssert(objTerritory, 'Territory not inserted');
        Market__c objMarket = new Market__c(Name = 'Test Portfolio', Portfolio__c = 'Test Portfolio', TerritoryId__c = objTerritory.Id);
        TestingUtility.insertWithAssert(objMarket, 'Portfolio not inserted');
        Lead objLead = new Lead(FirstName='John',LastName='Smith',Email='john.smith@example.com',Phone = '1234567891',Company='Example',LeadSource='WeWork.com',Lead_Source_Detail__c='Book a Tour Form',Locations_Interested__c='Test Building Tour');
        TestingUtility.insertWithAssert(objLead, 'first Lead is created');
        objLead = new Lead(FirstName='John',LastName='Smith',Email='john.smith12@example.com',Phone = '1234567891',Company='Example',LeadSource='WeWork.com',Lead_Source_Detail__c='Book a Tour Form',Locations_Interested__c='Test Building Tour', Unomy_Updated_DateTime__c = Date.today(), Unomy_Location_Address__c = 'USA', Unomy_Location_City__c = 'Seattle', Unomy_Location_State__c = 'Washington', Unomy_Location_Country__c = 'USA');
        TestingUtility.insertWithAssert(objLead, 'Second Lead is created');
        
        Account acc1 = new Account(Name='Master Account', Unomy_Company_ID__c = 123456, Unomy_Updated_DateTime__c = Date.today(), Lead_Source__c = 'Test', Account_Type__c = 'Org', Unomy_Location_Address__c = 'USA', Unomy_Location_City__c = 'Seattle', Unomy_Location_State__c = 'Washington', Unomy_Location_Country__c = 'USA', BillingStreet = 'Washington', BillingCity = 'Seattle', BillingState = 'Washington', BillingCountry = 'USA'); 
        TestingUtility.insertWithAssert(acc1, 'Account Not Inserted'); 
        Contact con = new Contact(FirstName = 'Contact1', LastName = 'Member', Email = 'test.Contact1@example.com', AccountId = acc1.Id, Unomy_Updated_DateTime__c = Date.today(), Unomy_Location_Address__c = 'USA', Unomy_Location_City__c = 'Seattle', Unomy_Location_State__c = 'Washington', Unomy_Location_Country__c = 'USA');
        TestingUtility.insertWithAssert(con, 'Contact Not Inserted');
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
        Description         :   This test method for get grography.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    @isTest
    public static void verifyUpdateMarketForWebService(){ 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());
        Account objAcc = [SELECT Id, Account_Market__c From Account];
        System.assertEquals(null, objAcc.Account_Market__c);
        String result = MarketAssignmentController.getMarketForWebservice(objAcc.Id);
        Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals(true, Boolean.valueOf(mapResult.get('isValid')));
        result = MarketAssignmentController.updateMarketForWebservice(objAcc.Id, String.valueOf(mapResult.get('marketId')), String.valueOf(mapResult.get('geographyId')));
        mapResult = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals(true, Boolean.valueOf(mapResult.get('updated')));
        Lead leadRec1;
        Lead leadRec2;
        List<Lead> lstLeads = [SELECT Id, Lead_Market__c, Email FROM Lead];
        if(!lstLeads.isEmpty()){
            for(Lead objLead : lstLeads){
                if(objLead.Email.equalsIgnoreCase('john.smith@example.com')){
                    leadRec1 = objLead;
                }else{
                    leadRec2 = objLead;
                }
            }
            result = MarketAssignmentController.getMarketForWebservice(leadRec1.Id);
            mapResult = (Map<String, Object>)JSON.deserializeUntyped(result);
            Debug.Log('mapResult---'+mapResult);
            System.assertEquals(false, Boolean.valueOf(mapResult.get('isValid')));
        }
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This test method for update market on account.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    @isTest
    public static void verifupdateMarketForLightning(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());
        Lead leadRec1;
        Lead leadRec2;
        List<Lead> lstLeads = [SELECT Id, Lead_Market__c, Email FROM Lead];
        if(!lstLeads.isEmpty()){
            for(Lead objLead : lstLeads){
                if(objLead.Email.equalsIgnoreCase('john.smith@example.com')){
                    leadRec1 = objLead;
                }else{
                    leadRec2 = objLead;
                }
            }
            DatabaseResult result = MarketAssignmentController.getMarketForLightning(leadRec1.Id);
            Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(result.data));
            System.assertEquals(false, Boolean.valueOf(mapResult.get('isValid')));
            result = MarketAssignmentController.getMarketForLightning(leadRec2.Id);
            mapResult = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(result.data));
            result = MarketAssignmentController.updateMarketForLightning(leadRec2.Id, mapResult);
            mapResult = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(result.data));
            System.assertEquals(true, Boolean.valueOf(mapResult.get('isValid')));
        }
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This test method for get billing address for account.
        Created Date  		:   04 December 2018
		Issue No.			:	ST-3200
    **************************************************************************************************************************************/    
    @isTest
    public static void verifyInvalideCondition(){
        MarketAssignmentController.getMarket(null);
        MarketAssignmentController.updateMarket(null, null);
    }
}