/************************************************************************************************************************************
	Author			:	Ajaysinh Chauhan
	Description 	:	This class is used to test TerritoryTriggersHandler

	History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        		AUTHOR                       DETAIL
	1	    	04 December 2017		Ajaysinh Chauhan             Initial Developement
**************************************************************************************************************************************/
@isTest
public class TerritoryTriggersHandlerTests {
    /************************************************************************************************************************************
        Author				:	Ajaysinh Chauhan
        Description 		:	This method is used to test TerritoryInfo On Building
        Last Modified Date  :	04 December 2017
        Last Modified By	:	Ajaysinh Chauhan
    **************************************************************************************************************************************/        
    public static testmethod void testUpdateTerritoryInfoOnBuilding(){
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='Wework System Administrator'];
        
        Map<String,Object> mapPortfolioSalesManager1 = new Map<String,Object>();
       	mapPortfolioSalesManager1.put('LastName','TestPortfolioSalesManager1');
        mapPortfolioSalesManager1.put('Username','TestPortfolioSalesManager1@weworkexample.com');
        mapPortfolioSalesManager1.put('Email','TestPortfolioSalesManager1@weworkexample.com');
        User PortfolioSalesManager1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapPortfolioSalesManager1, true);
                
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
        
        Map<string , Object> mapRegionalSalesManager1 = new Map <String, object>();
        mapRegionalSalesManager1.put('LastName', 'testRegionalSalesManager1');
        mapRegionalSalesManager1.put('UserName', 'testRegionalSalesmManager1@exampale.com');  
        mapRegionalSalesManager1.put('Email','testRegionalSalesmManager1@exampale.com');
        User RegionalSalesManager1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapRegionalSalesManager1, true); 
        
        Map<string , Object> mapRegionalSalesManager2 = new Map <String, object>();
        mapRegionalSalesManager2.put('LastName', 'testRegionalSalesManager2');
        mapRegionalSalesManager2.put('UserName', 'testRegionalSalesmManager2@exampale.com');  
        mapRegionalSalesManager2.put('Email','testRegionalSalesmManager2@exampale.com');
        User RegionalSalesManager2 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapRegionalSalesManager2, true); 
        //Scanerio 1 on Assign Portfolio to the building, the Portfolio info, and Portfolio's Territory Info should be populated on its building
        
        Region__c region1 = new Region__c(Name='Test Region 1',Region__c='Test Region 1',Regional_Sales_Manager__c=RegionalSalesManager1.Id);
        insert region1;
        System.assert(region1.Id!=null, 'Region 1 Not Inserted');
        
        Region__c region2 = new Region__c(Name='Test Region 1',Region__c='Test Region 1',Regional_Sales_Manager__c=RegionalSalesManager1.Id);
        insert region2;
        System.assert(region2.Id!=null, 'Region 2 Not Inserted');
        
        Territory__c territory1 = new Territory__c();
        territory1.Name = 'Test Territory 1';
        territory1.Territory__c = 'Test Terriotory 1';
        territory1.Territory_Sales_Manager__c = TerritorySalesManager1.Id;
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
        
        //Scanerio 1 : On Insert of bulding all the Territory Info should be populted on building
        //[Select Id,Market__r.TerritoryId__r.Territory__c,Market__r.TerritoryId__r.Territory_Sales_Manager__r.Name,Market__r.TerritoryId__r.RegionId__r.Region__c,Market__r.TerritoryId__r.RegionId__r.Regional_Sales_Manager__r.Name From Building__c Where Market__r.TerritoryId__c IN:setTerritoryIds]
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
        
        //scanerio 2 : if Territory Name OR Territory's Sales Manager OR Region changes on Terriotory, updated info must be updated on building also
        territory1.Territory__c = 'Test Territory Updated';
        territory1.Territory_Sales_Manager__c = TerritorySalesManager2.Id;
        territory1.RegionID__c = region2.Id;
        update territory1;
        
        bldng = [Select Id,Territory_Name__c,Territory_Sales_Manager_Name__c,Region_Name__c,Regional_Sales_Manager_Name__c from Building__c Where Id=:bldng.Id];
        region2 = [Select Name,Region__c,Regional_Sales_Manager__r.Name from Region__c where Id=:region2.Id];
        territory1 = [Select Name,Territory__c,Territory_Sales_Manager__r.Name from Territory__c Where Id=:territory1.Id];
        System.assertEquals(region2.Region__c, bldng.Region_Name__c, 'Region Not Updated on building');
        System.assertEquals(region2.Regional_Sales_Manager__r.Name, bldng.Regional_Sales_Manager_Name__c, 'Regional Sales Manager Name not updated on building');
        System.assertEquals(territory1.Territory__c, bldng.Territory_Name__c, 'Territory Name not updated on the building');
        System.assertEquals(territory1.Territory_Sales_Manager__r.Name, bldng.Territory_Sales_Manager_Name__c, 'Territory Sales Manager Not updated on the building');
    }
}