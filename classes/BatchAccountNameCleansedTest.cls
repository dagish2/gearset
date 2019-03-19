/**
* @Created By   	: Mayuresh Ghodke
* @Created Date 	: 02-Aug-2017
* @Issue No.		: ST-1232 : Batch class wee call method cleaning Account Class name : BatchAccountNameCleansed
*/ 
@isTest 
public class BatchAccountNameCleansedTest 
{
    @testSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
    }
    static testMethod void testData(){
        List<Account> lstAccount= new List<Account>();
        for(Integer i=0 ;i <10;i++){
            Account acc = new Account();
            acc.Name ='James Test'+i;
            acc.Unomy_Company_Name__c = 'Unomy_Company_Name__c Test'+i;
            lstAccount.add(acc);
        }
        Debug.log('Before insert...');
        insert lstAccount;
        Debug.log('after insert...');
        Test.startTest();
        Id batjobId1 = Database.executeBatch(new BatchAccountNameCleansed('Name', 'Cleansed_Account_Name__c'), 50);
        Debug.log('batjobId1 => '+batjobId1);	
        Id batjobId2 = Database.executeBatch(new BatchAccountNameCleansed('Unomy_Company_Name__c', 'Cleansed_Unomy_Company_Name__c'), 50);
        Debug.log('batjobId2 => '+batjobId2);	
        Test.stopTest();
        List<Account> lstAccount1= [Select Id, Name, Cleansed_Account_Name__c, Unomy_Company_Name__c, Cleansed_Unomy_Company_Name__c From account];
       // for(Account obj : lstAccount1){
        for(Integer i=0 ;i <lstAccount1.size();i++){
        	system.assertEquals(lstAccount1[i].Cleansed_Account_Name__c,'jamestest'+i);
        	system.assertEquals(lstAccount1[i].Cleansed_Unomy_Company_Name__c,'unomy_company_name__ctest'+i);
        }
        Debug.log('lstAccount1 => '+lstAccount1);
    }
}