/************************************************************************************************************************************
    Author      : Anant Kumar
    Description : This class contains Logic of TourTriggerHandler

    History     :
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION     DATE                AUTHOR          DETAIL
    1           23 February 2016    Anant Kumar     Initial Developement
**************************************************************************************************************************************/

public class TourTriggerHandler extends ITriggerHandler {
    public static Boolean bOnceExTrigger = false;
    public static Boolean flag = true;
    
    public TourTriggerHandler(){
        super('Tour_Outcome__c');
    }
    
    /************************************************************************************************************************************
         Author             : Pragalbha Mahajan
         Description        : This method overrides before insert method from ITriggerHander which will control the execution flow.
         Last Modified Date : 02 February 2018
         Last Modified By   : Pragalbha Mahajan (added Comment)
    **************************************************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){
        Debug.log('BeforeInsert start=='+Limits.getQueries());
        if(TriggerSettings.mappedField.Tour_setTourCanceledDate){
            setTourCanceledDate((List<Tour_Outcome__c>)listNewItems, null, null, null);
        }
             
        if(TriggerSettings.mappedField.Tour_setTourCompletedDate){
            setTourCompletedDate((List<Tour_Outcome__c>)listNewItems, null, null, null);
        }
             
        if(TriggerSettings.mappedField.Tour_setTourScheduledWithEmail){
            setTourScheduledWithEmail((List<Tour_Outcome__c>)listNewItems, null, null, null);
        }
            
        if(TriggerSettings.mappedField.Tour_setLocationEmail){
            setLocationEmail((List<Tour_Outcome__c>)listNewItems, null, null, null);
        }
            
        if(TriggerSettings.mappedField.Tour_setTourDate){
            setTourDate((List<Tour_Outcome__c>)listNewItems, null, null, null);
        }
            
        if(TriggerSettings.mappedField.Tour_CloseAllOpenInboundLeadActivities){
            closeAllOpenInboundLead((List<Tour_Outcome__c>)listNewItems, null, null, null);
        }
            
        if(TriggerSettings.mappedField.Tour_UpdateTourEnditme){
            updateTourEndTime((List<Tour_Outcome__c>)listNewItems, null, null, null);
        }
            
        if(TriggerSettings.mappedField.Tour_UpdateActiveReferrerOnTour){
            updateActiveReferrerOnTour((List<Tour_Outcome__c>)listNewItems, null, null, null);
        }
            
        Debug.log('BeforeInsert end=='+Limits.getQueries());
    }
    
    /************************************************************************************************************************************
         Author             : Pragalbha Mahajan
         Description        : This method overrides after insert method from ITriggerHander which will control the execution flow.
         Last Modified Date : 02 February 2018
         Last Modified By   : Pragalbha Mahajan (added Comment)
    **************************************************************************************************************************************/
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){
        Debug.log('AfterInsert start=='+Limits.getQueries());
        
        if(TriggerSettings.mappedField.Tour_StageUpdateforJourneyRecords){
            updateJourneyStage((List<Tour_Outcome__c>) listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, null, null);  
        }
        
        if(TriggerSettings.mappedField.Tour_ExtendValidityOfReference){
            extendValidityOfReference((List<Tour_Outcome__c>) listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, null, null);
        }  
        
        if(Test.isRunningTest()|| System.isBatch()){
            if(TriggerSettings.mappedField.Tour_countTour){
                countTour(JSON.serialize((List<Tour_Outcome__c>)listNewItems));
            }
        } else if(TriggerSettings.mappedField.Tour_countTour){
            callCountTour(JSON.serialize((List<Tour_Outcome__c>)listNewItems)); 
        }        
       
        /************************************************************************************************************************************
            Author              : Samadhan Kadam
            Description         : Send email to Opportunity owner when tour is created and completed.
            Last Modified Date  : 08 April 2017
            Last Modified By    : Samadhan Kadam
            Issue No            : ST-1006
        ********************************************************************************************************************************/  
        /*if(TriggerSettings.mappedField.Tour_EmailAlertToOpportunityOwner){
            Debug.log('Tour_EmailAlertToOpportunityOwner Insert AvoidRecurssion.firstRun---'+AvoidRecurssion.firstRun);
            if(AvoidRecurssion.firstRun){ 
                AvoidRecurssion.firstRun = false;
                QueueEmailAlertForOpportunity emailAlertJob = new QueueEmailAlertForOpportunity((List<Tour_Outcome__c>) listNewItems);
                ID jobID = System.enqueueJob(emailAlertJob);
                Debug.log('QueueEmailAlertForOpportunity Insert jobID---'+jobID);
            }            
        }                
        Debug.log('AfterInsert end=='+Limits.getQueries());*/
    }
    
    /************************************************************************************************************************************
         Author             : Pragalbha Mahajan
         Description        : This method overrides before update method from ITriggerHander which will control the execution flow.
         Last Modified Date : 02 February 2018
         Last Modified By   : Pragalbha Mahajan (added Comment)
    **************************************************************************************************************************************/
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        Debug.log('Tour_Completed_By_SFID__c =====>'+Trigger.New);  
        if(TriggerSettings.mappedField.Tour_setTourCanceledDate){
            setTourCanceledDate((List<Tour_Outcome__c>)listNewItems, null, null, null);
        }
             
        if(TriggerSettings.mappedField.Tour_setTourCompletedDate){
            setTourCompletedDate((List<Tour_Outcome__c>)listNewItems, null, null, null);
        }
             
        if(TriggerSettings.mappedField.Tour_setTourScheduledWithEmail){
            setTourScheduledWithEmail((List<Tour_Outcome__c>)listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, null, null);
        }
            
        if(TriggerSettings.mappedField.Tour_setLocationEmail){
            setLocationEmail((List<Tour_Outcome__c>) listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, (List<Tour_Outcome__c>) listOldItems, (Map<Id, Tour_Outcome__c>) mapOldItems);
        }
            
        if(TriggerSettings.mappedField.Tour_setTourDate){
            setTourDate((List<Tour_Outcome__c>)listNewItems, null, null, null);
        }
        
        if(TriggerSettings.mappedField.Tour_UpdateOwnerForAssignedHost){
            updateTourOwnerForAssignedHost((List<Tour_Outcome__c>) listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, (List<Tour_Outcome__c>) listOldItems, (Map<Id, Tour_Outcome__c>) mapOldItems);
        }
        
        if(TriggerSettings.mappedField.Tour_UpdateOwnerForCompletedBy){
            WithoutSharingUtilityController.updateTourCompletedBy((List<Tour_Outcome__c>)listNewItems, (Map<Id, Tour_Outcome__c>)mapOldItems);
        }
        
        if(TriggerSettings.mappedField.Tour_CleanTourOutcomeData){
            cleanTourOutcomeData((List<Tour_Outcome__c>) listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, (List<Tour_Outcome__c>) listOldItems, (Map<Id, Tour_Outcome__c>) mapOldItems);
        }
        
        if(TriggerSettings.mappedField.Tour_CreateORUpdateTourOutcome){
            createORUpdateTourOutcome((List<Tour_Outcome__c>) listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, (List<Tour_Outcome__c>) listOldItems, (Map<Id, Tour_Outcome__c>) mapOldItems);
        }
        
        if(TriggerSettings.mappedField.Tour_CloseAllOpenInboundLeadActivities){
            closeAllOpenInboundLead((List<Tour_Outcome__c>) listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, (List<Tour_Outcome__c>) listOldItems, (Map<Id, Tour_Outcome__c>) mapOldItems);          
        }
        
        if(TriggerSettings.mappedField.Tour_UpdateTourEnditme){
            updateTourEndTime((List<Tour_Outcome__c>) listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, (List<Tour_Outcome__c>) listOldItems, (Map<Id, Tour_Outcome__c>) mapOldItems);
        }
        
        if(TriggerSettings.mappedField.Tour_UpdateActiveReferrerOnTour){
            updateActiveReferrerOnTour((List<Tour_Outcome__c>) listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, (List<Tour_Outcome__c>) listOldItems, (Map<Id, Tour_Outcome__c>) mapOldItems);
        }
        
        Debug.log('BeforeUpdate end=='+Limits.getQueries());        
    }
    
    /************************************************************************************************************************************
         Author             : Pragalbha Mahajan
         Description        : This method overrides after update method from ITriggerHander which will control the execution flow.
         Last Modified Date : 02 February 2018
         Last Modified By   : Pragalbha Mahajan (added Comment)
    **************************************************************************************************************************************/
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        Debug.log('AfterUpdate start=='+Limits.getQueries());
        if(TriggerSettings.mappedField.Tour_StageUpdateforJourneyRecords){
            updateJourneyStage((List<Tour_Outcome__c>) listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, (List<Tour_Outcome__c>) listOldItems, (Map<Id, Tour_Outcome__c>) mapOldItems);
        }
        
        if(TriggerSettings.mappedField.Tour_ExtendValidityOfReference){
            extendValidityOfReference((List<Tour_Outcome__c>) listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, (List<Tour_Outcome__c>) listOldItems, (Map<Id, Tour_Outcome__c>) mapOldItems);
        }
        
        if(TriggerSettings.mappedField.Tour_countTour){
            if(Test.isRunningTest()|| System.isBatch()){            
                countTour(JSON.serialize((List<Tour_Outcome__c>) listNewItems));
            } else {
                callCountTour(JSON.serialize((List<Tour_Outcome__c>) listNewItems));
            }
        }
        
        /************************************************************************************************************************************
            Author              : Samadhan Kadam
            Description         : Send email to Opportunity owner when tour is created and completed.
            Last Modified Date  : 08 April 2017
            Last Modified By    : Samadhan Kadam
            Issue No            : ST-1006
        ********************************************************************************************************************************/          
        if(TriggerSettings.mappedField.Tour_EmailAlertToOpportunityOwner){
            Debug.log('Tour_EmailAlertToOpportunityOwner After AvoidRecurssion.firstRun---'+AvoidRecurssion.firstRun);
            if(AvoidRecurssion.firstRun){
                AvoidRecurssion.firstRun = false;
                QueueEmailAlertForOpportunity emailAlertJob = new QueueEmailAlertForOpportunity((List<Tour_Outcome__c>)listNewItems,(Map<Id, Tour_Outcome__c>) mapOldItems);
                ID jobID = System.enqueueJob(emailAlertJob);
                Debug.log('QueueEmailAlertForOpportunity Update jobID---'+jobID);
            }           
        }
        
        if(TriggerSettings.mappedField.Tour_tourCreateTaskForEmailReminderSent){
            tourCreateTaskForEmailReminderSent((List<Tour_Outcome__c>) listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, (List<Tour_Outcome__c>) listOldItems, (Map<Id, Tour_Outcome__c>) mapOldItems);
        }
        
        if(TriggerSettings.mappedField.Tour_updateOpportunityStage){
            updateOpportunityStage((List<Tour_Outcome__c>) listNewItems, (Map<Id, Tour_Outcome__c>) mapNewItems, (List<Tour_Outcome__c>) listOldItems, (Map<Id, Tour_Outcome__c>) mapOldItems);
        }
        
        Debug.log('AfterUpdate end=='+Limits.getQueries());
    }  
    
    public class TourAssignedHostSettings {
        public List<string> AllowedProfiles {get;set;}
    }
    
    static Map<Id, Opportunity> mapOpportunities;
    /************************************************************************************************************************************
        Author              : Anant
        Description         : This method is used to update Tour Owner For Assigned Host
        Last Modified Date  : 30 March 2017
        Last Modified By    : Dipak Pawar 
        Issue No            : ST-1020

    ********************************************************************************************************************************/    
    public static void updateTourOwnerForAssignedHost(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewTours, List<Tour_Outcome__c> lstOldTours, Map<Id, Tour_Outcome__c> mapOldTours){
        Set<Id> assignedHostContactIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        for(Tour_Outcome__c tour: lstNewTours){
            if(mapOldTours.get(tour.Id).Assigned_Host__c != tour.Assigned_host__c){
                assignedHostContactIds.add(tour.Assigned_host__c);
                if(tour.Opportunity__c != null){
                    opportunityIds.add(tour.Opportunity__c);
                }
            }
        }
        Debug.log('updateTourOwnerForAssignedHost assignedHostContactIds---'+assignedHostContactIds);
        if(assignedHostContactIds.size() > 0){
            Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Id IN:assignedHostContactIds]);
            Set<String> setOpportunityStages = new Set<String>{'closed won', 'closed lost'};
            if(opportunityIds.size() > 0){                
                mapOpportunities = new Map<Id, Opportunity>([SELECT Id, RecordTypeId, OwnerId, StageName FROM Opportunity WHERE Id IN :opportunityIds AND StageName NOT IN : setOpportunityStages]);
            }
            Setting__c tourAssignedHostSettingsObj = Settings.get('TourAssignedHost Settings');
            if(tourAssignedHostSettingsObj!=null){
                Set<String> setAllowedProfiles = new Set<String>();
                TourTriggerHandler.TourAssignedHostSettings tourAssignedHostSettings = (TourTriggerHandler.TourAssignedHostSettings)System.JSON.deserialize(tourAssignedHostSettingsObj.Data__c, TourTriggerHandler.TourAssignedHostSettings.class);
                if(tourAssignedHostSettings!=null && tourAssignedHostSettings.AllowedProfiles!=null && tourAssignedHostSettings.AllowedProfiles.size() > 0){
                    for(String profileName : tourAssignedHostSettings.AllowedProfiles){
                        setAllowedProfiles.add(profileName.trim().toLowerCase());
                    }
                }                
                
                if(setAllowedProfiles.size() > 0){                    
                    Boolean oppCondtion = (setOpportunityStages != null && setOpportunityStages.size() > 0 && mapOpportunities != null  && mapOpportunities.size() > 0);
                    List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
                    Id consumerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
                    for(Tour_Outcome__c tour: lstNewTours){
                        if(tour.Assigned_host__c != null && mapContacts.containsKey(tour.Assigned_host__c) && Settings.getUserByEmail(mapContacts.get(tour.Assigned_host__c).Email) != null && setAllowedProfiles.contains(String.valueOf(Settings.getUserByEmail(mapContacts.get(tour.Assigned_host__c).Email).Profile.Name).toLowerCase())){
                            tour.OwnerId = Settings.getUserByEmail(mapContacts.get(tour.Assigned_host__c).Email).Id;
                            if(oppCondtion && mapOpportunities.get(tour.Opportunity__c) != null && mapOpportunities.get(tour.Opportunity__c).RecordTypeId == consumerRecordTypeId){
                                Opportunity oppRec = mapOpportunities.get(tour.Opportunity__c);                                
                                if(oppRec.OwnerId != Settings.getUserByEmail(mapContacts.get(tour.Assigned_host__c).Email).Id && oppRec.StageName != null && !setOpportunityStages.contains(oppRec.StageName)){
                                    oppRec.OwnerId = Settings.getUserByEmail(mapContacts.get(tour.Assigned_host__c).Email).Id;
                                    lstOpportunityToUpdate.add(oppRec);
                                }
                            }
                        }
                    }
                    if(lstOpportunityToUpdate.size() > 0){                                   
                        update lstOpportunityToUpdate;
                    }                               
                }
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              : Pranay Jadhav 
        Description         : Tour_Outcome__c: Stage Update for Journey Records
        Last Modified Date  : 28 June 2016
        Last Modified By    : Pranay Jadhav
        Issue No            : ST-444
    ********************************************************************************************************************************/     
    public static void updateJourneyStage(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewTours, List<Tour_Outcome__c> lstOldTours, Map<Id, Tour_Outcome__c> mapOldTours){
        Set<Id> setJourneyIds = new Set<Id>();
        for(Tour_Outcome__c tour : lstNewTours){
            if(tour.Journey__c != null ){
                setJourneyIds.add(tour.Journey__c);
            }
        }            
        if(setJourneyIds.size() > 0){
            Setting__c objJourneyCompletedStatus = Settings.get('JourneyCloseStages');
            Set<String> setOfStatus = (Set<String>)JSON.deserialize(objJourneyCompletedStatus.data__c, Set<String>.class);
            List<Journey__c> listJourneys = [SELECT Id, Name, Status__c, (SELECT Id,Name,Status__c FROM Tours__r) FROM Journey__c WHERE Id IN :setJourneyIds AND Status__c NOT IN :setOfStatus];
            List<Journey__c> lstUpdateJourneys = new List<Journey__c>();
            for (Journey__c journey : listJourneys) {
                if(Journey.Tours__r.size() > 0){
                    for(Tour_Outcome__c Tour : journey.Tours__r) {
                        if(Tour.Status__c != 'Completed'){
                            journey.Status__c = 'Completed';
                            lstUpdateJourneys.add(journey);
                            break;
                        }
                    }
                }
            }            
            if(lstUpdateJourneys != null && lstUpdateJourneys.size()> 0){               
                update lstUpdateJourneys;
            }
        }           
    }
    
    /************************************************************************************************************************************
        Author              : Anant Kumar   
        Description         : Close all open InboundLead Leads activities
        Last Modified Date  : 15 June 2015
        Last Modified By    : Anant Kumar
        Issue No            : ST-372
    ********************************************************************************************************************************/ 
    public static void closeAllOpenInboundLead(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewTours, List<Tour_Outcome__c> lstOldTours, Map<Id, Tour_Outcome__c> mapOldTours){
        Setting__c objectData = Settings.get('CloseOpenActivities');
        Debug.Log( 'Subjects To Close : Settings : ' + objectData);
        if(objectData != null){
            Map<String, Object> mapData = (Map<String,Object>)JSON.deserializeUntyped(objectData.Data__c);
            Set<String> setTaskSubjects = new Set<String>();
            if(mapData.get('subject')!= null && String.valueOf(mapData.get('subject')).split(',').size() > 0){
                setTaskSubjects.addAll(String.valueOf(mapData.get('subject')).toLowerCase().split(','));
            }
            if(setTaskSubjects.size() > 0){
                Debug.log('Subjects To Close : ' + setTaskSubjects);                
                Set<Id> setContactIds = new Set<Id>();
                for(Tour_Outcome__c tour : lstNewTours){
                    if((mapOldTours == null && tour.Primary_Member__c != null) || (mapOldTours != null && tour.Primary_Member__c != null && tour.Status__c != mapOldTours.get(tour.Id).Status__c)){
                        setContactIds.add(tour.Primary_Member__c);
                    }
                    
                }        
                if(setContactIds.size() > 0){            
                    List<Task> openInboundLeadTask = new List<Task>();
                    for(Contact con : [Select Id, (Select Id, Subject From Tasks Where Subject In :setTaskSubjects and Status != 'Completed' ) From Contact Where Id in :setContactIds]){
                        for(Task task : con.tasks){
                            Debug.log('subject---'+task.Subject.toLowerCase());
                            Debug.log('contains---'+setTaskSubjects.contains(task.Subject.toLowerCase()));
                            if(setTaskSubjects.contains(task.Subject.toLowerCase())){
                                task.Status = 'Completed';
                                openInboundLeadTask.add(task);
                            }
                        }
                    } 
                    if(openInboundLeadTask.size()>0){
                        update openInboundLeadTask;
                    }
                }
            }
        }
    }
    /************************************************************************************************************************************
        Description         : Tour_Outcome__c: Move TourEndTime to TourTriggerHandler
        Last Modified Date  : 22/June/2016
        Last Modified By    : Anant Kumar
        Issue No            : ST-464
    ********************************************************************************************************************************/       
    public static void updateTourEndTime(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewItems, List<Tour_Outcome__c> listOldItems, Map<Id, Tour_Outcome__c> mapOldItems){
        for (Tour_Outcome__c tourRec : lstNewTours) {
            //if no end time, add a default one
            if (tourRec.End_Time__c == null && tourRec.Start_Time__c != null) {         
                //start time is required so always exists
                Time parsed_time = TourServices.parsePicklistTime(tourRec.Start_Time__c);
                tourRec.End_Time__c = Datetime.newInstance(
                    Date.today(), //just used as reference we only need the time
                    parsed_time.addMinutes(30)  
                ).format('h:mma');          
            }                
            //remove leading 0
            if (tourRec.End_Time__c != null && tourRec.Start_Time__c != null) {         
                tourRec.End_Time__c = tourRec.End_Time__c.removeStart('0');         
            }
        } 
    }
    
    /************************************************************************************************************************************
        Author              : Samadhan Kadam
        Description         : This method get active Referrence record and set Referrer__c field value of Tour based on Primary_Member__c email Id.
        Last Modified Date  : 20 July 2016
        Last Modified By    : Samadhan Kadam
        Issue No            : ST-531
    ********************************************************************************************************************************/       
    public static void updateActiveReferrerOnTour(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewTours, List<Tour_Outcome__c> lstOldTours, Map<Id, Tour_Outcome__c> mapOldTours){        
        Set<Id> setContact = new Set<Id>();
        for(Tour_Outcome__c currentTour : lstNewTours){
            if(mapOldTours == null && currentTour.Primary_Member__c != null){
                setContact.add(currentTour.Primary_Member__c);              
            } else if(mapOldTours != null && currentTour.Primary_Member__c != null && mapOldTours.get(currentTour.Id).Primary_Member__c != currentTour.Primary_Member__c){
                setContact.add(currentTour.Primary_Member__c);
            }
        }
        if(setContact!= null && !setContact.isEmpty()){
            Set<String> setOfContactEmails = new Set<String>();
            Map<Id, String> mapOfContact = new Map<Id, String>();
            for(Contact contact : [SELECT Id, Email FROM Contact WHERE Id IN :setContact]){
                if(contact.Email != null){
                    setOfContactEmails.add(contact.Email.toLowerCase());
                    mapOfContact.put(contact.Id, contact.Email.toLowerCase());
                }
            }
            if(mapOfContact != null && !mapOfContact.isEmpty()){
                Map<String,Id> mapActiveReference = ReferenceHandler.getActiveReference(setOfContactEmails);                    
                if(mapActiveReference != null && mapActiveReference.size() > 0){
                    for(Tour_Outcome__c tourRec : lstNewTours){
                        tourRec.Referrer__c = mapActiveReference.get(mapOfContact.get(tourRec.Primary_Member__c));
                    }   
                }
            }
        } 
    }
    
    /************************************************************************************************************************************
        Author              : Samadhan Kadam
        Description         : This method extend validity(Expires On) of Referral__c for 60 days if Tour Status__c is Completed or Scheduled.
        Last Modified Date  : 22 July 2016.
        Last Modified By    : Samadhan Kadam
        Issue No            : ST-473
    ********************************************************************************************************************************/      
    public static void extendValidityOfReference(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewTours, List<Tour_Outcome__c> lstOldTours, Map<Id, Tour_Outcome__c> mapOldTours){        
        Set<String> setPrimaryMemberEmails = new Set<String>();
        for(Tour_Outcome__c tourRec : lstNewTours){
            if(tourRec.Primary_Member__c != null && (Trigger.isInsert || (Trigger.isUpdate && tourRec.Status__c != mapOldTours.get(tourRec.Id).Status__c)) && (tourRec.Status__c == 'Scheduled' || tourRec.Status__c == 'Completed')){
                setPrimaryMemberEmails.add(tourRec.Primary_Member_Email__c);
            }
        }          
        if(setPrimaryMemberEmails != null && setPrimaryMemberEmails.size() > 0){
            ReferenceHandler.ExtendReference(setPrimaryMemberEmails);
        }        
    }

    /************************************************************************************************************************************
        Author              : Samadhan Kadam
        Description         : This method is used for call Count Tour
        Last Modified Date  : 22 July 2016.
        Last Modified By    : Samadhan Kadam
    ********************************************************************************************************************************/    
    @future
    public static void callCountTour(string triggerTourOutcomelst){
        TourTriggerHandler.countTour(triggerTourOutcomelst);
    }
    
    /************************************************************************************************************************************
        Author              : Mayuresh Ghodke
        Description         : Update count of tour on contact and change status of journey.
        Last Modified Date  : 12 August 2016
        Last Modified By    : Mayuresh Ghodke
        Issue No            : ST-601
    ********************************************************************************************************************************/      
    public static void countTour(String triggerTourOutcomelst){
		debug.log('countofTours==>'+triggerTourOutcomelst);       
        set<Id> setPrimaryContact = new set<Id>();
        List<Tour_Outcome__c> lstTriggerTourOutcomes = (List<Tour_Outcome__c>)JSON.deserialize(triggerTourOutcomelst, List<Tour_Outcome__c>.class); 
        debug.log('lstTriggerTourOutcomes==>'+lstTriggerTourOutcomes); 
        for(Tour_Outcome__c tourRec : lstTriggerTourOutcomes){
            if(tourRec.Primary_Member__c != null){
                setPrimaryContact.add(tourRec.Primary_Member__c);
            }    
        }    
         debug.log('setPrimaryContact==>'+setPrimaryContact); 
        if(setPrimaryContact.size() > 0){
            List<Contact> lstContactToBeUpdated = new List<Contact>();
            Integer countScheduledTours;
            Integer countCompletedTours;
            Integer countOtherTours;
            for(Contact conRec : [SELECT Id, Name, (SELECT Id, Name, Status__c FROM Tours3__r) FROM Contact Where Id IN : setPrimaryContact]){
                countScheduledTours = 0;
                countCompletedTours = 0;
                countOtherTours = 0;
                for(Tour_Outcome__c tourRec : conRec.Tours3__r){
                    if(tourRec.Status__c == 'Scheduled'){
                        countScheduledTours += 1;
                    }else if(tourRec.Status__c == 'Completed'){
                        countCompletedTours += 1;
                    }else{
                        countOtherTours += 1;
                    }
                }
                debug.log('countScheduledTours'+countScheduledTours);
                debug.log('countCompletedTours'+countCompletedTours);
                debug.log('countOtherTours'+countCompletedTours);
                lstContactToBeUpdated.add(new Contact(Id = conRec.Id,Total_Scheduled_Tours__c = countScheduledTours, Total_Completed_Tours__c = countCompletedTours, Other_Tours_Count__c = countOtherTours));
            }
            if(lstContactToBeUpdated.size()>0){
                update lstContactToBeUpdated;
            }                
        }
    }
    
    /************************************************************************************************************************************
        Author              : Mayuresh Ghodke
        Description         : This method is used for Contact2Activity mapping
        Last Modified Date  : 08 November 2016
        Last Modified By    : Mayuresh Ghodke
    ********************************************************************************************************************************/  
    public static Settings.FieldMappings Contact2Activity() {
        try{
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
        } catch(Exception pEx) {          
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('TourTriggerHandler','Contact2Activity','Field Mapping Error : Something Went Wrong !!!',pEx)
            );
            throw new TourTriggerHandlerException(pEx.getMessage());
        }        
    }
    
    
    /************************************************************************************************************************************
        Author              : Amol Darekar
        Description         : This trigger is use to create task on 1hr and 24 hr email reminde send.
        Last Modified Date  : 15 November 2016
        Last Modified By    : Amol Darekar
        Issue No            : ST-787
    ********************************************************************************************************************************/  
    public static void tourCreateTaskForEmailReminderSent(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewItems, List<Tour_Outcome__c> listOldItems, Map<Id, Tour_Outcome__c> mapOldTours){
        Set<Id> setOneHrTasks = new Set<Id>();
        Set<Id> setOneDayTasks = new Set<Id>();
        set<id> setContactMap = new set<id>();
        for(Tour_Outcome__c currentTour : lstNewTours){
            Tour_Outcome__c objOldTour = mapOldTours.get(currentTour.Id);
            if(currentTour.X1_Hour_reminder_email_sent__c == true && objOldTour.X1_Hour_reminder_email_sent__c != currentTour.X1_Hour_reminder_email_sent__c){
                setOneHrTasks.add(currentTour.Id);
                setContactMap.add(currentTour.Primary_Member__c);
            }
            if(currentTour.X24_Hours_email_reminder_sent__c == true && objOldTour.X24_Hours_email_reminder_sent__c != currentTour.X24_Hours_email_reminder_sent__c){
                setOneDayTasks.add(currentTour.Id);
                setContactMap.add(currentTour.Primary_Member__c);
            }
        }   
        Debug.log('setContactMap::'+setContactMap);
        if(setContactMap.size() > 0){
            Map<Id, Contact> mapContacts = new Map<Id,Contact>([select Id, ownerId From Contact where Id IN : setContactMap]);
            list<Task> lstTasks = new list<Task>();
            for(Tour_Outcome__c currentTour : lstNewTours){
                Task objTask;
                if(setOneHrTasks.contains(currentTour.Id)){
                    objTask = new Task();
                    objTask.OwnerId = mapContacts.get(currentTour.Primary_Member__c).ownerId;
                    objTask.Subject = '1 Hour reminder email sent';
                    objTask.Status = 'Completed';
                    objTask.Priority = 'Normal';
                    objTask.Type = 'Task';
                    objTask.WhatId = currentTour.Id;
                    objTask.WhoId = currentTour.Primary_Member__c;
                    lstTasks.add(objTask);                    
                }
                if(setOneDayTasks.contains(currentTour.Id)){
                    objTask = new Task();
                    objTask.OwnerId = mapContacts.get(currentTour.Primary_Member__c).ownerId;
                    objTask.Subject = '24 Hours email reminder sent';
                    objTask.Type = 'Task';
                    objTask.Status = 'Completed';
                    objTask.Priority = 'Normal';
                    objTask.WhatId = currentTour.Id;
                    objTask.WhoId = currentTour.Primary_Member__c;
                    lstTasks.add(objTask);                    
                }
            }
            if(lstTasks.size() > 0){               
                insert lstTasks; 
            }           
        }  
    }
    
    /************************************************************************************************************************************
        Author              : Anant Kumar
        Description         : Update related opportunity stage to 'Selling' if Tour status is changed to 'Completed'.by Dipak Pawar for exclude Opportunities to update Stages as defined in 'TourOpportunityStatusTrigger' settings.
        Last Modified Date  : 11 January 2017
        Last Modified By    : Dipak Pawar
        Issue No            : ST-862
    ********************************************************************************************************************************/   
    public static void updateOpportunityStage(List<Tour_Outcome__c> listNewItems, Map<Id, Tour_Outcome__c> mapNewItems, List<Tour_Outcome__c> listOldItems, Map<Id, Tour_Outcome__c> mapOldItems) {
        Map<Id,Opportunity> mapOpportunitiesToUpdate = new Map<Id,Opportunity>();
        TourOpportunityStatusController tourOpportunityStatusSetting = new TourOpportunityStatusController();
        Set<String> excludedOpportunityStages = new Set<String>();
        Setting__c JSONTourOpportunityStatus = Settings.get('TourOpportunityStatusTrigger');        
        if(JSONTourOpportunityStatus != null){
            tourOpportunityStatusSetting = (TourOpportunityStatusController)JSON.deserialize(JSONTourOpportunityStatus.Data__c, TourOpportunityStatusController.class);                 
        }            
        if(tourOpportunityStatusSetting != null){
            if(tourOpportunityStatusSetting.ExcludedOpportunityStages != null){
                for(String oppStagName : tourOpportunityStatusSetting.ExcludedOpportunityStages){
                    excludedOpportunityStages.add(oppStagName.trim().toLowerCase());
                }                
            }           
            Map<String, String> mapTourStatus = new Map<String, String>();
            Set<Id> setOpportunityIds = new Set<Id>();
            Map<String, String> mapOppStageNameValues = new Map<String, String>();
            Map<String, String> mapTourStatusValues = new Map<String, String>();
            for(Tour_Outcome__c tour : listNewItems){
                Tour_Outcome__c oldTour = mapOldItems.get(tour.Id);
                if(tour.Opportunity__c != null && oldTour.Status__c != tour.Status__c){
                    setOpportunityIds.add(tour.Opportunity__c);
                }           
            }            
            if(setOpportunityIds.size() > 0){
                Map<Id, Opportunity> mapTourRelatedOpportunities = new Map<Id, Opportunity>();
                if(setOpportunityIds.size() > 0){
                    for(Opportunity oppRec : [SELECT Id, StageName, (SELECT Id, Name, Status__c, Opportunity__c FROM Tour_Outcome__r) FROM Opportunity WHERE Id IN :setOpportunityIds AND StageName NOT IN: excludedOpportunityStages]){
                        if(!excludedOpportunityStages.contains(oppRec.StageName.trim().toLowerCase())){
                            mapTourRelatedOpportunities.put(oppRec.Id, oppRec);
                        }
                    }
                }
                
                if(tourOpportunityStatusSetting.TourOpportunityStatusMappings != null  && tourOpportunityStatusSetting.TourOpportunityStatusMappings.size() > 0){
                    for(TourOpportunityStatusMapping obj : tourOpportunityStatusSetting.TourOpportunityStatusMappings){                    
                        mapTourStatus.put(obj.TourStatus.toLowerCase(), obj.OpportunityStatus);
                    }           
                }
                
                for(String stageValue : WeworkEngine.fetchObjectFields('Opportunity', 'StageName')){
                    if(!mapTourStatus.containsKey(stageValue.toLowerCase())){
                        mapTourStatus.put(stageValue.toLowerCase(), stageValue);
                    }
                }
                
                for(Tour_Outcome__c tour : listNewItems){            
                    Tour_Outcome__c oldTour = mapOldItems.get(tour.Id);
                    if(tour.Opportunity__c != null && oldTour.Status__c != tour.Status__c && mapTourStatus.get(tour.Status__c.toLowerCase()) != null) {
                        Opportunity objOpportunity = new Opportunity(Id = tour.Opportunity__c);
                        if(mapTourRelatedOpportunities.get(tour.Opportunity__c) != null && mapTourRelatedOpportunities.get(tour.Opportunity__c).Tour_Outcome__r != null && mapTourStatus.get(mapTourRelatedOpportunities.get(tour.Opportunity__c).Tour_Outcome__r[0].Status__c.toLowerCase()) != null){
                            String status = mapTourRelatedOpportunities.get(tour.Opportunity__c).Tour_Outcome__r[0].Status__c;
                            objOpportunity.StageName = mapTourStatus.get(status.toLowerCase());
                            mapOpportunitiesToUpdate.put(objOpportunity.Id,objOpportunity);                     
                        }
                    }
                }
                if(mapOpportunitiesToUpdate.size()>0) {                        
                    update mapOpportunitiesToUpdate.values();                       
                }
            }
        }
    }
    /************************************************************************************************************************************
        Author          : Mayuresh Ghodke
        Description     : This wrapper is used to store opportunity status on tour.
        Created Date    : 08 November 2016
    ********************************************************************************************************************************/  
    public class TourOpportunityStatusController{
        public List<TourOpportunityStatusMapping> TourOpportunityStatusMappings{get;set;}
        public List<String> ExcludedOpportunityStages{get;set;}
    } 
    
    /************************************************************************************************************************************
        Author          : Mayuresh Ghodke
        Description     : This wrapper is used to map opportunity status.
        Created Date    : 08 November 2016
    ********************************************************************************************************************************/  
    public class TourOpportunityStatusMapping{
        public string TourStatus{get;set;}
        public string OpportunityStatus{get;set;}
    }    
    
    static Set<String> setReservableName = new Set<String>();// storing this things for next method
    static Map<String, Reservable__c> mapReservables = new Map<String, Reservable__c>();
    /************************************************************************************************************************************
        Author              : Dipak Pawar
        Description         : Update building names bu UUID provided by space sation in Interested_Buildings__c on Tour, update clean information on Tour after sync from SS for Tour Outcome Form functionality.
        Last Modified Date  : 08 August 2017
        Last Modified By    : Dipak Pawar
        Issue No            : ST-1068, ST-1243
    ********************************************************************************************************************************/ 
    public static void cleanTourOutcomeData(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewTours, List<Tour_Outcome__c> lstOldTours, Map<Id, Tour_Outcome__c> mapOldTours){        
        Map<Id, List<String>> mapBuildingUUIDs = new Map<Id, List<String>>();
        Set<String> setBuildingUUIDs = new Set<String>();
        Map<Id, List<String>> mapReservableUUIDs = new Map<Id, List<String>>();
        Set<String> setReservableUUIDs = new Set<String>();
        Map<Id, String> mapDecisionMakerEmails = new Map<Id, String>();
        if(mapOldTours != null) {
            for(Tour_Outcome__c newTourRec : lstNewTours){
                Tour_Outcome__c oldTourRec = mapOldTours.get(newTourRec.Id);
                // For building uuids
                if(String.valueOf(newTourRec.Interested_Buildings__c) != null && (String.valueOf(oldTourRec.Interested_Buildings__c) == null || (String.valueOf(oldTourRec.Interested_Buildings__c) != null && !String.valueOf(newTourRec.Interested_Buildings__c).contains(String.valueOf(oldTourRec.Interested_Buildings__c))))){
                    mapBuildingUUIDs.put(newTourRec.Id, String.valueOf(newTourRec.Interested_Buildings__c).split(';'));
                    setBuildingUUIDs.addAll(String.valueOf(newTourRec.Interested_Buildings__c).split(';'));                    
                }
                
                // For reservable uuids
                if(String.valueOf(newTourRec.Outcome_Reservables__c) != null && (String.valueOf(oldTourRec.Outcome_Reservables__c) == null ||(String.valueOf(oldTourRec.Outcome_Reservables__c) != null && !String.valueOf(newTourRec.Outcome_Reservables__c).contains(String.valueOf(oldTourRec.Outcome_Reservables__c))))){
                    mapReservableUUIDs.put(newTourRec.Id, String.valueOf(newTourRec.Outcome_Reservables__c).split(';'));
                    setReservableUUIDs.addAll(String.valueOf(newTourRec.Outcome_Reservables__c).split(';'));                    
                }               
                
                // For decision maker contact lookup field
                if(newTourRec.Name_of_Decision_Maker__c != null && newTourRec.Name_of_Decision_Maker__c != oldTourRec.Name_of_Decision_Maker__c){
                    mapDecisionMakerEmails.put(newTourRec.Id, newTourRec.Name_of_Decision_Maker__c);
                }
            }
            Map<String, Building__c> mapBuildings = new Map<String, Building__c>();
            if(setBuildingUUIDs != null && setBuildingUUIDs.size() > 0){
                Settings.fetchBuildings();
                mapBuildings = Settings.mapBuildingByUUID;
            }
            
            if(setReservableUUIDs.size() > 0){
                for(Reservable__c reservable : [SELECT Name, Building__r.Name, Building__c, Building_UUID__c, Floor__c, Monthly_Price__c, Next_Move_In__c, Office_Work_Station_Type__c, Office_Capacity__c, UUID__c FROM Reservable__c WHERE UUID__c IN :setReservableUUIDs]){
                    mapReservables.put(reservable.UUID__c, reservable);
                }            
            }            
            
            Map<String, Id> mapContacts = new Map<String, Id>();
            if(mapDecisionMakerEmails != null && mapDecisionMakerEmails.size() > 0){
                for(Contact conRec : [SELECT Id, Name, Email FROM Contact WHERE Email IN :mapDecisionMakerEmails.values()]){
                    mapContacts.put(conRec.Email, conRec.Id);
                }            
            }
            
            for(Tour_Outcome__c newTourRec : lstNewTours){
                Tour_Outcome__c oldTourRec = mapOldTours.get(newTourRec.Id);
                // For building names
                if(mapBuildingUUIDs.get(newTourRec.Id) != null && mapBuildingUUIDs.get(newTourRec.Id).size() > 0){
                    List<String> buildings = new List<String>();
                    for(String uuid : mapBuildingUUIDs.get(newTourRec.Id)){
                        if(mapBuildings != null && mapBuildings.get(uuid) != null && mapBuildings.get(uuid).Name != null){
                            buildings.add(mapBuildings.get(uuid).Name);
                        }else{
                            buildings.add(uuid);
                        }                  
                    }
                    newTourRec.Interested_Buildings__c = String.join(buildings, ';');
                }                
                // For reservable names
                if(mapReservableUUIDs.get(newTourRec.Id) != null && mapReservableUUIDs.get(newTourRec.Id).size() > 0){
                    List<String> reservables = new List<String>();
                    for(String uuid : mapReservableUUIDs.get(newTourRec.Id)){
                        if(mapReservables != null && mapReservables.get(uuid) != null && mapReservables.get(uuid).Name != null){
                            reservables.add(mapReservables.get(uuid).Name);
                        }else{
                            reservables.add(uuid);
                        }                   
                    }                    
                    setReservableName.addAll(reservables); //Modified By Nikhil Mehta For storing reservable name
                    newTourRec.Outcome_Reservables__c = String.join(reservables, ';');
                }                
                // For Decision maker contact lookup
                if(mapDecisionMakerEmails.get(newTourRec.Id) != null){
                    newTourRec.Decision_Maker__c = mapContacts.get(mapDecisionMakerEmails.get(newTourRec.Id));
                }                      
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              : Dipak Pawar
        Description         : Create or Update Tour outcome records based on Outcome_Reservables__c field from space station 
        Last Modified Date  : 08 August 2017
        Last Modified By    : Dipak Pawar
        Issue No            : ST-933, ST-1242
    ********************************************************************************************************************************/ 
    public static void createORUpdateTourOutcome(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewTours, List<Tour_Outcome__c> lstOldTours, Map<Id, Tour_Outcome__c> mapOldTours){
        Map<Id,List<String>> mapReservalbeNames = new Map<Id,List<String>>();
        Map<Id, Tour_Outcome__c> mapTriggerOldMap = mapOldTours;
        Set<String> setReservableNames = new Set<String>();
        Set<Id> setOpportunityIds = new Set<Id>();
        Set<String> setExcludedOppStages = new Set<String>{'closed won','closed lost'};
        Set<String> setFieldsForOpptyChange = new Set<String>{'Current_Budget__c','Desired_Budget__c','Name_of_Decision_Maker__c','No_Follow_Up__c','Urgency__c','Is_Decision_Maker__c','Decision_Maker__c'};
        Boolean boolChangeOppty = false;
        Debug.log('setExcludedOppStages => '+setExcludedOppStages);
        if(mapOldTours!=null) {
            for(Tour_Outcome__c newTourRec : lstNewTours){
                Tour_Outcome__c oldTourRec = mapOldTours.get(newTourRec.Id);
                if(newTourRec.Opportunity__c != null){
                    setOpportunityIds.add(newTourRec.Opportunity__c);
                }                
                if((newTourRec.Outcome_Reservables__c != null && newTourRec.Outcome_Reservables__c != '')){
                    mapReservalbeNames.put(newTourRec.Id, newTourRec.Outcome_Reservables__c.split(';'));
                    setReservableNames.addAll(newTourRec.Outcome_Reservables__c.split(';'));
                }              
            }            
            Map<String, Reservable__c> mapReservables = new Map<String, Reservable__c>();
            if(setReservableNames.size() > 0){                
                List<Reservable__c> lstReservable = new List<Reservable__c>();
                if(setReservableName != null && setReservableName.containsAll(setReservableNames) && mapReservables != null && mapReservables.size() > 0){
                    for(Reservable__c reservableRec : mapReservables.values()){
                        lstReservable.add(reservableRec);
                    }                
                }else{
                    lstReservable = [SELECT Name, Building__r.Name, Building__c, Building_UUID__c, Floor__c, Monthly_Price__c, Next_Move_In__c, Office_Work_Station_Type__c, Office_Capacity__c, UUID__c FROM Reservable__c WHERE Name IN :setReservableNames];
                }
                for(Reservable__c reservable : lstReservable){
                    mapReservables.put(reservable.Name, reservable);
                }               
            }
            if(setOpportunityIds.size()>0){
                if(mapOpportunities != null && !mapOpportunities.keySet().containsAll(setOpportunityIds)){
                    mapOpportunities = new Map<Id, Opportunity>([SELECT Id, StageName, (Select Id, Status__c From Tour_Outcome__r Where Status__c = 'Completed') FROM Opportunity WHERE Id IN: setOpportunityIds]);
                }
            }            
            Settings.fetchBuildings();
            Map<Id, Building__c> mapBuildings = Settings.mapBuildingById;      
            List<Tour_Summary__c> outcomesToInsert = new List<Tour_Summary__c>();
            Map<Id, Opportunity> mapOpportunitiesToUpdate = new Map<Id, Opportunity>();            
            for(Tour_Outcome__c tour : lstNewTours){       
                Tour_Outcome__c oldTour = mapOldTours.get(tour.Id);
                if((String.isNotBlank(tour.Unit_Type__c) || tour.Unit_Type__c != null) && tour.Office_Capacity__c != null){                    
                    List<String> officeCapacity = new List<String>();
                    List<String> officeCapacityTemp = tour.Office_Capacity__c.split(';');
                    List<String> unitType = tour.Unit_Type__c.split(';');
                    for(Integer i = 0; i < officeCapacityTemp.size(); i++){
                        officeCapacity.add(officeCapacityTemp[i]);
                    }                    
                    Map<Integer,Integer> mapCapacity=new Map<Integer,Integer>();
                    for(String capacity : officeCapacity){
                        if(mapCapacity.containsKey(Integer.valueOf(capacity))){
                            mapCapacity.put(Integer.valueOf(capacity), mapCapacity.get(Integer.valueOf(capacity))+1);
                        }else{
                            mapCapacity.put(Integer.valueOf(capacity), 1);
                        }
                    }
                    List<Map<String,Object>> unitTypeDetails = new List<Map<String,Object>>();
                    for(String office : unitType){
                        if(office.toLowerCase() != 'office'){
                            unitTypeDetails.add(new Map<String,Object>{'office'=>office,'capacity'=>1});
                            mapCapacity.put(1,mapCapacity.get(1)-1);
                        }
                    }
                    for(Integer capacity : mapCapacity.keyset()){
                        for(Integer i = 0; i < mapCapacity.get(capacity); i++){
                            unitTypeDetails.add(new Map<String, Object>{'office'=>'office','capacity'=>capacity});
                        }
                    }
                    for(Map<String,Object> unit : unitTypeDetails){
                        Tour_Summary__c outcome = new Tour_Summary__c();
                        outcome.TourSummary__c = tour.Id;
                        outcome.Tour_Outcome__c = tour.Tour_Outcome__c;
                        outcome.Move_In_Date__c = tour.Move_In_Date__c;
                        outcome.Interested_Buildings__c = tour.Interested_Buildings__c;
                        outcome.Tour_Outcome_Notes__c = tour.Tour_Outcome_Notes__c;
                        outcome.Objections__c = tour.Objections__c;
                        outcome.Product_Line__c = 'WeWork';
                        outcome.Opportunity__c = tour.Opportunity__c;
                        outcome.Unit_Type__c = String.valueOf(unit.get('office'));
                        outcome.BuildingName__c = tour.Location__c;
                        if(mapBuildings.containsKey(tour.Location__c)){
                            outcome.Building_UUID__c = mapBuildings.get(tour.Location__c).UUID__c;
                        }                            
                        outcome.Office_Capacity__c = Integer.valueOf(unit.get('capacity'));
                        outcome.Name = String.valueOf(unit.get('office') + '-' + unit.get('capacity')).capitalize();
                        outcome.Decision_Maker__c = tour.Decision_Maker__c;
                        outcome.Is_Decision_Maker__c = tour.Is_Decision_Maker__c;
                        outcome.Current_Budget__c = tour.Current_Budget__c;
                        outcome.Desired_Budget__c = tour.Desired_Budget__c;
                        outcome.Name_of_Decision_Maker__c = tour.Name_of_Decision_Maker__c;
                        outcome.How_Did_You_Hear_About_Us__c = tour.How_Did_You_Hear_About_Us__c;
                        outcome.Interested_in_Number_of_Desks__c = tour.Interested_in_Number_of_Desks__c;
                        outcome.No_Follow_Up__c = tour.No_Follow_Up__c;
                        outcome.Urgency__c = tour.Urgency__c;                        
                        outcomesToInsert.add(outcome);
                    }
                }                
                if(mapReservalbeNames != null && mapReservalbeNames.get(tour.Id) != null && mapReservalbeNames.get(tour.Id).size() > 0){
                    for(String reservableName : mapReservalbeNames.get(tour.Id)){
                        if(mapReservables.get(reservableName) != null){                 
                            Tour_Summary__c outcome = new Tour_Summary__c();                        
                            outcome.TourSummary__c = tour.Id;
                            outcome.Name = String.valueOf(mapReservables.get(reservableName).Name).capitalize();
                            outcome.Tour_Outcome__c = tour.Tour_Outcome__c;
                            outcome.BuildingName__c = mapReservables.get(reservableName).Building__c;
                            outcome.Building_UUID__c = mapReservables.get(reservableName).Building_UUID__c;
                            outcome.Reservable_Name__c = mapReservables.get(reservableName).Name;
                            outcome.Reservable_Price__c = mapReservables.get(reservableName).Monthly_Price__c;
                            outcome.Reservable_UUID__c = mapReservables.get(reservableName).UUID__c;
                            outcome.Reservable_Floor__c = String.valueOf(mapReservables.get(reservableName).Floor__c);
                            outcome.Move_In_Date__c = tour.Move_In_Date__c;
                            outcome.Interested_Buildings__c = tour.Interested_Buildings__c;
                            outcome.Unit_Type__c = mapReservables.get(reservableName).Office_Work_Station_Type__c;
                            outcome.Office_Capacity__c = mapReservables.get(reservableName).Office_Capacity__c;
                            outcome.Tour_Outcome_Notes__c = tour.Tour_Outcome_Notes__c;
                            outcome.Objections__c = tour.Objections__c;
                            outcome.Other_Objections__c = tour.Other_Objections__c;
                            outcome.Product_Line__c = 'WeWork';
                            outcome.Opportunity__c = tour.Opportunity__c;
                            outcome.Decision_Maker__c = tour.Decision_Maker__c;
                            outcome.Is_Decision_Maker__c = tour.Is_Decision_Maker__c;
                            outcome.Current_Budget__c = tour.Current_Budget__c;
                            outcome.Desired_Budget__c = tour.Desired_Budget__c;
                            outcome.Name_of_Decision_Maker__c = tour.Name_of_Decision_Maker__c;
                            outcome.How_Did_You_Hear_About_Us__c = tour.How_Did_You_Hear_About_Us__c;
                            outcome.Interested_in_Number_of_Desks__c = tour.Interested_in_Number_of_Desks__c;
                            outcome.No_Follow_Up__c = tour.No_Follow_Up__c;
                            outcome.Urgency__c = tour.Urgency__c;
                            outcomesToInsert.add(outcome);
                        }
                    }
                }
                if(tour.Opportunity__c!=null && mapOpportunities != null && mapOpportunities.get(tour.Opportunity__c)!=null){
                    Opportunity opp = mapOpportunities.get(tour.Opportunity__c);
                    for(String filed : setFieldsForOpptyChange){
                        if(tour.get(filed) != oldTour.get(filed)){
                            boolChangeOppty = true; 
                        }                            
                    }
                    Debug.log('mapOpportunities---'+mapOpportunities);
                    if(mapOpportunities.containsKey(tour.Opportunity__c) && mapOpportunities.get(tour.Opportunity__c) != null && (mapOpportunities.get(tour.Opportunity__c).Tour_Outcome__r.size() == 0)){
                        if(mapOldTours.get(tour.Id).Tour_Outcome_UUID__c == null){
                            if(opp.StageName!=null && !setExcludedOppStages.contains(opp.StageName.toLowerCase()) && boolChangeOppty){                        
                                opp.Id = tour.Opportunity__c;
                                opp.Decision_Maker__c = tour.Decision_Maker__c;
                                opp.Is_Decision_Maker__c = tour.Is_Decision_Maker__c;
                                opp.Current_Budget__c = tour.Current_Budget__c;
                                opp.Desired_Budget__c = tour.Desired_Budget__c;
                                opp.Name_of_Decision_Maker__c = tour.Name_of_Decision_Maker__c;
                                opp.How_Did_You_Hear_About_Us__c = tour.How_Did_You_Hear_About_Us__c;
                                opp.Interested_in_Number_of_Desks__c = tour.Interested_in_Number_of_Desks__c;
                                opp.No_Follow_Up__c = tour.No_Follow_Up__c;
                                opp.Urgency__c = tour.Urgency__c;
                                //DEV : Sunil B.
                                //Issue : ST-1272
                                //opp.CloseDate = tour.Expected_Close_Date__c;
                                mapOpportunitiesToUpdate.put(opp.Id, opp);                        
                            }
                        } 
                    } 
                } 
            }
            if(mapOldTours != null && mapOldTours.size() > 0){
                delete [SELECT Id, Name FROM Tour_Summary__c WHERE TourSummary__c IN: mapOldTours.keySet()];
            }
            if(outcomesToInsert.size() > 0){                
                upsert outcomesToInsert;
            }
            if(mapOpportunitiesToUpdate.size()>0){                
                update mapOpportunitiesToUpdate.values();
            }
        }                  
    }   
    
    /************************************************************************************************************************************
        Author              : Shivprasad Patil
        Description         : This method update Location email field on tour with related building email.
        Created Date        : 17 November 2018
    ********************************************************************************************************************************/
    public static void setLocationEmail(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewTours, List<Tour_Outcome__c> lstOldTours, Map<Id, Tour_Outcome__c> mapOldTours){
        Set<Id> setOfBuildingIds = new Set<Id>();
        List<Tour_Outcome__c> lstTours = new List<Tour_Outcome__c>();
        for(Tour_Outcome__c objTour: lstNewTours){
            if(String.isNotBlank(objTour.Building_No_City__c)){
                setOfBuildingIds.add(objTour.Location__c);
                lstTours.add(objTour);
            }
        }
        
        if(!lstTours.isEmpty()){
            Map<Id, Building__c> mapOfBuilding = new Map<Id, Building__c>([SELECT Id, Email__c FROM Building__c WHERE Id IN : setOfBuildingIds]);
            for(Tour_Outcome__c objTour: lstTours){
                objTour.Location_Email__c = mapOfBuilding.get(objTour.Location__c).Email__c;
            }     
        }
    }
    
    /************************************************************************************************************************************
        Author              : Shivprasad Patil
        Description         : This method update tour canceled date when status gets Cancelled
        Created Date        : 17 November 2018
     ********************************************************************************************************************************/
    public static void setTourCanceledDate(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewTours, List<Tour_Outcome__c> lstOldTours, Map<Id, Tour_Outcome__c> mapOldTours){
        for(Tour_Outcome__c objTour: lstNewTours){
            if(objTour.Status__c == 'Cancelled' && objTour.Tour_Canceled_Date__c == null ){
                objTour.Tour_Canceled_Date__c = System.today();
            }
        }
    }

    /************************************************************************************************************************************
        Author              : Shivprasad Patil
        Description         : This method update tour completed date when status gets completed
        Created Date        : 17 November 2018
     ********************************************************************************************************************************/
    public static void setTourCompletedDate(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewTours, List<Tour_Outcome__c> lstOldTours, Map<Id, Tour_Outcome__c> mapOldTours){
        for(Tour_Outcome__c objTour: lstNewTours){
            if(objTour.Status__c == 'Completed'){
                objTour.Tour_Completed__c = System.today();
            }
        }        
    }
    
     /************************************************************************************************************************************
        Author              : Shivprasad Patil
        Description         : This method update tour schedule with email field with related lead or opportunity primary member email
        Created Date        : 17 November 2018
     ********************************************************************************************************************************/
    public static void setTourScheduledWithEmail(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewTours, List<Tour_Outcome__c> lstOldTours, Map<Id, Tour_Outcome__c> mapOldTours){
        List<Tour_Outcome__c> lstTours = new List<Tour_Outcome__c>();
        Set<Id> setOfOpportunityIds = new Set<Id>();
        Set<Id> setOfLeadIds = new Set<Id>();
        for(Tour_Outcome__c objTour: lstNewTours){
            if(String.isNotBlank(objTour.Lead__c)){
                setOfLeadIds.add(objTour.Lead__c);
                lstTours.add(objTour);
            }
            if(String.isNotBlank(objTour.Opportunity__c)){
                setOfOpportunityIds.add(objTour.Opportunity__c);
                lstTours.add(objTour);
            }
        }
        
        if(!lstTours.isEmpty()){
            Map<Id, Opportunity> mapOfOpportunity;
            Map<Id, Lead> mapOfLead;
            if(!setOfOpportunityIds.isEmpty()){
                mapOfOpportunity = new  Map<Id, Opportunity>([SELECT Id, Primary_Member__r.Email FROM Opportunity  WHERE Id IN :setOfOpportunityIds]);
            }
            
            if(!setOfLeadIds.isEmpty()){
                mapOfLead = new Map<Id, Lead>([SELECT Id, Email FROM Lead WHERE ID IN :setOfLeadIds]);
            }
            Debug.log('mapOfLead==='+mapOfLead);
            for(Tour_Outcome__c objTour: lstTours){
                if(String.isNotBlank(objTour.Lead__c)){
                    objTour.Tour_Scheduled_With_Email__c = mapOfLead.get(objTour.Lead__c).Email;
                }else{
                    if(String.isNotBlank(mapOfOpportunity.get(objTour.Opportunity__c).Primary_Member__r.Email)){
                        objTour.Tour_Scheduled_With_Email__c = mapOfOpportunity.get(objTour.Opportunity__c).Primary_Member__r.Email;
                    }
                }
            }
        }
    }
    
    /************************************************************************************************************************************
        Author              : Shivprasad Patil
        Description         : This method update tour date if status is No Show Or Completed.
        Created Date        : 17 November 2018
     ********************************************************************************************************************************/
    public static void setTourDate(List<Tour_Outcome__c> lstNewTours, Map<Id, Tour_Outcome__c> mapNewTours, List<Tour_Outcome__c> lstOldTours, Map<Id, Tour_Outcome__c> mapOldTours){
        for(Tour_Outcome__c objTour: lstNewTours){
            if(objTour.Tour_Date__c == null && (objTour.Status__c == 'No Show' || objTour.Status__c == 'Completed')){
                objTour.Tour_Date__c = System.today();
            }
        }
    }
    /************************************************************************************************************************************
        Author          : Mayuresh Ghodke
        Description     : This class is custom exception class used to handle exceptions.
        Created Date    : 08 November 2016
    ********************************************************************************************************************************/  
    public class TourTriggerHandlerException extends Exception{}
}