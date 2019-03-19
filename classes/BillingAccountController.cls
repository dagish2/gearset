/************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   This class contain all aura methods related to TransferPaperwork.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           10 Jan 2019         Prashant Mane        	Initial Developement
**************************************************************************************************************************************/
global without sharing class BillingAccountController {
    public static Boolean isInvoker = false;
    public static Savepoint sp {get;set;}
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'BillingAccountController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    
    /************************************************************************************************************************************
        Author              : Shivprasad Patil
        Description         : This method takes record Id and returns All Bill type and Blank type Billing_Accounts in hierarchy.
        Created Date        : 06 April 2018
        Issue No.           : 
        Last Modified Date  : 31,May 2018
        Last Modified By    : Ashish Mishra
	**************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getBillAccountsOfAccountHierarchy(String accountId, String opportunityId){
        try{
            BillAccountsForAccountHierarchy billAccountsForAccountHierarchyRec = new BillAccountsForAccountHierarchy(); 
            Id ultimateParentOrgId;
            billAccountsForAccountHierarchyRec.accountInfo = [Select Id,Account_Type__c,Parent_Org_Name__c,Number_of_Full_Time_Employees__c From Account Where Id =:accountId LIMIT 1];
            if(String.isNotBlank(billAccountsForAccountHierarchyRec.accountInfo.Account_Type__c) && billAccountsForAccountHierarchyRec.accountInfo.Account_Type__c.toLowerCase() != 'bill'){
                DataBaseResult orgData = LightningComponentController.getOrg(accountId);
                if(orgData != null && orgData.data != null){
                    ultimateParentOrgId = Id.valueOf((String)JSON.deserialize(JSON.serialize(LightningComponentController.getOrg(accountId).data), String.class));   
                    system.debug('ultimateParentOrgId'+ultimateParentOrgId);
                    billAccountsForAccountHierarchyRec.ultimateParentOrgId = ultimateParentOrgId;
                    billAccountsForAccountHierarchyRec.lstBillAccounts = [SELECT Id, OwnerId,ID_Status__c, Owner.Name,Parent_Account__r.Name,Parent_Account__r.Account_Type__c, Parent_Account__c, Name, Primary_Member__c, Primary_Member__r.Name,Primary_Member__r.Email, Primary_Member__r.Id, UUID__c, (Select Id From Opportunities__r where stagename='Selling' OR stagename='Qualifying' OR stagename='Negotiating' Or stagename='Closing') FROM Billing_Account__c WHERE (Ultimate_Parent_Org__c =:ultimateParentOrgId)];        
                    billAccountsForAccountHierarchyRec.accountInfo = [Select Id,Parent_Org_Name__c,Account_Type__c,Number_of_Full_Time_Employees__c From Account Where Id =:ultimateParentOrgId LIMIT 1];
                } 
                Opportunity objOpportunity = [SELECT Id, Name, Primary_Member__c, Primary_Member__r.Email, Primary_Member__r.Phone, Primary_Member__r.AccountId, Primary_Member__r.Account.Parent_Org_Name__c, Primary_Member__r.Billing_Account__c, Primary_Member__r.Billing_Account__r.Name FROM Opportunity WHERE Id =:opportunityId LIMIT 1];
                billAccountsForAccountHierarchyRec.opportunityPrimaryMember = objOpportunity.Primary_Member__r;
                Debug.log('getBillAccountsOfAccountHierarchy billAccountsForAccountHierarchyRec--- '+billAccountsForAccountHierarchyRec);  
            }
            return (new DatabaseResult(billAccountsForAccountHierarchyRec));
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'accountId==>'+accountId + ' opportunityId '+opportunityId, 'BillingAccountController', 'getBillAccountsOfAccountHierarchy');            
            return (new DatabaseResult(pEx)); 
        }
    }
    
   /**************************************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to check account is already present or not, if not present then insert NewAccount For SendPaperwork.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   ***************************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult insertNewAccountForSendPaperwork(Map<String,String> mapNewObject){
        try{
            sp = Database.setSavepoint();
            List<Billing_Account__c> lstAccounts = [Select Id,UUID__c From Billing_Account__c Where UUID__c=:mapNewObject.get('accountUUID')];
            if(lstAccounts.size()>0){
                return new DatabaseResult(lstAccounts[0]);
            }else{
                Debug.Log('value--->'+mapNewObject.get('parentId'));
                Billing_Account__c billingAccountRec = (Billing_Account__c)FieldMappingsHelper.getMappings(mapNewObject.get('parentId'), 'FieldMappings:AccountToBillingAccount');
                billingAccountRec.Name = mapNewObject.get('AccountName');
                billingAccountRec.UUID__c = mapNewObject.get('accountUUID');
                billingAccountRec.Name = mapNewObject.get('AccountName');
                billingAccountRec.Parent_Account__c = mapNewObject.get('parentId');
                Contact objContact;
                if(mapNewObject.get('contactId') != null){
                    billingAccountRec.Primary_Member__c  = mapNewObject.get('contactId');
                    insert billingAccountRec;
                    objContact = new Contact(Id=mapNewObject.get('contactId'),UUID__c = mapNewObject.get('primaryMemberUUID'),Billing_Account__c=billingAccountRec.Id);
                    if(mapNewObject.containsKey('contactAccountId') && mapNewObject.get('contactAccountId') != null){
                        objContact.AccountId = (mapNewObject.containsKey('contactAccountId') && mapNewObject.get('contactAccountId')!= null ? mapNewObject.get('contactAccountId') : null);
                    }
                    UPDATE objContact;
                }else{
                    insert billingAccountRec;
                    List<String> lstNames = mapNewObject.get('ContactName').split(' ');
                    String strFirstName = '',strLastName = '';
                    if(lstNames.size()>1){
                        strFirstName = lstNames[0];
                        lstNames.remove(0);
                        strLastName = String.join(lstNames,' ');
                    }else{
                        strLastName = String.join(lstNames,' ');
                    }
                    objContact = new Contact(FirstName=strFirstName,LastName=strLastName,Billing_Account__c=billingAccountRec.Id,AccountId=(mapNewObject.containsKey('parentId') && mapNewObject.get('parentId')!= null ? mapNewObject.get('parentId') : null),Email=mapNewObject.get('Email'),Phone=mapNewObject.get('Phone'),UUID__c=mapNewObject.get('primaryMemberUUID'));
                    insert objContact;
                    billingAccountRec.Primary_Member__c = objContact.Id;
                    update billingAccountRec;
                }
                return new DatabaseResult(billingAccountRec);
            }
        }catch(Exception pEx){
            LightningComponentController.rollbackTransaction(sp);
            ApexDebugLog.logException(pEx,'', 'BillingAccountController', 'insertNewAccountForSendPaperwork');            
            return (new DatabaseResult(pEx)); 
        }
    }
        
    class BillAccountsForAccountHierarchy{
        @AuraEnabled
        public Id ultimateParentOrgId;
        @AuraEnabled
        public List<Billing_Account__c> lstBillAccounts;
        @AuraEnabled
        public Account accountInfo;
        @AuraEnabled
        public Contact opportunityPrimaryMember;
    }
}