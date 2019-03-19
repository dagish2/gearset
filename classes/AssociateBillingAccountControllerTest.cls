/************************************************************************************************************************************
    Author      :   Dipak Pawar
    Description :   This class contain all test methods related to AssociateBillingAccountController class.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           18 July 2018        Dipak Pawar      Initial Developement
**************************************************************************************************************************************/
@isTest
public class AssociateBillingAccountControllerTest {
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        
        Account acc = new Account(Name='TestOrg1122',Account_Type__c='Org',Cleansed_Unomy_Company_Name__c ='testorg1122');
        insert acc;
        System.assertNotEquals(null, acc.Id);
        Billing_Account__c billAcc1 = new Billing_Account__c(Name='Test Bill 1',Parent_Account__c=acc.Id);
        insert billAcc1;
        System.assertNotEquals(null, billAcc1.Id);
        
        //secnario 2 : 
        Contact conRec = new Contact(
            firstname  = 'John',
            lastname   = 'Rambo',
            email     = 'test@example.com',
            accountID  = acc.Id,
            //Billing_Account__c =billAcc1.Id, 
            Status__c  = 'active'
        );
        
        insert conRec;
        System.assertNotEquals(null, conRec.Id);
    }   
    
    /************************************************************************************************************************************
    Author              : Priyanka Ambre
    Description         : This method tests the verifyGetOpportunityData.
    Created Date        : 18 July 2018 
    Issue No            : 
    **************************************************************************************************************************************/
    static testMethod void verifyGetOpportunityData(){
        //OrgAccount
        Test.startTest();
        Account orgAccRec = new Account(Name = 'orgAccRec',Number_of_Full_Time_Employees__c=1000, Account_Type__c='Org', Unomy_Company_Name__c='orgAcc');
        TestingUtility.insertWithAssert(orgAccRec);
        System.assertNotEquals(null, orgAccRec.Id);
        
        //Accounts
        List<Account> lstAccounts = new List<Account>();
        Account objAcc1 = new Account(Name = 'strAccountName1',Nickname__c = 'strAcc',Account_Type__c = 'Sales',ParentId = orgAccRec.id);
        lstAccounts.add(objAcc1); 
        TestingUtility.insertListWithAssert(lstAccounts);
        
        lstAccounts.clear();
        Billing_Account__c objBill1 = new Billing_Account__c(Name = 'strBillAccount1',Parent_Account__c = objAcc1.id);
        TestingUtility.insertWithAssert(objBill1); 
        
        Contact objConsumerCon = new Contact(firstname = 'John',lastname = 'Rambo',email = 'john.snow1@example.com', accountID = objAcc1.Id, Status__c = 'active');
        TestingUtility.insertWithAssert(objConsumerCon);
        
        Opportunity oppRecCons = TestingUtility.createOpportunity(objAcc1.Id, false);
        oppRecCons.Primary_Member__c = objConsumerCon.Id;
        oppRecCons.StageName = 'Selling';
        oppRecCons.CloseDate = system.today().addDays(5);
        oppRecCons.Membership_Agreement_Notes__c = 'Opprtunity 3 Membership_Agreement_Notes__c';
        oppRecCons.Tour_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecCons.Tour_Outcome_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecCons.Description = 'Opprtunity 3 Tour_Notes__c'; 
        oppRecCons.Owner_Auto_Assign__c = true; 
        TestingUtility.insertWithAssert(oppRecCons);
        AssociateBillingAccountController.AssignToAccountData objAssignToAccountData = (AssociateBillingAccountController.AssignToAccountData)JSON.deserialize(String.valueOf(AssociateBillingAccountController.getOpportunityData(oppRecCons.id).data), AssociateBillingAccountController.AssignToAccountData.class);
        System.assertEquals(1, objAssignToAccountData.billingAccounts.size());
        System.assertEquals(oppRecCons.Id, objAssignToAccountData.opportunityRecord.Id);
        System.assertEquals(orgAccRec.Id, objAssignToAccountData.ultimateParentOrgId);
        System.assertEquals(False, objAssignToAccountData.isValidStage);
        System.assertEquals(True, objAssignToAccountData.isValidForAssociation);
        
        Opportunity oppRecCons1 = TestingUtility.createOpportunity(objAcc1.Id, false);
        oppRecCons1.Primary_Member__c = objConsumerCon.Id;
        oppRecCons1.Billing_Account__c = objBill1.Id;
        oppRecCons1.StageName = 'Selling';
        TestingUtility.insertWithAssert(oppRecCons1);
        AssociateBillingAccountController.AssignToAccountData objAssignToAccountData1 = (AssociateBillingAccountController.AssignToAccountData)JSON.deserialize(String.valueOf(AssociateBillingAccountController.getOpportunityData(oppRecCons1.id).data), AssociateBillingAccountController.AssignToAccountData.class);
        
        System.assertEquals(1, objAssignToAccountData1.billingAccounts.size());
        System.assertEquals(oppRecCons1.Id, objAssignToAccountData1.opportunityRecord.Id);
        System.assertEquals(orgAccRec.Id, objAssignToAccountData1.ultimateParentOrgId);
        System.assertEquals(True, objAssignToAccountData1.isValidStage);
        System.assertEquals(True, objAssignToAccountData1.isValidForAssociation);
        
        Opportunity oppRecCons2 = TestingUtility.createOpportunity(orgAccRec.Id, false);
        oppRecCons2.Primary_Member__c = objConsumerCon.Id;
        oppRecCons2.StageName = 'Closing';
        TestingUtility.insertWithAssert(oppRecCons2);
        AssociateBillingAccountController.AssignToAccountData objAssignToAccountData2 = (AssociateBillingAccountController.AssignToAccountData)JSON.deserialize(String.valueOf(AssociateBillingAccountController.getOpportunityData(oppRecCons2.id).data), AssociateBillingAccountController.AssignToAccountData.class);
        
        System.assertEquals(1, objAssignToAccountData2.billingAccounts.size());
        System.assertEquals(oppRecCons2.Id, objAssignToAccountData2.opportunityRecord.Id);
        System.assertEquals(orgAccRec.Id, objAssignToAccountData2.ultimateParentOrgId);
        System.assertEquals(True, objAssignToAccountData2.isValidStage);
        System.assertEquals(True, objAssignToAccountData2.isValidForAssociation);
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              : Pragalbha Mahajan
        Description         : This method test methods for createNewBillingAccount.
        Created Date        : 24 July 2018 
        Issue No            : 
    **************************************************************************************************************************************/ 
    public static testMethod void createNewBillingAccountTest() {
        List<Billing_Account__c> lstBill= [Select ID,UUID__c, Name From Billing_Account__c];         
        List<Account> lstAccounts = [SELECT Id,Name FROM Account WHERE Name = 'TestOrg1122'];
        List<Contact> lstContact = [SELECT Id,Name,UUID__c,AccountId,Billing_Account__c,Email FROM Contact WHERE Email = 'test@example.com'];
        
        String accountUUID = 'df122ca8-7777-5555-6666-86f1146227c7';
        String accid = String.valueOf(lstAccounts[0].Id);
        DatabaseResult result1 = AssociateBillingAccountController.createNewBillingAccount(new Map<String,String>{'contactId'=>lstContact[0].Id,'primaryMemberUUID'=>'df122ca8-3333-2222-1111-86f1146227c7','billingAccountUUID'=> accountUUID,'AccountName'=>'TestAccount1','parentId'=> accid,'contactAccountId'=> lstContact[0].AccountId});
        System.assertNotEquals(null,result1);
        Billing_Account__c billAccId = (Billing_Account__c)result1.data;
        List<Billing_Account__c> lstBillAcc = [SELECT Id,Name,UUID__c,Primary_Member__c FROM Billing_Account__c WHERE Id=:billAccId.Id];
        List<Contact> lstContact1 = [SELECT Id,Name,UUID__c,AccountId,Billing_Account__c FROM Contact WHERE Email = 'test@example.com'];
        System.assertEquals(lstBillAcc[0].Primary_Member__c, lstContact1[0].Id);
        
        System.assertEquals(lstContact1[0].UUID__c, 'df122ca8-3333-2222-1111-86f1146227c7');
        System.assertEquals(lstContact1[0].Billing_Account__c, lstBillAcc[0].Id);
        
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        accRec = [SELECT Id,Name,UUID__c FROM Account WHERE Id=:accRec.Id];
        String accRecid = String.valueOf(accRec.Id);
        
        Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, true);
        System.assertNotEquals(null,oppRec.Id);
        DatabaseResult result2 = AssociateBillingAccountController.createNewBillingAccount(new Map<String,String>{'accountUUID'=>accRec.UUID__c,'AccountName'=>'strAccountName','parentId'=> accRecid,'contactName'=>'Test Contact','oppId'=> oppRec.Id});
        System.assertNotEquals(null,result2);
        Billing_Account__c objBillAcc = (Billing_Account__c)result2.data;
        List<Billing_Account__c> lstBillAccount = [Select ID,UUID__c From Billing_Account__c WHERE Id =: objBillAcc.Id];
        List<Opportunity> lstOpportunity = [SELECT Id,Billing_Account__c FROM Opportunity];
        
        System.assertEquals(lstOpportunity[0].Billing_Account__c, lstBillAccount[0].Id);
    }
}