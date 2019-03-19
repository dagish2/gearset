/************************************************************************************************************************************
Author : Amol Darekar  
Description : This class should contain all test methods related to DealsTriggerHandler class.

History:
----------------------------------------------------------------------------------------------------------------------------------
VERSION					DATE					AUTHOR							DETAIL
1						13 May 2016		   	Amol Darekar             		Initial Developement
**************************************************************************************************************************************/
@isTest
public class DealsTriggerHandlerTest {
    
/************************************************************************************************************************************
	Author 				: Amol Darekar
	Description 		: This test method is used to verify DealsHandler.
	Created Date		: 13 May 2016	
**************************************************************************************************************************************/ 
    static testMethod void testDealsHandler(){  	    
        Triggers__c triggers = new Triggers__c(Deals_Set_Closed_Deal_Status_To_Blank__c= true);
        insert triggers;
        
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
        
        deal1.Status__c = 'Closed';
        TestingUtility.updateWithAssert(deal1);
        
        deal1.Status__c = 'Pencils Down';
        TestingUtility.updateWithAssert(deal1);
    }
}