/************************************************************************************************************************************
    Author      :   Jitesh Adwani	
    Description :   This class will contain all the test method of TrJourneyOutreachStageStatus.
	Issue No    : 	ST-3039
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1          12 November 2018     Jitesh             Initial Developement
**************************************************************************************************************************************/
@isTest
public class TrJourneyOutreachStageStatusTest {
	
    @testSetup
    static void initData(){
        SalesConsoleSettings.createSettings();
        TestingUtility.getRecords(new Map<String, Object>{'objName'=>'lead', 'numberOfRecords'=>3});
    }
    
/************************************************************************************************************************************
    Author         : Jitesh Adwani
    Description    : This method is used in TrJourneyStageStatus.
    Created Date   : 15 Nov 2018 
    Issue No       : ST-3039
**************************************************************************************************************************************/
    public static testMethod void verifyUpdateJourneyStatusOnOutreachStage() {
        List<Journey__c> lstJourneys = [SELECT Id, Name, Outreach_Stage__c FROM Journey__c];
        List<Journey__c> lstUpdateJourney = new List<Journey__c>();
        for(Journey__c objJourney : lstJourneys){
            objJourney.Outreach_Stage__c = 'Call 1';
            lstUpdateJourney.add(objJourney);
        }
        TestingUtility.updateListWithAssert(lstUpdateJourney);
        List<Journey__c> lstUpdatedJourneys = [SELECT Id, Name, Outreach_Stage__c, Status__c FROM Journey__c];
        for(Journey__c objJourney : lstUpdatedJourneys){
            System.assertEquals(objJourney.Status__c.toLowerCase(), 'trying to reach', 'Status didn\'t update');
        }
    }
}