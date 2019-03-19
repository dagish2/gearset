/************************************************************************************************************************************
    Author      :   Milanjeet Singh
    Description :   This class is the test class to cover all the exception handling in trigger dispatcher class

    History :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                     DETAIL
    1           22 Oct 2018        Milanjeet Singh            Initial Developement
**************************************************************************************************************************************/
@isTest
public class RESTApiLogTriggerHandlerTest {
    @TestSetup
    public static void testSetup(){
        SalesConsoleSettings.createSettings();  
    }
    
     /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method is to create exception in before insert context and will be manage in trigger dispatcher class
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/   
    public static testmethod void verifyHandleBeforeInsert(){
        try{
          TriggerSettings.setRestApiLog_BeforeInsertException(true);
          insertRestApiLog();  
        }catch(Exception ex){}       
    }
    
     /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method is to create exception in after insert context and will be manage in trigger dispatcher class
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/       
    public static testmethod void verifyHandleAfterInsert(){
        try{
          TriggerSettings.setRestApiLog_BeforeInsertException(false);
          TriggerSettings.setRestApiLog_AfterInsertException(true);
          insertRestApiLog();  
        }catch(Exception ex){}       
    }
    
     /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method is to create exception in before update context and will be manage in trigger dispatcher class
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/       
    public static testmethod void verifyHandleBeforeUpdate(){
        try{
          TriggerSettings.setRestApiLogTriggerSettings(false);
          insertRestApiLog();
          ApexDebugLog.currentInvoker = null;
          List<Rest_API_Log__c> lstRest = new List<REST_API_Log__c>([SELECT Id FROM REST_API_Log__c WHERE Name = 'Test Api Log']);
          system.assertEquals(1, lstRest.size());
          TriggerSettings.setRestApiLog_BeforeUpdateException(true);
          update lstRest[0];
        }catch(Exception ex){}       
    }
    
     /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method is to create exception in after update context and will be manage in trigger dispatcher class
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/       
    public static testmethod void verifyHandleAfterUpdate(){
        try{
          TriggerSettings.setRestApiLogTriggerSettings(false);
          insertRestApiLog();
          ApexDebugLog.currentInvoker = null;
          List<Rest_API_Log__c> lstRest = new List<REST_API_Log__c>([SELECT Id FROM REST_API_Log__c WHERE Name = 'Test Api Log']);
          system.assertEquals(1, lstRest.size());
          TriggerSettings.setRestApiLog_AfterUpdateException(true);
          update lstRest[0];
        }catch(Exception ex){}       
    }
    
     /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method is to create exception in before delete context and will be manage in trigger dispatcher class
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/       
    public static testmethod void verifyHandleBeforeDelete(){
        List<Rest_API_Log__c> lstRest;
        try{
          TriggerSettings.setRestApiLogTriggerSettings(false);
          insertRestApiLog();
          ApexDebugLog.currentInvoker = null;
          lstRest = new List<REST_API_Log__c>([SELECT Id FROM REST_API_Log__c WHERE Name = 'Test Api Log']);
          system.assertEquals(1, lstRest.size());
          TriggerSettings.setRestApiLog_BeforeDeleteException(true);
          delete lstRest[0];
        }catch(Exception ex){
          TriggerSettings.setRestApiLogTriggerSettings(false);
          Debug.log('In Catch');
          delete lstRest[0];
        }       
    }
    
     /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method is to create exception in after delete context and will be manage in trigger dispatcher class
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/       
    public static testmethod void verifyHandleAfterDelete(){
        try{
          TriggerSettings.setRestApiLogTriggerSettings(false);
          insertRestApiLog();
          ApexDebugLog.currentInvoker = null;
          List<Rest_API_Log__c> lstRest = new List<REST_API_Log__c>([SELECT Id FROM REST_API_Log__c WHERE Name = 'Test Api Log']);
          system.assertEquals(1, lstRest.size());
          TriggerSettings.setRestApiLog_AfterDeleteException(true);
          delete lstRest[0];
          TriggerSettings.setRestApiLogTriggerSettings(false);
          TriggerSettings.setRestApiLog_UnDeleteException(true);
          undelete lstRest[0];
        }catch(Exception ex){}
    }
    
     /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method is to create exception in after undelete context and will be manage in trigger dispatcher class
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/       
    public static testmethod void verifyHandleAfterUnDelete(){
        try{
          TriggerSettings.setRestApiLogTriggerSettings(false);
          insertRestApiLog();
          ApexDebugLog.currentInvoker = null;
          List<Rest_API_Log__c> lstRest = new List<REST_API_Log__c>([SELECT Id FROM REST_API_Log__c WHERE Name = 'Test Api Log']);
          system.assertEquals(1, lstRest.size());
          delete lstRest[0];
          TriggerSettings.setRestApiLog_UnDeleteException(true);
          undelete lstRest[0];
        }catch(Exception ex){}
    }
    
     /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method is helper method to insert a record of REST_API_Log__c object and used in above handler methods 
        Last Modified Date  :   22 Oct 2018
    ************************************************************************************************************************************/   
    public static void insertRestApiLog(){
        Insert new REST_API_Log__c(Name='Test Api Log');
    }
}