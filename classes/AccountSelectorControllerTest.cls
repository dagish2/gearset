/************************************************************************************************************************************
Author 		: Sunil Bhosale
Description : This class Contains Unit Test of Account selector page functionality

History		:
----------------------------------------------------------------------------------------------------------------------------------
VERSION		DATE				    AUTHOR				DETAIL
1.0			16 october 2018			Sunil Bhosale 		Initial Developement
**************************************************************************************************************************************/

@isTest
public class AccountSelectorControllerTest {
    @TestSetup
    static void initData(){ 
        SalesConsoleSettings.createSettings();
        WeWorkValidatorHelper.createTerritoryStructure();
        Account orgAccount1 = TestingUtility.createAccount('strAccountName', false);
        orgAccount1.Account_Type__c = 'Org'; 
        orgAccount1.Unomy_Company_ID__c = 1234 ;
        orgAccount1.Unomy_Company_Name__c = 'test company1';
        orgAccount1.Cleansed_Account_Name__c = 'test company cleansed';
        Database.insert(orgAccount1, false);
        System.assert(orgAccount1.id != null);
        
        List<Lead> lstLead = new List<Lead>();
        Lead objLead = new Lead();        
        objLead.LastName = 'lastName';       
        objLead.Email = 'john.smith1610201801@example.com'; 
        objLead.Phone = '1234567891';
        objLead.Company = 'Test Company';
        objLead.Locations_Interested__c='Test Building Tour';
        objLead.Unomy_Company_ID__c = 1234 ;
        objLead.LeadSource= 'Broker';        
        objLead.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead);
        
        Lead objLead2 = new Lead();        
        objLead2.LastName = 'lastName2';       
        objLead2.Email = 'john.smith1610201802@example.com'; 
        objLead2.Phone = '1234567891';
        objLead2.Company = 'Test Company2';
        objLead2.Unomy_Company_ID__c = 1234 ;
        objLead2.Locations_Interested__c='Test Building Tour';
        objLead2.LeadSource= 'Broker';
        objLead2.Lead_Source_Detail__c = 'Broker1';
        lstLead.add(objLead2);  
        insert lstLead;
    }
    
    /************************************************************************************************************************************
    Author         : Sunil Bhosale
    Description     : This method verify the getMatchedAccounts (AuraEnabled) Metohd
    Created  Date    : 16 october 2018
  **************************************************************************************************************************************/    
    static testMethod void verifyGetMatchedAccounts1(){
        Lead objLead = [SELECT Id, Title , FirstName, Name, Interested_in_Number_of_Desks_Min__c,Interested_in_Number_of_Desks__c,LastName,Product_Line__c,OwnerId,Email_Domain__c,Company,Account__c,Account__r.Name,Account__r.Account_Type__c,Referrer__c,Cleansed_Unomy_Company_Name__c,Cleansed_Company_Name__c,Email,Unomy_Company_ID__c,Unomy_Company_Name__c,LeadSource,Lead_Source_Detail__c,Generate_Journey__c,By_Pass_Journey_Creation_Criteria__c,Campaign_Id__c,Building_Interested_In__c,Building_Interested_In__r.City__c,Locations_Interested__c,Number_of_Full_Time_Employees__c, Unomy_Company_Size__c, Company_Size__c, Markets_Interested__c From Lead WHERE Email = 'john.smith1610201801@example.com'];
        DatabaseResult result = AccountSelectorController.getMatchedAccounts(objLead);
        System.assertNotEquals(null, result);     
        List<Account> lstMatchedAccounts = (List<Account>)result.data;
        System.assertEquals(1, lstMatchedAccounts.size());
        
        result = AccountSelectorController.getMatchedAccounts(null);
        lstMatchedAccounts = (List<Account>)result.data;
        System.assertEquals(0, lstMatchedAccounts.size());       
    }

    /************************************************************************************************************************************
    Author         : Sunil Bhosale
    Description     : This method verify the getMatchedAccounts (AuraEnabled) Metohd
    Created  Date    : 16 october 2018
  **************************************************************************************************************************************/ 
    static testMethod void verifyGetMatchedAccounts2(){
        List<Lead> lstLeads = [SELECT LastName,Name, Cleansed_Unomy_Company_Name__c, Unomy_Company_Name__c, Cleansed_Company_Name__c, Email, Phone, Company, Unomy_Company_ID__c, Locations_Interested__c, LeadSource, Lead_Source_Detail__c FROM Lead ];
        DatabaseResult databaseResult = AccountSelectorController.getMatchedAccounts(lstLeads[0]);  
        System.assertEquals('SObject row was retrieved via SOQL without querying the requested field: Lead.Account__c', databaseResult.message);        
    }
    
    /************************************************************************************************************************************
    Author         : Krishana Tupe
    Description    : This method verify the getRelatedSalesAccounts (AuraEnabled) Metohd
    Created  Date  : 16 october 2018
  **************************************************************************************************************************************/ 
    @isTest
    public static void verifyGetRelatedSales(){
        Account accRec = [SELECT Id From Account Where Name = 'strAccountName' AND Account_Type__c = 'Org'];   
        Debug.log('accRec==>'+accRec);
        List<Account> lstSalesAccount = new List<Account>();
        for(Integer iIndex = 1; iIndex <=5 ; iIndex++){
            Account accRecforSales = TestingUtility.createAccount('SalesAccount' + iIndex, false); 
            accRecforSales.Nickname__c = 'SalesAccount' + iIndex;
            accRecforSales.Account_Type__c = 'Sales';
            accRecforSales.ParentId = accRec.Id;
            lstSalesAccount.add(accRecforSales);
        }        
        Database.insert(lstSalesAccount);
        List<Account> lstAccounts = [SELECT Id, Name, Parent_Org_Id__c, Account_Type__c, OwnerId, Owner.Name, ParentId, Parent.Name, Primary_Member__c, Primary_Member__r.Name, Primary_Member__r.Email FROM Account WHERE Id IN : lstSalesAccount];
        Debug.log('lstAccounts==>'+lstAccounts);       
        DatabaseResult objResult =  AccountSelectorController.getRelatedSalesAccounts(lstAccounts[1].Id);       
        AccountSelectorControllerTest.checkAssert(objResult, 5); 
        DatabaseResult objResult1 =  AccountSelectorController.getRelatedSalesAccounts(accRec.Id);
        AccountSelectorControllerTest.checkAssert(objResult1, 5);
        
        objResult =  AccountSelectorController.getRelatedSalesAccounts(null);
    }
    
    /************************************************************************************************************************************
    Author         : Krishana Tupe
    Description    : This method verify the getRelatedViewHierarchy (AuraEnabled) Metohd
    Created  Date  : 16 october 2018
  **************************************************************************************************************************************/ 
    @isTest
    public static void verifyGetRelatedViewHierarchy(){
        Account accRec = [SELECT Id From Account Where Name = 'strAccountName' AND Account_Type__c = 'Org'];   
        Debug.log('accRec==>'+accRec);
        List<Account> lstSalesAccount = new List<Account>();
        for(Integer iIndex = 1; iIndex <=5 ; iIndex++){
            Account accRecforSales = TestingUtility.createAccount('SalesAccount' + iIndex, false); 
            accRecforSales.Nickname__c = 'SalesAccount' + iIndex;
            accRecforSales.Account_Type__c = 'Sales';
            accRecforSales.ParentId = accRec.Id;
            lstSalesAccount.add(accRecforSales);
        }        
        Database.insert(lstSalesAccount);
        List<Account> lstAccounts = [SELECT Id, Name, Parent_Org_Id__c, Account_Type__c, OwnerId, Owner.Name, ParentId, Parent.Name, Primary_Member__c, Primary_Member__r.Name, Primary_Member__r.Email FROM Account WHERE Id IN : lstSalesAccount];
        Debug.log('lstAccounts==>'+lstAccounts);       
        DatabaseResult objResult =  AccountSelectorController.getRelatedViewHierarchy(lstAccounts[1].Id);
        AccountSelectorControllerTest.checkAssert(objResult, 6); 
        DatabaseResult objResult1 =  AccountSelectorController.getRelatedViewHierarchy(accRec.Id);
        AccountSelectorControllerTest.checkAssert(objResult1, 6);
        
        objResult =  AccountSelectorController.getRelatedViewHierarchy(null);
    }
    
    /************************************************************************************************************************************
    Author         : Shivprasad Patil
    Description    : This method verify the getQueryDataTest (AuraEnabled) Metohd
    Created  Date  : 03 December 2018
    **************************************************************************************************************************************/ 
    @isTest
    public static void getQueryDataTest(){
        List<Account> lstAccount = [SELECT Id FROM Account WHERE Account_Type__c = 'Org'];
        Integer intOrgCount = lstAccount.size();
        Map<String, Object> mapOfParams = new Map<String, Object>{'accountName'=>'strAccount', 'accountType'=>'Org'};
        DatabaseResult result = AccountSelectorController.getQueryData('searchOrgAccounts', mapOfParams);
        System.assertEquals(true, result.success);
        List<sObject> lstOfAccounts = (List<sObject>)result.data;
        System.assertEquals(intOrgCount, lstOfAccounts.size());
    }
    /************************************************************************************************************************************
    Author         : Krishana Tupe
    Created  Date  : 16 october 2018
  **************************************************************************************************************************************/ 
    static void checkAssert(DatabaseResult objResult, Integer assertValue){ 
        Debug.log('objResult==>'+objResult);
        String str = JSON.serialize(objResult.data);
        List<Account> lstAccount = (List<Account>)JSON.deserialize(str, List<Account>.class);
        Debug.log('lstAccount==>'+lstAccount);
        System.assert(lstAccount.size() == assertValue);
    }
}