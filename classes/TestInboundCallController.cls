@isTest
public class TestInboundCallController
{
  
    static Boolean settingsInitialized = false;
    static LeadConvertor.JourneySettings settingJourney;
    
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        List<Lead> lstLead = new List<Lead>();
        lstLead.add(new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test', Email = 'Test1@example.com', LeadSource = 'Broker', Lead_Source_Detail__c = 'Broker1', Status = 'TestStatus', CurrencyIsoCode = 'USD', Number_of_Desks_2016__c = '2-5 desks'));
        lstLead.add(new Lead(FirstName = 'Test1', LastName = 'Test1', Company = 'Test1', Email = 'Test111@example.com', LeadSource = 'other', Status = 'TestStatus', CurrencyIsoCode = 'USD'));
        lstLead.add(new Lead(FirstName = 'TestLead', LastName = 'Testlead@example.com', Company = 'Testleadco', Email = 'Testlead@example.com', LeadSource = 'other', Status = 'TestStatus', CurrencyIsoCode = 'USD'));
        TestingUtility.insertListWithAssert(lstLead);
        
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(new Account(Name = 'Test Account'));
        TestingUtility.insertListWithAssert(lstAccount);
        
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(new Contact(Firstname = 'TestFirstName', Lastname = 'TestLastName', Email = 'test@example.com', Status__c = 'active', LeadSource = 'Broker',	Lead_Source_Detail__c = 'Broker1', CurrencyIsoCode = 'USD', Number_of_Desks_2016__c = '2-5 desks'));
        lstContact.add(new Contact(FirstName = 'Test', LastName = 'Contact1', AccountId = lstAccount[0].Id,	Email = 'Test111@example.com', Phone = '3256987425'));
        lstContact.add(new Contact(FirstName = 'Test', LastName = 'Contact2', AccountId = lstAccount[0].Id,	Phone = '3256987455', Email = 'Test112@example.com', LeadSource = 'Inbound Call'));
        TestingUtility.insertListWithAssert(lstContact);
        
        List<Building__c> lstBuilding = new List<Building__c>();
        lstBuilding.add(new Building__c(Name='b1', uuid__c = 'abc123', City__c = 'NewYork'));
        lstBuilding.add(new Building__c(Name='b2', uuid__c = 'abc1234', City__c = 'NewYork'));
        TestingUtility.insertListWithAssert(lstBuilding);
    }
    
    static void initFieldMappings() {
        if( settingsInitialized ){
            return;
        }
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 1');
        userRecordMap.put('Username','testweworkuser1@example.com');
        userRecordMap.put('Email','testweworkuser1@example.com');
        User testUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true); 
        
        userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 2');
        userRecordMap.put('Username','testweworkuser2@example.com');
        userRecordMap.put('Email','testweworkuser2@example.com');
        User testUser1 = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true); 

        //Create a queue
        Group testGroup = new Group ();
        testGroup.Name = 'Test Lead Queue';
        testGroup.Type = 'Queue';
        TestingUtility.insertWithAssert(testGroup, 'Group is not inserted');
        
        Group testGroup1 = new Group ();
        testGroup1.Name = 'Test Lead Queue1';
        testGroup1.Type = 'Queue';
        TestingUtility.insertWithAssert(testGroup1, 'Group is not inserted');
        System.runAs(new User(Id=UserInfo.getUserId())){
            List<QueueSObject> lstQueue = new List<QueueSObject>();
            lstQueue.add(new QueueSObject(QueueId = testGroup.Id,SObjectType = 'Lead'));
            lstQueue.add(new QueueSObject(QueueId = testGroup.Id,SObjectType = 'Journey__c'));
            lstQueue.add(new QueueSObject(QueueId = testGroup1.Id,SObjectType = 'Lead'));
            lstQueue.add(new QueueSObject(QueueId = testGroup1.Id,SObjectType = 'Journey__c'));           
            TestingUtility.insertListWithAssert(lstQueue);
            
            List<GroupMember> lstmember = new List<GroupMember>();
            lstMember.add(new GroupMember(UserOrGroupId = testUser.Id,GroupId = testGroup.Id));
            lstMember.add(new GroupMember(UserOrGroupId = UserInfo.getUserId(),GroupId = testGroup.Id));
			TestingUtility.insertListWithAssert(lstMember);            
        }
        settingsInitialized = true;
    }
    
    static testMethod void testContactAndRelated(){
        List<Account> lstAccount =[SELECT Id ,Name From Account WHERE Name = 'Test Account'];		
		List<Contact> lstRelatedContact = [SELECT Id, FirstName, LastName, AccountId, Email, Phone FROM Contact WHERE AccountId =:lstAccount[0].id];//two contacts        		
        Lead objlead = [SELECT Id, FirstName, LastName, Company, Email, LeadSource, Status, CurrencyIsoCode FROM Lead Where Email = 'Test111@example.com'];		
        Journey__c objTestJourny1 = new Journey__c();
		objTestJourny1.Name = 'Test Customer1';
		objTestJourny1.Status__c = 'Started';
		objTestJourny1.Primary_Contact__c = lstRelatedContact[0].Id;
		objTestJourny1.NMD_Next_Contact_Date__c=Date.today().addDays(4);
		TestingUtility.insertWithAssert(objTestJourny1);
        
		objTestJourny1 = new Journey__c();
		objTestJourny1.Name = 'Test Customer1';
		objTestJourny1.Status__c = 'Started';
		objTestJourny1.Primary_Lead__c = objlead.Id;
		objTestJourny1.NMD_Next_Contact_Date__c=Date.today().addDays(4); 
		TestingUtility.insertWithAssert(objTestJourny1);
       
		list<InboundCallController.JourneyContactInfo> lstJourneyContactInfo = InboundCallController.getContactAndRelatedJoureny('3256987425','','', (String)lstRelatedContact[0].Id,lstRelatedContact[0].Phone, true);
        System.assert(lstJourneyContactInfo !=null);        
        list<InboundCallController.JourneyContactInfo> lstJourneyContactInfo2 = InboundCallController.getContactAndRelatedJoureny('Test111@example.com','','','','', true);
		System.assert(lstJourneyContactInfo2 !=null);
        list<InboundCallController.JourneyContactInfo> lstJourneyContactInfo3 = InboundCallController.getContactAndRelatedJoureny('3256987425','','', (String)lstRelatedContact[0].Id,lstRelatedContact[0].Phone, false);
        System.assert(lstJourneyContactInfo3.size()== 0);
        list<InboundCallController.JourneyContactInfo> lstJourneyContactInfo4 = InboundCallController.getContactAndRelatedJoureny('Test112@example.com','','','','', false);
        System.assert(lstJourneyContactInfo4.size()== 0);
	}
    
    static testMethod void testJourneyCreationFromLead(){
        initFieldMappings();
        User objUser = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, objUser);        
        List<Building__c> lstBuilding = [SELECT Id , Name, uuid__c, City__c FROM Building__c ];        
        List<Lead> lstlead = [SELECT Id, FirstName, LastName, Company, Email, LeadSource, Lead_Source_Detail__c, Status, CurrencyIsoCode, Number_of_Desks_2016__c FROM Lead];        
        InboundCallController.createOrUpdateJourney(lstlead[0].Id,'Inbound Call','Inbound Call Page',lstBuilding[1].Id, lstBuilding[1].City__c,true);        
        List<Journey__c> lstTestJourney = [Select Id, Name from Journey__c WHERE Primary_Lead__c = :lstlead[0].Id];
        system.assertEquals(2,lstTestJourney.size());
    }
    
    static testMethod void testJourneyCreationFromContact(){
    	initFieldMappings();
    	User objUser = [Select Id from user where username =:'testweworkuser1@example.com'];
        List<Building__c> lstBuilding = [SELECT Id , Name, uuid__c, City__c FROM Building__c ];    	
    	Contact objContact = new Contact(firstname = 'TestFirstName', lastname = 'TestLastName', email = 'testemail@example.com', Status__c = 'active', LeadSource = 'Broker', Lead_Source_Detail__c = 'Broker1', CurrencyIsoCode = 'USD', Number_of_Desks_2016__c = '2-5 desks');        
        objContact.ownerId = objUser.Id;
        TestingUtility.insertWithAssert(objContact, 'Contact is not inserted');        
        InboundCallController.createOrUpdateJourney(objContact.Id,'Inbound Call','Inbound Call Page',lstBuilding[1].Id, lstBuilding[1].City__c,false);
        list <Journey__c> lstTestJourney = [Select Id,Name from Journey__c where Primary_Contact__c = :objContact.Id];
        system.assertEquals(1, lstTestJourney.size()); 
        /*list<Task> lstTestTasks = [Select Id from Task WHERE WhoID =:objContact.Id];
        system.assertEquals(1, lstTestTasks.size());
        list<Product_Interested__c> lstTestProductInterested = [Select Id from Product_Interested__c];
        system.assertEquals(1, lstTestProductInterested.size());*/
    }
    
    static testMethod void testContactAndRelatedforLead(){        
        Lead objlead = [SELECT Id, FirstName, LastName, Company, Email, LeadSource, Status, CurrencyIsoCode FROM Lead Where Email = 'Testlead@example.com'];       
        Journey__c objTestJourny1 = new Journey__c();
        objTestJourny1.Name = 'Test Customer1';
        objTestJourny1.Status__c = 'Started';
        objTestJourny1.Primary_Lead__c = objlead.Id;
        objTestJourny1.NMD_Next_Contact_Date__c=Date.today().addDays(4);
        TestingUtility.insertWithAssert(objTestJourny1); 
		list<InboundCallController.JourneyContactInfo> lstJourneyContactInfo = InboundCallController.getContactAndRelatedJoureny('Testlead@example.com','Testlead@example.com','','','', true);
        System.assertNotEquals(null, lstJourneyContactInfo);        
        list<InboundCallController.JourneyContactInfo> lstJourneyContactInfo2 = InboundCallController.getContactAndRelatedJoureny('Testlead@example.com','Testlead@example.com','','','', false);
        System.assert(lstJourneyContactInfo2.size()== 0);
        try{
            InboundCallController.getContactAndRelatedJoureny(null,null,null,null,null,null);
        }catch(Exception ex){
            System.debug('Exception==>'+ex.getMessage());
        }
        WeworkEngine controller = new WeworkEngine();
        InboundCallController obj = new InboundCallController(controller);
    }
    
    static testMethod void testSendEmail(){
        List<Account> lstAccount =[SELECT Id ,Name From Account WHERE Name = 'Test Account'];        
        String RecordTypeId = InboundCallController.getRecordTypeInfo('Consumer');
        debug.log('RecordTypeId==>'+RecordTypeId);        
        Contact relatedContact = [SELECT Id, FirstName, LastName, AccountId, Email, Phone FROM Contact WHERE AccountId =:lstAccount[0].id Limit 1];
        Lead objlead = [SELECT Id, FirstName, LastName, Company, Email, LeadSource, Status, CurrencyIsoCode FROM Lead Where Email = 'Test111@example.com'];        
        String htmlBody = '<html> <p>Dear {!Contact.FirstName},</p> Have a nice Day. </html>';
        Boolean result1 = InboundCallController.sendEmail(objlead.Id, htmlBody,'Test Subject');
        System.assertEquals(true, result1);
        Boolean result2 = InboundCallController.sendEmail(relatedContact.Id, htmlBody,'Test Subject');
        System.assertEquals(true, result2);
        InboundCallController.DefaultJourneySettings();//Use to cover this method
        try{
            Boolean result3 = InboundCallController.sendEmail(null, htmlBody,'Test Subject');//For Exception
        }catch(Exception ex){
            System.debug('Exception==>'+ex.getMessage());
        }
    }
}