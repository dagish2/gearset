@isTest
global class TourOutcomeFormMockResponceTest implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;
    
   public TourOutcomeFormMockResponceTest() {
  }

    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('Success');
        res.setStatusCode(200);
        return res;
    }
}