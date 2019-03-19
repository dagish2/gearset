/************************************************************************************************************************************
    Author      :   Dipak Pawar
    Description :   

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1         16 Nov 2018    		Dipak Pawar            Initial Developement
**************************************************************************************************************************************/
@isTest
public class TrLeadChangeRelatedJourneyStatusTest {
	@testSetup
    Static void initData() {
        SalesConsoleSettings.createSettings();
        Map<String, Object> mapData = new Map<String, Object>();        
        mapData.put('objName', 'Lead');        
        mapData.put('Generate_Journey__c', true);
        mapData.put('numberOfRecords', 3);
        
        List<Lead> lstLeads = new List<Lead>();
        lstLeads = (List<Lead>)TestingUtility.getRecords(mapData);
        System.assertEquals(3, lstLeads.size());
        
        List<Journey__c> lstJourneys = new List<Journey__c>([SELECT Id, Status__c FROM Journey__c]);
        System.assertEquals(3, lstJourneys.size());
        for(Journey__c objJourney : lstJourneys){
            System.assertEquals('Started', objJourney.Status__c);
        }
    }
    
    private static testMethod void verifyChangeLeadRelatedJourneyStatus() {        
        List<Lead> lstLeads = new List<Lead>([SELECT Id, Email, Status, (SELECT Id, Status__c FROM Journeys__r) FROM Lead]);
        System.assertEquals(3, lstLeads.size());
        lstLeads[0].Status = 'In Process';
        lstLeads[1].Status = 'Qualified';
        lstLeads[2].Status = 'Unqualified';
        lstLeads[2].Unqualified_Reason__c = 'Test Reason';
        update lstLeads;
        
        for(Lead objLead : [SELECT Id, Status, (SELECT Id, Status__c FROM Journeys__r ORDER BY LastModifiedDate DESC) FROM Lead]){
            switch on objLead.Status {
                when 'In Process' {
                    System.assertEquals('Accepted', objLead.Journeys__r[0].Status__c);
                }
                when 'Qualified' {                    
                    System.assertEquals('Accepted', objLead.Journeys__r[0].Status__c);
                }
                when 'Unqualified' {                    
                    System.assertEquals('Unqualified', objLead.Journeys__r[0].Status__c);
                }
            }
        }
    }
}