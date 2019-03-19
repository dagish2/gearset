@isTest
public class BatchToMigrateBuildingPlayersTests {
    /*
* @ Descrption : To Test Data Maigration for populate building players Names and Email.
* @ Created By : Krishana Tupe
* @ Created Date : 06 Jan 2018
* @ Issue : For ST-1855
*/	 public static Profile weworkSystemAdmin;
     public static FactoryClass objFc = new FactoryClass();
     public static User RegionSalesManager;
     public static User TerritorySalesManager;
     public static User PortfolioSalesManager;
     public static User ClusterSalesManager;
     public static User ClusterSalesLead ;
     public static void setup() {
     	weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        RegionSalesManager = objFc.getRegionSalesManager(weworkSystemAdmin.Id);
        TerritorySalesManager = objFc.getTerritorySalesManager(weworkSystemAdmin.Id);
        PortfolioSalesManager = objFc.getPortfolioSalesManager(weworkSystemAdmin.Id);
        ClusterSalesManager= objFc.getClusterSalesManager(weworkSystemAdmin.Id);
        ClusterSalesLead = objFc.getClusterSalesLead(weworkSystemAdmin.Id);
     
     }
     static testMethod void testMultipleRecordsDifferentScenario(){ 
     	BatchToMigrateBuildingPlayersTests.setup();         
        Region__c regn = objFc.insertRegion(RegionSalesManager.ID);
        System.assert(regn.Id!=null, 'Region not inserted');
        
        Territory__c tertry = objFc.insertTerritory(TerritorySalesManager.Id,regn.Id);
        System.assert(tertry.Id!=null, 'Territory not inserted');
        
        Market__c mrkt = objFc.insertPortfolio(tertry.Id,PortfolioSalesManager.Id);
        System.assert(mrkt.Id!=null, 'Portfolio not inserted');
        
        Cluster__c clstr =  objFc.insertCluster(ClusterSalesLead.Id,ClusterSalesManager.Id);
        System.assert(clstr.Id!=null, 'Cluster not inserted');
        
        List<Building__c> lstbldng = objFc.insertMultipleBuilding(null,mrkt.Id,3);
        lstbldng.addAll(objFc.insertMultipleBuilding(clstr.Id,null,3)); 
     	
        map<ID,Object> mapBldng  = new  map<ID,Object>();
        for(Building__c itrbuldng : lstbldng)
        {
            System.assert(itrbuldng.Id!=null, 'Building not inserted');  
            mapBldng.put(itrbuldng.Id, itrbuldng);
        }
         
        lstbldng =   [Select Id,
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
					Regional_Sales_Manager_Email__c	From Building__c Where Id IN :mapBldng.keySet()];
         
        Test.startTest();
        Database.executeBatch(new BatchToMigrateBuildingPlayers(),6);
        Test.stopTest();
        Integer index = 0; 
        for(Building__c itrbuldng : lstbldng)
          {
              if(index <=2 )
              {
                System.assertEquals(null,itrbuldng.Cluster_Name__c, 'Cluster Name not Populated');
                System.assertEquals('Test Portfolio',itrbuldng.Portfolio_Name__c, 'Portfolio Name not Populated');
                System.assertEquals('Test Territory',itrbuldng.Territory_Name__c, 'Territory Name not Populated');
                System.assertEquals('Test Region',itrbuldng.Region_Name__c, 'Region Name not Populated');
        
                System.assertEquals(null,itrbuldng.Cluster_Sales_Manager_Name__c, 'Cluster Sales Manager Name not Populated');
                System.assertEquals(null,itrbuldng.Cluster_Sales_Lead_Name__c, 'Cluster Sales Lead Name not Populated');
                System.assertEquals('TestPortfolioSalesManager',itrbuldng.Portfolio_Sales_Manager_Name__c, 'Portfolio Sales Manager Name not Populated');
                System.assertEquals('TestTerritorySalesManager',itrbuldng.Territory_Sales_Manager_Name__c, 'Territory Sales Manager Name not Populated');
                System.assertEquals('TestRegionSalesManager',itrbuldng.Regional_Sales_Manager_Name__c, 'Region Sales Manager Name not Populated');
                
                System.assertEquals(null,itrbuldng.Cluster_Sales_Manager_Email__c, 'Cluster Sales Manager Email not Populated');
                System.assertEquals(null,itrbuldng.Cluster_Sales_Lead_Email__c, 'Cluster Sales Lead Email not Populated');
                System.assertEquals('testportfoliosalesmanager@weworkexample.com',itrbuldng.Portfolio_Sales_Manager_Email__c, 'Portfolio Sales Manager Email not Populated');
                System.assertEquals('testterritorysalesmanager@weworkexample.com',itrbuldng.Territory_Sales_Manager_Email__c, 'Territory Sales Manager Email not Populated');
                System.assertEquals('testregionsalesmanager@weworkexample.com',itrbuldng.Regional_Sales_Manager_Email__c, 'Region Sales Manager Email not Populated');
             }
             else{
                  
                System.assertEquals('Test Cluster',itrbuldng.Cluster_Name__c, 'Cluster Name not Populated');
                System.assertEquals(null,itrbuldng.Portfolio_Name__c, 'Portfolio Name not Populated');
                System.assertEquals(null,itrbuldng.Territory_Name__c, 'Territory Name not Populated');
                System.assertEquals(null,itrbuldng.Region_Name__c, 'Region Name not Populated');
        
                System.assertEquals('TestClusterSalesManager',itrbuldng.Cluster_Sales_Manager_Name__c, 'Cluster Sales Manager Name not Populated');
                System.assertEquals('TestClusterSalesLead',itrbuldng.Cluster_Sales_Lead_Name__c, 'Cluster Sales Lead Name not Populated');
                System.assertEquals(null,itrbuldng.Portfolio_Sales_Manager_Name__c, 'Portfolio Sales Manager Name not Populated');
                System.assertEquals(null,itrbuldng.Territory_Sales_Manager_Name__c, 'Territory Sales Manager Name not Populated');
                System.assertEquals(null,itrbuldng.Regional_Sales_Manager_Name__c, 'Region Sales Manager Name not Populated');
                
                System.assertEquals('testclustersalesmanager@weworkexample.com',itrbuldng.Cluster_Sales_Manager_Email__c, 'Cluster Sales Manager Email not Populated');
                System.assertEquals('testclustersaleslead@weworkexample.com',itrbuldng.Cluster_Sales_Lead_Email__c, 'Cluster Sales Lead Email not Populated');
                System.assertEquals(null,itrbuldng.Portfolio_Sales_Manager_Email__c, 'Portfolio Sales Manager Email not Populated');
                System.assertEquals(null,itrbuldng.Territory_Sales_Manager_Email__c, 'Territory Sales Manager Email not Populated');
                System.assertEquals(null,itrbuldng.Regional_Sales_Manager_Email__c, 'Region Sales Manager Email not Populated');
           }
             ++index; 
          } 
               
         
     }
     static testMethod void testBatchToMigrateBuildingPlayersStrightWorkflowTests(){ 
		BatchToMigrateBuildingPlayersTests.setup();         
        Region__c regn = objFc.insertRegion(RegionSalesManager.ID);
        System.assert(regn.Id!=null, 'Region not inserted');
        
        Territory__c tertry = objFc.insertTerritory(TerritorySalesManager.Id,regn.Id);
        System.assert(tertry.Id!=null, 'Territory not inserted');
        
        Market__c mrkt = objFc.insertPortfolio(tertry.Id,PortfolioSalesManager.Id);
        System.assert(mrkt.Id!=null, 'Portfolio not inserted');
        
        Cluster__c clstr =  objFc.insertCluster(ClusterSalesLead.Id,ClusterSalesManager.Id);
        System.assert(clstr.Id!=null, 'Cluster not inserted');
        
        List<Building__c> lstbldng =   objFc.insertMultipleBuilding(clstr.Id,mrkt.Id,5);
        map<ID,Object> mapBldng  = new  map<ID,Object>();
        for(Building__c itrbuldng : lstbldng)
        {
            System.assert(itrbuldng.Id!=null, 'Building not inserted');  
            mapBldng.put(itrbuldng.Id, itrbuldng);
        }
        
        lstbldng =   [Select Id,
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
					Regional_Sales_Manager_Email__c	From Building__c Where Id IN :mapBldng.keySet()];
         debug.log('lstbldng===>'+lstbldng);
         Test.startTest();
         Database.executeBatch(new BatchToMigrateBuildingPlayers(),5);
         Test.stopTest();
         
          for(Building__c itrbuldng : lstbldng)
          {
                System.assertEquals('Test Cluster',itrbuldng.Cluster_Name__c, 'Cluster Name not Populated');
                System.assertEquals('Test Portfolio',itrbuldng.Portfolio_Name__c, 'Portfolio Name not Populated');
                System.assertEquals('Test Territory',itrbuldng.Territory_Name__c, 'Territory Name not Populated');
                System.assertEquals('Test Region',itrbuldng.Region_Name__c, 'Region Name not Populated');
        
                System.assertEquals('TestClusterSalesManager',itrbuldng.Cluster_Sales_Manager_Name__c, 'Cluster Sales Manager Name not Populated');
                System.assertEquals('TestClusterSalesLead',itrbuldng.Cluster_Sales_Lead_Name__c, 'Cluster Sales Lead Name not Populated');
                System.assertEquals('TestPortfolioSalesManager',itrbuldng.Portfolio_Sales_Manager_Name__c, 'Portfolio Sales Manager Name not Populated');
                System.assertEquals('TestTerritorySalesManager',itrbuldng.Territory_Sales_Manager_Name__c, 'Territory Sales Manager Name not Populated');
                System.assertEquals('TestRegionSalesManager',itrbuldng.Regional_Sales_Manager_Name__c, 'Region Sales Manager Name not Populated');
                
                System.assertEquals('testclustersalesmanager@weworkexample.com',itrbuldng.Cluster_Sales_Manager_Email__c, 'Cluster Sales Manager Email not Populated');
                System.assertEquals('testclustersaleslead@weworkexample.com',itrbuldng.Cluster_Sales_Lead_Email__c, 'Cluster Sales Lead Email not Populated');
                System.assertEquals('testportfoliosalesmanager@weworkexample.com',itrbuldng.Portfolio_Sales_Manager_Email__c, 'Portfolio Sales Manager Email not Populated');
                System.assertEquals('testterritorysalesmanager@weworkexample.com',itrbuldng.Territory_Sales_Manager_Email__c, 'Territory Sales Manager Email not Populated');
                System.assertEquals('testregionsalesmanager@weworkexample.com',itrbuldng.Regional_Sales_Manager_Email__c, 'Region Sales Manager Email not Populated');
           }
    }
    static testMethod void testBatchToMigrateBuildingPlayersForPortfolioTests(){ 
       	BatchToMigrateBuildingPlayersTests.setup();         
        
        Region__c regn = objFc.insertRegion(RegionSalesManager.ID);
        System.assert(regn.Id!=null, 'Region not inserted');
        
        Territory__c tertry = objFc.insertTerritory(TerritorySalesManager.Id,regn.Id);
		System.assert(tertry.Id!=null, 'Territory not inserted');
        
        Market__c mrkt = objFc.insertPortfolio(tertry.Id,PortfolioSalesManager.Id);
		System.assert(mrkt.Id!=null, 'Portfolio not inserted');
        
        Cluster__c clstr =  objFc.insertCluster(ClusterSalesLead.Id,ClusterSalesManager.Id);
		System.assert(clstr.Id!=null, 'Cluster not inserted');
        
        Building__c bldng1 = objFc.insertMultipleBuilding(clstr.Id,null,1)[0];
		System.assert(bldng1.Id!=null, 'Building not inserted');
        
        bldng1 =   [Select Id,
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
					Regional_Sales_Manager_Email__c	From Building__c Where Id=:bldng1.Id];
         debug.log('bldng===>'+bldng1);
         Test.startTest();
         Database.executeBatch(new BatchToMigrateBuildingPlayers());
         Test.stopTest();
         
         
        System.assertEquals('Test Cluster',bldng1.Cluster_Name__c, 'Cluster Name not Populated');
        System.assertEquals(null,bldng1.Portfolio_Name__c, 'Portfolio Name not Populated');
        System.assertEquals(null,bldng1.Territory_Name__c, 'Territory Name not Populated');
        System.assertEquals(null,bldng1.Region_Name__c, 'Region Name not Populated');

        System.assertEquals('TestClusterSalesManager',bldng1.Cluster_Sales_Manager_Name__c, 'Cluster Sales Manager Name not Populated');
        System.assertEquals('TestClusterSalesLead',bldng1.Cluster_Sales_Lead_Name__c, 'Cluster Sales Lead Name not Populated');
        System.assertEquals(null,bldng1.Portfolio_Sales_Manager_Name__c, 'Portfolio Sales Manager Name not Populated');
        System.assertEquals(null,bldng1.Territory_Sales_Manager_Name__c, 'Territory Sales Manager Name not Populated');
        System.assertEquals(null,bldng1.Regional_Sales_Manager_Name__c, 'Region Sales Manager Name not Populated');
        
        System.assertEquals('testclustersalesmanager@weworkexample.com',bldng1.Cluster_Sales_Manager_Email__c, 'Cluster Sales Manager Email not Populated');
        System.assertEquals('testclustersaleslead@weworkexample.com',bldng1.Cluster_Sales_Lead_Email__c, 'Cluster Sales Lead Email not Populated');
        System.assertEquals(null,bldng1.Portfolio_Sales_Manager_Email__c, 'Portfolio Sales Manager Email not Populated');
        System.assertEquals(null,bldng1.Territory_Sales_Manager_Email__c, 'Territory Sales Manager Email not Populated');
        System.assertEquals(null,bldng1.Regional_Sales_Manager_Email__c, 'Region Sales Manager Email not Populated');
    }
    static testMethod void testBatchToMigrateBuildingPlayersForClusterTests(){ 
       	BatchToMigrateBuildingPlayersTests.setup();         
        Region__c regn = objFc.insertRegion(null);
        System.assert(regn.Id!=null, 'Region not inserted');
        
        Territory__c tertry = objFc.insertTerritory(null,regn.Id);
        System.assert(tertry.Id!=null, 'Territory not inserted');
        
        Market__c mrkt = objFc.insertPortfolio(tertry.Id,PortfolioSalesManager.Id);
        System.assert(mrkt.Id!=null, 'Portfolio not inserted');
        
        Cluster__c clstr = objFc.insertCluster(null,null);
        System.assert(clstr.Id!=null, 'Cluster not inserted');
        
        Building__c bldng1 = objFc.insertMultipleBuilding(null,mrkt.Id,1)[0];
        System.assert(bldng1.Id!=null, 'Building not inserted');
        
        bldng1 =   [Select Id,
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
					Regional_Sales_Manager_Email__c	From Building__c Where Id=:bldng1.Id];
         debug.log('bldng===>'+bldng1);
         Test.startTest();
         Database.executeBatch(new BatchToMigrateBuildingPlayers());
         Test.stopTest();
         
         
        System.assertEquals(null,bldng1.Cluster_Name__c, 'Cluster Name not Populated');
        System.assertEquals('Test Portfolio',bldng1.Portfolio_Name__c, 'Portfolio Name not Populated');
        System.assertEquals('Test Territory',bldng1.Territory_Name__c, 'Territory Name not Populated');
        System.assertEquals('Test Region',bldng1.Region_Name__c, 'Region Name not Populated');

        System.assertEquals(null,bldng1.Cluster_Sales_Manager_Name__c, 'Cluster Sales Manager Name not Populated');
        System.assertEquals(null,bldng1.Cluster_Sales_Lead_Name__c, 'Cluster Sales Lead Name not Populated');
        System.assertEquals('TestPortfolioSalesManager',bldng1.Portfolio_Sales_Manager_Name__c, 'Portfolio Sales Manager Name not Populated');
        System.assertEquals(null,bldng1.Territory_Sales_Manager_Name__c, 'Territory Sales Manager Name not Populated');
        System.assertEquals(null,bldng1.Regional_Sales_Manager_Name__c, 'Region Sales Manager Name not Populated');
        
        System.assertEquals(null,bldng1.Cluster_Sales_Manager_Email__c, 'Cluster Sales Manager Email not Populated');
        System.assertEquals(null,bldng1.Cluster_Sales_Lead_Email__c, 'Cluster Sales Lead Email not Populated');
        
        System.assertEquals(null,bldng1.Territory_Sales_Manager_Email__c, 'Territory Sales Manager Email not Populated');
        System.assertEquals(null,bldng1.Regional_Sales_Manager_Email__c, 'Region Sales Manager Email not Populated');
    }
    
    class FactoryClass{
        
        public List<Building__c> insertMultipleBuilding(Id clstrId,Id mrktId,Integer numberOfBuildings)
        {	
            List<Building__c> lstBuilding = new List<Building__c>();
            if( numberOfBuildings == null )
                numberOfBuildings = 1;
            for(Integer index = 0;index < numberOfBuildings; ++index)
            {
                        Building__c bldng = new Building__c(Name='Test Building'+index,Cluster__c = clstrId,Market__c = mrktId);
        				lstBuilding.add(bldng);
			}
            
            INSERT lstBuilding;
            return lstBuilding;
        }
        public Market__c insertPortfolio(Id tertryId,Id PortfolioSalesManagerId)
        {
             Market__c mrkt = new Market__c(Name='Test Portfolio',Portfolio__c='Test Portfolio',TerritoryId__c=tertryId,Portfolio_Sales_Manager__c=PortfolioSalesManagerId);
          	 insert mrkt;
             return mrkt;
        }
        public Region__c insertRegion(Id RegionSalesManager)
        {
             Region__c regn = new Region__c(Name='Test Region',Region__c='Test Region',Regional_Sales_Manager__c= RegionSalesManager);
       		 INSERT regn;
             return regn;
        }
         public Territory__c insertTerritory(Id TerritorySalesManager,Id regn)
        {        
            Territory__c tertry = new Territory__c(Name='Test Territory',Territory__c='Test Territory',RegionID__c=regn,Territory_Sales_Manager__c=TerritorySalesManager);
        	insert tertry;
            return tertry;
        }
         public Cluster__c insertCluster(Id ClusterSalesLead,Id ClusterSalesManager)
        {
             Cluster__c clstr = new Cluster__c(Name='Test Cluster',Cluster_Sales_Manager__c=ClusterSalesManager,Sales_Lead__c=ClusterSalesLead);
       		 insert clstr;
             return clstr;
        }
        public User getRegionSalesManager(Id weworkSystemAdminId)
        {
            Map<String,Object> mapRegionSalesManager = new Map<String,Object>();
            mapRegionSalesManager.put('LastName','TestRegionSalesManager');
            mapRegionSalesManager.put('Username','TestRegionSalesManager@weworkexample.com');
            mapRegionSalesManager.put('Email','testregionsalesmanager@weworkexample.com');
            return TestingUtility.insertUserWithAssert(weworkSystemAdminId, mapRegionSalesManager, true);
        }
        public User getTerritorySalesManager(Id weworkSystemAdminId){
            
            Map<String,Object> mapTerritorySalesManager = new Map<String,Object>();
            mapTerritorySalesManager.put('LastName','TestTerritorySalesManager');
            mapTerritorySalesManager.put('Username','TestTerritorySalesManager@weworkexample.com');
            mapTerritorySalesManager.put('Email','testterritorysalesmanager@weworkexample.com');
            return TestingUtility.insertUserWithAssert(weworkSystemAdminId, mapTerritorySalesManager, true);
        }
        public User getPortfolioSalesManager(Id weworkSystemAdminId){
             Map<String,Object> mapPortfolioSalesManager = new Map<String,Object>();
             mapPortfolioSalesManager.put('LastName','TestPortfolioSalesManager');
             mapPortfolioSalesManager.put('Username','TestPortfolioSalesManager@weworkexample.com');
             mapPortfolioSalesManager.put('Email','testportfoliosalesmanager@weworkexample.com');
             return TestingUtility.insertUserWithAssert(weworkSystemAdminId, mapPortfolioSalesManager, true);

        }
         public User getClusterSalesManager(Id weworkSystemAdminId){
             Map<String,Object> mapClusterSalesManager = new Map<String,Object>();
             mapClusterSalesManager.put('LastName','TestClusterSalesManager');
             mapClusterSalesManager.put('Username','TestClusterSalesManager@weworkexample.com');
             mapClusterSalesManager.put('Email','testclustersalesmanager@weworkexample.com');
             return TestingUtility.insertUserWithAssert(weworkSystemAdminId, mapClusterSalesManager, true);
         }
         public User getClusterSalesLead(Id weworkSystemAdminId){
             Map<String,Object> mapClusterSalesLead = new Map<String,Object>();
             mapClusterSalesLead.put('LastName','TestClusterSalesLead');
             mapClusterSalesLead.put('Username','TestClusterSalesLead@weworkexample.com');
             mapClusterSalesLead.put('Email','testclustersaleslead@weworkexample.com');
             return TestingUtility.insertUserWithAssert(weworkSystemAdminId, mapClusterSalesLead, true);
         }
    }
}