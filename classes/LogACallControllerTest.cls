/************************************************************************************************************************************
    Author      :   Dipak Pawar    
    Description :   This class contain methods that are used in LogACallController
    
    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1          31-10-2018           Dipak Pawar             Initial Developement
**************************************************************************************************************************************/
@isTest
public class LogACallControllerTest {
    @testSetup 
    static void setup(){
        SalesConsoleSettings.createSettings();
        List<Lead> lstLeadsToInsert = new List<Lead>();
        List<Journey__C> lstJourneys = new List<Journey__C>();
        
        lstLeadsToInsert.addAll(getLeads('john_smith', 5));
        TestingUtility.insertListWithAssert(lstLeadsToInsert);
        
        for(Lead lead : lstLeadsToInsert){
            Journey__c journey = new Journey__c();
            journey.Name = lead.LastName;
            journey.Primary_Lead__c = lead.Id;
            journey.Status__c = 'Started';
            journey.Primary_Email__c = lead.Email;
            journey.NMD_Next_Contact_Date__c = Date.today();
            lstJourneys.add(journey);
        } 
        TestingUtility.insertListWithAssert(lstJourneys);
    }
    
    public static List<Lead> getLeads(string nameDifferentiator, Integer count){
        List<Lead> lstLeads = new List<Lead>();
        for(Integer index = 1; index <= count; index++){
            lstLeads.add(new Lead(LastName = nameDifferentiator, Email = nameDifferentiator + index + '@example.com', Office_Type__c = 'Daily Desk', Status = 'Open', Company = nameDifferentiator, Locations_Interested__c = 'Test Building Tour'));
        }
        return lstLeads;
    }
    
    /****************************************************************************************************************************
        Author              : Dipak Pawar
        Description         : This method Covers the getJourneydata
        Created Date        : 31-10-2018
        Issue               : ST-2868
    *****************************************************************************************************************************/
    static testMethod void getJourneydataTest(){
        List<Lead> lstLeads = new List<Lead>([SELECT Id, Name FROM Lead]);
        System.assertEquals(lstLeads.size(), 5);
        List<Journey__c> lstJourneys = new List<Journey__c>([SELECT Id, Name FROM Journey__c]);
        System.assertEquals(lstJourneys.size(), 10);
        
        DatabaseResult result = LogACallController.getJourneyData(lstJourneys[0].Id, 'getJourneyData');
        System.assertNotEquals(null, result);
        Map<String, Object> objDatabaseResult = (Map<String, Object>)result.data;
        Journey__c journeyRecord = (Journey__c)objDatabaseResult.get('journeyRecord');
        System.assertNotEquals(null, journeyRecord);
        System.assertEquals(lstJourneys[0].Id, journeyRecord.Id);
        
        result = LogACallController.saveCallLogs(journeyRecord, true, 'test call comments');
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.data);
       
        result = LogACallController.getJourneyData(null, null);
        System.assertEquals(true, result.success);
        
        result = LogACallController.saveCallLogs(null, true, null);
        System.assertEquals(false, result.success);
    }
}