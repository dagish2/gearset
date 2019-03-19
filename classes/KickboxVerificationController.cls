/*********************************************************************************************
Name   : KickboxVerificationController
Purpose:Accept CSV file form KickboxVerification page and send to Kickbox API. As we get Job id from kickbox API,
		we will create record of Kickbox Verification object and attach that CSV file as attachment for request tracking.
		And Cover Test methods in KickboxVerificationControllerTest Apex class.
History:
         VERSION      DATE      	AUTHOR                 DETAIL                     ISSUE
          1.0      21 Dec 2016   Mayuresh Ghodke	 Initial Developement.			  ST-684
		  2.0          _     	 Shobhit Ghalot	 	 Bug Fixses.
		  3.0	   11 Jan 2018	 Amol Darekar		 Add code to add table and summery information in email body.
		Code is commented by Rupesh Patil as this class is depricated
*********************************************************************************************/

global class KickboxVerificationController {

    /*public KickboxVerificationController(WeworkEngine controller) {

    }


    public KickboxVerificationController() {

    }

    global class settingTemplateURL{
        
        String downloadURL { get; set;}
        //Setting__c KickboxSettings { get; set;}
        
        Map<String, Setting__c> KickboxSettings {get;set;}
    }
  
    global static String getSettingsRecord(List<String> lstsetting){
        debug.log('Call ala kickla'+lstsetting);
        Map<String, Setting__c> mapkickboxSettings = new Map<String, Setting__c>();
        try{
            for(String settingsName : lstsetting){
                mapkickboxSettings.put(settingsName,Settings.get(settingsName));
            }
            String downloadURL = KickboxVerificationController.generateURL();
            settingTemplateURL JSONWrapper = new settingTemplateURL();
            JSONWrapper.downloadURL = downloadURL;
            //JSONWrapper.KickboxSettings = Settings.get(settingsName);
            JSONWrapper.KickboxSettings = mapkickboxSettings;
            debug.log('mapkickboxSettings ::'+ mapkickboxSettings);
            debug.log('downloadURL ::'+ downloadURL);
            debug.log('JSONWrapper ::'+ JSONWrapper);
            return JSON.serialize(JSONWrapper);   
        }catch(Exception pEx) {            
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('kickboxVerification','getSettingsRecord','Line Number==>'+pEx.getLineNumber(),pEx)
            );
            throw new kickboxVerificationException(pEx.getMessage());
        }
    }
	
    //Changes Made By	: Shobhit Gahlot
    //ST-1363			: Changes made for new flow
    //Comment 			: Now Leads are inserted without sending lead emails for kickbox response
    @RemoteAction
    global static  String kickboxVerification(string csvFile, String generateJourney, Attachment objAttachment, Id campaingeId, Id KickboxVerificationId, String filePart){
         debug.log('in kickboxVerification generateJourney ==>'+generateJourney);
        debug.log('in kickboxVerification --------'+csvFile);
        //Map<String,String> mapRecords = new  Map<String,String>();
        Debug.log('KickboxVerificationId--------'+KickboxVerificationId);
        Kickbox_Verification__c objKickboxVerification;
        try{
           if(KickboxVerificationId == null){
            debug.log('inside kickboxVerification for first time --------'+KickboxVerificationId);
            objKickboxVerification = new Kickbox_Verification__c();
            //objKickboxVerification.Kickbox_Job_Id__c = decimal.valueOf(response1.id);
            objKickboxVerification.Create_From_Journey_Importer__c = true;
            objKickboxVerification.Generate_Journey__c = Boolean.valueOf(generateJourney);
            if(campaingeId != null)
                objKickboxVerification.Campaign__c = campaingeId;       
            
            insert objKickboxVerification;
            Debug.log('objKickboxVerification.CreatedDate -------- '+objKickboxVerification.CreatedDate );
            Debug.log('objKickboxVerification -------- '+objKickboxVerification.id);
            objAttachment.ParentId = objKickboxVerification.id;
            objAttachment.OwnerId = UserInfo.getUserId();
            objAttachment.Body = Blob.valueof(csvFile);
            objAttachment.Name = 'Lead Importer Kickbox : Id : '+objKickboxVerification.Id +' File Part : '+filePart;
            objAttachment.ContentType = 'text/csv';
            insert objAttachment;
            debug.log('Attchment id ::'+objAttachment.Id);
        }
        KickboxVerificationApiHandler.successWrapper objWrapper;
        Debug.log('Cntrlr getCpuTime --------'+Limits.getCpuTime());
        Debug.log('Cntrlr getLimitCpuTime --------'+Limits.getLimitCpuTime());
        debug.log('in kickboxVerification generateJourney ==>'+generateJourney);
        KickboxProcessLeadsBatch myBatchObject = new KickboxProcessLeadsBatch(csvFile,generateJourney,objKickboxVerification.Id,filePart,campaingeId); 
        Id batchId = Database.executeBatch(myBatchObject,2000);
        Debug.log('batchId::::'+batchId);
        
        return 'done';  
        }catch(Exception pEx) {            
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('kickboxVerification','kickboxVerification','Line Number==>'+pEx.getLineNumber(),pEx)
            );
            throw new kickboxVerificationException(pEx.getMessage());
        }       
    }
    
    /*
	* Created By   	: Mayuresh Ghodke
	* Created Date 	: 20-Feb-2017
	* Comment		: If user click on ' Bulk Add To Campaign' of Journey console then selected Journeies will pass to Campaign Emails 2nd Step.
					  At the end with created or updated Campaign and with Journey's primary member we need to create Campaign Member.
	* Issue No.		: 
	*/
   /*@RemoteAction
    global static List<Id> saveCampaignMember(List<Id> lstJourneyIds,Id newCampaignId){
        Debug.log('lstJourneyIds :: '+lstJourneyIds);
        Debug.log('newCampaignId :: '+newCampaignId);
        Debug.log('saveCampaignMember');
        Set<Id> setContactIds = new Set<Id>();
        Set<Id> setLeadIds = new Set<Id>();
        
        List<Journey__c> lstJourney = [Select Id,Primary_Contact__c,Primary_Lead__c From Journey__c Where Id IN : lstJourneyIds];
        Debug.log('lstJourney :: '+lstJourney);
        try{
            for(Journey__c objJourney : lstJourney){
                if(objJourney.Primary_Contact__c != null)
                    setContactIds.add(objJourney.Primary_Contact__c);
                else
                    setLeadIds.add(objJourney.Primary_Lead__c);
            }
            Debug.log('setContactIds :: '+setContactIds);
            Debug.log('setLeadIds :: '+setLeadIds);
            
            List<CampaignMember> lstExistCampaignMemberCon = new List<CampaignMember>();
            if(setContactIds!=null && !setContactIds.isEmpty()){
                lstExistCampaignMemberCon = [Select Id,contactid From CampaignMember Where contactid IN : setContactIds AND campaignid =: newCampaignId];
            }
            Debug.log('lstExistCampaignMemberCon :: '+lstExistCampaignMemberCon);
            
            List<CampaignMember> lstExistCampaignMemberLead = new List<CampaignMember>();
            if(setLeadIds!=null && !setLeadIds.isEmpty()){
                lstExistCampaignMemberLead = [Select Id,leadid From CampaignMember Where leadid IN : setLeadIds AND campaignid =: newCampaignId];
            }
            
            Debug.log('lstExistCampaignMemberLead :: '+lstExistCampaignMemberLead);
            if(lstExistCampaignMemberCon!=null && !lstExistCampaignMemberCon.isEmpty())
                for(CampaignMember obj : lstExistCampaignMemberCon)
                setContactIds.remove(obj.contactid);
            if(lstExistCampaignMemberLead!=null && !lstExistCampaignMemberLead.isEmpty())
                for(CampaignMember obj : lstExistCampaignMemberLead)
                setLeadIds.remove(obj.leadid);
            
            Debug.log('setContactIds :: '+setContactIds);
            Debug.log('setLeadIds :: '+setLeadIds);
            List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
            if(setContactIds!=null && !setContactIds.isEmpty()){
                for(Id objId : setContactIds){
                    CampaignMember campMem = new CampaignMember (campaignid=newCampaignId, contactid=objId);
                    lstCampaignMember.add(campMem);
                }
                Debug.log('lstCampaignMember Contact :: '+lstCampaignMember);
            }
            if(setLeadIds!=null && !setLeadIds.isEmpty()){
                for(Id objId : setLeadIds){
                    CampaignMember campMem = new CampaignMember (campaignid=newCampaignId, leadid=objId);
                    lstCampaignMember.add(campMem);
                }
                Debug.log('lstCampaignMember Lead :: '+lstCampaignMember);
            }
            
            insert lstCampaignMember;
            List<Id> lstCampaignMemberId = new List<Id>();
            
            for(CampaignMember objId : lstCampaignMember)
                lstCampaignMemberId.add(objId.Id);
            return lstCampaignMemberId;
            
        }catch(Exception pEx) {            
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('kickboxVerification','saveCampaignMember','Line Number==>'+pEx.getLineNumber(),pEx)
            );
            throw new kickboxVerificationException(pEx.getMessage());
        }  
    }
    
    /*
	* Created By   	: Mayuresh Ghodke
	* Created Date 	: 28-Dec-2016
	* Comment		: Call from Lead List view button. 
					  Which will call to CheckEmailQuality batch class for check emails of Lead and Contatct between perticular date.
	* Issue No.		: ST-684
	*/
  /*  webservice static void kickboxVerificationRunBatchClass(){
        Boolean regularBatch = false;
        CheckEmailQuality obj = new CheckEmailQuality('LeadQuery','ContactQuery',regularBatch);
        Database.executeBatch(obj);  
    }

    global static String generateURL(){
        try{
        KickboxLeadImporterUtility objKickboxLeadImporterUtility = new KickboxLeadImporterUtility();
        Setting__c RecordJSONKickboxLeadImporterUtility = Settings.get('KickboxLeadImporterUtility');
        
        Debug.log('RecordJSONKickboxLeadImporterUtility :: '+ RecordJSONKickboxLeadImporterUtility);
        
        objKickboxLeadImporterUtility = (KickboxLeadImporterUtility)JSON.deserialize(RecordJSONKickboxLeadImporterUtility.Data__c, KickboxLeadImporterUtility.Class);
        Debug.log('objKickboxLeadImporterUtility :: '+objKickboxLeadImporterUtility);
        
        List<Document> lstDocument = [SELECT Id, Name, Body FROM Document where name =: objKickboxLeadImporterUtility.SampleCsvTemplate limit 1];
        debug.log('lstDocument generateURL :: '+lstDocument);        
            if(lstDocument != null && lstDocument.size()>0)
            {
                String IdDocument = lstDocument[0].Id;
                string strOrgId = UserInfo.getOrganizationId();
                string orgInst = URL.getSalesforceBaseUrl().getHost();
                debug.log('After working orgInst ::'+orgInst);
                string strDocUrl = URL.getSalesforceBaseUrl().getProtocol() + '://' + orgInst + '/servlet/servlet.FileDownload?file=' + IdDocument + '&oid=' + strOrgId;
                debug.log('URL ::'+strDocUrl);
                return strDocUrl;
            }
            else{
                return null;
            } 
        }catch(Exception pEx) {            
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('kickboxVerification','generateURL','Line Number==>'+pEx.getLineNumber(),pEx)
            );
            throw new kickboxVerificationException(pEx.getMessage());
        }  
    }
    
     @RemoteAction
    global static List<List<sObject>> searchQuery(String strSearchQuery) {
        try{
            
        }catch(Exception pEx) {            
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('kickboxVerification','searchQuery','Line Number==>'+pEx.getLineNumber()+'strSearchQuery==>'+strSearchQuery,pEx)
            );
            throw new kickboxVerificationException(pEx.getMessage());
        }  
        return Search.query(strSearchQuery);
    }
    
    /*Purpose : This method is use to send email to user for kickbox lead upload details*/
  /*  global static string kickboxVerificationSendMail(string csvFileFailed, string csvFileSuccess, Id KickboxVerificationId,map<string,list<sObject>> mapSobjectRecords,map<string,integer> mapOfCounts){
        debug.log('in kickboxVerification ::'+KickboxVerificationId);
        EmailTemplate successfullTemplate = [select Id,Body,HtmlValue From EmailTemplate where Name = 'Leads Uploaded_Success'];
        
        Id userId = UserInfo.getUserId();
        User objUser = [Select Id,Email, FirstName From user Where id =: userId];
        
        set<string> setTblFields = new set<string>();
        setTblFields.add('Id');
        setTblFields.add('Primary_Email__c');
       
        Messaging.SingleEmailMessage emailsuccess =new Messaging.SingleEmailMessage();
        String htmlBody = successfullTemplate.Body;
        htmlBody = htmlBody.replace('{!User.FirstName}', objUser.FirstName);
        htmlBody = htmlBody.replace('#ExistingLeadTable#', getTableBody(setTblFields,mapSobjectRecords));
        htmlBody = htmlBody.replace(']]>', '');    
        String[] toAllAddresses = new list<string>();
        toAllAddresses.add(objUser.Email);
        String subject ='Leads Importer Summary';
        emailsuccess.setSubject(subject);
        emailsuccess.setToAddresses(toAllAddresses);
        emailsuccess.setTargetObjectId(objUser.Id);
        emailsuccess.setTemplateId(successfullTemplate.Id);
        emailsuccess.setSaveAsActivity(false);
        //emailsuccess.setPlainTextBody(htmlBody);
        String uploadSummery = '<br></br>';
        
        for(string currentLable:mapOfCounts.keySet())
            uploadSummery +=' '+ currentLable +' = <b>'+ mapOfCounts.get(currentLable)+'</b><br></br>';
        
        htmlBody = htmlBody.replace('#UploadSummery#', uploadSummery);
        emailsuccess.setHtmlBody(htmlBody);
        Messaging.EmailFileAttachment csvAttcFailValidations = new Messaging.EmailFileAttachment();
        Messaging.EmailFileAttachment csvAttcSuccessful = new Messaging.EmailFileAttachment();
        
        List<Messaging.Emailfileattachment> lstAttachments = new List<Messaging.Emailfileattachment>();
        if(String.isNotBlank(csvFileSuccess)){
            blob csvBlob = Blob.valueOf(csvFileSuccess);
            string csvname= 'Leads Successfully Created.csv';
            csvAttcSuccessful.setFileName(csvname);
            csvAttcSuccessful.setBody(csvBlob);
            Attachment objAttachment = new Attachment();
            objAttachment.Name = 'Lead Importer Lead Insert : Success';
            objAttachment.IsPrivate = false;
            objAttachment.ContentType = 'text/csv';
            objAttachment.Body =  Blob.valueof(csvFileSuccess);
            objAttachment.OwnerId = UserInfo.getUserId();
            objAttachment.ParentId = KickboxVerificationId;
            insert objAttachment;
            Debug.Log('csvAttcSuccessful :: '+csvAttcSuccessful);
	        lstAttachments.add(csvAttcSuccessful);
        }
        Debug.Log('lstAttachments :: '+lstAttachments);
        
		if(String.isNotBlank(csvFileFailed)){
            blob csvBlobFailValidations = Blob.valueOf(csvFileFailed);
            string csvnameFail = 'Leads Insert Failed.csv';//will contain leads that fail due to validations
            csvAttcFailValidations.setFileName(csvnameFail);
            csvAttcFailValidations.setBody(csvBlobFailValidations);
            
            //Insert Failed Leads Attachment save to Salesforce
            Attachment objAttachmentFailedInsert = new Attachment();
            objAttachmentFailedInsert.Name = 'Lead Importer Lead Insert Failed';
            objAttachmentFailedInsert.IsPrivate = false;
            objAttachmentFailedInsert.ContentType = 'text/csv';
            objAttachmentFailedInsert.Body =  Blob.valueof(csvFileFailed);
            objAttachmentFailedInsert.OwnerId = UserInfo.getUserId();
            objAttachmentFailedInsert.ParentId = KickboxVerificationId;
            insert objAttachmentFailedInsert;
            Debug.Log('csvAttcFailValidations :: '+csvAttcFailValidations);
            lstAttachments.add(csvAttcFailValidations);
        }
        if(lstAttachments.size()>0 && lstAttachments != null)
            emailsuccess.setFileAttachments(lstAttachments );
        
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailsuccess});
        
        return 'done';
    }
    
    public static string getTableBody(set<string> setTblFields,map<string,list<sObject>> mapSobjectRecords){
        String htmlBody = '';
        List<sObject> myList = new List<sObject>();
        //open table..
      	map<string,map<string,string>> mapObjectAndFields = new map<string,map<string,string>>();
        mapObjectAndFields.put('New Journeys',new map<string,string>{'Primary_Email__c' =>'Email','Id'=>'Id'});
        mapObjectAndFields.put('Existing Journeys',new map<string,string>{'Primary_Email__c' =>'Email','Id'=>'Id'});
        mapObjectAndFields.put('Existing Leads',new map<string,string>{'Email' =>'Email of Lead','Id'=>'Id'});
        mapObjectAndFields.put('New Leads',new map<string,string>{'Email' =>'Email of Lead','Id'=>'Id'});
        mapObjectAndFields.put('Existing Contacts',new map<string,string>{'Email' =>'Email of Contact','Id'=>'Id'});

        Debug.log('mapSobjectRecords getTableBody==>'+mapSobjectRecords);
        for(string currentObject : mapSobjectRecords.keySet()){
            myList = mapSobjectRecords.get(currentObject);
            if(myList != null && myList.size()>0){
            htmlBody += '<table border="1" style="border-collapse: collapse;width:60%;text-align: center;"><caption style="text-align: left;margin: 4px 0px 2px 0px;"><b>'+currentObject+'</b></caption>';
            htmlBody+= '<tr style="height: 25px;background:#563d7c;color:white;"><th>Sr.no</th>';

            map<string,string> mapFieldsWithLabel =  mapObjectAndFields.get(currentObject);
            for(string currentField : mapFieldsWithLabel.keySet())
             {
                   htmlBody+= '<th>' + mapFieldsWithLabel.get(currentField) + '</th>';
             }
            htmlBody+= '</tr>';
            Integer Index = 0;
            string background = '';
            for(sObject l : myList){
                if(math.mod(Index, 2) == 0){
                   background = '#d5e9e5';
                }
                else{
                    background = '#ffffff';
                }
                htmlBody+= '<tr style="height:25px;background-color:'+background+'"><td>'+ ++Index +'</td>';
                for(string currentField :  mapFieldsWithLabel.keySet())
                 {
                   htmlBody+= '<td>' + l.get(currentField) + '</td>';
                 }
                htmlBody+= '</tr>';
            }
            //close table...
            htmlBody += '</table><br></br><br></br>';
        }
        }
        return htmlBody;
    }
    
    
    global class KickboxResponseOne{
        public String id {get;set;}
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
    
    global class KickboxLeadImporterUtility{
        public Integer ChunkSize;
        public List<Map<String, String>> JsErrors;
        public String SampleCsvTemplate;
        public List<String> CsvAPINames;
        public String HelperText;
        public Integer MaxAllowedRecords;
    }
    public class kickboxVerificationException extends Exception{}*/
}