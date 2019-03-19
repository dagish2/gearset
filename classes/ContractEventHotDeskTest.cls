/**
* Name			:	ContractEventHotDeskTest	 
* Issue No.		: 	CSI-441 
* Purpose		:	Test Methods for ContractEventHotDesk
	Version			Author				Date			Detail				Feature
	1.0				Samadhan Kadam		22/01/2018		Initial Development	
***********************************************************************************************************************************************************
*/ 

@isTest
public class ContractEventHotDeskTest { 
   @TestSetup 
    static void testDataSetUp(){
        TriggerSettings.mappedField.Billing_Account_mapParentAccount = false;
        ContractEventTestingUtility.getContractDataForAllEvents();
        //TriggerSettings.mappedField.Billing_Account_mapParentAccount = true;
    }
    static testMethod void verifyHotDeskCancellationExistingOpportunity(){
        List<Reservable__c> lstReservable = [SELECT Id, uuid__c, Building__c FROM Reservable__c WHERE UUID__c != null];
        system.assert(lstReservable.size() > 0);
        Set<Id> setBuildingIds = new Set<Id>();
        for(Reservable__c obj : lstReservable){
            setBuildingIds.add(obj.Building__c);
        }
        List<Opportunity> lstOpportunities = [SELECT Id, Name, contract_uuid__c, Billing_Account__r.UUID__c, (SELECT Id, Status__c,Reservable__r.UUID__c FROM Opportunity_Move_Outs__r), (Select Id, Reservable__c, Start_Date__c, Opportunity__c, Monthly_Price__c From Opportunity_Offices__r) FROM Opportunity order by createdDate LIMIT 1];        
        String company_uuid = lstOpportunities[0].Billing_Account__r.UUID__c;
        Opportunity opportunity= lstOpportunities[0];
        opportunity.Billing_Account__c = null;
        update opportunity;
        List<Billing_Account__c> lstBillingAccount = [SELECT Id, uuid__c FROM Billing_Account__c WHERE UUID__c != null];
        system.assert(lstBillingAccount.size() > 0);
        List<Contact> lstContacts = [SELECT Id, uuid__c, Email FROM Contact WHERE UUID__c != null];
        system.assert(lstContacts.size() > 0);
        List<Building__c> lstBuilding = [SELECT Id, uuid__c FROM Building__c WHERE UUID__c != null AND Id In : setBuildingIds];
        system.assert(lstBuilding.size() > 0);
        List<WWTypes.move_insVal> lstmove_insVal = ContractEventTestingUtility.getMoveInsForPayload(lstBuilding, lstReservable); 
        List<WWTypes.move_outssVal> lstmove_outssVal = ContractEventTestingUtility.getMoveOutsforPayload(lstBuilding, lstReservable);
        List<WWTypes.products> lstproductss = ContractEventTestingUtility.getProductsforPayload(lstBuilding, lstReservable);
        WWTypes.ContractEvent ObjContractEvent = ContractEventTestingUtility.getCompletePayloadForContract('Contract Canceled', company_uuid, lstContacts[0].Email, 'test', 'USD', 'www.test.com,www.test1.com', String.valueOf(Date.today().addDays(-2)), null, null, null, null, opportunity.Id, null, null, lstproductss, lstmove_insVal, lstmove_outssVal);
        ObjContractEvent.reservation_uuid = 'reservationuuid' ;
        ObjContractEvent.lead_source = 'lead_source';
        ObjContractEvent.lead_source_detail = 'lead_source_detail';
        Debug.log('ObjContractEventObjContractEvent'+ObjContractEvent);
        RESTContractEvent.Response response = ContractEventTestingUtility.callOutToContractEventEndPoint(ObjContractEvent);
        Debug.log('responseresponse123'+response);		
        System.assertEquals(true, response.success);
        Id OpportunityId; 
        if(response.result != null && response.result != '')
            OpportunityId = ContractEventTestingUtility.extractIdFromResultInContractEvent(response.result);
        Opportunity opp = ContractEventTestingUtility.getOpportunityAfterContractRequest(OpportunityId);
        ContractEventTestingUtility.payloadAssertion(ObjContractEvent, opp, null);
        
    }
    
    static testMethod void verifyHotDeskCancellationNewOpportunityCreation(){
        List<Reservable__c> lstReservable = [SELECT Id, uuid__c, Building__c FROM Reservable__c WHERE UUID__c != null];
        system.assert(lstReservable.size() > 0);
        Set<Id> setBuildingIds = new Set<Id>();
        for(Reservable__c obj : lstReservable){
            setBuildingIds.add(obj.Building__c);
        }
        List<Opportunity> lstOpportunities = [SELECT Id, Name, contract_uuid__c, Billing_Account__r.UUID__c, (SELECT Id, Status__c,Reservable__r.UUID__c FROM Opportunity_Move_Outs__r), (Select Id, Reservable__c, Start_Date__c, Opportunity__c, Monthly_Price__c From Opportunity_Offices__r) FROM Opportunity order by createdDate LIMIT 1];        
        List<Billing_Account__c> lstBillingAccount = [SELECT Id, uuid__c FROM Billing_Account__c WHERE UUID__c != null];
        system.assert(lstBillingAccount.size() > 0);
        List<Contact> lstContacts = [SELECT Id, uuid__c, Email FROM Contact WHERE UUID__c != null];
        system.assert(lstContacts.size() > 0);
        List<Building__c> lstBuilding = [SELECT Id, uuid__c FROM Building__c WHERE UUID__c != null AND Id In : setBuildingIds];
        system.assert(lstBuilding.size() > 0);
        List<WWTypes.move_insVal> lstmove_insVal = ContractEventTestingUtility.getMoveInsForPayload(lstBuilding, lstReservable); 
        List<WWTypes.move_outssVal> lstmove_outssVal = ContractEventTestingUtility.getMoveOutsforPayload(lstBuilding, lstReservable);
        List<WWTypes.products> lstproductss = ContractEventTestingUtility.getProductsforPayload(lstBuilding, lstReservable);
        WWTypes.ContractEvent ObjContractEvent = ContractEventTestingUtility.getCompletePayloadForContract('Contract Canceled', lstBillingAccount[0].UUID__c, lstContacts[0].Email, 'test', 'USD', 'www.test.com,www.test1.com', String.valueOf(Date.today().addDays(-2)), null, null, null, null, null, null,null, lstproductss, lstmove_insVal, lstmove_outssVal);
        Debug.log('ObjContractEventObjContractEvent'+ObjContractEvent);
        ObjContractEvent.reservation_uuid = 'reservationuuid' ;
        ObjContractEvent.lead_source = 'lead_source';
        ObjContractEvent.lead_source_detail = 'lead_source_detail';
        RESTContractEvent.Response response = ContractEventTestingUtility.callOutToContractEventEndPoint(ObjContractEvent);
        Debug.log('responseresponse123'+response);		
        System.assertEquals(true, response.success);
        Id OpportunityId; 
        if(response.result != null && response.result != '')
            OpportunityId = ContractEventTestingUtility.extractIdFromResultInContractEvent(response.result);
        Opportunity opp = ContractEventTestingUtility.getOpportunityAfterContractRequest(OpportunityId);
        ContractEventTestingUtility.payloadAssertion(ObjContractEvent, opp, null);
    }
    
    static testMethod void verifyHotDeskOpportunityUpdate(){
        List<Opportunity> lstOpportunities = [SELECT Id, Name, contract_uuid__c, Billing_Account__r.UUID__c, (SELECT Id, Status__c,Reservable__r.UUID__c FROM Opportunity_Move_Outs__r), (Select Id, Reservable__c, Start_Date__c, Opportunity__c, Monthly_Price__c From Opportunity_Offices__r) FROM Opportunity order by createdDate LIMIT 1];        
        List<Reservable__c> lstReservable = [SELECT Id, uuid__c, Building__c FROM Reservable__c WHERE UUID__c != null];
        system.assert(lstReservable.size() > 0);
        Set<Id> setBuildingIds = new Set<Id>();
        for(Reservable__c obj : lstReservable){
            setBuildingIds.add(obj.Building__c);
        }
        List<Billing_Account__c> lstBillingAccount = [SELECT Id, uuid__c FROM Billing_Account__c WHERE UUID__c != null];
        system.assert(lstBillingAccount.size() > 0);
        List<Contact> lstContacts = [SELECT Id, uuid__c, Email FROM Contact WHERE UUID__c != null];
        system.assert(lstContacts.size() > 0);
        List<Building__c> lstBuilding = [SELECT Id, uuid__c FROM Building__c WHERE UUID__c != null AND Id In : setBuildingIds];
        system.assert(lstBuilding.size() > 0);
        List<WWTypes.move_insVal> lstmove_insVal = ContractEventTestingUtility.getMoveInsForPayload(lstBuilding, lstReservable); 
        List<WWTypes.move_outssVal> lstmove_outssVal = ContractEventTestingUtility.getMoveOutsforPayload(lstBuilding, lstReservable);
        List<WWTypes.products> lstproductss = ContractEventTestingUtility.getProductsforPayload(lstBuilding, lstReservable);
        WWTypes.ContractEvent ObjContractEvent = ContractEventTestingUtility.getCompletePayloadForContract('Contract Signed', lstBillingAccount[0].UUID__c, lstContacts[0].Email, 'test', 'USD', 'www.test.com,www.test1.com', String.valueOf(Date.today().addDays(-2)), null, null, null, null, String.valueOf(lstOpportunities[0].Id),'testOppReservation', null, null,  lstproductss, lstmove_insVal, lstmove_outssVal);
        Debug.log('ObjContractEventObjContractEvent'+ObjContractEvent);
        ObjContractEvent.reservation_uuid = 'reservationuuid' ;
        ObjContractEvent.lead_source = 'lead_source';
        ObjContractEvent.lead_source_detail = 'lead_source_detail';
        RESTContractEvent.Response response = ContractEventTestingUtility.callOutToContractEventEndPoint(ObjContractEvent);
        Debug.log('responseresponse123'+response);		
        System.assertEquals(true, response.success);
        Id OpportunityId; 
        if(response.result != null && response.result != '')
            OpportunityId = ContractEventTestingUtility.extractIdFromResultInContractEvent(response.result);
        Opportunity opp = ContractEventTestingUtility.getOpportunityAfterContractRequest(OpportunityId);
        ContractEventTestingUtility.payloadAssertion(ObjContractEvent, opp, null);
    }
}