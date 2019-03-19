/************************************************************************************************************************************
    Author      :   Ashish Mishra
    Description :   Trigger on opportunity ,fire when Referrer__c is not null, Lead Source not equal to Broker Reffral and Check region name
					Accouding to region name send email notification which is assign to that region.(on Insert and on Update).
	Issue No.	:	ST-3276

    History:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           2 Jan 2019    		Ashish Mishra         	Initial Developement
**************************************************************************************************************************************/
public class TrOpportunityEmailAlertForBrokerInvolved implements IProcessHandler{
    
    public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap) {              
        emailAlertForBrokerInvolved((List<Opportunity>)triggerNew, triggerOldMap);
    }
    
    static void emailAlertForBrokerInvolved(List<Opportunity> lstNewOpportunities, Map<Id, sobject> mapOldOpportunities){
        MetadataSetting__mdt brokerInvolvedNotificationMetadata = Settings.getMetadataSetting('BrokerInvolvedNotification');
        
        if(brokerInvolvedNotificationMetadata != null){
            BrokerInvolvedNotificationMetada objBrokerInvolvedNotificationMetadata = (BrokerInvolvedNotificationMetada)JSON.deserialize(brokerInvolvedNotificationMetadata.Data__c, BrokerInvolvedNotificationMetada.class);
            if(objBrokerInvolvedNotificationMetadata != null){
                Map<String, String> mapRegionRelatedEmails = getRegionRelatedEmails(objBrokerInvolvedNotificationMetadata.RegionRelatedEmails);
                Set<String> setExcludedLeadSources = getOpportunityExcludedLeadSources(objBrokerInvolvedNotificationMetadata.ExcludedOpportunityLeadSource);
                
                Map<Id, String> mapOpportunityRelatedEmails = new Map<Id, String>();
                
                if(mapRegionRelatedEmails != null){
                    for(Opportunity newOpportunity : lstNewOpportunities){
                        Opportunity oldOpportunity = mapOldOpportunities != null ? (Opportunity)mapOldOpportunities.get(newOpportunity.Id) : null;
                        Boolean isValidOpportunityForNotification = validateOpportunityForNotification(newOpportunity, oldOpportunity, setExcludedLeadSources, mapRegionRelatedEmails.keySet());
                        if(isValidOpportunityForNotification){
                            mapOpportunityRelatedEmails.put(newOpportunity.Id, mapRegionRelatedEmails.get(newOpportunity.Region_Name__c.toLowerCase()));
                        }
                    }
                    
                    if(mapOpportunityRelatedEmails.size() > 0){
                        String strEmailTemplateName = objBrokerInvolvedNotificationMetadata.EmailTemplateName;
                        sendBrokerInvolvedNotifications(mapOpportunityRelatedEmails, strEmailTemplateName);
                    }
                }
            }
        }
    }
    
    static Boolean validateOpportunityForNotification(Opportunity newOpportunity, Opportunity oldOpportunity, Set<String> setExcludedLeadSources, Set<String> setRegions){
        Boolean isValidOpportunityForNotification = String.isNotBlank(newOpportunity.LeadSource) && String.isNotBlank(newOpportunity.Referrer__c) && newOpportunity.Broker_Involvement_Indicated__c == 'Yes' && !setExcludedLeadSources.contains(newOpportunity.LeadSource.toLowerCase()) && String.isNotBlank(newOpportunity.Region_Name__c) && setRegions.contains(newOpportunity.Region_Name__c.toLowerCase());
        if(isValidOpportunityForNotification && (oldOpportunity == null || ((oldOpportunity != null && newOpportunity.Broker_Involvement_Indicated__c != oldOpportunity.Broker_Involvement_Indicated__c || newOpportunity.Referrer__c != oldOpportunity.Referrer__c)))) { 
            return true;
        }
        return false;
    }
    
    static Map<String, String> getRegionRelatedEmails(Map<String, String> mapMetadataRegionEmails){
        Map<String, String> mapRegionRelatedEmails = new Map<String, String>();
        for(String regionName : mapMetadataRegionEmails.keySet()){
            mapRegionRelatedEmails.put(regionName.toLowerCase(), String.valueOf(mapMetadataRegionEmails.get(regionName)));
        }
        return mapRegionRelatedEmails;
    }
    
    static Set<String> getOpportunityExcludedLeadSources(List<String> lstExcludedOpportunityLeadSources){
        Set<String> setExcludedLeadSources = new Set<String>();
        for(String strLeadSource : lstExcludedOpportunityLeadSources){
            setExcludedLeadSources.add(strLeadSource.toLowerCase());
        }
        return setExcludedLeadSources;
    }
    
    static void sendBrokerInvolvedNotifications(Map<Id, String> mapOpportunityRelatedEmails, String strEmailTemplateName){
        List<Messaging.SingleEmailMessage> lstBrokerInvolvedNotificationEmails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate objEmailTemplate = Settings.getEmailTemplateByDeveloperName(strEmailTemplateName);
        Messaging.SingleEmailMessage objSingleMail;
        for(Id opportunityId : mapOpportunityRelatedEmails.keySet()){
            String strEmailAddress = mapOpportunityRelatedEmails.get(opportunityId);  
            if(String.isNotBlank(strEmailAddress)){
                objSingleMail = new Messaging.SingleEmailMessage();
                objSingleMail.setTemplateID(objEmailTemplate.Id); 
                objSingleMail.setTargetObjectId(UserInfo.getUserId());
                objSingleMail.setWhatId(opportunityId);
                objSingleMail.setSenderDisplayName('WeWork');
                objSingleMail.setTreatTargetObjectAsRecipient(false);
                objSingleMail.setSaveAsActivity(false);
                objSingleMail.setToAddresses(new List<String>{strEmailAddress});
                
                lstBrokerInvolvedNotificationEmails.add(objSingleMail);   
            }
        }
        
        if(lstBrokerInvolvedNotificationEmails.size() > 0){
            Messaging.sendEmail(lstBrokerInvolvedNotificationEmails, false);
        }
    }
    
    class BrokerInvolvedNotificationMetada {
		public List<String> ExcludedOpportunityLeadSource;
		public Map<String, String> RegionRelatedEmails;
		public String EmailTemplateName;
	}
}