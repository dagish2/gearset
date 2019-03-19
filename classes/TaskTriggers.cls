/**********************************************************************************************************************************
    AUTHOR 		: RamseySolutions	
    Discription : Placeholder for different Task triggers logic
    History 	: --
    Comment 	: Code is depricated  so commented by Rupesh Patil
---------------------------------------------------------------------------------------------------------------------------------
	VERSION 			DATE					AUTHOR							DETAIL											
	1					18, Jan 2016			RamseySolutions					Placeholder for different Task triggers
*****************************************************************************************************************************************/
public class TaskTriggers extends ITriggerHandler{
    
    public TaskTriggers(){
        super('Task');
    }
    /*************************************************************************************************
    Author 				: Mayuresh Ghodke
    Description 		: This method overrides before insert method from ITriggerHander which will control the execution flow.
    Created Date		: 18, Jan 2016
	Last Modified By	: Prashant Mane
    Last Modified Date	: 02 Feb, 2018
****************************************************************************************************/
    /*public override void BeforeInsert(List<SObject> listNewItems)
    {
        updateActiveReferrer(listNewItems, null, null, null);       
        updateOutreachStageOnJourney(listNewItems, null, null, null);
    }
    /*************************************************************************************************
    Author 				: Mayuresh Ghodke
    Description 		: This method overrides after insert method from ITriggerHander which will control the execution flow.
    Created Date		: 18, Jan 2016
	Last Modified By	: Prashant Mane
    Last Modified Date	: 02 Feb, 2018
****************************************************************************************************/
  /*  public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems)
    {       
        updateLeadEngagementFields(listNewItems, null, null, null);       
        updateJourneyOnTour(listNewItems, null, null, null);                  	
        updateContactOnTask(listNewItems, null, null, null);
    }
    /*************************************************************************************************
    Author 				: Mayuresh Ghodke
    Description 		: This method overrides before update method from ITriggerHander which will control the execution flow.
    Created Date		: 18, Jan 2016
	Last Modified By	: Prashant Mane
    Last Modified Date	: 02 Feb, 2018
****************************************************************************************************/
   /* public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems)
    {  
        updateJourneyNMDNextContactDate(listNewItems, mapNewItems, listOldItems, mapOldItems);
        updateOutreachStageOnJourney(listNewItems, mapNewItems, listOldItems, mapOldItems);     	
        changeTaskOwner(listNewItems, mapNewItems, listOldItems, mapOldItems);
    }
    /*************************************************************************************************
    Author 				: Mayuresh Ghodke
    Description 		: This method overrides after update method from ITriggerHander which will control the execution flow.
    Created Date		: 18, Jan 2016
	Last Modified By	: Prashant Mane
    Last Modified Date	: 02 Feb, 2018
****************************************************************************************************/
   /* public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems)
    {	    
        updateJourneyStageField(null, null, null, null);
        updateContactOnTask(listNewItems, mapNewItems, listOldItems, mapOldItems); 
        changeTaskOwner(listNewItems, mapNewItems, listOldItems, mapOldItems);
    }
	/*************************************************************************************************
       Author 				: Mayuresh Ghodke
       Description 			: This method used to update lead engagement field 
       Created Date			: 17 May, 2016
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
****************************************************************************************************/	
   /* public static void updateLeadEngagementFields(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems) 
    {
        if(TriggerSettings.mappedField.Task_UpdateLeadEngagementFields)
        {
            Task[] newTasks = listNewItems;
            Set<Task> tasksToProcess = new Set<Task>{};
                Set<Id> leadIds = new Set<Id>{};
                    
                    for (Task t:newTasks) {
                        
                        if (!String.isBlank(t.WhoId) &&
                            String.valueOf(t.WhoId).startsWith('00Q') &&
                            !String.isBlank(t.Subject) &&
                            t.Subject.startsWith('Engage Campaign:')) {
                                
                                tasksToProcess.add(t);
                                leadIds.add(t.WhoId);
                            }
                    }
            if (!tasksToProcess.isEmpty()) {
                Map<Id, Lead> leadMap = new Map<Id, Lead>([select Id,
                                                           Engage_Emails_Sent__c,
                                                           Last_Engage_Email_Sent__c
                                                           from Lead
                                                           where Id in :leadIds]);
                for (Task t:tasksToProcess) {
                    Lead l = leadMap.get(t.WhoId);
                    l.Engage_Emails_Sent__c = l.Engage_Emails_Sent__c == null ? 1 : l.Engage_Emails_Sent__c + 1;
                    l.Last_Engage_Email_Sent__c = t.CreatedDate;
                }
                update leadMap.values();
            }
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
       Description 			:  This function will fire on update task. If task is related to Lead and Lead having owner Queue. 
     		          		   Then if we update task with Status : Completed, Type : Call/Email/Phone, Subject : !Inbound Lead submission.
            		    	   Then current user is of that same lead owner's queue then lead's owner get change with current user.
     		          		   Same for Journey WhatId.
	   Created Date 		: 13 June,2016
       Last Modified Date	: 1 Feb, 2018
       Last Modified By		: Mayuresh Ghodke & Samadhan Kadam
 	   Issue No. 			: ST-421
****************************************************************************************************/	
    /*public static void changeTaskOwner(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems) 
    {
        if(TriggerSettings.mappedField.Task_ChangeOwnerToFirstUserWhoRespond)
        {
            Setting__c settingsQueue = Settings.get('QueueManagementSettings');
            Set<String> setTypes = new Set<String>();
            Set<String> setStatus = new Set<String>();
            Set<String> setExcludeSubjects = new Set<String>();
            
            Set<Id> whatIdJourneySet = new Set<Id>();
            Set<Id> whoIdLeadSet = new Set<Id>();
            
            Id currentUserProfileId = userinfo.getProfileId();
            Id currentUser = userinfo.getUserId();
            
            //If no settings are found do not process the queue
            if( settingsQueue == null || String.IsBlank(settingsQueue.Data__c))
                return;
            
            QueueRoundRobinSettings setting = (QueueRoundRobinSettings)JSON.deserialize(settingsQueue.Data__c, QueueRoundRobinSettings.class);
            String excludedProfileId = setting.excludeprofiles;
            if(setting.types != null)
                setTypes = new Set<String>(setting.types);
            if(setting.status != null)
                setStatus = new Set<String>(setting.status);
            if(setting.excludesubjects != null)
                setExcludeSubjects = new Set<String>(setting.excludesubjects);
            
            String journeyPrefix = Journey__c.SObjectType.getDescribe().getKeyPrefix();
            
            for(Task task : (List<Task>)Trigger.New){
                if(setStatus.contains(task.Status) && (setTypes.contains(task.Type)) && (!setExcludeSubjects.contains(task.Subject))){
                    //Find out WhatId which are Journey.
                    if(task.WhatId != null){
                        if(String.valueOf(task.WhatId).startsWith(journeyPrefix)){
                            whatIdJourneySet.add(task.WhatId);  
                        }
                    }
                    //Find out WhoId which are Lead.
                    if(task.WhoId != null){
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
                    if(String.ValueOf(leadOwnerId.OwnerId).startsWith('00G')){
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
            List<GroupMember> listQueueMemberJaourney = new List<GroupMember>();
            Set<Id> setJaourneyOwnerFromQueue = new Set<id>();
            List<Journey__c> lstJaourneyToUpdate = new List<Journey__c>();
            
            //Find out list of queues which are require.
            if(whatIdJourneySet!=null && !whatIdJourneySet.isEmpty()){
                Set<Journey__c> lstJourneyOwnerId = new Set<Journey__c>([Select OwnerId From Journey__c Where Id IN : whatIdJourneySet]);
                for(Journey__c journeyOwnerId : lstJourneyOwnerId){
                    if(String.ValueOf(journeyOwnerId.OwnerId).startsWith('00G')){
                        setJaourneyOwnerFromQueue.add(journeyOwnerId.OwnerId);
                    }
                }
                //Find out members of queue.
                if(setJaourneyOwnerFromQueue !=null && !setJaourneyOwnerFromQueue.isEmpty()){
                    listQueueMemberJaourney =[select Id,GroupId, UserOrGroupId from GroupMember where groupId =:setJaourneyOwnerFromQueue];
                    for(Journey__c journeyIterator : lstJourneyOwnerId){
                        for(GroupMember queueMember : listQueueMemberJaourney){
                            if(queueMember.GroupId == journeyIterator.OwnerId && queueMember.UserOrGroupId == currentUser){
                                journeyIterator.OwnerId = currentUser;
                                lstJaourneyToUpdate.add(journeyIterator);
                            }
                        }
                    }
                }
            }
            
            if(lstLeadToUpdate!=null && !lstLeadToUpdate.isEmpty())
                update lstLeadToUpdate;
            
            if(lstLeadsJourneyToUpdate!=null && !lstLeadsJourneyToUpdate.isEmpty())
                update lstLeadsJourneyToUpdate;
            
            if(lstJaourneyToUpdate!=null && !lstJaourneyToUpdate.isEmpty())   
                update lstJaourneyToUpdate;  
        }
    }
    

	/*************************************************************************************************
       Author 				: Samadhan Kadam
       Description 			: This method fire the trigger whenever call result assigned to Do Not Call also Journey Stage is updated to Completed-Lost
       Created Date			: 17 May, 2016
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
****************************************************************************************************/
   /* public static void updateJourneyStageField(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems) 
    {
        if(TriggerSettings.mappedField.Task_UpdateJourneyStageToCompletedLost)
        {
            String callResult,upperStr;
            List<Journey__c> lstJourneyToUpdate = new List<Journey__c>();
            
            for(Task task : (List<Task>)Trigger.New)
            {       
                if(!string.isBlank(task.CallDisposition))
                {
                    callResult = task.CallDisposition;
                    upperStr = callResult.toUpperCase();
                }
                
                if(upperStr == 'DO NOT CALL')
                {
                    Journey__c journey = new Journey__c();
                    journey.Id = task.whatId;
                    journey.Status__c = 'Unqualified';
                    journey.Lost_Reason__c = 'Not Interested';
                    lstJourneyToUpdate.add(journey);            
                }
            }
            if(lstJourneyToUpdate.size() > 0)
                update lstJourneyToUpdate;
        }
    }
    
	/*************************************************************************************************
    Author 				: Amol Darekar 
    Description 		: This method used for set NMD Next Contact Date on task create.
    Created  Date 		: 19 May, 2016
    Issue No. 			: ST-297 , ST-298
    Last Modified By 	: Prashant Mane
    Last Modified Date  : 02 Feb,2018
****************************************************************************************************/
  /*  public static void updateJourneyNMDNextContactDate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems)
    {
        if(TriggerSettings.mappedField.Task_CallResultUpdateJourneyNMDDate && !AvoidRecurssion.isUpdateJourneyNMDNextContactDate)
        {
            try
            {
                list<Task> lstTask = listNewItems;
                map<Id,String> mapTaskCallResult = new map<Id,String>();
                map<String,Integer> mapAddDays = new map<String,Integer>();
                map<Id,Id> mapJourneyContactIds = new map<Id,Id>();
                set<Id> setTaskJournyWhatIds = new set<Id>();
                Debug.log('Task_CallResultUpdateJourneyNMDDate::');
                
                list<Task> lstOpenTask = new list<Task>();
                set<Id> setTaskWhatId = new set<Id>();
                
                //Modified By Dipak Pawar for SOQL optimization
                //String NMDJson = [Select Data__c from Setting__c where Name=:'JourneySettings'].Data__c;
                String NMDJson;
                Setting__c JourneySettings = Settings.get('JourneySettings');
                if(JourneySettings != null){
                    NMDJson = JourneySettings.Data__c;
                    Debug.log('NMDJson :: '+NMDJson);
                }         
                
                list<NMDNextDateClass> lstNMDJson =  (List<NMDNextDateClass>) JSON.deserialize(NMDJson, List<NMDNextDateClass>.class);
                
                for(NMDNextDateClass currentNMDJson : lstNMDJson)
                {
                    mapAddDays.put(currentNMDJson.CallResult,currentNMDJson.NextDate);
                }
                
                Schema.sObjectType sObjectTypeJourney = Schema.Journey__c.getSObjectType();
                
                Debug.log('mapAddDays::'+mapAddDays);
                
                for(Task currentTask : lstTask)
                {
                    //Task objOldTask = (Task) Trigger.oldMap.get(currentTask.Id);
                    //objOldTask.status == 'Not Started' && 
                    
                    if(currentTask.status == 'Completed' && currentTask.whatId != null && currentTask.whatId.getSObjectType() == sObjectTypeJourney)
                    {
                        if(!String.isBlank(currentTask.CallDisposition) && (mapAddDays != null && mapAddDays.containsKey(currentTask.CallDisposition)))
                        {
                            mapTaskCallResult.put(currentTask.whatId,currentTask.CallDisposition);
                            //if(currentTask.CallDisposition.contains('Left VM'))
                            currentTask.ActivityDate = DateUtilities.addBusinessDays(Date.today(), mapAddDays.get(currentTask.CallDisposition));
                        }
                    }
                }
                Debug.log('mapTaskCallResult::'+mapTaskCallResult);
                if(mapTaskCallResult !=null && mapTaskCallResult.size()>0)
                {
                    list<Journey__c> lstJourney = [Select Id, Name, Primary_Contact__c, NMD_Next_Contact_Date__c from Journey__c where Id IN:mapTaskCallResult.keySet()];
                    
                    for(Journey__c currentJourney: lstJourney)
                    {
                        mapJourneyContactIds.put(currentJourney.Id,currentJourney.Primary_Contact__c);
                        
                        if(mapAddDays != null && mapAddDays.containsKey(mapTaskCallResult.get(currentJourney.Id)))
                        {
                            currentJourney.NMD_Next_Contact_Date__c = DateUtilities.addBusinessDays(Date.today(), mapAddDays.get(mapTaskCallResult.get(currentJourney.Id)));
                        }
                    }
                    
                    
                    //Set WhoId for task
                    if(mapJourneyContactIds !=null && mapJourneyContactIds.size()>0)
                    {
                        for(Task currentTask : lstTask)
                        {
                            currentTask.whoId = mapJourneyContactIds.get(currentTask.whatId);
                        }
                        
                    }
                    
                    Debug.log('lstJourney::'+lstJourney);
                    if(lstJourney != null && lstJourney.size() >0)
                    {
                        update lstJourney;  
                    }
                }
                //Issue: ST-298
                for(Task currentTask : lstTask)
                {
                    system.debug(loggingLevel.ERROR,'Status*********************'+currentTask.Status);
                    if(currentTask.whatId != null && currentTask.whatId.getSObjectType() == sObjectTypeJourney)
                    {
                        if(currentTask.status != 'Completed')
                        {
                            setTaskWhatId.add(currentTask.whatId);
                            lstOpenTask.add(currentTask);
                            
                            if(currentTask.status == 'Not Started')
                                setTaskJournyWhatIds.add(currentTask.whatId);
                        }
                    }
                }
                
                if(setTaskJournyWhatIds !=null && setTaskJournyWhatIds.size()> 0)
                {
                    list<Task> lstTaskToBeCompleted = [Select status , ActivityDate,Subject from Task Where WhatId IN:setTaskJournyWhatIds and ActivityDate <: Date.today() and status !=: 'Completed'];
                    
                    if(lstTaskToBeCompleted != null && lstTaskToBeCompleted.size()>0)
                    {
                        for(Task currentTask : lstTaskToBeCompleted)
                        {
                            system.debug(loggingLevel.ERROR,'CURRENT TASK+++++++++++++++++++++'+currentTask);
                            if(currentTask.subject != null && currentTask.subject.contains('Follow-Up'))
                            {
                                
                                currentTask.status = 'Completed'; 
                            }
                        }
                        update lstTaskToBeCompleted;
                    }
                }
                AvoidRecurssion.isUpdateJourneyNMDNextContactDate = true;
            }
            catch(Exception ex)
            {
                system.debug(logginglevel.ERROR,'Exception:'+ex.getMessage());
            }
        }      		
    }
    

	/*************************************************************************************************
       Author 				: Mayuresh Ghodke 
       Description 			: this methos to used to update active referrer
       Created Date 		: 1 Aug, 2016
       Issue No. 			: ST-585
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
****************************************************************************************************/
    /*public static void updateActiveReferrer(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems)
    {
        if(TriggerSettings.mappedField.Task_UpdateActiveReferrer)
        {
            set<String> emails = new set<String>();
            set<Id> leadIds = new set<Id>();
            set<Id> contactIds = new set<Id>();
            
            for(Task taskRec : (List<Task>)listNewItems)
            {       
                if(taskRec.WhoId != null && String.valueOf(taskRec.WhoId).startsWith('00Q'))
                    leadIds.add(taskRec.WhoId);
                else if(taskRec.WhoId != null && String.valueOf(taskRec.WhoId).startsWith('003'))
                    contactIds.add(taskRec.WhoId);
            }
            Map<Id, Contact> mapContact = new Map<Id, Contact>();
            Map<Id, Lead> mapLead = new Map<Id, Lead>();
            if(contactIds.size() > 0)
            {
                mapContact = new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Id in:contactIds]);
                for(Contact con : mapContact.values())
                {
                    if(con.Email != null)
                        emails.add(con.Email.toLowerCase());
                }
            }
            if(leadIds.size() > 0)
            {
                mapLead = new Map<Id, Lead>([SELECT Id, Email FROM Lead WHERE Id in:leadIds]);
                for(Lead lead : mapLead.values())
                {
                    if(lead.Email != null)
                        emails.add(lead.Email.toLowerCase());
                }
            }
            if(emails.size() > 0)
            {
                Map<String, Id> mapActiveReferences = ReferenceHandler.getActiveReference(emails);
                for(Task taskRec : (List<Task>)listNewItems)
                {
                    if(taskRec.WhoId != null && String.valueOf(taskRec.WhoId).startsWith('00Q') && mapLead.get(taskRec.WhoId) != null)
                    {
                        if(mapLead.get(taskRec.WhoId).Email.toLowerCase() != null)
                            taskRec.Referrer__c = mapActiveReferences.get(mapLead.get(taskRec.WhoId).Email.toLowerCase());
                    }
                    if(taskRec.WhoId != null && String.valueOf(taskRec.WhoId).startsWith('003') && mapContact.get(taskRec.WhoId) != null)
                    {
                        if(mapContact.get(taskRec.WhoId).Email.toLowerCase() != null)
                            taskRec.Referrer__c = mapActiveReferences.get(mapContact.get(taskRec.WhoId).Email.toLowerCase());
                    }
                }
            }
        }
    }
    
    public class NMDNextDateClass
    {
        public String CallResult{get;set;}
        public Integer NextDate{get;set;}  
    } 
    

	/*************************************************************************************************
       Author 				: Dipak Pawar
       Description 			: This method is for update Outreach Stage of all Journeys of related Task.
       Created Date			: 26 Aug, 2016 
       Issue No. 			: ST-639
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
****************************************************************************************************/
   /* public static void updateOutreachStageOnJourney(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems) 
    {    
        if(TriggerSettings.mappedField.Task_UpdateOutreachStageOnJourney)
        {
            Set<Id> setTaskRelatedJourneys = new Set<Id>();
            Set<Id> setRelatedPrimaryContacts = new Set<Id>();
            Set<Id> setRelatedPrimaryLeads = new Set<Id>();
            String taskSubject = 'FastCall Outbound Call';
            String journeyPrefix = Journey__c.SObjectType.getDescribe().getKeyPrefix();
            Map<Id, Journey__c> mapJourneysToBeProcessed = new Map<Id, Journey__c>();
            List<Task> lstTasksToBeProcessed = new List<Task>();
            
            if(Trigger.isInsert){
                if(listNewItems != null)
                {
                    for(Task currentTask : (List<Task>)listNewItems) {
                        if(String.isEmpty(currentTask.Subject)){
                            currentTask.Subject = taskSubject;
                        }
                        if(currentTask.WhatId != null && currentTask.Subject!=null && (currentTask.Subject).equalsIgnoreCase(taskSubject) && String.valueOf(currentTask.WhatId).startsWith(journeyPrefix)) {
                            setTaskRelatedJourneys.add(currentTask.WhatId);             
                        }
                    }
                }
            } else if(Trigger.isUpdate) {
                if(listNewItems != null)
                {
                    for(Task currentTask : (List<Task>)listNewItems) {
                        Task oldTask = (Task)mapOldItems.get(currentTask.Id);
                        if(String.isEmpty(currentTask.Subject)){
                            currentTask.Subject = taskSubject;
                        }
                        if(currentTask.WhatId != null && currentTask.Subject!=null && (currentTask.Subject).equalsIgnoreCase(taskSubject) && oldTask.Subject == 'fc_EmptySubject' && String.valueOf(currentTask.WhatId).startsWith(journeyPrefix)){
                            setTaskRelatedJourneys.add(currentTask.WhatId);  
                        }   
                    }
                }
            }
            
            if(!setTaskRelatedJourneys.isEmpty()){
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
                            List<Journey__c> lstContactJourneys = new List<Journey__c>();
                            if(mapJourneys.get(journey.Primary_Contact__c) == null) {                    
                                lstContactJourneys.add(journey);
                                mapJourneys.put(journey.Primary_Contact__c, lstContactJourneys);
                            }
                            else {
                                lstContactJourneys = mapJourneys.get(journey.Primary_Contact__c);
                                lstContactJourneys.add(journey);
                                mapJourneys.put(journey.Primary_Contact__c, lstContactJourneys);    
                            }
                        }
                        if(journey.Primary_Lead__c != null && journey.Status__c == 'Started') {
                            List<Journey__c> lstLeadJourneys = new List<Journey__c>();
                            if(mapJourneys.get(journey.Primary_Lead__c) == null) {                    
                                lstLeadJourneys.add(journey);
                                mapJourneys.put(journey.Primary_Lead__c, lstLeadJourneys);
                            }
                            else {
                                lstLeadJourneys = mapJourneys.get(journey.Primary_Lead__c);
                                lstLeadJourneys.add(journey);
                                mapJourneys.put(journey.Primary_Lead__c, lstLeadJourneys);    
                            }
                        }
                    }
                    
                    if(setTaskRelatedJourneys.size() > 0 && mapJourneys.size() > 0) {
                        for(Task currentTask : (List<Task>)listNewItems) {  
                            if(String.isEmpty(currentTask.Subject)){
                                currentTask.Subject = taskSubject;
                            }
                            if(currentTask.Subject!=null && currentTask.Subject.equalsIgnoreCase(taskSubject)  && (mapRelatedJourneys.get(currentTask.WhatId).Outreach_Stage__c == 'Call 1' || (mapRelatedJourneys.get(currentTask.WhatId).Outreach_Stage__c == '') || (mapRelatedJourneys.get(currentTask.WhatId).Outreach_Stage__c == null)) && mapRelatedJourneys.get(currentTask.WhatId).Status__c == 'Started' ){
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
                                        }
                                        else if((journey.Outreach_Stage__c == '' || journey.Outreach_Stage__c == null) && mapRelatedJourneys.get(currentTask.WhatId).Outreach_Stage__c == journey.Outreach_Stage__c) {
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
                if(mapJourneysToBeProcessed.size() > 0)
                    update mapJourneysToBeProcessed.values();
                if(lstTasksToBeProcessed.size() > 0)
                    insert lstTasksToBeProcessed; 
            }
        }    
    }

	/*************************************************************************************************
       Author 				: Amol Darekar 
       Description 			: This method is for update Journey lookup on tour when ever tout is booked and activity is logged with subject ''Book a Tour''       Last Modified Date	:	1 Feb, 2018
       Created Date			: 26 Aug, 2016 
	   Issue No. 			: ST-602
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
****************************************************************************************************/
   /* public static void updateJourneyOnTour(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems)
    {
        if(TriggerSettings.mappedField.Task_updateJourneyOnTour)
        {
            Debug.log('Task Trigger::');
            Debug.log('In task triggers updateJourneyOnTour::');
            Schema.sObjectType sObjectTypeTour = Schema.Tour_Outcome__c.getSObjectType();
            
            list<Task> lstTask = listNewItems;
            map<Id,Task> mapTourIds = new map<Id,Task>();
            map<Id,Task> mapTaskTourWhatIds = new map<Id,Task>();
            list<Tour_Outcome__c> lstToursToUpdate = new list<Tour_Outcome__c>();
            Debug.log('lstTask::'+lstTask);
            for(Task currentTask : lstTask)
            {
                if(currentTask.subject == 'Book a Tour' && currentTask.whatId != null && currentTask.whatId.getSObjectType() == sObjectTypeTour)
                {
                    mapTourIds.put(currentTask.Id,currentTask);
                    mapTaskTourWhatIds.put(currentTask.whatId,currentTask);
                }
                
            }
            
            Debug.log('mapTourIds::'+mapTourIds);
            
            if(mapTourIds != null && mapTourIds.size() > 0)
            {
                list<Tour_Outcome__c> lstTour = [SELECT Id,Primary_Member__c,Location__c,Journey__c from Tour_Outcome__c WHERE Id IN : mapTaskTourWhatIds.keySet()];
                
                Debug.log('lstTour::'+lstTour);
                
                map<Id,Id> mapTourJourneyPrimeryMembers = new map<Id,Id>();
                
                map<Id,list<Tour_Outcome__c>> mapPrimaryMemberAndTours = new map<Id,list<Tour_Outcome__c>>();
                
                map<Id,Id> mapQuickQuote = new map<Id,Id>();
                
                map<Id,Id> mapBuildingInterested = new map<Id,Id>();
                
                for(Tour_Outcome__c currentTourOutcome : lstTour)
                {
                    if(currentTourOutcome.Primary_Member__c != null)
                    {
                        mapTourJourneyPrimeryMembers.put(currentTourOutcome.Primary_Member__c,null);
                        
                        //More than one tours can be associated with one primary member
                        if(mapPrimaryMemberAndTours.containsKey(currentTourOutcome.Primary_Member__c))
                        {
                            mapPrimaryMemberAndTours.get(currentTourOutcome.Primary_Member__c).add(currentTourOutcome);
                        }
                        else
                        {
                            mapPrimaryMemberAndTours.put(currentTourOutcome.Primary_Member__c,new list<Tour_Outcome__c>{currentTourOutcome});
                        }
                    }
                    
                }
                
                Debug.log('mapTourJourneyPrimeryMembers::'+mapTourJourneyPrimeryMembers);
                
                //If there are more than one open journeys for same primary member the select the latest modified journeys
                
                List<Journey__c> lstJourneys = new List<Journey__c>();
                if(mapTourJourneyPrimeryMembers.size() > 0){    
                    lstJourneys = [SELECT Id, Name, LastModifiedDate, Status__c, Primary_Contact__c, Building_Interested_In__c,Quick_Quote_Location__c From Journey__C WHERE Primary_Contact__c IN : mapTourJourneyPrimeryMembers.keySet() ORDER BY LastModifiedDate DESC];
                    
                    Debug.log('lstJourneys::'+lstJourneys);
                    for(Journey__c currentJourney : lstJourneys)
                    {
                        Debug.log('mapPrimaryMemberAndTours::'+mapPrimaryMemberAndTours);
                        
                        if(currentJourney.Status__c == 'Started' && mapPrimaryMemberAndTours.containsKey(currentJourney.Primary_Contact__c))
                        {
                            
                            list<Tour_Outcome__c> lstTourOutcome = mapPrimaryMemberAndTours.get(currentJourney.Primary_Contact__c);
                            
                            Debug.log('lstTourOutcome::'+lstTourOutcome);
                            
                            for(Tour_Outcome__c currentTourOutcome: lstTourOutcome)
                            {
                                //If building interested match then set tours Journey field currentJourneyId
                                if(currentJourney.Building_Interested_In__c != null && currentJourney.Building_Interested_In__c == currentTourOutcome.Location__c && !mapBuildingInterested.containsKey(currentTourOutcome.Id))//buildingInterestedFlag
                                {
                                    currentTourOutcome.Journey__c = currentJourney.Id;
                                    mapBuildingInterested.put(currentTourOutcome.Id,currentJourney.Id);
                                }
                                else if(mapTaskTourWhatIds.containsKey(currentTourOutcome.Id) && mapTaskTourWhatIds.get(currentTourOutcome.Id).Quick_Quote_Location__c != null 
                                        && mapTaskTourWhatIds.get(currentTourOutcome.Id).Quick_Quote_Location__c == currentJourney.Quick_Quote_Location__c
                                        && !mapBuildingInterested.containsKey(currentTourOutcome.Id)
                                        && !mapQuickQuote.containsKey(currentTourOutcome.Id))//&& buildingInterestedFlag && quickQuoteFlag
                                {
                                    //Compaire task Quick_Quote_location with journey Quick_Quote_location
                                    mapQuickQuote.put(currentTourOutcome.Id,currentJourney.Id);
                                    currentTourOutcome.Journey__c = currentJourney.Id;
                                }
                                else if(currentTourOutcome.Journey__c == null && !mapBuildingInterested.containsKey(currentTourOutcome.Id) && !mapQuickQuote.containsKey(currentTourOutcome.Id))
                                { 
                                    currentTourOutcome.Journey__c = currentJourney.Id;
                                }  
                            }
                            
                            mapPrimaryMemberAndTours.put(currentJourney.Primary_Contact__c,lstTourOutcome);
                        }
                        
                    }
                }
                for(Id currentMemberId :mapPrimaryMemberAndTours.keySet())
                {
                    list<Tour_Outcome__c> lstCurrentTourOutcome = mapPrimaryMemberAndTours.get(currentMemberId);
                    if(lstCurrentTourOutcome != null && lstCurrentTourOutcome.size() > 0)
                    {
                        lstToursToUpdate.addAll(lstCurrentTourOutcome);
                    }
                }
                Debug.log('Tours to update::'+lstToursToUpdate);
                update lstToursToUpdate;
            }// If(mapTourIds) End
        }
    }

	/*************************************************************************************************
       Author 				: Dipak Pawar
       Description 			: This method is for update Contact on task when task create/update with Spacestation Contact UUID we need to display the Contact Name from Salesforce on Task. 
       Created Date			: 19 Dec, 2016 
	   Issue No. 			: ST-791
	   Last Modified By 	: Prashant Mane
	   Last Modified Date   : 02 Feb,2018
****************************************************************************************************/
  /*  public static void updateContactOnTask(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems) 
    {
        if(TriggerSettings.mappedField.Task_updateContactOnTask)
        {
            Set<Id> setTaskIds = new Set<Id>();
            Map<Id, Task> mapTasksToUpdate = new Map<Id, Task>();
            Set<String> setContactUUIds = new Set<String>();
            Map<Id, Task> mapTriggerNewMap;
            Map<Id, Task> mapTriggerOldMap = (Map<Id, Task>)mapOldItems;
            Map<String, Contact> mapRelatedContacts = new Map<String, Contact>();
            if(listNewItems != null)
            {
                for(Task task : (List<Task>)listNewItems){
                    setTaskIds.add(task.Id);
                }
            }
            if(!setTaskIds.isEmpty()){
                mapTriggerNewMap = new Map<Id, Task>([SELECT Id, Subject, Saleslady_Contact_UUID__c, Salesforce_Contact__c FROM Task WHERE Id IN :setTaskIds]);    
            }
            Debug.Log('mapTriggerNewMap :: '+mapTriggerNewMap);
            if(!mapTriggerNewMap.isEmpty()){
                for(Task task : mapTriggerNewMap.values()){
                    if(Trigger.IsInsert && task.Saleslady_Contact_UUID__c != null) {
                        setContactUUIds.add(task.Saleslady_Contact_UUID__c);
                    }
                    else if(Trigger.IsUpdate && task.Saleslady_Contact_UUID__c != null && task.Saleslady_Contact_UUID__c != mapTriggerOldMap.get(task.Id).Saleslady_Contact_UUID__c) {
                        setContactUUIds.add(task.Saleslady_Contact_UUID__c);
                    }
                }
                if(!setContactUUIds.isEmpty()){
                    for(Contact con : [SELECT Id, Name, Email, UUID__c FROM Contact WHERE UUID__c IN : setContactUUIds]){
                        mapRelatedContacts.put(con.UUID__c, con);
                    }
                }
                Debug.Log('mapRelatedContacts :: '+mapRelatedContacts);
                
                for(Task currentTask : mapTriggerNewMap.values()){
                    if(Trigger.IsInsert) {
                        if(!mapRelatedContacts.isEmpty() && mapRelatedContacts.get(currentTask.Saleslady_Contact_UUID__c) != null){
                            Debug.Log('I : '+(mapRelatedContacts.get(currentTask.Saleslady_Contact_UUID__c).Id));
                            currentTask.Salesforce_Contact__c = mapRelatedContacts.get(currentTask.Saleslady_Contact_UUID__c).Id + ' ' + mapRelatedContacts.get(currentTask.Saleslady_Contact_UUID__c).Name;
                        } else {
                            currentTask.Salesforce_Contact__c = '';
                        }
                        mapTasksToUpdate.put(currentTask.Id, currentTask);                       
                    }
                    else if(Trigger.IsUpdate){
                        if(currentTask.Saleslady_Contact_UUID__c != null && currentTask.Saleslady_Contact_UUID__c != mapTriggerOldMap.get(currentTask.Id).Saleslady_Contact_UUID__c) {
                            if(!mapRelatedContacts.isEmpty() &&  mapRelatedContacts.get(currentTask.Saleslady_Contact_UUID__c) != null){
                                Debug.Log('U : '+(mapRelatedContacts.get(currentTask.Saleslady_Contact_UUID__c).Id));
                                currentTask.Salesforce_Contact__c = mapRelatedContacts.get(currentTask.Saleslady_Contact_UUID__c).Id + ' ' + mapRelatedContacts.get(currentTask.Saleslady_Contact_UUID__c).Name;
                            } else {
                                currentTask.Salesforce_Contact__c = '';
                            }
                            mapTasksToUpdate.put(currentTask.Id, currentTask);                       
                        } else if((currentTask.Saleslady_Contact_UUID__c == '' || currentTask.Saleslady_Contact_UUID__c == null) && currentTask.Saleslady_Contact_UUID__c != mapTriggerOldMap.get(currentTask.Id).Saleslady_Contact_UUID__c) {
                            currentTask.Salesforce_Contact__c = '';
                            mapTasksToUpdate.put(currentTask.Id, currentTask);
                        }                       
                    }                    
                }       
                Debug.Log('mapTasksToUpdate :: '+mapTasksToUpdate);
                if(!mapTasksToUpdate.isEmpty()){
                    update mapTasksToUpdate.values();
                }
            }
        }
    }*/
}