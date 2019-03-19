/************************************************************************************************************************************
	Author 		: 	Shivprasad Patil
	Description : 	This class helps to exposes the Lead via SFDC's REST API

	History     :	 
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			8 June 2018			Shivprasad Patil		  -
**************************************************************************************************************************************/
public class RESTInboundLeadAPIHelper {
    public static Boolean isLeadFromWeb = false;
     /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method used to get Leads by given email address
    Created Date		: 07,June 2018
    Last Modified By 	: 
    Last Modified Date  : 
   *****************************************************************************************************************************/
    public static lead getRecentLeadByEmail(string pEmail){
       List<Lead> lstOfLead = [ SELECT Id, CreatedDate, Email, IsConverted, ConvertedContactId, ConvertedAccountId, ConvertedOpportunityId, 
                              OwnerId FROM Lead WHERE Email =: pEmail ORDER BY createddate DESC LIMIT 1 ];
       return lstOfLead.size() > 0 ? lstOfLead[0] : null;
    }
    
     /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method used to get Contact by given email address
    Created Date		: 07,June 2018
    Last Modified By 	: 
    Last Modified Date  : 
   *****************************************************************************************************************************/
    public static contact getRecentContactByEmail(string pEmail){
         List<Contact> lstOfContact = [ SELECT Id, AccountId, Account.Type, OwnerId, Id_kind__c,
                                    (SELECT Id, StageName, Contract_Sent_Date__c, CloseDate FROM Opportunities__r),
                                    (SELECT CreatedDate FROM Tours3__r) FROM Contact WHERE Email =: pEmail 
                                    ORDER BY createddate DESC LIMIT 1];
         return lstOfContact.size() > 0 ? lstOfContact[0] : null;
    }
    
     /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method used to convert array of product interest into string seperated by semi-colon
    Created Date		: 07,June 2018
    Last Modified By 	: 
    Last Modified Date  : 
   *****************************************************************************************************************************/
    public string getProductInterests(String [] Product_Interests) {
        try {
            return String.join(Product_Interests, ';');
        } catch(Exception pEx) {
            return '';
        }
    }
    
     /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method used to return marked Names from given UUID's
    Created Date		: 07,June 2018
    Last Modified By 	: 
    Last Modified Date  : 
   *****************************************************************************************************************************/
    public string getMarketIdsFromUUIds(List<String> lstOfMarketUUIds){
        try {
            List<String> lstOfMarketNames = new List<String>();
            for(Market__c itrMarket : [SELECT Name, UUID__c FROM Market__c WHERE UUID__c IN :new Set<String>(lstOfMarketUUIds)]) 
                lstOfMarketNames.add(itrMarket.Name);
            if(lstOfMarketNames.size() == 0)
                return null;
            return String.join(lstOfMarketNames,';');    
        }catch(Exception pEx) {
            return null;
        }
    }
    
     /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method used to market names from building interest's
    Created Date		: 07,June 2018
    Last Modified By 	: 
    Last Modified Date  : 
   *****************************************************************************************************************************/
    public string getMarketIdsFromBuildingMarkets(List<String> lstOfBuildingsInterestedUUIds){
        try{
            List<String> lstBuildingMarketNames = new List<String>();
            for(Building__c  itrBuilding : [SELECT Id,(SELECT Market__r.Name FROM Building_Markets__r) FROM Building__c Where UUID__c IN :new Set<String>(lstOfBuildingsInterestedUUIds)]) {
                for(Building_Market__c itrBuildingMarket : itrBuilding.Building_Markets__r)
                    lstBuildingMarketNames.add(itrBuildingMarket.Market__r.Name);
            }
            if(lstBuildingMarketNames.size() == 0)
                return null;
            return String.join(lstBuildingMarketNames,';');
        }catch(Exception pEx) {
            return null;
        }
    }
    
  /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method used to insert lead which is coming from web
    Created Date		: 07,June 2018
    Last Modified By 	: 
    Last Modified Date  : 
   *****************************************************************************************************************************/
    public Id insertLeadByWeb(WWTypes.InboundLead pInboundLead) {
        //Lead Assignment rule is commented by Krishana Tupe on 29-11-2018 for Lead/Journey Hold Back flow as suggested by Rashad(CSI)
        //Database.DMLOptions dmo = new Database.DMLOptions();
        //dmo.assignmentRuleHeader.useDefaultRule = ( pInboundLead.tour_date == null && pInboundLead.tour_building_uuid == null);
        //dmo.EmailHeader.triggerUserEmail = true;
        isLeadFromWeb = true;
        Lead objLead = setInterestedInDesks(pInboundLead, getLeadByMapping(pInboundLead));
        //objLead.setOptions(dmo);      
        SaveResult sr = new SaveResult(Database.insert(objLead));
        if(sr.IsSuccess){
            return Id.valueOf(sr.Id);  
        }
        return null;
    }
    
    /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method used to insert lead coming from Email2Lead.
    Created Date		: 07,June 2018
    Last Modified By 	: 
    Last Modified Date  : 
   *****************************************************************************************************************************/
    public set<Id> insertLeadByEmail(set<string> emailIds, Messaging.inboundEmail pEmail, Messaging.InboundEnvelope pEnv){
        set<Id> setIds = new set<Id>();
        List<Lead> newLeads = new List<Lead>();
        //use default assignment rule
        //Database.DMLOptions dmo = new Database.DMLOptions();
       // dmo.assignmentRuleHeader.useDefaultRule = true;
        debug.log('insertLeadByEmail emailIds=>'+emailIds);
        for(String emailId: emailIds){
            Lead leadnew = new Lead();
            leadnew.LastName = emailId.substring(0, emailId.indexOf('@'));
            leadnew.Company = this.getContactCompany(pEmail.fromAddress);
            leadnew.Email = emailId;
            leadnew.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partnership').getRecordTypeId();
            leadnew.email_origin__c = pEnv.fromAddress;
            leadnew.leadsource = 'Inbound Email';
            leadnew.lead_source_detail__c = 'joinus@wework.com';
            leadnew.Generate_Journey__c = false;
            leadNew.Status = 'Open';
            //if(!Test.isRunningTest())
               // leadnew.setOptions(dmo);
            newLeads.add(leadnew);            
        }
        isLeadFromWeb = true;
        Debug.Log('insertLeadByEmail newLeads=>'+newLeads);
        Database.SaveResult[] srList = Database.insert(newLeads);
        for(Database.SaveResult sr : srList){
            if (sr.isSuccess()) {
                setIds.add(sr.getId());
            }
        }
        return setIds;
    }  
    
   /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method used field mapping for given payLoad
    Created Date		: 08,June 2018
    Last Modified By 	: 
    Last Modified Date  : 
   *****************************************************************************************************************************/
    private lead getLeadByMapping(WWTypes.InboundLead pInboundLead){
        return new Lead(
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
            Company_Size__c                     = pInboundLead.company_size,
            Interested_in_Number_of_Desks_Range__c  = (String.isNotBlank(pInboundLead.desks_interested_range)) ? pInboundLead.desks_interested_range :  null,
            Interested_in_Number_of_Desks_Min__c = (String.isNotBlank(pInboundLead.desks_interested_min)) ? Integer.valueOf(pInboundLead.desks_interested_min) : null,
            Interested_in_Number_of_Desks_Max__c = (String.isNotBlank(pInboundLead.desks_interested_max)) ? Integer.valueOf(pInboundLead.desks_interested_max) : null,
            locations_interested__c             = (pInboundLead.buildings_interested_uuids!=null) ? BuildingHandler.getMultipicklistValuesFromUUID(pInboundLead.buildings_interested_uuids) : null,
            last_inbound_lead_received_at__c    = Datetime.now(),
            description                         = pInboundLead.notes,
            Locale__c                           = pInboundLead.locale,
            quick_quote_location__c             = pInboundLead.quick_quote_location,
            Country_Code__c                     = pInboundLead.country_code,
            Product_Line__c                     = pInboundLead.product_line,
            Product_Interests__c                = getProductInterests(pInboundLead.product_interests),
            Market__c                           = pInboundLead.market,
            Generate_Journey__c                 = pInboundLead.generate_journeys == false ? false : true,
            Markets_Interested__c               = (pInboundLead.market_uuids != null) ? getMarketIdsFromUUIds(pInboundLead.market_uuids) : (pInboundLead.buildings_interested_uuids != null) ? getMarketIdsFromBuildingMarkets(pInboundLead.buildings_interested_uuids) : null,
            Move_In_Time_Frame__c               = pInboundLead.move_in_time_frame,
            Ts_and_Cs_Consent__c			    = checkIsValidBoolean(pInboundLead.t_and_cs_consent,'t_and_cs_consent'), 
            Affiliate_Consent__c				= checkIsValidBoolean(pInboundLead.affiliates_consent,'affiliates_consent'),
            Marketing_Consent__c 				= checkIsValidBoolean(pInboundLead.marketing_consent,'marketing_consent'), 
            Referral_Fail_Reason__c				= pInboundLead.referral_fail_reason != null &&pInboundLead.referral_fail_reason!= '' ? pInboundLead.referral_fail_reason.length() > 255 ? pInboundLead.referral_fail_reason.substring(0, 255):pInboundLead.referral_fail_reason: null,
            Campaign_Id__c                      = (pInboundLead.campaign_sfid != null && pInboundLead.campaign_sfid != '') ? pInboundLead.campaign_sfid : null,
            LeadSource_Sub_Type__c				= pInboundLead.lead_source_subtype, //Issue ST-3222
            Contact_Broker__c  					= (pInboundLead.contact_referrer_only != null && pInboundLead.contact_referrer_only==true) ? pInboundLead.contact_referrer_only : false,
            Personal_Mailing_Street__c			= (pInboundLead.lead_address != null && pInboundLead.lead_address.street != null && pInboundLead.lead_address.street != '') ? pInboundLead.lead_address.street : null,
            Personal_Mailing_City__c			= (pInboundLead.lead_address != null && pInboundLead.lead_address.city != null && pInboundLead.lead_address.city != '') ? pInboundLead.lead_address.city : null,
            Personal_Mailing_State__c			= (pInboundLead.lead_address != null && pInboundLead.lead_address.state != null && pInboundLead.lead_address.state != '') ? pInboundLead.lead_address.state : null,
            Personal_Mailing_PostalCode__c		= (pInboundLead.lead_address != null && pInboundLead.lead_address.zip != null && pInboundLead.lead_address.zip != '') ? pInboundLead.lead_address.zip : null,
            Personal_Mailing_Country__c			= (pInboundLead.lead_address != null && pInboundLead.lead_address.country != null && pInboundLead.lead_address.country != '') ? pInboundLead.lead_address.country : null
            //Number_of_Full_Time_Employees__c    = (String.isNotBlank(pInboundLead.company_size) && pInboundLead.company_size != 'Unknown') ? Integer.valueOf(this.getCompanySize(pInboundLead.company_size)) : null
        );
    }
    
    /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method used to set intrested in desks
    Created Date		: 08,June 2018
    Last Modified By 	: 
    Last Modified Date  : 
   *****************************************************************************************************************************/
    private lead setInterestedInDesks(WWTypes.InboundLead pInboundLead, Lead objLead){
        if(String.isNotBlank(pInboundLead.desks_interested_min)){
            objLead.Interested_in_Number_of_Desks__c = Integer.valueof(pInboundLead.desks_interested_min);
        }else if(String.isNotBlank(pInboundLead.company_size) && pInboundLead.company_size != 'Unknown'){
            objLead.Interested_in_Number_of_Desks__c = this.getCompanySize(pInboundLead.company_size); 
        }else if((String.isNotBlank(pInboundLead.company_size) && pInboundLead.company_size == 'Unknown')){
            objLead.Interested_in_Number_of_Desks__c = 0;
        }
        if(pInboundLead.tour_building_uuid != null)
            objLead.Building_Interested_In__c = BuildingHandler.getBuildingIdByUUID(pInboundLead.tour_building_uuid);
        if(  String.isNotBlank(pInboundLead.referrer_sfid) && pInboundLead.referrer_sfid.length() >= 15 ){
            objLead.Referrer__c = pInboundLead.referrer_sfid;
            objLead.Contact_Broker__c = (pInboundLead.contact_referrer_only != null && pInboundLead.contact_referrer_only==true) ? pInboundLead.contact_referrer_only : false;
        }
        Debug.log('objLead==>'+objLead);
        return objLead;
    }
    
    /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method used to get domain of company using email
    Created Date		: 08,June 2018
    Last Modified By 	: 
    Last Modified Date  : 
   *****************************************************************************************************************************/
    private string getContactCompany(string pEmail) {
        string result;
        try {
            result = pEmail.indexOf('@') > 0 ? pEmail.substring(pEmail.indexOf('@') + 1) : pEmail;
        }
        catch(Exception pEx) {
            result = ''; 
        }
        return result;
    }
    
   /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method used to get company size.
    Created Date		: 08,June 2018
    Last Modified By 	: 
    Last Modified Date  : 
   *****************************************************************************************************************************/
    public Integer getCompanySize(String size){
        Debug.log('size1-----'+size);
        Integer lowerSize;
        size = size.replaceAll('(,|desks|desk|people|peoples|<)','');
        size = size.deleteWhitespace();
        Debug.log('size2-----'+size);
        size = size.split('(-|\\+)')[0];
        Debug.log('size3-----'+size);
        try{
            return Integer.valueOf(size);
        }catch(Exception ex){
            return 1;
        }
    }
    
   /****************************************************************************************************************************
    Author 				: Shivprasad Patil
    Description  		: This method wheather boolean value is valid or not.
    Created Date		: 08,June 2018
    Last Modified By 	: 
    Last Modified Date  : 
   *****************************************************************************************************************************/
    public Boolean checkIsValidBoolean(Object flag,String fieldName){  
            Debug.log('In checkIsValidBoolean==');
            String strFlag;
            Debug.log('flag=='+flag);
            if(flag != null){
                strFlag = String.valueOf(flag).toLowerCase();                               
            } 
            Debug.log('strFlag=='+strFlag);
            Boolean result = (strFlag=='true' || strFlag=='1') ? True : ( (strFlag=='false' || strFlag=='0' || strFlag==null || strFlag=='') ? False : null );
             Debug.log('result=='+result);
            if(result==null)
                throw new RESTInboundLeadAPIController.InboundLeadException('Invalid boolean or String: '+strFlag+' of Field '+fieldName+' ');
            return result;
    }
}