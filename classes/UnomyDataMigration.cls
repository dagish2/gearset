global class UnomyDataMigration implements Database.Batchable<sObject>{
    global final String Query;
    global final Map<String, String> fieldValues;
    global UnomyDataMigration(String q, Map<String, String> fieldValues){
        this.Query = q;
        this.fieldValues = fieldValues;
  }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){  
        for(sobject s : scope){
            for(String fldName : fieldValues.keySet()) {
                s.put(fldName, fieldValues.get(fldName));
            }
        }
        
        update scope;
    }
    global void finish(Database.BatchableContext BC){  
        
    }
}