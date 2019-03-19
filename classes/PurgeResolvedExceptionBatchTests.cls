/* Created By : Krishana Tupe
* Date : 21-Dec-2017
* Issue : ST-1737
* Comment : verify Delete all "Resolved" exception that are created before 30 days.
*/
@isTest
public class PurgeResolvedExceptionBatchTests {
    static{
        SalesConsoleSettings.createSettings();
    }
    public static testmethod void testPurgeResolvedExceptionBatchBeforeDays(){
        List<Apex_Debug_Log__c> lstlogs = new List<Apex_Debug_Log__c>();
        lstlogs.add(new Apex_Debug_Log__c(Apex_Class__c='Test Class1',Method__c='Test Method1',Status__c='resolved',Type__c='Warning',	Message__c='Attempt to de-reference a null object'));
        lstlogs.add(new Apex_Debug_Log__c(Apex_Class__c='Test Class2',Method__c='Test Method2',Status__c='Open',Type__c='Error',	Message__c='Attempt to de-reference a null object'));
        lstlogs.add(new Apex_Debug_Log__c(Apex_Class__c='Test Class3',Method__c='Test Method3',Status__c='resolved',Type__c='Warning',	Message__c='Attempt to de-reference a null object'));
        lstlogs.add(new Apex_Debug_Log__c(Apex_Class__c='Test Class4',Method__c='Test Method4',Status__c='Open',Type__c='Error',	Message__c='Krishana Test'));
        lstlogs.add(new Apex_Debug_Log__c(Apex_Class__c='Test Class5',Method__c='Test Method5',Status__c='resolved',Type__c='Warning',	Message__c='Krishana Test'));
        lstlogs.add(new Apex_Debug_Log__c(Apex_Class__c='Test Class6',Method__c='Test Method6',Status__c='resolved',Type__c='Error',	Message__c='Krishana Test'));
        lstlogs.add(new Apex_Debug_Log__c(Apex_Class__c='Test Class7',Method__c='Test Method7',Status__c='resolved',Type__c='Warning',	Message__c='Attempt to de-reference a null object'));
        lstlogs.add(new Apex_Debug_Log__c(Apex_Class__c='Test Class6',Method__c='Test Method8',Status__c='Open',Type__c='Error',	Message__c='Attempt to de-reference a null object'));
        lstlogs.add(new Apex_Debug_Log__c(Apex_Class__c='Test Class9',Method__c='Test Method9',Status__c='In Progress',Type__c='Warning',	Message__c='Krishana Test'));
        lstlogs.add(new Apex_Debug_Log__c(Apex_Class__c='Test Class10',Method__c='Test Method10',Status__c='Open',Type__c='Error',	Message__c='Krishana Test'));
        
        insert lstlogs;
        Datetime days = Datetime.now().addDays(-40);
        Test.setCreatedDate(lstlogs[0].Id, days);
        Test.setCreatedDate(lstlogs[1].Id, days);
        Test.setCreatedDate(lstlogs[8].Id, days);
        
        List<Apex_Debug_Log__c> lstlogsdata=[SELECT Id,Name,CreatedDate,Apex_Class__c,Status__c,Type__c,Message__c FROM Apex_Debug_Log__c order by CreatedDate LIMIT 100];
        debug.log('lstlogsdata==>'+lstlogsdata);
        Test.startTest();        
        Database.executeBatch(new PurgeResolvedExceptionBatch(),1);
        Test.stopTest();
        List<Apex_Debug_Log__c> lstlogsdataAfterBatchExecution=[SELECT Id,Name,CreatedDate,Apex_Class__c,Status__c,Type__c,Message__c FROM Apex_Debug_Log__c order by CreatedDate LIMIT 100];
        debug.log('lstlogsdata After Batch Execution==>'+lstlogsdataAfterBatchExecution);
        System.assertEquals(9,lstlogsdataAfterBatchExecution.size(), 'Apex Logs Should be only 9 record===>');
        System.assertEquals('Open',lstlogsdataAfterBatchExecution[0].Status__c, 'Apex Logs record status should be Open====>');
    } 
    public static testmethod void testPurgeResolvedExceptionBatchforWithinDays(){
        List<Apex_Debug_Log__c> lstlogs = new List<Apex_Debug_Log__c>();
        lstlogs.add(new Apex_Debug_Log__c(Apex_Class__c='Test Class1',Method__c='Test Method1',Status__c='resolved',Type__c='Warning',	Message__c='Attempt to de-reference a null object'));
        lstlogs.add(new Apex_Debug_Log__c(Apex_Class__c='Test Class2',Method__c='Test Method2',Status__c='Open',Type__c='Error',	Message__c='Krishana Test'));
        
        insert lstlogs;
        Datetime days = Datetime.now().addDays(-10);
        Test.setCreatedDate(lstlogs[0].Id, days);
        Test.setCreatedDate(lstlogs[1].Id, days);
        List<Apex_Debug_Log__c> lstlogsdata=[SELECT Id,Name,CreatedDate,Apex_Class__c,Status__c,Type__c,Message__c FROM Apex_Debug_Log__c order by CreatedDate LIMIT 100];
        debug.log('lstlogsdata==>'+lstlogsdata);
        Test.startTest();        
        Database.executeBatch(new PurgeResolvedExceptionBatch(),1);
        Test.stopTest();
        List<Apex_Debug_Log__c> lstlogsdataAfterBatchExecution=[SELECT Id,Name,CreatedDate,Apex_Class__c,Status__c,Type__c,Message__c FROM Apex_Debug_Log__c order by CreatedDate LIMIT 100];
        debug.log('lstlogsdata After Batch Execution==>'+lstlogsdataAfterBatchExecution);
        System.assertEquals(2,lstlogsdataAfterBatchExecution.size(), 'Apex Logs Should be only 2 record');
        System.assertEquals('Resolved',lstlogsdataAfterBatchExecution[0].Status__c, 'Apex Logs record status should be Resolved');
        System.assertEquals('Open',lstlogsdataAfterBatchExecution[1].Status__c, 'Apex Logs record status should be Open');
    } 
}