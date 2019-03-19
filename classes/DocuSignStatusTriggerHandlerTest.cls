/************************************************************************************************************************************
    Author 		: 	Aanat Kumar	
    Description : 	This is a test class moved by TestDocusignTriggers test class.

    History		:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
	1			07 July 2016		Aanat Kumar				Initial Developement
**************************************************************************************************************************************/
@isTest
private class DocuSignStatusTriggerHandlerTest {
    static{
        SalesConsoleSettings.createSettings();
    }
    /************************************************************************************************************************************
		Author 				: 	Aanat Kumar
		Description 		: 	This test method will verify document sign status after opportunity closed won.
		Created Date		:	07 July 2016
	**************************************************************************************************************************************/
    static testMethod void testDocusignStatusOpportunityWon() {
        
        Account p_account = new Account(name = 'Acme', UUID__c = 'account-uuid');
        insert p_account;
        
        Contact c_primary = new Contact(firstname = 'Paul',lastname = 'Boss', email = 'test@example.com', AccountId = p_account.id);
        insert c_primary;
        
        Opportunity o = new Opportunity(Name = 'Test', CloseDate = Date.today(), StageName = 'Qualifying', AccountId = p_account.id, Primary_Member__c = c_primary.Id);
        insert o;
        
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__Opportunity__c = o.Id, dsfs__Envelope_Status__c = 'Fake status');
        insert dsStatus;
        
        o = [select StageName,Primary_Member__c from Opportunity where Id = :o.Id];
        debug.log('Primary_Member__c ==>'+o);
        System.assertNotEquals('Closing', o.StageName);
        
        dsStatus.dsfs__Envelope_Status__c = 'Completed';
        update dsStatus;
        
        o = [select StageName from Opportunity where Id = :o.Id];
        System.assertEquals('Closing', o.StageName);
    }
}