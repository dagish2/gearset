@isTest
public class TourOutcomeFormControllerTest{
    @TestSetup 
    static void testDataSetup() {
        SalesConsoleSettings.createSettings(); 
        Map<String, Object> mapContactFieldValues = new Map<String, Object>();
        List<Contact> lstContacts = new List<Contact>();
        mapContactFieldValues.put('firstname', 'test');
        mapContactFieldValues.put('lastname', 'Contact');
        mapContactFieldValues.put('email', 'joinus@wework.com');
        mapContactFieldValues.put('Status__c', 'active');
        mapContactFieldValues.put('UUID__c', 'UUID1');
        lstContacts.add((Contact)TestingUtility.createTestRecords(Contact.sObjectType,mapContactFieldValues,false));
        mapContactFieldValues.put('firstname', 'test');
        mapContactFieldValues.put('lastname', 'Contact1');
        mapContactFieldValues.put('email', 'testUser@wework.com');
        mapContactFieldValues.put('Status__c', 'active');
        mapContactFieldValues.put('UUID__c', 'UUID2');
        lstContacts.add((Contact)TestingUtility.createTestRecords(Contact.sObjectType, mapContactFieldValues, false));
        TestingUtility.insertListWithAssert(lstContacts);
        
        List<Building__c> lstBuildings = new List<Building__c>();
        Map<String, Object> mapBuildingFieldValues = new Map<String, Object>();
        mapBuildingFieldValues.put('Name', 'building1');
        mapBuildingFieldValues.put('uuid__c', 'UUID3');
        lstBuildings.add((Building__c)TestingUtility.createTestRecords(Building__c.sObjectType, mapBuildingFieldValues, false));
        TestingUtility.insertListWithAssert(lstBuildings); 
        
        List<Tour_Outcome__c> lstTourOutcomes = new List<Tour_Outcome__c>();
        Map<String, Object> mapTourOutcomeFieldValues = new Map<String, Object>();
        mapTourOutcomeFieldValues.put('Primary_Member__c', lstContacts[0].Id);
        mapTourOutcomeFieldValues.put('Scheduled_By__c', lstContacts[1].Id);
        mapTourOutcomeFieldValues.put('Status__c', 'Inquiry');
        mapTourOutcomeFieldValues.put('Tour_Date__c', system.today().addDays(3));
        mapTourOutcomeFieldValues.put('Tour_Outcome__c', 'Interested');
        mapTourOutcomeFieldValues.put('Move_In_Date__c', system.today().addDays(4));
        mapTourOutcomeFieldValues.put('Interested_Buildings__c', lstBuildings[0].Name+';Test Building');
        mapTourOutcomeFieldValues.put('Unit_Type__c', 'Office;HotDesk');
        mapTourOutcomeFieldValues.put('Office_Capacity__c', '11;12;13;14;15');
        mapTourOutcomeFieldValues.put('Tour_Outcome_Notes__c', 'Test Notes');
        mapTourOutcomeFieldValues.put('Objections__c', 'Too Expensive;Other');
        lstTourOutcomes.add((Tour_Outcome__c)TestingUtility.createTestRecords(Tour_Outcome__c.sObjectType, mapTourOutcomeFieldValues, false));
        TestingUtility.insertListWithAssert(lstTourOutcomes);
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name = 'WeWork System Administrator'];        
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName', 'Last Name');
        userRecordMap.put('Username', TestingUtility.createStringValue()+'username@user.com');
        userRecordMap.put('Email', 'testUser@wework.com');
        User testUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true);   
        
        TourOutcomeFormController.Headers headers = new TourOutcomeFormController.Headers();
        headers.Authorization = 'Token token=dIc0nYcdaPvmFzUq3e0-CQ';
        
        TourOutcomeFormController.ReservableAvailabilityAPI reservAvailApi = new TourOutcomeFormController.ReservableAvailabilityAPI();
        reservAvailApi.headers = headers;
        reservAvailApi.url = 'https://sales-api-staging.wework.com/v2/office_availabilities/search';
        
        TourOutcomeFormController.CreateTourOutcomes tourOutcomes = new TourOutcomeFormController.CreateTourOutcomes();
        tourOutcomes.headers = headers;
        tourOutcomes.url = 'https://sales-api-staging.wework.com/v1/tour_outcomes';
        
        TourOutcomeFormController.NoShow noShow = new TourOutcomeFormController.NoShow();
        noShow.headers = headers;
        noShow.url = 'https://sales-api-staging.wework.com/v1/tours/tour_uuid/no_show';
        
        TourOutcomeFormController.Reasons reasons = new TourOutcomeFormController.Reasons();
        reasons.headers = headers;
        reasons.url = 'https://sales-api-staging.wework.com/v1/reasons';
        
        TourOutcomeFormController.HowHeards howHeards = new TourOutcomeFormController.HowHeards();
        howHeards.headers = headers;
        howHeards.url = 'https://sales-api-staging.wework.com/v2/how_heards';
        
        TourOutcomeFormController.Urgencies urgencies = new TourOutcomeFormController.Urgencies();
        urgencies.headers = headers;
        urgencies.url = 'https://sales-api-staging.wework.com/v2/urgencies';
        
        TourOutcomeFormController.ReservableTourBuildingAvailabilitiesAPI reservTour = new TourOutcomeFormController.ReservableTourBuildingAvailabilitiesAPI();
        reservTour.headers = headers;
        reservTour.url = 'https://sales-api-staging.wework.com/v2/available_tour_times';
        
        TourOutcomeFormController.ReservableRescheduleAPI reservReschedule = new TourOutcomeFormController.ReservableRescheduleAPI();
        reservReschedule.headers = headers;
        reservReschedule.url = 'https://sales-api-staging.wework.com/v1/tours/:id/reschedule';
        
        TourOutcomeFormController.TourOutcomeFormSettings tourOutcomeFormSetting = new TourOutcomeFormController.TourOutcomeFormSettings();
        tourOutcomeFormSetting.RestrictedProfiles = new set<String>{'WeWork NMD Admin', 'WeWork NMD User', 'WeWork NMD User - Beta', 'WeWork NMD User - Outbound'};
        tourOutcomeFormSetting.reservableAvailabilityAPI = reservAvailApi;
        tourOutcomeFormSetting.createTourOutcomes = tourOutcomes;
        tourOutcomeFormSetting.howHeards = howHeards;
        tourOutcomeFormSetting.noShow = noShow;
        tourOutcomeFormSetting.reasons = reasons;
        tourOutcomeFormSetting.reservableRescheduleAPI = reservReschedule;
        tourOutcomeFormSetting.reservableTourBuildingAvailabilitiesAPI = reservTour;
        tourOutcomeFormSetting.urgencies = urgencies;
    }
    
    @isTest 
    static void getFormDataTest(){
        List<Tour_Outcome__c> lstTourOutcomes = [SELECT Id, Name FROM Tour_Outcome__c];
        List<User> lstUsers = [SELECT Id, Name,Email FROM User Where Email = 'testUser@wework.com'];
        List<Contact> lstContacts = [SELECT Id, Name, email, UUID__c FROM Contact];        
        Map<String, Object> parameters = new Map<String, Object>{'IdOrUUID' => lstTourOutcomes[0].Id, 'label' => 'TourDetails'};
        String result = (String)TourOutcomeFormController.getFormData(parameters).data;
        Map<String, Object> formData = (Map<String, Object>)JSON.deserializeUntyped(result);
        
        List<object> tourRecord = (List<object>)formData.get('tourRecord');
        Map<String, Object> tourCompletedBy = (Map<String, Object>)formData.get('tourCompletedBy');
        Map<String, Object> setting = (Map<String, Object>)formData.get('setting');
        Map<String, Object> urgenciesSetting = (Map<String, Object>)setting.get('urgencies');
        TourOutcomeFormController.Urgencies urgencies = new TourOutcomeFormController.Urgencies();
        urgencies.url = 'https://sales-api-staging.wework.com/v2/urgencies';
        System.assertNotEquals(null, formData);
        Map<String, Object> mapResult = (Map<String, object>)tourRecord[0];       
        System.assertEquals(lstTourOutcomes[0].Id, mapResult.get('Id'));
        System.assertEquals(userInfo.getUserId(), formData.get('loggedInUser'));
        System.assertEquals(urgencies.url, urgenciesSetting.get('url'));
        System.assertEquals(lstContacts[0].Id, tourCompletedBy.get('Id'));
        System.runAs(lstUsers[0]){
            string userContextData = (string)TourOutcomeFormController.getFormData(parameters).data;
            Map<String, Object> userContextFormData = (Map<String, Object>)JSON.deserializeUntyped(userContextData);
            Map<String, Object> userContextTourCompletedBy = (Map<String, Object>)userContextFormData.get('tourCompletedBy'); 
            System.assertEquals(lstContacts[1].Id, userContextTourCompletedBy.get('Id'));
        }
        TestingUtility.deleteListWithAssert(lstContacts);
        System.runAs(lstUsers[0]){
            String userContextData = (String)TourOutcomeFormController.getFormData(parameters).data;
            Map<String, Object> userContextFormData = (Map<String, Object>)JSON.deserializeUntyped(userContextData);
            Map<String, Object> userContextTourCompletedBy = (Map<String, Object>)userContextFormData.get('tourCompletedBy');
            System.assertEquals(null, userContextTourCompletedBy.get('Id'));
        }
        try{
            DatabaseResult result1  = TourOutcomeFormController.getFormData(null);
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        } 
    }  
    
    @isTest 
    static void getUserContactInfoTest(){
        List<User> lstUsers = [SELECT Id, Name FROM User Where Email = 'testUser@wework.com'];
        List<Contact> lstContacts = [SELECT Id, Name, email, UUID__c FROM Contact];
        System.runAs(lstUsers[0]){
        String contact = TourOutcomeFormController.getUserContactInfo();
        Map<String, Object> contactMap = (Map<String, Object>)JSON.deserializeUntyped(contact.substringBetween('[', ']'));
        System.assertEquals(lstContacts[1].Id, contactMap.get('Id'));
        }
    }
    
    
}