/**
* Name			:	ContractEventSentTest	 
* Issue No.		: 	
* Purpose		:	This is contains the test methods 'Contract Sent' event.
* History		
Version			Author				Date			Detail						Feature			IssueNumber
1.0				Shobhit Gahlot		16/1/2018		Initial Development		
***********************************************************************************************************************************************************
*/
@isTest 
public with sharing class ContractEventSentTest {
    @TestSetup 
    static void testDataSetUp(){
        ContractEventTestingUtility.getContractDataForAllEvents();
    }
    
    static testMethod void testContractEventSentNewOpportunity(){
        List<Opportunity> lstOpportunities = [SELECT Id, Name, Billing_Account__r.UUID__c,Type__c, (SELECT Id, Status__c,Reservable__r.UUID__c FROM Opportunity_Move_Outs__r), (Select Id, Reservable__c, Start_Date__c, Opportunity__c, Monthly_Price__c From Opportunity_Offices__r) FROM Opportunity order by createdDate LIMIT 1];        
        debug.log('lstOpportunities: '+lstOpportunities);
        List<Reservable__c> lstReservable = [SELECT Id, uuid__c, Building__c FROM Reservable__c WHERE UUID__c != null];
        system.assert(lstReservable.size() > 0);
        Set<Id> setBuildingIds = new Set<Id>();
        for(Reservable__c obj : lstReservable){
            setBuildingIds.add(obj.Building__c);
        }
        List<Building__c> lstBuilding = [SELECT Id, uuid__c FROM Building__c WHERE UUID__c != null AND Id In : setBuildingIds];
        system.assert(lstBuilding.size() > 0);
        
        
        List<Billing_Account__c> lstBillingAccount = [SELECT Id, uuid__c FROM Billing_Account__c WHERE UUID__c != null];
        system.assert(lstBillingAccount.size() > 0);
        
        List<Contact> lstContacts = [SELECT Id, uuid__c, Email FROM Contact WHERE UUID__c != null];
        system.assert(lstContacts.size() > 0);
        
        Map<String,Object> mapPayLoadValues = new Map<String,Object>();
        
        List<WWTypes.commitmentTerms> lstcommitmentTerms  = ContractEventTestingUtility.getCommitmentsForPayload(lstBuilding);
        
        List<WWTypes.Discounts> lstDiscounts = ContractEventTestingUtility.getDiscountsForPayload(lstBuilding);
        
        List<WWTypes.move_insVal> lstmove_insVal = ContractEventTestingUtility.getMoveInsForPayload(lstBuilding, lstReservable);        
        
        List<WWTypes.move_outssVal> lstmove_outssVal = ContractEventTestingUtility.getMoveOutsforPayload(lstBuilding, lstReservable);
        
        List<WWTypes.products> lstproductss = ContractEventTestingUtility.getProductsforPayload(lstBuilding, lstReservable);
        debug.log('lstproductss: '+lstproductss);
        String strContractExpiration = '2018-03-06 08:37:30';
        Long longContractExpiration = DateTime.valueOf(strContractExpiration).getTime();
        WWTypes.ContractEvent ObjContractEvent = ContractEventTestingUtility.getCompletePayloadForContract('Contract Sent', lstBillingAccount[0].UUID__c, lstContacts[0].Email, 'New opportunity', 'USD', 'www.test.com,www.test1.com', '2018-10-14', 'Commitment', String.valueOf(lstOpportunities[0].Id), lstContacts[0].uuid__c, String.valueOf(strContractExpiration), null, lstcommitmentTerms, lstDiscounts, lstproductss, lstmove_insVal, lstmove_outssVal);
        RESTContractEvent.Response response = ContractEventTestingUtility.callOutToContractEventEndPoint(ObjContractEvent);
        Debug.log('response testContractEventSentSearchCriteriaNewOpportunity ::'+response);
        System.assertEquals(true, response.success);
        System.assert(response.result.startsWith('"New Opportunity :'));
        Id OpportunityId;
        if(response.result != null && response.result != ''){
            Debug.Log('response.result--'+response.result);
        	OpportunityId = ContractEventTestingUtility.extractIdFromResultInContractEvent(response.result);
            Debug.Log('OpportunityId--'+OpportunityId);
        }
        Map<Id,OpportunityLineItem> mapOpportunityLineItem = new Map<Id,OpportunityLineItem>();
        Debug.Log('ContractEvenetSentTest OpportunityId--'+OpportunityId);
        Opportunity opp = ContractEventTestingUtility.getOpportunityAfterContractRequest(OpportunityId);
        debug.log('ContractEvenetSentTest opp-----:'+opp);
        System.assertEquals(12.00, opp.Commitment_Term_in_months__c);
        ContractEventTestingUtility.payloadAssertion(ObjContractEvent, opp, null);
        System.assertEquals(Date.ValueOf(lstmove_insVal[2].start_date), opp.Actual_Start_Date__c);//Latest date on movein
        System.assertEquals(lstContacts[0].Id, opp.Send_Paperwork_By__c);
        System.assertEquals(lstContacts[0].UUID__c, opp.Community_Manager_UUID__c);
        System.assertEquals(lstContacts[0].Id, opp.Community_User__c);
        System.assertEquals(lstContacts[0].Id, opp.Primary_Member__c);
        System.assertEquals('Mixed', opp.Type__c);
        System.assertEquals(opp.Billing_Account__c, lstBillingAccount[0].id);
        
    }
    
    static testMethod void testContractEventSentUpdateOpportunity(){
        List<Opportunity> lstOpportunities = [SELECT Id, Name, Billing_Account__r.UUID__c,(SELECT Id,ProductCode FROM OpportunityLineItems), (SELECT Id, Status__c,Reservable__r.UUID__c FROM Opportunity_Move_Outs__r), (Select Id, Reservable__c, Start_Date__c, Opportunity__c, Monthly_Price__c From Opportunity_Offices__r) FROM Opportunity order by createdDate desc];        
        
        List<Reservable__c> lstReservable = [SELECT Id, uuid__c, Building__c FROM Reservable__c WHERE UUID__c != null];
        system.assert(lstReservable.size() > 0);
        Set<Id> setBuildingIds = new Set<Id>();
        for(Reservable__c obj : lstReservable){
            setBuildingIds.add(obj.Building__c);
        }
        List<Building__c> lstBuilding = [SELECT Id, uuid__c FROM Building__c WHERE UUID__c != null AND Id In : setBuildingIds];
        system.assert(lstBuilding.size() > 0);
        
        
        List<Billing_Account__c> lstBillingAccount = [SELECT Id, uuid__c FROM Billing_Account__c WHERE UUID__c != null];
        system.assert(lstBillingAccount.size() > 0);
        
        List<Contact> lstContacts = [SELECT Id, uuid__c, Email FROM Contact WHERE UUID__c != null];
        system.assert(lstContacts.size() > 0);
        
        Map<String,Object> mapPayLoadValues = new Map<String,Object>();
        
        List<WWTypes.commitmentTerms> lstcommitmentTerms  = ContractEventTestingUtility.getCommitmentsForPayload(lstBuilding);
        
        List<WWTypes.Discounts> lstDiscounts = ContractEventTestingUtility.getDiscountsForPayload(lstBuilding);
        
        List<WWTypes.move_insVal> lstmove_insVal = ContractEventTestingUtility.getMoveInsForPayload(lstBuilding, lstReservable);        
        
        List<WWTypes.move_outssVal> lstmove_outssVal = ContractEventTestingUtility.getMoveOutsforPayload(lstBuilding, lstReservable);
        
        List<WWTypes.products> lstproductss = ContractEventTestingUtility.getProductsforPayload(lstBuilding, lstReservable);
        
        String strContractExpiration = '2018-03-06 08:37:30';
        Long longContractExpiration = DateTime.valueOf(strContractExpiration).getTime();
        
        WWTypes.ContractEvent ObjContractEvent = ContractEventTestingUtility.getCompletePayloadForContract('Contract Sent', lstOpportunities[0].Billing_Account__r.UUID__c, lstContacts[0].Email, 'New opportunity', 'USD', 'www.test.com,www.test1.com', '2018-10-14', 'Commitment', null, lstContacts[0].uuid__c, String.valueOf(strContractExpiration), String.ValueOf(lstOpportunities[0].Id), lstcommitmentTerms, lstDiscounts, lstproductss, lstmove_insVal, lstmove_outssVal);
        Debug.Log('ObjContractEvent==>'+ObjContractEvent);
        
        RESTContractEvent.Response response = ContractEventTestingUtility.callOutToContractEventEndPoint(ObjContractEvent);
        Debug.log('response testContractEventSentSearchCriteriaNewOpportunity ::'+response);
        System.assertEquals(true, response.success);
        System.assert(response.result.startsWith('"Update Opportunity :'));
        Id OpportunityId;
        if(response.result != null && response.result != '')
            OpportunityId = ContractEventTestingUtility.extractIdFromResultInContractEvent(response.result);
        System.assertEquals(String.valueOf(lstOpportunities[0].Id), OpportunityId);
        Opportunity opp = ContractEventTestingUtility.getOpportunityAfterContractRequest(OpportunityId);
        
        System.assertEquals(12.00, opp.Commitment_Term_in_months__c);
        ContractEventTestingUtility.payloadAssertion(ObjContractEvent, opp, null);
        System.assertEquals(Date.ValueOf(lstmove_insVal[2].start_date), opp.Actual_Start_Date__c);//Latest date on movein
        System.assertEquals(lstContacts[0].Id, opp.Send_Paperwork_By__c);
        System.assertEquals(lstContacts[0].UUID__c, opp.Community_Manager_UUID__c);
        System.assertEquals(lstContacts[0].Id, opp.Community_User__c);
        System.assertEquals(lstContacts[0].Id, opp.Primary_Member__c);
        System.assertEquals('Mixed', opp.Type__c);
        System.assertEquals(opp.Billing_Account__c, lstBillingAccount[0].id);
    }
    
    static testMethod void testCurrencyChangeWithOpportunity_Id(){
        
        List<Opportunity> lstOpportunities = [SELECT Id, Name, Billing_Account__r.UUID__c, CurrencyIsoCode, (SELECT Id,ProductCode FROM OpportunityLineItems), (SELECT Id, Status__c,Reservable__r.UUID__c FROM Opportunity_Move_Outs__r), (Select Id, Reservable__c, Start_Date__c, Opportunity__c, Monthly_Price__c From Opportunity_Offices__r) FROM Opportunity order by createdDate LIMIT 1];        
        
        List<PriceBookEntry> lstpricebook = [SELECT ID FROM PriceBookEntry WHERE ProductCode = 'Not Considered' AND CurrencyIsoCode =: lstOpportunities[0].CurrencyIsoCode];
        
        OpportunityLineItem objLineItem = new OpportunityLineItem(
            PriceBookEntryId = lstpricebook[0].Id,
            UnitPrice = 56,
            quantity = 20,
            OpportunityId = lstOpportunities[0].Id
        );
        TestingUtility.insertWithAssert(objLineItem);
        
        
        List<Reservable__c> lstReservable = [SELECT Id, uuid__c, Building__c FROM Reservable__c WHERE UUID__c != null];
        system.assert(lstReservable.size() > 0);
        Set<Id> setBuildingIds = new Set<Id>();
        for(Reservable__c obj : lstReservable){
            setBuildingIds.add(obj.Building__c);
        }
        List<Building__c> lstBuilding = [SELECT Id, uuid__c FROM Building__c WHERE UUID__c != null AND Id In : setBuildingIds];
        system.assert(lstBuilding.size() > 0);
        
        
        List<Billing_Account__c> lstBillingAccount = [SELECT Id, uuid__c FROM Billing_Account__c WHERE UUID__c =: lstOpportunities[0].Billing_Account__r.UUID__c];
        system.assert(lstBillingAccount.size() > 0);
        
        List<Contact> lstContacts = [SELECT Id, uuid__c, Email FROM Contact WHERE UUID__c != null];
        system.assert(lstContacts.size() > 0);
        
        Map<String,Object> mapPayLoadValues = new Map<String,Object>();
        
        List<WWTypes.commitmentTerms> lstcommitmentTerms  = ContractEventTestingUtility.getCommitmentsForPayload(lstBuilding);
        
        List<WWTypes.Discounts> lstDiscounts = ContractEventTestingUtility.getDiscountsForPayload(lstBuilding);
        
        List<WWTypes.move_insVal> lstmove_insVal = ContractEventTestingUtility.getMoveInsForPayload(lstBuilding, lstReservable);        
        
        List<WWTypes.move_outssVal> lstmove_outssVal = ContractEventTestingUtility.getMoveOutsforPayload(lstBuilding, lstReservable);
        
        List<WWTypes.products> lstproductss = ContractEventTestingUtility.getProductsforPayload(lstBuilding, lstReservable);
        
        String strContractExpiration = '2018-03-06 08:37:30';
        Long longContractExpiration = DateTime.valueOf(strContractExpiration).getTime();
        
        WWTypes.ContractEvent ObjContractEvent = ContractEventTestingUtility.getCompletePayloadForContract('Contract Sent', lstOpportunities[0].Billing_Account__r.UUID__c, lstContacts[0].Email, 'Update opportunity', 'EUR', 'www.test.com,www.test1.com', '2018-10-14', 'Commitment', null, lstContacts[0].uuid__c, String.valueOf(strContractExpiration), String.ValueOf(lstOpportunities[0].Id), lstcommitmentTerms, lstDiscounts, lstproductss, lstmove_insVal, lstmove_outssVal);
        Debug.Log('ObjContractEvent==>'+ObjContractEvent);
        
        RESTContractEvent.Response response = ContractEventTestingUtility.callOutToContractEventEndPoint(ObjContractEvent);
        Debug.log('response testContractEventSentSearchCriteriaNewOpportunity ::'+response);
        System.assertEquals(true, response.success);
        System.assert(response.result.startsWith('"Update Opportunity :'));
        Id OpportunityId;
        if(response.result != null && response.result != ''){
            OpportunityId = ContractEventTestingUtility.extractIdFromResultInContractEvent(response.result);
        }  
        System.assertEquals(String.valueOf(lstOpportunities[0].Id), OpportunityId);
        Opportunity opp = ContractEventTestingUtility.getOpportunityAfterContractRequest(OpportunityId);
        
        System.assertEquals(12.00, opp.Commitment_Term_in_months__c);
        ContractEventTestingUtility.payloadAssertion(ObjContractEvent, opp, 'INR');
        System.assertEquals(Date.ValueOf(lstmove_insVal[2].start_date), opp.Actual_Start_Date__c);//Latest date on movein
        System.assertEquals(lstContacts[0].Id, opp.Send_Paperwork_By__c);
        System.assertEquals(lstContacts[0].UUID__c, opp.Community_Manager_UUID__c);
        System.assertEquals(lstContacts[0].Id, opp.Community_User__c);
        System.assertEquals(lstContacts[0].Id, opp.Primary_Member__c);
        System.assertEquals('Mixed', opp.Type__c);
        System.assertEquals(opp.Billing_Account__c, lstBillingAccount[0].id);
        
        debug.log('result testContractEventSentSearchCriteria update ::' + response);
        System.assertEquals(true, response.success);
        debug.log('response.result::' + response.result);
        System.assert(response.result.startsWith('"Update Opportunity :'));
        
    }
    
    
    static testMethod void testContractEventSentDealUpdateOpportunity(){
        List<Opportunity> lstOpportunities = [SELECT Id, Name, Billing_Account__r.UUID__c, CurrencyIsoCode FROM Opportunity order by createdDate];        
        
        List<Reservable__c> lstReservable = [SELECT Id, uuid__c, Building__c FROM Reservable__c WHERE UUID__c != null];
        system.assert(lstReservable.size() > 0);
        Set<Id> setBuildingIds = new Set<Id>();
        for(Reservable__c obj : lstReservable){
            setBuildingIds.add(obj.Building__c);
        }
        List<Building__c> lstBuilding = [SELECT Id, uuid__c FROM Building__c WHERE UUID__c != null AND Id In : setBuildingIds];
        system.assert(lstBuilding.size() > 0);
        
        List<Billing_Account__c> lstBillingAccount = [SELECT Id, uuid__c FROM Billing_Account__c WHERE UUID__c =: lstOpportunities[0].Billing_Account__r.UUID__c];
        system.assert(lstBillingAccount.size() > 0);
        
        List<Contact> lstContacts = [SELECT Id, uuid__c, Email FROM Contact WHERE UUID__c != null];
        system.assert(lstContacts.size() > 0);
        
        Map<String,Object> mapPayLoadValues = new Map<String,Object>();
        
        List<WWTypes.move_insVal> lstmove_insVal = ContractEventTestingUtility.getMoveInsForPayload(lstBuilding, lstReservable);        
        
        List<WWTypes.products> lstproductss = ContractEventTestingUtility.getProductsforPayload(lstBuilding, lstReservable);
        for(WWTypes.products objProduct : lstproductss){
            objProduct.product_code = 'PRDL-000001';
            break;
        }
        
        String strContractExpiration = '2018-03-06 08:37:30';
        Long longContractExpiration = DateTime.valueOf(strContractExpiration).getTime();
        
        WWTypes.ContractEvent ObjContractEvent = ContractEventTestingUtility.getCompletePayloadForContract('Contract Sent', lstOpportunities[0].Billing_Account__r.UUID__c, lstContacts[0].Email, 'Update opportunity', 'INR', 'www.test.com,www.test1.com', '2018-10-14', 'Commitment', null, lstContacts[0].uuid__c, String.valueOf(strContractExpiration), String.ValueOf(lstOpportunities[0].Id), null, null, lstproductss, lstmove_insVal, null);
        Debug.Log('ObjContractEvent==>'+ObjContractEvent);
        
        RESTContractEvent.Response response = ContractEventTestingUtility.callOutToContractEventEndPoint(ObjContractEvent);
        Debug.log('response testContractEventSentSearchCriteriaNewOpportunity ::'+response);
        System.assertEquals(true, response.success);
        System.assert(response.result.startsWith('"Update Opportunity :'));
        Id OpportunityId;
        if(response.result != null && response.result != ''){
            OpportunityId = ContractEventTestingUtility.extractIdFromResultInContractEvent(response.result);
        }  
        System.assertEquals(String.valueOf(lstOpportunities[0].Id), OpportunityId);
        Opportunity opp = ContractEventTestingUtility.getOpportunityAfterContractRequest(OpportunityId);
        
        
        ContractEventTestingUtility.payloadAssertion(ObjContractEvent, opp, null);
        System.assertEquals(Date.ValueOf(lstmove_insVal[2].start_date), opp.Actual_Start_Date__c);//Latest date on movein
        System.assertEquals(lstContacts[0].Id, opp.Send_Paperwork_By__c);
        System.assertEquals(lstContacts[0].UUID__c, opp.Community_Manager_UUID__c);
        System.assertEquals(lstContacts[0].Id, opp.Community_User__c);
        System.assertEquals(lstContacts[0].Id, opp.Primary_Member__c);
        System.assertEquals(opp.Billing_Account__c, lstBillingAccount[0].id);
    }
    
    static testMethod void testContractEventSentCreateNewDeal(){
        
        List<Opportunity> lstOpportunities = [SELECT Id, Name, Billing_Account__r.UUID__c, CurrencyIsoCode FROM Opportunity order by createdDate];        
        List<Reservable__c> lstReservable = [SELECT Id, uuid__c, Building__c FROM Reservable__c WHERE UUID__c != null];
        system.assert(lstReservable.size() > 0);
        Set<Id> setBuildingIds = new Set<Id>();
        for(Reservable__c obj : lstReservable){
            setBuildingIds.add(obj.Building__c);
        }
        List<Building__c> lstBuilding = [SELECT Id, uuid__c FROM Building__c WHERE UUID__c != null AND Id In : setBuildingIds];
        system.assert(lstBuilding.size() > 0);
        
        List<Billing_Account__c> lstBillingAccount = [SELECT Id, uuid__c FROM Billing_Account__c WHERE UUID__c =: lstOpportunities[0].Billing_Account__r.UUID__c];
        system.assert(lstBillingAccount.size() > 0);
        
        List<Contact> lstContacts = [SELECT Id, uuid__c, Email FROM Contact WHERE UUID__c != null];
        system.assert(lstContacts.size() > 0);
        
        Map<String,Object> mapPayLoadValues = new Map<String,Object>();
        
        List<WWTypes.move_insVal> lstmove_insVal = ContractEventTestingUtility.getMoveInsForPayload(lstBuilding, lstReservable);        
        
        List<WWTypes.products> lstproductss = ContractEventTestingUtility.getProductsforPayload(lstBuilding, lstReservable);
        for(WWTypes.products objProduct : lstproductss){
            objProduct.product_code = 'PRDL-000001';
            break;
        }
        
        String strContractExpiration = '2018-03-06 08:37:30';
        Long longContractExpiration = DateTime.valueOf(strContractExpiration).getTime();
        
        WWTypes.ContractEvent ObjContractEvent = ContractEventTestingUtility.getCompletePayloadForContract('Contract Sent', lstOpportunities[0].Billing_Account__r.UUID__c, lstContacts[0].Email, 'Update opportunity', 'INR', 'www.test.com,www.test1.com', '2018-10-14', 'Commitment', null, lstContacts[0].uuid__c, String.valueOf(strContractExpiration), null, null, null, lstproductss, lstmove_insVal, null);
        Debug.Log('ObjContractEvent==>'+ObjContractEvent);
        
        RESTContractEvent.Response response = ContractEventTestingUtility.callOutToContractEventEndPoint(ObjContractEvent);
        Debug.log('response testContractEventSentSearchCriteriaNewOpportunity ::'+response);
        System.assertEquals(true, response.success);
        System.assert(response.result.startsWith('"New Opportunity :'));
        Id OpportunityId;
        if(response.result != null && response.result != ''){
            OpportunityId = ContractEventTestingUtility.extractIdFromResultInContractEvent(response.result);
        }
        
        Opportunity opp = ContractEventTestingUtility.getOpportunityAfterContractRequest(OpportunityId);
        
        ContractEventTestingUtility.payloadAssertion(ObjContractEvent, opp, null);
        System.assertEquals(Date.ValueOf(lstmove_insVal[2].start_date), opp.Actual_Start_Date__c);//Latest date on movein
        System.assertEquals(lstContacts[0].Id, opp.Send_Paperwork_By__c);
        System.assertEquals(lstContacts[0].UUID__c, opp.Community_Manager_UUID__c);
        System.assertEquals(lstContacts[0].Id, opp.Community_User__c);
        System.assertEquals(lstContacts[0].Id, opp.Primary_Member__c);
        System.assertEquals(opp.Billing_Account__c, lstBillingAccount[0].id);
    }
}