/*****************************************************************************************************************************
Author 		:  Sunil Bhosale
Description :  This class is used as 
Date		:  15 July 2018
Issue		:  ST-2655
----------------------------------------------------------------------------------------------------------------------------------
VERSION					DATE					AUTHOR							DETAIL
1.0					15,July 2018		    Sunil Bhosale	                Initial Developement

******************************************************************************************************************************/
@isTest
public class BrokerInvolvedControllerTest {
    
    @Testsetup
    static void initData(){
        SalesConsoleSettings.createSettings();  
        Account accRec = TestingUtility.createAccount('TestAccount1', true);
        Contact conRec = new Contact(
            firstname  = 'John',
            lastname   = 'Rambo',
            email     = 'test1@example.com',
            accountID  = accRec.Id,
            Status__c  = 'active'
        );
        insert conRec;
        accRec.Primary_Member__c = conRec.Id;
        update accRec;
        Contact referrerContact = new Contact(
            firstname  = 'John',
            lastname   = 'Rambo',
            email     = 'test2@example.com',
            accountID  = accRec.Id,
            Status__c  = 'active'
        );
        insert referrerContact;
        
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec.Primary_Member__c = conRec.Id;
        oppRec.Broker_Involved__c = false;
        oppRec.StageName = 'Selling';
        oppRec.CloseDate = system.today().addDays(5);
        oppRec.Amount = 150;
        oppRec.RecordTypeId = oppRecordType.get('Consumer');
        TestingUtility.insertWithAssert(oppRec);
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec1.Primary_Member__c = conRec.Id;
        oppRec1.StageName = 'Selling';
        oppRec1.Broker_Involved__c = false;
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        TestingUtility.insertWithAssert(oppRec1);
        List<Opportunity> lstOpportunity = [select id from Opportunity ];
        System.assert(lstOpportunity.size() > 0);
        List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
        for(Opportunity opportunity : lstOpportunity){
            opportunity.Referrer__c = referrerContact.Id;
            lstOpportunityToUpdate.add(opportunity);
        }
        update lstOpportunityToUpdate ;
    }
    
    static testMethod void verifyBrokerInvolved(){
        List<Opportunity> lstOpportunity = [SELECT Id, Referrer__c FROM Opportunity ];
        test.startTest();
        BrokerInvolvedController.updateBrokerInvolved(lstOpportunity[0].Id);
        BrokerInvolvedController.updateBrokerInvolved(lstOpportunity[1].Id);
        test.stopTest();
        for(Opportunity opportunity : [SELECT Id, Referrer__c, Broker_Involved_DateTime__c, Broker_Involved__c, Broker_Involvement_Indicated__c FROM Opportunity ]){
            System.assertEquals(Date.today(), opportunity.Broker_Involved_DateTime__c);
            System.assertEquals('Yes', opportunity.Broker_Involvement_Indicated__c);
        }
    }
    
}