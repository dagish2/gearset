/**  
* @Created By   	: Dipak Pawar
* @Changes By		: Mayuresh Ghodke
* @Created Date 	: 30-November-2016
* @Issue No.		: ST-684. And Cover Test methods in KickboxVerificationTest Apex class.
					: ST-1367. Batch Criteria changed
*/ 
// To run normally daily batch run script : Id batjobId = Database.executeBatch(new CheckEmailQuality('LeadString','ContactString',true));
// For Datewise batch run script : KickboxVerificationController.kickboxVerificationRunBatchClass.();
global class CheckEmailQuality implements Database.Batchable<SObject>, Database.AllowsCallouts,Database.Stateful  {
	global String leadQuery; //Fetch Leads 
    global String contactQuery; //Fetch Contacts
    public string nameFile;
    public Blob contentFile;
    global List<Id> lstKickboxVerificationIds = new List<Id>();
    String[] filelines = new String[]{};
    List<Contact> lstContactToUpdate;
    global JsonKickboxAPI objJSONKickboxAPI = new JsonKickboxAPI();
    global DateTime FromDate = null;
    global DateTime ToDate = null;
    global boolean properDate = true;
    global boolean regularBatchFlag;
	global CheckEmailQuality(String leadQueryString, String contactQueryString, Boolean regularBatch) {
        String emailQuality = 'pending';
        String emailQuality1 = 'Pending';
        regularBatchFlag = regularBatch;
		leadQuery = leadQueryString;
        contactQuery = contactQueryString;
        Debug.log('leadQuery :: '+leadQuery);
        Setting__c RecordJSONKickboxAPI = Settings.get('KickboxAPI');
    	objJSONKickboxAPI = (JsonKickboxAPI)JSON.deserialize(RecordJSONKickboxAPI.Data__c, JsonKickboxAPI.Class);
    	Debug.log('objJSONKickboxAPI :: '+objJSONKickboxAPI);
        Debug.log('regularBatch :: '+regularBatch);
        if(!regularBatch){
            String dayFromDate = objJSONKickboxAPI.BatchDates.FromDate;
            String dayToDate = objJSONKickboxAPI.BatchDates.ToDate;
            Boolean fromDateFormat =dayFromDate.contains('-');
            Boolean dayToDateFormat =dayToDate.contains('-');
            Debug.log('dayToDateFormat :: '+dayToDateFormat);
            Debug.log('fromDateFormat :: '+fromDateFormat);
            if(fromDateFormat && dayToDateFormat){
                List<String> dateParts = dayFromDate.split('-');
                Debug.log('dateParts :: '+dateParts);
                Debug.log('dateParts :: '+Integer.valueOf(dateParts[2])); //2016
                Debug.log('dateParts :: '+Integer.valueOf(dateParts[1])); //12
                Debug.log('dateParts :: '+Integer.valueOf(dateParts[0])); //07
                //FromDate = Datetime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
                
				FromDate = Datetime.newInstance(Integer.valueOf(dateParts[2]),Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
                Debug.log('FromDate :: '+FromDate);
                
                List<String> datePart = dayToDate.split('-');
                //ToDate = Datetime.newInstance(Integer.valueOf(datePart[0]), Integer.valueOf(datePart[1]), Integer.valueOf(datePart[2]));
                ToDate = Datetime.newInstance(Integer.valueOf(datePart[2]),Integer.valueOf(datePart[0]), Integer.valueOf(datePart[1]));
                Debug.log('ToDate :: '+ToDate);
                integer intDays =  FromDate.Date().daysBetween(ToDate.Date());
                Debug.log('intDays :: '+intDays);
                
                if(intDays < 1){
                    properDate = false;
                    Debug.log('properDate :: '+properDate);
                }
                
                leadQuery = 'Select id,email from Lead where Lead.CreatedDate > FromDate and Lead.CreatedDate < ToDate AND Email_Quality__c =\''+emailQuality+'\' AND isConverted = false';
                contactQuery = 'Select id,email from Contact where Contact.CreatedDate > FromDate and Contact.CreatedDate < ToDate AND Email_Quality__c =\''+emailQuality+'\'';
            }
            else{
                properDate = false;
            }
        }
        else{
            //and Daily_Batch_Run_Successfully__c = false and Generate_Journey__c = false
            //Changes Made By : Shobhit Gahlot
            //Issue No		  : ST-1367
            //Comment 		  : Here we fetch kickboxVerification records where  Used_Re_Architect_Logic__c which is set in 
            //                  execute method of this class we Daily_Batch_Run_Successfully__c is set to true in 
            //                  KickboxVerificationApiHandlerForBatch class only if the batch was run successfully
            //                  so we find out for last how many days the batch class was not successfull and get leads and
            //                  contacts for all previous days when the batch was unsuccessful.		    
            /*List<Kickbox_Verification__c> lstkickboxverifification = [SELECT Id, Name, Daily_Batch_Run_Successfully__c, Used_Re_Architect_Logic__c FROM Kickbox_Verification__c where Used_Re_Architect_Logic__c = true ORDER BY createdDate DESC];
            Integer lastNdays = 0;//number of days for which batch was successful
            Debug.log('lstkickboxverifification ::'+lstkickboxverifification);
            if(lstkickboxverifification.size() > 0 && lstkickboxverifification != null){
                for(Kickbox_Verification__c objKickbox : lstkickboxverifification){
                    if(objKickbox.Daily_Batch_Run_Successfully__c == false)
                        lastNdays++;
                    else
                        break;
                }
            }
            Debug.log('lastNdays :: '+lastNdays);
            if(lastNdays > 0){
                leadQuery = 'Select id,email from Lead where Email_Quality__c = pending AND isConverted = false Limit 5';
            	contactQuery = 'Select id,email from Contact where Email_Quality__c = pending Limit 5';
            	Debug.log('leadQuery with n number of days :: '+leadQuery);
                Debug.log('contactQuery with n number of days :: '+contactQuery);
            }else{*/
            
                leadQuery = 'Select id,email from Lead where (Email_Quality__c =\''+emailQuality+'\' OR Email_Quality__c =\''+emailQuality1+'\' )AND isConverted = false';
            	contactQuery = 'Select id,email from Contact where (Email_Quality__c =\''+emailQuality+'\' OR Email_Quality__c =\''+emailQuality1+'\' )';
            //}
            
            Debug.log('leadQuery :: '+leadQuery);
            Debug.log('contactQuery display :: '+contactQuery);
        }
    }
	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */ 
	global List<sObject> start(Database.BatchableContext context) {
        List<sObject> lstEmailIds = new List<sObject>();
        Debug.log('In start properDate :: '+properDate);
        if(properDate){
            if(FromDate != null && ToDate != null){
                String dateToDate = String.valueOf(ToDate);
                dateToDate = dateToDate.replace(' ', 'T') + 'Z';
                String dateFromDate = String.valueOf(FromDate);
                dateFromDate = dateFromDate.replace(' ', 'T') + 'Z';
                leadQuery = leadQuery.replace('ToDate', dateToDate);
                leadQuery = leadQuery.replace('FromDate',dateFromDate);
                contactQuery = contactQuery.replace('ToDate', dateToDate);
                contactQuery = contactQuery.replace('FromDate',dateFromDate);
            }
            Database.QueryLocator lstLead = Database.getQueryLocator(leadQuery);
            Debug.log('lstLead :: '+lstLead);
            
            Database.QueryLocator lstContact = Database.getQueryLocator(contactQuery);
            Debug.log('lstContact :: '+lstContact);
            
            Database.QueryLocatorIterator itLead =  lstLead.iterator();
            // Iterate over the Lead records
            while (itLead.hasNext()){
                Lead objLead = (Lead)itLead.next();
                lstEmailIds.add(objLead);
                Debug.log('lead ::'+objLead);
            }
            
            Database.QueryLocatorIterator itContact =  lstContact.iterator();
            // Iterate over the Contact records
            while (itContact.hasNext()){
                Contact objContact = (Contact)itContact.next();
                lstEmailIds.add(objContact);
                Debug.log('Contact ::'+objContact);
            }
            Debug.log('lstEmailIds ::'+lstEmailIds);
    	}
        return lstEmailIds;
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<sObject> scope) {
        Debug.log('In execute :: '+context);
        Debug.log('In execute scope:: '+scope);

        try{
            Debug.log('In execute properDate :: '+properDate);
              if(properDate){  
                Debug.log('scope :: '+scope);
                //Create CSV format
                string header = 'Id, Email\n';
                string finalstr = header;        
                for(sObject objEmailId : scope){
                    string recordString = String.valueOf( objEmailId.get('Id') ) + ',';
                    recordString = recordString + String.valueOf( objEmailId.get('Email') ) + '\n';
                    finalstr = finalstr + recordString;
                }
                Debug.log('finalstr :: '+finalstr);
                Debug.log('Blob.valueOf(finalstr) :: '+String.valueOf((Blob.valueOf(finalstr).size())));
                
                //First API call Kickbox with CSV file content.
                Http h1 = new Http();
                HttpRequest req1 = new HttpRequest();
                req1.setEndpoint(objJSONKickboxAPI.API[0].url+''+objJSONKickboxAPI.API[0].apikey);
                req1.setMethod('PUT');
                req1.setHeader('Content-Type','text/csv');
                req1.setBody(finalstr);
                HttpResponse res1 = h1.send(req1);
                KickboxResponseOne response1 = (KickboxResponseOne)JSON.deserialize(res1.getBody(), KickboxResponseOne.class);
                Debug.log('response1 :: '+response1);
                
                //Insert Job Id
                Kickbox_Verification__c objKickboxVerification = new Kickbox_Verification__c();
                objKickboxVerification.Kickbox_Job_Id__c = decimal.valueOf(response1.id);
                objKickboxVerification.Create_From_Journey_Importer__c = false;
                    Debug.log('system.now() :: '+system.now() );
                // Set as -50 to run workflow after 10mins when record gets created.
                objKickboxVerification.Call_Kickbox_API_After_10_minutus__c = system.now().addMinutes(-50);
                objKickboxVerification.Used_Re_Architect_Logic__c = true;
                if(!regularBatchFlag){
                    objKickboxVerification.From_Date__c = FromDate;
                    objKickboxVerification.To_Date__c = ToDate;
                }
                insert objKickboxVerification;
                  Debug.log(' objKickboxVerification :: '+objKickboxVerification);
                lstKickboxVerificationIds.add(objKickboxVerification.id);
                Attachment objAttachment = new Attachment();
                objAttachment.ParentId = objKickboxVerification.id;
                objAttachment.OwnerId = UserInfo.getUserId();
                objAttachment.Body = Blob.valueof(finalstr);
                objAttachment.Name = 'Batch Kickbox Request';
                objAttachment.ContentType = 'text/csv';
                insert objAttachment;
                
                Debug.log('objKickboxVerification.CreatedDate :: '+objKickboxVerification.CreatedDate );
                Debug.log('objKickboxVerification :: '+objKickboxVerification.id);
              }
        }
        catch(Exception exc){
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string>();
            for(String emailId : objJSONKickboxAPI.BatchRunEmailNotify)
                toAddresses.add(emailId);
            Debug.log('toAddresses :: '+toAddresses);
            if(toAddresses.size() > 0){
                String subject;
                if(regularBatchFlag)
                    subject ='Batch Run for Kickbox Verification failed : '+Date.today();
                else
                    subject ='Batch Run for Kickbox Verification failed :'+FromDate+' To '+ToDate;
                
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
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
        Debug.log('In finish properDate :: '+properDate);
        if(properDate){
            //Send email notification to user fir Kickbox Verification Id
            Debug.log('finish lstKickboxVerificationIds :: '+lstKickboxVerificationIds);
            //Leads Batch_In_Progress
            EmailTemplate emailInProgress = [select Id,Body From EmailTemplate where Name = 'Leads Batch_In_Progress'];
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string>();
            for(String emailId : objJSONKickboxAPI.BatchRunEmailNotify)
                toAddresses.add(emailId);
            Debug.log('toAddresses :: '+toAddresses);
            String subject;
            if(regularBatchFlag)
            	subject ='Batch Run for Kickbox Verification : '+Date.today();
            else
                subject ='Batch Run for Kickbox Verification :'+FromDate+' To '+ToDate;
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            
            String htmlBodyFail = emailInProgress.Body;
            String urls = '';
            for(Id obj :lstKickboxVerificationIds){
                if(urls != '')
                	urls = urls + System.Url.getSalesforceBaseUrl().toExternalForm()+'/'+obj+'\n';
            	else
					urls = '\n'+System.Url.getSalesforceBaseUrl().toExternalForm()+'/'+obj+'\n';
                Debug.log('urls :: '+urls);
            } 
            Debug.log('lstKickboxVerificationIds :: '+lstKickboxVerificationIds);
			htmlBodyFail = htmlBodyFail.replace('URL_Record', urls);
	        htmlBodyFail = htmlBodyFail.replace(']]>', '');
            email.setPlainTextBody(htmlBodyFail);
            //email.setHtmlBody('Hello, <br/><br/> Kickbox verification for the Leads and Contacts are in progress.<br/> For complete information please find the attachments on the below record. <br/> URL of the record : '+System.Url.getSalesforceBaseUrl().toExternalForm()+'/'+lstKickboxVerificationIds[0]+'<br/><br/> Thank you.');
            //email.setHtmlBody('Hello , <br/><br/> Todays batch run gets call. Please find below tracking Ids. <br/>'+lstKickboxVerificationIds+'<br/><br/> Thank you.');
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
        else{
            Id userId = UserInfo.getUserId();
            User objUser = [Select Id,Email, FirstName From user Where id =: userId];
            //
            EmailTemplate failureEmailInvalidDate = [select Id,Body From EmailTemplate where Name = 'Leads Batch_Failure Invalid Date Format'];
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string>();
            for(String emailId : objJSONKickboxAPI.BatchRunEmailNotify)
                toAddresses.add(emailId);
            Debug.log('toAddresses :: '+toAddresses);
            toAddresses.add(objUser.Email);
            String subject ='Kickbox Verification Batch Run failed : Invalid Date Format';
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            String htmlBodyFail = failureEmailInvalidDate.Body;
	        htmlBodyFail = htmlBodyFail.replace(']]>', '');
            //email.setHtmlBody('Hello, <br/><br/>Kickbox Verification Batch Run failed because of the invalid date format. The format should be "mm-dd-yyyy". Or check From Date and To Date. To Date should be greater than From Date.<br/><br/> Thank you.');
            email.setPlainTextBody(htmlBodyFail);
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
	}
    public class KickboxResponseOne{
        public String id {get;set;}
        public String success{get;set;} 
        public String message{get;set;}
    }
    public class BatchDates {
		public String FromDate;
		public String ToDate;
	}

	public class API {
		public String Name;
		public String url;
		public String apikey;
	}

	public class Attachments {
		public String ParentId;
		public String Message;
	}
    public class JsonKickboxAPI {
        public List<API> API;
        public Attachments Attachments;
        public BatchDates BatchDates;
        public Set<String> EmailQuality;
        public List<String> BatchRunEmailNotify;
	}
}