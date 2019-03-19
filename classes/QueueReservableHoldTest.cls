@isTest
public class QueueReservableHoldTest {
	static{
         SalesConsoleSettings.createSettings();
    }
    public static testMethod void testReservableHoldQueue(){
        List<Account> lstAccounts = new List<Account>();
        Account accRec = TestingUtility.createAccount('strAccountName', false);
        accRec.UUID__c = '123456789';
        //accRec.Primary_Member__c=conRec.Id;
        accRec.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
      	lstAccounts.add(accRec);    
        
        Account accRec2 = new Account();
        accRec2.Name = 'strAccountName1';
        //accRec2.Primary_Member__c=conRec1.Id;
        accRec2.UUID__c = '123456781';
        accRec2.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        lstAccounts.add(accRec2);
        
        Account accRec3 = new Account();
        accRec3.Name = 'strAccountName2';
        //accRec3.Primary_Member__c=conRec2.Id;
        accRec3.UUID__c = '123456782';
        lstAccounts.add(accRec3);
        insert lstAccounts;        
        
        List<Contact> lstContacts = new List<Contact>();
        Contact conRec = new Contact(firstname = 'John',lastname = 'Rambo',email = 'test@example.com',Status__c = 'active', UUID__c='contact1uuid');
        lstContacts.add(conRec);
        Contact conRec1 = new Contact(firstname = 'John1',lastname = 'Rambo2',email = 'test2@example.com', Status__c = 'active');
        lstContacts.add(conRec1);
        Contact conRec2 = new Contact(firstname = 'John1',lastname = 'Rambo2',email = 'test23@example.com',AccountId = accRec3.Id  ,Status__c = 'active',UUID__c='contact3uuid');
        lstContacts.add(conRec2);
        insert lstContacts;
        
        Building__c building1 = new Building__c(
            Name='Test1',
            uuid__c = 'abc123'
        );
        insert building1;
        System.assertNotEquals(null, building1.Id);
        
        Building__c building2 = new Building__c(
            Name='Test2',
            uuid__c = 'abc1234'
        );
        insert building2;
        
         Test.startTest();     
        
        System.assertNotEquals(null, building2.Id);
        Opportunity oppRecForConsumer = TestingUtility.createOpportunity(accRec3.Id, false);
        oppRecForConsumer.Primary_Member__c = conRec1.Id;
        oppRecForConsumer.StageName = 'Selling';
        oppRecForConsumer.CloseDate = system.today().addDays(5);
        oppRecForConsumer.Membership_Agreement_Notes__c = 'Opprtunity 1 Membership_Agreement_Notes__c';
        oppRecForConsumer.Tour_Notes__c = 'Opprtunity 1 Tour_Notes__c';        
        oppRecForConsumer.Tour_Outcome_Notes__c = 'Opprtunity 1 Tour_Notes__c';
        oppRecForConsumer.Description = 'Opprtunity 1 Tour_Notes__c';
        oppRecForConsumer.Locations_Interested__c = building1.Name+';'+building2.Name;
        oppRecForConsumer.Owner_Auto_Assign__c = true;
        debug.Log('Before insert oppRecForConsumer' + oppRecForConsumer);
        TestingUtility.insertWithAssert(oppRecForConsumer);
        
        Building__c building = new Building__c();
       	building.Name = 'Test Square';
        building.City__c = 'Newyork City';
        TestingUtility.insertWithAssert(building);
        
        Reservable__c residentialUnit1 = new Reservable__c();
        residentialUnit1.Building__c = building.Id;
        residentialUnit1.Name = 'Residential Unit-101';
        residentialUnit1.Monthly_Price__c = 50;
        residentialUnit1.UUID__c = '4f65bbe3-3997-4f9b-b3b6-54535f8247d6';
        TestingUtility.insertWithAssert(residentialUnit1);
        
        Reservable_Hold__c newHold = new Reservable_Hold__c();
        newHold.Company_UUID__c = accRec.UUID__c;
        newHold.Reservable_UUID__c =  residentialUnit1.UUID__c;
        newHold.expires_at__c = system.today().addDays(5);
        newHold.CurrencyIsoCode = 'USD';
        newHold.Approval_Status__c = 'hold';
        newHold.UUID__c = 'adasfda';
        newHold.Contact_UUID__c = conRec2.UUID__c;
        insert newHold;
        
        newHold.Approval_Status__c = 'released';
        update newHold;
        
          
       // newHold.Approval_Status__c = 'rejected';
        //update newHold;
        
        List<Reservable_Hold__c> lstHold = new List<Reservable_Hold__c>();
        lstHold.add(newHold);
        Map<Id,Reservable_Hold__c> mapHold = new Map<Id,Reservable_Hold__c>();
        mapHold.put(newHold.id, newHold);
        //System.enqueueJob(new QueueReservableHold(lstHold,mapHold));
        System.enqueueJob(new QueueReservableHold(lstHold));
        Test.setMock(HttpCalloutMock.class, new ReservableHoldMock());
         Test.stopTest();
    }
}