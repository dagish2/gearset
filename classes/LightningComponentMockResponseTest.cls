@isTest
global class LightningComponentMockResponseTest implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        Debug.log('Set Mock');
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('Success');
        res.setStatusCode(200);
        return res;
    }
}