/************************************************************************************************************************************
    Author 		:  Amol Darekar   
    Description :  This class covers all test method related lead trigger
    History		:  --

----------------------------------------------------------------------------------------------------------------------------------
	VERSION					DATE					AUTHOR							DETAIL
	1					    05,July 2016		    Amol Darekar  	                Initial Developement
	2.0						06 June 2018			Sunil Bhosale					Code revamp.
**************************************************************************************************************************************/
@isTest
public class LeadTriggerHandlerTest {  
    static Boolean settingsInitialized = false;
    static User apiUser;
    static User testUser;    
    static LeadConvertor.JourneySettings settingJourney;
    static set<String> setEmails = new set<String>() ;
    
    @TestSetup
    static void initData(){          
        SalesConsoleSettings.createSettings();
        WeWorkValidatorHelper.createTerritoryStructure();
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];       
        apiUser = [SELECT Id,Name From User WHERE Name='Susie Romero' LIMIT 1];       
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','testweworkuser1');
        userRecordMap.put('Username','testweworkuser1878@example.com');
        userRecordMap.put('Email','testweworkuser1@example.com');
        testUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true);      
        List<Lead> lstLeadsToInsert = new List<Lead>();
        List<Journey__C> lstJourneys = new List<Journey__C>();
        set<Id> setLeadIds = new set<Id>();
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_1@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open', Locations_Interested__c = 'Test Building Tour',Company = 'Enzigma ltd',Generate_Journey__c = true,Number_of_Full_Time_Employees__c = 15));
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_2@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open', Locations_Interested__c = 'Test Building Tour',Company = 'Enzigma group',Generate_Journey__c = true,Number_of_Full_Time_Employees__c = 25));
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_3@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open', Locations_Interested__c = 'Test Building Tour',Company = 'Enzigma services',Generate_Journey__c = true, Number_of_Full_Time_Employees__c = 1025));
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_4@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open', Locations_Interested__c = 'Test Building Tour',Company = 'Enzigma systems',Generate_Journey__c = true,Unomy_Company_Size__c = '1001'));
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'johnDoe6618_5@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open', Locations_Interested__c = 'Test Building Tour',Company = 'Enzigma .co.usa',Generate_Journey__c = true,Unomy_Company_Size__c = '999')); 
        TestingUtility.insertListWithAssert(lstLeadsToInsert);
        
        for(Journey__c journey : [SELECT Id FROM Journey__c WHERE Primary_Lead__c IN : lstLeadsToInsert])
            System.assert(journey.Id != null, 'Journey not inserted properly');
        List<Building__C> lstBuilding = [SELECT Id FROM Building__C WHERE Name = 'Test Building Tour'];       
    }
    
 
 /************************************************************************************************************************************
       	Author 				: Sunil Bhosale
       	Description 		: This method used to update CleansedCompanyName on Lead based on 'AccountCleansingSetting' setting.
		Issue NO : 			: ST-352
	   	Created Date		: 06 June 2018
		Modified by			: Ashish Mishra
		Modified Date		: 11 July 2018
 **************************************************************************************************************************************/
    static testMethod void verifyupdateCleansedCompanyName(){
        List<Lead> lstLead = new List<Lead>();
        for(Lead lead : [select id , company, Cleansed_Company_Name__c from Lead]){
            System.assert(lead.company!= null);
            System.assert(lead.Cleansed_Company_Name__c!= null);            
            lead.Company = 'Enzigma consulting';
            lstLead.add(lead);
        }
        update lstLead;
        for(Lead lead : [select id , company, Cleansed_Company_Name__c from Lead]){
            System.assert(lead.company!= null);
            System.assert(lead.Cleansed_Company_Name__c!= null);
            System.assert(lead.Cleansed_Company_Name__c == 'enzigma', 'Cleansed_Company_Name__c not map properly');
        }
    }
    
 /************************************************************************************************************************************
       Author 				: Sunil Bhosale
       Description 			: This method used to update CleansedCompanyName on Lead based .
		Issue NO : 			: ST-352
	   Created Date			: 06 June 2018
**************************************************************************************************************************************/     
    Static testMethod void verifyUpdateCleansedName(){
        List<Lead> lstLeadObj = new List<Lead>();
        for(Lead lead : [SELECT id, Company, Name, Cleansed_Company_Name__c FROM Lead]){           
            System.assert(lead.Name != null);
            lead.LastName = 'John Doe Test';
            lstLeadObj.add(lead);
        }
        update lstLeadObj;
        for(Lead lead : [select Id, company, Name, Cleansed_Company_Name__c from Lead]){           
            System.assert(lead.Name != Null);
        }
    }
    
/************************************************************************************************************************************
       Author 				: Sunil Bhosale
       Description 			: Update The Building Interest On Lead.
		Issue NO : 			: ST-352
	   Created Date			: 06 June 2018
**************************************************************************************************************************************/
    static testMethod void verifyupdateBuildingInterestOnLead(){
        List<Building__C> lstBuilding = [select id from Building__C where name = 'Test Building Tour'];
        for(Lead lead : [select id,Locations_Interested__c,Building_Interested_In__c from Lead]){
            System.assert(lead.Locations_Interested__c != null);
            System.assert(lead.Building_Interested_In__c != null);
            System.assert(lead.Building_Interested_In__c == lstBuilding[0].Id);
            
        }
    }
    
/************************************************************************************************************************************
       Author 				: Sunil Bhosale
       Description 			: This trigger is used to update Active referre(Referrer__c) on Lead
		Issue NO : 			: ST-352
	   Created Date			: 06 June 2018
**************************************************************************************************************************************/
    static testMethod void verifyUpdateActiveReferrerOnLead(){
        List<Account> lstAccount = new List<Account>();
        List<Contact> lstcontact = new List<Contact>();
        List<Referral__c> lstReferral = new List<Referral__c>();
        List<Lead> lstLeadsToInsert = new List<Lead>();
        List<Lead> lstLead = new List<Lead>();
        set<String> setEmails =new set<String>();
        lstAccount.add(new Account(Name='account7', Unomy_Company_ID__c = 77777, Lead_Source__c='LeadSource1'));
        lstAccount.add( new Account(Name='account8', Unomy_Company_ID__c = 8888, Lead_Source__c='LeadSource2'));
        lstAccount.add( new Account(Name='account9', Unomy_Company_ID__c = 99999, Lead_Source__c='LeadSource3'));
        lstAccount.add( new Account(Name='account10', Unomy_Company_ID__c = 00000, Lead_Source__c='LeadSource4'));
        lstAccount.add( new Account(Name='account11', Unomy_Company_ID__c = 12121, Lead_Source__c='LeadSource5'));
        TestingUtility.insertListWithAssert(lstAccount);
        for(Account account : lstAccount){
            System.assert(account.Id!= null, 'Accounts not inseertd');
        }
        lstcontact.add(new Contact(FirstName='Contact7',LastName='Member',Email='test.RefContact1@example.com',AccountId=lstAccount[0].Id));
        lstcontact.add(new Contact(FirstName='Contact8',LastName='Member',Email='test.RefContact2@example.com',AccountId=lstAccount[1].Id));
        lstcontact.add(new Contact(FirstName='Contact9',LastName='Member',Email='test.RefContact3@example.com',AccountId=lstAccount[2].Id));
        lstcontact.add(new Contact(FirstName='Contact10',LastName='Member',Email='test.RefContact4@example.com',AccountId=lstAccount[3].Id));
        lstcontact.add(new Contact(FirstName='Contact11',LastName='Member',Email='test.RefContact5@example.com',AccountId=lstAccount[4].Id));
        TestingUtility.insertListWithAssert(lstcontact);
        
        for(Contact contact : lstcontact)   {
            System.assert(contact.Id!= null, 'contacts not inseertd');
        } 
        lstReferral.add(new Referral__c(Referral_Email__c = 'referral_6@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[0].Id));
        lstReferral.add(new Referral__c(Referral_Email__c = 'referral_7@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[1].Id));
        lstReferral.add(new Referral__c(Referral_Email__c = 'referral_8@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[2].Id));
        lstReferral.add(new Referral__c(Referral_Email__c = 'referral_9@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[3].Id));
        lstReferral.add(new Referral__c(Referral_Email__c = 'referral_10@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = lstcontact[4].Id));
        TestingUtility.insertListWithAssert(lstReferral);
        for(Referral__c Referral : lstReferral){
            System.assert(Referral.Id!= null, 'Referral not inseertd');
            setEmails.add(Referral.Referral_Email__c);
        }
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'referral_6@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany1', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true));
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'referral_7@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany2', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true));
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'referral_8@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany3', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true));
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'referral_9@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany4', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true));
        lstLeadsToInsert.add(new Lead(LastName = 'Doe', FirstName = 'John', Email = 'referral_10@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open',Company = 'TestCompany5', Locations_Interested__c = 'Test Building Tour',Generate_Journey__c = true)); //NYC-5th Ave;LON-Aldgate Tower; NYC-42 Street
        TestingUtility.insertListWithAssert(lstLeadsToInsert);
        for(Lead lead : [SELECT Id, Referrer__c FROM Lead WHERE Email IN : setEmails]){
            System.assert(lead.Referrer__c!= null, 'Referrer is null');
        }
    }
    
/************************************************************************************************************************************
       Author 				: Sunil Bhosale
       Description 			: This test method verifies that when the Lead is 'Unqulified' then started journey associated with Lead shode
							  be 'Unqulified', i.e journey status = 'Unqulified'.
       Created Date			: 06 June 2018
**************************************************************************************************************************************/
    static testMethod void verifyChangeRelatedJourneyStatus(){
        List<Lead> lstLeadsToUpdate = new List<Lead>() ;
        set<Id>  setLeadIds = new set<Id>();
        for(Lead objLead : [SELECT Id, Status, Unqualified_Reason__c FROM Lead]){
            objLead.Status = 'Unqualified';
            objLead.Unqualified_Reason__c = 'Not interested';
            lstLeadsToUpdate.add(objLead);
            setLeadIds.add(objLead.Id);
        }
        Test.startTest();
        if(lstLeadsToUpdate.size() > 0){
            update lstLeadsToUpdate;  
        }    
        Test.stopTest();
        List<Journey__c> lstJourneys = [SELECT Id, Status__c, Lost_Reason__c FROM journey__c WHERE Primary_Lead__c IN : setLeadIds];
        Debug.log('lstJourneys==>'+lstJourneys);
        for(Journey__c journey : lstJourneys){
            System.assertEquals('Unqualified', journey.Status__c, 'journey status is not changing properly ');
            System.assertEquals('Not interested', journey.Lost_Reason__c, 'Lost reason is not mapping properly on journey from Lead');    
        }
    }
    
/************************************************************************************************************************************
       Author 				: Sunil Bhosale
       Description 			: This trigger is used to verify if Lead is converted then journey associated with the Lead move to Contact.
								( When Lead gets converted, we need to set the Contact person on the Journey as a "Primary Contact")
       Created Date			: 06 June 2018
**************************************************************************************************************************************/
 
    static testMethod void verifyupdateJourneyPrimaryContact(){
        List<String> lstEmail = new List<String>();
        set<Id> setLeadId = new set<Id>();
        Map<String,Id> mapLeadEmailToContactId = new Map<String,Id>();      
        List<Lead> lstLeads = new list<Lead>([SELECT id,Status,Email,ConvertedContactId,Unqualified_Reason__c,Campaign_Id__c,Lead_Assignment_Stage__c,IsConverted,(SELECT Id FROM Journeys__r) FROM Lead]);
        for(Lead lead : lstLeads){
            lstEmail.add(lead.Email);
            setLeadId.add(lead.Id);
        }       
        test.startTest();
        LeadConverterHelper.manageLead(lstLeads);
        test.stopTest();
        for(Lead lead : [select id,Email,ConvertedContactId from Lead where Id IN : setLeadId]){
            mapLeadEmailToContactId.put(lead.Email, lead.ConvertedContactId);
        }       
    }
    
/************************************************************************************************************************************
       Author 				: Sunil Bhosale
       Description 			: This method is used to verify Restart journey functionality
       Created Date			: 06 June 2018
**************************************************************************************************************************************/
   
    static testMethod void verifyrestartJourney(){
        set<Id> setLeadId = new set<Id>();
        List<Journey__C> lstJourneyToUpdate  = new List<Journey__C> ();      
        List<Lead> lstLeads = [select id,Status,Email,ConvertedContactId,Unqualified_Reason__c from Lead];       
        List<Journey__C> lstJourney = [Select Id,Primary_Lead__c,Primary_Contact__c,NMD_Next_Contact_Date__c From Journey__c Where Primary_Lead__c IN : lstLeads];
        for(Journey__C journey : lstJourney ){
            journey.NMD_Next_Contact_Date__c = Date.newInstance(2018, 06, 06).addDays(2);
            lstJourneyToUpdate.add(journey);
        }
        test.startTest();
        update lstJourneyToUpdate;
        
        List<Lead> lstLeadToUpadte  = new List<Lead>();
        for(Lead lead : lstLeads){
            lead.Restart_Journey__c = true;
            lstLeadToUpadte.add(lead);
        }
        update lstLeadToUpadte;
        for(Lead objLead : [SELECT Id, (SELECT Id, OwnerId, CreatedDate, NMD_Next_Contact_Date__c FROM Journeys__r ORDER BY LastModifiedDate DESC) From Lead Where Id IN :lstLeads]){
            if(objLead.journeys__r.size() > 0){
                System.assertEquals(LeadTriggerHandlerTest.getBuisnessDate(objLead.journeys__r[0]), objLead.journeys__r[0].NMD_Next_Contact_Date__c, 'NMD_Next_Contact_Date__c NOT changed');   
            }
        } 
        lstLeadToUpadte.clear();
        lstLeads.clear();
        lstLeads = [select id,Restart_Journey__c from Lead where Id IN : setLeadId];
        for(Lead lead : lstLeads){
            System.assertEquals(false, lead.Restart_Journey__c, 'Restart_Journey__c field shode be false after update of lead');
            lead.Restart_Journey__c = true;
            lstLeadToUpadte.add(lead);
        }
        test.stopTest();
        delete [select id from Journey__c where Primary_Lead__c IN : setLeadId];//remove all started journeys associated with the lead
        System.assert([select id from Journey__c where Primary_Lead__c IN : setLeadId].size() == 0);//journeys are apsent.
        update lstLeadToUpadte;//again make Restart_Journey__c as true and update now New started journeys shode create for all leads.
        for(Journey__c journey : [SELECT Id, NMD_Next_Contact_Date__c, Primary_Lead__c, Status__c, Primary_Email__c FROM Journey__c WHERE Primary_Lead__c IN : setLeadId]){
            System.assertEquals('Started', journey.Status__c, 'journey status is not correct');         
        }
    }
    
/************************************************************************************************************************************
       Author 				: Sunil Bhosale
       Description 			: This method is used to verify Office_Type__c on Building interest
       Created Date			: 06 June 2018
**************************************************************************************************************************************/
    static testMethod void verifyCopyOfficeTypeFromLeadToBuildingInterest(){
        List <Lead> lstLeads = [select id,Office_Type__c from Lead];
        List<Lead> lstLeadsToUpdate = new List<Lead> ();
        set<Id> setLeadIds = new set<Id>();
        for(Lead lead : lstLeads){
            lead.Office_Type__c = 'Hot desk';
            lstLeadsToUpdate.add(lead);
            setLeadIds.add(lead.Id);
        }
        update lstLeadsToUpdate;
        for(Building_Interest__c buildingInterest : [select id,Office_Type__c from Building_Interest__c where Lead__c IN : setLeadIds ]){
            debug.Log('buildingInterest.Office_Type__c'+buildingInterest.Office_Type__c);
            System.assertEquals('Hot desk', buildingInterest.Office_Type__c, 'Office_Type__c is not map properly on buildingInterest ');
        }
    }
    
  /***************************************************************************************************************************
       Author 				: Jitesh Adwani
       Description 			: test method to test CheckForRelatedJoureny.
       Created Date			: 07 june 2018
****************************************************************************************************************************/
    public static testMethod void verifyCheckForRelatedJoureny(){
        List<Lead> lstLead = new List<Lead>();
        List<Journey__c> lstJourney = new List<Journey__c>();        
        Lead testLead = new Lead(FirstName = 'Test',
                                 LastName = 'Lead',
                                 Company = 'TestCompany',
                                 Status = 'Open',
                                 Locations_Interested__c = 'B1; B2;',
                                 Office_Type__c = 'Shared Desk; DailyDesk;',
                                 Email = 'test@example.com',
                                 Referrer__c = null);
        lstLead.add(testLead);
        Lead testLead1 = new Lead(FirstName = 'Test',
                                  LastName = 'Lead1',
                                  Company = 'TestCompany',
                                  Status = 'Open',
                                  Locations_Interested__c = 'B1; B2;',
                                  Office_Type__c = 'Shared Desk; DailyDesk;',
                                  Email = 'test1@example.com',
                                  Referrer__c = null);
        lstLead.add(testLead1);
        insert lstLead;
        
        List<Lead> lstLeadData = [Select Id From Lead];        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'testJourney';
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        testJourney.Primary_Lead__c = lstLeadData[0].Id;
        lstJourney.add(testJourney);
        
        Journey__c testJourney1 = new Journey__c();
        testJourney1.Name = 'testJourney';
        testJourney1.NMD_Next_Contact_Date__c = Date.today();
        testJourney1.Primary_Lead__c = lstLeadData[1].Id;
        lstJourney.add(testJourney1);
        test.startTest();
        insert lstJourney;
        test.stopTest();
        try{
            delete lstLead;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot delete the Lead associated with one or more Journeys.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }  
       
    static void initFieldMappings() {
        if( settingsInitialized )
            return;
        Account account = new Account(Name = 'Dummy Lead Conversion Account');
        insert account;
        settingsInitialized = true;
    }
    
    private static void PrepareData(){
        List<Building__c> lstBuilding = new List<Building__c>();
        lstBuilding.add( new Building__c(Name = 'B1',UUID__c='111222333444555'));
        lstBuilding.add( new Building__c(Name = 'B2',UUID__c='222333444555666'));
        insert lstBuilding;
    }	
	
	
	/***************************************************************************************************************************
       Author 				: Amol Darekar
       Description 			: test method to Check For Related Joureny
       Created Date			: 05 july, 2016
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
	****************************************************************************************************************************/ 
    static testmethod void testCheckForRelatedJoureny(){        
        Lead testLead = new Lead(FirstName = 'Test',
                                 LastName = 'Lead',
                                 Company = 'TestCompany',
                                 Status = 'Open',
                                 Locations_Interested__c = 'B1; B2;',
                                 Office_Type__c = 'Shared Desk; DailyDesk;',
                                 Email = 'test@example.com',
                                 Referrer__c = null);
        insert testLead;
        List<Lead> lstLead = [Select Id From Lead where Company = 'TestCompany'];
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'testJourney';
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        testJourney.Primary_Lead__c = lstLead[0].Id;
        test.startTest();
        insert testJourney;
        test.stopTest();
        try{
            delete testJourney;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Lead related with one or more Jourenys. Can not delete Lead') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    /***************************************************************************************************************************
       Author 				: Shivprasad Patil
       Description 			: This method check update Lead Source and Lead Source detail according to unomy data.
       Created Date			:  17 July 2018
	****************************************************************************************************************************/
    public static testMethod void updateLeadSourceAndLeadSourceDetailTest(){
        Account objAccount = new Account(Name='Example', Unomy_Company_ID__c = 11111, Lead_Source__c='LeadSource1',Account_Type__c='Org');
        insert objAccount;
        Contact objContact = new Contact(FirstName='John',LastName='Smith',Email='john.smith@example.com',AccountId=objAccount.Id);
        insert objContact;
        insert new Lead(LastName = 'Doe', utm_source__c = 'PArtner',utm_medium__c='test', FirstName = 'John', Email = 'johnDoe6618_111@example.com' ,Office_Type__c = 'Daily Desk',Status = 'Open', Locations_Interested__c = 'Test Building Tour',Company = 'Enzigma ltd',Generate_Journey__c = true,Number_of_Full_Time_Employees__c = 15,Referrer__c=objContact.Id);
        List<Lead> lstLead = new List<Lead>([SELECT Id,LeadSource,Lead_Source_Detail__c FROM Lead WHERE Email = 'johnDoe6618_111@example.com']);
        System.assertEquals('Partner Referral', lstLead[0].LeadSource);
        System.assertEquals('test', lstLead[0].Lead_Source_Detail__c);
        lstLead = new List<Lead>([SELECT Id,LeadSource,Lead_Source_Detail__c FROM Lead WHERE Email = 'johnDoe6618_111@example.com']);
        test.startTest();
        if(lstLead.size() > 0){
            lstLead[0].utm_source__c = 'PArtner';
            lstLead[0].utm_medium__c='test' ;
            update lstLead;
        }
        test.stopTest();
        if(lstLead.size() > 0){        
            lstLead = new List<Lead>([SELECT Id,LeadSource,Lead_Source_Detail__c FROM Lead WHERE Email = 'johnDoe6618_111@example.com']);
            System.assertEquals('Partner Referral', lstLead[0].LeadSource);
            System.assertEquals('test', lstLead[0].Lead_Source_Detail__c);
        }
    }
    
    public static testMethod void testUpdateLeadScore(){
        List<Lead_Score_Table__c> lstLeadScoreTable = new List<Lead_Score_Table__c>();
        List<Lead> lstLead = new List<Lead>();
        List<Building__c> lstBuilding = new List<Building__c>();
        List<decimal> lstLeadScore = new List<decimal>{0.9455454675,0.8654455454,0.76654455454,0.66654455454,0.56654455454,0.46654455454,0.36654455454,0.26654455454};
            
            lstBuilding.add(new Building__c(Name = 'MUM-BKC',UUID__c = 'B-0001'));
        lstBuilding.add(new Building__c(Name = 'CHI-National',UUID__c = 'B-0002'));
        lstBuilding.add(new Building__c(Name = 'DC-Apollo',UUID__c = 'B-0003'));
        lstBuilding.add(new Building__c(Name = 'BLR-Building',UUID__c = 'B-0004'));
        TestingUtility.insertListWithAssert(lstBuilding);
        
        List<Building__c> lstInsertedBuilding = [Select Id,Name from Building__c where Id IN : lstBuilding];
        
        lstLeadScoreTable.add(new Lead_Score_Table__c(Lead_Source_Aggregate__c = 'Website',Lead_Source_Detail_Aggregate__c = 'Book A Tour Availability',Location_Interested__c = 'MUM',Number_Of_Full_Time_Employees__c = '1-10',Interested_In_Number_of_Desks__c = '1',Lead_Score__c = 0.9455454675));
        lstLeadScoreTable.add(new Lead_Score_Table__c(Lead_Source_Aggregate__c = 'Outbound',Lead_Source_Detail_Aggregate__c = 'Other',Location_Interested__c = 'CHI',Number_Of_Full_Time_Employees__c = '15',Lead_Score__c = 0.8654455454));
        lstLeadScoreTable.add(new Lead_Score_Table__c(Lead_Source_Aggregate__c = 'Inbound Call',Lead_Source_Detail_Aggregate__c = 'NA',Location_Interested__c = 'DC',Interested_In_Number_of_Desks__c = '2-9',Lead_Score__c = 0.76654455454));
        lstLeadScoreTable.add(new Lead_Score_Table__c(Lead_Source_Aggregate__c = 'Affiliate Referral',Lead_Source_Detail_Aggregate__c = 'Referral Web',Interested_In_Number_of_Desks__c = '10-20',Lead_Score__c = 0.66654455454));
        lstLeadScoreTable.add(new Lead_Score_Table__c(Lead_Source_Aggregate__c = 'Broker Referral',Lead_Source_Detail_Aggregate__c = 'Softbank Japan Referral',Number_Of_Full_Time_Employees__c = '55',Lead_Score__c = 0.56654455454));
        lstLeadScoreTable.add(new Lead_Score_Table__c(Lead_Source_Aggregate__c = 'Guest Wifi & Events',Lead_Source_Detail_Aggregate__c = 'SOS Worldwide Ltd Referral',Location_Interested__c = 'BLR',Lead_Score__c = 0.46654455454));
        lstLeadScoreTable.add(new Lead_Score_Table__c(Lead_Source_Aggregate__c = 'Partner Referral',Lead_Source_Detail_Aggregate__c = 'spacingcoil Referral',Number_Of_Full_Time_Employees__c = '105',Interested_In_Number_of_Desks__c = '21-100',Lead_Score__c = 0.36654455454));
        lstLeadScoreTable.add(new Lead_Score_Table__c(Lead_Source_Aggregate__c = 'Guest Wifi & Events',Lead_Source_Detail_Aggregate__c = 'Other',Lead_Score__c = 0.26654455454)); 
        
        TestingUtility.insertListWithAssert(lstLeadScoreTable);
        
        lstLead.add(new Lead(LastName = 'Doe1', FirstName = 'John1', Company = 'infoway', Email = 'johnDoe007_01@example.com', LeadSource='weWork.com', Generate_Journey__c = false, Lead_Source_Detail__c='Book A Tour Availability', Building_Interested_In__c = lstInsertedBuilding[0].Id, Unomy_Company_Size__c='1-10', Interested_in_Number_of_Desks__c = 1));
        lstLead.add(new Lead(LastName = 'Doe2', FirstName = 'John2', Company = 'ibm', Email = 'johnDoe007_02@example.com', LeadSource='Outbound Email/Cold Call', Generate_Journey__c = false, Lead_Source_Detail__c='Project Upgrade - US/Can East', Building_Interested_In__c = lstInsertedBuilding[1].Id, Unomy_Company_Size__c = '15'));
        lstLead.add(new Lead(LastName = 'Doe3', FirstName = 'John3', Company = 'infosys', Email = 'johnDoe007_03@example.com', LeadSource='Inbound Call', Generate_Journey__c = false, Lead_Source_Detail__c='NA', Building_Interested_In__c = lstInsertedBuilding[2].Id, Interested_in_Number_of_Desks__c = 3));
        lstLead.add(new Lead(LastName = 'Doe4', FirstName = 'John4', Company = 'wipro', Email = 'johnDoe007_04@example.com', LeadSource='Affiliate Referral', Generate_Journey__c = false, Lead_Source_Detail__c='Referral Web', Interested_in_Number_of_Desks__c = 15));
        lstLead.add(new Lead(LastName = 'Doe5', FirstName = 'John5', Company = 'MRF', Email = 'johnDoe007_05@example.com' , LeadSource='Broker Referral', Generate_Journey__c = false, Lead_Source_Detail__c='Softbank Japan Referral', Unomy_Company_Size__c = '55')); 
        lstLead.add(new Lead(LastName = 'Doe6', FirstName = 'John6', Company = 'TATA', Email = 'johnDoe007_06@example.com', LeadSource='Event', Lead_Source_Detail__c='SOS Worldwide Ltd Referral', Generate_Journey__c = false, Building_Interested_In__c = lstInsertedBuilding[3].Id)); 
        lstLead.add(new Lead(LastName = 'Doe7', FirstName = 'John7', Company = 'Infra', Email = 'johnDoe007_07@example.com', LeadSource='Partner Referral', Lead_Source_Detail__c='spacingcoil Referral', Generate_Journey__c = false, Unomy_Company_Size__c = '105', Interested_in_Number_of_Desks__c = 25));   
        lstLead.add(new Lead(LastName = 'Doe8', FirstName = 'John8', Company = 'Calsoft', Email = 'johnDoe007_08@example.com', LeadSource='Event', Lead_Source_Detail__c = 'test ',Generate_Journey__c = false));
        TestingUtility.insertListWithAssert(lstLead);
        test.startTest();
        for(Lead leadRec : lstLead){
            leadRec.Unomy_Updated_DateTime__c = system.now();
        }
        TestingUtility.updateListWithAssert(lstLead);        
        List<Lead> lstUpdatedLeadsRecord = [SELECT ID,Name,Email,Unomy_Updated_DateTime__c,Lead_Demographic_Score__c FROM Lead WHERE ID IN : lstLead];        
        for(Integer index = 0; index < lstUpdatedLeadsRecord.size();index++) {           
            system.assertEquals(lstLeadScore[index], lstUpdatedLeadsRecord[index].Lead_Demographic_Score__c);
        }
        test.stopTest();
    }
    
    @isTest
    public static void verifyCheckRelatedJourney(){      
        set<Id> setLeadId = new set<Id>();            
        List<Lead> lstLeads = [SELECT Id, Status, Email, ConvertedContactId, Unqualified_Reason__c FROM Lead];  
        try{
            delete lstLeads[0];
        }catch(Exception pEx){
            System.assert(pEx.getMessage().contains('You cannot delete the Lead associated with one or more Journeys.'));
        }
    } 
    
    public static Map<String,BusinessHours> mapBH;
    public static Map<Id,Id> mapGroupIdwithUserId;
    public static void getBusinessHours(){
        if(mapBH == null){
            mapBH = new Map<String,BusinessHours>();
            for(BusinessHours bh : [SELECT Id,Name FROM BusinessHours]){
                if(!mapBH.containsKey(bh.Name))
                    mapBH.put(bh.Name, bh);
            }  
        } 
    }
    
    public static void getmapGroupIdwithUserIds(){
        if(mapGroupIdwithUserId == null){
            mapGroupIdwithUserId = new Map<Id,Id>();
            for(GroupMember objGroupMember : [SELECT UserOrGroupId,GroupId FROM GroupMember]){
                if(!mapGroupIdwithUserId.containsKey(objGroupMember.GroupId)){
                    mapGroupIdwithUserId.put(objGroupMember.GroupId, objGroupMember.UserOrGroupId);
                }
            }   
        }        
    }
    
    public static Date getBuisnessDate(Journey__c journeyRec){ 
        settings.fetchUsers();
        getmapGroupIdwithUserIds();
        Date returnDate;
        Map<Id,User> mapUsers = settings.mapAllUsersById;
        getBusinessHours();
        if(!((String)journeyRec.OwnerId).startsWith('00G')){
            String str = 'WeWork_'+ mapUsers.get(journeyRec.OwnerId).TimeZoneSidKey +'_Business_Hours';
            if(mapBH.containsKey(str)){
                Timezone tz = Timezone.getTimeZone(mapUsers.get(journeyRec.OwnerId).TimeZoneSidKey);                      
                if(!BusinessHours.isWithin(mapBH.get(str).Id, journeyRec.CreatedDate)){
                    DateTime dt = BusinessHours.nextStartDate(mapBH.get(str).Id, journeyRec.CreatedDate);                            
                    DateTime localDate = dt.addMinutes(tz.getOffset(dt) / (60 * 1000));                           
                    returnDate = date.valueOf(dt.format('yyyy-MM-dd', mapUsers.get(journeyRec.OwnerId).TimeZoneSidKey));                           
                }else{
                    DateTime dt = BusinessHours.nextStartDate(mapBH.get(str).Id, journeyRec.CreatedDate);                           
                    DateTime localDate = dt.addMinutes(tz.getOffset(dt) / (60 * 1000));                           
                    if((journeyRec.OwnerId != null) && mapUsers.containsKey(journeyRec.OwnerId)){
                        returnDate = date.valueOf(dt.format('yyyy-MM-dd', mapUsers.get(journeyRec.OwnerId).TimeZoneSidKey));    
                    }                          
                }
            }
        }else{
            TimeZone uTZ = UserInfo.getTimeZone();
            String str ='';
            if(mapGroupIdwithUserId != null && mapUsers != null && mapGroupIdwithUserId.containsKey(journeyRec.OwnerId) && mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)) != null){
                str = 'WeWork_'+ mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)).TimeZoneSidKey +'_Business_Hours';   
            }else{
                str = 'WeWork_'+ uTZ.getID() +'_Business_Hours';
            }
            if(mapBH.containsKey(str)){
                Timezone tz;
                if(mapGroupIdwithUserId != null && mapUsers != null && mapGroupIdwithUserId.containsKey(journeyRec.OwnerId) && mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)) != null){
                    tz = Timezone.getTimeZone(mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)).TimeZoneSidKey);  
                } else {
                    tz = uTZ;   
                }
                if(!BusinessHours.isWithin(mapBH.get(str).Id, journeyRec.CreatedDate)){
                    DateTime dt = BusinessHours.nextStartDate(mapBH.get(str).Id, journeyRec.CreatedDate);                           
                    DateTime localDate = dt.addMinutes(tz.getOffset(dt) / (60 * 1000));                          
                    returnDate = ((mapGroupIdwithUserId.containsKey(journeyRec.OwnerId) && mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)) != null) ? date.valueOf(dt.format('yyyy-MM-dd', mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)).TimeZoneSidKey)) : date.valueOf(dt.format('yyyy-MM-dd', uTZ.getID())));
                }else{
                    DateTime dt = BusinessHours.nextStartDate(mapBH.get(str).Id, journeyRec.CreatedDate);                          
                    DateTime localDate = dt.addMinutes(tz.getOffset(dt) / (60 * 1000));
                    returnDate =  ((mapGroupIdwithUserId.containsKey(journeyRec.OwnerId) && mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)) != null) ? date.valueOf(dt.format('yyyy-MM-dd', mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)).TimeZoneSidKey)) : date.valueOf(dt.format('yyyy-MM-dd', uTZ.getID())));
                }
            }           
        }
        Debug.log('Return todays Date==>'+returnDate);
        return returnDate;
    }
}