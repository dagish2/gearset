@isTest
public class MergedAccountsTest {
    static{
        SalesConsoleSettings.createSettings();      
    }
    public static testMethod void verifyBatch(){
        TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
        triggerSetting.Account_CreateMergedAccounts = false;
        insert new Account(Name='Test Account',UUID__c='xcbjhdbcshjsd');
        Test.startTest();
        Database.executeBatch(new MergedAccountsBatch());
        Test.stopTest();
        triggerSetting.Account_CreateMergedAccounts = true;
    }
}