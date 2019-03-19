/************************************************************************************************************************************
    Author 		: 	RamseySolutions	
    Description : 	This class contain test methods for the different CampaignMember triggers.

    History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR				ISSUE 			DETAIL
	1			22 January 2016		RamseySolutions						Initial Developement
	2			23 October 2018		Krishana Tupe		ST-2931			Done Required Changs
	3			23 October 2018		Krishana Tupe		ST-29312		Done Required Changs
***************************************************************************************************************************************/
@isTest
private class CampaignMemberTriggerHandlerTest {  
    static List<Account> lstAccounts = new List<Account>();
    static Lead[] leads = new List<Lead>();
    static List<Contact> lstContacts = new List<Contact>();
    static List<Campaign> lstCampaigns = new List<Campaign>();
    static List<Building__c> lstBuildings= new List<Building__c>();
    static List<User> lstUser = new List<User>();
    static List<CampaignMember> lstCampaignMembersToInsert = new List<CampaignMember>();   
    static List<Building__c> lstBuilding = new List<Building__c>();
    static Id[] leadIds = new List<Id>();
    static Contact contact;
    static CampaignMember[] members = new List<CampaignMember>();
    static List<Lead> lstLeads = new List<Lead>();
    
    static {               
        SalesConsoleSettings.createSettings();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        lstUser.add(new User(Alias = 'testU', Email='testUserName1@example.com', 
                             EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = true,
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUserName1@example.com',CommunityNickname = 'Test User 001'));  
        
        lstUser.add(new User(Alias = 'testU1', Email='testUser1LeadOwner@example.com', 
                             EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = true,
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser1LeadOwner@example.com',CommunityNickname = 'Test User 002'));  
        
        lstUser.add(new User(Alias = 'testU3',Email='testinactiveuser@example.com', 
                             EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = false,
                             TimeZoneSidKey='America/Los_Angeles', UserName='testinactiveuser@example.com',CommunityNickname = 'Test User 003'));        
        TestingUtility.insertListWithAssert(lstUser); 
        
        lstCampaigns.add(new Campaign(Name = 'Test Campaign 1', City__c = 'Chicago', State__c = 'IL',Email_Address__c='Building1@example.com',Type = 'Splash Event', Lead_Owner__c = lstUser[2].Id));
        lstCampaigns.add(new Campaign(Name = 'Test Campaign 2', City__c = 'Chicago', State__c = 'IL', Type = 'Splash Event',Email_Address__c='Building1@example.com', Lead_Owner__c = lstUser[2].Id));        
        lstCampaigns.add( new Campaign(Name = 'Test Campaign 3', State__c = 'DC', City__c = 'Washington DC', Type = 'Splash Event',Email_Address__c='abc3@example.com', Lead_Owner__c = lstUser[1].Id));       
        lstCampaigns.add(new Campaign(Name = 'Test Campaign 4', State__c = 'DC', City__c = 'Chicago', Type = 'Splash Event', Lead_Owner__c = lstUser[2].Id));        
        lstCampaigns.add(new Campaign(Name = 'Test Campaign 5', State__c = 'DC', Type = 'Splash Event',  Lead_Owner__c = lstUser[2].Id));
        TestingUtility.insertListWithAssert(lstCampaigns); 
        
        //Buildings
        lstBuildings.add(new Building__c(Name='Building15318_1', UUID__c = '15318_1', Email__c = 'Building1@example.com'));        
        lstBuildings.add(new Building__c(Name = 'B1',UUID__c='111222333444555',Email__c='abc1@example.com'));
        lstBuildings.add( new Building__c(Name = 'B2',UUID__c='222333444555666',Email__c='abc2@example.com'));
        TestingUtility.insertListWithAssert(lstBuildings);
        
        //Accounts        
        lstAccounts.add(new Account(name = 'Test Account1', UUID__c = 'testAccount1UUID1'));
        TestingUtility.insertListWithAssert(lstAccounts);
        
        //Insert Test Leads 
        lstLeads.add(new Lead(LastName = 'Doe', FirstName = 'John', Email='testcampaign1@example.com', Company = 'WeWork Inc', Locations_Interested__c = lstBuildings[0].Name, Generate_Journey__c = true));
        lstLeads.add(new Lead(LastName = 'Doe', FirstName = 'John', Email='testcampaign2@example.com', Company = 'WeWork Inc', Generate_Journey__c = true));
        lstLeads.add(new Lead(LastName = 'Doe', FirstName = 'John', Email='testcampaign3@example.com', Company = 'WeWork Inc', Locations_Interested__c=lstBuildings[0].Name, Generate_Journey__c = true));
        lstLeads.add(new Lead(LastName = 'Doe',FirstName = 'John', Email='testcampaign4@example.com', Company = 'WeWork Inc', Locations_Interested__c=lstBuildings[1].Name, Generate_Journey__c = true));
        lstLeads.add(new Lead(LastName = 'Doe',FirstName = 'John', Email='testcampaign5@example.com', Company = 'WeWork Inc', Locations_Interested__c=lstBuildings[1].Name, Generate_Journey__c = true));        
        TestingUtility.insertListWithAssert(lstLeads);
        
        lstContacts.add(new Contact(LastName = 'TestContact1', Email = 'testcontact1RestCon@example.com',AccountId = lstAccounts[0].Id));
        lstContacts.add(new Contact(LastName = 'TestContact2', Email = 'testcontact2RestCon@example.com',AccountId = lstAccounts[0].Id));       
        TestingUtility.insertListWithAssert(lstContacts);
        
        List<Journey__c> lstJourneys = new List<Journey__c>();
        lstJourneys.add(new Journey__c(Name = lstLeads[3].LastName, Primary_Lead__c = lstLeads[3].Id, Status__c = 'Started', Primary_Email__c = lstLeads[3].Email, NMD_Next_Contact_Date__c = Date.today()));
        lstJourneys.add(new Journey__c(Name = lstContacts[0].LastName, Primary_Contact__c = lstContacts[0].Id, Status__c = 'Started', Primary_Email__c = lstContacts[0].Email, NMD_Next_Contact_Date__c = Date.today()));       
        TestingUtility.insertListWithAssert(lstJourneys);
        
        SalesConsoleSettings.createUnassignedNMDUSQueueSetting();
        SalesConsoleSettings.createSplashEventJourney();       
        lstCampaignMembersToInsert.add(new CampaignMember(LeadId = lstLeads[0].Id, CampaignId = lstCampaigns[0].Id));
        lstCampaignMembersToInsert.add(new CampaignMember(ContactId = lstContacts[0].Id, CampaignId = lstCampaigns[0].Id));
        TestingUtility.insertListWithAssert(lstCampaignMembersToInsert); 
    }
    
    
 /************************************************************************************************************************************
        Author 				: 	Priyanka Ambre
    	Description			:	
		Created Date		:	
**************************************************************************************************************************************/
    @isTest
    public static void testUpdateLeadFromSplashCampaigns (){ 
        Test.startTest();
        lstCampaigns = [SELECT Id, Name, City__c, State__c, Email_Address__c, Type, Lead_Owner__c, StartDate FROM Campaign WHERE Id IN: lstCampaigns];
        debug.log('lstCampaigns: '+lstCampaigns);
        CampaignMemberStatus cmStatus = new CampaignMemberStatus(CampaignId = lstCampaigns[0].Id, IsDefault = true, HasResponded = true, Label='RSVP_Yes', SortOrder = 3);
        insert cmStatus;
        System.assertNotEquals(null, cmStatus.Id);
        List<CampaignMember> lstCampaignMembers = new List<CampaignMember>();
        lstCampaignMembers.add(new CampaignMember(LeadId = lstLeads[0].Id, CampaignId = lstCampaigns[1].Id));
        lstCampaignMembers.add(new CampaignMember(LeadId = lstLeads[1].Id, CampaignId = lstCampaigns[0].Id, Status = 'RSVP_Yes'));
        lstCampaignMembers.add(new CampaignMember(LeadId = lstLeads[2].Id, CampaignId = lstCampaigns[0].Id, Status = 'RSVP_Yes'));
        lstCampaignMembers.add(new CampaignMember(LeadId = lstLeads[3].Id, CampaignId = lstCampaigns[2].Id));
        TestingUtility.insertListWithAssert(lstCampaignMembers);
        Test.stopTest();
        
        for(Lead leadRec : [SELECT Last_Event_Name__c, Last_Event_Date__c, City, State FROM Lead]){
            debug.log('leadRec in testmethod: '+leadRec);
            debug.log('lstCampaigns in testmethod: '+lstCampaigns);
            if(leadRec.Id == lstLeads[0].Id ){              
                System.assertEquals(lstCampaigns[0].City__c, leadRec.City );
                System.assertEquals(lstCampaigns[0].State__c, leadRec.State );
            }else if(leadRec.Id == lstLeads[1].Id ){
                System.assertEquals(lstCampaigns[0].City__c, leadRec.City );
                System.assertEquals(lstCampaigns[0].State__c, leadRec.State );
                System.assertEquals(lstCampaigns[0].Name, leadRec.Last_Event_Name__c );
                System.assertEquals(lstCampaigns[0].StartDate, leadRec.Last_Event_Date__c );
            }else if(leadRec.Id == lstLeads[2].Id ){
                System.assertEquals(lstCampaigns[0].City__c, leadRec.City );
                System.assertEquals(lstCampaigns[0].State__c, leadRec.State );
                System.assertEquals(lstCampaigns[0].Name, leadRec.Last_Event_Name__c );
                System.assertEquals(lstCampaigns[0].StartDate, leadRec.Last_Event_Date__c );
            }else if(leadRec.Id == lstLeads[3].Id ){
                System.assertEquals(lstCampaigns[2].City__c, leadRec.City );
                System.assertEquals(lstCampaigns[2].State__c, leadRec.State );
            }
        }
    }
    
    @isTest
    public static void testCampaignMemberFromSplashCampaigns(){ 
        Test.startTest();
        lstCampaigns = [SELECT Id, Name, City__c, State__c, Email_Address__c, Type, Lead_Owner__c, StartDate FROM Campaign WHERE Id IN: lstCampaigns];
        CampaignMemberStatus cmStatus = new CampaignMemberStatus(CampaignId = lstCampaigns[0].Id, IsDefault = true, HasResponded = true, Label='RSVP_Yes', SortOrder = 3);
        insert cmStatus;
        System.assertNotEquals(null, cmStatus.Id);
        List<CampaignMember> lstCampaignMembers = new List<CampaignMember>();
        lstCampaignMembers.add(new CampaignMember(LeadId = lstLeads[0].Id, CampaignId = lstCampaigns[1].Id));
        lstCampaignMembers.add(new CampaignMember(LeadId = lstLeads[1].Id, CampaignId = lstCampaigns[0].Id));
        lstCampaignMembers.add(new CampaignMember(LeadId = lstLeads[2].Id, CampaignId = lstCampaigns[0].Id));
        lstCampaignMembers.add(new CampaignMember(LeadId = lstLeads[3].Id, CampaignId = lstCampaigns[2].Id));
        TestingUtility.insertListWithAssert(lstCampaignMembers);        
        lstCampaignMembers[1].Status = 'RSVP_Yes'; 
        lstCampaignMembers[2].Status = 'RSVP_Yes'; 
        TestingUtility.updateListWithAssert(lstCampaignMembers);
        Test.stopTest();        
        for(Lead leadRec : [SELECT Last_Event_Name__c, Last_Event_Date__c, City, State FROM Lead]){
            if(leadRec.Id == lstLeads[0].Id ){              
                System.assertEquals(lstCampaigns[0].City__c, leadRec.City );
                System.assertEquals(lstCampaigns[0].State__c, leadRec.State );
            }else if(leadRec.Id == lstLeads[1].Id ){
                System.assertEquals(lstCampaigns[0].City__c, leadRec.City );
                System.assertEquals(lstCampaigns[0].State__c, leadRec.State );
                System.assertEquals(lstCampaigns[0].Name, leadRec.Last_Event_Name__c );
                System.assertEquals(lstCampaigns[0].StartDate, leadRec.Last_Event_Date__c );
            }else if(leadRec.Id == lstLeads[2].Id ){
                System.assertEquals(lstCampaigns[0].City__c, leadRec.City );
                System.assertEquals(lstCampaigns[0].State__c, leadRec.State );
                System.assertEquals(lstCampaigns[0].Name, leadRec.Last_Event_Name__c );
                System.assertEquals(lstCampaigns[0].StartDate, leadRec.Last_Event_Date__c );
            }else if(leadRec.Id == lstLeads[3].Id ){
                System.assertEquals(lstCampaigns[2].City__c, leadRec.City );
                System.assertEquals(lstCampaigns[2].State__c, leadRec.State );
            }
        }
    }
   
}