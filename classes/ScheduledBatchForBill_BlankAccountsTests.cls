@isTest
public class ScheduledBatchForBill_BlankAccountsTests{
    static{
        SalesConsoleSettings.createSettings();  
    }
    /*************************************************************************************************************************
    Author 				: Krishana Tupe
    Description 		: Test Method To verify Bill account parentId is Updates or not.
    Created Date		: 18 April 2018
    Last Modified By 	: Krishana Tupe
    Last Modified Date  : 18 April 2018
	******************************************************************************************************************************/	
    public static testMethod void TestOrgPopulateOrNotonBillAccounts(){
        List<Account> lstAccounts = new List<Account>();
        lstAccounts.add(new Account(Name='Org Account',Account_Type__c='Org',Unomy_Company_ID__c=123,Unomy_Company_Name__c='testOrg',Cleansed_Account_Name__c='OrgAccount',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='Bill Account 1',Account_Type__c='Bill',Unomy_Company_ID__c=123,Unomy_Company_Name__c='',Cleansed_Account_Name__c='',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='Bill Account 2',Account_Type__c='Bill',Unomy_Company_Name__c='testOrg',Cleansed_Account_Name__c='',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='Org Account',Account_Type__c='Bill',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='Test Cleansed',Account_Type__c='Bill',Cleansed_Account_Name__c='testcleansed',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='Test Cleansed',Account_Type__c='Bill',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='testCleansed2',Account_Type__c='',Unomy_Company_ID__c=1223,Unomy_Company_Name__c='testOrg',Cleansed_Account_Name__c='orgaccount',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='testCleansed3',Account_Type__c='',Unomy_Company_ID__c=1234,Unomy_Company_Name__c='testOrg',Cleansed_Account_Name__c='orgaccount',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='testCleansed4',Account_Type__c='',Unomy_Company_ID__c=1235,Unomy_Company_Name__c='testOrg',Cleansed_Account_Name__c='orgaccount',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        
        Database.insert(lstAccounts,false);  
        
        List<Account> lstOfInsertedAccounts = [SELECT Id,Name,ParentId,Account_Type__c,Org_Identification_Status__c FROM Account];
        Debug.log('lstOfInsertedAccounts==>'+lstOfInsertedAccounts);
        System.assertEquals(9,lstOfInsertedAccounts.size());
        
        for(Account accRec : lstOfInsertedAccounts){            
            System.assertEquals('Pending',accRec.Org_Identification_Status__c);           
            System.assertEquals(null,accRec.ParentId);            
        }
        
        Test.startTest();        
        ScheduledBatchToCreateOrgForBillAccounts bacthObj = new ScheduledBatchToCreateOrgForBillAccounts();
        DataBase.executeBatch(bacthObj); 
        Test.stopTest();
        
        Account orgAccount = [Select Id,Name,Cleansed_Account_Name__c,Lead_Source__c,Account_Type__c,Unomy_Company_ID__c,ParentId,Org_Identification_Status__c FROM Account WHERE Id=:lstAccounts[0].Id];
        Debug.log('orgAccount==>'+orgAccount);
        List<Account> lstAccountss = [SELECT Id,Cleansed_Account_Name__c,Name,Lead_Source__c,Unomy_Company_ID__c,Account_Type__c,ParentId,Org_Identification_Status__c FROM Account];
        Debug.log('lstAccountss==>'+lstAccountss);
        List<Account> lstOrgAccounts =  new List<Account>();  
        System.assertEquals(10,lstAccountss.size());
        for(Account acc : lstAccountss){
            if(acc.Account_Type__c =='Org'){
                lstOrgAccounts.add(acc);
            }
            if(acc.Account_Type__c =='Bill'){
                if(acc.Name=='Test Cleansed'){
                    debug.log('acc.Name==>'+acc.Name+ 'acc.ParentId'+acc.ParentId);
                    System.assertNotEquals(null,acc.ParentId);               
                    System.assertEquals('Processed',acc.Org_Identification_Status__c); 
                }else{
                    System.assertEquals(orgAccount.Id,acc.ParentId);               
                    System.assertEquals('Processed',acc.Org_Identification_Status__c);  
                }                 
            }else if(acc.Account_Type__c =='' || acc.Account_Type__c =='Org'){
                if(acc.Name=='Test Cleansed' && acc.Lead_Source__c != null){   
                    System.assertEquals('Batch',acc.Lead_Source__c); 
                    System.assertEquals('Processed',acc.Org_Identification_Status__c);              
                    System.assertEquals(null,orgAccount.ParentId); 
                }else{
                    System.assertEquals('Pending',acc.Org_Identification_Status__c);              
                    System.assertEquals(null,orgAccount.ParentId);  
                }                
            }             
        }
        System.assertEquals(2,lstOrgAccounts.size());
    }   
    
   /*************************************************************************************************************************
        Author 				: Krishana Tupe
        Description 		: Test Method To verify Blank account parentId is Updates or not.
        Created Date		: 18,Jan 2018
        Last Modified By 	: Krishana Tupe
        Last Modified Date  : 18 April 2018
	******************************************************************************************************************************/
    public static testMethod void TestOrgPopulateOrNotonBlankAccounts(){
        List<Account> lstAccounts = new List<Account>();
        lstAccounts.add(new Account(Name='Org Account',Account_Type__c='Org',Unomy_Company_ID__c=123,Unomy_Company_Name__c='testOrg',Cleansed_Account_Name__c='OrgAccount',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='Bill Account 1',Account_Type__c='',Unomy_Company_ID__c=123,Unomy_Company_Name__c='',Cleansed_Account_Name__c='',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='Bill Account 2',Account_Type__c='',Unomy_Company_Name__c='testOrg',Cleansed_Account_Name__c='',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='Org Account',Account_Type__c='',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='Test Cleansed',Account_Type__c='',Cleansed_Account_Name__c='testcleansed',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='testCleansed2',Account_Type__c='Bill',Unomy_Company_ID__c=123,Unomy_Company_Name__c='testOrg',Cleansed_Account_Name__c='orgaccount',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='testCleansed3',Account_Type__c='Bill',Unomy_Company_ID__c=123,Unomy_Company_Name__c='testOrg',Cleansed_Account_Name__c='orgaccount',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        lstAccounts.add(new Account(Name='testCleansed4',Account_Type__c='Bill',Unomy_Company_ID__c=123,Unomy_Company_Name__c='testOrg',Cleansed_Account_Name__c='orgaccount',Unomy_Updated_DateTime__c=System.now().addMinutes(-1)));
        
        Database.insert(lstAccounts,false);  
        
        List<Account> lstOfInsertedAccounts = [SELECT Id,Name,ParentId,Account_Type__c,Org_Identification_Status__c FROM Account];
        Debug.log('lstOfInsertedAccounts==>'+lstOfInsertedAccounts);
        System.assertEquals(8,lstOfInsertedAccounts.size());
        
        for(Account accRec : lstOfInsertedAccounts){            
            System.assertEquals('Pending',accRec.Org_Identification_Status__c);           
            System.assertEquals(null,accRec.ParentId);            
        }
        
        Test.startTest();        
        ScheduledBatchToAssignOrgAccounts bacthObj = new ScheduledBatchToAssignOrgAccounts();
        DataBase.executeBatch(bacthObj); 
        Test.stopTest();
        
        Account orgAccount = [Select Id,Name,Lead_Source__c,Account_Type__c,Unomy_Company_ID__c,ParentId,Org_Identification_Status__c FROM Account WHERE Id=:lstAccounts[0].Id];
        Debug.log('orgAccount==>'+orgAccount);
        List<Account> lstAccountss = [SELECT Id,Name,Lead_Source__c,Unomy_Company_ID__c,Account_Type__c,ParentId,Org_Identification_Status__c FROM Account];
        Debug.log('lstAccountss==>'+lstAccountss);               
        System.assertEquals(8,lstAccountss.size());
        for(Account acc : lstAccountss){
            
            if(acc.Account_Type__c ==''){
                if(acc.Name=='Test Cleansed'){
                    System.assertEquals(null,acc.ParentId);               
                    System.assertEquals('Processed',acc.Org_Identification_Status__c); 
                }else{
                    System.assertEquals(orgAccount.Id,acc.ParentId);               
                    System.assertEquals('Processed',acc.Org_Identification_Status__c);  
                }                 
            }else if(acc.Account_Type__c =='Bill' || acc.Account_Type__c =='Org'){                
                System.assertEquals('Pending',acc.Org_Identification_Status__c);              
                System.assertEquals(null,orgAccount.ParentId);  
            }                
        }             
    }
}