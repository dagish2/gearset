/************************************************************************************************************************************
    Author 		: 
    Description : ---

    History		:
----------------------------------------------------------------------------------------------------------------------------------
    VERSION	  DATE	        AUTHOR           DETAIL
    1	             
**************************************************************************************************************************************/

@isTest
public class JourneyTriggerHandlerTest {
    static Boolean settingsInitialized = false;
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        WeWorkValidatorHelper.createTerritoryStructure();
        set<String> setEmails = new set<String>() ;
        List<Lead> lstLeadsToInsert = new List<Lead>();
        List<Journey__C> lstJourneys = new List<Journey__C>();
        List<Account>  lstAccount = new List<Account>();
        List<Contact>  lstContact = new List<Contact>();
        
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_1@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany1', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true));
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_2@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany2', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true));
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_3@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany3', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true));
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_4@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany4', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true));
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_5@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany5', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true)); //NYC-5th Ave;LON-Aldgate Tower; NYC-42 Street
        TestingUtility.insertListWithAssert(lstLeadsToInsert);
       
        lstAccount.add(new Account(Name='account1', Unomy_Company_ID__c = 11111, Lead_Source__c='LeadSource1'));
        lstAccount.add( new Account(Name='account2', Unomy_Company_ID__c = 22222, Lead_Source__c='LeadSource2'));
        lstAccount.add( new Account(Name='account3', Unomy_Company_ID__c = 33333, Lead_Source__c='LeadSource3'));
        lstAccount.add( new Account(Name='account4', Unomy_Company_ID__c = 44444, Lead_Source__c='LeadSource4'));
        lstAccount.add( new Account(Name='account5', Unomy_Company_ID__c = 55555, Lead_Source__c='LeadSource5'));
        TestingUtility.insertListWithAssert(lstAccount);
        
        lstcontact.add(new Contact(FirstName='Contact1',LastName='Member',Email='test.Contact1@example.com',AccountId=lstAccount[0].Id));
        lstcontact.add(new Contact(FirstName='Contact2',LastName='Member',Email='test.Contact2@example.com',AccountId=lstAccount[1].Id));
        lstcontact.add(new Contact(FirstName='Contact3',LastName='Member',Email='test.Contact3@example.com',AccountId=lstAccount[2].Id));
        lstcontact.add(new Contact(FirstName='Contact4',LastName='Member',Email='test.Contact4@example.com',AccountId=lstAccount[3].Id));
        lstcontact.add(new Contact(FirstName='Contact5',LastName='Member',Email='test.Contact5@example.com',AccountId=lstAccount[4].Id));
        TestingUtility.insertListWithAssert(lstcontact);
       
    }
    
/************************************************************************************************************************************
    Author 				: Sunil Bhosale
    Issue No 			: ST-928
    Description 		: This method verifies that 
						  
	 Created Date 		: 11 June 2018
**************************************************************************************************************************************/
    public static testMethod void verifyupdateHasActiveJourneyField(){
        Test.startTest();
        set<Id> setLeadIds = new set<Id>();
        List<Journey__c> lstJourneys =  [SELECt Id, Primary_Lead__c, Status__c FROM Journey__c];
        for(Journey__c journey : lstJourneys){
            System.assert(journey.Status__c == 'Accepted');
            setLeadIds.add(journey.Primary_Lead__c);            
        }
        for(Lead lead : [SELECT Id, Has_Active_Journey__c FROM Lead WHERE Id IN : setLeadIds]){
            System.assert(lead.Has_Active_Journey__c != null);
            System.assert(lead.Has_Active_Journey__c == true);
        }
        
        lstJourneys = new List<Journey__c>();
        for(Contact contact  : [SELECT Id, LastName, Email FROM Contact]){
            Journey__c journey = new Journey__c();
            journey.Name = contact.LastName;
            journey.Primary_Lead__c = null;
            journey.Primary_Contact__c = contact.Id;
            journey.Status__c = 'Started';
            journey.Primary_Email__c = contact.Email;
            journey.NMD_Next_Contact_Date__c = Date.today();
            lstJourneys.add(journey);
        } 
        TestingUtility.insertListWithAssert(lstJourneys);
        
        for(Contact contact  : [SELECT Id, Has_Active_Journey__c FROM Contact]){
            System.assert(contact.Has_Active_Journey__c!= null);
            System.assert(contact.Has_Active_Journey__c== true);
        }
       test.stopTest();
        
    } 
    
    
    
    
/************************************************************************************************************************************
    Author 				: Sunil Bhosale
    Issue No 			: 
    Description 		: if journey's stage become 'Manual Outreach' OR 'NMD Drip' then the associated Lead (Status) OR Contact 
						  ('Outreach_Stage__c') become same as jourey. 
	 Created Date 		: 07 June 2018
**************************************************************************************************************************************/

    public static testMEthod void verifySetPrimaryLeadStatusWhenJourneyStatusChange(){
        List<Journey__c> lstJourneyToUpdate = new List<Journey__c>();
        set<Id> setLeadIds = new set<Id>();
        List<Journey__C> journeys = [SELECT Id, Outreach_Stage__c, Primary_Lead__c, Primary_Contact__c FROM Journey__c];
        for(Journey__c journey : journeys){
            journey.Outreach_Stage__c = 'Manual Outreach';
            lstJourneyToUpdate.add(journey);
            setLeadIds.add(journey.Primary_Lead__c);
        }
        update lstJourneyToUpdate;
        
        System.assert(setLeadIds.size() > 0);        
        for(Lead objLead : [SELECT Id, Status from Lead where Id IN : setLeadIds]){           
            System.assert(objLead.Status != null);          
            System.assertEquals('In Process', objLead.Status, 'correct outreach stage is not populated on lead');
        }
        Test.startTest(); 
        List<Contact> lstCon = [SELECT Id FROM Contact];
        set<Id> setContactId = new set<Id>();
        lstJourneyToUpdate = new List<Journey__c>(); 
        Integer counter = 0;
        for(Journey__c journey : journeys){
            journey.Primary_Contact__c = lstCon[counter].Id;  
            journey.Primary_Lead__c = null;
            journey.Outreach_Stage__c = 'NMD Drip';
            lstJourneyToUpdate.add(journey);
            setContactId.add(lstCon[counter].Id);
            counter++;
        }
        update lstJourneyToUpdate;
        for(Contact objContact : [SELECT Id, Outreach_Stage__c FROM Contact WHERE Id IN : setContactId]){        
            System.assert(objContact.Outreach_Stage__c != null);
            System.assertEquals('NMD Drip', objContact.Outreach_Stage__c, 'Outreach_Stage__c on contact is incorrect');
        }
        Test.stopTest();        
    }
    
/************************************************************************************************************************************
    Author 				: Sunil Bhosale
    Issue No 			: ST-533
    Description 		:  This method test that the active referrer is mapped on journey for Contacts
    Created Date 		: 07 June 2018
**************************************************************************************************************************************/
  
    public static testMethod void verifyupdateActiveReferrerOnJourneyForCotacts(){
         List<Account> lstAccount = new List<Account>();
        List<Contact> lstcontact = new List<Contact>();
        List<Referral__c> lstReferral = new List<Referral__c>();
        List<Lead> lstLead = new List<Lead>();
        set<Id> setContacts =new set<Id>();
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
            
        }
        lstcontact.clear();
        lstcontact.add(new Contact(FirstName='Contact7',LastName='Member',Email='referral_6@example.com',AccountId=lstAccount[0].Id));
        lstcontact.add(new Contact(FirstName='Contact8',LastName='Member',Email='referral_7@example.com',AccountId=lstAccount[1].Id));
        lstcontact.add(new Contact(FirstName='Contact9',LastName='Member',Email='referral_8@example.com',AccountId=lstAccount[2].Id));
        lstcontact.add(new Contact(FirstName='Contact10',LastName='Member',Email='referral_9@example.com',AccountId=lstAccount[3].Id));
        lstcontact.add(new Contact(FirstName='Contact11',LastName='Member',Email='referral_10@example.com',AccountId=lstAccount[4].Id));
        insert lstcontact;
        for(Contact contact : lstcontact){
            System.assert(contact.Id != null, 'contacts for referral not inserted');
            setContacts.add(contact.Id);
        }
        List <Journey__c>  lstJourneyToInsert = new List<Journey__c>();
        for(Contact contact : lstcontact){
            Journey__c journey = new Journey__c();
            journey.Name = contact.LastName;
            journey.Primary_Contact__c = contact.Id;
            journey.Status__c = 'Started';
            journey.Primary_Email__c = contact.Email;
           	journey.NMD_Next_Contact_Date__c = Date.today();
            lstJourneyToInsert.add(journey);
        } 
        insert lstJourneyToInsert;
        for(Journey__c journey : [select id, Referrer__c from Journey__c where   Primary_Contact__c IN :  setContacts ]){
            System.assert(journey.Id!= null, 'journey for Referral not inseertd');
            System.assert(journey.Referrer__c != null , 'referal is not mapped on journey ');
        }
    }
/************************************************************************************************************************************
    Author 				: Sunil Bhosale
    Issue No 			: ST-533
    Description 		:  This method test that the active referrer is mapped on journey for Leads
    Created Date 		: 07 June 2018
**************************************************************************************************************************************/

    public static testMethod void verifyupdateActiveReferrerOnJourneyForLeads(){
        List<Account> lstAccount = new List<Account>();
        List<Contact> lstcontact = new List<Contact>();
        List<Referral__c> lstReferral = new List<Referral__c>();
        List<Lead> lstLead = new List<Lead>();
        set<Id> setLeadIs =new set<Id>();
        lstAccount.add(new Account(Name='account7', Unomy_Company_ID__c = 77777, Lead_Source__c='LeadSource1'));
        lstAccount.add( new Account(Name='account8', Unomy_Company_ID__c = 8888, Lead_Source__c='LeadSource2'));
        lstAccount.add( new Account(Name='account9', Unomy_Company_ID__c = 99999, Lead_Source__c='LeadSource3'));
        lstAccount.add( new Account(Name='account10', Unomy_Company_ID__c = 00000, Lead_Source__c='LeadSource4'));
        lstAccount.add( new Account(Name='account11', Unomy_Company_ID__c = 12121, Lead_Source__c='LeadSource5'));
        test.startTest();
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
            for(Contact contact : lstcontact)   {
                System.assert(contact.Id!= null, 'contacts not inseertd');
            } 
        lstReferral.add(new Referral__c(Referral_Email__c = 'johnDoe6618_6@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[0].Id));
        lstReferral.add(new Referral__c(Referral_Email__c = 'johnDoe6618_7@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[1].Id));
        lstReferral.add(new Referral__c(Referral_Email__c = 'johnDoe6618_8@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[2].Id));
        lstReferral.add(new Referral__c(Referral_Email__c = 'johnDoe6618_9@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[3].Id));
        lstReferral.add(new Referral__c(Referral_Email__c = 'johnDoe6618_10@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[4].Id));
        insert lstReferral;
        for(Referral__c Referral : lstReferral){
             System.assert(Referral.Id!= null, 'Referral not inseertd');
        }
        
        lstLead.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_6@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany1', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true));
        lstLead.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_7@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany2', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true));
        lstLead.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_8@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany3', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true));
        lstLead.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_9@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany4', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true));
        lstLead.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_10@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany5', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true)); //NYC-5th Ave;LON-Aldgate Tower; NYC-42 Street
        insert lstLead;
         for(Lead lead : lstLead){
             System.assert(lead.Id!= null, 'lead for Referral not inseertd');
             setLeadIs.add(lead.Id);
        }
        System.assert(setLeadIs.size() > 0 &&  setLeadIs!= null  ,'lead set is  is empty');
        List<Journey__C> lstJourneyToInsert = new List<Journey__C>();
        for(Lead lead : lstLead){
            Journey__c journey = new Journey__c();
            journey.Name = lead.LastName;
            journey.Primary_Lead__c = lead.Id;
            journey.Status__c = 'Started';
            journey.Primary_Email__c = lead.Email;
           	journey.NMD_Next_Contact_Date__c = Date.today();
            lstJourneyToInsert.add(journey);
        } 
        insert lstJourneyToInsert;
        test.stopTest();
        for(Journey__c journey : [select id, Referrer__c,Primary_Email__c from Journey__c where Primary_Lead__c IN :  setLeadIs ]){
            System.assert(journey.Id!= null, 'journey for Referral not inseertd');
         //   System.assert(journey.Referrer__c != null , 'referal is not mapped on journey ');
        }
        
     
        
    }
   
    /************************************************************************************************************************************
    Author 				:
    Issue No 			:
    Description 		: This method is used to initialize data.
    Created Date 		:
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
    
    static void initFieldMappings() {
        if( settingsInitialized )
            return;
        
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'Lead:Lead and Lead Source Details';
        testSettings.Data__c = '{"LeadSource":[{"name":"Broker","OverrideLeadSoruce":false},{"name":"Test Broker","OverrideLeadSoruce":true}], "LeadSourceDetails":["Broker1","Broker2" ]}';
        TestingUtility.insertWithAssert(testSettings);
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 1');
        userRecordMap.put('Username','testweworkuser1@example.com');
        userRecordMap.put('Email','testweworkuser1@example.com');
        User testUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true); 
        
        userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 2');
        userRecordMap.put('Username','testweworkuser2@example.com');
        userRecordMap.put('Email','testweworkuser2@example.com');
        User testUser1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true); 
        
        //Create a queue
        Group testGroup = new Group ();
        testGroup.Name = 'Test Lead Queue';
        testGroup.Type = 'Queue';
        insert testGroup;
        
        Group testGroup1 = new Group ();
        testGroup1.Name = 'Test Lead Queue1';
        testGroup1.Type = 'Queue';
        insert testGroup1;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueueSObject testQueue = new QueueSObject();
            testQueue.QueueId = testGroup.Id;
            testQueue.SObjectType = 'Lead';
            insert testQueue;
            
            testQueue = new QueueSObject();
            testQueue.QueueId = testGroup.Id;
            testQueue.SObjectType = 'Journey__c';
            insert testQueue;
            
            testQueue = new QueueSObject();
            testQueue.QueueId = testGroup1.Id;
            testQueue.SObjectType = 'Lead';
            insert testQueue;
            
            testQueue = new QueueSObject();
            testQueue.QueueId = testGroup1.Id;
            testQueue.SObjectType = 'Journey__c';
            insert testQueue;
            
            GroupMember member = new GroupMember();
            member.UserOrGroupId = testUser.Id;
            member.GroupId = testGroup.Id; 
            insert member;
            
            member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = testGroup.Id; 
            insert member;
        }
        
        testSettings = new Setting__c();
        testSettings.Name = 'User/Queue Journey Creation';
        testSettings.Data__c = '{"allowedUsers":[{"userName":"'+ testUser.Username +'","Id":"'+testUser.Id +'"},{"userName":"'+ testUser1.Username +'","Id":"'+testUser1.Id +'"}],"allowedQueues":[{"Id":"'+ testGroup.Id +'","queueName":"'+ testGroup.Name +'"}]}';
        TestingUtility.insertWithAssert(testSettings);
        
        settingsInitialized = true;
    }
    
    public static Lead prepareLead(String lastName, String company, String email, String phone) {
        return prepareLeads(lastName, company, email, phone, 1)[0];
    }
    /************************************************************************************************************************************
    Author 				:
    Issue No 			:
    Description 		: This method is used to prepare leads for test data.
    Created Date 		:
    Last Modified Date	: 02 Feb, 2018
    Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
    
    public static List<Lead> prepareLeads(String lastName, String company, String email, String phone, integer count){
        List<Lead> listLeads = new List<Lead>();
        if( count == 1 ){
            Lead leadNew = new Lead(LastName = lastName, Company = company, Email = email, Phone = phone, Generate_Journey__c = false);
            listLeads.add(leadNew);
        }
        else if( count > 1 ) {
            String emailName = null, emailDomain = null;
            if( !String.IsBlank(email) ){
                integer iFound = email.indexOf('@');
                if( iFound >= 0 ){
                    emailName = email.left(iFound);
                    emailDomain = email.Mid(iFound, email.length());
                }
            }
            
            for(integer iIndex = 0; iIndex < count; ++iIndex) {
                Lead leadNew = new Lead(LastName = lastName + '-' + iIndex, Company = company, Generate_Journey__c = false);
                leadNew.Email = (emailName == null) ? null : emailName + '-' + iIndex + emailDomain;
                leadNew.Phone = (String.IsBlank(phone)) ? null : phone + iIndex;
                listLeads.add(leadNew);
            }
        }
        
        return listLeads;
    }
    /************************************************************************************************************************************
    Author 				:
    Issue No 			:
    Description 		: This method is used to set primary lead to unqualified.
    Created Date 		:
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Sunil Bhosale
**************************************************************************************************************************************/
    
    private static testMethod void verifySetPrimaryLeadToUnqualified() {
        List<Journey__C> lstJourneys = [select id,Status__c from journey__C];
        set<Id> setLeadIds = new set<Id>();
        for(Journey__C journey : lstJourneys){
            journey.Status__c = 'Unqualified';
            journey.Lost_Reason__c = 'Budget';                                  
            setLeadIds.add(journey.Primary_Lead__c);                                  
            }
        update lstJourneys;
        test.startTest();
        for(Lead lead : [select id,Status,Unqualified_Reason__c from Lead where Id IN : setLeadIds]){
            System.assert(lead.Status != null);
            System.assert(lead.Unqualified_Reason__c != null);
            System.assert(lead.Status == 'Unqualified');
            System.assert(lead.Unqualified_Reason__c == 'Budget');
            
        }
        test.stopTest();
        
    }
   
    /************************************************************************************************************************************
    Author 				:
    Issue No 			:
    Description 		: This method is used to test weekend Cadence.
    Created Date 		:
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
    
    private static testMethod void testweekendCadence(){
        test.startTest();
        Lead testLead = new Lead(FirstName = 'Test',
                                 LastName = 'Lead',
                                 Company = 'TestCompany',
                                 Status = 'Open',
                                 Locations_Interested__c = 'B1; B2;',
                                 Office_Type__c = 'Shared Desk; DailyDesk;',
                                 Email = 'test2005@example.com'
                                );
        insert testLead;
        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'test2000Journey5';
        testJourney.CurrencyIsoCode = 'USD';
        testJourney.Primary_Lead__c = testLead.Id;
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        testJourney.Lost_Reason__c = 'Not Interested';
        //testJourney.CreatedDate = myDateTime;
        insert testJourney;
        
        testJourney  = [Select Id,NMD_Next_Contact_Date__c,CreatedDate FROM Journey__c WHERE Id =: testJourney.Id];
        //Date expected = Date.newInstance(2016, 11, 28);
        //System.assertEquals(expected, testJourney.NMD_Next_Contact_Date__c);
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 1');
        userRecordMap.put('Username','testweworkuser1@example.com');
        userRecordMap.put('Email','testweworkuser1@example.com');
        User testUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true); 
        
        userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 2');
        userRecordMap.put('Username','testweworkuser2@example.com');
        userRecordMap.put('Email','testweworkuser2@example.com');
        User testUser1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true); 
        
        //Create a queue
        Group testGroup = new Group ();
        testGroup.Name = 'Test Lead Queue';
        testGroup.Type = 'Queue';
        insert testGroup;
        test.stopTest();
        Group testGroup1 = new Group ();
        testGroup1.Name = 'Test Lead Queue1';
        testGroup1.Type = 'Queue';
        insert testGroup1;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueueSObject testQueue = new QueueSObject();
            testQueue.QueueId = testGroup.Id;
            testQueue.SObjectType = 'Lead';
            insert testQueue;
            
            testQueue = new QueueSObject();
            testQueue.QueueId = testGroup.Id;
            testQueue.SObjectType = 'Journey__c';
            insert testQueue;
            
            testQueue = new QueueSObject();
            testQueue.QueueId = testGroup1.Id;
            testQueue.SObjectType = 'Lead';
            insert testQueue;
            
            testQueue = new QueueSObject();
            testQueue.QueueId = testGroup1.Id;
            testQueue.SObjectType = 'Journey__c';
            insert testQueue;
            
            GroupMember member = new GroupMember();
            member.UserOrGroupId = testUser.Id;//UserInfo.getUserId();
            member.GroupId = testGroup.Id; 
            insert member;
            
            member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = testGroup.Id; 
            insert member;
        }
        
        Lead testLead1 = new Lead(FirstName = 'Test',
                                  LastName = 'Lead',
                                  Company = 'TestCompany',
                                  Status = 'Open',
                                  Locations_Interested__c = 'B1; B2;',
                                  Office_Type__c = 'Shared Desk; DailyDesk;',
                                  Email = 'test1200689@example.com',
                                  OwnerId = testGroup.Id
                                 );
        insert testLead1;
        
        Journey__c testJourney1 = new Journey__c();
        testJourney1.Name = 'test2000Journey5';
        testJourney1.CurrencyIsoCode = 'USD';
        testJourney1.Primary_Lead__c = testLead1.Id;
        testJourney1.NMD_Next_Contact_Date__c = Date.today();
        testJourney1.Lost_Reason__c = 'Not Interested';
        testJourney1.OwnerId = testGroup1.Id;
        insert testJourney1;
        
    }
    
  
    
    /************************************************************************************************************************************
    Author 				: Milanjeet Singh
    Issue No 			:
    Description 		: If Journey owner is Api User and Associted Lead owner is also Api User.
    					  If New Lead with the same Email comes in the System with Different owner we update Owner SFID field on related journey"
                          on updation of Owner SFID, the trigger will fire and it should update the journey and lead owner from Owner SFID field 
    Created Date 		:
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
    //This Method is commented because method updateJourneysOwner() of JourneyTriggerHandler is not using from here.
    //Now this functionality is implimented  from  Lead Converter.
    /*
    static testMethod void verifyUpdateJourneysOwner_Scanerio1(){
        User apiUserJourneyUpdate = [Select Id,isActive,Name from User where username='testapiuser89833@example.com'];
        Debug.Log('S1-apiUserJourneyUpdate-------'+apiUserJourneyUpdate);        
        Lead testLead = new Lead(OwnerId=apiUserJourneyUpdate.Id,LastName = 'Test Lead Last Name', Company = 'Test Company', Email = 'test_Journey_ownwer@example.com', Phone = '6565656592', Generate_Journey__c = true);
        TestingUtility.insertWithAssert(testLead);
        Debug.Log('OwnerInfo :: ' +[Select Owner.Name from Lead where Id=:testLead.Id]);
        Debug.Log('Journeys Size ::' + [Select Id, Name from Journey__c where Primary_Lead__c =:testLead.Id].size());
        
        Journey__c testJourney = new Journey__c();
        testJourney.OwnerId = apiUserJourneyUpdate.Id;
        testJourney.Name = 'testJourney2';
        testJourney.CurrencyIsoCode = 'USD';
        testJourney.Primary_Lead__c = testLead.Id;
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        testJourney.Status__c = 'Started';
        //testJourney.Owner_SFID__c = '';
        TestingUtility.insertWithAssert(testJourney);
         Debug.Log('Journeys Size ::' + [Select Id, Name from Journey__c where Primary_Lead__c =:testLead.Id].size());
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Map<String,Object> userRecordMap1 = new Map<String,Object>();
        userRecordMap1.put('LastName','Last Name 1');
        userRecordMap1.put('Username','testweworkowneruser1@example.com');
        userRecordMap1.put('Email','testweworkowneruser1@example.com');
        User sfOwner = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap1, true);
        
        testJourney.Owner_SFID__c = sfOwner.Id;
        update testJourney;
        
        testJourney = [Select Id,OwnerId,Owner_SFID__c,Primary_Lead__c from Journey__c where Id=:testJourney.Id];
        testLead = [Select Id,OwnerId from Lead where Id=:testLead.Id];
        
        System.assertEquals(sfOwner.Id,testJourney.Owner_SFID__c, 'Owner SFID not updated on journey');
        System.assertEquals(sfOwner.Id,testJourney.OwnerId, 'Owner not updated on journey');
        System.assertEquals(sfOwner.Id,testLead.OwnerId, 'Owner not updated on related lead');
        
        
    }
    */
    /************************************************************************************************************************************
    Author 				: Milanjeet Singh
    Issue No 			:
    Description 		: If Journey owner is Api User and Associted Contact owner is also Api User.
                    	  If New Lead with the same Email comes in the System with Different owner we update Owner SFID field on related journey"
                    	  on updation of Owner SFID, the trigger will fire and it should update the journey and Contact owner from Owner SFID field 
    Created Date 		:
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
    
    static testMethod void verifyUpdateJourneysOwner_Scanerio2(){
        User apiUserJourneyUpdate = [Select Id,isActive,Name from User where username='testapiuser89833@example.com'];
        Debug.Log('S2-apiUserJourneyUpdate-------'+apiUserJourneyUpdate);
        Contact testContact = new Contact();
        testContact.OwnerId= apiUserJourneyUpdate.Id;
        testContact.LastName = 'TestContact Name';
        testContact.Email = 'testownercontact1@example.com';
        testContact.Outreach_Stage__c ='Manual Outreach';
        testContact.Has_Active_Journey__c = false;
        TestingUtility.insertWithAssert(testContact);
        
        Journey__c testJourney2 = new Journey__c();
        testJourney2.OwnerId = apiUserJourneyUpdate.Id;
        testJourney2.Name = 'testJourney2';
        testJourney2.CurrencyIsoCode = 'USD';
        testJourney2.Primary_Contact__c = testContact.Id;
        testJourney2.NMD_Next_Contact_Date__c = Date.today();
        testJourney2.Status__c = 'Started';
        //testJourney.Owner_SFID__c = '005F0000003KmbwIAC';
        TestingUtility.insertWithAssert(testJourney2);
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Map<String,Object> userRecordMap1 = new Map<String,Object>();
        userRecordMap1.put('LastName','Last Name 2');
        userRecordMap1.put('Username','testweworkowneruser2@example123.com');
        userRecordMap1.put('Email','testweworkowneruser2@example123.com');
        User sfOwner = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap1, true);
        
        testJourney2.Owner_SFID__c = sfOwner.Id;
        update testJourney2;
        apiUserJourneyUpdate = [Select Id,isActive,Name from User where username='testapiuser89833@example.com'];
        Debug.Log('S2.2-apiUserJourneyUpdate-------'+apiUserJourneyUpdate);    
        testJourney2 = [Select Id,OwnerId,Owner_SFID__c,Primary_Lead__c from Journey__c where Id=:testJourney2.Id];
        testContact= [Select Id,OwnerId from Contact where Id=:testContact.Id];
        Debug.Log('mapUserById2>>'+apiUserJourneyUpdate.Id);
        System.assertEquals(sfOwner.Id,testJourney2.Owner_SFID__c, 'Owner SFID not updated on journey');
        //System.assertEquals(sfOwner.Id,testJourney2.OwnerId, 'Owner not updated on journey');
        //System.assertEquals(sfOwner.Id,testContact.OwnerId, 'Owner not updated on related Contact');
    }
        /************************************************************************************************************************************
    Author 				:
    Issue No 			:
    Description 		: This method is used to journey creation for lead Assigned to Queue.
    Created Date 		:
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
    
   /* static testMethod void testJourneyCreationForLeadAssignedToQueue(){
        initFieldMappings();
        Lead lead;
        Contact contact;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        //Check if lead owner is queue if yes and Lead source and lead source details condition satisfy create journey and activity.
        Group testGroup = [Select Id,Name from Group where Name = 'Test Lead Queue' and Type = 'Queue'];
        Debug.log('testGroup:'+testGroup.Id);
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        lead.OwnerId = testGroup.Id;
        insert lead;
        
        journeys = [Select Id, Primary_Contact__c From Journey__c];
        System.assertEquals(1,journeys.size());
        tasks = [Select Id from Task];
        System.assertEquals(1,tasks.size()); 
        Test.setCreatedDate(journeys[0].Id,system.today().addDays(-2));
        
        User u = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, u);
        
        //Lead owner is user and existing lead owner is a queue then system will not create a new journey
        //Because journey is already exist and it's created date is greater than date mentioned in JSON
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        lead.ownerId = u.Id;
        insert lead;
        
        journeys = [Select Id, Primary_Contact__c From Journey__c];
        System.assertEquals(1,journeys.size());
        tasks = [Select Id from Task];
        System.assertEquals(2,tasks.size());
        
        Test.setCreatedDate(journeys[0].Id,system.today().addDays(-5));
        
        Test.startTest();
        //Lead owner is user and existing lead owner is a queue then system will  create a new journey
        //Because journey is already exist but it's created date is less than date mentioned in JSON
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        lead.ownerId = u.Id;
        insert lead;
        
        //Two journey is created with same ownerId
        journeys = [Select Id, Primary_Contact__c From Journey__c where ownerId =:testGroup.Id];
        System.assertEquals(2,journeys.size());
        tasks = [Select Id from Task];
        System.assertEquals(3,tasks.size());
        
        //Lead owner is user and existing lead owner is a queue then system will  not create a new journey
        //Because journey is already exist and it's createdDate date is greater than date mentioned in JSON
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        lead.ownerId = u.Id;
        insert lead;
        journeys = [Select Id, Primary_Contact__c,createdDate From Journey__c where ownerId =:testGroup.Id];
        Debug.log('journey is already exist ==>>' + journeys);
        System.assertEquals(2,journeys.size());
        tasks = [Select Id from Task];
        System.assertEquals(4,tasks.size());
        journeys = [Select Id, Primary_Contact__c From Journey__c where createdDate >=: Date.today()];
        //System.assertEquals(1,journeys.size());
        Test.stopTest();
    }*/
    
    
    
    /************************************************************************************************************************************
    Author 				:
    Issue No 			:
    Description 		: This method is used to update existing Joureny.
    Created Date 		:
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
    /*static testMethod void testUpdateExistingJoureny(){
        initFieldMappings();
        Group testGroup = [Select Id,Name from Group where Name = 'Test Lead Queue' and Type = 'Queue'];
        Debug.log('testGroup:'+testGroup.Id);
        Lead testLead = new Lead(FirstName = 'Test',
                                 LastName = 'Lead',
                                 Company = 'TestCompany',
                                 Status = 'Open',
                                 Locations_Interested__c = 'B1; B2;',
                                 Office_Type__c = 'Shared Desk; DailyDesk;',
                                 Email = 'test12012@example.com',
                                 LeadSource = 'Broker',
                                 Lead_Source_Detail__c = 'Broker1',
                                 Generate_Journey__c = true,
                                 OwnerId = testGroup.Id          
                                );
        insert testLead;
        
        List<Journey__c> journeys = [select Id,Name,NMD_Next_Contact_Date__c,ownerId from Journey__c];
        system.assertEquals(1,journeys.size());
    }
    */
  
}