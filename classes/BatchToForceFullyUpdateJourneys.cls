/************************************************************************************************************************************
    Author      :  Sunil Bhosale  
    Description :  Forcefully update longstanding Journeys.
    Issue No    :  ST-1547

    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION    DATE        AUTHOR            DETAIL
        1                 Sunil Bhosale      Initial Developement
        2   14/11/2018    Jitesh Adwani      ST-3033 Change Name of the fields.
**************************************************************************************************************************************/
global class BatchToForceFullyUpdateJourneys implements Database.Batchable<sObject>, Database.Stateful {
    public String strQuery;
    public JourneyForceFullyClose objJourneyForceFullyClose ;
    Set<String> setJourneyStages;
    Datetime startTime, endTime;
    List<String> lstErrors = new List<String>();
    Integer totalSucceededRecords = 0, numberOfDays;
    
    global BatchToForceFullyUpdateJourneys() {
        objJourneyForceFullyClose = (JourneyForceFullyClose )System.JSON.deserialize(Settings.get('JourneyForceFullyClose').Data__c, JourneyForceFullyClose.class);
        if(objJourneyForceFullyClose != null){
            setJourneyStages = new Set<String>(objJourneyForceFullyClose.Stages);
            Integer numberOfDays = numberOfDays = objJourneyForceFullyClose.NumberOfDays;
            Date startDate = Date.valueOf(objJourneyForceFullyClose.StartDate);            
            startTime = Datetime.newInstanceGmt(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);
            Debug.Log('startTime---'+startTime);
            Date endDate = Date.valueOf(objJourneyForceFullyClose.EndDate);
            endTime = Datetime.newInstanceGmt(endDate.year(), endDate.month(), endDate.day(), 23, 59, 59);
            Debug.Log('endTime---'+endTime);
            strQuery = 'SELECT Id, IsAuto_Complete_Expiration__c, Auto_Complete_Expiration__c, NMD_Next_Contact_Date__c, Status__c, CreatedDate, LastModifiedDate, (SELECT Id, CreatedDate, ActivityDate FROM OpenActivities ORDER BY CreatedDate DESC) FROM Journey__c WHERE IsAuto_Complete_Expiration__c = false AND CreatedDate >= :startTime AND CreatedDate <= :endTime AND Status__c NOT IN :setJourneyStages';
        }
    } 
    
    global Database.QueryLocator start(Database.BatchableContext batchContext){        
        return Database.getQueryLocator(strQuery); 
    }
    
    global void execute(Database.BatchableContext BC, List<Journey__c> lstJourneys) {
        Debug.log('BatchToForceFullyUpdateJourneys lstJourneys---'+lstJourneys.size());
        try{
            Boolean openActivityPresent, isJourneyToClose;
            Date dateToFilter = Date.today().addDays(-objJourneyForceFullyClose.NumberOfDays), autoCompleteExpirationDate = Date.today();
            Debug.log('BatchToForceFullyUpdateJourneys dateToFilter---'+dateToFilter);
            List<Journey__c> lstJourneysToUpdate = new List<Journey__c>();
            for(Journey__c objJourney : lstJourneys){ 
                isJourneyToClose = false;
                for(OpenActivity objActivity : objJourney.OpenActivities){
                    if(objActivity.ActivityDate != null && objActivity.ActivityDate < dateToFilter){
                        isJourneyToClose = true;
                        autoCompleteExpirationDate = objActivity.ActivityDate.addDays(numberOfDays);
                    } else if(objActivity.CreatedDate < dateToFilter){
                        isJourneyToClose = true;
                        autoCompleteExpirationDate = Date.valueOf(objActivity.CreatedDate).addDays(numberOfDays);
                    }
                    break;
                }                               
                if(!isJourneyToClose && objJourney.NMD_Next_Contact_Date__c < dateToFilter){
                    isJourneyToClose = true;
                    autoCompleteExpirationDate = Date.valueOf(objJourney.NMD_Next_Contact_Date__c).addDays(numberOfDays);                    
                }
                if(!isJourneyToClose && objJourney.LastModifiedDate < dateToFilter){
                    isJourneyToClose = true;
                    autoCompleteExpirationDate = Date.valueOf(objJourney.LastModifiedDate).addDays(numberOfDays);                    
                }                
                if(isJourneyToClose){
                    objJourney.Auto_Complete_Expiration__c = autoCompleteExpirationDate;
                    objJourney.IsAuto_Complete_Expiration__c = true;
                    objJourney.Status__c = 'Auto-Complete/Expiration';
                    lstJourneysToUpdate.add(objJourney);
                }
            }
            Debug.log('BatchToForceFullyUpdateJourneys lstJourneysToUpdate---'+lstJourneysToUpdate.size());
            if(lstJourneysToUpdate.size() > 0){
                for(Database.SaveResult objResult : Database.update(lstJourneysToUpdate, false)){
                    if(objResult.isSuccess()){
                        totalSucceededRecords += 1;
                    }else{
                        lstErrors.add(objResult.getId() +'-'+ objResult.getErrors());
                    }
                }
            }
        } catch (Exception ex) {            
            ApexDebugLog.logException(ex, JSON.serialize(lstJourneys), 'BatchToForceFullyUpdateJourneys', 'execute');
        }          
    }
    
    global void finish(Database.BatchableContext BC) {
        EmailTemplate objTemplate = [SELECT Id, Body FROM EmailTemplate WHERE DeveloperName= 'Forcefully_Update_Journeys_Status'];
        objTemplate.Body = objTemplate.Body.replace('{{TotalRecords}}', String.valueOf(totalSucceededRecords + lstErrors.size()) + '\n');
        objTemplate.Body = objTemplate.Body.replace('{{SuccessRecords}}', String.valueOf(totalSucceededRecords)+ '\n');
        objTemplate.Body = objTemplate.Body.replace('{{FailedRecords}}', String.valueOf(lstErrors.size())+ '\n');
        
        AsyncApexJob objAsyncJob = [SELECT Id, Status, NumberOfErrors, TotalJobItems FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        Messaging.SingleEmailMessage objSingleEmail = new Messaging.SingleEmailMessage();
        objSingleEmail.setSubject('Forcefully update Journeys  status : ' + objAsyncJob.Status);
        objSingleEmail.setToAddresses( new List<String>(objJourneyForceFullyClose.Emails) );
        objSingleEmail.setHtmlBody(objTemplate.Body);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {objSingleEmail});        
    }
     
    global class JourneyForceFullyClose {
        public Set <String> Stages  {get; set;}  
        public Integer NumberOfDays {get; set;}
        public Set<String> Emails  {get; set;}
        public Date StartDate {get; set;}
        public Date EndDate {get; set;}
    }
}