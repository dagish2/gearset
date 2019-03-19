/************************************************************************************************************************************
	Author		: 	Krishana Tupe
	Description	: 	This batch class handle Geography insertion using google api account update related market on Account record.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        		AUTHOR                     	DETAIL
	1	    	12 December 2018		Krishana Tupe           	Initial Developement
	2	    	23 January 2019			Krishana Tupe            	Made changes for Lead/Account update Market logic
**************************************************************************************************************************************/
@isTest
public class BatchToUpdateMarketTest{

 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to crete the Test data for this Test class
        Created Date  		:   23 January 2019
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
   @TestSetup
    public static void initData(){
        SalesConsoleSettings.createSettings();
    }

  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method returns the Leads
        Created Date  		:   23 January 2019
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public static List<Lead> getLeads(List<Lead> lstLeads, Integer size){
        for(Integer iIndex = 0; iIndex < size; iIndex++){
            lstLeads.add(new Lead(LeadSource='WeWork.com', Lead_Source_Detail__c='TEST LEAD SOURCE '+iIndex, LastName = 'Doe '+iIndex, FirstName = 'John', Email = 'johndoe1582018_1'+iIndex+'@example.com', Office_Type__c = 'Daily Desk', Status = 'Open', Locations_Interested__c = 'Test Building Tour', Company = 'Enzigma ltd', Generate_Journey__c = true, Number_of_Full_Time_Employees__c = 15));
        }
        return lstLeads;
    }

  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method returns the Accounts
        Created Date  		:   23 January 2019
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public static List<Account> getAccounts(List<Account> lstAccounts, Integer size){
        for(Integer iIndex = 0; iIndex < size; iIndex++){
            lstAccounts.add(new Account(Name='Master Account'+iIndex, Unomy_Company_ID__c = 123456+iIndex, Unomy_Updated_DateTime__c = Date.today(), Lead_Source__c = 'Test'+iIndex, Account_Type__c = 'Org', Unomy_Location_Address__c = 'USA', Unomy_Location_City__c = 'Seattle', Unomy_Location_State__c = 'Washington', Unomy_Location_Country__c = 'USA', BillingStreet = 'Washington', BillingCity = 'Seattle', BillingState = 'Washington', BillingCountry = 'USA'));
        }
        return lstAccounts;
    }

  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies the Market Update on Lead functionality using Batch
        Created Date  		:   23 January 2019
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
   @isTest
    public static void verifyUpdateMarketOnLead(){
        RESTInboundLeadAPIHelper.isLeadFromWeb  = true;
        List<Lead> lstLeads = new List<Lead>();
        BatchToUpdateMarketTest.getLeads(lstLeads,5);
        Database.insert(lstLeads, false);
        List<Lead> lstLeadsResult = [SELECT Id, Name, Email, Update_HQ_Market_Status__c, Lead_Demographic_Score_Re_calculate__c, Lead_Demographic_Score__c, Lead_Processing_Stage__c, Processing_Stage__c, Lead_Market__c FROM Lead WHERE Id IN : lstLeads AND isConverted = FALSE];
        verifyAssertions(lstLeadsResult, 'Pending', 'Created', '1');

        for(Lead objLead : lstLeadsResult){
            objLead.Unomy_Updated_DateTime__c = System.today();
        }
        Database.update(lstLeadsResult, false);
        Test.startTest();
        Database.executeBatch(new BatchToUpdateMarket('Lead'));
        Test.stopTest();
        lstLeadsResult = [SELECT Id, Name, Email, Update_HQ_Market_Status__c, Lead_Demographic_Score_Re_calculate__c, Lead_Demographic_Score__c, Lead_Processing_Stage__c, Processing_Stage__c, Lead_Market__c FROM Lead WHERE Id IN : lstLeads AND isConverted = FALSE];

        Database.executeBatch(new BatchToUpdateMarket('Lead'));
        lstLeadsResult = [SELECT Id, Name, Email, Update_HQ_Market_Status__c, Lead_Demographic_Score_Re_calculate__c, Lead_Demographic_Score__c, Lead_Processing_Stage__c, Processing_Stage__c, Lead_Market__c FROM Lead WHERE Id IN : lstLeads AND isConverted = FALSE];
        verifyAssertions(lstLeadsResult, NULL, 'Market Identified', '3');
    }



   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method created the test data for update market on Lead/Account.
        Created Date  		:   23 January 2019
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
   public static Id createMarketData(){
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
        return objMarket.Id;
    }

 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies the Lead records on which we need to find and update market.
        Created Date  		:   23 January 2019
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    @isTest
    public static void verifyUpdateMarketOnLeadSuccess(){
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());
        Id marketId = createMarketData();
        RESTInboundLeadAPIHelper.isLeadFromWeb  = true;
        List<Lead> lstLeads = new List<Lead>();
        BatchToUpdateMarketTest.getLeads(lstLeads,5);
        Database.insert(lstLeads, false);
        List<Lead> lstLeadsResult = [SELECT Id, Name, Email, Update_HQ_Market_Status__c, Lead_Demographic_Score_Re_calculate__c, Lead_Demographic_Score__c, Lead_Processing_Stage__c, Processing_Stage__c, Lead_Market__c FROM Lead WHERE Id IN : lstLeads AND isConverted = FALSE];
        verifyAssertions(lstLeadsResult, 'Pending', 'Created', '1');
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
        for(Lead objLead : lstLeadsResult){
            System.assertEquals(marketId, objLead.Lead_Market__c);
        }
    }

   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies the Lead/Account batch metadata.
        Created Date  		:   23 January 2019
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
     @isTest
    public static void verifyUpdateMarketMetadata(){
        Map<String, object> mapUpdateMarketBatchMDT = BatchToUpdateMarketHelper.getUpdateMarketBatchMetadata('UpdateMarketBatchMetadata');
        System.assert(mapUpdateMarketBatchMDT != null);
        System.assert(mapUpdateMarketBatchMDT.containsKey('StopBatch'));
        System.assert(mapUpdateMarketBatchMDT.containsKey('Lead'));
        System.assert(mapUpdateMarketBatchMDT.containsKey('Account'));
        Map<String, object> mapBatchInfo = (Map<String, object>)mapUpdateMarketBatchMDT.get('Lead');
        System.assert(mapBatchInfo.containsKey('ContinuousBatchQuery'));
        System.assert(mapBatchInfo.containsKey('Chunk Size'));
        System.assert(mapBatchInfo.containsKey('Stop'));
        System.assert(String.isNotBlank(String.valueOf(mapBatchInfo.get('ContinuousBatchQuery'))));
    }

   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies the Account records on which we need to find and update market but unomy data present.
        Created Date  		:   23 January 2019
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    @isTest
    public static void verifyUpdateMarketOnAccountSuccess(){
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());
        Id marketId = createMarketData();
        List<Account> lstAccounts = new List<Account>();
        BatchToUpdateMarketTest.getAccounts(lstAccounts,5);
        Database.insert(lstAccounts, false);
        List<Account> lstAccountInserted = [SELECT Id, Processing_Stage__c, Account_Market__c, Unomy_Company_ID__c, Geography__c, Market_Identified_On__c, Update_HQ_Market_Status__c FROM Account WHERE Id IN : lstAccounts];
        Test.startTest();
        Database.executeBatch(new BatchToUpdateMarket('Account'));
        Test.stopTest();
        lstAccountInserted = [SELECT Id, Processing_Stage__c, Account_Market__c, Unomy_Company_ID__c, Geography__c, Market_Identified_On__c, Update_HQ_Market_Status__c FROM Account WHERE Id IN : lstAccountInserted];
        for(Account objAccount : lstAccountInserted){
            System.assertEquals(marketId, objAccount.Account_Market__c);
            System.assertNotEquals(NULL, objAccount.Geography__c);
            System.assertEquals('Completed', objAccount.Update_HQ_Market_Status__c);
        }
    }

  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies the Account records on which we need to find and update market but unomy data blank.
        Created Date  		:   23 January 2019
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    @isTest
    public static void verifyUpdateMarketOnAccountFailure(){
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());
        Test.startTest();
        List<Account> lstAccounts = new List<Account>();
        lstAccounts.add(new Account(Name='Master Account 1', Unomy_Company_ID__c = 1234561, Unomy_Updated_DateTime__c = Date.today(), Lead_Source__c = 'Test 1', Account_Type__c = 'Org'));
        lstAccounts.add(new Account(Name='Master Account 2', Unomy_Company_ID__c = 1234562, Unomy_Updated_DateTime__c = Date.today(), Lead_Source__c = 'Test 2', Account_Type__c = 'Org'));
        Database.insert(lstAccounts, false);
        List<Account> lstAccountInserted = [SELECT Id, Processing_Stage__c, Account_Market__c, Unomy_Company_ID__c, Geography__c, Market_Identified_On__c, Update_HQ_Market_Status__c FROM Account WHERE Id IN : lstAccounts];
        Database.executeBatch(new BatchToUpdateMarket('Account'));
        Test.stopTest();
        lstAccountInserted = [SELECT Id, Processing_Stage__c, Account_Market__c, Unomy_Company_ID__c, Geography__c, Market_Identified_On__c, Update_HQ_Market_Status__c FROM Account WHERE Id IN : lstAccountInserted];
        for(Account objAccount : lstAccountInserted){
            System.assertEquals(NULL, objAccount.Account_Market__c);
            System.assertEquals('HQ Market Identified', objAccount.Processing_Stage__c);
            System.assertEquals(NULL, objAccount.Geography__c);
            System.assertEquals('Retry Round 1', objAccount.Update_HQ_Market_Status__c);
        }
    }

   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method validate the assertion for Batch result
        Created Date  		:   23 January 2019
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public static void verifyAssertions(List<Lead> lstLeadsResult, String strStatus, String pStage, string leadPrStage){
        for(Lead objLead : lstLeadsResult){
            if(String.isNotBlank(strStatus)){
                System.assertEquals(strStatus, objLead.Update_HQ_Market_Status__c);
            }
            System.assertEquals(false, objLead.Lead_Demographic_Score_Re_calculate__c);
           // System.assertEquals(leadPrStage, objLead.Lead_Processing_Stage__c);
            System.assertEquals(pStage, objLead.Processing_Stage__c);
        }
    }


}