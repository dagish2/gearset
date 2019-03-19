/************************************************************************************************************************************
    Author      :   Jitesh Adwani
    Description :   This class is used to test Restart Journeys for Tours.

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
      1       11 Dec 2018    		Jitesh Adwani          Initial Developement
**************************************************************************************************************************************/
@isTest
public class TrTourRestartJourneyTest { 
	@testSetup
    static void testData(){
        Test.startTest();
        SalesConsoleSettings.createSettings();
        List<Tour_Outcome__c> lstTours = TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Tour', 'numberOfRecords' => 6});
       	System.assertEquals(lstTours.size(), 6);
        
        Profile weworkNMDUserBeta = [SELECT Id FROM Profile WHERE Name = 'WeWork NMD User - Beta'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName', 'Last Name 1');
        userRecordMap.put('Username', 'testweworkuser1@example.com');
        userRecordMap.put('Email', 'testweworkuser1@example.com');
        TestingUtility.insertUserWithAssert(weworkNMDUserBeta.Id, userRecordMap, true); 
        userRecordMap.clear();
        
        Profile weworkCommunityManager = [SELECT Id FROM Profile WHERE Name = 'WeWork Community Manager'];        
        userRecordMap.put('LastName', 'Last Name 2');
        userRecordMap.put('Username', 'testweworkuser2@example.com');
        userRecordMap.put('Email', 'testweworkuser2@example.com');
        TestingUtility.insertUserWithAssert(weworkCommunityManager.Id, userRecordMap, true);        
        
        List<Contact> lstUserRelatedContact = TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Contact', 'numberOfRecords' => 2,'lstEmails'=>new List<String>{'testweworkuser1@example.com','testweworkuser2@example.com'}});        
        //Create a Queue
        Group testGroup = new Group ();
        testGroup.Name = 'Test Contact Queue';
        testGroup.Type = 'Queue';
        TestingUtility.insertWithAssert(testGroup);       
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueueSObject testQueue = new QueueSObject();
            testQueue.QueueId = testGroup.Id;
            testQueue.SObjectType = 'Journey__c';
            TestingUtility.insertWithAssert(testQueue);             
        } 
    }     

    /************************************************************************************************************************************
        Author         : Ashish Mishra
        Description    : This method is used to test Owner of New journey should be assigned to NMD User which is in booked by.
        Created Date   : 21 Dec 2018 
        Issue No       : ST-3352
	**************************************************************************************************************************************/
    private static testMethod void verifyRestartJourneyForTours(){
        List<Building__c> lstBuilding = [SELECT Id, Market__c FROM Building__c WHERE Name LIKE 'testBuilding%'];
        System.assertEquals(lstBuilding.size(), 6);
        
        Group objGroup = [SELECT Id FROM Group WHERE Name ='Test Contact Queue' AND Type = 'Queue' LIMIT 1];
        
        Setting__c restartLocationSetting = Settings.get('RestartLocation');
        if(restartLocationSetting != null){
            restartLocationSetting.Data__c = '{"' + lstBuilding[0].Market__c + '":"' + objGroup.Id +'"}';
            Update restartLocationSetting;
        }
        Integer count = 0;
        Id unassignedNMDUserQueueId = TrTourRestartJourney.getUnassignedNMDUserQueueId();
        List<Tour_Outcome__c> lstTours = new List<Tour_Outcome__c>([SELECT Id, Location__c, Location__r.Name, Status__c, booked_by_contact_id__c FROM Tour_Outcome__c]);        
        System.assertEquals(lstTours.size(), 6);
        System.assertNotEquals(null, lstTours[0].Location__c);
        
        List<Tour_Outcome__c> lstUpdateTours = new List<Tour_Outcome__c>();
        Set<Id> tourIds = new Set<Id>();
        List<Contact> lstConatct = new List<Contact>([SELECT Id, LastName, Email FROM Contact WHERE Email LIKE 'testweworkuser1@example.com' OR Email LIKE 'testweworkuser2@example.com']);
        for(Tour_Outcome__c objTour : lstTours){            
            if(count > 3){                
                objTour.booked_by_contact_id__c = lstConatct[0].Id;
            }else {
                objTour.booked_by_contact_id__c = lstConatct[1].Id;
            }
            count++;            
            Test.setCreatedDate(objTour.Id, Date.newInstance(2018, 12, 7));
            lstUpdateTours.add(objTour);
        }
        
        if(!lstUpdateTours.isEmpty()){
            TestingUtility.updateListWithAssert(lstUpdateTours);   
        }
        lstUpdateTours.clear();
        
        for(Tour_Outcome__c objTour : lstTours){
            objTour.Status__c = 'No Show';
            lstUpdateTours.add(objTour);            
        }
        if(!lstUpdateTours.isEmpty()){
            TestingUtility.updateListWithAssert(lstUpdateTours);   
        }
        Integer counter = 0;
        for(Contact objContact : [SELECT Id, Email, (SELECT Id, Primary_Email__c, OwnerId, CreatedDate, Status__c, Building_Interested_In__c, Locations_Interested__c, NMD_Next_Contact_Date__c, Primary_Contact__c, Stage__c, Restart_Journey_Reason__c, Outreach_Stage__c FROM Journeys__r) FROM Contact WHERE Email LIKE '%Contact@example.com']){
            List<Journey__c>  lstContactRelatedJourneys = objContact.Journeys__r;
            System.assertEquals(2, lstContactRelatedJourneys.size());
            System.assertEquals(LeadTriggerHandlerTest.getBuisnessDate(lstContactRelatedJourneys[0]), lstContactRelatedJourneys[0].NMD_Next_Contact_Date__c, 'NMD_Next_Contact_Date__c NOT changed');
            System.assertEquals(lstContactRelatedJourneys[0].Status__c, 'Trying to Reach');
            System.assertEquals(lstContactRelatedJourneys[0].Building_Interested_In__c, lstTours[counter].Location__c);
            System.assert(String.valueOf(lstContactRelatedJourneys[0].Locations_Interested__c).contains(Settings.getBuildingById(lstTours[counter].Location__c).Name));
            for(Journey__c objJourney :lstContactRelatedJourneys) {
                if(String.valueOf(objJourney.OwnerId).startsWith('00G')) {
                    System.assertEquals(objGroup.Id, String.valueOf(objJourney.OwnerId).substring(0,15), 'Owner is not assigned properly');
                }
            }
            counter++;
        }
    }
}