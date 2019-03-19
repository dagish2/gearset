@isTest
public class ScheduleUserSalesHierarchyTest {

/*****************************************************************************************************************************
    Author         		: Rupesh Patil
    Description     	: Test Method To verify User's VP, director,manager fields after batch fired
    Created Date    	: 7 Mar 2018
    Last Modified By   	: Pragalbha Mahajan
    Last Modified Date  : 4 July 2018
******************************************************************************************************************************/
    
    public static testMethod void testUserSalesRoleOnUser(){
        SalesConsoleSettings.createSettings();
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Map<String,Object> mapTestUserSalesExecutive = new Map<String,Object>();
        mapTestUserSalesExecutive.put('LastName','TestUserSalesExecutive');
        mapTestUserSalesExecutive.put('Username','testusersalesexecutive@weworkexample.com');
        mapTestUserSalesExecutive.put('Email','testusersalesexecutive@weworkexample.com');
        mapTestUserSalesExecutive.put('Sales_Role__c','Sales Executive');
        User testUserSalesExecutive = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTestUserSalesExecutive, true);
        
        Map<String,Object> mapTestUserSalesVP = new Map<String,Object>();
        mapTestUserSalesVP.put('LastName','TestUserSalesVP');
        mapTestUserSalesVP.put('Username','testusersalesvp@weworkexample.com');
        mapTestUserSalesVP.put('Email','testusersalesvp@weworkexample.com');
        mapTestUserSalesVP.put('Sales_Role__c','VP of Sales');
        //mapTestUserSalesVP.put('ManagerId', testUserSalesExecutive.Id);
        User testUserSalesVP = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTestUserSalesVP, true);
        
        Map<String,Object> mapTestUserSalesDirector = new Map<String,Object>();
        mapTestUserSalesDirector.put('LastName','TestUserSalesDirector');
        mapTestUserSalesDirector.put('Username','testusersalesdirector@weworkexample.com');
        mapTestUserSalesDirector.put('Email','testusersalesdirector@weworkexample.com');
        mapTestUserSalesDirector.put('Sales_Role__c','Director of Sales');
        mapTestUserSalesDirector.put('ManagerId',testUserSalesVP.Id);
        User testUserSalesDirector = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTestUserSalesDirector, true);
        
        Map<String,Object> mapTestUserSenior = new Map<String,Object>();
        mapTestUserSenior.put('LastName','TestUserSenior');
        mapTestUserSenior.put('Username','testusersenior@weworkexample.com');
        mapTestUserSenior.put('Email','testusersenior@weworkexample.com');
        mapTestUserSenior.put('Sales_Role__c','Sr. Account Executive');
        mapTestUserSenior.put('ManagerId',testUserSalesDirector.Id);
        User testUserSenior = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTestUserSenior, true);
        
        Map<String,Object> mapTestUserJunior = new Map<String,Object>();
        mapTestUserJunior.put('LastName','TestUserJunior');
        mapTestUserJunior.put('Username','testuserjunior@weworkexample.com');
        mapTestUserJunior.put('Email','testuserjunior@weworkexample.com');
        mapTestUserJunior.put('Sales_Role__c','Jr. Account Executive');
        mapTestUserJunior.put('ManagerId', testUserSalesDirector.Id);
        User testUserJunior = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTestUserJunior, true);
        
       
        ScheduleBatchToUpdateUserSalesHierarchy schBatchObj = new ScheduleBatchToUpdateUserSalesHierarchy();
        Test.startTest();
        Database.executeBatch(schBatchObj);
        Test.stopTest();
       
        //Checked for User fields (Role:Jr. Account Executive)
        User objUser = [SELECT Id,LastName,Email,ManagerId, Manager_Name__c,Manager_Email__c,VP__c,VP_Email__c,Director__c,Director_Email__c FROM User WHERE Sales_Role__c =:'Jr. Account Executive' AND ManagerId =:testUserSalesDirector.Id];
     //This is one time batch, no need to check for assertions
       /* System.assertEquals(testUserJunior.Id, objUser.Id);
        System.assertEquals(testUserJunior.LastName, objUser.LastName); 
        System.assertEquals(testUserJunior.Email, objUser.Email);        
        if(String.isNotBlank(objUser.ManagerId) && String.isNotBlank(objUser.Manager_Name__c)){
            System.assertEquals(testUserSalesDirector.LastName,objUser.Manager_Name__c);  
            System.assertEquals(testUserSalesDirector.Email,objUser.Manager_Email__c); 
        }
        
        System.assertEquals(testUserSalesDirector.LastName,objUser.Director__c);
        System.assertEquals(testUserSalesDirector.Email,objUser.Director_Email__c);
        System.assertEquals(testUserSalesVP.LastName, objUser.VP__c);
        System.assertEquals(testUserSalesVP.Email, objUser.VP_Email__c);*/
       
    }
    public static testMethod void testUserSalesRoleOnOpportunity(){
        SalesConsoleSettings.createSettings();
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Map<String,Object> mapTestUserSalesVP = new Map<String,Object>();
        mapTestUserSalesVP.put('LastName','TestUserSalesVP');
        mapTestUserSalesVP.put('Username','testusersalesvp@weworkexample.com');
        mapTestUserSalesVP.put('Email','testusersalesvp@weworkexample.com');
        mapTestUserSalesVP.put('Sales_Role__c','VP of Sales');
        User testUserSalesVP = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTestUserSalesVP, true);
        debug.log('testUserSalesVP: '+testUserSalesVP);
        
        Map<String,Object> mapTestUserSalesDirector = new Map<String,Object>();
        mapTestUserSalesDirector.put('LastName','TestUserSalesDirector');
        mapTestUserSalesDirector.put('Username','testusersalesdirector@weworkexample.com');
        mapTestUserSalesDirector.put('Email','testusersalesdirector@weworkexample.com');
        mapTestUserSalesDirector.put('Sales_Role__c','Director of Sales');
        mapTestUserSalesDirector.put('ManagerId',testUserSalesVP.Id);
        User testUserSalesDirector = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTestUserSalesDirector, true);
        debug.log('testUserSalesDirector: '+testUserSalesDirector);
        
        Map<String,Object> mapTestUserSenior = new Map<String,Object>();
        mapTestUserSenior.put('LastName','TestUserSenior');
        mapTestUserSenior.put('Username','testusersenior@weworkexample.com');
        mapTestUserSenior.put('Email','testusersenior@weworkexample.com');
        mapTestUserSenior.put('Sales_Role__c','Sr. Account Executive');
        mapTestUserSenior.put('ManagerId',testUserSalesDirector.Id);
        User testUserSenior = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTestUserSenior, true);
        debug.log('testUserSenior: '+testUserSenior);
        
        Map<String,Object> mapTestUserJunior = new Map<String,Object>();
        mapTestUserJunior.put('LastName','TestUserJunior');
        mapTestUserJunior.put('Username','testuserjunior@weworkexample.com');
        mapTestUserJunior.put('Email','testuserjunior@weworkexample.com');
        mapTestUserJunior.put('Sales_Role__c','Jr. Account Executive');
        mapTestUserJunior.put('ManagerId', testUserSalesDirector.Id);
        User testUserJunior = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapTestUserJunior, true);
        debug.log('testUserJunior: '+testUserJunior);
        
        List<Account> lstAccounts = new List<Account>();
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Account acc = new Account(
            name = 'Test Account',
            UUID__c = 'Test_Account_UUID',
            OwnerId = testUserJunior.Id // Modified
        );
        lstAccounts.add(acc);
        TestingUtility.insertListWithAssert(lstAccounts);
        
        Account acc1 = [SELECT Id,Name,ownerId,Owner.Name FROM Account WHERE Id =: acc.Id];        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            CloseDate = Date.Today(),
            StageName = 'Qualifying',
            contract_uuid__c = 'oppo123',
            CurrencyIsoCode = 'INR',
            OwnerId = testUserJunior.Id //Modified
           );
       	insert opp;
        System.assertNotEquals(opp.Id, null);
        //lstOpportunity.add(opp);
        //TestingUtility.insertListWithAssert(lstOpportunity);
        debug.log('Oppo: '+opp);
        Opportunity objOpp1 = [SELECT Id,Name,Owner.Name,Sales_Role__c,Director_of_Sales__c,Director_of_Sales_Email__c,VP_of_Sales__c,VP_of_Sales_Email__c,Portfolio_Director__c,Portfolio_Director_Email__c FROM Opportunity WHERE Id =:opp.Id]; 
        Debug.log('objOpp before batch::'+objOpp1);
       	User u = [select Id,Username,Sales_Role__c from User where Id = :UserInfo.getUserId()];
        debug.log('u: '+u);
        ScheduleBatchToUpdateUserSalesHierarchy schBatchObj = new ScheduleBatchToUpdateUserSalesHierarchy();
        Test.startTest(); 
        Database.executeBatch(schBatchObj);
        Test.stopTest();
        
        //Checked for opportunity fields
        Opportunity objOpp = [SELECT Id,Name,Owner.Name,Sales_Role__c,Director_of_Sales__c,Director_of_Sales_Email__c,VP_of_Sales__c,VP_of_Sales_Email__c,Portfolio_Director__c,Portfolio_Director_Email__c FROM Opportunity WHERE Id =:opp.Id]; 
       	Debug.log('objOpp after batch::'+objOpp);
        //This is one time batch, no need to check for assertions
        /*System.assertEquals(testUserJunior.Sales_Role__c, objOpp.Sales_Role__c);        
        System.assertEquals(testUserSalesDirector.LastName, objOpp.Director_of_Sales__c);
        System.assertEquals(testUserSalesDirector.Email, objOpp.Director_of_Sales_Email__c);
        System.assertEquals(testUserSalesVP.LastName, objOpp.VP_of_Sales__c);
        System.assertEquals(testUserSalesVP.Email, objOpp.VP_of_Sales_Email__c);
        System.assertEquals(testUserSalesDirector.LastName, objOpp.Portfolio_Director__c);
        System.assertEquals(testUserSalesDirector.Email, objOpp.Portfolio_Director_Email__c);*/
    }
}