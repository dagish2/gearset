/************************************************************************************************************************************
Author      :   Dipak Pawar
Description :   This class contain all aura methods related to Account Selector.
----------------------------------------------------------------------------------------------------------------------------------
VERSION     DATE                AUTHOR                  DETAIL
1           13 Oct 2018        Dipak Pawar          	Initial Developement
**************************************************************************************************************************************/
global without sharing class AccountSelectorController {
    public class  AccountSelectorControllerException extends Exception{}
    public static Boolean isInvoker = false;
    public static Savepoint sp {get; set;}
    
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'AccountSelectorController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    
    /************************************************************************************************************************************
Author              : Dipak Pawar
Description         : This method gives the matched Accounts for the given Lead record
Created Date        : 16 Oct 2018
Issue No            : ST-2783
**************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getMatchedAccounts(Lead objLead){
        try{    
            if(objLead != null ){
                Id orgId = OrganizationHelper.findRelatedOrg(objLead);            
                if(orgId != null){
                    return new DatabaseResult(new List<Account>([SELECT Id, Name, Parent_Org_Id__c, Account_Type__c, OwnerId, Owner.Name, ParentId, Parent.Name, Primary_Member__c, Primary_Member__r.Name, Primary_Member__r.Email FROM Account WHERE Id =: orgId]));
                }  
            }
            return new DatabaseResult(new List<Account>());
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx, '', 'AccountSelectorController', 'getMatchedAccounts');
            return new DatabaseResult(pEx);  
        }
    }  
    
    /************************************************************************************************************************************
Author              : Dipak Pawar
Description         : This method gives the Sales Accounts related to given Account Id
Created Date        : 16 Oct 2018
Issue No            : ST-2783
**************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getRelatedSalesAccounts(String accountId){
        try{
            Account objAccount = [SELECT Id, Name, Parent_Org_Id__c, Account_Type__c, OwnerId, Owner.Name, ParentId, Parent.Name, Primary_Member__c, Primary_Member__r.Name, Primary_Member__r.Email, (SELECT Id FROM childAccounts WHERE Account_Type__c = 'Sales') FROM Account WHERE Id =: accountId];
            Debug.log('objAccount==>'+objAccount);    
            if(objAccount != null && objAccount.Account_Type__c == 'Sales'){
                return new DatabaseResult(new List<Account>([SELECT Id, Name, Parent_Org_Id__c, Account_Type__c, OwnerId, Owner.Name, ParentId, Parent.Name, Primary_Member__c, Primary_Member__r.Name, Primary_Member__r.Email FROM Account WHERE (Id =: objAccount.Id  OR ParentId =: objAccount.Id OR ParentId =: objAccount.ParentId OR ParentId =: objAccount.Parent_Org_Id__c OR Parent_Org_Id__c =: String.valueOf(objAccount.Parent_Org_Id__c).subString(0,15)) AND Account_Type__c = 'Sales']));
            }else if(objAccount != null && objAccount.Account_Type__c == 'Org'){
                return new DatabaseResult(new List<Account>([SELECT Id, Name, Parent_Org_Id__c, Account_Type__c, OwnerId, Owner.Name, ParentId, Parent.Name, Primary_Member__c, Primary_Member__r.Name, Primary_Member__r.Email FROM Account WHERE (Id =: objAccount.Id OR ParentId =: objAccount.Id OR Parent_Org_Id__c =: String.valueOf(objAccount.Id).subString(0,15)) AND Account_Type__c = 'Sales']));
            } 
            return null;
        } catch(Exception pEx){
            ApexDebugLog.logException(pEx, '', 'AccountSelectorController', 'getRelatedSalesAccounts');
            return new DatabaseResult(pEx);  
        }
    } 
    
    /************************************************************************************************************************************
	Author              : Dipak Pawar
	Description         : This method gives the complete Account Hierarchy for given Account id
	Created Date        : 16 Oct 2018
	Issue No            : ST-2783
	**************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getRelatedViewHierarchy(String accountId){
        try{
            Account objAccount = [SELECT Id, Name, Parent_Org_Id__c, Account_Type__c, OwnerId, Owner.Name, ParentId, Parent.Name, Primary_Member__c, Primary_Member__r.Name, Primary_Member__r.Email FROM Account WHERE Id =: accountId];
            if(objAccount != null && objAccount.Parent_Org_Id__c != null){
                return new DatabaseResult(new List<Account>([SELECT Id, Name, Parent_Org_Id__c, Account_Type__c, OwnerId, Owner.Name, ParentId, Parent.Name, Primary_Member__c, Primary_Member__r.Name, Primary_Member__r.Email FROM Account WHERE (Id =: objAccount.Id OR ParentId =: objAccount.Id OR Parent_Org_Id__c =: String.valueOf(objAccount.Id).subString(0,15) OR Id =: objAccount.Parent_Org_Id__c OR ParentId = : objAccount.Parent_Org_Id__c OR Parent_Org_Id__c =: String.valueOf(objAccount.Parent_Org_Id__c).subString(0,15))]));
            }else if(objAccount != null && objAccount.Account_Type__c == 'Org'){
                return new DatabaseResult(new List<Account>([SELECT Id, Name, Parent_Org_Id__c, Account_Type__c, OwnerId, Owner.Name, ParentId, Parent.Name, Primary_Member__c, Primary_Member__r.Name, Primary_Member__r.Email FROM Account WHERE (Id =: objAccount.Id OR ParentId =: objAccount.Id OR Parent_Org_Id__c =: String.valueOf(objAccount.Id).subString(0,15))]));
            } 
            return null;
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx, '', 'AccountSelectorController', 'getRelatedViewHierarchy');
            return new DatabaseResult(pEx);  
        }
    }
    
    /************************************************************************************************************************************
	Author              : Shivprasad Patil
	Description         : This method used to generate query result for dynamic label.
	Created Date        : 03 December 2018
	Issue No            : -
	**************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getQueryData(String label, Map<String, Object> params){
        try{
            Debug.log('params=='+params);
            switch on label{
                when 'searchOrgAccounts'{
                    String accountType = (String)params.get('accountType');
                    String query = 'SELECT Id, Name, OwnerId, Account_SubType__c, Website, Owner.Name, Parent_Org__c, Parent_Org_Id__c, Primary_Member__r.Name, Account_Type__c FROM Account WHERE ';
                    query += accountType == 'Broker' ? ' Account_SubType__c = \'Broker\' ' :(accountType == 'All' ? '( Account_Type__c = \'Org\' OR Account_Type__c = \'Sales\')' : (accountType == 'Org' ? 'Account_Type__c = \'Org\'' : 'Account_Type__c = \'Sales\''));
                    if(params.containsKey('searchAllOrg') && !((Boolean)params.get('searchAllOrg'))){
                        query += ' AND RecordType.Name = \'Enterprise Solutions\' ';
                    }
                    query += ' AND Name LIKE \'' + (String)params.get('accountName') + '%\'';
                    return new DatabaseResult(Database.query(query));
                }
            }
            return new DatabaseResult(new List<sObject>());
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx, '', 'AccountSelectorController', 'getQueryData');
            return new DatabaseResult(pEx);  
        }
    }
}