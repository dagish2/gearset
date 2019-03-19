@RestResource(urlMapping='/OpportunitySend/*')
global class RESTOpportunitySend {
	@HttpPost
	global static Response doPost() {
		RESTOpportunitySend.Response response = new RESTOpportunitySend.Response();
		
		try {
			System.debug('-------- uri: ' + RestContext.request.requestURI);
			String opportunityID = RestContext.request.requestURI.substring(
      													RestContext.request.requestURI.lastIndexOf('/') + 1
      											 );

	    	//URL decode
	    	opportunityID = EncodingUtil.urlDecode(opportunityID, 'UTF-8');
	
	    	//rebuild base64
	    	opportunityID = EncodingHandler.decode(opportunityID);
	
	    	//parse opportunity ID and catch any potential attack/injection
	  		Id oID = Id.valueOf(opportunityID);
	  		System.debug('-------- oId: ' + oID);
			OpportunityServices.sendContract(oID);
			response.setSuccess('Contract sent!'); 
		} catch(Exception e) {
			response.setFailure('unable to send contract: ' + e.getMessage() );
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