@isTest
public class TrAccountByPassChildUpdateTest {

    @testSetup
    static void testSetup(){
        SalesConsoleSettings.createSettings();
        createBulkDataForTest();
    }
    
    public static void createBulkDataForTest(){
        Map<String, Integer> mapBatchMDTSetting = TrAccountByPassChildUpdate.getUpdateChildRecordsBatchMDTSetting();
        List<Account> lstAccounts = UtilAccount.GetNewAccounts(7, true);
        List<Contact> lstContacts = new List<Contact>();
        List<sObject> lstSObjects = new List<sObject>();
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        List<Account> lstAccountsToupdate = new List<Account>();
        List<Contact> lstContactsforMap = new List<Contact>();
        List<Opportunity> lstOpportunitiesforMap = new List<Opportunity>();
        Map<Id, Map<String, List<sObject>>> mapAccountWithChilds = new Map<Id, Map<String, List<Sobject>>>();
        
        for(Integer index = 0; index < 5; index++){
            switch on index {
                when 0 {
                    lstContactsforMap = UtilContact.GetNewContacts(2, lstAccounts[index], false);
                    lstOpportunitiesforMap = UtilOpportunity.GetNewOpportunity(2, lstAccounts[index], false);
                }
                when 1, 2 {
                    lstContactsforMap = UtilContact.GetNewContacts(10, lstAccounts[index], false);  
                    lstOpportunitiesforMap = UtilOpportunity.GetNewOpportunity(10, lstAccounts[index], false);
                }
                when 3 {
                    lstContactsforMap = UtilContact.GetNewContacts(5, lstAccounts[index], false);  
                    lstOpportunitiesforMap = UtilOpportunity.GetNewOpportunity(5, lstAccounts[index], false);
                }
                when 4 {
                    lstContactsforMap = UtilContact.GetNewContacts(20, lstAccounts[index], false);  
                    lstOpportunitiesforMap = UtilOpportunity.GetNewOpportunity(5, lstAccounts[index], false);
                }
            }
            lstContactsforMap = lstContactsforMap != NULL ? lstContactsforMap : new List<Contact>();
            lstOpportunitiesforMap = lstOpportunitiesforMap != NULL ? lstOpportunitiesforMap : new List<Opportunity>();
            lstContacts.addall(lstContactsforMap);
            lstOpportunities.addall(lstOpportunitiesforMap);
            mapAccountWithChilds.put(lstAccounts[index].Id, new Map<String, List<sObject>>{'Contacts'=>lstContactsforMap, 'Opportunities'=>lstOpportunitiesforMap});
        	lstContactsforMap = null;
            lstOpportunitiesforMap = null;
        }
        
        Integer count = 5;
        for(Integer index = 0; index < 2; index++){
            lstAccounts[index].ParentId = lstAccounts[count+index].Id;
            lstAccounts[index].Processing_Stage__c = 'On Hold';
            lstAccountsToupdate.add(lstAccounts[index]);
            lstContactsforMap = UtilContact.GetNewContacts(2, lstAccounts[count+index], false);
            lstOpportunitiesforMap = UtilOpportunity.GetNewOpportunity(2, lstAccounts[count+index], false);
            mapAccountWithChilds.put(lstAccounts[count+index].Id, new Map<String, List<sObject>>{'Contacts'=>lstContactsforMap, 'Opportunities'=>lstOpportunitiesforMap});
  			lstContacts.addall(lstContactsforMap);
            lstOpportunities.addall(lstOpportunitiesforMap);
            lstContactsforMap = null;
            lstOpportunitiesforMap = null;
        }
        
        for(Integer index = 0; index < lstAccounts.size(); index++){
            switch on index {
                when 0 {
                    addPrefixAndStages(mapAccountWithChilds.get(lstAccounts[index].Id), new Map<string, Map<String, Object>>{'Contacts'=> new Map<String, Object>{'Email'=>'byPassOnHold'}, 'Opportunities'=> new Map<String, Object>{'StageName'=>'Selling'}});
                }
                when 1, 2 {
                    addPrefixAndStages(mapAccountWithChilds.get(lstAccounts[index].Id), new Map<string, Map<String, Object>>{'Contacts'=> new Map<String, Object>{'Email'=>'byPassHighChildren'}, 'Opportunities'=> new Map<String, Object>{'StageName'=>'Selling'}});
                }
                when 3 {
                    addPrefixAndStages(mapAccountWithChilds.get(lstAccounts[index].Id), new Map<string, Map<String, Object>>{'Contacts'=> new Map<String, Object>{'Email'=>'syncUpdate'}, 'Opportunities'=> new Map<String, Object>{'StageName'=>'Selling'}});
                }
                when 4, 5, 6 {
                    addPrefixAndStages(mapAccountWithChilds.get(lstAccounts[index].Id), new Map<string, Map<String, Object>>{'Contacts'=> new Map<String, Object>{'Email'=>'byPassHighChildren'}, 'Opportunities'=> new Map<String, Object>{'StageName'=>'Selling'}});
                }
            }
           
        }
        lstSObjects.addAll(lstOpportunities);
        lstSObjects.addAll(lstContacts);
        insert lstOpportunities;
        insert lstContacts;
        update lstAccountsToupdate;
    }
    
    static void addPrefixAndStages(Map<String, List<sObject>> mapChildren, Map<String, Map<String, Object>> mapFieldsWithValuesOfSobject){
        for(String childName : mapChildren.keySet()){
            List<sobject> lstchildren = mapChildren.get(childName);
            if(lstchildren != null && lstchildren.size() > 0){
                Map<String, Object> mapFieldsWithValues = mapFieldsWithValuesOfSobject.get(childName);
                if(mapFieldsWithValues != null && childName == 'Contacts'){
                    for(sObject objSobject : lstchildren){
                        if(mapFieldsWithValues.get('Email') != null){
                            objSobject.put('Email', TestingUtility.createUserCommunityName()+String.ValueOf(mapFieldsWithValues.get('Email'))+objSobject.get('Email'));
                        }else{
                            string prefix =  String.ValueOf(mapFieldsWithValues.get('Email'));
                            mapFieldsWithValues.remove('Email');
                            addFieldsToSobject(objSobject, mapFieldsWithValues);
                            mapFieldsWithValues.put('Email', prefix);
                        }
                    }
                }else{
                    for(sObject objSobject : lstchildren){
                        addFieldsToSobject(objSobject, mapFieldsWithValues);
                    }
                }
            }
        }
    }
    
    static void addFieldsToSobject(sobject objSobject, Map<String, Object> mapFieldsWithValues){
        for(String fieldName : mapFieldsWithValues.keyset()){
            objSobject.put(fieldName, mapFieldsWithValues.get(fieldName));
        }
    }
    
    private static testMethod void verifyTrAccountByPassChildUpdateInBulk(){
        Map<Id, Account> mapAccountsByPassOnHold = new Map<Id, Account>();
        Map<Id, Account> mapAccountsByPassHighChildren = new Map<Id, Account>();
        Map<Id, Account> mapAccountsSyncUpdate = new Map<Id, Account>();
        List<Account> lstAccountsToupdate = new List<Account>();
        Id regionalBetaUserId = [SELECT Id FROM User WHERE Profile.Name = 'WeWork Regional Sales Lead - Beta' Limit 1].Id;
        Id recordTypeIdEnterprise =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        getTestRecords(mapAccountsByPassOnHold, mapAccountsByPassHighChildren, mapAccountsSyncUpdate, new Map<String, Object>{'recordTypeIdEnterprise'=>recordTypeIdEnterprise, 'regionalBetaUserId'=>regionalBetaUserId});
        Test.startTest();
            lstAccountsToupdate.addAll(mapAccountsByPassOnHold.values());
            lstAccountsToupdate.addAll(mapAccountsByPassHighChildren.values());
            lstAccountsToupdate.addAll(mapAccountsSyncUpdate.values());
            update lstAccountsToupdate;
        Test.stopTest();
        for(Account objAccount : [SELECT Id, Account_Owner_RecordType_For_Batch__c, Processing_Stage__c FROM Account WHERE Id In : mapAccountsByPassOnHold.keySet()]){
            system.assertEquals(objAccount.Processing_Stage__c, 'On Hold');
        }
        for(Account objAccount : [SELECT Id,(SELECT Id, RecordTypeId, OwnerId, Owner.Profile.Name, StageName FROM Opportunities),(SELECT Id, Name, RecordTypeId, OwnerId FROM childAccounts),(SELECT Id, Name, RecordTypeId, OwnerId FROM Contacts), Account_Owner_RecordType_For_Batch__c, Processing_Stage__c FROM Account WHERE Id In : lstAccountsToupdate]){
            system.assertNotEquals(objAccount.Account_Owner_RecordType_For_Batch__c, null);
            system.assert(objAccount.Account_Owner_RecordType_For_Batch__c.containsIgnoreCase(';'));
        }
    }
    
    private static testMethod void verifySyncChildUpdateWithBulk(){
        Map<Id, Account> mapAccountsByPassOnHold = new Map<Id, Account>();
        Map<Id, Account> mapAccountsByPassHighChildren = new Map<Id, Account>();
        Map<Id, Account> mapAccountsSyncUpdate = new Map<Id, Account>();
        List<Account> lstAccountsToupdate = new List<Account>();
        Id regionalBetaUserId = [SELECT Id FROM User WHERE Profile.Name = 'WeWork Regional Sales Lead - Beta' Limit 1].Id;
        Id recordTypeIdEnterprise =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        getTestRecords(mapAccountsByPassOnHold, mapAccountsByPassHighChildren, mapAccountsSyncUpdate, new Map<String, Object>{'recordTypeIdEnterprise'=>recordTypeIdEnterprise, 'regionalBetaUserId'=>regionalBetaUserId});
        Test.startTest();
            lstAccountsToupdate.addAll(mapAccountsByPassOnHold.values());
            lstAccountsToupdate.addAll(mapAccountsSyncUpdate.values());
            update lstAccountsToupdate;
        Test.stopTest();
        for(Account objAccount : [SELECT Id, Account_Owner_RecordType_For_Batch__c, Processing_Stage__c FROM Account WHERE Id In : mapAccountsByPassOnHold.keySet()]){
            system.assertEquals(objAccount.Processing_Stage__c, 'On Hold');
            system.assert(objAccount.Account_Owner_RecordType_For_Batch__c.containsIgnoreCase(';'));
        }
        for(Account objAccount : [SELECT Id, Account_Owner_RecordType_For_Batch__c, Processing_Stage__c FROM Account WHERE Id In : mapAccountsSyncUpdate.keySet()]){
            system.assertEquals(objAccount.Account_Owner_RecordType_For_Batch__c, null);
            system.assertEquals(objAccount.Processing_Stage__c, 'None');
        }
    }
	
    static void getTestRecords( Map<Id, Account> mapAccountsByPassOnHold, Map<Id, Account> mapAccountsByPassHighChildren, Map<Id, Account> mapAccountsSyncUpdate, Map<String, Object> mapFieldValues){
        Id recordTypeIdEnterprise = (Id)mapFieldValues.get('recordTypeIdEnterprise');
        Id regionalBetaUserId = (Id)mapFieldValues.get('regionalBetaUserId');
        for(Contact objContact : [SELECT Id, AccountId, Email, Account.Account_Owner_RecordType_For_Batch__c FROM Contact WHERE Email Like '%byPassOnHold%' OR Email Like '%byPassHighChildren%' OR Email Like '%syncUpdate%']){
            if(objContact.Email.containsIgnoreCase('byPassOnHold')){
                mapAccountsByPassOnHold.put(objContact.AccountId, new Account(RecordTypeId = recordTypeIdEnterprise, OwnerId = regionalBetaUserId, Id = objContact.AccountId, Account_Owner_RecordType_For_Batch__c = objContact.Account.Account_Owner_RecordType_For_Batch__c));
            }else if(objContact.Email.containsIgnoreCase('byPassHighChildren')){
                mapAccountsByPassHighChildren.put(objContact.AccountId, new Account(RecordTypeId = recordTypeIdEnterprise, OwnerId = regionalBetaUserId, Id = objContact.AccountId, Account_Owner_RecordType_For_Batch__c = objContact.Account.Account_Owner_RecordType_For_Batch__c));
            }else if(objContact.Email.containsIgnoreCase('syncUpdate')){
                mapAccountsSyncUpdate.put(objContact.AccountId, new Account(RecordTypeId = recordTypeIdEnterprise, OwnerId = regionalBetaUserId, Id = objContact.AccountId, Account_Owner_RecordType_For_Batch__c = objContact.Account.Account_Owner_RecordType_For_Batch__c));
            }
        }
    }    
    
}