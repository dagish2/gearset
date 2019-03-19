/************************************************************************************************************************************
  Author        : Dipak Pawar
  Description   : This class is used to test RESTAPITourV2
   
History:
----------------------------------------------------------------------------------------------------------------------------------
  VERSION       DATE                AUTHOR              DETAIL                                              ISSUE
    1           19 June 2018       Dipak Pawar         Initial Developement                                ST-
**************************************************************************************************************************************/
@isTest
public class RESTAPITourV2Test {
    public static User apiUser;
    public static Building__c b; 
    public static Contact nmdContact;
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This setup method will setup the initial test data for verification of Tour and Task creation functionality. 
        Created Date  		:   07 June 2018  
        Issue No			:	ST-
    **************************************************************************************************************************************/
    @TestSetup
    public static void setupData() {
        SalesConsoleSettings.createSettings();       
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        apiUser = new User();
        apiUser.Alias = 'APIU';
        apiUser.Email='test@example.com';
        apiUser.EmailEncodingKey='UTF-8';
        apiUser.LastName='APIUser';
        apiUser.LanguageLocaleKey='en_US';
        apiUser.LocaleSidKey = 'en_US';
        apiuser.ProfileId = weworkSystemAdmin.Id;
        apiUser.IsActive = true;
        apiUser.TimeZoneSidKey='America/Los_Angeles';
        apiUser.UserName='tourapiuser@example.com';
        apiUser.CommunityNickname = TestingUtility.createUserCommunityName();      
        insert apiUser;
        
        Map<String, Object> mapCommunitySalesLead = new Map<String, Object>();
        mapCommunitySalesLead.put('LastName', 'TestCommunitySalesLead');
        mapCommunitySalesLead.put('Username', 'TestCommunitySalesLead@weworkexample.com');
        mapCommunitySalesLead.put('Email', 'joinus@wework.com');
        User CommunityLead = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapCommunitySalesLead, true);
        
        nmdContact = new Contact(FirstName='WeWork', LastName='NMD USER',Email='joinus@wework.com');
        insert nmdContact;
        
        Setting__c testTourRservableSettings = new Setting__c();
        testTourRservableSettings.Name = 'TourRservableSettings';
        testTourRservableSettings.Data__c = '{"salesleadprofiles": [{"profilename":"System Administrator", "profileid":"00eF0000000Rfpc"}], "bookedbysalesleadlabel":"Booked By Sales Lead", "apiuseremail":"joinus@wework.com", "apiuserid":"005F0000003KmbwIAC", "apiusercontactid":"'+nmdContact.Id+'"}';
        insert testTourRservableSettings;
         
        TestingUtility.getRecords(new Map<String, Object> {'objName'=>'touropenhour','numberOfRecords'=>'1'});
        TestingUtility.getRecords(new Map<String, object> {'objName'=>'journey','numberOfRecords'=>'1'});
        
        List<Building__c> lstBuilding = [SELECT Id, City__c, uuid__c, Name FROM Building__c WHERE Name LIKE 'testBuilding%'];
        
        List<Tour_Schedule__c> lstTourSchedule = [SELECT Building__c, Simultaneous_Tours__c, Tour_Spacing__c, Maximum_Tour_Days__c FROM Tour_Schedule__c];
        List<Tour_Open_Hour__c> lstTourOpenHour = [SELECT weekday__c, start_time__c, end_time__c, Tour_Schedule__c, Building__c FROM Tour_Open_Hour__c];
    }    
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method gives the sample tour payload for tour booking;
        Created Date  		:   07 June 2018  
        Issue No			:	ST-
    **************************************************************************************************************************************/
    public static RESTAPITourModelsV2.Input getTourPayload (){
        List<Building__c> lstBuilding = [SELECT Id, City__c, uuid__c, Name FROM Building__c WHERE Name LIKE 'testBuilding%'];
        Debug.Log('lstBuilding Data==>'+lstBuilding);
        String jsonPayload = '{"desks_interested_min":"2","desks_interested_max":"3","desks_interested_range":"10-20","first_name":"John","last_name":"Smith0706201801","email":"john.smith0706201802@example.com","phone":"8600139164","lead_source":"wework.com","lead_source_detail":"Book A Tour Form","utm_campaign_id":"","utm_campaign":"San Francisco - Modifier","utm_content":"utm contents","utm_medium":"cpc","utm_source":"ads-google","utm_term":"virtual +office +san +francisco","company_name":"John Smith","company_size":"2-5 desks","company_industry":"Education","quick_quote_location":"New York City","notes":"Our Notes for","referral_code":"JetBlue","promo_code":"JetBlue","buildings_interested_uuids":["bdf78b97-f8c9-4062-923d-ed32e251d2ad"],"product_interests":["Office Space"],"product_line":"WeWork","locale":"US","country_code":"US","tour_date":"2018-06-07","tour_time":"08:00AM","tour_uuid":"fdb15bdf-19e2-4abe-bd40-7b7fa9816fb5","tour_building_uuid":"'+lstBuilding[0].UUID__c+'","tour_notes":"Currently at Manhattan, Relocate","contact_uuid":"dsp18593-3239-45cc-b690-5bccc15a27c3","original_tour":"","original_tour_uuid":"","sf_journey_uuid":"","booked_by_contact_id":"0033D00000Ou6FA","tour_completed_by":"","t_and_cs_consent":"False","marketing_consent":"False","affiliates_consent":"False","referral_fail_reason":"No Show","booked_by_sales_lead":true}';
        RESTAPITourModelsV2.Input tourPayload = (RESTAPITourModelsV2.Input)JSON.deserialize(jsonPayload, RESTAPITourModelsV2.Input.class);
        return tourPayload;
    }  
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies the task creation functionality for tour booking When Account is Consumer and Booked By Contact Id is null.
        Created Date  		:   07 June 2018  
        Issue No			:	ST-
	**************************************************************************************************************************************/
    public static testMethod void verifyCreateTaskForTourConsumer() {
        User apiUser = [SELECT Id FROM User WHERE UserName = 'tourapiuser@example.com'];
        List<Account> lstAccount = new List<Account>([SELECT Id, OwnerId, UUID__c, RecordTypeId FROM Account]);
        List<Contact> lstContact = new List<Contact>([SELECT Id, FirstName, LastName, UUID__c, Email FROM Contact]);
        System.runAs(apiUser){
            lstAccount[0].UUID__c = 'account-uuid';
            lstAccount[0].OwnerId = apiUser.Id;
            TestingUtility.updateListWithAssert(lstAccount);
        }
        
        RESTAPITourModelsV2.Input tourPayload = getTourPayload();       
        tourPayload.contact_uuid = lstContact[0].UUID__c;        
        tourPayload.booked_by_contact_id =null;
        tourPayload.booked_by_sales_lead = false;
        tourPayload.email = lstContact[0].Email; 
        tourPayload.first_name = lstContact[0].FirstName;
        tourPayload.last_name = lstContact[0].LastName;
        Test.startTest();        
        //submit post
        RESTAPIResult response = new RESTAPIResult();       
        response.setSuccess(RESTAPITourV2.bookTour(tourPayload));
        
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);
        
        List<Opportunity>lstOpps = [SELECT Id, OwnerId ,Primary_Member__c, RecordType.Name,AccountId,Account.OwnerId,Account.RecordType.Name FROM Opportunity WHERE Primary_Member__r.email = :lstContact[0].email];
        System.assert(lstOpps.size() > 0,'An opportunity should be created');
       
        User SusuieRomero = [SELECT Id, Name FROM User WHERE Id = '005F0000003KmbwIAC'];
        System.assertEquals(lstOpps[0].RecordType.Name, lstOpps[0].Account.RecordType.Name,'Opportunity Record Type should be same as Account Record Type.');		
        System.assertEquals(lstOpps[0].Account.OwnerId,lstOpps[0].OwnerId,'Opportunity owner should be same as Account owner as Account of Opportunity is mid market.');
        
        List<Tour_Outcome__c> lstTours = [SELECT id, Opportunity__c, tour_completed_by__c, tour_completed_by_UUID__c, tour_completed_by_Name__c, tour_completed_by_SFID__c,
                                          Booked_By_Sales_Lead__c, Hosted_By__c, Assigned_Host__c, OwnerId, booked_by_contact_id__c FROM Tour_Outcome__c WHERE tour_date__c = :tourPayload.tour_date ];
        System.assert(lstTours.size() > 0,'A tour for the specified date should be created:' + tourPayload.tour_date);  
        
        System.assertEquals(SusuieRomero.Id, lstTours[0].OwnerId);
        System.assertEquals(false, lstTours[0].Booked_By_Sales_Lead__c);
        System.assertEquals(lstTours[0].booked_by_contact_id__c, lstTours[0].Assigned_Host__c);        
        RESTAPITourModelsV2.Response res = (RESTAPITourModelsV2.Response)JSON.deserialize(JSON.serialize(response.result), RESTAPITourModelsV2.Response.class);
        System.assert(response.success != null && response.success && String.valueOf(res.tour_sfid).equals(lstTours[0].Id),'The tour id should be provided as response; ' + lstTours[0].Id);                                      
        System.assert(response.success != null && response.success && String.valueOf(res.contact_sfid).equals(lstContact[0].Id),'The Contact Id which tour should booked should be provided as response; ' + lstContact[0].Id);                                      
        Test.stopTest(); 
    }      
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies the task creation functionality for tour booking When Account is Mid Market and Booked By Contact Id is null.
        Created Date  		:   11 June 2018   
        Issue No			:	ST-
    **************************************************************************************************************************************/
    public static testMethod void verifyCreateTaskForTourMidMarket() {
        User apiUser = [SELECT Id FROM User WHERE UserName = 'tourapiuser@example.com'];
        List<Account> lstAccount = new List<Account>([SELECT Id, OwnerId, UUID__c, RecordTypeId FROM Account]);
        List<Contact> lstContact = new List<Contact>([SELECT Id, FirstName, LastName, UUID__c, Email FROM Contact]);
        System.runAs(apiUser){
            lstAccount[0].UUID__c = 'account-uuid';
            lstAccount[0].OwnerId = apiUser.Id;
            lstAccount[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
            TestingUtility.updateWithAssert(lstAccount[0]);
        }
        
        lstContact[0].UUID__c = 'contact-uuid';
        TestingUtility.updateWithAssert(lstContact[0]);
        
        
        RESTAPITourModelsV2.Input tourPayload = getTourPayload();       
        tourPayload.contact_uuid = lstContact[0].UUID__c;        
        tourPayload.booked_by_contact_id = null;
        tourPayload.booked_by_sales_lead = false;
        tourPayload.email = lstContact[0].Email; 
        tourPayload.first_name = lstContact[0].FirstName;
        tourPayload.last_name = lstContact[0].LastName;
        Test.startTest();        
        RESTAPIResult response = new RESTAPIResult();
        response.setSuccess(RESTAPITourV2.bookTour(tourPayload));        
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);
        List<Opportunity>lstOpps = [SELECT Id, OwnerId ,Primary_Member__c, RecordType.Name,AccountId,Account.OwnerId,Account.RecordType.Name FROM Opportunity WHERE Primary_Member__r.email = :lstContact[0].email];
        
        System.assert(lstOpps.size() > 0,'An opportunity should be created');
        System.assertEquals(lstOpps[0].RecordType.Name, lstOpps[0].Account.RecordType.Name,'Opportunity Record Type should be same as Account Record Type.');		
        System.assertEquals(lstOpps[0].Account.OwnerId,lstOpps[0].OwnerId,'Opportunity owner should be same as Account owner as Account of Opportunity is mid market.');
        
        List<Tour_Outcome__c> lstTours = [SELECT id, Opportunity__c, tour_completed_by__c, tour_completed_by_UUID__c, tour_completed_by_Name__c, tour_completed_by_SFID__c,
                                          Booked_By_Sales_Lead__c, Hosted_By__c, Assigned_Host__c, OwnerId, booked_by_contact_id__c FROM Tour_Outcome__c WHERE tour_date__c = :tourPayload.tour_date ];
        
        System.assert(lstTours.size() > 0,'A tour for the specified date should be created:' + tourPayload.tour_date);  
        
        System.assertEquals(false, lstTours[0].Booked_By_Sales_Lead__c);
        System.assertEquals(lstTours[0].booked_by_contact_id__c, lstTours[0].Assigned_Host__c);        
        RESTAPITourModelsV2.Response res = (RESTAPITourModelsV2.Response)JSON.deserialize(JSON.serialize(response.result), RESTAPITourModelsV2.Response.class);
        System.assert(response.success != null && response.success && String.valueOf(res.tour_sfid).equals(lstTours[0].Id),'The tour id should be provided as response; ' + lstTours[0].Id);                                      
        System.assert(response.success != null && response.success && String.valueOf(res.contact_sfid).equals(lstContact[0].Id),'The Contact Id which tour should booked should be provided as response; ' + lstContact[0].Id);                                      
        Test.stopTest();
    }   
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies the task creation functionality for tour booking When Account is Mid Market and Booked By Contact Id is given.
        Created Date  		:   11 June 2018  
        Issue No			:	
	**************************************************************************************************************************************/
    public static testMethod void verifyCreateTaskForTourMidMarketWithBookedByConId() {
        User apiUser = [SELECT Id FROM User WHERE UserName = 'tourapiuser@example.com'];
        List<Account> lstAccount = new List<Account>([SELECT Id, OwnerId, UUID__c, RecordTypeId FROM Account]);
        List<Contact> lstContact = new List<Contact>([SELECT Id, FirstName, LastName, UUID__c, Email FROM Contact]);
        
        System.runAs(apiUser){
            lstAccount[0].Name = 'A Company';
            lstAccount[0].UUID__c = 'account-uuid';
            lstAccount[0].OwnerId = apiUser.Id;
            lstAccount[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
            TestingUtility.updateWithAssert(lstAccount[0]);
        }
        
        lstContact[0].UUID__c = 'contact-uuid';
        lstContact[0].Email = 'testtourcompletedbycontact@example.com';
        TestingUtility.updateWithAssert(lstContact[0]);
        
        RESTAPITourModelsV2.Input tourPayload = getTourPayload();       
        tourPayload.contact_uuid = lstContact[0].UUID__c;        
        tourPayload.booked_by_contact_id = lstContact[0].Id;
        tourPayload.booked_by_sales_lead = false;
        tourPayload.email = lstContact[0].Email; 
        tourPayload.first_name = lstContact[0].FirstName;
        tourPayload.last_name = lstContact[0].LastName;
        Test.startTest();               
        RESTAPI.PayloadDetails payload = new RESTAPI.PayloadDetails();
        payload.Input = tourPayload;
        RESTAPIResult response = new RESTAPITourV2().executePost(payload);
        System.assertEquals(true, response.success, 'Response msg: ' + response.message);
        
        List<Opportunity> lstOpps = [SELECT Id, OwnerId, Primary_Member__c, RecordType.Name, AccountId, Account.OwnerId, Account.RecordType.Name FROM Opportunity WHERE Primary_Member__r.email = :lstContact[0].email];
        System.assert(lstOpps.size() > 0,'An opportunity should be created');
        
        System.assertEquals(lstOpps[0].RecordType.Name, lstOpps[0].Account.RecordType.Name, 'Opportunity Record Type should be same as Account Record Type.');		
        System.assertEquals(lstOpps[0].Account.OwnerId, lstOpps[0].OwnerId, 'Opportunity owner should be same as Account owner as Account of Opportunity is mid market.');
        List<Tour_Outcome__c> lstTours = [SELECT Id, Opportunity__c, tour_completed_by__c, tour_completed_by_UUID__c, tour_completed_by_Name__c, tour_completed_by_SFID__c,
                                          Booked_By_Sales_Lead__c, Hosted_By__c, Assigned_Host__c, OwnerId, booked_by_contact_id__c FROM Tour_Outcome__c WHERE tour_date__c = :tourPayload.tour_date];
        System.debug('lstTours[0].Assigned_Host__c-->'+lstTours[0].Assigned_Host__c);
        System.assert(lstTours.size() > 0, 'A tour for the specified date should be created:' + tourPayload.tour_date); 
        
        User susuieRomero = [SELECT Id, Name FROM User WHERE Id = '005F0000003KmbwIAC'];
        System.assertEquals(susuieRomero.Id, lstTours[0].OwnerId);
        System.assertEquals(false, lstTours[0].Booked_By_Sales_Lead__c);
        System.assertEquals(lstTours[0].booked_by_contact_id__c, lstContact[0].Id);
        RESTAPITourModelsV2.Response res = (RESTAPITourModelsV2.Response)JSON.deserialize(JSON.serialize(response.result), RESTAPITourModelsV2.Response.class);
        
        System.assert(response.success != null && response.success && String.valueOf(res.tour_sfid).equals(lstTours[0].Id),'The tour id should be provided as response; ' + lstTours[0].Id);                                      
        System.assert(response.success != null && response.success && String.valueOf(res.contact_sfid).equals(lstContact[0].Id),'The Contact Id which tour should booked should be provided as response; ' + lstContact[0].Id);                                      
        Test.stopTest();
    }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   
        Created Date  		:   12 June 2018  
        Issue No			:	ST-2482
	**************************************************************************************************************************************/
    public static testMethod void verifyCreateTaskForTourReschedule(){
        User apiUser = [SELECT Id FROM User WHERE UserName = 'tourapiuser@example.com'];
        List<Account> lstAccount = new List<Account>([SELECT Id, OwnerId, UUID__c, RecordTypeId FROM Account]);
        List<Contact> lstContact = new List<Contact>([SELECT Id, FirstName, LastName, UUID__c, Email FROM Contact]);
        List<Building__c> lstBuilding = [SELECT Id, City__c, uuid__c, Name FROM Building__c WHERE Name LIKE 'testBuilding%'];
        System.runAs(apiUser){
            lstAccount[0].UUID__c = 'account-uuid';
            lstAccount[0].OwnerId = apiUser.Id;
            TestingUtility.updateListWithAssert(lstAccount);
        }       
        lstContact[0].UUID__c = 'contact-uuid';
        lstContact[0].Email = 'testtourcompletedbycontact@example.com';
        TestingUtility.updateWithAssert(lstContact[0]);
        RESTAPITourModelsV2.Input tourPayload = getTourPayload();       
        tourPayload.contact_uuid = lstContact[0].UUID__c;        
        tourPayload.booked_by_contact_id = null;
        tourPayload.booked_by_sales_lead = false;
        tourPayload.email = lstContact[0].Email; 
        tourPayload.first_name = lstContact[0].FirstName;
        tourPayload.last_name = lstContact[0].LastName;
        Test.startTest();
        RESTAPIResult result = new RESTAPIResult();
        result.setSuccess(RESTAPITourV2.bookTour(tourPayload));
        System.assertEquals(true, result.success, 'Response msg: ' + result.message);
        List<Opportunity>lstOpps = [SELECT Id, OwnerId ,Primary_Member__c, RecordType.Name,AccountId,Account.OwnerId,Account.RecordType.Name FROM Opportunity WHERE Primary_Member__r.email = :lstContact[0].email];
        
        System.assert(lstOpps.size() > 0,'An opportunity should be created');
        
        System.assertEquals(lstOpps[0].RecordType.Name, lstOpps[0].Account.RecordType.Name,'Opportunity Record Type should be same as Account Record Type.');		
        System.assertEquals(apiUser.Id, lstOpps[0].OwnerId); 
        
        List<Tour_Outcome__c> lstTours = [SELECT id, Status__c, Opportunity__c, tour_completed_by__c, tour_completed_by_UUID__c, tour_completed_by_Name__c, tour_completed_by_SFID__c,
                                          Booked_By_Sales_Lead__c, Hosted_By__c, Assigned_Host__c, OwnerId, booked_by_contact_id__c, uuid__c, Original_Tour__c, Original_Tour__r.uuid__c FROM Tour_Outcome__c WHERE tour_date__c = :tourPayload.tour_date ];
        
        System.assert(lstTours.size() > 0, 'A tour for the specified date should be created:' + tourPayload.tour_date);  
        
        System.assertEquals(1, lstTours.size());
        System.assertEquals('Scheduled', lstTours[0].Status__c);
        System.assertEquals('fdb15bdf-19e2-4abe-bd40-7b7fa9816fb5', lstTours[0].uuid__c);
        
        tourPayload.original_tour_uuid = 'fdb15bdf-19e2-4abe-bd40-7b7fa9816fb5';
        tourPayload.tour_uuid = 'fdb15bdf-19e2-4abe-bd40-7b7fa9812345';

		List<Journey__c> lstJourney1 = new List<Journey__c>([SELECT Id, Status__c, Name FROM Journey__c WHERE Primary_Contact__c =: lstContact[0].Id]);
        lstJourney1[0].Status__c = 'Started';
        TestingUtility.updateWithAssert(lstJourney1[0]);	
        
        result = new RESTAPIResult();
        result.setSuccess(RESTAPITourV2.bookTour(tourPayload));
        
        system.assertEquals(true, result.success, 'Response msg: ' + result.message);
        lstTours = [SELECT id, Status__c, Opportunity__c, tour_completed_by__c, tour_completed_by_UUID__c, tour_completed_by_Name__c, tour_completed_by_SFID__c,
                    Booked_By_Sales_Lead__c, Hosted_By__c, Assigned_Host__c, OwnerId, booked_by_contact_id__c, uuid__c, Original_Tour__c, Original_Tour__r.uuid__c FROM Tour_Outcome__c WHERE tour_date__c = :tourPayload.tour_date ];
        System.assert(lstTours.size() > 0,'A tour for the specified date should be created:' + tourPayload.tour_date);
        System.assertEquals(2, lstTours.size());
        for(Tour_Outcome__c tour : lstTours){
            if(tour.uuid__c == 'fdb15bdf-19e2-4abe-bd40-7b7fa9816fb5'){
                System.assertEquals('Scheduled', tour.Status__c);
            } else if(tour.uuid__c == 'fdb15bdf-19e2-4abe-bd40-7b7fa9812345'){
                System.assertEquals('Scheduled', tour.Status__c);
                System.assertNotEquals(null, tour.Original_Tour__c);
                System.assertEquals('fdb15bdf-19e2-4abe-bd40-7b7fa9816fb5', tour.Original_Tour__r.uuid__c);
            }
        }        
        Test.stopTest();
    } 
    
}