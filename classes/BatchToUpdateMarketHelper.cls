/************************************************************************************************************************************
	Author		: 	Krishana Tupe
	Description	: 	This batch class handle Geography insertion using google api account update related market on Account record.
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE	        		AUTHOR                     	DETAIL
	1	    	12 December 2018		Krishana Tupe             	Initial Developement
	2	    	23 January 2019			Krishana Tupe            	Made changes for Lead/Account update Market logic
**************************************************************************************************************************************/
public class BatchToUpdateMarketHelper {
    public static Map<String, List<sObject>> mapSObjectsToUpdate = new Map<String, List<sObject>>();
    public static Map<String, sObject> mapOpportunitiesToUpdateViaAssignment = new Map<String, sObject>();
    
/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method ensures that appropriate batch will be called.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public static Boolean isReRunBatch(String sObjectName, map<String, object> mapUpdateMarketBatchMDT){
        Map<String, object> mapBatchInfo;
        if(sObjectName == 'Lead'){
            mapBatchInfo = (Map<String, object>)mapUpdateMarketBatchMDT.get('Account');
        }else if(sObjectName == 'Account'){
            mapBatchInfo = (Map<String, object>)mapUpdateMarketBatchMDT.get('Lead'); 
        }
        if(mapBatchInfo != null && mapBatchInfo.containsKey('Stop')){
            return Boolean.valueOf(mapBatchInfo.get('Stop'));
        } 
        return TRUE;
    }
    
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is use to return the batch size.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public static Integer getBatchSize(Map<String, object> mapUpdateMarketBatchMDT, String sObjectName){
        Integer batchSize = 80;
        if(mapUpdateMarketBatchMDT != null && mapUpdateMarketBatchMDT.containsKey(sObjectName)){
            Map<String, object> mapBatchInfo = (Map<String, object>)mapUpdateMarketBatchMDT.get(sObjectName);  
            if(mapBatchInfo.containsKey('Chunk Size')){
               batchSize = Integer.valueOf(mapBatchInfo.get('Chunk Size'));
            } 
        }
        return batchSize;
    }

  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is use to process the Account records to find and update the market on it.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public static Map<Id, sObject> getMarketAssignement(List<sObject> lstRecords){
        Map<Id, sObject> mapUpdateMarketResult = new Map<Id, sObject>();
        List<sObject> lstUpdateMarektResult = MarketAssignmentHandler.updateMarketOnSObject(lstRecords, false);
        if(lstUpdateMarektResult != null && !lstUpdateMarektResult.isEmpty()){
            mapUpdateMarketResult = new Map<Id, sObject>(lstUpdateMarektResult);
        } 
        return mapUpdateMarketResult;
    }
   
  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is use to process the Lead records to find and update the market on it.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public static void updateMarketonLead(List<sObject> lstLeads, Map<Id, sObject> mapUpdateMarketResult){
        Debug.Log('Lead lstLead ==>'+lstLeads);  
        Debug.Log('Lead mapUpdateMarketResult ==>'+mapUpdateMarketResult);
        if(lstLeads != null && !lstLeads.isEmpty()){
            List<Lead> lstLeadsToUpdate = new List<Lead>();
            for(Lead objLead : (List<Lead>)lstLeads){               
                if((String.isNotBlank(objLead.Processing_Stage__c) && objLead.Processing_Stage__c == 'Created') || objLead.Unomy_Updated_DateTime__c == NULL){
                    objLead.Bypass_Processing_Stage__c = 'Enriched';
                }
                Lead objTempLead;
                if(mapUpdateMarketResult.containsKey(objLead.Id)){               
                    objTempLead = (Lead)mapUpdateMarketResult.get(objLead.Id);
                }
                if(objLead.Lead_Demographic_Score__c == NULL){
                    objLead.Lead_Demographic_Score_Re_calculate__c = true;
                }
                if(String.isNotBlank(objLead.Processing_Stage__c) && (!objLead.Processing_Stage__c.equalsIgnoreCase('Assignment Complete') && !objLead.Processing_Stage__c.equalsIgnoreCase('Behavioural Scored'))){
                    objLead.Processing_Stage__c = 'Market Identified';
                } 
                Debug.log('objTempLead==>'+objTempLead);
                if(objTempLead != null){                
                    if(String.isNotBlank(objTempLead.Lead_Market__c)){
                        objLead.Lead_Market__c = objTempLead.Lead_Market__c;
                        objLead.Market_Identified_On__c = objTempLead.Market_Identified_On__c;
                    }
                    if(String.isNotBlank(objTempLead.Geography__c)){
                        objLead.Geography__c = objTempLead.Geography__c;                    
                    }                    
                }               
                
                if(objTempLead != null && String.isNotBlank(objLead.Lead_Market__c) && (String.isBlank(objLead.Update_HQ_Market_Status__c) || (String.isNotBlank(objLead.Update_HQ_Market_Status__c) && !objLead.Update_HQ_Market_Status__c.equalsIgnoreCase('Completed')))){
                    objLead.Update_HQ_Market_Status__c= 'Completed';
                }else if(objTempLead != null && String.isBlank(objLead.Lead_Market__c) && String.isNotBlank(objLead.Geography__c) && (String.isBlank(objLead.Update_HQ_Market_Status__c) || (!objLead.Update_HQ_Market_Status__c.equalsIgnoreCase('Completed') && !objLead.Update_HQ_Market_Status__c.equalsIgnoreCase('Retry Round 1')))){
                    objLead.Update_HQ_Market_Status__c= 'Retry Round 1';
                }else if(objTempLead != null && String.isBlank(objLead.Lead_Market__c) && String.isNotBlank(objLead.Geography__c) && (String.isBlank(objLead.Update_HQ_Market_Status__c) || objLead.Update_HQ_Market_Status__c.equalsIgnoreCase('Retry Round 1'))){
                    objLead.Update_HQ_Market_Status__c= 'Retry Round 2';
                }else if(objTempLead == null && (String.isBlank(objLead.Update_HQ_Market_Status__c) || (String.isNotBlank(objLead.Update_HQ_Market_Status__c) && !objLead.Update_HQ_Market_Status__c.equalsIgnoreCase('Retry Round 1')))){
                    objLead.Update_HQ_Market_Status__c= 'Retry Round 1'; 
                }else if(objTempLead == null && (String.isBlank(objLead.Update_HQ_Market_Status__c) || (String.isNotBlank(objLead.Update_HQ_Market_Status__c) && objLead.Update_HQ_Market_Status__c.equalsIgnoreCase('Retry Round 1')))){
                    objLead.Update_HQ_Market_Status__c= 'Retry Round 2'; 
                }
                lstLeadsToUpdate.add(objLead);
            }  
            BatchToUpdateMarketHelper.updatesObjectRecords(lstLeadsToUpdate);
        }
    }  
    
        
  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is use to process the Account records to find and update the market on it.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public static void updateMarketonAccount(List<sObject> lstAccounts, Map<Id, sObject> mapUpdateMarketResult){ 
        Debug.Log('Account records ==>'+lstAccounts);
        Debug.Log('Account mapUpdateMarketResult ==>'+mapUpdateMarketResult);
        Map<Id, sObject> mapOldAccounts;
        Map<Id, Account> mapNewAccounts = new Map<Id, Account>();
        if(lstAccounts != null && !lstAccounts.isEmpty()){
            Boolean isValideForAssignment = false;
            Map<Id, sObject> mapRecords = new Map<Id, sObject>(lstAccounts);
            mapOldAccounts = mapRecords.deepClone();
			List<sObject> lstsObjectsToUpdate = new List<sObject>(); 
            for(Account objAccountRec :  (List<Account>)lstAccounts){
                if(String.isNotBlank(objAccountRec.Processing_Stage__c)){
                   isValideForAssignment = objAccountRec.Processing_Stage__c.equalsIgnoreCase('On Hold'); 
                } 
                if(mapUpdateMarketResult.containskey(objAccountRec.Id)){
                    Account objAccount = (Account)mapUpdateMarketResult.get(objAccountRec.Id);
                    BatchToUpdateMarketHelper.updateMarketOnAcccount(objAccountRec, objAccount, lstsObjectsToUpdate);
                }else{                    
                    BatchToUpdateMarketHelper.updateAccountStages(objAccountRec);
                    objAccountRec.Processing_Stage__c = 'HQ Market Identified';
                    lstsObjectsToUpdate.add(objAccountRec);   
                }
                if(isValideForAssignment && objAccountRec.Forcefully_Account_Assignment__c && objAccountRec.getsObjects('Opportunities') != null && objAccountRec.getsObjects('Opportunities').size() > 0){
                    fireAccountAssignmentForOnHold(objAccountRec);
                }
                if(isValideForAssignment && String.isNotBlank(objAccountRec.Account_Owner_RecordType_For_Batch__c)){
                    changeOwnerAndRecordTypeId(objAccountRec);
                }
            }
            if(!mapOpportunitiesToUpdateViaAssignment.isEmpty()){
                AccountQueueServices.updateAccountQueues();
                Debug.Log('mapOpportunitiesToUpdateViaAssignment ==>'+mapOpportunitiesToUpdateViaAssignment);
                lstsObjectsToUpdate.AddAll(mapOpportunitiesToUpdateViaAssignment.values());
            }
            createRecordsToUpdate(lstAccounts, mapOldAccounts);
            BatchToUpdateMarketHelper.updatesObjectRecords(lstsObjectsToUpdate);
        }
    }
    
  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is use to update the Account processing stage depends on Market updation Success nd Failure.
        Created Date  		:   23 January 2019	
		Issue No.			:	-
  **************************************************************************************************************************************/
    public static void updateMarketOnAcccount(Account objAccountToUpdate , Account objAccount, List<Account> lstAccountsToUpdate){
        if((String.isNotBlank(objAccount.Account_Market__c) || String.isNotBlank(objAccount.Geography__c)) && (String.isBlank(objAccountToUpdate.Update_HQ_Market_Status__c) || (String.isNotBlank(objAccountToUpdate.Update_HQ_Market_Status__c) && !objAccountToUpdate.Update_HQ_Market_Status__c.equalsIgnoreCase('Completed')))){
            if(String.isNotBlank(objAccount.Account_Market__c)){
                objAccountToUpdate.Account_Market__c = objAccount.Account_Market__c; 
                objAccountToUpdate.Market_Identified_On__c = objAccount.Market_Identified_On__c; 
                objAccountToUpdate.Update_HQ_Market_Status__c = 'Completed';
            }
            if(String.isNotBlank(objAccount.Geography__c)){
                objAccountToUpdate.Geography__c = objAccount.Geography__c; 
                BatchToUpdateMarketHelper.updateAccountStages(objAccountToUpdate);
            }           
        }else if(String.isBlank(objAccountToUpdate.Processing_Stage__c)){
            BatchToUpdateMarketHelper.updateAccountStages(objAccountToUpdate);
        } 
        objAccountToUpdate.Processing_Stage__c = 'HQ Market Identified';
        lstAccountsToUpdate.add(objAccountToUpdate);
    }    
  
  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is use to update the Account processing stage depends on Market updation Success nd Failure.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public static void updateAccountStages(Account objAccountToUpdate){
        if(String.isBlank(objAccountToUpdate.Account_Market__c) || (String.isBlank(objAccountToUpdate.Account_Market__c) && String.isNotBlank(objAccountToUpdate.Geography__c))){
            if(String.isBlank(objAccountToUpdate.Update_HQ_Market_Status__c) || !objAccountToUpdate.Update_HQ_Market_Status__c.equalsIgnoreCase('Retry Round 1')){
                objAccountToUpdate.Update_HQ_Market_Status__c = 'Retry Round 1';   
            }else if(String.isNotBlank(objAccountToUpdate.Update_HQ_Market_Status__c) || objAccountToUpdate.Update_HQ_Market_Status__c.equalsIgnoreCase('Retry Round 1')){
                objAccountToUpdate.Update_HQ_Market_Status__c = 'Retry Round 2';    
            }   
        }else if(String.isBlank(objAccountToUpdate.Update_HQ_Market_Status__c) || !objAccountToUpdate.Update_HQ_Market_Status__c.equalsIgnoreCase('Completed')){
            objAccountToUpdate.Update_HQ_Market_Status__c = 'Completed';
        }  
    }
    
  /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is use to update the records.
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/
    public static void updatesObjectRecords(List<sObject> lstRecodToUpdates){
        Debug.log('lstRecodToUpdates==>'+lstRecodToUpdates);
        if(lstRecodToUpdates != null && !lstRecodToUpdates.isEmpty()){ 
            List<Database.SaveResult> lstSaveResults = Database.update(lstRecodToUpdates, false);
            Debug.log('lstSaveResults through Batch ==>'+lstSaveResults);
        }  
    }
    

 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to return the config metadata for batch which needs to find Market. 
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/    
    public static Map<String, object> getUpdateMarketBatchMetadata(String strMDTName){       
        MetadataSetting__mdt updateMarketBtachMDT = Settings.getMetadataSetting(strMDTName);
        if(updateMarketBtachMDT != null && String.isNotBlank(updateMarketBtachMDT.Data__c)){
            return (Map<String, object>)JSON.deserializeUntyped(updateMarketBtachMDT.Data__c);
        }
        return NULL;
    }   
    
   /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used chaining the update market batches for Lead and Account. 
        Created Date  		:   23 January 2019	
		Issue No.			:	ST-3343
  **************************************************************************************************************************************/    
    public static void executeBatchInChain(Boolean isStopBatch, Boolean isStop, String sObjectName, Integer batchSize){
        if(!isStopBatch){
            if(!isStop){
                switch on sObjectName{
                    when 'Lead' {
                        sObjectName = 'Account';
                    }
                    when 'Account' {
                        sObjectName = 'Lead';
                    }
                } 
            }
            Boolean runDefaultSizeBatch = true;
            if(mapSObjectsToUpdate != NULL && !mapSObjectsToUpdate.isEmpty()){
                List<AsyncApexJob> lstAsyncApexJobs = [SELECT Id FROM AsyncApexJob WHERE Status = 'Holding' FOR UPDATE];
                if(lstAsyncApexJobs.size() < 95){
                    Map<String, Integer> mapBatchMDTSetting = TrAccountByPassChildUpdate.getUpdateChildRecordsBatchMDTSetting();
                    Database.executeBatch(new BatchToUpdateOrInsertSObjects(getRecordsFromMap(mapSObjectsToUpdate)), mapBatchMDTSetting.get('BatchSize') != NULL ? mapBatchMDTSetting.get('BatchSize') : 200);
                    mapSObjectsToUpdate = new Map<String, List<sOBject>>();
                }else{
                    Database.executeBatch(new BatchToUpdateMarket(sObjectName, mapSObjectsToUpdate), (batchSize != null && batchSize > 0) ? batchSize : 80);
                    runDefaultSizeBatch = false;
                }
            }
            if(runDefaultSizeBatch){
                Database.executeBatch(new BatchToUpdateMarket(sObjectName), (batchSize != null && batchSize > 0) ? batchSize : 80);
            }
        }    
    }
    
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to forcefully fire account assignment from batch. 
        Created Date  		:   23 January 2019	
        Issue No.			:	ST-3343
    **************************************************************************************************************************************/    
    public static void fireAccountAssignmentForOnHold(Account objAccount){
        Debug.log('objAccount---'+objAccount);
        Id accountOwnerId;
        Id ownerId;
        List<Opportunity> lstOpportunitiesToUpdate = new List<Opportunity>();
        for(Opportunity objOpportunity : objAccount.Opportunities){
            Debug.log('objOpportunity---'+objOpportunity);
            ownerId = AccountAssignmentController.roeAccountRecordTypeForNewOpportunity(objAccount, objOpportunity);
            if(String.isNotBlank(ownerId)){
                Opportunity opportunityRec = new Opportunity(Id = objOpportunity.Id, Assignment_Status__c = 'Completed');
                if(AccountAssignmentHelper.checkValidUserForAssignment(objOpportunity.OwnerId)){
                    opportunityRec.OwnerId = ownerId;
                }
                mapOpportunitiesToUpdateViaAssignment.put(opportunityRec.Id, opportunityRec);
                if(AccountAssignmentController.mapAccountsToUpdate.containsKey(objAccount.Id)){
                    Account accountRec = AccountAssignmentController.mapAccountsToUpdate.get(objAccount.Id);
                    if(String.isBlank(accountOwnerId) && String.isNotBlank(accountRec.OwnerId)){
                        accountOwnerId = accountRec.OwnerId;
                        objAccount.Account_Owner_RecordType_For_Batch__c = NULL;
                    }
                    if(String.isNotBlank(accountRec.RecordTypeId)){
                        objAccount.RecordTypeId = accountRec.RecordTypeId;
                        objAccount.Account_Owner_RecordType_For_Batch__c = NULL;
                    }
                }
            }
        }
        if(String.isNotBlank(accountOwnerId) && AccountAssignmentHelper.checkValidUserForAssignment(objAccount.OwnerId)){
            objAccount.OwnerId = accountOwnerId;
        }
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   Populate Owner and Record Type on Account using Account_Owner_RecordType_For_Batch__c field. 
        Created Date  		:   22 Feb 2019	
    **************************************************************************************************************************************/    
    public static void changeOwnerAndRecordTypeId(Account objAccount){
        List<String> lstOwnerIdAndRecordTypeId = objAccount.Account_Owner_RecordType_For_Batch__c.split(';');
        if(lstOwnerIdAndRecordTypeId != NULL && !lstOwnerIdAndRecordTypeId.isEmpty()){
            for(String strRecordId : lstOwnerIdAndRecordTypeId){
                if(String.isNotBlank(strRecordId)){
                    Id recordId = Id.valueOf(strRecordId);
                    String sObjectName = recordId.getSObjectType().getDescribe().getName();
                    if(sObjectName.equalsIgnoreCase('user') && Settings.getUserActive(recordId)){
                        objAccount.OwnerId = recordId;
                    }else{
                        objAccount.RecordTypeId = recordId;
                    }
                }
            }
            objAccount.Account_Owner_RecordType_For_Batch__c = NULL;
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   Update Owner and Record Type on Account. 
        Created Date  		:   22 Feb 2019	
        // This is one for CPU hotfix.
    **************************************************************************************************************************************/    
    public static void createRecordsToUpdate(List<sObject> lstNewAccount, Map<Id, sObject> mapOldAccounts){
        Map<Id, Map<String, List<sObject>>> mapRecordsToUpdate = WithoutSharingUtilityController.changeChildsRecordTypeAndOwner(lstNewAccount, mapOldAccounts);
        if(mapRecordsToUpdate != NULL && !mapRecordsToUpdate.isEmpty()){
            if(mapSObjectsToUpdate == NULL){
                mapSObjectsToUpdate = new Map<String, List<sObject>>();
            }
            List<sObject> lstRecordsForThreshold = new List<sObject>();
            for(Map<String, List<sObject>> mapRecords : mapRecordsToUpdate.values()){
                for(String key : mapRecords.keySet()){
                    if(mapRecords.get(key) != NULL && !mapRecords.get(key).isEmpty()){
                        lstRecordsForThreshold.addAll(mapRecords.get(key));
                        addRecordsInMap(mapSObjectsToUpdate, key, mapRecords.get(key));
                    }
                }
            }
            Map<String, Integer> mapBatchMDTSetting = TrAccountByPassChildUpdate.getUpdateChildRecordsBatchMDTSetting();
            if(lstRecordsForThreshold.size() <= mapBatchMDTSetting.get('RecordsThreshold')){
                mapSObjectsToUpdate = new Map<String, List<sObject>>();
            }
        }
    }

    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   Update Owner and Record Type on Account. 
        Created Date  		:   22 Feb 2019	
        // This is one for CPU hotfix.
    **************************************************************************************************************************************/    
    public static void addRecordsInMap(Map<String, List<sObject>> mapRecordsToString, String keyName, List<sObject> lstRecords){
        if(mapRecordsToString == NULL){
            mapRecordsToString = new Map<String, List<sObject>>();
        }
        if(!mapRecordsToString.containsKey(keyName)){
            mapRecordsToString.put(keyName, new List<sObject>());
        }
        mapRecordsToString.get(keyName).addALL(lstRecords);
    }
    
   /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   Update Owner and Record Type on Account. 
        Created Date  		:   22 Feb 2019	
        // This is one for CPU hotfix.
    **************************************************************************************************************************************/    
    public static List<sObject> getRecordsFromMap(Map<String, List<sObject>> mapRecordsToString){
        if(mapRecordsToString == NULL){
            mapRecordsToString = new Map<String, List<sObject>>();
        }
        List<sObject> lstRecords = new List<sObject>();
        for(List<sObject> lstSobjects : mapRecordsToString.values()){
            lstRecords.addAll(lstSobjects);
        }
        return lstRecords;
    }
}