@isTest
public class LeadConverterHelperTests {
   
    @TestSetup 
    public static void initData(){
        SalesConsoleSettings.createSettings();
        WeWorkValidatorHelper.createTerritoryStructure();        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];
        System.assert(weworkSystemAdmin!=null);
        List<User> lstUsers = new List<User>();
        User weworkAdminUser = new User(Alias='APIU',Email='testadmin0021@example.com',EmailEncodingKey='UTF-8',LastName='APIUser',LanguageLocaleKey='en_US',LocaleSidKey = 'en_US',ProfileId = weworkSystemAdmin.Id,IsActive = true,TimeZoneSidKey='America/Los_Angeles',UserName='testadmin'+Datetime.now().getTime()+'@example.com',CommunityNickname = TestingUtility.createUserCommunityName());
        lstUsers.add(weworkAdminUser);
        User weworkUser = new User(Alias='USERT',Email='testuser551081@example.com',EmailEncodingKey='UTF-8',LastName='TestUser',LanguageLocaleKey='en_US',LocaleSidKey = 'en_US',ProfileId = weworkSystemAdmin.Id,IsActive = true,TimeZoneSidKey='America/Los_Angeles',UserName='newInactiveuser'+Datetime.now().getTime()+'@example.com',CommunityNickname = TestingUtility.createUserCommunityName());
        lstUsers.add(weworkUser);
        insert lstUsers;        
        Lead objLead = new Lead(OwnerId=weworkUser.Id,FirstName='John',LastName='Smith',Email='john.smit778106h@example.com',Company='Example',LeadSource='WeWork.com',Lead_Source_Detail__c='Book a Tour Form',Locations_Interested__c='Test Building Tour',Generate_Journey__c=false);
        insert objLead;
        
        Map<String, Object> mapData = new Map<String, Object>();        
        mapData.put('objName', 'Lead');        
        mapData.put('Generate_Journey__c', true);
        mapData.put('numberOfRecords', 1);
        List<Lead> lstLeads = new List<Lead>();
        Test.startTest();
        lstLeads = (List<Lead>)TestingUtility.getRecords(mapData);
        Test.stopTest();
        System.assertEquals(1, lstLeads.size());
    }
    
    @isTest
    public static void verifyFreshLeadCriteria(){
        Lead objLead = new Lead(FirstName='John',LastName='Smith',Email='john.smith@example.com',Phone = '1234567891',Company='Example',LeadSource='WeWork.com',Lead_Source_Detail__c='Book a Tour Form',Locations_Interested__c='Test Building Tour');
        Test.startTest();
        insert objLead;        
        Test.stopTest();
        System.assert(objLead.id != Null);
        List<Journey__c> lstJourneys = [Select Id,OwnerId,Primary_Lead__r.OwnerId From Journey__c Where Primary_Lead__c=:objLead.Id];
        System.assertEquals(1, lstJourneys.size(),'Journey not created');
        System.assertEquals(lstJourneys[0].Primary_Lead__r.OwnerId, lstJourneys[0].OwnerId,'Journey Owner should be lead owner.');
    }
  
    @isTest
    public static void verifyWithinXYDuplicateLeadCriteria(){
        Lead objLead = new Lead(FirstName='John',LastName='Smith',Email='john.smith@example.com',Phone = '1234567891',Company='Example',LeadSource='WeWork.com',Lead_Source_Detail__c='Book a Tour Form',Locations_Interested__c='Test Building Tour',Generate_Journey__c=false);
        insert objLead;
        Journey__c objJourney = new Journey__c(Name='Test Journey',Primary_Lead__c=objLead.Id,Status__c='Started',NMD_Next_Contact_Date__c=System.today());
        insert objJourney;
        Test.setCreatedDate(objJourney.Id,System.today().addDays(-5));
        Lead objDuplicateLead = new Lead(FirstName='John',LastName='Smith',Email='john.smith@example.com',Company='Example',LeadSource='WeWork.com',Lead_Source_Detail__c='Book a Tour Form',Locations_Interested__c='Test Building Tour');
        Test.startTest();
        insert objDuplicateLead;
        Test.stopTest();
        List<Journey__c> lstJourneys = [Select Id,OwnerId,Primary_Lead__c,Primary_Lead__r.OwnerId From Journey__c Where Primary_Lead__c=:objLead.Id Order By CreatedDate desc];
        System.assertEquals(2, lstJourneys.size(),'New journey not created');
        System.assertEquals(lstJourneys[0].Primary_Lead__c, objLead.Id,'Journey created on wrong lead.');
        System.assertEquals(lstJourneys[0].Primary_Lead__r.OwnerId, lstJourneys[0].OwnerId,'New Journey Owner should not be owner of lead');
    }
    
    @isTest
    public static void verifyBeyondYDuplicateLeadCriteria(){
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];
        User testUser = new User();
        testUser.LastName = 'Test Name 1';
        testUser.Username = 'verifyBeyondYDuplicateLeadCriteria'+Datetime.now().getTime()+'@example.com';
        testUser.Email = 'verifyBeyondYDuplicateLeadCriteria200192@example.com';
        testUser.ProfileId = weworkSystemAdmin.Id;
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US'; 
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.Alias = 'Name 1';
        insert testUser;
        
        Lead objLead = new Lead(FirstName='John',LastName='Smith',Email='john.smith@example.com',Company='Example',LeadSource='WeWork.com',Lead_Source_Detail__c='Book a Tour Form',Locations_Interested__c='Test Building Tour',Generate_Journey__c=false,Personal_Mailing_Street__c='Pimpri',Personal_Mailing_City__c='Pune',Personal_Mailing_PostalCode__c='411017',Personal_Mailing_Country__c='India',Personal_Mailing_State__c='Maharashtra',Promo_Code__c='Jet Blue');
        insert objLead;
        Journey__c objJourney = new Journey__c(Name='Test Journey',Primary_Lead__c=objLead.Id,Status__c='Started',NMD_Next_Contact_Date__c=System.today());
        insert objJourney;
        Test.setCreatedDate(objJourney.Id,System.today().addDays(-31));
        Lead objDuplicateLead = new Lead(FirstName='Duplicate',LastName='Smith',Email='john.smith@example.com',Company='Example',LeadSource='WeWork.com',Lead_Source_Detail__c='Book a Tour Form',Locations_Interested__c='Test Building Tour',Personal_Mailing_Street__c='Baner',Personal_Mailing_City__c='Pune',Personal_Mailing_PostalCode__c='411017',Personal_Mailing_Country__c='India',Personal_Mailing_State__c='Maharashtra',Promo_Code__c='Jet Blue');
        Test.startTest();
        insert objDuplicateLead;
        Test.stopTest();
        List<Journey__c> lstJourneys = [Select Id,OwnerId,Primary_Lead__c,Primary_Lead__r.OwnerId From Journey__c Where Primary_Lead__c=:objLead.Id Order By CreatedDate desc];
        System.assertEquals(2, lstJourneys.size(),'New journey not created');
        System.assertEquals(lstJourneys[0].Primary_Lead__c, objLead.Id,'Journey created on wrong lead.');
        System.assertEquals(lstJourneys[0].Primary_Lead__r.OwnerId, lstJourneys[0].OwnerId,'New Journey Owner should not be owner of lead');
        System.assertNotEquals(objLead.Personal_Mailing_Street__c, objDuplicateLead.Personal_Mailing_Street__c);
        System.assertEquals(objLead.Personal_Mailing_City__c, objDuplicateLead.Personal_Mailing_City__c);
        System.assertEquals(objLead.Personal_Mailing_State__c, objDuplicateLead.Personal_Mailing_State__c);
        System.assertEquals(objLead.Personal_Mailing_PostalCode__c, objDuplicateLead.Personal_Mailing_PostalCode__c);
        System.assertEquals(objLead.Personal_Mailing_Country__c, objDuplicateLead.Personal_Mailing_Country__c);
    }
    
    @isTest
    public static void verifyDuplicateLeadSubmissionOnContact(){
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];
        System.assert(weworkSystemAdmin!=null);
        User weworkAdminUser = new User(Alias='APIU',Email='testadmin03082018@example.com',EmailEncodingKey='UTF-8',LastName='APIUser',LanguageLocaleKey='en_US',LocaleSidKey = 'en_US',ProfileId = weworkSystemAdmin.Id,IsActive = false,TimeZoneSidKey='America/Los_Angeles',UserName='testadmin'+Datetime.now().getTime()+'@example.com',CommunityNickname = TestingUtility.createUserCommunityName());
        insert weworkAdminUser;
        System.assertNotEquals(null,weworkAdminUser.Id,'Active user');
        List<sObject> lstRecordsToInsert = new List<sObject>();
        Account objAccount = new Account(Name='Example', Unomy_Company_ID__c = 11111, Lead_Source__c='LeadSource1',Account_Type__c='Org');
        insert objAccount;
        Contact objContact = new Contact(FirstName='John',LastName='Smith',Email='john.smith@example.com',AccountId=objAccount.Id,Personal_Mailing_Street__c = 'Baner',Personal_Mailing_City__c = 'Pune', Personal_Mailing_State__c = 'Maharashtra',Personal_Mailing_PostalCode__c = '411017',Personal_Mailing_Country__c = 'India');
        insert objContact;
        Journey__c objJourney = new Journey__c(Name='Test Journey',Primary_Contact__c=objContact.Id,Status__c='Started',NMD_Next_Contact_Date__c=System.today());
        insert objJourney;
        Lead objDuplicateLead = new Lead(FirstName='Duplicate',LastName='Smith',Email='john.smith@example.com',Company='Example',LeadSource='WeWork.com',Lead_Source_Detail__c='Book a Tour Form',Locations_Interested__c='Test Building Tour',Personal_Mailing_Street__c='Pimpri',Personal_Mailing_City__c='Pune',Personal_Mailing_PostalCode__c='411017',Personal_Mailing_Country__c='India',Personal_Mailing_State__c='Maharashtra',Promo_Code__c='Jet Blue');
        Test.startTest();
        insert objDuplicateLead;
        Test.stopTest();
        List<Lead> lstLeads = new List<Lead>([SELECT Id, ConvertedContactId, ConvertedAccountId, Street, City, State, PostalCode, Country FROM Lead WHERE Id=:objDuplicateLead.Id]);
        System.assertEquals(objContact.Id, lstLeads[0].ConvertedContactId ,'Lead convert on existing Contact');
        System.assertEquals(objAccount.Id, lstLeads[0].ConvertedAccountId ,'Lead convert on existing Contact with related to Account');
        System.assertEquals(lstLeads[0].Street, objContact.MailingStreet);
        System.assertEquals(lstLeads[0].City, objContact.MailingCity);
        System.assertEquals(lstLeads[0].State, objContact.MailingState);
        System.assertEquals(lstLeads[0].PostalCode, objContact.MailingPostalCode);
        System.assertEquals(lstLeads[0].Country, objContact.MailingCountry);
    }
    
     @isTest
    public static void verifyContactCreateWhenLeadPresent(){
        Lead objLead = new Lead(FirstName='John',LastName='Smith',Email='john.smith@example.com',Company='Example',LeadSource='WeWork.com',Lead_Source_Detail__c='Book a Tour Form',Locations_Interested__c='Test Building Tour',Generate_Journey__c=false);
        insert objLead;
        Journey__c objJourney = new Journey__c(Name='Test Journey',Primary_Lead__c=objLead.Id,Status__c='Started',NMD_Next_Contact_Date__c=System.today());
        insert objJourney;
        Account objAccount = new Account(Name='Example', Unomy_Company_ID__c = 11111, Lead_Source__c='LeadSource1',Account_Type__c='Org');
        insert objAccount;
        Contact objContact = new Contact(FirstName='John',LastName='Smith',Email='john.smith@example.com',AccountId=objAccount.Id);
        insert objContact;
        Contact contactRec = [SELECT Id,(SELECT Id FROM Journeys__r) FROM Contact WHERE Email='john.smith@example.com' LIMIT 1];
        System.assertEquals(1,contactRec.Journeys__r.size());
    }
    
    @isTest
    public static void verifyTourPayload(){
        String jsonTourPayload = '{"first_name":"John","last_name":"Smith","email":"john.smith@example.com","phone":"1234567890","lead_source":"wework.com","lead_source_detail":"Book A Tour Form","utm_campaign_id":"","utm_campaign":"San Francisco - Modifier","utm_content":"utm contents","utm_medium":"cpc","utm_source":"ads-google","utm_term":"virtual +office +san +francisco","company_name":"John Smith","company_size":"2-5 desks","company_industry":"Education","quick_quote_location":"New York City","notes":"Our Notes for","referral_code":"JetBlue","promo_code":"JetBlue","buildings_interested_uuids":["bdf78b97-f8c9-4062-923d-ed32e251d2ad"],"product_interests":["Office Space"],"product_line":"WeWork","locale":"US","country_code":"US","tour_date":"2018-06-07","tour_time":"08:00AM","tour_uuid":"fdb15bdf-19e2-4abe-bd40-7b7fa9816fb5","tour_building_uuid":"bdf78b97-f8c9-4062-923d-ed32e251d2ad","tour_notes":"Currently at Manhattan, Relocate","contact_uuid":"dsp18593-3239-45cc-b690-5bccc15a27c3","original_tour":"","original_tour_uuid":"","sf_journey_uuid":"","booked_by_contact_id":"0033D00000Ou6FA","tour_completed_by":"","t_and_cs_consent":"False","marketing_consent":"False","affiliates_consent":"False","referral_fail_reason":"No Show","booked_by_sales_lead":true}';
        Map<String,Id> mapEntities = LeadConverterHelper.manageLead((RESTAPITourModelsV2.Input)JSON.deserialize(jsonTourPayload, RESTAPITourModelsV2.Input.class));
        System.assertNotEquals(null, mapEntities.get('accountId'), 'Using Tour payload new account created');
        System.assertNotEquals(null, mapEntities.get('contactId'), 'Using Tour payload new contact created');
    }
    
    @isTest
    public static void verifyTourPayloadForExistingLead(){
        Lead objLead = new Lead(FirstName='John',LastName='Smith',Email='john.smith@example.com',Company='Example',LeadSource='WeWork.com',Lead_Source_Detail__c='Book a Tour Form',Locations_Interested__c='Test Building Tour',Generate_Journey__c=false);
        insert objLead;
        String jsonTourPayload = '{"first_name":"John","last_name":"Smith","email":"john.smith@example.com","phone":"1234567890","lead_source":"wework.com","lead_source_detail":"Book A Tour Form","utm_campaign_id":"","utm_campaign":"San Francisco - Modifier","utm_content":"utm contents","utm_medium":"cpc","utm_source":"ads-google","utm_term":"virtual +office +san +francisco","company_name":"John Smith","company_size":"2-5 desks","company_industry":"Education","quick_quote_location":"New York City","notes":"Our Notes for","referral_code":"JetBlue","promo_code":"JetBlue","buildings_interested_uuids":["bdf78b97-f8c9-4062-923d-ed32e251d2ad"],"product_interests":["Office Space"],"product_line":"WeWork","locale":"US","country_code":"US","tour_date":"2018-06-07","tour_time":"08:00AM","tour_uuid":"fdb15bdf-19e2-4abe-bd40-7b7fa9816fb5","tour_building_uuid":"bdf78b97-f8c9-4062-923d-ed32e251d2ad","tour_notes":"Currently at Manhattan, Relocate","contact_uuid":"dsp18593-3239-45cc-b690-5bccc15a27c3","original_tour":"","original_tour_uuid":"","sf_journey_uuid":"","booked_by_contact_id":"0033D00000Ou6FA","tour_completed_by":"","t_and_cs_consent":"False","marketing_consent":"False","affiliates_consent":"False","referral_fail_reason":"No Show","booked_by_sales_lead":true}';
        Map<String,Id> mapEntities = LeadConverterHelper.manageLead((RESTAPITourModelsV2.Input)JSON.deserialize(jsonTourPayload, RESTAPITourModelsV2.Input.class));
        List<Lead> lstLeads = [SELECT Id, ConvertedContactId, ConvertedAccountId FROM Lead WHERE Id=:objLead.Id];
        System.assertEquals(lstLeads[0].ConvertedAccountId, mapEntities.get('accountId'), 'Using Tour payload new account created');
        System.assertEquals(lstLeads[0].ConvertedContactId, mapEntities.get('contactId'), 'Using Tour payload new contact created');
    }
    
    @isTest
    public static void verifyTourPayloadForExistingLeadWithInactiveUser(){
        User weworkAdminUser = [SELECT Id FROM User WHERE Email = 'testadmin0021@example.com'];
        User weworkUser = [SELECT Id FROM User WHERE Email = 'testuser551081@example.com'];
        System.assertNotEquals(null,weworkAdminUser.Id,'Active user');
        System.assertNotEquals(null,weworkUser.Id,'Active user');
        Lead objLead = [SELECT Id FROM Lead WHERE Email = 'john.smit778106h@example.com'];        
        weworkUser.IsActive = false;
        update weworkUser;
        Settings.lstUsers = null;        
        System.runAs(weworkAdminUser) {          
            String jsonTourPayload = '{"first_name":"John","last_name":"Smith","email":"john.smit778106h@example.com","phone":"1234567890","lead_source":"wework.com","lead_source_detail":"Book A Tour Form","utm_campaign_id":"","utm_campaign":"San Francisco - Modifier","utm_content":"utm contents","utm_medium":"cpc","utm_source":"ads-google","utm_term":"virtual +office +san +francisco","company_name":"John Smith","company_size":"2-5 desks","company_industry":"Education","quick_quote_location":"New York City","notes":"Our Notes for","referral_code":"JetBlue","promo_code":"JetBlue","buildings_interested_uuids":["bdf78b97-f8c9-4062-923d-ed32e251d2ad"],"product_interests":["Office Space"],"product_line":"WeWork","locale":"US","country_code":"US","tour_date":"2018-06-07","tour_time":"08:00AM","tour_uuid":"fdb15bdf-19e2-4abe-bd40-7b7fa9816fb5","tour_building_uuid":"bdf78b97-f8c9-4062-923d-ed32e251d2ad","tour_notes":"Currently at Manhattan, Relocate","contact_uuid":"dsp18593-3239-45cc-b690-5bccc15a27c3","original_tour":"","original_tour_uuid":"","sf_journey_uuid":"","booked_by_contact_id":"0033D00000Ou6FA","tour_completed_by":"","t_and_cs_consent":"False","marketing_consent":"False","affiliates_consent":"False","referral_fail_reason":"No Show","booked_by_sales_lead":true}';
            Test.startTest();
            Map<String,Id> mapEntities = LeadConverterHelper.manageLead((RESTAPITourModelsV2.Input)JSON.deserialize(jsonTourPayload, RESTAPITourModelsV2.Input.class));
            Test.stopTest();
            List<Lead> lstLeads = [SELECT Id, OwnerId, ConvertedContactId, ConvertedAccountId FROM Lead WHERE Id=:objLead.Id];
            System.assertEquals(lstLeads[0].ConvertedAccountId, mapEntities.get('accountId'), 'Using Tour payload new account created');
            System.assertEquals(lstLeads[0].ConvertedContactId, mapEntities.get('contactId'), 'Using Tour payload new contact created');
            System.assertEquals('005F0000003KmbwIAC', lstLeads[0].OwnerId, 'Using Tour payload new contact created');
        }
    }
    
    @isTest
    public static void verifyTourPayloadForExistingContact(){
        Account objAccount = new Account(Name='Example', Unomy_Company_ID__c = 11111, Lead_Source__c='LeadSource1',Account_Type__c='Org');
        insert objAccount;       
        Contact objContact = new Contact(FirstName='John',LastName='Smith',Email='john.smith@example.com',Unomy_Company_ID__c = 11111);
        insert objContact;
        String jsonTourPayload = '{"first_name":"John","last_name":"Smith","email":"john.smith@example.com","phone":"1234567890","lead_source":"wework.com","lead_source_detail":"Book A Tour Form","utm_campaign_id":"","utm_campaign":"San Francisco - Modifier","utm_content":"utm contents","utm_medium":"cpc","utm_source":"ads-google","utm_term":"virtual +office +san +francisco","company_name":"John Smith","company_size":"2-5 desks","company_industry":"Education","quick_quote_location":"New York City","notes":"Our Notes for","referral_code":"JetBlue","promo_code":"JetBlue","buildings_interested_uuids":["bdf78b97-f8c9-4062-923d-ed32e251d2ad"],"product_interests":["Office Space"],"product_line":"WeWork","locale":"US","country_code":"US","tour_date":"2018-06-07","tour_time":"08:00AM","tour_uuid":"fdb15bdf-19e2-4abe-bd40-7b7fa9816fb5","tour_building_uuid":"bdf78b97-f8c9-4062-923d-ed32e251d2ad","tour_notes":"Currently at Manhattan, Relocate","contact_uuid":"dsp18593-3239-45cc-b690-5bccc15a27c3","original_tour":"","original_tour_uuid":"","sf_journey_uuid":"","booked_by_contact_id":"0033D00000Ou6FA","tour_completed_by":"","t_and_cs_consent":"False","marketing_consent":"False","affiliates_consent":"False","referral_fail_reason":"No Show","booked_by_sales_lead":true}';
        Map<String,Id> mapEntities = LeadConverterHelper.manageLead((RESTAPITourModelsV2.Input)JSON.deserialize(jsonTourPayload, RESTAPITourModelsV2.Input.class));
        System.assertEquals(objAccount.Id, mapEntities.get('accountId'), 'Using Tour payload new account created');
        System.assertEquals(objContact.Id, mapEntities.get('contactId'), 'Using Tour payload new contact created');
    }
    
    @isTest
    public static void verifyTourPayloadForExistingContactWithUUID(){
        Contact objContact = new Contact(FirstName='John',LastName='Smith',Email='john.smith@example.com',UUId__c='dsp18593-3239-45cc-b690-5bccc15a27c3');
        insert objContact;
        String jsonTourPayload = '{"first_name":"John","last_name":"Smith","email":"john.smith@example.com","phone":"1234567890","lead_source":"wework.com","lead_source_detail":"Book A Tour Form","utm_campaign_id":"","utm_campaign":"San Francisco - Modifier","utm_content":"utm contents","utm_medium":"cpc","utm_source":"ads-google","utm_term":"virtual +office +san +francisco","company_name":"John Smith","company_size":"2-5 desks","company_industry":"Education","quick_quote_location":"New York City","notes":"Our Notes for","referral_code":"JetBlue","promo_code":"JetBlue","buildings_interested_uuids":["bdf78b97-f8c9-4062-923d-ed32e251d2ad"],"product_interests":["Office Space"],"product_line":"WeWork","locale":"US","country_code":"US","tour_date":"2018-06-07","tour_time":"08:00AM","tour_uuid":"fdb15bdf-19e2-4abe-bd40-7b7fa9816fb5","tour_building_uuid":"bdf78b97-f8c9-4062-923d-ed32e251d2ad","tour_notes":"Currently at Manhattan, Relocate","contact_uuid":"dsp18593-3239-45cc-b690-5bccc15a27c3","original_tour":"","original_tour_uuid":"","sf_journey_uuid":"","booked_by_contact_id":"0033D00000Ou6FA","tour_completed_by":"","t_and_cs_consent":"False","marketing_consent":"False","affiliates_consent":"False","referral_fail_reason":"No Show","booked_by_sales_lead":true}';
        Map<String,Id> mapEntities = LeadConverterHelper.manageLead((RESTAPITourModelsV2.Input)JSON.deserialize(jsonTourPayload, RESTAPITourModelsV2.Input.class));
        List<Contact> lstContacts = [SELECT Id, AccountId FROM Contact WHERE Id=:objContact.Id];
        System.assertNotEquals(Null, lstContacts[0].AccountId, 'Using Tour payload new account created for contact and binded with contact');
        System.assertEquals(objContact.Id, mapEntities.get('contactId'), 'Using Tour payload new contact created');
        System.assertEquals(lstContacts[0].AccountId, mapEntities.get('accountId'), 'Using Tour payload new Account created');
    }
    
    @isTest
    public static void verifyNegativeCondition(){
        System.assertEquals(null, LeadConverterHelper.manageLead(new Lead()), 'verify null condition single lead parameter');
        System.assertEquals(null, LeadConverterHelper.manageLead(new List<Lead>()), 'verify null condition list lead parameter');
        System.assertEquals(null, LeadConverterHelper.manageLead(new RESTAPITourModelsV2.Input()), 'verify null condition tour parameter');
        System.assertEquals(null, LeadConverterHelper.manageJourneyForLead(new List<Lead>(),false), 'verify null condition tour parameter');
    }
    
    @isTest
    public static void verifyconvertLeadWithTour(){
        List<Lead> lstleadData = [SELECT Id, FirstName, Interested_in_Number_of_Desks_Min__c, Interested_in_Number_of_Desks__c, LastName, Name, Product_Line__c, OwnerId, Email_Domain__c, Company, Account__c, Account__r.Account_Type__c, Referrer__c, Cleansed_Unomy_Company_Name__c, Cleansed_Company_Name__c, Email, Unomy_Company_ID__c, Unomy_Company_Name__c, LeadSource, Lead_Source_Detail__c, Generate_Journey__c, By_Pass_Journey_Creation_Criteria__c, Campaign_Id__c, Building_Interested_In__c, Building_Interested_In__r.City__c, Locations_Interested__c, Number_of_Full_Time_Employees__c, Company_Size__c, Markets_Interested__c FROM Lead WHERE IsConverted=false AND Email = 'john.smit778106h@example.com'];
        System.assertNotEquals(null, LeadConverterHelper.convertLeadWithTour(lstleadData[0]), 'Lead not converted with tour Payload');
    }    
    
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to verify convert leads to existing lead
        Created Date        :   6 Dec 2018        
    *************************************************************************************************************************************/
    @isTest
    public static void verifySetLeadGenerateJourney(){
        Lead objLead = new Lead(LastName='Smith',Email='email@enazigma.com',Phone='1234567891',Company='Test Company',Locations_Interested__c='Test Building Tour',LeadSource='Broker',Lead_Source_Detail__c='Broker1');
        insert objLead;
        System.assert(objLead.id!= null);
        DatabaseResult result = LightningComponentController.convertLeadsToExisting(objLead);
        System.assertEquals(true, result.success);
    } 
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to get the Journey Closed Stages.
        Created Date        :   6 Dec 2018        
*************************************************************************************************************************************/
    @isTest
    public static void verifyGetJourneyCloseStages(){
        Set<String> setStages = JourneyHelper.getJourneyCloseStages();
        System.assert(setStages != NULL);
        JourneyHelper.JourneyCreationSetting objSetting = new JourneyHelper.JourneyCreationSetting();        
        System.assert(objSetting != NULL);
        objSetting.NextCallInDaysFromLeadCreation = 5;
        objSetting.NextCallInDaysFromJourneyUpdation = 6;
        objSetting.ExistingJourneyStage = 'Accepted';       
        objSetting.AssignExistingJourneyOwner = 5;        
        objSetting.ExistingJourneyCreatedDateDifference = 25;        
        objSetting.JourneyAssignmentCutOffDays = 2;        
        objSetting.CloseInDaysFromJourneyCreation = 10;   
        Set<String> setCloseStages = new Set<String>{'Completed','Unqualified'};
            objSetting.ClosedJourneyStages = setCloseStages;        
        System.assertEquals(2, objSetting.ClosedJourneyStages.Size());        
    }
    /************************************************************************************************************************************
        Author              :   Jitesh Adwani
        Description         :   This method is used to get the JourneyId By LeadId .
        Created Date        :   6 Dec 2018        
*************************************************************************************************************************************/
    @isTest
    public static void verifyGetJourneyByLeadId(){
        List<Lead> lstLeads = new List<Lead>([SELECT Id, Lead_Id__c FROM Lead]);
        List<Journey__c> lstJourneys = new List<Journey__c>([SELECT Id, Lead_Id__c FROM Journey__c]);
        Id journeyId = LeadConverterHelper.getJourneyByLeadId(lstLeads[1].Id, lstJourneys);
        System.assertEquals(lstJourneys[0].Id, journeyId);
    }
}