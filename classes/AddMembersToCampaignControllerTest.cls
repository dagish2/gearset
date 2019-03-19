/**
 Created By:Amol Darekar
 Date:09 Sep 2016
 */
@isTest
private class AddMembersToCampaignControllerTest {
    static List<User> lstUser = new List<User>();
    static List<Building__c> lstBuildings= new List<Building__c>();
    static{
        SalesConsoleSettings.createSettings();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'testU', Email='testUserName1@example.com', 
                           EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = true,
                           TimeZoneSidKey='America/Los_Angeles', UserName='testUserName1@example.com',CommunityNickname = TestingUtility.createUserCommunityName());
        lstUser.add(u1);
        TestingUtility.insertListWithAssert(lstUser);
         //Buildings
        List<Building__c> lstBuilding = new List<Building__c>();
        Building__c Building1 = new Building__C();
        Building1.Name =  'Building15318_1';
        Building1.UUID__c = '15318_1';
        Building1.Email__c = 'Building1@example.com'; 
        lstBuildings.add(Building1); 
        TestingUtility.insertListWithAssert(lstBuildings);
        SalesConsoleSettings.createSplashEventJourney();
    }
    //Created By:Amol Darekar
    //Date:09 Sep 2016
    //ST-647
   
    static testMethod void testAddmembersToCampaign() { 
        
        Contact testContact = new Contact(LastName = 'test', Email = 'test@example.com');
        Test.startTest();
		insert testContact;
		System.assert(contact.Id != null);
		
		Lead testLead = new Lead(FirstName = 'Test',
                          LastName = 'Lead',
                          Company = 'TestCompany',
                          Status = 'Open',
                          Locations_Interested__c = 'B1; B2;',
                          Office_Type__c = 'Shared Desk; DailyDesk;',
                          Email = 'test@example.com');
        insert testLead;
        System.assert(testLead.Id != null);
		
		Journey__c testJourney = new Journey__c();
		testJourney.Name = 'testJourney';
		testJourney.CurrencyIsoCode = 'USD';
		testJourney.Primary_Contact__c = testContact.Id;
		testJourney.Outreach_Stage__c = 'Call 1';
		testJourney.NMD_Next_Contact_Date__c = Date.today();
		testJourney.Lost_Reason__c = 'Not Interested';
		testJourney.Status__c = 'Started';
		TestingUtility.insertWithAssert(testJourney);
        Test.stopTest();
		Journey__c testJourney1 = new Journey__c();
		testJourney1.Name = 'testJourney';
		testJourney1.CurrencyIsoCode = 'USD';
		testJourney1.Primary_Lead__c = testLead.Id;
		testJourney1.Outreach_Stage__c = 'Call 1';
		testJourney1.NMD_Next_Contact_Date__c = Date.today();
		testJourney1.Lost_Reason__c = 'Not Interested';
		testJourney1.Status__c = 'Started';
		TestingUtility.insertWithAssert(testJourney1);
		string journeyIds = testJourney.Id +','+testJourney1.Id;
		
		Campaign objCampaign = new Campaign(
		    Name = 'Test Campaign',
		    Type = 'Event',
		    CurrencyIsoCode = 'USD',
		    isActive = true,
            Region__c = 'Maharashtra'
		);
		insert objCampaign;
        System.assertNotEquals(null, objCampaign.Id);
		list<String> testLstTypes = AddMembersToCampaignController.CampaignTypes();
        system.assertEquals(3,testLstTypes.size());
        
		AddMembersToCampaignController.CampaignInfo(testLstTypes[0]);
		
		Boolean testSuccessFlag = AddMembersToCampaignController.addNewCampaignMembers(objCampaign.Id,journeyIds);
		system.assertEquals(true,testSuccessFlag); 
    }
}