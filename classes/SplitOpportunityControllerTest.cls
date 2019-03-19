/************************************************************************************************************************************
    Author      :   Pragalbha Mahajan    
    Description :   This class contain test methods for split opportunity controller.
    
    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           17 July 2018        Pragalbha Mahajan       Initial Developement
**************************************************************************************************************************************/

@isTest
public class SplitOpportunityControllerTest {
    public static List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
    public static List<Opportunity> lstOppToInsert = new List<Opportunity>();
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
       
        Profile systemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        debug.Log('systemAdmin' + systemAdmin);
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];
        debug.Log('weworkSystemAdmin' + weworkSystemAdmin);
        
        List<Product2> lstProducts = new List<Product2>();
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
       
         List<User> lstusers = new List<User>();
        User user1 = new User();
        user1.LastName = 'Last Name 1';
        user1.Username = 'testwework111017_1@example.com';
        user1.Email = 'testwework1@example.com';
        user1.ProfileId = systemAdmin.Id;
        user1.EmailEncodingKey = 'ISO-8859-1';
        user1.LanguageLocaleKey = 'en_US';
        user1.LocaleSidKey = 'en_US';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.Alias = 'Name 1';
        user1.IsActive = true;
        lstusers.add(user1);
        
        User user2 = new User();
        user2.LastName = 'Last Name 2';
        user2.Username = 'testwework05052018@example.com';
        user2.Email = 'testwework05052018@example.com';
        user2.ProfileId = weworkSystemAdmin.Id;
        user2.EmailEncodingKey = 'ISO-8859-1';
        user2.LanguageLocaleKey = 'en_US';
        user2.LocaleSidKey = 'en_US';
        user2.TimeZoneSidKey = 'America/Los_Angeles';
        user2.Alias = 'Name 1';
        user2.IsActive = true;
        lstusers.add(user2);
        TestingUtility.insertListWithAssert(lstusers);
       
        Account accRec = new Account(Name = 'strAccountName1',Number_of_Full_Time_Employees__c=1000 );
        insert accRec;
        System.assertNotEquals(null, accRec.Id);
        
        Account accRec2 = new Account(Name = 'strAccountName2',Number_of_Full_Time_Employees__c=1000, OwnerId = user1.Id);
        insert accRec2;
        System.assertNotEquals(null, accRec2.Id);
        
        
        Contact contactRec = new Contact(FirstName = 'John', LastName = 'Smith', Email = 'testContact1@example.com', AccountID = accRec.Id, Status__c = 'active');
        insert contactRec;
        System.assertNotEquals(null,contactRec.Id);   
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec1.Primary_Member__c = contactRec.Id;
        oppRec1.StageName = 'Closing';
        oppRec1.CurrencyIsoCode = 'USD';
        oppRec1.CloseDate = system.today().addDays(5); 
        lstOppToInsert.add(oppRec1);
        
        Opportunity oppRec2 = TestingUtility.createOpportunity(accRec2.Id, false);
        oppRec2.Primary_Member__c = contactRec.Id;
        oppRec2.StageName = 'Closing';
        oppRec2.CurrencyIsoCode = 'USD';
        oppRec2.CloseDate = system.today().addDays(5); 
        oppRec2.OwnerId = user1.Id;
        lstOppToInsert.add(oppRec2);
        
        TestingUtility.insertListWithAssert(lstOppToInsert);
        //insert oppRec1;
        //System.assertNotEquals(null, oppRec1.Id);
        Product2 prod = new Product2(
            Name = 'Deal',
            ProductCode = 'PRDL-000001',
            Default_Product_Category__c='Custom Office',
            IsActive = true);
        lstProducts.add(prod);
        Product2 prod1 = new Product2(
            Name = 'Hot Desk',
            ProductCode = 'PRHD-000400',
            Default_Product_Category__c='Custom Office',
            IsActive = true);
        lstProducts.add(prod1);
        Product2 prod2 = new Product2(
            Name = 'Desk',
            ProductCode = 'PRDE-000200',
            Default_Product_Category__c='Custom Office',
            IsActive = true);
        lstProducts.add(prod2);
        Product2 prod3 = new Product2(
            Name = 'DedicatedDesk',
            ProductCode = 'NotConsidered',
            Default_Product_Category__c='Custom Office',
            IsActive = true);
        lstProducts.add(prod3);
        TestingUtility.insertListWithAssert(lstProducts);
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        //Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        
        PricebookEntry standardPrice1 = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod1.Id,
            UnitPrice = 10000, 
            IsActive = true,
            CurrencyIsoCode = 'USD' );
        lstPricebookEntry.add(standardPrice1);
        TestingUtility.insertListWithAssert(lstPricebookEntry);
        OpportunityLineItem objOpportunityLineItem1 = new OpportunityLineItem();
        objOpportunityLineItem1.PricebookEntryId = standardPrice1.Id;
        objOpportunityLineItem1.OpportunityId = oppRec1.Id;
        objOpportunityLineItem1.UnitPrice = 10;
        objOpportunityLineItem1.Quantity = 20; 
        lstOpportunityLineItem.add(objOpportunityLineItem1);
        
        OpportunityLineItem objOpportunityLineItem2 = new OpportunityLineItem();
        objOpportunityLineItem2.PricebookEntryId = standardPrice1.Id;
        objOpportunityLineItem2.OpportunityId = oppRec1.Id;
        objOpportunityLineItem2.UnitPrice = 10;
        objOpportunityLineItem2.Quantity = 20; 
        lstOpportunityLineItem.add(objOpportunityLineItem2);
        
        OpportunityLineItem objOpportunityLineItem3 = new OpportunityLineItem();
        objOpportunityLineItem3.PricebookEntryId = standardPrice1.Id;
        objOpportunityLineItem3.OpportunityId = oppRec1.Id;
        objOpportunityLineItem3.UnitPrice = 10;
        objOpportunityLineItem3.Quantity = 20; 
        lstOpportunityLineItem.add(objOpportunityLineItem3);  
        Test.startTest();
        TestingUtility.insertListWithAssert(lstOpportunityLineItem);
    }    

    /************************************************************************************************************************************
        Author              :   Priyanka Ambre
        Description         :   This method is used to test splitOpportunity().
        Issue No.           :   ST-2043
        Last Modified Date  :   17 July 2018
        Last Modified By  	:   Pragalbha Mahajan
    **************************************************************************************************************************************/  
    public static testMethod void splitOpportunityTest(){
        List<Opportunity> lstOppInserted = [SELECT Id,Name,Primary_Member__c,StageName,CurrencyIsoCode,CloseDate FROM Opportunity];
        List<OpportunityLineItem> lstOLIInserted = [SELECT Id,Name,Geography__c,Building__c,PricebookEntryId,OpportunityId,UnitPrice,Quantity FROM OpportunityLineItem];
        String result = (String)SplitOpportunityController.splitOpportunity(lstOppInserted[0].Id, lstOLIInserted[0]).data;
        System.assertNotEquals(null, result); 
        Debug.log('result---'+result);
        Opportunity oppRecResult = Database.query('SELECT Id, Name, Account.Name, Old_Opportunity__c, Owner_Auto_Assign__c FROM Opportunity WHERE Id =\''+result+'\'');
        Debug.log('oppRecResult---'+oppRecResult);
        System.assertEquals(false, oppRecResult.Owner_Auto_Assign__c);
        System.assertEquals(lstOppInserted[0].Id, oppRecResult.Old_Opportunity__c);
        List<OpportunityLineItem> lstOppLineItemsOnOldOpp = [SELECT Id, Quantity, UnitPrice, TotalPrice, Description, PricebookEntry.Name, ListPrice, PricebookEntry.Product2.Family, Is_Primary_Product__c FROM OpportunityLineItem WHERE OpportunityId=:lstOppInserted[0].Id];
        List<OpportunityLineItem> lstOppLineItemsOnNewOpp = [SELECT Id, Quantity, UnitPrice, TotalPrice, Description, PricebookEntry.Name, ListPrice, PricebookEntry.Product2.Family ,Is_Primary_Product__c FROM OpportunityLineItem WHERE OpportunityId=:result];
        System.assertNotEquals(null, lstOppLineItemsOnNewOpp); 
        System.assertEquals(1, lstOppLineItemsOnNewOpp.size()); 
        System.assertEquals(true, lstOppLineItemsOnNewOpp[0].Is_Primary_Product__c); 
        System.assertEquals(2, lstOppLineItemsOnOldOpp.size());
        try{
            result = (String)SplitOpportunityController.splitOpportunity(null, null).data;
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    
     /************************************************************************************************************************************
        Author              :   Priyanka Ambre
        Description         :   This method tests getOppProductForSplit.
        Last Modified Date  :   17 July 2018
        Last Modified By  	:   Pragalbha Mahajan
    **************************************************************************************************************************************/  
    public static testMethod void getOppProductForSplitTest() {
       	List<Opportunity> lstOppInserted = [SELECT Id,Name,Primary_Member__c,StageName,CurrencyIsoCode,CloseDate,OwnerId FROM Opportunity];
        
        List<User> lstUserInserted = [SELECT Id,Username,LastName,Email,ProfileId,EmailEncodingKey FROM User WHERE Email =:'testwework05052018@example.com' OR Email =:'testwework1@example.com'];
       
        System.runAs(lstUserInserted[0]){//true
            String result  = (String)SplitOpportunityController.getOppProductForSplit(lstOppInserted[1].Id).data;
            Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(result);
            Debug.log('mapResult---'+mapResult);
            System.assertEquals('true', String.valueOf(mapResult.get('isValidForSplit')));
            System.assertNotEquals(null, mapResult.get('oppRec'));
         }
        lstOppInserted[1].OwnerId = lstUserInserted[1].Id;
        update lstOppInserted[1];
        System.runAs(lstUserInserted[1]){//true
            String result  = (String)SplitOpportunityController.getOppProductForSplit(lstOppInserted[1].Id).data;
            Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(result);
            Debug.log('mapResult---'+mapResult);
            System.assertEquals('true', String.valueOf(mapResult.get('isValidForSplit')));
            System.assertNotEquals(null, mapResult.get('oppRec'));
            Debug.log('mapResult---' + mapResult);
        } 
        lstOppInserted[1].OwnerId = lstUserInserted[0].Id;
        update lstOppInserted[1];
        for(Opportunity opp: [SELECT Id, OwnerId FROM Opportunity]){
            if(opp.Id == lstOppInserted[1].Id){
                System.assertEquals(lstUserInserted[0].Id, opp.OwnerId);
            }
        }        
        System.runAs(lstUserInserted[1]){//false
            String result  = (String)SplitOpportunityController.getOppProductForSplit(lstOppInserted[1].Id).data;
            Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(result);
            Debug.log('mapResult---'+mapResult); 
            System.assertEquals('false', String.valueOf(mapResult.get('isValidForSplit')));
            System.assertNotEquals(null, mapResult.get('oppRec'));
            Debug.log('mapResult---' + mapResult);
        } 
     }
}