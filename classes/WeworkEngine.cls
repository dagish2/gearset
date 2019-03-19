global class WeworkEngine
{
    global static String currentSandboxPath{ get; set;}
    global static List<Building__c> listBuildings { get; set;}
    global static SelectOption[] availableTimes {get; set;}
    static Settings.FieldMappings mapContactToJourney;
    static Settings.FieldMappings mapLeadToJourney;
    static LeadConvertor.JourneySettings settingsJourney;
    static Map<String, String>localeToDateTimeFmtMap;
    //System.URL.getSalesforceBaseURL().getHost();
    global WeworkEngine(AddMembersToCampaignController cctrl){}
    global WeworkEngine(){
        //currentSandboxPath = System.URL.getSalesforceBaseURL().toExternalForm();
        currentSandboxPath = System.URL.getSalesforceBaseUrl().getHost().remove('-api' );
    }
    
    @RemoteAction
    global static sObject[] Query(String strQuery) {
        return Database.Query(strQuery);
    }
    
    @RemoteAction
    global static List<List<sObject>> searchQuery(String strSearchQuery) {
        return Search.query(strSearchQuery);
    }
    
    //Retuns all picklist value.
    @RemoteAction
    global static List<String> fetchObjectFields( String objectApiName, String fieldApiName)
    {
        List<String> lstFieldValues = new List<String>();
        Schema.SObjectType targetObjectType = Schema.getGlobalDescribe().get(objectApiName);
        Map<String, Schema.SObjectField> field_map = targetObjectType.getDescribe().fields.getMap();
        for(Schema.PicklistEntry picklistEntry : field_map.get(fieldApiName).getDescribe().getPickListValues())
            lstFieldValues.add(picklistEntry.getLabel());
        return lstFieldValues;
    }
    
    @RemoteAction
    global static User GetLoggedInUserInfo() {
        User currentUser = [SELECT Name, Profile.Name, Id, Email, Username, FirstName, LastName, Profile.Id, TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId()];
        return currentUser;
    }
    
    @RemoteAction
    global static List<Contact> GetContactInfo(String EmailId) {
        List<Contact> lstContact = new List<Contact>([SELECT Id, Name, Email FROM Contact WHERE Email =: EmailId]);
        return lstContact;
    }
    
    @RemoteAction
    global static Reports.ReportResults runReport(String reportId) {
        return Reports.ReportManager.runReport(reportId, true);
    }
    
    /*
    * Created By    : Mayuresh Ghodke
    * Created Date  : 13-10-2016
    * Comment       : Fetch Report Name for Journey Tracker Button.
    * Issue No.     : ST-743
    */
    webservice static string FetchReportId() 
    { 
        Setting__c objeSetting = getSettingsRecord('JourneyReport'); //Fetch Setting
        list<ReportNameSetting> lstReportNameSetting = new list<ReportNameSetting>(); 
        lstReportNameSetting = (List<ReportNameSetting>)JSON.deserialize(objeSetting.Data__c,List<ReportNameSetting>.class);
        String ReportNameToFetch = lstReportNameSetting[0].ReportName;
        String FolderNameToFetch = lstReportNameSetting[0].FolderName;
        List<Report> lstReport = [Select Id,Name From Report Where Name =: ReportNameToFetch and FolderName =: FolderNameToFetch];
        Debug.log('lstReport : '+lstReport);
        
        if(lstReport != null && !lstReport.isEmpty())
            return lstReport[0].Id;
        else
            return 'No Report Found';
    }
    global class ReportNameSetting{
        String ReportName { get; set;}
        String FolderName { get; set;}
    }
    
    global static sObject ConstructSobject(String sObjectApiName, String jSONSObject)
    {
        try
        {
            Map<String, Object> fieldMap = null;
            fieldMap = (Map<String, Object>)JSON.deserializeUntyped(jSONSObject);
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectApiName);
            SObject newSobject = targetType.newSObject();
            Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
            System.debug(logginglevel.ERROR, 'fieldMap::'+fieldMap);
            System.debug(logginglevel.ERROR, 'jSONSObject::'+jSONSObject);
            for (String key : fieldMap.keySet()) 
            {
                Object value = fieldMap.get(key);
                Schema.DisplayType valueType = targetFields.get(key).getDescribe().getType();
                System.debug(logginglevel.ERROR, 'valueType::'+valueType);
                System.debug(logginglevel.ERROR, 'value::'+value);
                if (value instanceof String && valueType != null && valueType != Schema.DisplayType.String) 
                {
                    String svalue = (String)value;
                    if (valueType == Schema.DisplayType.Date)
                        newSobject.put(key, Date.valueOf(svalue));
                    else if(valueType == Schema.DisplayType.DateTime)
                        newSobject.put(key, DateTime.valueOfGmt(svalue));
                    else if (valueType == Schema.DisplayType.Percent || valueType == Schema.DisplayType.Currency) 
                        newSobject.put(key, svalue == '' ? null : Decimal.valueOf(svalue));
                    else if (valueType == Schema.DisplayType.Double)
                        newSobject.put(key, svalue == '' ? null : Double.valueOf(svalue));
                    else if (valueType == Schema.DisplayType.Integer)
                        newSobject.put(key, Integer.valueOf(svalue));
                    else if (valueType == Schema.DisplayType.Base64)
                        newSobject.put(key, Blob.valueOf(svalue));
                    else
                        newSobject.put(key, svalue);
                } 
                else
                    newSobject.put(key, value);
            }
            return newSobject;
        }
        catch(Exception ex)
        {
            System.debug(logginglevel.ERROR, 'Exception occured while creating sObject:'+ex.getMessage());
            Debug.log('Exception occured while creating sObject:'+ex.getMessage());
            return null;
        }
    }
    
    @RemoteAction
    global static String getUserName(){
        return UserInfo.getName();
    }
    
    @RemoteAction
    global static Boolean DeleteRecord(String strAPIName, String strJSONObject){
        sObject newSobject = ConstructSobject(strAPIName,strJSONObject);
        
        try{
            Database.delete(String.valueOf(newSobject.get('Id')));
            return true;
        }
        catch(Exception ex){
            Debug.log('Error occured while deleting the record:'+ex.getMessage());
        }
        return false;
        
    }
    
    @RemoteAction
    global static Setting__c getSettings(Id settingsId) {
        return [Select Id,Name,Data__c,Destination_Object__c,Source_Object__c,Type__c FROM Setting__c WHERE Id = :settingsId];
    }
    
    @RemoteAction
    global static List<Database.DeleteResult> DeleteRecords(List<Id> lstIds) 
    {   if(!lstIds.isEmpty())
        return Database.delete(lstIds); 
     else
         return null;    
    }
    
    @RemoteAction
    global static List<SaveResult> SaveRecords(List<sObject> lstObj){
        Debug.log('test==>'+lstObj);
        List<sObject> lstUpdateObj = new List<sObject>();
        List<sObject> lstNewObj = new List<sObject>();
        List<SaveResult> lstResult = new List<SaveResult>();
        try{
            for(sObject obj : lstObj){
                if(String.isNotEmpty(obj.Id))
                    lstUpdateObj.add(obj);
                else
                    lstNewObj.add(obj);
            }
            if(lstUpdateObj.size() > 0){
                for(Database.Saveresult newDatabaseUpdateResult : Database.update(lstUpdateObj)){
                    lstResult.add(new SaveResult(Database.update(lstUpdateObj)));
                }
            }
            if(lstNewObj.size() > 0){
                //Database.DMLOptions dmo = new Database.DMLOptions();
                //dmo.assignmentRuleHeader.useDefaultRule = true;
                for(Database.Saveresult newDatabaseSaveResult : Database.insert(lstNewObj)){
                    lstResult.add(new SaveResult(newDatabaseSaveResult));
                }
            }
        }catch(Exception ex){
            lstResult.add(new SaveResult(ex));
        }
        Debug.log('lstResult==>'+lstResult);
        return lstResult;
    }
    
    global class FieldResult{
        public string name { get; set;}
        public string label { get; set;}
        public integer length { get; set;}
        public Schema.Displaytype type { get; set;}
    }
    
    @RemoteAction
    global static List<FieldResult> GetAllFields(String objType){
        Map<String,DescribeFieldResult> fieldsWithDetails = new Map<String,DescribeFieldResult>();
        List<FieldResult> lstFieldResult = new List<FieldResult>();
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{objType});
        for(Schema.DescribeSobjectResult res : results) {
            for(Schema.SObjectField field: res.fields.getMap().values()){
                DescribeFieldResult fieldDescribe = field.getDescribe();
                FieldResult result = new FieldResult ();
                result.name = fieldDescribe.name;
                result.label = fieldDescribe.label;
                result.length = fieldDescribe.length;
                result.type = fieldDescribe.type;
                lstFieldResult.add(result);
                fieldsWithDetails.put(fieldDescribe.name,fieldDescribe);
            }
        }
        Debug.log('Test : : ' + lstFieldResult);
        return lstFieldResult;
    }
    
    @RemoteAction
    global static Date addBusinessDays( Integer utcYear, Integer utcMonth, Integer utcDate, Integer daysToAdd){
        Date date1 =  Date.newinstance(utcYear, utcMonth, utcDate);
        String dt = date1.format();
        Date givenDate = date.parse(dt);
        return DateUtilities.addBusinessDays(givenDate, daysToAdd);
    }

    @RemoteAction
    global static List<Building__c> getBuildingList(String product_line) {      
        listBuildings = new List<Building__c>();
        for (Tour_Schedule__c t:[Select Id,Building__r.UUID__c,Building__r.Id,Building__r.Name,Building__r.City__c,Building__r.Time_Zone__c,Building__r.Tour_Spacing__c From Tour_Schedule__c Where Product_Line__c =: product_line order by Building__r.Sort_Order__c asc]) {       
            Building__c b = new Building__c(Id = t.Building__r.Id, Name = t.Building__r.Name, City__c = t.Building__r.City__c, Time_Zone__c = t.Building__r.Time_Zone__c, Tour_Spacing__c = t.Building__r.Tour_Spacing__c, UUID__c = t.Building__r.UUID__c);
            listBuildings.add(b);
        }
        return listBuildings;
    }
    
    @RemoteAction
    global static List<LeadConvertor.ContactResult> convertLeadsToExisting(Map<String,Object> entity){
        Debug.log('entity===='+entity);
        Settings.FieldMappings mapLeadToContact = Settings.getFieldMappings('LeadToContact');
        if(mapLeadToContact == null)
        {
            mapLeadToContact = LeadConvertor.Lead2Contact();
        }
        Set<String> setLeadFields = new Set<String>();
        for(Settings.MappedField field : mapLeadToContact.mappings.values()){
            setLeadFields.add(field.fieldname.toLowerCase());
        }
        List<String> lstLeadFields = new List<String>();
        lstLeadFields.addAll(setLeadFields);
        Lead lead = Database.Query('Select ' + String.join(lstLeadFields, ',') + ' From Lead Where Id =\''+entity.get('leadId')+'\'');
        Contact con;
        if(entity.containsKey('accountId')){
            con = new Contact(AccountId=String.valueOf(entity.get('accountId')),Convert_Lead__c=false);
        }else{
            con = new Contact(Convert_Lead__c=false);
        }
        for(String field : mapLeadToContact.mappings.keySet()){
            Settings.MappedField mappedField = mapLeadToContact.mappings.get(field);
            if(mappedField.isvalue == true)
                con.put(field, mappedField.value);
            else
                con.put(field, lead.get(mappedField.fieldname));
        }
        insert con;
        List<LeadConvertor.ContactResult> result = LeadConvertor.ConvertLeadsToContact(new List<String>{lead.Email});
        Debug.log('result==>'+result);
        Account acc = Database.Query('Select Id,OwnerId,RecordTypeId,Primary_Member__c From Account Where Id =\''+result[0].AccountId+'\'');
        if(entity.containsKey('accountId') && entity.containsKey('buildingId') && String.isNotBlank(String.valueOf(entity.get('buildingId')))){
            Map<Id,Building__c> mapBuildings = new Map<Id,Building__c>([Select Id,Name From Building__c]);
            Debug.log('acc.Id-----'+acc.Id);
            Debug.log('acc.Primary_Member__c-----'+acc.Primary_Member__c);
            Debug.log('mapBuildings-----'+mapBuildings);
            Debug.log('entity.get(buildingId)-----'+entity.get('buildingId'));
            Opportunity opp = OpportunityServices.get_latest_open_opportunity_by_primary_member(acc.Id,acc.Primary_Member__c,mapBuildings.get(String.valueOf(entity.get('buildingId'))).Name);
            if(opp==null && entity.containsKey('buildingId') && String.isNotBlank(String.valueOf(entity.get('buildingId')))){
                WeworkEngine.createOpportunityOnLeadConversion(con.Id,String.valueOf(entity.get('buildingId')),Boolean.valueOf(entity.get('bookedBySalesLead')));
            }else{
                Opportunity_Role__c opRole = new Opportunity_Role__c(Contact__c=con.Id,Opportunity__c=opp.Id,Role__c='Influencer');
                insert opRole;
            }
        }else if(entity.containsKey('buildingId') && String.isNotBlank(String.valueOf(entity.get('buildingId')))){
            WeworkEngine.createOpportunityOnLeadConversion(con.Id,String.valueOf(entity.get('buildingId')),Boolean.valueOf(entity.get('bookedBySalesLead')));
        }
        if(entity.containsKey('acountId')){
            WeWorkEngine.mapLeadToAccount(lead.Id, acc.Id);
        }
        acc = Database.Query('Select Id,OwnerId,RecordTypeId,Primary_Member__c From Account Where Id =\''+result[0].AccountId+'\'');
        con = new Contact(Id=result[0].ContactId,OwnerId=acc.OwnerId);
        if(acc.RecordTypeId!=null && Schema.SObjectType.Opportunity.getRecordTypeInfosByName().containsKey(Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.RecordTypeId).getName())){
            con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.RecordTypeId).getName()).getRecordTypeId();
        }
        update con;
        if(entity.containsKey('allowMerge')){
            update new Account(Id=result[0].AccountId,Allow_Merge__c = Boolean.valueOf(entity.get('allowMerge')));
        }
        return result;
    }
    global static void createOpportunityOnLeadConversion(Id contactId,Id buildingId,Boolean bookedBySalesLead){
        Debug.log('contactId===='+contactId);
        Debug.log('buildingId===='+buildingId);
        Debug.log('bookedBySalesLead===='+bookedBySalesLead);
        Settings.FieldMappings mapContactToOpportunity = Settings.getFieldMappings('ContactToOpportunity');
        debug.log('mapContactToOpportunity==>'+mapContactToOpportunity);
        if(mapContactToOpportunity == null){
            mapContactToOpportunity = Contact2Opportunity();
        }
        Set<String> setContactFields = new Set<String>();   
        for(Settings.MappedField field : mapContactToOpportunity.mappings.values()){        
            setContactFields.add(field.fieldname.toLowerCase());
        }        
        setContactFields.add('Account.RecordTypeId');
        setContactFields.add('Account.OwnerId');
        setContactFields.add('AccountId');
        List<String> lstContactFields = new List<String>();
        lstContactFields.addAll(setContactFields);
        Contact con = Database.query('Select ' + String.join(lstContactFields, ',') + ' From Contact Where Id =\''+contactId+'\'');
        Opportunity opp = new Opportunity();
        for(String field : mapContactToOpportunity.mappings.keySet()){
            Settings.MappedField mappedField = mapContactToOpportunity.mappings.get(field);     
            if(mappedField.isvalue == true){    
                opp.put(field, mappedField.value);  
            }else if(opp.get(field)==null || opp.get(field)==''){
                opp.put(field,con.get(mappedField.fieldname));
            }
        }
        opp.Name = 'Opportunity Name';
        opp.CloseDate = Date.today();
        opp.StageName = 'Selling';
        opp.AccountId = con.AccountId;
        opp.Primary_Member__c = contactId;
        opp.Building__c = buildingId;
        if(con.Account.RecordTypeId!=null && Schema.SObjectType.Opportunity.getRecordTypeInfosByName().containsKey(Schema.SObjectType.Account.getRecordTypeInfosById().get(con.Account.RecordTypeId).getName())){
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Schema.SObjectType.Account.getRecordTypeInfosById().get(con.Account.RecordTypeId).getName()).getRecordTypeId();
        }
        //opp.OwnerId = con.Account.OwnerId;
        if(bookedBySalesLead){
            Debug.log('in true====');
            opp.Owner_Auto_Assign__c = false;
        }else{
            Debug.log('in false====');
            opp.Owner_Auto_Assign__c = true;
        }
        insert opp;
    }
    global static void mapLeadToAccount(Id leadId,Id accountId){
        Settings.FieldMappings mapLeadToAccount = Settings.getFieldMappings('LeadToAccount');
        if( mapLeadToAccount == null ){
            mapLeadToAccount = LeadConvertor.Lead2Account();
        }
        List<String> lstLeadFields = new List<String>();
        List<String> lstAccountFields = new List<String>();
        for(Settings.MappedField field : mapLeadToAccount.mappings.values()){
            lstLeadFields.add(field.fieldname.toLowerCase());
        }
        for(String field : mapLeadToAccount.mappings.keySet()){
            lstAccountFields.add(field.toLowerCase());
        }
        Lead lead = Database.query('Select ' + String.join(lstLeadFields, ',') + ' From Lead Where Id = \''+leadId+'\'');
        Account acc = Database.query('Select ' + String.join(lstAccountFields, ',') + ' From Account Where Id = \''+accountId+'\'');
        for(String field : mapLeadToAccount.mappings.keySet()){
            Settings.MappedField mappedField = mapLeadToAccount.mappings.get(field);
            if(String.isBlank(String.valueOf(acc.get(field)))){
                if(mappedField.isvalue == true){
                    acc.put(field, mappedField.value);
                }
                else{
                    acc.put(field, lead.get(mappedField.fieldname));
                }
            }
        }
    }
    
    @RemoteAction
    global static SelectOption[] loadAvailableTimes(Date tourDate,Id selectedBuilding,String product_line, String selectedBuildingTZ) {
        Debug.log('loadAvailableTimes ::'+tourDate);
        Debug.log('selectedBuilding ::'+selectedBuilding);    
        Debug.log('TourServices.getAvailableTimes(tourDate, selectedBuilding, product_line) ::'+TourServices.getAvailableTimes(tourDate, selectedBuilding, product_line));
        if(availableTimes == null)
            availableTimes = new List<SelectOption>();
        for (Time t:TourServices.getAvailableTimes(tourDate, selectedBuilding, product_line)) {
            String timeAsString = DateTime.newInstance(tourDate, t).format('h:mma', selectedBuildingTZ);
            Debug.log('timeAsString ::'+timeAsString);
            Debug.log('availableTimes ::'+availableTimes); 
            availableTimes.add(new SelectOption(timeAsString, timeAsString));
        }
        Debug.log('availableTimes ::'+availableTimes); 
        return availableTimes;
    }
    
    @RemoteAction
    global static SaveResult reScheduleTours(List<Tour_Outcome__c> lstNewTourRecords, List<Tour_Outcome__c> lstUpdateTourRecords) {     
        SaveResult tourResult;
        list<SaveResult> newTourRecordsResult,updateTourRecordsResult;
        Savepoint sp = Database.setSavepoint();
        try{
            debug.Log('lstNewTourRecords' + lstNewTourRecords);
            if(!lstNewTourRecords.isEmpty() && !lstUpdateTourRecords.isEmpty()){
                newTourRecordsResult = WeworkEngine.SaveRecords(lstNewTourRecords);
                updateTourRecordsResult = WeworkEngine.SaveRecords(lstUpdateTourRecords);
            }
            debug.Log('newTourRecordsResult' + newTourRecordsResult);
            if(newTourRecordsResult[0].IsSuccess==true && updateTourRecordsResult[0].IsSuccess==true){
                tourResult = new SaveResult();
                tourResult.IsSuccess = true;
                tourResult.Id = newTourRecordsResult[0].Id;
                tourResult.Message = 'Tour Reschedule Successful.';
                debug.Log('tourResult' + tourResult);
            }else{
                Database.rollback(sp);
                tourResult = new SaveResult();
                tourResult.IsSuccess = false;
                tourResult.Message = 'Tour Reschedule Failed.';
            }
            
        }catch(Exception ex){
            System.debug(logginglevel.ERROR, 'Exception in Rescheduling Line NUmbe::'+ex.getLineNumber());
            System.debug(logginglevel.ERROR, 'Exception in Rescheduling StackTraceString::'+ex.getStackTraceString());
            Database.rollback(sp);
            tourResult = new SaveResult(ex);
            System.debug(logginglevel.ERROR, 'Exception in Rescheduling::'+ex.getMessage());
        }
        return tourResult;
    }
    
    @RemoteAction
    global static SaveResult extendReference(Id recordId, Date expiryDate, Date referredDate){
        SaveResult sr = ReferenceHandler.ExtendReference(recordId, expiryDate, referredDate);
        return sr;
    }
    
    @RemoteAction
    global static Setting__c getSettingsRecord(String settingsName){
        return  Settings.get(settingsName);
    }
    
    /*
    Comment   : This method will use to map fields from contact to activity.
    Author    : Amol Darekar
    Date      : 16/07/2016 
    */
    public static Settings.FieldMappings Contact2Activity() {
        Settings.FieldMappings contactToActivityMappings = new Settings.FieldMappings();
        contactToActivityMappings.version = 1;
        contactToActivityMappings.mappings = new Map<String, Settings.MappedField>();
        contactToActivityMappings.mappings.put('Phone__c', new Settings.MappedField('Phone'));
        contactToActivityMappings.mappings.put('Locale__c', new Settings.MappedField('Locale__c'));
        contactToActivityMappings.mappings.put('Market__c', new Settings.MappedField('Market__c'));
        contactToActivityMappings.mappings.put('Product_Interests__c', new Settings.MappedField('Product_Interests__c'));
        contactToActivityMappings.mappings.put('Country_Code__c', new Settings.MappedField('Country_Code__c'));
        contactToActivityMappings.mappings.put('Quick_Quote_Location__c', new Settings.MappedField('Quick_Quote_Location__c'));
        //contactToActivityMappings.mappings.put('LeadSource', new Settings.MappedField('LeadSource'));
        contactToActivityMappings.mappings.put('Lead_Source_Detail__c', new Settings.MappedField('Lead_Source_Detail__c'));
        contactToActivityMappings.mappings.put('utm_campaign__c', new Settings.MappedField('utm_campaign__c'));
        contactToActivityMappings.mappings.put('utm_campaign_id__c', new Settings.MappedField('utm_campaign_id__c'));
        contactToActivityMappings.mappings.put('utm_content__c', new Settings.MappedField('utm_content__c'));
        contactToActivityMappings.mappings.put('utm_medium__c', new Settings.MappedField('utm_medium__c'));
        contactToActivityMappings.mappings.put('utm_source__c', new Settings.MappedField('utm_source__c'));
        contactToActivityMappings.mappings.put('utm_term__c', new Settings.MappedField('utm_term__c'));
        return contactToActivityMappings;
    }
    
    /*
    Comment   : This method will create new Activity when new Tour get booked.
    Author    : Mayuresh Ghodke 
    Date      : 16/07/2016 
    */
    @RemoteAction
    global static List<Task> createActivityForTour(String contactId,String tourDate,String tourId) {
        String result = null;
        List<Task> lstNewTask = new List<Task>();
        set<Id> setContacts = new set<Id>();
        setContacts.add(contactId);
        try{
            Task newTask = new Task();
            Debug.log('contactId ::'+contactId);
            Debug.log('tourDate ::'+tourDate);
            Debug.log('journeyId ::'+tourId);
            //Debug.log('lstTour ::'+lstTour);
            List<Contact> lstContcat = new List<Contact>();            
            Settings.FieldMappings mapContactToActivity;
            set<String> setContactFields = new set<String>();
            list<String> lstContactFields = new list<String>();
            mapContactToActivity = Settings.getFieldMappings('ContactToActivity');
            if(mapContactToActivity == null)
                mapContactToActivity = Contact2Activity();
            for(Settings.MappedField field : mapContactToActivity.mappings.values()){
                setContactFields.add(field.fieldname.toLowerCase());
            }
            lstContactFields.addAll(setContactFields);
            Debug.log('setContactFields :: '+setContactFields);
            Debug.log('lstContactFields ::'+lstContactFields);
            Debug.log('mapContactToActivity.mappings.keySet() :: '+mapContactToActivity.mappings.keySet());
            String str_contact_id = contactId;
            if(contactId != '')
                lstContcat = Database.Query('Select ' + String.join(lstContactFields, ',') + ' From Contact Where Id =: str_contact_id'); 
            
            Debug.log('lstContcat ::'+lstContcat);
            
            if(lstContcat!=null && !lstContcat.isEmpty()){
                newTask.Subject         = 'Tour Booked';
                newTask.Status          = 'In Progress';
                Date dueDate            = Date.valueOf(tourDate);
                newTask.ActivityDate    = dueDate;
                newTask.Subject         = 'Reschedule Tour';                
                newTask.WhoId           = lstContcat[0].Id;
                for(String field : mapContactToActivity.mappings.keySet()){
                    Settings.MappedField mappedField = mapContactToActivity.mappings.get(field);
                    if(mappedField.isvalue == true)
                        newTask.put(field, mappedField.value);
                    else
                        newTask.put(field, lstContcat[0].get(mappedField.fieldname));
                }
                
                lstNewTask.add(newTask);
                Debug.log('newTask ::'+newTask);
                Debug.log('lstNewTask ::'+lstNewTask);
            }
            if(lstNewTask!=null && !lstNewTask.isEmpty()){
                insert lstNewTask;
            }
        }catch(Exception ex){
            //Database.rollback(sp);
            result = 'Activities creation failed.'+ex;
        }
        return lstNewTask;
    }
    
    
    public static Settings.FieldMappings Lead2Journey() {
        Settings.FieldMappings leadToJourneyMappings = new Settings.FieldMappings();
        leadToJourneyMappings.version = 1;
        leadToJourneyMappings.mappings = new Map<String, Settings.MappedField>();
        leadToJourneyMappings.mappings.put('Name', new Settings.MappedField('Name'));
        leadToJourneyMappings.mappings.put('Lead_Source__c', new Settings.MappedField('LeadSource'));
        leadToJourneyMappings.mappings.put('Lead_Source_Detail__c', new Settings.MappedField('Lead_Source_Detail__c'));
        leadToJourneyMappings.mappings.put('utm_campaign__c', new Settings.MappedField('utm_campaign__c'));
        leadToJourneyMappings.mappings.put('utm_campaign_id__c', new Settings.MappedField('utm_campaign_id__c'));
        leadToJourneyMappings.mappings.put('utm_content__c', new Settings.MappedField('utm_content__c'));
        leadToJourneyMappings.mappings.put('utm_medium__c', new Settings.MappedField('utm_medium__c'));
        leadToJourneyMappings.mappings.put('utm_source__c', new Settings.MappedField('utm_source__c'));
        leadToJourneyMappings.mappings.put('utm_term__c', new Settings.MappedField('utm_term__c'));
        return leadToJourneyMappings;
    }
    
    public static Settings.FieldMappings Contact2Journey() {
        Settings.FieldMappings contactToJourneyMappings = new Settings.FieldMappings();
        contactToJourneyMappings.version = 1;
        contactToJourneyMappings.mappings = new Map<String, Settings.MappedField>();
        contactToJourneyMappings.mappings.put('Name', new Settings.MappedField('Name'));
        contactToJourneyMappings.mappings.put('Lead_Source_Detail__c', new Settings.MappedField('Lead_Source_Detail__c'));
        contactToJourneyMappings.mappings.put('utm_campaign__c', new Settings.MappedField('utm_campaign__c'));
        contactToJourneyMappings.mappings.put('utm_campaign_id__c', new Settings.MappedField('utm_campaign_id__c'));
        contactToJourneyMappings.mappings.put('utm_content__c', new Settings.MappedField('utm_content__c'));
        contactToJourneyMappings.mappings.put('utm_medium__c', new Settings.MappedField('utm_medium__c'));
        contactToJourneyMappings.mappings.put('utm_source__c', new Settings.MappedField('utm_source__c'));
        contactToJourneyMappings.mappings.put('utm_term__c', new Settings.MappedField('utm_term__c'));
        return contactToJourneyMappings;
    }
    
    /*
    Comment   : This method used for create 'Journey' and 'Journey Contact' record . 
    Issue     : ST-380
    Parameters: ContactId, Lead Source
    Author    : Amol Darekar 
    Date      : 11/06/2016 */
    @RemoteAction
    global static List<SaveResult> createJourneryAndJourneyContact(String recordId,string leadSource, string buildingInterested,string city, Boolean isLead)
    {
        try
        {
            List<SaveResult> lstJourneyResult = new List<SaveResult>();
            List<SaveResult> lstJourneyContactResult = new List<SaveResult>();
            List<Contact> lstContact = new List<Contact>();
            List<Lead> lstLead = new List<Lead>();
            list<String> lstContactFields = new list<String>();
            list<String> lstLeadFields = new list<String>();
            set<String> setLeadFields = new set<String>();
            set<String> setContactFields = new set<String>();
            mapContactToJourney = Settings.getFieldMappings('ContactToJourney');
            mapLeadToJourney = Settings.getFieldMappings('LeadToJourney');
            
            if(mapContactToJourney == null)
                mapContactToJourney = Contact2Journey();
            
            if(mapLeadToJourney == null)
                mapLeadToJourney = Lead2Journey();
            
            for(Settings.MappedField field : mapContactToJourney.mappings.values()){
                setContactFields.add(field.fieldname.toLowerCase());//lstContactFields.add(field.fieldname.toLowerCase());
            }
            
            //lstContactFields.add('LastName');
            //lstContactFields.add('LeadSource');
            //lstLeadFields.add('LastName');
            
            for(Settings.MappedField field : mapLeadToJourney.mappings.values()){
                setLeadFields.add(field.fieldname.toLowerCase());//lstLeadFields.add(field.fieldname.toLowerCase());
            }
            
            setContactFields.add('LastName');
            setLeadFields.add('LastName');
            lstLeadFields.addAll(setLeadFields);
            lstContactFields.addAll(setContactFields);
            
            if(isLead)
                lstlead = Database.Query('Select ' + String.join(lstLeadFields, ',') + ' From Lead Where Id =: recordId');// [Select Id,Name,FirstName,LastName,Market__c,Building_Interested_In__r.City__c, LeadSource , utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c, utm_campaign_id__c from Lead where Id =:recordId];
            else
                lstContact  = Database.Query('Select ' + String.join(lstContactFields, ',') + ' From contact Where Id =: recordId');//[Select Id,Name,FirstName,LastName,Market__c,LeadSource , utm_campaign__c, utm_content__c, utm_medium__c, utm_source__c, utm_term__c, utm_campaign_id__c from contact where Id =:recordId];
            
            Journey__c objNewJourney = new Journey__c();
            
            if((lstContact!=null && lstContact.size()>0) || (lstLead!=null && lstLead.size()>0))
            {
                if(isLead && lstLead[0].LastName !=null)
                {
                    for(String field : mapLeadToJourney.mappings.keySet()){
                        Settings.MappedField mappedField = mapLeadToJourney.mappings.get(field);
                        if(mappedField.isvalue == true)
                            objNewJourney.put(field, mappedField.value);
                        else
                            objNewJourney.put(field, lstLead[0].get(mappedField.fieldname));
                        
                    }
                    objNewJourney.Name = lstLead[0].Name +'-'+(string.isBlank(city) ? '' : city +'-') +''+ leadSource;
                }
                else if(lstContact[0].LastName !=null)
                {
                    
                    for(String field : mapContactToJourney.mappings.keySet()){
                        Settings.MappedField mappedField = mapContactToJourney.mappings.get(field);
                        if(mappedField.isvalue == true)
                            objNewJourney.put(field, mappedField.value);
                        else
                            objNewJourney.put(field, lstContact[0].get(mappedField.fieldname));
                        
                    }
                    objNewJourney.Name = lstContact[0].Name +'-'+ (string.isBlank(city) ? '' : city +'-') +''+ leadSource;
                }
                
                if(objNewJourney.Name != null && objNewJourney.Name.length() > 80)
                {
                    objNewJourney.Name =  objNewJourney.Name.substring(0, 80);
                }
                
                settingsJourney = (LeadConvertor.JourneySettings)Settings.get('JourneyCreationSettings', LeadConvertor.JourneySettings.class);
                
                
                if( settingsJourney == null ){
                    settingsJourney = new LeadConvertor.JourneySettings();
                }
                
                Debug.log('settingsJourney:'+settingsJourney);
                objNewJourney.Building_Interested_In__c = buildingInterested;
                objNewJourney.NMD_Next_Contact_Date__c = DateUtilities.addBusinessDays(Date.today(), settingsJourney.NextCallInDaysFromLeadCreation);
                objNewJourney.Status__c = 'Started';
                
                if(isLead)
                    objNewJourney.Primary_Lead__c = recordId;
                else
                    objNewJourney.Primary_Contact__c = recordId;
                
                lstJourneyResult = WeworkEngine.SaveRecords(new List<Journey__c>{objNewJourney});
                Debug.log('lstJourneyResult : '+lstJourneyResult);
            }
            
            return lstJourneyResult;
        }
        catch(Exception ex)
        {
            Debug.log('Exception:'+ex);
            system.debug(logginglevel.Error,'Exception:'+ex);
            return null;
        }
    }
    /**
    * @author pranay.jadhav@wework.com.dev5
    * @description : Lead To Activity mappings for 'Enterprise Solutions', and EnterpriseLead Settings for Activity Subject Name and Lead's Company Size
    * @date : 23/Aug/2016
    */
    public static Settings.FieldMappings mapLeadToActivity;
    public static EnterpriseSettingsRecord enterpriseSettingsValues;
    public static EnterpriseLeadSettings enterpriseSettings;
    public static Settings.FieldMappings Lead2Activity() {
        Settings.FieldMappings leadToActivityMappings = new Settings.FieldMappings();
        leadToActivityMappings.version = 1;
        leadToActivityMappings.mappings = new Map<String, Settings.MappedField>();
        leadToActivityMappings.mappings.put('Lead_Source__c', new Settings.MappedField('LeadSource'));
        return leadToActivityMappings;
    }
    
    public class EnterpriseSettingsRecord {
        public List<EnterpriseLandingSettings> EnterpriseLandingSettings;
        public EnterpriseLeadSettings EnterpriseLeadSettings;
    }
    
    public class EnterpriseLandingSettings {
        public String LeadSource;
        public String LeadSourceDetail;
    }
    
    public class EnterpriseLeadSettings {
        public String ActivitySubject;
        public Integer CompanySize;
    }
    
    
    static List<String> listLeadFields = null;
    public static List<String> getLeadFields(){
        Debug.log('In getLeadFields');
        mapLeadToActivity = Settings.getFieldMappings('LeadToActivity');
        Debug.log('mapLeadToActivity :: '+mapLeadToActivity);
        if( mapLeadToActivity == null ) mapLeadToActivity = Lead2Activity();
        Debug.log('mapLeadToActivity :: '+mapLeadToActivity);
        enterpriseSettingsValues = (EnterpriseSettingsRecord)Settings.get('EnterpriseSettings',EnterpriseSettingsRecord.Class);
        
        Debug.log('enterpriseSettingsValues :: '+enterpriseSettingsValues);
        enterpriseSettings = enterpriseSettingsValues.EnterpriseLeadSettings;
        if( listLeadFields == null ){
            Set<String> setLeadFields = new Set<String>();
            setLeadFields.add('OwnerId');
            setLeadFields.add('Company_Size__c');
            setLeadFields.add('RecordTypeId');
            for(Settings.MappedField field : mapLeadToActivity.mappings.values()){
                if(!setLeadFields.contains(field.fieldname))
                    setLeadFields.add(field.fieldname.toLowerCase());
            }
            listLeadFields = new List<String>();
            listLeadFields.addAll(setLeadFields);
        }
        return listLeadFields;
    }
    
    /*
    Comment   : This will call from Lead's custom button. 
    If that Lead's Company Size is > 15 then change its record type to 'Enterprise Solutions' and change owner to 'Enterprise Queue'.
    Issue     : ST-384
    Author    : Mayuresh Ghodke
    Date      : 25/07/2016
    Modified By   : Pranay Jadhav
    Modified Date : 23/Aug/2016
    */
    webservice static string changeLeadRecordType(String leadId)
    {
        Lead objLead = new Lead();
        objLead = Database.Query('SELECT ' + String.join(getLeadFields(), ',') + ' FROM Lead WHERE Id =: leadId AND IsConverted = False Limit 1');
        String reuslt = 'Please Try Angain.';
        List<Journey__c> lstLeadRelatedJourneys = [SELECT Id,Status__c FROM Journey__c WHERE Primary_Lead__c =: leadId AND Status__c = 'Started'];
        List<Group> lstOwnerInfo = new List<Group>();
        lstOwnerInfo = [SELECT Id FROM Group WHERE Name = 'Enterprise Queue' limit 1];
        List<RecordType> lstRecordType = new List<RecordType>();
        lstRecordType = [SELECT Id FROM RecordType WHERE Name = 'Enterprise Solutions' AND sObjectType = 'Lead'];
        if(objLead.Company_Size__c != null){
            Integer endRangeVal = null;
            Boolean containsUpperRange = objLead.Company_Size__c.contains('-');
            Boolean containsLowerRange = objLead.Company_Size__c.contains('+');
            if(containsUpperRange){
                String[] range = objLead.Company_Size__c.split('-');                    
                if(range.Size() > 1){
                    String[] endRange = range[1].split(' ');
                    if(endRange[0] != '')
                        endRangeVal = Integer.valueof(endRange[0]);
                    else
                        endRangeVal = Integer.valueof(endRange[1]);
                }
                else{
                    String lastRange = range[0].substring(0,range[0].length()-1);
                    endRangeVal = Integer.valueof(lastRange);  
                }
            }
            else if(containsLowerRange) {
                String range = objLead.Company_Size__c; 
                range = range.removeEnd('+');
                endRangeVal = Integer.valueof(range);
            }
            else{
                String range = objLead.Company_Size__c; 
                range = range.remove('desk').trim();
                endRangeVal = Integer.valueof(range);
            }
            Debug.log('enterpriseSettings.CompanySize :: '+enterpriseSettings.CompanySize);
            if(endRangeVal > (enterpriseSettings.CompanySize - 1)){
                if(objLead.OwnerId != lstOwnerInfo[0].Id && objLead.RecordTypeId != lstRecordType[0].Id){
                    Task activity = new Task();
                    for(String field : mapLeadToActivity.mappings.keySet()){
                        Settings.MappedField mappedField = mapLeadToActivity.mappings.get(field);
                        if(mappedField.isvalue == true)
                            activity.put(field, mappedField.value);
                        else
                            activity.put(field, objLead.get(mappedField.fieldname));
                    }
                    activity.OwnerId = UserInfo.getUserId();
                    activity.WhoId = objLead.Id;
                    activity.Subject = enterpriseSettings.ActivitySubject;
                    insert activity;
                    
                    objLead.OwnerId = lstOwnerInfo[0].Id;
                    objLead.RecordTypeId = lstRecordType[0].Id;
                    update objLead;
                    
                    List<Journey__c> lstJourneysToUpdate = new List<Journey__c>();
                    for(Journey__c objJourney : lstLeadRelatedJourneys){
                        objJourney.Status__c = 'Nurture';
                        objJourney.Nurture_Reason__c = 'Journey Nurture';
                        lstJourneysToUpdate.add(objJourney);
                    }
                    update lstJourneysToUpdate;
                    reuslt = 'Lead is submitted to Enterprise Solution Team successfully';
                }
                else if(objLead.OwnerId != lstOwnerInfo[0].Id){
                    Task activity = new Task();
                    for(String field : mapLeadToActivity.mappings.keySet()){
                        Settings.MappedField mappedField = mapLeadToActivity.mappings.get(field);
                        if(mappedField.isvalue == true)
                            activity.put(field, mappedField.value);
                        else
                            activity.put(field, objLead.get(mappedField.fieldname));
                    }
                    activity.OwnerId = UserInfo.getUserId();
                    activity.WhoId = objLead.Id;
                    activity.Subject = enterpriseSettings.ActivitySubject;
                    insert activity;
                    
                    objLead.OwnerId = lstOwnerInfo[0].Id;
                    update objLead;
                    List<Journey__c> lstJourneysToUpdate = new List<Journey__c>();
                    for(Journey__c objJourney : lstLeadRelatedJourneys){
                        objJourney.Status__c = 'Nurture';
                        objJourney.Nurture_Reason__c = 'Journey Nurture';
                        lstJourneysToUpdate.add(objJourney);
                    }
                    update lstJourneysToUpdate;
                    reuslt = 'Lead is submitted to Enterprise Solution Team successfully';
                }
                else if(objLead.RecordTypeId != lstRecordType[0].Id){
                    Task activity = new Task();
                    for(String field : mapLeadToActivity.mappings.keySet()){
                        Settings.MappedField mappedField = mapLeadToActivity.mappings.get(field);
                        if(mappedField.isvalue == true)
                            activity.put(field, mappedField.value);
                        else
                            activity.put(field, objLead.get(mappedField.fieldname));
                    }
                    activity.OwnerId = UserInfo.getUserId();
                    activity.WhoId = objLead.Id;
                    activity.Subject = enterpriseSettings.ActivitySubject;
                    insert activity;
                    
                    objLead.RecordTypeId = lstRecordType[0].Id;
                    update objLead;
                    List<Journey__c> lstJourneysToUpdate = new List<Journey__c>();
                    for(Journey__c objJourney : lstLeadRelatedJourneys){
                        objJourney.Status__c = 'Nurture';
                        objJourney.Nurture_Reason__c = 'Journey Nurture';
                        lstJourneysToUpdate.add(objJourney);
                    }
                    update lstJourneysToUpdate;
                    reuslt = 'Lead is submitted to Enterprise Solution Team successfully';
                }
                else{
                    reuslt = 'Lead is already submitted to Enterprise Solution Team';
                }
            }
            else{
                reuslt = 'Company Size is less than '+ enterpriseSettings.CompanySize +' desk. Unable to submit to Enterprise Solution Team';
            }
        }         
        else{
            reuslt = 'Please update Company Size to submit to Enterprise Solution Team';
        }
        return reuslt;
    }
    
    public static boolean hasSObjectField(String fieldName, SObject so){
        String s = JSON.serialize(so);
        Map<String,Object> obj = (Map<String,Object>) JSON.deserializeUntyped(s);
        Set<String> fieldsPresent = obj.keyset().clone();
        return fieldsPresent.contains(fieldName);
    }
    
    /**
    * @author pranay.jadhav@wework.com.dev5
    * @Issue : ST-629 Sales Console : VF Page : JourneyAction
    * @description : Change Outreach Stage to 'Marketing Drip' and create task to related contact and lead
    * @date : 26/Aug/2016
    */
    @RemoteAction
    global static JourneyStageUpdateResult changeStageRelatedLeadOrContactOnJourney(string journeyId) {
        JourneyStageUpdateResult stageChangeResult = new JourneyStageUpdateResult(); 
        if(!journeyId.contains(','))
        {
            List<Journey__c> lstJourneyToUpdate;
            List<Task> lstTaskToInsert;
            Journey__c objJourney = new Journey__c();
            //JourneyStageUpdateResult stageChangeResult = new JourneyStageUpdateResult();
            objJourney = Database.Query('SELECT Id,Primary_Lead__c,Primary_Contact__c FROM Journey__c WHERE Id =: journeyId LIMIT 1');
            if(objJourney != null){
                if(hasSObjectField('Primary_Lead__c', objJourney)){
                    List<Lead> lstLeads = [SELECT Id,(SELECT Id,Status__c,Outreach_Stage__c FROM Journeys__r) FROM Lead WHERE Id =:objJourney.Primary_Lead__c];
                    lstJourneyToUpdate = new List<Journey__c>();
                    lstTaskToInsert = new List<Task>();
                    for (Lead l : lstLeads) {
                        if(l.Journeys__r.size() > 0){
                            for(Journey__c obj : l.Journeys__r){
                                if(obj.Status__c =='Started' && obj.Outreach_Stage__c !='NMD Drip'){
                                    //obj.Status__c = 'Completed';
                                    obj.Outreach_Stage__c ='NMD Drip';
                                    lstJourneyToUpdate.add(obj);
                                }
                            }
                            if(lstJourneyToUpdate.size() > 0){
                                for(Journey__c journeyObj : lstJourneyToUpdate){
                                    Task newTask = new Task();
                                    newTask.WhatId = journeyObj.Id;
                                    //newTask.WhoId = l.Id;
                                    newTask.Type = 'MC Campaign';
                                    newTask.TaskSubtype = 'Call';
                                    newTask.Status = 'Completed';
                                    newTask.Subject = 'Journey Action : Marketing Drip';
                                    newTask.CallDisposition = 'User sent this member to the Marketing Cloud Drip Campaign';
                                    lstTaskToInsert.add(newTask);
                                }
                            }else{
                                stageChangeResult.result = 'No further actions possible as the member is not eligible for Marketing Drip.';
                                stageChangeResult.totalCount = lstJourneyToUpdate.size();
                                stageChangeResult.errorType = 'error';
                                return stageChangeResult;
                            }
                        }
                    }
                    
                    insert lstTaskToInsert;
                    update lstJourneyToUpdate;
                    
                    stageChangeResult.result = 'The member added to the Marketing Drip Campaigns Successfully';
                    stageChangeResult.totalCount = lstJourneyToUpdate.size();
                    stageChangeResult.errorType = 'success';
                    return stageChangeResult;
                    
                }else if(hasSObjectField('Primary_Contact__c', objJourney)){
                    List<Contact> lstContacts = [SELECT Id,(Select Id,Status__c,Outreach_Stage__c FROM Journeys__r) FROM Contact WHERE Id =:objJourney.Primary_Contact__c];
                    lstJourneyToUpdate = new List<Journey__c>();
                    lstTaskToInsert = new List<Task>();
                    for (Contact c : lstContacts) {
                        if(c.Journeys__r.size() > 0){
                            for(Journey__c obj : c.Journeys__r){
                                if(obj.Status__c =='Started' && obj.Outreach_Stage__c !='NMD Drip'){
                                    //obj.Status__c = 'Completed';
                                    obj.Outreach_Stage__c ='NMD Drip';
                                    lstJourneyToUpdate.add(obj);
                                }
                            }
                            if(lstJourneyToUpdate.size() > 0){
                                for(Journey__c journeyObj : lstJourneyToUpdate){
                                    Task newTask = new Task();
                                    newTask.WhatId = journeyObj.Id;
                                    newTask.WhoId = c.Id;
                                    newTask.Type = 'MC Campaign';
                                    newTask.TaskSubtype = 'Call';
                                    newTask.Status = 'Completed';
                                    newTask.Subject = 'Journey Action : Marketing Drip';
                                    newTask.CallDisposition = 'User sent this member to the Marketing Cloud Drip Campaign';
                                    lstTaskToInsert.add(newTask);
                                }
                            }else{
                                stageChangeResult.result = 'No further actions possible as the member is not eligible for Marketing Drip.';
                                stageChangeResult.totalCount = lstJourneyToUpdate.size();
                                stageChangeResult.errorType = 'error';
                                return stageChangeResult;
                            }
                        }
                    }
                    
                    insert lstTaskToInsert;
                    update lstJourneyToUpdate;
                    
                    stageChangeResult.result = 'The member added to the Marketing Drip Campaigns Successfully';
                    stageChangeResult.totalCount = lstJourneyToUpdate.size();
                    stageChangeResult.errorType = 'success';
                    return stageChangeResult;
                }
            }
            stageChangeResult.result = 'Journeys not found for the given Id or Primary Contact/Lead not assigned';
            stageChangeResult.totalCount = 0;
            stageChangeResult.errorType = 'error';
            return stageChangeResult;
        }
        else
        {
            stageChangeResult.errorType = 'success';
            return stageChangeResult;
        }
    }
    global class JourneyStageUpdateResult {
        public String result;
        public Integer totalCount;
        public String errorType;
    }
    
    /**
    * @author pranay.jadhav@wework.com.dev5
    * @Issue : ST-632 VF Page : Followup Call : Set Outreach Stage
    * @description : 
    * @date : 26/Aug/2016
    */
    @RemoteAction
    global static void setOutreachStage(Id journeyId) {
        Debug.log('In setOutreachStage==> ');
        List<Journey__c> lstJourneyToUpdate;
        List<Journey__c> lstJourneys = new List<Journey__c>();
        Set<String> setStages = new Set<String>{'Started'};
            Set<String> setOutreachStages = new Set<String>{'','Call 1','Call 2'};
                JourneyStageUpdateResult stageChangeResult = new JourneyStageUpdateResult();
        
        lstJourneys = [Select Id,Primary_Lead__c,Primary_Contact__c From Journey__c Where Id =: journeyId Limit 1];
        if(lstJourneys.size() > 0){
            if(hasSObjectField('Primary_Lead__c', lstJourneys.get(0))){
                List<Lead> lstLeads = [SELECT Id,(SELECT Id,Status__c,Outreach_Stage__c FROM Journeys__r) FROM Lead WHERE Id =:lstJourneys.get(0).Primary_Lead__c];
                lstJourneyToUpdate = new List<Journey__c>();
                for (Lead l : lstLeads) {
                    if(l.Journeys__r.size() > 0){
                        for(Journey__c obj : l.Journeys__r){
                            //if(obj.Status__c =='Started' && (setOutreachStages.contains(obj.Outreach_Stage__c) || String.isBlank(obj.Outreach_Stage__c))){
                            if(obj.Status__c =='Started'){
                                obj.Outreach_Stage__c ='Manual Outreach';
                                lstJourneyToUpdate.add(obj);
                            }
                        }
                    }
                }
                if(lstJourneyToUpdate.size() > 0)
                    update lstJourneyToUpdate;
                
            }else if(hasSObjectField('Primary_Contact__c', lstJourneys.get(0))){
                List<Contact> lstContacts = [SELECT Id,(Select Id,Status__c,Outreach_Stage__c FROM Journeys__r) FROM Contact WHERE Id =:lstJourneys.get(0).Primary_Contact__c];
                lstJourneyToUpdate = new List<Journey__c>();
                for (Contact c : lstContacts) {
                    if(c.Journeys__r.size() > 0){
                        for(Journey__c obj : c.Journeys__r){
                            Debug.log('obj.Status__c else if :: '+obj.Status__c);
                            Debug.log('obj.Status__c else if :: '+obj.Status__c);
                            //if(obj.Status__c =='Started' && (setOutreachStages.contains(obj.Outreach_Stage__c) || String.isBlank(obj.Outreach_Stage__c))){
                            if(obj.Status__c =='Started'){
                                obj.Outreach_Stage__c ='Manual Outreach';
                                lstJourneyToUpdate.add(obj);
                            }
                        }
                    }
                }
                Debug.log('lstJourneyToUpdate else if :: '+lstJourneyToUpdate);
                if(lstJourneyToUpdate.size() > 0)
                    update lstJourneyToUpdate;
            }           
        }
    }
    
    @RemoteAction
    global static Database.SaveResult[] createActivityForFollowUp(String taskWhatId,String ActivityDate,String Description) {
        String result = null;
        Database.SaveResult[] lstAddedTask;
        List<Task> lstNewTask = new List<Task>();
        set<Id> setContacts = new set<Id>();
        setContacts.add(taskWhatId);
        try{
            Task newTask = new Task();
            Debug.log('contactId ::'+taskWhatId);
            List<Journey__c> lstJourneys = new List<Journey__c>();    
            lstJourneys = [Select Id,Name,Primary_Lead__c,Primary_Contact__c From Journey__c Where Id =: taskWhatId Limit 1];
            if(lstJourneys[0].Primary_contact__c != null){
                List<Contact> lstContcat = new List<Contact>();
                Settings.FieldMappings mapContactToActivity;
                set<String> setContactFields = new set<String>();
                list<String> lstContactFields = new list<String>();
                mapContactToActivity = Settings.getFieldMappings('ContactToActivity');
                Debug.log('In WeWorkengine mapContactToActivity :: '+mapContactToActivity);
                if(mapContactToActivity == null)
                    mapContactToActivity = Contact2Activity();
                for(Settings.MappedField field : mapContactToActivity.mappings.values()){
                    setContactFields.add(field.fieldname.toLowerCase());
                }
                lstContactFields.addAll(setContactFields);
                Debug.log('setContactFields :: '+setContactFields);
                Debug.log('lstContactFields ::'+lstContactFields);
                Debug.log('mapContactToActivity.mappings.keySet() :: '+mapContactToActivity.mappings.keySet());   
                
                String str_contact_id = lstJourneys[0].Primary_contact__c;
                Debug.log('str_contact_id ::'+str_contact_id);
                if(str_contact_id != '')
                    lstContcat = Database.Query('Select ' + String.join(lstContactFields, ',') + ' From Contact Where Id =: str_contact_id'); 
                
                Debug.log('lstContcat ::'+lstContcat);
                if(lstContcat!=null && !lstContcat.isEmpty()){
                    newTask.Subject         = 'Follow-Up';
                    newTask.Status          = 'Not Started';
                    Date taskActivityDate   = Date.valueOf(ActivityDate);
                    newTask.ActivityDate    = taskActivityDate;             
                    newTask.WhoId           = lstContcat[0].Id;
                    newTask.WhatId          = taskWhatId;
                    newTask.Description__c  = Description;
                    Debug.log('In WeWorkEngine mapContactToActivity :: '+mapContactToActivity);
                    for(String field : mapContactToActivity.mappings.keySet()){
                        Settings.MappedField mappedField = mapContactToActivity.mappings.get(field);
                        if(mappedField.isvalue == true)
                            newTask.put(field, mappedField.value);
                        else
                            newTask.put(field, lstContcat[0].get(mappedField.fieldname));
                    }
                }
            }
            else{
                List<Lead> lstLead = new List<Lead>();
                //Settings.FieldMappings mapLeadToActivity;
                set<String> setLeadFields = new set<String>();
                list<String> lstLeadFields = new list<String>();
                mapLeadToActivity = Settings.getFieldMappings('LeadToActivity');
                if(mapLeadToActivity == null)
                    mapLeadToActivity = Contact2Activity();
                for(Settings.MappedField field : mapLeadToActivity.mappings.values()){
                    setLeadFields.add(field.fieldname.toLowerCase());
                }
                lstLeadFields.addAll(setLeadFields);
                Debug.log('setLeadFields :: '+setLeadFields);
                Debug.log('lstLeadFields ::'+lstLeadFields);
                Debug.log('mapLeadToActivity.mappings.keySet() :: '+mapLeadToActivity.mappings.keySet()); 
                String str_Lead_id = lstJourneys[0].Primary_Lead__c;
                Debug.log('str_Lead_id ::'+str_Lead_id);
                if(str_Lead_id != '')
                    lstLead = Database.Query('Select ' + String.join(lstLeadFields, ',') + ' From Lead Where Id =: str_Lead_id'); 
                Debug.log('lstLead ::'+lstLead);
                
                if(lstLead!=null && !lstLead.isEmpty()){
                    newTask.Subject         = 'Follow-Up';
                    newTask.Status          = 'Not Started';
                    Date taskActivityDate   = Date.valueOf(ActivityDate);
                    newTask.ActivityDate    = taskActivityDate;             
                    //newTask.WhoId             = lstLead[0].Id;
                    newTask.WhatId          = taskWhatId;
                    newTask.Description__c  = Description;
                    for(String field : mapLeadToActivity.mappings.keySet()){
                        Settings.MappedField mappedField = mapLeadToActivity.mappings.get(field);
                        if(mappedField.isvalue == true)
                            newTask.put(field, mappedField.value);
                        else
                            newTask.put(field, lstLead[0].get(mappedField.fieldname));
                    }
                }
            }
            
            //ST-1603
            if(newTask.OwnerId != null && ((String)newTask.OwnerId).startsWith('00G'))
            {
                newTask.OwnerId = UserInfo.getUserId();
            }
            lstNewTask.add(newTask);
            Debug.log('newTask ::'+newTask);
            Debug.log('lstNewTask ::'+lstNewTask);
            if(lstNewTask!=null && !lstNewTask.isEmpty()){
                lstAddedTask = Database.insert(lstNewTask, false);
            }
        }catch(Exception ex){
            result = 'Activities creation failed.'+ex;
        }
        return lstAddedTask;
    }
    
    
    /*
    *   Created By      : Amol Darekar
    *   Created Date    : 30 Nov 2016
    *   Summary         : This method will update journey NMD Next Contact Date and create follow-up task for journey.
    */
    @RemoteAction
    global static Boolean bulkJourneyUpdates(String journeyIds,DateTime nmdNextContactDate,String description,Integer seconds,Integer minuts,Integer hours)
    {
        try
        {
            Debug.log('seconds::'+seconds);
            Debug.log('minuts::'+minuts);
            Debug.log('hours::'+hours);
            set <String> setJourneyIds = new set<String>();
            set<String> setLeadIds = new set<String>();
            set<String> setContactIds = new set<String>();
            list<Task> lstTasks = new list<Task>();
            list<String> lstContactFields = new list<String>();
            set<String> setContactFields = new set<String>();
            Task objTask;
            setJourneyIds.addAll(journeyIds.split(','));
            Debug.log('setJourneyIds::'+setJourneyIds);
            
            //Add local time to date
            nmdNextContactDate = nmdNextContactDate.addSeconds(seconds);
            nmdNextContactDate = nmdNextContactDate.addMinutes(minuts);
            nmdNextContactDate = nmdNextContactDate.addHours(hours);
            Debug.log('nmdNextContactDate::'+nmdNextContactDate);
            
            //Get values for contact field mappings
            Settings.FieldMappings mapContactToActivity; 
            mapContactToActivity = Settings.getFieldMappings('ContactToActivity');
            Debug.log('In WeWorkengine mapContactToActivity :: '+mapContactToActivity);
            
            if(mapContactToActivity == null)
                mapContactToActivity = Contact2Activity();
            
            for(Settings.MappedField field : mapContactToActivity.mappings.values()){
                setContactFields.add(field.fieldname.toLowerCase());
            }     
            lstContactFields.addAll(setContactFields);
            
            //Get Values for lead field mappings
            set<String> setLeadFields = new set<String>();
            
            list<String> lstLeadFields = new list<String>();
            
            mapLeadToActivity = Settings.getFieldMappings('LeadToActivity');
            
            if(mapLeadToActivity == null)
                mapLeadToActivity = Contact2Activity();
            
            for(Settings.MappedField field : mapLeadToActivity.mappings.values()){
                setLeadFields.add(field.fieldname.toLowerCase());
            }
            
            lstLeadFields.addAll(setLeadFields);
            
            List<Journey__c> lstJourneys = new List<Journey__c>();    
            
            lstJourneys = [SELECT Id, Name, Primary_Lead__c, Primary_Contact__c, NMD_Next_Contact_Date__c,Status__c ,Outreach_Stage__c , CreatedDate FROM Journey__c WHERE Id IN : setJourneyIds AND (Primary_Lead__c != null OR Primary_Contact__c != null)];
            
            for(Journey__c currentJourney : lstJourneys)
            {
                if(currentJourney.Primary_Lead__c !=null)
                    setLeadIds.add(currentJourney.Primary_Lead__c);
                else if(currentJourney.Primary_Contact__c !=null)
                    setContactIds.add(currentJourney.Primary_Contact__c);
            }
            
            list<contact> lstContact = Database.Query('Select ' + String.join(lstContactFields, ',') + ' From Contact Where Id IN : setContactIds');
            
            list<lead> lstLead =   Database.Query('Select ' + String.join(lstLeadFields, ',') + ' From Lead Where Id IN : setLeadIds');
            
            map<Id,Contact> mapJourneyContacts = new map<Id,Contact>();
            
            for(Contact currentContact : lstContact)
            {
                mapJourneyContacts.put(currentContact.Id,currentContact);
            }
            
            map<Id,Lead> mapJourneyLeads = new map<Id,Lead>();
            
            for(Lead currentLead : lstLead)
            {
                mapJourneyLeads.put(currentLead.Id,currentLead);
            }
            
            for(Journey__c currentJourney : lstJourneys)
            {
                objTask = new Task();
                objTask.Type = 'Call';
                objTask.Subject = 'Follow-Up';
                objTask.Status = 'Not Started';             
                objTask.WhoId = currentJourney.Primary_Contact__c;
                objTask.WhatId = currentJourney.Id;
                objTask.ActivityDate =nmdNextContactDate.Date();
                
                if(currentJourney.Primary_Contact__c != null)
                {
                    Contact objContact = mapJourneyContacts.get(currentJourney.Primary_Contact__c);
                    for(String field : mapContactToActivity.mappings.keySet()){
                        Settings.MappedField mappedField = mapContactToActivity.mappings.get(field);
                        if(mappedField.isvalue == true)
                            objTask.put(field, mappedField.value);
                        else
                            objTask.put(field, objContact.get(mappedField.fieldname));
                    }
                }
                else if(currentJourney.Primary_Lead__c != null)
                {
                    Lead objLead = mapJourneyLeads.get(currentJourney.Primary_Lead__c);
                    for(String field : mapLeadToActivity.mappings.keySet()){
                        Settings.MappedField mappedField = mapLeadToActivity.mappings.get(field);
                        if(mappedField.isvalue == true)
                            objTask.put(field, mappedField.value);
                        else
                            objTask.put(field, objLead.get(mappedField.fieldname));
                    }
                }
                
                //ST-1603
                if(objTask.OwnerId != null && (String.valueOf(objTask.OwnerId)).startsWith('00G'))
                {
                    objTask.OwnerId = UserInfo.getUserId();
                }
                objTask.Description__c = description;
                lstTasks.add(objTask);
                
                
                if(Math.round(dateDiff(currentJourney.CreatedDate,nmdNextContactDate)) > 48)
                {
                    if(currentJourney.Status__c =='Started'){
                        currentJourney.Outreach_Stage__c ='Manual Outreach';
                    }
                }
                currentJourney.NMD_Next_Contact_Date__c = nmdNextContactDate.Date();
            }
            
            update lstJourneys;
            insert lstTasks;
            Set<Id> setNewTasks = new Set<Id>(); 
            for(Task t : lstTasks) {
                setNewTasks.add(t.Id);
            }
            List<Task> taskToUpdate = new List<Task>();
            for(Task t : [SELECT Id, Status FROM Task WHERE Id NOT IN :setNewTasks AND WhatId IN :setJourneyIds AND Status != 'Completed']) {
                t.Status = 'Completed';
                taskToUpdate.add(t);
            }
            update taskToUpdate;
            return true;
        }
        catch(Exception ex)
        {
            Debug.log('Exception occured while updating journeys::'+ex);
            Debug.log('Exception occured on Line::'+ex.getLineNumber());
            return false;
        }
    }
    
    /*
    *   Created By      : Amol Darekar
    *   Created Date    : 1 Dec 2016
    *   Summary         : This method will return difference between 2 date in hours.
    */
    public static Long dateDiff(DateTime createdDate, DateTime nmdNextNmdDate)
    {
        
        Debug.Log('dateDiff createdDate::'+createdDate);
        Debug.Log('dateDiff nmdNextNmdDate::'+nmdNextNmdDate);
        Long dt1Long = createdDate.getTime();
        Long dt2Long = nmdNextNmdDate.getTime();
        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        Decimal rem =  Math.mod(minutes, 60);
        Decimal hours = minutes/ 60;
        system.debug('rem'+rem);
        if(rem > 30)
        {
            Decimal dc = 0.6; 
            hours += dc;
            system.debug('hours'+hours);
        }
        system.debug('hours+rem'+Math.round(hours));
        return Math.round(hours);
    }
    
    public static String getLocaleToDateTimeFmtMap () {
        if (localeToDateTimeFmtMap == null)
            localeToDateTimeFmtMap  = new Map<String,String> {
                'ar'            => 'dd/MM/yyyy',
                    'ar_AE'         => 'dd/MM/yyyy',
                    'ar_BH'         => 'dd/MM/yyyy',
                    'ar_JO'         => 'dd/MM/yyyy',
                    'ar_KW'         => 'dd/MM/yyyy',
                    'ar_LB'         => 'dd/MM/yyyy',
                    'ar_SA'         => 'dd/MM/yyyy',
                    'bg_BG'         => 'yyyy-M-d',
                    'ca'            => 'dd/MM/yyyy',
                    'ca_ES'         => 'dd/MM/yyyy',
                    'ca_ES_EURO'    => 'dd/MM/yyyy',
                    'cs'            => 'd.M.yyyy',
                    'cs_CZ'         => 'd.M.yyyy',
                    'da'            => 'dd-MM-yyyy',
                    'da_DK'         => 'dd-MM-yyyy',
                    'de'            => 'dd.MM.yyyy',
                    'de_AT'         => 'dd.MM.yyyy',
                    'de_AT_EURO'    => 'dd.MM.yyyy',
                    'de_CH'         => 'dd.MM.yyyy',
                    'de_DE'         => 'dd.MM.yyyy',
                    'de_DE_EURO'    => 'dd.MM.yyyy',
                    'de_LU'         => 'dd.MM.yyyy',
                    'de_LU_EURO'    => 'dd.MM.yyyy',
                    'el_GR'         => 'd/M/yyyy',
                    'en_AU'         => 'd/MM/yyyy',
                    'en_B'          => 'M/d/yyyy',
                    'en_BM'         => 'M/d/yyyy',
                    'en_CA'         => 'dd/MM/yyyy',
                    'en_GB'         => 'dd/MM/yyyy',
                    'en_GH'         => 'M/d/yyyy',
                    'en_HK'         => 'dd/MM/yyyy',
                    'en_ID'         => 'dd/MM/yyyy',
                    'en_IE'         => 'dd/MM/yyyy',
                    'en_IE_EURO'    => 'dd/MM/yyyy',
                    'en_IN'         => 'dd/MM/yyyy',
                    'en_NZ'         => 'd/MM/yyyy',
                    'en_SG'         => 'dd/MM/yyyy',
                    'en_UG'         => 'M/d/yyyy',
                    'en_US'         => 'M/d/yyyy',
                    'en_VU'         => 'M/d/yyyy',
                    'en_ZA'         => 'yyyy/MM/dd',
                    'es'            => 'd/MM/yyyy',
                    'es_AR'         => 'dd/MM/yyyy',
                    'es_BO'         => 'dd-MM-yyyy',
                    'es_CL'         => 'dd-MM-yyyy',
                    'es_CO'         => 'd/MM/yyyy',
                    'es_CR'         => 'dd/MM/yyyy',
                    'es_EC'         => 'dd/MM/yyyy',
                    'es_ES'         => 'd/MM/yyyy',
                    'es_ES_EURO'    => 'd/MM/yyyy',
                    'es_GT'         => 'd/MM/yyyy',
                    'es_HN'         => 'MM-dd-yyyy',
                    'es_MX'         => 'd/MM/yyyy',
                    'es_PE'         => 'dd/MM/yyyy',
                    'es_PR'         => 'MM-dd-yyyy',
                    'es_PY'         => 'dd/MM/yyyy',
                    'es_SV'         => 'MM-dd-yyyy',
                    'es_UY'         => 'dd/MM/yyyy',
                    'es_VE'         => 'dd/MM/yyyy',
                    'et_EE'         => 'd.MM.yyyy',
                    'fi'            => 'd.M.yyyy',
                    'fi_FI'         => 'd.M.yyyy',
                    'fi_FI_EURO'    => 'd.M.yyyy',
                    'fr'            => 'dd/MM/yyyy',
                    'fr_BE'         => 'd/MM/yyyy',
                    'fr_CA'         => 'yyyy-MM-dd',
                    'fr_CH'         => 'dd.MM.yyyy',
                    'fr_FR'         => 'dd/MM/yyyy',
                    'fr_FR_EURO'    => 'dd/MM/yyyy',
                    'fr_LU'         => 'dd/MM/yyyy',
                    'fr_MC'         => 'dd/MM/yyyy',
                    'hr_HR'         => 'yyyy.MM.dd',
                    'hu'            => 'yyyy.MM.dd.',
                    'hy_AM'         => 'M/d/yyyy',
                    'ga_IE'         => 'dd/MM/yyyy',
                    'in_ID'         => 'dd/MM/yyyy',
                    'is_IS'         => 'd.M.yyyy',
                    'it'            => 'dd/MM/yyyy',
                    'it_CH'         => 'dd.MM.yyyy',
                    'it_IT'         => 'dd/MM/yyyy',
                    'iw'            => 'dd/MM/yyyy',
                    'iw_IL'         => 'dd/MM/yyyy',
                    'ja'            => 'yyyy/MM/dd',
                    'ja_JP'         => 'yyyy/MM/dd',
                    'kk_KZ'         => 'M/d/yyyy',
                    'km_KH'         => 'M/d/yyyy',
                    'ko'            => 'yyyy. M. d',
                    'ko_KP'         => 'yyyy. M. d',
                    'ko_KR'         => 'yyyy. M. d',
                    'lt_LT'         => 'yyyy.M.d',
                    'lv_LV'         => 'yyyy.d.M',
                    'ms_MY'         => 'dd/MM/yyyy',
                    'nl'            => 'd-M-yyyy',
                    'nl_BE'         => 'd/MM/yyyy',
                    'nl_NL'         => 'd-M-yyyy',
                    'nl_SR'         => 'd-M-yyyy',
                    'no'            => 'dd.MM.yyyy',
                    'no_NO'         => 'dd.MM.yyyy',
                    'pl'            => 'yyyy-MM-dd',
                    'pt'            => 'dd-MM-yyyy',
                    'pt_AO'         => 'dd-MM-yyyy',
                    'pt_BR'         => 'dd/MM/yyyy',
                    'pt_PT'         => 'dd-MM-yyyy',
                    'ro_RO'         => 'dd.MM.yyyy',
                    'ru'            => 'dd.MM.yyyy',
                    'sk_SK'         => 'd.M.yyyy',
                    'sl_SI'         => 'd.M.y',
                    'sv'            => 'yyyy-MM-dd',
                    'sv_SE'         => 'yyyy-MM-dd',
                    'th'            => 'M/d/yyyy',
                    'th_TH'         => 'd/M/yyyy',
                    'tr'            => 'dd.MM.yyyy',
                    'ur_PK'         => 'M/d/yyyy',
                    'vi_VN'         => 'dd/MM/yyyy',
                    'zh'            => 'yyyy-M-d',
                    'zh_CN'         => 'yyyy-M-d',
                    'zh_HK'         => 'dd/M/yyyy',
                    'zh_HK_STROKE'  => 'dd/M/yyyy',
                    'zh_TW'         => 'yyyy/M/d'
                    };
                        Debug.log('Test : UserInfo.getLocale() ::: ' + UserInfo.getLocale());
        return localeToDateTimeFmtMap.get(UserInfo.getLocale());
    }
    
    @RemoteAction
    global static Long callDateDiff(DateTime createdDate, DateTime nmdDate, Integer seconds, Integer minuts, Integer hours)
    {
        try
        {
            Debug.log('Test : createdDate ::: ' + createdDate);
            Debug.log('Test : nmdContactDate ::: ' + nmdDate);
            Debug.log('Test : seconds ::: ' + seconds);
            Debug.log('Test : minuts ::: ' + minuts);
            Debug.log('Test : hours ::: ' + hours);
            String dt = nmdDate.format(getLocaleToDateTimeFmtMap());
            DateTime nmdNextContactDate = Date.parse(dt);
            Debug.log('Test : nmdNextContactDate==>'+nmdNextContactDate);
            nmdNextContactDate = nmdNextContactDate.addSeconds(seconds);
            nmdNextContactDate = nmdNextContactDate.addMinutes(minuts);
            nmdNextContactDate = nmdNextContactDate.addHours(hours);
            Debug.log('Test : callDateDiff nmdNextContactDate::'+nmdNextContactDate);
            Long diffInHours = dateDiff(createdDate,nmdNextContactDate);
            return Math.round(diffInHours);
        }
        catch(Exception ex)
        {
            Debug.log('Test : Exception occured while updating journeys::'+ex);
            Debug.log('Test : Exception occured on Line::'+ex.getLineNumber());
            return null;
        }
    }
    
    public static Settings.FieldMappings Journey2Journey() {
        Settings.FieldMappings JourneyToJourneyMappings = new Settings.FieldMappings();
        JourneyToJourneyMappings.version = 1;
        JourneyToJourneyMappings.mappings = new Map<String, Settings.MappedField>();
        JourneyToJourneyMappings.mappings.put('Primary_Contact__c', new Settings.MappedField('Primary_Contact__c'));
        JourneyToJourneyMappings.mappings.put('Primary_Lead__c', new Settings.MappedField('Primary_Lead__c'));
        return JourneyToJourneyMappings;
    }
    public static Settings.FieldMappings mapJourneyToJourney;
    static List<String> lstJourneyFields = null;
    public static List<String> getJourneyFields(){
        mapJourneyToJourney = Settings.getFieldMappings('JourneyToJourney');
        if( mapJourneyToJourney == null ) mapJourneyToJourney = Journey2Journey();
        if( lstJourneyFields == null ){
            Set<String> setJourneyFields = new Set<String>();
            setJourneyFields.add('Primary_Contact__c');
            setJourneyFields.add('Primary_Lead__c');
            for(Settings.MappedField field : mapJourneyToJourney.mappings.values()){
                if(!setJourneyFields.contains(field.fieldname))
                    setJourneyFields.add(field.fieldname.toLowerCase());
            }
            lstJourneyFields = new List<String>();
            lstJourneyFields.addAll(setJourneyFields);
        }
        return lstJourneyFields;
    }
    
    /**
    * @author pranay.jadhav@wework.com.dev5
    * @Issue : ST-650 Sales Console : VF Page JourneyActions : Send To Enterprise
    * @description : Existing Journey stage Change to Transferred and create new Journey with stage Started with Owner 'Enterprise Queue' and Record Type ='Enterprise Solution' and create task to related contact and lead
    * @date : 31/Aug/2016
    */
    @RemoteAction
    global static JourneyStageUpdateResult sendToEnterpriseJourney(Id journeyId) {
        List<Journey__c> lstJourneyToUpdate;
        List<Task> lstTaskToInsert;
        JourneyStageUpdateResult stageChangeResult = new JourneyStageUpdateResult();
        Journey__c objJourney = new Journey__c();
        List<Group> lstOwnerInfo;
        try{
            objJourney = Database.Query('SELECT ' + String.join(getJourneyFields(), ',') + ' FROM Journey__c WHERE Id =: journeyId LIMIT 1');
            if(objJourney != null){
                lstOwnerInfo = [SELECT Id FROM Group WHERE Name = 'Enterprise Queue' limit 1];
            }
            if(objJourney != null){
                if(hasSObjectField('Primary_Lead__c', objJourney)){
                    List<Lead> lstLeads = [SELECT Id,(SELECT Id,Status__c FROM Journeys__r) FROM Lead WHERE Id =:objJourney.Primary_Lead__c];
                    lstJourneyToUpdate = new List<Journey__c>();
                    lstTaskToInsert = new List<Task>();
                    for (Lead l : lstLeads) {
                        if(l.Journeys__r.size() > 0){
                            for(Journey__c obj : l.Journeys__r){
                                if(obj.Status__c !='Transferred'){
                                    obj.Status__c = 'Transferred';
                                    lstJourneyToUpdate.add(obj);
                                }
                            }
                            if(lstJourneyToUpdate.size() > 0){
                                for(Journey__c journeyObj : lstJourneyToUpdate){
                                    Task newTask = new Task();
                                    newTask.WhoId = l.Id;
                                    newTask.Type = 'Other';
                                    newTask.Status = 'Completed';
                                    newTask.Subject = 'Journey Action : Send To Enterprise';
                                    newTask.CallDisposition = 'User sent this member to the Enterprise Team';
                                    lstTaskToInsert.add(newTask);
                                }
                            }else{
                                stageChangeResult.result = 'No further actions possible as the member is not eligible for Enterprise Solution.';
                                stageChangeResult.totalCount = lstJourneyToUpdate.size();
                                stageChangeResult.errorType = 'error';
                                return stageChangeResult;
                            }
                        }
                    }
                    
                    Journey__c objNewJourney = new Journey__c();
                    objNewJourney.UserType__c = 'Enterprise Solutions';
                    objNewJourney.OwnerId = lstOwnerInfo.get(0).Id;
                    for(String field : mapJourneyToJourney.mappings.keySet()){
                        Settings.MappedField mappedField = mapJourneyToJourney.mappings.get(field);
                        if(mappedField.isvalue == true)
                            objNewJourney.put(field, mappedField.value);
                        else
                            objNewJourney.put(field, objJourney.get(mappedField.fieldname));
                    }
                    Debug.Log('Queries objNewJourney ====>> '+objNewJourney);
                    
                    Lead leadToUpdate = new Lead();
                    leadToUpdate.Id = objJourney.Primary_Lead__c;
                    leadToUpdate.RecordTypeId  = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
                    leadToUpdate.OwnerId = lstOwnerInfo.get(0).Id;
                    List<Lead> lstleadToUpdate = new List<Lead>();
                    lstleadToUpdate.add(leadToUpdate);
                    SaveRecords(lstleadToUpdate);
                    insert objNewJourney;
                    insert lstTaskToInsert;
                    update lstJourneyToUpdate;
                    
                    stageChangeResult.result = 'The member is send to the Enterprise Solution Team successfully';
                    stageChangeResult.totalCount = lstJourneyToUpdate.size();
                    stageChangeResult.errorType = 'success';
                    return stageChangeResult;
                    
                }else if(hasSObjectField('Primary_Contact__c', objJourney)){
                    List<Contact> lstContacts = [SELECT Id,AccountId,(Select Id,Status__c,Outreach_Stage__c FROM Journeys__r) FROM Contact WHERE Id =:objJourney.Primary_Contact__c];
                    lstJourneyToUpdate = new List<Journey__c>();
                    lstTaskToInsert = new List<Task>();
                    for (Contact c : lstContacts) {
                        if(c.Journeys__r.size() > 0){
                            for(Journey__c obj : c.Journeys__r){
                                if(obj.Status__c !='Transferred'){
                                    obj.Status__c = 'Transferred';
                                    lstJourneyToUpdate.add(obj);
                                }
                            }
                            if(lstJourneyToUpdate.size() > 0){
                                for(Journey__c journeyObj : lstJourneyToUpdate){
                                    Task newTask = new Task();
                                    newTask.WhatId = journeyObj.Id;
                                    newTask.WhoId = c.Id;
                                    newTask.Type = 'Other';
                                    newTask.Status = 'Completed';
                                    newTask.Subject = 'Journey Action : Send To Enterprise';
                                    newTask.CallDisposition = 'User sent this member to the Enterprise Team';
                                    lstTaskToInsert.add(newTask);
                                }
                            }else{
                                stageChangeResult.result = 'No further actions possible as the member is not eligible for Enterprise Solution.';
                                stageChangeResult.totalCount = lstJourneyToUpdate.size();
                                stageChangeResult.errorType = 'error';
                                return stageChangeResult;
                            }
                        }
                    }
                    
                    Journey__c objNewJourney = new Journey__c();
                    objNewJourney.UserType__c = 'Enterprise Solutions';
                    objNewJourney.OwnerId = lstOwnerInfo.get(0).Id;
                    for(String field : mapJourneyToJourney.mappings.keySet()){
                        Settings.MappedField mappedField = mapJourneyToJourney.mappings.get(field);
                        if(mappedField.isvalue == true)
                            objNewJourney.put(field, mappedField.value);
                        else
                            objNewJourney.put(field, objJourney.get(mappedField.fieldname));
                    }
                    
                    List<sObject> lstToUpdate = new List<sObject>();
                    Contact ContactToUpdate = new Contact();
                    ContactToUpdate.Id = lstContacts.get(0).Id;
                    ContactToUpdate.RecordTypeId  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
                    //ContactToUpdate.OwnerId = lstOwnerInfo.get(0).Id;
                    lstToUpdate.add(ContactToUpdate);
                    
                    if(hasSObjectField('AccountId', lstContacts.get(0))){
                        Account accountToUpdate = new Account();
                        accountToUpdate.Id = lstContacts.get(0).AccountId;
                        accountToUpdate.RecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
                        //accountToUpdate.OwnerId = lstOwnerInfo.get(0).Id;
                        lstToUpdate.add(accountToUpdate);
                    }
                    Debug.Log('Update Contact ======>>>'+ lstToUpdate);
                    update lstToUpdate;
                    insert objNewJourney;
                    insert lstTaskToInsert;
                    update lstJourneyToUpdate;
                    
                    stageChangeResult.result = 'The member is send to the Enterprise Solution Team successfully';
                    stageChangeResult.totalCount = lstJourneyToUpdate.size();
                    stageChangeResult.errorType = 'success';
                    return stageChangeResult;
                }
            }
            stageChangeResult.result = 'Journeys not found for given Id or Primary Contact/Lead not assigned';
            stageChangeResult.totalCount = 0;
            stageChangeResult.errorType = 'error';
            return stageChangeResult;
        }catch(Exception exc){
            stageChangeResult.result = 'Error occurred error.';
            stageChangeResult.totalCount = 0;
            stageChangeResult.errorType = 'error';
            return stageChangeResult;
        }
    }
    
    /**
    * @author pranay.jadhav@wework.com.dev5
    * @Issue : ST-654 Sales Console : New Button : Manual Outreach
    * @description : All the Journey stage Change to Manual Outreach.
    * @date : 01/Aug/2016
    */
    @RemoteAction
    global static JourneyStageUpdateResult setJourneyStageToManualOutreach(Id journeyId) {
        List<Journey__c> lstJourneyToUpdate;
        List<Task> lstTaskToInsert;
        JourneyStageUpdateResult stageChangeResult = new JourneyStageUpdateResult();
        Journey__c objJourney = new Journey__c();
        objJourney = Database.Query('SELECT Id,Primary_Lead__c,Primary_Contact__c FROM Journey__c WHERE Id =: journeyId LIMIT 1');
        if(objJourney != null){
            if(hasSObjectField('Primary_Lead__c', objJourney)){
                List<Lead> lstLeads = [SELECT Id,(SELECT Id,Status__c FROM Journeys__r) FROM Lead WHERE Id =:objJourney.Primary_Lead__c];
                lstJourneyToUpdate = new List<Journey__c>();
                lstTaskToInsert = new List<Task>();
                for (Lead l : lstLeads) {
                    if(l.Journeys__r.size() > 0){
                        for(Journey__c obj : l.Journeys__r){
                            if(obj.Status__c =='Started'){
                                obj.Outreach_Stage__c ='NMD Drip';
                                lstJourneyToUpdate.add(obj);
                            }
                        }
                        if(lstJourneyToUpdate.size() > 0){
                            for(Journey__c journeyObj : lstJourneyToUpdate){
                                Task newTask = new Task();
                                newTask.WhoId = l.Id;
                                newTask.Type = 'Other';
                                newTask.Status = 'Completed';
                                newTask.Subject = 'Journey Action : Manual Outreach';
                                newTask.CallDisposition = 'User sent this member to the Manual Outreach';
                                lstTaskToInsert.add(newTask);
                            }
                        }else{
                            stageChangeResult.result = 'No further actions possible as the member is not eligible for Manual Outreach.';
                            stageChangeResult.totalCount = lstJourneyToUpdate.size();
                            stageChangeResult.errorType = 'error';
                            return stageChangeResult;
                        }
                    }
                }
                
                insert lstTaskToInsert;
                update lstJourneyToUpdate;
                
                stageChangeResult.result = 'The member is send to the added to Manaual Outreach successfully';
                stageChangeResult.totalCount = lstJourneyToUpdate.size();
                stageChangeResult.errorType = 'success';
                return stageChangeResult;
                
            }else if(hasSObjectField('Primary_Contact__c', objJourney)){
                List<Contact> lstContacts = [SELECT Id,(Select Id,Status__c,Outreach_Stage__c FROM Journeys__r) FROM Contact WHERE Id =:objJourney.Primary_Contact__c];
                lstJourneyToUpdate = new List<Journey__c>();
                lstTaskToInsert = new List<Task>();
                for (Contact c : lstContacts) {
                    if(c.Journeys__r.size() > 0){
                        for(Journey__c obj : c.Journeys__r){
                            if(obj.Status__c =='Started'){
                                obj.Outreach_Stage__c ='NMD Drip';
                                lstJourneyToUpdate.add(obj);
                            }
                        }
                        if(lstJourneyToUpdate.size() > 0){
                            for(Journey__c journeyObj : lstJourneyToUpdate){
                                Task newTask = new Task();
                                newTask.WhatId = journeyObj.Id;
                                newTask.WhoId = c.Id;
                                newTask.Type = 'Other';
                                newTask.Status = 'Completed';
                                newTask.Subject = 'Journey Action : Manual Outreach';
                                newTask.CallDisposition = 'User sent this member to the Manual Outreach';
                                lstTaskToInsert.add(newTask);
                            }
                        }else{
                            stageChangeResult.result = 'No further actions possible as the member is not eligible for Manual Outreach.';
                            stageChangeResult.totalCount = lstJourneyToUpdate.size();
                            stageChangeResult.errorType = 'error';
                            return stageChangeResult;
                        }
                    }
                }
                insert lstTaskToInsert;
                update lstJourneyToUpdate;
                
                stageChangeResult.result = 'The member is send to the added to Manaual Outreach successfully';
                stageChangeResult.totalCount = lstJourneyToUpdate.size();
                stageChangeResult.errorType = 'success';
                return stageChangeResult;
            }
        }
        stageChangeResult.result = 'Journeys not found for given Id or Primary Contact/Lead not assigned';
        stageChangeResult.totalCount = 0;
        stageChangeResult.errorType = 'error';
        return stageChangeResult;
    }
    
    /*
    *   Created By      : Dipak Pawar
    *   Created Date    : 23-09-2016
    *   Summary         : This method will accepts the exception and return it with proper formatting.
    *   Issue No.       : ST-701
    */
    global static String exceptionFormatter(Exception exc) {
        String errorMessage = (exc.getMessage().contains('\'')) ? exc.getMessage().replace('\'', '') :  exc.getMessage();
        if(errorMessage.containsIgnoreCase('first error:') && errorMessage.containsIgnoreCase(': [')) {
            errorMessage = errorMessage.substring(errorMessage.indexOf('first error:')+12,errorMessage.lastIndexOf(': [')).replace('_', ' ');
        }
        errorMessage=errorMessage+'StackTrace :'+exc.getStackTraceString();
        return errorMessage.toLowerCase().trim().capitalize();
    }
    
    /*
    *   Created By      : Dipak Pawar
    *   Created Date    : 5-10-2016
    *   Issue No.       : ST-719
    */
    @RemoteAction
    global static Map<String,List<Object>> getJourneyOpportunityData(String accountId, String contactId, String journeyId){
        Debug.log('accountId :: '+accountId); 
        Debug.log('contactId :: '+contactId);
        Map<String,List<Object>> mapReturnData = new Map<String,List<Object>>();
        List<Object> accountObject = new List<Object>();
        List<Object> contactObject = new List<Object>();
        List<Object> journeyObject = new List<Object>();
        Account accountRecord = [SELECT Id, OwnerId, RecordType.Name, Number_of_Full_Time_Employees__c, Company_Size__c, Unomy_Company_Size__c, Interested_in_Number_of_Desks__c FROM Account WHERE Id =:accountId]; 
        accountObject.add(accountRecord);
        
        Contact contactRecord = [SELECT Id, Number_of_Full_Time_Employees__c, Interested_in_Number_of_Desks__c, Location__r.Name, Location_Interested__c FROM Contact WHERE Id =:contactId];
        contactObject.add(contactRecord);
        
        Journey__c journeyRecord = [Select Id, Building_Interested_In__r.Name from Journey__c where Id =: journeyId];
        journeyObject.add(journeyRecord);
        
        mapReturnData.put('buildingList',WeworkEngine.getBuildingList('wework'));        
        mapReturnData.put('oppRecordTypes',[Select Id,Name from RecordType where SObjectType = 'Opportunity']);
        mapReturnData.put('journeyObject',journeyObject);
        mapReturnData.put('accountObject',accountObject);
        mapReturnData.put('contactObject',contactObject);
        debug.Log('mapReturnData 1:'+mapReturnData);
        return mapReturnData;
    }
    
    public static Settings.FieldMappings Contact2Opportunity() {        
        Settings.FieldMappings contactToActivityMappings = new Settings.FieldMappings();        
        contactToActivityMappings.version = 1;      
        contactToActivityMappings.mappings = new Map<String, Settings.MappedField>();       
        contactToActivityMappings.mappings.put('LeadSource', new Settings.MappedField('LeadSource'));       
        contactToActivityMappings.mappings.put('Lead_Source_Detail__c', new Settings.MappedField('Lead_Source_Detail__c'));                 
        contactToActivityMappings.mappings.put('utm_campaign_id__c', new Settings.MappedField('utm_campaign_id__c'));
        contactToActivityMappings.mappings.put('utm_content__c', new Settings.MappedField('utm_content__c')); 
        contactToActivityMappings.mappings.put('utm_medium__c', new Settings.MappedField('utm_medium__c')); 
        contactToActivityMappings.mappings.put('utm_source__c', new Settings.MappedField('utm_source__c')); 
        return contactToActivityMappings;       
    }       
    
    /*      
    *   Created By      : Dipak Pawar       
    *   Created Date    : 11-Jan-2017       
    *   Issue No.       : ST-856        
    */      
    @RemoteAction       
    global static List<SaveResult> addOpportunity(List<SObject> recordsToSave, Id contactId){       
        List<sObject> lstRecords = new List<sObject>();     
        List<SaveResult> result;        
        Settings.FieldMappings mapContactToOpportunity;     
        set<String> setContactFields = new set<String>();       
        list<String> lstContactFields = new list<String>();     
        List<Contact> lstContcat = new List<Contact>();
        Set<String> interestedLocations = new Set<String>();    
        Debug.log('recordsToSave :: '+recordsToSave);       
        
        for(SObject obj : recordsToSave){   
            if( obj.Id == null || String.valueOf(obj.Id).startsWith('006')){        
                Opportunity oppObject = (Opportunity)obj;       
                
                mapContactToOpportunity = Settings.getFieldMappings('ContactToOpportunity');        
                if(mapContactToOpportunity == null)     
                    mapContactToOpportunity = Contact2Opportunity();        
                Debug.log('mapContactToOpportunity :: '+mapContactToOpportunity);       
                for(Settings.MappedField field : mapContactToOpportunity.mappings.values()){        
                    setContactFields.add(field.fieldname.toLowerCase());        
                }       
                Debug.log('setContactFields :: '+setContactFields);     
                lstContactFields.addAll(setContactFields);      
                Debug.log('lstContactFields :: '+lstContactFields);     
                lstContcat = Database.Query('Select ' + String.join(lstContactFields, ',') + ' From Contact Where Id =: contactId');        
                Debug.log('lstContcat ::: ' + lstContcat);      
                if(lstContcat != null && lstContcat.size()>0)       
                {       
                    for(String field : mapContactToOpportunity.mappings.keySet()){      
                        Settings.MappedField mappedField = mapContactToOpportunity.mappings.get(field);     
                        if(mappedField.isvalue == true){        
                            oppObject.put(field, mappedField.value);                            
                        } else {
                            if(oppObject.get(field) == null || oppObject.get(field) == ''){
                                oppObject.put(field, lstContcat[0].get(mappedField.fieldname));
                            }
                        }       
                    }       
                }
                //oppObject.Locations_Interested__c = String.join(new List<String>(interestedLocations), ';');
                Debug.log('oppObject ::: ' + oppObject);
                obj = oppObject;        
            }
            if( obj.Id != null && String.valueOf(obj.Id).startsWith('001')){
                Account acc = (Account)obj;
                if(acc.RecordTypeId != null && acc.Number_of_Full_Time_Employees__c != null){
                    Integer companySize = acc.Number_of_Full_Time_Employees__c.intValue();
                    if(Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.RecordTypeId).getName().toLowerCase() == 'consumer'){
                        Debug.log('Test : Account ::: ' + acc);
                        Debug.log('Test : companySize ::: ' + companySize);
                        Setting__c accountRecordTypeSettings = Settings.get('AccountRecordTypeSettings');
                        Debug.log('accountRecordTypeSettings :: '+accountRecordTypeSettings);
                        List<RecordTypeSize> recordTypeSettings =  new List<RecordTypeSize>();
                        if(accountRecordTypeSettings != null){
                            recordTypeSettings = (List<RecordTypeSize>)JSON.deserialize(accountRecordTypeSettings.Data__c ,List<RecordTypeSize>.class);                 
                        }
                        Debug.log('recordTypeSettings :: '+recordTypeSettings);             
                        if(recordTypeSettings!=null){   
                            for(WeworkEngine.RecordTypeSize currentRecordType : recordTypeSettings){
                                if(currentRecordType.Size.contains('-') && companySize <= Integer.valueOf(currentRecordType.Size.split('-')[1]) && companySize >= Integer.valueOf(currentRecordType.Size.split('-')[0])){
                                    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(String.valueOf(currentRecordType.RecordType)).getRecordTypeId();
                                    Debug.log('acc :: '+acc);
                                    Debug.log('currentRecordType.Size :: '+currentRecordType.Size);
                                }else if(currentRecordType.Size.contains('+') && companySize >= Integer.valueOf(currentRecordType.Size.removeEnd('+'))){
                                    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(String.valueOf(currentRecordType.RecordType)).getRecordTypeId();
                                    Debug.log('acc :: '+acc);
                                    Debug.log('currentRecordType.Size :: '+currentRecordType.Size);
                                }
                            }
                        }
                        /*if(companySize >=50 && companySize < 500)
                        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
                        else if(companySize >= 500)
                        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
                        */
                    }
                }
                Debug.log('Test : acc ::: ' + acc);
                obj = acc;
            }                   
            lstRecords.add(obj);                    
        }               
        
        Debug.log('lstRecords :: '+lstRecords);     
        result = SaveRecords(lstRecords);
        Debug.log('result :: '+result);
        Debug.log('result.size() :: '+result.size());       
        return result;      
    }
    
    public class RecordTypeSize {
        public String Size {get;set;}
        public String RecordType {get;set;}
    }
    
    /*
    *   Created By      : Anat Kumar
    *   Modified By     : Amol Darekar 
    *   Created Date    : 10/12/2016
    *   Summary         : This method will return recordtype Id for Object.
    */
    @RemoteAction
    global static string getObjectRecordTypeId(string objectName,string recordtypeName)
    {
        String[] types = new String[]{objectName};
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        Schema.DescribeSObjectResult d = results[0];
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        return rtMapByName.get(recordtypeName).getRecordTypeId();
    }
    
    
    /*
    *   Created By      : Ajaysinh Chauhan
    *   Created Date    : 10/15/2016
    *   Summary         : This method will reassign lead which is having owner as site user.
    */
    @RemoteAction
    global static List<SaveResult> SaveWebsiteLead(List<Lead> lstLead){
        System.debug('save');
        List<SaveResult> lstResult = WeworkEngine.SaveRecords(lstLead);
        //WeworkEngine.reassignGuestUser(lstLead);
        return lstResult;
    }
    
    @InvocableMethod
    global static void reassignGuestUser(List<Lead> objLead){
        System.debug('reassign');
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        Database.update(objLead,dmo);
        
    }
    @RemoteAction
    global static void reassignGuestUserLead(List<Lead> objLead){
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        System.debug('objLead1------'+objLead);
        objLead[0].setOptions(dmo);
        System.debug('objLead------'+objLead);
        Database.update(objLead);
        
    }
    
    /*
    *   Created By      : Amol Darekar
    *   Created Date    : 15 October 2016
    *   Summary         : This method will call from partnershipform js to create activity and journey for lead created from 
    *                     Partnership Form.
    */
    @RemoteAction
    global static List<LeadConvertor.LeadResult> CallConvertLeadToJourneys(String leadId) {
        LeadConvertor.LeadResult []lstLeadResult;
        set<Id> leadIds = new set<Id>();
        leadIds.add(leadId);
        lstLeadResult = LeadConvertor.ConvertLeadsToJourneysOverloaded(leadIds,true,true);
        return lstLeadResult;
    }
    
    
    /*
    *   Created By      : Amol Darekar
    *   Created Date    : 2 January 2017
    *   Summary         : This method will return sObject field API names
    */
    @RemoteAction
    global static list<SObjectFieldDescription> getObjectFields(string objectType)
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        
        list<SObjectFieldDescription> lstJourneyObjFields = new list<SObjectFieldDescription>();
        
        Schema.SObjectType objectSchema = schemaMap.get(objectType);
        
        Debug.log('objectSchema::'+objectSchema);
        
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
        
        Debug.log('fieldMap::'+fieldMap);
        SObjectFieldDescription objFieldDiscription;
        
        for (String fieldName: fieldMap.keySet()) {
            if(fieldMap.get(fieldName).getDescribe().getType() != Schema.DisplayType.Reference)
            {
                objFieldDiscription = new SObjectFieldDescription();
                objFieldDiscription.fieldLabel =  fieldMap.get(fieldName).getDescribe().getLabel();
                objFieldDiscription.fieldApiName = '{!'+fieldName+'}';//'{!'+objectType+'.'+fieldName+'}';
                if(fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Date || fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.DateTime)
                    objFieldDiscription.fieldType = 'Date';
                
                lstJourneyObjFields.add(objFieldDiscription);
            }
        }
        
        Setting__c objDefaultJourneySettings =  Settings.get('Campaign Wizard Settings');
        Debug.log('Test : objDefaultJourneySettings ::: ' + objDefaultJourneySettings);
        if(objDefaultJourneySettings != null)
        {
            CampaignWizardSettings objDefaultJourneyInfo = (CampaignWizardSettings)JSON.deserialize(objDefaultJourneySettings.Data__c, CampaignWizardSettings.class);
            Debug.log('Test : objDefaultJourneyInfo ::: ' + objDefaultJourneyInfo);
            
            for(SObjectFieldDescription  currentDescription : objDefaultJourneyInfo.journeydefaultid.fieldAPIs)
            {
                Debug.log('Test : currentDescription ::: ' + currentDescription);
                objFieldDiscription = new SObjectFieldDescription();
                objFieldDiscription.fieldLabel =  currentDescription.fieldLabel;
                objFieldDiscription.fieldApiName = '{!'+currentDescription.fieldApiName+'}';//'{!'+objectType+'.'+fieldName+'}';
                //objFieldDiscription.fieldType = currentDescription.getType();
                lstJourneyObjFields.add(objFieldDiscription);
            }
            
            Debug.log('{!lstJourneyObjFields::'+lstJourneyObjFields+'}');
        }
        
        return lstJourneyObjFields;
    }
    
    global class SObjectFieldDescription
    {
        public string fieldLabel{get;set;}
        public string fieldApiName{get;set;}
        public string fieldType{get;set;}
    }
    
    global class CampaignWizardSettings{
        public DefaultJourneyInfoController journeydefaultid{get;set;}
        public SuccessMessage successmessage{get;set;}
    }  
    
    global class SuccessMessage{
        public string message{get;set;}
        public Integer timeout{get;set;}
    }  
    
    global class DefaultJourneyInfoController
    {
        public string Id{get;set;}
        public list<SObjectFieldDescription> fieldAPIs {get;set;}
        public list<string> types{get;set;}
    }
    
    /*
    *   Created By      : Amol Darekar
    *   Created Date    : 16 January 2017
    *   Summary         : This method is return Picklist values
    */
    @RemoteAction
    global static List<String> getPicklistValues(String SObjectApi_name,String SObject_Field_name){ 
        List<String> lstOptionVals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(SObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(SObject_Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstOptionVals.add(a.getValue());//add the value  to our final list
        }
        
        return lstOptionVals;
    }
    
    /*
    *   Created By      : Amol Darekar
    *   Created Date    : 2 January 2017
    *   Summary         : This method will return default journey record use to show value in place of API names.
    */
    @RemoteAction
    global static Journey__c getDefaultJourneyRecord(){
        List<String> listFields = new List<String>();
        Schema.SObjectType targetObjectType = Schema.getGlobalDescribe().get('Journey__c');
        for(Schema.SObjectField field: targetObjectType.getDescribe().fields.getMap().values()){
            DescribeFieldResult fieldDescribe = field.getDescribe();
            //if(fieldDescribe.isAccessible() && fieldDescribe.isCreateable()){
            listFields.add(fieldDescribe.getname().toLowerCase()); 
            //}        
        }
        Setting__c objDefaultJourneySettings =  Settings.get('Campaign Wizard Settings');
        Debug.log('Test : objDefaultJourneySettings ::: ' + objDefaultJourneySettings);
        if(objDefaultJourneySettings != null)
        {
            CampaignWizardSettings objDefaultJourneyInfo = (CampaignWizardSettings)JSON.deserialize(objDefaultJourneySettings.Data__c, CampaignWizardSettings.class);
            
            for(SObjectFieldDescription  currentDescription : objDefaultJourneyInfo.journeydefaultid.fieldAPIs)
            {
                listFields.add(currentDescription.fieldApiName.toLowerCase());
            }
            
            String str = 'SELECT '+ String.join(listFields, ',') + ' FROM Journey__c where Id = \''+ objDefaultJourneyInfo.journeydefaultid.Id +'\'';
            debug.log('str :: '+str);
            Journey__c journey = Database.query(str);
            return journey;
        }
        return null;
    }
    
    @RemoteAction
    global static list<string> getCampaignJSONTypes(){
        Setting__c objDefaultJourneySettings =  Settings.get('Campaign Wizard Settings');
        if(objDefaultJourneySettings != null)
        {
            CampaignWizardSettings objDefaultJourneyInfo = (CampaignWizardSettings)JSON.deserialize(objDefaultJourneySettings.Data__c, CampaignWizardSettings.class);
            return objDefaultJourneyInfo.journeydefaultid.types;
        }
        return null;
    }
    
    @RemoteAction
    global static list<string> getAllUpdatableSobjectField(string sobjectName)
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get('Campaign');
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
        list<string> lstFields = new list<string>();
        
        for(String fieldName : fieldMap.keySet()) {
            if(fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                lstFields.add(fieldName);
            }
        }
        
        return lstFields;
    }
    
    @RemoteAction
    global static string getResourceURL(string resourceName)
    {
        //Fetching the resource
        string strUrl ='';
        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];
        //Checking if the result is returned or not
        if(resourceList.size() == 1)
        {
            //Getting namespace
            String namespace = resourceList[0].NamespacePrefix;
            //Resource URL
            strUrl = '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
        }
        
        return strUrl;
    }
    
   /************************************************************************************************************************************
	Author              :   Pranay Jadhav
	Description         :   This method used in custom action
	Created Date        :   21 April 2017
	Issue               :   ST-1045
	Last Modified By    :   Dipak Pawar, ST-2201 : Prevent Send Paperwork for Certain Products
	Last Modified Date  :   17 May 2018
	Last Modified By 	:	Priyanka Ambre, ST-2327 : Provide Ability for Product Support Team to Send Paperwork
 **************************************************************************************************************************************/
    webservice static string isValidOppforSendPaperwork(Id oppId) {        
        Map<String, String> mapExcludedProfiles = new Map<String, String>();
        Map<String, String> mapExcludedProductTypes = new Map<String, String>();
        Set<String> setAllowedEnterpriseProfiles = new Set<String>();
        Id enterpriseSolutionRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();

        ValidResultWithOpp validResult = new ValidResultWithOpp();
        Settings.fetchUsers();
        Setting__c sendPaperWorkSetting = new Setting__c();
        sendPaperWorkSetting = Settings.get('SendPaperworkSetting'); 
        Debug.log('sendPaperWorkSetting'+sendPaperWorkSetting);     
        SendPaperworkSetting settingData = new SendPaperworkSetting();
        settingData = (SendPaperworkSetting)JSON.deserialize(sendPaperWorkSetting.Data__c, SendPaperworkSetting.class);
        Debug.Log('settingData'+settingData);
        if(settingData.Excludedprofiles != null){
            for(String strProfile : settingData.Excludedprofiles){
                mapExcludedProfiles.put(strProfile.toLowerCase(), strProfile);
            }
        }
        Debug.log('mapExcludedProfiles---'+mapExcludedProfiles);
        
        if(settingData.ExcludedProductTypes != null){
            for(String strProductType : settingData.ExcludedProductTypes){
                mapExcludedProductTypes.put(strProductType.toLowerCase(), strProductType);
            }                  
        }
        Debug.log('mapExcludedProductTypes ==>'+mapExcludedProductTypes);      
        
        for(string strProfile : settingData.AllowedEnterpriseProfiles){
            Debug.Log('strProfile---'+strProfile);
            setAllowedEnterpriseProfiles.add(strProfile.toLowerCase());
        }
        Debug.log('setAllowedEnterpriseProfiles ==>'+setAllowedEnterpriseProfiles); 
        
        Opportunity objOpportunity = [SELECT Id,AccountId,Type__c,Account.OwnerId,Account.Account_Type__c,Billing_Account__c,Billing_Account__r.UUID__c,recordTypeID,StageName,Contract_Stage__c,Account.uuid__c,Encoded_ID__c,Building_uuid__c,Actual_Start_Date__c,OwnerId,Locations_Interested__c,Building__c,Primary_Member__c from Opportunity WHERE Id =: oppId Limit 1];
        Debug.log('objOpportunity---'+objOpportunity);
        
        List<Opportunity> lstOpportunities = [SELECT Id,AccountId,Type__c,Account.OwnerId,Account.Account_Type__c,Billing_Account__c,Billing_Account__r.UUID__c,recordTypeID,StageName,Contract_Stage__c,Account.uuid__c,Encoded_ID__c,Building_uuid__c,Actual_Start_Date__c,OwnerId,Locations_Interested__c,Building__c,Primary_Member__c from Opportunity WHERE Id =: oppId Limit 1];
        Debug.log('lstOpportunities---'+lstOpportunities);
        Map<Id,String> recTypeNameWithIdMap= new Map<Id,String>();
        List<String> lstBuildingNames = new List<String>();
        if(String.valueOf(objOpportunity.Locations_Interested__c) != null && String.valueOf(objOpportunity.Locations_Interested__c) != '')
            lstBuildingNames = String.valueOf(objOpportunity.Locations_Interested__c).split(';');
        if(lstBuildingNames != null && lstBuildingNames.size() > 0) {
            validResult.opportunityBuildings = new List<String>();
            for(Building__c building : [SELECT Id, UUID__c FROM Building__c WHERE Name IN :lstBuildingNames]) {
                if(building.UUID__c != null)
                    validResult.opportunityBuildings.add(building.UUID__c);
            }               
        }
        Debug.log('validResult.opportunityBuildings :: '+validResult.opportunityBuildings);
        
        for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().values()){
            recTypeNameWithIdMap.put(recInfo.getRecordTypeId(),recInfo.getName());
        }        
        /*
		ST-1112 : As per 'Priority Issues' sheet. User should not do Sent PaperWork, if Opportunity StageName == 'Closing' and Contract_Stage__c == 'Contract Sent' || Contract_Stage__c == 'Contract Signed'
		Opportunity Contract has been already been sent
		*/        
        User loggedInUser = Settings.mapUserById.get(userinfo.getUserId());
        
        Debug.log('loggedInUser.Profile.Name.toLowerCase()----'+loggedInUser.Profile.Name.toLowerCase());
        Debug.log('recTypeNameWithIdMap.get(objOpportunity.recordTypeID)----'+recTypeNameWithIdMap.get(objOpportunity.recordTypeID));
        
        if(objOpportunity != null && objOpportunity.Type__c != null && String.valueOf(objOpportunity.Type__c) != null && recTypeNameWithIdMap.get(objOpportunity.recordTypeID) =='Enterprise Solutions' && mapExcludedProductTypes.containsKey(String.valueOf(objOpportunity.Type__c).toLowerCase())){
            Debug.log('Inside Type__c Validation==>'+lstOpportunities[0].Type__c);
            validResult.isValid = false;
            validResult.isValidOwner = false;
            validResult.objOpportunity = null;
            //Mofified By : Dipak Pawar Date:17/05/2018                
            validResult.errorMsg ='You cannot send paperwork for this Opportunity if Product Type is \''+String.join(mapExcludedProductTypes.values(), '\' or \'')+'\'';
            debug.log('in else Called ===>>'+validResult); 
            return JSON.serialize(validResult); 
        } 
        
        if((objOpportunity.StageName == 'Closing' || objOpportunity.StageName == 'Closed Won') && (objOpportunity.Contract_Stage__c == 'Contract Sent' || objOpportunity.Contract_Stage__c == 'Contract Signed')){
            Debug.log('Inside Validation');
            validResult.isValid = false;
            validResult.isValidOwner = false;
            validResult.objOpportunity = null;
            validResult.errorMsg ='Contract has already been sent.';
            debug.log('in else Called ===>>'+validResult);
            return JSON.serialize(validResult);
        }
        if((recTypeNameWithIdMap.get(objOpportunity.recordTypeID) == 'Mid Market' || recTypeNameWithIdMap.get(objOpportunity.recordTypeID) =='Enterprise Solutions')){
            if(objOpportunity.StageName != 'Closing' && !(mapExcludedProfiles.containsKey(loggedInUser.Profile.Name.toLowerCase()))){
                validResult.isValid = false;
                validResult.isValidOwner = false;
                validResult.objOpportunity = null;
                validResult.errorMsg ='Opportunity stage should be closing for sending paperwork.';
                debug.log('in else Called ===>>'+validResult);
                return JSON.serialize(validResult); 
            }
            if(!(mapExcludedProfiles.containsKey(loggedInUser.Profile.Name.toLowerCase()))){
                if((recTypeNameWithIdMap.get(objOpportunity.recordTypeID) != 'Enterprise Solutions') || (recTypeNameWithIdMap.get(objOpportunity.recordTypeID) =='Enterprise Solutions' && !setAllowedEnterpriseProfiles.contains(loggedInUser.Profile.Name.toLowerCase()))){
                    if(UserInfo.getUserId() == objOpportunity.OwnerId){
                        validResult.isValid = true;
                        validResult.isValidOwner = true;
                        validResult.objOpportunity = objOpportunity;
                        debug.log('in success Called ===>>'+validResult);
                        return JSON.serialize(validResult); 
                    } else{
                        validResult.isValid = false;
                        validResult.isValidOwner = false;
                        validResult.objOpportunity = null;
                        validResult.errorMsg = 'You should be the owner of the opportunity to perform send paperwork.';
                        debug.log('in else Called ===>>'+validResult);
                        return JSON.serialize(validResult); 
                    } 
                } else{
                    validResult.isValid = true;
                    validResult.isValidOwner = true;
                    validResult.objOpportunity = objOpportunity;
                    debug.log('in success Called1 ===>>'+validResult);
                    return JSON.serialize(validResult); 
                }  
            }else{
                validResult.isValid = true;
                validResult.isValidOwner = true;
                validResult.objOpportunity = objOpportunity;
                debug.log('in success Called1 ===>>'+validResult);
                return JSON.serialize(validResult); 
            }   
        }else if(recTypeNameWithIdMap.get(objOpportunity.recordTypeID) == 'Consumer' && (objOpportunity.Building__c == null || objOpportunity.Primary_Member__c == null)){
            validResult.isValid = false;
            validResult.isValidOwner = false;
            validResult.objOpportunity = null;
            if(objOpportunity.Building__c == null){
                validResult.errorMsg ='Building is a required field while sending the paperwork.';
            }else if(objOpportunity.Primary_Member__c == null){
                validResult.errorMsg ='Primary Member is a required field while sending the paperwork.';  
            } 
            Debug.log('in if Called ===>>'+validResult);
            return JSON.serialize(validResult); 
        }else{
            validResult.isValid = true;
            validResult.isValidOwner = true;
            validResult.objOpportunity = objOpportunity;
            debug.log('in success Called1 ===>>'+validResult);
            return JSON.serialize(validResult); 
        }
    }
    
    global class SendPaperWorkSetting {
        global List<OpportunityCreationSetting> OpportunityCreationSetting;
        global List<String> ExcludedProfiles;
        global List<String> ExcludedProductTypes;
        global List<String> AllowedEnterpriseProfiles;
        global String URL;
    }
    
    global class OpportunityCreationSetting {
        global String RecordType;
        global String CompanySize;
    } 
    
    global class ValidResultWithOpp{
        global Boolean isValid {get;set;}
        global Boolean isBillingAccountError {get;set;}
        global Boolean isValidOwner {get;set;}
        global string errorMsg {get;set;}
        global Opportunity objOpportunity {get;set;}
        global List<String> opportunityBuildings {get;set;}
        global string settingData {get;set;}
    }
    
    @RemoteAction
    global static String checkSendPaperWork(String oppId){
        return isValidOppforSendPaperwork(oppId);
    }
    
    @RemoteAction
    global static Opportunity createOpportunityForManageTours(Id contactId){
        try{
            Opportunity opp = new Opportunity();
            Contact con = [Select Id,Name,AccountId from Contact Where Id=:contactId];
            opp.Name = 'Manage Tour Opportunity';
            opp.StageName = 'Qualifying';
            opp.AccountId = con.AccountId;
            opp.Primary_Member__c = con.Id;
            opp.CloseDate = System.today();
            insert opp;
            return [Select Id,Name from Opportunity Where Id=:opp.Id];
        }
        catch(Exception ex){
            Debug.log(ex.getMessage());
            return null;
        }
    }    
    
  /************************************************************************************************************************************
	Author              : Amol Darekar
	Description         : This function get called from REST API where account is get search using UUID.
	Created Date        : 24-June-2017
	Issue No.           : ST-1156
  ***********************************************************************************************************************************
    Author              : Krishana Tupe
	Description         : Added comment structure
	Modified Date       : 28-July-2018	
   ************************************************************************************************************************************/
   global static String getMasterAccountUUID(string accountUUID) {       
        //Search for UUID in Merge Account object record and return Master Account UUID
        List<Merged_Account__c> lstMergeAccount = [SELECT Id,Master_UUID__c,Merged_Account_UUID__c FROM Merged_Account__c WHERE Merged_Account_UUID__c =: accountUUID LIMIT 1];
        Debug.log('IN getMasterAccountUUID ==> '+lstMergeAccount);
        if((!lstMergeAccount.isEmpty()) && lstMergeAccount.size() > 0){
            return lstMergeAccount.get(0).Master_UUID__c; 
        }
        return null;    
    }
    
    @RemoteAction
    global static Integer getLowerCompanySize(String size){
        return WithoutSharingUtilityController.getLowerSize(size);
    }    
  
  /************************************************************************************************************************************
	Author              : Shobhit Gahlot
	Description         : This function is used to generate uuid used in sendpaperwork button on opportunity
	Created Date        : 24-June-2017
	Issue No.           : ST-1298
  ***********************************************************************************************************************************
    Author              : Krishana Tupe
	Description         : Added comment structure
	Modified Date       : 28-July-2018	
   ************************************************************************************************************************************/
    webservice static String getOpportunityEncodedID(Id opportunityId) {
        Debug.log('IN getOpportunityEncodedID ==>'+opportunityId);
        return EncodingUtil.base64Encode(Blob.valueOf(opportunityId));
    }
    
    global static String convertEnterpriseLead(Map<String, Object> entity){
        try{
            Debug.Log('entity---'+entity);
            Lead leadRec;
            Account accRec;
            sObject conRec;
            Map<String, Id> createOppResult = new Map<String, Id>();
            if(entity.containsKey('leadId') && entity.containsKey('orgAccountId') && entity.get('orgAccountId') != null){
                conRec = [SELECT Id,RecordTypeId,AccountId FROM Contact WHERE Email =:(String)entity.get('Email')][0];
                if(conRec == null){
                    conRec = FieldMappingsHelper.getMappings((Id)entity.get('leadId'), 'FieldMappings:LeadToContact');
                    if(entity.containsKey('orgAccountId')){
                        //Commented by Pranay Jadhav don't need to override account's recordtype
                        //Account accountRec = new Account(Id = String.valueOf(entity.get('orgAccountId')), RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId()); 
                        //Account accountRec = new Account(Id = String.valueOf(entity.get('orgAccountId'))); 
                        //upsert accountRec;
                        conRec.put('AccountId',String.valueOf(entity.get('orgAccountId')));
                        conRec.put('Convert_Lead__c',false);
                    }
                    insert conRec;
                }else{
                    if(conRec.get('AccountId') != Id.valueOf((String)entity.get('orgAccountId'))){
                        conRec.put('AccountId',String.valueOf(entity.get('orgAccountId')));
                        update conRec;
                    }
                }
                Debug.log('conRec::'+conRec);
                Lead objLead;
                if(entity.get('accountId') == null && entity.get('orgAccountId') != null){
                    objLead = new Lead(Id=(Id)entity.get('leadId'),Account__c=(Id)entity.get('orgAccountId'));
                    update objLead;
                }else if(entity.get('accountId') != null && entity.get('orgAccountId') != null){
                    if(entity.get('accountId')!=entity.get('orgAccountId')){
                        objLead = new Lead(Id=(Id)entity.get('leadId'),Account__c=(Id)entity.get('orgAccountId'));
                        update objLead;
                    }else{
                        objLead = new Lead(Id=(Id)entity.get('leadId'),Account__c=(Id)entity.get('orgAccountId'));
                    }
                }
                objLead.Email = (String)entity.get('Email');
                Map<String,Id> mapIds = LeadConverterHelper.manageLead(objLead);
                accRec = Database.Query('Select Id, OwnerId, RecordTypeId, RecordType.Name, Primary_Member__c From Account Where Id =\''+mapIds.get('accountId')+'\'');
                conRec = new Contact(Id = mapIds.get('contactId'), OwnerId = accRec.OwnerId);
                conRec.put('RecordTypeId',Schema.SObjectType.Contact.getRecordTypeInfosByName().get(accRec.RecordType.Name).getRecordTypeId());
                update conRec;
                if(accRec.Primary_Member__c == null){
                    update new Account(Id=mapIds.get('accountId'), Primary_Member__c = conRec.Id, Allow_Merge__c = false);
                }
                createOppResult.put('accountId',mapIds.get('accountId'));
                createOppResult.put('contactId',mapIds.get('contactId'));
            } else if(entity.containsKey('contactId') && entity.containsKey('orgAccountId')) { 
                Debug.Log('Contact call');
                createOppResult.put('accountId', String.valueOf(entity.get('orgAccountId')));
                createOppResult.put('contactId', String.valueOf(entity.get('contactId')));
            }
            return JSON.serialize(createOppResult);
        }catch(Exception pEx) {            
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('WeworkEngine','convertEnterpriseLead',JSON.serialize(entity), pEx)
            );
            DatabaseResult result = new DatabaseResult(pEx);
            return JSON.serialize(result);
        }
    }
  /************************************************************************************************************************************
	Author              : Prashant Mane
	Description         : This method is used to validate the opportunity for Transfer Paperwork functionality for Community View Page. 
	Created Date        : 2-June-2018
	Issue No.           : CSI-838
	-------------------------------------------------------------------------------------------------------------------------------------
	Last Modified by	: Milanjeet Singh
	Description			: Updated the logic to validate the opportunity according to the new Billing Account Object Structure
	Issue No.			: ST-2547
 *************************************************************************************************************************************/
    webservice static string isValidOppforTransferPaperwork(Id oppId) { 
        String[] oppStages,oppContactStages;
        Set<String> setOfOppStages = new Set<string>();       
        set<String> setOfContractStages = new set<String>();
        ValidResultWithOpp validResult = new ValidResultWithOpp();
        try{
            Setting__c transferPaperWorkSetting = new Setting__c();
            transferPaperWorkSetting = Settings.get('TransferPaperwork'); 
            debug.log('TransferPaperworkSetting'+transferPaperWorkSetting);
            
            TransferPaperwork settingData = new TransferPaperwork();
            settingData = (TransferPaperwork)JSON.deserialize(transferPaperWorkSetting.Data__c.toLowerCase(), TransferPaperwork.class);
            debug.Log('settingData'+settingData);
            
            oppStages = settingData.allowedStages;
            oppContactStages = settingData.allowedContractStages;
            setOfOppStages.addAll(oppStages);
            setOfContractStages.addAll(oppContactStages);
            validResult.settingData = (settingData.url!=null && settingData.url.size()>0)?JSON.serialize(settingData.url):'[]';
            
            List<Opportunity> lstOpportunities = [SELECT Id,AccountId,Type__c,Billing_Account__r.UUID__c,Billing_Account__c,Account.OwnerId,Account.Account_Type__c,recordTypeID,StageName,Contract_Stage__c,Encoded_ID__c,Building_uuid__c,Actual_Start_Date__c,OwnerId,Locations_Interested__c,Building__c,Primary_Member__c from Opportunity WHERE Id =: oppId Limit 1];
            debug.log('lstOpportunities:::'+lstOpportunities);
            if((!setOfOppStages.contains(lstOpportunities[0].StageName != null ? lstOpportunities[0].StageName.toLowerCase() : null ))){
                debug.log('Inside Validation');
                validResult.isValid = false;
                validResult.objOpportunity = null;
                validResult.errorMsg ='You are not allowed to transfer this paperwork. Please check the Opportunity Stage.';
            }else if((!setOfContractStages.contains(lstOpportunities[0].Contract_Stage__c != null ? lstOpportunities[0].Contract_Stage__c.toLowerCase() : null ))){
                debug.log('setOfContractStages..++'+setOfContractStages);
                debug.log('Inside Validation');
                validResult.isValid = false;
                validResult.objOpportunity = null;
                validResult.errorMsg ='You are not allowed to transfer this paperwork. Please check the Contract Stage.';
                debug.log('in else Called ===>>'+validResult);
            }else if(lstOpportunities[0].Billing_Account__c !=null && String.isBlank(lstOpportunities[0].Billing_Account__r.UUID__c)){
                validResult.isValid = false;
                validResult.objOpportunity = null;
                validResult.errorMsg ='You are not allowed to transfer this paperwork as uuid is not present on Opportunity\'s Billing Account.';
            }else {
                validResult.isValid = true;
                validResult.objOpportunity = lstOpportunities.get(0);
            }
            Debug.log('Valid Result ===>>'+validResult);
            return JSON.serialize(validResult);
        } catch(Exception ex){
            Debug.log('Transfer Paperwork Exception'+ex.getMessage());
            return null;
        }
    } 
    global class TransferPaperwork{
        global String[] allowedStages;
        global String[] allowedContractStages;
        global String[] url;
    }   
}