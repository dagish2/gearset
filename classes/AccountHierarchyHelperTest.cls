/*************************************************************************************************************************************
    Author 		: 	Prashant Mane
    Issue NO	: 	ST-1947
    Description : 	This class contain all test methd regarding Account Hirarchy Helper
    History		: --

	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			12 Jan 2018			Prashant Mane			Initial Developement.
	2			23 Jan 2018			Prashant Mane			
**************************************************************************************************************************************/


@isTest
public class AccountHierarchyHelperTest {
  static Settings.FieldMappings mapBillAccountToOrgAccount = new Settings.FieldMappings();
    static {        
        SalesConsoleSettings.createSettings();
        mapBillAccountToOrgAccount = Settings.getFieldMappings('BillAccountToOrgAccount');
        if( mapBillAccountToOrgAccount == null){
            mapBillAccountToOrgAccount = Settings.BillAccountToOrgAccountMapping();   
        }  
    }
    /**************************************************************************************************************************
    Author 				: Prashant Mane
    Description  		: Test method to verify Account For Billing Type Of Account 
    Created Date		: 05,July 2016
    Last Modified By 	: Krishana Tupe
    Last Modified Date  : 20 Apr 2018 
 *****************************************************************************************************************************/ 
    public static testMethod void verifyGetRelatedOrgBillingType(){
        //created org for account
        Account orgAccount1 = TestingUtility.createAccount('strAccountName', false);
        orgAccount1.Account_Type__c = 'Org'; 
        orgAccount1.Unomy_Company_ID__c = 1234 ;
        orgAccount1.Unomy_Company_Name__c = 'test company1';
        orgAccount1.Cleansed_Account_Name__c = 'test company cleansed';
        insert orgAccount1;
        
        List<Account> lstAcc = new List<Account>();
        for(Integer index=0;index<5;index++){            
            Account billingAccount = new Account();
            billingAccount.Name = 'Test billiing account1';
            billingAccount.Account_Type__c = 'Bill';
            billingAccount.Unomy_Company_ID__c = 1234;
            lstAcc.add(billingAccount); 
        }
        insert lstAcc;
        
        for(Integer index = 0 ; index < lstAcc.size() ; index++){
            Id parentId= AccountHierarchyHelper.findOrCreateRelatedOrg(lstAcc[index],mapBillAccountToOrgAccount);
            System.assertEquals(orgAccount1.ID, parentId);
        }
        // Unomy_Company_Name__c is present and Unomy_Company_ID__c and Cleansed_Account_Name__c are not present
        List<Account> lstAcc1 = new List<Account>();
        for(Integer index=0;index<5;index++){
            Account billingAccount = new Account();
            billingAccount.Name = 'Test billiing account1';
            billingAccount.Account_Type__c = 'bill';
            billingAccount.Unomy_Company_Name__c = 'test company1';
            lstAcc1.add(billingAccount);
        }
        insert lstAcc1;
        for(Integer index = 0 ; index < lstAcc1.size() ; index++){
            Id parentId= AccountHierarchyHelper.findOrCreateRelatedOrg(lstAcc1[index],mapBillAccountToOrgAccount);
            System.assertEquals(orgAccount1.ID, parentId);
        }
        // Cleansed_Account_Name__c is present and Unomy_Company_ID__c and Unomy_Company_Name__c  are not present
        List<Account> lstAcc2 = new List<Account>();
        for(Integer index=0;index<5;index++){
            Account billingAccount = new Account();
            billingAccount.Name = 'Test billiing account1';
            billingAccount.Account_Type__c = 'bill';
            billingAccount.Unomy_Company_Name__c = 'test company1';
            billingAccount.Cleansed_Account_Name__c = 'test company cleansed';
            lstAcc2.add(billingAccount);            
        }
        insert lstAcc2;
        for(integer index = 0 ; index < lstAcc2.size() ; index++){
            Id parentId= AccountHierarchyHelper.findOrCreateRelatedOrg(lstAcc2[index],mapBillAccountToOrgAccount);
            System.assertEquals(orgAccount1.ID, parentId);
        }
    }
    
    /**************************************************************************************************************************
    Author 				: Krishana Tupe
    Description  		: Test method to verify org updatation on account or create new org for bill: Unomy_Company_Name__c and Unomy_Company_ID__c is present Cleansed_Account_Name__c are not present.
    Created Date		: 20,April 2016
    Last Modified By 	: Krishana Tupe
    Last Modified Date  : 20,April 2016
 	*****************************************************************************************************************************/ 
    public static testMethod void verifyGetRelatedOrgCreateNew(){
        List<Account> lstAcc = new List<Account>();
        for(integer index=0;index<5;index++){
            Account billingAccount = new Account();
            billingAccount.Name = 'Test billiing account1';
            billingAccount.Account_Type__c = 'bill';
            billingAccount.Unomy_Company_ID__c = 1234;
            billingAccount.Unomy_Company_Name__c = 'Enzi';
            lstAcc.add(billingAccount);
        }
        Database.insert(lstAcc,false);
        List<Account> lstAccountsToGetParentId = [Select Id,Name,Account_Type__c,Unomy_Company_ID__c,Cleansed_Unomy_Company_Name__c,Cleansed_Account_Name__c,Unomy_Company_Name__c,OwnerId,RecordTypeId FROM Account];
        debug.log('lstAccountsToGetParentId==>'+lstAccountsToGetParentId);
        system.assertEquals(5,lstAccountsToGetParentId.size());
        for(integer index = 0 ; index < lstAccountsToGetParentId.size() ; index++){
            id parentId= AccountHierarchyHelper.findOrCreateRelatedOrg(lstAccountsToGetParentId[index],mapBillAccountToOrgAccount);
            System.assertNotEquals(null, parentId);
        }
        List<Account> lstAccountsafterOrgFind = [Select Id,Name,Account_Type__c,Unomy_Company_ID__c,Unomy_Company_Name__c,OwnerId,RecordTypeId FROM Account];
        debug.log('lstAccountsafterOrgFind==>'+lstAccountsafterOrgFind);
        system.assertEquals(6,lstAccountsafterOrgFind.size());
        
    }
    /**************************************************************************************************************************
    Author 				: Krishana Tupe
    Description  		: Test method to verify org updatation on account or create new org for bill : Unomy_Company_Name__c is present and Unomy_Company_ID__c and Cleansed_Account_Name__c are not present
    Created Date		: 20,April 2016
    Last Modified By 	: Krishana Tupe
    Last Modified Date  : 20,April 2016
 	*****************************************************************************************************************************/ 
    public static testMethod void verifyGetRelatedOrgCreateNew1(){
        // Unomy_Company_Name__c is present and Unomy_Company_ID__c and Cleansed_Account_Name__c are not present
        List<Account> lstAcc1 = new List<Account>();
        for(integer index=0;index<5;index++){
            Account billingAccount = new Account();
            billingAccount.Name = 'Test billiing account1';
            billingAccount.Account_Type__c = 'bill';
            billingAccount.Unomy_Company_Name__c = 'test company1';
            lstAcc1.add(billingAccount);
        }       
        Database.insert(lstAcc1,false);
        List<Account> lstAccountsToGetParentId = [Select Id,Name,Account_Type__c,Unomy_Company_ID__c,Cleansed_Unomy_Company_Name__c,Cleansed_Account_Name__c,Unomy_Company_Name__c,OwnerId,RecordTypeId FROM Account];
        debug.log('lstAccountsToGetParentId==>'+lstAccountsToGetParentId);
        system.assertEquals(5,lstAccountsToGetParentId.size());
        for(integer index = 0 ; index < lstAccountsToGetParentId.size() ; index++){
            id parentId= AccountHierarchyHelper.findOrCreateRelatedOrg(lstAccountsToGetParentId[index],mapBillAccountToOrgAccount);
            System.assertNotEquals(null, parentId);
        }
        List<Account> lstAccountsafterOrgFind = [Select Id,Name,Account_Type__c,Unomy_Company_ID__c,Unomy_Company_Name__c,OwnerId,RecordTypeId FROM Account];
        debug.log('lstAccountsafterOrgFind==>'+lstAccountsafterOrgFind);
        system.assertEquals(6,lstAccountsafterOrgFind.size());        
    }  
  /**************************************************************************************************************************
    Author 				: Krishana Tupe
    Description  		: Test method to verify org updatation on account or create new org for bill : Unomy_Company_Name__c is present and Unomy_Company_ID__c and Cleansed_Account_Name__c are not present
    Created Date		: 20,April 2016
    Last Modified By 	: Krishana Tupe
    Last Modified Date  : 20,April 2016
 	*****************************************************************************************************************************/   
    public static testMethod void verifyGetRelatedOrgCreateNew2(){
        // Cleansed_Account_Name__cand Unomy_Company_Name__c is present and Unomy_Company_ID__c are not present
        List<Account> lstAcc2 = new List<Account>();
        for(integer index=0;index<5;index++){
            Account billingAccount = new Account();
            billingAccount.Name = 'Test billiing account1';
            billingAccount.Account_Type__c = 'bill';
            billingAccount.Unomy_Company_Name__c = 'test company1';
            billingAccount.Cleansed_Account_Name__c = 'test company cleansed';
            lstAcc2.add(billingAccount);
            
        }       
        Database.insert(lstAcc2,false);
        List<Account> lstAccountsToGetParentId = [Select Id,Name,Account_Type__c,Unomy_Company_ID__c,Cleansed_Unomy_Company_Name__c,Cleansed_Account_Name__c,Unomy_Company_Name__c,OwnerId,RecordTypeId FROM Account];
        debug.log('lstAccountsToGetParentId==>'+lstAccountsToGetParentId);
        system.assertEquals(5,lstAccountsToGetParentId.size());
        for(integer index = 0 ; index < lstAccountsToGetParentId.size() ; index++){
            id parentId= AccountHierarchyHelper.findOrCreateRelatedOrg(lstAccountsToGetParentId[index],mapBillAccountToOrgAccount);
            System.assertNotEquals(null, parentId);
        }
        List<Account> lstAccountsafterOrgFind = [Select Id,Name,Account_Type__c,Unomy_Company_ID__c,Unomy_Company_Name__c,OwnerId,RecordTypeId FROM Account];
        debug.log('lstAccountsafterOrgFind==>'+lstAccountsafterOrgFind);
        system.assertEquals(6,lstAccountsafterOrgFind.size());        
    }  
    
    /**************************************************************************************************************************
    Author 				: Prashant Mane
    Description  		: Test method to verify Org Account  for lead.
    Created Date		: 05,July 2016
    Last Modified By 	: Krishana Tupe
    Last Modified Date  : 20,April 2018
  *****************************************************************************************************************************/ 
    public static testMethod void verifyGetRelatedOrgForLeadObj(){
        Account acc3 = new Account();
        acc3.Name = 'TestDemo3';
        acc3.Account_Type__c = 'Org';
        acc3.Unomy_Company_Name__c = 'enzi';
        insert acc3;
        
        ID accId = AccountHierarchyHelper.findRelatedOrg(acc3);
        System.assertNOTEquals(null, accId);
        
        Lead objLead = new Lead(LastName='Test Org',Company='Enzi',Unomy_Company_Name__c='enzi',Email='m@example.com',Phone='9890989098');
        insert objLead;
        ID accId2 = AccountHierarchyHelper.findRelatedOrg(objLead);
        System.assertNOTEquals(null, accId2);
        
        acc3.Account_Type__c = 'Bill';
        Update acc3;
        Debug.log('acc3 Type Updated Successfully==>'+acc3);
        
        Lead objLead2 = new Lead(LastName='Test Org',Company='Enzi',Unomy_Company_Name__c='Enzi',Email='m@example1.com',Phone='9890989098');
        insert objLead2;
        Debug.log('objLead2==>'+objLead2);
        ID accId3 = AccountHierarchyHelper.findRelatedOrg(objLead2);
        System.assertEquals(null, accId3);
    }
    public List<Account> getAccountRecords(){
        Account acc3 = new Account();
        acc3.Name = 'TestDemo3';
        acc3.Account_Type__c = 'Org';
        acc3.Unomy_Company_Name__c = 'enzi';
        insert acc3;
        ID accId = AccountHierarchyHelper.findRelatedOrg(acc3);
        System.assertNOTEquals(null, accId);
        
        Lead objLead = new Lead(LastName='Test Org',Company='Enzi',Unomy_Company_Name__c='enzi',Email='m@example.com',Phone='9890989098');
        insert objLead;
        ID accId2 = AccountHierarchyHelper.findRelatedOrg(objLead);
        System.assertNOTEquals(null, accId2);
        
        acc3.Account_Type__c = 'Bill';
        Update acc3;
        
        Lead objLead2 = new Lead(LastName='Test Org',Company='Enzi',Unomy_Company_Name__c='Enzi',Email='m@example.com',Phone='9890989098');
        insert objLead2;
        ID accId3 = AccountHierarchyHelper.findRelatedOrg(objLead2);
        System.assertEquals(null, accId3);
        return new List<Account>();
    }
}