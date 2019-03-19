/************************************************************************************************************************************
    Author      :   Jitesh Adwani	
    Description :   This class will contain all the test method of TrRelateCampaignToOpportunity.
	Issue No    : 	ST-3136
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1          26 November 2018     Jitesh             Initial Developement
**************************************************************************************************************************************/
@isTest
public class TrRelateCampaignOnOpportunityTest {
	@testSetup
    Static void initData() {
        SalesConsoleSettings.createSettings();
        
        TestingUtility.getRecords(new Map<String, Object>{'objName'=>'campaignmember','numberOfRecords'=>3});
        List<Contact> lstContacts = new List<Contact>([SELECT Id, LastName FROM Contact]);
        List<Campaign> lstCampaigns = new List<Campaign>([SELECT Id FROM Campaign]);
        System.assertEquals(lstCampaigns.size(), 3);
        
        Map<String, Object> mapData = new Map<String, Object>();
        Map<String, List<Object>> mapFieldForOpportunity = new Map<String, List<Object>>();
        mapFieldForOpportunity.put('Primary_Member__c', new List<Object>{lstContacts[0].Id, lstContacts[1].Id, lstContacts[2].Id});
        mapData.put('objName', 'Opportunity');
        mapData.put('numberOfRecords', 3);
        mapData.put('doInsert', true);
        mapData.put('mapFieldValues', mapFieldForOpportunity);
        List<Opportunity> lstOpportunities = TestingUtility.getRecords(mapData);
        System.assertEquals(lstOpportunities.size(), 3);
    }
    
/************************************************************************************************************************************
    Author         : Jitesh Adwani
    Description    : This method is used to cover insertCampaignOnOpportunity.
    Created Date   : 26 Nov 2018 
    Issue No       : ST-3136
**************************************************************************************************************************************/
    public static testMethod void verifyInsertCampaignOnOpportunity(){
        Integer count = 0;
        CampaignMember objCampaignMember;
        List<Opportunity> lstOpportunities = new List<Opportunity>([SELECT Id, CampaignId, Primary_Member__c FROM Opportunity]);
        System.assertEquals(lstOpportunities.size(), 3);
        for(Contact objContact : [SELECT Id, (SELECT Id, Name, CampaignId FROM CampaignMembers ORDER BY LastModifiedDate DESC) FROM Contact]){
            objCampaignMember = objContact.CampaignMembers[0];
        	System.assertEquals(objContact.Id, lstOpportunities[count].Primary_Member__c);
            System.assertEquals(objCampaignMember.CampaignId, lstOpportunities[count].CampaignId);
            count++;
        }
    }
}