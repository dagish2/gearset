/************************************************************************************************************************************
    Author 		: Amol Darekar
    Description : ---
    
    History		:
----------------------------------------------------------------------------------------------------------------------------------
    VERSION	  DATE	         AUTHOR        DETAIL
    1	      17,May 2016	 Amol Darekar  Initial Developement
	2.0       9 June 2018    Sunil Bhosale	Code revamp
**************************************************************************************************************************************/

public class JourneyTriggerHandler extends ITriggerHandler{
    public JourneyTriggerHandler(){
        super('Journey__c');
    }
    
 
 /************************************************************************************************************************************
    Author 				:
    Issue No 			:
    Description 		: Method for Before Insert Trigger Event.
    Created Date 		:
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Shivprasad Patil

**************************************************************************************************************************************/
    public override void BeforeInsert(List<SObject> listNewItems){
        if(triggerSettings.mappedField.Journey_UpdateActiveReferrerOnJourney){
            JourneyTriggerHandler.updateActiveReferrerOnJourney((List<Journey__c>)listNewItems);
        }
        if(triggerSettings.mappedField.Journey_GenerateUUID ){
            JourneyTriggerHandler.generateUUID((List<Journey__c>)listNewItems);
        }
        if(triggerSettings.mappedField.Journey_updateJourneysOwner){
           // JourneyTriggerHandler.updateJourneysOwner((List<Journey__c>)listNewItems,null,null,null);
        }       
        //restrictDuplicateRecordsForAccountAssignment(listNewItems, null, null, null);
    }
    
  /************************************************************************************************************************************
    Author 				:
    Issue No 			:
    Description 		: Method for Before Update Trigger Event.
    Created Date 		:
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/

    
    public override void BeforeUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        
        if(triggerSettings.mappedField.Journey_updateJourneysOwner){
            //  JourneyTriggerHandler.updateJourneysOwner((List<Journey__c>)listNewItems,(map<Id,Journey__c>)mapNewItems,(List<Journey__c>)listOldItems,(map<Id,Journey__c>)mapOldItems);
        } 
        // restrictDuplicateRecordsForAccountAssignment(listNewItems, mapNewItems, listOldItems, mapOldItems);
        
    }

  /************************************************************************************************************************************
    Author 				:
    Issue No 			:
    Description 		: Method for After Insert Trigger Event.
    Created Date 		:
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
    public override void AfterInsert(List<SObject> listNewItems, Map<Id, SObject> mapNewItems){
        
        if(triggerSettings.mappedField.Journey_WeekendCadence){
            if(!AvoidRecurssion.isExecute){
                // This is commented because now lead assignment done first and then create journey.
                JourneyTriggerHandler.weekendCadence((List<Journey__c>)listNewItems,(map<Id,Journey__c>)mapNewItems);
            }
        }
        
        if(triggerSettings.mappedField.Journey_UpdateOwnerOnPrimaryContact){
            //This trigger is commented because this scenario is deprecated
            //JourneyTriggerHandler.changeContactOwnerOnJourneyCreateUpdate(listNewItems,mapNewItems,null,null);
        }
        if(triggerSettings.mappedField.Journey_updateHasActiveJourneyField){
            JourneyTriggerHandler.updateHasActiveJourneyField((List<Journey__c>)listNewItems,(map<Id,Journey__c>)mapNewItems,null,null);
        } 
        if(triggerSettings.mappedField.Journey_updateWhoIdForTask){
            JourneyTriggerHandler.updateWhoIdForTask((List<Journey__c>)listNewItems,(map<Id,Journey__c>)mapNewItems,null,null);
        }
        //restrictDuplicateRecordsForAccountAssignment(listNewItems, null, null, null);
        
        if(triggerSettings.mappedField.Journey_setContactOutreachStageWhenJourneyStatusChange){
            setContactOutreachStageWhenJourneyStatusChange((List<Journey__c>)listNewItems, (map<Id,Journey__c>)mapNewItems, null, null);
        }        
    }

    /************************************************************************************************************************************
    Author 				:
    Issue No 			:
    Description 		: Method for After Update Trigger Event.
    Created Date 		:
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
        
    public override void AfterUpdate(List<SObject> listNewItems, Map<Id, SObject> mapNewItems, List<SObject> listOldItems, Map<Id, SObject> mapOldItems){
        if(triggerSettings.mappedField.Journey_CreateJourneyContactOnMemberChange){
            //JourneyTriggerHelper.CreateNewJournyContactOnMemberChange(listNewItems,mapNewItems,listOldItems,mapOldItems);
        }     
       
        if(triggerSettings.mappedField.Journey_UpdateOwnerOnPrimaryContact){
            //This trigger is commented because this scenario is deprecated
            //JourneyTriggerHandler.changeContactOwnerOnJourneyCreateUpdate(listNewItems,mapNewItems,listOldItems,mapOldItems);
        }
        if(triggerSettings.mappedField.Journey_updateHasActiveJourneyField){
            JourneyTriggerHandler.updateHasActiveJourneyField((List<Journey__C>)listNewItems,(map<Id,Journey__c>)mapNewItems,(List<Journey__C>)listOldItems,(map<Id,Journey__c>)mapOldItems);
        }
        if(triggerSettings.mappedField.Journey_updateWhoIdForTask){
            JourneyTriggerHandler.updateWhoIdForTask((List<Journey__C>)listNewItems,(map<Id,Journey__c>)mapNewItems,(List<Journey__C>)listOldItems,(map<Id,Journey__c>)mapOldItems);
        }
       
        // restrictDuplicateRecordsForAccountAssignment(listNewItems, mapNewItems, listOldItems, mapOldItems);
         
        if(triggerSettings.mappedField.Journey_setContactOutreachStageWhenJourneyStatusChange){
            setContactOutreachStageWhenJourneyStatusChange((List<Journey__c>)listNewItems, (map<Id,Journey__c>)mapNewItems, (List<Journey__c>)listOldItems, (map<Id,Journey__c>)mapOldItems);
        }
    }

 /************************************************************************************************************************************
    Author 				: Krishana Tupe
    Issue No 			:
    Description 		: Set Contact Outreach Stage When Journey Outreach_Stage__c change  
    Last Modified Date	: 11 Dec 2018
	Last Modified Date	: 19 Feb 2019 for fix duplicate Id in List issue
    Last Modified By	: Krishana Tupe
**************************************************************************************************************************************/
    public static void setContactOutreachStageWhenJourneyStatusChange(List<Journey__c> listNewItems, Map<Id, Journey__c> mapNewItems, List<Journey__c> listOldItems, Map<Id, Journey__c> mapOldItems){
        Set<String> journeyStage = new Set<String>{'Manual Outreach','NMD Drip'};          
            Map<Id, Contact> mapContactsToUpdate = new Map<Id, Contact>();
        for(Journey__c currentJourney : listNewItems){           
            Journey__c oldJourney = Trigger.isUpdate ? mapOldItems.get(currentJourney.Id) : null;
            if(String.isNotBlank(currentJourney.Outreach_Stage__c) && journeyStage.contains(currentJourney.Outreach_Stage__c) && (Trigger.isInsert || (Trigger.isUpdate && oldJourney.Outreach_Stage__c != currentJourney.Outreach_Stage__c))){
                if(String.isNotBlank(currentJourney.Primary_Contact__c)){
                    Contact objContact = new Contact(Id = currentJourney.Primary_Contact__c, Outreach_Stage__c = currentJourney.Outreach_Stage__c);
                    mapContactsToUpdate.put(objContact.Id, objContact);
                }
            }
        }        
        if(!mapContactsToUpdate.isEmpty()){
            update mapContactsToUpdate.values();  
        }         
    }
   
/************************************************************************************************************************************
Author 				: Samadhan Kadam
Issue No 			: ST-533
Description 		: This method get active Referrence record and set Referrer__c field value of lead or contact based on email Id. 
Created Date 		: 19-07-2016
Last Modified Date	: 2 Feb, 2018
Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
    public static void updateActiveReferrerOnJourney(List<Journey__c> listNewItems){
        Set<String> setLeadEmails = new Set<String>();
        Set<String> setContactEmails = new Set<String>();
        Set<Id> setContact = new Set<Id>();
        Set<Id> setLead = new Set<Id>();
        Map<Id,String> mapOfLead = new Map<Id,String>();
        Map<Id,String> mapOfContact = new Map<Id,String>();
        for(Journey__c journey :  listNewItems){
            if(journey.Primary_Contact__c != null){
                setContact.add(journey.Primary_Contact__c);
            }  			
            if(journey.Primary_Lead__c != null){
                setLead.add(journey.Primary_Lead__c);
            }
        }
        if(!setContact.isEmpty()){
            for(Contact contact :  [select Id,Email,Referrer__c from Contact WHERE Id IN:setContact]){
                if(contact.Email != null){
                    setContactEmails.add(contact.Email.toLowerCase());
                    mapOfContact.put(contact.Id,contact.Email.toLowerCase());
                }
                
            }
            if(setContactEmails.size() > 0){
                Map<String,Id> mapOfContactActiveReference = ReferenceHandler.getActiveReference(setContactEmails);
                if(mapOfContactActiveReference != null && mapOfContactActiveReference.size() > 0){
                    for(Journey__c journey : listNewItems){
                        if( journey.Primary_Contact__c != null && mapOfContactActiveReference.get(mapOfContact.get(journey.Primary_Contact__c)) != null)
                            journey.Referrer__c = mapOfContactActiveReference.get(mapOfContact.get(journey.Primary_Contact__c));
                    }
                }
            }
        }
        if(setLead.size() > 0){
            for(Lead lead :  [select Id,Email,Referrer__c from Lead WHERE Id IN:setLead]){
                if(lead.Email != null){
                    setLeadEmails.add(lead.Email.toLowerCase());
                    mapOfLead.put(lead.Id,lead.Email.toLowerCase());	
                }
            }
            if(setLeadEmails.size() > 0){
                Map<String,Id> mapOfLeadActiveReference = ReferenceHandler.getActiveReference(setLeadEmails);
                debug.Log('mapOfLeadActiveReference' + mapOfLeadActiveReference);
                if(mapOfLeadActiveReference != null && mapOfLeadActiveReference.size() > 0){
                    for(Journey__c journey : listNewItems){
                        if( journey.Primary_Lead__c!= null && String.isNotBlank(journey.Primary_Lead__r.Email) && mapOfLeadActiveReference.get(mapOfLead.get(journey.Primary_Lead__c)) != null)
                            journey.Referrer__c = mapOfLeadActiveReference.get(mapOfLead.get(journey.Primary_Lead__c));
                    }
                }
            }
        }
    } 
    
/************************************************************************************************************************************
Author 				: Mayuresh Ghodke
Issue No 			:
Description 		: Generate UUID for new Journey.
Created Date 		: 29-07-2016
Last Modified Date	: 2 Feb, 2018
Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
   public static void generateUUID(List<Journey__c> listNewItems) {
          for (Journey__c journeyRec : listNewItems) {
                journeyRec.UUID__c = UUIDHandler.generateVersion4();
            }
    }
    
/************************************************************************************************************************************
Author 				: pranay jadhav
Issue No 			: ST-794
Description 		: If a journey is created on a Friday then the NMD next contact date should be the monday following.
Created Date 		: 28/11/2016
Last Modified Date	: 2 Feb, 2018
Last Modified By	: Shivprasad Patil
**************************************************************************************************************************************/
   public static void weekendCadence(List<Journey__c> listNewItems, Map<Id, Journey__c> mapNewItems){ 
            List<Journey__c> lstJourneyToUpdate = new List<Journey__c>();
            Set<Id> recordUserIds = new Set<Id>();
            Set<Id> recordQueueIds = new Set<Id>();
            Map<String,BusinessHours> mapBH = new Map<String,BusinessHours>();
            Map<Id,Id> mapGroupIdwithUserId = new Map<Id,Id>();
            Map<Id,User> mapUsers = new Map<Id,User>();
            for(BusinessHours bh:[SELECT Id,Name FROM BusinessHours]){
                if(!mapBH.containsKey(bh.Name))
                    mapBH.put(bh.Name, bh);
            }
            List<Journey__c> lstJourneys = [SELECT Id,Name,NMD_Next_Contact_Date__c,CreatedDate,OwnerId FROM Journey__c WHERE Id in : mapNewItems.keySet()]; 
            for (Journey__c journeyRec : lstJourneys) {
                if(((String)journeyRec.OwnerId).startsWith('00G'))
                    recordQueueIds.add(journeyRec.OwnerId);
                else
                    recordUserIds.add(journeyRec.OwnerId);
            }
            if(!recordUserIds.isEmpty())
                mapUsers = new Map<Id,User>([SELECT Id,Name,TimeZoneSidKey FROM User WHERE Id in: recordUserIds]);
            
            if(!recordQueueIds.isEmpty()){
                for(User objUser : [SELECT Id, Name, TimeZoneSidKey FROM User WHERE Id in (SELECT UserOrGroupId FROM GroupMember WHERE GroupId in : recordQueueIds)]){
                    if(!mapUsers.containsKey(objUser.Id))
                        mapUsers.put(objUser.Id, objUser);
                }
                
                for(GroupMember objGroupMember : [SELECT UserOrGroupId,GroupId FROM GroupMember WHERE GroupId in : recordQueueIds]){
                    if(!mapGroupIdwithUserId.containsKey(objGroupMember.GroupId)){
                        mapGroupIdwithUserId.put(objGroupMember.GroupId, objGroupMember.UserOrGroupId);
                    }
                }
            }
            for(Journey__c journeyRec : lstJourneys){
                if(!((String)journeyRec.OwnerId).startsWith('00G')){
                    String str = 'WeWork_'+ mapUsers.get(journeyRec.OwnerId).TimeZoneSidKey +'_Business_Hours';
                    if(mapBH.containsKey(str)){
                        Timezone tz = Timezone.getTimeZone(mapUsers.get(journeyRec.OwnerId).TimeZoneSidKey);
                        Debug.Log('isWithin  ==>>'+ BusinessHours.isWithin(mapBH.get(str).Id, journeyRec.CreatedDate));
                        if(!BusinessHours.isWithin(mapBH.get(str).Id, journeyRec.CreatedDate)){
                            DateTime dt = BusinessHours.nextStartDate(mapBH.get(str).Id, journeyRec.CreatedDate);
                            Debug.Log('Returned Date ==> '+ dt);
                            Debug.Log('tz.getOffset(dt) dt ==> '+ (tz.getOffset(dt)/ (60 * 60* 1000)));
                            DateTime localDate = dt.addMinutes(tz.getOffset(dt) / (60 * 1000));
                            Debug.Log('Adjusted Local Date added diff ==> '+ localDate);
                            Debug.Log('Local Date formated to tz ==> '+ date.valueOf(dt.format('yyyy-MM-dd', mapUsers.get(journeyRec.OwnerId).TimeZoneSidKey)));
                            journeyRec.NMD_Next_Contact_Date__c = date.valueOf(dt.format('yyyy-MM-dd', mapUsers.get(journeyRec.OwnerId).TimeZoneSidKey));
                            lstJourneyToUpdate.add(journeyRec);
                        }else{
                            DateTime dt = BusinessHours.nextStartDate(mapBH.get(str).Id, journeyRec.CreatedDate);
                            Debug.Log('In else Return nextStartDate  ==>>'+ dt);
                            DateTime localDate = dt.addMinutes(tz.getOffset(dt) / (60 * 1000));
                            Debug.Log('In Else Local Date formated ==> '+ date.valueOf(dt.format('yyyy-MM-dd', mapUsers.get(journeyRec.OwnerId).TimeZoneSidKey)));
                            if((journeyRec.OwnerId != null) && mapUsers.containsKey(journeyRec.OwnerId))
                                journeyRec.NMD_Next_Contact_Date__c = date.valueOf(dt.format('yyyy-MM-dd', mapUsers.get(journeyRec.OwnerId).TimeZoneSidKey));
                            lstJourneyToUpdate.add(journeyRec);
                        }
                    }
                }else{
                    TimeZone uTZ = UserInfo.getTimeZone();
                    String str ='';
                    if(mapGroupIdwithUserId.containsKey(journeyRec.OwnerId) && mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)) != null)
                        str = 'WeWork_'+ mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)).TimeZoneSidKey +'_Business_Hours';
                    else
                        str = 'WeWork_'+ uTZ.getID() +'_Business_Hours';
                    Debug.log('str in else ==>>'+str);
                    if(mapBH.containsKey(str)){
                        Timezone tz;
                        if(mapGroupIdwithUserId.containsKey(journeyRec.OwnerId) && mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)) != null)
                            tz = Timezone.getTimeZone(mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)).TimeZoneSidKey);
                        else 
                            tz = uTZ;
                        Debug.Log('isWithin  ==>>'+ BusinessHours.isWithin(mapBH.get(str).Id, journeyRec.CreatedDate));
                        if(!BusinessHours.isWithin(mapBH.get(str).Id, journeyRec.CreatedDate)){
                            DateTime dt = BusinessHours.nextStartDate(mapBH.get(str).Id, journeyRec.CreatedDate);
                            Debug.Log('Return nextStartDate  ==>>'+ dt);
                            DateTime localDate = dt.addMinutes(tz.getOffset(dt) / (60 * 1000));
                            Debug.Log('Adjusted Local Date added diff ==> '+ localDate);
                            journeyRec.NMD_Next_Contact_Date__c = ((mapGroupIdwithUserId.containsKey(journeyRec.OwnerId) && mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)) != null) ? date.valueOf(dt.format('yyyy-MM-dd', mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)).TimeZoneSidKey)) : date.valueOf(dt.format('yyyy-MM-dd', uTZ.getID())));
                            lstJourneyToUpdate.add(journeyRec);
                        }else{
                            DateTime dt = BusinessHours.nextStartDate(mapBH.get(str).Id, journeyRec.CreatedDate);
                            Debug.Log('In else Return nextStartDate  ==>>'+ dt);
                            DateTime localDate = dt.addMinutes(tz.getOffset(dt) / (60 * 1000));
                            journeyRec.NMD_Next_Contact_Date__c = ((mapGroupIdwithUserId.containsKey(journeyRec.OwnerId) && mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)) != null) ? date.valueOf(dt.format('yyyy-MM-dd', mapUsers.get(mapGroupIdwithUserId.get(journeyRec.OwnerId)).TimeZoneSidKey)) : date.valueOf(dt.format('yyyy-MM-dd', uTZ.getID())));
                            lstJourneyToUpdate.add(journeyRec);
                        }
                    }
                }
            }
            if(!lstJourneyToUpdate.isEmpty()){
                AvoidRecurssion.isExecute = true;
                update lstJourneyToUpdate;
            }
      
    }
/************************************************************************************************************************************
    Author				: Samadhan Kadam
    Issue No 			: ST-928
    Description 		: If Journey's Primary Lead or Primary Contact has more than 1 active journey then set "Has Active Journey" checkbox to true. 
    Created Date 		: 02-03-2017
    Last Modified By	: Krishana Tupe
**************************************************************************************************************************************/
    public static void updateHasActiveJourneyField(List<Journey__c> listNewItems, Map<Id, Journey__c> mapNewItems, List<Journey__c> listOldItems, Map<Id, Journey__c> mapOldItems){
        set<Id> setContactId = new set<Id>(); 
        set<Id> setLeadId = new set<Id>(); 
        List<Sobject> lstSobjectToUpdate = new List<Sobject>();        
        for(Journey__c objJourney :  listNewItems){
            Journey__c oldJourney = (Trigger.isUpdate ? mapOldItems.get(objJourney.Id) : null);
            if(Trigger.isInsert || (Trigger.isUpdate && ((String.isNotBlank(objJourney.Status__c) && String.isNotBlank(oldJourney.Status__c) != null  && objJourney.Status__c != oldJourney.Status__c )|| ( String.isNotBlank(objJourney.Primary_Lead__c) && String.isNotBlank(oldJourney.Primary_Lead__c) && objJourney.Primary_Lead__c != oldJourney.Primary_Lead__c)))){
                if(String.isNotBlank(objJourney.Primary_Contact__c)){
                    setContactId.add(objJourney.Primary_Contact__c);
                }else if(String.isNotBlank(objJourney.Primary_Lead__c)){
                    setLeadId.add(objJourney.Primary_Lead__c);
                }   
            }
        }       
        Set<String> setJourneyClosedStages  = LeadRoutingHelper.getJourneyClosedStages(); 
        if(!setContactId.isEmpty() && !setJourneyClosedStages.isEmpty()){        
            for(Contact currentContact : [SELECT Id, OwnerId, Has_Active_Journey__c, (SELECT Id, OwnerId, CreatedDate, Status__c FROM Journeys__r WHERE Status__c NOT IN : setJourneyClosedStages) FROM Contact where Id IN : setContactId]) {               
                Boolean isOpenJourneyPresent = false;
                for(Journey__c objJourney : currentContact.Journeys__r){
                    isOpenJourneyPresent = true;
	            break;
                }
                if(isOpenJourneyPresent){
                    if(!currentContact.Has_Active_Journey__c){
                        lstSobjectToUpdate.add(new Contact(Id = currentContact.Id, Has_Active_Journey__c = true));   
                    }
                }else if(currentContact.Has_Active_Journey__c){
                    lstSobjectToUpdate.add(new Contact(Id = currentContact.Id, Has_Active_Journey__c = false)); 
                }                
            }         
        }
        
        if(!setLeadId.isEmpty() && !setJourneyClosedStages.isEmpty()){            
            for(Lead currentLead : [SELECT Id,OwnerId, Has_Active_Journey__c, (SELECT Id, OwnerId, CreatedDate, Status__c FROM Journeys__r WHERE Status__c NOT IN : setJourneyClosedStages) FROM Lead where Id IN : setLeadId]){
                Boolean isOpenJourneyPresent = false;
                for(Journey__c objJourney : currentLead.Journeys__r){
                    isOpenJourneyPresent = true;
	            break;
                }
                if(isOpenJourneyPresent){
                    if(!currentLead.Has_Active_Journey__c){
                        lstSobjectToUpdate.add(new Lead(Id = currentLead.Id,Has_Active_Journey__c = true));
                    }
                }else if(currentLead.Has_Active_Journey__c){
                    lstSobjectToUpdate.add(new Lead(Id=currentLead.Id,Has_Active_Journey__c = false));
                }
            }              
        }          
        Debug.log('lstSobjectToUpdate==>'+lstSobjectToUpdate);
        if(lstSobjectToUpdate.Size() > 0){
            update lstSobjectToUpdate;
        }
    }
    
    /************************************************************************************************************************************
    Author 				: Anant Kumar
    Issue No 			:
    Description 		: If journey's primary member gets changed from Lead to Contact, we need to update all the task's WhoId related to the journey. 
    Created Date 		: 05-06-2017
    Last Modified Date	: 2 Feb, 2018
    Last Modified By	: Shivprasad Patil
    **************************************************************************************************************************************/
    public static void updateWhoIdForTask(List<Journey__c> listNewItems, Map<Id, Journey__c> mapNewItems, List<Journey__c> listOldItems, Map<Id, Journey__c> mapOldItems){
        
        Map<Id, Journey__c> oldMap = mapOldItems;
        Map<Id, Journey__c> journeyWithPrimaryMemberChange = new Map<Id, Journey__c>();
        for(Journey__c journey :  listNewItems){
            if(journey.Primary_Contact__c != null && (Trigger.isInsert || (Trigger.isUpdate && oldMap.get(journey.Id).Primary_Contact__c == null)))
                journeyWithPrimaryMemberChange.put(journey.Id, journey);
        }
        Map<Id, Task> tasksToUpdate = new Map<Id, Task>();
        if(journeyWithPrimaryMemberChange != null && journeyWithPrimaryMemberChange.size() > 0){
            for(Task task:[SELECT Id, WhoId, WhatId FROM Task WHERE WhatId in:journeyWithPrimaryMemberChange.keySet()]){
                task.WhoId = journeyWithPrimaryMemberChange.get(task.WhatId).Primary_Contact__c;
                tasksToUpdate.put(task.Id, task);
            }
            if(tasksToUpdate.size() > 0){
                update tasksToUpdate.values();
            }
        }
    }
    public class JourneyTriggerHandlerException extends Exception{}
    
}