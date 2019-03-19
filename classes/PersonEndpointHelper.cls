/************************************************************************************************************************************
    Author      :   Ajaysinh Chauhan    
    Description :   This class contain a logic of Person Endpoint.....
    
    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           19 June 2018        Ajaysinh Chauhan        Initial Developement
    2           22 June 2018        Krishana Tupe           Changes and API Versioning
  	3           31 July 2018        Krishana Tupe           Implementation of Person endpoint version 4
**************************************************************************************************************************************/
public class PersonEndpointHelper {
    public static Id personContactId;
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method has business logic of person endpoint.
        Created Date        :   31 July 2018 
   **************************************************************************************************************************************/    
    public static Map<String,String> managePerson(RESTAPIPersonModelsV2.Input body){        
        Debug.log('body==>'+body);
         Contact contactRecord = new Contact();
        if(String.isNotBlank(body.email)){                      
            String query = 'Select Id,Name,Billing_Account__c,Unomy_Company_Name__c,Billing_Account__r.Parent_Account__c,Account.Parent_Org_Id__c,Account_Name__c,Billing_Account__r.Ultimate_Parent_Org__c,Billing_Account__r.UUID__c,AccountId,Account.Name,Account.Account_Type__c,UUID__c,Email,Email_Domain__c,Company__c,Cleansed_Company_Name__c,Unomy_Company_Id__c,Cleansed_Unomy_Company_Name__c,FirstName,LastName,Phone,Type__c,LeadSource,Lead_Source_Detail__c,utm_campaign_id__c,utm_campaign__c,utm_content__c,utm_medium__c,utm_source__c,utm_term__c,Locale__c,Country_Code__c From Contact Where Email=\''+body.email+'\'';   
            List<Contact> lstPersonContacts = (List<Contact>)Database.query(query);
            Debug.log('lstPersonContacts==>'+lstPersonContacts);
            Contact objPersonContact;
            if(lstPersonContacts.size()>0){
                objPersonContact = lstPersonContacts[0];
                if(String.isBlank(objPersonContact.AccountId)){
                    if(String.isNotBlank(body.type) && body.type.equalsIgnoreCase('broker')){
                    	personContactId = objPersonContact.Id;    
                    }                    
                    objPersonContact.AccountId = OrganizationHelper.findOrCreateRelatedOrg(objPersonContact);
                    update objPersonContact;
                }
                if(String.isNotBlank(objPersonContact.Billing_Account__c)){
                    if(String.isBlank(objPersonContact.Billing_Account__r.Parent_Account__c)){
                        Billing_Account__c objBillingAccount = new Billing_Account__c(); 
                        objBillingAccount.Parent_Account__c = objPersonContact.AccountId; 
                        objBillingAccount.Id = objPersonContact.Billing_Account__c;
                        update objBillingAccount;
                    }
                    contactRecord = fillContactByPerson(body,objPersonContact);
                    contactRecord.Id = objPersonContact.Id;
                    update contactRecord;                             
                }else{
                    contactRecord.Id = createPersonStructure(body,objPersonContact);
                    contactRecord = fillContactByPerson(body,objPersonContact);
                    update contactRecord;
                }               
            }else{               
                contactRecord.Id = createPersonStructure(body,null); 
            }            
        }else{
            throw new RESTAPIPersonV2.PersonEndpointException('Email is required.');   
        } 
        if(String.isNotBlank(contactRecord.Id)){
            Contact conRecord = [Select Id,Name,AccountId,Billing_Account__c,UUID__c FROM Contact Where Id=:contactRecord.Id];
            return new Map<String, String>{'contact_sfid'=>conRecord.Id,'account_sfid'=> conRecord.AccountId,'billing_account_sfid'=> conRecord.Billing_Account__c,'contact_uuid'=> conRecord.UUID__c};  
                }
        return null;
    }
    /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to create new contact for personn endpoint with billing account.
        Created Date        :   31 July 2018 
   **************************************************************************************************************************************/ 
    public static Id createPersonStructure(RESTAPIPersonModelsV2.Input body,Contact objContact){
        Contact contactRecord;
        if(objContact==null){
            contactRecord = getContactByPerson(body);
            insert contactRecord; 
            String query = 'Select Id,Name,Billing_Account__c,Unomy_Company_Name__c,Billing_Account__r.Parent_Account__c,Account.Parent_Org_Id__c,Account_Name__c,Billing_Account__r.Ultimate_Parent_Org__c,Billing_Account__r.UUID__c,AccountId,Account.Name,Account.Account_Type__c,UUID__c,Email,Email_Domain__c,Company__c,Cleansed_Company_Name__c,Unomy_Company_Id__c,Cleansed_Unomy_Company_Name__c,FirstName,LastName,Phone,Type__c,LeadSource,Lead_Source_Detail__c,utm_campaign_id__c,utm_campaign__c,utm_content__c,utm_medium__c,utm_source__c,utm_term__c,Locale__c,Country_Code__c From Contact Where Id=\''+contactRecord.Id+'\'';   
            List<Contact> lstPersonContacts = (List<Contact>)Database.query(query);
            Debug.log('When new Contact is Created lstPersonContacts==>'+lstPersonContacts);
            if(String.isNotBlank(body.type) && body.type.equalsIgnoreCase('broker')){
                personContactId = contactRecord.Id;
            }
            contactRecord.AccountId = OrganizationHelper.findOrCreateRelatedOrg(lstPersonContacts[0]);
        }else{
            contactRecord = fillContactByPerson(body, objContact);
            contactRecord = objContact;
        } 
        DEbug.log('createPersonStructure contactRecord Before update==>'+contactRecord);
        update contactRecord;
        return contactRecord.Id;        
    }    
   
   /************************************************************************************************************************************
        Author              :   Ajaysinh Chauhan
        Description         :   This method returns the contact object from person endpoint payload.
        Created Date        :   19 June 2018    
   **************************************************************************************************************************************/ 
    public static Contact getContactByPerson(RESTAPIPersonModelsV2.Input body){
        Contact objContact = new contact();
        objContact.Email = body.email;
        objContact.Company__c = (String.isNotBlank(body.company_name)) ? body.company_name : (body.first_name+' '+body.last_name);
        objContact.FirstName = body.first_name;
        objContact.LastName = body.last_name;
        objContact.Phone = body.phone;
        objContact.Type__c = body.type;
        objContact.LeadSource = body.lead_source;
        objContact.Lead_Source_Detail__c = body.lead_source_detail;
        objContact.utm_campaign_id__c = body.utm_campaign_id;    
        objContact.utm_campaign__c = body.utm_campaign;
        objContact.utm_content__c = body.utm_content;
        objContact.utm_medium__c = body.utm_medium;
        objContact.utm_source__c = body.utm_source;
        objContact.utm_term__c = body.utm_term;
        objContact.Locale__c = body.locale;
        objContact.Country_Code__c = body.country_code;
        objContact.Market__c = body.market;
        if(String.isNotBlank(body.marketing_consent)){
            objContact.Marketing_Consent__c = Boolean.valueOf(body.marketing_consent);
        }
        if(String.isNotBlank(body.email_opt_out)){
            objContact.HasOptedOutOfEmail = Boolean.valueOf(body.email_opt_out);
        }
        return objContact;
    }
    
    /************************************************************************************************************************************
        Author              :   Ajaysinh Chauhan
        Description         :   This method fills the contact information from person endpoint payload.
        Created Date        :   19 June 2018    
    **************************************************************************************************************************************/ 
    public static Contact fillContactByPerson(RESTAPIPersonModelsV2.Input body,Contact objContact){
        if(objContact.Email==null)
            objContact.Email = body.email;
        if(objContact.FirstName==null)
            objContact.FirstName = body.first_name;
        if(objContact.LastName==null)
            objContact.LastName = body.last_name;
        if(objContact.Phone==null)
            objContact.Phone = body.phone;
        if(objContact.Type__c==null)
            objContact.Type__c = body.type;       
        if(objContact.LeadSource==null)
            objContact.LeadSource = body.lead_source;
        if(objContact.Lead_Source_Detail__c==null)
            objContact.Lead_Source_Detail__c = body.lead_source_detail;
        if(objContact.utm_campaign_id__c==null)
            objContact.utm_campaign_id__c = body.utm_campaign_id;
        if(objContact.utm_campaign__c==null)
            objContact.utm_campaign__c = body.utm_campaign;
        if(objContact.utm_content__c==null)
            objContact.utm_content__c = body.utm_content;
        if(objContact.utm_medium__c==null)
            objContact.utm_medium__c = body.utm_medium;
        if(objContact.utm_source__c==null)
            objContact.utm_source__c = body.utm_source;
        if(objContact.utm_term__c==null)
            objContact.utm_term__c = body.utm_term;
        if(objContact.Locale__c==null)
            objContact.Locale__c = body.locale;
        if(objContact.Country_Code__c==null)
            objContact.Country_Code__c = body.country_code;
        if(String.isNotBlank(body.market))
            objContact.Market__c = body.market;
        if(String.isNotBlank(body.marketing_consent))
            objContact.Marketing_Consent__c = Boolean.valueOf(body.marketing_consent);
        if(String.isNotBlank(body.email_opt_out))
            objContact.HasOptedOutOfEmail = Boolean.valueOf(body.email_opt_out);
        return objContact;
    }
}