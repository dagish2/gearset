/************************************************************************************************************************************
    Author      :   Krishana Tupe
    Description :   This class contains business logic for LogExceptionTriggers

    History : 
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                      DETAIL
    1           02 May 2018         Krishana Tupe               Initial development
**************************************************************************************************************************************/
public without sharing class LogExceptionTriggerHandler extends ITriggerHandler{    
    public LogExceptionTriggerHandler(){
        super('Log_Exception__e');
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method overrides after insert method from ITriggerHander which will control the execution flow.
        Last Modified Date  :   02 May 2018
    **************************************************************************************************************************************/ 
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){
        Debug.log('In After Insert TriggerHandler listNewItems==>'+listNewItems);
        insertApexDebugLog(listNewItems, mapNewItems);
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   Insert Apex debug log whenever exception occurred.
        Last Modified Date  :   02 May 2018
    **************************************************************************************************************************************/
    public static void insertApexDebugLog(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){
        if(TriggerSettings.mappedField.LogException_InsertApexDebugLog){
            try{
                Datetime myDateTime = datetime.now().addSeconds(-30);   
                Map<Id, ApexLog> mapDebugLogs = new Map<Id,ApexLog>([Select Id,StartTime FROM ApexLog WHERE StartTime >=: myDateTime order by StartTime LIMIT 10]);
                Debug.log('mapDebugLogs==>'+mapDebugLogs);                
                List<Apex_Debug_Log__c> lstLogsTobeCreated = new List<Apex_Debug_Log__c>();
                List<Id> lstIds = new List<Id>();
                if(mapDebugLogs != null){
                    lstIds.addAll(mapDebugLogs.keySet());
                }     
                Debug.log('lstIds==>'+lstIds);
                for (LogException__e event : (List<LogException__e>)listNewItems) { 
                    Debug.log('event in log Exception==>'+event);                    
                    Apex_Debug_Log__c apexDebuglog = new Apex_Debug_Log__c(                       
                        ReplayId__c             =  event.ReplayId,
                        OwnerId                 =  event.Login_UserId__c,
                        Type__c                 = 'Error',
                        Apex_Class__c           =  event.Apex_Class__c,
                        Method__c               =  event.Method__c,
                        Record_Id__c            =  event.Record__c,
                        Login_User_ProfileId__c =  event.Login_User_ProfileId__c,
                        Login_UserId__c         =  event.Login_UserId__c,
                        Message__c              =  event.Message__c,
                        Stack_Trace__c          =  event.Stack_Trace__c,
                        ErrorLineNumber__c      =  Integer.valueOf(event.ErrorLineNumber__c),
                        ExceptionTypeName__c    =  event.ExceptionTypeName__c,
                        ApexLogId__c            =  (lstIds != null && lstIds.size()>0) ? String.join(lstIds, ','):'',
                        InstanceName__c         =  event.InstanceName__c
                    );
                    lstLogsTobeCreated.add(apexDebuglog);
                    Debug.Log('Before record to Insert==>'+lstLogsTobeCreated);
                               
                } 
                if(lstLogsTobeCreated.size() > 0){                       
                        Database.SaveResult [] results = Database.insert(lstLogsTobeCreated, false);
                        debug.log('After record insert result==>'+results);
                        if (!test.isRunningTest() && [SELECT Is_Active__c  FROM Integration_Data__mdt  WHERE DeveloperName = :'RollBar' LIMIT 1].Is_Active__c )
                            ID jobID = System.enqueueJob(new QueueRollbarItemSubmit());
                      
                    }     
            }catch(Exception ex){                
                Debug.log('Something fatal has occurred and hence failed to create a Log. Error:' + ex.getMessage());      
            }  
        }
    }
}