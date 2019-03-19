/************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   Test class for Account Type Conversion functionality.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           28 Aug 2018         Prashant Mane           Initial Developement
**************************************************************************************************************************************/
@isTest
public class AccountTypeConversionControllerTest {
    @TestSetup
    static void testDataSetup(){        
        SalesConsoleSettings.createSettings();
        Map<String, Object> mapAccountFieldValues = new Map<String,Object>();
        
        //Ultimate Parent Account
        mapAccountFieldValues.put('Name', 'UltimateParent');
        mapAccountFieldValues.put('Account_Type__c', 'Org');
        Account ultimateOrg = TestingUtility.createAccount(mapAccountFieldValues, false);
        TestingUtility.insertWithAssert(ultimateOrg);  
        mapAccountFieldValues.clear();
        
        ultimateOrg = [SELECT Id FROM Account WHERE Name =: ultimateOrg.Name LIMIT 1];
        
        //Account 1
        mapAccountFieldValues.put('Name', 'Test Org 1');
        mapAccountFieldValues.put('Account_Type__c', 'Org');
        mapAccountFieldValues.put('ParentId', ultimateOrg.Id);
        Account orgRecord1 = TestingUtility.createAccount(mapAccountFieldValues, false);
        TestingUtility.insertWithAssert(orgRecord1);
        mapAccountFieldValues.clear();
        
        //Account 2
        orgRecord1 = [SELECT Id, ParentId FROM Account WHERE Id =: orgRecord1.Id];
        mapAccountFieldValues.put('Name', 'Test Org 2');
        mapAccountFieldValues.put('Account_Type__c', 'Org');
        mapAccountFieldValues.put('ParentId', orgRecord1.Id);
        Account orgRecord2 = TestingUtility.createAccount(mapAccountFieldValues, false);
        TestingUtility.insertWithAssert(orgRecord2);
        mapAccountFieldValues.clear();
        
        List<Account> lstAccounts = new List<Account>();
        //Account 3
        orgRecord2 = [SELECT Id, ParentId FROM Account WHERE Id =: orgRecord2.Id];
        mapAccountFieldValues.put('Name', 'Test Org 3');
        mapAccountFieldValues.put('Account_Type__c', 'Org');
        mapAccountFieldValues.put('ParentId', orgRecord2.Id);
        Account orgRecord3 = TestingUtility.createAccount(mapAccountFieldValues, false);
        lstAccounts.add(orgRecord3);
        mapAccountFieldValues.clear();
        
        mapAccountFieldValues.put('Name', 'Test Sales Account');
        mapAccountFieldValues.put('Account_Type__c', 'Sales');
        mapAccountFieldValues.put('Nickname__c', 'Sales 1');
        mapAccountFieldValues.put('ParentId', orgRecord2.Id);
        Account salesAccount = TestingUtility.createAccount(mapAccountFieldValues, false);
        lstAccounts.add(salesAccount);        
        mapAccountFieldValues.clear();        
        TestingUtility.insertListWithAssert(lstAccounts);
    }   
    
    /************************************************************************************************************************************
        Author        	:   Jitesh Adwani
		Description   	:   This method is used to get AccountTypeConversion data
        Created Date  	:   28 Aug 2018
        Issue No    	:   ST-2715
    **************************************************************************************************************************************/
    public static testMethod void verifyChangeAccountType(){        
        Id parentOrgId;
        Account objAccountToConvert;
        for(Account objAccount : [SELECT Id, Name, Account_Type__c, ParentId FROM Account ORDER BY CreatedDate]){
            if(objAccount.Name == 'UltimateParent'){                
                System.assertEquals('Org', objAccount.Account_Type__c);
                System.assertEquals(null, objAccount.ParentId);
                parentOrgId = objAccount.Id;
            } else if(objAccount.Name == 'Test Org 1'){
                System.assertEquals('Org', objAccount.Account_Type__c);
                System.assertEquals(parentOrgId, objAccount.ParentId);
                parentOrgId = objAccount.Id;                
            } else if(objAccount.Name == 'Test Org 2'){
                System.assertEquals('Org', objAccount.Account_Type__c);
                System.assertEquals(parentOrgId, objAccount.ParentId);                
                objAccountToConvert = objAccount;
            } else if(objAccount.Name == 'Test Org 3'){
                System.assertEquals('Org', objAccount.Account_Type__c);
                System.assertEquals(objAccountToConvert.Id, objAccount.ParentId);                
            } else {
                System.assertEquals('Sales', objAccount.Account_Type__c);
                System.assertEquals(objAccountToConvert.Id, objAccount.ParentId);
            }
        }       
        
        objAccountToConvert.Account_Type__c = 'Sales';
        objAccountToConvert.Nickname__c = 'Sales 3';
        objAccountToConvert.ParentId = parentOrgId;
        
        DatabaseResult result = AccountTypeConversionController.changeAccountType(objAccountToConvert);
        System.assertEquals(true, result.success);
        
        for(Account objAccount : [SELECT Id, Name, Account_Type__c, ParentId FROM Account ORDER BY CreatedDate]){
            if(objAccount.Name == 'UltimateParent'){                
                System.assertEquals('Org', objAccount.Account_Type__c);
                System.assertEquals(null, objAccount.ParentId);
                parentOrgId = objAccount.Id;
            } else if(objAccount.Name == 'Test Org 1'){
                System.assertEquals('Org', objAccount.Account_Type__c);
                System.assertEquals(parentOrgId, objAccount.ParentId);
                parentOrgId = objAccount.Id;
            } else if(objAccount.Name == 'Test Org 2'){
                System.assertEquals('Sales', objAccount.Account_Type__c);
                System.assertEquals(parentOrgId, objAccount.ParentId);                
                parentOrgId = objAccount.Id;
            } else if(objAccount.Name == 'Test Org 3'){
                System.assertEquals('Org', objAccount.Account_Type__c);
                System.assertEquals(parentOrgId, objAccount.ParentId);
            } else {
                System.assertEquals('Sales', objAccount.Account_Type__c);                
            }
        }
        
        result = AccountTypeConversionController.changeAccountType(null);
        System.assertEquals(false, result.success);
    }    
}