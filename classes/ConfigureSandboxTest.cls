/************************************************************************************************************************************
  Author     	: Priyanka Ambre
  Description 	: This class is used to test ConfigureSandbox.
   
History:
----------------------------------------------------------------------------------------------------------------------------------
  VERSION      	DATE        		AUTHOR          	DETAIL              	ISSUE
	1			24th August 2018   	Priyanka Ambre     	Initial Developement    ST-  	
**************************************************************************************************************************************/
@isTest
public class ConfigureSandboxTest {
	@TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
    }
    
    /************************************************************************************************************************************
        Author              :   Priyanka Ambre
        Description         :   
        Created Date  		:   24th August 2018
        Issue No			:	ST-
     ***************************************************************************************************************************************/
    public static testMethod void createUsersTest() { 
        Test.startTest();
        ConfigureSandbox objConfigureSandbox = new ConfigureSandbox();
        System.debug('In Test Methods ');
        Test.testSandboxPostCopyScript(
            objConfigureSandbox,  UserInfo.getOrganizationId(),
            UserInfo.getOrganizationId(), 'TestSandBox');
        Integer invocations = Limits.getEmailInvocations();
		
        ConfigureSandbox.SandboxWrapper objSandboxWrapper = (ConfigureSandbox.SandboxWrapper)JSON.deserialize(Settings.get('SandboxConfiguration').Data__c, ConfigureSandbox.SandboxWrapper.class);
        Map<String,Map<String,String>> mapUsers = objSandboxWrapper.users;
        Map<String,List<String>> mapSandboxes = objSandboxWrapper.sandboxes;
        List<String> lstUsersName = mapSandboxes.get('TestSandBox');
        List<String> lstUsersEmail = new List<String>();
        for(String strUserName:lstUsersName){
            if(mapUsers.containsKey(strUserName)){
                Map<String,String> objUserTemplate = mapUsers.get(strUserName);
                lstUsersEmail.add(objUserTemplate.get('email'));
            }
        }
        for(User userObj : [SELECT Id, Name, Username, Email FROM User WHERE Email IN : lstUsersEmail]){
            if(userObj.Email == 'testuser1@example.com'){
                System.assertEquals('testuser1@wework.com.testsandbox', userObj.Username);
            }else if(userObj.Email == 'testuser2@example.com'){
                System.assertEquals('testuser2@wework.com.testsandbox', userObj.Username);
            }
        }
        
        ConfigureSandbox.resetPassword('TestSandBox');
        Test.stopTest();
    }
}