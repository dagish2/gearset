/************************************************************************************************************************************
    Author      :   Nikhil Mehta
    Description :   This class contains test methods for OpportunityReferralStatusControllerTest functionality
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR              DETAIL
    1           29 Oct 2018         Nikhil Mehta      	Initial Developement
**************************************************************************************************************************************/
@isTest
public class OpportunityReferralStatusControllerTest {
@TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        Map<String, RecordTypeInfo> mapRecordTypeOfAccount = Schema.SObjectType.Account.getRecordTypeInfosByName();
        List<Account> lstAccounts = TestingUtility.createAccounts( 1, 'WeWork', false);
        lstAccounts[0].RecordTypeId = mapRecordTypeOfAccount.get('Enterprise Solutions').getRecordTypeId();
        TestingUtility.insertListWithAssert(lstAccounts);
        
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(TestingUtility.createContact(new Map<String, Object>{'FirstName' => 'Paul','LastName' => 'enterpriseBoss', 'Email' => 'paul@enterpriseBoss.com', 'AccountId' => lstAccounts[0].Id, 'UUID__c' => 'xxx123'}, false));
        TestingUtility.insertListWithAssert(lstContacts);
        
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        lstOpportunities.add(TestingUtility.createOpportunity(new Map<String, Object>{'Name' => 'Enterprise Opportunity1','Primary_Member__c' => lstContacts[0].Id, 'AccountId' => lstAccounts[0].Id, 'closeDate' => System.today(), 'Contract_Stage__c' => 'Contract Sent'}, false));
        lstOpportunities[0].StageName = 'Selling';
        TestingUtility.insertListWithAssert(lstOpportunities);
    }
    /****************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method is used to test getOpprtunityData.
        Created Date        : 29 Oct 2018
		Issue No			: ST-2858
   *****************************************************************************************************************************/    
    static testMethod void verifyGetOpprtunityData(){
        List<Contact> lstContact = [SELECT Id, (SELECT Id FROM Opportunities) FROM Contact WHERE Email = 'paul@enterpriseBoss.com'];
        if(!lstContact.isEmpty()){
            DatabaseResult result = OpportunityReferralStatusController.getOpprtunityData(lstContact[0].Opportunities[0].Id);
            Map<String, sObject> mapData = (Map<String, sObject>)JSON.deserialize(JSON.serialize(result.data), Map<String, sObject>.class);
            System.assert(mapData != null);
        }
    }
}