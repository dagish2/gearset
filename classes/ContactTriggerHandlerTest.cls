/************************************************************************************************************************************
	Author : Dipak Pawar  
	Description : This class contain all test methods related to ContactTriggerHandler class.

History:
----------------------------------------------------------------------------------------------------------------------------------
	VERSION					DATE					AUTHOR							DETAIL
	1						04 July 2016		   	Dipak Pawar	             		Initial Developement
**************************************************************************************************************************************/

@isTest
public class ContactTriggerHandlerTest{
    
	/************************************************************************************************************************************
		Author 				: Dipak Pawar  
		Description 		: This setup method is used to get all salesconsole settings for this class.
		Last Modified Date	: 04 July 2016
		Last Modified By	: Dipak Pawar	
	**************************************************************************************************************************************/
    @TestSetup
    public static void setup(){
        SalesConsoleSettings.createSettings();
        List<Account>  lstAccount = new List<Account>();
        List<Contact>  lstContact = new List<Contact>();
        lstAccount.add(new Account(Name='account1', Unomy_Company_ID__c = 11111, Lead_Source__c='LeadSource1'));
        lstAccount.add( new Account(Name='account2', Unomy_Company_ID__c = 22222, Lead_Source__c='LeadSource2'));
        lstAccount.add( new Account(Name='account3', Unomy_Company_ID__c = 33333, Lead_Source__c='LeadSource3'));
        lstAccount.add( new Account(Name='account4', Unomy_Company_ID__c = 44444, Lead_Source__c='LeadSource4'));
        lstAccount.add( new Account(Name='account5', Unomy_Company_ID__c = 55555, Lead_Source__c='LeadSource5'));
        insert lstAccount;
        for(Account account : lstAccount){
            System.assert(account.Id!= null, 'Accounts not inseertd');
        }
        //create opportunities
        List<Opportunity> lstOpp = new List<Opportunity>(); 
        for(Account account : [select id from Account]){
            lstOpp.add(TestingUtility.createOpportunity(account.Id, false));
        }
        
        lstcontact.add(new Contact(FirstName='Contact1',LastName='Member',Email='test.Contact1@example.com',AccountId=lstAccount[0].Id));
        lstcontact.add(new Contact(FirstName='Contact2',LastName='Member',Email='test.Contact2@example.com',AccountId=lstAccount[1].Id));
        lstcontact.add(new Contact(FirstName='Contact3',LastName='Member',Email='test.Contact3@example.com',AccountId=lstAccount[2].Id));
        lstcontact.add(new Contact(FirstName='Contact4',LastName='Member',Email='test.Contact4@example.com',AccountId=lstAccount[3].Id));
        lstcontact.add(new Contact(FirstName='Contact5',LastName='Member',Email='test.Contact5@example.com',AccountId=lstAccount[4].Id));
        insert lstcontact;
        for(Opportunity opp : lstOpp){
            opp.Primary_Member__c = lstcontact[0].Id;
        }
        TestingUtility.insertListWithAssert(lstOpp);        
        for(Contact contact : lstcontact) {
            System.assert(contact.Id!= null, 'contacts not inseertd');
        } 
    }
     /************************************************************************************************************************************
		Author 				: Sunil Bhosale
		Description 		: This test method is used to verify that update Active reffrer on Contact
		created Date		: 20 June 2018
			
	**************************************************************************************************************************************/
    @isTest
    static void verifyRestartJourney(){
        List<Contact> lstContact = new List<Contact>();
        List<Journey__C> lastJourneys = new List<Journey__C>();
        
        test.startTest();
        for(Contact contact : [select id,Restart_Journey__c from Contact]){
        	contact.Restart_Journey__c = true;
            lstContact.add(contact);
        }        
        update lstContact;
        List<Journey__C> lstJourneys = [select id,NMD_Next_Contact_Date__c,Status__c,Primary_Contact__c  from journey__C];
        System.assert(lstJourneys.size() > 0);
        for(Journey__C journey : lstJourneys){
            //System.assert(journey.NMD_Next_Contact_Date__c == Date.today());
            System.assert(journey.Status__c == 'Started');
            System.assert(journey.Primary_Contact__c != null);
            journey.NMD_Next_Contact_Date__c = Date.newInstance(1960, 2, 17);
            lastJourneys.add(journey);
        }
        for(Contact contact : [select id,Restart_Journey__c from Contact]){
            System.assert(contact.Restart_Journey__c == false);
        }
        test.stopTest();
    }
    
    /************************************************************************************************************************************
		Author 				: Sunil Bhosale
		Description 		: This test method is used to verify that update Active reffrer on Contact
		created Date		: 20 June 2018
			
	**************************************************************************************************************************************/
    @isTest
    static void verifyupdateActiveReferrerOnContact(){
        
        List<Account> lstAccount = new List<Account>();
        List<Contact> lstcontact = new List<Contact>();
        List<Referral__c> lstReferral = new List<Referral__c>();
        List<Lead> lstLeadsToInsert = new List<Lead>();
        List<Lead> lstLead = new List<Lead>();
        set<String> setEmails =new set<String>();
        test.startTest();
        lstAccount.add(new Account(Name='account7', Unomy_Company_ID__c = 77777, Lead_Source__c='LeadSource1'));
        lstAccount.add( new Account(Name='account8', Unomy_Company_ID__c = 8888, Lead_Source__c='LeadSource2'));
        lstAccount.add( new Account(Name='account9', Unomy_Company_ID__c = 99999, Lead_Source__c='LeadSource3'));
        lstAccount.add( new Account(Name='account10', Unomy_Company_ID__c = 00000, Lead_Source__c='LeadSource4'));
        lstAccount.add( new Account(Name='account11', Unomy_Company_ID__c = 12121, Lead_Source__c='LeadSource5'));
        insert lstAccount;
        for(Account account : lstAccount){
            System.assert(account.Id!= null, 'Accounts not inseertd');
        }
        lstcontact.add(new Contact(FirstName='Contact7',LastName='Member',Email='test.RefContact1@example.com',AccountId=lstAccount[0].Id));
        lstcontact.add(new Contact(FirstName='Contact8',LastName='Member',Email='test.RefContact2@example.com',AccountId=lstAccount[1].Id));
        lstcontact.add(new Contact(FirstName='Contact9',LastName='Member',Email='test.RefContact3@example.com',AccountId=lstAccount[2].Id));
        lstcontact.add(new Contact(FirstName='Contact10',LastName='Member',Email='test.RefContact4@example.com',AccountId=lstAccount[3].Id));
        lstcontact.add(new Contact(FirstName='Contact11',LastName='Member',Email='test.RefContact5@example.com',AccountId=lstAccount[4].Id));
        
        insert lstcontact;
        
        //lstcontact.clear();
        for(Contact contact : lstcontact)   {
            System.assert(contact.Id!= null, 'contacts not inseertd');
        } 
        lstReferral.add(new Referral__c(Referral_Email__c = 'referral_6@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[0].Id));
        lstReferral.add(new Referral__c(Referral_Email__c = 'referral_7@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[1].Id));
        lstReferral.add(new Referral__c(Referral_Email__c = 'referral_8@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[2].Id));
        lstReferral.add(new Referral__c(Referral_Email__c = 'referral_9@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[3].Id));
        lstReferral.add(new Referral__c(Referral_Email__c = 'referral_10@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[4].Id));
       
        insert lstReferral;
        
        for(Referral__c Referral : lstReferral){
            System.assert(Referral.Id!= null, 'Referral not inseertd');
            setEmails.add(Referral.Referral_Email__c);
       }
        lstcontact.clear();
        lstcontact.add(new Contact(FirstName='Contact7',LastName='Member',Email='referral_6@example.com',AccountId=lstAccount[0].Id));
        lstcontact.add(new Contact(FirstName='Contact8',LastName='Member',Email='referral_7@example.com',AccountId=lstAccount[1].Id));
        lstcontact.add(new Contact(FirstName='Contact9',LastName='Member',Email='referral_8@example.com',AccountId=lstAccount[2].Id));
        lstcontact.add(new Contact(FirstName='Contact10',LastName='Member',Email='referral_9@example.com',AccountId=lstAccount[3].Id));
        lstcontact.add(new Contact(FirstName='Contact11',LastName='Member',Email='referral_10@example.com',AccountId=lstAccount[4].Id));
       
        insert lstcontact;
        
        set<Id> setContactId = new set<Id>();
        for(Contact contact : lstcontact){
            System.assert(contact.Id!= null, 'contacts not inseertd');
            setContactId.add(contact.Id);
        } 
        for(Contact contact : [select id,Referrer__c from Contact where id IN : setContactId]){
            System.assert(contact.Referrer__c != null);
        }
        test.stopTest();
    }
    
    
    /************************************************************************************************************************************
		Author 				: Sunil Bhosale
		Description 		: This test method is used to verify update primary member on Account and opportunity if it is null.
		Last Modified Date	: 04 July 2016
		Last Modified By	: Dipak Pawar	
	**************************************************************************************************************************************/
 /*@isTest
    static void verifysetPrimaryContactOnAccount(){
      List<Opportunity> lstOpportunities = [select id,Primary_Member__c from Opportunity];
       System.assert(lstOpportunities.size() > 0);
        for(Opportunity opportunity : lstOpportunities) {
            System.assert(opportunity.Primary_Member__c!= null);
        }
        for(Account account : [select id,Primary_Member__c from Account]){
            System.assert(account.Primary_Member__c!= null);
        }
    }
    
    */
    /************************************************************************************************************************************
		Author 				: Sunil Bhosale
		Description 		: This test method is used to verify cleansed unomy company name on contact
		Last Modified Date	: 04 July 2016
		Last Modified By	: Dipak Pawar	
	**************************************************************************************************************************************/
     @isTest
    static void verifyupdateCleansedUnomyCompanyName(){
        test.startTest();
        List<Contact> lstContact  = new list<Contact>();
        for(Contact contact : [select id, Unomy_Company_Name__c from contact]){
            contact.Unomy_Company_Name__c = 'Enzigma.LTD';
            lstContact.add(contact);
        }
        
        update lstContact;
        
        for(Contact contact : [select id, Unomy_Company_Name__c,Cleansed_Unomy_Company_Name__c from contact]){
            System.assert(contact.Cleansed_Unomy_Company_Name__c != null);
            System.assertEquals('enzigmaltd', contact.Cleansed_Unomy_Company_Name__c);
        }
        test.stopTest();
    }
	/************************************************************************************************************************************
		Author 				: Dipak Pawar  
		Description 		: This test method is used to verify the duplication in contact by email.
		Last Modified Date	: 04 July 2016
		Last Modified By	: Dipak Pawar	
	**************************************************************************************************************************************/
    @isTest 
    static void testCheckForDuplicateEmail() {
        Test.startTest();
        Boolean result = false;
        Contact newContact1 = new Contact(
            firstname = 'TestFirstName',
            lastname = 'TestLastName',
            email = 'test@example.com',
            Status__c = 'active'
        );
        
        Contact newContact2 = new Contact(
            firstname = 'TestFirstName2',
            lastname = 'TestLastName1',
            email = 'test@example.com',
            Status__c = 'active'
        );
        
        Contact newContact3 = new Contact(
            firstname = 'TestFirstName3',
            lastname = 'TestLastName1',
            email = 'test123@example.com',
            Status__c = 'active'
        );
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(newContact1);
        lstContact.add(newContact2);
        lstContact.add(newContact3);
        
        try{
            Database.insert(lstContact);
        }
        catch(Exception ex){}        
        Test.stopTest();
    }
    
     /************************************************************************************************************************************
        Author 				: Dipak Pawar  
        Description 		: This test method is used to verify that if SF having existing lead and new contact will insert with same email,
                              and new contact Convert_Lead__c =true then existing lead will be conveted.
        Last Modified Date	: 20 June 2018
        Last Modified By	: Sunil Bhosale	
    **************************************************************************************************************************************/
      @isTest 
    static void verifyconvertMatchingLead(){
        Test.startTest();
        Account orgAccount = new Account(Name='Convert Lead Account 1',Account_Type__c='Org');
        TestingUtility.insertWithAssert(orgAccount);
        List<Lead> lstLeadsToInsert = new List<Lead>();
        lstLeadsToInsert.add(new Lead(FirstName='Convert Lead 1',LastName='Last Name 1',Company='Test 1',Email='convertlead1@example.com',LeadSource='other',Status='TestStatus',CurrencyIsoCode='USD'));
        lstLeadsToInsert.add(new Lead(FirstName='Convert Lead 2',LastName='Last Name 1',Company='Test 2',Email='convertlead2@example.com',LeadSource='other',Status='TestStatus',CurrencyIsoCode='USD'));
        TestingUtility.insertListWithAssert(lstLeadsToInsert);
        
        for(Lead convertedLead:[Select Id,isConverted from Lead Where Id IN:new Set<Id>{lstLeadsToInsert[0].Id,lstLeadsToInsert[1].Id}]){
            System.assertEquals(false,convertedLead.isConverted , 'Leads isConverted should be false by default');
        }
       
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(new Contact(AccountId=orgAccount.Id,firstname='Convert Lead 1 Contact 1',lastname='Last Name 1',Email='convertlead1@example.com',Status__c='active',Convert_Lead__c=true));
        lstContacts.add(new Contact(AccountId=orgAccount.Id,firstname='Convert Lead 2 Contact 2',lastname='Last Name 2',Email='convertlead2@example.com',Status__c='active',Convert_Lead__c=true));
        
        
        TestingUtility.insertListWithAssert(lstContacts);
        
        for(Lead convertedLead:[Select Id,isConverted from Lead Where Id IN:new Set<Id>{lstLeadsToInsert[0].Id,lstLeadsToInsert[1].Id}]){
            System.assertEquals(true,convertedLead.isConverted , 'Lead not Converted on contact insertion with same email');
        }
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author 				: Dipak Pawar
        Description 		: This test method is used to verify Account is update when its associated conatact gets deleted.
        Created Date		: 06 July 2016
        Last Modified Date	: 04 July 2016
        Last Modified By	: Krishana Tupe (Added Comment).
	**************************************************************************************************************************************/
    @isTest 
    static void testUpdateAccounts(){
        test.startTest();
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.firstname = 'TestFirstName';
        testContact.lastname = 'TestLastName';
        testContact.Email = 'TestEmail@example.com';
        testContact.Status__c = 'active';
        testContact.Convert_Lead__c = true;
        insert testContact;
        
        delete testContact;
        test.stopTest();
    }
    
   /************************************************************************************************************************************
        Author 				: Dipak Pawar
        Description 		: This test method is used to verify UUID is generate for Contact.
        Created Date		: 06 July 2016	
        Last Modified Date	: 01 February 2018
        Last Modified By	: Krishana Tupe (Added Comment).
    **************************************************************************************************************************************/  
    @isTest 
    static void testtGenerateUUID(){
        test.startTest();
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.firstname = 'TestFirstName';
        testContact.lastname = 'TestLastName';
        testContact.Email = 'TestEmail@example.com';
        testContact.Status__c = 'active';
        testContact.Convert_Lead__c = true;
        insert testContact;
        test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author 				: Samadhan Kadam 
        Description 		: This test method is used to verify UUID is generate for Contact.
        Created Date		: 01 August 2016	
        Last Modified Date	: 01 February 2018
        Last Modified By	: Krishana Tupe (Added Comment).
    **************************************************************************************************************************************/  
    @isTest
    static void testUpdateActiveReferrerOnContact(){
        test.startTest();
        Account accRec = new Account();
        accRec.Name='Test Account' ;
        insert accRec;
        
        Debug.log('Test : Contact Old ::: ' + [SELECT Id, LastName, Email FROM Contact WHERE Email='TestEmail123@example.com']);
        Contact testContact = new Contact();
        testContact.AccountId = accRec.Id;
        testContact.firstname = 'TestFirstName';
        testContact.lastname = 'TestLastName';
        testContact.Email = 'TestEmail123@example.com';
        testContact.Status__c = 'active';
        insert testContact;
        
        Referral__c testReferral = new Referral__c(Referral_Email__c = 'TesT444@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = testContact.Id);
        insert testReferral;
        
        Contact referrer1 = new Contact(
            AccountId =  accRec.Id,	
            firstname = 'TestFirstName',
            lastname = 'TestLastName',
            email = 'TesT444@example.com',
            Status__c = 'active',
            Referrer__c  = null	          
        );
        insert referrer1;
        Contact con = [SELECT Id,Referrer__c FROM Contact WHERE Id=:referrer1.Id];
        system.assertEquals( testContact.Id,con.Referrer__c );
        test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author 				: - 
        Description 		: This test method is used to verify UUID is generate for Contact.
        Created Date		: -	
        Last Modified Date	: 08 June 2017
        Last Modified By	: Shobhit Ghalot.
    **************************************************************************************************************************************/ 	
    @isTest 
    static void testRestrictOverrideLeadSource(){
        test.startTest();
        Account accRec = new Account();
        accRec.Name='Test Accounts' ;
        insert accRec;
        
        Contact testContact = new Contact();
        testContact.AccountId = accRec.Id;
        testContact.firstname = 'Test FirstName';
        testContact.lastname = 'Test LastName';
        testContact.Email = 'testemails@example.com';
        testContact.Status__c = 'active';
        testContact.LeadSource = 'WeWork.com';
        insert testContact;
        
        testContact.LeadSource ='event';
        update testContact;
        
        Lead lead = new Lead();
        lead.LastName = 'Smith';
        lead.Email = 'testemails@example.com';
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        insert lead;
        List<Contact> lstCont = [SELECT Id,Name,LeadSource FROM Contact Where Email =: lead.Email];
        system.assertEquals('WeWork.com' ,lstCont.get(0).LeadSource);
        test.stopTest();
    }    
      
    /************************************************************************************************************************************
        Author 				: Pranay Jadhav 
        Description 		: custom__crm__user___c not being populated in some cases
        Created Date		: 26 December 2016
        Last Modified Date	: -
        Last Modified By	: Sunil Bhosale
    **************************************************************************************************************************************/  
    @isTest 
    static void testUpdate_Custom_CRM_User() {
        test.startTest();
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];       
        //added by : sunil bhosale
        //to avoid Duplicate NickName
        User testUser = new User(Alias = 'testU', Email='testWeworkUser@enzigma.com', 
                                 EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = testProfile.Id, IsActive = true,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testWeworkUser@enzigma.com',CommunityNickname = TestingUtility.createUserCommunityName());
        insert testUser;        
        system.runAs(new User(Id=testUser.Id)){
            Account accountRec = new Account();
            accountRec.Name='Test Accounts' ;
            accountRec.Number_of_Full_Time_Employees__c = 55;
            insert accountRec;
            System.assertNotEquals(null, accountRec.Id);
            
            Map<String,Schema.RecordTypeInfo> mapobjContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName();
            Contact contactRec = new Contact();
            contactRec.AccountId = accountRec.Id;
            contactRec.firstname = 'Test FirstName';
            contactRec.lastname = 'Test LastName';
            contactRec.Email = 'testWeworkUser@enzigma.com';
            insert contactRec;           
            System.assertNotEquals(null, contactRec.Id);
            Contact cont = [SELECT Id, Email, Custom_CRM_User__c FROM Contact WHERE Id =:contactRec.Id];  
            System.assertNotEquals(null, cont);
            System.assertEquals(contactRec.Id, cont.Id);
            System.assertEquals(testUser.Id, cont.Custom_CRM_User__c);  
            test.stopTest();
        }
    }
    
    /************************************************************************************************************************************
        Author 				: Pragalbha Mahajan
        Description 		: This method is used to verify updation of Promo Code on Opportunity
        Created Date		: 22 October 2018
    **************************************************************************************************************************************/  
    public static testMethod void testUpdateOppPromoCode(){
        List<Account> lstAccounts = new List<Account>();
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        List<Contact> lstContacts = new List<Contact>();
        Map<String, Object> accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName1',
            'Account_Type__c' => 'Org',
            'RecordTypeId' =>  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId()};
        lstAccounts.addAll(TestingUtility.getAccountsByType(accountValuesMap, 'Org', 1));     
        TestingUtility.insertListWithAssert(lstAccounts);
        
        Map<String, Object> contactValuesMap = new Map<String, Object>{'FirstName' => 'strContact', 'AccountId' => lstAccounts[0].Id};
        Contact con1 = (Contact)TestingUtility.createContact(contactValuesMap, false);
		lstContacts.add(con1);
        TestingUtility.insertListWithAssert(lstContacts);
        
        Map<String, Object> opportunityValuesMap = new Map<String, Object>{'Name' => 'John1', 'StageName' => 'Selling', 'Amount' => 150, 'AccountId' => lstAccounts[0].Id, 'Promo_Code__c' => 'Buy1Get1', 'Primary_Member__c' => lstContacts[0].Id};
        Opportunity opp1 = (Opportunity)TestingUtility.createOpportunity(opportunityValuesMap, false);
        lstOpportunities.add(opp1);
        OpportunityValuesMap = new Map<String, Object>{'Name' => 'John2', 'StageName' => 'Closing', 'Amount' => 140, 'AccountId' => lstAccounts[0].Id, 'Promo_Code__c' => 'SaturdayBlast', 'Primary_Member__c' => lstContacts[0].Id, 'CloseDate' => system.today().addDays(3)};
        Opportunity opp2 = (Opportunity)TestingUtility.createOpportunity(opportunityValuesMap, false);
        lstOpportunities.add(opp2);
        opportunityValuesMap = new Map<String, Object>{'Name' => 'John3', 'StageName' => 'Closing', 'Amount' => 140, 'AccountId' => lstAccounts[0].Id, 'Primary_Member__c' => lstContacts[0].Id, 'CloseDate' => system.today().addDays(4)};
        Opportunity opp3 = (Opportunity)TestingUtility.createOpportunity(opportunityValuesMap, false);
        lstOpportunities.add(opp3);
        TestingUtility.insertListWithAssert(lstOpportunities);
        con1.Promo_Code__c = 'SundayFunday';
        Update con1;
        List<Opportunity> lstOpp = [SELECT Id,Name,Promo_Code__c FROM Opportunity WHERE Primary_Member__c =: con1.Id];
        System.assertNotEquals(con1.Promo_Code__c, lstOpp[0].Promo_Code__c);
        System.assertNotEquals(con1.Promo_Code__c, lstOpp[1].Promo_Code__c);
        System.assertEquals(con1.Promo_Code__c, lstOpp[2].Promo_Code__c);
    }
    
}