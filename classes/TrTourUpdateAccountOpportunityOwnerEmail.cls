/************************************************************************************************************************************
    Author 		: 	Chandra Teja
    Description : 	This class will contain before insertion logic to populate account owner and opportunity owner email.
    History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			21 February 2019	ChandraTeja     	Initial Development	 
**************************************************************************************************************************************/
public class TrTourUpdateAccountOpportunityOwnerEmail implements IProcessHandler {
    
    public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap) {
        updateAccountOwnerEmail((List<Tour_Outcome__c>)triggerNew);
    }
    static Map<Id, Contact> lstPrimaryMemberAndBookedByContact;
    
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This method is used to populate account owner's and opportunity owner's email value on insertion
        Created Date    : 21 February 2019 
        Issue No        : ST-3449, ST-3433
    **************************************************************************************************************************************/
    static void updateAccountOwnerEmail(List<Tour_Outcome__c> lstNewTours) {
        Map<Tour_Outcome__c, Id> mapTourOpportunityIds = new Map<Tour_Outcome__c, Id>();
        Map<Tour_Outcome__c, List<Id>> mapTourBookedByContactIds = new Map<Tour_Outcome__c, List<Id>>();      
        for(Tour_Outcome__c objTour : lstNewTours){
            if(String.isNotBlank(objTour.booked_by_contact_id__c) && String.isNotBlank(objTour.Primary_Member__c)) {
                List<Id> lstPrimaryMemberAndBookedByContactIds = new List<Id>();
                lstPrimaryMemberAndBookedByContactIds.add(objTour.booked_by_contact_id__c);
                lstPrimaryMemberAndBookedByContactIds.add(objTour.Primary_Member__c);
                mapTourBookedByContactIds.put(objTour, lstPrimaryMemberAndBookedByContactIds);
            }
            if(string.isNotBlank(objTour.Opportunity__c) && String.isNotBlank(objTour.booked_by_contact_id__c)){
                mapTourOpportunityIds.put(objTour, objTour.Opportunity__c);
            }
        }
        if(!mapTourBookedByContactIds.isEmpty()) {
            getContactUserEmails(mapTourBookedByContactIds);   
        }
        if(!mapTourOpportunityIds.isEmpty()) {
            getOpportunityUserEmails(mapTourOpportunityIds);   
        }
    }
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This method is used to populate account owner's email value on insertion
        Created Date    : 21 February 2019 
        Issue No        : ST-3449, ST-3433
    **************************************************************************************************************************************/
    static void getContactUserEmails(Map<Tour_Outcome__c, List<Id>> mapTourAndContactIds) {
        Set<Id> setPrimaryMemberAndBookedByContactIds = new Set<Id>();
        for(List<Id> lstIds: mapTourAndContactIds.values()){
            setPrimaryMemberAndBookedByContactIds.addAll(lstIds);
        }
        lstPrimaryMemberAndBookedByContact = RESTAPITourV2.getContacts(setPrimaryMemberAndBookedByContactIds);
        if(lstPrimaryMemberAndBookedByContact.keySet().size() != setPrimaryMemberAndBookedByContactIds.size())
        {
            lstPrimaryMemberAndBookedByContact = new Map<Id, Contact>([SELECT Id, Email, AccountId, Account.OwnerId, Account.Owner.Email FROM Contact WHERE Id IN : setPrimaryMemberAndBookedByContactIds]);
        }
        for(Tour_Outcome__c objTour : mapTourAndContactIds.keyset()){
            List<Id> lstPrimaryMemberAndBookedByContactIds = new List<Id>();
            lstPrimaryMemberAndBookedByContactIds = mapTourAndContactIds.get(objTour);
            if(checkIds(settings.getUserByEmail(lstPrimaryMemberAndBookedByContact.get(lstPrimaryMemberAndBookedByContactIds[0]).Email), lstPrimaryMemberAndBookedByContact.get(lstPrimaryMemberAndBookedByContactIds[1]).Account.OwnerId)){
                objTour.Account_Owner_Email__c = lstPrimaryMemberAndBookedByContact.get(lstPrimaryMemberAndBookedByContactIds[1]).Account.Owner.Email;
            }
        }
    }
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This method is used to populate opportunity owner's email value on insertion
        Created Date    : 21 February 2019 
        Issue No        : ST-3449, ST-3433
    **************************************************************************************************************************************/
    static void getOpportunityUserEmails(Map<Tour_Outcome__c, Id> mapTourAndOpportunityIds) {
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity> ([SELECT Id, OwnerId, Owner.Email From Opportunity WHERE Id In: mapTourAndOpportunityIds.values()]);
        for(Tour_Outcome__c objTour : mapTourAndOpportunityIds.keyset()){
            if(checkIds(settings.getUserByEmail(lstPrimaryMemberAndBookedByContact.get(objTour.booked_by_contact_id__c).Email), mapOpportunities.get(objTour.Opportunity__c).OwnerId)){
                objTour.Opportunity_Owner_Email__c = mapOpportunities.get(objTour.Opportunity__c).Owner.Email;
            }
        }
    }
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This method is used to check if booked by user and primary members account owner id is same or not
        Created Date    : 21 February 2019 
        Issue No        : ST-3449, ST-3433
    **************************************************************************************************************************************/
    static Boolean checkIds(User BookedByUser, Id primaryMemberAccountOwnerOrOpportunityOwnerId ) {
        if(BookedByUser != null && string.isNotBlank(primaryMemberAccountOwnerOrOpportunityOwnerId) && BookedByUser.Id != primaryMemberAccountOwnerOrOpportunityOwnerId){
            return true;
        }
        return false;
    } 
    
    
}