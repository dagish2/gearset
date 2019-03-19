/**
*	This task was updated to reuse some of the code we used to have for Payment notifications. 
*	Piggy-backing this endpoint, we changed the opportunity stage name and save the signed contract
* URL. We will revisit and refactor this in the future.
*	--@aldoforce
**/
@RestResource(urlMapping='/PaymentNotification/*')
global with sharing class RESTPaymentNotification {

    @HttpPost
    global static Response doPost(String opportunityID, String signed_contract_url ) {
    	RESTPaymentNotification.Response result = new RESTPaymentNotification.Response();
    	
      //do something to process the opportunityID payment notification
      try {
        //parse opportunity ID and catch any potential attack/injection
    		Id oID = Id.valueOf(opportunityID);

        //load the opportunity
        Opportunity o = [ SELECT Payment_Details_Status__c, Signed_Contract_URL__c 
                          FROM Opportunity 
                          WHERE Id = :oID 
                          LIMIT 1
                        ];

        //field update
        //o.Payment_Details_Status__c = 'Details Received';
        o.StageName = 'Closed Won';
        o.Signed_Contract_URL__c = signed_contract_url;

        //dml
        update o;

        //set response
    		result.setSuccess('successfully processed: ' + opportunityID); 
    	}
    	catch(Exception pEx) {
    		result.setFailure('unable to process: ' + opportunityID + '.' + pEx.getMessage() );
    	}
    	
    	return result;
    }

    global class Response {
    	global Boolean success;
    	global String message;

    	global void setSuccess(String pMessage) {this.success = true; this.message = pMessage;}
    	global void setFailure(String pMessage) {this.success = false; this.message = pMessage;}

    }

}