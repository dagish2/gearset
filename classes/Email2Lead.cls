/************************************************************************************************************************************
  Author     	: Pranay Jadhav.
  Description 	: Creates a Leads record from an inbound email submission.
   
  History		:
----------------------------------------------------------------------------------------------------------------------------------
  VERSION      	DATE        		AUTHOR          	DETAIL              	ISSUE
	1			11th June 2018   	Pranay Jadhav     	Initial Developement    ST-  	
**************************************************************************************************************************************/
global class Email2Lead implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        set<Id> setIds;
        try{
            setIds = new RESTInboundLeadAPIController(email, env).handleInboundEmailRequest();
            Debug.Log('setIds=='+setIds);
            list<Lead> lstLeads = [SELECT Id, Name, Email, IsConverted, ConvertedContactId, LeadSource, OwnerId FROM Lead WHERE Id IN : setIds];
            list<Contact> lstContacts = [SELECT Id, Name, Email, LeadSource, OwnerId FROM Contact WHERE Id IN : setIds];
            this.insertAttachments(email, env, lstLeads, lstContacts);
            result.success = true;
            result.message = 'Lead processed!';
        }
        catch(Exception pEx) {
            result.success = false;
            result.message = pEx.getMessage();
        }
        return result;
    }
    
    global void insertAttachments(Messaging.inboundEmail email, Messaging.InboundEnvelope env, list<Lead> lstLeads, list<Contact> lstContacts){
        list<Attachment> attachmentList = new list<Attachment>();
        list<sObject> lstSObject = new list<sObject>();
        lstSObject.addAll(new list<sObject>((list<sObject>)lstContacts));
        if(email.binaryAttachments != null){
            for(Messaging.Inboundemail.BinaryAttachment file : email.binaryAttachments){
                list<Attachment> lstLeadsAttachment = this.setAttachmentOnSObjects(lstSObject, JSON.serialize(file));
                if(lstLeadsAttachment != null && !lstLeadsAttachment.isEmpty())
                    attachmentList.addAll(lstLeadsAttachment);
            }
        }
        if(email.textAttachments != null){
            for(Messaging.Inboundemail.TextAttachment file : email.textAttachments) {
                list<Attachment> lstLeadsAttachment = this.setAttachmentOnSObjects(lstSObject, JSON.serialize(file));
                if(lstLeadsAttachment != null && !lstLeadsAttachment.isEmpty())
                    attachmentList.addAll(lstLeadsAttachment);
            }
        }
        if(attachmentList.size() > 0){
            insert attachmentList;
        }
    }
    
    private list<Attachment> setAttachmentOnSObjects(list<sObject> lstSObjects, string file){
        Map<String, Object> mapFile = (Map<String, Object>)JSON.deserializeUntyped(file);
        list<Attachment> attachmentList = new list<Attachment>();
        Attachment attachment;
        for(sObject obj : lstSObjects){
            attachment = new Attachment();
            attachment.Name = string.valueOf(obj.get('Email')) + '_'  + mapFile.get('fileName');
            attachment.Body = Blob.valueOf((string)mapFile.get('body'));
            attachment.ParentId = string.valueOf(obj.get('Id'));
            attachmentList.add(attachment);
        }
        return attachmentList;
    }
    
    public class Email2LeadException extends Exception{}
}