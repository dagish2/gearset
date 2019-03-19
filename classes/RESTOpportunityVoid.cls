@RestResource(urlMapping='/OpportunityVoid/*')
global class RESTOpportunityVoid {
	@HttpPost
	global static Response doPost() {
		RESTOpportunityVoid.Response response = new RESTOpportunityVoid.Response();
		
		try {
			System.debug('-------- uri: ' + RestContext.request.requestURI);
			String opportunityID = RestContext.request.requestURI.substring(
      													RestContext.request.requestURI.lastIndexOf('/') + 1
      											 );

	    	//URL decode
	    	opportunityID = EncodingUtil.urlDecode(opportunityID, 'UTF-8');
	
	    	//rebuild base64
	    	if(!opportunityID.startsWith('006'))
            	opportunityID = EncodingHandler.decode(opportunityID);
	
	    	//parse opportunity ID and catch any potential attack/injection
	  		Id oID = Id.valueOf(opportunityID);
	  		System.debug('-------- oId: ' + oID);
			
			//find opportunity
			Opportunity o = [select StageName from Opportunity where id=:oID];
			
			//update stage
			o.StageName = 'Closing';
			update o;
			
			response.setSuccess('Contract voided!');
		} catch(Exception e) {
			response.setFailure('unable to void contract: ' + WeworkEngine.exceptionFormatter(e) );
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