/************************************************************************************************************************************
    Author      :  Pragalbha Mahajan    
    Description :  This class contain all aura methods related new Account flow.
    
    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR          		DETAIL
     1          3 Sept 2018       	Pragalbha Mahajan    	Initial Developement
**************************************************************************************************************************************/

@isTest
public class NewOrganizationControllerTest {
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];	
        Profile testProfile1 = [SELECT Id FROM Profile WHERE Name='WeWork Enterprise Solutions'];
        List<User> lstUsers = new List<User>();
        User tstUser = new user(alias = 'test123', email='test123@noemail.com', 
                                emailencodingkey='UTF-8', firstName='Chris', lastname='Bonapart', languagelocalekey='en_US',
                                localesidkey='en_IN', profileid = testProfile.Id, country='India',
                                timezonesidkey='Asia/Kolkata', username='testchris_g@noemail.com'); 
        lstUsers.add(tstUser);
        
        User tstUser1 = new user(alias = 'test111', email='test111@noemail.com', 
                                emailencodingkey='UTF-8', firstName='John', lastname='Bonapart', languagelocalekey='en_US',
                                localesidkey='en_IN', profileid = testProfile1.Id, country='India',
                                timezonesidkey='Asia/Kolkata', username='johnBonapart_g@noemail.com'); 
        lstUsers.add(tstUser1);
        TestingUtility.insertListWithAssert(lstUsers);
        
        Contact contactRec = new Contact(FirstName = 'John1', LastName = 'Smith1', Email = 'testContact1@example.com', Status__c = 'active');
        TestingUtility.insertWithAssert(contactRec);
        Account accRec = new Account(Name = 'strAccount', Number_of_Full_Time_Employees__c = 1000, Website = 'testaccount.in', Interested_in_Number_of_Desks__c = 100, Phone = '9845623584');
        TestingUtility.insertWithAssert(accRec);
        Billing_Account__c billingAcc = new Billing_Account__c(Name = 'tstBillingAcc');
        TestingUtility.insertWithAssert(billingAcc);
    }
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method tests Account flow for user without permission set.
        Last Modified Date  :   4 Sept 2018
		Issue No			:   ST-2731
    **************************************************************************************************************************************/
    public static testMethod void verifyAccountFlowForUserWithOutPermission(){
        List<User> lstUser = [SELECT Id, Name, UserName, ProfileId, Profile.Name  FROM User WHERE UserName = 'johnBonapart_g@noemail.com'];
        System.runAs(lstUser[0]){
			DatabaseResult result = NewOrganizationController.getNewOrganizationData();  
            NewOrganizationController.NewOrganizationSettingWrapper permission = (NewOrganizationController.NewOrganizationSettingWrapper) result.data;
            System.assertEquals(false, permission.isUserCreateEnterpriseOrg);
            System.assertEquals(false, permission.isUserCreateOrg);
        }
    }
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method tests Account flow for user with permission set.
        Last Modified Date  :   4 Sept 2018
		Issue No			:   ST-2731
    **************************************************************************************************************************************/
    public static testMethod void verifyAccountFlowForUserWithPermissionSet(){
        List<User> lstUser = [SELECT Id,Name,UserName  FROM User WHERE UserName = 'testchris_g@noemail.com'];
        PermissionSet objPermission = [SELECT Id, Name, ProfileId FROM PermissionSet WHERE Name = 'Can_Create_Organization'];
        insert new PermissionSetAssignment(AssigneeId = lstUser[0].id, PermissionSetId = objPermission.Id);
        System.runAs(lstUser[0]){
			DatabaseResult result = NewOrganizationController.getNewOrganizationData();  
            NewOrganizationController.NewOrganizationSettingWrapper permission = (NewOrganizationController.NewOrganizationSettingWrapper) result.data;
            System.assertEquals(true, permission.isUserCreateEnterpriseOrg);
            System.assertEquals(true, permission.isUserCreateOrg);
        }
    }
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method tests CreateNewOrgAndContact.
        Last Modified Date  :   4 Sept 2018
		Issue No			: 	ST-2729
    **************************************************************************************************************************************/
    public static testMethod void verifyCreateNewOrgAndContact(){
        Account accRec = new Account(Name = 'strAccount1', Number_of_Full_Time_Employees__c = 1000, Website = 'testaccount1.in', Interested_in_Number_of_Desks__c = 100, Phone = '98456235644');
        Contact contactRec = new Contact(FirstName = 'John2', LastName = 'Smith2', Email = 'testContact2@example.com', Status__c = 'active');
        
        DatabaseResult result = NewOrganizationController.createNewOrganization(new List<sObject>{accRec, contactRec});
        List<Contact> lstContacts = [SELECT Id, Name, Email FROM Contact WHERE Email = 'testContact2@example.com'];
        System.assertNotEquals(lstContacts[0].Id, null);
        List<Account> lstAccounts = [SELECT Id, Name, RecordType.Name, Primary_Member__c, Account_Type__c FROM Account WHERE Website = 'testaccount1.in'];
        System.assertNotEquals(lstAccounts[0].Id, null);
        System.assertEquals(lstAccounts[0].Primary_Member__c, lstContacts[0].Id);
    }
    
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method tests CreateNewOrg with existing contact.
        Last Modified Date  :   4 Sept 2018
		Issue No			: 	ST-2729
    **************************************************************************************************************************************/
    public static testMethod void verifyCreateNewOrgWithExistingContact(){
        try{
            Account accRec = new Account(Name = 'strAccount1', Number_of_Full_Time_Employees__c = 1000, Website = 'testaccount1.in', Interested_in_Number_of_Desks__c = 100, Phone = '9845623645');
            List<Contact> lstContacts = [SELECT Id, Name, Email, AccountId FROM Contact WHERE Email = 'testContact1@example.com'];
            List<Billing_Account__c> lstBillingAccount = [SELECT Id, Name, Primary_Member__c, Parent_Account__c FROM Billing_Account__c];
            DatabaseResult result = NewOrganizationController.createNewOrganization(new List<sObject>{accRec, lstContacts[0], lstBillingAccount[0]});
            List<Account> lstAccounts = [SELECT Id, Name, RecordType.Name, Primary_Member__c, Account_Type__c FROM Account WHERE Website = 'testaccount1.in'];
            System.assertEquals(lstContacts[0].AccountId, lstAccounts[0].Id);
            
            DatabaseResult result1 = NewOrganizationController.createNewOrganization(new List<sObject>{lstContacts[0]});
            Account acc = (Account) result1.data;
            System.assertEquals(acc, null);
        }catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method tests CreateNewOrg with existing contact and billing account.
        Last Modified Date  :   4 Sept 2018
		Issue No			: 	ST-2729
    **************************************************************************************************************************************/
    public static testMethod void verifyCreateNewOrgWithExistingContactAndBillingAccount(){
        try{
            Account accRec = new Account(Name = 'strAccount1', Number_of_Full_Time_Employees__c = 1000, Website = 'testaccount1.in', Interested_in_Number_of_Desks__c = 100, Phone = '9845623645');
            List<Contact> lstContacts = [SELECT Id, Name, Email, AccountId FROM Contact];
            List<Billing_Account__c> lstBillingAccount = [SELECT Id, Name, Primary_Member__c, Parent_Account__c FROM Billing_Account__c];
            DatabaseResult result = NewOrganizationController.createNewOrganization(new List<sObject>{accRec, lstContacts[0]});
            List<Account> lstAccounts1 = [SELECT Id, Name, RecordType.Name, Primary_Member__c, Account_Type__c FROM Account WHERE Website = 'testaccount1.in'];
            System.assertEquals(lstContacts[0].AccountId, lstAccounts1[0].Id);
        }catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method tests send organization request.
        Last Modified Date  :   4 Sept 2018
		Issue No			: 	ST-2729
    **************************************************************************************************************************************/
    public static testMethod void verifySendOrgRequest(){
        try{
            Test.startTest();
            Contact contactRec = new Contact(FirstName = 'John', LastName = 'Bonapart', Email = 'testBonapart@example.com', Status__c = 'active');
            Account accRec = new Account(Name = 'TestOrg', Number_of_Full_Time_Employees__c = 1000, Website = 'www.testorg.com', Interested_in_Number_of_Desks__c = 100, Phone = '9845623645');
            System.assertEquals(false, RequestNewOrganizationController.sendNewOrganizationRequest(new Account()).data, 'when account is null');
            System.assertEquals(true, NewOrganizationController.sendNewOrganizationRequest(new List<sObject>{accRec, contactRec}).data);
            System.assertEquals(1,Limits.getEmailInvocations(), 'email count');
            Test.stopTest();
            System.assertEquals(null, NewOrganizationController.sendNewOrganizationRequest(new List<sObject>{contactRec}).data);
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    }
}