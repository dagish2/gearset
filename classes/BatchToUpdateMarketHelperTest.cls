/************************************************************************************************************************************
	Author		: 	Krishana Tupe
	Description	: 	This batch class handle Geography insertion using google api account update related market on Account record.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        		AUTHOR                     	DETAIL
	1	    	12 December 2018		Krishana Tupe           	Initial Developement
	2	    	23 January 2019			Krishana Tupe            	Made changes for Lead/Account update Market logic
**************************************************************************************************************************************/
@isTest
public class BatchToUpdateMarketHelperTest {
     @TestSetup
    public static void initData(){
        SalesConsoleSettings.createSettings();
        List<User> lstUserToInsert = new List<User>();
        Profile profileWeworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork System Administrator']; 
        Profile profileWeworkregionalbeta = [SELECT Id FROM Profile WHERE Name='WeWork Regional Sales Lead - Beta']; 
        lstUserToInsert.add(TestingUtility.insertUserWithAssert(profileWeworkSystemAdmin.Id, AccountAssignmentControllerTest.getUserData('Test User 1', 'testweworkuser25219@example.com', 'testweworkuser25219@example.com'), false));      
        lstUserToInsert.add(TestingUtility.insertUserWithAssert(profileWeworkregionalbeta.Id, AccountAssignmentControllerTest.getUserData('CmUser', 'testweworkuser252191@example.com', 'testweworkuser252191@example.com'), false));       
        TestingUtility.insertListWithAssert(lstUserToInsert);
    }  
        
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verify Execute batch chain.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/    
    @isTest
    public static void verifyExecuteBatchInChain(){
        BatchToUpdateMarketHelper.executeBatchInChain(false, false, 'Lead', 80);
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verify get batch size.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/    
	@isTest
    public static void verifyGetBatchSize(){
        Map<String, object> mapUpdateMarketBatchMDT = BatchToUpdateMarketHelper.getUpdateMarketBatchMetadata('UpdateMarketBatchMetadata');       
        System.assert(BatchToUpdateMarketHelper.getBatchSize(mapUpdateMarketBatchMDT, 'Lead') != NULL);
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method returns the Opportunities
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/    
    public static List<Opportunity> getOpportunities(Account objAccount, Contact objContact, Integer size){
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        if(objAccount == NULL){
            objAccount = new Account(Name='Master Account 78', Unomy_Company_ID__c = 12345678, Unomy_Updated_DateTime__c = Date.today(), Lead_Source__c = 'Test78', Account_Type__c = 'Org', Unomy_Location_Address__c = 'USA', Unomy_Location_City__c = 'Seattle', Unomy_Location_State__c = 'Washington', Unomy_Location_Country__c = 'USA', BillingStreet = 'Washington', BillingCity = 'Seattle', BillingState = 'Washington', BillingCountry = 'USA');
            Database.insert(new List<Account>{objAccount}, false);
        }
        if(objContact == NULL){
            objContact = TestingUtility.createContact(new Map<String, Object>{'FirstName' => 'Paul','LastName' => 'enterpriseBoss', 'Email' => 'paul@enterpriseBoss.com', 'AccountId' => objAccount.Id, 'UUID__c' => 'xxx123'}, false);
            Database.insert(new List<Contact>{objContact}, false);
        }
        for(Integer iIndex = 0; iIndex < size; iIndex++){
            lstOpportunities.add(TestingUtility.createOpportunity(new Map<String, Object>{'Name' => 'Enterprise Opportunity1','Primary_Member__c' => objContact.Id, 'AccountId' => objAccount.Id, 'closeDate' => System.today(), 'StageName' => 'Selling', 'Contract_Stage__c' => 'Contract Sent', 'Assignment_Status__c'=> 'On Hold'}, false));
        }
        return lstOpportunities;
    } 
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verify account assignment for on hold.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/    
    @isTest
    public static void verifyFireAccountAssignmentForOnHold(){
        List<Account> lstAccounts = new List<Account>();
        lstAccounts = BatchToUpdateMarketTest.getAccounts(lstAccounts, 1);       
        lstAccounts[0].Processing_Stage__c = 'On Hold';
        Database.insert(lstAccounts, true);
        Contact objContact = TestingUtility.createContact(new Map<String, Object>{'FirstName' => 'Paul','LastName' => 'enterpriseBoss', 'Email' => 'paul@enterpriseBoss.com', 'AccountId' => lstAccounts[0].Id, 'UUID__c' => 'xxx123'}, false);
        Database.insert(new List<Contact>{objContact}, false);
        List<Opportunity> lstOpportunities = getOpportunities(lstAccounts[0], objContact, 3);
        Database.insert(lstOpportunities, true);
        List<Account> lstAccountInserted = [SELECT Id, OwnerId, Owner.Name, Owner.Profile.Name, RecordTypeId, RecordType.Name, Lead_Source__c, Unomy_Company_Size__c, Number_of_Full_Time_Employees__c, Account_Market__c, Account_Market__r.TerritoryID__c, Account_Market__r.TerritoryID__r.RegionID__c, Update_HQ_Market_Status__c, Forcefully_Account_Assignment__c, Processing_stage__c, (SELECT Id, OwnerId, Interested_in_Number_of_Desks__c, Requirement_Quantity__c, Building__c, Owner_Auto_Assign__c FROM Opportunities WHERE Assignment_Status__c='On Hold' ORDER BY CreatedDate) FROM Account WHERE Processing_Stage__c = 'On Hold'];
        System.assertEquals(1, lstAccountInserted.size());
        System.assertEquals(3, lstAccountInserted[0].Opportunities.size());
        Map<Id, Account> mapNewAccounts = new Map<Id, Account>();
        BatchToUpdateMarketHelper.fireAccountAssignmentForOnHold(lstAccountInserted[0]);
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method verify account assignment for on hold.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/    
    @isTest
    public static void verifyCreateRecordsToUpdate(){
        User updatedAdminOwnerUser = [SELECT Id, Email FROM User Where UserName = 'testweworkuser25219@example.com' LIMIT 1];
        Map<String,RecordTypeInfo> mapAccountRecordTypeByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        List<Account> lstAccounts = new List<Account>();
        lstAccounts = BatchToUpdateMarketTest.getAccounts(lstAccounts, 1);
        lstAccounts[0].Processing_Stage__c = 'On Hold';
        lstAccounts[0].Account_Owner_RecordType_For_Batch__c = updatedAdminOwnerUser.Id+';'+mapAccountRecordTypeByName.get('Mid Market').getRecordTypeId();
        Database.insert(lstAccounts, true);
        Contact objContact = TestingUtility.createContact(new Map<String, Object>{'FirstName' => 'Paul','LastName' => 'enterpriseBoss', 'Email' => 'paul@enterpriseBoss.com', 'AccountId' => lstAccounts[0].Id, 'UUID__c' => 'xxx123'}, false);
        Database.insert(new List<Contact>{objContact}, false);
        List<Opportunity> lstOpportunities = getOpportunities(lstAccounts[0], objContact, 3);
        for(Opportunity objOpportunity : lstOpportunities){
            objOpportunity.Assignment_Status__c = 'Completed';
        }
        Database.insert(lstOpportunities, true);
        List<Account> lstAccountInserted = [SELECT Id, OwnerId, Owner.Name, Owner.Profile.Name, RecordTypeId, RecordType.Name, Lead_Source__c, Unomy_Company_Size__c, Number_of_Full_Time_Employees__c, Account_Market__c, Account_Market__r.TerritoryID__c, Account_Market__r.TerritoryID__r.RegionID__c, Update_HQ_Market_Status__c, Forcefully_Account_Assignment__c, Processing_stage__c, Account_Owner_RecordType_For_Batch__c, (SELECT Id, OwnerId, Interested_in_Number_of_Desks__c, Requirement_Quantity__c, Building__c, Owner_Auto_Assign__c FROM Opportunities ORDER BY CreatedDate) FROM Account WHERE Processing_Stage__c = 'On Hold'];
        Map<Id, Account> mapNewAccounts = new Map<Id, Account>(lstAccountInserted);
        Map<Id, Account> mapOldAccounts = mapNewAccounts.deepClone();
        System.assertEquals(1, lstAccountInserted.size());
        System.assertEquals(3, lstAccountInserted[0].Opportunities.size());
        BatchToUpdateMarketHelper.changeOwnerAndRecordTypeId(lstAccountInserted[0]);
        System.assertEquals(updatedAdminOwnerUser.Id, lstAccountInserted[0].OwnerId);
        System.assertEquals(mapAccountRecordTypeByName.get('Mid Market').getRecordTypeId(), lstAccountInserted[0].RecordTypeId);        
       	BatchToUpdateMarketHelper.createRecordsToUpdate(mapNewAccounts.values(), mapOldAccounts);
        List<sObject> lstRecordsToUpdate = BatchToUpdateMarketHelper.getRecordsFromMap(BatchToUpdateMarketHelper.mapSObjectsToUpdate);
        System.assertEquals(0, lstRecordsToUpdate.size());
    }
}