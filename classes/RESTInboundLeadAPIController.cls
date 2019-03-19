/************************************************************************************************************************************
	Author 		: 	Pranay Jadhav
	Description : 	This class having logic to handle the Lead via SFDC's REST API

	History     :	
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			8 June 2018			Pranay Jadhav		  -
**************************************************************************************************************************************/
public class RESTInboundLeadAPIController {
    private static WWTypes.InboundLead pInboundLead {get; set;}
    private Messaging.InboundEmail pEmail {get; set;}
    private Messaging.InboundEnvelope pEnv {get; set;}
    private Lead pLead {get; set;}
    private Contact pContact {get; set;}
    
    public RESTInboundLeadAPIController(WWTypes.InboundLead inboundLead){
        pInboundLead = inboundLead;
    }
    
    public RESTInboundLeadAPIController(Messaging.InboundEmail email, Messaging.InboundEnvelope env){
		pEmail = email;   
        pEnv = env;
    }
    
    /************************************************************************************************************************************
        Author 		: 	Pranay Jadhav
        Description : 	This method handle inbound email request and insert lead if it satisfies all criteria.
        
        History:
        ----------------------------------------------------------------------------------------------------------------------------------
        VERSION		DATE				AUTHOR					DETAIL
        1			8 June 2018			Pranay Jadhav		    -
    **************************************************************************************************************************************/
    public set<Id> handleInboundEmailRequest(){
        set<String> emailIds = new set<String>();
        if(pEmail.toAddresses != null && pEmail.toAddresses.size() > 0)
            emailIds.addAll(pEmail.toAddresses);
        for(String emailId : emailIds){
            if(emailId.endsWith('apex.salesforce.com') || emailId.endsWith('apex.sandbox.salesforce.com'))
                emailIds.remove(emailId);
        }
        if(pEmail.ccAddresses != null && pEmail.ccAddresses.size() > 0)
            emailIds.addAll(pEmail.ccAddresses);
        Debug.log('handleInboundEmailRequest emailIds=>'+emailIds);
        if(emailIds.size() > 0){
            return new RESTInboundLeadAPIHelper().insertLeadByEmail(emailIds, pEmail, pEnv);
        }  
        return null;
    }
    
    /************************************************************************************************************************************
        Author 		: 	Pranay Jadhav
        Description : 	This method handles post request coming from rest api.
        
        History:
        ----------------------------------------------------------------------------------------------------------------------------------
        VERSION		DATE				AUTHOR					DETAIL
        1			8 June 2018			Pranay Jadhav		    -
    **************************************************************************************************************************************/
    public Id handlePostRequest(){
        if(pInboundLead != null && String.isNotBlank(pInboundLead.email)){
            pLead = RESTInboundLeadAPIHelper.getRecentLeadByEmail(pInboundLead.email);
            Debug.log('pLead=='+pLead);
            pContact = RESTInboundLeadAPIHelper.getRecentContactByEmail(pInboundLead.email);
        }          
        if( String.isNotBlank(pInboundLead.referrer_sfid)){
            if(this.validateReferrer()){
                return new RESTInboundLeadAPIHelper().insertLeadByWeb(pInboundLead);
            }
        }else {
            return new RESTInboundLeadAPIHelper().insertLeadByWeb(pInboundLead);
        }
        return null;
    }
    
    /************************************************************************************************************************************
        Author 		: 	Pranay Jadhav
        Description : 	This method responsible to validate lead as per business requirements.
        
        History:
        ----------------------------------------------------------------------------------------------------------------------------------
        VERSION		DATE				AUTHOR					DETAIL
        1			8 June 2018			Pranay Jadhav		    -
    **************************************************************************************************************************************/
    private boolean validateReferrer(){
        Debug.log('pLead validateReferrer==='+pLead);
        Id referrerId = Id.valueOf(pInboundLead.referrer_sfid);
        if(pLead != null){
            Date createdDate = Date.newinstance(pLead.CreatedDate.year(), pLead.CreatedDate.month(), pLead.CreatedDate.day());
            if(createdDate.daysBetween(System.today()) <= 60)
                throw new InboundLeadException('A lead with given email was already submitted in last 60 days');
            else {
                pLead.Referrer__c = referrerId;
                pLead.Contact_Broker__c = pInboundLead.contact_referrer_only;
            }
        }
        if(pContact != null){
            if(pContact.Account.Type == 'Member' || pContact.Account.Type == 'Previous Member')
                throw new InboundLeadException('A member with given email already exists');
            
            for(Opportunity objOpportunity : pContact.Opportunities__r){
                Integer contractSentDateDiff, contractSignedDateDiff;
                if(objOpportunity.Contract_Sent_Date__c != null)
                    contractSentDateDiff = objOpportunity.Contract_Sent_Date__c.daysBetween(System.today());
                if(objOpportunity.StageName == 'Closed Won')
                    contractSignedDateDiff = objOpportunity.CloseDate.daysBetween(System.today());
                if(contractSentDateDiff < 60 || contractSignedDateDiff < 60){
                    throw new InboundLeadException('Person has a contract sent/signed in last 60 days');
                }
            }
            
            for(Tour_Outcome__c objTour : pContact.Tours3__r){
                Integer dayesBetweenTourCreatedAndToday = Date.newInstance(objTour.CreatedDate.year(), objTour.CreatedDate.month(), objTour.CreatedDate.day()).daysBetween(System.today());
                if(dayesBetweenTourCreatedAndToday <= 60){
                    throw new InboundLeadException('Person has booked a tour with us in last 60 days');
                }
            }
        }
        if(pInboundLead.email != null){
            if(ReferenceHandler.getActiveReference(pInboundLead.email) == null){
                List<Contact> lstReferrerContact = [SELECT Id, Type__c FROM Contact WHERE Id =: referrerId];
                Setting__c referenceSettingsObject = Settings.get('ReferenceSettings');
                if(referenceSettingsObject != null) {                     
                    ReferenceSettings refferenceSettingData = (ReferenceSettings)JSON.deserialize(referenceSettingsObject.Data__c, ReferenceSettings.class);
                    Referral__c referral = new Referral__c();
                    referral.Referral_Email__c = pInboundLead.email;
                    referral.Expires_On__c = System.today().addDays(refferenceSettingData.expireafter);
                    if(pInboundLead.lead_source_detail != null && pInboundLead.lead_source_detail == refferenceSettingData.ReferralSource.LeadSourceDetail) {
                        referral.Referral_Source__c = pInboundLead.lead_source_detail;  
                    } else if(pInboundLead.lead_source != null && pInboundLead.lead_source == refferenceSettingData.ReferralSource.LeadSource) {
                        referral.Referral_Source__c = pInboundLead.lead_source;
                    }
                    else {
                        referral.Referral_Source__c = refferenceSettingData.ReferralSource.Other;
                    }
                    if(lstReferrerContact != null && !lstReferrerContact.isEmpty())
                        referral.Referrer_Type__c = lstReferrerContact[0].Type__c;
                    referral.Referrer__c = referrerId;
                    referral.Start_Date__c = System.today();
                    insert referral;
                }   
            }
        }
        return true;
    }
   
    private class ReferenceSettings {
        private Integer expireafter {get; set;}
        private ReferralSource referralSource {get; set;}    
    }
    private class ReferralSource {
        private String LeadSourceDetail {get; set;}
        private String LeadSource {get; set;}
        private String Other {get; set;}
    }
    public class InboundLeadException extends Exception {}
}