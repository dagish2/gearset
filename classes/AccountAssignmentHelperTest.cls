/************************************************************************************************************************************
Author 		: 	Pragalbha Mahajan
Description : 	This class contains test methods for Account assignment helper.
History		:
----------------------------------------------------------------------------------------------------------------------------------
VERSION		DATE				AUTHOR					DETAIL
1			30 Jan 2019	        Pragalbha Mahajan     	Initial Development	 
**************************************************************************************************************************************/
@isTest
public class AccountAssignmentHelperTest {
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to setup test data.
    Issue No.			:	ST-3391
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    @testSetup
    static void setup(){
        SalesConsoleSettings.createSettings();
        String recTypeComsumerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
        String recTypeMidMarketId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mid_Market').getRecordTypeId();
        List<Account> lstAccounts = new List<Account>();
        Map<String, Object> accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName1',
            'Account_Type__c' => 'Org',
            'RecordTypeId' => recTypeComsumerId,
            'Unomy_Location_Country__c' => 'Australia',
            'Number_of_Full_Time_Employees__c' => 18};
        lstAccounts.addAll(TestingUtility.getAccountsByType(accountValuesMap, 'Org', 1));
        
        accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName2',
            'Account_Type__c' => 'Org',
            'RecordTypeId' => recTypeMidMarketId};     
        lstAccounts.addAll(TestingUtility.getAccountsByType(accountValuesMap, 'Org', 1));
		TestingUtility.insertListWithAssert(lstAccounts);
        
        List<Profile> lstProfile  = [SELECT Id FROM Profile WHERE Name='Wework System Administrator' OR Name = 'System Administrator'];
        List<User> lstUsers = new List<User>();
            Map<String,Object> userRecordMap = new Map<String,Object>{'LastName' => 'Last Name 1',
               'Username' =>  'testweworkuser1@example.com',
                'Email' => 'testweworkuser1@example.com'};
            lstUsers.add(TestingUtility.insertUserWithAssert(lstProfile[0].Id, userRecordMap, false));
            
            userRecordMap = new Map<String,Object>{'LastName' => 'Last Name 2',
               'Username' =>  'testweworkuser2@example.com',
                'Email' => 'testweworkuser2@example.com'};
            lstUsers.add(TestingUtility.insertUserWithAssert(lstProfile[1].Id, userRecordMap, false));
            
            TestingUtility.insertListWithAssert(lstUsers);
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to Verify get record type name by Id.
    Issue No.			:	ST-3391
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    @isTest
    public static void verifyGetRecordTypeNameById(){
        Account objAccount = [SELECT Id, Name, RecordTypeId, RecordType.Name FROM Account LIMIT 1];
        String recordTypeName = AccountAssignmentHelper.getRecordTypeNameById('Account', objAccount.RecordTypeId);
        System.assertEquals(objAccount.RecordType.Name, recordTypeName);
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to Verify profile and user for assignment.
    Issue No.			:	ST-3391
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    @isTest
    public static void verifyValidProfileAndUserForAssignment(){
        List<User> lstUsers = [SELECT Id, Name, Email, ProfileId, Profile.Name FROM User WHERE Profile.Name = 'Wework System Administrator' LIMIT 1];
        debug.log('lstUsers: '+lstUsers);
        System.assertEquals(True, AccountAssignmentHelper.isValidProfileAndUserForAssignment(lstUsers[0].Id));
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to Verify user is API user or not.
    Issue No.			:	ST-3391
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    @isTest
    public static void verifyIsAPIUser(){
        List<User> lstUsers = [SELECT Id, Name FROM User WHERE Id = '005F0000003Kmbw'];
        debug.log('lstUsers: '+lstUsers);
        System.assertEquals(True, AccountAssignmentHelper.isApiUser('UserId', lstUsers[0].id));
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to Verify check change account owner conditions.
    Issue No.			:	ST-3391
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    @isTest
    public static void verifyCheckChangeAccountOwnerConditions(){
        Account objAccount = [SELECT Id, Name, RecordTypeId, RecordType.Name, OwnerId FROM Account LIMIT 1];
        System.assertEquals(True, AccountAssignmentHelper.checkValidUserForAssignment(objAccount.OwnerId));
        AccountAssignmentHelper.getUpdatedAccountRecordTypeId(objAccount);
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to Verify get record Type Of Account by CompanySize.
    Issue No.			:	ST-3391
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    @isTest
    public static void verifyGetRecordTypeOfAccountUsingCompanySize(){
        Id recordId = AccountAssignmentHelper.getRecordTypeOfAccountUsingCompanySize(92);
        System.assertEquals(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId(), recordId);
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to Verify get lower size from range.
    Issue No.			:	ST-3391
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    @isTest
    public static void verifyGetLowerSize(){
        Integer strLowerSize = AccountAssignmentHelper.getLowerSize('20-50');
        System.assertEquals(20, strLowerSize);
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to Verify check referral lead source.
    Issue No.			:	ST-3391
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    @isTest
    public static void verifyCheckReferralLeadSource(){
        System.assertEquals(false, AccountAssignmentHelper.checkReferralLeadSource('Broker'));
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to Verify get allowed record type from metadata.
    Issue No.			:	ST-3391
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    @isTest
    public static void verifyGetAllowedRecordTypes(){
       Set<String> setAllowedRecordTypes = AccountAssignmentHelper.getAllowedRecordTypes('allowRecordTypes');   
       System.assertNotEquals(null, setAllowedRecordTypes);
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to Verify get record Type Of Account by CompanySize.
    Issue No.			:	ST-3391
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    @isTest
    public static void verifygetRecordTypeIdFromCompanySize(){
        Account objAccount = [SELECT Id, Name, RecordTypeId, RecordType.Name, OwnerId, Unomy_Company_Size__c, Number_of_Full_Time_Employees__c FROM Account WHERE Number_of_Full_Time_Employees__c != null LIMIT 1];
        System.assertEquals(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId(), AccountAssignmentHelper.getRecordTypeIdFromCompanySize(objAccount));
        AccountAssignmentHelper.getAccountFromMap(objAccount.Id);
    }
}