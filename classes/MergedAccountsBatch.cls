global class MergedAccountsBatch implements database.Batchable<sObject> {
    global Database.Querylocator start(Database.BatchableContext bc){
        String query='Select Id,UUID__c from Account Where Id Not IN (Select Account__c from Merged_Account__c)';
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc , List<Account> scope) {
        List<Merged_Account__c> mergedAccounts = new List<Merged_Account__c>();
        for(Account acc :scope){
            mergedAccounts.add(new Merged_Account__c(Account__c=acc.Id,Merged_Account_UUID__c=acc.UUID__c));
        }
        insert mergedAccounts;       
    }
    global void finish(Database.BatchableContext bc) {    }
}