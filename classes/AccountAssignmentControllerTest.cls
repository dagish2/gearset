/************************************************************************************************************************************
    Author      :   Pragalbha Mahajan
    Description :   This class contains all test methods related to AccountAssignmentController class.
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           2 Feb 2019         	Pragalbha Mahajan       Initial Development
************************************************************************************************************************************/
@isTest
public class AccountAssignmentControllerTest {
    static User testUser7, testUser1,testUser6, testUser5, responsibleCMUser, communitySalesLeadUser, apiUser;   
    static String recTypeComsumerId, recTypeMidMarketId, recTypeEnterpriseId;
    static List<Account> lstAccount = new List<Account>();
    static List<Building__c> lstBuilding;
    static List<Account_Queue__c> lstAccountQueues;
    static List<Country__c> lstcountries;
    static List<State__c> lststates;
    static List<City__c> lstCities;
    static Contact primaryContact;  
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to setup test data.
    Issue No.			:	ST-3391
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    static{
        SalesConsoleSettings.createSettings(); 
        recTypeComsumerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        recTypeMidMarketId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        recTypeEnterpriseId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        apiUser = [Select Id,Name from User Where Id = '005F0000003Kmbw' limit 1];
        createUsers();             
        insertTeriorityStructure();
        
        primaryContact = new Contact(LastName = 'Test Primary Contact', Email = 'test-primary-contact@example.com');
        TestingUtility.insertWithAssert(primaryContact);
        lstAccount = TestingUtility.createAccounts(13,'Test-Account',false);        
        setAccountData(lstAccount, 0, recTypeEnterpriseId, null, 5, apiUser.Id);
        setAccountData(lstAccount, 1, recTypeEnterpriseId, null, 0, apiUser.Id);
        setAccountData(lstAccount, 2, recTypeEnterpriseId, null, 0, testUser6.Id);
        setAccountData(lstAccount, 3, recTypeEnterpriseId, null, 0, testUser6.Id);//auto owner assign true 
        setAccountData(lstAccount, 4, recTypeEnterpriseId, null, 10000, responsibleCMUser.Id);
        
        setAccountData(lstAccount, 5, recTypeMidMarketId, null, 0, apiUser.Id);
        setAccountData(lstAccount, 6, recTypeMidMarketId, null, 0, apiUser.Id);   
        setAccountData(lstAccount, 7, recTypeMidMarketId, null, 0, testUser6.Id); //auto owner assign true 
        setAccountData(lstAccount, 8, recTypeMidMarketId, null, 0, responsibleCMUser.Id); 
        setAccountData(lstAccount, 9, recTypeMidMarketId, null, 10000, null);
        
        setAccountData(lstAccount, 10, recTypeComsumerId, null, 5, apiUser.Id);
        setAccountData(lstAccount, 11, recTypeComsumerId, null, 8, apiUser.Id);
        setAccountData(lstAccount, 10, recTypeComsumerId, null, 8, apiUser.Id);
        
        triggerSettings.mappedField.Account_UpdateRecordType = false;
        TestingUtility.insertListWithAssert(lstAccount);
        triggerSettings.mappedField.Account_UpdateRecordType = true;
    }
    
    @isTest
    public static void verifysetOwnerByRoeAssignment(){
        List<Account> lstEnterpriseAccounts = new List<Account>([SELECT Id, owner.profile.name,recordtype.name, owner.name, lead_source__c, primary_member__c, Number_of_Full_Time_Employees__c  FROM Account WHERE id in : lstAccount AND recordtype.name = 'Enterprise Solutions']);
        List<Account> lstMidMarketAccounts = new List<Account>([SELECT Id, owner.profile.name,recordtype.name, owner.name, lead_source__c, primary_member__c, Number_of_Full_Time_Employees__c FROM Account WHERE id in : lstAccount AND recordtype.name = 'Mid Market']);
        List<Account> lstConsumerAccounts= new List<Account>([SELECT Id, owner.profile.name,recordtype.name, owner.name, lead_source__c, primary_member__c, Number_of_Full_Time_Employees__c FROM Account WHERE id in : lstAccount AND recordtype.name = 'Consumer']);
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity.add(insertOpportunity(lstEnterpriseAccounts[0], 'Selling', lstBuilding[4].Id, 100, false));//api user autoowner assign false
        lstOpportunity.add(insertOpportunity(lstEnterpriseAccounts[1], 'Selling', lstBuilding[4].Id, 100, true));//api user autoowner assign true
        lstOpportunity.add(insertOpportunity(lstEnterpriseAccounts[2], 'Selling', lstBuilding[4].Id, 100, true));
        lstOpportunity.add(insertOpportunity(lstEnterpriseAccounts[3], 'Selling', lstBuilding[4].Id, 100, false));
        lstOpportunity.add(insertOpportunity(lstEnterpriseAccounts[4], 'Selling', lstBuilding[4].Id, 100, true));
        
        lstOpportunity.add(insertOpportunity(lstMidMarketAccounts[0], 'Selling', lstBuilding[4].Id, 100, true));//api user autoowner assign true
        lstOpportunity.add(insertOpportunity(lstMidMarketAccounts[1], 'Negotiating', lstBuilding[4].Id, 100, false));//api user autoowner assign false
        lstOpportunity.add(insertOpportunity(lstMidMarketAccounts[2], 'Negotiating', lstBuilding[4].Id, 100, false));
        lstOpportunity.add(insertOpportunity(lstMidMarketAccounts[3], 'Negotiating', lstBuilding[4].Id, 100, true));
        lstOpportunity.add(insertOpportunity(lstMidMarketAccounts[4], 'Selling', lstBuilding[4].Id, 100, true));
        
        lstOpportunity.add(insertOpportunity(lstConsumerAccounts[0], 'Selling', lstBuilding[4].Id, 100, false));//api user autoowner assign false
        lstOpportunity.add(insertOpportunity(lstConsumerAccounts[1], 'Selling', lstBuilding[4].Id, 100, true));//api user autoowner assign true
        lstOpportunity.add(insertOpportunity(lstConsumerAccounts[2], 'Selling', lstBuilding[4].Id, 100, false));//api user autoowner assign true
        
        TestingUtility.insertListWithAssert(lstOpportunity);
        
        Map<String, Map<String,String>> mapAsserts = roeAssignmentAsserts();
        system.assert(mapAsserts.size() > 0);
        Map<String,String> mapassertvalues;
        for(opportunity obj : [SELECT Id, Owner.Name, Account.Owner.Name, Account.ownerId, OwnerId, Account.RecordTypeId, Account.RecordType.Name, AccountId from Opportunity where Id IN : lstOpportunity]){
            if(mapAsserts.get(obj.AccountId) != null){
                for(String field : mapAsserts.get(obj.AccountId).keyset()){
                    mapassertvalues = mapAsserts.get(obj.AccountId);
                    Debug.Log('mapassertvalues.get(field)===>'+mapassertvalues.get(field));
                    system.assertEquals(mapassertvalues.get(field), AccountAssignmentController.getRelationShipValue(field, obj));
                }  
            }
        }
    }
    
    /**********************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to test update record type.
		Created Date  		:   16 Nov 2018
		Issue No			:	-
 **************************************************************************************************************************************************/     
    @isTest
    public static void testUpdateRecordType(){     
        Account objConsumerAccount1 = new Account(Name = 'Test Account Consumer 1', Account_Type__c = 'Org', Number_of_Full_Time_Employees__c = 5);
        TestingUtility.insertWithAssert(objConsumerAccount1);                 
        objConsumerAccount1 = [SELECT Id, Number_of_Full_Time_Employees__c, Name, RecordType.Name FROM Account WHERE Id =: objConsumerAccount1.Id LIMIT 1];       
        TestingUtility.createContact(objConsumerAccount1.Id, 'strLastName1', true);
        System.assertEquals('Consumer', objConsumerAccount1.RecordType.Name);
        
        Account objConsumerAccount2 = new Account(Name = 'Test Account Consumer 2', Account_Type__c = 'Org', Number_of_Full_Time_Employees__c = 15);
        TestingUtility.insertWithAssert(objConsumerAccount2);                 
        objConsumerAccount2 = [SELECT Id, Number_of_Full_Time_Employees__c, Name, RecordType.Name FROM Account WHERE Id =: objConsumerAccount2.Id LIMIT 1]; 
        System.assertEquals('Mid Market', objConsumerAccount2.RecordType.Name);
        
        Account objMidMarketAccount = new Account(Name = 'Test Mid Market Account 7821', Account_Type__c = 'Org', Unomy_Company_Size__c = '555 desk+');
        TestingUtility.insertWithAssert(objMidMarketAccount);     
        objMidMarketAccount = [SELECT Id, Number_of_Full_Time_Employees__c, Name, RecordType.Name FROM Account WHERE Id =: objMidMarketAccount.Id LIMIT 1];
        Contact objContact = TestingUtility.createContact(objMidMarketAccount.Id, 'strLastName1', false);
        objContact.Email = 'testtttt1421444444@example.com';
        TestingUtility.insertWithAssert(objContact);
        System.assertEquals('Mid Market', objMidMarketAccount.RecordType.Name);
        
        Account objEnterpriseSolutionsAccount = new Account(Name = 'Test Enterprise Account1', Account_Type__c = 'Org', Number_of_Full_Time_Employees__c = 1200);
        TestingUtility.insertWithAssert(objEnterpriseSolutionsAccount);     
        objEnterpriseSolutionsAccount = [SELECT Id, Number_of_Full_Time_Employees__c, Name, RecordType.Name FROM Account WHERE Id =: objEnterpriseSolutionsAccount.Id LIMIT 1];
        objContact = TestingUtility.createContact(objEnterpriseSolutionsAccount.Id, 'strLastName1', false);
        objContact.Email = 'testtttt1421447544@example.com';
        TestingUtility.insertWithAssert(objContact);
        System.assertEquals('Enterprise Solutions', objEnterpriseSolutionsAccount.RecordType.Name);   
        
        update new Account(Id = objConsumerAccount1.Id, Number_of_Full_Time_Employees__c = 500);
        objConsumerAccount1 = [SELECT Id, Number_of_Full_Time_Employees__c, Name, RecordType.Name FROM Account WHERE Id =: objConsumerAccount1.Id LIMIT 1];
        System.assertEquals('Mid Market', objConsumerAccount1.RecordType.Name);
        
        update new Account(Id = objConsumerAccount2.Id, Number_of_Full_Time_Employees__c =2500);
        objConsumerAccount2 = [SELECT Id, Number_of_Full_Time_Employees__c, Name, RecordType.Name FROM Account WHERE Id =: objConsumerAccount2.Id LIMIT 1];
        System.assertEquals('Enterprise Solutions', objEnterpriseSolutionsAccount.RecordType.Name); 
    }
    
	/**********************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used insert user for all test methods.
		Created Date  		:   16 Nov 2018
		Issue No			:	-
 **************************************************************************************************************************************************/ 
    public static List<User> createUsers(){
        List<User> lstUserToInsert = new List<User>();
        Profile profileWeworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator']; 
        Profile profileWeworkregionalbeta = [SELECT Id FROM Profile WHERE Name='WeWork Regional Sales Lead - Beta']; 
        lstUserToInsert.add(TestingUtility.insertUserWithAssert(profileWeworkSystemAdmin.Id, getUserData('Test User 1', 'testweworkuser1@example.com', 'testweworkuser1@example.com'), false));      
        lstUserToInsert.add(TestingUtility.insertUserWithAssert(profileWeworkregionalbeta.Id, getUserData('CmUser', 'responsibleCmUser@example.com', 'responsibleCmUser@example.com'), false));       
        lstUserToInsert.add(TestingUtility.insertUserWithAssert(profileWeworkSystemAdmin.Id, getUserData('Sales Lead', 'salesLeaduser@example.com', 'salesLeaduser@example.com'), false)); 
        lstUserToInsert.add(TestingUtility.insertUserWithAssert(profileWeworkSystemAdmin.Id, getUserData('Test User 5', 'testweworkuser10@example.com', 'testweworkuser10@example.com'), false));
        lstUserToInsert.add(TestingUtility.insertUserWithAssert(profileWeworkSystemAdmin.Id, getUserData('Test User 6', 'testweworkuser6@example.com', 'testweworkuser6@example.com'), false));
        lstUserToInsert.add(TestingUtility.insertUserWithAssert(profileWeworkSystemAdmin.Id, getUserData('Test User 7', 'testweworkuser7@example.com', 'testweworkuser7@example.com'), false));              
        TestingUtility.insertListWithAssert(lstUserToInsert);
        testUser1 = lstUserToInsert[0];
        responsibleCMUser = lstUserToInsert[1];
        communitySalesLeadUser = lstUserToInsert[2];
        testUser5 = lstUserToInsert[3];
        testUser6 = lstUserToInsert[4];
        testUser7 = lstUserToInsert[5];
        return lstUserToInsert;
    }    
    
    /**********************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used create Teriority Structure for Account assignment
		Created Date  		:   16 Nov 2018
		Issue No			:	-
 **************************************************************************************************************************************************/
    public static void insertTeriorityStructure(){
        //List of Markets
        List<Market__c> lstMarkets = new List<Market__c>(); 
        lstMarkets.add(new Market__c(Name = 'Sydney', CurrencyIsoCode = 'USD', Portfolio_Sales_Manager__c = communitySalesLeadUser.Id));
        lstMarkets.add(new Market__c(Name = 'London', CurrencyIsoCode = 'USD', Portfolio_Sales_Manager__c = communitySalesLeadUser.Id));
        TestingUtility.insertListWithAssert(lstMarkets);
        
        lstcountries=new List<Country__c>();       
        lstcountries.add(new Country__c(Name = 'Australia', Portfolio__c = lstMarkets[0].Id, CurrencyIsoCode = 'INR'));
        TestingUtility.insertListWithAssert(lstcountries);
        
        lststates=new List<State__c>();
        lststates.add(new State__c(Name = 'New South Wales', Portfolio__c = lstMarkets[0].Id, Country__c = lstcountries[0].Id));
        TestingUtility.insertListWithAssert(lststates);
        
        lstCities=new List<City__c>();        
        lstCities.add(new City__c(Name ='Sydney',Portfolio__c = lstMarkets[0].Id, State__c = lststates[0].Id));
        TestingUtility.insertListWithAssert(lstCities);
        
        lstAccountQueues = new List<Account_Queue__c>();        
        lstAccountQueues.add(getAccountQueue(testUser1.Id, 'Mid Market', 'Austin', lstMarkets[0].Id));
        lstAccountQueues.add(getAccountQueue(testUser5.Id, 'Consumer', 'Austin', lstMarkets[0].Id));
        lstAccountQueues.add(getAccountQueue(testUser7.Id, 'Enterprise Solutions', 'Sydney', lstMarkets[0].Id));
        TestingUtility.insertListWithAssert(lstAccountQueues);
        
        List<Cluster__c> lstClusters = new  List<Cluster__c>();
        lstClusters.add(new Cluster__c(Name = 'Test Cluster', Cluster_Sales_Manager__c =  testUser1.Id, Sales_Lead__c = testUser1.Id));
        lstClusters.add(new Cluster__c(Name = 'Test Cluster2'));
        TestingUtility.insertListWithAssert(lstClusters); 
        
        lstBuilding = new List<Building__c>();
        lstBuilding.add(new Building__c(City__c = 'Amsterdam', Country__c = 'Netherlands', Name = 'AMS-Metropool', CurrencyIsoCode = 'USD', Time_Zone__c = 'Europe/Amsterdam', Responsible_CM__c = responsibleCMUser.Id));
        lstBuilding.add(new Building__c(City__c = 'Brooklyn', Country__c = 'USA', State__c = 'CH', Name = 'BKN-Brooklyn Heights', CurrencyIsoCode = 'USD', Time_Zone__c = 'America/New_York', Community_Sales_Lead__c = communitySalesLeadUser.Id));
        lstBuilding.add(new Building__c(City__c = 'Berlin Mitte', Country__c = 'Germany', Name = 'BL-Sony Center', CurrencyIsoCode = 'USD', Time_Zone__c = 'America/New_York', Community_Sales_Lead__c = communitySalesLeadUser.Id));
        lstBuilding.add(new Building__c(City__c = 'London', Country__c = 'Netherlands', Name = 'AMS-Metropool', CurrencyIsoCode = 'USD', Time_Zone__c = 'Europe/Amsterdam'));
        lstBuilding.add(new Building__c(Market__c = lstMarkets[0].Id, City__c = 'London', Country__c = 'Netherlands', Name = 'Building1', CurrencyIsoCode = 'USD', Time_Zone__c = 'Europe/Amsterdam', Cluster__c = lstClusters[0].Id, Responsible_CM__c = responsibleCMUser.Id, Community_Lead__c = responsibleCMUser.Id));
        lstBuilding.add(new Building__c(Market__c = lstMarkets[1].Id, City__c = 'London', Country__c = 'Netherlands', Name = 'Building12', CurrencyIsoCode = 'USD', Time_Zone__c = 'Europe/Amsterdam', Cluster__c = lstClusters[1].Id));
        TestingUtility.insertListWithAssert(lstBuilding);
        
        //List of Building Markets for above buildings
        List<Building_Market__c> lstbuildingMarket = new List<Building_Market__c>();
        lstbuildingMarket.add(new Building_Market__c(Building__c = lstBuilding[3].Id, Market__c = lstMarkets[1].Id));
        lstbuildingMarket.add(new Building_Market__c(Building__c = lstBuilding[2].Id, Market__c = lstMarkets[0].Id));
        TestingUtility.insertListWithAssert(lstbuildingMarket);   
    }
    
    public static Map<String,Object> getUserData(String strLastName, String strUsername, String strEmail){
        Map<String,Object> mapUserRecord = new Map<String,Object>();
        mapUserRecord.put('LastName',strLastName);
        mapUserRecord.put('Username',strUsername);
        mapUserRecord.put('Email',strEmail);
        return mapUserRecord;
    }
    
    public static Account_Queue__c getAccountQueue(Id memberId, String strRecordType, String strMarket, Id portfolioId){
        Account_Queue__c objAccountQueue = new Account_Queue__c();
        objAccountQueue.Member__c = memberId;
        objAccountQueue.Account_Record_Type__c = strRecordType;
        objAccountQueue.Last_Account_Assigned__c = Date.today();
        objAccountQueue.Market__c = strMarket;        
        objAccountQueue.Is_Queue_Active__c = true;
        objAccountQueue.Portfolio__c = portfolioId; 
        return objAccountQueue;
    }
    
    public static void setAccountData(List<Account> lstAccount, Integer iIndex, Id recordTypeId, String strUnomyLocationCountry, Integer numberofEmployees, Id ownerId){
        debug.log('setAccountData primaryContact==>'+primaryContact);
        if(String.isNotBlank(strUnomyLocationCountry)){
            lstAccount[iIndex].Unomy_Location_Country__c = strUnomyLocationCountry;   
        }
        if(numberofEmployees != 0){
            Debug.Log('lstAccount[iIndex]==>'+lstAccount[iIndex]);
            lstAccount[iIndex].Number_of_Full_Time_Employees__c = numberofEmployees;
        }
        lstAccount[iIndex].Primary_Member__c = primaryContact.Id;
        if(ownerId != null){
          lstAccount[iIndex].ownerId = ownerId;  
        }
        
        lstAccount[iIndex].RecordTypeId  = recordTypeId;
    }
    
    public static Opportunity insertOpportunity(Account objAccount, String strStageName, Id buildingId, Integer iInterestedInNumberofDesks, Boolean autoOwnerAssign){
        Opportunity objOpportunity = TestingUtility.createOpportunity(objAccount.Id, false);
        objOpportunity.StageName = strStageName;
        objOpportunity.Primary_Member__c = objAccount.Primary_Member__c;
        objOpportunity.Building__c = buildingId;
        objOpportunity.Interested_in_Number_of_Desks__c = iInterestedInNumberofDesks;
        objOpportunity.Owner_Auto_Assign__c = autoOwnerAssign;
        return objOpportunity;
    }
    
    public static Map<String, Map<String,String>> roeAssignmentAsserts(){
        Map<String, Map<String,String>> mapAsserts = new Map<String, Map<String,String>>();
        mapAsserts.put(lstAccount[0].Id, new Map<String, string>{'Account.OwnerId'=>testUser7.Id, 'OwnerId'=>testUser7.Id, 'Account.RecordTypeId'=>recTypeEnterpriseId});
    	mapAsserts.put(lstAccount[1].Id, new Map<String, string>{'Account.OwnerId'=>testUser7.Id, 'OwnerId'=>testUser7.Id, 'Account.RecordTypeId'=>recTypeEnterpriseId});
        mapAsserts.put(lstAccount[2].Id, new Map<String, string>{'Account.OwnerId'=>testUser7.Id, 'OwnerId'=>testUser7.Id, 'Account.RecordTypeId'=>recTypeEnterpriseId});
        mapAsserts.put(lstAccount[3].Id, new Map<String, string>{'Account.OwnerId'=>testUser7.Id, 'OwnerId'=>testUser7.Id, 'Account.RecordTypeId'=>recTypeEnterpriseId});
        mapAsserts.put(lstAccount[4].Id, new Map<String, string>{'Account.OwnerId'=>responsibleCMUser.Id, 'OwnerId'=>responsibleCMUser.Id, 'Account.RecordTypeId'=>recTypeEnterpriseId});
        
        mapAsserts.put(lstAccount[5].Id, new Map<String, string>{'Account.OwnerId'=>testUser1.Id, 'OwnerId'=>testUser1.Id, 'Account.RecordTypeId'=>recTypeMidMarketId});
        mapAsserts.put(lstAccount[6].Id, new Map<String, string>{'Account.OwnerId'=>testUser1.Id, 'OwnerId'=>testUser1.Id, 'Account.RecordTypeId'=>recTypeMidMarketId});
        mapAsserts.put(lstAccount[7].Id, new Map<String, string>{'Account.OwnerId'=>testUser1.Id, 'OwnerId'=>testUser1.Id, 'Account.RecordTypeId'=>recTypeMidMarketId});
        mapAsserts.put(lstAccount[8].Id, new Map<String, string>{'Account.OwnerId'=>responsibleCMUser.Id, 'OwnerId'=>responsibleCMUser.Id, 'Account.RecordTypeId'=>recTypeMidMarketId});
        mapAsserts.put(lstAccount[9].Id, new Map<String, string>{'Account.OwnerId'=>testUser7.Id, 'OwnerId'=>testUser7.Id, 'Account.RecordTypeId'=>recTypeEnterpriseId});
        
        mapAsserts.put(lstAccount[10].Id, new Map<String, string>{'Account.OwnerId'=>testUser1.Id, 'OwnerId'=>testUser1.Id, 'Account.RecordTypeId'=>recTypeComsumerId});
        mapAsserts.put(lstAccount[11].Id, new Map<String, string>{'Account.OwnerId'=>testUser1.Id, 'OwnerId'=>testUser1.Id, 'Account.RecordTypeId'=>recTypeComsumerId});
        mapAsserts.put(lstAccount[12].Id, new Map<String, string>{'Account.OwnerId'=>testUser1.Id, 'OwnerId'=>testUser1.Id, 'Account.RecordTypeId'=>recTypeComsumerId});
        return mapAsserts;
    }
}