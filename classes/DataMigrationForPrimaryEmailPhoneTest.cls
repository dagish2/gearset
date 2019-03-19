@isTest
public class DataMigrationForPrimaryEmailPhoneTest {
	static Boolean settingsInitialized = false;
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
    }
    public static testMethod void verifyBatch(){
        List<Journey__c> lstjourneys = new List<Journey__c>();
        List<Contact> lstContacts = new List<Contact>();
        List<Lead> lstLeads = new List<Lead>();
        
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        Contact conRec1 = new Contact(
            firstname = 'Paul',
            lastname = 'Rambo',
            email = 'testcontact1@example.com',
            accountID = accRec.Id,
            Status__c = 'active',
            Phone = '1234567890'
        );
        lstContacts.add(conRec1);
        
        Contact conRec2 = new Contact(
            firstname = 'Paul',
            lastname = 'Rambo',
            email = 'testcontact2@example.com',
            accountID = accRec.Id,
            Status__c = 'active'
        );
        lstContacts.add(conRec2);
        insert lstContacts;
        
        Lead lead1 = new lead();
        lead1.LastName = 'Test 1';
        lead1.Company = 'test company';
        lead1.Phone = '1234567890';
        lead1.Email = 'test1@exapmle.com';
        lstLeads.add(lead1);
        
        Lead lead2 = new lead();
        lead2.LastName = 'Test 1';
        lead2.Company = 'test company';
        lead2.Email = 'test2@exapmle.com';
        lstLeads.add(lead2);
        
        Lead lead3 = new lead();
        lead3.LastName = 'Test 1';
        lead3.Company = 'test company';
        lead3.Phone = '1234567890';
        lead3.Email = 'test3@exapmle.com';
        lstLeads.add(lead3);
        insert lstLeads;
		
        Journey__c newTestJourney1 = new Journey__c();
        newTestJourney1.Name = 'Test 1';
        newTestJourney1.Status__c = 'Started';
        newTestJourney1.Primary_Contact__c = lstContacts[0].Id;
        newTestJourney1.Count_of_Desk__c = 90;
        newTestJourney1.NMD_Next_Contact_Date__c = Date.today();
        lstjourneys.add(newTestJourney1);
        
        Journey__c newTestJourney2 = new Journey__c();
        newTestJourney2.Name = 'Test 2';
        newTestJourney2.Status__c = 'Started';
        newTestJourney2.Primary_Contact__c = lstContacts[1].Id;
        newTestJourney2.Count_of_Desk__c = 90;
        newTestJourney2.NMD_Next_Contact_Date__c = Date.today();
        lstjourneys.add(newTestJourney2);
        
        Journey__c newTestJourney3 = new Journey__c();
        newTestJourney3.Name = 'Test 3';
        newTestJourney3.Status__c = 'Started';
        newTestJourney3.Primary_Lead__c = lstLeads[0].Id;
        newTestJourney3.Count_of_Desk__c = 90;
        newTestJourney3.NMD_Next_Contact_Date__c = Date.today();
        lstjourneys.add(newTestJourney3);
        
        Journey__c newTestJourney4 = new Journey__c();
        newTestJourney4.Name = 'Test 4';
        newTestJourney4.Status__c = 'Started';
        newTestJourney4.Primary_Lead__c = lstLeads[1].Id;
        newTestJourney4.Count_of_Desk__c = 90;
        newTestJourney4.NMD_Next_Contact_Date__c = Date.today();
        lstjourneys.add(newTestJourney4);
        
        Journey__c newTestJourney5 = new Journey__c();
        newTestJourney5.Name = 'Test 5';
        newTestJourney5.Status__c = 'Started';
        newTestJourney5.Primary_Lead__c = lstLeads[2].Id;
        newTestJourney5.Count_of_Desk__c = 90;
        newTestJourney5.NMD_Next_Contact_Date__c = Date.today();
        lstjourneys.add(newTestJourney5);
        insert lstjourneys;
        
        Test.startTest();
        Database.executeBatch(new DataMigrationForPrimaryEmailPhone());
        Test.stopTest();
        
        Journey__c objJourney = [select Id, Primary_Email__c, Primary_Phone__c FROM Journey__c where Id =: lstjourneys[0].Id];
        system.assertEquals(conRec1.Email, objJourney.Primary_Email__c);
        system.assertEquals(conRec1.Phone, objJourney.Primary_Phone__c);
        
        objJourney = [select Id, Primary_Email__c, Primary_Phone__c FROM Journey__c where Id =: lstjourneys[1].Id];
        system.assertEquals(conRec2.Phone, objJourney.Primary_Phone__c);
        
        
        objJourney = [select Id, Primary_Email__c, Primary_Phone__c FROM Journey__c where Id =: lstjourneys[2].Id];
        system.assertEquals(lead1.Email, objJourney.Primary_Email__c);
        system.assertEquals(lead1.Phone, objJourney.Primary_Phone__c);
        
        objJourney = [select Id, Primary_Email__c, Primary_Phone__c FROM Journey__c where Id =: lstjourneys[3].Id];
        system.assertEquals(lead2.Email, objJourney.Primary_Email__c);
        
        objJourney = [select Id, Primary_Email__c, Primary_Phone__c FROM Journey__c where Id =: lstjourneys[4].Id];
    	system.assertEquals(lead3.Phone, objJourney.Primary_Phone__c);
    }
}