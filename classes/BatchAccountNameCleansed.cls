/**
* @Created By   	: Mayuresh Ghodke
* @Created Date 	: 02-Aug-2017
* @Issue No.		: ST-1232 : Batch class wee call method cleaning Account Test Class name : BatchAccountNameCleansedTest
*/ 
global class BatchAccountNameCleansed implements Database.Batchable<SObject>{
    
    String sourceFieldName, destinationFieldName;
    
    public BatchAccountNameCleansed(String sourceFieldName, String destinationFieldName){
        this.sourceFieldName = sourceFieldName;
        this.destinationFieldName = destinationFieldName;
    }
    
    global Database.QueryLocator start(database.BatchableContext bc ){
        Debug.log('In  start : ');
        String query = 'SELECT Id, '+this.sourceFieldName+', '+this.destinationFieldName+' FROM Account WHERE '+this.sourceFieldName+' <> null AND '+this.destinationFieldName+' = null  ORDER BY CreatedDate asc';
        return Database.getQueryLocator(query);
    }
    global void execute (Database.BatchableContext bc, List<sObject> accRecords ){
        Debug.log('In  execute : ');
        for(sObject accRec : accRecords){
            accRec.put(this.destinationFieldName, AccountServices.createCleansedAccAndUnomyName(String.valueOf(accRec.get(this.sourceFieldName))));
            //if(String.valueOf(acc.get('Unomy_Company_Name__c')) != null)
            //accRec.put('Cleansed_Unomy_Company_Name__c',AccountServices.createCleansedAccAndUnomyName(String.valueOf(accRec.get('Unomy_Company_Name__c'))));
            Debug.log('acc to update :: '+accRec);
        }
        update accRecords;
        Debug.log('Update Scope : '+accRecords);
    }
    global void finish(Database.BatchableContext bc){
        Debug.log('In  finish : ');
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'mayuresh.ghodke@enzigma.in'};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Accounts updated ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }
}

//To Run this batch please run below script to developer console : 
//Id batjobId = Database.executeBatch(new BatchAccountNameCleansed('Unomy_Company_Name__c', 'Cleansed_Unomy_Company_Name__c'), 50);
//Debug.log('batjobId => '+batjobId);