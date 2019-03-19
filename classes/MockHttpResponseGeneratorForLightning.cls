/*
 * @ Created By : Samadhan Kadam
 * @ Created Date : 06 April 2017
 * @This class is created for generate fake response which is used in LightningComponentControllerTest class. 
 */
@isTest
global class MockHttpResponseGeneratorForLightning implements HttpCalloutMock{
	 global HTTPResponse respond(HTTPRequest req) {         
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(200);
        return res;
     }
}