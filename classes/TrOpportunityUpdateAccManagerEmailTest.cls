/************************************************************************************************************************************
    Author 		: 	Chandra Teja
    Description : 	This class will contain all the test method of TrOpportunityUpdateAccountMangerEmail.
    History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			19 February 2019	ChandraTeja     	Initial Development	 
**************************************************************************************************************************************/
@isTest
public class TrOpportunityUpdateAccManagerEmailTest {
	
    @testSetup
    static void setup() {
        SalesConsoleSettings.createSettings();
        List<User> lstUsers = (List<User>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'User', 'numberOfRecords' => 1});
        Map<String, Object> mapAccountData = new Map<String, Object>();
        mapAccountData.put('Name', 'TestAccountManger');
        mapAccountData.put('Account_Manager_Lookup__c', lstUsers[0].Id);
        Account testManagerAccount = TestingUtility.createAccount(mapAccountData, true);
        
        Map<String, Object> mapOpportunityData = new Map<String, Object>();
        Map<String, List<Object>> mapFieldForOpportunity = new Map<String, List<Object>>();
        mapFieldForOpportunity.put('StageName', new List<Object>{'Selling'});
        mapFieldForOpportunity.put('AccountId', new List<Object>{testManagerAccount.Id});
        mapFieldForOpportunity.put('CloseDate', new List<Object>{system.today().addDays(5)});
        
        mapOpportunityData.put('objName', 'Opportunity');
        mapOpportunityData.put('numberOfRecords', 1);
        mapOpportunityData.put('doInsert', true);
        mapOpportunityData.put('mapFieldValues', mapFieldForOpportunity);
        List<Opportunity> lstOpportunities = TestingUtility.getRecords(mapOpportunityData);
        System.assertEquals(1, lstOpportunities.size());
    }
    
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This method is used to unit test populate account manager's email value on insertion
        Created Date    : 19 February 2019 
        Issue No        : ST-3430
    **************************************************************************************************************************************/
    @isTest
    static void testUpdateAccountManagerEmail(){
        List<Account> lstAccounts = [SELECT Id, Account_Manager_Lookup__c, Account_Manager_Lookup__r.Email FROM Account];
        List<Opportunity> lstOpportunities = [SELECT Id, Account_Manager_Email__c FROM Opportunity WHERE AccountId = :lstAccounts[0].Id];
        System.assert(String.isNotBlank(lstOpportunities[0].Account_Manager_Email__c));
        system.assertEquals(lstAccounts[0].Account_Manager_Lookup__r.Email, lstOpportunities[0].Account_Manager_Email__c);
    }
}