/************************************************************************************************************************************
    Author      :   Ashish Mishra	
    Description :   This class will contains the test method of TrUserFederationIDUpdate.
	Issue No    : 	ST-3149
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           24 November 2018    Ashish Mishra           Initial Developement
**************************************************************************************************************************************/
@isTest
public class TrUserFederationIDUpdateTest {
    static String emailDomain = 'UserFederationIDUpdate.com';
    @testSetup
    static void initData(){
        SalesConsoleSettings.createSettings();        
		TestingUtility.getRecords(new Map<String, Object>{'objName'=>'User', 'emailDomain'=>emailDomain, 'numberOfRecords'=>4});
        String strQuery = 'SELECT Id, Email, Username FROM User WHERE Email LIKE \'%' + emailDomain + '\'';
        List<User> lstUsers = Database.query(strQuery);
        System.assertEquals(4, lstUsers.size());
    }
    
    /************************************************************************************************************************************
            Author         : Ashish Mishra
            Description    : This method is used to cover, user federationID when we enter email of user at the time of user insertion.
            Created Date   : 24 Nov 2018 
            Issue No       : ST-3149
    **************************************************************************************************************************************/
    public static testMethod void verifyFederationIdIsPopulatedOrNot() { 
        String strQuery = 'SELECT Id, Email, Username, FederationIdentifier FROM User WHERE Email LIKE \'%' + emailDomain + '\'';
        List<User> lstUsers = Database.query(strQuery);
        System.assertEquals(4, lstUsers.size());
        for(User objUser : lstUsers){
            System.assertEquals(objUser.Username, objUser.FederationIdentifier);
        }
        
        List<String> lstFederationIds = new List<String>{'Federation Id 1', '', 'Federation Id 2', ''};
        for(Integer iIndex = 0; iIndex < lstFederationIds.size(); iIndex++){
            lstUsers[iIndex].FederationIdentifier = lstFederationIds[iIndex];
        }
        
        update lstUsers;
        
        Integer iIndex = 0;
        for(User objUser : [SELECT LastName, Name, Email, Username, FederationIdentifier FROM User WHERE Email LIKE 'testUserEmail%']){
            System.assert(String.isNotBlank(objUser.FederationIdentifier), 'Federation Id is not inserted.');
            if(iIndex == 1 || iIndex == 3){
                System.assertEquals(objUser.Username, objUser.FederationIdentifier);
            }            
            iIndex++;            
        }        
    }
    public static testMethod void verifyFederationIdOnUsernameChange(){
        String strQuery = 'SELECT Id, Email, Username, FederationIdentifier FROM User WHERE Email LIKE \'%' + emailDomain + '\'';
        List<User> lstUsersForUpdateUsername = Database.query(strQuery);
        lstUsersForUpdateUsername[0].Username = 'testingUserNameChange@check.com';
        TestingUtility.updateWithAssert(lstUsersForUpdateUsername[0]);        
        List<User> lstUsersForUpdateUsername1 = Database.query(strQuery);
        System.assertEquals(lstUsersForUpdateUsername1[0].Username, lstUsersForUpdateUsername1[0].FederationIdentifier);
    }
}