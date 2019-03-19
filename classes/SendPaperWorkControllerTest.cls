/************************************************************************************************************************************
    Author      :   Priyanka Ambre
    Description :   This class contain all test methods related to SendPaperWorkController class.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           18 July 2018        Priyanka Ambre      Initial Developement
**************************************************************************************************************************************/
@isTest
public class SendPaperWorkControllerTest {
    public static List<Account> lstAccounts = new List<Account>(); 
    public static List<Contact> lstContacts = new List<Contact>(); 
    public static List<Building__c> lstBuildings= new List<Building__c>();
    public static List<User> lstUser = new List<User>();
    public static List<Opportunity> lstOpportunities = new List<Opportunity>();
    
    @TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings(); 
        Profile objProfile1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile weWorkProfile = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator'];
        User objUser1 = new User(Alias = 'testU', Email='testUserName1@example.com', 
                                 EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = objProfile1.Id, IsActive = true,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUserName1@example.com',CommunityNickname = TestingUtility.createUserCommunityName());
        lstUser.add(objUser1);
        
        User objUser2 = new User(Alias = 'testU1',Email='testUser1weWork@example.com', 
                                 EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = weWorkProfile.Id, IsActive = true,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser1LeadOwner@example.com',CommunityNickname = TestingUtility.createUserCommunityName());
        lstUser.add(objUser2); 
        TestingUtility.insertListWithAssert(lstUser); 
        
        //Refrence fields - RecordTypeId,Market__c,Primary_Member__c
        String recTypeComsumerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        String recTypeMidMarketId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        String recTypeEnterpriseId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        
        Account testAccountCon1 = TestingUtility.createAccount('Test-Account1',false);
        testAccountCon1.RecordTypeId = recTypeComsumerId ;
        testAccountCon1.Unomy_Location_Country__c = 'Australia';
        
        Account testAccountMM1 = TestingUtility.createAccount('Test-Account2',false);
        testAccountMM1.RecordTypeId = recTypeMidMarketId ;
        
        Account testAccountEnt1 = TestingUtility.createAccount('Test-Account3',false);
        testAccountEnt1.RecordTypeId = recTypeEnterpriseId ;
        
        lstAccounts = new List<Account>();
        lstAccounts.add(testAccountCon1);
        lstAccounts.add(testAccountMM1);
        lstAccounts.add(testAccountEnt1);
        TestingUtility.insertListWithAssert(lstAccounts);  
        
        Contact objConsumerCon = new Contact(firstname = 'John',lastname = 'Rambo',email = 'john.con1@example.com', accountID = testAccountCon1.Id, Status__c = 'active');
        lstContacts.add(objConsumerCon);
        Contact objMidCon = new Contact(firstname = 'John',lastname = 'Rambo',email = 'john.con2@example.com', accountID = testAccountMM1.Id, Status__c = 'active');
        lstContacts.add(objMidCon);
        Contact objEntCon = new Contact(firstname = 'John',lastname = 'Rambo',email = 'john.con3@example.com', accountID = testAccountEnt1.Id, Status__c = 'active');
        lstContacts.add(objEntCon);
        TestingUtility.insertListWithAssert(lstContacts);  
        
        Opportunity oppRecCons = TestingUtility.createOpportunity(lstAccounts[0].Id, false);
        oppRecCons.Primary_Member__c = objConsumerCon.Id;
        oppRecCons.StageName = 'Selling';
        oppRecCons.CloseDate = system.today().addDays(5);
        oppRecCons.Membership_Agreement_Notes__c = 'Opprtunity 3 Membership_Agreement_Notes__c';
        oppRecCons.Tour_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecCons.Tour_Outcome_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecCons.Description = 'Opprtunity 3 Tour_Notes__c'; 
        oppRecCons.Owner_Auto_Assign__c = true;   
        
        Opportunity oppRecMM = TestingUtility.createOpportunity(lstAccounts[1].Id, false);
        oppRecMM.Primary_Member__c = objMidCon.Id;
        oppRecMM.StageName = 'Selling';
        oppRecMM.CloseDate = system.today().addDays(5);
        oppRecMM.Membership_Agreement_Notes__c = 'Opprtunity 3 Membership_Agreement_Notes__c';
        oppRecMM.Tour_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecMM.Tour_Outcome_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecMM.Description = 'Opprtunity 3 Tour_Notes__c'; 
        oppRecMM.Owner_Auto_Assign__c = true;  
        
        Opportunity oppRecEnt = TestingUtility.createOpportunity(lstAccounts[2].Id, false);
        oppRecEnt.Primary_Member__c = objEntCon.Id;
        oppRecEnt.StageName = 'Selling';
        oppRecEnt.CloseDate = system.today().addDays(5);
        oppRecEnt.Membership_Agreement_Notes__c = 'Opprtunity 3 Membership_Agreement_Notes__c';
        oppRecEnt.Tour_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecEnt.Tour_Outcome_Notes__c = 'Opprtunity 3 Tour_Notes__c';
        oppRecEnt.Description = 'Opprtunity 3 Tour_Notes__c'; 
        oppRecEnt.Owner_Auto_Assign__c = true;  
        
        lstOpportunities.add(oppRecCons);
        lstOpportunities.add(oppRecMM);
        lstOpportunities.add(oppRecEnt);
        
        TestingUtility.insertListWithAssert(lstOpportunities); 
    }
    
    /************************************************************************************************************************************
    Author              : Priyanka Ambre
    Description         : This method tests the isValidOppforSendPaperwork.
    Created Date        : 18 July 2018 
    Issue No            : ST-1045, ST-2201, ST-2327. 
    **************************************************************************************************************************************/
    static testMethod void verifyIsValidOppforSendPaperwork(){  
        Opportunity oppRecCons;
        Opportunity oppRecMM;
        Opportunity oppRecEnt;
        List<Building__c> lstBuilding = new List<Building__c>();
        lstBuilding.add(new Building__c(City__c = 'Amsterdam', Country__c = 'Netherlands',Name = 'AMS-Metropool', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam', uuid__c = 'abc123'));
        lstBuilding.add(new Building__c(City__c = 'Brooklyn',Country__c = 'USA',State__c='TS', Name = 'BKN-Brooklyn Heights',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/New_York',uuid__c = 'abc1234'));
        TestingUtility.insertListWithAssert(lstBuilding);
        
        for(Opportunity objOpp:[SELECT Primary_Member__c, StageName, CloseDate, Membership_Agreement_Notes__c, AccountId, RecordTypeId, RecordType.Name, Type__c FROM Opportunity]){
            if(objOpp.RecordType.Name == 'Consumer'){
                oppRecCons = objOpp;
            }else if(objOpp.RecordType.Name == 'Mid Market'){
                oppRecMM = objOpp;
            }else if(objOpp.RecordType.Name == 'Enterprise Solutions'){
                oppRecEnt = objOpp;
            }
        }
        
        User objUser1;
        User objUserWeWork;
        for(User objUser:[SELECT Id, Email FROM User]){
            if(objUser.Email == 'testUserName1@example.com'){
                objUser1 = objUser;
            }else if(objUser.Email == 'testUser1weWork@example.com'){
                objUserWeWork = objUser;
            }
        }
        
        Test.startTest();
        //MidMarket Opportunity  for closing 
        oppRecMM.Contract_Stage__c = 'Contract Discarded';
        oppRecMM.StageName = 'Selling';
        update oppRecMM;
        System.runAs(objUser1) {
            String resultMMForClosing = SendPaperWorkController.isValidOppforSendPaperwork(oppRecMM.id);
            Map<String, Object> mapResultMMForClosing = (Map<String, Object>)JSON.deserializeUntyped(resultMMForClosing);  
            System.assertEquals(null, mapResultMMForClosing.get('opportunityBuildings'));
            System.assertEquals(false, mapResultMMForClosing.get('isValid'));
            System.assertEquals(false, mapResultMMForClosing.get('isValidOwner')); 
        } 
        
        //MidMarket Opportunity for closing and bypass Profiles
        System.runAs(objUserWeWork) {
            String resultMMForOwner = SendPaperWorkController.isValidOppforSendPaperwork(oppRecMM.id);
            Map<String, Object> mapResultMMForOwner = (Map<String, Object>)JSON.deserializeUntyped(resultMMForOwner);  
            System.assertEquals(null, mapResultMMForOwner.get('opportunityBuildings'));
            System.assertEquals(true, mapResultMMForOwner.get('isValid'));
            System.assertEquals(true, mapResultMMForOwner.get('isValidOwner')); 
        }
        //Enterprise Solutions Opportunity oppRec.Type__c = 'Mixed'
        oppRecEnt.Type__c = 'Mixed';
        update oppRecEnt;
        String resultForProduct = SendPaperWorkController.isValidOppforSendPaperwork(oppRecEnt.id);
        Map<String, Object> mapResultForProduct = (Map<String, Object>)JSON.deserializeUntyped(resultForProduct);  
        System.assertEquals(null, mapResultForProduct.get('opportunityBuildings'));
        System.assertEquals(false, mapResultForProduct.get('isValid'));
        System.assertEquals(false, mapResultForProduct.get('isValidOwner'));
        
        oppRecEnt.Type__c = 'Global Access';
        oppRecEnt.StageName = 'Closing';
        oppRecEnt.Contract_Stage__c = 'Contract Sent';
        update oppRecEnt;
        //Enterprise Solutions Opportunity oppRec.StageName = 'Closing' and oppRec.StageName = 'Closing'
        String resultForContractSent = SendPaperWorkController.isValidOppforSendPaperwork(oppRecEnt.id);
        Map<String, Object> mapResultForContractSent = (Map<String, Object>)JSON.deserializeUntyped(resultForContractSent);  
        System.assertEquals(null, mapResultForContractSent.get('opportunityBuildings'));
        System.assertEquals(false, mapResultForContractSent.get('isValid'));
        System.assertEquals(false, mapResultForContractSent.get('isValidOwner')); 
        
        //Enterprise Solutions Opportunity  for closing  
        oppRecEnt.StageName = 'Closing';
        oppRecEnt.Contract_Stage__c = 'Contract Discarded';
        update oppRecEnt;
        System.runAs(objUser1) {
            String resultEntForClosing = SendPaperWorkController.isValidOppforSendPaperwork(oppRecEnt.id);
            Map<String, Object> mapResultEntForClosing = (Map<String, Object>)JSON.deserializeUntyped(resultEntForClosing);  
            System.assertEquals(null, mapResultEntForClosing.get('opportunityBuildings'));
            System.assertEquals(false, mapResultEntForClosing.get('isValid'));
            System.assertEquals(false, mapResultEntForClosing.get('isValidOwner')); 
        }
        Account objAcc =[SELECT Id, Name, UUID__c, Account_Type__c, ParentId, Parent_Org_Id__c FROM Account WHERE Id=:oppRecEnt.AccountId];
        objAcc.OwnerId =  objUser1.Id;
        update objAcc;
        oppRecEnt.StageName = 'Closing';
        oppRecEnt.Locations_Interested__c = lstBuilding[0].Name;
        oppRecEnt.Building__c = lstBuilding[1].Id;
        oppRecEnt.OwnerId = objUser1.Id;
        update oppRecEnt;
        
        //Enterprise Solutions Opportunity   with same owner as  logged in User
        System.runAs(objUser1) {
            String resultEntForOwnerSame = SendPaperWorkController.isValidOppforSendPaperwork(oppRecEnt.id);
            Map<String, Object> mapResultEntForOwnerSame = (Map<String, Object>)JSON.deserializeUntyped(resultEntForOwnerSame);  
            System.assertNotEquals(null, mapResultEntForOwnerSame.get('opportunityBuildings'));
            System.assertEquals(true, mapResultEntForOwnerSame.get('isValid'));
            System.assertEquals(true, mapResultEntForOwnerSame.get('isValidOwner')); 
        }
        
        //Enterprise Solutions Opportunity Bypass profile
        System.runAs(objUserWeWork) {
            String resultEntForAllowedOwner = SendPaperWorkController.isValidOppforSendPaperwork(oppRecEnt.id);
            Map<String, Object> mapResultEntForAllowedOwner = (Map<String, Object>)JSON.deserializeUntyped(resultEntForAllowedOwner);  
            System.assertNotEquals(null, mapResultEntForAllowedOwner.get('opportunityBuildings'));
            System.assertEquals(true, mapResultEntForAllowedOwner.get('isValid'));
            System.assertEquals(true, mapResultEntForAllowedOwner.get('isValidOwner')); 
        }
        
        //Consumer Opportunity for Building__c  
        System.runAs(objUser1) {
            String resultConsumerForBuilding = SendPaperWorkController.isValidOppforSendPaperwork(oppRecCons.id);
            Map<String, Object> mapResultConsumerForBuilding = (Map<String, Object>)JSON.deserializeUntyped(resultConsumerForBuilding);  
            System.assertEquals(null, mapResultConsumerForBuilding.get('opportunityBuildings'));
            System.assertEquals(false, mapResultConsumerForBuilding.get('isValid'));
            System.assertEquals(false, mapResultConsumerForBuilding.get('isValidOwner')); 
        }
        
        //Consumer everything is good.
        oppRecCons.Building__c = lstBuilding[1].Id;
        update oppRecCons;
        System.runAs(objUser1) {
            String result = SendPaperWorkController.isValidOppforSendPaperwork(oppRecCons.id);
            Map<String, Object> mapResult  = (Map<String, Object>)JSON.deserializeUntyped(result);  
            System.assertEquals(null, mapResult.get('opportunityBuildings'));
            System.assertEquals(true, mapResult.get('isValid'));
            System.assertEquals(true, mapResult.get('isValidOwner'));
        }
        
        DatabaseResult nullResult = SendPaperWorkController.isValidOpportunityforSendPaperwork(null);
        System.assertEquals(null, nullResult.data);
        Test.stopTest(); 
    }
    
   /************************************************************************************************************************************
        Author              : Prashant Mane
        Description         : This method  is used to check GetOpportunityEncodedID .
        Created Date        : 10 Jan 2019
        Issue No.           : CSI-1571
    **************************************************************************************************************************************/
    public static testMethod void verifyGetOpportunityEncodedID() {
        Test.startTest();
        List<Building__c> lstBuildingss = (List<Building__c>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Building__c', 'numberOfRecords' => 4});
        List<Opportunity> lstOpps = (List<Opportunity>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Opportunity', 'numberOfRecords' => 1, 'doInsert' => true, 'mapFieldValues' => new Map<String, List<Object>>{'Contract_Stage__c' => new List<Object>{'Contract Sent'}}});
                
        List<Opportunity> lstOpportunities = [SELECT Id, Primary_Member__c, StageName, CloseDate, Locations_Interested__c, Owner_Auto_Assign__c FROM Opportunity LIMIT 1];
        List<Building__c> lstBuildings = [SELECT Id, Name, uuid__c FROM Building__c LIMIT 2];
        lstOpportunities[0].CloseDate = System.today().addDays(5);
        lstOpportunities[0].Locations_Interested__c = lstBuildings[0].Name+';'+lstBuildings[1].Name;
        lstOpportunities[0].Owner_Auto_Assign__c = true;
        TestingUtility.updateWithAssert(lstOpportunities[0]);
        Test.stopTest();
        
        SendPaperWorkController.ValidResultWithOpp resultObj = (SendPaperWorkController.ValidResultWithOpp)JSON.deserialize(String.valueOf(SendPaperWorkController.isValidOppforSendPaperwork(lstOpportunities[0].Id)), SendPaperWorkController.ValidResultWithOpp.class);
        System.assertEquals(false, resultObj.isValid);
        System.assertEquals(false, resultObj.isValidOwner);
        System.assertEquals(2, resultObj.opportunityBuildings.size());
        
        String encodedId = (String)SendPaperWorkController.getOpportunityEncodedID(lstOpportunities[0].Id);
        System.assertEquals([SELECT Encoded_ID__c FROM Opportunity WHERE Id =: lstOpportunities[0].Id][0].Encoded_ID__c, encodedId); 
        
        try{
            encodedId = (String)SendPaperWorkController.getOpportunityEncodedID(null);//To verify whether the null pointer exception caught by this method or not if null data is passed
        }catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    } 
}