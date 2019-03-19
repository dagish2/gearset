/*
* @ Descrption : Reassign leads having inactive owners by assignment rule
* @ Created By : Ajaysinh Chauhan
* @ Created Date : 24 Sep 2016
* @ Issue : ST-689
*/

global class LeadOwnerReassign implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id, Name,OwnerId FROM Lead WHERE OwnerId IN (SELECT Id FROM User WHERE IsActive = false) AND isConverted=false');
    }

    global void execute(Database.BatchableContext context, List<Lead> lstLeads) {
        map<Id,Id> mapLeadOwner =  new map<Id,Id>();
        list<Lead> lstLeadsToUpdate = new list<Lead>();
        for(lead lead : lstLeads)
        {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            lead.setOptions(dmo);
            mapLeadOwner.put(lead.Id,lead.ownerId);
        }
        update lstLeads;
        for(lead lead : lstLeads)
        {
           if(mapLeadOwner.get(lead.Id) == lead.ownerId)
           {
               lead.ownerId = UserInfo.getUserId();
               lstLeadsToUpdate.add(lead);
           }
        }
        if(lstLeadsToUpdate.size() > 0)
            update lstLeadsToUpdate;
    }
    
    global void finish(Database.BatchableContext context) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'wework@enzigma.com'});
        mail.setReplyTo('wework@enzigma.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Lead reassigned successfully!');
        mail.setPlainTextBody('Leads having owner as inactive user are reassigned to active users by assignment rule successfully!');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}