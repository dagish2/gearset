/************************************************************************************************************************************
Author      :   Roshan Kankrayane    
Description :   This class contain all aura methods that are used in ApexDebugLog lightning components.
History     :
----------------------------------------------------------------------------------------------------------------------------------
VERSION     DATE                AUTHOR                  DETAIL
1           25 Feb 2019         Roshan Kankrayane       

**************************************************************************************************************************************/
public without sharing class ApexDebugLogController {
/****************************************************************************************************************************
Author              : Roshan Kankrayane
Description         : This method used to retrive Logs from Apex debug log. Used in apex debug Log Lightning component
Created Date        : 25,Feb 2019
Last Modified By    : 
Last Modified Date  : 
*****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getDebugLog(String startDate,String endDate,String startTime,String endTime, String estimatedfix,String exceptioncategory,String status,String method,String message,String stackTrace){
        try{
            String query;
            String[] arrOfStartDate = startDate.split('-');
            String[] arrOfStartTime = startTime.split(':');
            String[] arrOfendDate = endDate.split('-');
            String[] arrOfEndTime = endTime.split(':');
            DateTime startDateTime = DateTime.newInstance(Integer.valueOf(arrOfStartDate[0]), Integer.valueOf(arrOfStartDate[1]), Integer.valueOf(arrOfStartDate[2]), Integer.valueOf(arrOfStartTime[0]), Integer.valueOf(arrOfStartTime[1]), 0);
            DateTime endDateTime = DateTime.newInstance(Integer.valueOf(arrOfendDate[0]), Integer.valueOf(arrOfendDate[1]), Integer.valueOf(arrOfendDate[2]),Integer.valueOf(arrOfEndTime[0]), Integer.valueOf(arrOfEndTime[1]), 0);
            System.debug('startDateTime=='+startDateTime);
            System.debug('endDateTime=='+endDateTime);
            query = 'SELECT Id, Owner.name , Name, Status__c, Estimated_Fix__c, Exception_Category__c, Apex_Class__c, Method__c, Message__c,Stack_Trace__c,Notes_and_Comments__c,Resolution_Steps_and_Details__c FROM Apex_Debug_Log__c WHERE   CreatedDate >= :startDateTime AND CreatedDate <= :endDateTime' + (exceptioncategory != '' && exceptioncategory != null  ? ' AND Exception_Category__c = :exceptioncategory' : '') + (estimatedfix != '' && estimatedfix != null  ? ' AND Estimated_Fix__c = :estimatedfix' : '') + (status != '' && status != null  ? ' AND Status__c = :status' : '') + (method != '' && method != null  ? ' AND 	Method__c = :method' : '')+ (message != '' && message != null  ? ' AND Message__c LIKE \'%'+message+'%\' '  : '')+'  LIMIT 10000';
            System.debug('query::'+query);
            List<Apex_Debug_Log__c> lstApexLog = (List<Apex_Debug_Log__c>)Database.query(query);
             System.debug('lstApexLog'+lstApexLog);
            if(stackTrace!=null && stackTrace!=''){
                List<Apex_Debug_Log__c> lstRecord = new List<Apex_Debug_Log__c>();
                for(Apex_Debug_Log__c lstApexDebugLog :lstApexLog ) {
                    if(lstApexDebugLog.Stack_Trace__c.contains(stackTrace)) {
                        lstRecord.add(lstApexDebugLog);
                    }
                }
                return new DatabaseResult(lstRecord);
            }
            return new DatabaseResult(lstApexLog);
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'startDate==>'+startDate, 'LightningComponentController', 'getdebuglog');            
            return (new DatabaseResult(pEx));  
        } 
    }  
/****************************************************************************************************************************
Author              : Roshan Kankrayane
Description         : This method used to update the Record of Apex Debug log Object.
Created Date        : 28,Feb 2019
Last Modified By    : 
Last Modified Date  : 
*****************************************************************************************************************************/ 
    @AuraEnabled
    public static String setFeildOfDebugLog(String estimatedfix, String findingsandobservations, String exceptioncategory, String status, String resolutionstepsanddetails, List<String> lstOfSelectedRecord){
        try{
            List<Apex_Debug_Log__c> lstRecordToUpdate = new List<Apex_Debug_Log__c>();
            for(Apex_Debug_Log__c objApexDebugLog:[SELECT Id,Estimated_Fix__c,Notes_and_Comments__c,Exception_Category__c,Status__c,Resolution_Steps_and_Details__c FROM Apex_Debug_Log__c Where Id IN : lstOfSelectedRecord]){
                if(findingsandobservations != null && findingsandobservations != ''){
                    objApexDebugLog.Notes_and_Comments__c = findingsandobservations;
                }
                if(estimatedfix != null && estimatedfix != ''){
                    objApexDebugLog.Estimated_Fix__c = estimatedfix;  
                }
                if(exceptioncategory != null && exceptioncategory != ''){
                    objApexDebugLog.Exception_Category__c = exceptioncategory;
                }
                if(status != null && status != ''){
                    objApexDebugLog.Status__c = status; 
                }
                if(resolutionstepsanddetails != null && resolutionstepsanddetails != ''){
                    objApexDebugLog.Resolution_Steps_and_Details__c = resolutionstepsanddetails;
                }
                lstRecordToUpdate.add(objApexDebugLog);
            }
            System.debug('lstRecordToUpdate'+lstRecordToUpdate);
            if(lstRecordToUpdate.size()>0){
                update lstRecordToUpdate;
            }
            return('SUCCESS'); 
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'estimatedfix==>'+estimatedfix, 'LightningComponentController', 'setFeildOfDebugLog');            
            return('ERROR');  
        }    
    }
}