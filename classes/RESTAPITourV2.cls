/************************************************************************************************************************************
    Author 		: 	Krishana Tupe	
    Description : 	This class contain the business logic for Tour booking functionality.
    
    History		:
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION		DATE				AUTHOR					DETAIL
    1			18 June 2018		Krishana Tupe			Initial Developement
**************************************************************************************************************************************/

public class RESTAPITourV2 extends RESTAPIBase{
    public static Building__c tourBuilding;
    public static Journey__c objJourney;
    public static Map<Id, Contact> mapContacts;
    
    public override RESTAPIResult executePost(RESTAPI.PayloadDetails payload){
        RESTAPITourModelsV2.Input input = (RESTAPITourModelsV2.Input)payload.Input;
        RESTAPIResult result = new RESTAPIResult();
        RESTAPITourModelsV2.Response response = bookTour(input);
        if(response != null){
            result.setSuccess('Tour Processed!', response);
        }
        return result;
    } 
    
    /************************************************************************************************************************************
        Author              :   Dipak Pawar
        Description         :   This method creates a Tour record with the given information in payload
        Created Date  		:   05 June 2018
		Issue No			:	ST-
    *************************************************************************************************************************************/
    public static RESTAPITourModelsV2.Response bookTour(RESTAPITourModelsV2.Input body){
        RESTAPITourModelsV2.Response response = new RESTAPITourModelsV2.Response();
        Map<String,Id> convertedData = LeadConverterHelper.manageLead(body);
        Contact tourContact;
        Opportunity objOpportunity;
        Tour_Outcome__c objTour;
        
        if(convertedData != null && convertedData.containsKey('contactId') && String.isNotBlank(convertedData.get('contactId'))){
            if(String.isNotBlank(body.booked_by_contact_id)){
                body.booked_by_contact_id = Id.valueOf(body.booked_by_contact_id);
                getContacts(new Set<Id>{convertedData.get('contactId'), body.booked_by_contact_id});
            }
            Contact objContact = getContactById(convertedData.get('contactId'));
            if(objContact != null){               
                tourContact = objContact;              
                if(String.isBlank(tourContact.AccountId) && convertedData.containsKey('accountId')){
                    tourContact.AccountId = convertedData.get('accountId');
                    update tourContact;
                    mapContacts.remove(tourContact.Id);
                    tourContact = getContactById(convertedData.get('contactId'));
                }
                TourHelper.updateInterestedNoOfDesksonAccount(tourContact,body);
                response.contact_sfid = tourContact.Id;
                response.account_sfid = tourContact.AccountId;
                if(String.isNotBlank(body.tour_building_uuid) && Settings.getBuildingByUUID(body.tour_building_uuid) != null){
                    tourBuilding = Settings.getBuildingByUUID(body.tour_building_uuid);
                }
                if(tourBuilding != null && tourBuilding.Name != null && body != null && tourContact != null ){
                    objOpportunity = OpportunityHelper.getOrCreateOpportunity(body, tourContact.AccountId, tourContact.Id, String.isNotBlank(body.opportunity_id) ? body.opportunity_id : null , tourBuilding);    
                    debug.log('objOpportunity: '+objOpportunity);
                    upsert objOpportunity;                    
                    response.opportunity_sfid = objOpportunity.Id;
                    List<Opportunity_Role__c> lstOpportunityRoles = new List<Opportunity_Role__c>([SELECT Id, Contact__c, Opportunity__c FROM Opportunity_Role__c WHERE Opportunity__c =: objOpportunity.Id AND Contact__c =: tourContact.Id]);
                    if(lstOpportunityRoles.size() == 0){
                        Opportunity_Role__c objOpportunityRole = OpportunityHelper.createOpportunityRole(objOpportunity.Id, tourContact.Id, 'Influencer');
                        insert objOpportunityRole;
                    }
                    objTour = TourHelper.createTour(body, tourContact, objOpportunity.Id);
                    insert objTour;
                    response.tour_sfid = objTour.Id;
                    Debug.log('Limits.getQueries() RESTAPITourV2 bookTour 05 ::'+Limits.getQueries());
                }
            }
        }
        return response;
    }
       
    /*****************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method is used to get Contacts.
        Created Date        :   15 Feb 2018
	******************************************************************************************************************************************/
    public static Contact getContactById(String contactId){
        If(String.isNotBlank(contactId)){
            if(mapContacts == NULL || mapContacts.isEmpty() || !mapContacts.containsKey(contactId)){
                mapContacts = getContacts(new Set<Id>{contactId});
            }
            if(mapContacts.containsKey(contactId)){
                return mapContacts.get(contactId);
            }
        }
        return NUll;
    }
    
    /*****************************************************************************************************************************************
        Author              :   Nikhil Mehta
        Description         :   This method is used to get Contacts.
        Created Date        :   15 Feb 2018
	******************************************************************************************************************************************/
    public static Map<Id, Contact> getContacts(Set<Id> setIds){
        if(mapContacts == NULL){
            mapContacts = new Map<Id, Contact>();
        }                 
        mapContacts.putAll(new Map<Id, Contact>([SELECT Id, AccountId, Email, Account.Name, Account.OwnerId, Account.Owner.Email, Interested_in_Number_of_Desks__c, Account.RecordType.Name, Account.Interested_in_Number_of_Desks_Max__c, Account.Interested_in_Number_of_Desks_Min__c, Account.Interested_in_Number_of_Desks_Range__c, OwnerId, UUID__c FROM Contact WHERE Id IN :setIds OR Email = :UserInfo.getUserEmail()]));
        return mapContacts;
    }
}