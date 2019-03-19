/************************************************************************************************************************************
    Author 		: 	Milanjeet	
    Description : 	This class contain test methods for cluster trigger.

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			09 November 2017	Milanjeet				Initial Developement
**************************************************************************************************************************************/
@isTest
public class ClusterTriggersHandlerTests {
    /************************************************************************************************************************************
        Author 				: 	Milanjeet
        Description 		: 	This method contain unit test for update cluster info on building.
		Created Date		: 	09 November 2017
	**************************************************************************************************************************************/
    public static testmethod void testUpdateClusterInfoOnBuilding(){
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='Wework System Administrator'];
        
        Map<String,Object> mapClusterSalesManager1 = new Map<String,Object>();
        mapClusterSalesManager1.put('LastName','TestClusterSalesManager1');
        mapClusterSalesManager1.put('Username','TestClusterSalesManager1@weworkexample.com');
        mapClusterSalesManager1.put('Email','TestClusterSalesManager1@weworkexample.com');
        User ClusterSalesManager1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapClusterSalesManager1, true);
        
        Map<String,Object> mapClusterSalesLead1 = new Map<String,Object>();
        mapClusterSalesLead1.put('LastName','TestClusterSalesLead1');
        mapClusterSalesLead1.put('Username','TestClusterSalesLead1@weworkexample.com');
        mapClusterSalesLead1.put('Email','TestClusterSalesLead1@weworkexample.com');
        User ClusterSalesLead1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapClusterSalesLead1, true);
        
        Map<String,Object> mapClusterSalesManager2 = new Map<String,Object>();
        mapClusterSalesManager2.put('LastName','TestClusterSalesManager2');
        mapClusterSalesManager2.put('Username','TestClusterSalesManager2@weworkexample.com');
        mapClusterSalesManager2.put('Email','TestClusterSalesManager2@weworkexample.com');
        User ClusterSalesManager2 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapClusterSalesManager2, true);
        
        Map<String,Object> mapClusterSalesLead2 = new Map<String,Object>();
        mapClusterSalesLead2.put('LastName','TestClusterSalesLead2');
        mapClusterSalesLead2.put('Username','TestClusterSalesLead2@weworkexample.com');
        mapClusterSalesLead2.put('Email','TestClusterSalesLead2@weworkexample.com');
        User ClusterSalesLead2 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapClusterSalesLead2, true);
        
        Cluster__c clstr = new Cluster__c(Name='Test Cluster',Cluster_Sales_Manager__c=ClusterSalesManager1.Id,Sales_Lead__c=ClusterSalesLead1.Id);
        insert clstr;
        System.assert(clstr.Id!=null, 'Cluster not inserted');
        
        Building__c bldng = new Building__c(Name='Test Building',Cluster__c=clstr.Id);
        insert bldng;
        System.assert(bldng.Id!=null, 'Building not inserted');
        
        bldng = [Select Id,Cluster_Sales_Manager_Name__c, Cluster_Sales_Lead_Name__c, Cluster_Name__c from Building__c where Id=:bldng.Id];
        clstr = [Select Id,Name,Sales_Lead__r.Name,Cluster_Sales_Manager__r.Name from Cluster__c where Id=:clstr.Id];
        
        System.assertEquals(bldng.Cluster_Name__c.toLowerCase(), clstr.Name.toLowerCase(),'Cluster Name Not updated on Building');
        System.assertEquals(bldng.Cluster_Sales_Lead_Name__c.toLowerCase(), clstr.Sales_Lead__r.Name.toLowerCase(),'Cluster Sales Lead Name NOt Updated on Building');
        System.assertEquals(bldng.Cluster_Sales_Manager_Name__c.toLowerCase(), clstr.Cluster_Sales_Manager__r.Name.toLowerCase(),'Cluster Sales Manager Name Not Updated on Building');
        
        //Updating Cluster Information
        clstr.Name = 'Test Cluster Updated';
        clstr.Sales_Lead__c=ClusterSalesLead2.Id;
        clstr.Cluster_Sales_Manager__c=ClusterSalesManager2.Id;
        update clstr;
        
        clstr = [Select Id,Name,Sales_Lead__r.Name,Cluster_Sales_Manager__r.Name from Cluster__c where Id=:clstr.Id];
        bldng = [Select Id,Cluster_Sales_Manager_Name__c, Cluster_Sales_Lead_Name__c, Cluster_Name__c from Building__c where Id=:bldng.Id];
        System.assertEquals(clstr.Name.toLowerCase(),bldng.Cluster_Name__c.toLowerCase(),'Cluster Name Not Updated on Building');
        System.assertEquals(bldng.Cluster_Sales_Lead_Name__c.toLowerCase(), clstr.Sales_Lead__r.Name.toLowerCase(),'Cluster Sales Lead Name Not updated on Building');
        System.assertEquals(bldng.Cluster_Sales_Manager_Name__c.toLowerCase(), clstr.Cluster_Sales_Manager__r.Name.toLowerCase(),'Cluster Sales Manager Name Not Updated on Building');
        
        //Scanerio for clearing SalesLead or SalesLead Manager: It should be blank on building too
        clstr.Sales_Lead__c = null;
        clstr.Cluster_Sales_Manager__c = null;
        update clstr;
        
        clstr = [Select Id,Sales_Lead__r.Name,Cluster_Sales_Manager__r.Name from Cluster__c where Id=:clstr.Id];
        bldng = [Select Id,Cluster_Sales_Manager_Name__c, Cluster_Sales_Lead_Name__c, Cluster_Name__c from Building__c where Id=:bldng.Id];
        
        System.assertEquals(bldng.Cluster_Sales_Lead_Name__c, clstr.Sales_Lead__r.Name,'Cluster Sales Lead Name Not updated on Building');
        System.assertEquals(bldng.Cluster_Sales_Manager_Name__c, clstr.Cluster_Sales_Manager__r.Name,'Cluster Sales Manager Name Not Updated on Building');
    }
}