/************************************************************************************************************************************
    Author      :   Jitesh Adwani   
    Description :   This class will contain all the test method of TrOpportunityEmailAlertForBrokerInvolved.
    Issue No    :   ST-3276
    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1          2 Jan 2019           Jitesh             Initial Developement
**************************************************************************************************************************************/
@isTest
public class TrOpportunityEmailAlertForBrokerInTest {   
    static Boolean isTriggerActive = false;
    
    @testSetup
    Static void initData() {
        Integer count = 0;
        Set<String> setTriggerConfig = new Set<String>{'OpportunityEmailAlertForBrokerOnInsert', 'OpportunityEmailAlertForBrokerOnUpdate'};
        List<Trigger_Configuration__mdt> config = [SELECT Active__c, Record_Types_API_Names__c FROM Trigger_Configuration__mdt WHERE Active__c = true AND DeveloperName IN :setTriggerConfig];
        if(config.size() > 0){
            isTriggerActive = true;
        }
        SalesConsoleSettings.createSettings();
        List<Region__c> lstRegion = new List<Region__c>();
        lstRegion.add(new Region__c(Name = 'India', Region__c = 'India'));
        lstRegion.add(new Region__c(Name = 'China', Region__c = 'China'));
        TestingUtility.insertListWithAssert(lstRegion);
        Territory__c objTerritory = new Territory__c(Name = 'Test Territory 1', Territory__c = 'Test Terriotory 1', RegionID__c = lstRegion[0].Id);
        TestingUtility.insertWithAssert(objTerritory, 'Territory inserted');
        Market__c objMarket = new Market__c(Name = 'Test Portfolio', Portfolio__c = 'Test Portfolio', TerritoryId__c = objTerritory.Id);
        TestingUtility.insertWithAssert(objMarket, 'Portfolio inserted');
        Building__c objBuilding = new Building__c(Name = 'Test1', UUID__c = '12544114441111', Market__c = objMarket.Id);
        TestingUtility.insertWithAssert(objBuilding);
        
        TestingUtility.getRecords(new Map<String, Object>{'objName'=>'contact','numberOfRecords'=>3});
        List<Contact> lstContacts = new List<Contact>([SELECT Id, LastName FROM Contact]);
        System.assertEquals(lstContacts.size(), 3);
        
        Map<String, Object> mapData = new Map<String, Object>();
        Map<String, List<Object>> mapFieldForOpportunity = new Map<String, List<Object>>();
        mapFieldForOpportunity.put('Primary_Member__c', new List<Object>{lstContacts[0].Id, lstContacts[1].Id, lstContacts[2].Id});
        mapFieldForOpportunity.put('LeadSource', new List<Object>{'Event', 'Event', 'Event'});
        mapFieldForOpportunity.put('Referrer__c', new List<Object>{lstContacts[0].Id, lstContacts[0].Id, lstContacts[0].Id});
        mapFieldForOpportunity.put('Building__c', new List<Object>{objBuilding.Id, objBuilding.Id, objBuilding.Id});
        mapFieldForOpportunity.put('Broker_Involvement_Indicated__c', new List<Object>{'Yes', 'No', 'Yes'});
        mapData.put('objName', 'Opportunity');
        mapData.put('numberOfRecords', 3);
        mapData.put('doInsert', true);
        mapData.put('mapFieldValues', mapFieldForOpportunity);
        List<Opportunity> lstOpportunities = TestingUtility.getRecords(mapData);
        System.assertEquals(lstOpportunities.size(), 3);
    }
    
    /************************************************************************************************************************************
        Author         : Jitesh Adwani
        Description    : This method is used check email is sent or not.
        Created Date   : 03 Jan 2019 
        Issue No       : ST-3276
    **************************************************************************************************************************************/
    public static testMethod void verifyEmailAlertForBrokerInvolved(){
        if(!isTriggerActive){
            return;
        }
        //Insert        
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(1, invocations, 'An Email has not been sent');
        //Update
        List<Territory__c> lstUpdateTerritory = new List<Territory__c>();
        List<Region__c> lstRegions = new List<Region__c>([SELECT Id, Name FROM Region__c]);
        List<Territory__c> lstTerritory = new List<Territory__c>([SELECT Id FROM Territory__c]);
        for(Territory__c objTerritory : lstTerritory){
            objTerritory.RegionID__c = lstRegions[1].Id;
            lstUpdateTerritory.add(objTerritory);
        }
        TestingUtility.updateListWithAssert(lstUpdateTerritory);
        List<Building__c> lstBuilding = new List<Building__c>([SELECT Id, Name, Region_Name__c FROM Building__c]);
        System.assertEquals(lstBuilding[0].Region_Name__c, lstRegions[1].Name, 'Region didn\'t Updated');
        List<Opportunity> lstOpportunity = new List<Opportunity>([SELECT Id, Name, Broker_Involvement_Indicated__c FROM Opportunity]); 
        lstOpportunity[1].Broker_Involvement_Indicated__c = 'Yes';
        TestingUtility.updateListWithAssert(lstOpportunity);
        Integer invocations1 = Limits.getEmailInvocations();
        System.assertEquals(2, invocations1, 'An Email has not been sent');
        
        //Negative scenario mail didn't send.
        List<Opportunity> lstOpportunities = new List<Opportunity>([SELECT Id, Name, Broker_Involvement_Indicated__c FROM Opportunity]);
        lstOpportunities[1].LeadSource = 'Broker Referral';
        TestingUtility.updateListWithAssert(lstOpportunities);     
        Integer invocations2 = Limits.getEmailInvocations();
        System.assertEquals(2, invocations2, 'An Email has not been sent');
    }
}