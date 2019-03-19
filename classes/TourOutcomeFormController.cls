global without sharing class TourOutcomeFormController {

    public static Boolean isInvoker = false;
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'TourOutcomeFormController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        	
    }

    global class FormData {
        public Object tourRecord {get;set;}
        public Object setting {get;set;}
        public Contact tourCompletedBy {get;set;}
        public Date currentDate {get;set;}
        public List<Building__c> buildings {get;set;}
        public String sessionId {get;set;}
        public String loggedInUser {get;set;}
    }
    
    @AuraEnabled
    public static DatabaseResult getFormData(Map<String, Object> parameters) {
        try{
            FormData objFormData = new FormData();
            Setting__c settingRecord = Settings.get('TourOutcomeForm');
            Debug.log('settingRecord :: '+settingRecord);
            TourOutcomeFormSettings setting = new TourOutcomeFormSettings();
            String label = (String) parameters.get('label');
            setting = (TourOutcomeFormSettings)JSON.deserialize(settingRecord.Data__c, TourOutcomeFormSettings.class); 
            object queryResult = getQueryResultForLabel(label, parameters).data; 
            Debug.log('queryResult ==> '+queryResult);
            if(queryResult != null){
                objFormData.tourRecord = queryResult;
            }            
            objFormData.setting = setting;
            String userEmail = UserInfo.getUserEmail();
            List<Contact> contactRecord = new List<Contact>([SELECT Id, Name, Email, UUID__c FROM Contact WHERE Email =: userEmail]);
            if(contactRecord.size() > 0){
                objFormData.tourCompletedBy = contactRecord[0];
            }else{
                userEmail = 'joinus@wework.com';
                contactRecord = new List<Contact>([SELECT Id, Name, Email, UUID__c FROM Contact WHERE Email =: userEmail]);
                if(contactRecord.size() > 0){
                    objFormData.tourCompletedBy = contactRecord[0];
                } else {
                    objFormData.tourCompletedBy = new Contact();
                }
            }
            objFormData.currentDate = System.today();            
            Map<String, Building__c> mapBuildings = new Map<String, Building__c>();
            objFormData.buildings = [SELECT Id, Name, Location_No_City__c, UUID__c FROM Building__c WHERE UUID__c <> null OR UUID__c <> ''];            
            objFormData.sessionId = UserInfo.getSessionId();
            objFormData.loggedInUser = UserInfo.getUserId();
            return new DatabaseResult(JSON.serialize(objFormData));            
        }catch(Exception ex){
            ApexDebugLog.logException(ex, JSON.serialize(parameters), 'TourOutcomeFormController', 'getFormData');            
            return (new DatabaseResult(ex)); 
        }
    }
    
    /************************************************************************************************************************************
        Author          : Samadhan Kadam
        Description     : We have moved all the client side queries to server side using this method
        Created Date    : 30 November 2018 
        Issue No        : ST-3011
    **************************************************************************************************************************************/
     @AuraEnabled
    public static DatabaseResult getQueryResultForLabel(String label, Map<String, Object> filters){
        String query;
        Switch on label{
            WHEN 'TourDetails'{
                query = 'SELECT Id, Name, New_Tour_Notes__c,Opportunity__r.Referrer_Name__c, Opportunity__r.Referrer_Email__c, Primary_Member__r.Email, Primary_Member__r.AccountId, Primary_Member__r.Account.Number_of_Full_Time_Employees__c, Tour_Outcome_UUID__c, Primary_Member__r.Account.Name, Primary_Member__r.Account.Unomy_Location_Country__c	, Primary_Member__r.Account.Unomy_Location_State__c ,Primary_Member__r.Account.Unomy_Location_City__c, Primary_Member__r.Account.Unomy_Location_Address__c, Primary_Member__r.Account.BillingCountry, Primary_Member__r.Account.BillingState, Primary_Member__r.Account.BillingCity, Primary_Member__r.Account.BillingStreet, Primary_Member__r.Name, Location__r.Name, Location__r.uuid__c, Location__r.Tour_Spacing__c, Opportunity__c, OwnerId, Tour_Outcome__c, Tour_Completed_By_UUID__c, Status__c, UUID__c, Unit_Type__c, Interested_Buildings__c, Interested_in_Number_of_Desks__c, How_Did_You_Hear_About_Us__c, Move_In_Date__c, Urgency__c, Current_Budget__c, Desired_Budget__c, Is_Decision_Maker__c, Decision_Maker__r.Name, Decision_Maker__r.Email, Name_of_Decision_Maker__c, Tour_Outcome_Notes__c, Objections__c, No_Follow_Up__c, Outcome_Reservables__c, Lease_Expiration__c, Tour_Date__c, Product_Line__c, Start_Time__c, End_Time__c, booked_by_contact_id__c, booked_by_contact_id__r.Name FROM Tour_Outcome__c';
                query += ' WHERE ' + checkForUUIDorSFID(String.valueof(filters.get('IdOrUUID')));
            }
        }  
        Debug.log('getQueryResultForLabel'+query);
        return String.isNotBlank(query) ? LightningComponentController.getQueryData(query) : new DatabaseResult(false, null, 'Something went wrong, please contact your system administrator');
    }
    
    public static string checkForUUIDorSFID(String parameter){
        String queryParameter = '';
        try{
            Id.valueOf(parameter);
            queryParameter += 'Id = \''+parameter+'\'';
        }catch(Exception ex){
            queryParameter += 'UUID__c = \''+parameter+'\'';
        }
        return queryParameter;
    }
    
    //Method to get contact by current user email
    @AuraEnabled
    public static string getUserContactInfo(){
        return JSON.serialize([Select Id, Name, Email From Contact Where Email=:UserInfo.getUserEmail()]);
    }
    global class TourOutcomeFormSettings{
        public Set<String> RestrictedProfiles {get;set;}
        public ReservableAvailabilityAPI reservableAvailabilityAPI {get;set;}
        public CreateTourOutcomes createTourOutcomes {get;set;}
        public NoShow noShow {get;set;}
        public Reasons reasons {get;set;}
        public HowHeards howHeards {get;set;}
        public Urgencies urgencies {get;set;}
        public ReservableTourBuildingAvailabilitiesAPI reservableTourBuildingAvailabilitiesAPI {get;set;}
        public ReservableRescheduleAPI reservableRescheduleAPI {get;set;}
    }
    global class ReservableAvailabilityAPI {
        public String url {get;set;}
        public Headers headers {get;set;}
    }    
    global class Headers {
        public String Authorization {get;set;}
    }
    global class CreateTourOutcomes {
        public String url {get;set;}
        public Headers headers {get;set;}
    }
    global class NoShow {
        public String url {get;set;}
        public Headers headers {get;set;}
    }
    global class Reasons {
        public String url {get;set;}
        public Headers headers {get;set;}
    }
    global class HowHeards {
        public String url {get;set;}
        public Headers headers {get;set;}
    }
    global class Urgencies {
        public String url {get;set;}
        public Headers headers {get;set;}
    }
    global class ReservableTourBuildingAvailabilitiesAPI {
        public String url {get;set;}
        public Headers headers {get;set;}
    }
    global class ReservableRescheduleAPI {
        public String url {get;set;}
        public Headers headers {get;set;}
    }
    
}