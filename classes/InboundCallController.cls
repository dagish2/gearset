/*
Created By: Amol Darekar.
Created Date: 16-06-2016.
*/
public class InboundCallController {
    public static string inboundNumber {get;set;} 
    /*Purpose : This method is use to get default journey settings in case we get null from JSON settings*/
    public static JourneySettings DefaultJourneySettings() {
        String strDummyAccountName = 'Dummy Lead Conversion Account';
        Account account;
        Account[] accounts = [Select Id From Account Where Name = :strDummyAccountName];
        if( accounts.size() > 0 ){
            account = accounts[0];
        }else{
            account = new Account(Name = strDummyAccountName);
            insert account;
        }        
        InboundCallController.JourneySettings settingJourney;        
        settingJourney = new InboundCallController.JourneySettings();
        settingJourney.NextCallInDaysFromLeadCreation = 1;
        settingJourney.NewLeadActivityFields = null;
        settingJourney.NewJourneyFields = null;
        settingJourney.NoCompanyAccountId = account.Id;
        return settingJourney;
    }
    
    public InboundCallController(WeworkEngine controller) {
        inboundNumber = apexpages.currentpage().getparameters().get('inboundNumber');
    }
    
    public InboundCallController(ApexPages.StandardController stdController) {}
    
    @RemoteAction
    public static List<SaveResult> createOrUpdateJourney(String recordId,string leadSource,string leadsourcedetail,string buildingInterested,string city, Boolean isLead){
        List<String> lstJourneyFields = new List<String>(LeadRoutingHelper.getJourneyFields());       
        Contact objContact;
        Lead objLead;       
        String strQuery;
        sObject objParent;
        List<sObject> lstRecordsToUpdate = new List<sObject>(); 
        List<SaveResult> lstJourneyResult = new List<SaveResult>();
        Map<Id,sObject> mapJourneys;
        Set<String> setJourneyClosedStages  = LeadRoutingHelper.getJourneyClosedStages(); 
        Setting__c objSetting = Settings.get('APIUserContactInfo');
        APIUserContactInfo apiUserSettings = new APIUserContactInfo();
        if(objSetting != null){
            apiUserSettings = (APIUserContactInfo)JSON.deserialize(objSetting.Data__c, APIUserContactInfo.class);
        }
        if(!isLead){            
            List<String> lstContactFields = new List<String>(LeadRoutingHelper.getContactFields()); 
            strQuery = 'SELECT ' + String.join(lstContactFields, ',') + ', (SELECT '+ String.join(lstJourneyFields, ',') +' FROM Journeys__r WHERE Status__c NOT IN : setJourneyClosedStages AND CreatedDate = TODAY ORDER BY LastModifiedDate DESC) FROM Contact WHERE Id =: recordId ORDER BY LastModifiedDate DESC';
            List<Contact> lstContacts = (List<Contact>)Database.query(strQuery); 
            if(!lstContacts.isEmpty()){
                objParent =  lstContacts[0];  
                objContact = lstContacts[0];
                mapJourneys = FieldMappingsHelper.getMappings(new Set<Id>{String.valueOf(objParent.get('Id'))},'FieldMappings:ContactToJourney');
            }
        }else{
            List<String> lstLeadFields = new List<String>(LeadRoutingHelper.getLeadFields());            
            strQuery = 'SELECT ' + String.join(lstLeadFields, ',') + ', (SELECT '+ String.join(lstJourneyFields, ',') +' FROM Journeys__r WHERE Status__c NOT IN : setJourneyClosedStages AND CreatedDate = TODAY ORDER BY LastModifiedDate DESC),(SELECT Id, Status, WhoId, WhatId FROM Tasks WHERE Status <> \'Completed\') From Lead WHERE IsConverted = false AND Id =: recordId ORDER BY CreatedDate';
            List<Lead> lstLeads = (List<Lead>)Database.query(strQuery);    
            if(!lstLeads.isEmpty()){
                objParent = lstLeads[0];
                objLead = lstLeads[0];
                mapJourneys = FieldMappingsHelper.getMappings(new Set<Id>{String.valueOf(objParent.get('Id'))},'FieldMappings:LeadToJourney');
            }
        }
        Set<String> setLocationIntrested =  new Set<String>();
        if(objLead != null && objLead.Locations_Interested__c != null){
            setLocationIntrested.addAll(objLead.Locations_Interested__c.split(';')); 
        }else if(objContact != null && objContact.Location_Interested__c != null){
            setLocationIntrested.addAll(objContact.Location_Interested__c.split(';'));
        }                    
        InboundCallController.LeadResult objLeadResult = new InboundCallController.LeadResult();
        Map<String, Map<String,Journey__c>> mapJourneyCriterias = new Map<String, Map<String,Journey__c>>();
        Journey__c objNewJourney = (Journey__c)mapJourneys.get(String.valueOf(objParent.get('Id')));
        objNewJourney = getJourneyDefaultMapping(objNewJourney, objLead, objContact, leadSource,  leadsourcedetail, buildingInterested, city, isLead);            
        if(objParent.getSObjects('Journeys__r') != null && objParent.getSObjects('Journeys__r').size() > 0){ 
            Map<String, Journey__c> mapResult = JourneyHelperUtility.checkIsUniqueJourney(objNewJourney,(List<Journey__c>)objParent.getSObjects('Journeys__r'), LeadRoutingHelper.getJourneyMatchingFields());                        
            mapJourneyCriterias.put(String.valueOf(objParent.get('Id')), mapResult); 
        }else{
            mapJourneyCriterias.put(String.valueOf(objParent.get('Id')), new Map<String, Journey__c>{'createNew' => null});   
        }         
        Map<String, Journey__c> mapCriteriaResult = mapJourneyCriterias.get(String.valueOf(objParent.get('Id')));    
        Debug.log('mapCriteriaResult==>'+mapCriteriaResult);
        Boolean isCreateNew = mapCriteriaResult.containsKey('createNew');  
        Map<String, Integer> mapNextNMDNDays = (Map<String, Integer>)JSON.deserialize(Settings.getMetadataSettingByDevName('JourneyNextNMDDateCriteria').Data__c, Map<String, Integer>.class );        
        if(isCreateNew){    
            objNewJourney.Status__c = 'Accepted';
            objNewJourney.NMD_Next_Contact_Date__c = DateUtilities.addBusinessDays(Date.today(), mapNextNMDNDays.get('NextCallINDaysFromLeadCreation'));  
            objNewJourney.OwnerId = UserInfo.getUserId();
        }else if(!isCreateNew && mapCriteriaResult.containsKey('reUse')){
            objNewJourney =  mapCriteriaResult.get('reUse'); 
            objNewJourney = getJourneyDefaultMapping(objNewJourney, objLead, objContact, leadSource,  leadsourcedetail, buildingInterested, city, isLead);            
            objNewJourney.NMD_Next_Contact_Date__c = DateUtilities.addBusinessDays(Date.today(), mapNextNMDNDays.get('NextCallINDaysFromJourneyUpdation'));      
        }
        
        if(Id.valueOf(String.valueOf(objParent.get('OwnerId'))) == Id.valueOf(apiUserSettings.UserId) && String.valueOf(objParent.getSObjectType()) == 'Lead'){
            lstRecordsToUpdate.add(new Lead(Id = String.valueOf(objParent.get('Id')), OwnerId = UserInfo.getUserId()));    
        }else if(!isLead && Id.valueOf(String.valueOf(objParent.get('OwnerId'))) == Id.valueOf(apiUserSettings.UserId) && String.valueOf(objParent.getSObjectType()) == 'Contact'){
            lstRecordsToUpdate.add(new Contact(Id = String.valueOf(objParent.get('Id')), OwnerId = UserInfo.getUserId()));    
        }
        objNewJourney.Promo_Code__c = objParent.get('Promo_Code__c') != null ? String.valueOf(objParent.get('Promo_Code__c')) : null;         
        objNewJourney.Locations_Interested__c = String.join(new List<String>(setLocationIntrested),';');
        Database.update(lstRecordsToUpdate, false);
        lstJourneyResult = WeworkEngine.SaveRecords(new List<Journey__c>{objNewJourney});        
        return lstJourneyResult;
    }
    
    public static Journey__c  getJourneyDefaultMapping(Journey__c objNewJourney, Lead objLead, Contact objContact, String leadSource, String leadsourcedetail, String buildingInterested, String city, Boolean isLead){
        if(String.isNotBlank(leadSource)){
            objNewJourney.Lead_Source__c = leadSource; 
        }       
        if(String.isNotBlank(leadsourcedetail)){
            objNewJourney.Lead_Source_Detail__c = leadsourcedetail;
        } 
        if(String.isNotBlank(buildingInterested)){
            objNewJourney.Building_Interested_In__c = buildingInterested;
        }
        if(isLead){
            objNewJourney.Primary_Lead__c = objLead.Id;
            objNewJourney.Lead_Id__c = objLead.Id; 
            objNewJourney.Name = objLead.Name +'-'+(string.isBlank(city) ? '' : city +'-') +''+ leadSource;
        }else{
            objNewJourney.Primary_Contact__c = objContact.Id;
            objNewJourney.Name = objContact.Name +'-'+(string.isBlank(city) ? '' : city +'-') +''+ leadSource;
        }
        objNewJourney.NMD_Next_Contact_Date__c  = System.Today();
        if(String.isNotBlank(objNewJourney.Name) && objNewJourney.Name.length() > 80) {
            objNewJourney.Name =  objNewJourney.Name.substring(0, 80);
        }         
        return objNewJourney;
    }
 
    /*
    Comment   : This method used get Journey Information related to Contact. 
    Issue     : ST-315
    Parameters: contactPhoneNo
    Author    : Amol Darekar 
    Date      : 16/06/2016 
    */
    @RemoteAction
    public static list<JourneyContactInfo> getContactAndRelatedJoureny(string searchParameter,string formattedNo, string unformattedNo , string contactId,string searchPhoneOnly, boolean isSOQL){
        list<JourneyContactInfo> lstJourneyContactInfo = new list<JourneyContactInfo>();
        set<Id> setContactIds = new set<Id>();
        map<Id,list<Journey__c>> mapLeadContactJournerys = new map<Id,list<Journey__c>>();
        list<contact> lstContactInfo  = new list<contact>();
        list<Lead> lstLeadInfo  = new list<Lead>();
        String tenDigitNumber = searchPhoneOnly;
        String phoneFormat1,phoneFormat2,phoneFormat3,phoneFormat4,phoneFormat5;
        Id entSolutionsTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
        
        if(!string.isBlank(formattedNo))
            formattedNo = '%' + formattedNo + '%';
        else
            formattedNo = '%- -%';
        
        if(!string.isBlank(unformattedNo))
            unformattedNo = '%' + unformattedNo + '%';
        else
            unformattedNo = '%- -%';
        string searchByNameOrEmail = '%'+searchParameter+'%';
        set<string> setPhones = new set<string>();
        if(!string.isBlank(searchPhoneOnly)){
            if(searchPhoneOnly != null && searchPhoneOnly.length() >= 10){
                tenDigitNumber = searchPhoneOnly.right(10);
                phoneFormat1 = '%'+tenDigitNumber.substring(0,3)+'-'+tenDigitNumber.substring(3,6)+'-'+tenDigitNumber.substring(tenDigitNumber.length() - 4)+'%';
                phoneFormat2 = phoneFormat1.replace('-','*');
                phoneFormat3 = phoneFormat1.replace('*',' ');
                phoneFormat4 = '%'+'('+tenDigitNumber.substring(0,3)+')'+tenDigitNumber.substring(3,6)+'-'+tenDigitNumber.substring(tenDigitNumber.length() - 4)+'%';
                phoneFormat5 = '%'+tenDigitNumber+'%';
            } else if(searchPhoneOnly != null){
                phoneFormat1 = phoneFormat2 = phoneFormat3 = phoneFormat4 = phoneFormat5 = searchPhoneOnly;
            }
        } else {
            phoneFormat1 = phoneFormat2 = phoneFormat3 = phoneFormat4 = phoneFormat5 = tenDigitNumber = '%- -%';
        }
        setPhones.add(phoneFormat1);
        setPhones.add(phoneFormat2);
        setPhones.add(phoneFormat3);
        setPhones.add(phoneFormat4);
        setPhones.add(phoneFormat5);
        setPhones.add(searchParameter);
        setPhones.add(formattedNo);
        setPhones.add(unformattedNo);
        String filterKeyWord = '';
        filterKeyWord += '("'+ phoneFormat1 +'")' + ' OR ';
        filterKeyWord += '("'+ phoneFormat2 +'")' + ' OR ';
        filterKeyWord += '("'+ phoneFormat3 +'")' + ' OR ';
        filterKeyWord += '("'+ phoneFormat4 +'")' + ' OR ';
        filterKeyWord += '("'+ phoneFormat5 +'")' + ' OR ';
        filterKeyWord += '("'+ searchParameter +'")' + ' OR ';
        filterKeyWord += '("'+ formattedNo +'")' + ' OR ';
        filterKeyWord += '("'+ unformattedNo +'")' + ' OR ';
        filterKeyWord += '("'+ searchByNameOrEmail +'")';        
        //Commented by Krishana Tupe 
        //Date 21 April 2018
        //Summary : here SOQL takes to much time to get the data and fires two SOQL 1 for Lead and 1 for Contact and here no use of contactId in SOQ.
        //We use SOSL instead of SOQL
       /* if(!String.isBlank(contactId)){      
            Debug.log('contactId::'+contactId);
            lstContactInfo = [Select Id, Name,FirstName,LastName,Email,Company__c,Company_Size__c,Phone,AccountId,Account.Name,Unomy_Company_Size__c,Interested_in_Number_of_Desks__c, Number_of_Full_Time_Employees__c,Location__r.Name,Location_Interested__c,Number_of_Desks_2016__c from contact where (phone Like: setPhones OR Name Like : searchByNameOrEmail OR Email Like : searchByNameOrEmail OR Company__c Like : searchByNameOrEmail OR Account.Name Like : searchParameter) ORDER BY CreatedDate DESC LIMIT 100];
            if(lstContactInfo.size()== 0)
                lstLeadInfo = [Select Id, Name,FirstName,LastName,Locations_Interested__c,Email,Company,Company_Size__c,Unomy_Company_Size__c,Phone,Building_Interested_In__r.Name, Number_of_Full_Time_Employees__c ,Interested_in_Number_of_Desks__c,Number_of_Desks_2016__c from lead where (phone Like: setPhones OR Name Like : searchByNameOrEmail OR Email Like : searchByNameOrEmail OR Company Like : searchByNameOrEmail) AND IsConverted = false ORDER BY CreatedDate DESC LIMIT 100];
        } else { */             
        if(isSOQL) {
            lstContactInfo = [Select Id, Name, FirstName, LastName, Email, Company__c, Company_Size__c, AccountId, Account.Name, Phone, Interested_in_Number_of_Desks__c, Unomy_Company_Size__c, Number_of_Full_Time_Employees__c, Location__r.Name, Location_Interested__c, Number_of_Desks_2016__c, Account.BillingState, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCountry, Account.BillingCity from contact where (phone Like: setPhones OR Name Like : searchByNameOrEmail OR Email Like : searchByNameOrEmail OR Company__c Like : searchByNameOrEmail OR Account.Name Like : searchParameter) ORDER BY CreatedDate DESC LIMIT 100];//phone =: searchParameter OR phone Like: formattedNo OR phone Like: unformattedNo OR
            lstLeadInfo = [SELECT Id, Name, FirstName, LastName, Email, Locations_Interested__c, Company, Company_Size__c, Phone, Building_Interested_In__r.Name, Unomy_Company_Size__c, Number_of_Full_Time_Employees__c , Interested_in_Number_of_Desks__c, Number_of_Desks_2016__c, PostalCode, State, City, Country, Street from lead where (phone Like: setPhones OR Name Like : searchByNameOrEmail OR Email Like : searchByNameOrEmail OR Company Like : searchByNameOrEmail) AND IsConverted = false ORDER BY CreatedDate DESC LIMIT 100];
        } else {
            String regExp = '[%]';
            String replacement = '*';
            String SOSLFilterKeys = filterKeyWord.replaceAll(regExp, replacement);
            List<List<SObject>> listOfSObject = [FIND :filterKeyWord IN ALL FIELDS RETURNING Contact(Id, Name, FirstName, LastName, Email, AccountId, Account.Name, Company__c, Number_of_Full_Time_Employees__c, Number_of_Desks_2016__c, Phone, Interested_in_Number_of_Desks__c, Company_Size__c, Location_Interested__c, Location__r.Name, Unomy_Company_Size__c, Account.BillingState, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCountry, Account.BillingCity), Lead(Id, Name, FirstName, LastName, Email, Locations_Interested__c, Company, Phone, Building_Interested_In__r.Name,Company_Size__c, Interested_in_Number_of_Desks__c, Number_of_Full_Time_Employees__c, Number_of_Desks_2016__c, Unomy_Company_Size__c, PostalCode, State, City, Country, Street WHERE IsConverted = false )];
            if(listOfSObject[0] != null && listOfSObject[0].size() > 0)
                lstContactInfo = listOfSObject[0];
            if(listOfSObject[1] != null && listOfSObject[1].size() > 0)                 
                lstLeadInfo = listOfSObject[1];
        }             
        // }
        for(contact currentJourneyContact : lstContactInfo){
            JourneyContactInfo objJourneyContact = new JourneyContactInfo();
            objJourneyContact.Id = currentJourneyContact.Id;
            objJourneyContact.FirstName = currentJourneyContact.FirstName;
            objJourneyContact.LastName = currentJourneyContact.LastName;
            objJourneyContact.Company = currentJourneyContact.Account.Name;
            objJourneyContact.CompanySize = currentJourneyContact.Company_Size__c;
            objJourneyContact.Email = currentJourneyContact.Email;
            objJourneyContact.Phone = currentJourneyContact.Phone;
            objJourneyContact.Number_of_Desks = currentJourneyContact.Number_of_Desks_2016__c;
            objJourneyContact.Number_of_Full_Time_Employess = String.valueOf(currentJourneyContact.Number_of_Full_Time_Employees__c);
            objJourneyContact.Interested_in_Number_of_Desks = String.valueOf(currentJourneyContact.Interested_in_Number_of_Desks__c);
            objJourneyContact.Unomy_Company_Size = String.valueOf(currentJourneyContact.Unomy_Company_Size__c);
            objJourneyContact.isLead = false;
            objJourneyContact.BuildingInterested = currentJourneyContact.Location__r;
            objJourneyContact.Locations_Interested = currentJourneyContact.Location_Interested__c;
            objJourneyContact.AccountId = currentJourneyContact.AccountId;
            objJourneyContact.Country = currentJourneyContact.Account.BillingCountry;
            objJourneyContact.State = currentJourneyContact.Account.BillingState;
            objJourneyContact.City = currentJourneyContact.Account.BillingCity;
            objJourneyContact.Street = currentJourneyContact.Account.BillingStreet;
            objJourneyContact.PostalCode = currentJourneyContact.Account.BillingPostalCode;
            setContactIds.add(currentJourneyContact.Id);
            lstJourneyContactInfo.add(objJourneyContact);
        }
        
        for(lead currentJourneyLead : lstLeadInfo){
            JourneyContactInfo objJourneyContact = new JourneyContactInfo();
            objJourneyContact.Id = currentJourneyLead.Id;
            objJourneyContact.FirstName = currentJourneyLead.FirstName;
            objJourneyContact.LastName = currentJourneyLead.LastName;
            objJourneyContact.Company = currentJourneyLead.Company;
            objJourneyContact.CompanySize = currentJourneyLead.Company_Size__c;
            objJourneyContact.Email = currentJourneyLead.Email;
            objJourneyContact.Phone = currentJourneyLead.Phone;
            objJourneyContact.BuildingInterested = currentJourneyLead.Building_Interested_In__r; 
            objJourneyContact.Number_of_Desks = currentJourneyLead.Number_of_Desks_2016__c; 
            objJourneyContact.Interested_in_Number_of_Desks = String.valueOf(currentJourneyLead.Interested_in_Number_of_Desks__c);
            objJourneyContact.Number_of_Full_Time_Employess = String.valueOf(currentJourneyLead.Number_of_Full_Time_Employees__c);
            objJourneyContact.Unomy_Company_Size = String.valueOf(currentJourneyLead.Unomy_Company_Size__c);
            objJourneyContact.isLead = true;
            objJourneyContact.Locations_Interested = currentJourneyLead.Locations_Interested__c;
            objJourneyContact.Country = currentJourneyLead.Country;
            objJourneyContact.State = currentJourneyLead.State;
            objJourneyContact.City = currentJourneyLead.City;
            objJourneyContact.Street = currentJourneyLead.Street;
            objJourneyContact.PostalCode = currentJourneyLead.PostalCode;
            setContactIds.add(currentJourneyLead.Id);
            
            lstJourneyContactInfo.add(objJourneyContact);
        }            
        //get journey related to contacts
        //Get only started journeys
        // Modified By Dipak Pawar for ST-3138
        Setting__c objSetting = Settings.get('JourneyCloseStages');
        Set<String> setJourneyCloseStages = new Set<String>();
        if(objSetting != null){
            setJourneyCloseStages = (Set<String>)JSON.deserialize(objSetting.Data__c, Set<String>.class);
        }
        Map<ID, Journey__c> mapJourneyRelatedToLeadContact = new Map<ID, Journey__c>([SELECT Id, Name, Primary_Contact__c,Primary_Contact__r.Name, Primary_Lead__c ,Primary_Lead__r.Name , Status__c, NMD_Next_Contact_Date__c FROM Journey__c where ((Primary_Contact__c IN:setContactIds OR Primary_Lead__c IN:setContactIds) AND Status__c NOT IN :setJourneyCloseStages) ORDER BY CreatedDate DESC limit 100]);
        for(Id currentJourneyId : mapJourneyRelatedToLeadContact.keySet()){   
            Journey__c objCurrentJourney = mapJourneyRelatedToLeadContact.get(currentJourneyId);
            if(objCurrentJourney.Primary_Contact__c != null ){
                if(mapLeadContactJournerys.containsKey(objCurrentJourney.Primary_Contact__c)){
                    mapLeadContactJournerys.get(objCurrentJourney.Primary_Contact__c).add(objCurrentJourney);
                }else{
                    mapLeadContactJournerys.put(objCurrentJourney.Primary_Contact__c , new list<Journey__c> {objCurrentJourney});
                }
            }else if(objCurrentJourney.Primary_Lead__c != null){
                if(mapLeadContactJournerys.containsKey(objCurrentJourney.Primary_Lead__c)){
                    mapLeadContactJournerys.get(objCurrentJourney.Primary_Lead__c).add(objCurrentJourney);
                } else {
                    mapLeadContactJournerys.put(objCurrentJourney.Primary_Lead__c , new list<Journey__c> {objCurrentJourney});
                }
            }
        }
        
        for(JourneyContactInfo currentJourneyContact : lstJourneyContactInfo){
            if(mapLeadContactJournerys.containsKey(currentJourneyContact.Id)){
                list<Journey__c> lstCurrentJourney = mapLeadContactJournerys.get(currentJourneyContact.Id);
                list<JourneyInfoController> lstJourneyInfo = new list<JourneyInfoController>();
                for(Journey__c currentJourney : lstCurrentJourney){
                    JourneyInfoController objJourneyInfo = new JourneyInfoController();
                    objJourneyInfo.JourneyId = currentJourney.Id;
                    objJourneyInfo.Name = currentJourney.Name;
                    objJourneyInfo.JourneyStage = currentJourney.Status__c;
                    objJourneyInfo.JourneyNMDDate = currentJourney.NMD_Next_Contact_Date__c;
                    lstJourneyInfo.add(objJourneyInfo);
                }
                currentJourneyContact.lstJourneyContacts = new list<JourneyInfoController>(); 
                currentJourneyContact.lstJourneyContacts.addAll(lstJourneyInfo);
            }
        }        
        return lstJourneyContactInfo;
    }
    
    @RemoteAction
    public static string getRecordTypeInfo(string recordTypename){
        return Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
    }
    
    /*
    Created By  : Mayuresh Ghodke.
    Created Date: 23-11-2016.
    Issue No.   : ST-582
    Comment     : Will send email to selected Lead or Contact. 
    Email template will be html template created with Export Reservable page.
    */
    @RemoteAction
    public static Boolean sendEmail(Id senderId, String htmlBody, String mailSubject) {    
        String fName;
        //Check given Id is LeadId or ContcatId
        if(senderId != null && String.ValueOf(senderId).startsWith('00Q')){
            Lead objLead = [Select Id,Name From Lead Where Id =: senderId];
            fName = objLead.Name;
        }else {
            Contact objContact = [Select Id,Name,FirstName  From Contact Where Id =: senderId];
            fName = objContact.Name;
        }
        //Customise Contact Name dynamically as per Lead or Contact
        User u = WeworkEngine.GetLoggedInUserInfo();
        htmlBody = htmlBody.replace('{!Contact.Name}', fName); 
        htmlBody = htmlBody.replace('{!User.FirstName}', u.FirstName);           
        List<Messaging.SingleEmailMessage> emailToSend = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setHtmlBody(htmlBody); //Add given html body
        mail.setSubject(mailSubject); //Add given email subject
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(senderId); //Selected ContactId or LeadId
        emailToSend.add(mail);
        Messaging.sendEmail(emailToSend,false);
        return true;
    }       
    
    public class JourneyContactInfo{
        public string Id{get;set;}
        public string Company{get;set;}
        public string CompanySize{get;set;}
        public string Email{get;set;}
        public string FirstName{get;set;}
        public string LastName{get;set;}
        public string LeadSource{get;set;}  
        public string Phone{get;set;}
        public string Number_of_Full_Time_Employess{get;set;}
        public string Number_of_Desks{get;set;}
        public string Interested_in_Number_of_Desks{get;set;}
        public string Unomy_Company_Size{get;set;}
        public string Country{get;set;}
        public string State{get;set;}
        public string City{get;set;}
        public string Street{get;set;}
        public string PostalCode{get;set;}
        public object BuildingInterested{get;set;}
        public boolean isLead{get;set;}
        public list<JourneyInfoController> lstJourneyContacts{get;set;}
        public string Locations_Interested{get;set;}
        public string AccountId{get;set;}
    }
    
    public class JourneyInfoController{
        public string Id{get;set;}
        public string Name{get;set;}
        public string ContactId{get;set;}
        public string ContactName{get;set;}
        public string JourneyId{get;set;}
        public string JourneyStage{get;set;}
        public Date JourneyNMDDate{get;set;}
        public string Role{get;set;}
        
    }
    
    public class LeadSoruceSettings {
        public List<LeadSoruceValues> LeadSource;//String[] LeadSource;
        public String[] LeadSourceDetails;
    }
    
    public class LeadSoruceValues {
        public String name;
        public Boolean OverrideLeadSoruce;
    }
    
    public class JourneySettings {
        public JourneySettings (){
            initDefaults();
        }
        
        public void initDefaults(){
            if( NextCallInDaysFromLeadCreation == null ){
                NextCallInDaysFromLeadCreation = 4;
            }
            
            if( CloseInDaysFromJourneyCreation == null ){
                CloseInDaysFromJourneyCreation = 30;
            }
            
            if(NextCallInDaysFromJourneyUpdation == null){
                NextCallInDaysFromJourneyUpdation = 0;
            }
            
            if(ExistingJourneyCreatedDateDifference == null){
                ExistingJourneyCreatedDateDifference = 4;
            }
            
            if(JourneyAssignmentCutOffDays == null){
                JourneyAssignmentCutOffDays = 30;
            }               
            
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
    
    Public class LeadResult {
        public String LeadId {get;set;}
        public String ContactId {get; set;}
        public String JourneyId {get; set;}
        public String ActivityId {get; set;}
        public String NumberOfDesks {get;set;}
        public String BuildingId {get;set;}
        public String CompanySize {get;set;}
        public String ProductLine {get;set;}            
    }
    
    /************************************************************************************************************************************
    Author              : Priyanka Ambre
    Description         : This wrapper class is used to store API user Details.
    Created Date        : 
    **************************************************************************************************************************************/    
    public class APIUserContactInfo {
        public String UserId{get;set;}
        public String Email{get;set;}
        public String Name{get;set;}
        public String contactId{get;set;}
        public String contactUUID{get;set;}
    }
    
    public class InboundCallControllerException extends Exception{}
    
}