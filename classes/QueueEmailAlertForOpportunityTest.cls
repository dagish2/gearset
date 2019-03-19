@isTest
public class QueueEmailAlertForOpportunityTest  {
    
    static{
        SalesConsoleSettings.createSettings();         
    }    
     
    static testMethod void verifyQueueEmailAlertForOpportunity(){ 
	Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    User u1 = new User(Alias = 'testU1', Email='testUser81817_1@example.com', 
                       EmailEncodingKey='UTF-8', LastName='User1', LanguageLocaleKey='en_US', 
                       LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = true,
                       TimeZoneSidKey='America/Los_Angeles', UserName='testUserName81817_3@example.com',CommunityNickname=TestingUtility.createUserCommunityName());
	insert u1;
    User u2 = new User(Alias = 'testU2', Email='testUser06092017_1@example.com', 
                       EmailEncodingKey='UTF-8', LastName='User2', LanguageLocaleKey='en_US', 
                       LocaleSidKey='en_US', ProfileId = p1.Id, IsActive = true,
                       TimeZoneSidKey='America/Los_Angeles', UserName='testUserName81817_4@example.com',CommunityNickname=TestingUtility.createUserCommunityName());
    insert u2;
      Building__c b1 = new Building__c(Name = 'B1',Responsible_CM__c=u2.Id);
        insert b1;
        
    Account accRec = new Account();
    	accRec.Name='Test Accounts' ;        
    	accRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        insert accRec;
    	System.assertNotEquals(null, accRec.Id);
        
    Contact conRec = new Contact(
        AccountId =  accRec.Id,  
        firstname = 'TestFirstName',
        lastname = 'TestLastName',
        email = 'testContact@example.com',
		Start_Date__c = Date.today()        
    );
    TestingUtility.insertWithAssert(conRec);
    System.assertNotEquals(null, conRec.Id);
    
    Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);    
    Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, false);
    oppRec.Primary_Member__c = conRec.Id;
    oppRec.StageName = 'Tour Scheduled';
    oppRec.OwnerId = u1.Id;
    oppRec.Amount = 100;
    oppRec.CloseDate = system.today().addDays(5);
    oppRec.RecordTypeId = oppRecordType.get('Mid Market');
    TestingUtility.insertWithAssert(oppRec);
    debug.log('opportunity Record--'+oppRec);
    debug.log('record type for mid market--'+oppRec.RecordTypeId);
    Test.startTest();
    Tour_Outcome__c tourRec1 = new Tour_Outcome__c(
        Primary_Member__c = conRec.Id,
        Scheduled_By__c = conRec.Id,
        Status__c = 'Inquiry',
        Location__c=b1.Id,
        OwnerID = u2.Id,
        Tour_Date__c = system.today().addDays(1),
        Move_In_Date__c = system.today().addDays(4),
        Opportunity__c = oppRec.Id,
        Start_Time__c = '9:00AM',
        End_Time__c = '9:30AM'
    );
    TestingUtility.insertWithAssert(tourRec1); 
    
    debug.log('tourRec1 on insertion --'+tourRec1);
    //TourTriggerHandler.firstRun = true;
    tourRec1.Status__c = 'Completed';   
    update tourRec1;
        tourRec1.Status__c = 'Rescheduled';   
         update tourRec1;
          tourRec1.Status__c = 'Cancelled';
        update tourRec1;
       /* Tour_Outcome__c tourRec2 = new Tour_Outcome__c(
            Primary_Member__c = conRec.Id,
            Scheduled_By__c = conRec.Id,
            Status__c = 'Inquiry',
            Location__c=b1.Id,
            OwnerID = u2.Id,
            Tour_Date__c = system.today().addDays(1),
            Move_In_Date__c = system.today().addDays(4),
            Opportunity__c = oppRec.Id 
        );
        TestingUtility.insertWithAssert(tourRec2); 
        tourRec1.Status__c = 'Rescheduled';
        update tourRec2;
        tourRec1.Status__c = 'Cancelled';
        update tourRec2;*/
        Test.stopTest();  
    } 
}