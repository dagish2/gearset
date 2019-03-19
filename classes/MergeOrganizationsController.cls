/************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   This class contain all aura methods related to MergeOrganizations Lightning Component.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           10 Jan 2019         Prashant Mane        	Initial Developement
**************************************************************************************************************************************/
global without sharing class MergeOrganizationsController {
    public static Boolean isInvoker = false;
    public static Savepoint sp {get;set;}
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'MergeOrganizationsController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    
    @AuraEnabled
    public static DatabaseResult validateAccounts(Id masterAccountId, List<Id> selectedAccounts){
        try{
            Debug.log('masterAccountId---'+masterAccountId);
            Map<String, Object> mergeResult = new Map<String, Object>();                
            Account masterRecord = new Account();
            List<Account> lstMergedAccount = new List<Account>();       
            String profileName = Settings.getUserById(UserInfo.getUserId()).Profile.Name;         
            MergeOrganisation objWrapperMerge = (MergeOrganisation)JSON.deserialize(Settings.get('MergeOrganizationsSetting').data__c, MergeOrganisation.class);
            Set<Id> setOfMasterHierarchy = new Set<Id>();
            Set<Id> setOfChilds = new Set<Id>();
            if(objWrapperMerge.OwnershipProfiles.contains(profileName)){
                Map<Id,Account> selectedAccount = new Map<Id,Account>([SELECT Id,Name,HierarchyLevel__c,ParentId,Parent.Parent.Id,Parent.Parent.Parent.Id,Parent.Parent.Parent.Parent.Id,Parent.Parent.Parent.Parent.Parent.Id FROM Account WHERE Id IN :selectedAccounts]);
                Debug.log('selectedAccount---'+selectedAccount);           
                for(Account objAccount : selectedAccount.values()){
                    if(masterAccountId == objAccount.Id){
                        masterRecord = objAccount;
                        setOfMasterHierarchy.add(objAccount.ParentId);
                        setOfMasterHierarchy.add(objAccount.Parent.Parent.Id);
                        setOfMasterHierarchy.add(objAccount.Parent.Parent.Parent.Id);
                        setOfMasterHierarchy.add(objAccount.Parent.Parent.Parent.Parent.Id);
                        setOfMasterHierarchy.add(objAccount.Parent.Parent.Parent.Parent.Parent.Id);
                    }else{
                        setOfChilds.add(objAccount.Id);
                        lstMergedAccount.add(objAccount);
                    }
                } 
                setOfMasterHierarchy.remove(null);
                Integer beforeCount =  setOfMasterHierarchy.size();
                setOfMasterHierarchy.removeAll(setOfChilds);           
                if(masterRecord != null && masterRecord.HierarchyLevel__c == null){
                    mergeResult.put('success', false);
                    mergeResult.put('message', 'Master Record Hierarchy Level is more than 5.');                
                }else{
                    mergeResult.put('success', true); 
                }
                Debug.log('masterRecord---'+masterRecord);
                Debug.log('lstMergedAccount---'+lstMergedAccount);
                for(Account account : lstMergedAccount){
                    Debug.log('account---'+account);
                    if(account.HierarchyLevel__c == null){
                        mergeResult.put('success', false);
                        mergeResult.put('message', 'Hierarchy Level is more than 5.');  
                        break;
                    }else{
                        mergeResult.put('success', true); 
                    }
                    if(Integer.valueOf(account.HierarchyLevel__c) < Integer.valueOf(masterRecord.HierarchyLevel__c) && setOfMasterHierarchy.size() < beforeCount){
                        mergeResult.put('success', false);
                        mergeResult.put('message', 'Master account must be higher in account heirarchy.');
                        break;
                    }else{
                        mergeResult.put('success', true);  
                    }
                }
                if(mergeResult != null && mergeResult.containsKey('success') && Boolean.valueOf(mergeResult.get('success'))){                
                    mergeResult.put('masterRecord',masterRecord);
                    mergeResult.put('lstMergedAccount',lstMergedAccount);                
                    Debug.log('mergeResult==>'+mergeResult);
                    // mergeResult = mergeAccounts(masterRecord, lstMergedAccount);      
                }                                
            }
            return new DatabaseResult(JSON.serialize(mergeResult));
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'masterAccountId==>'+masterAccountId, 'MergeOrganizationsController', 'validateAccounts');            
            return (new DatabaseResult(pEx));      
        }
    }
    
   /**********************************************************************************************************************************************
            Author              :   Jitesh Adwani
            Description         :   This method is used to Merge Org Account to Org and Sales Account To Sales and check whether the 
            Logged In User has Permission or Not. 
            Created Date        :   12 June 2018   
            Issue No.           :   -
            ***********************************************************************************************************************************
            Author              :   Krishana Tupe   
            Created Date    	:   23 July 2018 
            Description         :   Made required changes for validating merge accounts reported by Devdatta 
            Issue No.       	:   -
    ***********************************************************************************************************************************************/     
    @AuraEnabled
    public static DatabaseResult mergeAccountsToMaster(Account masterRecord, List<Account> lstMergedAccount){
        try{
            sp = Database.setSavepoint();
            Debug.log('mergeAccounts masterRecord==>'+masterRecord);
            Debug.log('mergeAccounts lstMergedAccount==>'+lstMergedAccount);        
            Database.MergeResult[] results = Database.merge(new Account(Id = masterRecord.Id), new List<Account>(lstMergedAccount), false);        
            Debug.log('results-->'+results);
            ReturnValidResults objResults = new ReturnValidResults();
            for(Database.MergeResult res : results){
                if(res.isSuccess()){                    
                    objResults.isSuccess = true;
                    objResults.message = 'Accounts merged successfully. Redirecting you to the Primary Account';
                }else{
                    for(Database.Error error: res.getErrors()){                       
                        objResults.isSuccess = false;
                        objResults.message = error.getMessage();                        
                    }
                }
            }
            Debug.log('objResults ==>'+objResults);
            return new DatabaseResult(JSON.serialize(objResults)); 
        }catch(Exception pEx){
            LightningComponentController.rollbackTransaction(sp);
            ApexDebugLog.logException(pEx,'masterRecord==>'+masterRecord, 'MergeOrganizationsController', 'mergeAccountsToMaster');            
            return (new DatabaseResult(pEx));  
        }
    }
    
    @AuraEnabled
    public static DatabaseResult getAccountsToDisplay(List<String> arrQuery){
        try{
            List<Account> lstAccounts1 = new List<Account>();
            List<Account> lstAccounts2 = new List<Account>();
            set<Account> setUniqueAccounts = new set<Account>();
            lstAccounts1 = Database.query(arrQuery[0]);
            lstAccounts2 = Database.query(arrQuery[1]);
            setUniqueAccounts.addAll(lstAccounts1);
            setUniqueAccounts.addAll(lstAccounts2);
            DatabaseResult result = new DatabaseResult(setUniqueAccounts);
            return result;
        }catch(Exception pEx){                       
            ApexDebugLog.logException(pEx,'', 'MergeOrganizationsController', 'getAccountsToDisplay');            
            return (new DatabaseResult(pEx));           
        }
    }
    
    /**********************************************************************************************************************************************
    Author              :   Krishana Tupe
    Description         :   This method is used to validate the organization merge functionality.                            
    Created Date        :   23 July 2018   
    Issue No.           :   -
  ***********************************************************************************************************************************************/ 
    @AuraEnabled
    public static DatabaseResult validateMergeAccounts(String masterAccountId, List<Id> selectedAccounts){
        try{
            Debug.log('validateMergeAccounts masterAccountId ==>'+masterAccountId);
            Debug.log('validateMergeAccounts selectedAccounts ==>'+selectedAccounts);       
            Account masterRecord;
            List<Account> lstMergedAccount = new List<Account>(); 
            ReturnValidResults objResults = new ReturnValidResults();
            Set<Id> setOfMasterHierarchy = new Set<Id>();
            Set<Id> setOfChilds = new Set<Id>();        
            Map<Id,Account> selectedAccount = new Map<Id,Account>([SELECT Id,Name,HierarchyLevel__c,ParentId,Parent.Parent.Id,Parent.Parent.Parent.Id,Parent.Parent.Parent.Parent.Id,Parent.Parent.Parent.Parent.Parent.Id FROM Account WHERE Id IN :selectedAccounts]);
            for(Account objAccount : selectedAccount.values()){
                if(Id.valueOf(masterAccountId) == objAccount.Id){
                    masterRecord = objAccount;
                    setOfMasterHierarchy.add(objAccount.ParentId);
                    setOfMasterHierarchy.add(objAccount.Parent.Parent.Id);
                    setOfMasterHierarchy.add(objAccount.Parent.Parent.Parent.Id);
                    setOfMasterHierarchy.add(objAccount.Parent.Parent.Parent.Parent.Id);
                    setOfMasterHierarchy.add(objAccount.Parent.Parent.Parent.Parent.Parent.Id);
                }else{
                    setOfChilds.add(objAccount.Id);
                    lstMergedAccount.add(objAccount);
                }
            } 
            setOfMasterHierarchy.remove(null);
            Integer beforeCount =  setOfMasterHierarchy.size();
            setOfMasterHierarchy.removeAll(setOfChilds);           
            if(masterRecord.HierarchyLevel__c == null){
                return new DatabaseResult(false,'false','Master Record Hierarchy Level is more than 5.');
            }
            for(Account account:lstMergedAccount){
                if(account.HierarchyLevel__c == null){
                    return new DatabaseResult(false,'false','Hierarchy Level is more than 5.');   
                }                   
                if(Integer.valueOf(account.HierarchyLevel__c) < Integer.valueOf(masterRecord.HierarchyLevel__c) && setOfMasterHierarchy.size() <= beforeCount){
                    return new DatabaseResult(false,'false','Master account must be higher in account heirarchy');
                }
            }
            Map<String,List<Account>> mapAccountsToMerge = new Map<String,List<Account>>();
            mapAccountsToMerge.put('masterRecord',new List<Account>{masterRecord});
            mapAccountsToMerge.put('lstMergedAccount',lstMergedAccount);
            Debug.log('mapAccountsToMerge==>'+mapAccountsToMerge);
            return new DatabaseResult(mapAccountsToMerge);  
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'masterAccountId==>'+masterAccountId, 'MergeOrganizationsController', 'validateMergeAccounts');            
            return (new DatabaseResult(pEx));       
        }
    }
    
    public class MergeOrganisation {
        public List<MetaFields> metaFields;
        public List<String> OwnershipProfiles;
        public List<String> queryFields;
    }
    
    public class MetaFields {
        public String name;
        public String label;
    }  
    
    public class ReturnValidResults{
        public boolean isSuccess;
        public String message;        
    }
    
}