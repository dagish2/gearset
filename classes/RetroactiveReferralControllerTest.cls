/************************************************************************************************************************************
    Author      :  Nikhil Mehta    
    Description :  This class contain all test methods related to aura methods in RetroactiveReferralControllerTest.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR          		DETAIL
     1          18 Oct 2018       	Nikhil Mehta    	    Initial Developement
**************************************************************************************************************************************/
@isTest
public class RetroactiveReferralControllerTest {
    @testSetup
    static void setup(){
        SalesConsoleSettings.createSettings();
        List<Account> lstAccounts = new List<Account>();
        List<Contact> lstContacts = new List<Contact>();
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        List<User> lstUsers = new List<User>();
        List<Billing_Account__c> lstBillingAccount = new List<Billing_Account__c>();
        
        List<Profile> lstProfile = [SELECT Id FROM Profile WHERE Name IN ('WeWork System Administrator', 'WeWork NMD User')]; 
        Map<String, Object> mapUserValues = TestingUtility.getUserMapValues('Admin');
        lstUsers.add((User)TestingUtility.insertUserWithAssert(lstProfile[0].Id, mapUserValues, false));
        
        Map<String, Object> mapUserValues1 = TestingUtility.getUserMapValues('NMDUser');
        lstUsers.add((User)TestingUtility.insertUserWithAssert(lstProfile[1].Id, mapUserValues1, false));
        TestingUtility.insertListWithAssert(lstUsers);
        
        lstAccounts.add(new Account(Name = 'tesAccount1'));
        lstAccounts.add(new Account(Name = 'testAccountSaveConAccRecords2', Account_Type__c = 'Org', Unomy_Company_ID__c = 123456789,Unomy_Company_Name__c = 'Enzigma123'));
        TestingUtility.insertListWithAssert(lstAccounts);
        
        lstContacts.add(new Contact(firstName = 'John', lastName = 'Rambo', email = 'john@example.com', Type__c = 'Employee'));
        TestingUtility.insertListWithAssert(lstContacts);
        
        lstBillingAccount.add(new Billing_Account__c(Name = 'Test Billing Account1', Parent_Account__c = lstAccounts[0].Id, UUID__c = 'testAccountUUID1', Primary_Member__c = lstContacts[0].Id));
        TestingUtility.insertListWithAssert(lstBillingAccount);
        
        lstOpportunities.add(new Opportunity(name = 'test oppty1', AccountId = lstAccounts[0].Id, Billing_Account__c = lstBillingAccount[0].Id, Primary_Member__c = lstContacts[0].Id, stageName = 'Selling' ,closeDate = System.today()));
        lstOpportunities.add(new Opportunity(name = 'test oppty2', AccountId = lstAccounts[0].Id, Primary_Member__c = lstContacts[0].Id, stageName = 'Qualifying', closeDate = System.today()));
        lstOpportunities.add(new Opportunity(name = 'test oppty3', AccountId = lstAccounts[0].Id, Primary_Member__c = lstContacts[0].Id, stageName = 'Closed Lost', closeDate = System.today()));
        lstOpportunities.add(new Opportunity(name = 'test oppty4', AccountId = lstAccounts[0].Id, Primary_Member__c = lstContacts[0].Id, Referral_Status__c = 'Approved', stageName = 'Closed Won', closeDate = System.today()));
        
        TestingUtility.insertListWithAssert(lstOpportunities);        
    }
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method tests UpdateReferrerOnOpportunity method
        Created Date        :   01 November 2018
        Issue No            :   ST-2858
    ******************************************************************************************************************************************/
    public static testMethod void verifycheckValidation(){
        List<Opportunity> lstOpportunity = [SELECT Id, Name, StageName FROM Opportunity WHERE StageName = 'Selling' OR StageName = 'Qualifying' OR StageName = 'Closed Lost' OR StageName = 'Closed Won'];
        List<Contact> lstContact = [SELECT Id, Type__c FROM Contact];
        List<Account> lstAccounts = [SELECT id FROM Account];
        List<User> lstUsers = [SELECT id, Name FROM User WHERE Email = 'testUser_NMDUser@example.com'];
        
        List<Billing_Account__c> lstBillingAccount = [SELECT Id, Primary_Member__c FROM Billing_Account__c];
        String oppResultNull = RetroactiveReferralController.isValidForWebService(null);
        Debug.log('oppResultNull'+oppResultNull);
        System.assertEquals(null, (Map<String, Object>) JSON.deserializeUntyped(oppResultNull));
        
        String oppResult = RetroactiveReferralController.isValidForWebService(lstOpportunity[0].Id);
        System.assertEquals(true, Boolean.valueOf(((Map<String, Object>) JSON.deserializeUntyped(oppResult)).get('isValid')));
        
        DatabaseResult oppRecord = RetroactiveReferralController.initialize(lstOpportunity[0].Id);
        System.assertEquals(true, Boolean.valueOf(((Map<String, Object>) JSON.deserializeUntyped(String.valueOf(oppRecord.data))).get('isValid')));
        
        oppRecord = RetroactiveReferralController.initialize(null);
        System.assertEquals(true, Boolean.valueOf(((Map<String, Object>) JSON.deserializeUntyped(String.valueOf(oppRecord.data))).get('isValid')));
      
        System.runAs(lstUsers[0]){
            String oppResult1 = RetroactiveReferralController.isValidForWebService(lstOpportunity[1].Id);
            System.assertEquals(false, Boolean.valueOf(((Map<String, Object>) JSON.deserializeUntyped(oppResult1)).get('isValid')));
            
            oppRecord = RetroactiveReferralController.initialize(null);
            System.assertEquals(false, Boolean.valueOf(((Map<String, Object>) JSON.deserializeUntyped(String.valueOf(oppRecord.data))).get('isValid')));
        }
        
        System.runAs(lstUsers[0]){
            Setting__c retroactiveSetting = Settings.get('RetroactiveReferralSettings');
            retroactiveSetting.Data__c ='{"RetroactiveReferralApi":{"url":"https://sales-api-staging.wework.com/v1/retroactive_referrals","Headers":{"Authorization":"Token token=dIc0nYcdaPvmFzUq3e0-CQ"}},"RetroactiveReferralType":["Retroactive Referral","Confidential Referral"],"ContactRecordType":"0120G000001K6d4","AccountRecordType":"0120G000001K6d3","APIUser":"005F0000003Kmbw","AllowedStages":["Closed Won"],"AllowedUsersId":["'+lstUsers[0].Id+'"],"AllowedProfileId":["00eF0000000aice"],"RetroactiveReferrType":["Employee","Member","Affiliate","Broker"],"RestrictOppStages":["Closed Lost","Merged"],"RestrictCriteria":{"excludeReferralStatus":["Approved"],"allowedOppStages":["Qualifying","Selling","Negotiating","Closing","Closed Won","Licensee"],"excludedContractStages":["Contract Sent","Contract Signed"],"excludedOppStages":["Closed Lost","Merged"]}}';
            update retroactiveSetting;    
            
            oppRecord = RetroactiveReferralController.initialize(null);
            System.assertEquals(true, Boolean.valueOf(((Map<String, Object>) JSON.deserializeUntyped(String.valueOf(oppRecord.data))).get('isValid')));
        
            String oppResult1 = RetroactiveReferralController.isValidForWebService(lstOpportunity[1].Id);
            String oppResult2 = RetroactiveReferralController.isValidForWebService(lstOpportunity[2].Id);
            String oppResult3 = RetroactiveReferralController.isValidForWebService(lstOpportunity[3].Id);
            
            System.assertEquals(true, Boolean.valueOf(((Map<String, Object>) JSON.deserializeUntyped(oppResult1)).get('isValid')));
            System.assertEquals(false, Boolean.valueOf(((Map<String, Object>) JSON.deserializeUntyped(oppResult2)).get('isValid')));
            System.assertEquals(false, Boolean.valueOf(((Map<String, Object>) JSON.deserializeUntyped(oppResult3)).get('isValid')));
        }
    }
    
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method tests UpdateReferrerOnOpportunity method
        Created Date        :   01 November 2018
        Issue No            :   ST-2858
    ******************************************************************************************************************************************/
    public static testMethod void testUpdateReferrerOnOpportunity(){
        List<Opportunity> lstOpportunity = [SELECT Id FROM Opportunity];
        List<Contact> lstContact = [SELECT Id, Type__c FROM Contact];
        List<Account> lstAccounts = [SELECT id FROM Account];
        List<Billing_Account__c> lstBillingAccount = [SELECT Id, Primary_Member__c FROM Billing_Account__c];
        
        DatabaseResult oppRecord = RetroactiveReferralController.updateReferrerOnOpportunity(lstOpportunity[0].Id, lstContact[0], lstBillingAccount[0].Id, lstAccounts[0].Id, 'Confidential Referral');
        Opportunity UpdatedOpp = [SELECT Id, Name, Billing_Account__c, Contract_Signed_On__c, Building__r.UUID__c, RecordType.Name, LeadSource, Referral_Type__c, Referrer__r.Name ,Referrer__r.Email ,Referrer__r.Phone ,Referrer__r.Type__c, Primary_Member__r.Email, Primary_Member__r.Name, Referrer__c FROM Opportunity WHERE Id =: lstOpportunity[0].Id];         
        System.assertEquals(lstBillingAccount[0].Id, UpdatedOpp.Billing_Account__c);
        System.assertEquals(lstBillingAccount[0].Primary_Member__c, UpdatedOpp.Primary_Member__c);
        System.assertEquals(lstContact[0].Id, UpdatedOpp.Referrer__c);
        System.assertEquals('Referral', UpdatedOpp.LeadSource);
    }
    
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method tests UpdateReferrerOnOpportunity method
        Created Date        :   01 November 2018
        Issue No            :   ST-2858
    ******************************************************************************************************************************************/
    public static testMethod void testNullConditionInUpdateReferrerOnOpportunity(){
        try{
            List<Opportunity> lstOpportunity = [SELECT Id FROM Opportunity];
            List<Contact> lstContact = [SELECT Id, Type__c FROM Contact];
            List<Account> lstAccounts = [SELECT id FROM Account];
            List<Billing_Account__c> lstBillingAccount = [SELECT Id, Primary_Member__c FROM Billing_Account__c];
            
            DatabaseResult oppRecordNull = RetroactiveReferralController.updateReferrerOnOpportunity(null, lstContact[0], lstBillingAccount[0].Id, lstAccounts[0].Id, 'Confidential Referral');
        }catch(Exception pEx) {
            System.assertEquals('Opportunity Id is not present', pEx.getMessage());
        }
    }
    
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method tests SaveConAccRecords method
        Created Date        :   01 November 2018
        Issue No            :   ST-2858
    ******************************************************************************************************************************************/
    public static testMethod void testSaveConAccRecords(){
        List<Billing_Account__c> lstBillingAccount = new List<Billing_Account__c>();
        boolean createReferral = true;
        List<sObject> lstSobject = new List<sObject>();
        List<Account> lstAccount = [SELECT Id, Name FROM Account];
        List<Contact> lstContact = [SELECT Id, FirstName, LastName, Email, Billing_Account__c, AccountId FROM Contact];
        lstBillingAccount.add(new Billing_Account__c(Name = 'Test Billing Account1'));
        //In Update Context 
        lstSobject.add(lstContact[0]);
        lstSobject.add(lstAccount[0]);
        lstSobject.add(lstBillingAccount[0]);
        DatabaseResult response = RetroactiveReferralController.saveConAccRecords(lstSobject);
        Map<String, sObject> response1 = (Map<String, sObject>)JSON.deserializeStrict(JSON.serialize(response.data), Map<String, sObject>.class);
        System.assert(String.isNotBlank(response1.get('billAcc').Id));
        System.assert(String.isNotBlank(response1.get('contact').Id));
        lstBillingAccount.clear();
        lstSobject.clear();
        Contact con = new Contact(LastName = 'tstContact', AccountId = lstAccount[0].Id);
        lstBillingAccount.add(new Billing_Account__c(Name = 'Test Billing Account2'));
        lstSobject.add(con);
        lstSobject.add(lstAccount[0]);
        lstSobject.add(lstBillingAccount[0]);
        DatabaseResult response2 = RetroactiveReferralController.saveConAccRecords(lstSobject);
        Map<String, sObject> response3 = (Map<String, sObject>)JSON.deserializeStrict(JSON.serialize(response2.data), Map<String, sObject>.class);
        System.assert(String.isNotBlank(response3.get('billAcc').Id));
        System.assert(String.isNotBlank(response3.get('contact').Id));
    }
}