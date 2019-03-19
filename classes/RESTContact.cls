@RestResource(urlMapping='/Person/*')
global class RESTContact {
    public static string contactSFID;
    public static string contactUUID;
    @HttpPost
    global static Response doPost(WWTypes.Person body) {
        Debug.log('Person body---'+body);
        RESTContact.Response response = new RESTContact.Response();
        try {
            ContactHandler handlerObj = new ContactHandler(body);
            response.setSuccess('Succeeded');     
        }
        catch(Exception pEx) {
            response.setFailure('unable to process: ' + pEx.getMessage() );
        }
        return response;
    }
    
    global class applicationException extends Exception {}
    
    global class Response {
        public Boolean success;
        public String message;
        public String result;
        public String contact_sfid;
        public String contact_uuid;
        
        public void setSuccess(String pResult) {
            this.success = true;
            this.result = pResult;
            this.contact_sfid = RESTContact.contactSFID;
            this.contact_uuid = RESTContact.contactUUID;
        }
        
        public void setFailure(String pMessage) {
            this.success = false; 
            this.message = pMessage;
        }
  
    }
}