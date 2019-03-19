global class SFMCRepliesController {
  global static SFMCRepliesSetting settingData;
    global static EmailTemplate emailTemplate;
    global static Set<String> userEmails;
    global static Set<String> oppTypes;
    global static Set<String> oppStages;
        
    static {
        settingData = (SFMCRepliesSetting)JSON.deserialize(Settings.get('SFMC Replies').Data__c, SFMCRepliesSetting.class);                
        userEmails = settingData.emails;
        emailTemplate = [SELECT Id, Name, HtmlValue FROM EmailTemplate WHERE Name =: settingData.template];
        if(settingData.opportunityType != null && settingData.opportunityType.size() > 0){
            oppTypes = new Set<String>();
            for(String type : settingData.opportunityType){
                oppTypes.add(type.toLowerCase());                
            }
            settingData.opportunityType = new List<String>(oppTypes);
        }
        if(settingData.opportunityStages != null && settingData.opportunityStages.size() > 0){
            oppStages = new Set<String>();
            for(String stage : settingData.opportunityStages){
                oppStages.add(stage.toLowerCase());                
            }			
            settingData.opportunityStages = new List<String>(oppStages);
        }
        
        Debug.log('static settingData :: '+settingData);
        Debug.log('static oppTypes :: '+oppTypes);
        Debug.log('static oppStages :: '+oppStages);
    }
    
  global SFMCRepliesController() {}    
    
    @RemoteAction
    global static SFMCRepliesSetting getSettingsData(){      
        return settingData;
    }    
    
  @RemoteAction
    global static List<String> readCSV(List<Request> lstObject){
      	Debug.log('lstObject :: '+lstObject);
        Map<String, RequestEmails> mapRequests = new Map<String, RequestEmails>();
        for(Request obj : lstObject){
            RequestEmails req = new RequestEmails();
            req.emailId = obj.emailId;
            req.emailCount = obj.emailCount;
            try{
                req.dateSent = (Datetime)Datetime.parse(obj.dateSent);
            }
            catch(Exception e){
                req.dateSent = null;
                Debug.log('req.dateSent exc:: '+req.dateSent);
            }
                 
            mapRequests.put(req.emailId.toLowerCase(), req);
        }
        
        Debug.log('mapRequests :: '+mapRequests);
        
        List<String> lstEmails = new List<String>(mapRequests.keySet());
        Debug.log('lstEmails :: '+lstEmails);
        
        String query = 'SELECT Id, Email, (SELECT Id, Name, CreatedDate FROM Tours3__r), (SELECT Id, Name, Number_of_Desks_2016__c, CreatedDate, Type__c, StageName FROM Opportunities__r) FROM Contact WHERE Email IN :lstEmails';
      List<Contact> result = Database.query(query);
        
        Debug.log('result :: '+result);
        Debug.log('result :: '+result.size());
        
        List<String> responseResult = new List<String>();
        
        if(result != null){
        for(Contact objContact : result){ 
                Debug.log('objContact :: '+objContact.Tours3__r);
                Debug.log('emailCount :: '+mapRequests.get(objContact.Email.toLowerCase()).emailCount);
          String csvFile = '"'+objContact.Email+'","'+mapRequests.get(objContact.Email.toLowerCase()).emailCount+'","';                
                String tourrecords = '';
            	String opprecords = '';
                Integer tourCount = 0;
            	Integer oppCount = 0;
                if(objContact.Tours3__r != null){
                    for(Tour_Outcome__c tour : objContact.Tours3__r){
                        Debug.log('mapRequests.get(objContact.Email.toLowerCase()) :: '+mapRequests.get(objContact.Email.toLowerCase()));
                        Debug.log('mapRequests.get(objContact.Email.toLowerCase()).dateSent :: '+mapRequests.get(objContact.Email.toLowerCase()).dateSent);
                        if(mapRequests.get(objContact.Email.toLowerCase()).dateSent != null && (Datetime.valueOf(tour.CreatedDate.format('yyyy-MM-dd hh:mm:ss')) >= mapRequests.get(objContact.Email.toLowerCase()).dateSent)){
                            tourCount+=1;
                            tourrecords+= tour.Id+'; ';                            
                        } else if(mapRequests.get(objContact.Email.toLowerCase()).dateSent == null) {
                            tourCount+=1;
                            tourrecords+= tour.Id+'; ';
                        }                       
                    }
                }
                csvFile+= tourCount+'","'+tourrecords;
                if(objContact.Opportunities__r != null){
                    for(Opportunity opp : objContact.Opportunities__r){
                        Debug.log('mapRequests.get(objContact.Email.toLowerCase()) :: '+mapRequests.get(objContact.Email.toLowerCase()));
                        Debug.log('mapRequests.get(objContact.Email.toLowerCase()).dateSent :: '+mapRequests.get(objContact.Email.toLowerCase()).dateSent);
                        if(mapRequests.get(objContact.Email.toLowerCase()).dateSent != null && (Datetime.valueOf(opp.CreatedDate.format('yyyy-MM-dd hh:mm:ss')) >= mapRequests.get(objContact.Email.toLowerCase()).dateSent) && !oppTypes.contains(opp.Type__c.toLowerCase()) && oppStages.contains(opp.StageName.toLowerCase())){
                            oppCount+=1;
                            opprecords+= opp.Id;
                            if(opp.Number_of_Desks_2016__c != null){
                                opprecords+= '='+opp.Number_of_Desks_2016__c;
                            }
                            opprecords+= '; ';
                        }  else if(mapRequests.get(objContact.Email.toLowerCase()).dateSent == null && !oppTypes.contains(opp.Type__c.toLowerCase()) && oppStages.contains(opp.StageName.toLowerCase())) {
                            oppCount+=1;
                            opprecords+= opp.Id;
                            if(opp.Number_of_Desks_2016__c != null){
                                opprecords+= '='+opp.Number_of_Desks_2016__c;
                            }
                            opprecords+= '; ';
                        }
                    }
                }            
                csvFile+= '","'+oppCount+'","'+opprecords+'"';
                responseResult.add(csvFile);
                Debug.log('csvFile :: '+csvFile);
             }
      }        
        return responseResult;
    }
    
    @RemoteAction
    global static Boolean sendAttachment(Id attachmentId, Boolean sendResultToMe){ 
        Debug.log('attachmentId :: '+attachmentId);
        Debug.log('userEmails :: '+userEmails);
        if(sendResultToMe){
            userEmails.add(WeworkEngine.GetLoggedInUserInfo().Email);
        }
        Debug.log('userEmails :: '+userEmails);
        Attachment attObj = [SELECT Id, Name, Body FROM Attachment WHERE Id =:attachmentId ];
        Debug.log('attObj :: '+attObj);
        
        Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Name, Email, FirstName FROM User WHERE Email IN :userEmails AND IsActive = true]);
        Debug.log('mapUsers :: '+mapUsers);                                                        
        
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        String subject ='SFMC Replies';
        Blob csvBlob = attObj.Body;
        string csvname= 'Result.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        for(Id userId : mapUsers.keySet()){            
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String[] toAddresses = new List<String>();
            toAddresses.add(mapUsers.get(userId).Email);            
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            email.setTemplateId(emailTemplate.Id);
            String html = emailTemplate.HtmlValue.replace('{!User.FirstName}', mapUsers.get(userId).FirstName);
            email.setHtmlBody(html.replace('{!User.FirstName}', mapUsers.get(userId).FirstName));
            email.setHtmlBody(html.replace(']]>', ''));
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            Debug.log('Finish');
        }            
       return true;
    }
    
    global class Request{
        public String emailId {get;set;}
        public Integer emailCount {get;set;}
        public String dateSent {get;set;}
    }
    
    global class RequestEmails{
        public String emailId {get;set;}
        public Integer emailCount {get;set;}
        public Datetime dateSent {get;set;}
    }
    
    global class SFMCRepliesSetting {
    	public Set<String> emails {get;set;}
        public String message {get;set;}
        public String template {get;set;}
        public String parentId {get;set;}
        public Integer size {get;set;}
        public Integer timeout {get;set;}
        public List<String> opportunityType {get;set;}
        public List<String> opportunityStages {get;set;}
  }
    @RemoteAction
    global static Map<String, String> getData(String objectName){
        Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        Map<String, String> result = new Map<String, String>();
        for(String field : mfields.keySet()){            
            if(!mfields.get(field).getDescribe().isUpdateable() && mfields.get(field).getDescribe().isCalculated() && (mfields.get(field).getDescribe().getCalculatedFormula()!=null)){
                result.put(field, mfields.get(field).getDescribe().getCalculatedFormula());                
            }
        }
        return result;
    }
}