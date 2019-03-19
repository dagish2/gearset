/************************************************************************************************************************************
    Author 		: Krishana Tupe
    Description : This class is used to test LogExceptionTriggerHandler

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1.0			02 May 2018			Krishana Tupe			Initial Developement.
**************************************************************************************************************************************/
@isTest
public class LogExceptionTriggerHandlerTest { 
        
    /************************************************************************************************************************************
        Author 				: 	Krishana Tupe
        Description 		: 	This method is used verify the functionality of insert platform event and get apex debug log record.
        Created Date		:	03 May 2018
        Last Modified By 	: 	Krishana Tupe
        Last Modified Date  : 	03 May 2018
    **********************************************************************************************************************************************/
    public testmethod static void verifyApexDebugLogsExceptionUsingPlatformEvent(){   
        try{
            Test.startTest();
            LogException__e newEvent = new LogException__e(
                Apex_Class__c = 'strClassName',
                ErrorLineNumber__c = 5,
                Exception_Type__c = 'Error',
                ExceptionTypeName__c = 'ex.getTypeName()', 
                Message__c = 'ex.getMessage()',
                Method__c = 'strMethodName',
                Record__c = 'listRecordIds',
                Login_User_ProfileId__c =  UserInfo.getProfileId(),
                Login_UserId__c         =  UserInfo.getUserId(),            
                Stack_Trace__c = 'ex.getStackTraceString()'            
            );
            // Call method to publish events
            Database.SaveResult sr = EventBus.publish(newEvent);
            Debug.log('Result of publish Event==>'+sr); 
            Test.stopTest();
            
            List<Apex_Debug_Log__c> lstApexDebugLogs = [Select Id,Apex_Class__c,ApexLogId__c,Message__c,Method__c,Record_Id__c,	Stack_Trace__c,Login_UserId__c,Login_User_ProfileId__c From Apex_Debug_Log__c];
            Debug.log('lstApexDebugLogs==>'+lstApexDebugLogs);
            System.assert(lstApexDebugLogs != null);
            System.assertEquals('strClassName',lstApexDebugLogs[0].Apex_Class__c);
            System.assertEquals('ex.getMessage()',lstApexDebugLogs[0].Message__c	);
            System.assertEquals('ex.getStackTraceString()',lstApexDebugLogs[0].Stack_Trace__c);
            System.assertEquals('strMethodName',lstApexDebugLogs[0].Method__c);
            System.assertEquals(UserInfo.getUserId(),lstApexDebugLogs[0].Login_UserId__c);
            System.assertEquals(UserInfo.getProfileId(),lstApexDebugLogs[0].Login_User_ProfileId__c); 
            
        }catch(Exception pEx) { 
            ApexDebugLog.logException(pEx,'Test Exception', 'LogExceptionTriggerHandlerTest', 'verifyApexDebugLogsExceptionUsingPlatformEvent');            
            throw new ApexDebugLog.ApexLogCustomException('Exception thrown from LogExceptionTriggerHandlerTest.verifyApexDebugLogsExceptionUsingPlatformEvent() : '+pEx);
        }
    }  
 /************************************************************************************************************************************
        Author 				: 	Krishana Tupe
        Description 		: 	This method is used to create custom exception.
        Created Date		:	29 May 2018
        Last Modified By 	: 	Krishana Tupe
        Last Modified Date  : 	29 May 2018
    **********************************************************************************************************************************************/ 
    public static void getException(){
        try{
            insert new Lead();
        }catch(Exception pEx){           
            Test.startTest();
            ApexDebugLog.logException(pEx,'Test Exception', 'LogExceptionTriggerHandlerTest', 'getException');
            List<Apex_Debug_Log__c> lstApexDebugLogs = [Select Id,ReplayId__c,Apex_Class__c,ApexLogId__c,Message__c,Method__c,Record_Id__c,	Stack_Trace__c,Login_UserId__c,Login_User_ProfileId__c From Apex_Debug_Log__c ORDER BY CreatedDate DESC];            
            Test.stopTest();
            throw new ApexDebugLog.ApexLogCustomException('Exception thrown from LogExceptionTriggerHandlerTest.getException() : '+pEx);  
        }
    }
    
   /************************************************************************************************************************************
        Author 				: 	Krishana Tupe
        Description 		: 	This method is used verify the log exception functionality.
        Created Date		:	29 May 2018
        Last Modified By 	: 	Krishana Tupe
        Last Modified Date  : 	29 May 2018
    **********************************************************************************************************************************************/ 
    public testmethod static void verifyApexDebugLogsException(){
        try{
            getException();
        }catch(Exception pEx){
            Debug.log('pEx in verifyApexDebugLogsException==>'+pEx);             
           List<Apex_Debug_Log__c> lstApexDebugLogs = [Select Id,ReplayId__c,Apex_Class__c,ApexLogId__c,Message__c,Method__c,Record_Id__c,	Stack_Trace__c,Login_UserId__c,Login_User_ProfileId__c From Apex_Debug_Log__c ORDER BY CreatedDate DESC];
            Debug.log('lstApexDebugLogs==>'+lstApexDebugLogs);
            System.assert(lstApexDebugLogs != null);
            //System.assert(String.isNotBlank(String.valueOf(lstApexDebugLogs[0].ReplayId__c)));
            System.assertEquals('LogExceptionTriggerHandlerTest',lstApexDebugLogs[0].Apex_Class__c);            
            System.assertEquals(pEx.getMessage(),'Exception thrown from LogExceptionTriggerHandlerTest.getException() : System.DmlException: '+lstApexDebugLogs[0].Message__c	);
            System.assertEquals('getException',lstApexDebugLogs[0].Method__c);
            System.assertEquals(UserInfo.getUserId(),lstApexDebugLogs[0].Login_UserId__c);
            System.assertEquals(UserInfo.getProfileId(),lstApexDebugLogs[0].Login_User_ProfileId__c); 
        }
    }
    
}