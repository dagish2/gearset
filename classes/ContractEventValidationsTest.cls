/**
* Name			:	ContractEventValidationsTest	 
* Issue No.		: 	
* Purpose		:	This contains the test methods of all the custom validations in contract event.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Rupesh Patil		1/31/2018		Initial Development							
***********************************************************************************************************************************************************
*/
@isTest
public class ContractEventValidationsTest {
    
    @TestSetup 
    static void testDataSetup(){
        ContractEventTestingUtility.getContractDataForAllEvents();
    }
    public static testMethod void testContractReservableNotFoundError(){
        List<Reservable__c> lstReservable = [SELECT Id, uuid__c, Building__c FROM Reservable__c WHERE UUID__c != null];
        system.assert(lstReservable.size() > 0);
        Set<Id> setBuildingIds = new Set<Id>();
        for(Reservable__c obj : lstReservable){
            setBuildingIds.add(obj.Building__c);
        }
        List<Building__c> lstBuilding = [SELECT Id, uuid__c FROM Building__c WHERE UUID__c != null AND Id In : setBuildingIds];
        system.assert(lstBuilding.size() > 0);
        List<WWTypes.move_insVal> lstmove_insVal = ContractEventTestingUtility.getMoveInsForPayload(lstBuilding, lstReservable);        
        List<WWTypes.move_outssVal> lstmove_outssVal = ContractEventTestingUtility.getMoveOutsforPayload(lstBuilding, lstReservable);
        for(WWTypes.move_insVal moveIn: lstmove_insVal){
            moveIn.reservable_uuid = 'objreservable_uuid_not_found';
            break;
        }
        TestingUtility.updateListWithAssert(lstReservable);
        WWTypes.ContractEvent ObjContractEvent = ContractEventTestingUtility.getCompletePayloadForContract('Contract Sent', 'testBilingAccountUUID1', 'testcontact1RestCon@example.com', 'FailedMembership', 'AUD', 'www.test.com,www.test1.com', '', '', '', '', '', null, null, null, null, lstmove_insVal, lstmove_outssVal);
        RESTContractEvent.Response response = ContractEventTestingUtility.callOutToContractEventEndPoint(ObjContractEvent);
        Debug.log('response pEx message---'+response);
        System.assertEquals(false, response.success);
        system.assertEquals(response.message.contains('objreservable_uuid_not_found,'), true);
    } 
}