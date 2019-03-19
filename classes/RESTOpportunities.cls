//@RestResource(urlMapping='/Opportunities/*')
global with sharing class RESTOpportunities {
    
   /*
    @HttpGet
    global static Response doGet(){
        List<String> results;
        RESTOpportunities.Response response = new RESTOpportunities.Response(); 		
        try {            
            String accountUUID = RestContext.request.requestURI.substring(
                RestContext.request.requestURI.lastIndexOf('/') + 1
            );
            Debug.log('accountUUID==>'+accountUUID);            
            //ST-1156
            //Changes made by Amol Darekar to get UUID from Merge Account Object records call to method WeworkEngine.getMasterAccountUUID().
            List<Account> accounts = [SELECT id FROM Account WHERE UUID__c = : WeworkEngine.getMasterAccountUUID(accountUUID) LIMIT 1];
            if (accounts.isEmpty()){
                throw new AccountDoesNotExistException('Could not find account with UUID ' + accountUUID);
            }  
            results = OpportunityServices.getEncodedOpportunityIdsForAccount(accounts.get(0).id);           
            response.setSuccess(results);	
        }catch(Exception pEx) {
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
 	
 	global class AccountDoesNotExistException extends Exception {}*/
}