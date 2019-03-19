/************************************************************************************************************************************
    Author 		: 	Krishana Tupe	
    Description : 	This class verify the business logic of exception logging.
    
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL
    1			23 April 2018		Krishana Tupe			Initial Developement
    2			03 May 2018 		Krishana Tupe			Changes for exception logging.
**************************************************************************************************************************************/
@isTest
public class ApexDebugLogTest {
     public static final Integer ZERO = 0;
    
 /************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to setup the settings data.
	Created Date		:	01 Aug 2018 	
 **************************************************************************************************************************************/
    @TestSetup
    public static void testSetup(){
        SalesConsoleSettings.createSettings();  
    }  
   
  /************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to verify exception record is created or not when exception is occured.
	Created Date		:	01 Aug 2018 	
**************************************************************************************************************************************/
    public static testmethod void verifylogException(){
        try{
            LogExceptionTriggerHandlerTest.getException();
        }catch(Exception pEx){
            Test.setMock(HttpCalloutMock.class, new MockResponseForApexDebugLog());
            Debug.log('pEx in verifyApexDebugLogsException==>'+pEx);             
            List<Apex_Debug_Log__c> lstApexDebugLogs = [Select Id,ReplayId__c,Apex_Class__c,ApexLogId__c,Message__c,Method__c,Record_Id__c,	Stack_Trace__c,Login_UserId__c,Login_User_ProfileId__c,InstanceName__c From Apex_Debug_Log__c ORDER BY CreatedDate DESC];
            Debug.log('lstApexDebugLogs==>'+lstApexDebugLogs);
            System.assert(lstApexDebugLogs != null);
            System.assertEquals('LogExceptionTriggerHandlerTest',lstApexDebugLogs[0].Apex_Class__c);            
            System.assertEquals(pEx.getMessage(),'Exception thrown from LogExceptionTriggerHandlerTest.getException() : System.DmlException: '+lstApexDebugLogs[0].Message__c	);
            System.assertEquals('getException',lstApexDebugLogs[0].Method__c);
            System.assertEquals(UserInfo.getUserId(),lstApexDebugLogs[0].Login_UserId__c);
            System.assertEquals(UserInfo.getProfileId(),lstApexDebugLogs[0].Login_User_ProfileId__c); 
        }
    }  
/************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to verify current sandbox name.
	Created Date		:	01 Aug 2018 	
**************************************************************************************************************************************/
    public static testmethod void verifyGetSandboxName(){
        String sandBoxName =  ApexDebugLog.getSandboxName();
        Debug.log('sandBoxName==>'+sandBoxName);
        System.assert(sandBoxName != null);
    }
    
 /************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to verify execute restapiresult log record.
	Created Date		:	01 Aug 2018 	
**************************************************************************************************************************************/   
    public static testmethod void verifylogRESTAPIResult(){
        try{
           LogExceptionTriggerHandlerTest.getException();
        }catch(Exception pEx){
            RESTAPI.PayloadDetails payload = new RESTAPI.PayloadDetails();
            Test.setMock(HttpCalloutMock.class, new MockResponseForApexDebugLog());
            payload.Service = 'Tour';
            payload.Version = 2;
            ApexDebugLog.logRESTAPIResult(pEx, null,payload,null);
            List<REST_API_Log__c> lstRestApiRecords = [Select Id,Name,Status__c,Result__c,Input_Payload__c,Service__c,Version__c,Logged_In_User__c From REST_API_Log__c];
            Debug.log('lstRestApiRecords==>'+lstRestApiRecords);
            System.assert(lstRestApiRecords != null);
            System.assertEquals('Tour',lstRestApiRecords[0].Service__c); 
            System.assertEquals(2,lstRestApiRecords[0].Version__c);
            System.assertEquals(UserInfo.getUserId(),lstRestApiRecords[0].Logged_In_User__c);
        }
    }
    
  /************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to verify invoker.
	Created Date		:	01 Aug 2018 	
**************************************************************************************************************************************/  
    public static testmethod void verifyRegisterRootInvoker(){
        Boolean isregister = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.Triggered, 'ApexDebugLogTest', ApexDebugLog.InvokerType.Triggered); 
        system.assertEquals(true, isregister);
        isregister = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.Triggered, 'ApexDebugLogTest', ApexDebugLog.InvokerType.Triggered); 
        system.assertEquals(false, isregister);
        Boolean isRootInvoker = ApexDebugLog.isRootInvoker(ApexDebugLog.InvokerType.Triggered);
        system.assertEquals(true, isRootInvoker);
    }
        
 /************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to verify getAccessToken and REST callout.
	Created Date		:	01 Aug 2018 	
**************************************************************************************************************************************/
    public static testmethod void vaerifyGetAccessToken(){
        Test.setMock(HttpCalloutMock.class, new MockResponseForApexDebugLog());
        Test.startTest();
        Map<String,String> mapAccessTokenData = ApexDebugLog.getAccessToken();
        Test.stopTest();
        System.assert(mapAccessTokenData != null);
        System.assert(mapAccessTokenData.containsKey('setEndpoint'));
    }
    
  /************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to verify getAccessToken and REST callout.
	Created Date		:	01 Aug 2018 	
**************************************************************************************************************************************/
    public static testmethod void vaerifyExecuteRestForAccessToken(){
        Test.setMock(HttpCalloutMock.class, new MockResponseForApexDebugLog());
        Test.startTest();
        String accessTokenString = ApexDebugLog.executeRest('accessToken', 'https://test.salesforce.com/executeRest', 'body');
        Test.stopTest();
        System.assert(accessTokenString != null);   
    }
    
 /************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to verify getAccessToken and REST callout.
	Created Date		:	01 Aug 2018 	
**************************************************************************************************************************************/
    public static testmethod void vaerifyExecuteRestForREST(){
        Test.setMock(HttpCalloutMock.class, new MockResponseForApexDebugLog());
        Test.startTest();
        String responseForRest = ApexDebugLog.executeRest('https://test.salesforce.com/executeRest', 'body');
        Test.stopTest();
        System.assert(responseForRest != null);   
    }
    
 /************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to verify old functionality of create log exception record with error type.
	Created Date		:	01 Aug 2018 	
**************************************************************************************************************************************/
   public  static testmethod void verifyCreateLog(){
        Integer intVal = 9;
        try{
            throw new ApexDebugLogException('Test Exception');
        } catch (Exception ex){
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('ApexDebugLogTest','verifyCreateLog',String.valueOf(ApexDebugLogTest.ZERO),ex)
            );
            List<Apex_Debug_Log__c> lstDebug = [Select Id,ReplayId__c,Type__c,Apex_Class__c,ApexLogId__c,Message__c,Method__c,Record_Id__c,	Stack_Trace__c,Login_UserId__c,Login_User_ProfileId__c,InstanceName__c From Apex_Debug_Log__c ORDER BY CreatedDate DESC];            
            System.assert(lstDebug.size() > 0, 'Log record should be created.');
            System.assertEquals(lstDebug[0].Type__c, 'Error', 'Type should be Error.');
        }
    }
 
/************************************************************************************************************************************
	Author 				: 	Krishana Tupe
	Description 		: 	This method is used to verify old functionality of create log exception record with Warming type.
	Created Date		:	01 Aug 2018 	
**************************************************************************************************************************************/
    public  static testmethod void verifyCreateLogWarning(){
        Integer intVal = 0;
        try{
            if (intVal < 5) throw new OtherException('This is bad');
        }catch (Exception ex){
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Warning('ApexDebugLogTest','verifyCreateLogWarning',String.valueOf(intVal),'Test Warning..')
            );
        }
        List<Apex_Debug_Log__c> lstDebug = [Select Id,ReplayId__c,Apex_Class__c,ApexLogId__c,Message__c,Method__c,Record_Id__c,	Stack_Trace__c,Login_UserId__c,Login_User_ProfileId__c,InstanceName__c From Apex_Debug_Log__c ORDER BY CreatedDate DESC];          
        System.assert(lstDebug.size() > 0, 'Log record should be created.');
    }
    
    public class ApexDebugLogException extends Exception {}
    public class OtherException extends Exception {}

}