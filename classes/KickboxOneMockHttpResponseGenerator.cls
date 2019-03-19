@isTest
global class KickboxOneMockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        Setting__c RecordJSONKickboxAPI = Settings.get('KickboxAPI');
        CheckEmailQuality.JsonKickboxAPI objJSONKickboxAPI = new CheckEmailQuality.JsonKickboxAPI();
        Debug.log('In KickboxOneMockHttpResponseGenerator RecordJSONKickboxAPI :: '+RecordJSONKickboxAPI);
        objJSONKickboxAPI = (CheckEmailQuality.JsonKickboxAPI)JSON.deserialize(RecordJSONKickboxAPI.Data__c, CheckEmailQuality.JsonKickboxAPI.Class);
        Debug.log('In KickboxOneMockHttpResponseGenerator objJSONKickboxAPI :: '+objJSONKickboxAPI);
        
        HttpResponse res = new HttpResponse();
        if(objJSONKickboxAPI.API[0].url+''+objJSONKickboxAPI.API[0].apikey == req.getEndpoint()){
            // Create a fake response for step 1
            res.setHeader('Content-Type','text/csv');
            res.setBody('{"id":141389,"success":true,"message":null}');
            res.setStatusCode(200);
            
        }
        return res;
    }
}