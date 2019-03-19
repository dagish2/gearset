/************************************************************************************************************************************
    Author      :   Priyanka Ambre  
    Description :   This class contain all aura methods related to CreateOpportunity.
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR                  DETAIL
    1           16 July 2018        Priyanka Ambre          Initial Developement
**************************************************************************************************************************************/
global without sharing class CreateOpportunityController {
    public class  CreateOpportunityControllerException extends Exception{}
    public static Boolean isInvoker = false;
    public static Savepoint sp {get; set;}
    static {
        isInvoker = ApexDebugLog.registerRootInvoker(ApexDebugLog.InvokerType.AURA, 'CreateOpportunityController' + 'getsObjectPrefix', ApexDebugLog.InvokerType.AURA);        
    }
    
    /************************************************************************************************************************************
        Author         : Priyanka Ambre
        Description    : This method takes record Id and returns you record detail.
        Created Date   : 16 July 2018
        Issue No.      :  
    **************************************************************************************************************************************/
	@AuraEnabled
    public static DatabaseResult getCreateOpportunityData(String recordId){    
        RelatedRecordDetail objRelatedRecordDetail = new RelatedRecordDetail();
        List<CustomPermission> lstCustomPermissions = [SELECT Id, DeveloperName, (SELECT Id, Parent.Name, Parent.Profile.Name FROM SetupEntityAccessItems WHERE Parent.Profile.Id =: UserInfo.getProfileId()) FROM CustomPermission WHERE DeveloperName = 'Can_Create_Opportunity_Under_Sales_Account' LIMIT 1];
        Boolean isCreateOppFromSalesAcc = (lstCustomPermissions.size() > 0 && lstCustomPermissions[0].SetupEntityAccessItems.size() > 0) ? true : false;
        DatabaseResult recordTypeInfo = LightningComponentController.getRecordTypeInfos(new List<String>{'Account', 'Contact', 'Opportunity'});
        objRelatedRecordDetail.recordTypeInfo = (Map<String, Map<String, Id>>)recordTypeInfo.data;        
        objRelatedRecordDetail.isValidForCreateOpp = true;
        objRelatedRecordDetail.userInfo = [SELECT Id, Name, Email, SmallPhotoUrl, Profile.Name, TimeZoneSidKey FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        objRelatedRecordDetail.opportunityQualifySetting = Settings.get('EnterpriseOpportunityQualifySetting');
        Id ultimateParentRecordId;
        List<SObject> lstRelatedRecords = new List<SObject>();
        Id relatedRecordId;
        String sObjectName;
        
        if(String.isNotBlank(recordId)){            
            relatedRecordId = Id.valueOf(recordId);
            sObjectName = relatedRecordId.getSObjectType().getDescribe().getName();
         
            switch on sObjectName {
                when 'Account' {
                    lstRelatedRecords = [SELECT Id, Name, Number_of_Full_Time_Employees__c, ParentId, Primary_Member__c, Primary_Member__r.Name, Primary_Member__r.Email, Lead_Source__c, Description, Interested_in_Number_of_Desks__c, Parent_Org_Id__c, Account_Type__c, RecordType.Name, OwnerId, Owner.Name  FROM Account WHERE Id =: recordId LIMIT 1];
                    if(lstRelatedRecords.size()>0){
                        Account accRec = (Account)lstRelatedRecords.get(0);
                        if(accRec != null){
                            if(accRec.Account_Type__c == 'Org'){
                                ultimateParentRecordId = accRec.Id; 
                            } else if(accRec.Account_Type__c == 'Sales'){ 
                                objRelatedRecordDetail.isValidForCreateOpp = isCreateOppFromSalesAcc;                                
                            }
                            if(ultimateParentRecordId == null){
                                Set<Id> accIds = new Set<Id>();
                                if(accRec.Parent_Org_Id__c != null){
                                    accIds.add(Id.valueOf(accRec.Parent_Org_Id__c));
                                }else if(accRec.ParentId != null){
                                    accIds.add(Id.valueOf(accRec.ParentId));
                                }
                                Map<Id, Id> mapOrgId = OrganizationHelper.getUltimateParents(accIds);
                                ultimateParentRecordId = mapOrgId.get(Id.valueOf(accRec.Parent_Org_Id__c));
                            }
                        }
                    } 
                }
                when 'Lead' {
                    lstRelatedRecords = [SELECT Id, Name, Email, IsConverted, ConvertedContactId, Company, Account__c, Account__r.Name, Account__r.Number_of_Full_Time_Employees__c, Account__r.Parent_Org_Id__c, Account__r.Account_Type__c, Account__r.ParentId, Unomy_Company_ID__c, Unomy_Company_Name__c, Cleansed_Company_Name__c, Cleansed_Unomy_Company_Name__c, LeadSource, Building_Interested_In__c, Lead_Source_Detail__c, Description, Interested_in_Number_of_Desks__c, Markets_Interested__c, Locations_Interested__c, Email_Domain__c, Phone, OwnerId, Owner.Name FROM Lead WHERE Id =: recordId LIMIT 1];
                    if(lstRelatedRecords.size() > 0 ){
                        List<Lead> lstLead = (List<Lead>) lstRelatedRecords;
                        if(lstLead.get(0).Account__c != null){
                            if(lstLead.get(0).Account__r.Account_Type__c == 'Org'){
                                ultimateParentRecordId = lstLead.get(0).Account__c;
                            }else if(lstLead.get(0).Account__r.Parent_Org_Id__c != null || lstLead.get(0).Account__r.ParentId != null){
                                Id accountId;
                                Set<Id> accIds = new Set<Id>();
                                if(lstLead.get(0).Account__r.Parent_Org_Id__c != null){
                                    accountId = Id.valueOf(lstLead.get(0).Account__r.Parent_Org_Id__c);
                                    accIds.add(Id.valueOf(lstLead.get(0).Account__r.Parent_Org_Id__c));
                                }else if(lstLead.get(0).Account__r.ParentId != null){
                                    accountId = Id.valueOf(lstLead.get(0).Account__r.ParentId);
                                    accIds.add(Id.valueOf(lstLead.get(0).Account__r.ParentId));
                                }
                                Map<Id, Id> mapOrgId = OrganizationHelper.getUltimateParents(accIds);
                                ultimateParentRecordId = mapOrgId.get(Id.valueOf(accountId));
                            }
                        }else{
                            Map<Id, Id> mapOrgId = OrganizationHelper.findRelatedOrg(lstLead);
                            ultimateParentRecordId = mapOrgId.get(Id.valueOf(lstLead.get(0).Id));
                        }
                    }
                }
                when 'Contact' {
                    lstRelatedRecords = [SELECT Id, Name, Email, AccountId, Account.Name, Account_Name__c, Account.Number_of_Full_Time_Employees__c, Account.Parent_Org_Id__c, Account.Account_Type__c, Account.ParentId, LeadSource, Location__c, Lead_Source_Detail__c, Description, Interested_in_Number_of_Desks__c, Markets_Interested__c, Unomy_Company_ID__c, Cleansed_Unomy_Company_Name__c, Cleansed_Company_Name__c, Email_Domain__c, Unomy_Company_Name__c, Company__c, Phone, OwnerId, Owner.Name FROM Contact WHERE Id =: recordId LIMIT 1];
                    if(lstRelatedRecords.size() > 0 ){
                        List<Contact> lstContact = (List<Contact>) lstRelatedRecords;
                        if(lstContact.get(0).AccountId != null){
                            if(lstContact.get(0).Account.Account_Type__c == 'Org'){
                                ultimateParentRecordId = lstContact.get(0).AccountId;
                            }else if(lstContact.get(0).Account.Account_Type__c == 'Sales'){
                                objRelatedRecordDetail.isValidForCreateOpp = isCreateOppFromSalesAcc;                                
                            }
                            if(ultimateParentRecordId == null && lstContact.get(0).Account.Parent_Org_Id__c != null || lstContact.get(0).Account.ParentId != null){
                                Id accountId;
                                Set<Id> accIds = new Set<Id>();
                                if(lstContact.get(0).Account.Parent_Org_Id__c != null){
                                    accountId = Id.valueOf(lstContact.get(0).Account.Parent_Org_Id__c);
                                    accIds.add(Id.valueOf(lstContact.get(0).Account.Parent_Org_Id__c));
                                }else if(lstContact.get(0).Account.ParentId != null){
                                    accountId = Id.valueOf(lstContact.get(0).Account.ParentId);
                                    accIds.add(Id.valueOf(lstContact.get(0).Account.ParentId));
                                }
                                Map<Id, Id> mapOrgId = OrganizationHelper.getUltimateParents(accIds);
                                ultimateParentRecordId = mapOrgId.get(Id.valueOf(accountId));
                            }
                        }else{
                            Map<Id, Id> mapOrgId = OrganizationHelper.findRelatedOrg(lstContact);
                            ultimateParentRecordId = mapOrgId.get(Id.valueOf(lstContact.get(0).Id));
                        }
                    }
                }
                when 'Journey__c' {
                    lstRelatedRecords = [SELECT Id, Name,
                                         Interested_in_Number_of_Desks__c,
                                         Description__c,
                                         Markets_Interested__c,
                                         Building_Interested_In__c,
                                         Lead_Source__c,
                                         Lead_Source_Detail__c,
                                         Locations_Interested__c,
                                         Primary_Contact__c,
                                         Primary_Contact__r.Id,
                                         Primary_Contact__r.Name,
                                         Primary_Contact__r.Location__c,
                                         Primary_Contact__r.Email,
                                         Primary_Contact__r.Phone,
                                         Primary_Contact__r.LeadSource,
                                         Primary_Contact__r.AccountId,
                                         Primary_Contact__r.Company__c,
                                         Primary_Contact__r.Account.Name,
                                         Primary_Contact__r.Account_Name__c,
                                         Primary_Contact__r.Account.Parent_Org_Id__c,
                                         Primary_Contact__r.Account.Account_Type__c,
                                         Primary_Contact__r.Account.ParentId,
                                         Primary_Contact__r.Lead_Source_Detail__c,
                                         Primary_Contact__r.Unomy_Company_ID__c,
                                         Primary_Contact__r.Email_Domain__c,
                                         Primary_Contact__r.Cleansed_Unomy_Company_Name__c,
                                         Primary_Contact__r.Unomy_Company_Name__c,
                                         Primary_Contact__r.Cleansed_Company_Name__c,
                                         Primary_Contact__r.Description,
                                         Primary_Lead__c,
                                         Primary_Lead__r.Id,
                                         Primary_Lead__r.Name,
                                         Primary_Lead__r.Email,
                                         Primary_Lead__r.Phone,
                                         Primary_Lead__r.IsConverted,
                                         Primary_Lead__r.ConvertedContactId,
                                         Primary_Lead__r.Company,
                                         Primary_Lead__r.LeadSource,
                                         Primary_Lead__r.Account__c,
                                         Primary_Lead__r.Account__r.Name,
                                         Primary_Lead__r.Account__r.Parent_Org_Id__c,
                                         Primary_Lead__r.Account__r.Account_Type__c,
                                         Primary_Lead__r.Account__r.ParentId,
                                         Primary_Lead__r.Unomy_Company_ID__c,
                                         Primary_Lead__r.Unomy_Company_Name__c,
                                         Primary_Lead__r.Cleansed_Company_Name__c,
                                         Primary_Lead__r.Cleansed_Unomy_Company_Name__c,
                                         Primary_Lead__r.Lead_Source_Detail__c,
                                         Primary_Lead__r.Email_Domain__c,
                                         Primary_Lead__r.Description, 
                                         OwnerId, 
                                         Owner.Name FROM Journey__c WHERE Id =: recordId LIMIT 1];                
                    if(lstRelatedRecords.size() > 0 ){
                        List<Journey__c> lstJourney = (List<Journey__c>) lstRelatedRecords;
                        if(!String.isBlank(lstJourney.get(0).Primary_Lead__c)){
                            List<Lead> lstLead = new List<Lead>();
                            lstLead.add(lstJourney.get(0).Primary_Lead__r);   
                            if(lstLead.get(0).Account__c != null){
                                if(lstLead.get(0).Account__r.Account_Type__c == 'Org'){
                                    ultimateParentRecordId = lstLead.get(0).Account__c; 
                                }else if(lstLead.get(0).Account__r.Parent_Org_Id__c != null || lstLead.get(0).Account__r.ParentId != null){
                                    Id accountId;
                                    Set<Id> accIds = new Set<Id>();
                                    if(lstLead.get(0).Account__r.Parent_Org_Id__c != null){
                                        accountId = Id.valueOf(lstLead.get(0).Account__r.Parent_Org_Id__c);
                                        accIds.add(Id.valueOf(lstLead.get(0).Account__r.Parent_Org_Id__c));
                                    }else if(lstLead.get(0).Account__r.ParentId != null){
                                        accountId = Id.valueOf(lstLead.get(0).Account__r.ParentId);
                                        accIds.add(Id.valueOf(lstLead.get(0).Account__r.ParentId));
                                    }
                                    Map<Id, Id> mapOrgId = OrganizationHelper.getUltimateParents(accIds);
                                    ultimateParentRecordId = mapOrgId.get(Id.valueOf(accountId));
                                }
                            }else{
                                Map<Id, Id> mapOrgId = OrganizationHelper.findRelatedOrg(lstLead);
                                ultimateParentRecordId = mapOrgId.get(Id.valueOf(lstLead.get(0).Id));
                            }  
                        }else if(!String.isBlank(lstJourney.get(0).Primary_Contact__c)){
                            List<Contact> lstContact = new List<contact>();
                            lstContact.add(lstJourney.get(0).Primary_Contact__r);
                            if(lstContact.get(0).AccountId != null){
                                if(lstContact.get(0).Account.Account_Type__c == 'Org'){
                                    ultimateParentRecordId = lstContact.get(0).AccountId;
                                } else if(lstContact.get(0).Account.Account_Type__c == 'Sales' ){
                                    objRelatedRecordDetail.isValidForCreateOpp = isCreateOppFromSalesAcc;                                    
                                }
                                if(ultimateParentRecordId == null && lstContact.get(0).Account.Parent_Org_Id__c != null || lstContact.get(0).Account.ParentId != null){
                                    Id accountId;
                                    Set<Id> accIds = new Set<Id>();
                                    if(lstContact.get(0).Account.Parent_Org_Id__c != null){
                                        accountId = Id.valueOf(lstContact.get(0).Account.Parent_Org_Id__c);
                                        accIds.add(Id.valueOf(lstContact.get(0).Account.Parent_Org_Id__c));
                                    }else if(lstContact.get(0).Account.ParentId != null){
                                        accountId = Id.valueOf(lstContact.get(0).Account.ParentId);
                                        accIds.add(Id.valueOf(lstContact.get(0).Account.ParentId));
                                    }
                                    Map<Id, Id> mapOrgId = OrganizationHelper.getUltimateParents(accIds);
                                    ultimateParentRecordId = mapOrgId.get(Id.valueOf(accountId));
                                } 
                            } else{
                                Map<Id, Id> mapOrgId = OrganizationHelper.findRelatedOrg(lstContact);
                                ultimateParentRecordId = mapOrgId.get(Id.valueOf(lstContact.get(0).Id));
                            }
                        }
                    }
                } 
            when else {
                Debug.log('default');
                }
            }
        } 
        if(lstRelatedRecords.size() > 0){
            objRelatedRecordDetail.relatedRecord = lstRelatedRecords[0];
            String relatedObjectName = relatedRecordId.getSObjectType().getDescribe().getName().toLowerCase();
            if(relatedObjectName.contains('__c')){
                relatedObjectName =  relatedObjectName.substringBefore('__c');
            }
            objRelatedRecordDetail.relatedObjectName = relatedObjectName;
            if(ultimateParentRecordId != null){
                objRelatedRecordDetail.ultimateParentAccountRecord = [SELECT Id, Name, Primary_Member__c FROM Account WHERE Id =: ultimateParentRecordId LIMIT 1];    
            }
         } 
        DatabaseResult result = new DatabaseResult(JSON.serialize(objRelatedRecordDetail));
        return result;
    }
    
     /************************************************************************************************************************************
        Author         : Priyanka Ambre
        Description    : Wrapper class used for getCreateOpportunityData.
        Created Date   : 16 July 2018 
    **************************************************************************************************************************************/
    global class RelatedRecordDetail {
        @AuraEnabled
        public User userInfo {get; set;}   
        @AuraEnabled
        public SObject relatedRecord {get; set;}       
        @AuraEnabled
        public String relatedObjectName {get; set;}        
        @AuraEnabled
        public Account ultimateParentAccountRecord {get; set;} 
        @AuraEnabled
        public Boolean isValidForCreateOpp{get; set;}  
        @AuraEnabled
        public Object opportunityQualifySetting{get; set;} 
        @AuraEnabled
        public Map<String, Map<String, Id>> recordTypeInfo{get; set;} 
    }
    
    /***************************************************************************************************************************
        Author              : Priyanka Ambre
        Description         : This method is used to create Enterprise Opportunity.
        Created Date        : 16 July 2018
        Issue No			: ST-2486 
    *****************************************************************************************************************************/
    @AuraEnabled
    public static DatabaseResult createEnterpriseOpportunity(Opportunity oppRec){
        Opportunity objOpportunity = OpportunityHelper.createOpportunity(oppRec);
        TriggerSettings.mappedField.Opportunity_inheritOrganizationRecordTypeAndOwner = false;//Modified by Priyanka Ambre for owner assignment.
        insert objOpportunity;
        if(objOpportunity.Journey__c != null){       
            JourneyHelper.closeOppRelatedJourney(objOpportunity.Journey__c);
        }
        DatabaseResult result = new DatabaseResult(true, objOpportunity, 'Opportunity created successfully.');
        return result;
    }
    
    /****************************************************************************************************************************
        Author              : Priyanka Ambre
        Description         : This method is used to convert EnterpriseLead.
        Created Date        : 16 July 2018 
    *****************************************************************************************************************************/    
    @AuraEnabled
    public static DatabaseResult convertEnterpriseLead(Map<String, Object> mapEntity){        
        try{
            Map<String, Map<String, Object>> mapConvertData;
            List<Task> lstTasks = new List<Task>();
            Account objAccount;
            Contact objContact;
            if(mapEntity.containsKey('leadId') && mapEntity.containsKey('orgAccountId') && mapEntity.get('orgAccountId') != null){
                objAccount = [SELECT Id, RecordType.Name FROM Account WHERE Id =: (String)mapEntity.get('orgAccountId') LIMIT 1];
                List<Contact> lstContacts = new List<Contact>([SELECT Id, RecordType.Name, AccountId FROM Contact WHERE Email =:(String)mapEntity.get('Email') LIMIT 1]);
                List<Lead> lstLeads = new List<Lead>([SELECT Id, Email, OwnerId, (SELECT Id, Status FROM Tasks WHERE Status <> 'Completed') FROM Lead WHERE Id =: (Id)mapEntity.get('leadId') ]);                
                for(Lead objLead : lstLeads){
                    for(Task objTask : objLead.Tasks){
                        lstTasks.add(new Task(Id = objTask.Id, Status = 'Completed'));
                    }
                }
                if(lstLeads[0] != null && !Settings.getUserActive(lstLeads[0].OwnerId) && !String.valueOf(lstLeads[0].OwnerId).toLowerCase().startsWith('00g')){
                    Map<String,String> mapAPIUserInfo = (Map<String,String>)JSON.deserialize(Settings.get('APIUserContactInfo').Data__c, Map<String,String>.class);
                    Lead leadRec = new Lead(Id = lstLeads[0].Id, OwnerId = mapAPIUserInfo.get('UserId'));
                    update leadRec;
                }
                objContact = lstContacts.size() > 0 ? lstContacts[0] : null;
                if(objContact == null){
                    objContact = (Contact)FieldMappingsHelper.getMappings((Id)mapEntity.get('leadId'), 'FieldMappings:LeadToContact');
                    objContact.AccountId = (Id)mapEntity.get('orgAccountId');
                    objContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(objAccount.RecordType.Name).getRecordTypeId();
                    objContact.Convert_Lead__c = false;
                    insert objContact;                    
                } else if(objContact.AccountId == null || objContact.AccountId != (Id)mapEntity.get('orgAccountId')){                    
                    objContact.AccountId = (Id)mapEntity.get('orgAccountId');
                    objContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(objAccount.RecordType.Name).getRecordTypeId();
                    update objContact;
                }
                mapConvertData = new Map<String, Map<String, Object>>{(String)mapEntity.get('Email')=> new Map<String, Object>{'accountId'=>objAccount.Id,'contactId'=>objContact.Id,'leads'=>lstLeads}};                
            }           
            Map<String, Map<String, Id>> mapConvertResultData = LeadConverterHelper.convertLead(mapConvertData);
            Map<String, Id> result = new Map<String, Id>(mapConvertResultData.get((String)mapEntity.get('Email')));
            if(result != null && lstTasks.size() > 0){
                update lstTasks;
            }
           return new DatabaseResult(JSON.serialize(result));
        }catch(Exception pEx) {            
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('CreateOpportunityController', 'convertEnterpriseLead', JSON.serialize(mapEntity), pEx)
            );            
            return new DatabaseResult(pEx);
        }
    }
}