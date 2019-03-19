/************************************************************************************************************************************
  Author     	: Dipak Pawar
  Description 	: This class is used to test OpportunityHelper

History:
----------------------------------------------------------------------------------------------------------------------------------
  VERSION      	DATE        		AUTHOR          	DETAIL              	ISSUE
	1			5th June 2018   	Dipak Pawar     	Initial Developement    ST-
**************************************************************************************************************************************/
@isTest
public class OpportunityHelperTest {

    static List<Account> lstAccount =  new List<Account>() ;
    static List<Building__c> lstBuilding = new List<Building__c>();
    static List<Contact> lstContacts = new List<Contact>();
    static String recTypeEnterpriseId;
    static String recTypeMidMarketId;
    static String recTypeComsumerId;

    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This setup method will setup the initial test data for verification of Tour and Task creation functionality.
        Created Date  		:   07 June 2018
        Issue No			:	ST-
    **************************************************************************************************************************************/
    static{
        SalesConsoleSettings.createSettings();
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Map<String, Object> mapCommunitySalesLead = new Map<String, Object>();
        mapCommunitySalesLead.put('LastName', 'TestCommunitySalesLead');
        mapCommunitySalesLead.put('Username', 'TestCommunitySalesLead@weworkexample.com');
        mapCommunitySalesLead.put('Email', 'testCommunitySalesLead@wework.com');
        User CommunityLead = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapCommunitySalesLead, true);
        //List of Building
        lstBuilding = new List<Building__c>();
        lstBuilding.add(new Building__c(City__c = 'Amsterdam', Country__c = 'Netherlands',Name = 'AMS-Metropool', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam'));
        lstBuilding.add(new Building__c(City__c = 'Brooklyn',Country__c = 'USA',State__c='TS', Name = 'BKN-Brooklyn Heights',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/New_York',Region_Name__c = 'Mumbai'));
        lstBuilding.add(new Building__c(City__c = 'Clinton',Country__c = 'USA',State__c='TS', Name = 'BKN-Clinton Heights',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/New_York',Portfolio_Name__c= 'PortfolioNmae'));
        lstBuilding.add(new Building__c(City__c = 'Bristol',Country__c = 'USA',State__c='TS', Name = 'BKN-Bristol Heights',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/New_York',Cluster_Name__c= 'ClusterName'));
        lstBuilding.add(new Building__c(City__c = 'Bristol',Country__c = 'USA',State__c='TS', Name = 'testBuilding',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/New_York',Cluster_Name__c= 'ClusterName'));
        lstBuilding.add(new Building__c(City__c = 'Mumbai',Country__c = 'India',State__c='MH', Name = 'TestMumbaiBuilding',CurrencyIsoCode = 'INR',Time_Zone__c = 'Asia/Kolkata',Cluster_Name__c= 'ClusterName', Community_Sales_Lead__c = CommunityLead.Id));
        TestingUtility.insertListWithAssert(lstBuilding);

        //Refrence fields - RecordTypeId,Market__c,Primary_Member__c
        recTypeComsumerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        recTypeMidMarketId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        recTypeEnterpriseId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();

        Account testAccount1 = TestingUtility.createAccount('Test-Account1',false);
        testAccount1.RecordTypeId = recTypeComsumerId ;
        testAccount1.Unomy_Location_Country__c = 'Australia';

        Account testAccount2 = TestingUtility.createAccount('Test-Account2',false);
        testAccount2.RecordTypeId = recTypeMidMarketId ;

        Account testAccount3 = TestingUtility.createAccount('Test-Account3',false);
        testAccount3.RecordTypeId = recTypeEnterpriseId ;
        lstAccount.add(testAccount1);
        lstAccount.add(testAccount2);
        lstAccount.add(testAccount3);
        TestingUtility.insertListWithAssert(lstAccount);

        Contact conRec1 = new Contact(
            firstname  = 'John1',
            lastname   = 'Rambo1',
            email     = 'test1@example.com',
            accountID  = lstAccount[0].Id,
            Status__c  = 'active'
        );
        Contact conRec2 = new Contact(
            firstname  = 'John2',
            lastname   = 'Rambo2',
            email     = 'test2@example.com',
            accountID  = lstAccount[1].Id,
            Status__c  = 'active'
        );
        Contact conRec3 = new Contact(
            firstname  = 'John3',
            lastname   = 'Rambo3',
            email     = 'test3@example.com',
            accountID  = lstAccount[2].Id,
            Status__c  = 'active'
        );
        Contact conRec4 = new Contact(
            FirstName='WeWork',
            LastName='NMD USER',
            Email='testCommunitySalesLead@wework.com',
            accountID  = lstAccount[2].Id,
            Status__c  = 'active');

        lstContacts.add(conRec1);
        lstContacts.add(conRec2);
        lstContacts.add(conRec3);
        lstContacts.add(conRec4);
        TestingUtility.insertListWithAssert(lstContacts);

        List<Account> lstAccToUpdate = new List<Account>();
        testAccount1.Primary_Member__c = conRec1.Id;
        testAccount2.Primary_Member__c = conRec2.Id;
        testAccount3.Primary_Member__c = conRec3.Id;
        lstAccToUpdate.add(testAccount1);
        lstAccToUpdate.add(testAccount2);
        lstAccToUpdate.add(testAccount3);
        update lstAccToUpdate;

        Opportunity oppRec1 = TestingUtility.createOpportunity(lstAccount[0].Id, false);
        oppRec1.Primary_Member__c = lstContacts[0].Id;
        oppRec1.StageName = 'Qualifying';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.Building__c = lstBuilding[0].Id;
        oppRec1.Locations_Interested__c = lstBuilding[0].Name;
        TestingUtility.insertWithAssert(oppRec1);

        Opportunity oppRec2 = TestingUtility.createOpportunity(lstAccount[1].Id, false);
        oppRec2.Primary_Member__c = lstContacts[1].Id;
        oppRec2.StageName = 'Qualifying';
        oppRec2.CloseDate = system.today().addDays(5);
        oppRec2.Building__c = lstBuilding[1].Id;
        oppRec2.Locations_Interested__c = lstBuilding[1].Name;
        TestingUtility.insertWithAssert(oppRec2);
    }

 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This setup method will setup the initial test data for verification of Tour and Task creation functionality.
        Created Date  		:   22 June 2018
        Issue No			:	ST-
 ***************************************************************************************************************************************/
    static testMethod void verifyGetLatestOpportunity(){
        Account acc = new Account();
        acc = new Account();
        acc.Name = 'A Company';
        acc.UUID__c = 'account-uuid';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        TestingUtility.insertWithAssert(acc);

        Contact con = TestingUtility.createContact(acc.Id, 'strLastName 1', false);
        con.UUID__c = 'contact-uuid';
        con.Email = 'testtourcompletedbycontact@example.com';
        TestingUtility.insertWithAssert(con);

        RESTAPITourModelsV2.Input tourPayload = RESTAPITourV2Test.getTourPayload();
        tourPayload.contact_uuid = con.UUID__c;
        tourPayload.booked_by_contact_id =null;
        tourPayload.booked_by_sales_lead = false;
        tourPayload.email = con.Email;
        tourPayload.first_name = con.FirstName;
        tourPayload.last_name = con.LastName;
    }

     /************************************************************************************************************************************
        Author              :   Priyanka Ambre
        Description         :   This setup method will test getOrCreateOpportunity.
        Created Date  		:   27 June 2018
        Issue No			:	ST-
   ***************************************************************************************************************************************/

    static testMethod void verifyGetOrCreateOpportunity(){
        RESTAPITourModelsV2.Input tourPayload = RESTAPITourV2Test.getTourPayload();
        tourPayload.booked_by_contact_id = lstContacts[0].Id;
        tourPayload.booked_by_sales_lead = true;
        tourPayload.email = lstContacts[0].Email;
        tourPayload.first_name = lstContacts[0].FirstName;
        tourPayload.last_name = lstContacts[0].LastName;
        tourPayload.sf_journey_uuid = 'abc123-55645';

        Opportunity oppRec1 = TestingUtility.createOpportunity(lstAccount[0].Id, false);
        oppRec1.Primary_Member__c = lstContacts[0].Id;
        oppRec1.StageName = 'Qualifying';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.Building__c = lstBuilding[0].Id;
        oppRec1.Locations_Interested__c = lstBuilding[0].Name;
        TestingUtility.insertWithAssert(oppRec1);

        Test.startTest();
        Opportunity objOpportunity = OpportunityHelper.getOrCreateOpportunity(tourPayload, lstAccount[0].Id, lstContacts[0].Id, oppRec1.Id , lstBuilding[0]);
        System.assertEquals(oppRec1.Id, objOpportunity.Id);

        Opportunity objOpportunity1 = OpportunityHelper.getOrCreateOpportunity(tourPayload, lstAccount[0].Id, lstContacts[0].Id, oppRec1.Id, lstBuilding[0]);
		System.assertEquals(oppRec1.Id, objOpportunity.Id);

        Opportunity objOpportunity2 = OpportunityHelper.getOrCreateOpportunity(tourPayload, lstAccount[0].Id, lstContacts[0].Id, oppRec1.Id, lstBuilding[1]);
		System.assertEquals(oppRec1.Id, objOpportunity2.Id);

        Opportunity objOpportunity3 = OpportunityHelper.getOrCreateOpportunity(tourPayload, lstAccount[0].Id, lstContacts[1].Id, oppRec1.Id , lstBuilding[1]);
        System.assertEquals(oppRec1.Id, objOpportunity3.Id);
        Test.stopTest();
        //oppRec1 Id is given
        Opportunity objOpportunity4 = OpportunityHelper.getOrCreateOpportunity(tourPayload, lstAccount[0].Id, lstContacts[1].Id, oppRec1.Id , lstBuilding[1]);
        System.assertEquals(oppRec1.Id, objOpportunity4.Id);

        delete oppRec1;
        //Create new Opportunity
        Opportunity objOpportunity5 = OpportunityHelper.getOrCreateOpportunity(tourPayload, lstAccount[1].Id, lstContacts[1].Id, null , lstBuilding[1]);
        System.assertEquals(tourPayload.booked_by_contact_id, objOpportunity5.Tour_Booked_By__c);

     }

      /************************************************************************************************************************************
        Author              :   Priyanka Ambre
        Description         :   This test method is used to verify CreateOpportunity() when we pass Opportunity Record to the Method .
        Created Date  		:   27 June 2018
        Issue No			:	ST-
		Modified by			:	Ashish Mishra
		Modified date		:	06 July 2018
   ***************************************************************************************************************************************/
    static testMethod void verifyCreateOpportunity(){
        Profile systemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];

        Map<String,Object> userRecordMap1 = new Map<String,Object>();
        userRecordMap1.put('LastName','Last Name');
        userRecordMap1.put('Username','testweworkuserforSendPaperwork@example.com');
        userRecordMap1.put('Email','testweworkuserforSendPaperwork@example.com');
        userRecordMap1.put('IsActive',true);
        User testUser1 = TestingUtility.insertUserWithAssert(systemAdmin.Id, userRecordMap1, true);

        Map<String,Object> userRecordMap2 = new Map<String,Object>();
        userRecordMap2.put('LastName','Last Name1');
        userRecordMap2.put('Username','testweworkuserforSendPaperwork3@example.com');
        userRecordMap2.put('Email','testweworkuserforSendPaperwork3@example.com');
        userRecordMap2.put('IsActive',true);
        User testUser2 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap2, true);

        Opportunity objOppRec = new Opportunity(
            Do_Not_Create_Opportunity_Role__c=true,
            AccountId=lstAccount[0].Id,
            LeadSource='WeWork.com',
            Owner_Auto_Assign__c=true,
            StageName='Qualifying',
            Decision_Maker__c=null,
            Primary_Member__c=lstContacts[0].Id,
            Interested_in_Number_of_Desks__c=0,
            Building__c=lstBuilding[0].Id,
            CloseDate=system.today().addDays(5)
        );
        System.runAs(testUser1) {
            Opportunity objOppResponse =  OpportunityHelper.createOpportunity(objOppRec);
            System.debug('objOppResponse'+objOppResponse);
            System.assertEquals(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Consumer').getRecordTypeId(), objOppResponse.RecordTypeId);
            System.assertEquals(false, objOppResponse.Owner_Auto_Assign__c);
        }

    }
    /************************************************************************************************************************************
        Author              :   Jitesh Adwani
        Description         :   This test method is used to verify GetLatestOpenOpportunity() When we pass AccountId, ContactId, Bulding Details It will
								provide open opportunity according to given criteria.
        Created Date  		:   05 Sep 2018
        Issue No			:	ST-2743
		Modified by			:	Ashish Mishra
		Modified date		:	06 Sep 2018
   ***************************************************************************************************************************************/
    @isTest
    static void verifyGetLatestOpenOpportunity(){
        List<Building__c> lstBuilding = [SELECT Id, Name,Portfolio_Name__c,Cluster_Name__c FROM Building__c];
        List<Account> lstAccount = [SELECT Id, Name FROM Account];
        List<Contact> lstContact = [SELECT Id, Name FROM Contact];
    	List<Opportunity> lstOpportunity = [SELECT Id, Name, Building__c, Building__r.Name, Primary_Member__c FROM Opportunity];


        Test.startTest();
        //For Tour Building Portfolio Name
        Opportunity objOpportunity = OpportunityHelper.getLatestOpenOpportunity(lstAccount[0].Id, lstContact[0].Id, lstBuilding[0]);
        System.assertEquals(lstBuilding[0].Name, objOpportunity.Locations_Interested__c);
        System.assertEquals(lstOpportunity[0].Primary_Member__c, lstContact[0].Id);


        Account account = TestingUtility.createAccount('Master Account', false);
        TestingUtility.insertWithAssert(account);
        Contact contact = TestingUtility.createContact(account.Id,'Contact1',false);
        TestingUtility.insertWithAssert(contact);

        //For Tour Building Portfolio Name
        Opportunity oppRecord1 = TestingUtility.createOpportunity(account.Id, false);
        oppRecord1.Primary_Member__c = contact.Id;
        oppRecord1.StageName = 'Qualifying';
        oppRecord1.Building__c = lstBuilding[2].Id;
        oppRecord1.CloseDate = system.today().addDays(5);
        TestingUtility.insertWithAssert(oppRecord1);
        Opportunity objOpportunity2 = OpportunityHelper.getLatestOpenOpportunity(account.Id, contact.Id, lstBuilding[2]);
        System.assertEquals(objOpportunity2.Building__r.Portfolio_Name__c,lstBuilding[2].Portfolio_Name__c);

        //For Tour Building Cluster Name Criteria
        Opportunity oppRecord2 = TestingUtility.createOpportunity(account.Id, false);
        oppRecord2.Primary_Member__c = contact.Id;
        oppRecord2.StageName = 'Qualifying';
        oppRecord2.Building__c = lstBuilding[3].Id;
        oppRecord2.CloseDate = system.today().addDays(5);
        TestingUtility.insertWithAssert(oppRecord2);
        Opportunity objOpportunity3 = OpportunityHelper.getLatestOpenOpportunity(account.Id, contact.Id, lstBuilding[3]);
        Test.stopTest();
        System.assertEquals(objOpportunity3.Building__r.Cluster_Name__c,lstBuilding[3].Cluster_Name__c);
    }

    @isTest
    static void verifyGetLowerSize(){
        Integer companySize = OpportunityHelper.getLowerSize('1,000-2,000');
        Debug.log('companySize==>'+companySize);
        System.assertEquals(1000, companySize, 'Conpany Size is not match for "-" Separator');

        Integer companySize2 = OpportunityHelper.getLowerSize('1,000+2,000');
        Debug.log('companySize2==>'+companySize2);
        System.assertEquals(1000, companySize, 'Conpany Size is not match for "+" Separator');

        Integer companySize3 = OpportunityHelper.getLowerSize('1,000');
        Debug.log('companySize3==>'+companySize3);
        System.assertEquals(1000, companySize, 'Conpany Size is not match, remove comma');

        Integer companySize4 = OpportunityHelper.getLowerSize('');
        Debug.log('companySize4==>'+companySize4);
        System.assertEquals(0, 0, 'Conpany Size is not match for "-" Separator');
    }

    @isTest
    static void verifyGetUniquePickListValues(){
        String pickList ='test1;test2;test3';
        Set<String> newValues = new Set<String>();
        newValues.add('Picklist Value1');
        newValues.add('Picklist Value2');
        newValues.add('test1');
        Set<String> setPicklist = OpportunityHelper.getUniquePickListValues(pickList,newValues);
		System.assertEquals(5, setPicklist.size() , 'Size of picklist is not match with expected size');
    }

    @isTest
    static void verifyCreateOpportunityRole(){
        List<Building__c> lstBuilding = [SELECT Id, Name,Portfolio_Name__c,Cluster_Name__c FROM Building__c];
        List<Account> lstAccount = [SELECT Id, Name FROM Account];
        List<Contact> lstContact = [SELECT Id, Name FROM Contact];
    	List<Opportunity> lstOpportunity = [SELECT Id, Name, Building__c, Building__r.Name, Primary_Member__c FROM Opportunity];

        Opportunity_Role__c objOpportunityRole = OpportunityHelper.createOpportunityRole(lstOpportunity[0].id, lstContact[0].id, 'Main Contact');
		System.assertEquals('Main Contact', objOpportunityRole.Role__c, 'Opportunity Role is not match with as expected');
    }

    @isTest
    static void verifyCreateOpportunityWithContactId(){
        List<Building__c> lstBuilding = [SELECT Id, Name,Portfolio_Name__c,Cluster_Name__c FROM Building__c];
        List<Account> lstAccount = [SELECT Id, Name FROM Account];
        List<Contact> lstContact = [SELECT Id, Name FROM Contact];

        Opportunity objOpportunity = OpportunityHelper.createOpportunity(lstContact[0].id, 'Selling');
		System.assertEquals('Selling', objOpportunity.StageName, 'Opportunity linked stage is not match given');
    }

    /*****************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method is used to test valid team member for different building.
        Created Date        :   18 Feb 2019
	******************************************************************************************************************************************/
    public static testMethod void verifyGetvalidteamMemberForDifferentBuilding(){
        List<Account> lstAccount = new List<Account>([SELECT Id, OwnerId, UUID__c, RecordTypeId FROM Account]);
        List<Contact> lstContact = new List<Contact>([SELECT Id, FirstName, LastName, UUID__c, Email FROM Contact WHERE Email = 'testCommunitySalesLead@wework.com']);
        User objCommunityLead = [SELECT Id, Name, Email FROM User WHERE Email != '' LIMIT 1];
        List<Building__c> lstBuilding = [SELECT Id, City__c,  uuid__c, Name, Community_Sales_Lead__c, Community_Lead__c, Cluster__c, Cluster__r.Sales_Lead__c FROM Building__c WHERE Name LIKE '%TestMumbaiBuilding%'];
        System.assertEquals(lstBuilding.size(), 1);
        Test.startTest();

        Map<String, Object> mapData = new Map<String, Object>();
        Map<String, List<Object>> mapFieldForOpportunity = new Map<String, List<Object>>();

        mapFieldForOpportunity.put('Name', New List<Object>{'test oppty1', 'test oppty2'});
        mapFieldForOpportunity.put('StageName', New List<Object>{'Qualifying', 'Selling'});
        mapFieldForOpportunity.put('AccountId', new List<Object>{lstAccount[0].Id, lstAccount[0].Id});
        mapFieldForOpportunity.put('Referrer__c', new List<Object>{lstContact[0].Id, lstContact[0].Id});
        mapFieldForOpportunity.put('Building__c', new List<Object>{lstBuilding[0].Id, lstBuilding[0].Id});
        mapData.put('objName', 'Opportunity');
        mapData.put('numberOfRecords', 2);
        mapData.put('doInsert', true);
        mapData.put('mapFieldValues', mapFieldForOpportunity);
        List<Opportunity> lstOpportunities = TestingUtility.getRecords(mapData);
        Test.stopTest();
        OpportunityTeamMember objOppTeamMember = OpportunityHelper.getValidTeamMemberForDifferentBuilding(lstOpportunities[0], lstContact[0].Id);
        debug.log('objOppTeamMember: '+objOppTeamMember);
        System.assertNotEquals(Null, objOppTeamMember);
        System.assertEquals('Opp: Originating Rep', objOppTeamMember.TeamMemberRole);
        System.assertEquals(lstOpportunities[0].Id, objOppTeamMember.OpportunityId);
    }
}