/************************************************************************************************************************************
    Author      :   Jitesh Adwani	
    Description :   This class will contain Logic of TestMethod.
	Issue No    : 	ST-3114
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1          28 November 2018     Jitesh             Initial Developement
**************************************************************************************************************************************/
@isTest
public class TrCampaignNamingConventionTest {

	@testSetup
    static void testData(){
        SalesConsoleSettings.createSettings();
        List<campaign> lstCampaigns = TestingUtility.getRecords(new Map<String, Object>{'objName'=>'Campaign','numberOfRecords'=>4});
        System.assertEquals(3, lstCampaigns.size());
    }
    
/************************************************************************************************************************************
    Author         : Jitesh Adwani
    Description    : This method is used verifyInsertUpdateCampaignNamingConvention().
    Created Date   : 28 Nov 2018 
    Issue No       : ST-3114
**************************************************************************************************************************************/
    public static testMethod void verifyInsertUpdateCampaignNamingConvention(){
        List <Trigger_Configuration__mdt> TriggerConfiguration = [Select ID
                                                                  From Trigger_Configuration__mdt
                                                                  Where Implementing_Class__c = 'TrCampaignNamingConvention'
                                                                  AND Active__c = true];
        Debug.log('Before TriggerConfiguration==>'+TriggerConfiguration);
        if(TriggerConfiguration.size() == 0){
            Debug.log('TriggerConfiguration stopped==>'+TriggerConfiguration);
            return; 
        }
        Debug.log('After TriggerConfiguration==>'+TriggerConfiguration);
        List<Campaign> lstUpdateCampaign = new List<Campaign>();
        List<Campaign> lstCampaigns = [SELECT Id, Name, Name__c, CreatedDate FROM Campaign WHERE ParentId != ''];
        System.assertEquals(lstCampaigns.size(), 3);
        
        Set<Id> setCampaignIds = new Set<Id>();
        Test.setCreatedDate(lstCampaigns[0].Id, Date.newInstance(2018, 11, 8));
        lstUpdateCampaign.add(lstCampaigns[0]);
        setCampaignIds.add(lstCampaigns[0].Id);
        
        Test.setCreatedDate(lstCampaigns[1].Id, Date.newInstance(2018, 11, 8));
        lstUpdateCampaign.add(lstCampaigns[1]);
        setCampaignIds.add(lstCampaigns[1].Id);
        TestingUtility.updateListWithAssert(lstUpdateCampaign);
        
        for(Campaign objCampaign : [SELECT Id, Name, ParentId, Program__c, Region__c, Type, Name__c, CreatedDate FROM Campaign]){
            if(setCampaignIds.contains(objCampaign.Id)){
                System.assertEquals(objCampaign.Name__c, objCampaign.Name);
            } else {
                String campaignName = TrCampaignNamingConvention.getCampaignName(objCampaign, String.isNotBlank(objCampaign.Program__c), false);
                System.assertEquals(objCampaign.Name, campaignName);   
            }
        }
    }
}