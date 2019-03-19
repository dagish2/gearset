/*********************************************************************************************
Name   : KickboxVerificationControllerTest
Purpose: This class cover test senarios for KickboxVerificationController and KickboxProcessLeadsbatch
History:
         VERSION      DATE      	AUTHOR                 DETAIL
          1.0      21 Dec 2016   Mayuresh Ghodke	 Initial Developement.
		  2.0          _     	 Shobhit Ghalot	 	 
		  3.0	   11 Jan 2018	 Amol Darekar		
		Code is commented by Rupesh Patil as this class is depricated
*********************************************************************************************/
@isTest 
public class KickboxVerificationControllerTest {    
  /*  public static Id userId;
    public static Id buildingId;
    public static Id ContactIdValid;
    public static Id ContactIdInvalid;
    public static Id LeadIdValid;
    public static Id LeadIdInvalid;

    static{
         SalesConsoleSettings.createSettings();  
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        debug.Log('weworkSystemAdmin' + weworkSystemAdmin);
        List<User> lstusers = new List<User>();
        List<Building__c> lstbuildings = new List<Building__c>();
        User user1 = new User();
        user1.LastName = 'Last Name 1';
        user1.Username = 'testwework1_10@example.com';
        user1.Email = 'testwework1_10@example.com';
        user1.ProfileId = weworkSystemAdmin.Id;
        user1.EmailEncodingKey = 'ISO-8859-1';
        user1.LanguageLocaleKey = 'en_US';
        user1.LocaleSidKey = 'en_US';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.Alias = 'Name 1';
        user1.IsActive = true;
        lstusers.add(user1);
        insert lstusers;
        userId=lstusers[0].Id;
        Building__c b1 = new Building__c(Name = 'LA-Gas Tower');
        lstbuildings.add(b1);
        insert lstbuildings;
        buildingId = lstbuildings[0].Id;
    }

    private static testMethod void testSaveCampaignMember() {
        Set<Id> setLeadIds = new Set<Id>();
        Set<Id> setConIds = new Set<Id>();
        //New lead with out CampaignMember
        Lead lead1 = new Lead(FirstName = 'Test1', LastName = 'Test1', Company = 'Test', Email = 'testleadsaveCampaignMember1@example.com', Check_Duplicates__c = true);
        insert lead1;
        //New lead with CampaignMember
        Lead lead2 = new Lead(FirstName = 'Test1', LastName = 'Test1', Company = 'Test', Email = 'testleadsaveCampaignMember2@example.com', Check_Duplicates__c = true);
        insert lead2;
        setLeadIds.add(lead1.id);
        setLeadIds.add(lead2.id);
        //New Contact with CampaignMember
        Contact testContact1 = new Contact(LastName = 'test', Email = 'testsaveCampaignMember1@example.com');
		insert testContact1;
        //New Contact with out CampaignMember
        Contact testContact2 = new Contact(LastName = 'test', Email = 'testsaveCampaignMember2@example.com');
		insert testContact2;
        
        setConIds.add(testContact1.id);
        setConIds.add(testContact2.id);
        
        Campaign ca = new Campaign(Name = 'Test Campaign', Type = 'Event', CurrencyIsoCode = 'USD', isActive = true );
		insert ca;
        Test.startTest();
        List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
        CampaignMember campMem1 = new CampaignMember (campaignid=ca.Id, contactid=testContact2.id);
        CampaignMember campMem2 = new CampaignMember (campaignid=ca.Id, leadid=lead2.id);
        lstCampaignMember.add(campMem1);
        lstCampaignMember.add(campMem2);
        insert lstCampaignMember;
        
        Journey__c testJourney1 = new Journey__c();
            testJourney1.Name = 'testJourneyName1';
            testJourney1.CurrencyIsoCode = 'USD';
            testJourney1.Primary_Lead__c = lead1.Id;
            testJourney1.NMD_Next_Contact_Date__c = Date.today();
		insert testJourney1;
        
        Journey__c testJourney2 = new Journey__c();
            testJourney2.Name = 'testJourneyName2';
            testJourney2.CurrencyIsoCode = 'USD';
            testJourney2.Primary_Contact__c = testContact1.Id;
            testJourney2.NMD_Next_Contact_Date__c = Date.today();
        insert testJourney2;
        
        Journey__c testJourney3 = new Journey__c();
            testJourney3.Name = 'testJourneyName1';
            testJourney3.CurrencyIsoCode = 'USD';
            testJourney3.Primary_Lead__c = lead2.Id;
            testJourney3.NMD_Next_Contact_Date__c = Date.today();
		insert testJourney3;
        
        Journey__c testJourney4 = new Journey__c();
            testJourney4.Name = 'testJourneyName2';
            testJourney4.CurrencyIsoCode = 'USD';
            testJourney4.Primary_Contact__c = testContact2.Id;
            testJourney4.NMD_Next_Contact_Date__c = Date.today();
        insert testJourney4;
        
        List<Id> lstJourneyIds = new List<Id>();
        lstJourneyIds.add(testJourney2.Id);
        lstJourneyIds.add(testJourney1.Id);
        lstJourneyIds.add(testJourney3.Id);
        lstJourneyIds.add(testJourney4.Id);
        
        KickboxVerificationController.saveCampaignMember(lstJourneyIds,ca.Id);
        Test.stopTest();        
        List<CampaignMember> lstCampaignMemberLead = [Select Id From CampaignMember Where contactid IN : setConIds AND campaignid =: ca.Id ];
        List<CampaignMember> lstCampaignMemberCon = [Select Id From CampaignMember Where leadid IN : setLeadIds AND campaignid =: ca.Id ];
        //Should create new CampaignMember and exist then should not create duplicate.
        system.assertEquals(lstCampaignMemberLead.size(), 2);
        system.assertEquals(lstCampaignMemberCon.size(), 2);      
    }
    
    /*Purpose: This will verify Process leads in KickboxVerificationApiHandler's process leads method and kickboxVerification method of KickboxVerificationController*/
  /*  public static testMethod void verifykickboxVerification(){
        Lead lead = new Lead();
        lead.FirstName = 'John';
        lead.LastName = 'Smith';
        lead.Email = 'john.smith_001@example.com';
        lead.Phone = '98908877646464';
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = true;
        lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        //lead.Number_of_Desks__c = '1';
        insert lead;
        system.assertNotEquals(null, lead.Id);
        string csv1 = '"First Name","Last Name","EMAIL","Company","Locations Interested","Lead Source","Lead Source Detail","Generate Journey","Status","Phone"\n'+'"Wework","Kickbox1","Test3107_1@enzigma.com","","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","1234567890"\n'+'"Wework","Kickbox1","Test3107_2@enzigma.com","Enzigma","LA-Gas Tower","","Book A Tour Form","true","Open","1234567891"\n'+'"Wework","Kickbox1","Test3107_3@enzigma.com","Enzigma","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","1234567891"\n'+'"Wework","Kickbox1","Test3107_4@enzigma.com","Enzigma","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","1234567891"\n';
        string csv2 = '"First Name","Last Name","EMAIL","Company","Phone","Locations Interested","Lead Source","Lead Source Detail","Generate Journey","Status","Number of Desks 2016","Last Engage Email Sent","CallRail Answered","Event Date Needed","Lead Owner","Building Interested In"\n'+'"Wework","Kickbox2","Test1@enzigma.com","Enzigma","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","6","10/14/2011 11:46 AM","true","hjghfj","'+userId+'","'+buildingId+'"\n'+'"Wework","Kickbox3","Test2@enzigma.com","Enzigma","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","6","lhhl","true","12/27/2009","'+userId+'","'+buildingId+'"\n'+'"Wework","Kickbox5","Test3@enzigma.com","","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","6","10/14/2011 11:46 AM","true","12/27/2009","'+userId+'","'+buildingId+'"\n'+'"Wework","Kickbox6","Test4@enzigma.com","Enzigma","5658565555","LA-Gas Tower","","Book A Tour Form","true","Open","6","10/14/2011 11:46 AM","true","12/27/2009","'+userId+'","'+buildingId+'"\n'+'"Wework","Kickbox1","Test5@enzigma.com","Enzigma","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","6","10/14/2011 11:46 AM","true","12/27/2009","'+userId+'","a00F000000qknzd"';
        string generateJourney = 'true';
        Kickbox_Verification__c objKickboxVerification = new Kickbox_Verification__c();
        objKickboxVerification.Create_From_Journey_Importer__c = true;
        objKickboxVerification.Generate_Journey__c = Boolean.valueOf(generateJourney);     
        insert objKickboxVerification;
        //KickboxVerificationApiHandler.processLeads(csv1, generateJourney, objKickboxVerification.Id);
        //KickboxVerificationApiHandler.processLeads(csv2, generateJourney, objKickboxVerification.Id);
        //string csvFile, String generateJourney, Attachment objAttachment, Id campaingeId
        Attachment att1 = new Attachment();
        att1.IsPrivate = false;
        Attachment att2 = new Attachment();
        att2.IsPrivate = false;
        
        Test.startTest();
        KickboxVerificationController.kickboxVerification(csv1, generateJourney, att1, null,null,'2');
        //KickboxVerificationController.kickboxVerification(csv2, generateJourney, att2, null,objKickboxVerification.Id, '1');
        KickboxVerificationController.kickboxVerification(csv2, generateJourney, att2, null,null, '1');
        Test.stopTest();
        
        Set<String> setEmails = new set<String>();
        setEmails.add('Test3107_1@enzigma.com');// Company Name missing
        setEmails.add('Test3107_2@enzigma.com');// Lead Source missing
        setEmails.add('Test3107_3@enzigma.com');// All correct
        setEmails.add('Test3107_4@enzigma.com');// All correct
		setEmails.add('Test1@enzigma.com');//Date incorrect        
        setEmails.add('Test2@enzigma.com');//Date Time incorrect
        setEmails.add('Test3@enzigma.com');
        setEmails.add('Test4@example.com');
        setEmails.add('Test5@enzigma.com');
        
        List<Lead> lstLeads = [SELECT Id, Name, Email FROM Lead WHERE Email In : setEmails];
        debug.log('lstLeads in verifykickboxVerification :: '+lstLeads);
        system.assertEquals(2, lstLeads.size());
    }
    
    /*Purpose:This method check the kickbox csv upload functionality and lead insertion and validation*/
   /* public static testMethod void verifykickboxVerificationSendMail(){
        string csv1 = '"First Name","Last Name","EMAIL","Company","Locations Interested","Lead Source","Lead Source Detail","Generate Journey","Status","Phone"\n'+'"Wework","Kickbox1","Test3107_1@enzigma.com","","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","1234567890"\n'+'"Wework","Kickbox1","Test3107_2@enzigma.com","Enzigma","LA-Gas Tower","","Book A Tour Form","true","Open","1234567891"\n'+'"Wework","Kickbox1","Test3107_3@enzigma.com","Enzigma","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","1234567891"\n'+'"Wework","Kickbox1","Test3107_4@enzigma.com","Enzigma","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","1234567891"\n';
        string csv2 = '"First Name","Last Name","EMAIL","Company","Phone","Locations Interested","Lead Source","Lead Source Detail","Generate Journey","Status","Number of Desks 2016","Last Engage Email Sent","CallRail Answered","Event Date Needed","Lead Owner","Building Interested In"\n'+'"Wework","Kickbox2","Test1@enzigma.com","Enzigma","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","6","10/14/2011 11:46 AM","true","hjghfj","'+userId+'","'+buildingId+'"\n'+'"Wework","Kickbox3","Test2@enzigma.com","Enzigma","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","6","lhhl","true","12/27/2009","'+userId+'","'+buildingId+'"\n'+'"Wework","Kickbox5","Test3@enzigma.com","","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","6","10/14/2011 11:46 AM","true","12/27/2009","'+userId+'","'+buildingId+'"\n'+'"Wework","Kickbox6","Test4@enzigma.com","Enzigma","5658565555","LA-Gas Tower","","Book A Tour Form","true","Open","6","10/14/2011 11:46 AM","true","12/27/2009","'+userId+'","'+buildingId+'"\n'+'"Wework","Kickbox1","Test5@enzigma.com","Enzigma","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","6","10/14/2011 11:46 AM","true","12/27/2009","'+userId+'","a00F000000qknzd"';
        string generateJourney = 'true';
        
        Document document = new Document();
		document.Body = Blob.valueOf('/services/data/v40.0/sobjects/Document/0150m000000DKq1AAG/Body');
		document.ContentType = 'application/pdf';
		document.DeveloperName = 'Lead_Importer_CSV';
		document.IsPublic = true;
		document.Name = 'Lead Importer CSV Template';
        document.FolderId = UserInfo.getUserId();
		insert document;
        
        Kickbox_Verification__c objKickboxVerification = new Kickbox_Verification__c();
        objKickboxVerification.Create_From_Journey_Importer__c = true;
        objKickboxVerification.Generate_Journey__c = Boolean.valueOf(generateJourney);     
        insert objKickboxVerification;
        
    }
    
    /*Purpose:This method cover the remote action call*/
   /* public static testMethod void coverRemoteActions(){
        SalesConsoleSettings.createSettings();
        KickboxVerificationController.getSettingsRecord(new List<string>{'KickboxAPI'});       
    }
    
    /*Purpose:This method cover the getTableBody() function*/
   /* public static testMethod void verifyGetTableBody(){
        map<string,list<sObject>> mapSobjectRecords = new map<string,list<sObject>>();
        set<string> setTblFields = new set<string>();
        setTblFields.add('Name');
        setTblFields.add('Email');
        
        list<lead> lstLeads = [SELECT Name,Email FROM Lead limit 2];
        mapSobjectRecords.put('Lead',lstLeads);
        Debug.log('KickboxVerificationController.getTableBody(lstLeads,setTblFields)==>'+KickboxVerificationController.getTableBody(setTblFields,mapSobjectRecords));
    }
    
    /*Purpose: Check Campaign member get add into campaign if we pass campaign Id to kickbox*/
    /*static testMethod void addCampaginMemeberTest() 
    {   
        Lead lead;
        Journey__c[] journeys;
        string leadId;
        Lead[] leads;
        Task[] tasks;
        LeadConvertorTest.initFieldMappings();
        
        lead = new Lead(FirstName = 'Test1', LastName = 'Test1', Company = 'Test', Email = 'testleadsaveCampaignMember1@example.com', Check_Duplicates__c = true);
        insert lead;
        journeys = [SELECT Id,Primary_Email__c FROM Journey__c];
        System.assertEquals(0, journeys.size());
        
        string csv1 = '"First Name","Last Name","EMAIL","Company","Locations Interested","Lead Source","Lead Source Detail","Generate Journey","Status","Phone"\n'+'"Wework","Kickbox1","Test3107_1@enzigma.com","","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","1234567890"\n'+'"Wework","Kickbox1","Test3107_2@enzigma.com","Enzigma","LA-Gas Tower","","Book A Tour Form","true","Open","1234567891"\n'+'"Wework","Kickbox1","Test3107_3@enzigma.com","Enzigma","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","1234567891"\n'+'"Wework","Kickbox1","Test3107_4@enzigma.com","Enzigma","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","1234567891"\n';
       // string csv2 = '"First Name","Last Name","EMAIL","Company","Phone","Locations Interested","Lead Source","Lead Source Detail","Generate Journey","Status","Number of Desks 2016","Last Engage Email Sent","CallRail Answered","Event Date Needed","Lead Owner","Building Interested In"\n'+'"Wework","Kickbox2","Test1@enzigma.com","Enzigma","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","6","10/14/2011 11:46 AM","true","hjghfj","'+userId+'","'+buildingId+'"\n'+'"Wework","Kickbox3","Test2@enzigma.com","Enzigma","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","6","lhhl","true","12/27/2009","'+userId+'","'+buildingId+'"\n'+'"Wework","Kickbox5","Test3@enzigma.com","","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","6","10/14/2011 11:46 AM","true","12/27/2009","'+userId+'","'+buildingId+'"\n'+'"Wework","Kickbox6","Test4@enzigma.com","Enzigma","5658565555","LA-Gas Tower","","Book A Tour Form","true","Open","6","10/14/2011 11:46 AM","true","12/27/2009","'+userId+'","'+buildingId+'"\n'+'"Wework","Kickbox1","Test5@enzigma.com","Enzigma","5658565555","LA-Gas Tower","wework.com","Book A Tour Form","true","Open","6","10/14/2011 11:46 AM","true","12/27/2009","'+userId+'","a00F000000qknzd"';
        
        //Insert test campaigns     
	    Campaign campaign1 = new Campaign(Name = 'Test Campaign 1', City__c = 'Chicago', State__c = 'IL');
		insert campaign1;
		System.assert(campaign1.Id != null);
        Attachment att1 = new Attachment();
        att1.IsPrivate = false;
        
        Test.startTest();
        KickboxVerificationController.kickboxVerification(csv1, 'true', att1, campaign1.Id,null,'2');
        Test.stopTest();
             
        leads = [SELECT Id,Name,email FROM Lead WHERE Email != 'testleadsaveCampaignMember1@example.com' and isConverted = false];
        System.assertEquals(2, leads.size());
        
        //Check campaign member insertion.
        List<CampaignMember> lstCampaignMember = [SELECT Id,leadId,contactId FROM CampaignMember WHERE campaignId =: campaign1.Id];
        debug.log('lstCampaignMember 245==>'+lstCampaignMember);
        System.assertEquals(2,lstCampaignMember.size());
        
        journeys = [SELECT Id,Primary_Email__c FROM Journey__c WHERE Primary_Email__c != 'testleadsaveCampaignMember1@example.com'];
        System.assertEquals(2, journeys.size());
    }*/
}