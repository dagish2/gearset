/************************************************************************************************************************************
    Author      :   Nikhil Mehta
    Description :   This class contains test methods for Request New Organization functionality

    History :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                     	DETAIL
    1           20 July 2018        Nikhil Mehta            	Initial Developement	
**************************************************************************************************************************************/
@isTest
public class RequestNewOrganizationControllerTest {
	@TestSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
    }
    
    /****************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method is used to send mail for new orgnanization request.
        Created Date        : 20 July 2018
		Issue No			: ST-2630
   *****************************************************************************************************************************/    
    static testMethod void verifySendOrgRequest(){
        try{
            Test.startTest();
            System.assertEquals(false, RequestNewOrganizationController.sendNewOrganizationRequest(new Account()).data, 'when account is null');
            System.assertEquals(true, RequestNewOrganizationController.sendNewOrganizationRequest(new Account(Name = 'TestOrg', Number_of_Full_Time_Employees__c = 1000, Website = 'www.testorg.com'), new List<String>{'testEmail@example.com'}).data, 'when request send');
            System.assertEquals(1,Limits.getEmailInvocations(), 'email count');
            RequestNewOrganizationController.sendNewOrganizationRequest(null);
            Test.stopTest();
        } catch(Exception exc){
            System.assertNotEquals(null, exc);
        }
    } 
}