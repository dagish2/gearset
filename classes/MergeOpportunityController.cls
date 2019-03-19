/************************************************************************************************************************************
    Author      :   Prashant Mane
    Description :   This class contain all aura methods related to MergeOpportunities Lightning Component.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           10 Jan 2019         Prashant Mane        	Initial Developement
**************************************************************************************************************************************/
global without sharing class MergeOpportunityController {
    public static Boolean isInvoker = false;
    public static Savepoint sp {get;set;}
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'MergeOpportunityController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    
    @AuraEnabled
    public static DatabaseResult getMergeOpportunitySettings(){
        try{
            MergeOpportunityData objMergeOpportunityData = new MergeOpportunityData();
            objMergeOpportunityData.lstUser = [Select Id,Name,Email,SmallPhotoUrl,Profile.Name,TimeZoneSidKey from User Where Id=:UserInfo.getUserId()];
            objMergeOpportunityData.getMergeOpportunitySetting = Settings.get('OpportunityRelatedObjectSettings');
            return  new DatabaseResult(JSON.serialize(objMergeOpportunityData));   
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'mergeOppIds==>','MergeOpportunityController', 'mergeOpportunities');            
            return (new DatabaseResult(pEx)); 
        }        
    }
    
  /****************************************************************************************************************************
        Author              : Ajaysinh Chauhan
        Description         : This method is used to merge Opportunities.
        Created Date        : -
        Last Modified By    : Ashish Mishra
        Last Modified Date  : 31,May 2018
   *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult mergeOpportunities(string mergeOppIds,string primaryOpprtunity){
        try{
            sp = Database.setSavepoint();
            return  new DatabaseResult(OpportunityHandler.mergeOpprtunities(mergeOppIds, primaryOpprtunity));   
        }catch(Exception pEx){
            LightningComponentController.rollbackTransaction(sp);
            ApexDebugLog.logException(pEx,'mergeOppIds==>'+mergeOppIds+' primaryOpprtunity==>'+primaryOpprtunity, 'MergeOpportunityController', 'mergeOpportunities');            
            return (new DatabaseResult(pEx)); 
        }        
    }
    
    class MergeOpportunityData {
        public List<User> lstUser {get;set;}
        public Setting__c getMergeOpportunitySetting {get;set;}
    }
}