/* 
* @Created By   	: Mayuresh Ghodke
* @Created Date 	: 11 Dec'16
* @Issue No.		: ST-684
* @Comment			: This class will get call from Process builder. Name : Kickbox API Callout Queueable
					If Kickbox_Verification__c object record get update after 10mins from its creation time.
					then above Proccess builder will get fir and sendKickboxApiRequest() method get call.
					Which will send list of job id to Queueable class 'QueueKickBoxApiRequest' which will send callout request to Kickbox API.
*/

global class KickboxVerificationApiHandlerForBatch {
    //Method will get call from process builder. Name : Kickbox API Callout Queueable
    @InvocableMethod
    global static void sendKickboxApiRequest(List<Id> lstJobId) {        
        Debug.log('In KickboxVerificationTriggerHandler lstJobId ::'+lstJobId);
        //Send to Queueable Method to proccess.
        List<Id> lstId = new List<Id>();
        if(lstJobId!=null && !lstJobId.isEmpty())
        	System.enqueueJob(new QueueKickBoxApiRequest(lstJobId,false));
	}
    //Method will get call from Queueable class 'QueueKickBoxApiRequest' which will send callout request to Kickbox API
    global static void sendKickboxApiRequestQueueforBatch(List<Id> lstJobId) {
        Debug.log('In sendKickboxApiRequestQueue ::'+lstJobId);
        JsonKickboxAPI objJSONKickboxAPI = new JsonKickboxAPI();
        Setting__c RecordJSONKickboxAPI = Settings.get('KickboxAPI');
        //Debug.log('RecordJSONKickboxAPI :: '+ RecordJSONKickboxAPI);
        objJSONKickboxAPI = (JsonKickboxAPI)JSON.deserialize(RecordJSONKickboxAPI.Data__c, JsonKickboxAPI.Class);
        try{
            //Debug.log('objJSONKickboxAPI :: '+objJSONKickboxAPI);
            
            //Fetch require Job to process.
            List<Kickbox_Verification__c> lstKickboxVerificationJobId = [Select Id, From_Date__c, To_Date__c, Generate_Journey__c,Kickbox_API_Request_Send__c,Kickbox_Job_Id__c From Kickbox_Verification__c Where id IN : lstJobId];
            List<Lead> lstLeadCreate = new List<Lead>();
            List<Lead> lstLeadNotCreated = new List<Lead>();
            //Kickbox_Verification__c obj = lstKickboxVerificationJobId[0];
            for(Kickbox_Verification__c obj : lstKickboxVerificationJobId){
               Integer intJobId = Integer.valueof(obj.Kickbox_Job_Id__c);
                objJSONKickboxAPI.API[1].url = objJSONKickboxAPI.API[1].url.replace('{JobId}',String.valueOf(intJobId));
                Debug.log('objJSONKickboxAPI.API[1].url :: '+objJSONKickboxAPI.API[1].url);
                Debug.log('obj :: '+obj);
                
                //Second API call Kickbox with JobId from first API result.
                Http h2 = new Http();
                Debug.log('Kickbox_Job_Id__c :: '+Integer.valueof(obj.get('Kickbox_Job_Id__c')));
                HttpRequest req2 = new HttpRequest();
                req2.setEndpoint(objJSONKickboxAPI.API[1].url+''+objJSONKickboxAPI.API[1].apikey);
                req2.setMethod('GET');
                HttpResponse res2 = h2.send(req2);
                Debug.log('Response in RESTKickboxCallbcak res2.getBody() :: '+res2.getBody());
                KickboxResponseTwo response2 = (KickboxResponseTwo)JSON.deserialize(res2.getBody(), KickboxResponseTwo.class);
                Debug.log('Response in RESTKickboxCallbcak :: '+response2);
                
                //Third API call Kickbox with result URL of Second API.
                Http h3 = new Http();
                HttpRequest req3 = new HttpRequest();
                req3.setEndpoint(response2.download_url);
                req3.setMethod('GET');
                HttpResponse res3 = h3.send(req3);
                string response3 = res3.getBody();
                Debug.log('Response in RESTKickboxCallbcak res3.getBody() :: '+res3.getBody());//In CSV Format
                Debug.log('response3 :: '+response3);
                
                Attachment objAttachment = new Attachment();
                objAttachment.Name = 'Batch Kickbox Response';
                objAttachment.IsPrivate = false;
                objAttachment.ContentType = 'text/csv';
                objAttachment.Body =  Blob.valueof(res3.getBody());
                objAttachment.OwnerId = UserInfo.getUserId();
                objAttachment.ParentId = obj.Id;
                insert objAttachment;
                
                //Clear all CSV file.
                String target = '"';
                response3 = response3.replace(target, '');
                String nameFile = response3;
                List<String> filelines = nameFile.split('\n');
                
                List<Contact> lstContactToUpdate = new List<Contact>();
                List<Lead> lstLeadToUpdate = new List<Lead>();
                for (Integer i=1;i<filelines.size();i++){
                    String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
                    Debug.log('inputvalues[0] :: '+inputvalues[0]);
                    Debug.log('inputvalues[0].length() :: '+inputvalues[0].length());
                    //Check 1st value is Id or not
                    if(inputvalues[0].length() == 15 || inputvalues[0].length() == 18 ){ 
                        //Check Id is of Lead or Contact
                        if(inputvalues[0].startsWith('00Q')){
                            Lead objLead = new Lead();
                            objLead.Id = inputvalues[0];
                            //objLead.Email = inputvalues[1];
                            //Added By Shobhit Gahlot as the response from kickboxapi has changed from sending values at 3 previously was sending in column 2
                            if(inputvalues[2] != '' && (inputvalues[2].toLowerCase() == 'risky' || inputvalues[2].toLowerCase() == 'deliverable' || inputvalues[2].toLowerCase() == 'undeliverable'))
                                objLead.Email_Quality__c = inputvalues[2];
                            else if(inputvalues[3] != '' && (inputvalues[3].toLowerCase() == 'risky' || inputvalues[3].toLowerCase() == 'deliverable' || inputvalues[3].toLowerCase() == 'undeliverable'))
                                objLead.Email_Quality__c = inputvalues[3];
                            lstLeadToUpdate.add(objLead);
                        }
                        else{
                            Contact con = new Contact();
                            con.Id = inputvalues[0];
                            //Added By Shobhit Gahlot as the response from kickboxapi has changed from sending values at 3 previously was sending in column 2
                            if(inputvalues[2] != '' && (inputvalues[2].toLowerCase() == 'risky' || inputvalues[2].toLowerCase() == 'deliverable' || inputvalues[2].toLowerCase() == 'undeliverable'))
                                con.Email_Quality__c = inputvalues[2];
                            else if(inputvalues[3] != '' && (inputvalues[3].toLowerCase() == 'risky' || inputvalues[3].toLowerCase() == 'deliverable' || inputvalues[3].toLowerCase() == 'undeliverable'))
                                con.Email_Quality__c = inputvalues[3];
                            lstContactToUpdate.add(con);
                        }
                    }
                }
                Debug.log('lstContactToUpdate :: '+lstContactToUpdate);
                Debug.log('lstLeadToUpdate :: '+lstLeadToUpdate);
                Map<Id,Contact> mapContactToUpdate = new Map<Id,Contact>();
                if(lstContactToUpdate!=null && !lstContactToUpdate.isEmpty())
                    for(Contact objCon : lstContactToUpdate)
                        mapContactToUpdate.put(objCon.Id,objCon);
                
                Map<Id,Lead> mapLeadToUpdate = new Map<Id,Lead>();
                if(lstLeadToUpdate!=null && !lstLeadToUpdate.isEmpty())
                    for(Lead objLead : lstLeadToUpdate)
                        mapLeadToUpdate.put(objLead.Id,objLead);
                
                Debug.log('mapContactToUpdate :: '+mapContactToUpdate);
                Debug.log('mapLeadToUpdate :: '+mapLeadToUpdate);
                
                //Update Related Contacts Email Quality
                if(lstContactToUpdate!=null && !lstContactToUpdate.isEmpty()){
                    List<Contact> lstContactToUpdateEmailQuality = new List<Contact>();
                    lstContactToUpdateEmailQuality = [Select Id, Email_Quality__c From Contact Where Id IN : lstContactToUpdate];
                    for(Contact objCon : lstContactToUpdateEmailQuality){
                        Contact con = mapContactToUpdate.get(objCon.Id);
                        objCon.Email_Quality__c = con.Email_Quality__c;
                        Debug.log('objCon :: '+objCon);
                    }
                    update lstContactToUpdateEmailQuality;
                    Debug.log('lstContactToUpdateEmailQuality :: '+lstContactToUpdateEmailQuality);
                }
                
                //Update Related Leads Email Quality
                if(lstLeadToUpdate!=null && !lstLeadToUpdate.isEmpty()){
                    List<Lead> lstLeadToUpdateEmailQuality = new List<Lead>();
                    lstLeadToUpdateEmailQuality = [Select Id, Email_Quality__c From Lead Where Id IN : lstLeadToUpdate];
                    for(Lead objLead : lstLeadToUpdateEmailQuality){
                        Lead con = mapLeadToUpdate.get(objLead.Id);
                        objLead.Email_Quality__c = con.Email_Quality__c;
                        Debug.log('objLead :: '+objLead);
                    }
                    update lstLeadToUpdateEmailQuality;
                    Debug.log('lstLeadToUpdateEmailQuality :: '+lstLeadToUpdateEmailQuality);
                }
                //Update Kickbox Verification record
                obj.Kickbox_API_Request_Send__c = true;
                obj.Daily_Batch_Run_Successfully__c = true;
                
                update obj;
                //Send Email notification to User
                Debug.log('objJSONKickboxAPI.BatchRunEmailNotify check:: '+objJSONKickboxAPI.BatchRunEmailNotify);
                Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                String[] toAddresses = new list<string>();
                for(String emailId : objJSONKickboxAPI.BatchRunEmailNotify)
                    toAddresses.add(emailId);
                Debug.log('toAddresses :: '+toAddresses);
                String subject;
                if(lstKickboxVerificationJobId[0].From_Date__c != null && lstKickboxVerificationJobId[0].To_Date__c != null)
                    subject ='Kickbox Verification Batch Run Successfully  : '+lstKickboxVerificationJobId[0].From_Date__c+' To '+lstKickboxVerificationJobId[0].To_Date__c;
                else
                    subject ='Kickbox Verification Batch Run Successfully  : '+Date.today();
                email.setSubject(subject);
                email.setToAddresses( toAddresses );
                
                if(lstKickboxVerificationJobId[0].From_Date__c != null && lstKickboxVerificationJobId[0].To_Date__c != null)
                    email.setHtmlBody('Hello, <br/><br/> Kickbox verification for the Leads and Contacts created on '+lstKickboxVerificationJobId[0].From_Date__c+' To '+lstKickboxVerificationJobId[0].To_Date__c+' is successfully completed.<br/> For complete information please find the attachments on the below record. <br/> URL of the record : '+System.Url.getSalesforceBaseUrl().toExternalForm()+'/'+obj.Id+'<br/><br/> Thank you.');
                else
                    email.setHtmlBody('Hello, <br/><br/> Kickbox verification for the Leads and Contacts are successfully completed.<br/> For complete information please find the attachments on the below record. <br/> URL of the record : '+System.Url.getSalesforceBaseUrl().toExternalForm()+'/'+obj.Id+'<br/><br/> Thank you.');
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        	}
        }
        catch(Exception exc){
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string>();
            for(String emailId : objJSONKickboxAPI.BatchRunEmailNotify)
                toAddresses.add(emailId);
            Debug.log('toAddresses :: '+toAddresses);
            String subject;
            subject ='Batch Run for Kickbox Verification failed : '+Date.today();
            EmailTemplate failureEmail = [select Id,Body From EmailTemplate where Name = 'Leads Batch_Failure'];
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            //email.setHtmlBody('Hello, <br/><br/> Kickbox verification for the Leads and Contacts are in progress.<br/> For complete information please find the attachments on the below record. <br/> URL of the record : '+System.Url.getSalesforceBaseUrl().toExternalForm()+'/'+lstKickboxVerificationIds[0]+'<br/><br/> Thank you.');
            //email.setHtmlBody('Hello , <br/><br/> Todays batch run gets call. Please find below tracking Ids. <br/>'+lstKickboxVerificationIds+'<br/><br/> Thank you.');
            String htmlBodyFail = failureEmail.Body;
	        htmlBodyFail = htmlBodyFail.replace(']]>', '');
            email.setPlainTextBody(htmlBodyFail);
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }
    global class stats{
        public Decimal deliverable {get;set;}
        public Decimal undeliverable{get;set;} 
        public Decimal risky{get;set;}
        public Decimal unknown{get;set;}
        public Decimal sendex{get;set;}
        public Decimal addresses{get;set;}
    }
    
    global class KickboxResponseTwo{
        public String id {get;set;}
        public String name{get;set;}
        public String download_url{get;set;}
        public stats stats{get;set;}
        //public List<Resultstats> stats;
        public String created_at{get;set;}
        public String status{get;set;}
        public String error{get;set;} 
        public String duration{get;set;}
        
        public String success{get;set;} 
        public String message{get;set;}                   
    }
    global class BatchDates {
		public String FromDate;
		public String ToDate;
	}

	global class API {
		public String Name;
		public String url;
		public String apikey;
	}

	global class Attachments {
		public String ParentId;
		public String Message;
	}
    global class JsonKickboxAPI {
        public List<API> API;
        public Attachments Attachments;
        public BatchDates BatchDates;
        public Set<String> EmailQuality;
        public List<String> BatchRunEmailNotify;
	}
}