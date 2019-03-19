/* Created By : Krishana Tupe
* Date : 21-Dec-2017
* Issue : ST-1737
* Comment : Delete all "Resolved" exception that are created before 30 days.
*/
global class PurgeResolvedExceptionBatch  implements Database.Batchable<SObject>,Schedulable,Database.Stateful {    
    Setting__c purgeResolvedExceptionSetting = Settings.get('PurgeResolvedException');
    purgeResolvedExceptionSettings objSetting = new purgeResolvedExceptionSettings();
    Map<String,String> mapPurgeSetting = new Map<String,String>();
    List<String> lstEmailAddresses = new List<String>();
    static Set<String> setMessages = new Set<String>();
    static String Status;
    static String query;
    global PurgeResolvedExceptionBatch(){  
        if(purgeResolvedExceptionSetting!=null){
            objSetting = (purgeResolvedExceptionSettings)JSON.deserialize(purgeResolvedExceptionSetting.Data__c.toLowerCase(),purgeResolvedExceptionSettings.class);  
            mapPurgeSetting = objSetting.criterias;
            lstEmailAddresses = objSetting.emails;
            if(objSetting.messages!=null){
                setMessages = objSetting.messages;
            }
            Status = mapPurgeSetting.get('status') != null ? mapPurgeSetting.get('status') : 'resolved';
        } 
    }
    global void execute(SchedulableContext SC) {
        PurgeResolvedExceptionBatch purgeExceptionBatch = new PurgeResolvedExceptionBatch();
        //For daily 11:59 PM
        String CRON_EXP = '0 59 23 * * ? *';
        String jobId = System.schedule('Purge Resolved Exception Batch',CRON_EXP,purgeExceptionBatch);       
    } 
    
    global Database.QueryLocator start(Database.BatchableContext context) {        
        Integer days = mapPurgeSetting.get('no of days before') != null ? Integer.valueOf(mapPurgeSetting.get('no of days before')) : 30;
        DateTime lastDate = System.now().addDays(-days);
        Debug.log('lastDate==>'+lastDate);
        Debug.log('days==>'+days);
        Debug.log('Status==>'+Status);
        debug.log('objSetting==>'+objSetting);
        if(!setMessages.isEmpty()){
            query = 'SELECT Id,Name,Status__c,CreatedDate,Message__c FROM Apex_Debug_Log__c WHERE Message__c IN : setMessages AND createdDate < : lastDate AND Status__c =: Status ORDER BY CreatedDate DESC';  
        }else{
            query = 'SELECT Id,Name,Status__c,CreatedDate,Message__c FROM Apex_Debug_Log__c WHERE createdDate < : lastDate AND Status__c =: Status ORDER BY CreatedDate DESC'; 
        }        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Apex_Debug_Log__c> records) {
        debug.log('Records==>'+records);
        List<Id> lstApexDebugLogIds = new List<Id>();        
        for(Apex_Debug_Log__c logRecord :records){  
            debug.log('logRecord status==>'+(String)logRecord.Status__c.toLowerCase());
            debug.log('Setting status==>'+Status);
            if(!setMessages.isEmpty()){
                if((String)logRecord.Status__c.toLowerCase() == Status && setMessages.contains(((String)logRecord.Message__c.toLowerCase()))){                
                    lstApexDebugLogIds.add(logRecord.Id);
                }    
            }else{
                if((String)logRecord.Status__c.toLowerCase() == Status ){                
                    lstApexDebugLogIds.add(logRecord.Id);
                }   
            }           
        }
        debug.log('lstApexDebugLogIds To Delete==>'+lstApexDebugLogIds);
        if(lstApexDebugLogIds.size() > 0){
            Database.delete(lstApexDebugLogIds,FALSE);            
        }
    }	
    global void finish(Database.BatchableContext context){
       if(lstEmailAddresses.size()>0){
            AsyncApexJob a = [SELECT Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:context.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses =lstEmailAddresses;
            mail.setToAddresses(toAddresses);
            mail.setSubject('Purge Resolved Exception Batch Status :: ' + a.Status);
            mail.setPlainTextBody('Records Processed ' + a.TotalJobItems +   ' With '+ a.NumberOfErrors + ' Failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
        }
    }
    global class purgeResolvedExceptionSettings{
        List<String> emails;
        Map<String,String> criterias;
        set<String> messages;
    }
}