public class TaskServiceQueueable implements Queueable {
    public TaskServices taskService;
    public WWTypes.InboundLead inboundLead;
    public String Subject;
    public Id ownerId;
    public Id tourId;
    
    public TaskServiceQueueable(TaskServices ts, WWTypes.InboundLead pInboundLead, String pSubject, Id pOwnerId, Id pTourId) {
        this.taskService = ts;
        this.inboundLead = pInboundLead;
        this.Subject = pSubject;
        this.ownerId = pOwnerId;
        this.tourId = pTourId;
    }
    
    public void execute(QueueableContext context) {
        try{
            Task t = taskService.create_task_from_web(inboundLead);
            List<Contact> lstContcat = new List<Contact>();
            List<Journey__c> lstJourney = new List<Journey__c>();
            
            if(inboundLead.sf_journey_uuid != null && inboundLead.sf_journey_uuid != '')
                lstJourney = [Select Id From Journey__c Where UUID__c =: inboundLead.sf_journey_uuid];
            
            Settings.FieldMappings mapContactToActivity;
            set<String> setContactFields = new set<String>();
            list<String> lstContactFields = new list<String>();
            mapContactToActivity = Settings.getFieldMappings('ContactToActivity');
            if(mapContactToActivity == null)
                mapContactToActivity = Contact2Activity();
            for(Settings.MappedField field : mapContactToActivity.mappings.values()){
                setContactFields.add(field.fieldname.toLowerCase());
            }
            
            lstContactFields.addAll(setContactFields);
            String str_contact_uuid = inboundLead.contact_uuid;
            if(inboundLead.contact_uuid != '' && inboundLead.contact_uuid != null)
                lstContcat = Database.Query('Select ' + String.join(lstContactFields, ',') + ' From Contact Where UUID__c =: str_contact_uuid');
            
            t.Notes__c           = 'Created by Tour API';    
            t.Subject            = subject;
            t.Description        = inboundLead.tour_notes;        
            t.WhatId             = tourId;
            
            if(lstContcat != null && lstContcat.size()>0){ 
                for(String field : mapContactToActivity.mappings.keySet()){
                    Settings.MappedField mappedField = mapContactToActivity.mappings.get(field);
                    if(mappedField.isvalue == true)
                        t.put(field, mappedField.value);
                    else
                        t.put(field, lstContcat[0].get(mappedField.fieldname));
                }
            }
            
            if (ownerId != null)
                t.OwnerId = UserInfo.getUserId(); 
            
            insert t;
            
        } catch(Exception ex) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('TaskServiceQueueable','execute', JSON.serialize(inboundLead), ex)
            );
        }
    }
    
    
    public static Settings.FieldMappings Contact2Activity() {
        Settings.FieldMappings contactToActivityMappings = new Settings.FieldMappings();
        contactToActivityMappings.version = 1;
        contactToActivityMappings.mappings = new Map<String, Settings.MappedField>();
        contactToActivityMappings.mappings.put('Phone__c', new Settings.MappedField('Phone'));
        contactToActivityMappings.mappings.put('Locale__c', new Settings.MappedField('Locale__c'));
        contactToActivityMappings.mappings.put('Email__c', new Settings.MappedField('Email'));
        contactToActivityMappings.mappings.put('Market__c', new Settings.MappedField('Market__c'));
        contactToActivityMappings.mappings.put('Product_Interests__c', new Settings.MappedField('Product_Interests__c'));
        contactToActivityMappings.mappings.put('Country_Code__c', new Settings.MappedField('Country_Code__c'));
        contactToActivityMappings.mappings.put('Quick_Quote_Location__c', new Settings.MappedField('Quick_Quote_Location__c'));
        contactToActivityMappings.mappings.put('Lead_Source__c', new Settings.MappedField('LeadSource'));
        contactToActivityMappings.mappings.put('Lead_Source_Detail__c', new Settings.MappedField('Lead_Source_Detail__c'));
        contactToActivityMappings.mappings.put('utm_campaign__c', new Settings.MappedField('utm_campaign__c'));
        contactToActivityMappings.mappings.put('utm_campaign_id__c', new Settings.MappedField('utm_campaign_id__c'));
        contactToActivityMappings.mappings.put('utm_content__c', new Settings.MappedField('utm_content__c'));
        contactToActivityMappings.mappings.put('utm_medium__c', new Settings.MappedField('utm_medium__c'));
        contactToActivityMappings.mappings.put('utm_source__c', new Settings.MappedField('utm_source__c'));
        contactToActivityMappings.mappings.put('utm_term__c', new Settings.MappedField('utm_term__c'));
        return contactToActivityMappings;
    }
    
    public class TaskServiceQueueableException extends Exception{}
}