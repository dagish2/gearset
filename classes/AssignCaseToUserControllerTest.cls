/************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   This class contain all test methods related to AssignCaseToUserController class.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           10 Jan 2019         Prashant Mane           Initial Developement
**************************************************************************************************************************************/
@isTest
public class AssignCaseToUserControllerTest {
    
    @TestSetup
    static void initData(){ 
        SalesConsoleSettings.createSettings();
        Test.startTest();
        List<User> lstUsers = (List<User>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'User', 'numberOfRecords' => 2});
        List<Opportunity> lstOpportunities = (List<Opportunity>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Opportunity', 'numberOfRecords' => 1, 'doInsert' => true, 'mapFieldValues' => new Map<String, List<Object>>{'Contract_Stage__c' => new List<Object>{'Contract Sent'}}});
        Test.stopTest();
    } 
    
    /************************************************************************************************************************************
		Author         : Nikhil Mehta
		Description    : This method is used to verify assignCaseToUser()
		Created Date   : 05 May 2018 
		Modified By    : Rupesh Patil
		Modified Date 	: 20 Nov 2018
	**************************************************************************************************************************************/    
    public static testMethod void verifyAssignCaseToUser(){
        List<User> lstUsers = [SELECT Id FROM User LIMIT 2];
        List<Case> lstCases = (List<Case>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Case', 'numberOfRecords' => 4});
        List<Opportunity> lstOpportunities = [SELECT Id FROM Opportunity];
        List<OpportunityTeamMember> lstOppoTeams = (List<OpportunityTeamMember>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'oppoteam', 'numberOfRecords' => 2});
        lstOppoTeams[0].TeamMemberRole = 'Real Estate Advisory';
        TestingUtility.insertWithAssert(lstOppoTeams[0]);
        TestingUtility.deleteWithAssert(lstOppoTeams[1]); 
        User testUser = new User();
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name != 'System Administrator' limit 1].Id;                   
        testUser.LastName = 'Test';
        testUser.Email = 'test@test.com'+TestingUtility.createStringValue();
        testUser.Username = 'test@test.com' + System.currentTimeMillis();
        testUser.CompanyName = 'Salesforce';
        testUser.Title = 'Title';
        testUser.Alias = 'Roger';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        Insert testUser;
        System.runAs(testUser){
            Boolean result = (Boolean)AssignCaseToUserController.UpdateCaseToUser(lstCases[0].Id, testUser.Id, true).data;        
            System.assertNotEquals(null,result);
            try{
                result = (Boolean)AssignCaseToUserController.UpdateCaseToUser(null, null, null).data;
                result = (Boolean)AssignCaseToUserController.UpdateCaseToUser(lstCases[0].Id, null, true).data;
           } catch(Exception exc){
                System.assertNotEquals(null, exc);
            }
            Boolean result1 = (Boolean)AssignCaseToUserController.UpdateCaseToUser(lstCases[1].Id, testUser.Id, true).data;
            System.assertNotEquals(null, result1);
        }
        System.runAs(testUser){
            Boolean result2 = (Boolean)AssignCaseToUserController.UpdateCaseToUser(lstCases[0].Id, testUser.Id, true).data;
            System.assertNotEquals(null, result2);
            Boolean result3 = (Boolean)AssignCaseToUserController.UpdateCaseToUser(lstCases[2].Id, testUser.Id, true).data;
            System.assertNotEquals(null, result3);
            Boolean result4 = (Boolean)AssignCaseToUserController.UpdateCaseToUser(lstCases[3].Id, testUser.Id, true).data;
            System.assertNotEquals(null, result4);
        }
    }
    
   /************************************************************************************************************************************
		Author              : Prashant Mane
		Description         : This Method is used to verify getOnLoadAssignCasetoUserData. 
		Created Date        : 01/21/2019
		Issue No.           : CSI-1571
	**************************************************************************************************************************************/
    public static testMethod void verifyGetOnLoadAssignCasetoUserData(){
        List<Case> lstCases = (List<Case>)TestingUtility.getRecords(new Map<String, Object>{'objName' => 'Case', 'numberOfRecords' => 4});
        DatabaseResult onLoadDataResult = AssignCaseToUserController.getOnLoadAssignCaseToUserData(lstCases[0].Id);
        System.assertNotEquals(null , onLoadDataResult);
        
        DatabaseResult onLoadDataResult2 = AssignCaseToUserController.getOnLoadAssignCaseToUserData(null);
        System.assertNotEquals(null , onLoadDataResult2);
    }
}