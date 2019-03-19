@isTest
public class MergeOrganizationsControllerTest {
    /************************************************************************************************************************************
        Author 			: Rupesh Patil
        Description 	: This method has setup data for all test methods 
        Created Date	: 28 Nov 2018 
    **************************************************************************************************************************************/
    @TestSetup
    static void initData(){          
        SalesConsoleSettings.createSettings();
        Test.startTest();
        List<Contact> lstContacts = (List<Contact>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Contact', 'numberOfRecords' => 4});
        List<Account> lstAccounts = (List<Account>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Account', 'numberOfRecords' => 6});
        List<Building__c> lstBuildings = (List<Building__c>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Building__c', 'numberOfRecords' => 1});
        List<Tour_Outcome__c> lstTours = (List<Tour_Outcome__c>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Tour', 'numberOfRecords' => 4});
        List<Geography__c> lstGeographies = (List<Geography__c>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Geography__c', 'numberOfRecords' => 2});
        List<Billing_Account__c> lstBillingAccounts = (List<Billing_Account__c>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Billing_Account__c', 'numberOfRecords' => 1, 'doInsert' => true, 'method' => 'simpleBillingAccount'});        
        List<Opportunity> lstOpportunities = (List<Opportunity>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Opportunity', 'numberOfRecords' => 1, 'doInsert' => true, 'mapFieldValues' => new Map<String, List<Object>>{'Contract_Stage__c' => new List<Object>{'Contract Sent'}, 'Billing_Account__c' => new List<Object>{lstBillingAccounts[0].Id}}});
        List<Campaign> lstCampaigns = (List<Campaign>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Campaign', 'numberOfRecords' => 1});       
        Test.stopTest();
    }
    
/************************************************************************************************************************************
        Author 			: Sunil Bhosale
        Description 	: This method verify the merge organization functionality.
        Created Date	: 27 July 2018 
  **************************************************************************************************************************************/
    public static testMethod void verifyValidateAccounts(){
        List<Id> lstAccountIDs = new List<Id>();        
        Account orgAccount = TestingUtility.createAccount('strAccountName', false);
        orgAccount.Account_Type__c = 'Org'; 
        orgAccount.Unomy_Company_ID__c = 1234 ;
        orgAccount.Unomy_Company_Name__c = 'test company1';
        orgAccount.Cleansed_Account_Name__c = 'test company cleansed';
        insert orgAccount;
        lstAccountIDs.add(orgAccount.id);
        
        Account orgAccount1 = TestingUtility.createAccount('strAccountName1', false);
        orgAccount1.Account_Type__c = 'Org'; 
        orgAccount1.Unomy_Company_ID__c = 12345 ;
        orgAccount1.Unomy_Company_Name__c = 'test company2';
        orgAccount1.Cleansed_Account_Name__c = 'test company2 cleansed';
        insert orgAccount1;
        lstAccountIDs.add(orgAccount1.id);
        
        Account orgAccount2 = TestingUtility.createAccount('strAccountName2', false);
        orgAccount2.Account_Type__c = 'Org'; 
        orgAccount2.Unomy_Company_ID__c = 12345 ;
        orgAccount2.Unomy_Company_Name__c = 'test company2';
        orgAccount2.Cleansed_Account_Name__c = 'test company2 cleansed';
        insert orgAccount2;
        lstAccountIDs.add(orgAccount2.id); 
        MergeOrganizationsController.validateAccounts(orgAccount.Id,lstAccountIDs);
    }
   
    public static testMethod void verifyGetAccounts(){
        List<String> lstQuery = new List<String>();
        List<Account> lstAccount = new List<Account>();
        Account masterAcc = TestingUtility.createAccount('AccountName', false);
        masterAcc.Account_Type__c = 'Org';
        masterAcc.Nickname__c='PrinarySalesAcc';
        insert masterAcc;
        
        Account objAccount = TestingUtility.createAccount('AccountName', false);
        objAccount.Account_Type__c = 'Sales';
        objAccount.Nickname__c='PrinarySalesAcc';
        objAccount.ParentId = masterAcc.id;
        lstAccount.add(objAccount);
        
        Account objAccount2 = TestingUtility.createAccount('AccountName2', false);
        objAccount2.Account_Type__c = 'Sales';
        objAccount2.ParentId = masterAcc.id;
        objAccount2.Nickname__c='SalesAcc2';
       	lstAccount.add(objAccount2);
        insert lstAccount;
            
        lstQuery.add('SELECT Id FROM Account');
        lstQuery.add('SELECT Id FROM Account');
        
        MergeOrganizationsController.getAccountsToDisplay(lstQuery);
    }
    
    /************************************************************************************************************************************
        Author 			: Krishana Tupe
        Description 	: This method verify the merge organization functionality.
        Created Date	: 27 July 2018 
		Last Modified By: Rupesh Patil
		Last Modified Date : 28 Nov 2018
  **************************************************************************************************************************************/
    public static testMethod void verifyMergeAccounts(){		
        List<Account> lstAccounts = [SELECT Id, Name, Account_Type__c, Nickname__c FROM Account LIMIT 7];
        List<Id> lstAccountIDs = new List<Id>{lstAccounts[0].Id, lstAccounts[1].Id, lstAccounts[2].Id};
            
        Map<String, List<Account>> mapAccountsToMerge  = (Map<String, List<Account>>)MergeOrganizationsController.validateMergeAccounts(lstAccounts[0].Id, lstAccountIDs).data;        
        System.assert(mapAccountsToMerge.get('masterRecord') != null);
        System.assert(mapAccountsToMerge.get('lstMergedAccount') != null);
        LightningComponentController.ReturnValidResults objResults = new LightningComponentController.ReturnValidResults();
        
        String result  = (String)MergeOrganizationsController.mergeAccountsToMaster(mapAccountsToMerge.get('masterRecord')[0], mapAccountsToMerge.get('lstMergedAccount')).data;
        Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(result);        
        System.assertEquals(true, mapResult.get('isSuccess'));
        System.assert(String.valueOf(mapResult.get('message')).equalsIgnoreCase('Accounts merged successfully. Redirecting you to the Primary Account'));
        
        //Insert three Sales accounts under one Org Account ,one is primary account and two Sales account for merge 
        lstAccounts[3].Account_Type__c = 'Sales';
        lstAccounts[3].Nickname__c = 'ParentSales';
        lstAccounts[3].ParentId = lstAccounts[0].Id;
        lstAccounts[4].Account_Type__c = 'Sales';
        lstAccounts[4].Nickname__c = 'SalesNic1';
        lstAccounts[4].ParentId = lstAccounts[0].Id;
        lstAccounts[5].Account_Type__c = 'Sales';
        lstAccounts[5].Nickname__c = 'SalesNic2';
        lstAccounts[5].ParentId = lstAccounts[0].Id;
        List<Account> lstSalesAcount = new  List<Account>{lstAccounts[3], lstAccounts[4], lstAccounts[5]};
        TestingUtility.updateListWithAssert(lstSalesAcount);
        
        lstAccountIDs = new List<Id>{lstAccounts[3].Id, lstAccounts[4].Id, lstAccounts[5].Id};
        mapAccountsToMerge  = (Map<String,List<Account>>)MergeOrganizationsController.validateMergeAccounts(lstAccounts[3].Id, lstAccountIDs).data;        
        System.assert(mapAccountsToMerge.get('masterRecord') != null);
        System.assert(mapAccountsToMerge.get('lstMergedAccount') != null);        
        
        result  = (String)MergeOrganizationsController.mergeAccountsToMaster(mapAccountsToMerge.get('masterRecord')[0], mapAccountsToMerge.get('lstMergedAccount')).data;
        mapResult = (Map<String, Object>)JSON.deserializeUntyped(result);       
        System.assertEquals(true, mapResult.get('isSuccess'));
        System.assert(String.valueOf(mapResult.get('message')).equalsIgnoreCase('Accounts merged successfully. Redirecting you to the Primary Account'));       
        
        DatabaseResult result2 = MergeOrganizationsController.mergeAccountsToMaster(lstAccounts[5], mapAccountsToMerge.get('lstMergedAccount'));
        System.assert(result2.success);
    }
}