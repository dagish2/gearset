/************************************************************************************************************************************
    Author      :  Nikhil Mehta    
    Description :  This class contain all methods related to aura methods in RetroactiveReferralController.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR          		DETAIL
     1          10 Oct 2018       	Nikhil Mehta    	    Initial Developement
**************************************************************************************************************************************/
global without sharing class RetroactiveReferralController {
    public class RetroactiveReferralControllerException extends Exception{}
    public static Boolean isInvoker = false;
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'RetroactiveReferralController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method Use To check validation for web service.
        Last Modified Date  :   29 oct 2018
		Issue No			:   ST-2858
    **************************************************************************************************************************************/
    webservice static String isValidForWebService(Id opportunityId){
        if(String.isNotBlank(opportunityId)){
            return JSON.serialize(checkValidation(opportunityId, null));
        }
        return JSON.serialize(null);
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method use to test data for checkUpdateReferrer lightning component.
        Last Modified Date  :   29 oct 2018
		Issue No			:   ST-2858
    **************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult initialize(Id opportunityId){
        debug.log('Id opportunity ::'+opportunityId);
        Map<String, Object> mapInitData = new Map<String, Object>();
        Setting__c settingRecord = Settings.get('RetroactiveReferralSettings');
        if(String.isBlank(opportunityId)){
            mapInitData.putAll(checkValidation(null, null));
            mapInitData.put('Setting', settingRecord);
            settingRecord = Settings.get('TourReservableAPI');
            mapInitData.put('apiSetting', settingRecord);
        }else{
            List<Opportunity> lstOpps = [Select Id, Name, Owner.Name, AccountId, Account.Parent_Org__c, StageName, Contract_Stage__c, Referral_Status__c, CloseDate, Contract_Signed_On_Date__c, Building__r.Name, Building__c, Building__r.UUID__c, Referrer__r.Name, Referrer__r.Email, Referrer__r.Phone, Referrer__r.Type__c, Billing_Account__r.Id, Billing_Account__r.UUID__c, Billing_Account__r.Name, Billing_Account__r.Ultimate_Parent_Org__c, Billing_Account__r.Conventional_Name__c, RecordType.Name, Billing_Account__r.Primary_Member__r.UUID__c, Billing_Account__r.Primary_Member__r.Email, Billing_Account__r.Primary_Member__r.Phone, Billing_Account__r.Primary_Member__r.Name, Billing_Account__r.Parent_Account__c, Billing_Account__r.ID_Status__c, Primary_Member__r.Email, Primary_Member__r.Name , Deal_Type__c From Opportunity Where Id =: opportunityId];
            Map<Id, Map<String, String>> mapOpportunityWithResult;
            debug.log('lstOpps: ');
            if(!lstOpps.isEmpty()){
                Opportunity opp = lstOpps[0];
                debug.log('opp: '+opp);
                mapInitData.put('Setting', settingRecord);
                settingRecord = Settings.get('TourReservableAPI');
                mapInitData.put('apiSetting', settingRecord);
                mapInitData.put('OpportunityData', opp);
                mapInitData.put('LoggedInUser', UserInfo.getUserId());
                mapInitData.putAll(checkValidation(null, opp));
            } 
        }
        return new DatabaseResult(JSON.serialize(mapInitData));
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method use to check validation for update referrer.
        Last Modified Date  :   29 oct 2018
		Issue No			:   ST-2858
    **************************************************************************************************************************************/
    @AuraEnabled
    public static Map<String, String> checkValidation(Id opportunityId, Opportunity oppRec){
        Map<String, String> mapResult = new Map<String, String>();
        if(oppRec != null){
            mapResult.putAll(checkValidation(new List<Opportunity>{ oppRec }).get(oppRec.Id));
        }else if(String.isNotBlank(opportunityId)){
            List<Opportunity> lstOpps = [Select Id, Name, StageName, Contract_Stage__c, Referral_Status__c FROM Opportunity WHERE Id =: opportunityId];
            mapResult.putAll(checkValidation(lstOpps).get(opportunityId));
        }else{
            Setting__c settingRecord = Settings.get('RetroactiveReferralSettings');
            Map<String, Object> mapRetroactiveSetting = (Map<String, Object>)JSON.deserializeUntyped(settingRecord.data__c);
            Set<String> setAllowedProfileIds = (Set<String>) JSON.deserialize(JSON.serialize(mapRetroactiveSetting.get('AllowedProfileId')), Set<String>.class);
            Set<String> setAllowedUserIds = (Set<String>) JSON.deserialize(JSON.serialize(mapRetroactiveSetting.get('AllowedUsersId')), Set<String>.class);
            if(checkValidProfile(setAllowedProfileIds) || checkValidUser(setAllowedUserIds)){
                mapResult.putAll(new Map<String, String>{'isValid' => 'true'});
            }else{
                mapResult.putAll(new Map<String, String>{'isValid' => 'false', 'errorMessage' => 'User does not have permission for "Convert To Referral"'});
            }
        }
        if(mapResult.isEmpty()){
            mapResult.put('isValid', 'true');
        }
        return mapResult;
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method use to check validation for update referrer.
        Last Modified Date  :   29 oct 2018
		Issue No			:   ST-2858
    **************************************************************************************************************************************/
    @AuraEnabled
    public static  Map<Id, Map<String, String>> checkValidation(List<Opportunity> lstOpps){
        Boolean isValid = false;
        Map<Id, Map<String, String>> mapOpportunityWithResult = new Map<Id, Map<String, String>>();
        Setting__c retroactiveSetting = Settings.get('RetroactiveReferralSettings');
        Map<String, Object> mapRetroactiveSetting;
        Map<String, Set<String>> mapRestrictCriteria;
        Set<String> setAllowedUserIds;
        Set<String> setAllowedProfileIds;
        if(String.isNotBlank(retroactiveSetting.data__c)){
            mapRetroactiveSetting = (Map<String, Object>)JSON.deserializeUntyped(retroactiveSetting.data__c);
            mapRestrictCriteria = (Map<String, Set<String>>) JSON.deserialize(JSON.serialize(mapRetroactiveSetting.get('RestrictCriteria')).toLowerCase(), Map<String, Set<String>>.class);
            setAllowedUserIds = (Set<String>) JSON.deserialize(JSON.serialize(mapRetroactiveSetting.get('AllowedUsersId')), Set<String>.class);
        	setAllowedProfileIds = (Set<String>) JSON.deserialize(JSON.serialize(mapRetroactiveSetting.get('AllowedProfileId')), Set<String>.class);
         }
        for(Opportunity oppRec : lstOpps){
            mapOpportunityWithResult.put(oppRec.Id, new Map<String, String>{'isValid' => 'true'});
            if(oppRec != null && mapRestrictCriteria != null && setAllowedUserIds != null){
                if(checkValidProfile(setAllowedProfileIds) || checkValidUser(setAllowedUserIds)){
                    if(oppRec != null && mapRestrictCriteria.get('excludereferralstatus') != null && oppRec.Referral_Status__c != null && mapRestrictCriteria.get('excludereferralstatus').contains(oppRec.Referral_Status__c.toLowerCase())){
                        mapOpportunityWithResult.put(oppRec.Id, new Map<String, String>{'isValid' => 'false', 'errorMessage' => 'You can not perform this action as Referral status is already approved'});
                    }else if(oppRec != null && mapRestrictCriteria.get('excludedoppstages') != null && oppRec.StageName != null && mapRestrictCriteria.get('excludedoppstages').contains(oppRec.StageName.toLowerCase())){
                        mapOpportunityWithResult.put(oppRec.Id, new Map<String, String>{'isValid' => 'false', 'errorMessage' => 'You can not perform this action as Opportunity stage is Closed Lost or Closed Won'});
                    }
                }else {
                    mapOpportunityWithResult.put(oppRec.Id, new Map<String, String>{'isValid' => 'false', 'errorMessage' => 'User does not have permission for "Convert To Referral"'});
                }
            }
        }
        return mapOpportunityWithResult;
    }
    public static Boolean checkValidUser(Set<String> setAllowedUserIds){
        if(setAllowedUserIds != null && (setAllowedUserIds.contains(String.valueOf(UserInfo.getUserId())) || setAllowedUserIds.contains(String.valueOf(UserInfo.getUserId()).substring(0,15)))){
            return true;
        }else{
            return false;
        }
    }
    public static Boolean checkValidProfile(Set<String> setAllowedProfileIds){
         if(setAllowedProfileIds != null && (setAllowedProfileIds.contains(String.valueOf(UserInfo.getProfileId())) || setAllowedProfileIds.contains(String.valueOf(UserInfo.getProfileId()).substring(0,15)))){
            return true;
        }else{
            return false;
        }
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method is used to update referrer on opportunity.
        Last Modified Date  :   29 oct 2018
		Issue No			:   ST-2858
    **************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult updateReferrerOnOpportunity(Id opportunityId, Contact referrer, Id billAccId, Id parentAccId, String oppReferralType) {
        try{
            if(opportunityId != null){
                Opportunity oppRec = new Opportunity(Id = opportunityId);
                if(billAccId != null){
                    if(parentAccId != null){
                        oppRec.AccountId = parentAccId;
                    }
                    oppRec.Billing_Account__c = billAccId;
                    List<Billing_Account__c> lstBillAccs = [SELECT Id,Primary_Member__c FROM Billing_Account__c WHERE Id =: billAccId];
                    if(!lstBillAccs.isEmpty() && lstBillAccs[0].Primary_Member__c != null && oppReferralType != null && oppReferralType.equalsIgnoreCase('Confidential Referral')){
                        oppRec.Primary_Member__c = lstBillAccs[0].Primary_Member__c;
                    }
                }
                oppRec.Referrer__c = referrer.Id;
                oppRec.LeadSource = 'Referral';
                if(referrer.Type__c != null){
                    oppRec.Referral_Type__c = referrer.Type__c;
                }
                oppRec.Opportunity_Referral_Type__c = oppReferralType;
                oppRec.Referral_Status__c = 'Pending';
                update oppRec;
                return (new DatabaseResult(oppRec));
            }else{
                throw new RetroactiveReferralControllerException('Opportunity Id is not present');
            }
        }catch(Exception pEx) {
            ApexDebugLog.logException(pEx, 'OpportunityId', 'RetroactiveReferralController', 'updateReferrerOnOpportunity');
            if(pEx.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                pEx.setMessage(pEx.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,'));
            }
            return (new DatabaseResult(pEx));
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method is used to create contact or account from update referrer.
        Last Modified Date  :   25 oct 2018
		Issue No			:   ST-2858
    **************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult saveConAccRecords(List<sObject> lstRecords) {
        Contact objContact;
        Billing_Account__c objBillAccount;
        Boolean updateContact = false;
        for(sObject record : lstRecords){
            switch on record {
                when Contact conRec {
                    objContact = conRec;
                }
                when Billing_Account__c billAccRec {
                    objBillAccount = billAccRec;
                }
            } 
        }
       if(objContact != null){
            if(String.isNotBlank(objContact.Id)){
                if(String.isBlank(objContact.AccountId)){
                    objContact.AccountId = getUltimateOrg(objContact.Id);
                    updateContact = true;
                }
            }else{
                insert objContact;
                objContact.AccountId = getUltimateOrg(objContact.Id);
                updateContact = true;
            }
        }
        if(objBillAccount != null){
            if(String.isNotBlank(objContact.Id)){
                objBillAccount.Primary_Member__c = objContact.Id;
                if(String.isBlank(objBillAccount.Parent_Account__c)){
                    objBillAccount.Ultimate_Parent_Org__c = getUltimateOrg(objContact.Id);
                }
            }
            insert objBillAccount;
            if(String.isBlank(objContact.Billing_Account__c)){
                objContact.Billing_Account__c = objBillAccount.Id;
                updateContact = true;
            }
            if(String.isNotBlank(objContact.UUID__c)){
                updateContact = true;
            }
        }
        if(updateContact){
            update objContact;
        }
        return new DatabaseResult(new Map<String, sObject>{'billAcc' => objBillAccount, 'contact' => objContact});
    }
    /************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method is used to get org from contact.
        Last Modified Date  :   25 Oct 2018
		Issue No			:   ST-2858
    **************************************************************************************************************************************/
    public static Id getUltimateOrg(Id ContactId) {
        List<Contact> lstContact = new List<Contact>([Select Id, FirstName, LastName, Name, Company__c, OwnerId, Email_Domain__c, Account_Name__c, AccountId, Account.Account_Type__c, Email, Unomy_Company_ID__c, Unomy_Company_Name__c, UUID__c, Location__c, Location__r.City__c, LeadSource, Cleansed_Unomy_Company_Name__c, Location_Interested__c, Cleansed_Company_Name__c From Contact Where Id =: ContactId]);
        if(!lstContact.isEmpty()){
            return OrganizationHelper.findOrCreateRelatedOrg(lstContact).get(ContactId);
        }
        return NULL;
    }
}