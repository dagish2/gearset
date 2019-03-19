/************************************************************************************************************************************
	Author 		: Mayuresh Ghodke
	Description : This class will contain the business logic of ContactTrigger

	History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION			DATE				AUTHOR					DETAIL							ISSUE
	1				27 June 2016		Mayuresh Ghodke			Initial Developement			ST-420
**************************************************************************************************************************************/
public with sharing class ContactTriggerHandler extends ITriggerHandler{
    /************************************************************************************************************************************
       Author 			: Krishana Tupe
       Description 		: This is ITriggerHandler constructor which will be used in future.
       Created Date		: 01 February 2018          
    **************************************************************************************************************************************/   
    public ContactTriggerHandler(){
        super('Contact');
        
    }
	/************************************************************************************************************************************
      Author 				: Krishana Tupe
      Description 			: This method overrides before insert method from ITriggerHander which will control the execution flow.
      Last Modified Date	: 01 February 2018
      Last Modified By		: Krishana Tupe (added Comment)
	**************************************************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){
        Debug.log('listNewItems=='+listNewItems);
        if(TriggerSettings.mappedField.Contact_inheritOrganizationRecordTypeAndOwner){
            ContactTriggerHandler.inheritOrganizationRecordTypeAndOwner((List<Contact>)listNewItems, null, null, null);
        }
        if(TriggerSettings.mappedField.Contact_GenerateUUID){
            generateUUID(listNewItems);
        }
        if(TriggerSettings.mappedField.Contact_UpdateActiveReferrerOnContact){
            updateActiveReferrerOnContact((List<Contact>)listNewItems,null);
        }
        if(TriggerSettings.mappedField.Contact_CheckForDuplicateEmail){
            checkForDuplicateEmail(listNewItems,null);
        }
        if(TriggerSettings.mappedField.Contact_update_Custom_CRM_User){
            update_Custom_CRM_User((List<Contact>)listNewItems,null);
        }
        if(TriggerSettings.mappedField.Contact_UpdateCleansedName){
            updateCleansedName((List<Contact>)listNewItems);
        }
    }
    
    /************************************************************************************************************************************
      Author 				: Krishana Tupe
      Description 			: This method overrides before update method from ITriggerHander which will control the execution flow.
      Last Modified Date	: 01 February 2018
      Last Modified By		: Krishana Tupe (added Comment)
	**************************************************************************************************************************************/
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<Sobject> listOldItems, Map<Id, SObject> mapOldItems){        
        if(TriggerSettings.mappedField.Contact_inheritOrganizationRecordTypeAndOwner){
            ContactTriggerHandler.inheritOrganizationRecordTypeAndOwner((List<Contact>)listNewItems,(Map<Id,Contact>) mapNewItems,(List<Contact>) listOldItems,(Map<Id,Contact>) mapOldItems);
        } 
        if(TriggerSettings.mappedField.Contact_GenerateUUID){
            generateUUID(listNewItems);
        }
        if(TriggerSettings.mappedField.Contact_UpdateActiveReferrerOnContact){
            updateActiveReferrerOnContact((List<Contact>)listNewItems,(Map<Id,Contact>)mapNewItems);
        }
        if(TriggerSettings.mappedField.Contact_CheckForDuplicateEmail){
            checkForDuplicateEmail(listNewItems,mapOldItems);
        }
        if(TriggerSettings.mappedField.Contact_update_Custom_CRM_User){
            update_Custom_CRM_User((List<Contact>)listNewItems,(Map<Id,Contact>)mapNewItems);
        }       
        if(TriggerSettings.mappedField.Contact_restrictOverrideLeadSource){
            restrictOverrideLeadSource(listNewItems,mapNewItems,mapOldItems);
        }
        if(TriggerSettings.mappedField.Contact_UpdateCleansedName){
            updateCleansedName((List<Contact>)listNewItems);
        }
    }
    
    /************************************************************************************************************************************
      Author 				: Krishana Tupe
      Description 			: This method overrides after insert method from ITriggerHander which will control the execution flow.
      Last Modified Date	: 01 February 2018
      Last Modified By		: Krishana Tupe (added Comment)
	**************************************************************************************************************************************/
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){               
        if(TriggerSettings.mappedField.Contact_ConvertMatchingLead){
            convertMatchingLead((List<Contact>)listNewItems,(map<Id,Contact>)mapNewItems,null,null);
        }       
    }
    
    /************************************************************************************************************************************
      Author 				: Krishana Tupe
      Description 			: This method overrides after update method from ITriggerHander which will control the execution flow.
      Last Modified Date	: 01 February 2018
      Last Modified By		: Krishana Tupe (added Comment)
	**************************************************************************************************************************************/
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<Sobject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.Contact_RestartJourney){
            restartJourney((List<Contact>)listNewItems,(map<Id,Contact>)mapOldItems);
        }
        if(TriggerSettings.mappedField.Contact_ConvertMatchingLead){
            convertMatchingLead((List<Contact>)listNewItems,(map<Id,Contact>)mapNewItems,(List<Contact>) listOldItems,(map<Id,Contact>) mapOldItems);
        }
        if(TriggerSettings.mappedField.Contact_UpdateOpportunityPromoCode){
            updateOpportunityPromoCode((List<Contact>)listNewItems,(map<Id,Contact>)mapNewItems,(List<Contact>) listOldItems,(map<Id,Contact>) mapOldItems);
        }
    }
    
    /************************************************************************************************************************************
      Author 				: Krishana Tupe
      Description 			: This method overrides after delete method from ITriggerHander which will control the execution flow.
      Last Modified Date	: 01 February 2018
      Last Modified By		: Krishana Tupe (added Comment)
	**************************************************************************************************************************************/
    public override void AfterDelete( List<Sobject> listOldItems ,Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.Contact_UpdateAccounts){
            updateAccounts((List<Contact>)listOldItems,(map<Id,Contact>)mapOldItems);
        }
    }
    
	/************************************************************************************************************************************
       Author 				: Sunil Bhosale
       Description 			: This method is used to update Cleansed Unomy Company Name
       Last Modified Date	: 15 June 2018
    **************************************************************************************************************************************/
    public static void updateCleansedName(List<Contact> listNewItems){
        for(Contact contact:listNewItems){
            if(String.isNotBlank(contact.Account_Name__c)){
                contact.Cleansed_Company_Name__c = OrganizationHelper.getCleansedName(contact.Account_Name__c);
            }else if(String.isNotBlank(contact.Company__c)){
                contact.Cleansed_Company_Name__c = OrganizationHelper.getCleansedName(contact.Company__c);
            }else if(String.isNotBlank(contact.Billing_Account__c)){
                contact.Cleansed_Company_Name__c = OrganizationHelper.getCleansedName(contact.Billing_Account_Name__c);
            }else if(String.isNotBlank(contact.FirstName) && String.isNotBlank(contact.LastName)){
                contact.Cleansed_Company_Name__c = OrganizationHelper.getCleansedName(contact.FirstName+' '+contact.LastName);
            }else{
                contact.Cleansed_Company_Name__c = OrganizationHelper.getCleansedName(contact.LastName);
            }
            if(String.isNotBlank(contact.Unomy_Company_Name__c)){
                contact.Cleansed_Unomy_Company_Name__c = OrganizationHelper.getCleansedName(contact.Unomy_Company_Name__c);
            }    
        }  
    }
    
	/************************************************************************************************************************************
       Author 				: Mayuresh Ghodke 
       Description 			: This method is used to check duplicate contact records using email.
       Last Modified Date	: 18 Jan 2019
       Last Modified By		: Krishana Tupe
	**************************************************************************************************************************************/
    public static void checkForDuplicateEmail(List<Contact> listNewItems, Map<Id, SObject>  mapOldItems ){
        Map<String, Contact> mapContacts =new Map<String, Contact>();
        Map<Id, Contact> mapTriggerOldMap = (Map<Id, Contact>) mapOldItems;
        for(Contact objNewContact : listNewItems){
            Contact objOldContact = Trigger.isUpdate ? mapTriggerOldMap.get(objNewContact.Id) : null;
            if (String.isNotBlank(objNewContact.Email) && (Trigger.isInsert || (objOldContact != null && Settings.isChanged(objNewContact.Email, objOldContact.Email)))){
                if (mapContacts.containsKey(objNewContact.Email.toLowerCase())){
                    objNewContact.Email.addError('Another new contact has the same email address.');
                }else{
                    mapContacts.put(objNewContact.Email.toLowerCase(), objNewContact);
                }
            }
        }
        if(!mapContacts.isEmpty()){
            for(Contact objContact : [SELECT Email FROM Contact WHERE Email IN : mapContacts.KeySet()]){
                Contact objNewContact = mapContacts.get(objContact.Email.toLowerCase());
                objNewContact.Email.addError('A Contact with this email address already exists.'); 
            }
        }  
    }    
    
	/************************************************************************************************************************************
       Author 			: Samadhan Kadam 
       Description 		: This method convert lead to contact if Covert Lead checkbox on contact is true or checked
       Created Date		: 29 June 2016
       Last Modified By	: Samadhan Kadam
	--------------------------------------------------------------------------------------------------------------------------------------
	   Last Modified By : Milanjeet Singh
	   Modified Date	: 9-June-2018
	**************************************************************************************************************************************/
    public static void convertMatchingLead(list<Contact> listNewItems,Map<Id, Contact> mapNewItems, List<Contact> listOldItems, map<Id,Contact> mapOldItems ){	
        Set<String> setEmails = new Set<String>();
        if(Trigger.isInsert){
            for (Contact contact :listNewItems){
                if(contact.Convert_Lead__c != null &&contact.Convert_Lead__c ==true  && String.isNotBlank(contact.Email) )
                    setEmails.add(contact.Email);
            } 
        }else if(Trigger.isUpdate){
            for(Contact contact : listNewItems){
                if(String.isNotBlank(contact.Email) && String.isNotBlank(mapOldItems.get(contact.Id).Email) && !(contact.Email.equalsIgnoreCase(mapOldItems.get(contact.Id).Email))){
                    setEmails.add(contact.Email);
                }
                if( contact.Convert_Lead__c!= null && mapOldItems.get(contact.Id).Convert_Lead__c != null && contact.Convert_Lead__c == true && contact.Convert_Lead__c != mapOldItems.get(contact.Id).Convert_Lead__c )
                    setEmails.add(contact.Email);
            }
        }       
        if(setEmails !=null && setEmails.size() > 0){
            List<Lead> lstLeadsToConvert = [SELECT Id, Email, Campaign_Id__c FROM Lead WHERE Email IN : setEmails AND IsConverted =  FALSE];
            if(lstLeadsToConvert.size() > 0){               
                LeadConverterHelper.manageJourneyForLead(lstLeadsToConvert,false);
            }            
        }
    }
    
	/************************************************************************************************************************************
       Author 			: Dipak Pawar 
       Description 		: Update accounts (that will automatically set Primary Member).
       Created Date		: 04 July 2016
       Last Modified By	: Dipak Pawar
	   Issue No.		: ST-518
	**************************************************************************************************************************************/
    public static void updateAccounts(List<Contact> listNewItems ,Map<Id, Contact> mapOldItems){
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        for(Contact currentContact : listNewItems){
            if(!string.isBlank(currentContact.AccountId) && !mapAccounts.containsKey(currentContact.AccountId)){
                mapAccounts.put(currentContact.AccountId, new Account(Id = currentContact.AccountId));
            }
        }
        if(mapAccounts.size() > 0){
            update mapAccounts.values();
        }    
    }
    
	/************************************************************************************************************************************
       Author 			: Pranay Jadhav 
       Description 		: SF Lead/opportunity attribution [ restrict Override LeadSource ].
       Created Date		: 22 December 2016
       Last Modified By	: Dipak Pawar
	   Issue No.		: ST-803
	**************************************************************************************************************************************/
    public static void restrictOverrideLeadSource(List<Contact> listNewItems,  Map <Id,Sobject> mapNewItems,Map<Id, SObject> mapOldItems){
        for(Contact newContact : listNewItems){
            Contact objOldContact = (Contact)mapOldItems.get(newContact.Id);
            if(newContact.LeadSource != objOldContact.LeadSource && String.isNotBlank(objOldContact.LeadSource)){
                newContact.LeadSource = objOldContact.LeadSource;
            }
        }   
    }
   
	/************************************************************************************************************************************
       Author 			: Pranay Jadhav 
       Description 		: custom__crm__user___c not being populated in some cases.
       Created Date		: 26 December 2016
       Last Modified By	: Dipak Pawar
	   Issue No.		: ST-802
	**************************************************************************************************************************************/  
    public static void update_Custom_CRM_User(List<Contact> listNewItems, Map<Id, Contact>  mapNewItems ){
        Set<String> emails = new Set<String>();
        Set<String> setAllowedDomains = new Set<String>();
        Map<String,Id> mapEmailwithId = new Map<String,Id>();
        UserRoleUpdate objUserRoleUpdate = new UserRoleUpdate();
        Setting__c userRoleUpdatSetting = Settings.get('UserRoleUpdate');
        if(userRoleUpdatSetting != null){
            objUserRoleUpdate = (UserRoleUpdate)JSON.deserialize(userRoleUpdatSetting.Data__c , UserRoleUpdate.class);
            setAllowedDomains.addAll(objUserRoleUpdate.allowedDomains);
        }
        if(!setAllowedDomains.isEmpty()){
            for(Contact newContact : listNewItems){
                if(newContact.email != null){
                    if(setAllowedDomains.contains(newContact.email.split('@')[1]))
                        emails.add(newContact.email);
                }
            }
            if(!emails.isEmpty()){
                for(User user : Settings.getAllUsers()){
                    if(emails.contains(user.email))
                        mapEmailwithId.put(user.email,user.Id);
                }
                for(Contact contact : listNewItems){
                    if( String.isNotBlank(contact.Email) && mapEmailwithId.containsKey(contact.email))
                        contact.Custom_CRM_User__c = mapEmailwithId.get(contact.email);
                }
            } 
        }
    }
      
	/************************************************************************************************************************************
		Author 		: Pranay Jadhav
		Description : This wrapper class will be used to update_Custom_CRM_User on contact.

		History:
	----------------------------------------------------------------------------------------------------------------------------------
		VERSION			DATE					AUTHOR					DETAIL							ISSUE
		1				26 December 2016		Pranay Jadhav			Initial Developement			ST-802
	**************************************************************************************************************************************/     
    public class UserRoleUpdate {
        List<String> allowedDomains{get;set;} 
    }  
    
	/************************************************************************************************************************************
       Author 			: Dipak Pawar 
       Description 		: GenerateUUIDContact.
       Created Date		: 06 July 2016
       Last Modified By	: Dipak Pawar
	   Issue No.		: ST-518
	-------------------------------------------------------------------------------------------------------------------------------------
	   Last Modified By	: Milanjeet Singh
	   Description		: Changed the uuid generation logic as per new billing account object.
	**************************************************************************************************************************************/  
    public static void generateUUID(List<Contact> listNewItems) {
        for(Contact currentContact : listNewItems) {
            //Commented below condition as we need to generate UUID for contact every time if UUID is not populated.
            //if(currentContact.Billing_Account__c != null && String.isBlank(currentContact.UUID__c) && (currentContact.Leadsource == null || !currentContact.LeadSource.equalsIgnoreCase('Id')))
            if(String.isBlank(currentContact.UUID__c)){
                currentContact.UUID__c = UUIDHandler.generateVersion4();
            }
        }
    }
    
	/************************************************************************************************************************************
       Author 			: Samadhan Kadam 
       Description 		: This method get active Referrence record and set Referrer__c field value of Contact based on email Id.
       Created Date		: 01 August 2016
       Last Modified By	: Samadhan Kadam
	   Issue No.		: ST-583
	**************************************************************************************************************************************/   
    public static void updateActiveReferrerOnContact(List<Contact> listNewItems,Map<Id, Contact> mapNewItems ){
        Set<String> setOfContactEmail = new Set<String>();
        Map<Id,String> mapOfContact = new Map<Id,String>();
        map<string,Id> mapActiveReference = new map<String,Id>();
        for(Contact contact : listNewItems){
            if(contact.Email !=null){
                setOfContactEmail.add(contact.Email.toLowerCase());              
            }
        }
        if(!setOfContactEmail.isEmpty() && setOfContactEmail.size() > 0)
            mapActiveReference = ReferenceHandler.getActiveReference(setOfContactEmail);
        if(mapActiveReference != null && mapActiveReference.size() > 0){
            for(Contact contact : (listNewItems)){
                if( String.isNotBlank(contact.Email) && mapActiveReference.get(contact.Email.toLowerCase()) != null)
                    contact.Referrer__c = mapActiveReference.get(contact.Email.toLowerCase());
            }
        } 
    }    
    
	/************************************************************************************************************************************
       Author 			: Anant Kumar 
       Description 		: This method contains the restartJourney logic. 
       Created Date		: 23 August 2016
       Last Modified By	: Sunil Bhosale
	   Issue No.		: ST-622
	**************************************************************************************************************************************/  
    public static void restartJourney(List<Contact> listNewItems,Map<Id, Contact> mapOldItems){
        Settings.FieldMappings mapContactToJourney;
        Set<Id> contactToRestartJourney = new Set<Id>();
        Set<Id> Ids = new Set<Id>();
        List<Sobject> lstSobjectsToUpdate = new List<Sobject>();
        List<Journey__c> journeyToInsert = new List<Journey__c>();
        Map<Id, Contact> mapofContactWithJourney = new Map<Id, Contact>();
        for(Contact contactRec : listNewItems){
            if(contactRec.Restart_Journey__c == true && mapOldItems.get(contactRec.Id).Restart_Journey__c != contactRec.Restart_Journey__c)
                Ids.add(contactRec.Id);
        }
        if(Ids.size() > 0){
            mapContactToJourney = Settings.getFieldMappings('ContactToJourney');
            String strQuery = 'SELECT Name,Restart_Journey__c, LeadSource,';
            if(mapContactToJourney != null){
                for(Settings.MappedField field : mapContactToJourney.mappings.values()){
                    if(!strQuery.contains(field.fieldname))
                        strQuery += field.fieldname + ',';
                }
            }
            strQuery = strQuery.removeEnd(',');
            strQuery += ' , Location__r.City__c, (SELECT Status__c, LastModifiedDate, NMD_Next_Contact_Date__c, Building_Interested_In__c, Building_Interested_In__r.City__c FROM Journeys__r where Status__c = \'Started\'  Order By LastModifiedDate DESC LIMIT 1) FROM Contact c WHERE Id in:Ids';
            Debug.log('strQuery :: '+strQuery);
            for(Contact contact : Database.Query(strQuery)){
                contact.Restart_Journey__c = false;
                lstSobjectsToUpdate.add(contact);
                if(contact.Journeys__r.size() > 0){// started journey is present so update existing journey.
                    Journey__c journeyRec = contact.Journeys__r; 
                    Journey__c journey = new Journey__c();
                    journey.Id = journeyRec.Id;
                    journey.NMD_Next_Contact_Date__c = Date.today();
                    lstSobjectsToUpdate.add(journey);
                }else{//no started journey is present so create new journey.
                    Journey__c journey = new Journey__c();
                    if(mapContactToJourney != null){
                        for(String strKey : mapContactToJourney.mappings.keySet()){
                            journey.put(strKey, contact.get(mapContactToJourney.mappings.get(strKey).fieldname));
                        }
                    }
                    journey.NMD_Next_Contact_Date__c = Date.today();
                    journey.Primary_Contact__c = contact.Id;
                    journey.Status__c = 'Started';
                    if(contact.Location__c != null && String.isNotBlank(contact.Location__r.City__c) )
                        journey.Name = journey.Name + '-'+contact.Location__r.City__c;
                    if(String.isNotBlank(contact.LeadSource))
                        journey.Name = journey.Name + '-'+contact.LeadSource;
                    journeyToInsert.add(journey);
                }
            }
            if(journeyToInsert.size() > 0)
                insert journeyToInsert;
            If(lstSobjectsToUpdate.size() > 0)
                update lstSobjectsToUpdate;
        }
    }
      
    /************************************************************************************************************************************
        Author              :   Ajaysinh Chauhan
        Description         :   This method will update RecordType and Owner of the Contact same as Account.
        Created Date        :   23 June 2018    
    **************************************************************************************************************************************/    
    public static void inheritOrganizationRecordTypeAndOwner(List<Contact> listNewItems,Map<Id, Contact> mapNewItems,List<Contact> listOldItems, map<Id,Contact> mapOldItems ){
        Map<Id,Schema.RecordTypeInfo> mapAccountRecordType =  Schema.SObjectType.Account.getRecordTypeInfosById();
        Map<String,Schema.RecordTypeInfo> mapContactRecordType =  Schema.SObjectType.Contact.getRecordTypeInfosByName();
        for(Contact objContact:listNewItems){
            if(String.isNotBlank(objContact.Account_Record_Type__c) && mapContactRecordType.containsKey(mapAccountRecordType.get(objContact.Account_Record_Type__c).getName())){
                objContact.RecordTypeId = mapContactRecordType.get(mapAccountRecordType.get(objContact.Account_Record_Type__c).getName()).getRecordTypeId();
            }
            if(Trigger.isInsert && String.isNotBlank(objContact.Account_Owner__c) && Settings.getUserActive(objContact.Account_Owner__c)){
                objContact.OwnerId = objContact.Account_Owner__c;
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method will update Promo Code on Opportunity on Opportunity at the time of Opportunity reuse.
        Created Date        :   22 Oct 2018
    **************************************************************************************************************************************/    
    public static void updateOpportunityPromoCode(List<Contact> listNewItems,Map<Id, Contact> mapNewItems,List<Contact> listOldItems, map<Id,Contact> mapOldItems){
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        Set<Id> setContacts = new Set<Id>();
        for(Contact objContact: listNewItems){
            if(objContact.Promo_Code__c != mapOldItems.get(objContact.Id).Promo_Code__c){
                setContacts.add(objContact.Id);
            }
        }
        if(setContacts.size() > 0){
            for(Contact ObjContact: [SELECT Id, Promo_Code__c, (SELECT Id, Name, Primary_Contact__c, Promo_Code__c FROM Opportunities) FROM Contact WHERE Id IN: setContacts]){
                for(Opportunity ObjOpp: ObjContact.Opportunities){
                    if(ObjContact.Promo_Code__c != ObjOpp.Promo_Code__c && String.isBlank(ObjOpp.Promo_Code__c)){
                        ObjOpp.Promo_Code__c = ObjContact.Promo_Code__c;
                        lstOppToUpdate.add(ObjOpp);
                    }
                }
            }
        }
        if(lstOppToUpdate.size() > 0){
            update lstOppToUpdate;
        }
    }
   
	/************************************************************************************************************************************
		Author 		: Pranay Jadhav
		Description : This class will be used to handle ContactTrigger exception.

		History:
	----------------------------------------------------------------------------------------------------------------------------------
		VERSION			DATE					AUTHOR					DETAIL							ISSUE	
		1				26 December 2017		Pranay Jadhav			Initial Developement			-
	**************************************************************************************************************************************/
 	public class ContactTriggerHandlerException extends Exception{}
    
}