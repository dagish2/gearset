/************************************************************************************************************************************
    Author      :   Shobhit Gahlot 
    Description :   This class contains the test methods test ozonetel end point.

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           29 March 2018        ---                    Initial Developement
    2           26 April 2018        ---					AutoRabbit Commit
**************************************************************************************************************************************/
@isTest 
public class OzonetelHelperTest {

	Public Static List<Lead> lstleads = new List<Lead>(); 
    Public Static List<Task> lstTasks = new List<Task>(); 
    static{
        SalesConsoleSettings.createSettings();
        
		Lead lead1 = new Lead();
        lead1.Company = 'enzigma';
        lead1.LeadSource = 'Book A Form';
        lead1.LastName = 'test 1';
        lead1.Email = 'testlead1@enzigma.com';
        lead1.Phone = '1234567891';
        lstleads.add(lead1);
        TestingUtility.insertListWithAssert(lstleads);
            
        Task task1 = new Task();
        task1.WhoId = lstleads[0].Id;
        task1.Description = 'Test data';
        task1.CallDisposition = 'Test';
        task1.ActivityDate = Date.newInstance(2018, 03, 29);
        task1.FastCall__Call_Id__c = '397992175979271';
        lstTasks.add(task1);
        TestingUtility.insertListWithAssert(lstTasks);
    }
    public static testMethod void testUpdateActivity(){
        
        Test.startTest();
        //Initialising request and response obj
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        //Initialising request body
        req.requestBody = Blob.valueOf('{"AgentPhoneNumber":"09282339141 -> 09282333","Disposition":"","Skill":"Elidi","TimeToAnswer":"","AgentID":"libin -> sadhasivam","EndTime":"2015-04-06 15:16:54","DialedNumber":"libin -> sadhasivam","AgentStatus":"","DialStatus":"Not Answered","Status":"Answered","AgentName":"libin -> Sadhasivam","CallerID":"99404495","AudioFile":"https://test.audio.mp3","FallBackRule":"AgentDial -> AgentDial","Apikey":"KK1fa49366ed32f8724adad01c82fa3d74","PhoneName":"libin -> sadhasivam","Did":"914466949426","HangupBy":"UserHangup","StartTime":"2015-04-06 15:16:22","Type":"inboun","TransferredTo":"","TransferType":"No Transfers","Comments":"","UUI":"UUI","CustomerStatus":"","AgentUniqueID":"19434 -> 19543","Location":"CHN","Duration":"None","monitorUCID":"397992175979271","CallDuration":"00:11:21"}');
        req.requestURI = '/services/apexrest/Ozonetel';  
        req.httpMethod = 'POST';
		Debug.log('requestURI --- > '+req.requestURI);
        RestContext.request     = req;
        RestContext.response    = res;
        RESTOzonetel.Response response = RESTOzonetel.doPost();
        Debug.log('Response From REST API :::'+response);
        Test.stopTest();
        System.assertEquals('Activity Updated on SF', response.message, 'Not able to update the record');
        String audio = 'https://test.audio.mp3';
        String CallDurationRaw='00:11:21';
        Integer CallDurationInSeconds = Integer.valueOf(CallDurationRaw.split(':')[0])*3600+Integer.valueOf(CallDurationRaw.split(':')[1])*60+Integer.valueOf(CallDurationRaw.split(':')[2]);
        Task objUpdatedTask = [Select Id,FastCall__Call_Recording__c,CallDurationInSeconds,FastCall__Call_Id__c from Task Where Id=:lstTasks[0].Id];
        System.assertEquals(audio, objUpdatedTask.FastCall__Call_Recording__c, 'Audio Url Not Updatedon Activity');
        System.assertEquals(CallDurationInSeconds, objUpdatedTask.CallDurationInSeconds, 'CallDurationInSeconds not updated on Activity');
        System.assertEquals('397992175979271', objUpdatedTask.FastCall__Call_Id__c, 'UCID Not Updated on Activity');
    }
    public static testMethod void testUpdateActivity2(){
        Lead lead1 = new Lead();
        lead1.Company = 'enzigma';
        lead1.LeadSource = 'Book A Form';
        lead1.LastName = 'test 1';
        lead1.Email = 'testlead1@enzigma.com';
        lead1.Phone = '1234567891';
        TestingUtility.insertWithAssert(lead1);
            
        Task task1 = new Task();
        task1.WhoId = lstleads[0].Id;
        task1.Description = 'Test data';
        task1.CallDisposition = 'Test';
        task1.ActivityDate = Date.newInstance(2018, 03, 29);
        task1.FastCall__Call_Id__c = '1111111111';
        TestingUtility.insertWithAssert(task1);
        
        Test.startTest();
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();  
        req.requestBody = Blob.valueOf('{"AgentPhoneNumber":"09282339141 -> 09282333","Disposition":"","Skill":"Elidi","TimeToAnswer":"","AgentID":"libin -> sadhasivam","EndTime":"2015-04-06 15:16:54","DialedNumber":"libin -> sadhasivam","AgentStatus":"","DialStatus":"Not Answered","Status":"Answered","AgentName":"libin -> Sadhasivam","CallerID":"99404495","AudioFile":"https://test.audio.mp3","FallBackRule":"AgentDial -> AgentDial","Apikey":"KK1fa49366ed32f8724adad01c82fa3d74","PhoneName":"libin -> sadhasivam","Did":"914466949426","HangupBy":"UserHangup","StartTime":"2015-04-06 15:16:22","Type":"inboun","TransferredTo":"","TransferType":"No Transfers","Comments":"","UUI":"UUI","CustomerStatus":"","AgentUniqueID":"19434 -> 19543","Location":"CHN","Duration":"None","monitorUCID":"12345","CallDuration":"00:11:21"}');
        req.requestURI = '/services/apexrest/Ozonetel';  
        req.httpMethod = 'POST';
        //assign rest context
        RestContext.request     = req;
        RestContext.response    = res;
        RESTOzonetel.Response response = RESTOzonetel.doPost();
        Debug.log('Response From REST API :::'+response);
        Test.stopTest();
    }
}