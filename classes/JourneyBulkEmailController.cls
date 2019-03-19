global class JourneyBulkEmailController {
   public static List<Journey__c> lstJourney = new List<Journey__c>();
    public Map<string,List<EmailTemplate>> mapEmailTemplate {get; set;}
    public static Map<string,List<EmailTemplate>> mapEmailTemplateRet {get; set;}
    public String getLstJourney() {
        return null;
    } 
    
    /*
    @Name       : Mayuresh Ghodke
    @Date       : 25-08-16
    @Comment    : Send List of folders and related Email Templates.
    */
    public JourneyBulkEmailController() {
        /*List<EmailTemplate> lstEmailTemplates = [SELECT Name, Folder.Id,Folder.name, Id FROM EmailTemplate order by Name]; 
            mapEmailTemplate = new Map<string,List<EmailTemplate>>();  
            
            for(EmailTemplate currentEmailTemplate : lstEmailTemplates) { 
                if(currentEmailTemplate.Folder.name != null) {
                    if(mapEmailTemplate.containsKey(currentEmailTemplate.Folder.name)) {
                    List<EmailTemplate> lstEmailTemplate =  mapEmailTemplate.get(currentEmailTemplate.Folder.name);
                    lstEmailTemplate.add(currentEmailTemplate);
                    mapEmailTemplate.put(currentEmailTemplate.Folder.name,lstEmailTemplate);
                    }
                    else {
                        List<EmailTemplate> lstEmailTemplate = new List<EmailTemplate>();
                        lstEmailTemplate.add(currentEmailTemplate);
                        mapEmailTemplate.put(currentEmailTemplate.Folder.name,lstEmailTemplate);
                    }
                }   
            }
            Debug.log('mapEmailTemplate :: '+mapEmailTemplate); */
    }
    
    /*
    @Name       : Mayuresh Ghodke
    @Date       : 25-08-16
    @Comment    : Fetch selected email template's Body or HTML containt.
    */
    //@RemoteAction
   global static EmailTemplate fetchEmailTemplate(Id emailTemplateId) {
       /* // query the template body based on selected template
        EmailTemplate t = [select Id, HtmlValue, Body, Subject From EmailTemplate where Id =: emailTemplateId];
        Debug.log('EmailTemplate :: '+t);*/
        return null;//t;
    }
    
    /*
    @Name       : Mayuresh Ghodke
    @Date       : 25-08-16
    @Comment    : Send selected Email to journies lead or contact with selected email template.
    */
    @RemoteAction
    global static String sendEmail(Id emailTemplateId,String lstJtourneyId) {
       /* try{
            Debug.Log('lstJtourneyId ::'+lstJtourneyId);
            Debug.Log('emailTemplateId ::'+emailTemplateId);
            
            Set<Id> setJourneyId = new Set<Id>();
            
            for(String key : lstJtourneyId.split(',')){
                setJourneyId.add(key);
            }
            Debug.Log('setJourneyId ::'+setJourneyId);
            
            List<Journey__c> lstJourneyToSendEmail = new List<Journey__c>([Select Id,Name,Primary_Contact__c,Primary_Lead__c From Journey__c Where Id IN : setJourneyId]);
            Debug.Log('lstJourneyToSendEmail ::'+lstJourneyToSendEmail);
            
            Set<Id> setContactJourney = new Set<Id>();
            Set<Id> setLeadJourney = new Set<Id>();
            
            if(lstJourneyToSendEmail!=null && !lstJourneyToSendEmail.isEmpty())
                for(Journey__c journey : lstJourneyToSendEmail){
                    if(journey.Primary_Contact__c != null){
                        setContactJourney.add(journey.Primary_Contact__c);
                    }
                    if(journey.Primary_Lead__c != null){
                        setLeadJourney.add(journey.Primary_Lead__c);
                    }
                }
            Debug.Log('setContactJourney ::'+setContactJourney);
            Debug.Log('setLeadJourney ::'+setLeadJourney);*/
            
            /*List<Contact> lstContactToSendEmail = new List<Contact>([SELECT Id,Name,Email FROM Contact Where Id IN : setContactJourney]);
            List<Lead> lstLeadToSendEmail = new List<Lead>([SELECT Id,Name,Email FROM Lead Where Id IN : setLeadJourney]);
            Debug.Log('lstContactToSendEmail ::'+lstContactToSendEmail);
            Debug.Log('lstLeadToSendEmail ::'+lstLeadToSendEmail); */
           /* EmailTemplate t = [select Id, TemplateType From EmailTemplate where Id =: emailTemplateId];
            if(t.TemplateType == 'visualforce'){
            	Debug.Log(':: Send Email From Single Email ::');
	            List<Messaging.SingleEmailMessage> allEmailToSend = new List<Messaging.SingleEmailMessage>();
	            if(setContactJourney!=null && !setContactJourney.isEmpty())
	                for(Id con : setContactJourney){
	                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	                    mail.setTemplateID(emailTemplateId); 
	                    mail.setSaveAsActivity(false);
	                    mail.setTargetObjectId(con);
	                    allEmailToSend.add(mail);
	                }
	            
	            if(setLeadJourney!=null && !setLeadJourney.isEmpty())
	                for(Id lead : setLeadJourney){
	                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	                    mail.setTemplateID(emailTemplateId); 
	                    mail.setSaveAsActivity(false);
	                    mail.setTargetObjectId(lead);
	                    allEmailToSend.add(mail);
	                }
	                
	            Debug.Log('allEmailToSend ::'+allEmailToSend);
	            Messaging.sendEmail(allEmailToSend,false);
                return 'Email Send Successfully.';
            }
            else{
            	Debug.Log(':: Send Email From Mass Email ::');
	            List<Id> lstTargetIds = new List<Id>();
	            if(setContactJourney!=null && !setContactJourney.isEmpty())
	                lstTargetIds.addAll(setContactJourney);
	            
	                
	            Boolean sendContactEmail = true;
                Boolean sendLeadEmail = true;
                if(setContactJourney!=null && !setContactJourney.isEmpty()){
                    Messaging.MassEmailMessage emails = new Messaging.MassEmailMessage(); 
                    emails.setTargetObjectIds(lstTargetIds);
                    emails.setTemplateId(emailTemplateId);
                    Messaging.SendEmail(New Messaging.MassEmailMessage[]{emails});
                    sendContactEmail = true;
                }
                
                lstTargetIds.clear();
				if(setLeadJourney!=null && !setLeadJourney.isEmpty())
	                lstTargetIds.addAll(setLeadJourney);
                
                if(setLeadJourney!=null && !setLeadJourney.isEmpty()){
                    Messaging.MassEmailMessage emails = new Messaging.MassEmailMessage(); 
                    emails.setTargetObjectIds(lstTargetIds);
                    emails.setTemplateId(emailTemplateId);
                    Messaging.SendEmail(New Messaging.MassEmailMessage[]{emails});
                    sendLeadEmail = true;
                }*/
                /*	
                if(lstTargetIds!=null && !lstTargetIds.isEmpty()){
                    Messaging.MassEmailMessage emails = new Messaging.MassEmailMessage(); 
                    emails.setTargetObjectIds(lstTargetIds);
                    emails.setTemplateId(emailTemplateId);
                    Messaging.SendEmail(New Messaging.MassEmailMessage[]{emails});
                }*/
               /* if(sendLeadEmail && sendContactEmail)
                    return 'Email Send Successfully.';
                else
                    return null;
            }
            //return 'Email Send Successfully.';
        }
        catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'ex :: '+ex);
            return null;
        }*/ 
        return null;
    }
    
}