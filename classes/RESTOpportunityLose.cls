@RestResource(urlMapping='/OpportunityLose/*')
global class RESTOpportunityLose {
	@HttpPost
	global static Response doPost(WWTypes.Stage stage) {
		RESTOpportunityLose.Response response = new RESTOpportunityLose.Response();
		
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
			
			//find opportunity
			Opportunity o = [select StageName, Lost_Reason__c from Opportunity where id=:oID];
			
			//update stage
			o.StageName = 'Closed Lost';
			o.Lost_Reason__c = stage.reason;
			update o;
			
			response.setSuccess('Contract set to closed lost!');
		} catch(Exception e) {
			response.setFailure('unable to set contract to closed lost: ' + e.getMessage() );
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