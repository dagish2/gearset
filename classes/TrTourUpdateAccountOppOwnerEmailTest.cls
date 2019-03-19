/************************************************************************************************************************************
    Author 		: 	Chandra Teja
    Description : 	This class will contain all the test method of TrTourUpdateAccountOpportunityOwnerEmail.
    History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			21 February 2019	ChandraTeja     	Initial Development	 
**************************************************************************************************************************************/
@isTest
public class TrTourUpdateAccountOppOwnerEmailTest {
@testSetup
    static void setup() {
        SalesConsoleSettings.createSettings();
        Map<string, object> mapObjData = new Map<string, object>();
        mapObjData.put('objName', 'Tour');
        mapObjData.put('numberOfRecords', 1);
        mapObjData.put('doInsert', true);
        List<Tour_Outcome__c> lstTours = TestingUtility.getRecords(mapObjData);
        system.assertEquals(1, lstTours.size());
    }
    /************************************************************************************************************************************
        Author          : Chandra Teja
        Description     : This method is used to unit test populate account owner's and opportunity owner's email value on insertion
        Created Date    : 21 February 2019 
        Issue No        : ST-3449, ST-3433
    **************************************************************************************************************************************/
  @isTest
    static void testUpdateAccountAndOpportunityOwnerEmail(){
        List<Tour_Outcome__c> lstTours = [SELECT Id, Account_Owner_Email__c, Opportunity_Owner_Email__c, Primary_Member__c, booked_by_contact_id__c, Opportunity__c  FROM Tour_Outcome__c];
        List<Contact> lstContact = [SELECT AccountId, Account.Owner.Id, Account.Owner.Email, Email From Contact WHERE Id = :lstTours[0].Primary_Member__c OR Id = :lstTours[0].booked_by_contact_id__c];
        List<Opportunity> lstOpportunities = [SELECT Id, OwnerId, Owner.Email FROM Opportunity WHERE Id =:lstTours[0].Opportunity__c];
            User bookedByUser =  settings.getUserByEmail(lstContact[0].Email);
        if(bookedByUser != null && lstContact[0].Account.Owner.Id != bookedByUser.Id){
            system.assertEquals(lstTours[0].Account_Owner_Email__c , lstContact[0].Account.Owner.Email);
                }else{
                    system.assertEquals(lstTours[0].Account_Owner_Email__c, null);  
                }
        if(bookedByUser != null && lstOpportunities[0].OwnerId != bookedByUser.Id){
             system.assertEquals(lstTours[0].Opportunity_Owner_Email__c , lstOpportunities[0].Owner.Email);
                 }else{
                     system.assertEquals(lstTours[0].Opportunity_Owner_Email__c, null);
                 }
    }
    
    
}