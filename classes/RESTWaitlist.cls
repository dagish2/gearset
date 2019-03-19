@RestResource(urlMapping='/Waitlist/*')
global class RESTWaitlist {
  @HttpPost
  global static Response doPost(WWTypes.Waitlist body) {
    RESTWaitlist.Response response = new RESTWaitlist.Response();
    
    try {
        //serialize - might throw exceptions
        String soid = WaitlistHandler.process_waitlist(body);

        response.setSuccess(soid);     
    }
    catch(Exception pEx) {
        response.setFailure('unable to process: ' + pEx.getMessage() );
    }
    
    return response;
  }
  
  global class Response {
    public Boolean success;
    public String message;
    public String result;

    public void setSuccess(Object pResult) {
        this.success = true; 
        this.result = pResult != null ? JSON.serializePretty(pResult) : '';
    }
    
    public void setFailure(String pMessage) {
        this.success = false; 
        this.message = pMessage;
    }
  
  }
}