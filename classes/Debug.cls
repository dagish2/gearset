public class Debug {
    public static void turnDebugOn(){
        Triggers__c triggers = Settings.getTriggerSettings();
        triggers.Debug__c = true;
        upsert triggers;
    }
    
    public static void Log(String strLog){
        Triggers__c triggers = Settings.getTriggerSettings();
        if( triggers.Debug__c ) 
        {
            System.debug(logginglevel.ERROR, strLog);
        }
    }

	public static void LogTrigger(String strName){
		Debug.Log( 'Trigger : ' + strName + ' : ' + (Trigger.isAfter ? 'after' : 'before') + ' ' + (Trigger.isInsert ? 'insert' : (Trigger.isUpdate ? 'update' : 'delete')));
	}
}