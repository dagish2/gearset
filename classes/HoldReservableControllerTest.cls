/**
* Name			:	HoldReservableControllerTest 	
* Purpose		:	This contains the test methods for Hold Reservable Controller
*/
@isTest
public class HoldReservableControllerTest {
    @TestSetup 
    static void testDataSetup(){
        SalesConsoleSettings.createSettings();
        List<User> lstUsers = new List<User>();
        Map<String,Object> mapRecordValues = new Map<String,Object>();
        
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];
        
		mapRecordValues.put('Email','user1@example.com');
        lstUsers.add(TestingUtility.insertUserWithAssert(systemAdminProfile.Id, mapRecordValues, false));
        mapRecordValues.put('Email','user2@example.com');
        lstUsers.add(TestingUtility.insertUserWithAssert(systemAdminProfile.Id, mapRecordValues, false));
        mapRecordValues.put('Email','user3@example.com');
        lstUsers.add(TestingUtility.insertUserWithAssert(systemAdminProfile.Id, mapRecordValues, false));
        TestingUtility.insertListWithAssert(lstUsers);
        
        Id midMarketRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        Id enterprizeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        List<Account> lstAccounts = new List<Account>();
        Map<String,Object> mapAccountFieldValues = new Map<String,Object>();
        //Account 1
        mapAccountFieldValues.put('RecordTypeId', midMarketRecordTypeId);
        mapAccountFieldValues.put('Name','TestAcc1');
        lstAccounts.add(TestingUtility.createAccount(mapAccountFieldValues,false));
        
        //Account 2
        mapAccountFieldValues.put('RecordTypeId', enterprizeRecordTypeId);
        mapAccountFieldValues.put('Name','TestAcc2');
        mapAccountFieldValues.put('UUID__c', 'enterprize-0002-0002');
        lstAccounts.add(TestingUtility.createAccount(mapAccountFieldValues,false));
        
        //Account 3
        mapAccountFieldValues.remove('RecordTypeId');
        mapAccountFieldValues.put('Name','TestAcc3');
        mapAccountFieldValues.put('UUID__c', 'consumer-0003-0003');
        mapAccountFieldValues.put('OwnerId', lstUsers[0].Id);
        lstAccounts.add(TestingUtility.createAccount(mapAccountFieldValues,false));
        
        //Account 4
        mapAccountFieldValues.put('UUID__c', 'consumer-0004-0004');
        mapAccountFieldValues.put('Name','TestAcc4');
        mapAccountFieldValues.put('OwnerId', lstUsers[0].Id);
        mapAccountFieldValues.put('Account_Type__c', 'Org');
        lstAccounts.add(TestingUtility.createAccount(mapAccountFieldValues,false));
        
        //Inserting and assertion for accounts
        TestingUtility.insertListWithAssert(lstAccounts);
        
        List<Contact> lstContact = new List<Contact>();
        mapRecordValues.clear();
        mapRecordValues.put('LastName','Primary Contact');
        mapRecordValues.put('AccountId',lstAccounts[1].Id);
        mapRecordValues.put('UUID__c','test uuid 1');
        lstContact.add(TestingUtility.createContact(mapRecordValues, false));
        //Creation of Primary Member        
        TestingUtility.insertListWithAssert(lstContact);
        TestingUtility.upsertWithAssert(new Account(Id=lstAccounts[1].Id,Primary_Member__c=lstContact[0].Id));
        
        Map<String,Object> mapBuildingsFieldValues = new Map<String,Object>();
        
        List<Building__c> lstBuildings = new List<Building__c>();
        mapBuildingsFieldValues.put('Name','Test Building 1');
        mapBuildingsFieldValues.put('UUID__c','building-0001-0001');
        lstBuildings.add(TestingUtility.createBuilding(mapBuildingsFieldValues, false));
        mapBuildingsFieldValues.put('Name','Test Building 2');
        mapBuildingsFieldValues.put('UUID__c','building-0002-0002');
        lstBuildings.add(TestingUtility.createBuilding(mapBuildingsFieldValues, false));
        TestingUtility.insertListWithAssert(lstBuildings);
        
        opportunityDataForTesting(lstAccounts, lstBuildings, lstUsers);
        
        Reservable__c objReservable = new Reservable__c(
            Building__c = lstBuildings[0].Id,
            Name = 'Residential Unit-1015163',
            Monthly_Price__c = 50,
            UUID__c = 'reservable-0001-0001',
            Office_Work_Station_Type__c = 'Office');
        insert objReservable;
        
        Reservable_Hold__c newReservableHold = new Reservable_Hold__c();
        newReservableHold.Company_UUID__c = lstAccounts[1].UUID__c;
        newReservableHold.Reservable_UUID__c =  'reservable-0001-0001';
        newReservableHold.expires_at__c = system.today().addDays(5);
        newReservableHold.CurrencyIsoCode = 'USD';
        newReservableHold.UUID__c = 'reservable-uuid-0001-0001';
        newReservableHold.Approval_Status__c = 'hold';
        newReservableHold.contact_uuid__c = 'test uuid 1';
        TestingUtility.insertWithAssert(newReservableHold);
    }
    
    public static void opportunityDataForTesting(List<Account> lstAccounts, List<Building__c> lstBuildings, List<User> lstUsers){
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        Map<String,Object> mapOpportunityRecord = new Map<String,Object>();
        //Opportunity 1
        mapOpportunityRecord.put('StageName', 'Selling');
        mapOpportunityRecord.put('CloseDate', system.today().addDays(5));
        mapOpportunityRecord.put('AccountId', lstAccounts[1].Id);
        mapOpportunityRecord.put('Membership_Agreement_Notes__c', 'Opportunity Membership Agreement Notes');
        mapOpportunityRecord.put('Tour_Notes__c', 'Opportunity Tour Notes');
        mapOpportunityRecord.put('Tour_Outcome_Notes__c', 'Tour Outcome Notes');
        mapOpportunityRecord.put('Description', 'Opprtunity Description');
        mapOpportunityRecord.put('Locations_Interested__c', lstBuildings[0]+';'+lstBuildings[1]);
        mapOpportunityRecord.put('Owner_Auto_Assign__c', true);
        mapOpportunityRecord.put('Contract_UUID__c', 'opp01-contract1-0001');
        lstOpportunities.add(TestingUtility.createOpportunity(mapOpportunityRecord, false));
        
        //Opportunity 2
        mapOpportunityRecord.put('Contract_UUID__c', 'opp02-contract2-0002');
        lstOpportunities.add(TestingUtility.createOpportunity(mapOpportunityRecord, false));
        
       	//Opportunity 3 with Closed Lost
       	mapOpportunityRecord.put('StageName', 'Closed Lost');
        mapOpportunityRecord.put('Contract_UUID__c', 'opp03-contract3-0003');
        lstOpportunities.add(TestingUtility.createOpportunity(mapOpportunityRecord, false));
        
        //Opportunity 4 with Selling
       	mapOpportunityRecord.put('StageName', 'Selling');
        mapOpportunityRecord.put('Contract_UUID__c', 'opp04-contract4-0004');
        mapOpportunityRecord.put('AccountId', lstAccounts[2].Id);
        mapOpportunityRecord.put('OwnerId', lstUsers[0].Id);        
        lstOpportunities.add(TestingUtility.createOpportunity(mapOpportunityRecord, false));
        
        //Opportunity 5 with Selling
       	mapOpportunityRecord.put('StageName', 'Selling');
        mapOpportunityRecord.put('Contract_UUID__c', 'opp05-contract5-0005');
        mapOpportunityRecord.put('AccountId', lstAccounts[3].Id);
       // mapOpportunityRecord.put('OwnerId', lstUsers[0].Id);
        mapOpportunityRecord.put('Type__c','PxWe');
        lstOpportunities.add(TestingUtility.createOpportunity(mapOpportunityRecord, false));
        
        //Opportunity 6 with Closed Lost
        mapOpportunityRecord.put('StageName', 'Closed Lost');
        mapOpportunityRecord.put('Contract_UUID__c', 'opp06-contract6-0006');
        lstOpportunities.add(TestingUtility.createOpportunity(mapOpportunityRecord, false));
  
        //Inserting Opportunities
        TestingUtility.insertListWithAssert(lstOpportunities);
    }
    /********************************************************************
		Name : testIsValidHold
		Description : Test method to validate isVaildHold method
		Last Modified By : Rupesh Patil
		Last Modified Date : 28/08/2018
	************************************************************************/
    static testMethod void testIsValidHold(){
        Set<String> setContractUUID = new Set<String>{'opp01-contract1-0001','opp02-contract2-0002','opp03-contract3-0003','opp04-contract4-0004','opp05-contract5-0005','opp06-contract6-0006'};
        List<Opportunity> lstOpportunity = new List<Opportunity>([SELECT Id,Contract_UUID__c,Owner.Id FROM opportunity WHERE Contract_UUID__c IN: setContractUUID]);
        
        Test.startTest();
        debug.Log('lstOpportunity in testIsValidHold'+lstOpportunity);
        string result = HoldReservableController.isValidHoldLightning(lstOpportunity[0].id);
        ValidHoldResultWithOppp Data = (ValidHoldResultWithOppp)JSON.deserialize(result, ValidHoldResultWithOppp.class);
        
        result = HoldReservableController.isValidHoldLightning(lstOpportunity[1].id);
        Data = (ValidHoldResultWithOppp)JSON.deserialize(result, ValidHoldResultWithOppp.class);
        System.assertEquals(true,Data.isValidHold);
        
        result = HoldReservableController.isValidHoldLightning(lstOpportunity[2].id);
        Data = (ValidHoldResultWithOppp)JSON.deserialize(result, ValidHoldResultWithOppp.class);
        System.assertEquals(false,Data.isValidHold);
        
        result= HoldReservableController.isValidHoldLightning(lstOpportunity[3].id);           
        Data = (ValidHoldResultWithOppp)JSON.deserialize(result, ValidHoldResultWithOppp.class);        
        System.assertEquals(false, Data.isValidHold);
		System.assertEquals('Only Opportunity Owner Or Opportunity Team Member Can do Reservable Hold',Data.errorMsg,'lstOpportunity[3].id is changed and not the current user id');  
        
        result= HoldReservableController.isValidHoldLightning(lstOpportunity[4].id); 
        Data = (ValidHoldResultWithOppp)JSON.deserialize(result, ValidHoldResultWithOppp.class);
        System.assertEquals(false,Data.isValidHold);
        System.assertEquals('Opportunity Product Type should be \'WeWork\'.', Data.errorMsg);
        
        delete lstOpportunity[5];
        result= HoldReservableController.isValidHoldLightning(lstOpportunity[5].id); 
        Data = (ValidHoldResultWithOppp)JSON.deserialize(result, ValidHoldResultWithOppp.class);
        System.assertEquals(false,Data.isValidHold);
        String errorMsg = 'Opportunity not found with Id '+lstOpportunity[5].id+'.'; 
        System.assertEquals(errorMsg, Data.errorMsg);
        
        Test.stopTest();
    }
    
    static testMethod void testHoldoff(){
        Reservable_Hold__c holdRecord = [SELECT Id FROM Reservable_Hold__c WHERE Reservable_UUID__c = 'reservable-0001-0001'];
        String sourcePage = 'salesforce_reservable_hold';
        Test.setMock(HttpCalloutMock.class, new ReservableHoldMock());
        Test.startTest();
        String response = HoldReservableController.holdOffReservableLightning(holdRecord.Id,sourcePage);
        Test.stopTest();
        system.assertNotEquals(null, response);
    }
    
    public static testMethod void verifyInitialize() {
        Opportunity Opportunity = [Select Id,Contract_UUID__c from opportunity where Contract_UUID__c = 'opp01-contract1-0001'];
        DatabaseResult response = HoldReservableController.initialize(Opportunity.Id);
        system.assertNotEquals(null, response);
    }
    
    public class ValidHoldResultWithOppp{
        public Boolean isValidHold {get;set;}
        public string errorMsg {get;set;}
        public Opportunity objOpportunity {get;set;}
        public List<String> opportunityBuildings {get;set;}
    }
}