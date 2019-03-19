/************************************************************************************************************************************
    Author      : 	Prashant Mane
    Description : 	This class is used to test BillingAccountTriggerHandler

    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE            AUTHOR                     DETAIL
    1           06 June 2018    Prashant Mane	           Initial Developement
**************************************************************************************************************************************/
@isTest
private class BillingAccountTriggerHandlerTest{
    @TestSetup
    static void initData(){         
        SalesConsoleSettings.createSettings();
        List<Billing_Account__c> lstBillAccounts = new List<Billing_Account__c>();
        
        lstBillAccounts.add(TestingUtility.createBillingAccount(new Map<String,Object>{'Name'=>'Test Billing Account 1','UUID__c'=>UUIDHandler.generateVersion4()},false));
        lstBillAccounts.add(TestingUtility.createBillingAccount(new Map<String,Object>{'Name'=>'The Enzigma Software & sons pvt ltd','UUID__c'=>UUIDHandler.generateVersion4()},false));
        lstBillAccounts.add(TestingUtility.createBillingAccount(new Map<String,Object>{'Name'=>'The Jack & Jones','UUID__c'=>UUIDHandler.generateVersion4()},false));
        lstBillAccounts.add(TestingUtility.createBillingAccount(new Map<String,Object>{'Name'=>'The Enzigma Software pvt ltd','UUID__c'=>UUIDHandler.generateVersion4()},false));
        TestingUtility.insertListWithAssert(lstBillAccounts);
        
        TestingUtility.createContact(new Map<String,Object>{'LastName'=>'Contact 1','Email'=>'testContact1@example.com'}, true);
    }
    /************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method used to verify Set Primary Member of Bill Account
        Last Modified Date  :   06 June 2018
        Last Modified By    :   Prashant Mane
    **************************************************************************************************************************************/        
    private static testMethod void testSetAccountPrimaryMember() {
         //pre-context
        Billing_Account__c billAcc = [SELECT Id FROM Billing_Account__c WHERE Name = 'Test Billing Account 1'];
        Contact  objContact = [SELECT Id FROM Contact WHERE Email = 'testContact1@example.com'];
        objContact.Billing_Account__c = billAcc.Id;
        update objContact;
        billAcc.Phone__c = 123654879;        
        update billAcc;
        Billing_Account__c updatedAcc = [SELECT Id,Primary_Member__c FROM Billing_Account__c WHERE Id = : billAcc.Id];
        system.assertEquals(updatedAcc.Primary_Member__c, objContact.Id, 'Contact should be primary member of account.');
    }
             
    /************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method used to test Cleansed Account Name And Cleansed Unomy Name
        Last Modified Date  :   06 June 2018
        Issue No.           :   
        Last Modified By    :   Prashant Mane
    **************************************************************************************************************************************/             
    static testmethod void testCleansedAccNameAndCleansedUnomyName(){
        set<String> setBillAccountNames = new set<String>{'The Enzigma Software & sons pvt ltd','The Jack & Jones','The Enzigma Software pvt ltd','Test Billing Account 1'};
        List<Billing_Account__c> lstBillAcc = [SELECT Id, Name,Cleansed_Account_Name__c FROM Billing_Account__c WHERE Name In : setBillAccountNames];
        
        String cleanedBillAccName = OrganizationHelper.getCleansedName(lstBillAcc[2].Name);
        system.assertEquals(cleanedBillAccName,lstBillAcc[2].Cleansed_Account_Name__c);
        
        String clenaedAccName1 = OrganizationHelper.getCleansedName(lstBillAcc[0].Name);
        system.assertEquals(clenaedAccName1,lstBillAcc[0].Cleansed_Account_Name__c);
        
        //test for Cleansed Unomy Name
        
        TestingUtility.updateWithAssert(TestingUtility.createBillingAccount(new Map<String,Object>{'Id'=>lstBillAcc[1].Id,'Unomy_Company_Name__c'=>'The Jack & Jones'}, false));

        String cleansedUnomyAccName = OrganizationHelper.getCleansedName('The Jack & Jones');
        Billing_Account__c BillgAccount = [SELECT ID,Name,Cleansed_Unomy_Company_Name__c FROM Billing_Account__c WHERE Id =: lstBillAcc[1].Id];
        system.assertEquals(cleansedUnomyAccName,BillgAccount.Cleansed_Unomy_Company_Name__c);
        
    }
    
    /************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method used verify GenerateUUID method of BillingAccountTriggerHandler
        Last Modified Date  :   06 June 2018
        Last Modified By    :   Prashant Mane
    **************************************************************************************************************************************/             
    static testmethod void testGenerateUUID(){
        List<Billing_Account__c> lstAccountInserted = [Select Id,Name,UUID__c From Billing_Account__c WHERE Lead_Source__c = null Or Lead_Source__c != 'Id'];
        debug.log('lstAccountInserted==>'+lstAccountInserted);
        for(integer index = 0 ;index < lstAccountInserted.size() ; index++){
            System.assertNotEquals(null,lstAccountInserted[index].UUID__c,'UUID not generated');
        }
    }
    
    static testmethod void verifysetUltimateParentToAccount(){
        Account acc1 = new Account(Name='Test Org 1',Account_Type__c='Org');
        TestingUtility.insertWithAssert(acc1);
        Account acc2 = new Account(Name='Test Sales 1',Account_Type__C='Sales',Nickname__c='Sales 1',ParentId=acc1.Id);
        TestingUtility.insertWithAssert(acc2);
        Account acc3 = new Account(Name='Test Sales 2',Account_Type__C='Sales',Nickname__c='Sales 2',ParentId=acc2.Id);
        TestingUtility.insertWithAssert(acc3);
        Billing_Account__c objBillAcc = new Billing_Account__c(Name='Test Billing Acc 1',Parent_Account__c=acc1.Id); 
        TestingUtility.insertWithAssert(objBillAcc);
        List<Billing_Account__c> lstBil = new List<Billing_Account__c>();
        
        for(Integer index = 0; index <= 5; index++){
            Billing_Account__c billAcc = new Billing_Account__c(Name='Test Billing '+Index,Parent_Account__c=acc1.Id); 
            lstBil.add(billAcc); 
        }
        insert lstBil;
        System.debug('lstBil==>'+lstBil);
        List<Billing_Account__c> lstBillAcc = [Select Id,Name,Parent_Account__c,Ultimate_Parent_Org__c From Billing_Account__c where Id IN:lstBil];
        for(Billing_Account__c objBill : lstBillAcc){
            Debug.Log('objBill--->'+objBill);
            System.assertNotEquals(null,objBill.Id);
            System.assertNOTEquals(null,objBill.Ultimate_Parent_Org__c);
        }
    }
    
    public static void createRecordsForChildRecordsParent(){
        List<Billing_Account__c> lstBillingAccToInsert = new List<Billing_Account__c>();
        List<Contact> lstContactToInsert = new List<Contact>();
        List<Opportunity> lstOpportunityToInsert = new List<Opportunity>();
        List<Account> lstAccToInsert = new List<Account>();
        
        Account orgAccount = TestingUtility.createAccount(new Map<String,Object>{'Name'=>'Org Account','UUID__c'=>'account-uuid-Org','Account_Type__c'=>'Org'},true);
        
        lstAccToInsert.add(TestingUtility.createAccount(new Map<String,Object>{'Name'=>'Account 1','UUID__c'=>'account-uuid0','Account_Type__c'=>'Org','ParentId'=>orgAccount.Id},false));
        lstAccToInsert.add(TestingUtility.createAccount(new Map<String,Object>{'Name'=>'Account 2','UUID__c'=>'account-uuid1','Account_Type__c'=>'Org','ParentId'=>orgAccount.Id},false));
        
        TestingUtility.insertListWithAssert(lstAccToInsert);
        Debug.log('lstAccToInsert==>'+lstAccToInsert);
        
        lstBillingAccToInsert.add(TestingUtility.createBillingAccount(new Map<String,Object>{'Name'=>'Test Account 1','Parent_Account__c'=>lstAccToInsert[0].Id},false));
        lstBillingAccToInsert.add(TestingUtility.createBillingAccount(new Map<String,Object>{'Name'=>'Test Account 2','Parent_Account__c'=>lstAccToInsert[1].Id},false));
        
        TestingUtility.insertListWithAssert(lstBillingAccToInsert);       
        Debug.log('lstBillingAccToInsert==>'+lstBillingAccToInsert);
        
        lstContactToInsert.add(TestingUtility.createContact(new Map<String,Object>{'FirstName'=>'Contact1','LastName'=>'LastName','Email'=>'testContact29062018K1@example.com','AccountId'=>lstAccToInsert[0].Id,'Billing_Account__c'=>lstBillingAccToInsert[0].Id},false));
        lstContactToInsert.add(TestingUtility.createContact(new Map<String,Object>{'FirstName'=>'Contact2','LastName'=>'LastName2','Email'=>'testContact29062018K2@example.com','AccountId'=>lstAccToInsert[0].Id,'Billing_Account__c'=>lstBillingAccToInsert[0].Id},false));
        TestingUtility.insertListWithAssert(lstContactToInsert);   
        
        lstOpportunityToInsert.add(TestingUtility.createOpportunity(new Map<String, Object>{'StageName'=>'Qualifying','AccountId'=>lstAccToInsert[0].Id,'Billing_Account__c'=>lstBillingAccToInsert[0].Id}, false));
        lstOpportunityToInsert.add(TestingUtility.createOpportunity(new Map<String, Object>{'StageName'=>'Qualifying','AccountId'=>lstAccToInsert[0].Id,'Billing_Account__c'=>lstBillingAccToInsert[0].Id}, false));
        TestingUtility.insertListWithAssert(lstOpportunityToInsert);
    }
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This Method is used to verify parenting of child records (Opportunities and Contacts) of Billing Account for same Org hierarchy.
        Created Date  		:   29 June 2018       
    **************************************************************************************************************************************/    
    public static testMethod void verifychangeChildRecordsParent1() {
        createRecordsForChildRecordsParent();
        List<Billing_Account__c> lstBillingAccounts =  [Select Id,Name,Parent_Account__c,Parent_Org__c,Ultimate_Parent_Org__c,OwnerId,(Select Id,Name,AccountId,OwnerId From Contacts__r),(Select Id,Name,AccountId,OwnerId From Opportunities__r) FROM Billing_Account__c WHERE Name IN ('Test Account 1','Test Account 2')];              
        Debug.log('lstBillingAccountss==>'+lstBillingAccounts);
        
        List<Account> lstAccToInsert = [SELECT ID FROM Account WHERE UUID__c In ('account-uuid-Org','account-uuid0','account-uuid1')];
        Debug.log('lstAccToInsert==>'+lstAccToInsert);
        Test.startTest(); 
        Billing_Account__c billtoUpdate = new Billing_Account__c();
        billtoUpdate.Id = lstBillingAccounts[0].Id;
        billtoUpdate.Parent_Account__c = lstAccToInsert[0].Id;
        DEbug.log('billtoUpdate verifychangeChildRecordsParent1==>'+billtoUpdate);
        Database.update(billtoUpdate,false); 
        Test.stopTest(); 
        
        List<Billing_Account__c> lstBillingAccountAfterUpdate =  [Select Id,Name,Parent_Account__c,OwnerId,(Select Id,Name,AccountId,OwnerId From Contacts__r),(Select Id,Name,AccountId,OwnerId From Opportunities__r) FROM Billing_Account__c WHERE Id=: billtoUpdate.Id];              
        Debug.log('lstBillingAccountAfterUpdate==>'+lstBillingAccountAfterUpdate);         
        //System.assertEquals(lstBillingAccountAfterUpdate[0].Parent_Account__c, lstAccToInsert[1].Id);
        List<String> lstChilds = new List<String>{'Contacts__r','Opportunities__r'};                                       
            for(String strChild:lstChilds){                         
                System.assertNotEquals(null,lstBillingAccountAfterUpdate[0].getsObjects(strChild));
                System.assertNotEquals(null,lstBillingAccounts[0].getsObjects(strChild));                
                System.assertEquals(2,lstBillingAccountAfterUpdate[0].getsObjects(strChild).size()); 
                System.assertEquals(2,lstBillingAccounts[0].getsObjects(strChild).size()); 
                for(Sobject childrecAfter : lstBillingAccountAfterUpdate[0].getsObjects(strChild)){
                    Debug.log('childrecAfter==>'+childrecAfter);
                    for(Sobject childrecBefore : lstBillingAccounts[0].getsObjects(strChild)){
                        if(childrecAfter.Id==childrecBefore.Id){                            
                            //System.assertEquals(lstAccToInsert[1].Id,childrecAfter.get('AccountId'));
                            System.assertEquals(childrecBefore.get('OwnerId'),childrecAfter.get('OwnerId'));
                        }
                    }                    
                }
            }
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This Method is used to verify parenting of child records (Opportunities and Contacts) of Billing Account for diffrent Org hierarchy.
        Created Date  		:   07 July 2018       
    **************************************************************************************************************************************/    
    public static testMethod void verifychangeChildRecordsParent2() {         
        createRecordsForChildRecordsParent();
        List<Billing_Account__c> lstBillingAccounts =  [Select Id,Name,Parent_Account__c,Parent_Org__c,Ultimate_Parent_Org__c,OwnerId,(Select Id,Name,AccountId,OwnerId From Contacts__r),(Select Id,Name,AccountId,OwnerId From Opportunities__r) FROM Billing_Account__c WHERE Name IN ('Test Account 1','Test Account 1')];              
        Debug.log('lstBillingAccountss==>'+lstBillingAccounts);
        
        List<Account> lstAccToInsert = [SELECT ID FROM Account WHERE UUID__c In ('account-uuid-Org','account-uuid0','account-uuid1')];
        Debug.log('lstBillingAccountss==>'+lstBillingAccounts);
        
        Test.startTest(); 
        Billing_Account__c billtoUpdate = new Billing_Account__c();
        billtoUpdate.Id = lstBillingAccounts[0].Id;
        billtoUpdate.Parent_Account__c = lstAccToInsert[1].Id;
        try{
            Database.update(billtoUpdate,false); 
        }catch(Exception pEx){
            Debug.log('pEx==>'+pEx);
            System.assert(pEx.getMessage().contains('Reparenting is allowed only within the same org hierarchy.'));
        }       
        Test.stopTest();
    }
    
    public static testMethod void verifyMapParentAccountAndContactsWithoutAccountId(){
        Contact objContactToUpdate = [SELECT Id FROM Contact WHERE Email = 'testContact1@example.com'];
        
        Billing_Account__c objBillAccount = TestingUtility.createBillingAccount(new Map<String,Object>{'Name'=>'Test Bill Contact Map','Primary_Member__c'=>objContactToUpdate.Id},true);
        
        List<Billing_Account__c> lstBillingAccount = [SELECT Id,Parent_Account__c FROM Billing_Account__c WHERE Id =: objBillAccount.Id];
        system.assertNotEquals(null, lstBillingAccount[0].Parent_Account__c);
        
        List<Account> lstAccount =  TestingUtility.getSalesAccountsWithHierarchy(10,true);
        Map<Id,List<Account>> mapAccountsWithHierarchy = new Map<Id,List<Account>>();
        mapAccountsWithHierarchy.put(TestingUtility.orgAccountIdOnInsert,lstAccount);
        
        Map<String,Object> mapCriteria = new  Map<String,Object>{'Unomy_Company_ID__c'=>576,'Unomy_Company_Name__c'=>'Test Billing Account 1','Cleansed_Company_Name__c'=>OrganizationHelper.getCleansedName('The Enzigma Software pvt ltd'),'Email'=>'test@example.com'};
        List<Contact> lstContacts = OrganizationHelperTest.createContactsWithOrgFinderCriteria(mapCriteria, null);
		Debug.log('lstContacts ==>'+lstContacts);
        Set<String> setEmails = new Set<String>();
        for(Integer index = 0; index < lstContacts.size(); index++){
            lstContacts[index].Email = 'test'+index+Datetime.now().getTime()+'@example.com';
            setEmails.add(lstContacts[index].Email);
            lstContacts[index].LastName = 'test12345'+Datetime.now().getTime();
        }
        lstContacts.add(TestingUtility.createContact(new Map<String,Object>{'LastName'=>'Contact 14549','Email'=>'testContact14549@example.com','AccountId'=>lstAccount[lstAccount.size()-1].Id}, false));        
    	TestingUtility.insertListWithAssert(lstContacts);
        
        Debug.log('lstContacts=>'+lstContacts);
        set<String> setBillAccountNames = new set<String>{'The Enzigma Software & sons pvt ltd','The Jack & Jones','The Enzigma Software pvt ltd','Test Billing Account 1'};
        List<Billing_Account__c> lstBillAcc = [SELECT Id FROM Billing_Account__c WHERE Name In : setBillAccountNames];
        
        Debug.log('lstBillAcc==>'+lstBillAcc);
        
        Test.startTest();
        for(Contact primaryMember : lstContacts){
            if(String.isNotBlank(primaryMember.AccountId)){
                lstBillAcc[0].Primary_Member__c = primaryMember.Id;
            }else if(String.isNotBlank(primaryMember.Unomy_Company_Name__c)){
                lstBillAcc[1].Primary_Member__c = primaryMember.Id;
            }else if(primaryMember.Unomy_Company_ID__c != null){
                lstBillAcc[2].Primary_Member__c = primaryMember.Id;
            }else if(String.isNotBlank(primaryMember.Cleansed_Company_Name__c)){
                lstBillAcc[3].Primary_Member__c = primaryMember.Id;
            }
        }
        TestingUtility.updateListWithAssert(lstBillAcc);
        Test.stopTest();
        for(Billing_Account__c billAcc : [SELECT Id, Parent_Account__c FROM Billing_Account__c WHERE Name In : setBillAccountNames]){
            system.assertNotEquals(null, billAcc.Parent_Account__c);
        }
    }
}