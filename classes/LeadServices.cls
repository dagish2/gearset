public with sharing class LeadServices {
    public Lead k {get;set;}
    public Contact c {get;set;}
    public Campaign objCampaign {get;set;}
    public Boolean is_first_touch {get; set;}
    public List<Lead> existingLeads{get; set;}
    public List<Contact> existingContacts{get; set;}
    public static String CampaignId;
    
    
    public LeadServices() {     
    }
    
    // Load init from Email
    public LeadServices(Messaging.inboundEmail email,Messaging.InboundEnvelope env) {
        Set<String> emailIds = new Set<String>();
        Set<String> existingEmailIds = new Set<String>();
        Set<String> newEmailIds = new Set<String>();
        //emailIds.add(email.fromAddress);
        Debug.log('Test : email ::: ' + email);
        if(email.toAddresses != null && email.toAddresses.size() > 0)
            emailIds.addAll(email.toAddresses);
        for(String emailId : emailIds){
            if(emailId.endsWith('apex.salesforce.com') || emailId.endsWith('apex.sandbox.salesforce.com'))
                emailIds.remove(emailId);
        }
        if(email.ccAddresses != null && email.ccAddresses.size() > 0)
            emailIds.addAll(email.ccAddresses);
        //if new create a new lead
        if (emailIds.size() > 0) insert_lead_by_email(emailIds, email, env);
    }
    
    // Load init from Web Handler
    public LeadServices(WWTypes.InboundLead pInboundLead) {
        validateInbloundRecord(pInboundLead);
        
        if(this.c != null)
            RESTInboundLead.contactId = this.c.Id;
        
        //if the lead exists and is not converted, we should update it
        if (this.k != null && !this.k.isConverted) {
            this.update_lead_by_web(pInboundLead);
        }
       
        //if new, create new lead
        if (this.set_first_touch()) this.insert_lead_by_web(pInboundLead);
        
    }
    
    public void convert_lead() {
        try{
            //convert lead
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(this.k.id);
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel 
                                        FROM LeadStatus 
                                        WHERE IsConverted=true 
                                        LIMIT 1
                                       ];
            
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            
            //re-query
            this.k = [  SELECT id, ownerId, Locale__c, Product_Interests__c, Country_Code__c, Product_Line__c, isConverted, convertedContactId, convertedAccountId, 
                      convertedOpportunityId, Company_Size__c, Building_Interested_In__c, CreatedDate, LastModifiedDate,Account__c
                      FROM Lead 
                      WHERE id = :k.id 
                      LIMIT 1
                     ];
            //update account's primary member
            Account a = new Account(
                id = this.k.convertedAccountId,
                Primary_Member__c = this.k.convertedContactId,
                ParentId = this.k.Account__c
            );
            update a;
            
            //update contact's locale
            Contact contactToUpdateLocale = new Contact(
                id = this.k.convertedContactId,
                Locale__c = this.k.Locale__c,
                Product_Interests__c = this.k.Product_Interests__c,
                Product_Line__c = this.k.Product_Line__c,
                Country_Code__c = this.k.Country_Code__c
            );
            update contactToUpdateLocale;
            
            //update opportunity's primary member
            Opportunity o = new Opportunity(
                id = this.k.convertedOpportunityId,
                Primary_Member__c = this.k.convertedContactId,
                Company_Size__c = this.k.Company_Size__c,
                Building__c = this.k.Building_Interested_In__c
            );
            update o;
        } catch(Exception pEx) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadServices','convert_lead',(this.k != null) ? JSON.serializePretty(this.k) : null, pEx)
            );
            throw new applicationException(pEx.getMessage());
        }
    }
    
    public void validateInbloundRecord(WWTypes.InboundLead pInboundLead){
        if(pInboundLead != null && String.isNotBlank(pInboundLead.email)){
            this.k = this.get_recent_lead_by_email(pInboundLead.email);
            //load contact
            this.c = this.get_contact_by_email(pInboundLead.email);
            
            // Anant Kumar on 6th May 2016(ST-289)
            // Changes made by : Anant Kumar(ST-472)
            // Date : 19/July/2016
            Id referrerId = null;
            if(pInboundLead.referrer_sfid != null && pInboundLead.referrer_sfid.length() >= 15 )
            {
                //Anant Kumar on 6th May 2016
                //ST-289
                if(this.k != null){
                    DateTime createdLeadDateTime = this.k.CreatedDate;
                    Date createdDate = date.newinstance(createdLeadDateTime.year(), createdLeadDateTime.month(), createdLeadDateTime.day());
                    Integer dayesBetweenCreatedAndToday = createdDate.daysBetween(System.today());
                    if(dayesBetweenCreatedAndToday <= 60)
                        throw new applicationException('A lead with given email was already submitted in last 60 days');
                    else{
                        this.k.Referrer__c = pInboundLead.referrer_sfid;
                        this.k.Contact_Broker__c = pInboundLead.contact_referrer_only == true ? pInboundLead.contact_referrer_only : false;
                    }
                }
                
                if(this.c != null)
                {
                    if(this.c.Account.Type == 'Member' || this.c.Account.Type == 'Previous Member')
                        throw new applicationException('A member with given email exists');
                    
                    //if(this.k.Opportunities__r != null)
                    for(Opportunity opp : this.c.Opportunities__r){
                        Integer contractSentDateDiff, contractSignedDateDiff;
                        if(opp.Contract_Sent_Date__c != null)
                            contractSentDateDiff = opp.Contract_Sent_Date__c.daysBetween(System.today());
                        if(opp.StageName == 'Closed Won')
                            contractSignedDateDiff = opp.CloseDate.daysBetween(System.today());
                        
                        if(contractSentDateDiff < 60 || contractSignedDateDiff < 60){
                            throw new applicationException('Person has a contract sent/signed in last 60 days');
                        }
                    }
                    for(Tour_Outcome__c tour : this.c.Tours3__r){
                        DateTime createdTourDateTime = tour.CreatedDate;
                        Date createdTourDate = date.newinstance(createdTourDateTime.year(), createdTourDateTime.month(), createdTourDateTime.day());
                        Integer dayesBetweenTourCreatedAndToday = createdTourDate.daysBetween(System.today());
                        if(dayesBetweenTourCreatedAndToday <= 60){
                            throw new applicationException('Person has booked a tour with us in last 60 days');
                        }
                    }
                }
                
                if(pInboundLead.email != null)
                {
                    referrerId = ReferenceHandler.getActiveReference(pInboundLead.email);
                    Debug.log('Test : referrerId ::: ' + referrerId);
                    if(referrerId == null)
                    {
                        Contact referrerContact = [SELECT Id, Type__c FROM Contact WHERE Id =: pInboundLead.referrer_sfid];
                        Setting__c referenceSettingsObject = Settings.get('ReferenceSettings');
                        if(referenceSettingsObject != null) {                     
                            ReferenceSettings refferenceSettingData = (ReferenceSettings)JSON.deserialize(referenceSettingsObject.Data__c, ReferenceSettings.class);
                            System.debug(LoggingLevel.ERROR,'refferenceSettingData :: '+refferenceSettingData);
                            Referral__c referral = new Referral__c();
                            referral.Referral_Email__c = pInboundLead.email;
                            referral.Expires_On__c = System.today().addDays(refferenceSettingData.expireafter);
                            
                            if(pInboundLead.lead_source_detail != null && pInboundLead.lead_source_detail == refferenceSettingData.ReferralSource.LeadSourceDetail) {
                                referral.Referral_Source__c = pInboundLead.lead_source_detail;  
                            } else if(pInboundLead.lead_source != null && pInboundLead.lead_source == refferenceSettingData.ReferralSource.LeadSource) {
                                referral.Referral_Source__c = pInboundLead.lead_source;
                            }
                            else {
                                referral.Referral_Source__c = refferenceSettingData.ReferralSource.Other;
                            }                                        
                            referral.Referrer_Type__c = referrerContact.Type__c;
                            referral.Referrer__c = pInboundLead.referrer_sfid;
                            referral.Start_Date__c = System.today();
                            insert referral;
                            Debug.log('Test : referral ::: ' + referral);
                        }    
                        
                    }
                }
            }
            if(this.c != null && pInboundLead.campaign_sfid != null){
                if(pInboundLead.campaign_sfid !=''){
                    try{
                        this.objCampaign = [SELECT ID From Campaign Where Id = : pInboundLead.campaign_sfid];
                    }catch(Exception pEx){
                        //throw new applicationException('Campaign with specified campaign_sfid does not exists');
                        new ApexDebugLog().createLog( 
                            new ApexDebugLog.Error('LeadServices','validateInbloundRecord',pEx.getMessage(), pEx)
                        );
                    }
                }
            }            
        }else{
            throw new applicationException('Required field missing : Email');
        }
    }
    
    private void update_lead_by_web(WWTypes.InboundLead pInboundLead) {
        try{
            //bindings
            this.lead_bind('firstname',                     pInboundLead.first_name);
            this.lead_bind('lastname',                      pInboundLead.last_name);
            this.lead_bind('company',                       pInboundLead.company_name);
            this.lead_bind('industry',                      pInboundLead.company_industry);     
            this.lead_bind('phone',                         pInboundLead.phone);        
            this.lead_bind('broker_company_name__c',        pInboundLead.broker_name);
            this.lead_bind('broker_email__c',               pInboundLead.broker_email);
            this.lead_bind('broker_phone__c',               pInboundLead.broker_phone);
            this.lead_bind('promo_code__c',                 pInboundLead.promo_code);
            this.lead_bind('referral_id__c',                pInboundLead.referral_id);
            this.lead_bind('referral_code__c',              pInboundLead.referral_code);
            this.lead_bind('locations_interested__c',       BuildingHandler.getMultipicklistValuesFromUUID(pInboundLead.buildings_interested_uuids));
            this.lead_bind('last_inbound_lead_received_at__c',  Datetime.now());
            this.lead_bind('description',                   pInboundLead.notes);
            this.lead_bind('quick_quote_location__c',       pInboundLead.quick_quote_location);
            this.lead_bind('Company_Size__c', pInboundLead.company_size);
            this.lead_bind('Markets_Interested__c', (pInboundLead.market_uuids != null) ? getMarketIdsFromUUIds(pInboundLead.market_uuids) : (pInboundLead.buildings_interested_uuids != null) ? getMarketIdsFromBuildingMarkets(pInboundLead.buildings_interested_uuids) : null);
            this.lead_bind('Ts_and_Cs_Consent__c',			AccountServices.checkIsValidBoolean(pInboundLead.t_and_cs_consent,'t_and_cs_consent')); //Issue ST - 2166
            this.lead_bind('Affiliate_Consent__c',			AccountServices.checkIsValidBoolean(pInboundLead.affiliates_consent,'affiliates_consent')); //Issue ST - 2166
            this.lead_bind('Marketing_Consent__c', 			AccountServices.checkIsValidBoolean(pInboundLead.marketing_consent,'marketing_consent')); //Issue ST - 2166
          	this.lead_bind('Referral_Fail_Reason__c',		pInboundLead.referral_fail_reason != null &&pInboundLead.referral_fail_reason!= '' ? pInboundLead.referral_fail_reason.length() > 255 ? pInboundLead.referral_fail_reason.substring(0, 255):pInboundLead.referral_fail_reason: null);
            if(pInboundLead.tour_building_uuid != null)
                this.lead_bind('Building_Interested_In__c', BuildingHandler.getBuildingIdByUUID(pInboundLead.tour_building_uuid));
            
            //Hemanshu Shah on 8th Apr 2016
            //If a lead is assigned to a queue, salesforce throws error on conversion, hence following code was added to assign the lead to current user
            if(k.OwnerId == null || ((String)k.OwnerId).startswith('00G'))
                k.OwnerId = UserInfo.getUserId();
            
            update this.k;
            RESTInboundLead.leadId = this.k.Id;
        }catch(Exception ex){
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadServices','update_lead_by_web',JSON.serializePretty(pInboundLead), ex)
            );
            throw new applicationException(ex.getMessage());
        }
    }
    
    private void lead_bind(String pField, Object pValue) {
        if (pValue != null)
            this.k.put(pField, pValue);
    }
    
    private void insert_lead_by_web(WWTypes.InboundLead pInboundLead) {
        try{
            //use default assignment rule
            Savepoint sp = Database.setSavepoint();
            Database.DMLOptions dmo                                 = new Database.DMLOptions();
            //Hemanshu Shah on 28 Apr 2016
            //If Lead is being created while not booking the tour, Lead assignment rules should be used,
            //If Lead is being created while booking a tour, Lead Owner should remain current user
            //We have to fix this because while creating lead for tour, if it was assigned to a queue, while converting salesforce was throwing error.
            dmo.assignmentRuleHeader.useDefaultRule = ( pInboundLead.tour_date == null && pInboundLead.tour_building_uuid == null);
            //dmo.assignmentRuleHeader.useDefaultRule = false;
            dmo.EmailHeader.triggerUserEmail = true;
            Debug.Log('LeadServices:insert_lead_by_web:assignmentRuleHeader.useDefaultRule:' + dmo.assignmentRuleHeader.useDefaultRule);
            
            //create new lead
            this.k = new Lead(
                firstname                           = pInboundLead.first_name,
                lastname                            = pInboundLead.last_name,
                company                             = pInboundLead.company_name,
                industry                            = pInboundLead.company_industry,
                email                               = pInboundLead.email,
                phone                               = pInboundLead.phone,
                leadsource                          = pInboundLead.lead_source,
                lead_source_detail__c               = pInboundLead.lead_source_detail,
                utm_campaign__c                     = pInboundLead.utm_campaign,
                utm_content__c                      = pInboundLead.utm_content,
                utm_medium__c                       = pInboundLead.utm_medium,
                utm_source__c                       = pInboundLead.utm_source,
                utm_term__c                         = pInboundLead.utm_term,
                utm_campaign_id__c                  = pInboundLead.utm_campaign_id,
                broker_company_name__c              = pInboundLead.broker_name,
                broker_email__c                     = pInboundLead.broker_email,
                broker_phone__c                     = pInboundLead.broker_phone,
                promo_code__c                       = pInboundLead.promo_code,
                referral_id__c                      = pInboundLead.referral_id,
                referral_code__c                    = pInboundLead.referral_code,
                //CSI-564
                Company_Size__c                     = pInboundLead.company_size,
                //ST-1631, CSI-564 New parameter desks_interested_range will be passed
                Interested_in_Number_of_Desks_Range__c  = (String.isNotBlank(pInboundLead.desks_interested_range)) ? pInboundLead.desks_interested_range :  null,
                //CSI-564
                Interested_in_Number_of_Desks_Min__c = (String.isNotBlank(pInboundLead.desks_interested_min)) ? Integer.valueOf(pInboundLead.desks_interested_min) : null,
                //CSI-564
                Interested_in_Number_of_Desks_Max__c = (String.isNotBlank(pInboundLead.desks_interested_max)) ? Integer.valueOf(pInboundLead.desks_interested_max) : null,
                locations_interested__c             = (pInboundLead.buildings_interested_uuids!=null) ? BuildingHandler.getMultipicklistValuesFromUUID(pInboundLead.buildings_interested_uuids) : null,
                last_inbound_lead_received_at__c    = Datetime.now(),
                description                         = pInboundLead.notes,
                Locale__c                           = pInboundLead.locale,
                quick_quote_location__c             = pInboundLead.quick_quote_location,
                Country_Code__c                     = pInboundLead.country_code,
                Product_Line__c                     = pInboundLead.product_line,
                Product_Interests__c                = getProduct_Interests(pInboundLead.product_interests),
                Market__c                           = pInboundLead.market,
                Generate_Journey__c                 = pInboundLead.generate_journeys != true ? false : pInboundLead.generate_journeys,
                Markets_Interested__c               = (pInboundLead.market_uuids != null) ? getMarketIdsFromUUIds(pInboundLead.market_uuids) : (pInboundLead.buildings_interested_uuids != null) ? getMarketIdsFromBuildingMarkets(pInboundLead.buildings_interested_uuids) : null,
                Move_In_Time_Frame__c               = pInboundLead.move_in_time_frame,
                Ts_and_Cs_Consent__c			    = AccountServices.checkIsValidBoolean(pInboundLead.t_and_cs_consent,'t_and_cs_consent'), //Issue ST - 2166
            	Affiliate_Consent__c				= AccountServices.checkIsValidBoolean(pInboundLead.affiliates_consent,'affiliates_consent'),//Issue ST - 2166
            	Marketing_Consent__c 				= AccountServices.checkIsValidBoolean(pInboundLead.marketing_consent,'marketing_consent'),   //Issue ST - 2166
                Referral_Fail_Reason__c				= pInboundLead.referral_fail_reason != null &&pInboundLead.referral_fail_reason!= '' ? pInboundLead.referral_fail_reason.length() > 255 ? pInboundLead.referral_fail_reason.substring(0, 255):pInboundLead.referral_fail_reason: null
                
                //... more to come... 
            );

            //Interested_in_Number_of_Desks__c =null When company_size blank case; Modified by Krishana Tupe on 10-10-2017 for ST-1516 also refer ST-1471
            //CSI-564 New parameter desks_interested_min will be passed which will be mapped in Interested_in_Number_of_Desks__c
            if(String.isNotBlank(pInboundLead.desks_interested_min)){
                this.k.Interested_in_Number_of_Desks__c = Integer.valueof(pInboundLead.desks_interested_min);
            }else if(String.isNotBlank(pInboundLead.company_size) && pInboundLead.company_size != 'Unknown'){
                this.k.Interested_in_Number_of_Desks__c = this.getCompanySize(pInboundLead.company_size); 
            }else if((String.isNotBlank(pInboundLead.company_size) && pInboundLead.company_size == 'Unknown')){
                this.k.Interested_in_Number_of_Desks__c = 0;
            }
            
            if(pInboundLead.tour_building_uuid != null)
                this.k.Building_Interested_In__c = BuildingHandler.getBuildingIdByUUID(pInboundLead.tour_building_uuid);
            //Anant Kumar on 6th May 2016
            //ST-289 : update lead "Referrer" and "Contact_Broker"
            if(pInboundLead.referrer_sfid != null  && pInboundLead.referrer_sfid.length() >= 15 ){
                this.k.Referrer__c = pInboundLead.referrer_sfid;
                this.k.Contact_Broker__c = pInboundLead.contact_referrer_only == true ? pInboundLead.contact_referrer_only : false;
            }
            
            //End ST-289
            //use lead assignment rules
            this.k.setOptions(dmo);            
            
            //dml
            insert this.k;
            /*
             * Code comented by : Sunil B.
             * Description : campaign member creation code is commented and writen in seprate class (campaignServices)
             * 				 this is done because intialy the campaign meber is inserted and the journeys are created but according to new 
             * 				  campaign member requriment we insert journey firest and then create campaign member	
             * method Name : insertCampaignMember
			*/
            
          /*  if(pInboundLead.campaign_sfid != null){
                if(pInboundLead.campaign_sfid !=''){
                    if(this.k.Id != null){
                        try{
                            this.objCampaign = [SELECT ID From Campaign Where Id = : pInboundLead.campaign_sfid];
                            if(objCampaign != null){
                                CampaignId = String.valueOf(objCampaign.Id);
                            }
                            
                            CampaignMember cm = new CampaignMember(CampaignId=this.objCampaign.Id ,LeadId=this.k.Id, Status='Sent');
                            insert cm;
                        }catch(Exception pEx){
                            Database.rollback(sp);
                            throw new applicationException('Campaign with specified campaign_sfid does not exists');
                        }
                    }
                }
            }
            */
            //Anant Kumar on 6th May 2016
            //Functionality to return salesforce id of the lead created
            RESTInboundLead.leadId = this.k.Id;
            
            //re-query
            this.k = [  SELECT id, ownerId, isConverted, convertedContactId, convertedAccountId, 
                      convertedOpportunityId 
                      FROM Lead 
                      WHERE id = :k.id 
                      LIMIT 1
                     ];
        } catch(Exception pEx) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadServices','insert_lead_by_web',JSON.serializePretty(pInboundLead), pEx)
            );
            throw new applicationException(pEx.getMessage());
        }
    }
    
    private Boolean set_first_touch() {
        this.is_first_touch = (this.k == null) & (this.c == null);
        return this.is_first_touch;
    }
    
    private Lead get_recent_lead_by_email(String pEmail) {      
        Lead[] Ks = [   SELECT id, createddate, email, isConverted, convertedContactId, convertedContact.ownerId, 
                     ownerId, convertedAccountId, convertedOpportunityId
                     FROM Lead 
                     WHERE email = :pEmail 
                     ORDER BY createddate DESC
                     LIMIT 1
                    ];
        
        return Ks.size() > 0 ? Ks[0] : null;
    }
    
    private Contact get_contact_by_email(String pEmail) {       
        Contact[] Ks = [    SELECT id, AccountId, ownerId, id_kind__c, Account.Type, is_primary_member__c,
                             (Select Id, StageName, CloseDate, Contract_Sent_Date__c From Opportunities__r),
                             (Select CreatedDate From Tours3__r)
                        FROM Contact 
                        WHERE email = :pEmail 
                        ORDER BY createddate DESC
                        LIMIT 1
                       ];
        
        return Ks.size() > 0 ? Ks[0] : null;
    }
    
    private void insert_lead_by_email(Set<string> emailIds, Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        try{
            //use default assignment rule
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            
            List<Lead> newLeads = new List<Lead>();
            String partnerShipRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partnership').getRecordTypeId();
            Debug.log('Test : partnerShipRecordTypeId ::: ' + partnerShipRecordTypeId);
            for(String emailId: emailIds){
                Lead leadnew = new Lead();
                leadnew.LastName = emailId.substring(0, emailId.indexOf('@'));
                leadnew.Company = this.getContactCompany(email.fromAddress);
                leadnew.Email = emailId;
                leadnew.RecordTypeId = partnerShipRecordTypeId;
                leadnew.email_origin__c = env.fromAddress;
                leadnew.leadsource = 'Inbound Email';
                leadnew.lead_source_detail__c = 'joinus@wework.com';
                leadnew.Generate_Journey__c = false;
                leadNew.Status = 'Open';
                if(!Test.isRunningTest()){
                    //use lead assignment rules
                    leadnew.setOptions(dmo);
                }
                newLeads.add(leadnew);
            }
            Debug.log('Test : newLeads before insert ::: ' + newLeads);
            insert newLeads;
            Debug.log('Test : newLeads after insert ::: ' + newLeads);
            //existingLeads.addAll(newLeads);
            Set<Id> leadIds = new Set<Id>();
            for(Lead insertedLead : newLeads)
                leadIds.add(insertedLead.Id);
            existingLeads = Database.Query('SELECT ' + String.join(LeadConvertor.getLeadFields(), ',') + ' FROM Lead WHERE id in :leadIds');
        } catch(Exception pEx) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadServices','insert_lead_by_email',JSON.serializePretty(email), pEx)
            );
            throw new applicationException(pEx.getMessage());
        }
    }
    
    private String getContactFirstname(String pFrom) {      
        String result;
        try {
            result = pFrom.substring(0,pFrom.indexOf(' '));  
        }
        catch(Exception pEx) {
            result = ''; //default value
        }
        
        return result;
    }
    
    private String getContactLastname(String pFrom) {
        String result;
        try {
            result = pFrom.indexOf(' ') > 0 ? 
                pFrom.substring(pFrom.indexOf(' ')) :
            pFrom;
        }
        catch(Exception pEx) {
            result = ''; //default value
        }
        
        return result;
    }
    
    private String getContactCompany(String pEmail) {
        String result;
        try {
            result = pEmail.indexOf('@') > 0 ? 
                pEmail.substring(pEmail.indexOf('@') + 1) :
            pEmail;
        }
        catch(Exception pEx) {
            result = ''; //default value
        }
        
        return result;
    }
    
    public static String getProduct_Interests(String [] Product_Interests) {
        String result;
        try {
            result = String.join(Product_Interests, ';');
        }
        catch(Exception pEx) {
            result = ''; //default value
            /*new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadServices','getProduct_Interests', (Product_Interests != null) ? String.join(Product_Interests, ',') : null, pEx)
            );*/
        }
        return result;
    }
    
    public string call_insert_lead_by_web(WWTypes.InboundLead body){
        try{
            validateInbloundRecord(body);
            insert_lead_by_web(body);
            return this.k.Id;
        } catch(Exception pEx) {
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadServices','call_insert_lead_by_web',JSON.serializePretty(body), pEx)
            );
            throw new applicationException(pEx.getMessage());
        }
        
    }
    
    //ST-676
    //Get Market Ids from market_uuids
    //Date : 13/Sep/2016
    public string getMarketIdsFromUUIds(String[] marketUUIds){
        String result;
        String[] marketNames = new String[]{};
        Map<String, String> mapUUIDWithName = new Map<String, String>();
        try {
            //collect buildings
            for(Market__c market : [SELECT Name, UUID__c FROM Market__c]) {
                mapUUIDWithName.put(market.UUID__c, market.Name);
            }
            for(String marketUUID : marketUUIds) {
                String marketName = mapUUIDWithName.get(marketUUID);
                if (marketName != null) marketNames.add(marketName);
            }

            //separate values with semi-colon
            result = String.join(marketNames, ';');
            //check if no matches
            if (marketNames.size() == 0) result = null;

        }
        catch(Exception pEx) {
            result = null; //default value
            /*new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadServices','getMarketIdsFromUUIds',(marketUUIds != null) ? String.join(marketUUIds, ',') : null, pEx)
            );*/
        }
        return result;
    }
    
    //ST-683
    //Get Markets from BuildingMarkets
    //Date : 20/Sep/2016
    public string getMarketIdsFromBuildingMarkets(String[] buildingsInterestedUUIds){
        String result;
        String[] buildingMarketNames = new String[]{};
        String[] buildingId = new String[]{};
        Set<String> setBuildingsInterestedUUIds = new Set<String>();
        Set<Id> setBuildingId = new Set<Id>();
        try {
            //collect buildings
            for(String buildingsInterestedUuid : buildingsInterestedUUIds) {
                setBuildingsInterestedUUIds.add(buildingsInterestedUuid);
            }
            Debug.log(': Test : setBuildingsInterestedUUIds ::'+setBuildingsInterestedUUIds);
            
            for(Building__c  building : [SELECT Id FROM Building__c Where UUID__c IN : setBuildingsInterestedUUIds ]) {
                setBuildingId.add(building.Id);
            }
            Debug.log(': Test : setBuildingId ::'+setBuildingId);
            
            for(Building_Market__c buildingMarket : [SELECT Id, Name, Building__c,Market__r.Name FROM Building_Market__c Where Building__c IN : setBuildingId]) {
                Debug.log(': Test : buildingMarket ::'+buildingMarket);
                buildingMarketNames.add(buildingMarket.Market__r.Name);
            }
            Debug.log(': Test : buildingMarketNames ::'+buildingMarketNames);
            
            //separate values with semi-colon
            result = String.join(buildingMarketNames, ';');
            Debug.log(': Test : result ::'+result);
            //check if no matches
            if (buildingMarketNames.size() == 0) result = null;
        } catch(Exception pEx) {
            result = null; //default value
            /*new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LeadServices','getMarketIdsFromBuildingMarkets', (buildingsInterestedUUIds != null) ? String.join(buildingsInterestedUUIds, ',') : null, pEx)
            );
            throw new applicationException(pEx.getMessage());*/
        }
        return result;
    }
 
    public Integer getCompanySize(String size){
        Debug.log('size1-----'+size);
        Integer lowerSize;
        size = size.replace(',','');
        size = size.replace('desks','');
        size = size.replace('desk','');
        size = size.replace('people','');
        size = size.replace('peoples','');
        size = size.replace('<','');
        size = size.deleteWhitespace();
        Debug.log('size2-----'+size);
        if(size.contains('-')){
            size = size.split('-')[0];
            try{
                lowerSize = Integer.valueOf(size);
            }catch(Exception ex){
                lowerSize = 1;
            }
            //lowerSize = Integer.valueOf(size.split('-')[0]);
        }else if(size.contains('+')){
            try{
                lowerSize = Integer.valueOf(size.split('\\+')[0]);
            }catch(Exception ex){
                lowerSize = 1;
            }
        }else{
            try{
                lowerSize = Integer.valueOf(size);Debug.log('In else direct size2-----'+size);
            }catch(Exception ex){
                lowerSize = 1;
            }
        }
        Debug.log('lowerSize-----'+lowerSize);
        return lowerSize;
    }
 

 
    //Custom Exception Class
    public class applicationException extends Exception {}
    
    public class ReferenceSettings{
        public Integer expireafter {get; set;}
        public ReferralSource referralSource {get; set;}    
    }
    class ReferralSource {
        public String LeadSourceDetail {get; set;}
        public String LeadSource {get; set;}
        public String Other {get; set;}
    }
}