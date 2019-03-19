/******************************************************************************************************************** 
Name              : MockHttpResponseGenerator.cls 
Description       : Mock Http class for tests.

Revision History  :-
Created/Modified by         Created/Modified Date       Requested by         Technical Design Proposal
---------------------------------------------------------------------------------------------------------------------
1. Rashad Saeed (Creator)      31 DEC 2018              WeWork                 SF - Rollbar Integration  Google Doc  
---------------------------------------------------------------------------------------------------------------------
*********************************************************************************************************************/
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {  
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
}