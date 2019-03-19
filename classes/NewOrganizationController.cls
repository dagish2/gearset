/************************************************************************************************************************************
    Author      :  Nikhil Mehta    
    Description :  This class contain all aura methods related new Account flow.
    
    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR          DETAIL
     1          30 August 2018      Nikhil Mehta    Initial Developement
**************************************************************************************************************************************/

global without sharing class NewOrganizationController {
    public class  NewOrganizationControllerException extends Exception{}
    public static Boolean isInvoker = false;
    public static Savepoint sp {get;set;}
    
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'NewOrganizationController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    
    /****************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method is used to get new organtion creation permission and instructions.
        Created Date        : 03 september 2018
		Issue No			: ST-2731
   *****************************************************************************************************************************/ 
    @AuraEnabled
    public static DatabaseResult getNewOrganizationData(){
        try{
            NewOrganizationSettingWrapper newOrgCreationSettingRec = new NewOrganizationSettingWrapper();
            if(newOrgCreationSettingRec.excludeProfiles != null && newOrgCreationSettingRec.excludeProfiles.size() > 0){
                User userRec = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
                newOrgCreationSettingRec.excludeProfiles = string.join(newOrgCreationSettingRec.excludeProfiles,',').toLowerCase().split(',');
                if(!newOrgCreationSettingRec.excludeProfiles.contains(userRec.Profile.Name.toLowerCase())){
                    newOrgCreationSettingRec.isUserCreateOrg = true;
                }
                List<PermissionSetAssignment> lstPermissionSetAssignments = new List<PermissionSetAssignment>([SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Can_Create_Organization' AND AssigneeId =: UserInfo.getUserId()]);
                if(lstPermissionSetAssignments.size() > 0){
                    newOrgCreationSettingRec.isUserCreateOrg = true;
                    newOrgCreationSettingRec.isUserCreateEnterpriseOrg = true;
                }
                return new DatabaseResult(newOrgCreationSettingRec);
            }else if(newOrgCreationSettingRec.instructions != null && newOrgCreationSettingRec.instructions.size() > 0){
                return new DatabaseResult(newOrgCreationSettingRec);
            }else{
                throw new NewOrganizationControllerException('NewOrgCreationSetting is null');
            }
        }catch(Exception pEx) {  
            ApexDebugLog.logException(pEx, '', 'CreateNewOrganizationController', 'getPermissionForAccountFlow');            
            return (new DatabaseResult(pEx));
        }
    }
    
    public class NewOrganizationSettingWrapper{
        public List<string> excludeProfiles;
        @AuraEnabled
        public Map<String, List<String>> instructions;
        @AuraEnabled
        public Boolean isUserCreateOrg;
        @AuraEnabled
        public Boolean isUserCreateEnterpriseOrg;
        NewOrganizationSettingWrapper(){
            isUserCreateOrg = false;
            isUserCreateEnterpriseOrg = false;
            Setting__c newOrgSetting = Settings.get('NewOrgCreationSetting');
            if(newOrgSetting != null){
                NewOrganizationSettingWrapper newOrgCreationSettingRec = (NewOrganizationSettingWrapper)JSON.deserialize(newOrgSetting.Data__c, NewOrganizationSettingWrapper.class);
                excludeProfiles = newOrgCreationSettingRec.excludeProfiles != null && newOrgCreationSettingRec.excludeProfiles.size() > 0 ? newOrgCreationSettingRec.excludeProfiles : null;
                instructions = newOrgCreationSettingRec.instructions != null && newOrgCreationSettingRec.instructions.size() > 0 ? newOrgCreationSettingRec.instructions : null;
            }else{
                excludeProfiles = null;
                instructions = null; 
            }
        }
    }
    
    /****************************************************************************************************************************
        Author              : Pragalbha Mahajan
        Description         : This method is used to createNewOrganization.
        Created Date        : 03 september 2018
		Issue No			: ST-2729
   *****************************************************************************************************************************/ 
    @AuraEnabled
    public static DatabaseResult createNewOrganization(List<sObject> lstRecords){
        Account objAccount;
        Contact objContact;
        Lead objLead;
        Billing_Account__c objBillAccount;
        try{
            for(sObject record : lstRecords){
                switch on record {
                    when Account accRec {
                        objAccount = accRec;
                    }
                    when Contact conRec {
                        objContact = conRec;
                    }
                    when Billing_Account__c billAccRec {
                        objBillAccount = billAccRec;
                    }
                    when Lead leadRec{
                        objLead = leadRec;
                    }
                } 
            }
            if(objAccount != null){
                if(objLead!=null && String.isNotBlank(objLead.Id)){
                    Map<Id, Account> mapLeadToAccount = new Map<Id,Account>();
                    mapLeadToAccount.put(objLead.Id, objAccount);
                    List<Account> lstAccount = (List<Account>)FieldmappingsHelper.getMappings(mapLeadToAccount, 'FieldMappings:LeadToAccount').values();
                    if(lstAccount.size() > 0){
                        objAccount = lstAccount[0];
                    }
                }
                insert objAccount;
                if(objContact != null){
                    if(objContact.Id != null){
                        if(objBillAccount != null){
                            if(objContact.AccountId == null && objAccount.Id != null){
                                objContact.AccountId = objAccount.Id;
                            }
                            update objContact;
                            if(objBillAccount.Parent_Account__c == null && objAccount.Id != null){
                                objBillAccount.Parent_Account__c = objAccount.Id;
                            }
                            update objBillAccount;
                        }else{
                            if(objContact.AccountId == null && objAccount.Id != null){
                                objContact.AccountId = objAccount.Id;
                            }
                            update objContact;
                        }
                    }else{
                        objContact.AccountId = objAccount.Id != null ? objAccount.Id : null ;
                        if(objLead!=null && String.isNotBlank(objLead.Id)){
                            Map<Id, Contact> mapContactsToMap = new Map<Id, Contact>();
                            mapContactsToMap.put(objLead.Id, objContact);
                            List<Contact> lstContact = (List<Contact>)FieldmappingsHelper.getMappings(mapContactsToMap, 'FieldMappings:LeadToContact').values();
                            if(lstContact.size() > 0){
                                objContact = lstContact[0];
                                objContact.Convert_Lead__c = false;
                            }
                        }
                        insert objContact;
                    }
                    if(objContact.Id != null){
                        objAccount.Primary_Member__c  = objContact.Id;
                        update objAccount;
                        /* START Added By Krishana to move related journeys to contact before Lead conversion so duplicate journey creations for contatc will be avoided********/
                        if(String.isNotBlank(objContact.Id) && String.isNotBlank(objContact.Email)){
                            List<Journey__c> lstJourneysToMove = new List<Journey__c>();
                            for(Journey__c objJourney : [SELECT Id, Email__c, Primary_Lead__c, Primary_Contact__c FROM Journey__c WHERE Email__c =: objContact.Email AND Primary_Lead__c <> null]){
                                objJourney.Primary_Contact__c = objContact.Id;
                                objJourney.Primary_Lead__c = NULL;
                                lstJourneysToMove.add(objJourney);
                            }
                            if(lstJourneysToMove != null && lstJourneysToMove.size() > 0){
                                Database.update(lstJourneysToMove);  
                            }   
                        }
                       /* Added By Krishana END ********/ 
                    }
                }
                return new DatabaseResult(objAccount.Id);
            }else{
                throw new NewOrganizationControllerException('Account is null');
            }
        }catch(Exception pEx) {
            ApexDebugLog.logException(pEx, JSON.serialize(objAccount), 'CreateNewOrganizationController', 'createNewOrg');            
            return (new DatabaseResult(pEx)); 
        } 
    }
    
    /****************************************************************************************************************************
        Author              : Nikhil Mehta
        Description         : This method is used to send mail for new orgnanization request from create new organization.
        Created Date        : 03 september 2018
		Issue No			: ST-2729
	-----------------------------------------------------------------------------------------------------------------------------
        Modified Date       : 18 September 2018
		Description         : Now this method is used to send mail for new orgnanization request using sales console setting.
		Issue No			: ST-2694
   *****************************************************************************************************************************/    
    @AuraEnabled
    public static DatabaseResult sendNewOrganizationRequest(List<sObject> lstRecords){
		Account objAccount;
        Contact objContact;        
        try{
            for(sObject record : lstRecords){
                switch on record {
                    when Account accRec {
                        objAccount = accRec;
                    }
                    when Contact conRec {
                        objContact = conRec;
                    }
                } 
            }
            sp = Database.setSavepoint();
            if(objAccount != null && objAccount.Name != null && objAccount.Number_of_Full_Time_Employees__c != null){
                Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
                List<String> accountFields = new List<String>();
                for(Schema.SObjectField field : fieldMap.values()){
                    if(String.isNotBlank(String.valueOf(objAccount.get(field.getDescribe().getname())))){
                        accountFields.add(field.getDescribe().getname());
                    }
                }
                List<String> contactFields = new List<String>();
                if(objContact != null && objContact.Email != null && objContact.FirstName != null && objContact.LastName != null){
                    fieldMap = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
                    for(Schema.SObjectField field : fieldMap.values()){
                        if(String.isNotBlank(String.valueOf(objContact.get(field.getDescribe().getname())))){
                            contactFields.add(field.getDescribe().getname());
                        }
                    }
                }
                List<String> toAddresses = new List<String>();
                Setting__c newOrgRequestEmails = [SELECT Id, Data__c FROM Setting__c WHERE Name = 'NewOrganizationCreationRequestEmails' LIMIT 1];
                if(newOrgRequestEmails != null && newOrgRequestEmails.data__c != null){
                    List<String> lstEmails = (List<String>)JSON.deserialize(newOrgRequestEmails.data__c, List<String>.class);
                    if(lstEmails.size() > 0){
                        toAddresses.addAll(lstEmails);
                    }
                }
                if(toAddresses.size() > 0){
                    EmailTemplate emailTemplateRequestNewOrgCreation = [SELECT Id, Name, Markup FROM EmailTemplate Where DeveloperName = 'New_Org_Creation_Request_With_Contact' LIMIT 1];
                    List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage objSingleMail;
                        for(String address : toAddresses ){
                            objSingleMail = new Messaging.SingleEmailMessage();
                            objSingleMail.setSubject('New Enterprise Organization Creation Request-'+objAccount.Name);
                            String htmlBody = emailTemplateRequestNewOrgCreation.Markup;
                            htmlBody = htmlBody.replace('{{loggedUser}}', UserInfo.getFirstName()+' '+UserInfo.getLastName());
                            for(String fieldName : accountFields){
                                htmlBody = htmlBody.replace('{{Account.'+fieldName+'}}', String.isNotBlank(String.valueOf(objAccount.get(fieldName)))?String.valueOf(objAccount.get(fieldName)):'');
                            }
                            for(String fieldName : contactFields){
                                htmlBody = htmlBody.replace('{{Contact.'+fieldName+'}}', String.isNotBlank(String.valueOf(objContact.get(fieldName)))?String.valueOf(objContact.get(fieldName)):'');
                            }
                            while(htmlBody.countMatches('{{')>0 && htmlBody.countMatches('}}')>0){
                                htmlBody=htmlBody.replace(htmlBody.substring(htmlBody.indexOf('{{'),htmlBody.indexOf('}}')+2),'');
                            }
                            htmlBody = htmlBody.replace('<a href="/001/o">Click here</a>', '<a href="' + System.Label.URL + '/apex/NewOrganization">Click here</a>');
                            Debug.log('htmlBody---'+htmlBody);
                            objSingleMail.htmlbody = htmlBody;
                            objSingleMail.setTreatTargetObjectAsRecipient(false);
                            objSingleMail.toAddresses = new List<String>{address};
                            objSingleMail.setSaveAsActivity(false);
                            lstEmails.add(objSingleMail);
                        }
                    Messaging.SendEmailResult[] emailResults =  Messaging.sendEmail(lstEmails);                    
                    for(Messaging.SendEmailResult emailResult :emailResults ){
                        if(emailResult.isSuccess()){
                            return new DatabaseResult(true);
                        }
                    }
                }
            }else if(objAccount == null ){
                throw new NewOrganizationControllerException('Account is null');
            }
            return new DatabaseResult(false);
        }catch(Exception pEx) {  
            ApexDebugLog.logException(pEx, JSON.serialize(objAccount), 'CreateNewOrganizationController', 'sendNewOrganizationRequest');            
            return (new DatabaseResult(pEx));
        }
    }
}