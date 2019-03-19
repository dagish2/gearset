/************************************************************************************************************************************
    Author 		: 	Krishana Tupe	
    Description : 	This class verify the insertion of exception into rollbar.
    
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL
    1			23 April 2018		Krishana Tupe			Initial Developement
    2			03 May 2018 		Krishana Tupe			Changes for exception logging.
   	3			06 Aug 2018 		Krishana Tupe			Changes for exception logging.
**************************************************************************************************************************************/
@isTest
public class QueueableForRollbarExceptionLogTest {

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
	Description 		: 	This method is used to verify exception log in rollbar functionality.
	Created Date		:	01 Aug 2018 	
**************************************************************************************************************************************/   
    public static testmethod void verifyRollbarExceptionInsertion(){
        try{
            LogExceptionTriggerHandlerTest.getException();
        }catch(Exception pEx){
            List<Apex_Debug_Log__c> lstLogsTobeCreated = [Select Id,ReplayId__c,Apex_Class__c,ApexLogId__c,Message__c,Method__c,Record_Id__c,Stack_Trace__c,Login_UserId__c,Login_User_ProfileId__c,InstanceName__c From Apex_Debug_Log__c ORDER BY CreatedDate DESC];
            Debug.log('lstLogsTobeCreatedIn Rollbar ==>'+lstLogsTobeCreated);
            Test.setMock(HttpCalloutMock.class, new MockResponseForApexDebugLog());           
            ID jobID = System.enqueueJob(new QueueableForRollbarExceptionLog(lstLogsTobeCreated));            
            debug.log('QueueableForRollbarExceptionLog Job Information==>'+jobID); 
            System.assert(jobID != null);  
             new QueueableForRollbarExceptionLog();
            new QueueableForRollbarExceptionLog(pEx,'123456789101115','QueueableForRollbarExceptionLogTest','verifyRollbarExceptionInsertion');
        }        
    }
}