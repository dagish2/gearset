public with sharing class TaskServices {
	public Lead k {get;set;}
	public Contact c {get;set;}
    public List<Lead> existingLeads{get; set;}
    public List<Contact> existingContacts{get; set;}
	public Boolean is_first_touch {get; set;}

	public TaskServices() {		
	}
	public TaskServices(List<Lead> existingLeads, List<Contact> existingContacts) {
        this.existingLeads = existingLeads;
        this.existingContacts = existingContacts;
	}
	public TaskServices(LeadServices ls) {
		this.k = ls.k;
		this.c = ls.c;
        this.existingLeads = ls.existingLeads;
		this.existingContacts = ls.existingContacts;
		this.is_first_touch = ls.is_first_touch;
	}
    
    public TaskServices(Lead k, Contact c, Boolean is_first_touch) {
        this.k = k;
        this.c = c;
        this.is_first_touch = is_first_touch;
    }
    public Task formatTask(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        try{
            Task t = new Task(
			type 			= 'Email',
			subject 		= email.subject,
			WhoId 			= this.getWhoId(),
			ownerId 		= this.getOwnerId(),
			description 	= this.getContentBody(email.subject, email.plainTextBody),
			WhatId 			= this.getWhatId(),
			interaction__c 	= 'Inbound'
		);
        Debug.Log('Test : t ::: ' + t);
             return t;
        }catch(Exception e){
            debug.Log('Exception:TaskServices:'+e.getLineNumber()+'--Message--'+e.getMessage());
            return null;
        }
        
       
    }
    
	public List<Task> create_task_from_email(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
        debug.Log('email---'+email);
		List<Task> listTask = new List<Task>();
        for(Lead exLead : existingLeads){
            this.k = exLead;
            listTask.add(this.formatTask(email, env));
        }
        for(Contact exContact : existingContacts){
            this.k = null;
            this.c = exContact;
            listTask.add(this.formatTask(email, env));
        }
        debug.Log('listTask---------TaskServ'+listTask);
        return listTask;
	}

	public Task create_task_from_web(WWTypes.InboundLead pInboundLead) {
		//create a new task
		Task t = new Task(
			type 						= 'Website', //review this
			subject 				= 'Inbound Lead submission', //default we will update it later
			WhoId 					= this.getWhoId(),
			ownerId 				= this.getOwnerId(),
			description 		= 'Inbound Lead', //review this
			WhatId 					= null, //review this
            Locale__c 		= pInboundLead.locale,
            Product_Interests__c = LeadServices.getProduct_Interests(pInboundLead.product_interests),
            Country_Code__c = pInboundLead.country_code,
			interaction__c 	= 'Inbound',
			Product_Line__c = pInboundLead.product_line,
			first_touch__c  = this.is_first_touch,
            Market__c		= pInboundLead.market
		);

		String id_kind = this.getContactIDKind();

		//check if member
		if (id_kind != null && id_kind.equalsIgnoreCase('Member'))	{
			t.subject = 'Current Member followup';
		}

		//check if it's a tour
		if (pInboundLead.tour_date != null && pInboundLead.tour_building_uuid != null) {
			t.subject = 'Selling';
		}

		//custom bindings

		//utms
		t.utm_campaign__c 		= pInboundLead.utm_campaign;
		t.utm_campaign_id__c	= pInboundLead.utm_campaign_id;
		t.utm_content__c			= pInboundLead.utm_content;
		t.utm_medium__c				= pInboundLead.utm_medium;
		t.utm_source__c				= pInboundLead.utm_source;
		t.utm_term__c					= pInboundLead.utm_term;

		//lead source
		t.lead_source__c 				= pInboundLead.lead_source;
		t.lead_source_detail__c = pInboundLead.lead_source_detail;

    // review this
    if (pInboundLead.tour_date != null) {
        t.activityDate = pInboundLead.tour_date;
    }
		debug.Log('create_task_from_email--t+_+_+_+'+t);
		return t;	
	}

	private String getContentBody(String pSubject, String pPlainTextBody) {
		String result;
		try {
			result = String.format(
								'Subject: {0} \nBody: \n\n{1}', 
								new String[]{
									pSubject != null ? pSubject : 'n/a',
									pPlainTextBody != null ? pPlainTextBody : 'n/a'
								}
			);
		}
		catch(Exception pEx) {
			result = ''; //default value
		}
	
		return result;
	}

	private String getContactIDKind() {
		String result = null;
		try {
			result = this.c.id_kind__c;
		}
		catch(Exception pEx) {
			result = null; //default value
		}
		
		return result;
	}

	private Id getWhoId() {
		Id result;
	
		//get lead id or converted contact id
		if (this.k != null) {
			result = this.k.isConverted ? this.k.convertedContactId : this.k.id;	
		}
		
		//get contact id or accept previous lead/contact id value
		result = this.c != null ? this.c.id : result;

		return result;
	}

	private Id getOwnerId () {
		Id result;
		try {

			//get owner from lead
			if (this.k != null) {
				result = this.k.isConverted ? 
								this.k.convertedContact.ownerId :
								this.k.ownerId;	
			}

			//get owner from contact
			if (this.c != null) {
                debug.Log('this.c'+this.c);
				result = this.c.OwnerId;	
			}			

			result = [	SELECT isActive 
									FROM User 
									WHERE id = :result 
									LIMIT 1
								].isActive ?
								result :
								UserInfo.getUserId();		
		}
		catch(Exception pEx) {
			result = UserInfo.getUserId(); //default value aka fallback user
		}
		
		return result;
	}

	private Id getWhatId() {
		Id result = null;

		if (this.k != null) {
			result = this.k.isConverted ? 
								OpportunityServices.getMostRecentOpportunityId(this.k.convertedAccountId) : 
								null;
		}

		if (this.c != null) {
			result = OpportunityServices.getMostRecentOpportunityId(this.c.AccountId);
		}

		return result;
	}
}