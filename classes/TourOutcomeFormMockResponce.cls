@isTest
global class TourOutcomeFormMockResponce implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        Debug.log('Set Mock');
        HttpResponse res = new HttpResponse();
        if('https://sales-api-staging.wework.com/v1/reasons' == req.getEndpoint()){
            // No Contract
            Debug.log('HttpResponse step 1 ::');
            res.setHeader('Content-Type','text/csv');
            res.setBody('{"reasons":[{"id":"5d70a116-1668-11e6-bd86-22000b2885a7","text":"Interested for the future","scope":"interested"},{"id":"5d6e88d6-1668-11e6-bd86-22000b2885a7","text":"Does not meet their needs","scope":"uninterested"}]}');
            res.setStatusCode(200);            
        }        
        return res;
        /*     
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('Success');
        res.setStatusCode(200);
        return res;*/
    }
}