/*****************************************************************************************************************************
  Yet to do
  1. Modularize the code into multiple method calls.
  2. Put comments for each method call to establish references.
  3. Get it reviewed from the peer team.
******************************************************************************************************************************
    Author      :  Krishana Tupe  
    Description :  This class contains the test methods of LeadRoutingHelper class.
					It will covers the LeadConverterHelper.manageLead(lstLeads, payload) methods and JourneyHelperUtility class.
    History     :  --
      
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION                 DATE            ISSUE       AUTHOR                          DETAIL
    1                       26 Nov 2018      -     		Krishana Tupe                   Initial Developement    
******************************************************************************************************************************/
@isTest
public class LeadRoutingHelperTest {
    

    public static string strHoldBackQueueId;
    static {
        if(String.isBlank(strHoldBackQueueId)){
            MetadataSetting__mdt objJourneyCreationMDT = Settings.getMetadataSettingByDevName('Hold_Back_Queue');  
            strHoldBackQueueId = String.isNotBlank(objJourneyCreationMDT.Data__c) ? objJourneyCreationMDT.Data__c : null;      
        }        
    }
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is to get user record								
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    public static User getUser(String strEmail, String strUserName, String profileId){
        return new User(Alias = 'testU', Email = strEmail, EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = profileId, IsActive = true,
                        TimeZoneSidKey='America/Los_Angeles', UserName = strUserName, CommunityNickname = TestingUtility.createUserCommunityName());
    }
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This setup method is used to create test data for LeadRoutingHelperTest class								
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    @TestSetup
    public static void testSetup(){
        SalesConsoleSettings.createSettings(); 
        List<User> lstUser = new List<User>();
        Profile weworkSysAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];        
        lstUser.add(getUser('testinguser1@example.com', 'testinguser1@example.com', weworkSysAdmin.Id));
        lstUser.add(getUser('testinguser2@example.com', 'testinguser2@example.com', weworkSysAdmin.Id));
        Database.insert(lstUser);
        
        List<Campaign> lstCampaigns = new List<Campaign>();
        lstCampaigns.add(new Campaign(Name = 'Test Campaign 1', City__c = 'Chicago', State__c = 'IL', Email_Address__c = 'Building1@example.com', Type = 'Splash Event'));
        lstCampaigns.add(new Campaign(Name = 'Test Campaign 2', State__c = 'DC', City__c = 'Washington DC', Type = 'Splash Event', Email_Address__c='abc3@example.com', Lead_Owner__c =lstUser[0].Id));
        Database.insert(lstCampaigns);
    }
    
 /************************************************************************************************************************************
    Author              :   Krishana Tupe
    Description         :   This method is used to verify insert lead and Journey for Hold back flow
    Created Date  		:   26 Nov 2018   
 *************************************************************************************************************************************/
    @isTest
    public static void verifyManualLeadInsertion(){
        List<Lead> lstLeads = new List<Lead>(); 
        LeadRoutingHelperTest.getLeadRecords(lstLeads, 1, 6, null, null);
        Test.startTest();
        TestingUtility.insertListWithAssert(lstLeads); 
        Test.stopTest();
        List<Lead> lstLeadsInserted = [SELECT Id, Name, OwnerId, Lead_Assignment_Stage__c, (SELECT Id,OwnerId FROM Journeys__r) FROM Lead WHERE Id IN : lstLeads AND IsConverted = false];
        System.assertEquals(6, lstLeadsInserted.size()); 
        verifyAssertions(lstLeadsInserted, 1, UserInfo.getUserId(), '1');
    }
    
        
/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies bypass Lead insertion hold back logic 								
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    @isTest
    public static void verifyBypassHoldBackLeadInsertion(){
        List<Lead> lstLeads = new List<Lead>(); 
        LeadRoutingHelperTest.getLeadRecords(lstLeads, 1, 6, null, '1000');        
        Test.startTest();
        TestingUtility.insertListWithAssert(lstLeads); 
        Test.stopTest();
        List<Lead> lstLeadsInserted = [SELECT Id, Name, OwnerId, Lead_Assignment_Stage__c, (SELECT Id,OwnerId FROM Journeys__r) FROM Lead WHERE Id IN : lstLeads AND IsConverted = false];
        System.assertEquals(6, lstLeadsInserted.size()); 
        verifyAssertions(lstLeadsInserted, 1, UserInfo.getUserId(), '1000');
    }
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies common assertions							
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    public static void verifyAssertions(List<Lead> lstLeadsInserted, Integer journeySize, String leadOwnerId, String assgnStage){
        for(Lead objLead : lstLeadsInserted){
            System.assert(objLead.Journeys__r.size() == journeySize);
            System.assertEquals(objLead.OwnerId, leadOwnerId);
            if(journeySize != 0){
                System.assertEquals(objLead.OwnerId, objLead.Journeys__r[0].OwnerId);
            }           
            System.assertEquals(objLead.Lead_Assignment_Stage__c, assgnStage);
        }   
    }
   
  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies Lead/journey hold back logic when lead comes from Website 								
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    @isTest
    public static void verifyLeadInsertionHoldBack(){
        List<Lead> lstLeads = new List<Lead>(); 
        LeadRoutingHelperTest.getLeadRecords(lstLeads, 1, 6, null, null);
        RESTInboundLeadAPIHelper.isLeadFromWeb = true;
        Test.startTest();
        TestingUtility.insertListWithAssert(lstLeads); 
        Test.stopTest();
        List<Lead> lstLeadsInserted = [SELECT Id, Name, OwnerId, Lead_Assignment_Stage__c, (SELECT Id, OwnerId FROM Journeys__r) FROM Lead WHERE Id IN : lstLeads AND IsConverted = false];
        System.assertEquals(6, lstLeadsInserted.size()); 
        verifyAssertions(lstLeadsInserted, 1, Id.valueOf(strHoldBackQueueId), '6');
    }
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies Lead/journey hold back logic when lead comes from Website  with campaign								
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    @isTest
    public static void verifyLeadInsertionWithCampaign(){
        List<Lead> lstLeads = new List<Lead>(); 
        List<Campaign> lstCampaigns = [SELECT Id, Lead_Owner__c, By_Pass_Campaign_Assignment__c FROM Campaign];      
        LeadRoutingHelperTest.getLeadRecords(lstLeads, 1, 3, lstCampaigns[0].Id, null);
        LeadRoutingHelperTest.getLeadRecords(lstLeads, 4, 6, lstCampaigns[1].Id, null);
        RESTInboundLeadAPIHelper.isLeadFromWeb = true;
        Test.startTest();
        TestingUtility.insertListWithAssert(lstLeads); 
        Test.stopTest();
        List<Lead> lstLeadsInserted = [SELECT Id, Name, OwnerId, Campaign_Id__c, Lead_Assignment_Stage__c, Lead_Source_Detail__c, (SELECT Id, OwnerId FROM Journeys__r) FROM Lead WHERE Id IN : lstLeads AND IsConverted = false];
        System.assertEquals(6, lstLeadsInserted.size()); 
        for(Lead objLead : lstLeadsInserted){
            System.assert(objLead.Journeys__r.size() == 1);
            System.assertEquals(objLead.Lead_Assignment_Stage__c, '1');
            System.assertNotEquals(objLead.OwnerId, Id.valueOf(strHoldBackQueueId));   
            System.assertNotEquals(objLead.OwnerId, UserInfo.getUserId());  
            System.assertEquals(objLead.OwnerId, objLead.Journeys__r[0].OwnerId);
            if(objLead.Lead_Source_Detail__c == 'TEST LEAD SOURCE 4'){
                System.assertEquals(objLead.OwnerId, objLead.Journeys__r[0].OwnerId);  
                System.assertEquals(objLead.OwnerId, objLead.Journeys__r[0].OwnerId); 
                System.assertEquals(objLead.Campaign_Id__c, lstCampaigns[1].Id); 
                System.assertEquals(objLead.OwnerId, lstCampaigns[1].Lead_Owner__c); 
            }else{
                System.assertEquals(objLead.Campaign_Id__c, lstCampaigns[0].Id);      
            }
        }
    }
   
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies Lead/journey hold back logic when duplicate lead comes from Website  without campaign								
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    @isTest
    public static void verifyDuplicateLeadInsertionWithoutCampaign(){
        List<Lead> lstLeads = new List<Lead>();
        LeadRoutingHelperTest.getLeadRecords(lstLeads, 1, 3, null, null);
        RESTInboundLeadAPIHelper.isLeadFromWeb = true;       
        TestingUtility.insertListWithAssert(lstLeads);
        List<Lead> lstLeadsInserted = [SELECT Id, Name, OwnerId, Campaign_Id__c, Lead_Assignment_Stage__c, Lead_Source_Detail__c, (SELECT Id, OwnerId FROM Journeys__r) FROM Lead WHERE Id IN : lstLeads AND IsConverted = false];
        System.assertEquals(3, lstLeadsInserted.size()); 
        lstLeads.clear();        
        LeadRoutingHelperTest.getLeadRecords(lstLeads, 1, 3, null, null);
        Test.startTest();
        Database.insert(lstLeads);
        Test.stopTest();        
        List<Lead> lstDuplicateLeadsInserted = [SELECT Id, Name, OwnerId, Lead_Assignment_Stage__c, (SELECT Id, OwnerId FROM Journeys__r) FROM Lead WHERE IsConverted = false];
        System.assertEquals(6, lstDuplicateLeadsInserted.size()); 
        for(Integer iIndex = 0; iIndex < lstDuplicateLeadsInserted.size(); iIndex++){
            Lead objLead = lstDuplicateLeadsInserted[iIndex];
            System.assertEquals(objLead.OwnerId, Id.valueOf(strHoldBackQueueId));            
            System.assertEquals(objLead.Lead_Assignment_Stage__c, '6');
            if(iIndex <= 2){
                System.assertEquals(objLead.Journeys__r[0].OwnerId, Id.valueOf(strHoldBackQueueId));
                System.assert(objLead.Journeys__r.size() == 1);
            }else{
                System.assert(objLead.Journeys__r.size() == 0);
            } 
        }
    }
    
/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies Lead/journey hold back logic when lead comes from Website and contact exist								
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    @isTest
    public static void verifyHoldBackForExistingContact(){
        Map<String, sObject> mapLeadContactData = getExistingContactData(true, null);
        Lead objLead = (Lead)mapLeadContactData.get('lead');
        Contact objContact = (Contact)mapLeadContactData.get('contact');
        List<Lead> lstDuplicateLeadsInserted = [SELECT Id, Name, OwnerId, Lead_Assignment_Stage__c, (SELECT Id, OwnerId FROM Journeys__r) FROM Lead WHERE Id =: objLead.Id AND IsConverted = false];
        System.assertEquals(1, lstDuplicateLeadsInserted.size()); 
        verifyAssertions(lstDuplicateLeadsInserted, 0, Id.valueOf(strHoldBackQueueId), '6');
        Contact objContactInserted = [SELECT Id, Name, OwnerId, (SELECT Id, OwnerId FROM Journeys__r) FROM Contact WHERE Id =: objContact.Id];
        System.assertEquals(objContactInserted.OwnerId, UserInfo.getUserId());
        System.assertEquals(1, objContactInserted.Journeys__r.size());
    }
   
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method inserts the contact and Lead in the system								
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    public static Map<String, sObject> getExistingContactData(Boolean isFromWeb, string campaignId){
        Account objAccount = new Account(name = 'Test Account1 org', UUID__c = 'testAccount1UUID1');
        TestingUtility.insertWithAssert(objAccount);
        Contact objContact = new Contact(AccountId = objAccount.Id, LastName = 'Test Contact 1', Email = 'johndoe1582018_1@example.com');
        TestingUtility.insertWithAssert(objContact);
        Lead objLead = new Lead(LeadSource='WeWork.com', Lead_Source_Detail__c='TEST LEAD SOURCE', LastName = 'Doe', FirstName = 'John', Email = 'johndoe1582018_1@example.com', Office_Type__c = 'Daily Desk', Status = 'Open', Locations_Interested__c = 'Test Building Tour', Company = 'Enzigma ltd', Generate_Journey__c = true, Number_of_Full_Time_Employees__c = 15);        
        if(String.isNotBlank(campaignId)){
            objLead.Campaign_Id__c =  campaignId; 
        }
        if(isFromWeb){
            RESTInboundLeadAPIHelper.isLeadFromWeb = true;   
        }
        Test.startTest();
        TestingUtility.insertWithAssert(objLead);
        Test.stopTest(); 
        return new Map<String, sObject>{'lead' => objLead, 'contact' => objContact};
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies by pass Lead/journey hold back logic when lead created manually and contact exist								
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    @isTest
    public static void verifyBypassHoldBackForExistingContact(){
        Map<String, sObject> mapLeadContactData = getExistingContactData(false, null);
        Lead objLead = (Lead)mapLeadContactData.get('lead');
        Contact objContact = (Contact)mapLeadContactData.get('contact');
        List<Lead> lstDuplicateLeadsInserted = [SELECT Id, Name, OwnerId, Lead_Assignment_Stage__c, (SELECT Id, OwnerId FROM Journeys__r) FROM Lead WHERE Id =: objLead.Id AND IsConverted = true];
        System.assertEquals(1, lstDuplicateLeadsInserted.size());      
        Contact objContactInserted = [SELECT Id, Name, OwnerId, (SELECT Id, OwnerId FROM Journeys__r) FROM Contact WHERE Id =: objContact.Id];
        System.assertEquals(objContactInserted.OwnerId, UserInfo.getUserId());
        System.assertEquals(1, objContactInserted.Journeys__r.size());
        System.assertEquals(objContactInserted.Journeys__r[0].OwnerId, UserInfo.getUserId());
    }
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verifies Lead/journey hold back logic when lead comes from Website with campaign and contact exist								
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    @isTest
    public static void verifyLeadExistingContactWithCampaign(){
        List<Campaign> lstCampaigns = [SELECT Id, Lead_Owner__c, By_Pass_Campaign_Assignment__c FROM Campaign];       
        Map<String, sObject> mapLeadContactData = getExistingContactData(true, lstCampaigns[1].Id);     
        Lead objLead = (Lead)mapLeadContactData.get('lead');
        Contact objContact = (Contact)mapLeadContactData.get('contact');
        List<Lead> lstDuplicateLeadsInserted = [SELECT Id, Name, OwnerId, Lead_Assignment_Stage__c, (SELECT Id, OwnerId FROM Journeys__r) FROM Lead WHERE Id =: objLead.Id AND IsConverted = true];
        System.assertEquals(1, lstDuplicateLeadsInserted.size()); 
        verifyAssertions(lstDuplicateLeadsInserted, 0, lstCampaigns[1].Lead_Owner__c, 'Lead Converted');
        Contact objContactInserted = [SELECT Id, Name, OwnerId, (SELECT Id, OwnerId FROM Journeys__r) FROM Contact WHERE Id =: objContact.Id];
        System.assertEquals(objContactInserted.OwnerId, UserInfo.getUserId());
        System.assertEquals(1, objContactInserted.Journeys__r.size());
        System.assertEquals(lstCampaigns[1].Lead_Owner__c, objContactInserted.Journeys__r[0].OwnerId);        
    }
    
/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to create the lead records data 
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    public static void getLeadRecords(List<Lead> lstLeads, Integer initialValue, Integer finalValue, String strCampaignId, String assignStage){      
        for(Integer iIndex = initialValue; iIndex <= finalValue; iIndex++){ 
            Lead objLead = new Lead(LeadSource='WeWork.com', Lead_Source_Detail__c='TEST LEAD SOURCE '+initialValue, LastName = 'Doe'+iIndex, FirstName = 'John', Email = 'johndoe1582018_'+iIndex+'@example.com', Office_Type__c = 'Daily Desk', Status = 'Open', Locations_Interested__c = 'Test Building Tour', Company = 'Enzigma ltd', Generate_Journey__c = true, Number_of_Full_Time_Employees__c = 15);
            if(String.isNotBlank(strCampaignId)){
                objLead.Campaign_Id__c = strCampaignId; 
            }
            if(String.isNotBlank(assignStage)){
                objLead.Lead_Assignment_Stage__c = assignStage; 
            }
            lstLeads.add(objLead); 
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to verify delete leads
      	Created Date  		:   5 Dec 2018        
    *************************************************************************************************************************************/
    @isTest
    public static void verifyDeleteLeads(){
        List<Lead> lstLeads = new List<Lead>();
        Lead objLead = new Lead(LeadSource='WeWork.com', Lead_Source_Detail__c='TEST LEAD SOURCE ', LastName = 'Doe', FirstName = 'John', Email = 'johndoe2018@example.com', Office_Type__c = 'Daily Desk', Status = 'Open', Locations_Interested__c = 'Test Building Tour', Company = 'Enzigma ltd', Generate_Journey__c = true, Number_of_Full_Time_Employees__c = 15);
        lstLeads.add(objLead);
        Lead objLead1 = new Lead(LeadSource='WeWork.com', Lead_Source_Detail__c='TEST LEAD SOURCE ', LastName = 'Doe2', FirstName = 'John', Email = 'johndoe2018@example.com', Office_Type__c = 'Daily Desk', Status = 'Open', Locations_Interested__c = 'Test Building Tour', Company = 'Enzigma ltd', Generate_Journey__c = true, Number_of_Full_Time_Employees__c = 5);
        lstLeads.add(objLead1);       
        Test.startTest();
        TestingUtility.insertListWithAssert(lstLeads); 
        Test.stopTest();      
        List<Lead> lstLeadsInserted = [SELECT Id, Name, Email, OwnerId, Lead_Assignment_Stage__c, IsConverted, Number_of_Full_Time_Employees__c FROM Lead WHERE Id IN : lstLeads];
        System.assertEquals(1, lstLeadsInserted.size());
        System.assertEquals(UserInfo.getUserId(), lstLeadsInserted[0].OwnerId);
    }
    
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to verify delete leads
      	Created Date  		:   5 Dec 2018        
    *************************************************************************************************************************************/
    @isTest
    public static void verifyDeleteLeadsWithoutJourney(){        
        List<Lead> lstLeads = new List<Lead>();
        List<Map<String, sObject>> lstJourneyParents = new List<Map<String, sObject>>();
        List<Id> lstLeadsToDelete = new List<Id>();
        List<CampaignMember> lstCampaignMembers = new List<CampaignMember>();
        Lead objLead = new Lead(LeadSource='WeWork.com', Lead_Source_Detail__c='TEST LEAD SOURCE ', LastName = 'Tie', FirstName = 'John', Email = 'johntie2018@example.com', Office_Type__c = 'Daily Desk', Status = 'Open', Locations_Interested__c = 'Test Building Tour', Company = 'Enzigma ltd', Generate_Journey__c = false, Number_of_Full_Time_Employees__c = 15);
        lstLeads.add(objLead);
        Lead objLead1 = new Lead(LeadSource='WeWork.com', Lead_Source_Detail__c='TEST LEAD SOURCE ', LastName = 'Tie2', FirstName = 'John', Email = 'johntie2018@example.com', Office_Type__c = 'Daily Desk', Status = 'Open', Locations_Interested__c = 'Test Building Tour', Company = 'Enzigma ltd', Generate_Journey__c = false, Number_of_Full_Time_Employees__c = 5);
        lstLeads.add(objLead1);       
        TestingUtility.insertListWithAssert(lstLeads); 
        List<Lead> lstLeadsInserted = [SELECT Id, Name, Email, OwnerId, Lead_Assignment_Stage__c, IsConverted, Number_of_Full_Time_Employees__c, Generate_Journey__c, Campaign_Id__c, (SELECT Id, OwnerId FROM Journeys__r) FROM Lead WHERE Id IN : lstLeads];
        for(Lead deleteLead : lstLeadsInserted){
            lstLeadsToDelete.add(deleteLead.Id);
        }
        LeadRoutingHelper.manageLeadRelatedRecords(true, lstJourneyParents, lstLeadsToDelete, lstCampaignMembers, null);       
        lstLeadsInserted = [SELECT Id, Name, Email, OwnerId, Lead_Assignment_Stage__c, IsConverted, Number_of_Full_Time_Employees__c, Generate_Journey__c, Campaign_Id__c, (SELECT Id, OwnerId FROM Journeys__r) FROM Lead WHERE Id IN : lstLeads];
        System.assertEquals(1, lstLeadsInserted.size());       
        System.assertEquals(0, lstLeadsInserted[0].Journeys__r.size());
    }
}