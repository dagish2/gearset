/************************************************************************************************************************************
  Author        : Dipak Pawar
  Description   : 
   
  History:
----------------------------------------------------------------------------------------------------------------------------------
  VERSION       DATE                AUTHOR              DETAIL                  ISSUE
    1           5th June 2018       Dipak Pawar         Initial Developement    ST-     
**************************************************************************************************************************************/
public class OpportunityHelper {
    public static List<OpportunityTeamMember> lstOpportunityTeamMembers = new List<OpportunityTeamMember>();
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method return the latest open Opportunity by given AccountId or Primary ConatactId for the given building
        Created Date        :   05 June 2018
        Issue No            :   ST-2484, ST-2486
    **************************************************************************************************************************************/
    public static Opportunity getOrCreateOpportunity(RESTAPITourModelsV2.Input body, Id accountId, Id contactId, Id opportunityId, Building__c objBuilding){
      	Opportunity objOpportunity;
        Id oldOpportunityBuilding;
        Set<String> locationInterested = new Set<String>();
        Debug.log('Limits.getQueries() in OpportunityHelper.getOrCreateOpportunity Insert 01::'+Limits.getQueries());
        if(opportunityId != null && String.isNotBlank(opportunityId)){
            List<Opportunity> lstOpportunities = new List<Opportunity>();
                lstOpportunities  = [SELECT Id, RecordTypeId, Building__c, Building__r.Name, Primary_Member__c, Count_of_Desk__c, Locations_Interested__c, CreatedDate, LastModifiedDate, StageName, Tour_Booked_By__c, (Select Id, Name From Tour_Outcome__r order by CreatedDate DESC LIMIT 1) FROM Opportunity WHERE Id =: opportunityId ORDER BY LastModifiedDate LIMIT 1];            
            if(lstOpportunities.size() > 0)
                objOpportunity = lstOpportunities[0]; 
        } else {
            // Get or Create Opportunity
            // ST-2485 : if open Opportunity found for Primary member/building
            objOpportunity = OpportunityHelper.getLatestOpenOpportunity(accountId, contactId, objBuilding);
            Debug.log('Limits.getQueries() in OpportunityHelper.getOrCreateOpportunity Insert 02::'+Limits.getQueries());
            // ST-2486 : else create new Opportunity        
            if(objOpportunity == null){            
                objOpportunity = OpportunityHelper.createOpportunity(contactId, 'Selling');
                objOpportunity.Tour_Scheduled__c = System.today();
                objOpportunity.Tour_Notes__c = body.tour_notes;
                objOpportunity.Owner_Auto_Assign__c = (body.booked_by_sales_lead != null && body.booked_by_sales_lead) ? false : true;
                objOpportunity.Referral_Fail_Reason__c = String.isNotBlank(body.referral_fail_reason) ? body.referral_fail_reason.length() > 255 ? body.referral_fail_reason.substring(0, 255) : body.referral_fail_reason : null;
                objOpportunity.Tour_Booked_By__c = String.isNotBlank(body.booked_by_contact_id) ? body.booked_by_contact_id : null;
                objOpportunity.Building__c = RESTAPITourV2.tourBuilding != null ? RESTAPITourV2.tourBuilding.Id : null;
                //Modified by Krishana Tupe : 25 June 2018
                if(objOpportunity.Interested_in_Number_of_Desks__c==0 || objOpportunity.Interested_in_Number_of_Desks__c==null){
                    objOpportunity.Interested_in_Number_of_Desks__c = body.desks_interested_min != null ? Integer.valueOf(body.desks_interested_min) : getLowerSize(body.company_size); 
                }
                //as per discussion with Girish, Modified by Krishana Tupe : 25 June 2018
                //Opportunity Owner logged in user when Account/contact recordType Mid Market and booked by Sales lead is true.
                if(objOpportunity.Owner_Auto_Assign__c == false){
                    if(String.isNotBlank(body.booked_by_contact_id)){
                        List<Contact> lstTourBookedByContacts = new List<Contact>([SELECT Id, Email FROM Contact WHERE Id =: Id.valueOf(body.booked_by_contact_id) LIMIT 1]);
                        objOpportunity.OwnerId = (lstTourBookedByContacts.size() > 0 && Settings.getUserByEmail(lstTourBookedByContacts[0].Email) != null) ? Settings.getUserByEmail(lstTourBookedByContacts[0].Email).Id : UserInfo.getUserId();                        
                    }
                    Debug.log('objOpportunity owner set as logged in user==>'+objOpportunity);
                }
                Debug.log('Limits.getQueries() in OpportunityHelper.getOrCreateOpportunity Insert 03::'+Limits.getQueries());
            }
        }
		
        if(String.isBlank(objOpportunity.Tour_Booked_By__c) && objOpportunity.Tour_Outcome__r != null && objOpportunity.Tour_Outcome__r.size() == 0){            
            objOpportunity.Tour_Booked_By__c = String.isNotBlank(body.booked_by_contact_id) ? body.booked_by_contact_id : null;            
        } 
        
        if(objOpportunity.RecordTypeId != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId()){
            oldOpportunityBuilding = objOpportunity.Building__c;
            objOpportunity.Building__c = RESTAPITourV2.tourBuilding != null ? RESTAPITourV2.tourBuilding.Id : objOpportunity.Building__c;
        }
        if(String.isNotBlank(objOpportunity.Locations_Interested__c)){
            locationInterested.addAll(objOpportunity.Locations_Interested__c.split(';'));            
        }
        locationInterested.add(objBuilding.Name);
        objOpportunity.Locations_Interested__c = String.join(new List<String>(locationInterested), ';');
        if(String.isNotBlank(body.sf_journey_uuid)){
            Debug.log('body.sf_journey_uuid---'+body.sf_journey_uuid);
            List<Journey__c> lstJourney = new List<Journey__c>([SELECT Id, Count_of_Desk__c FROM Journey__c WHERE UUID__c =: body.sf_journey_uuid]);
            Debug.log('lstJourney---'+lstJourney);
            if(lstJourney.size() > 0){
                RESTAPITourV2.objJourney = lstJourney[0];
                objOpportunity.Count_of_Desk__c = lstJourney[0].Count_of_Desk__c;
            }
        }
        //code added by Pragalbha for Opp team member creation
        if(String.isNotBlank(body.booked_by_contact_id) && String.isNotBlank(objOpportunity.Building__c) && String.isNotBlank(oldOpportunityBuilding) && objBuilding.Id != oldOpportunityBuilding){
            Building__c opportunityOldBuilding = settings.getBuildingById(oldOpportunityBuilding);
            OpportunityTeamMember objOpportunityTeamMember = (String.isNotBlank(opportunityOldBuilding.Market__c) && opportunityOldBuilding.Market__r.Name.equalsIgnoreCase(objBuilding.Market__r.Name)) ? getValidTeamMemberForDifferentBuilding(objOpportunity, body.booked_by_contact_id) : NULL;
            if(objOpportunityTeamMember != NULL){
                lstOpportunityTeamMembers.add(objOpportunityTeamMember);
            }
        }
        Debug.log('getOrCreateOpportunity objOpportunity---'+objOpportunity);
        return objOpportunity;
    }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method return the latest open Opportunity by given AccountId or Primary ConatactId for the given building
        Created Date        :   05 June 2018
        Issue No            :   ST-2484
		Modify by			:	Ashish Mishra
		Issue No			:	ST-2743
    **************************************************************************************************************************************/
    public static Opportunity getLatestOpenOpportunity(Id accountId, Id contactId, Building__C objBuilding){//Object buildingName		
        Setting__c openOppStages = Settings.get('OpenOpportunityStages');
        Set<String> setOpenOppStages = new Set<String>();
        List<Opportunity> openOpportunities;
        if(openOppStages != null && openOppStages.Data__c != null){
            setOpenOppStages = (Set<String>)JSON.deserialize(openOppStages.Data__c, Set<String>.class); 
        }
        if(setOpenOppStages != null && accountId != null){            
            openOpportunities = new List<Opportunity>([SELECT Id, RecordTypeId, Building__c, Building__r.Name, Primary_Member__c, Count_of_Desk__c, Building__r.Cluster_Name__c, Building__r.Territory_Name__c, Building__r.Region_Name__c,Building__r.Portfolio_Name__c, Locations_Interested__c, CreatedDate, LastModifiedDate, StageName, Tour_Booked_By__c FROM Opportunity WHERE AccountId =: accountId AND StageName IN :setOpenOppStages ORDER BY LastModifiedDate DESC]);                  
        }    
        if(openOpportunities.size() > 0 ){
            for(Opportunity objOpportunity : openOpportunities){
                if(contactId != null && objOpportunity.Primary_Member__c == contactId && objOpportunity.Building__c != null){
                    if(objOpportunity.Building__r.Name.equalsIgnoreCase(objBuilding.Name)){return objOpportunity;}
                    else if(String.isNotBlank(objOpportunity.Building__r.Portfolio_Name__c) && objOpportunity.Building__r.Portfolio_Name__c.equalsIgnoreCase(objBuilding.Portfolio_Name__c)){return objOpportunity;}
                    else if(String.isNotBlank(objOpportunity.Building__r.Cluster_Name__c) && objOpportunity.Building__r.Cluster_Name__c.equalsIgnoreCase(objBuilding.Cluster_Name__c)){return objOpportunity;}                                          
                }
            }
        }
        return null;        
    }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method create an Opportunity for the given contact.
        Created Date        :   05 June 2018
        Issue No            :   ST-2486
    **************************************************************************************************************************************/
    public static Opportunity createOpportunity(Id contactId, String stageName){
        Opportunity objOpportunity = new Opportunity();
        List<Contact> objContact = new List<Contact>([SELECT Id, RecordType.Name, AccountId,Account.Name, Account.RecordType.Name, Account.OwnerId, Account.Interested_in_Number_of_Desks__c FROM Contact WHERE Id = :contactId LIMIT 1]);
        if(objContact.size() > 0){
            // Contact To Opportunity field mappings ST-2490
            objOpportunity = (Opportunity)FieldMappingsHelper.getMappings(contactId, objOpportunity, 'FieldMappings:ContactToOpportunity');
            
            objOpportunity.StageName = (String.valueOf(objContact[0].Account.RecordType.Name) == 'Mid Market' || String.valueOf(objContact[0].Account.RecordType.Name) == 'Enterprise Solutions') ? 'Qualifying' : stageName;
            objOpportunity.AccountId = objContact[0].AccountId;
            objOpportunity.CloseDate = System.today();
            objOpportunity.Name = 'New Opportunity';          
                                
            objOpportunity.Primary_Member__c = objContact[0].Id;
            if(objContact[0].Account != null && objContact[0].Account.RecordType != null && Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(objContact[0].Account.RecordType.Name) != null ){
                objOpportunity.RecordTypeId = (objContact[0].Account.RecordType.Name != 'Referral') ? Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(objContact[0].Account.RecordType.Name).getRecordTypeId() : Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
            }
        }
        Debug.log('Tour createOpportunity objOpportunity ==>'+objOpportunity);
        Debug.log('Limits.getQueries() in OpportunityHelper.createOpportunity Insert 01::'+Limits.getQueries());
        return objOpportunity;       
    }
    
    /************************************************************************************************************************************
        Author          	: Rupesh Patil
        Description     	: This method is used to create Opportunity in the Community View page
        Issue No      		: ST-2385
        Created Date    	: 19 May 2018
	**************************************************************************************************************************************/
    public static opportunity createOpportunity(Id contactId, object noOfDesks, Id buildingID){
       		Opportunity newOpportunity = new Opportunity();
        	newOpportunity = (Opportunity)FieldMappingsHelper.getMappings(contactId, newOpportunity, 'FieldMappings:ContactToOpportunity');
            Debug.log('createOpportunity==>'+newOpportunity);
         	Contact objContact = [Select Id,Name,AccountId,Account.OwnerId,Account.Primary_Member__r.Name, Promo_Code__c from Contact Where Id=:contactId];
            debug.log('objContact: '+objContact);
            newOpportunity.Name = 'Community View Opportunity';
            if(objContact.Account.OwnerId != null){
                newOpportunity.OwnerId = objContact.Account.OwnerId;
            }           
            newOpportunity.StageName = 'Qualifying';
            newOpportunity.AccountId = objContact.AccountId;
            newOpportunity.Primary_Member__c = objContact.Id;
            newOpportunity.CloseDate = System.today();
            newOpportunity.Interested_in_Number_of_Desks__c = newOpportunity.Interested_in_Number_of_Desks__c != null ? newOpportunity.Interested_in_Number_of_Desks__c : (String.isNotBlank(String.valueOf(noOfDesks)) && Integer.valueOf(noOfDesks) > 0) ? Integer.valueOf(noOfDesks) : null;
            newOpportunity.Building__c = buildingID;
            newOpportunity.Promo_Code__c = objContact.Promo_Code__c;
            insert newOpportunity;
        	Debug.log('end newOpportunity==>'+newOpportunity);
            return newOpportunity;
    }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method create an Enterprise Opportunity for the given contact.
        Created Date        :   07 June 2018
        Issue No            :   ST-2486
		Modified by			:	Ashish Mishra
		Modified Date		:	7 July 2018
    **************************************************************************************************************************************/
    public static Opportunity createOpportunity(Opportunity objOpportunity){        
        objOpportunity.Name = 'Opportunity Name';        
        if(objOpportunity.get('AccountId') != null && String.isNotBlank(String.valueOf(objOpportunity.get('AccountId')))){
            // Opportunity record type = Account record type
            Account objAccount = [SELECT Id, RecordType.Name FROM Account WHERE Id =: (Id)objOpportunity.get('AccountId')];
            if(objAccount != null && objAccount.RecordType != null && Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(objAccount.RecordType.Name) != null){
                objOpportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(objAccount.RecordType.Name).getRecordTypeId();
            }
        }
        
        Id contactId = objOpportunity.Primary_Member__c != null ? objOpportunity.Primary_Member__c : objOpportunity.Decision_Maker__c != null ? objOpportunity.Decision_Maker__c : null;
        // Contact To Opportunity field mappings ST-2491
        if(contactId != null){
            objOpportunity = (Opportunity)FieldMappingsHelper.getMappings(contactId, objOpportunity, 'FieldMappings:ContactToOpportunity');
        }
        System.debug('objOpportunity==>'+objOpportunity);
        // Bypass the Opportunity auto owner assignments for profiles mentioned in "AccountMergeSettings" settings
        Map<String, Set<String>> accountMergeSettings = (Map<String, Set<String>>)JSON.deserialize(Settings.get('AccountMergeSettings').Data__c.toLowerCase(), Map<String, Set<String>>.class);
        Set<String> setProfiles = accountMergeSettings.get('profiles');
        Debug.log('setProfiles ---'+setProfiles);
        Debug.log('userinfo ---'+userinfo.getProfileId());
        
        List<Profile> lstProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String myProflieName = lstProfile[0].Name; 
        //if(!setProfiles.contains(String.valueOf(Settings.getUserById(UserInfo.getUserId()).profile.Name).toLowerCase())){
        if(!setProfiles.contains(myProflieName.toLowerCase())){                        
            objOpportunity.OwnerId = UserInfo.getUserId();
            objOpportunity.Owner_Auto_Assign__c = false;
        }        
        return objOpportunity;
    }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method create an Opportunity Role for the given Opportunity and Contact.
        Created Date        :   03 July 2018
        Issue No            :   
    **************************************************************************************************************************************/
    public static Opportunity_Role__c createOpportunityRole(Id opportunityId, Id contactId, String role){
        Opportunity_Role__c objOpportunityRole;
        objOpportunityRole = new Opportunity_Role__c();
        objOpportunityRole.Contact__c = contactId;
        objOpportunityRole.Opportunity__c = opportunityId;
        objOpportunityRole.Role__c = role;            
        return objOpportunityRole;
    }
    
    
    public static Opportunity createOpportunityWithFieldValues(Map<String, String> mapOppFieldsWithValues, Map<String, Set<String>> mapOppPickListValues){
        Opportunity objOpportunity = new Opportunity();
        List<Billing_Account__c> lstBillingAccount;
        List<Account> lstAccount;
        List<Contact> lstContact;        
        if(String.isNotBlank(mapOppFieldsWithValues.get('billingAccountUUID'))){
            Id BillingAccountId;
            try{
                BillingAccountId = Id.valueOf(mapOppFieldsWithValues.get('billingAccountUUID'));
            }catch(Exception ex){}
            if(BillingAccountId == null){
                lstBillingAccount = new List<Billing_Account__c>([SELECT Id, UUID__c FROM Billing_Account__c WHERE UUID__c =: mapOppFieldsWithValues.get('billingAccountUUID') LIMIT 1]);
                if(lstBillingAccount.size() > 0){
                    objOpportunity.Billing_Account__c = lstBillingAccount[0].Id;
                }
            }else{
               objOpportunity.Billing_Account__c = BillingAccountId;
            }
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('AccountUUID'))){
            Id AccountId;
            try{
                AccountId = Id.valueOf(mapOppFieldsWithValues.get('AccountUUID'));
            }catch(Exception ex){}
            if(AccountId == null){
                lstAccount = new List<Account>([SELECT Id FROM Account WHERE UUID__c =: mapOppFieldsWithValues.get('AccountUUID') LIMIT 1]);
                if(lstAccount.size() > 0){
                    objOpportunity.AccountId = lstAccount[0].Id;
                }
            }else{
                objOpportunity.AccountId = AccountId; 
            }
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('ContactPrimaryMember'))){
            Id ContactId;
            try{
                ContactId = Id.valueOf(mapOppFieldsWithValues.get('ContactPrimaryMember'));
            }catch(Exception ex){}
            if(ContactId == null){
                lstContact = new List<Contact>([SELECT Id FROM Contact WHERE Email =: mapOppFieldsWithValues.get('ContactPrimaryMember') LIMIT 1]);
                if(lstContact.size() > 0){
                   objOpportunity.Primary_Member__c = lstContact[0].Id; 
                }
            }else{
                objOpportunity.Primary_Member__c = ContactId;
            }
        }        
        if(String.isNotBlank(mapOppFieldsWithValues.get('CloseDate'))){
            objOpportunity.CloseDate = Date.ValueOf(mapOppFieldsWithValues.get('CloseDate'));
        }else{
            objOpportunity.CloseDate = system.today();
        }
		if(String.isNotBlank(mapOppFieldsWithValues.get('Type__c'))){
            objOpportunity.Type__c = mapOppFieldsWithValues.get('Type__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Actual_Start_Date__c'))){
            objOpportunity.Actual_Start_Date__c = Date.valueOf(mapOppFieldsWithValues.get('Actual_Start_Date__c'));
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Building__c'))){
            objOpportunity.Building__c = mapOppFieldsWithValues.get('Building__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('StageName'))){
            objOpportunity.StageName = mapOppFieldsWithValues.get('StageName');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Membership_Agreement_Notes__c'))){
            objOpportunity.Membership_Agreement_Notes__c = mapOppFieldsWithValues.get('Membership_Agreement_Notes__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('LeadSource'))){
            objOpportunity.LeadSource = mapOppFieldsWithValues.get('LeadSource');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Lead_Source_Detail__c'))){
            objOpportunity.Lead_Source_Detail__c = mapOppFieldsWithValues.get('Lead_Source_Detail__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Contract_UUID__c'))){
            objOpportunity.Contract_UUID__c = mapOppFieldsWithValues.get('Contract_UUID__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('CurrencyIsoCode'))){
            objOpportunity.CurrencyIsoCode = mapOppFieldsWithValues.get('CurrencyIsoCode');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Contract_Stage__c'))){
            objOpportunity.Contract_Stage__c = mapOppFieldsWithValues.get('Contract_Stage__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Owner_Auto_Assign__c'))){
            objOpportunity.Owner_Auto_Assign__c = Boolean.valueOf(mapOppFieldsWithValues.get('Owner_Auto_Assign__c'));
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Contract_Pdf__c'))){
            objOpportunity.Contract_Pdf__c = mapOppFieldsWithValues.get('Contract_Pdf__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Old_Opportunity__c'))){
            objOpportunity.Old_Opportunity__c = mapOppFieldsWithValues.get('Old_Opportunity__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Reservation_UUID__c'))){
            objOpportunity.Reservation_UUID__c = mapOppFieldsWithValues.get('Reservation_UUID__c');
        }
		if(String.isNotBlank(mapOppFieldsWithValues.get('Community_Manager_UUID__c'))){
            objOpportunity.Community_Manager_UUID__c = mapOppFieldsWithValues.get('Community_Manager_UUID__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Community_User__c'))){
            objOpportunity.Community_User__c = mapOppFieldsWithValues.get('Community_User__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Send_Paperwork_By__c'))){
            objOpportunity.Send_Paperwork_By__c = mapOppFieldsWithValues.get('Send_Paperwork_By__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Paperwork_Sent_On_Date__c'))){
            objOpportunity.Paperwork_Sent_On_Date__c = Date.valueOf(mapOppFieldsWithValues.get('Paperwork_Sent_On_Date__c'));
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Contract_Type__c'))){
            objOpportunity.Contract_Type__c = mapOppFieldsWithValues.get('Contract_Type__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Downgrade_Reason__c'))){
            objOpportunity.Downgrade_Reason__c = mapOppFieldsWithValues.get('Downgrade_Reason__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Downgrade_Notes__c'))){
            objOpportunity.Downgrade_Notes__c = mapOppFieldsWithValues.get('Downgrade_Notes__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Commitment_Term_in_months__c'))){
            objOpportunity.Commitment_Term_in_months__c = Decimal.ValueOf(mapOppFieldsWithValues.get('Commitment_Term_in_months__c'));
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Contract_Expiration__c'))){
            objOpportunity.Contract_Expiration__c = DateTime.valueOfGmt(mapOppFieldsWithValues.get('Contract_Expiration__c'));
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Lost_Reason__c'))){
            objOpportunity.Lost_Reason__c = mapOppFieldsWithValues.get('Lost_Reason__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Move_outs_Closed_Lost__c'))){
            objOpportunity.Move_outs_Closed_Lost__c = Boolean.ValueOf(mapOppFieldsWithValues.get('Move_outs_Closed_Lost__c'));
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Contract_Signed_On_Date__c'))){
            objOpportunity.Contract_Signed_On_Date__c = Date.valueOf(mapOppFieldsWithValues.get('Contract_Signed_On_Date__c'));
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('OwnerId'))){
            objOpportunity.OwnerId = mapOppFieldsWithValues.get('OwnerId');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Contract_Canceled_On_Date__c'))){
            objOpportunity.Contract_Canceled_On_Date__c = Date.ValueOf(mapOppFieldsWithValues.get('Contract_Canceled_On_Date__c'));
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Contract_Voided_Discarded_On_Date__c'))){
            objOpportunity.Contract_Voided_Discarded_On_Date__c = Date.ValueOf(mapOppFieldsWithValues.get('Contract_Voided_Discarded_On_Date__c'));
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Move_Out_Building__c'))){
            objOpportunity.Move_Out_Building__c = mapOppFieldsWithValues.get('Move_Out_Building__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Reservation_UUID__c'))){
            objOpportunity.Reservation_UUID__c = mapOppFieldsWithValues.get('Reservation_UUID__c');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('LeadSource'))){//CSI-1545
            objOpportunity.LeadSource = mapOppFieldsWithValues.get('LeadSource');
        }
        if(String.isNotBlank(mapOppFieldsWithValues.get('Lead_Source_Detail__c'))){//CSI-1545
            objOpportunity.Lead_Source_Detail__c = mapOppFieldsWithValues.get('Lead_Source_Detail__c');
        }
        if(mapOppPickListValues != null && mapOppPickListValues.size() > 0){
          objOpportunity = mapPickListValuesOnOppFields(mapOppPickListValues,objOpportunity);  
        }
        Debug.log('createOpportunityWithFieldValues objOpportunity==>'+objOpportunity);
        return objOpportunity;
    }
    /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method auto-populates the picklist values of opportunity.
        Created Date        :   11 June 2018
        Issue No            :   
    **************************************************************************************************************************************/
    public static Opportunity mapPickListValuesOnOppFields(Map<String, Set<String>> mapOppPickListValues, Opportunity objOpportunity){     
        for(String field : mapOppPickListValues.keySet()){
            String concatenatedList = '';
            for(String multiPickListValue : mapOppPickListValues.get(field)){
                concatenatedList += multiPickListValue + ';';
            }
            concatenatedList.removeEnd(';');
            objOpportunity.put(field,concatenatedList);
        }
        return objOpportunity;
    }
    /************************************************************************************************************************************
        Author              :   Shobhit Gahlot
        Description         :   This method returns a set of values for picklist.
        Created Date        :   11 June 2018
        Issue No            :   
    **************************************************************************************************************************************/
    public static Set<String> getUniquePickListValues(String pickList, Set<String> newValues){
        Set<String> setOldPickListValues;
        if(newValues.size() > 0){
            if(String.isNotBlank(pickList)){
                List<String> lstOldPickListValues = pickList.Split(';');
                setOldPickListValues = new Set<String>(lstOldPickListValues);
                for(String newPickListValue: newValues){
                    if(!setOldPickListValues.contains(newPickListValue)){
                        setOldPickListValues.add(newPickListValue);
                    }	
                }
            }
        }
        return setOldPickListValues;
    }
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method is used to get lower size from company size range.
        Created Date        :   21 June 2018
    **************************************************************************************************************************************/
    public static Integer getLowerSize(String strCompanySize){
        if(String.isNotBlank(strCompanySize)){
            Integer lowerSize;
            strCompanySize = strCompanySize.replace(',','');
            strCompanySize = strCompanySize.replace('desks','');
            strCompanySize = strCompanySize.replace('desk','');
            strCompanySize = strCompanySize.replace('<','');
            strCompanySize = strCompanySize.deleteWhitespace();
            if(strCompanySize.contains('-')){
                lowerSize = Integer.valueOf(strCompanySize.split('-')[0]);
            }else if(strCompanySize.contains('+')){
                lowerSize = Integer.valueOf(strCompanySize.split('\\+')[0]);
            }else{
                lowerSize = Integer.valueOf(strCompanySize);
            }
            return lowerSize;  
        }
        return 0;        
    }
     
    /*****************************************************************************************************************************************
        Author              :   Pragalbha Mahajan
        Description         :   This method is used to get valid team members for different buildings.
        Created Date        :   15 Feb 2018
	******************************************************************************************************************************************/
    public static OpportunityTeamMember getValidTeamMemberForDifferentBuilding(Opportunity objOpportunity, String bookedByContactId){
        Building__c opportunityNewBuilding = settings.getBuildingById(objOpportunity.Building__c);
        Contact objContact = RESTAPITourV2.getContactById(bookedByContactId);
        User objBookedByUser = objContact != NULL && String.isNotBlank(objContact.Email) ? Settings.getUserByEmail(objContact.Email) : NULL;
        if(objBookedByUser != NULL && opportunityNewBuilding != NULL && !AccountAssignmentHelper.isApiUser('UserId', objBookedByUser.Id) && (objBookedByUser.Id == opportunityNewBuilding.Community_Sales_Lead__c || objBookedByUser.Id == opportunityNewBuilding.Cluster__r.Sales_Lead__c)){
            return new OpportunityTeamMember(UserId = objBookedByUser.Id, TeamMemberRole = 'Opp: Originating Rep', OpportunityId = objOpportunity.Id);
        }
        return NULL;
    }
}