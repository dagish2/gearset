/****************************************************************************************************************************
Author              :	Samadhan kadam
Description         : 	This Batch is initiate from LightningComponentController class and used to insert leads from Lead/Journey 
						importer and notify login user by email about the import summary.
Created Date        : 	26 June 2018            
*********************************************************************************************************************************/    
public class JourneyImporterBatch implements Database.Batchable<sObject>,Database.Stateful{
    public List<Lead> lstLeads{get;set;}
    public String successCSV{get;set;}
    public String failCSV{get;set;}
    public string successTemp{get;set;}
    public string failTemp{get;set;}
    public string[] apiNamesOfCSVColumns{get;set;}
    Public Kickbox_Verification__c objKickboxVerification {get;set;}
    public set<string> setInsertedLeadEmails{get;set;}
    public set<Id> setInsertedLeads{get;set;}
    public map<string,list<sObject>> mapSobjectRecords = new map<string,list<sObject>>(); 
    public map<string,integer> mapOfSummaryCounts = new map<string,integer>();
    public DateTime date1{get;set;}
    public DateTime date2{get;set;}
    public Set<Id> setLeadIds;    
    public set<Id> setLeadsToDelete;
    public JourneyImporterBatch(List<Lead> lstLeads, Kickbox_Verification__c objKickboxVerification,String successHeader,string failHeader,string[] apiNamesOfCSVColumns){
        this.lstLeads = lstLeads;
        this.date1 = DateTime.now();
        this.date2 = date1.addSeconds(-30);
        this.date1 = date1.addSeconds(30);
        this.objKickboxVerification = objKickboxVerification;
        this.successTemp = successHeader;
        this.failTemp = failHeader;
        this.successCSV = successHeader;
        this.failCSV = failHeader;
        this.apiNamesOfCSVColumns = apiNamesOfCSVColumns;
        this.setInsertedLeadEmails = new Set<String>();
        this.setInsertedLeads = new Set<Id>();
        this.setLeadsToDelete = new set<Id>();
        this.setLeadIds = new set<Id>();
    }
    
    public Iterable<sObject> start(Database.BatchableContext bc) {
        return lstLeads;
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> records){        
        try{
            List<Database.SaveResult> results = Database.insert(records,false);
            if(LeadConverterHelper.setLeadIds != null && LeadConverterHelper.setLeadIds.size() > 0){
                this.setLeadIds.addAll(LeadConverterHelper.setLeadIds); 
            }  
            if(LeadConverterHelper.lstLeadsToDelete != null && LeadConverterHelper.lstLeadsToDelete.size() > 0){
                setLeadsToDelete.addAll(LeadConverterHelper.lstLeadsToDelete);
            }           
            for(Integer row=0;row<records.size();row++){
                if(results[row].isSuccess()){
                    for(string name : successCSV.split('\n')[0].split(',')){
                        if(name == 'Id'){
                            successCSV += (results[row].getId()+',');
                        }else{
                            if(String.isNotBlank(String.valueOf(records[row].get(name))) && String.valueOf(records[row].get(name)).contains(',')){
                                successCSV += ('"'+records[row].get(name)+'",');
                            }else{
                                successCSV += (records[row].get(name)+',');
                            }
                        }             
                    }
                    successCSV.removeEnd(',');
                    successCSV += '\n';
                    setInsertedLeadEmails.add(String.valueOf(records[row].get('Email')));
                    setInsertedLeads.add(results[row].getId());
                }else{               
                    for(string name : apiNamesOfCSVColumns){
                        if(String.isNotBlank(String.valueOf(records[row].get(name))) && String.valueOf(records[row].get(name)).contains(',')){
                            failCSV += ('"'+records[row].get(name)+'",');
                        }else{
                            failCSV += (records[row].get(name)+',');
                        }
                    }             
                    failCSV += ((results[row].getErrors()[0].getMessage().split('Exception:')[0].replaceAll('\n',' ').replaceAll(',',''))+'\n');             
                }
            }
        }catch(Exception pEx){
            Debug.log('pEx ==>'+pEx);
            Debug.log('getStackTraceString ==>'+pEx.getStackTraceString());
            ApexDebugLog.logException(pEx, JSON.serialize(records), 'JourneyImporterBatch', 'execue'); 
        }
    }
    
/************************************************************************************************************************************
        Author              :   Samadhan Kadam
        Description         :   This method is used used to Send an email notification to the logged in user 
								which imports the csv by Journey Importer(Kickbox Importer).
      	Modified Date  		:   29 Nov 2018 
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public void finish(Database.BatchableContext bc){
        Debug.log('setLeadIds==>'+setLeadIds);
        Debug.log('setLeadsToDelete==>'+setLeadsToDelete);        
        JourneyHelperUtility.updateJourneyOwner(setLeadIds, (!setLeadsToDelete.isEmpty() ? new List<Id>(setLeadsToDelete) : null));
        
        List<Contact> lstExistingContactEmails = [SELECT Id, Email FROM Contact WHERE Email IN : setInsertedLeadEmails];       
        set<string> setContactEmails = new set<string>();
        for(Contact currentContact : lstExistingContactEmails){
            if(String.isNotBlank(currentContact.Email)){
                setContactEmails.add(currentContact.Email.toLowerCase());  
            }               
        }        
        
        //SOQL to get list of Leads,Journey and Contact records show as a table in email.
        List<Lead> lstExistingLeadEmails = [SELECT Id, Email FROM Lead WHERE Email IN : setInsertedLeadEmails AND isConverted = FALSE AND Id NOT IN : setInsertedLeads];       
        Set<string> setOfExstLeadEmail = new Set<string>();
        if(lstExistingLeadEmails.size() > 0){
            for(Lead ObjLead : lstExistingLeadEmails){
                setOfExstLeadEmail.add(ObjLead.Email);
            }
        }
        List<Lead> lstNewLeads = [SELECT Id, Email FROM Lead WHERE Email IN : setInsertedLeadEmails AND Email NOT IN : setContactEmails AND Id NOT IN : lstExistingLeadEmails AND Email NOT IN : setOfExstLeadEmail AND isConverted = FALSE];
        List<Journey__c> lstJourenys = [SELECT Id, Primary_Email__c, CreatedDate, LastModifiedDate FROM Journey__c WHERE Primary_Email__c IN : setInsertedLeadEmails AND CreatedDate >: date2 AND CreatedById =: UserInfo.getUserId()];
        List<Journey__c> lstExistingJourenys = [SELECT Id, Primary_Email__c, CreatedDate, LastModifiedDate FROM Journey__c WHERE Primary_Email__c IN : setInsertedLeadEmails AND LastModifiedDate >: date2  AND LastModifiedBy.Id =: UserInfo.getUserId() AND Id NOT IN:lstJourenys];
        this.getRecordSummaryCounts(mapSobjectRecords, mapOfSummaryCounts, lstLeads, lstNewLeads, lstExistingLeadEmails, lstExistingContactEmails, lstJourenys, lstExistingJourenys);
        
        List<Attachment> lstAttachments = new List<Attachment>();
        List<Messaging.Emailfileattachment> lstEmailAttachments = new List<Messaging.Emailfileattachment>();
        this.insertResultantAttachments(lstAttachments, lstEmailAttachments, successCSV, successTemp, failCSV, failTemp, objKickboxVerification);  
        
        EmailTemplate successfullTemplate = [SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE Name = 'Leads Uploaded_Success'];
        User loggedInUserInfo = Settings.getUserById(UserInfo.getUserId()); 
        
        set<string> setTblFields = new set<string>{'Id','Primary_Email__c'};        
            Messaging.SingleEmailMessage summuryEmail = new Messaging.SingleEmailMessage();        
        summuryEmail.setSubject('Leads Importer Summary');
        summuryEmail.setToAddresses(new List<String>{loggedInUserInfo.Email});
        summuryEmail.setTargetObjectId(loggedInUserInfo.Id);
        summuryEmail.setTemplateId(successfullTemplate.Id);
        summuryEmail.setSaveAsActivity(false);
        if(lstEmailAttachments != null && lstEmailAttachments.size()>0){
            summuryEmail.setFileAttachments(lstEmailAttachments );
        }
        
        String htmlBody = successfullTemplate.Body;
        htmlBody = htmlBody.replace('{!User.FirstName}', loggedInUserInfo.Name);
        htmlBody = htmlBody.replace('#ExistingLeadTable#', LightningComponentController.getTableBody(setTblFields,mapSobjectRecords));
        htmlBody = htmlBody.replace(']]>', ''); 
        String uploadSummery = '<br></br>';
        for(string currentLable:mapOfSummaryCounts.keySet()){
            uploadSummery +=' '+ currentLable +' = <b>'+ mapOfSummaryCounts.get(currentLable)+'</b><br></br>';   
        }        
        htmlBody = htmlBody.replace('#UploadSummery#', uploadSummery);        
        summuryEmail.setHtmlBody(htmlBody);        
        Messaging.SendEmailResult[] arrEmailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {summuryEmail});
        Debug.log('arrEmailResult=='+arrEmailResult);      
    }
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used set the Kickbox Importer Successfull and Failure Summarry.
								i.e used to Send an email notification to the logged in user which imports the csv by Journey Importer(Kickbox Importer)
      	Created Date  		:   29 Nov 2018 
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public void getRecordSummaryCounts(Map<String, List<sObject>> mapSobjectRecords, Map<String,Integer> mapOfSummaryCounts, List<Lead> lstLeads, List<Lead> lstNewLeads, List<Lead> lstExistingLeadEmails, List<Contact> lstExistingContactEmails, List<Journey__c> lstJourenys,  List<Journey__c> lstExistingJourenys) {
        mapSobjectRecords.put('Existing Leads',lstExistingLeadEmails);
        mapSobjectRecords.put('Existing Contacts',lstExistingContactEmails);
        mapSobjectRecords.put('Existing Journeys',lstExistingJourenys);
        mapSobjectRecords.put('New Leads',lstNewLeads);
        mapSobjectRecords.put('New Journeys',lstJourenys);
        //Put summery of uploaded records into map to be pass to send email function
        mapOfSummaryCounts.put('Total Number of Leads Uploaded',lstLeads.size());
        mapOfSummaryCounts.put('New Leads Inserted in SF',lstNewLeads.size());
        mapOfSummaryCounts.put('Existing Lead Updated',lstExistingLeadEmails.size());
        mapOfSummaryCounts.put('Existing Contact Updated',lstExistingContactEmails.size());
        mapOfSummaryCounts.put('New Journeys Inserted in SF',lstJourenys.size());
        mapOfSummaryCounts.put('Existing Journeys Updated',lstExistingJourenys.size());  
    }
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to create a Attachment object for Kickbox importer result (Success and Failure)
      	Created Date  		:   29 Nov 2018 
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public Attachment getAttachment(String strName, String body, String strKickboxVerId ){
        Attachment objResponseAttachment = new Attachment();
        objResponseAttachment.Name = strName;
        objResponseAttachment.IsPrivate = false;
        objResponseAttachment.ContentType = 'text/csv';
        objResponseAttachment.Body =  Blob.valueof(Body);
        objResponseAttachment.OwnerId = UserInfo.getUserId();
        objResponseAttachment.ParentId = strKickboxVerId;
        return objResponseAttachment;
    }
    
 /************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is used to insert the Kickbox resultant attachments (Success and Failure)
      	Created Date  		:   29 Nov 2018 
        Last Modified By    :   Krishana Tupe
 *************************************************************************************************************************************/
    public void insertResultantAttachments(List<Attachment> lstAttachments, List<Messaging.Emailfileattachment> lstEmailAttachments, String successCSV, String successTemp, String failCSV, String failTemp, Kickbox_Verification__c objKickboxVerification){
        if(successCSV != successTemp){
            Attachment objResponseAttachment = getAttachment('Lead Importer Result : Success', successCSV, objKickboxVerification.Id);
            lstAttachments.add(objResponseAttachment);            
            Messaging.Emailfileattachment successEmailAttachment = new Messaging.Emailfileattachment();
            successEmailAttachment.setFileName('Leads Insert Success.csv');
            successEmailAttachment.setBody(Blob.valueOf(successCSV));
            lstEmailAttachments.add(successEmailAttachment);
        }
        if(failCSV != failTemp){
            Attachment objResponseAttachment = getAttachment('Lead Importer Result : Failed', failCSV, objKickboxVerification.Id);
            lstAttachments.add(objResponseAttachment);            
            Messaging.Emailfileattachment failEmailAttachment = new Messaging.Emailfileattachment();
            failEmailAttachment.setFileName('Leads Insert Fail.csv');
            failEmailAttachment.setBody(Blob.valueOf(failCSV));
            lstEmailAttachments.add(failEmailAttachment);
        }
        if(lstEmailAttachments != null && lstEmailAttachments.size() > 0){
            insert lstAttachments;     
        }        
    }
    
}