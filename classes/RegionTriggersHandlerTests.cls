/************************************************************************************************************************************
   	Author 		: Sunil Bhosale
   	Description : This class Contains Unit Tests of RegionTriggersHandler

   	History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR				DETAIL
	1			10 November 17		Sunil Bhosale 		Initial Developement
**************************************************************************************************************************************/

@isTest
public class RegionTriggersHandlerTests { 
    /************************************************************************************************************************************
    	Author 				: Sunil Bhosale
        Description 		: This method verifies for update region info on building
        Last Modified Date	: 10 November 17
        Last Modified By	: Sunil Bhosale
	**************************************************************************************************************************************/
    public static testmethod void testUpdateRegionInfoOnBuilding(){    
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='Wework System Administrator'];
        Map<string , Object> mapRegionalSalesManager1 = new Map <String, object>();
        mapRegionalSalesManager1.put('LastName', 'test_RegionalSalesManager1');
        mapRegionalSalesManager1.put('UserName', 'test_RegionalSalesmManage1@exampale.com');  
        mapRegionalSalesManager1.put('Email','test_RegionalSalesmManage1@exampale.com');
        User RegionalSalesManager1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapRegionalSalesManager1, true);
        
        Map<string , Object> mapRegionalSalesManager2 = new Map <String, object>();
        mapRegionalSalesManager2.put('LastName', 'test_RegionalSalesManager1');
        mapRegionalSalesManager2.put('UserName', 'test_RegionalSalesManager1@exampale.com');  
        mapRegionalSalesManager2.put('Email','test_RegionalSalesManager1@exampale.com');
        User RegionalSalesManager2 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapRegionalSalesManager2, true);
        
        Map<string,Object> mapTerritorySalesManager1 = new Map<String,Object>();
        mapTerritorySalesManager1.put('LastName', 'test_TerritorySalesManager1');
        mapTerritorySalesManager1.put('UserName', 'test_TerritorySalesManager1@exampale.com');
        mapTerritorySalesManager1.put('Email', 'test_TerritorySalesManager1@exampale.com');
        User testTerritorySalesManager1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTerritorySalesManager1, true);  
        
        Map<String,Object> mapPortfolioSalesManager1 = new Map<String,Object>();
        mapPortfolioSalesManager1.put('LastName','Test_PortfolioSalesManager1');
        mapPortfolioSalesManager1.put('Username','Test_PortfolioSalesManager1@weworkexample.com');
        mapPortfolioSalesManager1.put('Email','Test_PortfolioSalesManager1@weworkexample.com');
        User PortfolioSalesManager1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapPortfolioSalesManager1, true);
        
        Region__c region1 = new Region__c(Name='Test Region 1',Region__c='Test Region 1',Regional_Sales_Manager__c=RegionalSalesManager1.Id);
        insert region1;
        System.assert(region1.Id!=null, 'Region 1 Not Inserted');
        
        Territory__c territory1 = new Territory__c();
        territory1.Name = 'Test Territory 1';
        territory1.Territory__c = 'Test Terriotory 1';
        territory1.Territory_Sales_Manager__c = testTerritorySalesManager1.Id;
        territory1.RegionID__c = region1.Id;
        insert territory1;
        System.assert(territory1.Id!=null, 'Territory Not Inserted');
        
        Market__c portfolio = new Market__c();
        portfolio.Name = 'Test Portfolio';
        portfolio.Portfolio__c = 'Test Portfolio';
        portfolio.Portfolio_Sales_Manager__c = PortfolioSalesManager1.Id;
        portfolio.TerritoryID__c = territory1.Id;
        insert portfolio;
        
        Building__c bldng = new Building__c(Name='Test Building',Market__c=portfolio.Id);
        insert bldng;
        System.assert(bldng.Id!=null, 'Building not inserted');
        
        //Scanerio 1 : on insert building, all the information of region->territory->portfolio should be populated on the building
        bldng = [Select Id,Portfolio_Name__c,Portfolio_Sales_Manager_Name__c,Territory_Name__c,Territory_Sales_Manager_Name__c,Region_Name__c,Regional_Sales_Manager_Name__c from Building__c Where Id=:bldng.Id];
        region1 = [Select Name,Region__c,Regional_Sales_Manager__r.Name from Region__c where Id=:region1.Id];
        portfolio = [Select Name,Portfolio_Sales_Manager__r.Name from Market__c where Id=:portfolio.Id];
        territory1 = [Select Name,Territory__c,Territory_Sales_Manager__r.Name from Territory__c Where Id=:territory1.Id];
        
        System.assertEquals(portfolio.Name, bldng.Portfolio_Name__c, 'Portfolio Name Not Updated on Building');
        System.assertEquals(portfolio.Portfolio_Sales_Manager__r.Name, bldng.Portfolio_Sales_Manager_Name__c, 'Portfolio sales Manager Name Not Updated in Building');
        System.assertEquals(territory1.Territory__c,bldng.Territory_Name__c , 'Territory Name not Updated on Building');
        System.assertEquals(territory1.Territory_Sales_Manager__r.Name, bldng.Territory_Sales_Manager_Name__c, ' Territory Sales manager Name Not Updated on Building');
        System.assertEquals(region1.Region__c,bldng.Region_Name__c , 'Region Name not updated on building');
        System.assertEquals(region1.Regional_Sales_Manager__r.Name, bldng.Regional_Sales_Manager_Name__c, 'Regional Salesmanager Name not updated on Buiding');
        
        //Scanerio 2: If region's information changes, it must be updated to its all buildings
        region1.Region__c = 'Region Updated';
        region1.Regional_Sales_Manager__c = RegionalSalesManager2.Id;
        update region1;
        
        bldng = [Select Id,Region_Name__c,Regional_Sales_Manager_Name__c from Building__c Where Id=:bldng.Id];
        region1 = [Select Name,Region__c,Regional_Sales_Manager__r.Name from Region__c where Id=:region1.Id];
        
        System.assertEquals(region1.Region__c,bldng.Region_Name__c , 'Region Name not updated on building');
        System.assertEquals(region1.Regional_Sales_Manager__r.Name, bldng.Regional_Sales_Manager_Name__c, 'Regional Salesmanager Name not updated on Buiding');
    }
}