/************************************************************************************************************************************
    Author      :   Chandra Teja    
    Description :   This class contain test method related to ValidateClientSolutionsCaseController.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           6 December 2018     Chandra Teja            Initial Developement
**************************************************************************************************************************************/

@isTest
public class ClientSolutionsCaseControllerTest {
    @TestSetup
    static void setupTestData(){
        SalesConsoleSettings.createSettings();
            Map<String, List<Object>> mapFieldForOpportunity = new Map<String, List<Object>>();
            mapFieldForOpportunity.put('CurrencyIsoCode', new List<Object>{'INR','USD','AUD'});
            mapFieldForOpportunity.put('Name', new List<Object>{'testOpp1','testOpp2','testOpp3'});
            mapFieldForOpportunity.put('StageName', new List<Object>{'Qualifying','Selling','Negotiating'});
            mapFieldForOpportunity.put('Type__c', new List<Object>{'Global Access','PxWe','WeWork'});
            Map<String, Object> mapData = new Map<String, Object>();
            mapData.put('objName', 'opportunity');
            mapData.put('numberOfRecords', 3);
            mapData.put('mapFieldValues', mapFieldForOpportunity);
            mapData.put('doInsert', true);
        TestingUtility.getRecords(mapData);
    }
    /************************************************************************************************************************************
        Author         : Chandra Teja
        Description    : This method tests client solution button outputs based opportunity product type and stage name
        Created Date   : 06 December 2018  
        Issue No       : ST-3208
    **************************************************************************************************************************************/
    @isTest
    public static void getOpportunityDataTest(){
        List<Opportunity> lstOpportunities = [SELECT Id, Name, StageName, Type__c FROM Opportunity];
        DatabaseResult resultForQualifyingstage = (DatabaseResult)JSON.deserializeStrict((String)ValidateClientSolutionsCaseController.getOpportunityData(lstOpportunities[0].Id).data, DatabaseResult.class);
        DatabaseResult resultForPxweProductType = (DatabaseResult)JSON.deserializeStrict((String)ValidateClientSolutionsCaseController.getOpportunityData(lstOpportunities[1].Id).data, DatabaseResult.class);
        DatabaseResult resultforWeWorkProductType = (DatabaseResult)JSON.deserializeStrict((String)ValidateClientSolutionsCaseController.getOpportunityData(lstOpportunities[2].Id).data, DatabaseResult.class);
        system.assertEquals(false, resultForQualifyingstage.success);
        system.assertEquals(true, resultForPxweProductType.success);
        system.assertEquals(true, resultforWeWorkProductType.success);
    }
}