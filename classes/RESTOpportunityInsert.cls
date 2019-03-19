@RestResource(urlMapping='/OpportunityInsert/*')
global class RESTOpportunityInsert {
    @HttpPost
    global static Response doPost(WWTypes.OpportunityInsert body) {
        RESTOpportunityInsert.Response response = new RESTOpportunityInsert.Response();
        
        try {
            //serialize - might throw exceptions
            OpportunityServices.insertOpportunity(body);
            
            response.setSuccess('Perfect update!');     
        }
        catch(Exception pEx) {
            response.setFailure('unable to process: ' + pEx.getMessage() );
            debug.Log('Exception-- On Line : ' +pEx.getLineNumber() );
            debug.Log('Exception-- Message : ' + pEx.getMessage());
            debug.Log('Exception-- Trace : ' + pEx.getStackTraceString());
            debug.Log('Exception-- Cause : ' + pEx.getCause());
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