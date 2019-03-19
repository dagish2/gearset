/************************************************************************************************************************************
   	Author 		: Milanjeet
   	Description : This class Contains Unit Tests of Portfolio Triggers Handler

   	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE			AUTHOR				DETAIL
	1			9 Nov 2017		Milanjeet 			Initial Developement
**************************************************************************************************************************************/
@isTest
public class PortfolioTriggersHandlerTests {
    /************************************************************************************************************************************
    	Author 				: Milanjeet
        Description 		: This method verifies for updation of portfolio info on building
        Last Modified Date	: 9 Nov 2017
        Last Modified By	: Milanjeet
        Issue No 			: ---
	**************************************************************************************************************************************/
    public static testmethod void testUpdatePortfolioInfoOnBuilding(){
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='Wework System Administrator'];
        
        Map<String,Object> mapPortfolioSalesManager1 = new Map<String,Object>();
        mapPortfolioSalesManager1.put('LastName','TestPortfolioSalesManager1');
        mapPortfolioSalesManager1.put('Username','TestPortfolioSalesManager1@weworkexample.com');
        mapPortfolioSalesManager1.put('Email','TestPortfolioSalesManager1@weworkexample.com');
        User PortfolioSalesManager1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapPortfolioSalesManager1, true);
        
        Map<String,Object> mapPortfolioSalesManager2 = new Map<String,Object>();
        mapPortfolioSalesManager2.put('LastName','TestPortfolioSalesManager2');
        mapPortfolioSalesManager2.put('Username','TestPortfolioSalesManager2@weworkexample.com');
        mapPortfolioSalesManager2.put('Email','TestPortfolioSalesManager2@weworkexample.com');
        User PortfolioSalesManager2 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapPortfolioSalesManager2, true);
        
        Map<String,Object> mapTerritorySalesManager1 = new Map<String,Object>();
        mapTerritorySalesManager1.put('LastName','TestTerritorySalesManager1');
        mapTerritorySalesManager1.put('Username','TestTerritorySalesManager1@weworkexample.com');
        mapTerritorySalesManager1.put('Email','TestTerritorySalesManager1@weworkexample.com');
        User TerritorySalesManager1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTerritorySalesManager1, true);
        
        Map<String,Object> mapTerritorySalesManager2 = new Map<String,Object>();
        mapTerritorySalesManager2.put('LastName','TestTerritorySalesManager2');
        mapTerritorySalesManager2.put('Username','TestTerritorySalesManager2@weworkexample.com');
        mapTerritorySalesManager2.put('Email','TestTerritorySalesManager2@weworkexample.com');
        User TerritorySalesManager2 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTerritorySalesManager2, true);
        
        //Scanerio 1 on Assign Portfolio to the building, the Portfolio info, and Portfolio's Territory Info should be populated on its building
        Territory__c territory1 = new Territory__c();
        territory1.Name = 'Test Territory 1';
        territory1.Territory__c = 'Test Terriotory 1';
        territory1.Territory_Sales_Manager__c = TerritorySalesManager1.Id;
        insert territory1;
        System.assert(territory1.Id!=null, 'Territory Not Inserted');
        
        Territory__c territory2 = new Territory__c();
        territory2.Name = 'Test Territory 2';
        territory2.Territory__c = 'Test Territory 2';
        territory2.Territory_Sales_Manager__c = TerritorySalesManager2.Id;
        insert territory2;
        System.assert(territory2.Id!=null, 'Territory Not Inserted');
        
        Market__c portfolio = new Market__c();
        portfolio.Name = 'Test Portfolio';
        portfolio.Portfolio__c = 'Test Portfolio';
        portfolio.Portfolio_Sales_Manager__c = PortfolioSalesManager1.Id;
        portfolio.TerritoryID__c = territory1.Id;
        insert portfolio;
        System.assert(portfolio.Id!=null, 'Portfolio Not Inserted');
        
        Building__c bldng = new Building__c(Name='Test Building',Market__c=portfolio.Id);
        insert bldng;
        System.assert(bldng.Id!=null, 'Building not inserted');
        
        bldng = [Select Id,Market__c,Portfolio_Name__c,Portfolio_Sales_Manager_Name__c,Territory_Name__c,Territory_Sales_Manager_Name__c from Building__c Where Id=:bldng.Id];
        portfolio = [Select Id,Name,Portfolio__c,Portfolio_Sales_Manager__r.Name,Territory__c,TerritoryID__r.Territory__c,TerritoryID__r.Territory_Sales_Manager__r.Name from Market__c Where Id=:portfolio.Id];
        
        System.assertEquals(portfolio.Name, bldng.Portfolio_Name__c, 'Portfolio Name Not Updated on Building');
        System.assertEquals(portfolio.Portfolio_Sales_Manager__r.Name, bldng.Portfolio_Sales_Manager_Name__c, 'Portfolio sales Manager Name Not Updated in Building');
        System.assertEquals(portfolio.Territory__c,bldng.Territory_Name__c , 'Territory Name not Updated on Building');
        System.assertEquals(portfolio.TerritoryID__r.Territory_Sales_Manager__r.Name, bldng.Territory_Sales_Manager_Name__c, ' Territory Sales manager Name Not Updated on Building');
        
        //Scanerio 2 on update on Portfolio the Portfolio info, and Portfolio's Territory Info should be updated on its building
        //Updating Portfolio info, It should be updated on builing also
        portfolio.Portfolio__c = 'Test Portfolio Updated';
        portfolio.Portfolio_Sales_Manager__c = PortfolioSalesManager2.Id;
        portfolio.TerritoryID__c = territory2.Id;
        update portfolio;
        
        bldng = [Select Id,Market__c,Portfolio_Name__c,Portfolio_Sales_Manager_Name__c,Territory_Name__c,Territory_Sales_Manager_Name__c from Building__c Where Id=:bldng.Id];
        portfolio = [Select Id,Name,Portfolio__c,Portfolio_Sales_Manager__r.Name,Territory__c,TerritoryID__r.Territory__c,TerritoryID__r.Territory_Sales_Manager__r.Name from Market__c Where Id=:portfolio.Id];
        
        System.assertEquals(portfolio.Portfolio__c, bldng.Portfolio_Name__c, 'Portfolio Name Not Updated on Building');
        System.assertEquals(portfolio.Portfolio_Sales_Manager__r.Name, bldng.Portfolio_Sales_Manager_Name__c, 'Portfolio sales Manager Name Not Updated in Building');
        System.assertEquals(portfolio.Territory__c,bldng.Territory_Name__c , 'Territory Name not Updated on Building');
        System.assertEquals(portfolio.TerritoryID__r.Territory_Sales_Manager__r.Name, bldng.Territory_Sales_Manager_Name__c, 'Territory Sales manager Name Not Updated on Building');
    }
}