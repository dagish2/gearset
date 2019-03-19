/*****************************************************************************************************************************
	Author 		:  Krishana Tupe  
	Description :  This class is used to verify BatchOwnerChangeofSobject functionality.
				   Whenever user is getting deactivated then all its related records to be reparented.
	History		: 

----------------------------------------------------------------------------------------------------------------------------------
	VERSION			DATE			AUTHOR				Issue No		DETAIL
	1				17 Nov 2017		Krishana Tupe		ST-1287			Initial Developement
******************************************************************************************************************************/
@isTest
public class BatchOwnerChangeofSobjectTests {    
    static User susieRomero, responsibleCMUser, communitySalesLeadUser;
    static String recTypeComsumerId;
    
    static List<Building__c> lstBuilding;
    static String strQuery = 'SELECT Id, Name, IsActive FROM User WHERE Name =\'Test User1\' AND Username = \'testweworkuser123456788798798@example.com\' LIMIT 1';
    static{ 
        susieRomero = [SELECT Id, Name FROM User WHERE Id = '005F0000003Kmbw' LIMIT 1]; 
        recTypeComsumerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();       
    }
    
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to create initial setup data.
		Created Date		:	17 Nov 2017        
 **************************************************************************************************************************************/ 
    @TestSetup
    public static void setup(){
        SalesConsoleSettings.createSettings();
        Profile profileWeworkSystemAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];  
        List<User> lstUserToInsert = new List<User>();
        
        Map<String,Object> mapResponsibleCMUser = new Map<String,Object>();
        mapResponsibleCMUser.put('LastName','CmUser');
        mapResponsibleCMUser.put('Username','responsibleCmUser@example.com');
        mapResponsibleCMUser.put('Email','responsibleCmUser@example.com');       
        lstUserToInsert.add(TestingUtility.insertUserWithAssert(profileWeworkSystemAdmin.Id, mapResponsibleCMUser, false));
        
        Map<String,Object> mapCommunitySalesLeadUser = new Map<String,Object>();
        mapCommunitySalesLeadUser.put('LastName','Sales Lead');
        mapCommunitySalesLeadUser.put('Username','salesLeaduser@example.com');
        mapCommunitySalesLeadUser.put('Email','salesLeaduser@example.com');
        lstUserToInsert.add(TestingUtility.insertUserWithAssert(profileWeworkSystemAdmin.Id, mapCommunitySalesLeadUser, false));
        
        Map<String,Object> mapWeworkUser = new Map<String,Object>();
        mapWeworkUser.put('LastName','User1');
        mapWeworkUser.put('FirstName','Test');
        mapWeworkUser.put('Username','testweworkuser123456788798798@example.com');
        mapWeworkUser.put('Email','testapiuser-1XXX@example.com');
        mapWeworkUser.put('CommunitynickName','test333'+system.now());
        lstUserToInsert.add(TestingUtility.insertUserWithAssert(profileWeworkSystemAdmin.Id, mapWeworkUser, false));        
        TestingUtility.insertListWithAssert(lstUserToInsert); 
        responsibleCMUser = lstUserToInsert[0];
        communitySalesLeadUser = lstUserToInsert[1];
    }
   
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to verify when user get deactivated its all lead owner will be reassigned according to Lead assignment rule.
		Created Date		:	17 Nov 2017        
 **************************************************************************************************************************************/    
    @isTest
    static void testBatchOwnerChangeofLead(){       
        User testUser = (User)Database.query(strQuery)[0];             
        Lead objLead = new Lead(FirstName = 'Test',
                                LastName = 'Lead',
                                Company = 'vidu DATest',
                                Status = 'Open',
                                Office_Type__c = 'Shared Desk; DailyDesk;',
                                Email = 'test@examplesusie.com',
                                LeadSource = 'WeWork.com',
                                OwnerId = testUser.Id);      
        TestingUtility.insertWithAssert(objLead); 
        
        Test.startTest();
        objlead = [SELECT Id, Name, OwnerId FROM Lead WHERE Id =: objLead.Id LIMIT 1];
        System.assertEquals(objlead.ownerId, testUser.Id);
        deactivateUser(); 
        Test.stopTest();        
        Lead objleadAfterUpdate = [SELECT Id,Name, ownerId, Reassignment_On_User_Deactivation__c, User_Deactivation_Updated_On__c From Lead  Where Id =: objlead.Id LIMIT 1];        
        System.assertEquals(objleadAfterUpdate.Reassignment_On_User_Deactivation__c, true);
        System.assertEquals(objleadAfterUpdate.User_Deactivation_Updated_On__c, Date.today());       
    }
    
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to verify when user get deactivated its all contact owner will be reassigned according to susie romero API user.
		Created Date		:	17 Nov 2017        
 **************************************************************************************************************************************/ 
    @isTest
    public static void testBatchOwnerChangeofContact(){ 
        User accoutOwner = [SELECT Id, Name FROM User WHERE Email = 'Testnewrescm_user@weworkexample.com' LIMIT 1];
        User testUser = (User)Database.query(strQuery)[0]; 
        Account accRec = new Account(Name = 'Test Company', OwnerId = accoutOwner.Id);
        TestingUtility.insertWithAssert(accRec);
        Account objAccount = [SELECT Id, OwnerId, Name FROM Account WHERE Id =: accRec.Id LIMIT 1];        
        System.assert(objAccount != null); 
        System.assert(objAccount.OwnerId == accoutOwner.Id);  
        Contact objContact = createContact(objAccount.Id); 
        System.assert(objContact.Id != null);
        Contact objContact1 = [SELECT Id, Name, ownerId From Contact WHERE Id =: objContact.Id LIMIT 1];       
        objContact1.OwnerId = testUser.Id;
        TestingUtility.updateWithAssert(objContact1);
        Test.startTest();
        deactivateUser();
        Test.stopTest();
        Contact objContactAfterUpdate = [SELECT Id, Name, AccountId, OwnerId FROM Contact WHERE Id =: objContact.Id LIMIT 1];
        System.assertEquals(objAccount.Id, objContactAfterUpdate.AccountId);
        System.assertEquals(objAccount.OwnerId, objContactAfterUpdate.OwnerId);        
    }  
    
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to verify when user get deactivated its all journey owner will be reassigned to Unassigned NMD queue.
		Created Date		:	17 Nov 2017        
 **************************************************************************************************************************************/         
    @isTest
    public static void testBatchOwnerChangeofJourneyWhoseStatusOpen(){       
        User testUser = (User)Database.query(strQuery)[0]; 
        Lead objLead = new Lead(FirstName = 'Test',
                                LastName = 'Lead',
                                Company = 'TestCompany',
                                Status = 'Open',
                                Locations_Interested__c = 'B1; B2;',
                                Office_Type__c = 'Shared Desk; DailyDesk;',
                                Email = 'test@example.com');       
        TestingUtility.insertWithAssert(objLead);               
        Journey__c objJourney = createJourneyRecord(objLead.Id, 'Started');
        objJourney = [SELECT Id ,Name, OwnerId FROM Journey__c WHERE Id =: objJourney.Id];
        objJourney.OwnerId = testUser.id;
        update objJourney;
        Test.startTest();
        deactivateUser();
        Test.stopTest();
        Journey__c objJourneysAfterUpdate = [SELECT Id, Name, OwnerId FROM Journey__c WHERE Id =: objJourney.Id LIMIT 1];
        objLead = [SELECT OwnerId FROM Lead WHERE Id =: objLead.Id LIMIT 1];       
        System.assertEquals(objLead.OwnerId,objJourneysAfterUpdate.ownerId);
    }
    
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to verify when user get deactivated its all contact owner will be reassigned to Unassigned NMD queue.
		Created Date		:	17 Nov 2017        
 **************************************************************************************************************************************/ 
    @isTest
    public static void testBatchOwnerChangeofJourneyWhoseStatusOpenForParentContact(){              
        User testUser = (User)Database.query(strQuery)[0]; 
        Account objAccount = new Account(Name = 'Test Company');
        TestingUtility.insertWithAssert(objAccount);
        Contact objContact = createContact(objAccount.Id);  
        objContact.OwnerId = susieRomero.Id;
        update objContact;
        Journey__c objJourney = createJourneyRecord(objContact.Id, 'Started');       
        objJourney = [SELECT Id, Name, OwnerId FROM Journey__c WHERE Id =: objJourney.Id];
        objJourney.OwnerId = testUser.id;
        update objJourney;
        Test.startTest();
        deactivateUser();
        Test.stopTest();
        Journey__c objJourneysAfterUpdate = [SELECT Id, Name, OwnerId, Owner.Name, Owner.Type FROM Journey__c WHERE Id=: objJourney.Id LIMIT 1];
        objContact = [SELECT OwnerId FROM Contact WHERE Id =: objContact.Id LIMIT 1];
        System.assertNotEquals(objJourneysAfterUpdate.OwnerId, testUser.id);
        System.assertNotEquals(objContact.OwnerId, testUser.id); 
        List<Group> lstNmdQueue = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Id =: objJourneysAfterUpdate.OwnerId];       
        System.assert(lstNmdQueue != null);       
        System.assertEquals('Unassigned NMD US Queue' , lstNmdQueue[0].Name);         
    } 
    
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to verify when user get deactivated its all contact owner will be reassigned to Unassigned NMD queue.
		Created Date		:	17 Nov 2017        
 **************************************************************************************************************************************/    
    @isTest
    public static void testBatchOwnerChangeofJourneyWhoseStatusClosed(){        
        User testUser = (User)Database.query(strQuery)[0]; 
        Lead objLead = new Lead(FirstName = 'Test',
                                LastName = 'Lead',
                                Company = 'TestCompany',
                                Status = 'Open',
                                Locations_Interested__c = 'B1; B2;',
                                Office_Type__c = 'Shared Desk; DailyDesk;',
                                Email = 'test@example.com');
        TestingUtility.insertWithAssert(objLead);
        Journey__c objJourney = createJourneyRecord(objLead.Id, 'Unqualified');
        objJourney = [SELECT Id, Name, OwnerId FROM Journey__c WHERE Id =: objJourney.Id];
        objJourney.ownerId = testUser.Id;
        update objJourney;
        Test.startTest();
        deactivateUser();
        Test.stopTest();
        Journey__c objJourneysAfterUpdate = [SELECT Id, Name, OwnerId FROM Journey__c WHERE Id =: objJourney.Id LIMIT 1];          
        System.assertEquals(susieRomero.Id,objJourneysAfterUpdate.ownerId);
    }
    
 
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to verify when user get deactivated its all account owner will be reassigned according to Account Assignemnet using deal type.
		Created Date		:	17 Nov 2017        
**************************************************************************************************************************************/ 
    public testmethod static void testBatchOwnerChangeofAccountforRelational(){ 
        User testUser1 = (User)Database.query(strQuery)[0];
        User communitySalesLeadUser=[SELECT Id, Name, Username FROM User WHERE Username ='salesLeaduser@example.com' LIMIT 1];
        User responsibleCMUser=[SELECT Id, Name, Username FROM User WHERE Username ='responsibleCmUser@example.com' LIMIT 1];
        List<Market__c> lstMarkets = new List<Market__c>(); 
        lstMarkets.add(new Market__c(Name = 'Sydney',CurrencyIsoCode = 'USD', Portfolio_Sales_Manager__c = communitySalesLeadUser.Id));
        lstMarkets.add(new Market__c(Name = 'London', CurrencyIsoCode = 'USD', Portfolio_Sales_Manager__c = communitySalesLeadUser.Id));
        TestingUtility.insertListWithAssert(lstMarkets);
        
        List<Account_Queue__c> lstAccountQueues = new List<Account_Queue__c>();
        lstAccountQueues.add(new Account_Queue__c(Member__c = communitySalesLeadUser.Id, Account_Record_Type__c = 'Consumer', Is_Queue_Active__c = true, Market__c = 'London', Portfolio__c = lstMarkets[0].Id));
        TestingUtility.insertListWithAssert(lstAccountQueues);
        
        List<Cluster__c> lstClusters = new  List<Cluster__c>();
        lstClusters.add(new Cluster__c(Name = 'Test Cluster', Cluster_Sales_Manager__c =  testUser1.Id, Sales_Lead__c = testUser1.Id));
        lstClusters.add(new Cluster__c(Name = 'Test Cluster2'));
        TestingUtility.insertListWithAssert(lstClusters); 
        
        lstBuilding = new List<Building__c>();
        lstBuilding.add(new Building__c(Market__c = lstMarkets[0].Id, City__c = 'London', Country__c = 'Netherlands', Name = 'Building1', CurrencyIsoCode = 'USD', Time_Zone__c = 'Europe/Amsterdam', Cluster__c = lstClusters[0].Id, Responsible_CM__c = responsibleCMUser.Id));
        TestingUtility.insertListWithAssert(lstBuilding);
        
        Account testAccount_api = TestingUtility.createAccount('Test-Account',false);
        testAccount_api.RecordTypeId = recTypeComsumerId ;        
        testAccount_api.Interested_in_Number_of_Desks__c = 11;
        testAccount_api.Lead_Source__c = 'WeWork.com';
        testAccount_api.ownerId=testUser1.id;
        system.runAs(new User(Id = testUser1.Id)){
            insert testAccount_api;
        }
        //Verifying the owner of Account, It should be ApiUser
        Account testAccount = [SELECT OwnerId FROM Account WHERE Id =: testAccount_api.Id];
        System.assertEquals(testUser1.Id, testAccount.OwnerId);
        
        Opportunity objOpportunity = TestingUtility.createOpportunity(testAccount_api.Id,false);
        objOpportunity.StageName='Selling';
        objOpportunity.Building__c = lstBuilding[0].Id;
        objOpportunity.Interested_in_Number_of_Desks__c = 5;
        objOpportunity.Owner_Auto_Assign__c=true;
        TestingUtility.insertWithAssert(objOpportunity);
        List<Account> lstAccounts = [SELECT Id, RecordType.Name, OwnerId, Owner.ProfileId, (SELECT Id, OwnerId, Deal_Type__c, Building__r.Responsible_CM__c, Building__r.Cluster__r.Cluster_Sales_Manager__c FROM Opportunities WHERE (StageName = 'Qualifying' OR StageName = 'Negotiating' OR StageName = 'Selling') ORDER BY CreatedDate LIMIT 1) FROM Account WHERE Id =: testAccount_api.Id];
        system.assertEquals(1, lstAccounts[0].opportunities.size());
        
        Test.startTest();
        deactivateUser();
        Test.stopTest();
        
        Opportunity testOpp = [SELECT Id,OwnerId, Deal_Type__c, AccountId FROM Opportunity WHERE Id =: objOpportunity.Id];
        Account objAccount = [SELECT Id, OwnerId FROM Account WHERE Id =: testAccount_api.Id];
        System.assertEquals(testUser1.Id, objAccount.OwnerId );
    }      
   
  
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to verify when user get deactivated its all opportunity owner will be reassigned according to Account Assignemnet using deal type.
		Created Date		:	17 Nov 2017        
 **************************************************************************************************************************************/ 
    @isTest
    public static void testBatchOwnerChangeofOpportunity(){
        User testUser = (User)Database.query(strQuery)[0];        
        Test.startTest();
        Account objAccount = new Account(Name = 'Test Company');
        TestingUtility.insertWithAssert(objAccount);
        Contact objContact = createContact(objAccount.Id);        
        Opportunity objOpportunity = createOpportunity(objAccount.Id, objContact.Id, userInfo.getUserId());
        objOpportunity.OwnerId = testUser.Id;
        update objOpportunity;
        deactivateUser();
        Test.stopTest();
        Opportunity objOppUpdate = [SELECT Id, Name, OwnerId, AccountId, Account.OwnerId FROM Opportunity WHERE Id =: objOpportunity.Id ];
        System.assertEquals(objOpportunity.AccountId, objAccount.Id);
        System.assertEquals(susieRomero.Id, objOppUpdate.OwnerId);
    }   
    
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to verify when user get deactivated its all contact owner will be reassigned to API user.
		Created Date		:	17 Nov 2017        
 **************************************************************************************************************************************/    
    @isTest
    public static void testBatchOwnerChangeofTour(){             
        User testUser = (User)Database.query(strQuery)[0];       
        Test.startTest();
        Account objAccount = new Account(Name = 'Test Company');
        TestingUtility.insertWithAssert(objAccount);
        Contact objContact = createContact(objAccount.Id);        
        Opportunity objOpportunity = createOpportunity(objAccount.Id, objContact.Id, testUser.Id);
        Building__c objBuilding = new Building__c(Name = 'B1');
        TestingUtility.insertWithAssert(objBuilding);
        
        Tour_Outcome__c objTour = new Tour_Outcome__c();
        objTour.Scheduled_By__c = objContact.Id;
        objTour.Opportunity__c = objOpportunity.Id;       
        objTour.Status__c = 'Scheduled';
        objTour.Location__c = objBuilding.Id;
        objTour.Primary_Member__c = objContact.Id;
        objTour.Tour_Date__c = system.today().addDays(3);
        objTour.Start_Time__c = '9:30AM';
        objTour.end_Time__c = '10:00AM';
        objTour.OwnerId = testUser.Id;
        TestingUtility.insertWithAssert(objTour);        
        deactivateUser();
        Test.stopTest();        
        Tour_Outcome__c objTourUpdate = [SELECT Id, Name, OwnerId FROM Tour_Outcome__c WHERE Id =: objTour.Id LIMIT 1];       
        System.assertEquals(susieRomero.Id,objTourUpdate.ownerId);
    }
    
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used create a journey record
		Created Date		:	16 Nov 2018        
 **************************************************************************************************************************************/ 
    public static Journey__c createJourneyRecord(Id parentId, String strStatus){
        Journey__c objJourney = new Journey__c();
        objJourney.Name = 'testJourney';
        objJourney.CurrencyIsoCode = 'USD';
        if(String.valueOf(parentId).startsWith('003')){
            objJourney.Primary_Contact__c = parentId;
        }else{
            objJourney.Primary_Lead__c = parentId;
        }        
        objJourney.NMD_Next_Contact_Date__c = Date.today();
        objJourney.Lost_Reason__c = 'Not Interested';
        objJourney.Status__c = strStatus;
        TestingUtility.insertWithAssert(objJourney);
        return objJourney;
    }   
   
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to deactivate user.
		Created Date		:	17 Nov 2017        
 **************************************************************************************************************************************/  
    public static void deactivateUser(){  
        User adminUser = [SELECT Id FROM User WHERE Email = 'Testnewrescm_user@weworkexample.com' LIMIT 1]; 
        User testUser = [SELECT Id FROM User WHERE Name = 'Test User1' AND Username = 'testweworkuser123456788798798@example.com' LIMIT 1];
        System.runAs ( adminUser ) {        
            testUser.IsActive = false;
            update testUser; 
        }
    }
    
    public static Opportunity createOpportunity(Id accountId, Id contactId, Id oppOwnerId){
        Opportunity objOpportunity = TestingUtility.createOpportunity(accountId, false);
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        objOpportunity.Primary_Member__c = contactId;
        objOpportunity.StageName = 'Selling';
        objOpportunity.CloseDate = System.today().addDays(5);
        objOpportunity.Amount = 150;
        objOpportunity.RecordTypeId = oppRecordType.get('Consumer');        
        objOpportunity.OwnerId = oppOwnerId;
        TestingUtility.insertWithAssert(objOpportunity); 
        return objOpportunity;
    }
    
    public static Contact createContact(Id accountId){
        Contact objContact = new Contact(FirstName = 'Test',
                                         LastName = 'Contact1',
                                         AccountId = accountId,
                                         Email = 'testEmail_1111@example.com',
                                         Phone = '3256987425');
        TestingUtility.insertWithAssert(objContact);
        return objContact;
    }
    
}