/************************************************************************************************************************************
    Author      :   Mayuresh Ghodke
    Description :   This class is used to test AccountTriggerHandler

    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE            AUTHOR                     DETAIL
    1           05 July 2016    Mayuresh Ghodke            Initial Developement
**************************************************************************************************************************************/
@isTest
private class AccountTriggerHandlerTest{
    @TestSetup
    static void initData(){    
        SalesConsoleSettings.createSettings();        
    }
    /************************************************************************************************************************************
        Author              :   Ajaysinh Chauhan
        Description         :   This method is used to verify Merge Account
        Last Modified Date  :   10 Feb 2018
        Last Modified By    :   Ajaysinh Chauhan
    **************************************************************************************************************************************/

    public static testMethod void verifyUnomyAccountMerge_Org_Org(){
        Account masterAccount = new Account(Name='Master Account',Allow_Merge__c=true,Is_Merged__c=false,Unomy_Company_Id__c=2025,Account_Type__c='Org');
        TestingUtility.insertWithAssert(masterAccount, 'Account Not Inserted');
        
        Account childAccount = new Account(Name='Child Account',Allow_Merge__c=true,Is_Merged__c=false,Account_Type__c='Org');
        TestingUtility.insertWithAssert(childAccount, 'Child Account Not Inserted');
        
        childAccount.Unomy_Company_ID__c = 2025;
        childAccount.Unomy_Updated_DateTime__c = System.now();
        TestingUtility.updateWithAssert(childAccount, 'Child Account Not Updated');
        List<Account> lstAccounts = [Select Id From Account Where Id=:childAccount.Id];
        System.assertEquals(0, lstAccounts.size());
    }
 
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This method used to verify Merge Account
        Last Modified Date  :   05 July 2016
        Last Modified By    :   Mayuresh Ghodke
    **************************************************************************************************************************************/        
    private static testMethod void verifyMergeAccount(){
        User objUser = [SELECT Id,Name,Profile.Name FROM User WHERE UserName ='Testnewrescm_user@weworkexample.com'];
        debug.Log('objUser-Account merge'+objUser);
        System.runAs(objUser){

            test.startTest();
            Account acc1 = new Account(Name='Master Account', Unomy_Company_ID__c = 123456, Lead_Source__c='Test',Account_Type__c='Org');
            TestingUtility.insertWithAssert(acc1, 'Account Not Inserted');

            Contact con = new Contact(FirstName='Test',LastName='Member',Email='test.member@example.com',AccountId=acc1.Id);
            TestingUtility.insertWithAssert(con, 'Contact Not Inserted');
           
            Contact con1 = new Contact(FirstName='Test',LastName='Member',Email='test.member1@gmail.com',AccountId=acc1.Id);
            TestingUtility.insertWithAssert(con1, 'Contact Not Inserted');

            Account acc2 = new Account(Name='Child Account',Lead_Source__c='Test',Account_Type__c='Org');
            TestingUtility.insertWithAssert(acc2, 'Account Not Inserted');

            Opportunity opp1 = new Opportunity(Name='Test Child Opp',StageName='Selling',CloseDate=System.today(),AccountId=acc2.Id);
            TestingUtility.insertWithAssert(opp1, 'Opportunity Not Created');

            acc2.Unomy_Company_ID__c = 123456;
            acc2.Unomy_Updated_DateTime__c = System.now();
            TestingUtility.updateWithAssert(acc2, 'Account Not Updated');

            test.stopTest();
            List<Account> lstAccounts = [Select Id,Name,Unomy_Company_ID__c from Account Where Id IN: new List<Id>{acc1.Id,acc2.Id}];
            debug.log('lstAccounts In test Mthod==>'+lstAccounts);
            System.assert(lstAccounts.size()==1);           
            System.assert(lstAccounts[0].Id == acc1.Id);
            System.assertEquals(123456,lstAccounts[0].Unomy_Company_ID__c);
            
            Account acc3 = new Account(Name='Child Account1',Lead_Source__c='Test',Account_Type__c='Org');
            TestingUtility.insertWithAssert(acc3, 'Account Not Inserted');
            
            acc3.Unomy_Company_ID__c = 12345;
            TestingUtility.updateWithAssert(acc3, 'Account Not Updated');
            
            Opportunity opp2 = new Opportunity(Name='Test Child Opp',StageName='Selling',CloseDate=System.today(),AccountId=acc3.Id);
            TestingUtility.insertWithAssert(opp2, 'Opportunity Not Created');

            lstAccounts = [Select Id,Name,Unomy_Company_ID__c from Account Where Id IN: new List<Id>{acc1.Id,acc2.Id,acc3.Id}];
            System.assert(lstAccounts.size()==2);
            //Check if account with primary member havining domain in sales console settings 'PublicDomainSettings' not merge
            Account acc4 = new Account(Name='Child Account4',Lead_Source__c='Test',Primary_Member__c = con1.Id,Account_Type__c='Org');
            TestingUtility.insertWithAssert(acc4, 'Account Not Inserted');
            
            acc4.Unomy_Company_ID__c = 123456;
            TestingUtility.updateWithAssert(acc4, 'Account Not Updated');
            lstAccounts = [Select Id,Name,Unomy_Company_ID__c from Account Where Id IN: new List<Id>{acc1.Id,acc2.Id,acc3.Id,acc4.Id}];
            System.assert(lstAccounts.size()==3);
        }
    }

    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This method used to verify Set Primary Member of Account
        Last Modified Date  :   05 July 2016
        Last Modified By    :   Mayuresh Ghodke
    **************************************************************************************************************************************/        
    private static testMethod void testSetAccountPrimaryMember() {
        //pre-context
        Account acc = new Account(name = 'Test Account');
        TestingUtility.insertWithAssert(acc, 'Account Not Inserted');
        
        Contact con = new Contact(
            firstname = 'John',
            lastname = 'Rambo',
            email = 'john@example.com'
        );
        insert con;
        
        con.AccountId = acc.Id;
        update con;
        
        acc.phone = '1236548790';        
        update acc;
        Debug.log('conId :: '+con.Id);
        Debug.log('accId :: '+acc.Id);
        Debug.log('Primary_Member__c :: '+acc.Primary_Member__c);
        Account updatedAcc = [SELECT Id,Primary_Member__c FROM Account WHERE Id = : acc.Id];
        system.assertEquals(updatedAcc.Primary_Member__c, con.Id, 'Contact should be primary member of account.');
    }
    
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This method used to delete Account
        Last Modified Date  :   05 July 2016
        Last Modified By    :   Mayuresh Ghodke
    **************************************************************************************************************************************/        
    private static testMethod void deleteAccounts(){
       List<Account> lstAccObj1 = new List<Account>();
        //Senario 1 : Normal User Can delete only Inactive accounts
        Account acc = new Account(
            name = 'Test Account',
            ID_Status2__c = 'active'
        );
        lstAccObj1.add(acc);
        
        Account acc1 = new Account(
            name = 'Test Account1',
            ID_Status2__c = 'inactive'
        );
        lstAccObj1.add(acc1);
        
        insert lstAccObj1;
        List<account> lstAcc = new List<account>();
        lstAcc.add(acc);
        lstAcc.add(acc1);
        Database.DeleteResult[] deleteResult1 = database.delete(lstAcc, false); //true : for rollback if error comes
        List<Account> lstAccResult = [Select Id From Account Where Id =: acc.Id];
        system.assertEquals(lstAccResult.size(),1);
        List<Account> lstAccResult1 = [Select Id From Account Where Id =: acc1.Id];
        system.assertEquals(lstAccResult1.size(), 0);
   
        Debug.log('query:: '+limits.getQueries());
        //Senario 2 : User with Profile which is given in Setting User Can not delete Active
        Profile p = [SELECT Id FROM Profile WHERE Name = 'WeWork System Administrator']; 
        User user = new User(Alias = 'standt', 
                            Email = 'standarduser@testorg.com', 
                            EmailEncodingKey = 'UTF-8', 
                            LastName = 'Testing', 
                            LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US', 
                            ProfileId = p.Id, 
                            TimeZoneSidKey = 'America/Los_Angeles',
                            UserName = 'testuser@enzigmatest.com');
        insert user;
        System.runAs(user){
            List<Account> lstAccObj2 = new List<Account>();
            Account acc2 = new Account(
                name = 'Test Account1',
                ID_Status2__c = 'inactive'
            );
            lstAccObj2.add(acc2);
            Debug.Log('acc2.Id --> '+acc2.Id );
            Account acc3 = new Account(
                name = 'Test Account2',
                ID_Status2__c = 'inactive'
            );
            lstAccObj2.add(acc3);
            insert lstAccObj2;
            List<account> lstAcc2 = new List<account>();
            lstAcc2.add(acc2);
            lstAcc2.add(acc3);
            Database.DeleteResult[] deleteResult2 = database.delete(lstAcc2, false); //true : for rollback if error comes
            List<Account> lstAccResult2 = [Select Id From Account Where Id =: acc2.Id];
            system.assertEquals(0, lstAccResult2.size());
            List<Account> lstAccResult3 = [Select Id From Account Where Id =: acc3.Id];
            system.assertEquals(lstAccResult3.size(), 0);
        }
        debug.log('query2:: '+limits.getQueries());
        //Senario 3 : Normal User Can not delete accouncts which are having Opportunities with Stage = 'Closed Won' OR Contract_Stage__c = 'Contract Sent'
        List<Account> lstObjAcc4  = new List<Account>();
        Account acc4 = new Account(
            name = 'Test AccountOpp1',
            ID_Status2__c = 'inactive'
        );
        lstObjAcc4.add(acc4);
        Account acc5 = new Account(
            name = 'Test AccountOpp2',
            ID_Status2__c = 'inactive'
        );
        lstObjAcc4.add(acc5);
        insert lstObjAcc4;
        Opportunity opp = new Opportunity(
            name = 'test opportunity',
            stagename='Closed Won',
            closedate=system.today().addDays(5),
            accountid = acc4.Id
        );
        insert opp;
        List<account> lstAcc3 = new List<account>();
        lstAcc3.add(acc4);
        lstAcc3.add(acc5);
       
        Database.DeleteResult[] deleteResult3 = database.delete(lstAcc3, false); //true : for rollback if error comes
        List<Account> lstAccResult4 = [Select Id From Account Where Id =:acc4.Id];
        system.assertEquals(lstAccResult4.size(),1);
        List<Account> lstAccResult5 = [Select Id From Account Where Id =:acc5.Id];
        Debug.log('lstAccResult5 : '+lstAccResult5);
        system.assertEquals(lstAccResult5.size(),0);
          debug.log('query::3 '+limits.getQueries());
        //Senario 4 : Normal User Can not delete accouncts which are having Opportunities with Stage = 'Closed Won' OR Contract_Stage__c = 'Contract Sent'
       
        List<Account> lstObjAcc5 = new List<Account>();
        Account acc6 = new Account(
            name = 'Test Account acc6',
            ID_Status2__c = 'inactive'
        );
        lstObjAcc5.add(acc6);
        Account acc7 = new Account(
            name = 'Test Account123',
            ID_Status2__c = 'inactive'
        );
        lstObjAcc5.add(acc7);
        insert lstObjAcc5;
        Opportunity opp1 = new Opportunity(
            name = 'test opportunity',
            stagename='Selling',
            closedate=system.today().addDays(5),
            accountid = acc6.Id
        );
        insert opp1;
        List<account> lstAcc4 = new List<account>();
        lstAcc4.add(acc6);
        lstAcc4.add(acc7);
        test.startTest();
        Debug.log('query::4 '+limits.getQueries());
        Database.DeleteResult[] deleteResult4 = database.delete(lstAcc4, false); //true : for rollback if error comes
        List<Account> lstAccResult6 = [Select Id From Account Where Id =:acc5.Id];
        system.assertEquals(lstAccResult6.size(),0);
        List<Account> lstAccResult7 = [Select Id From Account Where Id =:acc6.Id];
        system.assertEquals(lstAccResult7.size(),1);
        test.stopTest();
    }

    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This method used to test Creation of Merged Account
        Last Modified Date  :   05 July 2016
        Last Modified By    :   Mayuresh Ghodke 
    **************************************************************************************************************************************/            
    static testmethod void testCreateMergedAccounts(){
        List<Account> lstAccounts = new List<Account>();
        for(Integer cnt = 1; cnt <= 5; cnt++){
            lstAccounts.add(
                new Account(
                    Name = 'Test Account'+cnt,
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId()
                )
            );
        }        
        insert lstAccounts;
        Debug.log('lstAccounts : '+lstAccounts);
        System.assertEquals(5, lstAccounts.size());
        for(Account accRec : lstAccounts){
            System.assertNotEquals(null, accRec.Id);
        }
        
        List<Merged_Account__c> lstMergedAccounts = [SELECT Id, Account__c, Merged_Account_UUID__c FROM Merged_Account__c];
        Debug.log('lstMergedAccounts : '+lstMergedAccounts);
        System.assertEquals(5, lstMergedAccounts.size());
      
        for(Merged_Account__c mergedAccountRec : lstMergedAccounts){
            System.assertNotEquals(null, mergedAccountRec.Id);
        }
    }

    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodake
        Description         :   This method used to test Cleansed Account Name And Cleansed Unomy Name
        Last Modified Date  :   05 July 2016
        Issue No.           :   ST-1246 
        Last Modified By    :   Mayuresh Ghodake
    **************************************************************************************************************************************/             
    static testmethod void testCleansedAccNameAndCleansedUnomyName(){
         Account accRec1 = new Account(
            Name = 'The Enzigma Software pvt ltd',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId(),
            UUID__c = UUIDHandler.generateVersion4()
        );
       
        insert accRec1;
        String clenaedAccName = OrganizationHelper.getCleansedName(accRec1.Name);
        Debug.log('clenaedAccName==>'+clenaedAccName);
            //AccountServices.createCleansedAccAndUnomyName(accRec1.Name);
        Account acc = [SELECT ID,Name,Cleansed_Account_Name__c FROM Account WHERE Id =: accRec1.Id];
        Debug.Log('********acc.Cleansed_Account_Name__c********'+acc.Cleansed_Account_Name__c);
        system.assertEquals(clenaedAccName,acc.Cleansed_Account_Name__c);
        
         Account accRec2 = new Account(
            Name = 'The Enzigma Software & sons pvt ltd',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId(),
            UUID__c = UUIDHandler.generateVersion4()
        );
        insert accRec2;
        String clenaedAccName1 = AccountServices.createCleansedAccAndUnomyName(accRec2.Name);
        Account acc1 = [SELECT ID,Name,Cleansed_Account_Name__c FROM Account WHERE Id =: accRec2.Id];
        system.assertEquals(clenaedAccName1,acc1.Cleansed_Account_Name__c);
        
        //test for Cleansed Unomy Name
        
        accRec1.Unomy_Company_Name__c = 'The Jack & Jones';
        update accRec1;
        String cleansedUnomyAccName = AccountServices.createCleansedAccAndUnomyName(accRec1.Unomy_Company_Name__c);
        Account acc3 = [SELECT ID,Name,Cleansed_Unomy_Company_Name__c FROM Account WHERE Id =: accRec1.Id];
        system.assertEquals(cleansedUnomyAccName,acc3.Cleansed_Unomy_Company_Name__c);
    }
    
  
    /************************************************************************************************************************************
        Author              :   Mayuresh Ghodke
        Description         :   This method used to test Account naming convention
        Last Modified Date  :   05 July 2016
        Last Modified By    :   Mayuresh Ghodke
    **************************************************************************************************************************************/                 
    static testmethod void testAccountNamingConvention(){
        List<Account> lstOrgAccounts = new List<Account>();
        //Getting Account Recordtype Ids
        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Id MidMarketRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        
        Map<String, Object> accountValuesMap = new Map<String, Object>{'Name' => 'Test Account for Consumer Org', 'RecordTypeId' => consumerRecordTypeId, 'Account_Type__c' => 'Org'};
                
        lstOrgAccounts.add((Account)TestingUtility.createTestRecords(Account.sObjectType, accountValuesMap, false));
        accountValuesMap.put('Name', 'Test Account for Mid Market Org');
        accountValuesMap.put('RecordTypeId', MidMarketRecordTypeId);
        
        lstOrgAccounts.add((Account)TestingUtility.createTestRecords(Account.sObjectType, accountValuesMap, false));
        
        TestingUtility.insertListWithAssert(lstOrgAccounts);
        
        accountValuesMap.put('Name', 'Test Account for Sales');
        accountValuesMap.put('Account_Type__c', 'Sales');
        accountValuesMap.put('ParentId', lstOrgAccounts[0].Id);
        
        List<Account> lstInsertedRecords =  new List<Account>();
        for( Integer index = 0; index < 4; index++ ){
            accountValuesMap.put('Nickname__c', 'Test Account for Sales0'+index);
            lstInsertedRecords.add(TestingUtility.createAccount(accountValuesMap, false));
        }
        
        accountValuesMap.put('ParentId', lstOrgAccounts[1].Id);
        for( Integer index = 0; index < 4; index++ ){
            accountValuesMap.put('Nickname__c', 'Test Account for Sales1'+index);
            lstInsertedRecords.add(TestingUtility.createAccount(accountValuesMap, false));
        }
        
        TestingUtility.insertListWithAssert(lstInsertedRecords);
        
        for(Account objAcc : [SELECT Id, Name, Account_Type__c, Nickname__c, ParentId FROM Account]){
            if(objAcc.Account_Type__c == 'Org'){
                if(objAcc.Id == lstOrgAccounts[0].Id){
                    System.assertEquals('Test Account for Consumer Org', objAcc.Name, 'Account Name Should be Test Account for Org');
                }else if(objAcc.Id == lstOrgAccounts[1].Id){
                    System.assertEquals('Test Account for Mid Market Org', objAcc.Name, 'Test Account for Mid Market Org');
                }
            }else {
                if(objAcc.ParentId == lstOrgAccounts[0].Id){
                    System.assertEquals(lstOrgAccounts[0].Name+':'+objAcc.Nickname__c, objAcc.Name);
                }else if(objAcc.ParentId == lstOrgAccounts[1].Id){
                    System.assertEquals(lstOrgAccounts[1].Name+':'+objAcc.Nickname__c, objAcc.Name);
                }
            }
        }
        
        List<Account> lstSalesAccounts = new List<Account>(); 
        accountValuesMap.put('ParentId', lstInsertedRecords[0].Id);
        
        for( Integer index = 0; index < 2; index++ ){
            accountValuesMap.put('Nickname__c', 'Test Account for Sales'+index);
            lstSalesAccounts.add(TestingUtility.createAccount(accountValuesMap, false));
        }
        
        for(Account objAccount : [SELECT Id, Name, UUID__c, Account_Type__c, Nickname__c, ParentId FROM Account WHERE  ParentId =: lstInsertedRecords[0].Id]){
            System.assertEquals(lstOrgAccounts[0].Name+':'+objAccount.Nickname__c, objAccount.Name);
        }        
    }
    
    static testmethod void testcheckDuplicateNicknameInOrg(){
        List<Account> lstOrgAccounts= new List<Account>();
        List<Account> lstSalesAccounts= new List<Account>();
        
        lstOrgAccounts.add(new Account(Name = 'Test Account for Org 1', Account_Type__c='Org'));
        lstOrgAccounts.add(new Account(Name = 'Test Account for Org 2', Account_Type__c='Org'));
        
        TestingUtility.insertListWithAssert(lstOrgAccounts);
        
        lstOrgAccounts = [Select Id,Org_Id__c,Parent_Org_Id__c from Account Where Id IN:new Set<Id>{lstOrgAccounts[0].Id,lstOrgAccounts[1].Id}];

        for(Account account:lstOrgAccounts){
            System.assertEquals(account.Parent_Org_Id__c, null, 'Parent Org Id Not Populated on Account');//changes in formula field 
            System.assert(account.Org_Id__c==null, 'Org Id Populated on Org Account');
        }
        
        //Inserting a new sales account for above Orgs
        lstSalesAccounts.add(new Account(Name = 'Sales 1 : Org 1', Account_Type__c='Sales',Nickname__c='Pune',ParentId=lstOrgAccounts[0].Id));
        lstSalesAccounts.add(new Account(Name = 'Sales 1 : Org 1', Account_Type__c='Sales',Nickname__c='Pune',ParentId=lstOrgAccounts[1].Id));
        
        TestingUtility.insertListWithAssert(lstSalesAccounts);
        
        lstSalesAccounts = [Select Id,Org_Id__c,Parent_Org_Id__c from Account Where Id IN:new Set<Id>{lstSalesAccounts[0].Id,lstSalesAccounts[1].Id}];

        System.assertEquals(lstSalesAccounts[0].Parent_Org_Id__c,lstOrgAccounts[0].Id , 'Parent Org Id Not Populated on sales account');
        System.assertEquals(lstSalesAccounts[1].Parent_Org_Id__c,lstOrgAccounts[1].Id , 'Parent Org Id Not Populated on sales account');
        
        //Inserting a new sales account with existing Nickname in Org
        Account newSalesAccount=new Account(Name = 'Test Account for Sales 1',Account_Type__c='Sales',Nickname__c='Pune',ParentId=lstOrgAccounts[0].Id); 
        try{
            insert newSalesAccount;
        }catch(Exception ex){
            //'Sales Account with same Nickname "'+account.Nickname__c+'" already exists under the organization. Please choose another nickname.'
            System.assertEquals('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Sales Account with same Nickname "'+newSalesAccount.Nickname__c+'" already exists under the organization. Please choose another nickname.: [Nickname__c]', ex.getMessage(), 'Sales Account Inserted with duplicate name in the organization');
            Debug.log('Exception : '+ex.getMessage());
        }
    }   
    
    public static testMethod void verifyRestrictAccountDeletionWithRelatedRecords(){
        List<Account> lstAccountsToDelete = new List<Account>();
        Account objAccountToBeDeleted = new Account(Name='Account to be deleted');
        TestingUtility.insertWithAssert(objAccountToBeDeleted, 'Account Not Inserted');
        
        Account objAccountToBeRestricted = new Account(Name='Account to be restricted',Account_Type__c='Org');
        TestingUtility.insertWithAssert(objAccountToBeRestricted, 'Account Not Inserted');
        
        Account objChildAccount = new Account(Name='Child of Account to be restricted',ParentId=objAccountToBeRestricted.Id);
        TestingUtility.insertWithAssert(objChildAccount, 'Account Not Inserted');
        
        lstAccountsToDelete.add(objAccountToBeDeleted);
        lstAccountsToDelete.add(objAccountToBeRestricted);
        
        List<Database.DeleteResult> lstDeleteResult;
        try{
            lstDeleteResult = Database.delete(lstAccountsToDelete, false);
        }catch(Exception ex){
            Debug.log(ex.getMessage());
        }finally{
            Debug.Log('lstDeleteResult::'+lstDeleteResult);
            for(Database.DeleteResult result:lstDeleteResult){
                  Debug.Log('result::'+result);
                if(result.id==objAccountToBeDeleted.Id){
                    System.assertEquals(true,result.isSuccess());
                }
                if(result.id==objAccountToBeRestricted.Id){
                    System.assertEquals(false,result.isSuccess());
                    System.assertEquals('You can not delete Accounts having child Accounts, Contacts or Opportunities except while merging.',result.getErrors()[0].getMessage());
                }
            }
        }
        Account objMergeMasterAccount = new Account(Name='Master Merge Account33',Unomy_Company_Id__c=123,Account_Type__c='Org');
        TestingUtility.insertWithAssert(objMergeMasterAccount, 'Account Not Inserted');
        
        Account objMergeChildAccount = new Account(Name='Child Merge Account22',Account_Type__c='Org');  
        TestingUtility.insertWithAssert(objMergeChildAccount, 'Account Not Inserted');
        
        objMergeChildAccount.Unomy_Company_ID__c = 123;
        objMergeChildAccount.Unomy_Updated_DateTime__c = System.now();
        
        Database.SaveResult saveResult = Database.update(objMergeChildAccount);
        System.assertEquals(true, saveResult.isSuccess());
        System.assertEquals(0, [Select Id From Account Where Id=:objMergeChildAccount.Id].size());
    }
        /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to prevent duplicate org creation and duplicate org Name updation
        Created Date        :   13 April 2018
        Last Modified By    :   Krishana Tupe
    **************************************************************************************************************************************/                 
    public static testMethod void verifyRetrictDuplicateOrgName(){
        List<Account> lstAccounts = new List<Account>();
        Account a = new Account(Name = 'Milanjeet', Account_Type__c = 'Org');
        
        Database.SaveResult[] lstSaveResult;
        lstAccounts.add(new Account(Name = 'Milanjeet', Account_Type__c = 'Org'));
        lstAccounts.add(new Account(Name = 'Devdatta', Account_Type__c = 'Org'));
        lstAccounts.add(new Account(Name = 'Devdatta', Account_Type__c = 'Org'));
        lstAccounts.add(new Account(Name = 'Devdatta', Account_Type__c = 'Org'));
        lstAccounts.add(new Account(Name = 'Krishana', Account_Type__c = 'Org'));
        try{
            Test.startTest();
            Database.Insert(a, false);
            Test.stopTest();
            lstSaveResult =  Database.Insert(lstAccounts, false);
        }catch(Exception ex){
            Debug.log('Exceptions---' + ex.getMessage());
        }finally{
            List<Account> lstAccountsToVerify = [Select Id,Name From Account];
            System.assertEquals(3,lstAccountsToVerify.size());
            for(Database.SaveResult result : lstSaveResult){
                if(result == lstSaveResult[0]){
                    System.assertEquals(false, result.isSuccess());
                    System.assertEquals('Milanjeet Organization already exists with the same name',result.getErrors()[0].getMessage());  
                }else if(result.id == lstAccounts[1].Id || result.id == lstAccounts[4].Id ){
                    System.assertEquals(true,result.isSuccess());
                }                
                if(result != lstSaveResult[0] && result.id == null){
                    System.assertEquals(false,result.isSuccess());
                    System.assertEquals('Devdatta Organization already exists with the same name',result.getErrors()[0].getMessage());
                }
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to prevent duplicate org Name updation
        Created Date        :   13 April 2018
        Last Modified By    :   Krishana Tupe
    **************************************************************************************************************************************/                 
    public static testMethod void verifyRetrictDuplicateOrgName1(){
        List<Account> lstAccounts = new List<Account>();
        Database.SaveResult[] lstSaveResult;
        lstAccounts.add(new Account(Name = 'Test Account 1', Account_Type__c = 'Org'));
        lstAccounts.add(new Account(Name = 'Test Account 2', Account_Type__c = 'Org'));
        lstAccounts.add(new Account(Name = 'Test Account 3', Account_Type__c = 'Org'));
        lstAccounts.add(new Account(Name = '', Account_Type__c = 'Org'));    

        Database.Insert(lstAccounts, false);
        
        lstAccounts[0].Name = 'Test Account 2';
        lstAccounts[1].Name = 'Test Account 1';
        lstAccounts[2].Name = 'test account 3';
        
        try{
            Test.startTest();
            lstSaveResult =  Database.update(lstAccounts, false);
            Test.stopTest();
        }catch(Exception ex){
            Debug.log('Exceptions---' + ex.getMessage());
        }finally{
            List<Account> lstAccountsToVerify = [Select Id, Name From Account];
            System.assertEquals(3, lstAccountsToVerify.size());
            for(Database.SaveResult result : lstSaveResult){
                if(result.id == lstAccounts[0].Id){
                    System.assertEquals(false,result.isSuccess());
                    System.assertEquals('Test Account 2 Organization already exists with the same name', result.getErrors()[0].getMessage());
                }else if(result.id == lstAccounts[1].Id){
                    System.assertEquals(false,result.isSuccess());
                    System.assertEquals('Test Account 1 Organization already exists with the same name', result.getErrors()[0].getMessage()); 
                }
                if(result.id == lstAccounts[2].Id){
                    System.assertEquals(true,result.isSuccess());
                }
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Shivprasad Patil
        Description         :   This method used to verify mapping to billing address in account record when unomy data is updated.
        Last Modified Date  :   26 June 2018
        Last Modified By    :   -
    **************************************************************************************************************************************/        
    private static testMethod void testMappingofUnomyDataToBillingAddress() {
        Account objAccount =  new Account(Name = 'Test Account 1',Account_Type__c = 'Org');
        TestingUtility.insertWithAssert(objAccount, 'Account Not Inserted');
        Update new Account(Id=objAccount.Id,Unomy_Updated_DateTime__c = System.now(),
                           Unomy_Location_Address__c='babashop',
                           Unomy_Location_City__c='tezpur',
                           Unomy_Location_State__c = 'bihar',
                           Unomy_Location_Country__c='india',
                           Unomy_Company_Size_Min__c = 55,
                           Unomy_Company_Website__c = 'google.com');
        objAccount = [SELECT Id,BillingAddress,Number_of_Full_Time_Employees__c,AnnualRevenue,Website FROM Account WHERE Id = :objAccount.Id];
        Address billingAddress = objAccount.BillingAddress;
        if(billingAddress != null){
            System.assertEquals('babashop',billingAddress.Street);
            System.assertEquals('tezpur',billingAddress.City);
            System.assertEquals('bihar',billingAddress.State);
            System.assertEquals('india',billingAddress.Country);
            System.assertEquals(55,objAccount.Number_of_Full_Time_Employees__c);
            System.assertEquals('google.com',objAccount.Website);  
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method use to test update the the child records which have same parent_org_id
        Created Date        :   06 July 2018
        Issue No            :   ST-2609
    **************************************************************************************************************************************/  
    public static testMethod void testupdateHierarchyAccountAndOpportunityNameOnMerge() {
        List<Account> lstOrgAccount = new List<Account>();
        Account accOrg1 = new Account(Name='Test Org 1',Account_Type__c='Org');
        lstOrgAccount.add(accOrg1);
        Account accOrg2 = new Account(Name='Test Org 2',Account_Type__c='Org');
        lstOrgAccount.add(accOrg2);
        TestingUtility.insertListWithAssert(lstOrgAccount);
        
        List<Account> lstSalesAccount = new List<Account>();
        Account accSales1 = new Account(Name='Test Sales 1',Account_Type__c='Sales',NickName__c='Sales 1',ParentId=accOrg1.Id);
        lstSalesAccount.add(accSales1);
        Account accSales2 = new Account(Name='Test Sales 2',Account_Type__c='Sales',NickName__c='Sales 2',ParentId=accOrg2.Id);
        lstSalesAccount.add(accSales2);
        TestingUtility.insertListWithAssert(lstSalesAccount);
        
        List<Contact> lstContact  = new List<Contact>();
        Contact con1 = new Contact(LastName='Test Con 1',Email='TestContact1@example.com',AccountId=accSales1.Id);
        lstContact.add(con1);
        Contact con2 = new Contact(LastName='Test Con 2',Email='TestContact2@example.com',AccountId=accSales2.Id);
        lstContact.add(con2);
        Contact con3 = new Contact(LastName='Test Con 3',Email='TestContact3@example.com',AccountId=accSales1.Id);
        lstContact.add(con3);
        Contact con4 = new Contact(LastName='Test Con 4',Email='TestContact4@example.com',AccountId=accSales2.Id);
        lstContact.add(con4);
        TestingUtility.insertListWithAssert(lstContact);
        
        List<Opportunity> lstOpporunity = new List<Opportunity>();
        Opportunity opp1 = new Opportunity(Name='Test Opp 1',AccountId=accOrg1.Id,Primary_Member__c=con3.Id,closeDate=Date.today(),StageName='Selling');
        lstOpporunity.add(opp1);
        Opportunity opp2 = new Opportunity(Name='Test Opp 2',AccountId=accOrg2.Id,Primary_Member__c=con4.Id,closeDate=Date.today(),StageName='Selling');
        lstOpporunity.add(opp2);
        
        TestingUtility.insertListWithAssert(lstOpporunity);
        
        List<Billing_Account__c> lstBillingAccount = new List<Billing_Account__c>();
        Billing_Account__c accBill1 = new Billing_Account__c(Name='Test Billing Account Org 1',Parent_Account__c=accSales1.Id,Primary_Member__c=con1.Id);
        lstBillingAccount.add(accBill1);
        Billing_Account__c accBill2 = new Billing_Account__c(Name='Test Billing Account Org 2',Parent_Account__c=accSales2.Id,Primary_Member__c=con2.Id);
        lstBillingAccount.add(accBill2);
        
        TestingUtility.insertListWithAssert(lstBillingAccount);
        
        Database.MergeResult results = Database.merge(lstSalesAccount[0],lstSalesAccount[1]);
        Debug.log('results===>'+results);
        System.assert(results.isSuccess());
        Database.MergeResult results1 = Database.merge(lstOrgAccount[0],lstOrgAccount[1]);
        System.assert(results1.isSuccess());
        Debug.log('results===>'+results1);
    }
    public List<Account> getOrgAccounts(){
        List<Account> lstAcc = new List<Account>();
        for(integer index=0;index<=10;index++){
            lstAcc.add( new Account(Name='test Org'+index,Account_Type__c='Org'));    
        }
        TestingUtility.insertListWithAssert(lstAcc);
        return lstAcc;
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method use to test restrict sales account to other org and update child records
        Created Date        :   12 July 2018
        Issue No            :   ST-2624,ST-2625
    **************************************************************************************************************************************/  
    public static testMethod void testUpdateOnReparent() {
        try { 
            List<Account> lstOrgAccount = new List<Account>();
            Account accOrg1 = new Account(Name='Test Org 1',Account_Type__c='Org');
            lstOrgAccount.add(accOrg1);
            Account accOrg2 = new Account(Name='Test Org 2',Account_Type__c='Org');
            lstOrgAccount.add(accOrg2);
            TestingUtility.insertListWithAssert(lstOrgAccount);
           
            List<Account> lstSalesAccount = new List<Account>();
            Account accSales1 = new Account(Name='Test Sales 1',Account_Type__c='Sales',NickName__c='Sales 1',ParentId=accOrg1.Id);
            lstSalesAccount.add(accSales1);
            Account accSales2 = new Account(Name='Test Sales 2',Account_Type__c='Sales',NickName__c='Sales 2',ParentId=accOrg2.Id);
            lstSalesAccount.add(accSales2);
            
            TestingUtility.insertListWithAssert(lstSalesAccount);
            
            accOrg1.ParentId=accOrg2.Id;
            TestingUtility.updateWithAssert(accOrg1, 'Account Not Updated Properly');
            
            accSales1.ParentId=accOrg2.Id;
            TestingUtility.updateWithAssert(accSales1, 'Account Not Updated Properly');
            
        } catch(Exception exc) {
            System.assertNotEquals(null, exc);
            Debug.log('exc=='+exc); 
            Boolean expectedExceptionThrown =  exc.getMessage().contains('Reparenting of Sales Account is not allowed outside the Organization.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }  
    }
    
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to test email sending on account ownership change.
        Created Date        :   30 August 2018
        Issue No            :   ST-2696
    **************************************************************************************************************************************/
    public static testMethod void testSendEmailOnOwnerChange(){
        List<User> lstUsers = new List<User>();
        List<Profile> lstTestProfiles = [SELECT Id FROM Profile WHERE Name IN ('WeWork Regional Sales Lead - Beta','System Administrator')];
        User testUser1 = new User(Alias = 'testU', Email='testUser654@example.com', 
                                  EmailEncodingKey='UTF-8', LastName='User1', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = lstTestProfiles[0].Id, IsActive = true,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='testUserName654@example.com',
                                  CommunityNickname ='Test1'+System.now());
        lstUsers.add(testUser1);
        User testUser2 = new User(Alias = 'testU', Email='testUser987@example.com', 
                                  EmailEncodingKey='UTF-8', LastName='User2', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = lstTestProfiles[1].Id, IsActive = true,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='testUserName987@example.com',
                                  CommunityNickname ='Test2'+System.now());
        lstUsers.add(testUser2);
        TestingUtility.insertListWithAssert(lstUsers);
        List<Account> lstAccounts = new List<Account>();
        
        Account accRec = TestingUtility.createAccount('strAccountName', false);
        accRec.UUID__c = '123456789';
        accRec.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        TestingUtility.insertWithAssert(accRec, 'Account Not Inserted');
        debug.log('accRec: '+accRec.Id);
        
        Integer beforeInvocations = Limits.getEmailInvocations();
        system.assertEquals(0, beforeInvocations);
        
        accRec.OwnerId = testUser2.Id;
        TestingUtility.updateWithAssert(accRec, 'Account Not Inserted');
        
        Integer afterInvocations = Limits.getEmailInvocations();
        system.assertEquals(1, afterInvocations);
        
        List<Account> lstAccountsToUpdate = new List<Account>();
        Test.startTest();
      
        Account accRecord2 = TestingUtility.createAccount('strAccountName2', false);
        accRecord2.UUID__c = '123654356';
        accRecord2.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        lstAccounts.add(accRecord2);
        
        Account accRecord3 = TestingUtility.createAccount('strAccountName3', false);
        accRecord3.UUID__c = '123455792';
        accRecord3.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        lstAccounts.add(accRecord3);
        TestingUtility.insertListWithAssert(lstAccounts);
        
        System.runAs(testUser1){
            lstAccounts.clear();
            Integer beforeBulkInvocations = Limits.getEmailInvocations();
            system.assertEquals(0, beforeBulkInvocations);
            
            Account accRecord4 = TestingUtility.createAccount('strAccountName4', false);
            accRecord4.UUID__c = '1236543658';
            accRecord4.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
            lstAccounts.add(accRecord4);
            
            Account accRecord5 = TestingUtility.createAccount('strAccountName5', false);
            accRecord5.UUID__c = '1234557564';
            accRecord5.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
            lstAccounts.add(accRecord5);
            TestingUtility.insertListWithAssert(lstAccounts);
            
            accRecord4.OwnerId = testUser2.Id;
            accRecord5.OwnerId = testUser2.Id;
            lstAccountsToUpdate.add(accRecord4);
            lstAccountsToUpdate.add(accRecord5);
            TestingUtility.updateListWithAssert(lstAccountsToUpdate);
            
            Integer afterBulkInvocations = Limits.getEmailInvocations();
            system.assertEquals(1, afterBulkInvocations);
        }
        
        System.runAs(testUser2){
            lstAccountsToUpdate.clear();
            Integer beforeBulkInvocations = Limits.getEmailInvocations();
            system.assertEquals(1, beforeBulkInvocations);
            
            accRecord2.OwnerId = testUser1.Id;
            accRecord3.OwnerId = testUser1.Id;
            lstAccountsToUpdate.add(accRecord2);
            lstAccountsToUpdate.add(accRecord3);
            TestingUtility.updateListWithAssert(lstAccountsToUpdate);
            
            Integer afterBulkInvocations = Limits.getEmailInvocations();
            system.assertEquals(2, afterBulkInvocations);
        }        
        Test.stopTest();
    }
}