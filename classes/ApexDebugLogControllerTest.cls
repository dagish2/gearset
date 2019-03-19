/************************************************************************************************************************************
Author 		: Roshan Kankrayane
Description : Test class for ApexDebugLogController which is use in ApexDebugLog Lightining Component .

History:
----------------------------------------------------------------------------------------------------------------------------------
VERSION		DATE				AUTHOR					DETAIL
1			02 Mar 2019			Roshan Kankrayane    	Initial Developement.
**************************************************************************************************************************************/
@isTest
public class ApexDebugLogControllerTest {
    /************************************************************************************************************************************
Author         : Roshan Kankrayane
Description    : This method is used to test getDebugLog function.
Created Date   : 02 Fed 2019 
Issue No       :  
**************************************************************************************************************************************/
    public static testMethod void getDebugLogTest() {
        string startTime = '11:00';
        string startDate = '2019-02-20';
        string endTime = '11:00';
        string endDate = '2022-05-31';
        string estimatedfix = 'Hotfix';
        String stackTrace='LeadTrigger';
        DatabaseResult result = ApexDebugLogController.getDebugLog(startDate,endDate,startTime,endTime,null,null,null,null,null,null);
        System.assertEquals(true,result.success);
        DatabaseResult result1 = ApexDebugLogController.getDebugLog(startDate,endDate,startTime,endTime,estimatedfix,null,null,null,null,stackTrace);
        System.assertNotEquals(null,result1);
        DatabaseResult result2 = ApexDebugLogController.getDebugLog(null,null,null,null,null,null,null,null,null,null);
        System.assertEquals(null,result2.data);
    }
    /************************************************************************************************************************************
Author         : Roshan Kankrayane
Description    :This method is used to test setFeildOfDebugLog function.
Created Date   : 02 Fed 2019 
Issue No       :  
**************************************************************************************************************************************/
    public static testMethod void setFeildOfDebugLogTest() {
        List<Apex_Debug_Log__c> lstApexDebugLog = new List<Apex_Debug_Log__c>();
        lstApexDebugLog.add(new Apex_Debug_Log__c(Estimated_Fix__c = 'Hotfix')); 
        lstApexDebugLog.add(new Apex_Debug_Log__c(Estimated_Fix__c = 'Hotfix'));
        Database.insert(lstApexDebugLog);
        string estimatedfix = 'Data Issue';
        string findingsandobservations = 'Lead Trigger';
        string exceptioncategory = 'Business Rule';
        string status = 'Open';
        string resolutionstepsanddetails = 'Lead Helper';
        List<id> lstId = new List<id>();
        for(Apex_Debug_Log__c ObjApexDebugLog : [SELECT Id FROM Apex_Debug_Log__c WHERE Estimated_Fix__c='Hotfix']){
            lstId.add(ObjApexDebugLog.id);
        }
        String result = ApexDebugLogController.setFeildOfDebugLog(estimatedfix, findingsandobservations, exceptioncategory, status, resolutionstepsanddetails, lstId);
        System.assertEquals('SUCCESS',result);
        String result1 = ApexDebugLogController.setFeildOfDebugLog(estimatedfix, findingsandobservations, exceptioncategory, status, resolutionstepsanddetails, null);
        System.assertEquals('ERROR',result1);
    }    
}