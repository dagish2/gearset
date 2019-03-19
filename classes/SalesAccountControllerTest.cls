/************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   This class contain all test methods related to SalesAccountController class.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           10 Jan 2019         Prashant Mane           Initial Developement
**************************************************************************************************************************************/
@isTest
public class SalesAccountControllerTest {
    
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        Test.startTest();
        List<User> lstUsers = (List<User>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'User', 'numberOfRecords' => 2});
        List<Lead> lstLeads = (List<Lead>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Lead', 'numberOfRecords' => 2});
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
        Author       : Krishana Tupe
        Description   : This method gets the ultimate org id and gets its related sales accounts.
        Created Date  : 27 July 2018 
  **************************************************************************************************************************************/
    public static testMethod void verifyGetRelatedSalesAccounts(){
        List<Account> lstAccounts = [SELECT Id, Account_Type__c, ParentId, Nickname__c, OwnerId FROM Account];
        List<Lead> lstLeads = [SELECT Id, Name, Email, LeadSource, Account__c FROM Lead];
        List<User> lstUsers = [SELECT Id FROM User];
        List<Account> lstAccountsToUpdate = new List<Account>();
        
        lstAccounts[0].Account_Type__c = 'Org';
        lstAccountsToUpdate.add(lstAccounts[0]);
        
        lstAccounts[1].Account_Type__c = 'Sales';
        lstAccounts[1].ParentId = lstAccounts[0].Id;
        lstAccounts[1].Nickname__c = 'sales1NickName';
        lstAccountsToUpdate.add(lstAccounts[1]);
        
        lstAccounts[2].Account_Type__c = 'Sales';
        lstAccounts[2].ParentId = lstAccounts[0].Id;
        lstAccounts[2].Nickname__c = 'sales2NickName';
        lstAccountsToUpdate.add(lstAccounts[2]);
        
        lstAccounts[3].Account_Type__c = 'Sales';
        lstAccounts[3].ParentId = lstAccounts[0].Id;
        lstAccounts[3].Nickname__c = 'sales26ickName';
        

        lstAccountsToUpdate.add(lstAccounts[3]);
        System.runAs(lstUsers[0]){
            TestingUtility.updateListWithAssert(lstAccountsToUpdate);
        }
        
        lstLeads[0].Account__c = lstAccounts[0].Id;
        TestingUtility.updateWithAssert(lstLeads[0]);
        
        Map<String,List<Account>> mapAccount = (Map<String,List<Account>>)SalesAccountController.getRelatedAccounts(lstLeads[0].Id, lstAccounts[0].Id).data; 
        System.assert(mapAccount.get('OrgAccount') != null);
        System.assertEquals(lstAccounts[0].Id, mapAccount.get('OrgAccount')[0].Id);   
        System.assert(mapAccount.get('SalesAccounts') != null);
        SalesAccountController.isValisUserToShowAccountSelector();
        
        Map<String,List<Account>> mapAccount1 = (Map<String,List<Account>>)SalesAccountController.getRelatedAccounts(null, null).data; 
        System.assert(mapAccount1 == null);
        
        DatabaseResult result =  SalesAccountController.isValidForSalesAccount(lstAccounts[0].Id);
        System.assert(result.success);
        DatabaseResult result1 =  SalesAccountController.isValidForSalesAccount(lstAccounts[2].Id);
        System.assert(result1.success);
        DatabaseResult result2 =  SalesAccountController.isValidForSalesAccount(lstAccounts[3].Id);
        System.assert(result2.success);
        DatabaseResult result3 =  SalesAccountController.isValidForSalesAccount(lstAccounts[4].Id);
        System.assert(result3.success);
        DatabaseResult result4 = SalesAccountController.isValidForSalesAccount(null);
        System.assert(!result4.success);
    } 
    
    /************************************************************************************************************************************
        Author 			: Krishana Tupe
        Description 	: This method gets the ultimate org id and gets its related sales accounts.
        Created Date	: 27 July 2018 
		Last Modified By: Rupesh Patil
		Last Modified Date : 28 Nov 2018
  **************************************************************************************************************************************/
    public static testMethod void verifyGetRelatedAccounts(){
        List<Account> lstAccounts = [SELECT Id, Name, Account_Type__c, Unomy_Company_ID__c, Unomy_Company_Name__c, Cleansed_Account_Name__c FROM Account LIMIT 2];
        List<Lead> lstLeads = [SELECT Id, Name, Account__c, Email, Phone, Company FROM Lead LIMIT 2];
        lstLeads[0].Account__c = lstAccounts[0].Id;
        TestingUtility.updateWithAssert(lstLeads[0]);
        Map<String,List<Account>> mapAccount = (Map<String,List<Account>>)SalesAccountController.getRelatedAccounts(lstLeads[0].Id, lstAccounts[0].Id).data; 
        System.assert(mapAccount.get('OrgAccount') != null);
        System.assertEquals(lstAccounts[0].Id, mapAccount.get('OrgAccount')[0].Id);     
        //when parentId not Populated on Lead 
        Map<String,List<Account>> mapAccount1 = (Map<String,List<Account>>)SalesAccountController.getRelatedAccounts(lstLeads[1].Id, null).data;         
        System.assert(mapAccount1.get('OrgAccount') != null);
        System.assertEquals(lstAccounts[0].Id, mapAccount1.get('OrgAccount')[0].Id);     
    }
}