/************************************************************************************************************************************
    Author     	: Sunil Bhosale  
    Description : update Longstanding Journeys
    Issue No 	: ST-1547

    History    	:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION    DATE        AUTHOR            DETAIL
    	1        	      Sunil Bhosale      Initial Developement
		2	14/11/2018    Jitesh Adwani		 Use the testing utility methods and change the according to the issue.
**************************************************************************************************************************************/
@isTest
public class BatchToForceFullyUpdateJourneysTest {
   @testSetup
    static void initData() {
        SalesConsoleSettings.createSettings();
        
        List<Journey__c> lstJourney = TestingUtility.getRecords(new Map<String, Object>{'objName'=>'journey', 'numberOfRecords'=>3});
        
        List<Journey__c> lstUpdateJourney = new List<Journey__c>();
        for(Journey__c objJourney : lstJourney){
            objJourney.NMD_Next_Contact_Date__c = Date.newInstance(2018, 10, 30);
        }
        TestingUtility.updateListWithAssert(lstJourney);
        
        TestingUtility.getRecords(new Map<String, Object>{'objName'=>'task', 'numberOfRecords'=>3});
        List<Task> lstTask = [SELECT Id, WhatId, Type, Status FROM Task];
        lstTask[0].WhatId = lstJourney[0].Id;
        lstTask[0].Type = 'Other';
        lstTask[1].WhatId = lstJourney[1].Id;
        lstTask[1].Type = 'Other';
        lstTask[1].Status = 'active';
        lstTask[1].ActivityDate = Date.today().addDays(-10);
        TestingUtility.updateListWithAssert(lstTask);
    }
    
/************************************************************************************************************************************
    Author         : Jitesh Adwani
    Description    : This method is used in BatchToForceFullyUpdateJournys to update the Journey.
    Created Date   : 14 Nov 2018 
    Issue No       : ST-3033
**************************************************************************************************************************************/
    static testMethod void testBatchToForceFullyUpdateJourneys(){
        List<Journey__c> lstJourneys = [SELECT Id FROM Journey__c];
        List<Task> lstTasks = [SELECT Id FROM Task];
        List<sObject> lstSoBject = new List<sObject>();
        
        //execute batch
 		List<Journey__c> lstJourneys2Update = new List<Journey__C>();
        List<Task> lstTasks2Update = new List<Task>();
        
        Test.setCreatedDate(lstJourneys[0].Id, DateTime.newInstance(2018, 9, 11));        
        lstJourneys2Update.add(lstJourneys[0]);
        Test.setCreatedDate(lstTasks[0].Id, Date.newInstance(2018, 9, 11));        
        lstTasks2Update.add(lstTasks[0]);
        
        Test.setCreatedDate(lstJourneys[1].Id, DateTime.newInstance(2018, 10, 10));
        lstJourneys2Update.add(lstJourneys[1]);		
        Test.setCreatedDate(lstTasks[1].Id, Date.newInstance(2018, 10, 14));        
        lstTasks2Update.add(lstTasks[1]);
        
        Test.setCreatedDate(lstTasks[2].id, Date.newInstance(2018, 10, 26));
        lstTasks2Update.add(lstTasks[2]);
        
       	Test.setCreatedDate(lstJourneys[2].ID, DateTime.newInstance(2018, 10, 29));
        lstJourneys2Update.add(lstJourneys[2]);
        lstsobject.addAll(lstJourneys2Update);
        lstsobject.addAll(lstTasks2Update);
        TestingUtility.updateListWithAssert(lstsobject);
        
        Test.startTest();      
        Database.executeBatch(new BatchToForceFullyUpdateJourneys());
        Test.stopTest();
        for(Journey__c objJourney : [SELECT Id, Status__c, IsAuto_Complete_Expiration__c, Auto_Complete_Expiration__c FROM Journey__c]){
            System.assert(String.isNotBlank(objJourney.Status__c)); 
            System.assert(objJourney.Status__c.equalsIgnoreCase('auto-complete/expiration'));
            System.assertEquals(true, objJourney.IsAuto_Complete_Expiration__c);            
        }
    }
}