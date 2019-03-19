/************************************************************************************************************************************
    Author      :   Dipak Pawar
    Description :   

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1         16 Nov 2018    		Dipak Pawar            Initial Developement
**************************************************************************************************************************************/
@isTest
public class TrJourneyChangeRelatedLeadStatusTest {
    @testSetup
    Static void initData() {
        SalesConsoleSettings.createSettings();
        Map<String, Object> mapData = new Map<String, Object>();        
        mapData.put('objName', 'Lead');        
        mapData.put('Generate_Journey__c', true);
        mapData.put('numberOfRecords', 9);
        
        List<Lead> lstLeads = new List<Lead>();
        Test.startTest();
        lstLeads = (List<Lead>)TestingUtility.getRecords(mapData);
        Test.stopTest();
        debug.log('lstLeads: '+lstLeads);
        System.assertEquals(9, lstLeads.size());
        
        List<Journey__c> lstJourneys = new List<Journey__c>([SELECT Id, Status__c FROM Journey__c WHERE Primary_Lead__c IN : lstLeads]);
        System.assertEquals(9, lstJourneys.size());
        for(Journey__c objJourney : lstJourneys){
            System.assertEquals('Accepted', objJourney.Status__c);
        }
    }
    
    private static testMethod void verifyChangeJourneyRelatedLeadStatus(){
        List<Journey__c> lstJourneys = new List<Journey__c>([SELECT Id, Status__c FROM Journey__c]);
        System.assertEquals(9, lstJourneys.size());
        
        List<String> lstJourneyStatus = new List<String>{'Accepted','Auto-Complete/Expiration','Completed','In Contact','Nurture','Nurture','Trying to Reach','Unqualified','Unresponsive'};
            for(Integer iIndex = 0; iIndex < lstJourneyStatus.size(); iIndex++){
                lstJourneys[iIndex].Status__c = lstJourneyStatus[iIndex];
                switch on lstJourneyStatus[iIndex] {
                    when 'Nurture' {
                        lstJourneys[iIndex].Nurture_Reason__c = 'Test Reason';
                    }
                    when 'Unqualified' {
                        lstJourneys[iIndex].Lost_Reason__c = 'Test Reason';
                    }
                }                
            }
        update lstJourneys;
        lstJourneys[4].Status__c = 'Started';
        update lstJourneys;
        
        for(Journey__c objJourney : [SELECT Id, Status__c, Lost_Reason__c, Nurture_Reason__c, Primary_Lead__r.Status, Primary_Lead__r.Unqualified_Reason__c, Primary_Lead__r.Nurture_Reason__c FROM Journey__c]){
            switch on objJourney.Status__c {
                when 'Started' {
                    System.assertEquals('Re-engaged', objJourney.Primary_Lead__r.Status);
                }
                when 'Accepted' {
                    System.assertEquals('In Process', objJourney.Primary_Lead__r.Status);
                }
                when 'Auto-Complete/Expiration' {                    
                    System.assertEquals('Nurture', objJourney.Primary_Lead__r.Status);
                }
                when 'Completed' {                    
                    System.assertEquals('Qualified', objJourney.Primary_Lead__r.Status);
                }
                when 'In Contact' {                    
                    System.assertEquals('In Process', objJourney.Primary_Lead__r.Status);
                }
                when 'Nurture' {                    
                    System.assertEquals('Nurture', objJourney.Primary_Lead__r.Status);
                    System.assertEquals(objJourney.Nurture_Reason__c, objJourney.Primary_Lead__r.Nurture_Reason__c);
                }
                when 'Trying to Reach' {                    
                    System.assertEquals('In Process', objJourney.Primary_Lead__r.Status);
                }
                when 'Unqualified' {  
                    System.assertEquals(objJourney.Lost_Reason__c, objJourney.Primary_Lead__r.Unqualified_Reason__c);
                    System.assertEquals('Unqualified', objJourney.Primary_Lead__r.Status);
                }
                when 'Unresponsive' {                    
                    System.assertEquals('Nurture', objJourney.Primary_Lead__r.Status);
                }
            }
        }
    }
}