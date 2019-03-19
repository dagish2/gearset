/************************************************************************************************************************************
    Author      :   Pragalbha Mahajan
    Description :   This class contains all test methods related to TrOpportunityCreateOppTeamMember class.
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           09 Jan 2019         Pragalbha Mahajan       Initial Development
************************************************************************************************************************************/
@isTest
public class TrOpportunityCreateOppTeamMemberTest {
    public static Boolean isTriggerActive = false;
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This static block is used to get wheather the trigger is active or not.
    Issue No.			:	ST-3293
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    static{
        if(!isTriggerActive){
            Set<String> setTriggerConfig = new Set<String>{'OpportunityCreateOppTeamMemberOnInsert', 'OpportunityCreateOppTeamMemberOnUpdate'};
                List<Trigger_Configuration__mdt> config = [SELECT Active__c, Record_Types_API_Names__c FROM Trigger_Configuration__mdt WHERE Active__c = true AND DeveloperName IN :setTriggerConfig];
            if(config.size() > 0){
                isTriggerActive = true;
            }  
        }
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to Verify Creation of Opportunity Team Member.
    Issue No.			:	ST-3293
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    @testSetup 
    public static void setup() {        
        SalesConsoleSettings.createSettings();
        List<User> lstUser = [SELECT Id, Name, ProfileId FROM User WHERE Profile.Name = 'WeWork NMD User - Outbound' OR Profile.Name = 'WeWork NMD User' LIMIT 2];
        String recTypeComsumerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
        String recTypeMidMarketId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mid_Market').getRecordTypeId();
        String recTypeEnterpriseId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise_Solutions').getRecordTypeId();
        
        List<Account> lstAccounts = new List<Account>();
        Map<String, Object> accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName1',
            'Account_Type__c' => 'Org',
            'RecordTypeId' => recTypeComsumerId,
            'Unomy_Location_Country__c' => 'Australia',
            'OwnerId' => lstUser[0].Id};
        lstAccounts.addAll(TestingUtility.getAccountsByType(accountValuesMap, 'Org', 1));
        
        accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName2',
            'Account_Type__c' => 'Org',
            'RecordTypeId' => recTypeMidMarketId};     
        lstAccounts.addAll(TestingUtility.getAccountsByType(accountValuesMap, 'Org', 1));
        
        accountValuesMap = new Map<String, Object>{'Name' => 'strAccountName3',
            'Account_Type__c' => 'Org',
            'RecordTypeId' => recTypeEnterpriseId};     
        lstAccounts.addAll(TestingUtility.getAccountsByType(accountValuesMap, 'Org', 1));
        TestingUtility.insertListWithAssert(lstAccounts);
        
        List<Contact> lstContacts = new List<Contact>();
        Map<String, Object> contactValuesMap = new Map<String, Object>{'FirstName' => 'John',
                'LastName' => 'Smith1',
                'Email' => 'john.smith1@example.com',
                'AccountId' => lstAccounts[0].Id };
        lstContacts.add((Contact)TestingUtility.createTestRecords(Contact.sObjectType, contactValuesMap, false));
        TestingUtility.insertListWithAssert(lstContacts);
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to Verify Creation of Opportunity Team Member.
    Issue No.			:	ST-3293
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    public static testMethod void testCreateOpportunityTeamMember(){
        if(!isTriggerActive){
            return;
        }
        List<OpportunityTeamMember> lstOpportunityTeamMember = [SELECT Id, UserId, TeamMemberRole, OpportunityId FROM OpportunityTeamMember];
        System.assert(lstOpportunityTeamMember.size() == 0);
        List<Account> lstAccount = [SELECT Id, Name, RecordTypeId, Unomy_Location_Country__c, OwnerId FROM Account];
        List<User> lstUser = [SELECT Id, Name, ProfileId, isActive FROM User WHERE (IsActive = True AND Profile.Name = 'WeWork NMD User - Outbound') LIMIT 1];
        List<Contact> lstContacts = new List<Contact>();
        Map<String,Object> mapContactFieldValues = new Map<String,Object>();
        System.runas(lstUser[0]){
            mapContactFieldValues = new Map<String, Object>{'FirstName' => 'John',
                'LastName' => 'Rambo',
                'Email' => 'test@example.com',
                'AccountId' => lstAccount[0].Id,
                'Status__c' => 'active',
                'OwnerId' => lstUser[0].Id};
            
            Contact conRec = TestingUtility.createContact(mapContactFieldValues,true);
            Map<String, Object> mapData = new Map<String, Object>();
            Map<String, List<Object>> mapFieldForOpportunity = new Map<String, List<Object>>();
            
            mapFieldForOpportunity.put('Name', New List<Object>{'test oppty1', 'test oppty2', 'test oppty3'});
            mapFieldForOpportunity.put('StageName', New List<Object>{'Qualifying', 'Selling', 'Qualifying'});
            mapFieldForOpportunity.put('AccountId', new List<Object>{lstAccount[0].Id, lstAccount[1].Id, lstAccount[2].Id});
            mapFieldForOpportunity.put('Referrer__c', new List<Object>{conRec.Id, conRec.Id, conRec.Id});
            mapData.put('objName', 'Opportunity');
            mapData.put('numberOfRecords', 3);
            mapData.put('doInsert', true);
            mapData.put('mapFieldValues', mapFieldForOpportunity);
            List<Opportunity> lstOpportunities = TestingUtility.getRecords(mapData);
            List<OpportunityTeamMember> lstOppTeamMember = [SELECT ID, Name, OpportunityId, TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId IN: lstOpportunities];
            system.assertEquals(3, lstOppTeamMember.Size());
            for(integer i=0; i<lstOppTeamMember.size(); i++){
                for(integer j = 0; j < lstOpportunities.size() ; j++){                    
                    if(lstOppTeamMember[i].OpportunityId == lstOpportunities[j].id){                        
                        System.assert(lstOppTeamMember[i].TeamMemberRole == 'BDM');
                    }
                }
            }
        }
    }
    
    /************************************************************************************************************************************
    Author 				: 	Pragalbha Mahajan
    Description 		: 	This method is used to Verify Creation of Opportunity Team Member for Positive scenario.
    Issue No.			:	ST-3293
	Created Date		:	09 Jan 2019
    **************************************************************************************************************************************/ 
    public static testMethod void testCreateOpportunityTeamMember2(){
        if(!isTriggerActive){
            return;
        }
        List<Account> lstAccount = [SELECT Id, Name, RecordTypeId, Unomy_Location_Country__c, OwnerId FROM Account];
        List<Contact> lstContact = [Select Id, Name, Interested_in_Number_of_Desks__c from Contact];
        List<User> lstUser = [SELECT Id, Name, ProfileId, isActive FROM User WHERE (IsActive = True AND Profile.Name = 'WeWork NMD User - Outbound') LIMIT 1];
		System.runAs(lstUser[0]) {
            Map<String, Object> mapData = new Map<String, Object>();
            Map<String, List<Object>> mapFieldForOpportunity = new Map<String, List<Object>>();
            
            mapFieldForOpportunity.put('Name', New List<Object>{'test oppty1', 'test oppty2', 'test oppty3'});
            mapFieldForOpportunity.put('StageName', New List<Object>{'Qualifying', 'Selling', 'Qualifying'});
            mapFieldForOpportunity.put('Primary_Member__c', new List<Object>{lstContact[0].Id, lstContact[0].Id, lstContact[0].Id});
            mapFieldForOpportunity.put('AccountId', new List<Object>{lstAccount[0].Id, lstAccount[1].Id, lstAccount[2].Id});
            mapData.put('objName', 'Opportunity');
            mapData.put('numberOfRecords', 3);
            mapData.put('doInsert', true);
            mapData.put('mapFieldValues', mapFieldForOpportunity);
            List<Opportunity> lstOpportunities = TestingUtility.getRecords(mapData);
            List<OpportunityTeamMember> lstOpportunityTeamMember = [SELECT id, UserId, TeamMemberRole, OpportunityId FROM OpportunityTeamMember WHERE OpportunityId IN: lstOpportunities];
            System.assert(lstOpportunityTeamMember.size() == 3);
            for(integer i=0; i<lstOpportunityTeamMember.size(); i++){
                for(integer j = 0; j < lstOpportunities.size() ; j++){                    
                    if(lstOpportunityTeamMember[i].OpportunityId == lstOpportunities[j].id){                        
                        System.assert(lstOpportunityTeamMember[i].OpportunityId == lstOpportunities[j].id);
                    }
                }
            }
        }
    }
}