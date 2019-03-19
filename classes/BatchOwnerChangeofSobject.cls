/*****************************************************************************************************************************
	Author 		:  Krishana Tupe  
	Description :  Reassign Sobject records having inactive owners by assignment rule using Batch
	History		: 

----------------------------------------------------------------------------------------------------------------------------------
	VERSION			DATE			AUTHOR				Issue No		DETAIL
	1				17 Nov 2017		Krishana Tupe		ST-1287			Initial Developement
	2				15 Nov 2018		Krishana Tupe		ST-1287			Revisit for contact ownership & Refactoring. 
******************************************************************************************************************************/
public class BatchOwnerChangeofSobject implements Database.Batchable<SObject>,Database.stateful {
    public List<String> lstOfSobject;
    public Integer index;
    public String query='',sObjectName;
    public Set<Id> setUserIds; 
    public RestrictBatchToChangeOwnerSettings settingObj;
    public Set<String> journeyClosedStatus,SetTourStatus,SetJourneyStatus,SetoppStageNames;        
    public  Map<String,String> mapContactOwnerData = (Map<String,String>)JSON.deserialize(Settings.get('Assign Contacts to Active User').Data__c, Map<String,String>.class);      
    public  Map<String, Set<String>> mapAllowedRecordTypesToChangeContactOwner;
    public  Set<String> setAllowedRecordTypes = new Set<String>();
    
    /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This Constructor is used to construct the query based on sobjectName.
		Created Date		:	17 Nov 2017        
 **************************************************************************************************************************************/
    public BatchOwnerChangeofSobject(Set<Id>setUserIds, List<String> lstOfSobject, Integer index){       
        this.lstOfSobject = lstOfSobject;
        this.index = index;
        String sObjectName = lstOfSobject[index];
        this.setUserIds = setUserIds;
        String query=''; 
        this.sObjectName = sObjectName;
        
        switch on sObjectName {
            when 'Journey__c' {		
                query+= 'SELECT Id, primary_Lead__c, primary_Lead__r.OwnerId, primary_contact__c, primary_contact__r.OwnerId, Name, OwnerId, Status__c FROM '+sObjectName+' WHERE OwnerId IN :setUserIds AND Status__c <> \'Completed\'';
                this.journeyClosedStatus = new Set<String>();
                Map<String,Object> mapOfSetting  = (Map<String,Object>)JSON.deserializeUntyped(Settings.get('JourneyForceFullyClose').Data__c);            
                for(Object stage : (List<Object>)mapOfSetting.get('Stages')){
                    journeyClosedStatus.add(((String)stage).toLowerCase());
                }    
            }	
            when 'Tour_Outcome__c' {		
                query += 'SELECT Id, Name, OwnerId, Status__c FROM '+sObjectName+' WHERE OwnerId IN : setUserIds';  
            }
            when 'Opportunity' {		
                query += 'SELECT Id, Name, OwnerId, StageName FROM '+sObjectName+' WHERE OwnerId IN : setUserIds AND StageName Not In : SetoppStageNames';
            }          
            when 'Lead' {		
                query +='SELECT Id, Name, OwnerId, LeadSource FROM '+sObjectName+' WHERE OwnerId IN : setUserIds AND isConverted = false';
            }
            when 'Contact' {		
                query += 'SELECT Id, Name, AccountId, OwnerId, Account_Owner__c, Account.RecordTypeId, Account.RecordType.Name FROM '+sObjectName+' WHERE (OwnerId IN :setUserIds OR Owner.isActive = false)'; 
                this.mapAllowedRecordTypesToChangeContactOwner = (Map<String, Set<String>>)JSON.deserialize(Settings.get('ContactOwnerShipSetting').Data__c,Map<String, Set<String>>.class);
                this.setAllowedRecordTypes = mapAllowedRecordTypesToChangeContactOwner.get('AllowedRecordTypes'); 
            }
            when else{		
                query += 'SELECT Id, Name, OwnerId FROM '+sObjectName+' WHERE OwnerId IN :setUserIds';  
            }            
        }      
        Debug.log('BatchOwnerChangeofSobject query ==>'+query);        
        this.query = query;        
        settingObj = (RestrictBatchToChangeOwnerSettings)JSON.deserialize(Settings.get('RestrictBatch To Change Owner Setting').Data__c.toLowerCase(), RestrictBatchToChangeOwnerSettings.class);       
        this.SetTourStatus = settingObj.TourStatus;
        this.SetJourneyStatus = settingObj.JourneyStatus;
        this.SetoppStageNames = settingObj.OpportunityStageName; 
    }
    
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to get the records whose owner is inactive.
		Created Date		:	17 Nov 2017        
 **************************************************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext context) {       
        return Database.getQueryLocator(query); 
    }    
    
     /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to reassign the owner of records based on criterias.
		Created Date		:	17 Nov 2017  
		Last Modified Date	:	
        Last Modified By	: 	Shivprasad Patil
	**************************************************************************************************************************************/
    public void execute(Database.BatchableContext context, List<sObject> lstRecords) {               
        switch on sObjectName {
            when 'Account'{
                this.setAccountOwnerByDealType((List<Account>)lstRecords);     
            }
            when 'Lead'{
                this.setLeadOwnerByLeadAssignmentRule((List<Lead>)lstRecords);
            }
            when 'Contact'{
                this.setContactOwnerOnUserDeactivation((List<Contact>)lstRecords);
            }
            when 'Journey__c'{
                this.setJourneyOwnerOnUserDeactivation((List<Journey__c>)lstRecords); 
            }
            when 'Tour_Outcome__c'{
                this.setTourOwnerOnUserDeactivation((List<Tour_Outcome__c>)lstRecords);  
            }
            when 'Opportunity'{
                this.setOpportunityOwnerOnUserDeactivation((List<Opportunity>)lstRecords);
            }
        }        
    }
    
  /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to rerun the batch till records not finished.
		Created Date		:	17 Nov 2017  
  		Last Modified Date	:	
        Last Modified By	: 	Shivprasad Patil
 **************************************************************************************************************************************/    
    public void finish(Database.BatchableContext context) {
        if((lstOfSobject.size() - 1) > index ){
            Database.executeBatch(new BatchOwnerChangeofSobject(setUserIds,lstOfSobject,index+1),50); 
        }
    }
    
   
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to assign account owner using Account assignment by latest modified opportunity Deal Type.
		Created Date		:	15 Nov 2018        
 *************************************************************************************************************************************/ 
    public void setAccountOwnerByDealType(List<Account> lstRecords){
        Set<Id> setAccountIds = new Set<Id>();
        for(Account objAccount : lstRecords){
            setAccountIds.add(objAccount.Id);                
        }
        if(setAccountIds.size() > 0){               
            List<Account> lstAccounts = new List<Account>();
            lstAccounts = WithoutSharingUtilityController.setAccountOwnerByDealType(setAccountIds);
            this.updateListRecords(lstAccounts);                             
        } 
    } 
    
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to assign Lead owner using Lead assignment rule.
		Created Date		:	15 Nov 2018        
 *************************************************************************************************************************************/  
    public void setLeadOwnerByLeadAssignmentRule(List<Lead> lstRecords){
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        for(Lead objLead : lstRecords){
            objLead.User_Deactivation_Updated_On__c = Date.today();
            objLead.Reassignment_On_User_Deactivation__c = true;
        }        
        Database.update(lstRecords, dmo);
    }
    
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to assign Contact owner as Account owner or Susie Romero depends on the Account Segment.
		Created Date		:	15 Nov 2018        
 *************************************************************************************************************************************/ 
    public void setContactOwnerOnUserDeactivation(List<Contact> lstRecords){
        List<Contact> lstContactToUpdates = new List<Contact>();       
        for(Contact objContact : lstRecords){            
            if(String.isNotBlank(objContact.Account_Owner__c) && objContact.OwnerId != Id.valueOf(objContact.Account_Owner__c)){
                if(setAllowedRecordTypes == null || (objContact.Account.RecordTypeId != null && setAllowedRecordTypes != null &&  setAllowedRecordTypes.contains(objContact.Account.RecordType.Name))){
                    if(Settings.getUserActive(objContact.Account_Owner__c)){
                        objContact.OwnerId = Id.valueOf(objContact.Account_Owner__c);
                        lstContactToUpdates.add(objContact);                         
                    }     
                }  
            }
            if(mapContactOwnerData != null && mapContactOwnerData.get('Id') != null && String.isNotBlank(objContact.AccountId) && objContact.Account.RecordTypeId != null && setAllowedRecordTypes != null && !setAllowedRecordTypes.contains(objContact.Account.RecordType.Name)){
                objContact.OwnerId = mapContactOwnerData.get('Id');
                lstContactToUpdates.add(objContact); 
            }
        }  
        this.updateListRecords(lstContactToUpdates);
    }
    
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to assign Journey owner as Lead/Contact owner or Susie Romero or NMD Unassigned Queue.
		Created Date		:	15 Nov 2018        
 *************************************************************************************************************************************/ 
    public void setJourneyOwnerOnUserDeactivation(List<Journey__c> lstRecords){
        List<Journey__c> lstJourneysTobeUpdates = new List<Journey__c>(); 
        QueueSObject objQueue = [SELECT Queue.Id, Queue.Name FROM QueueSObject WHERE Queue.Name = 'Unassigned NMD US Queue' LIMIT 1];  
        for(Journey__c objJourney : lstRecords){
            Id journeyOwnerId;            
            if(String.isNotBlank(objJourney.Status__c) && !SetJourneyStatus.contains(objJourney.Status__c.toLowerCase())){
                if(!journeyClosedStatus.contains(objJourney.Status__c.toLowerCase())){
                    Id parentOwnerId =  objJourney.Primary_Lead__c != null ?  objJourney.Primary_Lead__r.OwnerId : objJourney.Primary_Contact__r.OwnerId;
                    journeyOwnerId = parentOwnerId; 
                    if((parentOwnerId == Id.valueOf('005F0000003Kmbw') || !Settings.getUserActive(journeyOwnerId)) && objQueue != null){
                        //if associated lead or contact owner is susie or Inactive then assign journey to NMD Unassigned Queue                       
                        journeyOwnerId = objQueue.Queue.Id;
                    }               
                }else{
                    journeyOwnerId =  mapContactOwnerData.get('Id');  
                } 
            }
            if(String.isNotBlank(journeyOwnerId)){
                objJourney.ownerId = journeyOwnerId;
                lstJourneysTobeUpdates.add(objJourney);
            }
        }
        this.updateListRecords(lstJourneysTobeUpdates);        
    }
    
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to assign Tour owner as Susie Romero.
		Created Date		:	15 Nov 2018        
 *************************************************************************************************************************************/ 
    public void setTourOwnerOnUserDeactivation(List<Tour_Outcome__c> lstRecords){
        List<Tour_Outcome__c> lstTourOutcomesTobeUpdated = new List<Tour_Outcome__c>();
        for(Tour_Outcome__c objTour : lstRecords){
            if(String.isNotBlank(objTour.Status__c) && !SetTourStatus.contains(objTour.Status__c.toLowerCase()) && mapContactOwnerData != null && mapContactOwnerData.get('Id') != null){
                objTour.OwnerId = mapContactOwnerData.get('Id'); 
                objTour.User_Deactivation_Updated_On__c = Date.today();
                objTour.Reassignment_On_User_Deactivation__c = true;
                lstTourOutcomesTobeUpdated.add(objTour);
            }
        }
        this.updateListRecords(lstTourOutcomesTobeUpdated);
    }
    
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This method is used to assign Opportunity owner as Susie Romero.
		Created Date		:	15 Nov 2018        
 *************************************************************************************************************************************/ 
    public void setOpportunityOwnerOnUserDeactivation(List<Opportunity> lstRecords){
        List<Opportunity> lstOpportuntiyTobeUpdated = new List<Opportunity>();
        for(Opportunity objOpp : lstRecords){
            if(mapContactOwnerData != null && mapContactOwnerData.get('Id') != null){
                objOpp.OwnerId = mapContactOwnerData.get('Id');
                lstOpportuntiyTobeUpdated.add(objOpp);
            }
        }
        this.updateListRecords(lstOpportuntiyTobeUpdated);
    }
    
    public void updateListRecords(List<sObject> lstRecordsToUpdate){
        if(lstRecordsToUpdate != null && lstRecordsToUpdate.size() > 0){
            Database.update(lstRecordsToUpdate);
        } 
    }
        
 /************************************************************************************************************************************
        Author 				:	Krishana Tupe
        Description 		:	This wrapper class is used to get criterias which are used to decide record is reassigned or not.
		Created Date		:	17 Nov 2017        
 **************************************************************************************************************************************/
    public class RestrictBatchToChangeOwnerSettings {       
        public Set<String> TourStatus;
        public Set<String> JourneyStatus;
        public Set<String> OpportunityStageName;        
    } 
    
}