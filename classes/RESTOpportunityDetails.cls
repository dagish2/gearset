@RestResource(urlMapping='/OpportunityDetails/*')
global with sharing class RESTOpportunityDetails {

  @HttpPost
  global static Response doPost(WWTypes.OpportunityDetails body) {
    RESTOpportunityDetails.Response response = new RESTOpportunityDetails.Response();

    try {
      //serialize - might throw exceptions
      OpportunityServices.serializeOpportunityDetails(body);

      response.setSuccess('Perfect update!');


    }
    catch(Exception pEx) {
      response.setFailure('unable to process: ' + pEx.getMessage() );
    }
    
    return response;
  }

  @HttpGet
  global static Response doGet() {
  	WWTypes.OpportunityDetails result;
  	RESTOpportunityDetails.Response response = new RESTOpportunityDetails.Response();

    try {

    	//get encoded opportunity id
      String opportunityID = RestContext.request.requestURI.substring(
      													RestContext.request.requestURI.lastIndexOf('/') + 1
      											 );

    	//URL decode
    	opportunityID = EncodingUtil.urlDecode(opportunityID, 'UTF-8');

    	//rebuild base64
    	opportunityID = EncodingHandler.decode(opportunityID);

    	//parse opportunity ID and catch any potential attack/injection
  		Id oID = Id.valueOf(opportunityID);

    	//get the opportunity details object
    	result = OpportunityServices.getOpportunityDetails(oID);

      //set response
  		response.setSuccess(result); 

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