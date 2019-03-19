/************************************************************************************************************************************
Author      :   Shivprasad Patil   
Description :   This class contain all methods releated to broker lead conversion functionality.

History     :
----------------------------------------------------------------------------------------------------------------------------------
VERSION     DATE                AUTHOR                  DETAIL
1           21-08-2018          Shivprasad Patil        Initial Developement
**************************************************************************************************************************************/

global without sharing class ConvertBrokerLeadController { 
    @AuraEnabled
    public static DatabaseResult verifyBrokerLead(String leadId, Boolean convertLead, Lead objlead, String journeyId, Boolean isNewAccountCreated){
        return ConvertBrokerLeadController.verifyAndConvertBrokerLead(leadId, convertLead, objlead, journeyId, isNewAccountCreated);
    }
    
    webservice static LightningComponentController.WebServiceWrapper verifyBrokerLeadForWebService(String leadId, Boolean convertLead, Lead objlead, String journeyId, Boolean isNewAccountCreated){
        DatabaseResult result = ConvertBrokerLeadController.verifyAndConvertBrokerLead(leadId, convertLead, objlead, journeyId, isNewAccountCreated);
        Debug.log('result===='+result);
        return new LightningComponentController.WebServiceWrapper(result.success, String.valueOf(result.data), result.message); 
    }
    public static Savepoint sp;
    
    /****************************************************************************************************************************
Author              : Shivprasad Patil
Description         : This method used to verify and convert broker lead.
Created Date        : 22,Aug 2018
Last Modified By    : Shivprasad Patil
Last Modified Date  : 22,Aug 2018
*****************************************************************************************************************************/
    public static DatabaseResult verifyAndConvertBrokerLead(String leadId, Boolean convertLead, Lead objlead, String journeyId, Boolean isNewAccountCreated){
        try{
            sp = Database.setSavepoint();
            Setting__c RestrictOpportunityCreation = Settings.get('RestrictOpportunityCreation');
            Map<String,Map<String,set<String>>> mapOfCriteria  = (Map<String,Map<String,set<String>>>)JSON.deserialize(RestrictOpportunityCreation.Data__c.toLowerCase(), Map<String,Map<String,set<String>>>.class);
            if(convertLead){
                //List<Journey__c> lstOfJourney = [SELECT Id FROM Journey__c WHERE Primary_Lead__c = :objlead.Id AND Status__c='Started' ORDER BY LastModifiedDate desc];
                List<Task> lstOfTasks = [SELECT Id, Status FROM Task WHERE WhoId = :objlead.Id];
                Debug.log('objLead.Unomy_Company_Size__c=='+objLead.Unomy_Company_Size__c);
                if(String.isNotBlank(objLead.Unomy_Company_Size__c)){
                    objLead.Number_of_Full_Time_Employees__c = LeadTriggerHandler.getUnomyCompanySize(objLead.Unomy_Company_Size__c);
                }
                Debug.log('objLead=='+objLead);    
                DatabaseResult result =  LightningComponentController.convertLeadsToExisting(objlead);
                if(result.success){
                    Map<String,Id> mapOfConvertedData = (Map<String,Id>)JSON.deserialize(String.valueOf(result.data), Map<String,Id>.class);
                    Map<String,set<String>> mapOfLeadSource = mapOfCriteria.get('leadsourcecriteriaforconvertedlead');
                    if(mapOfLeadSource.containsKey('leadsource') && String.isNotBlank(objlead.LeadSource) && (mapOfLeadSource.get('leadsource')).contains(objlead.LeadSource.toLowerCase())){
                        if(isNewAccountCreated)
                            update new Account(Id = objlead.Account__c, Account_SubType__c = 'Broker');
                        if(String.isNotBlank(mapOfConvertedData.get('contactId')))
                            update new Contact(Id = mapOfConvertedData.get('contactId'), Type__c = 'Broker');
                    }
                    if(mapOfConvertedData.get('contactId') != null){
                    validateSendEmailToAccountOwner(mapOfConvertedData.get('contactId'));
                    }
                    if(String.isNotBlank(journeyId)){
                        update new Journey__c(Id=journeyId, Status__c='Completed');
                    }
                    if(lstOfTasks.size() >  0 ){
                        for(Task objTask : lstOfTasks){
                            objTask.Status = 'Completed';
                        }
                        update lstOfTasks;
                    }
                }else{
                    Database.rollback(sp);  
                }
                return result;
            }else{
                DatabaseResult result = LightningComponentController.validateLead(leadId);
                if(!result.success)
                    return result;
                
                Map<String,set<String>> mapOfFields  = mapOfCriteria.get('restrictcriteria');
                Debug.log('mapOfFields=='+mapOfFields);
                Set<String> setOfFields = new Set<String>();
                for(String strField : mapOfFields.keySet()){
                    setOfFields.add(strField.toLowerCase());
                }
                Debug.log('setOfFields=='+setOfFields);
                setOfFields.addAll(new Set<String>{'id','leadsource','email','interested_in_number_of_desks__c','number_of_full_time_employees__c','unomy_company_size__c'});
                Debug.log('setOfFields=='+setOfFields);
                sObject leadObj = Database.query('SELECT '+ String.join(new List<String>(setOfFields),',')+' FROM Lead WHERE Id = :leadId')[0];
                
                if(mapOfFields.size() > 0 ){
                    for(String strField : mapOfFields.keySet()){
                        if(! (leadObj.get(strField) !=null && mapOfFields.get(strField).contains( String.valueOf(leadObj.get(strField)).toLowerCase()))){
                            string label = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap().get(strField).getDescribe().getLabel();
                            return new DatabaseResult(false,null,'Cannot Convert Lead.Failed to match '+label+' Criteria.');
                        }
                    }
                }
                return new DatabaseResult((Lead)leadObj);
            }
        }catch(Exception pEx){
            if(sp != null){                
                Database.rollback(sp);  
            }
            Debug.log('Exception===='+pEx.getStackTraceString());
            ApexDebugLog.logException(pEx,'', 'ConvertBrokerLeadController', 'verifyBrokerLead');            
            return new DatabaseResult(pEx);  
        }
    }
    
    /****************************************************************************************************************************
Author              : Shivprasad Patil
Description         : This method used get latest modified journey on lead which not have complete status
Created Date        : 24,Nov 2018
Last Modified By    : Shivprasad Patil
Last Modified Date  : 24,Nov 2018
*****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getJourneyToUpdate(String leadId){
        try{
            Setting__c objJourneyCompletedStatus = Settings.get('JourneyCloseStages');
            Set<String> setOfStatus = (Set<String>)JSON.deserialize(objJourneyCompletedStatus.data__c, Set<String>.class);
            List<Journey__c> lstJourney = [SELECT Id FROM Journey__c WHERE Primary_Lead__c =:leadId AND Status__c NOT IN :setOfStatus];
            return new DatabaseResult(lstJourney);
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'ConvertBrokerLeadController', 'getJourneyToUpdate');            
            return new DatabaseResult(pEx);  
        }
    }
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : We have moved all the client side queries to server side using this method
        Created Date    : 1 February 2019
        Issue No        : ST-3285
    **************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getQueryResultForLabel(String label, Map<String, Object> filters){
        String query = '';
        Switch on label{
            WHEN 'journeyDetails'{
                query ='SELECT Id, Status__c, Primary_Lead__c, Primary_Contact__c, Primary_Contact__r.Account.Lighthouse_Account__c, Primary_Contact__r.Account.OwnerId, Primary_Contact__r.Account.Owner.Email FROM Journey__c ';
                query += 'WHERE Id=\''+filters.get('journeyId')+'\'';
            }
        }
        return String.isNotEmpty(query) ? (new DatabaseResult(LightningComponentController.getQueryData(query))) : new DatabaseResult(false, null, 'Something went wrong, please contact your system administrator');
    }
    
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This Method is used to decide whether to send email to account owner or not after clicking journey handoff button 
        Created Date    : 1 February 2019
        Issue No        : ST-3285
    **************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult saveJourney(Journey__c record) {
        try{
            sp = Database.setSavepoint();
            DatabaseResult result = new DatabaseResult(JSON.serialize(Database.update(record)));
            validateSendEmailToAccountOwner(record.Primary_Contact__r.Id);
            return result;
        }catch(Exception pEx){                    
            if(sp != null){                
                Database.rollback(sp);  
            }           
            ApexDebugLog.logException(pEx,JSON.serialize(record), 'ConvertBrokerLeadController', 'saveJourney');            
            return (new DatabaseResult(pEx));          
        }
    }
    
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This Method is used to decide whether to send email to account owner or not after clicking Lead handoff button  
        Created Date    : 1 February 2019
        Issue No        : ST-3285
    **************************************************************************************************************************************/
    public static void validateSendEmailToAccountOwner(Id contactId){
        Setting__c apiUserSetting = Settings.get('APIUserContactInfo');
        if(apiUserSetting != NULL && String.isNotBlank(apiUserSetting.Data__c)){
            Map<String, String> apiUserContactInfo = (Map<String, String>)JSON.deserialize(Settings.get('APIUserContactInfo').Data__c, Map<string, string>.class);
            List<Contact> lstContacts = new List<Contact>([SELECT Id, Account.OwnerId, Account.Owner.Email, Account.Owner.isActive, Account.Lighthouse_Account__c FROM Contact WHERE Id =:contactId]);
            if(!lstContacts.isEmpty()){
                Contact contactRec  = lstContacts[0];
                if(contactRec.Account.Lighthouse_Account__c && contactRec.Account.Owner.isActive && string.isNotBlank(contactRec.Account.Owner.Email) && apiUserContactInfo.containsKey('UserId') && contactRec.Account.OwnerId != apiUserContactInfo.get('UserId')){
                    sendEmailToLightHouseAccountOwnerOnLeadOrJourneyHandoff(contactRec);
                }
            }
        }
    }
    /************************************************************************************************************************************
        Author              :   Chandra Teja
        Description         :   This method is used to get journey closed stages.
      	Created Date  		:   1 February 2019
        Issue No            :   ST-3285
 	*************************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult getJourneyClosedStages(){
        MetadataSetting__mdt  closedJourneyStages= Settings.getMetadataSettingByDevName('ClosedJourneyStages');  
        return new DatabaseResult(closedJourneyStages.Data__c);
    }
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This Method is used to  send email to account owner or on clicking journey handoff or lead handoff button 
        Created Date    : 1 February 2019
        Issue No        : ST-3285
    **************************************************************************************************************************************/
    public static DatabaseResult sendEmailToLightHouseAccountOwnerOnLeadOrJourneyHandoff(Contact contactRec){
        try{
            EmailTemplate  emailTemplateId = [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Lead_Handoff'];    
            if(emailTemplateId  != null){
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setTemplateID(emailTemplateId.Id); 
                emailToSend.setTargetObjectId(contactRec.Account.OwnerId);
                emailToSend.setWhatId(contactRec.Id);
                emailToSend.setSaveAsActivity(false);
                emailToSend.toaddresses = new List<String>{contactRec.Account.Owner.Email};      
                    Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToSend}); 
            }
             return new DatabaseResult(true);
        }catch(Exception pEx){
            ApexDebugLog.logException(pEx,'', 'ConvertBrokerLeadController', 'sendEmailToLightHouseAccountOwnerOnLeadOrJourneyHandoff');            
            return new DatabaseResult(pEx);  
        }
    }
}