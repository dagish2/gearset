/************************************************************************************************************************************
  Author     	: Krishana Tupe
  Description 	: This class is used to test TaskHelper
   
History:
----------------------------------------------------------------------------------------------------------------------------------
  VERSION      	DATE        		AUTHOR          	DETAIL              	ISSUE
	1			6th June 2018   	Krishana Tupe     	Initial Developement    ST-  	
**************************************************************************************************************************************/
@isTest
public class TaskHelperTest {
     public static User apiUser;
     public static Building__c b; 
   	 public static Contact nmdContact;
   
    @TestSetup
    public static void setupData() {
        SalesConsoleSettings.createSettings();
        TestingUtility.getRecords(new Map<String, Object>{'objName'=>'Journey','numberOfRecords'=>'1'});
        
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
        
        nmdContact = new Contact(FirstName='WeWork', LastName='NMD USER',Email='joinus@wework.com');
        insert nmdContact;       
        Setting__c testTourRservableSettings = new Setting__c();
        testTourRservableSettings.Name = 'TourRservableSettings';
        testTourRservableSettings.Data__c = '{"salesleadprofiles": [{"profilename":"System Administrator", "profileid":"00eF0000000Rfpc"}], "bookedbysalesleadlabel":"Booked By Sales Lead", "apiuseremail":"joinus@wework.com", "apiuserid":"005F0000003KmbwIAC", "apiusercontactid":"'+nmdContact.Id+'"}';
        insert testTourRservableSettings;
        
        b = new Building__c(
            City__c = 'Test',
            uuid__c = 'bdf78b97-f8c9-4062-923d-ed32e251d2ad',
            Name = 'Test Building1'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        insert new Tour_Open_Hour__c(
            weekday__c = 'Monday',
            start_time__c = '8:00AM',
            end_time__c = '8:30PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        );        
    } 
   
    public static testMethod void verifyCreateTasksForTour(){
        User apiUser = [SELECT Id FROM User WHERE UserName = 'tourapiuser@example.com'];
        List<Account> lstAccount = new List<Account>([SELECT Id, Name FROM Account]);
        List<Contact> lstContact = new List<Contact>([SELECT Id, FirstName, LastName, UUID__c, Email FROM Contact]);
        System.runAs(apiUser){
            lstAccount[0].OwnerId = apiUser.Id;
            TestingUtility.updateWithAssert(lstAccount[0]);
        }
        lstContact[0].UUID__c = 'contact-uuid';
        lstContact[0].Email = 'testtourcompletedbycontact@example.com';
        TestingUtility.updateWithAssert(lstContact[0]);
        
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
        //confirm response
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);
        
        //confirm created open opportunity        
        List<Tour_Outcome__c> lstTours = [SELECT id, Opportunity__c, tour_completed_by__c, tour_completed_by_UUID__c, tour_completed_by_Name__c, tour_completed_by_SFID__c,
                                          Booked_By_Sales_Lead__c, Hosted_By__c, Assigned_Host__c, OwnerId, booked_by_contact_id__c FROM Tour_Outcome__c WHERE tour_date__c = :tourPayload.tour_date ];
        
        System.assert(lstTours.size() > 0,'A tour for the specified date should be created:' + tourPayload.tour_date);  
        
        User SusuieRomero = [Select Id,Name From User Where Id='005F0000003KmbwIAC'];       
        System.assertEquals(SusuieRomero.Id, lstTours[0].OwnerId);
        System.assertEquals(false, lstTours[0].Booked_By_Sales_Lead__c);
        System.assertEquals(lstTours[0].booked_by_contact_id__c, lstTours[0].Assigned_Host__c);        
        RESTAPITourModelsV2.Response res = (RESTAPITourModelsV2.Response)JSON.deserialize(JSON.serialize(response.result), RESTAPITourModelsV2.Response.class);
        System.assert(response.success != null && response.success && String.valueOf(res.tour_sfid).equals(lstTours[0].Id),'The tour id should be provided as response; ' + lstTours[0].Id);                                      
        System.assert(response.success != null && response.success && String.valueOf(res.contact_sfid).equals(lstContact[0].Id),'The Contact Id which tour should booked should be provided as response; ' + lstContact[0].Id);                                      
        Test.stopTest();
        
        List<Task> lstTasks = [SELECT id, subject FROM Task];       
        System.assert(lstTasks.size() == 0,'A task should not be created:' + lstTasks.size());
    }
    
    public static RESTAPITourModelsV2.Input getTourPayload(){
        String jsonPayload = '{"first_name":"John","last_name":"Smith0706201801","email":"john.smith070@example.com","phone":"8600139164","lead_source":"wework.com","lead_source_detail":"Book A Tour Form","utm_campaign_id":"","utm_campaign":"San Francisco - Modifier","utm_content":"utm contents","utm_medium":"cpc","utm_source":"ads-google","utm_term":"virtual +office +san +francisco","company_name":"John Smith","company_size":"2-5 desks","company_industry":"Education","quick_quote_location":"New York City","notes":"Our Notes for","referral_code":"JetBlue","promo_code":"JetBlue","buildings_interested_uuids":["bdf78b97-f8c9-4062-923d-ed32e251d2ad"],"product_interests":["Office Space"],"product_line":"WeWork","locale":"US","country_code":"US","tour_date":"2018-06-07","tour_time":"08:00AM","tour_uuid":"fdb15bdf-19e2-4abe-bd40-7b7fa9816fb5","tour_building_uuid":"bdf78b97-f8c9-4062-923d-ed32e251d2ad","tour_notes":"Currently at Manhattan, Relocate","contact_uuid":"dsp18593-3239-45cc-b690-5bccc15a27c3","original_tour":"","original_tour_uuid":"","sf_journey_uuid":"","booked_by_contact_id":"0033D00000Ou6FA","tour_completed_by":"","t_and_cs_consent":"False","marketing_consent":"False","affiliates_consent":"False","referral_fail_reason":"No Show","booked_by_sales_lead":true}';
        RESTAPITourModelsV2.Input tourPayload = (RESTAPITourModelsV2.Input)JSON.deserialize(jsonPayload, RESTAPITourModelsV2.Input.class);
        return tourPayload;
    }
    
}