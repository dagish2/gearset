/************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   This class contain all aura methods related to TransferPaperwork.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           10 Jan 2019         Prashant Mane        	Initial Developement
**************************************************************************************************************************************/
global without sharing class TransferPaperWorkController {
    
    public static Boolean isInvoker = false;
    public static Savepoint sp {get;set;}
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'TransferPaperWorkController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
        
    }
    
    /************************************************************************************************************************************
        Author              : Prashant Mane
        Description         : This method is used to validate the opportunity for Transfer Paperwork functionality for Community View Page. 
        Created Date        : 2-June-2018
        Issue No.           : CSI-838
        -------------------------------------------------------------------------------------------------------------------------------------
        Last Modified by	: Milanjeet Singh
        Description			: Updated the logic to validate the opportunity according to the new Billing Account Object Structure
        Issue No.			: ST-2547
    *************************************************************************************************************************************/
    webservice static string isValidOppforTransferPaperwork(Id oppId) { 
        String[] oppStages,oppContactStages;
        Set<String> setOfOppStages = new Set<string>();       
        set<String> setOfContractStages = new set<String>();
        ValidResultWithOpp validResult = new ValidResultWithOpp();
        try{
            Setting__c transferPaperWorkSetting = new Setting__c();
            transferPaperWorkSetting = Settings.get('TransferPaperwork'); 
            debug.log('TransferPaperworkSetting'+transferPaperWorkSetting);
            
            TransferPaperwork settingData = new TransferPaperwork();
            settingData = (TransferPaperwork)JSON.deserialize(transferPaperWorkSetting.Data__c.toLowerCase(), TransferPaperwork.class);
            debug.Log('settingData'+settingData);
            
            oppStages = settingData.allowedStages;
            oppContactStages = settingData.allowedContractStages;
            setOfOppStages.addAll(oppStages);
            setOfContractStages.addAll(oppContactStages);
            validResult.settingData = (settingData.url!=null && settingData.url.size()>0)?JSON.serialize(settingData.url):'[]';
            
            List<Opportunity> lstOpportunities = [SELECT Id,AccountId,Type__c,Billing_Account__r.UUID__c,Billing_Account__c,Account.OwnerId,Account.Account_Type__c,recordTypeID,StageName,Contract_Stage__c,Encoded_ID__c,Building_uuid__c,Actual_Start_Date__c,OwnerId,Locations_Interested__c,Building__c,Primary_Member__c from Opportunity WHERE Id =: oppId Limit 1];
            debug.log('lstOpportunities:::'+lstOpportunities);
            if((!setOfOppStages.contains(lstOpportunities[0].StageName != null ? lstOpportunities[0].StageName.toLowerCase() : null ))){
                debug.log('Inside Validation');
                validResult.isValid = false;
                validResult.objOpportunity = null;
                validResult.errorMsg ='You are not allowed to transfer this paperwork. Please check the Opportunity Stage.';
            }else if((!setOfContractStages.contains(lstOpportunities[0].Contract_Stage__c != null ? lstOpportunities[0].Contract_Stage__c.toLowerCase() : null ))){
                debug.log('setOfContractStages..++'+setOfContractStages);
                debug.log('Inside Validation');
                validResult.isValid = false;
                validResult.objOpportunity = null;
                validResult.errorMsg ='You are not allowed to transfer this paperwork. Please check the Contract Stage.';
                debug.log('in else Called ===>>'+validResult);
            }else if(lstOpportunities[0].Billing_Account__c !=null && String.isBlank(lstOpportunities[0].Billing_Account__r.UUID__c)){
                validResult.isValid = false;
                validResult.objOpportunity = null;
                validResult.errorMsg ='You are not allowed to transfer this paperwork as uuid is not present on Opportunity\'s Billing Account.';
            }else {
                validResult.isValid = true;
                validResult.objOpportunity = lstOpportunities.get(0);
            }
            Debug.log('Valid Result ===>>'+validResult);
            return JSON.serialize(validResult);
        } catch(Exception ex){
            Debug.log('Transfer Paperwork Exception'+ex.getMessage());
            return null;
        }
    } 
    
    /************************************************************************************************************************************
        Author              : Rohit Nimase
        Description         : This method is used to validate the opportunity for Transfer Paperwork functionality.  
        Created Date        : 23-Jan-2019
        Issue No.           : CSI-1571
    *************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult  isValidOpportunityforTransferPaperwork(Id oppId) {
        return new DatabaseResult(TransferPaperworkController.isValidOppforTransferPaperwork(oppId));
    }  
    
    global class ValidResultWithOpp{
        global Boolean isValid {get;set;}
        global Boolean isBillingAccountError {get;set;}
        global Boolean isValidOwner {get;set;}
        global string errorMsg {get;set;}
        global Opportunity objOpportunity {get;set;}
        global List<String> opportunityBuildings {get;set;}
        global string settingData {get;set;}
    }
    
    global class TransferPaperwork{
        global String[] allowedStages;
        global String[] allowedContractStages;
        global String[] url;
    }
}