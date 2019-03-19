/**
* Created By : Dipak Pawar
* Created Date : 2 June 2017
* Comment : Quaueable class for ST-1006 functionality.
*/
public class QueueEmailAlertForOpportunity implements Queueable {
    List<Tour_Outcome__c> triggerNew = new List<Tour_Outcome__c>();
    Map<Id, Tour_Outcome__c> triggerOldMap = new Map<Id, Tour_Outcome__c>();
    Boolean isInsert = false, isUpdate = false;	
	//public static Boolean firstRun = true;    
    //Map<String, Schema.RecordTypeInfo> mapOpportunityRecordTypes = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
    
    public QueueEmailAlertForOpportunity(List<Tour_Outcome__c> triggerNew){
        this.triggerNew = triggerNew;
        this.isInsert = true;
    }
    
    public QueueEmailAlertForOpportunity(List<Tour_Outcome__c> triggerNew, Map<Id, Tour_Outcome__c> triggerOldMap){
        this.triggerNew = triggerNew;
        this.triggerOldMap = triggerOldMap;
        this.isUpdate = true;
    }
    
    public void execute(QueueableContext context) {
        debug.log('In email Queueable');
        try{
        Set<ID> setOfOpp = new Set<ID>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        //String officeSpaceID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Mid Market').getRecordTypeId();
        Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();        
        if(this.isInsert){
            for(Tour_Outcome__c newTourRec : this.triggerNew){
                if(newTourRec.Opportunity__c != null){
                    setOfOpp.add(newTourRec.Opportunity__c);
                }
            }//For Tour Status is Booked i.e Created or Sceduled
            if(!setOfOpp.isEmpty()){
                EmailTemplate et=[SELECT id,Body FROM EmailTemplate WHERE name=:'Mid Market Email After Tour Created'];
                //List<Opportunity> lstOwners =[SELECT Id,Owner.FirstName,Owner.Id,Owner.Email FROM Opportunity WHERE Id IN : setOfOpp AND RecordTypeId =: officeSpaceID];//mapOpportunityRecordTypes.get('Mid Market').getRecordTypeId()];
                List<Opportunity> lstOwners =[SELECT Id,Owner.FirstName,Owner.Id,Owner.Email FROM Opportunity WHERE Id IN : setOfOpp ];//mapOpportunityRecordTypes.get('Mid Market').getRecordTypeId()];
                for(Opportunity oppID : lstOwners){
                    for(Tour_Outcome__c newTourRec : this.triggerNew){
                        if(oppID.Owner.Id != newTourRec.OwnerID){	   	
                            singleMail.setTargetObjectId(oppID.Owner.Id);								
                            singleMail.setWhatId(newTourRec.Id);
                            singleMail.setTemplateId(et.Id);
                            singleMail.setSaveAsActivity(false);
                            emails.add(singleMail);
                        }
                    }
                }  
                if(emails.size() > 0)
                    Messaging.sendEmail(emails);    			 
            }
            //Send Email when Tour Status is Completed,Rescheduled or Cancelled.
        } else if(this.isUpdate){
            debug.log('In Update condition');
            for(Tour_Outcome__c newTourRec : (List<Tour_Outcome__c>) this.triggerNew){
                Tour_Outcome__c oldTour = (Tour_Outcome__c)this.triggerOldMap.get(newTourRec.Id);
                if(newTourRec.Status__c != oldTour.Status__c && newTourRec.Status__c == 'Completed' ){
                    setOfOpp.add(newTourRec.Opportunity__c);
                }
                if(newTourRec.Status__c != oldTour.Status__c && newTourRec.Status__c == 'Cancelled' ){
                    setOfOpp.add(newTourRec.Opportunity__c);
                }
            }
            if(!setOfOpp.isEmpty()){
                EmailTemplate et1 = [SELECT id FROM EmailTemplate WHERE name=:'Mid Market Email After Tour Completed'];
                EmailTemplate et2 = [SELECT Id FROM EmailTemplate WHERE name=: 'Email Alert After Tour Rescheduled'];
                EmailTemplate et3 = [SELECT Id FROM EmailTemplate WHERE name=: 'Email Alert After Tour Cancelled'];
                List<Opportunity> lstOwners =[SELECT Owner.Id,Owner.Email FROM Opportunity where Id IN : setOfOpp]; // Modified by Dipak Pawar for SOQL optimization
                for(Opportunity oppID : lstOwners){
                    for(Tour_Outcome__c newTourRec : (List<Tour_Outcome__c>) this.triggerNew){
                        Tour_Outcome__c oldTour = (Tour_Outcome__c)this.triggerOldMap.get(newTourRec.Id);
                         if((oppID.Owner.Id != newTourRec.OwnerID) && (newTourRec.Status__c != oldTour.Status__c) && (newTourRec.Status__c == 'Completed')){
                            singleMail.setTargetObjectId(oppID.Owner.Id);								
                            singleMail.setWhatId(newTourRec.Id);
                            singleMail.setTemplateId(et1.Id);
                            singleMail.setSaveAsActivity(false);
                            emails.add(singleMail);
                        }                  
                        if((oppID.Owner.Id != newTourRec.OwnerID) && (newTourRec.Status__c != oldTour.Status__c) && (newTourRec.Status__c == 'Cancelled')){          
                            singleMail.setTargetObjectId(oppID.Owner.Id);								
                            singleMail.setWhatId(newTourRec.Id);
                            singleMail.setTemplateId(et3.Id);
                            singleMail.setSaveAsActivity(false);
                            emails.add(singleMail);
                        }
                    }
                }
                if(emails.size() > 0)
                    Messaging.sendEmail(emails);    
            }            
        }
        } catch(Exception ex) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('QueueEmailAlertForOpportunity','execute', 'TriggerNew =>> '+ JSON.serializePretty(this.triggerNew) +' triggerOldMap =>> '+ JSON.serializePretty(triggerOldMap), ex)
            );
        }
    }
}