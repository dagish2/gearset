/************************************************************************************************************************************
    Author      :   Krishana Tupe   
    Description :   This Queueable class used to save exception into Rollbar.
    
    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           23 April 2018       Krishana Tupe           Initial Developement
    2           03 May 2018         Krishana Tupe           Chnages for exception logging.
**************************************************************************************************************************************/
public class QueueableForRollbarExceptionLog implements Queueable,Database.AllowsCallouts {
    String listRecordIds;
    String strClassName;
    String strMethodName;
    Exception ex; 
    List<Apex_Debug_Log__c> lstApexLogRecords;
    public QueueableForRollbarExceptionLog(){}
  /****************************************************************************************************************************
        Author              : Krishana Tupe
        Description         : This method used to initialize the exception records.
        Created Date        : 23 April 2018
        Last Modified By    : Krishana Tupe
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/ 
    public QueueableForRollbarExceptionLog(Exception pEx, String listRecordIds, String strClassName, String strMethodName){
        debug.log('In ExceptionLoggerQueueable==>');
        this.listRecordIds = listRecordIds;
        this.strClassName = strClassName;
        this.strMethodName = strMethodName;
        this.ex = pEx;        
    }
    public QueueableForRollbarExceptionLog(List<Apex_Debug_Log__c> lstApexLogRecords){        
        this.lstApexLogRecords = lstApexLogRecords;
        Debug.log(' End of ExceptionLoggerQueueable Constructor this.lstApexLogRecords==>'+this.lstApexLogRecords);
    }
    
   /****************************************************************************************************************************
        Author              : Krishana Tupe
        Description         : This method used to save/send the exception records to the rollbar.
        Created Date        : 23 April 2018
        Last Modified By    : Krishana Tupe
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    public void execute(QueueableContext context) {        
        Debug.log(' End of ExceptionLoggerQueueable Constructor this.lstApexLogRecords==>'+this.lstApexLogRecords);
        for(Apex_Debug_Log__c logRecord : lstApexLogRecords){
            String result = postToRollbar(logRecord);
            Debug.log('result==>'+result);           
        }
        
    }
    
    /****************************************************************************************************************************
        Author              : Krishana Tupe
        Description         : This method will callout to rollbar api to save the exception records into Rollbar project.
        Created Date        : 23 April 2018
        Last Modified By    : Krishana Tupe
        Last Modified Date  : 31,May 2018
    *****************************************************************************************************************************/
    public static string postToRollbar(Apex_Debug_Log__c logRecord){        
        Setting__c RollbarConfigSetting = Settings.get('RollbarConfig');
        Map<String,String> mapSettingData;
        if(RollbarConfigSetting != null){
            mapSettingData = (Map<String,String>)JSON.deserialize(RollbarConfigSetting.Data__c, Map<String,String>.class);  
        }
         Debug.log('mapSettingData==>'+mapSettingData);        
        String tempRecordString = logRecord.Record_Id__c; 
        String strRecord='';
        if(String.isNotBlank(tempRecordString)){
            strRecord += tempRecordString.replace('"', '\\"');     
        }        
        Debug.log('strRecord==>'+strRecord);        
        logRecord.Record_Id__c = strRecord;
        if(mapSettingData != null){
            String payload = '{"access_token":"'+(mapSettingData.containsKey('access-token') ? mapSettingData.get('access-token') : '')+'","data":{"environment":"'+(String.valueOf(logRecord.InstanceName__c)).replaceAll('\\s+', '')+'","body":{"message":{"body":"'+String.valueOf(logRecord)+'"}}}}';
            Debug.log('payload==>'+payload.replaceAll('\\s+', ''));
            
            RollbarWrapper objRollbarPayload = getRollbarPostPayload(payload.replaceAll('\\s+', ''));
            Debug.log('objRollbarPayload==>'+objRollbarPayload);
            
            String result =   ApexDebugLog.executeRest((mapSettingData.containsKey('URL') ? mapSettingData.get('URL') :'https://api.rollbar.com/api/1/item/'),JSON.serialize(objRollbarPayload));                        
            Debug.log('BeforeInsert result==>'+result);  
            return result;            
        }
        return null;
    } 
    
    /****************************************************************************************************************************
        Author              : Krishana Tupe
        Description         : This method will return the wrapper of rollbar payload.
        Created Date        : 23 April 2018
        Last Modified By    : Krishana Tupe
        Last Modified Date  : 31,May 2018
    *****************************************************************************************************************************/
    public static RollbarWrapper getRollbarPostPayload(String payload) {
        return (RollbarWrapper) System.JSON.deserialize(payload,RollbarWrapper.class);
    }
    
    public class RollbarWrapper {
        public String access_token;
        public Data data;   
    }
    public class Data {
        public String environment;
        public Body body;
    }
    
    public class Body {
        public Message message;
    }
    public class Message {
        public String body;
    }
}