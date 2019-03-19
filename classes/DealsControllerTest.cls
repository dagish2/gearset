@isTest
private class DealsControllerTest {
    static testMethod void testDealsController(){
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork Standard User'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 1');
        userRecordMap.put('Username','testweworkuser1@test.com');
        userRecordMap.put('Email','testuser1@test.com');
        User user1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true);
        
        Deal__c deal1 = new Deal__c();
        deal1.Name = 'Deal 1';
        deal1.Priority__c = 'Important / Urgent';
        deal1.Status__c = 'Pencils Down';
        deal1.Phase__c = 'E';
        deal1.Group__c = 'Corporate';
        deal1.Notes__c = 'Hony Investors';
        deal1.Team__c = 'Legal: Rachell';
        deal1.Timing__c = System.today();
        deal1.Adam_Actions__c = 'Adam to discuss status of Jin Jiang and China Oceanwide with John Zhao';
        deal1.Approver_1__c = user1.Id;
        TestingUtility.insertWithAssert(deal1);
        
        Deal__c deal2 = new Deal__c();
        deal2.Name = 'Deal 2';
        deal2.Priority__c = 'Important / Urgent';
        deal2.Status__c = 'Pencils Down';
        deal2.Phase__c = 'E';
        deal2.Group__c = 'Corporate';
        deal2.Notes__c = 'Hony Investors';
        deal2.Team__c = 'Legal: Rachell';
        deal2.Timing__c = System.today();
        deal2.Adam_Actions__c = 'Adam to discuss status of Jin Jiang and China Oceanwide with John Zhao';
        deal2.Approver_1__c = user1.Id;
        TestingUtility.insertWithAssert(deal2);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(deal1);
        DealsController dealCtrlObj = new DealsController(stdController);
        System.assertEquals(2, dealCtrlObj.getDeals().size());  
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController([SELECT Id FROM Deal__c Limit 1]);
        dealCtrlObj = new DealsController(stdSetController);
        System.assertEquals(1, dealCtrlObj.getDeals().size());
    }
}