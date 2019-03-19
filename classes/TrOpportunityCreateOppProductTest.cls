/************************************************************************************************************************************
    Author      :   Pragalbha Mahajan
    Description :   This class contains all test methods related to OpportunityLineItemTriggerHandler class.
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           08 March 2018       Pragalbha Mahajan       Initial Development
************************************************************************************************************************************/
@isTest
public class TrOpportunityCreateOppProductTest {
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to setup test data
        Created Date        :   15 November 2018
        Issue No            :   ST-3076
    ******************************************************************************************************************************************/
	@testSetup 
    static void setup() {
        SalesConsoleSettings.createSettings();
		TestingUtility.createAllWeWorkProducts(true);
        String recTypeComsumerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
        String recTypeMidMarketId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mid_Market').getRecordTypeId();
        String recTypeEnterpriseId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise_Solutions').getRecordTypeId();
        
        List<Account> lstAccounts = new List<Account>();
        Map<String, Object> accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName1',
            'Account_Type__c' => 'Org',
            'RecordTypeId' => recTypeComsumerId,
            'Unomy_Location_Country__c' => 'Australia'};
        lstAccounts.addAll(TestingUtility.getAccountsByType(accountValuesMap, 'Org', 1));
        
        accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName2',
            'Account_Type__c' => 'Org',
            'RecordTypeId' => recTypeMidMarketId};     
        lstAccounts.addAll(TestingUtility.getAccountsByType(accountValuesMap, 'Org', 1));
        
        accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName3',
            'Account_Type__c' => 'Org',
            'RecordTypeId' => recTypeEnterpriseId};     
        lstAccounts.addAll(TestingUtility.getAccountsByType(accountValuesMap, 'Org', 1));
        TestingUtility.insertListWithAssert(lstAccounts);
        
        List<Contact> lstContacts = new List<Contact>();
        Map<String, Object> contactValuesMap = new Map<String, Object>{'FirstName' => 'John',
                'LastName' => 'Smith1',
                'Email' => 'john.smith1@example.com',
                'AccountId' => lstAccounts[0].Id };
        lstContacts.add((Contact)TestingUtility.createTestRecords(Contact.sObjectType, contactValuesMap, false));
        TestingUtility.insertListWithAssert(lstContacts);
    }     
    
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to test createOpportunityProduct method
        Created Date        :   15 November 2018
        Issue No            :   ST-3076
    ******************************************************************************************************************************************/
    public static testMethod void verifyCreateOpportunityProduct(){
        List<Account> lstAccount = [SELECT Id, Name, RecordTypeId, Unomy_Location_Country__c FROM Account];
        List<Contact> lstContact = [Select Id, Name, Interested_in_Number_of_Desks__c from Contact];
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        
        List<Opportunity> lstOpps = new List<Opportunity>();
        Map<String, Object> opportunityValuesMap = new Map<String, Object>{'Name' => 'test oppty1', 
            																'StageName' => 'Qualifying',
            																'Interested_in_Number_of_Desks__c' => 10};
        opportunityValuesMap = getOpportunityMapValues(opportunityValuesMap, oppRecordType.get('Consumer'), lstContact[0].Id, lstAccount[0].Id);
        Opportunity oppRec1 = (Opportunity)TestingUtility.createTestRecords(Opportunity.sObjectType, opportunityValuesMap, false);
        lstOpps.add(oppRec1);
        opportunityValuesMap.put('Interested_in_Number_of_Desks__c', null);
        OpportunityValuesMap = getOpportunityMapValues(opportunityValuesMap, oppRecordType.get('Mid Market'), lstContact[0].Id, lstAccount[1].Id);
        Opportunity opp2 = (Opportunity)TestingUtility.createTestRecords(Opportunity.sObjectType, opportunityValuesMap, false);
        lstOpps.add(opp2);
        opportunityValuesMap = getOpportunityMapValues(opportunityValuesMap, oppRecordType.get('Enterprise Solutions'), lstContact[0].Id, lstAccount[2].Id);
        Opportunity opp3 = (Opportunity)TestingUtility.createTestRecords(Opportunity.sObjectType, opportunityValuesMap, false);
        lstOpps.add(opp3);
        TestingUtility.insertListWithAssert(lstOpps);
        
        List<Opportunity> lstInsertedOppWithOLI = [SELECT Id, Name, Interested_in_Number_of_Desks__c, Company_Size__c, RecordType.Name, RecordTypeId, (Select Id,Quantity from OpportunityLineItems) FROM Opportunity WHERE Id IN : lstOpps];
        for(Opportunity objOpp: lstInsertedOppWithOLI){
            if(objOpp.RecordType.Name != 'Enterprise Solutions'){
                System.assert(objOpp.OpportunityLineItems.size() > 0, 'Opportunity Product not created');
            }else{
                System.assert(objOpp.OpportunityLineItems.size() == 0, 'Opportunity Product is created');
            }
        }
    }
    
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to map values to Opportunuity
        Created Date        :   15 November 2018
        Issue No            :   ST-3076
    ******************************************************************************************************************************************/
    public static Map<String, Object> getOpportunityMapValues(Map<String, Object> mapOppValues, Id recordTypeId, Id contactId, Id accountId){
        mapOppValues.put('Primary_Member__c', contactId);
        mapOppValues.put('RecordTypeId', recordTypeId);
        mapOppValues.put('AccountId', accountId);
        return mapOppValues;
    }
}