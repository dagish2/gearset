@isTest
public class CommunityViewHelperTests {
    @TestSetup 
    static void testDataSetup(){
        SalesConsoleSettings.createSettings();
        Test.startTest();
        List<Tour_Outcome__c> lstTours = (List<Tour_Outcome__c>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Tour', 'numberOfRecords' => 4});
        Test.stopTest();
        Map<String,Object> mapRecordValues = new Map<String,Object>();
        List<Account> lstAccounts = new List<Account>();
        Map<String,Object> mapAccountFieldValues = new Map<String,Object>();
        
        //Lead
		List<Lead> lstLead = new List<Lead>();
        Lead objLead1 = new Lead(LastName='TestLead1',Email='TestLead1@example.com',Company='TestLead1');
        lstLead.add(objLead1);
        Lead objLead2 = new Lead(LastName='TestLead2',Email='TestLead2@wework.com',Company='TestLead2');
        lstLead.add(objLead2);
        TestingUtility.insertListWithAssert(lstLead);
        
        //Account 1
        mapAccountFieldValues.put('Name', 'Test Org 1');
        mapAccountFieldValues.put('Account_Type__c', 'Org');
        lstAccounts.add(TestingUtility.createAccount(mapAccountFieldValues,false));
        mapRecordValues.clear();
        
        //Account 2
        mapAccountFieldValues.put('Name', 'Test Org 2');
        mapAccountFieldValues.put('Account_Type__c', 'Org');
        lstAccounts.add(TestingUtility.createAccount(mapAccountFieldValues,false));
        mapRecordValues.clear();
        
        TestingUtility.insertListWithAssert(lstAccounts);
        //Building 
        mapRecordValues.put('Name','Enzigma');
        mapRecordValues.put('CurrencyIsoCode','INR');
        mapRecordValues.put('Address__c','Banner');
        mapRecordValues.put('City__c','Pune');
        mapRecordValues.put('UUID__c','4eb8144b-f461-4849-8b81-b5fa344fb978');
        TestingUtility.createBuilding(mapRecordValues, true);

        //Contact
        List<Contact> lstContact = new List<Contact>();
        mapRecordValues.clear();
        mapRecordValues.put('LastName','Primary Contact');
        mapRecordValues.put('AccountId',lstAccounts[0].Id);
        lstContact.add(TestingUtility.createContact(mapRecordValues, false));
        
        //Creation of Primary Member        
        TestingUtility.insertListWithAssert(lstContact);
        TestingUtility.upsertWithAssert(new Account(Id=lstAccounts[1].Id,Primary_Member__c=lstContact[0].Id));
        mapRecordValues.clear();
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        List<Account> lstAccount = [SELECT Id,Name FROM Account];
        List<Contact> lstContacts = [SELECT Id,Name FROM Contact];
        List<Building__c> lstBuilding = [SELECT Id,Name FROM Building__c WHERE UUID__c = '4eb8144b-f461-4849-8b81-b5fa344fb978'];
        
        //Opportunity 1
        mapRecordValues.put('Name', 'Test Opp 2');
        mapRecordValues.put('StageName', 'Selling');
        mapRecordValues.put('CloseDate', system.today().addDays(5));
        mapRecordValues.put('AccountId', lstAccount[0].Id);
        mapRecordValues.put('Primary_Member__c', lstContacts[0].Id);
        mapRecordValues.put('Locations_Interested__c', lstBuilding[0].Id);
        lstOpportunities.add(TestingUtility.createOpportunity(mapRecordValues, false));
        mapRecordValues.clear();
        //Opportunity 2
        mapRecordValues.put('Name', 'Test Opp 1');
        mapRecordValues.put('AccountId', lstAccount[1].Id);
        mapRecordValues.put('StageName', 'Qualifying');
        mapRecordValues.put('CloseDate', system.today());
        mapRecordValues.put('Locations_Interested__c', lstBuilding[0].Id);
        mapRecordValues.put('Primary_Member__c', lstContacts[0].Id);
        lstOpportunities.add(TestingUtility.createOpportunity(mapRecordValues, false));
        TestingUtility.insertListWithAssert(lstOpportunities);
        mapRecordValues.clear();
        
        //User
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        List<Building__c> lstBuildingData = [SELECT Id, Name, uuid__c FROM Building__c WHERE UUID__c = '4eb8144b-f461-4849-8b81-b5fa344fb978'];
        mapRecordValues.put('LastName', 'Test User');
        mapRecordValues.put('Username', 'testuserjohn123@example.com');
        mapRecordValues.put('Email', 'testuserjohn@example.com');
        mapRecordValues.put('CommunitynickName', 'test333' +System.now());
        mapRecordValues.put('Community_View_Building__c', lstBuildingData[0].Id);
        TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, mapRecordValues, true);
    }
/************************************************************************************************************************************
        Author              :   Jitesh Adwani
        Description         :   This method is used to test createOpportunityForCommunityView().
        Issue No.           :   --
        Last Modified Date  :   22 May 2018
**************************************************************************************************************************************/
    public static testMethod void verifyGetCommunityViewData(){
		List<Building__c> lstBuilding = [SELECT Id,Name,uuid__c FROM Building__c WHERE UUID__c = '4eb8144b-f461-4849-8b81-b5fa344fb978'];
        Debug.log('lstBuilding===>'+lstBuilding); 
        String startDate = '2018-02-19';
        String endDate = '2018-05-22';
        String selectedStatus = 'Scheduled';
        List<Account> lstAccount = [SELECT Id,Name FROM Account];
        System.assert(lstAccount[0].Id != null);
        List<Contact> lstContact = [SELECT Id,Name FROM Contact];
        System.assert(lstContact[0].Id != null);
        DatabaseResult result = CommunityViewHelper.getOnLoadCommunityViewData(startDate, endDate, selectedStatus, lstContact[0].Id, lstContact[0].Id, lstBuilding[0].Id, lstAccount[0].Id);
        System.assertEquals(True, result.success);
        System.assertNOTEquals(null, result.data);
    }
/************************************************************************************************************************************
        Author              :   Jitesh Adwani
        Description         :   This method is used to test createOpportunityForCommunityView().
        Issue No.           :   --
        Last Modified Date  :   22 May 2018
**************************************************************************************************************************************/  
    public static testMethod void verifyCreateOpportunityForCommunityView(){
        List<Contact> lstContact = [Select Id,Name From Contact];
        System.assert(lstContact[0].Id != null);
        List<Building__c> lstBuilding = [SELECT Id,Name FROM Building__c WHERE UUID__c = '4eb8144b-f461-4849-8b81-b5fa344fb978'];
        System.assert(lstBuilding[0].Id != null);
        Object noOfDesks = 20;
        DatabaseResult result = CommunityViewHelper.createOpportunityForCommunityView(lstContact[0].Id, noOfDesks, lstBuilding[0].Id);
        System.assertNOTEquals(null, result.data);
        String resultStr = (String)result.data;       
        System.assertEquals(True, result.success);
    }
/************************************************************************************************************************************
        Author              :   Jitesh Adwani
        Description         :   This method is used to test createAccountOppContactCommunityView().
        Issue No.           :   --
        Last Modified Date  :   22 May 2018
**************************************************************************************************************************************/ 
    public static testMethod void verifyCreateAccountOppContactCommunityView(){
        Map<String, String> mapStringData = new Map<String, String>();
        mapStringData.put('AccountName', 'John Smith');
        mapStringData.put('account_uuid','be1d189e-ad09-4081-9432-6ea3cf1f21f2');
        mapStringData.put('FirstName','John');
        mapStringData.put('LastName','Smith');
        mapStringData.put('Email','john.smith220501@example.com');
        mapStringData.put('Phone','1234567890');
        mapStringData.put('user_uuid','661fa18a-17d5-4ea1-9ffd-9088dab2c7be');
        mapStringData.put('buildingId','a003D000001Lc1b');
        DatabaseResult result = CommunityViewHelper.createAccountOppContactCommunityView(mapStringData);
        System.assertEquals(True, result.success);
        System.assertNOTEquals(null, result.data);
    }
/************************************************************************************************************************************
        Author              :   Jitesh Adwani
        Description         :   This method is used to test getTourRelatedData().
        Issue No.           :   --
        Last Modified Date  :   22 May 2018
**************************************************************************************************************************************/
    public static testMethod void verifyGetTourRelatedData(){
        String startDate = '2018-05-18';
        String endDate = '2018-05-20';
        String selectedStatus = 'Scheduled';
        
        List<Building__c> lstBuilding = [SELECT Id,Name FROM Building__c WHERE UUID__c = '4eb8144b-f461-4849-8b81-b5fa344fb978'];
        System.assert(lstBuilding[0].Id != null);
        List<Account> lstAccount = [SELECT Id,Name FROM Account];
        System.assert(lstAccount[0].Id != null);
        List<Contact> lstContact = [SELECT Id,Name FROM Contact];
        System.assert(lstContact[0].Id != null);
        DatabaseResult result = CommunityViewHelper.getTourRelatedData(startDate,endDate ,selectedStatus,lstContact[0].Id,lstContact[0].Id,lstBuilding[0].Id,lstAccount[0].Id);
        Debug.log('result.data--->'+result.data);
    }
    
/************************************************************************************************************************************
        Author              :   Rohit Nimase
        Description         :   This method is used to test communityViewSOQL method.
        Issue No.           :   STL-127
        Last Modified Date  :   7 Feb 2019
**************************************************************************************************************************************/
    public static testMethod void verifyCommunityViewSOQL(){
        List<Tour_Outcome__c> lstTours = [SELECT Id, Name FROM Tour_Outcome__c LIMIT 3];
        string soqlLabel = 'label1';
		Map<String, Object> mapDatamapData = new Map<String, Object>();
        mapDatamapData.put('UUID__c', lstTours[0].id);
        
        DatabaseResult returnedQuery = CommunityViewHelper.communityViewSOQL(soqlLabel, mapDatamapData);
        System.assertNotEquals(null, returnedQuery.data);
    }
    
/************************************************************************************************************************************
        Author              :   Rohit Nimase
        Description         :   This method is used to test getOpportunityRecord method.
        Issue No.           :   STL-127
        Last Modified Date  :   7 Feb 2019
**************************************************************************************************************************************/
    public static testMethod void verifygetOpportunityRecord(){
        List<Building__c> lstBuilding = [SELECT Id,Name FROM Building__c WHERE UUID__c = '4eb8144b-f461-4849-8b81-b5fa344fb978'];
        System.assert(lstBuilding[0].Id != null);
        List<Lead> lstleadData = [SELECT Id, FirstName, Interested_in_Number_of_Desks_Min__c, Interested_in_Number_of_Desks__c, LastName, Name, Product_Line__c, OwnerId, Email_Domain__c, Company, Account__c, Account__r.Account_Type__c, Referrer__c, Cleansed_Unomy_Company_Name__c, Cleansed_Company_Name__c, Email, Unomy_Company_ID__c, Unomy_Company_Name__c, LeadSource, Lead_Source_Detail__c, Generate_Journey__c, By_Pass_Journey_Creation_Criteria__c, Campaign_Id__c, Building_Interested_In__c, Building_Interested_In__r.City__c, Locations_Interested__c, Number_of_Full_Time_Employees__c, Company_Size__c, Markets_Interested__c FROM Lead WHERE Email = 'TestLead1@example.com' AND IsConverted = false];
        if(lstleadData.size() > 0){
            Map<String,Map<String,Id>> mapConvertedLead  =  LeadConverterHelper.convertLeadWithTour(lstleadData[0]);
            Map<String,Id> mapLeadData = mapConvertedLead.get(lstleadData[0].email);
        	DatabaseResult objOpportunity = CommunityViewHelper.getOpportunityRecord(mapLeadData, lstBuilding[0].Id);
            System.assertNotEquals(null, objOpportunity.data);
            Map<String, Object> resultMapData = (Map<String, Object>)objOpportunity.data;
            System.assertNotEquals(null, resultMapData.get('contact'));
            System.assertNotEquals(null, resultMapData.get('opportunity'));
        }
    }
     
/************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method is used to test convertLeadForSendPaperWork().
        Issue No.           :   CSI-1105
        Last Modified Date  :   10 Aug 2018
**************************************************************************************************************************************/
    public static testMethod void verifyconvertLeadForSendPaperWork(){
        List<Lead> lstLead = [Select Id, Name From Lead WHERE Email = 'TestLead1@example.com'];
        List<Building__c> lstBuilding = [SELECT Id,Name FROM Building__c WHERE UUID__c = '4eb8144b-f461-4849-8b81-b5fa344fb978'];
        System.assert(lstBuilding[0].Id != null);
        Opportunity result = CommunityViewHelper.convertLeadForSendPaperWork(lstLead[0].Id,lstBuilding[0].Id);
        System.assert(result.Id != null, 'Lead not Converted');
    }
    
/************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method is used to test convertLeadForSendPaperWork().
        Issue No.           :   CSI-1105
        Last Modified Date  :   10 Aug 2018
**************************************************************************************************************************************/
    public static testMethod void verifyconvertLeadForSendPaperWorkWoOrgMatch(){
        List<Lead> lstLead = [SELECT Id, Name FROM Lead WHERE Email = 'TestLead2@wework.com'];
        List<Building__c> lstBuilding = [SELECT Id, Name FROM Building__c WHERE UUID__c = '4eb8144b-f461-4849-8b81-b5fa344fb978'];
        System.assert(lstBuilding[0].Id != null);
        test.startTest();
        Opportunity result = CommunityViewHelper.convertLeadForSendPaperWork(lstLead[0].Id,lstBuilding[0].Id);
        test.stopTest();
        System.assert(result.Id != null, 'Lead not Converted');
    }
    
/************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method is used to test convertLeadsToExistingAccountandOpportunity().
        Issue No.           :   ST-2722
        Last Modified Date  :   31 Aug 2018
**************************************************************************************************************************************/
    public static testMethod void verifyconvertLeadsToExistingAccountandOpportunity(){
        List<Lead> lstLead = [SELECT Id, Name, Email, Number_of_Full_Time_Employees__c FROM Lead WHERE Email = 'TestLead2@wework.com'];
        List<Building__c> lstBuilding = [SELECT Id,Name FROM Building__c WHERE UUID__c = '4eb8144b-f461-4849-8b81-b5fa344fb978'];
        System.assert(lstBuilding[0].Id != null);
        test.startTest();
        DatabaseResult result = CommunityViewHelper.convertLeadsToExistingAccountandOpportunity(lstLead[0],lstBuilding[0].Id);
        System.assert(result.data != null, 'Lead not Converted');
        test.stopTest();
        DatabaseResult noResult = CommunityViewHelper.convertLeadsToExistingAccountandOpportunity(null, lstBuilding[0].Id);
        System.assertEquals(null, noResult.data);
    }
        
/************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method is used to test SelectedBuildingTourRelatedData().
        Issue No.           :   CSI-1163
        Last Modified Date  :   31 Aug 2018
**************************************************************************************************************************************/
    public static testMethod void verifyGetSelectedBuildingTourRelatedData(){
        List<Building__c> lstBuilding = [SELECT Id,Name FROM Building__c WHERE UUID__c = '4eb8144b-f461-4849-8b81-b5fa344fb978'];
        DatabaseResult result = CommunityViewHelper.getSelectedBuildingTourRelatedDataAndUpdateUser(lstBuilding[0].Id);
        System.assert(result.data != null,'Selected builing Data Not Available');
    }
    
/************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method is used to test verifyGetBuildingRelatedData().
        Issue No.           :   CSI-1163
        Last Modified Date  :   31 Aug 2018
**************************************************************************************************************************************/
    public static testMethod void verifyGetBuildingRelatedData(){
        User objUser = [SELECT Id, Name FROM User WHERE Email =: 'testuserjohn@example.com'];
        System.runAs(objUser) {
            List<Building__c> lstBuilding = [SELECT Id,Name FROM Building__c WHERE UUID__c = '4eb8144b-f461-4849-8b81-b5fa344fb978'];
            List<Building__c> lstBuildingData = CommunityViewHelper.getBuildingRelatedData(lstBuilding[0].Id);
            System.assert(lstBuildingData.size() > 0,'Selected builing Data Not Available');
            List<Building__c> lstBuildingData2 = CommunityViewHelper.getBuildingRelatedData('');
            //System.assert(lstBuildingData2.size() > 0,'Selected builing Data Not Available');
            List<Building__c> lstBuildingData3 = CommunityViewHelper.getBuildingRelatedData('4eb8144b-f461-4849-8b81-b5fa344fb978');
            System.assert(lstBuildingData3.size() > 0,'Selected builing Data Not Available');
        }
    }
    
/************************************************************************************************************************************
        Author              :   Prashant Mane
        Description         :   This method is used to test verifyCalculateThisWeekEndDate().
        Issue No.           :   --
        Last Modified Date  :   22 May 2018
**************************************************************************************************************************************/
    public static testMethod void verifyCalculateThisWeekEndDate(){
        for(Integer index = 1; index < 8; index++){
            Date objDate = System.today();
			CommunityViewHelper.calculateThisWeekEndDate(objDate.addDays(index));
        }
    }
    
    /* 
        Scenario: Unit test for this specific function.
					Updating SAPI with new assigned host.
        
        Expected: Assert we got a valid response from the mock.
    */

	static testMethod void testUpdateSapiWithNewAssignedHost()
	{
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id userId = [Select Id From User limit 1].Id;
        string buildingUUID = '4eb8144b-f461-4849-8b81-b5fa344fb978';
        DatabaseResult result = CommunityViewHelper.updateSapiWithNewAssignedHost(buildingUUID, userId);
        Test.stopTest();
        
        //Assert we got a valid response from the mock and the functions returns success.
        system.assertEquals(result.success, true);
    }
}