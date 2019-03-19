/************************************************************************************************************************************
    Author      :   Dipak Pawar
    Description :   This class contain all aura methods related to AssignToAccount.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           18 July 2018        Dipak Pawar      		Initial Developement
**************************************************************************************************************************************/
global without sharing class AssociateBillingAccountController {
    public class AssociateBillingAccountControllerException extends Exception{}
    public static Boolean isInvoker = false;
    public static Savepoint sp {get;set;}
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'AssociateBillingAccountController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    
    /************************************************************************************************************************************
        Author              : Dipak Pawar
        Description         : This method brings the opportunity data, ultimateParentOrgId, billingAccounts, TourReservableAPI apiSetting .
        Created Date        : 18 July 2018 
		Last Modified Date  : 25 September 2018
    	Last Modified By    : Pragalbha Mahajan
    **************************************************************************************************************************************/	
    @AuraEnabled
    public static DatabaseResult getOpportunityData(Id opportunityId){
        try{
            AssignToAccountData objAssignToAccountData = new AssignToAccountData();
            objAssignToAccountData.opportunityRecord = (Opportunity)[SELECT Id, Name, AccountId, Account.Parent_Org_Name__c, Account.OwnerId, Billing_Account__c, Billing_Account__r.UUID__c, Primary_Member__c, Encoded_ID__c, Building_uuid__c, Actual_Start_Date__c, OwnerId, StageName, Contract_Stage__c, RecordType.Name FROM Opportunity WHERE Id =:opportunityId LIMIT 1];
            objAssignToAccountData.opportunityRecord.Encoded_ID__c = EncodingUtil.base64Encode(Blob.valueOf(opportunityId));
            DatabaseResult orgData = LightningComponentController.getOrg(objAssignToAccountData.opportunityRecord.AccountId);
            if(orgData != null && orgData.data != null){
             objAssignToAccountData.ultimateParentOrgId = Id.valueOf((String)JSON.deserialize(JSON.serialize(LightningComponentController.getOrg(objAssignToAccountData.opportunityRecord.AccountId).data), String.class));   
            }
            objAssignToAccountData.billingAccounts = new List<Billing_Account__c>([SELECT Id, OwnerId, ID_Status__c, Owner.Name, Parent_Account__r.Name, Parent_Account__r.Account_Type__c, Parent_Account__c, Name, Primary_Member__c, Primary_Member__r.Name, Primary_Member__r.Email, Primary_Member__r.Id, UUID__c FROM Billing_Account__c WHERE Ultimate_Parent_Org__c =:objAssignToAccountData.ultimateParentOrgId]);
            objAssignToAccountData.apiSetting = [SELECT Id, Name, Data__c FROM Setting__c WHERE Name = 'TourReservableAPI'];
            Boolean isValid = false;
            if(objAssignToAccountData.opportunityRecord.OwnerId == UserInfo.getUserId()){
                isValid = true;  
            }else{
                List<CustomPermission> lstCustomPermissions = [SELECT Id, DeveloperName, (SELECT Id, Parent.Name, Parent.Profile.Name FROM SetupEntityAccessItems WHERE Parent.Profile.Id =: UserInfo.getProfileId()) FROM CustomPermission WHERE DeveloperName = 'Can_Reparent_Billing_Account'];
                if(lstCustomPermissions != null && lstCustomPermissions.size() > 0 && lstCustomPermissions[0].SetupEntityAccessItems != null && lstCustomPermissions[0].SetupEntityAccessItems.size() > 0){
                    isValid = true;
                }
            }
            boolean isStageValid = false;
            if(isValid){
                String oppStageName = String.isBlank(objAssignToAccountData.opportunityRecord.StageName) ? '' : objAssignToAccountData.opportunityRecord.StageName.toLowerCase();
                String oppContractStage = String.isBlank(objAssignToAccountData.opportunityRecord.Contract_Stage__c) ? '' : objAssignToAccountData.opportunityRecord.Contract_Stage__c.toLowerCase();
                Setting__c manageBillingAccountSetting = Settings.get('ManageBillingAccountSetting');
                if(manageBillingAccountSetting != null && manageBillingAccountSetting.Data__c != null){
                    Map<String,object> mapSettingData = (Map<String, Object>) JSON.deserializeUntyped(manageBillingAccountSetting.Data__c.toLowerCase());
                    Map<String, Map<String, Set<String>>> billingAccSetting = (Map<String, Map<String, Set<String>>>) JSON.deserialize(JSON.serialize(mapSettingData.get('associatebillingaccount')),Map<String, Map<String, Set<String>>>.class);
                    if(objAssignToAccountData.opportunityRecord.Billing_Account__c != Null && billingAccSetting.get('withbillingaccount').get('allowedstages').contains(oppStageName) && (billingAccSetting.get('withbillingaccount').get('allowedcontractstages').contains(oppContractStage) || String.isBlank(oppContractStage))){
                        isStageValid = true;
                    } else if(objAssignToAccountData.opportunityRecord.Billing_Account__c == Null && billingAccSetting.get('withoutbillingaccount').get('allowedstages').contains(oppStageName) && (billingAccSetting.get('withoutbillingaccount').get('allowedcontractstages').contains(oppContractStage) || String.isBlank(oppContractStage))){
                        isStageValid = true;
                    }
                }else{
                    return new DatabaseResult(false,'null','Sales Console Setting (ManageBillingAccountSetting) not found.');
                }
            }
            objAssignToAccountData.isValidStage = isStageValid;
            objAssignToAccountData.isValidForAssociation = isValid;
            return new DatabaseResult(JSON.serialize(objAssignToAccountData));
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'opportunityId---'+opportunityId, 'AssociateBillingAccountController', 'getOpportunityData');            
            return (new DatabaseResult(pEx));
        }
    }
    
     /************************************************************************************************************************************
        Author              : Pragalbha Mahajan
        Description         : This method inserts new billing account and Contact or update the exixting ,if exists.
        Created Date        : 20 July 2018 
        Issue No            : 
    **************************************************************************************************************************************/	
     @AuraEnabled
    public static DatabaseResult createNewBillingAccount(Map<String,String> mapNewObject){
        try{ 
            List<Billing_Account__c> lstBillAccounts = [Select Id, UUID__c From Billing_Account__c Where UUID__c =: mapNewObject.get('billingAccountUUID')];
            Debug.log('lstBillAccounts---'+lstBillAccounts);
            if(lstBillAccounts.size()>0){
                return new DatabaseResult(lstBillAccounts[0]);
            }else{
                Billing_Account__c billingAccountRec = (Billing_Account__c)FieldMappingsHelper.getMappings(mapNewObject.get('parentId'), 'FieldMappings:AccountToBillingAccount');
                billingAccountRec.Name = mapNewObject.get('billingAccountName');
                billingAccountRec.UUID__c = mapNewObject.get('billingAccountUUID');                
                billingAccountRec.Parent_Account__c = mapNewObject.get('parentId');
                Contact objContact;
                Opportunity objOpp;
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
                    List<String> lstNames = mapNewObject.get('contactName').split(' ');
                    String strFirstName = '',strLastName = '';
                    if(lstNames.size()>1){
                        strFirstName = lstNames[0];
                        lstNames.remove(0);
                        strLastName = String.join(lstNames,' ');
                    }else{
                        strLastName = String.join(lstNames,' ');
                    }
                    objContact = new Contact(FirstName=strFirstName,LastName=strLastName,Billing_Account__c=billingAccountRec.Id,AccountId=(mapNewObject.containsKey('parentId') && mapNewObject.get('parentId')!= null ? mapNewObject.get('parentId') : null),Email=mapNewObject.get('Email'),Phone=mapNewObject.get('phone'),UUID__c=mapNewObject.get('primaryMemberUUID'));
                    insert objContact;
                    billingAccountRec.Primary_Member__c = objContact.Id;
                    update billingAccountRec;
                }
                if(mapNewObject.get('oppId') != null){
                    objOpp = new Opportunity(Id=mapNewObject.get('oppId'),Billing_Account__c=billingAccountRec.Id);
                    update objOpp;
                }
                billingAccountRec = [SELECT Id, Name, UUID__c FROM Billing_Account__c WHERE Id=:billingAccountRec.Id];
                return new DatabaseResult(billingAccountRec);
            }
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'AssociateBillingAccountController', 'insertNewAccountForSendPaperwork');            
            return (new DatabaseResult(pEx)); 
        }
    } 
    
     /************************************************************************************************************************************
        Author              : Pragalbha Mahajan
        Description         : This method checks is opportunity is valid for SendPaperWork.
        Created Date        : 23 July 2018 
        Issue No            : 
    **************************************************************************************************************************************/	
    @AuraEnabled
    public static DatabaseResult isValidOppforSendPaperwork(Id oppId){
        return new DatabaseResult(SendPaperWorkController.isValidOppforSendPaperwork(oppId));
    }
    
	/**************************************************************************************************************************************************
    Author              : Dipak Pawar
    Description         : This is a Class to hold AssignToAccountData Details.
    Created Date        : 18 July 2018 
    ***************************************************************************************************************************************************/
    public class AssignToAccountData {
        public Opportunity opportunityRecord{get;set;}
        public Id ultimateParentOrgId{get;set;}
        public List<Billing_Account__c> billingAccounts{get;set;}
        public Setting__c apiSetting{get;set;}
        public Boolean isValidForAssociation{get;set;}
        public Boolean isValidStage{get;set;}
    }
}