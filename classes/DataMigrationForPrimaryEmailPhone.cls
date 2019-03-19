/*
*   Created By      : Shobhit Gahlot
*   Created Date    : 09-10-2017
*   Issue			: St-1514
*   Summary         : This is batch to update Primary Email and Primary Phone on Journey
					  To run this following code is required to be exeuted from anonymous 
					  window 
					  Database.executeBatch(new DataMigrationForPrimaryEmailPhone());
*/

global class DataMigrationForPrimaryEmailPhone implements Database.batchable<sObject>,Database.Stateful{
    global final String Query;
    global final List<Id> lstJourneyIdsFailed = new List<Id>();
    global DataMigrationForPrimaryEmailPhone()
    {
        Query='SELECT Id, Primary_Email__c, Primary_Phone__c, Primary_Contact__c, Primary_Lead__c, Primary_Lead__r.Email, Primary_Lead__r.Phone, Primary_Contact__r.Email, Primary_Contact__r.Phone from Journey__c';
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext context, List<Journey__c> scope) {
        Set<Id> setRelatedLeads = new Set<Id>();
        Set<Id> setRelatedContacts = new Set<Id>();
        Set<Id> setleadIds = new Set<Id>();
        Set<Id> setContactIds = new Set<Id>();
        
        for(Journey__c objJourney : scope){
            if(objJourney.Primary_Lead__c != null)
                setRelatedLeads.add(objJourney.Primary_Lead__c);
            else
                setRelatedContacts.add(objJourney.Primary_Contact__c);
        }
        if(setRelatedLeads!= null && setRelatedLeads.size() > 0){
            List<Lead> lstPrimaryLead = [Select Id From Lead Where Id IN : setRelatedLeads];
            if(lstPrimaryLead!= null && lstPrimaryLead.size() > 0){
                for(Lead obj : lstPrimaryLead)
            		setleadIds.add(obj.Id);
            }
        }
		
		if(setRelatedContacts!= null && setRelatedContacts.size() > 0){
            List<Contact> lstPrimaryContact = [Select Id From Contact Where Id IN : setRelatedContacts];
            if(lstPrimaryContact!= null && lstPrimaryContact.size() > 0){
                for(Contact obj : lstPrimaryContact)
            		setContactIds.add(obj.Id);
            }
        }   
        Debug.log('setleadIds :: '+setleadIds);
        Debug.log('setContactIds :: '+setContactIds);
        List<Journey__c> lstJourneys = new List<Journey__c>();
        try{
            for(Journey__c objJourney : scope){
                if(objJourney.Primary_Contact__c != null && setContactIds.contains(objJourney.Primary_Contact__c)){
                    if(objJourney.Primary_Contact__r.Email != null)
                        objJourney.Primary_Email__c = objJourney.Primary_Contact__r.Email;
                    if(objJourney.Primary_Contact__r.Phone != null)
                        objJourney.Primary_Phone__c = objJourney.Primary_Contact__r.Phone;
                }else{
                    if(objJourney.Primary_Lead__c != null && setleadIds.contains(objJourney.Primary_Lead__c)){
                        if(objJourney.Primary_Lead__r.Email != null)
                        	objJourney.Primary_Email__c = objJourney.Primary_Lead__r.Email;
                    	if(objJourney.Primary_Lead__r.Phone != null)
                        	objJourney.Primary_Phone__c = objJourney.Primary_Lead__r.Phone;  
                    }
                }
                lstJourneys.add(objJourney);
            }
            Debug.log('lstJourneys :: '+lstJourneys.size());
            if(lstJourneys != null && lstJourneys.size() > 0){
                set<Id> setSuccessfullIds = new set<Id>();
                set<Id> setUnSuccessfullIds = new set<Id>();
                for(Journey__c j: lstJourneys)
                    debug.log('update joureney records ::'+ j);
                
                Database.SaveResult[] srList = Database.update(lstJourneys,false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                         setSuccessfullIds.add(sr.getId());
                         debug.log('sr.getId() :: '+sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            debug.log('The following error has occurred.');                    
                            debug.log(err.getStatusCode() + ': ' + err.getMessage());
                            debug.log('Journey fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                
                for(Journey__c j : lstJourneys){
                    if(setSuccessfullIds !=null &&  !setSuccessfullIds.contains(j.id))
                        lstJourneyIdsFailed.add(j.Id);
                }
                debug.log('lstJourneyIdsFailed ::' +lstJourneyIdsFailed);
            }
            
        }catch(Exception ex){
            Messaging.SingleEmailMessage emailsuccess =new Messaging.SingleEmailMessage();
            emailsuccess.setHtmlBody('Hello All, <br/>Something went wrong while running batch for data migration.<br/> Following Error has occured.<br/><br/>'+ ex.getMessage()+'<br/><br/> On Line number : '+ex.getLineNumber()+'<br/><br/> Complete StackTrace : '+ex.getStackTraceString()+'<br/>   Thank you.');
            
            String[] toAllAddresses = new list<string>();
            toAllAddresses.add('shobhit.gahlot@enzigma.com');
            //toAllAddresses.add('parag.vyas@enzigma.com');
            
            String subject ='Data Migration for Primary Email and Primary Phone on journey';
            emailsuccess.setSubject(subject);
            emailsuccess.setToAddresses(toAllAddresses);
            emailsuccess.setSaveAsActivity(false);
            
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailsuccess});
        }      

    }
    global void finish(Database.BatchableContext context) {
        Messaging.SingleEmailMessage emailsuccess =new Messaging.SingleEmailMessage();
        string htmlBody ='Hello All, <br/>Data migration is complete.<br /> Thank you.<br />';
        if(lstJourneyIdsFailed !=null && lstJourneyIdsFailed.size()>0){
            htmlBody +='<h4>Below is the list of failed Journeys</h4>';
            htmlBody += '<table style="border:1px solid;border-collapse: collapse;" width="50%"><tr style="background-color:black;color:#ffffff;"><th>Sr. No</th><th>Journey Id</th></tr>';
            Integer srNo = 1;
            for(Id failId: lstJourneyIdsFailed){
                htmlBody +='<tr><td style="border:1px solid;">'+srNo+'</td><td style="border:1px solid;">'+failId+'</td></tr>';
                srNo++;   
            }
            htmlBody +='</table>';
        }
        emailsuccess.setHtmlBody(htmlBody);
            String[] toAllAddresses = new list<string>();
            toAllAddresses.add('shobhit.gahlot@enzigma.com');
            toAllAddresses.add('parag.vyas@enzigma.com');
        	toAllAddresses.add('wework@enzigma.com');
            
            String subject ='Data Migration for Primary Email and Primary Phone on journey';
            emailsuccess.setSubject(subject);
            emailsuccess.setToAddresses(toAllAddresses);
            emailsuccess.setSaveAsActivity(false);
            
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailsuccess});
    }
}