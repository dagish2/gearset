/**
* Name			:	ContractEventSignedTest	 
* Issue No.		: 	
* Purpose		:	This contains the test methods of 'Contract Signed' event.
* History		
	Version			Author				Date			Detail						Feature			IssueNumber
	1.0				Rupesh Patil		1/31/2018		Initial Development							
***********************************************************************************************************************************************************
*/
@isTest 
public class ContractEventSignedTest {
    @TestSetup 
    static void testDataSetUp(){
     ContractEventTestingUtility.getContractDataForAllEvents();      
    }
    public static testMethod void testDealProductsCreateNewOpportunity(){
        List<Opportunity> lstOpportunities = [SELECT Id, Name, Billing_Account__r.UUID__c, Primary_Member__r.Email, (SELECT Id, Status__c, Reservable__r.UUID__c FROM Opportunity_Move_Outs__r), (Select Id, Reservable__c, Start_Date__c, Opportunity__c, Monthly_Price__c From Opportunity_Offices__r) FROM Opportunity order by createdDate];        
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
        List<WWTypes.move_insVal> lstmove_insVal = ContractEventTestingUtility.getMoveInsForPayload(lstBuilding, lstReservable);        
        List<WWTypes.products> lstproducts = ContractEventTestingUtility.getProductsforPayload(lstBuilding, lstReservable);     
        WWTypes.ContractEvent ObjContractEventSigned = ContractEventTestingUtility.getCompletePayloadForContract('Contract Signed', lstBillingAccount[2].UUID__c, lstOpportunities[0].Primary_Member__r.Email, 'abc123jnk', 'INR', '', '2018-11-06', 'New Business', '', lstContacts[1].UUID__c, '', '', null, null, lstproducts, lstmove_insVal, null);
        RESTContractEvent.Response response = ContractEventTestingUtility.callOutToContractEventEndPoint(objContractEventSigned);
        Debug.log('Response From REST API :::'+response);
        String oppoId;
        if(response.result != null && response.result != '')
            oppoId = ContractEventTestingUtility.extractIdFromResultInContractEvent(response.result);
        System.assertEquals(true, response.success);
        System.assert(response.result.startsWith('"New Opportunity :'));
        List<Opportunity> lstOpp = [SELECT Id, Billing_Account__c, StageName, CurrencyIsoCode, Contract_Signed_On_Date__c, Contract_UUID__c, Building__c, Contract_Stage__c,(select Id, Quantity, UnitPrice, Building_UUID__c, Building__c, CurrencyIsoCode From OpportunityLineItems) FROM Opportunity WHERE ID =:oppoId];
        System.assertEquals(3, lstopp[0].OpportunityLineItems.size());
        System.assertEquals(lstOpp[0].Id, oppoId);
        System.assertEquals(lstBuilding[0].Id, lstOpp[0].Building__c);
		System.assertEquals(lstOpp[0].Billing_Account__c, lstBillingAccount[2].id);		
        
    }
    public static testMethod void testContractEventSigned_SearchWithOpportunityId(){
        List<Opportunity> lstOpportunities = [SELECT Id, Name, Billing_Account__r.UUID__c, Primary_Member__r.Email, (SELECT Id, Status__c, Reservable__r.UUID__c FROM Opportunity_Move_Outs__r), (Select Id, Reservable__c, Start_Date__c, Opportunity__c, Monthly_Price__c From Opportunity_Offices__r) FROM Opportunity order by createdDate];        
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
        List<WWTypes.move_insVal> lstmove_insVal = ContractEventTestingUtility.getMoveInsForPayload(lstBuilding, lstReservable);        
        List<WWTypes.products> lstproducts = ContractEventTestingUtility.getProductsforPayload(lstBuilding, lstReservable);     
        WWTypes.ContractEvent ObjContractEventSigned = ContractEventTestingUtility.getCompletePayloadForContract('Contract Signed', lstBillingAccount[1].UUID__c, lstOpportunities[2].Primary_Member__r.Email, 'abc123jnk', 'INR', '', '2018-11-06', 'Upgrade', '', lstContacts[2].UUID__c, '', string.valueof(lstOpportunities[2].Id), null, null, lstproducts, lstmove_insVal, null);
        RESTContractEvent.Response response = ContractEventTestingUtility.callOutToContractEventEndPoint(objContractEventSigned);
        Debug.log('Response From REST API :::'+response);
        String oppoId;
        if(response.result != null && response.result != '')
            oppoId = ContractEventTestingUtility.extractIdFromResultInContractEvent(response.result);
        System.assertEquals(true, response.success);
        System.assert(response.result.startsWith('"Update Opportunity :'));
        List<Opportunity> lstOpp = [SELECT Id, Billing_Account__c, StageName, CurrencyIsoCode, Contract_Signed_On_Date__c, Contract_UUID__c, Contract_Stage__c, Type__c,(select Id, Quantity, UnitPrice, Building_UUID__c, Building__c, CurrencyIsoCode From OpportunityLineItems) FROM Opportunity WHERE ID =:oppoId];
        system.assertEquals(3, lstopp[0].OpportunityLineItems.size());//Only deal
        System.assertEquals(lstOpp[0].Id, oppoId);
        System.assertEquals('Closed Won', lstOpp[0].StageName);
        System.assertEquals('INR', lstOpp[0].CurrencyIsoCode);//To check currency value change from AUD to INR
        System.assertEquals(Date.valueOf(objContractEventSigned.contract_date), lstOpp[0].Contract_Signed_On_Date__c);
        System.assertEquals('Mixed', lstOpp[0].Type__c);
        System.assertEquals(lstOpp[0].Billing_Account__c, lstBillingAccount[1].id);
        List<Opportunity_Reservable__c> lstOpportunityReservable = [SELECT Id, Building__c, Start_Date__c, Pending_Desks__c, Monthly_Price__c, Reservable__r.UUID__c, Commitment_Terms_End_Date__c FROM Opportunity_Reservable__c WHERE opportunity__c =: oppoId];
        System.assertEquals(3, lstOpportunityReservable.size());
        List<Opportunity_Move_Outs__c> lstOpportunityMoveOut = [SELECT Id, Building__c, Move_Out_Date__c, Pending_Desks__c, Monthly_Price__c FROM Opportunity_Move_Outs__c WHERE opportunity__c =: oppoId ];
        System.assertEquals(0, lstOpportunityMoveOut.size());       
    }
    static testMethod void testDiscardContractEventMethod(){ 
        List<Opportunity> lstOpportunities = [SELECT Id, Name, Billing_Account__r.UUID__c, Primary_Member__r.Email, contract_UUId__c, (SELECT Id, Status__c, Reservable__r.UUID__c FROM Opportunity_Move_Outs__r), (Select Id, Reservable__c, Start_Date__c, Opportunity__c, Monthly_Price__c From Opportunity_Offices__r) FROM Opportunity order by createdDate];        
        Debug.log('lstOpportunities'+ lstOpportunities);
        lstOpportunities[1].contract_UUId__c = 'abcdef123';
        lstOpportunities[1].StageName = 'Closing';
        lstOpportunities[1].Contract_Stage__c = 'Contract Sent';
        TestingUtility.updateListWithAssert(lstOpportunities);
        Test.setMock(HttpCalloutMock.class, new ContractEventMockHttpResponseGenerator());
        String result = ContractEventServices.updateOppContractDiscard(lstOpportunities[0].contract_UUId__c);
        system.assertEquals('true', result);
        Test.startTest();
            String result1  = ContractEventServices.discardContractEvent(lstOpportunities[1].contract_UUId__c);
            string result2  = ContractEventServices.discardContractEvent(lstOpportunities[2].contract_UUId__c);
        Test.stopTest();
    }
    
    static testMethod void testResendpaperwork(){      
        List<Opportunity> lstOpportunities = [SELECT Id, Name, Billing_Account__r.UUID__c, Primary_Member__r.Email, contract_UUId__c, (SELECT Id, Status__c, Reservable__r.UUID__c FROM Opportunity_Move_Outs__r), (Select Id, Reservable__c, Start_Date__c, Opportunity__c, Monthly_Price__c From Opportunity_Offices__r) FROM Opportunity order by createdDate];        
        Debug.log('lstOpportunities'+ lstOpportunities);
        lstOpportunities[0].contract_UUId__c = 'abcdef123';
        TestingUtility.updateListWithAssert(lstOpportunities);
        Test.setMock(HttpCalloutMock.class, new ContractEventMockHttpResponseGenerator());
        Test.startTest();
        	String result = ContractEventServices.resendPaperworkLightning(lstOpportunities[0].contract_UUId__c);
        Test.stopTest();
        Opportunity opp = ContractEventServices.getOppData(lstOpportunities[0].Id);
        System.assertNotEquals(null, opp);
}
}