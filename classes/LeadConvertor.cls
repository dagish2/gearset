/*********************************************************************************************
Name   : LeadConvertor
Purpose: Check and delete duplicate leads
		 Convert lead if contact exist and delete if duplicate.
         Create Journey based on criteria and create activity and product interest.
History:
         VERSION      DATE      	AUTHOR                 DETAIL
          1.0      24 Apr 2016   Hemanshu Shah  	 Initial Developement.
		  2.0      1  May 2016	 Amol Darekar	 	 Initial Developement and Improvements.
		  3.0      19 Jan 2018	 Amol Darekar	 	 Changes for relate journey to campaign.

*********************************************************************************************/
global class LeadConvertor {
    //Fields mapping to map Lead fields to Contacts fields
    //static Map<String,String> mapLeadToContact;
    public static Settings.FieldMappings mapLeadToContact;
    //Fields mapping to map Lead fields to Journey fields
    public static Settings.FieldMappings mapLeadToJourney;
    //Fields mapping to map Lead fields to Activity fields
    public static Settings.FieldMappings mapLeadToActivity;
    //Fields mapping to map Lead fields to Account fields
    public static Settings.FieldMappings mapLeadToAccount;
    //Fields mapping to map Lead fields to Contact fields
    public static Settings.FieldMappings mapContactToJourney;
    
   public static JourneySettings settingsJourney;
    static Setting__c objUnassignedNMDUSQueue ;
    static UnassignedNMDUSQueue objUnassignedNMDUSQueueData ;
     /*Purpose : This method is use map field from Lead to Contact in case we get null from JSON settings*/
    public static Settings.FieldMappings Lead2Contact() {
        Settings.FieldMappings leadToContactMappings = new Settings.FieldMappings();
        leadToContactMappings.version = 1;
        leadToContactMappings.mappings = new Map<String, Settings.MappedField>();
        //leadToContactMappings.mappings.put('Name', new Settings.MappedField('Name'));
        leadToContactMappings.mappings.put('LastName', new Settings.MappedField('LastName'));
        leadToContactMappings.mappings.put('Email', new Settings.MappedField('Email'));
        leadToContactMappings.mappings.put('OwnerId', new Settings.MappedField('OwnerId'));
        return leadToContactMappings;
    }
    
    /*Purpose : This method is use map field from Lead to Journey in case we get null from JSON settings*/
    public static Settings.FieldMappings Lead2Journey() {
        Settings.FieldMappings leadToJourneyMappings = new Settings.FieldMappings();
        leadToJourneyMappings.version = 1;
        leadToJourneyMappings.mappings = new Map<String, Settings.MappedField>();
        leadToJourneyMappings.mappings.put('Name', new Settings.MappedField('Name'));
        leadToJourneyMappings.mappings.put('Lead_Source__c', new Settings.MappedField('LeadSource'));
        leadToJourneyMappings.mappings.put('Lead_Source_Detail__c', new Settings.MappedField('Lead_Source_Detail__c'));
        leadToJourneyMappings.mappings.put('Kickbox_CampaignId__c', new Settings.MappedField('CampaignId__c'));
        
        return leadToJourneyMappings;
    }
    
    /************************************************************************************************************************************
        Author          : Mayuresh Ghodke
        Description     : This wrapper is used to store unassigned NMD user queqes.
        Created Date    : 08 November 2016
    ********************************************************************************************************************************/  
    public class UnassignedNMDUSQueue{
        public List<String> UnassignedNMDUSQueue{get;set;}              
    }
    
    /*Purpose : This method is use map field from Lead to Activity in case we get null from JSON settings*/
    public static Settings.FieldMappings Lead2Activity() {
        Settings.FieldMappings leadToActivityMappings = new Settings.FieldMappings();
        leadToActivityMappings.version = 1;
        leadToActivityMappings.mappings = new Map<String, Settings.MappedField>();
        leadToActivityMappings.mappings.put('Lead_Source__c', new Settings.MappedField('LeadSource'));
        return leadToActivityMappings;
    }
    
    /*Purpose : This method is use map field from Lead to Account in case we get null from JSON settings*/
    public static Settings.FieldMappings Lead2Account() {
        Settings.FieldMappings leadToAccountMappings = new Settings.FieldMappings();
        leadToAccountMappings.version = 1;
        leadToAccountMappings.mappings = new Map<String, Settings.MappedField>();
        leadToAccountMappings.mappings.put('Name', new Settings.MappedField('Company'));
        leadToAccountMappings.mappings.put('CurrencyIsoCode', new Settings.MappedField('CurrencyIsoCode'));
        return leadToAccountMappings;
    }
    
    /*Purpose : This method is use to get default journey settings in case we get null from JSON settings*/
    public static JourneySettings DefaultJourneySettings() {
        String strDummyAccountName = 'Dummy Lead Conversion Account';
        Account account;
        Account[] accounts = [Select Id From Account Where Name = :strDummyAccountName];
        if( accounts.size() > 0 )
            account = accounts[0];
        else{
            account = new Account(Name = strDummyAccountName);
            insert account;
        }
        
        LeadConvertor.JourneySettings settingJourney;
        
        settingJourney = new LeadConvertor.JourneySettings();
        settingJourney.NextCallInDaysFromLeadCreation = 1;
        settingJourney.NewLeadActivityFields = null;
        settingJourney.NewJourneyFields = null;
        settingJourney.NoCompanyAccountId = account.Id;
        return settingJourney;
    }
    
    static {
        Settings.LoadSettings(new String[]{'FieldMappings:LeadToContact', 'FieldMappings:LeadToJourney', 'FieldMappings:LeadToActivity', 'Journey'});

        mapLeadToContact = Settings.getFieldMappings('LeadToContact');
        Debug.log('mapLeadToContact=='+mapLeadToContact);
        if( mapLeadToContact == null ) mapLeadToContact = Lead2Contact();
        
        mapLeadToJourney = Settings.getFieldMappings('LeadToJourney');
        if( mapLeadToJourney == null ) mapLeadToJourney = Lead2Journey();
        
        mapLeadToActivity = Settings.getFieldMappings('LeadToActivity');
        if( mapLeadToActivity == null ) mapLeadToActivity = Lead2Activity();
        
        mapLeadToAccount = Settings.getFieldMappings('LeadToAccount');
        if( mapLeadToAccount == null ) mapLeadToAccount = Lead2Account();
        
        mapContactToJourney = Settings.getFieldMappings('ContactToJourney');
        if( mapContactToJourney == null ) mapContactToJourney = WeworkEngine.Contact2Journey();
        
        settingsJourney = (JourneySettings)Settings.get('settingsJourney', JourneySettings.class);
        Debug.log('settingsJourney ::: ' + settingsJourney);
        if( settingsJourney == null ){
            settingsJourney = DefaultJourneySettings();
        } 
        
        settingsJourney.initDefaults();
    }
    
    static List<String> listLeadFields = null;
    
    /*Purpose : This method is use to retuen list of field fecth to be fetched in soql*/
    public static List<String> getLeadFields(){
        if( listLeadFields == null ){
            Set<String> setLeadFields = new Set<String>();
            setLeadFields.add('building_interested_in__r.city__c');
            setLeadFields.add('building_interested_in__c');
            setLeadFields.add('product_line__c');
            setLeadFields.add('number_of_desks_2016__c');
            setLeadFields.add('recordtypeid');
            setLeadFields.add('createdDate');
            setLeadFields.add('company_size__c');
            setLeadFields.add('name');
            setLeadFields.add('isconverted');
            setLeadFields.add('ownerid');
            setLeadFields.add('owner.IsActive');
            setLeadFields.add('Check_Duplicates__c');
            setLeadFields.add('Generate_Journey__c');
            setLeadFields.add('By_Pass_Journey_Creation_Criteria__c');
            setLeadFields.add('Kickbox_CampaignId__c'.toLowerCase());
            setLeadFields.add('account__c'); 
            setLeadFields.add('Affiliate_Consent__c'.toLowerCase());
            setLeadFields.add('Marketing_Consent__c'.toLowerCase()); 
            setLeadFields.add('Ts_and_Cs_Consent__c'.toLowerCase()); 
            setLeadFields.add('LeadSource'.toLowerCase());
            
            for(Settings.MappedField field : mapLeadToContact.mappings.values()){
                setLeadFields.add(field.fieldname.toLowerCase());
            }
            
            for(Settings.MappedField field : mapLeadToJourney.mappings.values()){
                setLeadFields.add(field.fieldname.toLowerCase());
            }
            
            for(Settings.MappedField field : mapLeadToActivity.mappings.values()){
                setLeadFields.add(field.fieldname.toLowerCase());
            }
            
            for(Settings.MappedField field : mapLeadToAccount.mappings.values()){
                setLeadFields.add(field.fieldname.toLowerCase());
            }
            
            listLeadFields = new List<String>();
            listLeadFields.addAll(setLeadFields);
        }
        return listLeadFields;
        
    }
    
     /*Purpose : Need this method to create new account from lead*/
    public static Account accountFromLead(Lead lead){
        Account objAccount = new Account();
        for(String field : mapLeadToAccount.mappings.keySet()){
            Settings.MappedField mappedField = mapLeadToAccount.mappings.get(field);
            if(mappedField.isvalue == true)
                objAccount.put(field, mappedField.value);
            else
                objAccount.put(field, lead.get(mappedField.fieldname));
        }
        
        if(!String.isBlank(lead.company)){
            objAccount.Name = lead.company;
        }
        else{
            objAccount.Name = (string.isBlank(lead.FirstName) ? '' :lead.FirstName+' ') +''+ lead.LastName;
        }
        debug.log('objAccount==>'+objAccount);
        //Added by Krishana;
        if(objAccount.ParentId == null && lead.Account__c != null){             
            objAccount.ParentId = lead.Account__c;
            objAccount.Org_Identification_Status__c = 'Processed';
        }
        if(!String.isBlank(objAccount.Account_Type__c)){
            objAccount.Account_Type__c=''; 
        }        
        return objAccount;
    }
    
    /*Purpose : Need this method to create Journey from lead*/
    public static Journey__c journeyFromLead(Lead lead ,Id existingLeadOwnerId, Contact exsitingContact,Boolean existingContactJourneyCreation,Boolean existingLeadJourneyCreation, Map<String, List<Journey__c>> mapJourneysByEmail, Boolean journeyCreatedInYDays,String apiUserId){
        Journey__c journey = new Journey__c();
        for(String strKey : settingsJourney.NewJourneyFields.keySet()) {
            journey.put(strKey, settingsJourney.NewJourneyFields.get(strKey));
        }
        
        journey.NMD_Next_Contact_Date__c = DateUtilities.addBusinessDays(Date.today(), settingsJourney.NextCallInDaysFromLeadCreation);
        for(String field : mapLeadToJourney.mappings.keySet()){
            Settings.MappedField mappedField = mapLeadToJourney.mappings.get(field);
            if(mappedField.isvalue == true)
                journey.put(field, mappedField.value);
            else
                journey.put(field, lead.get(mappedField.fieldname));
            
        }
        journey.Name = lead.name + '-' +(string.isBlank(lead.building_interested_In__r.city__c) ? '' :lead.building_interested_in__r.city__c+'-')+''+ lead.leadsource; //(Date.today()).year() +'-'+ (Date.today()).month() +'-'+ (Date.today()).day();
        if(journey.Name != null && journey.Name.length() > 80){
            journey.Name =  journey.Name.substring(0, 80);
        }

        Debug.log('Test :existingLeadOwnerId ::: ' + existingLeadOwnerId);
        Debug.log('Test :exisitingContact ::: ' + exsitingContact);
        Debug.log('Test :existingContactJourneyCreation ::: ' + existingContactJourneyCreation);
        Debug.log('Test :existingLeadJourneyCreation ::: ' + existingLeadJourneyCreation);
        Debug.log('Test :journey----'+journey);
        Debug.Log('Test :lead-------'+lead);
        if(journeyCreatedInYDays){
            journey.OwnerId = exsitingContact != null ? exsitingContact.OwnerId : (existingLeadOwnerId != null ? existingLeadOwnerId : null);
                }
        else if( !existingContactJourneyCreation && !existingLeadJourneyCreation)
            journey.OwnerId = lead.OwnerId;
        /* changes made by : Sunil B.
        * Issue No : ST-1879
        */
        else if(exsitingContact != null){
            //journey.OwnerId = exsitingContact.OwnerId;
            if(String.valueOf(exsitingContact.OwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(apiUserId).substring(0,15))
               && String.valueOf(lead.OwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(exsitingContact.OwnerId).substring(0,15))){
                   if(objUnassignedNMDUSQueueData!=null){
                       journey.OwnerId = objUnassignedNMDUSQueueData.UnassignedNMDUSQueue[0];
                   }     
               }else if(String.valueOf(exsitingContact.OwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(apiUserId).substring(0,15))
                        && !String.valueOf(lead.OwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(exsitingContact.OwnerId).substring(0,15))) {
                            journey.OwnerId = exsitingContact.OwnerId;
                            journey.Owner_SFID__c = lead.OwnerId;
                        }
            else if(!String.valueOf(exsitingContact.OwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(apiUserId).substring(0,15))
                    && !String.valueOf(lead.OwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(exsitingContact.OwnerId).substring(0,15))){
                        //journey.OwnerId = lead.OwnerId;
                       journey.OwnerId = exsitingContact.OwnerId;
                    }
            
        }
        else if(existingLeadOwnerId != null){
            debug.Log('In ExistingLeadOwnerId------');
            //journey.OwnerId = existingLeadOwnerId;
             if(String.valueOf(existingLeadOwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(apiUserId).substring(0,15))){
                 debug.Log('In ExistingLeadOwnerId Is Sussie------');
                  if(objUnassignedNMDUSQueueData!=null)
                    journey.Owner_SFID__c = objUnassignedNMDUSQueueData.UnassignedNMDUSQueue[0];
            }else{
                debug.Log('In ExistingLeadOwnerId Other then Sussie------');
                journey.Owner_SFID__c = existingLeadOwnerId;  
            }
        }
        
        //Changes for ST-1715
        if(exsitingContact != null){
            Debug.Log('Existing contact Journey :: journey ::'+journey);
            Debug.Log('Existing contact Journey :: lead ::'+lead);
            
            //Update Owner_SFID__c field if existing contact owner is api user and lead owner is not same as contact owner.
            if(!String.isBlank(apiUserId) && (String.valueOf(exsitingContact.OwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(apiUserId).substring(0,15)))
               && !(String.valueOf(exsitingContact.OwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(lead.OwnerId).substring(0,15)))){
                   Debug.Log('Inside if existing contact is susie : dup lead is not susie and existing contact owner is not leads owner');
                   journey.Owner_SFID__c = lead.OwnerId;
               }/*else if (!String.isBlank(apiUserId) 
                         && (String.valueOf(exsitingContact.OwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(apiUserId).substring(0,15)))
                         && (String.valueOf(exsitingContact.OwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(lead.OwnerId).substring(0,15)))){
                             //Need to assign NMD Queue
                             if(objUnassignedNMDUSQueueData!=null 
                                && objUnassignedNMDUSQueueData.UnassignedNMDUSQueue!=null
                                && objUnassignedNMDUSQueueData.UnassignedNMDUSQueue.size()>0)
                             	journey.Owner_SFID__c=objUnassignedNMDUSQueueData.UnassignedNMDUSQueue[0];
                         }*/
        }
        else if(existingLeadOwnerId != null){
            debug.Log('Existing Lead Owner------'+existingLeadOwnerId);
            if(!String.isBlank(apiUserId) && (String.valueOf(existingLeadOwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(apiUserId).substring(0,15)))
               && !(String.valueOf(existingLeadOwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(lead.OwnerId).substring(0,15)))){
                  
                   journey.Owner_SFID__c = lead.OwnerId;
               }/*else if(!String.isBlank(apiUserId) 
                        && (String.valueOf(existingLeadOwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(apiUserId).substring(0,15)))
                        && (String.valueOf(existingLeadOwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(lead.OwnerId).substring(0,15)))){
                            //Need to assign NMD Queue 
                            Debug.log('eeeeeeeee');
                            if(objUnassignedNMDUSQueueData!=null 
                               && objUnassignedNMDUSQueueData.UnassignedNMDUSQueue!=null
                               && objUnassignedNMDUSQueueData.UnassignedNMDUSQueue.size()>0)
                                journey.Owner_SFID__c=objUnassignedNMDUSQueueData.UnassignedNMDUSQueue[0];
                        }*/
        }
        
        return journey;
    }
    
    /*Comment   : This method is use to create Product Interested record for leads and contact.  
    Author    : Amol Darekar 
    Date      : 15 October 2016 
    Issue     : ST-740*/
    public static void createProductInterest(list<LeadResult> lstLeadResult,Date productIntDateDiff){
        map<string,LeadResult> mapUniqueKeys = new map<string,LeadResult>();
        map<string,Product_Interested__c> mapExistingProductInt = new map<string,Product_Interested__c>();
        Product_Interested__c objProductInterested;
        list<Product_Interested__c> lstProductInterestToBeInserted = new list<Product_Interested__c>();
        list<Product_Interested__c> lstProductInterestToBeUpdated = new list<Product_Interested__c>();
        map<String,String> mapJourneyStatusById = new map<String,String>();
        
        for(LeadResult currentLeadResult : lstLeadResult)
        { 
            if(currentLeadResult.JourneyId != null)
                mapJourneyStatusById.put(currentLeadResult.JourneyId,null);
            mapUniqueKeys.put(((String.isBlank(currentLeadResult.ProductLine)?'':currentLeadResult.ProductLine))+'-'+(String.isBlank(currentLeadResult.NumberOfDesks)?'':currentLeadResult.NumberOfDesks)+'-'+(String.isBlank(currentLeadResult.ContactId)?currentLeadResult.LeadId.substring(0,15) : currentLeadResult.ContactId.substring(0,15))+'-'+(String.isBlank(currentLeadResult.BuildingId)?'':currentLeadResult.BuildingId.substring(0,15)),currentLeadResult);
        }
        
        list<Product_Interested__c> lstExistingProductInterested = [SELECT Lead__c, Contact__c, Building__c, Unique_Key__c, Requested_Date__c, number_of_desks__c, Company_Size__c, CreatedDate, Status__c FROM Product_Interested__c WHERE Unique_Key__c IN: mapUniqueKeys.keyset()];
        
        for(Product_Interested__c currentProductInterested : lstExistingProductInterested)
        {
            mapExistingProductInt.put(currentProductInterested.Unique_key__c,currentProductInterested);
        }
        
        for(string currentKey : mapUniqueKeys.keyset())
        {
            if(!mapExistingProductInt.containsKey(currentKey))
            {
                LeadResult objLeadResult = mapUniqueKeys.get(currentKey);
                if(!string.isBlank(objLeadResult.NumberOfDesks))
                {
                    objProductInterested = new Product_Interested__c();
                    
                    if(objLeadResult.ContactId == null)
                        objProductInterested.Lead__c = objLeadResult.LeadId;
                    else
                        objProductInterested.Contact__c = objLeadResult.ContactId; 
                    
                    objProductInterested.number_of_desks__c = objLeadResult.NumberOfDesks;
                    objProductInterested.Building__c = objLeadResult.BuildingId;
                    objProductInterested.Journey__c = objLeadResult.JourneyId;
                    objProductInterested.Company_Size__c = objLeadResult.CompanySize;
                    objProductInterested.Requested_Date__c = Date.today();
                    objProductInterested.Product_Line__c = objLeadResult.ProductLine;
                    lstProductInterestToBeInserted.add(objProductInterested);
                }
            }
            else
            {
                objProductInterested = new Product_Interested__c();
                objProductInterested = mapExistingProductInt.get(currentKey);
                
                if(objProductInterested.CreatedDate > productIntDateDiff && objProductInterested.Status__c == 'Started')
                {
                    objProductInterested.Requested_Date__c = Date.today();
                    lstProductInterestToBeUpdated.add(objProductInterested);
                }
                else if(objProductInterested.CreatedDate > productIntDateDiff && String.isBlank(objProductInterested.Status__c))
                {
                    objProductInterested.Requested_Date__c = Date.today();
                    objProductInterested.Journey__c = mapUniqueKeys.get(currentKey).JourneyId;
                    lstProductInterestToBeUpdated.add(objProductInterested);
                }
                else
                {
                    Product_Interested__c newProductInterested = new Product_Interested__c();
                    if(objProductInterested.Contact__c == null)
                        newProductInterested.Lead__c = objProductInterested.Lead__c;
                    else
                        newProductInterested.Contact__c = objProductInterested.Contact__c; 
                    
                    newProductInterested.number_of_desks__c = objProductInterested.number_of_desks__c;
                    newProductInterested.Building__c = objProductInterested.Building__c;
                    newProductInterested.Journey__c = mapUniqueKeys.get(currentKey).JourneyId;
                    newProductInterested.Product_Line__c = mapUniqueKeys.get(currentKey).ProductLine;
                    newProductInterested.Company_Size__c = objProductInterested.Company_Size__c;
                    lstProductInterestToBeInserted.add(newProductInterested); 
                }
                
            }
        }
        if(lstProductInterestToBeInserted != null && lstProductInterestToBeInserted.size() > 0 )    
            insert lstProductInterestToBeInserted;
        
        if(lstProductInterestToBeUpdated != null && lstProductInterestToBeUpdated.size() > 0) 
            update lstProductInterestToBeUpdated;
    }
    
    //Need this method to create Activity from lead
    public static Task activityFromLead(Lead lead, Contact contact, Journey__c journey, Boolean IsLeadFromWebsite){
        Task activity = new Task();
        for(String strKey : settingsJourney.NewLeadActivityFields.keySet()) {
            activity.put(strKey, settingsJourney.NewLeadActivityFields.get(strKey));
        }
        
        if( contact != null ){
            activity.WhoId = contact.Id;
            //Journey can be associated with Task only if Task is assigned to the contact,
            //Salesforce does not allow to assolciate ask to any other object if the task
            //is associated with a Lead.
            if(journey != null) 
                activity.WhatId = journey.Id;
        }
        else
            activity.WhoId = lead.Id;
        
        for(String field : mapLeadToActivity.mappings.keySet()){
            Settings.MappedField mappedField = mapLeadToActivity.mappings.get(field);
            if(mappedField.isvalue == true)
                activity.put(field, mappedField.value);
            else
                activity.put(field, lead.get(mappedField.fieldname));
        }
        //Changes of ownerId ST-630
        if(contact != null){
            activity.ownerId = contact.Owner.IsActive ? contact.OwnerId : UserInfo.getUserId();
        }
        
        //If Lead task owner Id is Queue, Change ownerId to current user
        if(activity.OwnerId != null && ((String)activity.OwnerId).startsWith('00G'))
            activity.OwnerId = UserInfo.getUserId();
        //IF lead from website set activity type to 'website' and Status to 'Not Started'
        if(IsLeadFromWebsite){
            activity.Type = 'Website';
            activity.Status = 'Not Started';
        }
        return activity;
    }
    
    //Need this method to create Activity on exising lead
    public static Task activityFromExistingLead(Lead lead, Lead existingLead, Contact contact, Journey__c journey, Boolean IsLeadFromWebsite){
        Task activity = new Task();
        //activity.OwnerId = lead.OwnerId;
        for(String strKey : settingsJourney.NewLeadActivityFields.keySet()) {
            activity.put(strKey, settingsJourney.NewLeadActivityFields.get(strKey));
        }
        
        if( contact != null ){
            activity.WhoId = contact.Id;
            
            //Journey can be associated with Task only if Task is assigned to the contact,
            //Salesforce does not allow to assolciate ask to any other object if the task
            //is associated with a Lead.
            if(journey != null) 
                activity.WhatId = journey.Id;
        }
        else
            activity.WhoId = existingLead.Id;
        
        
        for(String field : mapLeadToActivity.mappings.keySet()){
            Settings.MappedField mappedField = mapLeadToActivity.mappings.get(field);
            if(mappedField.isvalue == true)
                activity.put(field, mappedField.value);
            else
                activity.put(field, lead.get(mappedField.fieldname));
        }
        
        //Changes of ownerId ST-630
        if(contact != null){
            activity.OwnerId = contact.Owner.IsActive ? contact.OwnerId : UserInfo.getUserId();
        }
        else if(existingLead !=null){
            activity.OwnerId = existingLead.Owner.IsActive ? existingLead.OwnerId : UserInfo.getUserId();
        }
        
        if(activity.OwnerId != null && ((String)activity.OwnerId).startsWith('00G')){
            activity.OwnerId = UserInfo.getUserId();
        }
        
        if(IsLeadFromWebsite){
            activity.Type = 'Website';
            activity.Status = 'Not Started';
        }
        return activity;
    }
    
    //public static void ConvertLead(Lead lead,contact contact,string convertedLeadStatus)
    //@future
    public static void ConvertLeads(set<string> setLeadEmails){
        //set<string> setLeadEmails
        Debug.Log('Kickbox :: ConvertLeads :: '+setLeadEmails);
        try{
            List<Lead> lstLeadsToConvert = [Select Id,Email,ownerId from Lead where Email In : setLeadEmails and IsConverted =: false];
            List<Contact> lstContact = [Select Id, Email, AccountId from Contact where Email In : setLeadEmails];
            Map<string,contact> mapContactByEmail = new Map<string,contact>();
            Debug.log('Kickbox :: lstLeadsToConvert:: '+lstLeadsToConvert);
            Debug.log('Kickbox :: In ConvertLeads lstContact:: '+lstContact);
            for(Contact currentContact : lstContact){
                mapContactByEmail.put(currentContact.Email.toLowerCase(),currentContact);
            }
            for(Lead lead : lstLeadsToConvert){
                //Debug log added as per suggetion of Ash to track the Exception
                Debug.log('Before Update lstLeadsToConvert::lead Email==> '+lead.Email+'lead OwnerId==>'+lead.OwnerId);
                if(((String)lead.OwnerId).startsWith('00G')){
                    lead.OwnerId = UserInfo.getUserId();
                }
            }
            
            Debug.log('setLeadEmails::'+setLeadEmails);
            Debug.log('Leads before Update::'+lstLeadsToConvert);
            update lstLeadsToConvert;
            list<Database.LeadConvert> leadConvert = new list<Database.LeadConvert>();
            
            for(Lead lead : lstLeadsToConvert){
                //Debug log added as per suggetion of Ash to track the Exception
                Debug.log('After Update lstLeadsToConvert::lead Email==> '+lead.Email+'lead OwnerId==>'+lead.OwnerId);
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(lead.Id);
                lc.setAccountId(mapContactByEmail.get(lead.Email.toLowerCase()).AccountId);
                lc.setContactId(mapContactByEmail.get(lead.Email.toLowerCase()).Id);
                lc.setConvertedStatus('Qualified');
                lc.doNotCreateOpportunity = true;
                lc.overwriteLeadSource  = false;
                lc.setOwnerId(lead.OwnerId);
                leadConvert.add(lc);
            }
            List<Database.LeadConvertResult> lcr = Database.convertLead(leadConvert);
        } catch(Exception ex){
            //sendMailOnException(setLeadEmails,ex);
            List<String> emailIds = New List<String>();
            if(setLeadEmails!=null && setLeadEmails.size() > 0)
                emailIds.addAll(setLeadEmails);
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadConvertor','ConvertLeads',String.join(emailIds,','),ex)
            );
            throw new LeadConvertorException(ex.getMessage()); 
        }
    }
    
    //This method should be called whenever one or more leads are created
    /*
    Devoloped By: Hemanshu Shah
    Modified By: Amol Darekar
    Comment: This method is used to Generate Journey And Activity from lead if contact is not present and if contact present the it converts the lead 
    and transfer all journeys of lead to contact.
    */ 
    public static LeadResult[] ConvertLeadsToJourneys(Set<Id> setLeadIds,Boolean IsLeadFromWebsite){
        return ConvertLeadsToJourneysOverloaded(setLeadIds, IsLeadFromWebsite, true);
    }
    
    public static LeadResult[] ConvertLeadsToJourneysForEmailService(Set<Id> setLeadIds,Boolean IsCreateActivity){
        return ConvertLeadsToJourneysOverloaded(setLeadIds, false, IsCreateActivity);
    }
    
    public static LeadResult[] ConvertLeadsToJourneysOverloaded(Set<Id> setLeadIds,Boolean IsLeadFromWebsite, Boolean IsCreateActivity){
        Id campaignSFId ;
        Debug.log('IsLeadFromWebsite==>'+IsLeadFromWebsite);
        if(IsLeadFromWebsite){
            if(RESTInboundLead.inboundPayLoad != null && RESTInboundLead.inboundPayLoad.campaign_sfid != null && String.isNotBlank(RESTInboundLead.inboundPayLoad.campaign_sfid)){
                campaignSFId = RESTInboundLead.inboundPayLoad.campaign_sfid;
                String sobjectType = campaignSFId.getSObjectType().getDescribe().getName();
                if(!sobjectType.equalsIgnoreCase('Campaign')){
                    campaignSFId = null;
                }                
            }              
        }        
        Debug.log('campaignSFId==>'+campaignSFId);
        
        set<String> setLeadToConvertEmails = new set<String>();
        List<LeadResult> resultRet = new List<LeadResult>();
        set<string> setContactNotHavingAccount = new set<string>();
        set<string> setDuplicateLeadEmails = new set<string>();
        set<Id> setDupLeadIds = new set<Id>();
        
        objUnassignedNMDUSQueue = new Setting__c();
        objUnassignedNMDUSQueue = Settings.get('Unassigned NMD US Queue');
        objUnassignedNMDUSQueueData =new UnassignedNMDUSQueue();
        objUnassignedNMDUSQueueData = (UnassignedNMDUSQueue)JSON.deserialize(objUnassignedNMDUSQueue.Data__c, UnassignedNMDUSQueue.class);
        debug.log('objUnassignedNMDUSQueueData'+objUnassignedNMDUSQueueData);
        
        //ST-1715
        Setting__c updateJourneysOwnerSetting = Settings.get('UpdateJourneysOwner');
        Debug.log('updateJourneysOwnerSetting==>'+updateJourneysOwnerSetting);    
        Map<String,String> mapSettingData = (Map<String,String>)(JSON.deserialize(updateJourneysOwnerSetting.Data__c, Map<String,String>.class));
        integer iIndex = 0;
        //Prepare list of Leads and Leads Map
        Map<String, List<Lead>> mapLeadsByEmail = new Map<String,List<Lead>>();
        Map<Id,Lead> mapLeadsById = new Map<Id,Lead>();
        Map<Id,Id> mapLeadsWithIds = new Map<Id,Id>();
        Integer leadIndex = 0;
        list<lead> lstClonedLead = new list<lead>();
        try{
            Id entSolutionsTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
            Id partnershipTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partnership').getRecordTypeId();
            Lead[] leadsToBeProcessed = Database.Query('Select ' + String.join(getLeadFields(), ',') + ' From Lead Where Id in :setLeadIds and IsConverted = False and (Email !=\'\' or Email != NULL)');
            Debug.Log('Leads being Processed : ' + leadsToBeProcessed);
            
            //If lead is created through mass upload then we need to remove duplicate lead from list and id's from set
            if(leadsToBeProcessed != null && leadsToBeProcessed.size() > 1){               
                for(Lead currentLead : leadsToBeProcessed){
                    if(setDuplicateLeadEmails.contains(currentLead.Email.toLowerCase())){                       
                        setDupLeadIds.add(currentLead.Id);
                    }
                    else{
                        setDuplicateLeadEmails.add(currentLead.Email.toLowerCase());
                    }
                } 
                
            }else{
                //If lead is created and it is with duplicate email then it should not get fetch in case we aare fetching exesting lead.
                if(leadsToBeProcessed != null && leadsToBeProcessed.size() == 1){
                    setDupLeadIds.add(leadsToBeProcessed[0].Id);
                }
            } 
            
            for(Lead lead : leadsToBeProcessed){
                mapLeadsById.put(lead.Id, lead);
                if( !String.isBlank(lead.Email) ){
                    String strEmail = lead.Email.toLowerCase();
                    if( mapLeadsByEmail.containsKey(strEmail)){
                        mapLeadsByEmail.get(strEmail).add(lead);
                    } else {
                        mapLeadsByEmail.put(strEmail, new List<Lead>{lead});
                    }
                }
            }
            
            //Find existing contacts matching the emails sorted by CreatedDate desc so we will use latest contact.
            Set<String> leadEmails = mapLeadsByEmail.keySet();
            Contact[] contactsExisting = [Select Id, Email, AccountId, OwnerId, Owner.IsActive, createdDate, LeadSource, Lead_Source_Detail__c, Product_Line__c, Status__c From Contact Where Email in :leadEmails order by createdDate desc];
            Debug.log('Existing Contacts ==> ' + contactsExisting);
            
            Map<String,Contact> mapContactsExistingByEmail = new Map<String,Contact>();            
            List<Contact> contactsNew = new List<Contact>();
            Map<String,Contact> mapContactsByEmail = new Map<String,Contact>();
            Set<Id> setExistingLeadIds = new Set<Id>();
            Set<Id> setExistingContactIds = new Set<Id>();
            
            for(Contact contact : contactsExisting){
                if( !mapContactsByEmail.containsKey(contact.Email.toLowerCase())) {
                    mapContactsExistingByEmail.put(contact.Email.toLowerCase(), contact);
                    mapContactsByEmail.put(contact.Email.toLowerCase(), contact);
                    setExistingContactIds.add(contact.Id);
                }
                //Changes for lead conversion
                Debug.log('contact.AccountId==>'+contact.AccountId);
                if(contact.AccountId == null){
                    setContactNotHavingAccount.add(contact.Email.toLowerCase());
                } 
            }
            Debug.log('setContactNotHavingAccount==>'+setContactNotHavingAccount);
            
            /* 	Issue No. 		:		ST-1877 */
            /* 	Changes By. 	:		Milanjeet Singh */
            /* 	Modified Date 	:		17 March 2018 */
            /*  Commented By	: 		Milanjeet Singh */
            /* 	Description 	:		Is Owner is coming from Lead Assignment and its a queue, then no to need to assign the lead owner 
to Susie Romero and Its also worked same for Partnership form functionality*/
            /*************************************************************************************************************************************/
            /*List<Lead> lstLeadsToUpdate = new List<Lead>();
for(Lead lead : leadsToBeProcessed) {
if(!String.isBlank(lead.Email)){
String strLeadEmail = lead.Email.toLowerCase();
if(mapContactsByEmail != null && mapContactsByEmail.containsKey(strLeadEmail) ) {
debug.Log('mapContactsByEmail::----LeadTo be Processed' + mapContactsByEmail);
if(((String)lead.OwnerId).startsWith('00G')){
lead.OwnerId =UserInfo.getUserId();
//lead.OwnerId = String.valueOf(UserInfo.getUserId()).equalsIgnoreCase('005F0000003Kmbw')? (mapContactsByEmail.get(strLeadEmail).OwnerId):(lead.OwnerId);
lstLeadsToUpdate.add(lead);
}
}
}
}
Debug.log('lstLeadsToUpdate : Before' + lstLeadsToUpdate);
update lstLeadsToUpdate;
Debug.log('lstLeadsToUpdate : ' + lstLeadsToUpdate);*/
            /*************************************************************************************************************************************/
            
            Boolean leadUpdateFlag = false ,contactUpdateFlag = false;            
            //If lead owner is queue then update lead owner with current loggedin user id before conversion
            Map<String,Account> mapAccountsByName = new Map<String,Account>(); 
            //Create account for contact not having account and account Id to contact AccountId field. 
            List<Account> accountsNew = new List<Account>();
            
            for(String strEmail : setContactNotHavingAccount){ 
                accountsNew.add(accountFromLead(mapLeadsByEmail.get(strEmail)[0]));
            }
            if(accountsNew != null && accountsNew.size() >0){
                insert accountsNew;  
            }            
            for(Account account : accountsNew){
                mapAccountsByName.put(account.Name, account);
            }
            
            //Assign account Id to contact accountId and update contact required for conversion
            for(contact currentContact : contactsExisting){    
                if(!String.isBlank(currentContact.Email)){
                    if(currentContact.AccountId == null && mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0].company != null){
                        currentContact.AccountId = mapAccountsByName.get(mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0].company).Id;
                        contactUpdateFlag = true;
                    }  
                    else if(currentContact.AccountId == null){
                        string companyName = (string.isBlank((mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0]).FirstName+ ' ')?'':(mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0]).FirstName+' ') +''+(mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0]).LastName;
                        currentContact.AccountId = mapAccountsByName.get(companyName).Id;
                        contactUpdateFlag = true;
                    }
                }
            }
            
            Debug.Log('contactsExisting==> ' + contactsExisting);
            if(contactUpdateFlag == true){
                update contactsExisting; 
            }               
            
            //Check for existing lead
            set<string> setContactEmail = mapContactsByEmail.keySet();
            Map<String,Lead> mapExistingLeadsByEmail = new Map<String,Lead>();
            Lead[] leadsExisting =  Database.Query('Select ' + String.join(getLeadFields(), ',') + ' From Lead Where Email in :leadEmails And Email not in: setContactEmail And Id not in :setDupLeadIds AND isConverted=false ');//not in :setLeadIds 
            Debug.Log('Existing Leads ==>' + leadsExisting);
            
            for(Lead currentLead : leadsExisting){
                if(!String.isBlank(currentLead.Email)){ 
                    if(!mapExistingLeadsByEmail.containsKey(currentLead.Email.toLowerCase())){
                        mapExistingLeadsByEmail.put(currentLead.Email.toLowerCase(), currentLead);
                    }
                    else{
                        if(!setLeadIds.contains(currentLead.Id))
                            mapExistingLeadsByEmail.put(currentLead.Email.toLowerCase(), currentLead);
                    }        
                    setExistingLeadIds.add(currentLead.Id);
                }
            }
            Debug.Log('mapExistingLeadsByEmail==>' + mapExistingLeadsByEmail);
            
            List<Lead> leadsToBeDeleted = new List<Lead>();
            //Find if there are any open Journeys for given contacts
            Map<String,List<Journey__c>> mapJourneysByEmail = new Map<String,List<Journey__c>>();
            List<Journey__c> journeysToCreate = new List<Journey__c>();
            
            Map<Id,List<Task>> mapActivitys = new Map<Id,List<Task>>();
            //ST-638
            Date journeyDateDiff = system.today().addDays(-settingsJourney.ExistingJourneyCreatedDateDifference);
            Date journeyAssignmentCutOffDays = system.today().addDays(-settingsJourney.JourneyAssignmentCutOffDays);
            Debug.Log('test123'+settingsJourney);
            Journey__c[] journeysExisting = [Select Id, OwnerId, Status__c, Primary_Contact__c,Primary_Contact__r.Email, Primary_Lead__c, Primary_Lead__r.Email, CreatedDate, CampaignId__c From Journey__c Where Status__c =: settingsJourney.NewJourneyFields.get('Status__c') And (Primary_Contact__c IN :setExistingContactIds OR Primary_Lead__c IN : setExistingLeadIds) and createdDate >=: journeyAssignmentCutOffDays order by createdDate desc];           
            Debug.Log('journeysExisting :: '+journeysExisting); 
           
            
            Task[] lastActivity = [Select Id, WhoId, CreatedDate, LastmodifiedDate  From Task Where LastmodifiedDate = LAST_N_DAYS:60 AND (WhoId IN :setExistingContactIds OR WhoId IN : setExistingLeadIds) order by createdDate desc];               
            Debug.Log('lastActivity :: '+lastActivity); 
            
            if(lastActivity.size()>0 && lastActivity != null)
                for(Task activity : lastActivity){	            
                    if( mapActivitys.containsKey(activity.WhoId) ){
                        mapActivitys.get(activity.WhoId).add(activity);
                    }
                    else {
                        mapActivitys.put(activity.WhoId, new List<Task>{activity});
                    }
                }
            
            for(Journey__c journey : journeysExisting){
                String strEmail = null;
                if(journey.Primary_Contact__r != null)
                    strEmail = journey.Primary_Contact__r.Email.toLowerCase();
                else if(journey.Primary_Lead__r != null && !String.isBlank(journey.Primary_Lead__r.Email))//String.isBlank(journey.Primary_Lead__r.Email)
                    strEmail = journey.Primary_Lead__r.Email.toLowerCase();
                
                if( mapJourneysByEmail.containsKey(strEmail) ){
                    mapJourneysByEmail.get(strEmail).add(journey);
                }
                else {
                    mapJourneysByEmail.put(strEmail, new List<Journey__c>{journey});
                }
                
            }
            
            //Find list of Journeys which needs to be created, if there is no open Journey for given Contact
            List<Journey__c> journeysToUpsert = new List<Journey__c>();
            map<Integer,Journey__c> mapNullJourneys = new map<Integer,Journey__c>();
            map<Integer,Journey__c> mapJourneysBeforeUpsert = new map<Integer,Journey__c>();
            Integer mapIndex= 0;
            List<Task> activities = new List<Task>();
            set<string> setAllowedUsers = new set<string>();
            set<string> setAllowedQueues = new set<string>();
            
            //Get User and queue details for Journey Creation if owner Id record is in json & Lead Source and Lead Source Details Match then it will create Journey record.
            Setting__c settingsQueue = Settings.get('User/Queue Journey Creation');
            Debug.Log('User/Queue Journey Creation Setting ==> '+settingsQueue);
            
            if(settingsQueue != null){
                UserQueueJourneySettings objJourneyCreationsetting = (UserQueueJourneySettings)JSON.deserialize(settingsQueue.Data__c, UserQueueJourneySettings.class);
                set<Id> setUserId = new set<Id>();
                
                if(objJourneyCreationsetting != null){
                    string Ids;
                    for(AllowedUsersSettings currentUser:objJourneyCreationsetting.allowedUsers){
                        Ids = string.valueOf(currentUser.Id);
                        setAllowedUsers.add(Ids.subString(0,15));
                    }
                    
                    for(AllowedQueueSettings currentQueue:objJourneyCreationsetting.allowedQueues){
                        Ids = string.valueOf(currentQueue.Id);
                        setAllowedQueues.add(Ids.subString(0,15));
                    }
                    
                  
                    //Get Lead source and lead source details from JSON setting
                    settingsQueue = Settings.get('Lead:Lead and Lead Source Details');
                    Debug.log('Lead:Lead and Lead Source Details Settings> '+settingsQueue);
                    if(settingsQueue != null) {
                        map<String,set<String>> mapLeadSourceAndDetails = new map<String,set<String>>();
                        set<string> setLeadSource = new set<string>();
                        set<string> setLeadSourceDetails = new set<string>();
                        map<String,boolean> mapOverrideLeadSoruce = new map<String,boolean>();
                        LeadSoruceSettings setting = (LeadSoruceSettings)JSON.deserialize(settingsQueue.Data__c, LeadSoruceSettings.class);
                       
                        for(LeadSoruceValues currentLeadSource : setting.LeadSource) {
                            setLeadSource.add(currentLeadSource.name.toLowerCase());  
                            mapOverrideLeadSoruce.put(currentLeadSource.name.toLowerCase(),currentLeadSource.OverrideLeadSoruce);                            
                        }
                        
                        for(string currentLeadSourceDetails : setting.LeadSourceDetails) {
                            setLeadSourceDetails.add(currentLeadSourceDetails.toLowerCase());  
                        }
                        
                        map<String,List<Journey__c>> mapDuplicateJourneysByEmail = new map<String,List<Journey__c>>();
                        map<Id,Journey__c> mapExistingJourneyId = new map<Id,Journey__c>();
                        
                        for(Lead lead : leadsToBeProcessed) {
                            Journey__c journeyNew = null;
                            String strLeadEmail = '';
                            Boolean journeyFlag = true;
                            //If lead is created with recordtype enterprise solutions then do not create or update joureny.
                            //if( !String.isBlank(lead.Email)  && lead.RecordTypeId != entSolutionsTypeId) {
                            //Commented above to allow journey creation for all type of lead
                            if( !String.isBlank(lead.Email)) {
                                strLeadEmail = lead.Email.toLowerCase();                    
                                List<Journey__c> journeys = mapJourneysByEmail.get(strLeadEmail);
                                Debug.log('lead email for single lead ==> ' + strLeadEmail);
                                //Issue No. 	: ST-1277,ST-1350 : (Add By_Pass_Journey_Creation_Criteria__c)
                                //Changes By 	: Mayuresh Ghodke
                                //Date			: 28th Jul'17
                                //Comment 		: Apex : Journey : Change Journey Creation Criteria for Journey Importer
                                if(((setAllowedUsers.contains(string.valueOf(lead.OwnerId).subString(0,15)) || setAllowedQueues.contains(string.valueOf(lead.OwnerId).subString(0,15))) 
                                    && lead.LeadSource != null && setLeadSource.contains(lead.LeadSource.toLowerCase())
                                    && (mapOverrideLeadSoruce.get(lead.LeadSource.toLowerCase())
                                        || (lead.Lead_Source_Detail__c!= null && setLeadSourceDetails.contains(lead.Lead_Source_Detail__c.toLowerCase())))) || (lead.By_Pass_Journey_Creation_Criteria__c && lead.Generate_Journey__c ))
                                {
                                    Debug.log('lead.By_Pass_Journey_Creation_Criteria__c :: ' + lead.By_Pass_Journey_Creation_Criteria__c);
                                    Debug.log('lead.Generate_Journey__c :: ' + lead.Generate_Journey__c);
                                     Debug.log('journeys==> ' + journeys);
                                    if( journeys != null){
                                        for(Journey__c journey : journeys ) {
                                            //Changes of Journey Creation ST-630
                                            
                                            Debug.log('journey.CreatedDate :: ' + journey.CreatedDate);
                                            Debug.log('journeyDateDiff ' + journeyDateDiff);
                                            Debug.log('System.isBatch()==>'+System.isBatch());
                                            Debug.log('journey.CampaignId__c==>'+journey.CampaignId__c);
                                            Debug.log('lead.Kickbox_CampaignId__c==>'+lead.Kickbox_CampaignId__c);
                                            
                                            //If there is alredy Open Journey which has same OwnerId as Lead we need to reuse that journey
                                           
                                           
                                            DateTime currentDate = DateTime.valueOf(journey.CreatedDate);                                           
                                            Date journeyCreatedDate = Date.newinstance(currentDate.year(), currentDate.month(), currentDate.day());
                                            Debug.log('journeyCreatedDate==>'+journeyCreatedDate);
											/* Modified By Krishana Tupe for ST-2399 on 23 May 2018
											 * if(journey.CreatedDate >= journeyDateDiff)
                                            journeyNew = journey; */
                                            
                                            if(  ((System.isBatch() && lead.By_Pass_Journey_Creation_Criteria__c) || (lead.Lead_Source_Detail__c=='Marketing Landing Page' && String.isNotBlank(campaignSFId))) &&
                                               journeyCreatedDate >= System.today() &&     ((!System.isBatch() && journey.CampaignId__c == campaignSFId) || journey.CampaignId__c == lead.Kickbox_CampaignId__c)   ){
                                                Debug.log('Existing Journey Selected for Campaign ==>'+journey);
                                                journeyNew = journey;
                                            }else if( !System.isBatch() && String.isNotBlank(campaignSFId) && journeyCreatedDate >= System.today() && journey.CampaignId__c == campaignSFId ){
                                                Debug.log('Existing Journey Selected for Campaign for REST ==>'+journey);
                                                journeyNew = journey;
                                            }else if( ((System.isBatch() && String.isBlank(lead.Kickbox_CampaignId__c)) || (!System.isBatch() && String.isBlank(campaignSFId))) && journey.CreatedDate >= journeyDateDiff ){
                                                Debug.log('Existing Journey Selected without Campaign ==>'+journey);
                                                journeyNew = journey;
                                            }
                                            
                                            if(journeyNew != null ) {
                                                journeyNew.NMD_Next_Contact_Date__c = DateUtilities.addBusinessDays(Date.today(), settingsJourney.NextCallInDaysFromJourneyUpdation);
                                                journeyNew.Affiliate_Consent__c = lead.Affiliate_Consent__c;
                                                journeyNew.Marketing_Consent__c = lead.Marketing_Consent__c;
                                                journeyNew.Ts_and_Cs_Consent__c = lead.Ts_and_Cs_Consent__c;
                                                if(journeyNew.CampaignId__c == null)
                                                    //journeyNew.CampaignId__c = lead.Kickbox_CampaignId__c;
                                                    
                                                    //Changes for ST-1715 if existing journey owner id the owner given insettings and lead owner is different then update
                                                    //the Owner_SFID__c field on journey with new owner Id.
                                              Debug.log('JourneyOwnerChange lead.OwnerId==>'+lead.OwnerId);
                                                if((mapSettingData.get('ownerId') != null && (String.valueOf(journeyNew.OwnerId).substring(0,15)).equalsIgnoreCase(String.valueOf(mapSettingData.get('ownerId')).substring(0,15)))
                                                   && !(String.valueOf(lead.OwnerId).substring(0,15).equalsIgnoreCase(String.valueOf(mapSettingData.get('ownerId')).substring(0,15)))) 
                                                    journeyNew.Owner_SFID__c = lead.ownerId;
                                                Debug.log('journeyNew.Owner_SFID__c ==>'+journeyNew.Owner_SFID__c);
                                                Debug.log('mapContactsByEmail ====>'+mapContactsByEmail);
                                                //Added by : Krishana
                                                //Date     : 29/12/2017
                                                //Purpose  : If contact exists and its owner is not API user, we need to update OwnerSFID of journey to update journey owner
                                                if((mapSettingData.get('ownerId') != null && (String.valueOf(journeyNew.OwnerId).substring(0,15)).equalsIgnoreCase(String.valueOf(mapSettingData.get('ownerId')).substring(0,15)))
                                                   && mapContactsByEmail.get(lead.Email) != null && !(String.valueOf(mapContactsByEmail.get(String.valueof(lead.Email)).ownerId).substring(0,15).equalsIgnoreCase(String.valueOf(mapSettingData.get('ownerId')).substring(0,15)))) 
                                                    journeyNew.Owner_SFID__c = mapContactsByEmail.get(String.valueof(lead.Email)).ownerId;                                                
                                                Debug.Log('mapSettingData.get'+mapSettingData.get('ownerId'));
                                                /*
* Purpose  : If contact exists and its owner is  API user, we need to update the owner of exsting open jorneys which are created within 4 (ettingsJourney.ExistingJourneyCreatedDateDifference  days)days .
*  1) if lead is coming from website then exsting journey owner will be unassigned NMD US Queue
*  2) if lead is coimng from other than wesite then owner of exsiting journey will be LogedIn user.  
* //check lead is coming from website
*/
                                                /*if((String.valueOf(journeyNew.OwnerId).substring(0,15)).equalsIgnoreCase(String.valueOf(mapSettingData.get('ownerId')).substring(0,15)) &&
mapContactsByEmail.get(lead.Email) != null && 
(String.valueOf(mapContactsByEmail.get(String.valueof(lead.Email)).ownerId).substring(0,15).equalsIgnoreCase(String.valueOf(mapSettingData.get('ownerId')).substring(0,15))) &&
String.valueOf(userinfo.getUserId().substring(0,15)).equalsIgnoreCase(string.valueOf(mapSettingData.get('ownerId')).substring(0,15)) )
{	
debug.Log('inside if trueee');
journeyNew.OwnerId = objUnassignedNMDUSQueueData.UnassignedNMDUSQueue[0]; 
}*/
                                                
                                                break;
                                            }
                                        }
                                    }
                                }
                                //else if
                                if(leadsToBeProcessed != null && leadsToBeProcessed.size() > 1){
                                    strLeadEmail = lead.Email.toLowerCase();
                                    Debug.log('lead email:: ' + strLeadEmail);
                                    //Prevent creating jounrey for leads with same email if condition satisfy
                                    if(journeys == null){
                                        journeys = mapDuplicateJourneysByEmail.get(strLeadEmail); 
                                    }else{
                                        Boolean tempReplaceJourney = true;
                                        list<Journey__c> lstTempJourney = mapDuplicateJourneysByEmail.get(lead.Email.toLowerCase());
                                        if(lstTempJourney != null && journeys!=null){
                                            for(Journey__c journey:journeys) {
                                                if(!tempReplaceJourney)
                                                    break;
                                                for(Journey__c currentJourney : lstTempJourney){
                                                    if((currentJourney !=null && journey !=null) && (currentJourney.ownerId == journey.ownerId)){
                                                        tempReplaceJourney = false;
                                                    }
                                                }
                                            }
                                            if(tempReplaceJourney){
                                                journeys.clear();
                                                journeys.addAll(lstTempJourney);
                                            }
                                        }
                                    }
                                    
                                    if( journeys != null && journeys.size() > 0){
                                        for(Journey__c journey : journeys ) {
                                            //Changes of Journey Creation ST-630
                                            //If there is alredy Open Journey which has same OwnerId as Lead we need to reuse that journey
                                            journeyFlag = false;
                                            break;                                            
                                        }
                                    }
                                }
                            }
                            
                            Debug.log('contact for journeyNew==>'+journeyNew);
                            Contact contact = mapContactsByEmail.get(lead.Email.toLowerCase());
                            Debug.log('contact==> '+contact);  
                            Lead leadExisting = mapExistingLeadsByEmail.get(lead.Email.toLowerCase());
                            Debug.log('mapExistingLeadsByEmail 938==> ' + mapExistingLeadsByEmail);
                            Debug.log('leadExisting==> ' + leadExisting);                          
                            Debug.log('journeyNew==>'+journeyNew);
                            Debug.log('lead.RecordTypeId ==>'+lead.RecordTypeId);
                            Debug.log('entSolutionsTypeId==>'+entSolutionsTypeId);
                            
                            //If lead is created with recordtype enterprise solutions then do not create or update joureny.
                            //if( journeyNew == null && lead.RecordTypeId != entSolutionsTypeId) {
                            //Commented above to allow journey creation for all type of lead
                            if(journeyNew == null) {
                                string leadOwnerId = string.valueOf(lead.OwnerId);
                                Debug.log('leadOwnerId: lead ==>'+lead);
                                leadOwnerId = leadOwnerId.subString(0,15);
                                Debug.log('setAllowedUsers :'+setAllowedUsers);
                                Debug.log('setAllowedQueues :'+setAllowedQueues);                                
                                
                                //Check existing lead/contact created date is greter than equals date diff provided in settings against contact created date
                                //and also check for lead source and details condition
                                //ST-653
                                Boolean existingLeadJourneyCreation = false,existingContactJourneyCreation = false, existingJourneyBeforeXDays = false, journeyCreatedInYDays = false;
                                Debug.log('Test : leadExisting ::: ' + leadExisting);
                                Debug.log('Test : journeyAssignmentCutOffDays ::: ' + journeyAssignmentCutOffDays);
                                Debug.log('Test : setLeadSource ::: ' + setLeadSource);
                                Debug.log('Test : mapOverrideLeadSoruce ::: ' + mapOverrideLeadSoruce);
                                Debug.log('Test : setLeadSourceDetails ::: ' + setLeadSourceDetails);
                                Debug.log('Test :  contact::: '+contact); 
                                
                                if(contact != null || leadExisting != null){
                                    Journey__c[] journeyWithExisitingLeadOrContacts = new List<Journey__c>();
                                    if(contact != null)
                                        journeyWithExisitingLeadOrContacts  = mapJourneysByEmail.get(contact.Email.toLowerCase());
                                    else
                                        journeyWithExisitingLeadOrContacts = mapJourneysByEmail.get(leadExisting.Email.toLowerCase());
                                    
                                    Journey__c journeyWithExisitingLeadOrContact = journeyWithExisitingLeadOrContacts != null ? journeyWithExisitingLeadOrContacts[0] : null;
                                    Debug.log('New lead 976 ==>'+lead);
                                    Debug.log('Existing lead 977 ==>'+leadExisting);
                                    Debug.log('System Batch ==>'+System.isBatch());
                                    Debug.log('journeyWithExisitingLeadOrContact.CreatedDate ==>'+journeyWithExisitingLeadOrContact );                                
                                                                                                         
                                    Debug.log('journeyDateDiff==>'+journeyDateDiff);
                                   // &&  ((String.isNotBlank(lead.Kickbox_CampaignId__c)|| String.isNotBlank(campaignSFId)) && (journeyWithExisitingLeadOrContact.CampaignId__c != lead.Kickbox_CampaignId__c || campaignSFId !=  lead.Kickbox_CampaignId__c))
                                    
                                    /* Modified by Krishana Tupe for St-2399 on 23 May 2018 */
                                    if(journeyWithExisitingLeadOrContact != null && (  (((System.isBatch() && lead.By_Pass_Journey_Creation_Criteria__c) || (lead.Lead_Source_Detail__c=='Marketing Landing Page' && String.isNotBlank(campaignSFId)) )  && journeyWithExisitingLeadOrContact.CreatedDate <= System.today() ) || journeyWithExisitingLeadOrContact.CreatedDate <= journeyDateDiff) ){
                                        existingJourneyBeforeXDays = true;  
                                    }                                        
                                    if(existingJourneyBeforeXDays && journeyWithExisitingLeadOrContact.CreatedDate >= journeyAssignmentCutOffDays){
                                        journeyCreatedInYDays = true;
                                    }
                                    Debug.log('New lead==>'+lead);
                                    Debug.log('Existing lead==>'+leadExisting);
                                    Debug.log('Test : existingJourneyBeforeXDays ::: ' + existingJourneyBeforeXDays);	
                                    Debug.log('Test : journeyCreatedInYDays ::: ' + journeyCreatedInYDays);	
                                }
                                
                                if((setAllowedUsers.contains(leadOwnerId) || setAllowedQueues.contains(leadOwnerId)) 
                                   && lead.LeadSource != null && setLeadSource.contains(lead.LeadSource.toLowerCase())
                                   && (mapOverrideLeadSoruce.get(lead.LeadSource.toLowerCase())
                                       || (lead.Lead_Source_Detail__c!= null && setLeadSourceDetails.contains(lead.Lead_Source_Detail__c.toLowerCase()))))
                                {
                                    Debug.log('Test :  Inside Exisiting::: ');	
                                    Debug.log('Test :  contact::: '+contact);  
                                    if(contact != null && contact.createdDate >= journeyAssignmentCutOffDays
                                       && setAllowedUsers.contains(string.valueOf(contact.OwnerId).subString(0,15))){
                                           existingContactJourneyCreation = true;
                                       }
                                    else if(leadExisting !=null && leadExisting.createdDate >= journeyAssignmentCutOffDays
                                            && setAllowedUsers.contains(string.valueOf(leadExisting.OwnerId).subString(0,15))){
                                                existingLeadJourneyCreation = true;
                                            }
                                }
                                Debug.log('lead ::'+lead);	
                                //(existingContactJourneyCreation || existingLeadJourneyCreation) || 
                                Debug.log('Test : existingContactJourneyCreation ::: ' + existingContactJourneyCreation);
                                Debug.log('Test : existingLeadJourneyCreation ::: ' + existingLeadJourneyCreation);
                                Debug.log('Test : journeyFlag ::: ' + journeyFlag);
                                Debug.log('Test : (existingContactJourneyCreation || existingLeadJourneyCreation && journeyFlag) ::: ' + (existingContactJourneyCreation || existingLeadJourneyCreation && journeyFlag));
                                if(((existingContactJourneyCreation || existingLeadJourneyCreation && journeyFlag) || ( (setAllowedUsers.contains(leadOwnerId) || setAllowedQueues.contains(leadOwnerId)) 
                                                                                                                       && lead.LeadSource != null  
                                                                                                                       && setLeadSource.contains(lead.LeadSource.toLowerCase()) 
                                                                                                                       && (mapOverrideLeadSoruce.get(lead.LeadSource.toLowerCase()) || (lead.Lead_Source_Detail__c!= null && setLeadSourceDetails.contains(lead.Lead_Source_Detail__c.toLowerCase()))) 
                                                                                                                       && journeyFlag)) || (lead.By_Pass_Journey_Creation_Criteria__c && lead.Generate_Journey__c))
                                {
                                    //if(leadExisting == null || (leadExisting != null && leadExisting.RecordTypeId != entSolutionsTypeId))
                                    Debug.log('kickbox lead ::'+lead);
                                    Debug.log('kickbox lead.Check_Duplicates__c ::'+lead.Check_Duplicates__c);
                                    Debug.log('kickbox lead.Generate_Journey__c ::'+lead.Generate_Journey__c);
                                    //To check filter kickbox verified Leads which dont have Generate Journey
                                    if((lead.Check_Duplicates__c && lead.Generate_Journey__c)
                                       || (!lead.Check_Duplicates__c && !lead.Generate_Journey__c) 
                                       || (!lead.Check_Duplicates__c && lead.Generate_Journey__c)){
                                           Debug.log('kickbox lead ::'+lead);
                                           Debug.log('kickbox leadExisting ::'+leadExisting);
                                           //Debug.log('kickbox leadExisting.RecordTypeId  ::'+leadExisting.RecordTypeId );
                                           if((leadExisting != null && leadExisting.RecordTypeId != entSolutionsTypeId) || leadExisting == null){ 
                                               //New:If Existing lead not null then set journey ownerId to existing lead ownerId.
                                               //ST-653
                                               if(leadExisting !=null){   
                                                   Debug.log('leadExisting :: '+leadExisting);
                                                   Debug.log('lead.By_Pass_Journey_Creation_Criteria__c :: '+lead.By_Pass_Journey_Creation_Criteria__c);
                                                   Debug.log('mapActivitys.containsKey(leadExisting.Id) :: '+mapActivitys.containsKey(leadExisting.Id));
                                                   Debug.log('mapActivitys :: '+mapActivitys);
                                                   //ST-1350 //Last activity on the lead/contact is 90 days or older
                                                   /* Modified by Krishana Tupe for ST-2399 on 23 May 2018 */
                                                   if(lead.By_Pass_Journey_Creation_Criteria__c == false || ( lead.Generate_Journey__c == true && lead.By_Pass_Journey_Creation_Criteria__c == true && (String.isNotBlank(campaignSFId) || ( String.isNotBlank(lead.Kickbox_CampaignId__c) && (leadExisting.Kickbox_CampaignId__c != lead.Kickbox_CampaignId__c)) || !mapActivitys.containsKey(leadExisting.Id) ) )){
                                                       //to get new Journey from Lead.
                                                       journeyNew = journeyFromLead(lead,leadExisting.ownerId,contact,existingContactJourneyCreation,existingLeadJourneyCreation, mapJourneysByEmail, journeyCreatedInYDays, mapSettingData.get('ownerId'));
                                                       //ST-717
                                                       if(leadExisting.RecordTypeId == partnershipTypeId)
                                                           journeyNew.UserType__c = 'Partnership';
                                                       else if(!journeyCreatedInYDays && lead.RecordTypeId == partnershipTypeId){
                                                           journeyNew.UserType__c = 'Partnership';
                                                       }
                                                       /* ST-2399 Start, Modified by Krishana Tupe for ST-2399 on 23 May 2018 */
                                                       journeyNew.Lead_Source__c = lead.LeadSource;                                                       
                                                       if(String.isNotBlank(lead.Kickbox_CampaignId__c)){
                                                           journeyNew.CampaignId__c = lead.Kickbox_CampaignId__c;
                                                       }else if(String.isNotBlank(campaignSFId)){
                                                           //journeyNew.CampaignId__c = campaignSFId;  
                                                       }
                                                       /* ST-2399 End */
                                                   }
                                               }
                                               else {
                                                   Debug.log('If-Else Contact Exist===>');
                                                   Debug.log('contact 1035 :: '+contact);
                                                   Debug.log('lead==>: '+lead);
                                                   Debug.log('System.isBatch()==>'+System.isBatch());
                                                   Debug.log('mapActivitys==>'+mapActivitys);
                                                   //ST-1350 //Last activity on the lead/contact is 90 days or older//Member is not active. (Contact: Status: not equal to active)                                                  
                                                   /* Modified by Krishana Tupe for ST-2399 on 23 May 2018 */
                                                   if(lead.By_Pass_Journey_Creation_Criteria__c == false || (contact == null && lead.By_Pass_Journey_Creation_Criteria__c == true && lead.Generate_Journey__c == true) || (contact != null && lead.By_Pass_Journey_Creation_Criteria__c == true && lead.Generate_Journey__c == true && contact.Status__c.toLowerCase() == 'inactive' && ( ( (System.isBatch() && String.isNotBlank(lead.Kickbox_CampaignId__c)) || (!System.isBatch() && String.isNotBlank(campaignSFId)) ) || !mapActivitys.containsKey(contact.Id)) )){
                                                       journeyNew = journeyFromLead(lead,null,contact,existingContactJourneyCreation,existingLeadJourneyCreation, mapJourneysByEmail, journeyCreatedInYDays, mapSettingData.get('ownerId'));
                                                       //ST-717
                                                       if(lead.RecordTypeId == partnershipTypeId){
                                                           journeyNew.UserType__c = 'Partnership';
                                                       }                                                           
                                                       /* ST-2399 Start, Modified by Krishana Tupe for ST-2399 on 23 May 2018 */
                                                       journeyNew.Lead_Source__c = lead.LeadSource;
                                                       if(String.isNotBlank(lead.Kickbox_CampaignId__c)){
                                                           journeyNew.CampaignId__c = lead.Kickbox_CampaignId__c;
                                                       }else if(String.isNotBlank(campaignSFId)){
                                                         //  journeyNew.CampaignId__c = campaignSFId;  
                                                       }
														/* ST-2399 End */                                                       
                                                   }
                                                   Debug.log('Journey For New Lead==>'+journeyNew);
                                               }
                                               Debug.log('journeyNew for date::'+journeyNew);
                                               Boolean tempDupJourneyFlag = true;
                                               //mapDuplicateJourneysByEmail is use for prevent creating multiple journeys for lead with same email
                                               if(!mapDuplicateJourneysByEmail.containsKey(lead.Email.toLowerCase()))
                                                   mapDuplicateJourneysByEmail.put(lead.Email.toLowerCase(),new List<Journey__c> {journeyNew});
                                               else {
                                                   list<Journey__c> lstTempJourney = mapDuplicateJourneysByEmail.get(lead.Email.toLowerCase());
                                                   Debug.log('list temp journey::'+lstTempJourney);
                                                   for(Journey__c currentJourney : lstTempJourney){
                                                       if((currentJourney != null && journeyNew !=null) && currentJourney.ownerId == journeyNew.ownerId)
                                                           tempDupJourneyFlag = false;
                                                   }
                                                   if(tempDupJourneyFlag)
                                                       mapDuplicateJourneysByEmail.get(lead.Email.toLowerCase()).add(journeyNew);
                                               } 
                                           }
                                       }
                                    
                                }
                                
                                if(contact != null){
                                    Debug.log('Test :  contact::: 1069==>'+contact);  
                                    if(journeyNew != null)
                                        journeyNew.Primary_Contact__c = contact.Id;
                                    //New Requirement if contact exist with same email use existing contact and convert the lead
                                    if(mapContactsByEmail.containsKey(lead.Email.toLowerCase()) ) {
                                        setLeadToConvertEmails.add(lead.Email.toLowerCase());// ConvertLead(lead,contact,settingsJourney.ConvertedLeadStatus);
                                    }
                                    Debug.log('Test :  setLeadToConvertEmails::: '+setLeadToConvertEmails);  
                                    //leadsToBeDeleted.add(lead);
                                }
                                else if(leadExisting != null) {
                                    Debug.log('Test : leadExisting before delete 1080 ::: '+leadExisting);
                                    Debug.log('Test : lead ::: '+lead);
                                    if(journeyNew!=null)
                                        journeyNew.Primary_Lead__c = leadExisting.Id;
                                    //If Lead with same Email already exists delete lead being processed
                                    //In case of mass upload do not delete lead with unique email id
                                    if(leadExisting.Id !=  lead.Id)
                                        leadsToBeDeleted.add(lead);
                                }
                                else if(journeyNew != null)
                                    journeyNew.Primary_Lead__c = lead.Id;
                            }
                            else {    //If lead is of type enterprise solution the control will come here
                                Debug.log('leadExisting else::'+leadExisting);
                                if(contact != null)
                                    setLeadToConvertEmails.add(lead.Email.toLowerCase());//ConvertLead(lead,contact,settingsJourney.ConvertedLeadStatus);
                                else if(leadExisting != null && leadExisting.Id != lead.Id)//if in case of mass upload if lead email id is unique then it should not be deleted
                                    leadsToBeDeleted.add(lead);
                                Debug.log('leadsToBeDeleted else::'+leadsToBeDeleted);
                            }
                            
                            if(journeyNew != null) {
                                //In case duplicate lead comes in mass upload then it will check if journey already not get added in 
                                //JourneysToUpsert becasue if we can not update same journey twice. 
                                if(journeyNew.Id == null || (journeyNew.Id != null && !mapExistingJourneyId.containsKey(journeyNew.Id))){
                                    journeysToUpsert.add(journeyNew);
                                    if(journeyNew.Id != null){
                                        mapExistingJourneyId.put(journeyNew.Id,journeyNew);
                                        mapJourneysBeforeUpsert.put(mapIndex,journeyNew);
                                    }
                                    else
                                        mapJourneysBeforeUpsert.put(mapIndex,journeyNew);
                                }
                                else {
                                    //mapExistingJourneyId.put(journeyNew.Id,journeyNew);
                                    mapNullJourneys.put(mapIndex,null);
                                }
                                
                            }
                            else {
                                mapNullJourneys.put(mapIndex,journeyNew);
                            }
                            mapIndex++;
                        }//End leadToBeProcessed for journey creation
                        
                        
                        Debug.log('Journeys To Upsert: ' + journeysToUpsert);
                        if(journeysToUpsert.size() >0)
                            upsert journeysToUpsert;
                        Debug.log('Lead converter Journeys To Upsert: ' + journeysToUpsert);
                        /*
                        * Author : Sunil B.
                        * Date   : 02 April 2018 
                        * Description  : 'insertCampaignMember' is used to create campaign member.  
                        */
                       // RESTInboundLead.insertCampaignMember();
                        
                        for(Integer currentIndex : mapJourneysBeforeUpsert.keySet()){
                            mapNullJourneys.put(currentIndex,journeysToUpsert[iIndex]);
                            iIndex++;
                        }
                        
                        journeysToUpsert = mapNullJourneys.values();
                        iIndex = 0;
                        Debug.log('Test : IsCreateActivity ::: ' + IsCreateActivity);
                        if(IsCreateActivity){
                            Debug.log('leadsToBeProcessed : ' + leadsToBeProcessed);
                            for(Lead lead : leadsToBeProcessed) {
                                Contact contact = null;
                                Lead leadExisting;
                                Task task;
                                if(!String.isBlank(lead.Email)) {
                                    String strEmail = lead.Email.toLowerCase();
                                    contact = mapContactsByEmail.get(strEmail);
                                    leadExisting = mapExistingLeadsByEmail.get(lead.Email.toLowerCase());
                                }
                                
                                if(leadExisting == null || (leadExisting != null && leadExisting.Id == lead.Id))
                                    task = activityFromLead(lead, contact, journeysToUpsert[iIndex],IsLeadFromWebsite);
                                else
                                    task = activityFromExistingLead(lead, leadExisting, contact, journeysToUpsert[iIndex],IsLeadFromWebsite);
                                
                                Debug.log('task To Insert: ' + task);
                                activities.add(task);
                                ++iIndex;
                            }
                            
                            Debug.log('Activities To Insert: ' + activities);
                            //Insert activities
                            upsert activities;
                        }
                        
                        iIndex = 0;
                        //If isLeadsFromKickbox flag is true then we call convert lead method directly.
                        Boolean isLeadsFromKickbox = false;
                        for(Lead lead : leadsToBeProcessed) {
                            if(!isLeadsFromKickbox && lead.Check_Duplicates__c)
                                isLeadsFromKickbox = true;
                            
                            LeadResult result = new LeadResult();
                            if( !String.isBlank(lead.Email)) {
                                String strEmail = lead.Email.toLowerCase();
                                Contact contact = mapContactsByEmail.get(strEmail);
                                if(contact != null) {
                                    result.ContactId = contact.Id;
                                    result.ProductLine = contact.Product_Line__c;
                                }
                                Lead leadExisting = mapExistingLeadsByEmail.get(strEmail);
                                if(leadExisting != null) {
                                    result.LeadId = leadExisting.Id;
                                    result.ProductLine = Lead.Product_Line__c;
                                }
                                else{
                                    result.LeadId = Lead.Id;
                                    result.ProductLine = Lead.Product_Line__c;
                                }
                            }
                            
                            if(IsCreateActivity){
                                result.ActivityId = activities[iIndex].Id;
                                if(journeysToUpsert[iIndex] != null)
                                    result.JourneyId = journeysToUpsert[iIndex].Id;
                            }
                            
                            if(journeysToUpsert[iIndex] != null)
                                result.JourneyId = journeysToUpsert[iIndex].Id;
                            
                            result.NumberOfDesks = lead.number_of_desks_2016__c;
                            result.BuildingId = lead.building_interested_in__c;
                            result.CompanySize = lead.Company_Size__c;
                            Debug.log('Result::'+result);
                            resultRet.add(result);
                            ++iIndex;
                        }
                        
                        //ST-740
                        LeadConvertor.createProductInterest(resultRet,journeyDateDiff);
                        
                        //IF Lead is creted throung RESTInboundLead then for conversion of lead it will call future method for conversion
                        //Else if Lead is created and ConvertLead function call from Lead Triggers then it will call ConvertLeads directly 
                        //because from future method we can not call future method again.
                        if(setLeadToConvertEmails != null && setLeadToConvertEmails.size() > 0 && !Test.isRunningTest() && IsLeadFromWebsite ){ 
                            debug.log('FutureConvertLeads calling From 1215==>'+setLeadToConvertEmails);
                            LeadConvertor.FutureConvertLeads(setLeadToConvertEmails);
                        }else if(setLeadToConvertEmails != null && setLeadToConvertEmails.size() > 0){
                            if(!Test.isRunningTest() && !isLeadsFromKickbox){
                                ID convertJobID = System.enqueueJob(new QueueableClass(setLeadToConvertEmails));
                                Debug.log('convertJobID::'+convertJobID);
                            }
                            else{
                                Debug.Log('Kickbox :: setLeadToConvertEmails :: '+setLeadToConvertEmails);
                                LeadConvertor.ConvertLeads(setLeadToConvertEmails); 
                            }
                            //LeadConvertor.ConvertLeads(setLeadToConvertEmails); 
                        }
                        Debug.log('leadsToBeDeleted::'+leadsToBeDeleted);
                        if(leadsToBeDeleted != null && leadsToBeDeleted.size()>0){
                            delete leadsToBeDeleted;
                        }
                    }//Lead:Lead and Lead Source Details end
                }
            }
            return resultRet;
            
        }catch(Exception ex) {  
            Debug.log('Lead Convertot Exception ==>'+ex);
            Debug.log('Lead Convertot Exception Line Number ==>'+ex.getLineNumber());           
            if(RESTInboundLead.sp!=null)  
                Database.rollback(RESTInboundLead.sp);
            List<String> emailIds = New List<String>();
            if(mapLeadsByEmail.keyset()!=null && mapLeadsByEmail.size() > 0)
                emailIds.addAll(mapLeadsByEmail.keyset());
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadConvertor','ConvertLeadsToJourneysOverloaded',String.join(emailIds,','),ex)
            );
            throw new LeadConvertorException(ex.getMessage());  
        }
        
    }
    
    /*
    Comment   : This method is use to convert leads to contact and account if contact is not exist.   
    Author    : Amol Darekar 
    Date      : 28 June 2016 
    Issue	  : ST-450*/
    public static ContactResult[] ConvertLeadsToContact(list<string> lstContactEmails){
        Debug.log('In ConvertLeadsToContact===>');
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Lead> mapLeadsById = new Map<Id,Lead>();
        Map<String,Contact> mapContactsByEmail = new Map<String,Contact>();
        Map<String, List<Lead>> mapLeadsByEmail = new Map<String,List<Lead>>();
        set<string> setContactNotHavingAccount = new set<string>();
        list<string> lstEmails = new list<string>();
        //list<contact> lstContactNotHavingAccount = new list<contact>();
        List<ContactResult> resultRet = new List<ContactResult>();
        try{            
            for(String currentEmail : lstContactEmails){
                if(!String.isBlank(currentEmail))
                    lstEmails.add(currentEmail);
            }
            
            if(lstEmails == null || lstEmails.size() == 0)
                return null;
            
            Contact[] contactsExisting = [Select Id, Email, OwnerId, AccountId, LeadSource From Contact Where Email in :lstEmails Order by CreatedDate desc];
            if(contactsExisting !=null && contactsExisting.size()>0){
                for(Contact contact : contactsExisting){
                    contactIds.add(contact.Id);
                    Debug.log('contact.AccountId::'+contact.AccountId);
                    if( !mapContactsByEmail.containsKey(contact.Email.toLowerCase())) {
                        mapContactsByEmail.put(contact.Email.toLowerCase(), contact);
                    }
                    if(contact.AccountId == null){
                        setContactNotHavingAccount.add(contact.Email.toLowerCase());
                        //lstContactNotHavingAccount.add(contact);
                    }  
                }
            }            
            Debug.log('Contact lstEmails::'+lstEmails);
            //Debug.log('Existing leads with contact\'s email :: ' + [SELECT Id, Email, isConverted FROM Lead]);
            Lead[] leadsToBeProcessed = Database.Query('Select ' + String.join(getLeadFields(), ',') + ' From Lead Where Email in :lstEmails and isConverted = false');  
            Debug.log('leadsToBeProcessed::'+leadsToBeProcessed);
            
            if(leadsToBeProcessed!=null && leadsToBeProcessed.size()>0){      	
                for(Lead lead : leadsToBeProcessed){
                    mapLeadsById.put(lead.Id, lead);
                    if( mapLeadsByEmail.containsKey(lead.Email)){
                        mapLeadsByEmail.get(lead.Email.toLowerCase()).add(lead);
                    }
                    else {
                        mapLeadsByEmail.put( lead.Email.toLowerCase(), new List<Lead>{lead});
                    }
                }       
                
                //Set of company name of lead
                Set<String> leadEmails = mapLeadsByEmail.keySet();
                set<string> setLeadsCompany = new set<string>();
                
                for(String strEmail : leadEmails) {
                    strEmail = strEmail.toLowerCase();
                    setLeadsCompany.add((mapLeadsByEmail.get(strEmail.toLowerCase())[0]).company);
                    
                }
                
                //Create account which do not already exist 
                List<Account> accountsNew = new List<Account>();
                for(String strEmail : setContactNotHavingAccount){ 
                    accountsNew.add(accountFromLead(mapLeadsByEmail.get(strEmail)[0]));
                }
                Debug.log('Test : accountsNew ::: ' + accountsNew);
                insert accountsNew;
                
                //Add newly created accounts to map
                Map<String,Account> mapAccountsByName = new Map<String,Account>();
                for(Account account : accountsNew){
                    mapAccountsByName.put(account.Name, account);
                }
                
                //Assign account Id to contact and update the contact
                
                if(contactsExisting.size() > 0){
                    for(contact currentContact : contactsExisting){
                        Debug.log('currentContact::'+currentContact);
                        if(currentContact.AccountId == null && mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0].company != null)
                            currentContact.AccountId = mapAccountsByName.get(mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0].company).Id;  
                        else if(currentContact.AccountId == null){
                            string companyName = (string.isBlank((mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0]).FirstName+ ' ')?'':(mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0]).FirstName+' ') +''+(mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0]).LastName;
                            currentContact.AccountId = mapAccountsByName.get(companyName).Id; 
                        }   
                    }
                    Debug.log('Test : Line Number ::: ' + contactsExisting);
                    update contactsExisting;
                    for(Contact contact : contactsExisting){
                        mapContactsByEmail.put(contact.Email.toLowerCase(), contact);
                    }
                }
                
                //Put contact with account Id                
                List<Journey__c> newJourneys = new List<Journey__c>();
                
                Map<String,Journey__c> mapEmailsToJourney = new Map<String,Journey__c>(); 
                
                //Find if there are any Journeys for given contacts or lead
                
                Map<String,List<Journey__c>> mapJourneysByEmail = new Map<String,List<Journey__c>>();
                
                Journey__c[] journeys = [Select Id, Primary_Lead__c, Primary_Contact__c,Primary_Contact__r.Email, Primary_Lead__r.Email, Status__c, OwnerId From Journey__c Where Primary_Lead__c in :mapLeadsById.keySet()];
                
                for(Journey__c journey : journeys) {
                    String strEmail = null;
                    if(journey.Primary_Contact__r != null)
                        strEmail = journey.Primary_Contact__r.Email.toLowerCase();
                    else if(journey.Primary_Lead__r != null && !String.isBlank(journey.Primary_Lead__r.Email))//String.isBlank(journey.Primary_Lead__r.Email)
                        strEmail = journey.Primary_Lead__r.Email.toLowerCase();
                    
                    if( mapJourneysByEmail.containsKey(strEmail) ){
                        mapJourneysByEmail.get(strEmail).add(journey);
                    }
                    else {
                        mapJourneysByEmail.put(strEmail, new List<Journey__c>{journey});
                    }
                }          
                
                map<string,Journey__c> mapContactWithOpenJourneys = new map<string,Journey__c>();
                
                //assign all journeys of lead to contact
                for(string strLeadEmail : mapLeadsByEmail.keySet()){
                    list<Journey__c> lstAllJourneys = mapJourneysByEmail.get(strLeadEmail);
                    
                    string contactId = mapContactsByEmail.get(strLeadEmail).Id;
                    
                    string ownerId = mapContactsByEmail.get(strLeadEmail).ownerId;
                    
                    if(lstAllJourneys != null){
                        for(Journey__c currnetJourney : lstAllJourneys){
                            if(currnetJourney.Primary_Lead__c != null){
                                currnetJourney.Primary_Lead__c = null;
                                currnetJourney.Primary_Contact__c = contactId;
                                if(((String)currnetJourney.OwnerId).startsWith('00G')){
                                    currnetJourney.OwnerId = UserInfo.getUserId();
                                }
                                newJourneys.add(currnetJourney); 
                            }
                        }
                    }
                }
                
                upsert newJourneys;
                
                list<Product_Interested__c> lstProductInterestToBeUpdated = new list<Product_Interested__c>();
                
                //Change Lead lookup to contact lookup for Product Interested object for lead and also update the unique key
                //ST-740
                list<Product_Interested__c> lstExistingProductInterested = [SELECT Lead__c, Contact__c, Unique_Key__c, number_of_desks__c, Building__c FROM Product_Interested__c WHERE Lead__c IN: mapLeadsById.keyset()];
                for(Product_Interested__c currentProductInterest : lstExistingProductInterested){
                    Lead objLead = mapLeadsById.get(currentProductInterest.Lead__c);
                    currentProductInterest.Lead__c = null;
                    currentProductInterest.Contact__c = mapContactsByEmail.get(objLead.Email.toLowerCase()).Id;
                    //currentProductInterest.Unique_Key__c = (string.isBlank(currentProductInterest.number_of_desks__c)?'':currentProductInterest.number_of_desks__c)+'-'+ mapContactsByEmail.get(objLead.Email.toLowerCase()).Id+'-'+(string.isBlank(currentProductInterest.Building__c)?'':currentProductInterest.Building__c);
                    lstProductInterestToBeUpdated.add(currentProductInterest);
                }
                
                update lstProductInterestToBeUpdated;
                
                //If lead owner is queue then update lead owner with current loggedin user id before conversion
                for(Lead lead : leadsToBeProcessed) {
                    String strLeadEmail = lead.Email.toLowerCase();
                    if( mapLeadsByEmail.containsKey(strLeadEmail) || mapContactsByEmail.containsKey(strLeadEmail) ) {
                        if(((String)lead.OwnerId).startsWith('00G'))
                        {
                            lead.OwnerId = UserInfo.getUserId();
                        }
                    }
                }
                
                update leadsToBeProcessed;
                
                integer iIndex = 0;
                for(Lead lead : leadsToBeProcessed) {
                    String strLeadEmail = lead.Email.toLowerCase();
                    ContactResult result = new ContactResult(); 
                    String companyName = mapLeadsByEmail.get(strLeadEmail)[0].company;
                    result.ContactId = mapContactsByEmail.get(strLeadEmail).Id;
                    result.AccountId = mapContactsByEmail.get(strLeadEmail).AccountId;
                    Debug.log('lead.OwnerId In Contact==>'+lead.OwnerId);
                    if( mapLeadsByEmail.containsKey(strLeadEmail) || mapContactsByEmail.containsKey(strLeadEmail) ) {
                        if(((String)lead.OwnerId).startsWith('00G')){
                            lead.OwnerId = UserInfo.getUserId();
                            update lead;
                        }
                   Debug.log('lead.OwnerId In Contact After==>'+lead.OwnerId);    
                        Database.LeadConvert leadConvert = new database.LeadConvert();
                        leadConvert.setLeadId(lead.Id);
                        //leadConvert.setAccountId(mapAccountsByName.get(companyName).Id);
                        leadConvert.setAccountId(mapContactsByEmail.get(strLeadEmail).AccountId);
                        leadConvert.setContactId(result.ContactId);
                        leadConvert.setConvertedStatus(settingsJourney.ConvertedLeadStatus);
                        leadConvert.doNotCreateOpportunity = true;
                        leadConvert.setOwnerId(lead.OwnerId);
                        Debug.log('Lead Being Converted : ' + leadConvert);
                        Database.LeadConvertResult lcr = Database.convertLead(leadConvert);
                    }
                    Debug.log('result : ' + result);
                    resultRet.add(result); 
                }
            } else {
                ContactResult result = new ContactResult();
                for(Contact contact : contactsExisting){
                    result.ContactId = contact.Id;
                    result.AccountId = contact.AccountId;
                    resultRet.add(result);
                }
            }
            //delete leadsToBeDeleted;
            Debug.log('resultRet : ' + resultRet);
            return resultRet;
        } catch(Exception ex) {  
            //sendMailOnException(mapLeadsByEmail.keyset(),ex);
            List<String> emailIds = New List<String>();
            debug.log('Message::'+ex.getLineNumber()+'LineNumber::'+ex.getMessage());
            if(mapLeadsByEmail.keyset()!=null && mapLeadsByEmail.size() > 0)
                emailIds.addAll(mapLeadsByEmail.keyset());
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadConvertor','ConvertLeadsToContact',String.join(emailIds,','),ex)
            );
            throw new LeadConvertorException(ex.getMessage());  
        }
    }
    
    //This method send email on exception occured in mehod
    public static void sendMailOnException(set<string> setLeadEmails,Exception ex){
        List<String> sendTo = new List<String>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        sendTo.add('wework@enzigma.com');
        mail.setToAddresses(sendTo);
        mail.setSubject('Exception Mail');
        String body = 'Hello Team,<br></br><br></br>';
        body += 'While processing records for the following emails:';
        for(string currentEmails : setLeadEmails){
            body += currentEmails+',';
        }
        body += ' following exception occured:<br></br>'+ex+' <br></br>';
        if(ex != null){
            body += 'Line Number:' +ex.getLineNumber() +' <br></br>';
            body += ' ' +ex.getStackTraceString();
        }
        mail.setHtmlBody(body);
        mails.add(mail);
        Debug.log('You have made :: ' + Limits.getEmailInvocations() + ' email calls out of ' + Limits.getLimitEmailInvocations() + ' allowed');
        Messaging.sendEmail(mails);
        
    }
    
    public class QueueableClass implements Queueable {
        list<lead> lstLeadsToBeDeleted;
        set<string> setLeadToConvert;
        public QueueableClass(){            
        }
        
        public QueueableClass(list<lead> lstLeads){
            lstLeadsToBeDeleted = new list<lead>();
            lstLeadsToBeDeleted.addAll(lstLeads);
        }
        
        public QueueableClass(set<string> setLeadToConvertEmails){
            setLeadToConvert = new set<string>();
            setLeadToConvert.addAll(setLeadToConvertEmails);
        }
        
        public void execute(QueueableContext SC) {
            //do stuff
            if(lstLeadsToBeDeleted != null)
                delete lstLeadsToBeDeleted;
            if(setLeadToConvert != null)
                LeadConvertor.ConvertLeads(setLeadToConvert);
        }
    }
    
    @future
    public static void FutureConvertLeadsToJourneys(Set<Id> setLeadIds){
        ConvertLeadsToJourneys(setLeadIds,false); 
    }
    
    @future
    public static void FutureConvertLeadsToContact(List<String> listEmails){
        ConvertLeadsToContact(listEmails); 
    }
    
    @future
    public static void FutureConvertLeads(set<String> setEmails){
        ConvertLeads(setEmails); 
    }
    
    global class LeadResult {
        public String LeadId {get;set;}
        public String ContactId {get; set;}
        public String JourneyId {get; set;}
        public String ActivityId {get; set;}
        public String NumberOfDesks {get;set;}
        public String BuildingId {get;set;}
        public String CompanySize {get;set;}
        public String ProductLine {get;set;}            
    }
    
    global class ContactResult {
        public String ContactId {get; set;}
        public String JourneyId {get; set;}
        public String AccountId {get; set;}   
    }
    
    public class JourneySettings {
        public JourneySettings (){
            initDefaults();
        }
        
        public void initDefaults(){
            if( NextCallInDaysFromLeadCreation == null )
                NextCallInDaysFromLeadCreation = 4;
            if( CloseInDaysFromJourneyCreation == null )
                CloseInDaysFromJourneyCreation = 30;
            if(NextCallInDaysFromJourneyUpdation == null)
                NextCallInDaysFromJourneyUpdation = 0;
            if(ExistingJourneyCreatedDateDifference == null)
                ExistingJourneyCreatedDateDifference = 4;
            if(JourneyAssignmentCutOffDays == null)
                
                JourneyAssignmentCutOffDays = 30;
            if( NewLeadActivityFields == null )
                NewLeadActivityFields = new Map<String,String>{'Subject' => 'Inbound Lead submission', 'Status' => 'Open'};
                    if( NewJourneyFields == null )
                    NewJourneyFields = new Map<String,String>{'Status__c' => 'Started'};
                        if( ClosedJourneyStages == null )
                        ClosedJourneyStages = new String[]{'Completed-Won', 'Completed-Lost'};
                            if(ConvertedLeadStatus == null)
                            ConvertedLeadStatus = 'Qualified';
        }
        
        public String NoCompanyAccountId {get;set;}
        public String ConvertedLeadStatus {get;set;}
        public Integer NextCallInDaysFromLeadCreation {get;set;}
        public Integer JourneyAssignmentCutOffDays {get;set;}
        public Integer NextCallInDaysFromJourneyUpdation {get;set;}
        public Integer CloseInDaysFromJourneyCreation {get;set;}
        public Integer ExistingJourneyCreatedDateDifference{get;set;}
        public Map<String,String> NewLeadActivityFields{get;set;}
        public Map<String,String> NewJourneyFields {get;set;}
        public String[] ClosedJourneyStages {get;set;}
    }
    
    public class AllowedUsersSettings {
        public String userName;
        public String Id;  
    }
    
    public class AllowedQueueSettings {
        public String queueName;  
        public String Id;  
    }
    
    public class UserQueueJourneySettings{
        public AllowedUsersSettings[] allowedUsers;
        public AllowedQueueSettings[] allowedQueues;
    }
    
    public class LeadSoruceSettings {
        public List<LeadSoruceValues> LeadSource;//String[] LeadSource;
        public String[] LeadSourceDetails;
    }
    
    public class LeadSoruceValues {
        public String name;
        public Boolean OverrideLeadSoruce;
    }
    
    public class LeadConvertorException extends Exception{}
}