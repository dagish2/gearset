/************************************************************************************************************************************
    Author      :   Shobhit Gahlot
    Description :   This Trigger is used in before update for by passing the child owner change trigger depending on the threshold 
					value set in the setting.
    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           18 Feb 2019    		Shobhit Gahlot          Initial Developement
**************************************************************************************************************************************/
public class TrAccountByPassChildUpdate implements IProcessHandler{
    
    static Map<String, Integer> mapBatchMDTSetting;
    public static List<sObject> lstchildObjectsToUpdate;
    public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap) {
        lstchildObjectsToUpdate = null;
        Map<Id, Map<String, List<sObject>>> mapAccountsWithOwnerOrRecordTypeChange = WithoutSharingUtilityController.changeChildsRecordTypeAndOwner(triggerNew, triggerOldMap);
        Debug.log('TrAccountByPassChildOwnerChange mapAccountsWithOwnerOrRecordTypeChange =='+mapAccountsWithOwnerOrRecordTypeChange.size());
        getUpdateChildRecordsBatchMDTSetting();
        if(mapAccountsWithOwnerOrRecordTypeChange == null || mapAccountsWithOwnerOrRecordTypeChange.size() == 0 || mapBatchMDTSetting == null){
            return;
        }else{
            Map<Id, sObject> mapNewAccounts = new Map<Id, sObject>(); 
            mapNewAccounts.putAll(triggerNew);
            checkForNumberOfChildRecordsThreshold(mapAccountsWithOwnerOrRecordTypeChange, mapNewAccounts, triggerOldMap);
        }
        TriggerProcessingManager.mapNumOfIterationsByProcess.remove('TrAccountByPassChildUpdate');
    }
    
    public static void checkForNumberOfChildRecordsThreshold(Map<Id, Map<String, List<sObject>>> mapAccountsWithOwnerOrRecordTypeChange, Map<Id, sObject> mapNewAccounts, Map<Id, sObject> triggerOldMap){
        List<Id> tempListAccountIdsForPossibleSyncUpdate = new List<Id>();
        Integer totalChildRecords = 0;
        Integer childRecordsPerAccount = 0;
        List<String> lstChilds = new List<String>{'Contacts','Opportunities','childAccounts'};
        String ProcessingStageOld, ProcessingStageNew;
        for(Id objAccountId : mapAccountsWithOwnerOrRecordTypeChange.keyset()){
            childRecordsPerAccount = 0;
            Account objOldAccount = (Account) triggerOldMap.get(objAccountId);
            Account objNewAccount = (Account) mapNewAccounts.get(objAccountId);
            if(objOldAccount.Processing_Stage__c == objNewAccount.Processing_Stage__c && String.isNotBlank(objNewAccount.Processing_Stage__c) &&  objNewAccount.Processing_Stage__c.equalsIgnoreCase('On Hold')){
                handleAboveThresholdAccounts(mapAccountsWithOwnerOrRecordTypeChange, mapNewAccounts, triggerOldMap, objAccountId);
                continue;
            }
            if((objOldAccount.Processing_Stage__c != objNewAccount.Processing_Stage__c && String.isNotBlank(objNewAccount.Processing_Stage__c) && objNewAccount.Processing_Stage__c.equalsIgnoreCase('HQ Market Identified'))
              && (BatchToUpdateMarketHelper.mapSObjectsToUpdate != NULL && !BatchToUpdateMarketHelper.mapSObjectsToUpdate.isEmpty())){
                // This is necessary so that if the account is waiting for assignment from batch and the owner is changed then we will bypass that change and reset account
                mapAccountsWithOwnerOrRecordTypeChange.remove(objAccountId);
                continue;
            }
            for(String childNameObject : lstChilds){
                if(mapAccountsWithOwnerOrRecordTypeChange.get(objAccountId).get(childNameObject) != null){
                    childRecordsPerAccount += mapAccountsWithOwnerOrRecordTypeChange.get(objAccountId).get(childNameObject).size(); 
                }
            }
            totalChildRecords += childRecordsPerAccount;
            if(childRecordsPerAccount > mapBatchMDTSetting.get('RecordsThreshold') || totalChildRecords > mapBatchMDTSetting.get('RecordsThreshold')){
                handleAboveThresholdAccounts(mapAccountsWithOwnerOrRecordTypeChange, mapNewAccounts, triggerOldMap, objAccountId);
            }else if(totalChildRecords <= mapBatchMDTSetting.get('RecordsThreshold') || childRecordsPerAccount <= mapBatchMDTSetting.get('RecordsThreshold')){
                tempListAccountIdsForPossibleSyncUpdate.add(objAccountId);
            }
        }
        Debug.log('totalChildRecords===>'+totalChildRecords);
        Debug.log('tempListAccountIdsForPossibleSyncUpdate.size()===>'+tempListAccountIdsForPossibleSyncUpdate.size());
        if(totalChildRecords > mapBatchMDTSetting.get('RecordsThreshold') && tempListAccountIdsForPossibleSyncUpdate.size() > 0){
            for(Id objAccountId : tempListAccountIdsForPossibleSyncUpdate){
                handleAboveThresholdAccounts(mapAccountsWithOwnerOrRecordTypeChange, mapNewAccounts, triggerOldMap, objAccountId);
            }
        }else if(totalChildRecords < mapBatchMDTSetting.get('RecordsThreshold') && tempListAccountIdsForPossibleSyncUpdate.size() > 0){
            lstchildObjectsToUpdate = new List<sObject>();
            List<sObject> lstContacts = new List<sObject>();
            List<sObject> lstOpportunities = new List<sObject>();
            List<sObject> lstChildAccounts = new List<sObject>();
            Map<String, List<sObject>> mapAccountForPossibleSyncUpdate;
            for(Id objAccountId : tempListAccountIdsForPossibleSyncUpdate){
                mapAccountForPossibleSyncUpdate = mapAccountsWithOwnerOrRecordTypeChange.get(objAccountId);
                if(mapAccountForPossibleSyncUpdate != null && mapAccountForPossibleSyncUpdate.size() > 0){
                    for(String childNameObject : mapAccountForPossibleSyncUpdate.keyset()){
                        List<sobject> tempList = mapAccountForPossibleSyncUpdate.get(childNameObject);
                        if(tempList != null && tempList.size() > 0){
                            if(childNameObject.equalsIgnoreCase('Contacts')){
                                lstContacts.addAll(tempList);
                            }else if(childNameObject.equalsIgnoreCase('Opportunities')){
                                lstOpportunities.addAll(tempList);
                            }else if(childNameObject.equalsIgnoreCase('childAccounts')){
                                lstChildAccounts.addAll(tempList);
                            }
                        }
                    }
                }
            }
            lstchildObjectsToUpdate.addAll(lstContacts);
            lstchildObjectsToUpdate.addAll(lstOpportunities);
            lstchildObjectsToUpdate.addAll(lstChildAccounts);
        }
    }

    private static void handleAboveThresholdAccounts(Map<Id, Map<String, List<sObject>>> mapAccountsWithOwnerOrRecordTypeChange, Map<Id, sObject> mapNewAccounts, Map<Id, sObject> triggerOldMap, Id objAccountId){
        markAccountsForBatch((Account) mapNewAccounts.get(objAccountId),(Account) triggerOldMap.get(objAccountId));
        mapAccountsWithOwnerOrRecordTypeChange.remove(objAccountId);
    }

    private static void markAccountsForBatch(Account newAccount, Account oldAccount){
        newAccount.Account_Owner_RecordType_For_Batch__c = newAccount.OwnerId + ';' + newAccount.RecordTypeId;
        newAccount.OwnerId = oldAccount.OwnerId;
        newAccount.Processing_Stage__c = 'On Hold';
        newAccount.RecordTypeId = oldAccount.RecordTypeId;
    }
    
    public static Map<String, Integer> getUpdateChildRecordsBatchMDTSetting(){       
        if(mapBatchMDTSetting == NULL){ 
            try{
                mapBatchMDTSetting = (Map<String, Integer>)JSON.deserialize(Settings.getMetadataSetting('BatchToUpdateChildRecordMetadata_Setting').Data__c, Map<String, Integer>.class);       
                if(Test.isRunningTest()){
                    mapBatchMDTSetting.put('RecordsThreshold', mapBatchMDTSetting.get('TestRecordsThreshold'));
                }
            }catch(Exception pEx){
                setDefaultBatchMetaData();
            }         
        }
        return mapBatchMDTSetting;
    } 
    
    public static void setDefaultBatchMetaData(){
        mapBatchMDTSetting = new Map<String, Integer>();
        mapBatchMDTSetting.put('BatchSize', 200);
        mapBatchMDTSetting.put('RecordsThreshold', 100);
    }
}