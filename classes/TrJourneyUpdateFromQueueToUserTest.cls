/************************************************************************************************************************************
    Author      :   Jitesh Adwani	
    Description :   This class will contain all the test method of TrJourneyOutreachStageStatus.
	Issue No    : 	ST-3039
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           12 November 2018    Jitesh             Initial Developement
**************************************************************************************************************************************/
@isTest
public class TrJourneyUpdateFromQueueToUserTest {
	@testSetup
    static void initData(){
        SalesConsoleSettings.createSettings();      
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 2');
        userRecordMap.put('Username','testweworkuser2@example.com');
        userRecordMap.put('Email','testweworkuser2@example.com');
        User testUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true);
        
        TestingUtility.getRecords(new Map<String, Object>{'objName'=>'journey', 'numberOfRecords'=>3});
    }
    
/************************************************************************************************************************************
    Author         : Jitesh Adwani
    Description    : This method is used in TrJourneyUpdateFromQueueToUser.
    Created Date   : 15 Nov 2018 
    Issue No       : ST-3040
**************************************************************************************************************************************/
    public static testMethod void verifyUpdateJourneyFromQueueToUser() {
        List<Journey__c> lstUpdateQueueJourney = new List<Journey__c>();
        List<Journey__c> lstUpdateUserJourney = new List<Journey__c>();
        List<User> lstUser = [SELECT Id FROM User WHERE Email = 'testweworkuser2@example.com']; 
        Group testJourneyGroup = new Group (Name = 'Test Journey Queue', Type = 'Queue');
        insert testJourneyGroup;
        System.runAs(new User(Id = UserInfo.getUserId())){
            QueueSObject testQueue = new QueueSObject(QueueId = testJourneyGroup.Id, SObjectType = 'Journey__c');
            TestingUtility.insertWithAssert(testQueue);
            GroupMember member = new GroupMember(UserOrGroupId = lstUser[0].Id, GroupId = testJourneyGroup.Id);
            TestingUtility.insertWithAssert(member);
        }
        for(Journey__c objJourney : [SELECT Id FROM Journey__c]){
            objJourney.OwnerId = testJourneyGroup.Id;
            lstUpdateQueueJourney.add(objJourney);
        }
        TestingUtility.updateListWithAssert(lstUpdateQueueJourney);
        for(Journey__c objJourney : lstUpdateQueueJourney){
            objJourney.OwnerId = UserInfo.getUserId();
            lstUpdateUserJourney.add(objJourney);
        }
        TestingUtility.updateListWithAssert(lstUpdateUserJourney);
        for(Journey__c objJourney : [SELECT Id, OwnerId, Status__c FROM Journey__c]){
            System.assertEquals(objJourney.OwnerId, UserInfo.getUserId());
            System.assertEquals(objJourney.Status__c, 'Accepted');
        }
    }
}