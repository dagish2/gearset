/**********************************************************************************************************************************
    AUTHOR 		: Ramsey Solutions	
    Discription : Placeholder for different Task triggers logic
    History 	: --

---------------------------------------------------------------------------------------------------------------------------------
VERSION 			DATE					AUTHOR							DETAIL											
1					18 Jan 2016				RamseySolutions					Placeholder for different Task triggers
2					12 June 2018			Krishana Tupe					Changes for Optimize the Task trigger
*****************************************************************************************************************************************/
public class TaskTriggerHandler extends ITriggerHandler{
    
    public TaskTriggerHandler(){
        super('Task');
    }
    /*************************************************************************************************
        Author 				: Mayuresh Ghodke
        Description 		: This method overrides before insert method from ITriggerHander which will control the execution flow.
        Created Date		: 18, Jan 2016
        Last Modified By	: Rupesh Patil
        Last Modified Date	: 06 June, 2018
    ****************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){
       Debug.log('Limits.getQueries() BeforeInsert IN Task Trigger:: 1 '+Limits.getQueries());
        if(TriggerSettings.mappedField.Task_UpdateActiveReferrer)
            updateActiveReferrer((List<Task>)listNewItems, null, null, null);
        if(TriggerSettings.mappedField.Task_UpdateOutreachStageOnJourney)
            updateOutreachStageOnJourney((List<Task>)listNewItems, null, null, null);
        Debug.log('Limits.getQueries() BeforeInsert IN Task Trigger:: 2 '+Limits.getQueries());
    }
    
   /*************************************************************************************************
        Author 				: Mayuresh Ghodke
        Description 		: This method overrides after insert method from ITriggerHander which will control the execution flow.
        Created Date		: 18, Jan 2016
        Last Modified By	: Rupesh Patil
        Last Modified Date	: 06 June, 2018
    ****************************************************************************************************/
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems) {   
       Debug.log('Limits.getQueries() BeforeInsert IN Task Trigger:: 3'+Limits.getQueries());
        if(TriggerSettings.mappedField.Task_UpdateLeadEngagementFields)
            updateLeadEngagementFields((List<Task>)listNewItems, null, null, null);  
       Debug.log('Limits.getQueries() BeforeInsert IN Task Trigger:: 4'+Limits.getQueries());
        if(TriggerSettings.mappedField.Task_updateContactOnTask)
            updateContactOnTask((List<Task>)listNewItems, null, null, null);
        Debug.log('Limits.getQueries() BeforeInsert IN Task Trigger:: 5'+Limits.getQueries());
    }
    /*************************************************************************************************
        Author 				: Mayuresh Ghodke
        Description 		: This method overrides before update method from ITriggerHander which will control the execution flow.
        Created Date		: 18, Jan 2016
        Last Modified By	: Rupesh Patil
        Last Modified Date	: 06 June, 2018
    ****************************************************************************************************/
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){  
        if(TriggerSettings.mappedField.Task_CallResultUpdateJourneyNMDDate) 
            updateJourneyNMDNextContactDate((List<Task>)listNewItems,(Map<Id, Task>) mapNewItems, (List<Task>)listOldItems,(Map<Id, Task>) mapOldItems);
        if(TriggerSettings.mappedField.Task_UpdateOutreachStageOnJourney)
            updateOutreachStageOnJourney((List<Task>)listNewItems,(Map<Id, Task>) mapNewItems,(List<Task>) listOldItems,(Map<Id, Task>) mapOldItems);  
        if(TriggerSettings.mappedField.Task_ChangeOwnerToFirstUserWhoRespond)        
            changeTaskOwner((List<Task>)listNewItems,(Map<Id, Task>) mapNewItems, (List<Task>)listOldItems, (Map<Id, Task>)mapOldItems);
    }
   	/*************************************************************************************************
        Author 				: Mayuresh Ghodke
        Description 		: This method overrides after update method from ITriggerHander which will control the execution flow.
        Created Date		: 18, Jan 2016
        Last Modified By	: Rupesh Patil
        Last Modified Date	: 06 June, 2018
    ****************************************************************************************************/
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){	
        if(TriggerSettings.mappedField.Task_UpdateJourneyStageToCompletedLost)
            updateJourneyStageField((List<Task>)listNewItems,(Map<Id, Task>) mapNewItems, (List<Task>)listOldItems, (Map<Id, Task>)mapOldItems);
        if(TriggerSettings.mappedField.Task_updateContactOnTask)
            updateContactOnTask((List<Task>)listNewItems,(Map<Id, Task>) mapNewItems,(List<Task>) listOldItems, (Map<Id, Task>)mapOldItems); 
        if(TriggerSettings.mappedField.Task_ChangeOwnerToFirstUserWhoRespond)
            changeTaskOwner((List<Task>)listNewItems,(Map<Id, Task>) mapNewItems, (List<Task>)listOldItems, (Map<Id, Task>)mapOldItems);
    }
  
    /*************************************************************************************************
        Author 				: Mayuresh Ghodke
        Description 		: This method used to update lead engagement field 
        Created Date		: 17 May, 2016
        Last Modified By 	: Rupesh Patil
        Last Modified Date  : 06 June, 2018
    ****************************************************************************************************/	
    public static void updateLeadEngagementFields(List<Task> listNewItems, Map<Id,Task> mapNewItems, List<Task> listOldItems, Map<Id,Task> mapOldItems) {       
        Set<Id> leadIds = new Set<Id>();
        for(Task objTask : listNewItems){
            if(String.isNotBlank(objTask.WhoId) && String.valueOf(objTask.WhoId).startsWith('00Q') && String.isNotBlank(objTask.Subject) && objTask.Subject.startsWith('Engage Campaign:')){                    
                leadIds.add(objTask.WhoId);                                    
            }
        }
        Map<Id, Lead> leadMap;
        if(leadIds != null && leadIds.size() > 0){
            leadMap = new Map<Id, Lead>([SELECT Id,Engage_Emails_Sent__c,Last_Engage_Email_Sent__c FROM Lead WHERE Id IN :leadIds]);            
        }
        if(leadMap != null){
            for (Task objTask : listNewItems) {
                if(leadMap.containsKey(objTask.WhoId)){
                    Lead objLead = leadMap.get(objTask.WhoId);
                    objLead.Engage_Emails_Sent__c = objLead.Engage_Emails_Sent__c == null ? 1 : objLead.Engage_Emails_Sent__c + 1;
                    objLead.Last_Engage_Email_Sent__c = objTask.CreatedDate; 
                }               
            } 
            update leadMap.values();
        }        
    }
    public class QueueRoundRobinSettings {
        public String excludeprofiles {get; set;}
        public String[] types {get;set;}
        public String[] status {get;set;}
        public String[] excludesubjects {get;set;}
    }
    
    /*************************************************************************************************
        Author 				: Mayuresh Ghodke
        Description 		:  This function will fire on update task. If task is related to Lead and Lead having owner Queue. 
                               Then if we update task with Status : Completed, Type : Call/Email/Phone, Subject : !Inbound Lead submission.
                               Then current user is of that same lead owner's queue then lead's owner get change with current user.
                               Same for Journey WhatId.
        Created Date 		: 13 June,2016
        Last Modified Date	: 06 June, 2018
        Last Modified By	: Rupesh Patil
        Issue No. 			: ST-421
    ****************************************************************************************************/	
    public static void changeTaskOwner(List<Task> listNewItems, Map<Id,Task> mapNewItems, List<Task> listOldItems, Map<Id,Task> mapOldItems){
        Setting__c settingsQueue = Settings.get('QueueManagementSettings');
        
        Set<String> setTypes = new Set<String>();
        Set<String> setStatus = new Set<String>();
        Set<String> setExcludeSubjects = new Set<String>();        
        Set<Id> whatIdJourneySet = new Set<Id>();
        Set<Id> whoIdLeadSet = new Set<Id>();        
        Id currentUserProfileId = userinfo.getProfileId();
        Id currentUser = userinfo.getUserId();
        
        //If no settings are found do not process the queue
        if( settingsQueue == null || String.IsBlank(settingsQueue.Data__c)){
            return;
        }        
        QueueRoundRobinSettings setting = (QueueRoundRobinSettings)JSON.deserialize(settingsQueue.Data__c, QueueRoundRobinSettings.class);
        String excludedProfileId = setting.excludeprofiles;
        if(setting.types != null){
            setTypes = new Set<String>(setting.types);  
        }          
        if(setting.status != null){
            setStatus = new Set<String>(setting.status);  
        }           
        if(setting.excludesubjects != null){
            setExcludeSubjects = new Set<String>(setting.excludesubjects);  
        }         
        String journeyPrefix = Journey__c.SObjectType.getDescribe().getKeyPrefix();
        
        for(Task task : listNewItems){
            if(setStatus.contains(task.Status) && (setTypes.contains(task.Type)) && (!setExcludeSubjects.contains(task.Subject))){
                //Find out WhatId which are Journey.
                if(String.isNotBlank(task.WhatId)){
                    if(String.valueOf(task.WhatId).startsWith(journeyPrefix)){
                        whatIdJourneySet.add(task.WhatId);  
                    }
                }
                //Find out WhoId which are Lead.
                if(String.isNotBlank(task.WhoId)){
                    if(String.valueOf(task.WhoId).startsWith('00Q')){
                        whoIdLeadSet.add(task.WhoId);
                    }
                }
            }
        }
        
        //For Lead whoId
        List<GroupMember> listQueueMember = new List<GroupMember>();
        Set<Id> setLeadOwnerFromQueue = new Set<id>();
        List<Lead> lstLeadToUpdate = new List<Lead>();
        List<Journey__c> lstLeadsJourneyToUpdate = new List<Journey__c>();
        
        if(whoIdLeadSet != null && !whoIdLeadSet.isEmpty()){
            List<Lead> lstLeadOwnerId = new List<Lead>([Select Id,OwnerId From Lead Where Id IN : whoIdLeadSet]);
            List<Journey__c> lstLeadsJourney = new List<Journey__c>([Select Id,OwnerId,Primary_Lead__c From Journey__c Where Primary_Lead__c IN : whoIdLeadSet]);
            //Find out list of queues which are require.
            for(Lead leadOwnerId : lstLeadOwnerId){
                if(String.valueOf(leadOwnerId.OwnerId).startsWith('00G')){
                    setLeadOwnerFromQueue.add(leadOwnerId.OwnerId);
                }
            } 
            //Find out members of queue.
            if(setLeadOwnerFromQueue !=null && !setLeadOwnerFromQueue.isEmpty()){
                listQueueMember =[select Id,GroupId, UserOrGroupId from GroupMember where groupId =:setLeadOwnerFromQueue];
                for(Lead leadIterator : lstLeadOwnerId){
                    for(GroupMember queueMember : listQueueMember){
                        if(queueMember.GroupId == leadIterator.OwnerId && queueMember.UserOrGroupId == currentUser){
                            //Find out Lead's Journey which are having same Queue like Lead and change owner of that journey to current user.
                            for(Journey__c journeyIterator : lstLeadsJourney){
                                if(journeyIterator.Primary_Lead__c == leadIterator.Id && journeyIterator.OwnerId == leadIterator.OwnerId){
                                    journeyIterator.OwnerId = currentUser;
                                    lstLeadsJourneyToUpdate.add(journeyIterator);
                                }
                            }
                            leadIterator.OwnerId = currentUser;
                            lstLeadToUpdate.add(leadIterator);
                        }
                    }
                }
            }
        }
        
        //For Journey whatId
        List<GroupMember> listQueueMemberJourney = new List<GroupMember>();
        Set<Id> setJourneyOwnerFromQueue = new Set<id>();
        List<Journey__c> lstJourneyToUpdate = new List<Journey__c>();
        
        //Find out list of queues which are require.
        if(whatIdJourneySet!=null && !whatIdJourneySet.isEmpty()){
            Set<Journey__c> lstJourneyOwnerId = new Set<Journey__c>([Select OwnerId From Journey__c Where Id IN : whatIdJourneySet]);
            for(Journey__c journeyOwnerId : lstJourneyOwnerId){
                if(String.ValueOf(journeyOwnerId.OwnerId).startsWith('00G')){
                    setJourneyOwnerFromQueue.add(journeyOwnerId.OwnerId);
                }
            }
            //Find out members of queue.
            if(setJourneyOwnerFromQueue !=null && !setJourneyOwnerFromQueue.isEmpty()){
                listQueueMemberJourney =[select Id,GroupId, UserOrGroupId from GroupMember where groupId =:setJourneyOwnerFromQueue];
                for(Journey__c journeyIterator : lstJourneyOwnerId){
                    for(GroupMember queueMember : listQueueMemberJourney){
                        if(queueMember.GroupId == journeyIterator.OwnerId && queueMember.UserOrGroupId == currentUser){
                            journeyIterator.OwnerId = currentUser;
                            lstJourneyToUpdate.add(journeyIterator);
                        }
                    }
                }
            }
        }
        
        if(lstLeadToUpdate!= null && lstLeadToUpdate.size() > 0){
            update lstLeadToUpdate;
        } 
        if(lstLeadsJourneyToUpdate!=null && lstLeadsJourneyToUpdate.size() > 0){
            update lstLeadsJourneyToUpdate; 
        }
        if(lstJourneyToUpdate!=null && lstJourneyToUpdate.size() > 0){
            update lstJourneyToUpdate; 
        }   
    }
    
   /*************************************************************************************************
        Author 				: Samadhan Kadam
        Description 		: This method fire the trigger whenever call result assigned to Do Not Call also Journey Stage is updated to Completed-Lost
        Created Date		: 17 May, 2016
        Last Modified By 	: Rupesh Patil
        Last Modified Date  : 06 June, 2018
    ****************************************************************************************************/
    public static void updateJourneyStageField(List<Task> listNewItems, Map<Id,Task> mapNewItems, List<Task> listOldItems, Map<Id,Task> mapOldItems){
        if(TriggerSettings.mappedField.Task_UpdateJourneyStageToCompletedLost){
            String upperStr;
            List<Journey__c> lstJourneyToUpdate = new List<Journey__c>();            
            for(Task task : listNewItems){       
                if(string.isNotBlank(task.CallDisposition)){                   
                    upperStr = String.valueOf(task.CallDisposition).toUpperCase();
                }                
                if(upperStr == 'DO NOT CALL'){
                    Journey__c journey = new Journey__c();
                    journey.Id = task.whatId;
                    journey.Status__c = 'Unqualified';
                    journey.Lost_Reason__c = 'Not Interested';
                    lstJourneyToUpdate.add(journey);            
                }
            }
            if(lstJourneyToUpdate != null && lstJourneyToUpdate.size() > 0){
                update lstJourneyToUpdate;
            }            
        }
    }
    
  /************************************************************************************************************************
        Author 				: Amol Darekar 
        Description 		: This method used for set NMD Next Contact Date on task create.
        Created  Date 		: 19 May, 2016
        Issue No. 			: ST-297 , ST-298
        Last Modified By 	: Rupesh Patil
        Last Modified Date  : 06 June, 2018
    ************************************************************************************************************************/
    public static void updateJourneyNMDNextContactDate(List<Task> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        Debug.log('updateJourneyNMDNextContactDate---');
        Setting__c JourneySettings = Settings.get('JourneySettings');
        if(JourneySettings != null){
            List<NMDNextDateClass> lstNMDJson;
            Map<String,Integer> mapCallResultToDays = new Map<String,Integer>(); 
            Map<Id,String> mapJourneyToCallResult = new Map<Id,String>(); 
            List<Journey__C> lstJourneys = new List<Journey__C>();
            Schema.sObjectType sObjectTypeJourney = Schema.Journey__c.getSObjectType(); 
            lstNMDJson =  (List<NMDNextDateClass>) JSON.deserialize(JourneySettings.Data__c, List<NMDNextDateClass>.class);                
            for(NMDNextDateClass currentNMDJson : lstNMDJson){
              mapCallResultToDays.put(currentNMDJson.CallResult.toLowerCase(),currentNMDJson.NextDate);  
            }
            Debug.log('mapCallResultToDays :: '+mapCallResultToDays);
            Debug.log('listNewItems---'+listNewItems);
            if(mapCallResultToDays != null){
                for(Task currentTask : listNewItems){
                    if(currentTask.status == 'Completed' && String.isNotBlank(currentTask.whatId) && currentTask.whatId.getSObjectType() == sObjectTypeJourney &&
                       String.isNotBlank(currentTask.CallDisposition) && mapCallResultToDays.containsKey(currentTask.CallDisposition.toLowerCase())){
                           mapJourneyToCallResult.put(currentTask.whatId,currentTask.CallDisposition.toLowerCase());
                           currentTask.ActivityDate = DateUtilities.addBusinessDays(Date.today(), mapCallResultToDays.get(currentTask.CallDisposition.toLowerCase()));   
                    }
                }
                Debug.log('updateJourneyNMDNextContactDate mapJourneyToCallResult---'+mapJourneyToCallResult);
                Map<Id,Journey__c> mapJourneysToUpdate = new Map<Id,Journey__c>();//here map is used to prevent 'Duplicate id in List' exception.
                if(mapJourneyToCallResult != null && mapJourneyToCallResult.size() > 0){
                    Map<Id, String> mapJourneyToContact = new Map<Id, String>(); 
                    for(Journey__c journey : [Select Id, Name, Primary_Contact__c, NMD_Next_Contact_Date__c From Journey__c Where Id IN :mapJourneyToCallResult.keySet()]){
                        if(mapJourneyToCallResult.containsKey(journey.Id) && mapCallResultToDays.containsKey(mapJourneyToCallResult.get(journey.Id).toLowerCase())){
                            Integer intDays = mapCallResultToDays.get(mapJourneyToCallResult.get(journey.Id).toLowerCase());
                            Debug.log('updateJourneyNMDNextContactDate journey---'+journey);
                            journey.NMD_Next_Contact_Date__c = DateUtilities.addBusinessDays(Date.today(), intDays);
                            Debug.log('updateJourneyNMDNextContactDate journey---'+journey);
                            mapJourneysToUpdate.put(journey.Id,journey); 
                            if(journey.Primary_Contact__c != null){
                              mapJourneyToContact.put(journey.Id, journey.Primary_Contact__c);    
                            }                            
                        }
                    }
                    Debug.log('updateJourneyNMDNextContactDate mapJourneyToContact---'+mapJourneyToContact);
                    Debug.log('updateJourneyNMDNextContactDate listNewItems before 1---'+listNewItems);
                    if(mapJourneyToContact.size() > 0){
                        for(Task currentTask : listNewItems){
                            if(String.isNotBlank(currentTask.whatId) && mapJourneyToContact.containsKey(currentTask.whatId)){
                                currentTask.whoId = mapJourneyToContact.get(currentTask.whatId);                                
                            }                
                        }
                    }
                    Debug.log('updateJourneyNMDNextContactDate listNewItems after 1---'+listNewItems);
                }
                Debug.log('updateJourneyNMDNextContactDate listNewItems before 2---'+listNewItems);
                for(Task currentTask : listNewItems){
                    if(String.isNotBlank(currentTask.whatId) && currentTask.whatId.getSObjectType() == sObjectTypeJourney && currentTask.ActivityDate < Date.today() && currentTask.Status != 'Completed'){
                        currentTask.Status = 'Completed'; 
                    }
                }
                Debug.log('updateJourneyNMDNextContactDate listNewItems after 2---'+listNewItems);
                if(mapJourneysToUpdate.size() > 0){
                    update mapJourneysToUpdate.values();
                }
            }
        } 		
    }
    
    /*************************************************************************************************
        Author 				: Mayuresh Ghodke 
        Description 		: This method is used to update active referrer
        Created Date 		: 1 Aug, 2016
        Issue No. 			: ST-585
        Last Modified By 	: Rupesh Patil
        Last Modified Date  : 06 June, 2018
    ****************************************************************************************************/
    public static void updateActiveReferrer(List<Task> listNewItems, Map<Id, Task> mapNewItems, List<Task> listOldItems, Map<Id, Task> mapOldItems){
        set<String> emails = new set<String>();
        set<Id> leadIds = new set<Id>();
        set<Id> contactIds = new set<Id>();
        
        for(Task taskRec : listNewItems){ 
            if(String.isNotBlank(taskRec.WhoId)){
                if(String.valueOf(taskRec.WhoId).startsWith('00Q')){
                    leadIds.add(taskRec.WhoId);   
                }else if(String.valueOf(taskRec.WhoId).startsWith('003')){
                    contactIds.add(taskRec.WhoId);        
                }
            }            
        }
        
        Map<Id, Contact> mapContact = new Map<Id, Contact>();
        Map<Id, Lead> mapLead = new Map<Id, Lead>();
        if(contactIds != null && contactIds.size() > 0){
            mapContact = new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Id in:contactIds]);
            for(Contact con : mapContact.values()){
                if(String.isNotBlank(con.Email)){
                    emails.add(con.Email.toLowerCase()); 
                } 
            }
        }
        
        if(leadIds != null && leadIds.size() > 0){
            mapLead = new Map<Id, Lead>([SELECT Id, Email FROM Lead WHERE Id in:leadIds]);
            for(Lead lead : mapLead.values()){
                if(String.isNotBlank(lead.Email)){
                    emails.add(lead.Email.toLowerCase());  
                }
            }
        }
        
        if(emails != null && emails.size() > 0){
            Map<String, Id> mapActiveReferences = ReferenceHandler.getActiveReference(emails);
            for(Task taskRec : listNewItems){
                if(String.isNotBlank(taskRec.WhoId)){
                    if(String.valueOf(taskRec.WhoId).startsWith('00Q') && mapLead.get(taskRec.WhoId) != null){
                        if(mapLead.get(taskRec.WhoId).Email.toLowerCase() != null){
                            taskRec.Referrer__c = mapActiveReferences.get(mapLead.get(taskRec.WhoId).Email.toLowerCase());
                        }                        
                    } 
                    if(String.valueOf(taskRec.WhoId).startsWith('003') && mapContact.get(taskRec.WhoId) != null){
                        if(mapContact.containsKey(taskRec.WhoId) && String.isNotBlank(mapContact.get(taskRec.WhoId).Email.toLowerCase())){
                            taskRec.Referrer__c = mapActiveReferences.get(mapContact.get(taskRec.WhoId).Email.toLowerCase());   
                        }                       
                    }
                }
            }
        }
    }
  
    public class NMDNextDateClass{
        public String CallResult{get;set;}
        public Integer NextDate{get;set;}  
    }   
    
   /*************************************************************************************************
    Author 				: Dipak Pawar
    Description 		: This method is for update Outreach Stage of all Journeys of related Task.
    Created Date		: 26 Aug, 2016 
    Issue No. 			: ST-639
    Last Modified By 	: Rupesh Patil
    Last Modified Date  : 06 June, 2018
    ****************************************************************************************************/
    public static void updateOutreachStageOnJourney(List<Task> listNewItems, Map<Id, Task> mapNewItems, List<Task> listOldItems, Map<Id, Task> mapOldItems){    
        Set<Id> setTaskRelatedJourneys = new Set<Id>();
        Set<Id> setRelatedPrimaryContacts = new Set<Id>();
        Set<Id> setRelatedPrimaryLeads = new Set<Id>();       
        Map<Id, Journey__c> mapJourneysToBeProcessed = new Map<Id, Journey__c>();
        List<Task> lstTasksToBeProcessed = new List<Task>();        
        for(Task currentTask : listNewItems){
            if(String.isBlank(currentTask.Subject)){
                currentTask.Subject = 'FastCall Outbound Call';
            }
            if((Trigger.IsInsert || (Trigger.isUpdate && mapOldItems.get(currentTask.Id).get('Subject') == 'fc_EmptySubject')) && (String.isNotBlank(currentTask.WhatId) && String.isNotBlank(currentTask.Subject) && String.valueOf(currentTask.Subject).equalsIgnoreCase('FastCall Outbound Call') && String.valueOf(currentTask.WhatId).startsWith('a0j'))) {
                setTaskRelatedJourneys.add(currentTask.WhatId);             
            }
        }      
        if(setTaskRelatedJourneys != null && !setTaskRelatedJourneys.isEmpty()){
            Map<Id, Journey__c> mapRelatedJourneys = new Map<Id, Journey__c>([SELECT Id, Primary_Lead__c, Primary_Contact__c, Outreach_Stage__c, Status__c FROM Journey__c WHERE Status__c = 'Started' AND Id IN :setTaskRelatedJourneys]);
            for(Journey__c journey : mapRelatedJourneys.values()) {
                if(journey.Primary_Lead__c != null) {
                    setRelatedPrimaryLeads.add(journey.Primary_Lead__c);
                }
                if(journey.Primary_Contact__c != null) {
                    setRelatedPrimaryContacts.add(journey.Primary_Contact__c);
                }
            }
            if(!setRelatedPrimaryContacts.isEmpty() || !setRelatedPrimaryLeads.isEmpty()){
                List<Journey__c> lstJourneys = new List<Journey__c>([SELECT Id, Primary_Lead__c, Primary_Contact__c, Outreach_Stage__c, Status__c FROM Journey__c WHERE Status__c = 'Started' AND (Primary_Contact__c IN :setRelatedPrimaryContacts OR Primary_Lead__c IN :setRelatedPrimaryLeads)]);
                Map<Id, List<Journey__c>> mapJourneys = new Map<Id, List<Journey__c>>();
                for(Journey__c journey : lstJourneys) {
                    if(journey.Primary_Contact__c != null && journey.Status__c == 'Started') {                        
                        if(mapJourneys.containsKey(journey.Primary_Contact__c)){
                            List<Journey__c> lstContactJourneys = mapJourneys.get(journey.Primary_Contact__c);
                            lstContactJourneys.add(journey);
                            mapJourneys.put(journey.Primary_Contact__c, lstContactJourneys);    
                        }else{                            
                            mapJourneys.put(journey.Primary_Contact__c, new List<Journey__c>{journey}); 
                        }
                    }
                    if(journey.Primary_Lead__c != null && journey.Status__c == 'Started') {                       
                        if(mapJourneys.containsKey(journey.Primary_Lead__c)){
                            List<Journey__c> lstLeadJourneys = mapJourneys.get(journey.Primary_Lead__c);
                            lstLeadJourneys.add(journey);
                            mapJourneys.put(journey.Primary_Lead__c, lstLeadJourneys);    
                        }else{
                            mapJourneys.put(journey.Primary_Lead__c, new List<Journey__c>{journey});    
                        }
                    }
                }
				Debug.log('mapJourneys==>'+mapJourneys);                
                if(setTaskRelatedJourneys.size() > 0 && mapJourneys.size() > 0) {
                    for(Task currentTask : listNewItems) {  
                        if(String.isEmpty(currentTask.Subject)){
                            currentTask.Subject = 'FastCall Outbound Call';
                        }
                        if(String.isNotBlank(currentTask.Subject) && currentTask.Subject.equalsIgnoreCase('FastCall Outbound Call')  && (mapRelatedJourneys.get(currentTask.WhatId).Outreach_Stage__c == 'Call 1' || (mapRelatedJourneys.get(currentTask.WhatId).Outreach_Stage__c == '') || (mapRelatedJourneys.get(currentTask.WhatId).Outreach_Stage__c == null)) && mapRelatedJourneys.get(currentTask.WhatId).Status__c == 'Started' ){
                            List<Journey__c> journeys = new List<Journey__c>();
                            
                            if((mapRelatedJourneys.get(currentTask.WhatId)).Primary_Contact__c != null) {
                                journeys = mapJourneys.get((mapRelatedJourneys.get(currentTask.WhatId)).Primary_Contact__c);
                            }
                            if((mapRelatedJourneys.get(currentTask.WhatId)).Primary_Lead__c != null) {
                                journeys = mapJourneys.get((mapRelatedJourneys.get(currentTask.WhatId)).Primary_Lead__c);
                            }
                            if(journeys != null && journeys.size() > 0){
                                for(Journey__c journey : journeys){
                                    Task taskForOutreachJourney = new Task();
                                    taskForOutreachJourney.Type = 'Call';
                                    taskForOutreachJourney.TaskSubtype = 'Call';
                                    taskForOutreachJourney.Status = 'Completed';
                                    taskForOutreachJourney.Priority = 'Normal';
                                    taskForOutreachJourney.whatId = journey.Id;
                                    taskForOutreachJourney.WhoId = journey.Primary_Contact__c;
                                    if(journey.Outreach_Stage__c == 'Call 1' && mapRelatedJourneys.get(currentTask.WhatId).Outreach_Stage__c == journey.Outreach_Stage__c) {
                                        journey.Outreach_Stage__c = 'Call 2';
                                        taskForOutreachJourney.Subject = 'Log A Call :'+journey.Outreach_Stage__c;
                                        lstTasksToBeProcessed.add(taskForOutreachJourney);
                                        mapJourneysToBeProcessed.put(journey.Id, journey);
                                    }else if((journey.Outreach_Stage__c == '' || journey.Outreach_Stage__c == null) && mapRelatedJourneys.get(currentTask.WhatId).Outreach_Stage__c == journey.Outreach_Stage__c) {
                                        journey.Outreach_Stage__c = 'Call 1';
                                        taskForOutreachJourney.Subject = 'Log A Call :'+journey.Outreach_Stage__c;
                                        lstTasksToBeProcessed.add(taskForOutreachJourney);
                                        mapJourneysToBeProcessed.put(journey.Id, journey);
                                    }
                                }  
                            }              
                        }
                    }
                }
            }
            Debug.log('mapJourneysToBeProcessed==>'+mapJourneysToBeProcessed);
            if(mapJourneysToBeProcessed.size() > 0){
                update mapJourneysToBeProcessed.values();   
            }   
			Debug.log('lstTasksToBeProcessed==>'+lstTasksToBeProcessed);            
            if(lstTasksToBeProcessed.size() > 0){
                insert lstTasksToBeProcessed; 
            }               
        }
    }
    
  /*************************************************************************************************
        Author 				: Dipak Pawar
        Description 		: This method is for update Contact on task when task create/update with Spacestation Contact UUID we need to display the Contact Name from Salesforce on Task. 
        Created Date		: 19 Dec, 2016 
        Issue No. 			: ST-791
        Last Modified By 	: Rupesh Patil
        Last Modified Date  : 06 June, 2018
    ****************************************************************************************************/
    public static void updateContactOnTask(List<Task> listNewItems, Map<Id,Task> mapNewItems, List<Task> listOldItems, Map<Id,Task> mapOldItems){
        Set<Id> setTaskIds = new Set<Id>();        
        Set<String> setContactUUIds = new Set<String>();       
        Map<Id,Task> mapTriggerOldMap = mapOldItems;
        Map<Id,Task> mapTriggerNewMap;
        Map<String,Contact> mapRelatedContacts = new Map<String,Contact>();
        for(Task task : listNewItems){
            setTaskIds.add(task.Id);
        }
        //This query is used becuase the trigger is after insert/update context and Saleslady_Contact_UUID__c and Salesforce_Contact__c getting null.
        if(setTaskIds != null && setTaskIds.size() > 0){
            mapTriggerNewMap = new Map<Id, Task>([SELECT Id, Subject, Saleslady_Contact_UUID__c, Salesforce_Contact__c FROM Task WHERE Id IN :setTaskIds]);    
        }
        Debug.log('mapTriggerNewMap==>'+mapTriggerNewMap);
        if(mapTriggerNewMap != null && mapTriggerNewMap.size() >0){
            for(Task task : mapTriggerNewMap.values()){
                if(Trigger.IsInsert && task.Saleslady_Contact_UUID__c != null) {
                    setContactUUIds.add(task.Saleslady_Contact_UUID__c);
                }else if(Trigger.IsUpdate && task.Saleslady_Contact_UUID__c != null && task.Saleslady_Contact_UUID__c != mapTriggerOldMap.get(task.Id).Saleslady_Contact_UUID__c) {
                    setContactUUIds.add(task.Saleslady_Contact_UUID__c);
                }
            }
            
            Debug.log('setContactUUIds==>'+setContactUUIds);
            if(!setContactUUIds.isEmpty()){
                for(Contact con : [SELECT Id, Name, Email, UUID__c FROM Contact WHERE UUID__c IN : setContactUUIds]){
                    mapRelatedContacts.put(con.UUID__c, con);
                }
            }        
            Debug.Log('mapRelatedContacts ==> '+mapRelatedContacts);
            Debug.Log('listNewItems ==> '+listNewItems);
            
            Map<Id,Task> mapTasksToUpdate = new Map<Id,Task>();       
            for(Task currentTask :  mapTriggerNewMap.values()){
                Debug.log('currentTask.Saleslady_Contact_UUID__c==>'+currentTask.Saleslady_Contact_UUID__c);           
                Debug.log('currentTask==>'+currentTask);
                if(Trigger.IsInsert) {
                    if(mapRelatedContacts != null && mapRelatedContacts.containsKey(currentTask.Saleslady_Contact_UUID__c)){ 
                        currentTask.Salesforce_Contact__c = mapRelatedContacts.get(currentTask.Saleslady_Contact_UUID__c).Id + ' ' + mapRelatedContacts.get(currentTask.Saleslady_Contact_UUID__c).Name;
                    }else{ 
                        currentTask.Salesforce_Contact__c = ''; 
                    }                
                    mapTasksToUpdate.put(currentTask.Id, currentTask); 
                    Debug.log('mapTasksToUpdate==>'+mapTasksToUpdate);
                }else if(Trigger.IsUpdate){
                    if(currentTask.Saleslady_Contact_UUID__c != null && currentTask.Saleslady_Contact_UUID__c != mapTriggerOldMap.get(currentTask.Id).Saleslady_Contact_UUID__c) {
                        if(!mapRelatedContacts.isEmpty() &&  mapRelatedContacts.containsKey(currentTask.Saleslady_Contact_UUID__c)){                            
                            currentTask.Salesforce_Contact__c = mapRelatedContacts.get(currentTask.Saleslady_Contact_UUID__c).Id + ' ' + mapRelatedContacts.get(currentTask.Saleslady_Contact_UUID__c).Name;
                        }else {
                            currentTask.Salesforce_Contact__c = '';
                        }
                        mapTasksToUpdate.put(currentTask.Id, currentTask);                       
                    }else if(String.isBlank(currentTask.Saleslady_Contact_UUID__c) && currentTask.Saleslady_Contact_UUID__c != mapTriggerOldMap.get(currentTask.Id).Saleslady_Contact_UUID__c) {
                        currentTask.Salesforce_Contact__c = '';
                        mapTasksToUpdate.put(currentTask.Id, currentTask);
                    }                       
                }                    
            }        
            Debug.Log('mapTasksToUpdate ==> '+mapTasksToUpdate);
            
            if(!mapTasksToUpdate.isEmpty()){
                update mapTasksToUpdate.values();
            } 
        }
    }
}