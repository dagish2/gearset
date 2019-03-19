/*****************************************************************************************************************************
  Yet to do
  1. Modularize the code into multiple method calls.
  2. Put comments for each method call to establish references.
  3. Get it reviewed from the peer team.
******************************************************************************************************************************
    Author      :  Krishana Tupe  
    Description :  This class contains the business logic related to Lead Routing and Conversion
    History     :  --
    
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION                 DATE            ISSUE       AUTHOR                          DETAIL
    1                       29 Nov 2018      -     		Krishana Tupe                   Initial Developement    
******************************************************************************************************************************/
@isTest
public class LeadProcessingTest {
    public static string strHoldBackQueueId;
    static {
        if(String.isBlank(strHoldBackQueueId)){
            MetadataSetting__mdt objJourneyCreationMDT = Settings.getMetadataSettingByDevName('Hold_Back_Queue');  
            strHoldBackQueueId = String.isNotBlank(objJourneyCreationMDT.Data__c) ? objJourneyCreationMDT.Data__c : null;      
        }        
    }
   
  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This setup method is used to create a test data for LeadProcessingTest
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    @TestSetup
    public static void testSetup(){
        SalesConsoleSettings.createSettings(); 
    }
    
    
/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to verify the Lead/Journey Hold Back Flow from Process Builder 
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    @isTest
    public static void verifyLeadInsertionHoldBack(){
        List<Lead> lstLeads = new List<Lead>(); 
        LeadRoutingHelperTest.getLeadRecords(lstLeads, 1, 6, null, null);
        RESTInboundLeadAPIHelper.isLeadFromWeb = true;       
        TestingUtility.insertListWithAssert(lstLeads);        
        List<Lead> lstLeadsInserted = [SELECT Id, Name, Email, Campaign_Id__c, OwnerId, Lead_Assignment_Stage__c, (SELECT Id, OwnerId FROM Journeys__r) FROM Lead WHERE Id IN : lstLeads AND IsConverted = false];
        System.assertEquals(6, lstLeadsInserted.size()); 
        LeadRoutingHelperTest.verifyAssertions(lstLeadsInserted, 1, Id.valueOf(strHoldBackQueueId), '6');
        for(lead objLead : lstLeadsInserted){
            objLead.Unomy_Updated_DateTime__c = System.now(); 
        }
        RESTInboundLeadAPIHelper.isLeadFromWeb = false; 
        Test.startTest();
        LeadProcessing.routeLeadsToHoldBack(lstLeadsInserted);
        Test.stopTest();
        
        lstLeadsInserted = [SELECT Id, Name, OwnerId, Lead_Assignment_Stage__c, (SELECT Id, OwnerId FROM Journeys__r) FROM Lead WHERE Id IN : lstLeads AND IsConverted = false];
        System.assertEquals(6, lstLeadsInserted.size()); 
        for(Lead objLead : lstLeadsInserted){
            System.assertEquals('11',objLead.Lead_Assignment_Stage__c); 
            System.assertNotEquals(Id.valueOf(strHoldBackQueueId), objLead.OwnerId); 
            System.assert(objLead.Journeys__r.size() == 1);
            System.assertEquals(objLead.OwnerId, objLead.Journeys__r[0].OwnerId);
        }
    }
    
}