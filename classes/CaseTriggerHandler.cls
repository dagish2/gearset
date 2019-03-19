/************************************************************************************************************************************
    Author 		: 	Dipak Pawar
    Description : 	This class will contain the business logic of CaseTriggers.
    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			23-Nov-2017		    Dipak Pawar 				Initial Development	 
**************************************************************************************************************************************/

public class CaseTriggerHandler extends ITriggerHandler
{
    public CaseTriggerHandler(){
        super('Case');
    }
    
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){ 
        if(TriggerSettings.mappedField.Case_AutoDocumentGenerator){
            Debug.log('In Case_AutoDocumentGenerator AfterInsert SOQL LIMITS before calling:: '+Limits.getQueries()); 
            autoDocumentGenerator(listNewItems, mapNewItems);  
            Debug.log('In Case_AutoDocumentGenerator AfterInsert SOQL LIMITS after calling:: '+Limits.getQueries()); 
        }
    }
    
    public override void BeforeInsert(List<SObject> listNewItems){ 
        if(TriggerSettings.mappedField.Case_RestrictDuplicateCaseCreation){
            Debug.log('In Case_RestrictDuplicateCaseCreation BeforeInsert SOQL LIMITS before calling:: '+Limits.getQueries()); 
            restrictDuplicateCaseCreation(listNewItems);
            Debug.log('In Case_RestrictDuplicateCaseCreation BeforeInsert SOQL LIMITS after calling:: '+Limits.getQueries()); 
        }
        if(TriggerSettings.mappedField.Case_UpdateCaseSubject){
            Debug.log('In Case_UpdateCaseSubject BeforeInsert SOQL LIMITS before calling:: '+Limits.getQueries()); 
        	updateCaseSubject(listNewItems);
            Debug.log('In Case_UpdateCaseSubject BeforeInsert SOQL LIMITS after calling:: '+Limits.getQueries()); 
        }
        if(TriggerSettings.mappedField.Case_CaseOwnerAssignment){
            Debug.log('In Case_CaseOwnerAssignment BeforeInsert SOQL LIMITS before calling:: '+Limits.getQueries()); 
            caseOwnerAssignment(listNewItems);
            Debug.log('In Case_CaseOwnerAssignment BeforeInsert SOQL LIMITS after calling:: '+Limits.getQueries()); 
        }
        if(TriggerSettings.mappedField.Case_RestrictCaseCreationBasedOnOppStages){
            Debug.log('In Case_RestrictCaseCreationBasedOnOppStages BeforeInsert SOQL LIMITS before calling:: '+Limits.getQueries()); 
            restrictCaseCreationBasedOnOppStages(listNewItems);  
            Debug.log('In Case_RestrictCaseCreationBasedOnOppStages BeforeInsert SOQL LIMITS after calling:: '+Limits.getQueries()); 
        }
    }
    
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(TriggerSettings.mappedField.Case_ValidateUserToCloseCases){
            Debug.log('In Case_ValidateUserToCloseCases BeforeUpdate SOQL LIMITS before calling:: '+Limits.getQueries()); 
            validateUserToCloseCases(listNewItems, mapNewItems, listOldItems, mapOldItems); 
            Debug.log('In Case_ValidateUserToCloseCases BeforeUpdate SOQL LIMITS after calling:: '+Limits.getQueries()); 
        }
    }
    
    
    /************************************************************************************************************************************
    Author 				: 	Dipak Pawar
    Description 		: 	Assign the case to User/Queue based On role in Case Template. 
    Issue No.			:	ST-1535
    Last Modified Date	:	23 Jan 2018
    Last Modified By	: 	Dipak Pawar
    **************************************************************************************************************************************/  
   public static void caseOwnerAssignment(List<Case> newItems){
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setOpportunityIds = new Set<Id>();
        Set<Id> setCaseTemplateIds = new Set<Id>();
        for(Case objcase:(List<Case>)newItems){
            if(String.isNotBlank(objCase.AccountId)){
                setAccountIds.add(objCase.AccountId);
            }
            if(String.isNotBlank(objCase.Opportunity__c)){
                setOpportunityIds.add(objCase.Opportunity__c);
            }
            if(String.isNotBlank(objCase.Case_Template__c)){
                setCaseTemplateIds.add(objCase.Case_Template__c);
            }
        }
        if(setCaseTemplateIds.size()>0){
            Map<Id,Case_Template__c> mapCaseTemplate = new Map<Id,Case_Template__c>([Select Id,Name,Default_Owner__c,Owner_Role__c, Record_Type_Name__c From Case_Template__c Where Id IN:setCaseTemplateIds]);
            Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>();
            if(setOpportunityIds.size()>0){
                mapOpportunity = new Map<Id,Opportunity>([Select Id,AccountId,(Select Id,UserId,TeamMemberRole From OpportunityTeamMembers) From Opportunity Where Id IN:setOpportunityIds]);
            }
            for(Opportunity objOpportunity:mapOpportunity.values()){
                if(String.isNotBlank(objOpportunity.AccountId)){
                    setAccountIds.add(objOpportunity.AccountId);
                }
            }
            Map<Id,Account> mapAccount = new Map<Id,Account>();
            if(setAccountIds.size()>0){
                mapAccount = new Map<Id, Account>([Select Id,(Select Id,UserId,TeamMemberRole From AccountTeamMembers) From Account Where Id IN:setAccountIds]);
            }
            List<OpportunityTeamMember> lstMembersToAdd = new List<OpportunityTeamMember>();
            Set<String> setDefaultUsers = new Set<String>();
            Set<String> setDefaultQueues = new Set<String>();
            Set<Case> setDefaultCases = new Set<Case>();
            for(Case objcase:(List<Case>)newItems){
                Id ownerId;
                String userRole ;
                String defaultOwner;
                    
                if(mapCaseTemplate.containsKey(objcase.Case_Template__c) &&  mapCaseTemplate.get(objcase.Case_Template__c).Owner_Role__c != null){
                    userRole = mapCaseTemplate.get(objcase.Case_Template__c).Owner_Role__c;
                }
                if(mapCaseTemplate.containsKey(objcase.Case_Template__c) &&  mapCaseTemplate.get(objcase.Case_Template__c).Default_Owner__c != null){
					defaultOwner = mapCaseTemplate.get(objcase.Case_Template__c).Default_Owner__c;              
                }
                Id accountId;
                if(objcase.Opportunity__c!=null && mapOpportunity.containsKey(objcase.Opportunity__c)){
                    for(OpportunityTeamMember objMember:mapOpportunity.get(objcase.Opportunity__c).OpportunityTeamMembers){
                        if(objMember.TeamMemberRole==userRole){
                            ownerId = objMember.UserId;
                        }
                    }
                    if(ownerId==null){
                        accountId = mapOpportunity.get(objcase.Opportunity__c).AccountId;
                    }
                }
                if(ownerId==null && (objcase.AccountId!=null || accountId!=null)){
                    for(AccountTeamMember objMember:mapAccount.get(accountId!=null?accountId:objcase.AccountId).AccountTeamMembers){
                        if(objMember.TeamMemberRole==userRole){
                            ownerId = objMember.UserId;
                            if(accountId!=null){
                                lstMembersToAdd.add(new OpportunityTeamMember(UserId=objMember.UserId,OpportunityId=objcase.Opportunity__c,TeamMemberRole=userRole));
                            }
                        }
                    }
                }
                if(ownerId==null){
                    if(defaultOwner != null && defaultOwner.containsIgnorecase('user:')){
                        setDefaultUsers.add(defaultOwner.split(':')[1]);
                    }else if(defaultOwner != null && defaultOwner.containsIgnorecase('queue:')){
                        setDefaultQueues.add(defaultOwner.split(':')[1]);
                    }
                    setDefaultCases.add(objCase);
                }else{
                    objcase.OwnerId = ownerId;
                }
            }
            if(setDefaultCases.size()>0){
                Map<String,Id> mapUsers = new Map<String,Id>();
                if(setDefaultUsers.size()>0){
                    for(User objUser:[Select Id,UserName From User Where UserName IN:setDefaultUsers]){
                        mapUsers.put(('user:'+objUser.UserName.toLowerCase()),objUser.Id);
                    }
                }
                Map<String,Id> mapQueues = new Map<String,Id>();
                if(setDefaultQueues.size()>0){
                    for(Group objQueue:[Select Id,Name From Group Where Name IN:setDefaultQueues]){
                        mapQueues.put(('queue:'+objQueue.Name.toLowerCase()),objQueue.Id);
                    }
                }
                for(Case objCase : (List<Case>)newItems){
                    if(setDefaultCases.contains(objCase) && mapCaseTemplate.containsKey(objcase.Case_Template__c)!=null && mapCaseTemplate.get(objcase.Case_Template__c) !=null && mapCaseTemplate.get(objcase.Case_Template__c).Default_Owner__c !=null ){
                        String defaultOwner = mapCaseTemplate.get(objcase.Case_Template__c).Default_Owner__c.toLowerCase();
                        if(defaultOwner.containsIgnorecase('user:')){
                            objCase.OwnerId = mapUsers.get(defaultOwner);
                        }else if(defaultOwner.containsIgnorecase('queue:')){
                            objCase.OwnerId = mapQueues.get(defaultOwner);
                        }
                    }
                    if(objCase.OwnerId==null){
                    	objCase.OwnerId = UserInfo.getUserId();
                    }
                }
            }
            insert lstMembersToAdd;
        }
    } 
    /************************************************************************************************************************************
    Author 				: 	Priyanka Ambre
    Description 		: 	This method is used to close cases manually of valid user profile . 
    Issue No.			:	ST-2000
    Last Modified Date	:	29 Jan 2018
    Last Modified By	: 	Priyanka Ambre
	Code Reviewed by	:   Dipak Pawar 
	Code Reviewed date	:   1 Feb 2018
	Issue No			:   ST-2022
    **************************************************************************************************************************************/  
    public static void validateUserToCloseCases(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        try{
            User loggedInUser = [SELECT Name, Profile.Name, Id, Email, Username, FirstName, LastName, Profile.Id, TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId()];
            Set<String> setProfiles = new Set<String>();
            String strErrorMessage = 'Case Cannot be closed';
            CaseTriggerHandler.AllowedProfilesForManageCases objSettings;
            Setting__c allowedProfilesToManageCasesSetting = Settings.get('AllowedProfilesToManageCases');
            
            if(allowedProfilesToManageCasesSetting != null && allowedProfilesToManageCasesSetting.Data__c != null && String.isNotBlank(String.valueOf(allowedProfilesToManageCasesSetting.Data__c))){
                objSettings = (CaseTriggerHandler.AllowedProfilesForManageCases)JSON.deserialize(String.valueOf(allowedProfilesToManageCasesSetting.Data__c), CaseTriggerHandler.AllowedProfilesForManageCases.class);
                if(objSettings != null && objSettings.profiles != null) {
                    for(String profileName : objSettings.profiles){
                        setProfiles.add(profileName.toLowerCase());
                    }
                }
            }
            for(Case caseRec : (List<Case>) listNewItems) {
                if(caseRec.Status != null && caseRec.Status != mapOldItems.get(caseRec.Id).get('Status')) {
                    if((loggedInUser.Profile.Name).equalsIgnoreCase(caseRec.User_Profile__c) && caseRec.Status == 'Closed' && mapOldItems.get(caseRec.Id).get('Status') != 'Closed') { 
                        if(string.valueOf(caseRec.OwnerId).startsWith('00G'))
                            caseRec.OwnerId = loggedInUser.Id; 
                    } else if(setProfiles.contains(String.valueOf(loggedInUser.Profile.Name).toLowerCase()) && caseRec.Status == 'Closed' && mapOldItems.get(caseRec.Id).get('Status') != 'Closed') {	
                        if(string.valueOf(caseRec.OwnerId).startsWith('00G'))
                            caseRec.OwnerId = loggedInUser.Id;                             
                    } else if(!(loggedInUser.Profile.Name).equalsIgnoreCase(caseRec.User_Profile__c) && !setProfiles.contains(String.valueOf(loggedInUser.Profile.Name).toLowerCase())){
                        caseRec.Status.addError(objSettings.errorMessage);
                    }
                } 
            }            
        }catch(Exception pEx) {            
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('CaseTriggerHandler', 'validateUserToCloseCases', null, pEx)
            );
        } 
    } 
    /************************************************************************************************************************************
    Author 				: 	Dipak Pawar
    Description 		: 	This trigger/function creates the documents based on Document template related to case template of case record.
    Issue No.			:	ST-2001
    Last Modified Date	:	30 Jan 2018
    Last Modified By	: 	Dipak Pawar
    **************************************************************************************************************************************/  
    public static void autoDocumentGenerator(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){
        try{            
            Id entOppReTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
            Set<Id> setAccountIds = new Set<Id>();
            Set<Id> setOppIds = new Set<Id>(); 
            Set<Id> setCaseTemplateIds = new Set<Id>();
            List<Document__c> listDocsToCreate = new List<Document__c>();
            Map<Id, Set<String>> mapDocumentNames = new Map<Id, Set<String>>();
            for(Case caseRec : (List<Case>)listNewItems){
                if(caseRec.Case_Template__c != null){
                    setCaseTemplateIds.add(caseRec.Case_Template__c);
                }
                if(caseRec.Opportunity__c != null && caseRec.Opportunity_RecordType__c != null && caseRec.Opportunity_RecordType__c == entOppReTypeId){
                    setOppIds.add(caseRec.Opportunity__c);
                }
                if(caseRec.AccountId != null){
                    setAccountIds.add(caseRec.AccountId);
                }
             
            }
            
            if(!setCaseTemplateIds.isEmpty()){
                Map<Id, Case_Template__c> mapCaseTemplates = new Map<Id, Case_Template__c>([SELECT Id, Name, Triggering_Object__c, (SELECT Id, Name, Document_Name__c, Document_Type__c, Extensions_Allowed__c, Object__c FROM Document_Templates__r) FROM Case_Template__c WHERE Id IN :setCaseTemplateIds]);
               for(Document__c docRec : [SELECT Id, Name, Account__c, Is_Finalized__c, Opportunity__c, Type__c FROM Document__c WHERE (Account__c IN :setAccountIds OR Opportunity__c IN :setOppIds )]){                    
                    List<Document__c> lstDocs = null;
                    Set<String> setDocNames = null;
                    if(docRec.Account__c != null){                    
                        setDocNames = mapDocumentNames.containsKey(docRec.Account__c)?mapDocumentNames.get(docRec.Account__c):new Set<String>();
                        setDocNames.add(String.valueOf(docRec.Name).toLowerCase());
                        mapDocumentNames.put(docRec.Account__c, setDocNames);
                    } 
                    if(docRec.Opportunity__c != null){
                        setDocNames = mapDocumentNames.containsKey(docRec.Opportunity__c)?mapDocumentNames.get(docRec.Opportunity__c):new Set<String>();
                        setDocNames.add(String.valueOf(docRec.Name).toLowerCase());
                        mapDocumentNames.put(docRec.Opportunity__c, setDocNames);
                    }                 
                }
                
                if(!mapCaseTemplates.isEmpty()){                    
                    for(Case caseRec : (List<Case>)listNewItems){
                        if(caseRec.Case_Template__c != null && mapCaseTemplates.containsKey(caseRec.Case_Template__c) && mapCaseTemplates.get(caseRec.Case_Template__c) != null && mapCaseTemplates.get(caseRec.Case_Template__c).Document_Templates__r != null && mapCaseTemplates.get(caseRec.Case_Template__c).Document_Templates__r.size() > 0){                            
                            if(caseRec.Opportunity__c != null && caseRec.Opportunity_RecordType__c != null && caseRec.Opportunity_RecordType__c == entOppReTypeId){
                                for(Document_Template__c docTemplateRec : mapCaseTemplates.get(caseRec.Case_Template__c).Document_Templates__r){                                    
                                    Boolean createDocRec = false;
                                    if(mapDocumentNames.containsKey(caseRec.Opportunity__c) && mapDocumentNames.get(caseRec.Opportunity__c) != null && !mapDocumentNames.get(caseRec.Opportunity__c).contains(String.valueOf(docTemplateRec.Document_Name__c).toLowerCase())){
                                        createDocRec = true;
                                    } else if(!mapDocumentNames.containsKey(caseRec.Opportunity__c)){
                                        createDocRec = true;                                        
                                    }
                                    if(createDocRec){
                                        Document__c docRec = new Document__c(
                                            Name = docTemplateRec.Document_Name__c,
                                            Document_Template__c = docTemplateRec.Id,
                                            Extensions_Allowed__c = docTemplateRec.Extensions_Allowed__c,
                                            Is_Finalized__c = false,
                                            Opportunity__c = caseRec.Opportunity__c,
                                            Type__c = docTemplateRec.Document_Type__c
                                        );
                                        listDocsToCreate.add(docRec);
                                        Set<String> setDocNames = mapDocumentNames.containsKey(caseRec.Opportunity__c)?mapDocumentNames.get(caseRec.Opportunity__c):new Set<String>();
                                        setDocNames.add(String.valueOf(docRec.Name).toLowerCase());
                                        mapDocumentNames.put(caseRec.Opportunity__c, setDocNames);
                                    }
                                }
                            }
                            if(caseRec.AccountId != null){
                                for(Document_Template__c docTemplateRec : mapCaseTemplates.get(caseRec.Case_Template__c).Document_Templates__r){
                                    Boolean createDocRec = false;
                                    if(mapDocumentNames.containsKey(caseRec.AccountId) && mapDocumentNames.get(caseRec.AccountId) != null && !mapDocumentNames.get(caseRec.AccountId).contains(String.valueOf(docTemplateRec.Document_Name__c).toLowerCase())){
                                        createDocRec = true;
                                    } else if(!mapDocumentNames.containsKey(caseRec.AccountId)){
                                        createDocRec = true;
                                    }
                                    if(createDocRec){
                                        Document__c docRec = new Document__c(
                                            Account__c = caseRec.AccountId,
                                            Name = docTemplateRec.Document_Name__c,
                                            Document_Template__c = docTemplateRec.Id,
                                            Extensions_Allowed__c = docTemplateRec.Extensions_Allowed__c,
                                            Is_Finalized__c = false,
                                            Type__c = docTemplateRec.Document_Type__c
                                        );
                                        listDocsToCreate.add(docRec);
                                        Set<String> setDocNames = mapDocumentNames.containsKey(caseRec.AccountId)?mapDocumentNames.get(caseRec.AccountId):new Set<String>();
                                        setDocNames.add(String.valueOf(docRec.Name).toLowerCase());
                                        mapDocumentNames.put(caseRec.AccountId, setDocNames);
                                    }                                
                                }
                            } 
                        }                    
                    }
                    if(listDocsToCreate.size() > 0){
                        insert listDocsToCreate;
                    }
                }
            }
        }catch(Exception pEx) {
            List<Id> ids = New List<Id>();
            if(mapNewItems!=null)
                ids.addAll(mapNewItems.keyset());
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('CaseTriggerHandler','autoDocumentGenerator',String.join(ids,','),pEx)
            );
        }
    }
     /************************************************************************************************************************************
        Author 				: 	Priyanka Ambre
        Description 		: 	This is a wrapper class used in restrictCaseCreationBasedOnOppStages method to make list
								of profiles that will be bypassed by trigger and Error message to display.
        Created Date		:	30 Jan 2018
	**************************************************************************************************************************************/
    public class AllowedProfilesForManageCases {
        public List<String> profiles {get;set;}
        public  String errorMessage {get;set;}
    } 
    /************************************************************************************************************************************
    Author 				: 	Priyanka Ambre
    Description 		: 	This method is used to create cases manually for valid Request type and Opportunity Stages.
    Issue No.			:	ST-2005
    Last Modified Date	:	31 Jan 2018
    Last Modified By	: 	Priyanka Ambre
    **************************************************************************************************************************************/  
    public static void restrictCaseCreationBasedOnOppStages(List<SObject> listNewItems){
        try{  
            Map<String, Set<String>> mapAllowedOppStagesForRequestType = new  Map<String, Set<String>>();    
            Set<String> setRequestType = new Set<String>();
            Set<Id> setCaseOppIds = new Set<Id>();
            for(Case caseRec : (List<Case>) listNewItems){
                if(caseRec != null && caseRec.Opportunity__c != null){
                    setCaseOppIds.add(caseRec.Opportunity__c);
                    setRequestType.add(caseRec.Requested_Type__c);
                }
            }
            if(setRequestType.size()>0){
                //Get Cases related Case Templates records with Opportunity Stages
                for( Case_Template__c caseTemplateRec : [SELECT Id, Name, Opportunity_Stages__c FROM Case_Template__c WHERE Name IN:setRequestType]){
                    if(caseTemplateRec.Opportunity_Stages__c != null){
                        mapAllowedOppStagesForRequestType.put(String.valueOf(caseTemplateRec.Name).toLowerCase(), new Set<String>(String.valueOf(caseTemplateRec.Opportunity_Stages__c).toLowerCase().split(';')));
                    } else {
                        mapAllowedOppStagesForRequestType.put(String.valueOf(caseTemplateRec.Name).toLowerCase(), null);
                    }
                }
            }
            
            Debug.log('mapAllowedOppStagesForRequestType---' + mapAllowedOppStagesForRequestType);  
            //Get Cases related Opportunity records.
            Map<Id, Opportunity> mapCaseOpportunities = new Map<Id, Opportunity>([SELECT Name, StageName FROM Opportunity WHERE Id IN:setCaseOppIds]);
            Debug.log('mapCaseOpportunities---' + mapCaseOpportunities); 
            for(Case caseRec : (List<Case>) listNewItems){
                if(caseRec != null && caseRec.Opportunity__c != null && mapCaseOpportunities.containsKey(caseRec.Opportunity__c)){
                     if(mapCaseOpportunities.get(caseRec.Opportunity__c) != null && mapCaseOpportunities.get(caseRec.Opportunity__c).StageName  != null && caseRec.Requested_Type__c != null && mapAllowedOppStagesForRequestType.containsKey(String.valueOf(caseRec.Requested_Type__c).toLowerCase())){
                        if(mapAllowedOppStagesForRequestType.get(String.valueOf(caseRec.Requested_Type__c).toLowerCase()) == null){
                            caseRec.addError('Case can not be saved for this Opportunity Stage');   
                        } else if(!mapAllowedOppStagesForRequestType.get(String.valueOf(caseRec.Requested_Type__c).toLowerCase()).contains('any')){
                            if((mapAllowedOppStagesForRequestType.get(String.valueOf(caseRec.Requested_Type__c).toLowerCase()).size() > 0 && !mapAllowedOppStagesForRequestType.get(String.valueOf(caseRec.Requested_Type__c).toLowerCase()).contains(String.valueOf(mapCaseOpportunities.get(caseRec.Opportunity__c).StageName).toLowerCase()))){
                                caseRec.addError('Case can not be created for this Opportunity Stage : '+mapCaseOpportunities.get(caseRec.Opportunity__c).StageName);   
                            }
                        }
                    }  
                } 
            }
        }catch(Exception pEx){ 
            Debug.log('pEx In restrictCaseCreationBasedOnOppStages---' + pEx); 
            new ApexDebugLog().createLog(new ApexDebugLog.Error('CaseTriggerHandler', 'restrictCaseCreationBasedOnOppStages', null, pEx));
        }
    }
    
    /************************************************************************************************************************************
    Author 				: 	Priyanka Ambre
    Description 		: 	This method is used to set Subject and case template on case. 
    Issue No.			:	ST-2009
    Last Modified Date	:	02 Feb 2018
    Last Modified By	: 	Priyanka Ambre
    **************************************************************************************************************************************/  
    public static void updateCaseSubject(List<SObject> listNewItems){
        try{
            Id entOppReTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
            Set<Id> setAccountIds = new Set<Id>();
            Set<Id> setOppIds = new Set<Id>(); 
            Set<String> setRequestType = new Set<String>();
            Map<String, List<Case_Template__c>> mapCaseTemplate = new Map<String, List<Case_Template__c>>(); 
            for(Case caseRec : (List<Case>)listNewItems){
                if(caseRec.Requested_Type__c != null){
                    setRequestType.add(caseRec.Requested_Type__c);
                }
                if(caseRec.Opportunity__c != null && caseRec.Opportunity_RecordType__c != null && caseRec.Opportunity_RecordType__c == entOppReTypeId){
                    setOppIds.add(caseRec.Opportunity__c);
                }
                if(caseRec.AccountId != null){
                    setAccountIds.add(caseRec.AccountId);
                } 
            }
            if(!setRequestType.isEmpty()){
                for(Case_Template__c caseTemplateRec : [SELECT Id, Name, Opportunity_Stages__c, Triggering_Object__c,Record_Type_Name__c  FROM Case_Template__c WHERE Name IN:setRequestType]){
                    if(caseTemplateRec.Triggering_Object__c != null){
                        List<Case_Template__c> lstTempCaseTemplate = new List<Case_Template__c>();
                        if(mapCaseTemplate.containsKey(String.valueOf(caseTemplateRec.Triggering_Object__c).toLowerCase())){
                            lstTempCaseTemplate.addAll(mapCaseTemplate.get(String.valueOf(caseTemplateRec.Triggering_Object__c).toLowerCase()));  
                        } 
                        lstTempCaseTemplate.add(caseTemplateRec);
                        mapCaseTemplate.put(String.valueOf(caseTemplateRec.Triggering_Object__c).toLowerCase(), lstTempCaseTemplate);
                    }
                }
            } 
            Map<Id, Account> mapCaseAccounts = setAccountIds.size() > 0 ? new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN:setAccountIds]):new Map<Id, Account>();
            Map<Id, Opportunity> mapCaseOpportunities = setOppIds.size() > 0 ?new Map<Id, Opportunity>([SELECT Name, StageName, AccountId, Account.Name FROM Opportunity WHERE Id IN:setOppIds]):new Map<Id, Opportunity>();
            
            if(!mapCaseTemplate.isEmpty()){ 
                for(Case caseRec : (List<Case>) listNewItems){ 
                    if(caseRec.Requested_Type__c != null && caseRec.Record_Type_Name__c != null){
                        if(caseRec.Opportunity__c != null && mapCaseTemplate.containsKey('opportunity') && mapCaseTemplate.get('opportunity') != null){
                             for(Case_Template__c caseTemplateRec : mapCaseTemplate.get('opportunity')){
                                 if(caseTemplateRec.Record_Type_Name__c != null && (caseTemplateRec.Record_Type_Name__c).toLowerCase()==Schema.SObjectType.Case.getRecordTypeInfosById().get(caseRec.RecordTypeId).getName().toLowerCase()){
                                    if(caseTemplateRec.Name != null && String.valueOf(caseRec.Requested_Type__c).toLowerCase() == String.valueOf(caseTemplateRec.Name).toLowerCase()){ 
                                        caseRec.Case_Template__c = caseTemplateRec.Id;
                                    }
                                    if(mapCaseOpportunities.containsKey(caseRec.Opportunity__c) && mapCaseOpportunities.get(caseRec.Opportunity__c) != null && mapCaseOpportunities.get(caseRec.Opportunity__c).Account.Name !=null){
                                        caseRec.Subject = mapCaseOpportunities.get(caseRec.Opportunity__c).Account.Name + '-' + caseTemplateRec.Record_Type_Name__c + '-' + caseRec.Requested_Type__c; 
                                        caseRec.AccountId = mapCaseOpportunities.get(caseRec.Opportunity__c).AccountId;
                                    } 
                                }
                            }
                        } else if(caseRec.AccountId != null && mapCaseTemplate.containsKey('account') && mapCaseTemplate.get('account') != null){
                            for(Case_Template__c caseTemplateRec : mapCaseTemplate.get('account')){
                                if(caseTemplateRec.Record_Type_Name__c != null && ((caseTemplateRec.Record_Type_Name__c).toLowerCase()==Schema.SObjectType.Case.getRecordTypeInfosById().get(caseRec.RecordTypeId).getName().toLowerCase())){
                                    if(caseTemplateRec.Name != null && String.valueOf(caseRec.Requested_Type__c).toLowerCase() == String.valueOf(caseTemplateRec.Name).toLowerCase() && mapCaseAccounts.containsKey(caseRec.AccountId) && mapCaseAccounts.get(caseRec.AccountId) != null && mapCaseAccounts.get(caseRec.AccountId).Name != null){ 
                                        caseRec.Case_Template__c = caseTemplateRec.Id;
                                        caseRec.Subject = mapCaseAccounts.get(caseRec.AccountId).Name + '-' + caseTemplateRec.Record_Type_Name__c + '-' + caseRec.Requested_Type__c;
                                    }
                                } 
                            }   
                        }  
                    }
                }
            } 
        } catch(Exception Exc){ 
            Debug.log('Exc In updateCaseSubject ---' + Exc); 
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('CaseTriggerHandler','updateCaseSubject',null,Exc));
        }
    }
    /************************************************************************************************************************************
    Author 				: 	Priyanka Ambre
    Description 		: 	This method is used to restrict duplicate case creation. 
    Issue No.			:	ST-2137
    Last Modified Date	:	20 Mar 2018
    Last Modified By	: 	Priyanka Ambre
    **************************************************************************************************************************************/  
    public static void restrictDuplicateCaseCreation(List<SObject> listNewItems){
        try{
            Map<String, Case> mapCases = new Map<String, Case>();
            Set<Id> setAccountIds = new Set<Id>();
            Set<Id> setOppIds = new Set<Id>();          
            for(Case caseRec : (List<Case>) listNewItems){
                String caseKey;
                String recordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(caseRec.RecordTypeId).getName().toLowerCase();
                if(recordTypeName!=null &&  caseRec.Requested_Type__c != null &&  caseRec.Status != 'Closed'){
                    if(caseRec.Opportunity__c !=null){
                        caseKey = caseRec.Opportunity__c+'-'+recordTypeName+'-'+caseRec.Requested_Type__c;
                        if(!mapCases.containsKey(caseKey)){
                            mapCases.put(caseKey, caseRec);
                            setOppIds.add(caseRec.Opportunity__c);
                        } else{
                            caseRec.addError('Duplicate case can not be created');   
                        }
                    } else if(caseRec.AccountId !=null && caseRec.Opportunity__c==null){
                        caseKey = caseRec.AccountId+'-'+recordTypeName+'-'+caseRec.Requested_Type__c;
                        if(!mapCases.containsKey(caseKey)){
                            mapCases.put(caseKey, caseRec);
                            setAccountIds.add(caseRec.AccountId);
                        } else{
                            caseRec.addError('Duplicate case can not be created');   
                        }
                    } 
                }
            }
            Map<String, Case> mapExistingCases = new Map<String, Case>();
            for(Case caseRec : [SELECT Requested_Type__c, AccountId, Opportunity__c, RecordTypeId, Status, Record_Type_Name__c FROM Case WHERE ((Opportunity__c IN:setOppIds OR AccountId IN:setAccountIds) AND (Status != 'Closed'))]){
                String recordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(caseRec.RecordTypeId).getName().toLowerCase();
                if(recordTypeName!=null &&  caseRec.Requested_Type__c != null &&  caseRec.Status != 'Closed'){
                    if(caseRec.Opportunity__c !=null){
                        String caseKey = caseRec.Opportunity__c+'-'+recordTypeName+'-'+caseRec.Requested_Type__c;
                        if(!mapExistingCases.containsKey(caseKey)){
                            mapExistingCases.put(caseKey, caseRec);
                            setOppIds.add(caseRec.Opportunity__c);
                        } 
                    }
                    if(caseRec.AccountId !=null && caseRec.Opportunity__c==null ){
                        String caseKey = caseRec.AccountId+'-'+recordTypeName+'-'+caseRec.Requested_Type__c;
                        if(!mapExistingCases.containsKey(caseKey)){
                            mapExistingCases.put(caseKey, caseRec);
                            setAccountIds.add(caseRec.AccountId);
                        } 
                    } 
                }
                for(String str : mapCases.keySet()){
                    if(mapExistingCases.containsKey(str)){
                        mapCases.get(str).addError('Duplicate case can not be created');   
                    }
                }
            }
        }catch(Exception Exc){ 
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('CaseTriggerHandler','restrictDuplicateCaseCreation',null,Exc));
        }
    }
}