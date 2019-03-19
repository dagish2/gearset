@isTest
public class UnomyDataMigrationTest {
    @TestSetup
    public static void dataSetup()
    {
        SalesConsoleSettings.createSettings();
        Lead lead = new Lead(           
            FirstName = 'Test', 
            LastName = 'Test',
            Company = 'Test',
            Email = 'Test1@example.com',
            LeadSource = 'Broker',
            Lead_Source_Detail__c = 'Broker1',
            Status = 'TestStatus',
            CurrencyIsoCode = 'USD',
            Number_of_Desks_2016__c = '2-5 desks',
            Unomy_Location_City__c='MUMBAI'
        );
        insert lead;
        Lead lead2 = new Lead(           
            FirstName = 'Test1', 
            LastName = 'Test1',
            Company = 'Test',
            Email = 'Test1@example.com',
            LeadSource = 'Broker',
            Lead_Source_Detail__c = 'Broker1',
            Status = 'TestStatus',
            CurrencyIsoCode = 'USD',
            Number_of_Desks_2016__c = '2-5 desks',
            Unomy_Location_City__c='Bangluru'
        );
        insert lead2;
    }
    
    @isTest
    public static void UpdateUnomyLoacationcity()
    {
        String q='SELECT Id,Unomy_Location_City__c From Lead LIMIT 10';
        Map<String,String>mapoffield=new Map<String,String>();
        mapoffield.put('Unomy_Location_City__c','');
        Test.startTest();
        Database.executeBatch(new UnomyDataMigration(q,mapoffield));
        Test.stopTest();
        List<Lead> lstlead=[Select Id,Name,Unomy_Location_City__c From Lead LIMIT 10 ];
        for(Lead l:lstlead)
        {
            System.assertEquals(l.Unomy_Location_City__c,null);
        }
        
    }
}