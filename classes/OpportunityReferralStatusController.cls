/************************************************************************************************************************************
    Author      :  Nikhil Mehta    
    Description :  This class contain all methods related to aura methods in OpportunityReferralStatusController.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR          		DETAIL
     1          1 Nov 2018       	Nikhil Mehta    	    Initial Developement
**************************************************************************************************************************************/
public without sharing  class OpportunityReferralStatusController {
    public class OpportunityReferralStatusControllerException extends Exception{}
    public static Boolean isInvoker = false;
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'OpportunityReferralStatusControllerException' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
     /****************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method is used to getOpprtunityData.
        Created Date        : 29 Oct 2018
		Issue No			: ST-2858
   *****************************************************************************************************************************/  
    @AuraEnabled
    public static DatabaseResult getOpprtunityData(Id opportunityId){
        Map<String, sObject> mapData = new Map<String, sObject>();
        if(opportunityId != null){
           List<Opportunity> lstOpportunities = new List<Opportunity>([Select Id, Referral_Status__c, Contract_Signed_On_Date__c, RecordType.Id, RecordType.Name, Contact_Broker__c, Billing_Account__c, Billing_Account__r.Name, Billing_Account__r.UUID__c, Building__r.Id, Building__r.Name, Building__r.UUID__c, Building__r.Market__r.UUID__c, Primary_Member__r.Id, Primary_Member__r.Name, Primary_Member__r.Email, Referrer__r.Id, Referrer__r.Name, Referrer__r.Email, Referrer__r.Type__c,  Referrer__r.Phone, CreatedDate FROM Opportunity WHERE Id = :opportunityId]);
            Opportunity objOpportunity;
            if(!lstOpportunities.isEmpty()){
                objOpportunity = lstOpportunities[0];
                mapData.put('opp', objOpportunity);
            }
            Setting__c settingRecord = Settings.get('RetroactiveReferralSettings');
            if(settingRecord != null){
               mapData.put('referralSetting', settingRecord);
            }
            settingRecord = Settings.get('ReferenceSettings');
            if(settingRecord != null){
                Map<String, Object> mapReferral = (Map<String, Object>)JSON.deserializeUntyped(settingRecord.Data__c);
                mapData.put('referralRec', new Referral__c(Expires_On__c = System.today().addDays(Integer.valueOf(mapReferral.get('expireafter'))), Start_Date__c = System.today(), Referral_Source__c = 'Retroactive Referral'));
            }
            if(objOpportunity != null && String.isNotEmpty(objOpportunity.Primary_Member__c) && String.isNotEmpty(objOpportunity.Primary_Member__r.Email)){
                List<Referral__c> lstReferrals = [SELECT Id, CreatedDate, Referral_Email__c FROM Referral__c WHERE Referral_Email__c =: objOpportunity.Primary_Member__r.Email ORDER BY CreatedDate];
                if(!lstReferrals.isEmpty()){
                    mapData.put('existingReferral', lstReferrals[0]);
                }
            }
        }
        return new DatabaseResult(mapData);
    }
}