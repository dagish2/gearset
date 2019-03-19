/************************************************************************************************************************************
    Author      :   Jitesh Adwani    
    Description :   This class contain all methods that are used in TourCloseHourContoller
    
    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1          25-10-2018         	Jitesh Adwani        	Initial Developement
**************************************************************************************************************************************/
@isTest
public class TourCloseHourControllerTest {
    @testSetup 
    static void setup(){
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];	
        Profile weworkEnterpriseSolutions = [SELECT Id FROM Profile WHERE Name = 'WeWork Enterprise Solutions'];
        List<User> lstUsers = new List<User>();
        
        Map<String, Object> mapRegionSalesManager = new Map<String, Object>();
        mapRegionSalesManager.put('LastName', 'TestRegionSalesManager');
        mapRegionSalesManager.put('Username', 'TestRegionSalesManager' + DateTime.now().getTime() + '@weworkexample.com');
        mapRegionSalesManager.put('Email', 'testregionsalesmanager@weworkexample.com');
        User regionSalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapRegionSalesManager, true);
        
        Map<String, Object> mapTerritorySalesManager = new Map<String, Object>();
        mapTerritorySalesManager.put('LastName', 'TestTerritorySalesManager');
        mapTerritorySalesManager.put('Username', 'TestTerritorySalesManager' + DateTime.now().getTime() + '@weworkexample.com');
        mapTerritorySalesManager.put('Email', 'testterritorysalesmanager@weworkexample.com');
        User territorySalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTerritorySalesManager, true);
        
        Map<String, Object> mapPortfolioSalesManager = new Map<String, Object>();
        mapPortfolioSalesManager.put('LastName', 'TestPortfolioSalesManager');
        mapPortfolioSalesManager.put('Username', 'TestPortfolioSalesManager' + DateTime.now().getTime() + '@weworkexample.com');
        mapPortfolioSalesManager.put('Email', 'testportfoliosalesmanager@weworkexample.com');
        User portfolioSalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapPortfolioSalesManager, true);
        
        Map<String, Object> mapClusterSalesManager = new Map<String, Object>();
        mapClusterSalesManager.put('LastName', 'TestClusterSalesManager');
        mapClusterSalesManager.put('Username', 'TestClusterSalesManager' + DateTime.now().getTime() + '@weworkexample.com');
        mapClusterSalesManager.put('Email', 'testclustersalesmanager@weworkexample.com');
        User clusterSalesManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapClusterSalesManager, true);
        
        Map<String, Object> mapClusterSalesLead = new Map<String, Object>();
        mapClusterSalesLead.put('LastName', 'TestClusterSalesLead');
        mapClusterSalesLead.put('Username', 'TestClusterSalesLead' + DateTime.now().getTime() + '@weworkexample.com');
        mapClusterSalesLead.put('Email', 'testclustersaleslead@weworkexample.com');
        User clusterSalesLead = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapClusterSalesLead, true);
        
        Map<String, Object> mapCommunityManager = new Map<String, Object>();
        mapCommunityManager.put('LastName', 'TestCommunityManager');
        mapCommunityManager.put('Username', 'TestCommunityManager' + DateTime.now().getTime() + '@weworkexample.com');
        mapCommunityManager.put('Email', 'testcommunitymanager@weworkexample.com');
        User communityManager = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapCommunityManager, true);
      
        Map<String, Object> mapCommunityLead = new Map<String, Object>();
        mapCommunityLead.put('LastName', 'TestCommunityLead');
        mapCommunityLead.put('Username', 'TestCommunityLead' + DateTime.now().getTime() + '@weworkexample.com');
        mapCommunityLead.put('Email', 'testcommunitylead@weworkexample.com');
        User communityLead = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapCommunityLead, true);
       
        Region__c objRegion = new Region__c(Name = 'Test Region', Region__c = 'Test Region', Regional_Sales_Manager__c = regionSalesManager.Id);
        TestingUtility.insertWithAssert(objRegion, 'Region not inserted');
            
        Territory__c objTerritory = new Territory__c(Name = 'Test Territory', Territory__c =' Test Territory', RegionID__c = objRegion.Id, Territory_Sales_Manager__c = territorySalesManager.Id);
        TestingUtility.insertWithAssert(objTerritory, 'Territory not inserted');
            
        Market__c objMarket = new Market__c(Name = 'Test Portfolio', Portfolio__c = 'Test Portfolio', TerritoryId__c = objTerritory.Id, Portfolio_Sales_Manager__c = portfolioSalesManager.Id);
        TestingUtility.insertWithAssert(objMarket, 'Portfolio not inserted');
    
        Cluster__c objCluster = new Cluster__c(Name = 'Test Cluster', Cluster_Sales_Manager__c = clusterSalesManager.Id, Sales_Lead__c = clusterSalesLead.Id);
        TestingUtility.insertWithAssert(objCluster, 'Cluster not inserted');
        
        List<Building__C> lstBuilding = new List<Building__C>();
        lstBuilding.addAll(TestingUtility.createBuildings(new Map<String, Object>{'Cluster__c' => objCluster.Id}, 1));
        
        TestingUtility.insertListWithAssert(lstBuilding);
        
        User testUser1 = new User(Alias = 'test123', Email = 'johnsmith2610201801@example.com', 
                                EmailEncodingKey = 'UTF-8', FirstName = 'Chris', LastName = 'Bonapart', LanguageLocaleKey = 'en_US',
                                LocalesIdKey = 'en_IN', ProfileId = weworkSystemAdmin.Id, Country = 'India',
                                TimezonesIdKey = 'Asia/Kolkata', UserName = 'johnsmith2610201801' + DateTime.now().getTime() + '@example.com'); 
        lstUsers.add(testUser1);
        
        User testUser2 = new User(Alias = 'test123', Email = 'johnsmith2610201802@example.com', 
                                EmailEncodingKey = 'UTF-8', FirstName = 'Chris', LastName = 'Bonapart', LanguageLocaleKey = 'en_US',
                                LocalesIdKey = 'en_IN', ProfileId = weworkEnterpriseSolutions.Id, Country = 'India',
                                TimezonesIdKey = 'Asia/Kolkata', UserName = 'johnsmith2610201802' + DateTime.now().getTime() + '@example.com'); 
        lstUsers.add(testUser2);
        TestingUtility.insertListWithAssert(lstUsers);
        
        SalesConsoleSettings.createSettings();   
        
        List<Tour_Schedule__c> lstTourSchdules = new List<Tour_Schedule__c>();
        Tour_Schedule__c objTourSchedule = new Tour_Schedule__c(
            Building__c = lstBuilding[0].Id,
            Start_Time__c = '8:00AM',
            End_Time__c = '8:30AM',
            Product_Line__c = 'WeWork',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 10
        );
        lstTourSchdules.add(objTourSchedule);
        TestingUtility.insertListWithAssert(lstTourSchdules);
        
        List<Tour_Closed_Hour__c> lstTourClosedHours = new List<Tour_Closed_Hour__c>();
        Tour_Closed_Hour__c objTourClosedHour = new Tour_Closed_Hour__c(
        	Building__c = objTourSchedule.Building__c,
            Start_Time__c = '8:00AM',
            End_Time__c = '8:30AM',
            Tour_Schedule__c = objTourSchedule.Id
        );
        lstTourClosedHours.add(objTourClosedHour);
        TestingUtility.insertListWithAssert(lstTourClosedHours);
    }
    
    /****************************************************************************************************************************
        Author              : Jitesh Adwani
        Description         : This method Covers the GetPageData() and constructor.
        Created Date        : 25-10-2018
       	Issue               : ST-2939
    *****************************************************************************************************************************/
    static testMethod void testGetPageData(){
        ApexPages.StandardController controller = new ApexPages.StandardController(new Tour_Schedule__c());
        PageReference pageRef = Page.TourCloseHour;
        pageRef.getParameters().put('retURL', 'Enzigma');
        Test.setCurrentPage(pageRef);        
        TourCloseHourController objTour = new TourCloseHourController(controller);
        
        List<Tour_Closed_Hour__c> lstTourClosedHours = new List<Tour_Closed_Hour__c>([SELECT Id, Tour_Schedule__c FROM Tour_Closed_Hour__c]);

        List<User> lstUsers = new List<User>([SELECT Id, Name, UserName, Email FROM User WHERE Email = 'johnsmith2610201801@example.com']);
        System.assertEquals(1, lstUsers.size());
        
        DatabaseResult result;
        
        System.runAs(lstUsers[0]){
            result = TourCloseHourController.getPageData('TourCloseHour', lstTourClosedHours[0].Tour_Schedule__c, lstTourClosedHours[0].Id);
            System.assert(result.success);
            System.assertNotEquals(null, result.data);
            
            Map<String, Object> mapPageData = (Map<String, Object>)result.data;
            List<String> lstInstructions = (List<String>)mapPageData.get('instructions');
            System.assertNotEquals(null, lstInstructions);
            System.assertEquals(3, lstInstructions.size());
        }
        
        result = TourCloseHourController.getPageData(null, null, null);
    }
}