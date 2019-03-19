global class UpdateJourneyOnCampaignMemberBatch implements Database.Batchable<sObject>,Schedulable  {
    List<Journey__c> lstJournyesToUpdate = new List<Journey__c>();
    Map<String,Set<String>> setting = (Map<String,Set<String>>)JSON.deserialize(Settings.get('UpdateJourneyOnCampaignMemberBatch').Data__c,Map<String,Set<String>>.class);
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date Dtoday = System.today();
        Set<String> CampaignType = setting.get('CampaignType');
        //return Database.getQueryLocator('SELECT Id,Name,StartDate,Type,(SELECT Id,Name,ContactId,LeadId,CreatedDate From CampaignMembers) From Campaign WHERE StartDate =: Dtoday AND Type IN : CampaignType');
        return Database.getQueryLocator('SELECT Id,Name,ContactId,LeadId,CreatedDate,CampaignId From CampaignMember WHERE Campaign.Event_Email_Opt_Out__c = true AND ( Campaign.StartDate =: Dtoday AND Campaign.Type IN : CampaignType)');
    }
    global void execute(SchedulableContext ctx) {
        UpdateJourneyOnCampaignMemberBatch batchSch = new UpdateJourneyOnCampaignMemberBatch();
        database.executebatch(batchSch,1);
    }
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        Debug.log('In  execute : '+scope);
        set<string> Ids = new set<string>();
        map<String,CampaignMember> mapCampaignMembers = new map<String,CampaignMember>();
        map<String,String> mapLeadIdWithCampaignMembers = new map<String,String>();
        map<String,String> mapContactIdWithCampaignMembers = new map<String,String>();
        for(CampaignMember cmpMember : (List<CampaignMember>) scope){
            mapCampaignMembers.put(cmpMember.Id, cmpMember);
            if(cmpMember.LeadId != null){
                Ids.add(cmpMember.LeadId);
                mapLeadIdWithCampaignMembers.put(cmpMember.LeadId, cmpMember.Id);
            }
            if(cmpMember.ContactId != null){
                Ids.add(cmpMember.ContactId);
                mapContactIdWithCampaignMembers.put(cmpMember.ContactId, cmpMember.Id);
            } 
        }

        Set<String> JourneyLeadSource = setting.get('JourneyLeadSource');
        //List<Journey__c> lstJourneys = [SELECT Id,Name,Primary_Contact__c,Primary_Lead__c,CreatedDate From Journey__c Where Lead_Source__c IN : JourneyLeadSource AND (Primary_Contact__c IN :Ids OR Primary_Lead__c IN:Ids) ];
        //Debug.log('lstJourneys records ==>:  '+lstJourneys);
        //Debug.log('lstJourneys ==>:  '+lstJourneys.size());
        for(Journey__c objjourney : [ SELECT Id,Name,Primary_Contact__c,Primary_Lead__c,CreatedDate From Journey__c Where Status__c != 'Completed' AND (Lead_Source__c IN : JourneyLeadSource AND (Primary_Contact__c IN :Ids OR Primary_Lead__c IN:Ids)) ]){
            if(objjourney.Primary_Lead__c != null){
                if(mapLeadIdWithCampaignMembers.containsKey(objjourney.Primary_Lead__c)){
                    CampaignMember cmpMember = mapCampaignMembers.get(mapLeadIdWithCampaignMembers.get(objjourney.Primary_Lead__c));
                    if(date.newinstance(cmpMember.CreatedDate.year(),cmpMember.CreatedDate.month(),cmpMember.CreatedDate.day()) == date.newinstance(objjourney.CreatedDate.year(),objjourney.CreatedDate.month(),objjourney.CreatedDate.day())){
                        Debug.log('In Lead : '+objjourney.Id);
                        Journey__c objLJourney = new Journey__c();
                        objLJourney.Id = objjourney.Id;
                        objLJourney.Status__c = 'Completed';
                        lstJournyesToUpdate.add(objLJourney);
                    }
                }
            }
            if(objjourney.Primary_Contact__c != null){
                if(mapContactIdWithCampaignMembers.containsKey(objjourney.Primary_Contact__c)){
                    CampaignMember cmpMember = mapCampaignMembers.get(mapContactIdWithCampaignMembers.get(objjourney.Primary_Contact__c));
                    if(date.newinstance(cmpMember.CreatedDate.year(),cmpMember.CreatedDate.month(),cmpMember.CreatedDate.day()) == date.newinstance(objjourney.CreatedDate.year(),objjourney.CreatedDate.month(),objjourney.CreatedDate.day())){
                        Debug.log('In Contact : '+objjourney.Id);
                        Journey__c objCJourney = new Journey__c();
                        objCJourney.Id = objjourney.Id;
                        objCJourney.Status__c = 'Completed';
                        lstJournyesToUpdate.add(objCJourney);
                    }
                }
            }
        }
        Debug.log('lstJournyesToUpdate ==>.'+lstJournyesToUpdate);
        Database.update(lstJournyesToUpdate);
    }    
    
    global void finish(Database.BatchableContext bc){
        Set<String> emailtoAddr = setting.get('NotifyEmails');
        List<String> emails = new List<String>();
        emails.addAll(emailtoAddr);
        if(emailtoAddr.size() > 0){
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emails);
            mail.setSubject('Journeys updated ' + a.Status);
            mail.setPlainTextBody('The UpdateJourneyOnCampaignMemberBatch batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
    }    
    
}