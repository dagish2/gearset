@isTest
public class MergeOpportunityControllerTest {
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        Map<String,Object> mapRecordValues = new Map<String,Object>();
        List<Account> lstAccounts = new List<Account>();
        mapRecordValues.put('Name', 'Test Org 1');
        lstAccounts.add(TestingUtility.createAccount(mapRecordValues,false));
        mapRecordValues.clear();
        List<Contact> lstContact = new List<Contact>();
        mapRecordValues.clear();
        mapRecordValues.put('LastName','Primary Contact');
        mapRecordValues.put('AccountId',lstAccounts[0].Id);
        lstContact.add(TestingUtility.createContact(mapRecordValues, false));
        TestingUtility.insertListWithAssert(lstContact);
        mapRecordValues.clear();
        //Building 
        mapRecordValues.put('Name','Enzigma');
        mapRecordValues.put('CurrencyIsoCode','INR');
        mapRecordValues.put('Address__c','Banner');
        mapRecordValues.put('City__c','Pune');
        mapRecordValues.put('UUID__c','4eb8144b-f461-4849-8b81-b5fa344fb978');
        TestingUtility.createBuilding(mapRecordValues, true);
        List<Building__c> lstBuilding = [SELECT Id,Name FROM Building__c WHERE UUID__c = '4eb8144b-f461-4849-8b81-b5fa344fb978'];
        //Opportunity 1
        mapRecordValues.clear();
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        mapRecordValues.put('Name', 'Test Opp 2');
        mapRecordValues.put('StageName', 'Selling');
        mapRecordValues.put('CloseDate', system.today().addDays(5));
        mapRecordValues.put('AccountId', lstAccounts[0].Id);
        mapRecordValues.put('Primary_Member__c', lstContact[0].Id);
        mapRecordValues.put('Locations_Interested__c', lstBuilding[0].Id);
        lstOpportunities.add(TestingUtility.createOpportunity(mapRecordValues, false));
        mapRecordValues.clear();
        //Opportunity 2
        mapRecordValues.put('Name', 'Test Opp 1');
        mapRecordValues.put('AccountId', lstAccounts[0].Id);
        mapRecordValues.put('StageName', 'Qualifying');
        mapRecordValues.put('CloseDate', system.today());
        mapRecordValues.put('Locations_Interested__c', lstBuilding[0].Id);
        mapRecordValues.put('Primary_Member__c', lstContact[0].Id);
        lstOpportunities.add(TestingUtility.createOpportunity(mapRecordValues, false));
        TestingUtility.insertListWithAssert(lstOpportunities);
        mapRecordValues.clear();
        
    }
    static testMethod void verifyMergeOpportunities(){
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity LIMIT 2];
        List<Id> lstIds = new List<Id>();
        lstIds.add(lstOpp[0].Id);
        lstIds.add(lstOpp[1].Id);
        String mergeOppIds = JSON.serialize(lstIds);
        DatabaseResult result = MergeOpportunityController.mergeOpportunities(mergeOppIds,(String)lstOpp[0].Id);
        System.assertEquals(true, result.data);
         
        DatabaseResult result1 = MergeOpportunityController.mergeOpportunities(null,null);
        System.assertEquals(false, result1.success);
        
        DatabaseResult result2 = MergeOpportunityController.getMergeOpportunitySettings();
        System.assertEquals(true, result2.success);
    }
}