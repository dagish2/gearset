/******************************************************************************************************************** 
Name              : QueueRollbarItemSubmitTest.cls 
Description       : test class. test class for (Rollbar,RollbarConnection,QueueRollbarItemSubmit,RollBarItem) 

Revision History  :-
Created/Modified by         Created/Modified Date       Requested by         Technical Design Proposal
---------------------------------------------------------------------------------------------------------------------
1. Rashad Saeed (Creator)      31 DEC 2018              WeWork                 SF - Rollbar Integration  Google Doc  
---------------------------------------------------------------------------------------------------------------------
*********************************************************************************************************************/
@IsTest
private class QueueRollbarItemSubmitTest {
    static testMethod void shouldSuccessfullyCalloutToRollbar() {
        Apex_Debug_Log__c Alog = new Apex_Debug_Log__c(Apex_Class__c='Test');
        insert Alog;
        RollbarItem testItem = new RollbarItem(Alog);
        QueueableContext qc;
        QueueRollbarItemSubmit q = new QueueRollbarItemSubmit();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        q.execute(qc);
        Test.stopTest();
    }
}