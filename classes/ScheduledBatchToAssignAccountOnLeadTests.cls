/************************************************************************************************************************************
    Author 		: Prashant Mane
    Description : Test Methods For BatchToAssignAccountOnLead Which Find Related Account For Incoming Lead Based On Sepecific Creteria , If Not found then Dosen't Create New Account

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1			23 Jan 2018			Prashant Mane			Initial Developement.
**************************************************************************************************************************************/
@isTest
public class ScheduledBatchToAssignAccountOnLeadTests {
    static{
        SalesConsoleSettings.createSettings();
    }

    /*************************************************************************************************************************
       Author 				: Prashant Mane
       Description  		: Test Method to verify Account null on lead if no related Account Org found
       Created Date			: 23 Jan, 2018	
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
 	*****************************************************************************************************************************/
    //public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    public static testMethod void populateAccountIdWoOrg (){
        Lead objLead1 = getLead('test813','testEnzi1','test813@example.com',1234,'Enzigma','Enzigma','Pending',System.now().addMinutes(-1));
        Lead objLead2 = getLead('test8134','testEnzi2','test8134@example.com',1234,'Enzigma','Enzigma','Pending',System.now().addMinutes(-1));
        System.assertNOTEquals(null,objLead1);
        System.assertNOTEquals(null,objLead2);
        Test.startTest();
        ScheduledBatchToAssignAccountOnLead obj = new ScheduledBatchToAssignAccountOnLead();
        DataBase.executeBatch(obj); 
        Test.stopTest();
        Lead lead1 = [SELECT Id,account__c,Org_Identification_Status__c FROM Lead WHERE Id = :objLead1.Id];
        Lead lead2 = [SELECT Id,account__c,Org_Identification_Status__c FROM Lead WHERE Id = :objLead2.Id];
        System.assertEquals(null,lead1.account__c);
        System.assertEquals(null,lead2.account__c);
        
    }
    /*************************************************************************************************************************
       Author 				: Prashant Mane
       Description  		: Test Method to verify populate Account on lead if related Account Org found
       Created Date			: 23 Jan, 2018	
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
 	*****************************************************************************************************************************/
    public static testMethod void populateAccountIdWithOrg (){
        Account orgAccount = new Account();
        orgAccount = getAccount('testDemoAccount',12345,'Enzigma','Enzigma');
        Test.startTest();
        Lead objLead1 = getLead('test513','Enzi','test513@example.com',12345,'Enzigma','Enzigma','Pending',System.now().addMinutes(-1));
        Lead objLead4 = getLead('test343','Enzi','test443@example.com',null,null,null,'Pending',System.now().addMinutes(-1));
        Lead objLead5 = getLead('test353','Enzi','test453@example.com',12345,null,null,'Pending',System.now().addMinutes(-1));
        Lead objLead6 = getLead('test363','Enzi','test463@example.com',null,'Enzigma',null,'Pending',System.now().addMinutes(-1));
        Lead objLead7 = getLead('test373','Enzi','test473@example.com',12345,null,'Enzigma','Pending',System.now().addMinutes(-1));
        
        System.assertNOTEquals(null,objLead4);
        System.assertNOTEquals(null,objLead1);
        
        System.assertNOTEquals(null,objLead5);
        System.assertNOTEquals(null,objLead6);
        System.assertNOTEquals(null,objLead7);
        
        ScheduledBatchToAssignAccountOnLead obj = new ScheduledBatchToAssignAccountOnLead();
        DataBase.executeBatch(obj);
        Test.stopTest();
        Lead lead1 = [SELECT Id,account__c,Org_Identification_Status__c FROM Lead WHERE Id = :objLead1.Id];
        Lead lead4 = [SELECT Id,account__c,Org_Identification_Status__c FROM Lead WHERE Id = :objLead4.Id];
        
        Lead lead5 = [SELECT Id,account__c,Org_Identification_Status__c FROM Lead WHERE Id = :objLead5.Id];
        Lead lead6 = [SELECT Id,account__c,Org_Identification_Status__c FROM Lead WHERE Id = :objLead6.Id];
        Lead lead7 = [SELECT Id,account__c,Org_Identification_Status__c FROM Lead WHERE Id = :objLead7.Id];
        System.assertEquals(null,lead4.account__c);
        System.assertEquals(orgAccount.Id,lead1.account__c);
        
        //System.assertEquals(orgAccount.Id,lead5.account__c);
        //System.assertEquals(orgAccount.Id,lead6.account__c);
        //System.assertEquals(orgAccount.Id,lead7.account__c);
        
    }
    /*************************************************************************************************************************
       Author 				: Prashant Mane
       Description  		: Test Method to verify populate account on lead without unomy detail
       Created Date			: 23 Jan, 2018	
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
 	*****************************************************************************************************************************/
    public static testMethod void populateAccountWoUnomyDetails (){
        Lead objLead1 = getLead('test123','Enzi','test123@example.com',1234,null,null,'Pending',System.now().addMinutes(-1));
        Lead objLead3 = getLead('test122','Enzi','test122@example.com',null,'Enzigma',null,'Pending',System.now().addMinutes(-1));
        Lead objLead5 = getLead('test523','Enzi','test523@example.com',null,null,'Enzigma','Pending',System.now().addMinutes(-1));
        System.assertNOTEquals(null,objLead1);
        System.assertNOTEquals(null,objLead3);
        System.assertNOTEquals(null,objLead5);
        Test.startTest();
        ScheduledBatchToAssignAccountOnLead obj1 = new ScheduledBatchToAssignAccountOnLead();
        DataBase.executeBatch(obj1); 
        Test.stopTest();
        Lead lead1 = [SELECT Id,account__c,Org_Identification_Status__c FROM Lead WHERE Id = :objLead1.Id];
        Lead lead3 = [SELECT Id,account__c,Org_Identification_Status__c FROM Lead WHERE Id = :objLead3.Id];
        Lead lead5 = [SELECT Id,account__c,Org_Identification_Status__c FROM Lead WHERE Id = :objLead5.Id];
        System.assertEquals(null,lead5.account__c);
        System.assertEquals(null,lead3.account__c);
        System.assertEquals(null,lead1.account__c);
    }
    
    /*************************************************************************************************************************
       Author 				: Prashant Mane
       Description  		: Test Method to verify populate account using CleansedCompanyName
       Created Date			: 23 Jan, 2018	
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
 	*****************************************************************************************************************************/
    public static testMethod void verifyForCleansedCompanyName(){
        Account orgAccount = new Account();
        orgAccount = getAccount('testdemosales',null,null,'testdemosales');
        Lead objLead1 = getLead('testdemosales','testdemosales','testdemosales@example.com',null,null,'testdemosales','Pending',System.now().addMinutes(-1));
        System.assertNOTEquals(null,objLead1);
        Test.startTest();
        ScheduledBatchToAssignAccountOnLead obj1 = new ScheduledBatchToAssignAccountOnLead();
        DataBase.executeBatch(obj1); 
        Test.stopTest();
        Lead lead1 = [SELECT Id,account__c,Org_Identification_Status__c FROM Lead WHERE Id = :objLead1.Id];
        
        System.assertNOTEquals(null,lead1.account__c);
        //System.assertEquals('Processed',lead1.Org_Identification_Status__c);
        
    }
        public static testMethod void verifyForUnomyCompanyName(){
        Account orgAccount = new Account();
        orgAccount = getAccount('testdemoOrg',1234,'testdemosales',null);
        System.assertNOTEquals(null,orgAccount);
        Lead objLead1 = getLead('testdemosales','testdemosalesCompany','testdemosalesemail@example.com',12,'testdemosales',null,'Pending',System.now().addMinutes(-1));
        System.assertNOTEquals(null,objLead1);
        Test.startTest();
        ScheduledBatchToAssignAccountOnLead obj1 = new ScheduledBatchToAssignAccountOnLead();
        DataBase.executeBatch(obj1); 
        Test.stopTest();
        Lead lead1 = [SELECT Id,account__c,Org_Identification_Status__c FROM Lead WHERE Id = :objLead1.Id];
        System.assertNOTEquals(null,lead1.account__c);
        System.assertEquals('Processed',lead1.Org_Identification_Status__c);
        
    }
    
    /*************************************************************************************************************************
       Author 				: Prashant Mane
       Description  		: This method is used to create lead from diffrent test methods of this class.
       Created Date			: 23 Jan, 2018	
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
 	*****************************************************************************************************************************/
    public static Lead getLead(String name,String companyName,String email,Integer UnomyCompanyID,String UnomyCompanyName,String CleansedAccountName,String Status,Datetime UnomyUpdatedDateTime ){
        Lead objLead = new Lead();
        objLead.LastName = name;
        objLead.Company = companyName;
        objLead.Email = email;
        objLead.Unomy_Company_ID__c = UnomyCompanyID;
        objLead.Unomy_Company_Name__c = UnomyCompanyName;
        objLead.Cleansed_Company_Name__c = CleansedAccountName;
        objLead.Unomy_Updated_DateTime__c = UnomyUpdatedDateTime;
        objLead.Org_Identification_Status__c = Status;
        INSERT objLead;
        return objLead;
    }
    
    /*************************************************************************************************************************
       Author 				: Prashant Mane
       Description  		: This method is used to create account from diffrent test methods of this class.
       Created Date			: 23 Jan, 2018	
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
 	*****************************************************************************************************************************/
    public static Account getAccount(String name,Integer UnomyCompanyID,String UnomyCompanyName,String CleansedAccountName ){
        
        Account objAccount = new Account();
        objAccount.Name = name;
        objAccount.Account_Type__c = 'Org';
        objAccount.Unomy_Company_ID__c = UnomyCompanyID;
        objAccount.Unomy_Company_Name__c = UnomyCompanyName;
        objAccount.Cleansed_Account_Name__c = CleansedAccountName;
        INSERT objAccount;
        return objAccount;
    }
    
}