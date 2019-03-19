/***********************************************************************************************************************
    Author 		: Ajaysinh Chauhan
    Description : ---
    History		: --

----------------------------------------------------------------------------------------------------------------------------------
	VERSION					DATE					AUTHOR							DETAIL
	1						--		                Ajaysinh Chauhan	            Initial Developement
****************************************************************************************************************************/

@isTest
public class BuildingTriggerHandlerTests {
/****************************************************************************************************************************
		Author 				: Ajaysinh Chauhan
        Description 		: This method used to verify Teritory Structure.
        Created Date		: --
        Last Modified Date	: 02 Feb, 2018
        Last Modified By	: Prashant Mane
****************************************************************************************************************************/
    public static testMethod void verifySetTerritoryStructure(){
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        Map<String, Object> mapRegionSalesManager = new Map<String, Object>();
        mapRegionSalesManager.put('LastName', 'TestRegionSalesManager');
        mapRegionSalesManager.put('Username', 'TestRegionSalesManager@weworkexample.com');
        mapRegionSalesManager.put('Email', 'testregionsalesmanager@weworkexample.com');
        User RegionSalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapRegionSalesManager, true);
        
        Map<String, Object> mapTerritorySalesManager = new Map<String, Object>();
        mapTerritorySalesManager.put('LastName', 'TestTerritorySalesManager');
        mapTerritorySalesManager.put('Username', 'TestTerritorySalesManager@weworkexample.com');
        mapTerritorySalesManager.put('Email', 'testterritorysalesmanager@weworkexample.com');
        User TerritorySalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTerritorySalesManager, true);
        
        Map<String, Object> mapPortfolioSalesManager = new Map<String, Object>();
        mapPortfolioSalesManager.put('LastName', 'TestPortfolioSalesManager');
        mapPortfolioSalesManager.put('Username', 'TestPortfolioSalesManager@weworkexample.com');
        mapPortfolioSalesManager.put('Email', 'testportfoliosalesmanager@weworkexample.com');
        User PortfolioSalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapPortfolioSalesManager, true);
        
        Map<String, Object> mapClusterSalesManager = new Map<String, Object>();
        mapClusterSalesManager.put('LastName', 'TestClusterSalesManager');
        mapClusterSalesManager.put('Username', 'TestClusterSalesManager@weworkexample.com');
        mapClusterSalesManager.put('Email', 'testclustersalesmanager@weworkexample.com');
        User ClusterSalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapClusterSalesManager, true);
        
        Map<String, Object> mapClusterSalesLead = new Map<String, Object>();
        mapClusterSalesLead.put('LastName', 'TestClusterSalesLead');
        mapClusterSalesLead.put('Username', 'TestClusterSalesLead@weworkexample.com');
        mapClusterSalesLead.put('Email', 'testclustersaleslead@weworkexample.com');
        User ClusterSalesLead = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapClusterSalesLead, true);
        
        Map<String, Object> mapCommunityManager = new Map<String, Object>();
        mapCommunityManager.put('LastName', 'TestCommunityManager');
        mapCommunityManager.put('Username', 'TestCommunityManager@weworkexample.com');
        mapCommunityManager.put('Email', 'testcommunitymanager@weworkexample.com');
        User CommunityManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapCommunityManager, true);
      
        Map<String, Object> mapCommunityLead = new Map<String, Object>();
        mapCommunityLead.put('LastName', 'TestCommunityLead');
        mapCommunityLead.put('Username', 'TestCommunityLead@weworkexample.com');
        mapCommunityLead.put('Email', 'testcommunitylead@weworkexample.com');
        User CommunityLead = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapCommunityLead, true);
       
        Region__c objRegion = new Region__c(Name = 'Test Region', Region__c = 'Test Region', Regional_Sales_Manager__c = RegionSalesManager.Id);
        TestingUtility.insertWithAssert(objRegion, 'Region not inserted');
            
        Territory__c objTerritory = new Territory__c(Name = 'Test Territory', Territory__c =' Test Territory', RegionID__c = objRegion.Id, Territory_Sales_Manager__c = TerritorySalesManager.Id);
        TestingUtility.insertWithAssert(objTerritory, 'Territory not inserted');
            
        Market__c objMarket = new Market__c(Name = 'Test Portfolio', Portfolio__c = 'Test Portfolio', TerritoryId__c = objTerritory.Id, Portfolio_Sales_Manager__c = PortfolioSalesManager.Id);
        TestingUtility.insertWithAssert(objMarket, 'Portfolio not inserted');
    
        Cluster__c objCluster = new Cluster__c(Name = 'Test Cluster', Cluster_Sales_Manager__c = ClusterSalesManager.Id, Sales_Lead__c = ClusterSalesLead.Id);
        TestingUtility.insertWithAssert(objCluster,'Cluster not inserted');
        
        List<Building__C> lstBuilding =new List<Building__C>();
        lstBuilding.addAll(TestingUtility.createBuildings(new Map<String,Object>{'Cluster__c' => objCluster.Id}, 9));
        lstBuilding.addAll(TestingUtility.createBuildings(new Map<String,Object>{'Market__c' => objMarket.Id}, 9));
        lstBuilding.addAll(TestingUtility.createBuildings(new Map<String,Object>{'Community_Lead__c' => CommunityLead.Id}, 1));
        lstBuilding.addAll(TestingUtility.createBuildings(new Map<String,Object>{'Responsible_CM__c' => CommunityManager.Id}, 1));
        
        TestingUtility.insertListWithAssert(lstBuilding);
        
        List<Building__c> lstInsertedBuilding =   [SELECT Id,Name,
                   Cluster_Name__c,
                   Portfolio_Name__c,
                   Territory_Name__c,
                   Region_Name__c,
                   Cluster_Sales_Manager_Name__c,
                   Cluster_Sales_Lead_Name__c,
                   Portfolio_Sales_Manager_Name__c,
                   Territory_Sales_Manager_Name__c,
                   Regional_Sales_Manager_Name__c, 
                   Cluster_Sales_Manager_Email__c,
                   Cluster_Sales_Lead_Email__c,
                   Portfolio_Sales_Manager_Email__c,
                   Territory_Sales_Manager_Email__c,
                   Regional_Sales_Manager_Email__c,
                   Community_Lead__c,
                   Responsible_CM__c,
                   Community_Lead__r.Name,
                   Responsible_CM__r.Name FROM Building__c ORDER BY createdDate];
        
        system.assertEquals(20, lstInsertedBuilding.size(),'Building Not Inserted Properly');
        
        for(Integer Index = 0; Index < lstInsertedBuilding.size(); Index++){
            if(Index <= 8){
                System.assertEquals('Test Cluster', lstInsertedBuilding[Index].Cluster_Name__c, 'Cluster Name not Populated');
                System.assertEquals('TestClusterSalesManager', lstInsertedBuilding[Index].Cluster_Sales_Manager_Name__c, 'Cluster Sales Manager Name not Populated');
                System.assertEquals('TestClusterSalesLead', lstInsertedBuilding[Index].Cluster_Sales_Lead_Name__c, 'Cluster Sales Lead Name not Populated');
                System.assertEquals('testclustersalesmanager@weworkexample.com', lstInsertedBuilding[Index].Cluster_Sales_Manager_Email__c, 'Cluster Sales Manager Email not Populated');
                System.assertEquals('testclustersaleslead@weworkexample.com', lstInsertedBuilding[Index].Cluster_Sales_Lead_Email__c, 'Cluster Sales Lead Email not Populated');
            }else if(Index <= 17){
                System.assertEquals('Test Portfolio', lstInsertedBuilding[Index].Portfolio_Name__c, 'Portfolio Name not Populated');
                System.assertEquals('Test Territory', lstInsertedBuilding[Index].Territory_Name__c, 'Territory Name not Populated');
                System.assertEquals('Test Region', lstInsertedBuilding[Index].Region_Name__c, 'Region Name not Populated');
                System.assertEquals('TestPortfolioSalesManager', lstInsertedBuilding[Index].Portfolio_Sales_Manager_Name__c, 'Portfolio Sales Manager Name not Populated');
                System.assertEquals('TestTerritorySalesManager', lstInsertedBuilding[Index].Territory_Sales_Manager_Name__c, 'Territory Sales Manager Name not Populated');
                System.assertEquals('TestRegionSalesManager', lstInsertedBuilding[Index].Regional_Sales_Manager_Name__c, 'Region Sales Manager Name not Populated');
                System.assertEquals('testportfoliosalesmanager@weworkexample.com', lstInsertedBuilding[Index].Portfolio_Sales_Manager_Email__c, 'Portfolio Sales Manager Email not Populated');
                System.assertEquals('testterritorysalesmanager@weworkexample.com', lstInsertedBuilding[Index].Territory_Sales_Manager_Email__c, 'Territory Sales Manager Email not Populated');
                System.assertEquals('testregionsalesmanager@weworkexample.com', lstInsertedBuilding[Index].Regional_Sales_Manager_Email__c, 'Region Sales Manager Email not Populated');
            }else if(Index == 18){
                System.assertEquals('TestCommunityLead', lstInsertedBuilding[Index].Community_Lead__r.Name, 'Community Lead Name Not Populated');
            }else if(Index == 19){
                System.assertEquals('TestCommunityManager', lstInsertedBuilding[Index].Responsible_CM__r.Name,'Community Manager Name Not Populated');
            }
        }
    }
    
/*************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method is used to test manageBuildingRelatedGeographies.
        Created Date        : 14 May, 2018
		Issue No			: ST-2267
****************************************************************************************************/
    public static testMethod void testManageBuildingRelatedGeographies(){
        SalesConsoleSettings.createSettings();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueInsertGeoForBuildingMockRes());
        Building__c objBuilding = new Building__c(City__c = 'Frankfurt', Country__c = 'Germany',Name = 'HE-Goetheplatz', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam');
        TestingUtility.insertWithAssert(objBuilding);
        insert new Building__c();
        Test.stopTest();
    }
}