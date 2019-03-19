/**
*Modified By: Dipak Pawar
*Modified Date: 20 July 2016
*/
public class ContactHandler {
    public Contact existingContact {get;set;}
    public List<Lead> existingLeads {get;set;}
    public List<string> lstLeadEmails {get;set;}
    public Account existingAccount {get;set;}
    public LeadConvertor.ContactResult[]  contactResult; 
    public static LeadConvertor.ContactResult[]  contactResult1;
    
    public ContactHandler(WWTypes.Person pContact){
    	list<Contact> lstExistingContact = new list<contact>();
    	list<Account> lstExistingAccount = new list<Account>();
        if(pContact.email != null || pContact.contact_uuid != null || pContact.contact_sfid != null) {
        	if(lstExistingContact != null && pContact.contact_sfid != null) {
        		lstExistingContact = [SELECT Id, Company__c, FirstName, LastName, Phone, Type__c, UUID__c, LeadSource, Lead_Source_Detail__c, utm_campaign_id__c, utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c, Locale__c, Country_Code__c, AccountId, Account_UUID__c, Email FROM Contact
 WHERE Id =: pContact.contact_sfid];        		                   
        	}
        	if(pContact.contact_uuid != null && (lstExistingContact != null && lstExistingContact.size() == 0)) {
        		lstExistingContact = [SELECT Id, Company__c, FirstName, LastName, Phone, Type__c, UUID__c, LeadSource, Lead_Source_Detail__c, utm_campaign_id__c, utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c, Locale__c, Country_Code__c, AccountId, Account_UUID__c, Email FROM Contact
 WHERE UUID__c =: pContact.contact_uuid];
 				if(pContact.email != null && lstExistingContact.size() > 0 && lstExistingContact[0].Email != pContact.email) {
	            			throw new RESTContact.applicationException('Contact UUID is associated with different contact in Salesforce.');
							return;
	            		}         		                   
        	}        	    	        	
        	if(pContact.email != null && (lstExistingContact != null && lstExistingContact.size() == 0)) {
                if(pContact.email == '') {
                    throw new RESTContact.applicationException('Email field is required');
					return;
                }	
                lstExistingContact = [SELECT Id, Company__c, FirstName, LastName, Phone, Type__c, UUID__c, LeadSource, Lead_Source_Detail__c, utm_campaign_id__c, utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c, Locale__c, Country_Code__c, AccountId, Account_UUID__c, Email FROM Contact
 WHERE Email=:pContact.email];
        	}
        	if(lstExistingContact != null && lstExistingContact.size() > 0) {
                this.existingContact = lstExistingContact[0];
        	}
        	if(this.existingContact != null) {//.Id
        		if((pContact.account_uuid != null) && ((this.existingContact).Account_UUID__c != pContact.account_uuid)){
        			throw new RESTContact.applicationException('Contact is Primary Member on different Account');
					return;
				}
                this.existingContact = updateContact(this.existingContact, pContact);
                this.existingLeads = [SELECT Email FROM Lead WHERE Email=:this.existingContact.Email];
                if(this.existingLeads != null && this.existingLeads.size() > 0){//this.existingLeads.size() > 0 changes made by amol
                    this.lstLeadEmails = new list<string>();
                	for(Lead currentLead : this.existingLeads)
                		this.lstLeadEmails.add(currentLead.Email);
                    contactResult = LeadConvertor.ConvertLeadsToContact(lstLeadEmails);//ConvertLeadsToContact(lstLeadEmails);
                }
            }
            else {
	            	if(this.existingAccount == null && pContact.account_uuid != null){
	            		//ST-1156
  						//Changes made by Amol Darekar to get UUID from Merge Account Object records call to method WeworkEngine.getMasterAccountUUID().
	            		String masterAccountUUID = WeworkEngine.getMasterAccountUUID(pContact.account_uuid);
                        String useAccUUID = null;
                        if(masterAccountUUID == null)
                            useAccUUID = pContact.account_uuid;
                        else
                            useAccUUID = masterAccountUUID;
                        lstExistingAccount = [SELECT Id, Name, UUID__c FROM Account WHERE UUID__c =: WeworkEngine.getMasterAccountUUID(pContact.account_uuid)];
	            	}	            	
	            	if((lstExistingAccount != null && lstExistingAccount.size() > 0)) {
	            		if((lstExistingAccount[0].Name != pContact.company_name) || String.isBlank(pContact.company_name)) {
	            			throw new RESTContact.applicationException('Account UUID is associated with different account in Salesforce.');
							return;
	            		} 
	            		else {
	            			this.existingAccount = lstExistingAccount[0];
	            		}	            		
	            	}
            		else{
            			this.existingAccount = createAccount(pContact);	
            		}            	
                this.existingContact = createContact(pContact, this.existingAccount);
           }
        } 
        
        RESTContact.contactUUID = this.existingContact.UUID__c;
        RESTContact.contactSFID = this.existingContact.Id;
    }
	/*
	Comment   : This method used for update existing contact with given payload.
   	Author    : Dipak Pawar 
   	Date      : 20 July 2016 
	*/
	private static Contact updateContact(Contact contact, WWTypes.Person pContact){
        Contact newContact = contact;
        newContact.Company__c = (!String.isBlank(pContact.company_name)) ? pContact.company_name : pContact.first_name+' '+pContact.last_name;
    	newContact.FirstName = (!String.isBlank(pContact.first_name)) ? pContact.first_name : newContact.FirstName;
        newContact.LastName = (!String.isBlank(pContact.last_name)) ? pContact.last_name : newContact.LastName;
        newContact.Phone = (!String.isBlank(pContact.phone)) ? pContact.phone : newContact.Phone;
        newContact.Type__c = (!String.isBlank(pContact.type)) ? pContact.type : newContact.Type__c;
        newContact.UUID__c = (!String.isBlank(pContact.contact_uuid) && checkUUID(pContact.contact_uuid)) ? pContact.contact_uuid : newContact.UUID__c;
        newContact.LeadSource = (!String.isBlank(pContact.lead_source)) ? pContact.lead_source : newContact.LeadSource;
        newContact.Lead_Source_Detail__c = (!String.isBlank(pContact.lead_source_detail)) ? pContact.lead_source_detail : newContact.Lead_Source_Detail__c;
        newContact.utm_campaign_id__c = (!String.isBlank(pContact.utm_campaign_id)) ? pContact.utm_campaign_id : newContact.utm_campaign_id__c;
    	newContact.utm_campaign__c = (!String.isBlank(pContact.utm_campaign)) ? pContact.utm_campaign : newContact.utm_campaign__c;
    	newContact.utm_content__c = (!String.isBlank(pContact.utm_content)) ? pContact.utm_content : newContact.utm_content__c;
    	newContact.utm_medium__c = (!String.isBlank(pContact.utm_medium)) ? pContact.utm_medium : newContact.utm_medium__c;
    	newContact.utm_source__c = (!String.isBlank(pContact.utm_source)) ? pContact.utm_source : newContact.utm_source__c;
    	newContact.utm_term__c = (!String.isBlank(pContact.utm_term)) ? pContact.utm_term : newContact.utm_term__c;
    	newContact.Locale__c = (!String.isBlank(pContact.locale)) ? pContact.locale : newContact.Locale__c;
    	newContact.Country_Code__c = (!String.isBlank(pContact.country_code)) ? pContact.country_code : newContact.Country_Code__c;
    	
    	update newContact;
		Contact updatedContact = [SELECT Id, Company__c, FirstName, LastName, Phone, Type__c, UUID__c, LeadSource, Lead_Source_Detail__c, utm_campaign_id__c, utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c, Locale__c, Country_Code__c, AccountId, Account_UUID__c, Email FROM Contact
 WHERE Id =:newContact.Id limit 1];
        return updatedContact;
    }
    
	/*
	Comment   : This method used for create new Account with given payload.
   	Author    : Dipak Pawar 
   	Date      : 29 June 2016 
	*/
	private static Account createAccount(WWTypes.Person pContact){
		Account newAccount = new Account();
		newAccount.UUID__c = (!String.isBlank(pContact.account_uuid) && checkUUID(pContact.account_uuid)) ? pContact.account_uuid : '';
		newAccount.Name = (!String.isBlank(pContact.company_name)) ? pContact.company_name : pContact.first_name+' '+pContact.last_name;
    	newAccount.CurrencyIsoCode = 'USD';
        newAccount.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        insert newAccount;
    	return newAccount;
	}
	
	/*
	Comment   : This method used for create new Contact with given payload.
   	Author    : Dipak Pawar 
   	Date      : 29 June 2016 
	*/
	private static Contact createContact(WWTypes.Person pContact, Account account){
        Contact newContact = new Contact();
        newContact.Email = (!String.isBlank(pContact.email)) ? pContact.email : '';
        newContact.Company__c = (!String.isBlank(pContact.company_name)) ? pContact.company_name : (pContact.first_name+' '+pContact.last_name);
    	newContact.AccountId = account.Id;
        newContact.FirstName = pContact.first_name;
        newContact.LastName = pContact.last_name;
        newContact.Phone = pContact.phone;
        newContact.Type__c = pContact.type;
        newContact.UUID__c = (!String.isBlank(pContact.contact_uuid) && checkUUID(pContact.contact_uuid)) ? pContact.contact_uuid : '';
        newContact.LeadSource = pContact.lead_source;
        newContact.Lead_Source_Detail__c = pContact.lead_source_detail;
        newContact.utm_campaign_id__c = pContact.utm_campaign_id;
    	newContact.utm_campaign__c = pContact.utm_campaign;
    	newContact.utm_content__c = pContact.utm_content;
    	newContact.utm_medium__c = pContact.utm_medium;
    	newContact.utm_source__c = pContact.utm_source;
    	newContact.utm_term__c = pContact.utm_term;
    	newContact.Locale__c = pContact.locale;
    	newContact.Country_Code__c = pContact.country_code;
		insert newContact;
		Contact contact = [SELECT Id, Company__c, FirstName, LastName, Phone, Type__c, UUID__c, LeadSource, Lead_Source_Detail__c, utm_campaign_id__c, utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c, Locale__c, Country_Code__c, AccountId, Account_UUID__c, Email FROM Contact
 WHERE Id=:newContact.Id limit 1];
 		return contact;
    }
    /*
	Comment   : This method will accept UUID. Check that UUID is in valid format, 
				if yes then return true, if no then return false.
   	Author    : Dipak Pawar 
   	Date      : 18 July 2016 
	*/
    public static Boolean checkUUID(String uuid) {
    	Pattern MyPattern = Pattern.compile('[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}');
		Matcher MyMatcher = MyPattern.matcher(uuid);
		Boolean result = MyMatcher.matches();
        return result;
    } 
    
    /*
	Comment   : This method will accept email id. Check that any contact having that email id, 
				if yes then call to ConvetLead, if no then serach in Lead with email Id create new contact.
   	Author    : Mayuresh Ghodke 
   	Date      : 06 July 2016 
	*/
	public static void checkContact(String emailId){
        List<Contact> lstContact = new List<Contact>([Select Id From Contact Where Email = : emailId]);
        list<string> lstEmails = new list<string>();
    	lstEmails.add(emailId);
    	Debug.Log('lstContact :'+lstContact);
        if(lstContact !=null && !lstContact.isEmpty()){
        	contactResult1 = LeadConvertor.ConvertLeadsToContact(lstEmails);
        }
        else {
        	List<Lead> lstLead = new List<Lead>([Select Id,FirstName,LastName,Phone,MobilePhone,LeadSource,Address From Lead Where Email = : emailId Limit 1]);
        	if(lstLead !=null && !lstLead.isEmpty()){
        		Contact newContact = new Contact();
        		newContact.FirstName = lstLead[0].FirstName;
        		newContact.LastName = lstLead[0].LastName;
        		newContact.Phone = lstLead[0].Phone;
        		newContact.MobilePhone = lstLead[0].MobilePhone;
        		newContact.LeadSource = lstLead[0].LeadSource;
        		newContact.Email = emailId;
        		
        		insert newContact;
        	}
        }
        
    }
	
}