/************************************************************************************************************************************
    Author      :   Nikhil Mehta    
    Description :   This class contain all test methods related to ManageLineItemController class.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           17 July 2018        Nikhil Mehta            Initial Developement
**************************************************************************************************************************************/
@isTest
public class ManageLineItemControllerTests {
    public static List<Product2> lstProducts = new List<Product2>();
    public static List<Building__c> lstBuildings = new List<Building__c>();
    public static List<Geography__c> lstGeographies = new List<Geography__c>();
    public static List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
    public static List<Account> lstAccounts = new List<Account>();
    public static List<Contact> lstContacts = new List<Contact>();
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        Product2 prod = new Product2(Name = 'Deal',ProductCode = 'PRDL-000001',Default_Product_Category__c='Custom Office',IsActive = true);
        lstProducts.add(prod);
        Product2 prod1 = new Product2(Name = 'Hot Desk',ProductCode = 'PRHD-000400',Default_Product_Category__c='Custom Office',IsActive = true);
        lstProducts.add(prod1);
        Product2 prod2 = new Product2(Name = 'Desk',ProductCode = 'PRDE-000200',Default_Product_Category__c='Custom Office',IsActive = true);
        lstProducts.add(prod2);
        Product2 prod3 = new Product2(Name = 'DedicatedDesk',ProductCode = 'NotConsidered',Default_Product_Category__c='Custom Office',IsActive = true);
        lstProducts.add(prod3);
        TestingUtility.insertListWithAssert(lstProducts);
        
        Building__c building1 = new Building__c(Name='ATL-Tower',uuid__c = 'abc123');
        lstBuildings.add(building1);
        Building__c building2 = new Building__c(Name='ATL-Enzigma Tower',uuid__c = 'abc1234');
        lstBuildings.add(building2);
        insert lstBuildings;
        System.assertNotEquals(null, building1.Id);
        System.assertNotEquals(null, building2.Id);
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        //Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id, UnitPrice = 10000, IsActive = true, CurrencyIsoCode = 'USD' );
        lstPricebookEntry.add(standardPrice1);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true, CurrencyIsoCode = 'INR' );
        lstPricebookEntry.add(standardPrice2);
        TestingUtility.insertListWithAssert(lstPricebookEntry);
        
        lstAccounts.add(new Account(Name = 'strAccountName1',Number_of_Full_Time_Employees__c=1000));
        insert lstAccounts;
        System.assertNotEquals(null, lstAccounts[0].Id);
        
        lstContacts.add(new Contact(FirstName = 'John', LastName = 'Smith', Email = 'testContact1@example.com', AccountID = lstAccounts[0].Id, Status__c = 'active'));
        insert lstContacts;
        System.assertNotEquals(null,lstContacts[0].Id);
        
        Geography__c objGeography = new Geography__c(
                Name='Baner1,Maharashtra',
                City__c='Pune',
                Country__c='Indi2politicala', District__c='Pune',
                Formatted_Address__c='Baner, Pune, Maharashtra, India', 
                Geocode__Latitude__s=18.5596581,
                Geocode__Longitude__s=73.7799374,
                JSON__c='{"address_components":[{"long_name":"Baner","short_name":"Baner","types":["","sublocality","sublocality_level_1"]},{"long_name":"Pune","short_name":"Pune","types":["locality","political"]},{"long_name":"Pune","short_name":"Pune","types":["administrative_area_level_2","political"]},{"long_name":"Maharashtra","short_name":"MH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]}],"formatted_address":"Baner, Pune, Maharashtra, India","geometry":{"bounds":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}},"location":{"lat":18.5596581,"lng":73.7799374},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}}},"place_id":"ChIJy9Nd8M--wjsRfat_-5cSkaE","types":["political","sublocality","sublocality_level_1"]}',
                Location_Type__c='APPROXIMATE', 
                Place_ID__c='ChIJy9Nd8M--wjsRfat_-5cSkaE', 
                State__c='Maharashtra',
                Nearest_Building__c = building1.Id
            ); 
            upsert  objGeography Place_ID__c;
            System.assertNotEquals(null, objGeography.Id);
            Geography__c objGeography1 = new Geography__c(
                Name='Baner2,Maharashtra',
                City__c='Pune',
                Country__c='Indi2politicala', District__c='Pune',
                Formatted_Address__c='Baner, Pune, Maharashtra, India', 
                Geocode__Latitude__s=18.559659,
                Geocode__Longitude__s=73.779931,
                JSON__c='{"address_components":[{"long_name":"Baner","short_name":"Baner","types":["","sublocality","sublocality_level_1"]},{"long_name":"Pune","short_name":"Pune","types":["locality","political"]},{"long_name":"Pune","short_name":"Pune","types":["administrative_area_level_2","political"]},{"long_name":"Maharashtra","short_name":"MH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]}],"formatted_address":"Baner, Pune, Maharashtra, India","geometry":{"bounds":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}},"location":{"lat":18.5596581,"lng":73.7799374},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":18.5756111,"lng":73.8043045},"southwest":{"lat":18.544332,"lng":73.76332800000002}}},"place_id":"ChIJy9Nd8M--wjsRfat_-5cSkaE","types":["political","sublocality","sublocality_level_1"]}',
                Location_Type__c='APPROXIMATE', 
                Place_ID__c='ChIUJy9Nd8M--wjsRJfat_-5cSkaGE', 
                State__c='Maharashtra',
                Nearest_Building__c = building1.Id
            ); 
            upsert  objGeography1 Place_ID__c;
            System.assertNotEquals(null, objGeography1.Id);
    }
	/************************************************************************************************************************************
        Author         : Priyanka Ambre
        Description    : This method brings the all products for the given opp if logged in user have the permissions.
        Created Date   : 04 May 2018 
        Issue No       : ST-2356
    **************************************************************************************************************************************/
     public static testMethod void getManageProductsTest(){
        Profile systemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        debug.Log('systemAdmin' + systemAdmin);
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];
        debug.Log('weworkSystemAdmin' + weworkSystemAdmin);
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>(); 
        
        List<User> lstusers = new List<User>();
        User user1 = new User(LastName = 'Last Name 1',Username = 'testwework111017_1@example.com',Email = 'testwework1@example.com',ProfileId = systemAdmin.Id,EmailEncodingKey = 'ISO-8859-1',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',TimeZoneSidKey = 'America/Los_Angeles',Alias = 'Name 1',IsActive = true);
        lstusers.add(user1);
        User user2 = new User(LastName = 'Last Name 2',Username = 'testwework05052018@example.com',Email = 'testwework05052018@example.com',ProfileId = weworkSystemAdmin.Id,EmailEncodingKey = 'ISO-8859-1',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',TimeZoneSidKey = 'America/Los_Angeles',Alias = 'Name 1',IsActive = true);
        lstusers.add(user2);
        TestingUtility.insertListWithAssert(lstusers); 
        
        Account accRec = [SELECT Id, OwnerId FROM Account][0];
        accRec.ownerId = user1.Id;
        update accRec;
        Contact contactRec = [SELECT Id, OwnerId FROM Contact][0];
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec1.Primary_Member__c = contactRec.Id;
        oppRec1.StageName = 'Closing';
        oppRec1.CurrencyIsoCode = 'USD';
        oppRec1.CloseDate = system.today().addDays(5); 
        oppRec1.OwnerId = user1.Id;
        insert oppRec1;
        System.assertNotEquals(null, oppRec1.Id);
         
        PricebookEntry standardPrice1 = [SELECT Id FROM PriceBookEntry][0];
        OpportunityLineItem objOpportunityLineItem1 = new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20);
        lstOpportunityLineItem.add(objOpportunityLineItem1);
        
        OpportunityLineItem objOpportunityLineItem2 = new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20);
        lstOpportunityLineItem.add(objOpportunityLineItem2); 
        Test.startTest();
        TestingUtility.insertListWithAssert(lstOpportunityLineItem);
        System.runAs(user2){//true
            String result  = (String)ManageLineItemController.getManageProducts(oppRec1.Id).data;
            Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(result);
            Debug.log('mapResult---'+mapResult);
            System.assertNotEquals('null', String.valueOf(mapResult.get('isValidForManageProduct')));
            System.assertNotEquals(null, mapResult.get('oppRec'));
         }
        System.runAs(user1){//true
            String result  = (String)ManageLineItemController.getManageProducts(oppRec1.Id).data;
            Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(result);
            Debug.log('mapResult---'+mapResult);
            System.assertNotEquals('null', String.valueOf(mapResult.get('isValidForManageProduct')));
            System.assertNotEquals(null, mapResult.get('oppRec'));
            Debug.log('mapResult---' + mapResult);
        } 
        oppRec1.OwnerId = user2.Id;
        update oppRec1;
        for(Opportunity opp: [SELECT Id, OwnerId FROM Opportunity]){
            if(opp.Id == oppRec1.Id){
                System.assertEquals(user2.Id, opp.OwnerId);
            }
        }        
        System.runAs(user1){//false
            String result  = (String)ManageLineItemController.getManageProducts(oppRec1.Id).data;
            Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(result);
            Debug.log('mapResult---'+mapResult); 
            System.assertNotEquals('null', String.valueOf(mapResult.get('isValidForManageProduct')));
            System.assertNotEquals(null, mapResult.get('oppRec'));
            Debug.log('mapResult---' + mapResult);
        } 
     }
    /************************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method tests saveOpportunityProducts when building present.
        Created Date        : 20 March 2018 
    **************************************************************************************************************************************/
    public static testMethod void verifySaveOpportunityProductWhenBuildingPresent(){
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        String currencyCode = 'USD';
        Account accRec = [SELECT Id FROM Account][0];
		Contact contactRec = [SELECT Id FROM Contact][0];        
        lstBuildings = [SELECT Id FROM Building__c];
        Building__c building1 = lstBuildings[0];
        Building__c building2 = lstBuildings[1];
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec1.Primary_Member__c = contactRec.Id;
        oppRec1.StageName = 'Closing';
        oppRec1.CurrencyIsoCode = 'USD';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.Building__c = building1.Id;
        insert oppRec1;
        System.assertNotEquals(null, oppRec1.Id);
        
        PricebookEntry standardPrice1 = [SELECT Id FROM PriceBookEntry][0];
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20));
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20,Family__c = 'Wework',Is_Primary_Product__c = true,Building__c = building2.Id));
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20));
        
        String result = (String)ManageLineItemController.saveOpportunityProducts(oppRec1.Id, lstOpportunityLineItem, currencyCode, true).data;
        Debug.Log('Result---'+result);
        Opportunity oppRec2 = [SELECT Id, Building__c FROM Opportunity WHERE Id =: oppRec1.Id];
        System.assertEquals(building2.Id, oppRec2.Building__c);
        try{
            result = (String)ManageLineItemController.saveOpportunityProducts(null, null, null, null).data;
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    /************************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method tests saveOpportunityProducts when building and geography both are present.
        Created Date        : 17 July 2018 
    **************************************************************************************************************************************/
    public static testMethod void verifySaveOpportunityProductsWhenBuildingAndGeoBothPresent(){
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        String currencyCode = 'INR';
        Account accRec = [SELECT Id FROM Account][0];
        Contact contactRec = [SELECT Id FROM Contact][0];
        lstBuildings = [SELECT Id FROM Building__c];
        Building__c building1 =lstBuildings[0];
        Building__c building2 =lstBuildings[1];
        Geography__c objGeography = [SELECT Id, Nearest_Building__c FROM Geography__c][0];
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec1.Primary_Member__c = contactRec.Id;
        oppRec1.StageName = 'Closing';
        oppRec1.CurrencyIsoCode = 'USD';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.Building__c = building1.Id;
        insert oppRec1;
        System.assertNotEquals(null, oppRec1.Id);
        
        PricebookEntry standardPrice1 = [SELECT Id FROM PricebookEntry][0];
               
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20));
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20,Family__c = 'Wework',Is_Primary_Product__c = true,Building__c = building2.Id,Geography__c = objGeography.Id));
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20));
        
        String result = (String)ManageLineItemController.saveOpportunityProducts(oppRec1.Id, lstOpportunityLineItem, currencyCode, false).data;
        Debug.Log('Result---'+result);
        Opportunity oppRec2 = [SELECT Id, Building__c FROM Opportunity WHERE Id =: oppRec1.Id];
        System.assertEquals(building1.Id, oppRec2.Building__c);
        try{
            result = (String)ManageLineItemController.saveOpportunityProducts(null, null, null, null).data;
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    /************************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method tests saveOpportunityProducts when geography both are present.
        Created Date        : 17 July 2018 
    **************************************************************************************************************************************/
    public static testMethod void verifySaveOpportunityProductsWhenGeographyPresent(){
        //When Opportunity and Primary product's Geography are equal.
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        String currencyCode = 'USD';
        Account accRec = [SELECT Id FROM Account][0];
        Contact contactRec = [SELECT Id FROM Contact][0];
        lstBuildings = [SELECT Id FROM Building__c];
        Building__c building1 =lstBuildings[0];
        Building__c building2 =lstBuildings[1];
        lstGeographies = [SELECT Id, Nearest_Building__c FROM Geography__c];
        Geography__c objGeography = lstGeographies[0];
        Geography__c objGeography1 = lstGeographies[1];
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec1.Primary_Member__c = contactRec.Id;
        oppRec1.StageName = 'Closing';
        oppRec1.CurrencyIsoCode = 'USD';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.Geography__c = objGeography.Id;
        insert oppRec1;
        System.assertNotEquals(null, oppRec1.Id);
        
        objGeography.Nearest_Building__c = building2.Id;
        update objGeography;
        PricebookEntry standardPrice1 = [SELECT Id FROM PricebookEntry][0];
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20));
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20,Family__c = 'Wework',Is_Primary_Product__c = true,Geography__c = objGeography.Id));
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20));
        
        String result = (String)ManageLineItemController.saveOpportunityProducts(oppRec1.Id, lstOpportunityLineItem, currencyCode, false).data;
        Debug.Log('Result---'+result);
        Opportunity oppRec2 = [SELECT Id, Building__c FROM Opportunity WHERE Id =: oppRec1.Id];
        System.assertEquals(building2.Id, oppRec2.Building__c);
        
        //When Opportunity and Primary product's Geography are not equal.
        lstOpportunityLineItem.clear();
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20));
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20,Family__c = 'Wework',Is_Primary_Product__c = true,Geography__c = objGeography1.Id));
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20));
        result = (String)ManageLineItemController.saveOpportunityProducts(oppRec1.Id, lstOpportunityLineItem, currencyCode, true).data;
        Debug.Log('Result---'+result);
        oppRec2 = [SELECT Id, Building__c FROM Opportunity WHERE Id =: oppRec1.Id];
        System.assertEquals(objGeography1.Nearest_Building__c, oppRec2.Building__c);
        try{
            result = (String)ManageLineItemController.saveOpportunityProducts(null, null, null, null).data;
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    /************************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method tests saveOpportunityProducts when primary product has no building and no geography present.
        Created Date        : 17 July 2018 
    **************************************************************************************************************************************/
    public static testMethod void verifySaveOpportunityProductsNullCondition(){
      //When Opportunity and Primary product's Building are not equal.
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        String currencyCode = 'USD';
        Account accRec = [SELECT Id FROM Account][0];
        Contact contactRec = [SELECT Id FROM Contact][0];
        lstBuildings = [SELECT Id FROM Building__c];
        Building__c building1 =lstBuildings[0];
        Building__c building2 =lstBuildings[1];
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec1.Primary_Member__c = contactRec.Id;
        oppRec1.StageName = 'Closing';
        oppRec1.CurrencyIsoCode = 'USD';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.Building__c = building1.Id;
        insert oppRec1;
        System.assertNotEquals(null, oppRec1.Id);
        
        PricebookEntry standardPrice1 = [SELECT Id FROM PricebookEntry][0];
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20));
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20,Family__c = 'Wework',Is_Primary_Product__c = true));
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id,OpportunityId = oppRec1.Id,UnitPrice = 10,Quantity = 20));
        
        String result = (String)ManageLineItemController.saveOpportunityProducts(oppRec1.Id, lstOpportunityLineItem, currencyCode, false).data;
        Debug.Log('Result---'+result);
        Opportunity oppRec2 = [SELECT Id, Building__c,Geography__c FROM Opportunity WHERE Id =: oppRec1.Id];
        System.assertEquals(null, oppRec2.Building__c);
        System.assertEquals(null, oppRec2.Geography__c);
    }
    /************************************************************************************************************************************
        Author                : Chandra Teja
        Description           : This method tests the Currency change on Opportunity.
        Created Date          : 17 November 2018 
    **************************************************************************************************************************************/
    public static testMethod void verifyMapProductsOnCurrencyChange(){
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        String currencyCode = 'INR';
        String result = '';
        Account accRec = [SELECT Id FROM Account][0];
        Contact contactRec = [SELECT Id FROM Contact WHERE AccountId = :accRec.Id][0];
        Product2 productRec = [SELECT Id FROM Product2][0];
        lstBuildings = [SELECT Id FROM Building__c];
        Building__c building1 = lstBuildings[0];
        Building__c building2 = lstBuildings[1];
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec1.Primary_Member__c = contactRec.Id;
        oppRec1.StageName = 'Closing';
        oppRec1.CurrencyIsoCode = 'USD';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.Building__c = building1.Id;
        lstOpportunity.add(oppRec1);

        Opportunity oppRec2 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec2.Primary_Member__c = contactRec.Id;
        oppRec2.StageName = 'Selling';
        oppRec2.CurrencyIsoCode = 'USD';
        oppRec2.CloseDate = system.today().addDays(3);
        oppRec2.Building__c = building2.Id;
        lstOpportunity.add(oppRec2);
        TestingUtility.insertListWithAssert(lstOpportunity);
        
        PricebookEntry standardPrice1 = [SELECT Id FROM PricebookEntry][0];
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id, OpportunityId = lstOpportunity[0].Id, UnitPrice = 10, Quantity = 20, Family__c = 'Wework', Is_Primary_Product__c = true, Product2Id = productRec.Id));
        result = (String)ManageLineItemController.saveOpportunityProducts(oppRec1.Id, lstOpportunityLineItem, currencyCode, false).data;
        List<Opportunity> lstOppRec = [SELECT Id, Building__c, Geography__c, CurrencyIsoCode FROM Opportunity WHERE Id IN :lstOpportunity];
        System.assertEquals(currencyCode, lstOppRec[0].CurrencyIsoCode);
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id, OpportunityId = lstOpportunity[1].Id, UnitPrice = 10, Quantity = 20));
        lstOpportunityLineItem.add(new OpportunityLineItem(PricebookEntryId = standardPrice1.Id, OpportunityId = lstOpportunity[1].Id, UnitPrice = 10, Quantity = 20));
        result = (String)ManageLineItemController.saveOpportunityProducts(oppRec1.Id, lstOpportunityLineItem, currencyCode, true).data;
        lstOppRec = [SELECT Id, Building__c, Geography__c, CurrencyIsoCode FROM Opportunity WHERE Id IN :lstOpportunity];
        System.assertEquals(lstOpportunity[1].CurrencyIsoCode, lstOppRec[1].CurrencyIsoCode);
    }
    /************************************************************************************************************************************
        Author                : Chandra Teja
        Description           : This method tests sending data from serverside to clientside.
        Created Date          : 28 November 2018 
    **************************************************************************************************************************************/
    public static testMethod void verifyGetQueryResultForLabel(){
        Map<string, Object> filters = new Map<string, Object>();
        filters.put('CurrencyIsoCode', 'USD');
        DatabaseResult result3 = ManageLineItemController.getQueryResultForLabel('PriceBookEntry', filters);
        system.assertNotEquals(null, result3);
        filters.clear();
        filters.put('Name', 'AMS');
        DatabaseResult result4 = ManageLineItemController.getQueryResultForLabel('Building', filters);
        system.assertNotEquals(null, result4);
    }
}