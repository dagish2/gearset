/************************************************************************************************************************************
    Author      :   Pragalbha Mahajan
    Description :   This class contains all test methods related to OpportunityLineItemTriggerHandler class.
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           08 March 2018       Pragalbha Mahajan       Initial Development
************************************************************************************************************************************/
@isTest
private class OpportunityLineItemTriggerHandlerTest {
    public static List<Product2> lstProducts = new List<Product2>();
    public static List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
    public static List<Opportunity> lstOpportunities = new List<Opportunity>();
    public static List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
    public static List<OpportunityLineItem> lstOpportunityLineItemToInsert = new List<OpportunityLineItem>();
    public static List<OpportunityLineItem> lstOpportunityLineItemToDelete = new List<OpportunityLineItem>();
    public static List<Geography__c> lstGeographies = new  List<Geography__c>();
    public static List<Building__c> lstBuilding = new List<Building__c>();
    public static PricebookEntry standardPrice1 = new PricebookEntry();
    public static PricebookEntry standardPrice2 = new PricebookEntry();
    public static PricebookEntry standardPrice3 = new PricebookEntry();
	@TestSetup
    static void initData(){ 
        SalesConsoleSettings.createSettings();
        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Id MidMarketRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        
        List<Account> lstAccounts = new List<Account>();
        Map<String, Object> accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName1', 'Number_of_Full_Time_Employees__c' => 1000, 'Account_Type__c' => 'Org'};
            
        lstAccounts.add(TestingUtility.createAccount(accountValuesMap, false)); 
        TestingUtility.insertListWithAssert(lstAccounts);
        
        List<Contact> lstContacts = new List<Contact>();
        Map<String, Object> contactValuesMap = new Map<String, Object>{'FirstName' => 'John',
            'LastName' => 'Smith',
            'Email' => 'testContact1@example.com',
            'AccountID' => lstAccounts[0].Id,
            'Status__c' => 'active'};
        lstContacts.add(TestingUtility.createContact(contactValuesMap, false));
        TestingUtility.insertListWithAssert(lstContacts);
        
        Map<String, Object> oppportunityValuesMap = new Map<String, Object>{'Primary_Member__c' => lstContacts[0].Id,
            'AccountId' =>  lstAccounts[0].Id,
            'StageName' =>  'Closing',
            'CurrencyIsoCode' => 'USD',
            'CloseDate' =>  system.today().addDays(5)};
        List<Map<String, Object>>  lstSobjectValueMap = new List<Map<String, Object>>();
        lstSobjectValueMap.add(oppportunityValuesMap);
        lstOpportunities.addAll((List<Opportunity>)TestingUtility.createTestRecords(3, Opportunity.sObjectType, lstSobjectValueMap, true));
        
        Map<String, Object> product2ValuesMap = new Map<String, Object>{
            'Product_Category__c' => 'Hot Desk',
                'Family' => 'WeWork',
                'Default_Product_Category__c' => 'Hot Desk',
                'ProductCode' => 'PRHD-000400',
                'IsActive' => true, 'Product_Category__c' => 'Hot Desk'};
        lstProducts.add((Product2)TestingUtility.createTestRecords(Product2.sObjectType, product2ValuesMap, false));
        
        product2ValuesMap.put('Name', 'Hospitality');
        product2ValuesMap.put('Product_Category__c', 'PxWe');
        product2ValuesMap.put('Family', 'PxWe');
        product2ValuesMap.put('Default_Product_Category__c', 'PxWe');
        product2ValuesMap.put('ProductCode', 'PxWe-Ho');
        lstProducts.add((Product2)TestingUtility.createTestRecords(Product2.sObjectType, product2ValuesMap, false));
        
        product2ValuesMap.put('Name', 'Deal');
        product2ValuesMap.put('Product_Category__c', 'Standard Office');
        product2ValuesMap.put('Family', 'Standard Office');
        product2ValuesMap.put('Default_Product_Category__c', 'Standard Office');
        product2ValuesMap.put('ProductCode', 'PRDL-000001');
        lstProducts.add((Product2)TestingUtility.createTestRecords(Product2.sObjectType, product2ValuesMap, false));
        
        product2ValuesMap.put('Name', 'DedicatedDesk');
        product2ValuesMap.put('Product_Category__c', 'Global Access');
        product2ValuesMap.put('Family', 'Global Access');
        product2ValuesMap.put('Default_Product_Category__c', 'Standard Office');
        product2ValuesMap.put('ProductCode', 'PRDE-000500');
        lstProducts.add((Product2)TestingUtility.createTestRecords(Product2.sObjectType, product2ValuesMap, false));
        
        product2ValuesMap.put('Name', 'Desk');
        product2ValuesMap.put('Product_Category__c', 'Standard Office; Custom Office; Large Office(WWLO)');
        product2ValuesMap.put('Family', 'WeWork');
        product2ValuesMap.put('Default_Product_Category__c', 'Custom Office');
        product2ValuesMap.put('ProductCode', 'PROF-000900');
        lstProducts.add((Product2)TestingUtility.createTestRecords(Product2.sObjectType, product2ValuesMap, false));
        TestingUtility.insertListWithAssert(lstProducts);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Map<String, Object> pricebookEntryValuesMap = new Map<String, Object>{'Pricebook2Id' => pricebookId,
            'Product2Id' => lstProducts[0].Id,
            'UnitPrice' => 10001,
            'IsActive' => true, 'CurrencyIsoCode' => 'USD'};
        lstPricebookEntry.add((PricebookEntry)TestingUtility.createTestRecords(PricebookEntry.sObjectType, pricebookEntryValuesMap, false));
        
        pricebookEntryValuesMap.put('Pricebook2Id', pricebookId);
        pricebookEntryValuesMap.put('Product2Id', lstProducts[3].Id);
        pricebookEntryValuesMap.put('UnitPrice', 10002);
        lstPricebookEntry.add((PricebookEntry)TestingUtility.createTestRecords(PricebookEntry.sObjectType, pricebookEntryValuesMap, false));                        
        
        pricebookEntryValuesMap.put('Pricebook2Id', pricebookId);
        pricebookEntryValuesMap.put('Product2Id', lstProducts[1].Id);
        pricebookEntryValuesMap.put('UnitPrice', 10003);
        lstPricebookEntry.add((PricebookEntry)TestingUtility.createTestRecords(PricebookEntry.sObjectType, pricebookEntryValuesMap, false));                        
        TestingUtility.insertListWithAssert(lstPricebookEntry);
        
        Map<String, Object> GeographyValuesMap = new Map<String, Object>{'Name' => 'Baner1,Maharashtra',
            'City__c' => 'Baner1,Maharashtra',
            'Country__c' => 'Netherlands',
            'District__c' => 'Pune',
            'Formatted_Address__c' => 'Baner, Pune, Maharashtra, India',
            'Geocode__Latitude__s' => 18.5596581,
            'Geocode__Longitude__s' => 73.7799374,
            'JSON__c' => '{"address_components":[{"long_name":"Baner","short_name":"Baner","types":["","sublocality","sublocality_level_1"]},{"long_name":"Pune","short_name":"Pune","types":["locality","political"]},{"long_name":"Pune","short_name":"Pune","types":["administrative_area_level_2","political"]},{"long_name":"Maharashtra","short_name":"MH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]}],"formatted_address":"Baner, Pune, Maharashtra, India","geometry":{"bounds":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}},"location":{"lat":18.5596581,"lng":73.7799374},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}}},"place_id":"ChIJy9Nd8M--wjsRfat_-5cSkaE","types":["political","sublocality","sublocality_level_1"]}',
            'Location_Type__c' => 'APPROXIMATE',
            'Place_ID__c' => 'ChIJy9Nd8M--wjsRfat_-5cSkaEvhj',
            'State__c' => 'Maharashtra'};
        lstGeographies.add((Geography__c)TestingUtility.createTestRecords(Geography__c.sObjectType, GeographyValuesMap, false));                        
        
        GeographyValuesMap.put('Name', 'Sangamner, Maharashtra');
        GeographyValuesMap.put('City__c', 'Sangamner, Maharashtra');
        GeographyValuesMap.put('Country__c', 'Indi2politicala');
        GeographyValuesMap.put('District__c', 'Ahmednagar'); 
        GeographyValuesMap.put('Formatted_Address__c', 'Sangamner, Maharashtra 422605, India');
        GeographyValuesMap.put('Geocode__Latitude__s', 19.5771387);
        GeographyValuesMap.put('Geocode__Longitude__s', 74.2079648);
        GeographyValuesMap.put('JSON__c', '{"address_components":[{"long_name":"Sangamner","short_name":"Sangamner","types":["locality","political"]},{"long_name":"Ahmednagar","short_name":"Ahmednagar","types":["administrative_area_level_2","political"]},{"long_name":"Maharashtra","short_name":"MH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]},{"long_name":"422605","short_name":"422605","types":["postal_code"]}],"formatted_address":"Sangamner, Maharashtra 422605, India","geometry":{"bounds":{"northeast":{"lat":19.5954532,"lng":74.2273235},"southwest":{"lat":19.5567976,"lng":74.1888714}},"location":{"lat":19.5771387,"lng":74.2079648},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":19.5954532,"lng":74.2273235},"southwest":{"lat":19.5567976,"lng":74.1888714}}},"partial_match":true,"place_id":"ChIJeavrqdAB3TsRiL6oagFS3UY","types":["locality","political"]}');
        GeographyValuesMap.put('Place_ID__c', 'ChIJy9Nd8M--wjsRfat_-5cSkaEnjbhjg');
        GeographyValuesMap.put('State__c', 'Maharashtra');
        lstGeographies.add((Geography__c)TestingUtility.createTestRecords(Geography__c.sObjectType, GeographyValuesMap, false));   
        
        GeographyValuesMap.put('Name', 'Melbourne VIC, Victoria');
        GeographyValuesMap.put('City__c', 'Victoria');
        GeographyValuesMap.put('Country__c', 'Australia');
        GeographyValuesMap.put('District__c', 'Ahmednagar'); 
        GeographyValuesMap.put('Formatted_Address__c', 'Melbourne VIC, Australia');
        GeographyValuesMap.put('Geocode__Latitude__s', 19.5771387);
        GeographyValuesMap.put('Geocode__Longitude__s', 74.2079648);
        GeographyValuesMap.put('JSON__c', '{"address_components":[{"long_name":"Melbourne","short_name":"Melbourne","types":["colloquial_area","locality","political"]},{"long_name":"Victoria","short_name":"VIC","types":["administrative_area_level_1","political"]},{"long_name":"Australia","short_name":"AU","types":["country","political"]}],"formatted_address":"Melbourne VIC, Australia","geometry":{"bounds":{"northeast":{"lat":-37.5112737,"lng":145.5125288},"southwest":{"lat":-38.4338593,"lng":144.5937418}},"location":{"lat":-37.8136276,"lng":144.9630576},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":-37.5112737,"lng":145.5125288},"southwest":{"lat":-38.4338593,"lng":144.5937418}}},"place_id":"ChIJ90260rVG1moRkM2MIXVWBAQ","types":["colloquial_area","locality","political"]}');
        GeographyValuesMap.put('Place_ID__c', 'ChIJ90260rVG1moRkM2MIXVWBAQ');
        GeographyValuesMap.put('State__c', 'Victoria');
        lstGeographies.add((Geography__c)TestingUtility.createTestRecords(Geography__c.sObjectType, GeographyValuesMap, false));   
        
        TestingUtility.insertListWithAssert(lstGeographies);
        
        Map<String, Object> mapBuildingValues = new Map<String, Object>{'City__c' => 'Pune',
            'Country__c' => 'Netherlands',
            'Name' => 'AMS-Metropool',
            'CurrencyIsoCode' => 'USD',
            'Geography__c' => lstGeographies[0].Id,
            'UUID__c' => '11111',
            'Time_Zone__c' => 'America/New_York'}; 
        lstBuilding.add(TestingUtility.createBuilding(mapBuildingValues, false));
        
        mapBuildingValues.put('City__c', 'Sangamner');
        mapBuildingValues.put('Country__c', 'Indi2politicala');
        mapBuildingValues.put('State__c', 'TS'); 
        mapBuildingValues.put('Name', 'BKN-Brooklyn Heights');
        mapBuildingValues.put('Geography__c', lstGeographies[1].Id);
        mapBuildingValues.put('UUID__c', '22222');                   
        lstBuilding.add(TestingUtility.createBuilding(mapBuildingValues, false));
        
        mapBuildingValues.put('City__c', 'Victoria');
        mapBuildingValues.put('Country__c', 'Australia');
        mapBuildingValues.put('State__c', 'TS'); 
        mapBuildingValues.put('Name', 'BL-Sony Center');
        mapBuildingValues.put('Geography__c', lstGeographies[2].Id);
        mapBuildingValues.put('UUID__c', '33333');                   
        lstBuilding.add(TestingUtility.createBuilding(mapBuildingValues, false)); 
        
        mapBuildingValues.put('City__c', 'Nashik');
        mapBuildingValues.put('Country__c', 'India');
        mapBuildingValues.put('State__c', 'TS'); 
        mapBuildingValues.put('Name', 'BL-Tower');
        mapBuildingValues.put('Geography__c', lstGeographies[2].Id);
        mapBuildingValues.remove('UUID__c');                   
        lstBuilding.add(TestingUtility.createBuilding(mapBuildingValues, false)); 
        TestingUtility.insertListWithAssert(lstBuilding);
        
        lstGeographies[0].Nearest_Building__c = lstBuilding[0].Id;
        lstGeographies[1].Nearest_Building__c = lstBuilding[1].Id;
        lstGeographies[2].Nearest_Building__c = lstBuilding[2].Id;
        TestingUtility.updateListWithAssert(lstGeographies);
    }
    
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan 
        Description         :   Test method to update Opportunity Type according to Product Category.
        Issue No.           :   ST-2041
    **************************************************************************************************************************************/
    public static testMethod void updateOpportunityTypeTest()
    {  
        System.debug('1.Number of Queries used in this apex code so far before StartTest: ' + Limits.getQueries());
        lstOpportunities = [SELECT Type__c FROM Opportunity];
        List<Building__c> lstBuilding = [SELECT Name, UUID__c FROM Building__c];
        lstGeographies = [SELECT Id, Name FROM Geography__c];
        
        for(PricebookEntry objPricebookEntry : [SELECT Id, Name, UnitPrice FROM PricebookEntry]){
            if(objPricebookEntry.UnitPrice == 10001){
                standardPrice1 = objPricebookEntry;
            }else if(objPricebookEntry.UnitPrice == 10002){
                 standardPrice2 = objPricebookEntry;
            }else if(objPricebookEntry.UnitPrice == 10003){
                standardPrice3 = objPricebookEntry;
            }
        }
        
        Map<String, Object> mapOpportunityLineItemValues = new Map<String, Object>{'PricebookEntryId' => standardPrice1.Id,
            'OpportunityId' => lstOpportunities[0].Id,
            'UnitPrice' => 10,
            'Quantity' => 20,
            'Geography__c' => lstGeographies[0].Id}; 
        lstOpportunityLineItem.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false));
        
        mapOpportunityLineItemValues.put('PricebookEntryId', standardPrice3.Id);
        mapOpportunityLineItemValues.put('OpportunityId', lstOpportunities[0].Id);
        mapOpportunityLineItemValues.put('UnitPrice', 30); 
        mapOpportunityLineItemValues.put('Quantity', 40);
        mapOpportunityLineItemValues.put('Building__c',  lstBuilding[0].Id);  
        lstOpportunityLineItem.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false)); 
        
        mapOpportunityLineItemValues.put('PricebookEntryId', standardPrice1.Id);
        mapOpportunityLineItemValues.put('UnitPrice', 50); 
        mapOpportunityLineItemValues.put('Quantity', 60);
        mapOpportunityLineItemValues.put('Geography__c', lstGeographies[1].Id);  
        lstOpportunityLineItem.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false));
        
        mapOpportunityLineItemValues.put('PricebookEntryId', standardPrice1.Id);
        mapOpportunityLineItemValues.put('OpportunityId', lstOpportunities[1].Id);
        mapOpportunityLineItemValues.put('UnitPrice', 30); 
        mapOpportunityLineItemValues.put('Quantity', 40);
        mapOpportunityLineItemValues.put('Building__c', lstBuilding[1].Id);  
        lstOpportunityLineItem.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false));
        
        mapOpportunityLineItemValues.put('PricebookEntryId', standardPrice1.Id);
        mapOpportunityLineItemValues.put('OpportunityId', lstOpportunities[2].Id);
        mapOpportunityLineItemValues.put('Geography__c', lstGeographies[2].Id);  
        lstOpportunityLineItem.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false));
        
        mapOpportunityLineItemValues.put('PricebookEntryId', standardPrice2.Id);
        mapOpportunityLineItemValues.put('Building__c', lstBuilding[2].Id);  
        lstOpportunityLineItem.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false));
       
		mapOpportunityLineItemValues.put('PricebookEntryId', standardPrice2.Id);
        mapOpportunityLineItemValues.put('Building__c', lstBuilding[3].Id);  
        lstOpportunityLineItem.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false)); 
        TestingUtility.insertListWithAssert(lstOpportunityLineItem);
        Test.startTest();
        debug.log('lstOpportunities: '+lstOpportunities);
        for(Opportunity objOpportunity : [SELECT Type__c FROM Opportunity]){
            if(objOpportunity.Id ==  lstOpportunities[0].Id){
                system.assertEquals('Mixed', objOpportunity.Type__c);
            }else if(objOpportunity.Id ==  lstOpportunities[1].Id){
                system.assertEquals('WeWork', objOpportunity.Type__c);
            }else if(objOpportunity.Id ==  lstOpportunities[2].Id){
                system.assertEquals('Mixed', objOpportunity.Type__c);
            }
        }
     
        lstOpportunityLineItemToDelete.add(lstOpportunityLineItem[0]);
        lstOpportunityLineItemToDelete.add(lstOpportunityLineItem[2]);
        lstOpportunityLineItemToDelete.add(lstOpportunityLineItem[5]);
        lstOpportunityLineItemToDelete.add(lstOpportunityLineItem[6]);
        TestingUtility.deleteListWithAssert(lstOpportunityLineItemToDelete);
        
        for(Opportunity objOpportunity : [SELECT Type__c FROM Opportunity]){
            if(objOpportunity.Id ==  lstOpportunities[0].Id){
                system.assertEquals('PxWe', objOpportunity.Type__c);
            }else if(objOpportunity.Id ==  lstOpportunities[1].Id){
                system.assertEquals('WeWork', objOpportunity.Type__c);
            }else if(objOpportunity.Id ==  lstOpportunities[2].Id){
                system.assertEquals('WeWork', objOpportunity.Type__c);
            }
        }
        
        TestingUtility.deleteWithAssert(lstOpportunityLineItem[1]);
        for(Opportunity objOpportunity : [SELECT Type__c FROM Opportunity WHERE Id =: lstOpportunities[0].Id]){
            system.assertEquals(null, objOpportunity.Type__c);	  
        }
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Samadhan Kadam 
        Description         :   Test method for map Product field on opportunity Line Item(populateProductFieldsOnLineItems method)
        Issue No.           :   ST-1718
		Date				:	04/05/2018
    **************************************************************************************************************************************/
    public static testMethod void testPopulateProductFieldsOnLineItems(){
        PricebookEntry standardPrice1 , standardPrice2, standardPrice3;
        lstGeographies = [SELECT Id, Name, Nearest_Building__c FROM Geography__c];
        for(PricebookEntry objPricebookEntry : [SELECT Id, Name, UnitPrice FROM PricebookEntry]){
            if(objPricebookEntry.UnitPrice == 10001){
                standardPrice1 = objPricebookEntry;
            }else if(objPricebookEntry.UnitPrice == 10002){
                 standardPrice2 = objPricebookEntry;
            }else if(objPricebookEntry.UnitPrice == 10003){
                standardPrice3 = objPricebookEntry;
            }
        }
        Product2 objProduct1, objProduct2, objProduct3, objProduct4, objProduct5;
        lstOpportunities = [SELECT Type__c FROM Opportunity];
        for(Product2 objProduct : [SELECT Id, Name, Product_Category__c FROM Product2]){
            if(objProduct.Name == 'Hot Desk'){
                objProduct1 = objProduct;
            }else if(objProduct.Name == 'Hospitality'){
                objProduct2 = objProduct;
            }else if(objProduct.Name == 'Deal'){
                objProduct3 = objProduct;
            }else if(objProduct.Name == 'DedicatedDesk'){
                objProduct4 = objProduct;
            }else if(objProduct.Name == 'Desk'){
                objProduct5 = objProduct;
            }
        }
        List<OpportunityLineItem> lstoppLineItemInsert = new List<OpportunityLineItem>();
        Map<String, Object> mapOpportunityLineItemValues = new Map<String, Object>{'PricebookEntryId' => standardPrice2.Id,
            'OpportunityId' => lstOpportunities[1].Id,
            'UnitPrice' => 10,
            'Quantity' => 20,
            'Geography__c' => lstGeographies[0].Id,
            'ProductCode__c' => 'PRDE-000500',
            'Product_Category__c' => 'Global Access'}; 
        lstoppLineItemInsert.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false));
        
        mapOpportunityLineItemValues.remove('Product_Category__c');
        mapOpportunityLineItemValues.remove('UnitPrice');
        mapOpportunityLineItemValues.put('PricebookEntryId', standardPrice2.Id);
        mapOpportunityLineItemValues.put('Totalprice', 200); 
        mapOpportunityLineItemValues.put('Quantity', 4);
        mapOpportunityLineItemValues.put('Product2Id',  objProduct4.Id);  
        lstoppLineItemInsert.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false)); 
      	
        mapOpportunityLineItemValues.put('PricebookEntryId', standardPrice2.Id);
        mapOpportunityLineItemValues.put('Totalprice', 200); 
        mapOpportunityLineItemValues.put('ProductCode__c', 'PRDL-12345');
        mapOpportunityLineItemValues.put('Quantity', 4);
        mapOpportunityLineItemValues.put('Product2Id',  objProduct5.Id);  
        mapOpportunityLineItemValues.put('Product_Category__c', 'PxWe');
        mapOpportunityLineItemValues.put('Family__c', 'WeWork');
        lstoppLineItemInsert.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false)); 
        TestingUtility.insertListWithAssert(lstoppLineItemInsert);
        
        Settings.FieldMappings abc = OpportunityLineItemTriggerHandler.ProductToOpportunityLineItem();
        
        for(OpportunityLineItem objOppLineItem : [SELECT ID, Name, UnitPrice, Product_Category__c, ProductCode__c, Family__c FROM OpportunityLineItem]){
            if(objOppLineItem.Id == lstoppLineItemInsert[0].Id){
                System.assertEquals('PRDE-000500', objOppLineItem.ProductCode__c);
            } else if(objOppLineItem.Id == lstoppLineItemInsert[1].Id){
                system.assertEquals('PRDE-000500', objOppLineItem.ProductCode__c);
                system.assertEquals('Standard Office', objOppLineItem.Product_Category__c);
            } else if(objOppLineItem.Id == lstoppLineItemInsert[2].Id){
                system.assertEquals('PRDL-12345', objOppLineItem.ProductCode__c);
                system.assertEquals('PxWe', objOppLineItem.Product_Category__c);
                system.assertEquals('WeWork', objOppLineItem.Family__c);
            }
        }
        
        lstoppLineItemInsert[2].Family__c = 'Global Access';
        TestingUtility.updateListWithAssert(lstoppLineItemInsert);
        
      	OpportunityLineItem oppLineItem = [SELECT ID, Name, UnitPrice, Product_Category__c, ProductCode__c, Family__c FROM OpportunityLineItem WHERE ID =: lstoppLineItemInsert[2].Id];
        system.assertEquals('PRDE-000500', oppLineItem.ProductCode__c);
    }
    
    /************************************************************************************************************************************
    Author 				: 	Priyanka Ambre
    Description 		: 	This method will test updateBuildingFromGeography. 
    Issue No.			:	ST-2317
	Created Date        :   04 April 2018
    **************************************************************************************************************************************/ 
    public static testMethod void testUpdateBuildingFromGeography(){
        lstOpportunities = [SELECT Type__c FROM Opportunity];
        lstGeographies = [SELECT Id, Name, Nearest_Building__c FROM Geography__c];
        lstBuilding = [SELECT Name, UUID__c FROM Building__c];
        List<OpportunityLineItem> lstOpportunityLineItemToInsert = new List<OpportunityLineItem>();
        List<PricebookEntry> lstPricebookEntry = [SELECT Id, Name, UnitPrice FROM PricebookEntry];
        
        Map<String, Object> mapOpportunityLineItemValues = new Map<String, Object>{'PricebookEntryId' => lstPricebookEntry[0].Id,
            'OpportunityId' => lstOpportunities[0].Id,
            'UnitPrice' => 10,
            'Quantity' => 20,
            'Geography__c' => lstGeographies[0].Id,
            'Family__c' => 'WeWork'}; 
        lstOpportunityLineItemToInsert.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false));
        
        mapOpportunityLineItemValues.put('PricebookEntryId', lstPricebookEntry[1].Id);
        mapOpportunityLineItemValues.put('OpportunityId', lstOpportunities[0].Id);
        mapOpportunityLineItemValues.put('UnitPrice', 10); 
        mapOpportunityLineItemValues.put('Quantity', 20);
        mapOpportunityLineItemValues.put('Geography__c', lstGeographies[1].Id);  
        mapOpportunityLineItemValues.put('Family__c', 'PxWe');  
        lstOpportunityLineItemToInsert.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false)); 
        
        mapOpportunityLineItemValues.put('PricebookEntryId', lstPricebookEntry[2].Id);
        mapOpportunityLineItemValues.put('OpportunityId', lstOpportunities[1].Id);
        mapOpportunityLineItemValues.put('UnitPrice', 10); 
        mapOpportunityLineItemValues.put('Quantity', 20);
        mapOpportunityLineItemValues.put('Geography__c', lstGeographies[0].Id);  
        mapOpportunityLineItemValues.put('Family__c', 'Global Access');  
        lstOpportunityLineItemToInsert.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false)); 
       
        mapOpportunityLineItemValues.put('PricebookEntryId', lstPricebookEntry[0].Id);
        mapOpportunityLineItemValues.put('UnitPrice', 10); 
        mapOpportunityLineItemValues.put('Quantity', 40);
        mapOpportunityLineItemValues.put('Geography__c', lstGeographies[2].Id);  
        mapOpportunityLineItemValues.put('Family__c', 'Global Access');  
        lstOpportunityLineItemToInsert.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false)); 
       
        mapOpportunityLineItemValues.remove('Geography__c');
        mapOpportunityLineItemValues.put('PricebookEntryId', lstPricebookEntry[1].Id);
        mapOpportunityLineItemValues.put('OpportunityId', lstOpportunities[2].Id);
        mapOpportunityLineItemValues.put('UnitPrice', 10); 
        mapOpportunityLineItemValues.put('Quantity', 20);
        mapOpportunityLineItemValues.put('Family__c', 'WeWork');  
        lstOpportunityLineItemToInsert.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false)); 
        TestingUtility.insertListWithAssert(lstOpportunityLineItemToInsert);
        
        for(OpportunityLineItem oppLineItem : [SELECT Id, pricebookEntryId, OpportunityId, UnitPrice, Family__c, Building__c, Geography__c FROM OpportunityLineItem]){
            if(oppLineItem.Id == lstOpportunityLineItemToInsert[0].Id){
                System.assertEquals(lstGeographies[0].Id, oppLineItem.Geography__c);
                System.assertEquals(lstGeographies[0].Nearest_Building__c, oppLineItem.Building__c);
            } else if(oppLineItem.Id == lstOpportunityLineItemToInsert[1].Id){
                System.assertEquals(lstGeographies[1].Id, oppLineItem.Geography__c);  
                System.assertEquals(lstGeographies[1].Nearest_Building__c, oppLineItem.Building__c);
            } else if(oppLineItem.Id == lstOpportunityLineItemToInsert[2].Id){
                System.assertEquals(lstGeographies[0].Id, oppLineItem.Geography__c);           
                System.assertEquals(lstGeographies[0].Nearest_Building__c, oppLineItem.Building__c);
            } else if(oppLineItem.Id == lstOpportunityLineItemToInsert[3].Id){
                System.assertEquals(lstGeographies[2].Id, oppLineItem.Geography__c);           
                System.assertEquals(lstGeographies[2].Nearest_Building__c, oppLineItem.Building__c);
            } else if(oppLineItem.Id == lstOpportunityLineItemToInsert[4].Id){
                System.assertEquals(null, oppLineItem.Geography__c);           
                System.assertEquals(null, oppLineItem.Building__c);
            } 
        }
        
        lstOpportunityLineItemToInsert[0].Geography__c = lstGeographies[1].Id;
        lstOpportunityLineItemToInsert[0].Building__c = null;
        lstOpportunityLineItemToInsert[1].Geography__c = lstGeographies[0].Id;
        lstOpportunityLineItemToInsert[1].Building__c = null;
        lstOpportunityLineItemToInsert[4].Geography__c = lstGeographies[0].Id;
        lstOpportunityLineItemToInsert[4].Building__c = null;
        List<OpportunityLineItem> lstOppLineItemToUpdate = new List<OpportunityLineItem>();
        lstOppLineItemToUpdate.add(lstOpportunityLineItemToInsert[0]);
        lstOppLineItemToUpdate.add(lstOpportunityLineItemToInsert[1]);
        lstOppLineItemToUpdate.add(lstOpportunityLineItemToInsert[4]); 
        TestingUtility.updateListWithAssert(lstOppLineItemToUpdate);
        for(OpportunityLineItem oppLineItem : [SELECT Id, pricebookEntryId, OpportunityId, UnitPrice, Family__c, Building__c, Geography__c FROM OpportunityLineItem]){
            if(oppLineItem.Id == lstOpportunityLineItemToInsert[0].Id){
                System.assertEquals(lstGeographies[1].Id, oppLineItem.Geography__c);
                System.assertEquals(lstGeographies[1].Nearest_Building__c, oppLineItem.Building__c);
            } else if(oppLineItem.Id == (lstOpportunityLineItemToInsert[1].Id)){
                System.assertEquals(lstGeographies[0].Id, oppLineItem.Geography__c);  
                System.assertEquals(lstGeographies[0].Nearest_Building__c, oppLineItem.Building__c);
            } else if(oppLineItem.Id == lstOpportunityLineItemToInsert[4].Id){
                System.assertEquals(lstGeographies[0].Id, oppLineItem.Geography__c);           
                System.assertEquals(lstGeographies[0].Nearest_Building__c, oppLineItem.Building__c);
            }
        } 
    }
    
    /************************************************************************************************************************************
    Author 				: 	Nikhil Mehta
    Description 		: 	This method will test updateBuildingUUID. 
    Issue No.			:	
	Created Date        :   07 May 2018
    **************************************************************************************************************************************/ 
    public static testMethod void testupdateBuildingUUID(){
        lstOpportunities = [SELECT Type__c FROM Opportunity];
        //test
        
    	for(PricebookEntry objPricebookEntry : [SELECT Id, Name, UnitPrice FROM PricebookEntry]){
           if(objPricebookEntry.UnitPrice == 10001){
               standardPrice1 = objPricebookEntry;
           }else if(objPricebookEntry.UnitPrice == 10002){
               standardPrice2 = objPricebookEntry;
           }else if(objPricebookEntry.UnitPrice == 10003){
               standardPrice3 = objPricebookEntry;
           }
       }
        
        List<Building__c> lstBuilding = [SELECT Name, UUID__c FROM Building__c];
        Building__c objBuilding1 = new Building__c();
        
        for(Building__c building : lstBuilding){
            if(building.Name == 'BL-Tower'){
                objBuilding1 = building;
            }
        }
        
        Map<String, Object> mapOpportunityLineItemValues = new Map<String, Object>{'PricebookEntryId' => standardPrice3.Id,
            'OpportunityId' => lstOpportunities[0].Id,
            'UnitPrice' => 30,
            'Quantity' => 40,
            'Building__c' => lstBuilding[0].Id}; 
        lstOpportunityLineItem.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false));
        
        mapOpportunityLineItemValues.put('PricebookEntryId', standardPrice2.Id);
        mapOpportunityLineItemValues.put('OpportunityId', lstOpportunities[2].Id);
        mapOpportunityLineItemValues.put('UnitPrice', 50); 
        mapOpportunityLineItemValues.put('Quantity', 60);
        mapOpportunityLineItemValues.put('Building__c',  lstBuilding[2].Id);  
        lstOpportunityLineItem.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false));
        
        mapOpportunityLineItemValues.put('PricebookEntryId', standardPrice2.Id);
        mapOpportunityLineItemValues.put('Building__c',  lstBuilding[3].Id);  
        lstOpportunityLineItem.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false));
        
        mapOpportunityLineItemValues.put('PricebookEntryId', standardPrice1.Id);
        mapOpportunityLineItemValues.put('OpportunityId', lstOpportunities[1].Id);
        mapOpportunityLineItemValues.put('UnitPrice', 10); 
        mapOpportunityLineItemValues.put('Quantity', 20);
        mapOpportunityLineItemValues.put('Building__c',  lstBuilding[2].Id);  
        lstOpportunityLineItem.add(TestingUtility.createOpportunityLineItem(mapOpportunityLineItemValues, false));
        
        TestingUtility.insertListWithAssert(lstOpportunityLineItem);
        Test.startTest();
      
        objBuilding1.UUID__c = '44444';
        
        TestingUtility.updateWithAssert(objBuilding1);
        
        lstOpportunityLineItem[2].Quantity = 65;
        lstOpportunityLineItem[3].Building_UUID__c = null;
        TestingUtility.upsertListWithAssert(lstOpportunityLineItem);
        for(OpportunityLineItem objOpportunityLineItem :[SELECT Id, Building__c, Building__r.UUID__c, Building_UUID__c FROM OpportunityLineItem]){
            if(objOpportunityLineItem.Building__r.UUID__c == '11111'){
                System.assertEquals(objOpportunityLineItem.Building_UUID__c,'11111');
            }else if(objOpportunityLineItem.Building__r.UUID__c == '22222'){
                System.assertEquals(objOpportunityLineItem.Building_UUID__c, '22222');
            }else if(objOpportunityLineItem.Building__r.UUID__c == '33333'){
                System.assertEquals(objOpportunityLineItem.Building_UUID__c,'33333');
            }else if(objOpportunityLineItem.Building__r.UUID__c == '44444'){
                System.assertEquals(objOpportunityLineItem.Building_UUID__c, '44444');
            }
        }
    }
}